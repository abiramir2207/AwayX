<CFCOMPONENT HINT="Log 900 Data Insert" DISPLAYNAME="Log900DataInsert">
	<cfset this.billbackId = "">
	<cfset this.ModuleIdentifier = "">
	<cfset this.Deduction_ID = "">
	<cfset this.Log_900_ID = 0> 
	<cfset this.DateTimeHolder = "">
	
	<cffunction name="init" output="false" returntype="components.Interfaces.log900">
		<cfargument name="billbackId" required="true" default="" />
		<cfargument name="ModuleIdentifier" required="true" default="" />
		<cfargument name="DateTimeHolder" required="true" default="" />
		<cfargument name="Deduction_ID" required="false" default="" />
		<cfset setBillbackId(arguments.billbackId) />
		<cfset setModuleIdentifier(arguments.ModuleIdentifier) />
		<CFIF arguments.Deduction_ID NEQ "">
			<cfset setDeduction_ID(arguments.Deduction_ID) />
		</CFIF>
		<cfset setDateTimeHolder(arguments.DateTimeHolder) />
		<cfreturn this />		
	</cffunction>
	
	<!--- billbackId setter --->
	<cffunction name="setBillbackId" access="public" output="false">
		<cfargument name="billbackId" required="true" default="" />
		<cfset this.billbackId = arguments.billbackId />
	</cffunction>
	
	<!--- billbackId getter --->
	<cffunction name="getBillbackId" access="public" output="false">
		<cfreturn this.billbackId/>
	</cffunction>	
	
	<!--- ModuleIdentifier setter --->
	<cffunction name="setModuleIdentifier" access="public" output="false">
		<cfargument name="ModuleIdentifier" required="true" default="" />
		<cfset this.ModuleIdentifier = arguments.ModuleIdentifier />
	</cffunction>
	
	<!--- ModuleIdentifier getter --->
	<cffunction name="getModuleIdentifier" access="public" output="false">
		<cfreturn this.ModuleIdentifier/>
	</cffunction>
	
	<!--- Deduction_ID setter --->
	<cffunction name="setDeduction_ID" access="public" output="false">
		<cfargument name="Deduction_ID" required="true" default="" />
		<cfset this.Deduction_ID = arguments.Deduction_ID />
	</cffunction>
	
	<!--- Deduction_ID getter --->
	<cffunction name="getDeduction_ID" access="public" output="false">
		<cfreturn this.Deduction_ID/>
	</cffunction>
	
	<!--- Log_900_ID setter --->
	<cffunction name="setLog_900_ID" access="public" output="false">
		<cfargument name="Log_900_ID" required="true" type="numeric" />
		<cfset this.Log_900_ID = arguments.Log_900_ID />
	</cffunction>
	
	<!--- Log_900_ID getter --->
	<cffunction name="getLog_900_ID" access="public" output="false">
		<cfreturn this.Log_900_ID />
	</cffunction>

	<!--- DateTimeHolder setter --->
	<cffunction name="setDateTimeHolder" access="public" output="false">
		<cfargument name="DateTimeHolder" required="true" default="" />
		<cfset this.DateTimeHolder = arguments.DateTimeHolder />
	</cffunction>
	
	<!--- DateTimeHolder getter --->
	<cffunction name="getDateTimeHolder" access="public" output="false">
		<cfreturn this.DateTimeHolder/>
	</cffunction>	
	
	<cffunction name="DeleteFromLog" output="false" returntype="void">			
		<CFQUERY NAME="DeleteRecordsFrom900" DATASOURCE="#Application.Datasource#">
			UPDATE Log_900 SET Deleted = 1 WHERE Billback_ID = '#getBillbackId()#' AND Deleted = 0
		</CFQUERY>	
	</cffunction>		
	
	<cffunction name="AddtoLog" output="false" returntype="numeric">
		<cfset var passNull	= "yes" />	
		<cfif trim(#getDeduction_ID()#) NEQ "">
			<cfset passNull = "No"/>
		</cfif>
		<cfstoredproc procedure="Log_900_Insert" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" value = "#getBillbackId()#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@ModuleIdentifier" value="#getModuleIdentifier()#" null="no" />
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Deduction_ID" value = "#getDeduction_ID()#" null="#passNull#" />
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Trigger_Action_Indicator" value="" null="yes" />
			<cfprocparam type="In" CFSQLType="CF_SQL_TIMESTAMP" dbVarName = "@DateTimeHolder" value="#CREATEODBCDATETIME(getDateTimeHolder())#" null="no" />
			<cfprocparam type="Out" CFSQLType="CF_SQL_INTEGER" dbVarName = "@Log_900_ID" variable="Log_900_ID"  null="no" />
		</cfstoredproc>

		<cfset setLog_900_ID(Log_900_ID) /> 		
		<cfreturn Log_900_ID />

	</cffunction> 
	
</CFCOMPONENT>
