<!------ handler_core.cfm ----->
<!---include style sheet--->
<style>
	<cfinclude template="/common_files/main_style.css">
</style>
<cfparam name="url.id" 	default="0">
<cfparam name="form.id" 	default="#url.id#">

<cfparam name="url.command" 	default="">
<cfparam name="form.command" 	default="#url.command#">

<cfset thisPage = CGI.SCRIPT_NAME>
<cfset thisPageUrl = "#CGI.SCRIPT_NAME#?#CGI.QUERY_STRING#">
<cfset pagePhase = 0>
<!---switch for mode--->

<!------ <cfinclude template="/includes/call_please_wait.cfm"> ----->
<cfswitch expression="#form.command#">
	
	<!------ Create/Edit/Display initial request ----->
	<cfcase value="ceInitialRequest,sInitialRequest,sInitialRequestForward,dRequest" delimiters=",">
		<cfset pagePhase = 1>
		<cfinclude template="initial_request.cfm">
	</cfcase>

	
	<!------ Edit materials section ----->
	<cfcase value="ceRequestMaterials,sRequestMaterials,sRequestMaterialsToForward,sRequestMaterialsSupplier,sRequestMaterialsForward,dRequestMaterials" delimiters=",">
		<cfset pagePhase = 2>
		<cfinclude template="raw_materials.cfm">
	</cfcase>
	
	<!------ Edit procurement section ----->
	<cfcase value="dProcurement,ceProcurement,sProcurement,sProcurementForward" delimiters=",">
		<cfset pagePhase = 3>
		<cfinclude template="procurement.cfm">
	</cfcase>
	
	<!------ Edit pricing section ----->
	<cfcase value="dPricing,cePricing,sPricing,sPricingForward" delimiters=",">
		<cfset pagePhase = 4>
		<cfinclude template="pricing.cfm">
	</cfcase>
	
	<!------ Edit price in sales section ----->
	<cfcase value="dPriceInSales,cePriceInSales,sPriceInSales" delimiters=",">
		<cfset pagePhase = 5>
		<cfinclude template="price_in_Sales.cfm">
	</cfcase>
	
	<!------ Edit pricing section ----->
	<cfcase value="dealSheet" delimiters=",">		
		<cfinclude template="deal_sheet.cfm">
	</cfcase>
	
	<!------ got forward to next status ----->
	<cfcase value="saveForward" delimiters=",">		
		<cfinclude template="save_forward.cfm">
	</cfcase>	
	
	<!------ Create/Edit/Display notes ----->
	<cfcase value="dNotes,ceNotes,sNotes" delimiters=",">
		<cfinclude template="notes.cfm">
	</cfcase>
	
	<!------ Create/Edit/Display documents ----->
	<cfcase value="ceDocuments,sDocuments" delimiters=",">
		<cfinclude template="documents.cfm">
	</cfcase>
	
	<!------ Create/Edit/Display reminders ----->
	<cfcase value="dReminder,ceReminder,sReminder" delimiters=",">
		<cfinclude template="reminder.cfm">
	</cfcase>
	
	<!------ Create/Edit request dates ----->
	<cfcase value="ceRequestDates" delimiters=",">
		<cfinclude template="request_dates_create_edit.cfm">
	</cfcase>
	
	<!------ Chnage users ----->
	<cfcase value="ceSelectUser" delimiters=",">
		<cfinclude template="select_users.cfm">
	</cfcase>
	
</cfswitch>