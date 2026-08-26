<!--- 
FILE: 		Method: getXML()      							
FILENAME:   edi.cfc  							
CREATED: 	01/03/2008 - RBL
EDITED:		03/25/2008 - RBL

FUNCTIONALITY: 
1.) I return the main program letter information container via XML to the caller.
2.) I generate letters as requested for each program_id passed into within an array.
--->

<!--- base.awayx. --->

<cfcomponent output="false" alias="common_files.contracts.letters.edi">
	<!---
		 These are properties that are exposed by this CFC object.
		 These property definitions are used when calling this CFC as a web services, 
		 passed back to a flash movie, or when generating documentation

		 NOTE: these cfproperty tags do not set any default property values.
	--->

	<cfproperty name="program_letter_id" 					type="numeric" 	default="0">
	<cfproperty name="qGetProgramLetterXML" 			type="query" 		default="#queryNew('letter')#">
	<cfproperty name="xml_file" 									type="string" 	default="">
	<cfproperty name="xml_file_path" 							type="string" 	default="">
	<cfproperty name="xProgramLetterXML" 					type="string" 	default="">
  
  <cfproperty name="bAddCustomerProductNumbers" type="boolean" 	default="0">
  <cfproperty name="bLetterDisplayFreight"				type="boolean"	default="0">
  <cfproperty name="bIncludeVolumePage" 				type="boolean" 	default="0">
  <cfproperty name="bInsertWatermark" 					type="boolean" 	default="0">
  <cfproperty name="contractMainID" 						type="numeric" 	default="0">
  
  <cfproperty name="currentURL" 								type="string" 	default="">
  <cfproperty name="customerFreightUOM"					type="string"		default="Cs">
  <cfproperty name="generatorFolderPath" 				type="string" 	default="">
  <cfproperty name="generatorURL" 							type="string" 	default="">
  <cfproperty name="bLetterStatus"							type="boolean"	default="0">

	<cfscript>
		//Initialize the CFC with the default properties values.
		program_letter_id = 0;
		qGetProgramLetterXML = queryNew('letter');
		xml_file = "";
		xml_file_path = "";
		xProgramLetterXML = "";

		bAddCustomerProductNumbers = 0;
		bLetterDisplayFreight = 0;
		bIncludeVolumePage = 0;
		bInsertWatermark = 0;
		contractMainID = 0;
		currentURL = "";
		customerFreightUOM = "Cs";
		generatorFolderPath = "";
		generatorURL = "";
		bLetterStatus = 0;
	</cfscript>

	<!--- METHOD: getXML() --->
	<cffunction name="getXML" access="remote" returntype="xml" output="false" hint="I return the program information via XML to the caller.">
	
		<cfargument name="program_letter_id" type="numeric" default="0">
		
    <cfset var xml_file = "">
    
		<cfquery name="qGetProgramLetterXML" datasource="#application.datasource#">
		  SELECT 			*
		  FROM 				program_letters
		  WHERE 			program_letters.program_letters_id = #arguments.program_letters_id#
		</cfquery>
		
		<cfset xml_file = qGetProgramLetterXML.Letter_xml[1]>

		<cfxml casesensitive="no" variable="xProgramLetterXML">
			#xml_file#
		</cfxml>

		<!--- Attempt to process the function code --->
		<cftry>		
	
			<!--- Return the requested container to the caller --->
			<cfreturn xProgramLetterXML>
	
			<!--- If something went wrong with the function code... --->
			<cfcatch>		
				
				<!--- Return "False" to the caller --->
				<cfreturn "0">
				
			</cfcatch>		
			
		</cftry>	
		
	</cffunction>
  
  <!--- METHOD: generateLetters() --->
	<cffunction name="generateLetters" access="remote" returnType="boolean" output="false" hint="I generate a program letter for each contractMainID passed and respond to the caller as to whether or not it ran.">
  
    <cfargument name="bAddCustomerProductNumbers" 	type="boolean" 	default="0">
    <cfargument name="bLetterDisplayFreight" 					type="boolean" 	default="0">
    <cfargument name="bIncludeVolumePage" 					type="boolean" 	default="0">
    <cfargument name="bInsertWatermark" 						type="boolean" 	default="0">
    <cfargument name="contractMainID" 							type="numeric" 	required="yes">
    <cfargument name="customerFreightUOM"						type="string"		default="Cs">

		<cfset var currentURL = "http://" & cgi.http_host & CGI.SCRIPT_NAME>
		<cfset var generatorFolderPath = listDeleteAt(currentURL,listLen(currentURL,'/'),'/')>
		<cfset var generatorURL = listAppend(generatorFolderPath,'generate_opr_dis_letters.cfm','/')>
		<cfset var bLetterStatus = 0>

    <cfhttp url="#generatorURL#" method="get">
    	<cfhttpparam name="CMID" value="#arguments.contractMainID#">
      <cfhttpparam name="custprodnum" value="#arguments.bAddCustomerProductNumbers#">
      <cfhttpparam name="freightpage" value="#arguments.bLetterDisplayFreight#">
      <cfhttpparam name="freightuom" value="#arguments.customerFreightUom#">
      <cfhttpparam name="volumepage" value="#arguments.bIncludeVolumePage#">
      <cfhttpparam name="watermark" value="#arguments.bInsertWatermark#">
    </cfhttp>
    
    <cfset bLetterStatus = 1>

  	<!--- Attempt to process the function code --->
		<cftry>		
	
			<!--- Return Status to the caller --->
			<cfreturn bLetterStatus>
	
			<!--- If something went wrong with the function code... --->
			<cfcatch>		
				
				<!--- Return "False" to the caller --->
				<cfreturn 0>
				
			</cfcatch>		
			
		</cftry>
  
  </cffunction>

</cfcomponent>