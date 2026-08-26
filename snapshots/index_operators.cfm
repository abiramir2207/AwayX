
<!--- the sql used by this page --------------------------------------------------------------- --->
<cfinclude template="index_operators_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->


<!--- used to togle the state of the tabs ------------------------------------------------------- --->
<script>
	function clickme(div_object)
	{
		document.getElementById("one").className=	"tabs tab_a gradient_fix";
		document.getElementById("two").className=	"tabs tab_a gradient_fix";
		div_object.className=		"tabs tab_b gradient_fix";
	}
</script>


<!--- code used to hide/display the data grid tables -------------------------------------------- --->
<script language="JavaScript" type="text/javascript">
	function show(n)
	{
		for(i=1;i<=2;i++)
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
<div class="page_title_details gradient_fix"><cfoutput>#get_summary.operator_description# - #url.item_id#</cfoutput></div>
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
			<div id="two" onClick="clickme(this); show(1);" class="tabs tab_b gradient_fix" title="top ten items"><img src="images/detail_icon.png" align="left" class="button_icon">items</div>
			<div id="one" onClick="clickme(this); show(2);" class="tabs tab_a gradient_fix" title="top ten distributor sources"><img src="images/detail_icon.png" align="left" class="button_icon">distributor sources</div>
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
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Approved</td>
				<td class="datagrid_data align_right">#mydollarformat(os_dollars_approved)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Cases to Date</td>
				<td class="datagrid_data align_right">#mydollarformat(os_cases_to_date)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Dollars per Case</td>
				<td class="datagrid_data align_right">#dollarformat(os_dollars_per_case)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Forecasted Cases</td>
				<td class="datagrid_data align_right">#numberformat(os_forecasted_cases, '9,999,999')#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Forecasted Dollars</td>
				<td class="datagrid_data align_right">#mydollarformat(os_forecasted_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">Forecasted to Go</td>
				<td class="datagrid_data align_right">&nbsp;</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cases</td>
				<td class="datagrid_data align_right">#numberformat(os_ftg_cases, '9,999,999')#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dollars</td>
				<td class="datagrid_data align_right">#mydollarformat(os_ftg_dollars)#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cases/month</td>
				<td class="datagrid_data align_right">#numberformat(os_ftg_cases_per_month, '9,999,999')#</td>
			</tr>
			<cfset i=i+1>
			<tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
				<td class="datagrid_row_name">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Dollars/month</td>
				<td class="datagrid_data align_right">#mydollarformat(os_ftg_dollars_per_month)#</td>
			</tr>


			</table>
			</cfoutput>
			</div>

		</td>
		<td width="75%" valign="top">

			<div class="rounded_corners"  id="layer1" style="display: block">
			
			<div class="section_title top_ten_items gradient">Top Ten Items</div>
			
			<table  class="datagrid" width="100%" align="center">

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

			<div class="section_title top_ten_distributors gradient">Top Ten Distributor Sources</div>

			<table class="datagrid" width="100%" align="center">

			<tr>
				<td class="datagrid_header top_ten_distributors">Sold To</td>
				<td class="datagrid_header top_ten_distributors">Customer</td>
				<td class="datagrid_header top_ten_distributors">Region</td>
				<td class="datagrid_header top_ten_distributors align_right">Cases</td>
				<td class="datagrid_header top_ten_distributors align_right">Share</td>
				<td class="datagrid_header top_ten_distributors align_right">Dollars</td>
			</tr>

			<cfoutput query="get_distributor_sources">
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


		
		</td>
	</tr>

</table>

