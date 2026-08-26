
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<CFIF NOT IsDefined("reportInclude")>
		<CFINCLUDE TEMPLATE="reportInclude.cfm">
	</CFIF>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>
<!---Initailization--->

<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	<br><br><br>
	<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	<br><br><br>
	<cfflush>
</SPAN>

<body BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onload="">
	
	<SCRIPT LANGUAGE="JavaScript">
		document.all.PleaseWaitMessage.style.display='none';
	</SCRIPT>
	<!--- header  --->
	<CFINCLUDE TEMPLATE="/includes/header.cfm">
	<!--- read me help information --->

	<BLOCKQUOTE>
	<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
		<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
			<TR><TD VALIGN="top"><BLOCKQUOTE><CFINCLUDE TEMPLATE="reportInvoiceForm.cfm"></BLOCKQUOTE></TD></TR>
		</TABLE>
	</BLOCKQUOTE>
	<!--- footer --->
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
	<CF_MessageWindow>
	<CFIF isDefined("sErr")>
		<SCRIPT LANGUAGE="JavaScript">
			showError();		
		</SCRIPT>
	</CFIF>
	<SCRIPT LANGUAGE="JavaScript">
		findselectboxes();
	</SCRIPT>

</BODY>
</HTML>
