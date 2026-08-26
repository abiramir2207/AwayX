

<cfcomponent name="BrokerSearchService" displayname="BrokerSearchService" hint="Search Brokers">
	<cfset appSettings = application.appSettingsGet />
	<cffunction name="getBrokers" hint="return all Brokers" access="remote" output="false" returntype="query">
		<cfargument name="ProgramId" default="0">
		<cfset var businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
		<cfset var qGetBrokers =  queryNew('tmp') />
		<cfset var i = 0/>
		<cfset var busSegIdForProgram = 0 />
		<cfif businessSegManager.isEnabled()>
			<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(arguments.programId) />
		</cfif>
		<!--- <cfset var lCount = 25 /> --->
		<!--- <cfset structdelete(SESSION,"qGetBrokers") /> --->
			   <!--- <cfif not isdefined("session.qGetBrokers")> --->
				<CFQUERY NAME="qGetBrokers" datasource="#application.datasource#">
					
					SELECT
						isnull(rtrim(ltrim(BFB.Broker_Shard)),'')	AS baItem,
						BFB.BSA_Foodservice_Brokers_ID				AS distGuid,
		  					isnull(rtrim(ltrim(BFB.Broker_Name)),'') AS Description,
		  					isnull(rtrim(ltrim(BFB.Address)),'') 	+ ', ' + 
		  					isnull(rtrim(ltrim(BFB.City)),'') 		+ ' ' + 
		  					isnull(rtrim(ltrim(BFB.State)),'')  	+ ' ' + 
		  					isnull(rtrim(ltrim(BFB.Zip)),'')   	+ ' ' + 
		  					isnull(rtrim(ltrim(BFB.country_code)),'') 
		  															AS Address,
		  				isnull(rtrim(ltrim(replace(SZ.Zone_Name,'/','-'))),'') AS col1,
		  				isnull(rtrim(ltrim(SR.Region_Name)),'') 		AS col2,
		  				isnull(rtrim(ltrim(BFB.State)),'') 				AS col3,
		  				isnull(rtrim(ltrim(BFB.City)),'')   				AS col4,
		  				isnull(rtrim(ltrim(Active_Code)),'N') AS col5,
		  				'' AS col6,
		  				'' AS col7,
		  				CASE 
			 			WHEN CB.Contract_Main_ID > 0 THEN
			 			 	1 
			 			ELSE
			 			 	0
			 			END
			 			AS isSelected
		
					FROM BSA_Foodservice_Brokers BFB
					LEFT JOIN Contract_Brokers CB
						ON CB.BSA_Foodservice_Brokers_ID = BFB.BSA_Foodservice_Brokers_ID
						AND CB.Contract_Main_ID = '#arguments.programId#'
						AND CB.Deleted = 0
					LEFT JOIN Service_Markets SM
						ON SM.Service_Market_ID = BFB.Service_Market_ID
						AND	SM.Deleted = 0
					LEFT JOIN	Service_Regions SR
						ON BFB.Service_Region_ID = SR.Service_Region_ID
						AND	SR.Deleted = 0
					LEFT JOIN	Service_Zones SZ
						ON SR.Service_Zone_ID = SZ.Service_Zone_ID
						AND	SZ.Deleted = 0
					WHERE 	BFB.Deleted = 0
						<cfif busSegIdForProgram neq 0 and busSegIdForProgram neq "">
					--AND BFB.Business_Segment_ID = #busSegIdForProgram#
						</cfif>
						 <!--- <cfif i NEQ lCount>UNION</cfif> --->
					<!--- </cfloop> --->
				  </CFQUERY>
				 
				   <!--- <cfset session.qGetBrokers = qGetBrokers>  --->
			  <!--- </cfif> --->
			  <!--- <cfreturn var_qGetItems /> --->
			<cfreturn qGetBrokers />
			
	</cffunction>


	
	<cffunction name="searchSettings" returntype="String">
		<cfargument name="ProgramId" default="0">
		
		<cfset var x = 0 />
		<cfset var GetSettings = "" />
		<cfset var programManager	 = "" />
		<cfset var = "" />
		<!--- <cfset var = "" />
		<cfset var = "" />
		<cfset var = "" />
		<cfset var = "" /> --->
		
		<CFIF arguments.ProgramId NEQ 0 AND LEN(trim(arguments.ProgramId)) NEQ 0>
			<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
			<cfset programInfo = programManager.getProgramInfo(arguments.ProgramId)>
		
			<cfquery name="GetSettings" datasource="#application.datasource#">
				SELECT PCPO.Discount_Rebates_Group_Level,
						exclude_sig_products,
						modifying_program,
						EZButton_On,EZ_Contract_Id
				FROM Contract_Main
					INNER JOIN	Program_Control_Panel_Options PCPO
					ON (Contract_Main.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID)
				WHERE Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">
			</cfquery>
		</CFIF>
		 
		 <cfsavecontent variable="sProdSearchClause">
			 
			
		 </cfsavecontent>
		 <cflog text="#sProdSearchClause#">
		 <cfreturn sProdSearchClause />
	</cffunction>
	
	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfargument name="programId" default="0">

		<cfset var obj = "" />
		<cfset var stSettings = StructNew()/>

		<!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data--->
		<cfset obj = createobject("component", "mvc.models.SettingsService") />
		<cfset stSettings.user = StructNew()/>
		<!--- <cfset stSettings.user = obj.getUserObject(arguments.userId) /> --->
		
		<!--- return application.appSettingsGet as a structure with keys named the same as the appsettings methods--->
		<cfset stSettings.appSettings = StructNew()/>

		<cfset structinsert(stSettings.appSettings,"Exact_List_Matching_On",appSettings.Exact_List_Matching_On)>
		<!--- This is not required --->
		<!---
		<cfset stSettings.appSettings = obj.getAppSettingsObject() />
		--->
		<!--- UI Attribute Properties --->
		<cfset stsettings.uiAttributes = StructNew() />
		<cfset stsettings.uiAttributes = obj.getUIAttributes()> 
		
		<!--- Column Headers & Labels --->
		<cfset stSettings.appFlex = StructNew() />
		<cfset stSettings.appFlex.brokerLabel = "#application.returned_customer_setting.broker_label_singular#" />	<!--- broker --->
		<cfset stSettings.appFlex.col1 = "#application.returned_customer_setting.zone_label_singular#" />	<!--- Zone --->
		<cfset stSettings.appFlex.col2 ="#application.returned_customer_setting.region_label_singular#" />	<!--- Region --->
		<cfset stSettings.appFlex.col3 ="State" />	<!--- STATE --->
		<cfset stSettings.appFlex.col4 = "City"/>	<!--- CITY --->
		<cfset stSettings.appFlex.col5 = "Active"/>	<!--- ACTIVE CODE --->
		<cfset stSettings.appFlex.col6 = "NA"/>		<!--- EMPTY --->
		
		<cfreturn stSettings>
	</cffunction>
</cfcomponent>
