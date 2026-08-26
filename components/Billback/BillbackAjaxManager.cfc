<!---  
       Name:          BillbackAjaxManager.cfc    
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  5/11/2010
       Created By:    dkunnath
       Description:   
--->
<cfcomponent extends="components.ajaxCFC.ajax">

	<cffunction name="unlockBillback" access="public" returntype="boolean">
		<cfargument name="billbackID" type="string" required="true" />
		<cfargument name="userID" type="string" required="true" />
		<cfargument name="checkIfLockedByDeviationGrid" type="boolean" required="true" />
		
		<cfset var argArray 	= arguments[1] />
		
		<cfquery name="qUnlockBillback" datasource="#application.datasource#">
			UPDATE Billback_Allied
			SET    BB_Is_Locked = 0,
			       BB_Locked_By_User_ID = NULL,
			       BB_Lock_Date = NULL,
			       BB_Locked_By_Deviation_Grid = 0
			WHERE 	Billback_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackID#" />
			AND		BB_Locked_By_User_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#" />
			<cfif arguments.checkIfLockedByDeviationGrid eq "1">
			AND		BB_Locked_By_Deviation_Grid = 1
			</cfif>
		</cfquery>
		
		<cfreturn 1 />
			
	</cffunction>
	
	<cffunction name="unlockDeviationGridLock" access="public" returntype="boolean">
		<cfargument name="billbackID" type="string" required="true" />
		<cfargument name="userID" type="string" required="true" />
		
		<cfquery name="qUnlockBillback" datasource="#application.datasource#">
			UPDATE 	Billback_Allied
			SET    	BB_Locked_By_Deviation_Grid = 0
			WHERE 	Billback_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.billbackID#" />
			AND		BB_Locked_By_User_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#" />			
		</cfquery>
		
		<cfreturn 1 />
			
	</cffunction>
	
</cfcomponent>