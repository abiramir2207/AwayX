<!---
Name: 			ProgramLockType.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:	02/13/2008
Created By:		Tim Ford
Description:	This file is responsible for interfacing to Program Lock Types.  
--->

<cfcomponent hint="Component that interfaces to Program Lock Types" extends="components.Base">

	<cffunction name="init" output="false">

		<cfreturn this />

	</cffunction>
	
	<cffunction name="getProgramLockType" output="false" returntype="query">

		<cfset var var_returnQuery = "" />
		
		<cfset useLakebaseForqGetProgramLockType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lock_type")>
<cfif useLakebaseForqGetProgramLockType>
	<cftry>
		<cfset qGetProgramLockType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lock_type", {
				"select" = "program_lock_type_id,description,lock_type_message"
			}), "program_lock_type_id,description,lock_type_message"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramLockType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramLockType>
<cfquery name="qGetProgramLockType" datasource="#application.datasource#">
			SELECT	Program_Lock_Type_ID,
					Description,
					Lock_Type_Message
			FROM	Program_Lock_Type
		</cfquery>
</cfif>
		
		<cfset var_returnQuery = qGetProgramLockType />
		
		<cfreturn var_returnQuery />

	</cffunction>
	
	<cffunction name="getProgramLockStatus" output="false">
	
		<cfargument name="programId" required="yes" />

		<cfset var objBidRequest = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
		<cfset var objTemplate = CreateObject("component", "components.programs.template.TemplateManager") />

		<cfset var var_returnLockProgram 	= "" />
		<cfset var var_lockType 			= "" />
		
		<cfset var_returnLockProgram 	= 0 />
		<cfset var_lockType				= 0 />
		<cfset var_bIsLocklock			= 0 />
		
		<cfquery name="qGetProgramLockStatus" datasource="#application.datasource#">
			SELECT	Approved,
					Sending_To_External_Client,
					Sent_To_External_Client,
					Contract_Main_Aux_Data.Program_Lock_Type_ID
			FROM	Contract_Main
					INNER JOIN Contract_Main_Aux_Data ON
					Contract_Main_Aux_Data.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE	Contract_Main.Contract_Main_ID = #arguments.programId#
			AND		Deleted = 0
		</cfquery>

		<cfset TemplateDetails = objTemplate.getProgramTemplate('#arguments.programId#')>
		<cfset BidRequestDetails = objBidRequest.getStatus('#arguments.programId#')>		
		
		<!---figure out if the program should be locked based on the criteria --->
		<!---first make sure the program is approved--->
		<cfif qGetProgramLockStatus.RecordCount and qGetProgramLockStatus.Approved eq 1>
		
			<cfset var_lockType	= qGetProgramLockStatus.Program_Lock_Type_ID />
			<!---
			If on the template setting, "Interface on Program Approval" is turned ON 
			(Here we do not look at the bid status as the program should be locked on approval)
			OR
			The bid status is either WON (BidRequestDetails.Bid_Request_Status_ID = 2) OR  SPLIT (BidRequestDetails.Bid_Request_Status_ID = 3)
			
			IF template is set to Interface on Won (Interface_On_Approval = 0), we should not lock pending programs as user will need to lock and set it the bid status
			IF template is set to Interface on Won (Interface_On_Approval = 0), we should not lock lost programs as lost program will never get interfaced in this situation
			--->
			<cfif TemplateDetails.Interface_On_Approval EQ 1 OR BidRequestDetails.Bid_Request_Status_ID eq 2 OR BidRequestDetails.Bid_Request_Status_ID eq 3>
					<cfset var_bIsLocklock = 1 />
			</cfif>
			
			<!---now handle for each lock type--->
			<cfswitch expression="#var_lockType#">
				<!---if the lock type is 1 and Sending_To_External_Client = 0 and Sent_To_External_Client = 0
				then set var_returnLockProgram = 1 --->
				<cfcase value="1">	
				<!---  If "Proposal Status ON" template setting is turned ON--->
				<cfif TemplateDetails.BidRequestStatusOn eq 1>
					<cfif var_bIsLocklock eq 1>
							<cfif qGetProgramLockStatus.Sending_To_External_Client eq 0 and qGetProgramLockStatus.Sent_To_External_Client eq 0>
								<cfset var_returnLockProgram = 1 />
							</cfif>
					</cfif>
				<cfelse>
							<cfif qGetProgramLockStatus.Sending_To_External_Client eq 0 and qGetProgramLockStatus.Sent_To_External_Client eq 0>
								<cfset var_returnLockProgram = 1 />
							</cfif>
				</cfif>
				</cfcase>
				<!---if the lock type is 2 and Sent_To_External_Client = 0
				then set var_returnLockProgram = 1 --->
				<cfcase value="2">
				<!---  If "Proposal Status ON" template setting is turned ON--->
				<cfif TemplateDetails.BidRequestStatusOn eq 1>
					<cfif var_bIsLocklock eq 1>
							<cfif qGetProgramLockStatus.Sent_To_External_Client eq 0>
								<cfset var_returnLockProgram = 1 />
							</cfif>
					</cfif>
				<cfelse>
							<cfif qGetProgramLockStatus.Sent_To_External_Client eq 0>
								<cfset var_returnLockProgram = 1 />
							</cfif>
				</cfif>
				</cfcase>
				<!---if the lock type is 3 and Sending_To_External_Client = 1 and Sent_To_External_Client = 0
				then set var_returnLockProgram = 1 --->
				<cfcase value="3">
					<cfif qGetProgramLockStatus.Sending_To_External_Client eq 1 and qGetProgramLockStatus.Sent_To_External_Client eq 0>
						<cfset var_returnLockProgram = 1 />
					</cfif>
				</cfcase>

			</cfswitch>
			
		</cfif>
		
		<cfreturn var_returnLockProgram />

	</cffunction>
	
</cfcomponent>