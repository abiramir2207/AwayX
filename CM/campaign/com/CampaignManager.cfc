<cfcomponent hint="Manages Campaign" extends="cm.com.Base">


	<cffunction name="init" output="false">
	
		<cfset custManager = CreateObject("component","cm.customer.com.CustomerManager").init() />
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="true">
	
		<cfargument name="id" required="false" default=0 type="numeric" />
		
		<cfset this.campaign = CreateObject("component","cm.campaign.com.Campaign").init() />
		
		<cfif arguments.id>
			
			<cfquery name="qGetCampaign" datasource="#application.datasource#">
				SELECT 	CM_Campaign_ID,
						Campaign_Name,
						Campaign_Description,
						Campaign_Start_Date,
						Campaign_End_Date,
						Created_By_User_ID,
						Updated_By_User_ID
				FROM	CM_Campaign
				WHERE 	Deleted = 0
				AND		CM_Campaign_ID = #arguments.id#
				AND		deleted = 0
			</cfquery>
			
			<!--- query customers --->
			<cfquery name="qGetCustomerId" datasource="#application.datasource#">
				SELECT	Distributor_ID, Operator_ID, Family_ID, Buying_Group_ID, Operator_Type
				FROM	CM_Campaign_Customer
						INNER JOIN 	CM_Customer
						ON
						CM_Campaign_Customer.CM_Customer_ID = CM_Customer.CM_Customer_ID
						AND
						CM_Customer.Deleted = 0
				WHERE	CM_Campaign_Customer.CM_Campaign_ID = #arguments.id#
				AND		CM_Campaign_Customer.Deleted = 0
			</cfquery>
			
			<cfloop query="qGetCampaign">
				
				<cfset this.campaign.setId(CM_Campaign_ID) />
				<cfset this.campaign.setName(Campaign_Name) />
				<cfset this.campaign.setDesc(Campaign_Description) />
				<cfset this.campaign.setStartDate(Campaign_Start_Date) />
				<cfset this.campaign.setEndDate(Campaign_End_Date) />
				<cfset this.campaign.setCreatedUserName(Created_By_User_ID) />
				<cfset this.campaign.setUpdatedUserName(Updated_By_User_ID) />

				<!----- set distributor query ----->
				<cfset this.campaign.setDistributorList(ValueList(qGetCustomerId.Distributor_ID)) />
				<cfset this.campaign.setQDistributor(this.getDistributors()) />
				
				<cfset this.campaign.setOperatorList(ValueList(qGetCustomerId.Operator_ID)) />
				<cfset this.campaign.setQOperator(this.getOperators()) />
				
				<cfset this.campaign.setFamilyList(ValueList(qGetCustomerId.Family_ID)) />
				<cfset this.campaign.setBuyingGroupList(ValueList(qGetCustomerId.Buying_Group_ID)) />
				<cfset this.campaign.setOperatorTypeList(ValueList(qGetCustomerId.Operator_Type)) />
				
			</cfloop>
			
		</cfif>
		
		<cfreturn this.campaign />
		
	</cffunction>
	
	<cffunction name="getDistributors" output="false" returntype="query">
		
		<cfquery name="qGetDistributors" datasource="#application.datasource#">
			SELECT 	BSA_Foodservice_Customers_ID,
					Name
			FROM 	BSA_Foodservice_Customers							
			WHERE
					<cfset disList = this.campaign.getDistributorList()>
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
					<cfset opList = this.campaign.getOperatorList()>					
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
	
	<cffunction name="getByFilter" output="true" returntype="query">
		
		<cfargument name="search" type="struct" required="true" />
		<cfset this.search = arguments.search>
		<cfset tickBegin = GetTickCount()>
		<cfset checkOnUserPosition = Super.variableExist("this.search.User_ID", "")>
		<cfif checkOnUserPosition>
			<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
				SELECT User_Positions_ID
				FROM User_Position_Holders
				WHERE User_ID = '#this.search.User_ID#' AND Deleted = 0
			</CFQUERY>
			<CFSET GP_Supplied_Position = getUserPosition.User_Positions_ID>
			<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">
			<!------ <cfset allOperatorIds = custManager.getAllOperators(this.search.User_ID)>
			<cfset allDistributorIds = custManager.getAllDistributors(this.search.User_ID)> ----->
			<cfset accessibleCamapginIds = "">
			
			<!------ Distributor ----->	
			 <CFQUERY NAME="Campaigns_For_Distributors" DATASOURCE="#application.datasource#">
				SELECT	DISTINCT CM_Campaign.CM_Campaign_ID
				FROM	CM_Campaign
						INNER JOIN CM_Campaign_Customer
						ON
						CM_Campaign_Customer.Deleted = 0
						AND
						CM_Campaign_Customer.CM_Campaign_ID = CM_Campaign.CM_Campaign_ID
						INNER JOIN CM_Customer
						ON
						CM_Customer.Deleted = 0
						AND
						CM_Customer.CM_Customer_ID = CM_Campaign_Customer.CM_Customer_ID							
						INNER JOIN BSA_Foodservice_Customers							
						ON
						BSA_Foodservice_Customers.Deleted = 0
						AND
						(
							(
								BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = CM_Customer.Distributor_ID
								AND
								CM_Customer.CM_Customer_Group_ID = 1
							)
							OR
							(
								BSA_Foodservice_Customers.Family_ID = CM_Customer.Family_ID
								AND
								CM_Customer.CM_Customer_Group_ID = 3
							)
							OR
							(
								BSA_Foodservice_Customers.Buying_Group_ID = CM_Customer.Buying_Group_ID
								AND
								CM_Customer.CM_Customer_Group_ID = 4
							)								
						)
						
						
						INNER JOIN BSA_Foodservice_Brokers
						ON
						BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
						AND
						BSA_Foodservice_Brokers.Deleted = 0	
						INNER JOIN Service_Markets
						ON
						Service_Markets.Deleted = 0
						AND
						Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID							
						INNER JOIN User_Positions
						ON
						User_Positions.Deleted = 0
						AND
						User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID		
						AND
						User_Positions.User_Positions_ID IN (#GP_Position_List_From_My_Position_Down#)
				WHERE
						CM_Campaign.Deleted = 0
			</CFQUERY>
			
			<cfset accessibleCamapginIds = ListAppend(accessibleCamapginIds, ValueList(Campaigns_For_Distributors.CM_Campaign_ID), ",")>
			  
			
			
			<!------ Operator ----->	
			<CFQUERY NAME="Campaigns_For_Operators" DATASOURCE="#application.datasource#">
				SELECT	DISTINCT CM_Campaign.CM_Campaign_ID
				FROM	CM_Campaign
						INNER JOIN CM_Campaign_Customer
						ON
						CM_Campaign_Customer.Deleted = 0
						AND
						CM_Campaign_Customer.CM_Campaign_ID = CM_Campaign.CM_Campaign_ID
						INNER JOIN CM_Customer
						ON
						CM_Customer.Deleted = 0
						AND
						CM_Customer.CM_Customer_ID = CM_Campaign_Customer.CM_Customer_ID
						INNER JOIN BSA_Operator
						ON
						BSA_Operator.Deleted = 0							
						AND
						(
							(
							BSA_Operator.BSA_Operator_ID = 	CM_Customer.Operator_ID
							AND
							CM_Customer.CM_Customer_Group_ID = 2
							)
							OR
							(
							BSA_Operator.Operator_Type = 	CM_Customer.Operator_Type
							AND
							CM_Customer.CM_Customer_Group_ID = 5
							)
						)
						INNER JOIN Market_ZipCode
						ON
						Market_ZipCode.ZipCode = Left(BSA_Operator.Operator_Zip, 5)
						AND
						Market_ZipCode.Deleted = 0	
						INNER JOIN Service_Markets
						ON
						Service_Markets.Deleted = 0
						AND
						Service_Markets.Service_Market_ID = Market_ZipCode.Service_Market_ID
						INNER JOIN User_Positions
						ON
						User_Positions.Deleted = 0
						AND
						(
							(
								User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID
							)
							OR
							(
								BSA_Operator.User_Positions_ID IS NOT NULL
								AND
								User_Positions.User_Positions_ID = BSA_Operator.User_Positions_ID
							)
						)
						AND
						User_Positions.User_Positions_ID IN (#GP_Position_List_From_My_Position_Down#)
				WHERE
						CM_Campaign.Deleted = 0
			</CFQUERY>
			
			<cfset accessibleCamapginIds = ListAppend(accessibleCamapginIds, ValueList(Campaigns_For_Operators.CM_Campaign_ID), ",")>				
				
			
		</cfif>
		<cfquery name="qGetCampaignSearch" datasource="#application.datasource#">
			
			SELECT 	DISTINCT
					CM_Campaign.CM_Campaign_ID,
					CM_Campaign.Campaign_Name,
					CM_Campaign.Campaign_Description,
					CM_Campaign.Campaign_Start_Date,
					CM_Campaign.Campaign_End_Date,
					CM_Campaign.Created_By_User_ID,
					CM_Campaign.Updated_By_User_ID
			FROM	CM_Campaign					
			WHERE 	CM_Campaign.deleted = 0		
			<cfif checkOnUserPosition>
				AND	
				<cfif Len(accessibleCamapginIds) GT 0>
					CM_Campaign.CM_Campaign_ID IN (#accessibleCamapginIds#)
				<cfelse>
					1 = 2
				</cfif>	
			</cfif>	
			<cfif Super.variableExist("this.search.Campaign_Name", "")>
				AND 	CM_Campaign.Campaign_Name LIKE '%#this.search.Campaign_Name#%'
			</cfif>
			<cfif Super.variableExist("this.search.Campaign_Start_Date", "")>
				<cfif isDate(this.search.Campaign_Start_Date)>
				AND DateDiff(d, CM_Campaign.Campaign_Start_Date, #CreateOdbcDate(this.search.Campaign_Start_Date)#) >= 0
				AND DateDiff(d, #CreateOdbcDate(this.search.Campaign_Start_Date)#, CM_Campaign.Campaign_End_Date) >= 0
				</cfif>
			</cfif>
			<cfif Super.variableExist("this.search.Campaign_End_Date", "")>
				<cfif isDate(this.search.Campaign_End_Date)>
				AND DateDiff(d, CM_Campaign.Campaign_Start_Date, #CreateOdbcDate(this.search.Campaign_End_Date)#) >= 0
				AND DateDiff(d, #CreateOdbcDate(this.search.Campaign_End_Date)#, CM_Campaign.Campaign_End_Date) >= 0
				</cfif>
			</cfif>
					
		</cfquery>
		<cfset tickEnd = GetTickCount()>
		<cfset TotalTimeTaken = tickEnd - tickBegin>
		Time taken = #TotalTimeTaken# ms<HR>
		<cfreturn qGetCampaignSearch />
		
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
					
		<cfquery name="qGetAllCampaign" datasource="#application.datasource#">
			SELECT 	*
			FROM	CM_Campaign
			WHERE 	Deleted = 0
		</cfquery>
			
		<cfreturn qGetAllCampaign />
		
	</cffunction>
	
	<cffunction name="save" output="true">	
		
		<cftransaction action="begin">
			<cfif this.campaign.getId()>
				
				<cfquery name="qUpdateCampaign" datasource="#application.datasource#">
					UPDATE 	CM_Campaign
					SET		Campaign_Name = <cfqueryPARAM value = "#this.campaign.getName()#" CFSQLType = "CF_SQL_VARCHAR">, 
							Campaign_Description = <cfqueryPARAM value = "#this.campaign.getDesc()#" CFSQLType = "CF_SQL_VARCHAR">,
							Campaign_Start_Date = <cfqueryPARAM value = "#this.campaign.getStartDate()#" CFSQLType = "CF_SQL_DATE">,
							Campaign_End_Date = <cfqueryPARAM value = "#this.campaign.getEndDate()#" CFSQLType = "CF_SQL_DATE">,
							Updated_By_User_ID = <cfqueryPARAM value = "#this.campaign.getUpdatedUserId()#" CFSQLType = "CF_SQL_VARCHAR">,
							Updated_Date = getDate()
					WHERE	CM_Campaign_ID = <cfqueryPARAM value = "#this.campaign.getId()#" CFSQLType = "CF_SQL_INTEGER">
					AND		deleted = 0		
				</cfquery>
				
			<cfelse>
			
				<cfquery name="insertCampaign" datasource="#application.datasource#">
					
					SET NOCOUNT ON
					
					INSERT INTO CM_Campaign
						(Campaign_Name, Campaign_Description, Campaign_Start_Date, Campaign_End_Date, 
							Created_By_User_ID, Updated_By_User_ID)
					VALUES
						(
						<cfqueryPARAM value = "#this.campaign.getName()#" CFSQLType = "CF_SQL_VARCHAR">, 
						<cfqueryPARAM value = "#this.campaign.getDesc()#" CFSQLType = "CF_SQL_VARCHAR">, 
						<cfqueryPARAM value = "#this.campaign.getStartDate()#" CFSQLType = "CF_SQL_DATE">, 
						<cfqueryPARAM value = "#this.campaign.getEndDate()#" CFSQLType = "CF_SQL_DATE">, 
						<cfqueryPARAM value = "#this.campaign.getCreatedUserId()#" CFSQLType = "CF_SQL_VARCHAR">,
						<cfqueryPARAM value = "#this.campaign.getUpdatedUserId()#" CFSQLType = "CF_SQL_VARCHAR">
						)
					
					SELECT CM_Campaign_ID = @@IDENTITY
					
					SET NOCOUNT OFF
					
				</cfquery>
				
				<cfset this.campaign.setId(insertCampaign.CM_Campaign_ID) />
				
			</cfif>
			
			<!--- delete all customers --->
			<cfquery name="qDeleteCampaignCustomers" datasource="#application.datasource#">

				UPDATE 	CM_Campaign_Customer
				SET		DELETED = 1
				WHERE	
						Deleted = 0
						AND
						CM_Campaign_ID = #this.campaign.getId()#

			</cfquery>
			
			<cfquery name="qDeleteCustomers" datasource="#application.datasource#">
				
				UPDATE 	CM_Customer
				SET		DELETED = 1
				WHERE	
						Deleted = 0
						AND
						CM_Customer_ID IN 
						(SELECT	CM_Customer_ID 
						FROM 	CM_Campaign_Customer
						WHERE	CM_Campaign_ID = #this.campaign.getId()#)						
			</cfquery>
				
			<!---loop over any distributors and update for each--->
			<cfloop index="indx" list="#this.campaign.getDistributorList()#">
				
				<cfset custId = custManager.save(1, indx)>
				
				<!---insert distributors--->
				<cfquery name="qInsertCustomer" datasource="#application.datasource#">
				
					INSERT INTO CM_Campaign_Customer
						(CM_Customer_ID, CM_Campaign_ID)
					VALUES
						(#custId#, #this.campaign.getId()#)
						
				</cfquery>
				
			</cfloop>
			
			<!---loop over any operators and update for each--->
			<cfloop index="indx" list="#this.campaign.getOperatorList()#">
				
				<cfset custId = custManager.save(2, indx)>
				
				<!---insert distributors--->
				<cfquery name="qInsertCustomer" datasource="#application.datasource#">
				
					INSERT INTO CM_Campaign_Customer
						(CM_Customer_ID, CM_Campaign_ID)
					VALUES
						(#custId#, #this.campaign.getId()#)
						
				</cfquery>
				
			</cfloop>
			
			
			<!---loop over any family and update for each--->
			<cfloop index="indx" list="#this.campaign.getFamilyList()#">
				
				<cfset custId = custManager.save(3, indx)>
				
				<!---insert distributors--->
				<cfquery name="qInsertCustomer" datasource="#application.datasource#">
				
					INSERT INTO CM_Campaign_Customer
						(CM_Customer_ID, CM_Campaign_ID)
					VALUES
						(#custId#, #this.campaign.getId()#)
						
				</cfquery>
				
			</cfloop>
			
			<!---loop over any buying Group and update for each--->
			<cfloop index="indx" list="#this.campaign.getBuyingGroupList()#">
				
				<cfset custId = custManager.save(4, indx)>
				
				<!---insert distributors--->
				<cfquery name="qInsertCustomer" datasource="#application.datasource#">
				
					INSERT INTO CM_Campaign_Customer
						(CM_Customer_ID, CM_Campaign_ID)
					VALUES
						(#custId#, #this.campaign.getId()#)
						
				</cfquery>
				
			</cfloop>
			
			<!---loop over any operator type and update for each--->
			<cfloop index="indx" list="#this.campaign.getOperatorTypeList()#">
				
				<cfset custId = custManager.save(5, indx)>
				
				<!---insert distributors--->
				<cfquery name="qInsertCustomer" datasource="#application.datasource#">
				
					INSERT INTO CM_Campaign_Customer
						(CM_Customer_ID, CM_Campaign_ID)
					VALUES
						(#custId#, #this.campaign.getId()#)
						
				</cfquery>
				
			</cfloop>
			
		</cftransaction>
		
	</cffunction>

</cfcomponent>