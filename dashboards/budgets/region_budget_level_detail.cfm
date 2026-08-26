<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the sql code for this dashboard ----------------------------------------------------- --->
<cfinclude template="region_budget_level_detail_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<br />

<table width="900" border="0" cellspacing="0" cellpadding="0" id="thetable">

<thead>
	<tr>
		<TH><cfoutput>#region_label#</cfoutput>&nbsp;</TH>
		<TH><cfoutput>#market_label#</cfoutput>&nbsp;</TH>
		<TH>budget $&nbsp;</TH>
		<TH>commit<br />%&nbsp;</TH>
		<TH>commit bal<br />%&nbsp;</TH>
		<TH>paid<br />%&nbsp;</TH>
		<TH>paid bal<br />%&nbsp;</TH>
	</tr>
</thead>

<!--- instanciate the sub totals and totals variables ------------------------------------------ --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>

<cfset grand_sum_budget_dollars=0>
<cfset grand_sum_budget_dollars_commit=0>
<cfset grand_sum_budget_commit_bal=0>
<cfset grand_sum_budget_dollars_paid=0>
<cfset grand_sum_budget_paid_bal=0>

<tbody>

<cfoutput query="Get_Data_1" group="region_code">
	<tr>
		<td colspan="100%" class="data_grid_level1">#region_desc#<br />#region_code#
		<!--- 
		<br />Expired Budget:&nbsp;&nbsp;#numberformat(dash_budget_expired*100,'_')#%&nbsp;
		----------------------------------------------------------------------------------------- --->
		</td>
	</tr>
<cfoutput>

<!--- calculate the totals ------------------------------------------------------------------ --->
<cfset sum_budget_dollars=sum_budget_dollars+budget_dollars>
<cfset sum_budget_dollars_commit=sum_budget_dollars_commit+budget_dollars_commit>
<cfset sum_budget_commit_bal=sum_budget_commit_bal+budget_commit_bal>
<cfset sum_budget_dollars_paid=sum_budget_dollars_paid+budget_dollars_paid>
<cfset sum_budget_paid_bal=sum_budget_paid_bal+budget_paid_bal>

<!--- calculate the grand totals ------------------------------------------------------------------ --->
<cfset grand_sum_budget_dollars=grand_sum_budget_dollars+budget_dollars>
<cfset grand_sum_budget_dollars_commit=grand_sum_budget_dollars_commit+budget_dollars_commit>
<cfset grand_sum_budget_commit_bal=grand_sum_budget_commit_bal+budget_commit_bal>
<cfset grand_sum_budget_dollars_paid=grand_sum_budget_dollars_paid+budget_dollars_paid>
<cfset grand_sum_budget_paid_bal=grand_sum_budget_paid_bal+budget_paid_bal>  


	<tr bgcolor="###iif(Get_Data_1.currentrow MOD 2,DE('373737'), DE('222222'))#">
		<td class="data_grid_level3" width="185">&nbsp;</td>
		<td class="data_grid_level3">#budget_desc#<br />#budget_type# - #budget_cal#&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_dollars)#&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_dollars_commit)#<br />#numberformat(budget_commit_percent, '_._')#%&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_commit_bal)#<br />#numberformat(budget_commit_bal_percent, '_._')#%&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_dollars_paid)#<br />#numberformat(budget_paid_percent,'_._')#%&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_paid_bal)#<br />#numberformat(budget_paid_bal_percent,'_._')#%&nbsp;</td>
	</tr>
</cfoutput>  

	<tr bgcolor="##000000">
		<td class="data_grid_subtotals">&nbsp;</td>
		<td class="data_grid_subtotals">Sub Total&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars)#&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_commit)#<br />#numberformat(100*sum_budget_dollars_commit/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_commit_bal)#<br />#numberformat(100*sum_budget_commit_bal/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_paid)#<br />#numberformat(100*sum_budget_dollars_paid/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_paid_bal)#<br />#numberformat(100*sum_budget_paid_bal/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
	</tr>
 
<!--- instanciate the totals variables ------------------------------------------------------- --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0> 
</cfoutput>  

<cfoutput>
	<tr bgcolor="##000000">
		<td class="data_grid_totals">&nbsp;</td>
		<td class="data_grid_totals">Grand Total&nbsp;</td>
		<td class="data_grid_totals">#mydollarformat(grand_sum_budget_dollars)#&nbsp;</td>
		<td class="data_grid_totals">#mydollarformat(grand_sum_budget_dollars_commit)#<br />#numberformat(100*grand_sum_budget_dollars_commit/application.util.validation.EasyIIf(grand_sum_budget_dollars),"999.9")#%</td>
		<td class="data_grid_totals">#mydollarformat(grand_sum_budget_commit_bal)#<br />#numberformat(100*grand_sum_budget_commit_bal/application.util.validation.EasyIIf(grand_sum_budget_dollars),"999.9")#%</td>
		<td class="data_grid_totals">#mydollarformat(grand_sum_budget_dollars_paid)#<br />#numberformat(100*grand_sum_budget_dollars_paid/application.util.validation.EasyIIf(grand_sum_budget_dollars),"999.9")#%</td>
		<td class="data_grid_totals">#mydollarformat(grand_sum_budget_paid_bal)#<br />#numberformat(100*grand_sum_budget_paid_bal/application.util.validation.EasyIIf(grand_sum_budget_dollars),"999.9")#%</td>
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
