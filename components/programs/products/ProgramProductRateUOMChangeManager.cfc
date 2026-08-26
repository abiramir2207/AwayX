<cfcomponent hint="Program Product Rate UOM Change Manager" extends="components.Base">
	
	<cfset arUOM = ArrayNew(1) />

	<cffunction name="init" output="false" returntype="components.programs.products.ProgramProductRateUOMChangeManager">
		
		<cfreturn this />
		
	</cffunction>
	

	<cffunction name="checkUOMChanged" output="false" returntype="boolean">
		<cfargument name="programId" type="numeric" required="true" />		
		
		<cfset returnValue = 0 />
		
		<cfquery name="qGetRateUOMChangeEntries" datasource="#application.datasource#">
			SELECT TOP 1 *
			FROM	Program_Product_Rate_UOM_Change
			WHERE	Program_Product_Rate_UOM_Change.Deleted = 0
			AND		Program_Product_Rate_UOM_Change.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfif qGetRateUOMChangeEntries.recordCount>
			<cfset returnValue = 1 />
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="getRateUOMChanges" output="false" returntype="query">
		<cfargument name="programId" type="numeric" required="true" />		
		
		<cfquery name="qGetRateUOMChanges" datasource="#application.datasource#">
			SELECT 	Program_Product_Rate_UOM_Change.*,
					BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description,
					Discount_Type.Discount_Type_Desc
					
			FROM	Program_Product_Rate_UOM_Change
			
			INNER JOIN Contract_Products
			ON	Contract_Products.Deleted = 0
			AND	Contract_Products.Contract_Products_ID = Program_Product_Rate_UOM_Change.Contract_Products_ID
			
			INNER JOIN BSA_Foodservice_Items_Master
			ON	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
			
			INNER JOIN Discount_Type
			ON	Discount_Type.Discount_Type_ID = Program_Product_Rate_UOM_Change.Discount_Type_ID
			
			WHERE	Program_Product_Rate_UOM_Change.Deleted = 0
			AND		Program_Product_Rate_UOM_Change.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER">
			
			ORDER BY Discount_Type.Discount_Type_Desc, BSA_Foodservice_Items_Master.Item, Program_Product_Rate_UOM_Change.Created_Date, Program_Product_Rate_UOM_Change.Tier_Number
		</cfquery>
		
		<cfreturn qGetRateUOMChanges />
		
	</cffunction>
	
	<cffunction name="getUOMDesc" output="false" returntype="string">	
		<cfargument name="uomId" type="numeric" required="true" />

		<cfif ArrayLen(arUOM) EQ 0>
			<cfset arUOM = getUOMArray() />
		</cfif>
		
		<cfset returnValue = "" />
		<cfif (arguments.uomId EQ 1 OR arguments.uomId EQ 2)><!------ Right now we only handle 1 and 2 (CS/LB) ----->
			<cfset returnValue = arUOM[arguments.uomId] />			
		</cfif>		
	
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="getUOMArray" output="false" returntype="array">	
		
		<cfset var arUOM = arrayNew(1) />
		
		<cfset useLakebaseForqGetUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForqGetUOM>
	<cftry>
		<cfset qGetUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"select" = "unit_of_measure_id,unit_of_measure_desc,abbreviation"
			}), "unit_of_measure_id,unit_of_measure_desc,abbreviation"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetUOM>
<cfquery name="qGetUOM" datasource="#application.datasource#">
			SELECT	Unit_of_Measure_ID, Unit_Of_Measure_Desc, Abbreviation
			FROM	Units_of_Measure			
		</cfquery>
</cfif>
		
		<cfloop query="qGetUOM">
			<cfset arUOM[ArrayLen(arUOM) + 1] = Left(Abbreviation, 2) />
		</cfloop>
					
		<cfreturn arUOM />		
	</cffunction>
	
</cfcomponent>