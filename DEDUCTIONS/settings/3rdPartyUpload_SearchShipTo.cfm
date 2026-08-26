<!--- ------------------------------------------------------------------------------ 
     Template: \DEDUCTIONS\settings\3rdPartyUpload_SearchShipTo.cfm
      Date:     
      Updated By:   
      Purpose:  
------------------------------------------------------------------------------ --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title></title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style type="text/css" media=screen>
.action { font-size: 8pt; font-weight:bold; margin:10px 0 10px 0; }
.action label { margin:0 10px 0 30px; }
.action select { position:relative; top:2px; }
.dollar { text-align:right; }
.mid { text-align: center; }
.moveup { margin-top:-5px; }
#budget_form { margin:15px; }
#datatable { margin-top:15px; }
#mainfieldset { margin:0px 0; padding:0 1em .5em; border:0 none; border-top:#cccccc 1px solid; }
#mainfieldset legend { margin:0.5em; padding:0 1.5em; background:transparent; color:#003366; font-size:1.1em; font-weight:bold; }
#segments { margin-left:15px; }
div.save { margin-top:10px; }
ul, li { display:inline; }
ul { margin:0; list-style-type:none; }
li { border:solid 1px white; padding:5px; margin:5px; background-color:white; font-weight:normal; }
</style>
</head>
<body>
<font color="##000066" size="2">Search <cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput>  :: Select Default Payee #</font> 
<hr color="navy">

<!--- ------------------------------------------------------------------------------ --->
<cfquery name="vars.qDistributor" datasource="#application.datasource#">
	SELECT	BSA_Foodservice_Customers.Name,
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
			BB_III_Upload_Default_Dist.Distributor_ID,
			BSA_Foodservice_Customers.Ship_To,
			BSA_Foodservice_Customers.Family_ID
	FROM	BSA_Foodservice_Customers
			LEFT JOIN BB_III_Upload_Default_Dist ON BB_III_Upload_Default_Dist.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID AND BB_III_Upload_Default_Dist.Deleted = 0
	WHERE 	BSA_Foodservice_Customers.Deleted = 0
	AND		Ship_To <> 'Group'
</cfquery>

<cfset useLakebaseForqSelected = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_iii_upload_default_dist")>
<cfif useLakebaseForqSelected>
<cftry>
<cfset vars.qSelected = application.oLakebase.toQuery(
application.oLakebase.selectRows("bb_iii_upload_default_dist", {
"select" = "distributor_id",
"deleted" = "eq.0",
"ship_to_level" = "eq.1"
}),
"distributor_id"
)>
<cfcatch type="any">
<cfset useLakebaseForqSelected = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForqSelected><cfquery name="vars.qSelected" datasource="#application.datasource#">
	SELECT	Distributor_ID
	FROM 	BB_III_Upload_Default_Dist
	WHERE	Deleted = 0
	AND		Ship_To_Level = 1
</cfquery>
</cfif>
<cfset vars.selected_list = ValueList(vars.qSelected.Distributor_ID)>

<!--- ------------------------------------------------------------------------------ --->
<form name="Billback_3rdSingleIV_SearchShipTo" method="post" action="3rdPartyUpload_SearchShipTo.cfm">
<div id="datatable">
<table id="Distributor" class="datagrid">
	<thead>
		<tr>
			<th></th>
			<th><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput> Name</th>
			<th>Default Payee #</th>
			<th><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput></th>
		</tr>
	</thead>
<tbody>

<cfsetting enablecfoutputonly="true">
<cfloop query="vars.qDistributor">
	<cfoutput><tr></cfoutput>
		<cfoutput><td align="center" nowrap><Font color="red">[ </font><A HREF="3rdPartyUpload_DefaultPayeeShipTo.cfm?ShipTO=#vars.qDistributor.Ship_To#&Customers_ID=#BSA_Foodservice_Customers_ID#">select default payee ##</A><Font color="red"> ]</font></td></cfoutput>
		<cfoutput><td>#vars.qDistributor.Name#</td></cfoutput>
		<cfoutput><td><cfif len(#vars.qDistributor.Name#) GT 0 >#vars.qDistributor.Name#</cfif></td></cfoutput>
		<cfoutput><td nowrap><cfif len(#vars.qDistributor.Ship_To#) GT 0 >#vars.qDistributor.Ship_To#</cfif></td></cfoutput>
	<cfoutput></tr></cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="false">
</tbody>
</table>
</div>   <!---datatable--->
</form>

<!--- ------------------------------------------------------------------------------ --->
<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.6.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript">
var budget_form = "budget_form";
<!---adjust main fieldset width when user's resolution is too low--->
$('#mainfieldset').css('width', ($(window).width() <= 700) ? "600px" : "98%");

  var column_sizes = ["20%", "32%","32%","16%"];

var grid = $('#Distributor').dataTable({
	 "bAutoWidth": true
	,"bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fti<"save">'
  ,"sScrollXInner": "100%"
  <!---,"sScrollY": "100%"--->
  ,"aaSorting": [[ 1, "asc" ]] <!---default sorting on code column--->
  ,"aoColumns": [
                  {"sWidth": column_sizes[0], "bSortable":false, "bSearchable":false },
                    {"sWidth": column_sizes[1]}
                  , {"sWidth": column_sizes[2]}
 				  , {"sWidth": column_sizes[3]}
                  ]
}).fnSetFilteringDelay();


$('table#Distributor tr').hover (
  function() { $(this).addClass("over"); },
  function() { $(this).removeClass("over"); }
);
<!---events for toggle all checkbox------------------------------------------------------------------------------------>
var $checkboxes = $('.cb');               <!---the other checkboxes--->
$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
 $checkboxes.prop('checked', ( this.checked ) ? true : false );
 e.stopPropagation();
});

</script>
</body>
</html>
