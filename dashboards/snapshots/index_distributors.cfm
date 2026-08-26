

<!--- the sql used by this page --------------------------------------------------------------- --->
<cfinclude template="index_distributors_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

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


<!--- ----------------------------------------------------------------------------------------- --->
<!--- logic used to togle the uom used: cases or pounds as of 5/30/2012 ----------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<cfparam name="url.uom" default="13579">


<cfif url.uom EQ "13579">
	<cfset uom = "Cases">
	<!--- summary --->
	<cfset ds_purchases_uom = get_summary.ds_purchases_cases>
    <cfset ds_street_uom = get_summary.ds_street_cases>
    <cfset ds_street_percent_uom = get_summary.ds_street_percent_cases*100>
    <cfset ds_operator_discounted_uom = get_summary.ds_operator_discounted_cases>
    <cfset ds_operator_discounted_percent_uom = get_summary.ds_operator_discounted_percent_cases*100>
    <cfset ds_mrkt_shelter_rate_uom = get_summary.ds_mrkt_shelter_rate_cases>
    <cfset ds_operator_discounted_rate_uom = get_summary.ds_operator_discounted_rate_cases>
    <cfset ds_investment_rate_uom = get_summary.ds_investment_rate_cases>
<cfelse>
	<cfset uom = "Pounds">
	<!--- summary --->
	<cfset ds_purchases_uom = get_summary.ds_purchases_pounds>
    <cfset ds_street_uom = get_summary.ds_street_pounds>
    <cfset ds_street_percent_uom = get_summary.ds_street_percent_pounds*100>
    <cfset ds_operator_discounted_uom = get_summary.ds_operator_discounted_pounds>
    <cfset ds_operator_discounted_percent_uom = get_summary.ds_operator_discounted_percent_pounds*100>
    <cfset ds_mrkt_shelter_rate_uom = get_summary.ds_mrkt_shelter_rate_pounds>
    <cfset ds_operator_discounted_rate_uom = get_summary.ds_operator_discounted_rate_pounds>
    <cfset ds_investment_rate_uom = get_summary.ds_investment_rate_pounds>
</cfif>


<!--- ----------------------------------------------------------------------------------------- --->












<table cellpadding="0" cellspacing="15" border="0" width="100%" align="center">

	<tr>
		<td colspan="2">

        <!--- ----------------------------------------------------------------------------------------- --->
		<div class="snapshot_title">Distributor: <cfoutput>#get_summary.distributor_description# - #url.item_id#</cfoutput></div>
        <div class="links dark_gradient rounded_corners gradient_fix" onClick="javascript:show(1);">top ten categories - <cfoutput>#uom#</cfoutput></div>
        <div class="links dark_gradient rounded_corners gradient_fix" onClick="javascript:show(3);">top ten operator accounts</div>
        <div class="links dark_gradient rounded_corners gradient_fix" onClick="javascript:show(2);">top ten claims settled</div>

            <div class="form dark_gradient rounded_corners gradient_fix" style="background-color:#8400ff;">
            	<form action="search_details.cfm" method="get" name="myform">
                    <input name="item_id" type="hidden" value="<cfoutput>#url.item_id#</cfoutput>" />
                    <input name="item_type_code" type="hidden" value="<cfoutput>#url.item_type_code#</cfoutput>" />
                    <input name="date_period" type="hidden" value="<cfoutput>#url.date_period#</cfoutput>" />
                	<input id="uom_cases" name="uom" type="radio" value="13579" onClick='document.myform.submit();' <cfif url.uom eq "13579"> checked="true"<cfelse></cfif> class="uom" /> CASES
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                	<input id="uom_pounds" name="uom" type="radio" value="97531" onClick='document.myform.submit();'<cfif url.uom eq "97531"> checked="true"<cfelse></cfif> class="uom" /> POUNDS
                </form>
            </div>

		</td>
	</tr>

	<tr>
		<td width="25%" valign="top">

			<div class="">
		
			<div class="section_title summary gradient">Customer Summary</div>
            <br />
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
				<td class="datagrid_row_name align_right"><cfoutput>#uom#</cfoutput></td>
				<td class="datagrid_row_name align_right">Dollars</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Purchases</td>
				<td class="datagrid_data align_right">#numberformat(ds_purchases_uom, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_purchases_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Street</td>
				<td class="datagrid_data align_right">#numberformat(ds_street_uom, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_street_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;</td>
				<td class="datagrid_data align_right">#numberformat(ds_street_percent_uom, '999')#%</td>
				<td class="datagrid_data align_right">#numberformat(ds_street_dollars_percent, '999.9')#%</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Op.Discounted</td>
				<td class="datagrid_data align_right">#numberformat(ds_operator_discounted_uom, '9,999,999')#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_operator_discounted_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;</td>
				<td class="datagrid_data align_right">#numberformat(ds_operator_discounted_percent_uom, '99.9')#%</td>
				<td class="datagrid_data align_right">#numberformat(ds_operator_discounted_dollars_percent, '99.9')#%</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name align_right">&nbsp;</td>
				<td class="datagrid_row_name align_right">Rate</td>
				<td class="datagrid_row_name align_right">Dollars</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Mrkg. Shelter</td>
				<td class="datagrid_data align_right">#dollarformat(ds_mrkt_shelter_rate_uom)#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_mrkt_shelter_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Op.Discounted</td>
				<td class="datagrid_data align_right">#dollarformat(ds_operator_discounted_rate_uom)#</td>
				<td class="datagrid_data align_right">#mydollarformat(ds_operator_discounted_dollars_cr)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name totals">Investment</td>
				<td class="datagrid_data align_right totals">#dollarformat(ds_investment_rate_uom)#</td>
				<td class="datagrid_data align_right totals">#mydollarformat(ds_investment_dollars)#</td>
			</tr>
			</table>
			</cfoutput>
			</div>

		</td>
		<td width="75%" valign="top">
        
			<!--- top ten categories -------------------------------------------------------------------------- --->
			<div class=""  id="layer1" style="display: block">
			
			<div class="section_title top_ten_items gradient">Top Ten Categories - <cfoutput>#uom#</cfoutput></div>
            
            <br />
			
            <table cellpadding="0" cellspacing="0" border="0" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_items">Category</td>
				<td class="datagrid_header top_ten_items align_right">Dollars</td>
				<!--- <td class="datagrid_header top_ten_items align_right">13WRT</td> --->
				<td class="datagrid_header top_ten_items align_right"><cfoutput>#uom#</cfoutput></td>
				<td class="datagrid_header top_ten_items align_right">Revenue</td>
				<td class="datagrid_header top_ten_items align_right">Trade</td>
				<td class="datagrid_header top_ten_items align_right">Operator</td>
				<td class="datagrid_header top_ten_items align_right">Total</td>
				<td class="datagrid_header top_ten_items align_right">%</td>
				<td class="datagrid_header top_ten_items align_right">Net/Case</td>
				<!--- <td class="datagrid_header top_ten_items align_right">Index</td> --->
			</tr>

			<cfoutput query="get_categories">
            
        <!--- logic used to togle the uom used: cases or pounds as of 5/30/2012 ----------------------- --->

			<cfif url.uom EQ "13579">
                <cfset uom = "Cases">
                <!--- categories --->
                <cfset ttct_uom = get_categories.ttct_cases>
                <cfset ttct_revenue_uom = get_categories.ttct_revenue_cases>
                <cfset ttct_trade_uom = get_categories.ttct_trade_cases>
                <cfset ttct_operator_uom = get_categories.ttct_operator_cases>
                <cfset ttct_total_uom = get_categories.ttct_total_cases>
                <cfset ttct_percent_uom = get_categories.ttct_percent_cases*100>
                <cfset ttct_net_per_uom = get_categories.ttct_net_per_cases>
            <cfelse>
                <cfset uom = "Pounds">
                <!--- categories --->
                <cfset ttct_uom = get_categories.ttct_pounds>
                <cfset ttct_revenue_uom = get_categories.ttct_revenue_pounds>
                <cfset ttct_trade_uom = get_categories.ttct_trade_pounds>
                <cfset ttct_operator_uom = get_categories.ttct_operator_pounds>
                <cfset ttct_total_uom = get_categories.ttct_total_pounds>
                <cfset ttct_percent_uom = get_categories.ttct_percent_pounds*100>
                <cfset ttct_net_per_uom = get_categories.ttct_net_per_pounds>
            </cfif>
            
            
            
            
			<tr class="<cfif #get_categories.currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">#ttct_category#</td>
				<td class="datagrid_data align_right">#mydollarformat(ttct_dollars)#</td>
				<!--- <td class="datagrid_data align_right">#numberformat(ttct_13wrt, '(99.9)')#%</td> --->
				<td class="datagrid_data align_right">#numberformat(ttct_uom, '9,999,999')#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_revenue_uom)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_trade_uom)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_operator_uom)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_total_uom)#</td>
				<td class="datagrid_data align_right">#numberformat(ttct_percent_uom, 99)#%</td>
				<td class="datagrid_data align_right">#dollarformat(ttct_net_per_uom)#</td>
				<!--- <td class="datagrid_data align_right">#ttct_index#</td> --->
			</tr>
			</cfoutput>
			</table>
			
			</div>


			<!--- top ten claims settled ----------------------------------------------------------------- --->
			<div class="" id="layer2" style="display: none">

			<div class="section_title top_ten_distributors gradient">Top Ten Claims Settled</div>
            
            <br />

            <table cellpadding="0" cellspacing="0" border="0" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_distributors">Claim</td>
				<td class="datagrid_header top_ten_distributors">Reference</td>
				<td class="datagrid_header top_ten_distributors">Contract</td>
				<td class="datagrid_header top_ten_distributors align_right">Claimed</td>
				<td class="datagrid_header top_ten_distributors align_right">Vs. Expected</td>
				<td class="datagrid_header top_ten_distributors align_right">Rate</td>
			</tr>

			<cfset ttcl_claimed_amount_total 				= 0>
			<cfset ttcl_claimed_amount_vs_expected_total 	= 0>
            
			<cfoutput query="get_claims">

			<tr class="<cfif #get_claims.currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">#ttcl_claim_number#</td>
				<td class="datagrid_data">#ttcl_reference#</td>
				<td class="datagrid_data">#ttcl_contract_title#</td>
				<td class="datagrid_data align_right">#dollarformat(ttcl_claimed_amount)#</td>
				<td class="datagrid_data align_right">#dollarformat(ttcl_claimed_amount_vs_expected)#</td>
				<td class="datagrid_data align_right">#numberformat(ttcl_rate, '99')#%</td>
			</tr>
			
            <cfset ttcl_claimed_amount_total				=	ttcl_claimed_amount_total	+	ttcl_claimed_amount>
			<cfset ttcl_claimed_amount_vs_expected_total	=	ttcl_claimed_amount_vs_expected_total	+	ttcl_claimed_amount_vs_expected>
			
			</cfoutput>

			<cfoutput>
			<tr>
				<td class="datagrid_row_name totals">&nbsp;</td>
				<td class="datagrid_row_name totals">&nbsp;</td>
				<td class="datagrid_row_name totals">All claims - Past 30 days</td>
				<td class="datagrid_row_name align_right totals">#dollarformat(ttcl_claimed_amount_total)#</td>
				<td class="datagrid_row_name align_right totals">#dollarformat(ttcl_claimed_amount_vs_expected_total)#</td>
				<td class="datagrid_row_name align_right totals">#numberformat(ttcl_claimed_amount_vs_expected_total*100/ttcl_claimed_amount_total, '0.00')#%</td>
			</cfoutput>

			</table>

			</div>



			<!--- top ten operator accounts-------------------------------------------------------------------------- --->
			<div class="" id="layer3" style="display: none">

			<div class="section_title top_ten_distributors gradient">Top Ten Operator Accounts</div>
            
            <br />

            <table cellpadding="0" cellspacing="0" border="0" width="100%" align="center">

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
				<td class="datagrid_data align_right">#numberformat(ttoa_share, '99')#%</td>
				<td class="datagrid_data align_right">#mydollarformat(ttoa_dollars)#</td>

			</tr>
			</cfoutput>
			</table>

			</div>

		</td>
	</tr>

</table>


