<!--- ProgramProductGroupDAO.cfc --->
<cfcomponent>


	<cffunction name="bDiscountTypeHasGroups" output="false" returntype="boolean">
		
		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="discountTypeId" required="true" type="numeric">
		
		<cfset var discountHasGroup = 0 />
		
		<cfset useLakebaseForqGetGroupProductForDiscountType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqGetGroupProductForDiscountType>
	<cftry>
		<cfset qGetGroupProductForDiscountType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#arguments.programId#",
				"deleted" = "eq.0",
				"product_type_id" = "eq.#arguments.discountTypeId#",
				"is_group" = "eq.1",
				"limit" = "1",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGroupProductForDiscountType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGroupProductForDiscountType>
<CFQUERY NAME="qGetGroupProductForDiscountType" datasource="#application.datasource#">
			
			SELECT 	TOP 1 Contract_Products.Contract_Main_ID
			FROM	Contract_Products
			WHERE	Contract_Products.Contract_Main_ID = #arguments.programId#
			AND		Contract_Products.Deleted = 0
			AND		Product_Type_ID = #arguments.discountTypeId#
			AND		Contract_Products.Is_Group = 1

		</CFQUERY>
</cfif>
		
		<cfif qGetGroupProductForDiscountType.RecordCount>
			<cfset discountHasGroup = 1 />
		</cfif>
		
		<cfreturn discountHasGroup />
		
	</cffunction>

</cfcomponent>