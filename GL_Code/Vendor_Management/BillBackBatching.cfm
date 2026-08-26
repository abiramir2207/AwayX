<!---------------------------------------------------------------------------------------------------------------------
      Template: \GL_Code\Vendor_Management\BillBackBatching.cfm
      Date:     2013 July
      Author:   Chris Nguyen
      Purpose:  

			Remarks:  
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "vendorBatching">
<cfset billbackLabels = createObject("component", "mvc.Models.SettingsService").getBBLabels() />

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link href="/common_files/feedback.css?38095" rel="stylesheet" media="screen" />
<style>
	div.datagridwrapper { margin:5px 0; }
	.dollar { text-align: right; }
	div.batched { float:right; }
	.center { text-align: center; }
</style>
<!--------------------------------------------------------------------------------------------------------------------->

<cfscript>
  dataCFC = createObject("component", "components.programs.vendor.vendor");
	if ( cgi.request_method eq "post" ) {
		// writedump( form );
		dataCFC.saveBillbacksOnHold( form );
	}
  bbLabels = CreateObject("component", "mvc.Models.SettingsService").getBBLabels();
  qBillBacks = dataCFC.getBillbacksOnHold();
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<body>
<cfif cgi.request_method eq "post">
	<!---<cfset dataCFC.saveBillBacks( form )>--->
	<div class="success" style="height:15px;">
		<p>Your changes have been saved succesfully.</p>
	</div>	
</cfif>

<br /><br />

<form name="BillBackBatching" method="post">
<div class="datagridwrapper">
<table id="datagrid" class="datagrid" style='table-layout:fixed'>
  <col width="6%">
  <col width="9%">
  <col width="15%">
  <col width="15%">
  <col width="15%">
  <col width="15%">
  <col width="20%">
  <thead>
    <cfoutput>
    <tr>
      <th class="center">Release?<br/><input type="checkbox" name="checkall" id="toggle_all"></th>
      <th>Status</th>
      <th>#bbLabels['Billback']# ##</th>
      <th>Reference</th>
      <th>#bbLabels['Claimed']# $</th>
      <th>#bbLabels['Payee']# ID</th>
      <th>#bbLabels['Payee']# Name</th>
    </tr>
    </cfoutput>
  </thead>
<tbody>
  <cfsetting enablecfoutputonly=true>
  <cfloop query="qBillBacks">    
    <cfoutput><tr></cfoutput>
      <cfoutput><td class="center"><input type="checkbox" name="BB_#qBillBacks.billback_id#" updated=0 <cfif qBillBacks.hold neq '1'>checked</cfif> class="cb"></td></cfoutput>
      <cfoutput><td>#qBillBacks.bb_Status_Abbreviation#</td></cfoutput>
      <cfoutput><td>#qBillBacks.bb_code#</td></cfoutput>
      <cfoutput><td>#qBillBacks.bb_reference#</td></cfoutput>
      <cfoutput><td class="dollar">#dollarFormat( qBillBacks.bb_amount )#</td></cfoutput>
      <cfoutput><td>#qBillBacks.payee_id#</td></cfoutput>
      <cfoutput><td>#qBillBacks.payee_name#</td></cfoutput>
    <cfoutput></tr></cfoutput>
  </cfloop>
  <cfsetting enablecfoutputonly=false>
</tbody>
</table>
</div>
<input type="hidden" name="notReleased">
</form>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
var hideSuccess = <cfif cgi.request_method eq "post"> true <cfelse> false </cfif>;
$(function() {
	toggle_all = function() {
		$('#toggle_all').prop('checked', ( $('input.cb').length && $('input.cb:checked').length == $('input.cb').length ) ? true : false );
	}
		
  var mydatagrid = $('#datagrid').dataTable({
       aaSorting: [] 
      ,"aoColumns": [ { "bSortable": false  } 
                     ,{ "bSortable": true  }
                     ,{ "bSortable": true  }
                     ,{ "bSortable": true  }
                     ,{ "bSortable": true, "sType":"dollar"  }
                     ,{ "bSortable": true  }
                     ,{ "bSortable": true  } ]
      ,"bAutoWidth": false
      ,"bPaginate": false
      ,"bSortClasses": false
      ,"bScrollCollapse": true
      ,"fnDrawCallback": function() { toggle_all(); }
      ,"sDom": 'f<"batched">ti'
    }).fnSetFilteringDelay();
    
		hideSuccessDiv = function() {
			if ( hideSuccess ) {
				$('div.success').hide( 700 );
				hideSuccess = false;
			}
		}
		
		<!---events for toggle all checkbox------------------------------------------------------------------------------------>
		$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
		 e.stopPropagation();
		 hideSuccessDiv();		 
		 $('input.cb').prop('checked', ( this.checked ) ? true : false );
		});
		
		<!---event for individual checkbox------------------------------------------------------------------------------------>
		$('input.cb').change(function(e){      <!---listen for the change event on the toggle--->
		 	hideSuccessDiv();		 
			$(this).prop('updated', 1);
			toggle_all();
		});

		$('div.batched').html('<b><a href="#" id="saveData" class="save">[ save data ]</a>');

		$('#saveData').click(function(e) {
			e.preventDefault();
	    $(this).prop('disabled', true).html('saving data..');
	    
			// clear filter for all elements to show before sending the form to post
			mydatagrid.fnFilter('');

			var notChecked = [];
			// gather all unchecked checkboxes that users changed (these checkboxes would not posted in the form)
			$('input[updated=1]:not(:checked)').each( function() {
					notChecked.push( $(this).prop('name') );		
			});
			// save above unchecked checkboxes in a hidden input 
			$('input[name=notReleased]').val( notChecked.join(',') );

			$('form[name=BillBackBatching]').submit();		
		});
});
</script>
</cfmodule>