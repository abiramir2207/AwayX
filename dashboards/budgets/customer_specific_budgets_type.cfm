<!--- --->
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

        AND		dist_name <> ''
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
<cfset budget_classes_list = form.budget_class_value />
<div style="text-align:left; font-size:10px; margin:10px 10px -10px 10px;">
    <form action="display.cfm?content=64967-42449-38955-35403" method="post">
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
<!--- Budget Class(es) presented: <cfoutput>#budget_classes_list#</cfoutput> --->
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
      <cfelse> <!--- if form scope is empty, and cookie is nto set, use all classes --->
            <cfset form.budget_class_value = ValueList(Get_budget_classes.Budget_Class_Desc,",") />
      </cfif>
</cfif>
<cfset budget_classes_list = form.budget_class_value />
<BR />
Budget Class(es) presented: <cfoutput>#budget_classes_list#</cfoutput>
<div class="note">The only budget classes used by this dashboard, are the ones set by the "Select Budget Classes"</div>






















<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
SELECT	dash_budget_expired,

        dashboards_budget_weekly_summary.budget_desc,
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

        left join Budget on Budget.Budget_ID = Dashboards_Budget_Weekly_Summary.Budget_ID
        left join Budget_Class on Budget_Class.Budget_Class_ID = Budget.Budget_Class_ID


WHERE	1=1
AND		dist_name <> ''
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



order by budget_type, dist_name asc, budget_dollars desc

</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->
<br />
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="customer_specific_budgets.css">
<!--- ----------------------------------------------------------------------------------------- --->

<!--- instanciate the subtotals variables ------------------------------------------------------- --->
<cfset sub_sum_budget_dollars=0>
<cfset sub_sum_budget_dollars_commit=0>
<cfset sub_sum_budget_commit_bal=0>
<cfset sub_sum_budget_dollars_paid=0>
<cfset sub_sum_budget_paid_bal=0>

<!--- instanciate the grand totals variables ------------------------------------------------------- --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>


<cfset columns = 7 >
<cfset table_width = 920>
<cfset column_width = 85>
<cfset column_width_first = (table_width - ((columns - 1) * column_width))>

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="customer_specific_budgets_buttons.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<div style="overflow-x: hidden; overflow-y: hidden; height:35px; padding-left:10px; margin:0px;">
<table width="<cfoutput>#table_width#</cfoutput>" align="left" cellspacing="0">
	<tr>
		<td width="<cfoutput>#column_width_first#</cfoutput>" class="column_heading left">budget type - distributor</td>
		<td width="<cfoutput>#column_width#</cfoutput>" class="column_heading left">account</td>
		<td width="<cfoutput>#column_width#</cfoutput>" class="column_heading">budget $</td>
		<td width="<cfoutput>#column_width#</cfoutput>" class="column_heading">commit<br />%</td>
		<td width="<cfoutput>#column_width#</cfoutput>" class="column_heading">commit<br />bal %</td>
		<td width="<cfoutput>#column_width#</cfoutput>" class="column_heading">paid<br />%</td>
		<td width="<cfoutput>#column_width#</cfoutput>" class="column_heading">paid<br />bal %</td>
	</tr>
</table>
</div>

<div style="overflow-x: hidden; overflow-y: scroll; height:400px; padding-left:10px; margin:0px; overflow: scroll; -webkit-overflow-scrolling: touch;">
<table width="<cfoutput>#table_width#</cfoutput>" align="left" cellspacing="0">

<tr><td colspan="100%"><a name="top">&nbsp;</a></td></tr>


<cfoutput group="budget_type" query="Get_Data_1">
<tr><td colspan="100%" class="subtotals_title">#budget_type#</td></tr>


<cfoutput>

<!--- calculate the sub totals ------------------------------------------------------------------ --->
<cfset sub_sum_budget_dollars			=	sub_sum_budget_dollars+budget_dollars>
<cfset sub_sum_budget_dollars_commit	=	sub_sum_budget_dollars_commit+budget_dollars_commit>
<cfset sub_sum_budget_commit_bal		=	sub_sum_budget_commit_bal+budget_commit_bal>
<cfset sub_sum_budget_dollars_paid		=	sub_sum_budget_dollars_paid+budget_dollars_paid>
<cfset sub_sum_budget_paid_bal			=	sub_sum_budget_paid_bal+budget_paid_bal>

<!--- calculate the grand totals ------------------------------------------------------------------ --->
<cfset sum_budget_dollars=sum_budget_dollars+budget_dollars>
<cfset sum_budget_dollars_commit=sum_budget_dollars_commit+budget_dollars_commit>
<cfset sum_budget_commit_bal=sum_budget_commit_bal+budget_commit_bal>
<cfset sum_budget_dollars_paid=sum_budget_dollars_paid+budget_dollars_paid>
<cfset sum_budget_paid_bal=sum_budget_paid_bal+budget_paid_bal>
	
	<tr bgcolor="###iif(Get_Data_1.currentrow MOD 2,DE('373737'), DE('222222'))#">
		<td width="#column_width_first#" class="data_cell left">#dist_name#</td>
		<td width="#column_width#" class="data_cell left">#shipto#</td>
		<td width="#column_width#" class="data_cell">#mydollarformat(budget_dollars)#</td>
		<td width="#column_width#" class="data_cell">#mydollarformat(budget_dollars_commit)#<br />#numberformat(budget_commit_percent, '(),')#%</td>
		<td width="#column_width#" class="data_cell">#mydollarformat(budget_commit_bal)#<br />#numberformat(budget_commit_bal_percent, '(),')#%</td>
		<td width="#column_width#" class="data_cell">#mydollarformat(budget_dollars_paid)#<br />#numberformat(budget_paid_percent,'(),')#%</td>
		<td width="#column_width#" class="data_cell">#mydollarformat(budget_paid_bal)#<br />#numberformat(budget_paid_bal_percent,'(),')#%</td>
	</tr>
	
</cfoutput>



	<tr>
    	<td class="subtotals">&nbsp;</td>
    	<td class="subtotals">&nbsp;</td>
    	<td class="subtotals">#mydollarformat(sub_sum_budget_dollars)#</td>
    	<td class="subtotals">#mydollarformat(sub_sum_budget_dollars_commit)#<br />#numberformat(100*sub_sum_budget_dollars_commit/application.util.validation.EasyIIf(sub_sum_budget_dollars), "(),")#%</td>
    	<td class="subtotals">#mydollarformat(sub_sum_budget_commit_bal)#<br />#numberformat(100*sub_sum_budget_commit_bal/application.util.validation.EasyIIf(sub_sum_budget_dollars), "(),")#%</td>
    	<td class="subtotals">#mydollarformat(sub_sum_budget_dollars_paid)#<br />#numberformat(100*sub_sum_budget_dollars_paid/application.util.validation.EasyIIf(sub_sum_budget_dollars), "(),")#%</td>
    	<td class="subtotals">#mydollarformat(sub_sum_budget_paid_bal)#<br />#numberformat(100*sub_sum_budget_paid_bal/application.util.validation.EasyIIf(sub_sum_budget_dollars), "(),")#%</td>
	</tr>

<!--- reset the subtotals variables ------------------------------------------------------- --->
<cfset sub_sum_budget_dollars=0>
<cfset sub_sum_budget_dollars_commit=0>
<cfset sub_sum_budget_commit_bal=0>
<cfset sub_sum_budget_dollars_paid=0>
<cfset sub_sum_budget_paid_bal=0>

</cfoutput>


<cfoutput>
	<tr>
		<td class="grandtotals">&nbsp;</td>
		<td class="grandtotals">&nbsp;</td>
		<td class="grandtotals">#mydollarformat(sum_budget_dollars)#</td>
		<td class="grandtotals">#mydollarformat(sum_budget_dollars_commit)#<br />#numberformat(100*sum_budget_dollars_commit/application.util.validation.EasyIIf(sum_budget_dollars), "(),")#%</td>
		<td class="grandtotals">#mydollarformat(sum_budget_commit_bal)#<br />#numberformat(100*sum_budget_commit_bal/application.util.validation.EasyIIf(sum_budget_dollars), "(),")#%</td>
		<td class="grandtotals">#mydollarformat(sum_budget_dollars_paid)#<br />#numberformat(100*sum_budget_dollars_paid/application.util.validation.EasyIIf(sum_budget_dollars), "(),")#%</td>
		<td class="grandtotals">#mydollarformat(sum_budget_paid_bal)#<br />#numberformat(100*sum_budget_paid_bal/application.util.validation.EasyIIf(sum_budget_dollars), "(),")#%</td>
	</tr>
</cfoutput>

	<tr><td colspan="100%" align="left"><input onClick="javascript:location.href='#top'"; class="button" name="" type="button" value="back to top" /><a name="gt">&nbsp;</a></td></tr>

</table>
</div>

