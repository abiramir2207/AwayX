
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<!--- block of code used that filters access rights and permissions --------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->
<CFSET getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(#request.AccessStructure.Profiles_ID#)>

<cfset useLakebaseForqDashboardAccessInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dashboard_access")>
<cfif useLakebaseForqDashboardAccessInfo>
	<cftry>
		<cfset qDashboardAccessInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dashboard_access", {
				"profile_id" = "eq.#request.AccessStructure.Profiles_ID#",
				"select" = "budget,budgets_territory_total,budgets_customer_specific_budgets,budgets_program_details,budgets_territory_budget_level_detail,budgets_sub_region_budget_level_detail,billback,billbacks_summary_table,billbacks_monthly_summary,billbacks_yearly_summary,billbacks_quarterly_summary,billbacks_stats,sales,sales_last_12_months_eqc,sales_fiscal_year_summary_eqc,sales_sales_view_drilldown,sales_tbm_sales_tracker,sales_nam_sales_tracker,sales_tracker,performance,performance_programs"
			}), "budget,budgets_territory_total,budgets_customer_specific_budgets,budgets_program_details,budgets_territory_budget_level_detail,budgets_sub_region_budget_level_detail,billback,billbacks_summary_table,billbacks_monthly_summary,billbacks_yearly_summary,billbacks_quarterly_summary,billbacks_stats,sales,sales_last_12_months_eqc,sales_fiscal_year_summary_eqc,sales_sales_view_drilldown,sales_tbm_sales_tracker,sales_nam_sales_tracker,sales_tracker,performance,performance_programs"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDashboardAccessInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDashboardAccessInfo>
<cfquery name="qDashboardAccessInfo" datasource="#application.datasource#">
	SELECT
	  
	budget,
	budgets_territory_total,
	budgets_customer_specific_budgets,
	budgets_program_details,
	budgets_territory_budget_level_detail,
	budgets_sub_region_budget_level_detail,
	
	billback,
	Billbacks_summary_table,
	Billbacks_monthly_summary,
	Billbacks_yearly_summary,
	Billbacks_quarterly_summary,
	Billbacks_stats,
	
	sales,
	Sales_last_12_months_eqc,
	Sales_fiscal_year_summary_eqc,
	Sales_sales_view_drilldown,
	Sales_TBM_sales_tracker,
	Sales_NAM_sales_tracker,
	Sales_tracker,
	
	performance,
	Performance_programs
	
	FROM Dashboard_Access
	WHERE Profile_ID = #request.AccessStructure.Profiles_ID#
</cfquery>
</cfif>  

<!--- 
<cfoutput>
	ProfileID:			#request.AccessStructure.Profiles_ID#<br />
	Access to Budgets:	#qDashboardAccessInfo.Budget#<br>
	Access to Billbacks:#qDashboardAccessInfo.Billback# <br>
	Access to Sales:	#qDashboardAccessInfo.Sales#<br>
	Remote Access:		#getProfiles.DASHBOARD_REMOTE_ACCESS#<br>
	Default UOM:		#getProfiles.DASHBOARD_UOM#<br>
</cfoutput>
 --->
 
 
<!--- ----------------------------------------------------------------------------------------- --->
<!--- ----------------------------------------------------------------------------------------- --->


<!--- ----------------------------------------------------------------------------------------- --->
<CFPARAM NAME="page_name" DEFAULT='Dashboards'>
<!--- ----------------------------------------------------------------------------------------- --->

<!--- ----------------------------------------------------------------------------------------- --->

<style type="text/css">
a.links
{
	margin: 0px 0px 0px 0px;
	padding: 3px 0px 3px 0px;
	border-bottom: 0px silver dotted;
}
</style>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td valign="middle"><a href="index.cfm"><img src="images/logo3_small.png" border="0" vspace="3" hspace="10" /></a></td>
        <td valign="middle" width="100%"><div class="header_page_name"><cfoutput>#page_name#</cfoutput>
        <td style="padding-right:15px;">
		
		<CFIF FindNoCase('ipad','#CGI.HTTP_USER_AGENT#') GREATER THAN 0 or FindNoCase('AppleWebKit','#CGI.HTTP_USER_AGENT#') GREATER THAN 0>
		<a href="/logoff.cfm"><img src="images/logoff2.png" border="0" /></a>
		</CFIF>

		</td>
    </tr>
</table>

<!--- ----------------------------------------------------------------------------------------- --->

<!--- math funtions used everywhere ----------------------------------------------------------- --->
<cfinclude template="udf_functions.cfm">
<!--- ----------------------------------------------------------------------------------------- --->
