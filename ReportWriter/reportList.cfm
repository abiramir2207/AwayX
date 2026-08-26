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
	<SCRIPT language="JavaScript" SRC="/validate.js"></SCRIPT>
	<SCRIPT language="JavaScript" SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
	<SCRIPT language="JavaScript" SRC="rCommonFunctions.js"></SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" onLoad="javascript:disableProgramFilterItems();disableProductFilterItems();">

<CFINCLUDE TEMPLATE="/includes/header.cfm">

<BLOCKQUOTE>

<BR>

<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="5" HEIGHT="100%" WIDTH="90%" align="center">
	<TR>
		<!--- <TD VALIGN="top">
			<IMG SRC="/images/icon_reports_large.gif" BORDER="0" ALT="">
		</TD>
		<TD BGCOLOR="Navy"></TD> --->
		<TD VALIGN="top">
		<CFSET diThisPage="#reportListPage#">
		<CFINCLUDE template="reportHeader.cfm">
		<!-----
			<DIV CLASS="title2">How to create a report:</DIV>
<OL>
	<LI>Select the report you wish to run by clicking the icon to the left of the report title.</LI>
	<LI>A selection box will open that allows you to enter the dates for your report, make selections within a range of criteria covering operator types, market area coverage, distributor types, and product types.  These criteria allow you to run targeted reports against specific areas of the business.  </LI>
	<LI>At the bottom of the selection box, select "Screen-HTML" if you wish to view the report within your browser or "File-XL" if you wish to export the report to Microsoft Excel.  Once in Excel, you can use the data just like any other spreadsheet you work with (sorting, filtering, adding columns, rows, etc.).  Finally, remember to save the report to your hard drive.</LI>
	<LI>Click on "Run this report".</LI>
</OL>--->



<BLOCKQUOTE>

<cfoutput>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">&nbsp;&nbsp;&nbsp;
<SPAN CLASS="title2">Saved Reports
</SPAN>
</cfoutput>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!------ 
<CFQUERY NAME="q_getReportList" datasource="#application.datasource#">
	SELECT 	rt.Report_Type_ID,rt.Report_Type,rtemp.Report_Name,rtemp.Report_StartTime
	FROM	Report_Type rt,Report_Template rtemp
	WHERE	rt.Report_Type_ID=rtemp.Report_Type_ID
	--and GenerateEmail IS NULL
</CFQUERY>
 ----->

<HR COLOR="Orange" SIZE="1">
<BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFOUTPUT>
<!------ 
<CFIF q_getReportList.recordCount GT 0>
	<TABLE CELLSPACING="0" CELLPADDING="2" BORDER="0" ALIGN="CENTER" CLASS="Maintable">	
	<THEAD BGCOLOR="FFCE84">
		<TD>&nbsp;</TD>
		<TD><FONT SIZE="-1"><b>Report Type</b></FONT></TD>
		<TD><FONT SIZE="-1"><b>Report Name</b></FONT></TD>
		<TD><FONT SIZE="-1"><b>Start Time</b></FONT></TD>		
		<TD>&nbsp;</TD>
	</THEAD>
	<COLGROUP>
	<COL SPAN="2" style="color:blue"></COL>
	</COLGROUP>
	<CFLOOP QUERY="q_getReportList">
		<CFSET thisReportDetailsPage=reportDetailsPage>
		<!------<CFSET thisReportDetailsPage=MarginReportDetailsPage>----->
		
		<TR <cfif (q_getReportList.currentRow mod 2) NEQ 0> BGCOLOR=ccffcc</cfif> style="cursor:pointer">
		<TD>&nbsp;</TD>
		<CFSET reportLongName=UCase(ReplaceNoCase(ReplaceNoCase(Report_Type,"summary",""),"_"," ","All"))>
		<a href="#thisReportDetailsPage#?rID=#Report_Type_ID#"><TD WIDTH="200" style="color:blue" VALIGN="TOP">#reportLongName#</TD></a>
		<a href="#thisReportDetailsPage#?rID=#Report_Type_ID#"><TD WIDTH="300" style="color:blue" VALIGN="TOP">#Report_Name#</TD></a>
		<a href="#thisReportDetailsPage#?rID=#Report_Type_ID#"><TD WIDTH="100" style="color:blue" VALIGN="TOP">#TimeFormat(CreateDateTime(Year(Now()),Month(Now()),Day(Now()),Left(Report_StartTime,2),Mid(Report_StartTime,4,2),Mid(Report_StartTime,7,2)),"hh:mm tt")#</TD></a>		
		<TD TITLE="Delete #reportLongName#"><a href="#reportDeletePage#?rID=#Report_Type_ID#" onClick="javascript:return confirm('Do you want to delete saved report \'' + '#ReplaceNOCase(reportLongName,"'","\'","All")#' + '\'?');"><img src="/images/delete.gif" TITLE="Delete #reportLongName#"></a></TD>
		</TR>

	</CFLOOP>
	</TABLE>
<CFELSE>
	<TABLE BGCOLOR="Orange" BORDER="0" CELLPADDING="3" CELLSPACING="1" ALIGN="CENTER">
		<TR BGCOLOR="White">
		<TD>		
		<FONT SIZE="2"><B>
		No Saved reports found
		</B></FONT>
		</TD>
		</TD>
		</TR>
	</TABLE>
</CFIF>
 ----->
 
 <p></p>
<cfif request.AccessStructure.Company_Name IS "BSA Foods">
<TABLE CELLSPACING="0" CELLPADDING="2" BORDER="0" ALIGN="CENTER" CLASS="Maintable" width="75%">	
	<THEAD BGCOLOR="FFCE84">
	<tr><Td><FONT SIZE="-1"><b>Specified Reports:</Td></tr>
	</thead>

	<tr><td><a href="/reportwriter/fiscal_period_reports/index.cfm">Fernando's #application.returned_customer_setting.distributor_label_singular# Payment Report</a></td></tr>
	
<tr><td></td></tr>
</TABLE>


</cfif>
</CFOUTPUT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE>
<!------
<cfif URL.reportType EQ "program">
	<CFINCLUDE TEMPLATE="#reportProgramPage#">
<cfelse>
	<CFINCLUDE TEMPLATE="#reportProductPage#">
</cfif>
---->
<!-----
<CFINCLUDE TEMPLATE="#reportProgramPage#">
<CFINCLUDE TEMPLATE="#reportProductPage#">
---->



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
</BODY>
</HTML>
