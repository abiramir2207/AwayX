
<cfoutput>
	<tr>
		<td colspan="100%">
			&nbsp;
		</td>
	</tr>
	<tr class="tableHeader">
		<td colspan="100%">
			Unknown Products
		</td>
	</tr>
	
	<cfloop index="prodIndx" from="1" to="#stUnKnowProducts.Count#" step="1">	
		<CFSET currentrowIndex = currentrowIndex + 1>
		<CFSET CurrentProduct = evaluate("stUnKnowProducts.Product_#prodIndx#")>
		
			<CFIF ShowProductsInGroupLevel EQ 1>
				<cfset useLakebaseForgetProductData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_hierarchy")>
<cfif useLakebaseForgetProductData>
	<cftry>
		<cfset getProductData = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_hierarchy", {
				"product_hierarchy_id" = "eq.#CurrentProduct.PRODUCT_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProductData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProductData>
<CFQUERY NAME="getProductData" DATASOURCE="#Application.Datasource#">
					SELECT * FROM Product_Hierarchy
					WHERE Product_Hierarchy_ID = '#CurrentProduct.PRODUCT_ID#'
				</CFQUERY>
</cfif>													
			<CFELSE>
				<cfquery name="getProductData" datasource="#Application.Datasource#">
					SELECT	BB_Unknown_Product_Item_Number Item, 
							BB_Unknown_Product_Item_Number UPC, 
							BB_Unknown_Product_Description Description, 
							1 Net_Weight, 
							'NA' Brand_Name
					FROM    Billback_Product 
					WHERE	Billback_Product_ID = 	 '#CurrentProduct.Billback_Product_ID#'
					ORDER BY Item, UPC, Description
				</cfquery>													
			</CFIF>
			
			<cfset tmpprodCust = CurrentProduct.PRODUCT_ID & "|" & CurrentProduct.distributor_id_earned>
				<cfset bbDeviationManager = CreateObject("component", "components.billback.BillbackDeviationManager").init() />
				<cfset getCustData = bbDeviationManager.getDistributorInfo(CurrentProduct.distributor_id_earned) />
			<!--- Dev Note: BSD 12092 Commented out this line because 
			      it added a duplicate Product ID to the temp_ExistingProductList_On_Program 
			      form field and would not remove it from the list of products if you
			      tried to delete.
			      
			      CFSET FORM.temp_ExistingProductList_On_Program = listappend(FORM.temp_ExistingProductList_On_Program, tmpprodCust)
			--->
			<cfif thisCust neq CurrentProduct.distributor_id_earned>
				<tr bgcolor="D2E1EE" >
					<td align="left" bgcolor="8B0000" colspan="100%" nowrap>
								<table border="0" style="border-bottom: 0;" cellpadding="0" cellspacing="0">
									<tr><cfoutput>
										<td style="border-bottom : 0" nowrap width="100%">
										<cfif trim(getCustData.Ship_To) neq "">
											<span style="color:white; font-weight: bold;">
													#getCustData.name#&nbsp;(#getCustData.Ship_To#)&nbsp;::&nbsp;#getCustData.city#, #getCustData.state#
											</span> 
										<cfelse>
											<span style="color:white; font-weight: bold;">No #application.returned_customer_setting.distributor_label_singular# </span> 
										</cfif>
										 </td>
										</cfoutput>
									</tr>
								</table>
						</td>
								<!--- <td colspan="3" bgcolor="D2E1EE">&nbsp;</td> --->
				</tr>
				<cfset thisCust = CurrentProduct.distributor_id_earned>
			</cfif>
			<cfif Evaluate(currentrowIndex mod 2) eq 0>
				<cfset tmpBgColor = "FFFFFF" />
			<cfelse>
				<cfset tmpBgColor = "ccffcc" />
			</cfif>
				<tr id="prdRow_#currentrowIndex#" BGCOLOR="#tmpBgColor#"><!---Product Start row--->
					<TD nowrap>
						<img bDelete="true" name="IMG_Delete_Scissor"  src="/images/scissor.gif" title="click here to delete this product" border="0" onClick="deleteThisProduct('#tmpprodCust#', '#tmpBgColor#', '#currentProgramObject.Count_ID#','#currentProgramObject.Program_ID#','1')" style="cursor: pointer;">
						<CFIF ShowProductsInGroupLevel EQ 1>#getProductData.Product_Hierarchy#</CFIF>
					</TD>
					<TD nowrap>
					<CFIF ShowProductsInGroupLevel NEQ 1>#getProductData.Item#<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1 AND len(trim(getProductData.UPC)) GT 0><br>#getProductData.UPC#</cfif></cfif><CFELSE>#getProductData.Product_Hierarchy_Name#</CFIF>
					<br>#getProductData.Description#
					</TD>
					<td>Extended<br>Amount</td>
					
					
					<CFSET thisRandomID = replace(createuuid(), "-", "_", "ALL")>
					<CFSET FoundUniqueID = 0>
					<cfloop condition="FoundUniqueID EQ 0">
						<CFIF listfind(listOfUsedIDS,thisRandomID) EQ 0>
							<CFSET listOfUsedIDS = listappend(listOfUsedIDS,thisRandomID)>
							<CFSET FoundUniqueID = 1>
						<CFELSE>
							<CFSET thisRandomID = replace(createuuid(), "-", "_", "ALL")>
						</CFIF>
					</CFLOOP>
					
						
		<CFSET LocalRateSum = 0>
		
			<!--- Explains amount --->
		
			<!------ Fixed ----->
			<cfif ShowFixed  OR NOT appSettings.getHideInvalidComponentTypesInBillbacks()>
			<TD style="border-bottom:solid silver 1px;" align="center" valign="center"  nowrap>
			<font size="#Dollar_Sign_Size#"><b>$</b></font><SPAN ID="RateCollection_#thisRandomID#" SumOfRates=0><input maxlength="10" style="border-left: 2 solid Black; border-right: 2 solid Black; border-top: 2 solid Black; border-bottom: 2 solid Black;  text-align : right;" 	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value" type="Text" size="7" value="<CFIF CurrentProduct.Rate_Fixed 	NEQ 0 OR len(trim(CurrentProduct.Rate_Fixed)) NEQ 0>#trim(CurrentProduct.Rate_Fixed)#</CFIF>" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" onBlur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#"></SPAN>
			
			</TD>												
			<CFIF isnumeric(trim(CurrentProduct.Rate_Fixed))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Fixed)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Fixed)></CFIF>
			<cfelse>
			<!--- The discount type got deleted --->
			<CFIF CurrentProduct.Rate_Fixed 	NEQ 0 OR len(trim(CurrentProduct.Rate_Fixed)) NEQ 0><SPAN ID="RateCollection_#thisRandomID#" SumOfRates=0><input type="hidden" name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value" value="0"></SPAN></CFIF>
			</cfif>
			<!--- Rebate --->
			<cfif ShowRebate OR NOT appSettings.getHideInvalidComponentTypesInBillbacks()>
			<TD style="border-bottom:solid silver 1px;" align="center"  nowrap><font size="#Dollar_Sign_Size#" ><b>$</b></font><SPAN ID="RateCollection_#thisRandomID#"><input maxlength="10" style="border-left: 2 solid Black; border-right: 2 solid Black; border-top: 2 solid Black; border-bottom: 2 solid Black;  text-align : right;" 	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value" type="Text" size="7" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" value="<CFIF CurrentProduct.Rate_Rebate 	NEQ 0 OR len(trim(CurrentProduct.Rate_Rebate)) NEQ 0>#trim(CurrentProduct.Rate_Rebate)#</CFIF>" 	onkeyup="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" onBlur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#"></SPAN>
			
			</TD>
			<CFIF isnumeric(trim(CurrentProduct.Rate_Rebate))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Rebate)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Rebate)></CFIF>
			<cfelse>
			<!--- The discount type got deleted --->
			<CFIF CurrentProduct.Rate_Rebate 	NEQ 0 OR len(trim(CurrentProduct.Rate_Rebate)) NEQ 0><SPAN ID="RateCollection_#thisRandomID#"><input type="hidden" name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value" value="0"></SPAN></CFIF>
			</cfif>
			<!--- Growth --->
			<cfif ShowGrowth OR NOT appSettings.getHideInvalidComponentTypesInBillbacks()>
			<TD style="border-bottom:solid silver 1px;" align="center"  nowrap><font size="#Dollar_Sign_Size#" ><b>$</b></font><SPAN ID="RateCollection_#thisRandomID#"><input maxlength="10" style="border-left: 2 solid Black; border-right: 2 solid Black; border-top: 2 solid Black; border-bottom: 2 solid Black;  text-align : right;" 	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value" type="Text" size="7" value="<CFIF CurrentProduct.Rate_Growth    NEQ 0 OR len(trim(CurrentProduct.Rate_Growth)) NEQ 0>#trim(CurrentProduct.Rate_Growth)#</CFIF>" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);"	onkeyup="clenseText(this, '.0123456789'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" onBlur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#"></SPAN>
			
			</TD>
			<CFIF isnumeric(trim(CurrentProduct.Rate_Growth))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Growth)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Growth)></CFIF>
			<cfelse>
			<!--- The discount type got deleted --->
			<CFIF CurrentProduct.Rate_Growth    NEQ 0 OR len(trim(CurrentProduct.Rate_Growth)) NEQ 0><SPAN ID="RateCollection_#thisRandomID#"><input type="hidden" name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value" value="0"></SPAN></CFIF>
			</cfif>
			<!--- Formula --->
			<cfif ShowFormulaPricing>
			<TD style="border-bottom:solid silver 1px;" align="center"  nowrap><font size="#Dollar_Sign_Size#" ><b>$</b></font><SPAN ID="RateCollection_#thisRandomID#"><input maxlength="10" style="border-left: 2 solid Black; border-right: 2 solid Black; border-top: 2 solid Black; border-bottom: 2 solid Black;  text-align : right;" 	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value" type="Text" size="7" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" value="<CFIF CurrentProduct.Rate_Formula 	NEQ 0 OR len(trim(CurrentProduct.Rate_Formula)) NEQ 0>#trim(CurrentProduct.Rate_Formula)#</CFIF>" 	onkeyup="clenseText(this, '.0123456789'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" onBlur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#"></SPAN>
			
			</TD>		
			<CFIF isnumeric(trim(CurrentProduct.Rate_Formula))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Formula)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Formula)></CFIF>
			<cfelse>
			<!--- The discount type got deleted --->
			<CFIF CurrentProduct.Rate_Formula 	NEQ 0 OR len(trim(CurrentProduct.Rate_Formula)) NEQ 0><SPAN ID="RateCollection_#thisRandomID#"><input type="hidden" name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value" value="0"></SPAN></CFIF>
			</cfif>
			
			<!--- Bid Request --->
			<cfif ShowBidRequest OR NOT appSettings.getHideInvalidComponentTypesInBillbacks()><CFSET BB_Current_Product_Type_ID = 11 />
			
			<TD style="border-bottom:solid silver 1px;" align="center"  nowrap> <font size="#Dollar_Sign_Size#" ><b>$</b></font><SPAN ID="RateCollection_#thisRandomID#"><input maxlength="10" style="border-left: 2 solid Black; border-right: 2 solid Black; border-top: 2 solid Black; border-bottom: 2 solid Black;  text-align : right;" 	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_#BB_Current_Product_Type_ID#_Value" type="Text" size="7" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" value="<CFIF CurrentProduct.Rate_BidRequest 	NEQ 0 OR len(trim(CurrentProduct.Rate_BidRequest)) NEQ 0>#trim(CurrentProduct.Rate_BidRequest)#</CFIF>" 	onkeyup="clenseText(this, '.0123456789'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" onBlur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#"></SPAN>
			
			</TD>		
			<CFIF isnumeric(trim(CurrentProduct.Rate_BidRequest))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_BidRequest)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_BidRequest)></CFIF>
			<cfelse>
			<!--- The discount type got deleted --->
			<CFIF CurrentProduct.Rate_BidRequest 	NEQ 0 OR len(trim(CurrentProduct.Rate_BidRequest)) NEQ 0><SPAN ID="RateCollection_#thisRandomID#"><input type="hidden" name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_11_Value" value="0"></SPAN></CFIF>
			</cfif>
			<!--- Claim adjustment --->
			<cfif ShowClaimAdjustment>
			<TD style="border-bottom:solid silver 1px;" align="center"  nowrap>
			<font size="#Dollar_Sign_Size#" ><b>$</b></font>
			<SPAN ID="RateCollection_#thisRandomID#" ed=0>
			<input maxlength="10" 
			style="border-left: 2 solid Black; border-right: 2 solid Black; border-top: 2 solid Black; border-bottom: 2 solid Black;  text-align : right;" 
			name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value" 
			type="Text" 
			size="7" 
			onfocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
			value="<CFIF CurrentProduct.Rate_ClaimAdjust 	NEQ 0 OR len(trim(CurrentProduct.Rate_ClaimAdjust)) NEQ 0>#trim(CurrentProduct.Rate_ClaimAdjust)#</CFIF>" 	
			onkeyup="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" 
			onblur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" 
			rcid="#thisRandomID#">
			</SPAN>
			</TD>
			<cfelse>
			<SPAN ID="RateCollection_#thisRandomID#" ed=0><input type="hidden" name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value" value=""></SPAN>
			</cfif>
			
			
					<CFSET temp_Vol_LB = 0>
					<CFSET temp_Vol_CS = 0>
					<cfset variables.temp_Total_Vol_CS = 0 />
					<cfset variables.temp_Total_Vol_LB = 0 />
					<CFIF CurrentProduct.Volume_UOM EQ 2>
						<CFSET temp_Vol_LB = trim(numberformat(CurrentProduct.Volume, '_.__'))>
						<CFSET temp_Vol_CS = 0>
						<CFSET variables.temp_Total_Vol_LB = trim(numberformat(CurrentProduct.Volume, '_.__')) />
						<CFSET variables.temp_Total_Vol_CS = temp_Vol_LB / getProductData.Net_Weight />
						<CFSET variables.temp_Total_Vol_CS = trim(numberformat(variables.temp_Total_Vol_CS, '_.__')) />
					<CFELSE>
						<CFSET temp_Vol_CS = trim(numberformat(CurrentProduct.Volume, '_.__'))>
						<CFSET temp_Vol_LB = 0>
						<CFSET variables.temp_Total_Vol_CS = trim(numberformat(CurrentProduct.Volume, '_.__')) />
						<CFSET variables.temp_Total_Vol_LB = temp_Vol_CS * val(getProductData.Net_Weight) />
						<CFSET variables.temp_Total_Vol_LB = trim(numberformat(variables.temp_Total_Vol_LB, '_.__')) />
					</CFIF>
		
		<TD nowrap><SPAN id="VolumeCollectionErrorSpan"></SPAN>
		<!--- The volume text box has a few ID's associated with it.The ones starting with the word "Err" are for displaying error messages. 
				In the Onchange event below for UOMcollection , we use firstchild.lastchild bcoz the "VolumeCollection" id is the last id below (the spans are one inside the other) 
				and is being used for changing the UOM's --->
		<span id="VolumeCollection" rcid="#thisRandomID#">
		<span id="Err_ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume"></span><span id="Err_Percent_ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume"></span>
		<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume" style="border-left: 2 solid black; border-right: 2 solid black; border-top: 2 solid black; border-bottom: 2 solid black; color: black; text-align : right;" type="text" size="7" maxlength="10" value="<CFIF len(trim(CurrentProduct.Volume)) GT 0>#trim(NumberFormat(CurrentProduct.Volume, '_.__'))#</CFIF>" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this); " onBlur="TwoDecimalsOnBlur(this); resetLocalVolume(this,'ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_UOM');propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#" TOTAL_VOL_LB="#variables.temp_Total_Vol_LB#" TOTAL_VOL_CS="#variables.temp_Total_Vol_CS#" NET_WEIGHT="#trim(getProductData.Net_Weight)#"></span>
		<span id="UOMCollection">
		<cf_uom_dropdown
			company_main_id			=	""
			default_option_on		=	""
			default_option_text		=	""
			default_option_value	=	""
			dropdown_name			=	"ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_UOM"
			option_text_abbreviated	=	"1"
			plural_uom_display		=	"1"
			product_type_id			=	""
			program_template_id		=	""
			selected_uom_id			=	"#CurrentProduct.Volume_UOM#"
			text_before_tag_close	=	""
			uom_id_exclusion_list	=	"3"
			uom_id_inclusion_list	=	""
			onchange				= 	"resetLocalVolume(document.all.ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume, ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_UOM);"
			
		>
		</span>
		</TD>
		<CFIF isnumeric(trim(CurrentProduct.Volume))><CFSET Total_Of_Volume = Total_Of_Volume + trim(CurrentProduct.Volume)></CFIF>
			
			<CFIF isnumeric(trim(CurrentProduct.Rate_ClaimAdjust))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_ClaimAdjust)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_ClaimAdjust)></CFIF>
		
			<Script>
			RateCollection_#thisRandomID#[0].SumOfRates="#trim(NumberFormat(LocalRateSum,'___________________.__'))#"
			</SCRIPT>			
			
			<!---Adds spaces to the end of the table to make it look nice --->
			<cfloop	from="0" to="#EndSpaces#" index="Count" step="1">
			<td>&nbsp;</td>
			</cfloop>					
			<td>&nbsp; </td>
		
		</TR><!---Product End row--->
	
	</CFLOOP>
</cfoutput>

