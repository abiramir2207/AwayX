<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="reportInclude.cfm">
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE>
	select
	{
		width: 200px;
	}
	</STYLE>
	<SCRIPT language="JavaScript" SRC="../validate.js"></SCRIPT>	
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="javascript:document.all.PleaseWaitMessage.style.display='none';document.all.bodyText.style.display='';disableProgramFilterItems();disableProductFilterItems();intervalSelection(document.all.rInterval);">

<CFSET PW_DoNotCFFLUSH=1>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	<br><br><br>
	<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	<br><br><br>
</SPAN>


<SPAN ID="bodyText" STYLE="display:none">
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<BLOCKQUOTE>
<BR>
<CFPARAM NAME="URL.reportType" DEFAULT="programSummary">
<CFPARAM NAME="reportType" DEFAULT="#URL.reportType#">


<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>		
		<TD VALIGN="top">
		<CFSET diThisPage="#reportType#">
		<CFINCLUDE template="reportHeader.cfm">

<CFINCLUDE TEMPLATE="reportLookup.cfm">


<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegEnabled = businessSegManager.isEnabled()>

	
<cfif reportType EQ "programSummary" OR reportType EQ "productSummary">
	<SCRIPT language="JavaScript" SRC="rCommonFunctions_1.js"></SCRIPT>
<cfelse>
	<SCRIPT language="JavaScript" SRC="rCommonFunctions.js"></SCRIPT>
</cfif>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">&nbsp;&nbsp;&nbsp;

<cfif reportType EQ "programSummary">	
	<CFINCLUDE TEMPLATE="#reportProgramPage#">
 <!--- <CFINCLUDE TEMPLATE="newprogramreport.cfm"> --->
<!-----<cfelseif reportType EQ "productSummary">------->
<cfelseif reportType EQ "invoiceprogramSummary">
	 <CFINCLUDE TEMPLATE="#newreportProgramPage#">
<cfelseif reportType EQ "invoiceproductSummary">
	 <CFINCLUDE TEMPLATE="#newreportProductPage#">
<cfelse>
	<CFINCLUDE TEMPLATE="#reportProductPage#">
<!-----<cfelseif reportType EQ "productMargin">
	<CFINCLUDE TEMPLATE="#reportProductMarginPage#">------->
</cfif>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE>
		</TD>
	</TR>
</TABLE>


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
