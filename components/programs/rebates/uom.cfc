<cfcomponent>
	
	<cffunction name="getUomLabel" output="false" returntype="string">
	
		<cfargument name="uomId" type="string" required="true" default="0">
   
   		<cfset var labUomId = "" />
		
		<cfif trim(arguments.uomId) eq "">
			<cfset labUomId = 0 />
		<cfelse>
			<cfset labUomId = arguments.uomId  />
		</cfif>
		
		<cfset useLakebaseForqGetThisUom = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("units_of_measure")>
<cfif useLakebaseForqGetThisUom>
	<cftry>
		<cfset qGetThisUom = application.oLakebase.toQuery(
			application.oLakebase.selectRows("units_of_measure", {
				"unit_of_measure_id" = "eq.#labUomId#",
				"select" = "unit_of_measure_desc"
			}), "unit_of_measure_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetThisUom = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetThisUom>
<cfquery name="qGetThisUom" datasource="#application.datasource#">
			SELECT 	Unit_Of_Measure_Desc
			FROM	Units_of_Measure
			WHERE	Unit_Of_Measure_ID = #labUomId#
		</cfquery>
</cfif>
		
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