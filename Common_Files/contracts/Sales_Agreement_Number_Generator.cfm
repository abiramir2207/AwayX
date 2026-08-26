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
	<!--- Retrieve the last contract number	--->
	<CFQUERY NAME="Get_Highest_Contract_Number" datasource="#application.datasource#">
		SELECT	MAX (Export_Sales_Agreement_Number) as old_contract_number
		FROM	Export_Number_Generator_Sales_Agreements
	</CFQUERY>

	<!--- Create next contract number	--->
	<CFSET new_number=IncrementValue(Get_Highest_Contract_Number.old_contract_number)>

	<!--- Save new contract Number --->
	<CFQUERY NAME="Save_Contract_Number" datasource="#application.datasource#">
		INSERT INTO Export_Number_Generator_Sales_Agreements values(#new_number#)
	</CFQUERY>

	<!------ Format the number  ----->
	<cfset generator_contract_number = CreateObject("component", "components.settings.ApplicationNumberManager").getFormatedBANumber
				(
					number = new_number,
					prefix = application.oApplicationAppSettingsManager.getApplicationAppSettings().getProgramNumberPrefix()
				) />	
</cflock> 
