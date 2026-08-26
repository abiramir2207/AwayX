<cfcomponent displayname="Contract Components" hint="Component responsible for interaction with contract information for a rebate component.">
   
   	<cffunction name="get" output="false" returntype="query">
		
		<cfargument name="contractMainId" type="numeric" required="true" default="">
		
		<cfquery name="qGetContractInfo" datasource="#application.datasource#">
			SELECT *
			FROM Contract_Main
			WHERE Contract_Main_ID = '#arguments.contractMainId#'
		</cfquery>
		
		<cfreturn qGetContractInfo />	

   	</cffunction>
	
	<cffunction name="getProgramId" output="false" returntype="query">
	
		<cfargument name="programId" type="string" required="true" default="">
		
		<CFQUERY NAME="qGetProgramType" datasource="#application.datasource#">
			SELECT 	ProgramType_ID
			FROM 	Contract_Main 
			WHERE Contract_Main_ID = '#arguments.programId#'
		</CFQUERY>
		
		<cfreturn qGetProgramType />
		
	</cffunction>
   
	<cffunction name="getDefaultUom" output="false" returntype="numeric">
	
		<cfargument name="programId" type="numeric" required="true" default="0">
		
		<cfset rDefaultUOM = 0 />
			
		<CFQUERY NAME="qGetDefaultUOM" datasource="#application.datasource#">
		
			SELECT 	RateTypeDefault
			FROM 	Program_Control_Panel_Options
					INNER JOIN Contract_Main ON
					Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
					AND Contract_Main.Deleted = 0
					AND Contract_Main.Contract_Main_ID = #arguments.programId#
			WHERE 	Program_Control_Panel_Options.Deleted = 0
			
		</CFQUERY>
		
		<cfif qGetDefaultUOM.RecordCount>
			<cfset rDefaultUOM = qGetDefaultUOM.RateTypeDefault />
		</cfif>
		
		<cfreturn rDefaultUOM />
		
	</cffunction>
	
</cfcomponent>
	
