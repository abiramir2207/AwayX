<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Prof_Model_Classification\listClassification.cfm
      Date:     2013 Feb
      Author:   Chris Nguyen
      Purpose:  Allow users to manage profitability model classifications

			Remarks:  
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "profit-models-classification">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#actions { margin:7px 0 7px 0; }
#massapply { float:left; margin:15px 0 2px 0;}
#list221 { clear:both; margin-top:5px; }
form { margin:0; padding:0 }
.dropdown { width:50px; }
.action { margin-right:13px; }
</style>
<cfscript>
  dataCFC = createObject("component", "components.general.Profitability_Models");
</cfscript>


<cfif cgi.request_method eq "post">
	<cfif form.action eq "delete">
		<cfset dataCFC.deleteClassification(  classification_id   = form.classification_id )>
	</cfif>
</cfif>

<cfscript>
  qClassifications = dataCFC.getClassifications();
</cfscript>

<cfoutput>
<div id="whole">
	<div id="actions">
		<a href="##" class="" id="add301">#application.util.string.actionLinkFormat("create new classification")#</a>
	</div>
	</cfoutput>
	
	<div id="list221">
		<form id="form226" method="post">
		<input type="hidden" name="action" id="action">
		<input type="hidden" name="classification_id" id="classification_id">
		<table class="datagrid" id="datagrid" style='table-layout:fixed'>
			<col width="60%">
			<col width="40%">
			<thead>
			<tr>
			 <th>Classification Name</th>
			 <th>Action</th>
			</tr>
			</thead>
			
			<tbody>
			<cfsetting enablecfoutputonly="true" >
			<cfloop query="qClassifications">
			<cfoutput><tr></cfoutput>
			  <cfoutput><td>#qClassifications.Classification_Name#</td></cfoutput>
			  <cfoutput><td rowid="#qClassifications.Prof_Model_Classification_Id#"><a href="##" class="action edit301">#application.util.string.actionLinkFormat("edit")#</a> <a href="##" class="action del301">#application.util.string.actionLinkFormat("delete")#</a></td></cfoutput>
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

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script type="text/javascript">
$(document).ready(function() {
  oTable = $('#datagrid').dataTable({
       "aaSorting": []
      ,"aoColumns": [  
                       { "bSearchable":true }
                      ,{ "bSearchable":false, "bSortable":false }
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

	$('#save222').click( function() {
	  $("#form226").submit();
	});

	$('#add301').click( function() {
	  window.location = "editClassification.cfm?classification_id=0";
	});

	$('.edit301').click( function() {
	  window.location = "editClassification.cfm?classification_id=" + $(this).parent().attr('rowid');
	});

	$('.del301').click( function() {
	  if ( confirm('Are you sure you want to delete?') ) {
		  $('#action').val( 'delete' );
		  $('#classification_id').val( $(this).parent().attr('rowid') );
		  $("#form226").submit();
		}
	});
});
</script>
</cfmodule>