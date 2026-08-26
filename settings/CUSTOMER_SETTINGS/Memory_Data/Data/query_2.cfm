<cfoutput><cfoutput>
SELECT DISTINCT
		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Description, 
		BSA_Foodservice_Items_Master.UPC, BSA_Foodservice_Items_Master.Item, Type_Code_Desc.Type_Code_Desc, 
		Brand.Brand_Name, Product_Q_Brand_Desc.Q_Brand_ID, Type_Group_Desc.Type_Group_Desc
FROM         
		BSA_Foodservice_Items_Master 
		INNER JOIN Line_Of_Business
		ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID
		INNER JOIN	Type_Code_Desc 
		ON BSA_Foodservice_Items_Master.Type_Code_Desc_ID = Type_Code_Desc.Type_Code_Desc_ID 
		INNER JOIN	Brand 
		ON BSA_Foodservice_Items_Master.Brand_ID = Brand.Brand_ID 
		INNER JOIN	Product_Q_Brand_Desc 
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
		AND Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business
		INNER JOIN	Type_Group_Desc 
		ON BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
	<CFIF len(FORM.Program_ID) GT 0>
		INNER JOIN	Contract_Products 
		ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
	</CFIF>					  			  
WHERE
		0=0 
		AND BSA_Foodservice_Items_Master.Deleted = 0
	<CFIF len(FORM.Program_ID) GT 0>
		AND Contract_Products.Contract_Main_ID IN(#Form.Program_ID#)
		AND Contract_Products.Deleted = 0
		AND 
			( -- start and
				(--start Product_Type_ID = 1
					dbo.Contract_Products.Product_Type_ID = 1 
					AND
					exists(
						SELECT Program_Fixed_Price_Product_Data_ID
						FROM Program_Fixed_Price_Product_Data
						WHERE len(Fixed_Price_Value) > 0 AND len(Volume) > 0 AND Deleted = 0 AND Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					)
				
				)--end Product_Type_ID = 1
				
				OR
				
				(--start Product_Type_ID = 2
					dbo.Contract_Products.Product_Type_ID = 2 
					AND
					exists(
						SELECT Program_Rebates_Product_Data_ID
						FROM Program_Rebates_Product_Data
						WHERE len(Rebate_Value) > 0 AND len(Volume) > 0 AND Deleted = 0 AND Program_Rebates_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
					)
				
				)--end Product_Type_ID = 2
				
				OR
				
				(--start Product_Type_ID = 4
					dbo.Contract_Products.Product_Type_ID = 4
					AND
					exists(
						SELECT     dbo.Program_Growth_Component_Product_Data.Contract_Products_ID
						FROM       dbo.Program_Growth_Component_Product_Data INNER JOIN
						                      dbo.Program_Growth_Components ON 
						                      dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_ID = dbo.Program_Growth_Components.Program_Growth_Component_ID
						                       INNER JOIN
						                      dbo.Program_Growth_Component_Tiers ON 
						                      dbo.Program_Growth_Components.Program_Growth_Component_ID = dbo.Program_Growth_Component_Tiers.Program_Growth_Component_ID INNER JOIN
						                      dbo.Program_Growth_Component_Product_Tier_Data ON 
						                      dbo.Program_Growth_Component_Tiers.Program_Growth_Component_Tier_ID = dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Tier_ID
						                       AND 
						                      dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_Product_Data_ID = dbo.Program_Growth_Component_Product_Tier_Data.Program_Growth_Component_Product_Data_ID
						WHERE     (dbo.Program_Growth_Components.Deleted = 0) AND (dbo.Program_Growth_Component_Tiers.Tier_Number = N'1') AND 
						                      (dbo.Program_Growth_Component_Tiers.Deleted = 0) AND (dbo.Program_Growth_Component_Product_Tier_Data.Deleted = 0) AND 
						                      (dbo.Program_Growth_Component_Product_Data.Deleted = 0) AND (dbo.Program_Growth_Components.Deleted = 0) AND 
						                      (LEN(dbo.Program_Growth_Component_Product_Data.Weekly_Volume) > 0) AND (LEN(dbo.Program_Growth_Component_Product_Tier_Data.Rate) > 0)
											   AND Program_Growth_Component_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
  					)
				
				)--end Product_Type_ID = 4

				OR
				
				(--start Product_Type_ID = 5
					dbo.Contract_Products.Product_Type_ID = 5 
					AND
					exists(
						SELECT Program_Formula_Pricing_Rule_Product_ID
						FROM Program_Formula_Pricing_Rule_Products
						WHERE len(Price) > 0 AND len(Weekly_Volume) > 0 AND Deleted = 0 AND Program_Formula_Pricing_Rule_Products.Contract_Product_ID = Contract_Products.Contract_Products_ID
					)
				)--end Product_Type_ID = 5

			)-- end			
	</CFIF>
		
	<!--- type group --->
	<CFIF FORM.Type_Group_Desc_ID NEQ 0>
		AND BSA_Foodservice_Items_Master.Type_Group_Desc_ID = '#FORM.Type_Group_Desc_ID#'
	</CFIF>

	<!--- type code --->
	<CFIF FORM.Type_Code_Desc_ID NEQ 0>
		AND BSA_Foodservice_Items_Master.Type_Code_Desc_ID = '#FORM.Type_Code_Desc_ID#'
	</CFIF>

	<!--- Q_Brand_ID --->
	<CFIF FORM.Q_Brand_ID NEQ 0>
		AND Product_Q_Brand_Desc.Q_Brand_ID = '#FORM.Q_Brand_ID#'
	</CFIF>
	
	<!--- Line_Of_Business --->
	<CFIF len(trim(getLOBCharacter.Line_Of_Business)) GT 0>
		AND Product_Q_Brand_Desc.LOB = '#getLOBCharacter.Line_Of_Business#'
	</CFIF>
	
	<!--- Brand_ID --->
	<CFIF FORM.Brand_ID NEQ 0>
		AND dbo.BSA_Foodservice_Items_Master.Brand_ID = '#FORM.Brand_ID#'
	</CFIF>
		
	<!--- Line Of Business --->
	<CFIF FORM.Line_Of_Biz NEQ 0>
		AND BSA_Foodservice_Items_Master.Line_Of_Business_ID = '#FORM.Line_Of_Biz#'
	</CFIF>

	<!--- Product_Status --->
	<CFIF FORM.Product_Status NEQ 0>
		AND BSA_Foodservice_Items_Master.Active_Code = '#FORM.Product_Status#'
	</CFIF>
		
	<!--- description search --->
	<CFIF len(trim(FORM.Description_String)) NEQ 0>
			AND BSA_Foodservice_Items_Master.Description LIKE '%#preservesinglequotes(FORM.Description_String)#%'
	</CFIF>
		
	<!--- ITEM # search --->
	<CFIF len(trim(FORM.item_number)) NEQ 0>
			AND BSA_Foodservice_Items_Master.Item 	like 	'%#preservesinglequotes(FORM.item_number)#%'
	</CFIF>

	<!--- UPC search --->
	<CFIF len(trim(FORM.upc_number)) NEQ 0>
			AND BSA_Foodservice_Items_Master.UPC 	like 	'%#preservesinglequotes(FORM.upc_number)#%'
	</CFIF>
		
	<cfif isdefined("categoryList")>
		<cfif len(trim(categoryList)) GT 0>
			AND BSA_Foodservice_Items_Master.Category_ID IN(#replace(categoryList, "''", "'", "ALL")#)
		</cfif>
	</cfif>
		
	<CFIF SHOW_INVOICE_FILTER EQ 1>
		<CFPARAM NAME="FORM.Ship_To" DEFAULT="">
		<CFIF ((FORM.Distributor NEQ "0" AND FORM.Distributor NEQ "") OR FORM.Ship_To NEQ "") AND Trim(FORM.Invoice_Days) NEQ "">
			AND
			EXISTS
			(
				SELECT	TOP 1 Invoice_Header.Invoice_Header_ID
				FROM	Invoice_Header
					INNER JOIN Invoice_Detail
					ON
					(
						(Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID)
						AND
						(Invoice_Detail.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID)
						AND
						(Invoice_Detail.Deleted = 0)
					)
					<CFIF FORM.Ship_To NEQ "">
					INNER JOIN BSA_Foodservice_Customers
					ON
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Invoice_Header.BSA_Foodservice_Customers_ID
					AND BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#FORM.Ship_To#%'
					</CFIF>
				WHERE
					<CFIF (FORM.Distributor NEQ "0" AND FORM.Distributor NEQ "")>
					Invoice_Header.BSA_Foodservice_Customers_ID = '#FORM.Distributor#'
					AND
					</CFIF>
					Invoice_Header.Deleted = 0
					AND
					DATEDIFF(d,Invoice_Header.Invoice_Date,GetDate()) <= #FORM.Invoice_Days#
			)
		</CFIF>
	</CFIF>
	<CFIF isdefined("FORM.Rebate_Type_Search_ID")>
		<CFIF FORM.Rebate_Type_Search_ID NEQ 0>
			AND
			<CFIF listlen(trim(List_Of_Rebate_Product_ID)) GT 0>
			
				dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN(#replace(List_Of_Rebate_Product_ID, "#chr(39)##chr(39)#", chr(39), "ALL")#)
			<CFELSE>
				0=1
			</CFIF>
		</CFIF>
	</CFIF>
		
	<cfif isdefined("form.Only_Show_Products_From_These_Groups")>
		<cfif trim(form.Only_Show_Products_From_These_Groups) EQ 666>
			AND 0 = 1
		<cfelse>
			<cfif trim(form.Only_Show_Products_From_These_Groups) NEQ 0>
				AND 
				<cfif application.returned_customer_setting.approval_on_type_code EQ 1>
					dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID
				<cfelse>
					dbo.BSA_Foodservice_Items_Master.Type_Group_Desc_ID
				</cfif>
				IN(#listqualify(form.Only_Show_Products_From_These_Groups, "'")#)
			<cfelse><!--- nothing ---></cfif>			
		</cfif>
	</cfif>
	<cfif isDefined("form.businessSegmentsOn") and isDefined("form.Business_Segment_ID")>
		<cfif form.businessSegmentsOn eq 1 and form.Business_Segment_ID neq 0>
			AND BSA_Foodservice_Items_Master.Business_Segment_ID = #form.Business_Segment_Id#	
		</cfif>
	</cfif>
	<cfif isdefined("sql_Sort_By") AND isdefined("sql_Sort_By_Order")>
		ORDER BY #sql_Sort_By# #sql_Sort_By_Order#
	</cfif>
</cfoutput></cfoutput>
