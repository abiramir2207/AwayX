<!---
file: ReportWriter\Programs_Beyond_EZ_Rate.cfm
Created on : 10/12/2014
Useed to generate a CVS file with list of programs with items rate above EZ rate.
--->

 <cfquery name="qGetProgramsWithAboveEZRates" datasource="#Application.Datasource#">
 	IF OBJECT_ID('tempdb..##tmp_cm') IS NOT NULL
	DROP TABLE ##tmp_cm
	
	select	cm.Contract_Main_ID, 
				cm.Contract_Number + ' - '+
				CASE
					WHEN LEN(cm.revision_version) = 4 THEN RIGHT('000' + CAST(cm.revision_version AS VARCHAR(10)), 4)
					WHEN LEN(cm.revision_version) = 5 THEN RIGHT('000' + CAST(cm.revision_version AS VARCHAR(10)), 5)
					ELSE RIGHT('000' + CAST(cm.revision_version AS VARCHAR(10)), 3)
				END AS [Contract],
				cm.revision_version AS [Version ##],
				Replace(cm.Contract_Title,',',' ')  AS [Title], 
				t.Created_Type AS [Template], 
				CASE t.EZButton_On 
				when 1 then 'EZ Template' else '' 
				END AS [EZ Template],
				cm.Contract_Created_Date AS [Created On], 
				cm.Broker_Approved_Date AS [RFA On],
				cm.Approval_Date AS [Approved On],
				u.Name_First + ' ' + u.Name_Last AS [Approved By],
				cm.Notes,
				t.EZ_Contract_Id,
				cm.Contract_Start_Date,
				cm.Contract_End_Date,
				cm.Contract_Created_Date,
				cm.Creator_ID,
				cm.Responsible_User_ID	
	into		##tmp_cm
	from	Contract_Main cm
	inner join Program_Control_Panel_Options t
	on		t.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
	left join _users u
	on		u.User_ID = cm.Approved_By_User_ID
	where	cm.Deleted = 0
	and		cm.Approved = 1
	and		t.EZButton_On = 1
	and		(cm.Contract_Status_Type_IDX = 2 OR DateDiff(d, cm.Approval_Date, GETDATE()) <= 367)

	IF OBJECT_ID('tempdb..##tmp_cp') IS NOT NULL
	DROP TABLE ##tmp_cp

	select	cm.*,
				cp.Contract_Products_ID, 
				cp.Product_Type_ID, 
				cp.BSA_Foodservice_Items_Master_ID, 
				i.Item, cast(cd.Rate AS float) AS Rate, 
				cd.Unit_Of_Measure_ID,
				UOM.Unit_of_Measure_Desc_Singular,
				i.Description
	into		##tmp_cp
	from	##tmp_cm cm
	inner join Contract_Products cp
	on		cp.Contract_Main_ID = cm.Contract_Main_ID
	and		cp.Deleted = 0
	and		cp.Is_Group = 0
	inner join BSA_Foodservice_Items_Master i
	on		i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	inner join Program_Rebates_Component rc
	on		rc.Program_ID = cm.Contract_Main_ID
	and		rc.Deleted = 0
	inner join Program_Rebates_Product_Data pd
	on		pd.Contract_Products_ID = cp.Contract_Products_ID
	and		pd.Deleted = 0
	inner join Program_Rebates_Component_Data cd
	on		cd.Program_Rebates_Product_Data_ID = pd.Program_Rebates_Product_Data_ID
	and		cd.Program_Rebates_Component_ID = rc.Program_Rebates_Component_ID
	and		cd.Deleted = 0
	inner join Units_of_Measure UOM
	on		UOM.Unit_Of_Measure_ID = cd.Unit_Of_Measure_ID

	IF OBJECT_ID('tempdb..##tmp_reb_rate') IS NOT NULL
	DROP TABLE ##tmp_reb_rate

	select	Contract_Main_ID, 
				BSA_Foodservice_Items_Master_ID, 
				Item, SUM(Rate) AS Rate, 
				##tmp_cp.description,
				CAST(null as float) AS EZ_Rate,
				CAST(null as varchar(10)) AS EZ_UOM,
				##tmp_cp.Unit_of_Measure_Desc_Singular AS Program_UOM,
				CAST(null as varchar(50)) AS Approved_By,
				CAST(null as datetime) AS Approved_Date
	into		##tmp_reb_rate
	from	##tmp_cp
	group by Contract_Main_ID, BSA_Foodservice_Items_Master_ID, Item, description,Unit_of_Measure_Desc_Singular

	IF OBJECT_ID('tempdb..##tmp_ez_rate') IS NOT NULL
	DROP TABLE ##tmp_ez_rate

	select	cm.Contract_Main_ID,
				cp.Contract_Products_ID, 
				cp.Product_Type_ID, 
				cp.BSA_Foodservice_Items_Master_ID, 
				i.Item, cast(cd.Rate as float) AS Rate, 
				cd.Unit_Of_Measure_ID, 
				UOM.Unit_of_Measure_Desc_Singular
	into	##tmp_ez_rate
	from	##tmp_cm cm
	inner join Contract_Products cp
	on		cp.Contract_Main_ID = cm.EZ_Contract_Id
	and		cp.Deleted = 0
	and		cp.Is_Group = 0
	inner join BSA_Foodservice_Items_Master i
	on		i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
	inner join Program_Rebates_Component rc
	on		rc.Program_ID = cm.EZ_Contract_Id
	and		rc.Deleted = 0
	inner join Program_Rebates_Product_Data pd
	on		pd.Contract_Products_ID = cp.Contract_Products_ID
	and		pd.Deleted = 0
	inner join Program_Rebates_Component_Data cd
	on		cd.Program_Rebates_Product_Data_ID = pd.Program_Rebates_Product_Data_ID
	and		cd.Program_Rebates_Component_ID = rc.Program_Rebates_Component_ID
	and		cd.Deleted = 0
	inner join Units_of_Measure UOM
	on		UOM.Unit_Of_Measure_ID = cd.Unit_Of_Measure_ID

	update	##tmp_reb_rate
	set		EZ_Rate = ##tmp_ez_rate.Rate, 
				EZ_UOM = ##tmp_ez_rate.Unit_of_Measure_Desc_Singular
	from	##tmp_reb_rate
	inner join ##tmp_ez_rate
	on		##tmp_ez_rate.Contract_Main_ID = ##tmp_reb_rate.Contract_Main_ID
	and		##tmp_ez_rate.BSA_Foodservice_Items_Master_ID = ##tmp_reb_rate.BSA_Foodservice_Items_Master_ID

	IF OBJECT_ID('tempdb..##tmp_tc_approvals') IS NOT NULL
	DROP TABLE ##tmp_tc_approvals

	select	cm.Contract_Main_ID, 
				cm.BSA_Foodservice_Items_Master_ID, 
				tc.User_Id, tc.created_date, 
				MIN(tc.created_date) OVER(PARTITION BY cm.Contract_Main_ID, 
				cm.BSA_Foodservice_Items_Master_ID) AS Min_Created_Date
	into	##tmp_tc_approvals
	from	##tmp_reb_rate cm
	inner join Program_Type_Code_Approval_Info tc
	on		tc.Program_Id = cm.Contract_Main_ID
	and		tc.Product_Id = cm.BSA_Foodservice_Items_Master_ID
	and		tc.deleted = 0
	and		tc.Approve = 1
	where	Rate > EZ_Rate

	update	##tmp_reb_rate
	set			Approved_By = ##tmp_tc_approvals.User_Id,
					Approved_Date = ##tmp_tc_approvals.Min_Created_Date
	from		##tmp_reb_rate
	inner join ##tmp_tc_approvals
	on		##tmp_tc_approvals.Contract_Main_ID = ##tmp_reb_rate.Contract_Main_ID
	and		##tmp_tc_approvals.BSA_Foodservice_Items_Master_ID = ##tmp_reb_rate.BSA_Foodservice_Items_Master_ID
	and		##tmp_tc_approvals.Min_Created_Date = ##tmp_tc_approvals.created_date
	where	Rate > EZ_Rate

	select	##tmp_cm.Template,
				##tmp_cm.Contract,
				##tmp_cm.Title, 
				##tmp_cm.Contract_Start_Date,
				##tmp_cm.Contract_End_Date,
				u2.Name_First+' '+u2.Name_Last AS RSP, 
				u1.Name_First+' '+u1.Name_Last AS Created_by, 
				##tmp_cm.Contract_Created_Date,	
				##tmp_cm.[Approved By] AS Approved_By,
				##tmp_cm.[Approved On] AS Approved_On,
				''''+##tmp_reb_rate.Item AS Item,
				##tmp_reb_rate.description,
				##tmp_reb_rate.EZ_Rate as Template_EZ_Rate,
				##tmp_reb_rate.EZ_UOM as Template_EZ_UOM,
				##tmp_reb_rate.Rate as Program_Rate,
				##tmp_reb_rate.Program_UOM as Program_UOM,
				##tmp_reb_rate.Rate - ##tmp_reb_rate.EZ_Rate as Variance
	from	##tmp_cm
	inner join ##tmp_reb_rate
	on		##tmp_reb_rate.Contract_Main_ID = ##tmp_cm.Contract_Main_ID
	and		##tmp_reb_rate.Rate > ##tmp_reb_rate.EZ_Rate
	left join _users u
	on		u.user_id = ##tmp_reb_rate.Approved_By
	inner join _users u1
	on		u1.user_id = ##tmp_cm.Creator_ID
	inner join _users u2
	on		u2.user_id = ##tmp_cm.Responsible_User_ID
	left join Profiles p
	on		p.Profiles_ID = u.Profiles_ID	  
	Order by ##tmp_cm.Contract DESC
 </cfquery>
 
<!--- 
	47846: Event error 1486 - (65536) outside allowable range/Anand Rao/30-Jan-2015
	Changed the HSSFSHEET to csv download, so that the user can download the file
	even if it exceeds the row range of 0...65536
--->
 
<!--- Create a STRING BUFFER to hold the output --->

<Cfdump var="#qGetProgramsWithAboveEZRates#" /><!--- abort= "true"  --->
<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >
	
	<!--- Header row --->
	<cfset fileOutput.append("Template" & ",")>
	<cfset fileOutput.append("Program ##" & ",")>
	<cfset fileOutput.append("Program Title" & ",")>
	<cfset fileOutput.append("Start Date" & ",")>
	<cfset fileOutput.append("End Date" & ",")>
	<cfset fileOutput.append("Program RSP" & ",")>
	<cfset fileOutput.append("Created By" & ",")>
	<cfset fileOutput.append("Created Date" & ",")>
	<cfset fileOutput.append("Approved By" & ",")>
	<cfset fileOutput.append("Approved Date" & ",")>
	<cfset fileOutput.append("Item" & ",")>
	<cfset fileOutput.append("Description" & ",")>
	<cfset fileOutput.append("Template EZ Rate" & ",")>
	<cfset fileOutput.append("Template EZ UOM" & ",")>
	<cfset fileOutput.append("Program Rate" & ",")>
	<cfset fileOutput.append("Program Rate UOM" & ",")>											
	<cfset fileOutput.append("Variance" & ",")>
 	<cfset fileOutput.append(Chr(13) & Chr(10))>
	 
	<!--- Detail row: loop through the query, and append the records to the buffer	--->
	<cfloop query="qGetProgramsWithAboveEZRates">
		<cfset fileOutput.append(Template & ",")>
		<cfset fileOutput.append(Contract & ",")>
		<cfset fileOutput.append(Title & ",")>
		<cfset CSD = Dateformat(Contract_Start_Date,'mm/dd/yyyy')/>		
		<cfset fileOutput.append(CSD & ",")>
		<cfset CED = Dateformat(Contract_End_Date,'mm/dd/yyyy')/>		
		<cfset fileOutput.append(CED & ",")>
		<cfset fileOutput.append(RSP & ",")>
		<cfset fileOutput.append(Created_By & ",")>
		<cfset CCD = Dateformat(Contract_Created_Date,'mm/dd/yyyy')/>		
		<cfset fileOutput.append(CCD & ",")>
		<cfset fileOutput.append(Approved_By & ",")>
		<cfset AOD = Dateformat(Approved_On,'mm/dd/yyyy')/>		
		<cfset fileOutput.append(AOD & ",")>
		<cfset fileOutput.append(Item & ",")>
		<cfset fileOutput.append(description & ",")>
		<cfset fileOutput.append(DollarFormat(Template_EZ_Rate) & ",")>
		<cfset fileOutput.append(Template_EZ_UOM & ",")>
		<cfset fileOutput.append(DollarFormat(Program_Rate) & ",")>
		<cfset fileOutput.append(Program_UOM & ",")>														
		<cfset fileOutput.append(DollarFormat(Variance))>
	 	<cfset fileOutput.append(Chr(13) & Chr(10))>
	</cfloop>	  
	 
 	<cfset DownloadFileName = "Programs_With_Items_Above_EZRates" & "_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />
	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\ReportWriter\" & DownloadFileName  />	 
	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#"  >
	
	<!--- download link --->
	<cfheader name="Content-Disposition" value="attachment;filename=#DownloadFileName#"  />
	<cfcontent type="application/csv" file="#pathFileName#" deletefile="no"  />
	

