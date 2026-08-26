<!---
	Name:
		auto_deviation_report.cfm
	Created By:
		Tim Ford 06/24/2008
	Description:
		File used to generate the auto deviation report and send it to recipients defined under email settings
--->

<cfparam name="ACCESSSTRUCTURE.USER_ID" 	default="0000000000">

<cfquery name="qGetAutoDeviations" datasource="#application.datasource#">
	SELECT	Billback.Auto_Deviation_On Run_Date, --Deviation Run Date
			Billback.BB_Code, --Payable Number
			Billback.BB_Reference, --BA Billback Number
			Billback.BB_Amount, --BB_Amt
			Billback_Status.BB_Status_Description, --Status
			ISNULL(Billback.Auto_Deviated_Percent, 0) AS Auto_Deviated_Percent, --Deviated Percent
			ISNULL(Billback.Auto_Deviated_Amt, 0) AS Auto_Deviated_Amt, --Deviated Amount
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
	FROM	Billback
			INNER JOIN Billback_Status ON
			Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
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
	WHERE	Billback.Auto_Deviation_On IS NOT NULL
	AND		DateDiff(day, Billback.Auto_Deviation_On, getDate()) = 1

</cfquery>

<CFSET DateTimpStamp 	= "#DATEFORMAT(now(),"mm/dd/yyyy")##TIMEFORMAT(now(),"hh:mm:ss")#">
<CFSET DateTimpStamp 	= REPLACE(DateTimpStamp,"/","","ALL")>
<CFSET DateTimpStamp 	= REPLACE(DateTimpStamp,":","","ALL")>
<CFSET fileName 		= "Auto_Deviations_#DateTimpStamp#.xls">

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
<cfset cell1.setCellValue("Deviation Run Date") />
<cfset cell1.setCellStyle(cswrap) />
<!--- Payable Number --->
<cfset cell2 = row1.createCell(1) />
<cfset cell2.setCellValue("Payable Number") />
<cfset cell2.setCellStyle(cs) />
<!--- BA Billback Number --->
<cfset cell3 = row1.createCell(2) />
<cfset cell3.setCellValue("BA Billback Number") />
<cfset cell3.setCellStyle(cs) />
<!--- Billback Amount --->
<cfset cell4 = row1.createCell(3) />
<cfset cell4.setCellValue("Billback Amount") />
<cfset cell4.setCellStyle(cs) />
<!--- Status --->
<cfset cell5 = row1.createCell(4) />
<cfset cell5.setCellValue("Status") />
<cfset cell5.setCellStyle(cs) />
<!--- Deviated Percent --->
<cfset cell6 = row1.createCell(5) />
<cfset cell6.setCellValue("Deviated Percent") />
<cfset cell6.setCellStyle(cs) />
<!--- Deviated Amount --->
<cfset cell7 = row1.createCell(6) />
<cfset cell7.setCellValue("Deviated Amount") />
<cfset cell7.setCellStyle(cs) />
<!--- BA Payee ID --->
<cfset cell8 = row1.createCell(7) />
<cfset cell8.setCellValue("BA Payee ID") />
<cfset cell8.setCellStyle(cs) />
<!--- Payee Name --->
<cfset cell9 = row1.createCell(8) />
<cfset cell9.setCellValue("Payee Name") />
<cfset cell9.setCellStyle(cs) />


<cfoutput>
<cfloop query="qGetAutoDeviations">
	<cfset varirable.thisCurrentRow = newSheet.createRow(#currentRow#) />
	
	<cfset varirable.thisCurrentRow.createCell(0).setCellValue(#dateFormat(trim(Run_Date), "mm/dd/yyyy")#) />
	<cfset varirable.thisCurrentRow.getCell(0).setCellStyle(dfStyle) />
	<cfset varirable.thisCurrentRow.createCell(1).setCellValue(#trim(BB_Code)#) />
	<cfset varirable.thisCurrentRow.createCell(2).setCellValue(#trim(BB_Reference)#) />
	<cfset varirable.thisCurrentRow.createCell(3).setCellValue(#NumberFormat(trim(BB_Amount), "$9.__")#) />
	<cfset varirable.thisCurrentRow.createCell(4).setCellValue(#trim(BB_Status_Description)#) />
	<cfset varirable.thisCurrentRow.createCell(5).setCellValue(#NumberFormat(trim(Auto_Deviated_Percent), "9.__")# & "%") />
	<cfset varirable.thisCurrentRow.getCell(5).setCellStyle(percentStyle) />
	<cfset varirable.thisCurrentRow.createCell(6).setCellValue(#NumberFormat(Auto_Deviated_Amt, "$9.__")#) />
	<cfset varirable.thisCurrentRow.createCell(7).setCellValue(#trim(Payee_ID)#) />
	<cfset varirable.thisCurrentRow.createCell(8).setCellValue(#trim(ReplaceNoCase(Payee_Name, ",", ""))#) />
</cfloop>
</cfoutput>

<cfset workBook.write(variables.fileOutStream) />
<cfset variables.fileOutStream.flush() /> 
<cfset variables.fileOutStream.close() /> 

<cfset useLakebaseForgetEmailAddressList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetEmailAddressList>
	<cftry>
		<cfset getEmailAddressList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "send_auto_deviation"
			}), "send_auto_deviation"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetEmailAddressList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetEmailAddressList>
<cfquery name="getEmailAddressList" datasource="#application.datasource#">
	SELECT 	General_Settings.Send_Auto_Deviation
	FROM 	General_Settings
</cfquery>
</cfif>

<!---Only send an email notification if we have email addresses--->
<cfif getEmailAddressList.RecordCount and len(trim(getEmailAddressList.Send_Auto_Deviation))>

	<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
	
	<CF_EMAILWRAPPER 
		TO			=	"#trim(getEmailAddressList.Send_Auto_Deviation)#"
		FROM		=	"#Contact_Admin_Email_Address#"
		SUBJECT		=	"Auto Deviation Report"
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="1"
		appArea="1"
	>
	
		<cf_emailwrapperparam file = "#fileName#" store="no" />
		
	</CF_EMAILWRAPPER>
	
</cfif>


