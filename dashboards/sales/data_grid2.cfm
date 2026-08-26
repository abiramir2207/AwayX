<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the data to populate the grid ------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<!--- get the sub-regions for this region --->
<cfquery name="get_sub_region"  datasource="#application.datasource#">
	Select		distinct
				level_2_code,
				level_2_description
	From		dashboards_sales_summary
	Where		level_1_code = '#url.region#'
</cfquery>










<cfquery name="get_data_1" datasource="#application.datasource#">

select		
			
			dashboards_sales_summary.dashboards_sales_summary_id,
			dashboards_sales_summary.date_time_stamp,
			dashboards_sales_summary.level_1_description,
			dashboards_sales_summary.level_1_code,

			dashboards_sales_summary.level_2_description,
			dashboards_sales_summary.level_2_code,

			dashboards_sales_summary.level_3_description,
			dashboards_sales_summary.level_3_code,

			dashboards_sales_summary.month_id,
			dashboards_sales_summary.quarter_id,
			dashboards_sales_summary.year_id,
			dashboards_sales_summary.volume,
			dashboards_sales_summary.metric_id,
			dashboards_sales_month_lookup.month_abreviation,
			dashboards_sales_month_lookup.month_description,
			dashboards_sales_metric_lookup.metric_abreviation,
			dashboards_sales_metric_lookup.metric_description

from		dashboards_sales_summary

inner join	dashboards_sales_month_lookup on dashboards_sales_summary.month_id = dashboards_sales_month_lookup.dashboards_sales_month_lookup_id

inner join	dashboards_sales_metric_lookup on dashboards_sales_summary.metric_id = dashboards_sales_metric_lookup.dashboards_sales_metric_lookup_id

where		dashboards_sales_summary.level_id = 2

and			level_1_code = '#url.region#'	

and			dashboards_sales_summary.year_id = 2011

</cfquery>


<cfoutput query="get_sub_region" group="level_2_description">
	<cfoutput>
		#get_sub_region.level_2_description#
	</cfoutput>
</cfoutput>


<table border="0" cellpadding="0" cellspacing="0" width="100%">

	<tr>
		<td class="data_grid_header">month</td>

		<td class="data_grid_header">volume</td>
		
		<td class="data_grid_header">metric</td>
		<td class="data_grid_header">sply</td>
		<td class="data_grid_header">abs dif</td>
		<td class="data_grid_header">% dif</td>
	</tr>


<cfoutput query="get_data_1" group="month_id">
	<tr>
		<td colspan="100%" class="data_grid_level2">#month_description#<br /></td>
	</tr>

	<cfoutput group="metric_id">
	<cfset volume_sply=volume*(1+randrange(-11111,+11111)/100000)>
		<tr>
			<td class="data_grid_level3"></td>

			<cfif evaluate(volume-volume_sply) GTE 0>
			<cfset flag="green_tiny.png">
			<cfelse>
			<cfset flag="red_tiny.png">
			</cfif>
			
			<td class="data_grid_level3">#level_3_description# #numberformat(volume, '9,999,999.99')# <img src="images/#flag#"></td>
			<td class="data_grid_level3">#metric_description#</td>
			<td class="data_grid_level3">#numberformat(volume_sply, '9,999,999.99')#</td>
			<td class="data_grid_level3">#numberformat(evaluate(volume-volume_sply), '9,999,999.99')#</td>
			<td class="data_grid_level3">#numberformat(evaluate((volume-volume_sply)*100/volume_sply),'9,999.99')#%</td>
		</tr>
	
	</cfoutput>

</cfoutput>

</table>
