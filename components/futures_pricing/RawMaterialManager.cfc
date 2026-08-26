<cfcomponent hint="Futures Pricing Raw Material Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.RawMaterialManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.futures_pricing.RawMaterial">
		
		<cfargument name="id" type="string" required="true" />
		
		<cfset this.rawMaterial = CreateObject("component", "components.futures_pricing.RawMaterial").init() />
		
		<cfif arguments.id>
		
			<cfset useLakebaseForqGetRawMaterial = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_raw_material")>
<cfif useLakebaseForqGetRawMaterial>
	<cftry>
		<cfset qGetRawMaterial = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_raw_material", {
				"deleted" = "eq.0",
				"fp_raw_material_id" = "eq.#arguments.id#",
				"select" = "fp_raw_material_id,raw_material_number,raw_material_desc"
			}), "fp_raw_material_id,raw_material_number,raw_material_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetRawMaterial = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetRawMaterial>
<cfquery name="qGetRawMaterial" datasource="#application.datasource#">
				SELECT	FP_Raw_Material_ID, 
						Raw_Material_Number, 
						Raw_Material_Desc
				FROM	FP_Raw_Material
				WHERE	Deleted = 0
				AND		FP_Raw_Material_ID = #arguments.id#
			</cfquery>
</cfif>
			
			<cfloop query="qGetRawMaterial">
			
				<cfset this.rawMaterial.setId(FP_Raw_Material_ID)>
				<cfset this.rawMaterial.setNumber(Raw_Material_Number)>
				<cfset this.rawMaterial.setDesc(Raw_Material_Desc)>
			
			</cfloop>
			
		</cfif>
		
		<cfreturn this.rawMaterial />
	
	</cffunction>
	
	<cffunction name="save" output="false">
	
		<cfif this.rawMaterial.getId()>
			<!------ update ----->
			<cfquery name="qUpdateRawMaterial" datasource="#application.datasource#">
				UPDATE	FP_Raw_Material
				SET		Raw_Material_Number = <cfqueryparam value="#this.rawMaterial.getNumber()#" cfsqltype="CF_SQL_VARCHAR">,
						Raw_Material_Desc = <cfqueryparam value="#this.rawMaterial.getDesc()#" cfsqltype="CF_SQL_VARCHAR">
				WHERE
						Deleted = 0
						AND
						FP_Raw_Material_ID = #this.rawMaterial.getId()#
			</cfquery>
		
		<cfelse>
			<!------ insert ----->
			<cfquery name="qInsertRawMaterial" datasource="#application.datasource#">
				INSERT INTO FP_Raw_Material
						(Raw_Material_Number, Raw_Material_Desc)
				VALUES
						(<cfqueryparam value="#this.rawMaterial.getNumber()#" cfsqltype="CF_SQL_VARCHAR">, <cfqueryparam value="#this.rawMaterial.getDesc()#" cfsqltype="CF_SQL_VARCHAR">)
			</cfquery>
		
		</cfif>
	
	</cffunction>
	
	<cffunction name="deactivate" output="false">
	
		<!------ update ----->
		<cfquery name="qDeactivate" datasource="#application.datasource#">
			UPDATE	FP_Raw_Material
			SET		Active = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
			WHERE	Deleted = 0
			AND		FP_Raw_Material_ID = #this.rawMaterial.getId()#
		</cfquery>
	
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
		
		<cfset useLakebaseForqGetRawMaterials = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_raw_material")>
<cfif useLakebaseForqGetRawMaterials>
	<cftry>
		<cfset qGetRawMaterials = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_raw_material", {
				"deleted" = "eq.0",
				"active" = "eq.1",
				"select" = "fp_raw_material_id,raw_material_number,raw_material_desc"
			}), "fp_raw_material_id,raw_material_number,raw_material_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetRawMaterials = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetRawMaterials>
<cfquery name="qGetRawMaterials" datasource="#application.datasource#">
			SELECT	FP_Raw_Material_ID, 
					Raw_Material_Number, 
					Raw_Material_Desc
			FROM	FP_Raw_Material
			WHERE	Deleted = 0					
			AND		Active = 1
		</cfquery>
</cfif>
		
		<cfreturn qGetRawMaterials />
	
	</cffunction>
	
	<cffunction name="getRawMaterials" output="false" returntype="query">
		
		<cfargument name="idList" type="string" required="true" />		
		
		<cfquery name="qGetRawMaterials" datasource="#application.datasource#">
			SELECT	FP_Raw_Material_ID, Raw_Material_Number, Raw_Material_Desc
			FROM	FP_Raw_Material
			WHERE
					Deleted = 0
					AND
					<cfif Len(arguments.idList) GT 0>
					FP_Raw_Material_ID IN (#arguments.idList#)	
					<cfelse>
					1=2
					</cfif>
		</cfquery>
		
		<cfreturn qGetRawMaterials />
	
	</cffunction>

</cfcomponent>
