<CFSET PAGE_TITLE=	"Settings Control Panel">
<CFSET GROUP=		"Control_Panel">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>



<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>
		<TD VALIGN="top">
			<IMG SRC="/images/icon_settings_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		<TD VALIGN="top">
			<DIV CLASS="title2">How to modify your settings:</DIV>

<table border="0" cellspacing="0" cellpadding="5">
  <tr>
    <td valign="top">
      <p align="right" style="margin-right: 0; margin-bottom: 4"><FONT color="#008000"><B>Password:</B></FONT></td>
    <td valign="top">
      <p align="left" style="margin-bottom: 4">Choose a password that is at least 8 characters long. It may contain numbers (0-9) and letters in upper and lower case (A-Z or a-z), but we don't recommend the use of spaces or other symbols. Make sure it is difficult for others to guess!&nbsp;</td>
  </tr>
  <tr>
    <td valign="top">
      <p align="right" style="margin-right: 0; margin-bottom: 4"><FONT color="#008000"><B>Expiration
      Alerts:</B></FONT></td>
    <td valign="top">You have the ability to receive
      alerts via e-mail informing you of the contracts that are about to expire within a window that you
      select.&nbsp; You can elect to receive an alert when any contract will
      expire within 30, 45, 60 and/or 90 days.&nbsp; Additionally, you can
      establish a standard message and recipients to send the message to.&nbsp; If you need to send alerts to more than one address, enter them separated with a comma (,). How the text wraps within the text box, is purely cosmetic.&nbsp;</td>
  </tr>
  <tr>
    <td valign="top">
      <p align="right" style="margin-right: 0; margin-bottom: 4"><FONT color="#008000"><B>e-Mail:</B></FONT></td>
    <td valign="top">You have the ability to send copies of your contracts via
      e-mail and create a custom message that will informing the recipients of the contents of your email.&nbsp;
      Note that you should use a string of (#xxxxxx) to indicate contract
      numbers (note that the "xxxxxxx" string will be replaced by the Contract
      Number automatically by the system).</td>
  </tr>
  <tr>
    <td valign="top">
      <p align="right" style="margin-right: 0; margin-bottom: 4"><FONT color="#008000"><B>Expected
      Rates:</B></FONT></td>
    <td valign="top">To
      audit the rates any given <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> is charging for net price contracts,
      this area captures the assumptions you give the system regarding which
      inbound price to apply for delivered and FOB rates, the duration to apply
      to calculation, the date to begin calculating, and the range of tolerance
      expressed as a % +/- when compared to the e-Rate.</td>
  </tr>
  <tr>
    <td valign="top">
      <p align="right" style="margin-right: 0; margin-bottom: 4"><FONT color="#008000"><B>Expected
      volumes:</B></FONT></td>
    <td valign="top">To
      audit the volumes any given <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput> is claiming via billbacks, this
      area captures the assumptions you give the system regarding which how far
      back in time their purchases and billback volumes should be aggregated for
      comparison.&nbsp; Additionally, your settings determine whether or not to
      &quot;match&quot; the two aggregation periods and establishes the range of
      tolerance expressed as a % +/- when compared to the e-Volume.&nbsp;</td>
  </tr>
</table>

			
			
		</TD>
	</TR>
</TABLE>




<CENTER>
	<CF_button
		button_name		=	""
		button_caption	=	"new control panel interface"
		button_action	=	"index2.cfm"
		button_type		=	"link"
		button_width	=	"250"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">
</CENTER>



<!--- 
<TABLE ALIGN="center">
<TR>
	<TD>
<!--- 
	<CF_button
		button_name		=	""
		button_caption	=	"modify settings"
		button_action	=	"control_panel.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">
 --->
	</TD>
	<TD>
	<CF_button
		button_name		=	""
		button_caption	=	"modify access rights"
		button_action	=	"access_rights/index.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">
	</TD>
	<TD>
	<CF_button
		button_name		=	""
		button_caption	=	"modify user settings"
		button_action	=	"control_panel_user.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">
	</TD>
	<TD>
	<CF_button
		button_name		=	""
		button_caption	=	"modify payables settings"
		button_action	=	"control_panel_payables.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">
	</TD>
	<TD>
	<CF_button
		button_name		=	""
		button_caption	=	"modify program settings"
		button_action	=	"control_panel_program.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">
	</TD>
</TR>

<!---
<TR>
	<TD>
	<CF_button
		button_name		=	""
		button_caption	=	"modify deduction settings"
		button_action	=	"control_panel_deductions.cfm"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">
	</TD>
</TR> --->
</TABLE>
 --->







</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
