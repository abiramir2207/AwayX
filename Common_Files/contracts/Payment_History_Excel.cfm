<!--- Create new Excel File using the java.io.FileOutputStream class
 Then create an instance of the HSSFWorkbook Class based on
 Apache's POI library which is available at http://poi.apache.org/
--->
<cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init("Payment_History.xls") />
<cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
<!--- Create a new Worksheet and name it --->
<cfset newSheet = workBook.createSheet() />
<cfset workBook.setSheetName(0, "Payment History") />
<!--- Creates the default Font --->
<cfset f = workBook.createFont() />
<cfset cs = workBook.createCellStyle() />
<cfset cswrap = workBook.createCellStyle() />
<cfif isDefined("f.BOLDWEIGHT_BOLD")> <cfset f.setBoldweight(f.BOLDWEIGHT_BOLD)> <cfelse> <cfset f.setBold(true)> </cfif>
<cfset cs.setFont(f) />
<cfset cswrap.setFont(f) />
<cfset cswrap.setWrapText(true) />

	<!--- Create a row and the Header cell --->
	<cfset row1 = newSheet.createRow(0) />

	<cfset cell1 = row1.createCell(0) />
	<cfset cell1.setCellValue("Billback ##") />
	<cfset cell1.setCellStyle(cswrap) />

	<cfset cell2 = row1.createCell(1) />
	<cfset cell2.setCellValue("Billback Title") />
	<cfset cell2.setCellStyle(cs) />

	<cfset cell3 = row1.createCell(2) />
	<cfset cell3.setCellValue("Payable ##") />
	<cfset cell3.setCellStyle(cs) />

	<cfset cell4 = row1.createCell(3) />
	<cfset cell4.setCellValue("Payee Name") />
	<cfset cell4.setCellStyle(cs) />

	<cfset cell5 = row1.createCell(4) />
	<cfset cell5.setCellValue("Payee ID") />
	<cfset cell5.setCellStyle(cs) />

	<cfset cell6 = row1.createCell(5) />
	<cfset cell6.setCellValue("Start Date") />
	<cfset cell6.setCellStyle(cs) />

	<cfset cell7 = row1.createCell(6) />
	<cfset cell7.setCellValue("End Date") />
	<cfset cell7.setCellStyle(cs) />

	<cfset cell8 = row1.createCell(7) />
	<cfset cell8.setCellValue("Paid Amount") />
	<cfset cell8.setCellStyle(cs) />

	<cfset cell9 = row1.createCell(8) />
	<cfset cell9.setCellValue("Transaction ##") />
	<cfset cell9.setCellStyle(cs) />

	<cfset cell10 = row1.createCell(9) />
	<cfset cell10.setCellValue("Date Paid") />
	<cfset cell10.setCellStyle(cs) />

	<cfset cell11 = row1.createCell(10) />
	<cfset cell11.setCellValue("LBS") />
	<cfset cell11.setCellStyle(cs) />

	<cfset cell12 = row1.createCell(11) />
	<cfset cell12.setCellValue("LB Avg Rate") />
	<cfset cell12.setCellStyle(cs) />

	<cfset cell13 = row1.createCell(12) />
	<cfset cell13.setCellValue("CS") />
	<cfset cell13.setCellStyle(cs) />

	<cfset cell14 = row1.createCell(13) />
	<cfset cell14.setCellValue("CS Avg Rate") />
	<cfset cell14.setCellStyle(cs) />

	<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
	<cfset getpaymentdetails = PaymentHistoryManager.getpaymentdetails(url.contract_number) />
	<cfoutput query="getpaymentdetails">
		<cfset row2 = newSheet.createRow(#currentRow#) />
		<cfset row2.createCell(0).setCellValue(#BB_reference#) />
		<cfset row2.createCell(1).setCellValue(#BB_Title#) />
		<cfset row2.createCell(2).setCellValue(#BB_code#) />
		<cfset row2.createCell(3).setCellValue(#payee_name#) />
		<cfset row2.createCell(4).setCellValue(#payee_id#) />
		<cfset row2.createCell(5).setCellValue(#dateformat(BB_start_date,"mm/dd/yyyy")#) />
		<cfset row2.createCell(6).setCellValue(#dateformat(BB_End_date,"mm/dd/yyyy")#) />
		<cfset row2.createCell(7).setCellValue(#DollarFormat(paid_amount)#) />
		<cfset row2.createCell(8).setCellValue(#Check_Number#) />
		<cfset row2.createCell(9).setCellValue(#dateformat(check_date,"mm/dd/yyyy")#) />
		<cfset row2.createCell(10).setCellValue(#numberformat(volume_lb,'_,___,___,___,___')#) />
		<cfset row2.createCell(11).setCellValue(#DollarFormat(avg_rate_lb)#) />
		<cfset row2.createCell(12).setCellValue(#numberformat(volume_cs,'_,___,___,___,___')#) />
		<cfset row2.createCell(13).setCellValue(#DollarFormat(avg_rate_cs)#) />
	</cfoutput>

	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() />
	<cfset variables.fileOutStream.close() />

	 <cfheader name="Content-Disposition" value="attachment;filename=Payment_History.xls"  />
	 <cfcontent type="application/vnd.ms-excel" file="Payment_History.xls" deletefile="true"  />