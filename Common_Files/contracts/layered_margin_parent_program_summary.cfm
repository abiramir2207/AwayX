<!----
	Copyright (c) 2010 Blacksmith Applications, Inc.
	Date:	4/6/2010 --- kvangapalli

	Name:			Common_Files\contracts\layered_margin_parent_program_summary.cfm
	Description:	This page displays the layered margin summary for the parent verison
	Usage:			This file is called from layered_program_approval.cfm.
					Code from the file layered_program_approval.cfm was moved here for
					readabilty and development purposes
	Tip:			Set the appropricate variables on this page and this page can be included in other pages.

---->

<cfoutput>
	<!------ Previous Version - Annual/Program Summary : Rate / UOM Start ----->
	<cfif Program_Is_A_Revision>
		<cfparam name="margin_version" default="current" />

		<tr> <td class='ln_19' style="border-bottom: 0px solid blue;">&nbsp;</td> </tr>
		<tr>
			<!--- do not remove this empty td element, it is required to support sticky column --->
			<td class='ln_22'>&nbsp;</td>
			<td class='ln_23' align="left" colspan="100%" class="header colspan100">
				<strong>
					<a href="##" onClick="togglePreviousView('#margin_version#');">
					Prior approved version
					<cfif margin_version eq "approved">
						- archived financials
					<cfelse>
						- current financials
					</cfif>
					- (#DateFormat(PreviousVersion_Margin_Calculated_Date,"mm/dd/yyyy")# #TimeFormat(PreviousVersion_Margin_Calculated_Date,"h:mm tt")#)
					</a>
				</strong>
				<cfif margin_version neq "approved">
					<img border="0" src="/Images/help_small.gif" width="14" height="14" class="small_help"
						title="This provides the financial summary for the previously approved version of this program with the current values for pricing, other trade and cost.">
					- <a href="javascript:showrevisiondetails('#contract_main_id#','#getProgramInfo.Contract_Status_Type_IDX#');">Revision Report</a>
					- <span id="btnRefreshPreviousMargin"><a href="javascript:refreshPreviousMargin();">Refresh Previous Margin</a></span>
				<cfelse>
					<img border="0" src="/Images/help_small.gif" width="14" height="14"  class="small_help"
						title="This provides the financial summary for the previously approved version of this program with the values for pricing, other trade and cost from the date when the prior version was approved.">
				</cfif>
			</td>
		</tr>
		<tr id="previous_rate_#margin_version#" valign="middle">
			<td class='ln_47' align="left" id="header"><strong>Rate / #totalprogramvolumeUOM#</strong></td>
            <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
    		<cfif variables.bDisplayContractPrice>
				<!--- 16314 [begin] --->
                <td class='ln_51'>&nbsp;</td>
                <!--- 16314 [end] --->
            </cfif>
            <!--- 17289 > 16314 follow up 10/14/08 [end] --->
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<cfset data = makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfif data lt 0>
					<cfset data = data *(-1)>
				</cfif>
				<td class='ln_60' align="right" nowrap>
					<cfif	((TotalProgramPreviousVersionVolume GT AnnualVolume_CS) and TRIM(AnnualVolume_CS) NEQ "*")
						or	((TotalProgramPreviousVersionVolume LT MinVolume_CS)	and TRIM(MinVolume_CS) NEQ "*")>
						<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
							onmouseover="initTheTooltip('Volume not within your approval limits.')"
							onmouseout="popOut()"
							align="absmiddle" />
					</cfif>
					#trim(numberformat(data,"___,___,___,___,___,___-__"))#
				</td>

				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_BaseSales) />
				<cfif data lt 0>
					<cfset data = data *(-1)>
				</cfif>
				<td class='ln_75' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<cfif margin_display_style eq "custom_t">
					<!--- ALlow/Surch --->
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Allowance_Surcharges) />
				<cfif data lt 0>
					<cfset data = data *(-1)>
				</cfif>
				<td class='ln_84' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />

					<!--- Customer Freight ---->
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Customer_Freight) />
				<cfif data lt 0>
					<cfset data = data *(-1)>
				</cfif>
				<td class='ln_92' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<cfif direct_pricing EQ 0>
					<!--- Dev Note: KAL; D20537: Margin Approval ? Trade as Percent of Gross Sales. Forge changes --->
					<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
						<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Cash_Discount) />
				<cfif data lt 0>
					<cfset data = data *(-1)>
				</cfif>
				<td class='ln_104' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
						<cfset colCount = colCount + 1 />
					</cfif>

					<!--- allowance: previous version --->
					<cfparam name="addExtra" default="0">
					<cfif TotalProgramPreviousVersionVolume neq "" and TotalProgramPreviousVersionVolume neq 0>
						<cfset addExtra = makenumeric(getProgramPreviousVersionLumpsum.Lumpsum_Amount/TotalProgramPreviousVersionVolume) />
					</cfif>

					<cfif form.Margin_Type EQ 1 OR form.margin_type EQ 3>
						<cfset data = makeNumeric(getProgramPreviousVersionMargins.TOTAL_Allowance) + addExtra />
					<cfelse>
						<cfset data = makeNumeric(getProgramPreviousVersionMargins.TOTAL_Allowance) />
					</cfif>


					<td class='ln_121' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />

					<!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
					<!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Allowance". --->
					<td class='ln_126' align="right" nowrap>
						<cfif data EQ 0 OR getProgramPreviousVersionMargins.Total_BaseSales EQ 0>
							N/A
						<cfelseif data LT 0>
							0%
						<cfelse>
						<cfset Total_Allowance_Rate_Percent = (data/getProgramPreviousVersionMargins.Total_BaseSales) * 100>
							#application.util.string.cellFormat(value=Total_Allowance_Rate_Percent ,decimalplaces = request.numeric_format)# %
						</cfif>
					</td>
					<cfset colCount = colCount + 1 />
					</cfif>

				<cfif ShowTPA EQ 1>
					<cfif margin_display_style eq "custom_t">
						<!--- TPA Operator --->
						<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TPA_Oper) />

					<td class='ln_144' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
						<cfset colCount = colCount + 1 />
					</cfif>

					<!--- TPA Distributor (Distributor Trade) --->
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TPA) />

					<td class='ln_151' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_pullbackamount) />

					<td class='ln_158' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<cfif margin_display_style eq "custom_t">
					<!--- Other Spend --->
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Other_Spend) />

					<td class='ln_166' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<!--- net sales: previous version --->
				<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 0>
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.TOTAL_NetSales) />

					<td class='ln_175' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>
			</cfif>

			<cfif Get_Profile_Settings.View_Cost EQ 1>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Cost) />

					<td class='ln_183' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Brokerage) />

					<td class='ln_190' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<cfif margin_display_style eq "custom_t">
				<!--- Shuttle Freight --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_shuttle_freight) />

					<td class='ln_198' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Warehouse --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Custom_Warehouse) />

					<td class='ln_204' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Gross Margin --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Gross_Margin) />

					<td class='ln_210' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Brokerage --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Custom_Brokerage) />

					<td class='ln_216' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Contribution Margin --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Contribution_Margin_Alt) />

					<td class='ln_222' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Variable Contribution Margin --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Variable_Contribution_Margin) />

					<td class='ln_228' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!---MAP and MDF --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Map_Mdf) />

					<td class='ln_234' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!---SG & A --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_SGA) />

					<td class='ln_240' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>


			<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome) />

					<td class='ln_248' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
				<cfif appSettings.getApprovalMarginType() eq 2>
				<!--- Annual Case Rate --->
				<td class='ln_255' align="right" nowrap>
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TradeAmt_CS) />

					#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#
				</td>
				<cfelse>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_OprMargin) />

				<td class='ln_263' align="right" nowrap>
					<cfif (getProgramPreviousVersionMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*">
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
	<cfif appSettings.getapprovalLayeredCosts() EQ 2>

		<cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
			<cfset data = getProgramPreviousVersionMargins.Total_OprIncome - getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost/>
		<cfelse>
			<cfset data = getProgramPreviousVersionMargins.Total_OprIncome + getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost/>
		</cfif>


					<td class='ln_284' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

		<cfif getProgramPreviousVersionMargins.Total_NetSales EQ 0>
			<cfset getProgramPreviousVersionMargins.Total_NetSales = 1>
		</cfif>

		<cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
			<cfset data = ((getProgramPreviousVersionMargins.Total_OprIncome - getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost)/getProgramPreviousVersionMargins.Total_NetSales) * 100>
		<cfelse>
			<cfset data = ((getProgramPreviousVersionMargins.Total_OprIncome + getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost)/getProgramPreviousVersionMargins.Total_NetSales) * 100>
		</cfif>

		<td class='ln_296' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
	</cfif>
	<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
	<td class='ln_299'>&nbsp;</td>
	<td class='ln_300'>&nbsp;</td>
			<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<!--- Trade CS --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TradeAmt) />

					<td class='ln_306' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Trade Percent --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TradePercent) />

					<td class='ln_312' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</TD>
			</cfif>

			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<td class='ln_317'>&nbsp;</td> <!--- leave the trade spend field blank for the rate/uom row, instead it will be displayed in the absolute $ row --->
			</cfif>

			<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
				<td class='ln_321'>&nbsp;</td>
				<td class='ln_322'>&nbsp;</td>
				<td class='ln_323'>&nbsp;</td>
				<td class='ln_324'>&nbsp;</td>
			<cfelse>
				<td class='ln_326'>&nbsp;</td>
				<td class='ln_327'>&nbsp;</td>
			</cfif>

		</tr>
		<!------ Previous Version - Annual/Program Summary : Rate / UOM end ----->


		<!------ Previous Version - Annual/Program Summary : Absolute $ start ----->
		<tr id="previous_dollar_#margin_version#" valign="middle">
			<td class='ln_336' align="left" id="header"><strong>Absolute $</strong></td>
            <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
    		<cfif variables.bDisplayContractPrice>
				<!--- 16314 [begin] --->
                <td class='ln_340'>&nbsp;</td>
                <!--- 16314 [end] --->
            </cfif>
            <!--- 17289 > 16314 follow up 10/14/08 [end] --->
			<cfif Get_Profile_Settings.Base_View EQ 1>

				<cfset data = makeNumeric(TotalProgramPreviousVersionVolume) />

					<cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)>
				<td class='ln_349'>
					<cfset colCount = colCount + 1 />
					<cfif	((TotalProgramPreviousVersionVolume GT AnnualVolume_CS) and TRIM(AnnualVolume_CS) NEQ "*")
						OR	((TotalProgramPreviousVersionVolume LT MinVolume_CS) and TRIM(MinVolume_CS) NEQ "*")>
						<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
							onmouseover="initTheTooltip('Volume not within your approval limits.')"
							onmouseout="popOut()"
							align="absmiddle">
					</cfif>&nbsp;
				</td>

				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_BaseSales) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset tempABS_BaseSales = data />

					<td class='ln_363' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<cfif margin_display_style eq "custom_t">
					<!--- ALlow/Surch --->
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Allowance_Surcharges) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_369' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

					<!--- Customer Freight ---->
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Customer_Freight) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_374' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

				<cfif direct_pricing EQ 0>
					<!--- Dev Note: KAL; D20537: Margin Approval ? Trade as Percent of Gross Sales. Forge changes --->
					<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
						<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Cash_Discount) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_383' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					</cfif>

					<cfparam name="addExtra" default="0">
					<cfif TotalProgramPreviousVersionVolume neq "" and TotalProgramPreviousVersionVolume neq 0>
						<cfset addExtra = makenumeric(getProgramPreviousVersionLumpsum.Lumpsum_Amount/TotalProgramPreviousVersionVolume) />
					</cfif>
					<cfif form.Margin_Type EQ 1 OR form.margin_type EQ 3>
						<cfset data = (makeNumeric(getProgramPreviousVersionMargins.TOTAL_Allowance) + addExtra) * makeNumeric(TotalProgramPreviousVersionVolume) />
					<cfelse>
						<cfset data = makeNumeric(getProgramPreviousVersionMargins.TOTAL_Allowance) * makeNumeric(TotalProgramPreviousVersionVolume) />
					</cfif>

					<cfset AllowAbs2 = makeNumeric(data)>


					<td class='ln_399' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<!--- skip a column for "Allow %" --->
					<td class='ln_401' align="right" nowrap>&nbsp;</TD>
				</cfif>

				<cfif ShowTPA EQ 1>
					<cfif margin_display_style eq "custom_t">
						<!--- TPA Operator --->
						<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TPA_Oper) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_409' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					</cfif>

					<!--- TPA Distributor (Distributor Trade) --->
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TPA) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_415' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

				<cfif appSettings.getPullbacksOn() EQ 1	and GetSettings.Pullbacks_On EQ 1>
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_pullbackamount) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_421' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

				<cfif margin_display_style eq "custom_t">
					<!--- Other Spend --->
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Other_Spend) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_428' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

				<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 0>
					<cfset data = makeNumeric(getProgramPreviousVersionMargins.TOTAL_NetSales) * makeNumeric(TotalProgramPreviousVersionVolume) />
					<cfset tempABS_NetSales = data />


					<td class='ln_437' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>
			</cfif>

			<cfif Get_Profile_Settings.View_Cost EQ 1>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Cost) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_444' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>

			<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Brokerage) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_450' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>

			<cfif margin_display_style eq "custom_t">
				<!--- Shuttle Freight --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_shuttle_freight) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_457' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- Warehouse --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Custom_Warehouse) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_462' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- Gross Margin --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Gross_Margin) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_467' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- Brokerage --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Custom_Brokerage) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_472' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- Contribution Margin --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Contribution_Margin_Alt) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_477' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- Variable Contribution Margin --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Variable_Contribution_Margin) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_482' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- MAP and MDF --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Map_Mdf) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_487' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- SG & A --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_SGA) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<td class='ln_492' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>

			<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset absTotalOperIncome = data />

					<td class='ln_499' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>

			<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
			<cfif appSettings.getApprovalMarginType() eq 2>
				<!--- Annual Case Rate --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TradeAmt_CS) * makeNumeric(getProgramMargins.totalprogramvolumecs) />

				<cfset AllowAbs1 = makeNumeric(data)>


					<td class='ln_510' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfelse>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_OprMargin) />

					<cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)>
				<td class='ln_515'>
					<cfif (getProgramPreviousVersionMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*">
						<IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
							onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')"
							onmouseout="popOut()"
							align="absmiddle">
					</cfif>&nbsp;
				</td>
			</cfif>
			</cfif>
	<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
	<cfif appSettings.getapprovalLayeredCosts() EQ 2>

		<cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
			<cfset data = (getProgramPreviousVersionMargins.Total_OprIncome-getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost) * getProgramPreviousVersionMargins.TotalProgramVolume/>
		<cfelse>
			<cfset data = (getProgramPreviousVersionMargins.Total_OprIncome+getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost) * getProgramPreviousVersionMargins.TotalProgramVolume/>
		</cfif>

        <cfset TotalContribMargin = data />

					<td class='ln_536' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
        <cfset data = makeNumeric(getProgramPreviousVersionMargins.TOTAL_NetSales) * makeNumeric(TotalProgramPreviousVersionVolume) />
		<cfif data EQ 0>
			<cfset data = 1>
		</cfif>



					<td class='ln_544' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</TD>
	</cfif>
	<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
		<td class='ln_547 csvExclude' valign="bottom">&nbsp;</td>
		<td class='ln_548'>&nbsp;</td>
			<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
			<cfif appSettings.getApprovalMarginType() eq 1>
				<!--- Trade CS --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TradeAmt) * makeNumeric(TotalProgramPreviousVersionVolume)  />

					<td class='ln_554' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- Trade Percent --->
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_TradePercent) />

					<td class='ln_559' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</TD>
			</cfif>

			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
			<cfif Get_Profile_Settings.Base_View EQ 1>
				<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_Trade_Spend) />

					<td class='ln_566' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>

			<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
				<td class='ln_570'>&nbsp;</td>
				<td class='ln_571'>&nbsp;</td>
				<td class='ln_572'>&nbsp;</td>
				<td class='ln_573'>&nbsp;</td>
			<cfelse>
				<td class='ln_575'>&nbsp;</td>
				<td class='ln_576'>&nbsp;</td>
			</cfif>

		</tr>
	</cfif>
	<!------ Previous Version - Annual/Program Summary : Absolute $ end ----->
</cfoutput>