<cfquery name="invocierecords" datasource="#application.datasource#">
		SELECT DISTINCT Invoice_Number
			<cfif url.from EQ 'invoice'>
						FROM #URL.Log_CF_Header_Table#
						WHERE #Log_Distributor_Column# = '#url.CustomerNumber#'		
			<cfelseif url.from EQ 'item'>
						FROM #Log_CF_Detail_Table#
						WHERE #Log_Item_Column# = '#url.ItemNumber#'		
			</cfif> 
		AND Created_Date BETWEEN '#url.startdate#' AND '#url.enddate#'					  
</cfquery>

      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init("Invoice_report.xls") />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "Invoices") />
      <!--- Creates the default Font --->
	  <cfset f = workBook.createFont() />
      <cfset cs = workBook.createCellStyle() />
      <cfset cswrap = workBook.createCellStyle() />
      <cfif isDefined("f.BOLDWEIGHT_BOLD")> <cfset f.setBoldweight(f.BOLDWEIGHT_BOLD)> <cfelse> <cfset f.setBold(true)> </cfif>
      <cfset cs.setFont(f) />
      <cfset cswrap.setFont(f) />
      <cfset cswrap.setWrapText(true) />

<cfoutput>
	
  	  <!--- Create a row and the Header cell --->
      <cfset row1 = newSheet.createRow(0) />
      <cfset cell1 = row1.createCell(0) />
      <!--- invocie --->
	    <cfset cell1.setCellValue("Invoice Number") />
      <cfset cell1.setCellStyle(cswrap) />
      <!--- 
      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("#application.returned_customer_setting.distributor_label_singular#") />
      <cfset cell2.setCellStyle(cs) />--->
               
 
     <cfloop query="invocierecords">
	   <cfset row2 = newSheet.createRow(#currentRow#) />
	   <cfset row2.createCell(0).setCellValue(Invoice_Number) />
	    <!---<cfset row2.createCell(1).setCellValue(Customer_Number) />---> 
	 </cfloop>
	 
</cfoutput>
    
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=Invoice_report.xls"  />
	 <cfcontent type="application/vnd.ms-excel" file="Invoice_report.xls" deletefile="true"  />
	 
	  
	 
	

