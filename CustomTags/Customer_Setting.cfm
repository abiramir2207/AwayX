<cfparam name="attributes.generic_setting_id"	default="">
<cfparam name="attributes.company_main_id"		default="">
<cfparam name="default_customer_setting"		default="Default Label">
<cfparam name="attributes.return_variable_name"	default="">
<cfset customer_setting_error_string 			= "DATA LABELING INTERFACE MISHAP, IF YOU CAN SEE THIS PLEASE CONTACT YOUR ADMINISTRATOR">
<cfset cache_settings	= 1>

<cfif len(trim(attributes.generic_setting_id)) GT 0 AND len(trim(attributes.company_main_id)) GT 0 AND len(trim(attributes.return_variable_name)) GT 0>
	<cfif not isdefined("caller.returned_customer_setting")>
		<cfset caller.returned_customer_setting = structnew()>
		<cfset caller.returned_customer_setting.customer_setting_default_label = default_customer_setting>
		<cfset caller.returned_customer_setting.customer_setting_error_string = customer_setting_error_string>
	</cfif>
	
	<cftry>
		<cfif cache_settings EQ 1>
			<cfset cache_window = createtimespan(0,24,0,0)>
		<cfelse>
			<cfset cache_window = createtimespan(0,0,0,0)>
		</cfif>
		
		<cfquery name="getDataLabel" datasource="#application.datasource#" cachedwithin="#cache_window#">
			SELECT #attributes.generic_setting_id# 
			FROM 
						Customer_Settings
		</cfquery>
		
		<cfif getDataLabel.recordcount EQ 0>
			<CFSET "caller.returned_customer_setting.#attributes.return_variable_name#" = default_customer_setting>
		<cfelse>
			<CFSET "caller.returned_customer_setting.#attributes.return_variable_name#" = evaluate("getDataLabel.#attributes.generic_setting_id#")>
		</cfif>
	<cfcatch type="Any">
		<CFSET "caller.returned_customer_setting.#attributes.return_variable_name#" = customer_setting_error_string>
	</cfcatch>
	</cftry>
<cfelse>

</cfif>