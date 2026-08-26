<!--- QUERIES TO GET DATA --->
<CFPARAM NAME="Program_ID_To_Replicate" DEFAULT="0">

	<!--- Basic Information - Contract_Main --->
	<cfset useLakebaseForgetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetContractInfo>
	<cftry>
		<cfset getContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Program_ID_To_Replicate#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractInfo>
<CFQUERY NAME="getContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#Program_ID_To_Replicate#'
	</CFQUERY>
</cfif>
	
	<!--- contract_operators --->
	<cfset useLakebaseForgetContractOperators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_operators")>
<cfif useLakebaseForgetContractOperators>
	<cftry>
		<cfset getContractOperators = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_operators", {
				"contract_main_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractOperators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractOperators>
<CFQUERY NAME="getContractOperators" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Operators
		WHERE Contract_Main_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
	</CFQUERY>
</cfif>

	<!--- contract_brokers --->
	<cfset useLakebaseForgetContractBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_brokers")>
<cfif useLakebaseForgetContractBrokers>
	<cftry>
		<cfset getContractBrokers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_brokers", {
				"contract_main_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractBrokers>
<CFQUERY NAME="getContractBrokers" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Brokers
		WHERE Contract_Main_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
	</CFQUERY>
</cfif>
	
	<!--- contract_Distributors --->
	<cfset useLakebaseForgetContractDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForgetContractDistributors>
	<cftry>
		<cfset getContractDistributors = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractDistributors>
<CFQUERY NAME="getContractDistributors" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Distributors
		WHERE Contract_Main_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
	</CFQUERY>
</cfif>	

	<!--- contract_products --->
	<cfset useLakebaseForgetContract_Products = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForgetContract_Products>
	<cftry>
		<cfset getContract_Products = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"contract_main_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContract_Products = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContract_Products>
<CFQUERY NAME="getContract_Products" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Products
		WHERE Contract_Main_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
	</CFQUERY>
</cfif>
	<CFSET ListOfProductIDs = valuelist(getContract_Products.Contract_Products_ID)>
	<CFIF Listlen(ListOfProductIDs) EQ 0><CFSET ListOfProductIDs = 0></CFIF>
	
	<!--- FIXED PRICE PRODUCTS --->
	<CFQUERY NAME="get_Fixed_Price_Products" datasource="#application.datasource#">
		SELECT *
		FROM Program_Fixed_Price_Product_Data
		WHERE Contract_products_ID IN(#ListOfProductIDs#) AND Deleted = 0
	</CFQUERY>

	<!--- REBATE PRODUCTS --->
	<CFQUERY NAME="get_Rebate_Products" datasource="#application.datasource#">
		SELECT *
		FROM Program_Rebates_Product_Data
		WHERE Contract_products_ID IN(#ListOfProductIDs#) AND Deleted = 0
	</CFQUERY>	

	<!--- lumpsum components --->
	<cfset useLakebaseForget_Lump_Sum_Components = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sums")>
<cfif useLakebaseForget_Lump_Sum_Components>
	<cftry>
		<cfset get_Lump_Sum_Components = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sums", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_Lump_Sum_Components = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_Lump_Sum_Components>
<CFQUERY NAME="get_Lump_Sum_Components" datasource="#application.datasource#">
		SELECT *
		FROM Program_Lump_Sums
		WHERE Program_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
	</CFQUERY>
</cfif>

	<!--- lumpsum component Products --->
	<CFQUERY NAME="get_Lump_Sum_Component_Products" datasource="#application.datasource#">
		SELECT *
		FROM Program_Lump_Sum_Product_Data
		WHERE Contract_Products_ID IN(#ListOfProductIDs#) AND Deleted = 0
	</CFQUERY>	
	
	<!--- Growth Components --->
	<cfset useLakebaseForget_Growth_Components = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
<cfif useLakebaseForget_Growth_Components>
	<cftry>
		<cfset get_Growth_Components = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_components", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_Growth_Components = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_Growth_Components>
<CFQUERY NAME="get_Growth_Components" datasource="#application.datasource#">
		SELECT *
		FROM Program_Growth_Components
		WHERE Program_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
	</CFQUERY>
</cfif>

	<!--- Growth Components Tiers--->
	<cfset useLakebaseForget_Growth_Component_Tiers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_component_tiers")>
<cfif useLakebaseForget_Growth_Component_Tiers>
	<cftry>
		<cfset get_Growth_Component_Tiers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_growth_component_tiers", {
				"program_id" = "eq.#Program_ID_To_Replicate#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_Growth_Component_Tiers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_Growth_Component_Tiers>
<CFQUERY NAME="get_Growth_Component_Tiers" datasource="#application.datasource#">
		SELECT *
		FROM Program_Growth_Component_Tiers
		WHERE Program_ID = '#Program_ID_To_Replicate#' AND Deleted = 0
	</CFQUERY>
</cfif>
	
	<!--- Growth Components Tier Products--->
	<CFQUERY NAME="get_Growth_Component_Tier_Products" datasource="#application.datasource#">
		SELECT *
		FROM Program_Growth_Component_Product_Data
		WHERE Contract_Products_ID IN(#ListOfProductIDs#) AND Deleted = 0
	</CFQUERY>
	<CFSET ListOfProductDataIDS = valuelist(get_Growth_Component_Tier_Products.Program_Growth_Component_Product_Data_ID)>
	<CFIF Listlen(ListOfProductDataIDS) EQ 0><CFSET ListOfProductDataIDS = 0></CFIF>
	<!--- Growth Components Tier Product Data--->
	<CFQUERY NAME="get_Growth_Component_Tier_Product_Tier_Data" datasource="#application.datasource#">
		SELECT *
		FROM Program_Growth_Component_Product_Tier_Data
		WHERE Program_Growth_Component_Product_Data_ID IN(#ListOfProductDataIDS#) AND Deleted = 0
	</CFQUERY>	
	
<!--- BuildStruct --->
	<CFSET Program = StructNew()>

	<!--- Contract_Main --->
	<CFSET Program.Basic_Information = StructNew()>
	
	<CFOUTPUT QUERY="getContractInfo">
		<CFLOOP INDEX="Contract_Main_Column_List" LIST="#getContractInfo.ColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("getContractInfo.#Contract_Main_Column_List#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "Program.Basic_Information.#Contract_Main_Column_List#" = ThisRowAndColumnData>
		</CFLOOP>
	</CFOUTPUT>

	<!--- contract_operators --->
	<CFSET NewStructLevelName = "Program.Operators">
	<CFSET MasterQuery = "getContractOperators">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>
	<CFSET ThisStructure.Master_Table = "Contract_Operators">
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>

	<!--- contract_brokers --->
	<CFSET NewStructLevelName = "Program.Brokers">
	<CFSET MasterQuery = "getContractBrokers">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Contract_Brokers">	
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>	
	
	<!--- contract_Distributors--->
	<CFSET NewStructLevelName = "Program.Distributors">
	<CFSET MasterQuery = "getContractDistributors">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Contract_Distributors">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>		

	<!--- Contract_Products --->
	<CFSET NewStructLevelName = "Program.Products">
	<CFSET MasterQuery = "getContract_Products">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Contract_Products">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>		

	<!--- Fixed price products --->
	<CFSET NewStructLevelName = "Program.Products.Fixed_Price_Products">
	<CFSET MasterQuery = "get_Fixed_Price_Products">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Program_Fixed_Price_Product_Data">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>	

	<!--- REBATE products --->
	<CFSET NewStructLevelName = "Program.Products.Rebate_Products">
	<CFSET MasterQuery = "get_Rebate_Products">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Program_Rebates_Product_Data">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>		

	<!--- lump sum component --->
	<CFSET NewStructLevelName = "Program.Lump_Sum_Components">
	<CFSET MasterQuery = "get_Lump_SUm_Components">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Program_Lump_Sums">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>
	
	<!--- lump sum component products --->
	<CFSET NewStructLevelName = "Program.Lump_Sum_Components.Products">
	<CFSET MasterQuery = "get_Lump_Sum_Component_Products">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Program_Lump_Sum_Product_Data">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>			

	<!--- growth components --->
	<CFSET NewStructLevelName = "Program.Growth_Components">
	<CFSET MasterQuery = "get_Growth_Components">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Program_Growth_Components">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>	

	<!--- growth component tiers --->
	<CFSET NewStructLevelName = "Program.Growth_Components.Tiers">
	<CFSET MasterQuery = "get_Growth_Component_Tiers">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Program_Growth_Component_Tiers">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>		
	
	<!--- growth component tier products --->
	<CFSET NewStructLevelName = "Program.Growth_Components.Tiers.Tier_Products">
	<CFSET MasterQuery = "get_Growth_Component_Tier_Products">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Program_Growth_Component_Product_Data">		
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>

	<!--- growth component tier product tier data --->
	<CFSET NewStructLevelName = "Program.Growth_Components.Tiers.Tier_Products.Product_Tier_Data">
	<CFSET MasterQuery = "get_Growth_Component_Tier_Product_Tier_Data">

	<CFSET "#NewStructLevelName#" = StructNew()>
	<CFSET ThisStructure = evaluate(NewStructLevelName)>
	<CFSET theColumnList = evaluate("#MasterQuery#.columnlist")>
	
	<CFSET ThisStructure.Recordcount = evaluate("#MasterQuery#.recordcount")>
	<CFSET ThisStructure.ColumnList = theColumnList>	
	<CFSET ThisStructure.Master_Table = "Program_Growth_Component_Product_Tier_Data">
	<CFSET IndexCounter = 1>
	<CFOUTPUT QUERY="#MasterQuery#">
		<CFLOOP INDEX="Master_Query_Column" LIST="#theColumnList#">
			<CFSET ThisRowAndColumnData = evaluate("#MasterQuery#.#Master_Query_Column#")>
			<CFIF len(trim(ThisRowAndColumnData)) EQ 0>
				<CFSET ThisRowAndColumnData = "NULL">
			</CFIF>
			<CFSET "ThisStructure.#Master_Query_Column#_#IndexCounter#" = ThisRowAndColumnData>
		</CFLOOP>
	<CFSET IndexCounter = IndexCounter + 1>
	</CFOUTPUT>	

