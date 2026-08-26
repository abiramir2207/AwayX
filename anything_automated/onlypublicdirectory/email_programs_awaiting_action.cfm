
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
<cfoutput>
<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<!----------------- Add Spinner ------------------------>

<cfquery name="getAllRFAPrograms" datasource="#application.datasource#">
select 		* 
from		rfa_awaiting_action
where 		NoofdaysinRFA >= <cfqueryparam value="#appSettings.getawaitingactiondays()#" cfsqltype="CF_SQL_INTEGER">
ORDER BY 	Region_Name, Market_Name, Generic_Type, Contract_Number, 
			Type_Code_Desc, Profiles_ID DESC, Broker_Approved_Date, Contract_Title, 
			Contract_Start_Date, Contract_End_Date
</cfquery>
</cfoutput>

<cfquery name="getRFAtitle" datasource="#application.datasource#">

select report_name,Send_Report_To
from _application_settings

</cfquery>



<cfquery name="getTotalPrograms" dbtype="query">
	select  count(distinct contract_number) totalprograms
	from 	getAllRFAPrograms
</cfquery>


<cfsavecontent variable = "EmailContents">
	<CFINCLUDE TEMPLATE="\anything_automated\email\programs_awaiting_action.cfm">
</cfsavecontent>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfoutput>

#EmailContents#
<cfflush>

<cfif getRFAtitle.send_report_to neq "">
<CFSET request.AccessStructure.User_ID = "0000000000">
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
			</cf_EmailWrapper></cfif>
		</cfoutput> 
