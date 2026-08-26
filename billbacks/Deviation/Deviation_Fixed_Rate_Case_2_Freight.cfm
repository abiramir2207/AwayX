<!------ Deviation_Fixed_Rate_Case_2_Freight.cfm 
 MODIFIED SO IT IS ONLY USED BY objFreight.bFREIGHT_VERSION_ITEM = true
 components.freight.FreightBracketSetting  ----->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// 
Rule 2. Program Fixed Components contain FOB only
1. From invoice table, get the most commonly occurring FOB price based on cases ordered;
2. Else retrieve the lowest non-bid Delivered price from the invoice table and subtract the delivery costs (del_del_cost + del_cust_pickup);
3. Else get the lowest FOB price from the price list table for any point in time in that particular time span;
4. Else from the special price list table, get the lowest delivered price from any point in time in that particular time span and subtract the proxy cost from it (case proxy cost = proxy cost * gross weight);
5. Else get the lowest National Delivered Truckload Price from the price list table for the window and subtract the proxy cost from it (case proxy cost = proxy cost * gross weight).
Price - avg. FOB Fixed Price = Rebate
 ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<cfparam name="calledFromDEL" default="0">
<cfoutput>
<cfif calledFromDEL eq 0>
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
</cfif>
<cfset FOBPricePaid = 0>
<cfset LowestFOBPricePaid = 0>
<!--- SPECIAL FREIGHT SETTINGS --->
<cfset objFreight = CreateObject("component","components.freight.FreightBracketSetting") />
<cfset objFreight.getFreightSettings()  />
	<!--- objFreight.bFREIGHT_VERSION_ITEM --->
<!------  1. From invoice table, get the most commonly occurring FOB price based on cases ordered; ----->
<cfset qGetInvoiceInfoFOB = bbDeviationManager.getInvoiceDetails(distributorId=distributorId, productId=Product_ID, date1=Sample_Size_Start_Date, date2=Sample_Size_End_Date, billbackUOM=Billback_UOM, invoiceDateField=check_Date, returnType=4, ProductReplacementID='', payeeTypeId=BB_Payee_Type_ID, BBproductId=BBproductId, FobPriceIndicator=Fob_Price_Indicator, InvoiceTypeFilter=Invoice_Type_Filter_List, InvoiceTypeExcludeList=Invoice_Type_Exclude_List)>
<cfif qGetInvoiceInfoFOB.recordCount>
	<!------ get the max volume used ----->
	<cfquery name="qGetMaxVolume" dbtype="query">	
		SELECT Max(Volume_Invoiced) As MaxVolume_Invoiced
		FROM	qGetInvoiceInfoFOB
	</cfquery>
	<!------ get the price used for that max volume ----->
	<cfquery name="qGetMostCommonlyUsedPrice" dbtype="query">
		SELECT	unitPrice
		FROM	qGetInvoiceInfoFOB
		WHERE	Volume_Invoiced >= #qGetMaxVolume.MaxVolume_Invoiced#
		Order By unitPrice
	</cfquery>	
	<cfset FOBPricePaid = qGetMostCommonlyUsedPrice.unitPrice>
	<cfif (FOBPricePaid LT LowestFOBPricePaid OR LowestFOBPricePaid EQ 0) AND isnumeric(FOBPricePaid) AND FOBPricePaid NEQ 0>
		<cfset LowestFOBPricePaid = FOBPricePaid />
	</cfif>
	<TR CLASS="MaintableTHEAD">
		<TD COLSPAN="5" ALIGN="RIGHT"><B>Invoice Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
		<TD ALIGN="CENTER"><B>=</B></TD>
		<TD>#NumberFormat(FOBPricePaid, DEVIATION_RATE_FORMAT)#</TD>
	</TR>
<cfelse>

	<cfset lowestDliveredInvoicePrice = 0>
	<!------ 2. Else retrieve the lowest non-bid Delivered price from the invoice table and subtract the delivery costs (del_del_cost + del_cust_pickup);  ----->
	<cfset qGetInvoiceInfoDELForFOB = bbDeviationManager.getInvoiceDetails(distributorId=distributorId, productId=Product_ID, date1=Sample_Size_Start_Date, date2=Sample_Size_End_Date, billbackUOM=Billback_UOM, invoiceDateField=check_Date, returnType=3, ProductReplacementID='', payeeTypeId=BB_Payee_Type_ID, BBproductId=BBproductId, FobPriceIndicator=Fob_Price_Indicator, InvoiceTypeFilter=Invoice_Type_Filter_List, InvoiceTypeExcludeList=Invoice_Type_Exclude_List)>
		<cfset lowestDliveredInvoicePrice = qGetInvoiceInfoDELForFOB.Min_Unit_price>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="5" ALIGN="RIGHT"><B>Invoice Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
			<TD ALIGN="CENTER"><B>=</B></TD>
			<TD>#NumberFormat(lowestDliveredInvoicePrice, DEVIATION_RATE_FORMAT)#</TD>
		</TR>
	<cfif qGetInvoiceInfoDELForFOB.recordCount AND Val(qGetInvoiceInfoDELForFOB.Min_Unit_price) NEQ 0>
		<!------ subtract Del_Del_Cost and Del_Cust_Pickup ----->
		<cfif Del_Cost_UOM NEQ Billback_UOM>
			<cfif Del_Cost_UOM EQ 1><!------ convert to LB ----->
				<cfset Del_Del_Cost 	= Del_Del_Cost / Net_weight>
				<cfset Del_Cust_Pickup 	= Del_Cust_Pickup / Net_weight>
			<cfelse><!------ convert to CS ----->
				<cfset Del_Del_Cost 	= Del_Del_Cost * Net_weight>
				<cfset Del_Cust_Pickup 	= Del_Cust_Pickup * Net_weight>
			</cfif>
		</cfif>
	
		<cfset FOBPricePaid = lowestDliveredInvoicePrice - (Val(Del_Del_Cost) + Val(Del_Cust_Pickup))>
		<cfif (FOBPricePaid LT LowestFOBPricePaid OR LowestFOBPricePaid EQ 0) AND isnumeric(FOBPricePaid) AND FOBPricePaid NEQ 0>
			<cfset LowestFOBPricePaid = FOBPricePaid />
		</cfif>
		</cfif>
		 <!----  3. Else get the lowest FOB price from the price list table for any point in time in that particular time span; ---->
		<!--- objFreight.bFREIGHT_VERSION_ITEM --->
		<cfset qGetRegularTruckLoadPriceFOB = bbDeviationManager.getRegularTruckLoadPrice(
								distributorId = distributorId,
								productId = Product_ID,
								priceStartDate = Sample_Size_Start_Date,
								priceEndDate = Sample_Size_End_Date,
								billbackUOM = Billback_UOM,
								deliveryType = 2) />

			<cfset truckLoadPrice = qGetRegularTruckLoadPriceFOB.Product_Price>		

			<cfset FOBPricePaid = truckLoadPrice>
			<cfif (FOBPricePaid LT LowestFOBPricePaid OR LowestFOBPricePaid EQ 0)  AND isnumeric(FOBPricePaid) AND FOBPricePaid NEQ 0>
				<cfset LowestFOBPricePaid = FOBPricePaid />
			</cfif>
			<cfset DEL_Price = 0 />
			<cfset qGetSpecialPrice = bbDeviationManager.getSpecialPrice(
								distributorId = distributorId,
								productId = Product_ID,
								priceStartDate = Sample_Size_Start_Date,
								priceEndDate = Sample_Size_End_Date,
								billbackUOM = Billback_UOM,
								deliveryType = 1) /> <!--- get DEL special price --->

				<cfset DEL_Price = qGetSpecialPrice.Product_Price>
				
				<cfif (DEL_Price LT LowestFOBPricePaid OR LowestFOBPricePaid EQ 0)  AND isnumeric(DEL_Price) AND DEL_Price NEQ 0>
					<cfset LowestFOBPricePaid = DEL_Price />
				</cfif>
				<TR CLASS="MaintableTHEAD">
					<TD COLSPAN="5" ALIGN="RIGHT"><B>Special Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
					<TD ALIGN="CENTER"><B>=</B></TD>
					<TD>#NumberFormat(DEL_Price, DEVIATION_RATE_FORMAT)#</TD>
				</TR>				
				<cfset qGetRegularTruckLoadPriceDEL = bbDeviationManager.getRegularTruckLoadPrice(
										distributorId = distributorId,
										productId = Product_ID,
										priceStartDate = Sample_Size_Start_Date,
										priceEndDate = Sample_Size_End_Date,
										billbackUOM = Billback_UOM,
										deliveryType = 1) />
				<cfif qGetRegularTruckLoadPriceDEL.recordCount AND Val(qGetRegularTruckLoadPriceDEL.Product_Price) NEQ 0>
					<cfset truckLoadPrice = qGetRegularTruckLoadPriceDEL.Product_Price>	
					<TR CLASS="MaintableTHEAD">
						<TD COLSPAN="5" ALIGN="RIGHT"><B>List Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
						<TD ALIGN="CENTER"><B>=</B></TD>
						<TD>#NumberFormat(truckLoadPrice, DEVIATION_RATE_FORMAT)#</TD>
					</TR>
					<cfset DEL_Price = truckLoadPrice>
					
					<cfif (DEL_Price LT LowestFOBPricePaid OR LowestFOBPricePaid EQ 0)  AND isnumeric(DEL_Price) AND DEL_Price NEQ 0>
						<cfset LowestFOBPricePaid = DEL_Price />
					</cfif>
				<cfelse>
					<TR CLASS="MaintableTHEAD">
						<TD COLSPAN="5" ALIGN="RIGHT"><B>List Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</B></TD>
						<TD ALIGN="CENTER"><B>=</B></TD>
						<TD style="color:red">Not found</TD>
					</TR>
				</cfif>
			<!---</cfif>--->
			<cfif DEL_Price NEQ 0>
				<!--- Get the proxy Cost for the Product --->
				<cfset proxy_del_cost = val(Billback_Product_Program.proxy_del_cost)>
				<!--- If the Product UOM is LB --->
				<cfif Billback_UOM eq 2>
					<cfset proxy_del_cost = (val(Billback_Product_Program.proxy_del_cost) * val(Billback_Product_Program.gross_weight))/ val(Billback_Product_Program.net_weight)>
				<cfelse>
					<cfset proxy_del_cost = val(Billback_Product_Program.proxy_del_cost) * val(Billback_Product_Program.gross_weight)>
				</cfif>
				<cfset FOBPricePaid =  DEL_Price - val(proxy_del_cost) />
				<cfif (FOBPricePaid LT LowestFOBPricePaid OR LowestFOBPricePaid EQ 0)  AND isnumeric(FOBPricePaid) AND FOBPricePaid NEQ 0>
					<cfset LowestFOBPricePaid = FOBPricePaid />
				</cfif>
			</cfif>
	
</cfif>

<cfif calledFromDEL eq 0>
	<cfset avgPricePaid = FOBPricePaid>
	<cfif objFreight.bFREIGHT_VERSION_ITEM EQ 1 >
		<cfset avgPricePaid = LowestFOBPricePaid>
	</cfif>
</cfif>

<cfif objFreight.bFREIGHT_VERSION_ITEM EQ 1 >
	<cfset avgPricePaid = LowestFOBPricePaid>
</cfif>

<!------ get average FOB program price ----->
<cfif BB_Product_Type_ID eq 11>
       <cfset qGetAvgProgramPrice = bbDeviationManager.getAvgProgramBidRequestPrice(revisionProgramId, Product_ID, Billback_UOM, 2, appSettings.getFixedcomponents_on(), PayTo)>
<cfelse>
       <cfset qGetAvgProgramPrice = bbDeviationManager.getAvgProgramFixedPrice(revisionProgramId, Product_ID, Billback_UOM, 2, appSettings.getFixedcomponents_on(), PayTo, Dist_ID)>
</cfif>

<cfif qGetAvgProgramPrice.recordCount>
	<cfset product_Rate = qGetAvgProgramPrice.AvgProgramPrice>
</cfif>

<cfif calledFromDEL eq 0>
	</TABLE>
</cfif>
</cfoutput>
