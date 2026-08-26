<!---
Document Name:	index.cfm
Directory:		settings/personalization
Author:			Brenda Flynn
Contact:		bflynn@bigredflame.com
Date Created:	February 20, 2004

This is a page which allows users to set their preferences for certain areas of the application. Almost all the information is saved in the table _users_personalization.

--->

<cfparam name="RecordsToShow" default="25">
<cfparam name="LastUpdated" default="Never">

<cfquery name="GetPriorValues" datasource="#application.datasource#">
SELECT * FROM _User_Preferences
WHERE User_ID = '#request.AccessStructure.User_ID#'
</cfquery>

<!---Sets values to be record values if there is a record returned--->
<cfif GetPriorValues.Recordcount GT 0>
	<cfset LastUpdated = dateformat(GetPriorValues.Last_Updated, 'MM/DD/YYYY') & " " & timeformat(GetPriorValues.Last_Updated)>
	<cfset RecordsToShow = GetPriorValues.Records_To_Show>
</cfif>

<html>
<head>
	<title>Blacksmith Apps Personalization</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</head>

<body>
<cfoutput>
<table width="99%" cellpadding="0" cellspacing="0" border="0">
<form action="index_action.cfm" name="MyForm" method="post">
<!---Top display--->
<tr>
	<td><img src="/images/control_panel/password_closed.gif"></td>
	<td rowspan="100%" bgcolor="navy"><img src="/images/clear.gif"></td>
	<td><span class="pageheading">&nbsp; &nbsp; Personal Settings for #request.AccessStructure.name_first# #request.AccessStructure.name_last#</span>
<br>&nbsp; &nbsp;  Last Updated:  #LastUpdated#</td>
</tr>

<!---Blue border--->
<tr>
	<td style="border-top:solid navy 3px;">&nbsp; </td>
	<td style="border-top:solid navy 3px;">&nbsp; </td>
</tr>

<!---Records to display--->

<tr>
	<td align="right"><strong>Records to Display</strong>&nbsp; </td>
	<td><span class="error_RecordsToShow">&nbsp; </span><input type="text" maxlength="2" size="5" name="RecordsToShow" value="#RecordsToShow#" onKeyUp="clenseText(this, '0123456789');" ></td>
</tr>


<!---submit--->

<tr>
	<td align="right">&nbsp; </td>
	<td>&nbsp; <CF_button
			button_name		=	""
			button_caption	=	"save"
			button_action	=	"confirmCompletion();"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Save preferences"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>	</td>
</tr>

</table>
</form>
</cfoutput>
</body>
</html>

<!---Javascripts--->

<SCRIPT language="JavaScript" src="/Common_Files/scripts/numberValidation.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/Common_Files/scripts/requiredFields.js"></SCRIPT>	
<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/Common_Files/scripts/formattotwodecimals.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/validateFormUtils.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/date_functions.js"></SCRIPT>
<CF_MessageWindow>

<script>
function confirmCompletion(){
	
	ErrorCount = 0
	
	<!--- Amount --->
		if(document.all.RecordsToShow.value.length == 0)	{
			ErrorCount++;
			queueMessage("You must enter a number of records to display.", document.all.error_ReimbursementAmount);
		}
		else if(document.all.RecordsToShow.value == 0)
		{
			ErrorCount++;
			queueMessage("You must select to display at least one record.", document.all.error_ReimbursementAmount);
		}
		else
		{
			clearQueue(document.all.error_RecordsToShow);
		}

		

			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0) {
				MyForm.submit()
			}
			else {
				showMessageWindow()
			}	

		}
</script>

