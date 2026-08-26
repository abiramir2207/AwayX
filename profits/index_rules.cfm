<!--- Get the profile for this user --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFSET PAGE_TITLE=	"Profitability Analysis Tool">
<CFSET GROUP=		"Profit">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0">

<TR>
	<TD>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>
	<TD VALIGN="top" WIDTH="255">
		<BR>
		<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
		<BR><BR>
		<B>
		<FONT COLOR="Red">[</FONT>
		<FONT COLOR="Blue"><A HREF="index.cfm">view commodity data sources</A></FONT>
		<FONT COLOR="Red">]</FONT>
		</B>
		<BR><BR>
		<CFSET TARGET_PAGE = "MainFrame">
		<CFIF Get_Profile_Settings.Commodity_Price_Rule_View EQ 1>
			<CFINCLUDE TEMPLATE="rules_wizard_get_list_of_rules.cfm">
		</CFIF>









		
	</TD>
	<TD VALIGN="top" WIDTH="100%">
		&nbsp;&nbsp;
		<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="7" BORDER="0" ALT="">



		<CFIF Get_Profile_Settings.Commodity_Price_Rule_View EQ 1>
			<CFPARAM NAME="URL.PRID" 	DEFAULT="">
			<CFSET IFRAME_URL = "index2.cfm">
			<CFIF URL.PRID NEQ "">
				<CFSET IFRAME_URL = "pricing_rule_display.cfm?PRID=#URL.PRID#">
			</CFIF>
			<IFRAME SRC="<CFOUTPUT>#IFRAME_URL#</CFOUTPUT>" NAME="MainFrame" WIDTH="675" MARGINWIDTH="5" HEIGHT="497" MARGINHEIGHT="5" SCROLLING="auto"></IFRAME>
		</CFIF>

		



	</TD>
</TR>
</TABLE>








<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- 
<SCRIPT LANGUAGE="JavaScript">
	findselectboxes();
</SCRIPT>
 --->

</BODY>
</HTML>
