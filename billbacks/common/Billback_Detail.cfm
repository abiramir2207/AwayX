<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<CFPARAM NAME="URL.BBID"	DEFAULT="">
<CFSET Billback_ID=URL.BBID>

<CFSET InfoBar_BBID = Billback_ID>
<cfinclude template="/Billbacks/capture/billback_load_infobar.cfm">


<html>
<head>
	<title>Billback Summary</title>
	<cfinclude template="/Billbacks/capture/iframe_style.cfm">
</head>
<!---
<img src=/images/lock3.gif width=25 height=34 border=0 onmouseover=""this.src='/images/lock2.gif'"" onmouseout=""this.src='/images/lock3.gif'"" style=""cursor:pointer;""><BR>UNLOCKED
 --->

<BODY LEFTMARGIN="5" TOPMARGIN="5">

<cfinclude template="/get_access_profile.cfm">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This section handles the Billback Approval								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Display The Appropriate Status --->
<CFSET StatusDisplay_CELLSPACING	= 4>
<CFSET StatusDisplay_CELLPADDING	= 0>
<CFSET StatusDisplay_FONTCOLOR		= "white">
<CFSET StatusDisplay_CELLBGCOLOR	= "green">

<CFSET Program_Is_A_Revision 			= 0>
<CFSET ISPROGRAMTEMPLATEAVAILABLE 		= 1>
<CFSEt DisAllowAccessBasedOnPosition 	= 0>

	<cfquery name="UnLockOtherBillbacksLockedByMe" datasource="#Application.Datasource#">
		UPDATE	Billback_Allied
		SET
			BB_Is_Locked = 0
		WHERE
			BB_Is_Locked			=	1
			AND
			BB_Locked_By_User_ID	= <cfqueryparam value='#request.AccessStructure.User_ID#'>
			<CFIF LEN(trim(Billback_ID)) GT 0 AND Billback_ID NEQ 0>
				AND
				Billback_ID <> <cfqueryparam value='#Billback_ID#'>
			</CFIF>
			AND BB_Locked_By_Match_Central = <cfqueryparam value=0>
	</cfquery>


	<cfquery name="GetLockStatus" datasource="#Application.Datasource#">
		SELECT BB_Is_Locked,BB_Locked_By_User_ID
		FROM
			Billback_Allied
		WHERE
			Billback_ID = <cfqueryparam value='#Billback_ID#'>
	</cfquery>


	<CFIF GetLockStatus.BB_Is_Locked EQ 1>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 0>
	<CFELSE>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 1>
	</CFIF>

	<CFIF GetLockStatus.BB_Locked_By_User_ID NEQ request.AccessStructure.User_ID>
		<CFSET DisAllowAccessBasedOnLockStatus 	= 1>
	</CFIF>
<cfset APVL_Contract_Status = getBillbackInformation.Billback_Status_ID>

<CFSWITCH EXPRESSION="#APVL_Contract_Status#">
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
				if(window.parent.bb_complete_payee == true){
					if(confirm("Press OK To Flag This Billback as Ready For Approval")) {
						document.all.ApprovalForm.submit();
					}
					else {
						document.all.ApproveContractButton.checked = false;
					}
				}
				else{
					alert("Select a payee before flagging this billback as 'Read For Approval'")
				}
			}
		</SCRIPT>
		<!-- </FORM> -->
	</CFCASE>

	<CFCASE VALUE="2">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Ready For Approval">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Revision Ready For Approval">
		</CFIF>
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
		<SCRIPT>
			function confirmApproval() {
				if(confirm("Press OK To Flag This Billback as Paid")) {
					document.all.ApprovalForm.submit();
				}
				else {
					document.all.ApproveContractButton.checked = false;
				}
			}
		</SCRIPT>
	</CFCASE>

	<CFCASE VALUE="3">
		<CFSET StatusDisplay_DisplayText	= "Approved">
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "green">
		<CFSET StatusDisplay_FONTCOLOR		= "white">
	</CFCASE>

	<CFCASE VALUE="4">
		<CFSET StatusDisplay_DisplayText	= "Payment Request">
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>

	<CFCASE VALUE="5">
		<CFSET StatusDisplay_DisplayText	= "Paid">
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>

	<CFCASE VALUE="6">
		<CFSET StatusDisplay_DisplayText	= "Pending Fund Update">
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>

	<CFCASE VALUE="7">
		<CFSET StatusDisplay_DisplayText	= "Pending Vendor ID">
		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>

	<CFCASE VALUE="8">
		<CFSET StatusDisplay_DisplayText	= "Approved - VOID">
		<CFSET StatusDisplay_BGCOLOR		= "red">
		<CFSET StatusDisplay_CELLBGCOLOR	= "green">
		<CFSET StatusDisplay_FONTCOLOR		= "white">
	</CFCASE>


</CFSWITCH>

<CFOUTPUT>
	<TABLE
		BORDER="0"
		CELLSPACING="#StatusDisplay_CELLSPACING#"
		CELLPADDING="#StatusDisplay_CELLPADDING#"
		WIDTH="100%"
		BGCOLOR="#StatusDisplay_BGCOLOR#">
	<TR>
		<TD BGCOLOR="#StatusDisplay_CELLBGCOLOR#" WIDTH="100%"><FONT COLOR="#StatusDisplay_FONTCOLOR#" SIZE="3"><B>#StatusDisplay_DisplayText#</B></FONT>
		</TD>
			<CFIF APVL_Contract_Status EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP>
				&nbsp;&nbsp;&nbsp;
				<FONT COLOR="Black" SIZE="3"><B><!--- Click Here To Flag This Program As  --->Ready For Approval</B></FONT>
				<INPUT TYPE="checkbox" NAME="ApproveContractButton" TITLE="Click Here to Begin Approval Process" VALUE="" onClick="confirmApproval()">
				&nbsp;&nbsp;&nbsp;
			</CFIF>

			<!--- this user has full approval abilities --->
			<CFIF APVL_Contract_Status EQ 2 AND DisAllowAccessBasedOnLockStatus EQ 0 AND Get_Profile_Settings.BB_VIEW_DEVIATION EQ 1>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;" ONCLICK="window.parent.deviations_tab.fireEvent('onclick')">
					&nbsp;&nbsp;&nbsp;
					Click Here to Begin Approval Process
					&nbsp;&nbsp;&nbsp;
				</TD>
			</CFIF>
	</TR>
	</TABLE>
</CFOUTPUT>
<BR>
</blockquote>
<!---
	END STATUS
 --->

<CFSAVECONTENT VARIABLE="Billback_Detail_Content">
	<CFINCLUDE TEMPLATE="Billback_Detail_Content.cfm">
</CFSAVECONTENT>
<CFOUTPUT>#Replace(Billback_Detail_Content, "<TR style=""display:none;""><TD></TD></TR>", "<TR><TD nowrap ID=""cellLabel"">Comments:<BR><span style=""color:red;font-size:10px;"">only visible internally</span></TD><TD valign=""top"">#Get_Billback_Info.Comments#</TD></TR>")#</CFOUTPUT>


<CFSET Print_Button_Show 		= 1>
<CFSET Email_Button_Show 		= 1>
<CFSET Fax_Button_Show 			= 1>
<CFSET Delete_Button_Show		= 0>

<!------------------- BB_Create is reused to Delete tooo -------------------------->
<CFSET Profile_Delete			= Get_Profile_Settings.BB_Create>

<CFIF (NOT DisAllowAccessBasedOnLockStatus) AND (APVL_Contract_Status LTE 2) AND (Profile_Delete EQ 1)>
	<CFSET Delete_Button_Show		= 1>
</CFIF>
<BR>


	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="1%" ALIGN="CENTER">
		<TR>

<CFIF Print_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"NewWindow('../common/BB_Detail_Print.cfm?BBID=#Billback_ID#','name','800','600','Yes', 'No')"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare an email contents"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
</CFIF>

<CFIF Email_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"email"
			button_action	=	"window.location.href='../common/bb_Detail_Email.cfm?BBID=#Billback_ID#'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare email contents"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
</CFIF>
<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
<CFIF Fax_Button_Show EQ 1>
	<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"fax"
			button_action	=	"window.location.href='../common/bb_Detail_Email.cfm?BBID=#Billback_ID#&FAX_EMAIL=FAX'"
			button_type		=	"javascript_link"
			button_width	=	"50"
			button_color	=	"Navy"
			button_tip		=	"Prepare the contents of a fax to be sent"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
</CFIF>
--->

	</TR>
	</TABLE>

	<CFSET Status_Value = getBillbackInformation.Billback_Status_ID>
	<cfswitch expression="#Status_Value#">
		<cfcase value="1"><!--- IS WIP NEXT RFA --->
			<CFSET Status_Value = 2>
		</cfcase>
		<cfcase value="2"><!--- IS WIP NEXT RFA --->
			<CFSET Status_Value = 4>
		</cfcase>
	</CFSWITCH>



<cfset local_bbid = Billback_ID>
<cfinclude template="/Billbacks/capture/bb_menu_stats.cfm">


<cfset bblock.bb_id 				= local_bbid>
<cfset bblock.user_id_bb_locker 	= request.AccessStructure.user_id>
<cfset bblock.relocate_ability 		= "0">
<cfinclude template="/Billbacks/capture/billback_locker.cfm">
<script>
	// BSD D11544
    try { window.parent.dyniframesize(); } catch (err) { };
</script>
</BODY>
</html>
