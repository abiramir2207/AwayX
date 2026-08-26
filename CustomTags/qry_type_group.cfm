

<cfparam name="attributes.Query_Name" default="qry_type_group">
<cfparam name="attributes.company_main_id" default="">
<cfparam name="attributes.BUSINESS_SEGMENT_ID" default="">

<cfquery name="#attributes.Query_Name#" datasource="#application.datasource#">
	<cfinclude template="#application.returned_customer_setting.qry_type_group_syntax#">
</cfquery>

<cfset "caller.#attributes.Query_Name#" = Duplicate(evaluate(attributes.Query_Name))>