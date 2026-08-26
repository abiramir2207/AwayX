<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- get the data from the terminology table --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="get_all" datasource="#Application.Datasource#">
	
	Select	Dashboard_Labels_Desc, 
			Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	
	From	Dashboard_Labels
	
	Where	Deleted = 0

</CFQUERY>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- query the master query looking for the right terms							 	--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFQUERY name="budget_class" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Budget Class'
</cfquery>	

<CFQUERY name="territory" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Territory'
</cfquery>	

<CFQUERY name="customer" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Customer'
</cfquery>	

<CFQUERY name="program" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Program'
</cfquery>	

<CFQUERY name="sub_region" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Sub Region'
</cfquery>	

<CFQUERY name="Budget" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Budget'
</cfquery>	

<CFQUERY name="billback" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Billback'
</cfquery>	

<CFQUERY name="sales" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Sales'
</cfquery>	

<CFQUERY name="performance" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Performance'
</cfquery>	







<CFQUERY name="family" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Family'
</cfquery>	

<CFQUERY name="distributor" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Distributor'
</cfquery>	

<CFQUERY name="budget_dollar" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Budget Dollar'
</cfquery>	

<CFQUERY name="commit" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Committed Dollar'
</cfquery>	

<CFQUERY name="invoice" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Invoice'
</cfquery>	


<!--- ----------------------------------------------------------------------------------------- --->
<!--- set the terminology for the labels used ------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->

<cfset label.zone_total.singular			=	#application.returned_customer_setting.ZONE_LABEL_SINGULAR#&" total">
<cfset label.zone_total.plural				=	#application.returned_customer_setting.ZONE_LABEL_PLURAL#&" total">

<cfset label.zone_budget_detail.singular	=	#application.returned_customer_setting.ZONE_LABEL_SINGULAR#&" budget detail">
<cfset label.zone_budget_detail.plural		=	#application.returned_customer_setting.ZONE_LABEL_PLURAL#&" budget detail">

<cfset label.region_total.singular			=	#application.returned_customer_setting.REGION_LABEL_SINGULAR#&" total">
<cfset label.region_total.plural			=	#application.returned_customer_setting.REGION_LABEL_PLURAL#&" total">

<cfset label.region_detail.singular			=	#application.returned_customer_setting.REGION_LABEL_SINGULAR#&" budget detail">
<cfset label.regions_detail.plural			=	#application.returned_customer_setting.REGION_LABEL_PLURAL#&" budget detail">

<cfset label.market_total.singular			=	#application.returned_customer_setting.MARKET_LABEL_SINGULAR#&" total">
<cfset label.market_total.plural			=	#application.returned_customer_setting.MARKET_LABEL_PLURAL#&" total">

<cfset label.market_detail.singular			=	#application.returned_customer_setting.MARKET_LABEL_SINGULAR#&" budget detail">
<cfset label.market_detail.singular			=	#application.returned_customer_setting.MARKET_LABEL_PLURAL#&" budget detail">

<cfset label.shipto.singular				=	#application.returned_customer_setting.SHARD_SHIP_TO_LABEL#>

<cfset label.customer_accrual.singular		=	"Customer Specific Accrual">

<cfset label.customer_fixed.singular		=	"Customer Specific fixed">

<cfset label.user_total.singular			=	"User Total">

<CFSET label.budget_class.singular 			= 	budget_class.Dashboard_Labels_Singular>
<CFSET label.budget_class.plural 			= 	budget_class.Dashboard_Labels_Plural>

<CFSET label.territory.singular 			= 	territory.Dashboard_Labels_Singular>
<CFSET label.territory.plural 				= 	territory.Dashboard_Labels_Plural>

<CFSET label.customer.singular 				= 	customer.Dashboard_Labels_Singular>
<CFSET label.customer.plural 				= 	customer.Dashboard_Labels_Plural>

<CFSET label.program.singular 				= 	program.Dashboard_Labels_Singular>
<CFSET label.program.plural 				= 	program.Dashboard_Labels_Plural>

<CFSET label.sub_region.singular 			= 	sub_region.Dashboard_Labels_Singular>
<CFSET label.sub_region.plural 				= 	sub_region.Dashboard_Labels_Plural>

<CFSET label.budget.singular 				= 	budget.Dashboard_Labels_Singular>
<CFSET label.budget.plural 					= 	budget.Dashboard_Labels_Plural>

<CFSET label.billback.singular 				= 	billback.Dashboard_Labels_Singular>
<CFSET label.billback.plural 				= 	billback.Dashboard_Labels_Plural>

<CFSET label.sales.singular 				= 	sales.Dashboard_Labels_Singular>
<CFSET label.sales.plural 					= 	sales.Dashboard_Labels_Plural>

<CFSET label.performance.singular 			= 	performance.Dashboard_Labels_Singular>
<CFSET label.performance.plural 			= 	performance.Dashboard_Labels_Plural>





<CFSET label.family.singular 				= 	family.Dashboard_Labels_Singular>
<CFSET label.family.plural 					= 	family.Dashboard_Labels_Plural>

<CFSET label.distributor.singular 			= 	distributor.Dashboard_Labels_Singular>
<CFSET label.distributor.plural 			= 	distributor.Dashboard_Labels_Plural>

<CFSET label.budget_dollar.singular 		= 	budget_dollar.Dashboard_Labels_Singular>
<CFSET label.budget_dollar.plural 			= 	budget_dollar.Dashboard_Labels_Plural>

<CFSET label.commit.singular 				= 	commit.Dashboard_Labels_Singular>
<CFSET label.commit.plural 					= 	commit.Dashboard_Labels_Plural>

<CFSET label.invoice.singular 				= 	invoice.Dashboard_Labels_Singular>
<CFSET label.invoice.plural 				= 	invoice.Dashboard_Labels_Plural>
