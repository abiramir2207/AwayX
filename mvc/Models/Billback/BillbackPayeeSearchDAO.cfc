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
	
		<cfscript>
			qReturn = qSearch;
			return qReturn;
		</cfscript>
		
	</cffunction>
	
</cfcomponent>