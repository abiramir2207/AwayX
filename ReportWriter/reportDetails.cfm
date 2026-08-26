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
	<!-----<SCRIPT language="JavaScript" SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>------->
	<SCRIPT language="JavaScript" SRC="rCommonFunctions.js"></SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="javascript:document.all.PleaseWaitMessage.style.display='none';document.all.bodyText.style.display='';disableProgramFilterItems();disableProductFilterItems();intervalSelection(document.all.rInterval);disableProductMarginFilterItems();marginOptionSelected(document.all.rMarginOption);">
<CFSET PW_DoNotCFFLUSH=1>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
	<br><br><br>
	<center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
	<br><br><br>
</SPAN>

<SPAN ID="bodyText" STYLE="display:none">
<CFINCLUDE TEMPLATE="/includes/header.cfm">

<BLOCKQUOTE>
<B>
<FONT SIZE="2" COLOR="Red">[</FONT>
<FONT SIZE="2" COLOR="Blue"><A HREF="/help_files/manual/Reports/index.cfm" onclick="NewWindow(this.href,'name','800','600','Yes', 'No');return false;">read me first</A></FONT>
<FONT SIZE="2" COLOR="Red">]</FONT>
</B>


<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5">
	<TR>
		<TD VALIGN="top">
		<CFSET diThisPage="#reportDetailsPage#">
		<CFINCLUDE template="reportHeader.cfm">
		<!-----
			<DIV CLASS="title2">How to create a report:</DIV>
<OL>
	<LI>Select the report you wish to run by clicking the icon to the left of the report title.</LI>
	<LI>A selection box will open that allows you to enter the dates for your report, make selections within a range of criteria covering operator types, market area coverage, distributor types, and product types.  These criteria allow you to run targeted reports against specific areas of the business.  </LI>
	<LI>At the bottom of the selection box, select "Screen-HTML" if you wish to view the report within your browser or "File-XL" if you wish to export the report to Microsoft Excel.  Once in Excel, you can use the data just like any other spreadsheet you work with (sorting, filtering, adding columns, rows, etc.).  Finally, remember to save the report to your hard drive.</LI>
	<LI>Click on "Run this report".</LI>
</OL>--->


<CFINCLUDE TEMPLATE="reportLookup.cfm">

<BLOCKQUOTE>

<CFPARAM NAME="URL.rID" DEFAULT="">
<CFPARAM NAME="rID" DEFAULT="#URL.rID#">
<CFPARAM NAME="reportType" DEFAULT="programSummary">
<CFSET rUserName="">
<CFSET rEditDate="">


<CFIF isNumeric(rID)>

	<!-----<CFQUERY NAME="q_getReportDetails" datasource="#application.datasource#">
	SELECT 	rt.Report_Type_ID,rt.Report_Type,u.Name_First + ' ' + u.Name_Last as uName,rt.Created_Date,rtemp.*
	FROM	Report_Type rt,Report_Template rtemp,_users u
	WHERE	rt.Report_Type_ID=rtemp.Report_Type_ID			
			and
			rt.Report_Type_ID=#rID#
			and
			u.user_id = rt.User_ID
	</CFQUERY>------->
	<!-----<CFQUERY NAME="q_getReportDetails" datasource="#application.datasource#">
	SELECT 	rt.Report_Type_ID,rt.Report_Type,rtemp.*,u.Name_First + ' ' + u.Name_Last as uName,rt.Created_Date
	FROM	Report_Type rt,Report_Template rtemp,_users u
	WHERE	u.user_ID=rt.user_ID
			and rt.Report_Type_ID=rtemp.Report_Type_ID
			and rt.Report_Type_ID=#rID#
	</CFQUERY>------->
	
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


<cfif reportType EQ "programSummary">
	<CFINCLUDE TEMPLATE="#reportProgramPage#">
<cfelseif reportType EQ "productSummary">
	<CFINCLUDE TEMPLATE="#reportProductPage#">
<cfelseif reportType EQ "invoiceprogramSummary">
	<CFINCLUDE TEMPLATE="#newreportProgramPage#">
<cfelseif reportType EQ "invoiceproductSummary">
	<CFINCLUDE TEMPLATE="#newreportProductPage#">
<cfelseif reportType EQ "Product_Based_Margin_Analysis">
	<CFOUTPUT>
	<SCRIPT LANGUAGE="Javascript">
		var reportSaveActionPage = "#MarginSaveActionPage#";
		var verifyValuesFunction = "verifyMarginReportValues";
	</SCRIPT>
	</CFOUTPUT>
	<CFINCLUDE TEMPLATE="#reportProductMarginAnalysisPage#">
<cfelse>
	<CFOUTPUT>
	<SCRIPT LANGUAGE="Javascript">
		var reportSaveActionPage = "#MarginSaveActionPage#";
		var verifyValuesFunction = "verifyMarginReportValues";
	</SCRIPT>
	</CFOUTPUT>
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
