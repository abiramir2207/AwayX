<CFSET PAGE_TITLE="Program Summary">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Create_Export_Agreements EQ 0 AND Get_Profile_Settings.Create_Approve_Export_Agreements EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>

<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
<CFSET URL.Export_Sales_Agreement_ID = cryp.value>
<CFSET EncrypContractId = URL.CID>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="-100"> 
<cfset Cache_Control_Header_Already_Added = 1>
<CFINCLUDE template="/includes/call_please_wait.cfm">

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
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET CSL_Contract_Main_ID = cryp.value>

<cfset Agreement_Manager = CreateObject("component","components.Export.Sales_Agreement") />

<cfset CSL_CallingPageCode ="ViewSalesAgreement">
<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 5; left : 10px; top: 0px">
 	<CFINCLUDE TEMPLATE="sales_agreement_status_legend.cfm"></div>
<cfelse>
	<CFINCLUDE TEMPLATE="sales_agreement_status_legend.cfm">
</cfif>

<cfset Export_Sales_Agreement_ID = CSL_Export_Sales_Agreement_ID>
<cfif isdefined("Var")><cfset var1 =  Var></cfif>
<cfif Not isDefined("var1")>
	<cfsavecontent variable = "var1">
		<CFINCLUDE TEMPLATE="Sales_Agreement_thin_general_display.cfm">
	</cfsavecontent>
</cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This section handles the contract Approval								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->	

<!--- Display The Appropriate Status --->
<CFSET StatusDisplay_CELLSPACING	= 4>
<CFSET StatusDisplay_CELLPADDING	= 0>
<CFSET StatusDisplay_FONTCOLOR		= "white">
<CFSET StatusDisplay_CELLBGCOLOR	= "green">

<cfset Agreement_Status = CSLGetContractInfo.Contract_Status_Type_IDX>

<!--- Get the profile information of the program creator and the current user --->
<cfset Creator_Profile_ID = Agreement_Manager.getProfile(CSLGetContractInfo.Creator_ID).Profiles_ID>
<cfset Creator_Profile_Desc = Agreement_Manager.getProfile(CSLGetContractInfo.Creator_ID).Profiles_Desc>
<cfset Current_User_Profile_ID = Agreement_Manager.getProfile('#request.AccessStructure.User_ID#').Profiles_ID>
<cfset Current_User_Profile_Desc = Agreement_Manager.getProfile('#request.AccessStructure.User_ID#').Profiles_Desc>

<!--- Form with the data needed to pre - approve the contract --->
<FORM ACTION="Sales_Agreement_Approval.cfm" METHOD="post" name="RFA_FORM">
	<INPUT TYPE="hidden" NAME="CID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="Status_ID" VALUE="2">
</FORM>

<!--- Form with the data needed to approve the contract --->
<FORM ACTION="Sales_Agreement_Approval.cfm" METHOD="post" name="Approval_FORM">
	<INPUT TYPE="hidden" NAME="CID" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
	<INPUT TYPE="hidden" NAME="Status_ID" VALUE="3">
</FORM>

<!--- Show the appropriate information for the current status --->
<cfoutput>
<CFSWITCH EXPRESSION="#Agreement_Status#">
	<CFCASE VALUE="1">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Work In Progress"> 
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Revision In Progress"> 
		</CFIF>
		
		<CFSET StatusDisplay_BGCOLOR		= "gray">
		<CFSET StatusDisplay_CELLBGCOLOR	= "gray">

		<SCRIPT>
			function confirmApproval() {
				if (confirm("Are you sure you want this agreement to be ready for approval?") == 1)
				{
					document.RFA_FORM.submit();
				}
			}
		</SCRIPT>
	</CFCASE>

	<CFCASE VALUE="2">
		<CFIF  Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Ready For Approval">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Revision Ready For Approval">
		</CFIF>
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
		<SCRIPT>
			function confirmApproval() {
				if (confirm("Are you sure you want approve this agreement?") == 1)
				{
					document.Approval_FORM.submit();
				}
			}
		</SCRIPT>
	</CFCASE>

	<CFCASE VALUE="4">
		<CFSET StatusDisplay_DisplayText	= "Pre Active">
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
	</CFCASE>

	
	<CFCASE VALUE="5">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText = "Active">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText = "Active Revision">
		</CFIF>
		
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>

	<CFCASE VALUE="6">
		<CFSET DayCount = datediff('d', dateformat(now(), 'm/d/yyy'), dateformat(selExportSalesAgreement.Export_End_Date, 'm/d/yyy'))>
		<CFSET Temp = " Day">
		<cfif DayCount GT 1><CFSET Temp = " Days"></cfif>

		<CFIF DayCount EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Will Expire Today">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Expires In " & DayCount & Temp>
		</CFIF>
		
		
		<CFSET StatusDisplay_BGCOLOR		= "Red">
		<CFSET StatusDisplay_CELLBGCOLOR	= "Red">
	</CFCASE>			
	
	<CFCASE VALUE="7">
		<CFSET StatusDisplay_DisplayText	= "Expired">
		<CFSET StatusDisplay_BGCOLOR		= "black">
		<CFSET StatusDisplay_CELLBGCOLOR	= "black">
	</CFCASE>		
</CFSWITCH>

	<TABLE
		BORDER="0"
		CELLSPACING="#StatusDisplay_CELLSPACING#"
		CELLPADDING="#StatusDisplay_CELLPADDING#"
		WIDTH="700"
		BGCOLOR="#StatusDisplay_BGCOLOR#"
		ALIGN ="CENTER">
	<TR>
		<TD BGCOLOR="#StatusDisplay_CELLBGCOLOR#" WIDTH="100%">
			<FONT COLOR="#StatusDisplay_FONTCOLOR#" SIZE="3"><B>#StatusDisplay_DisplayText#</B></FONT>
		</TD>

		<CFIF Agreement_Status EQ 1>
			<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP>
				&nbsp;&nbsp;&nbsp;
				<FONT COLOR="Black" SIZE="3"><B>Ready For Approval</B></FONT>
				<INPUT TYPE="checkbox" NAME="ApproveContractButton" TITLE="Click Here to Pre-Approve This Program" VALUE="#URL.CID#" onClick="confirmApproval()">
				&nbsp;&nbsp;&nbsp;
				</TD>
			</CFIF>
				<!--- Programs created by "Export Sales" have to be approved by "Export Services" and vice-versa. "Export Headquarters" has the authority to create and approve their own programs,
							as well as approve any other program --->
				<CFIF Agreement_Status EQ 2 AND ((Get_Profile_Settings.Approve_Export_Agreements AND Current_User_Profile_ID NEQ Creator_Profile_ID) OR (Get_Profile_Settings.Create_Approve_Export_Agreements))>
						<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: hand;" ONCLICK="confirmApproval()">
							&nbsp;&nbsp;&nbsp;
							Click Here to Approve This Program
							&nbsp;&nbsp;&nbsp;
						</TD>
				</CFIF>
			</TR>
	</TABLE>
		
<table BORDER="0" align="RIGHT" WIDTH="910">
	<TR>
		<TD>
			#var1#
		</TD>
	</TR>
</table>

	</cfoutput>

</BODY>
</HTML>
