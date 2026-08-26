<!---
  *  @Author: Milan Mushran
  *  @Date: 7/16/2018

	FUNCTIONALITY:
	- Generate an Excel file with the product grpup members.
--->
<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
<cfset ProgramManager = CreateObject("component", "components.programs.ProgramManager")>

<cfparam name="URL.Contract_Main_ID" default="0">
<cfparam name="form.contract_main_id" default="0">

<cfif URL.Contract_Main_ID neq 0>
	<cfset variables.programID = URL.Contract_Main_ID>
<cfelseif form.contract_main_id neq 0>
	<cfset variables.programID = form.contract_main_id>
</cfif>

<cfset qTemplate = templateManager.getProgramTemplate(variables.programID)>
<!--- If "Excel file for product group members" template setting is ON for operators OR distributors
Note: Since we just want the letter to be generated once, we are not looking at whether distributor or operator letter
is being generated.
 --->
<cfif qTemplate.Distributor_Generate_Excel_File_Product_Group_Members eq 1 OR qTemplate.Operator_Generate_Excel_File_Product_Group_Members eq 1>

	<cfset variables.ProductGroupExists = ProgramManager.CheckProductGroupExistsOnProgram(variables.programID)>

	<cfif variables.ProductGroupExists eq 1>

		<cfset objLetterManager = CreateObject("component", "mvc.Models.LetterManager")>
		<cfset qGroupMembers = objLetterManager.getProgramProductGroupMembers(variables.programID)>

		<cfquery name="qProgram" Datasource="#application.datasource#">
			SELECT	Contract_Number, CASE
										WHEN LEN(Contract_Main.revision_version) = 4 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 4)
										WHEN LEN(Contract_Main.revision_version) = 5 THEN RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 5)
										ELSE RIGHT('000' + CAST(Contract_Main.revision_version AS VARCHAR(10)), 3)
									END As Revision_Version
			FROM 	Contract_Main
			WHERE 	Contract_Main_ID = <cfqueryparam value="#variables.programID#" cfsqltype="cf_sql_integer">
		</cfquery> 

		<cfset variables.fileName = "#qProgram.Contract_Number#-#qProgram.Revision_Version#_Product_Group_Members_#dateformat(now(), "mm_dd_yyyy")#"> 
		<cfset variables.fileName = REReplace(variables.fileName,"[^0-9A-Za-z_-]","_","all") >
		<cfset variables.ExcelFileName = "#variables.fileName#.xls">
		<cfset variables.folderPath = "#Application.Doc_Path#\Temp_Files\Program\Letters\#variables.programID#">
		
		<cfif NOT DirectoryExists(variables.folderPath) >
			<cfdirectory action = "create" directory="#variables.folderPath#" />
		</cfif>

		<cfset variables.ExcelFilePath = "#variables.folderPath#\#variables.ExcelFileName#">

		<!--- Create new Excel File using the java.io.FileOutputStream class
			 Then create an instance of the HSSFWorkbook Class based on
			 Apache's POI library which is available at http://poi.apache.org/
		--->
		<cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#variables.ExcelFilePath#) />
		<cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>

		<!--- Create a new Worksheet and name it --->
		<cfset newSheet = workBook.createSheet() />
		<cfset workBook.setSheetName(0, "Members List") />

		<!--- Create a row and the header cell --->
		<cfset row1 = newSheet.createRow(0) />

		<!--- Column 1 --->
		<cfset cell1 = row1.createCell(0) />
		<cfset cell1.setCellValue("Group") />
		<cfset newSheet.setColumnWidth(0, 12000) />

		<!--- Column 2 --->
		<cfset cell2 = row1.createCell(1) />
		<cfoutput><cfset cell2.setCellValue("#application.returned_customer_setting.Item_Label#") /></cfoutput>
		<cfset newSheet.setColumnWidth(1, 7000) />

		<!--- Column 3 --->
		<cfset cell3 = row1.createCell(2) />
		<cfset cell3.setCellValue("Description") />
		<cfset newSheet.setColumnWidth(2, 15000) />

		<cfoutput query="qGroupMembers">	      
		   <cfset newrow = newSheet.createRow(#currentRow#) />
		   <cfset newrow.createCell(0).setCellValue(#Group_Desc#) />
		   <cfset newrow.createCell(1).setCellValue(#Item#) />
		   <cfset newrow.createCell(2).setCellValue(#Description#) />
		</cfoutput>

		<cfset workBook.write(variables.fileOutStream) />
		<cfset variables.fileOutStream.flush() /> 
		<cfset variables.fileOutStream.close() /> 

		
		<cfquery name="qSetFilePath" Datasource="#application.datasource#">
		UPDATE Contract_Main_Aux_Data
		SET Product_Group_Members_File_Path = <cfqueryparam value="#variables.ExcelFilePath#" cfsqltype="cf_sql_varchar">
		WHERE Contract_Main_ID = <cfqueryparam value="#variables.programID#" cfsqltype="cf_sql_integer"> 
		</cfquery> 

		</cfif>
</cfif>