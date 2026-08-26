<cfparam name="url.ID" default="">

<cfset thisReferer = replacenocase(cgi.http_referer, cgi.http_host, "", "ALL")>
<cfif thisReferer EQ "http:///settings/index2.cfm" AND len(url.ID) GT 0>
	<cfquery name="deleteRule" datasource="#application.datasource#">
		UPDATE Bid_Rules
		SET Deleted = 1
		WHERE Bid_Rule_ID = '#url.ID#'
	</cfquery>
</cfif>

<cflocation url="index.cfm">
