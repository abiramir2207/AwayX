<!-----      
		Name: 			Dashboard_Access.cfm     
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						01/12/2012
						Dinesh Rachala
		Description:
                       This page save "dashboard" access for each profile.
----->

<cfparam name="form.profileId" 									default="">

<cfparam name="form.BudgetDashboard" 							default="0">
<cfparam name="form.Budgets_territory_total" 					default="0">
<cfparam name="form.Budgets_customer_specific_budgets" 			default="0">
<cfparam name="form.Budgets_program_details" 					default="0">
<cfparam name="form.Budgets_territory_budget_level_detail"		default="0">
<cfparam name="form.Budgets_sub_region_budget_level_detail"		default="0">

<cfparam name="form.BillbackDashboard" 							default="0">
<cfparam name="form.Billbacks_summary_table" 					default="0">
<cfparam name="form.Billbacks_monthly_summary" 					default="0">
<cfparam name="form.Billbacks_yearly_summary" 					default="0">
<cfparam name="form.Billbacks_quarterly_summary" 				default="0">
<cfparam name="form.Billbacks_stats" 							default="0">

<cfparam name="form.SalesDashboard" 							default="0">
<cfparam name="form.Sales_last_12_months_eqc" 					default="0">
<cfparam name="form.Sales_fiscal_year_summary_eqc" 				default="0">
<cfparam name="form.Sales_sales_view_drilldown" 				default="0">
<cfparam name="form.Sales_TBM_sales_tracker" 					default="0">
<cfparam name="form.Sales_NAM_sales_tracker" 					default="0">
<cfparam name="form.Sales_tracker" 								default="0">

<cfparam name="form.PerformanceDashboard" 						default="0">
<cfparam name="form.Performance_programs" 						default="0">


<cfif NOT isNumeric(form.profileId) OR form.profileId EQ 0>
	<!------ do nothing ----->
<cfelse>
	<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
	
	<cfset test = templateManager.SaveDashboardAccess(

				profileID								=	form.profileId,
				
				budget									= 	form.BudgetDashboard,
				Budgets_territory_total					=	form.Budgets_territory_total,
				Budgets_customer_specific_budgets		=	form.Budgets_customer_specific_budgets,
				Budgets_program_details					=	form.Budgets_program_details,
				Budgets_territory_budget_level_detail	=	form.Budgets_territory_budget_level_detail,
				Budgets_sub_region_budget_level_detail	=	form.Budgets_sub_region_budget_level_detail,
				
				billback								= 	form.BillbackDashboard,
				Billbacks_summary_table					=	form.Billbacks_summary_table,
				Billbacks_monthly_summary				=	form.Billbacks_monthly_summary,
				Billbacks_yearly_summary				=	form.Billbacks_yearly_summary,
				Billbacks_quarterly_summary				=	form.Billbacks_quarterly_summary,
				Billbacks_stats							=	form.Billbacks_stats,
				
				sales									= 	form.SalesDashboard,
				Sales_last_12_months_eqc				=	form.Sales_last_12_months_eqc,
				Sales_fiscal_year_summary_eqc			=	form.Sales_fiscal_year_summary_eqc,
				Sales_sales_view_drilldown				=	form.Sales_sales_view_drilldown,
				Sales_TBM_sales_tracker					=	form.Sales_TBM_sales_tracker,
				Sales_NAM_sales_tracker					=	form.Sales_NAM_sales_tracker,
				Sales_tracker							=	form.Sales_tracker,
				
				Performance								=	form.PerformanceDashboard,
				Performance_programs					=	form.Performance_programs

			) />
</cfif>
<cfquery name="UpdateGeneralInformation" datasource="#application.datasource#">
		UPDATE Profiles_Settings
		SET Last_Changed_Date		= getdate(),
		    Last_Changed_User_ID	= '#request.accessStructure.User_ID#'		
</cfquery>

<script language="JavaScript">
window.close();
</script>