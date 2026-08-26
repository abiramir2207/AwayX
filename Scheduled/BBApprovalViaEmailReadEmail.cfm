<!---
	Copyright (c)2009 Blacksmith Applications, Inc.
	Filename:			AwayX/Scheduled/BBApprovalViaEmailReadEmail.cfm
	Created:			8/14/2018
	Developer:			kvangapalli
	Description:		This file reads the incoming email from users and prepares a billbacks list and sends for approval.
						This is a copy of the file AwayX/Scheduled/ApprovalViaEmailReadEmail.cfm
	Usage:				AwayX/settings/app_settings_approval_via_email.cfm
	Modified:			8/15/18 D78742 - Remote Approval for Billbacks - Initial Commit
--->

<!---
1 	Read new email --- DONE
2	Loop through each mail --- DONE
3	Find the mail id and userid --- DONE
4	verify the fromId, userid and sentId --- DONE
5	verify pin matches --- DONE
6	If 4 or 5 verification fails email back failure  --- DONE
7	else - verify that the billbacks received are in the sent email --- DONE
8	If billbacks match build a string to pass it to auto approve --- DONE
9	Mark the record in db as received and set the email as read --- DONE
10 	Send an email to the user confirming list of billbacks approved --- DONE (Sent by Mass Approval process)
--->

<cfset variables.newLine = " <br/>" />

<!--- Get application settings --->
<cfset applicationSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = applicationSettingsManager.get()>

<!--- Run this job obly if the app setting is on --->
<cfif appSettings.get_Setting('BB_Approval_Via_Email') >

	<!--- Begin: Declare all components used --->
	<cfset application.oController.getObject(path="mvc.Models.Program.Approval.EmailApprovalManager",name="EmailApprovalManager",bReload= 1) />
	<cfset application.oController.getObject(path="components.user.userManager",name="UserManager",bReload= 1) />
	<cfset application.oController.getObject(path="components.settings.encryption",name="cryp_key",bReload= 0) />
	<cfset variables.cryp_key  = application.ocryp_key.getPasswordKey() />
	<!--- End: Declare all components used --->

	<cfset variables.qGetAutoApproverSettings = application.oEmailApprovalManager.getAutoApproverSettings() />
	<cfset variables.bbAutoApproveEmail       = variables.qGetAutoApproverSettings.BB_Auto_Approve_Email />
	<cfset variables.userName                 = variables.qGetAutoApproverSettings.userName />
	<cfset variables.mailServer               = variables.qGetAutoApproverSettings.mail_Server />
	<cfset variables.domainServer             = variables.qGetAutoApproverSettings.domain_Server />
	<cfset variables.mailFolder               = variables.qGetAutoApproverSettings.mail_Folder />
	<cfset variables.mailSSL                  = variables.qGetAutoApproverSettings.Mail_SSL />
	<cfset variables.bbNumberLen              = application.oUserManager.getBillbackNumberLen() />
	<cfset variables.userBillbacksArray       = arraynew(1) />
	<cfset variables.newMail                  = 0 />

	<!--- Use the decrypt function to get the password --->
	<cf_cryp string="#variables.qGetAutoApproverSettings.password#" type="de" key="#variables.cryp_key#">
	<cfparam name="cryp.value" 	  default=""/>
	<cfset variables.password 	= cryp.value />

	<cfparam name="bbDetailsDelimiterFirst"	  default="0">
	<cfparam name="bbDetailsDelimiterLast" 	  default="0">

	<!--- Dev Note: KAL; 08/27/2012; Dxxxx: Remote Approval for Exchange 2010 using EWS Java API --->
	<!--- ********** begin: java objects for exchange 2010 support ********** --->
	<!--- 1. Create an instance of the ExchangeService class --->
	<cfobject type="Java" class="microsoft.exchange.webservices.data.core.ExchangeService" name="service">
	<cfset service.init()>

	<!--- 2. Set the credentials --->
	<!--- 2a. Create an instance of the WebCredentials class --->
	<cfobject type="Java" class="microsoft.exchange.webservices.data.credential.WebCredentials" name="credentials">
	<cfset credentials.init("#variables.userName#","#variables.password#", "#variables.domainServer#")>			<!--- 2b. Set the credentials --->
	<cfset service.setCredentials(credentials) />																<!--- 2c. Set the credentials in the service object --->

	<!--- 3.  Set the URL to Exchange (stay away from autodsicovery) --->
	<cfif variables.mailSSL>
		<cfset variables.exchangeURL = "https://#mailServer#/EWS/Exchange.asmx" />
	<cfelse>
		<cfset variables.exchangeURL = "http://#mailServer#/EWS/Exchange.asmx" />
	</cfif>
	<cfobject type="Java" class="java.net.URI" name="uri">									<!--- 3a. Create an instance of the uri class --->
	<cfset uri.init(variables.exchangeURL) />												<!--- 3b. Set the full path --->
	<cfset service.setUrl(uri) />															<!--- 3c. Set the url in the service object --->

	<!--- Create a instance of the EmailMessage class to assign each mail to it --->
	<cfobject type="Java" action="create" class="microsoft.exchange.webservices.data.core.service.item.EmailMessage" name="message">
	<cfset message = message.init(service) />								<!--- Initiate the EmailMessage instance to the service object --->

	<!--- Create a instance of the MessageBody class to send invalid pin message --->
	<cfobject type="Java" class="microsoft.exchange.webservices.data.property.complex.MessageBody" name="invalidPinMsgBody">
	<cfset invalidPinMsgBody.init("You entered an invalid pin. Please enter the correct pin")>	<!--- Build Message content for pin failure --->

	<cfobject type="Java" class="microsoft.exchange.webservices.data.core.enumeration.property.WellKnownFolderName" name="wkfn">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.core.enumeration.service.ConflictResolutionMode" name="conflictMode">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.core.enumeration.service.DeleteMode" name="deleteMode">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.core.PropertySet" name="propertySet">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.property.complex.EmailAddress" name="emailAddress">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.property.complex.FolderId" name="folders">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.property.complex.Mailbox" name="mailBox">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.search.filter.SearchFilter" name="searchFilter">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.search.FolderView" name="folderView">
	<cfobject type="Java" class="microsoft.exchange.webservices.data.search.ItemView" name="itemView">

	<!--- ********** end: java objects for exchange 2010 support ********** --->

	<!--- Begin: Find unread mail using the Java EWS API --->
	<!--- Folder Structure is as follows: RootFolder > Folders/Programs/Billbacks > [Client] --->
	<cfset rootfolder =  folders.init(wkfn.MsgFolderRoot) />					<!--- Get an instance of the root folder --->
	<cfset viewFolders = service.findFolders(rootfolder, folderView.init(50) ) />

	<!--- Get the list of folders from the root folder  --->
	<cfloop array="#viewFolders.getFolders()#" index="xFolder">
		<!--- <cfif xFolder.getDisplayName() eq listFirst(variables.mailFolder, '/')> --->
		<cfif xFolder.getDisplayName() eq "Billbacks">
			<cfoutput>
				<cfset viewSubFolders = xFolder.findFolders(folderView.init(xFolder.getChildFolderCount())) />

				<!--- Loop over the list of child folders and get the client folder  --->
				<cfloop array="#viewSubFolders.getFolders()#" index="xSubFolder">
					<cfif xSubFolder.getDisplayName() eq  listLast(variables.mailFolder, '/') >

						<!--- Process only when there are emails; Otherwise errors when no emails --->
						<cfif xSubFolder.getTotalCount()>
							<cfset viewItems = xSubFolder.findItems(itemView.init(xSubFolder.getTotalCount())) />

							<cfloop array="#viewItems.getItems()#" index="item">
								<cfset message = message.bind(service, item.getId())/>
								<cfif NOT message.IsRead > <!--- get only the unread mails --->

									<!--- Declare necessary variables --->
									<cfset variables.newMail = variables.newMail + 1 />
									<cfset variables.msgUId = message />
									<cfset variables.msgSentId = "" />
									<cfset variables.msgFrom = "" />
									<cfset variables.msgContent = "" />

									<!--- Java EWS returns time in UTC; convert it to local/ET --->
									<!--- <cfset variables.msgDateTime = message.getDateTimeReceived() /> --->
									<cfset variables.msgDateTime = DateConvert("utc2Local", message.getDateTimeReceived()) />
									<cfset variables.msgSubject	 = "" />
									<cfset variables.msgStruct = structNew() />

									<cfset variables.msgPinArr = "" />
									<cfset variables.msgPin = "" />
									<cfset variables.msgUserArr = "" />
									<cfset variables.msgUserId = "" />
									<cfset variables.msgBillbacksArr = "" />
									<cfset variables.msgBillbacks = "" />
									<cfset variables.verifyReceivedBBEmailPin = 0 />
									<cfset variables.getMatchingBillbacks = "" />

									<!--- Set values to the variables --->
									<cfset variables.msgSubject	= message.getSubject() />
									<cfset variables.msgContent = message.getBody() />
									<cfset variables.msgFrom 	= message.getSender() />

									<!--- Get the pin --->
									<cfset variables.msgPinArr 	= reMatchNoCase("##\d+##", variables.msgContent) />	<!--- Returns an array --->
									<!--- Get the email sentId & userId --->
									<cfset variables.msgUserArr	= reMatchNoCase("(\d+\|)[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}", variables.msgContent) />	<!--- Returns an array --->

									<!--- Dev Note: KAL; D20807: Prog approval via mobile device - delete inbound junk and 'out of office' replies
										  If the pin or the userId array lengths are zero, then move the email to deleted folder.--->
									<cfif (arrayLen(variables.msgPinArr) eq 0) or (arrayLen(variables.msgUserArr) eq 0)>

										<!--- Delete/move the email to Deleted Items folder --->
										<!--- <cfset message.move(wkfn.DeletedItems) /> --->
										<cfset message.delete(deleteMode.MoveToDeletedItems) />

									<cfelse>
										<!--- Extract pin --->
										<cfset variables.msgPin 	= replaceNoCase(variables.msgPinArr[1], "##", "", "all")  /> <!--- Pin should be in the first cell of the array --->
										<!--- Extract emailId & userId --->
										<cfset variables.msgSentId	= listFirst(arrayToList(variables.msgUserArr), "|")/>
										<cfset variables.msgUserId	= listLast(arrayToList(variables.msgUserArr), "|")/>

										<!--- Get the billbacks from email --->
										<cfset variables.msgBillbacksArr	= reMatchNoCase("[0-9A-Z]{2}-[0-9A-Z][0-9]{#(variables.bbNumberLen-1)#}-[0-9]{2}", variables.msgContent) /> 		<!--- Returns an array --->
										<cfset variables.msgBillbacks 	= arrayToList(variables.msgBillbacksArr) />

										<!--- Build Message header content for pin failure --->
										<cfset variables.failureMsg = "You entered incorrect pin. Please enter the correct pin" />
										<cfset variables.failureMsg = variables.failureMsg & "#variables.newLine#"/>
										<cfset variables.failureMsgHdr = "-----Original Message-----" />
										<cfset variables.failureMsgHdr = variables.failureMsgHdr & "#variables.newLine#" />
										<cfset variables.failureMsgHdr = variables.failureMsgHdr & "From: " & variables.msgFrom & "#variables.newLine#" />
										<cfset variables.failureMsgHdr = variables.failureMsgHdr & "Sent: " & dateFormat(variables.msgDateTime, "medium") & " " & timeFormat(variables.msgDateTime, "medium") />
										<cfset variables.failureMsgHdr = variables.failureMsgHdr & "#variables.newLine#" />
										<cfset variables.failureMsgHdr = variables.failureMsgHdr & "To: " & variables.bbAutoApproveEmail & "#variables.newLine#" />
										<cfset variables.failureMsgHdr = variables.failureMsgHdr & "Subject: " & variables.msgSubject & "#variables.newLine#" />
										<cfset variables.failureMsgHdr = variables.failureMsgHdr & "#variables.newLine#" />

										<!--- verify email and pin --->
										<cfset variables.verifyReceivedBBEmailPin	= application.oEmailApprovalManager.verifyReceivedBBEmailPin(variables.msgSentId, variables.msgUserId, variables.msgFrom, variables.msgPin) />

										<cfif variables.verifyReceivedBBEmailPin>
											<!--- get the list of billbacks --->
											<cfset variables.getMatchingBillbacks = application.oEmailApprovalManager.getMatchingBillbacks(variables.msgSentId, variables.msgBillbacks) />

										<cfelse>
											<!--- Email back Pin verification failure --->
											<CF_EMAILWRAPPER
												TO="#variables.msgFrom#"
												FROM="#variables.bbAutoApproveEmail#"
												SUBJECT="#variables.msgSubject# - Incorrect Pin"
												TYPE="html"
												messagetype="1"
												generatedby="1"
												apparea="1"
												logMessage="1">

												#variables.failureMsg#   		#variables.newLine#
												#variables.failureMsgHdr#   #variables.newLine#
												#variables.msgContent#

											</CF_EMAILWRAPPER>
										</cfif> <!--- variables.verifyReceivedBBEmailPin --->

										<!--- If the email is verified and matching billbacks are found in the email then mass approve them  --->
										<cfif variables.getMatchingBillbacks.recordCount >

											<!---
											<cfset variables.userExists = 0> <!--- variable to record if user already in array and whether to add or append new billbacks/record --->
											<cfloop from="1" to="#arraylen(userBillbacksArray)#" index="looper" >
												<cfif variables.msgUserId eq structFind(variables.userBillbacksArray[looper], "user_Id") >
													<!--- User is in array then append the billbacks to the billbacks list  --->
													<cfset variables.userBillbacksArray[looper].billbacks = variables.userBillbacksArray[looper].billbacks & "," & variables.getMatchingBillbacks.Billback_ID />
													<cfset variables.userExists = 1>
												</cfif>
											</cfloop>
											--->

											<!--- If user not in array then add the billbacks to new row in array --->
											<cfloop query="variables.getMatchingBillbacks">
												<!--- get the User credentials for AccessStructure for this user --->
												<cfset variables.qUserInfo = application.oUserManager.getUserInfo(variables.msgUserId) />

												<cfset variables.temp = arrayAppend(variables.userBillbacksArray, structNew()) >
												<cfset variables.userBillbacksArray[arraylen(userBillbacksArray)].billbacks       = variables.getMatchingBillbacks.Billback_ID />
												<cfset variables.userBillbacksArray[arraylen(userBillbacksArray)].Payment_Type    = variables.getMatchingBillbacks.Approved_Payment_Type />
												<cfset variables.userBillbacksArray[arraylen(userBillbacksArray)].user_Id         = variables.qUserInfo.user_Id />
												<cfset variables.userBillbacksArray[arraylen(userBillbacksArray)].user_Email      = variables.qUserInfo.user_Email />
												<cfset variables.userBillbacksArray[arraylen(userBillbacksArray)].user_name       = variables.qUserInfo.name_first & " " & variables.qUserInfo.name_last />
												<cfset variables.userBillbacksArray[arraylen(userBillbacksArray)].user_code       = variables.qUserInfo.user_code />
												<cfset variables.userBillbacksArray[arraylen(userBillbacksArray)].profiles_Id     = variables.qUserInfo.profiles_Id />
												<cfset variables.userBillbacksArray[arraylen(userBillbacksArray)].company_Main_Id = variables.qUserInfo.Company_Main_ID />
											</cfloop>

											<!--- Mark these billbacks in this email and all other emails as processed --->
											<cfset variables.setEmailProcessed	= application.oEmailApprovalManager.setBBEmailProcessed(variables.msgSentId, variables.msgUserId, variables.getMatchingBillbacks.Billback_ID, variables.msgDateTime, variables.msgUId) />

										</cfif> <!--- variables.getMatchingBillbacks --->

										<!--- Mark this email read --->
										<cfset message.IsRead = javacast("boolean", true) />
										<cfset temp = message.Update(conflictMode.AutoResolve) />

									</cfif> <!--- Delete invalid email to Deleted Items folder --->
								</cfif> <!--- message.IsRead --->
							</cfloop> <!--- item --->
						</cfif> <!--- end: Process only when there are emails  --->
					</cfif>	<!--- xSubFolder.getDisplayName() [clients directory] --->
				</cfloop> <!--- end : client folder loop --->
			</cfoutput> <!--- xFolder.getDisplayName() [folders directory] --->
		</cfif> <!--- root --->
	</cfloop> <!--- end : root folder loop --->
	<!--- End: Find unread main using the Java EWS API --->


	<!--- Dev Note: KAL; 7/19/2010; D23915: Single Instance Remote Approval
		  loop over the billbacks per user and call Mass Approval --->
	<!--- Output the contents to a vairable so that we can email --->
	<cfsavecontent variable="variables.processEmails">
		<cfloop from="1" to="#arraylen(userBillbacksArray)#" index="looper" >
			<center>
				<cfoutput>User: #variables.userBillbacksArray[looper].user_name# (#variables.userBillbacksArray[looper].user_code#); #variables.userBillbacksArray[looper].user_Email#<br></cfoutput>
			</center>
			<!--- set AccessStructure settings for this user --->
			<cfset request.accessStructure.user_Id = variables.userBillbacksArray[looper].user_Id />
			<cfset request.accessStructure.user_Email = variables.userBillbacksArray[looper].user_Email />
			<cfset request.accessStructure.profiles_id = variables.userBillbacksArray[looper].profiles_Id />
			<cfset request.accessStructure.company_Main_Id = variables.userBillbacksArray[looper].Company_Main_ID />

			<!--- Approve the Billbacks --->
			<cfset url.BBID = variables.userBillbacksArray[looper].billbacks />
			<cfset url.type = variables.userBillbacksArray[looper].Payment_Type  />
			<cfinclude template="/get_access_profile.cfm">
			<cfinclude template   = "/billbacks/scorecard/ajax/pay_claimed_expected.cfm" >

			<!--- Dev Note: Kal; D43870: Run Remote Approval Send on demand for users with Single option --->
			<cfset url.billback_Id = 0 />
				<cfsilent>
					<cfset url.billback_Id = variables.userBillbacksArray[looper].billbacks  />
					<cfinclude template="/Scheduled/BBApprovalViaEmailSendEmail.cfm" >
				</cfsilent>
			<br><br>
		</cfloop>
	</cfsavecontent>

	<!--- Output on the screen --->
	<cfoutput>
		<b>Date : #DateFormat(now(), "mm/dd/yyyy")# #TimeFormat(now(), "short")# ET</b> <br/>
		<b>#variables.newMail# - Approval Emails Processed </b> <br/> <br/>
		#variables.processEmails#
	</cfoutput>

	<!--- Send job success email to the user in settings panel --->
	<cfoutput>
		#variables.processEmails#
		<CF_EMAILWRAPPER
			TO="#appSettings.get_Setting('BB_Email_In_Job_Success')#"
			FROM="#variables.bbAutoApproveEmail#"
			SUBJECT="Billback Email Approval Inbound Job Success"
			TYPE="html"
			messagetype="1"
			generatedby="1"
			apparea="1"
			logMessage="1">
				<b>Date : #DateFormat(now(), "mm/dd/yyyy")# #TimeFormat(now(), "short")# ET</b><br/>
				<b>#variables.newMail# - Approval Emails Processed </b><br/><br/>
				#variables.processEmails#
		</CF_EMAILWRAPPER>
	</cfoutput>

</cfif> <!--- end: Run this job obly if the app setting is on --->

