<CFQUERY NAME="deleteCompany" datasource="#application.datasource#">
	UPDATE Company_Main
	SET deleted = 1
	WHERE Company_Main_ID = '#FORM.Company_Main_ID#'
</CFQUERY>

<CFLOCATION URL="companies_search_form.cfm">