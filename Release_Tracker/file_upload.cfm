<!---
***********************************************************************
Author: Milan Mushran
Filename: file_upload.cfm
Purpose: To upload patches (To be used by QA and our clients who host on their own)
Date Created: 10/04/2006
Modification:Error message in cf, not js
Modified By:Milan Mushran
Modified Date:10/20/2006
Modification:
Modified By:
Modified Date:
***********************************************************************
--->
<html>
<head>
<title>Patch Deployment System</title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />

<body>

<cfparam name="url.error" default="">
<cfparam name="PageTitle" default="">

<!--- Displays the page title set in the URL --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!--- Show error message --->
	<cfif url.error eq  "filetype">
		<cfset message = "Please upload a zip file only.">
	<cfelseif url.error eq  "nodata">
		<cfset message = "First execute the SQL file which comes with the patch.">
	<cfelseif url.error eq  "success">
		<cfset message = "The content of the zip file has been successfully uploaded.">
	</cfif>

<cfif url.error neq "">
<table border="0" cellpadding="0" cellspacing="0" align="center">
	<tr>
		<td><span style="color:red;font-style:bold;font-size:14;"><cfoutput>#Ucase(Message)#</cfoutput></span></td>
	</tr>
</table>
</cfif>
	
<cfset general_functions = CreateObject("component", "components.general.general_functions")>
<!--- Get the path to the 'Awayx' folder --->
<cfset rootpath = general_functions.Get_Application_Path()>
<cfset rootpath = rootpath & "\">

<!---  Get the folder one level above the 'Awayx' folder (This is not needed now) --->
<!---<cfset rootpath = Left(rootpath, Len(rootpath) - Find("\", reverse(rootpath))+1)>--->

<form name="frmFileUpload" action="file_upload_action.cfm" method="post" enctype="multipart/form-data" onSubmit="if(document.all.FileName.value==''){alert('Please choose a file.');return false;}">
<table cellspacing="1" align="center">
	<tr>
		<td><b>Select a Zip File:</b>&nbsp;<input type="file" name="FileName">
			<input type="submit" name="butSubmit" value="Upload"  onClick="window.document.frmFileUpload.UploadFrom.value=document.all.FileName.value">
		</td>	
			<input type="hidden" name="UploadFrom">
			<cfoutput>
			<input type="hidden" name="FileSavePath" value="#rootpath#">
			</cfoutput>
 </tr>
</table>
</form>

</body>
</html>
