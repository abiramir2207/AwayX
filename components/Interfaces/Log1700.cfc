<CFCOMPONENT HINT="Log 1700 Data Insert" DISPLAYNAME="Log1700DataInsert">
	<cfset this.billbackId = "">
	<cfset this.ResolutionIdentifier = "">
	<cfset this.Deduction_ID = ""> 
	<cfset this.DateTimeHolder = "">

	<cffunction name="init" output="false" returntype="components.Interfaces.log1700">
		<cfargument name="billbackId" required="true" default="" />
		<cfargument name="ResolutionIdentifier" required="true" default="" />
		<cfargument name="Deduction_ID" required="true" default="" />
		<cfargument name="DateTimeHolder" required="true" default="" />
		<cfset setBillbackId(arguments.billbackId) />
		<cfset setResolutionIdentifier(arguments.ResolutionIdentifier) />		
		<cfset setDeduction_ID(arguments.Deduction_ID) />
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
	
	<!--- ResolutionIdentifier setter --->
	<cffunction name="setResolutionIdentifier" access="public" output="false">
		<cfargument name="ResolutionIdentifier" required="true" default="" />
		<cfset this.ResolutionIdentifier = arguments.ResolutionIdentifier />
	</cffunction>
	
	<!--- ResolutionIdentifier getter --->
	<cffunction name="getResolutionIdentifier" access="public" output="false">
		<cfreturn this.ResolutionIdentifier/>
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
		<CFQUERY NAME="DeleteRecordsFrom1700" DATASOURCE="#Application.Datasource#">
			UPDATE Log_1700 SET Deleted = 1 WHERE Deduction_ID = '#getDeduction_ID()#' AND Deleted = 0
		</CFQUERY>	
	</cffunction>		
	
	<cffunction name="AddtoLog" output="false" returntype="void">
		<!--- 
		<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
			UPDATE Log_1700 SET Deleted = 1 WHERE Deduction_ID = '#getDeduction_ID()#' AND Current_Insert = 1 AND Deleted = 0
		</CFQUERY>	 --->
		
		<cfstoredproc procedure="Log_1700_Insert" datasource="#application.datasource#">
				
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Deduction_ID" value = "#getDeduction_ID()#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@ResolutionIdentifier" value="#getResolutionIdentifier()#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_TIMESTAMP" dbVarName = "@DateTimeHolder" value="#CREATEODBCDATETIME(getDateTimeHolder())#" null="no" />
			
		</cfstoredproc>
		
	</cffunction>
	
	
	
</CFCOMPONENT>
