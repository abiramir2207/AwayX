<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
SELECT	dash_budget_expired,

        budget_desc,
        budget_type,
        
        budget_dollars as budget_dollars,
        
        budget_dollars_commit as budget_dollars_commit,
        budget_commit_bal as budget_commit_bal,
        (100*budget_commit_percent) as budget_commit_percent,
        (100*(1-budget_commit_percent)) as budget_commit_bal_percent,
        
        budget_dollars_paid as budget_dollars_paid,
        budget_paid_bal as budget_paid_bal,
        (100*budget_paid_percent) as budget_paid_percent,
        (100*(1-budget_paid_percent)) as budget_paid_bal_percent,
        shipto,
        dist_name

FROM	dbo.dashboards_budget_weekly_summary

WHERE	1=1
AND		dist_name <> ''
<cfif 	user_market_list neq "">
AND		market_id in (#user_market_list#)
<cfelse>
AND		1=2 <!--- Do not return any record if user is below this level --->
</cfif>

order by dist_name asc, budget_dollars desc

</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->

<br />


<style>

th.column_heading, th.column_heading_text
{
	color:						#FFFFFF;
	background-color:			#006600;
	text-align:					right;
	font-size:					11px;
	font-weight:				bold;
	padding:					10px 10px 5px 10px;
}

th.column_heading_text
{
	text-align:					left;
}

td.data_cell, td.data_cell_text
{
	color:						#aaaaaa;
	text-align:					right;
	font-size:					11px;
	padding:					3px 10px 3px 10px;
}


td.data_cell_text
{
	text-align:					left;
}

td.data_grid_subtotals
{
	color:						#FFFFFF;
	background-color:			#000000;
	text-align:					right;
	font-size:					10px;
	font-weight:				bold;
	padding:					5px 10px 10px 10px;
}

</style>


<!--- instanciate the totals variables ------------------------------------------------------- --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>


<cfset column_width = "150px">

<table width="900" border="0" cellspacing="0" cellpadding="0" id="thetable">

<thead>
	<tr>
		<th style="width:100%;" class="column_heading_text">distributor</th>
		<th style="width:#column_width#;" class="column_heading_text">account</th>
		<th style="width:#column_width#;" class="column_heading_text">type</th>
		<th style="width:#column_width#;" class="column_heading">budget $</th>
		<th style="width:#column_width#;" class="column_heading">commit<br />%</th>
		<th style="width:#column_width#;" class="column_heading">commit<br />bal %</th>
		<th style="width:#column_width#;" class="column_heading">paid<br />%</th>
		<th style="width:#column_width#;" class="column_heading">paid&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br />bal %&nbsp;&nbsp;&nbsp;</th>
	</tr>
</thead>

<tbody>



<cfoutput group="budget_type">

<tr>
	<td colspan="100%">#budget_type#</td>
</tr>

<cfoutput query="Get_Data_1">


<!--- calculate the totals ------------------------------------------------------------------ --->
<cfset sum_budget_dollars=sum_budget_dollars+budget_dollars>
<cfset sum_budget_dollars_commit=sum_budget_dollars_commit+budget_dollars_commit>
<cfset sum_budget_commit_bal=sum_budget_commit_bal+budget_commit_bal>
<cfset sum_budget_dollars_paid=sum_budget_dollars_paid+budget_dollars_paid>
<cfset sum_budget_paid_bal=sum_budget_paid_bal+budget_paid_bal>
	
	<tr bgcolor="###iif(Get_Data_1.currentrow MOD 2,DE('373737'), DE('222222'))#">
		<td class="data_cell_text">#dist_name#</td>
		<td class="data_cell_text">#shipto#</td>
		<td class="data_cell_text">#budget_type#</td>
		<td class="data_cell">#mydollarformat(budget_dollars)#</td>
		<td class="data_cell">#mydollarformat(budget_dollars_commit)#<br />#numberformat(budget_commit_percent, ',')#%</td>
		<td class="data_cell">#mydollarformat(budget_commit_bal)#<br />#numberformat(budget_commit_bal_percent, ',')#%</td>
		<td class="data_cell">#mydollarformat(budget_dollars_paid)#<br />#numberformat(budget_paid_percent,',')#%</td>
		<td class="data_cell">#mydollarformat(budget_paid_bal)#<br />#numberformat(budget_paid_bal_percent,',')#%</td>
	</tr>
	
</cfoutput>
</cfoutput>


<cfoutput>

	<tr bgcolor="##000000">
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;"></td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;"></td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid; text-align:left;">Totals</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;">#mydollarformat(sum_budget_dollars)#</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;">#mydollarformat(sum_budget_dollars_commit)#<br />#numberformat(100*sum_budget_dollars_commit/application.util.validation.EasyIIf(sum_budget_dollars), ",")#%</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;">#mydollarformat(sum_budget_commit_bal)#<br />#numberformat(100*sum_budget_commit_bal/application.util.validation.EasyIIf(sum_budget_dollars), ",")#%</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;">#mydollarformat(sum_budget_dollars_paid)#<br />#numberformat(100*sum_budget_dollars_paid/application.util.validation.EasyIIf(sum_budget_dollars), ",")#%</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;">#mydollarformat(sum_budget_paid_bal)#<br />#numberformat(100*sum_budget_paid_bal/application.util.validation.EasyIIf(sum_budget_dollars), ",")#%</td>
	</tr>

</cfoutput>

</tbody>
  
</table>

<!--- ----------------------------------------------------------------------------------------- --->
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
<!--- ----------------------------------------------------------------------------------------- --->

<br />
