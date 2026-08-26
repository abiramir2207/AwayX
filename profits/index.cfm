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

<TABLE CELLSPACING="0" CELLPADDING="2" BORDER="0" HEIGHT="98%">

<TR>
	<TD WIDTH="100">&nbsp;</TD>
	<TD VALIGN="top" WIDTH="46%" VALIGN="TOP" HEIGHT="100%">
		<TABLE CELLPADDING="0" CELLSPACING="0" WIDTH="100%" HEIGHT="100%" BORDER="0">
		<TR>
		<TD>
		<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
		<BR><BR>
		<TABLE CELLPADDING="0" CELLSPACING="0" BGCOLOR="D3D3D3" WIDTH="100%">
		<TR>
		<TD>
		<!------<SPAN STYLE="width:350px;border-bottom:2px orange solid;font: bold 14px sans-serif; color: Navy;">----->
		<SPAN WIDTH="100%" STYLE="font: bold 14px sans-serif; color: Navy;">
		&nbsp;Commodity Data Sources</SPAN>
		</TD>
		</TR>
		</TABLE>	
		</TD>
		</TR>
		<TR>
		<TD HEIGHT="100%">
		<IFRAME SRC="data_sources.cfm" NAME="toc" ID="toc" WIDTH="100%" HEIGHT="100%" MARGINWIDTH="0" MARGINHEIGHT="0"></IFRAME>
		<!------<CFINCLUDE TEMPLATE="data_sources.cfm">----->
		</TD>
		</TR>
		</TABLE>
		
	</TD>
	<TD WIDTH="100">&nbsp;
	&nbsp;</TD>
	<TD VALIGN="top" WIDTH="46%">
		
		<CFIF Get_Profile_Settings.Commodity_Price_Rule_View EQ 1>
			<TABLE CELLPADDING="0" CELLSPACING="0" WIDTH="100%" HEIGHT="100%" BORDER="0">
			<TR>
			<TD>
			<BR><BR>
			<TABLE CELLPADDING="0" CELLSPACING="0" BGCOLOR="D3D3D3" WIDTH="100%">
			<TR>
			<TD>
			<!------<SPAN STYLE="width:350px;border-bottom:2px orange solid;font: bold 14px sans-serif; color: Navy;">----->
			<SPAN WIDTH="100%" STYLE="font: bold 14px sans-serif; color: Navy;">
			&nbsp;Saved Pricing Rules</SPAN>
			</TD>
			</TR>
			</TABLE>	
			</TD>
			</TR>
			<TR>
			<TD HEIGHT="100%">
			<IFRAME SRC="rules_wizard_get_list_of_rules.cfm" NAME="toc" ID="toc" WIDTH="100%" HEIGHT="100%" MARGINWIDTH="0" MARGINHEIGHT="0"></IFRAME>
			<!------<CFINCLUDE TEMPLATE="rules_wizard_get_list_of_rules.cfm">----->
			</TD>
			</TR>
			</TABLE>
		</CFIF>
	</TD>
	<TD WIDTH="100">&nbsp;</TD>
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
