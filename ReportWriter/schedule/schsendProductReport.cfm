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

<!--- <cfoutput>#rColumnHeaderID# - #displayInvoiceProductExpense#</cfoutput><cfabort> --->

<cfsavecontent variable="fileContent">

<cfif reportType EQ "productSummary">
			<CFINCLUDE TEMPLATE="#displayProduct#">
<cfelseif reportType EQ "invoiceproductSummary">
	<cfif checkcolheader is "fiscalVolume">
		<CFINCLUDE TEMPLATE="#displayInvoiceProductVolume#">
	<cfelseif checkcolheader is "fiscalExpense">
		<CFINCLUDE TEMPLATE="#displayInvoiceProductExpense#">
	<cfelseif checkcolheader is "fiscalMargin">
		<CFINCLUDE TEMPLATE="#displayInvoiceProductMargin#">
	<cfelse>
		<CFINCLUDE TEMPLATE="#displayInvoiceProductVolume#">
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
	 <cf_EmailWrapper to = "#Trim(i)#"
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
		<cf_EmailWrapperparam file="#fName#" store="yes" />
	<!--- </cfmail> --->
	</cf_EmailWrapper>
</cfloop>

<!------
<cffile action = "delete" 
  file = "#fName#">
----->