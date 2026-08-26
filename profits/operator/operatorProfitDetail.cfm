<!DOCTYPE>
<!---------------------------------------------------------------------------------------------------------------------
			Template: 
			Date:     
			Author:   Chris Nguyen
			Purpose:  

----------------------------------------------------------------------------------------------------------------------->
<html>
<head>
	<title>Operator Profit Detail</title>
	<style>
	  .datagrid tr td:first-child { text-align: left; font-size: 1em; }
	  .datagrid td { text-align: right; }
  	.neg { color: red !important; }
	</style>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
</head>

<!--------------------------------------------------------------------------------------------------------------------->
<cfscript>
  vars = {};
  vars.volumeFormat = "(,";
  vars.productGroupID = ( url.allProducts eq 'on' ? '00000000-0000-0000-0000-000000000000' : url.product );

  oProfitModel  = createObject("component", "components.general.Profitability_Models");
  qDetail       = oProfitModel.getOperatorProfitDetail( operatorNumber=url.operator, productClass='total', productGroupID=vars.productGroupID );
</cfscript>
<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="cssClassForNumber" access="public" output="false">
  <cfargument name="numericValue" required="true">
  
  <cfreturn val( arguments.numericValue ) gte 0 ? '' : "class=neg">
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

<body>
<cfoutput><h2 style="float:left;margin:0 0 10px 0;">Operator Profit Detail By #url.UOM#</h2>
<a style="float:right;margin:10px 10px 0 0;" id="export" onclick="getCSVData();">#application.util.string.actionLinkFormat("export")#</a>
</cfoutput>
<div class="datagridwrapper">
<table id="datagrid" class="datagrid">
<thead>
	<tr>
	  <cfoutput><th>#application.returned_customer_setting.Distributor_Label_Singular#</th></cfoutput>
	  <th>Current</th>
	  <th>Prior</th>
	  <th>Diff</th>
	  <th>% Diff</th>
  </tr>
</thead>
<tbody>
	<cfsetting enablecfoutputonly=true>
	<cfloop query="qDetail">    
    <cfoutput><tr></cfoutput>
      <cfoutput><td>#qDetail.Distributor_Name# <cfif len(qDetail.Distributor_Number)>( #qDetail.Distributor_Number# )</cfif></td></cfoutput>
      <cfoutput><td #cssClassForNumber( qDetail[ url.uom & "_total_ty"][ qDetail.currentRow ] )#>#numberFormat( qDetail[ url.uom & "_total_ty"][ qDetail.currentRow ], vars.volumeFormat )#</td></cfoutput>
      <cfoutput><td #cssClassForNumber( qDetail[ url.uom & "_total_ly"][ qDetail.currentRow ] )#>#numberFormat( qDetail[ url.uom & "_total_ly"][ qDetail.currentRow ], vars.volumeFormat)#</td></cfoutput>
      <cfoutput><td #cssClassForNumber( qDetail[ url.uom & "_total_abs_ch"][ qDetail.currentRow ] )#>#numberFormat( qDetail[ url.uom & "_total_abs_ch"][ qDetail.currentRow ], vars.volumeFormat)#</td></cfoutput>
      <cfoutput><td #cssClassForNumber( qDetail[ url.uom & "_total_pct_ch"][ qDetail.currentRow ] )#>#numberFormat( qDetail[ url.uom & "_total_pct_ch"][ qDetail.currentRow ], vars.volumeFormat)#%</td></cfoutput>
    <cfoutput></tr></cfoutput>
  </cfloop>
	<cfsetting enablecfoutputonly=false>
</tbody>
</table>
</div>
<form action="/common_files/csv.cfm" method ="post" id="csv_form"> 
  <input type="hidden" name="csv_text" id="csv_text">
  <input type="hidden" name="csv_file_name" id="csv_file_name">
</form>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->
<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/Script/javascript/table2csv.js"></script>
<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>
<script type="text/javascript">
$(function() {
	mydatagrid = $('#datagrid').dataTable({
	     "bAutoWidth": false
	    ,"bPaginate": false
	    ,"bSortClasses": false
	    ,"bScrollCollapse": true
	    ,"sDom": 'fpti'
	    ,aaSorting: [] 
		  ,"aoColumns": [   { }
		                  , { "sType":"dollar", "bSearchable": false }
		                  , { "sType":"dollar", "bSearchable": false  }
		                  , { "sType":"dollar", "bSearchable": false }
		                  , { "sType":"dollar", "bSearchable": false }
		                  ]
	  }).fnSetFilteringDelay();

	new FixedHeader ( mydatagrid );
	
  getCSVData = function() {
    $("#csv_text").val( $('#datagrid').table2CSV() ); 
    $("#csv_file_name").val( $('title').text() + ' - ' + new Date().toDateString() + '.csv' );
    $("#csv_form").submit();
  }
    
	$('#datagrid tr').hover (
	  function() { $(this).addClass("over"); },
	  function() { $(this).removeClass("over"); }
	);  
});
</script>
</body>
</html>
