<cfcomponent>
   
   <cffunction name="checkExists" output="false" returntype="boolean">	
   
	  	<cfargument name="aCompToCheck" type="array" required="true" default="">	
		<cfargument name="compID" type="string" required="true" default="">

   
   		<cfscript>
			
			doesExist = false;
			
			for (i=1; i lte ArrayLen(arguments.aCompToCheck); i = i+1)
			{
				if (not CompareNoCase(arguments.aCompToCheck[i].compUUID, arguments.compID))
					doesExist = true;
			}
			
		</cfscript>
		
		<cfreturn doesExist />

   </cffunction>
   
	<cffunction name="getActive" output="false" returntype="query">	
		<cfset useLakebaseForqGetActiveComps = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_rule")>
<cfif useLakebaseForqGetActiveComps>
	<cftry>
		<cfset qGetActiveComps = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_product_integrity_rule", {
				"deleted" = "eq.0",
				"order" = "rule_name.asc",
				"select" = "*"
			}), "*"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetActiveComps = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetActiveComps>
<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT 		Distributor_Product_Integrity_Rule.*
			FROM 		Distributor_Product_Integrity_Rule
			WHERE 		Deleted = 0
			ORDER BY 	Rule_Name
		</cfquery>
</cfif>

		<cfreturn qGetActiveComps />
		
   	</cffunction>
	
	<cffunction name="getComp" output="false" returntype="query">	
   
   		<cfargument name="compId" required="false" default=0 />
		
		<cfset useLakebaseForqGetComp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_rule")>
<cfif useLakebaseForqGetComp>
	<cftry>
		<cfset qGetComp = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_product_integrity_rule", {
				"distributor_product_integrity_rule_id" = "eq.#arguments.compId#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetComp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetComp>
<cfquery name="qGetComp" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Distributor_Product_Integrity_Rule
			WHERE 	Distributor_Product_Integrity_Rule_ID = #arguments.compId#	
		</cfquery>
</cfif>

		<cfreturn qGetComp />
		
   	</cffunction>
		
	<cffunction name="add" output="false" hint="Function used to add a new component.">
		<cfargument name="Distributor_Product_Integrity_Rule_ID" required="false" default="" />
		<cfargument name="Rule_Name" required="true" default="" />
		<cfargument name="Error_Msg" required="false" default="" />
		<cfargument name="Inclusive_Restriction" required="false" default="0" />
		<cfargument name="Distributor_List" required="false" default="" >
		<cfargument name="Product_List" required="false" default="" >
		
		<!------ Check if another component with same name exist ----->
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Distributor_Product_Integrity_Rule_ID AS External_ID
			FROM	Distributor_Product_Integrity_Rule
			WHERE	Deleted = 0
			AND Rule_Name = '#trim(arguments.Rule_Name)#'
		</cfquery>
				
		<cfset bProceedWithInsert = 1 />
		<cfset bCompNameExists = 0 />
		
		<cfif qGetActiveComps.RecordCount>
		
			<cfset bProceedWithInsert = 0 />
			
			<!------ if names are same do not have to insert ----->
			
			<cfset bCompNameExists = 1 />
			
			<!------ if there is any existing component which has same name but different id, notify  ----->
			<cfif application.returned_customer_setting.external_id_on EQ 1>
				<cfloop query="qGetActiveComps">
					<cfif External_ID NEQ arguments.Distributor_Product_Integrity_Rule_ID>	
						<cfset bCompNameExists = 2 />
						<cfbreak />
					</cfif>					
				</cfloop>
			</cfif>			
		</cfif>
			
		<cfif bProceedWithInsert EQ 1>
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO	Distributor_Product_Integrity_Rule
					(Rule_Name, Error_Msg, Inclusive_Restriction, Created_By)
				VALUES
					('#arguments.Rule_Name#', 
					'#arguments.Error_Msg#', 
					<cfqueryparam value="#arguments.Inclusive_Restriction#" cfsqltype="CF_SQL_INTEGER">,
					'#request.AccessStructure.User_ID#'
					)
				SELECT Distributor_Product_Integrity_Rule_ID = @@IDENTITY
				SET NOCOUNT OFF
			</cfquery>
			
			<cfloop list="#arguments.Distributor_List#" index="DistributorID">
				<cfset useLakebaseForInsertDistributors = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_distributors")>
<cfif useLakebaseForInsertDistributors>
	<cftry>
		<cfset application.oLakebase.insertRow("distributor_product_integrity_distributors", {
			"distributor_product_integrity_rule_id" = "#qGetActiveComps.Distributor_Product_Integrity_Rule_ID#",
			"distributor_id" = "#DistributorID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertDistributors = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertDistributors>
<cfquery name="InsertDistributors" datasource="#application.datasource#">
				INSERT INTO Distributor_Product_Integrity_Distributors
				(
					Distributor_Product_Integrity_Rule_ID,
					Distributor_ID
				)
				VALUES
				(
					#qGetActiveComps.Distributor_Product_Integrity_Rule_ID#,
					'#DistributorID#'
				)
				</cfquery>
</cfif>
			</cfloop>
			
			<cfloop list="#arguments.Product_List#" index="ProductID">
				<cfset useLakebaseForInsertProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_products")>
<cfif useLakebaseForInsertProducts>
	<cftry>
		<cfset application.oLakebase.insertRow("distributor_product_integrity_products", {
			"distributor_product_integrity_rule_id" = "#qGetActiveComps.Distributor_Product_Integrity_Rule_ID#",
			"product_id" = "#ProductID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertProducts>
<cfquery name="InsertProducts" datasource="#application.datasource#">
				INSERT INTO Distributor_Product_Integrity_Products
				(
					Distributor_Product_Integrity_Rule_ID,
					Product_ID
				)
				VALUES
				(
					#qGetActiveComps.Distributor_Product_Integrity_Rule_ID#,
					'#ProductID#'
				)
				</cfquery>
</cfif>
			</cfloop>
		</cfif>

		<cfreturn bCompNameExists />
		
   	</cffunction>
	
	<cffunction name="delete" output="false" hint="Function used to delete components.">
	
		<cfargument name="compIds" required="false" default="" />	
   
		<cfquery datasource="#application.datasource#">
			UPDATE 	Distributor_Product_Integrity_Rule
			SET		Deleted = 1,
					Modified_By = '#request.AccessStructure.User_ID#',
					Modified_Date = #now()#
			WHERE	Distributor_Product_Integrity_Rule_ID = #arguments.compIds#
		</cfquery>
		
		<cfquery name="DeleteProducts" datasource="#application.datasource#">
		DELETE FROM Distributor_Product_Integrity_Products
		WHERE Distributor_Product_Integrity_Rule_ID = #arguments.compIds#
		</cfquery>
		
		<cfquery name="DeleteDistributors" datasource="#application.datasource#">
		DELETE FROM Distributor_Product_Integrity_Distributors
		WHERE Distributor_Product_Integrity_Rule_ID = #arguments.compIds#
		</cfquery>
		
   	</cffunction>
	
	<cffunction name="update" output="false" hint="Function used to update components." returntype="numeric">
	
		<cfargument name="Distributor_Product_Integrity_Rule_ID" required="false" default="" />
		<cfargument name="Rule_Name" required="true" default="" />
		<cfargument name="Error_Msg" required="false" default="" />
		<cfargument name="Inclusive_Restriction" required="false" default="0" />
		<cfargument name="Distributor_List" required="false" default="" >
		<cfargument name="Product_List" required="false" default="" >
		
		<cfset bCompNameExists = 0 />
	 	
		<cftransaction>
		<!--- Delete prior distributors --->	
		<cfquery name="DeletePriorDistributors" datasource="#application.datasource#">
			DELETE FROM Distributor_Product_Integrity_Distributors
			WHERE Distributor_Product_Integrity_Rule_ID = '#arguments.Distributor_Product_Integrity_Rule_ID#'
		</cfquery>
				
		<!--- Delete prior products --->	
		<cfquery name="DeletePriorProducts" datasource="#application.datasource#">
			DELETE FROM Distributor_Product_Integrity_Products
			WHERE Distributor_Product_Integrity_Rule_ID = '#arguments.Distributor_Product_Integrity_Rule_ID#'
		</cfquery>
		
		<!--- Update rule --->
		<cfquery name="UpdateRule" datasource="#application.datasource#">
		UPDATE Distributor_Product_Integrity_Rule
		SET Rule_Name = '#arguments.Rule_Name#',
			Error_Msg = '#arguments.Error_Msg#',
			Inclusive_Restriction = '#arguments.Inclusive_Restriction#',
			Modified_Date = #now()#,
			Modified_By = '#request.AccessStructure.User_ID#'
		WHERE Distributor_Product_Integrity_Rule.Distributor_Product_Integrity_Rule_ID = 
		'#arguments.Distributor_Product_Integrity_Rule_ID#'
		</cfquery>
		
		<!--- Insert distributors --->
		<cfloop list="#arguments.Distributor_List#" index="DistributorID">a
			<cfquery name="InsertDistributors" datasource="#application.datasource#">
			INSERT INTO Distributor_Product_Integrity_Distributors
			(
				Distributor_Product_Integrity_Rule_ID,
				Distributor_ID
			)
			VALUES
			(
				#arguments.Distributor_Product_Integrity_Rule_ID#,
				'#DistributorID#'
			)
			</cfquery>
		</cfloop>
		
	<!--- Insert products --->
		<cfloop list="#arguments.Product_List#" index="ProductID">b
			<cfquery name="InsertProducts" datasource="#application.datasource#">
			INSERT INTO Distributor_Product_Integrity_Products
			(
				Distributor_Product_Integrity_Rule_ID,
				Product_ID
			)
			VALUES
			(
				#arguments.Distributor_Product_Integrity_Rule_ID#,
				'#ProductID#'
			)
			</cfquery>
		</cfloop>

		</cftransaction>
	  <cfreturn bCompNameExists />
   	</cffunction>
   

   
</cfcomponent>