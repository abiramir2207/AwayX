<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- get the data from the terminology table --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset useLakebaseForget_all = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dashboard_labels")>
<cfif useLakebaseForget_all>
	<cftry>
		<cfset get_all = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dashboard_labels", {
				"deleted" = "eq.0",
				"select" = "dashboard_labels_desc,dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_desc,dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_all = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_all>
<CFQUERY NAME="get_all" datasource="#Application.Datasource#">
	
	Select	Dashboard_Labels_Desc, 
			Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	
	From	Dashboard_Labels
	
	Where	Deleted = 0

</CFQUERY>
</cfif>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- query the master query looking for the right terms							 	--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfset useLakebaseForbudget_class = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForbudget_class>
	<cftry>
		<cfset budget_class = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Budget Class",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForbudget_class = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForbudget_class>
<CFQUERY name="budget_class" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Budget Class'
</cfquery>
</cfif>	

<cfset useLakebaseForterritory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForterritory>
	<cftry>
		<cfset territory = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Territory",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForterritory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForterritory>
<CFQUERY name="territory" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Territory'
</cfquery>
</cfif>	

<cfset useLakebaseForcustomer = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForcustomer>
	<cftry>
		<cfset customer = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Customer",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcustomer = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcustomer>
<CFQUERY name="customer" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Customer'
</cfquery>
</cfif>	

<cfset useLakebaseForprogram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForprogram>
	<cftry>
		<cfset program = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Program",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForprogram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForprogram>
<CFQUERY name="program" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Program'
</cfquery>
</cfif>	

<cfset useLakebaseForsub_region = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForsub_region>
	<cftry>
		<cfset sub_region = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Sub Region",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsub_region = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsub_region>
<CFQUERY name="sub_region" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Sub Region'
</cfquery>
</cfif>	

<cfset useLakebaseForBudget = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForBudget>
	<cftry>
		<cfset Budget = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Budget",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBudget = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBudget>
<CFQUERY name="Budget" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Budget'
</cfquery>
</cfif>	

<cfset useLakebaseForbillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForbillback>
	<cftry>
		<cfset billback = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Billback",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForbillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForbillback>
<CFQUERY name="billback" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Billback'
</cfquery>
</cfif>	

<cfset useLakebaseForsales = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForsales>
	<cftry>
		<cfset sales = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Sales",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForsales = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsales>
<CFQUERY name="sales" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Sales'
</cfquery>
</cfif>	

<cfset useLakebaseForperformance = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForperformance>
	<cftry>
		<cfset performance = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Performance",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForperformance = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForperformance>
<CFQUERY name="performance" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Performance'
</cfquery>
</cfif>	







<cfset useLakebaseForfamily = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForfamily>
	<cftry>
		<cfset family = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Family",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForfamily = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForfamily>
<CFQUERY name="family" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Family'
</cfquery>
</cfif>	

<cfset useLakebaseFordistributor = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseFordistributor>
	<cftry>
		<cfset distributor = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Distributor",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordistributor = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordistributor>
<CFQUERY name="distributor" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Distributor'
</cfquery>
</cfif>	

<cfset useLakebaseForbudget_dollar = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForbudget_dollar>
	<cftry>
		<cfset budget_dollar = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Budget Dollar",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForbudget_dollar = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForbudget_dollar>
<CFQUERY name="budget_dollar" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Budget Dollar'
</cfquery>
</cfif>	

<cfset useLakebaseForcommit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForcommit>
	<cftry>
		<cfset commit = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Committed Dollar",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcommit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcommit>
<CFQUERY name="commit" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Committed Dollar'
</cfquery>
</cfif>	

<cfset useLakebaseForinvoice = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("get_all")>
<cfif useLakebaseForinvoice>
	<cftry>
		<cfset invoice = application.oLakebase.toQuery(
			application.oLakebase.selectRows("get_all", {
				"dashboard_labels_desc" = "eq.Invoice",
				"select" = "dashboard_labels_singular,dashboard_labels_plural"
			}), "dashboard_labels_singular,dashboard_labels_plural"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForinvoice = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinvoice>
<CFQUERY name="invoice" datasource="#Application.Datasource#" dbtype="query">
	Select	Dashboard_Labels_Singular, 
			Dashboard_Labels_Plural
	From	get_all
	Where	Dashboard_Labels_Desc = 'Invoice'
</cfquery>
</cfif>	


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
