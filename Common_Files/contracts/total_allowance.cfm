
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">	

<cfif NOT isDefined("getProgramSettngs.Generic_Type")>
	<cfquery name="getProgramSettngs" datasource="#application.datasource#">
	SELECT Program_Control_Panel_Options.* 
	FROM Contract_Main
		INNER JOIN Program_Control_Panel_Options 
		ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE Contract_Main_ID = #Contract_Main_ID#
	</cfquery>
</cfif>

<cfoutput>

<!---Only show if it's turned on in application settings--->
<!---Gets pricing floor stuff--->
<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()> --->
	<cfset useLakebaseForgetfloor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForgetfloor>
	<cftry>
		<cfset getfloor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "floor_price"
			}), "floor_price"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetfloor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetfloor>
<cfset useLakebaseForGetFloor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGetFloor>
	<cftry>
		<cfset GetFloor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "floor_price"
			}), "floor_price"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFloor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFloor>
<cfquery name="getfloor" datasource="#application.datasource#">
		select floor_price from _application_settings
	</cfquery>
</cfif>
</cfif>
<cfif getfloor.floor_price IS 1>
	<cfset UseFloorPrice = 1>
<cfelse>
	<cfset UseFloorPrice = 0>
</cfif>

<cfset TotalAllowance = 0>
<cfparam name="DisplayDetails" default="0">

<!---Used only for pricing floor--->
<cfset FailedFloorTest = 0>
<cfparam name="Approval_Floor" default="">
<cfparam name="Pound_Floor" default="">

<!---If pricing floor is turned on, which pricing floor to use--->
<cfif UseFloorPrice IS 1>

	<!---If program is Operator Deviated, Operator Direct or Bid Request--->
	
	<cfif getProgramSettngs.Generic_Type IS "Operator Direct or HQ Programs" 
		OR getProgramSettngs.Generic_Type IS "Operator-Deviated Pricing" 
		OR getProgramSettngs.Generic_Type IS "Bid Request">
		
		<cfquery name="GetFloor" datasource="#application.datasource#">
		SELECT Pound_Operator_Floor AS Pound_Floor FROM Spending_Cap_Pricing_Floor
		WHERE Product_ID = '#BSA_Foodservice_Items_Master_ID#'
		</cfquery>
		
		<cfset Pound_Floor = GetFloor.Pound_Floor>
	<cfelse>
		<cfquery name="GetFloor" datasource="#application.datasource#">
		SELECT Pound_Distributor_Floor AS Pound_Floor FROM Spending_Cap_Pricing_Floor
		WHERE Product_ID = '#BSA_Foodservice_Items_Master_ID#'
		</cfquery>
		
		<cfset Pound_Floor = GetFloor.Pound_Floor>
	</cfif>
	
	<cfif len(trim(Pound_Floor)) LT 1>
		<cfset Pound_Floor = "1000000">
	</cfif>

	<!---OK, now let's estabilish whether and how much below the floor price this user can go; this users' floor price--->

	<cfif Get_Profile_Settings.Approve_Below_Floor IS 1>
		<cfif isNumeric(Get_Profile_Settings.Approve_Below_Floor_Amount) AND IsNumeric(Pound_Floor)>
			<!---If it's a number, set as a number--->
			<cfset Approval_Floor = Pound_Floor - Get_Profile_Settings.Approve_Below_Floor_Amount>	
	
		<cfelseif Get_Profile_Settings.Approve_Below_Floor_Amount IS "*">
			<!---If it's a star, make sure it's 1 less than the price being asked (so it will always succeed)--->
			<cfset Approval_Floor = "*">
		<cfelse>
		<!---Otherwise, they can't approve--->
			<cfset Approval_Floor = Pound_Floor>
		<!--- 	<cfset FailedFloorTest = 1> --->
		</cfif>
	<cfelse>
	<!---They can't approve--->
		<cfset Approval_Floor = Pound_Floor>
		<!--- <cfset FailedFloorTest = 1> --->
	</cfif>

<!---End Pricing floor logic--->	
</cfif>

<!---if display details then show discount types for just this product--->
<cfif DisplayDetails IS 1>

	<cfset useLakebaseForItemDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForItemDetails>
	<cftry>
		<cfset ItemDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#BSA_Foodservice_Items_Master_ID#",
				"select" = "item,description"
			}), "item,description"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForItemDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForItemDetails>
<cfquery name="ItemDetails" datasource="#application.datasource#">
		SELECT 	BSA_Foodservice_Items_Master.Item, 
				BSA_Foodservice_Items_Master.Description
		FROM 	BSA_Foodservice_Items_Master 
		WHERE	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
	</cfquery>
</cfif>

	<table border="0"  width="98%">
		<tr>
			<td>
				<strong>#ItemDetails.Description#</strong>
			</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td>
				<strong>#ItemDetails.Item#</strong>
			</td>
			<td align="right">
				<em>All values are per pound</em>
			</td>
		</tr>
	</table>

	<hr width="98%" color="orange" align="left">

	<table border="0" width="98%" class="maintable" cellpadding="2" cellspacing="0">
	
		<tr bgcolor="lightsteelblue">
			<td class="tableheaders"><strong>Discount Type</strong></td>
			<td class="tableheaders"><strong>Price List</strong></td>
			<cfif UseFloorPrice IS 1><td class="tableheaders"><strong>Meets Price Floor</strong></td></cfif>
			<td class="tableheaders"><strong>#Application.RebateLabel#/Price Offered</strong></td>
			<td class="tableheaders"><strong>Discount</strong></td>
		</tr>
		
		<!--- <cfinclude template="/common_files/contracts/makeNumeric.cfm"> --->
		
</cfif>

<cfset useLakebaseForGetItemInformation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_items_master")>
<cfif useLakebaseForGetItemInformation>
	<cftry>
		<cfset GetItemInformation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_items_master", {
				"bsa_foodservice_items_master_id" = "eq.#BSA_Foodservice_Items_Master_ID#",
				"select" = "item,description,net_weight"
			}), "item,description,net_weight"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetItemInformation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetItemInformation>
<cfquery name="GetItemInformation" datasource="#application.datasource#">
	SELECT 	BSA_Foodservice_Items_Master.Item, 
			BSA_Foodservice_Items_Master.Description, 
			BSA_Foodservice_Items_Master.Net_Weight
	FROM 	BSA_Foodservice_Items_Master
	WHERE 	BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
</cfquery>
</cfif>

<cfquery name="GetContractProductInfo" datasource="#application.datasource#">
	SELECT 	Contract_Products.Contract_Products_ID, 
			Contract_Products.Product_Type_ID, 
			Contract_Product_Margin.FPR_LB, 
			Contract_Product_Margin.KPR_LB, 
			Contract_Product_Margin.OER_LB, 
			Contract_Product_Margin.RER_LB, 
			Contract_Product_Margin.GRR_LB,
			Contract_Product_Margin.QPR_LB
	FROM 	Contract_Products	
			INNER JOIN Contract_Product_Margin ON 
				Contract_Product_Margin.Contract_Product_ID = Contract_Products.Contract_Products_ID
	WHERE 	Contract_Products.Contract_Main_ID = '#Contract_Main_ID#'
	AND 	Contract_Products.BSA_Foodservice_Items_Master_ID = '#BSA_Foodservice_Items_Master_ID#'
	AND 	Contract_Products.Deleted = 0
</cfquery>

<!------ Get the avg price for the distributors ----->
<cfquery name="GetPriceList" datasource="#application.datasource#">
SELECT 	SUM(FOB_PRICE), 
		ISNULL(SUM(BRACKET_PRICE), 0)  LB_FOB_Price
FROM 	Product_Based_Margin
WHERE 	PRODUCT_ID = '#BSA_Foodservice_Items_Master_ID#'
		AND PROGRAM_ID = #Contract_Main_ID#
		AND PRODUCT_TYPE_ID = 
		(
		SELECT 	TOP 1 PRODUCT_TYPE_ID
		FROM	Product_Based_Margin
		WHERE	PRODUCT_ID = '#BSA_Foodservice_Items_Master_ID#'
		AND PROGRAM_ID = #Contract_Main_ID#
		)
</cfquery>

<cfif GetPriceList.Recordcount LT 1>
	<cfset LB_FOB_Price = 0>
<cfelse>
	<cfset LB_FOB_Price = GetPriceList.LB_FOB_Price>
</cfif>

<cfif LB_FOB_Price EQ 0>
	<!------ Get regular price list price ----->
	<!---Call the get_fob_proce stored proc to get price--->
	<cfstoredproc procedure="GET_FOB_PRICE" datasource="#application.datasource#">
  
		<!--- cfprocparam tags --->
	   	<cfprocparam type = "In" CFSQLType ="CF_SQL_CHAR" dbVarName = "@@SHIP_TO" null="yes">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_ID" value="#BSA_Foodservice_Items_Master_ID#" null="no">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRICE_ID" null="yes" value="">
		<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="CS_FOB_Price" dbVarName = "@@CS_PRICE" null="no">
		<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="LB_FOB_Price" dbVarName = "@@LB_PRICE" null="no">

	</cfstoredproc>
	
	<cfif LB_FOB_Price EQ "">
		<cfset LB_FOB_Price = 0>
	</cfif>
</cfif>


<cfif LB_FOB_Price EQ 0>
	<!------ Get default price ----->
	<cfquery name="GetPriceList" datasource="#application.datasource#">
		SELECT 	LB_FOB_Price
		FROM 	Price_List_Default
		WHERE 	Product_ID = '#BSA_Foodservice_Items_Master_ID#'
	</cfquery> 
	<cfif GetPriceList.Recordcount LT 1>
		<cfset LB_FOB_Price = 0>
	<cfelse>
		<cfset LB_FOB_Price = GetPriceList.LB_FOB_Price>
	</cfif>
</cfif>

<!---TSF: Modification Bid Requests--->
<!---Only show Bid Request if the product_type_id is 10--->
<!---///////////////////////////////////////////////////ONLY BID REQUEST//////////////////////////////////////////////////--->
<cfif GetContractProductInfo.Product_Type_ID eq 10>
	<!---Bid Request number 10--->
	
	<!---Get Bid Request cost data -- query of a query--->
	<cfset useLakebaseForgetBidRequestCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getcontractproductinfo")>
<cfif useLakebaseForgetBidRequestCosts>
	<cftry>
		<cfset getBidRequestCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getcontractproductinfo", {
				"product_type_id" = "eq.10"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBidRequestCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBidRequestCosts>
<cfquery name="getBidRequestCosts" dbtype="query">
		SELECT 	*
		FROM 	GetContractProductInfo
		WHERE 	Product_Type_ID = 10
	</cfquery>
</cfif>
	
	<cfif isNumeric(getBidRequestCosts.FPR_LB)>
	
		<cfset Bid_Request_Price_Value = getBidRequestCosts.QPR_LB>
		<cfset BidRequestDiscount = LB_FOB_Price - Bid_Request_Price_Value>
	
		<cfif DisplayDetails IS 1>
		
			<tr>	
				<td><strong>Proposal:</strong></td>
				<Td>$#numberformat(LB_FOB_Price, '___,___,___,___.____')#</TD>
				<cfif UseFloorPrice IS 1>
					<td align="center">
					<!----If the users floor price is below the price set, we're ok. Otherwise we fail.--->
					<cfif Approval_Floor GT Bid_Request_Price_Value>
						<cfset FailedFloorTest = 1>
						<img src="/images/no_small.gif">
					<cfelse>
						<img src="/images/yes_small.gif">
					</cfif>
					</td>
					<td>$#numberformat(Bid_Request_Price_Value, '___,___,___,___.____')#</td>
					<td>NA </td>
				<cfelse>
					<td>$#numberformat(Bid_Request_Price_Value, '___,___,___,___.____')#</td>
					<td><cfif BidRequestDiscount LT 0><font color="red"></cfif>$#numberformat(BidRequestDiscount, '___,___,___,___.____')#</font></td>
				</cfif>
				
			</tr>
			
		</cfif>
	
	<cfif UseFloorPrice IS NOT 1>
		<cfset TotalAllowance = TotalAllowance + BidRequestDiscount>
	<cfelse>
		<cfif Approval_Floor GT Bid_Request_Price_Value>
			<cfset FailedFloorTest = 1>
		</cfif>
	</cfif>
			
	</cfif>

<!---///////////////////////////////////////////////////THE REST OF THE WORLD//////////////////////////////////////////////////--->
<cfelse>
	
	<!---Fixed Price number 1--->
	
	<!---Get just fixed price product data -- query of a query--->
	<cfset useLakebaseForgetFixedPriceCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getcontractproductinfo")>
<cfif useLakebaseForgetFixedPriceCosts>
	<cftry>
		<cfset getFixedPriceCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getcontractproductinfo", {
				"product_type_id" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetFixedPriceCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetFixedPriceCosts>
<cfquery name="getFixedPriceCosts" dbtype="query">
		SELECT 	*
		FROM 	GetContractProductInfo
		WHERE 	Product_Type_ID = 1
	</cfquery>
</cfif>
	
	<cfif isNumeric(getFixedPriceCosts.FPR_LB) AND getFixedPriceCosts.Recordcount GT 0>
	
		<cfset Fixed_Price_Value = getFixedPriceCosts.FPR_LB>
		<cfset FixedPriceDiscount = LB_FOB_Price - Fixed_Price_Value>
	
		<cfif DisplayDetails IS 1>
		
			<tr>	
				<td><strong>Fixed Price:</strong></td>
				<Td>$#numberformat(LB_FOB_Price, '___,___,___,___.____')#</TD>
				<cfif UseFloorPrice IS 1>
					<td align="center">
					<!----If the users floor price is below the price set, we're ok. Otherwise we fail.--->
					<cfif Approval_Floor GT Fixed_Price_Value>
						<cfset FailedFloorTest = 1>
						<img src="/images/no_small.gif">
					<cfelse>
						<img src="/images/yes_small.gif">
					</cfif>
					</td>
					<td>$#numberformat(Fixed_Price_Value, '___,___,___,___.____')#</td>
					<td>NA</td>
				<cfelse>
					<td>$#numberformat(Fixed_Price_Value, '___,___,___,___.____')#</td>
					<td><cfif FixedPriceDiscount LT 0><font color="red"></cfif>$#numberformat(FixedPriceDiscount, '___,___,___,___.____')#</font></td>
				</cfif>
				
			</tr>
			
		</cfif>
		
		<cfif Approval_Floor GT Fixed_Price_Value>
			<cfset FailedFloorTest = 1>
		</cfif>
		<cfif UseFloorPrice IS NOT 1>
			<cfset TotalAllowance = TotalAllowance + FixedPriceDiscount>
		</cfif>
	
	</cfif>
	
	<!---Formula Price number 5--->
	
	<!---Get just formula price product data -- query of a query--->
	<cfset useLakebaseForgetFormulaPriceCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getcontractproductinfo")>
<cfif useLakebaseForgetFormulaPriceCosts>
	<cftry>
		<cfset getFormulaPriceCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getcontractproductinfo", {
				"product_type_id" = "eq.5"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetFormulaPriceCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetFormulaPriceCosts>
<cfquery name="getFormulaPriceCosts" dbtype="query">
		SELECT 	*
		FROM 	GetContractProductInfo
		WHERE 	Product_Type_ID = 5
	</cfquery>
</cfif>

	<cfif isNumeric(getFormulaPriceCosts.KPR_LB) AND getFormulaPriceCosts.Recordcount GT 0>
	
		<cfset Formula_Price_Value = getFormulaPriceCosts.KPR_LB>
		<cfset FormulaPriceDiscount = LB_FOB_Price - Formula_Price_Value>
	
		<cfif DisplayDetails IS 1>
		
			<tr>	
				<td><strong>Formula Price:</strong></td>
				<Td>$#numberformat(LB_FOB_Price, '___,___,___,___.____')#</TD>
				
				<cfif UseFloorPrice IS 1>
					<td>
					<!----If the users floor price is below the price set, we're ok. Otherwise we fail.--->
					<cfif Approval_Floor GT Formula_Price_Value>
						<cfset FailedFloorTest = 1>
						<img src="/images/no_small.gif">
					<cfelse>
						<img src="/images/yes_small.gif">
					</cfif>
					</td>
					<td>$#numberformat(Formula_Price_Value, '___,___,___,___.____')#</td>
					<td>NA</td>
				<cfelse>
					<td>$#numberformat(Formula_Price_Value, '___,___,___,___.____')#</td>
					<td><cfif FormulaPriceDiscount LT 0><font color="red"></cfif>$#numberformat(FormulaPriceDiscount, '___,___,___,___.____')#</font></td>
				</cfif>
								
			</tr>
		 
		</cfif>
		
	<cfif Approval_Floor GT Formula_Price_Value>
		<cfset FailedFloorTest = 1>
	</cfif>
	
	<cfif UseFloorPrice IS NOT 1>
		<cfset TotalAllowance = TotalAllowance + FormulaPriceDiscount>
	</cfif>
		
	</cfif>
		
	<!---Off Invoice number 8 OER_LB --->
	
	<!---Get just off invoice product data -- query of a query--->
	<cfset useLakebaseForgetOffInvoiceCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getcontractproductinfo")>
<cfif useLakebaseForgetOffInvoiceCosts>
	<cftry>
		<cfset getOffInvoiceCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getcontractproductinfo", {
				"product_type_id" = "eq.8"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetOffInvoiceCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetOffInvoiceCosts>
<cfquery name="getOffInvoiceCosts" dbtype="query">
		SELECT 	*
		FROM 	GetContractProductInfo
		WHERE 	Product_Type_ID = 8
	</cfquery>
</cfif>
	
	<cfif isNumeric(getOffInvoiceCosts.OER_LB)  AND getOffInvoiceCosts.Recordcount GT 0>
	
		<cfset Off_Invoice_Value = getOffInvoiceCosts.OER_LB>
		<cfset OffInvoiceDiscount = Off_Invoice_Value>
	
		<cfif DisplayDetails IS 1>
		
			<tr>	
				<td><strong>Off Invoice:</strong></td>
				<Td>#lsCurrencyFormat(LB_FOB_Price)#</TD>
						
				<cfif UseFloorPrice IS 1>
					<td>
					<!----If the users floor price is below the price set, we're ok. Otherwise we fail.--->
					<cfif Approval_Floor GT Off_Invoice_Value>
						<cfset FailedFloorTest = 1>
						<img src="/images/no_small.gif">
					<cfelse>
						<img src="/images/yes_small.gif">
					</cfif>
					</td>
					<td>$#numberformat(Off_Invoice_Value, '___,___,___,___.____')#</td>
					<td>NA</td>
				<cfelse>
					<td>$#numberformat(Off_Invoice_Value, '___,___,___,___.____')#</td>
					<td><cfif OffInvoiceDiscount LT 0><font color="red"></cfif>$#numberformat(OffInvoiceDiscount, '___,___,___,___.____')#</font></td>
				</cfif>
			
			</tr>
		 
		</cfif>
		
		
		<cfif Approval_Floor GT Off_Invoice_Value>
			<cfset FailedFloorTest = 1>
		</cfif>
		<cfif UseFloorPrice IS NOT 1>
			<cfset TotalAllowance = TotalAllowance + OffInvoiceDiscount>
		</cfif>

	</cfif>
	<!--- 
	<!---Shows different information--->
	<cfif DisplayDetails IS 1>
	
	<tr bgcolor="lightsteelblue">
		<td class="tableheaders">&nbsp; </td>
		<td class="tableheaders">&nbsp; </td>
		<td class="tableheaders"><strong>Rebate Offered</strong></td>
		<td class="tableheaders"><strong>Allowance/Discount</strong></td>
	</tr>
	
	</cfif> --->
	
	<!---Rebate number 2--->
	
	<!---Get just rebate product data -- query of a query--->
	<cfset useLakebaseForgetRebateCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getcontractproductinfo")>
<cfif useLakebaseForgetRebateCosts>
	<cftry>
		<cfset getRebateCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getcontractproductinfo", {
				"product_type_id" = "eq.2"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetRebateCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetRebateCosts>
<cfquery name="getRebateCosts" dbtype="query">
		SELECT 	*
		FROM 	GetContractProductInfo
		WHERE 	Product_Type_ID = 2
	</cfquery>
</cfif>
	
	<cfif isNumeric(getRebateCosts.RER_LB) AND getRebateCosts.Recordcount GT 0>
	
		<cfset Rebate_Value = getRebateCosts.RER_LB >
	
		<cfif DisplayDetails IS 1>
			
			<tr>	
				<td><strong>#Application.RebateLabel#:</strong></td>
				<Td>&nbsp; </TD>
				<cfif UseFloorPrice IS 1>	<td>&nbsp; </td></cfif>
				<td>$#numberformat(Rebate_Value, '___,___,___,___.____')#</td>
				<td><cfif Rebate_Value LT 0><font color="red"></cfif>$#numberformat(Rebate_Value, '___,___,___,___.____')#</font></td>
			</tr>
		 
		</cfif>
		
		<cfset TotalAllowance = TotalAllowance + Rebate_Value>
	
	</cfif>
	
	<!---Growth number 4--->
	
	<!---Get just growth product data -- query of a query--->
	<cfset useLakebaseForgetGrowthCosts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getcontractproductinfo")>
<cfif useLakebaseForgetGrowthCosts>
	<cftry>
		<cfset getGrowthCosts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getcontractproductinfo", {
				"product_type_id" = "eq.4"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGrowthCosts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGrowthCosts>
<cfquery name="getGrowthCosts" dbtype="query">
		SELECT 	*
		FROM 	GetContractProductInfo
		WHERE 	Product_Type_ID = 4
	</cfquery>
</cfif>
	
	<cfif isNumeric(getGrowthCosts.GRR_LB) AND getGrowthCosts.Recordcount GT 0>
	
		<cfset Growth_Value = getGrowthCosts.GRR_LB>
	
		<cfif DisplayDetails IS 1>
		
			<tr>	
				<td><strong>Growth:</strong></td>
				<Td>&nbsp; </TD>
				<cfif UseFloorPrice IS 1>	<td>&nbsp; </td></cfif>
				<td>$#numberformat(Growth_Value, '___,___,___,___.____')#</td>
				<td><cfif Growth_Value LT 0><font color="red"></cfif>$#numberformat(Growth_Value, '___,___,___,___.____')#</font></td>
			</tr>
		 
		</cfif>
		
		<cfset TotalAllowance = TotalAllowance + Growth_Value>
	
	</cfif>

</cfif>

<cfif DisplayDetails IS 1>

		<tr>
			<td colspan="3">
				Total for allowances: &nbsp; 
			</td>
			<cfif UseFloorPrice IS 1>	<td>&nbsp; </td></cfif>
			<td>
				<cfif TotalAllowance LT 0><font color="red"><cfelse><font color="black"></cfif>$#numberformat(TotalAllowance, '___,___,___,___.____')#</font>
			</td>
		</tr>
		
	</table>
	
	<center>
	
	<CF_smallLink   
		title = "close window"   
		url = "##"  
		parameters = "onClick=""JavaScript: window.close();return false;""" 
		>
	</center>
	
</cfif>

</cfoutput>
