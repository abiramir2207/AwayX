<!-----------------showReport.cfm----------------->
<!----------------Set Defaults--------->

<cfset srNotCSV=true>
<cfif rReportOutputType EQ "e">
	<cfcontent type="application/unknown">
	<cfheader name="Content-Disposition" value="attachment;filename=programSummaryReport.xls">
<cfelseif rReportOutputType EQ "c">
	<cfcontent type="application/unknown">
	<cfheader name="Content-Disposition" value="attachment;filename=programSummaryReport.csv">
	<cfset srNotCSV=false>
</cfif>
<CFSET reportType=Form.rReportType>

<cfswitch expression="#CheckColHeader#">
<cfcase value="fiscalvolume">
<CFINCLUDE TEMPLATE="#displaynewVolumeProgram#">
</cfcase>
<cfcase value="fiscalexpense">
<CFINCLUDE TEMPLATE="#displaynewExpenseProgram#">
</cfcase>
<cfcase value="fiscalmargin">
<CFINCLUDE TEMPLATE="#displaynewMarginProgram#">
</cfcase>
<cfdefaultcase>
<CFINCLUDE TEMPLATE="#displaynewVolumeProgram#">
</cfdefaultcase>
</cfswitch>
	<!--- <cfif CheckColHeader is 'fiscalvolume'>
			<CFINCLUDE TEMPLATE="#displaynewVolumeProgram#">
	<cfesleif CheckColHeader is 'fiscalexpense'>
			<CFINCLUDE TEMPLATE="#displaynewExpenseProgram#">
	<cfesleif CheckColHeader is 'fiscalmargin'>
			<CFINCLUDE TEMPLATE="#displaynewMarginProgram#">
	</cfif> --->


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
