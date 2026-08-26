<cfcomponent hint="Volume Unit Of Time Manager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.volume.uotManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.volume.uot">
		<cfargument name="id" type="numeric" required="false" default="0" />
	
		<cfset this.uot = CreateObject("component", "components.volume.uot").init() />
		
		<cfif arguments.id>
		
			<cfset qGetUOT = this.getAll(arguments.id) />
			
			<cfloop query="qGetUOT">
			
				<cfset this.uot.setId(Volume_UOT_ID) />
				<cfset this.uot.setDesc(UOT_Desc) />
				<cfset this.uot.setNounDesc(UOT_Desc_Noun) />
				<cfset this.uot.setMultiplier(Unit_Multiplier) />
			
			</cfloop>
		
		</cfif>
		
		<cfreturn this.uot />
		
	</cffunction>
	
	<cffunction name="getDefaultVolumeUOT" output="false" returntype="components.volume.uot">
		<cfargument name="companyId" type="string" required="true" />
		
		<cfset useLakebaseForqGetDefaultUOT = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForqGetDefaultUOT>
	<cftry>
		<cfset qGetDefaultUOT = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#arguments.companyId#",
				"select" = "volume_uot_id"
			}), "volume_uot_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDefaultUOT = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDefaultUOT>
<cfquery name="qGetDefaultUOT" datasource="#application.datasource#">
			Select	Volume_UOT_ID
			From	_Users_Settings					
			Where	_Users_Settings.User_ID		=	'#arguments.companyId#'
		</cfquery>
</cfif>
		
		<cfset defaultVolumeUOT = 0 />
		<cfloop query="qGetDefaultUOT">
			<cfif isNumeric(Volume_UOT_ID)>
				<cfset defaultVolumeUOT = Volume_UOT_ID />
			</cfif>
		</cfloop>
		<cfset this.get(defaultVolumeUOT) />
		
		<cfreturn this.uot />
		
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
	
		<cfquery name="qGetUOTs" datasource="#application.datasource#">
			SELECT	Volume_UOT_ID, UOT_Desc, UOT_Desc_Noun, Unit_Multiplier
			FROM	Volume_UOT
			WHERE
					Deleted = 0
					<cfif arguments.id>
					AND Volume_UOT_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
					</cfif>			
		</cfquery>
		
		<cfreturn qGetUOTs />
	
	</cffunction>
	  
   <!--- 
      22522/Anand Rao/24-Feb-2010
      Default unit of time for volume -- only allow Program 
      Added this function to return the Program UOM record alone
    --->
  <cffunction name="getUMZero" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
	
		<cfquery name="qGetUOTsUM" datasource="#application.datasource#">
			SELECT	Volume_UOT_ID, UOT_Desc, UOT_Desc_Noun, Unit_Multiplier
			FROM	Volume_UOT
			WHERE
					Deleted = 0
					<cfif arguments.id>
					AND Volume_UOT_ID = <cfqueryparam value="#arguments.id#" cfsqltype="CF_SQL_INTEGER">
					</cfif>		
          AND Unit_Multiplier = 0	
		</cfquery>
		
		<cfreturn qGetUOTsUM />
	
	</cffunction>
    
	<cffunction name="getStatusDesc" output="false" returntype="string">
		<cfargument name="id" type="numeric" required="true" />
	
		<cfset returnValue = "" />
		
		<cfset qGetUOTs = this.getAll(arguments.id) />
		
		<cfloop query="qGetUOTs">
			<cfset returnValue = UOT_Desc />
		</cfloop>
		
		<cfreturn returnValue />
	
	</cffunction>
	
	
</cfcomponent>
