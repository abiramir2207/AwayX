
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
			dbo.Dashboards_Sales_Month_Lookup.month_abreviation as months,

            round(sum(dbo.Dashboards_Sales_Summary.Actual_Current),2) as actual,
            round(sum(dbo.Dashboards_Sales_Summary.actual_yag),2) as sply,
            round(sum(dbo.Dashboards_Sales_Summary.forecast),2) as forecasted,
            
            case when dbo.Dashboards_Sales_Month_Lookup.end_date < getdate() then 'A' else 'F' end as reporting_flag
            --case when dbo.Dashboards_Sales_Month_Lookup.end_date < '9/1/2011' then 'A' else 'F' end as reporting_flag
            
            
                        
            
FROM		
			dbo.Dashboards_Sales_Summary
            INNER JOIN dbo.Dashboards_Sales_Month_Lookup ON dbo.Dashboards_Sales_Summary.month_id = dbo.Dashboards_Sales_Month_Lookup.dashboards_sales_month_lookup_id
            INNER JOIN dbo.Dashboards_Sales_Metric_Lookup ON dbo.Dashboards_Sales_Summary.metric_id = dbo.Dashboards_Sales_Metric_Lookup.dashboards_sales_metric_lookup_id

WHERE		
            dbo.Dashboards_Sales_Summary.level_id = 3
            <cfif 	user_market_list neq "">
            AND		level_3_id in (#user_market_list#)
            <cfelse>
            AND		1=2 <!--- Do not return any record if user is below this level --->
            </cfif>
            AND
            dbo.Dashboards_Sales_Summary.Record_Type = 1
			AND 
            GetDate() between Dashboards_Sales_Month_Lookup.Year_Start_Date AND Dashboards_Sales_Month_Lookup.Year_End_Date
            
group by	
			dbo.Dashboards_Sales_Summary.month_id,
            dbo.Dashboards_Sales_Summary.quarter_id,
            dbo.Dashboards_Sales_Summary.year_id,
            dbo.Dashboards_Sales_Month_Lookup.start_date,
            dbo.Dashboards_Sales_Month_Lookup.end_date,
            dbo.Dashboards_Sales_Month_Lookup.month_description,
            dbo.Dashboards_Sales_Month_Lookup.month_abreviation,
            dbo.Dashboards_Sales_Summary.metric_id,
            dbo.Dashboards_Sales_Metric_Lookup.metric_description,
            dbo.Dashboards_Sales_Metric_Lookup.metric_abreviation

ORDER BY	
            dbo.Dashboards_Sales_Month_Lookup.start_date

</cfquery>

<!--- ----------------------------------------------------------------------------------------- --->
<!--- convert query results to lists ---------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<cfset months=		valueList(get_data_1.months)>
<cfset actual=		valueList(get_data_1.actual)>
<cfset forecasted=	valueList(get_data_1.forecasted)>
<cfset sply=		valueList(get_data_1.sply)>
<cfset reportingflag=		valueList(get_data_1.reporting_flag)>

<cfset fiscal=		valueList(get_data_1.year_id)>
<!--- ----------------------------------------------------------------------------------------- --->


<div align="right"><a id="displayText" href="javascript:toggle();" style="color:#FFFFFF; font-size:20px;"><img src='../images/maximize.png' width="20" height="20" border="0" name='view data details' title='view data details' /></a></div>


<center>

    <cfchart 
        format=					"#chartformat#" 
        chartheight=			"#chartheight#" 
        chartwidth=				"#chartwidth#" 
        foregroundcolor=		"#chartforegroundcolor#" 
        databackgroundcolor=	"#chartdatabackgroundcolor#" 
        fontsize=				"#chartfontsize#"
        showlegend=				"#chartshowlegend#" 
        backgroundcolor=		"#chartbackgroundcolor#">
        
        <cfchartseries type="#actual_sales_type#" serieslabel="Actual" seriescolor="#actual_sales_color#">
            <cfloop index="i" from="1" to="#get_data_1.recordcount#">
            <cfchartdata item="#listGetAt(months, i)#" value="#round(listGetAt(actual, i))#">
            </cfloop>
        </cfchartseries>
        
        <cfchartseries type="#forecasted_sales_type#" serieslabel="Forecasted" seriescolor="#forecasted_sales_color#">
            <cfloop index="i" from="1" to="#get_data_1.recordcount#">
            <cfchartdata item="#listGetAt(months, i)#" value="#round(listGetAt(forecasted, i))#">
            </cfloop>
        </cfchartseries>
        
        <cfchartseries type="#sply_sales_type#" serieslabel="Same Period Last Year" seriescolor="#sply_sales_color#">
            <cfloop index="i" from="1" to="#get_data_1.recordcount#">
            <cfchartdata item="#listGetAt(months, i)#" value="#round(listGetAt(sply, i))#">
            </cfloop>
        </cfchartseries>
        
    </cfchart>  

</center>


         
<script language="javascript"> 
function toggle() {
	var ele = document.getElementById("toggleText");
	var text = document.getElementById("displayText");
	if(ele.style.display == "block") {
    		ele.style.display = "none";
		text.innerHTML = "<img src='../images/maximize.png' width='20' height='20' border='0' name='view data details' title='view data details' />";
  	}
	else {
		ele.style.display = "block";
		text.innerHTML = "<img src='../images/blank.png' width='20' height='20' border='0' />";
	}
} 
</script>


<div class="hover_box gradient_fix" id="toggleText" style="display: none;">

  <div align="right"><a id="displayText" href="javascript:toggle();"><img src='../images/minimize.png' name='hide data details' title='hide data details' width="20" height="20" border="0" /></a></div>
    <div class="page_title"><cfoutput>#page_name#</cfoutput> (<cfoutput>#uom#</cfoutput>)</div>

    <table cellpadding="0" cellspacing="0" border="0" width="100%" height="83%" align="center">
        <tr>
            <td class="column_title">&nbsp;</td>
            <td class="column_title">type</td>
            <td class="column_title">f/a</td>
            <td class="column_title">sply</td>
            <td class="column_title">abs dif</td>
            <td class="column_title">% dif</td>
            
        </tr>
    

	<!--- instanciate the variable that tracks sply for the actual and forecasted months ---------- --->
    <cfset sply_total_actual_months = 0>
    <cfset sply_total_forecasted_months = 0>
    <!--- ----------------------------------------------------------------------------------------- --->
        
    <cfloop index="i" from="1" to="#get_data_1.recordcount#">
    <cfoutput>

	<cfset reporting_flag= listGetAt(reportingflag, i)>
    
    
    <cfif reporting_flag EQ "A">

    	<cfset reporting_sales = listGetAt(actual, i)>
        <cfset abs_delta = reporting_sales-listGetAt(sply, i)>
        <cfset abs_delta_percent = abs_delta*100/(listGetAt(sply, i)+0.001)>
        <cfset sply_total_actual_months = sply_total_actual_months + listGetAt(sply, i)>

    <cfelse>

    	<cfset reporting_sales = listGetAt(forecasted, i)>
        <cfset abs_delta = reporting_sales-listGetAt(sply, i)>
        <cfset abs_delta_percent = abs_delta*100/(listGetAt(sply, i)+0.001)>
        <cfset sply_total_forecasted_months = sply_total_forecasted_months + listGetAt(sply, i)>

    </cfif>


	<cfif listGetAt(sply, i) EQ 0>
        <cfset abs_delta_percent = "n/a">
    </cfif>

        <tr>
            <td class="row_title">#listGetAt(months, i)#</td>
            <td class="data_cell">#reporting_flag#</td>
            <td class="data_cell">#numberformat(reporting_sales, ',')#</td>
            <td class="data_cell">#numberformat(listGetAt(sply, i), ',')#</td>
            <td class="data_cell">#numberformat(abs_delta, '(),')#</td>
            <td class="data_cell">#numberformat(abs_delta*100/(listGetAt(sply, i)+0.0001), '()0.0')#%</td>
        </tr>
    </cfoutput>

    </cfloop>

    <cfset fa_total 					= ArraySum(ListToArray(actual)) + ArraySum(ListToArray(forecasted))>
    <cfset abs_dif_actual 				= ArraySum(ListToArray(actual)) - sply_total_actual_months>
    <cfset abs_dif_forecasted 			= ArraySum(ListToArray(forecasted)) - sply_total_forecasted_months>
	<cfset abs_dif_total 				= abs_dif_actual + abs_dif_forecasted>
    <cfset abs_dif_actual_percent 		= (ArraySum(ListToArray(actual)) - sply_total_actual_months)*100/(sply_total_actual_months+0.0001)>
    <cfset abs_dif_forecasted_percent 	= (ArraySum(ListToArray(forecasted)) - sply_total_forecasted_months)*100/(sply_total_forecasted_months+0.0001)>
    <cfif ArraySum(ListToArray(sply)) eq 0 >
	<cfset abs_dif_total_percent 		= "" />
    <cfelse>
	<cfset abs_dif_total_percent 		= (abs_dif_total*100)/ArraySum(ListToArray(sply))>
     </cfif>   
    

		<!--- totals at bottom of page -------------------------------------------------- --->

        <tr>
            <td class="row_title" style="border-top:3px #FFFFFF solid; border-bottom:1px #777777 solid;">Year To Date (actual)</td>
            <td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:1px #777777 solid;">-</td>
            <td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(ArraySum(ListToArray(actual)), "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(sply_total_actual_months, "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(abs_dif_actual, "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(abs_dif_actual_percent, "()0.0")#%</cfoutput></td>
        </tr>

        <tr>
            <td class="row_title" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;">Year To Go (forecast)</td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;">-</td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(ArraySum(ListToArray(forecasted)), "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(sply_total_forecasted_months, "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(abs_dif_forecasted, "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(abs_dif_forecasted_percent, "()0.0")#%</cfoutput></td>
        </tr>
																																				
        <tr>
            <td class="row_title" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;">Full Year (all)</td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;">-</td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(fa_total, "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(ArraySum(ListToArray(sply)), "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;"><cfoutput>#numberformat(abs_dif_total, "(),")#</cfoutput></td>
            <td class="data_cell" style="border-top:0px #777777 solid; border-bottom:1px #777777 solid;"><cfoutput><cfif abs_dif_total_percent neq "">#numberformat(abs_dif_total_percent, "()0.0")#%</cfif></cfoutput></td>
        </tr>

    </table>

</div>

