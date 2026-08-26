<!---
	You must pass in: Contract_Main_ID (only one, if you have multiple, loop through the include
	This page is called from:
	- /common_files/contract/contract_approve_broker_action.cfm
	- /common_files/contract/mass_program_copy_process.cfm
	- /scheduled/Auto_Renew_Programs.cfm
	- /ANYTHING_AUTOMATED/EMAIL/rfa_program_reminder_email.cfm
	- /common_files/contract/program_agree_action.cfm
--->

<cfparam name="bByPassSettings" default="0" />
<!--- Dev Note: KAL; 7/2/2010; D23915: New Setting to determine whether RFA email shoudl go user --->
<cfparam name="checkRFANotificationEmail" default="1" />

<!--- SEND EMAIL TO ALERT USERS of status change --->
<cfset useLakebaseForgetGSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGSettings>
	<cftry>
		<cfset getGSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "send_auto_rfa_email,rfa_email"
			}), "send_auto_rfa_email,rfa_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGSettings>
<cfquery name="getGSettings" datasource="#application.datasource#">
	SELECT	send_auto_rfa_email, RFA_Email
	FROM	General_Settings
</cfquery>
</cfif>

<cfset didWeSendEmail = 0 />

<CFIF bByPassSettings or (getGSettings.send_auto_rfa_email EQ 1 AND getGSettings.RFA_Email EQ 1)>

	<cfparam name="LocationFrom" default="Auto">

	<cfif NOT isDefined("businessSegmentsOn")>
		<cfset userManager = CreateObject("component", "components.user.UserManager") />
		<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfset businessSegmentsOn = 0 />
		<cfif businessSegManager.isEnabled()>
			<cfset businessSegmentsOn = 1 />
		</cfif>
	</cfif>

	<!--- <!--- <!--- <!--- <!--- STATUS CHANGE NOTIFICATION EMAIL ---> ---> ---> ---> --->
	<CFQUERY NAME="getThisProgramsStatus" datasource="#application.datasource#">
		SELECT 	Contract_main.Contract_Status_Type_IDX,
				Contract_main.Revision_Of_Contract_Main_ID,
				Contract_main.Broker_User_ID,
				Contract_main.Broker_Approved_Date,
				Contract_main.Contract_Number,
				Contract_main.Contract_Title,
				Contract_main.Responsible_User_Id,
				Contract_main.Creator_ID,
				Contract_main.Creating_User_Position_ID,
				Contract_Main.Business_Segment_ID,
				Contract_Main.ProgramType_ID,
				Program_Control_Panel_Options.Send_RFA_Email,
				Program_Control_Panel_Options.Generic_Type
		FROM 	Contract_main
				INNER JOIN	Program_Control_Panel_Options ON
				Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		WHERE 	Contract_main.Contract_main_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>

	<!---TSF - Label 12624/86027 - Check for template level setting on whether or not to send emails on RFA --->
	<cfif getThisProgramsStatus.Send_RFA_Email>

		<cfset userManager = createobject("component", "components.user.userManager") />
		<CFSET currentUserPositionID = userManager.getPositionId(getThisProgramsStatus.Broker_User_ID)>
		<CFSET userPositionID = getThisProgramsStatus.Creating_User_Position_ID>
		<CFSET positionList = createobject("component", "components.geography.position").getFirstPositionAbove(userPositionID)>
		<cfset RFADate 		= getThisProgramsStatus.Broker_Approved_Date>

		<cfset qCurrentUserInfo = userManager.getUser(getThisProgramsStatus.Broker_User_ID) />
		<cfset uName = qCurrentUserInfo.User_Full_Name>
		<cfset uEmail = qCurrentUserInfo.User_Email>
		<cfset userInBehalf = 0>
		<cfif currentUserPositionID NEQ userPositionID>
			<!------ if current user's position id is not equal to responsible position ----->
			<cfset userInBehalf = 1>
			<cfset qResponsibleUserInfo = userManager.getUser(getThisProgramsStatus.Responsible_User_Id) />
			<cfset responsibleUserName = qResponsibleUserInfo.User_Full_Name>
			<cfset responsibleUserEmail = qResponsibleUserInfo.User_Email>
		</cfif>

		<!---TSF - Label 13992: If there is no from email address then get the system administrators address--->
		<cfif not len(trim(uEmail))>
			<cfset uEmail = userManager.getCurrentSystemAdmin().User_Email />
		</cfif>

		<cfif NOT isDefined("appSettings")>
			<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<cfset appSettings = genSettingsManager.get()>
		</cfif>

		<!--- Dev note(65876 and 76235) - variable "Setting_HQ_Send_Email_To_RSP_Only" will be OFF by default on "get_user_position_contact.cfm".
		No email should be sent on RFA to HQ users (except RSP), when HQ position is tne creator of the program AND generic type = Distributor Trade Shelter AMD When
		appsettings.getNotify_RSP_Only_NotAllHQUser() setting is ON and appsettings.getSend_RFA_Agree_Emails_To_CRA_Users() setting is OFF.
		--->

		<cfset HQ_Send_Email_To_RSP_Only = 0 />
		<cfif NOT isDefined("HQPosition")>
			<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />
		</cfif>

		<!---  Check if Creating_User_Position_ID is HQ ----->
		<cfif userPositionID EQ HQPosition.User_Positions_ID>
			<cfset HQ_Send_Email_To_RSP_Only = 1 />
		</cfif>

		<cfset Setting_HQ_Send_Email_To_RSP_Only = appsettings.getNotify_RSP_Only_NotAllHQUser() AND appsettings.getSend_RFA_Agree_Emails_To_CRA_Users() EQ 0 AND getThisProgramsStatus.Generic_Type EQ "Distributor Trade/Shelter" AND HQ_Send_Email_To_RSP_Only>

		<cfset EmailList = "">
		<cfif listlen(trim(PositionList)) GT 0>
			<cfset Creating_User_Position_ID 	= positionList /><!------ RFA email should go out to the position above ----->
			<cfset Contract_Business_Segment_ID = getThisProgramsStatus.Business_Segment_ID />
			<cfset Contract_Responsible_User_ID = getThisProgramsStatus.Responsible_User_ID />
			<cfset Contract_Template_ID 		= getThisProgramsStatus.ProgramType_ID />
			<cfset checkRFANotificationEmail = 1 />

			<!------ 2=At Agree, send only to CRA (currently responsible for approval) users, 3 = send email on RFA and Agreed to person above ----->
			<cfif appSettings.getRFAEmailEvent() EQ 2 OR appSettings.getRFAEmailEvent() EQ 3>
				<cfset ProgramManager = CreateObject("component", "components.programs.ProgramManager").init() />
				<!--- <cfset userPositionContactInfo = ProgramManager.getApprovableUsers(Contract_Main_ID, businessSegmentsOn, Contract_Responsible_User_ID, checkRFANotificationEmail) /> --->
				<cfset userPositionContactInfo = ProgramManager.getApprovableUsers(programId=Contract_Main_ID, businessSegmentsOn=businessSegmentsOn, responsibleUserId=Contract_Responsible_User_ID, checkRFANotificationEmail=checkRFANotificationEmail, HQSendEmailToRSPOnly=Setting_HQ_Send_Email_To_RSP_Only) />
			<cfelse><!------ At RFA, send to all users who can access this program in the position above the Responsible user ----->
				<cfset CheckApprovalAccess = 1 />
				<cfinclude template="get_user_position_contact.cfm" />
			</cfif>

			<cfset EmailList = valuelist(userPositionContactInfo.User_Email)>

		</cfif>

		<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
			<cfset commonqueries_Called = 0 />
			<CFSET CSL_Contract_Main_ID = Contract_Main_ID>
			<CFINCLUDE template="/common_files/contracts/commonqueries.cfm">
			<cfsavecontent variable = "EmailContents">
				<CFINCLUDE TEMPLATE="/common_files/contracts/thin_contract_general_display.cfm">
			</cfsavecontent>
		</CFIF>

		<cfoutput>
				<cfset AlreadySentTo = "">
				<cfloop index="EAddr" list="#EmailList#">

				<cfif EAddr IS NOT uEmail AND ListContains(AlreadySentTo, EAddr) IS False AND len(trim(uEmail))>
					<cfset AlreadySentTo = listappend(AlreadySentTo,EAddr)>
					<!--- prevent problem in including this template more than once --->
					<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
						<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
					</cfif>

					<CF_EMAILWRAPPER
						TO			=	"#EAddr#"
						FROM		=	"#uEmail#"
						subject="#EmailSubject(	getThisProgramsStatus.Contract_Number       <!--- 30738 --->
																,getThisProgramsStatus.Contract_Title
																,'is in need of approval')#"
						TYPE		=	"html"
						messagetype="1"
						generatedby="2"
						appArea="1"
					>
						<TABLE>
						<TR>
						<TD VALIGN="top">
						Program [#getThisProgramsStatus.Contract_Number#] "#getThisProgramsStatus.Contract_Title#" is in need of approval.<br>
						Requested Approval by: #uName#<cfif userInBehalf> in behalf of #responsibleUserName#</cfif><br>
						Requested Approval on: #DateFormat(RFADate, "mm/dd/yyyy")#
						</TD>
						</TR>
						</TABLE>
						<cfif appSettings.getSendAutoAttachments() and appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
							<CF_Writing_Email_Attachment
								Naming_Format="Program_#getThisProgramsStatus.Contract_Title#"
								File_Extension="html"
								Relative_Path="\Temp_Files\Program\"
								Output_Content="#EmailContents#"
								addNewLine="No"
								Return_File_Name="fName">
							<cf_emailwrapperparam file = "#fName#" store="yes" />
						</cfif>
					</CF_EMAILWRAPPER>

					</cfif>
				</cfloop>
				<cfset didWeSendEmail = 1 />
				<!---Only do this if it was called from the RFA page--->
				<cfif LocationFrom IS "UponRFA">
					<!--- update RFA sent bit --->
					<cfquery name="update_RFA_Email_Bit" datasource="#application.datasource#">
						UPDATE Contract_Main_Aux_Data
						SET RFA_Email_Sent = 1
						WHERE Contract_Main_ID = <cfqueryparam value="#Contract_Main_ID#" cfsqltype="CF_SQL_INTEGER">
					</cfquery>
				</CFIF>

		</cfoutput>
	</cfif>
</CFIF>