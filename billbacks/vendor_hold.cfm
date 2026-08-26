<!doctype html>
<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \billbacks\vendor_hold.cfm
      Date:     2015 March
      Author:   Chris Nguyen
      Purpose:  Vendor Hold Research Tool from home page
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="form.action" default="">
<cfscript>
	variables.noty         = {};
	variables.noty.message = [];
	variables.noty.timeout = [];
	variables.lock_main_id = 'Vendor_Hold_Research';
	variables.lock_cfc     = createObject("component", "components.general.lock");
	variables.data_cfc     = createObject("component", "components.billback.vendor_hold");
</cfscript>

<cfif cgi.request_method eq 'post'>
	<!--- switching from readonly to edit --->
	<cfif form.action eq "edit">
		<!--- attempt to lock it --->
		<cfset variables.lock_success = lock_cfc.lock( variables.lock_main_id )>
		<!--- locking was failed --->
		<cfif not variables.lock_success>
			<!--- stay in read only mode --->
			<cfscript>
				form.action = "readonly";
			</cfscript>
		</cfif>
	<!--- switching from edit to readonly --->
	<cfelseif form.action eq "readonly">
		<cfset variables.unlock_success = lock_cfc.unlockByID( variables.lock_main_id )>
	<cfelseif form.action eq "save">
		<cfscript>
			variables.data_cfc.saveData( form );
			arrayAppend(variables.noty.message, "Your changes have been saved successfully.<br>If you are done with all your changes click the <b>Edit</b> button for read only & then click the <b>close window</b> option.");
			arrayAppend(variables.noty.timeout, 60000);
		</cfscript>
	</cfif>
</cfif>

<cfscript>
	variables.billbacks   = variables.data_cfc.getBillBacks();
	variables.segments    = variables.data_cfc.getSegments();
	variables.statuses    = variables.data_cfc.getStatuses();
	variables.closings    = variables.data_cfc.getClosings();
	variables.lock_status = lock_cfc.getStatus( variables.lock_main_id );

	variables.aaData = [];

	// <!--- switch to edit mode if page is locked by current user --->
	if ( variables.lock_status.is_Locked and variables.lock_status.Locked_By_User_ID eq request.AccessStructure.User_ID )
		form.action = 'edit';
	if (form.action eq 'edit') {
		variables.disabled = '';
	}
	else {
		variables.disabled = 'disabled';
	}
	variables.nbsp = '&nbsp;';
</cfscript>
<!--- build aaData parameter (an array of arrays) for DataTables --->
<cfoutput query="variables.billbacks">
	<cfif variables.billbacks.cLosing_Method EQ 'Payment'>
		<cfset vendorNameORPayeeName = variables.billbacks.Vendor_Name>
		<cfset vendorIDORPayeeID = variables.billbacks.Vendor_ID>	
	<cfelse>
		<cfset vendorNameORPayeeName = variables.billbacks.Payee_Name>
		<cfset vendorIDORPayeeID = variables.billbacks.Payee_Id>	
	</cfif>	
	
	<cfscript>
		variables.aTemp = [];
		variables.checked = (variables.billbacks.hold eq 1 ? "" : "checked");
		// do not allow to release (no checkbox) wip, rfa billbacks
		if (variables.billbacks.BillBack_Status_Id eq 1 OR variables.billbacks.BillBack_Status_Id eq 2) {
			arrayAppend(variables.aTemp,'&nbsp;');
		}
		else {
			arrayAppend(variables.aTemp,'<input type=checkbox name=release #variables.disabled# #variables.checked# save=0 value="#variables.billbacks.billback_ID#">');
		}

		arrayAppend(variables.aTemp, variables.billbacks.segment);
		arrayAppend(variables.aTemp, replace(variables.billbacks.analyst,",","","all"));
		arrayAppend(variables.aTemp, variables.billbacks.referenceNum);
		arrayAppend(variables.aTemp, variables.billbacks.bb_code);
		arrayAppend(variables.aTemp, variables.billbacks.bb_status_abbreviation);
		arrayAppend(variables.aTemp, variables.billbacks.cLosing_Method);
		arrayAppend(variables.aTemp, vendorIDORPayeeID);
		arrayAppend(variables.aTemp, replace(vendorNameORPayeeName,",","","all"));
		arrayAppend(variables.aTemp, dollarFormat(variables.billbacks.bb_amount));
		arrayAppend(variables.aTemp, dollarFormat(variables.billbacks.expected_amount));
		arrayAppend(variables.aTemp, dollarFormat(variables.billbacks.approved_amount));
		arrayAppend(variables.aTemp, dateformat(variables.billbacks.Created_Date, 'm/d/yyyy'));
		arrayAppend(variables.aTemp, dateformat(variables.billbacks.Date_Approved, 'm/d/yyyy'));
		arrayAppend(variables.aTemp, variables.billbacks.age);

		arrayAppend(variables.aaData, variables.aTemp);
	</cfscript>
</cfoutput>
</cfsilent>
<html>
<head>
    <title>Vendor Hold Research</title>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
    <style>
	.right { float: right; }
	.header1 { margin: 10px 0; width: 100%; }
	div.header2 { margin-bottom:10px; }
	.header2 a { margin-right: 25px; }
	.info { margin-left:30px; font-weight:bold; font-size:1em; color:black; padding:5px 20px; letter-spacing:0.75px; border: 3px solid orange; }
	div#msg55 { font-size: 1.15em; letter-spacing:0.9px; }
	div#msg55 p { font-size: 1.35em; margin:20px; padding:20px; background-color: #BDE5F8; letter-spacing:0.9px; }
	button { cursor: pointer; }
	span.mode1, span.mode2 { font-size: 0.9em; font-weight: normal; }
	span.mode1 { color: #ffce84; }
	span.mode2 { color: white; }
	table.datagrid { table-layout: fixed; }
	table.datagrid td { height: 20px; overflow: hidden; }
	th, td { overflow:hidden; }
	td.dollar { text-align: right; }
	th.center2, td.center { text-align: center; }
	thead th { text-align:left; }
	thead th.nobar { border-left:2px solid #FFCE84 !important; }   /* hide left border */
	thead input, thead select, tfoot input { width: 98%; }
    </style>
</head>
<body>
	<cfsavecontent variable="variables.body">
	<div id="msg55"></div>    <!--- reserve this div for displaying message in long process (e.g. saving changes) --->
	<!--- export to csv form --->
	<form action="/common_files/csv.cfm" method ="post" id="csv_form" name="csv">
		<input type="hidden" name="csv_text" id="csv_text">
		<input type="hidden" name="csv_file_name">
	</form>
	<!--- main form --->
	<form name="vendor_hold" method="post">
		<input type="hidden" name="action" value=<cfoutput>"#form.action#"</cfoutput>>
		<input type="hidden" name="unrelease">  <!--- list of checked boxes that became unchecked --->
		<div class="header1">
			<!--- read only/edit button --->
			<cfif form.action eq 'edit'>
				<button class="edit" title="Click for Read Only" id="page_mode" value="edit"> <b>Edit</b> <span class="mode2">(click for read only) </span></button>
			<cfelse>
				<button class="readonly" title="Click to Edit" id="page_mode" value="readonly"> <b>Read Only</b> <span class="mode1">(click to edit)</span> </button>
				<cfif len(variables.lock_status.Locked_By_User_Name)>
					<span class="info">Vendor hold research is currently locked by <cfoutput>#variables.lock_status.Locked_By_User_Name#</cfoutput></span>
				</cfif>
			</cfif>
		</div> <!--- class="header1" --->

		<div class="header2">
			<span>
				<cfoutput>
				<cfif form.action eq 'edit'>
					<a href="##" id="save">#application.util.string.actionLinkFormat2("save")#</a>
				</cfif>
				<a href="##" id="export" onclick="getCSVData();">#application.util.string.actionLinkFormat2("export to csv")#</a>
				<cfif form.action neq 'edit'>
					<a href="##" id="refresh">#application.util.string.actionLinkFormat2("refresh page")#</a>
				</cfif>
				<a href="##" id="reset">#application.util.string.actionLinkFormat2("reset filter")#</a>
				<a href="##" id="close">#application.util.string.actionLinkFormat2("close window")#</a>
				</cfoutput>
			</span>
		</div> <!--- class="header2" --->

		<div class="content">
			<!--- data table grid --->
			<cfset variables.columnSizes = [1.2,    <!--- release --->
											1.5,    <!--- segment --->
											3,      <!--- analyst --->
											2,      <!--- invoice --->
											2,      <!--- billback --->
											1,      <!--- status --->
											1.5,    <!--- closing --->
											1.75,   <!--- vendor --->
											3,      <!--- vendor name --->
											2,      <!--- claimed --->
											2,      <!--- expected --->
											2,      <!--- approved --->
											1.35,   <!--- created --->
											1.45,   <!--- approved --->
											0.3     <!--- age --->          ]>
			<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>

			<table id="datagrid" class="datagrid" style='table-layout:fixed;width:100%;'>
				<!--- <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
					<cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
				</cfloop> --->
				<col width="4%">  <!--- release --->
				<col width="4%">  <!--- segment --->
				<col width="12%"> <!--- analyst --->
				<col width="7%">  <!--- invoice --->
				<col width="7%">  <!--- billback --->
				<col width="4%">  <!--- status --->
				<col width="5%">  <!--- closing --->
				<col width="6%">  <!--- vendor --->
				<col width="16%"> <!--- vendor name --->
				<col width="7%">  <!--- claimed --->
				<col width="7%">  <!--- expected --->
				<col width="7%">  <!--- approved --->
				<col width="5%">  <!--- created --->
				<col width="5%">  <!--- approved --->
				<col width="4%">  <!--- age --->
				<cfoutput>
				<thead>
					<tr>
						<th class="center">Release</th>
						<th id="seg51">Segment</th>
						<th>Analyst</th>
						<th>Invoice</th>
						<th>Billback</th>
						<th id="sta51">Status</th>
						<th>Closing</th>
						<th>Vendor / Payee</th>
						<th>Vendor / Payee Name</th>
						<th>Claimed</th>
						<th>Expected</th>
						<th>Approved</th>
						<th id="cre51">Created</th>
						<th id="app51">Approved</th>
						<th>Age</th>
					</tr>
					<tr id="filter">
						<th class="csvExclude center"><input type="checkbox" name="checkall" #variables.disabled#></th>
						<th class="nobar csvExclude">
							<select name="segment">
								<option value="">All</option>
								<cfloop query="variables.segments">
									<option>#variables.segments.Business_Unit_Id#</option>
								</cfloop>
							</select>
						</th>
						<th class="nobar csvExclude"><input type="text" name="analyst"></th>
						<th class="nobar csvExclude"><input type="text" name="invoice"></th>
						<th class="nobar csvExclude"><input type="text" name="billback"></th>
						<th class="nobar csvExclude">
							<select name="status">
								<option value="">All</option>
								<cfloop query="variables.statuses">
									<option>#variables.statuses.bb_Status_Abbreviation#</option>
								</cfloop>
							</select>
						</th>
						<th class="nobar csvExclude">
							<select name="closing">
								<option value="">All</option>
								<cfloop query="variables.closings">
									<option>#variables.closings.vchBillBack_cLosing_Method_desc#</option>
								</cfloop>
							</select>
						</th>
						<th class="nobar csvExclude"><input type="text" name="vendor"></th>
						<th class="nobar csvExclude"><input type="text" name="vendor_name"></th>

						<th class="nobar csvExclude">&nbsp;</th>
						<th class="nobar csvExclude">&nbsp;</th>
						<th class="nobar csvExclude">&nbsp;</th>
						<th class="nobar csvExclude">&nbsp;</th>
						<th class="nobar csvExclude">&nbsp;</th>
						<th class="nobar csvExclude">&nbsp;</th>
					</tr>
				</thead>
				</cfoutput>
				<tbody>
				</tbody>
			</table>
		</div> <!--- class="content" --->
	</form>
	</cfsavecontent>
	<!--- remove extra white spaces prior to displaying on the page --->
	<cfoutput>#application.util.string.compress( variables.body )#</cfoutput>

	<cfinclude template="/common_files/jQuery.cfm">
	<cfinclude template="/common_files/dataTables2.cfm">
	<script src="/script/javascript/table2csv.js?d"></script>
	<script src="/script/javascript/jquery.noty.packaged.min.js"></script>
	<script src="/script/javascript/jquery.dataTables-api.js"></script>

	<script>
	// adjust column headings & font size to fit small screen
	if ($(window).width() < 1400) {
		$("th, td").css("font-size", "0.85em");
		$("#seg51").text("Seg");
		$("#sta51").text("Stat");
		$("#cre51").text("Added");
		$("#app51").text("App Dt");
	}
  	var  my_form = $('form[name=vendor_hold]')
  		,checkall = $("input[name=checkall]")
  		,windowHeight = $(window).height(), sScrollY = Math.floor( ( windowHeight > 800 ? 0.75 : .73 ) * windowHeight )
     	,mydatagrid = $('#datagrid').show().dataTable({
     						   "aaData": <cfoutput>#serializeJSON(variables.aaData)#</cfoutput>
						      ,"aaSorting": []
						      ,"aoColumns": [	 {"bSortable":false, "bSearchable":false, "sClass":"center"}    /* release */
												,{"bSortable":true, "sClass":"center"}     /* segment */
												,{"bSortable":true}     /* analyst */
												,{"bSortable":true}     /* invoice */
												,{"bSortable":true, "sClass":"center"}     /* billback */
												,{"bSortable":true, "sClass":"center"}     /* status */
												,{"bSortable":true, "sClass":"center"}     /* closing */
												,{"bSortable":true, "sClass":"center"}     /* vendor */
												,{"bSortable":true}     /* vendor name */
												,{"bSortable":true, "sType":"dollar",  "bSearchable":false, "sClass":"dollar"}     /* claimed */
												,{"bSortable":true, "sType":"dollar",  "bSearchable":false, "sClass":"dollar"}     /* expected*/
												,{"bSortable":true, "sType":"dollar",  "bSearchable":false, "sClass":"dollar"}     /* approved*/
												,{"bSortable":true, "sType":"date",    "bSearchable":false, "sClass":"center"}     /* created */
												,{"bSortable":true, "sType":"date",    "bSearchable":false, "sClass":"center"}     /* approved*/
												,{"bSortable":true, "sType":"numeric", "bSearchable":false, "sClass":"center"}     /* age */
						      				]
						      ,"bAutoWidth": false            // false for quicker rendering
						      ,"bDeferRender": true           // true for quicker rendering
						      ,"bPaginate": false
						      ,"bProcessing": true            // true to show processing message in sorting large table
						      ,"bScrollCollapse": false
						      ,"bSortCellsTop": true          // true to inform sorting on first row in thead
						      ,"bSortClasses": false
						      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
						      ,"sDom": 'tir'
							  ,"sScrollY": sScrollY
	  				});
	// highlight current row
	$('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
	// set up multiple columns filter
	$("#filter th").each( function ( i ) {
	    $('select, input', this).change( function (e) {
	    	if ($(this).attr("name") !== "checkall") {
	        	mydatagrid.fnFilter( $(this).val(), i );
				checkall.removeAttr("checked");
	    	}
	    });
	});
	// refresh page with latest information
	$('#refresh').click(function() {
		my_form.hide();
		window.location.href = '/billbacks/vendor_hold.cfm';
	});
	// on Enter key filter data in the focused column
	$("form").keypress(function(e) {
		if (e.which == 13) {
			$("#filter th").each( function ( i ) {
			    $('select:focus, input:focus', this).each( function (e) {
	    			if ($(this).attr("name") !== "checkall") {
			        	mydatagrid.fnFilter( $(this).val(), i );
						checkall.removeAttr("checked");
	    			}
			    });
			});
			return false;
		}
	});
	$('#page_mode').click(function() {
		var current_mode = $(this).val();
		$('input[name=action]').val(current_mode == 'readonly' ? 'edit' : 'readonly');
		my_form.hide();
		$("#msg55").append("<p>Processing, please wait...</p>");
		my_form.submit();
	});
	// reset all filters
	function reset() {
		$("#filter th").each( function ( i ) {
		    $('select, input', this).each(function() {
		    	if ($(this).attr("name") !== "checkall") {
					// if filter is not empty clear it and refresh
					if ( $(this).val().length ) {
			        	$(this).val("");
			        	mydatagrid.fnFilter( "", i );
					}
		    	}
		    });
		});
		checkall.removeAttr("checked");
		return true;
	};
	$("#reset").click(function() { reset(); });
	// keep track of changes
	$("input[name=release]").change(function() { $(this).attr("save", 1) } );
	checkall.change(function() {
		$("input[name=release]").attr("save", 1).attr("checked", (this.checked ? true : false));
	});
	// user clicked save data
	$("#save").click(function() {
		my_form.hide();
		$("#msg55").append("<p>Saving changes, please wait...</p>");
        reset();
        // alert($("input[save=1]").length)
		var notChecked = [];
		$("input[save=1]:not(:checked)").each(function(){
			notChecked.push( $(this).val() );
		})
		// save above unchecked checkboxes in a hidden input
		$('input[name=unrelease]').val( notChecked.join(',') );
		$('input[name=action]').val("save");
		// disable all inputs that were not changed to simplify save logic & for better performance
		$("input[save=0], thead input, thead select").attr("disabled", true);
		my_form.submit();
	});
	// export to csv
	getCSVData = function() {
		$('input[name=csv_file_name]').val( "vendor_hold_research_"
		                                    + Math.random().toString(36).slice(2)    // append an arbitrary unique substring
											+ ".csv");
		var csv_value=$('table.datagrid').table2CSV( {  csvExclude: 'csvExclude'   // filter out elements with csvExclude class
			                                         } );
		$("#csv_text").val(csv_value);
		$("#csv_form").submit();
	}
	// close window
	$('#close').click(function() {
		// if changes were made confirm
		if ($("#page_mode").val() == 'edit' && reset() && $("input[save=1]").length) {
			noty( { text: "Your unsaved changes will be lost.<br>Click <b>go back</b> to return & save your changes,<br>otherwise click continue."
			          ,type:'error'
			          ,layout:'center'
			          ,animation: { open: {height: 'toggle'}, close: {height: 'toggle'}, easing: 'swing', speed: 250 }
			          ,buttons: [  { text:'go back', addClass:'btn-primary', onClick:function($noty) {  $noty.close(); } }
			                      ,{ text:'continue', onClick:function($noty) { $noty.close(); window.close(); } } ]
			        });
		}
		else {
			window.close();
		}
	});
	// display notification messages
	<cfoutput>
	<cfloop from="1" to="#arrayLen(variables.noty.Message)#" index="variables.idx">
		noty( { text: "#variables.noty.Message[ variables.idx ]#"
		      ,type:'information'
		      <cfif variables.noty.timeout[ variables.idx ] gt 0>
		          ,timeout: #variables.noty.timeout[ variables.idx ]#
		      </cfif>
		      ,layout:'bottom'
		      ,closeWith: ['click']
		    });
	</cfloop>
	</cfoutput>
	</script>
</body>
</html>