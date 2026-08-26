
<cfparam name="ClaimPage_Title" default="Claim Reports">
<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="reportInclude.cfm">
</CFIF>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#ClaimPage_Title#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE>
	select
	{
		width: 200px;
	}
	</STYLE>
	<SCRIPT language="JavaScript" SRC="../validate.js"></SCRIPT>	
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="javascript:document.all.PleaseWaitMessage.style.display='none';document.all.bodyText.style.display='';">
<CFSET PW_DoNotCFFLUSH=1>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	<br><br><br>
	<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	<br><br><br>
</SPAN>

<cfset claimReportList = "claimSummary,varietySummary,timeProcSummary,participation,savingCost" >

<SPAN ID="bodyText" STYLE="display:none">
	<CFINCLUDE TEMPLATE="/includes/header.cfm">	
	<BLOCKQUOTE>
	<BR>
	<CFPARAM NAME="URL.reportType" DEFAULT="claimSummary">
	<CFPARAM NAME="reportType" DEFAULT="#URL.reportType#">
	
	<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
	
	<CFSET diThisPage="#reportType#">
	<CFINCLUDE template="claimReportHeader.cfm">
	<CFINCLUDE template="claimReportInterface.cfm">
	</BLOCKQUOTE>
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
</SPAN>
</BODY>
</HTML>
