<!----------------------------------------------------------------------------------
Name         :	AwayX/Planners/Create/select_planner_template.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	04/01/2016
Created By   : 	KAL
Description  : 	Create Planner; Lists Planner Templates
<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!<<<!!!
	THIS FILE IS DEPRECATED; INSTEAD USE /planners/include/select_planner_template.cfm
>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!>>>!!!
---------------------------------------------------------------------------------->

<!--- get planner templates  --->
<cfset allowedTemplates = plannerTemplateManager.getAllowedPlannerTemplates()/>
<cfsavecontent variable="uncompressed">
<div id="datagrid_div">
	<table class="datagrid" id="datagrid"  style='table-layout:fixed'>
		<col width="30%">
		<col width="50%">
		<col width="10%">
		<col width="10%">
		<thead>
			<tr>
				<th align="left">Type</th>
				<th align="left">Description</th>
				<th align="left">Start Date</th>
				<th align="left">End Date</th>
			</tr>
		</thead>
		<tbody>
			<cfoutput query="allowedTemplates">
				<tr id="#allowedTemplates.Planner_Template_ID#" class="templateId">
					<td>#allowedTemplates.Planner_Type#kal</td>
					<td>#allowedTemplates.Planner_Description#</td>
					<td>#dateFormat(allowedTemplates.Planner_Start_Date, "medium")#</td>
					<td>#dateFormat(allowedTemplates.Planner_End_Date, "medium")#</td>
				</tr>
			</cfoutput>
		</tbody>
	</table>
</div>
</cfsavecontent>
<cfoutput>#application.util.string.compress( uncompressed )#</cfoutput>

<script>
	// datatable
	var oTable = $('table#datagrid').DataTable({
		 "autoWidth": false
		,"paging": false
		,"processing":true
		,"orderClasses": true
		,"ScrollCollapse": true
		,"sDom": 'ti'
		,"columns": [
			  {"bSortable":true, "bSearchable":true }
			, {"bSortable":true,  "bSearchable":true}
			, {"bSortable":true,  "bSearchable":true}
			, {"bSortable":true, "bSearchable":true} ]
	}) // DataTable

</script>
