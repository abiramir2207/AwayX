<!---
Name: 			BillbackPayeeSearchManager.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	05/23/2011
Created By:    	Tim Ford
Description:	I am responsible for assembling and returning payee data needed for billbacks.
Parameters:		N/A
Usage:			N/A
--->
<cfcomponent name="BillbackPayeeSearchManager" displayname="BillbackPayeeSearchManager">

	<!--- initialize the BillbackPayeeSearchDAO to use for all functions in BillbackPayeeSearchManager --->
	<cfscript>
		objBillbackPayeeSearchDAO 		= CreateObject("component","mvc.Models.Billback.BillbackPayeeSearchDAO");
	</cfscript>
	
	<!--- get payee data--->
	<cffunction name="getPayeeData" output="false" access="remote">
	
		<cfargument name="payeeId"	required="true"	type="string" />
		
		<cfscript>
			//set local variables
			var strPayeeId			= "";
			var stRetData		= structNew();
			var	qGetPayeeData	= "";
			var idxRow			= "";
			
			//assign local variables
			strPayeeId			= arguments.payeeId;
			
			qGetPayeeData = objBillbackPayeeSearchDAO.searchPayeeData(strPayeeId);
			
			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetPayeeData.RecordCount; idxRow = (idxRow + 1))
			{
				//Populate Address VO
				stData = structNew();
				stData["__type__"] 		= "mvc.Models.Entity.vos.Address";
				stData["addressLine1"] 	= qGetPayeeData["addressLine1"][idxRow];
				stData["addressLine2"] 	= qGetPayeeData["addressLine2"][idxRow];
				stData["city"] 			= qGetPayeeData["city"][idxRow];
				stData["state"] 		= qGetPayeeData["state"][idxRow];
				stData["zipCode"] 		= qGetPayeeData["zipCode"][idxRow];
            	
				//Populate Payee VO
				stRetData["__type__"] 		= "mvc.Models.Entity.vos.Payee";
				stRetData["payeeTypeId"]	= 1;
				stRetData["name"] 			=  qGetPayeeData["name"][idxRow];
				stRetData["payeeId"] 		=  qGetPayeeData["payeeId"][idxRow];
				stRetData["address"] 		= stData;
				
			}
			return stRetData;
		</cfscript>
	
	</cffunction>

</cfcomponent>