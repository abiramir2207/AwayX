<CFCOMPONENT HINT="Log 700 Data Insert" DISPLAYNAME="Log700DataInsert">
	<cfset this.billbackId = "">
	<cfset this.DateTimeHolder = "">

	<cffunction name="init" output="false" returntype="components.Interfaces.log700">
		<cfargument name="billbackId" required="true" default="" />
		<cfargument name="DateTimeHolder" required="true" default="" />
		<cfset setBillbackId(arguments.billbackId) />
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
	
	<!--- DateTimeHolder setter --->
	<cffunction name="setDateTimeHolder" access="public" output="false">
		<cfargument name="DateTimeHolder" required="true" default="" />
		<cfset this.DateTimeHolder = arguments.DateTimeHolder />
	</cffunction>
	
	<!--- DateTimeHolder getter --->
	<cffunction name="getDateTimeHolder" access="public" output="false">
		<cfreturn this.DateTimeHolder/>
	</cffunction>	
	
	<cffunction name="AddtoLog" output="false" returntype="void">
	<!--- 
		<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
			UPDATE Log_700 SET Deleted = 1 WHERE Billback_ID = '#getBillbackId()#' AND Current_Insert = 1 AND Deleted = 0
		</CFQUERY>	
	 --->	
		
		<cfstoredproc procedure="Log_700_Insert" datasource="#application.datasource#">
				
			<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR" dbVarName = "@Billback_ID" value = "#getBillbackId()#" null="no">
			<cfprocparam type="In" CFSQLType="CF_SQL_TIMESTAMP" dbVarName = "@DateTimeHolder" value="#CREATEODBCDATETIME(getDateTimeHolder())#" null="no" />
			
		</cfstoredproc>
		
	</cffunction>
	
	<cffunction name="updateNulls" output="false" returntype="void" access="public">
		<CFQUERY NAME="GetAllInfo" DATASOURCE="#Application.Datasource#">
			SELECT Top 1 * FROM Log_700 WHERE Billback_ID = '#getBillbackId()#' AND Current_Insert = 1 AND Deleted = 0
		</CFQUERY>
		
		<CFIF GetAllInfo.Operator_ID EQ "">
			<CFSET getProgramOperator()>
		</CFIF>
		<CFSET updateSrdShipToLegacyID()>
	</cffunction>
	
	<cffunction name="getProgramOperator" output="false" returntype="void" access="public">
	
		<CFQUERY NAME="UpdateOperator" DATASOURCE="#Application.Datasource#">
			UPDATE 	Log_700
			SET 	Operator_ID = (	SELECT 		TOP 1 Contract_Operators.BSA_Operator_ID
									FROM 		Billback_Program 
				
									INNER JOIN 	Contract_Operators ON Contract_Operators.Contract_Main_ID = Billback_Program.Program_ID AND
												Contract_Operators.Deleted = 0
									
									WHERE		Billback_Program.Billback_ID = Log_700.Billback_ID AND
												Billback_Program.Deleted = 0 )
			WHERE 	Log_700.Billback_ID = '#getBillbackId()#' AND 
					Current_Insert = 1 AND 
					Deleted = 0
		</CFQUERY>
	</cffunction>


	
	<cffunction name="updateSrdShipToLegacyID" output="false" returntype="void">		
		<CFQUERY NAME="UpdateDistOperInfo" DATASOURCE="#Application.Datasource#">
			UPDATE 	Log_700
			
			SET 	Shr_Ship_To = (	SELECT Shr_Ship_To FROM BSA_Foodservice_Customers WHERE BSA_Foodservice_Customers_ID = Distributor_ID ),
					Operator_Legacy_ID = ( SELECT ISNULL(BSA_Operator.Legacy_ID, BSA_Operator.BSA_Operator_ID) FROM BSA_Operator WHERE BSA_Operator_ID = Operator_ID),
					<!--- Ana 15454 - Commentting to avoid DeadLock --->
					Current_Insert = 0
					
			WHERE	Billback_ID = '#getBillbackId()#' AND 
					Current_Insert = 1 AND
					Deleted = 0
		</CFQUERY>
	</cffunction> 
	
</CFCOMPONENT>
