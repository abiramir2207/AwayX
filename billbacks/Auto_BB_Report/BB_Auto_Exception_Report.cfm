<!---------------------------------------------------------------------------------------------------------------------
Template:	\billbacks\Auto_BB_Report\BB_Auto_Exception_Report.cfm
Date:	Aug 9th, 2017
Author:	Milan Mushran
Purpose: Excel Report for Auto pay exception list 
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html>
<cfparam name="URL.ReportID" default="">
<cfset qGetExceptionReportDistributorsForExcelReport = application.oBBReportGet.getExceptionReportDistributorsForExcelReport(URL.ReportID)>
<cfset qGetExceptionReportInvoicesForExcelReport = application.oBBReportGet.getExceptionReportInvoicesForExcelReport(URL.ReportID)>
<cfset objGeneralFunctions = CreateObject("component","components.general.General_Functions")>

<body>

<cfset file_name = "AutoPayExceptionList_#URL.ReportID#_#DateFormat(now(),'mmddyyyy')#_#TimeFormat(now(),'hhmmss')#.xls">
<cfset file_path = "#Application.Doc_Path#\Temp_Files\Billback\AutoPayReport\#file_name#">

<!--- DISTRIBUTOR --->

<!--- Initialize spreadsheet object --->
<cfset DistSheet = SpreadsheetNew("DistList")>

<!--- Initialize an array to store column numbers to be converted to "text". --->
<cfset arrColumnNumbersToFormatAsText = ArrayNew(1)>

<!--- Column Numbers --->
<cfset ArrayAppend(arrColumnNumbersToFormatAsText, 1)>

<cfset fileExistStatus = 0>
<cfif qGetExceptionReportDistributorsForExcelReport.Recordcount GT 0>
	<!--- Call function to format column(s) as text. --->
	<cfset objGeneralFunctions.spreadsheetAddRowsForceTextFormat(DistSheet,qGetExceptionReportDistributorsForExcelReport,arrColumnNumbersToFormatAsText)>
	<cfspreadsheet  
		action="write" 
		filename = "#file_path#"
			<!--- For this sheet, the data was modified above (convert datatype to "text") and so the data comes
			from a sheet ("DistSheet") and not a query.
			--->
			name = "DistSheet" 
			sheetname="distributors">
		<cfset fileExistStatus = 1>
</cfif>

<!--- If the file already exists, then update the file with invoice details in a new tab, else write the file --->
<cfif fileExistStatus eq 1>
<cfset fileAction = "update">
<cfelse>
<cfset fileAction = "write">
</cfif>

<!--- INVOICE --->

<!--- Initialize spreadsheet object --->
<cfset InvoicesSheet = SpreadsheetNew("InvoicesList")>

<!--- Initialize an array to store column numbers to be converted to "text". --->
<cfset arrColumnNumbersToFormatAsText = ArrayNew(1)>

<!--- Column Numbers --->
<cfset ArrayAppend(arrColumnNumbersToFormatAsText, 1)>
<cfset ArrayAppend(arrColumnNumbersToFormatAsText, 2)>
<cfset ArrayAppend(arrColumnNumbersToFormatAsText, 3)>
<cfset ArrayAppend(arrColumnNumbersToFormatAsText, 6)>


<cfif qGetExceptionReportInvoicesForExcelReport.Recordcount GT 0>
	<!--- Call function to format column(s) as text. --->
	<cfset objGeneralFunctions.spreadsheetAddRowsForceTextFormat(InvoicesSheet,qGetExceptionReportInvoicesForExcelReport,arrColumnNumbersToFormatAsText)>
	<cfspreadsheet  
		action="#fileAction#" 
		filename = "#file_path#" 
		<!--- For this sheet, the data was modified above (convert datatype to "text") and so the data comes
		from a sheet ("InvoicesSheet") and not a query.
		--->
		name = "InvoicesSheet" 
		sheetname="invoices">
	<cfset fileExistStatus = 1>
</cfif>

<cfoutput>
	<cfif fileExistStatus eq 1>
		<cfheader name="Cache-Control" value="no-cache" >
		<cfheader name="Content-Disposition" value="attachment; filename=#file_name#" >
		<cfcontent type="application/vnd.ms-excel" file="#file_path#">
	</cfif>
</cfoutput>

</body>
</html>