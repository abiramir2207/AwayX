<!--- <cf enterchat url="The full url to a chat entrance form"> --->

<cfif not isdefined("attributes.url")>
	The "url" parameter is missing.<cfabort>
</cfif>

<cfset params="">
<cfif isdefined("cookie.wchuname")>
	<cfset params="?rcu=#cookie.wchuname#">
	<cfif isdefined("cookie.wchuemail")>
		<cfset params=params & "&rce=#cookie.wchuemail#">
	<cfelse>
		<cfset params=params & "&rce=">
	</cfif>
</cfif>

<cfhttp method="GET" url="#attributes.url##params#" timeout="10"></cfhttp>

<cfoutput>#CFHTTP.FileContent#</cfoutput>
