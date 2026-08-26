<!--- BB_Auto_Report_Growth_Calc_Details.cfm --->

<!---------------------------------------------------------------------------------------------------------------------
      Template: \Program_Wizard\index.cfm
      Date:     2013 April
      Author:   Chris Nguyen
      Purpose:  List program templates & allow users to manage them

      Remarks:
----------------------------------------------------------------------------------------------------------------------->

<cfparam name="url.ReportID" default="0">
<cfparam name="form.save_action" default="0">
<cfparam name="form.BB_Auto_Growth_Calc_ID_List" default="0">

<cfif form.save_action eq "save_changes" or form.save_action eq "restore_original">
	<cfif form.save_action eq "save_changes">
		<cfset application.oBBReportUpdate.SaveGrowthCalcChanges(
					url.ReportID, 
					form.BB_Auto_Growth_Calc_ID_List, 
					form, 
					request.accessStructure.User_Id) />
	<cfelseif form.save_action eq "restore_original">
		<cfset application.oBBReportUpdate.RestoreGrowthCalcChanges(
					url.ReportID, 
					form.BB_Auto_Growth_Calc_ID_List, 
					request.accessStructure.User_Id) />
	</cfif>
	<!------ Close the window ----->
	<script>		
		window.opener.location.reload();
		window.close();
	</script>
	<cfabort>
</cfif>

<!DOCTYPE HTML>
<cfinclude template="/actionFormat.cfm">
<html>
<head>
  <title>Growth Calculation Details</title>
  <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  <style>
  #createnew-div { margin:0px 0; float:right; position:relative; top:5px; }
  #createnew-div select { margin:0 8px 0 0; }
  #datagrid2 { margin-top:-15px; }
  #generictypefilter { width:225px; }
  .datagrid TBODY TR.even { BACKGROUND-COLOR: #eeffee }
  .actiontd { padding-left: 30px; }
  .action { margin:0 8px; }
  .blank { margin-right:55px; }
  .activate { background-color: #FFDEAD; }
  #generictypefilter { width: 98%; }
.rowHead {
	font-family: Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	font-weight: bold;
	color: #000099;
	text-align: left;
	border-bottom-color: #990000;
	background-color: #ffce84;
	
	border-top-width: 1px;
	border-right-width: 1px;
	border-bottom-width: 1px;
	border-left-width: 1px;
	border-top-style: none;
	border-right-style: solid;
	border-bottom-style: solid;
	border-left-style: none;
}
 .colHead {
	border-top-width: 1px;
	border-right-width: 1px;
	border-bottom-width: 1px;
	border-left-width: 1px;
	border-top-style: none;
	border-right-style: solid;
	border-bottom-style: solid;
	border-left-style: none;
}
  </style>
</head>
<body>
	
<cfset qGetGrowthCalc = application.oBBReportGet.getGrowthCalc(URL.ReportID, URL.ReportLevel, URL.billback_id)>
<cfset qGetPeriod	= application.oBBReportGet.getReportPeriod(URL.ReportID) />
<cfquery dbtype="query" name="qGrowthCalID">
	SELECT 	DISTINCT BB_Auto_Growth_Calc_ID
	FROM	qGetGrowthCalc
</cfquery>
<table border="0" cellspacing="0" cellpadding="3" width="100%">
<thead>
  <tr height="25">
  	<cfif application.oBBReportGet.getAutoPayType() EQ 2>
		<!--- Auto Pay Lite --->
		<td class="rowHead" nowrap>Title</td>
	<cfelse>
		<!--- Full auto pay --->
		<td class="rowHead" nowrap>Period</td>
	</cfif>
		<td class="rowHead" nowrap>Report Id</td>
		<td class="rowHead" width="80">Status</td>
  </tr>
</thead>
  <tr>
	<CFOUTPUT>
	<cfif application.oBBReportGet.getAutoPayType() EQ 2>
		<!--- Auto Pay Lite --->
		<td class="colHead">#qgetPeriod.Report_Title#</td>
	<cfelse>
		<!--- Full auto pay --->
		<td class="colHead">#dateFormat(qgetPeriod.end_date,"mmmm yy")#</td>
	</cfif>
	
	<td class="colHead">#qgetPeriod.BB_Auto_Report_id#</td>
	<td class="colHead">#application.oBBReportGet.getReportStatus(status = qgetPeriod.status,
									   pause	= qgetPeriod.Pause_Schedule)#</td>   
	</CFOUTPUT>
  </tr>
</table>

<cfif qGetGrowthCalc.recordCount EQ 0>
	No growth exceptions data found
	<cfabort>
</cfif>
<cfset iOverride = 0 />
<br>
<div align="right">
<cfoutput>
	<cfif qgetPeriod.status LT 4>
	<a href="##" id="save_changes">#application.util.string.actionLinkFormat("save changes")#</a>
	<a href="##" id="restore_original">#application.util.string.actionLinkFormat("restore to actual")#</a>
	</cfif>
	<a href="##" id="close_window">#application.util.string.actionLinkFormat("close window")#</a>	
</cfoutput>
</div>
<br><br>
<form id="growth_form" action="#cgi.script_name#?ReportID=#url.ReportID#" method="post">
<input type="hidden" name="save_action" id="save_action" value="0">
<cfoutput>
<input type="hidden" name="BB_Auto_Growth_Calc_ID_List" value="#ValueList(qGrowthCalID.BB_Auto_Growth_Calc_ID)#">
</cfoutput>
<div id="datagrid2">
<table class="datagrid" id="datagrid"  style='table-layout:fixed'>
<col width="20%">
<col width="20%">
<col width="17%">
<col width="10%">
<col width="15%">
<col width="10%">
<col width="10%">
<thead>
<tr>
    <th align="left">Program</th>
    <th align="left">Billback</th>
	<th align="left">Growth calc</th>	
	<th align="left">Tier</th>
	<th align="left">Goals</th>
	<th align="left">Variance</th>
	<th align="left">Actual</th>
</tr>
</thead>
<tbody>
	<cfset variables.descriptionDisplayLength = 112>
	<cfoutput query="qGetGrowthCalc">
	<tr>
		<!--- Contract --->
		<td title="#Contract_Title#">#Contract_Number#<br>
		<cfif len(Contract_Title) lt variables.descriptionDisplayLength>
		  #Contract_Title#
		<cfelse>
		  #application.util.string.fullLeft(Contract_Title, variables.descriptionDisplayLength)# ...
		</cfif>
		</td>
		<!--- Billback --->
		<td title="#BB_Title#">#BB_Code#<br>
		<cfif len(BB_Title) lt variables.descriptionDisplayLength>
		  #BB_Title#
		<cfelse>
		  #application.util.string.fullLeft(BB_Title, variables.descriptionDisplayLength)# ...
		</cfif>
		</td>
		<!--- Payee --->
		<td><cfif Distributor_ID_Paid EQ "00000000-0000-0000-0000-000000000000">Program<cfelse>#Payee_ID#<br>#Payee_Name#</cfif></td>
		<!--- Tier --->		
		<td>
		<input type="radio" id="Select_Tier_#BB_Auto_Growth_Calc_ID#" name="Select_Tier_#BB_Auto_Growth_Calc_ID#" value="#Tier_Number#" <cfif Selected_Tier EQ Tier_Number>checked</cfif>>
		<cfif Tier_Number EQ 0>None<cfelse>Tier #Tier_Number#</cfif>
		<cfif Tier_Attained EQ Tier_Number>&nbsp;<img src="/images/yes_small.gif" align="middle" border="0" title="Actual Tier = #Tier_Number#" /></cfif>
		<cfif Selected_Tier NEQ Tier_Attained AND Selected_Tier EQ Tier_Number><img src="/images/positive.gif" align="middle" border="0" title="Close enough tier = #Tier_Number#" />
		<cfset iOverride = 1 />
		</cfif>
		</td>
		<td align="center">
		<!--- Tier Start/End --->		
		<cfif Tier_Number EQ 0>&nbsp;<cfelse>
		<cfif Component_UOM EQ 4>
		$#NumberFormat(New_Range_Start, ",")# - 
		<cfelse>
		#NumberFormat(New_Range_Start, ",")# #Component_UOM_Desc# -
		</cfif>
		<cfif New_Range_End EQ "*">#New_Range_End#<cfelse><cfif Component_UOM EQ 4>$#NumberFormat(New_Range_End, ",")#<cfelse>#NumberFormat(New_Range_End, ",")# #Component_UOM_Desc#</cfif></cfif>
		<cfif Original_Component_UOM EQ 3>
			<br>#NumberFormat(Range_Start, ",.00")#% -
			<cfif Range_End EQ "*">#Range_End#<cfelse>#NumberFormat(Range_End, ",")#%</cfif>
		</cfif>
		</cfif>
		</td>
		<!--- Variance --->
		<cfset Variance = 0 />
		<cfif Tier_Number NEQ 0 AND New_Range_Start neq 0>
			<cfset Variance = New_Range_Start - Component_Total />
			<cfset VariancePercent = (Variance / New_Range_Start) * 100 />
		</cfif>		
		<td align="right"><cfif Variance GT 0><cfif Component_UOM EQ 4>$#NumberFormat(Variance, ",")#<cfelse>#NumberFormat(Variance, ",")# #Component_UOM_Desc#</cfif><br>
		#NumberFormat(VariancePercent, ",")#%
		</cfif></td>
		<!--- Volume --->
		<td align="right">
			<cfif Component_UOM EQ 4>$#NumberFormat(Component_Total, ",")#<cfelse>#NumberFormat(Component_Total, ",")# #Component_UOM_Desc#</cfif>
		</td>
	</tr>
	</cfoutput>
</tbody>
</table>
</div>
</form>


<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
var oTable = $('table#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'dft'
    ,"aoColumns": [   {"bSortable":false, "bSearchable":true }
                    , {"bSortable":false,  "bSearchable":true}
                    , {"bSortable":false,  "bSearchable":true}
                    , {"bSortable":false,  "bSearchable":false}
                    , {"bSortable":false, "bSearchable":false} 
                    , {"bSortable":false, "bSearchable":false}                    
                    , {"bSortable":false, "bSearchable":false}
                  ]
  });

<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

$('#save_changes').click(function(e) {
	oTable.fnFilter( '', 1 );
 	oTable.fnFilter( '' );   // display hidden rows while saving, only displayed records will be saved
 	$('#save_action').val("save_changes");
 	$('#growth_form').submit();
});

$('#restore_original').click(function(e) {
	oTable.fnFilter( '', 1 );
 	oTable.fnFilter( '' );   // display hidden rows while saving, only displayed records will be saved
 	<cfif iOverride>
	$('#save_action').val("restore_original");
 	$('#growth_form').submit();
 	<cfelse>
	alert("Current tiers match actual tiers and reset is not required");
	</cfif>
});

$('#close_window').click(function(e) {
	window.close();
});

</script>
</body>
</html>