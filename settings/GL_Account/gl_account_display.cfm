<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\GL_Account\GL_Account_display.cfm
      Date:     2014 July
      Author:   Chris Nguyen
      Purpose:  Manage GL accounts

      Notes:

----------------------------------------------------------------------------------------------------------------------->
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<div style="margin:0 0 5px 0">
<cfoutput>
<cfif form.display eq "inActive">
	<a href="##" onClick="javaScript: return activateSelComps();">#application.util.string.actionLinkFormat2("activate selected")#</a>
<cfelse>
	<a href="##" onClick="javaScript: return deactivateSelComps();">#application.util.string.actionLinkFormat2("deactivate selected")#</a>
</cfif>
</cfoutput>
</div>

<cfset variables.columnSizes = [0.35, 2, 3, 1.5, 1.5, 1.5]>
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( variables.columnSizes )>

<table id="datagrid" class="datagrid" style='table-layout:fixed;width:100%;'>
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
  <cfoutput>
	<thead>
    <tr>
      <th><input type="checkbox" name="checkAll" id="toggle_all"></th>
      <th>#Application.GLAccountLabel#</th>
      <th>#Application.GLAccountLabel# Description</th>
      <th>Start Date</th>
	  <th>End Date</th>
      <th>Action</th>
    </tr>
  </thead>
  </cfoutput>

  <!--- stuff the content of tbody into a variable so we can remove extra white space easily --->
  <cfsavecontent variable="variables.tbody">
		<cfoutput query="qGetCompRebates">
			<tr>
				<td><input type="checkbox" class="toggle_one" name="CID" value="#qGetCompRebates.GL_Account_ID#"></td>
				<td>#qGetCompRebates.GL_Account#</td>
				<td>#qGetCompRebates.GL_Account_Desc#</td>
				<td>#dateformat(qGetCompRebates.Start_Date, 'mmm d, yyyy')#</td>
				<td>#dateformat(qGetCompRebates.End_Date, 'mmm d, yyyy')#</td>
				<td>
					<a href="" onClick="JavaScript: return submitDataForm('edit','#GL_Account_ID#');">#application.util.string.actionLinkFormat2("edit")#</a> &nbsp;
					<a href="" onClick="JavaScript: return submitDataForm('copy','#GL_Account_ID#');">#application.util.string.actionLinkFormat2("copy")#</a> &nbsp;	<!---	D45619 :: Add [copy] link and alphabetize selected components in GL codes --->
					<CFIF form.display EQ "active">
						<a href="" onClick="JavaScript: return deactivateComp('#GL_Account_ID#');">#application.util.string.actionLinkFormat2("deactivate")#</a>
					<CFELSE>
						<a href="" onClick="JavaScript: return activateComp('#GL_Account_ID#');">#application.util.string.actionLinkFormat2("activate")#</a>
					</CFIF>
				</td>
			</tr>
		</cfoutput>
	</cfsavecontent>
	<tbody>
		<cfoutput>#application.util.string.compress(variables.tbody)#</cfoutput>
	</tbody>
</table>


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
      ,"sScrollY": Math.floor($(window).height()) - 200
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"aoColumns": [
										   {"bSortable":false, "bSearchable":false}
										  ,{"bSortable":true,  "bSearchable":true}
										  ,{"bSortable":true,  "bSearchable":true}
										  ,{"bSortable":true,  "bSearchable":true}
										  ,{"bSortable":true,  "bSearchable":true}
										  ,{"bSortable":false, "bSearchable":false}
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
</script>



