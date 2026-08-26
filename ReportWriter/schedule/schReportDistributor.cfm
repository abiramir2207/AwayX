<!--------------------------  scReportProduct.cfm ---------------------->

<!--------Set defaults------------->
<CFSET rStatus=-1>
<!------<CFSET rProgramTypes="-1">----->
<CFSET rGenericTypes="-1">
<CFSET rFilter="">
<CFSET rZones="">
<CFSET rRegions="">
<CFSET rBrokers="">
<CFSET rSortBy="status,programtype">

<CFSET rFilterItems="">

<CFSET rFamilys="">
<CFSET rBuyingGroups="">
<CFSET rDistributors="">
<CFSET rOperators="">
<CFSET startdate="">
<CFSET enddate="">

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
<!--- 	<cfoutput>#rColumnHeaderID#</cfoutput> --->

	<CFIF isDefined("rFilterItemValue") AND isDefined("rFilterItems")>
		<CFSET Evaluate("r#rFilterItems#s=""#rFilterItemValue#""")>
	</CFIF>
	
	<CFSET rEmailAddress=q_getReportDetails.Report_EmailAddress>
	<cfset checkcolheader = rColumnHeaderID>
	
	
	<!------------------- End Get Vals from DB ------------------------->

	<!-----<CFSET rColumnHeaderID=ReplaceList(rColumnHeaderID,"quantity","volume")>------->
	
	<CFLOOP index="li" list="#fProgramColumnHeaderID#" delimiters=",">
		<CFIF ListFindNoCase(rColumnHeaderID,li,",")>
			<CFSET rColumnHeaderID=ListDeleteAt(rColumnHeaderID, ListFindNoCase(rColumnHeaderID,li,","),",")>
		</CFIF>
	</CFLOOP>
	<CFSET rColumnHeaderID=ListAppend(fProgramColumnHeaderID,rColumnHeaderID,",")>

	<!-----<CFSET rColumnHeaderID=ListAppend(fProgramColumnHeaderID,rColumnHeaderID,",")>------->
	
	<!-----<CFSET rColumnHeaderID=ListAppend(fProgramColumnHeaderID,rColumnHeaderID,",")>------->

	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!----------------------- Building query starts here ------------------------------------------------------>
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	

	<!-----<CFSET showReportPage="schSendDistributorReport.cfm">------->
	<!-----<CFSET showReportPage=schSendProgram>------->
	
	<!-----<CFINCLUDE TEMPLATE="generateDistributorReport.cfm">------->
	<cfif reportType EQ "programSummary">
			<CFINCLUDE TEMPLATE="#schGenerateProgram#">
		<cfelseif reportType EQ "invoiceprogramSummary">
			<cfif ListFindNoCase(rColumnHeaderID,"FiscalVolume",",")>
			<CFINCLUDE TEMPLATE="#schGenerateInvoiceProgramVolumePage#">
			<cfelseif ListFindNoCase(rColumnHeaderID,"FiscalExpense",",")>
			<CFINCLUDE TEMPLATE="#schGenerateInvoiceProgramExpensePage#">
			<cfelseif ListFindNoCase(rColumnHeaderID,"FiscalMargin",",")>
			<CFINCLUDE TEMPLATE="#schGenerateInvoiceProgramMarginPage#">
			<cfelse>
			<CFINCLUDE TEMPLATE="#schGenerateInvoiceProgramPage#">
			</cfif>
		</cfif>
<!--- 	<CFINCLUDE TEMPLATE="#schGenerateProgram#"> --->
	
	<cfif IsDefined("srqueryname")>
		<CFINCLUDE TEMPLATE="#schSendProgram#">
	</cfif>
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!----------------------- Building query ends here -------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->
	<!--------------------------------------------------------------------------------------------------------->

	