<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\settings_export.cfm
      Date:     2022 September
      Author:   Dinesh Rachala
      Purpose:  Download Settings List
----------------------------------------------------------------------------------------------------------------------->
<cfquery name="getAccessStatus" datasource="#application.datasource#">
		SELECT tbl1.Module_Name,
			CASE
			WHEN tbl2.Settings_Panel_Access_Modules_ID IS NULL THEN
				'Hide'
			ELSE
				'Show'
			END AS Status, P.Profiles_Desc
	FROM Settings_Panel_Access_Modules tbl1
	LEFT JOIN Settings_Panel_Access_Modules_Profiles tbl2
	ON tbl1.Settings_Panel_Access_Modules_ID = tbl2.Settings_Panel_Access_Modules_ID
	INNER JOIN dbo.Profiles P
	ON P.Profiles_ID = tbl2.Profiles_ID
	WHERE Module_Name = 'users_search_form'
</cfquery> 

<cfset header="Setting Name">
<cfset headerValue="List Users">
			<cfloop query="getAccessStatus">
				<cfset header = listAppend(header, #Profiles_Desc#)>
			</cfloop>

			<cfloop query="getAccessStatus">
				<cfset headerValue= listAppend(headerValue, #Status#)>
			</cfloop>

<cfscript>
	//Use an absolute path for the files.
	FileName = "List_Users_Access_Info_"&#request.AccessStructure.User_ID#&".xls";
	donwloadfilepath = application.Doc_Path & "\Temp_Files\settings\" & FileName;

	objSpreadsheet=spreadsheetnew("Settings");

	SpreadSheetAddRow(objSpreadsheet,"#header#");
	SpreadSheetAddRow(objSpreadsheet, #headerValue#);

	SpreadsheetSetActiveSheet(objSpreadsheet, 'Settings');
</cfscript>

<cfspreadsheet action="write" filename="#donwloadfilepath#" name="objSpreadsheet" sheetname="#lcase(application.returned_customer_setting.operator_label_plural)#" overwrite=true>

<cfheader name="Content-Disposition" value="attachment; filename=#FileName#" >
<cfcontent type="application/vnd.ms-excel" file="#donwloadfilepath#">























