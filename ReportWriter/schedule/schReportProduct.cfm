<!--------------------------  scReportProduct.cfm ---------------------->

<!--------Set defaults------------->
<CFSET rStatus=-1>
<!------<CFSET rProgramTypes="-1">----->
<CFSET rGenericTypes="-1">
<CFSET rFilter="none">
<CFSET rZones="">
<CFSET rRegions="">
<CFSET rBrokers="">
<CFSET rSortBy="status,programtype">

<CFSET rFilterItems="typegroup">

<CFSET rTypeGroups="">
<CFSET rQBrands="">
<CFSET rTypeCodes="">
<CFSET rBrands="">

<CFSET rReportOutputType="h">
<CFSET rColumnHeaderID="">

<CFSET rEmailAddress="">

<!--------Set defaults------------->

	<!------------------- Get Vals from DB ------------------------->
	<CFLOOP QUERY="q_getReportStructure">
		<CFSET Evaluate("#Report_Structure#=""#Report_Structure_Value#""")>
	</CFLOOP>
	
	
	
	
	<CFIF isDefined("rFilterValue") AND isDefined("rFilter")>
		<CFSET Evaluate("r#rFilter#s=""#rFilterValue#""")>
	</CFIF>
	
	
	<CFIF isDefined("rFilterItemValue") AND isDefined("rFilterItems")>
		<CFSET Evaluate("r#rFilterItems#s=""#rFilterItemValue#""")>
	</CFIF>
	
	<CFSET rEmailAddress=q_getReportDetails.Report_EmailAddress>
	<!------------------- End Get Vals from DB ------------------------->
	
	
	<CFSET rColumnHeaderID=ReplaceList(rColumnHeaderID,"quantity","volume")>
	
	<CFLOOP index="li" list="#fProductColumnHeaderID#" delimiters=",">
		<CFIF ListFindNoCase(rColumnHeaderID,li,",")>
			<CFSET rColumnHeaderID=ListDeleteAt(rColumnHeaderID, ListFindNoCase(rColumnHeaderID,li,","),",")>
		</CFIF>
	</CFLOOP>
	<cfset checkcolheader = rColumnHeaderID>
	
	<CFSET rColumnHeaderID=ListAppend(fProductColumnHeaderID,rColumnHeaderID,",")>
	
	<!-----<CFSET rColumnHeaderID=ListAppend(fProductColumnHeaderID,rColumnHeaderID,",")>------->
	
	
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!----------------------- Building query starts here ------------------------------------------------------>
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	
	
	
	<!-----<CFSET showReportPage="schSendProductReport.cfm">------->
	<!-----<CFSET showReportPage=schSendProduct>------->
	
	<!-----<CFINCLUDE TEMPLATE="generateProductReport.cfm">------->	
	<cfif reportType EQ "productSummary">
			<CFINCLUDE TEMPLATE="#schGenerateProduct#">
		<cfelseif reportType EQ "invoiceproductSummary">
			<CFINCLUDE TEMPLATE="#schGenerateInvoiceProduct#">
	</cfif>

	
	<cfif IsDefined("srqueryname")>
		<CFINCLUDE TEMPLATE="#schSendProduct#">
	</cfif>
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!----------------------- Building query ends here -------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->