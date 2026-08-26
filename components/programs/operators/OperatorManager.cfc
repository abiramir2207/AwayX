<!---OperatorManager.cfc--->
<cfcomponent displayname="Operator Manager Component" hint="Manager for operator component">


	<!--- CONSTRUCTOR --->
	<cffunction name="init" access="public" returntype="void" output="false">
	</cffunction>

	<cffunction name="getProgramOperators" output="false" returntype="components.programs.operators.ProgramOperators">

		<cfargument name="programId" required="false" default="0" />

		<!---initialize ProgramOperator object to return--->
		<cfset rProgramOperator = CreateObject("component", "components.programs.operators.ProgramOperators") />

		<cfquery name="qGetProgramOperators" datasource="#application.datasource#">

			SELECT 	Contract_Operators.BSA_Operator_ID,
					Contract_Operators.Contract_Main_ID,
					BSA_Operator.Operator_Name
			FROM 	Contract_Operators INNER JOIN BSA_Operator
					ON BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
					AND BSA_Operator.Deleted = 0
			WHERE 	Contract_Operators.Deleted = 0
			AND		Contract_Operators.Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />

		</cfquery>

		<cfloop query="qGetProgramOperators">

			<!---create an instance of Operator--->
			<cfset operatorObj = CreateObject("component", "components.programs.operators.Operator") />
			<cfset operatorObj.setOperatorId(BSA_Operator_ID) />
			<cfset operatorObj.setProgramId(Contract_Main_ID) />
			<cfset operatorObj.setName(Operator_Name) />
			<cfset rProgramOperator.setProgramOperator(operatorObj) />

		</cfloop>

		<cfreturn rProgramOperator />

	</cffunction>

	<cffunction name="getProgramOperatorIds" output="false" returntype="components.programs.operators.ProgramOperators">

		<cfargument name="programId" required="false" default="0" />

		<!---initialize ProgramOperator object to return--->
		<cfset rProgramOperator = CreateObject("component", "components.programs.operators.ProgramOperators") />

		<cfquery name="qGetProgramOperatorList" datasource="#application.datasource#">

			SELECT 	BSA_Operator_ID
			FROM 	Contract_Operators
			WHERE 	Deleted = 0
			AND		Contract_Main_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />

			ORDER BY BSA_Operator_ID

		</cfquery>

		<cfset rProgramOperator.setLOperatorIds(ValueList(qGetProgramOperatorList.BSA_Operator_ID)) />

		<cfreturn rProgramOperator />

	</cffunction>

	<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

	<cffunction name="getOperatorGroupInfo" output="false">
		<cfargument name="programId" required="true" type="numeric" />

		<cfset var vars = structNew()>

		<cfquery name="vars.qGetProgramInfo" datasource="#application.datasource#">
			SELECT	Program_Control_Panel_Options.Specify_Operator_Groups
			  FROM	Contract_Main
					    INNER JOIN Program_Control_Panel_Options
					      ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			 WHERE	Contract_Main.Contract_Main_ID = <cfqueryparam cfsqltype="CF_SQL_NUMERIC" value="#arguments.programId#">
		</cfquery>

		<cfreturn vars.qGetProgramInfo>
	</cffunction>

</cfcomponent>