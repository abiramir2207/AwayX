<!---
	Name:
		auto_approve_report.cfm
	Copied By:
		Deepa Kunnath 12/12/2012
	From:
		auto_deviation_report.cfm
	Description:
		File used to generate the auto approve report and send it to recipients defined under email settings
	Label:
		D35466 GM EDI BB Auto Approve Process Overview
--->
<cfquery name="getEmailAddressList" datasource="#application.datasource#">
	SELECT 	General_Settings.Send_Auto_Deviation
	FROM 	General_Settings
</cfquery>

<!---Only send an email notification if we have email addresses--->
<cfif getEmailAddressList.RecordCount and len(trim(getEmailAddressList.Send_Auto_Deviation))>

	<cfparam name="ACCESSSTRUCTURE.USER_ID" 	default="0000000000">
	
	<!--- Get billback labels --->
	<cfset stBillbackLabels = CreateObject("component", "mvc.Models.SettingsService").getBBLabels() />
	
	<cfquery name="qGetAutoDeviations" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmp_auto_approve_bb_list') IS NOT NULL
		DROP TABLE ##tmp_auto_approve_bb_list
		
		SELECT	Billback.Billback_ID,
				Billback.Auto_Deviation_On Run_Date, --Deviation Run Date
				BB_Approved.Date_Approved, --Status Date
				Billback.BB_Code, --Payable Number
				Billback.BB_Reference, --BA Billback Number
				Billback.BB_Amount, --BB_Amt
				Billback_Status.BB_Status_Description, --Status
				ISNULL(CAST((Billback.BB_Amount - Billback.BB_Expected_Amount) * 100 / Billback.BB_Amount as decimal(20, 2)), 0) as Auto_Deviated_Percent, --Deviated Percent
				ISNULL(CAST(Billback.BB_Amount - Billback.BB_Expected_Amount as decimal(20, 2)), 0) as Auto_Deviated_Amt, --Deviated Amount
				CASE
					WHEN Billback.Billback_Payee_Type_ID=1 THEN  
					BSA_Foodservice_Customers.Shr_Ship_To  
					
					WHEN Billback.Billback_Payee_Type_ID=2 THEN
					BSA_Operator.BSA_Operator_ID
				END AS Payee_ID, --BA Payee ID
				CASE
					WHEN Billback.Billback_Payee_Type_ID=1 THEN  
					BSA_Foodservice_Customers.Name  
					
					WHEN Billback.Billback_Payee_Type_ID=2 THEN
					BSA_Operator.Operator_Name
				END AS Payee_Name --Payee_Name,
		INTO	##tmp_auto_approve_bb_list
		FROM	Billback
				INNER JOIN Billback_Status ON
				Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
				INNER JOIN BB_Approved ON
				BB_Approved.Billback_ID = Billback.Billback_ID
				LEFT JOIN	
				(
					Billback_Distributor
					LEFT JOIN BSA_Foodservice_Customers ON 
					(Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID)
				)
				ON
				(
					(Billback_Distributor.Billback_ID = Billback.Billback_ID)
					AND
					(
						(Billback.Billback_Payee_Type_ID = 1)
						OR
						(Billback.Billback_Payee_Type_ID = 5)
					)
					AND
					(Billback_Distributor.Deleted = 0)
				)
				----------------------------------------------------				
				LEFT JOIN	
				(
					Billback_Operator
					LEFT JOIN BSA_Operator ON
					(Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID)
				)
				ON
				(
					(Billback_Operator.Billback_ID = Billback.Billback_ID)
					AND
					(
						(Billback.Billback_Payee_Type_ID = 2)
						OR
						(Billback.Billback_Payee_Type_ID = 6)
					)
					AND
					(Billback_Operator.Deleted = 0)				
				)
		WHERE	Billback.Deleted = 0
		AND		Billback.Auto_Approved = 1
		AND		Billback.Approved_By_Process = 5 -- GM EDI BB Auto Approve Process
		AND		EXISTS (
				SELECT	1
				FROM	BB_Auto_Approve_Log
				WHERE	BB_Auto_Approve_Log.Billback_ID = Billback.Billback_ID
				AND		ISNULL(BB_Auto_Approve_Log.Report_Sent, 0) = 0
				UNION
				SELECT	1
				FROM	DD_Auto_Match_Log
				WHERE	DD_Auto_Match_Log.Billback_ID = Billback.Billback_ID
				AND		ISNULL(DD_Auto_Match_Log.Report_Sent, 0) = 0
				)
	
		SELECT * FROM ##tmp_auto_approve_bb_list
	</cfquery>

	<CFSET DateTimpStamp 	= "#DATEFORMAT(now(),"mm/dd/yyyy")##TIMEFORMAT(now(),"hh:mm:ss")#">
	<CFSET DateTimpStamp 	= REPLACE(DateTimpStamp,"/","","ALL")>
	<CFSET DateTimpStamp 	= REPLACE(DateTimpStamp,":","","ALL")>
	<CFSET fileName 		= "Auto_Approve_#DateTimpStamp#.xls">
	
	<cfset variables.fileOutStream = createObject("java","java.io.FileOutputStream").init("#fileName#") />
	<cfset workBook = createObject("java","org.apache.poi.hssf.usermodel.HSSFWorkbook").init()/>
	<!--- Create a new Worksheet and name it --->
	<cfset newSheet = workBook.createSheet() />
	<cfset workBook.setSheetName(0, "Report") />
	<!--- Creates the default Font --->
	<cfset f = workBook.createFont() />
	<cfset cs = workBook.createCellStyle() />
	<cfset cswrap = workBook.createCellStyle() />
	<cfif isDefined("f.BOLDWEIGHT_BOLD")> <cfset f.setBoldweight(f.BOLDWEIGHT_BOLD)> <cfelse> <cfset f.setBold(true)> </cfif>
	<cfset cs.setFont(f) />
	<cfset cswrap.setFont(f) />
	
	<cfset df = workBook.createDataFormat() />
	
	<cfset dfStyle = workBook.createCellStyle() />
	<cfset dfStyle.setDataFormat(df.getFormat("m/d/yy")) />
	
	<cfset percentStyle = workBook.createCellStyle() />
	<cfset percentStyle.setDataFormat(df.getFormat("0.00%")) />
	
	
	<!--- Create a row and the Header cell --->
	<cfset row1 = newSheet.createRow(0) />
	<!--- Deviation Run Date --->
	<cfset cell1 = row1.createCell(0) />
	<cfset cell1.setCellValue(stBillbackLabels['Deviation'] & " Run Date") /> <!--- Deviation Run Date --->
	<cfset cell1.setCellStyle(cswrap) />
	<!--- Payable Number --->
	<cfset cell2 = row1.createCell(1) />
	<cfset cell2.setCellValue(stBillbackLabels['Payable']) /> <!--- Payable Number --->
	<cfset cell2.setCellStyle(cs) />
	<!--- BA Billback Number --->
	<cfset cell3 = row1.createCell(2) />
	<cfset cell3.setCellValue(stBillbackLabels['Billback'] & " ##") /> <!--- Billback Number --->
	<cfset cell3.setCellStyle(cs) />
	<!--- Billback Amount --->
	<cfset cell4 = row1.createCell(3) />
	<cfset cell4.setCellValue(stBillbackLabels['Claimed'] & " $") /> <!--- Claimed Amount --->
	<cfset cell4.setCellStyle(cs) />
	<!--- Status --->
	<cfset cell5 = row1.createCell(4) />
	<cfset cell5.setCellValue("Status") /> <!--- Status --->
	<cfset cell5.setCellStyle(cs) />
	<!--- Status Date --->
	<cfset cell6 = row1.createCell(5) />
	<cfset cell6.setCellValue("Status Date") /> <!--- Status Date --->
	<cfset cell6.setCellStyle(cswrap) />
	<!--- Deviated Percent --->
	<cfset cell7 = row1.createCell(6) />
	<cfset cell7.setCellValue(stBillbackLabels['Deviation'] & " %") /> <!--- Deviation Deviation --->
	<cfset cell7.setCellStyle(cs) />
	<!--- Deviated Amount --->
	<cfset cell8 = row1.createCell(7) />
	<cfset cell8.setCellValue(stBillbackLabels['Deviation'] & " Amount") /> <!--- Deviation Amount --->
	<cfset cell8.setCellStyle(cs) />
	<!--- BA Payee ID --->
	<cfset cell9 = row1.createCell(8) />
	<cfset cell9.setCellValue(stBillbackLabels['Payee'] & " ID") /> <!--- Payee ID --->
	<cfset cell9.setCellStyle(cs) />
	<!--- Payee Name --->
	<cfset cell10 = row1.createCell(9) />
	<cfset cell10.setCellValue(stBillbackLabels['Payee'] & " Name") /> <!--- Payee Name --->
	<cfset cell10.setCellStyle(cs) />


	<cfoutput>
	<cfloop query="qGetAutoDeviations">
		<cfset varirable.thisCurrentRow = newSheet.createRow(#currentRow#) />
		
		<cfset varirable.thisCurrentRow.createCell(0).setCellValue(#dateFormat(trim(Run_Date), "mm/dd/yyyy")#) />
		<cfset varirable.thisCurrentRow.getCell(0).setCellStyle(dfStyle) />
		<cfset varirable.thisCurrentRow.createCell(1).setCellValue(#trim(BB_Code)#) />
		<cfset varirable.thisCurrentRow.createCell(2).setCellValue(#trim(BB_Reference)#) />
		<cfset varirable.thisCurrentRow.createCell(3).setCellValue(#NumberFormat(trim(BB_Amount), "$9.__")#) />
		<cfset varirable.thisCurrentRow.createCell(4).setCellValue(#trim(BB_Status_Description)#) />
		<cfset varirable.thisCurrentRow.createCell(5).setCellValue(#dateFormat(trim(Date_Approved), "mm/dd/yyyy")#) />
		<cfset varirable.thisCurrentRow.getCell(5).setCellStyle(dfStyle) />
		<cfset varirable.thisCurrentRow.createCell(6).setCellValue(#NumberFormat(trim(Auto_Deviated_Percent), "9.__")# & "%") />
		<cfset varirable.thisCurrentRow.getCell(6).setCellStyle(percentStyle) />
		<cfset varirable.thisCurrentRow.createCell(7).setCellValue(#NumberFormat(Auto_Deviated_Amt, "$9.__")#) />
		<cfset varirable.thisCurrentRow.createCell(8).setCellValue(#trim(Payee_ID)#) />
		<cfset varirable.thisCurrentRow.createCell(9).setCellValue(#trim(ReplaceNoCase(Payee_Name, ",", ""))#) />
	</cfloop>
	</cfoutput>
	
	<cfset workBook.write(variables.fileOutStream) />
	<cfset variables.fileOutStream.flush() /> 
	<cfset variables.fileOutStream.close() /> 


	<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
	
	<!--- Send email --->
	<CF_EMAILWRAPPER 
		TO			=	"#trim(getEmailAddressList.Send_Auto_Deviation)#"
		FROM		=	"#Contact_Admin_Email_Address#"
		SUBJECT		=	"Auto Approve Report (#application.returned_customer_setting.Company_Name#)"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="1"
		appArea="1"
	>
	
		<cf_emailwrapperparam file = "#fileName#" store="no" />
		
	</CF_EMAILWRAPPER>

	<!--- Update sent flag --->
	<cfquery name="qUpdateReportSentFlag" datasource="#application.datasource#">
		UPDATE	BB_Auto_Approve_Log
		SET		Report_Sent = 1
		FROM	BB_Auto_Approve_Log
		INNER JOIN ##tmp_auto_approve_bb_list
		ON		##tmp_auto_approve_bb_list.Billback_ID = BB_Auto_Approve_Log.Billback_ID
	</cfquery>
	
		<cfquery name="qUpdateReportSentFlag" datasource="#application.datasource#">
		UPDATE	DD_Auto_Match_Log
		SET		Report_Sent = 1
		FROM	DD_Auto_Match_Log
		INNER JOIN ##tmp_auto_approve_bb_list
		ON		##tmp_auto_approve_bb_list.Billback_ID = DD_Auto_Match_Log.Billback_ID
	</cfquery> 

	
	Auto Approve Report email Sent
	
</cfif>


