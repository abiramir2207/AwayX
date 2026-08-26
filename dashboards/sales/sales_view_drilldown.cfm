
<!--- logic used for the values being retrieved ----------------------------------------------------

SPLY
	(X) - EQC_SPLY_Past:		For last F/Y, actual sales for the same periods as in (A)
	(Y) - EQC_SPLY_Post:		For last F/Y, actual sales for the same periods as in (D)		
	
YTD (actual)
	(A) - EQC_Actual:			Total EQCs for the periods of the current F/Y where the period end date < than today
	(B) - EQC_Actual_Dif:		Value (A) minus value (X)
	(C) - EQC_Actual_Percent:	Value (B) divided by value (A) (percent)

YTG (forecast)
	(D) - EQC_Forecast:			Total forecasted EQCs for the current F/Y, e.g., each period where end date >= than today
	(E) - EQC_Forecast_Dif:		Value (D) minus value (Y)
	(F) - EQC_Forecast_Percent:	Value (E) divided by value (D) (percent)

TOTAL
	(G) - EQC_Total:			Value (A) plus value (D)
	(H) - EQC_Total_Dif:		Value (B) plus value (E)
	(I) - EQC_Total_Percent:	Value (H) divided by value (G) (percent)

----------------------------------------------------------------------------------------------- --->

<cfquery name="get_data_1"  datasource="#application.datasource#">

SELECT
        dbo.Dashboards_Sales_Summary.level_1_description,
        dbo.Dashboards_Sales_Summary.level_2_description,
        dbo.Dashboards_Sales_Summary.level_3_description,
        
        round(sum(case when dbo.Dashboards_Sales_Month_Lookup.End_Date < getdate() then dbo.Dashboards_Sales_Summary.actual_current else 0 end), 0) as EQC_Actual,
        round(sum(case when dbo.Dashboards_Sales_Month_Lookup.End_Date >= getdate() then dbo.Dashboards_Sales_Summary.forecast else 0 end), 0) as EQC_Forecast,
        
        round(sum(case when dbo.Dashboards_Sales_Month_Lookup.End_Date < getdate() then dbo.Dashboards_Sales_Summary.actual_yag else 0 end), 0) as EQC_SPLY_Past_Months,
        round(sum(case when dbo.Dashboards_Sales_Month_Lookup.End_Date >= getdate() then dbo.Dashboards_Sales_Summary.actual_yag else 0 end), 0) as EQC_SPLY_Post_Months

FROM		
		dbo.Dashboards_Sales_Summary
		INNER JOIN dbo.Dashboards_Sales_Month_Lookup ON dbo.Dashboards_Sales_Summary.month_id = dbo.Dashboards_Sales_Month_Lookup.dashboards_sales_month_lookup_id

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

GROUP BY
		dbo.Dashboards_Sales_Summary.level_1_description,
        dbo.Dashboards_Sales_Summary.level_2_description,
        dbo.Dashboards_Sales_Summary.level_3_description

order by 
		dbo.Dashboards_Sales_Summary.level_1_description,
        dbo.Dashboards_Sales_Summary.level_2_description,
        dbo.Dashboards_Sales_Summary.level_3_description

</cfquery>


<!--- ----------------------------------------------------------------------------------------- --->

<cfset level_I_color			=	"ffde98">
<cfset level_I_back_color		=	"000000">
<cfset level_I_total_color		=	"000000">
<cfset level_I_total_back_color	=	level_I_color>

<cfset level_II_color			=	"4169e1">
<cfset level_II_back_color		=	"000000">
<cfset level_II_total_color		=	"ffffff">
<cfset level_II_total_back_color=	level_II_color>

<cfset grand_total_color		=	"000000">
<cfset grand_total_back_color	=	"ffffff">

<style>

th.column_heading, td.column_heading
{
	color:						#FFFFFF;
	background-color:			#004400;
	text-align:					right;
	font-size:					9px;
	font-weight:				bold;
	padding:					5px 0px 5px 0px;
	border-bottom:				0px #000000 solid;
}

td.grand_totals
{
	color:						#<cfoutput>#grand_total_color#</cfoutput>;
	background-color:			#<cfoutput>#grand_total_back_color#</cfoutput>;
	text-align:					right;
	font-size:					9px;
	font-weight:				bold;
	padding:					10px 5px 10px 0px;
	border-bottom:				0px #FFFFFF solid;
	border-top:					10px #000000 solid;
}

td.data_cell_level_I
{
	color:						#<cfoutput>#level_I_color#</cfoutput>;
	background-color:			#<cfoutput>#level_I_back_color#</cfoutput>;
	text-align:					left;
	font-size:					9px;
	font-weight:				bold;
	padding:					15px 5px 5px 0px;
	border-bottom:				2px #<cfoutput>#level_I_color#</cfoutput> solid;
}

td.data_cell_level_I_totals
{
	color:						#<cfoutput>#level_I_total_color#</cfoutput>;
	background-color:			#<cfoutput>#level_I_total_back_color#</cfoutput>;
	text-align:					right;
	font-size:					9px;
	font-weight:				bold;
	padding:					5px 5px 5px 0px;
	border-top:					0px #<cfoutput>#level_I_color#</cfoutput> solid;
	border-bottom:				0px #<cfoutput>#level_I_back_color#</cfoutput> solid;
}

td.data_cell_level_II
{
	color:						#<cfoutput>#level_II_color#</cfoutput>;
	background-color:			#<cfoutput>#level_II_back_color#</cfoutput>;
	text-align:					left;
	font-size:					9px;
	font-weight:				bold;
	padding:					5px 5px 5px 0px;
	border-bottom:				2px #<cfoutput>#level_II_color#</cfoutput> solid;
}

td.data_cell_level_II_totals
{
	color:						#<cfoutput>#level_II_total_color#</cfoutput>;
	background-color:			#<cfoutput>#level_II_total_back_color#</cfoutput>;
	text-align:					right;
	font-size:					9px;
	font-weight:				bold;
	padding:					5px 5px 5px 0px;
	border-top:					0px #<cfoutput>#level_II_color#</cfoutput> solid;
}

td.data_cell
{
	color:						#FFFFFF;
	background-color:			inherit;
	text-align:					right;
	font-size:					9px;
	font-weight:				bold;
	padding:					5px 5px 5px 0px;
	border-bottom:				1px #222222 solid;
}

th.right, td.right
{
	text-align:					right;
}

th.left, td.left
{
	text-align:					left;
}

th.left, td.center
{
	text-align:					center;
}

input.button
{
	width:						125px;
	margin:						0px 15px 10px 0px;
}

</style>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->

<script>
function show_Level_1() {
       $('tr[name=level_1_desc],tr[name=level_2_desc],tr[name=level_2],tr[name=level_3]').hide();
}

function show_Level_2() {
       $('tr[name=level_2_desc],tr[name=level_3]').hide();
       $('tr[name=level_1_desc],tr[name=level_2]').show();
}

function show_Level_3() {
       $('tr[name=level_1_desc],tr[name=level_2_desc],tr[name=level_2],tr[name=level_3]').show();
}
</script>


<!--- ----------------------------------------------------------------------------------------- --->
<input onClick="location.href='#gt'"; class="button" name="" type="button" value="grand totals" />
<input onClick="javascript:show_Level_1();" class="button" name="" type="button" value="regions" />
<input onClick="javascript:show_Level_2();" class="button" name="" type="button" value="sub-regions" />
<input onClick="javascript:show_Level_3();" class="button" name="" type="button" value="all levels" />
<!--- ----------------------------------------------------------------------------------------- --->





<cfset table_width = 905>
<cfset column_width = 75>
<cfset column_width_first = table_width - (9 * column_width)>


<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<div>
<table border="0" cellpadding="0" cellspacing="0" width="<cfoutput>#table_width#</cfoutput>">
	<tr>
    	<th width="<cfoutput>#column_width_first#</cfoutput>" class="column_heading" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">&nbsp;</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #004400 solid;">&nbsp;</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading left" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #004400 solid;">Total</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">&nbsp;</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #004400 solid;">&nbsp;</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading left" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #004400 solid;">YTD</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">&nbsp;</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #004400 solid;">&nbsp;</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading left" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #004400 solid;">YTG</th>
        <th width="<cfoutput>#column_width#</cfoutput>" class="column_heading" style="solid; border-bottom:1px #000000 solid; border-left:1px #004400 solid; border-right:1px #004400 solid;">&nbsp;</th>
    </tr>
    <tr>
    	<th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">&nbsp;</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">EQC</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">DIF</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">%</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">EQC</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">DIF</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">%</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">EQC</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #000000 solid;">DIF</th>
        <th class="column_heading" style="solid; border-bottom:0px #000000 solid; border-left:1px #004400 solid; border-right:1px #004400 solid;">%</th>
    </tr>
</table>
</div>
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<div style="overflow-x: hidden; overflow-y: scroll; height:400px; overflow: scroll; -webkit-overflow-scrolling: touch;">
<table border="0" cellpadding="0" cellspacing="0" width="<cfoutput>#table_width#</cfoutput>">


	<tr>
	    <td width="<cfoutput>#column_width_first#</cfoutput>"><a name="top">&nbsp;</a></td>

	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>
	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>
	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>

	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>
	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>
	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>

	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>
	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>
	    <td width="<cfoutput>#column_width#</cfoutput>">&nbsp;</td>
    </tr>


<!--- instanciate sub totals and totals variables ------------------------------------------ --->
<cfset Level1_Totals_EQC_Actual = 0>
<cfset Level1_Totals_EQC_Actual_Dif = 0>
<cfset Level1_Totals_EQC_Forecast = 0>
<cfset Level1_Totals_EQC_Forecast_Dif = 0>
<cfset Level1_Totals_EQC_Total = 0>
<cfset Level1_Totals_EQC_Total_Dif = 0>

<cfset Level2_Totals_EQC_Actual = 0>
<cfset Level2_Totals_EQC_Actual_Dif = 0>
<cfset Level2_Totals_EQC_Forecast = 0>
<cfset Level2_Totals_EQC_Forecast_Dif = 0>
<cfset Level2_Totals_EQC_Total = 0>
<cfset Level2_Totals_EQC_Total_Dif = 0>

<cfset GT_Totals_EQC_Actual = 0>
<cfset GT_Totals_EQC_Actual_Dif = 0>
<cfset GT_Totals_EQC_Forecast = 0>
<cfset GT_Totals_EQC_Forecast_Dif = 0>
<cfset GT_Totals_EQC_Total = 0>
<cfset GT_Totals_EQC_Total_Dif = 0>


<!--- instanciate the percents in case there are no records returned from the db --->
<cfset GT_TOTALS_EQC_TOTAL_PERCENT = 0>
<cfset GT_TOTALS_EQC_ACTUAL_PERCENT = 0>
<cfset GT_TOTALS_EQC_FORECAST_PERCENT = 0>




<cfoutput query="get_data_1" group="level_1_description">

	<tr name="level_1_desc" id="level_1_desc">
	    <td class="data_cell_level_I">#level_1_description#</td>

	    <td class="data_cell_level_I">&nbsp;</td>
	    <td class="data_cell_level_I">&nbsp;</td>
	    <td class="data_cell_level_I">&nbsp;</td>

	    <td class="data_cell_level_I">&nbsp;</td>
	    <td class="data_cell_level_I">&nbsp;</td>
	    <td class="data_cell_level_I">&nbsp;</td>

	    <td class="data_cell_level_I">&nbsp;</td>
	    <td class="data_cell_level_I">&nbsp;</td>
	    <td class="data_cell_level_I">&nbsp;</td>
    </tr>

<cfoutput group="level_2_description">

	<tr name="level_2_desc" id="level_2_desc">
	    <td class="data_cell_level_II">#level_2_description#</td>

	    <td class="data_cell_level_II">&nbsp;</td>
	    <td class="data_cell_level_II">&nbsp;</td>
	    <td class="data_cell_level_II">&nbsp;</td>

	    <td class="data_cell_level_II">&nbsp;</td>
	    <td class="data_cell_level_II">&nbsp;</td>
	    <td class="data_cell_level_II">&nbsp;</td>

	    <td class="data_cell_level_II">&nbsp;</td>
	    <td class="data_cell_level_II">&nbsp;</td>
	    <td class="data_cell_level_II">&nbsp;</td>
    </tr>

<cfoutput>


<!--- variables used at the territory level --->
<cfset EQC_Actual = EQC_Actual>
<cfset EQC_Actual_Dif = EQC_Actual - EQC_SPLY_Past_Months>
<cfset EQC_Actual_Percent = percentage(EQC_Actual_Dif, EQC_Actual)>
<!--- <cfset EQC_Actual_Percent = (EQC_Actual_Dif*100)/(application.util.validation.EasyIIf(EQC_Actual))> --->

<cfset EQC_Forecast = EQC_Forecast>
<cfset EQC_Forecast_Dif = EQC_Forecast - EQC_SPLY_Post_Months>
<cfset EQC_Forecast_Percent = percentage(EQC_Forecast_Dif, EQC_Forecast)>
<!--- <cfset EQC_Forecast_Percent = (EQC_Forecast_Dif*100)/(application.util.validation.EasyIIf(EQC_Forecast))> --->

<cfset EQC_Total = EQC_Actual + EQC_Forecast>
<cfset EQC_Total_Dif = EQC_Actual_Dif + EQC_Forecast_Dif>
<cfset EQC_Total_Percent = percentage(EQC_Total_Dif, EQC_Total)>
<!--- <cfset EQC_Total_Percent = (EQC_Total_Dif*100)/(application.util.validation.EasyIIf(EQC_Total))> --->

<!--- variables used for totals and subtotals --->
<cfset Level1_Totals_EQC_Actual = Level1_Totals_EQC_Actual + EQC_Actual>
<cfset Level1_Totals_EQC_Actual_Dif = Level1_Totals_EQC_Actual_Dif + EQC_Actual_Dif>
<cfset Level1_Totals_EQC_Actual_Percent = percentage(Level1_Totals_EQC_Actual_Dif, Level1_Totals_EQC_Actual)>
<!--- <cfset Level1_Totals_EQC_Actual_Percent = (Level1_Totals_EQC_Actual_Dif*100)/(application.util.validation.EasyIIf(Level1_Totals_EQC_Actual))> --->

<cfset Level1_Totals_EQC_Forecast = Level1_Totals_EQC_Forecast + EQC_Forecast>
<cfset Level1_Totals_EQC_Forecast_Dif = Level1_Totals_EQC_Forecast_Dif + EQC_Forecast_Dif>
<cfset Level1_Totals_EQC_Forecast_Percent = percentage(Level1_Totals_EQC_Forecast_Dif, Level1_Totals_EQC_Actual)>
<!--- <cfset Level1_Totals_EQC_Forecast_Percent = (Level1_Totals_EQC_Forecast_Dif*100)/(application.util.validation.EasyIIf(Level1_Totals_EQC_Actual))> --->

<cfset Level1_Totals_EQC_Total = Level1_Totals_EQC_Total + EQC_Total>
<cfset Level1_Totals_EQC_Total_Dif = Level1_Totals_EQC_Total_Dif + EQC_Total_Dif>
<cfset Level1_Totals_EQC_Total_Percent = percentage(Level1_Totals_EQC_Total_Dif,Level1_Totals_EQC_Total)>
<!--- <cfset Level1_Totals_EQC_Total_Percent = (Level1_Totals_EQC_Total_Dif*100)/(application.util.validation.EasyIIf(Level1_Totals_EQC_Total))> --->

<cfset Level2_Totals_EQC_Actual = Level2_Totals_EQC_Actual + EQC_Actual>
<cfset Level2_Totals_EQC_Actual_Dif = Level2_Totals_EQC_Actual_Dif + EQC_Actual_Dif>
<cfset Level2_Totals_EQC_Actual_Percent = percentage(Level2_Totals_EQC_Actual_Dif,Level2_Totals_EQC_Actual)>
<!--- <cfset Level2_Totals_EQC_Actual_Percent = (Level2_Totals_EQC_Actual_Dif*100)/(application.util.validation.EasyIIf(Level2_Totals_EQC_Actual))> --->

<cfset Level2_Totals_EQC_Forecast = Level2_Totals_EQC_Forecast + EQC_Forecast>
<cfset Level2_Totals_EQC_Forecast_Dif = Level2_Totals_EQC_Forecast_Dif + EQC_Forecast_Dif>
<cfset Level2_Totals_EQC_Forecast_Percent = percentage(Level2_Totals_EQC_Forecast_Dif, Level2_Totals_EQC_Forecast)>
<!--- <cfset Level2_Totals_EQC_Forecast_Percent = (Level2_Totals_EQC_Forecast_Dif*100)/(application.util.validation.EasyIIf(Level2_Totals_EQC_Forecast))> --->


<cfset Level2_Totals_EQC_Total = Level2_Totals_EQC_Total + EQC_Total>
<cfset Level2_Totals_EQC_Total_Dif = Level2_Totals_EQC_Total_Dif + EQC_Total_Dif>
<cfset Level2_Totals_EQC_Total_Percent = percentage(Level2_Totals_EQC_Total_Dif, Level2_Totals_EQC_Total)>
<!--- <cfset Level2_Totals_EQC_Total_Percent = (Level2_Totals_EQC_Total_Dif*100)/(application.util.validation.EasyIIf(Level2_Totals_EQC_Total))> --->



<!--- variables used in the grand total row --->
<cfset GT_Totals_EQC_Actual = GT_Totals_EQC_Actual + EQC_Actual>
<cfset GT_Totals_EQC_Actual_Dif = GT_Totals_EQC_Actual_Dif + EQC_Actual_Dif>
<cfset GT_Totals_EQC_Actual_Percent = percentage(GT_Totals_EQC_Total_Dif, GT_Totals_EQC_Actual)>
<!--- <cfset GT_Totals_EQC_Actual_Percent = (GT_Totals_EQC_Total_Dif*100)/(application.util.validation.EasyIIf(GT_Totals_EQC_Actual))> --->

<cfset GT_Totals_EQC_Forecast = GT_Totals_EQC_Forecast + EQC_Forecast>
<cfset GT_Totals_EQC_Forecast_Dif = GT_Totals_EQC_Forecast_Dif + EQC_Forecast_Dif>
<cfset GT_Totals_EQC_Forecast_Percent = percentage(GT_Totals_EQC_Forecast_Dif, GT_Totals_EQC_Forecast)>
<!--- <cfset GT_Totals_EQC_Forecast_Percent = (GT_Totals_EQC_Forecast_Dif*100)/(application.util.validation.EasyIIf(GT_Totals_EQC_Forecast))> --->

<cfset GT_Totals_EQC_Total = GT_Totals_EQC_Total + EQC_Total>
<cfset GT_Totals_EQC_Total_Dif = GT_Totals_EQC_Total_Dif + EQC_Total_Dif>
<cfset GT_Totals_EQC_Total_Percent = percentage(GT_Totals_EQC_Total_Dif, GT_Totals_EQC_Total)>
<!--- <cfset GT_Totals_EQC_Total_Percent = (GT_Totals_EQC_Total_Dif*100)/(application.util.validation.EasyIIf(GT_Totals_EQC_Total))> --->


	<tr name="level_3" id="level_3">
        <td class="data_cell left"><cfloop index="i" from="1" to="5">&nbsp;</cfloop>#level_3_description#</td>

        <td class="data_cell">#numberformat(EQC_Total, '(),')#</td>
        <td class="data_cell">#numberformat(EQC_Total_Dif, '(),')#</td>
        <td class="data_cell">#numberformat(EQC_Total_Percent, '(),.0')#%</td>

        <td class="data_cell">#numberformat(EQC_Actual, '(),')#</td>
        <td class="data_cell">#numberformat(EQC_Actual_Dif, '(),')#</td>
        <td class="data_cell">#numberformat(EQC_Actual_Percent, '(),.0')#%</td>

        <td class="data_cell">#numberformat(EQC_Forecast, '(),')#</td>
        <td class="data_cell">#numberformat(EQC_Forecast_Dif, '(),')#</td>
        <td class="data_cell">#numberformat(EQC_Forecast_Percent, '(),.0')#%</td>
    </tr>

</cfoutput>

	<!--- level 2 totals --->

	<tr name="level_2" id="level_2">
    	<td class="data_cell_level_II_totals">#level_2_description#</td>

    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Total, '(),')#</td>
    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Total_Dif, '(),')#</td>
    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Total_Percent, '(),.0')#%</td>

    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Actual, '(),')#</td>
    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Actual_Dif, '(),')#</td>
    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Actual_Percent, '(),.0')#%</td>

    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Forecast, '(),')#</td>
    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Forecast_Dif, '(),')#</td>
    	<td class="data_cell_level_II_totals">#numberformat(Level2_Totals_EQC_Forecast_Percent, '(),.0')#%</td>
    </tr>

<!--- reset values --->
<cfset Level2_Totals_EQC_Actual = 0>
<cfset Level2_Totals_EQC_Actual_Dif = 0>
<cfset Level2_Totals_EQC_Forecast = 0>
<cfset Level2_Totals_EQC_Forecast_Dif = 0>
<cfset Level2_Totals_EQC_Total = 0>
<cfset Level2_Totals_EQC_Total_Dif = 0>


</cfoutput>

	<!--- level 1 totals --->
	<tr  name="level_1" id="level_1">
    	<td class="data_cell_level_I_totals">#level_1_description#</td>

    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Total, '(),')#</td>
    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Total_Dif, '(),')#</td>
    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Total_Percent, '(),.0')#%</td>

    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Actual, '(),')#</td>
    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Actual_Dif, '(),')#</td>
    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Actual_Percent, '(),.0')#%</td>

    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Forecast, '(),')#</td>
    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Forecast_Dif, '(),')#</td>
    	<td class="data_cell_level_I_totals">#numberformat(Level1_Totals_EQC_Forecast_Percent, '(),.0')#%</td>
    </tr>

<!--- reset values --->
<cfset Level1_Totals_EQC_Actual = 0>
<cfset Level1_Totals_EQC_Actual_Dif = 0>
<cfset Level1_Totals_EQC_Forecast = 0>
<cfset Level1_Totals_EQC_Forecast_Dif = 0>
<cfset Level1_Totals_EQC_Total = 0>
<cfset Level1_Totals_EQC_Total_Dif = 0>


</cfoutput>


<cfoutput>

<!--- grand totals --->
<tr>
	<td class="grand_totals"><a name="gt">&nbsp;</a>Grand</td>

	<td class="grand_totals">#numberformat(GT_Totals_EQC_Total, ',')#</td>
	<td class="grand_totals">#numberformat(GT_Totals_EQC_Total_Dif, ',')#</td>
	<td class="grand_totals">#numberformat(GT_Totals_EQC_Total_Percent, ',.0')#%</td>

	<td class="grand_totals">#numberformat(GT_Totals_EQC_Actual, ',')#</td>
	<td class="grand_totals">#numberformat(GT_Totals_EQC_Actual_Dif, ',')#</td>
	<td class="grand_totals">#numberformat(GT_Totals_EQC_Actual_Percent, ',.0')#%</td>

	<td class="grand_totals">#numberformat(GT_Totals_EQC_Forecast, ',')#</td>
	<td class="grand_totals">#numberformat(GT_Totals_EQC_Forecast_Dif, ',')#</td>
	<td class="grand_totals">#numberformat(GT_Totals_EQC_Forecast_Percent, ',.0')#%</td>
</tr>
</cfoutput>


<tr><td colspan="100%"><br /><input onClick="javascript:location.href='#top'"; class="button" name="" type="button" value="back to top" /></td></tr>


</table>


</div>




<!--- ----------------------------------------------------------------------------------------- --->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
<!--- ----------------------------------------------------------------------------------------- --->