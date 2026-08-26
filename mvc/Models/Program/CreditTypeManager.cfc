<cfcomponent displayname="Credit Type Manager" output="false">

<cffunction name="getCreditTypes" hint="return all the credit type records that macthes the criteria" access="public" output="false" returntype="query">
	
	<cfargument name="creditTypeID" type="numeric" required="false" default="0" />
	<cfargument name="IncludeDeleted" type="boolean" required="false" default="0" />
	 
	<cfset var qGetCreditTypes = "" />
	
	<cfquery name="qGetCreditTypes" datasource="#application.datasource#">
		SELECT	Credit_Type.Credit_Type_ID, Credit_Type.Credit_Type, Credit_Type.Credit_Type_Description, 
				Credit_Type.Deleted,
				Credit_Type.Updated_By, Credit_Type.Updated_Date 
		FROM	Credit_Type
		WHERE	1 = 1
		<cfif arguments.IncludeDeleted eq 0>
		AND		Credit_Type.Deleted = 0
		</cfif>
		<cfif arguments.creditTypeID neq 0>
		AND		Credit_Type.Credit_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.creditTypeID#" />
		</cfif>
		ORDER BY Credit_Type.Credit_Type
	</cfquery>
	
	<cfreturn qGetCreditTypes />
	
	
</cffunction>

<cffunction name="addEditCreditType" hint="insert/update credit type record" access="public" output="false" returntype="void">
	<cfargument name="creditTypeID" type="numeric" required="true" />
	<cfargument name="creditType" type="string" required="true" />
	<cfargument name="creditTypeDesc" type="string" required="true" />
	<cfargument name="deleted" type="boolean" required="true" />
	<cfargument name="userID" type="string" required="true" />
	
	<cfset var qInsertData = "" />
	<cfset var qUpdateData = "" />
	
	<cfif arguments.creditTypeID EQ 0>
	
		<!--- Insert the record --->
		<CFQUERY NAME="qInsertData" datasource="#application.datasource#">
			INSERT INTO Credit_Type
				(
				Credit_Type, 
				Credit_Type_Description
				)
			VALUES
				(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.creditType#" />,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.creditTypeDesc#" />
				)
		</CFQUERY>
		
	<CFELSE>
		
		<!--- Update the record --->
		<CFQUERY NAME="qUpdateData" datasource="#application.datasource#">
			UPDATE 		Credit_Type
			SET 		Credit_Type 			= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.creditType#" />,
						Credit_Type_Description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.creditTypeDesc#" />,
						Updated_Date			= GetDate(),
						Updated_By				= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#" />,
						Deleted					= <cfqueryparam cfsqltype="cf_sql_bit" value="#arguments.deleted#" />
			WHERE		Credit_Type_ID		= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.creditTypeID#" />
		</CFQUERY>
	
	</CFIF>
	
</cffunction>

</cfcomponent>