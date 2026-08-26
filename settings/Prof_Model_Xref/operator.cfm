<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Prof_Model_Classification\operator.cfm
      Date:     2013 Feb
      Author:   Chris Nguyen
      Purpose:  Allow users to manage profitability model operators xref

			Remarks:  - Use multiple pages due to large number of operators in the system
			          - [save] option would save data on current page to avoid performance problem
			          - mass apply option would apply to data on current page to avoid performance problem
			          - [reset] option ignores unsaved changes and reload the page
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "profit-models-xref">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/select2.css">
<style>
#actions { float:right; margin:15px 0 10px 0; }
#apply853 { float:left; margin:15px 0 10px 0; }
#list221 { clear:both; margin-top:5px; }
#massapply { margin:0 0 5px 0; }
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
		Saving and loading #lcase(application.returned_customer_setting.Operator_Label_Plural)#, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
	</div>
	<!---<cfdump var="#form#">--->
	<cfset dataCFC.saveOperators( form=form, category="xref" )>
	<!---<cfabort>--->
<cfelse>
	<div id="wait" style='margin-top:10px;'>
		Loading #lcase(application.returned_customer_setting.Operator_Label_Plural)#, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
	</div>
</cfif>
</cfoutput>

<cfscript>
  labels     = {};
  labels.CFC = createObject("component", "components.settings.labels.labels").init();
  labels.location_type = labels.CFC.getGeneralLabels('Location Type');
  
  qLocationTypes = dataCFC.getOperatorLocationTypes();
  qCustomerPG = dataCFC.getCustomerPG();
</cfscript>

<!--- due to a large number of items in the system we do not display the content until dataTable is done
      with processing the table content. --->
<div id="whole" style="display:none">
	<form id="form226" method="post">
	<cfoutput>
	<div id="apply853">
		<b>#application.returned_customer_setting.Distributor_Label_Singular# Planning Group:</b> <select name="PG_Customer_Category_ID" id="PG_Customer_Category_ID" style="width:350px;"><option> </option><cfloop query="qCustomerPG"><option value="#qCustomerPG.PG_Customer_Category_ID#">#qCustomerPG.PG_Customer_Category_Name# ( #qCustomerPG.PG_Customer_Category_Code# )</option></cfloop></select>
		<a href="##" class="action" id="save222">#application.util.string.actionLinkFormat("assign & save changes on this page")#</a>
	</div>
	<div id="actions">
		<!---<a href="##" class="action" id="save222">#application.util.string.actionLinkFormat("save changes on this page")#</a>--->
		<!---<a href="##" class="action" id="reset222">#application.util.string.actionLinkFormat("reset")#</a>--->
		<a href="##" class="action" id="export222">#application.util.string.actionLinkFormat("export")#</a>
	</div>
	<hr style="clear:both;width:100%;"/>
	</cfoutput>
	
	<div id="list221">
		<input type="hidden" name="updated_rows" id="updated_rows">    <!--- send back a list of items that were changed --->
		<div id="massapply">
			<input type="checkbox" id="checkall" name="checkall"> <b>select all <cfoutput>#lcase(application.returned_customer_setting.Operator_Label_Plural)#</cfoutput> on this page</b>
		</div>

		<table class="datagrid" id="datagrid" style='table-layout:fixed'>
			<col width="7%">
			<col width="25%">
			<col width="12%">
			<col width="24%">
			<col width="10%">
			<col width="22%">

			<thead>
			<tr>
				<cfoutput>
			 <th align="left">Select</th>
			 <th align="left">#application.returned_customer_setting.Operator_Label_Singular# Name</th>
			 <th align="left">#application.returned_customer_setting.Operator_Legacy_Id_label#</th>
			 <th class="columnfilter" align="left"><!---#labels.location_type.General_Labels_Label#--->Location Type<br/>
			 	<select><option> </option>
			 		<cfloop query="qLocationTypes"><option>#qLocationTypes.Operator_Location_Type#</option></cfloop>
			 	</select></th>
			 <th class="columnfilter" align="left">Active Code <br/><select class="dropdown"><option> </option><option>A</option><option>N</option></select></th>
			 <th align="left">#application.returned_customer_setting.Distributor_Label_Singular# Planning Group</th>
			 </cfoutput>
			</tr>
			</thead>
			
			<tbody>
			</tbody>
		</table>
	</div>
	</form>
</div> <!--- id=whole --->

<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/table2csv.js?foo"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/select2.min.js?foo"></script>

<script type="text/javascript">
$(document).ready(function() {
  oTable = $('#datagrid').dataTable({
       "bServerSide": true
     , "bProcessing": true
     , "iDisplayLength": 200
     , "sAjaxSource": "ajax/operator.cfm"
     , "sDom": "fplrtip"
      ,"aLengthMenu": [ [200, 500, -1], [200, 500, "All"]]
      ,"aoColumns": [  
                       { "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":true }
                      ,{ "bSearchable":true }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":true, "bSortable":true }
                    ]
      ,"bScrollCollapse": true
      ,"bSortClasses": false
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
    })
    .fnSetFilteringDelay()
    ;

  /* Add a select menu for each TH element in the table footer */
  $("thead th").each( function ( i ) {
  	if ( $(this).hasClass("columnfilter") ) {
  		  if ( $(this).hasClass("addselect") ) {
					 $(this).html( $(this).html() + '<br/>' + fnCreateSelect( oTable.fnGetColumnData(i) ) );
  		  }
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
	  $('#updated_rows').val( temp_array.join(',') );
	  $("#form226").submit();
	});

	$('#reset222').click( function() {
		window.location.href = window.location.href;
	});

	$('#export222').click( function() {
	  var csv_value=$('#datagrid').table2CSV();
	  $("#csv_text").val(csv_value);
	  $("#csv_file_name").val( 'Profitability Model ' + <cfoutput>'#application.returned_customer_setting.Operator_Label_Plural#'</cfoutput> + ' Xref ' + $.datepicker.formatDate('mm-dd-yy', new Date()) + '.csv' );
	  $("#csv_form").submit();
	});
	$('#wait').hide();
	$('#whole').show();

	// preload image for quicker display
  var image = $('<img />').attr('src', '/Images/ajax-loader.gif');
  <cfif qCustomerPG.recordCount gt 50>
  	$('#PG_Customer_Category_ID').select2( { placeholder:"Choose..." } );
  </cfif>
});

</script>
</cfmodule>