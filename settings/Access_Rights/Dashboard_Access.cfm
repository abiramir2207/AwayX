<!-----      
		Name: 			Dashboard_Access.cfm     
               			Copyright (c) 2006 Blacksmith Applications, Inc.
		Created:
						01/12/2012
						Dinesh Rachala
		Description:
                       This page allows administrators to view and edit the list of "dashboard" each profile have access.
----->
<cfparam name="url.profileId" 	default="">
<cfif NOT isNumeric(url.profileId) OR url.profileId EQ 0>
	<cfabort>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Dashboard Access</title>
</head>

<body>

		<cfquery name="qDashboardAccessInfo" datasource="#application.datasource#">
			SELECT 
				Budget,
				Budgets_territory_total,
				Budgets_customer_specific_budgets,
				Budgets_program_details,
				Budgets_territory_budget_level_detail,
				Budgets_sub_region_budget_level_detail,
				
				Billback,
				Billbacks_summary_table,
				Billbacks_monthly_summary,
				Billbacks_yearly_summary,
				Billbacks_quarterly_summary,
				Billbacks_stats,
				
				Sales,
				Sales_last_12_months_eqc,
				Sales_fiscal_year_summary_eqc,
				Sales_sales_view_drilldown,
				Sales_TBM_sales_tracker,
				Sales_NAM_sales_tracker,
				Sales_tracker,
				
				Performance,
				Performance_programs

			FROM
				Dashboard_Access

			WHERE
				Profile_ID = #url.profileId#
		</cfquery>	


<font COLOR="Navy" SIZE="+1">Dashboard Access Control Panel</font>
<HR COLOR="orange">





<style>
	
	table.layout
	{
		width:				75%;
		margin:				0px auto 0px auto;
		border-collapse:	collapse;
	}
	
	td
	{
		padding:			1px 0px 1px 5px;
	}
	
	td.dash_group
	{
		background-color:	#FFFFFF;
		border-bottom:		2px #0000FF solid;
		font-size:			14px;
		font-weight:		bold; 
	}

	td.dash_setting, td.dash_group_setting
	{
		text-align:		right;
		padding-right:	20px;
	}

	
	td.dash_name, td.dash_setting
	{
		border-bottom:		1px #C6DEFF solid;
		padding-left:		20px;
		text-transform:		uppercase;	
	}

	td.separator
	{
		background-color:	#FFFFFF;
	}	


	img.warning
	{
		cursor:				pointer;
	}

</style>



<form method="post" name="frmDashboardAccess" action="dashboard_access_action.cfm">


<BR />


<TABLE class="layout">


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- budgets --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD class="dash_group">Budgets Dashboards</TD>
		<TD class="dash_group dash_group_setting">
			
						
			<img src="/Images/Control_panel/warning.png" class="warning" title="Unchecking this group means that none of the individual dashboards within will be available regardless of their individual settings">
			<input type="checkbox" value="1" name="BudgetDashboard"<cfif #qDashboardAccessInfo.Budget# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Budgets territory total</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Budgets_territory_total"<cfif #qDashboardAccessInfo.Budgets_territory_total# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Budgets customer specific budgets</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Budgets_customer_specific_budgets"<cfif #qDashboardAccessInfo.Budgets_customer_specific_budgets# EQ 1> checked</cfif>></TD>
	</TR>

	<TR>
		<TD class="dash_name">Budgets program details</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Budgets_program_details"<cfif #qDashboardAccessInfo.Budgets_program_details# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Budgets territory budget level detail</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Budgets_territory_budget_level_detail"<cfif #qDashboardAccessInfo.Budgets_territory_budget_level_detail# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Budgets sub region budget level detail</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Budgets_sub_region_budget_level_detail"<cfif #qDashboardAccessInfo.Budgets_sub_region_budget_level_detail# EQ 1> checked</cfif>></TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


	<TR>
		<TD class="separator" colspan="100%">&nbsp;&nbsp;</TD>
	</TR>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- billbacks --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD class="dash_group">Billbacks Dashboards</TD>
		<TD class="dash_group dash_group_setting">
			<img src="/Images/Control_panel/warning.png" class="warning" title="Unchecking this group means that none of the individual dashboards within will be available regardless of their individual settings">
			<input type="checkbox" value="1" name="BillbackDashboard"<cfif #qDashboardAccessInfo.Billback# EQ 1> checked</cfif> title="Unchecking this box will mean that none of the individual Billback dashboards will be available regardless of the individual settings"></TD>
	</TR>
	<TR>
		<TD class="dash_name">Billbacks summary table</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Billbacks_summary_table"<cfif #qDashboardAccessInfo.Billbacks_summary_table# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Billbacks monthly summary</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Billbacks_monthly_summary"<cfif #qDashboardAccessInfo.Billbacks_monthly_summary# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Billbacks yearly summary</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Billbacks_yearly_summary"<cfif #qDashboardAccessInfo.Billbacks_yearly_summary# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Billbacks quarterly summary</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Billbacks_quarterly_summary"<cfif #qDashboardAccessInfo.Billbacks_quarterly_summary# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Billbacks stats</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Billbacks_stats"<cfif #qDashboardAccessInfo.Billbacks_stats# EQ 1> checked</cfif>></TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<TR>
		<TD class="separator" colspan="100%">&nbsp;&nbsp;</TD>
	</TR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- sales --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD class="dash_group">Sales Dashboards</TD>
		<TD class="dash_group dash_group_setting">
			<img src="/Images/Control_panel/warning.png" class="warning" title="Unchecking this group means that none of the individual dashboards within will be available regardless of their individual settings">
			<input type="checkbox" value="1" name="SalesDashboard"<cfif #qDashboardAccessInfo.Sales# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Sales last 12 months_eqc</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Sales_last_12_months_eqc"<cfif #qDashboardAccessInfo.Sales_last_12_months_eqc# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Sales fiscal year summary eqc</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Sales_fiscal_year_summary_eqc"<cfif #qDashboardAccessInfo.Sales_fiscal_year_summary_eqc# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Sales view drilldown</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Sales_sales_view_drilldown"<cfif #qDashboardAccessInfo.Sales_sales_view_drilldown# EQ 1> checked</cfif>></TD>
	</TR>

	<TR>
		<TD class="dash_name">Sales Tracker</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Sales_tracker"<cfif #qDashboardAccessInfo.Sales_tracker# EQ 1> checked</cfif>></TD>
	</TR>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


	<TR>
		<TD class="separator" colspan="100%">&nbsp;&nbsp;</TD>
	</TR>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- performance --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<TR>
		<TD class="dash_group">Performance Dashboards</TD>
		<TD class="dash_group dash_group_setting">
			<img src="/Images/Control_panel/warning.png" class="warning" title="Unchecking this group means that none of the individual dashboards within will be available regardless of their individual settings">
			<input type="checkbox" value="1" name="PerformanceDashboard"<cfif #qDashboardAccessInfo.Performance# EQ 1> checked</cfif>></TD>
	</TR>
	<TR>
		<TD class="dash_name">Performance programs</TD>
		<TD class="dash_setting"><input type="checkbox" value="1" name="Performance_programs"<cfif #qDashboardAccessInfo.Performance_programs# EQ 1> checked</cfif>></TD>
	</TR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- note --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<tr>
		<TD colspan="100%" style="color:#FF0000; font-weight:bold; text-align:center;">
			<BR />
			When a group checkbox (Budgets, Billbacks, Sales or Performance) is "unchecked", it causes all Dashboards within that group
			to become unavailable regardless of the status of each one.
		</TD>
	</tr>

</TABLE>


<cfoutput><input type="Hidden" name="profileId" value="#url.profileId#" /></cfoutput>

</form>
<br>
<div align="center">
	<CF_BUTTON
		BUTTON_NAME		=	""
		BUTTON_CAPTION	=	"save settings"
		BUTTON_ACTION	=	"document.frmDashboardAccess.submit();"
		BUTTON_TYPE		=	"javascript_link"
		BUTTON_WIDTH	=	"100"
		BUTTON_COLOR	=	"Navy"
		BUTTON_TIP		=	""
		FONT_COLOR		=	"White"
		FONT_SIZE		=	"12"
		FONT_WEIGHT		=	"bold">
</div>

</body>
</html>
