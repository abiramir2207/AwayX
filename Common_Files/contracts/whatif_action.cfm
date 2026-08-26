<!---------------------------------------------------------------------------------------------------------------------
      Template:
      Label:    45515
      Date:     2014 October
      Author:   Chris Nguyen
      Purpose:  Posting action for program what-if
----------------------------------------------------------------------------------------------------------------------->

<cfif cgi.request_method eq 'post'>

	<!--- <cfdump var="#form#" abort="true"> --->

	<!--- save data into the db --->
	<cfscript>
    	variables.whatIfCFC = createObject("component", "components.programs.contractWhatIf");
    	if (form.action eq 'reset') {
    		variables.whatIfCFC.resetWhatIf( form.contract_main_id );
    	}
    	else {
    		variables.whatIfCFC.saveWhatIf( form.contract_main_id );
    	}
	</cfscript>

	<!--- no next page so close current window --->
	<cfif not structKeyExists(form, "next_page_url") or form.next_page_url eq "">
		<script>
			window.close();
		</script>

	<!--- next page exists and users did NOT click on apply all so redirect to new page --->
	<cfelseif form.action neq "apply all">
		<cfoutput><cflocation url="#form.next_page_url#" addtoken="false"></cfoutput>

	<!--- users clicked on apply all option, transfer all form variables to another action page --->
	<cfelse>
		<cfoutput>
		<form name="MyForm" action="#form.next_page_url#" method="post">
			<cfloop collection="#form#" item="variables.item">
				<input type="hidden" name="#variables.item#" value="#form[ variables.item ]#">
			</cfloop>
		</form>
		</cfoutput>

		<script>
			MyForm.submit();
		</script>
	</cfif>
</cfif>