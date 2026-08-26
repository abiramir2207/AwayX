<cfscript>
		param name="form.customer_search"				default="";
		param name="form.customer_group_search"	default="";
		param name="form.operator_search"				default="";
		param name="form.program_search"				default="";
		param name="form.item_search"						default="";
		param name="form.item_group_search"			default="";

		param name="form.template_list"			default="";
		param name="form.planner_list"			default="";
		param name="form.paid_to"			default="";
		param name="form.discount_type"			default="";
		param name="form.component_list"			default="";

		// Default dates should be for the past 6 months
		param name="form.startdate"							default="#dateformat(DateAdd('m',-6,now()),'m/d/yyyy')#";
		param name="form.endDate"							default="#dateformat(now(),'m/d/yyyy')#";
		param name="form.startDateCondition"			default=">=";
		param name="form.endDateCondition"			default="<=";
</cfscript>

<cfoutput>
<div class="filter" title="" id="customer">
	<i class="label">Customer</i>
	<input type="text" name="customer_search" id="customer_search" size="30" value="#form.customer_search#">
</div>

<div class="filter" title="" id="cGroup">
	<i class="label">Customer Group</i>
	<input type="text" name="customer_group_search" id="customer_group_search" size="30" value="#form.customer_group_search#">
</div>

<div class="filter" title="" id="operator">
	<i class="label"><CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT></i>
	<input type="text" name="operator_search" id="operator_search" size="30" value="#form.operator_search#">
</div>

<div class="filter" title="" id="program">
	<i class="label">Program</i>
	<input type="text" name="program_search" id="program_search" size="30" value="#form.program_search#">
</div>

<div class="filter" title="" id="item">
	<i class="label"><CFOUTPUT>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</CFOUTPUT></i>
	<input type="text" name="item_search" id="item_search" size="30" value="#form.item_search#">
</div>

<div class="filter" title="" id="iGroup">
	<i class="label"><CFOUTPUT>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</CFOUTPUT> Group</i>
	<input type="text" name="item_group_search" id="item_group_search" size="30" value="#form.item_group_search#">
</div>

<!---  SELECT BOXES --->
<div class="filter mt-1" title="filter: Program Template" id="template">
	<select name="template_list" id="template_list" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllTemplates">
			<option value="#First_Parent_ID#" <cfif form.template_list EQ First_Parent_ID>SELECTED</cfif>>#Created_Type#</option>
		</cfloop>
	</select>
</div>
<!--- Planner Drop Down --->
<cfoutput>
<div class="filter mt-1" title="filter: #Application.PlannerLabel# Template" id="#Application.PlannerLabel#">
</cfoutput>
	<select name="planner_list" id="planner_list" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllPlannersTemplates">
			<option value="#Planner_Template_ID#" <cfif form.planner_list EQ Planner_Template_ID>SELECTED</cfif>>#Planner_Type#</option>
		</cfloop>
	</select>
</div>
<!---Paid To Drop Down--->
<div class="filter mt-1" title="filter: Paid To" id="paidTo">
	<select name="paid_to" id="paid_to" multiple="multiple" style="width:99%;">
		<option value="1" <cfif form.paid_to EQ 1>SELECTED</cfif>>#application.returned_customer_setting.distributor_label_plural# </option>
		<option value="2" <cfif form.paid_to EQ 2>SELECTED</cfif>>#application.returned_customer_setting.operator_label_plural#/Indirect</option>
	</select>
</div>
<!---Discount Type Drop Down--->
<div class="filter mt-1" title="filter: Discount Type" id="discountType">
	<select name="discount_type" id="discount_type" multiple="multiple" style="width:99%;">
		<option value="F" <cfif form.discount_type EQ "F">SELECTED</cfif>>Fixed Price</option>
		<option value="R" <cfif form.discount_type EQ "R">SELECTED</cfif>>Rebate</option>
		<option value="L" <cfif form.discount_type EQ "L">SELECTED</cfif>>Lump Sum</option>
		<option value="G" <cfif form.discount_type EQ "G">SELECTED</cfif>>Growth</option>
	</select>
</div>
<!---Components Drop Down--->
<div class="filter mt-1" title="filter: Components" id="components">
	<select name="component_list" id="component_list" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllComponents">
			<option value="#Component_ID#" <cfif form.component_list EQ Component_ID>SELECTED</cfif>>#Component_Name#</option>
		</cfloop>
	</select>
</div>
<!---  DATE range --->
<div class="filter" style="margin-left: 4px; margin-top:5px;" id="dateRange">
	Date Range <br>
	<select name="startDateCondition" id="startDateCondition" style="width:35px;">
			<option value="=" <cfif form.startDateCondition EQ "=">SELECTED</cfif>>=</option>
			<option value=">=" <cfif form.startDateCondition EQ ">=">SELECTED</cfif>>>=</option>
			<option value="<=" <cfif form.startDateCondition EQ "<=">SELECTED</cfif>><=</option>
	</select>
	<input name="startDate" id="startDate" type="text" class="date" value="#form.startDate#"> to

	<select name="endDateCondition" id="endDateCondition" style="width:35px;">
			<option value="=" <cfif form.endDateCondition EQ "=">SELECTED</cfif>>=</option>
			<option value=">=" <cfif form.endDateCondition EQ ">=">SELECTED</cfif>>>=</option>
			<option value="<=" <cfif form.endDateCondition EQ "<=">SELECTED</cfif>><=</option>
	</select>
	<input name="endDate" id="endDate" type="text" class="date" value="#form.endDate#">
</div>
<!---  BUTTONS --->
<div style="display: flex;flex-direction: row;flex-wrap: wrap;justify-content: center; margin-top:8px; margin-bottom:8px;">
	<button type="button" id="programs-btn" onClick="validate('PRG');" title="Search Programs using the selected filters" class="button recommended" >Search Programs</button>
	<button type="button" onClick="resetPRGOptions();" title="Clear the filters" class="button alt">reset</button>
</div>
</cfoutput>

<script type="text/javascript">
// Reset the filters (and the grid).  Used for reset button
function resetPRGOptions() {
	$("select[name=template_list]").multipleSelect('uncheckAll');
	$("select[name=planner_list]").multipleSelect('uncheckAll');
	$("select[name=paid_to]").multipleSelect('uncheckAll');
	$("select[name=discount_type]").multipleSelect('uncheckAll');
	$("select[name=component_list]").multipleSelect('uncheckAll');

	$('#customer_search').val('');
	$('#customer_group_search').val('');
	$('#operator_search').val('');
	$('#program_search').val('');
	$('#item_search').val('');
	$('#item_group_search').val('');

	no_data_available(ProgramGridOptions, "hidden");   // suppress no data available message
	ProgramGridOptions.api.setRowData([]);
}

function validate(type){
	/*FILTER CHECK*/
	var CSearch  = $("input[name=customer_search]").val();
	var CGSearch = $("input[name=customer_group_search]").val();
	var OSearch  = $("input[name=operator_search]").val();
	var PSearch  = $("input[name=program_search]").val();
	var ISearch  = $("input[name=item_search]").val();
	var IGSearch  = $("input[name=item_group_search]").val();

	var errors = [];
	var lenRequirment = 0;

	if (CSearch === '' && CGSearch === '' && OSearch === '' && PSearch === '' && ISearch === '' && IGSearch=== ''){
		errors.push("Please enter a value for a filter.");
	}

	if ( ! errors.length && (	(CSearch != '' && CSearch.length < 5)
	|| (CGSearch != '' && CGSearch.length < 5)
	|| (OSearch != '' && OSearch.length < 5)
	|| (PSearch != '' && PSearch.length < 5)
	|| (ISearch != '' && ISearch.length < 5)
	|| (IGSearch != '' && IGSearch.length < 5))
	) {
		errors.push("Search string should be at least 5 characters.");
	}

	if (errors.length) {
		new Noty({ layout:"center", type:"error", text: noty_message(errors.join("<br>")) }).show();
		return;
	}else{
		$('#search').val('prg');
		jsonLoad();
	}
}

$(".date").datepicker({
dateFormat: "m/d/yy",
changeMonth: true,
changeYear: true,
onSelect: function( selected ) {
	// change date limit based on selected value
	if ( jQuery(this).attr("name") === "startDate" )
		jQuery("input[name=enddate]").datepicker("option", "minDate", selected);
	else
		jQuery("input[name=startDate]").datepicker("option", "maxDate", selected);
}
});
</script>