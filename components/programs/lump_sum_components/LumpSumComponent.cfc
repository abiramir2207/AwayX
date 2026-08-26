<!---
	Description:
		Component used for Lump Sum Components

--->

<cfcomponent>

	
	<CFQUERY NAME="qGetLumpSumComponents" datasource="#application.datasource#">
		SELECT *
		FROM Program_Lump_Sums
		WHERE 0<>0
	</CFQUERY>
	
	<cfloop index="index" list="#qGetLumpSumComponents.columnList#">
		<cfset "this.#index#" = "NULL" />
	</cfloop>
	
	<cffunction name="new" output="false">
    
		<cfargument name="lumpSumAmount" type="string" required="false" default="">
	<!--- 	<cfargument name="lumpSumName" type="string" required="false" default=""> --->
		<cfargument name="programLumpSumNameId" type="string" required="false" default="">
		<cfargument name="volume" type="string" required="false" default="">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="deleted" type="string" required="false" default="">
		<cfargument name="lumpSumId" type="string" required="false" default="">
		<cfargument name="recordCount" type="string" required="false" default="">

    	<cfset this.LUMP_SUM_AMOUNT = arguments.lumpSumAmount>
<!--- 		<cfset this.LUMP_SUM_NAME = arguments.lumpSumName> --->
		<cfset this.PROGRAM_LUMP_SUM_NAME_ID = arguments.programLumpSumNameId>
		<cfset this.LUMP_SUM_VOLUME = arguments.volume>
		<cfset this.LUMP_SUM_DESCRIPTION = arguments.description>
		<cfset this.DELETED = arguments.deleted>
		<cfset this.PROGRAM_LUMP_SUM_ID = arguments.lumpSumId>
		<cfset this.recordCount = arguments.recordCount>

  	</cffunction>
	
	<cffunction name="getActive" output="false" returntype="query">	
		
		<cfargument name="lumpSumNameId" required="false" default=0 />
		
		<cfquery name="qGetActiveLumpSumNames" datasource="#application.datasource#">
			SELECT 	Program_Lump_Sum_Name,
					Program_Lump_Sum_Name_ID 
			FROM 	Program_Lump_Sum_Name
			WHERE 	Deleted = 0
			AND		(
						Active = 1
						OR 		Program_Lump_Sum_Name_ID = #arguments.lumpSumNameId#
					)
			
			ORDER BY 	Program_Lump_Sum_Name
			
		</cfquery>

		<cfreturn qGetActiveLumpSumNames />
		
   	</cffunction>
	
	<cffunction name="getDesc" output="false" returntype="string">	
		
		<cfargument name="lumpSumNameId" required="false" default=0 />
		
		<cfset qGetActiveLumpSumNames = getActive(arguments.lumpSumNameId) />

		<cfreturn qGetActiveLumpSumNames.Program_Lump_Sum_Name />
		
   	</cffunction>
	
	<cffunction name="getLumpSumName" output="false" returntype="query">	
   
   		<cfargument name="lumpSumNameId" required="false" default=0 />
		
		<cfset useLakebaseForqGetLumpSumName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_lump_sum_name")>
<cfif useLakebaseForqGetLumpSumName>
	<cftry>
		<cfset qGetLumpSumName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_lump_sum_name", {
				"program_lump_sum_name_id" = "eq.#arguments.lumpSumNameId#",
				"select" = "program_lump_sum_name,program_lump_sum_name_id"
			}), "program_lump_sum_name,program_lump_sum_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLumpSumName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLumpSumName>
<cfquery name="qGetLumpSumName" datasource="#application.datasource#">
			SELECT 	Program_Lump_Sum_Name,
					Program_Lump_Sum_Name_ID 
			FROM 	Program_Lump_Sum_Name
			WHERE 	Program_Lump_Sum_Name_ID = #arguments.lumpSumNameId#	
		</cfquery>
</cfif>

		<cfreturn qGetLumpSumName />
		
   	</cffunction>
	
</cfcomponent>