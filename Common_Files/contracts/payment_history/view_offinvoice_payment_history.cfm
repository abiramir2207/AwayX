<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\payment_history\view_offinvoice_payment_history.cfm
      Date:     2015 December
      Author:   Milan Mushran
      Purpose:  offinvoice summary report
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<HTML>
<HEAD>
<TITLE>Payment History</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<!--- multiselect dependencies (start) --->
	<cfmodule template="/customTags/include.cfm" file_to_include="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css, /styles/jQueryUI_18/jquery.multiselect.css" />
	<!--- multiselect dependencies (end) --->

	 <style>
	 	h2 {
			<cfif val(plannerId) eq 0>background-color: #FFCE84;</cfif>
			height: 26px;
			line-height: 26px;
			border-top:1px solid black;
			border-bottom:1px solid black;
			padding-left: 7px;
			font-size: 1.3em;
		}
		table.datagrid { table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; }
		.header { width:100%; border-bottom:1px solid #000000;border-top:1px solid #000000;border-left:1px solid #000000;
				border-right:1px solid #000000;
				<cfif plannerId eq 0>
				background-color: #FFE083;
				<cfelse>
				background-color: #C4DCF1;
				</cfif>
		}
		body { overflow: hidden; }
		.right{text-align:right !important;}
		.center{text-align:center !important;}
		.csvExcludeAndCenter{text-align:center !important;}
		<cfif val(plannerId) neq 0>
		table.dataTable thead th{background-color: #9BC2E6;}
		</cfif>
	</style>
</HEAD>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<!---
Only when I changed the jquery version to 1.9.3, did the "datagrid" Processing error" went away.
Before it was "1.9.1".
--->
<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/jQuery.cfm">

<!--- multiselect dependencies (start) --->
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js, /Script/javascript/jQueryUI_18/jquery.multiselect.min.js, /Script/javascript/jquery.multiselect.filter.js"/>
<!--- multiselect dependencies (end) --->

<cfparam name="form.payee" default="">
<cfparam name="form.start_date_operator" default="">
<cfparam name="form.end_date_operator" default="">
<cfparam name="form.date_criteria_start" default="">
<cfparam name="form.date_criteria_end" default="">
<cfparam name="form.offinvoice_number" default="">
<cfparam name="form.item_number" default="">
<cfparam name="form.gridCollapse" default="0">
<cfparam name="productID" default="">
<cfparam name="plannerID" default="0">

<cfset oProgram = CreateObject("component", "components.programs.program") />

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />


<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(ContractId)>
<cfset getsummarypaymentdetails = PaymentHistoryManager.getsummarypaymentdetails(contract_number=getcontractInfo.contract_number,contractMainID=ContractId,offinvoice=1,plannerID=plannerID) />
<cfset getdateInfo = PaymentHistoryManager.getdateInfo(getcontractInfo.contract_number,ContractId)>
<cfset getDistributorsFromPaymentHistory = oProgram.getDistributorsFromPaymentHistory(getcontractInfo.contract_number,ContractId,plannerID)>
<cfset qGetOperatorOffInvoiceByDate = PaymentHistoryManager.getOperatorOffInvoiceByDate(getcontractInfo.contract_number,ContractId,form.start_date_operator,
																	form.end_date_operator,form.date_criteria_start,form.date_criteria_end,
																	form.payee,form.offinvoice_number,form.item_number,selectedMonths,plannerID) />


<BODY onLoad="disable_start_Date();disable_end_Date();">

<cfoutput>
	<h2><cfif val(plannerId) eq 0>#getcontractInfo.contract_number#: </cfif>OFF-INVOICE HISTORY</h2>

<cfif productID eq "">
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
<table class="header" cellpadding="2" cellspacing="0" border="0"  width="100%">
	<tr>
		<td width="33%"><b>Dollars:</b>&nbsp;#dollarformat(total_dollars)#</td>
		<td width="33%"><b>#application.uomcaseplural#:</b>#numberformat(getsummarypaymentdetails.volume_cs,'_,___,___,___,___')#</td>
		<td width="33%"><b>#application.uompoundplural#:</b>#numberformat(getsummarypaymentdetails.volume_lb,'_,___,___,___,___')#</td>
	</tr>
	<tr>
		<td width="33%"><b>Claims:</b>#numberformat(getsummarypaymentdetails.count,'_,___,___,___,___')#</td>
		<td width="33%"><b>Rate/#application.uomcasesingular#:</b>&nbsp;#dollarformat(avg_total_rate_cs)#</td>
		<td width="33%"><b>Rate/#application.uompoundsingular#:</b>&nbsp;#numberformat(avg_total_rate_lb,'$(_,.____')#</td>
	</tr>
</table>
</cfif>
<CFSET Date_Operator_Symbols=" ,>=,=,<=">

<form name="frmOffinvoicePaymentHistory" style="margin-top:2px;" action="view_offinvoice_payment_history.cfm" method="post">
<IMG <cfif form.gridCollapse eq 0> SRC="/images/nolines_plus.gif"<cfelse>SRC="/images/nolines_minus.gif"</cfif> id="idExpandCollapse"  style="vertical-align: middle;" TITLE="show filters" OnClick="showHideFilters('tblOffInvoiceHistory','idExpandCollapse');"><span style="font-size:10px;font-weight:bold;">FILTER</span>
<table id="tblOffInvoiceHistory" cellpadding="4" cellspacing="0"  border="0" <cfif form.gridCollapse eq 0>style="display:none"</cfif>>
	<tr>
		<td width="25%"><b>PAYEE</b></td>
		<td width="25%"><b>OFF-INVOICE DATE:&nbsp;FROM</b></td>
		<td width="27%"><b>OFF-INVOICE DATE:&nbsp;TO</b></td>
		<td width="23%">&nbsp;</td>
	</tr>
	<tr>
		<td>
			<!--- off-invoice does not use operators or brokers and so we only have "distributor" list below --->
			<select name="payee" id="payee" class="drpdwn" multiple="multiple" style="WIDTH:290px">
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
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td><b>OFF-INVOICE ##</b></td>
		<td><b>#UCASE(application.returned_customer_setting.item_label)#</b></td>
		<td>&nbsp;</td>
		<td><a href="javascript:exportAll();" id="exportData">#application.util.string.actionLinkFormat2("export invoices to csv")#</a></td>
	</tr>
	<tr>
		<td><input type="text" name="offinvoice_number" id="offinvoice_number" size="30" value="#form.offinvoice_number#">
		<td colspan="2"><input type="text" name="item_number" id="item_number" size="20" value="#form.item_number#">
		&nbsp;&nbsp;
			<a href="javascript:void();" onClick="filterData();">#application.util.string.actionLinkFormat2("filter data")#</a>
		&nbsp;&nbsp;
			<a href="javascript:void();" onClick="resetSearchFields();">#application.util.string.actionLinkFormat2("reset")#</a>
		</td>
		<td align="left">
				<a href="##" onclick="viewItems()">#application.util.string.actionLinkFormat2("view product detail")#</a>
		</td>
	</tr>
</table>
<input type="hidden" name="ContractId" value="#ContractId#">
<input type="hidden" name="gridCollapse" value="1">
<input type="hidden" name="selectedMonths" value="#selectedMonths#">
<input type="hidden" name="plannerID" value="#plannerID#">
</form>


<table id="datagrid" class="datagrid" style="table-layout:fixed;">
  <col width="3%"> <col width="11%"> <col width="22%"> <col width="24%"> <col width="20%"> <col width="20%">
  <thead>
  <tr>
    <th><input name="check_all_year_month" class="checkall" type="checkbox"></th>
    <th>Year</th>
    <th>Month</th>
    <th class="right">Dollars&nbsp;&nbsp;&nbsp;&nbsp;</th>
    <th class="right">Cases&nbsp;&nbsp;&nbsp;&nbsp;</th>
    <th class="right">Pounds&nbsp;&nbsp;&nbsp;&nbsp;</th>
  </tr>
  </thead>
  <tfoot>
    <tr>
      <th></th>
      <th></th>
      <th align="right"><b>Total:</b></th>
      <th id="totalDollars"></th>
      <th id="totalCases"></th>
      <th id="totalPounds"></th>
    </tr>
  </tfoot>
  <tbody>
  <cfloop query="qGetOperatorOffInvoiceByDate">
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
</table>

<!--- These form values are exclusively used to pass values the from values to a popup page.
These form values (filters) are needed
Some of these form values like "payee","offinvoice_number","product" are the search criteria
user enters on this screen.
--->
<form name="frmSearchCriteria" action="view_offinvoice_item_details.cfm" method="post">
	<input type="hidden" name="contract_number" value="#getcontractInfo.Contract_Number#">
	<input type="hidden" name="ContractId" value="#ContractId#">
	<input type="hidden" name="plannerID" value="#plannerID#">
	<input type="hidden" name="payee" value="#payee#">
	<input type="hidden" name="offinvoice_number" value="#offinvoice_number#">
	<input type="hidden" name="item_number" value="#item_number#">
	<!--- Stores the values of the checkboxes (Year/Month combination) --->
	<input type="hidden" name="yearMonthList" value="">
</form>

</cfoutput>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 55;
	var mydatagrid = '';
</script>

<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js, /Script/javascript/numeral.min.js"/>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>

<script type="text/javascript">
	var jTable = $(".datagrid");
	mydatagrid = jTable.dataTable({
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
		<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
		IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
		THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
		--->
		,"sScrollY" : 0 <!--- Leave this as 0 for setting datagrid height. --->
		/* This techinque of totalling is used when there is no paging. This will not count the total of all the pages. */
		,"fnDrawCallback": function() {
							var $tfoot = $('div.dataTables_scrollFootInner');

								var dollarArray = this.fnGetColumnData( iColumn=3,bUnique=false );
								var casesArray = this.fnGetColumnData(  iColumn=4,bUnique=false );
								var poundsArray = this.fnGetColumnData( iColumn=5,bUnique=false );

								var total_Dollars = totalColumn(dollarArray);
								var total_Cases = totalColumn(casesArray);
								var total_Pounds = totalColumn(poundsArray);

								/* total dollars formatted. */
								$tfoot.find('th#totalDollars').text( numeral(total_Dollars).format( "($0,0.00)" ) );

								/* total cases formatted. */
								$tfoot.find('th#totalCases').text( numeral(total_Cases).format( "0,0" ) );

								/* total pounds formatted. */
								$tfoot.find('th#totalPounds').text( numeral(total_Pounds).format( "0,0" ) );
							}
	});
	$(window).resize( function() {
		jTable.fnAdjustColumnSizing();
		jTable.fnDraw();
} );
	function totalColumn(arr){
		var columnTotal = 0;

		for(i=0;i<=arr.length;i++){
			columnTotal = columnTotal + numeral(arr[i]);
		}
	return columnTotal;
	}

	this.filterData = function()
	{
	$('form[name=frmOffinvoicePaymentHistory]').submit();
	}

	//initialize the multiselect widget(s).
	$("#payee").multiselect().multiselectfilter();

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
		start_Date(frmOffinvoicePaymentHistory.start_date_operator);
	}

	function disable_end_Date()
	{
		end_Date(frmOffinvoicePaymentHistory.end_date_operator);
	}

	function resetSearchFields()
	{
		document.getElementById('item_number').value = '';
		document.getElementById('offinvoice_number').value = '';
		document.getElementById('date_criteria_start').value = '';
		document.getElementById('date_criteria_end').value = '';
		document.getElementById('start_date_operator').value = '';
		document.getElementById('end_date_operator').value = '';
	}

	exportAll = function() {

	var selectInvoices = '';
	$('input[type=checkbox]:checked').each(function(index){
		if($(this).val() != 'on'){
			selectInvoices = selectInvoices.concat($(this).val()).concat(',');
		}
    });
		if(selectInvoices.length){
            if ($("iframe[name=export]").length == 0) {
        	    $("body").append('<iframe name="export" style="opacity:0"></iframe>');
    	    }

			let csv_src = "/Common_Files/exportAll.cfm?" + "type=getOperatorOffInvoiceByDate"
											+ "&contract_number=<cfoutput>#getcontractInfo.contract_number#</cfoutput>"
											+ "&contractMainID=<cfoutput>#contractID#</cfoutput>"
											+ "&plannerID=<cfoutput>#plannerID#</cfoutput>"
											+ "&start_date_operator=<cfoutput>#form.start_date_operator#</cfoutput>"
											+ "&end_date_operator=<cfoutput>#form.end_date_operator#</cfoutput>"
											+ "&date_criteria_start=<cfoutput>#form.date_criteria_start#</cfoutput>"
											+ "&date_criteria_end=<cfoutput>#form.date_criteria_end#</cfoutput>"
											+ "&payee=<cfoutput>#form.payee#</cfoutput>"
											+ "&offinvoice_number=<cfoutput>#form.offinvoice_number#</cfoutput>"
											+ "&item_number=<cfoutput>#form.item_number#</cfoutput>"
											+ "&friendlyFileName=<cfoutput>#urlEncodedFormat('OI_All_#getcontractInfo.contract_number#_')#</cfoutput>"
											+ "&filteredInvoices="+selectInvoices;
            $("iframe[name=export]").attr("src", csv_src);
		}else{
			alert('Please select a Invoice.')
		}
	}

	function viewItems(){
		var checkBox_checked = $('input[name=check_year_month]:checked');

		/* At least one selection needs to be made */
		if(checkBox_checked.length > 0){
			window.open('about:blank', 'formpopup', 'toolbars=no,scrollbars=no,resizable=yes,left=0,top=0,width=1150,height=620');
			frmSearchCriteria.target = 'formpopup';
			frmSearchCriteria.submit();
		}
		else{
			alert('Please select at least one Invoice');
		}
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
</script>
</BODY>
</HTML>