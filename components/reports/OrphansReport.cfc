<!----
	Name: <file name>         
	Copyright (c) 2014 Blacksmith Applications, Inc.       
	Description:This CFC contain functions that used to generate orphans program and billback reports.
	Usage: Settings>>Programs>>Budgets>>Research(tab)
	Label:D42242 Create links w/in the application for client to run report to see Orphaned BB's and Programs
---->
<cfcomponent>
	<cffunction name="getOrphanPrograms" output="false" returntype="query">
			<cfquery name="qGetOrphanPrograms" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmp_cm') IS NOT NULL
				DROP TABLE ##tmp_cm
				
				SELECT	cm.Contract_Number
								,CAST(0 as int) Max_CMID
								,CAST(null as datetime) as Program_Start
								,CAST(null as datetime) as Program_End
								into	##tmp_cm
				FROM		Contract_Main cm
				WHERE	cm.Deleted = 0
				AND		cm.Approved = 1
				AND		cm.Manual_Cancel = 0
				
				UPDATE	##tmp_cm
				SET		Program_Start = d.Program_Start
							,Program_End = d.Program_End
							,Max_CMID = d.Max_CMID
				FROM	##tmp_cm
				INNER JOIN (
										SELECT	cm.Contract_Number, 
														MIN(cm.Effective_Start_Date) as Program_Start, 
														MAX(cm.Effective_End_Date) as Program_End, 
														MAX(cm.Contract_Main_ID) as Max_CMID
										FROM	##tmp_cm t
										INNER JOIN Contract_Main cm
										ON			cm.Contract_Number = t.Contract_Number
										AND		cm.Effective_Start_Date IS NOT NULL
										GROUP BY cm.Contract_Number
										) d
				ON	##tmp_cm.Contract_Number = d.Contract_Number
				
				--- Get program budgets
				IF OBJECT_ID('tempdb..##tmp_pgm_budget') IS NOT NULL
				DROP TABLE ##tmp_pgm_budget
				
				SELECT	DISTINCT t.Contract_Number
								,t.Program_Start
								,t.Program_End
								,bc.Budget_Class_Desc
								,CAST(bc.Is_Fiscal as int) as Is_Fiscal
								,bc.Partial_Year
								,bc.Start_Date
								,bc.End_Date
				INTO	##tmp_pgm_budget
				FROM	##tmp_cm t
				INNER JOIN 	Budget_Program_Selection s
				ON					s.Program_ID = t.Max_CMID
				INNER JOIN 	Budget b
				ON					b.Budget_ID = s.Budget_ID
				INNER JOIN 	Budget_Class bc
				ON					bc.Budget_Class_ID = b.Budget_Class_ID
				
				-- If budget is partial year everything gets allocated to that budget so no need to check fot dates
				DELETE ##tmp_cm 
				WHERE Contract_Number IN (
																		SELECT Contract_Number 
																		FROM ##tmp_pgm_budget 
																		WHERE Partial_Year = 1
																	)
				DELETE ##tmp_pgm_budget 
				WHERE Contract_Number IN (
																		SELECT Contract_Number 
																		FROM ##tmp_pgm_budget 
																		WHERE Partial_Year = 1
																	)
				
				---- Find programs with dates outside budget
				IF OBJECT_ID('tempdb..##tmp_pgm_dates_outside') IS NOT NULL
				DROP TABLE ##tmp_pgm_dates_outside
				
				SELECT t.*
				INTO	##tmp_pgm_dates_outside
				FROM	##tmp_pgm_budget t
				WHERE	(Program_Start < Start_Date OR Program_Start > End_Date)
				AND		NOT EXISTS (
														SELECT	1
														FROM	##tmp_pgm_budget t2
														WHERE	t.Contract_Number = t2.Contract_Number
														AND		t2.Program_Start BETWEEN t2.Start_Date AND t2.End_Date
													)
				UNION
				SELECT	t.*
				FROM	##tmp_pgm_budget t
				WHERE	(Program_End < Start_Date OR Program_End > End_Date)
				AND		NOT EXISTS (
														SELECT	1
														FROM	##tmp_pgm_budget t2
														WHERE	t.Contract_Number = t2.Contract_Number
														AND		t2.Program_End BETWEEN t2.Start_Date AND t2.End_Date
													)
				UNION
				-- Catch any days in the middle that may not have a budget
				SELECT	DISTINCT t.*
				FROM	##tmp_pgm_budget t
				INNER JOIN RDB_Fiscal_Dates dd
				ON		dd.Day between t.Program_Start and t.Program_End
				WHERE	NOT (dd.Day BETWEEN Start_Date AND End_Date)
				AND		NOT EXISTS (
														SELECT	1
														FROM	##tmp_pgm_budget t2
														WHERE	t.Contract_Number = t2.Contract_Number
														AND		dd.Day BETWEEN t2.Start_Date AND t2.End_Date
													)
				
				
				-- List of programs without any budgets or with programs outside budget dates
				IF OBJECT_ID('tempdb..##tmp_pgm_list') IS NOT NULL
				DROP TABLE ##tmp_pgm_list
				
				SELECT	DISTINCT Contract_Number 
				INTO	##tmp_pgm_list
				FROM	##tmp_pgm_dates_outside
				UNION
				SELECT	Contract_Number
				FROM	##tmp_cm
				WHERE	NOT EXISTS (SELECT 1 FROM ##tmp_pgm_budget t WHERE t.Contract_Number = ##tmp_cm.Contract_Number)
				
				
				--- Generate the report
				
				IF OBJECT_ID('tempdb..##tmp_fy') IS NOT NULL
				DROP TABLE ##tmp_fy
				
				SELECT	Replace(fy.Fiscal_Year, '_20', '') as Fiscal_Year, MIN(fy.Start_Date) as Start_Date, MAX(fy.End_Date) as End_Date
				INTO	##tmp_fy
				FROM	Fiscal_Year fy
				WHERE	fy.Deleted = 0
				Group By fy.Fiscal_Year
				Order By MIN(fy.Start_Date)
				
				
				declare @year_start int,
				@year_end int
				
				select 	@year_start = year(getdate()) - 5,
				@year_end = year(getdate()) + 5
				
				IF OBJECT_ID('tempdb..##tmp_cy') IS NOT NULL
				DROP TABLE ##tmp_cy
				
				CREATE TABLE ##tmp_cy(CY_Desc varchar(10), Start_Date datetime, End_Date datetime)
				INSERT INTO ##tmp_cy (CY_Desc, Start_Date, End_Date)
				SELECT 	'CY' + cast(year as varchar(20)), start_date, end_date
				FROM 	udf_GetCalendarYears (@year_start, @year_end)
				ORDER BY year
				
				
				IF OBJECT_ID('tempdb..##tmp_PGM_report') IS NOT NULL
				DROP TABLE ##tmp_PGM_report
				
				SELECT	cm.Contract_Number, cm.Contract_Title, t.Created_Type,
				##tmp_cm.Program_Start,
				##tmp_cm.Program_End,
				CASE
				WHEN (
				SELECT	Max(Is_Fiscal)
				FROM	##tmp_pgm_budget
				WHERE	##tmp_pgm_budget.Contract_Number = cm.Contract_Number
				) = 1 THEN
				
				(
				SELECT	CAST(Fiscal_Year as varchar(20)) + ',' 
				FROM	##tmp_fy
				WHERE	##tmp_fy.Start_Date <= Program_End
				AND		##tmp_fy.End_Date >= Program_Start
				ORDER BY Fiscal_Year
				FOR XML PATH('')
				)
				
				ELSE
				
				(
				SELECT	CAST(CY_Desc as varchar(20)) + ',' 
				FROM	##tmp_cy
				WHERE	##tmp_cy.Start_Date <= Program_End
				AND		##tmp_cy.End_Date >= Program_Start
				ORDER BY CY_Desc
				FOR XML PATH('')
				)
				
				END as PGM_Dates,
				(
				SELECT	CAST(Budget_Class_Desc as varchar(20)) + ',' 
				FROM	##tmp_pgm_budget
				WHERE	##tmp_pgm_budget.Contract_Number = cm.Contract_Number
				ORDER BY Budget_Class_Desc
				FOR XML PATH('')
				) as Budget_Class
				INTO	##tmp_PGM_report
				FROM	##tmp_cm
				INNER JOIN Contract_Main cm
				ON		cm.Contract_Main_ID = ##tmp_cm.Max_CMID
				INNER JOIN Program_Control_Panel_Options t
				ON		t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
				WHERE	##tmp_cm.Contract_Number IN (SELECT Contract_Number FROM ##tmp_pgm_list)
				
				
				
				UPDATE	##tmp_PGM_report
				SET		PGM_Dates = SUBSTRING(PGM_Dates, 1, Len(PGM_Dates) - 1),
				Budget_Class = SUBSTRING(Budget_Class, 1, Len(Budget_Class) - 1)
				
				
				SELECT	*
				FROM	##tmp_PGM_report
			</cfquery>
	<cfreturn qGetOrphanPrograms />
	</cffunction>
	<cffunction name="getOrphanBillbacks" output="false" returntype="query">
			<cfquery name="qGetOrphanBillbacks" datasource="#application.datasource#">
				IF OBJECT_ID('tempdb..##tmp_Budget_all') IS NOT NULL
				DROP TABLE ##tmp_Budget_all
				
				SELECT	P.Billback_ID
							, cm.Contract_Number
							, Budget_Class.Budget_Class_Desc as Budget_Class_Desc
							, Budget_Class.Start_Date as Class_Start_Date
							, Budget_Class.End_Date as Class_End_Date
							, CAST(P.Actual_Dollar as decimal(20, 2)) as Act
				INTO	##tmp_Budget_all
				FROM	Budget
				INNER JOIN Budget_Class 
				ON			Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
				AND		Budget_Class.Deleted = 0
				AND		Budget_Class.Active = 1
				INNER JOIN Budget_Position_Billback P
				ON			P.Budget_ID = Budget.Budget_ID
				INNER JOIN Contract_Main cm
				ON			cm.Contract_Main_ID = P.Contract_Main_ID
				WHERE	Budget.Deleted = 0
				AND		Budget.Active = 1
				AND		ISNULL(Budget.Allocation_Position_Level, 0) != 4 -- Position Level
				UNION ALL
				SELECT	P.Billback_ID
				, cm.Contract_Number
				, Budget_Class.Budget_Class_Desc as Budget_Class_Desc
				, Budget_Class.Start_Date as Class_Start_Date
				, Budget_Class.End_Date as Class_End_Date
				, CAST(P.Actual_Dollar as decimal(20, 2)) as Act
				FROM	Budget
				INNER JOIN Budget_Class 
				ON			Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
				AND		Budget_Class.Deleted = 0
				AND		Budget_Class.Active = 1
				INNER JOIN Budget_Distributor_Billback P
				ON			P.Budget_ID = Budget.Budget_ID
				INNER JOIN Contract_Main cm
				ON			cm.Contract_Main_ID = P.Contract_Main_ID
				WHERE	Budget.Deleted = 0
				AND		Budget.Active = 1
				AND		ISNULL(Budget.Allocation_Position_Level, 0) = 4 -- Distributor Level
				UNION ALL
				SELECT	  Billback.Billback_ID
								, Contract_Main.Contract_Number
								,'' as Budget_Class_Desc
								, null as Class_Start_Date
								, null as Class_End_Date
								, 0 as Act
				FROM	Billback
				INNER JOIN BB_Approved
				ON			BB_Approved.Billback_ID = Billback.Billback_ID
				AND		BB_Approved.Paid_Amount != 0
				INNER JOIN Billback_Program
				ON			Billback_Program.Billback_ID = Billback.Billback_ID
				AND		Billback_Program.Deleted = 0
				INNER JOIN Contract_Main
				ON			Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
				WHERE	Billback.Deleted = 0
				AND		Billback.Billback_Status_ID = 5
				AND		Billback.BB_Parent_ID IS NULL
				AND		NOT EXISTS (
														SELECT	1
														FROM	Budget_Distributor_Billback
														INNER JOIN Contract_Main cm ON cm.Contract_Main_ID = Budget_Distributor_Billback.Contract_Main_ID
														WHERE	Budget_Distributor_Billback.Billback_ID = Billback.Billback_ID
														AND		cm.Contract_Number = Contract_Main.Contract_Number
													)
				AND		NOT EXISTS (
														SELECT	1
														FROM	Budget_Position_Billback
														INNER JOIN Contract_Main cm ON cm.Contract_Main_ID = Budget_Position_Billback.Contract_Main_ID
														WHERE	Budget_Position_Billback.Billback_ID = Billback.Billback_ID
														AND		cm.Contract_Number = Contract_Main.Contract_Number
													)		
				AND		EXISTS (
												SELECT	1
												FROM	Contract_Main as All_Versions
												INNER JOIN Budget_Program_Selection 
												ON		Budget_Program_Selection.Program_ID = All_Versions.Contract_Main_ID
												INNER JOIN Budget_Class 
												ON		Budget_Class.Budget_Class_ID = Budget_Program_Selection.Budget_Class_ID
												INNER JOIN Budget on Budget.Budget_ID = Budget_Program_Selection.Budget_ID
												WHERE	All_Versions.Contract_Number = Contract_Main.Contract_Number
												AND		All_Versions.Approved = 1
											)
				
				
				IF OBJECT_ID('tempdb..##tmp_BB_Budgets') IS NOT NULL
				DROP TABLE ##tmp_BB_Budgets
				
				SELECT	DISTINCT Billback_ID, Contract_Number, Budget_Class_Desc
				INTO	##tmp_BB_Budgets
				FROM	##tmp_Budget_all
				
				IF OBJECT_ID('tempdb..##tmp_Budget_sum') IS NOT NULL
				DROP TABLE ##tmp_Budget_sum
				
				SELECT	Billback_ID, Budget_Class_Desc, SUM(Act) as Act, MIN(Class_Start_Date) as Class_Start_Date, MAX(Class_End_Date) as Max_Class_End_Date
				INTO	##tmp_Budget_sum
				FROM	##tmp_Budget_all
				GROUP BY Billback_ID, Budget_Class_Desc
	
				IF OBJECT_ID('tempdb..##tmp_pgm_Budget_sum') IS NOT NULL
				DROP TABLE ##tmp_pgm_Budget_sum
				
				SELECT	Billback_ID, Contract_Number, SUM(Act) as Act, MIN(Class_Start_Date) as Class_Start_Date, MAX(Class_End_Date) as Max_Class_End_Date
				INTO	##tmp_pgm_Budget_sum
				FROM	##tmp_Budget_all
				GROUP BY Billback_ID, Contract_Number

				-- If BB Dates are outside bb budget class dates
				IF OBJECT_ID('tempdb..##tmp_actual_mismatch1') IS NOT NULL
				DROP TABLE ##tmp_actual_mismatch1
				
				SELECT	  BB_Actuals.Billback_ID
								, Billback.BB_Code
								, Billback.BB_Title
								, Billback.BB_Start_Date
								, Billback.BB_End_Date
								, case Billback.Uploaded_Billback
											when 0 then 'Manual'
											when 2 then 'User Upload'
											when 3 then 'EDI'
				end as Create_Type
				INTO	##tmp_actual_mismatch1
				FROM	##tmp_Budget_sum as BB_Actuals
				INNER JOIN Billback
				ON				 Billback.Billback_ID = BB_Actuals.Billback_ID
				INNER JOIN BB_Approved
				ON			BB_Approved.Billback_ID = BB_Actuals.Billback_ID
				WHERE	Billback.Billback_Status_ID = 5
				AND		Billback.Deleted = 0
				AND		Billback.BB_Parent_ID IS NULL
				AND		BB_Approved.Paid_Amount != 0
				Group By BB_Actuals.Billback_ID, Billback.BB_Code, Billback.BB_Title, BB_Approved.Paid_Amount, Billback.Uploaded_Billback, Billback.Created_Date, Billback.BB_Start_Date, Billback.BB_End_Date
				Having CAST(SUM(Act) - BB_Approved.Paid_Amount as Decimal(20, 0)) != 0
				
				
				-- If BB/PGM Dates are outside bb budget class dates
				IF OBJECT_ID('tempdb..##tmp_actual_mismatch') IS NOT NULL
				DROP TABLE ##tmp_actual_mismatch
				
				SELECT	DISTINCT BB_Actuals.*
				INTO	##tmp_actual_mismatch
				FROM	##tmp_actual_mismatch1 as BB_Actuals
				INNER JOIN Billback_Program
				ON			Billback_Program.Billback_ID = BB_Actuals.Billback_ID
				AND		Billback_Program.Deleted = 0
				INNER JOIN Contract_Main cm
				ON			cm.Contract_Main_ID = Billback_Program.Program_ID
				INNER JOIN ##tmp_pgm_Budget_sum
				ON			##tmp_pgm_Budget_sum.Billback_ID = BB_Actuals.Billback_ID
				AND		##tmp_pgm_Budget_sum.Contract_Number = cm.Contract_Number
				WHERE	(BB_End_Date > Max_Class_End_Date OR BB_Start_Date < Class_Start_Date OR Class_Start_Date IS NULL)
				
				
				
				IF OBJECT_ID('tempdb..##tmp_bb_pgm_amount') IS NOT NULL
				DROP TABLE ##tmp_bb_pgm_amount
				
				SELECT	cm.Contract_Number
								,cm.Contract_Start_Date
								,cm.Contract_End_Date
								,bpg.Billback_ID, bpg.Billback_Program_ID
								,CAST(null as decimal(20, 2)) as Item_Amount
								,CAST(null as decimal(20, 2)) as LS_Amount
								,CAST(null as decimal(20, 2)) as BB_PGM_Amount
				INTO	##tmp_bb_pgm_amount
				FROM	##tmp_actual_mismatch b
				INNER JOIN BB_Approved a
				ON		a.Billback_ID = b.Billback_ID
				INNER JOIN Billback_Program bpg
				ON			bpg.Billback_ID = b.Billback_ID
				AND		bpg.Deleted = 0
				INNER JOIN Contract_Main cm
				ON			cm.Contract_Main_ID = bpg.Program_ID
				
				UPDATE	##tmp_bb_pgm_amount
				SET		 Contract_Start_Date = PGMDates.Effective_Start_Date
							,Contract_End_Date = PGMDates.Effective_End_Date
				FROM	##tmp_bb_pgm_amount
				INNER JOIN (
										SELECT	cm.Contract_Number, MIN(cm.Effective_Start_Date) as Effective_Start_Date, MAX(cm.Effective_End_Date) as Effective_End_Date
										FROM	##tmp_bb_pgm_amount
										INNER JOIN Contract_Main cm
										ON		cm.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
										AND		cm.Effective_Start_Date IS NOT NULL
										GROUP BY cm.Contract_Number
									) as PGMDates
				ON	PGMDates.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
				
				
				IF OBJECT_ID('tempdb..##tmp_bb_pgm_item_amount') IS NOT NULL
				DROP TABLE ##tmp_bb_pgm_item_amount
				
				SELECT	  f.Billback_ID
								, f.Billback_Program_ID
								, SUM(f.Item_Volume_Paid_CS * fd.Paid_Rate_CS) as Item_Amount
				INTO	##tmp_bb_pgm_item_amount
				FROM	##tmp_bb_pgm_amount b
				INNER JOIN BB_Item_Final f
				ON			f.Billback_ID = b.Billback_ID
				AND		f.Billback_Program_ID = b.Billback_Program_ID
				AND		f.Deleted = 0
				INNER JOIN BB_Item_Final_Detail  fd
				ON			fd.BB_Item_Final_ID = f.BB_Item_Final_ID
				GROUP BY f.Billback_ID, f.Billback_Program_ID
				
				IF OBJECT_ID('tempdb..##tmp_bb_pgm_ls_amount') IS NOT NULL
				DROP TABLE ##tmp_bb_pgm_ls_amount
				
				SELECT	  ls.Billback_ID
								, ls.Billback_Program_ID
								, SUM(ls.LS_Paid_Amount) as LS_Amount
				INTO	##tmp_bb_pgm_ls_amount
				FROM	##tmp_bb_pgm_amount b
				INNER JOIN BB_Lump_Sums ls
				ON			ls.Billback_ID = b.Billback_ID
				AND		ls.Billback_Program_ID = b.Billback_Program_ID
				AND		ls.Deleted = 0
				GROUP BY ls.Billback_ID, ls.Billback_Program_ID

				UPDATE	##tmp_bb_pgm_amount
				SET		Item_Amount = d.Item_Amount
				FROM	##tmp_bb_pgm_amount b
				INNER JOIN ##tmp_bb_pgm_item_amount d
				ON		d.Billback_ID = b.Billback_ID
				AND		d.Billback_Program_ID = b.Billback_Program_ID
		
				UPDATE	##tmp_bb_pgm_amount
				SET		LS_Amount = d.LS_Amount
				FROM	##tmp_bb_pgm_amount b
				INNER JOIN ##tmp_bb_pgm_ls_amount d
				ON			d.Billback_ID = b.Billback_ID
				AND		d.Billback_Program_ID = b.Billback_Program_ID
	
				UPDATE	##tmp_bb_pgm_amount
				SET		BB_PGM_Amount = ISNULL(Item_Amount, 0) + ISNULL(LS_Amount, 0)

				IF OBJECT_ID('tempdb..##tmp_pgm_budget_class') IS NOT NULL
				DROP TABLE ##tmp_pgm_budget_class
				
				SELECT	DISTINCT cm.Contract_Number
								, CAST(bc.Is_Fiscal as int) as Is_Fiscal
								, bc.Budget_Class_Desc as Budget_Class_Desc
								, bc.Start_Date
								, bc.End_Date
				INTO	##tmp_pgm_budget_class
				FROM	##tmp_bb_pgm_amount
				INNER JOIN Contract_Main cm
				ON		cm.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
				AND		(
									cm.Effective_Start_Date IS NOT NULL
									OR (cm.Manual_Cancel = 1)
								)
				INNER JOIN Budget_Program_Selection s
				ON		s.Program_ID = cm.Contract_Main_ID
				INNER JOIN Budget b
				ON		b.Budget_ID = s.Budget_ID
				INNER JOIN Budget_Class bc
				ON		bc.Budget_Class_ID = b.Budget_Class_ID
				
				
				IF OBJECT_ID('tempdb..##tmp_fy') IS NOT NULL
				DROP TABLE ##tmp_fy
				
				SELECT	Replace(fy.Fiscal_Year, '_20', '') as Fiscal_Year
							, MIN(fy.Start_Date) as Start_Date
							, MAX(fy.End_Date) as End_Date
				INTO	##tmp_fy
				FROM	Fiscal_Year fy
				WHERE	fy.Deleted = 0
				Group By fy.Fiscal_Year
				Order By MIN(fy.Start_Date)
				
				declare @year_start int,
				@year_end int
				
				select 	@year_start = year(getdate()) - 5,
				@year_end = year(getdate()) + 5
				
				IF OBJECT_ID('tempdb..##tmp_cy') IS NOT NULL
				DROP TABLE ##tmp_cy
				
				CREATE TABLE ##tmp_cy(CY_Desc varchar(10), Start_Date datetime, End_Date datetime)
				INSERT INTO ##tmp_cy (CY_Desc, Start_Date, End_Date)
				SELECT 	'CY' + cast(year as varchar(20)), start_date, end_date
				FROM 	udf_GetCalendarYears (@year_start, @year_end)
				ORDER BY year
				
				
				IF OBJECT_ID('tempdb..##tmp_bb_report') IS NOT NULL
				DROP TABLE ##tmp_bb_report
				
				SELECT	CAST(null as varchar(50)) as Msg,
				##tmp_actual_mismatch.*,
				Contract_Number
				, Contract_Start_Date
				, Contract_End_Date
				, BB_PGM_Amount
				, ISNULL((
								SELECT	SUM(Act)
								FROM	##tmp_pgm_Budget_sum
								WHERE	##tmp_pgm_Budget_sum.Billback_ID = ##tmp_bb_pgm_amount.Billback_ID
								AND		##tmp_pgm_Budget_sum.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
								), 0) as BB_PGM_Actual
				, BB_PGM_Amount - 
				ISNULL((
							SELECT	SUM(Act)
							FROM	##tmp_pgm_Budget_sum
							WHERE	##tmp_pgm_Budget_sum.Billback_ID = ##tmp_bb_pgm_amount.Billback_ID
							AND		##tmp_pgm_Budget_sum.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
							), 0) as Diff,		
				
				CASE
				WHEN (
								SELECT	Max(Is_Fiscal)
								FROM	##tmp_pgm_budget_class
								WHERE	##tmp_pgm_budget_class.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
							) = 1 THEN
				
							(
								SELECT	CAST(Fiscal_Year as varchar(20)) + ',' 
								FROM	##tmp_fy
								WHERE	##tmp_fy.Start_Date <= BB_End_Date
								AND		##tmp_fy.End_Date >= BB_Start_Date
								ORDER BY Fiscal_Year
								FOR XML PATH('')
							)
				
				ELSE
				
				(
				SELECT	CAST(CY_Desc as varchar(20)) + ',' 
				FROM	##tmp_cy
				WHERE	##tmp_cy.Start_Date <= BB_End_Date
				AND		##tmp_cy.End_Date >= BB_Start_Date
				ORDER BY CY_Desc
				FOR XML PATH('')
				)
				
				END as BB_Dates,
				
				CASE
				WHEN (
								SELECT	Max(Is_Fiscal)
								FROM	##tmp_pgm_budget_class
								WHERE	##tmp_pgm_budget_class.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
							) = 1 THEN
				
							(
								SELECT	CAST(Fiscal_Year as varchar(20)) + ',' 
								FROM	##tmp_fy
								WHERE	##tmp_fy.Start_Date <= Contract_End_Date
								AND		##tmp_fy.End_Date >= Contract_Start_Date
								ORDER BY Fiscal_Year
								FOR XML PATH('')
							)			
				
				ELSE
				
							(
								SELECT	CAST(CY_Desc as varchar(20)) + ',' 
								FROM	##tmp_cy
								WHERE	##tmp_cy.Start_Date <= Contract_End_Date
								AND		##tmp_cy.End_Date >= Contract_Start_Date
								ORDER BY CY_Desc
								FOR XML PATH('')
							)
							
				END as PGM_Dates,
				
							(
								SELECT	CAST(Budget_Class_Desc as varchar(20)) + ',' 
								FROM	##tmp_BB_Budgets
								WHERE	##tmp_BB_Budgets.Billback_ID = ##tmp_actual_mismatch.Billback_ID
								AND		##tmp_BB_Budgets.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
								ORDER BY Budget_Class_Desc
								FOR XML PATH('')
							) as Billback_Budget_Class,
							
							(
								SELECT	CAST(Budget_Class_Desc as varchar(20)) + ',' 
								FROM	##tmp_pgm_budget_class
								WHERE	##tmp_pgm_budget_class.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number
								ORDER BY Budget_Class_Desc
								FOR XML PATH('')
							) as Program_Budget_Class,
							
				(SELECT Min(Start_Date) FROM ##tmp_pgm_budget_class WHERE ##tmp_pgm_budget_class.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number) as Program_Budget_Start,
				(SELECT Max(End_Date) FROM ##tmp_pgm_budget_class WHERE ##tmp_pgm_budget_class.Contract_Number = ##tmp_bb_pgm_amount.Contract_Number) as Program_Budget_End
				
				INTO	##tmp_bb_report
				FROM	##tmp_actual_mismatch
				INNER JOIN ##tmp_bb_pgm_amount
				ON		##tmp_bb_pgm_amount.Billback_ID = ##tmp_actual_mismatch.Billback_ID
				
				
				UPDATE	##tmp_bb_report
				SET		Billback_Budget_Class = SUBSTRING(Billback_Budget_Class, 1, Len(Billback_Budget_Class) - 1),
				Program_Budget_Class = SUBSTRING(Program_Budget_Class, 1, Len(Program_Budget_Class) - 1),
				BB_Dates = SUBSTRING(BB_Dates, 1, Len(BB_Dates) - 1),
				PGM_Dates = SUBSTRING(PGM_Dates, 1, Len(PGM_Dates) - 1)
				
				
				
				UPDATE	##tmp_bb_report
				SET		Msg = 'BB outside Budget dates'
				WHERE	Msg IS NULL
				AND		Diff != 0
				AND		(BB_Start_Date < Program_Budget_Start
				OR		BB_Start_Date > Program_Budget_End
				OR		BB_End_Date < Program_Budget_Start
				OR		BB_End_Date > Program_Budget_End
				)
				
				UPDATE	##tmp_bb_report
				SET		Msg = 'BB outside Program dates'
				WHERE	Msg IS NULL
				AND		Diff != 0
				AND		(BB_Start_Date < Contract_Start_Date
				OR		BB_Start_Date > Contract_End_Date
				OR		BB_End_Date < Contract_Start_Date
				OR		BB_End_Date > Contract_End_Date
				)
				
				
				
				SELECT 	 BB_Code
								,BB_Title
								,BB_Start_Date
								,BB_End_Date
								,Create_Type
								,Msg	
								,Contract_Number
								,Contract_Start_Date
								,Contract_End_Date
								,BB_PGM_Amount
								,BB_PGM_Actual
								,Diff
								,BB_Dates
								,PGM_Dates
								,Billback_Budget_Class
								,Program_Budget_Class
								,Program_Budget_Start
								,Program_Budget_End
				FROM	##tmp_bb_report
				WHERE	Msg IS NOT NULL
				AND		Diff != 0
			</cfquery>
	<cfreturn qGetOrphanBillbacks />
	</cffunction>
</cfcomponent>