<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the data to populate the grid ------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<cfinclude template="_get_position_lists.cfm">

<cfquery name="get_data_1"  datasource="#application.datasource#">
 
SELECT		dbo.Dashboards_Sales_Summary.date_time_stamp,
            dbo.Dashboards_Sales_Summary.level_1_description,
            dbo.Dashboards_Sales_Summary.level_2_description,
            dbo.Dashboards_Sales_Summary.level_3_description,
            dbo.Dashboards_Sales_Summary.level_1_code,
            dbo.Dashboards_Sales_Summary.level_2_code,
            dbo.Dashboards_Sales_Summary.level_3_code,
            dbo.Dashboards_Sales_Summary.month_id,
            dbo.Dashboards_Sales_Summary.quarter_id,
            dbo.Dashboards_Sales_Summary.year_id,
            dbo.Dashboards_Sales_Month_Lookup.month_description,
            dbo.Dashboards_Sales_Month_Lookup.month_abreviation,
            dbo.Dashboards_Sales_Summary.metric_id,
            dbo.Dashboards_Sales_Metric_Lookup.metric_description,
            dbo.Dashboards_Sales_Metric_Lookup.metric_abreviation,
            dbo.Dashboards_Sales_Summary.Actual_Current,
            dbo.Dashboards_Sales_Summary.Actual_YAG,
            dbo.Dashboards_Sales_Summary.Forecast,
            dbo.Dashboards_Sales_Summary.Goal

FROM		dbo.Dashboards_Sales_Summary
            INNER JOIN dbo.Dashboards_Sales_Month_Lookup ON dbo.Dashboards_Sales_Summary.month_id = dbo.Dashboards_Sales_Month_Lookup.dashboards_sales_month_lookup_id
            INNER JOIN dbo.Dashboards_Sales_Metric_Lookup ON dbo.Dashboards_Sales_Summary.metric_id = dbo.Dashboards_Sales_Metric_Lookup.dashboards_sales_metric_lookup_id

WHERE		dbo.Dashboards_Sales_Summary.level_id = 3

			<cfif 	user_market_list neq "">
            AND		level_3_id in (#user_market_list#)
            <cfelse>
            AND		1=2 <!--- Do not return any record if user is below this level --->
            </cfif>

ORDER BY	dbo.Dashboards_Sales_Summary.level_1_description,
			dbo.Dashboards_Sales_Summary.level_2_description,
			dbo.Dashboards_Sales_Summary.level_3_description,
            dbo.Dashboards_Sales_Month_Lookup.start_date

</cfquery>

<style>

th
{
	text-align:		left;
}

</style>


<table width="900" border="0" cellspacing="0" cellpadding="0" id="thetable">
<thead>
    <tr>
        <th>level</th>
        <th>&nbsp;</th>
        <th>&nbsp;</th>
        <th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; month</th>
        <th style="text-align:right;">Volume&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
        <th style="text-align:right;">SPLY&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
        <th style="text-align:right;">Dif&nbsp;&nbsp;&nbsp;&nbsp;</th>
        <th style="text-align:right;">Dif %&nbsp;&nbsp;&nbsp;&nbsp;</th>
    </tr>
</thead>

<tbody>

<cfoutput query="get_data_1" group="level_1_description">

    <tr>
    <td class="data_grid_level1" nowrap="nowrap" colspan="100%">#get_data_1.level_1_description#</td>
    </tr>


<cfoutput group="level_2_description">

    <tr>
    <td width="25">&nbsp;</td>
    <td class="data_grid_level2" nowrap="nowrap" colspan="100%">#get_data_1.level_2_description#</td>
	</tr>



<cfoutput group="level_3_description">

    <tr>
    <td width="25">&nbsp;</td>
    <td width="25">&nbsp;</td>
    <td class="data_grid_level3" nowrap="nowrap">#get_data_1.level_3_description#</td>
	</tr>



<cfoutput>

    <cfif evaluate(Actual_Current-Actual_YAG) LT 0>
    <cfset color="##FF0000">
    <cfelse>
    <cfset color="##00FF00">
    </cfif>

    <tr>
	<td>&nbsp;&nbsp;</td>
	<td>&nbsp;&nbsp;</td>
	<td>&nbsp;&nbsp;</td>
    <td class="data_grid_level3" nowrap="nowrap">#month_description# - #year_id#</td>
    <td class="data_grid_level3" nowrap="nowrap" style="color:#color#; text-align:right;">#numberformat(Actual_Current, '9,999,999')#</td>
    <td class="data_grid_level3" nowrap="nowrap" style="text-align:right;">#numberformat(Actual_YAG, '9,999,999')#</td>
    <td class="data_grid_level3" nowrap="nowrap" style="text-align:right;">#numberformat(evaluate(Actual_Current-Actual_YAG), '9,999,999')#</td>
    <td class="data_grid_level3" nowrap="nowrap" style="text-align:right;">#numberformat(evaluate((Actual_Current-Actual_YAG)*100/application.util.validation.EasyIIf(Actual_YAG)),'9,999.9')#%</td>
	</tr>

</cfoutput>
</cfoutput>
</cfoutput>
</cfoutput>


</tbody>
</table>



<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
<script type="text/javascript" src="../javascript/jquery.tablescroll.js"></script>

<script>
/*<![CDATA[*/

jQuery(document).ready(function($)
{
	$('#thetable').tableScroll({height:400});
});

/*]]>*/
</script>

























