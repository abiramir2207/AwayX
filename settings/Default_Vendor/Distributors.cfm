<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Default_Vendor\Distributors.cfm
      Date:     2014 Jan
      Author:   Chris Nguyen
      Purpose:  Manage default vendor & billback closing method for distributors

			Remarks:
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "defaultVendor">
<cfparam name="FORM.command" default="" />
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/feedback.css">
<style>
	div.datagridwrapper { margin:10px 0; }
  form {
    margin:0; padding: 0;
  }
  td select, th select {
    width:94%;
  }
  .vendor_id {
    width:70%;
  }
  .find {
    cursor: pointer;
  }
  .vendor_name {
    width:94%;
    background-color: #F5F5F5;
  }
  div.save {
    float:left;
    margin: 5px 0 0 15px;
  }
  select {
    font-size: 10px;
  }
  input.deduct_TimeFrame { width:94%; }
  img { position:relative; top:3px; }
  .center { text-align: center; }
</style>

<!--------------------------------------------------------------------------------------------------------------------->

<cfif cgi.request_method eq "post" and FORM.command EQ "">
  <cfset saveChanges()>
  <cfstoredproc procedure = "Update_Default_Vendor_Closing_Method" dataSource="#application.datasource#">
    <cfprocresult name = qryResult>
  </cfstoredproc>
</cfif>



<cfquery name="variables.bbClosingMethods" datasource="#application.datasource#">
  SELECT  vchBillback_Closing_Method_Desc
         ,iBillback_Closing_Method_ID
    FROM BILLBACK_CLOSING_METHODS
   WHERE Deleted = 0
         AND iBillback_Closing_Method_ID IN (1, 2, 5, 8, 3, 12)
		 ORDER BY vchBillback_Closing_Method_Desc
</cfquery>
<!--- D45757 :: Claim rates report - primary source settings panel START --->
<cfquery name="variables.bbClaimSourceXREF" datasource="#application.datasource#">
	SELECT		BCSX.Source_Type_Description + ' (' +BCSX.Source_Code+ ')' AS Source_Type_Description, BCSX.BB_Claim_Source_XREF_ID
	FROM			BB_Claim_Source_XREF BCSX
	WHERE		BCSX.Deleted = 0
	AND			BCSX.Active = 1
	ORDER BY 	BCSX.Source_Type_Description
</cfquery>
<!--- D45757 :: Claim rates report - primary source settings panel END --->
<form name="DataForm" method="post">
<!--- <cfoutput>
	<div align="right">
		<a href="##" onclick="javascript:submitGo();">#application.util.string.actionLinkFormat("Go")#</a>&nbsp;&nbsp;&nbsp;
	</div>
</cfoutput> --->
<div class="datagridwrapper" style="display:block">
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [2.00, 1, 1.25, 2.00, 1.50, 2.00, 1, 1.25, .7, .3] )>

 <table width="100%" border="0" cellpadding="1" cellspacing="0" class="datagrid" id="VendorDisplayTable" style='table-layout:fixed'>
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
  <thead>
    <tr>
    <th>Name</th>
    <th>ID</th>
    <th>Vendor ID<br><input type="text" name="vendor_id_mass" class="vendor_id"> <img class='find' src="/images/searchtool.gif" width="16" height="16"/><br><cfoutput><a id='mass_apply_1' href='##'>#application.util.string.actionLinkFormat('mass apply')#</a></cfoutput></th>
    <th>Vendor Name<br><input type="text" name="vendor_name_mass" class="vendor_name" disabled><br>&nbsp;</th>
    <th>BB Closing Method<br><select id="closing_method_id_mass">
        <option></option>
        <cfoutput query="variables.bbClosingMethods">
          <option value="#variables.bbClosingMethods.iBillback_Closing_Method_ID#">#variables.bbClosingMethods.vchBillback_Closing_Method_Desc#</option>
        </cfoutput>
      </select><br><cfoutput><a id='mass_apply_2' href='##'>#application.util.string.actionLinkFormat('mass apply')#</a></cfoutput></th>
 <!--- D45757 :: Claim rates report - primary source settings panel START --->
 	<th>Primary Source<br><select id="claim_source_xref_mass">
        <option></option>
        <cfoutput query="variables.bbClaimSourceXREF">
          <option value="#variables.bbClaimSourceXREF.BB_Claim_Source_XREF_ID#">#variables.bbClaimSourceXREF.Source_Type_Description#</option>
        </cfoutput>
      </select><br><cfoutput><a id='mass_apply_3' href='##'>#application.util.string.actionLinkFormat('mass apply')#</a></cfoutput></th>
 <!--- D45757 :: Claim rates report - primary source settings panel END --->
	<th>Deduct Timeframe (days) <img src="/images/help_small.gif" title="Number of days after a billback's delivery end date, the distributor will deduct."></th>
    <th>Updated By</th>
    <th>Updated Date</th>
	<th>BBs</th>
    </tr>
  </thead>
<tbody>
</tbody>
</table>
</div>
<cfoutput>
	<input name="command" id="command" type="hidden" value="#FORM.command#" />
</cfoutput>

</form>   <!---name="vendorBatching" method="post">--->

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="saveChanges" output="false">
  <!--- <cfdump var="#form#" abort="false"> --->
  <cfoutput>
  <cfloop collection="#form#" item="local.element">
    <!--- locate the element with a prefix of "row_", it contains the record ID --->
    <cfif left(local.element, 4) eq "row_">
      <!--- extract the information from the related elements --->
      <cfscript>
        local.record_id = form[ local.element ];

        local.row_number = listLast( local.element, '_');
        local.vendor_id = form[ "vendor_id_" & local.row_number ];
        local.closing_method_id = form[ "closing_method_id_" & local.row_number ];
		local.deduct_TimeFrame = form[ "deduct_TimeFrame_" & local.row_number ];
		local.claim_source_xref_id = form[ "claim_source_xref_id_" & local.row_number ];
      </cfscript>

      <!--- #local.record_id# | #local.row_number# | #local.vendor_id# | #local.closing_method_id#<br> --->

      <cfquery name="local.save" datasource="#application.datasource#">
            UPDATE Bsa_foodservice_customers
             SET  Default_vendor_id = '#local.vendor_id#'
					,Default_billback_closing_method_id =  <cfif local.closing_method_id eq ''>NULL<cfelse>#local.closing_method_id#</cfif>
					,Deduct_TimeFrame = '#local.deduct_TimeFrame#'
					,Manually_Updated_Date = GETDATE()
					,Manually_Updated_By = <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>
					,Primary_BB_Claim_Source_XREF_ID = <cfif local.claim_source_xref_id eq ''>NULL<cfelse>#local.claim_source_xref_id#</cfif>
           WHERE BSA_Foodservice_Customers_ID = '#local.record_id#'
                 -- skip updating if vendor_id is not valid
                 <cfif local.vendor_id neq ''>
                  AND ( SELECT 1 FROM Vendor_Master WHERE Vendor_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim( local.vendor_id )#"> ) > 0
                 </cfif>
      </cfquery>
    </cfif>
  </cfloop>
  </cfoutput>
</cffunction>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script>
var sScrollY = Math.round(0.7 * $(window).height()),
    mydatagrid = $('table.datagrid').dataTable({
     aaSorting: [ [0, 'asc'] ]
    ,"aoColumns": [   { "bSearchable":true, "bSortable":true }
                    , { "bSearchable":true, "bSortable":true }
                    , { "bSearchable":true, "bSortable":false, "sClass":"center" }
                    , { "bSearchable":true, "bSortable":false, "sClass":"center" }
                    , { "bSearchable":false, "bSortable":false, "sClass":"center" }
                    , { "bSearchable":true, "bSortable":false, "sClass":"center" }
                    , { "bSearchable":false, "bSortable":false, "sClass":"center" }
                    , { "bSearchable":false, "bSortable":false }
                    , { "bSearchable":false, "bSortable":false }
                    , { "bSearchable":false, "bSortable":false }
                ]
    ,"bAutoWidth": false
    ,"bProcessing": true
    ,"bServerSide": true
    ,"bSortClasses": false
    ,"sScrollY": sScrollY         <!--- data grid height --->
    ,"iDisplayLength": 100
    ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
    ,"sAjaxSource": "ajax/Distributors.cfm"
    ,"sDom": 'f<"save">prtip'
    ,"fnPreDrawCallback": function( oSettings ) {
        // no change was made
        if ( $('input.row_id[changed=1]').length == 0 ) {
          return true;
        }

        // user confirmed to ignore changes
        if ( confirm('Your changes have not been saved.\n\nPlease click Cancel to go back to save, otherwise click OK to ignore.') ) {
          // reset all changed attribute
          $('input.row_id[changed=1]').attr("changed", "0");
          return true;
        }

        // user wanted to go to back to save changes
        return false;
      }
  }).fnSetFilteringDelay();

$('div.save').html(<cfoutput>"<a href='##' id='saveData' class='save'>#application.util.string.actionLinkFormat('save changes on this page')#</a>"</cfoutput>);

$('#saveData').click(function(e) {
	e.preventDefault();
  $('div.success, div.dataTables_filter, table.datagrid, div.dataTables_info, div.dataTables_paginate').hide();
  $(this).hide();
  noty( { text: "Saving changes, please wait for a moment.."
                ,layout:'center'
                ,type:'information'
                ,killer:true
                ,timeout:0  });

  $('tbody tr').each(function() {
     var $row_id = $(this).find('.row_id[changed=0]');
     if ( $row_id.length ) {
       // disable this row - thus not including it in the form post
       $row_id.attr("disabled", "true");
     }
  });

	$('form[name=DataForm]').submit();
});

// $('div.wait').hide();
// $('div.datagridwrapper').show();

$('table.datagrid').on('click', 'th img.find', function(e) {
  var windowcmd = "/GL_code/Vendor_Management/vendor_master_search.cfm?"
                    + "Formname=DataForm"
                    + "&FieldName=vendor_id_mass"
                    + "&DescFieldName=vendor_name_mass"
                    + "&srcCaller=DIST"
					+ "&ReloadForm=0";
					// + "&lsBusinessSegmentID=" + $tr.find('input.Business_Segment_ID').attr("value");
  NewWindow(windowcmd, "Vensearchwindow", 800, 600, "yes", "yes");
})

$('table.datagrid').on('click', 'td img.find', function(e) {
  var $tr = $(e.target).closest('tr');
  // highlight the row to track the location after returning from popup search
  $tr.addClass('over').find("input.row_id").attr("changed", "1");
 // var test = JSON.stringify(e);
//alert(test);  
  var windowcmd = "/GL_code/Vendor_Management/vendor_master_search.cfm?"
                    + "Formname=DataForm"
                    + "&FieldName=" + $tr.find('input.vendor_id').attr("name")
                    + "&DescFieldName=" + $tr.find('.vendor_name').attr("name")
                    + "&ReloadForm=0"
				    + "&srcCaller=DIST"
					+ "&lsBusinessSegmentID=" + $tr.find('input.Business_Segment_ID').attr("value");
  NewWindow(windowcmd, "Vensearchwindow", 800, 600, "yes", "yes");
})

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
$('tbody').on('change', 'select', function(e) {
  var $target = $(e.target);
  $target.closest('tr').find("input.row_id").attr("changed", "1");
  if ($target.hasClass("closing_method")) {
    // 55346 - check for missing bank information based on vendor and closing method
    if (isBankInfoMissing( vendor_id = $target.closest('tr').find("input.vendor_id").val()
                           ,closing_method = $target.val() ) ) {
      // reset value to blank & keep input focused (which requires setTimeout())
      setTimeout(function(){ $target.val('').focus(); }, 0);
      return false;
    }
  }
});
$('tbody').on('change', 'input.vendor_id', function(e) {
  var $target = $(e.target), newValue = $target.val();
	if (newValue !== '' && !isVendor( newValue ) && e.target.id == 'vendor_id') {
    setTimeout(function(){ $target.focus(); }, 0);
  	return false;
	}
	if (e.target.id == 'vendor_id') {
    // 55346 - check for missing bank information based on vendor and closing method
    if (isBankInfoMissing( vendor_id = newValue
                          ,closing_method = $(e.target).closest('tr').find("select.closing_method").val() )) {
      // reset value to blank & keep input focused (which requires setTimeout())
      setTimeout(function(){ $target.val('').focus(); }, 0);
      return false;
    }
 		$(e.target).closest('tr').find("input.row_id").attr("changed", "1");
 	}
});
/*
	Checking for the deduct_TimeFrame text box
	Validation Rules:
	a) The value of the Deduct Timeframe should be a value between 0 and 999
	b) The user should have selected a Vendor ID before entering the Deduct Timeframe value.
*/
$('tbody').on('change', 'input.deduct_TimeFrame', function(e) {
  var $target = $(e.target), newValue = $target.val();
  var strError = '';
  	if (e.target.id == 'deduct_TimeFrame' && (newValue == '' || (newValue < 0 || newValue >= 1000)))
	{
		strError = '- Please enter a valid number between 0-999';
  	}
	if ($(e.target).closest('tr').find("input.vendor_id").attr("value") == '')
	{
		strError = strError + '\n- Please enter a valid vendor ID for this row';
	}
	if (strError != '')
	{
		  alert('Errors Found:\n---------------\n' + strError);
      setTimeout(function(){ $target.focus(); }, 0);
    	return false;
	}

 	if (e.target.id == 'deduct_TimeFrame'){
  		$(e.target).closest('tr').find("input.row_id").attr("changed", "1");
	}
})

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
$('#mass_apply_1').click(function() {
  var mass_value = $('input[name=vendor_id_mass]').val()
     ,dataIsValid = 1
  if (mass_value !== '') {
    dataIsValid = isVendor( mass_value );
    if (! dataIsValid) {
      $('input[name=vendor_id_mass]').focus();
    }
  }
  if (dataIsValid) {
    $('tbody .vendor_id').val( mass_value );
    $('tbody .vendor_name').val( $('input[name=vendor_name_mass]').val() );
    $('tbody .row_id').attr("changed", "1");
  }
});

$('#mass_apply_2').click(function() {
  $('.closing_method').val( $('#closing_method_id_mass').val() );
  $('tbody .row_id').attr("changed", "1");
   return false;
});
// D45757 :: Claim rates report - primary source settings panel START
$('#mass_apply_3').click(function() {
  $('.claim_source_method').val( $('#claim_source_xref_mass').val() );
  $('tbody .row_id').attr("changed", "1");
  return false;
});
// D45757 :: Claim rates report - primary source settings panel END
isVendor = function( vendor_id ) {
  var dataIsValid = 1;
    $.ajax({ url: "/components/programs/Vendor/vendor.cfc"
            ,type: "post"
            ,data: { method: "isVendorMaster"
                    ,vendor_id: vendor_id }
            ,dataType: "json"
                          ,async: false
                          ,timeout:60000
            ,error: function(jqXHR, textStatus, errorThrown) { /* alert( 'System is busy, please try again later.' ); */ dataIsValid = 0; }
            ,success: function(json) { if ( json.ERRORS.length ) {
                                         alert( json.ERRORS.join('\n') );
                                         dataIsValid = 0;
                                       }
                                     }
          });
  return dataIsValid;
};
// check for required vendor bank info based on closing method
isBankInfoMissing = function( vendor_id, closing_method ) {
  var dataIsMissing = 0;
  // do not validate when one of the parameters is missing
  if ( (vendor_id !== '') && (closing_method !== '') ) {
    $.ajax({ url: "/components/programs/Vendor/vendor.cfc"
            ,type: "post"
            ,data: { method: "isBankInfoMissing"
                    ,closing_method: closing_method
                    ,vendor_id: vendor_id }
            ,dataType: "json"
            ,async: false
            ,timeout:60000
            ,error: function(jqXHR, textStatus, errorThrown) { /* alert( 'System is busy, please try again later.' ); */ }
            ,success: function(json) { if ( json.ERRORS.length )  { dataIsMissing = 1; alert( json.ERRORS.join('\n') ); } }
          });
  }
  return dataIsMissing;
};
/*
function submitGo()
{
	document.DataForm.command.value = "ActionGo";
	document.DataForm.submit();
}
*/
function viewBBList(shrShipTo)
{
	window.open("/settings/Default_Vendor/BillbackList.cfm?src=Dist&shrShipTo=" + shrShipTo +"","BB_List","location=0,status=0,scrollbars=1,left=0,top=0,width=500,height=400");
	return false;
}
<cfif cgi.request_method eq "post" and FORM.command EQ "">
  noty( { text: "Your changes have been saved succesfully."
                ,layout:'bottom'
                ,type:'information'
                ,killer:true
                ,timeout:5000  });
</cfif>
</script>

</cfmodule>
