
<cfquery name="get_data_1"  datasource="#application.datasource#">

SELECT		dbo.Dashboards_Sales_Summary.month_id,
            dbo.Dashboards_Sales_Summary.quarter_id,
            dbo.Dashboards_Sales_Summary.year_id,
            dbo.Dashboards_Sales_Month_Lookup.month_description,
            dbo.Dashboards_Sales_Month_Lookup.month_abreviation,
            dbo.Dashboards_Sales_Summary.metric_id,
            
            dbo.Dashboards_Sales_Month_Lookup.start_date,
            
            dbo.Dashboards_Sales_Metric_Lookup.metric_description,
            dbo.Dashboards_Sales_Metric_Lookup.metric_abreviation,
			dbo.Dashboards_Sales_Month_Lookup.month_abreviation as display_month,

            round(sum(dbo.Dashboards_Sales_Summary.Actual_Current), 0) as sales,
            round(sum(dbo.Dashboards_Sales_Summary.actual_yag), 0) as sply,
            
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
            
            dbo.Dashboards_Sales_Summary.Record_Type = 2

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


<cfset months=listappend(months,valuelist(get_data_1.display_month))>
<cfset sales=listappend(sales,valuelist(get_data_1.sales))>
<cfset sply=listappend(sply,valuelist(get_data_1.sply))>
<cfset dif_abs=listappend(dif_abs,valuelist(get_data_1.dif_abs))>
<cfset dif_prc=listappend(dif_prc,valuelist(get_data_1.dif_prc))>

<cfset fy=listappend(fy,valuelist(get_data_1.year_id))>


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

        <cfchartseries type="#actual_sales_type#" serieslabel="Sales" seriescolor="#actual_sales_color#">
            <cfloop index="i" from="1" to="#get_data_1.recordcount#">
            <cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(sales, i)#">
            </cfloop>
        </cfchartseries>

        <cfchartseries type="#sply_sales_type#" serieslabel="Same Period Last Year" seriescolor="#sply_sales_color#">
            <cfloop index="i" from="1" to="#get_data_1.recordcount#">
            <cfchartdata item="#listGetAt(months, i)#" value="#listGetAt(sply, i)#">
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

			    <table cellpadding="0" cellspacing="0" border="0" width="100%" height="80%" align="center">

				<tr>
					<td class="column_title">&nbsp;</td>
					<td class="column_title">sales</td>
					<td class="column_title">sply</td>
					<td class="column_title">abs dif</td>
					<td class="column_title">% dif</td>
				</tr>

				<cfloop index="i" from="1" to="#get_data_1.recordcount#">

				<tr>
					<td class="row_title"><cfoutput>#listGetAt(months, i)#</cfoutput></td>
					<td class="data_cell"><cfoutput>#numberformat(listGetAt(sales, i),'()9,999,999')#</cfoutput></td>
					<td class="data_cell"><cfoutput>#numberformat(listGetAt(sply, i),'()9,999,999')#</cfoutput></td>
					<td class="data_cell"><cfoutput>#numberformat(listGetAt(dif_abs, i),'()9,999,999')#</cfoutput></td>
					<td class="data_cell"><cfif listGetAt(sales, i) EQ 0>n/a<cfelse><cfoutput>#numberformat(listGetAt(dif_prc, i)*100,'()9,999,999.9')#</cfoutput>%</cfif></td>
				</tr>

				</cfloop>

                <tr>
					<td class="row_title" style="border-top:3px #FFFFFF solid; border-bottom:0px #FFFFFF solid;">Totals</td>
					<td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:0px #FFFFFF solid;"><cfoutput>#numberformat(ArraySum(ListToArray(sales)), "(),")#</cfoutput></td>
					<td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:0px #FFFFFF solid;"><cfoutput>#numberformat(ArraySum(ListToArray(sply)), "(),")#</cfoutput></td>
					<td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:0px #FFFFFF solid;"><cfoutput>#numberformat(ArraySum(ListToArray(dif_abs)), "(),")#</cfoutput></td>
					<td class="data_cell" style="border-top:3px #FFFFFF solid; border-bottom:0px #FFFFFF solid;"><cfoutput>#numberformat(ArraySum(ListToArray(dif_abs))*100/ArraySum(ListToArray(sply)), "().9")#%</cfoutput></td>
				</tr>

			</table>

</div>



