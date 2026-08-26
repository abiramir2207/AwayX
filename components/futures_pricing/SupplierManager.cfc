<cfcomponent hint="Supplier Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.futures_pricing.SupplierManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.futures_pricing.Supplier">
		
		<cfargument name="id" type="string" required="true" />
		
		<cfset this.supplier = CreateObject("component", "components.futures_pricing.Supplier").init() />
		
		<cfif arguments.id>
		
			<cfset useLakebaseForqGetSupplier = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("fp_supplier")>
<cfif useLakebaseForqGetSupplier>
	<cftry>
		<cfset qGetSupplier = application.oLakebase.toQuery(
			application.oLakebase.selectRows("fp_supplier", {
				"deleted" = "eq.0",
				"fp_supplier_id" = "eq.#arguments.id#",
				"select" = "fp_supplier_id,supplier_name"
			}), "fp_supplier_id,supplier_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetSupplier = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetSupplier>
<cfquery name="qGetSupplier" datasource="#application.datasource#">
				SELECT	FP_Supplier_ID, Supplier_Name
				FROM	FP_Supplier
				WHERE
						Deleted = 0
						AND
						FP_Supplier_ID = #arguments.id#
			</cfquery>
</cfif>
			
			<cfloop query="qGetSupplier">
			
				<cfset this.supplier.setId(FP_Supplier_ID)>
				<cfset this.supplier.setName(Supplier_Name)>
			
			</cfloop>
			
		</cfif>
		
		<cfreturn this.supplier />
	
	</cffunction>
	
	<cffunction name="save" output="false">
	
		<cfif this.supplier.getId()>
			<!------ update ----->
			<cfquery name="qUpdateRawMaterial" datasource="#application.datasource#">
				UPDATE	FP_Supplier
				SET		Supplier_Name = <cfqueryparam value="#this.supplier.getName()#" cfsqltype="CF_SQL_VARCHAR">
				WHERE
						Deleted = 0
						AND
						FP_Supplier_ID = #this.supplier.getId()#
			</cfquery>
		
		<cfelse>
			<!------ insert ----->
			<cfquery name="qInsertRawMaterial" datasource="#application.datasource#">
				INSERT INTO FP_Supplier
						(Supplier_Name)
				VALUES
						(<cfqueryparam value="#this.supplier.getName()#" cfsqltype="CF_SQL_VARCHAR">)
			</cfquery>
		
		</cfif>
	
	</cffunction>
	
	<cffunction name="deactivate" output="false">
	
		<!------ update ----->
		<cfquery name="qDeactivate" datasource="#application.datasource#">
			UPDATE	FP_Supplier
			SET		Active = <cfqueryparam value="0" cfsqltype="CF_SQL_BIT">
			WHERE	Deleted = 0
			AND		FP_Supplier_ID = #this.supplier.getId()#
		</cfquery>
	
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
		
		<cfquery name="qGetSuppliers" datasource="#application.datasource#">
			SELECT	FP_Supplier_ID, 
					Supplier_Name
			FROM	FP_Supplier
			WHERE	Deleted = 0
			AND		Active = 1					
		</cfquery>
		
		<cfreturn qGetSuppliers />
	
	</cffunction>
	
	<cffunction name="getSupplier" output="false" returntype="query">
	
		<cfargument name="lSupplierId" default="" required="false" />
		
		<cfquery name="qGetSupplier" datasource="#application.datasource#">
		
			SELECT	FP_Supplier_ID, 
					Supplier_Name
			FROM	FP_Supplier
			WHERE	Deleted = 0
			AND
				<cfif Len(trim(arguments.lSupplierId))>
					FP_Supplier_ID IN (#arguments.lSupplierId#)	
				<cfelse>
					1=2
				</cfif>
			
		</cfquery>
		
		<cfreturn qGetSupplier />
	
	</cffunction>

</cfcomponent>
