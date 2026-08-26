<!----
 	Name: Search_Customer_Invoice.cfm
 	Copyright (c) 2016 Blacksmith Applications, Inc.
   	Description:
	This file add a new billback feature that will allow users to search for, view, and download billbacks summarized by billback number
	(i.e. customer invoice number) and billback payee.
 ---->
 <cf_layout-bare>
 	<style>
 	a.action {
 		cursor: pointer;
 		margin: 0 15px;
 	}
 	.center {
 		text-align: center !important;
 	}
 	.right {
 		text-align: right;

 	}
 	#filter {
 		display: block;
 		width: 100%;
 		margin-bottom: 10px;
 	}
 	input.input {
 		width: 150px;
 	}
 	</style>
<cf_include file_to_include="/Common_Files/datatable.css, /styles/tTip.css"/>
<cfparam name="form.Invoice_Number" 			default=""/>
<cfparam name="form.Customer_Name" 			default=""/>
<cfparam name="form.Customer_Number" 		default=""/>
<cfparam name="formsubmit" 							default="0"/>
<cfparam name="form.searchClick" 					default="0"/>
<cfparam name="form.dateFieldSign" 				default="1"/>
<cfparam name="form.Created_Date" 				default="#DateAdd("d",-367, Dateformat(now(), 'mm/dd/yyyy'))#"/>

<cfset PageTitle="Customer Invoice Search">
<cfinclude template="/settings/settings_title.cfm">

	<form name="SearchCustomerInvoice" action="Search_Customer_Invoice.cfm" method="post" id="SearchCustomerInvoice" style="margin:0;padding:0;">
 		<!--- <fieldset style="padding:8px; width: 98%; border: 1px solid Blue; display:table;">
			<legend style="font: bold 14px sans-serif; color: Red;">Search Form</legend> --->

 				<table border="0" align="left" cellpadding="2" id="filter">
					<tr style="font-weight: bold;">
						<td>Invoice Number</td>
						<td>Customer Name</td>
						<td>Customer Number</td>
						<td>
							<span onmouseout="popUpTip(event,'CreateDateFiled');" onmouseover="popUpTip(event,'CreateDateFiled');">Created Date &nbsp;&nbsp;<img src="/images/i.gif" /> </span>
    						<div id="CreateDateFiled" class="tip">
    							By default the date is set to only return records within the last 367 days in order to limit slow performance and loading.
								The user can manually change the date field to a more appropriate timeframe if needed.
    						</div>
						</td>
						<td>&nbsp;</td>
					</tr>
					<tr>
					<cfoutput>
						<td><input type="text" name="Invoice_Number" value="#form.Invoice_Number#" class="input"></td>
						<td><input type="text" name="Customer_Name" value="#form.Customer_Name#" class="input"></td>
						<td><input type="text" name="Customer_Number" value="#form.Customer_Number#" class="input"></td>
						<td>
							<select name="dateFieldSign">
								<option value="1" <cfif form.dateFieldSign EQ 1>Selected</cfif>>></option>
								<option value="2" <cfif form.dateFieldSign EQ 2>Selected</cfif>><</option>
								<option value="3" <cfif form.dateFieldSign EQ 3>Selected</cfif>>=</option>
							</select>
							<input type="text" name="Created_Date" value="#Dateformat(form.Created_Date,'mm/dd/yyyy')#" class="input date">
						</td>
						<td>
							<a class="submit action">#application.util.string.actionLinkFormat("search")#</a>
							<a class="reset action">#application.util.string.actionLinkFormat("reset")#</a>
						<cfif form.searchclick>
							<a href="javascript:getCSVData();" class="action">#LCase(application.util.string.actionLinkFormat2("export"))#</a>
						</cfif>
						</td>
					</cfoutput>
					</tr>
				</table>
 		<!--- </fieldset> --->
 		<input type="hidden" name="formsubmit" value="0" id="formsubmit"/>
		<input type="hidden" name="searchClick" value="0" id="searchclick"/>
	</form>

	<hr class="two" style="width:100%;">

<cfif formsubmit>
	<cfset urlVariable = "searchClick=#form.searchClick#&Invoice_Number=#form.Invoice_Number#&Customer_Name=#form.Customer_Name#&Customer_Number=#form.Customer_Number#&dateFieldSign=#form.dateFieldSign#&Created_Date=#form.Created_Date#">
			<!--- data table grid --->
			<cfset variables.columnSizes = [1, 1, 1, 1, 3,
											1, 1, 1, 1
          ]>
			<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>
	<table class="datagrid" id="CustomerInvoiceSearch" style='table-layout:fixed;width:100%;'>
				<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
					<cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
				</cfloop>
	  <thead>
	    <th class="header">Invoice #</th>
	    <th class="header">Delivery Start</th>
	    <th class="header">Delivery End</th>
	    <th class="header center">Total Claims</th>
		<th class="header">Customer</th>
	    <th class="header center">Claimed</th>
		<th class="header center">Expected</th>
	    <th class="header center">Paid</th>
	    <th class="header center">Deviated</th>
	  </thead>
	  <tbody>

	  </tbody>
	</table>

	<form action="/common_files/csv.cfm" method ="post" id="csv_form">
	  <input type="hidden" name="csv_text" id="csv_text">
	  <input type="hidden" name="csv_file_name" id="csv_file_name">
	</form>

	<cfinclude template="/Common_Files/dataTables.cfm">
	<cf_include file_to_include="/Script/javascript/jquery.dataTables-api.js, /script/tTip.js, /Script/javascript/table2csv.js"/>

	<script>
		oTable = $('.datagrid').dataTable( {
			  "bServerSide": true
			, "bFilter": false
			, "bSortClasses": false
			, "bAutoWidth": false
			, "paging": true
			, "pagingType": "simple"
			, "bProcessing": true
			, "sAjaxSource": "ajax/Search_Customer_Invoice_ajax.cfm?<cfoutput>#urlVariable#</cfoutput>"
			, "sScrollY": Math.floor(jQuery(window).height()) - 185
			, "sDom": "rtp"
			, "iDisplayLength": 100
			, "aaSorting": []
		    , "aoColumns": [
									{"bSortable":true}
			                    ,	{"bSortable":true}
								,	{"bSortable":true}
			                    ,	{"bSortable":true, "sClass":"right"}
			                    ,	{"bSortable":true}
			                    ,	{"bSortable":false, "sClass":"right"}
			                    ,	{"bSortable":false, "sClass":"right"}
			                    ,	{"bSortable":false, "sClass":"right"}
								,	{"bSortable":false, "sClass":"right"}
			                 ]
		} ).fnSetFilteringDelay();
	</script>

</cfif>

<cf_include file_to_include="/styles/jQueryUI_18/smoothness/jquery-ui-1.8.22.custom.css, /script/javascript/ajax_js/jqueryui-1.8.10.min.js"/>
<script>
	$(document).ready(function() {
		$( ".submit" ).click(function() {
		  $("#formsubmit").val("1");
		  $("#searchclick").val("1");
		  $( "#customContainer" ).show();
		  $("#SearchCustomerInvoice" ).submit();
		});
	    $(".reset").on("click", function(event){
	        $(".input").val("");
	    });
	});
	getCSVData = function() {
	 var csv_value = $('#CustomerInvoiceSearch').table2CSV({ sScrollY: 1 });
	 $("#csv_file_name").val("Customer_Invoice_Search_" + random367() + ".csv");
	 $("#csv_text").val(csv_value);
	 $("#csv_form").submit();
	}
	$(".date").datepicker({
	    dateFormat: "m/d/yy",
	    changeMonth: true,
	    changeYear: true,
	    numberOfMonths: 3,
	    showCurrentAtPos: 2
	});

	function listofbb(bbreference,Upload_ID){
		popupCenterByPercentages("/common_files/processing.cfm?actualPage=/billbacks/customerinvoice/billback_list.cfm&bbreference="+bbreference+"&Upload_ID="+Upload_ID, "Billback_list", 90, 70);
	}
</script>
</cf_layout-bare>
