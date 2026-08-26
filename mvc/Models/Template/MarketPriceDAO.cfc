<cfcomponent name="MarketPriceDAO" hint="Data Access Object for Market Price" extends="mvc.Models.SettingsService">
	
	<cffunction name="setMPProgramApproval" returntype="void">
		<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfquery name="qUpdateMPProgramApproval" datasource="#application.datasource#">
			UPDATE Contract_Main_Aux_data
			SET Market_Price_Approved = 1,
				Market_Price_Approved_By = '#request.AccessStructure.user_id#',
				Market_Price_Approved_Date = getDate()
			WHERE  Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#">
		</cfquery>
		
	</cffunction>
	
	<cffunction name="getMPApprovals" returntype="Query" >
		<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfscript>
			var qGetMPApprovals = QueryNew('itemGuid');
		</cfscript>
		<cfquery name="qGetMPApprovals" datasource="#application.datasource#">
			SELECT	
					BSAFIM.BSA_Foodservice_Items_Master_ID AS itemGuid
			FROM	Program_Fixed_Price_Product_Data FPPD
			INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Fixed_Component_ID = FPPD.Program_Fixed_Component_ID
			INNER JOIN Program_Fixed_Component_Name FCN ON
					FCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = FPPD.Contract_Products_ID AND
					CP.Contract_Main_ID = FPPD.Program_ID
			INNER JOIN BSA_Foodservice_Items_Master BSAFIM ON 
					BSAFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			LEFT JOIN Market_Price_Program_Approvals MPPA_exist ON
					MPPA_exist.Contract_Main_Id = FPPD.Program_ID AND
					MPPA_exist.BSA_Foodservice_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_ID AND
					MPPA_Exist.Component_Name_Id = PFC.Program_Fixed_Component_Name_ID
			WHERE	FPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#">
			AND		FPPD.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		PFC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Product_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
			AND		MPPA_exist.Contract_Main_Id IS NULL
			AND		FPPD.Market_Price_Rate != 0
		</cfquery>
		<!--- <cfset this.dmp(qGetMPApprovals) /> --->
		<cfreturn qGetMPApprovals/>
	</cffunction>
	
	<cffunction name="insertMPApprovalVariances" returntype="void" >
		<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfargument name="bAuto" type="boolean" required="false" default="0"/>
		
		<!---<cfquery name="qInsertMPApprovalVariances" datasource="#application.datasource#">
			
			INSERT INTO Market_Price_Program_Approvals (
					Contract_Main_Id,
					BSA_Foodservice_Items_Master_ID,
					Variance,
					Component_Name_Id,
					User_Id
				)
			SELECT	DISTINCT	#arguments.ProgramId#,
					BSAFIM.BSA_Foodservice_Items_Master_ID AS itemGuid,
					(FPPD.Market_Price_Rate - FPPD.Fixed_Price_Value)/FPPD.Market_Price_Rate * 100 as MPVariance,
					PFC.Program_Fixed_Component_Name_ID,
					'#request.AccessStructure.user_id#'	
			FROM	Program_Fixed_Price_Product_Data FPPD
			INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Fixed_Component_ID = FPPD.Program_Fixed_Component_ID
			INNER JOIN Program_Fixed_Component_Name FCN ON
					FCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = FPPD.Contract_Products_ID AND
					CP.Contract_Main_ID = FPPD.Program_ID
			INNER JOIN BSA_Foodservice_Items_Master BSAFIM ON 
					BSAFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			LEFT JOIN Market_Price_Program_Approvals MPPA_exist ON
					MPPA_exist.Contract_Main_Id = FPPD.Program_ID AND
					MPPA_exist.BSA_Foodservice_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_ID AND
					MPPA_Exist.Component_Name_Id = PFC.Program_Fixed_Component_Name_ID
			WHERE	FPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#">
			AND		FPPD.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		PFC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Product_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
			AND 	MPPA_exist.Contract_Main_Id IS NULL
			AND		FPPD.Market_Price_Rate != 0
			<!--- if auto approve, we only approve items with a fixed price greater than or equal to MP rate --->
			<cfif bAuto>
				AND		FPPD.Fixed_Price_Value >= FPPD.Market_Price_Rate
			</cfif>
		</cfquery>--->
		<!---<cfset this.dmp(arguments.ProgramId) />
		<cfset this.dmp(request.AccessStructure.user_id) />
		<cfset this.dmp(arguments.bAuto) />--->
		<!--- Group capture uses the Same Logic from an SP --->
		<cfquery name="qInsertMPApprovalVariances" datasource="#application.datasource#">
			EXEC INSERT_MARKET_PRICE_APPROVAL_VARIANCES #arguments.ProgramId#,'#request.AccessStructure.user_id#',#arguments.bAuto#
		</cfquery>
	
	</cffunction>
	
	<cffunction name="getMaxMPProgramVariances" returntype="Query" >
		<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfargument name="iMPId" type="numeric" required="true"/>
		<cfscript>
			var qGetMaxMPProgramVariances = queryNew('MaxVariance');
		</cfscript>
		<cfquery name="qGetMaxMPProgramVariances" datasource="#application.datasource#">
			SELECT	ISNULL(MAX(CAST(((FPPD.Market_Price_Rate - FPPD.Fixed_Price_Value)/FPPD.Market_Price_Rate * 100) AS DECIMAL(10,2))),0) as MaxVariance
			FROM	Program_Fixed_Price_Product_Data FPPD
			INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Fixed_Component_ID = FPPD.Program_Fixed_Component_ID
			INNER JOIN Program_Fixed_Component_Name FCN ON
					FCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = FPPD.Contract_Products_ID AND
					CP.Contract_Main_ID = FPPD.Program_ID
			--INNER JOIN BSA_Foodservice_Items_Master BSAFIM ON 
			--		BSAFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
				LEFT JOIN Market_Price_List MP ON
					MP.Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iMPId#">
				LEFT JOIN Market_Price_Product_Rates MPR ON
					MP.Market_Price_List_Id = MPR.Market_Price_List_Id AND
					MPR.BSA_Foodservice_Items_Master_Id = CP.BSA_FoodService_Items_Master_ID
			WHERE	FPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#">
			AND		FPPD.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		PFC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Product_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
			AND		FPPD.Market_Price_Rate != 0
		</cfquery>
		<cfreturn qGetMaxMPProgramVariances />
	</cffunction>
<!---
	<cffunction name="" >
		<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfscript>
			//var oReturnObject = StructNew();
			//var objComponentManager	= CreateObject("component","mvc.Models.Program.Component.ComponentManager");
			//program.components[0].prodRate
		</cfscript>
	
	</cffunction> --->

</cfcomponent>