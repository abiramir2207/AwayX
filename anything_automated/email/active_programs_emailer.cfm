<!------ Get application settings ----->
<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<!--- variable "Setting_HQ_Send_Email_To_RSP_Only" will be OFF by default on "get_user_position_contact.cfm" --->
<cfset Setting_HQ_Send_Email_To_RSP_Only = appsettings.getNotify_RSP_Only_NotAllHQUser()>

<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">

<cfset Email_To_Test_address = "bflynn@bigredflame.com">
<cfset Send_Email_To_Test_address = 0>
<!--- <cfset ExpirationDate = dateformat(DateAdd('ww', Contract_Expiration_Range, Now()), 'm/d/yyyy')> --->
<cfquery name="getActivePrograms" datasource="#application.datasource#">
	SELECT 	Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number,
			Contract_Main.Creating_User_Position_ID,datediff(day, getdate(), contract_start_date) as no_of_days,
			contract_title, contract_start_date,
			Contract_Main.Business_Segment_ID, Contract_Main.Responsible_User_ID, Contract_Main.ProgramType_ID
	FROM	Contract_Main
			INNER JOIN Contract_Main_Aux_Data
			ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
			<cfif getGSettings.Use_Discount_ID EQ 1><!---BJF D9361 this has resulted in applications that do not use discount identifiers getting no notifications of expiration --->
			INNER JOIN	Program_Control_Panel_Options
			ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
			inner join Discount_Identifier on Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID
			</cfif>
	WHERE
			Contract_Main.Deleted = 0
			<cfif isDefined("send_active_email") and send_active_email EQ 1>
				and Contract_Main.Contract_Main_ID = <cfqueryparam value="#cryp.value#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
				AND	Contract_Main_Aux_Data.Active_Email_Sent = 0 --only select programs which havent had this email sent already
				AND	Contract_Main.Contract_Status_Type_IDX = 5 -- automated process flagged this program as active
				<cfif Listlen(appSettings.getpricingtemplatelist()) GT 0 AND getGSettings.Use_Discount_ID EQ 1>
				AND Discount_Identifier.Discount_Identifier_Desc NOT IN (#ListQualify(appSettings.getpricingtemplatelist(), "'" , ",", "ALL")#)
				</cfif>
			</cfif>
</cfquery>


<cfloop query="getActivePrograms">
	<cfset ac.cid = getActivePrograms.Contract_Main_ID>
	<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
		<cfset commonqueries_Called = 0 />
		<CFSET CSL_Contract_Main_ID = getActivePrograms.Contract_Main_ID>
		<CFINCLUDE template="\common_files\contracts\commonqueries.cfm">
		<cfsavecontent variable = "EmailContents">
			<CFINCLUDE TEMPLATE="\common_files\contracts\thin_contract_general_display.cfm">
		</cfsavecontent>
	<cfelse>
		<cfsavecontent variable="EmailContents">
			<cfinclude template="\templates\email\active_program.cfm">
		</cfsavecontent>
	</cfif>

	<cfoutput>#EmailContents#</cfoutput>

	<cfset Contract_Business_Segment_ID = Business_Segment_ID>
	<cfset Contract_Responsible_User_ID = Responsible_User_ID>
	<cfset Contract_Template_ID 		= ProgramType_ID>

	<cfinclude template="get_user_position_contact.cfm" />

	<!--- html output for task output--->
	<table align="center">
		<TR>
			<TD align="center">recipients</TD>
		</TR>
		<tr>
			<TD align="center">
				<cfdump var="#userPositionContactInfo#">
			</TD>
		</tr>
	</table>
	<hr>

	<!--- html output for task output--->
	<cfset thisContractNumber = getActivePrograms.Contract_Number>
	<cfset contract_title = getActivePrograms.Contract_Title>
	<cfset contract_startdate = getActivePrograms.Contract_Start_Date>

	<cfloop query="userPositionContactInfo">
		<cfset finalEmailAddress = userPositionContactInfo.User_Email>

		<cfif Send_Email_To_Test_address EQ 1>
			<cfset finalEmailAddress = Email_To_Test_address>
		</cfif>

		<cfoutput>
			<!--- prevent problem in including this template more than once --->
			<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
				<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
			</cfif>
			<cf_EmailWrapper
				to="#finalEmailAddress#"
				from="#Contact_Admin_Email_Address#"
				subject="#EmailSubject(	getActivePrograms.Contract_Number       <!--- 30738 --->
			        									,getActivePrograms.Contract_Title
			        									,'Active Notification')#"
				type="HTML"
				messagetype="1"
				generatedby="1"
				apparea="1">

				<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
					Program Active Notification<br> [#thisContractNumber#] "#Contract_Title#" has become active on #dateformat(contract_startdate, 'mm/dd/yyyy')#
					<CF_Writing_Email_Attachment
		  				Naming_Format="Program_#Contract_Title#"
						File_Extension="html"
						Relative_Path="\Temp_Files\Program\"
						Output_Content="#EmailContents#"
						addNewLine="No"
						Return_File_Name="fName">
					<cf_emailwrapperparam file = "#fName#" store="yes" />
				<cfelse>
					#EmailContents#
				</cfif>

			</cf_EmailWrapper>
		</cfoutput>
	</cfloop>

	<!--- record that email was sent --->
	<cfquery name="recordemailstatus" datasource="#application.datasource#">
		UPDATE	Contract_Main_Aux_Data
		SET		Active_Email_Sent = 1
		WHERE	Contract_Main_ID = <cfqueryparam value="#ac.cid#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>

</cfloop>
