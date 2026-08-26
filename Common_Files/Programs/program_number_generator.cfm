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
	<!--- Retrieve the last Program number																 --->
	<CFQUERY NAME="Get_Highest_Program_Number" datasource="#application.datasource#">
		Select	Max (Program_Number) as old_program_number
		From	Number_Generator_Programs
	</CFQUERY>
	<!--- Create next contract number																	 --->
	<CFSET new_number=IncrementValue(Get_Highest_Program_Number.old_Program_number)>
	<!--- Save new contract Number																		 --->
	<CFQUERY NAME="Save_Program_Number" datasource="#application.datasource#">
	Insert into Number_Generator_Programs values(#new_number#)
	</CFQUERY>
	<cfswitch expression = #request.AccessStructure.Company_Main_ID#>
	  <cfcase value = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"><!--- BSA --->
		  <CFSET prefix="001-">
	  </cfcase>
	  <cfcase value = "2FE48D64-006A-4C2F-86CC2F58141A8274"><!--- Tyson --->
		  <CFSET prefix="002-">
	  </cfcase>
	  <cfcase value = "A680F76A-2C69-4DD5-A3A17A18A1C1D78B"><!--- The Test Company --->
		  <CFSET prefix="003-">
	  </cfcase>
	  <cfdefaultcase>
		  <CFSET prefix="000-"><!--- All other companies... --->
	  </cfdefaultcase>
	</cfswitch>
	<!--- Add to the contract number the prefix of the current company									 --->
	<CFSET generator_program_number=prefix&new_number>
	<!--- <CFOUTPUT>#generator_contract_number#</CFOUTPUT> --->
</cflock> 






