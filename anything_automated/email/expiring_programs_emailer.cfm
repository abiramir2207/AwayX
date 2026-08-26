<cfset Email_To_Test_address = "noreply@bigredflame.com">
<cfset Send_Email_To_Test_address = 0>        <!--- TO DO: change this to zero --->



<!----------------------  Start Function getExpiryMessage --------------->
<cffunction name="getExpiryMessage" returntype="string">
	<cfargument name="endDate" type="date" />

	<cfset Contract_Expiration_Range_In_Weeks = DateDiff("ww", Now(), DateAdd('d', arguments.endDate, 1))>
	<cfset Contract_Expiration_Range_In_Days = DateDiff("d", Now(), DateAdd('d', arguments.endDate, 1))>
	<cfset Balance_Expiration_Range_In_Days = Contract_Expiration_Range_In_Days MOD 7>
	<cfset ExpirationDate = DateFormat(arguments.endDate, "mm/dd/yyyy")>

	<cfset ExpiryMessage = "soon" />
	<cfif Contract_Expiration_Range_In_Weeks neq 0>
		<cfif Contract_Expiration_Range_In_Weeks eq 1>
		 <cfset NumberOfWeek = "week">
		<cfelse>
			<cfset NumberOfWeek= "weeks">
		</cfif>
		<cfset ExpiryMessage ="in #Contract_Expiration_Range_In_Weeks# #NumberOfWeek#">
		<cfif Balance_Expiration_Range_In_Days EQ 1>
			<cfset ExpiryMessage = ExpiryMessage &" and #Balance_Expiration_Range_In_Days# day">
		<cfelseif Balance_Expiration_Range_In_Days GT 1>
			<cfset ExpiryMessage = ExpiryMessage &" and #Balance_Expiration_Range_In_Days# days">
		</cfif>
	<cfelse>
		<cfif Balance_Expiration_Range_In_Days EQ 1>
			<cfset ExpiryMessage = "in #Balance_Expiration_Range_In_Days# day">
		<cfelseif Balance_Expiration_Range_In_Days GT 1>
			<cfset ExpiryMessage = "in #Balance_Expiration_Range_In_Days# days">
		<cfelse>
			<cfset ExpiryMessage = "today">
		</cfif>
	</cfif>

	<cfreturn ExpiryMessage />

</cffunction>
<!-------------------  End Function getExpiryMessage ---------------------->

<!---Gets correct "From" address--->
<cfinclude template="/get_Contact_Admin_Email_Address.cfm">

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<!--- variable "Setting_HQ_Send_Email_To_RSP_Only" will be OFF by default on "get_user_position_contact.cfm" --->
<cfset Setting_HQ_Send_Email_To_RSP_Only = appsettings.getNotify_RSP_Only_NotAllHQUser()>

<!---TSF - Label 12527: Changed query to use Company_Main_ID FROM Company_Main instead of hard coded value--->
<cfquery name="getExpirationTime" datasource="#application.datasource#">
	SELECT	Contract_Expiration_Range,User_ID
	FROM	_Users_Settings
	WHERE	User_ID = (SELECT Company_Main_ID FROM Company_Main WHERE Deleted = 0)
</cfquery>


<cfset useLakebaseForgetSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetSettings>
	<cftry>
		<cfset getSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "number_of_days_for_summarized_weekly_expiring_email,send_daily_expiring_email,use_discount_id"
			}), "number_of_days_for_summarized_weekly_expiring_email,send_daily_expiring_email,use_discount_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetSettings>
<cfquery name="getSettings" datasource="#application.datasource#">
	SELECT Number_Of_Days_For_Summarized_Weekly_Expiring_Email,send_daily_expiring_email,Use_Discount_ID
	FROM General_Settings
</cfquery>
</cfif>

<cfset DailyExpiringEmail = getSettings.send_daily_expiring_email>
<cfset NumberOfDaysForWeeklyNotification = getSettings.Number_Of_Days_For_Summarized_Weekly_Expiring_Email>
<cfset Contract_Expiration_Range = getExpirationTime.Contract_Expiration_Range>
<cfset sendSummaryEmailToday = 0 />
<cfif NumberOfDaysForWeeklyNotification NEQ 0 AND DayOfWeek(now()) eq 6>
	<cfset sendSummaryEmailToday = 1 />
</cfif>


<cfif not isnumeric(Contract_Expiration_Range)>
 <!--- there is a program misconfiguration, put email code to admin here --->
<cfelse>

	<cfquery name="getExpiringPrograms" datasource="#application.datasource#">
		SELECT
		    Contract_Main.Contract_Main_ID, Contract_Main.Contract_Number, Contract_Main.Creating_User_Position_ID,
				datediff(day, getdate(), contract_end_date) as no_of_days, contract_title, Contract_Main.Responsible_User_ID, Contract_Main_Aux_Data.Expiring_Email_Sent,
				Contract_Main.Business_Segment_ID, Contract_Main.Responsible_User_ID, Contract_Main.ProgramType_ID, Contract_Main.Contract_End_Date,
				ISNULL(Profiles.Profiles_ID, 0) as Profiles_ID
		FROM	Contract_Main
				INNER JOIN	Contract_Main_Aux_Data
				ON Contract_Main.Contract_Main_ID = Contract_Main_Aux_Data.Contract_Main_ID
				INNER JOIN _Users on _Users.User_ID = Contract_Main.Responsible_User_ID and _Users.Deleted = 0
				LEFT JOIN Profiles on Profiles.Profiles_ID = _Users.Profiles_ID and Profiles.Deleted = 0
			<cfif getSettings.Use_Discount_ID EQ 1> <!--- BJF D9361 this has resulted in applications that do not use discount identifiers getting no notifications of expiration --->
				INNER JOIN	Program_Control_Panel_Options
				ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
				INNER JOIN Discount_Identifier on Discount_Identifier.Discount_Identifier_ID = Program_Control_Panel_Options.Discount_Identifier_ID
			</cfif>
		WHERE
				Contract_Main.Deleted = 0
				AND
				(
					1 = 2
					<cfif sendSummaryEmailToday eq 1>
						-- Send every friday as long as the contract end date is less than or equal to Weekly Notification days
						OR datediff(day, getdate(), contract_end_date) <= #NumberOfDaysForWeeklyNotification#
					<cfelseif DailyExpiringEmail EQ 1>
						--only select programs which havent had this email sent already
						OR Contract_Main_Aux_Data.Expiring_Email_Sent = 0
					</cfif>
				)
				AND Contract_Main.Contract_Status_Type_IDX = 6 -- automated process flagged this program as expiring
			<cfif Listlen(appSettings.getpricingtemplatelist()) GT 0 AND getSettings.Use_Discount_ID EQ 1>
				AND Discount_Identifier.Discount_Identifier_Desc NOT IN (#ListQualify(appSettings.getpricingtemplatelist(), "'" , ",", "ALL")#)
			</cfif>
			--Filter Out Programs That have already been revised or Auto Renewed
			AND NOT EXISTS(
								SELECT Contract_main_Id
								FROM Contract_Main CM2
								WHERE (CM2.Revision_of_Contract_Main_ID = Contract_Main.Contract_main_Id
										OR
										(CM2.Renewal_Of_Contract_Main_ID = Contract_Main.Contract_main_Id AND
											Is_AutoRenew = 1)
										)
										AND
										CM2.Deleted = 0
								)
			ORDER BY Contract_Title ASC
	</cfquery>

  <cfset Responsible_User_ID_List = "">

	<cfloop query="getExpiringPrograms">

		<cfset Expiring_Email_Sent = getExpiringPrograms.Expiring_Email_Sent>
		<cfset ep.cid = getExpiringPrograms.Contract_Main_ID>

		<cfset request.accessstructure.profiles_id = getExpiringPrograms.Profiles_ID />

		<!--- Only for Summarized emails, which are sent to RSP --->
		<cfif NumberOfDaysForWeeklyNotification GTE 1>
			<cfset Responsible_User_ID = getExpiringPrograms.Responsible_User_ID>
			<cfif NOT ListContains(Responsible_User_ID_List, Responsible_User_ID)>
				<cfset Responsible_User_ID_List = listAppend(Responsible_User_ID_List,getExpiringPrograms.Responsible_User_ID)>
			</cfif>
		</cfif>
		<!--- End Only for Summarized emails, which are sent to RSP --->

		<cfset ExpiryMessage = getExpiryMessage(getExpiringPrograms.Contract_End_Date) />

		<!--- For notification of programs expiring --->
		<cfif DailyExpiringEmail eq 1 AND Expiring_Email_Sent eq 0>
			<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
				<CFSET CSL_Contract_Main_ID = getExpiringPrograms.Contract_Main_ID>
				<cfset commonqueries_Called = 0 />
				<CFINCLUDE template="\common_files\contracts\commonqueries.cfm">
				<cfsavecontent variable = "EmailContents">
					<CFINCLUDE TEMPLATE="\common_files\contracts\thin_contract_general_display.cfm">
				</cfsavecontent>
			<cfelse>
				<cfsavecontent variable="EmailContents">
					<cfinclude template="\templates\email\expiring_program.cfm">
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
			<cfset thisContractNumber = getExpiringPrograms.Contract_Number>
			<cfset Contract_Title = getExpiringPrograms.Contract_Title>

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
						subject="#EmailSubject(	getExpiringPrograms.Contract_Number       <!--- 30738 --->
					        									,getExpiringPrograms.Contract_Title
					        									,'Expiration Notification')#"
						type="HTML"
						messagetype="1"
						generatedby="1"
						apparea="1">
						<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
Please be advised program #getExpiringPrograms.Contract_Number# is expiring and will expire #ExpiryMessage#.
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
				SET		Expiring_Email_Sent = 1
				WHERE	Contract_Main_ID = <cfqueryparam value="#ep.cid#" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
		</cfif>
		<!--- End - For notification of programs expiring --->
	</cfloop>


	<cfset ep.cid = valuelist(getExpiringPrograms.Contract_Main_ID)>

	<cfif listlen(ep.cid) GT 0>

		<!--- WEEKLY SUMMARIIZED EMAIL --->
		<cfif NumberOfDaysForWeeklyNotification GTE 1 AND sendSummaryEmailToday eq 1>
			<cfloop list ="#Responsible_User_ID_List#" index="RSP_ID">
				<cfset useLakebaseForgetRSPEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetRSPEmail>
	<cftry>
		<cfset getRSPEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#RSP_ID#",
				"select" = "user_email,name_first"
			}), "user_email,name_first"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetRSPEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetRSPEmail>
<cfquery name="getRSPEmail" datasource="#application.datasource#">
					SELECT User_Email, NAME_FIRST
					FROM _Users
					WHERE User_ID = '#RSP_ID#'
				</cfquery>
</cfif>

				<cfsavecontent variable="EmailContents">
					<cfinclude template="\templates\email\expiring_program.cfm">
				</cfsavecontent>

				<cfset finalEmailAddress = getRSPEmail.User_Email>

				<cfif Send_Email_To_Test_address EQ 1>
					<cfset finalEmailAddress = Email_To_Test_address>
				</cfif>
				<cfset Msg = "SUMMARY">
				<!--- Add the number of days for program notification in the email subject --->
				<cfoutput>
					<cf_EmailWrapper
						to="#finalEmailAddress#"
						from="#Contact_Admin_Email_Address#"
						subject="#NumberOfDaysForWeeklyNotification# day Program Expiring Notification (#Msg#)"
						type="HTML"
						messagetype="1"
						generatedby="1"
						apparea="1">

						#EmailContents#

					</cf_EmailWrapper>
				</cfoutput>
				<cfoutput>#EmailContents#</cfoutput>

				<!--- html output for task output--->
				<table align="center">
					<TR>
						<TD align="center">recipients of <cfoutput>#Msg#</cfoutput> version</TD>
					</TR>
					<tr>
						<TD align="center">
							<cfdump var="#getRSPEmail#">
						</TD>
					</tr>
				</table>
				<hr>
			</cfloop>
		</cfif>
		<!--- END WEEKLY SUMMARIIZED EMAIL --->

	</cfif> <!--- <cfif listlen(ep.cid) GT 0> --->
</cfif>