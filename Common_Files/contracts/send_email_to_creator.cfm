
<cfparam name="getSendToEmail.User_Email" default="kehrlich@bigredflame.com">
<cfparam name="getFromEmail.User_Email" default="kehrlich@bigredflame.com">
<cfparam name="Form.notes" default="">

<cfquery name="getSendToEmail" datasource="#application.datasource#">
	select User_Email
	from _Users
	where User_ID = (select creator_ID  from contract_main where contract_main_id='#cryp.value#')
</cfquery>
	
<cfquery name="getFromEmail" datasource="#application.datasource#">
	select User_Email, Name_first, Name_Last
	from _Users
	where User_ID = '#request.AccessStructure.User_ID#'
</cfquery>

<cfquery name="getProgramTitle" datasource="#application.datasource#">
	select Contract_Number,contract_title
	from contract_main 
	where contract_main_id='#cryp.value#'
</cfquery>

<cfset ep.cid = #cryp.value#>
<CFSET CSL_Contract_Main_ID = #cryp.value#>	
<CFINCLUDE template="\common_files\contracts\commonqueries.cfm">
<cfsavecontent variable = "EmailContents">
	<CFINCLUDE TEMPLATE="\common_files\contracts\thin_contract_general_display.cfm">
</cfsavecontent>
		
<cfoutput>
	<cf_EmailWrapper 
		to="#getSendToEmail.User_Email#" 
		from="#getFromEmail.User_Email#" 
		subject="Program #getProgramTitle.Contract_Number# Disagree Notification" 
		type="HTML" 					
		messagetype="1" 
		generatedby="1" 
		apparea="1">

		Program Disagree Notification<br>
		Program #getProgramTitle.Contract_Number# has been disagreed and reset to WIP by #getFromEmail.Name_first# #getFromEmail.Name_last#.<br><br>
		#Form.notes#<br>
		<CF_Writing_Email_Attachment
			Naming_Format="Program_#getProgramTitle.Contract_Title#"
			File_Extension="html"
			Relative_Path="\Temp_Files\Program\"
			Output_Content="#EmailContents#"
			addNewLine="No"
			Return_File_Name="fName">

		<cf_emailwrapperparam file = "#fName#" store="yes" />
	</cf_EmailWrapper>
</cfoutput>
			
		