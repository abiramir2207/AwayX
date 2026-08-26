<cfcomponent hint="Distributor Group Manager" extends="components.Base">

	<!--- <cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()> --->
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<!--- Label 10406: Hide Add all Distributor link ---> 
	<cfset allOn = 0 /><!--- appSettings.getAllowAllDistributors() --->
	
	<cffunction name="init" output="false" returntype="components.programs.distributors.DistributorGroupManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="allowSelectAllDistributors" output="false" returntype="boolean">
	
		<cfargument name="programId" type="numeric" required="true">
		
		<cfset bAllowSelectAllDistributors = false>
	
		<cfif allOn eq 1>
		
			<cfset bAllowSelectAllDistributors = true>
		
		</cfif>
	
		<cfreturn bAllowSelectAllDistributors />
		
	</cffunction>
	
	<cffunction name="getDistributorForGroupDistributors" output="false" returntype="string">
	
		<cfargument name="groupLevel" type="numeric" required="true">
		<cfargument name="groupID" type="numeric" required="true">
	
		<cfset distributorId = "">
		
		<cfif arguments.groupLevel NEQ 0 AND isNumeric(arguments.groupLevel)>
	
			<cfset useLakebaseForqGetAllDistributorsDistributorID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_group_distributor")>
<cfif useLakebaseForqGetAllDistributorsDistributorID>
	<cftry>
		<cfset qGetAllDistributorsDistributorID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_group_distributor", {
				"deleted" = "eq.0",
				"distributor_group_level_id" = "eq.#arguments.groupLevel#",
				"distributor_group_id" = "eq.#arguments.groupID#",
				"limit" = "1",
				"select" = "distributor_id"
			}), "distributor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAllDistributorsDistributorID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAllDistributorsDistributorID>
<cfquery name="qGetAllDistributorsDistributorID" datasource="#application.datasource#">
				SELECT	TOP 1 Distributor_ID
				FROM	Distributor_Group_Distributor
				WHERE
						Deleted = 0
						AND Distributor_Group_Level_ID = #arguments.groupLevel#
						AND Distributor_Group_ID = '#arguments.groupID#'
			</cfquery>
</cfif>
			
			<cfloop query="qGetAllDistributorsDistributorID">
			
				<cfset distributorId = Distributor_ID>
			
			</cfloop>
		
		</cfif>
	
		<cfreturn distributorId />
		
	</cffunction>
	
	<cffunction name="getDistributorGroupDistributorCount" output="false" returntype="numeric">
	
		<cfargument name="distributorGroupLevel" type="numeric" required="true">
		<cfargument name="distributorGroupID" type="string" required="true">
		
		<cfset distributorsCount = 0>
	
		<cfif arguments.distributorGroupLevel EQ 1>
		
			<cfquery name="qGetDistributorsCount" datasource="#application.datasource#">
				SELECT 	Count(DISTINCT BSA_Foodservice_Customers.Ship_To) As groupDistributorsCount
				FROM	BSA_Foodservice_Customers
						INNER JOIN	Distributor_Family 
						ON 
						BSA_Foodservice_Customers.Family_ID = Distributor_Family.Family_ID 
						INNER JOIN	dbo.Distributor_Buying_Groups 
						ON 	
						BSA_Foodservice_Customers.Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID 
						<cfif appSettings.getDistributorMultiPosition()>
						INNER JOIN Market_Distributor
						ON
						Market_Distributor.Deleted = 0
						AND Market_Distributor.Distributor_ID = BSA_FoodService_Customers.BSA_FoodService_Customers_ID
						INNER JOIN Service_Markets
						ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
						</cfif>
						INNER JOIN	dbo.BSA_Foodservice_Brokers 
						ON 
						<cfif appSettings.getDistributorMultiPosition()> 
						BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
						<cfelse>
						dbo.BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = dbo.BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID 
						</cfif>
						INNER JOIN	dbo.Service_Regions 
						ON 
						<cfif appSettings.getDistributorMultiPosition()>
						Service_Regions.Service_Region_ID = Service_Markets.Service_Region_ID
						<cfelse>
						dbo.BSA_Foodservice_Brokers.Service_Region_ID = dbo.Service_Regions.Service_Region_ID 
						</cfif>
						INNER JOIN	dbo.Service_Zones 
						ON 
						dbo.Service_Regions.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID
				WHERE
						BSA_Foodservice_Customers.Deleted = 0
						AND
						BSA_Foodservice_Customers.Active_Code = 'A'
						<cfif arguments.distributorGroupID NEQ "" AND arguments.distributorGroupID NEQ 0>
						<cfif application.returned_customer_setting.customer_keyword IS "conagra" AND arguments.distributorGroupID EQ 5>
						<cfset arguments.distributorGroupID = 1 />
						</cfif>
						AND BSA_Foodservice_Customers.Business_Segment_ID = #arguments.distributorGroupID#
						<!------ <cfelse>
						AND Business_Segment_ID IS NULL ----->
						</cfif>
			</cfquery>			
			<cfset distributorsCount = qGetDistributorsCount.groupDistributorsCount />
		
		</cfif>
	
		<cfreturn distributorsCount />
		
	</cffunction>
	
	<cffunction name="isAllDistributorProgram" output="true" returntype="boolean">
	
		<cfargument name="programId" type="numeric" required="true">
		
		<cfset bAllDistributorProgram = false />
		
		<cfset this.businessSegmentID = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").getSegmentIdByProgram(arguments.programId) />
		
		<cfset this.groupDistributorId = this.getDistributorForGroupDistributors(1, this.businessSegmentID) />
		
		<cfif Len(this.groupDistributorId) Gt 0>
		
			<cfquery name="qGetAllDistributor" datasource="#application.datasource#">
	
				SELECT	BSA_Foodservice_Customers_ID
				FROM	Contract_Distributors
				WHERE
						Contract_Distributors.Deleted = 0
						AND
						Contract_Distributors.Contract_Main_ID = #arguments.programId#
						AND
						Contract_Distributors.BSA_Foodservice_Customers_ID = '#this.groupDistributorId#'						
			</cfquery>
			
			<cfif qGetAllDistributor.recordCount>
	
				<cfset bAllDistributorProgram = true />
			
			</cfif>
		
		</cfif>
		
		<cfreturn bAllDistributorProgram />
		
	</cffunction>
	
	<cffunction name="getGroupFromDistributor" output="false" returntype="any">
	
		<cfargument name="distributorId" type="string" required="true">
		<cfargument name="returnType" type="numeric" required="false" default="1" hint="1=query,2=groupLevel,3=groupId">
	
		<cfset groupLevel = 0>
		<cfset groupId = "">
		
		
		<cfset useLakebaseForqGetDistributorGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_group_distributor")>
<cfif useLakebaseForqGetDistributorGroup>
	<cftry>
		<cfset qGetDistributorGroup = application.oLakebase.toQuery(
			application.oLakebase.selectRows("distributor_group_distributor", {
				"deleted" = "eq.0",
				"distributor_id" = "eq.#arguments.distributorId#",
				"select" = "distributor_group_level_id,distributor_group_id"
			}), "distributor_group_level_id,distributor_group_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistributorGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistributorGroup>
<cfquery name="qGetDistributorGroup" datasource="#application.datasource#">
			SELECT	Distributor_Group_Level_ID, Distributor_Group_ID
			FROM	Distributor_Group_Distributor
			WHERE
					Deleted = 0
					AND
					Distributor_ID = '#arguments.distributorId#'
		</cfquery>
</cfif>
		
		<cfif arguments.returnType EQ 1>
		
			<cfif NOT qGetDistributorGroup.recordCount>
			
				<cfset QueryAddRow(qGetDistributorGroup) />
				<cfset QuerySetCell(qGetDistributorGroup, "Distributor_Group_Level_ID", 0) />
				<cfset QuerySetCell(qGetDistributorGroup, "Distributor_Group_ID", "") />
			
			</cfif>
		
			<cfreturn qGetDistributorGroup />
			
		<cfelseif arguments.returnType EQ 2>
		
			<cfif qGetDistributorGroup.recordCount>
			
				<cfset groupLevel = qGetDistributorGroup.Distributor_Group_Level_ID />
			
			</cfif>
			
			<cfreturn groupLevel />
			
		<cfelseif arguments.returnType EQ 3>
		
			<cfif qGetDistributorGroup.recordCount>
			
				<cfset groupId = qGetDistributorGroup.Distributor_Group_ID />
			
			</cfif>
			
			<cfreturn groupId />
			
		</cfif>
		
		<cfreturn 0 />
		
	</cffunction>
	
	<cffunction name="getDistributorGroupDetails" output="false" returntype="any">
	
		<cfargument name="distributorGroupLevel" type="numeric" required="true">
		<cfargument name="distributorGroupID" type="string" required="true">
		
		<cfset prodGroupDetails = StructNew() />
		<cfset prodGroupDetails.Shr_Ship_To = "" />
		<cfset prodGroupDetails.Ship_to = "" />
		<cfset prodGroupDetails.Name = "All Distributors" />
		
		<cfif arguments.distributorGroupLevel EQ 1>
		
			<cfif isNumeric(arguments.distributorGroupID) AND arguments.distributorGroupID NEQ 0>
			
				<cfset useLakebaseForprodGroupDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForprodGroupDetails>
	<cftry>
		<cfset prodGroupDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment", {
				"deleted" = "eq.0",
				"business_segment_id" = "eq.#arguments.distributorGroupID#",
				"select" = "'' as shr_ship_to,'' as ship_to,distributor_label_plural#' as name"
			}), "'' as shr_ship_to,'' as ship_to,distributor_label_plural#' as name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForprodGroupDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForprodGroupDetails>
<cfquery name="prodGroupDetails" datasource="#application.datasource#">
				
					SELECT 	'' AS Shr_Ship_To,
							'' AS Ship_To,
							'All ' + Business_Unit_Desc + ' #application.returned_customer_setting.distributor_label_plural#' As Name
					FROM	Business_Segment
					WHERE
							Business_Segment.Deleted = 0
							AND
							Business_Segment.Business_Segment_ID = #arguments.distributorGroupID#
							
				</cfquery>
</cfif>
			
			</cfif>
		
		</cfif>	
		
		<cfreturn prodGroupDetails />
	
	</cffunction>
	
	<cffunction name="getDistGroupInfo" output="false">
	
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfquery name="qGetProgramInfo" datasource="#application.datasource#">
			SELECT	Program_Control_Panel_Options.Specify_Distributor_Groups,
						Program_Control_Panel_Options.Dynamic_Static_Groups,
						Program_Control_Panel_Options.Specify_Individual_Distributors, --- D55544 
						Program_Control_Panel_Options.Specify_Distributors
			FROM	Contract_Main
			INNER JOIN Program_Control_Panel_Options
			ON 		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			WHERE	Contract_Main.Contract_Main_ID = #arguments.programId#
		</cfquery>
		
		<cfreturn qGetProgramInfo>
		
	</cffunction>
	
	<cffunction name="ProgramDistributorIsGroup" output="false">
	
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfset returnValue = 0 />
		<cfset useLakebaseForqGetGroupsSaved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForqGetGroupsSaved>
	<cftry>
		<cfset qGetGroupsSaved = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#arguments.programId#",
				"deleted" = "eq.0",
				"is_group" = "eq.1",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGroupsSaved = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGroupsSaved>
<cfquery name="qGetGroupsSaved" datasource="#application.datasource#">
			SELECT 	TOP 1 *
			FROM 	Contract_Distributors
			WHERE 	Contract_Main_ID = #arguments.programId#
			AND 	Deleted = 0
			AND		Is_Group = 1		
		</cfquery>
</cfif>
		
		<cfif qGetGroupsSaved.recordCount>
			<cfset returnValue = 1 />
		</cfif>
		
		<cfreturn returnValue>
		
	</cffunction>

</cfcomponent>