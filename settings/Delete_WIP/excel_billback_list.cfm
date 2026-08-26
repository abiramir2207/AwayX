<!---
	Copyright (c)2014 Blacksmith Applications, Inc.
	Filename:		C:\Work\base\AwayX\Settings\Delete_WIP\excel_billback_list.cfm
	Created:		1/24/2014
	Developer:		Milan
	Description:	Create Excel document for list of billbacks to be purged.
--->

<cfparam name="url.purgeDate" default="">
	<!--- NOTE:
		If you change the conditions in this query, you will need to change it on "confirm_deletion.cfm" and "execute_deletion.cfm" also. 
	--->
<cfquery name="billbackList" datasource="#application.datasource#">
	SELECT BB_Code,bb_title,BB_Reference,BB_Date,BB_Start_Date,BB_End_Date,
	CASE Billback.Deleted 
		WHEN 1
			THEN 'Yes'
		ELSE
			'No'
	END
		As 'Deleted'

	FROM 
		Billback
	WHERE Billback.Created_Date <= #url.purgeDate#
	AND Billback.Billback_Status_ID = 1
	ORDER BY Billback.Deleted Desc
</cfquery>


	<cfset ExcelName  = "deleteBillbackList.xls">


      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#ExcelName#) />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "billback list") />
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

      <cfset cell1.setCellValue("Payable Number") />
      <cfset cell1.setCellStyle(cswrap) />

      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("Payable Title") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Reference Number") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Billback Date") />
      <cfset cell4.setCellStyle(cs) />

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Billback Start Date") />
      <cfset cell5.setCellStyle(cs) />

      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Billback End Date") />
      <cfset cell6.setCellStyle(cs) />

      <cfset cell7 = row1.createCell(6) />
      <cfset cell7.setCellValue("Already Deleted") />
      <cfset cell7.setCellStyle(cs) />

     <cfoutput>
      <cfloop query="billbackList">
			   <cfset row2 = newSheet.createRow(#currentRow#) />

			   <cfset row2.createCell(0).setCellValue(#BB_Code#) />
			   <cfset row2.createCell(1).setCellValue(#bb_title#) />
			   <cfset row2.createCell(2).setCellValue(#BB_Reference#) />
			   <cfset row2.createCell(3).setCellValue(#Dateformat(BB_Date,'MM/DD/YYYY')#) />
			   <cfset row2.createCell(4).setCellValue(#Dateformat(BB_Start_Date,'MM/DD/YYYY')#) />
			   <cfset row2.createCell(5).setCellValue(#Dateformat(BB_End_Date,'MM/DD/YYYY')#) />
			   <cfset row2.createCell(6).setCellValue(#Deleted#) />
	 </cfloop>
    </cfoutput>

	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() />
	<cfset variables.fileOutStream.close() />

	 <cfheader name="Content-Disposition" value="attachment;filename=#ExcelName#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#ExcelName#" deletefile="true" />