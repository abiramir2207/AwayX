<!---
Name: 			BillbackEmailManager.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	09/01/2011
Created By:    	Tim Ford
Description:	I am responsible for Billback email notifications.
--->

<cfcomponent displayname="BillbackEmailManager" hint="Component to handle all Billback email notifications">

	<cfset appSettings = application.appSettingsGet />
	
	<cffunction name="sendAgreeEmail" access="public" output="false" hint="Function that will send email notifications when a user agrees to a billback">	
		
		<cfargument name="billbackId" 	type="string"	required="true">
		<cfargument name="userId"		type="string"	required="true">
		
		<cfscript>
			//set local variables
			var strBillbackId			= "";
			var strUserId				= "";
			var objBillbackManager 		= "";
			var objUserManager 			= "";
			var objPosition				= "";
			var qGetThisBillbackStatus	= "";
			var strUserPositionID		= "";
			var qCurrentUserInfo		= "";
			var dtRFADate				= "";
			var qRFAUserInfo			= "";

			//assign local variables
			strBillbackId		= arguments.billbackId;
			strUserId			= arguments.userId;
			objBillbackManager	= CreateObject("component", "components.billback.BillbackManager");
			objUserManager		= CreateObject("component", "components.user.userManager");
			
			qGetThisBillbackStatus 	= objBillbackManager.getBillbackDetails(strBillbackId);
			strUserPositionID		= qGetThisBillbackStatus.BB_Creator_User_Position_ID;
			qRFAUserInfo	 		= objUserManager.getUser(qGetThisBillbackStatus.BB_Request_Approval_User_ID);
			dtRFADate				= qGetThisBillbackStatus.BB_Request_Approval_Date;

			//this code is to handle for the issue when the billback rfa user is the auto pay user
			if (trim(qRFAUserInfo.User_Email) eq ""){
				qCurrentUserInfo =  objUserManager.getUser(strUserId);
			}
			else{
				qCurrentUserInfo = qRFAUserInfo;
			}
			
		</cfscript>
		
		<cfif appSettings.getBBAgreeEmail()>
		
			<cfif objBillbackManager.sendEmailtoNextCRA(strBillbackId, strUserId)>
						
				<cfset uName = qCurrentUserInfo.User_Full_Name>
				<cfset uEmail = qCurrentUserInfo.User_Email>
				
				<cfset EmailList = "">
				<!--- D31428:Approval Routing not generating E-Mail START 
					Uncommented below if and comment below variable.--->
				<cfif appSettings.getProgramAgreeEscalate() EQ 1><!------ If ProgramAgreeEscalate is on send mail to CRAs ----->
					<cfset userPositionContactInfo = objBillbackManager.getApprovableUsers(strBillbackId) />
					<cfset EmailList = valuelist(userPositionContactInfo.User_Email)>
				</cfif>
				
				<!---<cfset userPositionContactInfo = objBillbackManager.getApprovableUsers(strBillbackId) />--->
				<!--- D31428:Approval Routing not generating E-Mail END --->
				
				<cfloop index="EAddr" list="#EmailList#">
				
					<cf_emailwrapper 
						to			=	"#EAddr#"
						from		=	"#uEmail#"
						subject		=	"Billback #qGetThisBillbackStatus.BB_Code# is in need of approval."
						type		=	"html" 
						messageType	=	"1" 
						generatedBy	=	"2"
						appArea		=	"3"
					>
						<table>
							<tr>
								<td valign="top">
									<cfoutput>
									Billback [#qGetThisBillbackStatus.BB_Code#] "#qGetThisBillbackStatus.BB_Title#" is in need of approval.<br>
									Requested Approval by: #uName#<br>
									Requested Approval on: #DateFormat(dtRFADate, 'mm/dd/yyyy')#
									</cfoutput>
								</td>
							</tr>
						</table>					
					</cf_emailwrapper>
					
				</cfloop>
				
				<cfset objBillbackManager.setSentEmailtoNextCRA(strBillbackId, strUserId) />

			</cfif>
			
		</cfif>

	</cffunction>
	
	<cffunction name="sendApproveEmail" access="public" output="false" hint="Function that will send email notifications when a user approves a billback">
	
		<cfargument name="billbackId"	type="string"	required="true">
		<cfargument name="userId"		type="string"	required="true">
		
		<cfscript>
			//set local variables
			var strBillbackId			= "";
			var objBillbackManager 		= "";
			var qGetPayeeType			= "";
			var strContactAdminEmail	= "";
			var qGetContactAdminEmail	= "";
			var qGetEmailAddresses		= "";
			var qGetApprovedUserInfo	= "";

			//assign local variables
			strBillbackId		= arguments.billbackId;
			objBillbackManager	= CreateObject("component", "components.billback.BillbackManager");
			
			qGetPayeeType 	= objBillbackManager.getBillbackDetails(strBillbackId);
		</cfscript>
		
		<cfset useLakebaseForGetBillbackEmail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGetBillbackEmail>
	<cftry>
		<cfset GetBillbackEmail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "bb_approved_email"
			}), "bb_approved_email"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBillbackEmail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBillbackEmail>
<cfquery name="GetBillbackEmail" datasource="#application.datasource#">
			SELECT	BB_Approved_Email 
			FROM 	_application_settings
		</cfquery>
</cfif>
		
		<cfif Len(trim(qGetPayeeType.BB_Request_Approval_User_ID)) GT 0 AND GetBillbackEmail.BB_Approved_Email EQ 1>
			
			<cfquery name="qGetContactAdminEmail" datasource="#application.datasource#">
				SELECT	User_Email
				FROM 	_Users
						INNER JOIN Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
				WHERE 	Contact_Administrator = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
			</cfquery>
			
			<cfif qGetContactAdminEmail.recordCount GT 0>
			
				<cfset strContactAdminEmail = qGetContactAdminEmail.User_Email />
				
			<cfelse>
			
				<cfquery name="qGetContactAdminEmail" datasource="#application.datasource#">
					SELECT 	User_Email
					FROm 	_Users
							INNER JOIN Company_Main ON _Users.Company_Main_ID = Company_Main.Company_Main_ID
					WHERE 	Is_System_Administrator = <cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">
				</cfquery>
				
				<cfif qGetContactAdminEmail.recordCount GT 0>
				
					<cfset strContactAdminEmail = qGetContactAdminEmail.User_Email />
					
				</cfif>
				
			</cfif>
			
			<cfquery name="qGetEmailAddresses" datasource="#application.datasource#">
				SELECT	RFA_User.User_Email RFA_User_Email
				FROM	_Users RFA_User
				WHERE   RFA_User.User_ID = <cfqueryparam value="#qGetPayeeType.BB_Request_Approval_User_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND		RFA_User.Deleted = 0
			</cfquery>
			
			<cfquery name="qGetApprovedUserInfo" datasource="#application.datasource#">
				SELECT	Date_Approved,
						_Users.Name_First + ' ' + _Users.Name_Last AS Approved_User_Full_Name,
						User_Email AS Approving_User_Email
				FROM	BB_Approved
						INNER JOIN _Users ON _Users.User_ID = BB_Approved.User_Approved
				WHERE	BB_Approved.Billback_ID = <cfqueryparam value="#strBillbackId#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			
			<cfset Approved_Date = Now() />
			
			<cfset Approved_User = "" />
			
			<cfif qGetApprovedUserInfo.RecordCount GT 0>
				<cfset Approved_Date = qGetApprovedUserInfo.Date_Approved>
				<cfset Approved_User = qGetApprovedUserInfo.Approved_user_Full_Name>
			</cfif>
			
			<cfif qGetEmailAddresses.recordCount GT 0>
			
				<cfif compareNoCase(qGetEmailAddresses.RFA_User_Email,qGetApprovedUserInfo.Approving_User_Email) IS NOT 0>

					<cf_emailwrapper 
						to			=	"#qGetEmailAddresses.RFA_User_Email#"
						from		=	"#strContactAdminEmail#"
						subject		=	"Billback #qGetPayeeType.BB_Code# has been approved"
						type		=	"html"
						messageType = 	"1"
						generatedBy	=	"2"
						appArea		=	"3">		
							<table>
								<tr>
									<td valign="top">
										<cfoutput>Billback [#qGetPayeeType.BB_Code#] "#qGetPayeeType.BB_Title#" has been approved by #Approved_User# on #DateFormat(Approved_Date, 'mm/dd/yyyy')#</cfoutput>
									</td>
								</tr>
							</table>
					</cf_emailwrapper>
					
				</cfif>
				
			</cfif>
			
		</cfif>
	
	</cffunction>
	
</cfcomponent>