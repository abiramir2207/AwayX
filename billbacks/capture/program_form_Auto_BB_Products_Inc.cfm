						
						<!---Auto BB can only have products from the program.--->
						<CFIF currentProgramObject.Products_On_Program GT 0>
								<TR>
									<TD height="#ProgramSpacerHeight#" colspan="100%">&nbsp;</TD>
								</TR>
								<TR>
									<TD colspan="100%"><span class="ProductTypeLabel"><CFIF xl eq 0><!--- start (don't run if export to xl is yes) --->Products On the Program<cfif appSettings.Claims_at_Comp_Level and billbackProgramRebateComps.recordCount gt 0> Component</cfif></cfif><!--- end (don't run if export to xl is yes) ---></span></TD>
								</TR>
								<TR>
									<TD colspan="100%">
										<table width="100%" border="0" cellspacing="0" cellpadding="3" align="left" class="productListTableStyle">
											<CFIF ShowProductsInGroupLevel EQ 1>
											<CFIF xl eq 0><!--- start (don't run if export to xl is yes) --->
											<TR class="tableHeader">
												<TD nowrap WIDTH="20%">Product Hierarchy</TD>
												<TD nowrap WIDTH="60%">Product Hierarchy Name</TD>	
												<TD>&nbsp;</TD>
												<TD WIDTH="50">Volume</TD>
												<TD WIDTH="40">UOM</TD>
												<TD WIDTH="65"><CFIF qCheckSched.Scheduled_Auto_BB>Sales Basis<br>Rate<cfelse>&nbsp;</CFIF></TD>
											</TR>
											<CFELSE>
											<TR>
												<TD nowrap><b>Customer Number</b></TD>
												<TD nowrap><b>Customer Name</b></TD>	
												<TD nowrap><b>Group</b></TD>
												<TD nowrap><b>Group Description</b></TD>
												<TD nowrap><b>Family</b></TD>
												<TD nowrap><b>Family Description</b></TD>
												<TD nowrap><b>Volume</b></TD>
												<TD nowrap><b>UOM</b></TD>
												
												<TD nowrap><CFIF qCheckSched.Scheduled_Auto_BB><b>Sales Basis</b><cfelse>&nbsp;</CFIF></TD>
												<TD nowrap><b>Rate</b></TD>
												<TD nowrap><b>Calulated Amount</b></TD>
												<TD nowrap><b>Claim Adjustment</b></TD>
												<TD nowrap><b>Family Total</b></TD>
												<!--- <CFIF CurrentProductCollection.Product_1.Rate_Rebate_Show EQ 1 OR NOT qCheckSched.Scheduled_Auto_BB>
												<TD nowrap><b>Rebate</b></TD>
												</CFIF> --->
											</TR>
											</CFIF><!--- end (don't run if export to xl is yes) --->	
											<CFELSE>
											<TR class="tableHeader">
												<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
													<cfif application.returned_customer_setting.upc_switch EQ 1>
														<TD nowrap><cfif trim(application.returned_customer_setting.upc_label) neq "">#application.returned_customer_setting.upc_label#<cfelse>UPC</cfif></TD>
													</cfif>
												</cfif>
												<TD nowrap><cfif trim(application.returned_customer_setting.item_label) neq "">#application.returned_customer_setting.item_label#<cfelse>Item ##</cfif></TD>
												<TD nowrap>Description</TD>
												<TD nowrap>Brand</TD>
												<TD>&nbsp;</TD>
												<TD WIDTH="50">Volume</TD>
												<TD WIDTH="40">UOM</TD>
												<TD WIDTH="65"><CFIF qCheckSched.Scheduled_Auto_BB>Sales Basis<br>Rate<cfelse>&nbsp;</CFIF></TD>
											</TR>		
											</CFIF>						
											<CFSET  FORM.temp_ExistingProductList_On_Program		= "">
												<CFSET LocalRateSum = 0>
												<cfset custid = "">
												<cfset SubTot = 0>
												<cfset GrpTot = 0>
												<cfset GrpName = "">
												<CFSET NewCust = "">
												<CFSET CustGrpid = "">
											<cfloop index="z" from="1" to="#CurrentProductCollection.Count#" step="1">	
												<CFSET currentrowIndex = currentrowIndex + 1>
												<CFSET CurrentProduct = evaluate("CurrentProductCollection.Product_#z#")>
												
												<CFSET TempProdTot = 0><!--- used for AutoBB worksheet calculation...they enter final amount and the claim field gets populated with the diff --->
													<cfif isnumeric(CurrentProduct.Rate_Fixed)>
														<CFSET TempProdTot = CurrentProduct.Rate_Fixed + TempProdTot>
													</cfif>
													<cfif isnumeric(CurrentProduct.Rate_Rebate)>
														<CFSET TempProdTot = CurrentProduct.Rate_Rebate + TempProdTot>
													</cfif>
													<cfif isnumeric(CurrentProduct.Rate_Lump_Sum)>
														<CFSET TempProdTot = CurrentProduct.Rate_Lump_Sum + TempProdTot>
													</cfif>
													<cfif isnumeric(CurrentProduct.Rate_Growth)>
														<CFSET TempProdTot = CurrentProduct.Rate_Growth + TempProdTot>
													</cfif>
													<cfif isnumeric(CurrentProduct.Rate_Formula)>
														<CFSET TempProdTot = CurrentProduct.Rate_Formula + TempProdTot>
													</cfif>
													<!--- <cfif isnumeric(CurrentProduct.Rate_ClaimAdjust)>
														<CFSET TempProdTot = CurrentProduct.Rate_ClaimAdjust + TempProdTot>
													</cfif> --->
												
												<CFIF CurrentProduct.Product_Type_ID EQ 1>
													<CFIF ShowProductsInGroupLevel EQ 1>
														<CFQUERY NAME="getProductData" DATASOURCE="#Application.Datasource#">
															SELECT * FROM Product_Hierarchy
															WHERE Product_Hierarchy_ID = '#CurrentProduct.PRODUCT_ID#'
														</CFQUERY>													
													<CFELSE>

														<cfquery name="getProductData" datasource="#Application.Datasource#">
															SELECT	dbo.BSA_Foodservice_Items_Master.Item, 
																	dbo.BSA_Foodservice_Items_Master.UPC, 
																	dbo.BSA_Foodservice_Items_Master.Description,
																	dbo.BSA_Foodservice_Items_Master.Net_Weight,
															        dbo.Brand.Brand_Name
															FROM    dbo.BSA_Foodservice_Items_Master 
																	INNER JOIN dbo.Brand ON 
																	dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID
															WHERE 	BSA_Foodservice_Items_Master_ID = '#CurrentProduct.PRODUCT_ID#'
															ORDER BY Item, UPC, Description
														</cfquery>													
													</CFIF>
													<CFIF qCheckSched.Scheduled_Auto_BB><!--- Display subTotal of Product rates for this distributor...Multi Dist Non Group Only --->
													
					<!--- |||||||||||||||||||||||||||	display customer level totals ********************--->
														<cfif CurrentProduct.Distributor_ID_Earned neq custid>
															 <cfif custid neq "">
															</cfif> 
															<CFSET NewCust = replace(CurrentProduct.Distributor_ID_Earned, "-", "_", "ALL")>
															<cfset custid = CurrentProduct.Distributor_ID_Earned>
															<cfset SubTot = 0>
																<CFQUERY NAME="getCustName" DATASOURCE="#Application.Datasource#">
																	SELECT Name, Shr_Ship_To FROM BSA_Foodservice_customers
																	WHERE BSA_Foodservice_customers_ID = '#CurrentProduct.Distributor_ID_Earned#'
																</CFQUERY>
																<CFQUERY NAME="getCustRate" DATASOURCE="#Application.Datasource#">
																	SELECT 		sum(cast(BB_Rate as float)) as Cust_rate
																	FROM 		Billback_Product 
																	INNER JOIN 	Billback_Product_Detail 
																				ON Billback_Product_Detail.Billback_ID = Billback_Product.Billback_ID 
																				and Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
																	WHERE 		Billback_Product.Billback_ID = '#Billback.Billback_ID#' AND 
																				Billback_Program_ID = '#Program.Billback_Program_ID#' AND
																				--Product_Hierarchy_ID = '#CurrentProduct.Billback_Product_ID#' AND
																				Billback_Product.Deleted = 0 AND 
																				Billback_Product_Detail.Deleted = 0 AND
																				CASE
																				WHEN Earned_From_Group = 0	THEN
																				Billback_Product_Detail.Distributor_ID_Earned
																				ELSE
																				Billback_Product_Detail.Customer_Group_ID
																				END 
																				 = '#CurrentProduct.Distributor_ID_Earned#'
																</CFQUERY>
															<cfif xl eq 0><!--- start (don't run if export to xl is yes) --->
																<cfif GrpName neq "" and GrpTot neq TempProdTot>
																 <tr bgcolor="D2E1EE">
																	<td colspan="1" bgcolor="D2E1EE">&nbsp;</td>
																	<td bgcolor="D2E1EE" align="left" colspan="2">
																		<table style="border-bottom: 0;" cellpadding="0" cellspacing="0">
																			<tr>
																				<!--- <td width="200" style="border-bottom : 0">&nbsp;</td> --->
																				<td align="right" width="300" style="border-bottom : 0" colspan="2"><span style="color:Navy; font-weight: bold;"><cfoutput>#GrpName#</cfoutput>&nbsp;&nbsp;::&nbsp;&nbsp;SubTot:$</span></td><!--- 8B0000 --->
																				<td align="right" width="75" style="border-bottom : 0"><cfoutput><span style="color:Navy; font-weight: bold;" id="GrpSubTot_#CustGrpid#">#numberformat(GrpTot,'9999999999.99')#</cfoutput></span></td>
																			</tr>
																		</table>
																		<!--- <span style="color:8B0000; font-weight: bold; padding-left: 240px;">Group SubTot:$</span> <span style="color:8B0000; font-weight: bold;" id="GrpSubTot_#NewGrp#">#numberformat(GrpTot,'9999999999.99')#</span> --->
																	</td>
																	<td colspan="3" bgcolor="D2E1EE">&nbsp;</td>
																 </tr>
																</cfif>
														 	<tr>
																<!--- <td colspan="1" bgcolor="8B0000"><span style="color:white; font-weight: bold;"></span></td> --->																
																<td align="left" bgcolor="8B0000" colspan="4">
																		<table style="border-bottom: 0;" cellpadding="0" cellspacing="0">
																			<tr><cfoutput>
																				<td width="325" style="border-bottom : 0"><span style="color:white; font-weight: bold;">#getCustName.name#&nbsp;&nbsp;::&nbsp;&nbsp;#getCustName.Shr_Ship_To#</span> </td>
																				<td align="left" width="100" style="border-bottom : 0"><span style="color:white; font-weight: bold;">Customer SubTot:$</span> </td><!--- 8B0000 --->
																				<td align="right" width="68" style="border-bottom : 0"><span style="color:white; font-weight: bold;" id="CustTot_#NewCust#">#numberformat(getCustRate.Cust_rate,'9999999999.99')#</span></td>
																				</cfoutput>
																			</tr>
																		</table>
																</td>
																<td colspan="2" bgcolor="8B0000">&nbsp;</td>															
															</tr>
															</cfif><!--- end (don't run if export to xl is yes) --->
															<cfset GrpName = ""> <!--- reset group name and unique id since it is a new customer display --->
															<!--- <Cfset CustGrpid = replace(createuuid(), "-", "_", "ALL")> --->
														</cfif>
				<!--- ||||||||||||||||||||	display product Group totals ************************ --->
													
														<cfif IsDefined("CurrentProduct.Group") AND  CurrentProduct.Group neq GrpName><!--- #TempProdTot# :: #GrpTot#  ::  #LocalRateSum# --->
															<cfif GrpName neq ""><!---  and GrpTot neq LocalRateSum>  and GrpTot neq TempProdTot --->
																<CFSET NewGrp = replace(CurrentProduct.Group_ID, "-", "_", "ALL")>
															<cfif xl eq 0> <!--- start (don't run if export to xl is yes) --->
																<tr bgcolor="D2E1EE">
																	<td colspan="1" bgcolor="D2E1EE">&nbsp;</td>
																	<td bgcolor="D2E1EE" align="left" colspan="2">
																		<table style="border-bottom: 0;" cellpadding="0" cellspacing="0">
																			<tr>
																				<!--- <td width="200" style="border-bottom : 0">&nbsp;</td> --->
																				<td align="right" width="300" style="border-bottom : 0" colspan="2"><span style="color:Navy; font-weight: bold;"><cfoutput>#GrpName#</cfoutput>&nbsp;&nbsp;::&nbsp;&nbsp;SubTot:$</span></td><!--- 8B0000 --->
																				<td align="right" width="75" style="border-bottom : 0"><cfoutput><span style="color:Navy; font-weight: bold;" id="GrpSubTot_#CustGrpid#">#numberformat(GrpTot,'9999999999.99')#</cfoutput></span></td>
																			</tr>
																		</table>
																		<!--- <span style="color:8B0000; font-weight: bold; padding-left: 240px;">Group SubTot:$</span> <span style="color:8B0000; font-weight: bold;" id="GrpSubTot_#NewGrp#">#numberformat(GrpTot,'9999999999.99')#</span> --->
																	</td>
																	<td colspan="3" bgcolor="D2E1EE">&nbsp;</td>
																</tr>
															</cfif> <!--- end (don't run if export to xl is yes) --->
															 </cfif>
															<cfset GrpName = CurrentProduct.Group>
															<cfset GrpTot = 0>
															<cfset CustGrpid = replace(createuuid(), "-", "_", "ALL")><!--- set a new grpid for JS ratecollection we just totaled a group so start fresh--->
														 <cfif xl eq 0> <!--- start (don't run if export to xl is yes) --->
															<tr>
																<td bgcolor="000080"><span style="color:white; font-weight: bold;"><cfoutput>#CurrentProduct.Product_Hierarchy#<!--- &nbsp;&nbsp;&nbsp;::&nbsp;&nbsp;&nbsp; ---></cfoutput></span></td>
																<td bgcolor="000080"><span style="color:white; font-weight: bold; padding-left: 0px;"><cfoutput>#GrpName#</cfoutput></span></td>
																<td colspan="4" bgcolor="000080">&nbsp;</td>
																<!--- <td colspan="4" bgcolor="white">&nbsp;</td> --->
															</tr>
														</cfif><!--- end (don't run if export to xl is yes) --->
													 </cfif>
													
				<!---||||||||||||||||||||||||||	 display product Group totals END ************************ --->
													
													</cfif>
													<CFSET FORM.temp_ExistingProductList_On_Program = listappend(FORM.temp_ExistingProductList_On_Program, CurrentProduct.PRODUCT_ID)>
													<CFIF Not qCheckSched.Scheduled_Auto_BB>
													<TR <CFIF currentrowIndex mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
														<CFIF ShowProductsInGroupLevel NEQ 1><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1><TD nowrap><cfoutput>#getProductData.UPC#</cfoutput></TD></cfif></cfif><CFELSE><TD NoWrap><!--- #getProductData.Product_Hierarchy# ---></TD></CFIF>
														<TD><CFIF ShowProductsInGroupLevel NEQ 1>#getProductData.Item#<CFELSE><!--- #getProductData.Product_Hierarchy_Name# ---></CFIF></TD>
														<CFIF ShowProductsInGroupLevel NEQ 1><TD nowrap>#getProductData.Description#</TD></CFIF>
														<CFIF ShowProductsInGroupLevel NEQ 1><TD width="100%"><CFIF len(trim(getProductData.Brand_Name)) GT 0><cfoutput>#getProductData.Brand_Name#</cfoutput><CFELSE>not available </CFIF></TD></CFIF>
														<TD valign="bottom"><SPAN id="VolumeCollectionErrorSpan"></SPAN>&nbsp;</TD>
													</CFIF>
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
														
														<CFSET temp_Vol_LB = 0>
														<CFSET temp_Vol_CS = 0>
														<cfset variables.temp_Total_Vol_CS = 0 />
														<cfset variables.temp_Total_Vol_LB = 0 />
														<CFIF CurrentProduct.Volume_UOM EQ 2>
															<CFSET temp_Vol_LB = trim(numberformat(CurrentProduct.Volume, '_.__'))>
															<CFSET temp_Vol_CS = 0>
															<CFSET variables.temp_Total_Vol_LB = trim(numberformat(CurrentProduct.Volume, '_.__')) />
															<CFIF ShowProductsInGroupLevel EQ 1>
																<CFSET variables.temp_Total_Vol_CS = temp_Vol_LB / 1/>
															<cfelse>
																<CFSET variables.temp_Total_Vol_CS = temp_Vol_LB / getProductData.Net_Weight />
															</CFIF>
															<CFSET variables.temp_Total_Vol_CS = trim(numberformat(variables.temp_Total_Vol_CS, '_.__')) />
														<CFELSE>
															<CFSET temp_Vol_CS = trim(numberformat(CurrentProduct.Volume, '_.__'))>
															<CFSET temp_Vol_LB = 0>
															<CFSET variables.temp_Total_Vol_CS = trim(numberformat(CurrentProduct.Volume, '_.__')) />
															<CFIF ShowProductsInGroupLevel EQ 1>
																<CFSET variables.temp_Total_Vol_LB = temp_Vol_CS * 1/>
															<cfelse>
																<CFSET variables.temp_Total_Vol_LB = temp_Vol_CS * getProductData.Net_Weight />
															</CFIF>
															<CFSET variables.temp_Total_Vol_LB = trim(numberformat(variables.temp_Total_Vol_LB, '_.__')) />
														</CFIF>
														

							<CFIF Not qCheckSched.Scheduled_Auto_BB>
									<TD nowrap>

											<!--- The volume text box has a few ID's associated with it.The ones starting with the word "Err" are for displaying error messages. 
														In the Onchange event below for UOMcollection , we use firstchild.lastchild bcoz the "VolumeCollection" id is the last id below (the spans are one inside the other) 
														and is being used for changing the UOM's --->
											
											<cfoutput><span id="VolumeCollection" rcid="#thisRandomID#">
											<span id="Err_ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume"></span><span id="Err_Percent_ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume"></span>
											<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume" style="border-left: 2 solid black; border-right: 2 solid black; border-top: 2 solid black; border-bottom: 2 solid black; color: black; text-align : right;" type="text" size="7" maxlength="10" value="<CFIF len(trim(CurrentProduct.Volume)) GT 0>#trim(NumberFormat(CurrentProduct.Volume, '_.__'))#</CFIF>" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" onKeyUp="clenseText(this, '-.0123456789'); allowonlytwodecimalplaces(this); " onBlur="TwoDecimalsOnBlur(this); resetLocalVolume(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#" TOTAL_VOL_LB="#variables.temp_Total_Vol_LB#" TOTAL_VOL_CS="#variables.temp_Total_Vol_CS#" NET_WEIGHT="#trim(getProductData.Net_Weight)#"></span>
											</cfoutput>
											</TD>
																<CFELSE>
																</CFIF>

													
													<CFIF isnumeric(trim(CurrentProduct.Volume))><CFSET Total_Of_Volume = Total_Of_Volume + trim(CurrentProduct.Volume)></CFIF>

															<CFIF Not qCheckSched.Scheduled_Auto_BB>
															  <TD>
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
																	text_before_tag_close	=	"onchange=""this.parentElement.parentElement.previousSibling.firstChild.firstChild.fireEvent('onkeyup');resetLocalVolume(document.all.ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume);"""
																	uom_id_exclusion_list	=	"3"
																	uom_id_inclusion_list	=	"">
																</span>
															  </TD>
															<CFELSE>
															<CFIF xl eq 0><!--- start (don't run if export to xl is yes) ---><td></td></CFIF><!--- end (don't run if export to xl is yes) --->
																<cfquery name="getUOMs" datasource="#application.datasource#">
																	SELECT 	Unit_Of_Measure_ID,
																			Unit_Of_Measure_Desc,
																			Abbreviation
																	FROM
																			Units_Of_Measure
																	WHERE Unit_Of_Measure_ID = '#CurrentProduct.Volume_UOM#'
																</cfquery>
																<!--- Display moved down below for Auto BB --->
																<!--- <cfoutput><span style="background: White; width: 40px; padding-bottom: 1px; padding-top: 1px; border: 2px solid Black; text-align: center;">#UCase(getUOMs.Abbreviation)#</span></cfoutput> --->
															</CFIF>
															
															<CFIF xl eq 0><!--- start (don't run if export to xl is yes) --->
																<TD nowrap>
																	<CFIF Not qCheckSched.Scheduled_Auto_BB>

															<!---Submits a form so that when the user changes UOM for an item that gets passed to the worksheet. BJF: D9264 --->
																		<!--- 	<A tabindex="-1" HREF="##" onclick="NewWindow('ws_volume.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume','worksheet','400','450','Yes', 'Yes');return false;" TITLE="Worksheet"> --->

																	<A tabindex="-1" href="##" onclick="return LaunchVolumeWindow('#Billback.Billback_ID#','ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume','worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume','KnownProgramForm','#CurrentProduct.PRODUCT_ID#','#CurrentProduct.Volume_UOM#','#currentProgramObject.Program_ID#','ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_UOM')" Title="Worksheet">
			
																			<cfquery name="WSVolumeEntry" dbtype="query">
																				SELECT Program_ID
																				FROM WorksheetVolume
																				WHERE Product_ID = '#CurrentProduct.Product_ID#' 
																				AND Program_ID = #currentProgramObject.Program_ID#
																			</cfquery>
																			
																			<cfif WSVolumeEntry.Recordcount GT 0>
																				<img src="/images/worksheet_has_data.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume" ></a>
																			<cfelse>
																				<img src="/images/worksheet.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume" ></a>
																			</cfif>
																			&nbsp; 
																			<img src="/images/no_small.gif" title="Delete This Product From The Billback" border="0" onClick="DeleteProduct(#currentProgramObject.Count_ID#,#CurrentProduct.Count_ID#)" style="cursor:pointer;">
																	</CFIF>
																</TD>
															</CFIF><!--- end (don't run if export to xl is yes) --->
															</TR>
															
													
													<TR <CFIF xl eq 0><!--- start (don't run if export to xl is yes) ---><CFIF currentrowIndex mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF></CFIF><!--- end (don't run if export to xl is yes) --->>
														<CFIF ShowProductsInGroupLevel EQ 1>
													
														<CFIF xl eq 0><!--- start (don't run if export to xl is yes) --->
														<cfoutput><td>#getProductData.Product_Hierarchy# /<br>#getProductData.Product_Hierarchy_Name#</td></cfoutput>
														<CFELSE>
													<cfoutput>
													<td>#getCustName.Shr_Ship_To#</td>
													<td>#getCustName.name#</td>
													<td>#CurrentProduct.Product_Hierarchy#</td>
													<td>#GrpName#</td>
													<td>'#getProductData.Product_Hierarchy#'</td>
													<td>#getProductData.Product_Hierarchy_Name#</td>
													<td><CFIF len(trim(CurrentProduct.Volume)) GT 0>#trim(NumberFormat(CurrentProduct.Volume, '_.__'))#<CFELSE>&nbsp;</CFIF></td>
													<td>#UCase(getUOMs.Abbreviation)#</td>
													
													<td>#CurrentProduct.Sales_Dollars#</td>
													<td>
														<CFIF CurrentProduct.Rate_Lump_Sum_Show EQ 1>
																			<CFIF CurrentProduct.Volume neq 0 and CurrentProduct.Sales_Dollars neq 0>
																				<cfset znum = CurrentProduct.Sales_Dollars/CurrentProduct.Volume>#NumberFormat(znum,'9999999999.99')#
																			</CFIF>
																			&nbsp;Sales Basis
														<CFELSE>
																			#trim(NumberFormat(CurrentProduct.Discount_Offered, '999999999.99'))#
																			<CFIF CurrentProduct.Discount_UOM eq 3> %
																			<CFELSEIF CurrentProduct.Discount_UOM eq 1> $CS
																			<CFELSEIF CurrentProduct.Discount_UOM eq 2> $LB
																			</CFIF>
														</CFIF>
													</td>
													<td>
													<cfset DiscountTypeValue = 0>
													<CFIF CurrentProduct.Rate_Fixed_Show EQ 1>
													<cfset DiscountTypeValue = trim(CurrentProduct.Rate_Fixed)>
													<CFELSEIF CurrentProduct.Rate_Rebate_Show EQ 1>
													<cfset DiscountTypeValue = trim(CurrentProduct.Rate_Rebate)>
													<CFELSEIF CurrentProduct.Rate_Lump_Sum_Show EQ 1>
													<cfset DiscountTypeValue = trim(CurrentProduct.Rate_Lump_Sum)>
													<CFELSEIF CurrentProduct.Rate_Growth_Show EQ 1>
													<cfset DiscountTypeValue = trim(CurrentProduct.Rate_Growth)>
													<CFELSEIF CurrentProduct.Rate_Formula_Show EQ 1>
													<cfset DiscountTypeValue = trim(CurrentProduct.Rate_Formula)>
													<CFELSEIF CurrentProduct.Rate_BidRequest_Show EQ 1>
													<cfset DiscountTypeValue = trim(CurrentProduct.Rate_BidRequest)>
													</CFIF>	
													#trim(DiscountTypeValue)#
													</td>
													<td>#val(CurrentProduct.Rate_ClaimAdjust)#</td>
													<td><cfset FamilyTotal = val(trim(DiscountTypeValue)) + val(trim(CurrentProduct.Rate_ClaimAdjust))>
													#trim(FamilyTotal)#
													</td>
													<!--- <CFIF CurrentProductCollection.Product_1.Rate_Rebate_Show EQ 1 OR NOT qCheckSched.Scheduled_Auto_BB>
													<td>#CurrentProduct.Rate_Rebate#</td>
													</CFIF> --->
													</cfoutput>
														</CFIF>
														</CFIF><!--- end (don't run if export to xl is yes) --->
												
												<cfif xl eq 0>  <!--- start (don't run if export to xl is yes) --->
														<TD <CFIF qCheckSched.Scheduled_Auto_BB>colspan="2"<cfelse>colspan="100%"</CFIF>>
															<table width="" cellspacing="0" cellpadding="4" border="0" align="left">
																<cfoutput><TR style="">
																	<TD WIDTH="20"></TD>
																	<TD style="border-bottom:solid silver 1px;" align="center"><cfif Not qCheckSched.Scheduled_Auto_BB><A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=1&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value" onClick="NewWindow(this.href,'fixed','400','450','Yes', 'Yes');return false;" TITLE="Worksheet" style="font-color: black;"><font color="black">Fixed Pricing</font></a><cfelseif CurrentProduct.Rate_Fixed_Show EQ 1><font color="black">Fixed Pricing</font><cfelse><!--- <font color="gray">Fixed Pricing</font> ---></cfif></TD>
																	<TD style="border-bottom:solid silver 1px;" align="center"><cfif Not qCheckSched.Scheduled_Auto_BB><A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=2&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value" onClick="NewWindow(this.href,'rebate','400','450','Yes', 'Yes');return false;" TITLE="Worksheet"><font color="black">#Application.RebateLabel#</font></a><cfelseif CurrentProduct.Rate_Rebate_Show EQ 1><font color="black">#Application.RebateLabel#</font><cfelse><!--- <font color="gray">#Application.RebateLabel#</font> ---></cfif></TD>
																	<CFIF qCheckSched.Scheduled_Auto_BB><td align="center" style="border-bottom:solid silver 1px;" title="Lump Sum is weighted for each products volume / total volume"><cfif CurrentProduct.Rate_Lump_Sum_Show EQ 1><font color="black">Lump Sum</font><cfelse><!--- <font color="gray">Lump Sum</font> ---></cfif></td></cfif>
																	<TD style="border-bottom:solid silver 1px;" align="center"><cfif Not qCheckSched.Scheduled_Auto_BB><A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=4&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value" onClick="NewWindow(this.href,'Growth','400','450','Yes', 'Yes');return false;" TITLE="Worksheet"><font color="black">Growth</font></a><cfelseif CurrentProduct.Rate_Growth_Show EQ 1><font color="black">Growth</font><cfelse><!--- <font color="gray">Growth</font> ---></cfif></TD>
																	<TD style="border-bottom:solid silver 1px;" align="center"><cfif Not qCheckSched.Scheduled_Auto_BB><A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=5&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value" onClick="NewWindow(this.href,'Formula','400','450','Yes', 'Yes');return false;" TITLE="Worksheet"><font color="black">Formula Pricing</font></a><cfelseif CurrentProduct.Rate_Formula_Show EQ 1><font color="black">Formula Pricing</font><cfelse><!--- <font color="gray">Formula Pricing</font> ---></cfif></TD>
																	<TD style="border-bottom:solid silver 1px;" align="center"><cfif Not qCheckSched.Scheduled_Auto_BB><A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=11&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_11_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_11_Value" onClick="NewWindow(this.href,'Bid_Request','400','450','Yes', 'Yes');return false;" TITLE="Worksheet"><font color="black">Proposal</font></a><cfelseif CurrentProduct.Rate_BidRequest_Show EQ 1><font color="black">Proposal</font><cfelse><!--- <font color="gray">Bid Request</font> ---></cfif></TD>
																	<TD style="border-bottom:solid silver 1px;" align="center"><!--- <A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=10&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value" onclick="NewWindow(this.href,'rebate','400','450','Yes', 'Yes');return false;" TITLE="Worksheet"> ---><font color="black">Claim Adjustment</font><!--- </a> ---></TD>
																	<cfif qCheckSched.Scheduled_Auto_BB>
																		<TD style="border-bottom:0" align="center">&nbsp;&nbsp;<!--- <font color="black">Total</font> ---></TD>
																	</cfif>
																</TR></cfoutput>
																<CFSET WSDollarEntry_ForList = "1,2,4,5,10,11" />
																<cfloop list="#WSDollarEntry_ForList#" index="i">
																<cfquery name="WSDollarEntry_#i#" dbtype="query">
																SELECT Program_ID
																FROM WorksheetDollars
																WHERE Product_ID = '#CurrentProduct.Product_ID#' 
																AND Program_ID = #currentProgramObject.Program_ID#
																AND Discount_Type = #i#
																<CFIF qCheckSched.Scheduled_Auto_BB>And customer_id = '#CurrentProduct.Distributor_ID_Earned#'</cfif>
																</cfquery>
																</cfloop>
																<TR>
																<TD></TD>
																<CFSET LocalRateSum = 0>
																<!------ Fixed ----->
																<cfoutput><TD style="border-bottom:0" align="center" valign="center">
																<CFIF CurrentProduct.Rate_Fixed_Show EQ 1 or NOT qCheckSched.Scheduled_Auto_BB>
																<font size="#Dollar_Sign_Size#" color="<CFIF CurrentProduct.Rate_Fixed_Show EQ 1>green<cfelse>red</CFIF>"><b>$</b></font>
																</cfif>
																	<span id="RateCollection_#thisRandomID#" SumOfRates="0">
																		<CFIF NOT qCheckSched.Scheduled_Auto_BB>
																			<input maxlength="10" 
																				style="<CFIF CurrentProduct.Rate_Fixed_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; <CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;</CFIF>" 
																						name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value" type="Text" size="7" 
																						value="<CFIF CurrentProduct.Rate_Fixed NEQ 0 OR len(trim(CurrentProduct.Rate_Fixed)) NEQ 0>#trim(CurrentProduct.Rate_Fixed)#</CFIF>" 
																						onfocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
																						onkeyup="clenseText(this, '.0123456789-'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" 
																						onblur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#">
																		<CFELSE>
																			<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value" type="hidden" value="<CFIF CurrentProduct.Rate_Fixed NEQ 0 OR len(trim(CurrentProduct.Rate_Fixed)) NEQ 0>#trim(CurrentProduct.Rate_Fixed)#</CFIF>" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#" >
																			<CFIF CurrentProduct.Rate_Fixed_Show EQ 1><span style="<CFIF CurrentProduct.Rate_Fixed_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; background-color: White;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;background-color: whitesmoke;</CFIF> padding: 1px 3px 1px 3px; width: 70px; color: Black;">#trim(CurrentProduct.Rate_Fixed)#</span></CFIF>
																		</CFIF>
																	</SPAN>
																<cfif Not qCheckSched.Scheduled_Auto_BB>

																<A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=1&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value" onClick="NewWindow(this.href,'fixed','400','450','Yes', 'Yes');return false;" TITLE="Worksheet">
																<cfif WSDollarEntry_1.Recordcount GT 0>
																		<img src="/images/worksheet_has_data.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value">
																	<cfelse>
																		<img src="/images/worksheet.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_1_Value">
																	</cfif>
																	</a>&nbsp; 
																</cfif></cfoutput>
																</TD>	
																<CFIF isnumeric(trim(CurrentProduct.Rate_Fixed))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Fixed)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Fixed)></CFIF>
																<!--- Rebate --->
																<cfoutput><TD style="border-bottom:0" align="center">
																  <CFIF CurrentProduct.Rate_Rebate_Show EQ 1 or NOT qCheckSched.Scheduled_Auto_BB>
																	<font size="#Dollar_Sign_Size#" color="<CFIF CurrentProduct.Rate_Rebate_Show EQ 1>green<cfelse>red</CFIF>"><b>$</b></font>
																  </CFIF>
																	<span id="RateCollection_#thisRandomID#">
																		<CFIF NOT qCheckSched.Scheduled_Auto_BB>
																			<input maxlength="10" style="<CFIF CurrentProduct.Rate_Rebate_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; background-color: White;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right; background-color: White;</CFIF>" 	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value" type="Text" size="7" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" value="<CFIF CurrentProduct.Rate_Rebate NEQ 0 OR len(trim(CurrentProduct.Rate_Rebate)) NEQ 0>#trim(CurrentProduct.Rate_Rebate)#</CFIF>" onKeyUp="clenseText(this, '.0123456789-'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" onBlur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#">
																		<CFELSE>
																			<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value" type="hidden" value="<CFIF CurrentProduct.Rate_Rebate NEQ 0 OR len(trim(CurrentProduct.Rate_Rebate)) NEQ 0>#trim(CurrentProduct.Rate_Rebate)#</CFIF>" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#">
																			<CFIF CurrentProduct.Rate_Rebate_Show EQ 1><span style="<CFIF CurrentProduct.Rate_Rebate_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; background-color: White;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right; background-color: whitesmoke;</CFIF> padding: 1px 3px 1px 3px; width: 70px; color: Black;">#trim(CurrentProduct.Rate_Rebate)#</span></CFIF>
																		</CFIF>
																	</SPAN>
																<cfif Not qCheckSched.Scheduled_Auto_BB>

																	<A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=2&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value" onClick="NewWindow(this.href,'fixed','400','450','Yes', 'Yes');return false;" TITLE="Worksheet">

																	<cfif WSDollarEntry_2.Recordcount GT 0>
																		<img src="/images/worksheet_has_data.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value">
																	<cfelse>
																		<img src="/images/worksheet.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value">
																	</cfif>
																	</a>&nbsp;
																</cfif> 
																</TD></cfoutput>
																<CFIF isnumeric(trim(CurrentProduct.Rate_Rebate))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Rebate)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Rebate)></CFIF>
																
																
																
															<!--- 	Lump Sum at Product level is for scheduled Auto BB only...Not really a "Lump" at this point, but it is set up in the program as one and allocated to products based on volume --->
																<CFIF qCheckSched.Scheduled_Auto_BB>
																<!--- LUMP SUM --->
																<TD style="border-bottom:0" align="center">
																  <cfoutput><CFIF CurrentProduct.Rate_Lump_Sum_Show EQ 1 or NOT qCheckSched.Scheduled_Auto_BB>
																	<font size="#Dollar_Sign_Size#" color="<CFIF CurrentProduct.Rate_Lump_Sum_Show 	EQ 1>green<cfelse>red</CFIF>"><b>$</b></font>
																  </CFIF>
																	<span id="RateCollection_#thisRandomID#">
																		<CFIF NOT qCheckSched.Scheduled_Auto_BB>
																			<input maxlength="10" style="<CFIF CurrentProduct.Rate_Lump_Sum_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; background-color: White;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right; background-color: White;</CFIF>" 	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value" type="Text" size="7" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" value="<CFIF CurrentProduct.Rate_Lump_Sum NEQ 0 OR len(trim(CurrentProduct.Rate_Lump_Sum)) NEQ 0>#trim(CurrentProduct.Rate_Lump_Sum)#</CFIF>" onKeyUp="clenseText(this, '.0123456789-'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" onBlur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#">
																		<CFELSE>
																			<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_3_Value" type="hidden" value="<CFIF CurrentProduct.Rate_Lump_Sum NEQ 0 OR len(trim(CurrentProduct.Rate_Lump_Sum)) NEQ 0>#trim(CurrentProduct.Rate_Lump_Sum)#</CFIF>" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#">
																			<CFIF CurrentProduct.Rate_Lump_Sum_Show EQ 1><span style="<CFIF CurrentProduct.Rate_Lump_Sum_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; background-color: White;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right; background-color: whitesmoke;</CFIF> padding: 1px 3px 1px 3px; width: 70px; color: Black;"><cfoutput>#trim(CurrentProduct.Rate_Lump_Sum)#</cfoutput></span></CFIF>
																		</CFIF>
																	</SPAN>
																<cfif CurrentProduct.Product_Type_ID eq 3 or Not qCheckSched.Scheduled_Auto_BB>
																	<A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=3&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_2_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_3_Value" onClick="NewWindow(this.href,'Lump_Sum','400','450','Yes', 'Yes');return false;" TITLE="Worksheet">

																	<cfif WSDollarEntry_2.Recordcount GT 0>
																	<img src="/images/worksheet_has_data.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_3_Value">
																	<cfelse>
																	<img src="/images/worksheet.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_3_Value">
																	</cfif>
																	</a>&nbsp;
																</cfif> </cfoutput>
																</TD>
																<CFIF isnumeric(trim(CurrentProduct.Rate_Lump_Sum))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Lump_Sum)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Lump_Sum)></CFIF>
																</CFIF>
																
																<!--- Growth --->
																<TD style="border-bottom:0" align="center">
																  <cfoutput><CFIF CurrentProduct.Rate_Growth_Show EQ 1 or NOT qCheckSched.Scheduled_Auto_BB>
																	<font size="#Dollar_Sign_Size#" color="<CFIF CurrentProduct.Rate_Growth_Show EQ 1>green<cfelse>red</CFIF>"><b>$</b></font>
																  </CFIF>
																	<SPAN ID="RateCollection_#thisRandomID#">
																		<CFIF NOT qCheckSched.Scheduled_Auto_BB>
																			<input maxlength="10" style="<CFIF CurrentProduct.Rate_Growth_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;</CFIF>" 	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value" type="Text" size="7" value="<CFIF CurrentProduct.Rate_Growth NEQ 0 OR len(trim(CurrentProduct.Rate_Growth)) NEQ 0>#trim(CurrentProduct.Rate_Growth)#</CFIF>" onFocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);"	onkeyup="clenseText(this, '.0123456789-'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" onBlur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" rcid="#thisRandomID#">
																		<CFELSE>
																			<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value" type="hidden" value="<CFIF CurrentProduct.Rate_Growth NEQ 0 OR len(trim(CurrentProduct.Rate_Growth)) NEQ 0>#trim(CurrentProduct.Rate_Growth)#</CFIF>" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#">
																			<CFIF CurrentProduct.Rate_Growth_Show EQ 1><span style="<CFIF CurrentProduct.Rate_Growth_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; background-color: White;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;background-color: whitesmoke;</CFIF> padding: 1px 3px 1px 3px; width: 70px; color: Black;">#trim(CurrentProduct.Rate_Growth)#</span></CFIF>
																		</CFIF>
																	</SPAN>
																<cfif Not qCheckSched.Scheduled_Auto_BB>
																	<A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=4&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value" onClick="NewWindow(this.href,'fixed','400','450','Yes', 'Yes');return false;" TITLE="Worksheet">

																	<cfif WSDollarEntry_4.Recordcount GT 0>
																		<img src="/images/worksheet_has_data.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value">
																	<cfelse>
																		<img src="/images/worksheet.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_4_Value">
																	</cfif>
																	</a>&nbsp;
																</cfif> </cfoutput>
																</TD>
																<CFIF isnumeric(trim(CurrentProduct.Rate_Growth))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Growth)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Growth)></CFIF>
																<!--- Formula --->
																<TD style="border-bottom:0" align="center"><!--- border-bottom:solid silver 1px; --->
																 <cfoutput> <CFIF CurrentProduct.Rate_Formula_Show EQ 1 or NOT qCheckSched.Scheduled_Auto_BB>
																	<font size="#Dollar_Sign_Size#" color="<CFIF CurrentProduct.Rate_Formula_Show EQ 1>green<cfelse>red</CFIF>"><b>$</b></font>
																  </CFIF>
																	<SPAN ID="RateCollection_#thisRandomID#">
																		<CFIF NOT qCheckSched.Scheduled_Auto_BB>
																			<input maxlength="10" 
																					style="<CFIF CurrentProduct.Rate_Formula_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;</CFIF>" 	
																					name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value" 
																					type="Text" 
																					size="7" 
																					onfocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
																					value="<CFIF CurrentProduct.Rate_Formula 	NEQ 0 OR len(trim(CurrentProduct.Rate_Formula)) NEQ 0>#trim(CurrentProduct.Rate_Formula)#</CFIF>" 	
																					onkeyup="clenseText(this, '.0123456789-'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" 
																					onblur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" 
																					rcid="#thisRandomID#">
																		<CFELSE>
																			<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value" type="hidden" value="<CFIF CurrentProduct.Rate_Formula NEQ 0 OR len(trim(CurrentProduct.Rate_Formula)) NEQ 0>#trim(CurrentProduct.Rate_Formula)#</CFIF>" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#">
																			<CFIF CurrentProduct.Rate_Formula_Show EQ 1><span style="<CFIF CurrentProduct.Rate_Formula_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; background-color: White;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;background-color: whitesmoke;</CFIF> padding: 1px 3px 1px 3px; width: 70px; color: Black;">#trim(CurrentProduct.Rate_Formula)#</span></CFIF>
																		</CFIF>
																	</SPAN>
																<cfif Not qCheckSched.Scheduled_Auto_BB>
																	<A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=5&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value" onClick="NewWindow(this.href,'fixed','400','450','Yes', 'Yes');return false;" TITLE="Worksheet">

																	<cfif WSDollarEntry_5.Recordcount GT 0>
																		<img src="/images/worksheet_has_data.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value">
																	<cfelse>
																		<img src="/images/worksheet.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_5_Value">
																	</cfif>
																	</a>&nbsp; 
																</cfif></cfoutput>
																</TD>		
																<CFIF isnumeric(trim(CurrentProduct.Rate_Formula))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_Formula)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_Formula)></CFIF>
																<!--- Bid Request --->
																<CFSET BB_Current_Product_Type_ID = 11 />
																<TD style="border-bottom:0" align="center"><!--- border-bottom:solid silver 1px; --->
																<cfoutput><CFIF CurrentProduct.Rate_BidRequest_Show EQ 1 or NOT qCheckSched.Scheduled_Auto_BB>
																<font size="#Dollar_Sign_Size#" color="<CFIF CurrentProduct.Rate_BidRequest_Show 	EQ 1>green<cfelse>red</CFIF>"><b>$</b></font>
																</CFIF>
																<SPAN ID="RateCollection_#thisRandomID#">
																	<CFIF NOT qCheckSched.Scheduled_Auto_BB>
																		<input maxlength="10" 
																				style="<CFIF CurrentProduct.Rate_BidRequest_Show 		EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;</CFIF>" 	
																				name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_#BB_Current_Product_Type_ID#_Value" 
																				type="Text" 
																				size="7" 
																				onfocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
																				value="<CFIF CurrentProduct.Rate_BidRequest 	NEQ 0 OR len(trim(CurrentProduct.Rate_BidRequest)) NEQ 0>#trim(CurrentProduct.Rate_BidRequest)#</CFIF>" 	
																				onkeyup="clenseText(this, '.0123456789'); allowonlytwodecimalplaces(this); AdjustRateTotal(this);" 
																				onblur="TwoDecimalsOnBlur(this); AdjustRateTotal(this);propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" 
																				rcid="#thisRandomID#">
																	<CFELSE>
																		<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_#BB_Current_Product_Type_ID#_Value" type="hidden" value="<CFIF CurrentProduct.Rate_BidRequest NEQ 0 OR len(trim(CurrentProduct.Rate_BidRequest)) NEQ 0>#trim(CurrentProduct.Rate_BidRequest)#</CFIF>" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#">
																		<CFIF CurrentProduct.Rate_BidRequest_Show EQ 1><span style="<CFIF CurrentProduct.Rate_BidRequest_Show EQ 1>border-left: 2 solid Green; border-right: 2 solid Green; border-top: 2 solid Green; border-bottom: 2 solid Green; color: Green; text-align : right; background-color: White;<CFELSE>border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;background-color: whitesmoke;</CFIF> padding: 1px 3px 1px 3px; width: 70px; color: Black;">#trim(CurrentProduct.Rate_BidRequest)#</span></CFIF>
																	</CFIF>
																</SPAN>
																<cfif Not qCheckSched.Scheduled_Auto_BB>
																	<A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=#BB_Current_Product_Type_ID#&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_#BB_Current_Product_Type_ID#_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_#BB_Current_Product_Type_ID#_Value" onClick="NewWindow(this.href,'fixed','400','450','Yes', 'Yes');return false;" TITLE="Worksheet">

																	<cfif Evaluate("WSDollarEntry_#BB_Current_Product_Type_ID#").Recordcount GT 0>
																		<img src="/images/worksheet_has_data.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_#BB_Current_Product_Type_ID#_Value">
																	<cfelse>
																		<img src="/images/worksheet.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_#BB_Current_Product_Type_ID#_Value">
																	</cfif>
																	</a>&nbsp; 
																</cfif></cfoutput>
																</TD>		
																<CFIF isnumeric(trim(CurrentProduct.Rate_BidRequest))><CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_BidRequest)><CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_BidRequest)></CFIF>
																
																<!--- Claim adjustment --->
																<TD style="border-bottom:0" align="center"><!---  border-bottom:solid silver 1px; --->
																<cfoutput><cfif xl neq 1>
																	<!--- don't run if export to xl is yes. --->
																<!---The above statement(xl neq 1) is no longer valid as this logic runs only when xl=0.(Changed on Jan 12th, 2006 by Milan)--->
																<font size="#Dollar_Sign_Size#" color="red"><b>$</b></font>
																<SPAN ID="RateCollection_#thisRandomID#" ed=0>
																<input maxlength="10"
																	style="border-left: 2 solid Red; border-right: 2 solid Red; border-top: 2 solid Red; border-bottom: 2 solid Red; color: Red; text-align : right;"
																	name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value" 
																	type="Text" 
																	size="7" 
																	onfocus="propogateProperty(this, 'style.backgroundColor', '#alertcolor#', false);" 
																	value="<CFIF CurrentProduct.Rate_ClaimAdjust NEQ 0 OR len(trim(CurrentProduct.Rate_ClaimAdjust)) NEQ 0><cfoutput>#trim(CurrentProduct.Rate_ClaimAdjust)#</cfoutput></CFIF>" 	
																	onkeyup="clenseText(this, '.0123456789-'); allowonlytwodecimalplaces(this); AdjustRateTotal(this, '#CustGrpid#', '#NewCust#');" 
																	onblur="TwoDecimalsOnBlur(this); AdjustRateTotal(this, '#CustGrpid#', '#NewCust#'); propogateProperty(this, 'style.backgroundColor', '##ffffff', false);" 
																	rcid="#thisRandomID#"
																	<cfif currentProgramObject.Count_ID eq 1 and CurrentProduct.Count_ID eq 1>onload="this.focus()"</cfif>><!--- AdjustGroupTotal(this); --->
																</SPAN>
																<cfif qCheckSched.Scheduled_Auto_BB>
																	<A tabindex="-1" HREF="ws_dollars.cfm?Product_ID=#CurrentProduct.PRODUCT_ID#&Billback_ID=#Billback.Billback_ID#&Program_ID=#currentProgramObject.Program_ID#&Discount_Type=10&Product_Volume_UOM=#CurrentProduct.Volume_UOM#&FieldtoFill=ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value&ParentFormName=KnownProgramForm&Image=worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value&AutoBB=#qCheckSched.Scheduled_Auto_BB#&Tot=#TempProdTot#&customer_ID=#CurrentProduct.Distributor_ID_Earned#" onClick="NewWindow(this.href,'fixed','400','450','Yes', 'Yes');return false;" TITLE="Worksheet">

																	<cfif WSDollarEntry_10.Recordcount GT 0>
																		<img src="/images/worksheet_has_data.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value">
																	<cfelse>
																		<img src="/images/worksheet.gif" border="0" valign="center" id="worksheet_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_RateType_10_Value">
																	</cfif>
																	</a>&nbsp;
																</cfif> 
																<cfelse><!--- is xl export --->
																	<!---The above statement(is xl export) is no longer valid as this logic runs only when xl=0.(Changed on Jan 12th, 2006 by Milan)--->
																	<cfoutput>#trim(CurrentProduct.Rate_ClaimAdjust)#</cfoutput>
																</cfif>
																<!--- </cfif> --->
																</cfoutput>
																</TD>
																	<cfoutput><CFIF isnumeric(trim(CurrentProduct.Rate_ClaimAdjust))>
																		<CFSET Total_Of_Rates = Total_Of_Rates + trim(CurrentProduct.Rate_ClaimAdjust)>
																		<CFSET LocalRateSum = LocalRateSum + trim(CurrentProduct.Rate_ClaimAdjust)>
																	</CFIF>
																		<Script>
																		RateCollection_#thisRandomID#[0].SumOfRates="#replace(NumberFormat(LocalRateSum,'99999999999999999999.__')," ","","all")#"
																		</SCRIPT></cfoutput>
																<cfif qCheckSched.Scheduled_Auto_BB>
																	<TD style="border-bottom:0"> <!--- border-bottom:solid silver 1px; --->
																		 
																			<table style="border-bottom: 0;" cellpadding="0" cellspacing="0">
																				<tr>
																					<td align="right" style="border-bottom : 0">Total:$</td>
																					<cfoutput>
																					<td align="right" width="75" style="border-bottom : 0">
																					<!--- hidden field used for JS calculations to update subtotal fields --->
																						
																					<cfoutput>	<SPAN id="Grp_Col#CustGrpid#">
																							<input type="hidden" value="#trim(numberformat(LocalRateSum,'9999999999.99'))#" name="LocalTot_#thisRandomID#" rcid="#CustGrpid#" id="Grp_Col#CustGrpid#">
																						</span>
																						<SPAN id="Cust_Col#NewCust#">
																							<input type="hidden" value="#trim(numberformat(LocalRateSum,'9999999999.99'))#" name="LocalTotC_#thisRandomID#" rcid="#NewCust#">
																						</span>
																						<SPAN id="LocalTots_#thisRandomID#">
																							#trim(numberformat(LocalRateSum,'9999999999.99'))#
																						</span></cfoutput>
																					</td></cfoutput><!--- AdjustRateTotal(this);  rcid="Grp_Collection_#CustGrpid#"--->
																				</tr>
																			</table>
																		
																	</TD>
																</cfif>
																</TR>															
																<!--- <TR>
																	<TD colspan="100%" height="15px"></TD>
																</TR> --->
															</table>
														</TD>
														<cfif qCheckSched.Scheduled_Auto_BB>
															<TD nowrap align="left">
																<SPAN id="VolumeCollectionErrorSpan"></SPAN>&nbsp;
																<cfoutput><span id="VolumeCollection" rcid="#thisRandomID#" style="border-left: 2 solid black; border-right: 2 solid black; border-top: 2 solid black; border-bottom: 2 solid black; color: black; text-align: right; padding: 1px 3px 1px 3px; width: 60px; background-color: White;">
																			<span id="Err_ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume"></span><span id="Err_Percent_ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume"></span>
																			<CFIF len(trim(CurrentProduct.Volume)) GT 0>#trim(NumberFormat(CurrentProduct.Volume, '_.__'))#</CFIF>
																		<input name="ProgramCount_#currentProgramObject.Count_ID#_ProductCount_#CurrentProduct.Count_ID#_Volume" type="hidden" value="<CFIF len(trim(CurrentProduct.Volume)) GT 0>#trim(NumberFormat(CurrentProduct.Volume, '_.__'))#</CFIF>" VOL_LB="#temp_Vol_LB#" VOL_CS="#temp_Vol_CS#"></span></cfoutput>
															</td>
															
															<td><span id="UOMCollection">
																		<cfoutput><span style="background: White; width: 40px; padding-bottom: 1px; padding-top: 1px; border: 2px solid Black; text-align: center;">#UCase(getUOMs.Abbreviation)#</span></cfoutput>
																</span>
															</td>	
															
															<cfparam name="CurrentProduct.Sales_Dollars" default="0">
															<td WIDTH="65" nowrap="nowrap">
																$<cfoutput>#trim(NumberFormat(CurrentProduct.Sales_Dollars, '999999999.99'))#</cfoutput><br>
																<CFIF CurrentProduct.Rate_Lump_Sum_Show EQ 1>
																	<CFIF CurrentProduct.Volume neq 0 and CurrentProduct.Sales_Dollars neq 0>
																		<cfset znum = CurrentProduct.Sales_Dollars/CurrentProduct.Volume><cfoutput>#NumberFormat(znum,'9999999999.99')#</cfoutput>
																	</cfif>&nbsp;Sales Basis/CA
																<cfelse><cfoutput>#trim(NumberFormat(CurrentProduct.Discount_Offered, '999999999.99'))#</cfoutput>
																	<cfif CurrentProduct.Discount_UOM eq 3> %
																	<cfelseif CurrentProduct.Discount_UOM eq 1> $CS
																	<cfelseif CurrentProduct.Discount_UOM eq 2> $LB
																	</cfif>
																</cfif>
															</td>
															<!--- <td colspan="2">&nbsp;</td> --->
														</cfif> <!--- if Scheduled_Auto_BB --->
													</TR>
													<!--- Display Product Group and Family level Totals  |||||||||||||||||||||||||||||||||||||||||     --->
													<CFSET SubTot = SubTot + LocalRateSum>
													<CFSET GrpTot = GrpTot + LocalRateSum>
													<cfif z eq CurrentProductCollection.Count and qCheckSched.Scheduled_Auto_BB and GrpTot Neq TempProdtot>
															<tr>
																<td colspan="1" bgcolor="D2E1EE">&nbsp;</td>
																<td bgcolor="D2E1EE" align="left" colspan="2">
																	<!--- <span style="padding-left: 240px;"> --->
																		<table style="border-bottom: 0;" cellpadding="0" cellspacing="0">
																			<tr>
																				<!--- <td width="200" style="border-bottom : 0">&nbsp;</td> --->
																				<td align="right" width="300" style="border-bottom : 0" colspan="2"><span style="color:Navy; font-weight: bold;"><cfoutput>#GrpName#</cfoutput>&nbsp;&nbsp;::&nbsp;&nbsp;SubTot:$</span></td>
																				<td align="right" width="75" style="border-bottom : 0"><cfoutput><span style="color:Navy; font-weight: bold;" id="GrpSubTot_#trim(CustGrpid)#">#trim(numberformat(GrpTot,'9999999999.99'))#</cfoutput></span></td>
																			</tr>
																		</table>
																	 </td>
																<td colspan="3" bgcolor="D2E1EE">&nbsp;</td>
															</tr>
													</cfif>
													<!--- Display Product Group and Family level Totals  end    ||||||||||||||||||||||||||||||||||||||||| --->
												</CFIF>
												</cfif>  <!--- end (don't run if export to xl is yes) --->
											</CFLOOP>
										</table>
									</td>
								</tr>
							</CFIF>