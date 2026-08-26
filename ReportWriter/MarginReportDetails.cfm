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


<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>
		<TD VALIGN="top">
			<IMG SRC="/images/icon_reports_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD>
		<TD VALIGN="top">
		<CFSET diThisPage="#MarginReportDetailsPage#">
		<CFINCLUDE template="reportHeader.cfm">

<CFINCLUDE TEMPLATE="reportLookup.cfm">

<CFOUTPUT>
<SCRIPT LANGUAGE="Javascript">
	var reportSaveActionPage = "#MarginSaveActionPage#";
	var verifyValuesFunction = "verifyMarginReportValues";
</SCRIPT>
</CFOUTPUT>

<BLOCKQUOTE>

<CFPARAM NAME="URL.rID" DEFAULT="">
<CFPARAM NAME="rID" DEFAULT="#URL.rID#">
<CFPARAM NAME="reportType" DEFAULT="Product_Based_Margin_Analysis">
<CFSET rUserName="">
<CFSET rEditDate="">


<CFIF isNumeric(rID)>

	
	<CFQUERY NAME="q_getReportDetails" datasource="#application.datasource#">
	SELECT 	rt.Report_Type_ID,rt.Report_Type,rtemp.*,u.Name_First + ' ' + u.Name_Last as uName,rt.Created_Date
	FROM	
			(Report_Type rt right join Report_Template rtemp 
			on rt.Report_Type_ID=rtemp.Report_Type_ID) 
			left join _Users u on rt.User_ID = u.User_ID
	WHERE		rt.Report_Type_ID=#rID#
	</CFQUERY>
	
	
	<CFIF q_getReportDetails.recordCount GT 0>		
		<CFSET reportType=q_getReportDetails.Report_Type>
		<CFSET rUserName=q_getReportDetails.uName>
		<CFSET rEditDate=q_getReportDetails.Created_Date>
		<CFQUERY NAME="q_getReportStructure" datasource="#application.datasource#">
			SELECT 	rs.*
			FROM	Report_Type rt,Report_Structure rs
			WHERE	rt.Report_Type_ID=rs.Report_Type_ID
			and
			rt.Report_Type_ID=#rID#
		</CFQUERY>
	</CFIF>
<CFELSE>
	<CFLOCATION url="#reportListPage#">
</CFIF>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<cfif reportType EQ "Product_Based_Margin_Analysis">	
	<CFINCLUDE TEMPLATE="#reportProductMarginAnalysisPage#">
<cfelse>
	<CFINCLUDE TEMPLATE="#reportProductMarginAnalysisPage#">
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
