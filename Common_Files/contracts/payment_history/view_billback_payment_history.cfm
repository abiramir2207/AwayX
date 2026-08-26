<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\view_billback_payment_history.cfm
      Date:     2015 December
      Author:   Milan Mushran
      Purpose:  list of billbacks associated to a program
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
 	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<!--- multiselect dependencies (start) --->
	<cfmodule template="/customTags/include.cfm" file_to_include="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css, /styles/jQueryUI_18/jquery.multiselect.css" />
	<!--- multiselect dependencies (end) --->

 <style>
	table.datagrid { table-layout: fixed; width: 100%; }
	thead th { text-align:left !important; }
	.header { width:100%; border-bottom:1px solid #000000;border-top:1px solid #000000;border-left:1px solid #000000;
			border-right:1px solid #000000;
			<cfif val(plannerId) eq 0>
			background-color: #FFE083;
			<cfelse>
			background-color: #C4DCF1;
			</cfif>
	}
	body { overflow: hidden; }
	.right{text-align:right !important;}
	.center{text-align:center !important;}
	<cfif val(plannerId) neq 0>
	table.dataTable thead th{background-color: #9BC2E6;}
	</cfif>
</style>
</HEAD>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<!--- Only when I changed the jquery version to 1.9.3, did the "datagrid" Processing error" went away.
Before it was "1.9.1".
--->
<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">

<!--- multiselect dependencies (start) --->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js, /Script/javascript/jquery.multiselect.filter.js"/>
<!--- multiselect dependencies (end) --->

<cfparam name="form.type_code_desc_id" default="">
<cfparam name="form.payee" default="">
<cfparam name="form.start_date_operator" default="">
<cfparam name="form.end_date_operator" default="">
<cfparam name="form.date_criteria_start" default="">
<cfparam name="form.date_criteria_end" default="">
<cfparam name="form.settlement_id" default="">
<cfparam name="form.billback_search" default="">
<cfparam name="productID" default="">
<cfparam name="ContractId" default="">
<cfparam name="plannerID" default="0">
<cfparam name="form.gridCollapse" default="0">
<cfparam name="URL.CPAccess" default=""><!--- 83860 URL.CPAccess will be used in Application_Common.cfm ---->
<cfparam name="url.selectedMonths" default="">

<cfset vars = structnew()>
<cfset vars.labelSettings = Createobject("component", "components.settings.Labels.Labels") />
<cfset vars.qBBLabels = vars.labelSettings.getBillBackLabels() />

<cfquery name="qBillbackLabels" dbtype="query">
	SELECT Billback_Labels_Label
	FROM vars.qBBLabels
	WHERE Billback_Labels_Label = 'Billback'
</cfquery>

<!--- "Product_ID" exists when user visits from "PRODUCT CLAIMED NOT ON PROGRAM" grid. --->
<cfif productID neq "">
	<cfquery name="qGetItemDetails" datasource="#application.datasource#">
		SELECT Item,Description
		FROM BSA_Foodservice_Items_Master
		WHERE BSA_Foodservice_Items_Master_ID = '#productID#'
	</cfquery>

	<cfset prod = qGetItemDetails.Item>
	<cfset prod_desc = qGetItemDetails.Description>
</cfif>

<BODY onLoad="disable_start_Date();disable_end_Date();">

<h3>
	<cfoutput>
		<div style="text-align:center">#UCASE(qBillbackLabels.Billback_Labels_Label)# RECORDS: <br /> #contractNumber#
			<cfif productID neq "">
				<br /> #application.returned_customer_setting.item_label#: #prod# (#prod_desc#)
			</cfif>
		</div>
	</cfoutput>
</h3>

<cfset oProgram = CreateObject("component", "components.programs.program") />
<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset getsummarypaymentdetails = PaymentHistoryManager.getsummarypaymentdetails(contract_number=contractNumber,contractMainID=ContractId,plannerID=plannerID) />
<cfset getTypeCodesFromPaymentHistory = oProgram.getTypeCodesFromPaymentHistory(contractNumber,ContractId,plannerID)>
<cfset getDistributorsFromPaymentHistory = oProgram.getDistributorsFromPaymentHistory(contractNumber,ContractId,plannerID)>
<cfset getOperatorsFromPaymentHistory = oProgram.getOperatorsFromPaymentHistory(contractNumber,ContractId,plannerID)>
<cfset getBrokersFromPaymentHistory = oProgram.getBrokersFromPaymentHistory(contractNumber,ContractId,plannerID)>

<cfset total_dollars = getsummarypaymentdetails.paid_amount>
<cfif getsummarypaymentdetails.volume_lb NEQ 0 and getsummarypaymentdetails.volume_lb NEQ "">
	<cfset avg_total_rate_lb = Total_Dollars/getsummarypaymentdetails.volume_lb>
<cfelse>
	<cfset avg_total_rate_lb = 0>
</cfif>
<cfif getsummarypaymentdetails.volume_cs NEQ 0 and getsummarypaymentdetails.volume_cs NEQ "">
	<cfset avg_total_rate_cs = Total_Dollars/getsummarypaymentdetails.volume_cs>
<cfelse>
	<cfset avg_total_rate_cs = 0>
</cfif>

<cfoutput>
<cfif productID eq "">
<table class="header" cellpadding="2" cellspacing="0" border="0"  width="100%">
	<tr>
		<td width="33%"><b>Dollars:</b>&nbsp;#dollarformat(total_dollars)#</td>
		<td width="33%"><b>#application.uomcaseplural#:</b>#numberformat(getsummarypaymentdetails.volume_cs,'_,___,___,___,___')#</td>
		<td width="33%"><b>#application.uompoundplural#:</b>#numberformat(getsummarypaymentdetails.volume_lb,'_,___,___,___,___')#</td>
	</tr>
	<tr>
		<td width="33%"><b>Claims:</b>#numberformat(getsummarypaymentdetails.bb_count,'_,___,___,___,___')#</td>
		<td width="33%"><b>Rate/#application.uomcasesingular#:</b>&nbsp;#dollarformat(avg_total_rate_cs)#</td>
		<td width="33%"><b>Rate/#application.uompoundsingular#:</b>&nbsp;#numberformat(avg_total_rate_lb,'$(_,.____')#</td>
	</tr>
</table>
</cfif>

<CFSET Date_Operator_Symbols=" ,>=,=,<=">

<form name="frmBillbackPaymentHistory" action="view_billback_payment_history.cfm" style="margin-top:2px;" method="post" id="frmBillbackPaymentHistory">
<cfif productID eq "" and request.AccessStructure.External_Customer_Profile_Access NEQ "1">
<IMG <cfif form.gridCollapse eq 0> SRC="/images/nolines_plus.gif"<cfelse>SRC="/images/nolines_minus.gif"</cfif> id="idExpandCollapse"  style="vertical-align: middle;" TITLE="show filters" OnClick="showHideFilters('tblBillbackHistory','idExpandCollapse');"><span style="font-size:10px;font-weight:bold;">FILTER</span>
<table id="tblBillbackHistory" width="100%" cellpadding="4" cellspacing="0" border="0"<cfif form.gridCollapse eq 0>style="display:none"</cfif>>
	<tr>
		<td width="25%"><b>#application.returned_customer_setting.type_code_label_singular#</b></td>
		<td width="25%"><b>PAYEE</b></td>
		<td width="30%"><b>#UCASE(qBillbackLabels.Billback_Labels_Label)#</b>&nbsp;<span title="Search on the following fields - payable ##, billback ## and billback title." style="cursor:pointer;color:##0000FF;font-size:12px;;font-weight:bold;">?</span></td>
		<td width="20%">&nbsp;</td>
	</tr>
	<tr>
		<td>
			<select name="type_code_desc_id" id="type_code_desc_id" class="drpdwn" multiple="multiple" style="width:290px;">
			<cfloop query="getTypeCodesFromPaymentHistory">
			<option value="#Type_Code_Desc_ID#"  <cfif ListFind(form.type_code_desc_id,getTypeCodesFromPaymentHistory.Type_Code_Desc_ID) neq 0>selected</cfif>>#Type_Code_Desc# (#Type_Code_Legacy#)</option>
			</cfloop>
			<optgroup label="OTHER">
			<!--- Using "00000000-0000-0000-0000-000000000000" here, because the column in the query (arguments.type_code_desc_id) is a GUID. --->
			<option value="00000000-0000-0000-0000-000000000000" <cfif ListFind(form.type_code_desc_id,"00000000-0000-0000-0000-000000000000") neq 0>selected</cfif>>#UCASE(application.returned_customer_setting.item_label)#S NOT ON PROGRAM</option>
			</optgroup>
			</select>
		</td>
		<td>
			<select name="payee" id="payee" class="drpdwn" multiple="multiple" style="width:290px;">
			<optgroup label="#UCASE(application.returned_customer_setting.operator_label_plural)#">
			<cfloop query="getOperatorsFromPaymentHistory">
			<option value="#BSA_Operator_id#" <cfif ListFind(form.payee,getOperatorsFromPaymentHistory.bsa_operator_id) neq 0>selected</cfif>>#Operator_Name# (#payee_id#)</option>
			</cfloop>

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

			<optgroup label="OTHER">
			<option value="0" <cfif ListFind(form.payee,"0") neq 0>selected</cfif>><b>#UCASE(application.returned_customer_setting.distributor_label_plural)# NOT ON PROGRAM</b></option>
			</optgroup>
			</select>
		</td>
		<td valign="top"><input type="text" name="billback_search" id="billback_search" size="20" value="#form.billback_search#">
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td><b>PAID DATE:&nbsp;FROM</b></td>
		<td><b>PAID DATE:&nbsp;TO</b></td>
		<td><b>SETTLEMENT ID</b>&nbsp;<span title="The Settlement ID represents either the check number or credit memo number, depending upon the closing method." style="cursor:pointer;color:##0000FF;font-size:12px;;font-weight:bold;">?</span></td>
		<td><a href="javascript:exportAll();" id="exportData">#application.util.string.actionLinkFormat2("export")#</a></td>
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
				<CF_EASYDATE FORMNAME="frmBillbackPaymentHistory" FIELDNAME="date_criteria_start" FORMAT="mm/dd/yyyy" DEFAULT="#form.date_criteria_start#">
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
				<CF_EASYDATE FORMNAME="frmBillbackPaymentHistory" FIELDNAME="date_criteria_end" FORMAT="mm/dd/yyyy" DEFAULT="#form.date_criteria_end#">
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
		<td><a href="##" onclick="submitform();">#application.util.string.actionLinkFormat2("view product detail")#</a></td>
	</tr>
</table>
</cfif>
			<input type="hidden" name="contractNumber" value="#contractNumber#">
			<!--- From "view_items_claimed_not_on_program.cfm", a specific "productID" is passed to this page. --->
			<input type="hidden" name="productID" value="#productID#">
			<input type="hidden" name="gridCollapse" value="1">
</form>


<!--- These form values are exclusively used to pass form values to a popup page.--->
<form name="frmSearchCriteria" action="/common_files/contracts/payment_history_item_details.cfm" method="post">
	<input type="hidden" name="ContractId" value="#ContractId#">
	<input type="hidden" name="plannerID" value="#plannerID#">
	<!--- Stores the value of the checkboxes for the selected records. --->
	<input type="hidden" name="billbackList" value="">
</form>


<form name="frmBillbackList" method="post">
<table id="datagrid" class="datagrid" style="table-layout:fixed;">
  <cfif productID eq "" and request.AccessStructure.External_Customer_Profile_Access NEQ "1">
  <col width="3%">
  <col width="23%">
  <cfelse>
  <col width="26%">
  </cfif>
  <col width="9%">
  <col width="18%">
  <col width="6%">
  <col width="6%">
  <col width="9%">
  <col width="9%">
  <col width="9%">
  <col width="8%">
  <thead>
  <tr>
	<cfif productID eq "" and request.AccessStructure.External_Customer_Profile_Access NEQ "1">
	<th><input name="payment_check_all" class="checkall" type="checkbox"></th>
	</cfif>
	<th>#qBillbackLabels.Billback_Labels_Label# ## <br /> #qBillbackLabels.Billback_Labels_Label# Title</th>
	<th>Payable ##</th>
	<th>Payee Name<br />Payee ##</th>
	<th>Start<br />Date</th>
	<th>End<br />Date</th>
	<th class="right">Paid $&nbsp;&nbsp;&nbsp;&nbsp; <br /> Settlement ID&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th>Approved<br />Ck Date <br> Ack'd</th>
	<th class="right">Pounds&nbsp;&nbsp;&nbsp;&nbsp; <br /> Avg Rate&nbsp;&nbsp;&nbsp;&nbsp;<br />(Pounds)&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th class="right">Cases&nbsp;&nbsp;&nbsp;&nbsp; <br /> Avg Rate&nbsp;&nbsp;&nbsp;&nbsp;<br />(Cases)&nbsp;&nbsp;&nbsp;&nbsp;</th>
  </tr>
  </thead>

  <tbody>
  </tbody>

  <tfoot>
   <tr>
   <cfif productID eq "" and request.AccessStructure.External_Customer_Profile_Access NEQ "1">
	<th>&nbsp;</th>
	</cfif>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th colspan="2" align="right"><b>Total (All pages):</b></th>
	<th id="totalPounds"></th>
	<th id="totalCases"></th>
    </tr>
  </tfoot>

</table>

</form>
</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 65;
	var mydatagrid = '';
</script>

<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js, /Script/javascript/numeral.min.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>

<cfif productID eq "" and request.AccessStructure.External_Customer_Profile_Access NEQ "1">
	<cfset sortColumnNum = 7>
<cfelse>
	<cfset sortColumnNum = 6>
</cfif>
<script type="text/javascript">
	var jTable = $(".datagrid");
	mydatagrid =  jTable.dataTable({
		"aaSorting": [ [<cfoutput>#sortColumnNum#</cfoutput>, 'asc'] ]
		,"aoColumns": [
						<cfif productID eq "" and request.AccessStructure.External_Customer_Profile_Access NEQ "1">
						{"bSortable":false, "sClass":"csvExclude"}, /* Col 1 */
						</cfif>
						{"bSortable":true}	/* Col 2 */
						,{ "bSortable": true}	/* Col 3 */
						,{ "bSortable": true}	/* Col 4 */
						,{ "bSortable": true}	/* Col 5 */
						,{ "bSortable": true}	/* Col 6 */
						,{ "bSortable": true, "sClass" : "right"}	/* Col 7 */
						,{ "bSortable": true, "sClass" : "center"}	/* Col 8 */
						/* Note: Even though we use "sType":"dollar", the sorting is on pounds and not "avg rate". */
						,{ "bSortable": true, "sClass" : "right"}/* Col 9 */
						/* Note: Even though we use "sType":"dollar", the sorting is on cases and not "avg rate". */
						,{ "bSortable": true, "sClass" : "right"}/* Col 10 */
					]
		,"bAutoWidth": false            // false for quicker rendering
		,"bDeferRender": true           // true for quicker rendering
		,"bPaginate": true
		,"bProcessing": true            // true to show processing message in sorting large table
		,"bServerSide": true
		,"bScrollCollapse": true        // true to put the footer of the grid just below the records, when there are a few records only
		,"bSortCellsTop": true          // true to inform sorting on first row in thead
		,"bSortClasses": false
		,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
		,"sAjaxSource": "../ajax/billback_details.cfm?selectedMonths=<cfoutput>#url.selectedMonths#&CPAccess=#url.CPAccess#</cfoutput>"
		,"sDom": 'ptir'
		,"iDisplayLength": 100
		,"sServerMethod": "POST"
		<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
		IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
		THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
		--->
		,"sScrollY" : Math.floor(jQuery(window).height()) -  220
		,"fnServerParams": function ( aoData ) {
			<cfoutput>
			aoData.push( { "name": "contractNumber", "value": '#contractNumber#' } );
			aoData.push( { "name": "contractMainID", "value": '#ContractId#' } );
			aoData.push( { "name": "plannerID", "value": '#plannerID#' } );
			<!--- Filtering options are not availablewhen we view details for a specific item and so in that case,
			do not pass these filtering options (form elements).
			--->
			<cfif productID eq "" and request.AccessStructure.External_Customer_Profile_Access NEQ "1">
			aoData.push( { "name": "type_code_desc_id", "value": $('select[name=type_code_desc_id]').val() } );
			aoData.push( { "name": "payee", "value": $('select[name=payee]').val() } );
			aoData.push( { "name": "start_date_operator", "value": $('select[name=start_date_operator]').val() } );
			aoData.push( { "name": "end_date_operator", "value":  $('select[name=end_date_operator]').val() } );
			aoData.push( { "name": "date_criteria_start", "value": $('input[name=date_criteria_start]').val() } );
			aoData.push( { "name": "date_criteria_end", "value": $('input[name=date_criteria_end]').val() } );
			aoData.push( { "name": "settlement_id", "value": $('input[name=settlement_id]').val() } );
			aoData.push( { "name": "billback_search", "value": $('input[name=billback_search]').val() } );
			</cfif>
			aoData.push( { "name": "productID", "value": '#productID#' } );
			<!--- SINCE WE MAY HAVE RECORDS ON MULTIPLE PAGES FOR SOME PROGRAMS, WE NEED TO PASS "billbackList" TO THE AJAX PROCESSING PAGE, SO THAT IF A USER FILTERS
			RECORDS ON THIS PAGE, AND THEN SELECTS RECORDS AND THEN FILTERS AGAIN, THE PREVIOUS SELECTED RECORDS ARE NOT LOST.
			--->
			aoData.push( { "name": "billbackList", "value": $('input[name=billbackList]').val() } );
			</cfoutput>
			}
	/* THIS TECHNIQUE OF TOTALLING IS USED WHEN WE THE DATA CALL IS AN AJAX CALL */
	,"fnServerData": function ( sSource, aoData, fnCallback ) {
		 $.ajax( {   "dataType": 'json'
				 , "type": "POST"
				 , "url": sSource
				 , "data": aoData
				 , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
										 $tfoot.find('#totalPounds').text(numeral(json.TOTALPOUNDSINVOICED).format( "0,0" ) );
										 $tfoot.find('#totalCases').text(numeral(json.TOTALCASESINVOICED).format( "0,0" ) );
										 fnCallback(json); }
		 } );
		}

	})

	//initialize the multiselect widgets.
	$("#payee").multiselect().multiselectfilter();
	$("#type_code_desc_id").multiselect().multiselectfilter();

	this.filterData = function()
	{
	/* Reload the grid using ajax. This way if a user has already selected billback(s) using the checkbox, the new search will still retain
	the previously selected billbacks. Normally this would alreayd happen if the filters are a part of the grid, but since the filters are
	not a part of the grid, below code is needed.
	*/
		mydatagrid.fnReloadAjax();
	}

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
		start_Date(frmBillbackPaymentHistory.start_date_operator);
	}

	function disable_end_Date()
	{
		end_Date(frmBillbackPaymentHistory.end_date_operator);
	}

	function resetSearchFields(){
		$('#frmBillbackPaymentHistory')[0].reset();
	}

	exportAll = function() {
		var selectBB = '';
			$('input[type=checkbox]:checked').each(function(index){
				if($(this).val() != 'on'){
 			 		selectBB = selectBB.concat($(this).val()).concat(',');
 				}else{
 					selectBB = 'ALL'
 					return false;
 				}
			});
		if(selectBB.length){
	window.open( "/Common_Files/exportAll.cfm?" + "type=getpaymentdetails"
								+ "&contract_number=<cfoutput>#ContractNumber#</cfoutput>"
								+ "&contractMainID=<cfoutput>#contractID#</cfoutput>"
								+ "&plannerID=<cfoutput>#plannerID#</cfoutput>"
								+ "&type_code_desc_id=<cfoutput>#form.type_code_desc_id#</cfoutput>"
								+ "&payee=<cfoutput>#form.payee#</cfoutput>"
								+ "&start_date_operator=<cfoutput>#form.start_date_operator#</cfoutput>"
								+ "&end_date_operator=<cfoutput>#form.end_date_operator#</cfoutput>"
								+ "&date_criteria_start=<cfoutput>#form.date_criteria_start#</cfoutput>"
								+ "&date_criteria_end=<cfoutput>#form.date_criteria_end#</cfoutput>"
								+ "&settlement_id=<cfoutput>#form.settlement_id#</cfoutput>"
								+ "&billback_search=<cfoutput>#form.billback_search#</cfoutput>"
								+ "&productID=<cfoutput>#productID#</cfoutput>"
								+ "&billbackLabel=<cfoutput>#qBillbackLabels.Billback_Labels_Label#</cfoutput>"
								+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('BB_#contractNumber#')#</cfoutput>"
								+ "&filteredBB="+selectBB

				,"_blank"
		,"toolbar=no, scrollbars=no, resizable=no, top=10000, left=1, width=1, height=1");
		}
		else{
			alert('Please select a Billback.')
		}
	}

	// "Check/Uncheck all" checkboxes
	$('input[name=payment_check_all]').change(function() {
		$("input.cb").attr("checked", (this.checked ? true : false));
		 addRemoveBB();
	});

	function submitform(){
	/* Below input stores a list of selected "billbacks", regardless of which page (The grid uses paging when the
	records exceeds a certain limit), the billback got selected. */
	var selectedBillbacks = $('input[name=billbackList]').val();

	/* At least one selection needs to be made */
	if(selectedBillbacks !=''){
			window.open('about:blank', 'formpopup', 'toolbars=no,scrollbars=no,resizable=yes,left=0,top=0,width=1200,height=650');
			frmSearchCriteria.target = 'formpopup';
			frmSearchCriteria.submit();
		}
		else{
			alert('Please select at least one Billback');
		}
	}

	function totalColumn(arr){
		var columnTotal = 0;

		for(i=0;i<=arr.length;i++){
			columnTotal = columnTotal + numeral(arr[i]);
		}
	return columnTotal;
	}

	function addRemoveBB(){
		 /* all checked rows are saved in a hidden input with a name of 'billbackList' */
		var hiddenCBoxes = $('input[name=billbackList]').val();

		/* convert the list into an array for easy manipulation */
		if (hiddenCBoxes.length == 0)
			var abillbackList = [];
		else
			var abillbackList = hiddenCBoxes.split(",");

		/* scan thru all checkboxes on the page */
		$('input.cb').each( function() {
			var bb_id = $(this).val();

			if ( $(this).prop('checked') ) {

				 /* checked box is not in the array, add it */
				if (abillbackList.indexOf( bb_id ) == -1)
					abillbackList.push( bb_id );
			}
			else {
				 /* box is not checked so we need to remove it */
				while(abillbackList.indexOf( bb_id ) != -1) {
					abillbackList.splice(abillbackList.indexOf( bb_id ),1);
				}
			}
		});

		/* convert array back to a list for usage in form action */
		hiddenCBoxes = abillbackList.join(",");

		/* refresh the hidden input with ALL selected rows */
		$('input[name=billbackList]').val( hiddenCBoxes );
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
</BODY>
</HTML>