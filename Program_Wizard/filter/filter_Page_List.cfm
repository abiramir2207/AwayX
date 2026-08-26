
<cfset variables.settings = application.returned_customer_setting />

	<CFSET PAGE_TITLES = "">
	<CFSET PAGE_URLS = "">
	<CFSET PAGE_NAMES = "">
	
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "User Position", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "positions", ",")>
	
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "#variables.settings.DISTRIBUTOR_LABEL_SINGULAR#", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "customers", ",")>
	
	 <!--- Include the operators only if the operators are allowed in the template --->
  <cfif (Template.Specify_Operators EQ 1)>
    <CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "#variables.settings.OPERATOR_LABEL_SINGULAR#", ",")>
	  <CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "operators", ",")>
  </cfif>
	
	<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "#variables.settings.ITEM_LABEL#", ",")>
	<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "items", ",")>

 
	<!---	Market Pice Template Only	--->
	<cfif Template.MarketPrice>
		<CFSET PAGE_TITLES = ListAppend(PAGE_TITLES, "market price", ",")>
		<CFSET PAGE_NAMES = ListAppend(PAGE_NAMES, "market_price", ",")>
	</cfif>