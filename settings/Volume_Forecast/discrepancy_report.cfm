<!----
	Name: discrepancy_report.cfm         
	Copyright (c) 2013 Blacksmith Applications, Inc.       
 	Description:Used to download discrepancy report
	Usage:Used to download discrepancy report
---->	
<cfstoredproc procedure="VF_Report_Missing_Dist_Prod" datasource="#application.datasource#">
	<cfprocresult name="qdiscrepancyreport">
</cfstoredproc>

<cfquery name="customersettings" datasource="#application.datasource#" >
	SELECT shard_ship_to_label,item_label,type_code_label_singular
	FROM customer_settings
</cfquery>

<cfquery name="businesssegment" datasource="#application.datasource#" >
   select business_segment_label
	from _application_settings
</cfquery>
  
      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init("discrepancy_report.xls") />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "DiscrepancyReport") />
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
	  <cfset cell1.setCellValue("#businesssegment.business_segment_label# ##") />
      <cfset cell1.setCellStyle(cswrap) />

      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("#businesssegment.business_segment_label#") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("#customersettings.shard_ship_to_label#") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Name") />
      <cfset cell4.setCellStyle(cs) />

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("#customersettings.item_label#") />
      <cfset cell5.setCellStyle(cs) />

      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Description") />
      <cfset cell6.setCellStyle(cs) />
  
      <cfset cell7 = row1.createCell(6) />
      <cfset cell7.setCellValue("#customersettings.type_code_label_singular#") />
      <cfset cell7.setCellStyle(cs) />

      <cfset cell8 = row1.createCell(7) />
      <cfset cell8.setCellValue("Prior EQ CS") />
      <cfset cell8.setCellStyle(cs) />

      <cfset cell9 = row1.createCell(8) />
      <cfset cell9.setCellValue("Current EQ CS") />
      <cfset cell9.setCellStyle(cs) />
                   
  </cfoutput>

      <cfoutput query="qdiscrepancyreport">
			   <cfset row2 = newSheet.createRow(#currentRow#) />
			   <cfset row2.createCell(0).setCellValue(#Business_Unit_ID#) />
			   <cfset row2.createCell(1).setCellValue(#Business_Unit_Desc#) />
			   <cfset row2.createCell(2).setCellValue(#Shr_Ship_To#) />
			   <cfset row2.createCell(3).setCellValue(#Name#) />
			   <cfset row2.createCell(4).setCellValue(#Item#) />
			   <cfset row2.createCell(5).setCellValue(#Description#) />
			   <cfset row2.createCell(6).setCellValue(#Type_Code_Desc#) />
   			   <cfset row2.createCell(7).setCellValue(#trim(Prior_EQC)#) />
			   <cfset row2.createCell(8).setCellValue(#trim(Current_EQC)#) />
	 </cfoutput>

	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 
	 
	 <cfheader name="Content-Disposition" value="attachment;filename=discrepancy_report.xls"  />
	 <cfcontent type="application/vnd.ms-excel" file="discrepancy_report.xls" deletefile="true"  />