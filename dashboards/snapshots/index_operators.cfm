

<!--- the sql used by this page --------------------------------------------------------------- --->
<cfinclude template="index_operators_sql.cfm">
<!--- ----------------------------------------------------------------------------------------- --->

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


<table cellpadding="0" cellspacing="15" border="0" width="100%" align="center">

<tr>

    <td colspan="100%">
        
        <div class="snapshot_title rounded_corners">Operator: <cfoutput>#get_summary.operator_description# - #url.item_id#</cfoutput></div>
        <div class="links dark_gradient rounded_corners gradient_fix" onClick="javascript:show(1);">top ten items</div>
        <div class="links dark_gradient rounded_corners gradient_fix" onClick="javascript:show(2);">top ten distributor sources</div>
        
    </td>
</tr>

<tr>

    <td width="25%" valign="top">
    
        <div class="section_title">Customer Summary</div>
        <br />
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
            <td class="datagrid_data align_right">#numberformat(os_cases_to_date, ',')#</td>
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
            <td class="datagrid_row_name">Approved/Discount $</td>
            <td class="datagrid_data align_right">&nbsp;</td>
        </tr>
        <cfset i=i+1>
        <tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
            <td class="datagrid_row_name">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Cases</td>
            <td class="datagrid_data align_right">#numberformat(os_approved_cases, '9,999,999')#</td>
        </tr>
        <cfset i=i+1>
        <tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
            <td class="datagrid_row_name">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$/Case</td>
            <td class="datagrid_data align_right">#dollarformat(os_approved_dollars_per_case)#</td>
        </tr>
        <cfset i=i+1>
        <tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
            <td class="datagrid_row_name">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Pounds</td>
            <td class="datagrid_data align_right">#numberformat(os_approved_pounds, '9,999,999')#</td>
        </tr>
        <cfset i=i+1>
        <tr class="<cfif #i# mod 2>dark_row<cfelse>light_row</cfif>">
            <td class="datagrid_row_name">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$/Pound</td>
            <td class="datagrid_data align_right">#dollarformat(os_approved_dollars_per_pound)#</td>
        </tr>
    
    
        </table>
        </cfoutput>
    
    </td>

    <td width="75%" valign="top">
    
        <!--- top ten items -------------------------------------------------------------------------- --->
        <div class="" id="layer1" style="display: block">
        <div class="section_title">Top Ten Items</div>
        
        <br />
        
        <table cellpadding="0" cellspacing="0" border="0" width="100%" align="center">
        <tr>
            <td class="datagrid_header top_ten_items">Item</td>
            <td class="datagrid_header top_ten_items">Description</td>
            <td class="datagrid_header top_ten_items align_right">Dollars</td>
            <td class="datagrid_header top_ten_items align_right">Cases</td>
            <td class="datagrid_header top_ten_items align_right">$/Case</td>
            <td class="datagrid_header top_ten_items align_right">Net</td>
        </tr>
        <cfoutput query="get_items">
        <tr class="<cfif #currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
            <td class="datagrid_row_name">#ttit_item_number#</td>
            <td class="datagrid_data">#ttit_item_description#</td>
            <td class="datagrid_data align_right">#mydollarformat(ttit_dollars)#</td>
            <td class="datagrid_data align_right">#numberformat(ttit_cases, '9,999,999')#</td>
            <td class="datagrid_data align_right">#dollarformat(ttit_dollars_per_case)#</td>
            <td class="datagrid_data align_right">#dollarformat(ttit_net)#</td>
        </tr>
        </cfoutput>
        </table>
        </div>
    
    
        <!--- top ten distributors ----------------------------------------------------------------- --->
        <div class="" id="layer2" style="display: none">
        <div class="section_title">Top Ten Distributor Sources</div>
        
        <br />
        
        <table cellpadding="0" cellspacing="0" border="0" width="100%" align="center">
        <tr>
            <td class="datagrid_header top_ten_distributors">Sold To</td>
            <td class="datagrid_header top_ten_distributors">Customer/Region</td>
    
            <td class="datagrid_header top_ten_distributors align_right">Cases<br />$/Case</td>
            <td class="datagrid_header top_ten_distributors align_right">Pounds<br />$/Pound</td>
            <td class="datagrid_header top_ten_distributors align_right">Disc.Total<br />$/Case</td>
            <td class="datagrid_header top_ten_distributors align_right">Disc.Total<br />$/Pound</td>
    
            <td class="datagrid_header top_ten_distributors align_right">Share</td>
            <td class="datagrid_header top_ten_distributors align_right">Dollars</td>
        </tr>
        <cfoutput query="get_distributor_sources">
        <tr class="<cfif #currentrow# mod 2>dark_row<cfelse>light_row</cfif>">
            <td class="datagrid_row_name">#ttds_distributor_sold_to#</td>
            <td class="datagrid_data">#ttds_distributor_name#<br />#ttds_distributor_region#</td>
    
            <td class="datagrid_data align_right">#numberformat(ttds_cases, '9,999,999')#<br />$#numberformat(ttds_dollars_per_case,'9,999,999.99')#</td>
            <td class="datagrid_data align_right">#numberformat(ttds_pounds,',')#<br />$#numberformat(ttds_dollars_per_pound,'9,999,999.99')#</td>
            <td class="datagrid_data align_right">9999</td>
            <td class="datagrid_data align_right">9999</td>
    
            <td class="datagrid_data align_right">#numberformat(ttds_share,'99')#%</td>
            <td class="datagrid_data align_right">#mydollarformat(ttds_dollars)#</td>
        </tr>
        </cfoutput>
        </table>
        </div>
    
    </td>

</tr>

</table>

            

