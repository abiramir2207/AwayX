<!--- SearchSelection.cfc - Copyright (c) 2009 Blacksmith Applications, Inc.--->
<!--- Created By: Brenda Flynn 2/2/2009 --->
<!--- Clearing house for all search selection logging--->
<cfcomponent>

	<cffunction name="init" output="false">
		<cfreturn this />
	</cffunction>

	<!--- The generic function that enters all specific search screen results to the db --->
	<cffunction name="saveSearchSelection" output="false">

		<cfargument name="Search_Page" required="true" default="" />
		<cfargument name="Environment" required="true" default="" />
		<cfargument name="User_ID" required="true" default="" />
		<cfargument name="Number_of_criteria" required="false" default="0" />
		<cfargument name="Number_of_records" required="false" default="0" />
		<cfargument name="ExecutionTime" required="false" default="" />
		<cfargument name="Selections" required="false" default="" />

		<cfquery name="qSaveSearchSelection" datasource="#application.datasource#">
			INSERT INTO Search_Selections
			(
				Search_Page,
				Environment,
				User_ID,
				Number_of_criteria,
				Number_of_records,
				ExecutionTime,
				Selections
			)
			VALUES
			(
				<cfqueryparam value="#arguments.Search_Page#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.Environment#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#arguments.Number_of_criteria#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.Number_of_records#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.ExecutionTime#" cfsqltype="CF_SQL_INTEGER">,
				<cfqueryparam value="#arguments.Selections#">
			)
		</cfquery>

		<cfreturn this />

	</cffunction>

	<cffunction name="DistributorSearch" output="true">
		<cfargument name="Search_Page" required="true" default="" />
		<cfargument name="Environment" required="true" default="" />
		<cfargument name="User_ID" required="true" default="" />
		<cfargument name="SearchCriteria" required="false" default="" />
		<cfargument name="Number_of_records" required="false" default="0" />
		<cfargument name="ExecutionTime" required="false" default="" />
		<!--- Compare values I have vs. defaults from  /common_files/contracts/select_distributors.cfm (/components/customer/DistributorManager.cfc) and log the deltas --->

		<!--- ************** BEGIN DEFINE DELTAS ****************** --->
		<cfset SearchDelta = "">
		<cfset CriteriaCount = 0>
			<!--- checkFinalItemList --->
			<cfif isDefined("SearchCriteria.checkFinalItemList")>
				<cfif SearchCriteria.checkFinalItemList NEQ 0>
					<cfset SearchDelta = SearchDelta & "FinalItemList (List tool) = #SearchCriteria.FinalItemList# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Distributor_Status --->
			<cfif isDefined("SearchCriteria.Distributor_Status")>
				<cfif len(trim(#SearchCriteria.Distributor_Status#)) AND SearchCriteria.Distributor_Status NEQ
				"A">
					<cfset SearchDelta = SearchDelta & "Distributor_Status (Active_Code) = #SearchCriteria.Distributor_Status# |">

					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- itemList --->
			<cfif isDefined("SearchCriteria.itemList")>
				<cfif len(trim(#SearchCriteria.itemList#))>
					<cfset SearchDelta = SearchDelta & "itemList (Ship To List) = #SearchCriteria.itemList# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Ship_To --->
			<cfif isDefined("SearchCriteria.Ship_To")>
				<cfif len(trim(#SearchCriteria.Ship_To#))>
					<cfset SearchDelta = SearchDelta & "Ship_To = #SearchCriteria.Ship_To# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Family_Name --->
			<cfif isDefined("SearchCriteria.Family_Name")>
				<cfif len(trim(#SearchCriteria.Family_Name#)) AND SearchCriteria.Family_Name NEQ 0>
					<cfset SearchDelta = SearchDelta & "Family_Name = #SearchCriteria.Family_Name# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Buying_Group --->
			<cfif isDefined("SearchCriteria.Buying_Group") AND SearchCriteria.Buying_Group NEQ 0>
				<cfif len(trim(#SearchCriteria.Buying_Group#))>
					<cfset SearchDelta = SearchDelta & "Buying_Group = #SearchCriteria.Buying_Group# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Line_Of_Biz --->
			<cfif isDefined("SearchCriteria.Line_Of_Biz")>
				<cfif len(trim(#SearchCriteria.Line_Of_Biz#)) AND SearchCriteria.Line_Of_Biz NEQ 0>
					<cfset SearchDelta = SearchDelta & "Line_Of_Biz = #SearchCriteria.Line_Of_Biz# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Cust_Id --->
			<cfif isDefined("SearchCriteria.Cust_Id")>
				<cfif len(trim(#SearchCriteria.Cust_Id#)) AND SearchCriteria.Cust_Id NEQ 0>
					<cfset SearchDelta = SearchDelta & "Cust_Id = #SearchCriteria.Cust_Id# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Zone_ID --->
			<cfif isDefined("SearchCriteria.Zone_ID")>
				<cfif len(trim(#SearchCriteria.Zone_ID#)) AND SearchCriteria.Zone_ID NEQ 0>
					<cfset SearchDelta = SearchDelta & "Zone_ID = #SearchCriteria.Zone_ID# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Region_ID --->
			<cfif isDefined("SearchCriteria.Region_ID")>
				<cfif len(trim(#SearchCriteria.Region_ID#)) AND SearchCriteria.Region_ID NEQ 0>
					<cfset SearchDelta = SearchDelta & "Region_ID = #SearchCriteria.Region_ID# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Broker --->
			<cfif isDefined("SearchCriteria.Broker")>
				<cfif len(trim(#SearchCriteria.Broker#)) AND SearchCriteria.Broker NEQ 0>
					<cfset SearchDelta = SearchDelta & "Broker = #SearchCriteria.Broker# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- State --->
			<cfif isDefined("SearchCriteria.State")>
				<cfif len(trim(#SearchCriteria.State#)) AND SearchCriteria.State NEQ 0>
					<cfset SearchDelta = SearchDelta & "State = #SearchCriteria.State# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- country_code --->
			<cfif isDefined("SearchCriteria.country_code")>
				<cfif len(trim(#SearchCriteria.country_code#)) AND SearchCriteria.country_code NEQ 0>
					<cfset SearchDelta = SearchDelta & "country_code = #SearchCriteria.country_code# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- LOADPRODUCTSFROMTHESEPROGRAMS --->
			<cfif isDefined("SearchCriteria.LOADPRODUCTSFROMTHESEPROGRAMS")>
				<cfif len(trim(#SearchCriteria.LOADPRODUCTSFROMTHESEPROGRAMS#)) AND SearchCriteria.LOADPRODUCTSFROMTHESEPROGRAMS NEQ 0>
					<cfset SearchDelta = SearchDelta & "LOADPRODUCTSFROMTHESEPROGRAMS = #SearchCriteria.LOADPRODUCTSFROMTHESEPROGRAMS# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- searchstring --->
			<cfif isDefined("SearchCriteria.searchstring")>
				<cfif len(trim(#SearchCriteria.searchstring#))>
					<cfset SearchDelta = SearchDelta & "searchstring = #SearchCriteria.searchstring# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Dist_Name --->
			<cfif isDefined("SearchCriteria.Dist_Name")>
				<cfif len(trim(#SearchCriteria.Dist_Name#))>
					<cfset SearchDelta = SearchDelta & "Dist_Name = #SearchCriteria.Dist_Name# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Line_Of_Business_ID --->
			<cfif isDefined("SearchCriteria.Line_Of_Business_ID")>
				<cfif len(trim(#SearchCriteria.Line_Of_Business_ID#))>
					<cfset SearchDelta = SearchDelta & "Line_Of_Business_ID = #SearchCriteria.Line_Of_Business_ID# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Line_Of_Business_ID --->
			<cfif isDefined("SearchCriteria.Customer_Type")>
				<cfif len(trim(#SearchCriteria.Customer_Type#))>
					<cfset SearchDelta = SearchDelta & "Customer_Type = #SearchCriteria.Customer_Type# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Line_Of_Business_ID --->
			<cfif isDefined("SearchCriteria.Customer_Type")>
				<cfif len(trim(#SearchCriteria.Customer_Type#))>
					<cfset SearchDelta = SearchDelta & "Customer_Type = #SearchCriteria.Customer_Type# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- Sort orders --->
			<cfif isDefined("SearchCriteria.sort_by")>
				<cfif len(trim(#SearchCriteria.sort_by#)) AND sort_by NEQ "Name">
					<cfset SearchDelta = SearchDelta & "sort_by = #SearchCriteria.sort_by# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- sql_Sort_By_Order --->
			<cfif isDefined("SearchCriteria.sort_Order")>
				<cfif len(trim(#SearchCriteria.sort_Order#)) AND sort_Order NEQ "ASC">
					<cfset SearchDelta = SearchDelta & "sort_Order = #SearchCriteria.sort_Order# |">
					<cfset CriteriaCount = CriteriaCount + 1>
				</cfif>
			</cfif>
			<!--- ************** BEGIN DEFINE DELTAS ****************** --->

			<!--- Call save function --->
			<cfset SaveSelection = saveSearchSelection
			(	arguments.Search_Page,
				arguments.Environment,
				arguments.User_ID,
				CriteriaCount,
				arguments.Number_of_Records,
				arguments.ExecutionTime,
				SearchDelta
			)>

		<cfreturn this />
	</cffunction>
</cfcomponent>