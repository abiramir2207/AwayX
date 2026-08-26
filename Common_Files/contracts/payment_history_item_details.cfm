<cfparam name="form.plannerID" default="0">
<!DOCTYPE HTML>
<html>
<head>
	<title>Payment History Item Details</title>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		div#commands a { margin:5px;}
		div#commands div { margin:5px;}
		table.datagrid { table-layout: fixed; width: 100%; }
		thead th { text-align:left !important; }
		.dollar { text-align: right; }
		.center{text-align:center !important;}
		.right{text-align:right !important;}
		div#header { margin:3px 1%; width:98%; border-bottom:1px solid #B4886B;
			<cfif val(plannerId) eq 0>
			background-color: #FFE083;
			<cfelse>
			background-color: #C4DCF1;
			</cfif>
		}
		.both { clear:both; }
		div#header label { width: 90px; font-weight: bold; }
		div#lefthdr, div#middlehdr, div#righthdr { line-height:16px; padding:7px; }
		div#lefthdr { width:50%; }
		<cfif not val(plannerID)>
			div#middlehdr { width:25%; position:absolute; left:50%; top:10px; }
			div#righthdr { width:25%; position:absolute; left:75%; top:10px; }
		<cfelse>
			div#middlehdr { width:50%;}
			div#righthdr { width:50%; position:absolute; left:50%; top:10px; }
		</cfif>
		div#content { margin:1%; width:98%; }
		body { overflow: hidden; }
		div.export {float:right;}
		<cfif val(plannerId) neq 0>
		table.dataTable thead th{background-color: #9BC2E6;}
		</cfif>
	</style>
</head>
<body>
<CFPARAM NAME="FORM.FinalPaymentList" 	DEFAULT="">
<CFPARAM NAME="FORM.check_billback" 	DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedpayments" 	DEFAULT="">
<CFPARAM NAME="url.issingleselection" 	DEFAULT="0">
<cfparam name="url.paymentId" default="">
<cfparam name="url.distributor_id" default="">
<cfparam name="FinalPaymentListtocheck" default="">
<cfparam name="distributoridlist" default="">
<cfparam name="form.formsubmit" 	DEFAULT="0">
<cfparam name="form.FinalPaymentListtocheck" DEFAULT="0">
<cfparam name="form.distributoridlist" DEFAULT="0">
<cfparam name="URL.PRINT" default="0">
<cfparam name="form.generatexlsreport" default="0">
<cfparam name="form.Allpaymentsselected" default="0">
<cfparam name="form.payee_type" default="0">
<cfparam name="form.contractId" default="0">


<cfparam name="form.billbackList" default="">

<cfscript>
	variables.nbsp = '&nbsp;';
</cfscript>

<!---<CFSET fore_Color="FFE083">--->

<CFSET Form.FinalPaymentList = form.billbackList>

<cfif listlen(Form.FinalPaymentList) EQ 0>

	<div id="tableContainer" class="tableContainer" align="center">
		<table border="0" CELLSPACING="0" align="center" width="800"  class="nopaymentsfounds">
			<TR><TD><b>Please make a valid selection.</b></TD></TR>
		</table>
	</div>

<!---<cfif listlen(FinalPaymentListtocheck) EQ 0 or listlen(distributoridlist) EQ 0>--->
	<!---<div id="tableContainer" class="tableContainer" align="center">
		<table border="0" CELLSPACING="0" align="center" width="800"  class="nopaymentsfounds">
			<TR><TD><b>Please make a valid selection.</b></TD></TR>
		</table>
	</div>--->
<cfelse>
	<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
	<cfset getcontractInfo = PaymentHistoryManager.getcontractInfo(form.ContractId)>
	<cfset getdateInfo = PaymentHistoryManager.getdateInfo(getcontractInfo.contract_number,form.ContractId)><!--- D32973:Dates on Payment History --->

	<cfset getpaymentitemleveldetails = PaymentHistoryManager.getpaymentitemleveldetails(paymentIds=Form.FinalPaymentList,contract_number=getcontractInfo.contract_number,contractMainID=Form.contractId,plannerID=plannerID)>

	<!---<CFPARAM NAME="frompage" DEFAULT="1">--->

	<cfoutput>
		<div id="header">
			<cfif not val(plannerID)>
			<div id="lefthdr">
					<b>#getcontractInfo.Contract_Number#</b> - &nbsp; #left(getcontractInfo.Contract_Title,75)#<br>
					<cfif len(getcontractInfo.contract_reference_number)>
						<b>Reference Number:</b> &nbsp; #getcontractInfo.contract_reference_number#<br>
					</cfif>
					<b>Status:</b> &nbsp; #getcontractInfo.contract_status_type_desc#<br>
					<!--- D32973:Dates on Payment History --->
					<b>Contract Start Date:</b> &nbsp; #Dateformat(getdateInfo.start_date,"mm/dd/yyyy")# &nbsp; <b>Contract End Date:</b> &nbsp; #Dateformat(getdateInfo.end_date,"mm/dd/yyyy")# <br>
					<b>Template Type:</b> &nbsp; #getcontractInfo.created_type#
			</div>  <!--- id="lefthdr" --->
			</cfif>

			<cfsilent>
				<cfset validcount = 0>
				<cfif getpaymentitemleveldetails.recordcount GT 0>
					<cfset validcount = 1>
					<cfquery name="qgetpaymentitemsummarydetails" dbtype="query">
						select SUM(rate) as total_rate,SUM(volume_lb) as total_vol_lb,SUM(volume_CS) as total_vol_cs
						from getpaymentitemleveldetails
					</cfquery>
					<cfif qgetpaymentitemsummarydetails.total_vol_lb NEQ 0 and qgetpaymentitemsummarydetails.total_vol_lb NEQ "">
						<cfset avg_total_rate_lb = qgetpaymentitemsummarydetails.total_rate/qgetpaymentitemsummarydetails.total_vol_lb>
					<cfelse>
						<cfset avg_total_rate_lb = 0>
					</cfif>
					<cfif qgetpaymentitemsummarydetails.total_vol_cs NEQ 0 and qgetpaymentitemsummarydetails.total_vol_cs NEQ "">
						<cfset avg_total_rate_cs = qgetpaymentitemsummarydetails.total_rate/qgetpaymentitemsummarydetails.total_vol_cs>
					<cfelse>
						<cfset avg_total_rate_cs = 0>
					</cfif>
				</cfif>
			</cfsilent>
			<div id="middlehdr">
				<label>Total Products:</label> &nbsp; <cfif validcount EQ 1> #numberformat(getpaymentitemleveldetails.recordcount,'_,___,___,___,___')#<cfelse>&nbsp;</cfif><br>
				<label>Total #Application.UOMPoundPlural#:</label> &nbsp; <cfif validcount EQ 1> #numberformat(qgetpaymentitemsummarydetails.total_vol_lb,'_,___,___,___,___')# #Application.UOMPoundAbrPlural# <cfelse> &nbsp; </cfif><br>
				<label>Total #Application.UOMCasePlural#:</label> &nbsp; <cfif validcount EQ 1>#numberformat(qgetpaymentitemsummarydetails.total_vol_cs,'_,___,___,___,___')# #Application.UOMCaseAbrSingular#<cfelse>&nbsp;</cfif>
			</div> <!--- id="middlehdr" --->
			<div id="righthdr">
				<label>Total Dollars:</label> &nbsp; <cfif validcount EQ 1>#dollarformat(qgetpaymentitemsummarydetails.total_rate)#<cfelse>&nbsp;</cfif><br>
				<label>Avg Rate/#Application.UOMPoundAbrSingular#:</label> &nbsp; <cfif validcount EQ 1>#numberformat(avg_total_rate_lb,'$(_,.____')#/#Application.UOMPoundAbrSingular#<cfelse>&nbsp;</cfif><br>
				<label>Avg Rate/#Application.UOMCaseAbrSingular#:</label> &nbsp; <cfif validcount EQ 1>#numberformat(avg_total_rate_cs,'$_,.__')#/#Application.UOMCaseAbrSingular#<cfelse>&nbsp;</cfif>
			</div>   <!--- id="righthdr" --->
		</div>  <!--- id="header" --->
		<div class="both"></div>

		<div id="content">
			<!--- data table grid --->
			<cfset variables.columnSizes = [2.5,    <!--- item --->
											3.5,    <!--- description --->
											2,      <!--- total dollars --->
											1.5,    <!--- % of total dollars --->
											2,      <!--- total pounds --->
											1.5,    <!--- % of total pounds --->
											2,      <!--- total cases --->
											1.5     <!--- % of total cases --->
											]>
			<!--- <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )> --->

			<table id="datagrid" class="datagrid">
				<col width="15%">
				<col width="25%">
				<col width="11%">
				<col width="9%">
				<col width="11%">
				<col width="9%">
				<col width="11%">
				<col width="9%">
				<cfoutput>
				<thead>
					<tr>
						<th>#application.util.string.fcase(application.returned_customer_setting.item_label)#</th>
						<th>Description</th>
						<th class="right">Dollars&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
						<th class="right">% of Dollars&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
						<th class="right">#Application.UOMPoundPlural#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
						<th class="right">% of #Application.UOMPoundPlural#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
						<th class="right">#Application.UOMCasePlural#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
						<th class="right">% of #Application.UOMCasePlural#&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
					</tr>
				</thead>
				<tfoot>
					<tr>
						<th></th>
						<th align="right"><b>Total (All pages):</b></th>
						<th id="totalDollars"></th>
						<th>&nbsp;</th>
						<th id="totalPounds"></th>
						<th>&nbsp;</th>
						<th id="totalCases"></th>
						<th>&nbsp;</th>
					</tr>
				</tfoot>
				</cfoutput>
				<tbody>
					<cfsavecontent variable="variables.tbody">
						<cfloop query="getpaymentitemleveldetails">
							<tr>
								<td>#getpaymentitemleveldetails.item#</td>
								<td>#getpaymentitemleveldetails.description#</td>
								<td class="dollars">#(getpaymentitemleveldetails.rate neq "" ? dollarFormat(getpaymentitemleveldetails.rate) : variables.nbsp)#</td>
								<td>
									<cfif (qgetpaymentitemsummarydetails.total_rate neq 0 and qgetpaymentitemsummarydetails.total_rate neq "")>
										#numberFormat(getpaymentitemleveldetails.rate / qgetpaymentitemsummarydetails.total_rate * 100, "_,")#%
									<cfelse>
										&nbsp;
									</cfif>
								</td>
								<td class="lbs">#(getpaymentitemleveldetails.volume_lb neq "" ? numberFormat(getpaymentitemleveldetails.volume_lb, "_,") : variables.nbsp)#</td>
								<td>
									<cfif (qgetpaymentitemsummarydetails.total_vol_lb neq 0 and qgetpaymentitemsummarydetails.total_vol_lb neq "")>
										#numberFormat(getpaymentitemleveldetails.volume_lb / qgetpaymentitemsummarydetails.total_vol_lb * 100, "_,")#%
									<cfelse>
										&nbsp;
									</cfif>
								</td>
								<td class="cases">#(getpaymentitemleveldetails.volume_cs neq "" ? numberFormat(getpaymentitemleveldetails.volume_cs, "_,") : variables.nbsp)#</td>
								<td>
									<cfif (qgetpaymentitemsummarydetails.total_vol_cs neq 0 and qgetpaymentitemsummarydetails.total_vol_cs neq "")>
										#numberFormat(getpaymentitemleveldetails.volume_cs / qgetpaymentitemsummarydetails.total_vol_cs * 100, "_,")#%
									<cfelse>
										&nbsp;
									</cfif>
								</td>
							</tr>
						</cfloop>
					</cfsavecontent>
					#application.util.string.compress( variables.tbody )#
				</tbody>
			</table>
		</div>   <!--- id="content" --->
	</cfoutput>
</cfif>

<!--- use below values for the csv report --->
<cfif IsDefined("qgetpaymentitemsummarydetails.total_rate")>
	<cfset total_rate = qgetpaymentitemsummarydetails.total_rate>
</cfif>
<cfif IsDefined("qgetpaymentitemsummarydetails.total_vol_lb")>
	<cfset total_vol_lb = qgetpaymentitemsummarydetails.total_vol_lb>
</cfif>
<cfif IsDefined("qgetpaymentitemsummarydetails.total_vol_cs")>
	<cfset total_vol_cs = qgetpaymentitemsummarydetails.total_vol_cs>
</cfif>

<!--- Below two variables ("height_below_grid_to_bottom_page_in_pixels" and "mydatagrid" are being used in
"jquery.dataTables-api.js" below and so we need to define it here.
--->
<script type="text/javascript">
	var height_below_grid_to_bottom_page_in_pixels = 50;
	var mydatagrid = '';
</script>

	<cfset datatables.version = "1.9.3">
	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/dataTables.cfm">
	<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/table2csv.js, /Script/javascript/numeral.min.js"/>
	<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>

	<script>
		var x_filter = 'foo';
		// adjust column headings & font size to fit small screen
		if ($(window).width() < 1400) {
			$("th, td").css("font-size", "0.85em");
		}
		var jTable = $(".datagrid");
		mydatagrid = jTable.dataTable({
						"aaSorting": [[ 2, "desc" ]]
						,"aoColumns": [	 {}    /* item */
										,{}    /* description */
										,{"bSearchable":false, "sClass":"dollar"}     /* total dollars */
										,{"bSearchable":false, "sClass":"dollar"}
										,{"bSearchable":false, "sClass":"dollar"}     /* total lbs */
										,{"bSearchable":false, "sClass":"dollar"}
										,{"bSearchable":false, "sClass":"dollar"}     /* total cases */
										,{"bSearchable":false, "sClass":"dollar"}
									]
					  ,"bAutoWidth": false            // false for quicker rendering
					  ,"bDeferRender": false          // true for quicker rendering
					  ,"bPaginate": true
					  ,"bProcessing": true            // true to show processing message in sorting large table
					  ,"bScrollCollapse": true        // true to put the footer of the grid just below the records, when there are a few records only
					  ,"bSortClasses": false
					  ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
					  ,"sDom": 'Tfp<"export">tir'
					<!--- NOTE: BY DEFAULT, THERE IS A MINIMUM SCROLLABLE HEIGHT ASSOCIATED WITH THE GRID. THAT IS BEING OVERRIDDEN AT THE BOTTOM OF THIS FILE.
					IT WAS NECESSARY SO THAT THE LINKS AT THE BOTTOM OF THIS PAGE (IF ANY) CAN SHOW UP. ALSO, WHEN THERE ARE JUST A FEW GRID RECORDS AND WE NEED TO SHOW
					THE FOOTER OF THE GRID JUST BELOW THE RECORDS, THEN WE NEED TO OVERRIDE THE MINIMUM HEIGHT AND SET ""bScrollCollapse" TO "TRUE ON THE GRID.
					--->
					,"sScrollY" : Math.floor(jQuery(window).height()) -200
					  ,"iDisplayLength": 100
					  /* calculate "total" */
					  ,"fnDrawCallback": function() {

					   /* Calculate totals:
						Note:This technique of totalling is useful when totalling needs to be done on the client-side, when there is paging involved.
						Need to use "bUnique= false". Without it, only unique values will be totalled.
					   */
					   var dollarArray = this.fnGetColumnData( iColumn=2,bUnique=false );
					   var poundsArray = this.fnGetColumnData(  iColumn=4,bUnique=false );
					   var casesArray = this.fnGetColumnData(  iColumn=6,bUnique=false );

					   var total_Dollars = totalColumn(dollarArray);
					   var total_Pounds = totalColumn(poundsArray);
					   var total_Cases = totalColumn(casesArray);

						var filter = $('#datagrid_filter input').val();

						/* Only if the data has changed, do the total. Do not do total again, otherwise. It is useful in scenarios, where the user just
						sorts data.In that case, we do not need to do total again.
						The logic looks for filter string. If the filter string (search string) is a new one, then do the total.
						*/
						if (x_filter !== filter) {
							var $tfoot = $('div.dataTables_scrollFootInner');

							$tfoot.find('th#totalDollars').text( numeral(total_Dollars).format( "($0,0.00)" ) );
							$tfoot.find('th#totalPounds').text( numeral(total_Pounds).format( "0,0" ) );
							$tfoot.find('th#totalCases').text( numeral(total_Cases).format( "0,0" ) );
						}

						x_filter = filter;
					}

			});
		// highlight current row
		$('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

		function totalColumn(arr){
			var columnTotal = 0;
			var tempTotal = 0;
			for(i=0;i<=arr.length;i++){
				if (arr[i] != undefined)
			 	{
					tempTotal = (arr[i]).replace('$','');
					tempTotal = tempTotal.replace(',','');
					// columnTotal = columnTotal + parseFloat(numeral(tempTotal).format("0,0.00"));
					columnTotal = columnTotal + parseFloat(tempTotal);
				}
			}
		return columnTotal;
		}

		/* Normally the "exportAll" function passes data through the URL, but below function passes data through the form instead of the URL,
		as the data passed to the URL may sometimes exceed the limit. */
		exportAll = function() {
			window.open('about:blank', 'formpopup', 'toolbars=no,scrollbars=no,resizable=no,left=1,top=10000,width=1,height=1');
			frmExportAll.target = 'formpopup';
			frmExportAll.submit();
		}


	/* The default scrollable height of a datagrid is probably around "300 px". We need to reduce the minimum height, so that
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_scrollBody').css('min-height', '30px');

	<cfoutput>
	$('div.export').html("<a href='javascript:exportAll();'>#application.util.string.actionLinkFormat2('export all to csv')#</a> &nbsp;");
	</cfoutput>
	</script>

	<cfoutput>
		<form name="frmExportAll" action="/Common_Files/exportAll.cfm" method="post">
			<input type="hidden" name="type" value="getpaymentitemleveldetails">
			<input type="hidden" name="contract_number" value="#getcontractInfo.contract_number#">
			<input type="hidden" name="ContractId" value="#form.ContractId#">
			<input type="hidden" name="plannerID" value="#form.plannerID#">
			<input type="hidden" name="paymentIds" value="#form.FinalPaymentList#">
			<input type="hidden" name="total_rate" value="#total_rate#">
			<input type="hidden" name="total_vol_lb" value="#total_vol_lb#">
			<input type="hidden" name="total_vol_cs" value="#total_vol_cs#">
			<input type="hidden" name="friendlyFileName" value="#urlEncodedFormat('payment_history_item_detail_#getcontractInfo.contract_number#_')#">
		</form>
	</cfoutput>
</body>
</html>
