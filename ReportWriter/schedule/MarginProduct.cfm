<!------MarginProduct.cfm----->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Set defaults
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFSET rStatus="-1">
<CFSET rGenericTypes ="-1">

<CFSET rSortBy="status,programtype,margin">
<CFSET rMarginOption="ALL">
<CFSET rMarginValue1="">
<CFSET rMarginValue2="">

<CFSET rFilterItem="">
<CFSET rFilterCust="">

<CFSET rTypeGroups="-1">
<CFSET rQBrands="-1">
<CFSET rTypeCodes="-1">
<CFSET rBrands="-1">


<CFSET rFamilys="">
<CFSET rBuyingGroups="">
<CFSET rDistributors="">

<CFSET reportFormatType=1>

<CFSET rReportOutputType="h">

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Set defaults
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Values From DB
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->

<CFLOOP QUERY="q_getReportStructure">
	<CFSET Evaluate("#Report_Structure#=""#Report_Structure_Value#""")>
</CFLOOP>

<CFIF isDefined("rFilterItemValue") AND isDefined("rFilterItem")>
	<CFSET Evaluate("r#rFilterItem#=""#rFilterItemValue#""")>
</CFIF>

<CFIF isDefined("rFilterCustValue") AND isDefined("rFilterCust")>
	<CFSET Evaluate("r#rFilterCust#=""#rFilterCustValue#""")>
</CFIF>

<CFSET rEmailAddress=q_getReportDetails.Report_EmailAddress>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Get Values From DB
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->



<!--------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->
<!----------------------- Building query starts here ------------------------------------------------------>
<!--------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->

	<CFINCLUDE TEMPLATE="#schGenerateMarginProduct#">	
	<cfif IsDefined("srqueryname")>
		<CFINCLUDE TEMPLATE="#SendMarginProduct#">
	</cfif>	

<!--------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->
<!----------------------- Building query ends here -------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------->
