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
<style>
.Orangline
{
	border-right: 2px solid orange;
	width:400px;
}
</style>


<!--- load custom labels for deduction account, payment account --->
<cfinclude template="/common_Files/general_labels.cfm">

<!--- get credit type details --->
<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()><!--- if auto pay app switch is ON --->
<cfsilent>
	<cfset qGetCreditTypes = application.oCreditTypeManager.getCreditTypes() />
	<cfset alreadySelectedCreditTypeExclusionList = "" />
</cfsilent>
</cfif><!--- if auto pay app switch is ON --->

<cfparam name="form.compExternalID" 	default="">
<cfparam name="form.compName" 	default="">
<cfparam name="form.Rebate_Percent_Option" 	default="1">

<!---D79237:  Rebate - OI and Redi START---->
	<cfset qGetALLCompRebates = compRebate.getActive(get_all_active = 1)>
	<cfset useLakebaseForqGetActiveComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetallcomprebates")>
<cfif useLakebaseForqGetActiveComps>
	<cftry>
		<cfset qGetActiveComps = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetallcomprebates", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveComps>
<cfquery name="qGetActiveComps" dbtype="query">
		SELECT *
		FROM qGetALLCompRebates
	</cfquery>
</cfif>
<!---D79237:  Rebate - OI and Redi END---->

<FIELDSET STYLE="padding:10px; width:1150px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Component Information</LEGEND>
	<table width="100%" border="0"   cellpadding="3" cellspacing="0">
		<!--- <colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup> --->
		<cfoutput>
		<!------ external id ----->
		<cfif application.returned_customer_setting.external_id_on EQ 1>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#ID.General_Labels_Label#:</B></TD>
			<TD><INPUT NAME="compExternalID" TYPE="text" VALUE="#form.compExternalID#" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #ID.General_Labels_Label# on View Program page:</B></TD>
			<TD><INPUT NAME="displayExternalID" TYPE="checkbox" VALUE="1"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<cfelse>
			<INPUT NAME="compExternalID" TYPE="hidden" VALUE="#form.compExternalID#">
			<INPUT NAME="displayExternalID" TYPE="hidden" VALUE="#form.displayExternalID#"><!---D58135 --->
		</cfif>
		<TR>
			<TD ALIGN="right" class="Orangline" width="50%"><B>Component Name:</B></TD>
			<TD width="50%"><INPUT NAME="compName" TYPE="text" MAXLENGTH="50" value="#form.compName#" style="width:220px"></TD>
		</TR>
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
			<li>If this option is set to 'Gross Sales', auto pay calculations will be based upon regular invoice records only. The application will not consider additional records such as credits.</li>
			<li>If this option is set to 'Net Sales', you will have the following additional options to select from:
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
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Net_Of_Cash_Discount"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Net_Of_Cash_Discount" checked>
			</TD>
		</TR>
		<TR id="id_autopay_netfreight" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Auto pay calculations are net of freight allowances:</B>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Net_Of_Freight_Allowance"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Net_Of_Freight_Allowance" checked>
			</TD>
		</TR>
		<TR id="id_autopay_excludecredit" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Auto pay should exclude by credit type:</B>
			</TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Auto_Pay_Exclude_Credit_Type" checked  onClick="showHideOptions()"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Auto_Pay_Exclude_Credit_Type"  onClick="showHideOptions()">
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
			</CF_SmallHelp></TD>
			<TD>
			<select name="Rebate_Margin_Percent_Option">
			<cfloop query="qMarginPercentOptions">
			<option value="#Rebate_Margin_Percent_Option_ID#" <cfif Rebate_Margin_Percent_Option_ID EQ form.Rebate_Margin_Percent_Option>SELECTED</cfif>>#Rebate_Margin_Percent_Option_Desc#</option>
			</cfloop>
			</select>
			</TD>
		</TR>
		<!--- Price Protection --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Rebate Type:</B></TD>
			<TD>
			<select name="Rebate_type">
			<option value="0">None</option>
      <option value="8">Accrual Budget</option>
			<option value="6">Add component value to invoice price</option><!---D38693 Simplot ENH - Off Invoice & Deviations--->
			<option value="1">Base Price Protection Rebate</option>
			<cfif appSettings.get_Setting('Blended_Rate') eq '1'>
			<option value="7">Blended Rate</option>
			</cfif>
			<option value="3">Exclude from margin calculation</option>
			<option value="5">Express as cost in margin</option>
			<option value="2">Price Protection Increase Rebate</option>
			<option value="4">Variable/Fixed Combo</option>
			<option value="9">Exclude from TPA/Reduce from Base Sales</option>
			</select>
			</TD>
		</TR>
		<!--- D38536  :: Alternate recapture rates per component START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Alternate <cfoutput>#appSettings.getPullbackLabel()#</cfoutput> Rates:</B></TD>
			<TD>
				No &nbsp;<input onclick="showHideAlternateRecapture();" type="radio" value="0" name="Alternate_Recapture_Rate" checked>
				&nbsp;&nbsp;
				Yes <input onclick="showHideAlternateRecapture();"  type="radio" value="1" name="Alternate_Recapture_Rate">
			</TD>
		</TR>
		<TR class="alternateRatesTR1" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B><cfoutput>#appSettings.getPullbackLabel()# #LCase(application.returned_customer_setting.operator_label_singular)#</cfoutput> exclusion:</B></TD>
			<TD>
				No &nbsp;<input onclick="showHideAlternateRecapture();" type="radio" value="0" name="Alternate_Recapture_By_Operator" checked>
				&nbsp;&nbsp;
				Yes <input onclick="showHideAlternateRecapture();"  type="radio" value="1" name="Alternate_Recapture_By_Operator">
			</TD>
		</TR>
	<cfloop from="1" to="3" index="i">
		<cfset TRID = 1 />
		<cfif i GT 1>
			<cfset TRID = "" />
		</cfif>
		<TR class="alternateRatesTR#TRID#" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>Alternate Rate #i#:</B></TD>
			<TD>
				<table>
					<tr>
							<td><input type="checkbox" name="rate#i#" value="1"></td>
							<td><B>Label : &nbsp;</B><input type="text" name="description#i#" value="" style="width:200px"></td>
							<td valign="top">
								<span class="alternateRatesTemplate">
											<CF_button
											button_name		=	""
											button_caption	=	"templates"
											button_action	=	"templateAlternateRate(#i#, 0);"
											button_type		=	"javascript_link"
											button_width	=	"75"
											button_color	=	"Navy"
											button_tip		=	""
											font_color		=	"White"
											font_size		=	"12"
											font_weight		=	"bold"
										>
								</span>
							<input type="hidden" name="AlternateRateTemplateList#i#" value="">
							</td>
					</tr>
				</table>
			</TD>
		</TR>
	</cfloop>


		<!--- D38536  :: Alternate recapture rates per component END--->

		<!---D79237:  Rebate - OI and Redi START--->
		<cfif appSettings.get_Setting('Include_Second_Component_Feature') eq '1'>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Include 2nd Component With Same Rates:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Include_Second_Component"  class="Include_Second_Component" checked onclick="$('.SecondCompNameId').hide();">
				&nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Include_Second_Component"  class="Include_Second_Component" onclick="$('.SecondCompNameId').show();">
			</TD>
		</TR>
		</cfif>
		<TR class="SecondCompNameId" style="display:none;">
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd #Application.RebateLabel# Component:<br />
				<select name="Second_Component_Name_ID" id="Second_Component_Name_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="qGetActiveComps">
					<option value="#Program_Rebates_Component_Name_ID#">#Program_Rebates_Component_Name#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<TR class="SecondCompNameId" style="display:none;">
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component Payment Cycle:<br />
				<select name="Second_Component_Payment_Cycle_ID" id="Second_Component_Payment_Cycle_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="qGetPaymentCycles">
					<option value="#Payment_Cycle_ID#">#Payment_Cycle#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<TR class="SecondCompNameId" style="display:none;">
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component Claim Mechanic:<br />
			<select name="Second_Component_Payment_Type_ID" id="Second_Component_Payment_Type_ID" style="width:200px;">
					<option value="0">Select one option</option>
					<cfloop query="GetClaimMechInfo">
					<option value="#Payment_Type_ID#">#Payment_Type_Name#</option>
					</cfloop>
				</select>
			</TD>
		</TR>
		<cfif appsettings.getGL_Account_On() IS 1>
		<TR class="SecondCompNameId" style="display:none;">
			<TD ALIGN="right" class="Orangline">&nbsp;</TD>
			<TD>2nd Component GL Account:<br />
				<select name="Second_Component_GL_Account_ID" id="Second_Component_GL_Account_ID" style="width:200px;">
						<option value="0" SELECTED>Select one option</option>
					<cfloop query="qGetGLs">
						<option value="#GL_Account_ID#">
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
				No &nbsp;<input type="radio" value="0" name="Exclude_From_Recapture" checked>
				&nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Exclude_From_Recapture">
			</TD>
		</TR>
		<!--- Interface as Rate --->
		<!--- Dev Note: KAL; D17073: AE - Variable Scan Conversion --->
		<!--- 38973 Remove rebate component setting - Interface as Rate
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Interface as Rate:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Interface_as_Rate"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Interface_as_Rate" checked>
			</TD>
		</TR> --->

		<!--- Accrual --->
		<cfif appSettings.getShow_Component_Accrual()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Accrual On:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Accrual_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Accrual_On">
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Accrual_On" value ="0">
		</cfif>

		<!--- 34114 --->
		<tr>
			<TD ALIGN="right" class="Orangline"><B>Recapture rate sources from program's budget (instead of program):</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" checked name="Recapture_Rate_From_Program_Budget"> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Recapture_Rate_From_Program_Budget">
			</TD>
		</tr>

		<!--- Brokerage --->
		<cfif appSettings.getBrokerage_Functionality_On()>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Exclude Brokerage:</B></TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Exclude_Brokerage" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Exclude_Brokerage" >
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="Exclude_Brokerage" value ="0">
		</cfif>

 	<!---
				Dev Notes: D23988/Anand Rao/30-Jun-10
				Rebate Component Setting change Off Invoice Label
	--->
		<TR>
			<TD ALIGN="right" class="Orangline">
        <B>Display Off Invoice Claim Mechanics:</B><br>
        <span style="font-size: 10px;display:compact;width:200px;color:##000000;text-align:left;">[if yes is selected, only claim mechanics with Off Invoice set to 'yes' will be shown for this component]</span>
      </TD>
			<TD>
				No &nbsp;<input type="radio" value="0" name="Off_Invoice_On" checked> &nbsp;&nbsp;
				Yes <input type="radio" value="1" name="Off_Invoice_On">
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
				Yes <input type="radio" onclick="Toggle('show','ExpectedRateTR')" value="1" name="Update_BB_Expected_Rate">
			</TD>
		</TR>
		<TR class="ExpectedRateTR" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>BB Expected Rate should be:</B></TD>
			<TD>
					<select name="Expected_Rate">
						<option value="0">Select an option</option>
						<option value="1">Set to $0</option>
						<option value="2">Less than program's rebate rate</option>
						<option value="3">Add program's rebate rate</option>
					</select>
			</TD>
		</TR>
<!--- 91550 :: Enhancement: Template-specific Expected Rate Adjustments START --->
			<TR class="ExpectedRateTR" style="display:none;">
				<TD ALIGN="right" class="Orangline"><B>Apply Expected Rate to:</B></TD>
				<TD>
						<select name="Expected_Rate_Affect_Discount_Type">
							<option value="0">Select an Option</option>
							<option value="1">Fixed</option>
							<option value="2">Rebate</option>
							<option value="3">Both</option>
						</select>
				</TD>
			</TR>

				<TR class="ExpectedRateTR" style="display:none;">
					<TD ALIGN="right" class="Orangline"><B>Apply to all templates:</B></TD>
					<TD>
						<table>
							<tr>
								<td>
									No &nbsp;<input type="radio" value="0" name="Expected_Rate_Apply_All_Templates" checked  onclick="$('##TemplateLink').show();"> &nbsp;&nbsp;
								</td>
								<td>
									Yes <input type="radio" value="1" name="Expected_Rate_Apply_All_Templates"  onclick="$('##TemplateLink').hide();">
								</td>
								<td>
									<input type="hidden" name="ExpectedRateTemplateList" value="">
									<CF_button
									button_name		=	""
									button_caption	=	"templates"
									button_action	=	"template('', 0);"
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
		<TR class="ExpectedRateTR" style="display:none;">
			<TD ALIGN="right" class="Orangline"><B>When the BB Payee Type is:</B></TD>
			<TD>
					<select name="Program_Pays_To">
						<option value="0">Select an option</option>
						<option value="1">Distributor</option>
						<option value="2">Operator</option>
						<option value="4">Both</option>
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

			<TD><INPUT NAME="Deduction_Account" TYPE="text" VALUE="" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ deduction_account ]# on View Program page:</B></TD>
			<TD><INPUT NAME="displayDeductionAccount" TYPE="checkbox" VALUE="1"></TD>
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

			<TD><INPUT NAME="Payment_Account" TYPE="text" VALUE="" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Display #general_labels[ payment_account ]# on View Program page:</B></TD>
			<TD><INPUT NAME="displayPaymentAccount" TYPE="checkbox" VALUE="1"></TD>
		</TR>
		<!--- D58135 ::  Additional Component info displaye inside program END--->
		<!--- End account info --->

		<!--- PROGRAM INTERFACE LOCK --->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Program Interface Lock:</B></TD>
			<TD>
				<cfif application.appsettingsget.getProgramLockTypeID() EQ 0>
					No <CF_SmallHelp
							width="300"
							displayShifyX = "-200"
							imgPath="/images/i.gif"
							imgWidth="12"
							imgHeight="11"
							dropdownCheck="0"
					>
				<center>The setting called Program Lock Type is set to 'Do Not Lock', therefore you cannot change this setting.</center>
				</CF_SmallHelp>

				<input type="hidden"  name = "Program_Lock_Type_ID"  value= "0" />
				<cfelse>
					No<input type="radio" name="Program_Lock_Type_ID" value="0" checked>&nbsp;
					Yes <input type="radio" name="Program_Lock_Type_ID" value="<cfoutput>#application.appsettingsget.getProgramLockTypeID()#</cfoutput>">
				</cfif>
			</TD>
		<TR>
		<!--- PROGRAM INTERFACE LOCK --->

		<!--- Operating Group --->
		<cfif operatingGroupOn>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>#operatingGroupManager.getLabel(operatingGroupLevel)#:</B></TD>
			<TD>
			<cfset qGetOperatingGroups = operatingGroupManager.get(level = operatingGroupLevel, active = 1) />
			<select name="Operating_Group_ID" style="width:200px">
				<cfloop query="qGetOperatingGroups">
				<option value="#Operating_Group_ID#">#Operating_Group_Number# : #Operating_Group_Desc#</option>
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
				<cfif NOT ListFindNOCase(usedAllowanceCodes, Allowance_Code_ID)>
				<cfset anyAllowanceCodeAvailable = 1 />
				<option value="#Allowance_Code_ID#" <cfif form.Allowance_Code_ID EQ Allowance_Code_ID>selected</cfif>>#Allowance_Code_Number# : #Allowance_Code_Desc#</option>
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
			<input type="Checkbox" name="Required_Effective_Rate_Percent" value="1" />
			</TD>
		</TR>
		</cfif>

<cfif appSettings.getGL_Account_On()>

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
		<TR id="ShowGLSearch" >
			<td ALIGN="right" class="Orangline"><strong><cfoutput>#Application.GLAccountLabel#</cfoutput>s</strong></td><!---D42774 --->
			<td><CF_button
					button_name		=	""
					button_caption	=	"Search for GLs"
					button_action	=	"return searchGL('','add');"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				></td>
		</TR>

		<tr id="ShowGLInfo" style="display: none">
		<td align="right" valign="top" class="Orangline"><strong>Current GLs</strong></td>
		<td>
			<cfdiv bind="url:/settings/GL_Account/componentGL.cfm?GLList={GLList}" ID="compInfo"/>
			<input name="GLList" type="hidden" value="">
		</td>
		</tr>
	<cfelse>
		<tr>
		<td align="right" valign="top" class="Orangline"><strong>Current GLs</strong></td>
		<td>
			#GLQuery.GL_Account# (#GLQuery.GL_Account_Desc#)
			<input name="GLList" type="hidden" value="#GLQuery.GL_Account_ID#">
		</td>
		</tr>
	</cfif>
</cfif>

		<input type="hidden" name="Component_ID" value="">
		<input name="ExistingGLList" type="hidden" value="">

		<TR>
			<TD ALIGN="right" class="Orangline"><B>Is Retail:</B></TD>
				<TD>
					<input name="Is_Retail" type="checkbox" value="1" onClick="checkNetOutFixedPrice();" />
				</TD>
		</TR>
		<TR>
			<TD ALIGN="right" class="Orangline"><B>Net Out of Fixed Price:</B></TD>
				<TD>
					<input name="Net_Out_of_Fixed_Price" type="checkbox" value="1" disabled />
				</TD>
			</TR>
		<!---95126 START--->
		<TR>
			<TD ALIGN="right" class="Orangline"><B>TPO Field:</B></TD>
			<TD>
				<select name="TPO_Field" style="width:200px">
					<option value="0">None</option>
					<option value="1">EDLP</option>
					<option value="2">Promo Event</option>
				</select>
			</TD>
			</TR>
			<TR>
			<TD ALIGN="right" class="Orangline"><B>TPO Rate Type:</B></TD>
			<TD>
			<select name="TPO_Rate_Type" style="width:200px">
				<option value="0">None</option>
				<option value="1">Base Rate</option>
				<option value="2">OI Rate</option>
				<option value="3">BB Rate</option>
				<option value="4">Scan Rate</option>
				<option value="5">Lump Sum</option>
			</select>
			</TD>
		</TR>
		<!---95126 END--->

		</cfoutput>

		<!--- ***************************** select templates ***************************** --->
		<TR>
		<TD colspan="100%">
		<cfset component_select_templates_component_id = -1 />
		<cfset component_select_templates_discount_type_id = 2 />
		<cfinclude template="/program_wizard/component_select_templates_grid.cfm" />
		</TD>
		</TR>

		<!--- ***************************** select Auto Pay Transaction Filters ***************************** --->
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()>
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
		IsClosed="No";
		</CFSCRIPT>

		<CF_OPENLAYER
			BORDER="#Border#"							BORDERSIZE="#BorderSize#"
			BORDERCOLOR="#BorderColor#"					IMAGE="#Image#"
			IMAGEOPEN="#ImageOpen#"						TITLE="Select the transaction types to INCLUDE in Auto Pay calculations"
			TITLECLOSED="Select the transaction types to INCLUDE in Auto Pay calculations"	TITLETOOLTIP="Click here to toggle view"
			TITLECOLOR="#TitleColor#"					TITLEFONT="#TitleFont#"
			TITLESIZE="#TitleSize#"						ISCLOSED="#IsClosed#">

		<cfset componentNameId = 0 />
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
		</cfif> <!--- if auto pay app switch is ON --->

		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return checkData('2','');"
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

	function addComp()
	{

		var actionFrm = document.DataForm;

		if (trim(actionFrm.compName.value) == "")
		{
			alert("Please provide a component name");
			return false;
		}
		if (actionFrm.Allowance_Code_ID)
		{
			if (trim(actionFrm.Allowance_Code_ID.value) == "0")
			{
				alert("Please select an allowance code");
				return false;
			}
		}
		<cfif appSettings.getGL_Account_On() AND appSettings.getGL_ACCOUNT_REQUIRED_FOR_COMP()>

		if (trim(actionFrm.GLList.value) == "" )
			{
				alert("Please add at least one <cfoutput>#Application.GLAccountLabel#</cfoutput>");//D42774
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

		//set hidden form fields and submit
		actionFrm.command.value = 'addComp';
		actionFrm.display.value = 'active';
		actionFrm.submit();
		$("#msgSave").append("<p>Saving changes, please wait...</p>");
		return false;

	}

	<cfinclude template="../credit_type_js.cfm" />
	</script>
</FIELDSET>