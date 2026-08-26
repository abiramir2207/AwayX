<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
		Send mail to the user who requested approval
		xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<cfparam name="massapproval" default="0">
<cfparam name="CloseWindow" default="1">
<cfparam name="sendLetterGenerationEmail" default="0">

<!--- STATUS CHANGE NOTIFICATION EMAIL --->
<cfset useLakebaseForgetThisProgramsStatusEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetThisProgramsStatusEmail>
	<cftry>
		<cfset getThisProgramsStatusEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#contract_main_id#",
				"select" = "contract_status_type_idx,revision_of_contract_main_id,broker_user_id,contract_number,contract_title,broker_user_id,creating_user_position_id,business_segment_id,responsible_user_id,programtype_id,creator_id"
			}), "contract_status_type_idx,revision_of_contract_main_id,broker_user_id,contract_number,contract_title,broker_user_id,creating_user_position_id,business_segment_id,responsible_user_id,programtype_id,creator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetThisProgramsStatusEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetThisProgramsStatusEmail>
<CFQUERY NAME="getThisProgramsStatusEmail" datasource="#application.datasource#">
	SELECT 	Contract_Status_Type_IDX, Revision_Of_Contract_Main_ID, Broker_User_ID, Contract_Number, Contract_Title, Broker_User_ID,Creating_User_Position_ID,
			Contract_Main.Business_Segment_ID, Contract_Main.Responsible_User_ID, Contract_Main.ProgramType_ID, Contract_Main.Creator_ID
	FROM 	Contract_main
	WHERE 	Contract_main_ID = '#contract_main_id#'
</CFQUERY>
</cfif>

<!--- prevent problem in including this template more than once --->
<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
	<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
</cfif>


<!---D40252	Event error Element CONTRACT_STATUS_TYPE_IDX is undefined in GETTHISPROGRAMSSTATUS. --->
<CFIF getThisProgramsStatusEmail.Contract_Status_Type_IDX GTE 3><!---- Approved ------>
	<cfsetting enablecfoutputonly="Yes">
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfset objGenFunc = createObject("component", "components.general.General_Functions")>

	<cfset userManager = CreateObject("component", "components.user.UserManager") />
	<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
	<cfset businessSegmentsOn = 0 />
	<cfif businessSegManager.isEnabled()>
		<cfset businessSegmentsOn = 1 />
	</cfif>


	<cfset Approved_Date = now()>

	<!--- check the email bit to determine whether to send email or not --->
	<cfset useLakebaseForgetGenSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGenSettings>
	<cftry>
		<cfset getGenSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "send_daily_expiring_email,send_daily_expired_email,send_daily_active_email,send_daily_aging_billback_email,send_broker_email,send_approve_email,number_of_days_for_summarized_weekly_expiring_email,use_discount_id"
			}), "send_daily_expiring_email,send_daily_expired_email,send_daily_active_email,send_daily_aging_billback_email,send_broker_email,send_approve_email,number_of_days_for_summarized_weekly_expiring_email,use_discount_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGenSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGenSettings>
<cfquery name="getGenSettings" datasource="#application.datasource#">
		SELECT
			send_daily_expiring_email,
			send_daily_expired_email,
			send_daily_active_email,
			send_daily_aging_billback_email,
			send_broker_email,
			send_Approve_email,
			Number_Of_Days_For_Summarized_Weekly_Expiring_Email,
			Use_Discount_ID
		FROM
			General_Settings
	</cfquery>
</cfif>

	<cfset useLakebaseForgetUserName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetUserName>
	<cftry>
		<cfset getUserName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"select" = "name_first,name_last,user_email"
			}), "name_first,name_last,user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserName>
<cfquery name="getUserName" datasource="#application.datasource#">
		SELECT Name_First, Name_Last, User_Email
		FROM _Users
		WHERE User_ID = '#request.AccessStructure.user_id#'
	</cfquery>
</cfif>

	<cfset uName = getUserName.Name_First & " " & getUserName.Name_Last>
	<cfset uEmail = getUserName.User_Email>

	<cfset Creating_User_Position_ID = getThisProgramsStatusEmail.Creating_User_Position_ID>
	<cfset Contract_Business_Segment_ID = getThisProgramsStatusEmail.Business_Segment_ID>
	<cfset Contract_Responsible_User_ID = getThisProgramsStatusEmail.Responsible_User_ID>
	<cfset Contract_Template_ID 		= getThisProgramsStatusEmail.ProgramType_ID>
	<CFSET CSL_Contract_Main_ID = contract_main_id>
	<cfset sEmailAction = "approval" />
	<cfinclude template="\anything_automated\email\get_user_position_contact.cfm">

	<cfset useLakebaseForGetSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGetSetting>
	<cftry>
		<cfset GetSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "only_notify_rsp_of_approval"
			}), "only_notify_rsp_of_approval"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSetting>
<cfquery name="GetSetting" datasource="#application.datasource#">
	Select Only_Notify_RSP_Of_Approval FROM _application_settings
	</cfquery>
</cfif>

	<cfset Setting_HQ_Send_Email_To_RSP_Only = appsettings.getNotify_RSP_Only_NotAllHQUser()>

	<cfset HQ_Send_Email_To_RSP_Only = 0 />
	<cfif Setting_HQ_Send_Email_To_RSP_Only>
		<cfif NOT isDefined("HQPosition")>
			<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />
		</cfif>

		<!---  Check if Creating_User_Position_ID is HQ ----->
		<cfif Creating_User_Position_ID EQ HQPosition.User_Positions_ID>
			<cfset HQ_Send_Email_To_RSP_Only = 1 />
		</cfif>
	</cfif>

	<!---BJF: Email RSP not whole position D10655 (GetSetting.Only_Notify_RSP_Of_Approval).
	Dev Note:(65876) - Email only the RSP and not all the users of the HQ position, when the creator of the program belongs
	to the HQ position (HQ_Send_Email_To_RSP_Only)
	--->
	<cfif GetSetting.Only_Notify_RSP_Of_Approval IS 1 OR HQ_Send_Email_To_RSP_Only eq 1>
		<cfset useLakebaseForuserPositionContactInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForuserPositionContactInfo>
	<cftry>
		<cfset userPositionContactInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Contract_Responsible_User_ID#",
				"deleted" = "eq.0",
				"select" = "user_email"
			}), "user_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForuserPositionContactInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForuserPositionContactInfo>
<cfquery name="userPositionContactInfo" datasource="#application.datasource#">
		SELECT User_Email FROM _Users WHERE User_ID = '#Contract_Responsible_User_ID#' AND Deleted = 0
		</cfquery>
</cfif>
	</cfif>

	<cfif (getGenSettings.send_approve_email EQ 1 and appSettings.getSendAutoAttachments() EQ 1) OR (appSettings.getSendApprovedProgramsEmailAdress() NEQ "") AND sendLetterGenerationEmail eq 0>
	<CFINCLUDE template="commonqueries.cfm">
	</cfif>

	<!--- If "Send Approval Email" setting is on OR an email needs to be sent for automated letter generation --->
	<cfif getGenSettings.send_approve_email EQ 1 OR sendLetterGenerationEmail eq 1>
		<!--- Ignore for the automated "letter generation" email --->
		<cfif appSettings.getSendAutoAttachments() AND sendLetterGenerationEmail eq 0>
			<cfsavecontent variable = "EmailContents">
				<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
			</cfsavecontent>
		</CFIF>

		<cfif sendLetterGenerationEmail eq 1>

			<!--- Get the email address from the "From Address for Letters" section --->
			<cfset fromemail = appSettings.getlettersfromemail()>

			<!--- Is the email valid --->
			<cfset isFromEmailValid = objGenFunc.checkEmail(fromemail)>

			<!--- If no, then make the admin's email as the "From" email address--->
			<cfif isFromEmailValid eq 0>
				<CFINCLUDE TEMPLATE="/get_Contact_Admin_Email_Address.cfm">
				<CFSET fromemail = Contact_Admin_Email_Address>
			</cfif>

			<cfset uEmail = fromemail>

		</cfif>

		<cfloop query="userPositionContactInfo">
			<!---Query userPositionContactInfo is in \anything_automated\email\get_user_position_contact.cfm--->

			<cfset finalEmailAddress = userPositionContactInfo.User_Email>
			<!--- SEND EMAIL TO ALERT USERS of status change --->
			<cfif len(trim(finalEmailAddress)) GT 0 AND trim(finalEmailAddress) NEQ trim(uEmail)>
			<cfoutput>
			<!--- Approval email only--->
			<cfif sendLetterGenerationEmail eq 0>
				<CF_EMAILWRAPPER
					TO			=	"#finalEmailAddress#"
					FROM		=	"#uEmail#"
					SUBJECT =	"#EmailSubject(	getThisProgramsStatusEmail.Contract_Number,getThisProgramsStatusEmail.Contract_Title,'has been approved')#"
					TYPE		=	"html"
					messagetype="1"
					generatedby="2"
					appArea="1"
				>
						<TABLE>
						<TR>
						<TD VALIGN="top">
						Program [#getThisProgramsStatusEmail.Contract_Number#] "#getThisProgramsStatusEmail.Contract_Title#" has been approved by  #uName# on #DateFormat(Approved_Date, "mm/dd/yyyy")#
						<!--- <CFIF Len(Encrypted_Url) GT 0>
						<BR><A HREF="#Encrypted_Url#">Click here to goto Program [#getThisProgramsStatusEmail.Contract_Number#]...</A>
						</CFIF> --->
						</TD>
						</TR>
						</TABLE>
					<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
						<CF_Writing_Email_Attachment
						Naming_Format="Program_#getThisProgramsStatusEmail.Contract_Title#"
						File_Extension="html"
						Relative_Path="\Temp_Files\Program\"
						Output_Content="#EmailContents#"
						addNewLine="No"
						Return_File_Name="fName">

						<cf_emailwrapperparam file = "#fName#" store="yes" />
					</cfif>
				</CF_EMAILWRAPPER>
			<!--- Automated "letter generation" email--->
			<cfelse>
				<CF_EMAILWRAPPER
					TO			=	"#finalEmailAddress#"
					FROM		=	"#uEmail#"
					SUBJECT		=	"Letters for Program #getThisProgramsStatusEmail.Contract_Number# are ready to view"
					TYPE		=	"html"
					messagetype="1"
					generatedby="2"
					appArea="1"
				>
						<TABLE>
						<TR>
						<TD VALIGN="top">
						Letters for program [#getThisProgramsStatusEmail.Contract_Number#] "#getThisProgramsStatusEmail.Contract_Title#" have been generated by the automated process and are ready to view.
						<!--- <CFIF Len(Encrypted_Url) GT 0>
						<BR><A HREF="#Encrypted_Url#">Click here to goto Program [#getThisProgramsStatusEmail.Contract_Number#]...</A>
						</CFIF> --->
						</TD>
						</TR>
						</TABLE>
				</CF_EMAILWRAPPER>
			</cfif>
			</cfoutput>
			</cfif>
		</cfloop>
	</cfif>
	<!--- <!--- <!--- <!--- <!--- STATUS CHANGE NOTIFICATION EMAIL ---> ---> ---> ---> --->
</CFIF>

<!--- Ignore for the automated "letter generation" email --->
<cfif sendLetterGenerationEmail eq 0>
	<cfif appSettings.getSendApprovedProgramsEmailAdress() NEQ "">
		<cfset isTextFormat = "true">
		<CF_EMAILWRAPPER
			TO			=	"#appSettings.getSendApprovedProgramsEmailAdress()#"
			FROM		=	"#uEmail#"
			SUBJECT		=	"#EmailSubject(getThisProgramsStatusEmail.Contract_Number,getThisProgramsStatusEmail.Contract_Title,'has been approved')#"
			TYPE		=	"html"
			messagetype="1"
			generatedby="2"
			appArea="1"
			>
			<cfoutput>Program [#getThisProgramsStatusEmail.Contract_Number#] "#getThisProgramsStatusEmail.Contract_Title#" has been approved by  #uName# on #DateFormat(Approved_Date, "mm/dd/yyyy")#</cfoutput>
			<cfsavecontent variable = "Contents">
				<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
			</cfsavecontent>
			<cfif appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
				<CF_Writing_Email_Attachment
					Naming_Format="Program_#getThisProgramsStatusEmail.Contract_Title#"
					File_Extension="txt"
					Relative_Path="\Temp_Files\Program\"
					Output_Content="#Contents#"
					addNewLine="No"
					Return_File_Name="fName">
						<cf_emailwrapperparam file = "#fName#" store="yes">
			</cfif>
		</CF_EMAILWRAPPER>
		<cfset isTextFormat = "false">
	</cfif>

		<!------<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">----->
		<!------ this program whetever the status is should have price ------>
		<CFSET generateReleaseProgramID = contract_main_id>
		<CFSET generateRelease_GeneratePrices = 1>
		<CFINCLUDE TEMPLATE="Contract_Formula_Pricing_Periods_Generate_Prices_For_Release.cfm">
		<!------ this program whetever the status is should have price ------>

		<CFIF getThisProgramsStatusEmail.Contract_Status_Type_IDX EQ 5 and getGenSettings.send_daily_active_email EQ 1><!---- Active------>
			<cfset send_active_email = 1 >
			<cfset cryp.value = #contract_main_id#>
			<cfinclude template="\anything_automated\email\active_programs_emailer.cfm">
		</cfif>

	<cfsetting enablecfoutputonly="No" showdebugoutput="yes" >
	<cfsetting enablecfoutputonly="No" showdebugoutput="yes">

	<cfif Not IsDefined("FORM.ApproveContract")>
		<cfset FORM.ApproveContract  = URL.CID>
	</cfif>

	<cfif massapproval EQ 0 and CloseWindow>
		<cfset targetpage = "winSummary_" & contract_main_id>
		<script>
			/* reloadFromVerticalPNL */
			var existingWin = window.open('', <cfoutput>'#targetpage#'</cfoutput>);
			// reload function in parent popup is available
			if ( typeof existingWin.reloadFromPopUp === "function" ) {
				existingWin.reloadFromPopUp(1);
			}
			window.close();
		</script>
	</cfif>
</cfif>
