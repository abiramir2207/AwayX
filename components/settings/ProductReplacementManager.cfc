<cfcomponent displayname="ProductReplacementManager" hint="Product Replacement Manager" extends="components.Base">

	<cffunction name="init" returntype="components.settings.ProductReplacementManager" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="saveProductReplacement" output="false" returntype="array">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="notes" type="string" required="true" />
		<cfargument name="productList" type="string" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "No action" />
		<cfset returnValue[2] = arguments.id />		
		
		<!---- make sure there are 2 products selected ----->
		<cfif ListLen(productList) NEQ 2>
			<cfset returnValue[1] = "You have to select 2 products" />
			<cfreturn returnValue />			
		</cfif>

		<!---- make sure any of the product selected is not already selected in another combination ----->
		<cfset qGetOtherProductReplacementsWithTheseProducts = getProductReplacement(
				bActive = -1,
				excludeId = arguments.id,
				originalProductIdList = productList) />
		<cfif qGetOtherProductReplacementsWithTheseProducts.recordCount>
			<cfset returnValue[1] = "The products you have selected is already part of another replacement '#qGetOtherProductReplacementsWithTheseProducts.Item_Replacement_Header_Notes#'" />
			<cfreturn returnValue />	
		</cfif>
		
		<cfset product1 = ListGetAt(productList, 1)>
		<cfset product2 = ListGetAt(productList, 2)>

		<cftransaction action="begin">
			
		<cftry>
		
		<cfquery name="qInsertUpdateProductReplacement" datasource="#application.datasource#">
			
			SET NOCOUNT ON
			
			DECLARE @Item_Replacement_Header_ID int
			
			<cfif arguments.id><!----- update ------>
				SET @Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
				
				UPDATE	Item_Replacement_Header
				SET		Item_Replacement_Header_Notes = <cfqueryparam value="#arguments.notes#" cfsqltype="CF_SQL_VARCHAR">,
						Updated_Date = GetDate(),
						Updated_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
				WHERE	Item_Replacement_Header_ID = @Item_Replacement_Header_ID
				
				DELETE FROM Item_Replacement
				WHERE	Item_Replacement_Header_ID = @Item_Replacement_Header_ID
			<cfelse>
				INSERT INTO Item_Replacement_Header (Item_Replacement_Header_Notes, Created_By)
				VALUES (
					<cfqueryparam value="#arguments.notes#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">)
				SET @Item_Replacement_Header_ID = @@IDENTITY
			</cfif>
			
			INSERT INTO Item_Replacement(
				Item_Replacement_Header_ID, 
				Original_Item_ID, Original_Item_Number,
				Replacement_Item_ID, Replacement_Item_Number					
			)
			VALUES (
				@Item_Replacement_Header_ID,
				<cfqueryparam value="#product1#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#product2#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">
			)
			
			INSERT INTO Item_Replacement(
				Item_Replacement_Header_ID, 
				Original_Item_ID, Original_Item_Number,
				Replacement_Item_ID, Replacement_Item_Number					
			)
			VALUES (
				@Item_Replacement_Header_ID,					
				<cfqueryparam value="#product2#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#product1#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="" cfsqltype="CF_SQL_VARCHAR">
			)
			
			INSERT INTO Item_Replacement_History(
					Item_Replacement_ID,
					Item_Replacement_Header_ID,
					Replacement_Item_ID,
					Original_Item_ID,
					Original_Item_Number,
					Replacement_Item_Number
			)
			SELECT	
					Item_Replacement_ID,
					Item_Replacement_Header_ID,
					Replacement_Item_ID,
					Original_Item_ID,
					Original_Item_Number,
					Replacement_Item_Number
			FROM	Item_Replacement
			WHERE	Item_Replacement_Header_ID = @Item_Replacement_Header_ID
			
			
			SELECT Item_Replacement_Header_ID = @Item_Replacement_Header_ID
			SET NOCOUNT OFF
		</cfquery>
		
			<cftransaction action="commit" />

			<cfcatch>
				<cftransaction action="rollback" />
				<cfrethrow />
			</cfcatch>
		
		</cftry>
		
		</cftransaction>
		
		
		<cfset returnValue[1] = "" />
		<cfset returnValue[2] = qInsertUpdateProductReplacement.Item_Replacement_Header_ID />			
		
		<cfreturn returnValue />
	
	</cffunction>

	<cffunction name="deactivateProductReplacement" output="false" returntype="array">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "No action" />
		<cfset returnValue[2] = arguments.id />		
		
		<cfquery name="qDeactivateProductReplacement" datasource="#application.datasource#">
			UPDATE	Item_Replacement_Header
			SET		Active = 0,
					DeActivated_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
					DeActivated_Date = GetDate()
			WHERE	Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
			AND		Active = 1
			
			UPDATE	Item_Replacement
			SET		Deleted = 1
			WHERE	Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfset returnValue[1] = "" />
		
		<cfreturn returnValue />
	
	</cffunction>
	
	<cffunction name="activateProductReplacement" output="false" returntype="array">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "No action" />
		<cfset returnValue[2] = arguments.id />		
		
		<!--- get the product list for this header --->
		<cfquery name="qGetProductID" datasource="#application.datasource#">
			SELECT	Original_Item_ID
			FROM	Item_Replacement
			WHERE	Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">			
		</cfquery>
		<cfset productList = ValueList(qGetProductID.Original_Item_ID) />

		<!---- make sure there are 2 products selected ----->
		<cfif ListLen(productList) NEQ 2>
			<cfset returnValue[1] = "You need to have 2 products selected" />
			<cfreturn returnValue />			
		</cfif>
		
		<cfif productList neq "">
			<!---- make sure any of the product selected is not already selected in another combination ----->
			<cfset qGetOtherProductReplacementsWithTheseProducts = getProductReplacement(
					excludeId = arguments.id,
					originalProductIdList = productList) />
			<cfif qGetOtherProductReplacementsWithTheseProducts.recordCount>
				<cfset returnValue[1] = "The products part of this record is already part of another replacement '#qGetOtherProductReplacementsWithTheseProducts.Item_Replacement_Header_Notes#'" />
				<cfreturn returnValue />	
			</cfif>
		</cfif>
		
		<cfquery name="qActivateProductReplacement" datasource="#application.datasource#">
			UPDATE	Item_Replacement_Header
			SET		Active = 1,
					DeActivated_By = NULL,
					DeActivated_Date = NULL
			WHERE	Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
			AND		Active = 0
			
			UPDATE	Item_Replacement
			SET		Deleted = 0
			WHERE	Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">			
			AND		Deleted = 1
		</cfquery>
		
		<cfset returnValue[1] = "" />
		
		<cfreturn returnValue />
	
	</cffunction>
	
	<cffunction name="deleteProductReplacement" output="false" returntype="array">
	
		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfset var returnValue = ArrayNew(1) />
		<cfset returnValue[1] = "No action" />
		<cfset returnValue[2] = arguments.id />		
		
		<cftransaction action="begin">
		
			<cftry>
			
			<cfquery name="qDeactivateProductReplacement" datasource="#application.datasource#">
				UPDATE	Item_Replacement_Header
				SET		Deleted = 1,
						Deleted_By = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">,
						Deleted_Date = GetDate()
				WHERE	Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
				AND		Deleted = 0
				
				DELETE FROM Item_Replacement
				WHERE	Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
			</cfquery>
		
			<cftransaction action="commit" />
				
			<cfcatch>
				<cftransaction action="rollback" />
				<cfrethrow />
			</cfcatch>
			
			</cftry>
		
		</cftransaction>
		
		<cfset returnValue[1] = "" />
		
		<cfreturn returnValue />
	
	</cffunction>	

	<cffunction name="getProductReplacement" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="bActive" type="numeric" required="false" default="1" />
		<cfargument name="originalProductIdList" type="string" required="false" default="" />
		<cfargument name="excludeId" type="numeric" required="false" default="0" />
				
		<cfquery name="qGetItemReplacement" datasource="#Application.Datasource#">
			SELECT	Item_Replacement_Header.*, 					
					Created_By_User.Name_First + ' ' + Created_By_User.Name_Last as Created_By_User_Name,
					Updated_By_User.Name_First + ' ' + Updated_By_User.Name_Last as Updated_By_User_Name,
					Deactivated_By_User.Name_First + ' ' + Deactivated_By_User.Name_Last as Deactivated_By_User_Name,
					Deleted_By_User.Name_First + ' ' + Deleted_By_User.Name_Last as Deleted_By_User_Name,
					BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID, BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description
			FROM	Item_Replacement_Header
			LEFT JOIN Item_Replacement
			ON		Item_Replacement.Item_Replacement_Header_ID = Item_Replacement_Header.Item_Replacement_Header_ID
			--AND		Item_Replacement.Deleted = 0
			LEFT JOIN BSA_Foodservice_Items_Master
			ON		BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Item_Replacement.Original_Item_ID
			LEFT JOIN _Users as Created_By_User
			ON		Created_By_User.User_ID = Item_Replacement_Header.Created_By
			LEFT JOIN _Users as Updated_By_User
			ON		Updated_By_User.User_ID = Item_Replacement_Header.Updated_By
			LEFT JOIN _Users as Deactivated_By_User
			ON		Deactivated_By_User.User_ID = Item_Replacement_Header.DeActivated_By
			LEFT JOIN _Users as Deleted_By_User
			ON		Deleted_By_User.User_ID = Item_Replacement_Header.Deleted_By
			WHERE	Item_Replacement_Header.Deleted = 0
			<cfif arguments.bActive neq -1>
			AND		Item_Replacement_Header.Active = <cfqueryparam value="#arguments.bActive#" cfsqltype="cf_sql_bit">
			</cfif>
			<cfif arguments.id neq 0>
			AND		Item_Replacement_Header.Item_Replacement_Header_ID = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif arguments.excludeId neq 0>
			AND		Item_Replacement_Header.Item_Replacement_Header_ID <> <cfqueryparam value="#arguments.excludeId#" cfsqltype="cf_sql_integer">
			</cfif>
			<cfif arguments.originalProductIdList neq "">
			AND		Item_Replacement.Original_Item_ID IN (<cfqueryparam value="#arguments.originalProductIdList#" cfsqltype="cf_sql_varchar" list="true">)
			</cfif>
			ORDER BY Item_Replacement_Header.Item_Replacement_Header_Notes
		</cfquery>
			
		<cfreturn qGetItemReplacement />
		
	</cffunction>	
</cfcomponent>
