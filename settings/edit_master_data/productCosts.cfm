<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\edit_master_data\productCosts.cfm
      Date:     2013 Sep
      Author:   Chris Nguyen
      Purpose:  Allow users to manage product costs

      Remarks:  -
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html>
<head>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/select2.css">
<style>
#actions { float:right; margin:15px 0 2px 0; }
#apply853 { float:left; margin:15px 0 10px 0; }
#list221 { clear:both; margin-top:5px; }
#massapply { margin:0 0 5px 0; }
form { margin:0; padding:0 }
.dropdown { width:50px; }
.action { margin-left:13px; }
.dataTables_paginate { margin-right:0px; }
div.massUOM { float:left; margin-left:20px; }
</style>
</head>
<body>
<cfparam name="url.withoutCost" default="0">

<cfinclude template="/helpsystem/help_link.cfm">
<table border="0" cellpadding="2" cellspacing="0" width="100%" id="toPtiTle">
  <tr>
    <td align="left" bgcolor="#A7CAF2" width="100%" height="25" style="background-image: url(/Images/gradient.jpg); background-repeat:no-repeat;">
      <cfoutput><span style="color:white; font-size:14px; font-weight: bold; padding-left:5px; letter-spacing:1.75px">PRODUCT COSTS</span></cfoutput>
    </td>
  </tr>
</table>

<cfoutput>
<cfif cgi.request_method eq "post">
  <div id="wait" style='margin-top:10px;'>
    Saving and loading #lcase(application.returned_customer_setting.Item_Label)#, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
  </div>
  <!--- <cfdump var="#form#"> --->
  <cfset dataCFC = createObject("component", "components.products.products")>
  <cfset dataCFC.saveProductCosts( products = form )>
  <!---<cfabort>--->
<cfelse>
  <div id="wait" style='margin-top:10px;'>
    Loading #lcase(application.returned_customer_setting.Item_Label)#, please wait... <img src="/Images/ajax-loader.gif" border=0 height="15" width="15">
  </div>
</cfif>
</cfoutput>

<cfscript>
  dataCFC = createObject("component", "components.general.Profitability_Models");
  qTypeCodes = dataCFC.getTypeCodes();
  qTypeGroups = dataCFC.getTypeGroups();

  dataCFC = createObject("component", "components.products.products");
  qBrands = dataCFC.getBrands();
  qQBrands = dataCFC.getQBrands();
</cfscript>

<form action="/common_files/csv.cfm" method ="post" id="csv_form">
<input type="hidden" name="csv_text" id="csv_text">
<input type="hidden" name="csv_file_name" id="csv_file_name">
</form>

<cfoutput>
<!--- due to a large number of items in the system we do not display the content until dataTable is done
      with processing the table content. --->
<form id="form226" method="post">
<div id="whole" style="display:none">
  <div id="actions">
    <input type="checkbox" id="withoutCost" name="withoutCost" <cfif url.withoutCost eq '1'>checked=checked</cfif>><b>show only #lcase(application.returned_customer_setting.Item_Label)# without cost</b>
    <a href="##" class="action" id="save222">#application.util.string.actionLinkFormat("save")#</a>
    <a href="##" class="action" id="export222">#application.util.string.actionLinkFormat("export")#</a>
  </div>
  <hr style="clear:both;width:100%;"/>
  </cfoutput>

  <div id="list221">
    <input type="hidden" name="updated_rows" id="updated_rows">    <!--- send back a list of items that were changed --->

    <table class="datagrid" id="datagrid" style='table-layout:fixed'>
      <col width="10%">
      <col width="15%">
      <col width="15%">

      <col width="15%">
      <col width="12%">
      <col width="12%">

      <col width="5%">
      <col width="10%">
      <col width="6%">

      <thead>
      <tr>
       <cfoutput><th>#application.returned_customer_setting.Item_Label#</th></cfoutput>
       <th>Description</th>
       <th class="columnfilter"><cfoutput>#application.returned_customer_setting.Type_Code_Label_Singular#</cfoutput><br/><select style="width:99%;"><option> </option><cfoutput query="qTypeCodes"><option>#qTypeCodes.Type_Code_Desc#</option></cfoutput></select></th>
       <th class="columnfilter"><cfoutput>#application.returned_customer_setting.Type_Group_Label_Singular#</cfoutput><br/><select style="width:99%;"><option> </option><cfoutput query="qTypeGroups"><option>#qTypeGroups.Type_Group_Desc#</option></cfoutput></select></th>

       <th class="columnfilter">Brand<br/><select style="width:99%;"><option> </option><cfoutput query="qBrands"><option>#qBrands.Brand_Name#</option></cfoutput></select></th>
       <th class="columnfilter"><cfoutput>#application.returned_customer_setting.Q_Brand_Label_Singular#</cfoutput><br/><select style="width:99%;"><option> </option><cfoutput query="qQBrands"><option>#qQBrands.q_Brand#</option></cfoutput></select></th>

       <th class="columnfilter">Active<br/><select style="width:99%;"><option> </option><option>A</option><option>N</option></select></th>
       <th>Cost</th>
       <th>Per</th>
      </tr>
      </thead>

      <tbody>
      </tbody>
    </table>
  </div>
</div> <!--- id=whole --->
</form>

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/table2csv.js?foo"></script>
<script type="text/javascript" src="/script/javascript/jquery.util.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/moment.min.js"></script>

<script type="text/javascript">
var preDraw = 0;
$(document).ready(function() {
  var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .61 : .4) * windowHeight;
  var oTable = $('#datagrid').dataTable({
       "bServerSide": true
     , "bProcessing": true
     , "iDisplayLength": 100
     , "sAjaxSource": "ajax/productCosts.cfm?withoutCost=<cfoutput>#url.withoutCost#</cfoutput>"
     , "sDom": 'f<"massUOM">plrtip'
      ,"sScrollY": sScrollY         <!--- data grid height --->
      ,"aoColumns": [
                       { "bSearchable":true }
                      ,{ "bSearchable":true }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                      ,{ "bSearchable":false, "bSortable":false }
                    ]
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"aLengthMenu": [ [100, 200, 500], [100, 200, 500]]
      ,"bScrollCollapse": true
      ,"bSortClasses": false
      ,"fnPreDrawCallback": function( oSettings ) {
            // for each page refresh by Ajax fnPreDrawCallback is called twice we therefore need to keep track of number of calls
            if ( preDraw == 0 && $('input.changed').length ) {
              if (!confirm("You have unsaved changes.\n\n Click Cancel to go back to save.\n Click OK to ignore your changes and continue.") ) {
                return false;
              }
            }
            preDraw++;
          }
      ,"fnDrawCallback": function() {
          preDraw = 0;
          $(".cost, .uom").change( MarkAsChanged );
          $(".cost").forceNumeric();
        }
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

  function MarkAsChanged(){
    // mark both cost input and uom radio button inputs as changed
    $(this).parents('tr').find('input').addClass("changed");
  }

  $('#save222').click( function() {
    $("#form226").hide();
    // disable inputs that were not changed so they won't be sent in the form post, minimize number of db updates
    $("#form226 input:not(.changed)").attr("disabled", "disabled");
    $("#form226").submit();
  });

  $('#reset222').click( function() {
    window.location.href = window.location.href;
  });

  $('#export222').click( function() {
    var csv_value=$('#datagrid').table2CSV();
    $("#csv_text").val(csv_value);
    $("#csv_file_name").val( <cfoutput>'#application.returned_customer_setting.Item_Label#'</cfoutput> + ' Costs ' + moment().format('LLL') + '.csv' );
    $("#csv_form").submit();
  });

  $('#wait').hide();
  $('#whole').show();
  // preload image for quicker display
  var image = $('<img />').attr('src', '/Images/ajax-loader.gif');

  <cfif url.withoutCost eq '1'>
    var urlWithoutCost = 1;
  <cfelse>
    var urlWithoutCost = 0;
  </cfif>

  // mass UOM elements and the associated event
  $('div.massUOM').html( '<b>Cost for all products at UOM</b> <input name="massUOM" type="radio" value="cs">cs  <input name="massUOM" type="radio" value="lb">lb' );
  $('div.massUOM input').change(function(event) {
    var massUOM = $(this).val();
    $('.uom[value=' + massUOM + ']').prop('checked', 'checked').addClass("changed");
    $('.cost').addClass("changed");
  });

  $('#withoutCost').click(function() {
    if ( $('input.changed').length ) {
      if (!confirm("You have unsaved changes.\n\n Click Cancel to go back to save.\n Click OK to ignore your changes and continue.") ) {
        return false;
      }
    }
    $('#whole').hide( 700 );
    window.location.href = '/settings/edit_master_data/productCosts.cfm?withoutCost=' + (urlWithoutCost == 1 ? 0 : 1);
  });
});
</script>
</body>
</html>