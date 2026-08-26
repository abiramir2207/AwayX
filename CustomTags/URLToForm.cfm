<!---
Purpose:
		Transfers URL structure key/value pairs to FORM structure
RequiredInput:
		none
OptionalInput:
		none
--->


<CFPARAM NAME="attributes.bOverrideFormVars" default="0" TYPE="boolean">

<cfloop collection="#url#" item="key">

	<cfif attributes.bOverrideFormVars or not isDefined("form.#key#")>
		<cfset "FORM.#key#" = url[key]>
	</cfif>
		
</cfloop>