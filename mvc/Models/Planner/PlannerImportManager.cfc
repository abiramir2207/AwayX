<!----------------------------------------------------------------------------------
Name         :  PlannerImportManager.cfc
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  July 2017
Created By   :  KAL
Description  :  Manager for Import Planners
----------------------------------------------------------------------------------->
<cfcomponent name="PlannerImportManager" displayname="PlannerCopyManager" hint="Manager for Copy & Import Planners">



	<cffunction name="init" output="false" hint="Planner Program Copy">

	</cffunction>

	<cffunction name="executePlannerProgramImport" output="false" hint="executes Planner Program Copy">
		<cfargument name="data" required="true" type="struct" />

		<cfscript>
			local.stData = structNew();
			local.stData = arguments.data;

			// save data to db/log table
			local.batchId = savePlannerProgramImport(local.stData);
			// get planner import data
			// local.getData = getPlannerProgramImport(local.batchId);
			// set the planner as system locked
			local.lockPlanner = lockPlannerImport(local.stData.target_planner_id);
			// run program import - the process
			local.processImport = runPlannerImport(local.stData.source_planner_id, local.stData.target_planner_id, local.batchId);
			/*
			// unlock the system locked planner
			local.unlockPlanner = unlockPlannerImport(local.stData.target_planner_id);
			// email user - the process completed
			local.emailSent = emailPlannerProgramImport(local.batchId);  // fix
			*/
		</cfscript>

	</cffunction>

	<cffunction name="savePlannerProgramImport" output="false" returntype="numeric" hint="Save Entries in Planner Program Copy">
		<cfargument name="data" required="true" type="struct" />

		<cfscript>
			local.stData = structNew();
			local.stData = arguments.data;
		</cfscript>

		<!--- insert into planner program copy log table --->
		<cfquery name="local.getBatchID" datasource="#application.datasource#">
			Select (ISNULL(Max(Planner_Program_Copy_Batch_Id),0) + 1) as BatchID from Planner_Program_Copy_Log
		</cfquery>

		<cfloop index="local.progId" list="#local.stData.chosen_programs#">
			<cfquery name="local.qInsertLog" datasource="#application.datasource#">
				INSERT INTO Planner_Program_Copy_Log
						(
							Planner_Program_Copy_Batch_Id,
							To_Planner_Id,
							From_Planner_Id,
							From_Program_Id,
							User_Id,
							Import_Type,
							Deleted,
							Created_Date,
							Processed
						)
				Values 	(
							#local.getBatchID.BatchID#,
							#local.stData.target_planner_id#,
							#local.stData.source_planner_id#,
							#local.progId#,
							'#local.stData.user_id#',
							'#local.stData.planner_import_type#',
							0,
							getdate(),
							0
					)
			</cfquery>
		</cfloop>
		<cfreturn local.getBatchID.BatchID />
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="getPlannerProgramImport" output="false" returntype="query" hint="Get entry from Planner Program Copy">
		<cfargument name="batchId" required="true" type="numeric" />

		<cfquery name="local.qGetPlannerProgramImport" datasource="#application.datasource#">

			SELECT ppcl.Planner_Program_Copy_Batch_Id,
				   ppcl.To_Planner_Id,
				   p_To.Planner_Number   AS To_Planner,
				   ppcl.From_Planner_Id,
				   p_From.Planner_Number AS From_Planner,
				   ppcl.From_Program_Id,
				   cm.Contract_Number,
				   cm.Contract_Title,
				   ppcl.New_Program_Id,
				   ppcl.User_Id,
				   u.User_eMail,
				   ppcl.import_type
			FROM   Planner_Program_Copy_Log ppcl
				   INNER JOIN Planners p_To
						   ON p_To.Planner_Id = ppcl.To_Planner_Id
				   INNER JOIN Planners p_From
						   ON p_From.Planner_Id = ppcl.From_Planner_Id
				   INNER JOIN Contract_Main cm
						   ON cm.Contract_Main_Id = ppcl.From_Program_Id
						  AND cm.Planner_Id       = p_From.Planner_Id
						  AND cm.Deleted          = 0
				   INNER JOIN _Users u
						   ON u.User_Id = ppcl.User_Id
						  AND u.Deleted = 0
			WHERE  PPCL.Deleted   = 0
			   AND  PPCL.Planner_Program_Copy_Batch_Id = #arguments.batchId#
		</cfquery>

		<cfreturn local.qGetPlannerProgramImport />
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="lockPlannerImport" output="false">
		<cfargument name="plannerid" type="numeric" required="true">

		<cfquery name="local.qLockImportPlanner" datasource="#application.datasource#">
			UPDATE Planners
			SET    System_Locked = 1,
				   System_Locked_Date = GetDate()
			WHERE  Planner_Id = #arguments.PlannerId#
		</cfquery>
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="unlockPlannerImport" output="false">
		<cfargument name="plannerid" type="numeric" required="true">

		<cfquery datasource="#application.datasource#">
			UPDATE Planners
			SET    System_Locked = 0,
				   System_Locked_Date = null
			WHERE  Planner_Id = #arguments.PlannerId#
		</cfquery>

	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="runPlannerImport" output="false">
		<cfargument name="source_planner_id" required="true" type="numeric">
		<cfargument name="target_planner_id" required="true" type="numeric">
		<cfargument name="batchId" required="true" type="numeric">

		<!--- make arguments available inside a thread --->
		<cfset request.arguments = structCopy(arguments)>

		<cfthread action="run" name="plannerImport_#arguments.batchId#">
			<cfoutput>
			<cftry>
				<cfstoredproc procedure = "Planner_Copy_Programs" datasource="#application.datasource#">
					<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#request.arguments.source_planner_id#" null="no">
					<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#request.arguments.target_planner_id#" null="no">
					<cfprocparam type="in" cfsqltype="cf_sql_integer" value="#request.arguments.batchId#"           null="no">
				</cfstoredproc>

				<cfscript>
					unlockPlannerImport( request.arguments.target_planner_id );  // unlock the system locked planner
					emailPlannerProgramImport( request.arguments.batchId );		// email user - the process completed
				</cfscript>

				<cfcatch type="any">
					<cflog type="error" text="Exception in runPlannerImport(): #cfcatch.message#" file="exception" application="no">
					<cfscript>
						unlockPlannerImport( request.arguments.target_planner_id );  		// unlock the system locked planner
						emailPlannerProgramImport( request.arguments.batchId, cfcatch );	// email user - the process failed
					</cfscript>
					<cfrethrow>
				</cfcatch>
			</cftry>
			 </cfoutput>
		</cfthread>
	</cffunction>

	<!-------------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="emailPlannerProgramImport" output="false">
		<cfargument name="batchId" required="true" type="numeric">
		<cfargument name="exception" required="false">

		<cfscript>
			local.importData = getPlannerProgramImport(arguments.batchId);
		</cfscript>

		<cfquery name="local.qUserEmail" datasource="#application.datasource#">
			SELECT	TOP 1 User_Email
			FROM   Planner_Program_Copy_Log PPCL
			INNER JOIN _Users U on U.User_ID = PPCL.User_ID
			WHERE  U.Deleted   = 0
			   AND  PPCL.Planner_Program_Copy_Batch_Id = #arguments.batchId#
		</cfquery>


		<cfquery name="local.qGetSystemAdmin" datasource="#application.datasource#">
			SELECT	TOP 1 User_Email
			FROM 	_Users
			WHERE 	Is_System_Administrator = 1
			AND		Deleted = 0
		</cfquery>

		<!--- email user about the unexpected exception --->
		<cfif structKeyExists(arguments, "exception")>
			<cf_emailwrapper
				to 			= "#local.qUserEmail.User_Email#"
				from		= "#local.qGetSystemAdmin.User_Email#"
				subject		= "Planner Import Failed"
				type		= "html"
				messagetype	= "1"
				generatedby	= "1"
				appArea		= "1"
			>
			<cfoutput>
				<p><b>Planner Import Failed.</b></p>
				<p>There were unexpected problems in importing programs from planner #local.importData.From_Planner# to #local.importData.To_Planner#.</p>
				<ul>
					<cfscript>
						for ( row in local.importData ) {
							writeOutput("<li> #row.Contract_Number# : #row.Contract_Title#</li>");
						}
					</cfscript>
				</ul>
				<br>
				<p>Please forward this email to the technical support department.</p>
				<cfdump var="#arguments.exception#">
			</cfoutput>
			</cf_emailwrapper>

		<!--- email user about complete status--->
		<cfelse>
			<cf_emailwrapper
				to 			= "#local.qUserEmail.User_Email#"
				from		= "#local.qGetSystemAdmin.User_Email#"
				subject		= "Planner Import Completed"
				type		= "html"
				messagetype	= "1"
				generatedby	= "1"
				appArea		= "1"
			>
			<cfoutput>
				<p><b>Planner Import Completed.</b></p>
				<p>The following programs were imported successfully from planner #local.importData.From_Planner# to #local.importData.To_Planner#.</p>
				<ul>
					<cfscript>
						for ( row in local.importData ) {
							writeOutput("<li> #row.Contract_Number# : #row.Contract_Title#</li>");
						}
					</cfscript>
				</ul>
				<br/>
			</cfoutput>
			</cf_emailwrapper>
		</cfif>
	</cffunction>

</cfcomponent>