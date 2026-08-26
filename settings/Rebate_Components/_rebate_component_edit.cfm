<style>
.Orangline{
	border-right: 2px solid orange;
	width:400px;
}
ul.rebate_type > li {
    margin-bottom: 5px;
}
</style>

<!--- load custom labels for deduction account, payment account --->
<cfinclude template="/common_Files/general_labels.cfm">

<cfif isDefined("stError")>
	<cfset showCompTypeName = "Component name" />
	<cfif form.rebate_type EQ 2>
		<cfset showCompTypeName = "PP Increase Rebate Component" />
	</cfif>
	<script>
	<cfoutput>
	<cfif stError.bNameExists EQ 2>
		alert("#showCompTypeName# already exists with a different ID.");
	<cfelseif stError.bNameExists EQ 3>
		alert("Another component exists with the same allowance code.");
	</cfif>
	</cfoutput>
	</script>
</cfif>

<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()><!--- if auto pay app switch is ON --->
<!--- get credit type details --->
<cfsilent>
	<cfset qGetCreditTypes = application.oCreditTypeManager.getCreditTypes() />
	<cfset alreadySelectedCreditTypeExclusionList = "" />
	<cfif qGetCompRebates.Auto_Pay_Exclude_Credit_Type IS 1>
		<cfset qGetCreditTypeExclusion = compRebate.getCreditTypeExclusion(Rebate_Component_Name_ID = form.compId) />
		<cfset alreadySelectedCreditTypeExclusionList = ValueList(qGetCreditTypeExclusion.Credit_Type_ID) />
	</cfif>
</cfsilent>
</cfif><!--- if auto pay app switch is ON --->

<!--- Last edited info --->
<cfif isdefined("qGetCompRebates.Last_Edited_By") AND len(trim(qGetCompRebates.Last_Edited_By)) GT 0 >

	<cfset useLakebaseForGetUserLastEdited = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserLastEdited>
	<cftry>
		<cfset GetUserLastEdited = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#qGetCompRebates.Last_Edited_By#",
				"select" = "name_first + ' ' + name_last as userlastedited"
			}), "name_first + ' ' + name_last as userlastedited"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserLastEdited = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserLastEdited>
<cfquery name="GetUserLastEdited" datasource="#application.datasource#">
	SELECT Name_First + ' ' + Name_Last AS UserLastEdited
	FROM _Users
	WHERE User_ID = '#qGetCompRebates.Last_Edited_By#'
	</cfquery>
</cfif>
	<cfif GetUserLastEdited.Recordcount IS 1>
	<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;margin-top:10px;" CELLPADDING="3" CELLSPACING="0" align="center">
	<TR>
	<TD align="center" width="400px" style="font-size:12px;">
		<B>Last updated on <CFOUTPUT>#dateformat(qGetCompRebates.Last_Edited_Date, 'm/d/yyy')# #timeformat(qGetCompRebates.Last_Edited_Date, 'h:mm:ss TT')# by #GetUserLastEdited.UserLastEdited#</CFOUTPUT></B></TD>
	</TD>
	</TR>
	</TABLE>
	</cfif>
	<br>
</cfif>
<!---D79237:  Rebate - OI and Redi START---->
	<cfset qGetALLCompRebates = compRebate.getActive(get_all_active = 1)>
	<cfquery name="qGetActiveComps" dbtype="query">
		SELECT *
		FROM qGetALLCompRebates
		WHERE Program_Rebates_Component_Name_ID NOT IN (#form.compId#)
	</cfquery>
<!---D79237:  Rebate - OI and Redi END---->

<FIELDSET STYLE="padding:10px; width:1150px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Information</LEGEND>
	<cfoutput>
	<table width="100%" border="0" cellpadding="3" cellspacing="0">
		<!--- <colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup> --->
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#ID.General_Labels_Label#: </B></TD>

			<TD><INPUT NAME="compExternalID" TYPE="text" VALUE="#qGetCompRebates.External_ID#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #ID.General_Labels_Label# on View Program page:</B></TD>
			<TD><INPUT NAME="displayExternalID" TYPE="checkbox" VALUE="1" <cfif qGetCompRebates.ID_on_ViewProgramPage>Checked</cfif>></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<cfelse>
			<INPUT NAME="compExternalID" TYPE="hidden" VALUE="#qGetCompRebates.External_ID#">
			<INPUT NAME="displayExternalID" TYPE="hidden" VALUE="#qGetCompRebates.ID_on_ViewProgramPage#"><!---D58135 --->
		</cfif>
		<TR>
			<TD ALIGN="right" class="Orangline" width="50%"><B>Component Name:</B></TD>
			<TD width="50%"><INPUT NAME="compName" TYPE="text" VALUE="#qGetCompRebates.Program_Rebates_Component_Name#" MAXLENGTH="50" style="width:220px"></TD>
		</TR>
		<cfset Rebate_Percent_Option = qGetCompRebates.Rebate_Percent_Option_ID>
		<cfset qPercentOptions = compRebate.getPercentOptions() />
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Business rules for percentage rebates - Margin & Auto Pay:</B>
			<CF_SmallHelp
					width="500"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
			<table cellpadding="0" cellspacing="0">
			<tr><td align="left">
			<span style="text-decoration:underline">Auto Pay Calculations</span>
			<ul>
			<li>If this option is set to "Gross Sales", auto pay calculations will be based upon regular invoice records only. The application will not consider additional records such as credits.</li>
			<li>If this option is set to "Net Sales", you will have the following additional options to select from:
				<ol>
					<li>Auto pay calculations are net of cash discount [yes or no]</li>
					<li>Auto pay calculations are net of freight allowances [yes or no]</li>
					<li>Auto pay should exclude by credit type [yes or no]</li>
				</ol>
			</li>
			<li>Options ##1 & 2 are applicable only if the client sends the necessary data in their invoice detail file.  The columns in the invoice detail file for the data would be:  Freight_Revenue and Cash_Discount.  Coordination with Blacksmith is needed when implementing this data.</li>
			<li>If option ##3 is set to YES, then, you will select which credit types to exclude.  By default, the application will consider all credit types, eg, the transaction rows the application will use to calculate the amount due will include all records for each eligible customer and item combination.  If you do not wish to net out specific credit types, you should turn the check box on for those to exclude.  Credit types that are excluded will not be considered.</li>
			</ul>
 			</td></tr>
			<tr><td align="left">
			<span style="text-decoration:underline">Margin Calculations</span>
			<ul>
			<li>If this option is set to '<span style="text-decoration:underline">Gross Sales</span>', the allowance resolution for percentage-based rebates [eg, converting the percentage offered to a per case and/or per pound equivalent] will consider the <span style="text-decoration:underline">Base Sales</span> [eg, into-stock price] value for the calculation.</li>
			<li>If this option is set to '<span style="text-decoration:underline">Net Sales</span>', the allowance resolution for percentage-based rebates [eg, converting the percentage offered to a per case and/or per pound equivalent] will consider the <span style="text-decoration:underline">Net Sales</span> [eg, into-stock price less other trade and allowances] value for the calculation.</li>
			</ul>
			</td></tr>
			</table>
			</CF_SmallHelp>
			</TD>
			<TD>
			<select name="Rebate_Percent_Option" onChange="showHideOptions()">
			<cfloop query="qPercentOptions">
			<option value="#Rebate_Percent_Option_ID#" <cfif Rebate_Percent_Option_ID EQ Rebate_Percent_Option>SELECTED</cfif>>#Rebate_Percent_Option_Desc#</option>
			</cfloop>
			</select>
			</TD>
		</TR>
		<!--- D23133 : Change Request - Bagcraft - Component level exclusions
		Add 3 new settings to the rebate component settings panel.
			Auto pay should exclude Cash Discount.
				This setting is applicable (and only available) when the "Percentage option used in Auto Pay & Margin" is set to Net Sales.
			Auto pay should exclude Freight Allowance.
				This setting is applicable (and only available) when the "Percentage option used in Auto Pay & Margin" is set to Net Sales.
			Auto pay should exclude by Type.
		--->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()><!--- if auto pay app switch is ON --->
		<TR id="id_autopay_netdiscount" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Auto pay calculations are net of cash discount:</B>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Net_Of_Cash_Discount" <cfif qGetCompRebates.Auto_Pay_Net_Of_Cash_Discount IS 0>checked</cfif>> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Net_Of_Cash_Discount" <cfif qGetCompRebates.Auto_Pay_Net_Of_Cash_Discount IS 1>checked</cfif>>
			</TD>
		</TR>
		<TR id="id_autopay_netfreight" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Auto pay calculations are net of freight allowances:</B>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Net_Of_Freight_Allowance" <cfif qGetCompRebates.Auto_Pay_Net_Of_Freight_Allowance IS 0>checked</cfif>> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Net_Of_Freight_Allowance" <cfif qGetCompRebates.Auto_Pay_Net_Of_Freight_Allowance IS 1>checked</cfif>>
			</TD>
		</TR>
		<TR id="id_autopay_excludecredit" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Auto pay should exclude by credit type:</B>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Exclude_Credit_Type" <cfif qGetCompRebates.Auto_Pay_Exclude_Credit_Type IS 0>checked</cfif> onClick="showHideOptions()"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Exclude_Credit_Type" <cfif qGetCompRebates.Auto_Pay_Exclude_Credit_Type IS 1>checked</cfif> onClick="showHideOptions()">
			</TD>
		</TR>
		<cfsilent>
		<cfset divHeight = qGetCreditTypes.recordCount * 20 />
		<cfif divHeight gt 100>
			<cfset divHeight = 100 />
		</cfif>
		</cfsilent>
		<cfinclude template="../inc_credit_types.cfm" />
		</cfif><!--- if auto pay app switch is ON --->

		<cfset Rebate_Margin_Percent_Option = qGetCompRebates.Rebate_Margin_Percent_Option_ID>
		<cfset qMarginPercentOptions = compRebate.getMarginPercentOptions() />
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Percentage option used in TPA & Margin:</B>
			<CF_SmallHelp
					width="500"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
			<table cellpadding="0" cellspacing="0">
			<tr><td align="left">
			Margin Page:
			<ul>
			<li>If this setting is Fixed Price, the allowance calculation will use the Fixed Price from the program for percentage conversion, as long as a fixed price is present and not $0.  If those conditions are not met, then it will use Base Sales for percentage conversion.</li>
			</ul>
 			</td></tr>
			<tr><td align="left">
			TPA:
			<ul>
			<li>If this setting is Fixed Price, the allowance calculation will store the value as a percentage in the TPA table.  TPA will be resolved as:  Fixed Price from program, if there is one present, multiplied by the percentage value that was stored.  If the program does not have a fixed price, then base sales multiplied by the percentage value that was stored.</li>
			<li>If this setting Base Sales, the allowance calculation will convert the percentage into a per pound value using base sales and store the converted value in the TPA table.</li>
			</ul>
			</td></tr>
			</table>
			</CF_SmallHelp>
			</TD>
			<TD>
			<select name="Rebate_Margin_Percent_Option">
			<cfloop query="qMarginPercentOptions">
			<option value="#Rebate_Margin_Percent_Option_ID#" <cfif Rebate_Margin_Percent_Option_ID EQ Rebate_Margin_Percent_Option>SELECTED</cfif>>#Rebate_Margin_Percent_Option_Desc#</option>
			</cfloop>
			</select>
			</TD>
		</TR>
		<!--- Price Protection --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Rebate Type:</B>
<!---D38693 Simplot ENH - Off Invoice & Deviations START--->
			<CF_SmallHelp
					width="500"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
					<table cellpadding="0" cellspacing="0">
						<tr>
							<td align="left">
								<ul class="rebate_type">
										<li><b>Base Price Protection Rebate</b> - This option classifies the program rebate as a value that will be price protected from price increases.</li>
										<li><b>Price Protection Increase Rebate</b> - If a program has the Base Price Protection Rebate, then when a price increase takes place, Blacksmith will revise the program and add this component to the program.  The component's value will be the price increase amount.</li>
										<li><b>Exclude from margin calculation</b> - This option removes the rate from consideration by the FORGE approval scheme.  You should select this option when FORGE is acting as the utility for managing non-trade related activities as a front-end to the Enterprise.  In those cases, the impact of those variables is already taken into consideration within the master data file for product cost.</li>
										<li><b>Variable/Fixed combo</b> -  This option provides users with the ability to establish a rate for a given quantity that resolves to a fixed [lump sum] promoted value.  For example, offering $1.00 per 100 cases will store the estimated promoted value of $100.00 for the margin evaluation.  This feature simplifies the user interaction in establishing the projected committed value of the program.</li>
										<li><b>Express as cost in margin</b> - This option classifies the program rebate value as a product cost rather than a trade expense for the program approval evaluation.  This feature accounts for cost factors that are not available through the Enterprise integration package.</li>
                                        <li><b>Add component value to invoice price</b> - This option will  find any programs with the component, and for the distributors and items associated to the component add the component dollar value to the invoice price for those distributors and items.</li>
                                        <li><b>Scan</b> - This option provides an extra box when adding a rebate component.  This box is used to define the percent of the volume that is expected to move during this program period.  The margin page will calculate using the rate * volume * percent to calculate extended trade.  Accruals will also use the percentage to calculate the spend.  Billbacks will use the true rate. Example:  Rebate of $1.00/cs, 60%, volume of 1000 cases.  Margin page will calculate $600 extended trade, or a trade rate of $.60 cs.  Accruals will calculate at $.60 per case purchased.  Billbacks will use the full $1.00 rate times the volume claimed.</li>
								</ul>
							</td>
						</tr>
					</table>
			</CF_SmallHelp>
<!---D38693 Simplot ENH - Off Invoice & Deviations END--->
			</TD>
			<TD>
			<select name="Rebate_type">
			<option value="0" <cfif qGetCompRebates.Rebate_type EQ 0>SELECTED</cfif>>None</option>
			<option value="8" <cfif qGetCompRebates.Rebate_type EQ 8>SELECTED</cfif>>Accrual Budget</option>
      <option value="6" <cfif qGetCompRebates.Rebate_type EQ 6>SELECTED</cfif>>Add component value to invoice price</option><!---D38693 Simplot ENH - Off Invoice & Deviations--->
			<option value="1" <cfif qGetCompRebates.Rebate_type EQ 1>SELECTED</cfif>>Base Price Protection Rebate</option>
			<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
			<option value="7" <cfif qGetCompRebates.Rebate_type EQ 7>SELECTED</cfif>>Blended Rate</option>
			</cfif>
			<option value="3" <cfif qGetCompRebates.Rebate_type EQ 3>SELECTED</cfif>>Exclude from margin calculation</option>
			<option value="5" <cfif qGetCompRebates.Rebate_type EQ 5>SELECTED</cfif>>Express as cost in margin</option>
			<option value="2" <cfif qGetCompRebates.Rebate_type EQ 2>SELECTED</cfif>>Price Protection Increase Rebate</option>
			<option value="4" <cfif qGetCompRebates.Rebate_type EQ 4>SELECTED</cfif>>Variable/Fixed Combo</option>
			<option value="9" <cfif qGetCompRebates.Rebate_type EQ 9>SELECTED</cfif>>Exclude from TPA/Reduce from Base Sales</option>
			<option value="10" <cfif qGetCompRebates.Rebate_type EQ 10>SELECTED</cfif>>Scan</option>
			</select>
			</TD>
		</TR>
		<!--- D38536  :: Alternate recapture rates per component START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Alternate <cfoutput>#appSettings.getPullbackLabel()#</cfoutput> Rates:</B></TD>
			<TD>
				No &nbsp;<input onclick="showHideAlternateRecapture();;" type="radio" value="0" name="Alternate_Recapture_Rate" <cfif qGetCompRebates.Alternate_Recapture_Rate IS 0>checked</cfif>>
				&nbsp;&nbsp;
				Yes <input onclick="showHideAlternateRecapture();"  type="radio" value="1" name="Alternate_Recapture_Rate" <cfif qGetCompRebates.Alternate_Recapture_Rate IS 1>checked</cfif>>
			</TD>
		</TR>
		<TR class="alternateRatesTR1" <cfif qGetCompRebates.Alternate_Recapture_Rate EQ 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline"><B><cfoutput>#appSettings.getPullbackLabel()# #LCase(application.returned_customer_setting.operator_label_singular)#</cfoutput> exclusion:</B></TD>
			<TD>
				No &nbsp;<input onclick="showHideAlternateRecapture();" type="radio" value="0" name="Alternate_Recapture_By_Operator" <cfif qGetCompRebates.Alternate_Recapture_By_Operator IS 0>checked</cfif>>
				&nbsp;&nbsp;
				Yes <input onclick="showHideAlternateRecapture();"  type="radio" value="1" name="Alternate_Recapture_By_Operator" <cfif qGetCompRebates.Alternate_Recapture_By_Operator IS 1>checked</cfif>>
			</TD>
		</TR>
	<cfloop from="1" to="3" index="i">
		<cfset useLakebaseForalternateRateCheck = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alternate_recapture_rate_setting")>
<cfif useLakebaseForalternateRateCheck>
	<cftry>
		<cfset alternateRateCheck = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alternate_recapture_rate_setting", {
				"program_rebates_component_name_id" = "eq.#form.compid#",
				"alternate_recapture_rate_index" = "eq.#i#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForalternateRateCheck = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForalternateRateCheck>
<cfquery name="alternateRateCheck" datasource="#application.datasource#">
		 SELECT *
		 FROM Alternate_Recapture_Rate_Setting
		 WHERE Program_Rebates_Component_Name_ID = #form.compid#
		 AND Alternate_Recapture_Rate_Index = #i#
		</cfquery>
</cfif>

		<cfset useLakebaseForalternateRateTemplateList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alternate_recapture_rate_template")>
<cfif useLakebaseForalternateRateTemplateList>
	<cftry>
		<cfset alternateRateTemplateList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("alternate_recapture_rate_template", {
				"program_rebates_component_name_id" = "eq.#form.compid#",
				"alternate_recapture_rate_index" = "eq.#i#",
				"select" = "first_parent_id"
			}), "first_parent_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForalternateRateTemplateList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForalternateRateTemplateList>
<cfquery name="alternateRateTemplateList" datasource="#application.datasource#">
				SELECT First_Parent_ID
				FROM Alternate_Recapture_Rate_Template
				WHERE Program_Rebates_Component_Name_ID = #form.compid#
				AND Alternate_Recapture_Rate_Index = #i#
		</cfquery>
</cfif>

		<cfset TRID = 1 />
		<cfif i GT 1>
			<cfset TRID = "" />
		</cfif>

		<cfset display = 1 />
		<cfif qGetCompRebates.Alternate_Recapture_Rate>
			<cfif qGetCompRebates.Alternate_Recapture_By_Operator>
				<cfif i GT 1>
					<!--- Hide the second and thrird alternate recapture rate rows when "recapture by operator" is ON --->
					<cfset display = 0 />
				</cfif>
			</cfif>
		<cfelse>
			<cfset display = 0 />
		</cfif>
		<TR class="alternateRatesTR#TRID#" <cfif display eq 0>style="display:none;"</cfif>>

			<TD ALIGN="right" class="Orangline"><B>Alternate Rate #i#:</B></TD>
			<TD>
				<table>
					<tr>
							<td><input type="checkbox" name="rate#i#" value="1" <cfif len(alternateRateCheck.Status) AND alternateRateCheck.Status EQ 0>CHECKED</cfif>></td>
							<td><B>Label : &nbsp;</B><input type="text" name="description#i#" value="#alternateRateCheck.Alternate_Recapture_Rate_Label#" style="width:200px"></td>
							<td valign="top"><!---&nbsp;<a onclick="template(#i#, #form.compid#);">#Actiontext('templates')#</a>--->
															<input type="hidden" name="AlternateRateTemplateList#i#" value="#ValueList(alternateRateTemplateList.First_Parent_ID,",")#">
															<span class="alternateRatesTemplate" <cfif qGetCompRebates.Alternate_Recapture_By_Operator>style="display:none;"</cfif>>
															<CF_button
																		button_name		=	""
																		button_caption	=	"templates"
																		button_action	=	"templateAlternateRate(#i#, #form.compid#, document.all.DataForm.AlternateRateTemplateList#i#.value);"
																		button_type		=	"javascript_link"
																		button_width	=	"75"
																		button_color	=	"Navy"
																		button_tip		=	""
																		font_color		=	"White"
																		font_size		=	"12"
																		font_weight		=	"bold"
																	></span>

							</td>
					</tr>
				</table>
			</TD>
		</TR>
	</cfloop>
		<!--- D38536  :: Alternate recapture rates per component END--->
		<cfif appSettings.get_Setting('Include_Second_Component_Feature') eq '1'>
		<!---D79237:  Rebate - OI and Redi START---->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Include 2nd Component With Same Rates:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Include_Second_Component" class="Include_Second_Component" <cfif qGetCompRebates.Include_Second_Component IS 0>checked</cfif> onclick="$('.SecondCompNameId').hide();">
				&nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Include_Second_Component" class="Include_Second_Component" <cfif qGetCompRebates.Include_Second_Component IS 1>checked</cfif> onclick="$('.SecondCompNameId').show();">
			</TD>
		</TR>
		<cfelse>
		<cfset qGetCompRebates.Include_Second_Component = 0>
		</cfif>
		<TR class="SecondCompNameId" <cfif qGetCompRebates.Include_Second_Component IS 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd #Application.RebateLabel# Component:<br />
				<select name="Second_Component_Name_ID" id="Second_Component_Name_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="qGetActiveComps">
					<option value="#Program_Rebates_Component_Name_ID#" <cfif qGetCompRebates.Second_Component_Name_ID EQ Program_Rebates_Component_Name_ID>SELECTED</cfif>>#Program_Rebates_Component_Name#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<TR class="SecondCompNameId" <cfif qGetCompRebates.Include_Second_Component IS 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component Payment Cycle:<br />
				<select name="Second_Component_Payment_Cycle_ID" id="Second_Component_Payment_Cycle_ID" style="width:200px;">
					<option value="0" SELECTED>Select one option</option>
					<cfloop query="qGetPaymentCycles">
						<option value="#Payment_Cycle_ID#"  <cfif qGetCompRebates.Second_Component_Payment_Cycle_ID EQ Payment_Cycle_ID>SELECTED</cfif>>#Payment_Cycle#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<TR class="SecondCompNameId" <cfif qGetCompRebates.Include_Second_Component IS 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component Claim Mechanic:<br />
			<select name="Second_Component_Payment_Type_ID" id="Second_Component_Payment_Type_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="GetClaimMechInfo">
					<option value="#Payment_Type_ID#" <cfif qGetCompRebates.Second_Component_Payment_Type_ID EQ Payment_Type_ID>SELECTED</cfif>>#Payment_Type_Name#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<cfif appsettings.getGL_Account_On() IS 1>
		<TR class="SecondCompNameId" <cfif qGetCompRebates.Include_Second_Component IS 0>style="display:none;"</cfif>>
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component GL Account:<br />
				<select name="Second_Component_GL_Account_ID" id="Second_Component_GL_Account_ID" style="width:200px;">
						<option value="0" SELECTED>Select one option</option>
					<cfloop query="qGetGLs">
						<option value="#GL_Account_ID#"  <cfif qGetCompRebates.Second_Component_GL_Account_ID EQ GL_Account_ID>SELECTED</cfif>>
						#Gl_Account# (#GL_Account_Desc#)
						</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		</cfif>
		<!---D79237:  Rebate - OI and Redi END--->
		<!--- D44978: Set Excludes from Recapture at the component level --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Exclude From <cfoutput>#appSettings.getPullbackLabel()#</cfoutput>:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Exclude_From_Recapture" <cfif qGetCompRebates.Exclude_From_Recapture IS 0>checked</cfif>>
				&nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Exclude_From_Recapture" <cfif qGetCompRebates.Exclude_From_Recapture IS 1>checked</cfif>>
			</TD>
		</TR>
		<!--- Interface as Rate --->
		<!--- Dev Note: KAL; D17073: AE - Variable Scan Conversion --->
		<!--- 38973 Remove rebate component setting - Interface as Rate
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Interface as Rate:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Interface_as_Rate" <cfif qGetCompRebates.Interface_as_Rate IS 0>checked</cfif>> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Interface_as_Rate" <cfif qGetCompRebates.Interface_as_Rate IS 1>checked</cfif>>
			</TD>
		</TR>	--->
		<input type="hidden" name="Interface_as_Rate" value="#qGetCompRebates.Interface_as_Rate#">

		<!--- Accrual --->
		<cfif appSettings.getShow_Component_Accrual()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Accrual On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Accrual_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Accrual_On" <cfif qGetCompRebates.Accrual_On IS 1>checked</cfif>>
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Accrual_On" value ="#qGetCompRebates.Accrual_On#">
		</cfif>

		<!--- 34114 --->
		<tr>
			<TD ALIGN="right" class="Orangline"><B>Recapture rate sources from program's budget (instead of program):</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" <cfif qGetCompRebates.Recapture_Rate_From_Program_Budget neq "1">checked</cfif> name="Recapture_Rate_From_Program_Budget"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" <cfif qGetCompRebates.Recapture_Rate_From_Program_Budget eq "1">checked</cfif> name="Recapture_Rate_From_Program_Budget">
			</TD>
		</tr>

		<!--- Brokerage --->
		<cfif appSettings.getBrokerage_Functionality_On()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Exclude Brokerage:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Exclude_Brokerage" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Exclude_Brokerage" <cfif qGetCompRebates.Exclude_Brokerage IS 1>checked</cfif>>
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Exclude_Brokerage" value ="#qGetCompRebates.Exclude_Brokerage#">
		</cfif>

<!---
    Dev Notes: D23988/Anand Rao/30-Jun-10
		Rebate Component Setting change Off Invoice Label
--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display Off Invoice Claim Mechanics:</B><br />
			<span style="font-size: 10px;display:compact;width:200px;color:##000000;text-align:left;">[if yes is selected, only claim mechanics with Off Invoice set to 'yes' will be shown for this component]</span>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Off_Invoice_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Off_Invoice_On" <cfif qGetCompRebates.Off_Invoice_On IS 1>checked</cfif>>
			</TD>
		</TR>

	<!--- D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work  START --->
		<TR>
			<TD ALIGN="right" class="Orangline">
        		<B>Update BB Expected Rate:
				<CF_SmallHelp
					width="350"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>When this is ON, in the billback rate pop up window you will see a row called Override Rate with the appropriate rate it is adding/subtracting.</center>
				</CF_SmallHelp>
				</B><br>
            </TD>
			<TD>
				No &nbsp;<input type="radio" onclick="Toggle('hide','ExpectedRateTR')" value="0" name="Update_BB_Expected_Rate" checked> &nbsp;&nbsp;
				Yes <input type="radio" onclick="Toggle('show','ExpectedRateTR')" value="1" name="Update_BB_Expected_Rate" <cfif qGetCompRebates.Update_BB_Expected_Rate IS 1>checked</cfif>>
			</TD>
		</TR>

		<cfif qGetCompRebates.Update_BB_Expected_Rate>
		<TR class="ExpectedRateTR">
		<cfelse>
		<TR class="ExpectedRateTR" style="display:none;">
		</cfif>
			<TD ALIGN="right" class="Orangline"><B>BB Expected Rate should be:</B></TD>
			<TD>
					<select name="Expected_Rate">
						<option value="0">Select an Option</option>
						<option value="1" <cfif qGetCompRebates.Expected_Rate IS 1>selected</cfif>>Set to $0</option>
						<option value="2" <cfif qGetCompRebates.Expected_Rate IS 2>selected</cfif>>Less the program's rebate rate</option>
						<option value="3" <cfif qGetCompRebates.Expected_Rate IS 3>selected</cfif>>Add program's rebate rate</option>
					</select>
			</TD>
		</TR>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments START --->
		<cfif qGetCompRebates.Update_BB_Expected_Rate>
			<TR class="ExpectedRateTR">
			<cfelse>
			<TR class="ExpectedRateTR" style="display:none;">
			</cfif>
				<TD ALIGN="right" class="Orangline"><B>Apply Expected Rate to:</B></TD>
				<TD>
						<select name="Expected_Rate_Affect_Discount_Type">
							<option value="0">Select an Option</option>
							<option value="1" <cfif qGetCompRebates.Expected_Rate_Affect_Discount_Type IS 1>selected</cfif>>Fixed</option>
							<option value="2" <cfif qGetCompRebates.Expected_Rate_Affect_Discount_Type IS 2>selected</cfif>>Rebate</option>
							<option value="3" <cfif qGetCompRebates.Expected_Rate_Affect_Discount_Type IS 3>selected</cfif>>Both</option>
						</select>
				</TD>
			</TR>

			<cfif qGetCompRebates.Update_BB_Expected_Rate>
				<TR class="ExpectedRateTR">
				<cfelse>
				<TR class="ExpectedRateTR" style="display:none;">
				</cfif>
					<TD ALIGN="right" class="Orangline"><B>Apply to all templates:</B></TD>
					<TD>
						<table>
							<tr>
								<td>
									No &nbsp;<input type="radio" value="0" name="Expected_Rate_Apply_All_Templates" checked  onclick="$('##TemplateLink').show();"> &nbsp;&nbsp;
								</td>
								<td>
									Yes <input type="radio" value="1" name="Expected_Rate_Apply_All_Templates" <cfif qGetCompRebates.Expected_Rate_Apply_All_Templates IS 1>checked</cfif> onclick="$('##TemplateLink').hide();">
								</td>
								<td id="TemplateLink" <cfif qGetCompRebates.Expected_Rate_Apply_All_Templates IS 1>style="display:none;"</cfif>>
									<cfset ExpectedRateTemplateList = compRebate.getExpectedRateTemplates(form.compid)>
									<input type="hidden" name="ExpectedRateTemplateList" value="#ValueList(ExpectedRateTemplateList.First_Parent_ID,",")#">
									<CF_button
									button_name		=	""
									button_caption	=	"templates"
									button_action	=	"template('', #form.compid#, document.all.DataForm.ExpectedRateTemplateList.value);"
									button_type		=	"javascript_link"
									button_width	=	"75"
									button_color	=	"Navy"
									button_tip		=	""
									font_color		=	"White"
									font_size		=	"12"
									font_weight		=	"bold"
								>
								</td>
							</tr>
						</table>
					</TD>
				</TR>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments END --->
		<cfif qGetCompRebates.Update_BB_Expected_Rate>
		<TR class="ExpectedRateTR">
		<cfelse>
		<TR class="ExpectedRateTR" style="display:none;">
		</cfif>
			<TD ALIGN="right" class="Orangline"><B>When the BB Payee Type is:</B></TD>
			<TD>
					<select name="Program_pays_to">
						<option value="0">Select an Option</option>
						<option value="1"<cfif qGetCompRebates.Program_Pays_To IS 1>selected</cfif>>Distributor</option>
						<option value="2"<cfif qGetCompRebates.Program_Pays_To IS 2>selected</cfif>>Operator</option>
						<option value="4"<cfif qGetCompRebates.Program_Pays_To IS 4>selected</cfif>>Both</option>
					</select>
			</TD>
		</TR>
	<!--- D40991 :: Sysco - Update BB Expected Rate for Operator Deviated Programs.  CF Work  END --->
		<!--- D17171 Optional Payment and Deduction account information --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#general_labels[ deduction_account ]#: <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>This is optional information. If you do not know what value to enter here, leave this blank.</center>
				</CF_SmallHelp></B></TD>

			<TD><INPUT NAME="Deduction_Account" TYPE="text" VALUE="#qGetCompRebates.Deduction_Account#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ deduction_account ]# on View Program page:</B></TD>
			<TD><INPUT NAME="displayDeductionAccount" TYPE="checkbox" VALUE="1" <cfif qGetCompRebates.DeductionAccount_on_ViewProgramPage>Checked</cfif>></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#general_labels[ payment_account ]#: <CF_SmallHelp
					width="300"
					displayShifyX = "-200"
					imgPath="/Images/i.gif"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					>
				<center>This is optional information. If you do not know what value to enter here, leave this blank.</center>
				</CF_SmallHelp></B></TD>

			<TD><INPUT NAME="Payment_Account" TYPE="text" VALUE="#qGetCompRebates.Payment_Account#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ payment_account ]# on View Program page:</B></TD>
			<TD><INPUT NAME="displayPaymentAccount" TYPE="checkbox" VALUE="1" <cfif qGetCompRebates.PaymentAccount_on_ViewProgramPage>Checked</cfif>></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<!--- End account info --->

		<!--- PROGRAM INTERFACE LOCK --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Program Interface Lock:</B></TD>
			<TD>
			<cfif application.appsettingsget.getProgramLockTypeID() EQ 0>
			  <cfif qGetCompRebates.Program_Lock_Type_ID EQ 0>
				No<CF_SmallHelp
							width="300"
							displayShifyX = "-200"
							imgPath="/images/i.gif"
							imgWidth="12"
							imgHeight="11"
							dropdownCheck="0">
						<center>The setting called Program Lock Type is set to ‘Do Not Lock’, therefore you cannot change this claim mechanic setting</center>
					</CF_SmallHelp>
			  <cfelse>
				Yes<CF_SmallHelp
							width="300"
							displayShifyX = "-200"
							imgPath="/images/i.gif"
							imgWidth="12"
							imgHeight="11"
							dropdownCheck="0">
						<center>The setting called Program Lock Type is set to ‘Do Not Lock’, therefore you cannot change this claim mechanic setting</center>
					</CF_SmallHelp>
			  </cfif>
			<input type="hidden"  name = "Program_Lock_Type_ID"  value= "<cfoutput>#qGetCompRebates.Program_Lock_Type_ID#</cfoutput>" />
			 <cfelse>
					No <input type="radio" name="Program_Lock_Type_ID" value="0" <cfif qGetCompRebates.Program_Lock_Type_ID EQ 0>checked</cfif>>&nbsp;
					Yes <input type="radio" name="Program_Lock_Type_ID" value="<cfoutput>#application.appsettingsget.getProgramLockTypeID()#</cfoutput>" <cfif application.appsettingsget.getProgramLockTypeID() eq qGetCompRebates.Program_Lock_Type_ID>checked</cfif>>
				</cfif>
			</TD>
		</TR>
		<!--- PROGRAM INTERFACE LOCK --->

		<!--- Operating Group --->
		<cfif operatingGroupOn>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#operatingGroupManager.getLabel(operatingGroupLevel)#:</B></TD>
			<TD>
			<cfset qGetOperatingGroups = operatingGroupManager.get(level = operatingGroupLevel, active = 1) />
			<select name="Operating_Group_ID" style="width:200px">
				<cfloop query="qGetOperatingGroups">
				<option value="#Operating_Group_ID#" <cfif qGetCompRebates.Operating_Group_ID EQ Operating_Group_ID> selected</cfif>>#Operating_Group_Number# : #Operating_Group_Desc#</option>
				</cfloop>
			</select>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Allowance Code:</B></TD>
			<TD>
			<cfsilent>
			<cfset qGetAllowanceCodes = allowanceCodeManager.getAllowanceCodes() />
			<!------ going to re-use the code to get list of all component names for diffent discount types ----->
			<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
			<cfset discountTypeList = templateManager.getComponentDiscountTypeList() />
			<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(0, discountTypeList, 0,0,0,0,0) />
			<cfset usedAllowanceCodes = ValueList(qGetAllTemplateDiscountComponents.Allowance_Code_ID) />
			<cfset anyAllowanceCodeAvailable = 0 />
			</cfsilent>
			<select name="Allowance_Code_ID" style="width:200px">
				<option value="0">Select Allowance Code</option>
				<cfloop query="qGetAllowanceCodes">
				<cfif qGetCompRebates.Allowance_Code_ID EQ Allowance_Code_ID OR NOT ListFindNOCase(usedAllowanceCodes, Allowance_Code_ID)>
				<cfset anyAllowanceCodeAvailable = 1 />
				<option value="#Allowance_Code_ID#" <cfif qGetCompRebates.Allowance_Code_ID EQ Allowance_Code_ID> selected</cfif>>#Allowance_Code_Number# : #Allowance_Code_Desc#</option>
				</cfif>
				</cfloop>
			</select>
			<cfif anyAllowanceCodeAvailable EQ 0>
			<font color="red">No allowance code available.</font>
			</cfif>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Effective Rate % Required:</B></TD>
			<TD>
			<input type="Checkbox" name="Required_Effective_Rate_Percent" value="1" <cfif qGetCompRebates.Required_Effective_Rate_Percent EQ 1> checked</cfif> />
			</TD>
		</TR>
		</cfif>

		<cfif appSettings.getGL_Account_On()>

			<cfparam name="ExistingGLList" default="">
			<cfquery name="GetExistingGLs" datasource="#application.datasource#">
				SELECT GL_Account.*
				FROM GL_Account
				INNER JOIN GL_Component_Mapping
				ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
				AND GL_Component_Mapping.Discount_Type_ID = 2 <!--- CHANGE PER DISCOUNT TYPE --->
				AND GL_Component_Mapping.Component_Name_ID = '#qGetCompRebates.Program_Rebates_Component_Name_ID#'
			</cfquery>

			<cfset ExistingGLList = valuelist(GetExistingGLs.GL_Account_ID)>

			<cfif isdefined("form.ExistingGLList")>
				<cfquery name="DeleteComponentGL" datasource="#application.datasource#">
					DELETE FROM GL_Component_Mapping
					WHERE Component_Name_ID = <cfqueryparam value="#qGetCompRebates.Program_Rebates_Component_Name_ID#" cfsqltype="CF_SQL_INTEGER">
						AND Discount_Type_ID = 2
				</cfquery>

				<!--- Insert GLs --->
				<cfloop list="#form.ExistingGLList#" index="GL_Account_ID">
						<cfset useLakebaseForInsertNewGLS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_component_mapping")>
<cfif useLakebaseForInsertNewGLS>
	<cftry>
		<cfset application.oLakebase.insertRow("gl_component_mapping", {
			"gl_account_id" = "#GL_Account_ID#",
			"component_name_id" = "#qGetCompRebates.Program_Rebates_Component_Name_ID#",
			"discount_type_id" = "2"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertNewGLS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertNewGLS>
<cfquery name="InsertNewGLS" datasource="#application.datasource#">
							INSERT INTO GL_Component_Mapping
							(
								GL_Account_ID,
								Component_Name_ID,
								Discount_Type_ID
							)
							VALUES
							(
								'#GL_Account_ID#',
								'#qGetCompRebates.Program_Rebates_Component_Name_ID#',
								2
							)
						</cfquery>
</cfif>
				</cfloop>
			</cfif>
	<cfset useLakebaseForGLQuery = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_account")>
<cfif useLakebaseForGLQuery>
	<cftry>
		<cfset GLQuery = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_account", {
				"deleted" = "eq.0",
				"is_active" = "eq.1",
				"select" = "gl_account,gl_account_desc,gl_account_id"
			}), "gl_account,gl_account_desc,gl_account_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGLQuery = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGLQuery>
<cfquery name="GLQuery" datasource="#application.datasource#">
		SELECT GL_Account, GL_Account_Desc ,GL_Account_ID
		FROM GL_Account
		WHERE Deleted = 0
		AND Is_Active = 1
	</cfquery>
</cfif>
	<cfif GLQuery.recordCount GT 1>
			<TR>
				<td ALIGN="right" class="Orangline"><strong><cfoutput>#Application.GLAccountLabel#</cfoutput>s</strong></td><!---D42774 --->
				<td>
					<CF_button
						button_name		=	""
						button_caption	=	"Search for GLs"
						button_action	=	"return searchGL('','edit');"
						button_type		=	"javascript_link"
						button_width	=	"75"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</td>
			</TR>
	</cfif>
			<cfquery name="GetExistingGLs" datasource="#application.datasource#">
				SELECT GL_Account.*
				FROM GL_Account
				INNER JOIN GL_Component_Mapping
				ON GL_Component_Mapping.GL_Account_ID = GL_Account.GL_Account_ID
				AND GL_Component_Mapping.Discount_Type_ID = 2 <!--- CHANGE PER DISCOUNT TYPE --->
				AND GL_Component_Mapping.Component_Name_ID = '#qGetCompRebates.Program_Rebates_Component_Name_ID#'
			</cfquery>

			<cfset ExistingGLList = valuelist(GetExistingGLs.GL_Account_ID)>

			<cfif GetExistingGLs.Recordcount GT 0>
				<tr>
					<td align="right" valign="top" class="Orangline"><strong>Current GLs</strong></td>
					<td>
						<table bgcolor="WhiteSmoke" cellpadding="2" cellspacing="0">
							<!--- <cfdump var="#GetExistingGLs#"> --->
							<cfloop query="GetExistingGLs">
								<tr id="#GL_Account_ID#">
									<td>#GL_Account# (#Gl_Account_Desc#)</td>
									<td><img src="/images/scissor.gif" onclick="deleteGL(#GL_Account_ID#)" style="cursor: pointer;"></td>
								</tr>
							</cfloop>
						</table>
					</td>
				</tr>
			</cfif>
			<input name="ExistingGLList" value="#ExistingGLList#" type="hidden">
			<input type="hidden" name="Component_ID" value="#qGetCompRebates.Program_Rebates_Component_Name_ID#">
		</cfif>
		<input name="GLList" type="hidden" value="">

		<TR>
			<TD ALIGN="right" class="Orangline"><B>Is Retail:</B></TD>
				<TD>
					<input name="Is_Retail" type="checkbox" value="1" onClick="checkNetOutFixedPrice();" <cfif qGetCompRebates.Is_Retail EQ 1> checked</cfif> />
				</TD>
		</TR>
		<TR>
			<TD ALIGN="right" class="Orangline">
				<B>Net Out of Fixed Price:</B><br>
				<span style="font-size: 10px;display:compact;width:200px;color:##000000;text-align:left;">[this option is only available if Is Retail is on]</span>
			</TD>
			<TD>
				<input name="Net_Out_of_Fixed_Price" type="checkbox" value="1" <cfif qGetCompRebates.Net_Out_of_Fixed_Price EQ 1>checked</cfif> <cfif qGetCompRebates.Is_Retail EQ 0> disabled</cfif>  />
			</TD>
		</TR>
	</cfoutput>

		<!--- ***************************** select templates ***************************** --->
		<TR>
		<TD colspan="100%">
		<cfset component_select_templates_component_id = form.compId />
		<cfset component_select_templates_discount_type_id = 2 />
		<cfinclude template="/program_wizard/component_select_templates_grid.cfm" />
		</TD>
		</TR>
		<!--- ***************************** select Auto Pay Transaction Filters ***************************** --->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()><!--- if auto pay app switch is ON --->
		<TR>
		<TD colspan="2">

		<cfset maxCols = 1 />
		<cfset tdWidth = 100/maxCols />
		<CFSCRIPT>
		Border="Yes";
		BorderSize=1;
		BorderColor="orange";
		Image="/images/plus3.gif";
		ImageOpen="/images/minus3.gif";
		TitleColor="Blue";
		TitleFont="Arial";
		TitleSize=9;
		IsClosed="Yes";
		</CFSCRIPT>

		<CF_OPENLAYER
			BORDER="#Border#"							BORDERSIZE="#BorderSize#"
			BORDERCOLOR="#BorderColor#"					IMAGE="#Image#"
			IMAGEOPEN="#ImageOpen#"						TITLE="Select the transaction types to INCLUDE in Auto Pay calculations"
			TITLECLOSED="Select the transaction types to INCLUDE in Auto Pay calculations"	TITLETOOLTIP="Click here to toggle view"
			TITLECOLOR="#TitleColor#"					TITLEFONT="#TitleFont#"
			TITLESIZE="#TitleSize#"						ISCLOSED="#IsClosed#">

		<cfset componentNameId = form.compId />
		<cfset discountTypeId = 2 />

		<!--- Payee = Distributor --->
		<cfset payeeTypeId = 1 />
		<cfinclude template="/settings/program_component_fob_price_indicator_select.cfm" />

		<!--- Payee = Operator --->
		<cfset payeeTypeId = 2 />
		<cfinclude template="/settings/program_component_fob_price_indicator_select.cfm" />

		<!--- Payee = Broker --->
		<cfset payeeTypeId = 3 />
		<cfinclude template="/settings/program_component_fob_price_indicator_select.cfm" />

		</CF_OPENLAYER>
		</TD>
		</TR>
		</cfif><!--- if auto pay app switch is ON --->

		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return checkData('2','#qGetCompRebates.Program_Rebates_Component_Name_ID#');"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
<script>
	///////////////////////////////////   Update Component //////////////////////////////////////////
	function upadateComp(compId)
	{

		var actionFrm = document.DataForm;

		if (trim(actionFrm.compName.value) == "")
		{
			alert("Please provide a component name");
			return;
		}
		if (actionFrm.Allowance_Code_ID)
		{
			if (trim(actionFrm.Allowance_Code_ID.value) == "0")
			{
				alert("Please select an allowance code");
				return;
			}
		}
		<cfif appSettings.getGL_Account_On() AND appSettings.getGL_ACCOUNT_REQUIRED_FOR_COMP()>
		if (trim(actionFrm.ExistingGLList.value) == "" || ((listLength(actionFrm.ExistingGLList.value, ',') == listLength(actionFrm.GLList.value, ',')) && trim(actionFrm.GLList.value) != ""))
			{
				alert("Please add at least one <cfoutput>#Application.GLAccountLabel#</cfoutput>"); //D42774
				return false;
			}
		</cfif>

		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()>
		<cfoutput>
		if(anyFOBSelected(1) == 0) // payee = distributor
		{
			alert("Please select the transaction types to INCLUDE in Auto Pay calculations for payee = #application.returned_customer_setting.distributor_label_singular#");
			return false;
		}
		if(anyFOBSelected(2) == 0) // payee = operator
		{
			alert("Please select the transaction types to INCLUDE in Auto Pay calculations for payee = #application.returned_customer_setting.operator_label_singular#");
			return false;
		}
		if(anyFOBSelected(3) == 0) // payee = broker
		{
			alert("Please select the transaction types to INCLUDE in Auto Pay calculations for payee = #application.returned_customer_setting.broker_label_singular#");
			return false;
		}
		</cfoutput>
		</cfif>

		<cfif appSettings.get_Setting('Include_Second_Component_Feature') eq '1'>
		if($(".Include_Second_Component:checked").val() == 1)
		{
			if($("#Second_Component_Name_ID option:selected").val() == 0)
			{
				alert("Please select a 2nd component");
				return false;
			}

			if($("#Second_Component_Payment_Cycle_ID option:selected").val() == 0)
			{
				alert("Please select a payment cycle for the 2nd component");
				return false;
			}

			if($("#Second_Component_Payment_Type_ID option:selected").val() == 0)
			{
				alert("Please select a claim mechanic for the 2nd component");
				return false;
			}


		<cfif appsettings.getGL_Account_On() IS 1 AND appsettings.getGL_Account_Required_for_Comp() IS 1>
			if($("#Second_Component_GL_Account_ID option:selected").val() == 0)
			{
				alert("Please select a GL Account for the 2nd component");
				return false;
			}
		</cfif>
		}
		</cfif>

		actionFrm.compId.value = compId;
		actionFrm.command.value = 'update';
		actionFrm.display.value = actionFrm.returnTo.value;
		actionFrm.submit();
		$("#msgSave").append("<p>Saving changes, please wait...</p>");
		return false;
	}

	<cfinclude template="../credit_type_js.cfm" />
	</script>
	</FIELDSET>