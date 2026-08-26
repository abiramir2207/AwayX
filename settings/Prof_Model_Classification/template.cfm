<!---------------------------------------------------------------------------------------------------------------------
      Template: 
      Date:     2013 Feb
      Author:   Chris Nguyen
      Purpose:  Allow users to assign classification to templates

			Remarks:  
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "profit-models-classification">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#actions { float:right; margin:15px 0 2px 0; }
#apply853 { float:left; margin:15px 0 10px 0; }
#massapply { margin:0 0 5px 0; }
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
		Saving and loading templates, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
	</div>
	<!---<cfdump var="#form#">--->
	<cfset dataCFC.saveTemplates( form, "classifications" )>
	<!---<cfabort>--->
<cfelse>
	<div id="wait" style='margin-top:10px;'>
		Loading templates, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
	</div>
</cfif>
</cfoutput>

<cfscript>
  qTemplates = dataCFC.getTemplates( "classifications");
  qGenericTypes = dataCFC.getGenericTypes();
  qClassifications = dataCFC.getClassifications();
</cfscript>

<cfoutput>
<div id="whole">
	<form id="form226" method="post">
	<div id="apply853">
		<b>Classification:</b> <select name="Prof_Model_Classification_Id" style="width:250px;"><option> </option><cfloop query="qClassifications"><option value="#Prof_Model_Classification_Id#">#qClassifications.Classification_Name#</option></cfloop></select>
		<a href="##" class="action" id="save222">#application.util.string.actionLinkFormat("apply classification & save changes on this page")#</a>
	</div>
	<div id="actions">
		<!--- <a href="##" class="action" id="save222">#application.util.string.actionLinkFormat("save changes on this page")#</a>
		<a href="##" class="action" id="reset222">#application.util.string.actionLinkFormat("reset")#</a> --->
		<a href="##" class="action" id="export222">#application.util.string.actionLinkFormat("export")#</a>
	</div>
	<hr style="clear:both;width:100%;"/>
	</cfoutput>
	
	<div id="list221">
		<input type="hidden" name="updated_rows" id="updated_rows">    <!--- send back a list of templates that were changed --->
		<div id="massapply">
			<input type="checkbox" id="checkall" name="checkall"> <b>select all templates on this page</b>
		</div>

		<table class="datagrid" id="datagrid" style='table-layout:fixed'>
			<col width="20%">
			<col width="27%">
			<col width="27%">
			<col width="27%">

			<thead>
			<tr>
			 <th align="left">Select</th>
			 <th class="columnfilter" align="left">Generic Type<br/><select><option> </option><cfoutput query="qGenericTypes"><option>#qGenericTypes.Generic_Type#</option></cfoutput></select></th>
			 <th align="left">Program Type</th>
			 <th align="left">Classification</th>
			</tr>
			</thead>
			
			<tbody>
			<cfsetting enablecfoutputonly="true" >
			<cfloop query="qTemplates">
			<cfoutput><tr></cfoutput>
			 	<!--- prefix input name with a letter 'i' to make it a valid name; when we post we would need to strip it off 
			 	      to get the numeric ID to find the row to update; --->
			  <cfoutput><td><input type="checkbox" name="i#qTemplates.Prof_Model_Template_Classifications_Id#" class="cbox"></td></cfoutput>
			  <cfoutput><td>#qTemplates.Generic_Type#</td></cfoutput>
			  <cfoutput><td>#qTemplates.Created_Type#</td></cfoutput>
			  <cfoutput><td>#qTemplates.Classification_Name#</td></cfoutput>
			<cfoutput></tr></cfoutput>
			</cfloop>
			<cfsetting enablecfoutputonly="false" >
			</tbody>
		</table>
	</div>
	</form>
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
                      ,{ "bSearchable":true, "bSortable":false }
                      ,{ "bSearchable":true }
                      ,{ "bSearchable":true, "bSortable":true }
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
	  	$('.cbox').prop('checked', checked_value );
	  }
	);
  
	$('#save222').click( function() {
		var temp_array = [];
		$('.cbox:checked').each( function() { temp_array.push( $(this).prop('name') ); } );
		if ( temp_array.length == 0 ) {
			alert( "Please select at least one operator." );
			return false;
		}

		$(this).html('<b>Saving...</b> <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">');
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
	  $("#csv_file_name").val( 'Profitability Model Template Classifications ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv' );
	  $("#csv_form").submit();
	});

	$('#wait').hide();
	// preload image for quicker display
  var image = $('<img />').attr('src', '/Images/ajax-loader.gif');
});
</script>
</cfmodule>