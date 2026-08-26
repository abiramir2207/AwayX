<!---
/deductions/search_screens/adjustment_exclusion_details.cfm
Brenda Flynn
October 9, 2003, 2003

--->

<!---Sends them home if they're not allowed to use this --->

<!--------------------------------------------------------
Start Search Form
--------------------------------------------------------->

<STYLE>
	SELECT,INPUT
	{
		font-size : 10px;
	}
	SELECT
	{
		font-size : 10px;
		WIDTH:200px;
	}
</STYLE>


<CFSET PAGE_TITLE="Exclusions and Adjustments Details">
<CFSET GROUP="Deployment">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!---Spinner--->
<CFIF Not Isdefined("URL.dontshowwait")>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>

<SCRIPT LANGUAGE="JavaScript">

function hide_PleaseWaitMessage()
{ 
 document.all.PleaseWaitMessage.style.display='none';
}
hide_PleaseWaitMessage();


</SCRIPT>
</CFIF>
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

<cfquery name="Details" datasource="#application.datasource#">
<cfif Type IS 1>
<!---It's an adjustment--->

	SELECT BB_Adjustment.Date_Applied, BB_Adjustment.Adjustment_Amount AS Amount, Billback.Billback_ID, D_Billback.Billback_ID AS Applied_To_BB_ID, Billback.BB_Title AS Original_Billback, D_Billback.BB_Title AS Applied_To_Billback, Billback.BB_Date AS Original_Billback_Date, D_Billback.BB_Date AS Applied_To_Billback_Date, Billback.BB_Reference AS Original_Billback_Reference, D_Billback.BB_Reference AS Applied_To_Billback_Reference, Billback.BB_Code AS Original_BB_Code, D_Billback.BB_Code AS Applied_To_BB_Code, _users.Name_First AS Original_BB_Name_First, _users.Name_Last AS Original_BB_Name_Last, D_Users.Name_First AS Applied_To_Name_First, D_Users.Name_Last AS Applied_To_Name_Last
	FROM BB_Adjustment 
		INNER JOIN Billback
		ON Billback.Billback_ID = BB_Adjustment.Billback_ID
		INNER JOIN Billback D_Billback
		ON D_Billback.Billback_ID = BB_Adjustment.Adjustment_Deducted_From_BB_ID
		INNER JOIN BB_Approved
		ON BB_Approved.Billback_ID = Billback.Billback_ID
		INNER JOIN _users
		ON _users.User_ID = BB_Approved.User_Approved
		LEFT JOIN BB_Approved D_BB_Approved
		ON D_BB_Approved.Billback_ID = D_Billback.Billback_ID
		LEFT JOIN _users D_Users
		ON D_Users.User_ID = D_BB_Approved.User_Approved
	WHERE 	BB_Adjustment.BB_Adjustment_ID = '#ID#' 
<cfelse>
<!---It's an exclusion--->
	SELECT BB_Program_Exclusion.Date_Applied, (SELECT SUM(BB_Product_Exclusion.Dollar_Amount) from BB_Product_Exclusion WHERE BB_Program_Exclusion.BB_Program_Exclusion_ID = BB_Product_Exclusion.BB_Program_Exclusion_ID AND BB_Program_Exclusion.BB_Program_Exclusion_ID = '#ID#') AS Amount, Billback.Billback_ID, D_Billback.Billback_ID AS Applied_To_BB_ID, Billback.BB_Title AS Original_Billback, D_Billback.BB_Title AS Applied_To_Billback, Billback.BB_Date AS Original_Billback_Date, D_Billback.BB_Date AS Applied_To_Billback_Date, Billback.BB_Reference AS Original_Billback_Reference, D_Billback.BB_Reference AS Applied_To_Billback_Reference, Billback.BB_Code AS Original_BB_Code, D_Billback.BB_Code AS Applied_To_BB_Code, _users.Name_First AS Original_BB_Name_First, _users.Name_Last AS Original_BB_Name_Last, D_Users.Name_First AS Applied_To_Name_First, D_Users.Name_Last AS Applied_To_Name_Last 
		FROM BB_Program_Exclusion
	<!--- 	INNER JOIN BB_Product_Exclusion 
		ON BB_Program_Exclusion.BB_Program_Exclusion_ID = BB_Product_Exclusion.BB_Program_Exclusion_ID --->
		INNER JOIN Billback
		ON Billback.Billback_ID = BB_Program_Exclusion.Billback_ID
		INNER JOIN Billback D_Billback
		ON D_Billback.Billback_ID = BB_Program_Exclusion.Exclusion_Deducted_From_BB_ID
		INNER JOIN BB_Approved
		ON BB_Approved.Billback_ID = Billback.Billback_ID
		INNER JOIN _users
		ON _users.User_ID = BB_Approved.User_Approved
		LEFT JOIN BB_Approved D_BB_Approved
		ON D_BB_Approved.Billback_ID = D_Billback.Billback_ID
		LEFT JOIN _users D_Users
		ON D_Users.User_ID = D_BB_Approved.User_Approved
	WHERE BB_Program_Exclusion.BB_Program_Exclusion_ID = '#ID#'


</cfif>
</cfquery>
<!--- <cfdump var="#Details#"> --->

<cfif Type IS 1>
	<Cfset TypeName = "Adjustment">
<cfelse>
	<cfset TypeName = "Exclusion">
</cfif>
<p></p>

<cfoutput query="Details">
<div align="center">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr><td colspan="4" align="center"><strong><font size="+1">#TypeName# for #LSCurrencyFormat(Amount)#</font></strong></td></tr>
<tr><td colspan="4">&nbsp; </td></tr>
	<tr><td colspan="4" bgcolor="lightsteelblue"><strong>Billback that created the #TypeName#:</strong></td></tr>

	<tr><td>Billback Title:</td><td bgcolor="orange" width="1" rowspan="100%"><td rowspan="100%">&nbsp;&nbsp;  </td><img src="/Images/fill.gif" width="1" height="1" alt="" border="0"></td><td>#Original_Billback#</td><td rowspan="100%">&nbsp;&nbsp; &nbsp;  </td></tr>
	<tr><td>Billback Number:</td><td>#Original_BB_Code#</td></tr>
	<tr><td>Billback Reference:</td><td>#Original_Billback_Reference#</td></tr>
	<tr><td>Approved:</td><td>#DateFormat(Original_Billback_Date, 'MMM DD, YYYY')#</td></tr>
	<tr><td>Approver:</td><td>#Original_BB_Name_First# #Original_BB_Name_Last#</td></tr>
	<cfquery name="ProgramsforOriginalBillback" datasource="#application.datasource#">
	SELECT Contract_Main.Contract_Title, Contract_Main.Contract_Number
	FROM Billback_Program
		INNER JOIN Contract_Main
		ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
	WHERE Billback_Program.Billback_ID = '#Billback_ID#'
	</cfquery>
	<tr><td valign="top">Programs in Billback:</td>
	<td>
<cfloop query="ProgramsforOriginalBillback">
	#Contract_Number# - #Contract_Title#<br>
</cfloop>	</td></tr>
	<tr><td colspan="4">&nbsp;&nbsp;  </td></tr>
	<tr><td colspan="4" bgcolor="lightsteelblue"><strong>Billback that had the #TypeName# applied to its payment:</strong></td></tr>
	<tr><td>Billback Title:</td><td>#Applied_To_Billback#</td></tr>
	<tr><td>Billback Number:</td><td>#Applied_To_BB_Code#</td></tr>
	<tr><td>Billback Reference:</td><td>#Applied_To_Billback_Reference#</td></tr>
	<tr><td>Approved:</td><td>#DateFormat(Applied_To_Billback_Date, 'MMM DD, YYYY')#</td></tr>
	<tr><td>Approver:</td><td>#Applied_To_Name_First# #Applied_To_Name_Last#</td></tr>
	<cfquery name="ProgramsforAppliedToBillback" datasource="#application.datasource#">
	SELECT Contract_Main.Contract_Title, Contract_Main.Contract_Number
	FROM Billback_Program
		INNER JOIN Contract_Main
		ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
	WHERE Billback_Program.Billback_ID = '#Applied_To_BB_ID#'
	</cfquery>
	<tr><td valign="top">Programs in Billback:</td>
	<td>
<cfloop query="ProgramsforAppliedToBillback">
	#Contract_Number# - #Contract_Title#<br>
</cfloop>	</td></tr>
	</table>
</div>
</cfoutput>


</BODY>
</HTML>