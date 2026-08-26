<CFSET PAGE_TITLE="Load Template">
<CFSET GROUP="Contracts">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">


</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BLOCKQUOTE><BLOCKQUOTE>
<CFQUERY NAME="GetTemplates" datasource="#application.datasource#">
SELECT *
FROM Contract_Main
WHERE Template = 1
and DELETED = 0
</CFQUERY>

<table border="0" cellspacing="0" cellpadding="2" align="center">
	<TR>
		<TD>&nbsp;</TD>
		<TD><font size="2"><b>Template Title</b></font></TD>
	</TR>
<CFOUTPUT>
	<CFLOOP QUERY="GetTemplates">
	<CF_CRYP type="en" string="#GetTemplates.Contract_Main_ID#" key="#request.key#">
	<TR BGCOLOR="<Cfif currentrow mod 2>WhiteSmoke<CFELSE></CFIF>">
		<TD><A HREF="save_template_as_contract.cfm?CID=#cryp.value#"><img src="/images/contracts_icon.gif"></A></TD>
		<TD><A HREF="save_template_as_contract.cfm?CID=#cryp.value#">#GetTemplates.Contract_Title#</A></TD>
	</TR>
	
	</CFLOOP>
</CFOUTPUT>
</TABLE>

</BLOCKQUOTE></BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>
