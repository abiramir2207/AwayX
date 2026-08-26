<cfcomponent hint="Manages Activity" extends ="cm.com.base">


	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false">
	
		<cfargument name="id" required="false" default=0 type="numeric" />
		
		<cfset this.activity = CreateObject("component","cm.activity.com.Activity").init() />
		
		<cfif arguments.id>
			
			<cfquery name="qGetActivity" datasource="#application.datasource#">
				SELECT 	CM_Activity_ID,
						Activity_Name,
						Activity_Notes,
						Activity_Start_Date,
						Activity_End_Date,
						CM_Activity_Objective_ID,
						CM_Activity_Type_ID,
						CM_Activity_Result_ID,
						Created_By_User_ID,
						Updated_By_User_ID
				FROM	CM_Activity
				WHERE 	Deleted = 0
				AND		CM_Activity_ID = <cfqueryPARAM value = "#arguments.id#" CFSQLType = "CF_SQL_INTEGER">
				AND		deleted = 0
			</cfquery>
			
			<!---query products--->
			<cfquery name="qGetProductId" datasource="#application.datasource#">
				SELECT	Product_ID
				FROM	CM_Activity_Product						
				WHERE	CM_Activity_Product.CM_Activity_ID = #arguments.id#
				AND		deleted = 0
			</cfquery>
			
			<!---query distributors--->
			<cfset useLakebaseForqGetDistributorId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cm_activity_customer")>
<cfif useLakebaseForqGetDistributorId>
	<cftry>
		<cfset qGetDistributorId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cm_activity_customer", {
				"cm_activity_id" = "eq.#arguments.id#",
				"cm_customer_type_id" = "eq.1",
				"deleted" = "eq.0",
				"select" = "distributor_id"
			}), "distributor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistributorId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistributorId>
<cfquery name="qGetDistributorId" datasource="#application.datasource#">
				SELECT	Distributor_ID
				FROM	CM_Activity_Customer						
				WHERE	CM_Activity_Customer.CM_Activity_ID = #arguments.id#
				AND		CM_Customer_Type_ID = 1
				AND		deleted = 0
			</cfquery>
</cfif>
			
			<!---query operators--->
			<cfset useLakebaseForqGetOperatorId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cm_activity_customer")>
<cfif useLakebaseForqGetOperatorId>
	<cftry>
		<cfset qGetOperatorId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cm_activity_customer", {
				"cm_activity_id" = "eq.#arguments.id#",
				"cm_customer_type_id" = "eq.2",
				"deleted" = "eq.0",
				"select" = "operator_id"
			}), "operator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetOperatorId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetOperatorId>
<cfquery name="qGetOperatorId" datasource="#application.datasource#">
				SELECT	Operator_ID
				FROM	CM_Activity_Customer						
				WHERE	CM_Activity_Customer.CM_Activity_ID = #arguments.id#
				AND		CM_Customer_Type_ID = 2
				AND		deleted = 0
			</cfquery>
</cfif>
			
			<cfloop query="qGetActivity">
				
				<cfset this.activity.setId(CM_Activity_ID) />
				<cfset this.activity.setName(Activity_Name) />
				<cfset this.activity.setNotes(Activity_Notes) />
				<cfset this.activity.setStartDate(Activity_Start_Date) />
				<cfset this.activity.setEndDate(Activity_End_Date) />
				<cfset this.activity.setObjectiveId(CM_Activity_Objective_ID) />
				<cfset this.activity.setTypeId(CM_Activity_Type_ID) />
				<cfset this.activity.setResultId(CM_Activity_Result_ID) />
				<cfset this.activity.setCreatedUserName(Created_By_User_ID) />
				<cfset this.activity.setUpdatedUserName(Updated_By_User_ID) />

				
				
				<!----- set products query ----->
				<cfset this.activity.setProductList(ValueList(qGetProductId.Product_ID)) />
				<cfset this.activity.setQProduct(this.getProducts()) />
				
				<!----- set distributor query ----->
				<cfset this.activity.setDistributorList(ValueList(qGetDistributorId.Distributor_ID)) />
				<cfset this.activity.setQDistributor(this.getDistributors()) />
				
				<!----- set distributor query ----->
				<cfset this.activity.setOperatorList(ValueList(qGetOperatorId.Operator_ID)) />
				<cfset this.activity.setQOperator(this.getOperators()) />
				
			</cfloop>
			
		</cfif>
		
		<cfreturn this.activity />
		
	</cffunction>
	
	<cffunction name="getProducts" output="false" returntype="query">
		
			<cfquery name="qGetProducts" datasource="#application.datasource#">
				SELECT	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID AS Product_ID,
						UPC,
						Item,
						Description
				FROM	BSA_Foodservice_Items_Master						
				WHERE
						<cfset productList = this.activity.getProductList()>
						<cfif Len(productList)>
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID IN
						(#ListQualify(productList, "'")#)
						<cfelse>
						1=2
						</cfif>
						
			</cfquery>
			
			<cfreturn qGetProducts />
			
	</cffunction>
	
	
	<cffunction name="getDistributors" output="false" returntype="query">
		
		<cfquery name="qGetDistributors" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Customers_ID,
					Name
			FROM 	BSA_Foodservice_Customers							
			WHERE
					<cfset disList = this.activity.getDistributorList()>
					<cfif Len(disList)>
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN
					(#ListQualify(disList, "'")#)
					<cfelse>
					1=2
					</cfif>
			AND		deleted = 0
						
		</cfquery>
			
		<cfreturn qGetDistributors />
			
	</cffunction>
	
	<cffunction name="getOperators" output="false" returntype="query">
		
		<cfquery name="qGetOperators" datasource="#application.datasource#">
			SELECT 	BSA_Operator_ID,
					Operator_Name
			FROM 	BSA_Operator							
			WHERE
					<cfset opList = this.activity.getOperatorList()>
					<cfif Len(opList)>
					BSA_Operator.BSA_Operator_ID IN
					(#ListQualify(opList, "'")#)
					<cfelse>
					1=2
					</cfif>
			AND		deleted = 0
						
		</cfquery>
			
		<cfreturn qGetOperators />
			
	</cffunction>
	
	<!------ 
	<cffunction name="getAll" output="false" returntype="query">
					
		<cfquery name="qGetAllActivity" datasource="#application.datasource#">
			SELECT 	CM_Activity.CM_Activity_ID, CM_Activity.Activity_Name, CM_Activity.Activity_Notes
			FROM	CM_Activity
			WHERE 	Deleted = 0
		</cfquery>
			
		<cfreturn qGetAllActivity />
		
	</cffunction>
	 ----->
	
	<cffunction name="getByFilter" output="false" returntype="query">
		<cfargument name="search" type="struct" required="true" />
		<cfset this.search = arguments.search>
		<cfquery name="qGetAllByFilter" datasource="#application.datasource#">
			SELECT 	CM_Activity.CM_Activity_ID, CM_Activity.Activity_Name, CM_Activity.Activity_Notes,
					CM_Activity.Activity_Start_Date, CM_Activity.Activity_End_Date,
					CM_Activity_Type.Activity_Type_Name,
					CM_Activity_Objective.Activity_Objective_Name,
					CM_Activity_Result.Activity_Result_Name
			FROM	CM_Activity
					LEFT JOIN CM_Activity_Type
					ON
					CM_Activity.CM_Activity_Type_ID = CM_Activity_Type.CM_Activity_Type_ID
					AND
					CM_Activity_Type.Deleted = 0
					LEFT JOIN CM_Activity_Objective
					ON
					CM_Activity_Objective.CM_Activity_Objective_ID = CM_Activity.CM_Activity_Objective_ID
					AND
					CM_Activity_Objective.Deleted = 0
					LEFT JOIN CM_Activity_Result
					ON
					CM_Activity_Result.CM_Activity_Result_ID = CM_Activity.CM_Activity_Result_ID
					AND
					CM_Activity_Result.Deleted = 0
					<cfif Super.variableExist("this.search.typeId", "")>
						INNER JOIN CM_Activity_Customer 
						ON
						CM_Activity_Customer.CM_Activity_ID = CM_Activity.CM_Activity_ID
						AND
						CM_Activity_Customer.CM_Customer_Type_ID = #this.search.typeId#
						<cfif this.search.typeId eq 1>
							AND	CM_Activity_Customer.Distributor_ID = '#this.search.id#'
						<cfelseif this.search.typeId eq 2>
							AND	CM_Activity_Customer.Operator_ID = #this.search.id#
						</cfif>
						AND 	CM_Activity_Customer.deleted = 0
					</cfif>
			WHERE 	CM_Activity.Deleted = 0
					<cfif Super.variableExist("this.search.Activity_Name", "")>
					AND CM_Activity.Activity_Name LIKE <cfqueryPARAM value = "%#this.search.Activity_Name#%" CFSQLType = "CF_SQL_VARCHAR">
					</cfif>
					<cfif Super.variableExist("this.search.Activity_Desc", "")>
					AND CM_Activity.Activity_Desc 	LIKE 	<cfqueryPARAM value = "%#this.search.Activity_Desc#%" CFSQLType = "CF_SQL_VARCHAR">
					</cfif>
					<cfif Super.variableExist("this.search.Activity_Start_Date", "")>
						<cfif isDate(this.search.Activity_Start_Date)>
						<!------ 
						AND DateDiff(d, CM_Activity.Activity_Start_Date, #CreateOdbcDate(this.search.Activity_Start_Date)#) >= 0
						AND DateDiff(d, #CreateOdbcDate(this.search.Activity_Start_Date)#, CM_Activity.Activity_End_Date) >= 0
						 ----->
						AND DateDiff(d, CM_Activity.Activity_Start_Date, <cfqueryPARAM value = "#this.search.Activity_Start_Date#" CFSQLType = "CF_SQL_DATE">) >= 0
						AND DateDiff(d, <cfqueryPARAM value = "#this.search.Activity_Start_Date#" CFSQLType = "CF_SQL_DATE">, CM_Activity.Activity_End_Date) >= 0
						
						</cfif>
					</cfif>
					<cfif Super.variableExist("this.search.Activity_End_Date", "")>
						<cfif isDate(this.search.Activity_End_Date)>
						AND DateDiff(d, CM_Activity.Activity_Start_Date, <cfqueryPARAM value = "#this.search.Activity_End_Date#" CFSQLType = "CF_SQL_DATE">) >= 0
						AND DateDiff(d, <cfqueryPARAM value = "#this.search.Activity_End_Date#" CFSQLType = "CF_SQL_DATE">, CM_Activity.Activity_End_Date) >= 0
						</cfif>
					</cfif>
					<cfif Super.variableExist("this.search.CM_Activity_Objective_ID", "")>
					AND CM_Activity.CM_Activity_Objective_ID 	= 	<cfqueryPARAM value = "#this.search.CM_Activity_Objective_ID#" CFSQLType = "CF_SQL_INTEGER">
					</cfif>
					<cfif Super.variableExist("this.search.CM_Activity_Type_ID", "")>
					AND CM_Activity.CM_Activity_Type_ID 	= 	<cfqueryPARAM value = "#this.search.CM_Activity_Type_ID#" CFSQLType = "CF_SQL_INTEGER">
					</cfif>
					<cfif Super.variableExist("this.search.CM_Activity_Result_ID", "")>
					AND CM_Activity.CM_Activity_Result_ID 	= 	<cfqueryPARAM value = "#this.search.CM_Activity_Result_ID#" CFSQLType = "CF_SQL_INTEGER">
					</cfif>
					<cfif Super.variableExist("this.search.User_ID", "")>
					AND CM_Activity.Activity_Owner_ID 	= 	<cfqueryPARAM value = "#this.search.User_ID#" CFSQLType = "CF_SQL_VARCHAR">
					</cfif>
		</cfquery>
			
		<cfreturn qGetAllByFilter />
		
	</cffunction>
	
	<cffunction name="save" output="true">	
	
		<cftransaction action="begin">
			
			<cfif this.activity.getId()>
				
				<cfquery name="qUpdateActivity" datasource="#application.datasource#">
					UPDATE 	CM_Activity					
					SET		Activity_Name = <cfqueryPARAM value = "#this.activity.getName()#" CFSQLType = "CF_SQL_VARCHAR">, 
							Activity_Notes = <cfqueryPARAM value = "#this.activity.getNotes()#" CFSQLType = "CF_SQL_VARCHAR">,
							Activity_Start_Date = <cfqueryPARAM value = "#this.activity.getStartDate()#" CFSQLType = "CF_SQL_DATE">,
							Activity_End_Date = <cfqueryPARAM value = "#this.activity.getEndDate()#" CFSQLType = "CF_SQL_DATE">,
							CM_Activity_Objective_ID = <cfqueryPARAM value = "#this.activity.getObjectiveId()#" CFSQLType = "CF_SQL_INTEGER">,
							CM_Activity_Type_ID = <cfqueryPARAM value = "#this.activity.getTypeId()#" CFSQLType = "CF_SQL_INTEGER">,
							CM_Activity_Result_ID = <cfqueryPARAM value = "#this.activity.getResultId()#" CFSQLType = "CF_SQL_INTEGER">,
							Updated_By_User_ID = <cfqueryPARAM value = "#this.activity.getUpdatedUserId()#" CFSQLType = "CF_SQL_VARCHAR">
					WHERE	CM_Activity_ID = <cfqueryPARAM value = "#this.activity.getId()#" CFSQLType = "CF_SQL_INTEGER">
					AND		deleted = 0		
				</cfquery>
				
			<cfelse>
			
				<cfquery name="qAddActivity" datasource="#application.datasource#">
					
					SET NOCOUNT ON
					
					INSERT INTO CM_Activity
						(Activity_Name, Activity_Notes, Activity_Start_Date, Activity_End_Date, 
							CM_Activity_Objective_ID, CM_Activity_Type_ID, CM_Activity_Result_ID, Activity_Owner_ID, Created_By_User_ID, Updated_By_User_ID)
					VALUES
						(<cfqueryPARAM value = "#this.activity.getName()#" CFSQLType = "CF_SQL_VARCHAR">,
						 <cfqueryPARAM value = "#this.activity.getNotes()#" CFSQLType = "CF_SQL_VARCHAR">,
						 <cfqueryPARAM value = "#this.activity.getStartDate()#" CFSQLType = "CF_SQL_DATE">,
						 <cfqueryPARAM value = "#this.activity.getEndDate()#" CFSQLType = "CF_SQL_DATE">, 
						 <cfqueryPARAM value = "#this.activity.getObjectiveId()#" CFSQLType = "CF_SQL_INTEGER">,
						 <cfqueryPARAM value = "#this.activity.getTypeId()#" CFSQLType = "CF_SQL_INTEGER">,
						 <cfqueryPARAM value = "#this.activity.getResultId()#" CFSQLType = "CF_SQL_INTEGER">,
						 <cfqueryPARAM value = "#this.activity.getOwnerId()#" CFSQLType = "CF_SQL_VARCHAR">,
						 <cfqueryPARAM value = "#this.activity.getCreatedUserId()#" CFSQLType = "CF_SQL_VARCHAR">,
						 <cfqueryPARAM value = "#this.activity.getUpdatedUserId()#" CFSQLType = "CF_SQL_VARCHAR">)
					
					SELECT CM_Activity_ID = @@IDENTITY
					
					SET NOCOUNT OFF
				</cfquery>
				
				<cfset this.activity.setId(qAddActivity.CM_Activity_ID)>
				
			</cfif>
			
			<!---delete products--->
			<cfquery name="qDeleteProducts" datasource="#application.datasource#">
				
				UPDATE 	CM_Activity_Product
				SET		DELETED = 1
				WHERE	CM_Activity_ID = #this.activity.getId()#
						
			</cfquery>
				
			<!---loop over any products and update for each--->
			<cfloop index="indx" list="#this.activity.getProductList()#">
				
				<!---insert products--->
				<cfquery name="qInsertProducts" datasource="#application.datasource#">
					
					INSERT INTO CM_Activity_Product
						(Product_ID, CM_Activity_ID)
					VALUES
						('#indx#', #this.activity.getId()#)
					
				</cfquery>
				
			</cfloop>
			
			<!---delete distributors--->
			<cfquery name="qDeleteDistributors" datasource="#application.datasource#">
				
				UPDATE 	CM_Activity_Customer
				SET		DELETED = 1
				WHERE	CM_Activity_ID = #this.activity.getId()#
				AND		CM_Customer_Type_ID = 1
						
			</cfquery>
				
			<!---loop over any distributors and update for each--->
			<cfloop index="indx" list="#this.activity.getDistributorList()#">
				
				<!---insert distributors --->
				<cfquery name="qInsertDistributors" datasource="#application.datasource#">
				
					INSERT INTO CM_Activity_Customer
						(Distributor_ID, CM_Activity_ID, CM_Customer_Type_ID)
					VALUES
						('#indx#', #this.activity.getId()#, 1)
						
				</cfquery>
				
			</cfloop>
			
			<!---delete operators --->
			<cfquery name="qDeleteOperators" datasource="#application.datasource#">
				
				UPDATE 	CM_Activity_Customer
				SET		DELETED = 1
				WHERE	CM_Activity_ID = #this.activity.getId()#
				AND		CM_Customer_Type_ID = 2
						
			</cfquery>
				
			<!---loop over any operators and update for each--->
			<cfloop index="indx" list="#this.activity.getOperatorList()#">
				
				<!---insert distributors--->
				<cfquery name="qInsertOperators" datasource="#application.datasource#">
				
					INSERT INTO CM_Activity_Customer
						(Operator_ID, CM_Activity_ID, CM_Customer_Type_ID)
					VALUES
						('#indx#', #this.activity.getId()#, 2)
						
				</cfquery>
				
			</cfloop>

		</cftransaction>
					
	</cffunction>
	

</cfcomponent>