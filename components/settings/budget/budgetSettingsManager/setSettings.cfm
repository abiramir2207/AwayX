	<!--- Update Default Selections and Control Levels --->
	<cffunction name="setSettings" output="No" hint="Update Budget Control Panel Settings - Defaults & Control Levels">
		<cfargument name="trade_control_levels" required="true" type="numeric">
		<cfargument name="volume_control_levels" required="true" type="numeric">
		<cfargument name="trade_allocation_type_selection" required="true" type="numeric">
		<cfargument name="volume_allocation_type_selection" required="true" type="numeric">
		<cfargument name="volume_uom_selection" required="true" type="numeric">
		<cfargument name="trade_product_group_selection" required="true" type="numeric">
		<cfargument name="volume_product_group_selection" required="true" type="numeric">
		<cfargument name="trade_sales_group_selection" required="true" type="numeric">
		<cfargument name="volume_sales_group_selection" required="true" type="numeric">
		<cfargument name="trade_customer_group_selection" required="true" type="numeric">
		<cfargument name="volume_customer_group_selection" required="true" type="numeric">
		<cfargument name="user_id" required="true" type="string">

		<cfquery name="qUpdateSettings" datasource="#application.datasource#">
			UPDATE budget_control_panel_settings 
			SET
			trade_control_levels = #arguments.trade_control_levels#,
			volume_control_levels = #arguments.volume_control_levels#,
			trade_allocation_type_selection = #arguments.trade_allocation_type_selection#,
			volume_allocation_type_selection = #arguments.volume_allocation_type_selection#,
			volume_uom_selection = #arguments.volume_uom_selection#,
			trade_product_group_selection = #arguments.trade_product_group_selection#,
			volume_product_group_selection = #arguments.volume_product_group_selection#,
			trade_sales_group_selection = #arguments.trade_sales_group_selection#,
			volume_sales_group_selection = #arguments.volume_sales_group_selection#,
			trade_customer_group_selection = #arguments.trade_customer_group_selection#,
			volume_customer_group_selection = #arguments.volume_customer_group_selection#,
			Updated_By = '#arguments.user_id#',
			Updated_On = getdate()
		</cfquery>
	</cffunction>