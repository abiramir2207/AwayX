<!---Identify unique file name --->
<cfset UniqueGeneralName = replace(request.AccessStructure.User_ID, "-", "_", "all") & dateformat(now(), 'mm_dd_mm_ss')>
<cfset UniqueFileName = "ExportFreight" & UniqueGeneralName & ".txt">

<!---Set file location --->
<cfset filepath = application.Doc_Path & "\Temp_Files\Export\Freight\"  & UniqueFileName>

<!---Write file from form to server --->
	<CFFILE action = "write"
					file="#filepath#"
					output="#trim(form.Freightdata)#">

<!--- Sets the path for uploading the form field to a file --->
<cfset FiletoUpload = "\\" & Application.WebServerName & "\" & Replace(filepath, ":", "$")>

<cfif NOT FileExists(FiletoUpload)>
	<cfset FileToUpload = filepath>
</cfif>

	<cfquery name="ExecuteSP" datasource="#application.datasource#"> 
	exec Update_Export_Freight '#FiletoUpload#'
	</cfquery>

<cflocation url="index.cfm?Action=#Action#">