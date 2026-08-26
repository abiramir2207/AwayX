 <!--- "URL.Cancel" is for cancelling multiple programs (by default only one program can be cancelled) --->

<cfparam name="URL.Cancel" default ="0">
<cfparam name="URL.CancelERP" default ="0">
<cfparam name="FORM.cancel_option" 	default="0">
<cf_cryp type="de" key="#request.key#" string="#FORM.Program_ID#">
<cfset FORM.cancel_option = Val(FORM.cancel_option) />

<cfset newEndDate = "" />
<cfif FORM.cancel_option EQ 1>
	<cfset newEndDate = DateFormat(Now(), "mm/dd/yyyy") />
</cfif>
<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentsOn = 0 />
<cfif businessSegManager.isEnabled()>
	<cfset businessSegmentsOn = 1 />
</cfif>
<cfset program = CreateObject("component", "components.programs.program") />
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset qGetProgramInfo = program.getProgramInfo(cryp.value) />
<!------ SEND DATA TO SAP ----->
<cfif appsettings.getsend_to_sap()>
	 <CFQUERY NAME="updatecontractmain" datasource="#application.datasource#">
		update 	contract_main
		set 	Sent_To_External_Client = 1,
				Cancel_Sent_To_External_Client = 1<!---D28127: Manual cancelations are not working --->
		<cfif FORM.cancel_option EQ 1>
				,Contract_End_Date = <cfqueryparam value="#newEndDate#" cfsqltype="CF_SQL_DATE">
				,Cancel_And_End_Dated = 1
			<cfif dateDiff("d", Now(), qGetProgramInfo.Contract_Start_Date) GT 0>
				,Contract_Start_Date = <cfqueryparam value="#newEndDate#" cfsqltype="CF_SQL_DATE">
			</cfif>
		</cfif>
		where 	contract_main_id = #cryp.value#
		and 	deleted = 0
	</CFQUERY>
	
	<cfif FORM.cancel_option EQ 1><!------ if end date is changing ----->
		<!------ update effective dates for all versions of the program ----->
		<cfstoredproc procedure="PROGRAM_EFFECTIVE_DATES_UPDATE" datasource="#application.datasource#">
								
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@CONTRACT_MAIN_ID" value = "#cryp.value#" null="no">
					
		</cfstoredproc>
	</cfif>
	
	<div align="center"><font size="2" color="red"> SENDING DATA TO SAP, PLEASE CHECK LATER!!!!.</font> </div>
	
	<cfset PathToExe 	= ExpandPath("\Utils\BSA_HTTP.exe")>
	<cfset outputpath 	= ExpandPath("\Utils\Output\#cryp.value#.html")>
	<cfset InputFile="url=http://#appSettings.getWebserverInternalIPAddress()#/Scheduled/send_cancelled_program_SAP.cfm?program_id=#cryp.value#&user_id=#request.AccessStructure.user_id#&delete=1&SMPROFILE=NO&cancel_option=#FORM.cancel_option# outputpath=#outputpath#">
	<cfexecute
	     name="#PathToExe#"
	     arguments="#InputFile#">
	</cfexecute>

<cfelse><!------ NOT SEND DATA TO SAP ----->

	<cfset programsettings =  program.getprogramsettings(cryp.value)>
	
	<!------ DATE EXCLUSION PROGRAMS ----->
	<cfif programsettings.Date_Exclusions_ON EQ 1>
		<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />	
		<CFSET ContractIDList = GenProgramManager.ChildProgramIDs(cryp.value,0)>
		<cfset ChildProgramIDList = ValueList(ContractIDList.Revision_Program_ID)>
		<cfif ListLen(ChildProgramIDList) neq 0>
			 <cfloop list="#ChildProgramIDList#" index="ContractID">
				<cfset deleteSuccess = program.cancelProgram(
							programId = ContractID,
							userId = request.AccessStructure.User_ID,
							cancelallprogramversions = appsettings.getcancelallprogramversions(),
							Date_Exclusions_ON = programsettings.Date_Exclusions_ON,
							IS_Date_Exclusions_child = 1,
							cancelOption = FORM.cancel_option
							) />
				<cfif URL.CancelERP EQ 1><!------ CANCEL ERP ----->
					<cfset program.CancelProgramInERP(ContractID) />
				</cfif>
			 </cfloop>
		</cfif>
	</cfif>
	<!------ CANCEL CURRENT PROGRAM ----->
	<cfset program.cancelProgram(
				programId = cryp.value,
				userId = request.AccessStructure.User_ID,
				cancelallprogramversions = appsettings.getcancelallprogramversions(),
				Date_Exclusions_ON = programsettings.Date_Exclusions_ON,
				IS_Date_Exclusions_child = 0,
				cancelOption = FORM.cancel_option
				) />
	<cfif URL.CancelERP EQ 1><!------ CANCEL ERP ----->
		<cfset program.CancelProgramInERP(cryp.value) />
	</cfif>
	<!------ Get application settings ----->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	
	<cfif appSettings.getCancelProgramEmail()><!------ CANCEL PGM: SEND EMAIL ----->
		<cfset send_Cancel_Email_Now = 1>
		<cfset send_Email_Program_ID = cryp.value>
		<cfinclude template="\anything_automated\email\cancelled_programs_emailer.cfm">
	</cfif>
</cfif>

<!--- If cancelling a single program --->
<cfif URL.Cancel eq 0>
<!---48555 Cancel Program Settings unlock the program--->
<cfstoredproc procedure="USP_Contract_Lock_Unlock" datasource="#application.datasource#">
		<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@User_ID" value="#request.AccessStructure.user_id#">
		<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Unlock" value="1">
		<cfprocparam type="In" cfsqltype="cf_sql_bit" dbVarName="@Lock" value="0">
		<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Lock_Program_ID" value="0">
		<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Lock_Program_Number" value="">
		<cfprocparam type="In" cfsqltype="cf_sql_integer" dbVarName="@Unlock_Program_ID" value="0">
		<cfprocparam type="In" cfsqltype="cf_sql_varchar" dbVarName="@Unlock_Program_Number" value="">
</cfstoredproc>

<script language="javascript">
if(window.opener)
{
	//window.opener.location.href='/flex/search/ProgramSearchFx.cfm?Reload=1'; <!---48555 Cancel Program Settings--->
	window.close();
}
else
{
	window.location.href= '/manufacturers/home.cfm';
}
</script>
</cfif>