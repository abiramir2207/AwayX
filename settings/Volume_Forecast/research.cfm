<cfset datatables.version = "1.9.1">
<cfset jQueryUI.version = "1.8.23">
<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/TableTools.min.js"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js"></script>
<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css">


<cfparam name="edit" default = 0>
<!--- This if statement is used to pull info for selected CLASS --->
<!--- <cfset qGetInvoiceMarketSegment = VFManager.getInvoiceMarketSegment() > --->

<!--- This if statement is used to DISPLAY LIST OF CLASSES with Options like EDIT and DELETE--->
<cfif (form.command EQ "research") AND (form.nextcommand EQ 0)>
	<cfoutput>
		<!--- This is css stuff and inserted into the head tag --->
		<cfsavecontent variable="vars.htmlHead">
			<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
				<style>
					.action { font-weight:bold; margin:0 3px 0 3px; }
				</style>
		</cfsavecontent>
		<cfhtmlhead text="#vars.htmlHead#">

<fieldset style="padding:10px; width: 100%; border: 1px solid blue;">
<legend style="font: bold 14px sans-serif; color: red;">Invoice Research - Segment & Market</legend> <br/>

			<table cellspacing="5" id="searchFields">
				<tr>
					<!--- Invoice --->
					<td>
						<span ID="searchItemLabel">Invoice ##:</span><BR>
						<input type="text" id="invoiceNumber" name="invoiceNumber" value="" size="20" maxlength="20">
					</td>
					<!--- Invoice Date --->
					<td>
						<span ID="searchItemLabel">Invoice Date:</span><BR>
						<select id="invoiceDateOperator"> name="invoiceDateOperator">
							<option value=">=">>=</option>
							<option value=">=">>=</option>
							<option value="=">=</option>
						</select>
						<input type="text" id="invoiceDate" name="invoiceDate" value="" size="12" maxlength="20">
					</td>

					<!--- Item --->
					<td>
						<span ID="searchItemLabel">#application.returned_customer_setting.item_label# Number:</span><BR>
						<input type="text" id="itemNumber" name="itemNumber" value="" size="20" maxlength="20">
					</td>
					<td>
						<span ID="searchItemLabel">#application.returned_customer_setting.item_label# Description:</span><BR>
						<input type="text" id="itemDesc" name="itemDesc" value="" size="20" maxlength="20">
					</td>

					<!--- ShipTo --->
					<td>
						<span ID="searchItemLabel">#application.returned_customer_setting.distributor_label_singular# Number:</span><BR>
						<input type="text" id="shipTo" name="shipTo" value="" size="20" maxlength="20">
					</td>
					<td>
						<span ID="searchItemLabel">#application.returned_customer_setting.distributor_label_singular# Name:</span><BR>
						<input type="text" id="shipToName" name="shipToName" value="" size="20" maxlength="20">
					</td>
				</tr>
				<tr>
					<!--- business segment --->
					<td>
						<span ID="searchItemLabel">#Application.oApplicationAppSettingsManager.getApplicationAppSettings().getbusiness_segment_label()# ID:</span><BR>
						<input type="text" id="segmentId" name="segmentId" value="" size="20" maxlength="20">
					</td>
					<td>
						<span ID="searchItemLabel">#Application.oApplicationAppSettingsManager.getApplicationAppSettings().getbusiness_segment_label()# Name:</span><BR>
						<input type="text" id="segmentName" name="segmentName" value="" size="20" maxlength="20">
					</td>

					<!--- market --->
					<td>
						<span ID="searchItemLabel">#application.returned_customer_setting.market_label_singular# ID:</span><BR>
						<input type="text" id="marketId" name="marketId" value="" size="20" maxlength="20">
					</td>
					<td>
						<span ID="searchItemLabel">#application.returned_customer_setting.market_label_singular# Name:</span><BR>
						<input type="text" id="marketName" name="marketName" value="" size="20" maxlength="20">
					</td>

					<!--- links --->
					<td>
						<a href="javascript: resetHandler();" style="font: bold 12px sans-serif;">#ActionText("reset")#</a>
						<a href="javascript: searchHandler();" style="font: bold 12px sans-serif;">#ActionText("search")#</a>
					</td>
					<td>
						<a href="javascript: exportExcel();" style="font: bold 12px sans-serif;">#ActionText("export to excel")#</a>
					</td>
				</tr>
			</table>

		</fieldset>


		<div id="seperator" align="center" style="display:none;" height="100" > <img src="/images/ajax-loader.gif"> </div>

		<!--- datatable place holder style="position:relative;top:-300px;"--->
		<div id="invResearchDisplay" style="padding-top: 10px;">
			<table id="invResearch" class="datagrid">
				<!---
				<thead>
					<tr>
						<th class="columnfilter addselect">Invoice Number</th>
						<th class="columnfilter addselect">Invoice Date</th>
						<th class="columnfilter addselect">#application.returned_customer_setting.item_label# Number</th>
						<th class="columnfilter addselect">#application.returned_customer_setting.item_label# Description</th>
						<th class="columnfilter addselect">#application.returned_customer_setting.distributor_label_singular# Number</th>
						<th class="columnfilter addselect">#application.returned_customer_setting.distributor_label_singular# Name</th>
						<th class="columnfilter addselect">#Application.oApplicationAppSettingsManager.getApplicationAppSettings().getbusiness_segment_label()# ID</th>
						<th class="columnfilter addselect">#Application.oApplicationAppSettingsManager.getApplicationAppSettings().getbusiness_segment_label()# Name</th>
						<th class="columnfilter addselect">#application.returned_customer_setting.market_label_singular# ID</th>
						<th class="columnfilter addselect">#application.returned_customer_setting.market_label_singular# Name</th>
					</tr>
				</thead>
				--->
				<tbody>
				</tbody>
			</table>
		</div>
	</cfoutput>

	<script type="text/javascript">

		var tableData = [];

		var tableCols = [
			/* invoice number */	{"sTitle": "Invoice #", "sClass": "columnfilter addselect"},
			/* invoice date */		{"sTitle": "Invoice Date", "sClass": "columnfilter addselect"},
			/* item number */		{"sTitle": "<cfoutput>#application.returned_customer_setting.item_label# ##</cfoutput>", "sClass": "columnfilter addselect"},
			/* item description */	{"sTitle": "<cfoutput>#application.returned_customer_setting.item_label# Description</cfoutput>", "sClass": "columnfilter addselect"},
			/* customer number */	{"sTitle": "<cfoutput>#application.returned_customer_setting.distributor_label_singular# ##</cfoutput>", "sClass": "columnfilter addselect"},
			/* customer name */		{"sTitle": "<cfoutput>#application.returned_customer_setting.distributor_label_singular# Name</cfoutput>", "sClass": "columnfilter addselect"},
			/* business segment */	{"sTitle": "<cfoutput>#Application.oApplicationAppSettingsManager.getApplicationAppSettings().getbusiness_segment_label()# ID</cfoutput>", "sClass": "columnfilter addselect"},
			/* business segment */	{"sTitle": "<cfoutput>#Application.oApplicationAppSettingsManager.getApplicationAppSettings().getbusiness_segment_label()# Name</cfoutput>", "sClass": "columnfilter addselect"},
			/* market id*/			{"sTitle": "<cfoutput>#application.returned_customer_setting.market_label_singular# ID</cfoutput>", "sClass": "columnfilter addselect"},
			/* market name*/		{"sTitle": "<cfoutput>#application.returned_customer_setting.market_label_singular# Name</cfoutput>", "sClass": "columnfilter addselect"}
			];

		// $('input').bind('focus', function(){ $(this).addClass('hilight'); }).bind('blur', function(){ $(this).removeClass('hilight'); });
		// $('form input:visible:enabled:first').focus();

		/* reset function */
		// var resetHandler = function(){$('form')[0].reset();} 											//to reset entire form and dropdowns
		var resetHandler = function(){$('#searchFields :input').each(function(){$(this).val('');});} 		//this only reset the values in the seach section

		/* search function */
		var searchHandler = function(){

			/* warn if no search fields are entered */
			var searchFieldsFilled = 0;
			$('#searchFields input').each(function() {
				if($.trim(this.value).length) { // zero-length string after trimming
					searchFieldsFilled++;
				}
			});

			if(!searchFieldsFilled){
				alert("You havent entered any search criteria!");
			}else{
				$('#seperator').css('display','block'); // Add progress bar
				$.ajax({
					url: "/components/programs/volume/volume_forecast.cfc"
					,type: "post"
					,data: {
						method: "getInvoiceMarketSegment"
						,invoiceNumber: $("#invoiceNumber").val()
						,invoiceDateOperator: $("#invoiceDateOperator").val()
						,invoiceDate: $("#invoiceDate").val()
						,itemNumber: $("#itemNumber").val()
						,itemDesc: $("#itemDesc").val()
						,shipTo: $("#shipTo").val()
						,shipToName: $("#shipToName").val()
						,segmentId: $("#segmentId").val()
						,segmentName: $("#segmentName").val()
						,marketId: $("#marketId").val()
						,marketName: $("#marketName").val()
					}
					,dataType: "json"
					,async: true
					,timeout: 60000
					,error: function(jqXHR, textStatus, errorThrown) {
						$('#seperator').css('display','none');
						alert('An unexpected problem has occurred, please change search criteria!');
					}
					,success: function(data) {
						dtRender(data.DATA);
						$( "#invResearch_wrapper" ).remove();
					}
				})
			} //else
		}

		// render datatables
		var dtRender = function(data) {
			tableData = data;
			var oTable = $('#invResearch').dataTable({
				"bAutoWidth": true,
				"bDestroy": true,
				"bDeferRender": true,
				"bFilter": true,
				"bProcessing": true,
				"bPaginate": false,
				"bSortClasses": false,
				"bScrollCollapse": true,
				"bScrollInfinite": true,
				"sScrollY": "400px",
				"sDom": 'r',
				// "sDom":'lir',
				// "sDom":'ltr',
				"aoColumns": tableCols,
				"aaData": tableData
			}).fnSetFilteringDelay();

			// .fnSetFilteringDelay();
			// filterDropDown();

			// remove progress bar
			$('#seperator').css('display','none');

			/* Add a select menu for each TH element in the table header */
			$('table#invResearch thead tr th').each( function ( i ) {
				if ( $(this).hasClass("columnfilter") ) {
					if ( $(this).hasClass("addselect") ) {
						$('select', this).remove();	// remove existing dropdown
						$('br', this).remove(); // remove existing new line
						$(this).html($(this).html() + '<br/>' + fnCreateSelect( oTable.fnGetColumnData(i) ));
					}
					$('select', this).change( function () {
						oTable.fnFilter( $(this).val(), i );
					} );
				}
			} );

			// hover CSS
			$('table#invResearch tr').hover (
			  function() { $(this).addClass("over"); },
			  function() { $(this).removeClass("over"); }
			);
		}

		// export to csv
		var exportExcel = function() {
			var csv_value=$('#invResearch').table2CSV();
			$("#csv_text").val(csv_value);
			$("#csv_form").submit();
		}

	</script>

</cfif>

