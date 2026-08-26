<!--- SEND EMAIL TO ALERT USERS of status change --->
<cfquery name="getGSettings" datasource="#application.datasource#">
	SELECT
		send_auto_rfa_email, RFA_Email
	FROM
		General_Settings
</cfquery>
<cfset didWeSendEmail = 0 />


<cfparam name="LocationFrom" default="Auto">

	<!--- STATUS CHANGE NOTIFICATION EMAIL --->
	<CFQUERY NAME="getThisProgramsStatus" datasource="#application.datasource#">
		SELECT 	Contract_Status_Type_IDX, Revision_of_Export_Sales_Agreement_ID, RFA_User_ID, RFA_Approved_Date, Export_Sales_Agreement_Number, Export_Sales_Agreement_Name,
						Creator_ID, Creating_User_Position_ID
		FROM 	Export_Sales_Agreement
		WHERE 	Export_Sales_Agreement_ID = <cfqueryparam value="#Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
	</CFQUERY>

	<cfset userManager = createobject("component", "components.user.userManager") />
	<cfset RFAUserPositionID = userManager.getPositionId(getThisProgramsStatus.RFA_User_ID)>
	<cfset userPositionID = getThisProgramsStatus.Creating_User_Position_ID>
	<cfset Agreement_Manager = createobject("component", "components.Export.Sales_Agreement") />
	<cfset RFAuserProfile = Agreement_Manager.getProfile(getThisProgramsStatus.RFA_User_ID).Profiles_ID />
	<cfset positionList = createobject("component", "components.geography.position").getFirstPositionAbove(userPositionID)>
	<cfset RFADate 		= getThisProgramsStatus.RFA_Approved_Date>

	<cfset qCurrentUserInfo = userManager.getUser(getThisProgramsStatus.RFA_User_ID) />
	<cfset uName = qCurrentUserInfo.User_Full_Name>
	<cfset uEmail = qCurrentUserInfo.User_Email>

	<cfif NOT isDefined("appSettings")>
		<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
		<cfset appSettings = genSettingsManager.get()>
	</cfif>

	<cfset EmailList = "">
	<cfif listlen(trim(PositionList)) GT 0>
		<cfset Creating_User_Position_ID 	= positionList /><!------ RFA email should go out to the position above ----->

				<!------ At RFA, send to all users who can access this program in the position above the Responsible user ----->
			<cfset CheckApprovalAccess = 1 />
			<cfinclude template="sales_agreement_get_user_position_contact.cfm" />


		<cfset EmailList = valuelist(userPositionContactInfo.User_Email)>
	</cfif>

	<!---<cfif appSettings.getSendAutoAttachments()>	--->
		<CFSET CSL_Export_Sales_Agreement_ID = Export_Sales_Agreement_ID>
		<cfsavecontent variable = "EmailContents">
			<CFINCLUDE TEMPLATE="#Application.Doc_Mapping#\temp_files\program\Export_Programs_View_Private_#CSL_Export_Sales_Agreement_ID#.htm">
		</cfsavecontent>
	<!---</CFIF>--->

	<cfoutput>
			<cfset AlreadySentTo = "">
			<!--- prevent problem in including this template more than once --->
			<cfif not (isDefined("EmailSubject") and isCustomFunction(EmailSubject))>
				<cfinclude template="/Common_Files/Programs/emailsubject.cfm"/>   <!--- 30738 --->
			</cfif>
			<cfloop index="EAddr" list="#EmailList#">

			<cfif EAddr IS NOT uEmail AND ListContains(AlreadySentTo, EAddr) IS False>
				<cfset AlreadySentTo = listappend(AlreadySentTo,EAddr)>

				<CF_EMAILWRAPPER
					TO			=	"#EAddr#"
					FROM		=	"#uEmail#"
					subject="#EmailSubject(	getThisProgramsStatus.Export_Sales_Agreement_Number       <!--- 30738 --->
				        									,getThisProgramsStatus.Export_Sales_Agreement_Name
				        									,'is in need of approval')#"
					TYPE		=	"html"
					messagetype="1"
					generatedby="2"
					appArea="1"
				>
					<TABLE>
					<TR>
					<TD VALIGN="top">
					Program [#getThisProgramsStatus.Export_Sales_Agreement_Number#] "#getThisProgramsStatus.Export_Sales_Agreement_Name#" is in need of approval.<br>
					Requested Approval by: #uName#<br>
					Requested Approval on: #DateFormat(RFADate, "mm/dd/yyyy")#
					</TD>
					</TR>
					</TABLE>
					<!---<cfif appSettings.getSendAutoAttachments()>--->
					<cfif appSettings.getDisplayQuoteLetter() eq 0>    <!--- 30738 --->
						<CF_Writing_Email_Attachment
			  				Naming_Format="Program_#getThisProgramsStatus.Export_Sales_Agreement_Name#"
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
				<!--- update RFA sent bit --->
				<cfquery name="update_RFA_Email_Bit" datasource="#application.datasource#">
					UPDATE Export_Sales_Agreement
					SET RFA_Email_Sent = 1
					WHERE Export_Sales_Agreement_ID = <cfqueryparam value="#Export_Sales_Agreement_ID#" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
	</cfoutput>
