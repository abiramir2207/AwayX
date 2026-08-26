<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!---																									
An exclusive lock single-threads access to the CFML constructs in its body. Single-threaded access 		
implies that the body of the tag can be executed by at most one request at a time. A request executing	
inside a cflock tag has an "exclusive lock" on the tag. No other requests can start executing inside 	
the tag while a request has an exclusive lock. ColdFusion issues exclusive locks on a first-come, 		
first-served basis. 																					
																									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cflock timeout = "15"> 
	<!--- Generate new contract number --->
	<cfstoredproc procedure="generate_contract_number" datasource="#application.datasource#">
		<cfprocparam variable="new_number" type="out" cfsqltype="cf_sql_varchar" />
	</cfstoredproc>
	
	<!------ Format the number  ----->
	<cfset generator_contract_number = CreateObject("component", "components.settings.ApplicationNumberManager").getFormatedBANumber
				(
					number = new_number,
					prefix = application.oApplicationAppSettingsManager.getApplicationAppSettings().getProgramNumberPrefix()
				) />
	
</cflock> 
