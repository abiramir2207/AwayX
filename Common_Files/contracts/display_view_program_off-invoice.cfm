	<CFIF GetSettings.Generic_Type IS "Distributor Off-Invoice">

	<cfset qGetOIProgramComponents = ViewProgramManager.getOIProgramComponents(CSLGetContractInfo.Contract_Main_ID) />	
	<cfset getOffInvoice  = ViewProgramManager.getOffInvoice(CSLGetContractInfo.Contract_Main_ID, displayGroupType)>
	
	<cfif getOffInvoice.recordcount GT 0>
	
		<cfoutput>
	
		<TR>
			
			<TD COLSPAN="100%">
				<BR><BR>
				<B><FONT SIZE="2" COLOR="Navy">Off Invoice</FONT></B>
				<HR COLOR="Navy">
				
				<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0" border="0">
				
					<!--- TABLE HEADERS --->
					<TR BGCOLOR="##FFCE84" VALIGN="bottom">
						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
							<cfif application.returned_customer_setting.upc_switch EQ 1>
								<TD ID="header" WIDTH="70">
									<B>#application.returned_customer_setting.upc_label#</B>
								</TD><br>
							</cfif>
						</cfif>
						<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
						<TD ID="header">
							<B>#application.returned_customer_setting.item_label#</B>
						</TD>
						</cfif>
						<TD ID="header" WIDTH="200">
							<B>DESCRIPTION</B>
						</TD>
						<cfif displayGroupType>
							<TD ID="header" WIDTH="110">
								<B>#displayGroupTypeDesc#</B>
							</TD>
						</cfif>
						<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
							<TD ID="header" WIDTH="35"><B>Similar Product</B></TD>
						</cfif>
						<cfloop query="qGetOIProgramComponents">
						<TD ID="header" WIDTH="100" ALIGN="RIGHT">
							<B>#Program_OffInvoice_Component_Name#</B>
						</TD>
						</cfloop>
						<!--- TSF: Label 11092 - Removed color coding for group levels and added labels for levels --->
						<cfif appSettings.getAllowMultiLevelGroups() and GroupDataManager.isGroupDeal(CSLGetContractInfo.contract_main_id)>
							<td valign="top" align="right"><b><span style="font-size:12px">Level</span></b></td>
						</cfif>
					</TR>
					
			</cfoutput>
					<cfset BgCol_PricingLevel = "" />
					<!--- begin DATA OUTPUT --->
					<cfset prodCounter = 0 />
					<CFOUTPUT QUERY="getOffInvoice" group="BSA_Foodservice_Items_Master_ID">
						<cfset prodCounter = prodCounter + 1 />
						<!---onmouseover menuId--->
						<cfif Is_Group eq 1>
							<cfset request.menuId = 11 />
							<cfset request.theMOId = "#Product_Group_ID#&Group_Level_ID=#Product_Group_Level_ID#&programId=#CSLGetContractInfo.Contract_Main_ID#&producttype_id=8" />
						<cfelse>
							<cfset request.menuId = 6 />
							<cfset request.theMOId = BSA_Foodservice_Items_Master_ID />
						</cfif>

						<cfset BgCol_1 = "C6FFC6">
						<cfset BgCol_2 = "FFFFFF">						
						<!--- DATA OUTPUT --->
						<TR BGCOLOR="#IIf(prodCounter Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;">
							<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
								<cfif application.returned_customer_setting.upc_switch EQ 1>
									<TD ID="">
										#UPC#&nbsp;
									</TD>
								</cfif>
							</cfif>
							<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
							<TD ID="">
								#ITEM#&nbsp;
							</TD>
							</cfif>
							<TD ID="">
								#Description#
							</TD>
							<cfif displayGroupType>
								<TD ID="">
									#DisplayGroupName#
								</TD>
							</cfif>	
							<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
							<TD ID="">		
							<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(CSLGetContractInfo.Contract_Main_ID,BSA_Foodservice_Items_Master_ID)>
							<cfif SimilarExistingProduct.Recordcount neq 0>Yes<cfelse>No</cfif>
							</TD>
							</cfif>
							<cfoutput group="Program_OffInvoice_Component_Name_ID">
							<cfset Basis_Code_Type = 0 />
							<cfif Display_Basis_Treatment_Code EQ 1>
							<cfif BasisCodeManager.getBasicCodeType(Basis_Code_Master_ID) EQ "Y">
								<cfset Basis_Code_Type = 1 />
							</cfif>
							</cfif>
							<TD ID="" NOWRAP ALIGN="RIGHT">								
								<cfif not summaryView>
								<cfif Basis_Code_Type EQ 0>
								<font color="<cfif plus_minus IS 1>blue<cfelse>red</cfif>">
								<!--- Show the negative numbers with a bracket --->
								<cfif plus_minus IS 1>+<cfelse>(</cfif>
								<cfif UOM IS 1 OR UOM IS 2>
									#NumberFormat(Discount_Amount, ViewProgramManager.getRateFormatMask(0))#<cfif plus_minus IS NOT 1>)</cfif> per #ViewProgramManager.getUOMDesc(UOM)#									
								<cfelse>
									#NumberFormat(Discount_Amount, '___.__')#<cfif plus_minus IS NOT 1>)</cfif>%
								</cfif>
								
								<cfif appSettings.getPgmDisplayBothRateUOM() AND (UOM EQ 1 OR UOM EQ 2)>
								<br><cfif plus_minus IS 1>+<cfelse>(</cfif> #trim(numberformat(ViewProgramManager.getRateInUOM(Discount_Amount, UOM, Net_Weight), ViewProgramManager.getRateFormatMask(0)))#<cfif plus_minus IS NOT 1>)</cfif> per #ViewProgramManager.getTheOtherUOMDesc(UOM)#
								</cfif>
								</font>
								<cfelse>
								buy #NumberFormat(Basis_Code_Quantity, ViewProgramManager.getRateFormatMask(0))# #ViewProgramManager.getUOMDesc(Basis_Code_Quantity_UOM)# 
								<br>get #NumberFormat(Basis_Code_Free_Goods, ViewProgramManager.getRateFormatMask(0))# #ViewProgramManager.getUOMDesc(Basis_Code_Free_Goods_UOM)# free
								</cfif>
								<!------ D9993: The effectively rate should not display on the view program.
								<cfif Effective_Margin_Flag EQ 1>
								<br>Eff.: #NumberFormat(Effective_Margin_Percent, ViewProgramManager.getPercentFormatMask(0))# %
								</cfif> ----->
								<cfelse>&nbsp;</cfif>								
							</TD>
							<!--- TSF: Label 11092 - Removed color coding for group levels and added labels for levels --->
							<cfif appSettings.getAllowMultiLevelGroups() and GroupDataManager.isGroupDeal(CSLGetContractInfo.contract_main_id)>
								<td align="right">#GroupDataManager.getPricingLevel(getOffInvoice.PRICING_LEVEL_ID).Pricing_Level_desc#</td>
							</cfif>
							</cfoutput>
						</TR>
							
					</CFOUTPUT>					
				
					<!--- end DATA OUTPUT --->
					
				</TABLE>
		</TD>
		
	</TR>
	
	<!------ Start Clause Code ----->
	<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 2, 8)>
	<cfif getProgramClause.recordCount>
	<cfoutput><TR>
		<TD COLSPAN="100%">
		<BR>
		<!------ Off-invoice Clauses ----->
		<cfinclude template="/Clause_Library/clause_program_display.cfm">		
		</TD>
	</TR></cfoutput>
	</cfif>
	<!------ End  Clause Code ----->
	</cfif>
	</CFIF>