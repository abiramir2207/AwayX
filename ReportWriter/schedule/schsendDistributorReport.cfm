
<!-----------------showReport.cfm----------------->
<!----------------Set Defaults--------->
<cfset srNotCSV=true>
<!------<cfset rFileName="report_#rID#">----->
<cfset rFileName="#UCase(ReplaceNoCase(ReplaceNoCase(reportType,"summary","_summary")," ","_"))#_#DateFormat(Now(),"mmddyy")#">

<cfif rReportOutputType EQ "e">
	<cfset rFileExtention="xls">
<cfelseif rReportOutputType EQ "c">
	<cfset srNotCSV=false>	
	<cfset rFileExtention="csv">
<cfelse>
	<cfset rFileExtention="html">
</cfif>

<cfsavecontent variable="fileContent">
<cfif reportType EQ "programSummary">
			<CFINCLUDE TEMPLATE="#displayProgram#">
<cfelseif reportType EQ "invoiceprogramSummary">
	<cfif ListFindNoCase(rColumnHeaderID,"FiscalVolume",",")>
		<CFINCLUDE TEMPLATE="#displayInvoiceProgramVolume#">
	<cfelseif ListFindNoCase(rColumnHeaderID,"FiscalExpense",",")>
		<CFINCLUDE TEMPLATE="#displayInvoiceProgramExpense#">
	<cfelseif ListFindNoCase(rColumnHeaderID,"FiscalMargin",",")>
		<CFINCLUDE TEMPLATE="#displayInvoiceProgramMargin#">
	<cfelse>
		<CFINCLUDE TEMPLATE="#displayInvoiceProgramVolume#">
	</cfif>
</cfif>
</cfsavecontent>


<cfif srQuery.recordCount LTE 0>
	<cfset toEmail="#ownerEmail#">
<!--- 	<cfmail to = "#toEmail#"
      from = "#reportFromAddress#"
      subject = "#q_getReportDetails.Report_Name#"
	  type="html"> --->
	  <cfoutput>
	  <cf_EmailWrapper 
	  	to = "#toEmail#"
      	from = "#reportFromAddress#"
      	subject = "#q_getReportDetails.Report_Name#"
	  	type="html" 
		messagetype="1" 
		generatedby="1" 
		apparea="7">
	  <TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		This report (#UCase(reportDescription)#) created by #ownerName# was supposed to be sent to #rEmailAddress#.<BR>
		But was not sent as the report is empty.
		</TD>
		</TR>
		</TABLE>
	<!--- </cfmail> --->
	</cf_EmailWrapper>
	</cfoutput>
	<cfabort>
</cfif>

<CF_Writing_Email_Attachment
  				Naming_Format="Reports_#q_getReportDetails.Report_Name#"
				File_Extension="#rFileExtention#"
				Relative_Path="\Temp_Files\Report\"
				Output_Content="#fileContent#"
				addNewLine="No"
				Return_File_Name="fName"> 

<!-----<cfset toEmail="#ownerEmail#">------->
<cfset toEmail="#rEmailAddress#">
<cfloop index="i" list="#toEmail#" delimiters=";">
<!--- 	<cfmail to = "#Trim(i)#"
      from = "#reportFromAddress#"
      subject = "#q_getReportDetails.Report_Name#"
	  MIMEAttach = "#fName#"
	  type="html"> --->
	  <cfoutput>
	  <cf_EmailWrapper 
	  	to = "#Trim(i)#"
      	from = "#reportFromAddress#"
      	subject = "#q_getReportDetails.Report_Name#"
	  	type="html" 
		messagetype="1" 
		generatedby="1" 
		apparea="7">
		
	   <TABLE WIDTH="100%">
		<TR VALIGN="top">
		<TD>
		See the attached file (#rFileName#)<BR>
	  Report (#UCase(reportDescription)#) created by #ownerName#.
		</TD>
		</TR>
		</TABLE>
		<cf_EmailWrapperParam file="#fName#" store="yes" />
	<!--- </cfmail> --->
	</cf_EmailWrapper>
	</cfoutput>
</cfloop>
<!-----#Report #rID#------->

<!------
<cffile action = "delete" 
  file = "#fName#">
----->