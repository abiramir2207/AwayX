<!---
	FILENAME: 	ProgramAlertManager.cfc
	Copyright 	(c) 2008 Blacksmith Applications, Inc.
	CREATED: 	Tim Ford
--->

<cfcomponent>

	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	
	<cffunction name="addProgramAlertTemplate" access="public" output="false" returntype="void">
	
		<cfargument name="disTemplateID" 	type="numeric" required="yes" />
		<cfargument name="opeTemplateID" 	type="numeric" required="yes" />
		
		<cfset var var_disTemplateID = arguments.disTemplateID />
		<cfset var var_opeTemplateID = arguments.opeTemplateID />
		
		<cfquery datasource="#application.datasource#">
			
			INSERT INTO Program_Alert_Template
				(
					Distributor_Template_ID,
					Operator_Template_ID
				)
			VALUES
				(
					<cfqueryparam value="#var_disTemplateID#" cfsqltype="CF_SQL_INTEGER" />, 
					<cfqueryparam value="#var_opeTemplateID#" cfsqltype="CF_SQL_INTEGER" />
				)
				
		</cfquery>

	</cffunction>
	
	<cffunction name="addProgramAlertStatus" access="public" output="false">
	
		<cfargument name="alertStatusID" 	type="numeric" required="yes" />
		
		<cfset var var_alertStatusID = arguments.alertStatusID />
		
		<cfquery datasource="#application.datasource#">
			INSERT INTO Program_Alert_Status
				(
					Contract_Status_Type_ID
				)
			VALUES
				(
					<cfqueryparam value="#var_alertStatusID#" cfsqltype="CF_SQL_INTEGER" />
				)
		</cfquery>
		
	</cffunction>
	
	<cffunction name="addProgramAlertReminder" access="public" output="false">
	
		<cfargument name="reminder"	type="string" required="yes" />
		
		<cfset var var_reminder = arguments.reminder />
		
		<cfquery datasource="#application.datasource#">
		
			UPDATE	Program_Alert_Reminder
			SET		Deleted = 1,
					Updated_Date = getDate()
			WHERE	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
			
		</cfquery>
		
		<cfquery datasource="#application.datasource#">
			INSERT INTO Program_Alert_Reminder
				(Reminder)
			VALUES
				(
					<cfqueryparam value="#var_reminder#" 	cfsqltype="CF_SQL_VARCHAR" />
				)
		</cfquery>
	
	</cffunction>
	
	<cffunction name="addProgramAlertMessage" access="public" output="false">
	
		<cfargument name="message" 				type="string" default="" />
		<cfargument name="contractNumber" 		type="string" default="" />
		<cfargument name="userId" 				type="string" default="" />
		<cfargument name="contractMainID" 		type="string" default="" />
		
		
		<cfset var var_message 			= trim(arguments.message) />
		<cfset var var_contractNumber	= trim(arguments.contractNumber) />
		<cfset var var_userId			= trim(arguments.userId) />
		<cfset var var_contractMainID	= trim(arguments.contractMainID) />
		
		<!--- delete any possible program alerts that could have alrady been added due to revisions--->
		<cfquery datasource="#application.datasource#">
		
			UPDATE	Program_Alert_Message
			SET		Deleted = 1,
					Updated_Date = getDate()
			WHERE	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
			AND		Contract_Number = <cfqueryparam value="#var_contractNumber#" cfsqltype="CF_SQL_VARCHAR" />
			
		</cfquery>
			
		<cfif var_message neq "">
		
			<cfquery datasource="#application.datasource#">
				INSERT INTO Program_Alert_Message
					(Message, Contract_Number, User_ID, Contract_Main_ID)
				VALUES
					(
						<cfqueryparam value="#var_message#" 		cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#var_contractNumber#" 	cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#var_userId#" 			cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#var_contractMainID#" 	cfsqltype="CF_SQL_VARCHAR" />
					)
			</cfquery>
			
		</cfif>
	
	</cffunction>
	
	<cffunction name="deleteProgramAlertTemplate" access="public" output="false" returntype="void">
	
		<cfquery datasource="#application.datasource#">
		
			UPDATE	Program_Alert_Template
			SET		Deleted = 1,
					Updated_Date = getDate()
			WHERE	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
				
		</cfquery>

	</cffunction>
	
	<cffunction name="deleteProgramAlertStatus" access="public" output="false" returntype="void">
	
		<cfquery datasource="#application.datasource#">
		
			UPDATE	Program_Alert_Status
			SET		Deleted = 1,
					Updated_Date = getDate()
			WHERE	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
				
		</cfquery>

	</cffunction>
	
	<cffunction name="getProgramAlertTemplate" access="public" output="false">
	
		<cfargument name="getDisTemplateID" default="" required="no" />
		<cfargument name="getOpeTemplateID" default="" required="no" />
		
		<cfset var var_getDisTemplateID = arguments.getDisTemplateID />
		<cfset var var_getOpeTemplateID = arguments.getOpeTemplateID />
		
		<cfquery name="qGetProgramAlertTemplate" datasource="#application.datasource#">
			
			SELECT	Distributor_Template_ID,
					Operator_Template_ID
			FROM	Program_Alert_Template
			WHERE	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />
			<cfif len(trim(var_getDisTemplateID))>
			AND		Distributor_Template_ID = (SELECT First_Parent_ID FROM Program_Control_Panel_Options WHERE ProgramControl_Panel_Options_ID = <cfqueryparam value="#var_getDisTemplateID#" cfsqltype="CF_SQL_INTEGER" />)
			</cfif>
			<cfif len(trim(var_getOpeTemplateID))>
			AND		Operator_Template_ID = (SELECT First_Parent_ID FROM Program_Control_Panel_Options WHERE ProgramControl_Panel_Options_ID = <cfqueryparam value="#var_getOpeTemplateID#" cfsqltype="CF_SQL_INTEGER" />)
			</cfif>
				
		</cfquery>

		<cfreturn qGetProgramAlertTemplate />
		
	</cffunction>

	<cffunction name="getProgramAlertStatus" access="public" output="false">
		
		<cfquery name="qGetProgramAlertStatus" datasource="#application.datasource#">
			
			SELECT	Contract_Status_Type_ID
			FROM	Program_Alert_Status
			WHERE	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />

		</cfquery>

		<cfreturn qGetProgramAlertStatus />
		
	</cffunction>
	
	<cffunction name="getProgramAlertMessage" access="public" output="false">
	
		<cfargument name="getContractMainID" 	default="" required="no" />
		<cfargument name="getSentAlerts" 		default="" required="no" />
		
		<cfset var var_getContractMainID 	= arguments.getContractMainID />
		<cfset var var_getSentAlerts 		= arguments.getSentAlerts />
		
		<cfquery name="qGetProgramAlertMessageSent" datasource="#application.datasource#">
			
			SELECT	Program_Alert_Message.Message,
					Program_Alert_Message.Contract_Number,
					Program_Alert_Message.Contract_Main_ID,
					Program_Alert_Message.Pickedup_Date,
					_Users.Name_First + ' ' + _Users.Name_Last AS User_Name
			FROM	Program_Alert_Message
					INNER JOIN _Users ON
					_Users.User_ID = Program_Alert_Message.User_ID AND
					_Users.Deleted = 0
			WHERE	Program_Alert_Message.Deleted = 0
			<cfif len(trim(var_getSentAlerts))>
			AND		Program_Alert_Message.Pickedup_By_Job = 1
			</cfif>
			<cfif len(trim(var_getContractMainID))>
			AND		Program_Alert_Message.Contract_Main_ID = <cfqueryparam value="#var_getContractMainID#" cfsqltype="CF_SQL_INTEGER" />
			</cfif>

		</cfquery>

		<cfreturn qGetProgramAlertMessageSent />
		
	</cffunction>

	<cffunction name="getProgramAlertReminder" access="public" output="false">
	
		<cfquery name="qGetProgramAlertReminder" datasource="#application.datasource#">
			
			SELECT	Reminder
			FROM	Program_Alert_Reminder
			WHERE	Deleted = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT" />

		</cfquery>

		<cfreturn qGetProgramAlertReminder />
		
	</cffunction>
	
	<cffunction name="getProgramAlertOperatorPrograms" access="public" output="false">
	
		<cfargument name="alertingContractMainID" 	default="" required="no" />
		
		<cfset var var_alertingContractMainID 	= arguments.alertingContractMainID />
		
		<cfquery name="qGetProgramAlertOperatorPrograms" datasource="#application.datasource#">
			
			SELECT	*
			FROM	Program_Alert_Operator_Programs
			WHERE	Alerting_Contract_Main_ID = <cfqueryparam value="#var_alertingContractMainID#" cfsqltype="CF_SQL_INTEGER" />
			ORDER BY Operator_Template_Type ASC, Operator_Contract_Number DESC

		</cfquery>

		<cfreturn qGetProgramAlertOperatorPrograms />
		
	</cffunction>
	
</cfcomponent>