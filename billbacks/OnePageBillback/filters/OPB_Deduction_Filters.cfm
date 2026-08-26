<cfscript>
	param name="form.deduction_search"				default="";
	param name="form.reference_search"				default="";
	param name="form.check_search"				default="";
	param name="form.creference_search"				default="";
	param name="form.dd_customer_search"						default="";

	param name="form.dd_status_list"	default="";
	param name="form.dd_family"			default="";
	param name="form.dd_analyst"			default="";

	qGetAllDDStatus = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager_Filters").getDDStatus();
	qGetAllAnalysts = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager_Filters").getDDAnalysts();
	qGetAllFamilyNames = CreateObject("component", "Components.Billback.BillbackSettingsManager").GetFamilyNames();
</cfscript>

<cfoutput>

	<div class="filter" title="" id="deductionSearch">
		<i class="label">Deduction</i>
		<input type="text" name="deduction_search" id="deduction_search" size="30" value="#form.deduction_search#">
	</div>

	<div class="filter" title="" id="referenceSearch">
		<i class="label">Reference</i>
		<input type="text" name="reference_search" id="reference_search" size="30" value="#form.reference_search#">
	</div>

	<div class="filter" title="" id="checkSearch">
		<i class="label">Check</i>
		<input type="text" name="check_search" id="check_search" size="30" value="#form.check_search#">
	</div>

	<div class="filter" title="" id="creferenceSearch">
		<i class="label">#stDDLabels.Customer_Reference#</i>
		<input type="text" name="creference_search" id="creference_search" size="30" value="#form.creference_search#">
	</div>

	<div class="filter" title="" id="customerSearch">
		<i class="label">Customer</i>
		<input type="text" name="dd_customer_search" id="dd_customer_search" size="30" value="#form.dd_customer_search#">
	</div>

<!---  SELECT BOXES --->

<!--- Status Drop Down --->
<div class="filter mt-1" title="filter: Deduction Status" id="ddStatus">
	<select name="dd_status_list" id="dd_status_list" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllDDStatus">
			<option value="#DD_Status_ID#" <cfif form.dd_status_list EQ DD_Status_ID>SELECTED</cfif>>#DD_Status_Description#</option>
		</cfloop>
	</select>
</div>
<!--- Family Drop Down --->
<div class="filter mt-1" title="filter: #application.returned_customer_setting.family_name_label_singular#" id="ddfamily">
	<select name="dd_family" id="dd_family" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllFamilyNames">
			<option value="#Family_ID#" <cfif form.dd_family EQ Family_ID>SELECTED</cfif>>#Family_Name#</option>
		</cfloop>
	</select>
</div>
<!--- Analyst Drop Down --->
<div class="filter mt-1" title="filter: Deduction Analyst" id="ddAnalyst">
	<select name="dd_analyst" id="dd_analyst" multiple="multiple" style="width:99%;">
		<cfloop query="qGetAllAnalysts">
			<option value="#User_ID#" <cfif form.dd_analyst EQ User_ID>SELECTED</cfif>>#Name#</option>
		</cfloop>
	</select>
</div>
<!---  BUTTONS --->
<div style="display: flex;flex-direction: row;flex-wrap: wrap;justify-content: center; margin-top:8px; margin-bottom:8px;">
	<button type="button" id="ddSearchButton" onClick="DDvalidate();" title="search Deductions using the selected filters" class="button recommended">Search Deductions</button>
	<button type="button" onClick="resetDDOptions();" title="Clear the filters" class="button alt">reset</button>
</div>

</cfoutput>

<script type="text/javascript">
// Reset the filters (and the grid).  Used for reset button
function resetDDOptions() {
	$("select[name=dd_status_list]").multipleSelect('uncheckAll');
	$("select[name=dd_family]").multipleSelect('uncheckAll');
	$("select[name=dd_analyst]").multipleSelect('uncheckAll');

	$('#deduction_search').val('');
	$('#reference_search').val('');
	$('#check_search').val('');
	$('#creference_search').val('');
	$('#dd_customer_search').val('');

	no_data_available(DeductionGridOptions, "hidden");   // suppress no data available message
	DeductionGridOptions.api.setRowData([]);
}

function DDvalidate(){
	/*FILTER CHECK*/
	var DSearch  = $("input[name=deduction_search]").val();
	var RefSearch = $("input[name=reference_search]").val();
	var CSearch  = $("input[name=check_search]").val();
	var CRefSearch  = $("input[name=creference_search]").val();
	var CusSearch  = $("input[name=dd_customer_search]").val();

	var DDStatus  = $("#dd_status_list option:selected").val();
	var DDFamily  = $("#dd_family option:selected").val();
	var DDAnalyst  = $("#dd_analyst option:selected").val();

	if(typeof(DDStatus)  === "undefined") {
		DDStatus = 0;
	}
	if(typeof(DDFamily)  === "undefined") {
		DDFamily = 0;
	}
	if(typeof(DDAnalyst)  === "undefined") {
		DDAnalyst = 0;
	}

	var errors = [];
	var lenRequirment = 0;

	if (DSearch === '' && RefSearch === '' && CSearch === '' && CRefSearch === '' && CusSearch === '' & ! DDStatus & ! DDFamily & ! DDAnalyst){
		errors.push("Please enter a value for a filter.");
	}

if( ! DDStatus && ! DDFamily && ! DDAnalyst){
	if ( ! errors.length && (	(DSearch != '' && DSearch.length < 5)
																	|| (RefSearch != '' && RefSearch.length < 5)
																	|| (CSearch != '' && CSearch.length < 5)
																	|| (CRefSearch != '' && CRefSearch.length < 5)
																	|| (CusSearch != '' && CusSearch.length < 5))
	) {
		errors.push("Search string should be at least 5 characters.");
	}
}

	if (errors.length) {
		new Noty({ layout:"center", type:"error", text: noty_message(errors.join("<br>")) }).show();
		return;
	}else{
		$('#search').val('ded');
		ddLoad();
	}
}
</script>