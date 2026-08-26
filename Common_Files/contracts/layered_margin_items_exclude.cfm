<!---
	Copyright (c)2010 Blacksmith Applications, Inc.       
	Filename:		AwayX\Common_Files\contracts\layered_margin_items_exclude.cfm
	Created:		9/16/2010
	Developer:		kvangapalli
	Description:	This page displays the margin section and their summary for the items exluded in the margin.
					The original top section on margin only shows the items not excluded in margin.
	Usage:			<templates that depend on this file>
					layered_program_approval.cfm
	Tip:			app setting should be on for this file to be included
--->
<!--- Earlier, we had a <fieldset> here. <fieldset> behaves as a parent of <TR> if we need to use prototype or jquery code
($('excludeditems').siblings().invoke('toggle')) - Prototype code.
The above code will hide and show what is inside this <fieldset> and it works perfectly for versions below IE 10. For versions
before IE 10, <table> becomes the parent of <TR> and so the entire table gets hidden (entire margin page). 
So, <fieldset> was removed from here ans it was not needed.
--->
<cfoutput query="getAllExcludedProductMargins" group="Type_Code_Desc_ID">
	<!--- mass approve --->
	<cfset itemCheckBoxDisabled = 0 />
	<cfset getGroupvalues = "" />
	<cfquery name="getGroupvalues" dbtype="query">
		select * from getAllExcludedGroupMargins where Type_Code_Desc_Id = '#getAllExcludedProductMargins.Type_Code_Desc_Id#' 
	</cfquery>
	<!--- add variation to group margin --->
	<cfif trim(getGroupvalues.Group_ID_Margin) EQ "">
		<cfset getGroupvalues.Group_ID_Margin = 0 />
	</cfif>

	<cfset groupapprovalmargin = "*" />
	<cfset groupTargetCaseRateUOM = Target_Case_Rate_UOM />
	<cfset groupTargetCaseRate = Target_Case_Rate />
	<cfset groupTargetLBRate = Target_LB_Rate />

	<cfoutput>
		<!--- check if the profile has rights to have base view --->
		<cfif Get_Profile_Settings.Base_View EQ 1>
			<tr id="excludeditems" valign="top"><td colspan="all" style="border-bottom: 0px">&nbsp;</td></tr>

			<tr id="excludeditems" bgcolor="#itemtrbgcolor#" valign="top">
				<td width="150" class="forceLeft">
					<cfif form.margin_type EQ 2>
						<span style="cursor:pointer;" onmouseover="initTheTooltip('Stat Case Value:#trim(numberformat(CASE_EQUIVALENT,'_-___,___,___,___,___.___'))#')" onmouseout="popOut()">#Description# #Item#</span>
					<cfelse>
						#Description# #Item# 
					</cfif>
				</td>
				<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
				<cfif variables.bDisplayContractPrice>
					<!--- 16314 [begin] style="border-left: 1px black;" --->
					<td class="verticalBorders padRight" align="right" nowrap>
						<cfsilent>
							<!---
								form.margin_type
								variables.Program_ID
								variables.getAllExcludedProductMargins.Product_ID
								--->
							<cfif form.margin_type EQ 2>
								<cfquery name="qGetStatValue" datasource="#application.datasource#">
									SELECT ISNULL(CAST(CASE_EQUIVALENT as float),0) as CASE_EQUIVALENT
									FROM BSA_Foodservice_Items_Master
									where BSA_Foodservice_Items_Master_ID = '#variables.getAllExcludedProductMargins.Product_ID#'
								</cfquery>
								<cfset statMultiplier = qGetStatValue.CASE_EQUIVALENT />
								<cfif NOT statMultiplier>
									<cfset multiplier = "*" />
								<cfelse>
									<cfset multiplier = "/" />
								</cfif>
							<cfelseif form.margin_type EQ 3>
								<cfquery name="qGetNetValue" datasource="#application.datasource#">
									SELECT ISNULL(CAST(NET_WEIGHT as float),0) as NET_WEIGHT
									FROM BSA_Foodservice_Items_Master
									where BSA_Foodservice_Items_Master_ID = '#variables.getAllExcludedProductMargins.Product_ID#'
								</cfquery>
								<cfif NOT qGetNetValue.NET_WEIGHT>
									<cfset Net = 1 />
								<cfelse>
									<cfset Net = qGetNetValue.NET_WEIGHT[1] />
								</cfif>
								<cfset statMultiplier = Net />
								<cfset multiplier = "/" />
							<cfelseif form.margin_type EQ 4>
								<cfquery name="qGetVolume" datasource="#application.datasource#">
			                        SELECT ISNULL(Product_Program_Volume_CS,0) as Volume_Equivalent
			                        FROM contract_product_margin
			                        where product_id = '#variables.getAllExcludedProductMargins.Product_ID#'
			                        and deleted = 0
			                        and contract_main_id = '#contract_main_id#'
								</cfquery>
								<cfset statMultiplier = qGetVolume.Volume_Equivalent />
								<cfset multiplier = "*" />
							<cfelse>
								<cfset statMultiplier = 1 />
								<cfset multiplier = "*" />
							</cfif>
							<cfquery name="qGetContractPrice" datasource="#application.datasource#">
			                    SELECT ISNULL(FPR_CS,0) as Fixed_Price_CS
			                    FROM        dbo.Contract_Product_Margin
			                    INNER JOIN BSA_Foodservice_Items_Master
			                    ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Product_Margin.Product_Id
			                    --AND BSA_Foodservice_Items_Master.deleted = 0
			                    LEFT JOIN Type_Group_Desc
			                    ON Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID
			                    AND Type_Group_Desc.deleted = 0
			                    LEFT JOIN Group_Approval_Rights
			                    ON Group_Approval_Rights.Group_ID = Type_Group_Desc.Type_Group_Desc_ID
			                    AND Group_Approval_Rights.User_Profile_ID = #request.Accessstructure.Profiles_ID# 
			                    AND Group_Approval_Rights.deleted = 0
			                    WHERE Contract_Main_ID = #contract_main_id#
			                    AND Contract_Product_Margin.product_id = '#getAllExcludedProductMargins.Product_ID#'
							</cfquery>
							<cfset fixed_price = "#qGetContractPrice.Fixed_Price_CS##multiplier##statMultiplier#" />
							<cfset fixed_price = evaluate(fixed_price) />
							<!--- do we have more than 1 fixed component for this program ? [begin] --->
							<cfquery name="qGetFixedComponentIDs" datasource="#application.datasource#">
			                    SELECT 	Program_Fixed_Component_ID
			                    FROM 	Program_Fixed_Component
			                    WHERE 	Program_ID = #contract_main_id#
			                    AND		deleted = 0
							</cfquery>
							<!--- do we have more than 1 fixed component for this program ? [end] --->
						</cfsilent>
						<!--- D17218 [begin] 
							<span onmouseover="initTheTooltip('The value represents the fixed price offered on the program for this item.')" onmouseout="popOut()" style="cursor:help;>
							D17218 [end] --->
						<!--- if we are negative... --->
						
							#application.util.string.cellFormat(value=fixed_price ,decimalplaces = request.dollar_format)#
						<!--- D17218 [begin]      
							</span>
							D17218 [end] --->
						<!--- $#trim(numberformat(fixed_price,'_-___,___,___,___,___.____'))# --->
						<cfif qGetFixedComponentIDs.recordCount GT 1>
							<span class="redLarge">*</span>
						</cfif>
					</td>
					<!--- 16314 [end] --->
				</cfif>
				<!--- 17289 > 16314 follow up 10/14/08 [end] --->
				<td align="right" nowrap>
					#trim(numberformat(Round(Product_Program_Volume),'_-___,___,___,___,___'))#
				</td>

				<td align="right" nowrap>
					<a STYLE="cursor:pointer;" ONCLICK="showBaseSalesDetails('#replace(Product_Id, "-", "_", "ALL")#')">#application.util.string.cellFormat(value=Base_Sales ,decimalplaces = request.dollar_format)#</a> 
				</td>
				
				<cfif margin_display_style eq "custom_t">
					<!--- ALlow/Surch column ---->
					<td align="right" nowrap>
						#application.util.string.cellFormat(value=Allowance_Surcharges ,decimalplaces = request.dollar_format)#
					</td>

					<!--- Customer Freight column ---->
					<td align="right" nowrap>
						#application.util.string.cellFormat(value=Customer_Freight ,decimalplaces = request.dollar_format)#
					</td>
				</cfif>

				<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
				<!--- Display Cash Discount only if the app setting is on. This setting is off when margin = trade percent of gross sales. --->
				<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
					<cfif direct_pricing EQ 0 and appsettings.getlocalcostvariables() neq 1>
						<td align="right" nowrap>
							<cfif appsettings.getlocalcostvariables() eq 2>
								<A STYLE="cursor:pointer;" ONCLICK="showCashDiscountDetails('#replace(Product_Id, "-", "_", "ALL")#')"> 
							</cfif>
							#application.util.string.cellFormat(value=Cash_discount ,decimalplaces = request.dollar_format)#
							<cfif appsettings.getlocalcostvariables() eq 2>
								</a> 
						</td>
						</cfif> 
					</cfif>
					<cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing EQ 0>
						<td align="right" nowrap>
							<A STYLE="cursor:pointer;" ONCLICK="showLocalCostCalculation('#replace(Product_Id, "-", "_", "ALL")#','L','')"> #application.util.string.cellFormat(value=Cash_discount ,decimalplaces = request.dollar_format)#</A> 
						</td>
					</cfif>
				</cfif>
				<cfif direct_pricing EQ 0>
					<!--- ******* Allowance column ******* --->
					<td align="right" nowrap>
						<A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','A','')"> 
						<cfif appSettings.getApprovalMarginType() eq 2>
							<cfset Allowance_Display_Value = Item_Allowance_Annualized />
						<cfelse>
							<cfset Allowance_Display_Value = Item_Allowance />
						</cfif>
						
						#application.util.string.cellFormat(value=Allowance_Display_Value ,decimalplaces = request.dollar_format)#
						</A> 
					</td>
					<!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
					<!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Allowance_Display_Value". 
					I could have used IsDefined("Allowance_Display_Value") to show or hide this column, but it was simpler to just rely on the logic for "Allowance_Display_Value",
					as the below calculated value relies on ""Allowance_Display_Value".
					--->
					<td align="right" nowrap>
						<cfif Allowance_Display_Value EQ 0 OR Base_Sales EQ 0>
							N/A
						<cfelseif Allowance_Display_Value LT 0>
							0%
						<cfelse>
						<cfset Allowance_Percent = (Allowance_Display_Value/Base_Sales) * 100>
							#application.util.string.cellFormat(value=Allowance_Percent ,decimalplaces = request.numeric_format)# %
						</cfif>
					</td>
				</cfif>
				<cfif ShowTPA EQ 1>
					<cfif margin_display_style eq "custom_t">
						<!--- ******* TPA Operator column ******* --->
						<td align="right" nowrap>
							<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation('#replace(Product_Id, "-", "_", "ALL")#',1)">
							
							#application.util.string.cellFormat(value=TPA_Oper ,decimalplaces = request.dollar_format)#
							</A> 
						</td>
					</cfif>

					<!--- ******* TPA Distributor (Distributor Trade) column ******* --->
					<td align="right" nowrap>
						<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation('#replace(Product_Id, "-", "_", "ALL")#',0)">
						
						#application.util.string.cellFormat(value=TPA ,decimalplaces = request.dollar_format)#
						</A> 
					</td>
				</cfif>
				<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
					<td align="right" nowrap>
						<A STYLE="cursor:pointer;" ONCLICK="showPullbackCalculation('#replace(Product_Id, "-", "_", "ALL")#')"> 
						
						#application.util.string.cellFormat(value=Pullbackamount ,decimalplaces = request.dollar_format)#
						</A> 
					</td>
				</cfif>
				<cfif margin_display_style eq "custom_t">
					<!--- ******* Other Spend column ******* --->
					<td align="right" nowrap>
						
						#application.util.string.cellFormat(value=Other_Spend ,decimalplaces = request.dollar_format)#
					</td>
				</cfif>
				<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 0>
					<td align="right" nowrap>
						<A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','N','')"> 
						
						#application.util.string.cellFormat(value=Net_Sales ,decimalplaces = request.dollar_format)#
						</A> 
					</td>
				</cfif>
		</cfif>

		<cfif Get_Profile_Settings.View_Cost EQ 1>
			<td align="right" nowrap>
				<A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','C','')"> #application.util.string.cellFormat(value=Cost ,decimalplaces = request.dollar_format)#</A> 
			</td>
		</cfif>

		<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
			<td align="right" nowrap>
				<A STYLE="cursor:pointer;" ONCLICK="showBrokerage('#replace(Product_Id, "-", "_", "ALL")#')"> #application.util.string.cellFormat(value=Broker_Cost ,decimalplaces = request.dollar_format)#</A> 
			</td>
		</cfif>

		<cfif margin_display_style eq "custom_t">
			<!--- ******* Shuttle Freight column ******* --->
			<td align="right" nowrap>
				
				#application.util.string.cellFormat(value=Shuttle_Freight ,decimalplaces = request.dollar_format)#
			</td>

			<!--- ******* Warehouse column ******* --->
			<td align="right" nowrap>
				
				#application.util.string.cellFormat(value=Custom_Warehouse ,decimalplaces = request.dollar_format)#
			</td>

			<!--- ******* Gross Margin column ******* --->
			<td align="right" nowrap>
				
				#application.util.string.cellFormat(value=Gross_Margin ,decimalplaces = request.dollar_format)#
			</td>

			<!--- ******* Brokerage column ******* --->
			<td align="right" nowrap>
				
				#application.util.string.cellFormat(value=Custom_Brokerage ,decimalplaces = request.dollar_format)#
			</td>

			<!--- ******* Contribution Margin column ******* --->
			<td align="right" nowrap>
				
				#application.util.string.cellFormat(value=Contribution_Margin_Alt ,decimalplaces = request.dollar_format)#
			</td>

			<!--- ******* Variable Contribution Margin column ******* --->
			<td align="right" nowrap>
				
				#application.util.string.cellFormat(value=Variable_Contribution_Margin ,decimalplaces = request.dollar_format)#
			</td>

			<!--- ******* MAP and MDF column ******* --->
			<td align="right" nowrap>
				
				#application.util.string.cellFormat(value=Map_Mdf ,decimalplaces = request.dollar_format)#
			</td>

			<!--- ******* SG & A column ******* --->
			<td align="right" nowrap>
				
				#application.util.string.cellFormat(value=SGA ,decimalplaces = request.dollar_format)#
			</td>
		</cfif>

		<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
			<td align="right" nowrap>
				
					#application.util.string.cellFormat(value=Operating_Income ,decimalplaces = request.dollar_format)#
					<!---Tim Ford - Label 19381: Show if the Program is a revision and Operating Income is different from Revised program--->
					<cfif Program_Is_A_Revision and isDefined("getProductPreviousVersionMargins")>
						<cfquery name="qGetPreviousOperatingIncome" dbtype="query">
							SELECT Operating_Income, OperatingMargin_percent FROM getProductPreviousVersionMargins WHERE Product_ID = '#Product_ID#' 
						</cfquery>
						<cfif qGetPreviousOperatingIncome.RecordCount>
							<cfif DecimalFormat(qGetPreviousOperatingIncome.Operating_Income) neq DecimalFormat(Operating_Income)>
								&nbsp; 
								<CF_SmallHelp width="400" showImage="0" showText="<span style='cursor:help'>*</span>" showTextColor="red">
									<span style="text-align:center; font-size:10px">
										Previous Version #replace(replace(appsettings.getMarginColHeader11(),'%',''),'$','')#: 
										&nbsp; #application.util.string.cellFormat(value=qGetPreviousOperatingIncome.Operating_Income ,decimalplaces = request.dollar_format)#
										&nbsp;&nbsp; #application.util.string.cellFormat(value=qGetPreviousOperatingIncome.OperatingMargin_percent ,decimalplaces = request.numeric_format)# %
									</span>
								</CF_SmallHelp>
							</cfif>
						</cfif>
					</cfif>
				
			</td>
		</cfif>
		
		<!--- check if the user profile has rights to view margins --->
		<!--- add item variation to the item --->
		<cfset margin = application.util.string.cellFormat(value=TargetMargin ,decimalplaces = request.numeric_format)/>
		<cfset variationmargin  = Get_Profile_Settings.Margin_Target_Variation />
		<cfset approvalmargin  = "*" />
 
		<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
			<cfif appSettings.getApprovalMarginType() eq 2>
				<!--- Approval = Annual Case Rate --->
				<!--- ******* Annual Case Rate column ******* --->
				<td align="right" nowrap>
					
					#application.util.string.cellFormat(value=Trade ,decimalplaces = request.dollar_format)# /<cfif groupTargetCaseRateUOM EQ 1>CS<cfelseif groupTargetCaseRateUOM EQ 2>LB</cfif> 
				</td>
				<td>&nbsp;</td>
				<!--- ******* Target Case Rate column ******* --->
				<td align="right" nowrap>
					<cfif groupTargetCaseRateUOM EQ 2>
						<cfset data = groupTargetLBRate />
					<cfelse>
						<cfset data = groupTargetCaseRate />
					</cfif>					
									
					#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)# /<cfif groupTargetCaseRateUOM EQ 1>CS<cfelseif groupTargetCaseRateUOM EQ 2>LB</cfif>
				</td>				
			<cfelse>
				<!--- ******* Operating Margin Percent column ******* --->
				<td align="right" nowrap>
					
					#application.util.string.cellFormat(value=OperatingMargin_percent ,decimalplaces = request.numeric_format)# % <cfif OperatingMargin_percent LT 0><span style="color: red;">*IDC</span></cfif>
				</td>
				<td bgcolor="#itemtrbgcolor#">
					<cfif CannotApproveItemMargin EQ 1>
						<img src="/images/exclamation.gif" height="10" width="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle" />
					<cfelse>
						&nbsp; 
					</cfif>
				</td>
				<!--- ******* Margin % column ******* --->
				<td align="right" nowrap>
					<cfif marginTagetEnabled and appSettings.getuploadmargintargets_on()>
						<A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','T','P')"> 
						
							<cfif approvalmargin eq "*">
								#margin#% 
							<cfelse>
								#application.util.string.cellFormat(value=approvalmargin ,decimalplaces = request.numeric_format)# %
							</cfif>						
						
						</A> 
					</cfif>
				</td>
			</cfif>
			<cfif CannotApproveItemMargin EQ 1>
				<cfset form.AgreeList = ListAppend(form.AgreeList, BSA_Foodservice_Items_Master_Id) />
			<cfelse>
				<cfset form.ApproveList = ListAppend(form.ApproveList, BSA_Foodservice_Items_Master_Id) />
			</cfif>
		</cfif>
		<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
		<cfif appSettings.getApprovalMarginType() eq 1>
			<td align="right" nowrap>#application.util.string.cellFormat(value=Trade ,decimalplaces = request.dollar_format)# </td>
		</cfif>
		<!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
		<cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>
			<td align="right" nowrap>#application.util.string.cellFormat(value=Trade_Percent ,decimalplaces = request.numeric_format)# %</td>
		</cfif>
		<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
		<cfif Get_Profile_Settings.Base_View EQ 1>
			<td align="right" nowrap>
				<cfset tradespend = Item_Allowance * Round(Product_Program_Volume) />
				
				#application.util.string.cellFormat(value=tradespend ,decimalplaces = request.dollar_format)#
			</td>
		</cfif>
		<!--- check if the program is RFA only then display the check boxes --->
		<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
			<!--- get all the previous approved items  --->
			<cfquery name="getitemapprovedvalues" datasource="#application.datasource#">
				select isnull(approve,0) as item_approve,Name_Last,Name_First from Program_Type_Code_Approval_Info LEFT JOIN _Users ON _Users.user_id = Program_Type_Code_Approval_Info.User_Id and _Users.deleted = 0 where product_id = '#BSA_Foodservice_Items_Master_Id#' and program_id = #contract_main_id# and Program_Type_Code_Approval_Info.deleted = 0 and isnull(approve,0) = 1 
			</cfquery>
			<cfquery name="getitemagreedcount" datasource="#application.datasource#">
				select count(agree) as agreecount from Program_Type_Code_Approval_Info where product_id = '#BSA_Foodservice_Items_Master_Id#' and program_id = #contract_main_id# and Program_Type_Code_Approval_Info.deleted = 0 and isnull(agree,0) = 1 
			</cfquery>
			<!--- if the approve settings like growth and upfront funds are not allowed to be approved and if the item margin is not within limits --->
			<!--- display the label either approve or label after checking all the above conditions --->
			<cfif (CannotApproveSettings EQ 0 and CannotApproveItemMargin EQ 0 and CannotApproveProgramMargin EQ 0) OR (getitemapprovedvalues.recordcount GT 0 and getitemapprovedvalues.item_approve EQ 1)>
				<cfset feildname = "ProductApprove_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" />
				<cfset itemlabel = "Approve" />
				<cfif getitemagreedcount.agreecount GT 0>
					<cfset imagesrc = "Gaya_i18.gif" />
					<cfset title = "Click here to view the list of users who agreed" />
				<cfelse>
					<cfset imagesrc = "Gaya_i12.gif" />
					<cfset title = "" />
				</cfif>
				<cfif getitemapprovedvalues.item_approve EQ 1>
					<cfset itemlabel = "Approved" />
					<cfset checkitemvalue = "checked disabled" />
					<cfset imagesrc = "Gaya_i11.gif" />
					<cfset title = "" />
					<cfset approveditemuser = #getitemapprovedvalues.Name_First# & ' ' & #getitemapprovedvalues.Name_Last# />
				</cfif>
			<cfelseif (getitemapprovedvalues.item_approve EQ 0 OR getitemapprovedvalues.recordcount eq 0) and (CannotApproveSettings EQ 1 OR CannotApproveItemMargin EQ 1 OR CannotApproveProgramMargin EQ 1)>
				<cfset cannotapprove = 1 />
				<cfset feildname = "ProductAgree_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" />
				<cfquery name="getitemvalues" datasource="#application.datasource#">
					select isnull(agree,0) as item_agree from Program_Type_Code_Approval_Info where product_id = '#BSA_Foodservice_Items_Master_Id#' and user_id = '#request.AccessStructure.User_ID#' and program_id = #contract_main_id# and deleted = 0 
				</cfquery>
				<cfset itemlabel = "Agree" />
				<cfset imagesrc = "Gaya_i12.gif" />
				<cfif getitemvalues.item_agree EQ 1 and getitemvalues.recordcount GT 0>
					<cfset itemlabel = "Agreed" />
					<cfset checkitemvalue = "checked disabled" />
					<cfset title = "Click here to view the list of users who agreed" />
					<cfset imagesrc = "Gaya_i18.gif" />
				</cfif>
				<cfset button_label = "Agree" />
				<cfset showagreepopup = 1 />
			</cfif>
			<td bgcolor="#itemtrbgcolor#" valign="top">
				<!--- Removed with label 26954 
				<span id="checkAllProducts">
					<input type="checkbox" original_name="#feildname#" idToken="#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" name="#feildname#" value="1" #checkitemvalue# #disablecheckbox# <cfif disablecheckbox EQ "">checked</cfif>>
				</span>
				--->&nbsp;
			</td>
			<!--- mass approve --->
			<cfif not itemCheckBoxDisabled>
				<cfset stMassApproval["#feildname#"] = 1 />
			</cfif>
			<td bgcolor="#itemtrbgcolor#" class="Title6" valign="top">
				<!--- Removed with label 26954
				<span class="title5" id="approve_agree_label_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" original_approve_agree_label="#itemlabel#">#itemlabel#</span>
				--->&nbsp;
			</td>
			<td bgcolor="#itemtrbgcolor#">
				<IMG SRC="/images/Layered_Approval/#imagesrc#" 
				<cfif imagesrc EQ 'Gaya_i11.gif'>
					onmouseover="initTheTooltip('Approved by #approveditemuser#')" onmouseout="popOut()" 
				<cfelseif imagesrc EQ 'Gaya_i18.gif'>
					onmouseover="initTheTooltip('#title#')" onmouseout="popOut()" onclick="showCalculation('#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#','AG','P')" 
				</cfif>
				STYLE="cursor:pointer;">
			</td>
			<td>&nbsp;</td>
		<cfelse>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</cfif>
		</tr> 

		<cfset count = count + 1 />
		<cfset checkitemvalue = "" />
		<cfset itemlabel ="" />
		<cfset CannotApproveItemMargin = 0 />
	</cfoutput>
	<!--- End: Outputs the individual items  --->
	
	<!--- Type Code Groups --->
	<tr id="excludeditems" bgcolor="#grouptrbgcolor#">
		<cfloop query="getGroupvalues">
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" width="150" class="forceLeft">#Type_Code_Desc#</td>
				<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
				<cfif variables.bDisplayContractPrice>
					<!--- 16314 [begin] --->
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#">&nbsp;</td>
					<!--- 16314 [end] --->
				</cfif>
				<!--- 17289 > 16314 follow up 10/14/08 [end] --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					#application.util.string.cellFormat(value=Round(Total_Product_Program_Volume) ,decimalplaces = request.numeric_format)#
				</td>
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>#application.util.string.cellFormat(value=Total_Base_Sales ,decimalplaces = request.dollar_format)#</td>
				<cfif margin_display_style eq "custom_t">
					<!--- ALlow/Surch ---->
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>#application.util.string.cellFormat(value=Total_Allowance_Surcharges ,decimalplaces = request.dollar_format)#</td>
					<!--- Customer Freight ---->
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>#application.util.string.cellFormat(value=Total_Customer_Freight ,decimalplaces = request.dollar_format)#</td>
				</cfif>
				<cfif direct_pricing EQ 0>
					<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
					<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
						<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>#application.util.string.cellFormat(value=Total_Cash_discount ,decimalplaces = request.dollar_format)#</td>
					</cfif>
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
						<cfif appSettings.getApprovalMarginType() eq 2>
							<cfset Total_Item_Allowance_Display_Value = Total_Item_Allowance_Annualized />
						<cfelse>
							<cfset Total_Item_Allowance_Display_Value = Total_Item_Allowance />
						</cfif>
						
						#application.util.string.cellFormat(value=Total_Item_Allowance_Display_Value ,decimalplaces = request.dollar_format)#
					</td>

					<!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
					<!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Total_Item_Allowance_Display_Value". 
					I could have used IsDefined("Total_Item_Allowance_Display_Value") to show or hide this column, but it was simpler to just rely on the logic for "Total_Item_Allowance_Display_Value",
					as the below calculated value relies on ""Total_Item_Allowance_Display_Value".
					--->
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
						<cfif Total_Item_Allowance_Display_Value EQ 0 OR Total_Base_Sales EQ 0>
							N/A
						<cfelseif Total_Item_Allowance_Display_Value LT 0>
							0%
						<cfelse>
						<cfset Total_Allowance_Percent = (Total_Item_Allowance_Display_Value/Total_Base_Sales) * 100>
							#application.util.string.cellFormat(value=Total_Allowance_Percent ,decimalplaces = request.numeric_format)# %
						</cfif>
					</td>
				</cfif>
				<cfif ShowTPA EQ 1>
					<cfif margin_display_style eq "custom_t">
						<!--- TPA Operator --->
						<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
							
							#application.util.string.cellFormat(value=Total_TPA_Oper ,decimalplaces = request.dollar_format)#
						</td>
					</cfif>
					<!--- TPA Distributor (Distributor Trade) --->
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
						
						#application.util.string.cellFormat(value=Total_TPA ,decimalplaces = request.dollar_format)#
					</td>
				</cfif>
				<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
						
						#application.util.string.cellFormat(value=Total_Pullbackamount ,decimalplaces = request.dollar_format)#
					</td>
				</cfif>
				<cfif margin_display_style eq "custom_t">
					<!--- Other Spend --->
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
						
						#application.util.string.cellFormat(value=Total_Other_Spend ,decimalplaces = request.dollar_format)#
					</td>
				</cfif>
				<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 0>
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
						
						#application.util.string.cellFormat(value=Total_Net_Sales ,decimalplaces = request.dollar_format)#
					</td>
				</cfif>
			</cfif>
			<cfif Get_Profile_Settings.View_Cost EQ 1> 
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>#application.util.string.cellFormat(value=Total_Cost ,decimalplaces = request.dollar_format)#</td> 
			</cfif>
			<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1> 
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>#application.util.string.cellFormat(value=Total_Brokerage ,decimalplaces = request.dollar_format)#</td> 
			</cfif>
			<cfif margin_display_style eq "custom_t">
				<!--- Shuttle Freight --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					
					#application.util.string.cellFormat(value=Total_shuttle_freight ,decimalplaces = request.dollar_format)#
				</td>
				<!--- Warehouse --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					
					#application.util.string.cellFormat(value=Total_Custom_Warehouse ,decimalplaces = request.dollar_format)#
				</td>
				<!--- Gross Margin --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					
					#application.util.string.cellFormat(value=Total_Gross_Margin ,decimalplaces = request.dollar_format)#
				</td>		
				<!--- Brokerage --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					
					#application.util.string.cellFormat(value=Total_Custom_Brokerage ,decimalplaces = request.dollar_format)#
				</td>
				<!--- Contribution Margin --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					
					#application.util.string.cellFormat(value=Total_Contribution_Margin_Alt ,decimalplaces = request.dollar_format)#
				</td>
				<!--- Variable Contribution Margin --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					
					#application.util.string.cellFormat(value=Total_Variable_Contribution_Margin ,decimalplaces = request.dollar_format)#
				</td>
				<!--- MAP and MDF --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					
					#application.util.string.cellFormat(value=Total_Map_Mdf ,decimalplaces = request.dollar_format)#
				</td>
				<!--- SG & A --->
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
					
					#application.util.string.cellFormat(value=Total_SGA ,decimalplaces = request.dollar_format)#
				</td>
			</cfif>

			<cfif Get_Profile_Settings.View_Operating_Income EQ 1> 
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap> 
				
				#application.util.string.cellFormat(value=Total_Operating_Income ,decimalplaces = request.dollar_format)#
				</td> 
			</cfif> 
			<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
				<cfif appSettings.getApprovalMarginType() eq 2>
					<!--- Approval = Annual Case Rate --->
					<!--- ******* Annual Case Rate column ******* --->
					<td style="border-top: 1px solid 0000FF " bgcolor="#grouptrbgcolor#" align="right" nowrap>
						
						#application.util.string.cellFormat(value=Total_Trade ,decimalplaces = request.dollar_format)# /<cfif groupTargetCaseRateUOM EQ 1>CS<cfelseif groupTargetCaseRateUOM EQ 2>LB</cfif> 
					</td>
					<td style="border-top: 1px solid 0000FF " bgcolor="#grouptrbgcolor#" align="right" nowrap>&nbsp;</td>
					<!--- ******* Target Case Rate column ******* --->
					<td style="border-top: 1px solid 0000FF " bgcolor="#grouptrbgcolor#" align="right" nowrap>
						<cfif groupTargetCaseRateUOM EQ 2>
							<cfset data = groupTargetLBRate />
						<cfelse>
							<cfset data = groupTargetCaseRate />
						</cfif>
					
						#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#/<cfif groupTargetCaseRateUOM EQ 1>CS<cfelseif groupTargetCaseRateUOM EQ 2>LB</cfif> 
					</td>					
				<cfelse>
					<td style="border-top: 1px solid 0000FF " bgcolor="#grouptrbgcolor#" align="right" nowrap>

						#application.util.string.cellFormat(value=Round(Total_OperatingMargin_percent) ,decimalplaces = request.numeric_format)# %
					</td>
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#">
						<cfif CannotApproveGroupMargin EQ 1>
							<img src="/images/exclamation.gif" height="10" width="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle" />
						<cfelse>
						</cfif>
					</td>
					<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>
						<A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Type_code_desc_id, "-", "_", "ALL")#','T','G')"> 
							<cfif groupapprovalmargin EQ "*">
								#application.util.string.cellFormat(value=Target_Margin ,decimalplaces = request.numeric_format)# %
							<cfelse>
								#application.util.string.cellFormat(value=groupapprovalmargin ,decimalplaces = request.numeric_format)# %
							</cfif>
						</A> 
					</td>
				</cfif>
			</cfif>
			<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<td align="right" nowrap>#application.util.string.cellFormat(value=Total_Trade ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
			<cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>
				<td align="right" nowrap>
					#application.util.string.cellFormat(value=Total_Trade_Percent ,decimalplaces = request.numeric_format)# %
				</td>
			</cfif>
			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
			<!--- Dev Note: KAL; D21859: CAG Instill - trade as a % of sales questions - DISPLAY TRADE SPEND AT THE TYPE CODE ROWS --->
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<cfset Total_Trade_Spend = Total_Item_Allowance * Round(Total_Product_Program_Volume) />
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#" align="right" nowrap>

					#application.util.string.cellFormat(value=Total_Trade_Spend ,decimalplaces = request.dollar_format)#
				</td>
			</cfif>
			<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
				<!--- make sure u unckeck this later --->
				<cfquery name="getgroupapprovedvalues" datasource="#application.datasource#">
					select isnull(approve,0) as group_approve, Name_Last, Name_First
					from Program_Type_Code_Approval_Info
					Left JOIN  _users
					On _Users.user_id = Program_Type_Code_Approval_Info.User_Id
					and _Users.deleted = 0
					where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
					and program_id = #contract_main_id#
					and Program_Type_Code_Approval_Info.deleted = 0
					and isnull(approve,0) = 1
				</cfquery>
				<cfquery name="getgroupagreedcount" datasource="#application.datasource#">
					select count(agree) as agreecount
					from Program_Type_Code_Approval_Info
					where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
					and program_id = #contract_main_id#
					and Program_Type_Code_Approval_Info.deleted = 0
					and isnull(agree,0) = 1
				</cfquery>
				<cfif (CannotApproveSettings EQ 0 and Group_ID_Approval EQ 1 and CannotApproveProgramMargin EQ 0 and CannotApproveGroupMargin EQ 0) OR (getgroupapprovedvalues.recordcount gt 0 and getgroupapprovedvalues.group_approve GT 0)>
					<cfset feildname = "GroupApprove_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#" />
					<cfset grouplabel = "Approve" />
					<cfset showColumn = 0 />
					<cfif getgroupagreedcount.agreecount GT 0>
						<cfset imagesrc = "Gaya_i18.gif" />
						<cfset title = "Click here to view the list of users who agreed" />
					<cfelse>
						<cfset imagesrc = "Gaya_i12.gif" />
						<cfset title = "" />
					</cfif>
					<cfif getgroupapprovedvalues.group_approve EQ 1>
						<cfset grouplabel = "Approved" />
						<cfset checkgroupvalue = "checked disabled" />
						<cfset imagesrc = "Gaya_i11.gif" />
						<cfset title = "" />
						<cfset approvedgroupuser = #getgroupapprovedvalues.Name_First# & ' ' & #getgroupapprovedvalues.Name_Last# />
						<cfset showColumn = 1 />
					</cfif>
				<cfelseif (getgroupapprovedvalues.group_approve EQ 0 OR getgroupapprovedvalues.recordcount eq 0) and (CannotApproveSettings EQ 1 OR Group_ID_Approval EQ 0 OR CannotApproveGroupMargin EQ 1 or CannotApproveProgramMargin EQ 1)>
					<cfset cannotapprove = 1 />
					<cfset showColumn = 0 />
					<cfset feildname = "GroupAgree_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#" />
					<cfquery name="getgroupagreevalues" datasource="#application.datasource#">
						select isnull(agree,0) as group_agree
						from Program_Type_Code_Approval_Info
						where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
						and user_id = '#request.AccessStructure.User_ID#'
						and program_id = #contract_main_id#
						and deleted = 0
					</cfquery>
					<cfset grouplabel = "Agree" />
					<cfset imagesrc = "Gaya_i12.gif" />
					<cfif getgroupagreevalues.recordcount GT 0 and getgroupagreevalues.group_agree EQ 1>
						<cfset grouplabel = "Agreed" />
						<cfset checkgroupvalue = "checked disabled" />
						<cfset title = "Click here to view the list of users who agreed" />
						<cfset imagesrc = "Gaya_i18.gif" />
						<cfset showColumn = 1 />
					</cfif>
				</cfif>
				<cfif isDefined("showColumn") and showColumn EQ 0 and grouplabel is not "Approve" and grouplabel is not "Agree">
					<td>&nbsp;</td>
				</cfif>
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#">
					&nbsp; 
				</td>
				<cfif not itemCheckBoxDisabled>
					<cfset stMassApproval["#feildname#"] = 1 />
				</cfif>
				<td style="border-top:1px solid 0000FF" bgcolor="#grouptrbgcolor#">
					&nbsp; 
				</td>
				<td style="border-top: 1px solid 0000FF" bgcolor="#grouptrbgcolor#">
					<IMG SRC="/images/Layered_Approval/#imagesrc#" 
					<cfif imagesrc EQ 'Gaya_i11.gif'>
						onmouseover="initTheTooltip('Approved by #approvedgroupuser#')" onmouseout="popOut()" 
					<cfelseif imagesrc EQ 'Gaya_i18.gif'>
						onmouseover="initTheTooltip('#title#')" onmouseout="popOut()" onclick="showCalculation('#replace(Type_Code_Desc_Id, "-", "_", "ALL")#','AG','G')" 
					</cfif>
					STYLE="cursor:pointer;"> 
				</td>
				<td>&nbsp;</td>
			<cfelse>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</cfif>
			<cfset checkgroupvalue = "" />
			<cfset grouplabel = "" />
		</cfloop>
	</tr>

	<cfset CannotApproveGroupMargin = 0 />
	<cfset disablecheckbox = "" />
	<cfset grouptrbgcolor = "CCFFCC" />
	<cfset itemtrbgcolor = "f4f4f4" />
	<cfif massapproval eq 0>
		<cfset LastPercent = 0 />
		<!--- This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%) --->
		<cfset PercentDone = Int(Ceiling((OuterLoopcount/ExcludedProductMarginCount) * 100)/10) />
		<!--- Show the Image based on product count --->
		<cfif LastPercent neq PercentDone>
			<cfset Block = "Block" & PercentDone />
			<script>
				if(document.#Block#){				
					<cfloop from="1" to="#PercentDone#" index="i">
						<cfset Block = "Block" & i />
						document.#Block#.src = '/images/red_block.gif'; 
					</cfloop>
				} 
				//Show the progress in percent 
				if(document.getElementById('ShowPercentProgress')){ 
				<cfset PercentDone = PercentDone&'0' />
				document.getElementById('ShowPercentProgress').innerHTML = '#PercentDone#%'; } 
			</script> 
			<cfflush />
			<cfset LastPercent = PercentDone />
		</cfif>
		<cfset OuterLoopcount = OuterLoopcount + 1 />
	</cfif>
</cfoutput>
<!--- End Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->
<!--- Summary Row Begins --->
<!----- Annual/Program Summary : Header Start ----->
<cfoutput>
	<tr id="excludeditems">
		<td id="header" colspan="100%">
			<br />
			<strong>#qGetMarginUOT.UOT_Desc# Summary</strong>
		</td>		
	</tr>
	<!----- Annual/Program Summary : Header End ----->
	
	<cfset displayUOM = totalprogramvolumeUOM>
	<cfset qProgramSummaryMargins = getProgramExcludedProductMargins />
	<cfinclude template="layered_margin_program_rate_summary.cfm">
	
	<!--- display additional summary line for cs/lb if annual spending rate approval app switch is ON --->
	<cfif appSettings.getApprovalMarginType() eq 2>
		<cfif form.Margin_Type EQ 1><!--- case --->
			<!--- Display pound --->
			<cfset displayUOM = "LB">
			<cfset qProgramSummaryMargins = ApprovalProgramManager.getProgramMargins(program_id=contract_main_id, margin_type=3, margin_version="#original_margin_version#", excludeMarginItems=true)>
		<cfelse><!--- pound --->
			<!--- Display case --->
			<cfset displayUOM = "CS">
			<cfset qProgramSummaryMargins = ApprovalProgramManager.getProgramMargins(program_id=contract_main_id, margin_type=1, margin_version="#original_margin_version#", excludeMarginItems=true)>
		</cfif>
		<cfinclude template="layered_margin_program_rate_summary.cfm">
	</cfif>
	
	<!------ Annual/Program Summary : Absolute $ start ----->
	<tr id="excludeditems" valign="middle">
		<td align="left" id="header"><strong>
				Absolute $ 
			</strong></td>
		<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
		<cfif variables.bDisplayContractPrice>
			<!--- 16314 [begin] --->
			<td>&nbsp;</td>
			<!--- 16314 [end] --->
		</cfif>
		<!--- 17289 > 16314 follow up 10/14/08 [end] --->
		<cfif Get_Profile_Settings.Base_View EQ 1>
			<cfset data = makeNumeric(TotalProgramExcludedProductVolume) />
			<cfif data LT 0>
				<cfset data = data * (-1)>
				<cfset data = trim(numberformat(data,"___,___,___,___,___,___-__")) />
				<cfset data = "#negativeformat(data)#" />
			<cfelse>
				<cfset data = trim(numberformat(data,"___,___,___,___,___,___-__")) />
			</cfif>

			<td>
				<cfset colCount = colCount + 1 />
				&nbsp;
			</td>
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_BaseSales) * makeNumeric(TotalProgramExcludedProductVolume) />
			<cfset tempABS_BaseSales = data />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<cfif margin_display_style eq "custom_t">
				<!--- ALlow/Surch ---->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Allowance_Surcharges) * makeNumeric(TotalProgramExcludedProductVolume) />
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- Customer Freight ---->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Customer_Freight) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<cfif direct_pricing EQ 0>
				<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
				<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
				<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Cash_Discount) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
				<!--- Allowance --->
				<cfparam name="addExtra" default="0" />
				<cfif TotalProgramExcludedProductVolume neq "" and TotalProgramExcludedProductVolume neq 0>
					<cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/TotalProgramExcludedProductVolume) />
				</cfif>
				<cfif form.Margin_Type EQ 1 OR form.margin_type EQ 3>
					<cfset data = (makeNumeric(getProgramExcludedProductMargins.TOTAL_Allowance) + addExtra) * makeNumeric(TotalProgramExcludedProductVolume) />
				<cfelse>
					<cfset data = makeNumeric(getProgramExcludedProductMargins.TOTAL_Allowance) * makeNumeric(TotalProgramExcludedProductVolume) />
				</cfif>
				<cfset AllowAbs1 = makeNumeric(data) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- skip a column for "Allow %" --->
				<td align="right" nowrap>&nbsp;</td>
			</cfif>
			<cfif ShowTPA EQ 1>
				<cfif margin_display_style eq "custom_t">
					<!--- TPA Operator --->
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TPA_Oper) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
				<!--- TPA Distributor (Distributor Trade) --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TPA) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<cfif appSettings.getPullbacksOn() EQ 1	and GetSettings.Pullbacks_On EQ 1>
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_pullbackamount) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<cfif margin_display_style eq "custom_t">
				<!--- Other Spend --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Other_Spend) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
			<cfif appSettings.getApprovalMarginType() eq 0>
				<cfset data = makeNumeric(getProgramExcludedProductMargins.TOTAL_NetSales) * makeNumeric(TotalProgramExcludedProductVolume) />
				<cfset tempABS_NetSales = data />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
		</cfif>
		<cfif Get_Profile_Settings.View_Cost EQ 1>
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Cost) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
		</cfif>

		<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Brokerage) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
		</cfif>

		<cfif margin_display_style eq "custom_t">
			<!--- Shuttle Freight --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_shuttle_freight) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<!--- Warehouse --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Custom_Warehouse) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<!--- Gross Margin --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Gross_Margin) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<!--- Brokerage --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Custom_Brokerage) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<!--- Contribution Margin --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Contribution_Margin_Alt) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<!--- Variable Contribution Margin --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Variable_Contribution_Margin) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<!--- MAP and MDF --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Map_Mdf) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<!--- SG & A --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_SGA) * makeNumeric(TotalProgramExcludedProductVolume) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
		</cfif>
		<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_OprIncome) * makeNumeric(TotalProgramExcludedProductVolume) />
			<cfset absTotalOperIncome = data />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
		</cfif>
		<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
			<cfif appSettings.getApprovalMarginType() eq 2>
				<!--- Annual Case Rate --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TradeAmt_CS) * makeNumeric(getProgramExcludedProductMargins.totalprogramvolumecs) />
				<cfset AllowAbs1 = makeNumeric(data) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>		
			<cfelse>
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_OprMargin) />

			<cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)>
				<td>&nbsp;</td>
			</cfif>
			<td valign="bottom">&nbsp;</td>
			<td>&nbsp;</td>
		</cfif>
		<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
		<cfif appSettings.getApprovalMarginType() eq 1>
			<!--- Trade CS --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TradeAmt) * makeNumeric(TotalProgramExcludedProductVolume)  />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			<!--- Trade Percent --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TradePercent) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
		</cfif>
		<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
		<cfif Get_Profile_Settings.Base_View EQ 1>
			<!--- Trade Spend --->
			<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Trade_Spend) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
		</cfif>
		<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		<cfelse>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</cfif>
	</tr>
	<!------ Annual/Program Summary : Absolute $ end ----->
	<!------ Program Summary : Absolute $ start ----->
	<cfif qGetMarginUOT.Unit_Multiplier NEQ 0>
		<tr id="excludeditems">
			<td id="header"><br />
				<strong>
					Program Summary
				</strong></td>
			<cfif variables.bDisplayContractPrice>
				<td>&nbsp;</td>
			</cfif>
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<!--- volume --->
				<td>&nbsp;</td>
				<!--- base sales --->
				<td align="right" nowrap>&nbsp;</td>
				<cfif margin_display_style eq "custom_t">
					<!--- ALlow/Surch --->
					<td align="right" nowrap>&nbsp;</td>
					<!--- Customer Freight --->
					<td align="right" nowrap>&nbsp;</td>
				</cfif>
				<!--- cash disc --->
				<cfif direct_pricing EQ 0>
					<td align="right" nowrap>&nbsp;</td>
					<!--- allowance --->
					<td align="right" nowrap>&nbsp;</td>
				</cfif>
				<cfif ShowTPA EQ 1>
					<cfif margin_display_style eq "custom_t">
						<!--- TPA Operator --->
						<td align="right" nowrap>&nbsp;</td>
					</cfif>
					<!--- TPA Distributor (Distributor Trade) --->
					<td align="right" nowrap>&nbsp;</td>
				</cfif>
				<!--- pullback amount --->
				<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
					<td align="right" nowrap>&nbsp;</td>
				</cfif>
				<cfif margin_display_style eq "custom_t">
				<!--- Other Spend --->
					<td align="right" nowrap>&nbsp;</td>
				</cfif>
				<!--- net sales --->
				<td align="right" nowrap>&nbsp;</td>
			</cfif>
				<!--- cost --->
			<cfif Get_Profile_Settings.View_Cost EQ 1>
				<td align="right" nowrap>&nbsp;</td>
			</cfif>
			<!--- Brokerage --->
			<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
				<td align="right" nowrap>&nbsp;</td>
			</cfif>
			<cfif margin_display_style eq "custom_t">
				<!--- Shuttle Freight --->
				<td align="right" nowrap>&nbsp;</td>
				<!--- Warehouse --->
				<td align="right" nowrap>&nbsp;</td>
				<!--- Gross Margin --->
				<td align="right" nowrap>&nbsp;</td>
				<!--- Brokerage --->
				<td align="right" nowrap>&nbsp;</td>
				<!--- Contribution Margin --->
				<td align="right" nowrap>&nbsp;</td>
				<!--- Variable Contribution Margin --->
				<td align="right" nowrap>&nbsp;</td>'
				<!--- MAP and MDF --->
				<td align="right" nowrap>&nbsp;</td>
				<!--- SG & A --->
				<td align="right" nowrap>&nbsp;</td>
			</cfif>
			<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
				<td align="right" nowrap>&nbsp;</td>
			</cfif>
			<!--- operating margin --->
			<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</cfif>
			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<!--- trade spend --->
				<td align="right" nowrap>&nbsp;</td>
			</cfif>
			<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			<cfelse>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</cfif>
		</tr>
		<tr id="excludeditems" valign="middle">
			<td align="left" id="header"><strong>
					Absolute $ 
				</strong></td>
			<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
			<cfif variables.bDisplayContractPrice>
				<!--- 16314 [begin] --->
				<td>&nbsp;</td>
				<!--- 16314 [end] --->
			</cfif>
			<!--- 17289 > 16314 follow up 10/14/08 [end] --->
			<cfset ProgramVolume_For_Program_Span = (TotalProgramExcludedProductVolume * getProgramInfo.Program_Span) / qGetMarginUOT.Unit_Multiplier />
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<!--- volume --->
				<td>&nbsp;</td>
				<!--- base sales --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_BaseSales) * makeNumeric(ProgramVolume_For_Program_Span) />
				<cfset tempABS_BaseSales = data />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<cfif margin_display_style eq "custom_t">
					<!--- ALlow/Surch --->
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Allowance_Surcharges) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					<!--- Customer Freight --->
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Customer_Freight) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
				<!--- cash disc --->
				<cfif direct_pricing EQ 0>
					<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
					<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
						<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Cash_Discount) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					</cfif>
					<!--- allowance --->
					<cfparam name="addExtra" default="0" />
					<cfif ProgramVolume_For_Program_Span neq "" and ProgramVolume_For_Program_Span neq 0>
						<cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/ProgramVolume_For_Program_Span) />
					</cfif>
					<cfif form.Margin_Type EQ 1 OR form.margin_type EQ 3>
						<cfset data = (makeNumeric(getProgramExcludedProductMargins.TOTAL_Allowance) + addExtra) * makeNumeric(ProgramVolume_For_Program_Span) />
					<cfelse>
						<cfset data = makeNumeric(getProgramExcludedProductMargins.TOTAL_Allowance) * makeNumeric(ProgramVolume_For_Program_Span) />
					</cfif>
					<cfset AllowAbs1 = makeNumeric(data) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
				<!--- TPA --->
				<cfif ShowTPA EQ 1>
					<cfif margin_display_style eq "custom_t">
						<!--- TPA Operator --->
						<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TPA_Oper) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					</cfif>
					<!--- TPA Distributor (Distributor Trade) --->
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TPA) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
				<!--- pullback amount --->
				<cfif appSettings.getPullbacksOn() EQ 1
					and GetSettings.Pullbacks_On EQ 1>
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_pullbackamount) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
				<cfif margin_display_style eq "custom_t">
					<!--- Other Spend --->
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Other_Spend) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
				<!--- net sales --->
				<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 0>
					<cfset data = makeNumeric(getProgramExcludedProductMargins.TOTAL_NetSales) * makeNumeric(ProgramVolume_For_Program_Span) />
					<cfset tempABS_NetSales = data />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
			</cfif>
			<!--- cost --->
			<cfif Get_Profile_Settings.View_Cost EQ 1>
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Cost) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<!--- Brokerage --->
			<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Brokerage) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<cfif margin_display_style eq "custom_t">
				<!--- Shuttle Freight --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_shuttle_freight) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- Warehouse --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Custom_Warehouse) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- Gross Margin --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Gross_Margin) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- Brokerage --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Custom_Brokerage) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- Contribution Margin --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Contribution_Margin_Alt) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- Variable Contribution Margin --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Variable_Contribution_Margin) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- MAP and MDF --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_Map_Mdf) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- SG & A --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_SGA) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
				<!--- operating income --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_OprIncome) * makeNumeric(ProgramVolume_For_Program_Span) />
				<cfset absTotalOperIncome = data />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<!--- operating margin --->
			<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
				<cfif appSettings.getApprovalMarginType() eq 2>
					<!--- Annual Case Rate --->
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TradeAmt) * makeNumeric(ProgramVolume_For_Program_Span) />
					<cfset AllowAbs1 = makeNumeric(data) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<cfelse>
					<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_OprMargin) />
						
			<cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)&'%'>
					<td>&nbsp;</td>
				</cfif>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</cfif>
			<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<!--- Trade CS --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TradeAmt) * makeNumeric(ProgramVolume_For_Program_Span) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<!--- Trade Percent --->
				<cfset data = makeNumeric(getProgramExcludedProductMargins.Total_TradePercent) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
			</cfif>
			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<!--- trade spend --->
				<cfset data = makeNumeric(program_spend) />
			
			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>
			<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			<cfelse>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</cfif>
		</tr>
		<tr id="excludeditems-1" valign="top"><td colspan="all" style="border-bottom: 0px">&nbsp;</td></tr>
	</cfif>
</cfoutput>
<!------ Program Summary : Absolute $ end ----->
<!--- Summary Row Ends --->