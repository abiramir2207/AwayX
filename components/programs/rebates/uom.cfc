<cfcomponent>
	
	<cffunction name="getUomLabel" output="false" returntype="string">
	
		<cfargument name="uomId" type="string" required="true" default="0">
   
   		<cfset var labUomId = "" />
		
		<cfif trim(arguments.uomId) eq "">
			<cfset labUomId = 0 />
		<cfelse>
			<cfset labUomId = arguments.uomId  />
		</cfif>
		
		<cfquery name="qGetThisUom" datasource="#application.datasource#">
			SELECT 	Unit_Of_Measure_Desc
			FROM	Units_of_Measure
			WHERE	Unit_Of_Measure_ID = #labUomId#
		</cfquery>
		
		<cfreturn qGetThisUom.Unit_Of_Measure_Desc />	

   </cffunction>
   
   	<cffunction name="getUomAbbr" output="false" returntype="string">
	
		<cfargument name="uomId" type="string" required="true" default="0">
   		
		<cfset var abbrUomId = "" />
		
		<cfif trim(arguments.uomId) eq "">
			<cfset abbrUomId = 0 />
		<cfelse>
			<cfset abbrUomId = arguments.uomId  />
		</cfif>
		
		<cfquery name="qGetThisUom" datasource="#application.datasource#">
			SELECT 	Abbreviation
			FROM	Units_of_Measure
			WHERE	Unit_Of_Measure_ID = #abbrUomId#
		</cfquery>
		
		<cfreturn qGetThisUom.Abbreviation />	

   </cffunction>
   
</cfcomponent>