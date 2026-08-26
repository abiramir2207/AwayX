<!---
Document		:	/ANYTHING_AUTOMATED/EMAIL/rfa_billback_emailer.cfm
Author			:	Deepa Kunnath
Date Created	:	Nov 08, 2004
Purpose			:	To send RFA mail
Arguments		:	Billback_ID
Called from		: 
					/Billbacks/approval/Send_Agree_Email.cfm	
--->

<cfset didWeSendEmail = 0 />

<cfparam name="LocationFrom" default="Auto">	

	
<!--- <!--- <!--- <!--- <!--- STATUS CHANGE NOTIFICATION EMAIL ---> ---> ---> ---> --->
<CFQUERY NAME="getThisBillbackStatus" datasource="#application.datasource#">
	SELECT 	Billback_ID, BB_Title, BB_Creator_User_Position_ID, BB_Code, BB_Request_Approval_Date, BB_Request_Approval_User_ID
	FROM 	Billback
	WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>
		
<cfset userManager = createobject("component", "components.user.userManager") />
<CFSET userPositionID = getThisBillbackStatus.BB_Creator_User_Position_ID>
<CFSET positionList = createobject("component", "components.geography.position").getFirstPositionAbove(userPositionID)>
<cfset RFADate 		= getThisBillbackStatus.BB_Request_Approval_Date>

<cfset qCurrentUserInfo = userManager.getUser(getThisBillbackStatus.BB_Request_Approval_User_ID) />
<cfset uName = qCurrentUserInfo.User_Full_Name>
<cfset uEmail = qCurrentUserInfo.User_Email>


<cfif NOT isDefined("appSettings")>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
</cfif>

<cfset EmailList = "">

<cfif appSettings.getProgramAgreeEscalate() EQ 1><!------ If ProgramAgreeEscalate is on send mail to CRAs ----->
	<cfif NOT isDefined("BillbackManager")>
		<cfset BillbackManager = CreateObject("component", "components.billback.BillbackManager").init() />
	</cfif>
	<cfset userPositionContactInfo = BillbackManager.getApprovableUsers(Billback_ID) />
	<cfset EmailList = valuelist(userPositionContactInfo.User_Email)>
<cfelse><!------ send to all users in the position above the creating user position ----->
	<!------ uncomment if any client needs this. ----->
	<!------ 
	<cfif listlen(trim(PositionList)) GT 0>
		<cfset ContactUserPositionID = getBillbacks.BB_Creator_User_Position_ID />
		<cfinclude template="get_user_position_contact_bb.cfm">
		<cfset EmailList = valuelist(userPositionContactInfo.User_Email)>
	</cfif> 
	----->
</cfif>
			<!--- D38427 : Billback email notifications START --->
			<cfset useLakebaseForemailevent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForemailevent>
	<cftry>
		<cfset emailevent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "billback_rfa_agree_email_event"
			}), "billback_rfa_agree_email_event"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForemailevent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForemailevent>
<cfquery name="emailevent" datasource="#application.datasource#">
			select billback_rfa_agree_email_event
			from _application_Settings
			</cfquery>
</cfif>
			<cfif appSettings.getBBAgreeEmail() AND emailevent.billback_rfa_agree_email_event EQ 2>	
					<cfset useremail = 0>
					<cfset useremail = ListFind(EmailList, request.AccessStructure.User_Email)> 
					<cfif useremail>
							<cfset EmailList = ListDeleteAt(EmailList, #useremail#)>
					</cfif>
			</cfif>
				<!--- D38427 : Billback email notifications END --->	
	
<cfoutput>		
<cfloop index="EAddr" list="#EmailList#">
<!--- 
<cfset EAddr = "evazquez@awayx.com"> 
--->

	<CF_EMAILWRAPPER 
		TO			=	"#EAddr#"
		FROM		=	"#uEmail#"
		SUBJECT		=	"Billback #getThisBillbackStatus.BB_Code# is in need of approval."
		TYPE		=	"html" 
		messagetype="1" 
		generatedby="2"
		appArea="3"
	>
		<TABLE>
		<TR>
		<TD VALIGN="top">
		Billback [#getThisBillbackStatus.BB_Code#] "#getThisBillbackStatus.BB_Title#" is in need of approval.<br>
		Requested Approval by: #uName#<br>
		Requested Approval on: #DateFormat(RFADate, "mm/dd/yyyy")#
		</TD>
		</TR>
		</TABLE>					
	</CF_EMAILWRAPPER>
</cfloop>
<cfset didWeSendEmail = 1 />

	
</cfoutput>
