<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\programs\RecaptureOperatorList.cfc
	Date:      10/16/2014
	Author:    Deepa Kunnath
--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cfcomponent displayname="Recapture Operator List" output="no" hint="Houses all Recapture Operator List functions.">
     
<!----------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="getRecaptureOperatorList" access="public" returntype="query" output="no">
	
	<cfset var qRecaptureOperatorList = "" />

	<cfquery name="qRecaptureOperatorList" datasource="#application.datasource#">
		SELECT	o.BSA_Operator_ID, o.Legacy_ID, o.Operator_Name, o.Operator_City, o.Operator_State,
				u.Name_First + ' ' + u.Name_Last as Created_By,
				r.Created_Date
		FROM	Recapture_Operator_List r
		INNER JOIN BSA_Operator o
		ON		o.BSA_Operator_ID = r.BSA_Operator_ID
		LEFT JOIN _Users u
		ON		u.User_ID = r.Created_By
		WHERE	r.Deleted = 0
		ORDER BY o.Operator_Name
	</cfquery>

 	<cfreturn qRecaptureOperatorList / >
</cffunction>

<cffunction name="addOperators" access="public" returntype="void" output="no">
	<cfargument name="OperatorList" type="string" required="true" />
	<cfargument name="UserID" type="string" required="true" />
	
	<cfset var qAddOperator = "" />

	<cfquery name="qAddOperator" datasource="#application.datasource#">
		INSERT INTO Recapture_Operator_List (BSA_Operator_ID, Created_By)
		SELECT	o.BSA_Operator_ID, '#arguments.UserID#' as User_ID
		FROM	BSA_Operator o
		WHERE	o.BSA_Operator_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" list="true" value="#arguments.OperatorList#">)
		AND		NOT EXISTS (
			SELECT	1
			FROM	Recapture_Operator_List r
			WHERE	r.BSA_Operator_ID = o.BSA_Operator_ID
			AND		r.Deleted = 0
		)
	</cfquery>

</cffunction>

<cffunction name="deleteOperators" access="public" returntype="void" output="no">
	<cfargument name="OperatorList" type="string" required="true" />
	<cfargument name="UserID" type="string" required="true" />
	
	<cfset var qDeleteOperator = "" />

	<cfquery name="qDeleteOperator" datasource="#application.datasource#">
		UPDATE	Recapture_Operator_List
		SET		Deleted = 1,
				Deleted_Date = GetDate(),
				Deleted_By = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.UserID#">
		WHERE	Deleted = 0
		AND		BSA_Operator_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" list="true" value="#arguments.OperatorList#">)
	</cfquery>

</cffunction>
	
</cfcomponent>
	
