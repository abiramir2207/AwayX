<!---
  * ====================================================================================================
  *  @Author: Milan Mushran
  *  @Date: 2019-3-21
  *  User can upload ALias data from the Alias Management screen
  * ====================================================================================================
--->

<cfset UniqueGeneralName = replace(request.AccessStructure.User_ID, "-", "_", "all") & dateformat(now(), 'mm_dd_mm_ss')>
<cfset UniqueFileName = "AliasManagement_" & UniqueGeneralName & ".csv">

<!---Set file location --->
<cfset pathFileName = application.Doc_Path & "\Temp_Files\Alias\"  & UniqueFileName>

<!--- Upload the file to the web server --->
<CFFILE ACTION = "upload"
		FILEFIELD = "File_Path"
		DESTINATION = "#pathFileName#"
		NAMECONFLICT =	"MakeUnique">

<!---
To upload from developer's machine to stage environment, uncomment below code. 
and comment "CODE FOR STAGE AND PROD" below
--->
<!--- CODE FOR DEVELOPER'S MACHINE --->
<!---
<cfif FindNoCase("C:", pathFileName)>
	<cfset pathforDB  = "\\" & Application.WebServerName & pathFileName>
<cfelseif FindNoCase("E:", pathFileName)>
	<cfset pathforDB  = "\\" & Application.WebServerName & pathFileName>
<cfelseif FindNoCase("D:", pathFileName)>
	<cfset pathforDB  = "\\" & Application.WebServerName & pathFileName>
<cfelse>
	<cfset pathforDB  = "\\" & Application.WebServerName & pathFileName>
</cfif>

<cfset pathforDB = '\\' & Application.WebServerName & '\' & Replace(pathFileName, ':', '$')>
--->

<!--- To upload from a client's environment (stage or prod) , use below code 
Note: If we are uploading from the developer's machine to a stage environment, then below
code may not work and we may need to comment below code and uncomment the code above
--->
<!--- CODE FOR STAGE AND PROD --->
<cfif FindNoCase("C:", pathFileName)>
	<cfset pathforDB  = "\\" & Application.WebServerName & Replace(pathFileName, "C:", "")>
<cfelseif FindNoCase("E:", pathFileName)>
	<cfset pathforDB  = "\\" & Application.WebServerName & Replace(pathFileName, "E:", "")>
<cfelseif FindNoCase("D:", pathFileName)>
	<cfset pathforDB  = "\\" & Application.WebServerName & Replace(pathFileName, "D:", "")>
<cfelse>
	<cfset pathforDB  = "\\" & Application.WebServerName & Replace(pathFileName, "F:", "")>
</cfif>


<!--- Get the db path where the uploaded file will be copied from the web server  --->
<cfset useLakebaseForget_DTS_Reference_Path = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dataint_settings")>
<cfif useLakebaseForget_DTS_Reference_Path>
	<cftry>
		<cfset get_DTS_Reference_Path = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dataint_settings", {
				"order" = "setting_date.desc",
				"limit" = "1",
				"select" = "dts_reference_path"
			}), "dts_reference_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_DTS_Reference_Path = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_DTS_Reference_Path>
<cfquery name="get_DTS_Reference_Path" datasource="#application.datasource#">
SELECT TOP 1 DTS_Reference_Path
FROM DataInt_Settings
ORDER BY Setting_Date DESC
</cfquery>
</cfif>

<!--- We always choose the name '\AliasProducts.csv' for the file.--->
<cfset Complete_File_Path = get_DTS_Reference_Path.DTS_Reference_Path & "\" & UniqueFileName> 

<!--- Copy the file from the web server to the db server --->
<cffile action="copy" source="#pathforDB#" destination="#Complete_File_Path#">

<!--- Finally, call the routine to upload "Aliases" --->
<cfstoredproc procedure="Upload_Alias_Data" datasource="#application.datasource#">
	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@UserID" value = "#request.AccessStructure.User_ID#" null="no" />
	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@EntityType" value = "#form.Entity_Type#" null="no" />
	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@SourceID" value = "#form.Source_ID#" null="no" />
	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@SourceType" value = "#form.Source_Type#" null="no" />
	<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Complete_File_Path" value = "#Complete_File_Path#" null="no" />
</cfstoredproc>

<script>
window.opener.refreshGrid();
window.close();
</script>