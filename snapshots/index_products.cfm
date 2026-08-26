
<!--- the sql used by this page --------------------------------------------------------------- --->
<cfinclude template="index_products_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->


<!--- used to togle the state of the tabs ------------------------------------------------------- --->
<script>
	function clickme(div_object)
	{
		document.getElementById("one").className=	"tabs tab_a gradient_fix";
		document.getElementById("two").className=	"tabs tab_a gradient_fix";
		document.getElementById("tre").className=	"tabs tab_a gradient_fix";
		div_object.className=		"tabs tab_b gradient_fix";
	}
</script>

<!--- code used to hide/display the data grid tables -------------------------------------------- --->
<script language="JavaScript" type="text/javascript">
	function show(n)
	{
		for(i=1;i<=3;i++)
		{
			document.getElementById("layer"+i).style.display="none";
			document.getElementById("layer"+n).style.display="block";
		}
	}
</script>

<!--- function to remove decimals from dollar format because dollarformat always shows 2 decimals --->
<cfscript>
	function mydollarformat(money_string){
		money_string = DollarFormat(money_string);
		money_string = rereplaceNoCase(money_string, '\.\d{2}', '');
		return(money_string);
	}
	/*usage is: #mydollarformat(value goes here)# */
</cfscript>

<!--- ----------------------------------------------------------------------------------------- --->
<div class="page_title_details gradient_fix"><cfoutput>#get_summary.product_group_description# - #url.item_id#</cfoutput></div>
<cfinclude template="/snapshots/nav_links.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

<br />

<table cellpadding="0" cellspacing="5" border="0" width="100%" align="center">

	<tr>
		<td colspan="2">

		<!--[if gte IE 9]>
		  <style type="text/css">
			div.gradient_fix {filter: none;}
		  </style>
		<![endif]-->

		<div class="tab_wrapper">
			<div id="tre" onClick="clickme(this); show(1);" class="tabs tab_b gradient_fix" title="top ten items"><img src="images/detail_icon.png" align="left" class="button_icon">items</div>
			<div id="one" onClick="clickme(this); show(3);" class="tabs tab_a gradient_fix" title="top ten operators"><img src="images/detail_icon.png" align="left" class="button_icon">operators</div>
			<div id="two" onClick="clickme(this); show(2);" class="tabs tab_a gradient_fix" title="top ten distributors"><img src="images/detail_icon.png" align="left" class="button_icon">distributors</div>
		</div>

		</td>
	</tr>

	<tr>
		<td width="25%" valign="top">

			<div class="rounded_corners">
		
			<div class="section_title summary gradient">Customer Summary</div>
			<cfoutput query="get_summary">
			<cfset i=0>
			<table cellpadding="0" cellspacing="0" border="0" width="100%" align="center">
			<tr>
				<td class="datagrid_header summary">&nbsp;</td>
				<td class="datagrid_header summary align_right">&nbsp;</td>
				<td class="datagrid_header summary align_right">&nbsp;</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name align_right">&nbsp;</td>
				<td class="datagrid_row_name align_right"><br />Cases</td>
				<td class="datagrid_row_name align_right"><br />Dollars</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Purchases</td>
				<td class="datagrid_data align_right">#numberformat(pr_purchases_cases, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(pr_purchases_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Street</td>
				<td class="datagrid_data align_right">#numberformat(pr_street_cases, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(pr_street_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;</td>
				<td class="datagrid_data align_right">#pr_street_cases_percent#</td>
				<td class="datagrid_data align_right">#pr_street_dollars_percent#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Op.Discounted</td>
				<td class="datagrid_data align_right">#numberformat(pr_operator_discounted_cases, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(pr_operator_discounted_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;</td>
				<td class="datagrid_data align_right">#pr_operator_discounted_cases_percent#</td>
				<td class="datagrid_data align_right">#pr_operator_discounted_dollars_percent#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name align_right">&nbsp;</td>
				<td class="datagrid_row_name align_right"><br />Cs. Rate</td>
				<td class="datagrid_row_name align_right"><br />Dollars</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Mrkg. Shelter</td>
				<td class="datagrid_data align_right">#dollarformat(pr_mrkt_shelter_case_rate)#</td>
				<td class="datagrid_data align_right">#mydollarformat(pr_mrkt_shelter_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Op.Discounted</td>
				<td class="datagrid_data align_right">#dollarformat(pr_operator_discounted_case_rate)#</td>
				<td class="datagrid_data align_right">#mydollarformat(pr_operator_discounted_dollars_cr)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name totals">Investment</td>
				<td class="datagrid_data align_right totals">#dollarformat(pr_investment_case_rate)#</td>
				<td class="datagrid_data align_right totals">#mydollarformat(pr_investment_dollars)#</td>
			</tr>
			</table>
			</cfoutput>
			</div>

		</td>
		<td width="75%" valign="top">

			<div class="rounded_corners"  id="layer1" style="display: block">
			
			<div class="section_title top_ten_items gradient">Top Ten Items</div>

			<table  class="datagrid" cellpadding="0" cellspacing="5" border="0" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_items">Item</td>
				<td class="datagrid_header top_ten_items">Description</td>
				<td class="datagrid_header top_ten_items align_right">Dollars</td>
				<td class="datagrid_header top_ten_items align_right">Cases</td>
				<td class="datagrid_header top_ten_items align_right">$/Case</td>
				<td class="datagrid_header top_ten_items align_right">Net</td>
				<td class="datagrid_header top_ten_items align_right">Index</td>
			</tr>

			<cfoutput query="get_items">
			<tr class="<cfif #currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">#ttit_item_number#</td>
				<td class="datagrid_data">#ttit_item_description#</td>
				<td class="datagrid_data align_right">#mydollarformat(ttit_dollars)#</td>
				<td class="datagrid_data align_right">#numberformat(ttit_cases, '9,999,999')#</td>
				<td class="datagrid_data align_right">#dollarformat(ttit_dollars_per_cases)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttit_net)#</td>
				<td class="datagrid_data align_right">#numberformat(ttit_index, '9,999')#</td>
			</tr>
			</cfoutput>
			</table>
			</div>


			<div class="rounded_corners" id="layer2" style="display: none">

			<div class="section_title top_ten_distributors gradient">Top Ten Distributors</div>

			<table  class="datagrid" cellpadding="0" cellspacing="5" border="0" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_distributors">Sold To</td>
				<td class="datagrid_header top_ten_distributors">Customer</td>
				<td class="datagrid_header top_ten_distributors">Region</td>
				<td class="datagrid_header top_ten_distributors align_right">Cases</td>
				<td class="datagrid_header top_ten_distributors align_right">Share</td>
				<td class="datagrid_header top_ten_distributors align_right">Dollars</td>
			</tr>

			<cfoutput query="get_distributors">
			<tr class="<cfif #currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">#ttds_distributor_sold_to#</td>
				<td class="datagrid_data">#ttds_distributor_name#</td>
				<td class="datagrid_data">#ttds_distributor_region#</td>
				<td class="datagrid_data align_right">#numberformat(ttds_cases, '9,999,999')#</td>
				<td class="datagrid_data align_right">#numberformat(ttds_share,'99.99')#%</td>
				<td class="datagrid_data align_right">#mydollarformat(ttds_dollars)#</td>
			</tr>
			</cfoutput>
			</table>

		</div>





			<div class="rounded_corners" id="layer3" style="display: none">

			<div class="section_title top_ten_distributors gradient">Top Ten Operators</div>

			<table  class="datagrid" cellpadding="0" cellspacing="5" border="0" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_distributors">Contract</td>
				<td class="datagrid_header top_ten_distributors">Operator/Contract Title</td>
				<td class="datagrid_header top_ten_distributors">Type</td>
				<td class="datagrid_header top_ten_distributors align_right">Cases</td>
				<td class="datagrid_header top_ten_distributors align_right">Share</td>
				<td class="datagrid_header top_ten_distributors align_right">Dollars</td>
			</tr>

			<cfoutput query="get_operators">
			<tr class="<cfif #currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">#ttop_contract_number#</td>
				<td class="datagrid_data">#ttop_contract_title#</td>
				<td class="datagrid_data">#ttop_contract_type#</td>
				<td class="datagrid_data align_right">#numberformat(ttop_cases,'9,999,999')#</td>
				<td class="datagrid_data align_right">#ttop_share#</td>
				<td class="datagrid_data align_right">#mydollarformat(ttop_dollars)#</td>

			</tr>
			</cfoutput>
			</table>

			</div>

		</td>
	</tr>

</table>

