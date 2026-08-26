<!DOCTYPE HTML>
<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Planning_Groups\exportByDistributor.cfm
      Date:     2015 Mar
      Author:   Chris Nguyen
      Purpose:  Distributor selection

			Remarks:  - Use multiple pages due to large number of records in the system
					  - Selection is persistent between pages
					  - Column headers remain visible at all times
----------------------------------------------------------------------------------------------------------------------->
</cfsilent>
<html>
<head>
	<title>Export By Members</title>
</head>
<body>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<style>
#actions { margin:10px 0; }
#massapply { float:left; margin:15px 0 2px 0;}
#list221 { clear:both; margin-top:5px; }
form { margin:0; padding:0 }
.dropdown { width:50px; }
.action { margin-right:20px; }
.dataTables_paginate{margin-right:0px;}
table.datagrid select { width: 98%; }
div#msg55 p { font-size: 1.35em; margin:20px; padding:20px; background-color: #BDE5F8; letter-spacing:0.9px; }
</style>
<cfscript>
  dataCFC = createObject("component", "components.general.Profitability_Models");
</cfscript>


<cfoutput>
<cfif cgi.request_method eq "post">
	<cfsilent>
	    <cfset variables.webServerPath = "#application.doc_path#\data_files\created\settings\planning_groups\">
	    <!---create new folder to store Excel files --->
	    <cfif not DirectoryExists(variables.webServerPath)>
	        <cfdirectory directory = #variables.webServerPath# action = "create">
	    </cfif>

	    <cfscript>
	    	variables.isDebugging   = IsDebugMode() and 1;       // TODO: change 1 to 0 before checking in the code
	        variables.excelFile     = createUUID() & ".xlsx";    // create a unique file name
	        variables.dbServerPath = variables.webServerPath & variables.excelFile;

	        if ( findNoCase("C:", variables.dbServerPath) )
	            variables.dbServerPath  = "\\" & Application.WebServerName & replaceNoCase(variables.dbServerPath, "C:", "");
	        else if ( findNoCase("E:", variables.dbServerPath) )
	            variables.dbServerPath  = "\\" & Application.WebServerName & replaceNoCase(variables.dbServerPath, "E:", "");
			else if ( findNoCase("F:", variables.dbServerPath) )
	            variables.dbServerPath  = "\\" & Application.WebServerName & replaceNoCase(variables.dbServerPath, "F:", "");	
	        else
	            variables.dbServerPath  = "\\" & Application.WebServerName & replaceNoCase(variables.dbServerPath, "D:", "");
	    </cfscript>

	    <cfquery name="variables.getData" datasource="#application.datasource#">
	        IF Object_Id( 'tempdb..##tmp_pg_member') IS NOT NULL
	            DROP TABLE ##tmp_pg_member

	        CREATE TABLE ##tmp_pg_member (PG_Type VARCHAR( 20 ), Member_Id VARCHAR(250))

	        <!--- place all selected product IDs in a temp table to share with the stored procedure --->
	        <cfoutput>
	        <cfloop list="#form.checkedBoxes#" index="variables.singleDistributorID">
	            INSERT INTO ##tmp_pg_member VALUES ('distributor', '#variables.singleDistributorID#')
	        </cfloop>
	        </cfoutput>

	        <cfif variables.isDebugging>
				SELECT * FROM ##tmp_pg_member
			</cfif>
	        <cfoutput>EXEC USP_EXTRACT_PG_FOR_MEMBERS  @excel_result_file_name='#variables.excelFile#',  @excel_result_full_path='#variables.dbServerPath#'</cfoutput>
	    </cfquery>
	    <!--- <cfset variables.excelFile = "48055.xlsx"> --->
	</cfsilent>
	<cfif fileExists( variables.webServerPath & variables.excelFile )>
        <cfset variables.webServerPath = replace( variables.webServerPath, '\', '/', 'all' )>
	    <script>
	        window.close();    // close window with gathering info message
	        <cfoutput>window.open('/common_files/openContent.cfm?type=xls&fileName=#variables.excelFile#' + '&webServerPath=#variables.webServerPath#', 'openContent', 'height=0,width=0');</cfoutput>
	    </script>
    <cfelse>
	    <cfif variables.isDebugging>
			<cfdump var="#form#" label="FORM">
			<cfdump var="#variables.getData#" label="TMP_PG_MEMBER">
		</cfif>
        <!--- problems occurred inform users and bail out --->
        <cfinclude template="/common_files/jQuery.cfm">

        <script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
        <script>
            noty( {  text:"We are sorry for the inconvenience.<br>But we are unable to execute<br>this action at this time."
                    ,type:'error'
                    ,buttons: [  { text:'close', onClick:function($noty) {  $noty.close(); window.close(); } } ]
                    ,layout:'center' });
        </script>
        <cfabort>
    </cfif>
</cfif>
</cfoutput>

<cfscript>
  qFamilyNames  = dataCFC.getFamilyNames();
  qBuyingGroups = dataCFC.getBuyingGroups();
</cfscript>

<div id="msg55"></div>    <!--- reserve this div for displaying status --->
<div id="whole">
	<cfoutput>
	<div id="actions">
		<a href="##" class="action" id="exp31">#application.util.string.actionLinkFormat("export to excel")#</a>
		<a href="##" onclick="window.close();" class="action" id="clo17">#application.util.string.actionLinkFormat("close window")#</a>
	</div>
	</cfoutput>

	<div id="list221">
		<form id="form226" method="post">
		<input type="hidden" name="checkedBoxes" value="">		<!--- comma-delimited list of selected product IDs to send to SQL --->

		<table class="datagrid" id="datagrid" style='table-layout:fixed'>
			<col width="3%">
			<col width="29%">
			<col width="15%">
			<col width="22%">
			<col width="22%">
			<col width="10%">

			<thead>
			<tr>
			 <th align="left"><input type="checkbox" name="checkAll" id="checkall"></th>
			 <th align="left">Name</th>
			 <th align="left"><cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput></th>
			 <th class="columnfilter" align="left"><cfoutput>#application.returned_customer_setting.Family_Name_Label_Singular#</cfoutput><br/><select><option> </option><cfoutput query="qFamilyNames"><option>#qFamilyNames.Family_Name#</option></cfoutput></select></th>
			 <th class="columnfilter" align="left"><cfoutput>#application.returned_customer_setting.Buying_Group_Label_Singular#</cfoutput><br/><select><option> </option><cfoutput query="qBuyingGroups"><option>#qBuyingGroups.Buying_Group_Name#</option></cfoutput></select></th>
			 <th class="columnfilter" align="left">Active Code <br/><select class="dropdown"><option> </option><option>A</option><option>I</option><option>N</option></select></th>
			</tr>
			</thead>

			<tbody></tbody>
		</table>
		</form>
	</div>
</div> <!--- id=whole --->

<cfinclude template="/common_files/jQuery.cfm">

<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script type="text/javascript">
if (!Array.prototype.indexOf) {
		Array.prototype.indexOf = function(obj, start) {
         for (var i = (start || 0), j = this.length; i < j; i++) {
             if (this[i] === obj) { return i; }
         }
         return -1;
    };
}

updateSelection = function () {
  <!--- all checked rows are saved in a hidden input with a name of 'checkedBoxes'
        we pass this list of values to Ajax to maintain all user's selection
        before we send we need to refresh the values in this hidden input       --->
  var hiddenCBoxes = $('input[name=checkedBoxes]').val();
  <!--- convert the list into an array for easy manipulation --->
  if (hiddenCBoxes.length == 0)
    var aCheckedBoxes = [];
  else
    var aCheckedBoxes = hiddenCBoxes.split(",");

  <!--- scan thru all checkboxes on the page --->
  $('input.include').each( function() {
    var prod_id = $(this).val();

    if ( $(this).prop('checked') ) {
      // checked box is not in the array, add it
      if (aCheckedBoxes.indexOf( prod_id ) == -1)
        aCheckedBoxes.push( prod_id );
    }
    else {
      // box is not checked so we need to remove it
      while(aCheckedBoxes.indexOf( prod_id ) != -1) {
        aCheckedBoxes.splice(aCheckedBoxes.indexOf( prod_id ),1);
      }
    }
  });

  <!--- convert array back to a list for passing to Ajax and for usage in form action --->
  hiddenCBoxes = aCheckedBoxes.join(",");
  <!--- refresh the hidden input with ALL selected rows --->
  $('input[name=checkedBoxes]').val( hiddenCBoxes );
  return hiddenCBoxes;
};

$(document).ready(function() {
  var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .80 : .77) * windowHeight;
  var oTable = $('#datagrid').dataTable({
		 "aoColumns": [
	                       { "bSearchable":false, "bSortable":false, "sSortDataType": "dom-checkbox" }
	                      ,{ "bSearchable":true }
	                      ,{ "bSearchable":true }
	                      ,{ "bSearchable":false, "bSortable":false }
	                      ,{ "bSearchable":false, "bSortable":false }
	                      ,{ "bSearchable":false, "bSortable":false }
                      ]
		// ,"aLengthMenu": [ [200, 500, -1], [200, 500, "All"]]
		,"aaSorting": [[ 1, "asc" ]]
		,"bProcessing": true
		,"bScrollCollapse": true
		,"bServerSide": true
		,"bSortClasses": false
		,"fnServerParams": function ( aoData ) { $('#checkall').attr("checked", false);   // default not to checked all
		        								 aoData.push( { "name": "checkedBoxes", "value":updateSelection() } );
		                                       }
		,"iDisplayLength": 200
		,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
		,"sAjaxSource": "ajax/exportByDistributor.cfm"
		,"sDom": "fprtip"
		,"sScrollY": sScrollY
		,"sServerMethod": "POST"
    }).fnSetFilteringDelay();

	$('#checkall').change(function(e) {
	  	$('.include').prop('checked', this.checked );
	});

	/* Add a select menu for each TH element in the table footer */
	$("thead th").each( function ( i ) {
		if ( $(this).hasClass("columnfilter") ) {
		    $('select', this).change( function () {
		        oTable.fnFilter( $(this).val(), i );
		    } );
		}
	});

	$('#exp31').click( function() {
	  if (updateSelection() == "") {
        noty( {  text:"Please select at least one <cfoutput>#lcase(application.returned_customer_setting.Distributor_Label_Singular)#</cfoutput>"
		        ,type:'error'
		        ,buttons: [  { text:'close', onClick:function($noty) {  $noty.close(); } } ]
		        ,killer:true
		        ,layout:'center' });
		return false;
	  }
	  $("input[name=distributor_id]").attr("disabled", "disabled");    // trash product_id inputs to save space
	  $("div#whole").fadeOut();
	  $("#msg55").append("<p>Gathering information, please wait...</p>");
	  $("#form226").submit();
	});
});
</script>
</body>
</html>
