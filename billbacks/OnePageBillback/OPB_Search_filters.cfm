<!--
  * ====================================================================================================
  *  @Author: Dinesh Rachala
  *    @Date: June 2019
  * @Remarks: OnePageBillback Search filter section of the left-side Control panel
  *	Used to search for Deductions, Programs, Billbacks
  * ====================================================================================================
-->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfscript>
	param name="form.search"				default="";
	param name="form.searchDD"				default="0";

	appSettings = application.appSettingsGet;
	qGetAllTemplates = CreateObject("component", "components.programs.template.TemplateManager").getAllTemplates();
	qGetAllPlannersTemplates = CreateObject("component", "MVC.Models.Planner.PlannerTemplateManager").getPlannerTemplates();
	qGetAllComponents = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager_Filters").getAllComponents();
  qGetClosingMethods = CreateObject("component", "MVC.Models.OnePageBillback.OPBManager_Filters").getClosingMethods();

	labelSettings = Createobject("component", "mvc.Models.SettingsService");
	stBBLabels = labelSettings.getBBLabels();
	stDDLabels = labelSettings.getDDLabels();

</cfscript>
<cfset request.altActiveColor = "true">
<cf_include files="/common_files/tabnavFlex.cfm"/>

<form name="frmSettlements" id="frmSettlements" method="post" action="/Common_Files/exportAll.cfm">

	<div class="nav">
		<ul class="nav">
			<li  class="topnav" onclick="showTab(event, 'programSearchTab')" id="programTab">Programs</li>
			<li  class="topnav" onclick="showTab(event, 'billbackSearchTab')" id="billbackTab">Billbacks</li>
			<cfif application.appSettingsGet.getDeduction_Module()>
				<li  class="topnav" onclick="showTab(event, 'deductionSearchTab')" id="deductionTab" style="display: none">Deductions</li>
			</cfif>
		</ul>
	</div>

	<div class="card-main">
		<div id="programSearchTab" class="tabContent">
			<cfinclude template = "filters/opb_program_filters.cfm">
		</div>
		<div id="billbackSearchTab" class="tabContent">
			<cfinclude template = "filters/opb_billback_filters.cfm">
		</div>
		<cfif application.appSettingsGet.getDeduction_Module()>
			<div id="deductionSearchTab" class="tabContent" style="display: none">
				<cfinclude template = "filters/opb_deduction_filters.cfm">
			</div>
		</cfif>
	</div>

	<input type="hidden" name="search" value="<cfoutput>#form.Search#</cfoutput>" id="search">
	<input type="hidden" name="WorkItemType" value="" id="WorkItemType">
	<input type="hidden" name="MatchItemType" value="" id="MatchItemType">
	<input type="hidden" name="WorkWith" value="" id="WorkWith">
	<input type="hidden" name="fromCreate" id="fromCreate" value="0">
	<!--- "type" and "friendlyFileName" variables are needed for "download data". --->
	<input type="hidden" name="type" value="getSettlementsData">
	<input type="hidden" name="friendlyFileName" value="Settlements_data">

	<!---- BILLBACK FIELDS ---->
	<input type="hidden" name="MatchBillbackID" id="MatchBillbackID" value="" >
	<input type="hidden" name="MatchBillback" id="MatchBillback" value="" >
	<input type="hidden" name="MatchPayeeName" id="MatchPayeeName" value="" >
	<input type="hidden" name="MatchPayeeID" id="MatchPayeeID" value="">
	<input type="hidden" name="MatchReference" id="MatchReference" value="">
	<input type="hidden" name="MatchBBAppAmt" id="MatchBBAppAmt" value="">

 <!--- DEUDCTION FIELDS ---->
	<input type="hidden" name="MatchDeduction"  id="MatchDeduction" value="">
	<input type="hidden" name="MatchDeductionID" id="MatchDeductionID" value="">
	<input type="hidden" name="MatchDDAmount" id="MatchDDAmount" value="">

<!---SEARCH FILTERS ---->
<cfinclude template = "filters/OPB_BB_DD_Search_Filters.cfm">
</form>
<div id="MatchInfo" class="details-card" style="display: none">
	<div class="card-header">Match Type</div>
	<div class="card-main" style="width: 100%;">
		<div style="width:90%;float:left" id="MTypeInfo" ></div>
		<div style="width:9%;float:right;"><i class="fa fa-redo" onclick="clearMatch()"></i></div>
	</div>
</div>

<script>
	// Used to configure the multi-select dropdowns
	function ms_config(placeholder, deleteOption, single, dropWidth, position) {
		deleteOption = ( deleteOption || false);
		single       = ( single || false );
		dropWidth   = (dropWidth || '230px');
		position   = (position || 'bottom');

		return ({
					deleteOption: deleteOption
					,filter: true
					,placeholder: placeholder
					,selectAllDelimiter: "[]"
					,selectAllText: placeholder
					,single: single
					,width: '99%'
					,dropWidth : dropWidth
					,maxHeight: '200'
					/* position: 'top' will make sure that the dropdown opens up upwards */
					,position: position
				});
	}

	// Init the search multi-select filters
	activate_multipleSelect();

	// Setup each of the multi-select dropdowns
	function activate_multipleSelect() {

		$("select[name=template_list]").multipleSelect( ms_config('Show All Program Templates', false, false, '325px') );
		$("select[name=planner_list]").multipleSelect( ms_config('Show All <cfoutput>#Application.PlannerLabel#</cfoutput> Templates', false, false, '325px') );
		$("select[name=paid_to]").multipleSelect( ms_config('Show All Paid To', false, false, '325px') );
		$("select[name=discount_type]").multipleSelect( ms_config('Show All Discount Types', false, false, '325px') );
		$("select[name=component_list]").multipleSelect( ms_config('Show All Components', false, false, '325px') );

		$("select[name=bb_status_list]").multipleSelect( ms_config('Show All Billback Status', false, false, '325px') );
		$("select[name=bb_closing_method]").multipleSelect( ms_config('Show All Billback Closing Methods', false, false, '325px') );
		$("select[name=billback_analyst]").multipleSelect( ms_config('Show All Billback Analysts', false, false, '325px') );
		$("select[name=bb_template_list]").multipleSelect( ms_config('Show All Program Templates', false, false, '325px') );
		$("select[name=bb_component_list]").multipleSelect( ms_config('Show All Components', false, false, '325px') );
		$("select[name=bb_paid_to]").multipleSelect( ms_config('Show All Paid To', false, false, '325px') );

		$("select[name=dd_status_list]").multipleSelect( ms_config('Show All Deduction Status', false, false, '325px') );
		$("select[name=dd_family]").multipleSelect( ms_config('Show All <cfoutput>#application.returned_customer_setting.family_name_label_singular#</cfoutput>', false, false, '325px') );
		$("select[name=dd_analyst]").multipleSelect( ms_config('Show All Deduction Analysts', false, false, '325px') );

	}

function clearMatch(){
	$("#WorkItemType").val('');
	$("#WorkWith").val('');
	$("#MTypeInfo").text('');
	$("#MatchInfo").hide();
	$("#SearchFilters").hide();

  var BBType = $("input[name=billback]").attr("type") ;
  var DDType = $("input[name=deduction]").attr("type") ;
  var fieldName = '';

	if(BBType == 'radio'){
		$("input:radio").attr("checked", false);
	}else{
	 	$("input:checkbox").attr("checked", false);
	 	fieldName = 'billback';
	}

	if(DDType == 'radio'){
		$("input:radio").attr("checked", false);
	}else{
	 	$("input:checkbox").attr("checked", false);
	 	fieldName = 'deduction';
	}

	$("input[name="+fieldName+"]").prop('type', 'radio');
	$("tr[id='MatchInformation']").remove();//CLEAR TBODY SECTION IN MATCH BLOCK
	$("#RemainingBalance").html('$0.0000');//CLEAR REMAINING BALANCE IN MATCH BLOCK
	$("#RemainingBalance").css("color", "black");
	$("#MatchID").html('Deduction/Billback');//CLEAR SELECTED BILLBACK/DEDUCTION IN MATCH BLOCK
	$("#MatchAmount").html('');//CLEAR SELECTED BALANCE IN MATCH BLOCK
	$("#processButton").html('');//CLEAR PROCESS BOX IN MATCH BLOCK
	$( "#SplitRecord" ).val('');//CLEAR SPLIT BOX IN MATCH BLOCK
	$( "#matchList" ).val('');//CLEAR MATCH LIST

	$("#BBcheckall, #DDcheckall").hide();
	$("#BBcheckall").prop("checked", false);
	$("#DDcheckall").prop("checked", false);
	<cfif ! appSettings.getDDAllowNegativeAmountCredits() AND application.appSettingsget.getAuto_Reconcile_Match_Central_BB() NEQ 1>
	$("#negativeBalanceWhenNoCredit").val('0');
	$('#negativeMessageTable').hide();
	</cfif>

/*DROP DOWN RESET*/
$('#mainClassificationID').empty();
$('#mainClassificationID').append('<option >**<cfoutput>#MCObject.stDeductionLabels["Classification"]#</cfoutput>** </option>');

$('#ClosureReasonCode').empty();
$('#ClosureReasonCode').append('<option > ** Closure <cfoutput>#MCObject.stDeductionLabels["Reason Code"]#</cfoutput>** </option>');

$('#ClassificationID').empty();
$('#ClassificationID').append('<option >Select an option</option>');

$('#ReasonCodeForSplit').empty();
$('#ReasonCodeForSplit').append('<option > Select an option </option>');

$('#RebillPackage').empty();
$('#RebillPackage').append('<option > Select Rebill Package </option>');

$('#WhatToDo').empty();
$('#WhatToDo').append('<option >**Split Action**</option>');

$('#WriteOffReason').val('');

//$("input[name=match_deduction][value='0']").prop("checked",true);
	$( "#matchDDNo" ).prop( "checked", true );
	hideDDSection( '0' );
	/*RESET SEARCH FILTERS AGAIN*/
	$( "#FILTERworkItemamount" ).prop( "checked", true );
	$( "#FILTERdistributor" ).prop( "checked", true );
<cfif appSettings.getDDCloseWithEqualBBAmt()>
	$( "#FILTERremainingBalance" ).prop( "checked", true );
<cfelse>
	$( "#FILTERremainingBalance" ).prop( "checked", false );
</cfif>
	$( "#FILTERrefnumber" ).prop( "checked", true );
	$("#FILTERdistributor1").prop("checked",true);

	$("#FILTERworkItemamount").val('');
	$("#FILTERddAmount").val('');
	$("#FILTERdistributor").val('');
	$("#FILTERremainingBalance").val('');
	$("#FILTERremainingAmt").val('');
	$("#FILTERkeyword").val('');
	$("#MC_Shr_Ship_to").val('');
	$("#MC_Distributor_Name").val('');
	$("#MC_Bill_To_Name").val('');
	$("#MC_Shr_Bill_To").val('');
	$("#MC_Vendor_ID").val('');
	$("#MC_Vendor_Name").val('');
	$("#FILTERDistributorFamilyID").val('');

	if($('#WorkItemType').val()==''){
		bbLoad();
	}

}
</script>