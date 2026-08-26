<cfcomponent output="false" alias="mvc.Models.Admin.VolumePlan.VolPlanDAO">

	<!--- DATA ACCESS FOR VolumePlanManager --->
	<cfscript>
		variables.oPositions = createObject('component','components.geography.position').init();
	</cfscript>

	<cffunction name="init" output="false" returntype="mvc.Models.Admin.VolumePlan.VolPlanDAO">
		<cfreturn this />
	</cffunction>
	
	<!---.................................................................................................
	.......................................................................................................
	....................................... GET VOL PLAN MASTER ...........................................
	.......................................................................................................
	.......................................................................................................--->
	<cffunction name="getVolPlanMasterIds" returntype="Query" access="public" >
		<cfargument name="volPlanMasterId" default="0" />
		<cfargument name="userId" />
		<!--- Get list of id's --->
		<cfscript>
			var qGetVolPlanMasterIds = '';
		</cfscript>
		
			<cfquery name="qGetVolPlanMasterIds" datasource="#application.datasource#">
				  SELECT [Vol_Plan_Master_Id] as volPlanMasterId
				  FROM [Vol_Plan_Master] VPM
				  <cfif volPlanMasterId >
				  	WHERE Vol_Plan_Master_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlanMasterId#" />
				 </cfif>
			</cfquery>
		
		<cfreturn qGetVolPlanMasterIds />
	</cffunction>
	
	<cffunction name="getVolPlanMaster" returntype="Query" access="public" >
		<cfargument name="volPlanMasterId" default="0" />
		<cfargument name="userId" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		<!--- Get array of mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		<cfscript>
			var qGetVolPlanMaster = queryNew('x');
			WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
		<cfif volPlanMasterId >
			<cfquery name="qGetVolPlanMaster" datasource="#application.datasource#">
				  SELECT [Vol_Plan_Master_Id] as volPlanMasterId
				      ,[VPM].[Description] as description
				      ,[Baseline] as baseline
				      ,[VPM].[Volume_Plan_Source_Id] as idSource
					  	,[VPS].[description] as descSource
				      ,[VPM].[Volume_Plan_Status_Id] as idStatus
					  	,[VPStat].[description] as descStatus
				      ,[Calendar_Type] as type
				      ,[Calendar_Year] as year
				      ,[Start_Date] as start
				      ,[End_Year] as [end]
				      ,[VPM].[Item_PG_Type_Id] as itemTypeId
						, [PGTI].[PG_Type_Code] as itemCode
					  	, [PGTI].[PG_Type_Name] as itemName
						, [PGTI].[PG_Group_Type] as itemGroupTypeId
				      ,[VPM].[Customer_PG_Type_Id] as customerTypeId
					  	, [PGTC].[PG_Type_Code] as customerCode
					  	, [PGTC].[PG_Type_Name] as customerName
						, [PGTC].[PG_Group_Type] as customerGroupTypeId
				      ,[VPM].[Created_Date]
				      ,[VPM].[Created_User_Id]
				      ,[VPM].[Updated_Date]
				      ,[VPM].[Updated_User_Id]
					  	,0 as locked
				  FROM [Vol_Plan_Master] VPM
				  LEFT JOIN dbo.Volume_Plan_Source VPS ON
					VPS.Volume_Plan_Source_Id = VPM.Volume_Plan_Source_Id
				  LEFT JOIN dbo.Volume_Plan_Status VPStat ON
					VPStat.Volume_Plan_Status_Id = VPM.Volume_Plan_Status_Id
				  LEFT JOIN PG_Type PGTC ON
					PGTC.PG_Type_ID = VPM.Customer_PG_Type_Id
				  LEFT JOIN PG_Type PGTI ON
				    PGTI.PG_Type_ID = VPM.Item_PG_Type_Id
				  WHERE Vol_Plan_Master_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlanMasterId#" />	
			</cfquery>
		</cfif>
		<cfreturn qGetVolPlanMaster />
	</cffunction>
	
	<cffunction name="getVolPlans" returntype="Query" access="public" >
		<cfargument name="volPlanMasterId" default="0" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qGetVolPlan = queryNew('x');
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
		<cfif volPlanMasterId >
			<cfquery name="qGetVolPlan" datasource="#application.datasource#">
				SELECT [VP].[Vol_Plan_Id] as id
				      ,[VP].[Vol_Plan_Master_Id] as volPlanMasterId
				      ,[VP].[Description] as description
				      ,[VP].[Status] as status
				      ,[VP].[Created_Date] as createdDate
				      ,[VP].[Created_User_Id] as createdUser
				FROM [Vol_Plan] VP
				WHERE Vol_Plan_Master_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlanMasterId#" />	
			</cfquery>
		</cfif>
		<cfreturn qGetVolPlan />
		
	</cffunction>
	
	<cffunction name="getVolPlanPositions" returntype="Query" access="public" >
		<cfargument name="volPlanId" default="" />
		<cfscript>
			var qGetVolPlanPositions = '';
			//WriteLog(file="application.log", text="#volPlanId# & ' :: DAOgetVolPlanPositions"); 
		</cfscript>
		<!--- xx--->
		<cfquery name="qGetVolPlanPositions" datasource="#application.datasource#">
			SELECT 
				[VPP].[User_Positions_Id] as userPositionsId
				,[UP].[Position_Label] as positionLabel
			FROM [Vol_Plan_Position] [VPP]
			LEFT JOIN [USER_POsitions] [UP] ON
				  [UP].[User_Positions_Id] = [VPP].[User_Positions_Id]
			WHERE Vol_Plan_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlanId#" />	
		</cfquery>
		<cfreturn qGetVolPlanPositions />
	</cffunction>
	
	<cffunction name="getVolPlanCustomers" returntype="Query" access="public" >
		<cfargument name="volPlanId" default="" />
		<cfscript>
			var qGetVolPlanCustomers = '';
			//WriteLog(file="application.log", text="#volPlanId# & ' :: DAOgetVolPlanCustomers"); 
		</cfscript>
		<!--- xx--->
		<cfquery name="qGetVolPlanCustomers" datasource="#application.datasource#">
			SELECT [VPC].[Vol_Plan_Customer_Id]
      			,[VPC].[Vol_Plan_Id]
     			,[VPC].[PG_Type_Id] as typeId
      			,[VPC].[PG_Customer_Category_Id] as categoryId
      			,[VPC].[BSA_Foodservice_Customers_ID]
				--,[PGC].[PG_Type_ID]
     			--,[PGC].[PG_Customer_Category_Code] as code
      			--,[PGC].[PG_Customer_Category_Name] as name
			FROM [Vol_Plan_Customer] [VPC]
			LEFT JOIN [PG_Customer_Category] [PGC] ON
				[PGC].[PG_Customer_Category_Id] = [VPC].[PG_Customer_Category_Id]
			WHERE Vol_Plan_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlanId#" />
			AND [VPC].[BSA_Foodservice_Customers_ID] IS NOT NULL
		</cfquery>
		<cfreturn qGetVolPlanCustomers />
	</cffunction>
	
	<cffunction name="getVolPlanCustomersPg" returntype="Query" access="public" >
		<cfargument name="volPlanId" default="" />
		<cfscript>
			var qGetVolPlanCustomersPg = '';
			//WriteLog(file="application.log", text="#volPlanId# & ' :: DAOgetVolPlanCustomers"); 
		</cfscript>
		<!--- xx--->
		<cfquery name="qGetVolPlanCustomersPg" datasource="#application.datasource#">
			SELECT [VPC].[Vol_Plan_Customer_Id]
      			,[VPC].[Vol_Plan_Id]
     			,[VPC].[PG_Type_Id] as typeId
      			,[VPC].[PG_Customer_Category_Id] as categoryId
      			--,[VPC].[BSA_Foodservice_Customers_ID]
				--,[PGC].[PG_Type_ID]
     			,[PGC].[PG_Customer_Category_Code] as code
      			,[PGC].[PG_Customer_Category_Name] as name
			FROM [Vol_Plan_Customer] [VPC]
			LEFT JOIN [PG_Customer_Category] [PGC] ON
				[PGC].[PG_Customer_Category_Id] = [VPC].[PG_Customer_Category_Id]
			WHERE Vol_Plan_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlanId#" />
			AND [VPC].[PG_Type_Id] IS NOT NULL
			AND [VPC].[PG_Type_Id] != ''
			AND [VPC].[PG_Type_Id] != 0
		</cfquery>
		<cfreturn qGetVolPlanCustomersPg />
	</cffunction>
	
	
	<cffunction name="getVolPlanRecapture" returntype="Query" access="public" >
		<cfargument name="volPlanMasterId" default="0" />
		<cfscript>
			var qGetVolPlanRecapture = '';
			//WriteLog(file="application.log", text="#volPlanId# & ' :: DAOgetVolPlanCustomers"); 
		</cfscript>
		<!--- xx--->
		<cfquery name="qGetVolPlanRecapture" datasource="#application.datasource#">
			
			SELECT	[VPRC].[Vol_Plan_Master_Id] as [volPlanMasterId]
					,[PCPO].[Generic_Type] as [genericType]
					,[PCPO].[Created_Type] as [createdType]
					,[Vol_Plan_Recapture_Template_Id]
					,[VPRC].[Template_Id]
					,[PCPO].[First_Parent_Id]
			FROM [Vol_Plan_Recapture_Template] [VPRC]
			INNER JOIN [Program_Control_Panel_Options] [PCPO] ON
			[PCPO].[ProgramControl_Panel_Options_ID] = [VPRC].[Template_Id]
			WHERE Vol_Plan_Master_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlanMasterId#" />
		</cfquery>
		<cfreturn qGetVolPlanRecapture />
	</cffunction>
	
	<!---<cffunction name="getVolPlanCustomers" returntype="Query" access="public" >
		<cfargument name="volPlanId" default="" />
		<!--- xx--->
		<cfreturn queryNew('x') />
	</cffunction>--->
	
	<cffunction name="getVolPlanAdjustments" returntype="Query" access="public" >
		<cfargument name="volPlanId" default="" />
		<!--- xx--->
		<cfreturn queryNew('x') />
	</cffunction>
	
	<!---....................................................................................................
	.........................................................................................................
	....................................... SAVE VOL PLAN MASTER ............................................
	.........................................................................................................
	.........................................................................................................--->
	
	<cffunction name="InsertVolPlanMaster" returntype="boolean" access="public" >
		<cfargument name="VolPlanMaster" type="mvc.Models.Admin.VolumePlan.vos.VolPlanMaster" />
		<!--- SAVE data to DB for: mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		<cfquery name="qInsertVolPlanMaster" datasource="#application.datasource#">
				INSERT INTO Vol_Plan_Master
		           (
					   [Description]
					   ,[Baseline]
			           ,[Volume_Plan_Source_Id]
			           ,[Volume_Plan_Status_Id]
			           ,[Calendar_Type]
			           ,[Calendar_Year]
			           ,[Start_Date]
			           ,[End_Year]
					   <cfif VolPlanMaster.itemPlanGroupType.typeId>
							,[Item_PG_Type_Id]
						</cfif>
						<cfif VolPlanMaster.customerPlanGroupType.typeId>
							,[Customer_PG_Type_Id]
						</cfif>
			           ,[Created_User_Id]
				   )
		     VALUES
		           (
					   <cfqueryParam value="#VolPlanMaster.description#" cfsqltype="cf_sql_varchar" />
					   ,<cfqueryParam value="#VolPlanMaster.baseline#" cfsqltype="cf_sql_varchar" />
			           ,<cfqueryParam value="#VolPlanMaster.source.id#" cfsqltype="cf_sql_integer" />
			           <!---,<cfqueryParam value="#VolPlanMaster.status.id#" cfsqltype="cf_sql_integer" />--->
					   ,1 --1 is the id for WIP
			           ,<cfqueryParam value="#VolPlanMaster.calendar.type#" cfsqltype="cf_sql_varchar" />
			           ,<cfqueryParam value="#VolPlanMaster.calendar.year#" cfsqltype="cf_sql_varchar" />
			           ,<cfqueryParam value="#VolPlanMaster.calendar.start#" cfsqltype="cf_sql_date" />
			           ,<cfqueryParam value="#VolPlanMaster.calendar.end#" cfsqltype="cf_sql_date" />
						<cfif VolPlanMaster.itemPlanGroupType.typeId>
							,<cfqueryParam value="#VolPlanMaster.itemPlanGroupType.typeId#" cfsqltype="cf_sql_integer" />
						</cfif>
						<cfif VolPlanMaster.customerPlanGroupType.typeId>
							,<cfqueryParam value="#VolPlanMaster.customerPlanGroupType.typeId#" cfsqltype="cf_sql_integer" />
						</cfif>
						,<cfqueryParam value="#cookie.User_Id#" />
					)
			</cfquery>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="UpdateVolPlanMaster" returntype="boolean" access="public" >
		<cfargument name="VolPlanMaster" type="mvc.Models.Admin.VolumePlan.vos.VolPlanMaster" />
		<!--- SAVE data to DB for: mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		<cfquery name="qUpdateVolPlanMaster" datasource="#application.datasource#">
			UPDATE [Vol_Plan_Master]
			SET [Description] = <cfqueryParam value="#VolPlanMaster.description#" cfsqltype="cf_sql_varchar" />
				,[Baseline] = <cfqueryParam value="#VolPlanMaster.baseline#" cfsqltype="cf_sql_varchar" />
			    ,[Volume_Plan_Source_Id] = <cfqueryParam value="#VolPlanMaster.source.id#" cfsqltype="cf_sql_integer" />
				<cfif isnumeric(VolPlanMaster.status.id)>
			    	,[Volume_Plan_Status_Id] = <cfqueryParam value="#VolPlanMaster.status.id#" cfsqltype="cf_sql_integer" />
				<cfelse>
					,[Volume_Plan_Status_Id] = 1 --wip
				</cfif>
			    ,[Calendar_Type] = <cfqueryParam value="#VolPlanMaster.calendar.type#" cfsqltype="cf_sql_varchar" />
			    ,[Calendar_Year] = <cfqueryParam value="#VolPlanMaster.calendar.year#" cfsqltype="cf_sql_varchar" />
			    ,[Start_Date] = <cfqueryParam value="#VolPlanMaster.calendar.start#" cfsqltype="cf_sql_date"  />
			    ,[End_Year] = <cfqueryParam value="#VolPlanMaster.calendar.end#" cfsqltype="cf_sql_date" />
				<cfif VolPlanMaster.itemPlanGroupType.typeId>
				   ,[Item_PG_Type_Id] = <cfqueryParam value="#VolPlanMaster.itemPlanGroupType.typeId#" cfsqltype="cf_sql_integer" />
				</cfif>
				<cfif VolPlanMaster.customerPlanGroupType.typeId>
				   ,[Customer_PG_Type_Id] = <cfqueryParam value="#VolPlanMaster.customerPlanGroupType.typeId#" cfsqltype="cf_sql_integer" />
				</cfif>
				,[Updated_Date] = getDate()
     			,[Updated_User_Id] = <cfqueryParam value="#cookie.User_Id#"  cfsqltype="cf_sql_varchar" />
			 WHERE Vol_Plan_Master_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#VolPlanMaster.volPlanMasterId#" />	
		</cfquery>
		
		<cfreturn true />
	</cffunction>
	
	<cffunction name="checkVolPlanMasterExixts" returntype="boolean" access="public" >
		<cfargument name="iVolPlanMasterId" type="numeric" />
		<!--- SAVE data to DB for: mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		<cfquery name="qCheckVolPlanMaster" datasource="#application.datasource#">
			SELECT Vol_Plan_Master_Id
			FROM dbo.Vol_Plan_Master
			WHERE Vol_Plan_Master_Id = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.iVolPlanMasterId#" />
		</cfquery>
			
		<cfif qCheckVolPlanMaster.recordCount>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
		
	</cffunction>
	
	<!---....................................................................................................
	.........................................................................................................
	....................................... DELETE VOL PLAN MASTER ............................................
	.........................................................................................................
	.........................................................................................................--->
	
	<cffunction name="deleteVolPlanMaster" returntype="void" access="public" >
		<cfargument name="iVolPlanMasterId" type="numeric" />
		<!--- SAVE data to DB for: mvc.Models.Admin.VolumePlan.vos.VolPlanMaster --->
		
		<cftransaction>
			<cfquery name="qInsertVolPlanMasterLog" datasource="#application.datasource#">
				INSERT INTO [Vol_Plan_Master_Log]
			           ([Vol_Plan_Master_Id]
			           ,[Description]
			           ,[Baseline]
			           ,[Volume_Plan_Source_Id]
			           ,[Volume_Plan_Status_Id]
			           ,[Calendar_Type]
			           ,[Calendar_Year]
			           ,[Start_Date]
			           ,[End_Year]
			           ,[Item_PG_Type_Id]
			           ,[Customer_PG_Type_Id]
			           ,[Created_Date]
			           ,[Created_User_Id]
			           ,[Updated_Date]
			           ,[Updated_User_Id])
				SELECT [Vol_Plan_Master_Id]
				      ,[Description]
				      ,[Baseline]
				      ,[Volume_Plan_Source_Id]
				      ,[Volume_Plan_Status_Id]
				      ,[Calendar_Type]
				      ,[Calendar_Year]
				      ,[Start_Date]
				      ,[End_Year]
				      ,[Item_PG_Type_Id]
				      ,[Customer_PG_Type_Id]
				      ,[Created_Date]
				      ,[Created_User_Id]
				      ,[Updated_Date]
				      ,[Updated_User_Id]
				FROM [Vol_Plan_Master]
				WHERE Vol_Plan_Master_Id = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.iVolPlanMasterId#" />
			</cfquery>
		
			<cfquery name="qDeleteVolPlanMaster" datasource="#application.datasource#">
				DELETE FROM [Vol_Plan_Master]
				WHERE Vol_Plan_Master_Id = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.iVolPlanMasterId#" />
			</cfquery>
		</cftransaction>
		
			<!---<cfreturn true />--->
	</cffunction>
	
	<!---....................................................................................................
	.........................................................................................................
	........................................... SAVE VOL PLAN ...............................................
	.........................................................................................................
	.........................................................................................................--->
	<cffunction name="insertVolPlan" returntype="Numeric" access="public" >
		<cfargument name="volPlanMasterId" type="numeric" />
		<cfargument name="VolPlan" type="mvc.Models.Admin.VolumePlan.vos.VolPlan" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qInsertVolPlan = '';
			var iVolPlanId = 0;
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
		<cfif isNumeric(arguments.volPlan.volPlanMasterId) >
			<cfquery name="qInsertVolPlan" datasource="#application.datasource#" >
				INSERT INTO [Vol_Plan]
			           ([Vol_Plan_Master_Id]
			           ,[Description]
			           ,[Status]
			           ,[Created_Date]
			           ,[Created_User_Id])
			     VALUES
			           (<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlanMasterId#" /> 
			           ,<cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.volPlan.description#" />
			           ,<cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.volPlan.status#" />
			           ,getDate()
			           ,<cfqueryParam value="#cookie.User_Id#" />
					   )
				
				SELECT @@IDENTITY as ident
			</cfquery>
			<cfset iVolPlanId = qInsertVolPlan.ident />
		</cfif>
		<cfreturn iVolPlanId />
		
	</cffunction>
	
	<cffunction name="updateVolPlan" returntype="Boolean" access="public" >
		<cfargument name="VolPlan" type="mvc.Models.Admin.VolumePlan.vos.VolPlan" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qUpdateVolPlan = '';
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
		<cfif isNumeric(arguments.volPlan.volPlanMasterId)  >
			<cfquery name="qUpdateVolPlan" datasource="#application.datasource#">
				UPDATE [Vol_Plan]
				   SET [Description] = <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.volPlan.description#" />
				      ,[Status] = <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.volPlan.status#" />
				 WHERE Vol_Plan_Master_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlan.volPlanMasterId#" /> AND
				 	Vol_Plan_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlan.id#" /> 	
			</cfquery>
		</cfif>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="saveVolPlanCustomersPG" returntype="Boolean" access="public" >
		<cfargument name="VolPlanId" type="numeric" />
		<cfargument name="customer" type="mvc.Models.Admin.PlanGroup.vos.PlanGroup" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qSaveVolPlanCustomers = '';
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
			<cfquery name="qSaveVolPlanCustomers" datasource="#application.datasource#">
				INSERT INTO [Vol_Plan_Customer]
			           ([Vol_Plan_Id]
			           ,[PG_Type_Id]
			           ,[PG_Customer_Category_Id]
			          -- ,[BSA_Foodservice_Customers_ID]
					   )
			     VALUES
			           (<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.VolPlanId#" />
			           ,<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.customer.typeId#" />
			           ,<cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.customer.categoryId#" />
			         --  ,<!---<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.customer.customerId#" />--->
			           ) 	
			</cfquery>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="saveVolPlanCustomers" returntype="Boolean" access="public" >
		<cfargument name="VolPlanId" type="numeric" />
		<cfargument name="customer" type="mvc.Models.Admin.VolumePlan.vos.VolPlanCustomer" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qSaveVolPlanCustomers = '';
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
			<cfquery name="qSaveVolPlanCustomers" datasource="#application.datasource#">
				INSERT INTO [Vol_Plan_Customer]
			           ([Vol_Plan_Id]
			           ,[PG_Type_Id]
			           ,[PG_Customer_Category_Id]
			          -- ,[BSA_Foodservice_Customers_ID]
					   )
			     VALUES
			           (<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.VolPlanId#" />
			           ,<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.customer.typeId#" />
			           ,<cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.customer.categoryId#" />
			           ,<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.customer.customerId#" />
			           ) 	
			</cfquery>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="saveVolPlanPositions" returntype="Boolean" access="public" >
		<cfargument name="VolPlanId" type="numeric" />
		<cfargument name="UserPosition" type="mvc.Models.Entity.vos.UserPosition" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qSaveVolPlanPositions = '';
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
			<cfquery name="qSaveVolPlanPositions" datasource="#application.datasource#">
			 INSERT INTO [Vol_Plan_Position]
		           ([Vol_Plan_Id]
		           ,[User_Positions_Id])
		     VALUES
		           (<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.VolPlanId#" />
		           ,<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.UserPosition.userPositionsId#" />)
			</cfquery>
		<cfreturn true />
	</cffunction>
	
	
	<!---....................................................................................................
	.........................................................................................................
	....................................... DELETE VOL PLAN .................................................
	.........................................................................................................
	.........................................................................................................--->
	
	<cffunction name="deleteVolPlan" returntype="Boolean" access="public" >
		<cfargument name="VolPlan" type="mvc.Models.Admin.VolumePlan.vos.VolPlan" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qDeleteVolPlan = '';
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
		<cfif isNumeric(arguments.volPlan.volPlanMasterId)  >
			<cfquery name="qDeleteVolPlan" datasource="#application.datasource#">
				DELETE FROM [Vol_Plan]
				 WHERE Vol_Plan_Master_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlan.volPlanMasterId#" /> AND
				 	Vol_Plan_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlan.id#" /> 	
			</cfquery>
		</cfif>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="deleteVolPlanPositions" returntype="Boolean" access="public" >
		<cfargument name="VolPlan" type="mvc.Models.Admin.VolumePlan.vos.VolPlan" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qDeleteVolPlanPositions = '';
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
			<cfquery name="qDeleteVolPlanPositions" datasource="#application.datasource#">
			DELETE FROM [Vol_Plan_Position]
			WHERE Vol_Plan_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlan.id#" />	
			</cfquery>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="deleteVolPlanCustomers" returntype="Boolean" access="public" >
		<cfargument name="VolPlan" type="mvc.Models.Admin.VolumePlan.vos.VolPlan" />
		<!--- Get data from DB for: mvc.Models.Admin.VolumePlan.vos.VolumePlan for
			a specific VPMaster
		 --->
		 <cfscript>
			var qDeleteVolPlanCustomers = '';
			//WriteLog(file="application.log", text="#volPlanMasterId# & ' :: DAO"); 
		</cfscript>
			<cfquery name="qDeleteVolPlanCustomers" datasource="#application.datasource#">
			DELETE FROM [Vol_Plan_Customer]
			WHERE Vol_Plan_Id =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.volPlan.id#" />	
			</cfquery>
		<cfreturn true />
	</cffunction>
	
	<!---...................................................................................................
	........................................................................................................
	........................................ MASTER DEFINITION QUERIES .....................................
	........................................................................................................
	.........................................................................................................--->
	
	<cffunction name="getVolPlanMasterSource" returntype="Query" access="public" >
		<cfset var qGetVolPlanSource = "" />
		
		<cfquery name="qGetVolPlanSource" datasource="#application.datasource#">
			SELECT	
				Volume_Plan_Source_Id as idSource,
				Description as descSource
			FROM Volume_Plan_Source
    	</cfquery>
		
		<cfreturn qGetVolPlanSource />
	</cffunction>
	
	<cffunction name="getVolPlanMasterCalendar" returntype="Query" access="public" >
		<!--- xx--->
		<cfset var qGetVpCalendar = "" />
		
		<cfquery name="qGetVpCalendar" datasource="#application.datasource#">
			SELECT  'fiscal' as Cal_Type,
					fiscal_year as VP_Year,
					MIN(start_date) as Start_Date,
					MAX(end_date) as End_Date
			FROM fiscal_Year
			WHERE fiscal_year IN(
						SELECT DISTINCT fiscal_year
								--,datePart(yyyy,start_date) 
								--,datePart(yyyy,end_date)
						FROM fiscal_Year
						WHERE deleted = 0
						AND start_date > getDate()
						)
			GROUP by fiscal_year
			UNION
			SELECT  'calendar' as Cal_Type,
					CAST(datepart(yyyy,getdate()) as VarChar(4))  as VpYear,
					DATEADD(year, DATEDIFF(year, 0, getDate()), 0) as Start_Date,
					DATEADD(year, DATEDIFF(year, -1, getDate()), -1) as End_Date
			UNION
			SELECT  'calendar' as Cal_Type,
					CAST(datepart(yyyy,DATEADD(year,1,getdate())) as VarChar(4))  as VpYear,
					DATEADD(year, DATEDIFF(year, 0, GETDATE())+1, 0) as Start_Date,
					DATEADD(day,-1,DATEADD(year, DATEDIFF(year, 0, getDate())+2, 0)) as End_Date
	    </cfquery>
		
		<cfreturn qGetVpCalendar />
		
	</cffunction>
	
	<cffunction name="getVolPlanMasterTemplates" returntype="Query" access="public" >
		<cfargument name="Generic_Type" default="" />
		<!--- xx --->
		<cfset var qGet = "" />
		
		<cfquery name="qGetVolPlanMasterTemplates" datasource="#application.datasource#">
			SELECT ProgramControl_Panel_Options_ID as Id,
					Generic_Type as genericType,
					Created_Type as createdType,
					First_Parent_ID as firstParentID
			FROM Program_Control_Panel_Options
			WHERE Deleted = 0 AND
				pullback_Template_Type = 2
				AND IsDominant = 1
    	</cfquery>
			<!---Generic_Type IN ('Operator Direct or HQ Programs',
							'Operator-Deviated Pricing')--->
		<cfreturn qGetVolPlanMasterTemplates />
	</cffunction>
	
	<cffunction name="getVolPlanUserPositons" returntype="Query" access="public" >
		<!--- xx--->
		<!---SELECT	User_Positions.User_Positions_ID, 
					Position_Label,
					Service_Zones.Zone_Name,
					Service_Regions.Region_Name,
					Service_Markets.Market_Name,
					Service_Zones.Service_Zone_ID,
					Service_Regions.Service_Region_ID,
					Service_Markets.Service_Market_ID
			FROM	User_Positions
					LEFT JOIN	Service_Zones
					ON
					Service_Zones.Service_Zone_ID = User_Positions.Service_Zone_ID
					AND
					Service_Zones.Deleted = 0
					LEFT JOIN	Service_Regions
					ON
					Service_Regions.Service_Region_ID = User_Positions.Service_Region_ID
					AND
					Service_Regions.Deleted = 0
					LEFT JOIN	Service_Markets
					ON
					Service_Markets.Service_Market_ID = User_Positions.Service_Market_ID
					AND
					Service_Markets.Deleted = 0					
			WHERE
					User_Positions.Deleted = 0 --->
		<cfreturn oPositions.getPosition() />
	</cffunction>
	
	<!---<cffunction name="getVolPlanUserPositons" returntype="Query" access="public" >
		<cfargument name="xx" default="" />
		<!--- xx--->
		
	</cffunction>--->
	
	<!---
		<cfset var qGet = "" />
			<cfquery name="qGet" datasource="#application.datasource#">
				SELECT	
	    	</cfquery>
		<cfreturn qGet />
	--->

</cfcomponent>