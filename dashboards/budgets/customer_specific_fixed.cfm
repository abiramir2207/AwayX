<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the sql code for this dashboard ----------------------------------------------------- --->
<cfinclude template="customer_specific_fixed_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<br />

<!--- instanciate the totals variables ------------------------------------------------------- --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>

<table width="900" border="0" cellspacing="0" cellpadding="0" id="thetable">
<thead>
	<tr>
		<TH>distributor<br />ship to&nbsp;</TH>
		<TH>budget $&nbsp;</TH>
		<TH>commit<br />%&nbsp;</TH>
		<TH>commit bal<br />%&nbsp;</TH>
		<TH>paid<br />%&nbsp;</TH>
		<TH>paid bal<br />%&nbsp;</TH>
	</tr>
</thead>

<tbody>
<cfoutput query="Get_Data_1">


<!--- calculate the totals ------------------------------------------------------------------ --->
<cfset sum_budget_dollars=sum_budget_dollars+budget_dollars>
<cfset sum_budget_dollars_commit=sum_budget_dollars_commit+budget_dollars_commit>
<cfset sum_budget_commit_bal=sum_budget_commit_bal+budget_commit_bal>
<cfset sum_budget_dollars_paid=sum_budget_dollars_paid+budget_dollars_paid>
<cfset sum_budget_paid_bal=sum_budget_paid_bal+budget_paid_bal>


	<tr bgcolor="###iif(Get_Data_1.currentrow MOD 2,DE('373737'), DE('222222'))#">
		<td class="data_grid_level3">#dist_name#<br />#shipto#&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_dollars)#&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_dollars_commit)#<br />#numberformat(budget_commit_percent, '_._')#%&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_commit_bal)#<br />#numberformat(budget_commit_bal_percent, '_._')#%&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_dollars_paid)#<br />#numberformat(budget_paid_percent,'_._')#%&nbsp;</td>
		<td class="data_grid_level3">#mydollarformat(budget_paid_bal)#<br />#numberformat(budget_paid_bal_percent,'_._')#%&nbsp;</td>
	</tr>
  
</cfoutput>

<cfoutput>

	<tr bgcolor="##000000">
		<td class="data_grid_subtotals">Totals&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars)#&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_commit)#<br />#numberformat(100*sum_budget_dollars_commit/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_commit_bal)#<br />#numberformat(100*sum_budget_commit_bal/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_paid)#<br />#numberformat(100*sum_budget_dollars_paid/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_paid_bal)#<br />#numberformat(100*sum_budget_paid_bal/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
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
