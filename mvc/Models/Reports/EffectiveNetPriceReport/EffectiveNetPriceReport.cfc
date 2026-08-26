<cfcomponent displayname="EffectiveNetPriceReport" hint="Effective Net Price Report" output="false">

	<cfset appSettings = application.appSettingsGet />
	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<!--<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfargument name="programId" default="0">-->
		<cfset var obj = "" />
		<cfset var stSettings = StructNew()/>
		
		<!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data--->
		<cfset obj = createobject("component", "mvc.models.SettingsService") />
		<cfset stSettings.user = StructNew()/>
		<cfset stSettings.user = obj.getUserObject(arguments.userId) />

		<!--- APPSETTINGS: return application.appSettingsGet as a structure with keys named the same as the appsettings methods--->
		<!--- <cfset stSettings.appSettings = StructNew()/> --->
		<cfset stSettings.appSettings = obj.getAppSettingsObject() /> 
		
		<!--- APP FLEX: Custom settings --->
		<cfset stSettings.appFlex = StructNew()/>
		<cfset stSettings.appFlex.var1 = "var1 myColumn Label" />
		<cfset stSettings.appFlex.var2 = "This could be any setting in Db" />
		<cfset stSettings.appFlex.SomeLabel = "_ProjectTemplate Label" /> <!--- Some Label --->
		
		
		<cfset stsettings.appflex.brokerlabel      	= application.returned_customer_setting.broker_label_singular />
		<cfset stsettings.appflex.regionlabel      	= application.returned_customer_setting.region_label_singular />
		<cfset stsettings.appflex.familylabel      	= application.returned_customer_setting.family_name_label_singular /> 
		<cfset stsettings.appflex.buyinggrouplabel 	= application.returned_customer_setting.buying_group_label_singular />
		<cfset stsettings.appflex.typecodelabel	 	= application.returned_customer_setting.type_code_label_singular />
	    <cfset stsettings.appflex.operatorlabel    	= application.returned_customer_setting.operator_label_singular />		
		<cfset stsettings.appflex.itemlabel		 	= application.returned_customer_setting.item_label />
		<cfset stsettings.appflex.shardshiptolabel 	= application.returned_customer_setting.shard_ship_to_label />
		<cfset stsettings.appflex.distributorlabel 	= application.returned_customer_setting.distributor_label_singular />
		
	  	<cfset stsettings.UIAttributes = obj.getUIAttributes()> 
		<cfreturn stSettings>
	</cffunction>
	
	
	  <!--------------------------------------------------------------------------- 
    This function returns the data for the report	
  ----------------------------------------------------------------------------->
	<cffunction name="getReportData" output="false" access="remote" returntype="query">
		<cfargument name="userId" type="string" required="true" />
		
		<cfset sPositionList = getBelowMarketIDList(userId = arguments.userId) />
		
		<cfquery name="qGetReportData" datasource="#application.datasource#">
			SELECT 	*
			--FROM	EFFECTIVE_SPENDING_RATE_EXTRACT_DATA
			FROM	EFFECTIVE_SPENDING_RATE_EXTRACT_DATA_SIMPLOT
			WHERE	Item <> ''
			<cfif sPositionList NEQ "">
			AND	Service_Market_ID IN (#Service_Market_ID#)
			</cfif>
		</cfquery>
			
		<cfreturn qGetReportData />
	</cffunction>
	
	  <!------------------------------------------------------------------------- 
    This function returns all the Buying Groups
  --------------------------------------------------------------------------->
	<cffunction name="getAllAuxiliaryData" output="false" access="remote" returntype="struct">
		<cfargument name="userId" type="string" required="true" />
		
		<cfset application.oController.getObject("mvc.Models.Distributor.DistributorManager") />
		<cfset application.oController.getObject("mvc.Models.Item.ProductManager") />
		
		<cfset stAll = StructNew() />
		
		<cfset stAll.BuyingGroup = application.oDistributorManager.getAllBuyingGroups() />
		<cfset stAll.Family = application.oDistributorManager.getAllFamilyNames() />
		<cfset stAll.Region = getAllRegions() />
		<cfset stAll.Broker = getAllBrokers() />
		<cfset stAll.TypeCode = application.oProductManager.getAllTypeCodes() />
		<cfset stAll.Settings = getSettingsObject() />
		
		<cfreturn stAll />
		
	</cffunction>
	
  <!--------------------------------------------------------------------------- 
    This function returns a list of market id below the user id provided
	Will have a blank value if HQ user
	Will have 0 if no markets below
  ----------------------------------------------------------------------------->
	<cffunction name="getBelowMarketIDList" output="false" access="remote" returntype="string">
		<cfargument name="userId" type="string" required="true" />
		
		<cfset var returnValue = "" />
		
		<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(arguments.userId, 0, 1) />
		
		<cfset HQUser = 0>
		<cfset HQPosition = CreateObject("component", "components.geography.position").getHQPosition() />
		<cfif listfind(UserPositionList, HQPosition.User_Positions_ID)>
			<cfset HQUser = 1>
		</cfif>
		
		<cfif HQUser eq 0>
			<cfquery name="qGetBelowMarkets" datasource="#application.datasource#" <!---cachedwithin="#APPLICATION.masterDataCacheSpan#"--->>
				SELECT 	DISTINCT Service_Market_ID
				FROM	Positions_Below_Me
				WHERE	User_Positions_ID IN (#PreserveSingleQuotes(UserPositionList)#)
				AND		Service_Market_ID IS NOT NULL
			</cfquery>
			<cfset returnValue = "0" />
			<cfif qGetBelowMarkets.recordCount>
				<cfset returnValue = ValueList(qGetBelowMarkets.Service_Market_ID) />
			</cfif>
		</cfif>
		
		<cfreturn returnValue />
	</cffunction>
	
  <!--------------------------------------------------------------------------- 
    This function returns all the Regions
  ----------------------------------------------------------------------------->
	<cffunction name="getAllRegions" output="false" access="public" returntype="Query">
		<cfquery name="qGetAllRegions" datasource="#application.datasource#" <!---cachedwithin="#APPLICATION.masterDataCacheSpan#"--->>
			SELECT 	*
			FROM 	Service_Regions
			WHERE 	Deleted = 0
			AND 	Region_Name <> ''
			ORDER BY Region_Name
		</cfquery>
		<cfreturn qGetAllRegions />
	</cffunction>	
	
  <!--------------------------------------------------------------------------- 
    This function returns all the Brokers
  ----------------------------------------------------------------------------->
	<cffunction name="getAllBrokers" output="false" access="public" returntype="Query">
		<cfquery name="qGetAllBrokers" datasource="#application.datasource#" <!---cachedwithin="#APPLICATION.masterDataCacheSpan#"--->>
			SELECT 	*
			FROM 	BSA_Foodservice_Brokers
			WHERE 	Deleted = 0
			AND		Active_Code = 'A'
			AND 	Broker_Name <> ''			
			ORDER BY Broker_Name
		</cfquery>
		<cfreturn qGetAllBrokers />
	</cffunction>	

</cfcomponent>