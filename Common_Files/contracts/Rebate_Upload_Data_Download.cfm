<!---
Name:        Rebate_Upload_Data_Download.cfm
Copyright (c) 2016 Blacksmith Applications, Inc.
Description: Used to download uploaded items/rate/UOM from rebate page.
--->

<!--- Create new Excel File using the java.io.FileOutputStream class
 Then create an instance of the HSSFWorkbook Class based on
 Apache's POI library which is available at http://poi.apache.org/
--->
<cfset fileName = #url.Contract_Number#&' Exisiting Data.xls'>
<cfset sheetName = #url.Contract_Number#&' Data'>

<cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init("#fileName#") />
<cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
<!--- Create a new Worksheet and name it --->
<cfset newSheet = workBook.createSheet() />
<cfset workBook.setSheetName(0, "#sheetName#") />
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
	<cfset cell1.setCellValue("Item") />
	<cfset cell1.setCellStyle(cswrap) />

	<cfset cell3 = row1.createCell(1) />
	<cfset cell3.setCellValue("Description") />
	<cfset cell3.setCellStyle(cs) />

	<cfset cell2 = row1.createCell(2) />
	<cfset cell2.setCellValue("Rate") />
	<cfset cell2.setCellStyle(cs) />

	<cfset cell3 = row1.createCell(3) />
	<cfset cell3.setCellValue("UOM") />
	<cfset cell3.setCellStyle(cs) />

	<cfset cell4 = row1.createCell(4) />
	<cfset cell4.setCellValue("Component") />
	<cfset cell4.setCellStyle(cs) />

	<cfset cell5 = row1.createCell(5) />
	<cfset cell5.setCellValue("Is Group") />
	<cfset cell5.setCellStyle(cs) />

	<cfset cell6 = row1.createCell(6) />
	<cfset cell6.setCellValue("Pricing Level") />
	<cfset cell6.setCellStyle(cs) />

	<cfset RebateCFC = createObject("component","components.programs.rebates.Rebate")>
	<cfset Exisitingdata = RebateCFC.ExistingRecordsReport(url.contract_main_id,tablename,1)/>

	<cfoutput query="Exisitingdata">
		<cfset row2 = newSheet.createRow(#currentRow#) />
		<cfset row2.createCell(0).setCellValue(#item#) />
		<cfset row2.createCell(1).setCellValue(#description#) />
		<cfset row2.createCell(2).setCellValue(#dollarformat(rate)#) />
		<cfset row2.createCell(3).setCellValue(#Abbreviation_Singular#) />
		<cfset row2.createCell(4).setCellValue(#Program_Rebates_Component_Name#) />
		<cfset row2.createCell(5).setCellValue(#Is_Group#) />
		<cfset row2.createCell(6).setCellValue(#Pricing_Level_Id#) />
	</cfoutput>

	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() />
	<cfset variables.fileOutStream.close() />

	 <cfheader name="Content-Disposition" value="attachment;filename=#fileName#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#fileName#" deletefile="true"  />