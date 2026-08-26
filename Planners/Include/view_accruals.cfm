<!---------------------------------------------------------------------------------------------------------------------
      File: 	/planners/include/view_accruals.cfm
      Date:     2021 April
      Author:   Sharon Harris
      Purpose:  Template for displaying accrual grid. This is an include.
---------------------------------------------------------------------------------------------------------------------->
<style>
	table.accrual {
		width: 310px;
		border-collapse: collapse;
		border: 2px solid #b2b2b2;
		font-size:11px;
	}
	table.accrual thead th {
		background-color: #C4DCF1;
		border-bottom: 1px solid #666;
		font-weight: normal;
		padding: 4px;
	}
	table.accrual thead th {
		width: 29%;
	}
	table.accrual .firstCol {
		width: 13%;
	}

	table.accrual th, table.accrual td {
		border-bottom: 1px dotted #666;
		border-right: 1px dotted #666;
		text-align:right;
		padding: 4px;
	}
	table.accrual td.label {
		font-weight: bold;
		text-align: left;
		border-right: 1px solid #666;
	}
</style>
<cfoutput>
<table class="accrual">
	<thead>
		<tr>
			<th class="firstCol"> </th>
			<th>Gross Sales $</th>
			<th>Accruals</th>
			<th>Promo</th>
		</tr>
	</thead>
	<tbody>
		<tr> <!--- YTD --->
			<td class="label">YTD</td>
			<td>#numberFormat( request.queries.planner_summary.Sofar_Gross_Sales_Dollar, "$," )#</td>
			<td>#numberFormat( request.queries.planner_accrual_summary.Sofar_Accrual_Dollar, "$," )#</td>
			<td>#numberFormat( request.queries.planner_summary.Sofar_Promo_Dollar, "$," )#</td>
		</tr>
		<tr> <!--- To Go --->
			<td class="label">To Go</td>
			<td>#numberFormat( request.queries.planner_summary.Togo_Gross_Sales_Dollar, "$," )#</td>
			<td>#numberFormat( request.queries.planner_accrual_summary.Togo_Accrual_Dollar, "$," )#</td>
			<td>#numberFormat( request.queries.planner_summary.Togo_Promo_Dollar, "$," )#</td>
		</tr>
		<tr> <!--- Total --->
			<td class="label">Total</td>
			<td>#numberFormat( request.queries.planner_summary.Total_Gross_Sales_Dollar, "$," )#</td>
			<td>#numberFormat( request.queries.planner_accrual_summary.Total_Accrual_Dollar, "$," )#</td>
			<td>#numberFormat( request.queries.planner_summary.Total_Promo_Dollar, "$," )#</td>
		</tr>
		<tfoot>
			<tr> <!--- Rates --->
				<td class="label">Rates</td>
				<td> </td>
				<td>#percentFormat( request.queries.planner_accrual_summary.Total_Accrual_Dollar, request.queries.planner_summary.Total_Gross_Sales_Dollar )#</td>
				<td>#percentFormat( request.queries.planner_summary.Total_Promo_Dollar, request.queries.planner_summary.Total_Gross_Sales_Dollar )#</td>			
			</tr>
		</tfoot>
	</tbody>
</table>
</cfoutput>