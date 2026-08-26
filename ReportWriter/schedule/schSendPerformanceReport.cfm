<!-----------------showReport.cfm----------------->
<!----------------Set Defaults--------->
<cfoutput>
	<cfif Not isDefined("reportDescription") >
		<cfset reportDescription = "#q_getReportDetails.REPORT_NAME# scheduled to run at #q_getReportDetails.REPORT_STARTTIME#, #replace(q_getReportDetails.REPORT_STARTDATE,'/','-','all')# " >
	</cfif>
	<cfset srNotCSV=true>  
	<cfset rFileExtention = "html">
	<cfset rFileName="#UCase(ReplaceNoCase(ReplaceNoCase(reportType,"summary","_summary")," ","_"))#_#DateFormat(Now(),"mmddyy")#">
	<!---
	<cfset fName="#GetDirectoryFromPath(ExpandPath("saveReports/"))##rFileName#." & #rFileExtention#>
	--->
	<cfset fName="#Application.Doc_Path#\data_files\created\ReportWriter\Schedule\saveReports#rFileName#." & #rFileExtention#>
	<cffile action = "write"  file = "#fName#"  output = "#reportOutput#">
	<CF_Writing_Email_Attachment
	  				Naming_Format="Reports_#q_getReportDetails.Report_Name#"
					File_Extension="#rFileExtention#"
					Relative_Path="\Temp_Files\Report\"
					Output_Content="#reportOutput#"
					addNewLine="No"
					Return_File_Name="fName">	
	<!-----<cfset toEmail="#ownerEmail#">------->
	<cfset toEmail="#rEmailAddress#">
	<cfloop index="i" list="#toEmail#" delimiters=";">
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
		</cf_EmailWrapper>
	</cfloop>
</cfoutput>
