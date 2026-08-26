<cfset Email_To_Test_address = "bflynn@bigredflame.com">
<cfset Send_Email_To_Test_address = 0>

<!---Gets correct "From" address--->
<cfinclude template="/get_Contact_Admin_Email_Address.cfm">

<!---TSF - Label 12527: Changed query to use Company_Main_ID FROM Company_Main instead of hard coded value--->
<cfquery name="getExpirationTime" datasource="#application.datasource#">
	SELECT	Contract_Expiration_Range,User_ID
	FROM	_Users_Settings
	WHERE	User_ID = (SELECT Company_Main_ID FROM Company_Main WHERE Deleted = 0)
</cfquery>

<cfset Contract_Expiration_Range = getExpirationTime.Contract_Expiration_Range>

<cfif not isnumeric(Contract_Expiration_Range)>
	<!--- there is a program misconfiguration, put email code to admin here --->
	<cfabort>
<cfelse>

<!--- variable "Setting_HQ_Send_Email_To_RSP_Only" will be OFF by default on "get_user_position_contact.cfm" --->
<cfset Setting_HQ_Send_Email_To_RSP_Only = appsettings.getNotify_RSP_Only_NotAllHQUser()>

	<!--- <cfset ExpirationDate = dateformat(DateAdd('ww', Contract_Expiration_Range, Now()), 'm/d/yyyy')> --->
	<cfset ExpirationDate = dateformat(Now(), 'mm/dd/yyyy')>
	<cfquery name="getExpiredPrograms" datasource="#application.datasource#">
		SELECT Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, Contract_Main.Creating_User_Position_ID,
				datediff(day, getdate(), contract_end_date) as no_of_days, contract_title,
				Contract_Main.Business_Segment_ID, Contract_Main.Responsible_User_ID, Contract_Main.ProgramType_ID,
				ISNULL(Profiles.Profiles_ID, 0) as Profiles_ID
		FROM    Contract_Main
				INNER JOIN	Contract_Main_Aux_Data
				ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
				INNER JOIN _Users on _Users.User_ID = Contract_Main.Responsible_User_ID and _Users.Deleted = 0
				LEFT JOIN Profiles on Profiles.Profiles_ID = _Users.Profiles_ID and Profiles.Deleted = 0
				<cfif getGSettings.Use_Discount_ID EQ 1><!---BJF D9361 this has resulted in applications that do not use discount identifiers getting no notifications of expiration --->
				INNER JOIN	Program_Control_Panel_Options
				ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
				inner join Discount_Identifier on Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID
				</cfif>
		WHERE
				Contract_Main.Deleted = 0
				AND
				Contract_Main_Aux_Data.Expired_Email_Sent = 0 --only select programs which havent had this email sent already
				AND
				Contract_Main.Contract_Status_Type_IDX = 7 -- automated process flagged this program as expired
				AND
				Contract_Main.Manual_Cancel = 0
				<cfif Listlen(appSettings.getpricingtemplatelist()) GT 0 AND getGSettings.Use_Discount_ID EQ 1>
				AND Discount_Identifier.Discount_Identifier_Desc NOT IN  (#ListQualify(appSettings.getpricingtemplatelist(), "'" , ",", "ALL")#)
				</cfif>
	</cfquery>

	<cfloop query="getExpiredPrograms">
		<cfset ep.cid = getExpiredPrograms.Contract_Main_ID>
		<cfset request.accessstructure.profiles_id = getExpiredPrograms.Profiles_ID />
		<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
			<CFSET CSL_Contract_Main_ID = getExpiredPrograms.Contract_Main_ID>
			<cfset commonqueries_Called = 0 />
			<CFINCLUDE template="\common_files\contracts\commonqueries.cfm">
			<cfsavecontent variable = "EmailContents">
				<CFINCLUDE TEMPLATE="\common_files\contracts\thin_contract_general_display.cfm">
			</cfsavecontent>
		<cfelse>
			<cfsavecontent variable="EmailContents">
				<cfinclude template="\templates\email\expired_program.cfm">
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
		<cfset thisContractNumber = getExpiredPrograms.Contract_Number>
		<cfset Contract_Title = getExpiredPrograms.Contract_Title>

		<!--- prevent problem in including this template more than once --->
		<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
			<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
		</cfif>

		<cfloop query="userPositionContactInfo">
			<cfset finalEmailAddress = userPositionContactInfo.User_Email>

			<cfif Send_Email_To_Test_address EQ 1>
				<cfset finalEmailAddress = Email_To_Test_address>
			</cfif>

			<cfoutput>
				<cf_EmailWrapper
					to="#finalEmailAddress#"
					from="#Contact_Admin_Email_Address#"
					subject="#EmailSubject(	getExpiredPrograms.Contract_Number       <!--- 30738 --->
				        									,getExpiredPrograms.Contract_Title
				        									,'Expiration Notification')#"
					type="HTML"
					messagetype="1"
					generatedby="1"
					apparea="1">

					<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
						Program Expiration Notification<br>
						Please be advised this program has expired today #ExpirationDate#.
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
			<!--- record that email was sent --->
		</cfloop>

		<cfquery name="recordemailstatus" datasource="#application.datasource#">
			UPDATE	Contract_Main_Aux_Data
			SET		Expired_Email_Sent = 1
			WHERE	Contract_Main_ID = <cfqueryparam value="#ep.cid#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>

	</cfloop>

</cfif>