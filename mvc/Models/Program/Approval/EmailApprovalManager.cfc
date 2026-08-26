
<cfcomponent displayname="EmailApprovalManager" hint="Handles Email Approval Methods" output="false">

	<!--- Init --->
	<cffunction name="init" output="false" returntype="mvc.Models.Program.EmailApprovalManager">
		<cfreturn this />
	</cffunction>

	<!--- getAutoApproverSettings : Settings for userName, password and mailServer --->
	<cffunction name="getAutoApproverSettings" output="false" returntype="Query" >

		<cfset var qGetAutoApproverSettings = "" />
		<cfquery name="qGetAutoApproverSettings" datasource="#application.datasource#">
			SELECT	UserName, Password, Mail_Server, Domain_Server, Mail_Folder, Auto_Approve_Email, Mail_SSL, BB_Auto_Approve_Email
			FROM 	Auto_Approver_Settings
			WHERE	Deleted = 0
		</cfquery>

		<cfreturn qGetAutoApproverSettings />
	</cffunction>


	<!--- setAutoApproverSettings : Settings for userName, password and mailServer --->
	<cffunction name="setAutoApproverSettings" output="false" returntype="void">
		<cfargument name="userName" required="true" default="" type="String" />
		<cfargument name="password" required="true" default="" type="String" />
		<cfargument name="mailServer" required="true" default="" type="String" />
		<cfargument name="domainServer" required="true" default="" type="String" />
		<cfargument name="mailFolder" required="true" default="" type="String" />
		<cfargument name="autoApproveEmail" required="true" default="" type="String" />
		<cfargument name="bbAutoApproveEmail" required="true" default="" type="String" />

		<cfset var qSetAutoApproverSettings = "" />
		<cfquery name="qSetAutoApproverSettings" datasource="#application.datasource#">
			UPDATE  Auto_Approver_Settings
			SET		UserName 				= <cfqueryparam value="#arguments.userName#" cfsqltype="cf_sql_varchar"/>,
					Password 				= <cfqueryparam value="#arguments.password#" cfsqltype="cf_sql_varchar"/>,
					Mail_Server 			= <cfqueryparam value="#arguments.mailServer#" cfsqltype="cf_sql_varchar"/>,
					Domain_Server 			= <cfqueryparam value="#arguments.domainServer#" cfsqltype="cf_sql_varchar"/>,
					Mail_Folder 			= <cfqueryparam value="#arguments.mailFolder#" cfsqltype="cf_sql_varchar"/>,
					Auto_Approve_Email		= <cfqueryparam value="#arguments.autoApproveEmail#" cfsqltype="cf_sql_varchar"/>,
					BB_Auto_Approve_Email	= <cfqueryparam value="#arguments.bbAutoApproveEmail#" cfsqltype="cf_sql_varchar"/>
			WHERE	Deleted = 0
		</cfquery>

	</cffunction>


	<!--- Verify the received program email msg, address, and pin we got was for the original email we sent --->
	<cffunction name="verifyReceivedEmailPin" output="false" returntype="Numeric" >
		<cfargument name="sentId" required="true" default="0" type="numeric"/>
		<cfargument name="userId" required="true" default="0" type="UUID" />
		<cfargument name="fromId" required="true" default="0" type="String" />
		<cfargument name="pin" required="true" default="0" type="numeric"/>

		<cfset var emailId = arguments.fromId >
		<cfif find("<", arguments.fromId) >
			<cfset emailId = listLast(listFirst(arguments.fromId, ">"), "<") >
		</cfif>

		<cfset var qVerifyReceivedEmailPin = "" />
		<cfquery name="qVerifyReceivedEmailPin" datasource="#application.datasource#">
			SELECT	EAUP.Sent_ID
			FROM 	Email_Approval_User_Programs EAUP
			INNER JOIN _Users U
				ON	U.User_ID = EAUP.User_ID
			WHERE	EAUP.Sent_ID = <cfqueryparam value="#arguments.sentId#" cfsqltype="cf_sql_integer">
			AND		EAUP.User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_idstamp">
			AND		U.User_Email = <cfqueryparam value="#emailId#" cfsqltype="cf_sql_varchar">
			AND		U.User_Pin = <cfqueryparam value="#hash(arguments.pin)#" cfsqltype="cf_sql_varchar">
			AND		U.Deleted = 0
		</cfquery>

		<cfreturn qVerifyReceivedEmailPin.recordcount />
	</cffunction>


	<!--- Verify the received BB email msg, address, and pin we got was for the original email we sent --->
	<cffunction name="verifyReceivedBBEmailPin" output="false" returntype="Numeric" >
		<cfargument name="sentId" required="true" default="0" type="numeric"/>
		<cfargument name="userId" required="true" default="0" type="UUID" />
		<cfargument name="fromId" required="true" default="0" type="String" />
		<cfargument name="pin" required="true" default="0" type="numeric"/>

		<cfset var emailId = arguments.fromId >
		<cfif find("<", arguments.fromId) >
			<cfset emailId = listLast(listFirst(arguments.fromId, ">"), "<") >
		</cfif>

		<cfset var qVerifyReceivedBBEmailPin = "" />
		<cfquery name="qVerifyReceivedBBEmailPin" datasource="#application.datasource#">
			SELECT	EAUB.Sent_ID
			FROM 	Email_Approval_User_Billbacks EAUB
			INNER JOIN _Users U
				ON	U.User_ID = EAUB.User_ID
			WHERE	EAUB.Sent_ID = <cfqueryparam value="#arguments.sentId#" cfsqltype="cf_sql_integer">
			AND		EAUB.User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_idstamp">
			AND		U.User_Email = <cfqueryparam value="#emailId#" cfsqltype="cf_sql_varchar">
			AND		U.User_Pin = <cfqueryparam value="#hash(arguments.pin)#" cfsqltype="cf_sql_varchar">
			AND		U.Deleted = 0
		</cfquery>

		<cfreturn qVerifyReceivedBBEmailPin.recordcount />
	</cffunction>


	<!--- Get the list of programs in the email we sent and match them against the received --->
	<cffunction name="getMatchingPrograms" output="false" returntype="String" >
		<cfargument name="sentId" required="true" default="0" type="numeric" />
		<cfargument name="programList" required="true" default="" type="string" />

		<cfset var matchingProgramIds = "" />
		<cfset var qGetMatchingPrograms = "" />

		<cfquery name="qGetMatchingPrograms" datasource="#application.datasource#">
			SELECT	Program_ID, Program_Number
			FROM 	Email_Approval_User_Programs
			WHERE	Sent_ID = <cfqueryparam value="#arguments.sentId#" cfsqltype="cf_sql_integer">
			AND		Approval_Received = 0
			AND		Program_Number in (<cfqueryparam value="#arguments.programList#" cfsqltype="cf_sql_varchar" list="true">)
		</cfquery>

		<cfset matchingProgramIds = ValueList(qGetMatchingPrograms.Program_ID) />

		<cfreturn matchingProgramIds />
	</cffunction>


	<!--- Get the list of billbacks in the email we sent and match them against the received --->
	<cffunction name="getMatchingBillbacks" output="false" returntype="query" >
		<cfargument name="sentId" required="true" default="0" type="numeric" />
		<cfargument name="billbackList" required="true" default="" type="string" />

		<cfset var matchingBillbackIds = "" />
		<cfset var qGetMatchingBillbacks = "" />

		<cfquery name="qGetMatchingBillbacks" datasource="#application.datasource#">
			SELECT	Billback_ID, BB_Code, Claimed_Amount, Expected_Amount, Payment_Amount,
				   CASE
					   WHEN Payment_Amount = Expected_Amount
					   THEN 'E'
					   ELSE 'BB'
				   END AS Approved_Payment_Type
			FROM 	Email_Approval_User_Billbacks
			WHERE	Sent_ID = <cfqueryparam value="#arguments.sentId#" cfsqltype="cf_sql_integer">
			AND		Approval_Received = 0
			AND		BB_Code in (<cfqueryparam value="#arguments.billbackList#" cfsqltype="cf_sql_varchar" list="true">)
		</cfquery>

		<cfset matchingBillbackIds = ValueList(qGetMatchingBillbacks.Billback_ID) />

		<cfreturn qGetMatchingBillbacks />
	</cffunction>


	<!---setEmailProcessed : Mark this email and all other email sent to this user with these programs as processed --->
	<cffunction name="setEmailProcessed" output="false" returntype="void" >
		<cfargument name="sentId" required="true" default="0" type="numeric" />
		<cfargument name="userId" required="true" default="0" type="UUID" />
		<cfargument name="programIdList" required="true" default="" type="String" />
		<cfargument name="receivedDateTime" required="true" default="#now()#" type="Date" />
		<cfargument name="receivedMsgId" required="true" default="" type="String" />

		<cfset var qSetEmailProcessed = "" />
		<cfquery name="qSetEmailProcessed" datasource="#application.datasource#">
			UPDATE	Email_Approval_User_Programs
			SET		Received_ID = <cfqueryparam value="#arguments.sentId#" cfsqltype="cf_sql_integer">,
					Approval_Received = <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
					Approval_Received_Date = <cfqueryparam value="#arguments.receivedDateTime#" cfsqltype="cf_sql_timestamp">,
					Received_Server_UID = <cfqueryparam value="#arguments.receivedMsgId#" cfsqltype="cf_sql_varchar">
			WHERE	User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_idstamp">
			AND		Program_ID in (<cfqueryparam value="#arguments.programIdList#" cfsqltype="cf_sql_integer" list="true">)
			AND		Approval_Received = 0
		</cfquery>

	</cffunction>


	<!---setBBEmailProcessed : Mark this email and all other email sent to this user with these bilbacks as processed --->
	<cffunction name="setBBEmailProcessed" output="false" returntype="void" >
		<cfargument name="sentId" required="true" default="0" type="numeric" />
		<cfargument name="userId" required="true" default="0" type="UUID" />
		<cfargument name="billbackIdList" required="true" default="" type="String" />
		<cfargument name="receivedDateTime" required="true" default="#now()#" type="Date" />
		<cfargument name="receivedMsgId" required="true" default="" type="String" />

		<cfset var qSetBBEmailProcessed = "" />
		<cfquery name="qSetBBEmailProcessed" datasource="#application.datasource#">
			UPDATE	Email_Approval_User_Billbacks
			SET		Received_ID = <cfqueryparam value="#arguments.sentId#" cfsqltype="cf_sql_integer">,
					Approval_Received = <cfqueryparam value="1" cfsqltype="cf_sql_bit">,
					Approval_Received_Date = <cfqueryparam value="#arguments.receivedDateTime#" cfsqltype="cf_sql_timestamp">,
					Received_Server_UID = <cfqueryparam value="#arguments.receivedMsgId#" cfsqltype="cf_sql_varchar">
			WHERE	User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_idstamp">
			AND		Billback_ID in (<cfqueryparam value="#arguments.billbackIdList#" cfsqltype="cf_sql_varchar" list="true">)
			AND		Approval_Received = 0
		</cfquery>

	</cffunction>


	<!--- Insert into table Email_Approval_User_Programs --->
	<cffunction name="insertUserPrograms" output="false" returntype="void" >
		<cfargument	name="userId"				type="uuid"		default="0"	required="true"/>
		<cfargument	name="programId"			type="numeric"	default="0"	required="true"/>
		<cfargument	name="programNumber"		type="string"	default="0"	required="true"/>
		<cfargument	name="sentId"				type="numeric"	default="0"	required="true"/>
		<cfargument	name="remoteApprovalOption"	type="numeric"	default="2" required="false"/> <!--- 1= single; 2= batch (default) --->

		<cfset var qInsertUserPrograms = "" />
		<cfquery name="qInsertUserPrograms" datasource="#application.dataSource#">
			INSERT 	Email_Approval_User_Programs
					(
						User_ID,
						Program_ID,
						Program_Number,
						Created_Date,
						Sent_ID,
						Remote_Approval_Option
					)
			VALUES	(
						<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.programNumber#" cfsqltype="cf_sql_varchar">,
						getDate(),
						<cfqueryparam value="#arguments.sentId#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.remoteApprovalOption#" cfsqltype="cf_sql_integer">
					)
		</cfquery>

	</cffunction>


	<!--- Insert into table Email_Approval_User_Billbacks --->
	<cffunction name="insertUserBillbacks" output="false" returntype="void" >

		<cfargument	name="userId"				type="uuid"		default="0"	required="true"/>
		<cfargument	name="billbackId"			type="string"	default="0"	required="true"/>
		<cfargument	name="billbackIdInt"		type="numeric"	default="0"	required="true"/>
		<cfargument	name="bbCode"				type="string"	default="0"	required="true"/>
		<cfargument	name="sentId"				type="numeric"	default="0"	required="true"/>
		<cfargument	name="claimedAmount"		type="numeric"	default="0"	required="true"/>
		<cfargument	name="expectedAmount"		type="numeric"	default="0"	required="true"/>
		<cfargument	name="paymentAmount"		type="numeric"	default="0"	required="true"/>
		<cfargument	name="remoteApprovalOption"	type="numeric"	default="1" required="false"/> <!--- 1= single; 2= batch (default) --->

		<cfset var qInsertUserBillbacks = "" />
		<cfquery name="qInsertUserBillbacks" datasource="#application.dataSource#">
			INSERT 	Email_Approval_User_Billbacks
					(
						User_ID,
						Billback_ID,
						Billback_ID_Int,
						BB_Code,
						Created_Date,
						Sent_ID,
						Claimed_Amount,
						Expected_Amount,
						Payment_Amount,
						Remote_Approval_Option
					)
			VALUES	(
						<cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.billbackId#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.billbackIdInt#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.bbCode#" cfsqltype="cf_sql_varchar">,
						getDate(),
						<cfqueryparam value="#arguments.sentId#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.claimedAmount#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.expectedAmount#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.paymentAmount#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.remoteApprovalOption#" cfsqltype="cf_sql_integer">
					)
		</cfquery>
	</cffunction>

	<!--- Date: 7/7/2010 Usage: Check when last email was sent and whether to resend --->
	<cffunction name="checkResendEmail" output="false" returntype="boolean" hint="Check when last email was sent and whether to resend">
		<cfargument	name="userId"		type="uuid"		default="0"	required="true"/>
		<cfargument	name="programId" 	type="numeric"	default="0"	required="true"/>

		<cfset var bResendEmail = "1" />
		<cfset var qGetLastEmail = "" />

		<cfquery name="qGetLastEmail" datasource="#application.datasource#">
			SELECT	Program_ID, Program_Number, Email_Sent_Date, DateDiff(d, Email_Sent_Date, getDate()) as DaysOld
			FROM 	Email_Approval_User_Programs
			WHERE	User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_idstamp">
			AND		Program_ID in (<cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer" list="true">)
			AND		Remote_Approval_Option = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif qGetLastEmail.recordCount>
			<cfset bResendEmail = "0" />
		</cfif>

		<cfreturn bResendEmail />
	</cffunction>

	<!--- Date: 7/7/2010 Usage: Check when last email was sent and whether to resend --->
	<cffunction name="bbCheckResendEmail" output="false" returntype="boolean" hint="Check when last email was sent and whether to resend">
		<cfargument	name="userId"		type="uuid"   default="0"	required="true"/>
		<cfargument	name="billbackId" 	type="string" default="0"	required="true"/>

		<cfset var bResendEmail = "1" />
		<cfset var qGetLastEmail = "" />

		<cfquery name="qGetLastEmail" datasource="#application.datasource#">
			SELECT	Billback_ID, BB_Code, Email_Sent_Date, DateDiff(d, Email_Sent_Date, getDate()) as DaysOld
			FROM 	Email_Approval_User_Billbacks
			WHERE	User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_idstamp">
			AND		Billback_ID in (<cfqueryparam value="#arguments.billbackId#" cfsqltype="cf_sql_varchar" list="true">)
			AND		Remote_Approval_Option = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfif qGetLastEmail.recordCount>
			<cfset bResendEmail = "0" />
		</cfif>

		<cfreturn 1 />
	</cffunction>

</cfcomponent>