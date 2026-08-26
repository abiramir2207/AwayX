<cfparam name="url.user_id" default="">

<cfif len(trim(url.user_id)) GT 0>
	<cfquery name="saveAgreement" datasource="#application.datasource#">
		INSERT INTO usdanoi_agreements
		(user_id)
		VALUES
		('#url.user_id#')
	</cfquery>
</cfif>
<cflocation url="search.cfm">
