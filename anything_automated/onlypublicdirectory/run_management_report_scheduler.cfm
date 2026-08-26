 <cfparam name="url.report_id" default="">
 <cfoutput>
 <cfif url.report_id NEQ "">
 
 <CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

<CFQUERY NAME="Get_ReportDetails" DATASOURCE="#application.datasource#">
select report_name,Report_Path,Report_Users_Email
from management_report_details
where deleted = 0
and report_id = <cfqueryparam value="#url.report_id#" cfsqltype="CF_SQL_INTEGER">
</CFQUERY>

 <cfsavecontent variable = "EmailContents">
			<CFINCLUDE TEMPLATE="#Get_ReportDetails.report_path#">
</cfsavecontent>
<!--- #EmailContents#
<cfflush> --->
<CFSET request.AccessStructure.User_ID = "0000000000">
			<cfset finalEmailAddress = Get_ReportDetails.Report_Users_Email>
			<cf_EmailWrapper 
				to="#finalEmailAddress#" 
				from="#Contact_Admin_Email_Address#" 
				subject="#Get_ReportDetails.report_name#" 
				type="HTML"
				messagetype="1" 
				generatedby="1" 
				apparea="1">
				<cfoutput>Please find enclosed your revision report as of #Dateformat(now(),"mm/dd/yyyy")#</cfoutput>
						<CF_Writing_Email_Attachment
  				Naming_Format="#Get_ReportDetails.report_name#"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program_Status\"
				Output_Content="#EmailContents#"
				addNewLine="No"
				Return_File_Name="fName">
						<cf_emailwrapperparam file = "#fName#" store="yes" />
				
			<!--- </cfmail> --->
			</cf_EmailWrapper>
		
<cfelse>
<cfabort>
</cfif></cfoutput> 