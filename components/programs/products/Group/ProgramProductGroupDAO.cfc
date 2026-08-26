<!--- ProgramProductGroupDAO.cfc --->
<cfcomponent>


	<cffunction name="bDiscountTypeHasGroups" output="false" returntype="boolean">
		
		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="discountTypeId" required="true" type="numeric">
		
		<cfset var discountHasGroup = 0 />
		
		<CFQUERY NAME="qGetGroupProductForDiscountType" datasource="#application.datasource#">
			
			SELECT 	TOP 1 Contract_Products.Contract_Main_ID
			FROM	Contract_Products
			WHERE	Contract_Products.Contract_Main_ID = #arguments.programId#
			AND		Contract_Products.Deleted = 0
			AND		Product_Type_ID = #arguments.discountTypeId#
			AND		Contract_Products.Is_Group = 1

		</CFQUERY>
		
		<cfif qGetGroupProductForDiscountType.RecordCount>
			<cfset discountHasGroup = 1 />
		</cfif>
		
		<cfreturn discountHasGroup />
		
	</cffunction>

</cfcomponent>