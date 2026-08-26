<!---------------------------------------------------------------------------------------------------------------------
      Template: \GL_Code\Vendor_Management\vendorBatching.cfm
      Date:     2013 July
      Author:   Chris Nguyen
      Purpose:  

			Remarks:  
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "vendorBatching">

<cfset billbackLabels = createObject("component", "mvc.Models.SettingsService").getBBLabels() />

<!---<cfinclude template="header-vb.cfm">--->

<cfparam name="url.batched" default="yes">
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
	div.batched { float: left; }
	div.datagridwrapper { margin:5px 0; }
	.show923 { margin-left: 20px; font-weight: bold; }
</style>

<cfscript>
  dataCFC = createObject("component", "components.programs.vendor.vendor");
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<body>
<cfoutput>
<cfif cgi.request_method eq "post">
	<!---<cfdump var="#form#" abort=true>--->
	<cfset dataCFC.saveBatchedVendors( form )>
</cfif>
</cfoutput>

<div class="wait" style='margin-top:10px;'>
	Loading vendors, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
</div>

<br /><br />

<form name="vendorBatching" method="post">
<cfoutput><a href="##" id="saveData" class="save">#application.util.string.actionLinkFormat("save changes on this page")#</a></cfoutput>
<div class="datagridwrapper" style="display:none">
<table id="datagrid" class="datagrid" style='table-layout:fixed'>
  <col width="10%">
  <col width="28%">
  <col width="25%">
  <col width="30%">
  <col width="7%">
  <thead>
    <tr>
      <th align="left">ID</th>
      <th align="left">Name</th>
      <th align="left">Address</th>
      <th align="left">City, State Zip</th>
      <th align="left">Batched?</th>
    </tr>
  </thead>
<tbody>
</tbody>
</table>
</div>
<input type="hidden" name="notBatched">
</form>   <!---name="vendorBatching" method="post">--->
<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
$(function() {
  var mydatagrid = $('#datagrid').dataTable({
       aaSorting: [ [0, 'asc'] ] 
      ,"aLengthMenu": [ [200, 500, 1000], [200, 500, 1000]]
      ,"aoColumns": [ { "bSortable": true  } 
                     ,{ "bSortable": true  }
                     ,{ "bSortable": false }
                     ,{ "bSortable": true  }
                     ,{ "bSortable": false } ]
      ,"bAutoWidth": false
      ,"bProcessing": true
      ,"bServerSide": true
      ,"bSortClasses": false
      ,"bScrollCollapse": true
      ,"fnDrawCallback": function() { 
																						$('input.batched').change(function(){
																								$(this).prop('updated', 1);
																							});
      	 																 }
      ,"iDisplayLength": 200
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"sAjaxSource": "ajax/vendorBatching.cfm?batched=" + <cfoutput>"#url.batched#"</cfoutput>
      ,"sDom": 'f<"batched">plrtip'
    }).fnSetFilteringDelay();
  
	$('div.batched').html('<span class=show923>Display:</span> </b> <select name="batched"><option value="all"  <cfif url.batched eq "all">selected</cfif>>All</option><option <cfif url.batched eq "yes">selected</cfif> value="Yes">Only Batched</option><option <cfif url.batched eq "no">selected</cfif> value="No">Non Batched</option></select> ');
	
	$('select[name=batched]').change(function(){
		//_pleaseWait();
		window.location = 'vendorBatching.cfm?batched=' + $(this).val();
	});
	
	$('#saveData').click(function(e) {
		e.preventDefault();
    $(this).prop('disabled', true).html('saving data..');
    
		var notChecked = [];
		// gather all unchecked checkboxes that users changed (these checkboxes would not posted in the form)
		$('input[updated=1]:not(:checked)').each( function() {
				notChecked.push( $(this).prop('name') );		
		});
		// save above unchecked checkboxes in a hidden input 
		$('input[name=notBatched]').val( notChecked.join(',') );
		
		$('form[name=vendorBatching]').submit();		
	});
	
	$('div.wait').hide();
	$('div.datagridwrapper').show();
});
</script>

</cfmodule>
