<!---
Name: 			auto_pay_revise_message.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	02/11/2008
Created By:		Tim Ford 
Description:	This file is a pop up window used to alert the user that they are revising a program retroactively with auto pay components in the parent.  
--->
<cfsetting showdebugoutput="no">
<cfset PAGE_TITLE = "Auto Pay Retroactive Revision Message">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<head>
<title><cfoutput>#PAGE_TITLE#</cfoutput></title>
</head>
<body>

<table cellpadding="4" cellspacing="0" border="0">
	<tr>
		<td align="center">
			<span style="font-weight:bold;color:red;font-size:15pt">!!! IMPORTANT</span>
		</td>
	</tr>
	<tr>
		<td colspan="100%">
			<span style="font-weight:bold;font-size:10pt">
				The start date you have defined precedes today’s date, indicating that the revisions you are proposing will take effective retroactively.  This program contains components that are set to Auto Pay on a scheduled basis.  Please note that, if you remove an auto pay component, individual products within an Auto Pay component, or the customer[s] who previously had been identified to receive payment, the system will not adjust future payments to account for the dollars already disbursed against the previous version.
			</span>
		</td>
	</tr>
	<tr>
		<td align="center">
			<CF_smallLink 
				title = "ok" 
				url = "##"
				parameters = "onClick=""javascript: return window.close();"""
			>
		</td>
	</tr>
</table>
</body>
</html>