<cfinclude template="_get_position_lists.cfm">

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
			
            sum(dbo.Dashboards_Sales_Summary.Actual_Current) as sales,
            sum(dbo.Dashboards_Sales_Summary.Goal) as goals,
            sum(dbo.Dashboards_Sales_Summary.Forecast) as forecasts
            

FROM		dbo.Dashboards_Sales_Summary
            INNER JOIN dbo.Dashboards_Sales_Month_Lookup ON dbo.Dashboards_Sales_Summary.month_id = dbo.Dashboards_Sales_Month_Lookup.dashboards_sales_month_lookup_id
            INNER JOIN dbo.Dashboards_Sales_Metric_Lookup ON dbo.Dashboards_Sales_Summary.metric_id = dbo.Dashboards_Sales_Metric_Lookup.dashboards_sales_metric_lookup_id

WHERE		dbo.Dashboards_Sales_Summary.level_id = 3

			<cfif 	user_market_list neq "">
            AND		level_3_id in (#user_market_list#)
            <cfelse>
            AND		1=2 <!--- Do not return any record if user is below this level --->
            </cfif>
            
            AND   GetDate()  between Dashboards_Sales_Month_Lookup.Year_Start_Date and Dashboards_Sales_Month_Lookup.Year_End_Date
            
            
group by	dbo.Dashboards_Sales_Summary.month_id,
            dbo.Dashboards_Sales_Summary.quarter_id,
            dbo.Dashboards_Sales_Summary.year_id,
            dbo.Dashboards_Sales_Month_Lookup.start_date,
            dbo.Dashboards_Sales_Month_Lookup.End_Date,
            dbo.Dashboards_Sales_Month_Lookup.month_description,
            dbo.Dashboards_Sales_Month_Lookup.month_abreviation,
            dbo.Dashboards_Sales_Summary.metric_id,
            dbo.Dashboards_Sales_Metric_Lookup.metric_description,
            dbo.Dashboards_Sales_Metric_Lookup.metric_abreviation

ORDER BY	
            dbo.Dashboards_Sales_Month_Lookup.start_date
            

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<cfset periods=valuelist(get_data_1.month_abreviation)>
<cfset sales=valuelist(get_data_1.sales)>
<cfset goals=valuelist(get_data_1.goals)>
<cfset forecasts=valuelist(get_data_1.forecasts)>
<!--- ----------------------------------------------------------------------------------------- --->



<!--- periods: get the number of periods being analyzed ------------------------------------------->
<cfset number_of_periods=listlen(periods)>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- period with sales: get the number of periods for which there are sales figures -------------->
<cfset number_of_sales=listlen(sales)>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- number of periods without sales activity ---------------------------------------------------->
<cfset target_periods=number_of_periods-number_of_sales>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- goals total: get the goals total for all periods ---------------------------------------------->
<cfset goals_total=0>
<cfloop index="i" list="#goals#">
<cfset goals_total=goals_total+i>
</cfloop>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- get the total monthly goals up to the last month for which there are sales ------------------>
<cfset goals_total_upto_period=0>
<cfloop index="i" from="1" to="#number_of_sales#">
<cfset goals_total_upto_period=goals_total_upto_period+listGetAt(goals, i)>
</cfloop>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- get the total monthly forecasts up to the last month for which there are sales -------------->
<cfset forecasts_total_upto_period=0>
<cfloop index="i" from="1" to="#number_of_sales#">
<cfset forecasts_total_upto_period=forecasts_total_upto_period+listGetAt(forecasts, i)>
</cfloop>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- sales total : get the sales total as of the last month with activity ------------------------>
<cfset sales_total=0>
<cfloop index="i" list="#sales#">
<cfset sales_total=sales_total+i>
</cfloop>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- get the current deficit of sales: total goals up to current period minus total sales up  ---->
<!---  to the current period (both in absolute and percentage values) ----------------------------->
<cfif target_periods GT 0>
	<cfset current_deficit=sales_total-goals_total_upto_period>
	<cfset current_deficit_perc=numberformat(evaluate(current_deficit*100/goals_total_upto_period), '9,999.99')>
<cfelse>
	<cfset current_deficit=0>
	<cfset current_deficit_perc=0>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- pad the list of sales to include the periods without sales activity: ------------------------>
<!--- append a "zero" to the list for each month without sales (future peridos) this way the  ----->
<!--- number of periods with sales matches the number of periods with goals ----------------------->
<cfset sales_corrected=sales>
<cfloop index="i" from="1" to="#target_periods#">
<cfset sales_corrected=listAppend(sales_corrected, "0")>
</cfloop>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- pad the list of target months ie the months that we need to forecast sales for to be able --->
<!--- to meet the goals set for all periods ------------------------------------------------------->
<cfset sales_deficit=goals_total-sales_total>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- calculate the theoretical monthly sales for the periods with no sales to at least  ---------->
<!--- be equal to the total sales goals figure ----------------------------------------------------->
<cfif target_periods GT 0>
<cfset monthly_sales_target=sales_deficit/target_periods>
<cfelse>
<cfset monthly_sales_target=0>
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- pad the list of target months with the appropriate values:                                --->
<!--- for the months for which there are sales, pad with a zero for each month -------------------->
<!--- for the months for which there are no sales, pad with the calculated value ------------------>
<cfset target_corrected="">
<cfloop index="i" from="1" to="#number_of_sales#">
<cfset target_corrected=listAppend(target_corrected, "0")>
</cfloop>
<cfloop index="i" from="1" to="#target_periods#">
<cfset target_corrected=listAppend(target_corrected, "#monthly_sales_target#")>
</cfloop>
<!--- ----------------------------------------------------------------------------------------- --->

<style>

div.summary_titles
{
	font-size:		10px;
	color:			#000000;
	text-align:		center;
	border-bottom:	0px #FC0 solid;
	margin:			0px 5px 0px 5px;
	text-align:		center;
	color:			#FFFFFF;
	padding:		0px 5px 5px 5px;
	text-shadow: 	2px 2px 2px #000;
}

div.summary_details
{
	font-size:		30px;
	color:			#000000;
	text-align:		center;
	border-bottom:	0px silver solid;
	margin:			5px 0px 0px 0px;
	text-align:		center;
	color:			#d0e6ff;
	padding:		0px 5px 0px 5px;
	text-shadow: 	2px 2px 2px #000;
}

div.detail_box
{
	padding:			10px 0px 0px 0px;
	margin:				0px 0px 0px 16px;
	width:				165px; 
	float:				left;
	background-color:	#444444;
	text-align:			center;
	height:				80px;

	background: 		#3a5dad; /* Old browsers */
	background: 		-moz-linear-gradient(top,  #3a5dad 0%, #141414 100%); /* FF3.6+ */
	background: 		-webkit-gradient(linear, left top, left bottom, color-stop(0%,#3a5dad), color-stop(100%,#141414)); /* Chrome,Safari4+ */
	background: 		-webkit-linear-gradient(top,  #3a5dad 0%,#141414 100%); /* Chrome10+,Safari5.1+ */
	background: 		-o-linear-gradient(top,  #3a5dad 0%,#141414 100%); /* Opera 11.10+ */
	background: 		-ms-linear-gradient(top,  #3a5dad 0%,#141414 100%); /* IE10+ */
	background: 		linear-gradient(top,  #3a5dad 0%,#141414 100%); /* W3C */
	filter: 			progid:DXImageTransform.Microsoft.gradient( startColorstr='#3a5dad', endColorstr='#141414',GradientType=0 ); /* IE6-9 */

	-webkit-border-radius:	15px;
	-moz-border-radius:		15px;
	border-radius:			15px; 
	border:					1px #555555 solid;
}

</style>

<cfoutput>

<!--- used to change the color from green to red to highlight negative values --------------------->
<cfif current_deficit LTE 0>
	<cfset sign_color="##ff0000">
<cfelse>
	<cfset sign_color="##00FF00">
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->


<!--- master colors used by the chart and by the detail boxes data so both match ------------------>
<cfset goals_color="##FFFFFF">
<cfset forecasts_color="##FFff00">
<cfset sales_color="##ff8c00">
<cfset targets_color="##75c6ff">
<!--- ----------------------------------------------------------------------------------------- --->



</cfoutput>


<style>
td.row_title
{
	font-size:		12px;
	color:			#FFF;
	font-weight:	bold;
	width:			125px;

	padding:		10px 10px 10px 10px;
	white-space: 	nowrap;

	background: 		#3a5dad; /* Old browsers */
	background: 		-moz-linear-gradient(top,  #3a5dad 0%, #141414 100%); /* FF3.6+ */
	background: 		-webkit-gradient(linear, left top, left bottom, color-stop(0%,#3a5dad), color-stop(100%,#141414)); /* Chrome,Safari4+ */
	background: 		-webkit-linear-gradient(top,  #3a5dad 0%,#141414 100%); /* Chrome10+,Safari5.1+ */
	background: 		-o-linear-gradient(top,  #3a5dad 0%,#141414 100%); /* Opera 11.10+ */
	background: 		-ms-linear-gradient(top,  #3a5dad 0%,#141414 100%); /* IE10+ */
	background: 		linear-gradient(top,  #3a5dad 0%,#141414 100%); /* W3C */
	filter: 			progid:DXImageTransform.Microsoft.gradient( startColorstr='#3a5dad', endColorstr='#141414',GradientType=0 ); /* IE6-9 */}

td.row_data
{
	font-size:		10px;
	color:			#FFF;
	font-weight:	bold;
	width:			50px;

	text-align:		right;

	padding:		10px 10px 10px 0px;
	white-space: 	nowrap;
	
	background: 		#777777; /* Old browsers */
	background: 		-moz-linear-gradient(top,  #777777 0%, #333333 100%); /* FF3.6+ */
	background: 		-webkit-gradient(linear, left top, left bottom, color-stop(0%,#777777), color-stop(100%,#333333)); /* Chrome,Safari4+ */
	background: 		-webkit-linear-gradient(top,  #777777 0%,#333333 100%); /* Chrome10+,Safari5.1+ */
	background: 		-o-linear-gradient(top,  #777777 0%,#333333 100%); /* Opera 11.10+ */
	background: 		-ms-linear-gradient(top,  #777777 0%,#333333 100%); /* IE10+ */
	background: 		linear-gradient(top,  #777777 0%,#333333 100%); /* W3C */
	filter: 			progid:DXImageTransform.Microsoft.gradient( startColorstr='#777777', endColorstr='#333333',GradientType=0 ); /* IE6-9 */}


</style>

<cfoutput>

 
 
	<!--- create a corrected forecast list w/ values for only periods with no sales. Zero for all others --->
	<cfset forecast_corrected="">
	<!--- get the first period without sales --->
	<cfset number_of_no_sales=number_of_sales+1>
	<cfloop index="i" from="1" to="#number_of_sales#">
	<cfset forecast_corrected=ListAppend(forecast_corrected, 0)>
	</cfloop>
	
	
	<!--- starting with the first period without sales append the forecasted number --->
	<cfloop  index="i" from="#number_of_no_sales#" to="#number_of_periods#">
	<cfset forecast_point=listGetAt(forecasts, i)>
	<cfset forecast_corrected=ListAppend(forecast_corrected, forecast_point)>
	</cfloop>


		<cfset cum_sales=0><!--- calculate the cumulative value of the sales --->
		<cfset cum_sales_list=""><!--- create a list with the cumulative values --->



<!--- sum of all of the forecasts for all periods --->
<cfset forecasts_for_all_periods=0>
<cfloop index="i" list="#forecasts#">
	<cfset forecasts_for_all_periods=forecasts_for_all_periods+i>
</cfloop>

<!--- sum of the forecasts for the periods with sales --->
<!--- #forecasts_total_upto_period# --->

<!--- sum of the forecasts for the periods without sales --->
<cfset forecasts_total_periods_without_sales=forecasts_for_all_periods-forecasts_total_upto_period>

<!--- projected totals = all actual sales + forecasted sales for periods without sales --->
<cfset projected_totals=sales_total+forecasts_total_periods_without_sales>

<!--- goals differential = projected_totals-total goals for all periods --->
<cfset goals_differential=projected_totals-goals_total>


<!--- used to change the color from green to red to highlight negative values --------------------->
<cfif goals_differential LTE 0>
	<cfset sign_color="##ff0000">
<cfelse>
	<cfset sign_color="##00FF00">
</cfif>
<!--- ----------------------------------------------------------------------------------------- --->


	<div class="detail_box">
		<div class="summary_titles">Total Goals<br />( all periods )</div>
		<div class="summary_details" style="color:#goals_color#">#numberformat(goals_total, '9,999,999,999')#</div>
	</div>
	
	<div class="detail_box">
		<div class="summary_titles">Total Actual Sales<br />( all periods )</div>
		<div class="summary_details" style="color:#goals_color#">#numberformat(sales_total, '9,999,999,999')#</div>
	</div>

	<div class="detail_box">
		<div class="summary_titles">Forecasted Sales<br />( periods w/o sales )</div>
		<div class="summary_details" style="color:#goals_color#">#numberformat(forecasts_total_periods_without_sales, '9,999,999,999')#</div>
	</div>
	
	<div class="detail_box">
		<div class="summary_titles">Projected Totals<br />( all periods )</div>
		<div class="summary_details" style="color:#goals_color#">#numberformat(projected_totals, '9,999,999,999')#</div>
	</div>

	<div class="detail_box">
		<div class="summary_titles">Differential<br />( all periods )</div>
		<div class="summary_details" style="color:#sign_color#;font-size:20px; margin:15px 0px 0px 0px;">#numberformat(goals_differential, '9,999,999,999')#&nbsp;&nbsp;<cfif goals_total eq 0>n/a<cfelse>#numberformat(goals_differential*100/goals_total, '9,999')#%</cfif></div>
	</div>


<br /><br /><br /><br /><br /><br />




<style>
div.section_title
{
	font-size:		19px;
	font-weight:	bold;
	color:			##FFFFFF; 
	border-bottom:	3px ##FFFFFF solid; 
	width:			91%;
	margin:			25px 0px 0px 0px;
	padding:		0px 0px 5px 0px;
	background-color:inherit;
}

div.sub_section_title
{
	font-size:		12px; 
	font-weight:	bold;
	border-bottom:	0px ##FFFFFF solid; 
	width:			91%;
	margin:			2px 0px 0px 0px;
	padding:		0px 0px 0px 0px;
	background-color:inherit;
}

</style>
<br />
<div align="center">
	<div class="sub_section_title">
		<font color="#sales_color#">Actual vs. Goals</font>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<font color="#targets_color#">Forecast vs. Goals</font>
	</div>

	<cfchart 
		format="png" 
		chartheight="385" 
		chartwidth="875" 
		showxgridlines="yes"
		gridlines="30"
		foregroundcolor="##999999" 
		databackgroundcolor="##000000"
		fontsize="10" 
		fontbold="yes" 
		labelformat="number" 
		showlegend="no" 
		showmarkers="no" 
		backgroundcolor="##000000" 
		>
	
		<cfchartseries type="bar" serieslabel="Actual vs Goals" seriescolor="#sales_color#">
		<cfloop index="i" from="1" to="#number_of_sales#">
			<cfchartdata item="#listGetAt(periods, i)#" value="#evaluate(round((listGetAt(sales, i)-listGetAt(goals, i))))#">
		</cfloop>
		</cfchartseries>

		<cfchartseries type="bar" serieslabel="Forecasts vs Goals" seriescolor="#targets_color#">
		<cfloop index="i" from="#evaluate(number_of_sales+1)#" to="#number_of_periods#">
			<cfchartdata item="#listGetAt(periods, i)#" value="#evaluate(round((listGetAt(forecast_corrected, i)-listGetAt(goals, i))))#">
		</cfloop>
		</cfchartseries>

		<cfchartseries type="line" serieslabel="Zero Level" seriescolor="#goals_color#" markerstyle="snow">
		<cfloop index="i" from="1" to="#number_of_periods#">
			<cfchartdata item="#listGetAt(periods, i)#" value="0">
		</cfloop>
		</cfchartseries>
	</cfchart>	


<table cellpadding="0" cellspacing="0" border="0" align="center">

	<tr>
		<td class="row_title"><strong>Cumulative Goals:&nbsp;</strong></td>
		<cfset cum_goals=0><!--- calculate the cumulative value of the goals --->
		<cfset cum_goals_list=""><!--- create a list with the cumulative values --->
		<cfloop index="i" from="1" to="#number_of_periods#">

		<td class="row_data">
		
			<cfif i EQ 1>
				<cfset cum_goals=listGetAt(goals, i)>
			<cfelse>
				<cfset cum_goals=cum_goals+listGetAt(goals, i)>
			</cfif>
			#numberformat(cum_goals, '9,999,999')#
		</td>
		<cfset cum_goals_list=ListAppend(cum_goals_list, cum_goals)>
		</cfloop>
	</tr>

	<!--- create a corrected forecast list w/ values for only periods with no sales. Zero for all others --->
	<cfset forecast_corrected="">
	<!--- get the first period without sales --->
	<cfset number_of_no_sales=number_of_sales+1>
	<cfloop index="i" from="1" to="#number_of_sales#">
	<cfset forecast_corrected=ListAppend(forecast_corrected, 0)>
	</cfloop>
	
	
	<!--- starting with the first period without sales append the forecasted number --->
	<cfloop  index="i" from="#number_of_no_sales#" to="#number_of_periods#">
	<cfset forecast_point=listGetAt(forecasts, i)>
	<cfset forecast_corrected=ListAppend(forecast_corrected, forecast_point)>
	</cfloop>

	<tr>
		<td class="row_title"><strong>Cumulative Sales:&nbsp;</strong></td>
		<cfset cum_sales=0><!--- calculate the cumulative value of the sales --->
		<cfset cum_sales_list=""><!--- create a list with the cumulative values --->
		<cfloop index="i" from="1" to="#number_of_periods#">
		<td class="row_data">
			<cfif i EQ 1>
				<cfset cum_sales=listGetAt(sales_corrected, i)+listGetAt(forecast_corrected, i)>
			<cfelse>
				<cfset cum_sales=cum_sales+listGetAt(sales_corrected, i)+listGetAt(forecast_corrected, i)>
			</cfif>
			#numberformat(cum_sales, '9,999,999')#
		</td>
		<cfset cum_sales_list=ListAppend(cum_sales_list, cum_sales)>
		</cfloop>
	</tr>


	<tr>
		<td class="row_title"><strong>Differentials:&nbsp;</strong></td>
		<cfloop index="i" from="1" to="#number_of_periods#">
		<td class="row_data">
			#numberformat(evaluate(listGetAt(cum_sales_list, i)-listGetAt(cum_goals_list, i)),'()9,999,999)')#
		</td>
		</cfloop>
	</tr>

</table>




</div>
</cfoutput>

