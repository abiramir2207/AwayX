<!---Sets datasource name--->

<cfinclude template="/application_datasource.cfm">

<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

<!------
<CFIF NOT isDefined("request.AccessStructure.company_main_id")>
	<CFQUERY NAME="Get_Company_Main_ID" DATASOURCE="#application.datasource#">
	SELECT 	Company_Main_ID
	FROM	Company_Main
	WHERE
			Company_Main.Deleted = 0
	</CFQUERY>
	
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