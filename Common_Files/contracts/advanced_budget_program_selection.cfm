<!---
	Name:          	advanced_budget_program_selection.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	06/14/2011
	Created By:    	Deepa Kunnath
	Description:   	This page is the UI for displaying [budget $ / committed $ / balance / trade spend $] per component inside the program
	Parameters:
	Usage:
--->

<cfset programId = CONTRACT_MAIN_ID />
<cfset programSpendUseCommittedDollar = 1 >

<CFQUERY NAME="GetProgramExpired" datasource="#application.datasource#">
	select  isnull(cast(sum(cast(manual_cancel as int)) as bit), 0) as program_cancelled,
			case when MAX(Effective_End_Date) < CAST(CONVERT(CHAR(10), GETDATE(), 101) as datetime) then 1 else 0 end as program_expired,
			MIN(Effective_Start_Date) as Program_Start
	from  	contract_main
	where 	Contract_Number = '#getProgramInfo.Contract_Number#'
	and		approved = 1
</CFQUERY>

<cfset useLakebaseForGetProgramDates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetProgramDates>
	<cftry>
		<cfset GetProgramDates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#programId#",
				"select" = "contract_start_date,contract_end_date"
			}), "contract_start_date,contract_end_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetProgramDates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProgramDates>
<CFQUERY NAME="GetProgramDates" datasource="#application.datasource#">
	select  Contract_Start_Date, Contract_End_Date
	from  	contract_main
	where 	Contract_Main_ID = #programId#
</CFQUERY>
</cfif>

<cfset ProgramStart = GetProgramDates.Contract_Start_Date />
<cfset ProgramEnd = GetProgramDates.Contract_End_Date />
<!--- Use start date from earlier version if it has an earlier date  --->
<cfif isDate(GetProgramExpired.Program_Start) and DATEDIFF("d", GetProgramExpired.Program_Start, ProgramStart) GT 0>
	<cfset ProgramStart = GetProgramExpired.Program_Start />
</cfif>

<cfif GetProgramExpired.program_cancelled eq 0
	AND GetProgramExpired.program_expired eq 0
	AND getProgramInfo.contract_status_type_idx LTE 2>
	<!--- Program is not canelled or expired and current version is an RFA or WIP
	Same applies to a brand new WIP/RFA also --->
	<cfset programSpendUseCommittedDollar = 0>
<cfelseif GetProgramExpired.program_cancelled eq 0
	AND GetProgramExpired.program_expired eq 1
	AND getProgramInfo.contract_status_type_idx LTE 2
	AND DateDiff("d", Now(), getProgramInfo.Contract_End_Date) GTE 0>
	<!--- Program is not canelled but is expired and current version is an RFA or WIP
	But WIP/RFA version has a future date --->
	<cfset programSpendUseCommittedDollar = 0>
</cfif>

<CFQUERY NAME="qBudgetDollarForProgram" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##tmp_comm_upd_program_budget_selection') IS NOT NULL
	DROP TABLE ##tmp_comm_upd_program_budget_selection

	create table ##tmp_comm_upd_program_budget_selection (
		contract_main_id int,
		Budget_Class_ID int, Budget_Class_Desc varchar(200),
		start_date datetime, end_date datetime,
		allocation_start_date datetime, allocation_end_date datetime,
		Budget_ID int, Budget_Desc varchar(200),
		Budget_Contribution_Factor_Type_ID smallint, Allocation_Position_Level smallint,
		user_position_id int,
		position_label  varchar(200),
		bsa_foodservice_customers_id uniqueidentifier,
		shr_ship_to varchar(50),
		distributor_name  varchar(200),
		Budget_Dollar decimal(20, 0),
		Committed_Dollar decimal(20, 0),
		Actual_Dollar decimal(20, 0),
		Revision_Committed_Adjustment decimal(20, 2),
		Budget_Balance decimal(20, 0),
		Program_Trade_Spend_Dollar_LS decimal(20, 2),
		Program_Trade_Spend_Dollar_Non_LS decimal(20, 2),
		Program_Trade_Spend_Dollar decimal(20, 2),
		Budget_Balance_After_Approval decimal(20, 2)
	)

	insert into ##tmp_comm_upd_program_budget_selection
	EXEC ADV_BUDGET_GET_AVAIL_FOR_PGM #programId#

	<cfif programSpendUseCommittedDollar>
	<!--- Find the program committed dollar and use it --->

	IF OBJECT_ID('tempdb..##tmp_pg_committed') IS NOT NULL
	DROP TABLE ##tmp_pg_committed

	SELECT	pg.Budget_ID, SUM(pg.Committed_Dollar) as Committed_Dollar
	INTO	##tmp_pg_committed
	FROM	Budget b
	INNER JOIN	Budget_Position_Program pg
	ON		pg.Budget_ID = b.Budget_ID
	AND		pg.Contract_Number = '#getProgramInfo.Contract_Number#'
	WHERE	b.Deleted = 0
	AND		ISNULL(b.Allocation_Position_Level, 0) != 4
	GROUP BY pg.Budget_ID
	UNION
	SELECT	pg.Budget_ID, SUM(pg.Committed_Dollar) as Committed_Dollar
	FROM	Budget b
	INNER JOIN	Budget_Distributor_Program pg
	ON		pg.Budget_ID = b.Budget_ID
	AND		pg.Contract_Number = '#getProgramInfo.Contract_Number#'
	WHERE	b.Deleted = 0
	AND		ISNULL(b.Allocation_Position_Level, 0) = 4
	GROUP BY pg.Budget_ID

	update	t
	set		Program_Trade_Spend_Dollar = ISNULL(c.Committed_Dollar, 0),
			Budget_Balance_After_Approval = t.Budget_Balance
	from	##tmp_comm_upd_program_budget_selection t
	left join ##tmp_pg_committed c
	on	t.Budget_ID = c.Budget_ID

	</cfif>

	select	*
	from	##tmp_comm_upd_program_budget_selection
	order by allocation_end_date
</CFQUERY>


<cfset bUserCannotApproveBudget = 0 />
<cfset bProgramhasBudget = 0 />
<cfset sProgramBudgetMessage = "" />
<cfset bBudgetMissingProgramSpan = 0 />

<cfif qBudgetDollarForProgram.recordCount>
	<tr class="budget">
		<style>
			.subHeading {background-color: #FFCE84; font-weight:bold; font-size:14px;}
		</style>

		<!--- WR 113506 - insert an empty cell into first column, without it our margin page would be rendered with a very wide 1st sticky column --->
		<td>&nbsp;</td>

		<td class='ln_144' colspan="100%" style="border:none;">
			<br>
			<cfscript>
				tdStyle = "text-align:right;padding-right:3px;font-size:12px;";

				// append table id to use in export to csv option
				param name="request.table2csv" default="#arrayNew( 1 )#";
				table_id = "advanced_budget_program_selection";

				request.table2csv.append( "table##" & table_id );
			</cfscript>

			<cfoutput>
			<table width="100%" id="#table_id#" style="border-collapse:collapse">
				<thead>
					<tr valign="top" class="subHeading">
						<th class='ln_153' style="font-size:12px;">Budget/<br>Class</th>
						<th class='ln_154' style="font-size:12px;">Position/<br>#application.returned_customer_setting.distributor_label_singular#</th>
						<th class='ln_155' style="#tdStyle#">Budget $</th>
						<th class='ln_156' style="#tdStyle#">Committed $</th>
						<th class='ln_157' style="#tdStyle#">Actual $</th>
						<cfif getProgramInfo.is_a_revision EQ 1 and getProgramInfo.contract_status_type_idx LTE 2>
							<th class='ln_159' style="#tdStyle#">Revision Adj.</th>
						</cfif>
						<th style="#tdStyle#" class="balanceHeader">Balance</th>
						<th class='ln_162' style="#tdStyle#">Overall<br>Constraint <img border="0" src="/Images/i.gif" width="12" height="11" id="overall_constraint" title=""></th>
						<th class='ln_182' style="#tdStyle#">Version<br>Contribution</th>
						<cfif getProgramInfo.contract_status_type_idx LTE 2>
							<th style="#tdStyle#" class="balanceHeader">Balance<br>After Approval</th>
						</cfif>
					</tr>
				</thead>
			</cfoutput>

				<cfset tdStyle="text-align:right;padding-right:3px;">
				<tbody>
					<cfset prevBudgetEndDate = "" />
					<cfoutput query="qBudgetDollarForProgram">
						<tr valign="top">
							<td class='ln_195'>#Budget_Desc#<br>#Budget_Class_Desc#</td>
							<td class='ln_196'>
								<cfif Allocation_Position_Level eq 4>
									#Shr_Ship_to#<br>#Distributor_Name#
								<cfelse>
									#Position_Label#
								</cfif>
							</td>
							<td class='ln_203' style="#tdStyle#">#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Budget_Dollar)#</td>
							<td class='ln_204' style="#tdStyle#">#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Committed_Dollar)#</td>
							<td class='ln_205' style="#tdStyle#">#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Actual_Dollar)#</td>
							<cfif getProgramInfo.is_a_revision EQ 1 and getProgramInfo.contract_status_type_idx LTE 2>
								<td class='ln_207' style="#tdStyle#">#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Revision_Committed_Adjustment)#</td>
							</cfif>
							<td class='ln_209' style="#tdStyle#"
								<cfif qBudgetDollarForProgram.currentRow eq qBudgetDollarForProgram.recordCount>
									<cfif Budget_Balance neq "" and Budget_Balance lt 0> class="balanceLastRowNegative" <cfelse> class="balanceLastRowPositive" </cfif>
								<cfelse>
									<cfif Budget_Balance neq "" and Budget_Balance lt 0> class="balanceRowNegative" <cfelse> class="balanceRowPositive" </cfif>
								</cfif>
								>
									#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Budget_Balance)#
							</td>
							<td class='ln_218' style="#tdStyle#">&nbsp;</td>
							<td class='ln_219' style="#tdStyle#">#DollarFormat(Program_Trade_Spend_Dollar)#</td>
							<cfif getProgramInfo.contract_status_type_idx LTE 2>
								<td class='ln_221' style="#tdStyle#"
									<cfif qBudgetDollarForProgram.currentRow eq qBudgetDollarForProgram.recordCount>
										<cfif Budget_Balance_After_Approval neq "" and Budget_Balance_After_Approval lt 0> class="balanceLastRowNegative" <cfelse> class="balanceLastRowPositive" </cfif>
									<cfelse>
										<cfif Budget_Balance_After_Approval neq "" and Budget_Balance_After_Approval lt 0> class="balanceRowNegative" <cfelse> class="balanceRowPositive" </cfif>
									</cfif>
								>
									#application.oApplicationAppSettingsManager.DollarFormatWithBlank(Budget_Balance_After_Approval)#
								</td>
							</cfif>
						</tr>
						<!--- For variable budget dollar will not be available --->
						<cfif Budget_Balance_After_Approval LT 0 AND Budget_Contribution_Factor_Type_ID NEQ 3 AND Get_Profile_Settings.Approve_Pgm_Beyond_Budget EQ 0>
							<cfset bUserCannotApproveBudget = 1 />
							<cfset sProgramBudgetMessage = "You cannot approve programs over the budget balance" />
						</cfif>

						<!--- See if there is any gap between budgets as long as program has not ended --->
						<cfif isDate(prevBudgetEndDate)
							AND DATEDIFF("d", prevBudgetEndDate, qBudgetDollarForProgram.start_date) GT 1
							AND DATEDIFF("d", prevBudgetEndDate, ProgramEnd) GT 0>
							<cfset bBudgetMissingProgramSpan = 1 />
						</cfif>
						<cfset prevBudgetEndDate = qBudgetDollarForProgram.end_date />
					</cfoutput>

					<!--- 28378	Margin page - display alert if prg for future period & no budget setup...  --->
					<CFQUERY NAME="qGetBudgetClassEndDate" dbtype="query">
						select MIN(start_date) as min_budget_start_date, MAX(end_date) as max_budget_date from qBudgetDollarForProgram
					</CFQUERY>

					<cfif isDate(qGetBudgetClassEndDate.max_budget_date)  <!--- 35229 --->
						and DATEDIFF("d", qGetBudgetClassEndDate.max_budget_date, getProgramInfo.contract_end_date) GT 0
						and getProgramInfo.contract_end_date gt now()>
						<tr>
							<td class='ln_256' colspan="100%" style="color:red;border-bottom:none;padding:2px">
								Trade $ for future days not allocated because there is no budget.
							</td>
						</tr>
					</cfif>
				</tbody>
			</table>

			<!--- Below variable will let the approval page knwo so that it can display Agree link and the message at the bottom  --->
			<cfset programAgreeOnlyForBudgetDollar = bUserCannotApproveBudget />
			<cfset bProgramhasBudget = 1 />

			<!--- check if all of the program dates have budget selection --->
			<cfif appSettings.getBudgetSelectionRequired()>
				<cfif not isDate(qGetBudgetClassEndDate.min_budget_start_date) or not isDate(qGetBudgetClassEndDate.max_budget_date)>
					<cfset bBudgetMissingProgramSpan = 1 />
				<cfelseif qGetBudgetClassEndDate.min_budget_start_date gt ProgramStart or qGetBudgetClassEndDate.max_budget_date lt ProgramEnd>
					<cfset bBudgetMissingProgramSpan = 1 />
				</cfif>

				<cfif bBudgetMissingProgramSpan>
					<cfset bUserCannotApproveBudget = 1 />
					<cfset programAgreeOnlyForBudgetDollar = 1 />
					<cfset sProgramBudgetMessage = ListAppend(sProgramBudgetMessage, "Budget selection is required for entire program period") />
				</cfif>
			</cfif>
		</td>
	</tr>

<cfelseif appSettings.getBudgetSelectionRequired()>
	<cfset bUserCannotApproveBudget = 1 />
	<cfset bProgramhasBudget = 0 />
	<cfset programAgreeOnlyForBudgetDollar = 1 />
	<cfset sProgramBudgetMessage = "You cannot approve program without budget" />
</cfif>

<cfoutput>
<input type="hidden" id="Budget_Agree_Approve_Status" name="Budget_Agree_Approve_Status" value="#bUserCannotApproveBudget#">
</cfoutput>

