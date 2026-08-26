<CFQUERY NAME="deleteCompany" datasource="#application.datasource#">
	UPDATE BSA_Foodservice_Brokers
	SET deleted = 1
	WHERE BSA_Foodservice_Brokers_ID = '#FORM.Broker_ID#'
</CFQUERY>

<CFLOCATION URL="brokers_search_form.cfm">