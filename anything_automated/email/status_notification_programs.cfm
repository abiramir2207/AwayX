<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Status Notification</title><style>
	.tableheaders {
		font-size:13px;
		font-weight:bold;
		border-bottom:thin #FFFFFF 0px; 
			
	}	
	BODY, TD, .normal
	{
		font-family : Arial;
		font-size : 8pt;
		color : Black;
	}
	
	
	TABLE.Maintable TD 
	{
		border-bottom:solid #93BEE2 1px; font-size : 11px; border-right:solid #93BEE2 1px;}

		
	}
	#header {font-size: 13px; color: black; font-weight:bold;}
	
	.normal
	{
		font-family : Arial;
		font-size : 8pt;
		color : Black;
	}	
	#nostyle
	{
	border-right:none;
	}
</style>
<style type="text/css" media="screen">
<!--
.printDiv { overflow: auto;}
.thead2 { display: none } 
-->
</style>
<style type="text/css" media="print">
<!--
.printDiv { overflow: visible;}
.Maintable { width:650;}
thead { display: table-header-group } 
.thead1 { display: none } 

-->
</style>

</head>

<body>
<table class="Maintable" BORDER="0" CELLPADDING="1" CELLSPACING="0" width="800">
<thead class="thead1">
<TR bgColor="ffce84">
    <TD id=nostyle colSpan=4><B>Weekly Status Notification</B></TD>
    <TD id=nostyle colSpan=2><B>Report Run Date:</B> <B><cfoutput>#Dateformat(now(),"mm/dd/yyyy")#</cfoutput></B></TD></TR>
  <TR>
 <tr bgColor="ffce84">
<td ID="header" align="center" width="80">Program Number</td>
<td ID="header" align="center" width="250">Program Title</td>
<td ID="header" align="center" width="70">Start Date</td>
<td ID="header" align="center" width="70">End Date</td>
<td ID="header" align="center" width="100">Status</td>
<td ID="header" align="center" width="80">Status Changed Date</td>
</TR></THEAD>
</table>
<span class="printDiv" style="height:500px;width:820;" >
<table class="Maintable" BORDER="0" CELLPADDING="1" CELLSPACING="0" width="800">
<thead class="thead2">
 <tr bgColor="ffce84">
<td ID="header" align="center" width="80">Program Number</td>
<td ID="header" align="center" width="250">Program Title</td>
<td ID="header" align="center" width="70">Start Date</td>
<td ID="header" align="center" width="70">End Date</td>
<td ID="header" align="center" width="100">Status</td>
<td ID="header" align="center" width="80">Status Changed Date</td>
</TR></THEAD>
<tr>
 <td colspan="8">
<!---  <table class="Maintable" BORDER="0" CELLPADDING="1" CELLSPACING="0"> --->
<cfoutput query="getAllPrograms" group="Region_Name">
	<tr BGCOLOR="ddddd">
	<td colspan="6">
		<b><cfif Region_Name EQ "">
		Region : No Region
		<cfelse>
		Region : #Region_Name#
		</cfif></b>
	</td>
	</tr>
<cfoutput group="market_name">
	<tr BGCOLOR="b8b8b8">
	<td colspan="6">
		<b><cfif market_name EQ "">
		Market: No Market
		<cfelse>
		Market : #market_name#
		</cfif></b>
	</td>
	</tr>	
<cfset rowcount = 0>
<cfoutput group="contract_number">
<!--- <tr BGCOLOR="99FF66"> --->
<TR <CFIF rowcount mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
<td valign="top" width="80"><strong>#Contract_Number#</strong></td>
<td valign="top" width="250">#contract_title#</td>
<td valign="top" width="70" align="center">#Dateformat(contract_start_date,"mm/dd/yyyy")#</td>
<td valign="top" width="70" align="center">#Dateformat(contract_end_date,"mm/dd/yyyy")#</td>
<td width="100" valign="top">
<cfoutput>
#Contract_Status_Type_Desc# <cfif Is_A_Revision EQ 1>(Revision)</cfif><br></cfoutput>
</td>
<td width="80" valign="top" align="center">
<cfoutput>
#Dateformat(status_changed_date,"mm/dd/yyyy")#<br>
</cfoutput>
</td>

</tr>
<cfset rowcount = rowcount + 1>
</cfoutput>
</cfoutput>
</cfoutput>
<!--- </table> --->
</td>
 </tr>

</TABLE> </span>


</body>
</html>
