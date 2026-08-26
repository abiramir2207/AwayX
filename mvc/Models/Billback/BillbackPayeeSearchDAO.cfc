<!---
Name: 			BillbackPayeeSearchDAO.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	05/23/2011
Created By:    	Tim Ford
Description:	I am responsible DB payee search access for billback data.
Parameters:		N/A
Usage:			N/A
--->
<cfcomponent name="BillbackPayeeSearchDAO" displayname="BillbackPayeeSearchDAO">
	
	<!--- get payee data--->
	<cffunction name="searchPayeeData" output="false" access="public" returntype="query">
	
		<cfargument name="payeeId"	required="true"	type="string" />
		
		<cfscript>
			//set local variables
			var strPayeeId		= "";
			var qSearch			= "";
			var qReturn			= "";
			
			//assign local variables
			strPayeeId	= arguments.payeeId;
		</cfscript>
	
		<cfset useLakebaseForqSearch = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForqSearch>
	<cftry>
		<cfset qSearch = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", {
				"vendor_id" = "eq.#strPayeeId#",
				"select" = "vendor_name as name,vendor_id as payeeid,address_1 as addressline1,address_2 as addressline2,city as city,state as state,zipcode as zipcode"
			}), "vendor_name as name,vendor_id as payeeid,address_1 as addressline1,address_2 as addressline2,city as city,state as state,zipcode as zipcode"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqSearch = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqSearch>
<cfquery name="qSearch" datasource="#application.datasource#">
			SELECT	Vendor_Name AS name,
					Vendor_ID AS payeeId,
					Address_1 AS addressLine1,
					Address_2 AS addressLine2,
					City AS city,
					State AS state,
					Zipcode AS zipCode
			FROM	Vendor_Master
			WHERE	Vendor_ID = '#strPayeeId#'
		</cfquery>
</cfif>
	
		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>
		
	</cffunction>
	
</cfcomponent>