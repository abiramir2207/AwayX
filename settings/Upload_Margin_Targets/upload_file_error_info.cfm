<cfinclude template="/common_files/jQuery.cfm">
<cfinclude template="/common_files/dataTables2.cfm">

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

    <cfquery name="qErrorRecords" datasource="#application.datasource#">
        SELECT * 
        FROM Margin_Targets_Upload_Doc_Error_Details
        WHERE Doc_ID  = #url.Doc_ID#
    </cfquery>

<table class="datagrid" style="width: 100%">	
<thead>
	<tr>
		<th>Item ##</th>
		<th>Distribution Channel</th>
		<th>Net Sales Target Value</th>
		<th>Net Sales Floor Value</th>
		<th>GM Target Value</th>
		<th>GM Floor Value</th>
		<th>Reason</th>
	</tr>
</thead>
<tbody>
<cfoutput query="qErrorRecords">
	<tr>
		<td>#item#</td>
		<td>#Distribution_Channel#</td>
		<td>#Net_Sales_Target_Value#</td>
		<td>#Net_Sales_Floor_Value#</td>
		<td>#GM_Target_Value#</td>
		<td>#GM_Floor_Value#</td>
		<td>#replace(Reason, '.','<br>', 'ALL')#</td>
	</tr>
</cfoutput>
</tbody>
</table>

<script type="text/javascript" src="/Script/javascript/FixedHeader.min.js"></script>

<script>
var oTable = $('table.datagrid').DataTable({
	 "bPaginate": false
	,"bSortClasses": false
	,"bScrollCollapse": true
	,"sDom": 'fti'
	,"bFilter": true
	,"aoColumns": [   
															{"bSortable":true, "bSearchable":true }
														, {"bSortable":false,  "bSearchable":false}
														, {"bSortable":false,  "bSearchable":false}
														, {"bSortable":false,  "bSearchable":false}
														, {"bSortable":false,  "bSearchable":false}
														, {"bSortable":false,  "bSearchable":false}
														, {"bSortable":false,  "bSearchable":false}
													 ]
	,"scrollY": Math.floor(jQuery(window).height()) - 80
	,"scrollX": true
	,"scrollCollapse": true
})
</script>