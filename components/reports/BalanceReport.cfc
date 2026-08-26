<!--- BalanceReport.cfc - Copyright (c) 2004 Blacksmith Applications, Inc.--->
<!--- Created By: Tim Ford on 06/07/2005 --->
<!--- component to handle Balance Report data--->
<cfcomponent>

	<cffunction name="init" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getBillbackSummary" output="false" returntype="query">
	
		<cfargument name="date" required="false" default="" />
		
		<cfquery name="qGetBillbackInterfaceSummaryData" datasource="#application.datasource#">
			SELECT 	Log_900.BB_Code,
					Log_900.Billback_ID,
					Log_900.Vendor_ID,
					BSA_Foodservice_Customers.Name,
					Vendor_Master.Vendor_Name
			FROM 	Log_900
					INNER JOIN BSA_Foodservice_Customers ON
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Log_900.Distributor_ID
					INNER JOIN Vendor_Master ON
					Vendor_Master.Vendor_Master_ID = Log_900.Vendor_Master_ID
			WHERE	Log_900.Deleted = 0
			AND 	Log_900.Interface_Executed_On <= '#arguments.date#'		
		</cfquery>
		
		<cfreturn qGetBillbackInterfaceSummaryData />
		
	</cffunction>
	
	<cffunction name="getBillbackDetail" output="false" returntype="query">
	
		<cfargument name="billbackId" type="string" required="false" default="" />
		
		<cfquery name="qGetBillbackInterfaceData" datasource="#application.datasource#">
			SELECT 	Log_700.Allocated_Amount,
					Log_700.SCOA_Fund_Number,
					Log_910.Approved_Amount,
					Log_910.Fund_Number
			FROM 	Log_700
					INNER JOIN Log_910 ON
					Log_910.Billback_ID = Log_700.Billback_ID
					AND Log_910.Deleted = 0
			WHERE	Log_700.Deleted = 0
			AND 	Log_700.Billback_ID = '#arguments.billbackId#'		
		</cfquery>
		
		<cfreturn qGetBillbackInterfaceData />
		
	</cffunction>
	
	<cffunction name="getBillbackTotal" output="false" returntype="query">
	
		<cfargument name="billbackId" type="string" required="false" default="" />
		
		<cfquery name="qGetBillbackInterfaceTotals" datasource="#application.datasource#">
			SELECT	Log_900.Approved_Amount,
					SUM(ISNULL(Log_700.Allocated_Amount,0.00)) as Allocated_Sum,
					SUM(ISNULL(Log_910.Approved_Amount,0.00)) as Approved_Sum
			FROM 	Log_900
					INNER JOIN Log_700 ON
					Log_700.Billback_ID = Log_900.Billback_ID
					AND Log_700.Deleted = 0
					INNER JOIN Log_910 ON
					Log_910.Billback_ID = Log_900.Billback_ID
					AND Log_910.Deleted = 0
			WHERE	Log_900.Deleted = 0
			AND 	Log_900.Billback_ID = '#arguments.billbackId#'
			
			GROUP BY Log_900.Billback_ID, Log_900.Approved_Amount		
		</cfquery>
		
		<cfreturn qGetBillbackInterfaceTotals />
		
	</cffunction>
	
	<cffunction name="getDeductionDetail" output="false" returntype="query">
	
		<cfargument name="billbackId" type="string" required="false" default="" />
		
		<cfquery name="qGetDeductionInterfaceData" datasource="#application.datasource#">
			SELECT 	Log_910.Approved_Amount,
					Log_910.Fund_Number,
					Log_1700.Allocated_Amount,
					Log_1700.SCOA_Fund_Number
			FROM 	Log_910
					INNER JOIN Log_1700 ON
					Log_1700.Billback_ID = Log_910.Billback_ID
					AND Log_1700.Deleted = 0
					INNER JOIN Log_1510 ON
					Log_1510.Deduction_ID = Log_1700.Deduction_ID
					AND Log_1510.Deleted = 0
			WHERE	Log_910.Deleted = 0
			AND 	Log_910.Billback_ID = '#arguments.billbackId#'		
		</cfquery>
		
		<cfreturn qGetDeductionInterfaceData />
		
	</cffunction>
	
	<cffunction name="getDeductionTotal" output="false" returntype="query">
	
		<cfargument name="billbackId" type="string" required="false" default="" />
		
		<cfquery name="qGetDeductionInterfaceTotals" datasource="#application.datasource#">
			SELECT	Log_900.Approved_Amount,
					SUM(ISNULL(Log_1700.Allocated_Amount,0.00)) as Allocated_Sum,
					SUM(ISNULL(Log_910.Approved_Amount,0.00)) as Approved_Sum
			FROM 	Log_900
					INNER JOIN Log_1700 ON
					Log_1700.Billback_ID = Log_900.Billback_ID
					AND Log_1700.Deleted = 0
					INNER JOIN Log_910 ON
					Log_910.Billback_ID = Log_900.Billback_ID
					AND Log_910.Deleted = 0
			WHERE	Log_900.Deleted = 0
			AND 	Log_900.Billback_ID = '#arguments.billbackId#'
			
			GROUP BY Log_900.Billback_ID, Log_900.Approved_Amount		
		</cfquery>
		
		<cfreturn qGetDeductionInterfaceTotals />
		
	</cffunction>
	
</cfcomponent>