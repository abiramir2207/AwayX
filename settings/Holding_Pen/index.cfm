<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Holding_Pen\index.cfm
      Date:     26-Aug-2014
      Author:   Anand Rao
      Purpose:  Manage Holding Pen

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="FORM.command" default="" />
<cfparam name="FORM.delAction" default="0" />
<cfparam name="FORM.IdToDel" default="0" />
<!--- "GO" link is clicked to refresh the Holding Pen --->

<style>
.intSetting {
  padding-right: 25px;
  /*width: 50%;*/
  height: 20px;
  line-height:250%;
  vertical-align:middle;
}
.tdHeight {
  height: 20px;
  line-height:100%;
  vertical-align:middle;
}
</style>

 <CFSET URL.PageTitle="HOLDING PEN">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<cfset holdingPenManager = CreateObject("component", "mvc.Models.Settings.HoldingPenManager") />

<cfset III_P_Upload_Use_Holding_Pen = createObject("component", "components.billback.BillbackSettingsManager").getBBUploadedTypeLabels().III_P_Upload_Use_Holding_Pen />
	
<!--- Check to see if the delete action is 1 and the IdToDel is not 0 --->
<cfif FORM.delAction EQ "1" AND IdToDel NEQ "0">
	<cfset temp = holdingPenManager.delHoldingPenRec(request.accessstructure.user_ID,FORM.IdToDel) />
</cfif>

<cfif FORM.command EQ "ActionGo">

<!--- 	<cfstoredproc procedure = "Upload_BB_Hold_Validate" dataSource="#application.datasource#">
	 	<cfprocparam type="in" cfsqltype = "cf_sql_integer" value="2" dbVarName = "@called_from">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar"	value="#request.AccessStructure.User_ID#" dbvarname="@user_id">
		<cfprocresult name = qryResult>
	</cfstoredproc> --->
	<cfif III_P_Upload_Use_Holding_Pen EQ 1>

		<cfquery name="qryResult" datasource="#application.datasource#">
			EXEC Upload_III_Party_Hold_Validate 2, '#request.AccessStructure.User_ID#'
		</cfquery>
		
	</cfif>

	<cfquery name="qryResult" datasource="#application.datasource#">
		EXEC Upload_BB_Hold_Validate 2, '#request.AccessStructure.User_ID#'
	</cfquery>
	
	
</cfif>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


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

<SCRIPT LANGUAGE="JavaScript" SRC="/settings/Holding_Pen/holdingPen.js?ver=10"></SCRIPT>

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm"] )#>

<script>
	function toggleInterface(){
			$.ajax({
							async: false
							,data: { 	method: "toggleInterface" }
							//,dataType: "json"
							,success: function (data) {
								getInterfaceOn();
					           
					        	var interfaceIsOn = $("#interfaceOn").attr('checked');
					        	if(interfaceIsOn == 'checked'){ s = 'The 700 Interface has been set to INCLUDE 3000 Rebate Intake data.';}
					        	else{s = 'The 700 Interface has been set to IGNORE 3000 Rebate Intake data.';}
								alert(s);
					          	
				            }
				            ,error: function (data) {
				            	// console.log(data);
				                alert('An error occurred (toggleInterface).  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Settings/HoldingPenManager.cfc"
				});
		}

	function getInterfaceOn(){
		//var interfaceIsOn = $("#interfaceOn").val();
		//alert(interfaceIsOn);
			$.ajax({
							async: false
							,data: { method: "getInterfaceOn" }
							//,dataType: "json"
							,success: function (data) {
					            //s = JSON.parse(data);
					             s = data;
					            // alert(s);
					            //$("#interfaceOn").val(data);
					            if(s==1){ b=true;}
					            else{b=false;}
					            $("#interfaceOn").prop( "checked", b );     	
				            }
				            ,error: function (data) {
				            	// console.log(data);
				                alert('An error occurred (toggleInterface).  ' + JSON.stringify(data) );
				            }
							,type: "post"
							,url: "/mvc/Models/Settings/HoldingPenManager.cfc"
				});
		}

		document.addEventListener("DOMContentLoaded", function () {
	        getInterfaceOn();
	    });
</script>

<form name="frmAction" method="post" action="index.cfm"> 

<div style="margin:0 0 5px 0;text-align:right;float:right;width:550;display: inline-block;">
	<cfoutput>	
	<table border = 0>
		<tr>
			
			<td class="tdHeight">
				<a href="##" onclick="javascript:PopupCenter('downloadFile.cfm?fileParam=IgnoreReport','IgnoreReport','450','200');">#application.util.string.actionLinkFormat("Ignored rows Report")#</a>
			</td>
			<td class="tdHeight">
	   <!--- <a href="##" onclick="javascript:window.open('downloadFile.cfm?fileParam=Snapshot','Report_Download','width=400,height=300,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Snapshot")#</a>   --->
			<a href="##" onclick="javascript:PopupCenter('downloadFile.cfm?fileParam=Snapshot','Snapshot','450','200');">#application.util.string.actionLinkFormat("Snapshot")#</a>
			</td>
		<cfif (variables.inEditMode EQ 1)>
			<td class="tdHeight">	
				<!--- <a href="##" onclick="javascript:window.open('downloadFile.cfm?fileParam=Download&uploadType=#qHoldingpen.Upload_Type#','Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Download")#</a> ---> 
				<a href="##" onclick="javascript:PopupCenter('downloadFile.cfm?fileParam=Download&uploadType=#qHoldingpen.Upload_Type#','Download','450','200');">#application.util.string.actionLinkFormat("Download")#</a> 
			</td>
			<cfif (appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 0)> <!--- III_P_Upload_Use_Holding_Pen EQ 1 AND --->
			<td class="tdHeight">
				<a href="##" onclick="javascript:window.open('uploadFile.cfm?fileParam=upload','Upload','width=600,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Upload")#</a>
			</td>
			</cfif>
			<td class="tdHeight">
				<cfif variables.processing EQ 0>
					<div id="goLink" style="display:block">
				  		<a href="##" onclick="javascript:submitGo();">#application.util.string.actionLinkFormat("Go")#</a>
					</div>
				<cfelse>
					<img src="/images/loading_red.gif"> processing...</font>
				</cfif>
				<div id="goLinkProcessing" style="display:none">
					<font color="grey"><img src="/images/loading_red.gif"> processing...</font>
				</div>
			</td>
			<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1>
				<td class="intSetting">
					<cfif (variables.inEditMode EQ 1)>
						<a href="##" onclick="javascript:toggleInterface()"><b><font color='red'>[ </font> 700 Interface is ON: </a><input type="checkbox" name="interfaceOn" id="interfaceOn" onclick="javascript:toggleInterface()"><font color='red'> ]</font></b>
				 	</cfif>
				</td>
			</cfif>
		</cfif>
		</tr>
		</table>		
	</cfoutput>
</div>

<cfset variables.columnSizes = [0.75, 1.25, 1.0, 1.0, 0.75, 0.75, 1.0, 1.0, 0.50, 5.2,.50, .30]>
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
		<th>Total <br>Invoices</th>
      	<th>Item <br>Alias</th>
		<th>Distributor <br>Alias</th>
		<th>Operator <br>Alias</th>
		<th>No Program <br>Found</th>
		<th>Report</th>			
      	<th>File Name</th>
		<th>Delete</th>	
		<th>Report Log</th>
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
					<a href="##" onclick="javascript:window.open('downloadFile.cfm?fileParam=Report&BBUploadHoldScorecardID=#qHoldingpen.BB_Upload_Hold_Scorecard_ID#&UploadID=#qHoldingpen.Upload_ID#&UploadType=#qHoldingpen.Upload_Type#','Report_Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#application.util.string.actionLinkFormat("Report")#</a> 
				</td> 
				<td>
					<cfif ((qHoldingpen.Source EQ "SYSCO") OR (qHoldingpen.Source EQ "USFS" ) OR (qHoldingpen.Source EQ "BEK") OR (qHoldingpen.Source EQ "PFG") OR (qHoldingpen.Upload_Type EQ "2") OR (qHoldingpen.Source EQ "3rd Party" AND III_P_Upload_Use_Holding_Pen EQ 1))>
						<a href="##" title="#qHoldingpen.FileName#" onclick="javascript:window.open('downloadFile.cfm?fileParam=RFDownload&BBUploadHoldScorecardID=#qHoldingpen.BB_Upload_Hold_Scorecard_ID#&uploadType=#qHoldingpen.Upload_Type#','Report_Download','width=300,height=200,location=1,status=1,scrollbars=1,resizable=1');return false;">#qHoldingpen.FileName#</a> 
					<cfelse>
						#qHoldingpen.FileName#
					</cfif>		
				</td>
				<td>
					<cfif (qHoldingpen.Upload_Type EQ "2")>
						<a href="" onClick="JavaScript: return delHoldingPenRec('#qHoldingpen.BB_Upload_Hold_Scorecard_ID#');"><img src="/images/no_small.gif" TITLE="Delete " BORDER="0"></a>
					</cfif>
				</td>
				<td align="center">
					<a href="##" title="Report Download Log" onclick="javascript:window.open('reportDownloadLog.cfm?BBUploadHoldScorecardID=#qHoldingpen.BB_Upload_Hold_Scorecard_ID#&UploadID=#qHoldingpen.Upload_ID#','Report_Download_Log','width=400,height=250,location=1,status=1,scrollbars=1,resizable=1');return false;"><img src="/images/download_report_small.png" TITLE="Report Download Log" BORDER="0"></a>
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
<input name="delAction" id="delAction" type="hidden" value="#FORM.delAction#" />
<input name="IdToDel" id="IdToDel" type="hidden" value="#FORM.IdToDel#" />
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
										  ,{"bSortable":false,"bSearchable":false}
										  ,{"bSortable":false,"bSearchable":false}
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

		document.getElementById('goLink').style.display='none';
		document.getElementById('goLinkProcessing').style.display='block';
		document.frmAction.command.value = "ActionGo";
		document.frmAction.submit();	
		return false;
}

function delHoldingPenRec(BBUploadHoldScorecardID)
{
	var actionFrm = document.frmAction;

	if(confirm("Do you really want to delete the selected Record?"))
	{
		actionFrm.delAction.value = '1';
		actionFrm.IdToDel.value = BBUploadHoldScorecardID;
		actionFrm.submit();
		return false;
	}

	return false;
}

</script>



