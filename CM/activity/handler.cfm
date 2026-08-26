<!------ operator.cfm ----->

<CFPARAM NAME="form.command" 	DEFAULT="">

<!---switch case for command--->
<cfswitch expression="#form.command#">

	<!------ Create / Edit / Save Activity ----->
	<cfcase value="ceActivity,svActivity" delimiters=",">
		<cfinclude template="activity_create_edit.cfm" />
	</cfcase>
	
	<!------ Search Activity ----->
	<cfcase value="sActivity" delimiters=",">
		<cfinclude template="activity_search.cfm" />
	</cfcase>
	
	<!------ Create / Edit Activity Template----->
	<cfcase value="ceActivityTemplate,svActivityTemplate" delimiters=",">
		<cfset commandSuffix = "ActivityTemplate" />
		<cfinclude template="activity_template_create_edit.cfm" />
	</cfcase>
	
</cfswitch>