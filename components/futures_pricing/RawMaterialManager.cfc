<cfcomponent hint="Futures Pricing Raw Material Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.RawMaterialManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.futures_pricing.RawMaterial">
		
		<cfargument name="id" type="string" required="true" />
		
		<cfset this.rawMaterial = CreateObject("component", "components.futures_pricing.RawMaterial").init() />
		
		<cfif arguments.id>
		
			<cfquery name="qGetRawMaterial" datasource="#application.datasource#">
				SELECT	FP_Raw_Material_ID, 
						Raw_Material_Number, 
						Raw_Material_Desc
				FROM	FP_Raw_Material
				WHERE	Deleted = 0
				AND		FP_Raw_Material_ID = #arguments.id#
			</cfquery>
			
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
		
		<cfquery name="qGetRawMaterials" datasource="#application.datasource#">
			SELECT	FP_Raw_Material_ID, 
					Raw_Material_Number, 
					Raw_Material_Desc
			FROM	FP_Raw_Material
			WHERE	Deleted = 0					
			AND		Active = 1
		</cfquery>
		
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
