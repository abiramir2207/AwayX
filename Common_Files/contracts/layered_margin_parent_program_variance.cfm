<!----
	Copyright (c) 2010 Blacksmith Applications, Inc.
	Date: 4/6/2010 --- kvangapalli
	Name:			Common_Files\contracts\layered_margin_parent_program_variance.cfm
	Description:	This page displays the layered margin variance for the current program and its parent verison
	Usage:			This file is called from layered_program_approval.cfm.
	Code from the file layered_program_approval.cfm was moved here for
	readabilty and development purposes
	Tip:			Set the appropricate variables on this page and this page can be included in other pages.
	---->
<cfoutput>
	<!------ Margin Variance : Start ----->
	<cfif Program_Is_A_Revision and getSettings.Custom_Fixed_Price_Options EQ 0 >
		<cfparam name="margin_version" default="current" />
		<!------ Margin Variance : Rate / UOM Start ----->
		<tr><td class='ln_16' style="border-bottom: 0px solid blue;">&nbsp;</td></tr>
		<tr>
			<!--- do not remove this empty td element, it is required to support sticky column --->
			<td class='ln_19'>&nbsp;</td>

			<td class='ln_21' align="left" colspan="100%" class="header colspan100">
				<strong>
					<a href="##" onClick="togglePreviousView('#margin_version#');">
						Variance to prior approved version
						<cfif margin_version eq "approved">
							- archived financials
						<cfelse>
							- current financials
						</cfif>
					</a>
				</strong>
			</td>
		</tr>
		<tr id="variance_rate_#margin_version#" valign="middle">
			<td class='ln_35' align="left" id="header">
				<strong>Rate / #totalprogramvolumeUOM#</strong>
			</td>
			<!--- 17289 > 16314 follow up 10/14/08 [begin] --->

			<cfif variables.bDisplayContractPrice>
				<!--- 16314 [begin] --->
				<td class='ln_42'>&nbsp;</td>
				<!--- 16314 [end] --->
			</cfif>

			<!--- 17289 > 16314 follow up 10/14/08 [end] --->

			<cfif Get_Profile_Settings.Base_View EQ 1>
				<cfset data = makeNumeric(TotalProgramVolume - TotalProgramPreviousVersionVolume) />


					<td class='ln_52' align="right" nowrap>#trim(numberformat(data,"___,___,___,___,___,___-__"))#</TD>		<!---  ::  TotalProgramVolume --->
				<cfset data = makeNumeric(getProgramMargins.Total_BaseSales - getProgramPreviousVersionMargins.Total_BaseSales) />


					<td class='ln_56' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<cfif margin_display_style eq "custom_t">
					<!--- ALlow/Surch ---->
					<cfset data = makeNumeric(getProgramMargins.Total_Allowance_Surcharges - getProgramPreviousVersionMargins.Total_Allowance_Surcharges) />


					<td class='ln_64' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />

					<!--- Customer Freight ---->
					<cfset data = makeNumeric(getProgramMargins.Total_Customer_Freight - getProgramPreviousVersionMargins.Total_Customer_Freight) />


					<td class='ln_71' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<cfif direct_pricing EQ 0>
					<!--- Dev Note: KAL; D20537: Margin Approval ? Trade as Percent of Gross Sales. Forge changes --->
					<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->

					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
						<cfset data = makeNumeric(getProgramMargins.Total_Cash_Discount - getProgramPreviousVersionMargins.Total_Cash_Discount) />


					<td class='ln_83' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
						<cfset colCount = colCount + 1 />
					</cfif>

					<cfparam name="addExtra" default="0">

					<cfif TotalProgramPreviousVersionVolume neq "" and TotalProgramPreviousVersionVolume neq 0 and TotalProgramVolume neq "" and TotalProgramVolume neq 0>
						<cfset addExtra = (makenumeric(getProgramLumpsum.Lumpsum_Amount/TotalProgramVolume) - makenumeric(getProgramPreviousVersionLumpsum.Lumpsum_Amount/TotalProgramPreviousVersionVolume)) />
					</cfif>


					<cfif form.Margin_Type EQ 1 OR form.margin_type EQ 3>
						<cfset data = (makeNumeric(getProgramMargins.TOTAL_Allowance) - makeNumeric(getProgramPreviousVersionMargins.TOTAL_Allowance)) + addExtra />
					<cfelse>
						<cfset data = (makeNumeric(getProgramMargins.TOTAL_Allowance) - makeNumeric(getProgramPreviousVersionMargins.TOTAL_Allowance)) />
					</cfif>



					<td class='ln_102' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>		<!---  :: total_allowanve --->
					<cfset colCount = colCount + 1 />


					<!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
					<!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Allowance". --->
					<td class='ln_108' align="right" nowrap>
						<cfif data EQ 0 OR (getProgramMargins.Total_BaseSales - getProgramPreviousVersionMargins.Total_BaseSales) EQ 0>
							N/A
						<cfelseif data LT 0>
							0%
						<cfelse>
						<cfset Total_Allowance_Rate_Percent = (data/(getProgramMargins.Total_BaseSales - getProgramPreviousVersionMargins.Total_BaseSales)) * 100>
							#application.util.string.cellFormat(value=Total_Allowance_Rate_Percent ,decimalplaces = request.numeric_format)# %
						</cfif>
					</td>		 <!--- ::  Total_BaseSales --->
					<cfset colCount = colCount + 1 />
				</cfif>

				<cfif ShowTPA EQ 1>
					<cfif margin_display_style eq "custom_t">
						<!--- TPA Operator --->
						<cfset data = makeNumeric(getProgramMargins.Total_TPA_Oper - getProgramPreviousVersionMargins.Total_TPA_Oper) />

					<td class='ln_126' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
						<cfset colCount = colCount + 1 />
					</cfif>

					<!--- TPA Distributor (Distributor Trade) --->
					<cfset data = makeNumeric(getProgramMargins.Total_TPA - getProgramPreviousVersionMargins.Total_TPA) />


					<td class='ln_134' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
					<cfset data = makeNumeric(getProgramMargins.Total_pullbackamount - getProgramPreviousVersionMargins.Total_pullbackamount) />


					<td class='ln_142' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<cfif margin_display_style eq "custom_t">
					<!--- Other Spend --->
					<cfset data = makeNumeric(getProgramMargins.Total_Other_Spend - getProgramPreviousVersionMargins.Total_Other_Spend) />


					<td class='ln_151' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->

				<cfif appSettings.getApprovalMarginType() eq 0>
					<cfset data = makeNumeric(getProgramMargins.TOTAL_NetSales - getProgramPreviousVersionMargins.TOTAL_NetSales) />


					<td class='ln_161' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

			</cfif>


			<cfif Get_Profile_Settings.View_Cost EQ 1>
				<cfset data = makeNumeric(getProgramMargins.Total_Cost - getProgramPreviousVersionMargins.Total_Cost) />


					<td class='ln_172' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
				<cfset data = makeNumeric(getProgramMargins.Total_Brokerage - getProgramPreviousVersionMargins.Total_Brokerage) />


					<td class='ln_180' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<cfif margin_display_style eq "custom_t">
				<!--- Shuttle Freight --->
				<cfset data = makeNumeric(getProgramMargins.Total_shuttle_freight - getProgramPreviousVersionMargins.Total_shuttle_freight) />


					<td class='ln_189' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Warehouse--->
				<cfset data = makeNumeric(getProgramMargins.Total_Custom_Warehouse - getProgramPreviousVersionMargins.Total_Custom_Warehouse) />


					<td class='ln_196' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Gross Margin --->
				<cfset data = makeNumeric(getProgramMargins.Total_Gross_Margin - getProgramPreviousVersionMargins.Total_Gross_Margin) />


					<td class='ln_203' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Brokerage --->
				<cfset data = makeNumeric(getProgramMargins.Total_Custom_Brokerage - getProgramPreviousVersionMargins.Total_Custom_Brokerage) />


					<td class='ln_210' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Contribution Margin --->
				<cfset data = makeNumeric(getProgramMargins.Total_Contribution_Margin_Alt - getProgramPreviousVersionMargins.Total_Contribution_Margin_Alt) />


					<td class='ln_217' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- Variable Contribution Margin --->
				<cfset data = makeNumeric(getProgramMargins.Total_Variable_Contribution_Margin - getProgramPreviousVersionMargins.Total_Variable_Contribution_Margin) />


					<td class='ln_224' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />

				<!--- MAP and MDF --->
				<cfset data = makeNumeric(getProgramMargins.Total_Map_Mdf - getProgramPreviousVersionMargins.Total_Map_Mdf) />


					<td class='ln_231' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />


				<!--- SG & A --->
				<cfset data = makeNumeric(getProgramMargins.Total_SGA - getProgramPreviousVersionMargins.Total_SGA) />


					<td class='ln_239' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
				<cfset data = makeNumeric(getProgramMargins.Total_OprIncome - getProgramPreviousVersionMargins.Total_OprIncome) />


					<td class='ln_247' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>


			<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
				<cfif appSettings.getApprovalMarginType() eq 2>
				<!--- Annual Case Rate --->
				<td class='ln_255' align="right" nowrap>
					<cfset data = makeNumeric(getProgramMargins.Total_TradeAmt_CS - getProgramPreviousVersionMargins.Total_TradeAmt_CS) />


					#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#
				</td>
				<cfelse>
				<cfset data = makeNumeric(getProgramMargins.Total_OprMargin - getProgramPreviousVersionMargins.Total_OprMargin) />


					<td class='ln_265' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>
			</cfif>
	<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
	<cfif appSettings.getapprovalLayeredCosts() EQ 2>

		<cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
			<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome) - makeNumeric(getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost)/>
		<cfelse>
			<cfset data = makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome) + makeNumeric(getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost)/>
		</cfif>



					<td class='ln_279' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfif makeNumeric(getProgramPreviousVersionMargins.Total_NetSales) EQ 0>
				<cfset TotalNetSales =1>
			<cfelse>
				<cfset TotalNetSales = makeNumeric(getProgramPreviousVersionMargins.Total_NetSales)>
			</cfif>

		<cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
			<cfset data = ((makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome) - makeNumeric(getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost))/TotalNetSales) * 100>
		<cfelse>
			<cfset data = ((makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome) + makeNumeric(getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost))/TotalNetSales) * 100>
		</cfif>

		<td class='ln_292' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
	</cfif>
	<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
				<td class='ln_295'>&nbsp;</td>
				<td class='ln_296'>&nbsp;</td>
				<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->

			<cfif appSettings.getApprovalMarginType() eq 1>
				<!--- Trade CS --->
				<cfset data = makeNumeric(getProgramMargins.Total_TradeAmt - getProgramPreviousVersionMargins.Total_TradeAmt) />


					<td class='ln_304' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
				<!--- Trade Percent --->
				<cfset data = makeNumeric(getProgramMargins.Total_TradePercent - getProgramPreviousVersionMargins.Total_TradePercent) />



					<td class='ln_311' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</TD>
			</cfif>

			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->

			<cfif Get_Profile_Settings.Base_View EQ 1>
				<td class='ln_317'>&nbsp;</td>
			</cfif>


			<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
				<td class='ln_322'>&nbsp;</td>
				<td class='ln_323'>&nbsp;</td>
				<td class='ln_324'>&nbsp;</td>
				<td class='ln_325'>&nbsp;</td>
			<cfelse>
				<td class='ln_327'>&nbsp;</td>
				<td class='ln_328'>&nbsp;</td>
			</cfif>

		</tr>
		<!------ Margin Variance : Rate / UOM end ----->

		<!------ Margin Variance : Absolute Dollar Calculation ----->
		<tr id="variance_dollar_#margin_version#">
			<td class='ln_336' align="left" id="header"><strong>Absolute $</strong></td>
			<!--- 17289 > 16314 follow up 10/14/08 [begin] --->

			<cfif variables.bDisplayContractPrice>
				<!--- 16314 [begin] --->
				<td class='ln_341'>&nbsp;</td>
				<!--- 16314 [end] --->
			</cfif>

			<!--- 17289 > 16314 follow up 10/14/08 [end] --->

			<cfif Get_Profile_Settings.Base_View EQ 1>
				<td class='ln_348'>&nbsp;</td>
				<cfset data1 = makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_BaseSales) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_355' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<cfif margin_display_style eq "custom_t">
					<!--- ALlow/Surch ---->
					<cfset data1 = makeNumeric(getProgramMargins.Total_Allowance_Surcharges) * makeNumeric(TotalProgramVolume) />
					<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Allowance_Surcharges) * makeNumeric(TotalProgramPreviousVersionVolume) />
					<cfset data = data1 - data2 />



					<td class='ln_365' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

					<!--- Customer Freight ---->
					<cfset data1 = makeNumeric(getProgramMargins.Total_Customer_Freight) * makeNumeric(TotalProgramVolume) />
					<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Customer_Freight) * makeNumeric(TotalProgramPreviousVersionVolume) />
					<cfset data = data1 - data2 />



					<td class='ln_374' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

				<cfif direct_pricing EQ 0>
					<!--- Dev Note: KAL; D20537: Margin Approval ? Trade as Percent of Gross Sales. Forge changes --->
					<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->

					<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
						<cfset data1 = makeNumeric(getProgramMargins.Total_Cash_Discount) * makeNumeric(TotalProgramVolume) />
						<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Cash_Discount) * makeNumeric(TotalProgramPreviousVersionVolume) />
						<cfset data = data1 - data2 />



					<td class='ln_388' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>		<!---   ::  Total_Cash_Discount --->
					</cfif>

					<cfset data1 = makeNumeric(getProgramMargins.TOTAL_Allowance) * makeNumeric(TotalProgramVolume) />
					<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.TOTAL_Allowance) * makeNumeric(TotalProgramPreviousVersionVolume) />

					<cfset data = data1 - data2 />
					<!--- 	<cfset data = AllowAbs1 - AllowAbs2 />	 --->
					<td class='ln_396' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>		<!---  :: TOTAL_Allowance --->
					<!--- skip a colmn for "Allow %" --->
						<td class='ln_398' align="right" nowrap>&nbsp;</td>
				</cfif>


				<cfif ShowTPA EQ 1>
					<cfif margin_display_style eq "custom_t">
						<!--- TPA Operator --->
						<cfset data1 = makeNumeric(getProgramMargins.Total_TPA_Oper) * makeNumeric(TotalProgramVolume) />
						<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_TPA_Oper) * makeNumeric(TotalProgramPreviousVersionVolume) />
						<cfset data = data1 - data2 />


					<td class='ln_410' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					</cfif>

					<!--- TPA Distributor (Distributor Trade) --->
					<cfset data1 = makeNumeric(getProgramMargins.Total_TPA) * makeNumeric(TotalProgramVolume) />
					<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_TPA) * makeNumeric(TotalProgramPreviousVersionVolume) />
					<cfset data = data1 - data2 />



					<td class='ln_420' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

				<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
					<cfset data1 = makeNumeric(getProgramMargins.Total_pullbackamount) * makeNumeric(TotalProgramVolume) />
					<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_pullbackamount) * makeNumeric(TotalProgramPreviousVersionVolume) />
					<cfset data = data1 - data2 />



					<td class='ln_430' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

				<cfif margin_display_style eq "custom_t">
					<!--- Other Spend --->
					<cfset data1 = makeNumeric(getProgramMargins.Total_Other_Spend) * makeNumeric(TotalProgramVolume) />
					<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Other_Spend) * makeNumeric(TotalProgramPreviousVersionVolume) />
					<cfset data = data1 - data2 />



					<td class='ln_441' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

				<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
				<cfif appSettings.getApprovalMarginType() eq 0>
					<cfset data1 = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume) />
					<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.TOTAL_NetSales) * makeNumeric(TotalProgramPreviousVersionVolume) />
					<cfset data = data1 - data2 />
					<cfset TotalNetSales = data>


					<td class='ln_452' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				</cfif>

			</cfif>


			<cfif Get_Profile_Settings.View_Cost EQ 1>
				<cfset data1 = makeNumeric(getProgramMargins.Total_Cost) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Cost) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_465' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>

			<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
				<cfset data1 = makeNumeric(getProgramMargins.Total_Brokerage) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Brokerage) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_475' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>

			<cfif margin_display_style eq "custom_t">
				<!--- Shuttle Freight --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_shuttle_freight) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_shuttle_freight) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_486' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- Warehouse --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_Custom_Warehouse) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Custom_Warehouse) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_495' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!--- Gross Margin --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_Gross_Margin) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Gross_Margin) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_504' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!---Brokerage --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_Custom_Brokerage) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Custom_Brokerage) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_513' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!---Contribution Margin --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_Contribution_Margin_Alt) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Contribution_Margin_Alt) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_522' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!---Variable Contribution Margin --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_Variable_Contribution_Margin) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Variable_Contribution_Margin) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_531' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!---MAP and MDF --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_Map_Mdf) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_Map_Mdf) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_540' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>

				<!---SG & A --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_SGA) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_SGA) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_549' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>

			<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
				<cfset data1 = makeNumeric(getProgramMargins.Total_OprIncome) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_559' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>


			<cfif Get_Profile_Settings.View_Target_Margins EQ 1>
			<cfif appSettings.getApprovalMarginType() eq 2>
				<!--- Annual Case Rate --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_TradeAmt_CS) * makeNumeric(getProgramMargins.totalprogramvolumecs) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_TradeAmt_CS) * makeNumeric(getProgramPreviousVersionMargins.totalprogramvolumecs) />
				<cfset data = data1 - data2 />

				<cfset AllowAbs1 = makeNumeric(data)>



					<td class='ln_574' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfelse>
				<td class='ln_576'>&nbsp;</td>
			</cfif>
			</cfif>

	<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
	<cfif appSettings.getapprovalLayeredCosts() EQ 2>

		<cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
			<cfset data1 = (makeNumeric(getProgramMargins.Total_OprIncome)-makeNumeric(getProgramMargins.Total_Fixed_Mfg_Cost)) * makeNumeric(TotalProgramVolume)/>
			<cfset data2 = (makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome)-makeNumeric(getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost)) * makeNumeric(getProgramPreviousVersionMargins.TotalProgramVolume)/>
		<cfelse>
			<cfset data1 = (makeNumeric(getProgramMargins.Total_OprIncome)+makeNumeric(getProgramMargins.Total_Fixed_Mfg_Cost)) * makeNumeric(TotalProgramVolume)/>
			<cfset data2 = (makeNumeric(getProgramPreviousVersionMargins.Total_OprIncome)+makeNumeric(getProgramPreviousVersionMargins.Total_Fixed_Mfg_Cost)) * makeNumeric(getProgramPreviousVersionMargins.TotalProgramVolume)/>
		</cfif>


		<cfset data = data1 - data2 />

	 <cfset TotalContribMargin = data />


					<td class='ln_597' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>


				<cfif makeNumeric(TotalNetSales) EQ 0>
					<cfset TotalNetSales =1>
				</cfif>

				<cfset data = (TotalContribMargin/TotalNetSales) * 100>


					<td class='ln_607' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</TD>
	</cfif>
		<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
				<td class='ln_610 csvExclude'>&nbsp;</td>
				<td class='ln_611'>&nbsp;</td>
			<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->

			<cfif appSettings.getApprovalMarginType() eq 1>
				<!--- Trade CS --->
				<cfset data1 = makeNumeric(getProgramMargins.Total_TradeAmt) * makeNumeric(TotalProgramVolume) />
				<cfset data2 = makeNumeric(getProgramPreviousVersionMargins.Total_TradeAmt) * makeNumeric(TotalProgramPreviousVersionVolume) />
				<cfset data = data1 - data2 />



					<td class='ln_622' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<!--- Trade Percent --->
				<td class='ln_624' align="right" nowrap>&nbsp;</td>
			</cfif>

			<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->

			<cfif Get_Profile_Settings.Base_View EQ 1>
				<cfset data = makeNumeric(program_spend_in_margin_uot - PreviousVersion_program_spend_in_margin_uot) />



					<td class='ln_634' align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			</cfif>


			<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
				<td class='ln_639'>&nbsp;</td>
				<td class='ln_640'>&nbsp;</td>
				<td class='ln_641'>&nbsp;</td>
				<td class='ln_642'>&nbsp;</td>
			<cfelse>
				<td class='ln_644'>&nbsp;</td>
				<td class='ln_645'>&nbsp;</td>
			</cfif>

		</tr>
		<!------ Margin Variance : Absolute Dollar Calculation END ----->
	</cfif>

	<!------ Margin Variance : End ----->
</cfoutput>