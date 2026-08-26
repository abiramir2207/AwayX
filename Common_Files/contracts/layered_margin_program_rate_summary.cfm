<!----
	Copyright (c) 2011 Blacksmith Applications, Inc.
	Date: 			3/17/2010 --- dkunnath
	Name:			Common_Files\contracts\layered_margin_program_rate_summary.cfm
	Description:	This page displays the rate summary for the current program
	Usage:			This file is called from layered_program_approval.cfm
	Code from the file layered_program_approval.cfm was moved here for
	readabilty and development purposes
	Tip:			Set the appropriate variables on this page and this page can be included in other pages.
	---->

<cfset TotalProgramVolume = qProgramSummaryMargins.totalprogramvolume />
<cfoutput>
 	<!------ Annual/Program Summary : Rate / UOM start ----->
	<tr valign="middle">
		<td align="left" class="header"><strong>Rate / #displayUOM#</strong></td>
        <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
    	<cfif variables.bDisplayContractPrice>
			<!--- 16314 [begin] --->
            <td>&nbsp;</td>
            <!--- 16314 [end] --->
        </cfif>
        <!--- 17289 > 16314 follow up 10/14/08 [end] --->
		<cfif Get_Profile_Settings.Base_View EQ 1>
			<cfset data = makeNumeric(TotalProgramVolume) />


			<td align="right" nowrap>
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

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />

			<cfif margin_display_style eq "custom_t">
				<!--- ALlow/Surch --->
				<cfset data = makeNumeric(qProgramSummaryMargins.Total_Allowance_Surcharges) />

					<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />

				<!--- Customer Freight --->
				<cfset data = makeNumeric(qProgramSummaryMargins.Total_Customer_Freight) />

					<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
			</cfif>

			<cfif direct_pricing EQ 0>
				<!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
				<!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
				<cfif appsettings.getDisplayCashDiscountMargin() eq 1>
					<cfset data = makeNumeric(qProgramSummaryMargins.Total_Cash_Discount) />

					<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
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


				<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />


				<!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
				<!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Allowance". --->
				<td align="right" nowrap>
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
					<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
					<cfset colCount = colCount + 1 />
				</cfif>

				<!--- TPA Distributor (Distributor Trade) --->
				<cfset data = makeNumeric(qProgramSummaryMargins.Total_TPA) />

				<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<cfif appSettings.getPullbacksOn() EQ 1 and GetSettings.Pullbacks_On EQ 1>
				<cfset data = makeNumeric(qProgramSummaryMargins.Total_pullbackamount) />

				<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<cfif margin_display_style eq "custom_t">
				<!--- Other Spend --->
				<cfset data = makeNumeric(qProgramSummaryMargins.Total_Other_Spend) />

				<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>

			<!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
			<cfif appSettings.getApprovalMarginType() eq 0>
				<cfset data = makeNumeric(qProgramSummaryMargins.TOTAL_NetSales) />

				<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
				<cfset colCount = colCount + 1 />
			</cfif>
		</cfif>

		<cfif Get_Profile_Settings.View_Cost EQ 1>
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_Cost) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />
		</cfif>

		<cfif appSettings.getBrokerage_Margin_Calculation() EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins EQ 1>
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_Brokerage) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />
		</cfif>

		<cfif margin_display_style eq "custom_t">
			<!--- Shuttle Freight --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_shuttle_freight) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />

			<!--- Warehouse --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_Custom_Warehouse) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />

			<!--- Gross Margin --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_Gross_Margin) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />

			<!--- Brokerage --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_Custom_Brokerage) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />

			<!--- Contribution Margin --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_Contribution_Margin_Alt) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />

			<!--- Variable Contribution Margin --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_Variable_Contribution_Margin) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />

			<!--- MAP and MDF --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_Map_Mdf) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />

			<!--- SG & A --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_SGA) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />
		</cfif>

		<cfif Get_Profile_Settings.View_Operating_Income EQ 1>
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_OprIncome) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />
		</cfif>


		<cfif Get_Profile_Settings.View_Target_Margins EQ 1 AND (appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1)>
			<cfif appSettings.getApprovalMarginType() eq 2>
			<!--- Annual Case Rate --->
			<td align="right" nowrap>
				<cfset data = makeNumeric(qProgramSummaryMargins.Total_TradeAmt) />

				#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#
			</td>
			<cfelse>
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_OprMargin) />

			<td align="right" nowrap>
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

		<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

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
		<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
	</cfif>
	<!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
	<cfif Get_Profile_Settings.View_Target_Margins eq 1>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	</cfif>
		<!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
		<cfif appSettings.getApprovalMarginType() eq 1>
			<!--- Trade CS --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_TradeAmt) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</TD>
			<cfset colCount = colCount + 1 />
			<!--- Trade Percent --->
			<cfset data = makeNumeric(qProgramSummaryMargins.Total_TradePercent) />

			<td align="right" nowrap>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</TD>
		</cfif>
		<!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
		<cfif Get_Profile_Settings.Base_View EQ 1>
			<td>&nbsp;</td> <!--- leave the trade spend field blank for the rate/uom row, instead it will be displayed in the absolute $ row --->
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
	<!------ Annual/Program Summary : Rate / UOM end ----->

</cfoutput>