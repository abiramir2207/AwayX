<!------ Deviation_Fixed_Rate_Case_1_Freight.cfm 
 MODIFIED SO IT IS ONLY USED BY objFreight.bFREIGHT_VERSION_ITEM = true
 components.freight.FreightBracketSetting ----->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// 
Rule 1. Program Fixed Components contain Delivered only
1. From the special price list table, get the lowest delivered price from any point in time in that particular time span; 
2. Else get the lowest non-bid Delivered price from the invoice tables in the window and compare it with the lowest National Delivered Truckload Price from the price list table for the window and take the lower of the two; 
3. Else calculate the price using the FOB logic (given below) and add the proxy cost to it (case proxy cost = proxy cost * gross weight). 
Price - avg. Delivered Fixed Price = Rebate
 ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!--- SPECIAL FREIGHT SETTINGS --->
<cfset objFreight = CreateObject("component","components.freight.FreightBracketSetting") />
<cfset objFreight.getFreightSettings()  />
	<!--- objFreight.bFREIGHT_VERSION_ITEM --->

<cfoutput>
<cfPARAM name="avgPricePaid" DEFAULT="0" />
<cfpARAM name="LowestAvgPricePaid" DEFAULT="#avgPricePaid#" >
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="100%" CLASS="Maintable">
<COLGROUP>
	<COL SPAN="1" WIDTH="90"></COL><!------ invoice # ----->
	<COL SPAN="1" WIDTH="90"></COL><!------ invoice date ----->
	<COL SPAN="1" ALIGN="RIGHT"></COL><!------ volume ----->
	<COL SPAN="1" ALIGN="CENTER" WIDTH="90"></COL><!------ * ----->
	<COL SPAN="1" ALIGN="RIGHT"></COL><!------ Price/CS ----->
	<COL SPAN="1" ALIGN="CENTER" WIDTH="90"></COL><!------ = ----->
	<COL SPAN="1" ALIGN="RIGHT" WIDTH="70"></COL><!------ Price ----->
</COLGROUP>
<!------ 1. From the special price list table, get the lowest delivered price from any point in time in that particular time span;  ----->
<!------ TODO: ----->
<!------ <cfset qGetSpecialPrice = bbDeviationManager.getSpecialPrice(distributorId, "0F5D7B2D-EC51-430F-82F8-904B4788DAA4", Sample_Size_End_Date, Billback_UOM, 1)> ----->
<cfset qGetSpecialPrice = bbDeviationManager.getSpecialPrice(
								distributorId = distributorId,
								productId = Product_ID,
								priceStartDate = Sample_Size_Start_Date,
								priceEndDate = Sample_Size_End_Date,
								billbackUOM = Billback_UOM,
								deliveryType = 1) />
<cfset avgPricePaid = qGetSpecialPrice.Product_Price>
<cfif (avgPricePaid LT LowestAvgPricePaid OR LowestAvgPricePaid EQ 0) AND isnumeric(avgPricePaid) AND avgPricePaid NEQ 0>
	<cfset LowestAvgPricePaid = avgPricePaid />
</cfif>
<TR CLASS="MaintableTHEAD">
	<TD COLSPAN="5" ALIGN="RIGHT"><B>Special Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
	<TD ALIGN="CENTER"><B>=</B></TD>
	<TD>#NumberFormat(avgPricePaid, DEVIATION_RATE_FORMAT)#</TD>
</TR>
<cfset lowestDliveredInvoicePrice = 0>
<cfset truckLoadPrice = 0>
<!------ if no special price list ----->
<!------ 2. Else get the lowest non-bid Delivered price from the invoice tables in the window and compare it with the lowest National Delivered Truckload Price from the price list table for the window and take the lower of the two;  ----->
<!------ get min delivered non-bid invoice price ----->
<cfset qGetInvoiceInfoDEL = bbDeviationManager.getInvoiceDetails(distributorId=distributorId, productId=Product_ID, date1=Sample_Size_Start_Date, date2=Sample_Size_End_Date, billbackUOM=Billback_UOM, invoiceDateField=check_Date, returnType=3, ProductReplacementID='', payeeTypeId=BB_Payee_Type_ID, BBproductId=BBproductId, FobPriceIndicator=Fob_Price_Indicator, InvoiceTypeFilter=Invoice_Type_Filter_List, InvoiceTypeExcludeList=Invoice_Type_Exclude_List)>
<cfset lowestDliveredInvoicePrice = qGetInvoiceInfoDEL.Min_Unit_price>
<cfset avgPricePaid = lowestDliveredInvoicePrice> <!---<cfdump var="#qGetInvoiceInfoDEL#" />--->
<cfif (avgPricePaid LT LowestAvgPricePaid OR LowestAvgPricePaid EQ 0) AND isnumeric(avgPricePaid) AND avgPricePaid NEQ 0>
	<cfset LowestAvgPricePaid = avgPricePaid />
</cfif>
<TR CLASS="MaintableTHEAD">
	<TD COLSPAN="5" ALIGN="RIGHT"><B>Invoice Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
	<TD ALIGN="CENTER"><B>=</B></TD>
	<TD>#NumberFormat(lowestDliveredInvoicePrice, DEVIATION_RATE_FORMAT)#</TD>
</TR>
<!------ get national delivered truckload price from regular price list ----->
<cfset qGetRegularTruckLoadPriceDEL = bbDeviationManager.getRegularTruckLoadPrice(
					distributorId = distributorId,
					productId = Product_ID,
					priceStartDate = Sample_Size_Start_Date,
					priceEndDate = Sample_Size_End_Date,
					billbackUOM = Billback_UOM,
					deliveryType = 1) />
<cfset truckLoadPrice = qGetRegularTruckLoadPriceDEL.Product_Price>		
<TR CLASS="MaintableTHEAD">
	<TD COLSPAN="5" ALIGN="RIGHT"><B>List Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
	<TD ALIGN="CENTER"><B>=</B></TD>
	<TD>#NumberFormat(truckLoadPrice, DEVIATION_RATE_FORMAT)#</TD>
</TR>
<cfif (avgPricePaid GT truckLoadPrice AND truckLoadPrice NEQ 0) OR avgPricePaid EQ 0>
	<cfset avgPricePaid = truckLoadPrice>
	<cfif (avgPricePaid LT LowestAvgPricePaid OR LowestAvgPricePaid EQ 0) AND isnumeric(avgPricePaid) AND avgPricePaid NEQ 0>
		<cfset LowestAvgPricePaid = avgPricePaid />
	</cfif>
</cfif>
	
<!--- 3. Else calculate the price using the FOB logic (given below) and add the proxy cost to it (case proxy cost = proxy cost * gross weight).  OR objFreight.bFREIGHT_VERSION_ITEM EQ 1 --->
<cfif avgPricePaid eq 0 >
	<!----- use the FOB price + (GDW4 proxy cost * gross weight) ---->
	<cfset calledFromDEL = 1 />
	<cfinclude template="Deviation_Fixed_Rate_Case_2.cfm">
	<cfset FOB_Price = FOBPricePaid />
	<!------ get most commonly occuring fob price ----->
	<cfset qGetInvoiceInfoDEL = bbDeviationManager.getInvoiceDetails(distributorId=distributorId, productId=Product_ID, date1=Sample_Size_Start_Date, date2=Sample_Size_End_Date, billbackUOM=Billback_UOM, invoiceDateField=check_Date, returnType=4, ProductReplacementID='', payeeTypeId=BB_Payee_Type_ID, BBproductId=BBproductId, FobPriceIndicator=Fob_Price_Indicator, InvoiceTypeFilter=Invoice_Type_Filter_List, InvoiceTypeExcludeList=Invoice_Type_Exclude_List)>
	
	<cfset DEL_FOB_Price =  0 />
	<cfif FOB_Price gt 0>
		<!--- Get the proxy Cost for the Product --->
		<cfset proxy_del_cost = val(Billback_Product_Program.proxy_del_cost)>
		<!--- If the Product UOM is LB --->
		<cfif Billback_UOM eq 2>
			<cfset proxy_del_cost = (val(Billback_Product_Program.proxy_del_cost) * val(Billback_Product_Program.gross_weight))/ val(Billback_Product_Program.net_weight)>
		<cfelse>
			<cfset proxy_del_cost = val(Billback_Product_Program.proxy_del_cost) * val(Billback_Product_Program.gross_weight)>
		</cfif>
		<cfset DEL_FOB_Price =  FOB_Price + val(proxy_del_cost) />
		<cfset avgPricePaid = DEL_FOB_Price>
		<cfif (avgPricePaid LT LowestAvgPricePaid OR LowestAvgPricePaid EQ 0) AND isnumeric(avgPricePaid) AND avgPricePaid NEQ 0>
			<cfset LowestAvgPricePaid = avgPricePaid />
		</cfif>
	</cfif>
	<!----- If no Del truckload price (regular price) found, use teh FOB price + (GDW4 proxy cost * gross weight) END ---->
</cfif>

<cfif objFreight.bFREIGHT_VERSION_ITEM EQ 1 >
	<cfset avgPricePaid = LowestAvgPricePaid />
</cfif>

<!------ get average delivered program price ----->
<cfif BB_Product_Type_ID eq 11>
	<cfset qGetAvgProgramPrice = bbDeviationManager.getAvgProgramBidRequestPrice(revisionProgramId, Product_ID, Billback_UOM, 1, appSettings.getFixedcomponents_on(), PayTo)>
<cfelse>
	<cfset qGetAvgProgramPrice = bbDeviationManager.getAvgProgramFixedPrice(revisionProgramId, Product_ID, Billback_UOM, 1, appSettings.getFixedcomponents_on(), PayTo, Dist_ID)>
</cfif>

<cfif qGetAvgProgramPrice.recordCount>
	<cfset product_Rate = qGetAvgProgramPrice.AvgProgramPrice>
</cfif>
</TABLE>
</cfoutput>