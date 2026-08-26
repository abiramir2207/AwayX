<!--- getproducts function returns products based on ProgramId and DiscountTypeID  --->
<cfcomponent>

	<cffunction name="getproducts" output="false" returntype="query">

		<cfargument name="ComponentID" type="string" required="false" />
		<cfargument name="DiscountTypeID" type="string" required="false" />
		<cfargument name="ProgramID" type="string" required="false" />

	<cfset qgetproducts = queryNew("")>

		<cfif DiscountTypeID eq 1>

			<cfquery name="qgetproducts" datasource="#application.datasource#">
			SELECT	distinct BSA_Foodservice_Items_Master_ID
				FROM	Contract_Products
					INNER JOIN	dbo.Program_Fixed_Price_Product_Data
					ON
					Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					AND
					Program_Fixed_Price_Product_Data.Deleted = 0
				WHERE
					Contract_Products.Deleted = 0
					AND
					Contract_Products.Contract_Main_ID = '#arguments.ProgramID#'
					AND Contract_Products.product_type_id = '#arguments.DiscountTypeID#'
			</cfquery>

		<cfelseif DiscountTypeID eq 2>

			<cfset Rebateproducts = createObject("component","components.programs.rebates.rebate")>

			<cfset qgetproducts = Rebateproducts.LoadFromDB(arguments.ProgramID)>
			<cfset qgetproducts = arrayOfStructuresToQuery(qgetproducts.aprod)>

		<cfelseif DiscountTypeID EQ 4>
			<!---This query taken from the growth page nearly verbatim --->
			<CFQUERY NAME="qgetproducts" DATASOURCE="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master_ID
			FROM	Contract_Products
					INNER JOIN	Program_Growth_Component_Product_Data ON
					Contract_Products.Contract_Products_ID = Program_Growth_Component_Product_Data.Contract_Products_ID
					AND Program_Growth_Component_Product_Data.Deleted = 0
					<!--- AND Program_Growth_Component_Product_Data.Program_Growth_Component_ID = '#LoadedComponentID#'  (not applicable for here)--->
			WHERE	Contract_Products.Deleted = 0
			AND 	Contract_Products.Contract_Main_ID = '#arguments.ProgramID#'
			AND		Contract_Products.Discounted_Item = 1
			<!---filter on groups if they exist--->
			AND
					(
						<!------ Group ----->
						(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
						OR
						<!------ Product ----->
						(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
					)


		</CFQUERY>

		<!--- This is being used for Off-Invoice and not Fee --->
		<cfelseif DiscountTypeID eq 8>

			<cfset OIproducts = createObject("component","components.programs.Off_Invoice.OffInvoiceDAO")>
			<cfset qgetproducts = OIproducts.getOIProgramProducts(arguments.ProgramID)>


		<cfelseif DiscountTypeID eq 10>

			<cfset bidRequestProductManager = CreateObject("component", "components.programs.bid_request.BidRequestProductManager") />
			<cfset bidRequest = bidRequestProductManager.getBidRequestProductsFromDb(arguments.ProgramID) />
			<cfset qgetproducts = bidRequest.getBidRequestProducts() />
			<cfset qgetproducts = arrayOfStructuresToQuery(qgetproducts) />
		</cfif>


		<cfreturn qgetproducts />

	</cffunction>
<cffunction name="getEZButtonProductList" output="false" returntype="query">
		<cfargument name="ProgramID" type="string" required="false" />
		<cfargument name="DiscountTypeID" type="string" required="false" />
		<cfargument name="ComponentId" type="string" required="false" />
		<cfargument name="isparent" type="boolean" required="false" />
		<cfargument name="isgroup" type="boolean" required="false" />

		<cfif arguments.discounttypeid EQ 3>
		<CFQUERY NAME="qgetEZButtonProductList" DATASOURCE="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master_ID
			FROM	Contract_Products
			INNER JOIN Program_Lump_Sum_Product_Data ON
			Contract_Products.Contract_Products_ID =
			Program_Lump_Sum_Product_Data.Contract_Products_ID
			and Program_Lump_Sum_Product_Data.deleted = 0
			inner join Program_Lump_Sums on
			Program_Lump_Sums.Program_Lump_Sum_Id =
			Program_Lump_Sum_Product_Data.Program_Lump_Sum_Id
			and Program_Lump_Sums.program_id = Contract_Products.contract_main_id
			WHERE	Contract_Products.Deleted = 0
			AND 	Contract_Products.Contract_Main_ID = '#arguments.ProgramID#'
			AND 	product_type_id = 3
			AND 	Program_Lump_Sums.program_lump_sum_name_id = #arguments.ComponentId#
			AND contract_products.is_group = #arguments.isgroup#
		</CFQUERY>
		<cfelseif arguments.discounttypeid EQ 4>
			<!---This query taken from the growth page nearly verbatim --->
			<CFQUERY NAME="qgetEZButtonProductList" DATASOURCE="#application.datasource#">
			SELECT	DISTINCT BSA_Foodservice_Items_Master_ID
			FROM	Contract_Products
			INNER JOIN	Program_Growth_Component_Product_Data ON
			Contract_Products.Contract_Products_ID = 		Program_Growth_Component_Product_Data.Contract_Products_ID
			AND Program_Growth_Component_Product_Data.Deleted = 0
			inner join Program_Growth_Components on
			Program_Growth_Components.Program_Growth_Component_id =
			Program_Growth_Component_Product_Data.Program_Growth_Component_id
			and Program_Growth_Components.program_id =
			Contract_Products.Contract_Main_ID
			WHERE	Contract_Products.Deleted = 0
			AND Contract_Products.product_type_id = 4
			AND 	Contract_Products.Contract_Main_ID = '#arguments.ProgramID#'
			AND contract_products.is_group = #arguments.isgroup#
			<cfif arguments.isparent EQ 1>
			AND		Contract_Products.Discounted_Item = 1
			</cfif>
			AND
			(
			(Contract_Products.Product_Group_ID = CAST(Contract_Products.BSA_Foodservice_Items_Master_ID AS NVARCHAR(50)) AND Contract_Products.Is_Group = 1)
			OR
			(ISNULL(Contract_Products.Product_Group_ID, '') = '' AND Contract_Products.Is_Group = 0)
			)
			AND Program_Growth_Components.Program_Growth_Components_Name_ID = '#arguments.componentid#'
			AND Program_Growth_Components.IsParent = #arguments.isparent#
		</CFQUERY>
		<cfelse>
			<CFQUERY NAME="qgetEZButtonProductList" DATASOURCE="#application.datasource#">
			select DISTINCT BSA_Foodservice_Items_Master_ID
			FROM Contract_Products
			where contract_main_id = '#arguments.ProgramID#'
			and deleted = 0
			AND contract_products.is_group = #arguments.isgroup#
			and product_type_id = #arguments.DiscountTypeID#
			</CFQUERY>
		</cfif>
		<cfreturn qgetEZButtonProductList />
</cffunction>


<cfscript>
/*
 * Converts an array of structures to a CF Query Object.
 * 6-19-02: Minor revision by Rob Brooks-Bilson (rbils@amkor.com)
 *
 * Update to handle empty array passed in. Mod by Nathan Dintenfass. Also no longer using list func.
 *
 * @param Array 	 The array of structures to be converted to a query object.  Assumes each array element contains structure with same  (Required)
 * @return Returns a query object.
 * @author David Crawford (dcrawford@acteksoft.com)
 * @version 2, March 19, 2003
 */

function arrayOfStructuresToQuery(theArray){
	var colNames = "";
	var theQuery = queryNew("");
	var i=0;
	var j=0;
	//if there's nothing in the array, return the empty query
	if(NOT arrayLen(theArray))
		return theQuery;
	//get the column names into an array =
	colNames = structKeyArray(theArray[1]);
	//build the query based on the colNames
	theQuery = queryNew(arrayToList(colNames));
	//add the right number of rows to the query
	queryAddRow(theQuery, arrayLen(theArray));
	//for each element in the array, loop through the columns, populating the query
	for(i=1; i LTE arrayLen(theArray); i=i+1){
		for(j=1; j LTE arrayLen(colNames); j=j+1){
			querySetCell(theQuery, colNames[j], theArray[i][colNames[j]], i);
		}
	}
	return theQuery;
}
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="getQBrands" access="public" returntype="query" output="false">
  <cfargument name="brand_id" required="false">

  <cfquery name="local.query" datasource="#application.datasource#">
    SELECT DISTINCT b.q_Brand, b.q_Brand_Id
      FROM BSA_FOODSERVICE_ITEMS_MASTER a
           INNER JOIN Q_BRAND_DESC b ON a.q_Brand_Id = b.q_Brand_Id
                                    AND b.Deleted = 0
                                    AND a.Deleted = 0
     WHERE a.Item IS NOT NULL
      ORDER BY B.Q_Brand
  </cfquery>

  <cfreturn local.query>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="getBrands" access="public" returntype="query" output="false">
  <cfargument name="brand_id" required="false">

  <cfquery name="local.query" datasource="#application.datasource#">
    SELECT DISTINCT b.Brand_Name, b.Brand_Id
      FROM BSA_FOODSERVICE_ITEMS_MASTER a
           INNER JOIN BRAND b ON a.Brand_Id = b.Brand_Id
                             AND b.Deleted = 0
                             AND a.Deleted = 0
     WHERE a.Item IS NOT NULL
      ORDER BY b.Brand_Name
  </cfquery>

  <cfreturn local.query>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="saveProductCosts" access="public" output="true">
  <cfargument name="products" required="true">   <!--- data entry form structure with only 'changed' elements --->

  <cfloop collection="#arguments.products#" item="local.formElement">
  	<cfif local.formElement contains 'cost_'>
  		<cfscript>
	  		local.BSA_Foodservice_Items_Master_ID = right(local.formElement, len(local.formElement) - 5);
	  		local.uom                             = arguments.products[ 'uom_' & local.BSA_Foodservice_Items_Master_ID ];
	  		local.cost                            = replace( arguments.products[ local.formElement ], ',', '', 'all' );
  		</cfscript>

		  <cfif local.uom eq 'cs'>
			  <cfquery name="local.query" datasource="#application.datasource#">
			  	UPDATE BSA_FOODSERVICE_ITEMS_MASTER
			  	   SET CS_Curr_cost = '#local.cost#'
			  	       ,Curr_cost = CAST( CAST('#local.cost#' AS FLOAT) / CAST(Net_Weight AS FLOAT) AS NVARCHAR(50) )
			  	WHERE BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#local.BSA_Foodservice_Items_Master_ID#" cfsqltype="cf_sql_char">
			  </cfquery>
		  <cfelseif local.uom eq 'lb'>
			  <cfquery name="local.query" datasource="#application.datasource#">
			  	UPDATE BSA_FOODSERVICE_ITEMS_MASTER
			  	   SET Curr_cost = '#local.cost#'
			  	       ,Cs_Curr_cost = CAST( CAST('#local.cost#' AS FLOAT) * CAST(Net_Weight AS FLOAT) AS NVARCHAR(50) )
			  	WHERE BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#local.BSA_Foodservice_Items_Master_ID#" cfsqltype="cf_sql_char">
			  </cfquery>
		  </cfif>
  	</cfif>
  </cfloop>

</cffunction>


</cfcomponent>