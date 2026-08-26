<!---
	Copyright (c)2013 Blacksmith Applications, Inc.
	Filename:		C:\Work\base\AwayX\Program_Wizard\EZ_button_rates.cfm
	Created:		2/26/2013
	Developer:		drachala
	Description:	Used to download EZ button groups, items, rates
--->
<cfparam name="url.TemplateID" default="0">

<cfif (isDefined("URL.TemplateID") AND URL.TemplateID NEQ 0)>
	<cfset EZInfo = CreateObject("component","components.programs.template.TemplateManager").EZratesExcel(url.TemplateID) >
	
	<cfset useLakebaseForTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForTemplateInfo>
	<cftry>
		<cfset TemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#url.TemplateID#",
				"select" = "created_type"
			}), "created_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForTemplateInfo>
<cfquery name="TemplateInfo" datasource="#application.datasource#">
		SELECT Created_Type
		FROM Program_Control_Panel_Options
		WHERE ProgramControl_Panel_Options_ID = #url.TemplateID#
	</cfquery>
</cfif>

	<cfoutput>
		<!---D41067 :: Unable to Download Max Case Rates - EZ Button...  --->
		<cfset ExcelName  = #REReplace(TemplateInfo.Created_Type,"[^0-9A-Za-z]","","all")#>
		<cfset ExcelName  = "#trim(ExcelName)#.xls">
	</cfoutput>
<cfelseif isDefined("URL.EZButtonRateID")>
	<cfset EZInfo = CreateObject("component","components.programs.template.TemplateManager").EZRatesSettingExcel(url.EZButtonRateID) >
	
	<cfset useLakebaseForEZButtonInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ez_button_rate_setting")>
<cfif useLakebaseForEZButtonInfo>
	<cftry>
		<cfset EZButtonInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ez_button_rate_setting", {
				"ez_button_rate_id" = "eq.#url.EZButtonRateID#",
				"select" = "ez_button_rate_title"
			}), "ez_button_rate_title"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForEZButtonInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForEZButtonInfo>
<cfquery name="EZButtonInfo" datasource="#application.datasource#">
		SELECT EZ_Button_Rate_Title
		FROM EZ_Button_Rate_Setting
		WHERE EZ_Button_Rate_ID = #url.EZButtonRateID#
	</cfquery>
</cfif>
	<cfoutput>
		<!---D41067 :: Unable to Download Max Case Rates - EZ Button...  --->
		<cfset ExcelName  = #REReplace(EZButtonInfo.EZ_Button_Rate_Title,"[^0-9A-Za-z]","","all")#>
		<cfset ExcelName  = "#trim(ExcelName)#.xls">
	</cfoutput>
</cfif>	

      <cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init(#ExcelName#) />
	  <cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	  <!--- Create a new Worksheet and name it --->
	  <cfset newSheet = workBook.createSheet() />
      <cfset workBook.setSheetName(0, "EZ Button Products Info") />
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
	  <cfif isDefined("URL.TemplateID") AND URL.TemplateID NEQ 0>
			<cfset cell1.setCellValue("Template Name") />
	    	<cfset cell1.setCellStyle(cswrap) />
	  <cfelseif isDefined("URL.EZButtonRateID")>
			<cfset cell1.setCellValue("EZ Rate Title") />
	    	<cfset cell1.setCellStyle(cswrap) />	
	  </cfif>
      <cfset cell2 = row1.createCell(1) />
      <cfset cell2.setCellValue("Group ID") />
      <cfset cell2.setCellStyle(cs) />

      <cfset cell3 = row1.createCell(2) />
      <cfset cell3.setCellValue("Group Description") />
      <cfset cell3.setCellStyle(cs) />

      <cfset cell4 = row1.createCell(3) />
      <cfset cell4.setCellValue("Item ID") />
      <cfset cell4.setCellStyle(cs) />

      <cfset cell5 = row1.createCell(4) />
      <cfset cell5.setCellValue("Item Description") />
      <cfset cell5.setCellStyle(cs) />

      <cfset cell6 = row1.createCell(5) />
      <cfset cell6.setCellValue("Rate") />
      <cfset cell6.setCellStyle(cs) />

      <cfset cell7 = row1.createCell(6) />
      <cfset cell7.setCellValue("UOM") />
      <cfset cell7.setCellStyle(cs) />

     <cfoutput>

		<cfloop query="EZInfo">
			<cfset row2 = newSheet.createRow(#currentRow#) />
			<cfif isDefined("URL.TemplateID") AND URL.TemplateID NEQ 0>
				<cfset row2.createCell(0).setCellValue(#Created_Type#) />
			<cfelseif isDefined("URL.EZButtonRateID")>
				<cfset row2.createCell(0).setCellValue(#EZ_Button_Rate_Title#) />
			</cfif>
			<cfset row2.createCell(1).setCellValue(#Group_ID#) />
			<cfset row2.createCell(2).setCellValue(#Group_Desc#) />
			<cfset row2.createCell(3).setCellValue(#Item_ID#) />
			<cfset row2.createCell(4).setCellValue(#Item_Desc#) />
			<cfset row2.createCell(5).setCellValue(#rate#) />
			<cfset row2.createCell(6).setCellValue(#Abbreviation#) />
	 	</cfloop>
    </cfoutput>

	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() />
	<cfset variables.fileOutStream.close() />

	 <cfheader name="Content-Disposition" value="attachment;filename=#ExcelName#"  />
	 <cfcontent type="application/vnd.ms-excel" file="#ExcelName#" deletefile="true"  />