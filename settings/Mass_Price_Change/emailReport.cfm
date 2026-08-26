<cfsilent>
<!---
       Name:          index.cfm
       Copyright:     Copyright (c) 2013 Blacksmith Applications, Inc.
       Created Date:  06/10/2013
       Created By:    Kal
       Label:		  34605
       Description:   Mass Price Change Utility
--->
</cfsilent>


<cfparam name="userEmail" default="1">

<!--- Initiate the CFC --->
<!--- <cfset MPCManager = createObject("component","mvc.Models.Program.Upload.MassPriceChange") /> --->

<cfset qGetProgramReport = MPCManager.getProgramReport() />
<cfset qGetProgramProductReport = MPCManager.getProgramProductReport() />

<cfset fileName = "Mass_Price_Change_Report_" & DateFormat(now(),"yyyy_mm_dd") & ".xlsx" />
<cfset fileNamePath = application.Doc_Path & "\Temp_Files\Report\" & fileName />

<!--- header row --->
<cfset formatHR 			= structNew() />
<cfset formatHR.bgColor  	= "black" />
<cfset formatHR.color 	 	= "white" />
<cfset formatHR.fontSize 	= "9" />
<cfset formatHR.font 		= "Century Gothic" />
<cfset formatHR.bold 		= true />
<cfset formatHR.alignment 	= "center" />

<!--- date row format --->
<cfset formatDate 			 = structNew() />
<cfset formatDate.dataFormat = "mm/dd/yyyy" />

<!--- format data --->
<cfset formatRows.fontSize 	= "9" />
<cfset formatRows.font 		= "Arial" />

<!--- program sheet --->
<cfset excelDoc = spreadSheetNew("Programs_Report", true) />
<cfset headerRow = arrayToList(qGetProgramReport.getMetaData().getColumnLabels()) />
<cfset totalCols = arrayLen(qGetProgramReport.getMetaData().getColumnLabels()) />
<cfset totalRows = qGetProgramReport.recordCount + 1 />
<cfset spreadSheetAddRow(excelDoc, headerRow) />					<!--- header --->
<cfset spreadSheetAddRows(excelDoc, qGetProgramReport) />			<!--- data --->
<cfset spreadSheetFormatRows(excelDoc, formatRows, "1-#totalRows#") />	<!--- format data --->
<cfset spreadSheetAddFreezePane(excelDoc, 0, 1) />			<!--- freeze header row --->
<cfset spreadSheetFormatRow(excelDoc, formatHR, 1) />				<!--- format header row --->
<cfset spreadSheetFormatColumns(excelDoc, formatDate, "4-8") />		<!--- format dates --->


<!--- program product sheet --->
<cfset spreadsheetCreateSheet(excelDoc, "Program_Product_Report")>
<cfset spreadSheetSetActiveSheet(excelDoc, "Program_Product_Report")>
<cfset headerRow = arrayToList(qGetProgramProductReport.getMetaData().getColumnLabels()) />
<cfset totalCols = arrayLen(qGetProgramProductReport.getMetaData().getColumnLabels()) />
<cfset totalRows = qGetProgramProductReport.recordCount + 1 />
<cfset spreadSheetAddRow(excelDoc, headerRow) />					<!--- header --->
<cfset spreadSheetAddRows(excelDoc, qGetProgramProductReport) />	<!--- data --->
<cfset spreadSheetFormatRows(excelDoc, formatRows, "1-#totalRows#") />	<!--- format data --->
<cfset spreadSheetAddFreezePane(excelDoc, 0, 1) />			<!--- freeze header row --->
<cfset spreadSheetFormatRow(excelDoc, formatHR, 1) />				<!--- format header row --->
<cfset spreadSheetFormatColumns(excelDoc, formatDate, "5-6") />		<!--- format dates --->

<!--- write the contents to a file --->
<cfspreadsheet action="write" filename="#fileNamePath#" name="excelDoc" overwrite=true >

<!--- email the userd the report --->
<cfif len(userEmail)>
	<cfinclude template="/get_Contact_Admin_Email_Address.cfm">
	<cf_emailwrapper
		to="#userEmail#"
		from="#Contact_Admin_Email_Address#"
		subject="Mass Price Change Process - Completed"
		type="html"
		messagetype="1"
		generatedby="1"
		apparea="1"
		logMessage="1">

		Mass Price Change Process - Completed; Report attached.<br/><br/>
		A blank report indicates that no programs matched the criteria and none were revised.
		<br/><br/><br/><br/>
		<cf_emailwrapperparam file="#fileNamePath#" store="yes">

	</cf_emailwrapper>
</cfif>

