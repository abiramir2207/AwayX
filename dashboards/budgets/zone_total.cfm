<!--- ----------------------------------------------------------------------------------------- --->
<!--- get the sql code for this dashboard ----------------------------------------------------- --->
<cfinclude template="zone_total_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<br />

<table width="900" border="0" cellspacing="0" cellpadding="0"  id="thetable">

<thead>
	<tr>
        <th><cfoutput>#zone_label#</cfoutput>&nbsp;</th>
        <th>budget $&nbsp;</th>
        <th>commit<br />%&nbsp;</th>
        <th>commit bal<br />%&nbsp;</th>
        <th>paid<br />%&nbsp;</th>
        <th>paid bal<br />%&nbsp;</th>
	</tr>
</thead>

<tbody>

<cfoutput query="Get_Data_1">

  <tr>
    <td class="data_grid_level1">#zone_desc# - #zone_code#</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
    <td class="data_grid_level1">&nbsp;</td>
  </tr>

<cfoutput>
  <tr bgcolor="###iif(Get_Data_1.currentrow MOD 2,DE('373737'), DE('222222'))#">
    <td class="data_grid_level3">&nbsp;</td>
    <td class="data_grid_level3">#mydollarFormat(budget_dollars)#&nbsp;</td>
    <td class="data_grid_level3">#mydollarformat(budget_dollars_commit)#<br />#numberformat(budget_commit_percent, '_._')#%&nbsp;</td>
    <td class="data_grid_level3">#mydollarformat(budget_commit_bal)#<br />#numberformat(budget_commit_bal_percent, '_._')#%&nbsp;</td>
    <td class="data_grid_level3">#mydollarformat(budget_dollars_paid)#<br />#numberformat(budget_paid_percent,'_._')#%&nbsp;</td>
    <td class="data_grid_level3">#mydollarformat(budget_paid_bal)#<br />#numberformat(budget_paid_bal_percent,'_._')#%&nbsp;</td>
  </tr>
</cfoutput>  
</tbody>

  
</cfoutput>  
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
