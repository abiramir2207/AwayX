<cfcomponent hint="Operator Priority">

	<cffunction name="getPriority" output="false" returntype="query">

		<cfargument name="id" type="numeric" required="false" default="0" />

		<cfquery name="qGetPriority" datasource="#application.datasource#">
			SELECT distinct op.Operator_Priority_ID,
										op.Priority_Label,
										op.isDefault,
										case when b.BSA_Operator_ID IS NULL then 0 else 1 end AS operatorExists
			FROM Operator_Priority op
			LEFT JOIN BSA_Operator b
			ON op.Operator_Priority_ID = b.Operator_Priority_ID
			AND b.Deleted = 0
			WHERE op.Deleted = 0
			<cfif arguments.id>
			AND		op.Operator_Priority_ID = #arguments.id#
			</cfif>
			GROUP BY op.Operator_Priority_ID,
													op.Priority_Label,
													op.isDefault,
													b.BSA_Operator_ID
		</cfquery>

		<cfreturn qGetPriority />

	</cffunction>

	<cffunction name="save" output="false">

		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="name" type="string" required="true" default="" />

			<!--- if we have an id then we have to update--->
			<cfif arguments.id>

				<!---first check to see if this priority name already exists--->
				<cfquery name="qCheckExists" datasource="#application.datasource#">
					SELECT	Operator_Priority_ID
					FROM	Operator_Priority
					WHERE	Priority_Label = '#trim(arguments.name)#'
					AND		Deleted = 0
				</cfquery>

				<!---if a record doesn't exist then we can update--->
				<cfif not qCheckExists.RecordCount>

					<cfquery name="qGetPriority" datasource="#application.datasource#">
						UPDATE	Operator_Priority
						SET		Priority_Label = '#trim(arguments.name)#'
						WHERE	Operator_Priority_ID = #arguments.id#
						AND		Deleted = 0
					</cfquery>

				</cfif>

			<cfelse>

				<!---first check to see if this priority name already exists--->
				<cfquery name="qCheckExists" datasource="#application.datasource#">
					SELECT	Operator_Priority_ID
					FROM	Operator_Priority
					WHERE	Priority_Label = '#trim(arguments.name)#'
					AND		Deleted = 0
				</cfquery>

				<!---if a record doesn't exist then we can update--->
				<cfif not qCheckExists.RecordCount>

					<cfquery name="qGetPriority" datasource="#application.datasource#">
						INSERT INTO	Operator_Priority
							(Priority_Label)
						VALUES
							('#trim(arguments.name)#')
					</cfquery>

				</cfif>

			</cfif>

	</cffunction>

	<cffunction name="deletePriority" output="false">

		<cfargument name="id" type="numeric" required="false" default="0" />

			<cfquery name="qGetPriority" datasource="#application.datasource#">
				UPDATE	Operator_Priority
				SET		Deleted = 1
				WHERE	Operator_Priority_ID = #arguments.id#
			</cfquery>

	</cffunction>

	<cffunction name="assignPriority" output="false">

		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="operatorIdList" type="string" required="true" default="" />

		<cfquery name="qAssignPriority" datasource="#application.datasource#">
			UPDATE	BSA_Operator
			SET		Operator_Priority_ID = #arguments.id#
			WHERE
					BSA_Operator.Deleted = 0
					AND
					BSA_Operator.BSA_Operator_ID IN (#arguments.operatorIdList#)
		</cfquery>

	</cffunction>

</cfcomponent>