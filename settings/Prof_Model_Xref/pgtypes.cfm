<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Prof_Model_Xref\pgtypes.cfm
      Date:     2013 Mar
      Author:   Chris Nguyen
      Purpose:  Allow users to manage planning group settings
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "profit-models-xref">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#actions { float:right; margin:15px 0 2px 0; }
#massapply { float:left; margin:15px 0 2px 0;}
#list221 { clear:both; margin-top:5px; }
form { margin:0; padding:0 }
.dropdown { width:50px; }
.action { margin-left:13px; }
</style>
<cfscript>
  dataCFC = createObject("component", "components.general.Profitability_Models");
</cfscript>


<cfoutput>
<cfif cgi.request_method eq "post">
	<div id="wait" style='margin-top:10px;'>
		Saving and loading settings, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
	</div>
	<!---<cfdump var="#form#">--->
	<cfset dataCFC.saveXrefs( form )>
	<!---<cfabort>--->
<cfelse>
	<div id="wait" style='margin-top:10px;'>
		Loading settings, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
	</div>
</cfif>
</cfoutput>

<cfscript>
  qXrefs = dataCFC.getXrefs();
</cfscript>

<cfoutput>
<div id="whole">
	<div id="massapply">
		<input type="checkbox" id="checkall" name="checkall"> <b>include all on this page</b>
	</div>
	<div id="actions">
		<a href="##" class="action" id="save222">#application.util.string.actionLinkFormat("save changes on this page")#</a>
		<a href="##" class="action" id="export222">#application.util.string.actionLinkFormat("export")#</a>
	</div>
	</cfoutput>
	
	<div id="list221">
		<form id="form226" method="post">
		<input type="hidden" name="updated_rows" id="updated_rows">    <!--- send back a list of settings that were changed --->

		<table class="datagrid" id="datagrid" style='table-layout:fixed'>
			<col width="20%">
			<col width="30%">
			<col width="50%">

			<thead>
			<tr>
			 <th align="left">Include?</th>
			 <th align="left">Planning Group Type Code</th>
			 <th align="left">Planning Group Type Name</th>
			</tr>
			</thead>
			
			<tbody>
			<cfsetting enablecfoutputonly="true" >
			<cfloop query="qXrefs">
			<cfoutput><tr></cfoutput>
			 	<!--- prefix input name with a letter 'i' to make it a valid name; when we post we would need to strip it off 
			 	      to get the numeric ID to find the row to update; each template has a custom 'changed' attribute defaulted to 0; 
			 	      value is changed to 1 when users change the template included value --->
			  <cfoutput><td><input type="checkbox" name="i#qXrefs.Prof_Model_Xref_Id#" changed=0 <cfif qXrefs.Is_Included>checked=checked</cfif> class="include"></td></cfoutput>
			  <cfoutput><td>#qXrefs.pg_Type_Code#</td></cfoutput>
			  <cfoutput><td>#qXrefs.pg_Type_Name#</td></cfoutput>
			<cfoutput></tr></cfoutput>
			</cfloop>
			<cfsetting enablecfoutputonly="false" >
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
  oTable = $('#datagrid').dataTable({
       "aaSorting": []
      ,"aoColumns": [  
                       { "bSearchable":false, "bSortable":true, "sSortDataType": "dom-checkbox" }
                      ,{ "bSearchable":true, "bSortable":true }
                      ,{ "bSearchable":true, "bSortable":true  }
                    ]
      ,"bAutoWidth": false
      ,"bPaginate": false
      ,"bScrollCollapse": true
      ,"bSortClasses": false
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"sDom": 'fti'
    })
    .fnSetFilteringDelay()
    ;

  $('.include').change( function() { 
  	// initially all checkboxes have 'changed' attribute set to zeroes 
  	// whenever users make change we need to flag this checkbox as changed
  	$(this).prop('changed', '1');       
  } );
  
  /* Add a select menu for each TH element in the table footer */
  $("thead th").each( function ( i ) {
  	if ( $(this).hasClass("columnfilter") ) {
        $('select', this).change( function () {
            oTable.fnFilter( $(this).val(), i );
        } );
    }
  } );
    
  $('#checkall')
    .change(function(e) {
	  	var checked_value = this.checked ? true : false;
	  	$('.include').prop('checked', checked_value ).prop('changed', '1');
	  }
	);
  
	$('#save222').click( function() {
		$(this).html('<b>Saving...</b> <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
		// scan thru all checkboxes that users touched and make a list
		var temp_array = [];
		$('.include[changed=1]').each( function() { temp_array.push( $(this).prop('name') ); } );
		// populate the list of not checked checkboxes & pass it to the posting logic so we can update those rows as not included
	  $('#updated_rows').val( temp_array.join(',') );
	  $("#form226").submit();
	});

	$('#reset222').click( function() {
		window.location.href = window.location.href;
	});

	$('#export222').click( function() {
	  var csv_value=$('#datagrid').table2CSV();
	  $("#csv_text").val(csv_value);
	  $("#csv_file_name").val( 'Profitability Model Xref ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv' );
	  $("#csv_form").submit();
	});

	$('#wait').hide();
	// preload image for quicker display
  var image = $('<img />').attr('src', '/Images/ajax-loader.gif');
});
</script>
</cfmodule>