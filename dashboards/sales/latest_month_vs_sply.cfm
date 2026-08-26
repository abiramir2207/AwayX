<!--- ----------------------------------------------------------------------------------------- --->

<!--- get the latest month to retrieve data for  --->
<cfset latest_month=month(now())-1>
<!--- <cfoutput>#latest_month#</cfoutput> --->

<!--- get current year --->
<cfset this_year=year(now())>
<!--- <cfoutput>#this_year#</cfoutput> --->

<!--- get the last year  --->
<cfset last_year=year(now())-1>
<!--- <cfoutput>#last_year#</cfoutput> --->

<!--- get the metric description --->
<cfquery name="get_metric" datasource="#Application.Datasource#">
Select	metric_description,
		metric_abreviation
From	Dashboards_Sales_Metric_Lookup
Where	dashboards_sales_metric_lookup_id = #form.metric#
</cfquery>




<!--- get the name of the month --->
<cfquery name="get_month" datasource="#Application.Datasource#">
Select	month_description
From	Dashboards_Sales_Month_Lookup
Where	dashboards_sales_month_lookup_id = #latest_month#
</cfquery>

<!--- get the level of the data --->
<cfquery name="get_level" datasource="#Application.Datasource#">
Select	level_description
From	Dashboards_Sales_level_Lookup
Where	dashboards_sales_level_lookup_id = #form.level#
</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the data for all regions for the latest month --->
<cfquery name="get_data_1" datasource="#Application.Datasource#">
Select		round(volume,0) as volume
From		Dashboards_Sales_Summary
Where		month_id = #latest_month# and
			year_id = #this_year#  and
			level_id = #form.level# and
			metric_id = #form.metric#
</cfquery>


<!--- get the total for the latest month --->
<cfset latest_month_total=0>

<cfloop query="get_data_1">
<cfset latest_month_total=latest_month_total+volume>
</cfloop>

<!--- ----------------------------------------------------------------------------------------- --->



<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the data for all regions for SPLY --->
<cfquery name="get_data_2" datasource="#Application.Datasource#">
Select		round(volume,0) as volume
From		Dashboards_Sales_Summary
Where		month_id = #latest_month# and
			year_id = #last_year#  and
			level_id = #form.level# and
			metric_id = #form.metric#
</cfquery>


<!--- get the data for all regions for SPLY --->
<cfset latest_month_total_SPLY=0>

<cfloop query="get_data_2">
<cfset latest_month_total_SPLY=latest_month_total_SPLY+volume>
</cfloop>

<!--- ----------------------------------------------------------------------------------------- --->


<cfchart 
	format="png" 
	chartheight="350" 
	chartwidth="650" 
	foregroundcolor="##FFFFFF" 
	databackgroundcolor="##000000" 
	fontsize="11" 
	fontbold="yes" 
	xaxistitle="" 
	yaxistitle="#get_metric.metric_description#" 
	backgroundcolor="##000000"
	>

	<cfchartseries type="horizontalbar" paintstyle="shade" colorlist="##00FF00, ##ffae00">
		<cfchartdata item="#get_month.month_description# #this_year#" value="#latest_month_total#">
		<cfchartdata item="#get_month.month_description# #last_year#" value="#latest_month_total_SPLY#">
	</cfchartseries>

</cfchart>





<!--- ----------------------------------------------------------------------------------------- --->
<!--- calculate growth and format data --->
<cfset real_growth = numberformat(evaluate(latest_month_total-latest_month_total_SPLY), '9,999,999')>
<cfset percent_growth = numberformat(evaluate((latest_month_total-latest_month_total_SPLY)/latest_month_total_SPLY)*100,'9,999.99')>
<cfset latest_month_total=numberformat(latest_month_total, '9,999,999')>
<cfset latest_month_total_SPLY=numberformat(latest_month_total_SPLY, '9,999,999')>


<!--- is the growth positive or negative and set the symbol --->
<cfif real_growth GT 0>
	<cfset symbol="[+]">
<cfelse>
	<cfset symbol="[-]">
</cfif>



<cfoutput>
<br />
Period: #get_month.month_description# #this_year# vs.  #get_month.month_description# #last_year#
<br />
Level: #get_level.level_description# (All)
<br />
Latest sales: #get_metric.metric_abreviation##latest_month_total# 
<br />
SPLY sales: #get_metric.metric_abreviation##latest_month_total_SPLY#
<br />
Growth: #symbol# #get_metric.metric_abreviation##abs(real_growth)# / #percent_growth#%
</cfoutput>
<!--- ----------------------------------------------------------------------------------------- --->


<br /><br />
