<cfcomponent hint="This class is only used for database access. It holds all the queries for Program Lump Sums" extends="components.programs.Program">

	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getProgramLumpSumProducts" output="false" returntype="query">
	
		<cfargument name="lumpSumId" required="false" default="" />
		<cfargument name="programId" required="false" default="" />
		
		<!---call function that get's lump sum products--->
		<cfquery name="getLumpSumProducts" datasource="#application.datasource#">
			SELECT 	* 
			FROM 	fn_GetLumpSumProducts(#arguments.programId#, '#arguments.lumpSumId#')
		</cfquery>
	
		<cfreturn getLumpSumProducts />
		
	</cffunction>
	
	<cffunction name="getExcludedProgramLumpSumProducts" output="false" returntype="query">
		<cfargument name="LSCompId" required="false" default="" />
		<cfargument name="programId" required="false" default="" />

		<cfquery name="qGetExcludedProgramLumpSumProducts" datasource="#application.datasource#">
			select distinct BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
			from program_lump_sums
			inner join Program_Lump_Sum_Product_Data
				on program_lump_sums.Program_Lump_Sum_ID = Program_Lump_Sum_Product_Data.Program_Lump_Sum_ID
				and Program_Lump_Sum_Product_Data.deleted = 0
			inner join contract_products
				on contract_products.contract_products_id = Program_Lump_Sum_Product_Data.contract_products_id
				and contract_products.deleted = 0
				
			inner join BSA_Foodservice_Items_Master
				on BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = contract_products.BSA_Foodservice_Items_Master_ID
			where program_lump_sums.deleted = 0 
			and program_lump_sums.program_id =  '#arguments.programId#'
			<cfif arguments.LSCompId neq 0 and arguments.LSCompId neq "">
				and program_lump_sums.Program_Lump_Sum_ID not in ('#arguments.LSCompId#')
			</cfif>
			and (
					contract_products.is_group = 1 
					or
					(
						contract_products.is_group = 0
						and product_group_id = ''
					)
				)
		</cfquery>
		<cfreturn qGetExcludedProgramLumpSumProducts />
	</cffunction>
	
	
	
</cfcomponent>