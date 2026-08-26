<cfoutput>
<fieldset style="padding:7px; width:99%; border:1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;">Volume Plan - Duplicate</legend>
<div style="margin:10px 0;font:bold 12px;">
	Warning! Your volume plan represents a duplicate with the existing plans below.
</div>

<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">

<table id="datagrid" class="datagrid">
	<thead>
		<tr>
		<th>Existing Plan</th>
		<th>Product</th>
		<th>Distributor PG in existing plan</th>
		<th>Product PG in existing plan</th>
		<th>Distributor PG in your plan</th>
		<th>Product PG in your plan</th>
		<th>Distributor</th>
		</tr>
	</thead>
<tbody>
	<cfloop query="dup.volumePlans">
		<tr>
			<td>#dup.volumePlans.vf_plan_desc#<br/> #dup.volumePlans.vf_class_desc# - #dup.volumePlans.business_unit_desc#</td>
			<td>#dup.volumePlans.Description#</td>
			<td>#dup.volumePlans.Other_Vf_Pg_Customer_Category_Name#</td>
			<td>#dup.volumePlans.Other_Vf_Pg_Product_Category_Name#</td>
			<td>#dup.volumePlans.Pg_Customer_Category_Name#</Td>
			<td>#dup.volumePlans.Pg_Product_Category_Name#</Td>
			<td>#dup.volumePlans.Name# <cfif len(dup.volumePlans.shr_ship_to)>(#dup.volumePlans.shr_ship_to#)</cfif></td>
		</tr>
	</cfloop>
</tbody>
</table>

<br>

<a href="index.cfm?command=plan&from=plan">#ActionText("return to volume forecast plan")#</a>
</fieldset>
</cfoutput>
