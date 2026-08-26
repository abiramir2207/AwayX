

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This redirects the user to the search engine of choice										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFSET msnstring="#msn_query#"&#question#>
<CFSET googlestring="#google_query#"&#question#>


<CFIF search_engine EQ 1>
	<CFLOCATION URL="#googlestring#" ADDTOKEN="No">
<CFELSE>
	<CFLOCATION URL="#msnstring#" ADDTOKEN="No">
</CFIF>


