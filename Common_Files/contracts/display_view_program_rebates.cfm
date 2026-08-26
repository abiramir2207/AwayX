<cfsetting showDebugOutput=yes>
<cfset ADD_DOLLAR_SIGN = true>
<CFIF GetSettings.Discount_Rebates EQ 1>

		<cfsilent>

			<cfscript>
				rebate =  createObject("component","components.programs.rebates.Rebate");
				comp =  createObject("component","components.programs.rebates.RebateComponent");
			</cfscript>
			<!--- For Rebates, Remove the single Quotes --->
			<cfset List_Of_Contract_Main_IDs = Replace(List_Of_Contract_Main_IDs,"'","","ALL")>
			<cfif List_Of_Contract_Main_IDs neq "">
				<cfset rebateData = rebate.loadFromDB(programID=List_Of_Contract_Main_IDs, displayGroupType=displayGroupType,IsDateExclusion= GetSettings.Date_Exclusions_ON,EZButton_On=getsettings.EZButton_On)>
			<cfelse>
				<cfset rebateData = rebate.loadFromDB(programID=CSLGetContractInfo.Contract_Main_ID, displayGroupType=displayGroupType,IsDateExclusion= GetSettings.Date_Exclusions_ON,EZButton_On=getsettings.EZButton_On)>
			</cfif>

		</cfsilent>


<!--- Dev Note: drachala; D28957: Template EZ Button errors  START
Added/Changed: Added if condition to check BIDREQOBJ isdefined id not we will defined it--->
<cfif NOT isdefined("bidReqObj")>
<cfset bidReqObj = CreateObject("component", "components.programs.bid_request.BidRequestManager").getBidRequest(CSLGetContractInfo.Contract_Main_ID) />
</cfif>
<!--- End Dev Note: drachala; D28957: Template EZ Button errors  --->
		<CFSET upc_width=80>
		<CFSET desc_width=100>
		<CFSET volume_width=60>
		<CFSET component_width=95>
		<CFSET base_sales_width=70>
		<CFSET disc_perc_width=45>
		<CFSET saveButton_width=35>

		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 start--->
		<CFQUERY NAME="getFixedComponentInfo" datasource="#application.datasource#">
			SELECT	PFCN.Program_Fixed_Component_Name,
				PFCN.Program_Fixed_Component_Name_Id,
				PFCN.fixed_price_type
			FROM 	Program_Fixed_Component_Name PFCN
			INNER JOIN Program_Fixed_Component PFC ON
				PFC.Program_Fixed_Component_Name_ID = PFCN.Program_Fixed_Component_Name_ID
			WHERE 	PFCN.DELETED = 0 AND
					PFC.Program_ID = #CSLGetContractInfo.Contract_Main_ID# AND
					PFC.Deleted = 0 AND
					PFCN.fixed_price_type IN (1,3)
		</CFQUERY>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 end--->

		<!--- Dev Note: CPM 8223 --->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewPgmSortBy() EQ 0>
			<!--- If there are groups Milan; 11681 --->
			<cfset GroupExist = 0>
			<!---
			Label "D11124: Prg Summary, sort so exceptions/exclusions are with groups they related to"
			made the change so that group programs are sorted based on the group id, so that all pricing levels (general, exception, exclusion) will stay together.
			For some clients this will work as we only allow group at level one and only products belonging to that group at lower levels.
			But for other clients who allow different type of groups to be part of the different pricing levels (general, exception, exclusion), this may not work
			So we will do the sorting based on groups only if lower pricing levels allow only group.
			This can be modified later to use a brand new app setting if needed.
			---->
			<cfif appSettings.getPgmGrpsOnlyProdAtLowerLevel()>
				<!--- If groups exist, then get the required group attribute and sort by that value --->
				<cfloop from="1" to="#ArrayLen(rebateData.aProd)#" index="i">
						<cfif rebateData.aProd[i].IsGroup eq 1>
							<cfset GroupExist = 1>
							<cfset Field_Name =rebate.get_Attribute_Type(#rebateData.aProd[i].masterItemId#)>
							<cfbreak>
						</cfif>
				</cfloop>
			</cfif>
			<!--- Dev Note (77408): When "Product_Group_Sequencing" app setting is ON, then we will always sort by "pricing level" first.  --->
			<cfif GroupExist eq 1 and appSettings.get_Setting('Product_Group_Sequencing') eq '0'>
				<cfset rebateData = rebate.sort(rebateData, "#Field_Name#,pricingLevel", "ASC")>
			<cfelse> <!--- already sorted this way --->
				<cfset rebateData = rebate.sort(rebateData, "pricingLevel,item", "ASC")>
			</cfif>
		<cfelseif application.oApplicationAppSettingsManager.getApplicationAppSettings().getViewPgmSortBy() EQ 1>
			<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
				<cfset rebateData = rebate.sort(rebateData, "pricingLevel,description", "ASC")>
			<cfelse>
			 	<cfset rebateData = rebate.sort(rebateData, "description", "ASC")>
			</cfif>
		</cfif>

		<!--- Dev Note: CPM 9136: Short circuits above functionality; introduced by 8988 CPM bugfix for 3.2--->
		<!--- <cfset rebateData = rebate.sort(rebateData, "ITEM", "ASC")> --->
<!---	<cfdump var="#rebateData#"><cfabort>--->
		<cfif ArrayLen(rebateData.aProd)>
	<cfoutput>

<!--- MAX PRODUCTS START IF--->

<cfif ArrayLen(rebateData.aProd) GT rebate.getMaxProducts()>
	<cfset ProductCustomLabel = #lcase(REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all"))#&'s'>
			<cfset alert_message = "This section is configured to only display #ProductCustomLabel# if there are less than #rebate.getMaxProducts()# #ProductCustomLabel#. To view #ProductCustomLabel# on the program, click the left hand link called Export to Excel.">
			<TR>
				<TD COLSPAN="100%">
					<BR> <BR>
					<B>
					<FONT SIZE="2" COLOR="Navy">
						<cfif TRIM(GetSettings.Generic_Type) EQ "Bid Request">Proposal </cfif> #Application.RebateLabel#s
					#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#s  <img src="/images/help_small.gif" title="#alert_message#" width="12" height="12" /></B>
					</FONT>  Count = #Numberformat(ArrayLen(rebateData.aProd))#
						&nbsp;&nbsp;&nbsp;&nbsp;Click  <a onclick="NewWindow('/common_files/contracts/export2excel.cfm?CID=#URL.CID#&ContractNumber=#CSLGetContractInfo.Contract_Number#','Export','870','720','Yes','No');return false;" tilte="Export to excel">#application.util.string.actionLinkFormat2('export to excel')#</a> to see all products and rates
					<HR COLOR="Navy">
				</TD>
			</TR>

<cfelse>


			<!--- gather all items into an array --->
			<cfset variables.masterItems = []>
			<cfloop index="variables.counter" from="1" to="#arrayLen(rebateData.aProd)#">
				 <cfset arrayAppend(variables.masterItems, rebateData.aProd[ variables.counter ].masterItemId)>
			</cfloop>

			<!--- gather brand information for all items & save in a query ( in a REQUEST variable ) --->
			<cfquery name="request.qBrands" datasource="#application.datasource#">
				SELECT a.BSA_Foodservice_Items_Master_ID
				       ,Brand.Brand_Name
					FROM BSA_Foodservice_Items_Master a
 								INNER JOIN Brand ON a.Brand_ID = Brand.Brand_ID
 				 WHERE <cfif appsettings.getShowBrandOnViewProgram() EQ 1>
 				 			 	BSA_Foodservice_Items_Master_ID IN ( <cfqueryparam cfsqltype="cf_sql_char" list="true" value="#arrayToList(variables.masterItems)#"> )
 				 			 <cfelse>
 				 			  1 = 0
 				 			 </cfif>
			</cfquery>

			<TR>
				<TD COLSPAN="100%">
					<BR> <BR>
					<B><FONT SIZE="2" COLOR="Navy"><cfif TRIM(GetSettings.Generic_Type) EQ "Bid Request">Proposal </cfif> #Application.RebateLabel#s</FONT></B>
					<HR COLOR="Navy">

				<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0" border="0">
				<!--- TABLE HEADERS --->
				<TR BGCOLOR="##FFCE84" VALIGN="bottom">
					<TD ID="header" valign="top" width="125px">
					<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
						<cfif application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1><B>#REReplace(application.returned_customer_setting.upc_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B><cfif appSettings.get_Setting('Display_Item_No') eq '1'>/</cfif></cfif>
					</cfif>
					<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
					<B>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B>
					</cfif>
					</TD>
					<TD ID="header" WIDTH="300" valign="top"><B>Description<cfif appSettings.get_Setting('Product_Group_Sequencing') neq '1' AND appSettings.getViewProgramProductGroupType() neq "-1">/</cfif> </B>
					<!--- If app setting "Product Group to be displayed in View Program", is not set to "None". --->
					<cfif appSettings.get_Setting('Product_Group_Sequencing') neq '1' AND appSettings.getViewProgramProductGroupType() neq "-1">
						<cfif displayGroupType>
							<B>#REReplace(displayGroupTypeDesc, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B>
						<cfelse>
							<strong>Pack Size</strong>
						</cfif>
					</cfif>
					</TD>
					<cfif summaryView>
						<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND ArrayLen(rebateData.aComp) LTE 5>
							<TD ID="header" WIDTH="70" valign="top"><B>Won/Lost </B></TD>
						</cfif>
						<TD ID="header" WIDTH="75" valign="top">
						<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
							<cfif application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1><B>#REReplace(application.returned_customer_setting.upc_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B><cfif appSettings.get_Setting('Display_Item_No') eq '1'>/</cfif></cfif>

						</cfif>
						<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
						<B>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B>
						</cfif>
						</TD>
						<TD ID="header" WIDTH="250" valign="top"><B>DESCRIPTION<cfif appSettings.get_Setting('Product_Group_Sequencing') neq '1' AND appSettings.getViewProgramProductGroupType() neq "-1">/</cfif></B>
							<!--- If app setting "Product Group to be displayed in View Program", is not set to "None". --->
							<cfif appSettings.get_Setting('Product_Group_Sequencing') neq '1' and appSettings.getViewProgramProductGroupType() neq "-1">
								<cfif displayGroupType>
									<B>#REReplace(displayGroupTypeDesc, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</B>
								<cfelse>
									<strong>Pack Size</strong>
								</cfif>
							</cfif>
						</TD>
						<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND ArrayLen(rebateData.aComp) LTE 5>
							<TD ID="header" WIDTH="60" valign="top"><B>Won/Lost </B></TD>
						</cfif>
					</cfif>
					<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
							<TD ID="header" WIDTH="35" valign="top"><B>Similar Product</B></TD>
					</cfif>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 start--->
					<!--- IF  setshowrebateadditionalfields() && 'Single_Component_Per_Discount_Type' mws --->
					<cfif appSettings.getshowrebateadditionalfields() && GetSettings.Single_Component_Per_Discount_Type>
						<!--- D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable--->
						<TD  ID="header" width="#base_sales_width#" nowrap align="right" valign="top"><b>#REReplace(appSettings.getBaseSaleLabel(), "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</b>&nbsp;&nbsp;</TD>
					</cfif>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end--->
					<cfif not summaryView>
						<cfif GetSettings.Date_Exclusions_ON eq 1>
							<TD ID="header" valign="top"><B>Date</B></TD>
						</cfif>
						<cfset CompList ="">

						<cfloop index="i" from="1" to="#ArrayLen(rebateData.aComp)#">

							<!---get the component name--->
							<cfscript>
								qCompName = comp.getComp(rebateData.aComp[i].compNameId);
								qPayToName = comp.getCompPayTo(rebateData.aComp[i].componentPaidTo);
							</cfscript>
							<!------ external id ----->
							<!--- Do not repeat the same component --->
							<cfif GetSettings.Date_Exclusions_ON EQ 0 OR rebateData.aComp[i].ProgramID eq CSLGetContractInfo.Contract_Main_ID>
								<cfset CompList = ListAppend(CompList,qCompName.Program_Rebates_Component_Name)>

									<TD ID="header" valign="top">
										<B>
										<cfif URL.EZTemplate EQ 1>
										<!--- If inside ez template do nto show component name and other details --->
										Rate
										<cfelse>
										#qCompName.Program_Rebates_Component_Name#<br><cfif GetSettings.DispalyPaysToOnViewProgPage EQ 1>#qPayToName.Payment_Paid_To_Type_name#</cfif>
										<!---if the component type is 1 then we pay to distributor, otherwise it's operator---->

										<!--- BJF: Removed with label 13675--->
										<!--- <cfif application.returned_customer_setting.external_id_on EQ 1>
											<cfif Len(qCompName.External_ID) GT 0> (#qCompName.External_ID#)</cfif>
										</cfif> --->
										</cfif>
										&nbsp;
										</B>
									</TD>
								<!--- D38536  :: Alternate recapture rates per component START--->
									<cfif (isDefined("qCompName.Alternate_Recapture_Rate") AND qCompName.Alternate_Recapture_Rate EQ 1) AND not summaryView>
												<cfset useLakebaseForAlternateRateSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alternate_recapture_rate_setting")>
<cfif useLakebaseForAlternateRateSettings>
	<cftry>
		<cfset AlternateRateSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alternate_recapture_rate_setting", {
				"program_rebates_component_name_id" = "eq.#qCompName.Program_Rebates_Component_Name_ID#",
				"status" = "eq.0",
				"select" = "alternate_recapture_rate_label"
			}), "alternate_recapture_rate_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAlternateRateSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAlternateRateSettings>
<cfquery name="AlternateRateSettings" datasource="#application.datasource#">
														SELECT Alternate_Recapture_Rate_Label
														FROM Alternate_Recapture_Rate_Setting
														WHERE Program_Rebates_Component_Name_ID = #qCompName.Program_Rebates_Component_Name_ID#
														AND Status = 0
												</cfquery>
</cfif>

												<cfloop query="AlternateRateSettings">
													<TD ID="header" valign="top">
															<b>#REReplace(Alternate_Recapture_Rate_Label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</b>
													</TD>
												</cfloop>
									</cfif>
								<!--- D38536  :: Alternate recapture rates per component END--->
							</cfif>
							<!--- <TD ID="header"><B><cfoutput>#rebateData.aComp[i].compName#</cfoutput></B></TD> --->
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 start--->
						<!--- IF  setshowrebateadditionalfields() && 'Single_Component_Per_Discount_Type' mws --->
						<cfif appSettings.getshowrebateadditionalfields() && GetSettings.Single_Component_Per_Discount_Type>
							<!--- D28459: Change Base Sales program labels to custom label for Hormel Added This Appsetting Variable--->
							<TD ID="header" width="#base_sales_width#" nowrap align="right" valign="top"><b>#REReplace(appSettings.getNetSaleLabel(), "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</b>&nbsp;&nbsp;</TD>
							<TD ID="header" width="#disc_perc_width#" nowrap align="right" valign="top"><b>Disc %</b>&nbsp;&nbsp;</TD>
						</cfif>
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end--->

						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 start--->
						<!---<cfif appSettings.getUseFixedPriceType()>
							<!--- If the fixed price type is "Deviated price" (Meets Competition) OR Combination (Blended), show the competitor info w = 180, 120, 100--->
							<cfif getFixedComponentInfo.RecordCount>
								<TD ID="header" width="#disc_perc_width#" nowrap align="right" valign="top"><b>Comp Name</b>&nbsp;&nbsp;</TD>
								<TD ID="header" width="#disc_perc_width#" nowrap align="right" valign="top"><b>Dist Cost</b>&nbsp;&nbsp;</TD>
								<TD ID="header" width="#disc_perc_width#" nowrap align="right" valign="top"><b>Time Frame</b>&nbsp;&nbsp;</TD>
							</cfif>
						</cfif>--->
						<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 end--->
						</cfloop>
						<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND ArrayLen(rebateData.aComp) LTE 5>
							<TD ID="header" valign="top"><B>Won/Lost</B></TD>
							</cfif>
						</cfif>
						<!--- TSF: Label 11092 - Removed color coding for group levels and added labels for levels --->
						<cfif appSettings.getAllowMultiLevelGroups() and GroupDataManager.isGroupDeal(CSLGetContractInfo.contract_main_id) and appSettings.get_Setting('Product_Group_Sequencing') eq '0'>
							<td id="header" valign="top"><b>Level</b></td>
						</cfif>
					</TR>



					<!--- begin DATA OUTPUT --->
					<!--- Use the  ProductNumber variable to manage the coloring of cells --->
					<cfset ExistingPricingLevelList = "">
					<cfif not summaryView>
						<cfset UniqueProductList ="">
						<cfset ProductNumber = 0>
						<cfset BgCol_PricingLevel = 0> <!--- Dev Note: KAL; 7612 --->
						<cfset variables.prodcount = 0>
						<cfloop index="i" from="1" to="#ArrayLen(rebateData.aProd)#">
							<cfset variables.prodcount = variables.prodcount + 1>
							<!---TSF: Label D6588 --->
							<!---check to see it the sum of the rates are 0. if they are then don't display--->
							<cfset notZeroRate = 0 />
							<cfif rebateData.aProd[i].isGroup eq 1 OR application.oApplicationAppSettingsManager.getApplicationAppSettings().getPgmGrpLevel3IsExclusion() eq 1 OR appsettings.getdisplayzerosviewprogram() eq 1>
								<cfset notZeroRate = 1 />
							<cfelse>
								<cfloop index="aTmpComp" from="1" to="#ArrayLen(rebateData.aCompVal[i])#">
									<cfif isNumeric(rebateData.aCompVal[i][aTmpComp].rate) and rebateData.aCompVal[i][aTmpComp].rate gt 0>
										<cfset notZeroRate = 1 />
										<cfbreak>
									</cfif>
								</cfloop>
							</cfif>
							<cfif notZeroRate eq 1>

								<cfif ListFind(UniqueProductList,rebateData.aProd[i].masterItemId) eq 0>
									<cfset UniqueProductList = ListAppend(UniqueProductList,rebateData.aProd[i].masterItemId)>
									<cfset ProductNumber = ProductNumber +1>
								</cfif>

								<!---onmouseover menuId--->
								<cfif rebateData.aProd[i].isGroup eq 1>
									<cfset request.menuId = 11 />
									<cfset request.theMOId = "#rebateData.aProd[i].productGroupID#&Group_Level_ID=#rebateData.aProd[i].productGroupLevel#&programId=#CSLGetContractInfo.Contract_Main_ID#&producttype_id=2" />
								<cfelse>
									<cfset request.menuId = 6 />
									<cfset request.theMOId = rebateData.aProd[i].masterItemId />
								</cfif>
							<!--- DATA OUTPUT --->

							<cfset BgCol_1 = "C6FFC6">
							<cfset BgCol_2 = "FFFFFF">
							<!--- Dev Note (77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to "ExistingPricingLevelList".
							This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
							Note: we set "variables.prodcount" back to 1, so that the color coding can restart for a new group.
							thisGroupLevelDesc i.e., "group_level_desc" is shown on a single row.
							--->
							<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1' AND ListFind(ExistingPricingLevelList,rebateData.aProd[i].pricingLevel) eq 0>
								<cfset variables.prodcount = 1>
								<cfset thisGroupLevelDesc = GroupDataManager.getProductGroupsData(rebateData.aProd[i].productGroupLevel).Group_Level_Desc />
								<cfif trim(thisGroupLevelDesc) eq "">
									<cfset thisGroupLevelDesc = "Product" />
								</cfif>
								<tr bgcolor="##92B792">
								<td colspan="100%" >#thisGroupLevelDesc#</td>
								</tr>
								<cfset ExistingPricingLevelList = ListAppend(ExistingPricingLevelList,rebateData.aProd[i].pricingLevel)>
							</cfif>
							<TR BGCOLOR="#IIf(variables.prodcount Mod 2, DE(BgCol_1), DE(BgCol_2))#" VALIGN="top" <cfif NOT isDefined("URL.action_type")> ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
								<TD ID="">
									<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>
										<cfif application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1>
											#rebateData.aProd[i].UPC#<br>
										</cfif>
									</cfif>
									<cfif appSettings.get_Setting('Display_Item_No') eq '1' AND rebateData.aProd[i].GroupNumber eq "">
									#rebateData.aProd[i].ITEM#
									<cfelse>
									#rebateData.aProd[i].GroupNumber#
									</cfif>
								</TD>
								<TD ID="">#rebateData.aProd[i].Description# <!--- <cfif rebateData.aProd[i].GroupNumber neq "">-(#rebateData.aProd[i].GroupNumber#)</cfif> --->
									<!--- If app setting "Product Group to be displayed in View Program", is not set to "None". --->
									<cfif appSettings.getViewProgramProductGroupType() neq "-1">
										<cfif displayGroupType>
											<BR>#rebateData.aProd[i].displayGroupName#
										<cfelse>
												<BR>#rebateData.aProd[i].Pack_Size# #rebateData.aProd[i].Pack_Size_UOM#
										</cfif><br>#rebate.getBrandName( rebateData.aProd[i].masterItemId, request.qBrands)#
									</cfif>
								</TD>
								<cfif CSLGetContractInfo.Like_Product_Exist eq 1>
								<TD ID="">
								<cfset SimilarExistingProduct = ProdManager.getSimilarExistingProduct(CSLGetContractInfo.Contract_Main_ID,rebateData.aProd[i].masterItemId)>
									<cfif SimilarExistingProduct.Recordcount neq 0>Yes<cfelse>No</cfif>
								</TD>
								</cfif>
					<cfif GetSettings.Date_Exclusions_ON eq 1>
					<cfif rebateData.aProd[i].IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
						<TD ID="">#DateFormat(rebateData.aProd[i].Contract_Start_Date, "MM/DD/YYYY")#<br />#DateFormat(rebateData.aProd[i].Contract_End_Date, "MM/DD/YYYY")#</TD>
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
													<!--- If there is a days difference in the current date exclusion end date and the followinf date exclusion start date, get that info --->
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
		<!--- Use the RebateExistsCount variable to add the missing cells (<TD>) --->

		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 start  Single_Component_Per_Discount_Type --->
			 <cfif ArrayLen(rebateData.aComp) EQ 0 && appSettings.getshowrebateadditionalfields() && GetSettings.Single_Component_Per_Discount_Type >
				<cfscript>
					discPerc = 0;
					netSales = 0;
					baseSales = 0;
					thisInvUom = rebateData.aProd[i].productInventoryUOM;
					if(rebateData.aProd[i].BaseSalesCS != 0){
						if(thisInvUom == 'CS'){// CS...
							baseSales = rebateData.aProd[i].BaseSalesCS;
						}
						else if(thisInvUom == 'LB'){// LB...
							baseSales = rebateData.aProd[i].BaseSalesLB;
						}
					}
				</cfscript>
				<TD width="#base_sales_width#" align="right" nowrap>$#numberformat(baseSales,"_,___,____.____")#&nbsp;&nbsp;</TD>
			 </cfif>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end--->

		<cfset RebateExistsCount = 0>
		<cfloop index="n" from="1" to="#ArrayLen(rebateData.aComp)#">
			<cfif rebateData.aCompVal[i][n].compid NEQ "" OR GetSettings.Date_Exclusions_ON EQ 0>
				<cfif rebateData.aCompVal[i][n].UserSelectedUoM>
					<cfset UOM_ID = rebateData.aCompVal[i][n].UserSelectedUoM>
				<cfelse>
					<cfset UOM_ID = rebateData.aCompVal[i][n].uomId>
				</cfif>
			<cfscript>
			thisUom = ViewProgramManager.getUOMDesc(uomId=UOM_ID);
			thisUomId = rebateData.aCompVal[i][n].uomId;
			</cfscript>
			<cfset BasisCodeType = 0 />
			<cfif Display_Basis_Treatment_Code EQ 1>
			<cfif BasisCodeManager.getBasicCodeType(rebateData.aComp[n].BasisCode) EQ "Y">
				<cfset BasisCodeType = 1 />
			</cfif>
			</cfif>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 start  Single_Component_Per_Discount_Type --->
			<cfif appSettings.getshowrebateadditionalfields() && GetSettings.Single_Component_Per_Discount_Type >
				<cfscript>
					discPerc = 0;
					baseSales = 0;
					netSales = 0;
					thisInvUom = rebateData.aProd[i].productInventoryUOM;
					thisRate = rebateData.aCompVal[i][n].rate;
					if(rebateData.aProd[i].BaseSalesCS != 0){
						if(rebateData.aCompVal[i][n].UOMID == 1){// CS...
							baseSales = rebateData.aProd[i].BaseSalesCS;
							discPerc = thisRate / baseSales * 100;
							netSales = baseSales - thisRate;
							//(rebateData.aProd[i].BaseSalesCS - rebateData.aCompVal[i][n].rate);
						}
						else if(rebateData.aCompVal[i][n].UOMID == 2){// LB...
							baseSales = rebateData.aProd[i].BaseSalesLB;
							discPerc = thisRate / baseSales * 100;
							netSales = baseSales - thisRate;
							//(rebateData.aProd[i].BaseSalesLB - rebateData.aCompVal[i][n].rate)/;
						}
						else if(rebateData.aCompVal[i][n].UOMID == 3){// %...
							if(thisInvUom == 'LB'){
								baseSales = rebateData.aProd[i].BaseSalesLB;
							}
							else{
								baseSales = rebateData.aProd[i].BaseSalesCS;
							}
							discPerc = thisRate;
							netSales = baseSales - (thisRate * baseSales);
						}
					}
				</cfscript>
				<TD width="#base_sales_width#" align="right" nowrap>
				#trim(numberformat(baseSales, ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN, rebateData.aCompVal[i][n].UOMID, 1 )))#
				<!--- $#numberformat(baseSales,"_,___,____.____")# --->&nbsp;&nbsp;</TD>
			</cfif>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end--->

			<cfsavecontent variable ="rebatedisplayvalue">


				<!--- 76380 decimal places START--->
					<cfset decimalprecision = GenProgramManager.decimalPrecisionByUOM(rebateData.aCompVal[i][n].uomId,1)>
				<!--- 76380 decimal places END--->

				<cfif BasisCodeType EQ 0>
				<cfif rebateData.aCompVal[i][n].rate neq "" and rebateData.aCompVal[i][n].rate neq 0>
					<!---get uom label--->
					<cfif rebateData.aCompVal[i][n].uomId eq 3>
						<cfif not summaryView>#numberformat(rebateData.aCompVal[i][n].rate, decimalprecision)##thisUom#<br><cfelse>&nbsp;</cfif>
					<cfelseif rebateData.aCompVal[i][n].uomId eq 5><!----- EA ----->
						<cfif not summaryView>
							$#numberformat(rebateData.aCompVal[i][n].rate, decimalprecision)#/#thisUom#
							<cfif appSettings.getPgmDisplayBothRateUOM() AND rebateData.aProd[i].isGroup eq 0><!----- show CS value also ----->
								<cfset product_uom_rebate_rate = rebateData.aCompVal[i][n].rate * rebateData.aProd[i].EAConversion />
								<cfset product_uom = 1 />
								<cfif rebateData.aProd[i].productInventoryUOM EQ "LB"><cfset product_uom = 2 /></cfif>
								<br>$#trim(numberformat(product_uom_rebate_rate, decimalprecision))#/#ViewProgramManager.getUOMDesc(product_uom)#
							</cfif>
							<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
								$#numberformat((rebateData.aCompVal[i][n].rate * CSLGetContractInfo.currency_conversion_factor), decimalprecision)#/#thisUom# (CAD)
							</cfif>
						<cfelse>
							&nbsp;
						</cfif>
					<cfelse>
						<cfif not summaryView>
								$#numberformat(rebateData.aCompVal[i][n].rate, decimalprecision)#/#thisUom#
							<cfif appSettings.getPgmDisplayBothRateUOM() AND (rebateData.aCompVal[i][n].uomId EQ 1 OR rebateData.aCompVal[i][n].uomId EQ 2) AND rebateData.aProd[i].isGroup eq 0>
								<cfif rebateData.aCompVal[i][n].uomId eq 2>
									<br>$#trim(numberformat(ViewProgramManager.getRateInUOM(rebateData.aCompVal[i][n].rate, rebateData.aCompVal[i][n].uomId, rebateData.aProd[i].netWeight), "_.__"))#/#ViewProgramManager.getTheOtherUOMDesc(rebateData.aCompVal[i][n].uomId)#
								<cfelse>
									<br>$#trim(numberformat(ViewProgramManager.getRateInUOM(rebateData.aCompVal[i][n].rate, rebateData.aCompVal[i][n].uomId, rebateData.aProd[i].netWeight), ViewProgramManager.getRateFormatMask()))#/#ViewProgramManager.getTheOtherUOMDesc(rebateData.aCompVal[i][n].uomId)#
								</cfif>
							</cfif>
							<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
								<cfif rebateData.aCompVal[i][n].uomId eq 1>
									<br> $#numberformat((rebateData.aCompVal[i][n].rate * CSLGetContractInfo.currency_conversion_factor), "_.__")#
								<cfelse>
									<br> $#numberformat((rebateData.aCompVal[i][n].rate * CSLGetContractInfo.currency_conversion_factor), ViewProgramManager.getRateFormatMask())#
								</cfif>/#thisUom# (CAD)
							</cfif>
						<cfelse>
							&nbsp;
						</cfif>
					</cfif>
					<cfif rebateData.aComp[n].rebate_type eq 4><br>vol: #numberformat(rebateData.aCompVal[i][n].scanVolume, ViewProgramManager.getVolumeFormatMask())# #ViewProgramManager.getUOMDesc(uomId=rebateData.aCompVal[i][n].uomId, descType=2)# XX-8 </cfif><!----- if scan component, show scan volume also ----->
					<cfset RebateExistsCount = RebateExistsCount + 1>
				<cfelse>
				<cfif appsettings.getdisplayzerosviewprogram()>$#numberformat('0', decimalprecision)#/#thisUom#<cfelse>&nbsp;</cfif>
				</cfif>
				<cfelse><cfset uomDesc = ViewProgramManager.getUOMDesc(rebateData.aCompVal[i][n].basisCodeQuantityUom)/>
					buy #NumberFormat(rebateData.aCompVal[i][n].basisCodeQuantity, ViewProgramManager.getRateFormatMask(0))# #uomDesc#
					<br>get #NumberFormat(rebateData.aCompVal[i][n].basisCodeFreeGoods, ViewProgramManager.getRateFormatMask(0))# #uomDesc# free
				</cfif>
				<!------ D9993: The effectively rate should not display on the view program.
				<cfif Display_Basis_Treatment_Code EQ 1 AND rebateData.aComp[n].EffectiveMarginFlag EQ 1>
				<br>Eff.: #NumberFormat(rebateData.aCompVal[i][n].effectMarginPercent, ViewProgramManager.getPercentFormatMask(0))# %
				</cfif> ----->
			</cfsavecontent>

			 <cfif GetSettings.Date_Exclusions_ON eq 1>
				<cfif rebateData.aProd[i].IsExclusionRevision eq 1 OR ListLen(List_Of_Contract_Main_IDs) eq 1>
					<TD ID="">#rebatedisplayvalue#</TD>
				<cfelse>
					<TD ID="">
						<!--- If there are Date Exclusions --->
						<cfif ListLen(List_Of_Contract_Main_IDs) GT 1>
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
															#rebatedisplayvalue#<br /><br /><br />
														</cfif>
													<cfelse>
														<cfif DECount EQ 0>	#rebatedisplayvalue#<br /><br /> </cfif>
													</cfif>
												</cfif>
													<!--- If the date in the loop matches the date exclusion end date --->
													<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_End_Date) eq 0>
														<!--- If it's not the last row --->
														<cfif DateExclusionDate.currentrow neq DateExclusionDate.recordcount>
															<!--- If there is a days difference in the current date exclusion end date and the followinf date exclusion start date, get that info --->
															<cfif DateDiff('d',DayDate,DateExclusionDate.Contract_Start_Date[DateExclusionDate.currentrow+1]) GT 1>
																#rebatedisplayvalue#<br /><br /><br />
															</cfif>
														<cfelse>
															<!--- If the last date exclusion's end date is not the same as the parent date exclusion start date --->
															<cfif DateDiff('d',DateExclusionDate.Contract_End_Date,getDateExclusionprogramIDs.Contract_End_Date) neq 0>
																#rebatedisplayvalue#
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
			<cfelse>
				<TD>#rebatedisplayvalue#</TD>
			</cfif>

			<cfscript>
				qCompName = comp.getComp(rebateData.aComp[n].compNameId);
			</cfscript>
			<!--- D38536  :: Alternate recapture rates per component START--->
			<cfif (isDefined("qCompName.Alternate_Recapture_Rate") AND qCompName.Alternate_Recapture_Rate EQ 1)  AND not summaryView>
					<cfquery name="AR_Index" datasource="#application.datasource#">
						SELECT	alternate_recapture_rate_index
						FROM	alternate_recapture_rate_setting
						WHERE	Program_Rebates_Component_Name_ID = <cfqueryparam value="#rebatedata.acomp[n].compnameid#" cfsqltype="cf_sql_integer" />
						AND 	STATUS = 0
					</cfquery>

					<cfset ADD_DOLLAR_SIGN = true>
                    <cfset indexlists      = #valuelist(AR_Index.alternate_recapture_rate_index,",")#>

					<cfloop from="1" to="#AR_Index.recordcount#" index="A">

						<cfquery name="Pull_Alternate_Rate_Info" datasource="#application.datasource#">
							SELECT 	rate,
									cast(uom AS INT) AS uomId
							FROM 	Program_Rebate_Alternate_Recapture_Rate
							WHERE 	Contract_Main_ID = <cfqueryparam value="#cslgetcontractinfo.contract_main_id#" cfsqltype="cf_sql_integer" />
							AND 	Contract_Products_ID = <cfqueryparam value="#rebateData.aProd[i].contractprodid#" cfsqltype="cf_sql_integer" />
							AND 	Program_Rebates_Component_ID = <cfqueryparam value="#rebateData.Acomp[n].compid#" cfsqltype="cf_sql_integer" />
							AND 	Alternate_Recapture_Rate_Index = #listgetat(indexlists, A)#
						</cfquery>
						<TD>
							<cfif not summaryView>
								<cfif Pull_Alternate_Rate_Info.recordcount>
									<cfif Pull_Alternate_Rate_Info.uomId EQ 3>
										<!--- Rate Line #1 --->
										#numberformat(Pull_Alternate_Rate_Info.rate, ViewProgramManager.getRateFormatMask(0))# #ViewProgramManager.getUOMDesc(Pull_Alternate_Rate_Info.uomId)#
									<cfelse>
										<!--- CS or LB --->
										<!--- Rate Line #1 --->
										<cfif Pull_Alternate_Rate_Info.uomId eq 1>
											$#numberformat(Pull_Alternate_Rate_Info.rate, "_.__")#
										<cfelse>
											#numberformat(Pull_Alternate_Rate_Info.rate, ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN ))#
										</cfif>/#ViewProgramManager.getUOMDesc(Pull_Alternate_Rate_Info.uomId)#

										<!--- Rate Line #2 --->
										<cfif appSettings.getPgmDisplayBothRateUOM() AND (Pull_Alternate_Rate_Info.uomId EQ 1 OR Pull_Alternate_Rate_Info.uomId EQ 2) AND rebateData.aProd[i].isGroup eq 0>
											<cfif Pull_Alternate_Rate_Info.uomId eq 2>
												<br>$#trim(numberformat(ViewProgramManager.getRateInUOM(Pull_Alternate_Rate_Info.rate, Pull_Alternate_Rate_Info.uomId, rebateData.aProd[i].netWeight), "_.__"))#/#ViewProgramManager.getTheOtherUOMDesc(Pull_Alternate_Rate_Info.uomId)#
											<cfelse>
												<br>$#trim(numberformat(ViewProgramManager.getRateInUOM(Pull_Alternate_Rate_Info.rate, Pull_Alternate_Rate_Info.uomId, rebateData.aProd[i].netWeight), ViewProgramManager.getRateFormatMask()))#/#ViewProgramManager.getTheOtherUOMDesc(Pull_Alternate_Rate_Info.uomId)#
											</cfif>
										</cfif>
										<!--- converter currency --->
										<cfif getFieldSettings.currency_conversion_factor eq "1" AND isNumeric(CSLGetContractInfo.currency_conversion_factor)>
											$#numberformat((Pull_Alternate_Rate_Info.rate * CSLGetContractInfo.currency_conversion_factor), "_.__")# (CAD)
										</cfif>
									</cfif>
								<cfelse>
									&nbsp;
								</cfif>
							<cfelse>
								&nbsp;
							</cfif>
						</TD>
					</cfloop>
			</cfif>
			<!--- D38536  :: Alternate recapture rates per component END--->

			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 start  Single_Component_Per_Discount_Type --->
			 <cfif appSettings.getshowrebateadditionalfields() && GetSettings.Single_Component_Per_Discount_Type >
				<cfscript>
					/* ..............................
						These values are set up above.
						Look for D27183
					................................. */
				</cfscript>
				<TD width="#base_sales_width#" align="right" nowrap>
				#trim(numberformat(netSales, ViewProgramManager.getRateFormatMask( ADD_DOLLAR_SIGN, thisUomId, 1 )))#
				<!--- $#LSNumberFormat(netSales, "(___.___)")# --->
				&nbsp;&nbsp;</TD>
				<TD width="#disc_perc_width#" align="right" nowrap><!--- #LSNumberFormat(discPerc, "(__)")# --->
				#trim(numberformat(discPerc, ViewProgramManager.getRateFormatMask( 0, thisUomId, 1 )))#%&nbsp;&nbsp;</TD>
			 </cfif>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D27183 end--->

			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 start --->
			<cfif getFixedComponentInfo.RecordCount && appSettings.getUseFixedPriceType()>
				<!---<TD width="#base_sales_width#" align="right" nowrap>$#LSNumberFormat(rebateData.aCompVal[i][n].Competitor_Name_ID, "(___.___)")#&nbsp;&nbsp;</TD>
				<TD width="#base_sales_width#" align="right" nowrap>$#LSNumberFormat(rebateData.aCompVal[i][n].Competitor_Price, "(___.___)")#&nbsp;&nbsp;</TD>
				<TD width="#disc_perc_width#"  align="right" nowrap>#LSNumberFormat(rebateData.aCompVal[i][n].Competitor_Time_Frame, "(__)")#%&nbsp;&nbsp;</TD>--->
			</cfif>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx D28445 end--->

										</cfif>
										</cfloop>
									<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND ArrayLen(rebateData.aComp) LTE 5>
										<td>
											<!--- D33201: Competitive Data-Incorrectly Marks Products as Won Start --->
											<cfif #rebateData.aProd[i].IsGroup#>
														<img src="/images/info.png"  onclick="groupinfo('#rebateData.aProd[i].PRODUCTGROUPID#', '#rebateData.aProd[i].Description#')" align="center">
											<cfelse>

														<cfif trim(bidReqObj.getStatus()) eq 1>
															Pending...
														<cfelse>
															<cfset productStatus = BidRequestProductStatusManager.getProgramProductWonInfo(rebateData.aProd[i].masterItemID)/>
															<cfif productStatus eq 1>won
															<cfelseif productStatus eq 0>lost
															<cfelseif productStatus eq 2>split
															<cfelse>pending...
															</cfif>
														</cfif>

											</cfif>
											<!--- D33201: Competitive Data-Incorrectly Marks Products as Won END --->
										</td>
										</cfif>
										<!--- TSF: Label 11092 - Removed color coding for group levels and added labels for levels --->
										<cfif appSettings.getAllowMultiLevelGroups() and GroupDataManager.isGroupDeal(CSLGetContractInfo.contract_main_id) and appSettings.get_Setting('Product_Group_Sequencing') eq '0'>
											<td>#GroupDataManager.getPricingLevel(rebateData.aProd[i].PricingLevel).Pricing_Level_desc#</td>
										</cfif>
									</TR>
									</cfif><!---End notZeroRate--->
								</cfloop>
							<cfelse>
								<!--- make sure list the items horizontally--->
								<cfset productCount = 0 >
								<TR BGCOLOR="F2F2F2">
									<cfloop index="i" from="1" to="#ArrayLen(rebateData.aProd)#">
										<!---onmouseover menuId--->
										<cfif rebateData.aProd[i].isGroup eq 1>
											<cfset request.menuId = 11 />
											<cfset request.theMOId = "#rebateData.aProd[i].productGroupID#&Group_Level_ID=#rebateData.aProd[i].productGroupLevel#&programId=#CSLGetContractInfo.Contract_Main_ID#&producttype_id=2" />
										<cfelse>
											<cfset request.menuId = 6 />
											<cfset request.theMOId = rebateData.aProd[i].masterItemId />
										</cfif>

										<cfif productCount Mod 2 EQ 0>
											</tr>
											<TR BGCOLOR="F2F2F2" <cfif NOT isDefined("URL.action_type")> ONMOUSEOVER="menuID=#request.menuId#;URLstring='';an_ID='#request.theMOId#';doNotRelocate=1;" onmouseout="menuID=0;doNotRelocate=0;" style="cursor: help;"</cfif>>
										</cfif>
										<TD ID="">
											<cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string>

												<cfif application.returned_customer_setting.upc_switch EQ 1 OR GetSettings.Template_UPC_Display EQ 1>
													#rebateData.aProd[i].UPC#<br>
												</cfif>
											</cfif>
											<cfif appSettings.get_Setting('Display_Item_No') eq '1'>
											#rebateData.aProd[i].ITEM#
											</cfif>
										</TD>
										<TD ID="">#rebateData.aProd[i].Description#
											<cfif displayGroupType><BR>#rebateData.aProd[i].displayGroupName#</cfif>
											#rebate.getBrandName( rebateData.aProd[i].masterItemId, request.qBrands)#
										</TD>
										<cfif CSLGetContractInfo.BidRequestStatusOn EQ 1 AND ArrayLen(rebateData.aComp) LTE 5>
										<td>
											<cfif trim(bidReqObj.getStatus()) eq 1>
												Pending...
											<cfelse>
												<cfset productStatus = BidRequestProductStatusManager.getProgramProductWonInfo(rebateData.aProd[i].masterItemID)/>
												<cfif productStatus eq 1>won
												<cfelseif productStatus eq 0>lost
												<cfelseif productStatus eq 2>split
												<cfelse>pending
												</cfif>
											</cfif>
										</td>
										</cfif>
										<!--- TSF: Label 11092 - Removed color coding for group levels and added labels for levels --->
										<cfif appSettings.getAllowMultiLevelGroups() and GroupDataManager.isGroupDeal(CSLGetContractInfo.contract_main_id) and appSettings.get_Setting('Product_Group_Sequencing') eq '0'>
											<td>#GroupDataManager.getPricingLevel(rebateData.aProd[i].PricingLevel).Pricing_Level_desc#</td>
										</cfif>
										<cfset productCount = productCount + 1 >
									</CFLOOP>
								</TR>
							</cfif>
					<!--- END DATA OUTPUT --->
					</TABLE>
				</TD>
			</TR>
		</cfif>
</cfoutput>


			<!--- D13547 Start component key display --->
	<cfif URL.EZTemplate EQ 0>
	<TR>
		<TD COLSPAN="100%">

		<table width="100%" border="0">
			<tr><td colspan="2">
		<!------ Rebate Component information ----->
		<!--- Dev Note: drachala; D28861: Show / Hide component information  START
		Added/Changed: Added <A HREF> AND ID in TR--->
		<strong>Additional component information:</strong><a href="##" id="toggleRebateComponent" style="margin-left:5px;"></a>
		</td></tr>
		<cfif (ArrayLen(rebateData.aComp) GTE 2)>
			<cfset compWidth = 100/ArrayLen(rebateData.aComp)/>
		<cfelse>
			<cfset compWidth = 50 />
		</cfif>
		<tr id="eligibleRebateComponent"><td width="#compWidth#%" valign="top">

		<cfloop index="i" from="1" to="#ArrayLen(rebateData.aComp)#">

		<cfoutput>
			 <cfquery name="GetRebateCompInformation" datasource="#application.datasource#">
				SELECT	Program_Rebates_Component_Name.Off_Invoice_On,
						Program_Rebates_Component_Name.Program_Rebates_Component_Name,
						Payment_Type.Payment_Type_Name,
						Payment_Type.Restrict_From_Billback,
						Payment_Type.Is_Auto_Pay,
						Program_Rebates_Component.Component_Paid_To,
						Program_Rebates_Component.Claim_Mechanics,
						Program_Rebates_Component.Program_Rebates_Component_ID,
						Program_Rebates_Component.Vendor_Selection,
						Program_Rebates_Component.Vendor_Master_ID,
						GL_Account.GL_Account,
						GL_Account.GL_Account_Desc,
						isnull(nullif(Program_Rebates_Component.Payee_Type,''),0) As Payee_Selection
						<!--- D58135 ::  Additional Component info displaye inside program START--->
						,Program_Rebates_Component_Name.ID_on_ViewProgramPage
						,Program_Rebates_Component_Name.DeductionAccount_on_ViewProgramPage
						,Program_Rebates_Component_Name.PaymentAccount_on_ViewProgramPage
						,Program_Rebates_Component_Name.External_ID
						,Program_Rebates_Component_Name.Deduction_Account
						,Program_Rebates_Component_Name.Payment_Account
						<!--- D58135 ::  Additional Component info displaye inside program END--->
				FROM 	Program_Rebates_Component
						LEFT JOIN Payment_Type ON
						Payment_Type.Payment_Type_ID = Program_Rebates_Component.Claim_Mechanics
						LEFT JOIN GL_Account
						ON GL_Account.GL_Account_ID = Program_Rebates_Component.GL_Account_ID
						INNER JOIN Program_Rebates_Component_Name ON
						Program_Rebates_Component_Name.Program_Rebates_Component_Name_ID = Program_Rebates_Component.Program_Rebates_Component_Name_ID
				WHERE 	Program_Rebates_Component.Program_Rebates_Component_ID = '#rebateData.aComp[i].compid#'
				AND		Program_Rebates_Component.Program_ID = #CSLGetContractInfo.Contract_Main_ID#
				AND		Program_Rebates_Component.Deleted = 0
			</cfquery>

				<!--- If the Payee is the "Distributor" in the "Billback_Closing_Method" settings in the settings panel --->
				<cfif GetRebateCompInformation.Payee_Selection eq 1>
					<cfset qryDistributor = objDistributor.getDistributor(GetRebateCompInformation.Vendor_Master_ID)>
				<cfelse>
					<cfset qryVendor = objVendor.getVendorInfo(GetRebateCompInformation.Vendor_Master_ID)>
				</cfif>

				<em>#GetRebateCompInformation.Program_Rebates_Component_Name#</em>: <br>
				<li>Paid to: <cfif (GetRebateCompInformation.Component_Paid_To NEQ "")>#templateManager.getPaymentPaidToTypeDesc(paidToID = GetRebateCompInformation.Component_Paid_To, paidToDesc="")#</cfif></li>
				<!--- Vendor_Selection eq 1 means 'pay to a single vendor', Vendor_Selection eq 2 means 'pay individually'--->
				<cfif GetRebateCompInformation.Is_Auto_Pay eq 1>
				<li>Payee:&nbsp;<cfif GetRebateCompInformation.Vendor_Master_ID neq ""><cfif GetRebateCompInformation.Payee_Selection eq 1>#qryDistributor.Name# (#qryDistributor.Shr_Ship_To#)<cfelse>#qryVendor.Vendor_Name# (#qryVendor.Vendor_ID#)</cfif><cfelse><cfif GetRebateCompInformation.Vendor_Selection eq 2>Pays each individually<cfelseif GetRebateCompInformation.Vendor_Selection eq 3>Payee from planning groups</cfif></cfif></li>
				</cfif>
				<cfif appSettings.getPaymentCycleAtDiscountType()>
				<li>Payment Cycle:
				<cf_payment_cycle_selection
					Template_ID = "#CSLGetContractInfo.ProgramType_ID#"
					Program_ID = "#CSLGetContractInfo.Contract_Main_ID#"
					discount_Type_ID = "2"
					Selected_Payment_Cycle_ID = ""
					Component_ID = "#GetRebateCompInformation.Program_Rebates_Component_ID#"
					Action = "display"
					></li>
				</cfif>

				<cfif appSettings.getGL_Account_On()>
				<li>#Application.GLAccountLabel#: #GetRebateCompInformation.GL_Account_Desc# (#GetRebateCompInformation.GL_Account#)</li><!---D42774 --->
				</cfif>
				<cfif appSettings.getClaims_at_Comp_Level()><li>Claim Mechanic: #paymenttypeManager.getDesc(GetRebateCompInformation.Claim_Mechanics)#</li></cfif>
				<cfif len(trim(GetRebateCompInformation.Off_Invoice_On)) GT 0>
					<cfif GetRebateCompInformation.Off_Invoice_On IS 1>
						<li>Off Invoice: Yes</li>
					<cfelse>
						<li><!--- Not Off Invoice --->Off Invoice: No</li>
					</cfif>
				</cfif>
				<cfif len(trim(GetRebateCompInformation.Restrict_From_Billback)) GT 0>
					<cfif GetRebateCompInformation.Restrict_From_Billback IS 1>
						<li>Restricted from Billbacks: Yes</li>
					<cfelse>
						<li><!--- Available for Billbacks --->Restricted from Billbacks: No</li>
					</cfif>
				</cfif>
				<cfif len(trim(GetRebateCompInformation.Is_Auto_Pay)) GT 0>
					<cfif GetRebateCompInformation.Is_Auto_Pay IS 1>
						<li>Auto Pay: Yes</li>
					<cfelse>
						<li><!--- Not Auto Pay --->Auto Pay: No</li>
					</cfif>
				</cfif>
				<!--- D58135 ::  Additional Component info displaye inside program START--->
				<cfset ID = LabelComp.getGeneralLabels('Rebate External ID')>
				<cfset DeductionAccount = LabelComp.getGeneralLabels('Deduction Account')>
				<cfset PaymentAccount = LabelComp.getGeneralLabels('Payment Account')>

				<cfif application.returned_customer_setting.external_id_on EQ 1 AND GetRebateCompInformation.ID_on_ViewProgramPage>
					<li>#ID.General_Labels_Label#: #GetRebateCompInformation.External_ID#</li>
				</cfif>
				<cfif GetRebateCompInformation.DeductionAccount_on_ViewProgramPage>
					<li>#DeductionAccount.General_Labels_Label#: #GetRebateCompInformation.Deduction_Account#</li>
				</cfif>
				<cfif GetRebateCompInformation.PaymentAccount_on_ViewProgramPage>
					<li>#PaymentAccount.General_Labels_Label#: #GetRebateCompInformation.Payment_Account#</li>
				</cfif>
				<!--- D58135 ::  Additional Component info displaye inside program END--->
				<li>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")# Count: #ArrayLen(rebateData.aProd)#</li>

			</td><td valign="top">

			</cfoutput>
		</cfloop>
		</td></tr>
		</table>
		</TD>
	</TR>
	</cfif>
			<!------ Start Clause Code ----->
			<cfset getProgramClause = clauseProgramManager.getProgramClause(CSLGetContractInfo.Contract_Main_ID, 2, 2)>
			<cfif getProgramClause.recordCount>
			<cfoutput><TR>
				<TD COLSPAN="100%">

				<BR>
				<!------ Rebate Clauses ----->
				<cfinclude template="/Clause_Library/clause_program_display.cfm">
				</TD>
			</TR></cfoutput>
			</cfif>
			<!------ End  Clause Code ----->
		</cfif>
	</CFIF>
<cfoutput>
<!--- D33201: Competitive Data-Incorrectly Marks Products as Won Start --->
<script>
 function groupinfo(groupid, groupname){
		 window.open("/common_files/contracts/bid_request/group_won_lost_info.cfm?Contract_Main_ID=#CSLGetContractInfo.Contract_Main_ID#&groupId="+groupid+"&groupname="+groupname, "Group_Items_Status", "location=0, status=0, scrollbars=0, menubar=0, resizable =1,  width=800, height=620");
 }
</script>
<!--- D33201: Competitive Data-Incorrectly Marks Products as Won END --->
</cfoutput>