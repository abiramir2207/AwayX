<cfswitch expression="#url.tab_ID#">
<!--- Summary --->
<cfcase value="8"><cfinclude template="dyn_summary.cfm"></cfcase>

<!--- Basic Information --->
<cfcase value="1"><cfinclude template="dyn_basic_info.cfm"></cfcase>

<!--- Operators --->
<cfcase value="2"><cfinclude template="dyn_select_operators.cfm"></cfcase>

<!--- Brokers --->
<cfcase value="3"><cfinclude template="dyn_select_brokers.cfm"></cfcase>

<!--- Distributors --->
<cfcase value="4"><cfinclude template="dyn_select_distributors.cfm"></cfcase>

<!--- Products --->
<cfcase value="10"><cfinclude template="dyn_select_products.cfm"></cfcase>

<!--- Rates --->
<cfcase value="7">Rates</cfcase>

<!--- Components --->
<cfcase value="6">Components</cfcase>

<!--- Lamb Weston --->
<cfcase value="5">Lamb Weston</cfcase>
</cfswitch>

