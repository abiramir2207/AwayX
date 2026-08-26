<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Holding_Pen\index.cfm
      Date:     26-Aug-2014
      Author:   Anand Rao
      Purpose:  Manage Holding Pen

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="FORM.command" default="" />
<!--- "GO" link is clicked to refresh the Holding Pen --->

 <CFSET URL.PageTitle="HOLDING PEN">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">


<cfif FORM.command EQ "ActionGo">
	<cfstoredproc procedure = "Upload_BB_Hold_Validate" dataSource="#application.datasource#">
	 	<cfprocparam type="in" cfsqltype = "cf_sql_integer" value="2" dbVarName = "@called_from">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar"	value="#request.AccessStructure.User_ID#" dbvarname="@user_id">
		<cfprocresult name = qryResult>
	</cfstoredproc>
</cfif>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset holdingPenManager = CreateObject("component", "mvc.Models.Settings.HoldingPenManager") />

<cfset qHoldingpen = holdingPenManager.getHoldingPenData() />
<cfif isDefined("URL.lockUnlock")>
	<!--- 1 = lock; 0 = unlock --->
	<cfif URL.lockUnlock>
		<cfset temp = holdingPenManager.lockHoldingPenPage(request.accessstructure.user_ID) />
	<cfelse>
		<cfset temp = holdingPenManager.unlockHoldingPenPage() />
	</cfif>
</cfif>

<cfinclude template="holdingPen_Lock_Unlock.cfm" />
 
<SCRIPT LANGUAGE="JavaScript" SRC="holdingPen.js"></SCRIPT>

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<form name="frmAction" method="post" action="index.cfm"> 

<div style="margin:0 0 5px 0;text-align:right;">

<cfoutput>	
   	<a href="##" onclick="javascript:window.open('downloadFile.cfm?fileParam=Snapshot','Report_Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Snapshot")#</a>
	<cfif (variables.inEditMode EQ 1)>
	   	<a href="##" onclick="javascript:window.open('downloadFile.cfm?fileParam=Download','Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Download")#</a>
		<a href="##" onclick="javascript:window.open('uploadFile.cfm?fileParam=upload','Upload','width=600,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Upload")#</a>
  		<a href="##" onclick="javascript:submitGo();">#application.util.string.actionLinkFormat("Go")#</a>
	</cfif>
</cfoutput>
</div>

<cfset variables.columnSizes = [1, 1.5, 1.25, 1.5, 1.25, 1.5, 1.5, 1.5, 2.50, 0.50]>
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>
 
 
<table id="datagrid" class="datagrid" style='table-layout:fixed;width:100%;'>
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
  <cfoutput>
	<thead>
    <tr>
		<th>Batch</th>
      	<th>Batch Date</th>
		<th>Source</th>
		<th>Total Invoices</th>
      	<th>Item Alias</th>
		<th>Distributor Alias</th>
		<th>Operator Alias</th>
		<th>No Program Found</th>
      	<th>File Name</th>	
		<th>Report</th>	
    </tr>
  </thead>
  </cfoutput>

  <!--- stuff the content of tbody into a variable so we can remove extra white space easily --->
  <cfsavecontent variable="variables.tbody">
		<cfoutput query="qHoldingpen">
			<tr>
				<td>#qHoldingpen.Upload_ID#</td>
				<td>#dateformat(qHoldingpen.Upload_Date, 'mmm d, yyyy')#</td>
				<td>#qHoldingpen.Source#</td>
				<td>#qHoldingpen.Total_Invoices#</td>
				<td>#qHoldingpen.Item_Alias_Count#</td>
				<td>#qHoldingpen.Distributor_Alias_Count#</td>
				<td>#qHoldingpen.Operator_Alias_Count#</td>
				<td>#qHoldingpen.Invalid_Program_Count#</td> 
				<td>
					<cfif ((qHoldingpen.Source EQ "SYSCO") OR (qHoldingpen.Source EQ "USFS"))>
						<a href="##" onclick="javascript:window.open('downloadFile.cfm?fileParam=RFDownload&BBUploadHoldScorecardID=#qHoldingpen.BB_Upload_Hold_Scorecard_ID#','Report_Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#qHoldingpen.FileName#</a> 
					<cfelse>
						#qHoldingpen.FileName#
					</cfif>		
				</td>
				<td>
					<a href="##" onclick="javascript:window.open('downloadFile.cfm?fileParam=Report&UploadID=#qHoldingpen.Upload_ID#','Report_Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Report")#</a>
				</td>
			</tr>
		</cfoutput>
	</cfsavecontent>
	<tbody>
		<cfoutput>#application.util.string.compress(variables.tbody)#</cfoutput>
	</tbody>
</table>

<cfoutput>				
<input name="command" id="command" type="hidden" value="#FORM.command#" />
</cfoutput>
				
</form>
<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">

<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
$(function() {
  var mydatagrid = $('#datagrid').show().dataTable({
       aaSorting: []
      ,"bAutoWidth": false
      ,"bPaginate": true
      ,"iDisplayLength": 250
      ,"sDom": 'fptipr'
      ,"bSortClasses": false
      ,"bScrollCollapse": false
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"aoColumns": [
										   {"bSortable":true, "bSearchable":true}
										  ,{"bSortable":true, "bSearchable":true}
										  ,{"bSortable":true, "bSearchable":true}
										  ,{"bSortable":true, "bSearchable":true}
										  ,{"bSortable":true, "bSearchable":true}
										  ,{"bSortable":true, "bSearchable":true}
										  ,{"bSortable":true, "bSearchable":true}
										  ,{"bSortable":true, "bSearchable":true}
										  ,{"bSortable":true, "bSearchable":true}
										  ,{"bSortable":false,"bSearchable":true}
      							]
    }).fnSetFilteringDelay();

});
$('#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
$('#datagrid tbody').on('click', 'td', function(e) {
 if ( $(e.target).prop('checked') ) {
  var all_checked = 1;
  $('.toggle_one').each(function() {    <!---are all single toggle checked?--->
    if ( !$(this).prop('checked') ) {   <!---found one single toggle unchecked--->
       all_checked = 0;
       return false;
    }
  });
  $('#toggle_all').prop('checked', all_checked == 1 );
 }
 else {
      $('#toggle_all').prop('checked', false );   <!---at least one single toggle is unchecked so uncheck toggle all--->
 }
 });
$('#toggle_all').click(function(e){      <!---listen for click event on toggle all--->
  e.stopPropagation();
  $('.toggle_one').prop('checked', this.checked );
});


function submitGo()
{
		document.frmAction.command.value = "ActionGo";
		document.frmAction.submit();	
}
</script>



