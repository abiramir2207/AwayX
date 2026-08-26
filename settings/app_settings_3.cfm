<cfset jQueryUI.widgets = "full">
<cfinclude template="/common_files/jQuery.cfm">

<style>
	.appSettingsInput {
		text-align: right;
		width: 50px;
	}
	label > span {
		display: inline-block;
		width: 230px;
		position: relative;
		top: -2px;
	}
	div.setting {
		margin:2px 20px;
		padding:2px 5px 2px 5px;
		width: 470px;
		vertical-align: middle;
		/* border: 1px solid black; */
	}
	div.setting:hover {
		background-color: #e6bf9b;
	}
	div.secondary, label.secondary {
		margin-left: 30px;
	}
	input.cb_default {
		margin-right: 30px;
	}
	input[type=radio] {
		position2: relative;
		top2: 3px;
	}
	div.section {
		border-bottom: 1px solid blue;
	}
	span.ui-displayRow { 
		display: inline-block; 
	}
</style>
<!------ settings.cfm ----->
<cfset pageIdentifier = 3>
<cfoutput>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfif form.state>
	<cfparam name="form.ApprovalPoundMarginOn" 				default="0">
	<cfparam name="form.ApprovalPercentMarginOn" 			default="0">
	<cfparam name="form.ApprovalTotalPgmMarginOn" 			default="0">
	<cfparam name="form.ApprovalSpendingCapOn" 				default="0">
	<cfparam name="form.ApprovalLayeredOn" 					default="0">
	<cfparam name="form.ApprovalStandardOn" 				default="0">
	<cfparam name="form.approvalLayeredCosts" 				default="0">
	<cfparam name="form.approvalLayeredBidrequestSpecial" 	default="0">
	<cfparam name="form.Use_DC_SO_Base_sales" 				default="0">
	<cfparam name="form.use_cost_multiplier"				default="0">
	<cfparam name="form.Margin_Display_LB" 					default="0">
	<cfparam name="form.Margin_Display_CS" 					default="0">
	<cfparam name="form.Margin_Display_EQ" 					default="0">
	<cfparam name="form.Margin_Display_Default" 			default="0">
	<cfparam name="disposableOn" 							default="0">
	<cfparam name="layeredOn" 								default="0">
	<cfparam name="StandardOn" 								default="0">
	<cfparam name="form.Approve_LS_Component_By_Profile"	default="0">
	<cfparam name="form.Approval_Margin_Type"				default="0">
	<cfparam name="form.Display_Trade_Percent_on_Margin"	default="0">
  	<cfparam name="FORM.Margin_Operating_Income_Percent_Type" default="1">
	<cfparam name="form.TPA_Includes_PreActive"	default="1">
	<cfparam name="form.TPA_Includes_Active"	default="1">
	<cfparam name="form.TPA_Includes_Expiring"	default="1">
	<cfparam name="form.TPA_Includes_Program_Dates"	default="1">
	<cfparam name="form.OperatorTPAInDistributorPrograms" 	default="0">
	<cfparam name="form.LS_Allocation" 	default="0"><!--- D30065:LUMP SUM DOLLAR ALLOCATION ON CASE VOLUME BASIS  --->
	<cfparam name="form.Sequential_Net_Sales_Operating_Margin" 	default="0">


	<cfset appSettings = genSettingsManager.get(0)>
	<cfset appSettings.setApprovalPoundMarginOn(form.ApprovalPoundMarginOn)>
	<cfset appSettings.setApprovalPercentMarginOn(form.ApprovalPercentMarginOn)>
	<cfset appSettings.setApprovalTotalPgmMarginOn(form.ApprovalTotalPgmMarginOn)>
	<cfset appSettings.setApprovalSpendingCapOn(form.ApprovalSpendingCapOn)>
	<cfset appSettings.setApprovalLayeredCosts(form.approvalLayeredCosts)>
	<cfset appSettings.setusecostmultiplier(form.use_cost_multiplier)>
	<cfset appSettings.setUseDCSOBasesales(form.Use_DC_SO_Base_sales)>
	<cfset appSettings.setMarginDisplayLB(form.Margin_Display_LB)>
	<cfset appSettings.setMarginDisplayCS(form.Margin_Display_CS)>
	<cfset appSettings.setMarginDisplayEQ(form.Margin_Display_EQ)>
	<cfset appSettings.setMarginDisplayDefault(form.Margin_Display_Default)>
	<cfset appSettings.setApproveLSComponentByProfile(form.Approve_LS_Component_By_Profile)>
	<cfset appSettings.setApprovalMarginType(form.Approval_Margin_Type)>
	<cfset appSettings.setDisplay_Trade_Percent_on_Margin(form.Display_Trade_Percent_on_Margin)>
	<cfset appSettings.setMarginOperatingIncomePercentType(form.Margin_Operating_Income_Percent_Type)>
	<cfset appSettings.setTPA_Includes_PreActive(form.TPA_Includes_PreActive)>
	<cfset appSettings.setTPA_Includes_Active(form.TPA_Includes_Active)>
	<cfset appSettings.setTPA_Includes_Expiring(form.TPA_Includes_Expiring)>
	<cfset appSettings.setTPA_Includes_Program_Dates(form.TPA_Includes_Program_Dates)>
	<cfset appSettings.setOperatorTPAInDistributorPrograms(form.OperatorTPAInDistributorPrograms)>
	<cfset appSettings.setLS_Allocation(form.LS_Allocation)><!--- D30065:LUMP SUM DOLLAR ALLOCATION ON CASE VOLUME BASIS --->
	<cfset appSettings.setSequentialNetSalesOperatingMargin(form.Sequential_Net_Sales_Operating_Margin)>


	<cfif form.ApprovalLayeredOn EQ 5>
		<cfset layeredOn = 1>
	<cfelseif form.ApprovalLayeredOn EQ 6>
		<cfset disposableOn = 1>
	<cfelseif form.ApprovalLayeredOn EQ 7>
		<cfset StandardOn = 1>
	</cfif>
	<cfset appSettings.setApprovalLayeredOn(layeredOn)>
	<cfset appSettings.setApprovaldisposableOn(disposableOn)>
	<cfset appSettings.setApprovalStandardOn(StandardOn)>



	<cfset appSettings.setUpdatedBy(request.AccessStructure.User_ID)>
	<cfset genSettingsManager.save(pageIdentifier)>

	<cfset oProfiles = CreateObject("component", "components.settings.profiles.profile") />
	<cfset oProfiles.removeInvalidMarginUOMSelection(profileId = 0) />
	<cfset oProfiles.setMarginUOMDefaultSelect(profileId = 0) />

	<cflocation addtoken="No" url="#thisPage#">

	<cfabort>
</cfif>

<cfset appSettings = genSettingsManager.get(1, pageIdentifier, 1)>
<cf_include files="/Script/javascript/string_functions.js, /styles/css-loader.css">

<script language="JavaScript">

function CheckLumpSumApprovalByComponent()
{
	if(document.all.ApprovalLayeredOn[0].checked == false)
	{
		alert("You must select layered approval scheme, before you can select Lumpsum Approval by component");
		document.all.Approve_LS_Component_By_Profile.checked = false;
	}
}

function RemoveLumpSumApprovalByComponent()
{
		document.all.Approve_LS_Component_By_Profile.checked = false;
}

function validateAndSubmit(thisForm)
{
	var isValid = true;
	if(document.all.ApprovalLayeredOn[0].checked == true && thisForm.Margin_Display_LB.checked == false && thisForm.Margin_Display_CS.checked == false && thisForm.Margin_Display_EQ.checked == false)
	{
	queueMessage("Select atleast one margin display type",document.all.error_MarginDisplay);
	isValid = false;
	}
	else
	{
	clearQueue(document.all.error_MarginDisplay);
	}
	if(document.all.ApprovalLayeredOn[0].checked == true && thisForm.Margin_Display_default[0].checked == false && thisForm.Margin_Display_default[1].checked == false && thisForm.Margin_Display_default[2].checked == false)
	{
	queueMessage("Select a default margin display type",document.all.error_MarginDisplay);
	isValid = false;
	}
	else
	{
	clearQueue(document.all.error_MarginDisplay);
	}
	if(document.all.Margin_Display_default[0].checked && thisForm.Margin_Display_LB.checked == false)
	{
			isValid = false;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_Margin_Display_default_1);
	}
	else
	{
		clearQueue(document.all.error_Margin_Display_default_1);
	}
	if(document.all.Margin_Display_default[1].checked && thisForm.Margin_Display_CS.checked == false)
		{
			isValid = false;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_Margin_Display_default_2);
		}
	else
	{
		clearQueue(document.all.error_Margin_Display_default_2);
	}
		if(document.all.Margin_Display_default[2].checked && thisForm.Margin_Display_EQ.checked == false)
		{
			isValid = false;
			queueMessage("To set an item as default, you must choose to include it.", document.all.error_Margin_Display_default_3);
		}
	else
	{
		clearQueue(document.all.error_Margin_Display_default_3);
	}

	

	if(isValid)
	{
		show_loader("SAVING CHANGES, PLEASE WAIT...");
		let margin_display_style = $("select[name=margin_display_style]");
        /* approval layered not selected - reset the margin display type setting back to blacksmith */								
		if (!document.getElementById('app_layered').checked) {
			margin_display_style.val( "blacksmith" );
		}
		else {
			/* assign cost sequencing */
			// let seq = 100;
			// $(".seq").each(function() { seq = seq + 10;
			// 							let name_prefix = $(this).attr("name");
			// 							let selected_element = $("input[name=" + name_prefix + "_selected");

			// 							/*assign sequence value based on position*/
			// 							$("input[name=" + name_prefix + "_seq").val( seq );
			// 							if ($(this).attr("checked")) {
			// 								selected_element.val( "checked" );
			// 							}
			// 							else {
			// 								selected_element.val( "" );
			// 							}
			// 						});
		}
		zeroCheckBoxes();
		submitForm(thisForm, "Settings#pageIdentifier#");
	}
	else
	{
		showMessageWindow();
	}
}
</script>
<CF_MessageWindow>
<br>

<cfif Len(appSettings.getUpdatedBy()) GT 0>
	<div class="last_updated">
		The settings were last updated on #dateformat(appSettings.getUpdatedOn(), 'mm/dd/yyyy')# #timeformat(appSettings.getUpdatedOn(), 'hh:mm:ss TT')# by #appSettings.getUpdatedByUserName()#
	</div>
</cfif>

<div class="setting">
	<label><span class="text">Approval - Spending Cap is On:</span> <input type="checkbox" value="1" name="ApprovalSpendingCapOn" <cfif appSettings.getApprovalSpendingCapOn() IS 1>checked</CFIF> onclick="RemoveLumpSumApprovalByComponent()"></label>
</div>

<cfset approval_layered_selected = 0>
<div class="setting">
	<cfset margin_display_style = application.util.query.get_Setting("Margin_Display_Style", 0)>
	<label><span>Approval - Layered:</span> <input type="radio" value="5" name="ApprovalLayeredOn" id="app_layered" <cfif appSettings.getapprovallayeredon() IS 1>checked<cfset approval_layered_selected = 1></cfif>></label>
	<div class="secondary">
		<label style="margin:0 10px 0 1px;">Layered Margin Display Style:</label>
		<select name="margin_display_style">
			<option value="blacksmith" <cfif margin_display_style eq "">selected</cfif>>Blacksmith</option>
            <option value="custom_t" <cfif margin_display_style eq "custom_t">selected</cfif>>Custom_T</option>
            <cfif application.util.query.get_Setting("custom_rfp_process", 0)>
                <option value="custom_h" <cfif margin_display_style eq "custom_h">selected</cfif>>Custom_H</option>
            </cfif>
		</select> <img src="/images/help_small.gif" title="Custom_T means the margin page is based on custom_t requirements">
	</div>
</div>

<div class="setting" id="costs" <cfif margin_display_style neq "custom_t">style="display:none;"</cfif>>
	<cfset qCostSetting = application.util.query.get_Settings("margin_cost_predictive_selected, margin_cost_production_selected, margin_cost_historical_selected")>
	<h3 style="margin:0;padding:0;">Cost Sequencing:</h3>
	<hr class="six">
	<div class="secondary">
		<table>
		<tbody>
			<tr> <td><label><input type="checkbox" name="Margin_Cost_Predictive_Selected" #(qCostSetting.margin_cost_predictive_selected is "on" ? "checked" : "")#> Predictive</label></td> </tr>
			<tr> <td><label><input type="checkbox" name="Margin_Cost_Production_Selected" #(qCostSetting.margin_cost_production_selected is "on" ? "checked" : "")#> Production</label></td> </tr>
			<tr> <td><label><input type="checkbox" name="Margin_Cost_Historical_Selected" #(qCostSetting.margin_cost_historical_selected is "on" ? "checked" : "")#> Historical</label></td> </tr>
		</tbody>
		</table>	
	</div>
	<hr class="six">
</div>

<div class="setting" style="width:475px">
	<label><span>Approval Margin Type:</span></label>
	<div class="secondary">
		<!--- Approval_Margin_Type = 0 is Margin = Operating Income --->
		<label>
			<input type="radio" value="0" name="Approval_Margin_Type" <cfif appSettings.getApprovalMarginType() eq 0>checked</CFIF> onclick="document.all.OperatingIncomePercent.style.display = '';">Margin = Operating Income&nbsp;
		</label>
		<img src="/images/help_small.gif" 
			<!--- The "Title" is supposed to be on one line. Do not change it. --->
			Title="This option drives approvals based on 'operating income percentage'.  The operating income percent is calculated as operating income dollars / Net Sales dollars.  Net sales dollars is calculated as Base Price - Cash Discount - Allowances - Trade Adjustment."><br>
		<span Id="OperatingIncomePercent" <cfif appSettings.getApprovalMarginType() neq 0>style="display:none"</cfif>>
			<div style="margin-left:33px;">
				Operating Income%:
				<label><input type="radio" value="1" name="Margin_Operating_Income_Percent_Type" <cfif appSettings.getMarginOperatingIncomePercentType() eq 1>checked</cfif>> Oper Income $ / Net Sales</label>
				<label><input type="radio" value="2" name="Margin_Operating_Income_Percent_Type" <cfif appSettings.getMarginOperatingIncomePercentType() eq 2>checked</cfif>> Oper Income $ / Base Sales</label><br>
				<!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
				<label><input type="checkbox" value="1" name="Display_Trade_Percent_on_Margin" <cfif appSettings.getDisplay_Trade_Percent_on_Margin() eq 1>checked</cfif>>	Display column for Trade %</label>
			</div>
		</span>

		<!--- Approval_Margin_Type = 1 is Margin = Operating Income --->
		<label>
			<input type="radio" value="1" name="Approval_Margin_Type" <cfif appSettings.getApprovalMarginType() eq 1>checked</CFIF> onclick="document.all.OperatingIncomePercent.style.display = 'none';">Margin = Trade %&nbsp;
		</label>
		<img src="/images/help_small.gif"
			<!--- The "Title" is supposed to be on one line. Do not change it. --->
			Title="Some clients cannot rely upon their cost data as a core variable of the approval scheme.  This option drives approvals based on 'trade'. Trade % is calculated as:  (Allow + Trade Adj) / Base Sales."><br>

		<!--- Approval_Margin_Type = 2 is Approval = Annual Case Rate --->
		<label>
			<input type="radio" value="2" name="Approval_Margin_Type" <cfif appSettings.getApprovalMarginType() eq 2>checked</CFIF> onclick="document.all.OperatingIncomePercent.style.display = 'none';">Approval = Annual Case Rate&nbsp;
		</label>
		<img src="/images/help_small.gif"
			<!--- The "Title" is supposed to be on one line. Do not change it. --->
			Title="This option drives approvals based on the effective annualized spending rate per case.  Each approved program is resolved to an annualized spending rate and evaluated against category-level targets vis-a-vis the user profile."><br>
		
		<label>
			<input type="radio" value="3" name="Approval_Margin_Type" <cfif appSettings.getApprovalMarginType() eq 3>checked</CFIF>>Absolute Net Sales $&nbsp;
		</label>
		<img src="/images/help_small.gif"
			<!--- The "Title" is supposed to be on one line. Do not change it. --->
			Title="This option drives approvals based on Absolute Net Sales $ at either Lb, Case or Equiv Cs UOM">
	</div>
</div>

<div class="setting">
	<cfset Margin_Profile_Variance_Type = application.util.query.get_Setting("Margin_Profile_Variance_Type", 0)>
	<label><span>Profile Variance Type:</span> </label>
	<label><input value="1" type="radio" name="Margin_Profile_Variance_Type" <cfif Margin_Profile_Variance_Type NEQ '2'>checked="checked"</cfif>>Percent variance to target</label>
	<img src="/images/help_small.gif"
		<!--- The "Title" is supposed to be on one line. Do not change it. --->
		Title="Percent variance to target:  Variance defined will calculate as Target Margin +/- [Target Margin * Variance]. For example 40% target with 20 % variance will result in 48% margin approval level [40 + (40*20)] when Margin = Trade %. Otherwise, margin approval level will be 32% [40 - (40*20)]">
	<br><label><span> </span> </label>
	<label><input value="2" type="radio" name="Margin_Profile_Variance_Type" <cfif Margin_Profile_Variance_Type EQ '2'>checked="checked"</cfif>>Absolute variance from target</label>
	<img src="/images/help_small.gif"
		<!--- The "Title" is supposed to be on one line. Do not change it. --->
		Title="Absolute variance from target: Variance defined will add/subtract from Target Margin. Example 40% target with 5% variance. If Margin = Trade %, New target is 45%. Otherwise new target is 35%."><br>
</div>
		
<div class="setting">
	<label><span>Lump Sum Approval by Component:</span> <input value="1" type="checkbox" name="Approve_LS_Component_By_Profile" <cfif appSettings.getApproveLSComponentByProfile()>checked</cfif> onclick="CheckLumpSumApprovalByComponent()"></label>
</div>

<div class="setting">
	<label><span>Lump Sum Allocation:</span></label>
	<label><input value="1" type="radio" name="LS_Allocation" <cfif appSettings.getLS_Allocation() EQ 1>checked="checked"</cfif>>Case</label>
	<label><input value="2" type="radio" name="LS_Allocation" <cfif appSettings.getLS_Allocation() EQ 2>checked="checked"</cfif>>Pound</label>
</div>

<div class="setting">
	<label><span><span id="error_MarginDisplay"></span>Margin displayed in LB unit of measure:</span></label>
	<input value="1" class="cb_default" type="checkbox" name="Margin_Display_LB" <cfif appSettings.getMarginDisplayLB()>checked</cfif>>
	<label><input value="3" type="radio" name="Margin_Display_default" <cfif appSettings.getMarginDisplaydefault() EQ 3>checked</cfif>>(Default)</label>
	<span id="error_Margin_Display_default_1"></span>
</div>

<div class="setting">
	<label><span>Margin displayed in CS unit of measure:</span> </label>
	<input value="1" class="cb_default" type="checkbox" name="Margin_Display_CS" <cfif appSettings.getMarginDisplayCS()>checked</cfif>>
	<label><input value="1" type="radio" name="Margin_Display_default" <cfif appSettings.getMarginDisplaydefault() EQ 1>checked</cfif>>(Default)</label>
	<span id="error_Margin_Display_default_2"></span>
</div>

<div class="setting">
	<label><span>Margin displayed in equivalent unit of measure:</span> </label>
	<input value="1"  class="cb_default" type="checkbox" name="Margin_Display_EQ" <cfif appSettings.getMarginDisplayEQ()>checked</cfif>>
	<label><input value="2" type="radio" name="Margin_Display_default" <cfif appSettings.getMarginDisplaydefault() EQ 2>checked</cfif>>(Default)</label>
	<span id="error_Margin_Display_default_3"></span>
</div>

<div class="setting">
	<div class="secondary">
		<label><input type="radio" value="1" name="approvalLayeredCosts" <cfif appSettings.getapprovalLayeredCosts() EQ 1>checked</CFIF>>Single cost for products</label><br>
		<label><input type="radio" value="2" name="approvalLayeredCosts" <cfif appSettings.getapprovalLayeredCosts() EQ 2>checked</cfif>>Multiple costs for products</label><br>
		<label><input type="radio" value="3" name="approvalLayeredCosts" <cfif appSettings.getapprovalLayeredCosts() EQ 3>checked</cfif>>Customer based costs for products</label>
	</div>
</div>

<div class="setting">
	<label><span>Use Sales Org and DC in base sales calculation:</span> <input value="1" type="checkbox" name="Use_DC_SO_Base_sales" <cfif appSettings.getUseDCSOBasesales()>checked</cfif>></label>
</div>

<div class="setting">
	<label><span>Sequential - Net Sales & then Operating Margin<!--- <br>(Template default): ---></span> <input value="1" type="checkbox" name="Sequential_Net_Sales_Operating_Margin" <cfif appSettings.getSequentialNetSalesOperatingMargin()>checked</cfif>></label><br>(Template default)
</div>

<div class="setting">
	<label><span>Use Cost Multiplier:</span> <input value="1" type="checkbox" name="use_cost_multiplier" <cfif appSettings.getusecostmultiplier()>checked</cfif>></label>
</div>

<div class="setting">
	<label><span>Approval - Disposable Goods is On:</span> <input type="radio" value="6" name="ApprovalLayeredOn" <cfif appSettings.getApprovalDisposableOn() IS 1>checked<cfset approval_layered_selected = 1 /></CFIF> onclick="RemoveLumpSumApprovalByComponent()"></label>
</div>

<div class="setting">
	<label>
		<span>Contribution Margin Calculation <img src="/images/help_small.gif"
												<!--- The "Title" is supposed to be on one line. Do not change it. --->
												Title="This feature only works when the client sends us multiple cost variables.  Contribution Margin = Oper Inc - FX_Man_Cost."></span> 
		<input type="checkbox" value="1" name="Contribution_Margin_Calculation" <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>checked</cfif>>
	</label>
</div>

<div class="setting" style="margin-bottom:20px;">
	<label><span>Approval - None:</span> <input type="radio" value="0" name="ApprovalLayeredOn" <cfif approval_layered_selected IS 0>checked</CFIF> onclick="RemoveLumpSumApprovalByComponent()"></label>
</div>

<h3>TPA Settings:</h3>
<div class="setting">
	<label><span>Include Operator Programs in distributor <!--- program's TPA ---> <img src="/images/help_small.gif"
			<!--- The "Title" is supposed to be on one line. Do not change it. --->
			Title="Operator programs will be included in a distributor program's TPA.   Operator billbacks and Distributor Invoices are collected in the following way:  go back 90 days from today, then go back another 90 days to get billbacks and invoices from that time period.  To determine which operator programs to include in the operator TPA, it is solely based on billbacks collect in the 90 day timeframe mentioned above.  It does not use the status settings of PreActive, Active and Expiring.  Nor does it use the Based on Program Dates setting either."
			/></span> 
		<input value="1" type="checkbox" name="OperatorTPAInDistributorPrograms" id="OperatorTPAInDistributorPrograms" <cfif appSettings.getOperatorTPAInDistributorPrograms() EQ 1>checked</cfif>>
	</label><br>program's TPA
</div>

<div style="margin:15px 0 30px 0;">
	<a href="##" onclick="validateAndSubmit(document.#formName#);">#application.util.string.linkFormat("save")#</a>
</div>
</cfoutput>
<script>
	$("select[name=margin_display_style]").change(function(){
		/* hide/show cost sequencing elements based on custom_t selection */
		if ($(this).val().toLowerCase() == "custom_t")
			$("#costs").show();
		else 
			$("#costs").hide();
	});
</script>