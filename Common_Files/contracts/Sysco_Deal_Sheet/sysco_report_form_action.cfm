
<!---Update or insert database values?--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<!--- <Cfdump var="#form#"> --->
<CFINCLUDE template="/includes/call_please_wait.cfm">

<cfset useLakebaseForUpdateAllToDeleted = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("sysco_deal_sheet_programs")>
<cfif useLakebaseForUpdateAllToDeleted>
	<cftry>
		<cfset application.oLakebase.updateRows("sysco_deal_sheet_programs",
			{
				"contract_main_id" = "eq.#form.Contract_Main_ID#"
			},
			{
				"deleted" = "1",
				"deleted_date" = "#now()#",
				"deleted_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAllToDeleted = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAllToDeleted>
<cfquery name="UpdateAllToDeleted" datasource="#application.datasource#">
UPDATE Sysco_Deal_Sheet_Programs
SET Deleted = 1,
Deleted_Date = getdate(),
Deleted_By = '#request.AccessStructure.User_ID#'
WHERE Contract_Main_ID = #form.Contract_Main_ID#
</cfquery>
</cfif>

<cfloop index = "I"
  from = "1"
  to = "#NumberofRecords#">


<Cfif form.UseDBValues IS 1 and isDefined("RecordID_#i#") >
	
	<Cfif trim(evaluate("RecordID_#i#")) IS NOT "">
	<!---Update db values--->
	<cfquery name="UpdateSavedValues" datasource="#application.datasource#">
	UPDATE Sysco_Deal_Sheet_Programs
	SET 
	Contract_Main_ID = #form.Contract_Main_ID#,
	Supplier_CS = #evaluate("Supplier_CS_#i#")#,
	BSCC_CS = #evaluate("BSCC_CS_#i#")#,
	Total_CS = #evaluate("Total_CS_#i#")#,
	ABC_CS = #evaluate("ABC_CS_#i#")#,
	CC_CS = #evaluate("CC_CS_#i#")#,
	Original_Fixed = #evaluate("Original_Fixed_#i#")#,
	Original_Rebate = #evaluate("Original_Rebate_#i#")#,
	Product_ID = '#evaluate("Product_ID_#i#")#',
	Distributor_ID = '#evaluate("Distributor_ID_#i#")#',
	WH_Number	= '#evaluate("WH_Number_#i#")#',
	Deleted = 0,
	Updated_Date = getdate(),
	Updated_By = '#request.AccessStructure.User_ID#'
	WHERE Sysco_DS_Program_ID = '#evaluate("RecordID_#i#")#'
	</cfquery>
	
	<cfelse>
		<cfquery name="InsertSavedValues" datasource="#application.datasource#"> 
		INSERT INTO Sysco_Deal_Sheet_Programs
		(
			Contract_Main_ID,
			Supplier_CS,
			BSCC_CS,
			Total_CS,
			ABC_CS,
			CC_CS,
			Original_Fixed,
			Original_Rebate,
			Product_ID,
			Distributor_ID,
			WH_Number,
			Created_By			
		)
		VALUES
		(
			#form.Contract_Main_ID#,
			#evaluate("Supplier_CS_#i#")#,
			#evaluate("BSCC_CS_#i#")#,
			#evaluate("Total_CS_#i#")#,
			#evaluate("ABC_CS_#i#")#,
			#evaluate("CC_CS_#i#")#,
			#evaluate("Original_Fixed_#i#")#,
			#evaluate("Original_Rebate_#i#")#,
			'#evaluate("Product_ID_#i#")#',
			'#evaluate("Distributor_ID_#i#")#',
			'#evaluate("WH_Number_#i#")#',
			'#request.AccessStructure.User_ID#'
		)
		</cfquery>
	
	</CFIF>
	
	<cfelse>
	<!---Insert db values--->
		<cfquery name="InsertSavedValues" datasource="#application.datasource#"> 
		INSERT INTO Sysco_Deal_Sheet_Programs
		(
			Contract_Main_ID,
			Supplier_CS,
			BSCC_CS,
			Total_CS,
			ABC_CS,
			CC_CS,
			Original_Fixed,
			Original_Rebate,
			Product_ID,
			Distributor_ID,
			WH_Number,
			Created_By			
		)
		VALUES
		(
			#form.Contract_Main_ID#,
			#evaluate("Supplier_CS_#i#")#,
			#evaluate("BSCC_CS_#i#")#,
			#evaluate("Total_CS_#i#")#,
			#evaluate("ABC_CS_#i#")#,
			#evaluate("CC_CS_#i#")#,
			#evaluate("Original_Fixed_#i#")#,
			#evaluate("Original_Rebate_#i#")#,
			'#evaluate("Product_ID_#i#")#',
			'#evaluate("Distributor_ID_#i#")#',
			'#evaluate("WH_Number_#i#")#',
			'#request.AccessStructure.User_ID#'
		)
		</cfquery>
	
	</CFIF>

</cfloop>

<!--- Approve the program.  This is the brute force 1 click method! --->

<cfif form.approve>
    <!--- <CFQUERY NAME="ApproveContract" datasource="#application.datasource#">
		UPDATE Contract_Main
		Set 
			Approval_Date = getdate()
			,Approved = 1
			,Approved_By_User_ID = '#request.AccessStructure.User_ID#'
			,Is_Manual_Revision = Is_A_Revision
			,Broker_Approved = 1
			,Broker_Approved_date = getdate()
			,Broker_User_ID = '#request.AccessStructure.User_ID#'
	   WHERE Contract_Main_Id = #form.Contract_Main_ID#
	</CFQUERY>
	
	     <CFSET contract_main_id = form.Contract_Main_ID>
		 <CFSET generateReleaseProgramID = contract_main_id>
		 <cfset CloseWindow = 0>
		 <cfinclude template="generate_approve_email.cfm">  --->
		 <CFPARAM NAME="FORM.Program_Is_A_Revision" DEFAULT="0">
	     <CFPARAM NAME="FORM.Pay_Brokerage" DEFAULT="EMPTY">
		 <cfset CloseWindow = 0>
		 
		   <cfset cryp.value = form.Contract_Main_ID>
				   <CFQUERY NAME="getProgramTemplateInfo" datasource="#application.datasource#">
						SELECT     dbo.Program_Control_Panel_Options.Active, dbo.Program_Control_Panel_Options.Deleted, dbo.Contract_Main.Parent_Revised_Contract_Main_ID, 
						                      dbo.Contract_Main.Revision_of_Contract_Main_ID
						FROM         dbo.Contract_Main INNER JOIN
						                      dbo.Program_Control_Panel_Options ON 
						                      dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
						WHERE dbo.Contract_Main.Contract_Main_ID = '#form.Contract_Main_ID#'
					</CFQUERY>
					
					<CFSET ProgramIsARevision = 0>
					<CFIF len(trim(getProgramTemplateInfo.Parent_Revised_Contract_Main_ID)) NEQ 0 AND len(trim(getProgramTemplateInfo.Revision_of_Contract_Main_ID)) NEQ 0>
						<CFSET ProgramIsARevision = 1>
					</CFIF>
					
					<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#form.Contract_Main_ID#",
				"select" = "contract_start_date,contract_end_date,revision_of_contract_main_id"
			}), "contract_start_date,contract_end_date,revision_of_contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<CFQUERY NAME="GetContractInfo" datasource="#application.datasource#">
							SELECT Contract_Start_Date, Contract_End_Date, Revision_Of_Contract_Main_ID
							FROM Contract_Main
							WHERE Contract_Main_ID = '#form.Contract_Main_ID#'
					</CFQUERY>
</cfif>
		   <cfinclude template="/common_files/contracts/contract_approve_broker_action_include.cfm">
		   
				<CFQUERY NAME="getProgramTemplateInfo" datasource="#application.datasource#">
						SELECT     dbo.Program_Control_Panel_Options.Active, dbo.Program_Control_Panel_Options.Deleted, dbo.Contract_Main.Parent_Revised_Contract_Main_ID, 
						                      dbo.Contract_Main.Revision_of_Contract_Main_ID, Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
						FROM         dbo.Contract_Main INNER JOIN
						                      dbo.Program_Control_Panel_Options ON 
						                      dbo.Contract_Main.ProgramType_ID = dbo.Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
						WHERE dbo.Contract_Main.Contract_Main_ID = '#form.Contract_Main_ID#'
				</CFQUERY>
				
				<CFQUERY NAME="getSettings" datasource="#application.datasource#">
					SELECT	*
					FROM	dbo.Program_Control_Panel_Options
					WHERE ProgramControl_Panel_Options_ID = '#getProgramTemplateInfo.ProgramControl_Panel_Options_ID#'
				</CFQUERY>
		   <cfinclude template="/common_files/contracts/contract_approve_action_include.cfm">
		 
		 
</cfif>

<CF_CRYP type="en" string="#form.Contract_Main_ID#" key="#request.key#">
<cfset CID = cryp.value>

<!--- <cfoutput><cflocation url="sysco_report_form.cfm?CID=#CID#"></cfoutput> ---> 

<cfoutput> <form name="FrmApproveAction" target="mywindowname" action="sysco_report_form.cfm?CID=#CID#" method="post"></form></cfoutput>

	<script>
	FrmApproveAction.submit();
	</script>
</body>
</html>