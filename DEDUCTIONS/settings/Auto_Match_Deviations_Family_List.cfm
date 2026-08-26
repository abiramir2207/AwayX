<cfparam name="url.fromAutoMatch" default="0">
<cfparam name="url.fromAutoDeviation" default="0">

<cfset bbManager = createObject("component", "components.Billback.BillbackSettingsManager")>
<cfset qGetFamilyList = bbManager.GetFamilyNames()/>
<cfset qGetExistingFamily = bbManager.GetExistingFamilyNames(fromAutoMatch= #url.fromAutoMatch#,fromAutoDeviation=#url.fromAutoDeviation#)/>

<cfif url.fromAutoMatch>
	<CFSET URL.PageTitle="Auto Match Family List">
<cfelse>
	<CFSET URL.PageTitle="Auto Deviation Family List">
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<table class="datagrid">
	<thead>
	<tr>
		<th><b>Family</b></th>
		<th><b>Family Name</b></th>
	</tr>
	</thead>
	<tbody>
	<cfoutput query="qGetExistingFamily" >
	<tr>
		<td>#Family#</td>
		<td>#Family_Name#</td>
	</tr>
	</cfoutput>
	</tbody>
</table>

<cfinclude template="/Common_Files/jQuery.cfm">
<cfinclude template="/Common_Files/dataTables.cfm">
<cfmodule template="/customTags/include.cfm" file_to_include="/common_files/datatable.css">
<script>
	var windowHeight = $(window).height(), sScrollY = ( windowHeight > 800 ? .71 : .80) * windowHeight;
	oTable = $('.datagrid').dataTable( {
						  "bServerSide": false
						, "bProcessing": false
						, "bSortClasses": false
						, "bAutoWidth": false
						, "oLanguage": {"sSearch": "<b>Search:</b>"}
						, "sScrollY": sScrollY
						, "sDom": "rti"
						, "bPaginate":false
						, "aaSorting": []
						, "aoColumns": [  {"bSearchable": true,  "bSortable":true}, {"bSearchable": false,   "bSortable":true}]
					    } ).fnSetFilteringDelay();
</script>