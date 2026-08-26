<!---
Name: 			BillbackEditManager.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	05/18/2011
Created By:    	Tim Ford
Description:	I am responsible for editing billback data.
Parameters:		N/A
Usage:			N/A
--->
<cfcomponent name="BillbackEditManager" displayname="BillbackEditManager" extends="mvc.Models.SettingsService">

	<!--- initialize the BillbackDAO and BillbackEditDAO to use for all functions in BillbackEditManager --->
	<cfscript>
		objBillbackDAO 		= CreateObject("component","mvc.Models.Billback.BillbackDAO");
		objBillbackEditDAO 	= CreateObject("component","mvc.Models.Billback.BillbackEditDAO");
	</cfscript>

	<!--- 108837: Sometimes users click save before the response from approve is returned. Check if the BB is apprroved to prevent save and resetting BB closing method --->
	<cffunction name="checkBillbackStatus" output="false" access="remote" returnformat="JSON">
		<cfargument name="billbackidint" 	required="true" type="numeric">

		<cfset useLakebaseForqCheckBBStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqCheckBBStatus>
	<cftry>
		<cfset qCheckBBStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id_int" = "eq.#arguments.billbackidint#",
				"select" = "billback_status_id"
			}), "billback_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckBBStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckBBStatus>
<cfquery name="qCheckBBStatus" datasource="#application.datasource#" >
			Select Billback_Status_ID from Billback Where Billback_ID_Int = #arguments.billbackidint#
		</cfquery>
</cfif>

		<cfreturn application.util.struct.structSortLowerCase(serializeJSON(qCheckBBStatus, "struct")) />

	</cffunction>

	<!--- save billback data--->
	<cffunction name="saveBillbackJSON" output="false" access="remote" returnformat="JSON">

		<cfargument name="billback" type="struct" required="true">

		<cfscript>
			//assign local variables
			local.stBBHdr = this.saveBillback(arguments.billback);

			//return the billback struct
			local.stBBHdr = application.util.struct.structSortLowerCase(local.stBBHdr);
			return serializeJSON(local.stBBHdr, "struct");
		</cfscript>

	</cffunction>

	<!--- save billback data--->
	<cffunction name="saveBillback" output="false" access="remote">

		<cfargument name="billback" type="struct" required="true">

		<cfscript>
			//set local variables
			var stBillback				= structNew();
			var nRetBillbackIDInt		= "";
			var objBillbackManager		= "";
			var stRetStruct				= structNew();
			//assign local variables
			stBillback			= arguments.billback;
			objBillbackManager 	= CreateObject("component","mvc.Models.Billback.BillbackManager");

			//save billback data
			nRetBillbackIDInt = objBillbackEditDAO.saveBillbackData(stBillback);

			//use the billback int id returned from the saveBillbackData() function to get the billback
			// stRetStruct = objBillbackManager.getBillback(nRetBillbackIDInt);

			/* KAL changes to speed up the save */
			stRetStruct = objBillbackManager.getBBHeader(nRetBillbackIDInt);

			//return the billback struct
			return stRetStruct;

		</cfscript>

	</cffunction>

	<!--- copy billback data--->
	<cffunction name="copyBillback" output="false" access="remote">

		<cfargument name="billbackIDInt" 	required="true" type="numeric">
		<cfargument name="userId" 			required="true" type="string">

		<cfscript>
			//set local variables
			var nBillbackID			= "";
			var strUserId			= "";
			var stBillback			= structNew();
			var nRetBillbackIDInt 	= "";
			var objBillbackManager	= "";
			var stRetData			= structNew();
			var bCopyAction		= 1;

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
			strUserId	= arguments.userId;
			objBillbackManager 	= CreateObject("component","mvc.Models.Billback.BillbackManager");

			// get billback data using the existing billback id int
			stBillback =  objBillbackManager.getBillback(nBillbackID);

			// remove billback data not required for copy
			stBillback.bbHeader.billbackIDInt 		= '';
			stBillback.bbHeader.BBNumber 			= '';
			stBillback.bbHeader.referenceNumber 	= '';
			stBillback.bbHeader.requestApprovalDate	= '';
			stBillback.bbHeader.BBDate				= "#dateformat(now(), "mm/dd/yyyy")#";
			stBillback.bbHeader.startDate 			= "#dateformat(now(), "mm/dd/yyyy")#";
			stBillback.bbHeader.endDate 			= "#dateformat(now(), "mm/dd/yyyy")#";
            stBillback.receivedDate 				= "#dateformat(now(), "mm/dd/yyyy")#";
			stBillback.postDate 					= "#dateformat(now(), "mm/dd/yyyy")#";
			stBillback.claimedCS					= 0.00;
			stBillback.claimedLB					= 0.00;
			stBillback.bbHeader.creator.id			= strUserId;
			stBillback.bbHeader.CopiedBB 			= stBillback.bbHeader.billbackIDGUID;


			//save copied billback data
			nRetBillbackIDInt = objBillbackEditDAO.saveBillbackData(stBillback);

			// call get billback with the new billback id int then return it
			stRetData = objBillbackManager.getBillback(nRetBillbackIDInt,bCopyAction);
			return stRetData;

		</cfscript>

	</cffunction>

	<cffunction name="copyBillbackJSON" output="false" returntype="string" returnformat="JSON" access="remote">

		<cfargument name="billbackIDInt" 	required="true" type="numeric">
		<cfargument name="userId" 			required="true" type="string">

		<cfscript>
			var a = arguments;
			var b = this.copyBillback(a.billbackIDInt, a.userId);
			b = application.util.struct.structSortLowerCase(b);

			var jsonData = '';
			jsonData = serializeJson(b);

			return jsonData;
		</cfscript>
	</cffunction>



	<cffunction name="runBillbackDeviation" output="false" access="remote" returntype="mvc.Models.Billback.vos.Status">

		<cfargument name="billbackIDInt"	type="numeric" 	required="true">
		<cfargument name="userId" 			type="string"	required="true">

		<cfscript>
			//set local variables
			var nBillbackID			= "";
			var strUserID			= "";
			var oBillbackDAO = "";
			var q = "";
			var bbStatus 	= CreateObject("component","mvc.Models.Billback.vos.Status");
			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
			strUserID	= arguments.userId;

			//call runBillbackDeviationData() function
			objBillbackEditDAO.runBillbackDeviationData(nBillbackID, strUserID);
			oBillbackDAO = CreateObject("component","mvc.Models.Billback.BillbackDAO");
			q = oBillbackDAO.getBBRecord(nBillbackID);
			bbStatus.id = q.Billback_Status_ID;
			bbStatus.description = q.BB_Status_Description;
			bbStatus.abbreviation = q.BB_Status_Abbreviation;
			return bbStatus;
		</cfscript>

	</cffunction>

	<cffunction name="runBillbackDeviationJSON" output="false" returntype="string" returnformat="JSON" access="remote">

		<cfargument name="billbackIDInt"	type="numeric" 	required="true">
		<cfargument name="userId" 			type="string"	required="true">

		<cfscript>
			var a = arguments;
			var b = this.runBillbackDeviation(a.billbackIDInt, a.userId);
			b = application.util.struct.structSortLowerCase(b);

			var jsonData = '';
			jsonData = serializeJson(b);

			return jsonData;
		</cfscript>

	</cffunction>


</cfcomponent>