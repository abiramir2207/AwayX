<!DOCTYPE HTML>
<HTML>
<HEAD>
    <TITLE>Payment History</TITLE>
</HEAD>
<cfparam name="form.type_code_desc_id" default="">
<cfparam name="form.payee" default="">
<cfparam name="form.type" default="">
<cfparam name="form.start_date_operator" default="">
<cfparam name="form.end_date_operator" default="">
<cfparam name="form.date_criteria_start" default="">
<cfparam name="form.date_criteria_end" default="">
<cfparam name="form.settlement_id" default="">
<cfparam name="url.approval" default="0">
<cfparam name="form.gridCollapse" default="0">
<cfparam name="plannerId" default="0">
<cfparam name="form.mode" default="">
	
<!---<cfparam name="form.Contract_Main_ID" default="#url.ContractId#">--->
<cfset oProgram = CreateObject("component", "components.programs.program") />
<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />

<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
<cfset contractNumber = getcontractInfo.contract_number /> 
<cfset qGetBudgetActual = PaymentHistoryManager.getbudgetactual(contract_number=contractNumber, contractMainID=ContractId, plannerID=plannerID)>
<cfset IstOffInvoiceExist = PaymentHistoryManager.getOffInvoiceExist(contract_number=contractNumber, contractMainID=ContractId, plannerID=plannerID)>

<cfset getdateInfo = PaymentHistoryManager.getdateInfo(contractNumber, ContractId)>
<cfset getTypeCodesFromPaymentHistory = oProgram.getTypeCodesFromPaymentHistory(contractNumber, ContractId, plannerID)>
<cfset getDistributorsFromPaymentHistory = oProgram.getDistributorsFromPaymentHistory(contractNumber, ContractId, plannerID)>
<cfset getOperatorsFromPaymentHistory = oProgram.getOperatorsFromPaymentHistory(contractNumber, ContractId, plannerID)>
<cfset getBrokersFromPaymentHistory = oProgram.getBrokersFromPaymentHistory(contractNumber, ContractId, plannerID)>

<cfset qgetPaymentHistoryByDate = PaymentHistoryManager.getPaymentHistoryByDate(contractNumber,ContractId,form.type_code_desc_id,form.type,form.start_date_operator,
														form.end_date_operator,form.date_criteria_start,form.date_criteria_end,
														form.payee,form.settlement_id,plannerID)>

<cfset vars = structnew()>
<cfset vars.labelSettings = Createobject("component", "components.settings.Labels.Labels") />
<cfset vars.qBBLabels = vars.labelSettings.getBillBackLabels() />

<cfset structAppend(url, createObject( "component", "components.udf" ))>

<cfquery name="qBillbackLabels" dbtype="query">
	SELECT Billback_Labels_Label
	FROM vars.qBBLabels
	WHERE Billback_Labels_Label = 'Billback'
</cfquery>

<BODY onLoad="disable_start_Date();disable_end_Date();">

	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<!--- multiselect dependencies (start) --->
	<cfmodule template="/customTags/include.cfm" file_to_include="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css, /styles/jQueryUI_18/jquery.multiselect.css" />
	<!--- multiselect dependencies (end) --->

	 <style>
		table.datagrid { table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; }
		.header { width:100%; border-bottom:1px solid #000000;border-top:1px solid #000000;border-left:1px solid #000000;
				border-right:1px solid #000000;background-color: #ffe083;
		}
		body { overflow: hidden; }
		.right{text-align:right !important;}
		.center{text-align:center !important;}
		.csvExcludeAndCenter{text-align:center !important;}
		table.dataTable thead th{ font-weight: normal; font-family: "Arial";
		 	<cfif val(plannerId) neq 0>
		 	background-color: #9BC2E6;
			</cfif>
		 }
		
	</style>

    <!---
    Only when I changed the jquery version to 1.9.3, did the "datagrid" Processing error" went away.
    Before it was "1.9.1".
    --->
    <cfset datatables.version = "1.9.3">
    <cfinclude template="/common_files/jQuery.cfm">

    <SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

    <!--- multiselect dependencies (start) --->
    <cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js, /Script/javascript/jquery.multiselect.filter.js"/>
    <!--- multiselect dependencies (end) --->

<cfoutput>
<cfinclude template="/common_files/general_labels.cfm">
<cfif plannerId eq 0>
<table class="header" cellpadding="3" cellspacing="0">
	<tr>
		<td><b>Program ##:</b>&nbsp;#contractNumber#</td>
		<td><b>RSP:</b>&nbsp;#getcontractInfo.RSP#</td>
		<td><b>#general_labels[ delivery_period ]#</b>:&nbsp;#Dateformat(getdateInfo.start_date,"mm/dd/yyyy")# - #Dateformat(getdateInfo.end_date,"mm/dd/yyyy")#</td>
	</tr>
	<tr>
		<td colspan="2"><b>Title:</b>&nbsp;#left(getcontractInfo.Contract_Title,75)#</td>
		<td><b>Approved Date:</b>&nbsp;#getcontractInfo.Approval_Date#</td>
	</tr>
	<tr>
		<cfif len(getcontractInfo.contract_reference_number)>
		<td><b>Template:</b>&nbsp;#getcontractInfo.created_type#</td>
		<td colspan="2"><b>Reference ##:</b>&nbsp;#getcontractInfo.contract_reference_number#</td>
		<cfelse>
		<td colspan="3"><b>Template</b>:&nbsp;#getcontractInfo.created_type#</td>
		</cfif>
	</tr>
</table>
</cfif>
	
<CFSET Date_Operator_Symbols=" ,>=,=,<=">
<cfset actionpage = "/Common_Files/contracts/view_contract_payment_history.cfm" />
<cfif val(plannerId)>
	<cfset actionpage = "/planners/create/planner_spent.cfm" />
</cfif>
<form name="frmPaymentHistory" id="frmPaymentHistory" style="margin-top:2px;" action="#actionpage#" method="post">
<table width="100%">
	<tr>
		<td width="25%"><IMG <cfif form.gridCollapse eq 0> SRC="/images/nolines_plus.gif"<cfelse>SRC="/images/nolines_minus.gif"</cfif> id="idExpandCollapse"  style="vertical-align: middle;" TITLE="show filters" OnClick="showHideFilters('tblPaymentHistory','idExpandCollapse');">
		<span style="font-size:10px;font-weight:bold;">FILTER</span>
		</td>
		<td width="25%">&nbsp;</td>
		<td colspan="2" align="right">
		<a href="javascript:exportAll();" id="exportData">#application.util.string.actionLinkFormat2("export all #lcase(application.returned_customer_setting.item_label)# list to csv")#</a>
		&nbsp;&nbsp;
		<a href="##" onclick="viewItems()">#application.util.string.actionLinkFormat2("view selected product detail")#</a>
		</td>
	</tr>
</table>

<table id="tblPaymentHistory" cellpadding="4" cellspacing="0"  border="0" width="100%" <cfif form.gridCollapse eq 0>style="display:none"</cfif>>
	<tr>
		<td width="25%"><b>#application.returned_customer_setting.type_code_label_singular#</b></td>
		<td width="25%"><b>PAYEE</b></td>
		<td width="27%"><b>TYPE</b></td>
		<td width="23%">&nbsp;</td>
	</tr>
	<tr>
		<td>
			<select name="type_code_desc_id" id="type_code_desc_id" class="drpdwn" multiple="multiple" style="WIDTH:290px">
			<cfloop query="getTypeCodesFromPaymentHistory">
			<option value="#Type_Code_Desc_ID#"  <cfif ListFind(form.type_code_desc_id,getTypeCodesFromPaymentHistory.Type_Code_Desc_ID) neq 0>selected</cfif>>#Type_Code_Desc# (#Type_Code_Legacy#)</option>
			</cfloop>
			<optgroup label="NOT ON PROGRAM">
			<!--- Using "00000000-0000-0000-0000-000000000000" here, because the column in the query (arguments.type_code_desc_id) is a GUID. --->
			<option value="00000000-0000-0000-0000-000000000000" <cfif ListFind(form.type_code_desc_id,"00000000-0000-0000-0000-000000000000") neq 0>selected</cfif>>#UCASE(application.returned_customer_setting.item_label)#S NOT ON PROGRAM</option>
			</optgroup>
			</select>
		</td>
		<td>
			<select name="payee" id="payee" class="drpdwn" multiple="multiple" style="WIDTH:290px">
			<optgroup label="#UCASE(application.returned_customer_setting.operator_label_plural)#">
			<cfloop query="getOperatorsFromPaymentHistory">
			<option value="#BSA_Operator_id#" <cfif ListFind(form.payee,getOperatorsFromPaymentHistory.bsa_operator_id) neq 0>selected</cfif>>#Operator_Name# (#payee_id#)</option>
			</cfloop>
			</optgroup>

			<optgroup label="#UCASE(application.returned_customer_setting.broker_label_plural)#">
			<cfloop query="getBrokersFromPaymentHistory">
			<option value="#BSA_Foodservice_Brokers_ID#" <cfif ListFind(form.payee,getBrokersFromPaymentHistory.BSA_Foodservice_Brokers_ID) neq 0>selected</cfif>>#Broker_Name# (#broker_shard#)</option>
			</cfloop>
			</optgroup>

			<cfloop query="getDistributorsFromPaymentHistory">
			<optgroup label="#Family_Name#">
			<option value="#BSA_Foodservice_Customers_ID#" <cfif ListFind(form.payee,getDistributorsFromPaymentHistory.BSA_Foodservice_Customers_ID) neq 0>selected</cfif>>#Name# (#Shr_ship_to#)</option>
			</optgroup>
			</cfloop>

			<optgroup label="NOT ON PROGRAM">
			<option value="0" <cfif ListFind(form.payee,"0") neq 0>selected</cfif>><b>#UCASE(application.returned_customer_setting.distributor_label_plural)# NOT ON PROGRAM</b></option>
			</optgroup>
			</select>
		</td>
		<td>
			<select name="type" id="type" class="drpdwn" multiple="multiple" style="width:200px;">
			<option value="1" <cfif ListFind(form.type,1) neq 0>selected</cfif>>#qBillbackLabels.Billback_Labels_Label#</option>
			<option value="2" <cfif ListFind(form.type,2) neq 0>selected</cfif>>Off-Invoice</option>
			<cfif qGetBudgetActual.paid_amount neq "">
			<option value="3" <cfif ListFind(form.type,3) neq 0>selected</cfif>>Budget Actual Adjustment</option>
			</cfif>
			</select>
		</td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td><b>DATE:&nbsp;FROM</b></td>
		<td><b>DATE:&nbsp;TO</b></td>
		<td><b>SETTLEMENT ID</b>&nbsp;<span title="The Settlement ID represents either the check number, credit memo number or off-invoice number, depending upon the closing method." style="cursor:pointer;color:##0000FF;font-size:12px;;font-weight:bold;">?</span></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td valign="top">
			<table width="100%" border="0">
			<tr>
			<td width="10%"  valign="top">
			<select OnChange="JavaScript: start_Date(this);" name="start_date_operator" id="start_date_operator" style="WIDTH:45px">
				<cfset cnt=0>
				<cfloop list="#Date_Operator_Symbols#" index="thisOperator">
					<cfset cnt=cnt+1>
					<option value="#Trim(thisOperator)#"<CFIF FORM.start_date_operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</option>
				</cfloop>
			</select>
			</td>
			<td  style="padding-top:0px;">
			<SPAN ID="SP_Start_date">
				<CF_EASYDATE FORMNAME="frmPaymentHistory" FIELDNAME="date_criteria_start" FORMAT="mm/dd/yyyy" DEFAULT="#form.date_criteria_start#">
			</SPAN>
			</td>
			</tr>
			</table>
		</td>

		<td valign="top">
			<table width="100%" border="0">
			<tr>
			<td  width="10%" valign="top">
			<select OnChange="JavaScript: end_Date(this);" name="end_date_operator" id="end_date_operator" style="WIDTH:45px">
				<cfset cnt=0>
				<cfloop list="#Date_Operator_Symbols#" index="thisOperator">
					<cfset cnt=cnt+1>
					<option value="#Trim(thisOperator)#"<CFIF FORM.end_date_operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</option>
				</cfloop>
			</select>
			</td>
			<td style="padding-top:0px;">
			<SPAN ID="SP_End_date">
				<CF_EASYDATE FORMNAME="frmPaymentHistory" FIELDNAME="date_criteria_end" FORMAT="mm/dd/yyyy" DEFAULT="#form.date_criteria_end#">
			</SPAN>
			</td>
			</tr>
			</table>
		</td>

		<td valign="top"><input type="text" name="settlement_id" id="settlement_id" size="20" value="#form.settlement_id#">
		&nbsp;&nbsp;
		<a href="javascript:void();" onClick="filterData();">#application.util.string.actionLinkFormat2("filter data")#</a>
		&nbsp;&nbsp;
			<a href="javascript:void();" onClick="resetSearchFields();">#application.util.string.actionLinkFormat2("reset")#</a>
		</td>
		<td>&nbsp;</td>
	</tr>
</table>
<input type="hidden" name="ContractId" value="#ContractId#">
<input type="hidden" name="gridCollapse" value="1">
<input type="hidden" name="plannerID" value="#plannerID#">
<input type="hidden" name="mode" value="#form.mode#">
</form>

<cfset variables.totalDollars = 0>
<cfset variables.totalCases = 0>
<cfset variables.totalPounds = 0>

<table id="datagrid" class="datagrid" style="table-layout:fixed;">
  <col width="3%"> <col width="11%"> <col width="22%"> <col width="24%"> <col width="20%"> <col width="20%">
  <thead>
  <tr>
    <th><input name="check_all_year_month" id="check_all_year_month" class="checkall" type="checkbox"></th>
    <th>Year</th>
    <th>Paid Month</th>
    <th class="right">Dollars &nbsp; &nbsp;</th>
    <th class="right">Cases &nbsp; &nbsp;</th>
    <th class="right"><cfoutput>#get_UOM(2).Unit_Of_Measure_Desc#</cfoutput> &nbsp; &nbsp;</th>
  </tr>
  </thead>
  <tbody>
  <cfloop query="qgetPaymentHistoryByDate">
  	<cfset variables.totalDollars = variables.totalDollars + qgetPaymentHistoryByDate.Sales_Dollars>
	<cfset variables.totalCases = variables.totalCases + qgetPaymentHistoryByDate.Volume_Cs>
	<cfset variables.totalPounds = variables.totalPounds + qgetPaymentHistoryByDate.Volume_Lb>
	<tr>
		<td><input type="checkbox" name="check_year_month" class="cb" value="#Date_Year#-#DateMonth#" ONCLICK="if(!this.checked) document.all.check_all_year_month.checked = false;addRemoveSummaryEntries()"></td>
		<td>#Date_Year#</td>
		<td>#Date_Month#</td>
		<td class="dollars">#DollarFormat(Sales_Dollars)#</td>
		<td class="cases">#NumberFormat(Volume_Cs, "_,___,___,___,___")#</td>
		<td class="pounds">#NumberFormat(Volume_Lb, "_,___,___,___,___")#</td>
	</tr>
  </cfloop>
  </tbody>
  <tfoot>
    <tr>
      <th></th>
      <th></th>
      <th align="right"><b>Total:</b></th>
      <th id="totalDollars">#DollarFormat(variables.totalDollars)#</th>
      <th id="totalCases">#NumberFormat(variables.totalCases, "_,___,___,___,___")#</th>
      <th id="totalPounds">#NumberFormat(variables.totalPounds, "_,___,___,___,___")#</th>
    </tr>
  </tfoot>
</table>

<!--- These form values are exclusively used to pass values the from values to a popup page.
These form values (filters) are needed.
--->
<form name="frmSearchCriteria" action="/Common_Files/contracts/payment_history/view_item_details.cfm" method="post">
	<input type="hidden" name="contract_number" value="#contractNumber#">
	<input type="hidden" name="contractId" value="#contractId#">
	<input type="hidden" name="plannerID" value="#plannerID#">
	<input type="hidden" name="type_code_desc_id" value="#type_code_desc_id#">
	<input type="hidden" name="type" value="#type#">
	<input type="hidden" name="payee" value="#payee#">
	<input type="hidden" name="settlement_id" value="#settlement_id#">
	<!--- Stores the values of the checkboxes (Year/Month combination) --->
	<input type="hidden" name="yearMonthList" value="" id="yearMonthList">
</form>

<p>&nbsp;</p>

<table cellspacing="4">
	<tr>
			<td><a href="javascript: viewBillbackHistory('#contractNumber#','#ContractId#',#plannerID#);">#application.util.string.actionLinkFormat2("billback records")#</a></td>
		<cfif IstOffInvoiceExist GT 0>
			<td><a href="javascript: viewOffInvoiceHistory('#ContractId#',#plannerID#);">#application.util.string.actionLinkFormat2("off-invoice records")#</a></td>
		</cfif>
		<cfif qGetBudgetActual.paid_amount neq "">
			<td><a href="javascript: getbudgetactual('#contractNumber#','#ContractId#',#plannerID#);">#application.util.string.actionLinkFormat2("budget actual adjustment")#</b></a></td>
		</cfif>
		<!--- While approving a program, this link is visible. --->
		<cfif URL.Approval EQ 1>
			<td><a href="javascript: continueapproval();">#application.util.string.actionLinkFormat2("continue approval")#</a></td>
		</cfif>
	</tr>
</table>
</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 95;
	var mydatagrid = '';
</script>

<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js, /Script/javascript/numeral.min.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>

<script type="text/javascript">
	var jTable = $(".datagrid");
	 mydatagrid = $(".datagrid").dataTable({
		"aaSorting": []
		,"aoColumns": [
						{"bSortable":false, "sClass":"csvExclude"}	/* Col 1 */
						,{"bSortable":true,"sType":"numeric"}	/* Col 2 */
						,{ "bSortable": true}	/* Col 3 */
						,{ "bSortable": true, "sClass" : "right","sType":"dollar"}	/* Col 4 */
						,{ "bSortable": true, "sClass" : "right","sType":"dollar"}	/* Col 5 */
						,{ "bSortable": true, "sClass" : "right","sType":"dollar"}	/* Col 6 */
					]
		,"bAutoWidth": false            // false for quicker rendering
		,"bDeferRender": true           // true for quicker rendering
		,"bPaginate": false
		,"bProcessing": true            // true to show processing message in sorting large table
		,"bScrollCollapse": true        // true to put the footer of the grid just below the records, when there are a few records only
		,"bSortCellsTop": true          // true to inform sorting on first row in thead
		,"bSortClasses": false
		,"sDom": 'tir'
		<!---
		This will make sure that the height of the grid is adjusted depending on the window size and that the user can see maximum records on one page.

		NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
		IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
		THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
		--->
		//,"sScrollY" :0 <!--- Leave this as 0 for setting datagrid height. --->
		,"sScrollY" : Math.floor(jQuery(window).height()) - 150
	})

this.filterData = function()
{
	$('form[name=frmPaymentHistory]').submit();
}

function viewBillbackHistory(contractNumber,ContractId,plannerID){
	var SelectedMonths = '';
	if(document.getElementById("check_all_year_month").checked){
		SelectedMonths = 'ALL';
	}
	else{
		SelectedMonths = document.getElementById("yearMonthList").value;
	}
	if(SelectedMonths.length){
		window.open("/Common_Files/contracts/payment_history/view_billback_payment_history.cfm?selectedMonths="+ SelectedMonths +"&ContractNumber=" + contractNumber + "&ContractId=" + ContractId + "&plannerID=" + plannerID,"billbackPaymentHistory","toolbars=no,scrollbars=no,resizable=yes,left=0,top=0,width=1150,height=670");
	}else{
		alert('Please select at least one period');
	}
}

function viewOffInvoiceHistory(ContractId, plannerID){
	var SelectedMonths = '';
	if(document.getElementById("check_all_year_month").checked){
		SelectedMonths = 'ALL';
	}
	else{
		SelectedMonths = document.getElementById("yearMonthList").value;
	}
	if(SelectedMonths.length){
	window.open("/Common_Files/contracts/payment_history/view_offinvoice_payment_history.cfm?selectedMonths="+ SelectedMonths +"&ContractId=" + ContractId + "&plannerID=" + plannerID,"OffInvoicePaymentHistory","toolbars=no,scrollbars=no,resizable=yes,left=0,top=0,width=1000,height=600");
	}else{
		alert('Please select at least one period');
	}
}

//D36686
function getbudgetactual(contractNumber,ContractId,plannerID)
{
	window.open("/common_files/contracts/Budget_Actual_Adjustment.cfm?ContractNumber=" + contractNumber+"&ContractId=" + ContractId + "&plannerID=" + plannerID,"budgetActualAdjustment","toolbars=no,scrollbars=no,resizable=yes,left=0,top=0,width=900,height=620");
}

function getTrendAnalysis(contractNumber,ContractId)
{
	window.open("payment_history/trend_analysis.cfm?ContractNumber=" + contractNumber+"&ContractId=" + ContractId,"trendAnalysis","toolbars=no,scrollbars=no,resizable=yes,left=0,top=0,width=1200,height=700");
}

function viewItems(){
	var checkBox_checked = $('input[name=check_year_month]:checked');

	/* At least one selection needs to be made */
	if(checkBox_checked.length > 0){
		window.open('about:blank', 'formpopup', 'toolbars=no,scrollbars=no,resizable=yes,left=0,top=0,width=900,height=650');
		frmSearchCriteria.target = 'formpopup';
		frmSearchCriteria.submit();
	}
	else{
		alert('Please select at least one period');
	}
}
	//initialize the multiselect widgets.
	$("#payee").multiselect().multiselectfilter();
	$("#type_code_desc_id").multiselect().multiselectfilter();
	$("#type").multiselect().multiselectfilter();

	function start_Date(thisObj)
	{
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv("SP_Start_date",bDis,false);
	}

	function end_Date(thisObj)
	{
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv("SP_End_date",bDis,false);
	}

	function disable_start_Date()
	{
		start_Date(frmPaymentHistory.start_date_operator);
	}

	function disable_end_Date()
	{
		end_Date(frmPaymentHistory.end_date_operator);
	}

	function resetSearchFields()
	{
	document.getElementById("frmPaymentHistory").reset();
 	document.getElementById('type_code_desc_id').value='';
	document.getElementById('payee').value='';
	document.getElementById('type').value='';
	filterData();
		/*
		document.getElementById('settlement_id').value = '';
		document.getElementById('date_criteria_start').value = '';
		document.getElementById('date_criteria_end').value = '';
		document.getElementById('start_date_operator').value = '';
		document.getElementById('end_date_operator').value = '';
		*/
	}

	exportAll = function() {
	window.open( "/Common_Files/exportAll.cfm?" + "type=getPaymentHistoryByDate"
									+ "&contract_number=<cfoutput>#contractNumber#</cfoutput>"
									+ "&contractId=<cfoutput>#contractId#</cfoutput>"
									+ "&plannerId=<cfoutput>#plannerId#</cfoutput>"
									+ "&type_code_desc_id=<cfoutput>#form.type_code_desc_id#</cfoutput>"
									+ "&payment_type=<cfoutput>#form.type#</cfoutput>"
									+ "&payee=<cfoutput>#form.payee#</cfoutput>"
									+ "&settlement_id=<cfoutput>#form.settlement_id#</cfoutput>"
									+ "&start_date_operator=<cfoutput>#form.start_date_operator#</cfoutput>"
									+ "&end_date_operator=<cfoutput>#form.end_date_operator#</cfoutput>"
									+ "&date_criteria_start=<cfoutput>#form.date_criteria_start#</cfoutput>"
									+ "&date_criteria_end=<cfoutput>#form.date_criteria_end#</cfoutput>"
									+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('All_#contractNumber#_')#</cfoutput>"
		,"_blank"
		,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
	}

	// "Check/Uncheck all" checkboxes
	$('input[name=check_all_year_month]').change(function() {
		$("input.cb").attr("checked", (this.checked ? true : false));
		 addRemoveSummaryEntries();
	});

	function addRemoveSummaryEntries(){
		 /* all checked rows are saved in a hidden input with a name of 'yearMonthList' */
		var hiddenCBoxes = $('input[name=yearMonthList]').val();

		/* convert the list into an array for easy manipulation */
		if (hiddenCBoxes.length == 0)
			var aYearMonthList = [];
		else
			var aYearMonthList = hiddenCBoxes.split(",");

		/* scan thru all checkboxes on the page */
		$('input.cb').each( function() {
			var dtYearMonth = $(this).val();

			if ( $(this).prop('checked') ) {

				 /* checked box is not in the array, add it */
				if (aYearMonthList.indexOf( dtYearMonth ) == -1)
					aYearMonthList.push( dtYearMonth );
			}
			else {
				 /* box is not checked so we need to remove it */
				while(aYearMonthList.indexOf( dtYearMonth ) != -1) {
					aYearMonthList.splice(aYearMonthList.indexOf( dtYearMonth ),1);
				}
			}
		});

		/* convert array back to a list for usage in form action */
		hiddenCBoxes = aYearMonthList.join(",");

		/* refresh the hidden input with ALL selected rows */
		$('input[name=yearMonthList]').val( hiddenCBoxes );
	}

	/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_scrollBody').css('min-height', '30px');
	/* 
		101556	Headers in Payment History Billback screen not aligned/Anand Rao/12-Nov-2020 
		Resie the datagrid when the page is resized
	*/
	var update_size = function() {
   		$(mydatagrid).css({ width: $(mydatagrid).parent().width() });
    	mydatagrid.fnAdjustColumnSizing();  
  	}
	$(window).resize(function() {
		clearTimeout(window.refresh_size);
		window.refresh_size = setTimeout(function() { update_size(); }, 250);
	});
</script>

<cfinclude template="/common_files/focus.cfm">
</BODY>
</HTML>