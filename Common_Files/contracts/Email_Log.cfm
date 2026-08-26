<!-----------------------------------------------------------------------------

FILE NAME:		Email_Log.cfm
DESCRIPTION:
CREATED BY:		Anand Rao/09-Jun-2016
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	09-Jun-2016	Created

------------------------------------------------------------------------------>
<HTML>
<HEAD>
	<TITLE>Accrual data viewer</TITLE>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<style>
		h2 {
			background-color: #FFCE84;
			height: 26px;
			line-height: 26px;
			border-top:1px solid black;
			border-bottom:1px solid black;
			padding-left: 7px;
			font-size: 1.3em;
		}
	</style>
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<script>
	
function  fnDownload(filename)
{
 	window.open(filename,"Letter_Download","location=1,status=1,scrollbars=1,resizable=1,width=400,left=0,height=300");
	return false; 
}
 
function  showMessage(Message_Log_ID)
{
 	window.open("showEmailMessage.cfm?Message_Log_ID=" + Message_Log_ID,"Letter_Download","location=1,status=1,scrollbars=1,resizable=1,width=400,left=0,height=300");
	return false; 
}
	</script>
</HEAD>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.3">
<cfinclude template="/common_files/dataTables.cfm">
   
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/numeral.min.js">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.calculation.js"/>
 
<cfset objProgram = createObject("component", "components.programs.Program") />
<cfset qGetProgramData = objProgram.getProgramInfo(url.ContractId) />
 
<BODY>

<cfoutput>
<table border="0" width="100%" cellpadding="0" cellspacing="0">
	<tr>
		<td>
			<table border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td colspan="100%" bgcolor="">
						<cfinclude template="#Application.Doc_Mapping#/data_files/created/#application.returned_customer_setting.qry_customer_name_font_start#">
						#application.returned_customer_setting.company_name#</DIV>
						<B><font size="+1" color="Navy">Email Log - [#qGetProgramData.Contract_Number#] - #qGetProgramData.Contract_Title#</FONT></B>
					</td>
				</tr>
			</table>
		</td>
		<td align="right" valign="top">
			<CF_smallLink
				title = "close window"
				url = "JavaScript:window.close();"
				parameters = ""
			>
		</td>
	</tr>
</table>
<br>
<table id="datagridEmailLog" class="datagrid" >
  	<col width="4%">  	<!--- id --->
	<col width="10%"> 	<!--- Type Letter/Claims Rates Report --->  
	<col width="16%">  	<!--- From --->
	<col width="16%">  	<!--- To --->
	<col width="20%">  	<!--- Subject --->
	<col width="6%">  	<!--- Message --->
	<col width="8%">  	<!--- Attachments --->
	<col width="8%">  	<!--- Date/Time  --->
	<col width="12%">	<!--- Program Version --->
  <thead>
  <tr>
	 <th>ID</th>
     <th>Type </th>
     <th>From</th>
     <th>To</th>
     <th>Subject</th>
     <th>Message</th>
     <th>Attachments</th>
     <th>Data/Time</th>
     <th>Program<br>Version</th>
  </tr>
  <!--- column filters --->
  <tr id="filter">
	<th>&nbsp;</th>
	<th><select name="filter_Type" class="drpDownWidth">
							<option value="">All</option>
							<option>Letters</option>
							<option>Claim Rates</option>
							<cfif appSettings.getDisplayQuoteLetter() eq 0 and appSettings.getlettersavailable() neq 4 and appSettings.getExternal_Contacts() neq 0>
							<option>Claim Rates & Letters</option>
							</cfif>
						</select></th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th align="center">&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
	<th>&nbsp;</th>
  </tr> 
  </thead>
  <tbody>
  </tbody>
</table>
  
<form name="frmSearchCriteria" action="Email_Log_data.cfm" method="post">
	<input type="hidden" name="contractId" value="#url.ContractId#">
</form>

</cfoutput>

<script>
var gridHeightAdjustment =  180;
var jTable = $("#datagridEmailLog");
var heightDiff = (Math.floor($(window).height()) - Math.floor(jTable.offset().top))

 var mydatagrid = jTable.show().dataTable({
	aaSorting: [ [2, 'asc'] ] 
	,"aoColumns": [ 
				{"bSortable":true}
				,{ "bSortable": false }
				,{ "bSortable": true }
				,{ "bSortable": true} 
				,{ "bSortable": true} 
				,{ "bSortable": false}
				,{ "bSortable": false}
				,{ "bSortable": true}
				,{ "bSortable": true}
				]
	,"bAutoWidth": false
	,"bProcessing": true
	,"bServerSide": true
	,"bSortClasses": false
	,"bScrollCollapse": true		/* true to put the footer of the grid just below the records, when there are a few records only */
	,"iDisplayLength": 10
	,"bSortCellsTop": true	
	,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
	,"sAjaxSource": "ajax/Email_Log_data.cfm"
	,"sDom": 'ftipr'
	,"sServerMethod": "POST"
	,"sScrollY" : (heightDiff - gridHeightAdjustment)<!--- data grid height --->
	,"fnServerParams": function ( aoData ) {	
		 <cfoutput>
			aoData.push( { "name": "contractId", "value": '#contractId#' } );
		 </cfoutput>
		}
	,"fnServerData": function ( sSource, aoData, fnCallback ) {
		 $.ajax( {   "dataType": 'json'
				 , "type": "POST"
				 , "url": sSource
				 , "data": aoData
				 , "success": function(json) { var $tfoot = $('div.dataTables_scrollFootInner');
										 fnCallback(json); }
		 } );
		}
	}).fnSetFilteringDelay();

	/* The default minimum scrollable height of a datagrid is around "300px". We need to reduce the minimum height, so that 
	the footer (total row OR "showing x of y entries" message) at the bottom of the grid can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/
	$('.dataTables_scrollBody').css('min-height', '30px');

	/* The default minimum height of a datagrid is around "300px". We need to reduce the minimum height, so that 
	the links (if any) at the bottom of the grid can can be placed just below the grid records,
	rather than there being a big gap between the two, when there are one or just a few records.
	*/	
	$('.dataTables_wrapper').css('min-height', '30px');


/* set up column filter */
$("#filter th").each( function ( i ) {
    $('select', this).change( function (e) {
		mydatagrid.fnFilter( $(this).val(), i );
    });
});
 
</script>
</BODY>
</HTML>