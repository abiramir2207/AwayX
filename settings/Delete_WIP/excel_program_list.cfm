<!---
	Copyright (c)2014 Blacksmith Applications, Inc.
	Filename:		C:\Work\base\AwayX\Settings\Delete_WIP\excel_program_list.cfm
	Created:		1/24/2014
	Developer:		Milan
	Description:	Create Excel document for list of programs to be purged.
--->

<cfparam name="url.purgeDate" default="">
	<!--- NOTE:
		If you change the conditions in this query, you will need to change it on "confirm_deletion.cfm" and "execute_deletion.cfm" also.
	--->
<cfquery name="programList" datasource="#application.datasource#">
	SELECT Contract_Main.Contract_Number,Contract_Main.Contract_Title,Program_Control_Panel_Options.Created_Type,
	_Users.Name_First + ' ' + _Users.Name_Last As RSP,CONVERT(char(10),Contract_Main.Contract_Start_Date,101) As Contract_Start_Date,
	CONVERT(char(10),Contract_Main.Contract_End_Date,101) As Contract_End_Date, 
	CASE Contract_Main.Deleted 
		WHEN 1
			THEN 'Yes'
		ELSE
			'No'
	END
		As 'Deleted'
			
	FROM 
		Contract_Main
	LEFT JOIN Program_Control_Panel_Options
		ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	LEFT JOIN _Users
		ON _Users.User_ID = Contract_Main.Responsible_User_ID	
	WHERE Contract_Main.Contract_Created_Date <= #url.purgeDate#
	AND Contract_Main.Contract_Status_Type_IDX = 1
	AND contract_Number NOT LIKE '%TMP_PRG%'
	ORDER BY Contract_Main.Deleted Desc
</cfquery>


	<cfset ExcelName  = "deleteProgramsList.xls">


      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#ExcelName#) />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "program list") />
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

      <cfset cell1.setCellValue("Program Number") />
      <cfset cell1.setCellStyle(cswrap) />

      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("Program Title") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Template Name") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("RSP") />
      <cfset cell4.setCellStyle(cs) />

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Program Start Date") />
      <cfset cell5.setCellStyle(cs) />

      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Program End Date") />
      <cfset cell6.setCellStyle(cs) />

      <cfset cell7 = row1.createCell(6) />
      <cfset cell7.setCellValue("Already Deleted") />
      <cfset cell7.setCellStyle(cs) />

     <cfoutput>
      <cfloop query="programList">
			   <cfset row2 = newSheet.createRow(#currentRow#) />

			   <cfset row2.createCell(0).setCellValue(#Contract_Number#) />
			   <cfset row2.createCell(1).setCellValue(#Contract_Title#) />
			   <cfset row2.createCell(2).setCellValue(#Created_Type#) />
			   <cfset row2.createCell(3).setCellValue(#RSP#) />
			   <cfset row2.createCell(4).setCellValue(#Dateformat(Contract_Start_Date,'MM/DD/YYYY')#) />
			   <cfset row2.createCell(5).setCellValue(#Dateformat(Contract_End_Date,'MM/DD/YYYY')#) />
			   <cfset row2.createCell(6).setCellValue(#Deleted#) />
	 </cfloop>
    </cfoutput>

	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() />
	<cfset variables.fileOutStream.close() />

	 <cfheader name="Content-Disposition" value="attachment;filename=#ExcelName#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#ExcelName#" deletefile="true" />