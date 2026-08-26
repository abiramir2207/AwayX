<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR><BR>

<cfset useLakebaseForgetDistOpPricing = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForgetDistOpPricing>
	<cftry>
		<cfset getDistOpPricing = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDistOpPricing = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDistOpPricing>
<cfquery name="getDistOpPricing" datasource="#application.datasource#">
SELECT *
FROM BSA_Foodservice_Customers
</cfquery>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body BGCOLOR="WhiteSmoke">
<form action="op_dev_pricing_settings_Action.cfm" method="post" name="theForm" id="theForm">

<style type="text/css">
		body, table, td
		{font-family: Arial; font-size: 12px;}
		.data
		{font-size: 12px; font-weight: bold}
		select, TEXTAREA
		{width:	200px;font-size: 10px;}
		TEXTAREA
		{width:	400px;font-size: 10px;}

		TABLE.Maintable TD
		{border-bottom:solid #93BEE2 1px; font-size : 10px;}

		Maintable
		{cellspacing: 0;}

		header
		{font-size: 12px;}

</style>


<table>
	<TR>
		<TD>
			<!--- <div style="height: 500px; overflow: scroll; overflow-x: hidden;"> --->
				<TABLE ID="assignmentList" CELLPADDING="2" CELLSPACING="0" CLASS="maintable" WIDTH="600">
					<TR VALIGN="bottom" BGCOLOR="#FFCE84">
						<TD id="header"><b><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput></b></TD>
						<TD id="header"><b>Deduct</b></TD>
						<TD id="header"><b>Pullback</b></TD>
					</TR>
				<cfoutput>
					<cfloop query="getDistOpPricing">
						<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
							<TD>#getDistOpPricing.name#</TD>
							<TD><input name="ODP_#getDistOpPricing.BSA_Foodservice_Customers_ID#" value="1" type="Radio" <cfif getDistOpPricing.Op_Dev_Pricing EQ 1>checked</cfif>></TD>
							<TD><input name="ODP_#getDistOpPricing.BSA_Foodservice_Customers_ID#" value="2" type="Radio" <cfif getDistOpPricing.Op_Dev_Pricing EQ 2>checked</cfif>></TD>
						</TR>	
					</cfloop>
				</cfoutput>	
				</table>
			<!--- </DIV> --->
		</TD>
	</TR>
	<TR>
		<TD><input type="submit" value="save"></TD>
	</TR>
</table>
</form>
</body>
</html>
