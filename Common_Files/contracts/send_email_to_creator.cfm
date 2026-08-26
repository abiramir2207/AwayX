
<cfparam name="getSendToEmail.User_Email" default="kehrlich@bigredflame.com">
<cfparam name="getFromEmail.User_Email" default="kehrlich@bigredflame.com">
<cfparam name="Form.notes" default="">

<cfquery name="getSendToEmail" datasource="#application.datasource#">
	select User_Email
	from _Users
	where User_ID = (select creator_ID  from contract_main where contract_main_id='#cryp.value#')
</cfquery>
	
<cfset useLakebaseForgetFromEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetFromEmail>
	<cftry>
		<cfset getFromEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "user_email,name_first,name_last"
			}), "user_email,name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetFromEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetFromEmail>
<cfquery name="getFromEmail" datasource="#application.datasource#">
	select User_Email, Name_first, Name_Last
	from _Users
	where User_ID = '#request.AccessStructure.User_ID#'
</cfquery>
</cfif>

<cfset useLakebaseForgetProgramTitle = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetProgramTitle>
	<cftry>
		<cfset getProgramTitle = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#",
				"select" = "contract_number,contract_title"
			}), "contract_number,contract_title"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramTitle = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramTitle>
<cfquery name="getProgramTitle" datasource="#application.datasource#">
	select Contract_Number,contract_title
	from contract_main 
	where contract_main_id='#cryp.value#'
</cfquery>
</cfif>

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
			
		