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

<BR>

<TABLE WIDTH="700" ALIGN="center" CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD>

	<CF_TAB_GROUP Width="100%" height="450" General_Color="White">


		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Get the user settings from the database to be used by all tabs								 --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
		Select		*
		From		_Users_Settings
		Where		User_ID		=		'#request.AccessStructure.User_ID#'
		</CFQUERY>
		

		<CF_TAB_ITEM Title="deducts" ToolTip="Click here to...">
			<CFINCLUDE TEMPLATE="deduction_settings.cfm">
		</CF_TAB_ITEM>	

		
		<CF_TAB_ITEM Title="mkt area" ToolTip="Click here to...">
			<CFINCLUDE TEMPLATE="deduction_market_to_user.cfm">
		</CF_TAB_ITEM>


		<CF_TAB_ITEM Title="aging buckets" ToolTip="Click here to...">
			<CFINCLUDE TEMPLATE="aging_buckets.cfm">
		</CF_TAB_ITEM>

		<CF_TAB_ITEM Title="approvers" ToolTip="Click here to...">
			<CFINCLUDE TEMPLATE="deduction_approvers.cfm">
		</CF_TAB_ITEM>		

 
	</CF_TAB_GROUP>
	

	</TD>
</TR>
</TABLE>


<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
