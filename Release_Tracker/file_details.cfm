<html>
<title>File Details</title>
<head>
<!---
***********************************************************************
Author: Milan Mushran
Filename: file_details.cfm
Purpose: For viewing the history of the changes to a file.
Date Created: 10/20/2006
Modification:
Modified By:
Modified Date:
***********************************************************************
--->
<STYLE TYPE="text/css">
		.header
		{
			font-size: 11px;
			font-weight : bold;
			font-family:verdana;
			background: #FFCC99;
		}	
		TD.Underlined
		{
			border-bottom: 1px solid #7575FF;
		}
		TR.highlight TD.Underlined
		{
			background-color: #EAFFEA;
			border-bottom: 1px solid #7575FF;
			align: right;
		}
		TR.nothighlight TD.Underlined  
		{
			border-bottom: 1px solid #7575FF;
		}
</STYLE>
</head>
<CFQUERY NAME="getInstallationDetails" datasource="#application.datasource#">
SELECT File_Path, LTRIM(RTRIM(Release_Version)) As Release_Version, Patch_Number, CF_Installation, Object_Type,
File_Name, Installed_Date, Name, Label_Number, Version_Number,Application_Installation_Aux_Data.Comments
FROM Application_Installation LEFT OUTER JOIN Application_Installation_Aux_Data
ON Application_Installation.Application_Installation_ID = Application_Installation_Aux_Data.Application_Installation_ID
<cfif Release_Version neq "">
WHERE File_Path = '#URL.File_Path#' 
AND Release_Version = '#URL.Release_Version#'
<cfelse>
AND Application_Installation_ID = '#Application_Installation_ID#'
</cfif>
ORDER BY  Object_Type, File_Path,  CF_Installation, Installed_Date DESC
</CFQUERY>
<body>
<br />
<table border="0" cellpadding="4" cellspacing="0">
	<tr>
		<td class="header">File Name</td>
		<td class="header">Name</td>
		<td class="header">Date</td>
		<td class="header">Patch</td>
		<td class="header">Label</td>
	</tr>
	<cfoutput query="getInstallationDetails">
	<tr onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<td CLASS="Underlined">#File_Name#</td>
		<td CLASS="Underlined">#Name#</td>
		<td CLASS="Underlined">#DateFormat(Installed_Date, "m/dd/yyyy")# #TimeFormat(Installed_Date, "h:mm:ss tt")#</td>
		<td CLASS="Underlined">#Patch_Number#</td>
		<td CLASS="Underlined">#Label_Number#</td>
	</tr>
	<tr>
		<td colspan="100%"><b>Comments</b>: <cfif Comments neq "">#Comments#<cfelse>NONE</cfif></td>
	</tr>
	</cfoutput>
</table>
</body>
</html>