<cfif datepart('d', now()) IS "1">


<!---Yeah, I know I should have done contract number. Instead, I'll check to see if any of these have a more recent revision, and update accordingly--->
<cfquery name="CheckforRevisions" datasource="#application.datasource#">
SELECT Contract_Main_ID, Contract_Number FROM Contract_Main 
WHERE Deleted = 1
AND Contract_Main_ID IN (SELECT Program_ID FROM Auto_Checkbook WHERE Deleted = 0)
AND Contract_Number NOT IN (SELECT DISTINCT Contract_Number FROM Contract_Main WHERE Deleted = 0)
</cfquery>

<cfloop query="CheckforRevisions">
	<cfset useLakebaseForGetNewContractMain = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetNewContractMain>
	<cftry>
		<cfset GetNewContractMain = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_number" = "eq.#CheckforRevisions.Contract_Number#",
				"deleted" = "eq.0",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetNewContractMain = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetNewContractMain>
<Cfquery name="GetNewContractMain" datasource="#application.datasource#">
	SELECT Contract_Main_ID FROM Contract_Main WHERE Contract_Number = #CheckforRevisions.Contract_Number# AND Deleted = 0
	</CFQUERY>
</cfif>
	<cfif GetNewContractMain.Recordcount IS 1>
		<cfset useLakebaseForUpdateAutoCheckbook = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_checkbook")>
<cfif useLakebaseForUpdateAutoCheckbook>
	<cftry>
		<cfset application.oLakebase.updateRows("auto_checkbook",
			{
				"program_id" = "eq.#CheckforRevisions.Contract_Main_ID#"
			},
			{
				"program_id" = "#GetNewContractMain.Contract_Main_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAutoCheckbook = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAutoCheckbook>
<cfquery name="UpdateAutoCheckbook" datasource="#application.datasource#">
		UPDATE Auto_Checkbook
		SET Program_ID = '#GetNewContractMain.Contract_Main_ID#'
		WHERE Program_ID = '#CheckforRevisions.Contract_Main_ID#'
		</cfquery>
</cfif>
	
	</cfif>
</cfloop>
<!---Stops housecleaning, starts real work--->

<!---Get eligible auto checkbooks--->
<cfset useLakebaseForGetEligibleAutoCheckbooks = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_checkbook")>
<cfif useLakebaseForGetEligibleAutoCheckbooks>
	<cftry>
		<cfset GetEligibleAutoCheckbooks = application.oLakebase.toQuery(
			application.oLakebase.selectRows("auto_checkbook", {
				"deleted" = "eq.0",
				"select" = "program_id,distributor_id,send_to"
			}), "program_id,distributor_id,send_to"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetEligibleAutoCheckbooks = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetEligibleAutoCheckbooks>
<cfquery name="GetEligibleAutoCheckbooks" datasource="#application.datasource#">
SELECT Program_ID, Distributor_ID, Send_To
FROM Auto_Checkbook
WHERE Deleted = 0
</cfquery>
</cfif>

<!---Gets correct "From" address--->
<cfinclude template="/get_Contact_Admin_Email_Address.cfm">

<cfset ShowLedger = 1>
<cfset CalledFrom="Scheduled">
<cfset FormattedDate = dateformat(now(), 'mm-dd-yyyy')>

<cfloop query="GetEligibleAutoCheckbooks">

	<cfset url.ProgramList = GetEligibleAutoCheckbooks.Program_ID>
	<cfset url.Distributorlist = GetEligibleAutoCheckbooks.Distributor_ID>
	<cfset FinalProgramList = GetEligibleAutoCheckbooks.Program_ID>
	<cfset FinalDistributorList = GetEligibleAutoCheckbooks.Distributor_ID>
	<cfset Get_Profile_Settings.Reimbursement_Update = 0>
	<cfset ShowDetails = 1>
	
	<cfsavecontent variable="Checkbook_#GetEligibleAutoCheckbooks.Program_ID#">
		<cfinclude template="/billbacks/ledger/index.cfm">
	</cfsavecontent>
	
	<!----Build directory structure--->
<cfif DirectoryExists("#Application.Doc_Path#\temp_files\auto_checkbook") IS FALSE>
	<cfdirectory action="create" directory="#Application.Doc_Path#/temp_files/auto_checkbook">
</cfif>
	
	<CFFILE 	ACTION 			=	"Write"
				FILE 		= 	"#Application.Doc_Path#\Temp_Files\Auto_Checkbook\Checkbook_#FormattedDate#_#GetEligibleAutoCheckbooks.Program_ID#.html"
				OUTPUT 		= 	"#evaluate("Checkbook_#GetEligibleAutoCheckbooks.Program_ID#")#"
				ADDNEWLINE 	=	"Yes" 
				nameconflict = "overwrite"
				>
	
	<cfset FileLocation = #Application.Doc_Path# & "\Temp_Files\Auto_Checkbook\Checkbook_" &#FormattedDate# & "_" & #GetEligibleAutoCheckbooks.Program_ID# & ".html">
	
	<cfoutput>
	<CF_EMAILWRAPPER TO			=	"#Send_To#"
        FROM					=	"#Contact_Admin_Email_Address#"
        SUBJECT					=	"Update on #ProgramName# (#ProgramNumber#) for #DistributorName#"
		TYPE					=	"html" 
		GeneratedBy				= 	"2"
		messagetype="1" 
		apparea="1" 
	>
	
		This is your update on #ProgramName# (#ProgramNumber#) for #DistributorName#.
	<CF_EMAILWRAPPERPARAM FILE = "#FileLocation#" store="yes" />
	</CF_EMAILWRAPPER>
	</cfoutput>
			
</cfloop>

<!---Retire any that have programs that have expired--->

<cfquery name="GetProgramstoRetire" datasource="#application.datasource#">
SELECT Auto_Checkbook.Auto_Checkbook_ID
FROM Auto_Checkbook
	INNER JOIN Contract_Main
	ON Contract_Main.Contract_Main_ID = Auto_Checkbook.Program_ID
	AND 
	(	Contract_Main.Deleted = 1
		OR 
		Contract_Main.Contract_Status_Type_IDX > 6
	)
</cfquery>

<cfloop query="GetProgramstoRetire">
	<cfset useLakebaseForRetirePrograms = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_checkbook")>
<cfif useLakebaseForRetirePrograms>
	<cftry>
		<cfset application.oLakebase.updateRows("auto_checkbook",
			{
				"auto_checkbook_id" = "eq.#GetProgramstoRetire.Auto_Checkbook_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForRetirePrograms = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForRetirePrograms>
<cfquery name="RetirePrograms" datasource="#application.datasource#">
	UPDATE Auto_Checkbook
	SET Deleted = 1
	WHERE Auto_Checkbook_ID = '#GetProgramstoRetire.Auto_Checkbook_ID#'
	</cfquery>
</cfif>

</cfloop>
Executed
<cfelse>
Did not execute
</cfif>