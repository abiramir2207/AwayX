
<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="reportInclude.cfm">
</CFIF>
<cfset fromInvoiceReportSaveAction=true>
<CFPARAM NAME="Form.rName" DEFAULT="">
<CFPARAM NAME="Form.rStartDate" DEFAULT="">
<CFPARAM NAME="Form.rEndDate" DEFAULT="">
<CFPARAM NAME="Form.rStartTime" DEFAULT="">
<CFPARAM NAME="Form.rInterval" DEFAULT="">
<CFPARAM NAME="Form.rEmailAddress" DEFAULT="">

<CFSET userID=request.AccessStructure.user_id>
<cfif isDefined("form.reporttype") and form.reporttype EQ "programPerformance">
	<cfset Form.rInvoiceReportType = "ProgramPerformance">
</cfif>

<cfif Not isDefined("Form.rInvoiceReportType")>
	<cfset Form.rInvoiceReportType = "InvoiceVolume">
</cfif>

<cfif Not isDefined("Form.company_main_id") >
	<cfset Form.company_main_id = request.AccessStructure.company_main_id >
</cfif>

<!------------------------Validate--------------------->
<cfset allClear=true>

<!---------------------Validate ID ------------------------->
<CFIF isDefined("Form.rID")>
	<cfif NOT isNumeric(Form.rID)>
		<cfset allClear=false>
	</cfif>
	<cfset dbAction="edit">
<CFELSE>
	<cfset dbAction="add">
</CFIF>
<!--------------------- End Validate ID ------------------------->

<!---------------------Validate Name------------------------->
<cfif Trim(Form.rName) EQ "">
	<cfset allClear=false>
	<cfset writeToErrorMessage("Invalid Report Name","error_ReportName")>
</cfif>

<!---------------------End Validate Name------------------------->

<!---------------------Validate StartDate------------------------->
<cfset dTrue=true>
<cfset daysDiff=0>
<cfif isDateValid(Form.rvStartDate) EQ "Yes">
 	<!---------------------Validate Start Date against web server current date------------------------->
	<cfset daysDiff=Day(getDateFromMMDDYYYYFormat(Form.rvStartDate))-Day(thisDate)>
	<cfif daysDiff LT 0>
		<cfset allClear=false>
		<cfset writeToErrorMessage("Start Date should be greater than today","error_Start_Date")>
		<cfset dTrue=false>
	</cfif>
 <cfelse>
 	<cfset allClear=false>
	<cfset writeToErrorMessage("Invalid Start Date","error_Start_Date")>
	<cfset dTrue=false>
 </cfif>

<!---------------------End Validate StartDate------------------------->

<!---------------------Validate EndDate------------------------->

<cfif Form.rInterval NEQ "once">	
	<cfif isDateValid(Form.rvEndDate)>
		<cfif dTrue>
			<cfif DateDiff("d", getDateFromMMDDYYYYFormat(Form.rvStartDate),getDateFromMMDDYYYYFormat(Form.rvEndDate)) LT 0>
				<cfset allClear=false>
				<cfset writeToErrorMessage("End Date should be greater than Start Date","error_End_Date")>
			</cfif>
		</cfif>
	<cfelse>
		<cfset allClear=false>
		<cfset writeToErrorMessage("Invalid End Date","error_End_Date")>
	</cfif>	
</cfif>

<!---------------------End Validate EndDate------------------------->


<!-------------------------- Validate time ----------------------->

<cfset rStartTime = getMilitaryTime(Form.rStartTime)>
<cfif daysDiff EQ 0>	
	<cfset aStartTime=ListToArray(rStartTime,":")>
	<cfset rThisTime=timeformat(DateAdd('n',timeIncr,Now()), 'HH:mm:ss')>
	<cfset aThisTime=ListToArray(rThisTime,":")>
	<cfif checkTimelessThan(aStartTime,aThisTime)>
		<cfset allClear=false>
		<cfset writeToErrorMessage("Time should be greater than " & rThisTime & " if you select Start Date as today","error_Start_Time")>
	</cfif>
</cfif>

<!-------------------------- End Validate time ----------------------->

<!--------------------------- Validate Email Address ---------------------->
<cfif Len(Form.rEmailAddress) GT 0>
	<cfset validEmail = makeValidEmails(Form.rEmailAddress)>
	<cfif validEmail NEQ "">
		<cfset allClear=false>
		<cfset writeToErrorMessage("Invalid Email Address " & validEmail,"error_Email_Address")>
	<cfelseif Len(Form.rEmailAddress) GTE 3000>
		<cfset allClear = false>
		<cfset writeToErrorMessage("Email Address exceeds available size limit 3000","error_Email_Address")>
	</cfif>
<cfelse>
	<cfset allClear = false>
	<cfset writeToErrorMessage("Invalid Email Address","error_Email_Address")>
</cfif>

<!--------------------------- End Validate Email Address ---------------------->
<!------------------------End Validate--------------------->

<!---------------------  create report structure --------------------------->
<CFSET sSql="">
<CFOUTPUT>
	<cfloop collection=#form# item="myItem">
		<cfset report_structure_name = trim(myItem) >
		<cfset report_structure_value = #Evaluate('form.' & trim(myItem))# >
		<cfif report_structure_value EQ "">
			<cfset report_structure_value = "none" >
		</cfif>
		<cfif trim(myItem) NEQ "">
			<cfif Ucase(trim(myItem)) NEQ "FIELDNAMES">
				<CFIF dbAction EQ "edit">
					<cfset sSql="#sSql#UPDATE Report_Structure SET Report_Structure_Value='#report_structure_value#' WHERE Report_Type_ID=#Form.rID# and Report_Structure='#report_structure_name#';">
				<CFELSE>
					<CFSET sSql="#sSql#INSERT INTO Report_Structure(Report_Type_ID,Report_Structure,Report_Structure_Value) VALUES(--Report_Type_ID--,'#report_structure_name#','#report_structure_value#');">
				</CFIF>
			</cfif>
		<cfelse>
			<cfset allClear = false>
		</cfif>
	</cfloop>
</CFOUTPUT>

<!---------------------  End create report structure --------------------------->

<!------------------- Do some action ------------------->
<cfoutput>
<cfif allClear>
	All clear
	<!-----------------
	Steps
	1. Insert into db tables - Report_Type, Report_Structure, Report_Template
	2. schedule cfm using cfschedule to send mail
	3. redirect to next page
	---------------------->
	
	<!------------------1. Insert into db tables----------------------------->
	<cfif Form.rInterval NEQ "Once">
		<cfset sEndDate="#Right(Form.rvEndDate,4)#/#Left(Form.rvEndDate,2)#/#Mid(Form.rvEndDate,4,2)#">
	<cfelse>
		<cfset sEndDate="">
	</cfif>
	<cfset sStartDate="#Right(Form.rvStartDate,4)#/#Left(Form.rvStartDate,2)#/#Mid(Form.rvStartDate,4,2)#">
	<cfset commited=false>
	<cfdump var = #dbAction#>
	<cfif dbAction EQ "edit">
		<cftransaction action = "begin">
		<cftry>	
	 
		<cfquery name="q_ReportInsert" datasource="#application.datasource#">
			Update	Report_Type		
			Set		Report_Type='#Form.rInvoiceReportType#', user_ID='#userID#'
			Where	Report_Type_ID=#Form.rID#
		</cfquery>

		<cfset Report_TypeID=Form.rID>
		
		<cfquery name="q_ReportStructureInsert" datasource="#application.datasource#">
			#preserveSingleQuotes(sSql)#
		</cfquery>
		
		<cfquery name="q_ReportTemplateInsert" datasource="#application.datasource#">
			Update 	Report_Template
			Set				
				Report_Name='#Form.rName#',
				Report_StartDate='#sStartDate#',
				Report_EndDate='#sEndDate#',
				Report_StartTime='#rStartTime#',
				Report_Interval='#Form.rInterval#',
				Report_EmailAddress='#Form.rEmailAddress#'
			Where	Report_Type_ID=#Report_TypeID#
		</cfquery>
		
		
		<cftransaction action = "commit"/>
		<cfset commited=true>
		
			<!------<cfcatch type = "DATABASE">---->
			<cfcatch>
	    		<cftransaction action = "rollback"/>
					<P>#cfcatch.message#</P>
			</cfcatch>	
		</cftry>
		</cftransaction>
	<cfelseif dbAction EQ "add">
		
		<cftransaction action = "begin">
		<cftry>	
	  
		<cfquery name="q_ReportInsert" datasource="#application.datasource#">
			SET NOCOUNT ON
			insert into 	Report_Type		
				(Report_Type,user_ID)
			Values
				('#Form.rInvoiceReportType#','#userID#')
			SELECT Report_TypeID = @@IDENTITY
			SET NOCOUNT OFF
		</cfquery>
		<cfset Report_TypeID=q_ReportInsert.Report_TypeID>

		<cfset sSql=ReplaceNoCase(sSql,"--Report_Type_ID--",Report_TypeID,"All")>
		
		<cfquery name="q_ReportStructureInsert" datasource="#application.datasource#">
			#preserveSingleQuotes(sSql)#
		</cfquery>
		
	
		<cfquery name="q_ReportTemplateInsert" datasource="#application.datasource#">
			Insert into Report_Template
				(Report_Type_ID,Report_Name,Report_StartDate,Report_EndDate,Report_StartTime,Report_Interval,Report_EmailAddress)
			Values
				(#Report_TypeID#,'#Form.rName#','#sStartDate#','#sEndDate#','#rStartTime#','#Form.rInterval#','#Form.rEmailAddress#')
		</cfquery>

		<cftransaction action = "commit"/>
		<cfset commited=true>
		
			<!------<cfcatch type = "DATABASE">---->
			<cfcatch>
	    		<cftransaction action = "rollback"/>
					<P>#cfcatch.message#</P>
			</cfcatch>	
		</cftry>
		</cftransaction>
	</cfif>
	
	<!------------------ 1. Schedule the file ------------------------------------>

	<cfset thisPath="#Application.Doc_Path#\data_files\created\reportwriter\schedule\saveReports\">
	<!--- pass over the form item into the scheduled form--->
	<cfset scURL="#application.HTTPVar##CGI.HTTP_HOST#/ReportWriter/schedule/schInvoiceAction.cfm">
	<cfset scURL="#application.HTTPVar##CGI.HTTP_HOST#/ReportWriter/schedule/schReport.cfm?rID=#Report_TypeID#">
	
	<cfset dStartDate=DateFormat(CreateDate(Right(Form.rvStartDate,4),Left(Form.rvStartDate,2),Mid(Form.rvStartDate,4,2)),"MM/DD/YYYY")>
	<cfif isDefined("form.rvEndDate") and isDate(Form.rvEndDate)>
		<cfset dEndDate=DateFormat(CreateDate(Right(Form.rvEndDate,4),Left(Form.rvEndDate,2),Mid(Form.rvEndDate,4,2)),"MM/DD/YYYY")>
	<cfelse>
		<cfset dEndDate="">
	</cfif>
	<!---put the time stamp in the task name--->
	<cfif form.reporttype NEQ "programPerformance" >
		<cfset invoiceDateArray = ListToArray(form.invoicedate, "/") >
		<cfif isDefined("Form.rName") and Form.rName NEQ "" >
			<cfset task_name = Form.rName >
		<cfelse>
			<cfset task_name = "Invoice_Volume_Report_">
		</cfif>
	<cfelse>
		<cfif isDefined("Form.rName") and Form.rName NEQ "" >
			<cfset task_name = Form.rName >
		<cfelse>
			<cfset task_name = "Program_Performance_Indicator_">
		</cfif>
	</cfif>
	<cfif form.reporttype NEQ "programPerformance" >
		<cfset task_name = "#task_name#_" & invoiceDateArray[1] & "_" & invoiceDateArray[2] & "_" & invoiceDateArray[3] >
	<cfelse>
		<cfset task_name = "#task_name#_" & Dateformat(now(), "mm_dd_yyyy") >
	</cfif>
	<!---
		D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
		Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
		"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
	--->	
	<cfschedule action = "update"
	  task = "#task_name#" 
	  operation = "HTTPRequest"
	  url = "#scURL#"
	  startDate = "#dStartDate#"
	  enddate = "#dEndDate#"
	  startTime = "#rStartTime#"
	  interval = "#Form.rInterval#"
	  resolveURL = "Yes"
	  publish = "Yes"
	  file = "scReport_#task_name#.log"	<!--- D57544 --->
	  path = "#thisPath#"
	  username = "#rUserName#"
	  password = "#rPassword#"
	  requestTimeOut = "600">
	<!------------------ 2. End Schedule the file ------------------------------------>
	<!--- temporarily comment it out --->
	<cfif Not isDefined("thisFormName")>
		<cfset thisFormName = "MyInvoiceForm" >
	</cfif>
	<!--- <cfdump var = #form#> --->
	<cfset session.form = StructNew() >
	<cfoutput>
		<cfloop collection=#FORM# item="myItem">
			<cfoutput>
				<cfset "session.form.#trim(myItem)#"  = "#Evaluate('FORM.' & trim(myItem))#" >
			</cfoutput>
		</cfloop>
	</cfoutput>
	<cfif form.reporttype NEQ "programPerformance" >
		<cfset thisFileName = "/reportWriter/reportinvoice.cfm">
	<cfelse>
		<cfset thisFileName = "/Common_Files/Performance_Indicators/progPerfIndicator.cfm">
	</cfif>
	<CFLOCATION url="#thisFileName#?rID=#Report_TypeID#&action=#dbAction#" ADDTOKEN=false> 
	<!------------------End 3. Redirect to next page ----------------------------->
<cfelse>
	<cfset sErr=true>
	<cfset action = #dbAction#>
	<cfif form.reporttype NEQ "programPerformance" >
		<cfinclude template="/reportWriter/reportinvoice.cfm">
	<cfelse>
		<cfinclude template="/Common_Files/Performance_Indicators/progPerfIndicator.cfm">
	</cfif>
</cfif>
</cfoutput>
<!------------------- End Do some action ------------------->

