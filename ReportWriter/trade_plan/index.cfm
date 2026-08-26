<!---
	Name:
		index.cfm
	Created By:
		Tim Ford 04/10/2003
	Description:
		Index page for trade plan report tool
--->

<html>
<head>
	<title><CFOUTPUT>#application.returned_customer_setting.Trade_Label# Spending #Application.PlannerLabel#</CFOUTPUT></title>
</head>
<body LEFTMARGIN="0" TOPMARGIN="0">
<cfparam name="page_title" default="#application.returned_customer_setting.Trade_Label# Spending #Application.PlannerLabel#" />

<cfparam name="url.action" default="list" />

<cfset action = url.action />

<cfif isDefined("Form.action")>
	<cfset action = Form.action />
</cfif>

<!---if the action is volume app then we need strip out headers and links and popup index.cfm--->
<cfif compareNoCase(action, "volumeApp")>

	<CFINCLUDE TEMPLATE="/includes/header.cfm" />

	<BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<BR>
<p></p>

	<!---Include navigate menu--->
	<cfinclude template="menu.cfm" />

</cfif>

<cfswitch expression="#action#">

	<cfcase value="volumeApp">
		<cfinclude template="volume_popup.cfm" />
	</cfcase>

	<cfcase value="create">
		<cfinclude template="trade_plan_calc.cfm" />
	</cfcase>

	<cfcase value="create_calculate">
		<cfinclude template="trade_plan_calc.cfm" />
	</cfcase>

	<cfcase value="save">
		<cfinclude template="create_trade_plan_save.cfm" />
		<cflocation url="index.cfm?action=display&Trade_Plan_ID=#TradePlanUUID#" addtoken="no" />
	</cfcase>

	<cfcase value="list">
		<cfinclude template="get_trade_plan.cfm" />
	</cfcase>

	<cfcase value="edit">
		<cfinclude template="trade_plan_calc.cfm" />
	</cfcase>

	<cfcase value="copy">
		<cfinclude template="trade_plan_calc.cfm" />
	</cfcase>


	<cfcase value="update">
		<cfinclude template="update_trade_plan_save.cfm" />
 		<cflocation url="index.cfm?action=display&Trade_Plan_ID=#Trade_Plan_ID#" addtoken="no" />
	</cfcase>

	<cfcase value="email">
		<cfinclude template="create_email.cfm" />
	</cfcase>

	<cfcase value="email_send">
		<cfinclude template="send_email.cfm" />
		<cflocation url="index.cfm?action=display&Trade_Plan_ID=#Trade_Plan_ID#" addtoken="no" />
	</cfcase>

	<cfcase value="fax">
		<cfinclude template="create_fax.cfm" />
	</cfcase>

	<cfcase value="fax_send">
		<cfinclude template="send_fax.cfm" />
		<cflocation url="index.cfm?action=display&Trade_Plan_ID=#Trade_Plan_ID#" addtoken="no" />
	</cfcase>

	<cfcase value="display">
		<cfinclude template="trade_plan_calc.cfm" />
	</cfcase>

	<cfcase value="delete">
		<cfinclude template="delete_trade_plan.cfm" />
		<cflocation url="index.cfm" addtoken="no" />
	</cfcase>

	<cfcase value="createWIP">
		<!---validate the Incentive costs--->
		<cfscript>
			tradePlan = createObject("component","components.trade_plan.trade_plan");
			bIsValid = tradePlan.validateIncentiveCosts(Trade_Plan_ID);
		</cfscript>

		<cfif bIsValid>
			<cfinclude template="create_wip.cfm" />
		<cfelse>
			<script>alert("At least one Product Type Group must be checked for Program Incentive Costs.\nProgram Incentive Costs can't have a total of zero when creating a program.");</script>
			<cfset action = "display" />
			<cfinclude template="trade_plan_calc.cfm" />
		</cfif>

	</cfcase>

</cfswitch>

<cfif compareNoCase(action, "volumeApp")>
	<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</cfif>

</body>
</html>
