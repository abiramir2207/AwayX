	<CFIF GetSettings.Generic_Type IS "Bid Request" and GetSettings.Discount_BidRequest EQ 1>
		<!---get bid request data--->
<CFIF appSettings.getBidRequestComponentsOn() EQ 0>
		<cfset bidReqProdsFromDB = CreateObject("component", "components.programs.bid_request.BidRequestProductManager").getBidRequestProductsFromDb(CSLGetContractInfo.Contract_Main_ID) />
		<cfset bidReqProds = bidReqProdsFromDB.getBidRequestProducts() />
			<!---display bid requests only if they exist--->
			<cfif ArrayLen(bidReqProds)>
				<cfoutput>
			<TR>
				<TD COLSPAN="100%">
					<BR>
					<B><FONT SIZE="2" COLOR="Navy">Proposal</FONT></B>
					<cfif appSettings.getPaymentCycleAtDiscountType()>
					<B><br>Payment Cycle</B>:
					<cf_payment_cycle_selection
						Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
						Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
						discount_Type_ID = "5"
						Selected_Payment_Cycle_ID = ""
						Action = "display"
						>
					</cfif>
					<HR COLOR="Navy">
						
					<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
						<!--- TABLE HEADERS --->
						<TR BGCOLOR="##FFCE84" VALIGN="bottom">
<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>											<TD ID="header">
								<B>#application.returned_customer_setting.upc_label#</B>
							</td></cfif></cfif>
						<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
							<TD ID="header">
								<B>#application.returned_customer_setting.item_label#</B>
							</TD>
						</cfif>
							<TD ID="header">
								<B>DESCRIPTION /</B>
								<cfif displayGroupType>
								<BR><B><cfoutput>#displayGroupTypeDesc#</cfoutput></B>
								<cfelse>
								<br><strong>PACK SIZE</strong>
								</cfif>
							</TD>
							<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
							<TD ID="header"><B>Similar Product</B></TD>
							</cfif>
							<TD ID="header">
								<B>UOM</B>
							</TD>
							<TD ID="header">
								<B>Base Price</B>
							</TD>
							<TD ID="header">
								<B>Allowance</B>
							</TD>
							<TD ID="header">
								<B>Net</B>
							</TD>
							<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1> 
								<TD ID="header">
									<B>Won/Lost</B>
								</TD>
							</cfif>
						</tr>

						<cfloop index="i" from="1" to="#ArrayLen(bidReqProds)#">
							<tr>
								<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
									<cfif application.returned_customer_setting.upc_switch EQ 1><td>#bidReqProds[i].getUpc()#</td></cfif>
								</cfif>
								<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
								<td>#bidReqProds[i].getItem()#</td>
								</cfif>
								<td>
									#bidReqProds[i].getDesc()#
									<cfif displayGroupType EQ 3>
									<BR>#bidReqProds[i].getQBrand()#
									<cfelseif displayGroupType EQ 1>
									<BR>#bidReqProds[i].getTypeCode()#
									</cfif>
									<cfif NOT displayGroupType>
									#bidReqProds[i].getPackSize()#
									</cfif>
								</td>
								<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
									<td>		
										<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(CSLGetContractInfo.Contract_Main_ID,bidReqProds[i].getItemMasterID())>
										<cfif SimilarExistingProduct.Recordcount neq 0>Yes<cfelse>No</cfif>
									</td>
								</cfif>
								<td>#request.app_general_functions.getUomDesc(bidReqProds[i].getUom(),0)#</td>
								<td><cfif not summaryView>
										#NumberFormat(bidReqProds[i].getDefaultPrice() , ViewProgramManager.getRateFormatMask())#
										<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
											<br>#NumberFormat((bidReqProds[i].getDefaultPrice()*CSLGetContractInfo.currency_conversion_factor) , ViewProgramManager.getRateFormatMask())#
										</cfif>
									<cfelse>
										-
									</cfif>
								</td>
								<td>
									<cfif not summaryView>
										#NumberFormat(bidReqProds[i].getAllowance() , ViewProgramManager.getRateFormatMask())#
										<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
											<br>#NumberFormat((bidReqProds[i].getAllowance()*CSLGetContractInfo.currency_conversion_factor) , ViewProgramManager.getRateFormatMask())#
										</cfif>										
									<cfelse>
										-
									</cfif>
								</td>
								<td>
									<cfif not summaryView>
										#NumberFormat(bidReqProds[i].getNet() , ViewProgramManager.getRateFormatMask())#
										<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
											<br>#NumberFormat((bidReqProds[i].getNet()*CSLGetContractInfo.currency_conversion_factor) , ViewProgramManager.getRateFormatMask())#
										</cfif>										
									<cfelse>
										-
									</cfif>
								</td>
								<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1> 
									<td>
										<cfif trim(bidReqObj.getStatus()) eq 1>
											Pending...
										<cfelse>
											<cfif bidReqProds[i].getWon()>won<cfelse>lost</cfif>
										</cfif>
									</td>
								</cfif>
							</tr>
						</cfloop>
					</TABLE>			
				</TD>
					
			</TR>
			</cfoutput>
			<!------ Start Clause Code ----->
			<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 2, 10)>
			<cfif getProgramClause.recordCount>
				<TR>
					<TD COLSPAN="100%">
					<BR>
					<!------ Rebate Clauses ----->
					<cfinclude template="/Clause_Library/clause_program_display.cfm">		
					</TD>
				</TR>
			</cfif>
			<!------ End  Clause Code ----->
		</cfif>
		<cfelse>
		<!---BJF: Please note that this is the function getBidRequestProducts not the query qGetBidRequestProducts in the function getBidRequestProductsFromDb --->
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 or GetSettings.display_BidRequest_basesales EQ 1>
<cfset displaybasesales = 1>
<cfelse>
<cfset displaybasesales = 0>
</cfif>
	<cfset Get_Bidrequest_Products = bidRequestProdMan.getBidRequestProducts(programId=CSLGetContractInfo.contract_main_id,displayGroupType=displayGroupType,displayprogram=1,displaybasesales=displaybasesales)>
	<cfset getcompNames  = bidRequestProdMan.getAllBidrequestComponents(CSLGetContractInfo.Contract_Main_ID)>
				<TR>
				<TD COLSPAN="100%">
				<table width="100%">
				<td width="50%"><B><FONT SIZE="2" COLOR="Navy">Bid Fixed Pricing</FONT></B>
				</td>
				<td width="50%" align="right"><cfif CSLGetContractInfo.contract_status_type_idx GT 2 and CSLGetContractInfo.saved_bidrequest_basesales EQ 1> <A HREF="/common_files/contracts/bid_request/display_basesales.cfm?Program_ID=<cfoutput>#CSL_Contract_Main_ID#</cfoutput>" onclick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;">[Click here to view base sales at the time of approval]</A> </cfif> 
				</td>
				</table>
					<HR COLOR="Navy">
					<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0">
						<!--- TABLE HEADERS --->
						<cfoutput><TR BGCOLOR="##FFCE84" VALIGN="bottom">
							<TR BGCOLOR="##FFCE84" VALIGN="bottom">
						<TD ID="header" WIDTH="75" valign="top"><B>
							<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
								<cfif application.returned_customer_setting.upc_switch EQ 1>#application.returned_customer_setting.upc_label#/</cfif>
							</cfif>
							<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
							#application.returned_customer_setting.item_label#
							</cfif>
							</B>
						</TD>
						<TD ID="header" WIDTH="200" valign="top"><B>DESCRIPTION</B><cfif displayGroupType and not summaryView>
								/	<strong>#displayGroupTypeDesc#</strong>
								<cfelse><strong>/PACK SIZE</strong></cfif></TD>
							<TD ID="header" WIDTH="20" valign="top"><B>Spec</B></TD>
							<CFLOOP query="getcompNames">
								<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_BidRequest_basesales EQ 1>
							<TD ID="header" valign="top"><strong>Base<br>Sales</strong></TD>
							</cfif>
							<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_BidRequest_basesales EQ 1>
							<TD ID="header" valign="top"><strong>Discount</strong></TD>
							</cfif>
								<TD ID="header" valign="top"><B><cfoutput>#getcompNames.Program_Bidrequest_Component_Name#</cfoutput>
								<br>#templateManager.getPaymentPaidToTypeDesc(paidToID = getcompNames.Program_Bidrequest_Component_Paid_to, paidToDesc="")#</B></TD>
					<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_BidRequest_basesales EQ 1>
							<TD ID="header" valign="top"><strong>Discount%</strong></TD>
					</cfif>
								</CFLOOP>	
							<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5> 
							<TD ID="header" valign="top">
								<B>Won/Lost</B>
							</TD>
							</cfif>
							</tr></cfoutput>
							<CFOUTPUT QUERY="Get_Bidrequest_Products" group="BSA_Foodservice_Items_Master_ID">
							<CFSET item_num= Get_Bidrequest_Products.BSA_Foodservice_Items_Master_ID>
			<cfsilent>
			<cfif GetSettings.display_BidRequest_basesales EQ 1 OR appsettings.getshowfixedpriceadditionalfields() EQ 1>
			<cfif appSettings.getBidRequestUsePriceByDate() EQ 1>
				<cfif bIsIndirectBid>
					<cfset priceListId = bidRequestProdMan.getPriceListId("GIL98") />
				<cfelse>
					<cfset priceListId = bidRequestProdMan.getPriceListId() />
				</cfif>	
				<cfparam name="priceIdNull" default="no" />
				<cfif trim(priceListId) eq "">
					<cfset priceIdNull = "yes" />
				</cfif>
				<cfset stPrice = bidRequestProdMan.getPrice(BSA_Foodservice_Items_Master_ID, priceListId, priceIdNull, CSLGetContractInfo.contract_start_date, bIsIndirectBid) />
				<cfset FOB_CS_Price = stPrice.CSPrice />
				<cfset FOB_LB_Price = stPrice.LBPrice />
			<cfelse>
				<cfif appSettings.getUseItemCustPrice() EQ 1>
				<cfset getItemCustPrice = bidRequestProdMan.getItemCustPrice(BSA_Foodservice_Items_Master_ID,CSLGetContractInfo.contract_main_id) />
				<cfset FOB_CS_Price = getItemCustPrice.FOB_CS_Price>
				<cfset FOB_LB_Price = getItemCustPrice.FOB_LB_Price>
				<cfset DEL_CS_Price = getItemCustPrice.DEL_CS_Price>
				<cfset DEl_LB_Price = getItemCustPrice.DEL_LB_Price>
				<cfelse>
				<cfset FOB_CS_Price = Get_Bidrequest_Products.FOB_CS_Price>
				<cfset FOB_LB_Price = Get_Bidrequest_Products.FOB_LB_Price>
				<cfset DEL_CS_Price = Get_Bidrequest_Products.DEL_CS_Price>
				<cfset DEl_LB_Price = Get_Bidrequest_Products.DEL_LB_Price>
				</cfif>
			</cfif>
			</cfif>
			</cfsilent>
							<!--- DATA OUTPUT --->
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#Get_Bidrequest_Products.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
							<TD ID="">							
								<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
									<cfif application.returned_customer_setting.upc_switch EQ 1>#Get_Bidrequest_Products.UPC#<br></cfif>
								</cfif>
								<cfif appSettings.get_Setting('Display_Item_No') eq '1'>#Get_Bidrequest_Products.ITEM#</cfif>
							</TD>
							<TD ID="">#Get_Bidrequest_Products.Description#<cfif displayGroupType><br>#DisplayGroupName#<cfelse><!--- Add pack size D9582 ---><cfif len(trim(Get_Bidrequest_Products.Pack_Size)) GT 0><br>#Get_Bidrequest_Products.Pack_Size# #Get_Bidrequest_Products.Pack_Size_UOM# </cfif>
</cfif></TD>
							<TD ID="">#Get_Bidrequest_Products.Bid_Request_Key#</TD>
							<CFLOOP query="getcompNames">
						<cfsilent>
							<cfset getbidrequestproductprice  = bidRequestProdMan.getbidrequestproductprice(Get_Bidrequest_Products,getcompNames.Program_Bidrequest_Component_Id,item_num)>
				<cfset allow = 0>
				<cfset baseprice = 0>
				<cfset discount_percent = 0>
				<cfif GetSettings.display_BidRequest_basesales EQ 1 OR appsettings.getshowfixedpriceadditionalfields() EQ 1>
					<cfif getbidrequestproductprice.Bidrequest_Price_Value NEQ 0 and getbidrequestproductprice.Bidrequest_Price_Value NEQ "">
					<cfif appSettings.getBidRequestUsePriceByDate() EQ 1>
						<cfif getbidrequestproductprice.Unit_Of_Measure_ID EQ 2>
						<cfset baseprice = FOB_LB_Price>
						<cfset allow = FOB_LB_Price - getbidrequestproductprice.Bidrequest_Price_Value>
						<cfif FOB_LB_Price NEQ 0>
						<cfset discount_percent = ((FOB_LB_Price - getbidrequestproductprice.Bidrequest_Price_Value)/FOB_LB_Price) * 100>
						</cfif>
						<cfelse>
						<cfset baseprice = FOB_CS_Price>
						<cfset allow = FOB_CS_Price - getbidrequestproductprice.Bidrequest_Price_Value>
						<cfif FOB_CS_Price NEQ 0>
						<cfset discount_percent = ((FOB_CS_Price - getbidrequestproductprice.Bidrequest_Price_Value)/FOB_CS_Price) * 100>
						</cfif>
						</cfif>
					<cfelse>
						<cfif getbidrequestproductprice.Unit_Of_Measure_ID EQ 2>
						<cfif getcompNames.bidrequest_component_type EQ 2>
						<cfset baseprice = FOB_LB_Price>
						<cfset allow = FOB_LB_Price - getbidrequestproductprice.Bidrequest_Price_Value>
						<cfif FOB_LB_Price NEQ 0>
						<cfset discount_percent = ((FOB_LB_Price - getbidrequestproductprice.Bidrequest_Price_Value)/FOB_LB_Price) * 100>
						</cfif>
						<cfelse>
						<cfset baseprice = DEL_LB_Price>
						<cfset allow = DEL_LB_Price - getbidrequestproductprice.Bidrequest_Price_Value>
						<cfif DEL_LB_Price NEQ 0>
						<cfset discount_percent = ((DEL_LB_Price - getbidrequestproductprice.Bidrequest_Price_Value)/DEL_LB_Price) * 100>
						</cfif>
						</cfif>
						<cfelse>
						<cfif getcompNames.bidrequest_component_type EQ 2>
						<cfset baseprice = FOB_CS_Price>
						<cfif getbidrequestproductprice.Bidrequest_Price_Value NEQ "">
						<cfset allow = FOB_CS_Price - getbidrequestproductprice.Bidrequest_Price_Value>
						<cfelse>
						<cfset allow = 0>
						</cfif>
						<cfif FOB_CS_Price NEQ 0>
						<cfset discount_percent = ((FOB_CS_Price - getbidrequestproductprice.Bidrequest_Price_Value)/FOB_CS_Price) * 100>
						</cfif>
						<cfelse>
						<cfset baseprice = DEL_CS_Price>
						<cfif getbidrequestproductprice.Bidrequest_Price_Value NEQ "">
						<cfset allow = DEL_CS_Price - getbidrequestproductprice.Bidrequest_Price_Value>
						<cfelse>
						<cfset allow = 0>
						</cfif>
						<cfif DEL_CS_Price NEQ 0>
						<cfset discount_percent = ((DEL_CS_Price - getbidrequestproductprice.Bidrequest_Price_Value)/DEL_CS_Price) * 100>
						</cfif>
						</cfif>
						</cfif>
					</cfif>
					</cfif>
				</cfif>
					</cfsilent>
					<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_BidRequest_basesales EQ 1>
						<TD>
						#trim(numberformat(baseprice, ViewProgramManager.getRateFormatMask()))#
						</TD>
					</cfif>
					<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_BidRequest_basesales EQ 1>
						<td>
						<cfif allow LT 0>
						<cfset allowneg = allow * -1>
						#Negativeformat(numberformat(allowneg, ViewProgramManager.getRateFormatMask()))#
						<cfelse>
						#trim(numberformat(allow, ViewProgramManager.getRateFormatMask()))#
						</cfif>
						</td>
					</cfif>
							<TD ID="">
						<cfif getbidrequestproductprice.Bidrequest_Price_Value NEQ 0 and getbidrequestproductprice.Bidrequest_Price_Value NEQ "">
					#trim(numberformat(getbidrequestproductprice.Bidrequest_Price_Value, ViewProgramManager.getRateFormatMask()))# per #left(getbidrequestproductprice.Abbreviation, 2)#<cfelse>&nbsp;</cfif></TD>
			<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_BidRequest_basesales EQ 1>
			<td>
				<CFIF discount_percent LT 0>
				<cfset discountperneg = discount_percent * -1>
					#NegativeFormat(numberformat(discountperneg,"____.__"))#%	
				<CFELSE>
					#numberformat(discount_percent,"____.__")#%
				</CFIF>
			</cfif>
</CFLOOP>
							<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5> 
							<TD><cfif trim(bidReqObj.getStatus()) eq 1>
										Pending...
									<cfelse>
										<cfif won>won<cfelse>lost</cfif>
									</cfif></TD>
							</cfif>
							</tr>
							</cfoutput>
							</TABLE>			
				</TD>
					
			</TR>
			<!------ Start Clause Code ----->
			<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 2, 10)>
			<cfif getProgramClause.recordCount>
				<TR>
					<TD COLSPAN="100%">
					<BR>
					<!------ Rebate Clauses ----->
					<cfinclude template="/Clause_Library/clause_program_display.cfm">		
					</TD>
				</TR>
			</cfif>
		</cfif>
					
	</CFIF>
