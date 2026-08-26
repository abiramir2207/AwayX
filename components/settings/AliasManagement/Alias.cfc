<!--- BJF: This used the growth component addition as a template and retains some of the naming conventions --->

<cfcomponent hint="This class should be the core functionality to handle alias management" >
	<cffunction name="init" output="false">
		<cfreturn this />
	</cffunction>
	
   
   <!------ addProdAlias ----->
   	<cffunction name="addProdAlias" output="false" hint="Function used to add a new product alias.">
		<cfargument name="Product_Alias" required="true" default="" />
		<cfargument name="Product_List" required="false" default="" />
		<cfargument name="user_ID" required="false" default="0" />
		
		
		<cfset bCompNameExists = 0 />
		<cfset bProceedWithInsert = 1 />
		
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Alias_String
			FROM	Alias_Product
			WHERE	Alias_String = '#trim(arguments.Product_Alias)#'
			AND		deleted = 0
		</cfquery>
		<cfif qGetActiveComps.RecordCount GT 0>
			<cfset bProceedWithInsert = 0 />
			<cfset bCompNameExists = 1 />
		</cfif>
		
		<cfif bProceedWithInsert>
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO	Alias_Product
					(Alias_String, Product_ID, Created_By)
				VALUES
					('#trim(arguments.Product_Alias)#', 
					'#arguments.Product_List#',
					'#arguments.user_ID#')
			
				SET NOCOUNT OFF
			</cfquery>
		
		</cfif>
		
		<cfreturn bCompNameExists />
   	</cffunction>
	
	<!------ addDistAlias ----->
   	<cffunction name="addDistAlias" output="false" hint="Function used to add a new distributor alias.">
		<cfargument name="Distributor_Alias" required="true" default="" />
		<cfargument name="Distributor_List" required="false" default="" />
		<cfargument name="user_ID" required="false" default="0" />
		
		
		<cfset bCompNameExists = 0 />
		<cfset bProceedWithInsert = 1 />
		
		<cfquery name="qGetActiveComps" datasource="#application.datasource#">
			SELECT	Alias_String
			FROM	Alias_Distributor
			WHERE	Alias_String = '#trim(arguments.Distributor_Alias)#'
			AND		deleted = 0
		</cfquery>
		<cfif qGetActiveComps.RecordCount GT 0>
			<cfset bProceedWithInsert = 0 />
			<cfset bCompNameExists = 1 />
		</cfif>
		
		<cfif bProceedWithInsert>
			<cfquery name="qGetActiveComps" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO	Alias_Distributor
					(Alias_String, Distributor_ID, Created_By)
				VALUES
					('#trim(arguments.Distributor_Alias)#', 
					'#arguments.Distributor_List#',
					'#arguments.user_ID#')
				<!--- SELECT Alias_Distributor_ID = @@IDENTITY --->
				SET NOCOUNT OFF
			</cfquery>
		
		</cfif>
		
		<cfreturn bCompNameExists />
   	</cffunction>
	
	
	<!---Alias search --->
	<cffunction name="searchAlias" output="false" hint="Search for an alias">
	
		<cfargument name="Alias" required="false" default="" />
		<cfargument name="Name" required="false" default="" />
		<cfargument name="Number" required="false" default="" />
		<cfargument name="Created_By" required="false" default="" />
		<cfargument name="Alias_Type" required="true" default="1" /> <!--- 1 = dist, 2 = prod --->
		<cfargument name="Alias_ID" required="false" default="" />
		
		<!--- Distributor search --->
		<cfif Alias_Type IS 1>
		
			<cfquery name="GetAlias" datasource="#application.datasource#">
			SELECT 
				Alias_Distributor.Alias_Distributor_ID AS Alias_ID,
				Alias_Distributor.Alias_String, 
				_Users.Name_First, 
				_Users.Name_Last,
				_Users.User_Code,
				Alias_Distributor.Created_On,
				BSA_Foodservice_Customers.Name AS Name,
				BSA_Foodservice_Customers.Ship_To AS Number1,
				BSA_Foodservice_Customers.Shr_Ship_To AS Number2,
				1 AS Alias_Type, 
				Alias_Distributor.Distributor_ID AS Alias_Item_ID
			FROM Alias_Distributor
				INNER JOIN BSA_Foodservice_Customers
				ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Alias_Distributor.Distributor_ID
				AND BSA_Foodservice_Customers.Deleted = 0
			LEFT JOIN _Users
				ON _Users.User_ID = Alias_Distributor.Created_By
			WHERE Alias_Distributor.Deleted = 0
			<cfif len(trim(arguments.Alias)) GT 0>
				AND Alias_Distributor.Alias_String LIKE '%#arguments.Alias#%'
			</cfif>
			<cfif len(trim(arguments.Name)) GT 0>
				AND BSA_Foodservice_Customers.Name LIKE '%#arguments.Name#%'
			</cfif>
			<cfif len(trim(arguments.Number)) GT 0>
				AND 
					(
					BSA_Foodservice_Customers.Ship_To LIKE '%#arguments.Number#%'
						OR
					BSA_Foodservice_Customers.Shr_Ship_To LIKE '%#arguments.Number#%'
					)
			</cfif>
			<cfif len(trim(arguments.Created_By)) GT 0>
				AND Alias_Distributor.Created_By LIKE '%#arguments.Created_By#%'
			</cfif>
			<cfif len(trim(arguments.Alias_ID)) GT 0>
				AND Alias_Distributor.Alias_Distributor_ID LIKE '%#arguments.Alias_ID#%'
			</cfif>
			ORDER BY BSA_Foodservice_Customers.Name, Alias_Distributor.Alias_String
			</cfquery>
		
		<!--- //end Distributor search --->
		<cfelse>
		<!--- Product search --->
			<cfquery name="GetAlias" datasource="#application.datasource#">
			SELECT 
				Alias_Product.Alias_Product_ID AS Alias_ID,
				Alias_Product.Alias_String, 
				_Users.Name_First, 
				_Users.Name_Last,
				_Users.User_Code,
				Alias_Product.Created_On,
				BSA_Foodservice_Items_Master.Description AS Name,
				BSA_Foodservice_Items_Master.Item AS Number1,
				BSA_Foodservice_Items_Master.UPC AS Number2, 
				2 AS Alias_Type, 
				Alias_Product.Product_ID AS Alias_Item_ID
			FROM Alias_Product
				INNER JOIN BSA_Foodservice_Items_Master
				ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Alias_Product.Product_ID
				AND BSA_Foodservice_Items_Master.Deleted = 0
				LEFT JOIN _Users
				ON _Users.User_ID = Alias_Product.Created_By
			WHERE Alias_Product.Deleted = 0
			<cfif len(trim(arguments.Alias)) GT 0>
				AND Alias_Product.Alias_String LIKE '%#arguments.Alias#%'
			</cfif>
			<cfif len(trim(arguments.Name)) GT 0>
				AND BSA_Foodservice_Items_Master.Description LIKE '%#arguments.Name#%'
			</cfif>
			<cfif len(trim(arguments.Number)) GT 0>
				AND 
					(
					BSA_Foodservice_Items_Master.Item LIKE '%#arguments.Number#%'
						OR
					BSA_Foodservice_Items_Master.UPC LIKE '%#arguments.Number#%'
					)
			</cfif>
			<cfif len(trim(arguments.Created_By)) GT 0>
				AND Alias_Product.Created_By LIKE '%#arguments.Created_By#%'
			</cfif>
			<cfif len(trim(arguments.Alias_ID)) GT 0>
				AND Alias_Product.Alias_Product_ID LIKE '%#arguments.Alias_ID#%'
			</cfif>
			ORDER BY BSA_Foodservice_Items_Master.Description, Alias_Product.Alias_String
			</cfquery>
		
		<!---Alias type --->		
		</cfif>
		<!--- //end Product search --->
				
		<cfreturn GetAlias />
  	</cffunction>
	

	
	<!--- delete/undelete --->
	<cffunction name="deleteProductAlias" output="false" hint="Function used to delete components.">
		<cfargument name="compIds" required="false" default="" />	
		<cfquery datasource="#application.datasource#">
			UPDATE 	Alias_Product
			SET		Deleted = 1
			WHERE	Alias_Product_Id IN(#arguments.compIds#)
		</cfquery>
   	</cffunction>
	<cffunction name="deleteDistributorAlias" output="false" hint="Function used to delete components.">
		<cfargument name="compIds" required="false" default="" />	
		<cfquery datasource="#application.datasource#">
			UPDATE 	Alias_Distributor
			SET		Deleted = 1
			WHERE	Alias_Distributor_Id IN(#arguments.compIds#)
		</cfquery>
   	</cffunction>

	
	<!---update --->
	<cffunction name="update" output="false" hint="Function used to update components." >
		<cfargument name="Alias_Type" required="true"  />
		<cfargument name="Alias" required="true" />
		<cfargument name="Item_ID" required="true" />
		<cfargument name="User_ID" required="true" />
		<cfargument name="Alias_ID" required="true" />
	
		<cfif arguments.Alias_Type IS 1>
		<!---Distributor --->
		
			<cfset useLakebaseForUpdateAlias = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("alias_distributor")>
<cfif useLakebaseForUpdateAlias>
	<cftry>
		<cfset application.oLakebase.updateRows("alias_distributor",
			{
				"alias_distributor_id" = "eq.#arguments.Alias_ID#"
			},
			{
				"alias_string" = "#arguments.Alias#",
				"distributor_id" = "#arguments.Item_ID#",
				"created_by" = "#arguments.User_ID#",
				"created_on" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAlias = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAlias>
<cfquery name="UpdateAlias" datasource="#application.datasource#">
			UPDATE Alias_Distributor
				SET Alias_String = '#arguments.Alias#',
					Distributor_ID = '#arguments.Item_ID#',
					Created_By = '#arguments.User_ID#',
					Created_On = #now()#
				WHERE Alias_Distributor_ID = '#arguments.Alias_ID#'
			</cfquery>
</cfif>
			
		<cfelse>
		
			<cfquery name="UpdateAlias" datasource="#application.datasource#">
			UPDATE Alias_Product
				SET Alias_String = '#arguments.Alias#',
					Product_ID = '#arguments.Item_ID#',
					Created_By = '#arguments.User_ID#',
					Created_On = #now()#
				WHERE Alias_Product_ID = '#arguments.Alias_ID#'
			</cfquery>
		</cfif>
		
   	</cffunction>

	
	
</cfcomponent>