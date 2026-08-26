<cfparam name="Page_Relocate" default="">
<cfparam name="URL.Program_ID" default="">
<cfparam name="URL.ID" default="">
<cfparam name="Action" default="">
<cfparam name="CatalogView" default="0">
<cfparam name="URL.RevisionHistory" default="0">
<cfparam name="URL.CPAccess" default=""><!--- 83860 URL.CPAccess will be used in Application_Common.cfm ---->

<cfif URL.Program_ID eq "" and URL.ID neq "">
	<cfset URL.Program_ID = URL.ID />
</cfif>

<cf_include files="/styles/css-loader.css">
<cfinclude template="/Common_Files/jQuery.cfm">
<div class="customContainer" style="display:none;"></div>
	
<cfset local.URLCPAccessArg = "" />
<cfif request.AccessStructure.External_Customer_Profile_Access EQ "1">
	<cfset local.URLCPAccessArg = "&CPAccess=#URL.CPAccess#" />
</cfif>
	
	<cfif not isDefined("request.app_general_functions")>
		<!--- This page is used by Flex to encrypt program_id --->
		<!---initialize general functions to be used throuhout the application--->
		<cfset request.app_general_functions = CreateObject("component","components.general.General_Functions") />
	</cfif>
<!---D57639 :: View all versions of programs in program search START---> 
	<cfinclude template="/get_access_profile.cfm">
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()> 

		<!--- Request for program preview or program summary --->
		<cfif URL.Program_ID NEQ "">
			<CF_CRYP type="en" string="#URL.Program_ID#" key="#request.key#">
			<cfset CID = cryp.value>
		</cfif>

		<cfset useLakebaseForprgStatusCheck = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForprgStatusCheck>
	<cftry>
		<cfset prgStatusCheck = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#URL.Program_ID#",
				"select" = "deleted"
			}), "deleted"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForprgStatusCheck = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForprgStatusCheck>
<cfquery name="prgStatusCheck" datasource="#application.datasource#">
		SELECT deleted
		FROM Contract_Main
		WHERE Contract_Main_ID = #URL.Program_ID#
		</cfquery>
</cfif>
<!--- 61496 : View Program Versions link does not show program vesions
when app setting "Display all versions in program search" is ON we display deleted program in search when user click preview and 'view program version' above query causing to show error invalid number
due to program is set DELETED = 1 added code to set deleted = 0 when app setting in ON 
--->
 <cfset deleted = prgStatusCheck.deleted>		 
<cfif val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1>
	<cfset deleted = 0>	
</cfif>
<!--- 61496 : View Program Versions link does not show program vesions END--->
	<cfif URL.Program_ID neq "" AND prgStatusCheck.deleted AND appSettings.getModifyExpiredPrograms() AND Get_Profile_Settings.Modify_Expired_Programs AND val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 1 AND URL.RevisionHistory EQ 0>
		<cflocation url="#Page_Relocate#?CID=#CID#&display_program=1&FromFlex=1">
	<cfelseif URL.Program_ID neq "" AND prgStatusCheck.deleted AND (appSettings.getModifyExpiredPrograms() EQ 0 OR Get_Profile_Settings.Modify_Expired_Programs EQ 0 OR val(appSettings.get_Setting('Display_PGR_Versions_In_search')) EQ 0) AND URL.RevisionHistory EQ 0>
		<cflocation url="/scorecard/program_display.cfm?CID=#CID#&display_program=1&FromFlex=1">	
<!---D57639 :: View all versions of programs in program search END---> 
	<cfelseif URL.Program_ID neq "" AND deleted EQ 0 and action neq "copy" and action neq "print" and action neq "email">
		<cfscript>
			request.key = request.app_general_functions.GenerateKey();
		</cfscript>
		<cfif URL.RevisionHistory>
			
			<cfquery name="getContractNumber" datasource="#application.datasource#">
		            SELECT CM.Contract_number, count(CM.Contract_number) AS TotalVersions
		            FROM Contract_Main
		            INNER JOIN Contract_Main CM
		            ON          	CM.Contract_Number = Contract_Main.Contract_Number
		            AND         CM.Approved = 1
		            WHERE Contract_Main.Contract_Main_ID = #URL.Program_ID# 
		            GROUP BY CM.Contract_number         
			</cfquery>			
			
			<cfif getContractNumber.recordcount>
				<cfif getContractNumber.TotalVersions EQ 1>
					<cflocation url="/scorecard/program_display.cfm?CID=#CID#&contract_number=#getContractNumber.Contract_number#&display_program=1&FromFlex=1">
				<cfelse>
					<cflocation url="/common_files/contracts/contract_revision_history.cfm?CID=#CID#&RevisionHistory=1&showallversions=1&contract_number=#getContractNumber.Contract_number#&display_program=1&FromFlex=1">
				</cfif>
			</cfif>

		<cfelseif CatalogView eq 0>
			<script>
			show_loader( "LOADING... PLEASE WAIT...");
			<cfoutput>
				window.location.href = '#Page_Relocate#?CID=#CID#&display_program=1&FromFlex=1#local.URLCPAccessArg#';
			</cfoutput>
			</script>
		<cfelse>
			<!--- Catalog View (Pass CatalogView=1) --->
			<script>
			show_loader( "LOADING... PLEASE WAIT...");
			<cfoutput>
				window.location.href = '#Page_Relocate#?CID=#CID#&CatalogView=1&FromFlex=1#local.URLCPAccessArg#';
			</script>
			</cfoutput>
		</cfif>
	<!--- Request for email/print/copy --->
	<cfelse>
		<cflocation url="#Page_Relocate#?Contract_Main_ID=#ID#&FromFlex=1&Action=#Action#">
	</cfif>