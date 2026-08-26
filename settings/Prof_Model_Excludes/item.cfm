<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Prof_Model_Excludes\item.cfm
      Date:     2013 Feb
      Author:   Chris Nguyen
      Purpose:  Allow users to exclude products

			Remarks:  - Use multiple pages due to large number of products in the system
			          - [save] option would save data on current page to avoid performance problem
			          - mass apply option would apply to data on current page to avoid performance problem
			          - [reset] option ignores unsaved changes and reload the page
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "profitability-models">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#actions { float:right; margin:15px 0 2px 0; }
#massapply { float:left; margin:15px 0 2px 0;}
#list221 { clear:both; margin-top:5px; }
form { margin:0; padding:0 }
.dropdown { width:50px; }
.action { margin-left:13px; }
.dataTables_paginate{margin-right:0px;}
</style>
<cfscript>
  dataCFC = createObject("component", "components.general.Profitability_Models");
</cfscript>


<cfoutput>
<cfif cgi.request_method eq "post">
	<div id="wait" style='margin-top:10px;'>
		Saving and loading #lcase(application.returned_customer_setting.Item_Label)#, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
	</div>
	<!---<cfdump var="#form#">--->
	<cfset dataCFC.saveItems( form )>
	<!---<cfabort>--->
<cfelse>
	<div id="wait" style='margin-top:10px;'>
		Loading #lcase(application.returned_customer_setting.Item_Label)#, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
	</div>
</cfif>
</cfoutput>

<cfscript>
  // qItems = dataCFC.getItems();
  qTypeCodes = dataCFC.getTypeCodes();
  qTypeGroups = dataCFC.getTypeGroups();
</cfscript>

<cfoutput>
<!--- due to a large number of items in the system we do not display the content until dataTable is done
      with processing the table content. --->
<div id="whole" style="display:none">
	<div id="massapply">
		<input type="checkbox" id="checkall" name="checkall"> <b>exclude all #lcase(application.returned_customer_setting.Item_Label)# on this page</b>
	</div>
	<div id="actions">
		<a href="##" class="action" id="save222">#application.util.string.actionLinkFormat("save changes on this page")#</a>
		<a href="##" class="action" id="reset222">#application.util.string.actionLinkFormat("reset")#</a>
		<a href="##" class="action" id="export222">#application.util.string.actionLinkFormat("export")#</a>
	</div>
	</cfoutput>
	
	<div id="list221">
		<form id="form226" method="post">
		<input type="hidden" name="updated_rows" id="updated_rows">    <!--- send back a list of items that were changed --->

		<table class="datagrid" id="datagrid" style='table-layout:fixed'>
			<col width="7%">
			<col width="10%">
			<col width="35%">
			<col width="20%">
			<col width="19%">
			<col width="12%">

			<thead>
			<tr>
			 <th align="left">Exclude?</th>
			 <cfoutput><th>#application.returned_customer_setting.Item_Label#</th></cfoutput>
			 <th align="left">Description</th>
			 <th class="columnfilter" align="left">Type Code<br/><select><option> </option><cfoutput query="qTypeCodes"><option>#qTypeCodes.Type_Code_Desc#</option></cfoutput></select></th>
			 <th class="columnfilter" align="left">Type Group<br/><select><option> </option><cfoutput query="qTypeGroups"><option>#qTypeGroups.Type_Group_Desc#</option></cfoutput></select></th>
			 <th class="columnfilter" align="left">Active Code <br/><select class="dropdown"><option> </option><option>A</option><option>N</option></select></th>
			</tr>
			</thead>
			
			<tbody>
			</tbody>
		</table>
		</form>
	</div>
</div> <!--- id=whole --->

<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/table2csv.js?foo"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script type="text/javascript">
$(document).ready(function() {
  var oTable = $('#datagrid').dataTable({
       "bServerSide": true
     , "bProcessing": true
     , "iDisplayLength": 200
     , "sAjaxSource": "ajax/item.cfm"
     , "sDom": "fplrtip"
      ,"aoColumns": [  
                       { "bSearchable":false, "bSortable":true, "sSortDataType": "dom-checkbox" }
                      ,{ "bSearchable":true }
                      ,{ "bSearchable":true }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                    ]
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"aLengthMenu": [ [200, 500, -1], [200, 500, "All"]]
      ,"bScrollCollapse": true
      ,"bSortClasses": false
    })
    .fnSetFilteringDelay()
    ;

  $('.exclude').change( function() { 
  	// initially all checkboxes have 'changed' attribute set to zeroes 
  	// whenever users make change we need to flag this checkbox as changed
  	$(this).prop('changed', '1');       
  } );

  $('#checkall')
    .change(function(e) {
	  	var checked_value = this.checked ? true : false;
	  	$('.exclude').prop('checked', checked_value ).prop('changed', '1');
	  }
	);
  
  /* Add a select menu for each TH element in the table footer */
  $("thead th").each( function ( i ) {
  	if ( $(this).hasClass("columnfilter") ) {
        $('select', this).change( function () {
            oTable.fnFilter( $(this).val(), i );
        } );
    }
  } );

	$('#save222').click( function() {
		$(this).html('<b>Saving...</b> <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
		// scan thru all checkboxes that users touched and make a list
		var temp_array = [];
		$('.exclude[changed=1]').each( function() { temp_array.push( $(this).prop('name') ); } );
		// populate the list of not checked checkboxes & pass it to the posting logic so we can update those rows as not excluded
	  $('#updated_rows').val( temp_array.join(',') );
	  $("#form226").submit();
	});

	$('#reset222').click( function() {
		window.location.href = window.location.href;
	});

	$('#export222').click( function() {
	  var csv_value=$('#datagrid').table2CSV();
	  $("#csv_text").val(csv_value);
	  $("#csv_file_name").val( 'Profitability Model ' + <cfoutput>'#application.returned_customer_setting.Item_Label#'</cfoutput> + ' Excludes ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv' );
	  $("#csv_form").submit();
	});

  $('#wait').hide();
	$('#whole').show();
	// preload image for quicker display
  var image = $('<img />').attr('src', '/Images/ajax-loader.gif');
});
</script>
</cfmodule>