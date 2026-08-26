<!----
	Filename:	C:\Work\Code\base\AwayX\components\Deduction\Non_Trade.cfc
	Created:	12/21/2011
 	Developer:	drachala        
	Copyright (c) 2006 Blacksmith Applications, Inc.       
             
	Description:
		This file is used for NON TRADE DEDUCTION CLOSRE TYPE to pull items based on deduction ID
		UPDATE DD_Non_Trade_Product, deduction tables to close deduction
---->
<cfcomponent>

   	<cffunction name="ItemsForNonTrade" output="false" returntype="query">	
  	 <cfargument name="Customer_ID" required="true">
      <cfquery name="qGetItemsInfo" datasource="#application.datasource#">
        select	tbl180.cases_invoiced, tbl180.Pounds_invoiced, tbl180.sales_dollar , i.Description, i.item, i.BSA_Foodservice_Items_Master_ID
		from	Deductions d
		inner join BSA_Foodservice_Customers c
		on	(c.BSA_Foodservice_Customers_ID = d.Distributor_ID)
		or	(d.Distributor_ID is null and c.Distributor_Bill_To_ID = d.Distributor_Bill_To_ID)
		inner join Product_Customer_Group tbl180
		on	tbl180.Customer_ID = c.BSA_Foodservice_Customers_ID
		inner join BSA_Foodservice_Items_Master i
		on i.BSA_Foodservice_Items_Master_ID = tbl180.product_id
		where	d.Deduction_ID = <cfqueryparam value="#arguments.Customer_ID#" cfsqltype="CF_SQL_VARCHAR">
		Order by tbl180.sales_dollar
      </cfquery>
      <cfreturn qGetItemsInfo />
  </cffunction>  
 <!---  D34163 : Deduction - unable to close START --->
   	<cffunction name="ItemsFromDDNonTradeproduct" output="false" returntype="query">	
  	 <cfargument name="Customer_ID" required="true">
      <cfquery name="qGetItemsInfo" datasource="#application.datasource#">
        select	isnull(tbl180.cases_invoiced,0) AS cases_invoiced, isnull(tbl180.Pounds_invoiced,0) AS Pounds_invoiced, isnull(tbl180.sales_dollar,0) AS sales_dollar, i.Description, i.item, i.BSA_Foodservice_Items_Master_ID
		from	Deductions d
		inner join BSA_Foodservice_Customers c
		on	(c.BSA_Foodservice_Customers_ID = d.Distributor_ID)
		or	(d.Distributor_ID is null and c.Distributor_Bill_To_ID = d.Distributor_Bill_To_ID)
		inner join DD_Non_Trade_product
		on DD_Non_Trade_product.Deduction_ID = d.Deduction_ID
		left join Product_Customer_Group tbl180
		on	tbl180.Customer_ID = c.BSA_Foodservice_Customers_ID
		<!--- and tbl180.Customer_ID = d.Distributor_ID D39016 :: Non-Trade Closed Deductions--->
		and tbl180.Product_ID = DD_Non_Trade_product.BSA_Foodservice_Items_Master_ID<!--- D39016 :: Non-Trade Closed Deductions --->
		inner join BSA_Foodservice_Items_Master i
		on i.BSA_Foodservice_Items_Master_ID = DD_Non_Trade_product.BSA_Foodservice_Items_Master_ID
		where	d.Deduction_ID = <cfqueryparam value="#arguments.Customer_ID#" cfsqltype="CF_SQL_VARCHAR">
		Order by tbl180.sales_dollar
      </cfquery>
      <cfreturn qGetItemsInfo />
  </cffunction> 
  <!---  D34163 : Deduction - unable to close END --->
   	<cffunction name="InvoicesForNonTrade" output="false" returntype="query">	
  	 <cfargument name="Invoice" required="true">
	<cfargument name="deduction_id" type="string" required="true" ><!--- D39095 :: Deduction Filtering  --->
      <cfquery name="qItemsInfo" datasource="#application.datasource#">
			select	distinct Invoice_Header.Invoice_Header_ID, 
					Invoice_Header.Shared_Invoice_Number, 
					BSA_Foodservice_Customers.Shr_Ship_To, 
					BSA_Foodservice_Customers.Name
			from	Invoice_Header
			<!--- D39095 :: Deduction Filtering START --->
			inner join	Deductions d
			on d.Deduction_ID = '#arguments.deduction_id#'
			<!---  D39095 :: Deduction Filtering END --->
			
			Inner join BSA_Foodservice_Customers
			on	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Invoice_Header.BSA_Foodservice_Customers_ID
           
		 	<!--- D39095 :: Deduction Filtering START  --->
			and ((BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = d.Distributor_ID)
			or	(d.Distributor_ID is null and BSA_Foodservice_Customers.Distributor_Bill_To_ID = d.Distributor_Bill_To_ID))
			<!--- D39095 :: Deduction Filtering END  --->
			inner join Invoice_Detail
			on Invoice_Header.Invoice_Header_ID = Invoice_Detail.Invoice_Header_ID
			where	Shared_Invoice_Number like '%#arguments.Invoice#%'
			and		Invoice_Header.Deleted = 0
			and 	Invoice_Detail.Fob_Price_Ind in('y','n')
	</cfquery>
    <cfreturn qItemsInfo />
   </cffunction>
   
   	<cffunction name="InvoicesItems" output="false" returntype="query">	
  	  <cfargument name="Invoice_ID" required="true">
      <cfquery name="ItemsInfo" datasource="#application.datasource#">   
   		select	i.Description, i.item, i.BSA_Foodservice_Items_Master_ID, 
		sum(cast(Invoice_Detail.cases_invoiced as float)) as cases_invoiced, 
		sum(cast(Invoice_Detail.Pounds_invoiced as float)) as Pounds_invoiced, 
		sum(cast(Invoice_Detail.sales_dollars as float)) as sales_dollar <!--- D30423 All  Apply the filter(Fob_Price_Ind) to the 180 day table ---> 
		<!---sum(cast(Invoice_Detail.gross_sales_dollars as float)) as sales_dollarD30423 All  Apply the filter(Fob_Price_Ind) to the 180 day table ---> 
		from	Invoice_Detail
		inner join BSA_Foodservice_Items_Master i
		on		i.BSA_Foodservice_Items_Master_ID = Invoice_Detail.BSA_Foodservice_Items_Master_id
		where	Invoice_Header_ID = <cfqueryparam value="#arguments.Invoice_ID#" cfsqltype="CF_SQL_VARCHAR">
		and		Invoice_Detail.Deleted = 0
		and 	Invoice_Detail.Fob_Price_Ind in('y','n')
		group by i.Description, i.item, i.BSA_Foodservice_Items_Master_ID
	</cfquery>
    <cfreturn ItemsInfo />
  </cffunction>   
  
  	<cffunction name="NonTradeInsert" output="false" hint="will Insert items into DD_Non_Trade_Product if item has cases and dollars value Greater than 0">	
  	    <cfargument name="BSA_Item_Master_ID" 	required="yes">
		<cfargument name="DeductionID" 			required="yes">
		<cfargument name="Cases" 				required="yes">
		<cfargument name="Dollars" 				required="yes">
		<cfargument name="ReasonCode" 			required="yes">
		
  		<cfset useLakebaseForcheck_DD_Non_Trade = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_non_trade_product")>
<cfif useLakebaseForcheck_DD_Non_Trade>
	<cftry>
		<cfset check_DD_Non_Trade = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_non_trade_product", {
				"bsa_foodservice_items_master_id" = "eq.#arguments.BSA_Item_Master_ID#",
				"deduction_id" = "eq.#arguments.DeductionID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheck_DD_Non_Trade = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheck_DD_Non_Trade>
<cfquery name="check_DD_Non_Trade" datasource="#application.Datasource#">
			SELECT * 
			FROM DD_Non_Trade_Product
			WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Item_Master_ID#'
			AND Deduction_ID = '#arguments.DeductionID#'
		</cfquery>
</cfif>
		
		<cfif check_DD_Non_Trade.recordcount>
			<cfquery name="check_DD_Non_Trade" datasource="#application.Datasource#">
				DELETE FROM DD_Non_Trade_Product
				WHERE BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Item_Master_ID#'
				AND Deduction_ID = '#arguments.DeductionID#'
			</cfquery>
		</cfif>
		
			<cfquery name="Insert_DD_Non_Trade" datasource="#application.DataSource#">
	  	  		Insert Into DD_Non_Trade_Product(
							Deduction_ID,
							BSA_Foodservice_Items_Master_ID,
							Dollar,
							Volume,
							Volume_UOM,
							Reason_Code_ID
							)
		 		 Values (
						'#arguments.DeductionID#',
						'#arguments.BSA_Item_Master_ID#',
						 #arguments.Dollars#,
						 #arguments.Cases#,
						  1,
						 #arguments.ReasonCode#
		  				)
	  	  		Insert Into DD_Non_Trade_Product_History(
							Deduction_ID,
							BSA_Foodservice_Items_Master_ID,
							Dollar,
							Volume,
							Volume_UOM,
							Reason_Code_ID
							)
		 		 Values (
						'#arguments.DeductionID#',
						'#arguments.BSA_Item_Master_ID#',
						 #arguments.Dollars#,
						 #arguments.Cases#,
						  1,
						 #arguments.ReasonCode#
		  				)
	  		</cfquery> 
    </cffunction> 

	<cffunction name="UpdateClosureType" output="false" hint="will update all necessary table to prevent closing this dedcution as other type" >
		<cfargument name="BSA_Item_Master_ID" required="yes">
		<cfargument name="User_ID" required="yes">
		<cfargument name="DeductionID" required="yes">
		
		<cfset useLakebaseForCloser_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_closure")>
<cfif useLakebaseForCloser_Type>
	<cftry>
		<cfset Closer_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_closure", {
				"dd_closure_desc" = "eq.Non Trade",
				"select" = "dd_closure_type_id"
			}), "dd_closure_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCloser_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCloser_Type>
<cfquery name="Closer_Type" datasource="#application.Datasource#">
			SELECT DD_Closure_Type_ID
			FROM DD_Closure 
			WHERE DD_Closure_Desc='Non Trade'  	
		</cfquery>
</cfif>
	  	<cfset useLakebaseForUpdate_Deductions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdate_Deductions>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#arguments.DeductionID#"
			},
			{
				"non_trade_updated_by" = "#arguments.User_ID#",
				"dd_closure_id" = "#arguments.BSA_Item_Master_ID#",
				"dd_closure_type" = "#Closer_Type.DD_Closure_Type_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Deductions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Deductions>
<cfquery name="Update_Deductions" datasource="#application.Datasource#">
		  	UPDATE Deductions
			SET Non_Trade_Updated_By = '#arguments.User_ID#',
			DD_Closure_ID = '#arguments.BSA_Item_Master_ID#',
			DD_Closure_Type = #Closer_Type.DD_Closure_Type_ID#
			WHERE Deduction_ID = '#arguments.DeductionID#'
		</cfquery>
</cfif>
	</cffunction>

	<cffunction name="NonTradeOpen" output="false" hint="will update necessary table to re open deduction">
		<cfargument name="DeductionID" required="yes">
		 <cfquery name="Update_Deductions" datasource="#application.Datasource#">
	     	 UPDATE Deductions
		 	 SET Non_Trade_Updated_By = NULL,
		  		 DD_Closure_ID = NULL,
		 	 	 DD_Closure_Type = NULL,
		 	 	 Is_Non_Trade_Off = 0
		  	 WHERE Deduction_ID = '#arguments.DeductionID#'
		  	 AND DD_Closure_Type in (SELECT DD_Closure_Type_ID FROM DD_Closure WHERE DD_Closure_Desc ='Non Trade')

			DELETE FROM DD_Non_Trade_Product
			WHERE Deduction_ID = '#arguments.DeductionID#'
		</cfquery>
	</cffunction>
	
	<cffunction name="Closure_Type" output="false" returntype="query">
		<cfset useLakebaseForDDCloser_Type = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_closure")>
<cfif useLakebaseForDDCloser_Type>
	<cftry>
		<cfset DDCloser_Type = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_closure", {
				"dd_closure_desc" = "eq.Non Trade",
				"select" = "dd_closure_type_id"
			}), "dd_closure_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDDCloser_Type = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDDCloser_Type>
<cfquery name="DDCloser_Type" datasource="#application.Datasource#">
			SELECT DD_Closure_Type_ID
			FROM DD_Closure 
			WHERE DD_Closure_Desc ='Non Trade'  	
		</cfquery>
</cfif>
		<cfreturn DDCloser_Type />	
	</cffunction>
	
	<cffunction name="invoicedetails" output="false" returntype="query" >
		<cfargument name="InvoiceNumber" required="yes">
		<cfquery name="qinvoicedetails" datasource="#application.Datasource#">
			SELECT I.Shared_Invoice_Number, I.Invoice_Date, I.Purchase_Order, I.Reason_Code, I.Order_Date, 
				   I.Invoice_Date, I.Ship_Date, I.Delivery_Date, BSA.Name, BSA.Ship_To
			FROM Invoice_Header I
			INNER JOIN BSA_Foodservice_Customers BSA
			ON BSA.BSA_Foodservice_Customers_ID =
			I.BSA_Foodservice_Customers_ID
			WHERE I.invoice_header_id = <cfqueryparam value="#arguments.InvoiceNumber#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfreturn qinvoicedetails/>
	</cffunction>

	<cffunction name="NonTradeItemInfo" output="true" returntype="query" >
		<cfargument name="deduction_id" type="string" required="true" >
		<cfargument name="bsa_id" 		type="string" required="false" default="">
		<cfquery name="ItemDetails" datasource="#application.Datasource#">
			SELECT Dollar, Volume, Reason_Code_Id 
			FROM DD_Non_Trade_Product
			WHERE Deduction_Id = '#arguments.deduction_id#' <cfif len(arguments.bsa_id)>and BSA_Foodservice_Items_Master_ID = '#arguments.bsa_id#'</cfif>
		</cfquery>
		<cfreturn ItemDetails/>
	</cffunction>

</cfcomponent>