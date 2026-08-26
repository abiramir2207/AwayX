
<!--- ----------------------------------------------------------------------------------------- --->
<!--Compare this months data with same month in previous years -->
<cfquery name="Get_Data_1" datasource="#Application.Datasource#">

SELECT
	dashboards_sales_summary_id,
	level_one_description,
	level_one_code,
	level_two_description,
	level_two_code,
	level_three_description,
	level_three_code,
	month_id,
	[year] as year,
	volume,
	metric_id,
	level_id,
	quarter_id,
	date_time_stamp,
	dbo.Dashboards_Sales_Month_Lookup.month_description,
	dbo.Dashboards_Sales_Metric_Lookup.[metric_description] as metric_description

FROM
	dbo.Dashboards_Sales_Summary
	INNER JOIN dbo.Dashboards_Sales_Month_Lookup ON month_id = dbo.Dashboards_Sales_Month_Lookup.dashboards_sales_month_lookup_id
	INNER JOIN dbo.Dashboards_Sales_Metric_Lookup ON metric_id = dbo.Dashboards_Sales_Metric_Lookup.dashboards_sales_metric_lookup_id
WHERE
	month_id = 11 AND
	month_id = 10 AND
	metric_id = 1 

</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->

