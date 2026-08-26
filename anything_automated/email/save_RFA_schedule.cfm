<cfparam name="form.rvStartDate" default="">
<cfparam name="form.rvEndDate" default="">
<cfparam name="form.rEmailAddress" default="">
<cfparam name="form.rName" default="">
<cfparam name="form.rInterval" default="">
<cfparam name="form.rStartTime" default="">
<cfinclude template="RFA_report_include.cfm">
<!------------------------Validate--------------------->
<cfset allClear=true>
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
	<cfset daysDiff=Day(getDateFromMMDDYYYYFormat(Form.rvStartDate))-Day(now())>
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

<cfif allClear>

	<!------------------1. Insert into db tables----------------------------->
	<cfif Form.rInterval NEQ "Once">
		<cfset sEndDate="#Right(Form.rvEndDate,4)#/#Left(Form.rvEndDate,2)#/#Mid(Form.rvEndDate,4,2)#">
	<cfelse>
		<cfset sEndDate="">
	</cfif>
	<cfset sStartDate="#Right(Form.rvStartDate,4)#/#Left(Form.rvStartDate,2)#/#Mid(Form.rvStartDate,4,2)#">


<cfquery name="q_ReportTemplateInsert" datasource="#application.datasource#">
			Update 	_application_settings
			Set				
				Report_Name = <cfqueryparam value="#Form.rName#" cfsqltype="CF_SQL_VARCHAR">,
				Report_Start_Date = <cfqueryparam value="#sStartDate#" cfsqltype="CF_SQL_VARCHAR">,
				Report_End_Date <cfif sEndDate EQ "">is null<cfelse> = <cfqueryparam value="#sEndDate#" cfsqltype="CF_SQL_VARCHAR"></cfif> ,
				Report_Start_Time = <cfqueryparam value="#rStartTime#" cfsqltype="CF_SQL_VARCHAR">,
				Report_Interval = <cfqueryparam value="#Form.rInterval#" cfsqltype="CF_SQL_VARCHAR">,
				Send_Report_To = <cfqueryparam value="#Form.rEmailAddress#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfset dStartDate=DateFormat(CreateDate(Right(Form.rvStartDate,4),Left(Form.rvStartDate,2),Mid(Form.rvStartDate,4,2)),"MM/DD/YYYY")>
	<cfif isDefined("form.rvEndDate") and isDate(Form.rvEndDate)>
		<cfset dEndDate=DateFormat(CreateDate(Right(Form.rvEndDate,4),Left(Form.rvEndDate,2),Mid(Form.rvEndDate,4,2)),"MM/DD/YYYY")>
	<cfelse>
		<cfset dEndDate="">
	</cfif>

<cfset scURL="#application.HTTPVar##CGI.HTTP_HOST#/anything_automated/ONLYPUBLICDIRECTORY/email_programs_awaiting_action.cfm">	
		<cfoutput>
		<cfschedule action = "update"
		  task = "RFA_Programs_Awaiting_Action" 
		  operation = "HTTPRequest"
		  url = "#scURL#"
		  startDate = "#dStartDate#"
		  enddate = "#dEndDate#"
		  startTime = "#rStartTime#"
		  interval = "#Form.rInterval#"
		  resolveURL = "Yes"
		  requestTimeOut = "600"></cfoutput>
</cfif>
<CF_MessageWindow>
<CFIF isDefined("sErr")>
	<SCRIPT LANGUAGE="JavaScript">
		showError();		
	</SCRIPT>
<cfelse>
	 <script>
window.close();
</script> 
</CFIF>

