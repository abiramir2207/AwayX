<!-----------------------------------------------------------------------------

FILE NAME:    BBProgramReprocess.cfm
DESCRIPTION:  Reprocess file
CREATED BY:   Anand Rao
MODIFICATION HISTORY: BY    DATE    DESCRIPTION OF CHANGE

      Anand Rao 23-Apr-2013

------------------------------------------------------------------------------>
<style>
td.dollar {
  text-align: right;
}
p.warning {
  clear:both;
  margin:0 0 10px 0;
  padding:5px;
  background-color: blue;
  color:white;
  font-size: 12px;
}
</style>

<cfif form.command EQ "PRGREPROCESS" AND isDefined("FORM.CheckedBoxes")>
  <cftry>
    <!--- 1. Delete all the BBIDs from the table BB_Program_Reprocess_List  --->
    <cfquery name="delBBIDsInReprocessList" datasource="#application.datasource#">
      DELETE FROM BB_Program_Reprocess_List
    </cfquery>
    <!--- 2. get all the Billback IDs from the form scope and insert it into the BB_Program_Reprocess_List table --->
    <cfloop index = "variables.bb_id" list = "#FORM.CheckedBoxes#"  delimiters = ",">
      <cfquery name="variables.qryBBLocked" datasource="#application.datasource#">
        SELECT
          BB.BB_Code,
          BB.BB_Reference,
          BB.Billback_Status_ID,
          BA.BB_Is_Locked,
          BA.BB_Locked_By_User_ID,
          BA.BB_Lock_Date,
          BB.*
        FROM Billback BB
          INNER JOIN Billback_Allied BA ON BA.Billback_ID = BB.Billback_ID
        WHERE BB.Billback_ID = <cfqueryParam cfsqltype="cf_sql_varchar" value="#variables.bb_id#">
      </cfquery>

      <cfif ((variables.qryBBLocked.recordCount GTE 1) AND  (!variables.qryBBLocked.BB_Is_Locked))>
        <cfquery name="insBBIDsInReprocessList" datasource="#application.datasource#">
          INSERT INTO BB_Program_Reprocess_List (Billback_ID)
          VALUES(<cfqueryParam cfsqltype="cf_sql_varchar" value="#variables.bb_id#">)
        </cfquery>
      </cfif>
    </cfloop>

    <!--- 3. Call the SP BB_Program_Reprocess, so that it can reprocess the BBs from the above table. --->
    <cfstoredproc procedure="BB_Program_Reprocess" datasource="#application.datasource#">
    </cfstoredproc>
  <cfcatch>
      <cfquery name="unlockBBs" datasource="#application.datasource#">
        UPDATE  Billback_Allied set
          BB_Is_Locked = 0,
          BB_Locked_By_User_ID = NULL,
          BB_Lock_Date = NULL
        WHERE Billback_ID IN
        (
          SELECT Billback_ID FROM  BB_Program_Reprocess_List
        )
      </cfquery>
      <cfrethrow>
  </cfcatch>
  </cftry>
  <!--- <cfdump var="#form#"> --->
</cfif>

<!--- <cfif variables.inEditMode eq 1>
  <p class="warning headingTip"><b>Reminder:</b> Click the above <strong>reprocess</strong> option to reprocess the selected rows <strong>prior</strong> to changing the sorting order/the search string or navigating to a different page. </p>
</cfif> --->

<input type="hidden" name="checkedBoxes" value="">
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [0.65, 2.5, 2.5, 2, 2.5, 2.5, 3, 1.5] )>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="datagrid" style='table-layout:fixed'><!--- id="BBDisplayTable" --->
<cfoutput>
<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
  <col width="#variables.columnPercentage#%">
</cfloop>
</cfoutput>
  <thead ID="HEADER">
    <th>
      <input type="checkbox" name="CheckAll" id="toggle_all" <!--- onClick="javaScript: selectAll(this);" ---> <cfif variables.inEditMode eq 0>disabled=disabled</cfif>>
    </th>
    <th>Payable</th>
    <th>Status</th>
    <th>Claim $</th>
    <th>Ref #</th>
    <th>BB #</th>
    <th>Payee ID<br>Name</th>
    <th>Created Date</th>
  </thead>
  <tbody>
  </tbody>
</table>

<!---<div align="center">
<cfif variables.inEditMode>
  <cfoutput>
  <a href="##" class="ReProcess">#application.util.string.actionLinkFormat("reprocess")#</a>
  </cfoutput>
</cfif>
</div>--->
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/jquery.dataTables-api.js, /Script/javascript/dhtml.js">
<script type="text/javascript">
var formName = "DataForm";
var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .59 : .45) * windowHeight;

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
  $('input.cb').each( function() {
    var bb_id = $(this).val();

    if ( $(this).prop('checked') ) {
      // checked box is not in the array, add it
      if (aCheckedBoxes.indexOf( bb_id ) == -1)
        aCheckedBoxes.push( bb_id );
    }
    else {
      // box is not checked so we need to remove it
      while(aCheckedBoxes.indexOf( bb_id ) != -1) {
        aCheckedBoxes.splice(aCheckedBoxes.indexOf( bb_id ),1);
      }
    }
  });

  <!--- convert array back to a list for passing to Ajax and for usage in form action --->
  hiddenCBoxes = aCheckedBoxes.join(",");
  <!--- refresh the hidden input with ALL selected rows --->
  $('input[name=checkedBoxes]').val( hiddenCBoxes );
};

var reprocess = $('table.datagrid').dataTable({
   "bAutoWidth": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sDom": 'fptipr'
  ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
  ,"aaSorting": [[ 1, "asc" ]]
  ,"sScrollY": sScrollY         <!--- data grid height --->
  ,"bPaginate": true
  ,"bServerSide": true
  ,"bProcessing": true
  ,"iDisplayLength": 100
  ,"sAjaxSource": "ajax/BBProgramReprocess.cfm"
  ,"sServerMethod": "POST"
  ,"aoColumnDefs": [  { "aTargets":[0], "bSearchable":false, "bSortable":false }
                     ,{ "aTargets":[3], "bSearchable":false, "sClass":"dollar", "sType":"dollar"} ]
  ,"fnDrawCallback": function () { cb_count = $('.cb').length; toggle_all(); }
  ,"fnServerParams": function ( aoData ) {
            updateSelection();
            aoData.push( { "name": "checkedBoxes", "value": $('input[name=checkedBoxes]').val() } );
            aoData.push( { "name": "inEditMode", "value": <cfoutput>#variables.inEditMode#</cfoutput> } );
        }
}).fnSetFilteringDelay();

$('table.datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

//$('div.save').html("<a href=''##' class='ReProcess'><cfoutput>#LCase(ActionText('ReProcess'))#</cfoutput></a>");
var cb_count = $('.cb').length;    // count number of checkboxes
<!---events for toggle all checkbox------------------------------------------------------------------------------------>
$('#toggle_all').change(function(e){      <!---listen for the change event on the toggle--->
 $('.cb').prop('checked', ( this.checked ) ? true : false );
 e.stopPropagation();
});
<!---event for individual checkbox------------------------------------------------------------------------------------>
$('table.datagrid tbody').on('change', 'input.cb', function() { toggle_all(); });
<!---refresh toggle all state----------------------------------------------------------------------------------------->
toggle_all = function() {
  // toggle all is enabled when # of checkboxes equals to # of checked checkboxes otherwise make it disabled
  $('#toggle_all').prop('checked', ( $('.cb:checked').length == cb_count ) ? true : false );
}

$('.ReProcess').click(function(){
 // reprocess.fnFilter( '' );  // 33261 - redisplay hidden rows to prevent loosing selected data
 //check to see if any of the checkboxes are checked or not, if not throw an alert.
 var n = $( "input:checked" ).length;
 if (n==0)
 {
  alert("Please check at least one row to reprocess.");
  return false;
 }

 $('#command').val("PRGREPROCESS");
 $('.ReProcess').html("processing data, please wait...");

 updateSelection();
 $('form[name=' + formName + ']').submit();
 return false;
});
</script>