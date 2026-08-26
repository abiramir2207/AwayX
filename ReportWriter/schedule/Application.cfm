<!---Sets datasource name--->

<cfinclude template="/application_datasource.cfm">

<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

<!------
<CFIF NOT isDefined("request.AccessStructure.company_main_id")>
	<cfset useLakebaseForGet_Company_Main_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGet_Company_Main_ID>
	<cftry>
		<cfset Get_Company_Main_ID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"deleted" = "eq.0",
				"select" = "company_main_id"
			}), "company_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Company_Main_ID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Company_Main_ID>
<CFQUERY NAME="Get_Company_Main_ID" DATASOURCE="#application.datasource#">
	SELECT 	Company_Main_ID
	FROM	Company_Main
	WHERE
			Company_Main.Deleted = 0
	</CFQUERY>
</cfif>
	
	<CFIF Get_Company_Main_ID.recordCount GT 0>
		<CFSET request.AccessStructure.company_main_id = Get_Company_Main_ID.Company_Main_ID>
	</CFIF>
</CFIF>

<cfinclude template="/settings/load_global_customer_settings_action.cfm">

----->

<!---Sets global settings --->
<cfif fileexists("#Application.Doc_Path#\data_files\created\settings\customer_settings\Memory_Data\Data\application_include.cfm")>
	<cfinclude template="#Application.Doc_Mapping#/data_files/created/settings/customer_settings/Memory_Data/Data/application_include.cfm">
</cfif>

<CFSET request.AccessStructure.User_ID = "0000000000">