<!---
	Created by: Brenda Flynn
	Created on: January 18, 2010
	Label for creation: 21919
	Lowest build available: 6.1
	
	This functionality allows users to create a list of "Divested Items". 
	Those items are marked with an asterisk in several  billback screens.
	There is no app setting for this functionality. It will not be displayed unless items are selected as divested.
 --->

<cfcomponent hint="This initializes the Divested Items CFC" extends="components.base">

	<!--- Initialize function --->
	<cffunction name="init" output="false" returntype="components.settings.DivestedItems">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- Update "Last Updated By" --->
	<cffunction name="updateLastUpdatedBy" output="false" returntype="void">
		<cfargument name="Updating_User_ID" required="true">
		
		<cfset var qUpdateLastUpdatedBy = "" />	
		
		<cfquery name="qUpdateLastUpdatedBy" datasource="#application.datasource#">
		UPDATE 	Billback_Settings
		SET 	Divested_Updated_Date = getdate(),
				Divested_Updated_By = <cfqueryparam value="#arguments.Updating_User_ID#" cfsqltype="cf_sql_varchar">	
		</cfquery>
		
	</cffunction>
	
	<!--- Get last updated by --->
	<cffunction name="getLastUpdatedBy" output="false" returntype="query">
		<cfset var qLastUpdatedBy = "" />	
		
		<cfquery name="qLastUpdatedBy" datasource="#application.datasource#">
		SELECT 	Billback_Settings.Divested_Updated_Date,
				_Users.Name_First + ' ' + _Users.Name_Last AS Updated_By
		FROM 	Billback_Settings
			INNER JOIN _Users
			ON _Users.User_ID = Billback_Settings.Divested_Updated_By
		</cfquery>
		
		<cfreturn qLastUpdatedBy />
	</cffunction>
	
	<!--- Return a detailed query of all items that are "Is_Divested = 1" ordered by Item Number --->
	<cffunction name="getAllDivestedItemsDetails" output="false" returntype="query">
		
		<cfset var qgetAllDivestedItemsDetails = "" />
		
		<cfquery name="qgetAllDivestedItemsDetails" datasource="#application.datasource#">
			SELECT DISTINCT BSA_Foodservice_Items_Master_ID,
							Item,
							UPC,
							Description
			FROM 	BSA_Foodservice_Items_Master
			WHERE 	Is_Divested = 1
			ORDER BY Item
		</cfquery>
		
		<cfreturn qgetAllDivestedItemsDetails />	
	</cffunction>
	
	<!--- Return a query of all item IDs that are "Is_Divested = 1" ordered by Item Number --->
	<cffunction name="getAllDivestedItemsIDs" output="false" returntype="query">
		
		<cfset var qgetAllDivestedItemIDs = "" />
		
		<cfquery name="qgetAllDivestedItemIDs" datasource="#application.datasource#">
			SELECT DISTINCT BSA_Foodservice_Items_Master_ID 
			FROM 	BSA_Foodservice_Items_Master
			WHERE 	Is_Divested = 1
		</cfquery>
		
		<cfreturn qgetAllDivestedItemIDs />	
	</cffunction>
	
	<!---For each new item added to divested Items, update the value for BSA_Foodservice_Items_Master, updates the log, 
	and updates the "last updated by"--->
	<cffunction name="addDivestedItems" output="false" returntype="void">
		<cfargument name="Returned_Item_List" required="true">
		<cfargument name="User_ID" required="true">
		
		<!--- variables --->
		<cfset var sDeletedItems 	= "" />
		<cfset var sAddedItems 		= "" />
		
		<!--- Queries --->
		<cfset var updateLastModified = "" />
		<cfset var qDeletedItems 	= "" />
		<cfset var qUpdateDeleted 	= "" />
		<cfset var qUpdateDeletedLog= "" />
		<cfset var qNewItems 		= "" />
		<cfset var qUpdateAdded		= "" />
		<cfset var qUpdateAddedLog	= "" />
		
		<!---Update last updated by --->
		<cfset updateLastModified = this.updateLastUpdatedBy(arguments.User_ID)>
		
		<cfset cleanedItemList = ListQualify(Returned_Item_List, "'", ",", "all")>
		
		<!--- Figure out which items used to be divested and aren't, update item master and log --->
		<cfquery name="qDeletedItems" datasource="#application.datasource#">
		SELECT DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		FROM BSA_Foodservice_Items_Master
		WHERE BSA_Foodservice_Items_Master_ID NOT IN 
		<!--- I really, really tried to use CFQUERYPARAM for this, but I couldn't get the single quotes to quit escaping --->
		(#ListQualify(Returned_Item_List, "'", ",", "all")#)
		AND Is_Divested = 1
		</cfquery>
		
		<cfquery name="qNewItems" datasource="#application.datasource#">
		SELECT DISTINCT BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		FROM BSA_Foodservice_Items_Master
		WHERE BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN 
		(#ListQualify(Returned_Item_List, "'", ",", "all")#)
		AND Is_Divested = 0
		</cfquery>
		
		<cfset sDeletedItems 	= ValueList(qDeletedItems.BSA_Foodservice_Items_Master_ID) />
		<cfset sAddedItems 		= ValueList(qNewItems.BSA_Foodservice_Items_Master_ID) />
		
		<cfif len(trim(#sDeletedItems#)) GT 0>
			<cfquery name="qUpdateDeleted" datasource="#application.datasource#">
			UPDATE BSA_Foodservice_Items_Master
			SET Is_Divested = 0
			WHERE BSA_Foodservice_Items_Master_ID 
			IN (#ListQualify(sDeletedItems, "'", ",", "all")#)
			</cfquery>
			
			
			<cfloop list="#sDeletedItems#" index="Item_ID">
				<cfquery name="qUpdateDeletedLog" datasource="#application.datasource#">
				INSERT INTO Divested_Item_History
				(
					BSA_Foodservice_Items_Master_ID,
					Updated_Date,
					Updated_By,
					Divested_Updated_To
				)
				VALUES 
				(
					<cfqueryparam value="#Item_ID#" cfsqltype="cf_sql_varchar">,
					getdate(),
					<cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
					0
				)
				</cfquery>
			</cfloop>
		<!--- There are deleted items --->
		</cfif>
		<!--- For new divested items --->
		
		
		<cfif len(trim(#sAddedItems#)) GT 0>
		<cfquery name="qUpdateAdded" datasource="#application.datasource#">
		UPDATE BSA_Foodservice_Items_Master
		SET Is_Divested = 1
		WHERE BSA_Foodservice_Items_Master_ID 
		IN (#ListQualify(sAddedItems, "'", ",", "all")#)
		</cfquery>
		
		<cfloop list="#sAddedItems#" index="Item_ID">
			<cfquery name="qUpdateAddedLog" datasource="#application.datasource#">
			INSERT INTO Divested_Item_History
			(
				BSA_Foodservice_Items_Master_ID,
				Updated_Date,
				Updated_By,
				Divested_Updated_To
			)
			VALUES 
			(
				<cfqueryparam value="#Item_ID#" cfsqltype="cf_sql_varchar">,
				getdate(),
				<cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
				1
			)
			</cfquery>
		</cfloop>
		
		<!--- are there any items to add? ---->
		</cfif>	
	</cffunction>
	
	<!--- Deletes a divested item by updating the value of Is_Divested = 0, updates the log, and updates the last updated by--->
	<cffunction name="deleteDivestedItem" output="false" returntype="void">
		<cfargument name="Item_ID" required="true">
		<cfargument name="User_ID" required="true">
		
		<cfset var updateLastModified = "" />
		<cfset var qDeleteOneItemAsDivestedLog = "" />
		<cfset var qDeleteOneItemAsDivested = "" />
		
		<!---Update last updated by --->
		<cfset updateLastModified = this.updateLastUpdatedBy(arguments.User_ID)>
		
		<!--- First log entry --->
		<cfquery name="qDeleteOneItemAsDivestedLog" datasource="#application.datasource#">
		INSERT INTO Divested_Item_History
			(
				BSA_Foodservice_Items_Master_ID,
				Updated_Date,
				Updated_By,
				Divested_Updated_To
			)
			VALUES 
			(
				<cfqueryparam value="#arguments.Item_ID#" cfsqltype="cf_sql_varchar">,
				getdate(),
				<cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
				0
			)
		</cfquery>
		
		<!--- Then update item master --->
		<cfquery name="qDeleteOneItemAsDivested" datasource="#application.datasource#">
		UPDATE BSA_Foodservice_Items_Master
		SET Is_Divested = 0
		WHERE BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#arguments.Item_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
					
	</cffunction>
	
	<!--- Restores a divested item by updating the value of Is_Divested = 1, updates the log, 
	and updates the last updated by -- this is for use when someone "unscissors" an item. --->
	<cffunction name="restoreDivestedItem" output="false" returntype="void">
		<cfargument name="Item_ID" required="true">
		<cfargument name="User_ID" required="true">
		
		<cfset var updateLastModified = "" />
		<cfset var qRestoreOneItemAsDivestedLog = "" />
		<cfset var qRestoreOneItemAsDivested = "" />
		
		<!---Update last updated by --->
		<cfset updateLastModified = this.updateLastUpdatedBy(arguments.User_ID)>
		
		<!--- First log entry --->
		<cfquery name="qRestoreOneItemAsDivestedLog" datasource="#application.datasource#">
		INSERT INTO Divested_Item_History
			(
				BSA_Foodservice_Items_Master_ID,
				Updated_Date,
				Updated_By,
				Divested_Updated_To
			)
			VALUES 
			(
				<cfqueryparam value="#arguments.Item_ID#" cfsqltype="cf_sql_varchar">,
				getdate(),
				<cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
				1
			)
		</cfquery>
		
		<!--- Then update item master --->
		<cfquery name="qDeleteOneItemAsDivested" datasource="#application.datasource#">
		UPDATE BSA_Foodservice_Items_Master
		SET Is_Divested = 1
		WHERE BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#arguments.Item_ID#" cfsqltype="cf_sql_varchar">
		</cfquery>
					
	</cffunction>
	
	<!--- Identify divested items: takes a list of items and returns those items which are divested --->
	<cffunction name="identifyDivestedItems" output="false" returntype="string">
		<cfargument name="Item_List" required="true">
		
			
	</cffunction>
	
</cfcomponent>