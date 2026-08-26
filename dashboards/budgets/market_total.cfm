
<!---

<!--- ----------------------------------------------------------------------------------------- --->
<!--- get all the budget classes that could be retrieved -------------------------------------  --->
<!--- ----------------------------------------------------------------------------------------- --->

<cfquery name="Get_budget_classes" datasource="#Application.Datasource#">
SELECT	distinct Budget_Class.Budget_Class_Desc	as	Budget_Class_Desc,
		Budget_Class.start_date

FROM	dbo.dashboards_budget_weekly_summary
		

        left join Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
        left join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID

WHERE	1=1

        AND     dash_budget_type = 3
        <cfif 	user_market_list neq "">
        AND		market_id in (#user_market_list#)
        <cfelse>
        AND		1=2 <!--- Do not return any record if user is below this level --->

Order by Budget_Class.start_date

</cfif>
</cfquery>



<cfparam name="form.budget_class_value" default="" type="any">

<!--- If somethign is comign from the form scope use it --->
<cfif form.budget_class_value eq "">
      <!--- if form scope is empty, use cookie --->
      <cfif isdefined("cookie.budget_classes")>
            <cfset form.budget_class_value = cookie.budget_classes />
      <cfelse> <!--- if form scope is empty, and cookie is nto set, use all classes --->
            <cfset form.budget_class_value = ValueList(Get_budget_classes.Budget_Class_Desc,",") />
      </cfif>

</cfif>

<cfif form.budget_class_value eq "">
	<cfset form.budget_class_value = 0 />
</cfif>

<cfset budget_classes_list = form.budget_class_value />

<div style="text-align:left; font-size:10px; margin:10px 10px -10px 10px;">


    <form action="display.cfm?content=78888-94737-84955-80478" method="post">
    <table>
    <tr>
        <cfoutput query="Get_budget_classes">
        <td style="color:##DDDDDD;">#Budget_Class_Desc#</td>
        <td><input name="budget_class_value" type="checkbox" value="#Budget_Class_Desc#" style="width:20px; margin: 2px 0px 0px 0px;" <cfif ListFind(budget_classes_list, Budget_Class_Desc)>checked</cfif> /></td>
        </cfoutput>
        <td><input name="" type="submit" style="margin:3px 0px 0px 0px;" /></td>
    </tr>
    </table>
    </form>

      <!--- create the cookie with the budget classes values  --->
    <cfcookie name="budget_classes" value="#form.budget_class_value#">

</div>

<hr style="color: #f00;  background-color: #f00;  height: 2px; border:0px;" />

 --->

<style>
	
	div.note
	{
		color:			#FFFF00;
		font-size:		11px;
		font-style: 	italic;
	}
		
</style>











<cfparam name="form.budget_class_value" default="" type="any">

<!--- If somethign is comign from the form scope use it --->
<cfif form.budget_class_value eq "">
      <!--- if form scope is empty, use cookie --->
      <cfif isdefined("cookie.budget_classes")>
            <cfset form.budget_class_value = cookie.budget_classes />
      </cfif>


		<cfif form.budget_class_value eq ""> <!--- if form scope is empty, and cookie is nto set, use all classes --->

		<cfquery name="Get_budget_classes" datasource="#Application.Datasource#">
		SELECT	distinct Budget_Class.Budget_Class_Desc	as	Budget_Class_Desc,
				Budget_Class.start_date
		
		FROM	dbo.dashboards_budget_weekly_summary
				
		
		        left join Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
		        left join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID
		
		WHERE	1=1
		
		        AND     dash_budget_type = 3
		        <cfif 	user_market_list neq "">
		        AND		market_id in (#user_market_list#)
		        <cfelse>
		        AND		1=2 <!--- Do not return any record if user is below this level --->
				Order by Budget_Class.start_date
				</cfif>

		</cfquery>

		<cfset form.budget_class_value = ValueList(Get_budget_classes.Budget_Class_Desc,",") />

      </cfif>

</cfif>












<cfset budget_classes_list = form.budget_class_value />
<BR />
Budget Class(es) presented: <cfoutput>#budget_classes_list#</cfoutput>
<div class="note">The only budget classes used by this dashboard, are the ones set by the "Select Budget Classes"</div>


<br/><br/>
<span style="color:red; font-size:12px;">
(Values expressed in 1,000s)
</span>
<br/>

<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
SELECT	dash_budget_expired,

        dashboards_budget_weekly_summary.zone_desc,
        dashboards_budget_weekly_summary.zone_code,

        dashboards_budget_weekly_summary.region_desc,
        dashboards_budget_weekly_summary.region_code,

        dashboards_budget_weekly_summary.market_desc,
        dashboards_budget_weekly_summary.market_code,
        
        '' as budget_desc,
        '' as budget_type,
        
        Budget_Class.Budget_Class_Desc,
	
        sum(dashboards_budget_weekly_summary.budget_dollars/1000) as budget_dollars,
        
        sum(dashboards_budget_weekly_summary.budget_dollars_commit/1000) as budget_dollars_commit,
        sum(dashboards_budget_weekly_summary.budget_commit_bal/1000) as budget_commit_bal,





        (100 * (sum(dashboards_budget_weekly_summary.budget_dollars_commit) / CASE WHEN sum(dashboards_budget_weekly_summary.budget_dollars) = 0 THEN 1000 ELSE sum(dashboards_budget_weekly_summary.budget_dollars) END)) as budget_commit_percent,






        (100 * (1 - (sum(dashboards_budget_weekly_summary.budget_dollars_commit) / CASE WHEN sum(dashboards_budget_weekly_summary.budget_dollars) = 0 THEN 1000 ELSE sum(dashboards_budget_weekly_summary.budget_dollars) END))) as budget_commit_bal_percent,
        sum(dashboards_budget_weekly_summary.budget_dollars_paid/1000) as budget_dollars_paid,
        sum(dashboards_budget_weekly_summary.budget_paid_bal/1000) as budget_paid_bal,
        (100 * (sum(dashboards_budget_weekly_summary.budget_dollars_paid) / CASE WHEN sum(dashboards_budget_weekly_summary.budget_dollars) = 0 THEN 1000 ELSE sum(dashboards_budget_weekly_summary.budget_dollars) END)) as budget_paid_percent,
        (100 * (1 - (sum(dashboards_budget_weekly_summary.budget_dollars_paid) / CASE WHEN sum(dashboards_budget_weekly_summary.budget_dollars) = 0 THEN 1000 ELSE sum(dashboards_budget_weekly_summary.budget_dollars) END))) as budget_paid_bal_percent


        
        -- dashboards_budget_weekly_summary.dash_budget_type

FROM	dbo.dashboards_budget_weekly_summary

        left join Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
        left join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID

WHERE	1=1
		AND		dash_budget_type = 3
        
<cfif 	user_market_list neq "">
AND		market_id in (#user_market_list#)
<cfelse>
AND		1=2 <!--- Do not return any record if user is below this level --->
</cfif>

        <cfif 	budget_classes_list neq "">
        AND Budget_Class.Budget_Class_Desc IN (#ListQualify(budget_classes_list,"'")#)
        <cfelse>
        AND 1=2 <!--- Do not return any record if budget_classes_list is empty --->
        </cfif>


group by

		dash_budget_expired,

        dashboards_budget_weekly_summary.zone_desc,
        dashboards_budget_weekly_summary.zone_code,

        dashboards_budget_weekly_summary.region_desc,
        dashboards_budget_weekly_summary.region_code,

        dashboards_budget_weekly_summary.market_desc,
        dashboards_budget_weekly_summary.market_code,
                
        Budget_Class.Budget_Class_Desc


order by zone_desc, region_desc, budget_dollars desc, market_desc

</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->


<br />


<style>

th.column_heading, th.column_heading_text
{
	color:						#FFFFFF;
	background-color:			#006600;
	text-align:					center;
	font-size:					10px;
	font-weight:				bold;
	padding:					15px 10px 5px 5px;
}

th.column_heading_text
{
	text-align:					left;
}

td.data_cell, td.data_cell_text
{
	color:						#aaaaaa;
	text-align:					right;
	font-size:					10px;
	padding:					5px 10px 5px 5px;
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
	padding:					5px 10px 5px 5px;
}

td.data_grid_totals
{
	color:						#000000;
	background-color:			#FFFFFF;
	text-align:					right;
	font-size:					13px;
	font-weight:				bold;
	padding:					10px 10px 10px 5px;
	border-top:					0px #ffffff solid;
}

td.left, th.left
{
	text-align:					left;
}

td.right, th.right
{
	text-align:					right;
}

td.center, th.center
{
	text-align:					center;
}


</style>

<table width="900" border="0" cellspacing="0" cellpadding="0" id="thetable">

<thead>
	<tr>
		<th class="column_heading_text"><cfoutput>#label.market_total.singular#</cfoutput></th>
		<th class="column_heading right" width="120">budget<br />Class</th>
		<th class="column_heading right" width="120"><CFOUTPUT>#label.budget_dollar.singular#</CFOUTPUT><br /></th>
		<th class="column_heading right" width="120">commit<br />%</th>
		<th class="column_heading right" width="120">commit<br />bal %</th>
		<th class="column_heading right" width="120">paid<br />%</th>
		<th class="column_heading right" width="120">paid&nbsp;&nbsp;&nbsp;<br />bal %&nbsp;&nbsp;&nbsp;</th>
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

<cfoutput query="Get_Data_1" group="zone_desc">

  <tr>
    <td class="data_grid_level1" colspan="100%" nowrap>#zone_desc# - #zone_code#</td>
  </tr>

<cfoutput group="region_desc">
  <tr>
  	<td class="data_grid_level2"  colspan="100%"><cfloop index="i" from="1" to="15">&nbsp;</cfloop>#region_desc# - #region_code#</td>
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
		<td class="data_cell_text" nowrap="nowrap"><cfloop index="i" from="1" to="30">&nbsp;</cfloop>#market_desc# - #market_code#</td>
		<td class="data_cell" width="120">#Budget_Class_Desc#</td>
		<td class="data_cell" width="120">#mydollarformat(budget_dollars)#</td>
		<td class="data_cell" width="120">#mydollarformat(budget_dollars_commit)#<br />#numberformat(budget_commit_percent, '()')#%</td>
		<td class="data_cell" width="120">#mydollarformat(budget_commit_bal)#<br />#numberformat(budget_commit_bal_percent, '()')#%</td>
		<td class="data_cell" width="120">#mydollarformat(budget_dollars_paid)#<br />#numberformat(budget_paid_percent,'()')#%</td>
		<td class="data_cell" width="120">#mydollarformat(budget_paid_bal)#<br />#numberformat(budget_paid_bal_percent, '()')#%</td>
	</tr>

</cfoutput>  

	<tr bgcolor="##000000">
		<td class="data_grid_subtotals" style="text-align:left;">Sub Total</td>
		<td class="data_grid_subtotals">&nbsp;</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars)#</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_commit)#<br />#numberformat(100*sum_budget_dollars_commit/application.util.validation.EasyIIf(sum_budget_dollars), "()999.9")#%</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_commit_bal)#<br />#numberformat(100*sum_budget_commit_bal/application.util.validation.EasyIIf(sum_budget_dollars), "()999.9")#%</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_dollars_paid)#<br />#numberformat(100*sum_budget_dollars_paid/application.util.validation.EasyIIf(sum_budget_dollars), "()999.9")#%</td>
		<td class="data_grid_subtotals">#mydollarformat(sum_budget_paid_bal)#<br />#numberformat(100*sum_budget_paid_bal/application.util.validation.EasyIIf(sum_budget_dollars), "()999.9")#%</td>
	</tr>
  

<!--- reset the totals variables ------------------------------------------------------- --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>

</cfoutput>  

</cfoutput>

<cfoutput>

	<tr bgcolor="##000000">
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid; text-align:left;">Grand Total</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;"nowrap="nowrap">&nbsp;</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;"nowrap="nowrap">#mydollarformat(grand_sum_budget_dollars)#</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;"nowrap="nowrap">#mydollarformat(grand_sum_budget_dollars_commit)#<br />#numberformat(100*grand_sum_budget_dollars_commit/application.util.validation.EasyIIf(grand_sum_budget_dollars),"()999.9")#%</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;"nowrap="nowrap">#mydollarformat(grand_sum_budget_commit_bal)#<br />#numberformat(100*grand_sum_budget_commit_bal/application.util.validation.EasyIIf(grand_sum_budget_dollars),"()999.9")#%</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;"nowrap="nowrap">#mydollarformat(grand_sum_budget_dollars_paid)#<br />#numberformat(100*grand_sum_budget_dollars_paid/application.util.validation.EasyIIf(grand_sum_budget_dollars),"()999.9")#%</td>
		<td class="data_grid_subtotals" style="border-top:5px ##FFA500 solid;"nowrap="nowrap">#mydollarformat(grand_sum_budget_paid_bal)#<br />#numberformat(100*grand_sum_budget_paid_bal/application.util.validation.EasyIIf(grand_sum_budget_dollars),"()999.9")#%</td>
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
