<!--
  * ====================================================================================================
  *  @Author: Chris Nguyen
  *    @Date: 2018-07-12 07:37:39
  *
  * @Remarks: Layered program approval UDF for Custom_T
  *
  *
  *
  *
  * ====================================================================================================
 -->
<cfscript>
	th_count = 0;
	// this image placeholder is used to keep the gridviewscroll horizontal scrolling working properly
	img_1010 = '<img src="/images/exclamation.gif" height="10" width="10" style="opacity:0" alt="1010">';
</cfscript>

<!--- set up variable to avoid loading this file more than once (e.g. in mass approval) --->
<cfset request.layered_program_approval_t_udf = "loaded">

<cfset showItem = appSettings.get_Setting('Display_Item_No')>
<cfset Cont_Margin_Calculation = appSettings.get_Setting('Contribution_Margin_Calculation')>


<cffunction name="big_star" output="true" hint="Returns a big star element with overriding hovering message and a hidden input for previous value">
	<cfargument name="field_name" required="true">
	<cfargument name="product_id" required="false" default="#getAllProductMargins.BSA_Foodservice_Items_Master_ID#">
	<cfargument name="row_counter" required="false" default="#getAllProductMargins.currentRow#">

	<!--- locate previously saved value from a query  --->
	<cfquery name="local.qOverride" dbtype="query">
		SELECT *
		  FROM qMargin_Override
		 WHERE BSA_Foodservice_Items_Master_ID = '#arguments.product_id#'
		 AND   LOWER(Field_Name)               = '#lCase(arguments.field_name)#'
	</cfquery>

	<cfoutput>
	<cfsavecontent variable="local.result">
		<cfscript>
			local.no_dollar_sign = replace( variables.value, '$', '' );
			local.no_dollar_sign = sanitize_input(local.no_dollar_sign);

			// value attribute is already included, no need to add it
			if ( variables.value contains "value=" ) {
				local.value_string = local.no_dollar_sign;
			}
			else {
				// value attribute is not included, add it
				local.no_dollar_sign = "'" & local.no_dollar_sign & "'";
				local.value_string   = "value=" & local.no_dollar_sign & '"';
			}
		</cfscript>
		<!--- save old value in a hidden input --->
		<input type="hidden" name="old_#lcase(arguments.field_name)#_#arguments.row_counter#" #local.value_string#>
		<cfif local.qOverride.recordCount>
				<i class="audit"
					title="Previous value #numberFormat(local.qOverride.Old_Value, request.dollar_format)# was changed by #local.qOverride.User_Name# on #dateFormat(local.qOverride.Created_Date, 'medium')#">
					&bigstar;
				</i>
		</cfif>
	</cfsavecontent>
	</cfoutput>

	<cfreturn application.util.string.compress(local.result)>
</cffunction>


<cffunction name="tabIndex" output="false" hint="Returns tabindex attribute using top to bottom method and disabled attribute based on editing mode">
	<cfargument name="seq">
	<cfreturn "tabindex='#((getAllProductMargins.currentRow * 1000) + arguments.seq)#' " & (isEditing.recordCount ? "" : "disabled=disabled")>
</cffunction>

<!---------------------------------------------------------------------------------------------------------------------->
<!------- VERTICALPNL() ------------------------------------------------------------------------------------------------>
<!---------------------------------------------------------------------------------------------------------------------->
<cffunction name="verticalPNL">
	<cfoutput>
	<input type="hidden" name="product_count" value="#getAllProductMargins.recordCount#">
	<input type="hidden" name="next_page_url">
	<input type="hidden" name="action">
	<input type="hidden" name="page_view" value="#(url.detail7 eq "show" ? 'detail' : 'compact')#">   <!--- compact (w/o elements under discount, trade, cost) | detail  (with elements under discount, trade, cost) --->
	</cfoutput>

	<cfoutput query="getAllProductMargins">
		<!--- keep track of product IDs: first product is stored in input element named as 'prod_id_1' and has a value of BSA_Foodservice_Items_Master_ID --->
		<input type="hidden" name="prod_id_#getAllProductMargins.currentRow#"        value="#getAllProductMargins.BSA_Foodservice_Items_Master_ID#">
	</cfoutput>
	<cfsavecontent variable="variables.mainContent">
		<cfoutput>
		<div id="actions">
			<cfset url.detail7 = "show">    <!--- displays all rows for Tyson --->
			<cfset variables.moreless = (url.detail7 eq "show" ? "less -" : "more +")>
			<cfif url.verticalPNL eq "2">
				<a href="##" id="calc38">#application.util.string.actionLinkFormat2("calculate", "important")#</a>
				<a href="##" id="save38">#application.util.string.actionLinkFormat2("save")#</a>
				<a href="##" id="reset38">#application.util.string.actionLinkFormat2("reset")#</a>
				<a href="##" id="export82">#application.util.string.actionLinkFormat2("export to csv")#</a>
			<cfelse>
				<cfset useLakebaseForQProductLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_level")>
				<cfif useLakebaseForQProductLevel>
					<cftry>
						<cfset qProductLevel = application.oLakebase.toQuery(
							application.oLakebase.selectRows("product_group_level", {
								"select" = "product_group_level_id,group_level_desc,group_internal_label",
								"deleted" = "eq.false",
								"active" = "eq.true",
								"is_pg" = "eq.0",
								"product_group_level_type" = "neq.2"
							})
						)>
						<cfcatch type="any">
							<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
							<cfset useLakebaseForQProductLevel = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForQProductLevel>
				<cfquery name="qProductLevel" datasource="#application.datasource#">
					SELECT l.Product_Group_Level_ID
							, l.Group_Level_Desc
							, l.Group_Internal_Label
					FROM   Product_Group_Level l
					WHERE l.Deleted                    = 0
					AND   l.Active                     = 1
					AND   l.Is_PG                      = 0
					AND   l.Product_Group_Level_Type != 2
				</cfquery>
				</cfif>
				<input name="product_group_level_list" type="hidden" value="#form.product_group_level_list#">
				<select name="product_group_level_id" style="margin:0 8px 0 5px;">
					<option value="0">#application.returned_customer_setting.item_label# Level</option>
					<cfloop query="qProductLevel">
						<option value="#qProductLevel.Product_Group_Level_ID#" <cfif form.product_group_level_id eq qProductLevel.Product_Group_Level_ID>selected</cfif>>#qProductLevel.Group_Level_Desc#</option>
					</cfloop>
				</select>
				<a href='javaScript:void(0);' id="apply_groups">#application.util.string.linkFormat('apply')#</a>
				<cfif isEditing.recordCount and form.product_group_level_list eq "">
					<a href='javaScript:void(0);' id="save_vertical_pnl">#application.util.string.linkFormat('save')#</a>
					<a href='javaScript:void(0);' id="update_to_system_values">#application.util.string.linkFormat('update to system values')#</a>
				</cfif>
				<a href="##" id="export82">#application.util.string.linkFormat("export to csv")#</a>
			</cfif>
			<a href="##" id="close82">#application.util.string.LinkFormat("close window")#</a>
		<!--- 114617 :: Ideal Price START --->
		<cfif getProgramInfo.Ideal_Price AND (getProgramInfo.Contract_Is_Locked AND getProgramInfo.Contract_Status_Type_IDX LT 3 AND getProgramInfo.Contract_Locked_By_User_ID EQ request.AccessStructure.User_ID)>
			<cfset HTTPURL = ReplaceNocase(HTTP_URL, 'verticalPNL=1', '1=1','ALL')>
			<cfif ! listfind(HTTPURL,'&idealPriceAnalysis=1')>
				<cfset urlString = HTTPURL &  "&idealPriceAnalysis=1"/>
			<cfelse>
				<cfset urlString = HTTPURL/>
			</cfif>
			<a href="#urlString#">#application.util.string.actionLinkFormat2('ideal price analysis')#</a>
		</cfif>
		<!--- 114617 :: Ideal Price END --->
			<cfif url.verticalPNL eq "2" and variables.qWhatIf.recordCount gt 0>
				<!--- <span class="upd14">Page was last updated on #application.util.dateTime.dateTimeFormat(variables.qWhatIf.Changed_date)# by #variables.qWhatIf.Name_First# #variables.qWhatIf.Name_Last#</span> --->
				<cfscript>
					arrayAppend(variables.noty.Message, "This what if p&l was last modified by <b>#variables.qWhatIf.Name_First#  #variables.qWhatIf.Name_Last#</b> on #dateFormat(variables.qWhatIf.Changed_date, 'medium')#");
					arrayAppend(variables.noty.timeout, 0);
				</cfscript>
			</cfif>
			<br>
			<span id="approval_consideration">#variables.approval_consideration.getProgramText( getProgramInfo.contract_main_id )#</span>
		</div>

		<div id="uom35">
			<cfset newSpan = 1>
			<cfif DisplayMarginUOMCS>
				<cfset newSpan = newSpan + 1>
			</cfif>
			<cfif DisplayMarginUOMLB>
				<cfset newSpan = newSpan + 1>
			</cfif>
			<cfif DisplayMarginUOMEQ>
				<cfset newSpan = newSpan + 1>
			</cfif>
		<table>
			<tr>
				<td align="left" colspan="#newSpan#">#unitOfTime4Volume#</td>
			</tr>
			<tr>
				<td style="width:68px;text-align: right;">UOM :</td>
				<td style="text-align: left">
					<input type="radio" value="case" <cfif form.margin_type eq 1>checked</cfif> onClick = "changemarginTypePNL(1);">Physical Case
				</td>
				<td style="text-align: left">
					<input type="radio" value="lbs" <cfif form.margin_type eq 3>checked</cfif> onClick = "changemarginTypePNL(3);">#Application.UOMPoundPlural#
				</td>
			</tr>
		</table>
		<input type="hidden" name="margin_type" value="#form.margin_type#">
		</div>

		<div style="clear:both;"></div>

		<cfif url.verticalPNL eq "1">
			<!--- retrieve override information for this program --->
			<cfset qMargin_Override = ApprovalProgramManager.getMarginOverride(getProgramInfo.contract_main_id, form.margin_type)>
			<!--- <cfdump var="#qMargin_Override#"> --->
		<cfelseif url.verticalPNL eq "2">
			<div id="not07" style="margin-bottom:8px;">
				<label>Notes:</label> <textarea name="whatif_notes" rows="2"><cfif variables.qWhatIf.recordCount>#variables.qWhatIf.Notes#</cfif></textarea>
			</div>
		</cfif>

		<cfquery name="local.qMisc" datasource="#application.datasource#">
		SELECT Rsp = _Users.Name_First + ' ' + _Users.Name_Last
				,po.Position_Label
				,fixed_discount_count  = (SELECT COUNT(*)
											FROM PROGRAM_FIXED_COMPONENT pfc
											WHERE cm.Contract_Main_Id = pfc.Program_Id AND pfc.Deleted = 0)
				,rebate_discount_count = (SELECT COUNT(*)
											FROM PROGRAM_REBATES_COMPONENT prc
											WHERE cm.Contract_Main_Id = prc.Program_Id AND prc.Deleted = 0)
				,growth_discount_count = (SELECT COUNT(*)
											FROM Program_Growth_Components pgc
											WHERE cm.Contract_Main_Id = pgc.Program_Id AND pgc.Deleted = 0)
				,ls_discount_count     = (SELECT COUNT(*)
											FROM PROGRAM_LUMP_SUMS pls
											WHERE cm.Contract_Main_Id = pls.Program_Id AND pls.Deleted = 0)
			FROM Contract_Main cm
				LEFT JOIN _Users ON _Users.User_ID = cm.Responsible_User_ID
				LEFT JOIN User_Positions po ON po.User_Positions_ID = '#getProgramInfo.Creating_User_Position_ID#'
			WHERE cm.Contract_Main_Id = #getProgramInfo.contract_main_id#
		</cfquery>

	  <!--- cost detail information - applicable only when individual products are visible --->
		<cfif url.showProducts eq "1">
			<cfquery name="qCostDetail" datasource="#application.datasource#">
				SELECT
						CASE ISNULL(CAST(Contract_Product_Margin.Net_weight as FLOAT), 0)
						WHEN 0 THEN 1
						ELSE ISNULL(CAST(Contract_Product_Margin.Net_weight as FLOAT), 0)
						END                                              AS Net_weight
						,IsNull(fpr_cs, 0)                                AS Fixed_Price_CS
						,IsNull(rer_cs, 0)                                AS Rebate_Price_CS
						,IsNull(grr_cs, 0)                                AS Growth_Price_CS
						,IsNull(kpr_cs, 0)                                AS Formula_Price_CS
						,IsNull(oer_cs, 0)                                AS Offinvoice_Price_CS
						,IsNull(LumpSumAmount_cs, 0)                      AS LumpsumAmount_CS
						,IsNull(LumpSumAmount_lb, 0)                      AS LumpsumAmount_LB
						,Description
						,Item
						,Upc
						,IsNull(Base_Sales_lb, 0)                         AS Base_Sales_LB
						,IsNull(Base_Sales_cs, 0)                         AS Base_Sales_CS
						,IsNull(Program_Fixed_Price_cs, 0)                AS Program_Fixed_Price_CS
						,IsNull(Used_Fixed_Price, 0)                      AS Used_Fixed_Price
						,IsNull(Net_Price_cs, 0)                          AS Net_Price_CS
						,IsNull(Used_Net_Price, 0)                        AS Used_Net_Price
						,( IsNull(Item_Allowance_cs, 0)
						+ IsNull(LumpSumAmount_cs, 0) )                AS Item_Allowance_CS
						,( IsNull(Item_Allowance_lb, 0)
						+ IsNull(LumpSumAmount_lb, 0) )                AS Item_Allowance_LB
						,( IsNull(AnnualiZed_Allowance_cs, 0)
						+ IsNull(AnnualiZed_LumpSum_Allowance_cs, 0) ) AS Item_Annualized_Allowance_CS
						,( IsNull(AnnualiZed_Allowance_lb, 0)
						+ IsNull(AnnualiZed_LumpSum_Allowance_lb, 0) ) AS Item_Annualized_Allowance_LB
						,IsNull(tPa_cs, 0)                                AS TPA_CS
						,IsNull(PullBackAmount_cs, 0)                     AS PullbackAmount_CS
						,IsNull(Cash_Discount_cs, 0)                      AS Cash_Discount_CS
						,IsNull(Net_Sales_cs, 0)                          AS Net_Sales_CS
						,IsNull(Cost_cs, 0)                               AS Cost_CS
						,IsNull(dIff_Fixed_Price_cs, 0)                   AS Diff_Fixed_Price_CS
						,IsNull(dIff_Formula_Price_cs, 0)                 AS Diff_Formula_Price_CS
						,IsNull(var_Man_Cost, 0)                          AS Variable_Mfg_Cost
						,IsNull(fx_Man_Cost, 0)                           AS Fixed_Mfg_Cost
						,IsNull(del_frt_Cost, 0)                          AS Del_Frt_Cost
						,IsNull(del_del_Cost, 0)                          AS Del_Del_Cost
						,IsNull(del_var_Warhs, 0)                         AS Del_Var_Warhs
						,IsNull(del_cUst_Pickup, 0)                       AS Del_Cust_Pickup
						,IsNull(Fob_frt_Cost, 0)                          AS FOB_Frt_Cost
						,IsNull(Fob_Warhs, 0)                             AS FOB_Warhs
						,IsNull(cs_Curr_Cost, 0)                          AS Current_Cost
						,IsNull(Cost_From_Component_cs, 0)                AS Cost_From_Component_CS
						,Item_DeliveryType
						,IsNull(TargetMargin, 0)                          AS TargetMargin,

						<!--- 66894 Margin Target ENH Forge START --->
						<cfif OperatorProgram>
						ISNULL(Group_ID_Margin_Operator,0)
						<cfelse>
						IsNull(Group_Id_Margin, 0)
						</cfif> AS Margin_Target_Variation
						<!--- 66894 Margin Target ENH Forge END --->

						,GROUP_APPROVAL_RIGHTS.Group_Id_Margin
						,Product_ID
						,ISNULL(Allowance_Surcharges_CS, 0) AS Allowance_Surcharges_CS
						,ISNULL(Allowance_Surcharges_LB, 0) AS Allowance_Surcharges_LB
						,ISNULL(Customer_Freight_CS, 0) AS Customer_Freight_CS
						,ISNULL(Customer_Freight_LB, 0) AS Customer_Freight_LB
				FROM dbo.CONTRACT_PRODUCT_MARGIN
						INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER
								ON BSA_FOODSERVICE_ITEMS_MASTER.bsa_FoodService_Items_Master_Id = CONTRACT_PRODUCT_MARGIN.Product_Id
								AND BSA_FOODSERVICE_ITEMS_MASTER.Deleted = 0
						INNER JOIN TYPE_CODE_DESC
								ON TYPE_CODE_DESC.Type_Code_desc_Id = BSA_FOODSERVICE_ITEMS_MASTER.Type_Code_desc_Id
								AND TYPE_CODE_DESC.Deleted = 0
						LEFT JOIN GROUP_APPROVAL_RIGHTS
							ON GROUP_APPROVAL_RIGHTS.Group_Id = TYPE_CODE_DESC.Type_Code_desc_Id
								AND GROUP_APPROVAL_RIGHTS.User_Profile_Id = #request.Accessstructure.Profiles_ID#
								AND GROUP_APPROVAL_RIGHTS.Deleted = 0
				WHERE Contract_Main_Id = #getProgramInfo.contract_main_id#
			</cfquery>
		</cfif>
		</cfoutput>

		<!--- <cfdump abort="true" var="#getAllGroupMargins#"> --->

		<table cellspacing="0" id="GridView1" style="width:100%;border-collapse:collapse;">
		<!----------------------->
		<!--- COLUMNS HEADING --->
		<!----------------------->
		<tr class="GridviewScrollHeader">
			<th class="une82" id="one82"><cfoutput>
				#getProgramInfo.Contract_Number# -
				#dateFormat(getProgramInfo.Contract_Start_Date,'mmm d, yyyy')# to #dateFormat(getProgramInfo.Contract_End_Date,'mmm d, yyyy')#<br>
				#getProgramInfo.Contract_Title#<br>
				#local.qMisc.Rsp# (#trim(local.qMisc.Position_Label)#)
			</cfoutput>
			</th>
			<!--- Summary --->
			<th class="sum82" style="text-align:center;">Summary<br>Absolute $</th>
			<th class="sum82" style="text-align:center;">Summary<br>Rate / <cfoutput>#(form.margin_type eq '1' ? "CS" : "LB")#</cfoutput></th>

			<!--- Products & Type Code --->
			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<th class="grp82" style="text-align:center;">
						#application.util.string.wrapText( getAllGroupMargins.Type_Code_Desc )#
					</th>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfset useLakebaseForlocal_getGroupValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallgroupmargins")>
<cfif useLakebaseForlocal_getGroupValues>
	<cftry>
		<cfset local.getGroupValues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallgroupmargins", {
				"type_code_desc_id" = "eq.#getallproductmargins.type_code_desc_id#",
				"select" = "group_id_approval"
			}), "group_id_approval"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_getGroupValues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_getGroupValues>
<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
</cfif>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? " noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
						<th class="prod82 #variables.noApprovalClass#">   <!--- do not change class name it would break the what-if calculation logic --->

							<cfset item_UPC =''>
							<cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>
								<cfset item_UPC = getAllProductMargins.upc>
							<cfelse>
								<cfset item_UPC = getAllProductMargins.Item>
							</cfif>
							<cfif appSettings.getViewPgmSortBy()>
									#application.util.string.wrapText(getAllProductMargins.Description & ' ' & item_UPC)#
							<cfelse>
									#application.util.string.wrapText(item_UPC & ' ' & getAllProductMargins.Description)#
							</cfif>
						</th>
						</cfoutput>
					</cfif>  <!--- url.showProducts eq "1" --->
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>  <!--- class="GridviewScrollHeader"> --->

	<!--- 114617 :: Ideal Price START --->
	<cfif getProgramInfo.Ideal_Price>
		<tr class="GridviewScrollItem">
			<td class="une82">Ideal Price</td>
			<td class="sum82" id="albs"></td>
			<td class="sum82"> </td>
			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">&nbsp;</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<td>#application.util.string.cellFormat(value=getAllProductMargins.Ideal_Price ,decimalplaces = request.dollar_format )#</td>
							</cfoutput>
						</cfif>  <!--- url.showProducts eq "1" --->
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>
		<tr class="GridviewScrollItem">
				<td class="une82">Difference</td>
				<td class="sum82" id="albs"></td>
				<td class="sum82"> </td>
				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">&nbsp;</td>
					</cfoutput>
				<cfelse>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
							<cfif url.showProducts eq "1">
								<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfset useLakebaseForlocal_detail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qcostdetail")>
<cfif useLakebaseForlocal_detail>
	<cftry>
		<cfset local.detail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qcostdetail", {
				"product_id" = "eq.#getAllProductMargins.Product_ID#",
				"select" = "net_weight,fixed_price_cs"
			}), "net_weight,fixed_price_cs"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_detail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_detail>
<cfquery name="local.detail" dbtype="query">
									SELECT Net_weight,Fixed_Price_CS FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
								</cfquery>
</cfif>

								<cfscript>
									multiplier     = "*";
									statMultiplier = "1";
									IdealPrice = getAllProductMargins.Ideal_Price;

									if (form.margin_type eq 3) {
										multiplier     = "/";
										statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
									}
									if(! statMultiplier){
										statMultiplier = "1";
									}

									variables.value = 0;
									variables.valuePer = 0;

									if(IdealPrice){
										variables.value = local.detail.Fixed_Price_CS;
										variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
										variables.value = application.util.string.cellFormat(value=variables.value, decimalplaces = request.nondollar_format) - IdealPrice;
										if(variables.value > 0) variables.value = 0;
										variables.valuePer = (100 * variables.value)/IdealPrice;
									}
								</cfscript>
									<td>
										#application.util.string.cellFormat(value=variables.value, decimalplaces = request.dollar_format )#<br>
										#application.util.string.cellFormat(value=variables.valuePer, decimalplaces = request.nondollar_format)#%
									</td>
								</cfoutput>
							</cfif>  <!--- url.showProducts eq "1" --->
					</cfoutput>  <!--- query="getAllProductMargins"> --->
				</cfif>
		</tr>
		<tr class="GridviewScrollItem">
				<td class="une82">Ideal Price Diff $</td>
				<td class="sum82" id="IPDiff"></td>
				<td class="sum82"></td>
				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">&nbsp;</td>
					</cfoutput>
				<cfelse>
					<cfset TotalIPDiff =0>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
							<cfif url.showProducts eq "1">
								<cfoutput>  <!--- invidual products cfoutput loop --->
									<cfquery name="local.detail" dbtype="query">
										SELECT Net_weight,Fixed_Price_CS FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
									</cfquery>

									<cfscript>
										multiplier     = "*";
										statMultiplier = "1";

										if (form.margin_type eq 3) {
											multiplier     = "/";
											statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
										}
										variables.value = local.detail.Fixed_Price_CS;
										variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
										variables.value = variables.value - getAllProductMargins.Ideal_Price;
										if(variables.value > 0) variables.value = 0;
										variables.value = (variables.value) * getAllProductMargins.Product_Program_Volume;
									</cfscript>
									<cfset TotalIPDiff = TotalIPDiff + variables.value>
									<td>#application.util.string.cellFormat(value=variables.value, category = "dollar2" )#</td>
								</cfoutput>
							</cfif>  <!--- url.showProducts eq "1" --->
					</cfoutput>  <!--- query="getAllProductMargins"> --->
				</cfif>
		</tr>
	</cfif>
<!--- 114617 :: Ideal Price END --->

		<cfif form.margin_type eq '1'>
		<!------------------------->
		<!--- 002 - VOL. CS ------->
		<!------------------------->
		<tr class="GridviewScrollItem">
				<td class="une82">Cases</td>
				<td class="sum82" id="acases"><cfoutput>#application.util.string.cellFormat(round(getProgramMargins.totalprogramvolume), 'int')#</cfoutput></td>
				<td class="sum82"> </td>
					<cfif form.product_group_level_list neq "">
						<cfoutput query="getAllGroupMargins">
							<td class="grp82">
							#application.util.string.cellFormat(round(getAllGroupMargins.Total_Product_Program_Volume), 'int')#
							</td>
						</cfoutput>
			<cfelse>
		<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
							<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
								select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
							</cfquery>
							<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
							<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
							<cfif url.showProducts eq "1">
								<cfoutput>  <!--- invidual products cfoutput loop --->
									<cfset variables.value = application.util.string.cellFormat(round(getAllProductMargins.Product_Program_Volume), 'int')>
								<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
										#variables.value#
										<cfelse>
                                            <cfset variables.value = getAllProductMargins.Product_Program_Volume>
                                            <!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
											SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
											<cfset variables.value = variables.whatIF.User_Volume>
										</cfif>
										<!--- control tabbing navigation from top to bottom & stay in the same product --->
										<cfset variables.tabIndex = getAllProductMargins.currentRow * 1000>
										<!--- assign unique name with prefix "cases_" and suffix of record number
											,assign common class with prefix "gcases_" and suffix of group number
												for all products inside a group
												IMPORTANT: GridViewScroll() adds "_Copy" suffix to the names! When reference is needed remember to use "_Copy" suffix.
											--->
									        <input type="text" name="cases_#getAllProductMargins.currentRow#" class="gcases_#variables.group_idx# right" #numberFormatValue(round(variables.value), 'int')# #variables.disabled2# tabindex="#variables.tabIndex#">
										</cfif>
									</td>
								</cfoutput>
							</cfif>
					</cfoutput>  <!--- query="getAllProductMargins"> --->
				</cfif>
			</tr>
		</cfif> <!--- form.margin_type eq '1'> --->

		<cfif form.margin_type eq '3'>
			<!------------------------->
			<!--- 002X POUNDS --------->
			<!------------------------->
			<tr class="GridviewScrollItem">
				<td class="une82">Pounds</td>
				<td class="sum82" id="albs"><cfoutput>#application.util.string.cellFormat(round(getProgramMargins.totalprogramvolumelb), 'int')#</cfoutput></td>
				<td class="sum82"> </td>
				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							<cfif form.margin_type eq '1'>
								<cfset variables.value = getAllGroupMargins.Total_Product_Program_Volume_LB>
							<cfelse>
								<cfset variables.value = getAllGroupMargins.Total_Product_Program_Volume>
							</cfif>
							#application.util.string.cellFormat(round(variables.value), 'int')#
						</td>
					</cfoutput>
				<cfelse>

					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfif form.margin_type eq '1'>
									<cfset variables.value = getAllProductMargins.Product_Program_Volume_LB>
								<cfelse>
									<cfset variables.value = getAllProductMargins.Product_Program_Volume>
								</cfif>
								<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
								        <cfset variables.value = application.util.string.cellFormat(round(variables.value), 'int')>
										#variables.value#
									<cfelse>
										<!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
										    SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
										<cfset variables.value = variables.whatIF.User_Volume>
										</cfif>
										<!--- control tabbing navigation from top to bottom & stay in the same product --->
										<cfset variables.tabIndex = getAllProductMargins.currentRow * 1000>
										<!--- assign unique name with prefix "lbs_" and suffix of record number
											,assign common class with prefix "glbs_" and suffix of group number
											for all products inside a group
											IMPORTANT: GridViewScroll() adds "_Copy" suffix to the names! When reference is needed remember to use "_Copy" suffix.
											--->
										<input type="text" name="lbs_#getAllProductMargins.currentRow#" class="glbs_#variables.group_idx# right" #numberFormatValue(round(variables.value), 'int')# #variables.disabled2#  tabindex="#variables.tabIndex#">
									</cfif>
								</td>
							</cfoutput>
						</cfif>
					</cfoutput>  <!--- query="getAllProductMargins"> --->
				</cfif>
			</tr>
		</cfif> <!--- form.margin_type eq '3'> --->

		<!------------------->
		<!--- NET WEIGHT ---->
		<!------------------->
		<tr class="GridviewScrollItem">
			<td class="une82">Net Weight</td>
			<td class="sum82"> </td>
			<td class="sum82"> </td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">&nbsp;</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfquery name="local.detail" dbtype="query">
									SELECT Net_weight FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
								</cfquery>
								<td class="#variables.noApprovalClass#">#application.util.string.cellFormat(value=local.detail.Net_weight ,decimalplaces = request.numeric_format )#</td>
							</cfoutput>
						</cfif>  <!--- url.showProducts eq "1" --->
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>

		<!-------------------------------------->
		<!--- 003 - BASE SALES | LIST PRICE ---->
		<!-------------------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>#appsettings.getMarginColHeader2()#</cfoutput></td>
			<td class="sum82" id="alist_price"><cfoutput>#application.util.string.cellFormat(value=round(getProgramMargins.Total_BaseSales * getProgramMargins.TotalProgramVolume) ,decimalplaces = request.dollar_format )# </cfoutput>
			</td>
			<td class="sum82" id="ulist_price"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_BaseSales ,decimalplaces = request.dollar_format )#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Base_Sales ,decimalplaces = request.dollar_format )#
					</td>
				</cfoutput>
			<cfelse>

				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = getAllProductMargins.Base_Sales>
							<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
							        <cfset variables.value = application.util.string.cellFormat(value=variables.value, decimalplaces = request.dollar_format )>
									#big_star("Base_Sales")#
									<a href="##" onclick="showBaseSalesDetails('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#')">[$]</a>
									<input type="text" name="base_sales_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(10)# value="#sanitize_input(variables.value)#">
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
										SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
										<cfset variables.value = variables.whatIF.User_List_Price>
									</cfif>
									<!--- control tabbing navigation from top to bottom & stay in the same product --->
									<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 10>
									<!--- assign unique name with prefix "list_price_" and suffix of record number for all products inside a group --->
									<input type="text" name="list_price_#getAllProductMargins.currentRow#" class="right" #numberFormatValue(variables.value)# #variables.disabled2# tabindex="#variables.tabIndex#">
								</cfif>
							</td>
						</cfoutput>
					</cfif>  <!--- url.showProducts eq "1" --->
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>


		<!--------------------------->
		<!--- 003a - ALLOW/SURCH ---->
		<!--------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Allow/Surch</cfoutput></td>
			<td class="sum82" id="aallow_surch"><cfoutput>#application.util.string.cellFormat(value=round(getProgramMargins.Total_Allowance_Surcharges * getProgramMargins.TotalProgramVolume) ,decimalplaces = request.dollar_format )#</cfoutput>
			</td>
			<td class="sum82" id="uallow_surch"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Allowance_Surcharges ,decimalplaces = request.dollar_format )#</cfoutput></td>
			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Allowance_Surcharges ,decimalplaces = request.dollar_format )#
					</td>
				</cfoutput>
			<cfelse>

				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfquery name="local.detail" dbtype="query">
									SELECT Allowance_Surcharges_CS,Allowance_Surcharges_LB FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
								</cfquery>

								<cfset variables.value = form.margin_type eq 1
                                                            ? local.detail.Allowance_Surcharges_CS
                                                            : local.detail.Allowance_Surcharges_LB>

								<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
								        <cfset variables.value = application.util.string.cellFormat( value=variables.value, decimalplaces=request.dollar_format )>
										#big_star("Allowance_Surcharges")#
										<input type="text" name="allowance_surcharges_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(20)# value="#sanitize_input(variables.value)#">
									<cfelse>
										<!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
											SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
											<cfset variables.value = ''>
										</cfif>
										<!--- control tabbing navigation from top to bottom & stay in the same product --->
										<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 10>
										<!--- assign unique name with prefix "allow_surch_" and suffix of record number for all products inside a group --->
										<input type="text" name="allow_surch_#getAllProductMargins.currentRow#" class="right" #numberFormatValue(variables.value)#  #variables.disabled2# tabindex="#variables.tabIndex#">
									</cfif>
								</td>
							</cfoutput>
						</cfif>  <!--- url.showProducts eq "1" --->
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>

		<!-------------------------------->
		<!--- 003b - CUSTOMER FREIGHT ---->
		<!-------------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Customer Freight</cfoutput></td>
			<td class="sum82" id="acust_freight"><cfoutput>#application.util.string.cellFormat(value = round(getProgramMargins.Total_Customer_Freight * getProgramMargins.TotalProgramVolume) ,decimalplaces = request.dollar_format)#</cfoutput>
			</td>
			<td class="sum82" id="ucust_freight"><cfoutput>#application.util.string.cellFormat(value =getProgramMargins.Total_Customer_Freight ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value =getAllGroupMargins.Total_Customer_Freight ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>

				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>

					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfquery name="local.detail" dbtype="query">
								SELECT Customer_Freight_CS,Customer_Freight_LB FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
							</cfquery>
							<cfset variables.value = form.margin_type eq 1
                                                        ? local.detail.Customer_Freight_CS
                                                        : local.detail.Customer_Freight_LB>

							<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
							        <cfset variables.value = application.util.string.cellFormat( value = variables.value, decimalplaces = request.dollar_format)>
                                    #big_star("Customer_Freight")#
									<input type="text" name="customer_freight_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(30)# value="#sanitize_input(variables.value)#">
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
										SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
										<cfset variables.value = ''>
									</cfif>
									<!--- control tabbing navigation from top to bottom & stay in the same product --->
									<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 10>
									<!--- assign unique name with prefix "cust_freight_" and suffix of record number for all products inside a group --->
									<input type="text" name="cust_freight_#getAllProductMargins.currentRow#" class="right" #numberFormatValue(variables.value)#  #variables.disabled2# tabindex="#variables.tabIndex#">

								</cfif>
							</td>
						</cfoutput>
					</cfif>  <!--- url.showProducts eq "1" --->
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>

		<!---------------------------->
		<!--- 004 - CASH DISCOUNT ---->
		<!---------------------------->
					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
			<tr class="GridviewScrollItem">
				<td class="une82"><cfoutput><cfif appsettings.getlocalcostvariables() neq 1>#appsettings.getMarginColHeader3()#<cfelse>#appsettings.getMarginColHeader4()#</cfif></cfoutput></td>
				<td class="sum82" id="acash_disc"><cfoutput>#application.util.string.cellFormat(value = round(getProgramMargins.Total_Cash_discount  * getProgramMargins.TotalProgramVolume) ,decimalplaces = request.dollar_format)# </cfoutput></td>
				<td class="sum82" id="ucash_disc"><cfoutput>#application.util.string.cellFormat(value = getProgramMargins.Total_Cash_discount ,decimalplaces = request.dollar_format)#</cfoutput></td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							#application.util.string.cellFormat(value = getAllGroupMargins.Total_Cash_discount ,decimalplaces = request.dollar_format)#
						</td>
					</cfoutput>
				<cfelse>

					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
							<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
								select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
							</cfquery>
							<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
							<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
							<cfif url.showProducts eq "1">
								<cfoutput>  <!--- invidual products cfoutput loop --->
									<cfset variables.value = getAllProductMargins.Cash_discount>
									<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
											#application.util.string.cellFormat(value=variables.value, decimalplaces=request.dollar_format)#
										<cfelse>
											<!--- see if there is a saved what if row for this product --->
											<cfquery dbtype="query" name="variables.whatIF">
												SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
											</cfquery>
											<cfif variables.whatIF.recordCount>
												<cfset variables.value = variables.whatIF.User_Cash_Disc>
											</cfif>
											<!--- control tabbing navigation from top to bottom & stay in the same product --->
											<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 15>
											<!--- assign unique name with prefix "cash_disc" and suffix of record number for all products inside a group --->
											<input type="text" name="cash_disc_#getAllProductMargins.currentRow#" class="right" #numberFormatValue(variables.value)#  #variables.disabled2# tabindex="#variables.tabIndex#">
										</cfif>
									</td>
								</cfoutput>
							</cfif>  <!--- url.showProducts eq "1" --->
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>
		</cfif>    <!--- <cfif appsettings.getDisplayCashDiscountMargin() eq 1 > --->

		<!---------------------------------->
		<!--- 005 - ALLOWANCE | DISCOUNT --->
		<!---------------------------------->
					<cfif direct_pricing eq 0>
			<tr class="GridviewScrollItem">
				<cfif form.Margin_Type eq 1 OR form.margin_type eq 3>
					<cfparam name="addExtra" default="0">
					<cfif getProgramMargins.TotalProgramVolume neq "" and getProgramMargins.TotalProgramVolume neq 0>
						<cfset addExtra = getProgramLumpsum.Lumpsum_Amount / getProgramMargins.TotalProgramVolume/>
					</cfif>
					<cfset local.TOTAL_Allowance = getProgramMargins.TOTAL_Allowance + addExtra>
				<cfelse>
					<cfset local.TOTAL_Allowance = getProgramMargins.TOTAL_Allowance/>
				</cfif>

				<td class="une82 master11"><cfoutput>#appsettings.getMarginColHeader5()#</cfoutput></td>
				<td class="sum82" id="adisc"><cfoutput>#application.util.string.cellFormat(value = local.TOTAL_Allowance * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
				<td class="sum82" id="udisc"><cfoutput>#application.util.string.cellFormat(value = local.TOTAL_Allowance ,decimalplaces = request.dollar_format)#</cfoutput></td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							#application.util.string.cellFormat(value = appSettings.getApprovalMarginType() eq 2 ? getAllGroupMargins.Total_Item_Allowance_Annualized : getAllGroupMargins.Total_Item_Allowance ,decimalplaces = request.dollar_format)#
						</td>
					</cfoutput>
				<cfelse>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfset variables.value = application.util.string.cellFormat(value = appSettings.getApprovalMarginType() eq 2 ? getAllProductMargins.Item_Allowance_Annualized : getAllProductMargins.Item_Allowance ,decimalplaces = request.dollar_format)>
								<td class="#variables.noApprovalClass#" id="disc_#getAllProductMargins.currentRow#">
									<!--- D56447 :: EZ Rates Indicator inside a Program START --->
									<cfset EZrateIndicator = 0>
									<cfif getsettings.EZButton_On EQ 1 AND ListFind(ProductsBeyoundMaxRateList, getAllProductMargins.BSA_Foodservice_Items_Master_ID)>
										<cfset ezrate = listgetat(ProductsMaxRateList, ListFind(ProductsBeyoundMaxRateList, getAllProductMargins.BSA_Foodservice_Items_Master_ID))>
										<cfset EZrateIndicator = 1>
									</cfif>
									<!--- D56447 :: EZ Rates Indicator inside a Program END --->

									<cfif url.verticalPNL eq '1'>
										<cfif EZrateIndicator><b title="Item Rate above EZ rate. EZ Rate = $#ezrate#" style="font-size:12px;color:red;font-weight:bold;cursor:pointer;" align="absmiddle">( ! )</b></cfif> <a href="##" onclick="showCalculation('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#','A','')">#variables.value#</a>
										<!--- #variables.value# --->
									<cfelse>
										<!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
											SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
											<cfset variables.value = application.util.string.cellFormat(value = variables.whatIF.User_Discount ,decimalplaces = request.dollar_format)>
										</cfif>
										<cfif EZrateIndicator><b title="Item Rate above EZ rate. EZ Rate = $#ezrate#" style="font-size:12px;color:red;font-weight:bold;cursor:pointer;" align="absmiddle">( ! )</b></cfif> #variables.value#
									</cfif>
								</td>
							</cfoutput>
						</cfif>  <!--- url.showProducts eq "1" --->
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>

						<cfif url.detail7 eq "show">
				<!------------------------->
				<!--- 001 - FIXED PRICE --->
				<!------------------------->
				<cfif variables.bDisplayContractPrice and local.qMisc.fixed_discount_count>
					<tr class="GridviewScrollItem detail11">
						<cfoutput>
						<td class="une82b">#variables.spacer2#
							<cfif len(trim(appsettings.getMarginColHeader15()))>
								#appsettings.getMarginColHeader15()#
							<cfelse>
								Fixed Price
							</cfif>
						</td>
						</cfoutput>
						<td class="sum82"> </td>
						<td class="sum82"> </td>

						<cfif form.product_group_level_list neq "">
							<cfoutput query="getAllGroupMargins">
								<td class="grp82">&nbsp;</td>
							</cfoutput>
						<cfelse>
							<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
								<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
									select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
								</cfquery>
								<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
								<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
								<cfif url.showProducts eq "1">
									<cfoutput>  <!--- invidual products cfoutput loop --->
										<cfquery name="local.detail" dbtype="query">
											SELECT Net_weight,Fixed_Price_CS FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
										</cfquery>

										<cfscript>
											multiplier     = "*";
											statMultiplier = "1";

											if (form.margin_type eq 3) {
												multiplier     = "/";
												statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
											}
											variables.value = local.detail.Fixed_Price_CS;
											variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
										</cfscript>

										<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
												#application.util.string.cellFormat(value = variables.value ,decimalplaces = request.dollar_format)#
											<cfelse>
												<!--- see if there is a saved what if row for this product --->
												<cfquery dbtype="query" name="variables.whatIF">
													SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
												</cfquery>
												<cfif variables.whatIF.recordCount and variables.whatIF.User_Fixed_Price neq "">
													<cfset variables.value = variables.whatIF.User_Fixed_Price>
												</cfif>
												<!--- control tabbing navigation from top to bottom & stay in the same product --->
												<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 40>
												<!--- assign unique name with prefix "fixed_price_" and suffix of record number
													,assign common class with prefix "gfixed_price_" and suffix of group number
													for all products inside a group
													--->
												<input type="text" name="fixed_price_#getAllProductMargins.currentRow#" class="gfixed_price_#variables.group_idx# right" #numberFormatValue(variables.value)# #variables.disabled2#  tabindex="#variables.tabIndex#">
											</cfif>
										</td>
									</cfoutput>  <!--- invidual products cfoutput loop --->
								</cfif>  <!--- url.showProducts eq "1" --->
							</cfoutput>  <!--- query="getAllProductMargins"> --->
						</cfif>
					</tr>
				</cfif>  <!--- variables.bDisplayContractPrice> --->


				<!--------------------->
				<!--- 001b - REBATE --->
				<!--------------------->
							<cfif local.qMisc.rebate_discount_count>
					<tr class="GridviewScrollItem detail11">
						<td class="une82b"><cfoutput>#variables.spacer2#</cfoutput> Rebate</td>
						<td class="sum82"> </td>
						<td class="sum82"> </td>

						<cfif form.product_group_level_list neq "">
							<cfoutput query="getAllGroupMargins">
								<td class="grp82">&nbsp;</td>
							</cfoutput>
						<cfelse>

							<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
									<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
										select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
									</cfquery>
									<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
									<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
									<cfif url.showProducts eq "1">
										<cfoutput>  <!--- invidual products cfoutput loop --->
											<cfquery name="local.detail" dbtype="query">
												SELECT Net_weight,Rebate_Price_CS FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
											</cfquery>

											<cfscript>
												multiplier     = "*";
												statMultiplier = "1";

												if (form.margin_type eq 3) {
													multiplier     = "/";
													statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
												}
												variables.value = local.detail.Rebate_Price_CS;
												variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
											</cfscript>

											<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
													#application.util.string.cellFormat(value =variables.value ,decimalplaces = request.dollar_format)#
												<cfelse>
													<!--- see if there is a saved what if row for this product --->
													<cfquery dbtype="query" name="variables.whatIF">
													SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
													</cfquery>
													<cfif variables.whatIF.recordCount and variables.whatIF.User_Rebate neq "">
													<cfset variables.value = variables.whatIF.User_Rebate>
													</cfif>
													<!--- control tabbing navigation from top to bottom & stay in the same product --->
													<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 41>
													<!--- assign unique name with prefix "rebate_" and suffix of record number for all products inside a group --->
													<input type="text" name="rebate_#getAllProductMargins.currentRow#" class="right" #numberFormatValue(variables.value)# #variables.disabled2#  tabindex="#variables.tabIndex#">
												</cfif>
											</td>
										</cfoutput>
									</cfif>
							</cfoutput>
						</cfif>
					</tr>
				</cfif>    <!--- local.qMisc.rebate_discount_count> --->


				<!--------------------->
				<!--- 001c - GROWTH --->
				<!--------------------->
							<cfif local.qMisc.growth_discount_count>
					<tr class="GridviewScrollItem detail11">
						<td class="une82b"><cfoutput>#variables.spacer2#</cfoutput> Growth</td>
						<td class="sum82"> </td>
						<td class="sum82"> </td>

						<cfif form.product_group_level_list neq "">
							<cfoutput query="getAllGroupMargins">
								<td class="grp82">&nbsp;</td>
							</cfoutput>
						<cfelse>

							<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
								<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
									select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
								</cfquery>
								<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
								<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
								<cfif url.showProducts eq "1">
									<cfoutput>  <!--- invidual products cfoutput loop --->
										<cfquery name="local.detail" dbtype="query">
											SELECT Net_weight,Growth_Price_CS FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
										</cfquery>

										<cfscript>
											multiplier     = "*";
											statMultiplier = "1";

											if (form.margin_type eq 3) {
												multiplier     = "/";
												statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
											}
											variables.value = local.detail.Growth_Price_CS;
											variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
										</cfscript>

										<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
												#application.util.string.cellFormat(value =variables.value ,decimalplaces = request.dollar_format)#
											<cfelse>
												<!--- see if there is a saved what if row for this product --->
												<cfquery dbtype="query" name="variables.whatIF">
												SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
												</cfquery>
												<cfif variables.whatIF.recordCount and variables.whatIF.User_Growth neq "">
												<cfset variables.value = variables.whatIF.User_Growth>
												</cfif>
												<!--- control tabbing navigation from top to bottom & stay in the same product --->
												<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 42>
												<!--- assign unique name with prefix "growth_" and suffix of record number for all products inside a group --->
												<input type="text" name="growth_#getAllProductMargins.currentRow#" class="right" #numberFormatValue(variables.value)#  #variables.disabled2# tabindex="#variables.tabIndex#">
											</cfif>
										</td>
									</cfoutput>
								</cfif>
							</cfoutput>
						</cfif>
					</tr>
				</cfif>    <!--- local.qMisc.growth_discount_count --->


				<!----------------------->
				<!--- 001d - LUMP SUM --->
				<!----------------------->
							<cfif local.qMisc.ls_discount_count>
					<tr class="GridviewScrollItem detail11">
						<td class="une82b"><cfoutput>#variables.spacer2#</cfoutput> Lump Sum</td>
						<td class="sum82"> </td>
						<td class="sum82"> </td>

						<cfif form.product_group_level_list neq "">
							<cfoutput query="getAllGroupMargins">
								<td class="grp82">&nbsp;</td>
							</cfoutput>
						<cfelse>

							<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
								<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
									select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
								</cfquery>
								<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
								<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
								<cfif url.showProducts eq "1">
									<cfoutput>  <!--- invidual products cfoutput loop --->
										<cfquery name="local.detail" dbtype="query">
											SELECT Net_weight,LumpsumAmount_CS FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
										</cfquery>

										<cfscript>
											multiplier     = "*";
											statMultiplier = "1";

											if (form.margin_type eq 3) {
												multiplier     = "/";
												statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
											}
											variables.value = local.detail.LumpsumAmount_CS;
											variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
										</cfscript>

										<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
												#application.util.string.cellFormat(value =variables.value ,decimalplaces = request.dollar_format)#
											<cfelse>
												<!--- see if there is a saved what if row for this product --->
												<cfquery dbtype="query" name="variables.whatIF">
												SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
												</cfquery>
												<cfif variables.whatIF.recordCount and variables.whatIF.User_Lump_Sum neq "">
												    <cfset variables.value = variables.whatIF.User_Lump_Sum>
												</cfif>
												<!--- control tabbing navigation from top to bottom & stay in the same product --->
												<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 43>
												<!--- assign unique name with prefix "lump_sum_" and suffix of record number for all products inside a group --->
												<input type="text" name="lump_sum_#getAllProductMargins.currentRow#" class="right" #numberFormatValue(variables.value)#  #variables.disabled2# tabindex="#variables.tabIndex#">
											</cfif>
										</td>
									</cfoutput>
								</cfif>
							</cfoutput>
							</cfif>
					</tr>
				</cfif>    <!--- local.qMisc.ls_discount_count --->
			</cfif>   <!--- url.detail7 eq "show"> --->
			<!---------------------------------->
			<!--- 006 - ALLOW % | DISCOUNT % --->
			<!---------------------------------->
			<tr class="GridviewScrollItem">
				<td class="une82"><cfoutput>#appsettings.getMarginColHeader23()#</cfoutput></td>
				<td class="sum82" id="adisc_percent">
					<cfif local.TOTAL_Allowance eq 0 or getProgramMargins.Total_BaseSales eq 0>
						N/A
					<cfelseif local.TOTAL_Allowance lt 0>
						0%
					<cfelse>
						<cfoutput>#application.util.string.cellFormat(100 * (local.TOTAL_Allowance / getProgramMargins.Total_BaseSales), "percent2")#</cfoutput>
						</cfif>
				</td>
				<td class="sum82"> </td>
				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							<cfset local.Total_Item_Allowance_Display_Value = ( appSettings.getApprovalMarginType() eq 2 ? getAllGroupMargins.Total_Item_Allowance_Annualized : getAllGroupMargins.Total_Item_Allowance )>
							<cfif local.Total_Item_Allowance_Display_Value eq 0 OR getAllGroupMargins.Total_Base_Sales eq 0>
								N/A
							<cfelseif local.Total_Item_Allowance_Display_Value LT 0>
								0%
							<cfelse>
								#application.util.string.cellFormat(100 * (local.Total_Item_Allowance_Display_Value / getAllGroupMargins.Total_Base_Sales), "deci")#%
					</cfif>
						</td>
					</cfoutput>
				<cfelse>

					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfset local.Allowance_Display_Value = ( appSettings.getApprovalMarginType() eq 2 ? getAllProductMargins.Item_Allowance_Annualized : getAllProductMargins.Item_Allowance )/>
								<td class="per82 prod #variables.noApprovalClass#" id="disc_percent_#getAllProductMargins.currentRow#">
									<cfscript>
									if (local.Allowance_Display_Value eq 0 or getAllProductMargins.Base_Sales eq 0)
										variables.cellValue = "N/A";
									else if ( val(local.Allowance_Display_Value) lt 0 )
										variables.cellValue = "0%";
									else
										variables.cellValue = application.util.string.cellFormat(100 * (local.Allowance_Display_Value / getAllProductMargins.Base_Sales), "deci") & "%";
									</cfscript>
									<cfif url.verticalPNL eq '2'>
										<!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
										SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
										<cfset variables.cellValue = " ">   <!--- to be calculated later by calculate() --->
										</cfif>
									</cfif>
									#variables.cellValue#
								</td>
							</cfoutput>
						</cfif>  <!--- url.showProducts eq "1" --->
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>
		</cfif> <!--- direct_pricing eq 0> --->

		<!------------------------------------->
		<!--- 007 - TPA | TRADE --------------->
		<!------------------------------------->
					<cfif showtpa eq 1>
			<!--------------------------->
			<!--- 007a - TPA Operator --->
			<!--------------------------->
			<tr class="GridviewScrollItem">
				<td class="une82"><cfoutput>Other Operator Trade</cfoutput></td>
				<td class="sum82" id="atrade_oper"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TPA_Oper * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
				<td class="sum82" id="utrade_oper"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TPA_Oper ,decimalplaces = request.dollar_format)#</cfoutput></td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							#application.util.string.cellFormat(value=getAllGroupMargins.Total_TPA_Oper ,decimalplaces = request.dollar_format)#
						</td>
					</cfoutput>
				<cfelse>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.TPA_Oper ,decimalplaces = request.dollar_format)>
								<td class="#variables.noApprovalClass#" id="trade_oper_#getAllProductMargins.currentRow#">
									<cfif url.verticalPNL eq '1'>
										#big_star("TPA_Oper")#
										<a href="javascript:tpa_operator('#getAllProductMargins.Product_Id#')">[$]</a>
										<input type="text" name="tpa_oper_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(40)# value="#sanitize_input(variables.value)#">
									<cfelse>
										<!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
										SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
										<cfset variables.value = application.util.string.cellFormat(value =variables.whatIF.User_Trade ,decimalplaces = request.dollar_format)>
										</cfif>
										#variables.value#
									</cfif>
								</td>
							</cfoutput>
						</cfif>
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>


			<!----------------------------->
			<!--- 999 DISTRIBUTOR TRADE --->
			<!----------------------------->
			<tr class="GridviewScrollItem">
				<td class="une82"><cfoutput>Other Distributor Trade</cfoutput></td>
				<td class="sum82" id="atrade"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TPA * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
				<td class="sum82" id="utrade"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TPA ,decimalplaces = request.dollar_format)#</cfoutput></td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							#application.util.string.cellFormat(value=getAllGroupMargins.Total_TPA ,decimalplaces = request.dollar_format)#
						</td>
					</cfoutput>
				<cfelse>

					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = getAllProductMargins.TPA>
							<td class="#variables.noApprovalClass#">
								<cfif url.verticalPNL eq '1'>
							        <cfset variables.value = application.util.string.cellFormat(value=variables.value, decimalplaces=request.dollar_format)>
									#big_star("TPA")#
									<a href="javascript:tpa_distributor('#getAllProductMargins.Product_Id#')">[$]</a>
									<input type="text" name="tpa_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(50)# value="#sanitize_input(variables.value)#">
								<cfelse>
                                    <!--- see if there is a saved what if row for this product --->
                                    <cfquery dbtype="query" name="variables.whatIF">
                                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                                    </cfquery>
                                    <cfif variables.whatIF.recordCount>
                                        <cfset variables.value = variables.whatIF.User_Distributor_Trade>
                                    </cfif>
                                    <!--- control tabbing navigation from top to bottom & stay in the same product --->
                                    <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 53>
                                    <!--- assign unique name with prefix "distributor_trade_" and suffix of record number
                                            ,assign common class with prefix "gdistributor_trade_" and suffix of group number
                                            for all products inside a group
                                        --->
                                    <input type="text" name="distributor_trade_#getAllProductMargins.currentRow#" class="gdistributor_trade_#variables.group_idx# right" #numberFormatValue(variables.value)# #variables.disabled2# tabindex="#variables.tabIndex#">
								</cfif>
							</td>
						</cfoutput>
						</cfif>  <!--- url.showProducts eq "1" --->
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>
		</cfif> <!--- showtpa eq 1> --->

		<!------------------------------------->
		<!--- 008 - PULLBACK AMOUNT | AMT + --->
		<!------------------------------------->
					<cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
			<tr class="GridviewScrollItem">
				<td class="une82">Recapture</td>
				<td class="sum82" id="aamt_plus"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_pullbackamount ,decimalplaces = request.dollar_format)#</cfoutput></td>
				<td class="sum82"> </td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							#application.util.string.cellFormat(value=getAllGroupMargins.Total_Pullbackamount ,decimalplaces = request.dollar_format)#
						</td>
					</cfoutput>
				<cfelse>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfset variables.value = getAllProductMargins.PullBackAmount>
								<td class="#variables.noApprovalClass#">
									<cfif url.verticalPNL eq '1'>
								        <cfset variables.value = application.util.string.cellFormat(value=variables.value, decimalplaces=request.dollar_format)>
										#big_star("PullBackAmount")#
										<a href="javascript:showPullbackCalculation('#getAllProductMargins.Product_Id#')">[$]</a>
										<input type="text" name="pullbackamount_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(60)# value="#sanitize_input(variables.value)#">
									<cfelse>
										<!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
											SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
											<cfset variables.value = variables.whatIF.User_Pullback>
										</cfif>
										<!--- control tabbing navigation from top to bottom & stay in the same product --->
										<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 60>
										<!--- assign unique name with prefix "amt_plus_" and suffix of record number for all products inside a group --->
										<input type="text" name="amt_plus_#getAllProductMargins.currentRow#" class="right" #numberFormatValue(variables.value)#  #variables.disabled2# tabindex="#variables.tabIndex#">
									</cfif>
								</td>
							</cfoutput>
						</cfif>
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>
		</cfif> <!--- appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1> --->


		<!-------------------------->
		<!--- 008b - OTHER SPEND --->
		<!-------------------------->
		<tr class="GridviewScrollItem">
		<td class="une82"><cfoutput>Other Spend</cfoutput></td>
			<td class="sum82" id="aother_spend"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Other_Spend * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="uother_spend"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Other_Spend ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Other_Spend ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
					select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
					<cfoutput>  <!--- invidual products cfoutput loop --->
						<cfset variables.value = numberFormatValue(getAllProductMargins.Other_Spend)>
						<td class="#variables.noApprovalClass#"><cfif url.verticalPNL eq '1'>
								#big_star("Other_Spend")#
								<input type="text" name="other_spend_#getAllProductMargins.currentRow#" class="right numeric" #tabIndex(70)# #replace(variables.value,'$','')#>
							<cfelse>
								<!--- see if there is a saved what if row for this product --->
								<cfquery dbtype="query" name="variables.whatIF">
									SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
								</cfquery>
								<cfif variables.whatIF.recordCount>
									<cfset variables.value = numberFormatValue(variables.whatIF.User_Pullback)>
								</cfif>
								<!--- control tabbing navigation from top to bottom & stay in the same product --->
								<cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 60>
								<!--- assign unique name with prefix "amt_plus_" and suffix of record number for all products inside a group --->
								<input type="text" name="other_Spend_#getAllProductMargins.currentRow#" class="right" #variables.value#  #variables.disabled2# tabindex="#variables.tabIndex#">
							</cfif>
						</td>
					</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>


		<!----------------------->
		<!--- 009 - NET SALES --->
		<!----------------------->
					<cfif appSettings.getApprovalMarginType() eq 0>
			<tr class="GridviewScrollItem">
				<td class="une82"><cfoutput>#appsettings.getMarginColHeader8()#</cfoutput></td>
				<td class="sum82" id="anet_sales"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.TOTAL_NetSales * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
				<td class="sum82" id="unet_sales"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.TOTAL_NetSales ,decimalplaces = request.dollar_format)#</cfoutput></td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							#application.util.string.cellFormat(value=getAllGroupMargins.Total_Net_Sales ,decimalplaces = request.dollar_format)#
						</td>
					</cfoutput>
				<cfelse>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Net_Sales ,decimalplaces = request.dollar_format)>
								<td id="net_sales_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
									<cfif url.verticalPNL eq '1'>
										#variables.value#
										<!---<a href="##" onclick="showCalculation('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#','N','')">#variables.value#</a>--->
									<cfelse>
										<!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
										SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
										<cfset variables.value = " ">
										</cfif>
										#variables.value#
									</cfif>
								</td>
							</cfoutput>
						</cfif>
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>
		</cfif> <!--- appSettings.getApprovalMarginType() eq 0> --->

		<!------------------>
		<!--- 010 - COST --->
		<!------------------>
					<cfif Get_Profile_Settings.View_Cost eq 1>
			<tr class="GridviewScrollItem">
				<td class="une82"><cfoutput>#appsettings.getMarginColHeader9()#</cfoutput></td>
				<td class="sum82" id="acost"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Cost * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
				<td class="sum82" id="ucost"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Cost ,decimalplaces = request.dollar_format)#</cfoutput></td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							#application.util.string.cellFormat(value=getAllGroupMargins.Total_Cost ,decimalplaces = request.dollar_format)#
						</td>
					</cfoutput>
				<cfelse>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<td id="cost_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
									<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Cost ,decimalplaces = request.dollar_format)>
									<cfif url.verticalPNL eq '1'>
										#big_star("Cost")#
										<cfset element_id = "cost_popup_#getAllProductMargins.currentRow#">
										<a href="##" id="#element_id#" onclick="showCalculation('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#','C','','#element_id#')">#variables.value#</a>
										<!--- <input type="text" name="cost_#getAllProductMargins.currentRow#" class="right numeric" #tabIndex(80)#  value="#replace(variables.value,'$','')#"> --->
									<cfelse>
										<!--- see if there is a saved what if row for this product --->
										<cfquery dbtype="query" name="variables.whatIF">
										SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
										</cfquery>
										<cfif variables.whatIF.recordCount>
										<cfset variables.value = " ">  <!--- value to be calculated in calculate() --->
										</cfif>
										#variables.value#
									</cfif>
								</td>
							</cfoutput>
						</cfif>
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>
		</cfif> <!--- Get_Profile_Settings.View_Cost eq 1> --->


		<!------------------------------>
		<!--- 010b - SHUTTLE FREIGHT --->
		<!------------------------------>
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Shuttle Freight</cfoutput></td>
			<td class="sum82" id="ashuttle_freight"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_shuttle_freight * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="ushuttle_freight"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_shuttle_freight ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_shuttle_freight ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>

				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Shuttle_Freight ,decimalplaces = request.dollar_format)>
							<td id="shuttle_freight_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
								<cfif url.verticalPNL eq '1'>
									#big_star("Shuttle_Freight")#
									<input type="text" name="shuttle_freight_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(90)#  value="#sanitize_input(variables.value)#">
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
										SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
										<cfset variables.value = " ">
									</cfif>
									#variables.value#
								</cfif>
							</td>
						</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>

		<!------------------------>
		<!--- 010c - WAREHOUSE --->
		<!------------------------>
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Warehouse</cfoutput></td>
			<td class="sum82" id="awarehouse"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Custom_Warehouse * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="uwarehouse"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Custom_Warehouse ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Custom_Warehouse ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Custom_Warehouse ,decimalplaces = request.dollar_format)>
							<td id="custom_warehouse_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
								<cfif url.verticalPNL eq '1'>
									#big_star("Custom_Warehouse")#
									<input type="text" name="custom_warehouse_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(100)# value="#sanitize_input(variables.value)#">
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
									SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
									<cfset variables.value = " ">
									</cfif>
									#variables.value#
								</cfif>
							</td>
						</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>


		<!--------------------------->
		<!--- 010d - GROSS MARGIN --->
		<!--------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Gross Margin</cfoutput></td>
			<td class="sum82" id="agross_margin"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Gross_Margin * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="ugross_margin"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Gross_Margin ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Gross_Margin ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Gross_Margin ,decimalplaces = request.dollar_format)>
							<td id="gross_margin_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
								<cfif url.verticalPNL eq '1'>
									#variables.value#
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
									SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
									<cfset variables.value = " ">
									</cfif>
									#variables.value#
								</cfif>
							</td>
						</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>

		<!------------------------>
		<!--- 011 - BROKERAGE --->
		<!------------------------>
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Brokerage</cfoutput></td>
			<td class="sum82" id="acustom_brokerage"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Custom_Brokerage * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="ucustom_brokerage"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Custom_Brokerage ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Custom_Brokerage ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Custom_Brokerage ,decimalplaces = request.dollar_format)>
							<td id="custom_brokerage_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
								<cfif url.verticalPNL eq '1'>
									#big_star("Custom_Brokerage")#
									<input type="text" name="custom_brokerage_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(110)# value="#sanitize_input(variables.value)#">
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
									SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
									<cfset variables.value = " ">
									</cfif>
									#variables.value#
								</cfif>
							</td>
						</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>


		<!--------------------------------->
		<!--- 011b- CONTRIBUTION MARGIN --->
		<!--------------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Contribution Margin</cfoutput></td>
			<td class="sum82" id="acontribution_margin_alt"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Contribution_Margin_Alt * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="ucontribution_margin_alt"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Contribution_Margin_Alt ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Contribution_Margin_Alt ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Contribution_Margin_Alt ,decimalplaces = request.dollar_format)>
							<td id="contribution_margin_alt_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
								<cfif url.verticalPNL eq '1'>
									#variables.value#
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
									SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
									<cfset variables.value = " ">
									</cfif>
									#variables.value#
								</cfif>
							</td>
						</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>


		<!------------------------------------------>
		<!--- 011c- VARIABLE CONTRIBUTION MARGIN --->
		<!------------------------------------------>
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Variable Contribution Margin</cfoutput></td>
			<td class="sum82" id="avariable_contribution_margin"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Variable_Contribution_Margin * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="uvariable_contribution_margin"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Variable_Contribution_Margin ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Variable_Contribution_Margin ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
						<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Variable_Contribution_Margin ,decimalplaces = request.dollar_format)>
						<td id="variable_contribution_margin_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
							<cfif url.verticalPNL eq '1'>
								#variables.value#
							<cfelse>
								<!--- see if there is a saved what if row for this product --->
								<cfquery dbtype="query" name="variables.whatIF">
									SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
								</cfquery>
								<cfif variables.whatIF.recordCount>
									<cfset variables.value = " ">
								</cfif>
								#variables.value#
							</cfif>
						</td>
						</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>

		<!------------------------->
		<!--- 011d- MAP and MDF --->
		<!------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82">MAP and MDF</td>
			<td class="sum82" id="amap_and_mdf"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Map_Mdf * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="umap_and_mdf"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Map_Mdf ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Map_Mdf ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Map_Mdf ,decimalplaces = request.dollar_format)>
							<td id="map_mdf_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
								<cfif url.verticalPNL eq '1'>
									#big_star("Map_Mdf")#
									<input type="text" name="map_mdf_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(120)# value="#sanitize_input(variables.value)#">
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
									SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
									<cfset variables.value = " ">
									</cfif>
									#variables.value#
								</cfif>
							</td>
						</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>

		<!-------------------->
		<!--- 011e- SC & A --->
		<!-------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>SG & A</cfoutput></td>
			<td class="sum82" id="asga"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_SGA * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82" id="usga"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_SGA ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_SGA ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
						<cfoutput>  <!--- invidual products cfoutput loop --->
							<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.SGA ,decimalplaces = request.dollar_format)>
							<td id="sca_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
								<cfif url.verticalPNL eq '1'>
									#big_star("SGA")#
									<input type="text" name="sga_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value)#" #tabIndex(130)# value="#sanitize_input(variables.value)#">
								<cfelse>
									<!--- see if there is a saved what if row for this product --->
									<cfquery dbtype="query" name="variables.whatIF">
										SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
									</cfquery>
									<cfif variables.whatIF.recordCount>
										<cfset variables.value = " ">
									</cfif>
									#variables.value#
								</cfif>
							</td>
						</cfoutput>
					</cfif>
				</cfoutput>  <!--- query="getAllProductMargins"> --->
			</cfif>
		</tr>

		<!------------------------------>
		<!--- 012 - OPERATING INCOME --->
		<!------------------------------>
					<cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
			<tr class="GridviewScrollItem">
				<td class="une82"><cfoutput>#appsettings.getMarginColHeader11()#</cfoutput></td>
				<td class="sum82" id="aopr_inc"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_OprIncome  * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
				<td class="sum82" id="uopr_inc"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_OprIncome ,decimalplaces = request.dollar_format)#</cfoutput></td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">
							#application.util.string.cellFormat(value=getAllGroupMargins.Total_Operating_Income ,decimalplaces = request.dollar_format)#
						</td>
					</cfoutput>
				<cfelse>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Operating_Income ,decimalplaces = request.dollar_format)>
								<td id="opr_inc_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">#variables.value#
									<!---<input type="hidden" name="opr_income_#getAllProductMargins.currentRow#" class="right" value="#variables.value#">--->
								</td>
							</cfoutput>
						</cfif>
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>
		</cfif>  <!--- Get_Profile_Settings.View_Operating_Income eq 1> --->

		<!------------------------------>
		<!--- 013 - OPERATING MARGIN --->
		<!------------------------------>
					<cfif Get_Profile_Settings.View_Target_Margins eq 1>
						<cfif appSettings.getApprovalMarginType() eq 2><!--- Approval = Annual Case Rate --->
				<!------------------------------->
				<!--- 013a - Annual Case Rate --->
				<!------------------------------->
				<tr class="GridviewScrollItem">
					<td class="une82"><cfoutput>#appsettings.getMarginColHeader18()#</cfoutput></td>
					<td class="sum82" id="aopr_margin"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TradeAmt ,decimalplaces = request.dollar_format)#</cfoutput></td>
					<td class="sum82"> </td>

					<cfif form.product_group_level_list neq "">
						<cfoutput query="getAllGroupMargins">
							<td class="grp82">
								#application.util.string.cellFormat(value=getAllGroupMargins.Total_Trade ,decimalplaces = request.dollar_format)#
							</td>
						</cfoutput>
					<cfelse>
						<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
							<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
								select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
							</cfquery>
							<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
							<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
							<cfif url.showProducts eq "1">
								<cfoutput>  <!--- invidual products cfoutput loop --->
									<td class="#variables.noApprovalClass#">
										<cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Trade ,decimalplaces = request.dollar_format)>
										#variables.value#
									</td>
								</cfoutput>
							</cfif>
						</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
				</tr>

				<!------------------------------->
				<!--- 013B - TARGET CASE RATE --->
				<!------------------------------->
				<tr class="GridviewScrollItem">
					<td class="une82"><cfoutput>#appsettings.getMarginColHeader19()#</cfoutput></td>
					<td class="sum82"> </td>
					<td class="sum82"> </td>

					<cfif form.product_group_level_list neq "">
						<cfoutput query="getAllGroupMargins">
							<td class="grp82">&nbsp;</td>
						</cfoutput>
					<cfelse>
						<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
							<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
								select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
							</cfquery>
							<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
							<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
							<cfif url.showProducts eq "1">
								<cfoutput>  <!--- invidual products cfoutput loop --->
								<td class="#variables.noApprovalClass#"> </td>
								</cfoutput>
							</cfif>
						</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
				</tr>
			<cfelse>  <!--- appSettings.getApprovalMarginType() eq 2 --->
				<!--------------------------------------->
				<!--- 013M - OPERATING MARGIN PERCENT --->
				<!--------------------------------------->
				<tr class="GridviewScrollItem">
					<td class="une82"><cfoutput>#appsettings.getMarginColHeader12()#</cfoutput></td>
					<td class="sum82" id="aopr_margin"><cfoutput>#application.util.string.cellFormat(getProgramMargins.Total_OprMargin, "")#%</cfoutput></td>
					<td class="sum82"> </td>

					<cfif form.product_group_level_list neq "">
						<cfoutput query="getAllGroupMargins">
							<td class="grp82">
								#application.util.string.cellFormat(getAllGroupMargins.Total_OperatingMargin_percent, '')#%
							</td>
						</cfoutput>
						<cfelse>
						<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
							<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
								select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
							</cfquery>
							<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
							<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
							<cfif url.showProducts eq "1">
								<cfoutput>  <!--- invidual products cfoutput loop --->
									<td id="opr_margin_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
									<cfset variables.value = application.util.string.cellFormat(getAllProductMargins.OperatingMargin_percent, "")>
									#variables.value#%
									<!---<input type="hidden" name="opr_margin_#getAllProductMargins.currentRow#" class="right" value="#variables.value#">--->
									</td>
								</cfoutput>
							</cfif>
						</cfoutput>  <!--- query="getAllProductMargins"> --->

						</cfif>
				</tr>
			</cfif> <!--- appSettings.getApprovalMarginType() eq 2> --->
		</cfif> <!--- Get_Profile_Settings.View_Target_Margins eq 1> --->

		<!---------------------->
		<!--- 014 - TRADE CS --->
		<!---------------------->
					<cfif appSettings.getApprovalMarginType() eq 1>
			<tr class="GridviewScrollItem">
				<td class="une82"><cfoutput>#appsettings.getMarginColHeader16()#</cfoutput></td>
				<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TradeAmt * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
				<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TradeAmt ,decimalplaces = request.dollar_format)#</cfoutput></td>

				<cfif form.product_group_level_list neq "">
					<cfoutput query="getAllGroupMargins">
						<td class="grp82">&nbsp;</td>
					</cfoutput>
				<cfelse>
					<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
						<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
							select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
						</cfquery>
						<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
						<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
						<cfif url.showProducts eq "1">
							<cfoutput>  <!--- invidual products cfoutput loop --->
								<td class="#variables.noApprovalClass#"> </td>
							</cfoutput>
						</cfif>
					</cfoutput>  <!--- query="getAllProductMargins"> --->
					</cfif>
			</tr>
		</cfif> <!--- appSettings.getApprovalMarginType() eq 1> --->


		<!-------------------------------->
		<!--- 016 - TRADE SPENT | CSA  --->
		<!-------------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Trade Spend $</cfoutput></td>
			<td class="sum82" id="acsa"><cfoutput>#application.util.string.cellFormat(value=program_spend_in_margin_uot ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82"> </td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Total_Item_Allowance * round(getAllGroupMargins.Total_Product_Program_Volume) ,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<cfif url.showProducts eq "1">
					<cfoutput>  <!--- invidual products cfoutput loop --->
						<td id="csa_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
							<cfset variables.value = application.util.string.cellFormat(value = getAllProductMargins.Item_Allowance * round(getAllProductMargins.Product_Program_Volume) ,decimalplaces = request.dollar_format)>
							#variables.value#
						</td>
					</cfoutput>
					</cfif>
		</cfoutput>  <!--- query="getAllProductMargins"> --->
		</cfif>
		</tr>


		<!-------------------------------->
		<!--- 017 - Net Sales Target   --->
		<!-------------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Net Sales Target</cfoutput></td>
			<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Net_Sales_Target_Value * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Net_Sales_Target_Value ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Net_Sales_Target_Value,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfif url.showProducts eq "1">
					<cfoutput>  <!--- invidual products cfoutput loop --->
						<td id="csa_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
							<cfset variables.value = application.util.string.cellFormat(value = getAllProductMargins.Net_Sales_Target_Value ,decimalplaces = request.dollar_format)>
							#variables.value#
						</td>
					</cfoutput>
					</cfif>
		</cfoutput>  <!--- query="getAllProductMargins"> --->
		</cfif>
		</tr>


		<!-------------------------------->
		<!--- 018 - Net Sales Floor    --->
		<!-------------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>Net Sales Floor</cfoutput></td>
			<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Net_Sales_Floor_Value * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Net_Sales_Floor_Value ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.Net_Sales_Floor_Value1,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfif url.showProducts eq "1">
					<cfoutput>  <!--- invidual products cfoutput loop --->
						<td id="csa_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
							<cfset variables.value = application.util.string.cellFormat(value = getAllProductMargins.Net_Sales_Floor_Value ,decimalplaces = request.dollar_format)>
							#variables.value#
						</td>
					</cfoutput>
					</cfif>
		</cfoutput>  <!--- query="getAllProductMargins"> --->
		</cfif>
		</tr>


		<!-------------------------------->
		<!--- 019 - Gross Margin Target --->
		<!-------------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>GM Target</cfoutput></td>
			<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_GM_Target_Value * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_GM_Target_Value ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.GM_Target_Value1,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfif url.showProducts eq "1">
					<cfoutput>  <!--- invidual products cfoutput loop --->
						<td id="csa_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
							<cfset variables.value = application.util.string.cellFormat(value = getAllProductMargins.GM_Target_Value ,decimalplaces = request.dollar_format)>
							#variables.value#
						</td>
					</cfoutput>
					</cfif>
		</cfoutput>  <!--- query="getAllProductMargins"> --->
		</cfif>
		</tr>


		<!-------------------------------->
		<!--- 020 - Gross Margin Floor --->
		<!-------------------------------->
		<tr class="GridviewScrollItem">
			<td class="une82"><cfoutput>GM Floor</cfoutput></td>
			<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_GM_Floor_Value * getProgramMargins.TotalProgramVolume ,decimalplaces = request.dollar_format)#</cfoutput></td>
			<td class="sum82"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_GM_Floor_Value ,decimalplaces = request.dollar_format)#</cfoutput></td>

			<cfif form.product_group_level_list neq "">
				<cfoutput query="getAllGroupMargins">
					<td class="grp82">
						#application.util.string.cellFormat(value=getAllGroupMargins.GM_Floor_Value1,decimalplaces = request.dollar_format)#
					</td>
				</cfoutput>
			<cfelse>
				<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
					<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
						select Group_ID_Approval from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
					</cfquery>
					<cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
					<cfif url.showProducts eq "1">
					<cfoutput>  <!--- invidual products cfoutput loop --->
						<td id="csa_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass#">
							<cfset variables.value = application.util.string.cellFormat(value = getAllProductMargins.GM_Floor_Value ,decimalplaces = request.dollar_format)>
							#variables.value#
						</td>
					</cfoutput>
					</cfif>
		</cfoutput>  <!--- query="getAllProductMargins"> --->
		</cfif>
		</tr>

		</table>    <!--- id="t82"> --->
	</cfsavecontent>
	<cfoutput>#application.util.string.compress( variables.mainContent )#</cfoutput>
	<script>
	function showPullbackCalculation(CPID){
	<cfoutput>
		NewWindow('/common_files/contracts/pullbacks/Contract_Pullback_Analysis.cfm?ProductId='+CPID+'&CID=#URL.CID#&type=CS&margin_type=#form.margin_type#','PullbackAnalysis','750','350','Yes', 'Yes')
	</cfoutput>
	}

	document.getElementById('IPDiff').innerHTML=<cfoutput>'#application.util.string.cellFormat(value=TotalIPDiff, category = "dollar2" )#'</cfoutput>;

	</script>
</cffunction>		<!--- <cffunction name="verticalPNL"> --->

<!-------------------------------------------------------------------------------------------------------------------->
<!---  HORIZONTALPNL()  ---------------------------------------------------------------------------------------------->
<!-------------------------------------------------------------------------------------------------------------------->
<cffunction name="horizontalPNL">
	<cfset useLakebaseForgetGlobalUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGlobalUOM>
	<cftry>
		<cfset getGlobalUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "global_target_uom"
			}), "global_target_uom"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGlobalUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGlobalUOM>
<cfquery name="getGlobalUOM" datasource="#application.datasource#">
		SELECT Global_Target_UOM
		FROM General_Settings
	</cfquery>
</cfif>
	<cfif appSettings.getApprovalMarginType() NEQ 3>
		<cfset UOMdisplay = '%'>
	<cfelse>
		<cfif getGlobalUOM.Global_Target_UOM EQ 1>
			<cfset UOMdisplay = 'CS'>
		<cfelseif getGlobalUOM.Global_Target_UOM EQ 2>
			<cfset UOMdisplay = 'LB'>
		<cfelseif getGlobalUOM.Global_Target_UOM EQ 3>
			<cfset UOMdisplay = 'Equiv Cs'>
		<cfelse>
			<cfset UOMdisplay = 'CS'>
		</cfif>
	</cfif>

	<cfoutput>
	<cfif ! url.idealPriceAnalysis>
	<span id="approval_consideration">#variables.approval_consideration.getProgramText( getProgramInfo.contract_main_id )#</span>
	<table class="Maintable" cellpadding="0" cellspacing="0" width="100%">
		<tr>
			<td align="left" style="color:red;font-size:11px;border-bottom:none;">
			<!---D50860 :: Release 8.0 - Improvements to the 'View Margin' page inside a program START --->
				<cfif isDefined("ProgramIsARevision") AND ProgramIsARevision NEQ 0>
					<div style="float:left;margin-right:80px;">*** NOTE: This Is A Revision Of An Existing Program ***</div>
				</cfif>
			<!---D50860 :: Release 8.0 - Improvements to the 'View Margin' page inside a program END --->
			</td>
			<td style="font-size: 12px; border-bottom:none;" align="right">
				<cfset newSpan = 1>
				<cfif DisplayMarginUOMCS>
					<cfset newSpan = newSpan + 1>
				</cfif>
				<cfif DisplayMarginUOMLB>
					<cfset newSpan = newSpan + 1>
				</cfif>
				<cfif DisplayMarginUOMEQ>
					<cfset newSpan = newSpan + 1>
				</cfif>
				<table>
					<tr>
						<td style="border:none;" align="left" colspan="#newSpan#">#unitOfTime4Volume#</td>
					</tr>
					<tr>
						<td style="width:58px;border:none;text-align: right;">UOM :</td>
						<cfif DisplayMarginUOMCS>
						<td  style="border:none;">
							<input type="radio" name="Margin_Type" value="1" <cfif form.margin_type eq 1>checked</cfif> onClick = "changemarginType(1);">Physical Case &nbsp;&nbsp;
						</td>
					</cfif>
					<cfif DisplayMarginUOMLB>
						<td  style="border:none;">
							<input type="radio" name="Margin_Type" value="3" <cfif form.margin_type eq 3>checked</cfif> onClick = "changemarginType(3);"><cfoutput>#Application.UOMPoundPlural# &nbsp;&nbsp;</cfoutput>
						</td>
					</cfif>
					<cfif DisplayMarginUOMEQ>
						<td  style="border:none;">
							<input type="radio" name="Margin_Type" value="2" <cfif form.margin_type eq 2>checked</cfif> onClick = "changemarginType(2);"><cfoutput>#appsettings.getMarginColHeader22()#</cfoutput>
						</td>
					</cfif>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<cfif isDefined("MarginDate")>
					<div style="float:left;width:100%">#MarginDate#</div>
				</cfif>
			</td>
		</tr>
	</table>
<cfelse>
	<!--- 114617 :: Ideal Price START --->
	<table cellpadding="5" cellspacing="0" width="100%" border="0">
		<tr style="width:49%">
			<td colspan="3"><SPAN CLASS="Title4">[#getProgramInfo.Contract_Number#] : Ideal Price Analysis</span><br>Try different prices to see the effect.</td>
		</tr>
		<tr style="width:49%">
			<td style="width:33%">
				<table border="0" width="100%">
					<tr>
						<td style="width:28%">
							<button type="button" id="SelectItems" title="Select All Items" class="button recommended">Select All Items</button>
							<button type="button" id="UnselectItems" title="Unselect All Items" class="button recommended" style="display:none;">Un Select All Items</button>
						</td>
						<td>
							<button type="button" id="IdealPriceUpdate" title="Ideal Price Update" class="button">Set to Ideal Price Plus</button>
							<input type="text" size="2" name="IdealPricePlus" id="IdealPricePlus" value="0">%
						</td>
					</tr>
				</table>
			</td>
			<td style="width:33%">
				<input type="checkbox" name="LowerThanIdeal" id="LowerThanIdeal" value="1" <cfif url.Lower_Than_Ideal>Checked</cfif>>Show only lower than Ideal
				<input type="hidden" name="MarginType" value="<cfoutput>#form.margin_type#</cfoutput>">
			</td>
			<td style="width:33%;text-align:right;padding-right:50px;">
				<cfif getProgramInfo.Contract_Status_Type_IDX LTE 2>
				<button type="button" id="Save" title="Save Ideal Price" class="button recommended">Save</button>
				</cfif>
				<button type="button" id="Reset" title="Reset Ideal Price" class="button">Reset</button>
				<button type="button" id="Download" title="Download Ideal Price" class="button">Download</button>
				<button type="button" id="Margins" title="Back To Margins" class="button">View Margins</button>
				UOM :
				<cfif form.margin_type eq 1>Physical Case &nbsp;&nbsp;
				<cfelseif form.margin_type eq 2><cfoutput>#appsettings.getMarginColHeader22()# &nbsp;&nbsp;</cfoutput>
				<cfelseif form.margin_type eq 3><cfoutput>#Application.UOMPoundPlural# &nbsp;&nbsp;</cfoutput>
				<cfelse> N/A
				</cfif>
			</td>
		</tr>
	</table>
	<!--- 114617 :: Ideal Price END --->
</cfif>
</cfoutput>


<cf_include files="/script/javascript/gridviewscroll/1.0/gridviewscroll.js, /Script/javascript/gridviewscroll/1.0/gridviewscroll-for-margin.css">
<link rel="stylesheet" type="text/css" href="/styles/table.css">
<style>
body, html {
    height: 100%;
	overflow-y: hidden;
}
#tbl-container22 {
    height: calc(100vh - 165px);
    min-height: calc(100vh - 165px);
    max-height: calc(100vh - 165px);
}
.datagrid td {
	height: 18px !important;
}
</style>

<!--- <link rel="stylesheet" type="text/css" href="/styles/table.css"> --->
<div id="tbl-container22">
<table class="datagrid" style="width: 100%;" id="GridView1">

	<tr>
		<cfset tdLen = 0>
		<!---   check if they can see the base view --->
		<cfif Get_Profile_Settings.Base_View eq 1>
			<th class="header" valign="middle"><cfset th_count++><b>Description</b><br>&nbsp;<br>&nbsp;</th>
			<cfset tdLen = tdLen + 1>
		<!--- 114617 :: Ideal Price START --->
		<cfif getProgramInfo.Ideal_Price>
			<th valign="middle" class="header forceLeft 2590"> <cfset th_count++> <B>Ideal Price</B></th>
		</cfif>
		<cfset tdLen = tdLen + 1>
		<!--- 114617 :: Ideal Price END --->

			<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
	  		<cfif variables.bDisplayContractPrice>
	  			<!--- 16314 [begin] --->
		  		<th class="header" valign="middle" style="padding-top:2;" nowrap> <cfset th_count++>
					<!--- default to "Fixed Price" --->
			  		<span style="cursor:help;">
						<b><cfoutput><cfif len(trim(appsettings.getMarginColHeader15()))>#replace(appsettings.getMarginColHeader15()," ","<br>","All")#<cfelse>Fixed Price</cfif></cfoutput></b><br>
						<IMG SRC="/Images/i.gif"  onmouseover="initTheTooltip('The value represents the fixed price offered on the program for this item.')" onmouseout="popOut()">
			  		</span>
		  		</th>
		  		<cfset tdLen = tdLen + 1>
		  		<!--- 16314 [end] --->
	  		</cfif>
	  		<!--- 17289 > 16314 follow up 10/14/08 [end] --->
          <!--- 114617 :: Ideal Price START --->
					<cfif getProgramInfo.Ideal_Price>
						<th valign="middle" class="header">Diff <cfset th_count++></th>
						<cfset tdLen = tdLen + 1>
						<th valign="middle" class="header">Dollars <cfset th_count++></th>
						<cfset tdLen = tdLen + 1>
					</cfif>
					<!--- 114617 :: Ideal Price END --->
			<!--- The reason why we have "z-index:1" for multiple cells below is so that the content of <smallhelp> above can be fully be above these cells.
			Without using z-index,the contents of <smallhelp> gets hidden behind these cells.
			--->
	   		<th class="header" valign="middle" style="z-index:1"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader1()," ","<br>","All")#</cfoutput></b></th>
			<cfset tdLen = tdLen + 1>

			<!--- Base Sales --->
			<th class="header" valign="middle" style="z-index:1"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader2()," ","<br>","All")#</cfoutput></b>
				<cfif appSettings.getUseFixedPriceType()><br><cfoutput>
						<!--- Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  START
							What  I did: added ListLast to display numbers after "_"--->
						(<!---#getProgramInfo.Price_List_ID#--->
						#ListLast(getProgramInfo.price_list_id, "_")#
						<!--- End Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  --->
						<cfif getProgramInfo.priceBracket_Update eq 1><sup class="overriddenShow">*</sup></cfif>)</cfoutput>
				</cfif>
	  		</th>
			<cfset tdLen = tdLen + 1>

			<!--- ALlow/Surch ---->
			<th class="header" valign="middle"> <cfset th_count++> <b>Allow/<br/>Surch</b></th>
			<cfset tdLen = tdLen + 1>

			<!--- Customer Freight ---->
			<th class="header" valign="middle" title="Customer Freight"> <cfset th_count++> <b>Cust<br>Frt</b></th>
			<cfset tdLen = tdLen + 1>

			<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
			<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
			<cfif appsettings.getDisplayCashDiscountMargin() eq 1 >
				<cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
					<th class="header" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader3()," ","<br>","All")#</cfoutput></b></th>
					<cfset tdLen = tdLen + 1>
				</cfif>
				<cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
					<th class="header" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader4()," ","<br>","All")#</cfoutput></b></th>
					<cfset tdLen = tdLen + 1>
				</cfif>
			</cfif>

			<!--- allowance --->
			<cfif direct_pricing eq 0>
				<th class="header" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader5()," ","<br>","All")#</cfoutput></b>
					<cfif appSettings.getApprovalMarginType() eq 2>
						<img src="/Images/i.gif" title="The spending rates expressed represent the annualized values for this program as well as other concurrent programs. For example, a rebate of $1.00 per case offered for 6 months will contribute $0.50 per case on an annual basis.">
					</cfif>
				</th>
				<cfset tdLen = tdLen + 1>
				<!--- Allow % --->
				<th class="header" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader23()," ","<br>","All")#</cfoutput></b></th>
				<cfset tdLen = tdLen + 1>
			</cfif>

			<cfif ShowTPA eq 1>
				<!--- TPA Operator --->
				<th class="header" valign="middle" title="Other Operator Trade"> <cfset th_count++> <b>Oper<br>Trade</b></th>
				<cfset tdLen = tdLen + 1>
				<!--- TPA Distributor (Distributor Trade) --->
				<th class="header" valign="middle"  title="Other Distributor Trade"> <cfset th_count++> <b>Dist<br>Trade</b></th>
				<cfset tdLen = tdLen + 1>
			</cfif>

			<cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
				<th class="header" valign="middle" > <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader7()," ","<br>","All")#</cfoutput></b></th>
				<cfset tdLen = tdLen + 1>
			</cfif>

			<!--- Other Spend --->
			<th class="header" valign="middle" > <cfset th_count++> <b>Other<br/>Spend</b></th>
			<cfset tdLen = tdLen + 1>

			<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
			<cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
				<!--- net sales --->
				<th class="header" valign="middle" > <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader8()," ","<br>","All")#</cfoutput></b></th>
				<cfset tdLen = tdLen + 1>
			</cfif>
		</cfif>

		<!---   check if they can see the cost --->
		<cfif Get_Profile_Settings.View_Cost eq 1>
			<th class="header" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader9()," ","<br>","All")#</cfoutput></b></th>
			<cfset tdLen = tdLen + 1>
		</cfif>

		<!---   check if they can see the brokerage --->
		<cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
			<th class="header" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader10()," ","<br>","All")#</cfoutput></b></th>
			<cfset tdLen = tdLen + 1>
		</cfif>

		<!--- Shuttle Freight --->
		<th class="header" valign="middle"  title="Shuttle Freight"> <cfset th_count++> <b>Shuttle<br>Frt</b></th>
		<cfset tdLen = tdLen + 1>

		<!--- Warehouse --->
		<th class="header" valign="middle"  title="Warehouse"> <cfset th_count++> <b>Whse</b></th>
		<cfset tdLen = tdLen + 1>

		<!--- Gross Margin --->
		<th class="header 2306" valign="middle"  title="Gross Margin"> <cfset th_count++> <b>GM</b></th>
		<cfset tdLen = tdLen + 1>

		<!--- Brokerage --->
		<th class="header 2310" valign="middle" title="Brokerage"> <cfset th_count++> <b>Brkg</b></th>
		<cfset tdLen = tdLen + 1>

		<!--- Contribution Margin --->
		<th class="header 2314" valign="middle" title="Contribution Margin"> <cfset th_count++> <b>CM</b></th>
		<cfset tdLen = tdLen + 1>

		<!--- Variable Contribution Margin --->
		<th class="header 2318" valign="middle" title="Variable Contribution Margin"> <cfset th_count++> <b>Var<br>CM</b></th>
		<cfset tdLen = tdLen + 1>

		<!--- MAP and MDF --->
		<th class="header 2322" valign="middle"> <cfset th_count++> <b>MAP/<br>MDF</b></th>
		<cfset tdLen = tdLen + 1>

		<!--- SG & A --->
		<th class="header 2326" valign="middle" nowrap="nowrap"> <cfset th_count++> <b>SG & A</b></th>
		<cfset tdLen = tdLen + 1>

		<!---   check if they can see the Operating_Income --->
		<cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
			<th class="header 2331" valign="middle" > <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader11()," ","<br>","All")#</cfoutput></b></th>
			<cfset tdLen = tdLen + 1>
		</cfif>
		<!---   check if they can see the Target_Margins --->
		<cfif Get_Profile_Settings.View_Target_Margins eq 1>
			<cfif appSettings.getApprovalMarginType() eq 2><!--- Approval = Annual Case Rate --->
				<!--- Annual Case Rate --->
				<th class="header 2338" valign="middle" align="left"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader18()," ","<br>","All")#</cfoutput></b></th>
				<cfset tdLen = tdLen + 1>
				<th class="header 2341" class="csvExclude"> <cfset th_count++> &nbsp;99999</th> <cfset tdLen = tdLen + 1>
				<th class="header 2342" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader19()," ","<br>","All")#</cfoutput></b></th>
				<cfset tdLen = tdLen + 1>
			<cfelse>
				<!--- Operating Margin Percent --->
				<cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
					<th class="header 2347" valign="middle" align="left"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader12()," ","<br>","All")#</cfoutput></b></th>
					<cfset tdLen = tdLen + 1>
				</cfif>
				<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START --->
				<cfif Cont_Margin_Calculation EQ '1'>
					<th class="header 2352" valign="middle" align="left"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader24()," ","<br>","All")#</cfoutput></b></th>
					<cfset tdLen = tdLen + 1>
					<th class="header 2354" valign="middle" align="left"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader25()," ","<br>","All")#</cfoutput></b></th>
					<cfset tdLen = tdLen + 1>
				</cfif>
				<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
				<!--- margin target --->
				<!--- need to have a unvisible image (zero opacity) to support a smooth horizontal scrolling --->
				<th class="header 2360 csvExclude"> <cfset th_count++> <cfoutput> #img_1010# </cfoutput> </th>
				<cfset tdLen = tdLen + 1>
			<cfif margin_display_style NEQ "custom_t">
				<th class="header 2363" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader13()," ","<br>","All")# #UOMdisplay#</cfoutput></b></th>
				<cfset tdLen = tdLen + 1>
			</cfif>
			</cfif>
		</cfif>

		<cfif appSettings.getApprovalMarginType() eq 1>
			<th align="center" class="header 2370" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader16()," ","<br>","All")#</cfoutput></b></th>
			<cfset tdLen = tdLen + 1>
		</cfif>

		<!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
		<cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>
			<th align="center" class="header 2376" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader17()," ","<br>","All")#</cfoutput></b></th>
			<cfset tdLen = tdLen + 1>
		</cfif>

		<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
		<cfif Get_Profile_Settings.Base_View eq 1>
			<th align="center" class="header 2382" valign="middle"> <cfset th_count++> <b><cfoutput>#Replace(appsettings.getMarginColHeader14()," ","<br>","All")#</cfoutput></b></th>
			<cfset tdLen = tdLen + 1>
		</cfif>

		<cfoutput>
		<cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
			<th class="header 2390 csvExclude" valign="middle"> <cfset th_count++> <input type="checkbox" value="1" name="checkall" onclick="selectAll()" checked></th>
			<th class="header 2391 csvExclude" valign="middle"> <cfset th_count++> <b>Approve/ Agree</b></th>
			<th class="header csvExclude 2393"> <cfset th_count++> &nbsp;</th>
			<th class="header csvExclude 2394"> <cfset th_count++> &nbsp;</th>
		<cfelse>
			<!--- <th class="header csvExclude 2397"> <cfset th_count++>#img_1010#</th>
			<th class="header csvExclude 2398"> <cfset th_count++>#img_1010#</th> --->
		</cfif>
		</cfoutput>
	</tr>
		<cfset   count          = 0>
		<cfset   OuterLoopcount = 1>
		<cfquery name="getProductMarginCount" dbtype="query">
			SELECT COUNT(*) As ProductMarginCount
			FROM getAllProductMargins
			GROUP BY Type_Code_Desc_ID
		</cfquery>
		<cfset ProductMarginCount = getProductMarginCount.Recordcount>
		<cfif appSettings.getMarginItemsExclude()>
			<cfquery NAME="getExcludedProductMarginCount" DBTYPE="query">
				SELECT COUNT(*) As ExcludedProductMarginCount
				FROM getAllExcludedProductMargins
				GROUP BY Type_Code_Desc_ID
			</cfquery>
			<cfset ExcludedProductMarginCount = getExcludedProductMarginCount.Recordcount>
		</cfif>

		<!--- Dev Note: KAL; 9/13/2010; D23601: Margin display for regualar items --->
		<!--------------------------------------------------------------------------->
		<!--- Products main loop group by type code - start ------------------------->
		<!--------------------------------------------------------------------------->
		<!--- Get the entire data from the "Program_Type_Code_Approval_Info" table for this program.
		This query can be used as a "Query of Query" below.
		--->
		<cfquery name="getTypeCodeApprovalInfo" datasource="#application.datasource#">
			select tbl1.Type_code_Desc_ID,tbl1.Product_ID,IsNull(tbl1.Approve,0) As Approve, IsNull(tbl1.Agree,0) As Agree
					,tbl1.User_ID, IsNull(tbl1.System_Agreement, 0) As System_Agreement,_Users.Name_Last,_Users.Name_First
			from Program_Type_Code_Approval_Info tbl1
			LEFT JOIN  _Users
			ON _Users.user_id = tbl1.User_Id
			and _Users.deleted = 0
			where program_id = #contract_main_id#
			and tbl1.deleted = 0
		</cfquery>
		<cfset TotalDiffDollar = 0>
		<cfset TotalPrgDiffDollar=0>
		<cfset itemCount = 0>
		<cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
			<!--- mass approve --->
			<cfset itemCheckBoxDisabled = 0>

			<cfset useLakebaseForgetGroupvalues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallgroupmargins")>
<cfif useLakebaseForgetGroupvalues>
	<cftry>
		<cfset getGroupvalues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallgroupmargins", {
				"type_code_desc_id" = "eq.#getAllProductMargins.Type_Code_Desc_Id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGroupvalues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGroupvalues>
<cfquery name="getGroupvalues" dbtype="query">
				select * from getAllGroupMargins
				where Type_Code_Desc_Id = '#getAllProductMargins.Type_Code_Desc_Id#'
			</cfquery>
</cfif>
			<!--- add variation to group margin --->
			<cfif trim(getGroupvalues.Group_ID_Margin) eq "">
				<cfset getGroupvalues.Group_ID_Margin = 0>
			</cfif>

			<cfif trim(getGroupvalues.Group_ID_Margin) NEQ "*" and trim(getGroupvalues.Group_ID_Margin) NEQ "">
				<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 1>
					<cfset groupapprovalmargin = Target_Margin + ((Target_Margin * getGroupvalues.Group_ID_Margin)/100)>
				<cfelse>
					<cfset groupapprovalmargin = Target_Margin - ((ABS(Target_Margin) * getGroupvalues.Group_ID_Margin)/100)>
				</cfif>
			<cfelse>
				<cfset groupapprovalmargin = "*">
			</cfif>

			<cfset groupTargetCaseRateUOM = Target_Case_Rate_UOM>
			<cfset groupTargetCaseRate    = Target_Case_Rate>
			<cfset groupTargetLBRate      = Target_LB_Rate>

			<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<!--- check if the group margin is within limits, if not they cannot approve items either --->
				<cfif getGroupvalues.Total_Trade_Percent GT groupapprovalmargin  AND Trim(getGroupvalues.Group_ID_Margin) NEQ "*">
					<cfset CannotApproveGroupMargin = 1>
					<cfset CannotApproveItemMargin  = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
						<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Type_Code_Desc#.")>
					</cfif>
				</cfif>
			<cfelseif appSettings.getApprovalMarginType() eq 0>
				<!--- check if the group margin is within limits, if not they cannot approve items either --->
				<cfif getGroupvalues.Total_OperatingMargin_percent LT groupapprovalmargin  AND Trim(getGroupvalues.Group_ID_Margin) NEQ "*">
					<cfset CannotApproveGroupMargin = 1>
					<cfset CannotApproveItemMargin = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
						<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Type_Code_Desc#.")>
					</cfif>
				</cfif>
			<cfelseif appSettings.getApprovalMarginType() eq 2 AND Get_Profile_Settings.Approve_Beyond_Annual_Case_Rate eq 0>
				<cfif groupTargetCaseRateUOM eq 1 AND getGroupvalues.Total_Trade_CS GT groupTargetCaseRate>
					<cfset CannotApproveGroupMargin = 1>
					<cfset CannotApproveItemMargin = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
						<cfset temp = ArrayAppend(messageArray, "Annual case rate is not within the target for #Type_Code_Desc#.")>
					</cfif>
				<cfelseif groupTargetCaseRateUOM eq 2 AND getGroupvalues.Total_Trade_LB GT groupTargetLBRate>
					<cfset CannotApproveGroupMargin = 1>
					<cfset CannotApproveItemMargin = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
						<cfset temp = ArrayAppend(messageArray, "Annual pound rate is not within the target for #Type_Code_Desc#.")>
					</cfif>
				</cfif>
			<!--- 70104 Absolute Net Sales $ per Lb or Equiv Case --->
			<cfelseif appSettings.getApprovalMarginType() eq 3>
				<cfif getGroupvalues.Global_Total_Margin GT groupapprovalmargin  AND Trim(getGroupvalues.Group_ID_Margin) NEQ "*">
					<cfset CannotApproveGroupMargin = 1>
					<cfset CannotApproveItemMargin = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
						<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Type_Code_Desc#.")>
					</cfif>
				</cfif>
			</cfif>

		<!--- 72497 :: Program Approval - Annual Volume and % of List Price START--->
			<cfset groupApprovalMarginListPrice = 0>
			<cfif trim(getGroupvalues.Group_ID_List_Price) NEQ "*" and trim(getGroupvalues.Group_ID_List_Price) NEQ "">
				<cfset groupApprovalMarginListPrice = Target_Margin_ListPrice + ((Target_Margin_ListPrice * getGroupvalues.Group_ID_List_Price)/100)>
			<cfelse>
				<cfset groupApprovalMarginListPrice = "*">
			</cfif>

			<cfset Total_Allowance_Percent = 100>
			<cfif appSettings.getApprovalMarginType() eq 2>
				<cfset Total_Item_Allowance_Display_Value = getGroupvalues.Total_Item_Allowance_Annualized>
			<cfelse>
				<cfset Total_Item_Allowance_Display_Value = getGroupvalues.Total_Item_Allowance>
			</cfif>

			<cfif Total_Item_Allowance_Display_Value eq 0 OR getGroupvalues.Total_Base_Sales eq 0>
				<cfset Total_Allowance_Percent = 100>
			<cfelseif Total_Item_Allowance_Display_Value LT 0>
				<cfset Total_Allowance_Percent = 0>
			<cfelse>
				<cfset Total_Allowance_Percent = (Total_Item_Allowance_Display_Value/getGroupvalues.Total_Base_Sales) * 100>
			</cfif>

			<cfif Total_Allowance_Percent GT groupApprovalMarginListPrice  AND Trim(getGroupvalues.Group_ID_List_Price) NEQ "*">
				<cfset CannotApproveGroupMargin = 1>
				<cfset CannotApproveItemMargin = 1>
				<cfif getGroupvalues.Group_ID_Approval eq 1>
					<cfset itemmarginfailure = 1>
					<cfset temp = ArrayAppend(messageArray, "Discount % is not within your limits for #Type_Code_Desc#.")>
				</cfif>
			</cfif>
		<!--- 72497 :: Program Approval - Annual Volume and % of List Price END --->

			<cfif getGroupvalues.Group_ID_Approval eq 0>
				<cfset CannotApproveGroupMargin = 1>
				<cfset disablecheckbox          = "disabled">
				<cfset itemCheckBoxDisabled     = 1>
				<cfset temp                     = ArrayAppend(messageArray, "You cannot approve #Type_Code_Desc#")>
				<cfset grouptrbgcolor           = "##d3d3d3">
				<cfset itemtrbgcolor            = "##d3d3d3">
				<cfset form.RestrictedList      = listAppend(form.RestrictedList,BSA_Foodservice_Items_Master_Id ) >
			</cfif>

			<!------------------------------------------------------------------------------------------------------------------->
			<!--- Begin: Outputs the individual items  -------------------------------------------------------------------------->
			<!------------------------------------------------------------------------------------------------------------------->
			<cfoutput>
			<cfif getGroupvalues.Group_ID_Approval eq 0>
				<cfset CannotApproveItemMargin = 1>
			</cfif>

			<!--- check if the group margin is within limits, if not they cannot approve items either --->
			<cfif (appSettings.getApprovalMarginType() eq 0) AND (getGroupvalues.Total_OperatingMargin_percent LT groupapprovalmargin)  AND (Trim(getGroupvalues.Group_ID_Margin) NEQ "*")>
				<cfset CannotApproveItemMargin = 1>
			<cfelseif (appSettings.getApprovalMarginType() eq 1) AND (getGroupvalues.Total_Trade_Percent GT groupapprovalmargin)  AND (Trim(getGroupvalues.Group_ID_Margin) NEQ "*")>
				<cfset CannotApproveItemMargin = 1>
			<cfelseif appSettings.getApprovalMarginType() eq 2 AND Get_Profile_Settings.Approve_Beyond_Annual_Case_Rate eq 0>
				<cfif groupTargetCaseRateUOM eq 1 AND getGroupvalues.Total_Trade_CS GT groupTargetCaseRate>
					<cfset CannotApproveItemMargin = 1>
				<cfelseif groupTargetCaseRateUOM eq 2 AND getGroupvalues.Total_Trade_LB GT groupTargetLBRate>
					<cfset CannotApproveItemMargin = 1>
				</cfif>
			</cfif>

			<!--- Check if item is beyond ez max rate --->
			<cfif ListFind(lProductsBeyondMaxRateList, BSA_Foodservice_Items_Master_ID)>
				<cfset CannotApproveItemMargin  = 1>
				<cfset CannotApproveGroupMargin = 1>
			</cfif>
			<cfset itemCount = itemCount + 1>
			<!--- check if the profile has rights to have base view --->
			<cfif Get_Profile_Settings.Base_View eq 1>
				<tr class="csv" BGCOLOR="#itemtrbgcolor#" valign="middle" bsaid="#BSA_Foodservice_Items_Master_ID#" tcid="#Type_Code_Desc_ID#" id="#Type_Code_Desc_ID#_#itemCount#">  <!--- 34662 --->
					<td class="2585" align="left" nowrap>
					<!--- Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  START
					Added/Changed: Added IF condition to toggle display--->
					<!--- 114617 :: Ideal Price START --->
					<cfif url.idealPriceAnalysis>
						<input type="checkbox" tabindex="-1" <cfif ! Ideal_Price>disabled</cfif> class ="BSAID_Single csvExclude" name="#BSA_Foodservice_Items_Master_ID#" id="#BSA_Foodservice_Items_Master_ID#" value="1" TypeCode="#Type_Code_Desc_ID#">
					</cfif>
					<!--- 114617 :: Ideal Price END --->
						<cfif form.margin_type eq 2>
						<span style="cursor:pointer;" onmouseover="initTheTooltip('Stat Case Value:#trim(numberformat(CASE_EQUIVALENT,'_-___,___,___,___,___.___'))#')" onmouseout="popOut()">
							<cfif appSettings.getViewPgmSortBy()>#Description#<br><cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>#upc#<cfelse>#Item#</cfif><cfelse><cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>#upc#<cfelse>#Item#</cfif><br><cfif url.idealPriceAnalysis>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif> #Description#</cfif>
						</span>
					<cfelse>
						<cfif appSettings.getViewPgmSortBy()>#Description#<br><cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>#upc#<cfelse>#Item#</cfif>	<cfelse><cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>#upc#<cfelse>#Item#</cfif><br><cfif url.idealPriceAnalysis>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif> #Description#</cfif>
						</cfif>
					<!--- End Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  --->
					</td>

				<!--- 114617 :: Ideal Price START --->
				<cfif getProgramInfo.Ideal_Price>
					<td valign="top" class="header" id="prodid_#getAllProductMargins.Product_ID#" IdealPrice=#Ideal_Price# align="right">
						#application.util.string.cellFormat(value=Ideal_Price ,decimalplaces = request.dollar_format)#
					</td>
				</cfif>
				<!--- 114617 :: Ideal Price END --->

					<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
					<cfif variables.bDisplayContractPrice>
						<!------------------------->
						<!--- 001 - Fixed Price --->
						<!------------------------->
						<td class="verticalBorders padRight 2603" align="right" nowrap valign="top">
							<cfsilent>
								<!---
								form.margin_type
								variables.Program_ID
								variables.getAllProductMargins.Product_ID
								--->
								<cfif form.margin_type eq 2><!---   REMOVE ---->
									<cfquery name="qGetStatValue" datasource="#application.datasource#">
										SELECT ISNULL(CAST(CASE_EQUIVALENT as float),0) as CASE_EQUIVALENT
										FROM BSA_Foodservice_Items_Master
										where BSA_Foodservice_Items_Master_ID = '#variables.getAllProductMargins.Product_ID#'
									</cfquery>
									<cfset statMultiplier = qGetStatValue.CASE_EQUIVALENT>
									<cfif NOT statMultiplier>
										<cfset multiplier = "*">
									<cfelse>
										<cfset multiplier = "/">
									</cfif>
								<cfelseif form.margin_type eq 3>
									<cfquery name="qGetNetValue" datasource="#application.datasource#">
										SELECT ISNULL(CAST(NET_WEIGHT as float),0) as NET_WEIGHT
										FROM BSA_Foodservice_Items_Master
										where BSA_Foodservice_Items_Master_ID = '#variables.getAllProductMargins.Product_ID#'
									</cfquery>
									<cfif NOT qGetNetValue.NET_WEIGHT>
										<cfset Net = 1>
									<cfelse>
										<cfset Net = qGetNetValue.NET_WEIGHT[1]>
									</cfif>
									<cfset statMultiplier = Net>
									<cfset multiplier = "/">
								<cfelseif form.margin_type eq 4>
									<cfquery name="qGetVolume" datasource="#application.datasource#">
										SELECT ISNULL(Product_Program_Volume_CS,0) as Volume_Equivalent
										FROM contract_product_margin
										where product_id       = '#variables.getAllProductMargins.Product_ID#'
										and   deleted          = 0
										and   contract_main_id = '#contract_main_id#'
									</cfquery>
									<cfset statMultiplier = qGetVolume.Volume_Equivalent>
									<cfset multiplier = "*">
								<cfelse>
									<cfset statMultiplier = 1>
									<cfset multiplier     = "*">
								</cfif>
								<cfquery name="qGetContractPrice" datasource="#application.datasource#">
									SELECT ISNULL(FPR_CS,0) as Fixed_Price_CS, FPR_CS , FPR_LB, FPR_STAT
									FROM        dbo.Contract_Product_Margin
									INNER JOIN BSA_Foodservice_Items_Master
									ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Product_Margin.Product_Id
									--AND BSA_Foodservice_Items_Master.deleted = 0
									LEFT JOIN Type_Group_Desc
									ON  Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID
									AND Type_Group_Desc.deleted            = 0
									LEFT JOIN Group_Approval_Rights
									ON    Group_Approval_Rights.Group_ID        = Type_Group_Desc.Type_Group_Desc_ID
									AND   Group_Approval_Rights.User_Profile_ID = #request.Accessstructure.Profiles_ID#
									AND   Group_Approval_Rights.deleted         = 0
									WHERE Contract_Main_ID                      = #contract_main_id#
									AND   Contract_Product_Margin.product_id    = '#getAllProductMargins.Product_ID#'
								</cfquery>
								<cfif (isDefined("qGetContractPrice.Fixed_Price_CS") and qGetContractPrice.Fixed_Price_CS NEQ "")>
									<cfset fixed_price = "#qGetContractPrice.Fixed_Price_CS##multiplier##statMultiplier#">
									<cfset fixed_price = evaluate(fixed_price)>
								<cfelse>
									<cfset fixed_price = 0>
								</cfif>

								<!--- do we have more than 1 fixed component for this program ? [begin]  ???????????????????????????? OUTSIDE LOOP--->
								<cfquery name="qGetFixedComponentIDs" datasource="#application.datasource#">
									SELECT  Program_Fixed_Component_ID
									FROM  Program_Fixed_Component
									WHERE   Program_ID = #contract_main_id#
									AND   deleted = 0
								</cfquery>
								<!--- do we have more than 1 fixed component for this program ? [end] --->
							</cfsilent>
							<!--- if we are negative... --->
							<cfif url.idealPriceAnalysis>
								<cfset fixedprice = #replace(numberFormat(fixed_price,request.nondollar_format), ',','')#>
								<input type="text" name="#replace(getAllProductMargins.Product_ID,'-','_','ALL')#_Fixed_Price" id="#getAllProductMargins.Product_ID#_Fixed_Price" value="#fixedprice#" size="5" ONKEYUP="clenseText(this,'0123456789.');" ONCHANGE="IdealPriceCalculation('0', '#getAllProductMargins.Product_ID#', '#getAllProductMargins.Type_Code_Desc_ID#')">
								<input type="hidden" name="#replace(getAllProductMargins.Product_ID,'-','_','ALL')#_Fixed_Price_Change" id="#getAllProductMargins.Product_ID#_Fixed_Price_Change" value="0">
							<cfelse>
								#application.util.string.cellFormat(value=fixed_price ,decimalplaces = request.dollar_format)#
								<cfif qGetFixedComponentIDs.recordCount GT 1> <span class="redLarge">*</span></cfif>
							</cfif>
						</td>
						<!--- 16314 [end] --->
					</cfif>
					<!--- 17289 > 16314 follow up 10/14/08 [end] --->
          <!--- 114617 :: Ideal Price START --->
					<cfif getProgramInfo.Ideal_Price>
						<cfset fixed_price = application.util.string.cellFormat(value=fixed_price, decimalplaces = request.nondollar_format)>
							<cfif fixed_price GT Ideal_Price>
								<cfset IPRateDiff = '0'>
								<cfset IPRateDiffPer = '0'>
							<cfelse>
								<cfset 	IPRateDiff = fixed_price - Ideal_Price>
								<cfif Ideal_Price>
									<cfset 	IPRateDiffPer = (100 * IPRateDiff)/Ideal_Price >
								<cfelse>
									<cfset 	IPRateDiffPer = 0 >
								</cfif>
							</cfif>
						<td valign="top" class="header" align="right" id="#getAllProductMargins.Product_ID#_IPDifference" >
								#application.util.string.cellFormat(value=IPRateDiff ,decimalplaces = request.dollar_format)#<br>
								#application.util.string.cellFormat(value=IPRateDiffPer, decimalplaces = request.nondollar_format)#<cfif IPRateDiffPer LT 0><span class="neg">%</span><cfelse>%</cfif>
						</td>
							<cfif fixed_price GT Ideal_Price>
								<cfset DiffDollar = '0'>
							<cfelse>
								<cfset DiffDollar = (fixed_price - Ideal_Price) * Product_Program_Volume>
								<cfset TotalDiffDollar = TotalDiffDollar + DiffDollar>
							</cfif>
						<td valign="top" class="header" align="right" id="#getAllProductMargins.Product_ID#_IPDiffDoll" DiffDollar="#DiffDollar#">
							#application.util.string.cellFormat(value=DiffDollar, category = "dollar2")#
							<!---#application.util.string.cellFormat(value=DiffDollar ,decimalplaces = request.dollar_format)#--->
						</td>
					</cfif>
					<!--- 114617 :: Ideal Price END --->
					<!--------------------->
					<!--- 002 - Vol. CS --->
					<!--------------------->
					<td valign="top" align="right" nowrap class="2694" id="#Product_Id#_Volume" volume=#Product_Program_Volume#> #trim(numberformat(round(Product_Program_Volume),'_-___,___,___,___,___'))# </td>

					<!------------------------>
					<!--- 003 - Base Sales --->
					<!------------------------>
					<td valign="top" align="right" nowrap class="2699">
						<a style="cursor:pointer;" onclick="showBaseSalesDetails('#replace(Product_Id, "-", "_", "ALL")#')">
							#application.util.string.cellFormat(value=Base_Sales ,decimalplaces = request.dollar_format)#
						</a>
					</td>

					<!--------------------->
					<!--- ALlow/Surch --->
					<!--------------------->
					<td valign="top" align="right" nowrap class="2708">
						#application.util.string.cellFormat(value=Allowance_Surcharges ,decimalplaces = request.dollar_format)#
					</td>

					<!--------------------->
					<!--- Customer Freight --->
					<!--------------------->
					<td valign="top" align="right" nowrap class="2715">
						#application.util.string.cellFormat(value=Customer_Freight ,decimalplaces = request.dollar_format)#
					</td>

					<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
					<!--- Display Cash Discount only if the app setting is on. This setting is off when margin = trade percent of gross sales. --->
					<!--------------------->
					<!--- 004 Cash Disc --->
					<!--------------------->
					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
						<cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
							<td valign="top" align="right" nowrap class="2726">
								<cfif appsettings.getlocalcostvariables() eq 2>
									<A style="cursor:pointer;" onclick="showCashDiscountDetails('#replace(Product_Id, "-", "_", "ALL")#')">
								</cfif>
								#application.util.string.cellFormat(value=Cash_discount ,decimalplaces = request.dollar_format)#
								<cfif appsettings.getlocalcostvariables() eq 2>
									</a>
								</cfif>
							</td>
						</cfif>

						<cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
							<td valign="top" align="right" nowrap class="2738"> <A style="cursor:pointer;" onclick="showLocalCostCalculation('#replace(Product_Id, "-", "_", "ALL")#','L','')"> #application.util.string.cellFormat(value=Cash_discount ,decimalplaces = request.dollar_format)# </A> </td>
						</cfif>
					</cfif>

					<!------------------------------>
					<!--- 005 - Allowance column --->
					<!------------------------------>
					<cfif direct_pricing eq 0>
						<td valign="top" align="right" nowrap class="2746" id="#Product_Id#_Allowance" typecode=#Type_Code_Desc_ID# RER= #RER# GRR= #GRR# OER= #OER#
						DiffFormulaPrice= #Diff_Formula_Price# BaseSales=#Base_Sales# NetSales=#Net_Sales# ItemAllowance=#Item_Allowance# LumpsumAmount=#Lumpsum_Amount#
						AnnualizedAllowance=#AnnualizedAllowance# ItemAllowance=#ItemAllowance#>
							<!--- D56447 :: EZ Rates Indicator inside a Program START --->
							<cfset EZrateIndicator = 0>
							<cfif getsettings.EZButton_On EQ 1 AND ListFind(ProductsBeyoundMaxRateList, variables.getAllProductMargins.Product_ID)>
								<cfset ezrate = listgetat(ProductsMaxRateList, ListFind(ProductsBeyoundMaxRateList, variables.getAllProductMargins.Product_ID))>
								<cfset EZrateIndicator = 1>
							</cfif>
						<!--- D56447 :: EZ Rates Indicator inside a Program END --->
						<cfif appSettings.getApprovalMarginType() eq 2>
							<cfset Allowance_Display_Value = Item_Allowance_Annualized>
						<cfelse>
							<cfset Allowance_Display_Value = Item_Allowance>
						</cfif>
						<cfif url.idealPriceAnalysis>
							#trim(application.util.string.cellFormat(value=Allowance_Display_Value ,decimalplaces = request.dollar_format))#
						<cfelse>
							<A style="cursor:pointer;" onclick="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','A','')">
								<cfif EZrateIndicator>
									<b title="Item Rate above EZ rate. EZ Rate = $#ezrate#" style="font-size:12px;color:red;font-weight:bold;cursor:pointer;" align="absmiddle">( ! )</b>
								</cfif> #trim(application.util.string.cellFormat(value=Allowance_Display_Value ,decimalplaces = request.dollar_format))#
							</A>
						</cfif>
						</td>
						<!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
						<!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Allowance_Display_Value".
						I could have used IsDefined("Allowance_Display_Value") to show or hide this column, but it was simpler to just rely on the logic for "Allowance_Display_Value",
						as the below calculated value relies on ""Allowance_Display_Value".
						--->
						<!--------------------->
						<!--- 006 - allow % --->
						<!--------------------->
						<td valign="top" align="right" nowrap class="2771" id="#Product_Id#_Allowance_Percentage">
							<cfif Allowance_Display_Value eq 0 OR Base_Sales eq 0>
								N/A
								<cfset Allowance_Percent = 0>
							<cfelseif Allowance_Display_Value LT 0>
								0%
								<cfset Allowance_Percent = 0>
							<cfelse>
								<cfset Allowance_Percent = (Allowance_Display_Value/Base_Sales) * 100>
								#application.util.string.cellFormat(value=Allowance_Percent ,decimalplaces = request.numeric_format)#%
							</cfif>
						</td>
					</cfif>

					<!----------------->
					<!--- TPA Operator --->
					<!----------------->
					<cfif ShowTPA eq 1>
						<td valign="top" align="right" nowrap class="2787">
							<A style="cursor:pointer;" onclick="showTradeCalculation('#replace(Product_Id, "-", "_", "ALL")#',1)">
								#application.util.string.cellFormat(value=TPA_Oper ,decimalplaces = request.dollar_format)#
							</A>
						</td>
					<!----------------->
					<!--- TPA Distributor (Distributor Trade) --->
					<!----------------->
						<td valign="top" align="right" nowrap class="2796">
							<A style="cursor:pointer;" onclick="showTradeCalculation('#replace(Product_Id, "-", "_", "ALL")#',0)">
								#application.util.string.cellFormat(value=TPA ,decimalplaces = request.dollar_format)#
							</A>
						</td>
					</cfif>

					<!----------------------------->
					<!--- 008 - pullback amount --->
					<!----------------------------->
					<cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
						<td valign="top" align="right" nowrap class="2808">
							<A style="cursor:pointer;" onclick="showPullbackCalculation('#replace(Product_Id, "-", "_", "ALL")#')">
								#application.util.string.cellFormat(value=Pullbackamount ,decimalplaces = request.dollar_format)#
							</A>
						</td>
					</cfif>

					<!----------------------->
					<!--- Other Spend --->
					<!----------------------->
						<td valign="top" align="right" nowrap class="2819">
								#application.util.string.cellFormat(value=Other_Spend ,decimalplaces = request.dollar_format)#
						</td>

					<!----------------------->
					<!--- 009 - net sales --->
					<!----------------------->
					<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
					<cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
						<td valign="top" align="right" nowrap class="sum82 2829" id="#Product_Id#_Net_Sales" BaseSales=#Base_Sales# BaseDiscount=#Base_Discount# TPAOper=#TPA_Oper# TPA=#TPA# PullbackAmount=#PullbackAmount# AllowanceSurcharges=#Allowance_Surcharges# CustomerFreight=#Customer_Freight#  OtherSpend=#Other_Spend#>
							<cfif url.idealPriceAnalysis>
								#application.util.string.cellFormat(value=Net_Sales ,decimalplaces = request.dollar_format)#
							<cfelse>
								<A style="cursor:pointer;" onclick="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','N','')">
									#application.util.string.cellFormat(value=Net_Sales ,decimalplaces = request.dollar_format)#
								</A>
							</cfif>
						</td>
					</cfif>
			</cfif>		<!--- <cfif Get_Profile_Settings.Base_View eq 1> --->


			<!--- Dev Note: KAL; D21003: Margin Approval - Trade as Percent of Gross Sales, $0 price  --->
			<cfif Base_Sales eq 0 and Get_Profile_Settings.Approve_Zero_Product_Price eq 0>
				<cfset CannotApproveItemMargin = 1>
				<cfset CannotApproveGroupMargin = 1>
				<cfset temp = ArrayAppend(messageArray, "You cannot approve #Description# #Item# which has zero price.")>
			</cfif>

			<cfif Cost eq 0 and Get_Profile_Settings.Approve_Zero_Product_Cost eq 0>
				<cfset CannotApproveItemMargin = 1>
				<cfset CannotApproveGroupMargin = 1>
				<cfset temp = ArrayAppend(messageArray, "You cannot approve #Description# #Item# which has zero cost.")>
			</cfif>

			<!------------------>
			<!--- 010 - cost --->
			<!------------------>
			<cfif Get_Profile_Settings.View_Cost eq 1>
				<td valign="top" align="right" nowrap class="2856">
					<A style="cursor:pointer;" onclick="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','C','')">#application.util.string.cellFormat(value=Cost ,decimalplaces = request.dollar_format)#</A>
				</td>
			</cfif>

			<!----------------------->
			<!--- 011 - Brokerage --->
			<!----------------------->
			<cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
				<td valign="top" align="right" nowrap class="2865">
					<A style="cursor:pointer;" onclick="showBrokerage('#replace(Product_Id, "-", "_", "ALL")#')">#application.util.string.cellFormat(value=Broker_Cost ,decimalplaces = request.dollar_format)#</A>
				</td>
			</cfif>

			<!--- Shuttle Freight --->
			<td valign="top" align="right" nowrap class="2871">
				#application.util.string.cellFormat(value=Shuttle_Freight ,decimalplaces = request.dollar_format)#
			</td>

			<!--- Warehouse --->
			<td valign="top" align="right" nowrap class="2877">
				#application.util.string.cellFormat(value=Custom_Warehouse ,decimalplaces = request.dollar_format)#
			</td>

			<!--- Gross Margin --->
			<td valign="top" align="right" nowrap class="2883" id="#Product_Id#_Gross_Margin" COST=#cost# ShuttleFreight=#Shuttle_Freight#  CustomWarehouse=#Custom_Warehouse#>
				#application.util.string.cellFormat(value=Gross_Margin ,decimalplaces = request.dollar_format)#
			</td>

			<!--- Brokerage --->
			<td valign="top" align="right" nowrap class="2889">
				#application.util.string.cellFormat(value=Custom_Brokerage ,decimalplaces = request.dollar_format)#
			</td>

			<!--- Contribution Margin --->
			<td valign="top" align="right" nowrap class="2895" id="#Product_Id#_Contribution_Margin" CustomBrokerage=#Custom_Brokerage#>
					#application.util.string.cellFormat(value=Contribution_Margin_Alt ,decimalplaces = request.dollar_format)#
			</td>

			<!--- Variable Contribution Margin --->
			<td valign="top" align="right" nowrap class="2901" id="#Product_Id#_Variable_Contribution_Margin" FixedCost=#Fixed_Cost#>
					#application.util.string.cellFormat(value=Variable_Contribution_Margin ,decimalplaces = request.dollar_format)#
			</td>

			<!--- MAP and MDF --->
			<td valign="top" align="right" nowrap class="2907">
					#application.util.string.cellFormat(value=Map_Mdf ,decimalplaces = request.dollar_format)#
			</td>

			<!--- SG & A --->
			<td valign="top" align="right" nowrap class="2913">
					#application.util.string.cellFormat(value=SGA ,decimalplaces = request.dollar_format)#
			</td>

			<!------------------------------>
			<!--- 012 - operating income --->
			<!------------------------------>
			<cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
				<td valign="top" align="right" nowrap class="2922" id="#Product_Id#_Operating_Income" MapMdf=#Map_Mdf# SGA=#SGA#>
					#application.util.string.cellFormat(value=Operating_Income ,decimalplaces = request.dollar_format)#

						<!---Tim Ford - Label 19381: Show if the Program is a revision and Operating Income is different from Revised program--->
						<cfif Program_Is_A_Revision and isDefined("getProductPreviousVersionMargins")>
							<cfset useLakebaseForqGetPreviousOperatingIncome = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getproductpreviousversionmargins")>
<cfif useLakebaseForqGetPreviousOperatingIncome>
	<cftry>
		<cfset qGetPreviousOperatingIncome = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getproductpreviousversionmargins", {
				"product_id" = "eq.#Product_ID#",
				"select" = "operating_income,operatingmargin_percent"
			}), "operating_income,operatingmargin_percent"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPreviousOperatingIncome = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPreviousOperatingIncome>
<cfquery name="qGetPreviousOperatingIncome" dbtype="query">
								SELECT  Operating_Income, OperatingMargin_percent
								FROM  getProductPreviousVersionMargins
								WHERE Product_ID = '#Product_ID#'
							</cfquery>
</cfif>
							<cfif qGetPreviousOperatingIncome.RecordCount>
								<cfif DecimalFormat(qGetPreviousOperatingIncome.Operating_Income) neq DecimalFormat(Operating_Income)>
									<i class="tooltip" title="Previous Version #trim(replace(replace(appsettings.getMarginColHeader11(),'%',''),'$',''))#: &nbsp; #UnitNumberFormat(qGetPreviousOperatingIncome.Operating_Income,form.Margin_Type)# &nbsp; #round(qGetPreviousOperatingIncome.OperatingMargin_percent)#%">&bigstar;</i>
								</cfif>
							</cfif>
						</cfif>
				</td>
			</cfif>

			<!--- check if the user profile has rights to view margins --->
			<!--- add item variation to the item --->
			<cfset margin = trim(numberformat(TargetMargin,'_-___,___,___,___,___._'))>
			<cfset variationmargin  = Get_Profile_Settings.Margin_Target_Variation>
			<cfif trim(variationmargin) NEQ "*">
				<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 1>
					<cfset approvalmargin  = margin + ((margin * variationmargin)/100)>
				<cfelse>
					<cfset approvalmargin  = margin - ((margin * variationmargin)/100)>
				</cfif>
			<cfelse>
				<cfset approvalmargin  = "*">
			</cfif>

			<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<!--- If (margin = trade %) and App Setting (Margin Target on = OFF) ignore item level targets. --->
				<cfif appSettings.getuploadmargintargets_on()>
					<cfif Trade_Percent GT approvalmargin AND approvalmargin NEQ "*">
						<cfset CannotApproveItemMargin = 1>
						<cfset CannotApproveGroupMargin = 1>
						<cfif getGroupvalues.Group_ID_Approval eq 1>
							<cfset itemmarginfailure = 1>
						</cfif>
						<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Description# #Item#.")>
					</cfif>
				</cfif>
			<cfelseif appSettings.getApprovalMarginType() eq 0>
				<cfif OperatingMargin_percent LT approvalmargin AND approvalmargin NEQ "*">
					<cfset CannotApproveItemMargin = 1>
					<cfset CannotApproveGroupMargin = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
					</cfif>
					<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Description# #Item#.")>
				</cfif>
			<cfelseif appSettings.getApprovalMarginType() eq 2 AND Get_Profile_Settings.Approve_Beyond_Annual_Case_Rate eq 0>
				<cfif groupTargetCaseRateUOM eq 1 AND Trade_CS GT groupTargetCaseRate>
					<cfset CannotApproveItemMargin = 1>
					<cfset CannotApproveGroupMargin = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
					</cfif>
					<cfset temp = ArrayAppend(messageArray, "Annual case rate is not within the target for #Description# #Item#.")>
				<cfelseif groupTargetCaseRateUOM eq 2 AND Trade_LB GT groupTargetLBRate>
					<cfset CannotApproveItemMargin = 1>
					<cfset CannotApproveGroupMargin = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
					</cfif>
					<cfset temp = ArrayAppend(messageArray, "Annual pound rate is not within the target for #Description# #Item#.")>
				</cfif>
			<!--- 70104 Absolute Net Sales $ per Lb or Equiv Case --->
			<cfelseif appSettings.getApprovalMarginType() eq 3>
				<cfif Global_Net_Sales GT approvalmargin AND approvalmargin NEQ "*">
					<cfset CannotApproveItemMargin = 1>
					<cfset CannotApproveGroupMargin = 1>
					<cfif getGroupvalues.Group_ID_Approval eq 1>
						<cfset itemmarginfailure = 1>
					</cfif>
					<cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Description# #Item#.")>
				</cfif>
			</cfif>

			<!------------------------------>
			<!--- 013 - operating margin --->
			<!------------------------------>
			<cfif Get_Profile_Settings.View_Target_Margins eq 1>
				<cfif appSettings.getApprovalMarginType() eq 2><!--- Annual Case Rate --->
					<!------------------------------->
					<!--- 013a - Annual Case Rate --->
					<!------------------------------->
					<td valign="top" align="right" nowrap class="3016">
						#application.util.string.cellFormat(value=Trade ,decimalplaces = request.dollar_format)#/<cfif groupTargetCaseRateUOM eq 1>CS<cfelseif groupTargetCaseRateUOM eq 2>LB</cfif>
					</td>
					<!------------>
					<!--- 013z --->
					<td valign="top" class="3023">&nbsp;</td>

					<!------------------------------->
					<!--- 013b - Target Case Rate --->
					<!------------------------------->
					<td valign="top" align="right" nowrap class="3027">
						<cfif groupTargetCaseRateUOM eq 2>
							<cfset data = groupTargetLBRate>
						<cfelse>
							<cfset data = groupTargetCaseRate>
						</cfif>
						#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#/<cfif groupTargetCaseRateUOM eq 1>CS<cfelseif groupTargetCaseRateUOM eq 2>LB</cfif>
					</td>
				<cfelse>
				<!--------------------------------------->
				<!--- 013m - Operating Margin Percent --->
				<!--------------------------------------->
				<cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
					<td valign="top" align="right" nowrap class="3041" id="#Product_Id#_Operating_Margin_percent">
						#(OperatingMargin_percent lt 0
							? NegativeFormat( numberFormat( OperatingMargin_percent * -1, request.numeric_format ) )
							: numberformat( OperatingMargin_percent, request.numeric_format ))#%
					</td>
				</cfif>
					<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START --->
					<cfif Cont_Margin_Calculation EQ '1'>
						<td valign="top" align="right" nowrap class="3050">
							<cfif Cont_Margin_Calculation EQ '1'>
								<cfset ContribMarginAmount = #Operating_Income# - #Fixed_Mfg_Cost#>
							<cfelse>
								<cfset ContribMarginAmount = #Operating_Income# + #Fixed_Mfg_Cost#>
							</cfif>

							#application.util.string.cellFormat(value=ContribMarginAmount ,decimalplaces = request.dollar_format)#
						</td>
						<td valign="top" align="right" nowrap class="3059">
							<!--- Dev Note(63711): Since "Net_Sales" is a column name, it should be used as "variables.Net_Sales", if we need to override it by using
							a variable. Using <cfset Net_Sales = 1> will not override the "Net_Sales" variable.
							--->

							<cfif len(Net_Sales) EQ 0 OR Net_Sales EQ 0>
								<cfset variables.Net_Sales = 1>
							<cfelse>
								<cfset variables.Net_Sales = Net_Sales>
							</cfif>
								<cfset ContribMarginPer = (ContribMarginAmount / variables.Net_Sales) * 100>

								#application.util.string.cellFormat(value=ContribMarginPer ,decimalplaces = request.numeric_format)# %
						</td>
					</cfif>


					<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END --->
					<td valign="top" BGCOLOR="#itemtrbgcolor#" class="csvExclude 3077">
						<cfif CannotApproveItemMargin eq 1>
							<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle">
						<cfelse>
							#img_1010#
						</cfif>
					</td>


					<!----------------------->
					<!--- 013n - margin % --->
					<!----------------------->
				<cfif margin_display_style NEQ "custom_t">
					<td valign="top" align="right" nowrap class="3090">
						<cfif marginTagetEnabled and appSettings.getuploadmargintargets_on()>
							<A style="cursor:pointer;" onclick="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','T','P')">

								<cfif approvalmargin eq "*">
									#application.util.string.cellFormat(value=margin ,decimalplaces = request.dollar_format)#
								<cfelse>
									#application.util.string.cellFormat(value=approvalmargin ,decimalplaces = request.dollar_format)#
								</cfif>

							</A>
						</cfif>
					</td>
				</cfif>
				</cfif>

				<cfif CannotApproveItemMargin eq 1>
					<cfset form.AgreeList = ListAppend(form.AgreeList, BSA_Foodservice_Items_Master_Id) >
				<cfelse>
					<cfset form.ApproveList = ListAppend(form.ApproveList, BSA_Foodservice_Items_Master_Id)>
				</cfif>
			</cfif>
			<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
			<!---------------------->
			<!--- 014 - Trade CS --->
			<!---------------------->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<td valign="top" align="right" nowrap class="3117">
					#application.util.string.cellFormat(value=Trade ,decimalplaces = request.dollar_format)#
				</td>
			</cfif>

			<!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
			<!---------------------->
			<!--- 015 - trade %  --->
			<!---------------------->
			<cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>
				<td valign="top" align="right" nowrap class="3127">
					#application.util.string.cellFormat(value=Trade_Percent ,decimalplaces = request.numeric_format)# #UOMdisplay#
				</td>
			</cfif>

			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
			<!------------------------->
			<!--- 016 - Trade Spent --->
			<!------------------------->
			<cfif Get_Profile_Settings.Base_View eq 1>
				<td valign="top" align="right" nowrap class="3137" id="#Product_Id#_Trade_Spent" typecode=#Type_Code_Desc_ID#>
					<cfset tradespend = Item_Allowance * round(Product_Program_Volume)>
					#application.util.string.cellFormat(value=tradespend ,decimalplaces = request.dollar_format)#
				</td>
			</cfif>

			<cfif url.idealPriceAnalysis>
				<input type="hidden" name="#Product_Id#_Trade_Spent_TB" id="#Product_Id#_Trade_Spent_TB" value="#tradespend#">
				<input type="hidden" name="#Product_Id#_Operating_Margin_percent_TB" id="#Product_Id#_Operating_Margin_percent_TB" value="#OperatingMargin_percent#">
				<input type="hidden" name="#Product_Id#_Operating_Income_TB" id="#Product_Id#_Operating_Income_TB" value="#Operating_Income#">
				<input type="hidden" name="#Product_Id#_Variable_Contribution_Margin_TB" id="#Product_Id#_Variable_Contribution_Margin_TB" value="#Variable_Contribution_Margin#">
				<input type="hidden" name="#Product_Id#_Contribution_Margin_TB" id="#Product_Id#_Contribution_Margin_TB" value="#Contribution_Margin_Alt#">
				<input type="hidden" name="#Product_Id#_Gross_Margin_TB" id="#Product_Id#_Gross_Margin_TB" value="#Gross_Margin#">
				<input type="hidden" name="#Product_Id#_Net_Sales_TB" id="#Product_Id#_Net_Sales_TB" value="#Net_Sales#">
				<input type="hidden" name="#Product_Id#_Allowance_Percentage_TB" id="#Product_Id#_Allowance_Percentage_TB" value="#Allowance_Percent#">
				<input type="hidden" name="#Product_Id#_Allowance_TB" id="#Product_Id#_Allowance_TB" value="#Allowance_Display_Value#">
			</cfif>

			<!--- check if the program is RFA only then display the check boxes --->
			<cfif getProgramInfo.Contract_Status_Type_IDX neq 2>
				<!--- <td class="csvExclude 3227">#img_1010#</td>
				<td class="csvExclude 3228">#img_1010#</td> --->
			<cfelse>
				<!--- get all the previous approved items  --->
				<cfset useLakebaseForgetitemapprovedvalues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gettypecodeapprovalinfo")>
<cfif useLakebaseForgetitemapprovedvalues>
	<cftry>
		<cfset getitemapprovedvalues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gettypecodeapprovalinfo", {
				"product_id" = "eq.#BSA_Foodservice_Items_Master_Id#",
				"system_agreement" = "eq.0",
				"approve" = "eq.1",
				"order" = "system_agreement.asc",
				"select" = "approve as item_approve,name_last,name_first"
			}), "approve as item_approve,name_last,name_first"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetitemapprovedvalues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetitemapprovedvalues>
<cfquery name="getitemapprovedvalues" dbtype="query">
					select approve as item_approve,Name_Last,Name_First
					from getTypeCodeApprovalInfo
					where product_id = '#BSA_Foodservice_Items_Master_Id#'
					and System_Agreement = 0
					and approve = 1
					order by System_Agreement
				</cfquery>
</cfif>
				<cfquery name="getitemagreedcount" dbtype="query">
					select count(Product_ID) as agreecount
					from getTypeCodeApprovalInfo
					where product_id = '#BSA_Foodservice_Items_Master_Id#'
					and agree = 1
				</cfquery>

				<!--- if the approve settings like growth and upfront funds are not allowed to be approved and if the item margin is not within limits --->
				<!--- display the label either approve or label after checking all the above conditions --->
				<cfif (CannotApproveSettings eq 0 and CannotApproveItemMargin eq 0 and CannotApproveProgramMargin eq 0) OR (getitemapprovedvalues.recordcount GT 0 and getitemapprovedvalues.item_approve eq 1)>
					<cfset feildname = "ProductApprove_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#">
					<cfset itemlabel = "Approve">
					<cfif getitemagreedcount.agreecount GT 0>
						<cfset imagesrc = "Gaya_i18.gif">
						<cfset title = "Click here to view the list of users who agreed">
					<cfelse>
						<cfset imagesrc = "Gaya_i12.gif">
						<cfset title = "">
					</cfif>
					<cfif getitemapprovedvalues.item_approve eq 1>
						<cfset itemlabel = "Approved">
						<cfset checkitemvalue = "checked disabled">
						<cfset imagesrc = "Gaya_i11.gif">
						<cfset title = "">
						<cfset approveditemuser = #getitemapprovedvalues.Name_First# & ' ' & #getitemapprovedvalues.Name_Last#>
					</cfif>
				<cfelseif (getitemapprovedvalues.item_approve eq 0 OR getitemapprovedvalues.recordcount eq 0) and (CannotApproveSettings eq 1 OR CannotApproveItemMargin eq 1 OR CannotApproveProgramMargin eq 1)>
					<cfset cannotapprove = 1>
					<cfset feildname = "ProductAgree_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#">
						<cfquery name="getitemvalues" dbtype="query">
							select agree as item_agree
							from getTypeCodeApprovalInfo
							where product_id = '#BSA_Foodservice_Items_Master_Id#'
							and user_id = '#request.AccessStructure.User_ID#'
						</cfquery>
					<cfset itemlabel = "Agree">
					<cfset imagesrc = "Gaya_i12.gif">
					<cfif getitemvalues.item_agree eq 1 and getitemvalues.recordcount GT 0>
						<cfset itemlabel = "Agreed">
						<cfset checkitemvalue = "checked disabled">
						<cfset title = "Click here to view the list of users who agreed">
						<cfset imagesrc = "Gaya_i18.gif">
					</cfif>
					<cfset button_label = "Agree">
					<cfset showagreepopup = 1>
				</cfif>

				<td BGCOLOR="#itemtrbgcolor#" valign="middle" class="csvExclude 3202">
					<span id="checkAllProducts"><input type="checkbox" original_name="#feildname#" idToken="#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" name="#feildname#" value="1" #checkitemvalue# #disablecheckbox# <cfif disablecheckbox eq "">checked</cfif>></span>
				</td>
				<!--- mass approve --->
				<cfif not itemCheckBoxDisabled>
					<cfset stMassApproval["#feildname#"] = 1>
				</cfif>

				<td BGCOLOR="#itemtrbgcolor#" class="Title6 csvExclude 3210" valign="middle">
					<span class="title5" id="approve_agree_label_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" original_approve_agree_label="#itemlabel#">#itemlabel#</span>
				</td>
				<td BGCOLOR="#itemtrbgcolor#" class="csvExclude 3213">
					<IMG SRC="/images/Layered_Approval/#imagesrc#"
						<cfif imagesrc eq 'Gaya_i11.gif'>
							<cfif trim(approveditemuser) neq "">
								onmouseover="initTheTooltip('Approved by #approveditemuser#')" onmouseout="popOut()"
							</cfif>
						<cfelseif imagesrc eq 'Gaya_i18.gif'>
							onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
							onclick="showCalculation('#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#','AG','P')"
						</cfif>
						style="cursor:pointer;">
				</td>
				<td class="csvExclude 3225">&nbsp;</td>
			</cfif>
			</tr>

			<cfset count                   = count + 1>

			<cfset checkitemvalue          = "">
			<cfset itemlabel               = "">
			<cfset CannotApproveItemMargin = 0>

			</cfoutput>
			<input type="hidden" name="#Type_Code_Desc_ID#" value="#itemCount#">
			<cfset itemCount = 0>
			<!------------------------------------------------------------------------------------------------------------------->
			<!--- End: Outputs the individual items  ---------------------------------------------------------------------------->
			<!------------------------------------------------------------------------------------------------------------------->

			<!------------------------------------------------------------------------------------------------------------------->
			<!--- Type Code Groups - START -------------------------------------------------------------------------------------->
			<!------------------------------------------------------------------------------------------------------------------->
			<tr bgcolor="#grouptrbgcolor#" id="#Type_Code_Desc_ID#_ProdID">
				<cfloop query="getGroupvalues">
					<cfif Get_Profile_Settings.Base_View eq 1>
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="forceLeft 3248" valign="middle">
							<cfif url.idealPriceAnalysis>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif>#Type_Code_Desc#
						</td>
						<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
						<!------------------------->
						<!--- 114617 :: Ideal Price START --->
						<cfif getProgramInfo.Ideal_Price>
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3255">&nbsp;</td>
						</cfif>
						<!--- 114617 :: Ideal Price END --->
						<!--- 001 - Fixed Price --->
						<!------------------------->
						<cfif variables.bDisplayContractPrice>
						<!--- 16314 [begin] --->
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3255">&nbsp;</td>
							<!--- 16314 [end] --->
						</cfif>
						<!--- 17289 > 16314 follow up 10/14/08 [end] --->
						<!--- 114617 :: Ideal Price START --->
						<cfif getProgramInfo.Ideal_Price>
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3255">&nbsp;</td>
							<td style="border-top: 1px solid 0000FF;text-align:right;" BGCOLOR="#grouptrbgcolor#" class="3255" id="#Type_Code_Desc_ID#_TypeCode_Dollars">
								#application.util.string.cellFormat(value=TotalDiffDollar ,category = "dollar2")#
							</td>
							<cfset TotalPrgDiffDollar = TotalPrgDiffDollar + TotalDiffDollar>
							<cfset TotalDiffDollar = 0>
						</cfif>
						<!--- 114617 :: Ideal Price END --->
						<!------------------------->
						<!--- 002 - Vol. CS ------->
						<!------------------------->
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3262">
							#trim(numberformat(round(Total_Product_Program_Volume), request.numeric_format))#
						</td>
						<!------------------------->
						<!--- 003 - Base Sales ---->
						<!------------------------->
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3268">
							#application.util.string.cellFormat(value=Total_Base_Sales ,decimalplaces = request.dollar_format)#
						</td>
						<!------------------------->
						<!--- ALlow/Surch ---->
						<!------------------------->
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3274">
							#application.util.string.cellFormat(value=Total_Allowance_Surcharges ,decimalplaces = request.dollar_format)#
						</td>
						<!------------------------->
						<!--- Customer Freight ---->
						<!------------------------->
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3280">
							#application.util.string.cellFormat(value=Total_Customer_Freight ,decimalplaces = request.dollar_format)#
						</td>
						<cfif direct_pricing eq 0>
							<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
							<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
							<!--------------------->
							<!--- 004 Cash Disc --->
							<!--------------------->
							<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
								<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3290">
										#application.util.string.cellFormat(value=Total_Cash_discount ,decimalplaces = request.dollar_format)#
								</td>
							</cfif>
							<!----------------------->
							<!--- 005 - allowance --->
							<!----------------------->
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3297" id="#Type_Code_Desc_ID#_TypeCode_Allowance">
								<cfif appSettings.getApprovalMarginType() eq 2>
									<cfset Total_Item_Allowance_Display_Value = Total_Item_Allowance_Annualized>
								<cfelse>
									<cfset Total_Item_Allowance_Display_Value = Total_Item_Allowance>
								</cfif>

								#application.util.string.cellFormat(value=Total_Item_Allowance_Display_Value ,decimalplaces = request.dollar_format)#
							</td>

							<!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
							<!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Total_Item_Allowance_Display_Value".
							I could have used IsDefined("Total_Item_Allowance_Display_Value") to show or hide this column, but it was simpler to just rely on the logic for "Total_Item_Allowance_Display_Value",
							as the below calculated value relies on ""Total_Item_Allowance_Display_Value".
							--->
							<!--------------------->
							<!--- 006 - allow % --->
							<!--------------------->
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#"  align="right" nowrap class="3315" id="#Type_Code_Desc_ID#_TypeCode_AllowancePer">
								<cfif Total_Item_Allowance_Display_Value eq 0 OR Total_Base_Sales eq 0>
									N/A
								<cfelseif Total_Item_Allowance_Display_Value LT 0>
									0%
								<cfelse>
									<cfset Total_Allowance_Percent = (Total_Item_Allowance_Display_Value/Total_Base_Sales) * 100>
									#application.util.string.cellFormat(value=Total_Allowance_Percent ,decimalplaces = request.numeric_format)#%
								</cfif>
							</td>
						</cfif>

						<cfif ShowTPA eq 1>
							<!----------------------------->
							<!--- TPA Operator --------------->
							<!----------------------------->
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3331">

								#application.util.string.cellFormat(value=Total_TPA_Oper ,decimalplaces = request.dollar_format)#
							</td>
							<!----------------------------->
							<!--- TPA Distributor (Distributor Trade) --------------->
							<!----------------------------->
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3338">

								#application.util.string.cellFormat(value=Total_TPA ,decimalplaces = request.dollar_format)#
							</td>
						</cfif>

						<!----------------------------->
						<!--- 008 - pullback amount --->
						<!----------------------------->
						<cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3348">

								#application.util.string.cellFormat(value=Total_Pullbackamount ,decimalplaces = request.dollar_format)#
							</td>
						</cfif>

						<!----------------------------->
						<!--- Other Spend --------------->
						<!----------------------------->
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3357">

							#application.util.string.cellFormat(value=Total_Other_Spend ,decimalplaces = request.dollar_format)#
						</td>

						<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
						<!----------------------->
						<!--- 009 - net sales --->
						<!----------------------->
						<cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3367" id="#Type_Code_Desc_ID#_TypeCode_Net_Sales">

								#application.util.string.cellFormat(value=Total_Net_Sales ,decimalplaces = request.dollar_format)#
							</td>
						</cfif>
					</cfif>

					<!------------------>
					<!--- 010 - cost --->
					<!------------------>
					<cfif Get_Profile_Settings.View_Cost eq 1>
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3378">
							#application.util.string.cellFormat(value=Total_Cost ,decimalplaces = request.dollar_format)#
						</td>
					</cfif>

					<!----------------------->
					<!--- 011 - Brokerage --->
					<!----------------------->
					<cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3387">
							#application.util.string.cellFormat(value=Total_Brokerage ,decimalplaces = request.dollar_format)#
						</td>
					</cfif>

					<!----------------------->
					<!--- Shuttle Freight --->
					<!----------------------->
					<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3395">

						#application.util.string.cellFormat(value=Total_shuttle_freight ,decimalplaces = request.dollar_format)#
					</td>

					<!----------------------->
					<!--- Warehouse --->
					<!----------------------->
					<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3403">

						#application.util.string.cellFormat(value=Total_Custom_Warehouse ,decimalplaces = request.dollar_format)#
					</td>

					<!----------------------->
					<!--- Gross Margin --->
					<!----------------------->
					<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3411" id="#Type_Code_Desc_ID#_TypeCode_Gross_Margin">

					#application.util.string.cellFormat(value=Total_Gross_Margin ,decimalplaces = request.dollar_format)#
					</td>

					<!----------------------->
					<!--- Brokerage --->
					<!----------------------->
					<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3419">

					#application.util.string.cellFormat(value=Total_Custom_Brokerage ,decimalplaces = request.dollar_format)#
					</td>

					<!----------------------->
					<!--- Contribution Margin --->
					<!----------------------->
					<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3427" id="#Type_Code_Desc_ID#_TypeCode_Contribution_Margin">

					#application.util.string.cellFormat(value=Total_Contribution_Margin_Alt ,decimalplaces = request.dollar_format)#
					</td>

					<!----------------------->
					<!--- Variable Contribution Margin --->
					<!----------------------->
					<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3435" id="#Type_Code_Desc_ID#_TypeCode_Variable_Contribution_Margin">

					#application.util.string.cellFormat(value=Total_Variable_Contribution_Margin ,decimalplaces = request.dollar_format)#
					</td>

					<!----------------------->
					<!--- MAP and MDF --->
					<!----------------------->
					<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3443">

					#application.util.string.cellFormat(value=Total_Map_Mdf ,decimalplaces = request.dollar_format)#
					</td>

					<!----------------------->
					<!--- SG & A --->
					<!----------------------->
					<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3451">

					#application.util.string.cellFormat(value=Total_SGA ,decimalplaces = request.dollar_format)#
					</td>

					<!------------------------------>
					<!--- 012 - operating income --->
					<!------------------------------>
					<cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3460" id="#Type_Code_Desc_ID#_TypeCode_Opr_Income">

							#application.util.string.cellFormat(value=Total_Operating_Income ,decimalplaces = request.dollar_format)#
						</td>
					</cfif>

					<cfif Get_Profile_Settings.View_Target_Margins eq 1>
						<cfif appSettings.getApprovalMarginType() eq 2><!--- Annual Case Rate --->
							<!------------------------------->
							<!--- 013a - Annual Case Rate --->
							<!------------------------------->
							<td style="border-top: 1px solid 0000FF " BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3471">

								#application.util.string.cellFormat(value=Total_Trade ,decimalplaces = request.dollar_format)#
							</td>
							<!------------>
							<!--- 013z --->
							<td style="border-top: 1px solid 0000FF " BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3477">&nbsp;</td>

							<!------------------------------->
							<!--- 013b - Target Case Rate --->
							<!------------------------------->
							<td style="border-top: 1px solid 0000FF " BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3482">
								<cfif groupTargetCaseRateUOM eq 2>
									<cfset groupTargetRate = groupTargetLBRate>
								<cfelse>
									<cfset groupTargetRate = groupTargetCaseRate>
								</cfif>

								#application.util.string.cellFormat(value=groupTargetRate ,decimalplaces = request.dollar_format)#/<cfif groupTargetCaseRateUOM eq 1>CS<cfelseif groupTargetCaseRateUOM eq 2>LB</cfif>
							</td>
						<cfelse>
							<cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
								<td style="border-top: 1px solid 0000FF " BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3493" id="#Type_Code_Desc_ID#_TypeCode_Opr_Margin_Percentage">
									#(Total_OperatingMargin_percent lt 0
										? NegativeFormat( numberFormat( Total_OperatingMargin_percent * -1, request.numeric_format) )
										: numberformat( Total_OperatingMargin_percent, request.numeric_format ))#%
								</td>
							</cfif>

							<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START --->
							<cfif Cont_Margin_Calculation EQ '1'>
								<td align="right" nowrap class="3502">
									<cfif Cont_Margin_Calculation EQ '1'>
										<cfset Total_ContribMarginAmount = #Total_Operating_Income# - #Total_Fixed_Mfg_Cost#>
									<cfelse>
										<cfset Total_ContribMarginAmount = #Total_Operating_Income# + #Total_Fixed_Mfg_Cost#>
									</cfif>


									#application.util.string.cellFormat(value=Total_ContribMarginAmount ,decimalplaces = request.dollar_format)#
								</td>
								<td align="right" nowrap class="3512">
									<cfif len(Total_Net_Sales) EQ 0 OR Total_Net_Sales EQ 0>
										<cfset variables.Total_Net_Sales = 1>
									<cfelse>
										<cfset variables.Total_Net_Sales = Total_Net_Sales>
									</cfif>

									<cfset Total_ContribMarginPer = (Total_ContribMarginAmount / variables.Total_Net_Sales) * 100>
									#trim(numberformat(round(Total_ContribMarginPer), request.numeric_format))#%
								</td>
							</cfif>
							<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END --->
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3524 csvExclude" >
								<cfif CannotApproveGroupMargin eq 1>
									<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle">
								<cfelse>
									#img_1010#
								</cfif>
							</td>
						<cfif margin_display_style neq "custom_t">
							<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3531">
								<A style="cursor:pointer;" onclick="showCalculation('#replace(Type_code_desc_id, "-", "_", "ALL")#','T','G')">

										<cfif groupapprovalmargin eq "*">
											#numberformat(Target_Margin, request.numeric_format)# %
										<cfelse>
											#application.util.string.cellFormat(value=groupapprovalmargin ,decimalplaces = request.numeric_format)# %
										</cfif>
								</A>
							</td>
						</cfif>
						</cfif>
					</cfif>

					<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
					<cfif appSettings.getApprovalMarginType() eq 1>
						<td align="right" nowrap class="3547">
							#application.util.string.cellFormat(value=Total_Trade ,decimalplaces = request.dollar_format)#
						</td>
					</cfif>
					<!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
					<cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>
						<td align="right" nowrap class="3553">
							#application.util.string.cellFormat(value=Total_Trade_Percent ,decimalplaces = request.numeric_format)# %
						</td>
					</cfif>

					<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
					<!--- Dev Note: KAL; D21859: CAG Instill - trade as a % of sales questions - DISPLAY TRADE SPEND AT THE TYPE CODE ROWS --->
					<cfif Get_Profile_Settings.Base_View eq 1>
						<cfset Total_Trade_Spend = Total_Item_Allowance * round(Total_Product_Program_Volume)>
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="3562" id="#Type_Code_Desc_ID#_TypeCode_Trade_Spend">
							#application.util.string.cellFormat(value=Total_Trade_Spend ,decimalplaces = request.dollar_format)#
						</td>
					</cfif>

					<cfif getProgramInfo.Contract_Status_Type_IDX neq 2>
						<!--- <td class="3647">#img_1010#</td>
						<td class="3648">#img_1010#</td> --->
					<cfelse>
						<cfset useLakebaseForgetgroupapprovedvalues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gettypecodeapprovalinfo")>
<cfif useLakebaseForgetgroupapprovedvalues>
	<cftry>
		<cfset getgroupapprovedvalues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gettypecodeapprovalinfo", {
				"type_code_desc_id" = "eq.#getGroupvalues.Type_Code_Desc_Id#",
				"approve" = "eq.1",
				"select" = "approve as group_approve,name_last,name_first"
			}), "approve as group_approve,name_last,name_first"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetgroupapprovedvalues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetgroupapprovedvalues>
<cfquery name="getgroupapprovedvalues" dbtype="query">
							select approve as group_approve, Name_Last, Name_First
							from getTypeCodeApprovalInfo
							where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
							and approve = 1
						</cfquery>
</cfif>

						<cfquery name="getgroupagreedcount" dbtype="query">
							select count(Type_Code_Desc_Id) as agreecount
							from getTypeCodeApprovalInfo
							where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
							and agree = 1
						</cfquery>

						<cfif (CannotApproveSettings eq 0 and Group_ID_Approval eq 1 and CannotApproveProgramMargin eq 0 and CannotApproveGroupMargin eq 0) OR (getgroupapprovedvalues.recordcount gt 0 and getgroupapprovedvalues.group_approve GT 0)>
							<cfset feildname = "GroupApprove_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#">
							<cfset grouplabel = "Approve">
							<cfset showColumn = 0>
							<cfif getgroupagreedcount.agreecount GT 0>
								<cfset imagesrc = "Gaya_i18.gif">
								<cfset title = "Click here to view the list of users who agreed">
							<cfelse>
								<cfset imagesrc = "Gaya_i12.gif">
								<cfset title = "">
							</cfif>
							<cfif getgroupapprovedvalues.group_approve eq 1>
								<cfset grouplabel = "Approved">
								<cfset checkgroupvalue = "checked disabled">
								<cfset imagesrc = "Gaya_i11.gif">
								<cfset title = "">
								<cfset approvedgroupuser = #getgroupapprovedvalues.Name_First# & ' ' & #getgroupapprovedvalues.Name_Last#>
								<cfset showColumn = 1>
							</cfif>
						<cfelseif (getgroupapprovedvalues.group_approve eq 0 OR getgroupapprovedvalues.recordcount eq 0) and (CannotApproveSettings eq 1 OR Group_ID_Approval eq 0 OR CannotApproveGroupMargin eq 1 or CannotApproveProgramMargin eq 1)>
							<cfset cannotapprove = 1>
							<cfset showColumn = 0>
							<cfset feildname = "GroupAgree_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#">
							<cfquery name="getgroupagreevalues" dbtype="query">
								select agree as group_agree
								from getTypeCodeApprovalInfo
								where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
								and user_id = '#request.AccessStructure.User_ID#'
							</cfquery>
							<cfset grouplabel = "Agree">
							<cfset imagesrc = "Gaya_i12.gif">
							<cfif getgroupagreevalues.recordcount GT 0 and getgroupagreevalues.group_agree eq 1>
								<cfset grouplabel = "Agreed">
								<cfset checkgroupvalue = "checked disabled">
								<cfset title = "Click here to view the list of users who agreed">
								<cfset imagesrc = "Gaya_i18.gif">
								<cfset showColumn = 1>
							</cfif>
						</cfif>

						<cfif isDefined("showColumn") and showColumn eq 0 and grouplabel is not "Approve" and grouplabel is not "Agree">
							<td class="3623">&nbsp;</td>
						</cfif>

						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3626 csvExclude">
							<span id="checkAllProducts"><input type="checkbox" original_name="#feildname#" idToken="#replace(Type_Code_Desc_Id, "-", "_", "ALL")#" name="#feildname#" value="1" #checkgroupvalue# #disablecheckbox# <cfif disablecheckbox eq "">checked</cfif>></span>
						</td>
						<cfif not itemCheckBoxDisabled>
							<cfset stMassApproval["#feildname#"] = 1>
						</cfif>
						<td style="border-top:1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3632 csvExclude"><b><span class="title6" id="approve_agree_label_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#" original_approve_agree_label="#grouplabel#">#grouplabel#</span></b></td>
						<td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3633 csvExclude">
							<IMG SRC="/images/Layered_Approval/#imagesrc#"
								<cfif imagesrc eq 'Gaya_i11.gif'>
									<cfif trim(approvedgroupuser) neq "">
										onmouseover="initTheTooltip('Approved by #approvedgroupuser#')" onmouseout="popOut()"
									</cfif>
								<cfelseif imagesrc eq 'Gaya_i18.gif'>
									onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
									onclick="showCalculation('#replace(Type_Code_Desc_Id, "-", "_", "ALL")#','AG','G')"
								</cfif>
							style="cursor:pointer;">
						</td>
						<td class="3645 csvExclude">&nbsp;</td>
					</cfif>

					<cfset checkgroupvalue = "">
					<cfset grouplabel = "">
				</cfloop>
				<!------------------------------------------------------------------------------------------------------------------->
				<!--- Type Code Groups - END ---------------------------------------------------------------------------------------->
				<!------------------------------------------------------------------------------------------------------------------->
			</tr>

			<tr>
				<td style="border-bottom: 0px solid blue;" class="3660" colspan="#th_count#">&nbsp;<br>&nbsp;</td>
			</tr>

			<cfset CannotApproveGroupMargin = 0>
			<cfset disablecheckbox          = "">
			<cfset grouptrbgcolor           = "##CCFFCC">
			<cfset itemtrbgcolor            = "##f4f4f4">
			<cfif massapproval eq 0>
				<cfset LastPercent = 0>

				<!--- This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%) --->
				<cfset PercentDone = Int(Ceiling((OuterLoopcount/ProductMarginCount) * 100)/10)>

				<!--- Show the Image based on product count --->

				<cfif LastPercent neq PercentDone>
					<cfset Block = "Block" & PercentDone>
					<script>
						if(document.#Block#){
						<cfloop from="1" to="#PercentDone#" index="i">
							<cfset Block = "Block" & i>
							document.#Block#.src = '/images/red_block.gif';
						</cfloop>
						}
						//Show the progress in percent
						if(document.getElementById('ShowPercentProgress')){
						<cfset PercentDone = PercentDone&'0'>
							document.getElementById('ShowPercentProgress').innerHTML = '#PercentDone#%';
						}
					</script>
					<cfset LastPercent = PercentDone>
				</cfif>

				<cfset OuterLoopcount = OuterLoopcount + 1>
			</cfif>
		</cfoutput>		<!--- <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID"> --->

		<!--------------------------------------------------------------------------->
		<!--- Products main loop group by type code - end  -------------------------->
		<!--------------------------------------------------------------------------->

		<cfset colCount = 0>
		<cfoutput>
		<tr>
			<td style="background-color: ##ffce84;font-weight: bold" colspan="#th_count#" class="3704"><strong>#qGetMarginUOT.UOT_Desc# Summary</strong></td>
		</tr>

		<cfset OriginalTotalProgramVolume = TotalProgramVolume>

		<!------------------------------------------------------------------------------------------------------------------->
		<!------ Annual/Program Summary : Rate / UOM START ------------------------------------------------------------------>
		<!------------------------------------------------------------------------------------------------------------------->
		<cfset displayUOM = totalprogramvolumeUOM>
		<cfset qProgramSummaryMargins = getProgramMargins>
		<!--- <cfinclude template="layered_margin_program_rate_summary.cfm"> --->
		<cfset layered_margin_program_rate_summary()>

		<!--------------------------------------------------------------------------------------------------->
		<!--- display additional summary line for cs/lb if annual spending rate approval app switch is ON --->
		<!--------------------------------------------------------------------------------------------------->
		<cfif appSettings.getApprovalMarginType() eq 2>
			<cfif form.Margin_Type eq 1><!--- case --->
				<!--- Display pound --->
				<cfset displayUOM = "LB">
				<cfset qProgramSummaryMargins = ApprovalProgramManager.getProgramMargins(contract_main_id, 3, "#margin_version#")>
			<cfelse><!--- pound --->
				<!--- Display case --->
				<cfset displayUOM = "CS">
				<cfset qProgramSummaryMargins = ApprovalProgramManager.getProgramMargins(contract_main_id, 1, "#margin_version#")>
			</cfif>

			<!--- <cfinclude template="layered_margin_program_rate_summary.cfm"> --->
			<cfset layered_margin_program_rate_summary()>
		</cfif>
		<!------------------------------------------------------------------------------------------------------------------->
		<!------ Annual/Program Summary : Rate / UOM end -------------------------------------------------------------------->
		<!------------------------------------------------------------------------------------------------------------------->

		<!------------------------------------------------------------------------------------------------------------------->
		<!------ Annual/Program Summary : Absolute $ start ------------------------------------------------------------------>
		<!------------------------------------------------------------------------------------------------------------------->

		<cfset TotalProgramVolume = OriginalTotalProgramVolume>
		<tr valign="middle">
		  <td align="left" class="header 3742"><strong>Absolute $</strong></td>
			  <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
			<!--- 114617 :: Ideal Price START --->
			<cfif getProgramInfo.Ideal_Price>
					<td>&nbsp;</td>
			</cfif>
			<!--- 114617 :: Ideal Price END --->
			<!------------------------->
			<!--- 001 - Fixed Price --->
			<!------------------------->
			<cfif variables.bDisplayContractPrice>
				<!--- 16314 [begin] --->
				<td class="3749">&nbsp;</td>
				<!--- 16314 [end] --->
			</cfif>
			<!--- 17289 > 16314 follow up 10/14/08 [end] --->
						<!--- 114617 :: Ideal Price START --->
						<cfif getProgramInfo.Ideal_Price>
								<td>&nbsp;</td>
								<td id="PrgABSummary_Dollars">
									#application.util.string.cellFormat(value=TotalPrgDiffDollar ,category = "dollar2")#
								</td>
						</cfif>
						<!--- 114617 :: Ideal Price END --->
			<!------------------------->
			<!--- 002 - Vol. CS ------->
			<!------------------------->
			<cfif Get_Profile_Settings.Base_View eq 1>
				<cfset data = makeNumeric(TotalProgramVolume)>

			<cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)>
				<td class="3760">
					<cfset colCount = colCount + 1>
					<cfif ((TotalProgramVolume GT AnnualVolume_CS) and TRIM(AnnualVolume_CS) NEQ "*")
						OR  ((TotalProgramVolume LT MinVolume_CS) and TRIM(MinVolume_CS) NEQ "*")>
						<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
							onmouseover="initTheTooltip('Volume not within your approval limits.')"
							onmouseout="popOut()"
							align="absmiddle">
					</cfif>&nbsp;
				</td>
				<!------------------------->
				<!--- 003 - Base Sales ---->
				<!------------------------->
				<cfset data = makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(TotalProgramVolume)>
				<cfset tempABS_BaseSales = data>

				<td align="right" nowrap class="3776">
					#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#
				</td>

				<!----------------------->
				<!--- ALlow/Surch --->
				<!----------------------->
				<cfset data = makeNumeric(getProgramMargins.Total_Allowance_Surcharges) * makeNumeric(TotalProgramVolume)>

				<td align="right" nowrap class="3785">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!----------------------->
				<!--- Customer Freight --->
				<!----------------------->
				<cfset data = makeNumeric(getProgramMargins.Total_Customer_Freight) * makeNumeric(TotalProgramVolume)>

				<td align="right" nowrap class="3792">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<cfif direct_pricing eq 0>
					<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
					<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
					<!--- 004 --->
					<!--------------------->
					<!--- 004 Cash Disc --->
					<!--------------------->
					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
						<cfset data = makeNumeric(getProgramMargins.Total_Cash_Discount) * makeNumeric(TotalProgramVolume)>

						<td align="right" nowrap class="3804">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					</cfif>
					<!----------------------->
					<!--- 005 - allowance --->
					<!----------------------->
					<cfparam name="addExtra" default="0">
					<cfif TotalProgramVolume neq "" and TotalProgramVolume neq 0>
						<cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/TotalProgramVolume)>
					</cfif>
					<cfif form.Margin_Type eq 1 OR form.margin_type eq 3>
						<cfset data = (makeNumeric(getProgramMargins.TOTAL_Allowance) + addExtra) * makeNumeric(TotalProgramVolume)>
					<cfelse>
						<cfset data = makeNumeric(getProgramMargins.TOTAL_Allowance) * makeNumeric(TotalProgramVolume)>
					</cfif>

					<cfset AllowAbs1 = makeNumeric(data)>
					<td align="right" nowrap class="3822" id="PrgABSummary_Allowance" LumpsumAmount=#application.util.string.cellFormat(value=getProgramLumpsum.Lumpsum_Amount ,decimalplaces = request.nondollar_format)#>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					<!--------------------->
					<!--- 006 - allow % --->
					<!--------------------->
					<td align="right" nowrap class="3826">&nbsp;</td>
				</cfif>

				<cfif ShowTPA eq 1>
					<!----------------------------->
					<!--- TPA Operator --------------->
					<!----------------------------->
					<cfset data = makeNumeric(getProgramMargins.Total_TPA_Oper) * makeNumeric(TotalProgramVolume)>

					<td align="right" nowrap class="3835">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					<!----------------------------->
					<!--- TPA Distributor (Distributor Trade) --------------->
					<!----------------------------->
					<cfset data = makeNumeric(getProgramMargins.Total_TPA) * makeNumeric(TotalProgramVolume)>

					<td align="right" nowrap class="3841">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>

				<cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
					<!----------------------------->
					<!--- 008 - pullback amount --->
					<!----------------------------->
					<cfset data = makeNumeric(getProgramMargins.Total_pullbackamount) * makeNumeric(TotalProgramVolume)>

					<td align="right" nowrap class="3850">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>

				<!----------------------------->
				<!--- Other Spend --------------->
				<!----------------------------->
				<cfset data = makeNumeric(getProgramMargins.Total_Other_Spend) * makeNumeric(TotalProgramVolume)>

				<td align="right" nowrap class="3858">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 0>
					<!----------------------->
					<!--- 009 - net sales --->
					<!----------------------->
					<cfset data = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume)>
					<cfset tempABS_NetSales = data>

					<td align="right" nowrap class="3868" id="PrgABSummary_NetSales">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>
			</cfif>

			<cfif Get_Profile_Settings.View_Cost eq 1>
				<!------------------>
				<!--- 010 - cost --->
				<!------------------>
				<cfset data = makeNumeric(getProgramMargins.Total_Cost) * makeNumeric(TotalProgramVolume)>

				<td align="right" nowrap class="3878">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>

			<cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
				<!----------------------->
				<!--- 011 - Brokerage --->
				<!----------------------->
				<cfset data = makeNumeric(getProgramMargins.Total_Brokerage) * makeNumeric(TotalProgramVolume)>

				<td align="right" nowrap class="3887">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>

			<!----------------------------->
			<!--- Shuttle Freight --------------->
			<!----------------------------->
			<cfset data = makeNumeric(getProgramMargins.Total_shuttle_freight) * makeNumeric(TotalProgramVolume)>

			<td align="right" nowrap class="3895">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

			<!----------------------------->
			<!--- Warehouse --------------->
			<!----------------------------->
			<cfset data = makeNumeric(getProgramMargins.Total_Custom_Warehouse) * makeNumeric(TotalProgramVolume)>

			<td align="right" nowrap class="3902">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

			<!----------------------------->
			<!--- Gross Margin --------------->
			<!----------------------------->
			<cfset data = makeNumeric(getProgramMargins.Total_Gross_Margin) * makeNumeric(TotalProgramVolume)>

			<td align="right" nowrap class="3909" id="PrgABSummary_GrossMargin">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

			<!----------------------->
			<!--- Brokerage --->
			<!----------------------->
			<cfset data = makeNumeric(getProgramMargins.Total_Custom_Brokerage) * makeNumeric(TotalProgramVolume)>

			<td align="right" nowrap class="3916">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

			<!----------------------->
			<!--- Contribution Margin --->
			<!----------------------->
			<cfset data = makeNumeric(getProgramMargins.Total_Contribution_Margin_Alt) * makeNumeric(TotalProgramVolume)>

			<td align="right" nowrap class="3923" id="PrgABSummary_Contribution_Margin">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

			<!----------------------->
			<!--- Variable Contribution Margin --->
			<!----------------------->
			<cfset data = makeNumeric(getProgramMargins.Total_Variable_Contribution_Margin) * makeNumeric(TotalProgramVolume)>

			<td align="right" nowrap class="3930" id="PrgABSummary_Variable_Contribution_Margin">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

			<!----------------------->
			<!--- MAP and MDF --->
			<!----------------------->
			<cfset data = makeNumeric(getProgramMargins.Total_Map_Mdf) * makeNumeric(TotalProgramVolume)>

			<td align="right" nowrap class="3937">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

			<!----------------------->
			<!--- SG & A --->
			<!----------------------->
			<cfset data = makeNumeric(getProgramMargins.Total_SGA) * makeNumeric(TotalProgramVolume)>

			<td align="right" nowrap class="3944">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>


			<cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
				<!------------------------------>
				<!--- 012 - operating income --->
				<!------------------------------>
				<cfset data = makeNumeric(getProgramMargins.Total_OprIncome) * makeNumeric(TotalProgramVolume)>
				<cfset absTotalOperIncome = data>

				<td align="right" nowrap class="3954" id="PrgABSummary_Operating_Income">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>

			<cfif Get_Profile_Settings.View_Target_Margins eq 1>
				<cfif appSettings.getApprovalMarginType() eq 2>
					<!------------------------------->
					<!--- 013a - Annual Case Rate --->
					<!------------------------------->
					<cfset data = makeNumeric(getProgramMargins.Total_TradeAmt_CS) * makeNumeric(getProgramMargins.totalprogramvolumecs)>
					<cfset AllowAbs1 = makeNumeric(data)>

					<td align="right" nowrap class="3965">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<cfelse>
					<!--------------------------------------->
					<!--- 013m - Operating Margin Percent --->
					<!--------------------------------------->
					<cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
						<cfset data = makeNumeric(getProgramMargins.Total_OprMargin)>

							<cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)>
							<cfset data = "<b>#data#%</b>">
						<td class="3975">
							<cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*" and ignoreOperatingMarginCheck eq 0>
							<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
								onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')"
								onmouseout="popOut()"
								align="absmiddle">
							</cfif>&nbsp;
						</td>
					</cfif>
					</cfif>
			</cfif>

			<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
			<cfif Cont_Margin_Calculation EQ '1'>
				<cfset data = (makeNumeric(getProgramMargins.Total_Fixed_Mfg_Cost)+makeNumeric(getProgramMargins.Total_OprIncome)) * makeNumeric(TotalProgramVolume)/>
				<cfset TotalContribMargin = data>

				<td align="right" nowrap class="3992">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				<cfset variables.Total_Net_Sales = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume)>

				<cfif len(variables.Total_Net_Sales) EQ 0 OR variables.Total_Net_Sales EQ 0>
					<cfset variables.Total_Net_Sales = 1>
				</cfif>
				<cfset data = (TotalContribMargin/makeNumeric(variables.Total_Net_Sales)) * 100/>

				<td align="right" nowrap class="4000">#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
			</cfif>

			<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
			<!------------>
			<!--- 013z --->
			<!------------>
			<td valign="bottom" class="4007 csvExclude">&nbsp;</td>
			<!------------------->
			<!--- 013b | 013n --->
		<cfif margin_display_style neq "custom_t">
			<td class="4011">&nbsp;</td>
		</cfif>
			<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<!---------------------->
				<!--- 014 - Trade CS --->
				<!---------------------->
				<cfset data = makeNumeric(getProgramMargins.Total_TradeAmt) * makeNumeric(TotalProgramVolume) >

				<td align="right" nowrap class="4020">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!---------------------->
				<!--- 015 - trade %  --->
				<!---------------------->
				<cfset data = makeNumeric(getProgramMargins.Total_TradePercent)>

				<td align="right" nowrap class="4027">#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
			</cfif>
			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
			<cfif Get_Profile_Settings.Base_View eq 1>
				<!------------------------->
				<!--- 016 - Trade Spent --->
				<!------------------------->
				<cfset data = makeNumeric(program_spend_in_margin_uot)>

				<td align="right" nowrap class="4036" id="PrgABSummary_Trade_Spent">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
			</cfif>

			<cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
				<td class="4040">&nbsp;</td>
				<td class="4041">&nbsp;</td>
				<td class="4042">&nbsp;</td>
				<td class="4043">&nbsp;</td>
			<cfelse>
				<!--- <td class="4045">&nbsp;</td>
				<td class="4046">&nbsp;</td> --->
			</cfif>
		</tr>
		<!------------------------------------------------------------------------------------------------------------------->
		<!------ Annual/Program Summary : Absolute $ end -------------------------------------------------------------------->
		<!------------------------------------------------------------------------------------------------------------------->
		<!--- 114617 --->
		<cfif ! url.idealPriceAnalysis>
		<!------------------------------------------------------------------------------------------------------------------->
		<!------ Program Summary: Absolute#2 $ START ------------------------------------------------------------------------>
		<!------------------------------------------------------------------------------------------------------------------->
		<cfif qGetMarginUOT.Unit_Multiplier NEQ 0>
			<tr>
				<td class="header 4058" colspan="#th_count#"><br><strong>Program Summary</strong></td>
	 		</tr>

			<tr valign="middle">
				<td align="left" class="header 4062"><strong>Absolute $</strong></td>
				<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
				<cfif variables.bDisplayContractPrice>
				<!--- 16314 [begin] --->
					<td class="4066">&nbsp;</td>
					<!--- 16314 [end] --->
				</cfif>
				<!--- 17289 > 16314 follow up 10/14/08 [end] --->
				<cfset ProgramVolume_For_Program_Span = (TotalProgramVolume * getProgramInfo.Program_Span) / qGetMarginUOT.Unit_Multiplier>

				<cfif Get_Profile_Settings.Base_View eq 1>
					<!--- volume --->
					<td class="4074">&nbsp;</td>
					<!--- 003 - base sales --->
					<cfset data = makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(ProgramVolume_For_Program_Span)>
					<cfset tempABS_BaseSales = data>

					<td align="right" nowrap class="4079">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

					<!--- ALlow/Surch --->
					<cfset data = makeNumeric(getProgramMargins.Total_Allowance_Surcharges) * makeNumeric(ProgramVolume_For_Program_Span)>

					<td align="right" nowrap class="4084">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

					<!--- Customer Freight --->
					<cfset data = makeNumeric(getProgramMargins.Total_Customer_Freight) * makeNumeric(ProgramVolume_For_Program_Span)>

					<td align="right" nowrap class="4089">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

					<!--- cash disc --->
					<cfif direct_pricing eq 0>
						<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
						<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
						<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
								<cfset data = makeNumeric(getProgramMargins.Total_Cash_Discount) * makeNumeric(ProgramVolume_For_Program_Span)>

								<td align="right" nowrap class="4098">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
						</cfif>
						<!--- 005 - allowance --->
						<cfparam name="addExtra" default="0">
						<cfif ProgramVolume_For_Program_Span neq "" and ProgramVolume_For_Program_Span neq 0>
							<cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/ProgramVolume_For_Program_Span)>
						</cfif>
						<cfif form.Margin_Type eq 1 OR form.margin_type eq 3>
							<cfset data = (makeNumeric(getProgramMargins.TOTAL_Allowance) + addExtra) * makeNumeric(ProgramVolume_For_Program_Span)>
						<cfelse>
							<cfset data = makeNumeric(getProgramMargins.TOTAL_Allowance) * makeNumeric(ProgramVolume_For_Program_Span)>
						</cfif>

						<cfset AllowAbs1 = makeNumeric(data)>

						<td align="right" nowrap class="4113">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
						<!--- 006 -skip a column for "Allow %" --->
						<td align="right" nowrap class="4115">&nbsp;</td>
					</cfif>

					<!--- 007 - TPA --->
					<cfif ShowTPA eq 1>
						<!--- TPA Operator --->
						<cfset data = makeNumeric(getProgramMargins.Total_TPA_Oper) * makeNumeric(ProgramVolume_For_Program_Span)>

						<td align="right" nowrap class="4123">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
						<!--- TPA Distributor (Distributor Trade) --->
						<cfset data = makeNumeric(getProgramMargins.Total_TPA) * makeNumeric(ProgramVolume_For_Program_Span)>

						<td align="right" nowrap class="4127">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					</cfif>

					<!--- 008 - pullback amount --->
					<cfif appSettings.getPullbacksOn() eq 1
							and GetSettings.Pullbacks_On eq 1>
						<cfset data = makeNumeric(getProgramMargins.Total_pullbackamount) * makeNumeric(ProgramVolume_For_Program_Span)>

						<td align="right" nowrap class="4135">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					</cfif>

					<!--- Other Spend --->
					<cfset data = makeNumeric(getProgramMargins.Total_Other_Spend) * makeNumeric(ProgramVolume_For_Program_Span)>

					<td align="right" nowrap class="4141">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

					<!--- 009 - net sales --->
					<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
					<cfif appSettings.getApprovalMarginType() eq 0>
						<cfset data = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(ProgramVolume_For_Program_Span)>
						<cfset tempABS_NetSales = data>

						<td align="right" nowrap class="4149">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					</cfif>
				</cfif>

				<!--- 010 - cost --->
				<cfif Get_Profile_Settings.View_Cost eq 1>
					<cfset data = makeNumeric(getProgramMargins.Total_Cost) * makeNumeric(ProgramVolume_For_Program_Span)>

					<td align="right" nowrap class="4157">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>

				<!--- 011 - Brokerage --->
				<cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
					<cfset data = makeNumeric(getProgramMargins.Total_Brokerage) * makeNumeric(ProgramVolume_For_Program_Span)>

					<td align="right" nowrap class="4164">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>

				<!--- Shuttle Freight --->
				<cfset data = makeNumeric(getProgramMargins.Total_shuttle_freight) * makeNumeric(ProgramVolume_For_Program_Span)>

				<td align="right" nowrap class="4170">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!--- Warehouse --->
				<cfset data = makeNumeric(getProgramMargins.Total_Custom_Warehouse) * makeNumeric(ProgramVolume_For_Program_Span)>

				<td align="right" nowrap class="4175">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!--- Gross Margin --->
				<cfset data = makeNumeric(getProgramMargins.Total_Gross_Margin) * makeNumeric(ProgramVolume_For_Program_Span)>

				<td align="right" nowrap class="4180">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!--- Brokerage --->
				<cfset data = makeNumeric(getProgramMargins.Total_Custom_Brokerage) * makeNumeric(ProgramVolume_For_Program_Span)>

				<td align="right" nowrap class="4185">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!--- Contribution Margin --->
				<cfset data = makeNumeric(getProgramMargins.Total_Contribution_Margin_Alt) * makeNumeric(ProgramVolume_For_Program_Span)>

				<td align="right" nowrap class="4190">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!--- Variable Contribution Margin --->
				<cfset data = makeNumeric(getProgramMargins.Total_Variable_Contribution_Margin) * makeNumeric(ProgramVolume_For_Program_Span)>

				<td align="right" nowrap class="4195">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!--- MAP and MDF --->
				<cfset data = makeNumeric(getProgramMargins.Total_Map_Mdf) * makeNumeric(ProgramVolume_For_Program_Span)>

				<td align="right" nowrap class="4200">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<!--- SG & A --->
				<cfset data = makeNumeric(getProgramMargins.Total_SGA) * makeNumeric(ProgramVolume_For_Program_Span)>

				<td align="right" nowrap class="4205">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

				<cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
					<!--- 012 - operating income --->
					<cfset data = makeNumeric(getProgramMargins.Total_OprIncome) * makeNumeric(ProgramVolume_For_Program_Span)>
					<cfset absTotalOperIncome = data>

					<td align="right" nowrap class="4212">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>

				<!--- 013 - operating margin --->
				<cfif Get_Profile_Settings.View_Target_Margins eq 1>
					<cfif appSettings.getApprovalMarginType() eq 2>
						<!--- 013a - Annual Case Rate --->
						<cfset data = makeNumeric(getProgramMargins.Total_TradeAmt_CS) * makeNumeric(getProgramMargins.totalprogramvolumecs)>
						<cfset AllowAbs1 = makeNumeric(data)>

						<td align="right" nowrap class="4222">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					<cfelse>
						<!--- 013m - Operating Margin Percent --->
						<cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
							<cfset data = makeNumeric(getProgramMargins.Total_OprMargin)>

								<cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format) >
								<cfset data = "<b>#data#%</b>">

							<td>
								<cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin)
									and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*" and ignoreOperatingMarginCheck eq 0>
									<IMG SRC="/images/exclamation.gif"
										HEIGHT="10"
									WIDTH="10"
									onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')"
									onmouseout="popOut()"
									align="absmiddle">
								</cfif>&nbsp;
							</td>
						</cfif>
					</cfif>
				</cfif>

				<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
				<cfif Cont_Margin_Calculation EQ '1'>
					<cfset data = absTotalOperIncome/>
					<cfset TotalContribMargin = data>


					<td align="right" nowrap class="4252">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
					<cfset TOTALNetSales = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(ProgramVolume_For_Program_Span)>
					<cfif TOTALNetSales EQ 0>
						<cfset TOTALNetSales = 1>
					</cfif>
					<cfset data = (TotalContribMargin/makeNumeric(TOTALNetSales)) * 100>

					<td align="right" nowrap class="4259">#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
				</cfif>

				<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
				<td class="4263">&nbsp;</td>
				<td class="4264">&nbsp;</td>
				<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
				<cfif appSettings.getApprovalMarginType() eq 1>
					<!--- Trade CS --->
					<cfset data = makeNumeric(getProgramMargins.Total_TradeAmt) * makeNumeric(ProgramVolume_For_Program_Span)>

					<td align="right" nowrap class="4270">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

					<!--- Trade Percent --->
					<cfset data = makeNumeric(getProgramMargins.Total_TradePercent)>

					<td align="right" nowrap class="4275">#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
				</cfif>

				<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
				<cfif Get_Profile_Settings.Base_View eq 1>
					<!--- trade spend --->
					<cfset data = makeNumeric(program_spend)>

					<td align="right" nowrap class="4283">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
				</cfif>

				<cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
					<td class="4287" class="csvExclude">&nbsp;</td>
					<td class="4288" class="csvExclude">&nbsp;</td>
					<td class="4289" class="csvExclude">&nbsp;</td>
					<td class="4290" class="csvExclude">&nbsp;</td>
				<cfelse>
					<td class="4292" class="csvExclude">&nbsp;</td>
					<td class="4293" class="csvExclude">&nbsp;</td>
				</cfif>
			</tr>
		</cfif>

		<!------------------------------------------------------------------------------------------------------------------->
		<!------ Program Summary: Absolute#2 $ END -------------------------------------------------------------------------->
		<!------------------------------------------------------------------------------------------------------------------->


		<!---   Dev Note: KAL; D21684: Functionality of View Margins Screen
			Code from this section is moved to separate files for code reusability and ease of development purposes.
			Previous Version - Annual/Program Summary: Code is moved to layered_margin_parent_program_summary.cfm
			Margin Variance: Code is moved to layered_margin_parent_program_variance.cfm.
			First the code was moved and checked in and then changes were made to the code.
		--->


		<cfif Program_Is_A_Revision AND displayPreviousVersionMargin>
			<!--- *** Previous Program Margins - Current Date -- Start *** --->

			<!--- variable to set which margin_version; used in layered_margin_parent_program_summary.cfm --->
			<cfset margin_version = "current">

			<!--- Previous Program Margins Current Date --->
			<cfset getPgmPrevVerMargins_Current = ApprovalProgramManager.getProgramMargins(getProgramInfo.Revision_of_Contract_Main_ID, form.Margin_Type, "current")>

			<!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg START --->
			<cfif getPgmPrevVerMargins_Current.recordcount>
			<!--- set previous margin to this variable as we use this variable in the included templates --->
			<cfset getProgramPreviousVersionMargins = getPgmPrevVerMargins_Current>

			<cfset TotalProgramPreviousVersionVolume = getProgramPreviousVersionMargins.totalprogramvolume>
			<cfset PreviousVersion_program_spend = Val(getProgramPreviousVersionInfo.program_spend)>
			<cfset PreviousVersion_program_spend_in_margin_uot = Val(getProgramPreviousVersionInfo.program_spend_in_margin_uot)>
			<cfset PreviousVersion_Margin_Calculated_Date = ApprovalProgramManager.getMarginCalculatedDate(getProgramInfo.Revision_of_Contract_Main_ID, "current")>

			<!------ Previous Version - Annual/Program Summary : Rate/UOM & Absolute $ ----->
			<cfinclude template="layered_margin_parent_program_summary.cfm">

			<!------ Previous Version - Margin Variance ----->
			<cfinclude template="layered_margin_parent_program_variance.cfm">
		</cfif>
		<!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg END --->
		<!--- *** Previous Program Margins - Current Date -- End *** --->

		<!--- **** Previous Program Approved Margins -- Start **** --->
		<!--- variable to set which margin_version; used in layered_margin_parent_program_summary.cfm --->
		<cfset margin_version = "approved">

		<!--- Previous Program Approved Margins --->
		<cfset getPgmPrevVerMargins_Approved = ApprovalProgramManager.getProgramMargins(getProgramInfo.Revision_of_Contract_Main_ID, form.Margin_Type, "approved")>

		<!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg START --->
		<cfif getPgmPrevVerMargins_Approved.recordcount>
			<!--- set previous margin to this variable as we use this variable in the included templates --->
			<cfset getProgramPreviousVersionMargins = getPgmPrevVerMargins_Approved>

			<cfset TotalProgramPreviousVersionVolume = getProgramPreviousVersionMargins.totalprogramvolume>
			<cfset PreviousVersion_program_spend = Val(getProgramPreviousVersionInfo.program_spend)>
			<cfset PreviousVersion_program_spend_in_margin_uot = Val(getProgramPreviousVersionInfo.program_spend_in_margin_uot)>
			<cfset PreviousVersion_Margin_Calculated_Date = ApprovalProgramManager.getMarginCalculatedDate(getProgramInfo.Revision_of_Contract_Main_ID, "approved")>

			<!------ Previous Version - Annual/Program Summary : Rate/UOM & Absolute $ ----->
			<cfinclude template="layered_margin_parent_program_summary.cfm">

			<!------ Previous Version - Margin Variance ----->
			<cfinclude template="layered_margin_parent_program_variance.cfm">
		</cfif>
		<!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg END --->
	  	<!--- **** Previous Program Approved Margins -- Start **** --->
	</cfif>

	<cfif CannotApproveSettings eq 1>
		<cfset button_label = "Agree">
	</cfif>
	<cfif button_label eq "Approve">
		<cfset bProgramFinalApprove = 1><!------ this var should be set only when either all product are approved, or the current user can approve all the product left to approve ----->
	</cfif>

	<!------ display the pullback checkbox ----->
	<cfif bPullbackAvailable>
		<!------
		Different possible scenario
		- pullback already approved
		- pullback not approved and user do not have approval right for this template
		- pullback not approved and user do have approval right for this template
		----->

		<cfset pullbackBgColor = "gray">
		<cfset pullbackCheckDisabled = " disabled">
		<cfset pullbackCheckChecked = "">
		<cfif bUserCanApprovePullbackForThisPgm>
			<cfset pullbackBgColor = "ffdead">
			<cfset pullbackCheckDisabled = "">
		</cfif>
		<cfif bPullbackApproved>
			<cfset pullbackCheckChecked = " checked">
			<cfset pullbackCheckDisabled = " disabled">
		</cfif>

		<!------ If pullback not yet approved and needs approval ----->
		<cfif bPullbackAvailable AND NOT bPullbackApproved>
			<cfif bUserCanApprovePullbackForThisPgm eq 1>
				<cfset bApprovingPullbackApprovesProgram = bProgramFinalApprove><!------ this var should be set only when either all product are approved, or the current user can approve all the product left to approve ----->
			</cfif>
		</cfif>
		<tr>
			<td class="4400">&nbsp;</td>
		</tr>
		<tr>
			<td bgcolor="#pullbackBgColor#" class="header" colspan="8"><b>Approve #appSettings.getPullbackLabel()#</b></td>
			<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
			<cfif variables.bDisplayContractPrice>
			<!--- 16314 [begin] --->
				<td class="4407">&nbsp;</td>
				<!--- 16314 [end] --->
			</cfif>
			<!--- 17289 > 16314 follow up 10/14/08 [end] --->
			<td bgcolor="#pullbackBgColor#" class="4411">
				<input type="checkbox"
						name="Approve_Pullback"
						value="1" #pullbackCheckDisabled# #pullbackCheckChecked#
					<cfif bApprovingPullbackApprovesProgram>onPropertyChange="javaScript:changeApproveLabel(this.checked);"</cfif>
						bApprovingPullbackApprovesProgram="#bApprovingPullbackApprovesProgram#">
			</td>
			<td bgcolor="#pullbackBgColor#" class="4418"><span class="title6">Approve</span></td>
			<td bgcolor="#pullbackBgColor#" class="4419">
				<cfif bPullbackApproved>
					<IMG SRC="/images/Layered_Approval/Gaya_i11.gif"
						onmouseover="initTheTooltip('#sPullbackApprovedMessage#')"
						onmouseout="popOut()">
				<cfelse>
					<IMG SRC="/images/Layered_Approval/Gaya_i12.gif">
				</cfif>
			</td>
			<td class="4428">&nbsp;</td>
		</tr>
	</cfif>
	<!------ END display the pullback checkbox END ----->

	<!---- Freight Calculator - START --->
	<cfif appSettings.getFreight_Calculator_On()>
		<tr>
			<cfif Get_Profile_Settings.Base_View eq 1>
				<td class="4437">&nbsp;</td>
				<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
				<cfif variables.bDisplayContractPrice>
					<!--- 16314 [begin] --->
					<td class="4441">&nbsp;</td>
					<!--- 16314 [end] --->
				</cfif>
				<!--- 17289 > 16314 follow up 10/14/08 [end] --->
				<td class="4445">&nbsp;</td>
				<td class="4446">&nbsp;</td>
			</cfif>
			<cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
				<td class="4449">&nbsp;</td>
			</cfif>
			<cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
				<td class="4452">&nbsp;</td>
			</cfif>
			<cfif direct_pricing eq 0>
				<td class="4455">&nbsp;</td>
			</cfif>
			<cfif ShowTPA eq 1>
				<td class="4458">&nbsp;</td>
			</cfif>
			<cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
				<td class="4461">&nbsp;</td>
			</cfif>
		 	<cfif Get_Profile_Settings.View_Cost eq 1>
				<td class="4464">&nbsp;</td>
			</cfif>
		 	<cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
				<td class="4467">&nbsp;</td>
			</cfif>
			<cfif Get_Profile_Settings.View_Operating_Income eq 1>
				<td class="4470">&nbsp;</td>
			</cfif>
			<cfif Get_Profile_Settings.View_Operating_Income eq 1>
				<td align="left" colspan="2" class="4473">Freight Estimate:</td>
				<td align="left" colspan="2" class="4474"><input type="text" id="marginFreightCalc"
					name="marginFreightCalc"
					onBlur="javascript:calcFreight();"
					size="3">%</td>
				<td align="left" colspan="2" class="4478">Est. Freight $:</td>
			 	<td id="marginFreightCalcTarget" align="left" class="4479"></td>
			<cfelse>
				<td colspan="7" class="4481">&nbsp;</td>
		 	</cfif>
			<cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
				<td class="4484">&nbsp;</td>
				<td class="4485">&nbsp;</td>
			</cfif>
		</tr>

		<tr>
			<cfif Get_Profile_Settings.Base_View eq 1>
					<td class="4491">&nbsp;</td>
					<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
					<cfif variables.bDisplayContractPrice>
						<!--- 16314 [begin] --->
						<td class="4495">&nbsp;</td>
						<!--- 16314 [end] --->
					</cfif>
					<!--- 17289 > 16314 follow up 10/14/08 [end] --->
					<td class="4499">&nbsp;</td>
					<td class="4500">&nbsp;</td>
			</cfif>

			<cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
				<td class="4504">&nbsp;</td>
			</cfif>
			<cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
				<td class="4507">&nbsp;</td>
			</cfif>
			<cfif direct_pricing eq 0>
				<td class="4510">&nbsp;</td>
			</cfif>
			<cfif ShowTPA eq 1>
				<td class="4513">&nbsp;</td>
			</cfif>
			<cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
				<td class="4516">&nbsp;</td>
			</cfif>
			<cfif Get_Profile_Settings.View_Cost eq 1>
				<td class="4519">&nbsp;</td>
			</cfif>

			<cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
				<td class="4523">&nbsp;</td>
			</cfif>
			<cfif Get_Profile_Settings.View_Operating_Income eq 1>
				<td class="4526">&nbsp;</td>
			</cfif>
			<cfif Get_Profile_Settings.View_Operating_Income eq 1>
				<td align="left" colspan="2" class="4529">Est. Operating Margin Dollars: </td>
				<td align="left" colspan="2" id="marginDollars" class="4530"></td>
				<td align="left" colspan="2" class="4531">Est. Operating Margin %:</td>
				<td id="marginPercent" align="left" class="4532"></td>
			<cfelse>
				<td colspan="7" class="4534">&nbsp;</td>
			</cfif>
			<cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
				<td class="4537">&nbsp;</td>
				<td class="4538">&nbsp;</td>
			</cfif>
		</tr>
	</cfif>
	<!---- Freight Calculator - END --->


	<!--- Dev Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->
	<cfif appSettings.getMarginItemsExclude()>
		<tr> <td style="border-bottom: 0px solid blue;" class="4547" colspan="#th_count#">&nbsp;</td> </tr>
		<tr>
			<td align="left" colspan="#th_count#" id="highlight" class="4549">
				<strong>
				<a href="##" onclick="toggleProdExcludeView();">
					Products Excluded From Margin
				</a>
		  		</strong>
			</td>
		</tr>
		<cfinclude template="layered_margin_items_exclude.cfm">
	</cfif>
	<!--- End Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->

	<!---- NEW BUDGET DISPLAY ---->
	<cfif appSettings.getBudgetsFunctionalityOn()>
		#budgetDisplayString#
	</cfif>
	<!---- NEW BUDGET DISPLAY - END ---->
</cfif>
<!--- 114617 --->
	</cfoutput>

	</table>
</div>

<cfif ! isdefined('ProgramVolume_For_Program_Span')>
	<cfif qGetMarginUOT.Unit_Multiplier>
		<cfset ProgramVolume_For_Program_Span = (TotalProgramVolume * getProgramInfo.Program_Span) / qGetMarginUOT.Unit_Multiplier>
	<cfelse>
		<cfset ProgramVolume_For_Program_Span = 1>
	</cfif>
</cfif>

  <cf_include files="/script/javascript/table2csv.js">

  <script>
    const margin_table_id = "GridView1";
    const is_debugging    = 0;
    const begin           = performance.now();
    let column_count      = 0;
    let margin_Table      = document.getElementById( margin_table_id );

    /* gather table content BEFORE gridviewscroll breaks it apart */
    let margin_table_content = $( '#' + margin_table_id ).table2CSV( { findTHEAD: 'tr:first-child', csvExclude: 'csvExclude' } );

    margin_Table.rows[ 0 ].classList.add( "GridViewScrollHeader" );
    // loop through each row of the table body
    for ( let row = 1; row < margin_Table.rows.length; row++ ) {
      margin_Table.rows[ row ].classList.add( "GridViewScrollItem" );
    }

    // get the cells collection of the header row.
    let objCells = margin_Table.rows.item( 0 ).cells;

    // apply right alignment to all columns in header except the first one
    for ( let col = 1; col < objCells.length; col++ ) {
      objCells.item( col ).style.textAlign = "right";
    }

    column_count = objCells.length;

    if ( is_debugging ) {
       // loop through each row of the table body
       for ( let row = 1; row < margin_Table.rows.length; row++ ) {
         let objCells = margin_Table.rows.item( row ).cells;
        //  detect mistmached between td count and th count
         if ( objCells.length !== column_count ) {
            console.log("Unexpected row", row, "has", objCells.length, "tds", " - expected td count is", column_count);
         }
       }
       console.log("Elapsed time = ", performance.now() - begin);
    }

    $(document).ready(function() {
        gridViewScroll = new GridViewScroll( {
                                                elementID : margin_table_id,
                                                freezeColumn : true,
                                                freezeColumnCssClass : "GridViewScrollItemFreeze",
                                                freezeFooter : false,
                                                freezeHeaderRowCount : 1,
                                                freezeColumnCount : 1,
                                                width: "99%",
                                                height: "99%"
                                            } );

        gridViewScroll.enhance();

        $( window ).resize( function() {
            gridViewScroll.undo();
            gridViewScroll.enhance();
        } );

	//114617 :: Ideal Price START
	<cfif ! url.idealPriceAnalysis>
        // override the onclick assigned in other .cfm file due to gridviewscroll breaking table into multiple pieces
        document.getElementById( "csv" ).addEventListener( 'click', function(e) {
          e.preventDefault();

          $j( "input[name=csv_file_name]" ).val( "Margins"
                                                + <cfoutput>" #getProgramInfo.contract_number# "</cfoutput>
                                                + new Date().toJSON().slice( 0, 10 )
                                                + ".csv" );
          $j( "#csv_text" ).val( margin_table_content );
          $j( "#csv_form" ).submit();
        } );
	</cfif>
	//114617 :: Ideal Price END
    } );

		function changemarginType(Margin){
		document.MyForm.action = "layered_approval_include.cfm?Margin_Type="+Margin+"&<cfoutput>CID=#URL.CID#&UoT=#url.UoT#&duplicateprogram=#duplicateprogram#</cfoutput>"
									+ <cfif isDefined("MarginCalculatedDate")> "&MarginCalculatedDate=<cfoutput>#MarginCalculatedDate#</cfoutput>" <cfelse> "" </cfif>;
		MyForm.submit();
		}
	function showrevisiondetails(contractid,status){
		NewWindow('/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id='+contractid+'&Contract_Status='+status,'ProgramRevisionDetails','1200','550','Yes', 'Yes')

		}
	<!--- Freight Calc Js --->
	<cfif Get_Profile_Settings.View_Operating_Income eq 1>
		function calcFreight() {
			var totalBaseSales       = < cfoutput > #tempABS_BaseSales# < /cfoutput>;
			var percentage           = parseInt(document.all.marginFreightCalc.value);
			var totalOperatingMargin = < cfoutput > #absTotalOperIncome# < /cfoutput>;
			var netSales             = < cfoutput > #tempABS_NetSales# < /cfoutput>;
			var calcTarget           = 0;
			var marginDollars        = 0;
			var marginPercentage     = 0;
			if (isNaN(percentage)) {
				document.all.marginFreightCalcTarget.innerText = 0;
				document.all.marginFreightCalc.value           = 0;
			} else {
				if (percentage > 1000 || percentage < 0) {
					document.all.marginFreightCalc.value = 0;
				} else {
					calcTarget                                     = parseInt((percentage * .01) * totalBaseSales);
					marginDollars                                  = (totalOperatingMargin - calcTarget);
					marginPercentage                               = (marginDollars / netSales) * 100.0;
					document.all.marginFreightCalcTarget.innerText = "$" + FormatTextWithCommas(calcTarget);
					document.all.marginDollars.innerText           = "$" + FormatTextWithCommas(marginDollars);
					if (isNaN(marginPercentage) || marginDollars == 0) {
						document.all.marginPercent.innerText = 0 + "%";
					} else {
						document.all.marginPercent.innerText = parseInt(marginPercentage) + "%";
					}
				}
			}
		}
	</cfif>
//114617 :: Ideal Price START
  //Select and deselect all checkboxes
	$("#SelectItems").click(function(){
		$('.BSAID_Single:checkbox').not(":disabled").prop('checked', true);
		$('#UnselectItems').show();
		$('#SelectItems').hide();
	});
	$("#UnselectItems").click(function(){
		$('.BSAID_Single:checkbox').prop('checked', false);
		$('#UnselectItems').hide();
		$('#SelectItems').show();
	});

	$("#IdealPriceUpdate").click(function(){
		var IPChange = $('#IdealPricePlus').val();
		var count = 0 ;
		var typeCodeCount = 0;
		var Items = 0;
		var totalItems = $('input[name=ApproveList]').val();
					totalItems = totalItems.split(",").length;

			$("#GridView1_Content_Fixed input:checkbox").not(":disabled").each(function() {
				if($('input[name='+this.id+']:checked').val()){
					var bsaID = this.id;
					if(bsaID.length > 0){
					count = count + 1;
					// typ, id & Type Code
					IdealPriceCalculation('1', bsaID, $(this).attr("typecode"));

					var itemCount = $('input[name='+$(this).attr("typecode")+']').val();
								typeCodeCount = typeCodeCount + 1

					if( itemCount == typeCodeCount){
						TypeCodeCalculation('1', $(this).attr("typecode"));
						typeCodeCount = 0;
						Items = parseFloat(Items) + parseFloat(itemCount);
						if(totalItems == Items){
							PrgSummary();
						}
					}
				}
				}
			});
			if(! count){
				alert('Please select atleast one item.')
			}
	});

	function IdealPriceCalculation(typ, id, TypeCode){
		/*
		typ:
			1 :: Mass Apply
			0 :: Text Box
		*/
						var IPChange = $('#IdealPricePlus').val();
						var IdealPrice = $('#prodid_'+id).attr('idealprice');
						var decimalPlaces = <cfoutput>#decimal_places#</cfoutput>;
						var TotalAllowance = 0;
						var TotalAllowancePercentage = 0;
						var Volume = id+'_Volume';
						var FPid = id+'_Fixed_Price';
						var IPDiffID = id+'_IPDifference';
						var IPDiffDoll = id+'_IPDiffDoll';
						var FPidChange = id+'_Fixed_Price_Change';
						var Allowance = id+'_Allowance';
						var Allowance_TB = id+'_Allowance_TB';
						var AllowancePercentage = id+'_Allowance_Percentage';
						var NetSales = id+'_Net_Sales';
						var NetSales_TB = id+'_Net_Sales_TB';
						var GrossMargin = id+'_Gross_Margin';
						var GrossMargin_TB = id+'_Gross_Margin_TB';
						var ContributionMargin = id+'_Contribution_Margin';
						var ContributionMargin_TB = id+'_Contribution_Margin_TB';
						var VariableCM = id+'_Variable_Contribution_Margin';
						var VariableCM_TB = id+'_Variable_Contribution_Margin_TB';
						var OPRIncome = id+'_Operating_Income';
						var OPRIncome_TB = id+'_Operating_Income_TB';
						var OPRIncomePer = id+'_Operating_Margin_percent';
						var TradeSpend = id+'_Trade_Spent';
						var TradeSpend_TB = id+'_Trade_Spent_TB';
						var amtFormat = parseFloat('0').toFixed(decimalPlaces);

						//count = count + 1;
						$('#'+FPidChange).val('1');
						var FixedPrice = parseFloat($('#'+FPid).val());
						var defaultPrice = parseFloat('0').toFixed(decimalPlaces)
						if(typ ==1 && IdealPrice > defaultPrice){
							//CALCULATE NEW FIXED PRICE
							var NewPrice = parseFloat( (IPChange * IdealPrice)/100 )
									NewPrice = NewPrice +  parseFloat(IdealPrice);
									$('#'+FPid).val(NewPrice.toFixed(decimalPlaces));
						}else{
							var NewPrice = parseFloat($('#'+FPid).val());
						}
		//IDEAL PRICE DIFFERENCE CALCULATIONS
		if(NewPrice > IdealPrice){
			var IPDiff = parseFloat('0').toFixed(decimalPlaces);
			var IPDiffPer = parseFloat('0').toFixed(decimalPlaces);
			var IPInfo = numeral(IPDiff ).format( '$('+amtFormat+')' )+'<br>'+IPDiffPer+'%';
		}else{
			var IPDiff = (NewPrice - IdealPrice).toFixed(decimalPlaces);
			if(IdealPrice > 0){
				var IPDiffPer = ((100 * IPDiff)/IdealPrice).toFixed(decimalPlaces);
				if(IPDiffPer < 0){
					IPDiffPer = parseFloat(IPDiffPer) * -1;
					IPDiffPer = '('+IPDiffPer+')';
				}
			}else{
				var IPDiffPer = parseFloat('0').toFixed(decimalPlaces);
			}
			if(IPDiff < 0){
				var IPInfo = '<span class="neg">'+numeral(IPDiff).format( '$('+amtFormat+')' )+'<br>'+IPDiffPer+'%<span>';
			}else{
				var IPInfo = numeral(IPDiff).format( '$('+amtFormat+')' )+'<br>'+IPDiffPer+'%';
			}
			//var IPInfo = numeral(IPDiff).format( '$('+amtFormat+')' )+'<br>'+IPDiffPer+'%';
		}
		$('#'+IPDiffID).html(IPInfo);
		//IDEAL PRICE DOLLAR CALCULATIONS
		var IPDollar = $('#'+Volume).attr("volume") * IPDiff;
			IPDollar = parseFloat(IPDollar).toFixed();
			$('#'+IPDiffDoll).attr("DiffDollar", IPDollar);
			if(IPDollar < 0){
				IPDollar = IPDollar * -1;
				IPDollar = Number(IPDollar).toLocaleString("en-US");
				$('#'+IPDiffDoll).html('<span class="neg"> $('+IPDollar+')</span>');
			}else{
				IPDollar = Number(IPDollar).toLocaleString("en-US");
				$('#'+IPDiffDoll).html('$'+IPDollar);
			}
						//ALLOWANCE CALCULATIONS
		var NewAllowance = parseFloat($('#'+Allowance).attr("rer")) + parseFloat($('#'+Allowance).attr("grr")) + + parseFloat($('#'+Allowance).attr("diffformulaprice"))+ parseFloat($('#'+Allowance).attr("lumpsumamount"))+ (parseFloat($('#'+Allowance).attr("basesales"))-parseFloat(NewPrice))
								$('#'+Allowance_TB).val(NewAllowance.toFixed(decimalPlaces));
								if(NewAllowance < parseFloat('0').toFixed(decimalPlaces)){
									NewAllowance1 = numeral( NewAllowance ).format( '$('+amtFormat+')' )
									$('#'+Allowance).html('<span class="neg">'+NewAllowance1+'</span>');
								}else{
									NewAllowance1 = numeral( NewAllowance ).format( '$('+amtFormat+')' )
									$('#'+Allowance).html(NewAllowance1);
								}

						//ALLOWANCE PERCENTAGE CALCULATIONS
						if(parseFloat($('#'+Allowance).attr("basesales")) == 0){
							var NewAllowancePercentage = 0;
						}else{
							var NewAllowancePercentage = (parseFloat(NewAllowance)/parseFloat($('#'+Allowance).attr("basesales"))) * 100;
						}
						$('#'+AllowancePercentage).html(NewAllowancePercentage.toFixed(2)+' %');

						//NET SALES CALCULATIONS
		<cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
						var NewNetSales = parseFloat($('#'+Allowance).attr("basesales"))  - (parseFloat($('#'+NetSales).attr("basediscount")) + parseFloat(NewAllowance) +  parseFloat($('#'+NetSales).attr("tpaoper")) + parseFloat($('#'+NetSales).attr("tpa")) - parseFloat($('#'+NetSales).attr("pullbackamount")) ) - parseFloat($('#'+NetSales).attr("allowancesurcharges")) - parseFloat($('#'+NetSales).attr("customerfreight")) - parseFloat($('#'+NetSales).attr("otherspend"))
									$('#'+NetSales_TB).val(NewNetSales.toFixed(decimalPlaces));
									//alert(parseFloat($('#'+Allowance).attr("basesales")));
								if(NewNetSales < parseFloat('0').toFixed(decimalPlaces)){
									NewNetSales1 = numeral( NewNetSales ).format( '$('+amtFormat+')' )
									$('#'+NetSales).html('<span class="neg">'+NewNetSales1+'</span>');
								}else{
									NewNetSales1 = numeral( NewNetSales ).format( '$('+amtFormat+')' )
									$('#'+NetSales).html(NewNetSales1);
								}
			<cfelse>
				var NewNetSales ='0'
		</cfif>

						//GROSS MARGIN CALCULATIONS
						var NewGrossMargin = NewNetSales - parseFloat($('#'+GrossMargin).attr("cost")) - parseFloat($('#'+GrossMargin).attr("shuttlefreight")) - parseFloat($('#'+GrossMargin).attr("customwarehouse"));
									$('#'+GrossMargin_TB).val(NewGrossMargin.toFixed(decimalPlaces));
								if(NewGrossMargin < parseFloat('0').toFixed(decimalPlaces)){
									NewGrossMargin1 = numeral( NewGrossMargin ).format( '$('+amtFormat+')' )
									$('#'+GrossMargin).html('<span class="neg">'+NewGrossMargin1+'</span>');
								}else{
									NewGrossMargin1 = numeral( NewGrossMargin ).format( '$('+amtFormat+')' )
									$('#'+GrossMargin).html(NewGrossMargin1);
								}

						//CONTRIBUTION MARGIN CALCULATIONS
						var NewContributionMargin = parseFloat(NewGrossMargin) - parseFloat($('#'+ContributionMargin).attr("CustomBrokerage"));
									$('#'+ContributionMargin_TB).val(NewContributionMargin.toFixed(decimalPlaces));
								if(NewContributionMargin < parseFloat('0').toFixed(decimalPlaces)){
									NewContributionMargin1 = numeral( NewContributionMargin ).format( '$('+amtFormat+')' )
									$('#'+ContributionMargin).html('<span class="neg">'+NewContributionMargin1+'</span>');
								}else{
									NewContributionMargin1 = numeral( NewContributionMargin ).format( '$('+amtFormat+')' )
									$('#'+ContributionMargin).html(NewContributionMargin1);
								}

						//VARIABLE CONTRIBUTION MARGIN CALCULATIONS
						var NewVariableCM = parseFloat(NewContributionMargin) + parseFloat($('#'+VariableCM).attr("FixedCost"));
								$('#'+VariableCM_TB).val(NewVariableCM.toFixed(decimalPlaces));
								if(NewVariableCM < parseFloat('0').toFixed(decimalPlaces)){
									NewVariableCM1 = numeral( NewVariableCM ).format( '$('+amtFormat+')' )
									$('#'+VariableCM).html('<span class="neg">'+NewVariableCM1+'</span>');
								}else{
									NewVariableCM1 = numeral( NewVariableCM ).format( '$('+amtFormat+')' )
									$('#'+VariableCM).html(NewVariableCM1);
								}

						//OPERATING INCOME CALCULATIONS
						var NewOperatingIncome = parseFloat(NewContributionMargin) - parseFloat($('#'+OPRIncome).attr("MapMdf")) - parseFloat($('#'+OPRIncome).attr("SGA"));
									$('#'+OPRIncome_TB).val(NewOperatingIncome.toFixed(decimalPlaces));
								if(NewOperatingIncome < parseFloat('0').toFixed(decimalPlaces)){
									NewOperatingIncome1 = numeral( NewOperatingIncome ).format( '$('+amtFormat+')' )
									$('#'+OPRIncome).html('<span class="neg">'+NewOperatingIncome1+'</span>');
								}else{
									NewOperatingIncome1 = numeral( NewOperatingIncome ).format( '$('+amtFormat+')' )
									$('#'+OPRIncome).html(NewOperatingIncome1);
								}

						//OPERATING INCOME PERCENTAGE CALCULATIONS
						if(<cfoutput>#appSettings.getApprovalMarginType()#</cfoutput> == 0 && <cfoutput>#appSettings.getMarginOperatingIncomePercentType()#</cfoutput> == 2) {
							if(parseFloat($('#'+Allowance).attr("basesales")) !=  0 ){
								var OperatingMargin_percent = (NewOperatingIncome /parseFloat($('#'+Allowance).attr("basesales"))) * 100.00
								if (parseFloat($('#'+Allowance).attr("basesales")) < 0 && NewOperatingIncome <0) {
										OperatingMargin_percent = OperatingMargin_percent * -1;
								}
						}else{
							if( parseFloat($('#'+Allowance).attr("netsales")) != 0){
								var OperatingMargin_percent = (NewOperatingIncome  /parseFloat($('#'+Allowance).attr("netsales"))) * 100.00
								if (parseFloat(NewNetSales) < 0 && NewOperatingIncome <0){
									OperatingMargin_percent = OperatingMargin_percent * -1;
								}
							}
						}
						$('#'+OPRIncomePer).html(OperatingMargin_percent.toFixed(2)+' %');
					}

					//TRADE SPEND CALCULATIONS
					var NewTradeSpend = parseFloat(NewAllowance) * parseFloat($('#'+Volume).attr("volume"));
								$('#'+TradeSpend_TB).val(NewTradeSpend.toFixed(decimalPlaces));
							if(NewTradeSpend < parseFloat('0').toFixed(decimalPlaces)){
								NewTradeSpend1 = numeral( NewTradeSpend ).format( '$('+amtFormat+')' )
								$('#'+TradeSpend).html('<span class="neg">'+NewTradeSpend1+'</span>');
							}else{
								NewTradeSpend1 = numeral( NewTradeSpend ).format( '$('+amtFormat+')' )
								$('#'+TradeSpend).html(NewTradeSpend1);
							}

								TypeCodeCalculation(typ, TypeCode);
	}

	function TypeCodeCalculation(typ, TypeCode){
		var decimalPlaces = <cfoutput>#decimal_places#</cfoutput>;
				//TYPE CODE FORM FIELDS
		var TypeCodeAllowance = TypeCode+'_TypeCode_Allowance';
		var TypeCodeAllowancePer = TypeCode+'_TypeCode_AllowancePer';
		var TypeCodeNetSales = TypeCode+'_TypeCode_Net_Sales';
		var TypeCodeGrossMargin = TypeCode+'_TypeCode_Gross_Margin';
		var TypeCodeContributionMargin = TypeCode+'_TypeCode_Contribution_Margin';
		var TypeCodeVariableContributionMargin = TypeCode+'_TypeCode_Variable_Contribution_Margin';
		var TypeCodeOprIncome = TypeCode+'_TypeCode_Opr_Income';
		var TypeCodeOprMarginPercentage = TypeCode+'_TypeCode_Opr_Margin_Percentage';
		var TypeCodeTradeSpend = TypeCode+'_TypeCode_Trade_Spend';
		var TypeCodeDollars = TypeCode+'_TypeCode_Dollars';

		var TCItemCount = $('input[name='+TypeCode+']').val();
		var TotalAllowance = 0;
		var TotalAllowancePercentage = 0;
		var TotalVolume = 0;
		var TotalLSAmount = 0;
		var TotalBaseSales = 0;
		var TotalNetSales = 0;
		var TotalGrossMargin = 0;
		var TotalContributionMargin = 0;
		var TotalVariableContributionMargin = 0;
		var TotalOperationgIncome = 0;
		var TotalOperationgIncomePer=0;
		var OIP = 0;
		var TotalTradeSpend = 0;
		var TotalDiffDollars = 0;
		var amtFormat = parseFloat('0').toFixed(decimalPlaces);

			for(i=1;i<=TCItemCount;i++){
				var id= TypeCode+'_'+i;
				var BSATc = $('#'+id).attr("tcid");

			if(BSATc == TypeCode){
					var BSAID = $('#'+id).attr("bsaid");
					var Allowance = BSAID+'_Allowance_TB'; // WE USE TEXTBOX TO ASSIGN AND RETRIVE NEW ALLOWANCE WHICH CALCULATED
					var NetSales = BSAID+'_Net_Sales_TB';
					var GrossMargin = BSAID+'_Gross_Margin_TB';
					var ContributionMargin = BSAID+'_Contribution_Margin_TB';
					var VariableCM = BSAID+'_Variable_Contribution_Margin_TB';
					var OPRIncome = BSAID+'_Operating_Income_TB';
					var OPRIncomePer = BSAID+'_Operating_Margin_percent';
					var TradeSpend = BSAID+'_Trade_Spent_TB';
					var Volume = parseFloat($('#'+BSAID+'_Volume').attr("Volume"));
					var BaseSales = parseFloat($('#'+BSAID+'_Allowance').attr("basesales"));
					var NetSales = parseFloat($('#'+BSAID+'_Allowance').attr("netsales"));
					var IPDollar = parseFloat($('#'+BSAID+'_IPDiffDoll').attr("diffdollar"));

					TotalVolume = parseFloat(TotalVolume) + Volume;
					TotalDiffDollars = parseFloat(TotalDiffDollars) + IPDollar;

			//TYPE CODE ALLOWANCE CALCULATIONS
			//(ISNULL(SUM((LumpsumAmount+Item_Allowance)*Product_Program_Volume),0) / SUM(Product_Program_Volume))
				TotalAllowance =	parseFloat(TotalAllowance) + (parseFloat( $('#'+BSAID+'_Allowance').attr("lumpsumamount") ) + parseFloat($('#'+Allowance).val())) * Volume;

				//TYPE CODE ALLOWANCE PERCENTAGE CALCULATIONS
				//Total_Allowance_Percent = (TotalAllowance/Total_Base_Sales) * 100
				TotalBaseSales = parseFloat(TotalBaseSales) + ( BaseSales * Volume);

				//TYPE CODE NET SALES CALCULATIONS
				//ISNULL(SUM(Product_Program_Volume * Net_Sales),0)/SUM(Product_Program_Volume)
				<cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
					TotalNetSales = parseFloat(TotalNetSales)  + ( Volume * NetSales );
				<cfelse>
					TotalNetSales = '0';
				</cfif>

				//TYPE CODE GROSS MARGIN CALCULATIONS
				//SUM(GrossMargin * Volume),0) / SUM(Volume)
				TotalGrossMargin = parseFloat(TotalGrossMargin) + ( Volume * parseFloat( $('#'+GrossMargin).val() ) );

				//TYPE CODE CONTRIBUTION MARGIN CALCULATIONS
				//SUM(ContributionMargin * Volume),0) / SUM(Volume)
				TotalContributionMargin = parseFloat(TotalContributionMargin) + ( Volume * parseFloat( $('#'+ContributionMargin).val() ) );

				//TYPE CODE VARIABLE CONTRIBUTION MARGIN CALCULATIONS
				//SUM(VariableCM * Volume),0) / SUM(Volume)
				TotalVariableContributionMargin = parseFloat(TotalVariableContributionMargin) + ( Volume * parseFloat( $('#'+VariableCM).val() ) );

				//TYPE CODE OPERATING INCOME CALCULATIONS
				//ISNULL(SUM(Product_Program_Volume*Operating_Income),0)/SUM(Product_Program_Volume)
				TotalOperationgIncome = parseFloat(TotalOperationgIncome) + (Volume * parseFloat($('#'+OPRIncome).val()));

				//TYPE CODE OPERATING INCOME PERCENTAGE CALCULATIONS
				if( <cfoutput>#application.appSettingsGet.getMarginOperatingIncomePercentType()#</cfoutput> == 2){
					if( BaseSales == 0 || Volume == 0 ){
						TotalOperationgIncomePer =  parseFloat(TotalOperationgIncomePer) + 0;
					}else{
						OIP = OIP + ( (Volume * parseFloat($('#'+OPRIncome).val()) ) / (Volume * BaseSales) );
						TotalOperationgIncomePer = parseFloat(TotalOperationgIncomePer) + OIP
					}
				}else{
					if( NetSales == 0 || Volume == 0 ){
						TotalOperationgIncomePer =  parseFloat(TotalOperationgIncomePer) + 0;
					}else{
						OIP = OIP + ( ( Volume * parseFloat($('#'+OPRIncome).val())) / (Volume * NetSales) );
						TotalOperationgIncomePer = parseFloat(TotalOperationgIncomePer) + OIP;
					}
				}

				//TYPE CODE TRADE SPEND CALCULATIONS
				// TotalTradeSpend = Total_Item_Allowance * round(Total_Product_Program_Volume)>
				TotalTradeSpend = parseFloat(TotalTradeSpend) + ( parseFloat(TotalAllowance) * Volume );
		}
	}
	//TO PREVENT DIVISON BY 0 ISSUE
	if(! TotalVolume){
		TotalVolume = 1;
	}
	if(! TotalBaseSales){
		TotalBaseSales = 1;
	}
			//TYPE CODE DOLLARS UPDATE
			if(TotalDiffDollars< parseFloat('0').toFixed(decimalPlaces)){
				NewTotalDiffDollars = numeral( TotalDiffDollars ).format( '$(0,0)' )
				$('#'+TypeCodeDollars).html('<span class="neg">'+NewTotalDiffDollars+'</span>');
			}else{
				NewTotalDiffDollars = numeral( TotalDiffDollars ).format( '$(0,0)' )
				$('#'+TypeCodeDollars).html(NewTotalDiffDollars);
			}
		//TYPE CODE ALLOWANCE UPDATE
		if((TotalAllowance/TotalVolume) < parseFloat('0').toFixed(decimalPlaces)){
			NewTypeCodeAllowance = numeral( TotalAllowance/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeAllowance).html('<span class="neg">'+NewTypeCodeAllowance+'</span>');
		}else{
			NewTypeCodeAllowance = numeral( TotalAllowance/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeAllowance).html(NewTypeCodeAllowance);
		}
		//TYPE CODE ALLOWANCE PERCENTAGE  UPDATE
		$('#'+TypeCodeAllowancePer).html(((TotalAllowance/TotalBaseSales)*100).toFixed(2)+' %');
		<cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
		//TYPE CODE NET SALES UPDATE
		if((TotalNetSales/TotalVolume) < parseFloat('0').toFixed(decimalPlaces)){
			NewTypeCodeNetSales = numeral( TotalNetSales/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeNetSales).html('<span class="neg">'+NewTypeCodeNetSales+'</span>');
		}else{
			NewTypeCodeNetSales = numeral( TotalNetSales/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeNetSales).html(NewTypeCodeNetSales);
		}
		</cfif>
		//TYPE CODE GROSS MARGIN UPDATE
		if((TotalGrossMargin/TotalVolume) < parseFloat('0').toFixed(decimalPlaces)){
			NewTypeGrossMargin = numeral( TotalGrossMargin/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeGrossMargin).html('<span class="neg">'+NewTypeGrossMargin+'</span>');
		}else{
			NewTypeGrossMargin = numeral( TotalGrossMargin/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeGrossMargin).html(NewTypeGrossMargin);
		}
		//TYPE CODE CONTRIBUTION MARGIN UPDATE
		if((TotalContributionMargin/TotalVolume) < parseFloat('0').toFixed(decimalPlaces)){
			NewTotalContributionMargin = numeral( TotalContributionMargin/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeContributionMargin).html('<span class="neg">'+NewTotalContributionMargin+'</span>');
		}else{
			NewTotalContributionMargin = numeral( TotalContributionMargin/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeContributionMargin).html(NewTotalContributionMargin);
		}
		//TYPE CODE VARIABLE CONTRIBUTION MARGIN UPDATE
		if((TotalVariableContributionMargin/TotalVolume) < parseFloat('0').toFixed(decimalPlaces)){
			NewTotalVariableContributionMargin = numeral( TotalVariableContributionMargin/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeVariableContributionMargin).html('<span class="neg">'+NewTotalVariableContributionMargin+'</span>');
		}else{
			NewTotalVariableContributionMargin = numeral( TotalVariableContributionMargin/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeVariableContributionMargin).html(NewTotalVariableContributionMargin);
		}
		//TYPE CODE OPERATING INCOME UPDATE
		if((TotalOperationgIncome/TotalVolume) < parseFloat('0').toFixed(decimalPlaces)){
			NewOperatingIncome = numeral( TotalOperationgIncome/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeOprIncome).html('<span class="neg">'+NewOperatingIncome+'</span>');
		}else{
			NewOperatingIncome = numeral( TotalOperationgIncome/TotalVolume ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeOprIncome).html(NewOperatingIncome);
		}
		//TYPE CODE OPERATING INCOME PERCENTAGE  UPDATE
		$('#'+TypeCodeOprMarginPercentage).html((TotalOperationgIncomePer).toFixed(2)+' %');
		//TYPE CODE TRADE SPEND UPDATE
		if(TotalTradeSpend < parseFloat('0').toFixed(decimalPlaces)){
			NewTradeSpend = numeral( TotalTradeSpend ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeTradeSpend).html('<span class="neg">'+NewTradeSpend+'</span>');
		}else{
			NewTradeSpend = numeral( TotalTradeSpend ).format( '$('+amtFormat+')' )
			$('#'+TypeCodeTradeSpend).html(NewTradeSpend);
		}


			PrgSummary();

	}

function PrgSummary() {
	var PrgRateSummary_Allowance = 0;
	var PrgRateSummary_Net_Sales = 0;
	var PrgRateSummary_Gross_Margin = 0;
	var PrgRateSummary_Contribution_Margin = 0;
	var PrgRateSummary_Variable_Contribution_Margin = 0;
	var PrgRateSummary_Operating_Income = 0;
	var PrgRateSummary_Operating_IncomePer = 0;

	var PrgABSummary_Allowance = 0;
	var PrgABSummary_Net_Sales = 0;
	var PrgABSummary_Gross_Margin = 0;
	var PrgABSummary_Contribution_Margin = 0;
	var PrgABSummary_Variable_Contribution_Margin = 0;
	var PrgABSummary_Operating_Income = 0;
	var PrgABSummary_Operating_IncomePer = 0;
	var PrgABSummary_Dollars = 0;

	var decimalPlaces = <cfoutput>#decimal_places#</cfoutput>;
	var TotalProgramVolume = parseFloat($('#PrgRateSummary_Allowance').attr("TotalProgramVolume"));
	var Lumpsum_Amount = parseFloat($('#PrgRateSummary_Allowance').attr("LumpsumAmount"));
 	var TotalBaseSale = parseFloat($('#PrgRateSummary_Allowance').attr("TotalBaseSales"));

	var addExtra = 0;
	var addExtra1 = 0;
	var PrgSummary_Operating_Margin_percent= 0;
	var OIP = 0;
	var PrgSummary_Trade_Spent = 0;

	$('#GridView1 > tbody  > tr.GridViewScrollItem').each(function(index, tr) {
			var id = this.id;
			var TypeCode = $('#'+id).attr("tcid");
			var bsaid = $('#'+id).attr("bsaid");
			var Volume = parseFloat($('#'+bsaid+'_Volume').attr("Volume"));

if(TypeCode != undefined){
			if(<cfoutput>#application.appSettingsGet.getApprovalMarginType()#</cfoutput>  == 2){
				PrgRateSummary_Allowance = PrgRateSummary_Allowance + (Volume * parseFloat($('#'+bsaid+'_Allowance').attr("AnnualizedAllowance")) );
			}else{
				PrgRateSummary_Allowance = PrgRateSummary_Allowance + (Volume * parseFloat($('#'+bsaid+'_Allowance').attr("ItemAllowance")) );
			}

			PrgRateSummary_Net_Sales = PrgRateSummary_Net_Sales + (Volume * parseFloat($('#'+bsaid+'_Allowance').attr("netsales")) );
			PrgRateSummary_Gross_Margin = PrgRateSummary_Gross_Margin + (Volume * parseFloat( $('#'+bsaid+'_Gross_Margin_TB').val() ) );
			PrgRateSummary_Contribution_Margin = PrgRateSummary_Contribution_Margin + (Volume * parseFloat( $('#'+bsaid+'_Contribution_Margin_TB').val() ) );
			PrgRateSummary_Variable_Contribution_Margin = PrgRateSummary_Variable_Contribution_Margin + (Volume * parseFloat( $('#'+bsaid+'_Variable_Contribution_Margin_TB').val() ) );
			PrgRateSummary_Operating_Income = PrgRateSummary_Operating_Income + (Volume * parseFloat($('#'+bsaid+'_Operating_Income_TB').val()));

			PrgABSummary_Dollars = PrgABSummary_Dollars + parseFloat($('#'+bsaid+'_IPDiffDoll').attr("diffdollar"));

			if( <cfoutput>#application.appSettingsGet.getMarginOperatingIncomePercentType()#</cfoutput> == 2){
					if($('#'+bsaid+'_Allowance').attr("basesales") == 0){
						PrgSummary_Operating_Margin_percent =  parseFloat(PrgSummary_Operating_Margin_percent) + 0;
					}else{
						OIP = OIP + ( (Volume * parseFloat($('#'+bsaid+'_Operating_Income_TB').val()) ) / (Volume *parseFloat($('#'+bsaid+'_Allowance').attr("basesales"))) );
						PrgSummary_Operating_Margin_percent = parseFloat(PrgSummary_Operating_Margin_percent) + OIP
					}
				}else{
					if($('#'+bsaid+'_Allowance').attr("netsales") == 0){
						PrgSummary_Operating_Margin_percent =  parseFloat(PrgSummary_Operating_Margin_percent) + 0;
					}else{
						OIP = OIP + ( ( Volume * parseFloat($('#'+bsaid+'_Operating_Income_TB').val())) / (Volume *parseFloat($('#'+bsaid+'_Allowance').attr("netsales"))) );
						PrgSummary_Operating_Margin_percent = parseFloat(PrgSummary_Operating_Margin_percent) + OIP;
					}
				}
			PrgSummary_Trade_Spent = PrgSummary_Trade_Spent + ( parseFloat(PrgRateSummary_Allowance) *Volume ); ///???? CHECK WITH DEEPA REGARDING VARIABLE "PrgRateSummary_Allowance"
			}
	});
	// TO PREVENT DIVISION BY 0 ISSUE
if(! TotalBaseSale){
	TotalBaseSale = 1;
}
if(! TotalProgramVolume){
	TotalProgramVolume= 1;
}
				//PROGRAM SUMMARY ALLOWANCE CALCULATIONS
				//RATE
				if (TotalProgramVolume != "" && TotalProgramVolume != 0){
					var addExtra = Lumpsum_Amount / parseFloat(TotalProgramVolume);
				}
				//ABS
				if (<cfoutput>#ProgramVolume_For_Program_Span#</cfoutput> != "" && <cfoutput>#ProgramVolume_For_Program_Span#</cfoutput> != 0){
					var addExtra1 = Lumpsum_Amount / <cfoutput>#ProgramVolume_For_Program_Span#</cfoutput>;
				}

				if(<cfoutput>#form.Margin_Type# == 1 || #form.margin_type# == 3</cfoutput>){
					PrgRateSummary_Allowance = ( (parseFloat(PrgRateSummary_Allowance)  + parseFloat(addExtra)) /  parseFloat(TotalProgramVolume)  ) ;
					PrgABSummary_Allowance = ( ( parseFloat(PrgABSummary_Allowance)   +  parseFloat(addExtra)) * parseFloat(TotalProgramVolume)  )
				}else{
					PrgRateSummary_Allowance =  parseFloat(PrgRateSummary_Allowance) / parseFloat(TotalProgramVolume)  ;
					PrgABSummary_Allowance = (parseFloat(PrgABSummary_Allowance)  * parseFloat(TotalProgramVolume)  );
				}

				$('#PrgRateSummary_Allowance').html('$ ' +PrgRateSummary_Allowance.toFixed(decimalPlaces));
				$('#PrgABSummary_Allowance').html('$ ' +PrgABSummary_Allowance.toFixed(decimalPlaces));

				$('#PrgRateSummary_Allowance_Per').html(((PrgRateSummary_Allowance/TotalBaseSale) * 100).toFixed(2)+ ' %');

				$('#PrgRateSummary_Net_Sales').html('$ ' +(PrgRateSummary_Net_Sales / TotalProgramVolume ).toFixed(decimalPlaces));
				$('#PrgABSummary_Net_Sales').html('$ ' +(PrgRateSummary_Net_Sales * TotalProgramVolume ).toFixed(decimalPlaces));

				$('#PrgRateSummary_Gross_Margin').html('$ ' +(PrgRateSummary_Gross_Margin / TotalProgramVolume ).toFixed(decimalPlaces) );
				$('#PrgABSummary_Gross_Margin').html('$ ' +(PrgRateSummary_Gross_Margin * TotalProgramVolume ).toFixed(decimalPlaces) );

				$('#PrgRateSummary_Contribution_Margin').html('$ ' +(PrgRateSummary_Contribution_Margin / TotalProgramVolume ).toFixed(decimalPlaces) );
				$('#PrgABSummary_Contribution_Margin').html('$ ' +(PrgABSummary_Contribution_Margin * TotalProgramVolume ).toFixed(decimalPlaces) );

				$('#PrgRateSummary_Variable_Contribution_Margin').html('$ ' +(PrgRateSummary_Variable_Contribution_Margin / TotalProgramVolume ).toFixed(decimalPlaces) );
				$('#PrgABSummary_Variable_Contribution_Margin').html('$ ' +(PrgABSummary_Variable_Contribution_Margin * TotalProgramVolume ).toFixed(decimalPlaces) );

				$('#PrgRateSummary_Operating_Income').html('$ ' +PrgRateSummary_Operating_Income.toFixed(decimalPlaces) );
				$('#PrgABSummary_Operating_Income').html('$ ' +(PrgABSummary_Operating_Income * TotalProgramVolume ).toFixed(decimalPlaces) );
				
				//$('#PrgABSummary_Dollars').html('$ ' +PrgABSummary_Dollars.toFixed() );
				if(PrgABSummary_Dollars < parseFloat('0').toFixed()){
					PrgABSummary_Dollars = numeral( PrgABSummary_Dollars ).format( '$(0,0)' )
					$('#PrgABSummary_Dollars').html('<span class="neg">'+PrgABSummary_Dollars+'</span>');
				}else{
					PrgABSummary_Dollars = numeral( PrgABSummary_Dollars ).format( '$(0,0)' )
					$('#PrgABSummary_Dollars').html(PrgABSummary_Dollars);
				}

				if( <cfoutput>#application.appSettingsGet.getMarginOperatingIncomePercentType()#</cfoutput> == 2){/// Use Base Sales
					PrgRateSummary_Operating_IncomePer = ( parseFloat(TotalProgramVolume) * parseFloat(PrgRateSummary_Operating_Income) / parseFloat(TotalProgramVolume) * parseFloat(TotalBaseSale) )*100;
				}else{
					PrgRateSummary_Operating_IncomePer = ( parseFloat(TotalProgramVolume) * parseFloat(PrgRateSummary_Operating_Income) / parseFloat(TotalProgramVolume) * parseFloat(PrgRateSummary_Net_Sales) )*100;
				}
				$('#PrgRateSummary_Operating_IncomePer').html(PrgRateSummary_Operating_IncomePer.toFixed(2) +' %' );
}
//114617 :: Ideal Price END

	//function to add commas to a given string -  TODO: Put this in a .js file where it can be accessed everywhere
	function FormatTextWithCommas(oText) {
		var nf = new NumberFormat();
		nf.setNumber(oText);
		nf.setCommas(true);
		nf.setCurrency(false);
		nf.setPlaces(0);
		return nf.toFormatted()
	}
	<!--- Dev Note: KAL; D21684: Functionality of View Margins Screen: To Toggle previous margin displays --->
	togglePreviousView = function(objName){
		obj1 = 'previous_rate_' + objName
		obj2 = 'previous_dollar_' + objName
		obj3 = 'variance_rate_' + objName
		obj4 = 'variance_dollar_' + objName
		Effect.toggle(obj1, 'slide', { duration: .100 });
		Effect.toggle(obj2, 'slide', { duration: .100 });
		Effect.toggle(obj3, 'slide', { duration: .100 });
		Effect.toggle(obj4, 'slide', { duration: .100 });
	}
	<!--- Dev Note: KAL; D23601: Margin Items Exclude To Toggle the display --->
	toggleProdExcludeView = function(){
		/* Regular JS Code */
		var cellObject = document.getElementsByTagName("tr");

		/*Loop through the "<tr>" object. Look for specific "id" (below)*/
		for(i=0;i<cellObject.length;i++){
			if (cellObject[i].getAttribute('id') == 'excludeditems') {
			if (cellObject[i].style.display =='block' || cellObject[i].style.display == '')  {
				cellObject[i].style.display='none';
			}else{
				cellObject[i].style.display='block';
			}
			}
		}
	}

  </script>
  <cf_include files="/script/javascript/string_functions.js">
</cffunction>		<!--- <cffunction name="verticalPNL"> --->
<cffunction name="sanitize_input" output="false" hint="Clean up extra characters in a numeric input">
	<cfargument name="formatted_number" required="true">

	<cfif isEditing.recordCount eq 0>
		<cfreturn application.util.string.stripHTML(arguments.formatted_number)>
	<cfelse>
		<!--- strip out dollar sign --->
		<cfset local.result = replace(arguments.formatted_number, "$", "")>

		<!--- handle negative number --->
		<cfif local.result contains "neg">
			<!--- strip out span tags --->
			<cfset local.result = application.util.string.stripHTML(local.result)>
			<!--- strip out parentheses --->
			<cfset local.result = "-" & replace( replace(local.result, "(", ""), ")", "" )>
		</cfif>
		<cfreturn local.result>
	</cfif>

</cffunction>

<cffunction name="neg_css" output="false">
	<cfargument name="formatted_number" required="true">

	<cfreturn arguments.formatted_number contains "neg" ? "neg" : "">
</cffunction>
<cffunction name="numberFormatValue" output="false" hint="Returns negative CSS inline style and input value">
    <cfargument name="value" required="true">
    <cfargument name="decimalplaces" required="false">

    <cfscript>
        if ( arguments.value eq '' ) {
            return arguments.value;
        }

        if ( isDefined("arguments.decimalplaces") eq false ) {
            arguments.decimalplaces = request.dollar_format;
        }

        return ( arguments.value lt 0
                    ? "style='color:red;'"
                    : '' )
                 & "value='"
                 & numberFormat(arguments.value, arguments.decimalplaces)
                 & "'";
    </cfscript>
</cffunction>




<cffunction name="layered_margin_program_rate_summary" output="true">
    <cfset TotalProgramVolume = qProgramSummaryMargins.totalprogramvolume />
    <cfoutput>
      <!------ Annual/Program Summary : Rate / UOM start ----->
      <tr class="GridViewScrollItem" valign="middle">
        <td align="left" class="header 4765"><strong>Rate / #displayUOM#</strong></td>
				<cfif getProgramInfo.Ideal_Price>
					<td align="left" class="header 4765">&nbsp;</td>
					<td align="left" class="header 4765">&nbsp;</td>
					<td align="left" class="header 4765">&nbsp;</td>
				</cfif>
            <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
          <cfif variables.bDisplayContractPrice>
          <!--- 16314 [begin] --->
                <td class="4769">&nbsp;</td>
                <!--- 16314 [end] --->
            </cfif>
            <!--- 17289 > 16314 follow up 10/14/08 [end] --->
        <cfif Get_Profile_Settings.Base_View EQ 1>
          <cfset data = makeNumeric(TotalProgramVolume) />


          <td align="right" nowrap class="4777">
            <cfif	((TotalProgramVolume GT AnnualVolume_CS) and TRIM(AnnualVolume_CS) NEQ "*")
              or	((TotalProgramVolume LT MinVolume_CS)	and TRIM(MinVolume_CS) NEQ "*")>
              <IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
                onmouseover="initTheTooltip('Volume not within your approval limits.')"
                onmouseout="popOut()"
                align="absmiddle" />
            </cfif>
            #trim(numberformat(data,"___,___,___,___,___,___-__"))#
          </td>

          <cfset data = makeNumeric(qProgramSummaryMargins.Total_BaseSales) />

          <td align="right" nowrap class="4790">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />

          <cfif margin_display_style eq "custom_t">
            <!--- ALlow/Surch --->
            <cfset data = makeNumeric(qProgramSummaryMargins.Total_Allowance_Surcharges) />

              <td align="right" nowrap class="4797">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
              <cfset colCount = colCount + 1 />

            <!--- Customer Freight --->
            <cfset data = makeNumeric(qProgramSummaryMargins.Total_Customer_Freight) />

              <td align="right" nowrap class="4803">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
              <cfset colCount = colCount + 1 />
          </cfif>

          <cfif direct_pricing EQ 0>
            <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
            <!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
            <cfif appsettings.getDisplayCashDiscountMargin() eq 1>
              <cfset data = makeNumeric(qProgramSummaryMargins.Total_Cash_Discount) />

              <td align="right" nowrap class="4813">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
              <cfset colCount = colCount + 1 />
            </cfif>
            <!--- Allowance --->
            <cfparam name="addExtra" default="0">
            <cfif TotalProgramVolume neq "" and TotalProgramVolume neq 0>
              <cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/TotalProgramVolume) />
            </cfif>

            <cfif form.Margin_Type EQ 1 OR form.margin_type EQ 3>
              <cfset data = makeNumeric(qProgramSummaryMargins.TOTAL_Allowance) + addExtra />
            <cfelse>
              <cfset data = makeNumeric(qProgramSummaryMargins.TOTAL_Allowance) />
            </cfif>


            <td align="right" nowrap class="4829" id="PrgRateSummary_Allowance"  LumpsumAmount="#getProgramLumpsum.Lumpsum_Amount#" TotalProgramVolume="#TotalProgramVolume#" TotalBaseSales ="#application.util.string.cellFormat(value=qProgramSummaryMargins.Total_BaseSales ,decimalplaces = request.nondollar_format)#">
							#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#
						</TD>
            <cfset colCount = colCount + 1 />


            <!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
            <!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Allowance". --->
            <td align="right" nowrap class="4835" id="PrgRateSummary_Allowance_Per" >
              <cfif data EQ 0 OR qProgramSummaryMargins.Total_BaseSales EQ 0>
                N/A
              <cfelseif data LT 0>
                0%
              <cfelse>
              <cfset Total_Allowance_Rate_Percent = (data/qProgramSummaryMargins.Total_BaseSales) * 100>
                #application.util.string.cellFormat(value=Total_Allowance_Rate_Percent ,decimalplaces = request.numeric_format)# %
              </cfif>
            </td>
            <cfset colCount = colCount + 1 />
          </cfif>

          <cfif ShowTPA EQ 1>
            <cfif margin_display_style eq "custom_t">
              <!--- TPA Operator --->
              <cfset data = makeNumeric(qProgramSummaryMargins.Total_TPA_Oper) />
              <td align="right" nowrap class="4852">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
              <cfset colCount = colCount + 1 />
            </cfif>

            <!--- TPA Distributor (Distributor Trade) --->
            <cfset data = makeNumeric(qProgramSummaryMargins.Total_TPA) />

            <td align="right" nowrap class="4859">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
            <cfset colCount = colCount + 1 />
          </cfif>

          <cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
            <cfset data = makeNumeric(qProgramSummaryMargins.Total_pullbackamount) />

            <td align="right" class="4866" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
            <cfset colCount = colCount + 1 />
          </cfif>

          <cfif margin_display_style eq "custom_t">
            <!--- Other Spend --->
            <cfset data = makeNumeric(qProgramSummaryMargins.Total_Other_Spend) />

            <td align="right" class="4874" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
            <cfset colCount = colCount + 1 />
          </cfif>

          <!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
					<!--- Net Sales --->
          <cfif appSettings.getApprovalMarginType() eq 0>
            <cfset data = makeNumeric(qProgramSummaryMargins.TOTAL_NetSales) />

            <td align="right" class="4882" nowrap id="PrgRateSummary_NetSales">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
            <cfset colCount = colCount + 1 />
          </cfif>
        </cfif>

        <cfif Get_Profile_Settings.View_Cost EQ 1>
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_Cost) />

          <td align="right" class="4890" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />
        </cfif>

        <cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_Brokerage) />

          <td align="right" class="4897" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />
        </cfif>

        <cfif margin_display_style eq "custom_t">
          <!--- Shuttle Freight --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_shuttle_freight) />

          <td align="right" nowrap class="4905">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />

          <!--- Warehouse --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_Custom_Warehouse) />

          <td align="right" nowrap class="4911">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />

          <!--- Gross Margin --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_Gross_Margin) />
          <td align="right" nowrap class="4917" id="PrgRateSummary_Gross_Margin">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />

          <!--- Brokerage --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_Custom_Brokerage) />
          <td align="right" nowrap class="4923">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />

          <!--- Contribution Margin --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_Contribution_Margin_Alt) />

          <td align="right" nowrap class="4929" id="PrgRateSummary_Contribution_Margin">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />

          <!--- Variable Contribution Margin --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_Variable_Contribution_Margin) />
          <td align="right" nowrap class="4935" id="PrgRateSummary_Variable_Contribution_Margin">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />

          <!--- MAP and MDF --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_Map_Mdf) />
          <td align="right" nowrap class="4941">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />

          <!--- SG & A --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_SGA) />
          <td align="right" nowrap class="4947">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />
        </cfif>
				<!--- Operating Income --->
        <cfif Get_Profile_Settings.View_Operating_Income EQ 1>
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_OprIncome) />
          <td align="right" nowrap class="4954" id="PrgRateSummary_Operating_Income">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />
        </cfif>

        <cfif Get_Profile_Settings.View_Target_Margins EQ 1 AND (appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1)>
          <cfif appSettings.getApprovalMarginType() eq 2>
          <!--- Annual Case Rate --->
          <td align="right" nowrap class="4962">
            <cfset data = makeNumeric(qProgramSummaryMargins.Total_TradeAmt) />
            #application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#
          </td>
          <cfelse>
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_OprMargin) />

          <td align="right" nowrap class="4970" id="PrgRateSummary_Operating_IncomePer">
            <cfif (qProgramSummaryMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*" and ignoreOperatingMarginCheck EQ 0>
              <IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
                onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')"
                onmouseout="popOut()"
                align="absmiddle">
            </cfif>
            #application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %
          </td>
          </cfif>
        </cfif>
      <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
      <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1' AND appSettings.getapprovalLayeredCosts() EQ 2>

        <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_OprIncome) - makeNumeric(qProgramSummaryMargins.Total_Fixed_Mfg_Cost)/>
        <cfelse>
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_OprIncome) + makeNumeric(qProgramSummaryMargins.Total_Fixed_Mfg_Cost)/>
        </cfif>

        <td align="right" nowrap class="4990">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

        <cfset variables.Total_Net_Sales = qProgramSummaryMargins.Total_NetSales>
        <cfif len(variables.Total_Net_Sales) EQ 0 OR variables.Total_Net_Sales EQ 0>
          <cfset variables.Total_Net_Sales = 1>
        </cfif>
        <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
          <cfset data = ((makeNumeric(qProgramSummaryMargins.Total_OprIncome) - makeNumeric(qProgramSummaryMargins.Total_Fixed_Mfg_Cost))/makeNumeric(variables.Total_Net_Sales)) * 100/>
        <cfelse>
          <cfset data = ((makeNumeric(qProgramSummaryMargins.Total_OprIncome) + makeNumeric(qProgramSummaryMargins.Total_Fixed_Mfg_Cost))/makeNumeric(variables.Total_Net_Sales)) * 100/>
        </cfif>
        <cfset data = #trim(numberformat(round(data),'_-___,___,___,___,___'))#>
        <td align="right" nowrap class="5002">#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
      </cfif>
      <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
      <cfif Get_Profile_Settings.View_Target_Margins eq 1>
      	<!--- <td class="5006">#img_1010#</td>
      	<td class="5007">#img_1010#</td> --->
      </cfif>
        <!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
        <cfif appSettings.getApprovalMarginType() eq 1>
          <!--- Trade CS --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_TradeAmt) />

          <td align="right" nowrap class="5014">#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
          <cfset colCount = colCount + 1 />
          <!--- Trade Percent --->
          <cfset data = makeNumeric(qProgramSummaryMargins.Total_TradePercent) />

          <td align="right" nowrap class="5019">#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</TD>
        </cfif>
        <!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
        <cfif Get_Profile_Settings.Base_View EQ 1>
          <!--- ngt <td class="5023">&nbsp;</td>  leave the trade spend field blank for the rate/uom row, instead it will be displayed in the absolute $ row --->
        </cfif>
        <cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
          <td class="5026">&nbsp;</td>
          <td class="5027">&nbsp;</td>
          <td class="5028">&nbsp;</td>
          <td class="5029">&nbsp;</td>
        <cfelse>
          <td class="5031">#img_1010#</td>
          <td class="5032">#img_1010#</td>
        </cfif>

      </tr>
      <!------ Annual/Program Summary : Rate / UOM end ----->
    </cfoutput>
</cffunction>