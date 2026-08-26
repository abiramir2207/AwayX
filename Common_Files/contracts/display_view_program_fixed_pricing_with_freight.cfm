	<CFIF GetSettings.Discount_Fixed_Prices EQ 1>
<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 or GetSettings.display_FixedPrice_basesales EQ 1>
<cfset displaybasesales = 1>
<cfelse>
<cfset displaybasesales = 0>
</cfif>
			<cfif List_Of_Contract_Main_IDs neq "">
				<cfset getFixedPriceProducts  = ViewProgramManager.getFixedPriceProducts(List_Of_Contract_Main_IDs, displayGroupType,1,displaybasesales,appSettings.getBidRequestUsePriceByDate(),
appSettings.getUseItemCustPrice(),getsettings.Discount_Fixed_Prices_Freight)>
			<cfelse>
				<cfset getFixedPriceProducts  = ViewProgramManager.getFixedPriceProducts(CSLGetContractInfo.Contract_Main_ID, displayGroupType,0,displaybasesales,appSettings.getBidRequestUsePriceByDate(),appSettings.getUseItemCustPrice(),getsettings.Discount_Fixed_Prices_Freight)>
			</cfif>

			<cfif getFixedPriceProducts.recordcount GT 0>
				<cfif appSettings.getfixedcomponents_on()>
<!--- List_Of_Contract_Main_IDs will be always blank if GetSettings.Date_Exclusions_ON eq 0 --->
					<cfif List_Of_Contract_Main_IDs eq "">
						<cfset getcompNames  = ViewProgramManager.getcompNames(CSLGetContractInfo.Contract_Main_ID,"0")>
					<cfelse>
						<cfset getcompNames  = ViewProgramManager.getcompNames(List_Of_Contract_Main_IDs,"1")>
					</cfif>
				</cfif>
<CFIF getFixedPriceProducts.recordcount GT 0>
	<cfoutput><TR>
<TD COLSPAN="100%">
<table width="100%"><tr>
<td width="50%"><B><FONT SIZE="2" COLOR="Navy">#ucase(Application.FixedPriceLabel)#</FONT></B></td><!--- 29856:labels for Fixed Price, Rebate, Lump Sum, Growth --->
<td width="50%" align="right"><cfif CSLGetContractInfo.contract_status_type_idx GT 2 and (CSLGetContractInfo.saved_bidrequest_basesales EQ 1 and (appsettings.getshowfixedpriceadditionalfields() EQ 1 OR getsettings.display_FixedPrice_basesales EQ 1))> <A HREF="/common_files/contracts/display_fixedprice_basesales.cfm?Program_ID=<cfoutput>#CSL_Contract_Main_ID#</cfoutput>&List_Of_Contract_Main_IDs=<cfoutput>#List_Of_Contract_Main_IDs#</cfoutput>" onclick="NewWindow(this.href,'help','800','600','Yes', 'No');return false;">[Click here to view base sales at the time of approval]</A> </cfif></td>
</tr></table>
				<HR COLOR="Navy">
	</cfoutput>

		
				<!--- Dev Note: KAL; 11209 - Component code and description are not working correctly - This logic is obselete as you can add multiple components --->
				<!--- <span><font SIZE="1" COLOR="red">*The Prices Below Are <CFIF CSLGetContractInfo.Fixed_Price_Rebate_Type EQ 1>Net Delivered<CFELSE>FOB</CFIF><cfif trim(CSLGetContractInfo.Generic_Type) EQ "Operator-Deviated Pricing"> for the #application.returned_customer_setting.distributor_label_singular# and do not include their mark-up</cfif></font></span> --->
				<cfif appSettings.getPaymentCycleAtDiscountType()>
				<br><B>Payment Cycle</B>:
				<cf_payment_cycle_selection
					Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
					Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
					discount_Type_ID = "1"
					Selected_Payment_Cycle_ID = ""
					Action = "display"
					>
				</cfif>
					<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0" border="0">
					<!--- TABLE HEADERS --->
					
					<cfloop query="getcompNames">
                     <cfset compNameID = Program_Fixed_Component_ID />
					 <cfset paidTo  = Fixed_Component_Paid_to />
					 <cfset compID = Program_Fixed_Component_Name_Id />
					 
					<cfoutput>
					<THEAD>
					<TR BGCOLOR="##FFCE84" VALIGN="bottom">
                         <TD ID="header" WIDTH="75" valign="top"><strong>#application.returned_customer_setting.distributor_label_singular#</strong></TD>

						<TD ID="header" WIDTH="75" valign="top"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>UPC/</cfif></cfif>ITEM</B></TD>
						<TD ID="header" WIDTH="250" valign="top"><B>DESCRIPTION</B><cfif displayGroupType>/ <B>#displayGroupTypeDesc#</B></cfif></TD>
						<cfif summaryView>
							<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5>
								<TD ID="header" WIDTH="70" valign="top"><B>Won/Lost</B></TD>
							</cfif>
							<TD ID="header" WIDTH="75" valign="top"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>UPC/</cfif></cfif>ITEM</B></TD>
							<TD ID="header" WIDTH="250" valign="top"><B>DESCRIPTION</B><cfif displayGroupType>/ <B>#displayGroupTypeDesc#</B></cfif></TD>
							<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5>
								<TD ID="header" WIDTH="60" valign="top"><B>Won/Lost</B></TD>
							</cfif>
						</cfif>
						<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
							<TD ID="header" WIDTH="35" valign="top"><B>Similar Product</B></TD>
						</cfif>
						<cfif not summaryView>
							<cfif GetSettings.Date_Exclusions_ON EQ 1>
								<TD ID="header" valign="top"><B>Date</B></TD>
							</cfif>
							<cfset CompList ="">
							<cfif appSettings.getfixedcomponents_on()>		
				

								<cfif GetSettings.Date_Exclusions_ON EQ 0 OR getcompNames.Contract_Main_ID eq CSLGetContractInfo.Contract_Main_ID>					
									<!--- Do not repeat the Component Entries (commented out the code) --->
									<cfif ListFindNoCase(CompList,getcompNames.Program_Fixed_Component_ID) eq 0>
										<cfset CompList = ListAppend(CompList,getcompNames.Program_Fixed_Component_ID)>
									</cfif>
								</cfif>

								<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_FixedPrice_basesales EQ 1>
									<!--- D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable--->
							<TD ID="header" valign="top"><strong>#appSettings.getBaseSaleLabel()#</strong></TD>
								</cfif>
								<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_FixedPrice_basesales EQ 1>
							<TD ID="header" valign="top"><strong><cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>Discount<cfelse>Allow</cfif></strong></TD>
							</cfif>
								<TD ID="header" valign="top"><B><cfoutput><cfif Program_Summary_Display_Name is "">#Program_Fixed_Component_Name#<cfelse>#Program_Summary_Display_Name#</cfif></cfoutput>
								</TD>
								<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_FixedPrice_basesales EQ 1>
							<TD ID="header" valign="top"><strong>Discount%</strong></TD>
							</cfif>

		<!---<TD ID="header" valign="top"><strong>qFreight/LB</strong></TD>--->
		<TD ID="header" valign="top"><strong>#application.returned_customer_setting.distributor_label_singular# Rate</strong></TD>
		
									
								<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5>
							<TD ID="header" valign="top"><B>Won/Lost</B></TD>
								</cfif>

							<cfelse>
								<TD ID="header" WIDTH="130" ALIGN="RIGHT" valign="top"><B>Price</B></TD>
							</cfif>
						</cfif>
					</TR>
					</THEAD>
					</cfoutput>
					<!--- begin DATA OUTPUT --->
					<cfif GetSettings.Date_Exclusions_ON eq 0>
						<cfset List_Of_Contract_Main_IDs = CSLGetContractInfo.Contract_Main_ID>
					<cfelse>
						<cfset List_Of_Contract_Main_IDs = Replace(List_Of_Contract_Main_IDs,"'","","ALL")>
					</cfif>
					<!--- Loop through the different products and different Contract IDs one by one --->
					<cfset LoopCount = 0>
					<cfif not summaryView>
			<CFOUTPUT QUERY="getFixedPriceProducts" group="customer_id">
			<cfset customer_id = getFixedPriceProducts.customer_id>
            
			
			<cfif customer_id NEQ "">
			<TR  BGCOLOR="FFFACD" VALIGN="top">
			<TD colspan="100%">
			<strong>#getFixedPriceProducts.shr_ship_to# :#getFixedPriceProducts.name#</strong>
			</TD>
			</TR>
			</cfif>
			<CFOUTPUT group="BSA_Foodservice_Items_Master_ID">
			<cfset product_id = getFixedPriceProducts.BSA_Foodservice_Items_Master_ID>   
			
			
			<cfif GetSettings.display_FixedPrice_basesales EQ 1 OR appsettings.getshowfixedpriceadditionalfields() EQ 1>
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
				<cfset FOB_CS_Price = getFixedPriceProducts.FOB_CS_Price>
				<cfset FOB_LB_Price = getFixedPriceProducts.FOB_LB_Price>
				<cfset DEL_CS_Price = getFixedPriceProducts.DEL_CS_Price>
				<cfset DEl_LB_Price = getFixedPriceProducts.DEL_LB_Price>
				</cfif>
			</cfif>
			</cfif>
							<cfset LoopCount =LoopCount + 1>
							<cfoutput group="CONTRACT_MAIN_ID">
							<cfset ContractID = getFixedPriceProducts.CONTRACT_MAIN_ID>
							<!--- <cfloop list="#List_Of_Contract_Main_IDs#" index="ContractID"> ---> 
							<CFSET item_num= getFixedPriceProducts.BSA_Foodservice_Items_Master_ID>
							<CFSET Contract_ID= getFixedPriceProducts.CONTRACT_MAIN_ID>
							<CFSET IsExclusionRevision= getFixedPriceProducts.IsExclusionRevision>
                            
							<TR  BGCOLOR="#IIf(LoopCount Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#getFixedPriceProducts.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
					<TD ID="" valign="top">&nbsp;</TD>
					
								<TD ID="">
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
										<cfif application.returned_customer_setting.upc_switch EQ 1>#getFixedPriceProducts.UPC#<br></cfif>
									</cfif>#getFixedPriceProducts.ITEM#&nbsp;
								</TD>
								<TD ID="">#getFixedPriceProducts.Description#
								<cfif displayGroupType and not summaryView>
								<br>	#DisplayGroupName#
								</cfif></TD>
								<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
								<TD ID="">		
								<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(CSLGetContractInfo.Contract_Main_ID,item_num)>
									<cfif SimilarExistingProduct.Recordcount neq 0>Yes<cfelse>No</cfif>
								</TD>
								</cfif>
							
							 <cfif not summaryView>
								<cfif appSettings.getfixedcomponents_on()>
								
								<cfset ContractDate = "">
								<cfset FixedPriceList = "">
							
								<cfif GetSettings.Date_Exclusions_ON EQ 0>
									<cfset TotalFixedComponentIDList =  ViewProgramManager.getFixedComponentIDs(ContractID,item_num)>						
									<!--- Get the fixedproductprice for the Different contracts, by passing the ContractID too in the  getfixedproductprice function --->
									<cfset getfixedproductprice  = ViewProgramManager.getfixedproductprice(getFixedPriceProducts,getcompNames.Program_Fixed_Component_ID,item_num,ContractID)>

									<cfelse>
				
										<cfset TotalFixedComponentIDList =  ViewProgramManager.getFixedComponentIDs(ContractID,item_num)>

										<cfset getfixedproductprice  = ViewProgramManager.getfixedproductprice(getFixedPriceProducts,getcompNames.Program_Fixed_Component_ID,item_num,ContractID)>
										<!--- Do not repeat the Date --->
										<cfif getfixedproductprice.Fixed_Price_Value NEQ "">																		
											<cfif getfixedproductprice.Contract_Start_Date&getfixedproductprice.Contract_End_Date neq ContractDate> 
												<cfset ContractDate = getfixedproductprice.Contract_Start_Date&getfixedproductprice.Contract_End_Date>
						
											<cfif getfixedproductprice.IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
											<TD>#DateFormat(getfixedproductprice.Contract_Start_Date,"MM/DD/YYYY")#<br/> #DateFormat(getfixedproductprice.Contract_End_Date,"MM/DD/YYYY")#</TD>
																		
											<cfelse>
										<TD ID="">

								<!--- If there are Date Exclusions --->	
								<cfif ListLen(List_Of_Contract_Main_IDs) GT 1>
								<!--- Show the Contract Start Date --->
								<cfif DECount EQ 0>
								#DateFormat(getDateExclusionprogramIDs.Contract_Start_Date, "MM/DD/YYYY")#<br /></cfif>
								<!--- Delete the ParentID from the list and loop through the date exclusion ID's (Loop through the years, Month and Days)--->
								<cfset Date_Exclusion_Contract_Main_IDs = ListDeleteAt(List_Of_Contract_Main_IDs,1)>
								<cfset DateExclusionDate = GenProgramManager.DateExclusionDates(Date_Exclusion_Contract_Main_IDs)>
								<cfloop query="DateExclusionDate">
									<cfloop from="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_Start_Date)#" to="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_End_Date)#" index="IndexYear">
										<cfloop from="1" to="12" index="IndexMonth">
											<cfloop from="1" to="31" index="IndexDay">		
												<cfset DayDate = "#IndexMonth#/#IndexDay#/#IndexYear#">
													<cfif IsDate(DayDate)>
														<!--- If the date in the loop matches the date exclusion start date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date) eq 0>
															<!--- If it's not the first row --->
															<cfif DateExclusionDate.currentrow neq 1>
																<!--- If there is a days difference in the previous date exclusion end date and current date exclusion start date --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date[DateExclusionDate.currentrow-1]) GT 0>
																#DateFormat(Before_Date_Exclusion_Contract_Start_Date, "MM/DD/YYYY")#<br /><br />
																</cfif>
															 <cfelse>
																<cfif DECount EQ 0>#DateFormat(DateAdd('d',-1,Contract_Start_Date),"MM/DD/YYYY")#<br /><br /></cfif>
															</cfif> 
														</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
														 <cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														<!--- If it's not the last row --->
															<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														<!--- If there is a days difference in the current date exclusion end date and the following date exclusion start date, get that info --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																	#DateFormat(After_Date_Exclusion_Contract_End_Date, "MM/DD/YYYY")#<br />
																	#DateFormat(Before_Date_Exclusion_Contract_Start_Date[DateExclusionDate.currentrow+1], "MM/DD/YYYY")#<br /><br />			
																</cfif>
													
															<cfelse>
														
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
																<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																#DateFormat(DateAdd('d',1,Contract_End_Date),"MM/DD/YYYY")#<br />
																#DateFormat(getDateExclusionprogramIDs.Contract_End_Date, "MM/DD/YYYY")#
																</cfif>
													</cfif>
													</cfif>
												</cfif>
											</cfloop>
										</cfloop>
									</cfloop>
								</cfloop>
								</cfif>
								</TD>
										</cfif>
										</cfif>
										</cfif>
									</cfif>

			 <cfsilent>

		   <cfset getcurrentfixedproductprice  = ViewProgramManager.getfixedproductprice(getFixedPriceProducts,compNameID,item_num,ContractID,paidTo)>
                 
			<cfif getcurrentfixedproductprice.recordcount EQ 0>
				<cfset currentfixedvalue = 0>
			<cfelse>
				<cfif getcurrentfixedproductprice.Fixed_Price_Value EQ "">
					<cfset currentfixedvalue = 0>
          		<cfelse>
					<cfset currentfixedvalue = getcurrentfixedproductprice.Fixed_Price_Value>
					<cfset freightRate = getcurrentfixedproductprice.Freight_Rate />
				</cfif>
			</cfif>

			<cfif GetSettings.display_FixedPrice_basesales EQ 1 OR appsettings.getshowfixedpriceadditionalfields() EQ 1>
				<cfset allow = 0>
				<cfset baseprice = 0>
				<cfset discount_percent = 0>
					<cfif currentfixedvalue NEQ 0>
					<cfif appSettings.getBidRequestUsePriceByDate() EQ 1>
						<cfif getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 2>
						<cfset baseprice = FOB_LB_Price>
						<cfset allow = FOB_LB_Price - currentfixedvalue>
						<cfif FOB_LB_Price NEQ 0>
						<cfset discount_percent = ((FOB_LB_Price - currentfixedvalue)/FOB_LB_Price) * 100>
						</cfif>
						<cfelse>
						<cfset baseprice = FOB_CS_Price>
						<cfset allow = FOB_CS_Price - currentfixedvalue>
						<cfif FOB_CS_Price NEQ 0>
						<cfset discount_percent = ((FOB_CS_Price - currentfixedvalue)/FOB_CS_Price) * 100>
						</cfif>
						</cfif>
					<cfelse>
						<cfif getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 2>
						<cfif getcompNames.Fixed_component_type EQ 2>
						<cfset baseprice = FOB_LB_Price>
						<cfset allow = FOB_LB_Price - currentfixedvalue>
						<cfif FOB_LB_Price NEQ 0>
						<cfset discount_percent = ((FOB_LB_Price - currentfixedvalue)/FOB_LB_Price) * 100>
						</cfif>
						<cfelse>
						<cfset baseprice = DEL_LB_Price>
						<cfset allow = DEL_LB_Price - currentfixedvalue>
						<cfif DEL_LB_Price NEQ 0>
						<cfset discount_percent = ((DEL_LB_Price - currentfixedvalue)/DEL_LB_Price) * 100>
						</cfif>
						</cfif>
						<cfelse>
						<cfif getcompNames.Fixed_component_type EQ 2>
						<cfset baseprice = FOB_CS_Price>
						<cfset allow = FOB_CS_Price - currentfixedvalue>
						<cfif FOB_CS_Price NEQ 0>
						<cfset discount_percent = ((FOB_CS_Price - currentfixedvalue)/FOB_CS_Price) * 100>
						</cfif>
						<cfelse>
						<cfset baseprice = DEL_CS_Price>
						<cfset allow = DEL_CS_Price - currentfixedvalue>
						<cfif DEL_CS_Price NEQ 0>
						<cfset discount_percent = ((DEL_CS_Price - currentfixedvalue)/DEL_CS_Price) * 100>
						</cfif>
						</cfif>
						</cfif>
					</cfif>
					</cfif>
				</cfif>
				
                      
			     			 <cfset useLakebaseForgetfreightratesbyproduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getfixedpriceproducts")>
<cfif useLakebaseForgetfreightratesbyproduct>
	<cftry>
		<cfset getfreightratesbyproduct = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getfixedpriceproducts", {
				"bsa_foodservice_items_master_id" = "eq.#product_id#",
				"customer_id" = "eq.#customer_id#",
				"component_name_id" = "eq.#compID#",
				"paid_to" = "eq.#PaidTo#",
				"select" = "freight_rate"
			}), "freight_rate"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetfreightratesbyproduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetfreightratesbyproduct>
<cfquery name="getfreightratesbyproduct" dbtype="query">
								 select Freight_Rate
								 from getFixedPriceProducts
								 where BSA_Foodservice_Items_Master_ID = '#product_id#'
								 and customer_id = '#customer_id#'
								 and component_name_id = #compID#
								 and Paid_To = #PaidTo#
								</cfquery>
</cfif>
								
				
				
             
			
			
			<cfsavecontent variable="fixeddisplayvalue">
			<cfif currentfixedvalue neq 0>
#trim(numberformat(currentfixedvalue, ViewProgramManager.getRateFormatMask()))#/#left(getcurrentfixedproductprice.Abbreviation, 2)# <cfif appSettings.getPgmDisplayBothRateUOM() AND (getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 1 OR getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 2)>
			<br>#trim(numberformat(ViewProgramManager.getRateInUOM(currentfixedvalue, getcurrentfixedproductprice.Unit_Of_Measure_ID, getcurrentfixedproductprice.Net_Weight), ViewProgramManager.getRateFormatMask()))#/#ViewProgramManager.getTheOtherUOMDesc(getcurrentfixedproductprice.Unit_Of_Measure_ID)#
			</cfif><cfelse><cfif appsettings.getdisplayzerosviewprogram()>0.0000/#left(getcurrentfixedproductprice.Abbreviation, 2)# <cfelse>#trim(numberformat(getFixedPriceProducts.FIXED_PRICE_VALUE, ViewProgramManager.getRateFormatMask()))#/#left(getFixedPriceProducts.Abbreviation, 2)#<cfif appSettings.getPgmDisplayBothRateUOM() AND (getFixedPriceProducts.Unit_Of_Measure_ID EQ 1 OR getFixedPriceProducts.Unit_Of_Measure_ID EQ 2)>
			<br>#trim(numberformat(ViewProgramManager.getRateInUOM(getFixedPriceProducts.FIXED_PRICE_VALUE, getFixedPriceProducts.Unit_Of_Measure_ID, getFixedPriceProducts.Net_Weight), ViewProgramManager.getRateFormatMask()))#/#ViewProgramManager.getTheOtherUOMDesc(getFixedPriceProducts.Unit_Of_Measure_ID)#</cfif></cfif></cfif></cfsavecontent>
	         </cfsilent>
			<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_FixedPrice_basesales EQ 1>
			<TD>
			#trim(numberformat(baseprice, ViewProgramManager.getRateFormatMask()))#
			</TD>
			</cfif>
			<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_FixedPrice_basesales EQ 1>
			<td>
			<cfif allow LT 0>
			<cfset allowneg = allow * -1>
			#Negativeformat(numberformat(allowneg, ViewProgramManager.getRateFormatMask()))#
			<cfelse>
			#trim(numberformat(allow, ViewProgramManager.getRateFormatMask()))#
			</cfif>
			</td>
			</cfif>
			<td>
			<cfif getcurrentfixedproductprice.IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
	            AA   #fixeddisplayvalue# 
	
					<cfelse>
			<!--- If there are Date Exclusions --->	
								<cfif ListLen(List_Of_Contract_Main_IDs) GT 1>
								<!--- Show the Contract Start Date --->
								<!--- Delete the ParentID from the list and loop through the date exclusion ID's (Loop through the years, Month and Days)--->
								<cfset Date_Exclusion_Contract_Main_IDs = ListDeleteAt(List_Of_Contract_Main_IDs,1)>
<cfset DateExclusionDate = GenProgramManager.DateExclusionDates(Date_Exclusion_Contract_Main_IDs)>
			<cfloop query="DateExclusionDate">
									<cfloop from="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_Start_Date)#" to="#DatePart('yyyy', getDateExclusionprogramIDs.Contract_End_Date)#" index="IndexYear">
										<cfloop from="1" to="12" index="IndexMonth">
											<cfloop from="1" to="31" index="IndexDay">		
												<cfset DayDate = "#IndexMonth#/#IndexDay#/#IndexYear#">
													<cfif IsDate(DayDate)>
														<!--- If the date in the loop matches the date exclusion start date --->
														<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date) eq 0>
															<!--- If it's not the first row --->
															<cfif DateExclusionDate.currentrow neq 1>
																<!--- If there is a days difference in the previous date exclusion end date and current date exclusion start date --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date[DateExclusionDate.currentrow-1]) GT 0>
																#fixeddisplayvalue#<br /><br /><br />
																</cfif>
															 <cfelse><cfif DECount EQ 0>#fixeddisplayvalue#<br /><br /><br /></cfif>
															</cfif> 
														</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
														 <cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														<!--- If it's not the last row --->
															<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
														<!--- If there is a days difference in the current date exclusion end date and the following date exclusion start date, get that info --->
																<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																	#fixeddisplayvalue#	<br /><br /><br />			
																</cfif>
													
															<cfelse>
														
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
																<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																#fixeddisplayvalue#
																</cfif>
													</cfif>
													</cfif>
												</cfif>
											</cfloop>
										</cfloop>
									</cfloop>
								</cfloop></cfif>
			</cfif>
			

			<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 and GetSettings.display_FixedPrice_basesales EQ 1>
			<td>
				<CFIF discount_percent LT 0>
				<cfset discountperneg = discount_percent * -1>
					#NegativeFormat(numberformat(discountperneg,"____.__"))#%	
				<CFELSE>
					#numberformat(discount_percent,"____.__")#%
				</CFIF>
			</td>
			</cfif>
  
			<!---<TD ID="" valign="top">
			ZZ	#trim(numberformat(getfreightratesbyproduct.Freight_Rate, ViewProgramManager.getRateFormatMask()))#
			</TD>--->
				<!--- isnull() does not work on query of a query --->
				<cfif isnumeric(getfreightratesbyproduct.Freight_Rate) eq 0>
					<cfset tmpFreight_Rate = 0 />
				<cfelse>
					<cfset tmpFreight_Rate = getfreightratesbyproduct.Freight_Rate />
				</cfif>	
			<cfset fob_rate = currentfixedvalue + tmpFreight_Rate />
			<TD ID="" valign="top">
			 <cfif fob_rate eq 0>
				#trim(numberformat(getFixedPriceProducts.FIXED_PRICE_VALUE, ViewProgramManager.getRateFormatMask()))#
			  <cfelse>
				#trim(numberformat(fob_rate, ViewProgramManager.getRateFormatMask()))#
			</cfif>
			</TD>
			

			<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5>
			<td>
					<cfif trim(bidReqObj.getStatus()) eq 1>Pending...
					<cfelse>
							<cfif BidRequestProductStatusManager.getProgramProductWonInfo(item_num)>won<cfelse>lost</cfif>
					</cfif>
			</td>
			</cfif>
			<cfelse>
				<TD ALIGN="RIGHT" valign="top">#trim(numberformat(getFixedPriceProducts.Fixed_Price_Value, ViewProgramManager.getRateFormatMask()))# per #left(getFixedPriceProducts.Abbreviation, 2)#
	<br>			<cfif appSettings.getPgmDisplayBothRateUOM() AND (getFixedPriceProducts.Unit_Of_Measure_ID EQ 1 OR getFixedPriceProducts.Unit_Of_Measure_ID EQ 2)>
				#trim(numberformat(ViewProgramManager.getRateInUOM(getFixedPriceProducts.Fixed_Price_Value, getFixedPriceProducts.Unit_Of_Measure_ID, getFixedPriceProducts.Net_Weight), ViewProgramManager.getRateFormatMask()))# per #ViewProgramManager.getTheOtherUOMDesc(getFixedPriceProducts.Unit_Of_Measure_ID)#
				</cfif>
				</TD>				
			</cfif>
							</cfif> 
							</cfoutput>
							
					</cfoutput>
				</cfoutput>
						
				<cfelse>
				<!--- make sure list the items horizontally--->
					<cfset productCount = 0 >
					<TR BGCOLOR="F2F2F2">
						<CFOUTPUT QUERY="getFixedPriceProducts" group="BSA_Foodservice_Items_Master_ID">
							<cfif productCount Mod 2 EQ 0>
								</tr>
								<TR BGCOLOR="F2F2F2" ONMOUSEOVER="menuID=6;URLstring='';an_ID='#getFixedPriceProducts.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
							</cfif>
								<TD ID="" nowrap BGCOLOR="F2F2F2">
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
										<cfif application.returned_customer_setting.upc_switch EQ 1>#getFixedPriceProducts.UPC#<br></cfif>
									</cfif>#getFixedPriceProducts.ITEM#
								</TD>
								<TD ID="" nowrap BGCOLOR="F2F2F2">#getFixedPriceProducts.Description#</TD>	
							<cfset productCount = productCount + 1 >
							<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5>
								<td>
									<cfif trim(bidReqObj.getStatus()) eq 1>Pending...
									<cfelse>
											<cfif BidRequestProductStatusManager.getProgramProductWonInfo(getFixedPriceProducts.BSA_Foodservice_Items_Master_ID)>won<cfelse>lost</cfif>
									</cfif>
								</td>
							</cfif>
						</CFOUTPUT>
					</TR>
				</cfif></cfloop>
					<CFELSE>
						<TABLE WIDTH="100%">
						<cfoutput><TR>
							<TD COLSPAN="100%" ALIGN="center"><B><FONT COLOR="Red">NO PRODUCTS SUPPLIED</FONT></B></TD>
						</TR></cfoutput>
					</CFIF>
					<!--- end DATA OUTPUT --->
				</TABLE>			
				
		</TD>
	</TR>
	<!------ Start Clause Code ----->
	<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 2, 1)>
	<cfif getProgramClause.recordCount>
	<cfoutput><TR>
		<TD COLSPAN="100%">
		<BR>
		<!------ Fixed Price Clauses ----->
		<cfinclude template="/Clause_Library/clause_program_display.cfm">		
		</TD>
	</TR></cfoutput>
	</cfif>
	<!------ End  Clause Code ----->
	</cfif>
	</CFIF>