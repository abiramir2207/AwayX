<!-----------------showReport.cfm----------------->
<!----------------Set Defaults--------->

<cfset srNotCSV=true>
<cfif rReportOutputType EQ "e">
	<cfcontent type="application/unknown">
	<cfheader name="Content-Disposition" value="attachment;filename=productSummaryReport.xls">
<cfelseif rReportOutputType EQ "c">
	<cfcontent type="application/unknown">
	<cfheader name="Content-Disposition" value="attachment;filename=productSummaryReport.csv">
	<cfset srNotCSV=false>
</cfif>

<CFSET reportType=Form.rReportType>
<CFINCLUDE TEMPLATE="#displayProduct#">

<cfif srQuery.recordCount GT 0>
	<cfif rReportOutputType EQ "h">	
		<CFOUTPUT><TABLE CELLSPACING="0" CELLPADDING="0" BORDER="0" WIDTH="176" HEIGHT="35" BACKGROUND="/images/print_button.gif">
		<TR>
		<TD><A HREF="javascript:void(0);" onClick="javascript:window.print();"><IMG SRC="/images/fill.gif" ALT="" WIDTH="176" HEIGHT="35" BORDER="0"></A></TD>
		</TR>
		</TABLE></CFOUTPUT>	
	</cfif>
</cfif>

<cfif (rReportOutputType EQ "e") OR (rReportOutputType EQ "c")>
	<cfabort>
</cfif>
