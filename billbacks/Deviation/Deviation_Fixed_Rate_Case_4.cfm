<!------ fixed price (formula price) calculation cases - case 4----->
<!------ Deviation_Fixed_Rate_Case_4.cfm ----->
<!------ Rule 4. Old invoice amount scheme ----->
	<!------------------ Start Invoice Info display for fixed and formula ----------------------------->
	
	<!---- Fixed or Formula ----->



<cfset deliveryTypeToUse = 0 />
<CFIF IsDate(Sample_Size_Start_Date) AND IsDate(Sample_Size_End_Date)>
	<cfif programDelType eq 1 or programDelType eq 4>
	<!------------------- Get invoice info for the sample size ----------------->	
	<cfset Invoice_Info = bbDeviationManager.getInvoiceDetailsWithFreight(
			distributorId = distributorId, 
			productId = Product_ID, 
			date1 = Sample_Size_Start_Date, 
			date2 = Sample_Size_End_Date, 
			billbackUOM = Billback_UOM, 
			invoiceDateField = check_Date, 
			deliveryType = programDelType,
			warehouseMasterId = warehouseMasterId,
			zipCode = zipCode,
			ProductReplacementID = ProductReplacementID,
			useFreightCalcDelTypeFromInvoice = useFreightCalcDelTypeFromInvoice,
			payeeTypeId = BB_Payee_Type_ID,
			programId = revisionProgramId,
			BBproductId = BBproductId,
			FobPriceIndicator = Fob_Price_Indicator,
			InvoiceTypeFilter = Invoice_Type_Filter_List,
			InvoiceTypeExcludeList = Invoice_Type_Exclude_List)>
	<cfelse>
	<!------------------- Get invoice info for the sample size ----------------->	
	<cfset Invoice_Info = bbDeviationManager.getInvoiceDetails(
			distributorId = distributorId, 
			productId = Product_ID, 
			date1 = Sample_Size_Start_Date, 
			date2 = Sample_Size_End_Date, 
			billbackUOM = Billback_UOM, 
			invoiceDateField = check_Date, 
			returnType = 1,
			ProductReplacementID = ProductReplacementID,
			payeeTypeId = BB_Payee_Type_ID,
			BBproductId = BBproductId,
			FobPriceIndicator = Fob_Price_Indicator,
			InvoiceTypeFilter = Invoice_Type_Filter_List,
			InvoiceTypeExcludeList = Invoice_Type_Exclude_List)>
	</cfif>	
<CFELSE>
	<CFSET Invoice_Info = QueryNew("")>
</CFIF>

<CFOUTPUT>
<CFSET Open_layer_Desc="Invoices from #DateFormat(Sample_Size_Start_Date, "mm/dd/yyyy")# - #DateFormat(Sample_Size_End_Date, "mm/dd/yyyy")#">
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="#Open_layer_Desc#"  
	TitleClosed="#Open_layer_Desc#"  
	TitleTooltip="#Open_layer_Desc#"  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="Yes"
	Width="#width#"
	AddScript="#AddScript#">
<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" ALIGN="CENTER" WIDTH="100%" CLASS="Maintable">
<!---<CAPTION ALIGN="Left" STYLE="font-size:11px;font-weight:bold;">Invoices from #DateFormat(Sample_Size_Start_Date, "mm/dd/yyyy")# - #DateFormat(Sample_Size_End_Date, "mm/dd/yyyy")#</CAPTION>--->
<COLGROUP>
	<COL SPAN="1" WIDTH="90"></COL><!------ invoice # ----->
	<COL SPAN="1" WIDTH="90"></COL><!------ invoice date ----->
	<cfif appsettings.getBillback_Display_Base_Sales_in_Rate_Dev() EQ 1>
		<COL SPAN="1" WIDTH="90"></COL><!------ Base sales price ----->
	</cfif>
	<COL SPAN="1" ALIGN="RIGHT"></COL><!------ volume ----->
	<COL SPAN="1" ALIGN="CENTER" WIDTH="90"></COL><!------ * ----->
	<COL SPAN="1" ALIGN="RIGHT"></COL><!------ Price/CS ----->
	<cfif (programDelType eq 1 or programDelType eq 4) AND NOT objFreight.bFREIGHT_VERSION_ITEM> <!--- programDelType: 1=DEL, 4=FOB DC ----->
	<COL SPAN="1" ALIGN="CENTER"></COL><!------ + ----->
	<COL SPAN="1" ALIGN="RIGHT"></COL><!------ IBF ----->
	</cfif>
	<cfif programDelType eq 1 AND NOT objFreight.bFREIGHT_VERSION_ITEM> <!--- programDelType: 1=DEL, 4=FOB DC ----->
	<COL SPAN="1" ALIGN="CENTER"></COL><!------ + ----->
	<COL SPAN="1" ALIGN="RIGHT"></COL><!------ OBF ----->
	</cfif>
	<COL SPAN="1" ALIGN="CENTER" WIDTH="90"></COL><!------ = ----->
	<COL SPAN="1" ALIGN="RIGHT" WIDTH="70"></COL><!------ Price ----->
</COLGROUP>		
<cfset max_price = 0>
<cfset min_price = "" />
<cfset minmax_fob_price_ind = "Y">
<cfset minmax_ibf_rate = 0>
<cfset minmax_obf_rate = 0>
<cfset IBF_Rate_PER_BB_UOM = 0 />
<cfset OBF_Rate_PER_BB_UOM = 0 />
	<CFIF Invoice_Info.recordCount GT 0>
		<TR BGCOLOR="FFCE84" CLASS="MaintableTHEAD" STYLE="border-bottom:solid 93BEE2 1px;">
			<TD>Invoice ##</TD>
			<TD>#ListGetAt(DEVIATION_CONSTANTS_Trade_Eligibility_Triggers, Billback_Rate_Tolerance.BB_Tolerance_TET, ",")#</TD>
			<cfif appsettings.getBillback_Display_Base_Sales_in_Rate_Dev() EQ 1>
				<TD>#appsettings.getMarginColHeader2()#</TD><!--- Base Sales is the value--->
			</cfif>			
			<TD>Volume (#ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#)</TD>
			<TD>&nbsp;</TD>
			<TD>Price / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</TD>
			<cfif (programDelType eq 1 or programDelType eq 4) AND NOT objFreight.bFREIGHT_VERSION_ITEM> <!--- programDelType: 1=DEL, 4=FOB DC ----->
			<TD>&nbsp;</TD>
			<TD>IBF / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</TD>
			</cfif>
			<cfif programDelType eq 1 AND NOT objFreight.bFREIGHT_VERSION_ITEM> <!--- programDelType: 1=DEL, 4=FOB DC ----->
			<TD>&nbsp;</TD>
			<TD>OBF / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#</TD>
			</cfif>
			<TD>&nbsp;</TD>
			<TD>$</TD>
			<TD>&nbsp;</TD>
		</TR>		
		<CFLOOP QUERY="Invoice_Info">
		<cfset invoice_price = Invoice_Info.Unit_Price_PER_BB_UOM />
		<cfif programDelType NEQ 0>
			<CFSET IBF_Rate_PER_CS = (Val(IBF_Rate) / 100.00) * Gross_Weight>
			<CFSET OBF_Rate_PER_CS = (Val(OBF_Rate) / 100.00) * Gross_Weight>
			<cfif Billback_UOM EQ 2> <!--- LB --->
				<CFSET IBF_Rate_PER_BB_UOM = IBF_Rate_PER_CS / Net_Weight>
				<CFSET OBF_Rate_PER_BB_UOM = OBF_Rate_PER_CS / Net_Weight>
			<cfelse>
				<CFSET IBF_Rate_PER_BB_UOM = IBF_Rate_PER_CS>
				<CFSET OBF_Rate_PER_BB_UOM = OBF_Rate_PER_CS>
			</cfif>
			<cfif not useFreightCalcDelTypeFromInvoice>
				<cfif programDelType eq 1 or programDelType eq 4> <!--- programDelType: 1=DEL, 4=FOB DC ----->
					<cfset invoice_price = invoice_price + IBF_Rate_PER_BB_UOM /> 						
				</cfif>
				<cfif programDelType eq 1> <!--- programDelType: 1=DEL, 4=FOB DC ----->
					<cfset invoice_price = invoice_price + OBF_Rate_PER_BB_UOM /> 						
				</cfif>
			</cfif>
		</cfif>
		<CFSET Price_Per_Invoice=(Invoice_Info.Volume_Invoiced * invoice_price)>
		<CFSET Total_Price=Total_Price + Price_Per_Invoice>
		<CFSET Total_Pounds_Invoiced = Total_Pounds_Invoiced + Invoice_Info.Volume_Invoiced>		
		<TR>					
			<TD>#Invoice_Info.Shared_Invoice_Number#</TD>
			<TD>#DateFormat(Invoice_Info.This_Date, "mm/dd/yyyy")#</TD>
			<cfif appsettings.getBillback_Display_Base_Sales_in_Rate_Dev() EQ 1>
				<TD><cfif (Trim(ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")) EQ 'CS')>#Invoice_Info.Base_Sales_Price_CS#<cfelse>#Invoice_Info.Base_Sales_Price_LB#</cfif>&nbsp;</TD>
			</cfif>
			<TD>#NumberFormat(Invoice_Info.Volume_Invoiced, DEVIATION_VOLUME_FORMAT)#</TD>
			<TD>*</TD>
			<TD>#NumberFormat(Invoice_Info.Unit_Price_PER_BB_UOM, DEVIATION_RATE_FORMAT)#</TD>
			<cfif (programDelType eq 1 or programDelType eq 4) AND NOT objFreight.bFREIGHT_VERSION_ITEM> <!--- programDelType: 1=DEL, 4=FOB DC ----->
			<TD><cfif useFreightCalcDelTypeFromInvoice AND FOB_PRICE_IND NEQ "Y" AND FOB_PRICE_IND NEQ "N">&nbsp;
				<cfelse>+
				</cfif></TD>
			<TD><cfif useFreightCalcDelTypeFromInvoice AND FOB_PRICE_IND NEQ "Y" AND FOB_PRICE_IND NEQ "N">&nbsp;
				<cfelse>#NumberFormat(IBF_Rate_PER_BB_UOM, DEVIATION_RATE_FORMAT)#
				</cfif>
			</TD>
			</cfif>
			<cfif programDelType eq 1 AND NOT objFreight.bFREIGHT_VERSION_ITEM> <!--- programDelType: 1=DEL, 4=FOB DC ----->
			<TD><cfif useFreightCalcDelTypeFromInvoice AND FOB_PRICE_IND NEQ "N">&nbsp;
				<cfelse>+
				</cfif>
			</TD>
			<TD>
				<cfif useFreightCalcDelTypeFromInvoice AND FOB_PRICE_IND NEQ "N">&nbsp;
				<cfelse>
				#NumberFormat(OBF_Rate_PER_BB_UOM, DEVIATION_RATE_FORMAT)#
				</cfif>
			</TD>
			</cfif>
			<TD>=</TD>
			<TD>#NumberFormat(Price_Per_Invoice, DEVIATION_RATE_FORMAT)#</TD>			
			<TD>&nbsp;</TD>
		</TR>	
			<cfif max_price LTE invoice_price>
				<cfset max_price = invoice_price>
				<CFIF programDelType NEQ 0>
				<cfif appsettings.getBBDeviationUseMaxPrice() EQ 1>
					<cfset minmax_fob_price_ind = FOB_PRICE_IND>
					<cfset minmax_ibf_rate = IBF_Rate_PER_BB_UOM>
					<cfset minmax_obf_rate = OBF_Rate_PER_BB_UOM>
				</cfif>
				</cfif>
			</cfif>
			<cfif min_price eq "" OR min_price GTE invoice_price>
				<cfset min_price = invoice_price>
				<CFIF programDelType NEQ 0>
				<cfif appsettings.getBBDeviationUseMaxPrice() EQ 2>
					<cfset minmax_fob_price_ind = FOB_PRICE_IND>
					<cfset minmax_ibf_rate = IBF_Rate_PER_BB_UOM>
					<cfset minmax_obf_rate = OBF_Rate_PER_BB_UOM>
				</cfif>
				</cfif>
			</cfif>
		</CFLOOP>
	<CFELSE>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="100%"><B><FONT COLOR="Red">No Invoice found</FONT></B></TD>
		</TR>
	</CFIF>
	<CFIF appsettings.getBBDeviationUseMaxPrice() EQ 1>
		<cfset avgPricePaid = max_price>
	<CFELSEIF appsettings.getBBDeviationUseMaxPrice() EQ 2>
		<cfset avgPricePaid = Val(min_price) />
	<CFELSE>
		<cfset totalRowColspan = 5 />
		<cfif programDelType eq 1 or programDelType eq 4>
			<cfset totalRowColspan = totalRowColspan + 2 />
		</cfif>
		<cfif programDelType eq 1>
			<cfset totalRowColspan = totalRowColspan + 2 />
		</cfif>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="#totalRowColspan#" ALIGN="RIGHT"><B>Total $ &nbsp;&nbsp; (&##931; $) </B></TD>
			<TD ALIGN="CENTER"><B>=</B></TD>
			<TD>#NumberFormat(Total_Price, DEVIATION_RATE_FORMAT)#</TD>
		</TR>
		<TR CLASS="MaintableTHEAD">
			<TD COLSPAN="#totalRowColspan#" ALIGN="RIGHT" STYLE="border-bottom:solid Orange 1px;"><B>Total Volume &nbsp;&nbsp; (&##931; Volume (#ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")#)) </B></TD>
			<TD ALIGN="CENTER" STYLE="border-bottom:solid Orange 1px;"><B>=</B></TD>
			<TD STYLE="border-bottom:solid Orange 1px;">#NumberFormat(Total_Pounds_Invoiced, DEVIATION_VOLUME_FORMAT)#</TD>
		</TR>
		<CFSET Weighted_Average_Revenue=0>
		<CFIF Total_Pounds_Invoiced NEQ 0>		
			<CFSET Weighted_Average_Revenue=Total_Price/Total_Pounds_Invoiced>
		</CFIF>
		<TR CLASS="MaintableTHEAD" TITLE="#NumberFormat(Total_Price, DEVIATION_RATE_FORMAT)# / #NumberFormat(Total_Pounds_Invoiced, DEVIATION_VOLUME_FORMAT)# = #NumberFormat(Weighted_Average_Revenue, DEVIATION_RATE_FORMAT)#">
			<TD COLSPAN="#totalRowColspan#" ALIGN="RIGHT"><B>Weighted Average Revenue / #ListGetAt(DEVIATION_QUANTITY_UOM, Billback_UOM, ",")# &nbsp;&nbsp; (Total $ / Total Volume) </B></TD>
			<TD ALIGN="CENTER"><B>=</B></TD>
			<TD>#NumberFormat(Weighted_Average_Revenue, DEVIATION_RATE_FORMAT)#</TD>
		</TR>
			<cfset avgPricePaid = Weighted_Average_Revenue>
	</CFIF>
	<CFIF (appsettings.getBBDeviationUseMaxPrice() EQ 1 OR appsettings.getBBDeviationUseMaxPrice() EQ 2) AND NOT objFreight.bFREIGHT_VERSION_ITEM>
		<!--- If minmax_fob_price_ind is X, use deliveryTypeToUse = 0 (FOB logic) --->
		<cfif minmax_fob_price_ind EQ "Y"><!--- invoice is FOB/FDC --->
			<!--- Program: 1= DEL, 4= FDC --->
			<cfif programDelType eq 4> <!--- Program is FDC, use FDC --->
				<cfset deliveryTypeToUse = 4 />
			<cfelseif programDelType eq 1> <!--- Program is DEL, use FDC --->
				<cfif bbDeviationManager.bGetInvoiceOnlyOBF() EQ TRUE>
					<cfset deliveryTypeToUse = 5 /><!--- New delivery type for using OBF rate on Invoice only.  Used with Delivered components--->
				<cfelse>
					<cfset deliveryTypeToUse = 4 />
				</cfif>
			<cfelse> <!--- Program is FOB, use FOB --->
				<cfset deliveryTypeToUse = 0 />
			</cfif>
		<cfelseif minmax_fob_price_ind EQ "N"><!--- invoice is DEL --->
			<!--- Program: 1= DEL, 4= FDC --->
			<cfif programDelType eq 4> <!--- Program is FDC, use FDC --->
				<cfset deliveryTypeToUse = 4 />
			<cfelseif programDelType eq 1> <!--- Program is DEL, use DEL --->
				<cfset deliveryTypeToUse = 1 />
			<cfelse> <!--- Program is FOB, use FOB --->
				<cfset deliveryTypeToUse = 0 />
			</cfif>
		</cfif>
	</CFIF>
</TABLE>
</CF_openLayer>
</CFOUTPUT>		
<!------------------ End Invoice Info display for fixed and formula ----------------------------->
