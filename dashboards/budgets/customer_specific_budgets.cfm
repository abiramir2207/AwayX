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

<!--- ----------------------------------------------------------------------------------------- --->
<cfquery name="Get_Data_1" datasource="#Application.Datasource#">
	SELECT	dash_budget_expired,

	        dbo.dashboards_budget_weekly_summary.budget_desc	as	budget_desc,

	        budget_type							as	budget_type,
	        dash_budget_type_desc				as	dash_budget_type_desc,
	        Budget_Class.Budget_Class_Desc		as	Budget_Class_Desc,
	        budget_dollars 						as	budget_dollars,
	        budget_dollars_commit 				as	budget_dollars_commit,
	        budget_commit_bal 					as	budget_commit_bal,
	        (100*budget_commit_percent) 		as	budget_commit_percent,
	        (100*(1-budget_commit_percent)) 	as	budget_commit_bal_percent,
	        budget_dollars_paid 				as	budget_dollars_paid,
	        budget_paid_bal 					as	budget_paid_bal,
	        (100*budget_paid_percent) 			as	budget_paid_percent,
	        (100*(1-budget_paid_percent)) 		as	budget_paid_bal_percent,
	        shipto								as	shipto,
	        dist_name							as	dist_name

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

	ORDER BY dist_name asc, budget_dollars desc
</cfquery>
<!--- ----------------------------------------------------------------------------------------- --->

<br />
<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="customer_specific_budgets.css">
<!--- ----------------------------------------------------------------------------------------- --->

<!--- instanciate the totals variables ------------------------------------------------------- --->
<cfset sum_budget_dollars=0>
<cfset sum_budget_dollars_commit=0>
<cfset sum_budget_commit_bal=0>
<cfset sum_budget_dollars_paid=0>
<cfset sum_budget_paid_bal=0>

<cfset columns = 8 >
<cfset table_width = 920>
<cfset column_width = 80>
<cfset column_width_first = table_width-(columns*column_width)>

<!--- ----------------------------------------------------------------------------------------- --->
<cfinclude template="customer_specific_budgets_buttons.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<cfset columnSizes = application.util.array.dtColumnSizeInPercent( [3, 3, 1, 1, 1, 1, 1] )>
<div style="overflow-x: hidden; overflow-y: hidden; height:35px; padding-left:10px; margin:0px;">
	<cfoutput>
	<table width="98%" align="left" cellspacing="0">
		<cfloop array="#columnSizes#" index="columnPercentage">
		  <col width="#columnPercentage#%">
		</cfloop>
		<tr>
			<td class="column_heading left">distributor &middot; account</td>
			<td class="column_heading left">budget description<br>&middot; type &middot; class</td>
			<td class="column_heading right">#label.budget_dollar.singular#</td>
			<td class="column_heading right">commit<br />%</td>
			<td class="column_heading right">commit<br />bal %</td>
			<td class="column_heading right">paid<br />%</td>
			<td class="column_heading right">paid<br />bal %</td>
		</tr>
	</table>
	</cfoutput>
</div>

<div style="overflow-x: hidden; overflow-y: scroll; height:375px; padding-left:10px; margin:0px; overflow: scroll; -webkit-overflow-scrolling: touch;">
	<table width="100%" align="left" cellspacing="0">
		<cfoutput>
		<cfloop array="#columnSizes#" index="variables.columnPercentage">
		  <col width="#variables.columnPercentage#%">
		</cfloop>
		</cfoutput>

		<cfoutput query="Get_Data_1">
			<!--- calculate the totals ------------------------------------------------------------------ --->
			<cfscript>
				sum_budget_dollars        = sum_budget_dollars+budget_dollars;
				sum_budget_dollars_commit = sum_budget_dollars_commit+budget_dollars_commit;
				sum_budget_commit_bal     = sum_budget_commit_bal+budget_commit_bal;
				sum_budget_dollars_paid   = sum_budget_dollars_paid+budget_dollars_paid;
				sum_budget_paid_bal       = sum_budget_paid_bal+budget_paid_bal;
			</cfscript>

			<tr bgcolor=#(Get_Data_1.currentrow mod 2 ? "##373737" : "##222222")#>
				<td class="data_cell left">#dist_name# &middot; #shipto#</td>
				<td class="data_cell left">#budget_desc#<br>&middot; #budget_type# &middot; #Budget_Class_Desc#</td>
				<td class="data_cell right">#mydollarformat(budget_dollars)#</td>
				<td class="data_cell right">#mydollarformat(budget_dollars_commit)#<br />#numberformat(budget_commit_percent, ',')#%</td>
				<td class="data_cell right">#mydollarformat(budget_commit_bal)#<br />#numberformat(budget_commit_bal_percent, ',')#%</td>
				<td class="data_cell right">#mydollarformat(budget_dollars_paid)#<br />#numberformat(budget_paid_percent,',')#%</td>
				<td class="data_cell right">#mydollarformat(budget_paid_bal)#<br />#numberformat(budget_paid_bal_percent,',')#%</td>
			</tr>
		</cfoutput>

		<cfoutput>
			<tr>
				<td class="grandtotals">&nbsp;</td>
				<td class="grandtotals">&nbsp;</td>
				<td class="grandtotals">#mydollarformat(sum_budget_dollars)#</td>
				<td class="grandtotals">#mydollarformat(sum_budget_dollars_commit)#<br />#numberformat(100*sum_budget_dollars_commit/application.util.validation.EasyIIf(sum_budget_dollars), ",")#%</td>
				<td class="grandtotals">#mydollarformat(sum_budget_commit_bal)#<br />#numberformat(100*sum_budget_commit_bal/application.util.validation.EasyIIf(sum_budget_dollars), ",")#%</td>
				<td class="grandtotals">#mydollarformat(sum_budget_dollars_paid)#<br />#numberformat(100*sum_budget_dollars_paid/application.util.validation.EasyIIf(sum_budget_dollars), ",")#%</td>
				<td class="grandtotals">#mydollarformat(sum_budget_paid_bal)#<br />#numberformat(100*sum_budget_paid_bal/application.util.validation.EasyIIf(sum_budget_dollars), ",")#%</td>
			</tr>
		</cfoutput>

		<tr><td colspan="100%" align="left"><input onClick="javascript:location.href='#top'" class="button" name="" type="button" value="back to top" /><a name="gt">&nbsp;</a></td></tr>
	</table>
</div>
