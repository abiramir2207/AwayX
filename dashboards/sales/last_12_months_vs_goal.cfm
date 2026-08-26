


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
			
            sum(dbo.Dashboards_Sales_Summary.Actual_Current) as sales,
            sum(dbo.Dashboards_Sales_Summary.Goal) as goals,
            
            sum(dbo.Dashboards_Sales_Summary.Actual_Current) - sum(dbo.Dashboards_Sales_Summary.Goal) as dif_abs,
            (sum(dbo.Dashboards_Sales_Summary.Actual_Current) - sum(dbo.Dashboards_Sales_Summary.Goal)) / (case when sum(dbo.Dashboards_Sales_Summary.Goal) = 0 then 1 else sum(dbo.Dashboards_Sales_Summary.Goal) end) as dif_prc
            
            



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
<cfset goals="">
<cfset dif_abs="">
<cfset dif_prc="">
<cfset fy="">

<!--- 
<cfset missing_months=12-get_data_1.recordcount>

<cfloop index="i" from="1" to="#missing_months#">
	<cfset months=listappend(months,"n/a")>
    <cfset sales=listappend(sales,"0")>
    <cfset goals=listappend(goals,"0")>
    <cfset dif_abs=listappend(dif_abs,"0")>
    <cfset dif_prc=listappend(dif_prc,"0")>
</cfloop>
 --->

<cfset months=listappend(months,valuelist(get_data_1.month_abreviation))>
<cfset sales=listappend(sales,valuelist(get_data_1.sales))>
<cfset goals=listappend(goals,valuelist(get_data_1.goals))>
<cfset dif_abs=listappend(dif_abs,valuelist(get_data_1.dif_abs))>
<cfset dif_prc=listappend(dif_prc,valuelist(get_data_1.dif_prc))>

<cfset fy=listappend(fy,valuelist(get_data_1.year_id))>


<!--- <div class="section_title">Equivalent Cases</div> --->

<table cellpadding="10" cellspacing="0" border="0" width="95%">
	<tr>
		<td valign="top">
		
		
			<table cellpadding="3" cellspacing="1" width="275" height="375">
				<tr>
					<td class="data_grid_header">month</td>
					<!--- <td class="data_grid_header">fy</td> --->
					<td class="data_grid_header" style="text-align:right;">sales&nbsp;</td>
					<td class="data_grid_header" style="text-align:right;">goal</td>
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
					<td class="data_grid_level3" style="text-align:left;" nowrap>#listGetAt(months, i)#</td>

					<!--- <td class="data_grid_level3" style="text-align:left;" nowrap>#listGetAt(fy, i)#</td> --->

					<td class="data_grid_level3" style="text-align:right; color:#color#;" nowrap>#numberformat(listGetAt(sales, i),'9,999,999')#&nbsp;</td>
					<td class="data_grid_level3" style="text-align:right;" nowrap>#numberformat(listGetAt(goals, i),'9,999,999')#&nbsp;</td>
					<td class="data_grid_level3" style="text-align:right;" nowrap>#numberformat(listGetAt(dif_abs, i),'9,999,999')#&nbsp;</td>
					<td class="data_grid_level3" style="text-align:right;" nowrap><cfif listGetAt(goals, i) EQ 0>n/a<cfelse>#numberformat(listGetAt(dif_prc, i)*100,'9,999,999.9')#%</cfif>&nbsp;</td>
				</tr>

				</cfoutput>
				
				</cfloop>

			</table>


		</td>
		<td valign="top">
		
		<cfchart 
			format="png" 
			chartheight="375" 
			chartwidth="615" 
			foregroundcolor="##FFFFFF" 
			databackgroundcolor="##000000" 
			fontsize="10" 
			showlegend="yes" 
			backgroundcolor="##000000">

			<cfchartseries type="bar" serieslabel="Sales Goal" seriescolor="##000099">
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">
				<cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(goals, i)#">
				</cfloop>
			</cfchartseries>

			<cfchartseries type="line" serieslabel="Actual Sales" seriescolor="##FFFF00">
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">
				<cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(sales, i)#">
				</cfloop>
			</cfchartseries>



		</cfchart>




		</td>
	</tr>
</table>



