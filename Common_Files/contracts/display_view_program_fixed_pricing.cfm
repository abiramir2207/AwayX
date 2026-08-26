<cfset ADD_DOLLAR_SIGN = true>

<CFIF GetSettings.Discount_Fixed_Prices EQ 1>
	<cfset _Setting_Display_Item_No = appSettings.get_Setting('Display_Item_No') />
	<cfif appsettings.getshowfixedpriceadditionalfields() EQ 1 AND GetSettings.display_FixedPrice_basesales EQ 1>
		<cfset displaybasesales = 1>
	<cfelse>
		<cfset displaybasesales = 0>
	</cfif>
	<cfif List_Of_Contract_Main_IDs neq "">
		<cfset getFixedPriceProducts  = ViewProgramManager.getFixedPriceProducts(List_Of_Contract_Main_IDs
																																	,displayGroupType
																																	,1
																																	,displaybasesales
																																	,appSettings.getBidRequestUsePriceByDate()
																																	,appSettings.getUseItemCustPrice()
																																	,getsettings.Discount_Fixed_Prices_Freight)>
	<cfelse>
		<cfset getFixedPriceProducts  = ViewProgramManager.getFixedPriceProducts(CSLGetContractInfo.Contract_Main_ID
																																	,displayGroupType
																																	,0
																																	,displaybasesales
																																	,appSettings.getBidRequestUsePriceByDate()
																																	,appSettings.getUseItemCustPrice())>  <!--- ,getsettings.Discount_Fixed_Prices_Freight --->
	</cfif>

<cfif getFixedPriceProducts.recordcount GT 0>
		<cfif appSettings.getfixedcomponents_on()>
		<!--- List_Of_Contract_Main_IDs will be always blank if GetSettings.Date_Exclusions_ON eq 0 --->
			<cfif List_Of_Contract_Main_IDs eq "">
				<cfset getcompNames  = ViewProgramManager.getcompNames(CSLGetContractInfo.Contract_Main_ID,"0")>
			<cfelse>
				<cfset getcompNames  = ViewProgramManager.getcompNames(List_Of_Contract_Main_IDs,"1")>
			</cfif>
			<cfset getcurrentcompNames  = getcompNames />
		</cfif>
<CFIF getFixedPriceProducts.recordcount GT 0>

<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "GPO">
<cfoutput><SCRIPT>
	function createGpoExcel()
	{
		NewWindow('/Common_Files/contracts/OPP/GPO_Excel_Output.cfm?contractId=#CSLGetContractInfo.Contract_Main_ID#','gpoOutput','800','600','Yes', 'Yes');
		return false;
	}
</SCRIPT></cfoutput>
</cfif>

	<TR>
	    <cfoutput>
        <td colspan="100%">
            <style>
                .ml-sm {
                    margin-left: 15px;
                }
                .hidden {
                    display: none;
                }
            </style>
            <div style="margin-top:25px">
                <span style="color:navy;font-weight:bold;font-size:13px;">
                    #Application.FixedPriceLabel#
                    <cfif appSettings.getShow_Fixed_Freight()>
                        <cfset TemplateInfo = templatemanager.getProgramTemplate(CSLGetContractInfo.Contract_Main_ID)>
                        (<cfif TemplateInfo.Fixed_Type IS 1>Variable<cfelse>Guaranteed</cfif>)
                    </cfif>
                </span>

                <cfif !isDefined("request.settings.custom_rfp_process")>
                    <cfset application.util.query.request_settings()>
                </cfif>

                <cfif request.settings.custom_rfp_process   <!--- custom rfp internal setting --->
                    and CslGetContractInfo.Contract_status_type_idx gte 3  <!--- approved + status --->
                    and Getfieldsettings.RFP_Process        <!--- custom rfp program template --->
                    and get_profile_settings.Cont_prog_view_create_program>   <!--- user has program view create permission --->
                    <cfquery name="qTBD" datasource="#application.datasource#">
                        SELECT tbd.TBD_Item
                        FROM   Contract_Products cp
                            JOIN TBD_Item tbd
                                ON cp.BSA_Foodservice_Items_Master_ID = tbd.BSA_Foodservice_Items_Master_ID
                        WHERE  cp.Contract_Main_ID = #CSLGetContractInfo.Contract_Main_ID#
                    </cfquery>
                    <!--- display link option only when there is at least one TBD item --->
                    <cfif qTBD.recordCount>
                        <a href="##" class="ml-sm update_tbd hidden" onclick="update_tbd()">#application.util.string.linkFormat("update TBD products")#</a>
                    </cfif>
                </cfif>

                <cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "GPO">
                    <a  href="##" id="gpoExcel" class="ml-sm"
                        name="gpoExcel" title="Generate Excel Output"
                        onClick="createGpoExcel();">
                        <img src="/images/excel_icon.gif" align="middle" border="0" height="15" width="12"/>
                    </a>
                </cfif>


                <cfif appSettings.getShow_Fixed_Freight()>
                    <cfif len(trim(TemplateInfo.Fixed_Type_Explanation)) GT 0>
                        <span class="ml-sm">-- #TemplateInfo.Fixed_Type_Explanation#</span>
                    </cfif>
                </cfif>
            </div>
	        <hr color="navy">

	<!--- Dev Note: KAL; 11209 - Component code and description are not working correctly - This logic is obselete as you can add multiple components --->
	<!--- D45016 :: Restrict access at component level for all discount types START--->
	<cfset useLakebaseForgetAllFixedComponentsAccess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component_profile")>
<cfif useLakebaseForgetAllFixedComponentsAccess>
	<cftry>
		<cfset getAllFixedComponentsAccess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component_profile", {
				"deleted" = "eq.0",
				"profiles_id" = "eq.#request.AccessStructure.Profiles_ID#",
				"allow_user_to_view" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAllFixedComponentsAccess = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAllFixedComponentsAccess>
<cfquery name="getAllFixedComponentsAccess" datasource="#application.datasource#">
			SELECT 	*
			FROM		Program_Fixed_Component_Profile
			WHERE	Deleted = 0
			AND 		Profiles_ID = #request.AccessStructure.Profiles_ID#
			AND 		Allow_User_To_View = 1
	</cfquery>
</cfif>
	<!--- D45016 :: Restrict access at component level for all discount types END--->
					<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0" border="0">
					<!--- TABLE HEADERS --->
					<THEAD>
					<TR BGCOLOR="##FFCE84" VALIGN="bottom">
						<TD ID="header" WIDTH="75" valign="top"><B>
							<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
								<cfif application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1>#REReplace(application.returned_customer_setting.upc_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#<cfif _Setting_Display_Item_No eq '1'>/</cfif></cfif>
							</cfif>
							<cfif _Setting_Display_Item_No eq '1'>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</cfif></B></TD>
						<TD ID="header" WIDTH="250" valign="top"><B>Description</B><cfif  appSettings.get_Setting('Product_Group_Sequencing') neq '1' AND displayGroupType>/ <B>#REReplace(displayGroupTypeDesc, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B></cfif></TD>
						<cfif summaryView>
							<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5>
								<TD ID="header" WIDTH="70" valign="top"><B>Won/Lost</B></TD>
							</cfif>
							<TD ID="header" WIDTH="75" valign="top"><B>
								<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
									<cfif application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1>#REReplace(application.returned_customer_setting.upc_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#<cfif _Setting_Display_Item_No eq '1'>/</cfif></cfif>
								</cfif>
								<cfif _Setting_Display_Item_No eq '1'>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</cfif></B></TD>
							<TD ID="header" WIDTH="250" valign="top"><B>DESCRIPTION</B><cfif  appSettings.get_Setting('Product_Group_Sequencing') neq '1' AND displayGroupType>/ <B>#displayGroupTypeDesc#</B></cfif></TD>
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
								<cfquery name="getdistinctcompnames"  datasource="#application.datasource#">
									SELECT DISTINCT FirstCompName,Include_Second_Component,Program_Fixed_Component_Name,Program_Summary_Display_Name,Fixed_Component_Paid_to,Payment_Paid_To_Type_Name,Program_Fixed_Component_Name_ID,Program_Fixed_Component_ID
									FROM 	##TMP_CompNames
									ORDER BY FirstCompName, Include_Second_Component Desc,Program_Fixed_Component_ID
								</cfquery>
								<CFLOOP query="getcompNames">
									<cfif GetSettings.Date_Exclusions_ON EQ 0 OR getcompNames.Contract_Main_ID eq CSLGetContractInfo.Contract_Main_ID>
										<!--- Do not repeat the Component Entries (commented out the code) --->
										<cfif ListFindNoCase(CompList,getcompNames.Program_Fixed_Component_ID) eq 0>
											<cfset CompList = ListAppend(CompList,getcompNames.Program_Fixed_Component_ID)>
										</cfif>
									</cfif>
								</CFLOOP>

	<CFLOOP query="getdistinctcompnames">
		<!--- D45016 :: Restrict access at component level for all discount types START--->
			<cfif ! listfind(valuelist(getAllFixedComponentsAccess.Program_Fixed_Component_Name_ID),Program_Fixed_Component_Name_ID)>
			<cfset display = 'table-cell'>
			<cfelse>
				<cfset display = 'none'>
			</cfif>
		<!--- D45016 :: Restrict access at component level for all discount types END--->

	<cfif displaybasesales EQ 1>
		<!--- D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable--->
		<TD ID="header" valign="top" style="display:#display#"><strong>#appSettings.getBaseSaleLabel()#</strong></TD>
	</cfif>
	<cfif displaybasesales EQ 1>
		<TD ID="header" valign="top" style="display:#display#"><strong><cfif appsettings.getshowfixedpriceadditionalfields() EQ 1>Discount<cfelse>Allow</cfif></strong></TD>
	</cfif>
		<TD ID="header" valign="top" style="display:#display#">
			<B>
				<cfoutput>
					<cfif getdistinctcompnames.Program_Summary_Display_Name is "">
						#getdistinctcompnames.Program_Fixed_Component_Name#
					<cfelse>
						#getdistinctcompnames.Program_Summary_Display_Name#
					</cfif>
					<cfif GetSettings.DispalyPaysToOnViewProgPage EQ 1>
						<br>#getdistinctcompnames.Payment_Paid_To_Type_Name#
					</cfif>
				</cfoutput>
			</B>
		</TD>
	<!---IF MARKET PRICE, Display MP Details--->
	<cfif CSLGetContractInfo.Market_Price and bHideMarketPrice eq 0>
		<TD ID="header" valign="top" style="display:#display#"><strong>MARKET<br>PRICE</strong></TD>
		<TD ID="header" valign="top" style="display:#display#"><strong>VARIANCE</strong></TD>
	</cfif>
	<cfif displaybasesales EQ 1>
		<TD ID="header" valign="top" style="display:#display#"><strong>Discount%</strong></TD>
	</cfif>
	</CFLOOP>
								<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5>
										<TD ID="header" valign="top"><B>Won/Lost</B></TD>
								</cfif>

							<cfelse>
								<TD ID="header" WIDTH="130" ALIGN="RIGHT" valign="top"><B>Price</B></TD>
							</cfif>
							<cfset useLakebaseForisGroup_check = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getfixedpriceproducts")>
<cfif useLakebaseForisGroup_check>
	<cftry>
		<cfset isGroup_check = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getfixedpriceproducts", {
				"is_group" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisGroup_check = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisGroup_check>
<cfquery name="isGroup_check" dbtype="query">
								SELECT *
								FROM getFixedPriceProducts
								WHERE Is_Group = 1
							</cfquery>
</cfif>
							<!--- 39712 International Paper custom print column --->
							<cfif CSLGetContractInfo.Custom_Print gt 0 AND  appSettings.get_Setting('Custom_RFP_Process',0) EQ 0>
								<TD ID="header" valign="top"><B>Color<br>Digital<br>Graphic</B></TD>
								<!--- gather all products with custom print information --->
							 	<cfquery name="variables.customPrints" datasource="#application.datasource#">
									SELECT p.BSA_Foodservice_Items_Master_ID,b.Colors, b.Digital, b.Graphics
									FROM CONTRACT_PRODUCTS p
									INNER JOIN Print_Program_Custom_Options b
									ON b.Contract_Main_ID = p.Contract_Main_ID
									AND b.contract_products_id = p.contract_products_id
									AND b.Deleted = 0
									WHERE p.Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#CSLGetContractInfo.Contract_Main_ID#">
									AND p.Deleted = 0
							 	</cfquery>
							<cfelseif isGroup_check.RecordCount>
								<TD ID="header" valign="top"><B>Level</B></TD>
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

			<cfif GetSettings.Date_Exclusions_ON EQ 0>
				<cfset qTotalFixedComponentIDList =  ViewProgramManager.getFixedComponentIDs(CSLGetContractInfo.Contract_Main_ID, "")>
			</cfif>
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
			<cfif displaybasesales EQ 1>
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
			<cfelseif appSettings.getUseFixedPriceType() EQ 1>
			<!--- D30357:Today's Price Wrong on Revision History START --->
			<cfset getItemCustPrice = bidRequestProdMan.getItemCustPriceForFP(BSA_Foodservice_Items_Master_ID,CSLGetContractInfo.contract_main_id,CSLGetContractInfo.price_List_ID) />
			<cfif len(Base_Sales_CS)>
						<cfset FOB_CS_Price = #Base_Sales_CS#>
						<cfset FOB_LB_Price = #Base_Sales_CS#/#NET_WEIGHT#>
						<cfset DEL_CS_Price = #Base_Sales_CS#>
						<cfset DEl_LB_Price = #Base_Sales_CS#/#NET_WEIGHT#>
				<cfelse>
						<cfset FOB_CS_Price = getItemCustPrice.FOB_CS_Price>
						<cfset FOB_LB_Price = getItemCustPrice.FOB_LB_Price>
						<cfset DEL_CS_Price = getItemCustPrice.DEL_CS_Price>
						<cfset DEl_LB_Price = getItemCustPrice.DEL_LB_Price>
			</cfif>
			<!--- D30357:Today's Price Wrong on Revision History END --->
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
							<!--- D35295:Update market pricing to use new group rates grid--->
								<cfif getFixedPriceProducts.Is_Group>
									<cfset menuID = 11>
									<cfset an_ID = "#getFixedPriceProducts.Product_Group_ID#&Group_Level_ID=#getFixedPriceProducts.Product_Group_Level_ID#&programId=#CSLGetContractInfo.Contract_Main_ID#&producttype_id=1" />
										<cfelse>
									<cfset menuID = 6>
									<cfset an_ID = "#getFixedPriceProducts.BSA_Foodservice_Items_Master_ID#" />
								</cfif>
							<TR  BGCOLOR="#IIf(LoopCount Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" <cfif NOT isDefined("URL.action_type")>ONMOUSEOVER="menuID=#menuID#;URLstring='';an_ID='#an_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
								<!---D35295:Update market pricing to use new group rates grid --->
								<TD ID="">
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
										<cfif application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1>#getFixedPriceProducts.UPC#<br></cfif>
									</cfif>
									<cfif getFixedPriceProducts.Is_Group>Group Product<cfelse><cfif appSettings.get_Setting('Display_Item_No') eq '1'>
											<CFIF getcompNames.recordcount AND GetSettings.Discount_Formula_Pricing EQ 1 AND appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 AND  appSettings.get_Setting('Custom_RFP_Process',0) EQ 0>
												<a onClick="JavaScript: NewWindow('/Common_Files/contracts/Formula/Formula_Display.cfm?Program_Id=#CSLGetContractInfo.Contract_Main_ID#&contract_products_id=#getFixedPriceProducts.Contract_Products_ID#', 'FormulaDisplay',800, 800,1,1)" title="View Formula" STYLE="cursor: pointer;">#getFixedPriceProducts.ITEM#</a>
											<CFELSEIF getcompNames.recordcount AND GetSettings.Discount_Formula_Pricing EQ 1 AND appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 1 AND appSettings.get_Setting('Custom_RFP_Process',0) EQ 1>
												<a onClick="JavaScript: NewWindow('/Common_Files/contracts/Formula/Formula_Display_RFP.cfm?Program_Id=#CSLGetContractInfo.Contract_Main_ID#&contract_products_id=#getFixedPriceProducts.Contract_Products_ID#', 'FormulaDisplay',800, 800,1,1)" title="View Formula" STYLE="cursor: pointer;">#getFixedPriceProducts.ITEM#</a>
											<cfelse>
												#getFixedPriceProducts.ITEM#
											</CFIF>
									</cfif></cfif> <!---D35295:Update market pricing to use new group rates grid --->
								</TD>
								<TD>#getFixedPriceProducts.Description#
								<cfif displayGroupType and not summaryView>
								<br>	#DisplayGroupName#
								</cfif><cfif appsettings.getShowBrandOnViewProgram() EQ 1><br>#getFixedPriceProducts.Brand_Name#</cfif>
								<!--- D 36277	Add ”brand” to program view END--->
								</TD>
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
								 <CFLOOP query="getcompNames">
								<cfif GetSettings.Date_Exclusions_ON EQ 0>
									<cfset TotalFixedComponentIDList =  qTotalFixedComponentIDList />
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

<cfif DECount EQ 0>															#DateFormat(DateAdd('d',-1,Contract_Start_Date),"MM/DD/YYYY")#<br /><br /></cfif>
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
								</CFLOOP>


			<cfparam name="getcopmcount" default="0">
		<cfloop query ="getcurrentcompNames">

		<!--- D45016 :: Restrict access at component level for all discount types START--->
			<cfif ! listfind(valuelist(getAllFixedComponentsAccess.Program_Fixed_Component_Name_ID),Program_Fixed_Component_Name_ID)>
				<cfset display = 'table-cell'>
			<cfelse>
				<cfset display = 'none'>
			</cfif>
		<!--- D45016 :: Restrict access at component level for all discount types END--->
			<cfsilent>
			<cfset getcurrentfixedproductprice  = ViewProgramManager.getfixedproductprice(getFixedPriceProducts,getcurrentcompNames.Program_Fixed_Component_ID,item_num,ContractID)>
			<cfset Fixed_Price_Value_CS_LB = 0 />
			<cfset Fixed_Price_UOM_CS_LB = 0 />
			<cfif getcurrentfixedproductprice.recordcount EQ 0>
				<cfset currentfixedvalue = 0>
			<cfelse>
				<cfif getcurrentfixedproductprice.Fixed_Price_Value EQ "">
					<cfset currentfixedvalue = 0>
				<cfelse>
					<cfset currentfixedvalue = getcurrentfixedproductprice.Fixed_Price_Value>
					<cfset Fixed_Price_Value_CS_LB = getcurrentfixedproductprice.Stored_Fixed_Price_Value />
					<cfset Fixed_Price_UOM_CS_LB = getcurrentfixedproductprice.Stored_Fixed_Price_UOM />
				</cfif>
			</cfif>
			<cfif displaybasesales EQ 1>
				<cfset allow = 0>
				<cfset baseprice = 0>
				<cfset discount_percent = 0>
				<cfif Fixed_Price_Value_CS_LB NEQ 0>
					<!--- find the price ---->
					<cfif appSettings.getBidRequestUsePriceByDate() EQ 1 OR appSettings.getUseFixedPriceType() EQ 1>
						<cfif Fixed_Price_UOM_CS_LB EQ 2>
							<cfset baseprice = FOB_LB_Price>
						<cfelse>
							<cfset baseprice = FOB_CS_Price>
						</cfif>
					<cfelse>
						<cfif Fixed_Price_UOM_CS_LB EQ 2>
							<cfif getcompNames.Fixed_component_type EQ 2>
								<cfset baseprice = FOB_LB_Price>
							<cfelse>
								<cfset baseprice = DEL_LB_Price>
							</cfif>
						<cfelse>
							<cfif getcompNames.Fixed_component_type EQ 2>
								<cfset baseprice = FOB_CS_Price>
							<cfelse>
								<cfset baseprice = DEL_CS_Price>
							</cfif>
						</cfif>
					</cfif>

					<cfset basePriceForAllowance = baseprice />

					<!--- if business rule specified, add it to the base sales (price) ---->
					<cfset currentRuleId = getcompNames.Program_Fixed_Component_Name_Rule_ID />
					<cfif isNumeric(baseprice) AND currentRuleId neq 0>
					<cfset compBusRule = createObject("component","components.programs.fixed.FixedComponentBusinessRule")>
					<cfset qGetRuleInfo = compBusRule.getRules(ruleId = currentRuleId) />
						<cfset addRuleValue = 0 />

						<cfif isNumeric(getcompNames.Fixed_Component_Rule_Cost_Impact)>
							<cfif getcompNames.Fixed_Component_Rule_UOM eq 1><!--- cs --->
								<cfif Fixed_Price_UOM_CS_LB EQ 2><!--- fixed price is lb --->
									<cfset addRuleValue = qGetRuleInfo.Cost_Impact / Net_Weight />
								<cfelse>
									<cfset addRuleValue = qGetRuleInfo.Cost_Impact />
								</cfif>
							<cfelseif getcompNames.Fixed_Component_Rule_UOM eq 2><!--- lb --->
								<cfif Fixed_Price_UOM_CS_LB EQ 2><!--- fixed price is lb --->
									<cfset addRuleValue = getcompNames.Fixed_Component_Rule_Cost_Impact />
								<cfelse>
									<cfset addRuleValue = getcompNames.Fixed_Component_Rule_Cost_Impact * Net_Weight />
								</cfif>
							<cfelseif getcompNames.Fixed_Component_Rule_UOM eq 3><!--- % --->
								<cfif getcompNames.Apply_Percent_To eq 2>
									<cfset addRuleValue = Fixed_Price_Value_CS_LB * (getcompNames.Fixed_Component_Rule_Cost_Impact/100.00) />
								<cfelse>
									<cfset addRuleValue = baseprice * (getcompNames.Fixed_Component_Rule_Cost_Impact/100.00) />
								</cfif>
							</cfif>
						</cfif>
						<cfset basePriceForAllowance = baseprice + addRuleValue />
					</cfif>

					<!--- find allowance / allowance % ---->
					<cfset allow = basePriceForAllowance - Fixed_Price_Value_CS_LB>
					<!---Tim Ford: If allowance is less than zero then don't display the negative value. Just set it to zero --->
					<cfif allow lt 0>
						<cfset allow = 0 />
					</cfif>
					<cfif basePriceForAllowance NEQ 0 and allow gt 0>
						<cfset discount_percent = (allow/basePriceForAllowance) * 100>
					</cfif>
				</cfif>
			</cfif>
			<cfsavecontent variable="fixeddisplayvalue">

				<!--- 76380 decimal places START--->
					<!---if it's formula pricing then we need to tell the decimalPrecisionByUOM() function get the decimal precision from the Formula pricing - round decimal setting --->
					<cfset formulaPrice = false />
					<cfif GetSettings.Discount_Formula_Pricing EQ 1>
						<cfset formulaPrice = true />
					</cfif>
					<cfset decimalprecision = GenProgramManager.decimalPrecisionByUOM(getcurrentfixedproductprice.Unit_Of_Measure_ID,1, formulaPrice)>
				<!--- 76380 decimal places END--->
				<cfif currentfixedvalue neq 0>
						$#trim(numberformat(currentfixedvalue, decimalprecision))#/#left(getcurrentfixedproductprice.Abbreviation, 3)#
					<!---  D35295 :: Groups in Fixed price (rates Grid) added Is_Item_Group check --->
					<cfif appSettings.getPgmDisplayBothRateUOM() AND (getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 1 OR getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 2) AND (getcurrentfixedproductprice.Is_Item_Group EQ 0 OR (application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1 AND ISNUMERIC(getcurrentfixedproductprice.Prod_Var_A) EQ TRUE))>
						<cfif getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 1>
						 <br>#trim(numberformat(ViewProgramManager.getRateInUOM(currentfixedvalue, getcurrentfixedproductprice.Unit_Of_Measure_ID, getcurrentfixedproductprice.Net_Weight), ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN )))#/#ViewProgramManager.getTheOtherUOMDesc(getcurrentfixedproductprice.Unit_Of_Measure_ID)#
						<cfelse>
						 <br>$ #trim(numberformat(ViewProgramManager.getRateInUOM(currentfixedvalue, getcurrentfixedproductprice.Unit_Of_Measure_ID, getcurrentfixedproductprice.Net_Weight), "_.__"))#/#ViewProgramManager.getTheOtherUOMDesc(getcurrentfixedproductprice.Unit_Of_Measure_ID)#
						</cfif>
					</cfif>
					<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
						 <cfif getcurrentfixedproductprice.Unit_Of_Measure_ID EQ 1>
							 <br>$#trim(numberformat((currentfixedvalue * CSLGetContractInfo.currency_conversion_factor), "_.__"))#/#left(getcurrentfixedproductprice.Abbreviation, 2)# (CAD)
						 <cfelse>
							 <br>#trim(numberformat((currentfixedvalue * CSLGetContractInfo.currency_conversion_factor), ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN )))#/#left(getcurrentfixedproductprice.Abbreviation, 2)# (CAD)
						 </cfif>
					</cfif>
				<cfelse>
					<cfif appsettings.getdisplayzerosviewprogram()>0.0000/#left(getcurrentfixedproductprice.Abbreviation, 2)#
					<cfelse>&nbsp;
					</cfif>
				</cfif>
			</cfsavecontent>

			</cfsilent>
			<cfif displaybasesales EQ 1>
				<TD style="display:#display#">
					  #trim(numberformat(baseprice, ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN, getFixedPriceProducts.Unit_Of_Measure_ID, 1 )))#
					<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
						#trim(numberformat((baseprice * CSLGetContractInfo.currency_conversion_factor), ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN )))# (CAD)
					</cfif>
				</TD>
			</cfif>
			<cfif displaybasesales EQ 1>
				<td style="display:#display#">
					<cfif allow LT 0>
						<cfset allowneg = allow * -1>
						 #Negativeformat(numberformat(allowneg, ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN, getFixedPriceProducts.Unit_Of_Measure_ID, 1 )))#
						<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>>
							#Negativeformat(numberformat((allowneg * CSLGetContractInfo.currency_conversion_factor), ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN )))# (CAD)
						</cfif>
					<cfelse>
						 #trim(numberformat(allow, ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN, getFixedPriceProducts.Unit_Of_Measure_ID, 1)))#
						<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>>
							#trim(numberformat((allow * CSLGetContractInfo.currency_conversion_factor), ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN , getFixedPriceProducts.Unit_Of_Measure_ID, 1)))# (CAD)
						</cfif>
					</cfif>
				</td>
			</cfif>
			<td style="display:#display#">

			<cfif getcurrentfixedproductprice.IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
	              #fixeddisplayvalue#
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
											<cfelse>
												<cfif DECount EQ 0>#fixeddisplayvalue#<br /><br /><br /></cfif>
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
					</cfloop>
				</cfif>
			</cfif>

			<cfif getcurrentcompNames.recordcount LT getcopmcount>
				<cfset coldiff = getcopmcount - getcurrentcompNames.recordcount>
				<td colspan="#coldiff# style="display:#display#">&nbsp;</td>
			</cfif>

			<!---IF MARKET PRICE, Display MP Details--->
			<cfif CSLGetContractInfo.Market_Price and bHideMarketPrice eq 0>
				<td style="display:#display#">
					$#trim(numberformat(getcurrentfixedproductprice.Market_Price_Rate, "__.__"))#
					<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
						<br> $#trim(numberformat((val(getcurrentfixedproductprice.Market_Price_Rate) * CSLGetContractInfo.currency_conversion_factor), "__.__"))# (CAD)
					</cfif>
				</td>
				<td style="display:#display#">
					<cfif isNumeric(getcurrentfixedproductprice.Market_Price_Rate) AND getcurrentfixedproductprice.Market_Price_Rate NEQ 0 >
						$#trim(numberformat(getcurrentfixedproductprice.Market_Price_Rate-getcurrentfixedproductprice.Fixed_Price_Value, "___.__"))#
						&nbsp;&nbsp;
						#trim(numberformat((getcurrentfixedproductprice.Market_Price_Rate-getcurrentfixedproductprice.Fixed_Price_Value)/getcurrentfixedproductprice.Market_Price_Rate*100, "___.__"))#%
						<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
							<br> $#trim(numberformat(((getcurrentfixedproductprice.Market_Price_Rate-getcurrentfixedproductprice.Fixed_Price_Value) * CSLGetContractInfo.currency_conversion_factor), "___.__"))# (CAD)
						</cfif>
					<cfelse>
						&nbsp;
					</cfif>

				</td>
			</cfif>


			<cfset getcopmcount = getcurrentcompNames.recordcount>

			<cfif displaybasesales EQ 1>
			<td style="display:#display#">
				<CFIF discount_percent LT 0>
				<cfset discountperneg = discount_percent * -1>
					 #NegativeFormat(numberformat(discountperneg,"____.__"))#%
					 <cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
						<br> #NegativeFormat(numberformat((discountperneg * CSLGetContractInfo.currency_conversion_factor),"____.__"))#% (CAD)
					</cfif>
				<CFELSE>
					#numberformat(discount_percent,"____.__")#%
					 <cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
						<br> #numberformat((discount_percent * CSLGetContractInfo.currency_conversion_factor),"____.__")#% (CAD)
					</cfif>
				</CFIF>
			</td>
			</cfif>
		</cfloop>

			<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND getcompNames.recordcount LTE 5>
			<td>
					<cfif trim(bidReqObj.getStatus()) eq 1>Pending...
					<cfelse>
						<cfset productStatus = BidRequestProductStatusManager.getProgramProductWonInfo(item_num)>
						<cfif productStatus eq 1>won
						<cfelseif productStatus eq 0>lost
						<cfelse>Pending
						</cfif>
					</cfif>
			</td>
			</cfif>
			<cfelse>
				<TD ALIGN="RIGHT" valign="top">#trim(numberformat(getFixedPriceProducts.Fixed_Price_Value, ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN )))# per #left(getFixedPriceProducts.Abbreviation, 2)#
					<br>
					<cfif appSettings.getPgmDisplayBothRateUOM() AND (getFixedPriceProducts.Unit_Of_Measure_ID EQ 1 OR getFixedPriceProducts.Unit_Of_Measure_ID EQ 2)>
						#trim(numberformat(ViewProgramManager.getRateInUOM(getFixedPriceProducts.Fixed_Price_Value, getFixedPriceProducts.Unit_Of_Measure_ID, getFixedPriceProducts.Net_Weight), ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN )))# per #ViewProgramManager.getTheOtherUOMDesc(getFixedPriceProducts.Unit_Of_Measure_ID)#
					</cfif>
					 <cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
						<br> #trim(numberformat((ViewProgramManager.getRateInUOM(getFixedPriceProducts.Fixed_Price_Value, getFixedPriceProducts.Unit_Of_Measure_ID, getFixedPriceProducts.Net_Weight) * CSLGetContractInfo.currency_conversion_factor), ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN )))# per #ViewProgramManager.getTheOtherUOMDesc(getFixedPriceProducts.Unit_Of_Measure_ID)# (CAD)
					</cfif>
				</TD>
			</cfif>
			<!--- 39712 International Paper custom print column --->
			<cfif CSLGetContractInfo.Custom_Print gt 0 AND  appSettings.get_Setting('Custom_RFP_Process',0) EQ 0>
			 	<cfquery name="variables.customPrint" dbtype="query">
			 		SELECT Colors, Digital, Graphics
			 		  FROM variables.customPrints
			 		 WHERE BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_char" value="#item_num#">
			 	</cfquery>
				<TD valign="top">
					<cfif variables.customPrint.recordCount eq 0>
						&nbsp;
					<cfelse>
						#variables.customPrint.colors#<br>#(variables.customPrint.digital eq '0' ? 'no' : 'yes')#<br>#variables.customPrint.graphics#
					</cfif>
				</TD>
			<cfelseif isGroup_check.RecordCount>
				<TD valign="top" nowrap>#getFixedPriceProducts.Pricing_Level_Desc#</TD><!---D35295:Update market pricing to use new group rates grid --->
			</cfif>  <!--- CSLGetContractInfo.Custom_Print gt 0> --->
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
								<TR BGCOLOR="F2F2F2" <cfif NOT isDefined("URL.action_type")>ONMOUSEOVER="menuID=6;URLstring='';an_ID='#getFixedPriceProducts.BSA_Foodservice_Items_Master_ID#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
							</cfif>
								<TD ID="" nowrap BGCOLOR="F2F2F2">
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
										<cfif application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1>#getFixedPriceProducts.UPC#<br></cfif>
									</cfif>
									<cfif _Setting_Display_Item_No eq '1'>#getFixedPriceProducts.ITEM#</cfif>
								</TD>
								<TD ID="" nowrap BGCOLOR="F2F2F2">
									#getFixedPriceProducts.Description#<cfif appsettings.getShowBrandOnViewProgram() EQ 1><br>#getFixedPriceProducts.Brand_Name#</cfif>
								</TD>
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
				</cfif>
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

	<!--- D13547 Start component key display --->
	<TR>
		<TD COLSPAN="100%">

		<table width="100%" border="0">
			<tr><td colspan="2">
		<!------ Fixed Price Component information ----->
			<!--- Dev Note: drachala; D28861: Show / Hide component information  START
                  Added/Changed: Added <A HREF> AND ID in TR--->
		<strong>Additional component information:</strong> <a href="##" id="toggleFixedComponent" style="margin-left:5px;"></a>
		</td></tr>
		<tr id="eligibleFixedComponent">
		<cfoutput query="getcompNames">
			 <cfquery name="GetFixedCompInformation" datasource="#application.datasource#">
				SELECT Program_Fixed_Component_Name.Off_Invoice_On, Program_Fixed_Component_Name.Program_Fixed_Component_Name,
				Program_Fixed_Component_Name.Program_Summary_Display_Name,Payment_Type.Payment_Type_Name,
				Payment_Type.Restrict_From_Billback, Payment_Type.Is_Auto_Pay, Program_Fixed_Component.Fixed_Component_Paid_To,
				Program_Fixed_Component.Claim_Mechanics, Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID,
				GL_Account.GL_Account, GL_Account.GL_Account_Desc, Program_Fixed_Component.Program_Fixed_Component_ID,Program_Fixed_Component.Vendor_Selection,
				Program_Fixed_Component.Vendor_Master_ID, Program_Fixed_Component_Name.Fixed_Component_Type,
				isnull(nullif(Program_Fixed_Component.Payee_Type,''),0) As Payee_Selection
				<!--- D58135 ::  Additional Component info displaye inside program START--->
				,Program_Fixed_Component_Name.ID_on_ViewProgramPage
				,Program_Fixed_Component_Name.DeductionAccount_on_ViewProgramPage
				,Program_Fixed_Component_Name.PaymentAccount_on_ViewProgramPage
				,Program_Fixed_Component_Name.External_ID
				,Program_Fixed_Component_Name.Deduction_Account
				,Program_Fixed_Component_Name.Payment_Account
				,Program_Fixed_Component_Name.Formula_Pricing
				<!--- D58135 ::  Additional Component info displaye inside program END--->
				FROM Program_Fixed_Component
					LEFT JOIN Payment_Type
					ON Payment_Type.Payment_Type_ID = Program_Fixed_Component.Claim_Mechanics
					LEFT JOIN GL_Account
					ON GL_Account.GL_Account_ID = Program_Fixed_Component.GL_Account_ID
					INNER JOIN Program_Fixed_Component_Name
					ON Program_Fixed_Component_Name.Program_Fixed_Component_Name_ID = Program_Fixed_Component.Program_Fixed_Component_Name_ID
				WHERE Program_Fixed_Component.Program_Fixed_Component_ID = '#getcompNames.Program_Fixed_Component_ID#'
			</cfquery>


		<!--- D45016 :: Restrict access at component level for all discount types START--->
			<cfif ! listfind(valuelist(getAllFixedComponentsAccess.Program_Fixed_Component_Name_ID),getcompNames.Program_Fixed_Component_Name_ID)>
				<cfset display = "table-cell">
			<cfelse>
				<cfset display = 'none'>
			</cfif>
		<!--- D45016 :: Restrict access at component level for all discount types END--->
		<td valign="top" style="display:#display#">

			<!--- If the Payee is the "Distributor" in the "Billback_Closing_Method" settings in the settings panel --->
			<cfif GetFixedCompInformation.Payee_Selection eq 1>
				<cfset qryDistributor = objDistributor.getDistributor(GetFixedCompInformation.Vendor_Master_ID)>
			<cfelse>
				<cfset qryVendor = objVendor.getVendorInfo(GetFixedCompInformation.Vendor_Master_ID)>
			</cfif>

				<em><cfif GetFixedCompInformation.Program_Summary_Display_Name is "">#GetFixedCompInformation.Program_Fixed_Component_Name#<cfelse>#GetFixedCompInformation.Program_Summary_Display_Name#</cfif></em>: <br>

				<!--- BJF They want to see both the display name and the real name.--->
				<Cfif Compare(GetFixedCompInformation.Program_Fixed_Component_Name, GetFixedCompInformation.Program_Summary_Display_Name) NEQ 0>
				(#GetFixedCompInformation.Program_Fixed_Component_Name#)
				</Cfif>
            <ul style="margin:0;padding:0 13px;">
				<li>Paid to: <cfif (GetFixedCompInformation.Fixed_Component_Paid_to NEQ "")>#templateManager.getPaymentPaidToTypeDesc(paidToID = GetFixedCompInformation.Fixed_Component_Paid_to, paidToDesc="")#</cfif></li>
				<!--- Vendor_Selection eq 1 means 'pay to a single vendor', Vendor_Selection eq 2 means 'pay individually'--->
				<cfif GetFixedCompInformation.Is_Auto_Pay eq 1>
				<li>Payee:&nbsp;<cfif GetFixedCompInformation.Vendor_Master_ID neq ""><cfif GetFixedCompInformation.Payee_Selection eq 1>#qryDistributor.Name# (#qryDistributor.Shr_Ship_To#)<cfelse>#qryVendor.Vendor_Name# (#qryVendor.Vendor_ID#)</cfif><cfelse><cfif GetFixedCompInformation.Vendor_Selection eq 2>Pays each individually</cfif></cfif></li>
				</cfif>
				<cfif appSettings.getGL_Account_On()>
				<li>#Application.GLAccountLabel#: #GetFixedCompInformation.GL_Account_Desc# (#GetFixedCompInformation.GL_Account#)</li><!---D42774 --->
				</cfif>

				<cfif appSettings.getPaymentCycleAtDiscountType()>
					<li>
						Payment Cycle:
						<cfif (GetFixedCompInformation.Program_Fixed_Component_ID NEQ "")>
							<cf_payment_cycle_selection
								Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
								Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
								discount_Type_ID = "1"
								Selected_Payment_Cycle_ID = ""
								Component_ID = "#GetFixedCompInformation.Program_Fixed_Component_ID#"
								Action = "display"
								>
						 </cfif>
					</li>
				</cfif>
				<cfif appSettings.getClaims_at_Comp_Level()><li>Claim Mechanic: <cfif (GetFixedCompInformation.Claim_Mechanics NEQ "")>#paymenttypeManager.getDesc(GetFixedCompInformation.Claim_Mechanics)#</cfif></li></cfif>
				<cfif len(trim(GetFixedCompInformation.Off_Invoice_On)) GT 0>
					<cfif GetFixedCompInformation.Off_Invoice_On IS 1>
						<li>Off Invoice: Yes</li>
					<cfelse>
						<li>Off Invoice: No</li>
					</cfif>
				</cfif>
				<cfif len(trim(GetFixedCompInformation.Restrict_From_Billback)) GT 0>
					<cfif GetFixedCompInformation.Restrict_From_Billback IS 1>
						<li>Restricted from Billbacks: Yes</li>
					<cfelse>
						<li>Restricted from Billbacks: No</li>
					</cfif>
				</cfif>
				<cfif appSettings.getBBAutoReport() AND len(trim(GetFixedCompInformation.Is_Auto_Pay)) GT 0>
					<cfif GetFixedCompInformation.Is_Auto_Pay IS 1>
						<li>Auto Pay: Yes</li>
					<cfelse>
						<li>Auto Pay: No</li>
					</cfif>
				</cfif>
				<li>Fixed Pricing:
				<cfif (GetFixedCompInformation.Fixed_Component_Type NEQ "")>
					<cfswitch expression="#GetFixedCompInformation.Fixed_Component_Type#">
						<cfcase value="1">
							Delivered
						</cfcase>
						<cfcase value="2">
							FOB Plant
						</cfcase>
						<cfcase value="3">
							Delivered less freight
						</cfcase>
						<cfcase value="4">
							FOBDC
						</cfcase>
					</cfswitch>
				</cfif>
				</li>
				<!--- D58135 ::  Additional Component info displaye inside program START--->
				<cfset ID = LabelComp.getGeneralLabels('Fixed Price External ID')>
				<cfset DeductionAccount = LabelComp.getGeneralLabels('Deduction Account')>
				<cfset PaymentAccount = LabelComp.getGeneralLabels('Payment Account')>

				<cfif application.returned_customer_setting.external_id_on EQ 1 AND GetFixedCompInformation.ID_on_ViewProgramPage>
					<li>#ID.General_Labels_Label#: #GetFixedCompInformation.External_ID#</li>
				</cfif>
				<cfif GetFixedCompInformation.DeductionAccount_on_ViewProgramPage>
					<li>#DeductionAccount.General_Labels_Label#: #GetFixedCompInformation.Deduction_Account#</li>
				</cfif>
				<cfif GetFixedCompInformation.PaymentAccount_on_ViewProgramPage>
					<li>#PaymentAccount.General_Labels_Label#: #GetFixedCompInformation.Payment_Account#</li>
				</cfif>
				<!--- D58135 ::  Additional Component info displaye inside program END--->
				<cfif appSettings.getUseFixedPriceType()>
					<cfset priceBracket = GenProgramManager.getPriceListBracketForProgram(CSLGetContractInfo.Contract_Main_ID)>
				<li>Price Bracket:
				<!--- Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  START
                What  I did: added ListLast to display numbers after "_"--->
				<!---#priceBracket.price_list_id# --->
					#ListLast(priceBracket.price_list_id, "_")#
				<!--- End Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  --->
				<sup
					<cfif priceBracket.priceBracket_Update eq 1>class="overriddenShow"<cfelse>class="overriddenHide"</cfif>
					>*
				</sup>
				</cfif>

				<cfset variables.prodCountPerComponent = 0>
				<cfif getcompNames.recordcount>
					<!---  Dev Note (831400) - We need to divide query count by component count to get the number of products per component --->
					<cfset variables.prodCountPerComponent = getFixedPriceProducts.recordcount / getcompNames.recordcount>
				</cfif>

				<li>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")# Count: #variables.prodCountPerComponent#</li>

                <!--- FORMULA FIXED DISPLAY --->
                <CFIF getcompNames.recordcount AND GetFixedCompInformation.Formula_Pricing EQ 1 AND appSettings.get_Setting('Formula_Price_Item_Level_Config',0) EQ 0>
                    <cfset local.Program_Id = CSLGetContractInfo.Contract_Main_ID >
                    <cfset EDIT_RULE = false >
                    <CFINCLUDE template="/Common_Files/contracts/Formula/Formula_Display.cfm" >
                </CFIF>
            </ul>

			</td>

		</cfoutput>
		<!--- </td></tr> --->
		</tr>
		</table>
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


<script>
    if ( $("button.edit").length ) {
        $("a.update_tbd").removeClass("hidden");
    }
    function update_tbd() {
        <cfif isDefined("URL.CID")>
            location.href = <cfoutput>"/common_files/contracts/tbd_items.cfm?CID=#URL.CID#"</cfoutput>;
        </cfif>
    }
</script>
