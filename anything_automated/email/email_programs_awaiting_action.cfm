<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

<cfoutput>
<cfquery name="getAllRFAPrograms" datasource="#application.datasource#">
select * from
rfa_awaiting_action
where DATEDIFF(day,rfa_awaiting_action.Broker_Approved_Date,getdate()) >= <cfqueryparam value="#appSettings.getawaitingactiondays()#" cfsqltype="CF_SQL_INTEGER">
</cfquery>
</cfoutput>

<cfquery name="getRFAtitle" datasource="#application.datasource#">

select report_name,Send_Report_To
from _application_settings

</cfquery>




 <cfsavecontent variable = "EmailContents">
			<CFINCLUDE TEMPLATE="programs_awaiting_action.cfm">
</cfsavecontent>

<cfoutput>

#EmailContents#
<cfflush>

			<cfset finalEmailAddress = getRFAtitle.send_report_to>
			<cf_EmailWrapper 
				to="#finalEmailAddress#" 
				from="#Contact_Admin_Email_Address#" 
				subject="RFA Programs Waiting for Action" 
				type="HTML"
				messagetype="1" 
				generatedby="1" 
				apparea="1">
						<CF_Writing_Email_Attachment
  				Naming_Format="RFA_Programs_Waiting_For_Action"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program_Status\"
				Output_Content="#EmailContents#"
				addNewLine="No"
				Return_File_Name="fName">
						<cf_emailwrapperparam file = "#fName#" store="yes" />
				
			<!--- </cfmail> --->
			</cf_EmailWrapper>
		</cfoutput> 
