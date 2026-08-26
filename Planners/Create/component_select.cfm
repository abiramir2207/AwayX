<!---------------------------------------------------------------------------------------------------------------------
Template:	/Planners/Create/component_select.cfm
Date:  		06/14/2016
Author:		Tim Ford
Purpose:  	Component select popup called from Single Page Planner Program Create
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="url.templateId" 					default="" />
<cfparam name="url.discountType" 				default="" />
<cfparam name="form.discountType" 				default="#url.discountType#" />
<cfparam name="form.compNameId" 				default="" />
<cfparam name="form.rate" 						default="" />
<cfparam name="form.uom" 						default="" />
<cfparam name="url.Component_Paid_To"			default="" />
<cfparam name="form.Component_Paid_To"			default="#url.Component_Paid_To#" />
<cfparam name="url.PaymentCycle" 				default="" />
<cfparam name="form.PaymentCycle" 				default="#url.PaymentCycle#" />
<cfparam name="form.Fixed_Component_Paid_To" 	default="" />
<cfparam name="url.lump_sum_apply_to" 			default=" " />
<cfparam name="form.lump_sum_apply_to" 			default="#url.lump_sum_apply_to#" />
<cfparam name="url.compList" 					default="" />
<cfparam name="form.compList" 					default="#url.compList#" />
<cfparam name="form.save" 						default="0" />
<cfparam name="url.ClaimMechanics" 				default="0" />
<cfparam name="url.EligibleRecordCount"			default="3" />
<cfparam name="url.Generic_type"				default="" />
<cfparam name="url.Is_A_Revision"				default="0" />
<cfparam name="url.ModifyDeletedPrograms"		default="0" />
<cfparam name="url.Business_Segment_ID"			default="0" />
<cfparam name="variables.formName"				default="dataForm" />
<cfparam name="url.Claim_Mechanics"				default="0" />
<cfparam name="form.Claim_Mechanics"			default="#url.Claim_Mechanics#" />
<cfparam name="url.GL_Account_ID"				default="0" />
<cfparam name="form.GL_Account_ID"				default="#url.GL_Account_ID#" />
<cfparam name="url.Vendor_Master_ID"			default="0" />
<cfparam name="form.Vendor_Master_ID"			default="#url.Vendor_Master_ID#" />
<cfparam name="url.Vendor_Selection"			default="0" />
<cfparam name="form.Vendor_Selection"			default="#url.Vendor_Selection#" />
<cfparam name="url.Payee_Selection"				default="0" />
<cfparam name="form.Payee_Selection"			default="#url.Payee_Selection#" />
<cfparam name="url.VendorSelection"				default="#form.Vendor_Selection#" />
<cfparam name="form.Vendor_ID"					default="0" />
<cfparam name="form.VendorSelection"			default="0" />

<cfset PLANNER = "planner">

<cfparam name="url.Program_Upload"				default="0" />
<cfparam name="url.caller"				        default="">
<cfparam name="url.editComp"					default="0" />
<cfparam name="form.editComp"					default="#url.editComp#" />
<cfparam name="url.compId" 						default="" />
<cfparam name="form.compId" 					default="#url.compId#" />
<cfparam name="url.programId" 					default="0" />
<cfparam name="form.volume_percentage"			default="0" />
<cfparam name="URL.prodExists"					default = "0" />
<cfparam name="form.prodExists" 				default="#URL.prodExists#" />

<cfoutput>

<cfscript>
	qLabels                  = createObject("component", "components.settings.Labels.Labels").init();
	qGetPlannerRebateLabels  = qLabels.GetPlannerLabels('Rebate');
	plannerRebateLabel       = qGetPlannerRebateLabels.Planner_Labels_Singular;
	plannerRebateLabelPlural = qGetPlannerRebateLabels.Planner_Labels_Plural;
	oPlannerProgram          = CreateObject("component", "mvc.Models.Planner.PlannerProgramManager");
	oTemplateManager         = CreateObject("component", "components.programs.template.TemplateManager").init();
	url.caller               = lCase( url.caller );
	comp                     = 'Component';

	if ( url.caller contains PLANNER ) {
		comp = Application.PlannerCompLabel;
	}
</cfscript>


<cfif form.save eq 1>

	<cfif form.discountType eq 1 and form.editComp eq 0>
		<cfset form.Component_Paid_To = form.Fixed_Component_Paid_To />
	</cfif>

	<cfif form.Vendor_Selection eq "true">
		<cfset form.Vendor_Selection = 1 />
	<cfelse>
		<cfset form.Vendor_Selection = form.VendorSelection />
	</cfif>

	<cfif form.Vendor_Master_ID eq "">
		<cfset form.Vendor_Master_ID = "0" />
	</cfif>

	<cfif form.Payee_Selection eq "">
		<cfset form.Payee_Selection = "0" />
	</cfif>

	<script>

		if(window.opener.document.MyForm != null){

			var oForm = window.opener.document.MyForm;
			var oFixed = oForm.strFixedData;
			var oRebate = oForm.strRebateData;
            var oLumpSum = oForm.strLumpSumData;
            var elements = [
                                 '#form.compNameId#'             // 01
                                ,'#form.rate#'                  // 02
                                ,'#form.uom#'                   // 03
                                ,'#form.Component_Paid_To#'     // 04
                                ,'#form.PaymentCycle#'          // 05
                                ,'#form.lump_sum_apply_to#'     // 06
                                ,'#form.Claim_Mechanics#'       // 07
                                ,'#form.GL_Account_ID#'         // 08
                                ,'#form.Vendor_Master_ID#'      // 09
                                ,'#form.Vendor_Selection#'      // 10
                                ,'#form.Payee_Selection#'       // 11
                                ,'#form.volume_percentage#'     // 12
                            ];
            // var strVal = "#form.compNameId#_#form.rate#_#form.uom#_#form.Component_Paid_To#_#form.PaymentCycle#_#form.lump_sum_apply_to#_#form.Claim_Mechanics#_#form.GL_Account_ID#_#form.Vendor_Master_ID#_#form.Vendor_Selection#_#form.Payee_Selection#_#form.volume_percentage#";
            var strVal = elements.join("_");

			if ('#form.discountType#' == 1){
				var tmp = oFixed.value;
				oFixed.value = strVal;
			}
			else if ('#form.discountType#' == 2){
				var tmp = oRebate.value;
				oRebate.value = strVal;
			}
			else if ('#form.discountType#' == 3){
				var tmp = oLumpSum.value;
				oLumpSum.value = strVal;

			}

			<cfif form.editComp eq 1>
				oForm.bFromCompPopUpEdit.value = 1;
			</cfif>

			window.opener.show_loader();
			oForm.bFromCompPopUp.value = 1;
			oForm.bSave.value = 1;
			oForm.submit();
			window.close();
		}
	</script>

</cfif>
</cfoutput>

<cfset discountTypeDisplay = "">
<cfset url.ClaimMechanics  = form.Claim_Mechanics>

<!--- Set discount type label --->
<cfswitch expression="#form.discountType#">
	<cfcase value="1">
		<cfset variables.formName = "FixedComponents">
		<cfset discountTypeDisplay = application.fixedpricelabel>
	</cfcase>

	<cfcase value="2">
		<cfset discountTypeDisplay = plannerRebateLabel>
	</cfcase>

	<cfcase value="3">
		<cfset variables.formName = "NewLumpSum">
		<cfif url.caller contains PLANNER>
			<cfset discountTypeDisplay = application.PlannerLSLabel>
		<cfelse>
			<cfset discountTypeDisplay = application.lumpsumlabel>
		</cfif>
	</cfcase>
</cfswitch>

<cfquery name="qGetComponentData" datasource="#application.datasource#">
    /*** \Planners\Create\component_select.cfm - around line 156 ***/
	DECLARE @Tmp_All_Discount_Components table
	(
		Component_ID Int,
		Component_Name NVARCHAR(100),
		External_ID NVARCHAR(100),
		Discount_Type_ID Int,
		fixedType Int,
		Allowance_Code_ID Int,
		Active Bit,
		Greatest_Program_Value Bit,
        Rebate_Type Int
	)

	<cfif form.discountType eq 1>
		<cfset lRestrictList = CreateObject("component","components.programs.Fixed.FixedComponentProfile").compIdsToFilter(request.AccessStructure.Profiles_ID) />

		INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active, Greatest_Program_Value)
		SELECT	Program_Fixed_Component_Name_ID Component_ID, Program_Fixed_Component_Name Component_Name, External_ID, 1 Discount_Type_ID, Fixed_Component_Type, Allowance_Code_ID, Active, Greatest_Program_Value
		FROM	Program_Fixed_Component_Name
		WHERE	Program_Fixed_Component_Name.Deleted = 0
		<cfif trim(lRestrictList) neq "">
			AND		Program_Fixed_Component_Name_ID NOT IN (#lRestrictList#)
		</cfif>
		AND Active = 1
	</cfif>

	<cfif form.discountType eq 2>
	<cfset lRestrictList = CreateObject("component","components.programs.rebates.RebateComponentProfile").compIdsToFilter(request.AccessStructure.Profiles_ID) />

		INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active, Rebate_Type)
		SELECT	Program_Rebates_Component_Name_ID Component_ID, Program_Rebates_Component_Name Component_Name, External_ID, 2 Discount_Type_ID, 0, Allowance_Code_ID, Active, Rebate_Type
		FROM	Program_Rebates_Component_Name
		WHERE	Program_Rebates_Component_Name.Deleted = 0
		<cfif trim(lRestrictList) neq "">
			AND		Program_Rebates_Component_Name_ID NOT IN (#lRestrictList#)
		</cfif>
		AND Active = 1
	</cfif>

	<cfif form.discountType eq 3>
	<cfset lRestrictList = CreateObject("component","components.programs.Lump_Sum_Names.LumpSumComponentProfile").compIdsToFilter(request.AccessStructure.Profiles_ID) />

		INSERT INTO @Tmp_All_Discount_Components(Component_ID, Component_Name, External_ID, Discount_Type_ID, fixedType, Allowance_Code_ID, Active)
		SELECT	Program_Lump_Sum_Name_ID Component_ID, Program_Lump_Sum_Name Component_Name, External_ID, 3 Discount_Type_ID, 0, Allowance_Code_ID, Active
		FROM	Program_Lump_Sum_Name
		WHERE	Program_Lump_Sum_Name.Deleted = 0
		<cfif trim(lRestrictList) neq "">
			AND		Program_LumpSum_Component_Name_ID NOT IN (#lRestrictList#)
		</cfif>
		AND Active = 1
	</cfif>

	SELECT 	DISTINCT Program_Control_Panel_Options.Generic_Type,
			Program_Control_Panel_Options.ProgramControl_Panel_Options_ID Template_ID,
			Program_Control_Panel_Options.Created_Type,
			Program_Control_Panel_Options.First_Parent_ID,
			Program_Control_Panel_Options.Default_Rebate_Component_Name_Id,
			Program_Control_Panel_Options.Default_Fixed_Component_Name_Id,
			Tmp.*
	FROM	Program_Control_Panel_Options
			LEFT JOIN @Tmp_All_Discount_Components Tmp ON 1=1
			INNER JOIN Program_Template_Component ON Program_Template_Component.Deleted = 0
			AND Program_Template_Component.Discount_Type_ID = Tmp.Discount_Type_ID
			AND	Program_Template_Component.Component_ID = Tmp.Component_ID
			AND	Program_Template_Component.Template_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
	WHERE	(ISNULL(Tmp.Active, 1) = 1 OR Program_Template_Component.Program_Template_Component_ID IS NOT NULL)
	AND		Program_Control_Panel_Options.Deleted = 0
	AND		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = '#url.templateId#'
	AND		Tmp.Discount_Type_ID = '#form.discountType#'
	<cfif trim(url.compList) neq "">
	AND		Tmp.Component_ID NOT IN (#ListQualify(url.compList, "'")#)
	</cfif>
	<cfif trim(url.compId) neq "">
	AND		Tmp.Component_ID = '#url.compId#'
	</cfif>
	ORDER BY Tmp.Discount_Type_ID, Tmp.Component_Name, Program_Control_Panel_Options.Generic_Type, Program_Control_Panel_Options.Created_Type, Program_Control_Panel_Options.ProgramControl_Panel_Options_ID

</cfquery>

<cfset oPaymentCycle = CreateObject("component", "components.programs.PaymentCycleManager") />
<cfset qGetPaymentCycle = oPaymentCycle.getPaymentCycles(url.templateId) />
<!DOCTYPE HTML>
<HTML>
<HEAD>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<TITLE>Select Component</TITLE>
</HEAD>

<body>
<cfset jQueryUI.version = '1.11.4'/>
<cfinclude template="/Common_Files/jQuery.cfm">

<cf_include files="#arrayToList( [
                                     "/common_files/datatable.css"
                                    ,"/common_files/viewmodes.css"
                                    ,"/Script/javascript/string_functions.js"
                                    ,"/Script/javascript/format_functions.js"
                                    ,"/styles/css-loader.css"
                                    ])#">
<style>
    body { overflow: hidden; }
    .rebate_type_10 { display: none }
</style>

<cfif qGetComponentData.RecordCount>
<form method="post" name="<cfoutput>#variables.formName#</cfoutput>" id="<cfoutput>#variables.formName#</cfoutput>">
<cfoutput query="qGetComponentData" group="Discount_Type_ID">
	<cfquery name="qGetCompDetail" dbtype="query">
		SELECT * FROM qGetComponentData WHERE Discount_Type_ID = #Discount_Type_ID#
	</cfquery>
<div>
<table class="datagrid" id="datagrid" width="100%">
	<thead>
		<tr>
			<th> #comp# Name</th>
			<cfif form.editComp eq 0>
				<th>Default Rate</th>
			</cfif>
			<cfif form.discountType neq 3 and form.editComp eq 0>
			    <th>UOM</th>
			</cfif>
			<th>Paid To</th>
			<th colspan="2">Select Payment Cycle</th>
		</tr>
	</thead>
	<tbody>
		<tr valign="top">
			<td>
				<cfif form.editComp eq 1>
					#qGetCompDetail.Component_Name#
					<input name="compNameId" type="hidden" value="#form.compId#" />
				<cfelse>
					<select name="compNameId">
						<option value="-1" selected>Select #discountTypeDisplay# #comp#...</option>
						<cfloop query="qGetCompDetail">
							<option value="#Component_ID#" rebate_type="#qGetCompDetail.rebate_type#" <cfif qGetCompDetail.recordCount eq 1> selected</cfif>>#Component_Name#</option>
						</cfloop>
					</select>
				</cfif>
			</td>

			<cfif form.editComp eq 1>
				<input name="rate" type="hidden" value="0" />
			<cfelse>
				<td>
                    <input name="rate" type="text" size="5" ONKEYUP="clenseText(this,'0123456789.-')" onChange="this.value = formatToDecimalPlaces(this.value,4)"
						style="font-size:10" class="autoselect"
						<cfif url.Program_Upload or url.caller contains PLANNER> value="0.0000" </cfif> />
                    <div style="width:100%;text-align:left;margin-top:15px" class="rebate_type_10">
                        <b>Volume</b><br>
                        <input
                            name="volume_percentage"
                            type="text"
                            value=""
                            size="5"
                            class="positive-integer"
                            style="width:40px;"
                        >%
                    </div>
                </td>
			</cfif>

			<cfif form.editComp eq 1>

				<cfif form.discountType eq 3>
					<input name="lump_sum_apply_to" type="hidden" value="#form.lump_sum_apply_to#" />
					<input name="uom" type="hidden" value="0" />
				<cfelse>
					<input name="uom" type="hidden" value="0" />
				</cfif>

			<cfelse>

				<cfif form.discountType eq 3>
					<input name="uom" type="hidden" value="1" />
         	<input name="lump_sum_apply_to" type="hidden" value="1">
				<cfelse>
					<td>
						<cf_uom_dropdown
							program_id				=	""
							company_main_id			=	""
							default_option_on		=	"0"
							default_option_text		=	""
							default_option_value	=	""
							dropdown_name			=	"uom"
							option_text_abbreviated	=	"1"
							plural_uom_display		=	""
							product_type_id			=	"#form.discountType#"
							program_template_id		=	"#url.templateId#"
							selected_uom_id			=	""
							text_before_tag_close	=	""
							uom_id_exclusion_list	=	""
							uom_id_inclusion_list	=	""
							setDefaultSelected		= 	1
						>
					</td>
				</cfif>

			</cfif>

			<td>
				<cfif form.editComp eq 1>
					<cfset qLabels                = createObject("component", "components.settings.Labels.Labels").init() />
					<cfset qGetPaymentPaidToTypes = oTemplateManager.GetPaymentPaidToTypes(url.templateId,form.discountType,form.compId) />

					<cfloop query="qGetPaymentPaidToTypes">
						<input name="Component_Paid_To" type="Radio" value="<cfoutput>#Payment_Paid_To_ID#</cfoutput>" <cfif form.Component_Paid_To eq Payment_Paid_To_ID>checked</cfif>>
							<cfoutput>
								<cfif qGetPaymentPaidToTypes.Payment_Paid_To_ID eq "1">
									<cfset qGetPlannerDistributorLabels = qLabels.GetPlannerLabels('Distributor') />
									#qGetPlannerDistributorLabels.Planner_Labels_Singular#
								<cfelse>
									<cfset qGetPlannerOperatorLabels = qLabels.GetPlannerLabels('Operator') />
									#qGetPlannerOperatorLabels.Planner_Labels_Singular#
								</cfif>
							</cfoutput>
							<br>
					</cfloop>
				<cfelse>
					<cfdiv bind="url:/Common_Files/contracts/component_paid_to.cfm?Component_Name_ID={compNameId}&Discount_Type_ID=#EncodeForURL(form.discountType)#&ContractMainID=#EncodeForURL(url.programId)#&ProgramType_ID=#EncodeForURL(url.templateId)#&bFromPlanner=1" ID="paidToInfo" />
				</cfif>
			</td>
			<td>

				<select name="PaymentCycle" id="PaymentCycle">
					<option value="-1">Choose One</option>
					<cfloop query="qGetPaymentCycle">
						 <option value="#qGetPaymentCycle.Payment_Cycle_ID#"
                            <cfif form.PaymentCycle eq qGetPaymentCycle.Payment_Cycle_ID     <!--- previously selected payment cyle --->
                                or qGetPaymentCycle.RecordCount eq 1                         <!--- preselect the only payment cycle --->
                                or ( val(form.PaymentCycle) eq 0                             <!--- payment cyle not yet selected & this payment was assigned as default --->
                                        and qGetPaymentCycle.Payment_Cycle_ID EQ qGetPaymentCycle.PayCycleDefaultOption )>
                                selected
                            </cfif>>#qGetPaymentCycle.Payment_Cycle#</option>
					</cfloop>
				</select>
			</td>
			<td>
				<cfdiv bind="url:/Common_Files/contracts/component_information.cfm?Component_Name_ID={compNameId}&ModifyDeletedPrograms=#EncodeForURL(url.ModifyDeletedPrograms)#&Discount_Type_ID=#EncodeForURL(form.discountType)#&ClaimMechanics=#EncodeForURL(url.ClaimMechanics)#&ProgramType_ID=#EncodeForURL(url.templateId)#&Is_A_Revision=#EncodeForURL(url.Is_A_Revision)#&EligibleRecordCount=#EncodeForURL(url.EligibleRecordCount)#&programId=#EncodeForURL(url.programId)#&VendorSelection=#EncodeForURL(url.VendorSelection)#&Payee_Selection=#EncodeForURL(form.Payee_Selection)#&Vendor_Master_ID=#EncodeForURL(form.Vendor_Master_ID)#&Program_Upload=#EncodeForURL(url.Program_Upload)#" ID="compInfo" />
			</td>
		</tr>
	</tbody>
</table>
<br>
<a onClick="javascript: validate_form();" style="cursor:pointer;">#application.util.string.actionLinkFormat("save")#</a>
<cfif url.Program_Upload or ( url.caller contains PLANNER and url.discountType lte 2 )>
	<table width="450" border=0 cellspacing=0 cellpadding=0 align="center">
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td>Product Number<span style="color:red;font-weight:bold"><br>(AlphaNumeric only)</span></td>
		<td>Product Rate<span style="color:red;font-weight:bold"><br>(Numeric only)</span></td>
		<td>
			UOM
			<img border="0" src="/Images/i.gif" width="12" height="11"
				title="To delete a Previously uploaded product from program, user should type DEL into UOM column. Once records are submitted products with UOM = DEL will be deleted">
			<span style="color:red;font-weight:bold"> <br>
				(CS / LB / % / CWT / DEL)
			</span>
		</td>
	</tr>
	<tr>
		<td colspan="3">
			<textarea ID="itemList" CLASS="itemList" NAME="itemList"  ROWS="20" COLS="30" STYLE="width:430px"></textarea>
		</td>
	</tr>
	</table>
		<input type="hidden" name="programId" value="#url.programId#">
		<input type="hidden" name="thisObject" id="thisObject" value="product">
		<input type="hidden" name="match_type" id="match_type" value="exact">
		<input type="hidden" name="passedItemList" id="passedItemList" value="" >
		<input type="hidden" name="passedPrgList" id="passedPrgList" value="" >
		<input type="hidden" name="discountype" id="discountype" value="#url.discountType#">
		<input type="hidden" name="action" value="1">
</cfif>
<input name="discountType" type="hidden" value="#Discount_Type_ID#" />
<input type="hidden" name="Auto_Pay_Status" value="">
<input type="hidden" name="AllowSave" value="">
<input type="hidden" name="Vendor_Selection" value="#form.Vendor_Selection#">
<input name="save" type="hidden" value="1" />
<input type="hidden" name="editComp" value="#form.editComp#">
<input type="hidden" name="compId" value="#form.compId#">



</cfoutput>
</form>

<cfoutput>
</div>  <!--- div style="width:760px;" --->

<cf_include files="/script/javascript/numeric/jquery.numeric.min.js">

<script>
	function validate_form() {
		var errors = []
			,cnt = 0
		    ,required = [ "compNameId", "PaymentCycle" ]
		    ,messages = [ "Please select a <cfoutput>#comp#</cfoutput>.", "Please select a payment cycle." ]
			,valToCheck = ""
			,PayeeOption = 0;

		<!--- determine if product number/rate/uom textarea is empty --->
		let is_product_box_empty = true;
		if ( $.trim( $( ".itemList" ).val() ) )
		    is_product_box_empty = false;

		<cfif editComp eq 1>
			<!--- editing component, rate is not required --->
		<cfelseif ( url.Program_Upload )>
			<!--- product textarea input is required here --->
			if ( is_product_box_empty ) {
				errors.push( 'Please paste product & rate info.' );
			}
		<!--- When Planner program does not already have products, do not allow the user to add 
				component without pasting the products --->
		<cfelseif ((form.prodExists EQ "" OR form.prodExists EQ 0) AND url.caller contains PLANNER)>
			/* Display message only if the product box is empty */
			if (is_product_box_empty )
			{
				errors.push( 'Please paste product & rate info. first.' );
			}
		<cfelseif url.caller contains PLANNER>
			<!--- need to validate rate because product textarea is empty --->
			if ( is_product_box_empty ) {
				required.push( "rate" );
				messages.push( "Please enter a rate." );
			}
		<cfelse>
			required.push( "rate" );
			messages.push( "Please enter a rate." );
		</cfif>

			/* Discount types other than "fixed price" */
			if (document.all.Component_Paid_To){
				/* Determine who the payee is */
				for (i=0; i<=document.all.Component_Paid_To.length-1; i++){
					if (document.all.Component_Paid_To[i].checked == true){
						PayeeOption = i;
					}
				}
			}
			else
			{
				/* Fixed Price */
				if (document.all.Fixed_Component_Paid_To){
					/* Determine who the payee is */
					for (i=0; i<=document.all.Fixed_Component_Paid_To.length-1; i++){
						if (document.all.Fixed_Component_Paid_To[i].checked == true){
							PayeeOption = i;
						}
					}
				}
			}

			/* If Vendor selection radio boxes exist */
			if(document.all.VendorSelection)
			{
				if(document.all.Vendor_Master_ID)
				{
					if(document.all.Vendor_Master_ID.value == 0)
					{
						if(document.all.VendorSelection.type != "hidden")
						{
							/* if none of the payee radio button options are selected */
							if($("input:radio[name='VendorSelection']").is(":checked") == false){
									alert("You must select a payee.")
									return false;
							}
						}
						/* In this case, there are no "radio button" options  to select a payee type ("Select a single payee", "Pay each entity individually") etc.,
						but the "select a payee" link does exist as "VendorSelection" is true (From claim_mech_info.cfm), when "Auto Pay Disable Pay Each" appp setting
						is ON.
						*/
						else{
							alert("You must select a payee.");
							return false;
						}
						/* Pay to a single Payee */
						if(document.all.VendorSelection.type != "hidden" && document.all.VendorSelection[0].checked)
						{
							if(PayeeOption == 0)
							{
								alert("You must select a vendor for the auto payments.")
								return false;
							}
							else
							{
								alert("You must select a vendor for auto pay components not payable to distributor")
								return false;
							}
						}
						 /* Pay Individually */
						else
						{
							if(PayeeOption == 1 || PayeeOption == 3)
							{
								alert("You must select a vendor for auto pay components not payable to distributor")
								return false;
							}
						}
					}
				}
			}

		for (cnt = 0; cnt <= required.length; cnt++) {
			var $obj = $("input[name=" + required[cnt] + "]");

			if($obj.val() == undefined){
				valToCheck = $("select[name=" + required[cnt] + "]").val();
			}
			else{
				valToCheck = $obj.val();
			}

			if (valToCheck  == "" ||  valToCheck == 0 ||  valToCheck == -1) {
				errors.push( messages[cnt] );
				$obj.addClass( "attention" );
			}
			else {
				$obj.removeClass( "attention" );
			}
		};

        let rebate_type = $("select[name=compNameId]").find("option:selected").attr("rebate_type");
        if (rebate_type == 10) {
            if ($("input[name=volume_percentage]").val() == '') {
                errors.push("Please enter a volume percentage.");
            }
        }

		let copy_paste_action = '/common_files/contracts/Create_Product_Rate_List.cfm?discountype=#url.discountType#'

		// caller is retail planner program
		<cfif url.caller contains PLANNER>
			// change action URL when no error is found
			if ( errors.length == 0 && is_product_box_empty === false ) {
				#variables.formName#.action = copy_paste_action;
			}
		<cfelseif url.Program_Upload>
			// change action URL when no error is found
			if ( errors.length == 0 ) {
				#variables.formName#.action = copy_paste_action;
			}
		</cfif>


		if (errors.length) {
			alert( errors.join("\n") );
			return false;
		}
		    show_loader("PLEASE WAIT...");
	        #variables.formName#.submit();
	    };

        $("select[name=compNameId]").change(function(){
            let rebate_type = $(this).find("option:selected").attr("rebate_type");
            // display volume % input for scan redemption rebate type
            if (rebate_type == 10) {
                $(".rebate_type_10").show();
            }
            else {
                $(".rebate_type_10").hide();
            }
        });

        $('input.positive-integer').numeric({ negative: false, decimal: false });
</script>
</cfoutput>
<cfelse>
	<cfif form.discountType eq 1>
		<cfset type = 'fixed'>
	<cfelseif form.discountType eq 2>
		<cfset type = 'rebate'>
	<cfelseif form.discountType eq 3>
		<cfset type = 'lump sum'>
	<cfelse>
		<cfset type = ''>
	</cfif>
	<div align="center" style="font-weight: bold;color:red; font-size: 14px;">
		No eligible <cfoutput>#type#</cfoutput> components found.
	</div>
</cfif>
<!--- injects style for focused element here instead of using Application.cfc which places the same code oustide of </html> tag --->
<cfinclude template="/common_files/focus.cfm">
</body>
</HTML>
