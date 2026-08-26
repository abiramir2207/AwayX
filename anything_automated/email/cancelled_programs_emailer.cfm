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
<cfparam name="send_Cancel_Email_Now" 	default="">
<!--- <cfset ExpirationDate = dateformat(DateAdd('ww', Contract_Expiration_Range, Now()), 'm/d/yyyy')> --->
<cfquery name="getCancelledPrograms" datasource="#application.datasource#">
	SELECT 	Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number,
			Contract_Main.Creating_User_Position_ID, datediff(day, getdate(), contract_start_date) as no_of_days,
			contract_title, contract_start_date, Contract_Main.Cancelled_Date,
			Contract_Main.Business_Segment_ID, Contract_Main.Responsible_User_ID, Contract_Main.ProgramType_ID
	FROM	Contract_Main
			INNER JOIN Contract_Main_Aux_Data
			ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
	WHERE
			1=1
			<cfif send_Cancel_Email_Now>
			AND Contract_Main.Contract_Main_ID = <cfqueryparam value="#send_Email_Program_ID#" cfsqltype="CF_SQL_INTEGER">
			<cfelse>
			AND Contract_Main.Deleted = 0
			AND	Contract_Main_Aux_Data.Cancelled_Email_Sent = 0 	--only select programs which havent had this email sent already
			AND	Contract_Main.Force_Expiration_Flag = 1
			AND Contract_Main.Cancelled_By IS NOT NULL
			AND Contract_Main.Cancelled_Date IS NOT NULL
			</cfif>
</cfquery>




<cfloop query="getCancelledPrograms">
	<cfset ac.cid = getCancelledPrograms.Contract_Main_ID>
	<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
		<CFSET CSL_Contract_Main_ID = getCancelledPrograms.Contract_Main_ID>
		<cfset commonqueries_Called = 0 />
		<CFINCLUDE template="\common_files\contracts\commonqueries.cfm">
		<cfsavecontent variable = "EmailContents">
			<CFINCLUDE TEMPLATE="\common_files\contracts\thin_contract_general_display.cfm">
		</cfsavecontent>
	<CFELSE>
		<cfsavecontent variable="EmailContents">
			<cfinclude template="\templates\email\cancelled_program.cfm">
		</cfsavecontent>
	</cfif>

	<cfsilent>
<cfoutput>#EmailContents#</cfoutput>
	</cfsilent>
	<cfset Contract_Business_Segment_ID = Business_Segment_ID>
	<cfset Contract_Responsible_User_ID = Responsible_User_ID>
	<cfset Contract_Template_ID 		= ProgramType_ID>

	<cfinclude template="get_user_position_contact.cfm" />
	<cfsilent>
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
	</cfsilent>
	<!--- html output for task output--->
	<cfset thisContractNumber = getCancelledPrograms.Contract_Number>
	<cfset contract_title = getCancelledPrograms.Contract_Title>
	<cfset contract_startdate = getCancelledPrograms.Contract_Start_Date>
	<cfset Cancelled_Date = getCancelledPrograms.Cancelled_Date>
	<cfoutput>
	<!--- prevent problem in including this template more than once --->
	<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
		<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
	</cfif>
	<cfloop query="userPositionContactInfo">
		<cfset finalEmailAddress = userPositionContactInfo.User_Email>

		<cfif Send_Email_To_Test_address EQ 1>
			<cfset finalEmailAddress = Email_To_Test_address>
		</cfif>

		<cf_EmailWrapper
			to="#finalEmailAddress#"
			from="#Contact_Admin_Email_Address#"
			subject="#EmailSubject(	getCancelledPrograms.Contract_Number       <!--- 30738 --->
		        									,getCancelledPrograms.Contract_Title
		        									,'Cancellation Notification')#"
			type="HTML"
			messagetype="1"
			generatedby="1"
			apparea="1">

			<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
				Program Cancellation Notification<br> [#thisContractNumber#] "#Contract_Title#" has been cancelled on #dateformat(Cancelled_Date, 'mm/dd/yyyy')#
				<CF_Writing_Email_Attachment
  				Naming_Format="Program_#Contract_Title#"
				File_Extension="html"
				Relative_Path="\Temp_Files\Program\"
				Output_Content="#EmailContents#"
				addNewLine="No"
				Return_File_Name="fName">
				<cf_emailwrapperparam file = "#fName#" store="yes" />
			<CFELSE>
				#EmailContents#
			</cfif>

		</cf_EmailWrapper>

		<!--- record that email was sent --->
	</cfloop>
	</cfoutput>

	<cfquery name="recordemailstatus" datasource="#application.datasource#">
		UPDATE	Contract_Main_Aux_Data
		SET		Cancelled_Email_Sent = 1
		WHERE	Contract_Main_ID = <cfqueryparam value="#ac.cid#" cfsqltype="CF_SQL_INTEGER">
	</cfquery>

</cfloop>

	<!--- APPLICATION ADMIN SUMMARY EMAIL --->
	<cfset ac.cid = valuelist(getCancelledPrograms.Contract_Main_ID)>
	<cfif listlen(ac.cid) GT 0>
		<cfquery name="getContactPerson" datasource="#application.datasource#">
			SELECT     User_Email, Name_First, Name_Last
			FROM         dbo._Users
			WHERE     (Is_System_Administrator = 1)
			AND	   Deleted = 0
		</cfquery>

		<cfsavecontent variable="EmailContents">
			<cfinclude template="\templates\email\cancelled_program.cfm">
		</cfsavecontent>

		<cfloop query="getContactPerson">
			<cfset finalEmailAddress = getContactPerson.User_Email>

			<cfif Send_Email_To_Test_address EQ 1>
				<cfset finalEmailAddress = Email_To_Test_address>
			</cfif>
			<cfoutput>
				<cf_EmailWrapper
					to="#finalEmailAddress#"
					from="#Contact_Admin_Email_Address#"
					subject="Program Cancellation Notification (ADMINISTRATOR SUMMARY)"
					type="HTML"
					messagetype="1"
					generatedby="1"
					apparea="1">
					#EmailContents#
				</cf_EmailWrapper>
			</cfoutput>
		</cfloop>
		<cfsilent><cfoutput>#EmailContents#</cfoutput>
		<!--- html output for task output--->
		<table align="center">
			<TR>
				<TD align="center">recipients of admin summary version</TD>
			</TR>
			<tr>
				<TD align="center">
					<cfdump var="#getContactPerson#">
				</TD>
			</tr>
		</table>
		<hr>
		</cfsilent>
	</cfif>
