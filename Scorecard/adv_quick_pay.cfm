  <cf_include files="/script/javascript/string_functions.js, /script/javascript/numeral.min.js,  /common_files/noty.cfm, /Common_Files/dhx_message.cfm">
  <cf_include files=" /script/javascript/default.js, /styles/css-loader.css, /common_files/datatable.css">

	<cfset jQueryUI.widgets = "datepicker">
	<cfset datatables.version = "1.10.19">
	<cfset datatables.extensions = "fixedheader">
	<cfinclude template="/Common_Files/dataTables2.cfm">
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		.flex-container {
			display: flex;
			flex-flow: row wrap;
			justify-content: left;
			padding: 0;
			margin: 0;
			list-style: none;
		}
		.flex-item {
			width: 160px;
			height: auto;
			padding : 2px;
			margin-left: 5px;
			text-align: left;
		}
		.input{ width:150px; }
			.dollar { text-align: right; }
			.dataTables_wrapper .dataTables_filter {float:left; margin-top:4px; margin-right:15px;}
			.BBHeader {
			background-color:#ffce84;
			border:1px dotted #CCC;
			padding:4px;
			font-family:"Century Gothic",Verdana,Arial;
			font-size:1.05em;
			font-weight:bold;
			letter-spacing:0.2px;
			text-align:left;
			width:100%;
		}
		.importDD{
			width:700px;
			float:right;
		}
	</style>
	<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js?foo"></script>
	<cfset variables.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

	<cfset objSettingsService = createobject("component", "mvc.models.SettingsService") />
	<cfset QuickPay = createobject("component", "components.Billback.Quick_Pay") />
	<cfset ProgTrade 	= CreateObject("component", "components.programs.volume.ProgramVolume").getTotalTradeSpend(ContractNumber) />
	<cfset stBBLabels = objSettingsService.getBBLabels()>

	<cfif isdefined('url.cid')>
		<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">
		<cfset ContractMainID = cryp.value>
	<cfelse>
		<cfset ContractMainID = Form.ContractMainID>
	</cfif>

	<cfset LockPrg = QuickPay.ProgramStatus(Contract_Main_ID=ContractMainID, LockType=1)>
	<cfset DDForge = variables.appSettings.get_Setting('DD_In_Forge')>

<cfquery NAME="ClosingMethods" datasource="#application.datasource#">
	SELECT	iBillback_Closing_Method_ID, vchBillback_Closing_Method_Desc, qpDefault, Closing_Method_Code
	FROM  	Billback_Closing_Methods
	WHERE Deleted = 0
	AND Display_In_Advance_QP = 1
	ORDER BY Display_Sequence
</cfquery>

<cfquery name="userPosition" datasource="#application.datasource#">
	SELECT a.User_Positions_ID
	FROM User_Position_Holders a
	WHERE a.User_ID = '#request.AccessStructure.user_id#'
	AND a.User_Position_Type = 'P'
	AND	a.Deleted = 0
</CFQUERY>

<cfset RemainingAccrual = QuickPay.getAccrualAmount(contractmainid)>
<cfset qbudgetBalance = QuickPay.getBudgetBalance(contractmainid, ContractNumber)>
<cfset budgetBalance =  qbudgetBalance.budget_Balance />
<cfif ! len(budgetBalance)>
	<cfset budgetBalance = 0>
</cfif>
<cfset ProgramTradeEstimate = QuickPay.getTradeBalance(ContractNumber)>
<cfif ! len(ProgramTradeEstimate)>
	<cfset ProgramTradeEstimate = 0>
</cfif>
<cfset PrgComponents = QuickPay.getPrgComponents(contractmainid)>
<cfset PrgDistributors = QuickPay.getPrgDistributors(ContractNumber)>
<cfset TaxTypes = QuickPay.getTaxTypes()>

<cfsavecontent variable="BalanceInfo">
	<cfif variables.appSettings.get_Setting('Advance_Quick_Pay_Control') EQ 1 OR variables.appSettings.get_Setting('Advance_Quick_Pay_Control') EQ 3>
		<!---ACCRUAL--->
		<b>Program Accrual Balance : </b><span id="BalanceDisplay" style="padding-right:10px;"><cfoutput>#lscurrencyformat(RemainingAccrual)#</cfoutput> </span>
	<cfelseif variables.appSettings.get_Setting('Advance_Quick_Pay_Control') EQ 2 OR variables.appSettings.get_Setting('Advance_Quick_Pay_Control') EQ 3>
		<!---BUDGET--->
		<b>Budget Balance : </b><span id="BalanceDisplay" style="padding-right:10px;"><cfoutput>#lscurrencyformat(budgetBalance)#</cfoutput> </span>
	<cfelseif variables.appSettings.get_Setting('Advance_Quick_Pay_Control') EQ 4>
		<!---PROGRAM TRADE--->
		<b>Estimate Trade Balance : </b><span id="BalanceDisplay" style="padding-right:10px;"><cfoutput>#lscurrencyformat(ProgramTradeEstimate)#</cfoutput> </span>
	</cfif>
</cfsavecontent>
<cfset  DDID = '00000000-0000-0000-0000-000000000000'>

<form name="CreateBBform" method="post" id="CreateBBform" action="adv_quick_pay.cfm?CID=<cfoutput>#URL.CID#</cfoutput>">

<div class="flex-container">

	<div class="flex-item" id="CM" style="width:250px;margin-left:0px;padding-left:0px">
		Closing Method &nbsp;&nbsp;&nbsp;<cfif ! DDForge><br></cfif><select name="Closing_Method_ID" id="Closing_Method_ID" style="margin-top:5px;">
			<option value="0" id="0">Select a Closing Method</option>
			<cfoutput query="ClosingMethods">
				<option value="#iBillback_Closing_Method_ID#" data-id="#Closing_Method_Code#" <cfif qpDefault>Selected</cfif>>#vchBillback_Closing_Method_Desc#</option>
			</cfoutput>
		</select>
	</div>

	<!--- DEDUCTION FIELDS START--->
  <div class="flex-item" id="RefNum"><span id="RefNumText"></span><input class="input" type="text" name="Billback_Number" value="" size="5" id="Billback_Number" style="margin-top:5px;"></div>
	<div class="flex-item" id="TotAmt"><span id="TotAmtText"></span><input class="input" type="text" name="Total_Amount" value="0.00" size="5" id="Total_Amount" onKeyUp="clenseText(this, '0123456789.');" style="margin-top:5px;"></div>
	<div class="flex-item" id="BalanceInfo" style="text-align:right; width:300px"><cfoutput>#BalanceInfo#</cfoutput></div>
<!--- DEDUCTION FIELDS END ---->

</div>
<cfif DDForge>
	<!--- SELECTED DEDUCTIONS --->
	<div style="float:right;display:none;" class="BalanceInfo"><cfoutput>#BalanceInfo#</cfoutput></div>

	<table class="datagrid" style="display:none;">
		<thead>
			<th>&nbsp;</th>
			<th>Deduction #</th>
			<th style="text-align:right">Amount</th>
			<th style="text-align:right">Allocation $</th>
			<th>Date</th>
			<th>Reference #</th>
			<th>Payee </th>
			<th>Component</th>
			<!---117446 :: Billback - sales tax code START --->
			<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
			<th>Tax Type</th>
			</cfif>
			<!---117446 :: Billback - sales tax code END --->
		</thead>
		<tbody id="groupLevelFooter"></tbody>
	</table>

<table id="allDeductions" class="datagrid" style="table-layout:fixed;">
	<thead>
		<th width="30"><input type= "checkbox" onclick=javascript:HeaderClick(this.checked)  id = "DDcheckall"  name = "DDcheckall" ></th>
		<th width="150">Deduction #</th>
		<th width="100">Amount</th>
		<th width="100">Date</th>
		<th width="100">Reference</th>
		<th width="100">Customer #</th>
		<th width="200">Customer Name</th>
	</thead>
	<tbody>
	</tbody>
</table>
<cfelse>

</cfif>

<!--- BILLBACK OTHER FIELDS START---->
<div class="flex-container"  id="BBOtherFields" style="display:none;padding-top:10px;">
	<div class="BBHeader" style="margin-bottom:5px;"><cfoutput>#stBBLabels.Payable# Basic Info</cfoutput></div>
<!---
BB Start and BB End should be within program span. Rules -
•	If Program is pre-active, then default the BB start and BB End should be program’s start date.
•	If Program Active or Expiring, then default the BB start and BB end dates to ‘today’.
•	If Program is Expired, then BB start and BB End should be program’s end date.
---->
<cfif getPrginfo.contract_status_type_idx EQ 4><!--- PRE-ACTIVE--->
	<cfset BB_Start_Date = "#dateformat(getPrginfo.contract_start_date,'mm/dd/yyyy')#">
	<cfset BB_End_Date = "#dateformat(getPrginfo.contract_start_date,'mm/dd/yyyy')#">
<cfelseif getPrginfo.contract_status_type_idx EQ 5 OR getPrginfo.contract_status_type_idx EQ 6><!--- ACTIVE OR EXPIRING--->
	<cfset BB_Start_Date = "#dateformat(now(),'mm/dd/yyyy')#">
	<cfset BB_End_Date = "#dateformat(now(),'mm/dd/yyyy')#">
<cfelseif getPrginfo.contract_status_type_idx EQ 7><!--- EXPIRED--->
	<cfset BB_Start_Date = "#dateformat(getPrginfo.contract_end_date,'mm/dd/yyyy')#">
	<cfset BB_End_Date = "#dateformat(getPrginfo.contract_end_date,'mm/dd/yyyy')#">
<cfelse><!---OTHER--->
	<cfset BB_Start_Date = "#dateformat(now(),'mm/dd/yyyy')#">
	<cfset BB_End_Date = "#dateformat(now(),'mm/dd/yyyy')#">
</cfif>

	<div class="flex-item" id="BBStartDate">
		Delivery Period Start Date
		<input class="input date-info" type="text" name="BB_Start_Date" value="<cfoutput>#BB_Start_Date#</cfoutput>" size="5" id="BB_Start_Date" style="margin-top:5px;">
	</div>

	<div class="flex-item" id="BBEndDate">
		Delivery Period End Date
		<input class="input date-info" type="text" name="BB_End_Date" value="<cfoutput>#BB_End_Date#</cfoutput>" size="5" id="BB_End_Date" style="margin-top:5px;">
	</div>

	<div class="flex-item" id="BBDate">
		Billback Date
		<input class="input date-info" type="text" name="BB_Date" value="<cfoutput>#dateformat(now(),'mm/dd/yyyy')#</cfoutput>" size="5" id="BB_Date" style="margin-top:5px;">
	</div>

	<div class="flex-item" id="BBPayee" style="width:300px;display:none">
		Payee
		<select name="BB_Payee" id="BB_Payee" style="width:300px;margin-top:5px;">
			<option value="00000000-0000-0000-0000-000000000000">Select a Payee</option>
			<cfoutput query="PrgDistributors">
				<option value="#BSA_Foodservice_Customers_ID#"  data-id="D" data-number="#Payee_ID#">#Name# - (#Payee_ID#)</option>
			</cfoutput>
		</select>
	</div>

	<div class="flex-item" id="BBComponent" style="width:300px;display:none">
		Component
		<select name="BB_Component" id="BB_Component" style="width:300px;margin-top:5px;">
			<option value="0">Select a Components</option>
			<cfoutput query="PrgComponents">
				<option value="#ID#" data-type="#Discount_Type#" data-name='#Program_Rebates_Component_Name#'>#Name#</option>
			</cfoutput>
		</select>
	</div>

	<div class="flex-item" id="VendorInfo" style="disply:none;width:250px">
		Vendor 	<a id="vendorSearch"><cfoutput>#application.util.string.actionLinkFormat2('search')#</cfoutput></a>
		<input class="input date-info" type="text" name="Vendor" value="" size="5" id="Vendor" style="width:250px;margin-top:5px;" readonly>
		<input class="input date-info" type="hidden" name="Vendor_ID" value="" size="5" id="Vendor_ID">
		<input class="input date-info" type="hidden" name="Vendor_Master_ID" value="" size="5" id="Vendor_Master_ID">
	</div>
	<!---117446 :: Billback - sales tax code START --->
	<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
		<div class="flex-item" id="TaxTypeInfo" style="disply:none;width:300px">
			Tax Type
			<select name="Tax_Type" id="Tax_Type" style="width:300px;margin-top:5px;">
				<option value="0">Select a Tax Type</option>
				<cfoutput query="TaxTypes">
				<option value="#BB_Tax_Main_ID#">#TaxType#</option>
				</cfoutput>
			</select>
		</div>
	</cfif>
	<!---117446 :: Billback - sales tax code END --->
</div>

 <!---BILLBACK OTHER FIELDS END ----><br>
	<a id="createBB" style="display:none;"><cfoutput>#application.util.string.actionLinkFormat2('Create #stBBLabels.Payable#')#</cfoutput></a>
	<a id="reset" style="display:none;"><cfoutput>#application.util.string.actionLinkFormat2('Reset')#</cfoutput></a>
	<input type="hidden" name="Closing_Method" value="" id="Closing_Method" >
	<input type="hidden" name="Deduction_ID" value="" id="Deduction_ID" >
	<input type="hidden" name="DDAllocation" value="" id="DDAllocation" >
	<input type="hidden" name="Prg_Comp_Len" value="" id="Prg_Comp_Len" >
	<input type="hidden" name="DD_Number" value="" id="DD_Number" >
	<input type="hidden" name="DD_Ref_selected" value="" id="DD_Ref_selected" >
	<input type="hidden" name="DD_selected_Amount" value="" id="DD_selected_Amount" >
	<input type="hidden" name="DD_Total_Amount" value="" id="DD_Total_Amount" >
	<input type="hidden" name="DD_List" value="" id="DD_List" >
	<input type="hidden" name="Contract_Main_ID" value="<cfoutput>#ContractMainID#</cfoutput>" id="Contract_Main_ID" >
	<input type="hidden" name="User_Position_ID" value="<cfoutput>#userPosition.User_Positions_ID#</cfoutput>" id="User_Position_ID" >
	<input type="hidden" name="Unique_ID" value="" id="Unique_ID" >
	<cfoutput>
	<input type="hidden" name="#DDID#_CompName_0" value="" id="#DDID#_CompName_0">
	<input type="hidden" name="#DDID#_Discount_Type_0" value="" id="#DDID#_CompType_0">
	<input type="hidden" name="#DDID#_CompID_0" value="0" id="#DDID#_CompID_0">
	<input type="hidden" name="#DDID#_Allocation_0" value="0" id="#DDID#_Allocation_0">
	<input type="hidden" name="#DDID#_Payee_ID_0" value="" id="#DDID#_Payee_ID_0">
	<input type="hidden" name="#DDID#_PayeeType_0" value="" id="#DDID#_PayeeType_0">
	<input type="hidden" name="#DDID#_BB_Payee_0" value="" id="#DDID#_BB_Payee_0">
	</cfoutput>
</form>

<cfsavecontent variable="importLink">
	<!--- IMPORT & SEARCH LINKS --->
		<cfoutput>
			#BalanceInfo#
			&nbsp;&nbsp;&nbsp;
		<span style="float:right">
			<b>Total DD Amount :</b> $ <span id="TDADisplay" style="padding-right:10px;">0.00</span> <span id="TDA" style="display:none;padding-right:10px;">0.00</span>
			&nbsp;&nbsp;&nbsp;
			<a id="importDD" style="cursor:pointer">
				<b><font color="FF0000">[ </font> Import Deductions <font color="FF0000">]</font></b>
			</a>
	</span>
</cfoutput>
</cfsavecontent>

<script>

<cfif DDForge>

//HIDE REFERENCE NUMBER AND AMOUNT FIELDS
$('#RefNum').hide();
$('#TotAmt').hide();
$('#BalanceInfo').hide();
$('#VendorInfo').hide();

oTable = $('#allDeductions').DataTable( {
	  "bServerSide": true
	, "filter": true
	, "autoWidth": false
	, "paging": true
	, "pagingType": "numbers"
	, "bProcessing": true
	, "sAjaxSource": "ajax/adv_quick_pay.cfm?contractmainid=<cfoutput>#contractmainid#</cfoutput>"
	, "initComplete":  function(rows) {
						if ( ! oTable.data().count() ) {
							$('a#importDD').removeAttr('id');
						}
						$('#DD_Total_Amount').val(rows.json.TotalDDAmount)
						$('#DD_List').val(rows.json.DDList)
					   }
	, "dom": "<'importDD'>ftipr"
	, "language": {
			"lengthMenu": "Display _MENU_ records per page",
			"zeroRecords": "No programs matchs the criteria.",
			"info": "<b>Showing _START_ to _END_ of _TOTAL_ records</b>",
			"infoEmpty": "No programs matchs the criteria.",
			"infoFiltered": "",
			"sSearch": "Quick Search"
			}
	, "scrollY": Math.floor(jQuery(window).height()) - 200
	, "pageLength": 100
	, "aaSorting": [[ 1, "asc" ]]
  	, "columns": [
	                 {"orderable":false}
			,{"orderable":true}
			,{"orderable":true, "type":"currency", "sClass":"dollar"}
			,{"orderable":true, "type":"date"}
			,{"orderable":true}
			,{"orderable":true}
			,{"orderable":true}
	             ]

	} )
$('div.importDD').html(<cfoutput>'#application.util.string.compress(importLink)#'</cfoutput>);

$('.dataTables_filter input').attr('title', 'Searches against Deduction #, Reference, Customer #, Customer Name.');

oTable.on( 'draw', function () {
	var Deduction_ID = $('#Deduction_ID').val();
	$("input[name=deduction]").each(function(){
		if(	$("#DDcheckall").prop("checked")){
			this.checked=true;
		}else{
			this.checked=Deduction_ID.includes(this.id);
		}
	})
});

$(window).resize( function() {
	oTable.columns.adjust();
} );

<cfelse>
$(document).ready(function () {
	$("#Closing_Method_ID").trigger("change");
	$('#createBB').css( "display", "" );
	$('#reset').css( "display", "" );
})
</cfif>
$('#Closing_Method').val($( "#Closing_Method_ID option:selected" ).attr('data-id'));
$("#vendorSearch").click(function(){
	window.open('/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=CreateBBform&Settlements=1','vendorMaster','width=800,height=500,scrollbars=1');
})

//FUNCTION TO GET VENDOR INFORMATION
function vendorInfo(){
	var vendor = $("#Vendor").val();
	if(vendor.length >3){
		$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?method=getVendorInfo&ReturnFormat=JSON",
		data: ({
			vendorID: $("#Vendor").val()
			, AQP: 1
			}),
		dataType: 'JSON',
		success: function(response){
			//console.log(response)
			if(response.DATA.length){
				$('#Vendor').val(response.DATA[0][0]);
				$('#Vendor_Master_ID').val(response.DATA[0][1]);
				$('#Vendor_ID').val(response.DATA[0][2]);
			}else{
				$('#Vendor').val('');
				$('#Vendor_Master_ID').val('');
				$('#Vendor_ID').val('');
			}
		},
		error: function(xhr, textStatus, errorThrown){ new Noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
		});
	}
}

$( "#Closing_Method_ID" ).change(function() {
	var ClosingMethodType = $( "#Closing_Method_ID option:selected" ).attr('data-id');
	$('#Closing_Method').val(ClosingMethodType);
	$('#Deduction_ID').val('');
	$('#DD_selected_Amount').val('');
	$('#DD_Total_Amount').val('');
	if( ClosingMethodType == 'D'){
		$("#CM").css({"width": "250px", "margin-left": "0px", "padding-left": "0px"});
	<cfif DDForge>
		$('#RefNum').hide();
		$('#TotAmt').hide();
		$('#BalanceInfo').hide();
		$('#BBOtherFields').hide();
		$('#BBComponent').hide();
	//117446 :: Billback - sales tax code
	<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
		$('#TaxTypeInfo').hide();
	</cfif>
		$('#BBPayee').hide();
	<cfelse>
		$('#RefNumText').html('Deduction Number');
		$('#TotAmtText').html('Deduction Amount');
		$('#RefNum').show();
		$('#TotAmt').show();
		$('#BalanceInfo').show();
		$('#VendorInfo').show();
		$('#BBOtherFields').show();
		$('#BBComponent').show();
	//117446 :: Billback - sales tax code
	<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
		$('#TaxTypeInfo').show();
	</cfif>
		$('#BBPayee').show();
		getBBCreationInfo();
	</cfif>
		$('#allDeductions_wrapper').show();
		$('#createBB').css( "display", "none" );
		$('#reset').css( "display", "none" );
	}else{
		$('#CM').removeAttr("style");
		$('#RefNumText').html('Billback Number');
		$('#TotAmtText').html('Amount');
		$('#VendorInfo').show();
		$('#BBOtherFields').show();
		$('#allDeductions_wrapper').hide();
		$('#createBB').css( "display", "" );
		$('#reset').css( "display", "" );
		$('#RefNum').show();
		$('#TotAmt').show();
		$('#BalanceInfo').show();
		$('#BBComponent').show();
	//117446 :: Billback - sales tax code
	<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
		$('#TaxTypeInfo').show();
	</cfif>
		$('#BBPayee').show();
		getBBCreationInfo();
	}
})

$( "#BB_Component" ).change(function() {
	var ClosingMethodType = $( "#Closing_Method_ID option:selected" ).attr('data-id');
	var DDID = '00000000-0000-0000-0000-000000000000';
	if( ClosingMethodType == 'D'){
		$('#'+DDID+'_CompName_0').val('');
		$('#'+DDID+'_CompType_0').val('');
		$('#'+DDID+'_CompID_0').val('');
		$('#Deduction_ID').val('');
		$('#Prg_Comp_Len').val('');
	}else{
		var compName = $( "#BB_Component option:selected" ).attr('data-name');
		var compType = $( "#BB_Component option:selected" ).attr('data-type');
		var CompID = $( "#BB_Component option:selected" ).val();

		$('#'+DDID+'_CompName_0').val(compName);
		$('#'+DDID+'_CompType_0').val(compType);
		$('#'+DDID+'_CompID_0').val(CompID);
	}
})

$( "#BB_Payee" ).change(function() {
	var ClosingMethodType = $( "#Closing_Method_ID option:selected" ).attr('data-id');
	var DDID = '00000000-0000-0000-0000-000000000000';
	if( ClosingMethodType == 'D'){
		$('#'+DDID+'_Payee_ID_0').val('');
		$('#'+DDID+'_PayeeType_0').val('');
		$('#'+DDID+'_BB_Payee_0').val('');
		$('#Deduction_ID').val('');
		$('#Prg_Comp_Len').val('');
	}else{
		var Payee_ID = $( "#BB_Payee option:selected" ).attr('data-number');
		var PayeeType = $( "#BB_Payee option:selected" ).attr('data-id');
		var BB_Payee = $( "#BB_Payee option:selected" ).val();

		$('#'+DDID+'_Payee_ID_0').val(Payee_ID);
		$('#'+DDID+'_PayeeType_0').val(PayeeType);
		$('#'+DDID+'_BB_Payee_0').val(BB_Payee);
	}
})

function addDD(e, DDid, DDNum, Amount, Date, RefNum, DistID, DistName){

	var Deduction_ID = $('#Deduction_ID').val();
	var DD_selected_Amount = $('#DD_selected_Amount').val();
	var DD_Number = $('#DD_Number').val();
	var DD_Ref_selected = $('#DD_Ref_selected').val();
	var TotalAmount = parseFloat($('#TDA').html());
	    Amount = parseFloat(Amount);

	if( ! e.checked){
		//lockDD(0, DDid);
		$("#DDcheckall").prop("checked", false)
		Deduction_ID = Deduction_ID.replace(DDid,'');
		var DDArray = Deduction_ID.split(',');

		DDArray = DDArray.filter(item => item);
		Deduction_ID= DDArray.toString();
		$('#Deduction_ID').val(Deduction_ID);

		// DD Amount
		DD_selected_Amount = DD_selected_Amount.replace(Amount,'');
		var DDArray = DD_selected_Amount.split(',');
		DDArray = DDArray.filter(item => item);
		DD_selected_Amount= DDArray.toString();
		$('#DD_selected_Amount').val(DD_selected_Amount);

		// DED Number
		DD_Number = DD_Number.replace(DDNum,'');
		var DDArray = DD_Number.split(',');
		DDArray = DDArray.filter(item => item);
		DD_Number= DDArray.toString();
		$('#DD_Number').val(DD_Number);

		// DD Reference
		DD_Ref_selected = DD_Ref_selected.replace(RefNum,'');
		var DDArray = DD_Ref_selected.split(',');
		DDArray = DDArray.filter(item => item);
		DD_Ref_selected= DDArray.toString();
		$('#DD_Ref_selected').val(DD_Ref_selected);

		TotalAmount = TotalAmount - Amount;
		//$('#'+DDid).remove();
		$( "tr[id*="+DDid+"]" ).remove();
	}else {
		//lockDD(1, DDid);
		TotalAmount = TotalAmount + Amount;
		if(Deduction_ID.length){
			Deduction_ID = Deduction_ID.concat(','+DDid);
			$('#Deduction_ID').val(Deduction_ID);
		}else{
			$('#Deduction_ID').val(DDid);
		}
		// DD Amount
		if(DD_selected_Amount.length){
			DD_selected_Amount = DD_selected_Amount.concat(','+Amount);
			$('#DD_selected_Amount').val(DD_selected_Amount);
		}else{
			$('#DD_selected_Amount').val(Amount);
		}
		// DD Number
		if(DD_Number.length){
			DD_Number = DD_Number.concat(','+DDNum);
			$('#DD_Number').val(DD_Number);
		}else{
			$('#DD_Number').val(DDNum);
		}
		// DD Reference
		if(DD_Ref_selected.length){
			DD_Ref_selected = DD_Ref_selected.concat(','+RefNum);
			$('#DD_Ref_selected').val(DD_Ref_selected);
		}else{
			$('#DD_Ref_selected').val(RefNum);
		}
	populateCompDropdown(DDid, <cfoutput>#ContractMainID#, '#ContractNumber#'</cfoutput>, Amount, DDNum, Date, RefNum)
	}

	$('#TDA').html(TotalAmount.toFixed(2));
	$('#TDADisplay').html(TotalAmount.toLocaleString("en", {minimumFractionDigits: 2}))
}
function populateCompDropdown(DDid, CMid, ContractNumber, Amount, DDNum, Date, RefNum){
	var Compid = DDid+'_BB_Component';
	var CompLen = 0;
// getPrgComponents
	$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?method=getPrgComponents&ReturnFormat=JSON",
		data: ({	Contract_Main_ID: CMid	}),
		dataType: 'JSON',
		success: function(response){
		//console.log(response)
		if(response.DATA.length){
			var DDAmtAllocation = (Amount/response.DATA.length).toFixed(2);
			var DDAllocatedAmt = 0;
			for (var i = 0; i < response.DATA.length; i++) {
				var DDAllocation = $('#DDAllocation').val();
				if(DDAllocation.length){
					DDAllocation = DDAllocation.concat(','+DDAmtAllocation);
					$('#DDAllocation').val(DDAllocation);
				}else{
					$('#DDAllocation').val(DDAmtAllocation);
				}
				DDAllocatedAmt = DDAllocatedAmt+ parseFloat(DDAmtAllocation);
				var tdID = DDid+'_'+i;
				var CompTdID = DDid+'_Comp_'+i;
				var tr=$('<tr id='+tdID+' data-value='+Amount+'></tr>');
					$('<td><img src=/images/scissor.gif onclick=javascript:removeDD(this) id='+tdID+' ></td>').appendTo(tr);
					$('<td><a onclick=preview("'+DDid+'") style= cursor:pointer>'+DDNum+'</a> </td>').appendTo(tr);
					$('<td align=right>'+ currencyFormat(Amount,  '$ (0,0.00)') +'</td>').appendTo(tr);
					$('<td align=right><input type=textbox class=Allocation name='+DDid+'_Allocation_'+i+' id='+DDid+'_Allocation_'+i+' onKeyUp=javascript:ClenseText(this) onfocusout=decimalRestriction(this) width=50px value='+DDAmtAllocation+' ></td>').appendTo(tr);
					$('<td align=left>'+ Date +'</td>').appendTo(tr);
					$('<td align=left>'+ RefNum +'</td>').appendTo(tr);
					$('<td><input type=hidden name='+DDid+'_PayeeType_'+i+'  id='+DDid+'_PayeeType_'+i+' value=><input type=hidden name='+DDid+'_Payee_ID_'+i+'  id='+DDid+'_Payee_ID_'+i+' value=><select style=width:100% onChange=javascript:updatePayee(this,\''+DDid+'\','+i+') name='+DDid+'_BB_Payee_'+i+' class='+DDid+' id='+DDid+'_BB_Payee_'+i+'><option value=00000000-0000-0000-0000-000000000000>Select a Payee</option></select></td>').appendTo(tr);
					$('<td id='+CompTdID+'><input type=hidden name='+DDid+'_CompName_'+i+'  id='+DDid+'_CompName_'+i+' value="'+response.DATA[i][3]+'"><input type=hidden name='+DDid+'_Discount_Type_'+i+'  id='+DDid+'_CompType_'+i+' value='+ response.DATA[i][2] + '><input type=hidden name='+DDid+'_CompID_'+i+'  id='+DDid+'_CompID_'+i+' value='+ response.DATA[i][0] +'>'+ response.DATA[i][1] +'</td>').appendTo(tr);
					//117446 :: Billback - sales tax code 
					<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
					$('<td><select style=width:100% name='+DDid+'_TaxType_'+i+' class='+DDid+'_TaxType id='+DDid+'_TaxType_'+i+'><option value=0>Select a Tax Type</option></select></td>').appendTo(tr);
					</cfif>
					tr.appendTo('#groupLevelFooter');
					populateDistDropdown(DDid, ContractNumber, i);
					//117446 :: Billback - sales tax code 
				<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
					populateTaxTypedown(DDid, i);
				</cfif>
			}
			$('#Prg_Comp_Len').val(response.DATA.length);
			$('#DDAllocation').val(DDAllocation);
		}
		//MAKE SURE DD AMOUNT ALLOCATED CORRECTLY
		if(Amount - DDAllocatedAmt < 0 || Amount - DDAllocatedAmt > 0){
			var first = $('#'+DDid+'_Allocation_0').val();
						first = ( parseFloat(first) + parseFloat(Amount - DDAllocatedAmt) ).toFixed(2);
						$('#'+DDid+'_Allocation_0').val(first);
		}

		},
		error: function(xhr, textStatus, errorThrown){ noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
	});
}
//UPDATES PAYEE TYPE
function updatePayee(ths, DDid, cnt){
	var id = ths.id;
	$('#'+DDid+'_PayeeType_'+cnt).val($( "#"+id+" option:selected" ).attr('data-id'));
	$('#'+DDid+'_Payee_ID_'+cnt).val($( "#"+id+" option:selected" ).attr('data-number'));;
}
function populateDistDropdown(DDid, ContractNumber, i){
	//getPrgDistributors
	var Payeeid = DDid+'_BB_Payee_'+i;
	$.ajax( {
				type: "POST",
				url: "/components/Billback/Quick_Pay.cfc?method=getPrgDistributors&ReturnFormat=JSON",
				data: ({	ContractNumber: ContractNumber	}),
				dataType: 'JSON',
				success: function(response){
					if(response.DATA.length){
						for (var i = 0; i < response.DATA.length; i++) {
							if(response.DATA[i][3] > '0'){
							$('#'+Payeeid).append("<option value='" + response.DATA[i][3] + "' data-id='D'  data-number='" + response.DATA[i][1] + "'>" + response.DATA[i][2] + "</option>");
							}else{
							$('#'+Payeeid).append("<option  value='" + response.DATA[i][3] + "' data-id='D' data-number='" + response.DATA[i][1] + "'>" + response.DATA[i][2] + "</option>");
							}
						}
					}
				},
				error: function(xhr, textStatus, errorThrown){ noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
			});
}
function populateTaxTypedown(DDid, i){
	//getTaxTypes
	var TaxTypeid = DDid+'_TaxType_'+i;
	$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?method=getTaxTypes&ReturnFormat=JSON",
		data: ({	Deduction_ID: DDid	}),
		dataType: 'JSON',
		success: function(response){ 
			if(response.DATA.length){
				for (var i = 0; i < response.DATA.length; i++) { 
					if(response.DATA[i][2] == response.DATA[i][3]){
						$('#'+TaxTypeid).append("<option selected value='" + response.DATA[i][0] + "' data-id='D' >" + response.DATA[i][1] + "</option>");
					}else{
						$('#'+TaxTypeid).append("<option  value='" + response.DATA[i][0] + "' data-id='D' >" + response.DATA[i][1] + "</option>");
					}
				}
			}
		},
		error: function(xhr, textStatus, errorThrown){ noty({ layout:"center", type:"error", text: "Process Failed" }).show(); }
	});
}
$("#reset").click(function () {
	$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?method=DeleteRecords&ReturnFormat=JSON",
		data: ({	Unique_ID: $('#Unique_ID').val()	}),
		dataType: 'JSON',
		success: function(response){},
		error: function(xhr, textStatus, errorThrown){
			noty({ layout:"center", type:"error", text: "Process Failed" }).show();
		}
	});
	location.reload();
})

 $("#createBB").click(function () {

	 var totalDDAmount = 0;
	 var overPrgAccrual  = 0;
	 var overPrgBudget  = 0;
	 var errors = [];
	 var compLen = $('#Prg_Comp_Len').val();
	 var DDArray = $('#Deduction_ID').val().split(",");
	 var DDNumArray = $('#DD_Number').val().split(",");

	 $.noty.closeAll();

	 if( $( "#Closing_Method_ID option:selected" ).attr('data-id') != 'D' || <cfoutput>#DDForge#</cfoutput> == '0'){
		if( ! $("#Billback_Number").val().length){
			errors.push("Please Enter "+$("#RefNumText").html());
		}
		if( ! $("#Total_Amount").val().length){
			errors.push( "Please Enter Amount");
		}
		if( ! $("#Vendor").val().length){
			errors.push("Please Enter Vendor");
		}
		if( $("#BB_Payee").val() == '00000000-0000-0000-0000-000000000000'){
				errors.push("Please Select A Payee");
		}
		if( $("#BB_Component").val() == '0'){
			errors.push("Please Select A Component");
		}
		///117446 :: Billback - sales tax code 
		<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
		if( $("#Tax_Type").val() == '0'){
			errors.push("Please Select A Tax Type");
		}
		</cfif>
	}else{
		for (var i = 0; i <	DDArray.length; i++) {
			var DDAllocationAmount = 0;
			for (var j = 0; j < compLen; j++) {
				var Payee= DDArray[i]+'_BB_Payee_'+j;
				var TaxType= DDArray[i]+'_TaxType_'+j;
				var CompField= DDArray[i]+'_Comp_'+j;
			if (typeof $('#'+DDArray[i]+'_Allocation_'+j).val() !== 'undefined'){
					var trID = DDArray[i]+'_'+j;
					var DDAmount = parseFloat($( "#"+trID ).attr('data-value') );
					var AllocationAmt= $('#'+DDArray[i]+'_Allocation_'+j).val();
			}else{
				var AllocationAmt= 0;
			}
			DDAllocationAmount = DDAllocationAmount + parseFloat(AllocationAmt);
			if( $("#"+Payee+" option:selected").val() == '00000000-0000-0000-0000-000000000000'){
				errors.push("Please select payee for deduction "+DDNumArray[i]+" and component "+$('#'+CompField).text());
			}
		//117446 :: Billback - sales tax code 
		<cfif appSettings.getBillbacksSalesTax() EQ 2 AND getPrginfo.Billback_Sales_Tax>
			if( $("#"+TaxType+" option:selected").val() == '0'){
				errors.push("Please select tax type for deduction "+DDNumArray[i]+" and component "+$('#'+CompField).text());
			}	
		</cfif>
		}
			if( DDAllocationAmount < DDAmount){
				errors.push("Allocation amount for deduction "+DDNumArray[i]+" is less than deduction amount ");
			}
			if( DDAllocationAmount > DDAmount){
				errors.push("Allocation amount for deduction "+DDNumArray[i]+" is greater than deduction amount ");
			}
		}
	}

	if( ! $("#BB_Start_Date").val().length){
		errors.push("Please Enter Delivery Period Start Date.");
	}
	if( ! $("#BB_End_Date").val().length){
		errors.push("Please Enter Delivery Period End Date.");
	}
	if( ! $("#BB_Date").val().length){
		errors.push("Please Enter Billback Date");
	}
	if( ($("#BB_Start_Date").val().length && $("#BB_End_Date").val().length) && Date.parse($("#BB_Start_Date").val()) > Date.parse($("#BB_End_Date").val())){
		errors.push("Delivery Period End Date Must Be After The Delivery Period Start Date.");
	}

	var ProfileAQPMax= '<cfoutput>#Get_Profile_Settings.AQP_Max_Overspend#</cfoutput>';
	var AQPControl = <cfoutput>#variables.appSettings.get_Setting('Advance_Quick_Pay_Control') #</cfoutput>;
	var RemainingAccrual = <cfoutput>#RemainingAccrual#</cfoutput>;
	var budgetBalance = <cfoutput>#budgetBalance#</cfoutput>;
	var ProgramTradeEstimate = <cfoutput>#ProgramTradeEstimate#</cfoutput>;
	var totalDDAmount = $("#Total_Amount").val();
	var CMText = $( '#Closing_Method_ID option:selected' ).text();

	 if(totalDDAmount.length){
			/*
		WHEN variables.appSettings.get_Setting('Advance_Quick_Pay_Control') EQUAL TO "ACCURAL".
		THEN CHECK IF REMAINING ACCURAL AMOUNT ON PROGRAM IS GREATER THAN SUM OF SELECTED DEDUCTION AMOUNT.
		IF NOT ALERT USER
		*/
	// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "ACCRUAL"
		if(AQPControl == 1){
		overPrgAccrual = (totalDDAmount - RemainingAccrual);
		if( ProfileAQPMax != '*'){
			if(overPrgAccrual > ProfileAQPMax){
				errors.push("The dollar amount entered is beyond the program's remaining accrual balance.\n To proceed only enter dollar amount within program's remaining accrual balance.");
			}
		}
	}
	// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "BUDGET"
	if(AQPControl == 2){
			overPrgBudget = (totalDDAmount - budgetBalance);
		if( ProfileAQPMax != '*'){
				if(overPrgBudget > ProfileAQPMax){
					errors.push("The dollar amount entered is beyond the program's remaining budget balance.\n To proceed only enter dollar amount within program's remaining budget balance.");
				}
			}
	}
	// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "ACCRUAL & BUDGET"
	if(AQPControl ==3){
			overPrgBudget = (totalDDAmount - budgetBalance);
			overPrgAccrual = (totalDDAmount - RemainingAccrual);
		if( ProfileAQPMax != '*'){
				if(overPrgAccrual > ProfileAQPMax && overPrgBudget > ProfileAQPMax){
					errors.push("The dollar amount entered is beyond the program's remaining budget balance.\n To proceed only enter dollar amount within program's remaining budget balance.");
				}
			}
	}
	// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "PROGRAM TRADE ESTIMATE"
	if(AQPControl ==4){
		overPrgTrade = (totalDDAmount - ProgramTradeEstimate);
		if( ProfileAQPMax != '*'){
				if(overPrgTrade > ProfileAQPMax){
					errors.push("The dollar amount entered is beyond the program's trade estimate.\n To proceed only enter dollar amount within program's trade estimate.");
				}
		 }
	 }
}
	errors = errors.toString();

if(errors.length){
		/*DATE DIFFERENCE CHECK*/
		if( $("#BB_Start_Date").val().length && $("#BB_End_Date").val().length){
				var BBStartDate= $("#BB_Start_Date").datepicker("getDate");
    		var BBEndDate= $("#BB_End_Date").datepicker("getDate");
				var today      = new Date();
				var farpast    = new Date().setDate(today.getDate() - 500);
				var farfuture  = new Date().setDate(today.getDate() + 500);

				days = (BBEndDate- BBStartDate) / (1000 * 60 * 60 * 24);

				if ( days > 500 || (BBStartDate < farpast) || (BBStartDate > farfuture) ) {
					if (! confirm('Please Confirm The Billback Start And End Dates Are Accurate.\nClick OK To Continue.  Click Cancel To Update The Dates.')) {
						return false;
					}
				}
				}
				errors = errors.toString();
				errors = errors.replaceAll(',','<br>');
	noty( {  text:  errors
                ,type: 'error'
                ,buttons: [  { text:'Close Message', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } } ]
                ,layout: 'bottom' });
	return;
}else{
	noty({ layout:"center", type:"info", text: "Processing...." }).show();
 var Total_Amount = '0.00';
 if( $('#DD_selected_Amount').val().length ){
	Total_Amount = $('#DD_selected_Amount').val();
	$('#Total_Amount').val(Total_Amount);
	}

 const form = $( "form" );
	$.ajax({	type    : "post"
		, url     : "/components/Billback/Quick_Pay.cfc?method=LogTableUpdate"
		, dataType: "json"
		, data: form.serialize()
		, success : function (response) {
							$.noty.closeAll();
							if(response.BBINFO.length >= 1){
								noty({ layout:"center", type:"info",text: "Below Billback(s) Are Created Successfully <br>"+response.BBINFO }).show();
								setTimeout(function(){BBAutoApprove(response.BBUNIQUEID);},5000);
							}else{
								noty({ layout:"center", type:"info", text: response.BBCREATIONSTATUS[0] }).show();
								delayClose();
							}
						}
	,error: function(xhr, status, err) {
		noty({ layout:"center", type:"error", timeout: 1500, killer: true, text: "Billback Creation Process Failed" }).show();
	}
	});
}
});

function BBAutoApprove(uniqueID){
	$.noty.closeAll();
	$.ajax({  type    : "post"
		, url     : "/components/Billback/Quick_Pay.cfc"
		, dataType: "json"
		, data: { method: "AutoApproveQPBillbacks"
			,uniqueID: uniqueID
			}
		,success : function (response) {
			noty({ layout:"center", type:"info",text: "Auto Approve Process Success." }).show();
			}
		,error: function(xhr, status, err) {
			noty({ layout:"center", type:"error", text: "Auto Approve Process Failed" }).show();
		}
	});
	lockPRG(0);
	delayClose();
}

$('#importDD').click(function() {
	$.noty.closeAll();
	var Deduction_ID = $('#Deduction_ID').val().split(',');
				Deduction_ID = Deduction_ID.filter(Boolean);
	var totalDDAmount = $("#TDA").html();

if(Deduction_ID.length >= 1 || $("#DDcheckall").prop("checked")){
		checkProfieSettings(totalDDAmount);
	}else{
		noty({ layout:"center", type:"error", speed: 50, timeout: 250, killer: true, text: "Please Select A Deduction" }).show();
	}
});

function checkProfieSettings(totalDDAmount){

	 var errors = [];

	 var ProfileAQPMax= '<cfoutput>#Get_Profile_Settings.AQP_Max_Overspend#</cfoutput>';
	 var AQPControl = <cfoutput>#variables.appSettings.get_Setting('Advance_Quick_Pay_Control') #</cfoutput>;
	 var RemainingAccrual = <cfoutput>#RemainingAccrual#</cfoutput>;
	 var budgetBalance = <cfoutput>#budgetBalance#</cfoutput>;
	 var ProgramTradeEstimate = <cfoutput>#ProgramTradeEstimate#</cfoutput>;

	 $.noty.closeAll();
		/*
		WHEN variables.appSettings.get_Setting('Advance_Quick_Pay_Control') EQUAL TO "ACCURAL".
		THEN CHECK IF REMAINING ACCURAL AMOUNT ON PROGRAM IS GREATER THAN SUM OF SELECTED DEDUCTION AMOUNT.
		IF NOT ALERT USER
		*/
// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "ACCRUAL"
if(AQPControl == 1){
	overPrgAccrual = (totalDDAmount - RemainingAccrual);
	if( ProfileAQPMax != '*'){
		if(overPrgAccrual > ProfileAQPMax && totalDDAmount > RemainingAccrual){
			errors.push("The deduction dollar amounts selected is beyond the program remaining accrual balance.\n To proceed only select deduction dollar amounts that are within the remaining accrual balance.");
		}
	}
}
// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "BUDGET"
if(AQPControl == 2){
		overPrgBudget = (totalDDAmount - budgetBalance);
	if( ProfileAQPMax != '*'){
		if(overPrgBudget > ProfileAQPMax){
			errors.push("The deduction dollar amounts selected is beyond the program remaining budget balance.\n To proceed only select deduction dollar amounts that are within the remaining budget balance.");
		}
	}
}
// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "ACCRUAL & BUDGET"
if(AQPControl ==3){
			overPrgBudget = (totalDDAmount - budgetBalance);
			overPrgAccrual = (totalDDAmount - RemainingAccrual);
	if( ProfileAQPMax != '*'){
		if(overPrgAccrual > ProfileAQPMax && overPrgBudget > ProfileAQPMax){
			errors.push("The deduction dollar amounts selected is beyond the program remaining budget and accrual balance.\n To proceed only select deduction dollar amounts that are within the remaining budget and accrual balance.");
		}
	}
}

// ADVANCED QUICK PAY IS CONTROLLED BY IS SET TO BY :: "PROGRAM TRADE ESTIMATE"
if(AQPControl ==4){
		overPrgTrade = (totalDDAmount - ProgramTradeEstimate);
	if( ProfileAQPMax != '*'){
		if(overPrgTrade > ProfileAQPMax){
			errors.push("The deduction dollar amounts selected is beyond the program trade estimate.\n To proceed only select deduction dollar amounts that are within the program trade estimate.");
		}
	}
}

	errors = errors.toString();
	errors = errors.replaceAll('\n','<br>');

	if(errors.length){
		noty( {  text: errors
                ,type: 'error'
                ,buttons: [  { text:'Close Message', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } } ]
                ,layout: 'bottom' });
	}else{
		noty({ layout:"center", type:"info", text: "Processing...." }).show();
		getBBCreationInfo();
	}
}

function getBBCreationInfo(){
	var ClosingMethodType = $( "#Closing_Method_ID option:selected" ).attr('data-id');
	var totalDDAmount = $("#Total_Amount").val();
	if( ClosingMethodType != 'D'){
		$('#Deduction_ID').val('00000000-0000-0000-0000-000000000000');
		$('#Prg_Comp_Len').val('1');
		$('#00000000-0000-0000-0000-000000000000_Allocation_0').val(totalDDAmount);
	}else{
		<cfif ! DDForge>
			$('#Prg_Comp_Len').val('1');
		</cfif>
	}


	const form = $( "form" );
	$.ajax({  type    : "post"
		, url     : "/components/Billback/Quick_Pay.cfc?method=LogTableInsert"
		, dataType: "json"
		, data: form.serialize()
		, success : function (response) { //BELOW 3 LINES WILL SET DEFAULT PAYEE PER DEDUCTION
				for(i=0; i<response.DDID.length; i++){
					$('.'+response.DDID[i]).val(response.DISTID[i]);
					$('.'+response.DDID[i]).trigger("change");
				}
				$.noty.closeAll();
				if($( "#Closing_Method_ID option:selected" ).val() != 2){
					$('#Vendor').val(response.VENDORNAME);
					$('#Vendor_ID').val(response.VENDORID);
					$('#Vendor_Master_ID').val(response.VENDORMASTERID);
				}
				$('#Unique_ID').val(response.UNIQUEID);
			if( $( "#Closing_Method_ID option:selected" ).attr('data-id') == 'D'){
				var table = $('#allDeductions').DataTable();
				table.destroy();
				$('.datagrid').css( "display", "" );
				$('.BalanceInfo').css( "display", "" );
				$('#allDeductions').css( "display", "none" );
			}
				$('#BBOtherFields').css( "display", "" );
				$('#createBB').css( "display", "" );
				$('#reset').css( "display", "" );
				$('#links').css( "display", "none" );
			}
		,error: function(xhr, status, err) {
			noty({ layout:"center", type:"error", timeout: 1500, killer: true, text: "Import Process Failed" }).show();
		}
	});
}

function removeDD(e){
	var Amt = $(e).data("value");
	var DD_Amt = $('#TotalAmount').val() - parseFloat(Amt);
	$('#TotalAmount').val(DD_Amt.toFixed(2));
	var Deduction_ID = $('#Deduction_ID').val();
	var NewDD = Deduction_ID.replace(e.id, "");
	var NewDDArray = NewDD.split(',');
	var CleanNewDDArray = NewDDArray.filter(Boolean).toString();
	var CleanArrayLen = CleanNewDDArray.split(',');

	$('#Deduction_ID').val(CleanNewDDArray);
	$('#'+e.id).remove();
	lockDD(0, e.id);
	if(CleanArrayLen.length == 1){
	//	getBBCreationInfo(CleanArrayLen);
	}
	if($('#Deduction_ID').val().length == 0){
		location.reload(true)
	}
}

// JUST TO DELAY POP-UP CLOSE
function delayClose(){
	setTimeout(function(){self.close();},5000);
}

function preview(DDID){
	window.open('/deductions/inc_deduction_details.cfm?Display=Preview&Deduction_ID='+DDID,'Preview','width=700,height=600,scrollbars=1');
}
//DATE PICKER
$( "#BB_Start_Date, #BB_End_Date, #BB_Date" ).datepicker({
	dateFormat: "m/d/yy",
	changeMonth: true,
	changeYear: true,
	yearRange: "2016:2025",
	onSelect: function( selected ) {
		let dateName = jQuery(this).attr("name");
		// change date limit based on selected value (if start/end)
		if ( dateName === "BB_Start_Date" )
			jQuery("input[name=BB_End_Date]").datepicker("option", "minDate", selected);
		else if ( dateName === "BB_End_Date" )
			jQuery("input[name=BB_Start_Date]").datepicker("option", "maxDate", selected);
	}
});

 function HeaderClick(chk){
	var DD_selected_ID = [];
		$("input[name=deduction]").each(function(){
					this.checked=chk;
					DD_selected_ID.push(this.id);
		})
		if($("#DDcheckall").prop("checked")){

		$.ajax({  type    : "post"
			, url     : "ajax/adv_quick_pay.cfm?getAllDD=1&contractmainid=<cfoutput>#contractmainid#</cfoutput>"
			, dataType: "json"
			,success : function (response) {
				let popup = dhtmlx.modalbox( {
				text: "Do you really want to import "+response.aaData.length+" Deductions ?",
				title: "Confirm Reassignment",
				buttons: ["Yes", "No"],
				callback: function(res) {
					// res is 0 if they picked the first button (Yes)
					if (res == 0) {
						var TotalAmount = response.TotalDDAmount;
						$('#TDA').html(TotalAmount.toFixed(2));
						$('#TDADisplay').html(TotalAmount.toLocaleString("en"));
						$('#Deduction_ID').val(response.DDList);

						for(let i=0;i<response.aaData.length;i++){
						var tr=$('<tr id='+response.aaData[i][0]+'></tr>');
							$('<td><img src=/images/scissor.gif onclick=javascript:removeDD(this) id='+response.aaData[i][0]+' data-value='+response.aaData[i][2]+'></td>').appendTo(tr);
							$('<td>'+response.aaData[i][1]+'</td>').appendTo(tr);
							$('<td align=right>'+response.aaData[i][2]+'</td>').appendTo(tr);
							$('<td align=left>'+ response.aaData[i][3] +'</td>').appendTo(tr);
							$('<td align=left>'+ response.aaData[i][4] +'</td>').appendTo(tr);
							$('<td align=left>'+ response.aaData[i][5] +'</td>').appendTo(tr);
							$('<td align=left>'+ response.aaData[i][6] +'</td>').appendTo(tr);
							tr.appendTo('#groupLevelFooter');
						}
					}else{
						$("#groupLevelFooter").empty();
						$('input:checkbox').removeAttr('checked');
					}
						}
				});
						return false;
			}
		,error: function(xhr, status, err) {
			noty({ layout:"center", type:"error", timeout: 1500, killer: true, text: "Import Process Failed" }).show();
		}
		});
	}
 }
// LOCK & UNLOCK DEDUCTION
function lockDD(typ, DDid){
	if(typ){
		var fn = 'setDDLock';
	}else{
		var fn = 'DDUnlock';
	}
	$.ajax( {
		type: "POST",
		url: "/components/Billback/Quick_Pay.cfc?ReturnFormat=JSON&method="+fn,
		data: ({
				Lock_Status : typ
			,	Deduction_ID :  DDid
			}),
		dataType: 'JSON',
		success: function(response){
		//	console.log(response)
		},
		error: function(xhr, textStatus, errorThrown){
			noty({ layout:"center", type:"error", text: "Deduction Locking Process Failed" }).show();
		}
	});
}
// LOCK & UNLOCK PROGRAM
function lockPRG(typ){

	$.ajax( {
		async: false,
		type: "GET",
		url: "/components/Billback/Quick_Pay.cfc?ReturnFormat=JSON&method=ProgramStatus",
		data: ({
				LockType : typ
			,	Contract_Main_ID :  <cfoutput>#contractmainid#</cfoutput>
			}),
		dataType: 'JSON',
		success: function(response){
		//	console.log(response)
		},
		error: function(xhr, textStatus, errorThrown){
			noty({ layout:"center", type:"error", text: "Program Locking Process Failed" }).show();
		}
	});
}
window.addEventListener("beforeunload", function(){
	$.ajax({
		url: "/components/Billback/Quick_Pay.cfc"
					+ "?method=ProgramStatus"
					+ "&LockType=0"
					+ "&Contract_Main_ID=<cfoutput>#contractmainid#</cfoutput>"
	});
});

</script>