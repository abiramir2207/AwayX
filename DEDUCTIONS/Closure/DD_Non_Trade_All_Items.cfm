<!----
	Filename:	C:\Work\Code\base\AwayX\DEDUCTIONS\Closure\DD_Non_Trade_All_Items.cfm
	Created:	12/28/2011
 	Developer:	drachala
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		Display All items for DEDUCTION which is passed as URL variable, if not display all items for that INVOICE which is also passed as url variable
	Usage: DD NON TRADE
---->
<body onload="amount()">
<cfif NOT isDefined("Deduction_ID")>
	<cfset Deduction_ID = #url.Deduction_ID#>
</cfif>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfparam name="url.from" default="">
<cfparam name="form.sum_selected_cs" default="0">
<cfparam name="form.sum_selected_lb" default="0">
<cfparam name="form.sum_selected_dollar" default="0">

<cfinclude template="/settings/Advanced_Budget/actionFormat.cfm">
<cfinclude template="/deductions/sql_Deduction_Info.cfm">
<cfset deduction_amount = #Deduction_Info.DD_Amount#>

<div style="background: url(/Images/gradient.jpg); background-color:#A7CAF2; background-repeat : no-repeat; width:100%; height:20px; padding:5px; color: White; font-weight: bold; font-size: 16px;">
		<cfif isdefined("url.Invoice_ID")>Invoice - </cfif>All Items
</div>
<cfoutput>


 <cfinclude template="/common_files/jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
<cfif url.from EQ "pop-up">
<script type="text/javascript" src="/script/javascript/FixedHeader.min.js"></script>
</cfif>
<cfset ItemsInfo = CreateObject("component", "components.deduction.nontrade") />


<cfset NonTradeInfo = ItemsInfo.NonTradeItemInfo(deduction_id = #trim(Deduction_ID)#)>
<cfset total_amount_entered = 0>
<cfset total_remaining_amount = 0>
<cfloop query="NonTradeInfo" >
	<cfset total_amount_entered = total_amount_entered + dollar>
</cfloop>
<cfset total_remaining_amount = Deduction_Info.DD_Amount - #total_amount_entered#>

<cfif isdefined("url.Invoice_ID")>

<cfset InvoiceInfo = ItemsInfo.invoicedetails(#url.Invoice_ID#)>
<cfset Invoice_amount = ItemsInfo.InvoicesItems(#url.Invoice_ID#)>
<cfset total_Invoice_amount= 0>
<cfloop query="Invoice_amount" >
	<cfif len(Invoice_amount.sales_dollar)>
		<cfset total_Invoice_amount= total_Invoice_amount + Invoice_amount.sales_dollar>
	</cfif>
</cfloop>

</cfif>


<table width="100%" border="0">

<tr>
	<td valign="top"><b>#Deduction_Info.DD_DedID_SP_Number#</b></td>
	<td valign="top" align="center">
				<CFIF Deduction_Info.ShipToName NEQ "">
						<b>#Deduction_Info.ShipToName# (#Deduction_Info.Shr_Ship_To#)</b>
				<CFELSE>
						<b>#Deduction_Info.Name# (#Deduction_Info.Shr_Bill_To#)</b>
				</CFIF>
	</td>
	<td rowspan=2 valign="top">
				<table style="font-weight: bold; font-size:20px;" width="100%" border="0">
						<tr>
							<td align="right">Total Deduction Amount:</td>
							<td>#LSCurrencyFormat(Deduction_Info.DD_Amount)#</td>
						</tr>
						<tr>
							<td align="right">Amount Entered :</td>
							<td class="ae">#LSCurrencyFormat(total_amount_entered)#</td>
						</tr>
						<tr>
							<td align="right">Amount Remaining:</td>
							<td class="ar">#LSCurrencyFormat(total_remaining_amount)#</td>
						</tr>
				</table>
	</td>
</tr>
<cfif isdefined("url.Invoice_ID")>
<tr>
	<td>
			<table width="98%">
				<tr>
					<td><b>Distributor:</b></td>
					<td>&nbsp;#InvoiceInfo.name#</td>
				</tr>
				<tr>
					<td><b>Invoice##:</b></td>
					<td>&nbsp;#InvoiceInfo.Shared_Invoice_Number#</td>
				</tr>
				<tr>
					<td><b>Invoice Date:</b></td>
					<td>&nbsp;#DateFormat(InvoiceInfo.Invoice_Date, "yyyy-mm-dd")#</td>
				</tr>
				<tr>
					<td><b>Customer Purchase Order Number:</b></td>
					<td>&nbsp;#InvoiceInfo.Purchase_Order#</td>
				</tr>
				<tr>
					<td><b>Reason Code:</b></td>
					<td>&nbsp;#InvoiceInfo.Reason_Code#</td>
				</tr>
			</table>
	</td>
	<td>
			<table width="98%">
				<tr>
					<td><b>Order Date:</b></td>
					<td>&nbsp;#DateFormat(InvoiceInfo.Order_Date, "yyyy-mm-dd")#</td>
				</tr>
				<tr>
					<td><b>Invoice Date:</b></td>
					<td>&nbsp;#DateFormat(InvoiceInfo.Invoice_Date, "yyyy-mm-dd")#</td>
				</tr>
				<tr>
					<td><b>Ship Date:</b></td>
					<td>&nbsp;#DateFormat(InvoiceInfo.Ship_Date, "yyyy-mm-dd")#</td>
				</tr>
				<tr>
					<td><b>Delivery Date:</b></td>
					<td>&nbsp;#DateFormat(InvoiceInfo.Delivery_Date, "yyyy-mm-dd")#</td>
				</tr>
				<tr>
					<td><b>Net Invoice:</b></td>
					<td>&nbsp; $ #total_Invoice_amount#</td>
				</tr>
			</table>
	</td>
</tr>
</cfif>
</table>

	<div style="width: 100%; float: right; text-align:right;">
			<a href="DD_Non_Trade_Invoice.cfm?profile_id=#profile_id#&Deduction_ID=#Deduction_ID#&from=#url.from#">#ActionText("Search by Invoice")#</a>
			&nbsp;&nbsp;
			<cfif url.from EQ "pop-up">
      		<a href="/deductions/update_status.cfm?Deduction_ID=#Deduction_ID#"> #ActionText("Back")# </a>
			</cfif>
	</div>
</cfoutput>


<cfif isdefined("form.submit")>

	<cfset RFA_Deduction = 0>
	<cfset Deduction_ID= #url.Deduction_ID#/>

	<cfset Deduction_Info.DD_Amount = #deduction_amount#/>

	<cfset url.profile_id = #url.profile_id#/>
	<cfset url.from = #url.from#/>
	<cfinclude template="dd_non_trade_save.cfm"/>
	<cfif RFA_Deduction>
				<script>
					setTimeout('self.close();',2000);
				</script>
	</cfif>
</cfif>

<style>
	.button{
		border: none;
		background-color: white;
		font-weight: bold;
		color: blue;
		width:105px;
		cursor:pointer;
		}
	 .bracket{
	 	font-weight: bold;
		color: red;
	 }
	.button2{
		border: none;
		background-color: white;
		font-weight: bold;
		color: blue;
		width:50px;
		cursor:pointer;
		}
	 }
</style>
<cfset ItemsInfo = CreateObject("component", "components.deduction.nontrade") />
<cfset NonTradeItems = ItemsInfo.ItemsForNonTrade(#Deduction_ID#)>
<cfif isdefined("url.Invoice_ID")>
	<cfset NonTradeItems = ItemsInfo.InvoicesItems(#url.Invoice_ID#)>
</cfif>

<cfsavecontent variable="vars.htmlHead">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
.action { font-weight:bold; margin:0 3px 0 3px; }
</style>
</cfsavecontent>
<cfhtmlhead text="#vars.htmlHead#">

<cfscript>
  vars = StructNew();
</cfscript>


	<cfset useLakebaseForAutoCloseReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_auto_close")>
<cfif useLakebaseForAutoCloseReason>
<cftry>
<cfset AutoCloseReason = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_auto_close", {
"select" = "dd_reason_code_id"
}),
"dd_reason_code_id"
)>
<cfcatch type="any">
<cfset useLakebaseForAutoCloseReason = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForAutoCloseReason><cfquery name="AutoCloseReason" datasource="#application.datasource#">
		SELECT DD_Reason_Code_ID
		FROM DD_Auto_Close
	</cfquery>
</cfif>

	<cfset useLakebaseForGetReasonCodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reason_code")>
<cfif useLakebaseForGetReasonCodes>
<cftry>
<cfset grcParams = { "deleted" = "eq.0", "display_in" = "in.(1,3)", "order" = "dd_reason_code_description.asc" }>
<cfif AutoCloseReason.RecordCount GT 0 AND AutoCloseReason.DD_Reason_Code_ID NEQ "">
<cfset grcParams["dd_reason_code_id"] = "neq.#AutoCloseReason.DD_Reason_Code_ID#">
</cfif>
<cfif appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
<cfif len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type IS 1>
<cfset grcParams["closing_method"] = "eq.1">
<cfelseif len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type EQ 5>
<cfset grcParams["closing_method"] = "eq.2">
<cfelseif Deduction_Info.Is_Last_Status_Rebill>
<cfset grcParams["closing_method"] = "eq.4">
<cfelseif Deduction_Info.Is_Write_Off>
<cfset grcParams["closing_method"] = "eq.3">
<cfelseif Deduction_Info.DD_Rejected>
<cfset grcParams["closing_method"] = "eq.5">
</cfif>
</cfif>
<cfset GetReasonCodes = application.oLakebase.toQuery(
application.oLakebase.selectRows("dd_reason_code", grcParams)
)>
<cfcatch type="any">
<cfset useLakebaseForGetReasonCodes = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForGetReasonCodes><cfquery name="GetReasonCodes" datasource="#application.datasource#">
			SELECT * FROM DD_Reason_Code
			WHERE Deleted = 0 AND Display_In IN (1,3)
			<CFIF AutoCloseReason.RecordCount GT 0 AND AutoCloseReason.DD_Reason_Code_ID NEQ "">
			AND DD_Reason_Code_ID != #AutoCloseReason.DD_Reason_Code_ID#
			</CFIF>
			<CFIF appSettings.getRestrict_DD_Reason_Code_By_Closing_method()>
			<CFIF len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type IS 1>
			AND Closing_Method = 1
			<CFELSEIF len(trim(Deduction_Info.DD_Closure_ID)) GT 0 AND Deduction_Info.DD_Closure_Type EQ 5>
			AND Closing_Method = 2
			<CFELSEIF Deduction_Info.Is_Last_Status_Rebill>
			AND Closing_Method = 4
			<CFELSEIF Deduction_Info.Is_Write_Off>
			AND Closing_Method = 3
			<CFELSEIF Deduction_Info.DD_Rejected>
			AND Closing_Method = 5
			</CFIF>
			</CFIF>
			ORDER BY DD_Reason_Code_Description
	</cfquery>
</cfif>



<cfoutput>
<form name="allitems" action="dd_non_trade_all_items.cfm?profile_id=#profile_id#&deduction_amount=#Deduction_Info.DD_Amount#&Deduction_ID=#Deduction_ID#&from=#url.from#<cfif isdefined("url.Invoice_ID")>&Invoice_ID=#url.Invoice_ID#</cfif>" method="post">
</cfoutput>
<span class="bracket">[</span> <input type="submit" name="submit" value="Save and Continue" class="button"><span class="bracket">]</span> <br><br>
<cfset total_sales_dollar = 0>
		<cfset i = 0>
<table id="NonTrade" class="datagrid" border="0" width="100%">
	<thead>
					<tr>
	    				<th>Item&nbsp;&nbsp;&nbsp;</th>
						<th>Description</th>
	    				<th>Volume</th>
	    				<th>Sales <br>Dollars</th>
	    				<th>Average <br>Case Rate</th>
						<th>Cases</th>
						<th>Dollars</th>
						<th>
							<div style="float:left">Reason<br>Code</div>
							<div style="float:right">
								<div style="width:49%;float:left;text-align:right;"><input type="checkbox" name="selectall" value="all"></div>
								<div style="width:49%;float:right;text-align:left;">All<br>Same</div>
							</div>
						</th>
					</tr>
	</thead>
	<tbody>
		<cfsetting enablecfoutputonly=true>
		<cfloop query="NonTradeItems">

			<cfset NonTradeInfo = ItemsInfo.NonTradeItemInfo(deduction_id = #trim(Deduction_ID)#, bsa_id = #trim(BSA_Foodservice_Items_Master_ID)#)>
			<cfset form.sum_selected_cs = form.sum_selected_cs + cases_invoiced />
			<cfset form.sum_selected_lb = form.sum_selected_lb + Pounds_invoiced />
			<cfset form.sum_selected_dollar = form.sum_selected_dollar + sales_dollar />

			<cfif len(NonTradeItems.sales_dollar) EQ 0><cfset NonTradeItems.sales_dollar = 0></cfif>
			<cfset i = i+1>
					<cfoutput><tr></cfoutput>
						<cfoutput><td style="width:50px">#item#</td></cfoutput>
					 	<cfoutput><td style="width:200px">#Description#</td></cfoutput>
					 	<cfoutput><td style="width:60px">#cases_invoiced#</td></cfoutput>
					 	<cfoutput><td style="width:60px">#LSCurrencyFormat(NonTradeItems.sales_dollar)#</td></cfoutput>
						<cfif cases_invoiced EQ 0>
							<cfset Average_Case_Rate = #NonTradeItems.sales_dollar#>
						<cfelse>
							<cfset Average_Case_Rate = #NonTradeItems.sales_dollar#/#cases_invoiced#>
						</cfif>
					 	<cfoutput><td style="width:75px">#LSCurrencyFormat(Average_Case_Rate)#</td></cfoutput>
						<cfset items = #Replace(item, "-", "", 'all')#>
						<cfoutput><td style="width:60px"><input type="text" class="case" name="cases_#items#" cs_val="#trim(cases_invoiced)#" lb_val="#trim(Pounds_invoiced)#" value="<cfif len(NonTradeInfo.Volume)>#Round(NonTradeInfo.Volume)#<cfelseif isdefined("form.cases_#items#")>#evaluate( 'form.cases_#items#' )#</cfif>" size=5> </td></cfoutput>

						<cfoutput><td style="width:60px"><input  class="dollars" type="text" name="dollars_#items#" dollar_val="#trim(sales_dollar)#" cs_val="#trim(cases_invoiced)#" lb_val="#trim(Pounds_invoiced)#" value="<cfif len(NonTradeInfo.Dollar)>#NonTradeInfo.Dollar#<cfelseif isdefined("form.dollars_#items#")>#evaluate( 'form.dollars_#items#' )#</cfif>" size=5 onkeyup="amount()"></cfoutput>
							<cfoutput><input type="hidden" name="Avg_Case_Rate_#items#" value="#trim(Average_Case_Rate)#"></cfoutput>
							<cfoutput><input type="hidden" name="items" value="#items#"></cfoutput>
							<cfoutput><input type="hidden" name="BSA_Item_Master_ID_#items#" value="#BSA_Foodservice_Items_Master_ID#"></cfoutput>
							<cfoutput><input type="hidden" class="volume_cs" name="volume_cs_#items#" value="#trim(cases_invoiced)#"></cfoutput>
							<cfoutput><input type="hidden" class="volume_lb" name="volume_lb_#items#" value="#trim(Pounds_invoiced)#"></cfoutput>
							<cfoutput><input type="hidden" class="sales_dollar" name="sales_dollar_#items#" value="#trim(sales_dollar)#"></cfoutput>
		<cfif isdefined("url.Invoice_ID")>
			<cfif len(NonTradeItems.sales_dollar) EQ 0><cfset NonTradeItems.sales_dollar = 0></cfif>
			<cfset total_sales_dollar = total_sales_dollar + NonTradeItems.sales_dollar>
		</cfif>

						<cfoutput></td></cfoutput>
						<cfoutput><td style="width:300px"></cfoutput>

			<cfoutput><select name="ReasonCode_#items#" style="width:100%;font-size:10px;"></cfoutput>
				<CFIF GetReasonCodes.RecordCount GT 1>
					<cfoutput><OPTION VALUE="0">Select Reason Code</OPTION></cfoutput>
				</CFIF>
				<cfloop query="GetReasonCodes">
					<cfoutput><OPTION VALUE="#DD_Reason_Code_ID#" <cfif (len(NonTradeInfo.Reason_Code_Id) AND (NonTradeInfo.Reason_Code_Id EQ DD_Reason_Code_ID)) OR (Is_Default) OR (isdefined("ReasonCode_#items#") AND (#evaluate( 'ReasonCode_#items#' )# EQ  DD_Reason_Code_ID))>SELECTED</cfif>>#trim(DD_Reason_Code_Description)#</OPTION></cfoutput>
				</cfloop>
			<cfoutput></select></cfoutput>

						<cfoutput></td></cfoutput>
					<cfoutput></tr></cfoutput>

		</cfloop>
		<cfsetting enablecfoutputonly=false>
	</tbody>
</table>

<cfoutput>
<input type="hidden" name="item_count" value=#i#>
<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
<input type="hidden" name="Invoice_amount" value="#total_sales_dollar#">
<input type="hidden" name="new_amount" value="">
<input type="hidden" name="sum_selected_cs" value="#form.sum_selected_cs#" class="sum_selected_cs_1">
<input type="hidden" name="sum_selected_lb" value="#form.sum_selected_lb#" class="sum_selected_lb_1">
<input type="hidden" name="sum_selected_dollar" value="#form.sum_selected_dollar#" class="sum_selected_dollar_1">

<script>
	function amount(){
        var sum = 0;
		$('.dollars').each(function() { sum = sum + +($(this).val()); } );
		var new_amount = sum;

	    var update_amount =  $.DollarFormat(#Deduction_Info.DD_Amount# - new_amount);
		$(".ar").text( update_amount );
		var enter_amount = $.DollarFormat (new_amount);
		$(".ae").text( enter_amount );
	}

	$("select").change(function () {
		var n = $("input:checked").length;
		if(n == 1){
			var id=$(this).val();
			$('select[name*="ReasonCode"] option[value='+id+']').attr("selected", true);
			}
		})

	function sumSelected(){
        var sumCS = 0;
		var sumLB = 0;
		var sumDollar = 0;
		$('.volume_cs').each(function() { sumCS = sumCS + + $(this).val(); } );
		$('.volume_lb').each(function() { sumLB = sumLB + + $(this).val(); } );
		$('.sales_dollar').each(function() { sumDollar = sumDollar + + $(this).val(); } );
		$('.sum_selected_cs_1').val(sumCS);
		$('.sum_selected_lb_1').val(sumLB);
		$('.sum_selected_dollar_1').val(sumDollar);

	}
</script>
</cfoutput>
<span class="bracket">[</span> <input type="submit" name="submit" value="Save and Continue" class="button"><span class="bracket">]</span>
</form>



<script type="text/javascript" src="/Script/javascript/jquery.dataTables.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
	var grid = $('#NonTrade').dataTable({
			"bAutoWidth": false
			,"bPaginate": false<!--- D30009:More issues found  non-trade deduction feature REMOVED PAGGING TO FIX ISSUE2--->
			,"bSortClasses": false
			,"bScrollCollapse": true
			,"sDom": 'f<"batched">ti'
			,"sScrollXInner": "100%"
			,"sScrollY": "300px"
			,"aaSorting": [[ 0, "asc" ]]
			,"aoColumns": [   {/*"sWidth": ""*/}
							, {/*"sWidth": ""*/}
              , {/*"sWidth": "", */"sType": "numeric"}
							, {/*"sWidth": "",*/ "sType": "currency"}
              , {/*"sWidth": "",*/ "sType": "currency"}
							, {/*"sWidth": "",*/ "bSortable":false, "bSearchable":false}
							, {/*"sWidth": "",*/ "bSortable":false, "bSearchable":false}
							, {/*"sWidth": "",*/ "bSortable":false, "bSearchable":false}
						]
			,"fnDrawCallback": function() { sumSelected();}
}).fnSetFilteringDelay();

$('div.batched').html(' <span>Amount:</span> <input type="text" id="amount345" size="5" /> <span>UOM:</span> <select id="uom789"><option value="cs">CS</option><option value="lb">LB</option><option value="dollar">$</option><option value="percent">%</option></select> <span class="bracket">[</span> <input type="button" id="allocate1111" value="allocate" class="button2" /><span class="bracket">]</span>');
/*if table width is small expand it so reason code options would be fully displayed*/
if ($('#NonTrade').width() < 900) {
	$('#NonTrade').css('width', '900px');
}

<!--- adjust the grid when window is resized --->
$(window).resize(function(){
  grid.fnAdjustColumnSizing();
});

$('table#NonTrade tr').hover (
	function() { $(this).addClass("over"); },
	function() { $(this).removeClass("over"); }
);

$('#allocate1111').click(function(){
	var amount = $('#amount345').val();
	var uom = $('#uom789').val();
	var sumVolCS = $('.sum_selected_cs_1').val();
	var sumVolLB = $('.sum_selected_lb_1').val();
	var sumVolDollar = $('.sum_selected_dollar_1').val();
	var sum = 0;
	switch(uom)
	{
		case 'cs':
			$('.case').each(function() { var csVal = $(this).attr("cs_val"); $(this).val(csVal); } );
			$('.dollars').each(function() { var csVal = $(this).attr("cs_val");
				var eachCSAmnt = (csVal / sumVolCS) * <cfoutput>#Deduction_Info.DD_Amount#</cfoutput>; $(this).val(eachCSAmnt.toFixed(4)); sum = sum + eachCSAmnt; } );
			break;
		case 'lb':
			//$('.case').each(function() {  var lbVal = $(this).attr("lb_val"); $(this).val(lbVal); } );
			$('.case').each(function() { var csVal = $(this).attr("cs_val"); $(this).val(csVal); } );
			$('.dollars').each(function() { var eachLBAmnt = ($(this).attr("lb_val") / sumVolLB) * <cfoutput>#Deduction_Info.DD_Amount#</cfoutput>; $(this).val(eachLBAmnt.toFixed(4)); sum = sum + eachLBAmnt; } );
			break;
		case 'dollar':
			$('.case').each(function() { var csVal = $(this).attr("cs_val"); $(this).val(csVal); } );
			$('.dollars').each(function() { var eachDollarAmnt = ($(this).attr("dollar_val") / sumVolDollar) * <cfoutput>#Deduction_Info.DD_Amount#</cfoutput>; $(this).val(eachDollarAmnt.toFixed(4)); sum = sum + eachDollarAmnt; } );
			break;
		case 'percent':
			$('.case').each(function() { var csVal = $(this).attr("cs_val"); $(this).val(csVal); } );
			$('.dollars').each(function() { var eachDollarAmntByPercent = ($(this).attr("dollar_val") * (amount / 100)); $(this).val(eachDollarAmntByPercent.toFixed(4)); sum = sum + eachDollarAmntByPercent; } );
			break;
	}

	var new_amount = sum;
	var update_amount =  $.DollarFormat(<cfoutput>#Deduction_Info.DD_Amount#</cfoutput> - new_amount);
	$(".ar").text( update_amount );
	var enter_amount = $.DollarFormat (new_amount);
	$(".ae").text( enter_amount );

});
</script>

</body>