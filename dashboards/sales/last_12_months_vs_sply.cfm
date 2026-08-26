

<cfinclude template="_get_position_lists.cfm">

<cfquery name="get_data_1"  datasource="#application.datasource#">
 
SELECT		
            dbo.Dashboards_Sales_Summary.month_id,
            dbo.Dashboards_Sales_Summary.quarter_id,
            dbo.Dashboards_Sales_Summary.year_id,
            dbo.Dashboards_Sales_Month_Lookup.month_description,
            dbo.Dashboards_Sales_Month_Lookup.month_abreviation,
            dbo.Dashboards_Sales_Summary.metric_id,
            
            dbo.Dashboards_Sales_Month_Lookup.start_date,
            
            dbo.Dashboards_Sales_Metric_Lookup.metric_description,
            dbo.Dashboards_Sales_Metric_Lookup.metric_abreviation,
			dbo.Dashboards_Sales_Month_Lookup.month_abreviation as display_month,

            sum(dbo.Dashboards_Sales_Summary.Actual_Current) as sales,
            sum(dbo.Dashboards_Sales_Summary.actual_yag) as sply,
            
            sum(dbo.Dashboards_Sales_Summary.Actual_Current) - sum(dbo.Dashboards_Sales_Summary.actual_yag) as dif_abs,
            (sum(dbo.Dashboards_Sales_Summary.Actual_Current) - sum(dbo.Dashboards_Sales_Summary.actual_yag)) / (case when sum(dbo.Dashboards_Sales_Summary.actual_yag) = 0 then 1 else sum(dbo.Dashboards_Sales_Summary.actual_yag) end) as dif_prc
            
            



FROM		dbo.Dashboards_Sales_Summary
            INNER JOIN dbo.Dashboards_Sales_Month_Lookup ON dbo.Dashboards_Sales_Summary.month_id = dbo.Dashboards_Sales_Month_Lookup.dashboards_sales_month_lookup_id
            INNER JOIN dbo.Dashboards_Sales_Metric_Lookup ON dbo.Dashboards_Sales_Summary.metric_id = dbo.Dashboards_Sales_Metric_Lookup.dashboards_sales_metric_lookup_id

WHERE		dbo.Dashboards_Sales_Summary.level_id = 3

			<cfif 	user_market_list neq "">
            AND		level_3_id in (#user_market_list#)
            <cfelse>
            AND		1=2 <!--- Do not return any record if user is below this level --->
            </cfif>
            
            AND
            
            dbo.Dashboards_Sales_Month_Lookup.end_date < getdate()
            
            and
            dbo.Dashboards_Sales_Month_Lookup.Start_Date > dateadd(m, -12, getdate())


group by	dbo.Dashboards_Sales_Summary.month_id,
            dbo.Dashboards_Sales_Summary.quarter_id,
            dbo.Dashboards_Sales_Summary.year_id,
            dbo.Dashboards_Sales_Month_Lookup.start_date,
            dbo.Dashboards_Sales_Month_Lookup.month_description,
            dbo.Dashboards_Sales_Month_Lookup.month_abreviation,
            dbo.Dashboards_Sales_Summary.metric_id,
            dbo.Dashboards_Sales_Metric_Lookup.metric_description,
            dbo.Dashboards_Sales_Metric_Lookup.metric_abreviation

ORDER BY	
            dbo.Dashboards_Sales_Month_Lookup.start_date
            

</cfquery>




<!--- this is done in case the number of items in the db is less than 12 --->
<cfset months="">
<cfset sales="">
<cfset sply="">
<cfset dif_abs="">
<cfset dif_prc="">

<cfset fy="">


<!--- 

<cfset missing_months=12-get_data_1.recordcount>

<cfloop index="i" from="1" to="#missing_months#">
	<cfset months=listappend(months,"n/a")>
    <cfset sales=listappend(sales,"0")>
    <cfset sply=listappend(sply,"0")>
    <cfset dif_abs=listappend(dif_abs,"0")>
    <cfset dif_prc=listappend(dif_prc,"0")>

    <cfset fy=listappend(fy,"0")>

</cfloop>

 --->


<cfset months=listappend(months,valuelist(get_data_1.display_month))>
<cfset sales=listappend(sales,valuelist(get_data_1.sales))>
<cfset sply=listappend(sply,valuelist(get_data_1.sply))>
<cfset dif_abs=listappend(dif_abs,valuelist(get_data_1.dif_abs))>
<cfset dif_prc=listappend(dif_prc,valuelist(get_data_1.dif_prc))>

<cfset fy=listappend(fy,valuelist(get_data_1.year_id))>


<!--- <div class="section_title">Equivalente Cases</div> --->

<table cellpadding="10" cellspacing="0" border="0" width="95%">
	<tr>
		<td valign="top">
		
		
			<table cellpadding="4" cellspacing="0" width="275">
				<tr>
					<td class="data_grid_header">month</td>
					<!--- <td class="data_grid_header">fy</td> --->
					<td class="data_grid_header" style="text-align:right;">sales</td>
					<td class="data_grid_header" style="text-align:right;">sply</td>
					<td class="data_grid_header" style="text-align:right;">abs dif</td>
					<td class="data_grid_header" style="text-align:right;">% dif</td>
				</tr>
				
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">

				<cfoutput>

				<cfif listGetAt(dif_abs, i) GTE 0>
				<cfset color="##00FF00">
				<cfelse>
				<cfset color="##FF0000">
				</cfif>

				<tr bgcolor="###iif(i MOD 2,DE('373737'), DE('222222'))#">
					<td class="data_grid_level3" style="text-align:left; padding:8px 0px 8px 4px;" nowrap>#listGetAt(months, i)#</td>


					<!--- <td class="data_grid_level3" style="text-align:left; padding:8px 0px 8px 4px;" nowrap>#listGetAt(fy, i)#</td> --->


					<td class="data_grid_level3" style="text-align:right; padding:8px 0px 8px 0px; color:#color#;" nowrap>#numberformat(listGetAt(sales, i),'9,999,999')#&nbsp;</td>
					<td class="data_grid_level3" style="text-align:right; padding:8px 0px 8px 0px;" nowrap>#numberformat(listGetAt(sply, i),'9,999,999')#&nbsp;</td>
					<td class="data_grid_level3" style="text-align:right; padding:8px 0px 8px 0px;" nowrap>#numberformat(listGetAt(dif_abs, i),'9,999,999')#&nbsp;</td>
					<td class="data_grid_level3" style="text-align:right; padding:8px 0px 8px 0px;" nowrap><cfif listGetAt(sales, i) EQ 0>n/a<cfelse>#numberformat(listGetAt(dif_prc, i)*100,'9,999,999.9')#%</cfif>&nbsp;</td>




				</tr>
				
				</cfoutput>
				
				</cfloop>

			</table>
	
		
		</td>
		<td valign="top">

	
		<cfchart 
			format="png" 
			chartheight="400" 
			chartwidth="615" 
			foregroundcolor="##FFFFFF" 
			databackgroundcolor="##000000" 
			fontsize="10"
			showlegend="yes" 
			backgroundcolor="##000000">

			<cfchartseries type="bar" serieslabel="Same Period Last Year" seriescolor="##0000FF">
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">
				<cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(sply, i)#">
				</cfloop>
			</cfchartseries>

			<cfchartseries type="line" serieslabel="Sales" seriescolor="##FFFF00">
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">
				<cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(sales, i)#">
				</cfloop>
			</cfchartseries>


<!--- 
			<cfchartseries type="line" serieslabel="Trend" seriescolor="##FFFFFF">
				<cfloop index="i" from="1" to="12">
				<cfchartdata item="#listGetAt(months, i)#" value="#evaluate(1955+52.339*i)#">
				</cfloop>
			</cfchartseries>
 --->


		</cfchart>




		</td>
	</tr>
</table>