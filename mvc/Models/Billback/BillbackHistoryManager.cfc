<!---
Name: 			BillbackHistoryManager.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	08/23/2011
Created By:    	Tim Ford
Description:	I am responsible for managing billback history data.
Parameters:		N/A
Usage:			N/A
--->
<cfcomponent name="BillbackHistoryManager" displayname="BillbackHistoryManager">

	<!--- get billback copy history data --->
	<cffunction name="getBillbackCopyHistory" output="false">
	
		<cfargument name="billbackId" type="string" required="true">
		
		<cfscript>
			//set local variables
			var strBillbackId				= "";
			var qGetBillbackHistoryData		= "";
			var qRetBillbackHistoryData		= "";

			//assign local variables
			strBillbackId	= arguments.billbackId;
		</cfscript>
	
		<cfquery name="qGetBillbackHistoryData" datasource="#Application.Datasource#">
			SELECT	_Users.Name_First + ' ' + _Users.Name_Last AS Copied_By, Billback.Created_Date, Billback.BB_Code
			FROM	Billback
					INNER JOIN _Users ON _Users.User_ID = Billback.BB_Creator_ID
			WHERE	CopiedBB = <cfqueryparam value="#strBillbackId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfscript>
			qRetBillbackHistoryData = qGetBillbackHistoryData;
			return qRetBillbackHistoryData;
		</cfscript>
		
	</cffunction>

	<!--- get billback adjusted by data --->
	<cffunction name="getBillbackAdjustedBy" output="false">
	
		<cfargument name="billbackId" type="string" required="true">
		
		<cfscript>
			//set local variables
			var strBillbackId				= "";
			var qGetBillbackAdjustedByData	= "";
			var qRetBillbackAdjustedByData	= "";

			//assign local variables
			strBillbackId	= arguments.billbackId;
		</cfscript>
	
		<cfquery name="qGetBillbackAdjustedByData" datasource="#Application.Datasource#">
			SELECT	_Users.Name_First + ' ' + _Users.Name_Last AS Adjusted_By, Billback.BB_Adjusted_Date
			FROM	Billback
					INNER JOIN _Users ON _Users.User_ID = Billback.BB_Adjusted_By
			WHERE	Billback_ID = <cfqueryparam value="#strBillbackId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfscript>
			qRetBillbackAdjustedByData = qGetBillbackAdjustedByData;
			return qRetBillbackAdjustedByData;
		</cfscript>
		
	</cffunction>
	
	<!--- get billback adjusted program data --->
	<cffunction name="getBillbackAdjustedProgram" output="false">
	
		<cfargument name="billbackId" type="string" required="true">
		
		<cfscript>
			//set local variables
			var strBillbackId				= "";
			var qGetBillbackAdjustedData	= "";
			var qRetBillbackAdjustedData	= "";

			//assign local variables
			strBillbackId	= arguments.billbackId;
		</cfscript>
	
		<cfquery name="qGetBillbackAdjustedData" datasource="#Application.Datasource#">
			SELECT	DISTINCT CM_Old.Contract_Number AS Old_Program_Number, CM_New.Contract_Number AS New_Program_Number
			FROM	BB_Switch_Program_Log
					INNER JOIN Contract_Main CM_Old ON CM_Old.Contract_Main_ID = BB_Switch_Program_Log.Old_Program_ID
					INNER JOIN Contract_Main CM_New ON CM_New.Contract_Main_ID = BB_Switch_Program_Log.New_Program_ID
			WHERE	BB_Switch_Program_Log.Billback_ID =  <cfqueryparam value="#strBillbackId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfscript>
			qRetBillbackAdjustedData = qGetBillbackAdjustedData;
			return qRetBillbackAdjustedData;
		</cfscript>
		
	</cffunction>
	
</cfcomponent>