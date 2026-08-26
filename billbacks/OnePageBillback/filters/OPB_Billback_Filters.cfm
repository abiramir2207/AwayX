<cfscript>
	param name="form.payable_search"				default="";
	param name="form.billback_search"	default="";
	param name="form.bb_program_search"				default="";
	param name="form.bb_customer_search"				default="";
	param name="form.bb_operator_search"				default="";
	param name="form.bb_item_search"						default="";
	param name="form.bb_item_group_search"			default="";

	param name="form.bb_status_list"			default="";
	param name="form.bb_closing_method"			default="";
	param name="form.billback_analyst"			default="";
	param name="form.bb_template_list"			default="";
	param name="form.bb_component_list"			default="";
	param name="form.bb_paid_to"			default="";

	qGetAllStatus = CreateObject("component", "components.reports.claimReportManager").getClaimReportProgramStatus();
	qGetAllAnalysts = CreateObject("component", "components.billback.BillbackAssignmentManager").getAnalysts();
</cfscript>

<cfoutput>
<cfif application.appSettingsGet.getDeduction_Module()>
	<div class="filter" title="" id="matchDeduction" style="padding-bottom: 10px;">
		<i class="label"><B>Match Deductions</B></i>
		<input type="radio" name="match_deduction" value="1" style="width:25px" id="matchDDYes"><B>Yes</B>
		<input type="radio" name="match_deduction" value="0" style="width:25px" id="matchDDNo" checked><B>No</B>
	</div>
<cfelse>
	<input type="radio" name="match_deduction" value="0" style="width:25px" id="matchDDNo" checked>
</cfif>

<div class="filter" title="" id="payableSearch">
	<i class="label">#stBBLabels.Payable#</i>
	<input type="text" name="payable_search" id="payable_search" size="30" value="#form.payable_search#">
</div>

<div class="filter" title="" id="bbSearch">
	<i class="label">#stBBLabels.Billback#</i>
	<input type="text" name="billback_search" id="billback_search" size="30" value="#form.billback_search#">
</div>

<div class="filter" title="" id="program">
	<i class="label">Program</i>
	<input type="text" name="bb_program_search" id="bb_program_search" size="30" value="#form.bb_program_search#">
</div>

<div class="filter" title="" id="customer">
	<i class="label">Customer</i>
	<input type="text" name="bb_customer_search" id="bb_customer_search" size="30" value="#form.bb_customer_search#">
</div>

<div class="filter" title="" id="operator">
	<i class="label"><CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT></i>
	<input type="text" name="bb_operator_search" id="bb_operator_search" size="30" value="#form.bb_operator_search#">
</div>

<div class="filter" title="" id="item">
	<i class="label"><CFOUTPUT>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</CFOUTPUT></i>
	<input type="text" name="bb_item_search" id="bb_item_search" size="30" value="#form.bb_item_search#">
</div>

<div class="filter" title="" id="iGroup">
	<i class="label"><CFOUTPUT>#REReplace(application.returned_customer_setting.item_label, "\b(\S)(\S*)\b", "\u\1\L\2", "all")#</CFOUTPUT> Group</i>
	<input type="text" name="bb_item_group_search" id="bb_item_group_search" size="30" value="#form.bb_item_group_search#">
</div>

<!---  SELECT BOXES --->

<!--- Status Drop Down --->
<div class="filter mt-1" title="filter: #stBBLabels.Billback# Status" id="bbStatus">
	<select name="bb_status_list" id="bb_status_list" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllStatus">
			<option value="#Billback_Status_ID#" <cfif form.bb_status_list EQ Billback_Status_ID>SELECTED</cfif>>#BB_Status_Description#</option>
		</cfloop>
	</select>
</div>
<!--- Closing Method Drop Down --->
<div class="filter mt-1" title="filter: #stBBLabels.Billback# #stBBLabels.Closing_Method#" id="closingMethod">
	<select name="bb_closing_method" id="bb_closing_method" multiple="multiple" style="width:99%;">
		<cfloop query="qGetClosingMethods">
			<option value="#iBillback_Closing_Method_ID#" <cfif form.bb_closing_method EQ iBillback_Closing_Method_ID>SELECTED</cfif>>#vchBillback_Closing_Method_DESC#</option>
		</cfloop>
	</select>
</div>
<!--- Analyst Drop Down --->
<div class="filter mt-1" title="filter: #stBBLabels.Billback# #stBBLabels.Analyst#" id="bbAnalyst">
	<select name="billback_analyst" id="billback_analyst" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllAnalysts">
			<option value="#Analyst_User_ID#" <cfif form.billback_analyst EQ Analyst_User_ID>SELECTED</cfif>>#Name_First# #Name_Last#</option>
		</cfloop>
	</select>
</div>
<!--- Template Drop Down --->
<div class="filter mt-1" title="filter: Program Template" id="template">
	<select name="bb_template_list" id="bb_template_list" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllTemplates">
			<option value="#First_Parent_ID#" <cfif form.bb_template_list EQ First_Parent_ID>SELECTED</cfif>>#Created_Type#</option>
		</cfloop>
	</select>
</div>
<!---Components Drop Down--->
<div class="filter mt-1" title="filter: Components" id="components">
	<select name="bb_component_list" id="bb_component_list" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllComponents">
			<option value="#Component_ID#" <cfif form.bb_component_list EQ Component_ID>SELECTED</cfif>>#Component_Name#</option>
		</cfloop>
	</select>
</div>
<!---Paid To Drop Down--->
<div class="filter mt-1" title="filter: Paid To" id="paidTo">
	<select name="bb_paid_to" id="bb_paid_to" multiple="multiple" style="width:99%;">
		<option value="1" <cfif form.bb_paid_to EQ 1>SELECTED</cfif>>#application.returned_customer_setting.distributor_label_plural# </option>
		<option value="2" <cfif form.bb_paid_to EQ 2>SELECTED</cfif>>#application.returned_customer_setting.operator_label_plural#/Indirect</option>
	</select>
</div>
<!---  BUTTONS --->
<div style="display: flex;flex-direction: row;flex-wrap: wrap;justify-content: center; margin-top:8px; margin-bottom:8px;">
	<button type="button" id="bbSearchButton" onClick="BBvalidate();" title="Search Programs using the selected filters" class="button recommended">Search #stBBLabels.Billback#</button>
	<button type="button" onClick="resetBBOptions();" title="Clear the filters" class="button alt">reset</button>
</div>
<input type="hidden" name="BBLoaded" id="BBLoaded" value="0">

</cfoutput>

<script type="text/javascript">
// Reset the filters (and the grid).  Used for reset button
function resetBBOptions() {
	/*
	$("select[name=bb_status_list]").multipleSelect('uncheckAll');
	$("select[name=bb_closing_method]").multipleSelect('uncheckAll');
	$("select[name=billback_analyst]").multipleSelect('uncheckAll');
	$("select[name=bb_template_list]").multipleSelect('uncheckAll');
	$("select[name=bb_component_list]").multipleSelect('uncheckAll');
	$("select[name=bb_paid_to]").multipleSelect('uncheckAll');

	$('#payable_search').val('');
	$('#billback_search').val('');
	$('#bb_program_search').val('');
	$('#bb_customer_search').val('');
	$('#bb_operator_search').val('');
	$('#bb_item_search').val('');
	$('#bb_item_group_search').val('');*/


	$('#FILTERreferencenumber').val('');
	$('#MC_Distributor_Family_ID').val('');
	$('#search').val('');
	document.getElementById('frmSettlements').reset();
	clearMatch();

	no_data_available(BillbackGridOptions, "hidden");   // suppress no data available message
	BillbackGridOptions.api.setRowData([]);

$("input[name='match_deduction']").each(function(){
      if($(this).val() == "1"){
      	$(this).removeAttr('checked');
      }else{
      	$(this).prop("checked", true)
      	hideDDSection( $(this).val() );
      }
    });
}

function BBvalidate(){
	/*FILTER CHECK*/
	var PSearch  = $("input[name=payable_search]").val();
	var BBSearch = $("input[name=billback_search]").val();
	var PGSearch  = $("input[name=bb_program_search]").val();
	var CSearch  = $("input[name=bb_customer_search]").val();
	var OSearch  = $("input[name=bb_operator_search]").val();
	var ISearch  = $("input[name=bb_item_search]").val();
	var IGSearch  = $("input[name=bb_item_group_search]").val();
	var DDselection = $("input[name='match_deduction']:checked").val();

	var errors = [];
	var lenRequirment = 0;

	if (PSearch === '' && BBSearch === '' && PGSearch === '' && CSearch === '' && OSearch === '' && ISearch === '' && IGSearch=== ''){
		errors.push("Please enter a value for a filter.");
	}

	if ( ! errors.length && (	(PSearch != '' && PSearch.length < 5)
																	|| (BBSearch != '' && BBSearch.length < 5)
																	|| (PGSearch != '' && PGSearch.length < 5)
																	|| (CSearch != '' && CSearch.length < 5)
																	|| (OSearch != '' && OSearch.length < 5)
																	|| (ISearch != '' && ISearch.length < 5)
																	|| (IGSearch != '' && IGSearch.length < 5))
	) {
		errors.push("Search string should be at least 5 characters.");
	}

	if (errors.length) {
		new Noty({ layout:"center", type:"error", text: noty_message(errors.join("<br>")) }).show();
		return;
	}else{
		$('#search').val('bb');
		bbLoad();
		if(CSearch.length >=5 && DDselection ==1){
			$("input[name=dd_customer_search]").val(CSearch);
			$('#search').val('ded');
			DDvalidate();
		}
	}
}
$("input[name='match_deduction']").change(function(){
	var CSearch  = $("input[name=bb_customer_search]").val();
	var DDselection = $("input[name='match_deduction']:checked").val();

	if( $('#BBLoaded').val() != 0){
		$('#search').val('bb');
		bbLoad();
		if(CSearch.length >=5 && DDselection ==1){
			$("input[name=dd_customer_search]").val(CSearch);
			$('#search').val('ded');
			DDvalidate();
		}
	}
});
</script>