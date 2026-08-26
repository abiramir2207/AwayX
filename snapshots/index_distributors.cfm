
<!--- the sql used by this page --------------------------------------------------------------- --->
<cfinclude template="index_distributors_sql.cfm">
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
<div class="page_title_details gradient_fix"><cfoutput>#get_summary.distributor_description# - #url.item_id#</cfoutput></div>
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
			<div id="tre" onClick="javascript:show(1); javascript:clickme(this);" class="tabs tab_b gradient_fix" title="top ten categories"><img src="images/detail_icon.png" align="left" class="button_icon">categories</div>
			<div id="one" onClick="javascript:show(2); javascript:clickme(this);" class="tabs tab_a gradient_fix" title="top ten claims settled"><img src="images/detail_icon.png" align="left" class="button_icon">claims settled</div>
			<div id="two" onClick="javascript:show(3); javascript:clickme(this);" class="tabs tab_a gradient_fix" title="top operator accounts"><img src="images/detail_icon.png" align="left" class="button_icon">operator accounts</div>
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
				<td class="datagrid_row_name">Region</td>
				<td class="datagrid_data align_right">&nbsp;</td>
				<td class="datagrid_data align_right">#ds_region#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Parent</td>
				<td class="datagrid_data align_right">&nbsp;</td>
				<td class="datagrid_data align_right">#ds_corporate_parent#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Rank & Share</td>
				<td class="datagrid_data align_right">&nbsp;</td>
				<td class="datagrid_data align_right">#numberformat(ds_rank, '99')# / #numberformat(ds_share, '99')#%</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name align_right">&nbsp;</td>
				<td class="datagrid_row_name align_right"><br /><br />Cases</td>
				<td class="datagrid_row_name align_right"><br /><br />Dollars</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Purchases</td>
				<td class="datagrid_data align_right">#numberformat(ds_purchases_cases, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_purchases_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Street</td>
				<td class="datagrid_data align_right">#numberformat(ds_street_cases, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_street_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;</td>
				<td class="datagrid_data align_right">#numberformat(ds_street_cases_percent, '999')#%</td>
				<td class="datagrid_data align_right">#numberformat(ds_street_dollars_percent, '999.9')#%</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Op.Discounted</td>
				<td class="datagrid_data align_right">#numberformat(ds_operator_discounted_cases, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_operator_discounted_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;</td>
				<td class="datagrid_data align_right">#numberformat(ds_operator_discounted_cases_percent, '99.9')#%</td>
				<td class="datagrid_data align_right">#numberformat(ds_operator_discounted_dollars_percent, '99.9')#%</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name align_right">&nbsp;<br /></td>
				<td class="datagrid_row_name align_right"><br /><br />Cs.Rate</td>
				<td class="datagrid_row_name align_right"><br /><br />Dollars</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Mrkg. Shelter</td>
				<td class="datagrid_data align_right">#dollarformat(ds_mrkt_shelter_case_rate)#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_mrkt_shelter_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Op.Discounted</td>
				<td class="datagrid_data align_right">#dollarformat(ds_operator_discounted_case_rate)#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_operator_discounted_dollars_cr)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name totals">Investment</td>
				<td class="datagrid_data align_right totals">#dollarformat(ds_investment_case_rate)#</td>
				<td class="datagrid_data align_right totals">#mydollarformat(ds_investment_dollars)#</td>
			</tr>
			</table>
			</cfoutput>
			</div>

		</td>
		<td width="75%" valign="top">

			<div class="rounded_corners"  id="layer1" style="display: block">
			
			<div class="section_title top_ten_items gradient">Top Ten Categories</div>
			
			<table  class="datagrid" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_items">Category</td>
				<td class="datagrid_header top_ten_items align_right">Dollars</td>
				<td class="datagrid_header top_ten_items align_right">13WRT</td>
				<td class="datagrid_header top_ten_items align_right">Cases</td>
				<td class="datagrid_header top_ten_items align_right">Revenue</td>
				<td class="datagrid_header top_ten_items align_right">Trade</td>
				<td class="datagrid_header top_ten_items align_right">Operator</td>
				<td class="datagrid_header top_ten_items align_right">Total</td>
				<td class="datagrid_header top_ten_items align_right">%</td>
				<td class="datagrid_header top_ten_items align_right">Net/Case</td>
				<td class="datagrid_header top_ten_items align_right">Index</td>
			</tr>

			<cfoutput query="get_categories">
			<tr class="<cfif #get_categories.currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">#ttct_category#</td>
				<td class="datagrid_data align_right">#mydollarformat(ttct_dollars)#</td>
				<td class="datagrid_data align_right">#numberformat(ttct_13wrt, '(99.9)')#%</td>
				<td class="datagrid_data align_right">#numberformat(ttct_13wrt, '9,999,999')#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_revenue)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_trade)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_operator)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_total)#</td>
				<td class="datagrid_data align_right">#ttct_percent#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_net_per_cases)#</td>
				<td class="datagrid_data align_right">#ttct_index#</td>
			</tr>
			</cfoutput>
			</table>
			
			</div>



			<div class="rounded_corners" id="layer2" style="display: none">

			<div class="section_title top_ten_distributors gradient">Top Ten Claims Settled</div>

			<table  class="datagrid" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_distributors">Claim</td>
				<td class="datagrid_header top_ten_distributors">Reference</td>
				<td class="datagrid_header top_ten_distributors">Contract</td>
				<td class="datagrid_header top_ten_distributors align_right">Claimed</td>
				<td class="datagrid_header top_ten_distributors align_right">Vs. Expected</td>
				<td class="datagrid_header top_ten_distributors align_right">Rate</td>
			</tr>

			<cfoutput query="get_claims">

			<tr class="<cfif #get_claims.currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">#ttcl_claim_number#</td>
				<td class="datagrid_data">#ttcl_reference#</td>
				<td class="datagrid_data">#ttcl_contract_title#</td>
				<td class="datagrid_data align_right">#dollarformat(ttcl_claimed_amount)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttcl_claimed_amount_vs_expected)#</td>
				<td class="datagrid_data align_right">#numberformat(ttcl_rate, '99.9')#%</td>
			</tr>
			</cfoutput>

			<cfoutput>
			<tr>
				<td class="datagrid_row_name totals">&nbsp;</td>
				<td class="datagrid_row_name totals">&nbsp;</td>
				<td class="datagrid_row_name totals">All claims - Past 30 days</td>
				<td class="datagrid_row_name align_right totals">32,349.13 </td>
				<td class="datagrid_row_name align_right totals">2859.45</td>
				<td class="datagrid_row_name align_right totals">8.8</td>
			</cfoutput>

			</table>

			</div>




			<div class="rounded_corners" id="layer3" style="display: none">

			<div class="section_title top_ten_distributors gradient">Top Ten Operator Accounts</div>

			<table  class="datagrid" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_distributors">Contract</td>
				<td class="datagrid_header top_ten_distributors">Operator/Contract Title</td>
				<td class="datagrid_header top_ten_distributors">Type</td>
				<td class="datagrid_header top_ten_distributors align_right">Cases</td>
				<td class="datagrid_header top_ten_distributors align_right">Share</td>
				<td class="datagrid_header top_ten_distributors align_right">Dollars</td>
			</tr>

			<cfoutput query="get_operator_accounts">
			<tr class="<cfif #get_operator_accounts.currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">#ttoa_contract_number#</td>
				<td class="datagrid_data">#ttoa_contract_title#</td>
				<td class="datagrid_data">#ttoa_contract_type#</td>
				<td class="datagrid_data align_right">#numberformat(ttoa_cases,'9,999,999')#</td>
				<td class="datagrid_data align_right">#ttoa_share#</td>
				<td class="datagrid_data align_right">#mydollarformat(ttoa_dollars)#</td>

			</tr>
			</cfoutput>
			</table>

			</div>

		</td>
	</tr>

</table>


