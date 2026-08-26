<!---
	Copyright (c)2018 Blacksmith Applications, Inc.
	Filename:			AwayX/Scheduled/BBApprovalViaEmailSendEmail.cfm
	Created:			8/2/2018
	Developer:			kal
	Description:		finds billback that are in RFA & Agreed by Analyst and sends out the emails to CRA for approval
	Tip:				If a billbackId is passed to this file, then email is sent only for that billback
	Modified:			8/15/18 D78742 - Remote Approval for Billbacks - Initial Commit
--->
<cfparam name="url.billback_Id" default="0">
<cfset variables.newLine = " <br/>" />

<!--- Get application settings --->
<cfset applicationSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = applicationSettingsManager.get()>

<!--- Run this job obly if the app setting is on --->
<cfif appSettings.get_Setting('BB_Approval_Via_Email') >

	<!--- Begin: Initalise the components needed --->
	<cfset variables.billbackManager = createobject("component", "components.Billback.BillbackManager").init() />
	<cfset application.oController.getObject(path="mvc.Models.Program.Approval.EmailApprovalManager",name="EmailApprovalManager",bReload= 1) />
	<!--- End: Initalise the components needed --->

	<!--- Get Auto Approve Email Address for "From" --->
	<cfset variables.bbAutoApproveEmail = application.oEmailApprovalManager.getAutoApproverSettings().BB_Auto_Approve_Email />

	<!--- Get the email instructions --->
	<cfset variables.EmailInst = appSettings.get_Setting('BB_Email_Approval_Instructions') />

	<!--- Get the list of billabcks by user --->
	<cfset variables.qGetApprovableBillbacksUsersList = variables.billbackManager.getApprovableUsers(
														billbackId=url.billback_Id,
														bbRemoteApproval=1) />


	<!--- Dev Note: Kal; D43870: Run Remote Approval Send on demand for users with Single option  --->
	<cfquery name="variables.qUserList" dbtype="query" >
		SELECT 	DISTINCT user_ID, user_Email, user_Code, user_Full_Name, BB_Remote_Approval_Option
		FROM 		variables.qGetApprovableBillbacksUsersList
	</cfquery>

	<!--- <cfdump var="#variables.qUserList#" abort="true"> --->
	<cfoutput query="variables.qUserList">

		<cfset variables.msgHeader	= 	"#variables.qUserList.user_Full_Name#" & " (#variables.qUserList.user_Code#),"/>
		<cfset variables.msgHeader	= 	variables.msgHeader & "#variables.newLine#" & "#variables.newLine#" />
		<cfset variables.msgHeader	= 	variables.msgHeader & "#variables.EmailInst#" & "#variables.newLine#" />
		<cfset variables.msgBody 	= 	variables.newLine />
		<cfset variables.msgFooter	= 	"--- DO NOT EDIT BELOW THIS LINE ---" & "#variables.newLine#" />

		<!--- Get Max Sent ID --->
		<cfset variables.qGetMaxSentId = "" />
		<cfquery name="variables.qGetMaxSentId" datasource="#application.dataSource#">
			SELECT ISNULL(MAX(Sent_ID),0)+1  AS maxSentId FROM Email_Approval_User_Billbacks
		</cfquery>

		<!--- Get the program for each user --->
		<cfset variables.qGetUserBillbacks = "" />
		<cfquery name="variables.qGetUserBillbacks" dbtype="query" >
            SELECT  Billback_ID_Int, Billback_ID, BB_Code, BB_Title,
					Billback_Status_ID, Billback_Payee_Type_ID, BB_Reference, referenceNum,
					BB_Date, BB_Start_Date, BB_End_Date,
					BB_Amount, BB_Expected_Amount,
					Payee, Payee_ID,
					Broker_Name, Broker_Shard,
					Operator_Name, BSA_Operator_ID,
					Name, Ship_To,
					User_ID, User_Email,
					Dev_Amount, Dev_Percent,
					lastAgreedUser, lastAgreedName, lastAgreeDate, Agreed_Amount
            FROM 	variables.qGetApprovableBillbacksUsersList
			WHERE 	user_ID = <cfqueryparam value="#variables.qUserList.user_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>


		<!---
			Dev Note: KAL; 7/6/2010; D23915: Remmote approval email option
			Single email per program/Batch email; 1 = Single; 2 = Batch
			If Single add the msg footer and send email
		--->
		<cfif variables.qUserList.BB_Remote_Approval_Option eq 1>

			<!--- Loop through user's billabcks and insert into Email_Approval_User_Billbacks table and build the email body --->
			<cfloop query="variables.qGetUserBillbacks">

				<!--- Check if we sent email recently, otherwise resend it --->
				<cfset variables.checkResendEmail = application.oEmailApprovalManager.bbCheckResendEmail(
														variables.qGetUserBillbacks.User_ID,
														variables.qGetUserBillbacks.Billback_ID) />

				<!--- Check if we sent email recently, otherwise resend it --->
				<cfif variables.checkResendEmail>

					<!--- Insert into table Email_Approval_User_Billbacks --->
					<cfset variables.insertUserBillbacks = application.oEmailApprovalManager.insertUserBillbacks(
															variables.qGetUserBillbacks.User_ID,
															variables.qGetUserBillbacks.Billback_ID,
															variables.qGetUserBillbacks.Billback_ID_Int,
															variables.qGetUserBillbacks.BB_Code,
															variables.qGetMaxSentId.maxSentId,
															variables.qGetUserBillbacks.BB_Amount,  			<!--- Claimed_Amount --->
															variables.qGetUserBillbacks.BB_Expected_Amount, 	<!--- Expected_Amount --->
															variables.qGetUserBillbacks.Agreed_Amount, 			<!--- Agreed_Amount --->
															variables.qUserList.BB_Remote_Approval_Option ) />


					<!--- Build the email msg body/content --->
					<cfsavecontent variable="variables.msgBody">
					<style>
						table, th, td {
						    display: table-cell;
						    border: 0px;
						    padding:2px;
						    text-align: left;
						}
						col { display: table-column; }
						th { background: ##CCC; }
					</style>
					<table>
						<colgroup>
							<col width="120px;">
							<col width="1px;" style="background-color:orange">
							<col width="120px;">
						</colgroup>

						<thead>
						<tr>
							<th colspan="2">Approve This Amount : </th> <th>#numberFormat( variables.qGetUserBillbacks.Agreed_Amount, "($),999.99" )#</th>
						</tr>
						</thead>
						<tr>
							<td>Payable ##</td> <td rowspan="12">&nbsp;</td> <td>#variables.qGetUserBillbacks.BB_Code#</td>
						</tr>
						<tr>
							<td>Payee</td> <td>#variables.qGetUserBillbacks.Payee# (#variables.qGetUserBillbacks.Payee_Id#)</td>
						</tr>
						<tr>
							<td>Title</td> <td>#variables.qGetUserBillbacks.BB_Title#</td>
						</tr>
						<tr>
							<td>Billback Number</td> <td>#variables.qGetUserBillbacks.BB_Reference#</td>
						</tr>
						<tr>
							<td>Reference Number</td> <td>#variables.qGetUserBillbacks.referenceNum#</td>
						</tr>
						<tr>
							<td>Billback Date</td> <td>#variables.qGetUserBillbacks.BB_Date#</td>
						</tr>
						<tr>
							<td>Start Date</td> <td>#variables.qGetUserBillbacks.BB_Start_Date#</td>
						</tr>
						<tr>
							<td>End Date</td> <td>#variables.qGetUserBillbacks.BB_End_Date#</td>
						</tr>
						<tr>
							<td>Claimed Amount</td> <td>#numberFormat( variables.qGetUserBillbacks.BB_Amount, "($),999.99" )#</td>
						</tr>
						<tr>
							<td>Expected Amount</td> <td>#numberFormat( variables.qGetUserBillbacks.BB_Expected_Amount, "($),999.99" )#</td>
						</tr>
						<tr>
							<td>Deviation Amount (%)</td> <td>#numberFormat( variables.qGetUserBillbacks.Dev_Amount, "($),999.99" )# (#variables.qGetUserBillbacks.Dev_Amount#)</td>
						</tr>
						<tr>
							<td>Last Agreed By</td> <td>#variables.qGetUserBillbacks.lastAgreedName# &nbsp; (#dateformat(variables.qGetUserBillbacks.lastAgreeDate, "mm/dd/yyyy")#)</td>
						</tr>
					</table>
					<div>#variables.newLine# </div>
					</cfsavecontent>

					<!--- Build Email Footer --->
					<cfset variables.msgFooter	= 	"--- DO NOT EDIT BELOW THIS LINE ---" & "#variables.newLine#" />
					<cfset variables.msgFooter = variables.msgFooter & "--- " />
					<cfset variables.msgFooter = variables.msgFooter & "#variables.qGetMaxSentId.maxSentId#" & "|" & "#variables.qGetUserBillbacks.User_ID#" />
					<cfset variables.msgFooter = variables.msgFooter & " ---" />
					<cfset variables.msgFooter = variables.msgFooter & "#variables.newLine#" />
					<cfset variables.msgFooter = variables.msgFooter & "#application.returned_customer_setting.Company_Name#"& " -- " &"Contract Management services provided by #Application.CompanyNameFull#" />

					<cfset useLakebaseForGetcompany = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetcompany>
	<cftry>
		<cfset Getcompany = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "company_main_id"
			}), "company_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetcompany = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetcompany>
<cfquery name="Getcompany" datasource="#application.datasource#">
						SELECT 	Top 1 Company_Main_ID
						FROM 	Company_Main
						WHERE 	Deleted = 0		<!--- D45803 :: Template error when creating multiple programs --->
					</cfquery>
</cfif>

					<!--- Email Functionality Begins Here --->
					<CF_EMAILWRAPPER
						to="#variables.qGetUserBillbacks.User_Email#"
						from="#variables.bbAutoApproveEmail#"
						subject="BLACKSMITH BILLBACK APPROVAL REQUEST"
						type="html"
						messagetype="1"
						generatedby="1"
						apparea="1"
						logMessage="1">

							#variables.msgHeader#   #variables.newLine#
							#variables.msgBody#		#variables.newLine#
							#variables.msgFooter#	#variables.newLine#

					</CF_EMAILWRAPPER>
					<!--- Email Functionality Ends Here --->

					<!--- Set the email as sent in the Email_Approval_User_Billbacks table  --->
					<cfset variables.qSetEmailSent = "" />
					<cfquery name="variables.qSetEmailSent" datasource="#application.dataSource#">
						UPDATE	Email_Approval_User_Billbacks
						SET		Email_Sent = <cfqueryparam value="1" cfsqltype="cf_sql_bit" />,
								Email_Sent_Date = getDate()
						WHERE	Sent_ID = <cfqueryparam value="#variables.qGetMaxSentId.maxSentId#" cfsqltype="cf_sql_integer" />
					</cfquery>

					<!--- Get the next Max Sent ID --->
					<cfset variables.qGetMaxSentId = "" />
					<cfquery name="variables.qGetMaxSentId" datasource="#application.dataSource#">
						SELECT ISNULL(MAX(Sent_ID),0)+1  AS maxSentId FROM Email_Approval_User_Billbacks
					</cfquery>

				</cfif> <!--- end cfif: variables.checkResendEmail --->

			</cfloop> <!---end cfloop: variables.qGetUserBillbacks --->

		</cfif> <!--- end cfif: variables.qUserList.BB_Remote_Approval_Option --->

	</cfoutput> <!--- end cfoutput: query="variables.qUserList" --->

	<!--- Output on the screen --->
	<cfoutput>
		<h3>#variables.qGetApprovableBillbacksUsersList.recordCount# - Email requests sent for Approval</h3><br/>
	</cfoutput>

	<!--- Send job success email to the user in settings panel --->
	<!--- Dev Note: Kal; D43870: Run Remote Approval Send on demand for users with Single option --->
	<cfif not(url.billback_Id) >
		<cfoutput>
			<CF_EMAILWRAPPER
				to="#appSettings.get_Setting('BB_Email_Out_Job_Success')#"
				from="#variables.bbAutoApproveEmail#"
				subject="BB Email Approval Outbound Job Success"
				type="html"
				messagetype="1"
				generatedby="1"
				apparea="1"
				logMessage="1">

					<!--- #variables.qUserList.recordCount# - Email requests sent for Approval --->
					#variables.qGetApprovableBillbacksUsersList.recordCount# - Email requests sent for Approval

			</CF_EMAILWRAPPER>
		</cfoutput>
	</cfif>
</cfif>  <!--- appSettings.get_Setting('BB_Approval_Via_Email') --->