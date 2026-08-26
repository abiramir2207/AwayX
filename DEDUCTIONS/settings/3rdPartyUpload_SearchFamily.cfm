<!--- ------------------------------------------------------------------------------ 
     Template: \DEDUCTIONS\settings\3rdPartyUpload_SearchFamily.cfm
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

<font color="##000066" size="2">Search Family  :: Select Default Payee #</font> 
<hr color="navy">

<!--- ------------------------------------------------------------------------------ --->
<cfquery name="vars.qDistributor_Family" datasource="#application.datasource#">
	select Distributor_Family.Family_Name,Distributor_Family.Family_ID,BB_III_Upload_Default_Dist.Distributor_ID,BSA_Foodservice_Customers.Name,BSA_Foodservice_Customers.Ship_To
	from Distributor_Family 
	left Join BB_III_Upload_Default_Dist on Distributor_Family.Family_ID = BB_III_Upload_Default_Dist.Family_ID and BB_III_Upload_Default_Dist.Deleted = 0
	left Join BSA_Foodservice_Customers on BB_III_Upload_Default_Dist.Distributor_ID=BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
	where Distributor_Family.Deleted = 0
</cfquery>

<cfset useLakebaseForqSelected = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_iii_upload_default_dist")>
<cfif useLakebaseForqSelected>
<cftry>
<cfset vars.qSelected = application.oLakebase.toQuery(
application.oLakebase.selectRows("bb_iii_upload_default_dist", {
"select" = "family_id,distributor_id"
}),
"family_id,distributor_id"
)>
<cfcatch type="any">
<cfset useLakebaseForqSelected = false>
</cfcatch>
</cftry>
</cfif>
<cfif NOT useLakebaseForqSelected><cfquery name="vars.qSelected" datasource="#application.datasource#">
	SELECT Family_ID,Distributor_ID
	FROM BB_III_Upload_Default_Dist
</cfquery>
</cfif>
<cfset vars.selected_list = ValueList(vars.qSelected.Family_ID)>

<!--- ------------------------------------------------------------------------------ --->
<form name="Billback_3rdSingleIV_SearchFamily" method="post" action="3rdPartyUpload_SearchFamily.cfm">
<div id="datatable">
<table id="DistributorFamily" class="datagrid">
	<thead>
		<tr>
			<th></th>
			<th>Family Name</th>
			<th>Default Payee #</th>
			<th>Ship To</th>
		</tr>
	</thead>
<tbody>

<cfsetting enablecfoutputonly="true">
<cfloop query="vars.qDistributor_Family">
	<cfoutput><tr></cfoutput>
		<cfoutput><td align="center" nowrap><Font color="red">[ </font><A HREF="3rdPartyUpload_DefaultPayee.cfm?Family_ID=#vars.qDistributor_Family.Family_ID#">select default payee ##</A><Font color="red"> ]</font></td></cfoutput>
		<cfoutput><td>#vars.qDistributor_Family.Family_Name#</td></cfoutput>
		<cfoutput><td><cfif len(#vars.qDistributor_Family.Name#) GT 0 >#vars.qDistributor_Family.Name#</cfif></td></cfoutput>
		<cfoutput><td nowrap><cfif len(#vars.qDistributor_Family.Ship_To#) GT 0 >#vars.qDistributor_Family.Ship_To#</cfif></td></cfoutput>
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

var grid = $('#DistributorFamily').dataTable({
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


$('table#DistributorFamily tr').hover (
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
