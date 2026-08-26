

<!--- 
<cfset months=	'Nov/10,Dec/10,Jan/11,Feb/11,Mar/11,Apr/11,May/11,Jun/11,Jul/11,Aug/11,Sep/11,Oct/11,Nov/11,Dec/11'>

<cfset sales=		'2297,2338,3317,1594,1292,2709,3006,1331,1913,2863,1351,2871'>
<cfset goals=		'1931,3189,1147,1971,2710,2624,1910,1487,3008,3092,3322,1265'>
<cfset forec=		'1669,2671,2769,3000,2666,2915,2824,2885,2201,2998,2854,3156'>

<cfset diff_sg=		'366,-851,2170,-377,-1418,85,1096,-156,-1095,-229,-1971,1606'>
<cfset diff_sg_perc='18.95,-26.69,189.19,-19.13,-52.32,3.24,57.38,-10.49,-36.4,-7.41,-59.33,126.96'>

<cfset diff_sf=		'628,-333,548,-1406,-1374,-206,182,-1554,-288,-135,-1503,-285'>
<cfset diff_sf_perc='37.63,-12.47,19.79,-46.87,-51.54,-7.07,6.44,-53.86,-13.08,-4.5,-52.66,-9.03'>

 --->



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
            sum(dbo.Dashboards_Sales_Summary.forecast) as forec,
            
            sum(dbo.Dashboards_Sales_Summary.Actual_Current) - sum(dbo.Dashboards_Sales_Summary.Goal) as diff_sg,
            (sum(dbo.Dashboards_Sales_Summary.Actual_Current) - sum(dbo.Dashboards_Sales_Summary.Goal)) / (case when sum(dbo.Dashboards_Sales_Summary.Goal) = 0 then 1 else sum(dbo.Dashboards_Sales_Summary.Goal) end) as diff_sg_perc,



            sum(dbo.Dashboards_Sales_Summary.Actual_Current) - sum(dbo.Dashboards_Sales_Summary.forecast) as diff_sf,
            (sum(dbo.Dashboards_Sales_Summary.Actual_Current) - sum(dbo.Dashboards_Sales_Summary.forecast)) / (case when sum(dbo.Dashboards_Sales_Summary.forecast) = 0 then 1 else sum(dbo.Dashboards_Sales_Summary.forecast) end) as diff_sf_perc
            
            



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
<cfset forec="">

<cfset diff_sg="">
<cfset diff_sg_perc="">

<cfset diff_sf="">
<cfset diff_sf_perc="">

<cfset fy="">


<!--- 
<cfset missing_months=12-get_data_1.recordcount>

<cfloop index="i" from="1" to="#missing_months#">
	<cfset months=listappend(months,"n/a")>
    <cfset sales=listappend(sales,"0")>
    <cfset goals=listappend(goals,"0")>
    <cfset forec=listappend(forec,"0")>

    <cfset diff_sg=listappend(diff_sg,"0")>
    <cfset diff_sg_perc=listappend(diff_sg_perc,"0")>
    
    <cfset diff_sf=listappend(diff_sf,"0")>
    <cfset diff_sf_perc=listappend(diff_sf_perc,"0")>

    <cfset fy=listappend(fy,"0")>

</cfloop>
 --->
 
 
 
<cfset months=listappend(months,valuelist(get_data_1.month_abreviation))>
<cfset sales=listappend(sales,valuelist(get_data_1.sales))>
<cfset goals=listappend(goals,valuelist(get_data_1.goals))>
<cfset forec=listappend(forec,valuelist(get_data_1.forec))>

<cfset diff_sg=listappend(diff_sg,valuelist(get_data_1.diff_sg))>
<cfset diff_sg_perc=listappend(diff_sg_perc,valuelist(get_data_1.diff_sg_perc))>

<cfset diff_sf=listappend(diff_sf,valuelist(get_data_1.diff_sf))>
<cfset diff_sf_perc=listappend(diff_sf_perc,valuelist(get_data_1.diff_sf_perc))>

<cfset fy=listappend(fy,valuelist(get_data_1.year_id))>

<br />

<!--- <div class="section_title">Dollars</div> --->

<table cellpadding="10" cellspacing="0" border="0" width="95%">
	<tr>
		<td valign="top">
		
			<table cellpadding="4" cellspacing="0" width="275">
				<tr>
					<td class="data_grid_header">month</td>
					<!--- <td class="data_grid_header">fy</td> --->
					<td class="data_grid_header" style="text-align:right;">sales&nbsp;</td>
					<td class="data_grid_header" style="text-align:right;">vs.goal</td>
					<td class="data_grid_header" style="text-align:right;">vs.forecast</td>
				</tr>
				
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">

				<cfoutput>

				<cfif listGetAt(diff_sg, i) GTE 0>
				<cfset color1="##00FF00">
				<cfelse>
				<cfset color1="##FF0000">
				</cfif>

				<cfif listGetAt(diff_sf, i) GTE 0>
				<cfset color2="##00FF00">
				<cfelse>
				<cfset color2="##FF0000">
				</cfif>

				<tr bgcolor="###iif(i MOD 2,DE('373737'), DE('222222'))#">
					<td class="data_grid_level3" style="text-align:left; padding:4px 4px 4px 4px;" nowrap>
						#listGetAt(months, i)#
					</td>


					<!--- <td class="data_grid_level3" style="text-align:left; padding:4px 4px 4px 4px;" nowrap>#listGetAt(fy, i)#</td> --->


					<td class="data_grid_level3" style="text-align:right; padding:4px 4px 4px 4px;" nowrap>
						#numberformat(listGetAt(sales, i),'9,999,999')#&nbsp;&nbsp;
					</td>
					<td class="data_grid_level3" style="text-align:right; padding:4px 4px 4px 4px; color:#color1#;" nowrap>
						#numberformat(listGetAt(diff_sg, i), '9,999,999')#&nbsp;<br />
						#numberformat(listGetAt(diff_sg_perc, i), '9,999.9')#%&nbsp;
					</td>
					<td class="data_grid_level3" style="text-align:right; padding:4px 4px 4px 4px; color:#color2#;" nowrap>
						#numberformat(listGetAt(diff_sf, i), '9,999,999')#&nbsp;<br />
						#numberformat(listGetAt(diff_sf_perc, i), '9,999.9')#%&nbsp;
					</td>
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

			<cfchartseries type="line" serieslabel="Sales" seriescolor="##FFFF00">
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">
				<cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(sales, i)#">
				</cfloop>
			</cfchartseries>

			<cfchartseries type="bar" serieslabel="Goal" seriescolor="##CCCCCC">
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">
				<cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(goals, i)#">
				</cfloop>
			</cfchartseries>

			<cfchartseries type="bar" serieslabel="Forecast" seriescolor="##0000FF ">
				<cfloop index="i" from="1" to="#get_data_1.recordcount#">
				<cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(forec, i)#">
				</cfloop>
			</cfchartseries>


		</cfchart>



		</td>
	</tr>
</table>