<!---
Created By: Brenda Flynn
			bflynn@bigredflame.com
Created On:	June 8, 2004

Edited By:
Edited On:
Edited To:

Allows the user to identify program/distributor combinations for which they would like to recieve automated monthly emails
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<CFSET PAGE_TITLE="Auto Checkbook">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
<script>
function DeleteEntry(EntryToBeDeleted)
{	
  confirm("Are you sure you want to delete this entry?")
  {
  	var newLocation = "/billbacks/ledger/auto_checkbook/delete.cfm?Auto_Checkbook_ID=" + EntryToBeDeleted;
  	location.href=newLocation;
  }
}

</script>	
	
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- Header include --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<cfoutput>
<blockquote>
<table width="90%" cellpadding="0" cellspacing="2" border="0">
<tr><td colspan="100%"><font color="navy" size="2"><strong>Auto Checkbook</strong></font></td></tr>
<tr><td colspan="100%"><hr color="orange"></td></tr>
<tr><td colspan="100%" align="right">

<CF_smallLink 
	title = "add auto checkbook entry" 
	url = "/billbacks/ledger/auto_checkbook/add_edit.cfm"
	parameters = ""
></td></tr>
<!---Select scheduled auto checkbook entries for user--->

</table>
<!---Display active entries--->
<cfquery name="ActiveEntries" datasource="#application.datasource#">
SELECT Auto_Checkbook.Auto_Checkbook_ID, Auto_Checkbook.Send_To, Contract_Main.Contract_Number, Contract_Main.Contract_Title, BSA_Foodservice_Customers.Name
FROM Auto_Checkbook
	INNER JOIN Contract_Main
	ON Contract_Main.Contract_Main_ID = Auto_Checkbook.Program_ID
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Auto_Checkbook.Distributor_ID
WHERE User_ID = '#request.AccessStructure.User_ID#'
AND Auto_Checkbook.Deleted = 0
ORDER BY Auto_Checkbook.Created_Date DESC 
</cfquery>
<table cellpadding="2" cellspacing="0" border="0">
<tr><td><font color="navy" size="2">Active</font></td></tr>
</table>
<table cellpadding="2" cellspacing="0" border="0" style="maintable">
<tr>
	<td bgcolor="orange" width="130"><strong>Program Number</strong></td>
	<td bgcolor="orange" width="200"><strong>Program Title</strong></td>
	<td bgcolor="orange" width="150"><strong>#application.returned_customer_setting.distributor_label_singular#</strong></td>
	<td bgcolor="orange" width="200"><strong>Send To</strong></td>
	<Td bgcolor="orange" width="120">&nbsp; </TD>
	
</tr>
<cfloop query="ActiveEntries">
<tr <CFIF currentrow mod 2>BGCOLOR="ccffcc"<CFELSE>BGCOLOR="white"</CFIF>>
	<td>#trim(Contract_Number)#</td>
	<td>#trim(Contract_Title)#</td>
	<td>#trim(Name)#</td>
	<td>#trim(Send_To)#</td>
	<td align="right">
	<!--- <CF_smallLink 
	title = "edit" 
	url = "/billbacks/ledger/auto_checkbook/add_edit.cfm?Auto_Checkbook_ID=#Auto_Checkbook_ID#"
	parameters = ""
	>&nbsp; &nbsp;  --->
	<CF_smallLink 
	title = "delete" 
	url = "##"
	parameters = "onClick=""javascript: DeleteEntry(#Auto_Checkbook_ID#);"""
	>&nbsp; &nbsp; 
</td>
</tr>
</cfloop>
</table>
<p></p>
<!---Display inactive/deleted entries--->
<cfquery name="InActiveEntries" datasource="#application.datasource#">
SELECT Auto_Checkbook.Send_To, Contract_Main.Contract_Number, Contract_Main.Contract_Title, BSA_Foodservice_Customers.Name
FROM Auto_Checkbook
	INNER JOIN Contract_Main
	ON Contract_Main.Contract_Main_ID = Auto_Checkbook.Program_ID
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Auto_Checkbook.Distributor_ID
WHERE User_ID = '#request.AccessStructure.User_ID#'
AND Auto_Checkbook.Deleted = 1
ORDER BY Auto_Checkbook.Created_Date DESC 
</cfquery>
<table cellpadding="0" cellspacing="2" border="0" >
<tr><td><font color="navy" size="2">InActive</font></td></tr>
</table>
<table cellpadding="2" cellspacing="0" border="0" style="maintable">
<tr>
	<td bgcolor="orange" width="130"><strong>Program Number</strong></td>
	<td bgcolor="orange" width="200"><strong>Program Title</strong></td>
	<td bgcolor="orange" width="150"><strong>#application.returned_customer_setting.distributor_label_singular#</strong></td>
	<td bgcolor="orange" width="200"><strong>Send To</strong></td>
	<Td width="120"  bgcolor="orange">&nbsp; </TD>
</tr>
<cfloop query="InActiveEntries">
<tr>
	<td bgcolor="##CCCCCC">#Contract_Number#</td>
	<td bgcolor="##CCCCCC">#Contract_Title#</td>
	<td bgcolor="##CCCCCC">#Name#</td>
	<td bgcolor="##CCCCCC">#Send_To#</td>
	<td bgcolor="##CCCCCC">&nbsp; </td>
</tr>
</cfloop>
</table>
</cfoutput>
</blockquote>
<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>