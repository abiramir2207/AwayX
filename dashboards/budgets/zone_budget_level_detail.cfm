<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the sql code for this dashboard ----------------------------------------------------- --->
<cfinclude template="zone_budget_level_detail_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<br />

<table width="900" border="0" cellspacing="0" cellpadding="0" id="thetable">

<thead>
	<tr>
		<th><cfoutput>#zone_label#</cfoutput>&nbsp;</th>
		<th>budget desc&nbsp;</th>
		<th>budget $&nbsp;</th>
		<th>commit<br />%&nbsp;</th>
		<th>commit bal<br />%&nbsp;</th>
		<th>paid<br />%&nbsp;</th>
		<th>paid bal<br />%&nbsp;</th>
	</tr>
</thead>
<!--- instanciate the totals variables ------------------------------------------------------- --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>


<tbody>
<cfoutput query="Get_Data_1" group="zone_code">

  <tr>
    <td class="data_grid_level1">#zone_desc# - #zone_code#</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
  </tr>


<cfoutput>

<!--- calculate the totals ------------------------------------------------------------------ --->
<cfset sum_budget_dollars=sum_budget_dollars+budget_dollars>
<cfset sum_budget_dollars_commit=sum_budget_dollars_commit+budget_dollars_commit>
<cfset sum_budget_commit_bal=sum_budget_commit_bal+budget_commit_bal>
<cfset sum_budget_dollars_paid=sum_budget_dollars_paid+budget_dollars_paid>
<cfset sum_budget_paid_bal=sum_budget_paid_bal+budget_paid_bal>

  <tr bgcolor="###iif(Get_Data_1.currentrow MOD 2,DE('373737'), DE('222222'))#">
    <td class="data_grid_level3">&nbsp;</td>

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
    <td class="data_grid_subtotals">Totals&nbsp;</td>
    <td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars)#&nbsp;</td>
    <td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_commit)#<br />
    							 #numberformat(100*sum_budget_dollars_commit/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
    <td class="data_grid_subtotals">#mydollarformat(sum_budget_commit_bal)#<br />
    							 #numberformat(100*sum_budget_commit_bal/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
    <td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_paid)#<br />
    							 #numberformat(100*sum_budget_dollars_paid/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>
    <td class="data_grid_subtotals">#mydollarformat(sum_budget_paid_bal)#<br />
    							 #numberformat(100*sum_budget_paid_bal/application.util.validation.EasyIIf(sum_budget_dollars), "999.9")#%&nbsp;</td>

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
