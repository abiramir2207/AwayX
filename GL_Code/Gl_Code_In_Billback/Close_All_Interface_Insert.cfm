<cftransaction action="begin">

<cftry>
		
<CFIF IsDefined("Close_700")>
	<CFQUERY NAME="Close700" DATASOURCE="#Application.Datasource#">
		UPDATE Log_700 SET Current_Insert = 0 WHERE Billback_ID = '#Billback_ID#' AND Current_Insert = 1 AND Deleted = 0
	</CFQUERY>
</CFIF>

<CFIF IsDefined("Close_900")>
	<CFQUERY NAME="Close900" DATASOURCE="#Application.Datasource#">
		UPDATE 	Log_900 
		SET 	<CFIF IsDefined("FromDDReOpen")>
				DD_ReOpened = 1,
				</CFIF>
				Current_Insert = 0 
		WHERE 	Billback_ID = '#Billback_ID#' AND 
				<!--- Ana 15454 - We still need this update for ReOpen --->					
				Created_Date = <cfqueryparam value="#CREATEODBCDATETIME(DateTimeHolder)#" cfsqltype="cf_sql_timestamp"> AND
				--Current_Insert = 1 AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<CFIF IsDefined("Close_910")>
	<CFQUERY NAME="Close910" DATASOURCE="#Application.Datasource#">
		UPDATE 	Log_910 
		SET 	<CFIF IsDefined("FromDDReOpen")>
				DD_ReOpened = 1,
				</CFIF>
				Current_Insert = 0 
		WHERE 	Billback_ID = '#Billback_ID#' AND 
				<!--- Ana 15454 - We still need this update for ReOpen --->	
				Created_Date = <cfqueryparam value="#CREATEODBCDATETIME(DateTimeHolder)#" cfsqltype="cf_sql_timestamp"> AND
				--Current_Insert = 1 AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<CFIF IsDefined("Close_920")>
	<CFQUERY NAME="Close920" DATASOURCE="#Application.Datasource#">
		UPDATE 	Log_920 
		SET 	<CFIF IsDefined("FromDDReOpen")>
				DD_ReOpened = 1,
				</CFIF>
				Current_Insert = 0 
		WHERE 	Billback_ID = '#Billback_ID#' AND 
				<!--- Ana 15454 - We still need this update for ReOpen --->	
				Created_Date = <cfqueryparam value="#CREATEODBCDATETIME(DateTimeHolder)#" cfsqltype="cf_sql_timestamp"> AND
				--Current_Insert = 1 AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<CFIF IsDefined("Close_1510")>
	<CFQUERY NAME="Close1510" DATASOURCE="#Application.Datasource#">
		UPDATE 	Log_1510 
		SET 	<CFIF IsDefined("FromDDReOpen")>
				DD_ReOpened = 1,
				</CFIF>
				Current_Insert = 0 		
		WHERE 	Deduction_ID = '#Deduction_ID#' AND 
				<!--- Ana 15454 - We still need this update for ReOpen --->	
				Created_Date = <cfqueryparam value="#CREATEODBCDATETIME(DateTimeHolder)#" cfsqltype="cf_sql_timestamp"> AND
				--Current_Insert = 1 AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<CFIF IsDefined("Close_1520")>
	<CFQUERY NAME="Close1520" DATASOURCE="#Application.Datasource#">
		UPDATE 	Log_1520 
		SET 	Current_Insert = 0 		
		WHERE 	Deduction_ID = '#Deduction_ID#' AND 				
				Current_Insert = 1 AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<CFIF IsDefined("Close_1700")>
	<CFQUERY NAME="Close1700" DATASOURCE="#Application.Datasource#">
		UPDATE 	Log_1700 
		SET 	<CFIF IsDefined("FromDDReOpen")>
				DD_ReOpened = 1,
				</CFIF>
				Current_Insert = 0 
		WHERE 	Deduction_ID = '#Deduction_ID#' AND 
				<!--- Ana 15454 - We still need this update for ReOpen --->	
				Created_Date = CONVERT(CHAR(19),<cfqueryparam value="#CREATEODBCDATETIME(DateTimeHolder)#" cfsqltype="cf_sql_timestamp">,120) AND
				--Current_Insert = 1 AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<cftransaction action="commit" />

<cfcatch>
	
	<cftransaction action="rollback" />
	<cfrethrow />
		
</cfcatch>

</cftry>

</cftransaction>