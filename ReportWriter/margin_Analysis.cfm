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
	<SCRIPT language="JavaScript" SRC="rCommonFunctions.js"></SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="javascript:document.all.PleaseWaitMessage.style.display='none';document.all.bodyText.style.display='';disableProductMarginFilterItems();marginOptionSelected(document.all.rMarginOption);intervalSelection(document.all.rInterval);">
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
<CFPARAM NAME="URL.reportType" DEFAULT="Product_Based_Margin_Analysis">
<CFPARAM NAME="reportType" DEFAULT="#URL.reportType#">

<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>
		<!------ 
		<TD VALIGN="top">
			<IMG SRC="/images/icon_reports_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		 ----->
		<TD VALIGN="top">
		<CFSET diThisPage="#reportType#">
		<CFINCLUDE template="reportHeader.cfm">

<CFINCLUDE TEMPLATE="reportLookup.cfm">

<CFOUTPUT>
<SCRIPT LANGUAGE="Javascript">
	var reportSaveActionPage = "#MarginSaveActionPage#";
	var verifyValuesFunction = "verifyMarginReportValues";
</SCRIPT>
</CFOUTPUT>

<BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegEnabled = businessSegManager.isEnabled()>


<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">&nbsp;&nbsp;&nbsp;
<cfif reportType EQ "Product_Based_Margin_Analysis">	
	<CFINCLUDE TEMPLATE="#reportProductMarginAnalysisPage#">
<!-----<cfelseif reportType EQ "productSummary">------->
<cfelse>
	<CFINCLUDE TEMPLATE="#reportProductMarginAnalysisPage#">
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
