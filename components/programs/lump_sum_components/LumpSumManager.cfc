<cfcomponent displayname="LumpSumManager">

	<cffunction name="init" returntype="components.programs.lump_sum_components.LumpSumManager">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getLumpSumDistributors" returntype="query" output="false">
		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="lumpsumId" type="string" required="false" default="" />
		<cfargument name="returnOnlySelected" type="boolean" required="false" default="0" />
		
		<cfquery name="qGetLumpSumDistributors" datasource="#application.datasource#">
			SELECT  Program_Lump_Sums.Program_Lump_Sum_ID,
					Program_Lump_Sum_Name.Program_Lump_Sum_Name,
					Program_Lump_Sums.Lump_Sum_Amount,
					Name, 
					BSA_Foodservice_Customers.Shr_Ship_To, 
					BSA_Foodservice_Customers.City, 
					BSA_Foodservice_Customers.State, 
					BSA_Foodservice_Customers.Address_1,
					BSA_Foodservice_Customers.zipcode,
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
					CASE
					WHEN Program_Lump_Sum_Distributor.Program_ID IS NULL THEN 0
					ELSE 1
					END IsSelected
			FROM	Contract_Distributors 
					INNER JOIN	BSA_Foodservice_Customers 
					ON 
					Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					LEFT JOIN Program_Lump_Sum_Distributor
					ON
					Program_Lump_Sum_Distributor.Deleted = 0
					AND Program_Lump_Sum_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					AND Program_Lump_Sum_Distributor.Program_ID = Contract_Distributors.Contract_Main_ID
					<cfif arguments.lumpsumId NEQ "">
					AND Program_Lump_Sum_Distributor.Program_Lump_Sum_ID = '#arguments.lumpsumId#'
					</cfif>
					LEFT JOIN Program_Lump_Sums
					ON	Program_Lump_Sums.Program_Lump_Sum_ID = Program_Lump_Sum_Distributor.Program_Lump_Sum_ID
					LEFT JOIN Program_Lump_Sum_Name
					ON	Program_Lump_Sum_Name.Program_Lump_Sum_Name_ID = Program_Lump_Sums.Program_Lump_Sum_Name_ID
			WHERE   Contract_Distributors.Contract_Main_ID = '#arguments.programId#'
			AND 	Contract_Distributors.Deleted = 0
			AND 	Contract_Distributors.Is_Group = 0
			<cfif arguments.returnOnlySelected EQ 1>
			AND		Program_Lump_Sum_Distributor.Program_ID IS NOT NULL
			</cfif>
			ORDER BY Program_Lump_Sums.Program_Lump_Sum_ID, Name
		</cfquery>
		
		<cfreturn qGetLumpSumDistributors />
		
	</cffunction>
	
	<cffunction name="anyLumpSumWithoutDistributor" returntype="boolean" output="false">
		<cfargument name="programId" type="numeric" required="true" />
		
		<cfset bAnyLumpSumWithoutDistributor = 0 />
		<cfquery name="qGetLumpSumDistributors" datasource="#application.datasource#">
			SELECT  Program_Lump_Sums.Program_Lump_Sum_ID
			FROM	Program_Lump_Sums					
			WHERE   Program_Lump_Sums.Deleted = 0
			AND 	Program_Lump_Sums.Program_ID = #arguments.programId#
			AND		Program_Lump_Sums.Program_Lump_Sum_ID NOT IN
				(
					SELECT	DISTINCT Program_Lump_Sum_ID
					FROM	Program_Lump_Sum_Distributor
					WHERE	Program_Lump_Sum_Distributor.Deleted = 0
					AND		Program_Lump_Sum_Distributor.Program_ID = #arguments.programId#
				)
		</cfquery>
		<cfif qGetLumpSumDistributors.recordCount>
			<cfset bAnyLumpSumWithoutDistributor = 1 />
		</cfif>
		
		<cfreturn bAnyLumpSumWithoutDistributor />
		
	</cffunction>
	
	<cffunction name="anyDistributorWithoutLumpSum" returntype="boolean" output="false">
		<cfargument name="programId" type="numeric" required="true" />
		
		<cfset bAnyDistributorWithoutLumpSum = 0 />
		<cfquery name="qAnyDistributorWithoutLumpSum" datasource="#application.datasource#">
			SELECT  Contract_Distributors.BSA_Foodservice_Customers_ID
			FROM	Contract_Distributors					
			WHERE   Contract_Distributors.Deleted = 0
			AND 	Contract_Distributors.Contract_Main_ID = #arguments.programId#
			AND		Contract_Distributors.BSA_Foodservice_Customers_ID NOT IN
				(
					SELECT	DISTINCT Distributor_ID
					FROM	Program_Lump_Sum_Distributor
					WHERE	Program_Lump_Sum_Distributor.Deleted = 0
					AND		Program_Lump_Sum_Distributor.Program_ID = #arguments.programId#
				)
		</cfquery>
		<cfif qAnyDistributorWithoutLumpSum.recordCount>
			<cfset bAnyDistributorWithoutLumpSum = 1 />
		</cfif>
		
		<cfreturn bAnyDistributorWithoutLumpSum />
		
	</cffunction>
	
	
	<cffunction name="getLumpSumProgramID" returntype="numeric" output="false">
		<cfargument name="lumpsumId" type="string" required="false" default="" />
		
		<cfset useLakebaseForqGetLumpSumProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sums")>
<cfif useLakebaseForqGetLumpSumProgramID>
	<cftry>
		<cfset qGetLumpSumProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sums", {
				"program_lump_sum_id" = "eq.#arguments.lumpsumId#",
				"select" = "program_id"
			}), "program_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLumpSumProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLumpSumProgramID>
<cfquery name="qGetLumpSumProgramID" datasource="#application.datasource#">
			SELECT  Program_Lump_Sums.Program_ID					
			FROM	Program_Lump_Sums					
			WHERE   Program_Lump_Sums.Program_Lump_Sum_ID = '#arguments.lumpsumId#'
		</cfquery>
</cfif>
		
		<cfreturn qGetLumpSumProgramID.Program_ID />
		
	</cffunction>

	<!--- Dev Note: KAL; 11/2/2010; D25120: Duplicate / No items per LS component  --->
	<cffunction name="getLumpSumComponentWithoutItems" returntype="numeric" output="false">
		<cfargument name="programId" type="numeric" required="true" />
		
		<cfquery name="qGetLumpSumComponentWithoutItems" datasource="#application.datasource#" result="qWithoutItems">
			SELECT		Program_Lump_Sums.Program_Lump_Sum_ID, 
						Contract_Products.Bsa_Foodservice_Items_Master_ID, 
						Count(Contract_Products.Bsa_Foodservice_Items_Master_ID) as Item_Count
			FROM		Program_Lump_Sums
			LEFT JOIN	Program_Lump_Sum_Product_Data
				ON		Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
				AND		Program_Lump_Sum_Product_Data.Deleted = 0
				AND		Program_Lump_Sum_Product_Data.Captured_From_Group = 0
			LEFT JOIN	Contract_Products
				ON		Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
				AND		Contract_Products.Deleted = 0
			WHERE		Program_Lump_Sums.Deleted = 0
			AND			Program_Lump_Sums.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			GROUP BY	Program_Lump_Sums.Program_Lump_Sum_ID, Contract_Products.Bsa_Foodservice_Items_Master_ID
			HAVING		Count(Contract_Products.Bsa_Foodservice_Items_Master_ID) = 0
			ORDER BY	Item_Count DESC			
		</cfquery>

		<!---<cfreturn qGetLumpSumComponentWithoutItems.recordcount >--->
		<cfreturn qWithoutItems.recordcount>
		
	</cffunction>

	
	<cffunction name="getLumpSumComponentRepeatedItems" returntype="numeric" output="false">
		<cfargument name="programId" type="numeric" required="true" />
	
		<cfquery name="qGetLumpSumComponentRepeatedItems" datasource="#application.datasource#" result="qRepeatedItems">
			SELECT		Program_Lump_Sums.Program_Lump_Sum_ID, 
						Contract_Products.Bsa_Foodservice_Items_Master_ID, 
						Count(Contract_Products.Bsa_Foodservice_Items_Master_ID) as Item_Count
			FROM		Program_Lump_Sums
			LEFT JOIN	Program_Lump_Sum_Product_Data
				ON		Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID = Program_Lump_Sums.Program_Lump_Sum_ID
				AND		Program_Lump_Sum_Product_Data.Deleted = 0
				AND		Program_Lump_Sum_Product_Data.Captured_From_Group = 0
			LEFT JOIN	Contract_Products
				ON		Contract_Products.Contract_Products_ID = Program_Lump_Sum_Product_Data.Contract_Products_ID
				AND		Contract_Products.Deleted = 0
			WHERE		Program_Lump_Sums.Deleted = 0
			AND			Program_Lump_Sums.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
			GROUP BY	Program_Lump_Sums.Program_Lump_Sum_ID, Contract_Products.Bsa_Foodservice_Items_Master_ID
			HAVING		Count(BSA_Foodservice_Items_Master_ID) > 1
			ORDER BY	Item_Count DESC			
		</cfquery>

		<!---<cfreturn qGetLumpSumComponentRepeatedItems.recordcount>--->
		<cfreturn qRepeatedItems.recordcount>
		
	</cffunction>
	<!--- End Note: KAL; 11/2/2010; D25120: Duplicate / No items per LS component  --->
</cfcomponent>