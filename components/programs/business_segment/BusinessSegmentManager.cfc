<!---
  * ====================================================================================================
  *    @File: \components\programs\business_segment\BusinessSegmentManager.cfc
  *  @Author: Unknown
  *    @Date: 2018-07-31 09:44:36
  *
  * @Remarks: Business segment manager component
  * ====================================================================================================
--->
<cfcomponent>
	<!------
	<cfset this.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
	 ----->
	<cfset qGetClassCodesOn = "" />
	<cffunction name="init" output="false" returntype="components.programs.business_segment.BusinessSegmentManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="getClassCodesOn" output="false" returntype="numeric">

		<cfset classCodesOn = 0 />
		<cfif NOT isQuery(qGetClassCodesOn)>
			<cfset useLakebaseForqGetClassCodesOn = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForqGetClassCodesOn>
	<cftry>
		<cfset qGetClassCodesOn = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "classcodes_on"
			}), "classcodes_on"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetClassCodesOn = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetClassCodesOn>
<cfquery name="qGetClassCodesOn" datasource="#application.datasource#">
				SELECT	Classcodes_On
				FROM	_Application_Settings
			</cfquery>
</cfif>
		</cfif>
		<cfset classCodesOn = qGetClassCodesOn.Classcodes_On />
		<cfreturn classCodesOn />

	</cffunction>

	<cffunction name="getOperatorlegacyIDOn" output="false" returntype="numeric">
		<cfargument name="programID" type="string" required="true" default="0" />

		<cfset var LegacyIdOn = application.returned_customer_setting.operator_legacy_id_on>
		<cfset var businessSegmentsOn = isEnabled() />
		<cfset var businessSegmentID = getBusinessSegmentID(arguments.programID) />

		<cfif businessSegmentsOn eq 1 and arguments.programID neq 0>
			<cfset OperatorBSFilter = get(businessSegmentID) />
			<cfset LegacyIdOn =  val(OperatorBSFilter.LegacyIdOn)>
		</cfif>

		<cfreturn LegacyIdOn>
	</cffunction>

	<cffunction name="getBusinessSegmentID" output="false" returntype="numeric">
		<cfargument name="programID" type="string" required="true" default="0" />

			<cfset useLakebaseForqGetBusinessSegmentID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetBusinessSegmentID>
	<cftry>
		<cfset qGetBusinessSegmentID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.programID#",
				"select" = "business_segment_id"
			}), "business_segment_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBusinessSegmentID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBusinessSegmentID>
<cfquery name="qGetBusinessSegmentID" datasource="#application.datasource#">
				SELECT	Business_Segment_ID
				FROM	Contract_Main
				WHERE Contract_Main_id = '#arguments.programID#'
			</cfquery>
</cfif>

		<cfreturn qGetBusinessSegmentID.Business_Segment_ID>
	</cffunction>

	<cffunction name="getDistChannelFromBusSeg" output="false" returntype="any">
		<cfargument name="businessSegmentID" type="string" required="true" default="0" />
			<cfset useLakebaseForqGetDistChannelID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForqGetDistChannelID>
	<cftry>
		<cfset qGetDistChannelID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment", {
				"business_segment_id" = "eq.#arguments.businessSegmentID#",
				"select" = "bs_var_2"
			}), "bs_var_2"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistChannelID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistChannelID>
<cfquery name="qGetDistChannelID" datasource="#application.datasource#">
				SELECT	BS_Var_2
				FROM	Business_segment
				WHERE Business_segment_Id = '#arguments.businessSegmentID#'
			</cfquery>
</cfif>

		<cfreturn qGetDistChannelID.BS_Var_2>
	</cffunction>

	<cffunction name="get" output="false" returntype="query">

		<cfargument name="busSegId" type="string" required="false" default="0" />

		<!---get the business segments--->
		<cfquery name="qGetBusinessSegments" datasource="#application.datasource#">

			SELECT 	*
			FROM 	Business_Segment
			WHERE	Deleted = 0
			AND		Business_Segment_ID in (#arguments.busSegId#)

		</cfquery>

		<!---if we don't get a record count then retrun a record with a No Segment description--->
		<cfif not qGetBusinessSegments.RecordCount>

			<cfscript>
				QueryAddRow(qGetBusinessSegments);
				QuerySetCell(qGetBusinessSegments, "Business_Unit_Desc", "No Segment");
			</cfscript>

		</cfif>

		<cfreturn qGetBusinessSegments />

	</cffunction>

<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION START--->
	<cffunction name="getAll" output="false" returntype="query">
		<!---get ALL business segments--->
		<cfquery name="qGetBusinessSegments" datasource="#application.datasource#">
			SELECT 	*
			FROM 	Business_Segment
			WHERE	Deleted = 0
		</cfquery>
		<cfreturn qGetBusinessSegments />
	</cffunction>
<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION END--->

	<cffunction name="getList" output="false" returntype="query">

		<cfargument name="busSegIdList" type="string" required="true" />

		<!---get the business segments--->
		<cfquery name="qGetBusinessSegments" datasource="#application.datasource#">

			SELECT 	Business_Segment_ID,
					Business_Unit_ID,
					Business_Unit_Desc,
					ISNULL(Company_Code_ID, '') AS Company_Code_ID,
					Product_BS_Filter,
					Customer_BS_Filter,
					Customer_Show_Broker,
					Operator_BS_Filter,
					LegacyIdOn
			FROM 	Business_Segment
			WHERE	Deleted = 0
			AND		Business_Segment_ID IN (#arguments.busSegIdList#)

		</cfquery>

		<!---if we don't get a record count then retrun a record with a No Segment description--->
		<cfif not qGetBusinessSegments.RecordCount>

			<cfscript>
				QueryAddRow(qGetBusinessSegments);
				QuerySetCell(qGetBusinessSegments, "Business_Unit_Desc", "No Segment");
			</cfscript>

		</cfif>

		<cfreturn qGetBusinessSegments />

	</cffunction>

	<cffunction name="getActive" output="false" returntype="query" access="remote">
		<cfargument name="userId" type="string" required="false" default="" />
		<cfargument name="filterTemplate" type="string" required="false" default="0" />

		<!---get active business segments--->
		<cfif getClassCodesOn()>
			<cfquery name="qGetActiveBusinessSegments" datasource="#application.datasource#">
				SELECT distinct	Business_Segment.Business_Segment_ID,
						Business_Segment.Business_Unit_ID,
						Business_Segment.Business_Unit_Desc,
						ISNULL(Company_Code_ID, '') AS Company_Code_ID,
						Business_Segment.Product_BS_Filter
				FROM 	Business_Segment
						<cfif arguments.userId NEQ "">
						INNER JOIN
	                      Class_Code ON Business_Segment.Business_Segment_ID = 	Class_Code.Business_Segment_ID INNER JOIN
	                      User_Class_Code ON Class_Code.Class_Code_ID = User_Class_Code.Class_Code_Id
						AND
						User_Class_Code.User_ID = '#arguments.userId#'
						AND
						User_Class_Code.Deleted = 0
						AND Class_Code.Deleted = 0
						AND	Class_Code.Active = 1
						</cfif>
						<cfif arguments.filterTemplate NEQ "0">
						INNER JOIN Template_Business_Segment ON
						Template_Business_Segment.Business_Segment_ID = Business_Segment.Business_Segment_ID AND
						Template_Business_Segment.Template_ID = #arguments.filterTemplate# AND
						Template_Business_Segment.Deleted = 0
						</cfif>
				WHERE	Business_Segment.Deleted = 0
				AND		Business_Segment.Active = 1
				ORDER BY Business_Segment.Business_Unit_Desc<!--- D29947"sort the business segments in alpha order from A to Z." --->
			</cfquery>
		<cfelse>
			<cfquery name="qGetActiveBusinessSegments" datasource="#application.datasource#">

				SELECT 	Business_Segment.Business_Segment_ID,
						Business_Segment.Business_Unit_ID,
						Business_Segment.Business_Unit_Desc,
						ISNULL(Company_Code_ID, '') AS Company_Code_ID

				FROM 	Business_Segment
						<cfif arguments.userId NEQ "">
						INNER JOIN User_Business_Segment
						ON
						User_Business_Segment.Business_Segment_ID = Business_Segment.Business_Segment_ID
						AND
						User_Business_Segment.User_ID = '#arguments.userId#'
						AND
						User_Business_Segment.Deleted = 0


						</cfif>
						<cfif arguments.filterTemplate NEQ "0">
						INNER JOIN Template_Business_Segment ON
						Template_Business_Segment.Business_Segment_ID = Business_Segment.Business_Segment_ID AND
						Template_Business_Segment.Template_ID = #arguments.filterTemplate# AND
						Template_Business_Segment.Deleted = 0
						</cfif>
				WHERE	Business_Segment.Deleted = 0
				AND		Business_Segment.Active = 1
				ORDER BY Business_Segment.Business_Unit_Desc<!--- D29947"sort the business segments in alpha order from A to Z." --->
			</cfquery>
		</cfif>

		<cfreturn qGetActiveBusinessSegments />

	</cffunction>

	<cffunction name="getInActive" output="false" returntype="query">

		<!---get inActive business segments--->
		<cfquery name="qGetInActiveBusinessSegments" datasource="#application.datasource#">

			SELECT 	Business_Segment_ID,
					Business_Unit_ID,
					Business_Unit_Desc,
					ISNULL(Company_Code_ID, '') AS Company_Code_ID,
					Product_BS_Filter
			FROM 	Business_Segment
			WHERE	Deleted = 0
			AND		Active = 0
			ORDER BY Business_Segment.Business_Unit_ID
		</cfquery>

		<cfreturn qGetInActiveBusinessSegments />

	</cffunction>

	<cffunction name="makeInActive" output="false">

		<cfargument name="busSegId" type="numeric" required="false" default="" />

		<!---return 0 if there is only only active business segment left and business segments are enabled--->
		<cfset rIsValid = 1 />

		<cfif this.getActive().RecordCount eq 1 and this.isEnabled()>
			<cfset rIsValid = 0 />
		</cfif>

		<cfif rIsValid>

			<!---inActivate business segment if allowed--->
			<cfset useLakebaseForqMakeInActive = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForqMakeInActive>
	<cftry>
		<cfset application.oLakebase.updateRows("business_segment",
			{
				"deleted" = "eq.0",
				"business_segment_id" = "eq.#arguments.busSegId#"
			},
			{
				"active" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqMakeInActive = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqMakeInActive>
<cfquery name="qMakeInActive" datasource="#application.datasource#">

				UPDATE	Business_Segment
				SET		Active = 0
				WHERE	Deleted = 0
				AND		Business_Segment_ID = #arguments.busSegId#

			</cfquery>
</cfif>

		</cfif>

		<cfreturn rIsValid />

	</cffunction>

	<cffunction name="makeActive" output="false">

		<cfargument name="busSegId" type="numeric" required="false" default="" />

		<!---get the business segments--->
		<cfquery name="qMakeInActive" datasource="#application.datasource#">

			UPDATE	Business_Segment
			SET		Active = 1
			WHERE	Deleted = 0
			AND		Business_Segment_ID = #arguments.busSegId#

		</cfquery>

	</cffunction>

	<cffunction name="save" output="true">

		<cfargument name="busSegId" type="numeric" required="false" default="" />
		<cfargument name="unitId" type="string" required="false" default="" />
		<cfargument name="unitDesc" type="string" required="false" default="" />
		<cfargument name="companyCodeId" type="string" required="false" default="" />

		<cfargument name="Variable_1" type="string" required="false" default="" />
		<cfargument name="Variable_2" type="string" required="false" default="" />
		<cfargument name="Variable_3" type="string" required="false" default="" />
		<cfargument name="Variable_4" type="string" required="false" default="" />
		<cfargument name="Variable_5" type="string" required="false" default="" />
		<cfargument name="Variable_6" type="string" required="false" default="" />


		<!---if we have an id then update, otherwise it's a new segment so insert--->

		<cfif arguments.busSegId>

			<!---update business segment desc--->
			<cfquery name="qUpdateBusinessSegment" datasource="#application.datasource#">

				UPDATE	Business_Segment
				SET		Business_Unit_ID = <cfqueryparam value="#trim(arguments.unitId)#" cfsqltype="CF_SQL_VARCHAR" />
							, Business_Unit_Desc = <cfqueryparam value="#trim(arguments.unitDesc)#" cfsqltype="CF_SQL_VARCHAR" />
							, Company_Code_ID = <cfqueryparam value="#trim(arguments.companyCodeId)#" cfsqltype="CF_SQL_VARCHAR" />
							, BS_Var_1  = <cfqueryparam value="#trim(arguments.Variable_1)#" cfsqltype="CF_SQL_VARCHAR" />
							, BS_Var_2  = <cfqueryparam value="#trim(arguments.Variable_2)#" cfsqltype="CF_SQL_VARCHAR" />
							, BS_Var_3  = <cfqueryparam value="#trim(arguments.Variable_3)#" cfsqltype="CF_SQL_VARCHAR" />
							, BS_Var_4  = <cfqueryparam value="#trim(arguments.Variable_4)#" cfsqltype="CF_SQL_VARCHAR" />
							, BS_Var_5  = <cfqueryparam value="#trim(arguments.Variable_5)#" cfsqltype="CF_SQL_VARCHAR" />
							, BS_Var_6  = <cfqueryparam value="#trim(arguments.Variable_6)#" cfsqltype="CF_SQL_VARCHAR" />
				WHERE	Deleted = 0
				AND		Business_Segment_ID = #arguments.busSegId#

			</cfquery>

		<cfelse>

			<!---insert business segment--->
			<cfquery name="qInsertBusinessSegment" datasource="#application.datasource#">
				SET NOCOUNT ON

				INSERT INTO	Business_Segment (Business_Unit_ID, Business_Unit_Desc, Company_Code_ID, BS_Var_1, BS_Var_2, BS_Var_3, BS_Var_4, BS_Var_5, BS_Var_6)
				VALUES
					(
						<cfqueryparam value="#trim(arguments.unitId)#" cfsqltype="CF_SQL_VARCHAR" />
					, <cfqueryparam value="#trim(arguments.unitDesc)#" cfsqltype="CF_SQL_VARCHAR" />
					, <cfqueryparam value="#trim(arguments.companyCodeId)#" cfsqltype="CF_SQL_VARCHAR" />
					, <cfqueryparam value="#trim(arguments.Variable_1)#" cfsqltype="CF_SQL_VARCHAR" />
					, <cfqueryparam value="#trim(arguments.Variable_2)#" cfsqltype="CF_SQL_VARCHAR" />
					, <cfqueryparam value="#trim(arguments.Variable_3)#" cfsqltype="CF_SQL_VARCHAR" />
					, <cfqueryparam value="#trim(arguments.Variable_4)#" cfsqltype="CF_SQL_VARCHAR" />
					, <cfqueryparam value="#trim(arguments.Variable_5)#" cfsqltype="CF_SQL_VARCHAR" />
					, <cfqueryparam value="#trim(arguments.Variable_6)#" cfsqltype="CF_SQL_VARCHAR" />
					)

				UPDATE	Business_Segment
				SET		Customer_BS_Filter = @@IDENTITY
				WHERE	Business_Segment_ID = @@IDENTITY

				SET NOCOUNT OFF
			</cfquery>

		</cfif>

	</cffunction>

	<cffunction name="getSegmentIdByProgram" output="false">

		<cfargument name="programId" type="numeric" required="false" default="0" />

		<!---get the business segments--->
		<cfset useLakebaseForqGetBusSegIdFromProgram = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetBusSegIdFromProgram>
	<cftry>
		<cfset qGetBusSegIdFromProgram = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#arguments.programId#",
				"select" = "business_segment_id"
			}), "business_segment_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBusSegIdFromProgram = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBusSegIdFromProgram>
<cfquery name="qGetBusSegIdFromProgram" datasource="#application.datasource#">

			SELECT 	Business_Segment_ID
			FROM 	Contract_Main
			WHERE	Contract_Main_ID = #arguments.programId#

		</cfquery>
</cfif>

		<cfreturn qGetBusSegIdFromProgram.Business_Segment_ID />

	</cffunction>

	<cffunction name="getEnabled" output="false" returntype="struct">

		<cfset stBusinessSegmentSettings = StructNew() />
		<cfset stBusinessSegmentSettings.Enabled = 0 />
		<cfset stBusinessSegmentSettings.DistributorEnabled = 0 />
		<cfset stBusinessSegmentSettings.ProductEnabled = 0 />
		<cfset stBusinessSegmentSettings.VendorEnabledType = 0 />
		<cfset stBusinessSegmentSettings.OperatorEnabled = 0 /><!--- D50739 --->
		<cfset stBusinessSegmentSettings.AutoPay_Segment_Enable = 0/><!--- 65015 :: Auto Pay by Segment START --->
		<cfset stBusinessSegmentSettings.Allow_Multiple_Segment = 0/><!--- 64860 :: Update Segments selection on programs --->
		<cfset stBusinessSegmentSettings.Allow_Segment_Change = 0/>
		<cfset stBusinessSegmentSettings.Budget_Segment_Enabled = 0/><!--- 77185 Budgets & Segment --->
		<cfset stBusinessSegmentSettings.Display_Segment_In_Billbacks = 0 />
		<cfset stBusinessSegmentSettings.Planner_Volume_Plan_Segment_Enable = 0 />
		<cfset stBusinessSegmentSettings.User_Segment_Filters_Autopay_Results = 0 />
		

		<cfif application.returned_customer_setting.business_segments_on eq 1>

			<!---check to see if business segments are enabled--->
			<cfset useLakebaseForqIsEnabled = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment_enabled")>
<cfif useLakebaseForqIsEnabled>
	<cftry>
		<cfset qIsEnabled = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment_enabled", {
				"deleted" = "eq.0",
				"select" = "enabled,distributor_enabled,product_enabled,vendor_enabled_type,operator_enabled,autopay_segment_enable,allow_multiple_segment,allow_segment_change,budget_segment_enabled,display_segment_in_billbacks,planner_volume_plan_segment_enable,user_segment_filters_autopay_results"
			}), "enabled,distributor_enabled,product_enabled,vendor_enabled_type,operator_enabled,autopay_segment_enable,allow_multiple_segment,allow_segment_change,budget_segment_enabled,display_segment_in_billbacks,planner_volume_plan_segment_enable,user_segment_filters_autopay_results"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqIsEnabled = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqIsEnabled>
<cfquery name="qIsEnabled" datasource="#application.datasource#">

				SELECT	Enabled, Distributor_Enabled, Product_Enabled, Vendor_Enabled_Type,Operator_Enabled, AutoPay_Segment_Enable, Allow_Multiple_Segment, Allow_Segment_Change,
						Budget_Segment_Enabled,Display_Segment_In_Billbacks,Planner_Volume_Plan_Segment_Enable,User_Segment_Filters_Autopay_Results
				FROM	Business_Segment_Enabled
				WHERE	Deleted = 0

			</cfquery>
</cfif>

			<!---set enabled if business segments are turned on in customer settings--->
			<cfif qIsEnabled.RecordCount and application.returned_customer_setting.business_segments_on eq 1>
				<cfset stBusinessSegmentSettings.Enabled = qIsEnabled.Enabled />
				<cfset stBusinessSegmentSettings.DistributorEnabled = qIsEnabled.Distributor_Enabled />
				<cfset stBusinessSegmentSettings.ProductEnabled = qIsEnabled.Product_Enabled />
				<cfset stBusinessSegmentSettings.VendorEnabledType = qIsEnabled.Vendor_Enabled_Type />
				<cfset stBusinessSegmentSettings.OperatorEnabled = qIsEnabled.Operator_Enabled /><!--- D50739--->
				<cfset stBusinessSegmentSettings.AutoPay_Segment_Enable = qIsEnabled.AutoPay_Segment_Enable/><!--- 65015 :: Auto Pay by Segment START --->
				<cfset stBusinessSegmentSettings.Allow_Multiple_Segment = qIsEnabled.Allow_Multiple_Segment/><!--- 64860 :: Update Segments selection on programs --->
				<cfset stBusinessSegmentSettings.Allow_Segment_Change = qIsEnabled.Allow_Segment_Change/><!--- 76383 :: Allow Segment to be changed on revise/copy/in Edit mode --->
				<cfset stBusinessSegmentSettings.Budget_Segment_Enabled = qIsEnabled.Budget_Segment_Enabled/><!--- 77185 Budgets & Segment --->
				<cfset stBusinessSegmentSettings.Display_Segment_In_Billbacks = qIsEnabled.Display_Segment_In_Billbacks/>
				<cfset stBusinessSegmentSettings.Planner_Volume_Plan_Segment_Enable = qIsEnabled.Planner_Volume_Plan_Segment_Enable />
				<cfset stBusinessSegmentSettings.User_Segment_Filters_Autopay_Results = qIsEnabled.User_Segment_Filters_Autopay_Results />
			</cfif>

		</cfif>

		<cfreturn stBusinessSegmentSettings />

	</cffunction>

	<cffunction name="isEnabled" output="false" returntype="boolean">

		<cfreturn getEnabled().Enabled />

	</cffunction>

<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION START--->
	<cffunction name="isEnabledForOperator" output="false" returntype="boolean">

		<cfreturn getEnabled().OperatorEnabled />

	</cffunction>
<!--- D50739 ::  CREATE OPERATOR:  ADD BUSINESS SEGMENT FOR SELECTION DURING OPERATOR CREATION END--->

	<cffunction name="isEnabledForDistributor" output="false" returntype="boolean">

		<cfreturn getEnabled().DistributorEnabled />

	</cffunction>

	<cffunction name="isEnabledForProduct" output="false" returntype="boolean">

		<cfreturn getEnabled().ProductEnabled />

	</cffunction>

	<cffunction name="isEnabledForVendorType" output="false" returntype="boolean">

		<cfreturn getEnabled().VendorEnabledType />

	</cffunction>

	<cffunction name="isEnabledForBudget" output="false" returntype="boolean">

		<cfreturn getEnabled().Budget_Segment_Enabled />

	</cffunction>

	<cffunction name="setEnabled" output="true">

		<cfargument name="enabledVal" required="false" default="0" />
		<cfargument name="enabledValDistributor" required="false" default="0" />
		<cfargument name="enabledValProduct" required="false" default="0" />
		<cfargument name="enabledValVendorType" required="false" default="0" />
		<cfargument name="enabledValOperator" required="false" default="0" />
		<cfargument name="enabledAutoPaySegment" required="false" default="0" />
		<cfargument name="enabledAllowMultipleSegment" required="false" default="0" />
		<cfargument name="enabledAllowSegmentChange" required="false" default="0" />
		<cfargument name="enabledBudgetSegment" required="false" default="0" />
		<cfargument name="enabledDisplaySegmentInBillbacks" required="false" default="0" />
		<cfargument name="enabledPlannerVolumePlan" required="false" default="0" />
		<cfargument name="enabledUserSegmentFiltersAutopayResults" required="false" default="0" />
		

		<cfif arguments.enabledVal eq 0>
			<cfset arguments.enabledValDistributor = 0 />
			<cfset arguments.enabledValProduct = 0 />
			<cfset arguments.enabledValVendorType = 0 />
			<cfset arguments.enabledAutoPaySegment = 0/>
			<cfset arguments.enabledAllowMultipleSegment = 0/>
			<cfset arguments.enabledAllowSegmentChange = 0/>
			<cfset arguments.enabledBudgetSegment = 0/>
			<cfset arguments.enabledDisplaySegmentInBillbacks = 0/>
			<cfset arguments.enabledPlannerVolumePlan = 0/>
			<cfset arguments.enabledUserSegmentFiltersAutopayResults = 0/>
			
		</cfif>
		<!---WE CANNOT ALLOW SEGMENT CHANGE WHEN SEGEMENT FOR DISTRIBUTOR, OPERATOR OR PRODUCT IS ENABLED --->
		<cfif arguments.enabledValProduct OR arguments.enabledValDistributor OR arguments.enabledValOperator>
			<cfset arguments.enabledAllowSegmentChange = 0>
		</cfif>

		<!---if we have a record set then update, otherwise insert--->
		<cfset useLakebaseForqCheckEnabled = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment_enabled")>
<cfif useLakebaseForqCheckEnabled>
	<cftry>
		<cfset qCheckEnabled = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment_enabled", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckEnabled = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckEnabled>
<cfquery name="qCheckEnabled" datasource="#application.datasource#">

			SELECT	*
			FROM	Business_Segment_Enabled

		</cfquery>
</cfif>

		<cfif qCheckEnabled.RecordCount>

			<cfquery name="qUpdateEnabled" datasource="#application.datasource#">
				UPDATE 	Business_Segment_Enabled
				SET		Enabled = #arguments.enabledVal#,
						Distributor_Enabled = #arguments.enabledValDistributor#,
						Product_Enabled = #arguments.enabledValProduct#,
						Vendor_Enabled_Type = #arguments.enabledValVendorType#,
						Operator_Enabled = #arguments.enabledValOperator#
						,AutoPay_Segment_Enable = #arguments.enabledAutoPaySegment#
						,Allow_Multiple_Segment = #arguments.enabledAllowMultipleSegment#
						,Allow_Segment_Change = #arguments.enabledAllowSegmentChange#
						,Budget_Segment_Enabled = #arguments.enabledBudgetSegment#
						,Display_Segment_In_Billbacks = #arguments.enabledDisplaySegmentInBillbacks#
						,Planner_Volume_Plan_Segment_Enable = #arguments.enabledPlannerVolumePlan#
						,User_Segment_Filters_Autopay_Results = #enabledUserSegmentFiltersAutopayResults#
			</cfquery>

		<cfelse>

			<cfquery name="qSetEnabled" datasource="#application.datasource#">

				INSERT INTO Business_Segment_Enabled
					(Enabled, Distributor_Enabled, Product_Enabled, Vendor_Enabled_Type,Operator_Enabled,AutoPay_Segment_Enable,Allow_Multiple_Segment,Allow_Segment_Change,
					Budget_Segment_Enabled,Display_Segment_In_Billbacks,Planner_Volume_Plan_Segment_Enable,User_Segment_Filters_Autopay_Results)
				VALUES
					(#arguments.enabledVal#, #arguments.enabledValDistributor#, #arguments.enabledValProduct#, #arguments.enabledValVendorType#, #arguments.enabledValOperator#,#arguments.enabledAutoPaySegment#,#arguments.enabledAllowMultipleSegment#,#arguments.enabledAllowSegmentChange#,
					#arguments.enabledBudgetSegment#,#enabledDisplaySegmentInBillbacks#,#arguments.enabledPlannerVolumePlan#,#arguments.enabledUserSegmentFiltersAutopayResults#)

			</cfquery>

		</cfif>


	</cffunction>

	<cffunction name="segmentsExist" output="false">

		<cfparam name="rVal" default="0" />

		<!---run query to see if any segments exist--->
		<cfset useLakebaseForqCheckExists = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("business_segment")>
<cfif useLakebaseForqCheckExists>
	<cftry>
		<cfset qCheckExists = application.oLakebase.toQuery(
			application.oLakebase.selectRows("business_segment", {
				"deleted" = "eq.0",
				"active" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckExists = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckExists>
<cfquery name="qCheckExists" datasource="#application.datasource#">

			SELECT	*
			FROM	Business_Segment
			WHERE	Deleted = 0
			AND		Active = 1

		</cfquery>
</cfif>

		<cfif qCheckExists.RecordCount>
			<cfset rVal = 1 />
		</cfif>

		<cfreturn rVal />

	</cffunction>

	<cffunction name="getActiveClasscodes" output="false" returntype="query">
		<cfargument name="userId" type="string" required="false" default="" />
		<cfargument name="returnAllClassCode" type="numeric" required="false" default="1" />
		<cfargument name="suppressGroups" required="false" default="0" />
		<cfargument name="filterTemplate" type="string" required="false" default="0" />

		<!---get active business segments--->
		<cfif getClassCodesOn()>
			<cfquery name="qGetActiveClasscodes" datasource="#application.datasource#">
				SELECT 	DISTINCT Class_Code.Class_Code,
						Class_Code.Class_Code_Desc,
						Class_Code.Class_Code_ID,
						Class_Code.Class_Code_UUID,
						Class_Code.Business_Segment_ID,
						Class_Code.External_Id,
						Business_Unit_Desc,
						Class_Code_UUID,
						Class_Code.Breakout_Percentage,
						<CFIF arguments.userId NEQ "">
						User_Class_Code.User_Class_Code_ID
						<CFELSE>
						1 AS User_Class_Code_ID
						</CFIF>
				FROM 	Class_Code
						<!---TSF - Label 11075: Check to see if there are any items for this group. If there are not then return nothing--->
						<cfif arguments.suppressGroups>
						INNER JOIN Product_Customer_Group ON Product_Customer_Group.Class_Code_UUID = Class_Code.Class_Code_UUID
						</cfif>
						INNER JOIN Business_Segment
						ON
						Business_Segment.Deleted = 0
						AND
						Business_Segment.Business_Segment_ID = Class_Code.Business_Segment_ID
						<cfif arguments.filterTemplate NEQ "0">
						INNER JOIN Template_Business_Segment ON
						Template_Business_Segment.Business_Segment_ID = Business_Segment.Business_Segment_ID AND
						Template_Business_Segment.Deleted = 0
						</cfif>
						<cfif arguments.userId NEQ "">
						<cfif arguments.returnAllClassCode>LEFT<cfelse>INNER</cfif>
						JOIN
	                    User_Class_Code ON Class_Code.Class_Code_ID = User_Class_Code.Class_Code_Id
						AND
						User_Class_Code.User_ID = '#arguments.userId#'
						AND
						User_Class_Code.Deleted = 0
						</cfif>
				WHERE Class_Code.Deleted = 0
						AND	Class_Code.Active = 1
						<cfif  isEnabled()>
								AND Business_Segment.Business_Segment_ID in 
								(
									SELECT Business_Segment_ID FROM User_Business_Segment WHERE User_ID = '#request.accessStructure.User_Id#'	
								)
						</cfif>
						ORDER BY Business_Segment.Business_Unit_Desc
			</cfquery>
		<cfelse>
			<cfquery name="qGetActiveClasscodes" datasource="#application.datasource#">
				SELECT 	DISTINCT Business_Segment.Business_Unit_Desc, Business_Segment.Business_Segment_ID,
				<CFIF len(arguments.userId) GT 0>
						User_Business_Segment.User_Business_Segment_ID
				<CFELSE>
				1 AS User_Business_Segment_ID
				</CFIF>
				FROM 	Business_Segment
				<CFIF len(arguments.userId) GT 0>
					<cfif arguments.returnAllClassCode>LEFT<cfelse>INNER</cfif>
					 JOIN User_Business_Segment
					ON User_Business_Segment.Business_Segment_ID = Business_Segment.Business_Segment_ID
					AND User_Business_Segment.User_ID = '#arguments.userId#'
					AND User_Business_Segment.Deleted = 0
				</CFIF>
				<cfif arguments.filterTemplate NEQ "0">
				INNER JOIN Template_Business_Segment ON
				Template_Business_Segment.Business_Segment_ID = Business_Segment.Business_Segment_ID AND
				Template_Business_Segment.Deleted = 0
				</cfif>
				where Business_Segment.deleted = 0
				AND Business_Segment.Active = 1
				<cfif  isEnabled()>
						AND Business_Segment.Business_Segment_ID in 
						(
							SELECT Business_Segment_ID FROM User_Business_Segment WHERE User_ID = '#request.accessStructure.User_Id#'	
						)
				</cfif>
				ORDER BY Business_Segment.Business_Unit_Desc
			</cfquery>
		</cfif>
		<cfreturn qGetActiveClasscodes />

	</cffunction>

	<cffunction name="getClasscode" output="false" returntype="query">
		<cfargument name="id" type="numeric" required="false" default="0" />

		<!---get the class codes--->
		<cfset useLakebaseForqGetClasscodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("class_code")>
<cfif useLakebaseForqGetClasscodes>
	<cftry>
		<cfset qGetClasscodes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("class_code", {
				"deleted" = "eq.0",
				"class_code_id" = "eq.#arguments.id#",
				"select" = "class_code_id,class_code,class_code_desc,class_code_uuid,business_segment_id,external_id"
			}), "class_code_id,class_code,class_code_desc,class_code_uuid,business_segment_id,external_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetClasscodes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetClasscodes>
<cfquery name="qGetClassCodes" datasource="#application.datasource#">

			SELECT 	Class_Code_ID,
					Class_Code,
					Class_Code_Desc,
					Class_Code_UUID,
					Business_Segment_ID,
					External_Id
			FROM 	Class_Code
			WHERE	Deleted = 0
			AND		Class_Code_ID = #arguments.id#

		</cfquery>
</cfif>

		<!---if we don't get a record count then retrun a record with a No Segment description--->
		<cfif not qGetClassCodes.RecordCount>

			<cfscript>
				QueryAddRow(qGetClassCodes);
				QuerySetCell(qGetClassCodes, "Class_Code_Desc", "No Class Code");
			</cfscript>

		</cfif>

		<cfreturn qGetClassCodes />

	</cffunction>

	<cffunction name="getClassCodes" output="false" returntype="query">
		<cfargument name="uuIDList" type="string" required="false" default="0" />

		<!---get the class codes--->
		<cfquery name="qGetClasscodes" datasource="#application.datasource#">

			SELECT 	Class_Code_ID,
					Class_Code,
					Class_Code_Desc,
					Class_Code_UUID,
					Business_Segment_ID,
					Materials_For_Settlement
			FROM 	Class_Code
			WHERE	Deleted = 0
			<cfif arguments.uuIDList NEQ "">
			AND		Class_Code_UUID IN (<cfqueryparam list="Yes" value="#arguments.uuIDList#" cfsqltype="CF_SQL_VARCHAR" />)
			</cfif>

		</cfquery>

		<cfreturn qGetClasscodes />

	</cffunction>

	<cffunction name="getClassCodeIDList" output="false" returntype="string">
		<cfargument name="uuIDList" type="string" required="false" default="0" />

		<!---get the class codes--->
		<cfset qGetClasscodes = getClassCodes(arguments.uuIDList) />

		<cfreturn ValueList(qGetClasscodes.Class_Code_ID) />

	</cffunction>

	<cffunction name="saveClassCode" output="false">

		<cfargument name="id" type="numeric" required="false" default="" />
		<cfargument name="classCodeId" type="string" required="false" default="" />
		<cfargument name="classCodeDesc" type="string" required="false" default="" />
		<cfargument name="businessSegmentId" type="numeric" required="true" />
		<cfargument name="materialsForSettlement" type="String" required="false" default="" />

		<cfset var rClassCodeId = 0 />
		<!---if we have an id then update, otherwise it's a new class code so insert--->

		<cfif arguments.id>

			<!---update class code desc--->
			<cfquery name="qUpdateClassCode" datasource="#application.datasource#">

				UPDATE	Class_Code
				SET		Class_Code = <cfqueryparam value="#trim(arguments.classCodeId)#" cfsqltype="CF_SQL_VARCHAR" />,
						Class_Code_Desc = <cfqueryparam value="#trim(arguments.classCodeDesc)#" cfsqltype="CF_SQL_VARCHAR" />,
						Business_Segment_ID = <cfqueryparam value="#trim(arguments.businessSegmentId)#" cfsqltype="CF_SQL_INTEGER" />,
				        External_Id = <cfqueryparam value="#trim(arguments.materialsForSettlement)#" cfsqltype="CF_SQL_VARCHAR" />
				WHERE	Deleted = 0
				AND		Class_Code_ID = #arguments.id#

			</cfquery>

		<cfelse>

			<!---insert Class Code --->
			<cfquery name="qInsertBusinessSegment" datasource="#application.datasource#">

				INSERT INTO	Class_Code
					(Class_Code, Class_Code_Desc, Business_Segment_ID, External_Id)
				VALUES
					(
						<cfqueryparam value="#trim(arguments.classCodeId)#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#trim(arguments.classCodeDesc)#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#trim(arguments.businessSegmentId)#" cfsqltype="CF_SQL_INTEGER" />,
						<cfqueryparam value="#trim(arguments.materialsForSettlement)#" cfsqltype="CF_SQL_VARCHAR" />
					)

				SELECT @@IDENTITY AS Class_Code_ID
			</cfquery>

			<cfset rClassCodeId = qInsertBusinessSegment.Class_Code_ID />

		</cfif>

		<cfreturn rClassCodeId />

	</cffunction>

	<cffunction name="saveClassCodeBudgetPercentage" output="false" returntype="void">

		<cfargument name="objForm" required="true" type="struct" />

		<cfset qGetClassCodes = getActiveClasscodes() />

		<cftransaction action="BEGIN" isolation="READ_COMMITTED">

		<cftry>

			<cfloop query="qGetClassCodes">

				<cfset newPercentage = Evaluate("arguments.objForm.Breakout_Percentage_#Class_Code_ID#") />
				<cfquery name="qUpdatePercentage" datasource="#application.datasource#">
					UPDATE	Class_Code
					SET		Breakout_Percentage = #newPercentage#
					WHERE	Class_Code_ID = #Class_Code_ID#
				</cfquery>

			</cfloop>


			<cftransaction action="COMMIT" />

			<cfcatch>

				<cftransaction action="ROLLBACK" />

				<cfrethrow />

			</cfcatch>

		</cftry>

		</cftransaction>


	</cffunction>

	<!---get business segment/template combinations --->
	<cffunction name="getBusinessSegmentTemplateSettings" output="false" returntype="query">
		<cfargument name="templateId" type="numeric" required="false" default="0" />

		<!---get business segments for the given template--->
		<cfquery name="qGetTemplateBusinessSegments" datasource="#application.datasource#">
			SELECT 	Template_ID,
					Business_Segment_ID
			FROM 	Template_Business_Segment
			WHERE	Deleted = 0
			AND		Template_ID = <cfqueryparam value="#arguments.templateId#" cfsqltype="cf_sql_integer">
		</cfquery>

		<cfreturn qGetTemplateBusinessSegments />

	</cffunction>

	<!---add business segment/template combinations --->
	<cffunction name="addBusinessSegmentTemplateSettings" output="false">
		<cfargument name="oldTemplateId" 			type="numeric" 	required="false" 	default="0" />
		<cfargument name="newTemplateId" 			type="numeric" 	required="false" 	default="0" />
		<cfargument name="lBusinessSegments" 		type="any" 		required="no" 		default="" />

		<!---loop over list of templates and add business segments for the given template--->
		<cfloop list="#arguments.lBusinessSegments#" index="businessSegmentIndex">
			<cfquery name="qInsertTemplateBusinessSegments" datasource="#application.datasource#">
				INSERT INTO Template_Business_Segment
					(Template_ID, Business_Segment_ID)
				VALUES
					(<cfqueryparam value="#arguments.newTemplateId#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#businessSegmentIndex#" cfsqltype="cf_sql_integer">)
			</cfquery>
		</cfloop>
	</cffunction>

	<!---update business segment/template combinations --->
	<cffunction name="updateBusinessSegmentTemplateSettings" output="false">
		<cfargument name="TemplateId" 			type="numeric" 	required="false" 	default="0" />
		<cfargument name="lBusinessSegments" 		type="any" 		required="no" 		default="" />

		<cfquery name="qDeleteTemplateBusinessSegments" datasource="#application.datasource#">
				Update	Template_Business_Segment
				SET 	Deleted = 1
				WHERE	Template_ID = <cfqueryparam value="#arguments.TemplateId#" cfsqltype="cf_sql_integer">
				AND 	Deleted = 0
		</cfquery>

		<!---loop over list of templates and add business segments for the given template--->
		<cfloop list="#arguments.lBusinessSegments#" index="businessSegmentIndex">
			<cfquery name="qInsertTemplateBusinessSegments" datasource="#application.datasource#">
				INSERT INTO Template_Business_Segment
					(Template_ID, Business_Segment_ID)
				VALUES
					(<cfqueryparam value="#arguments.TemplateId#" cfsqltype="cf_sql_integer">, <cfqueryparam value="#businessSegmentIndex#" cfsqltype="cf_sql_integer">)
			</cfquery>
		</cfloop>
	</cffunction>

	<cffunction name="copy_existing_segment" output="false">
		<cfargument name="existing_segment_id" type="numeric" required="true">

		<cfquery name="local.new_segment" datasource="#application.datasource#">
			SET NOCOUNT ON

			INSERT INTO Business_Segment
						(Business_Unit_ID,
						Business_Unit_Desc,
						Company_Code_ID,
						BS_Var_1,
						BS_Var_2,
						BS_Var_3,
						BS_Var_4,
						BS_Var_5,
						BS_Var_6)
			SELECT 	Business_Unit_ID,
					Business_Unit_Desc + ' (COPY)' AS Business_Unit_Desc,
					Company_Code_ID,
					BS_Var_1,
					BS_Var_2,
					BS_Var_3,
					BS_Var_4,
					BS_Var_5,
					BS_Var_6
			FROM   Business_Segment
			WHERE  Business_Segment_ID = #arguments.existing_segment_id#

			SELECT @@IDENTITY AS business_segment_id
		</cfquery>

		<cfreturn local.new_segment.business_segment_id>
	</cffunction>

	<cffunction name="getUploadBusinessSegments" output="false" returntype="query" access="remote">
		
		<cfquery name="qGetActiveBusinessSegments" datasource="#application.datasource#">
			SELECT	DISTINCT Business_Segment.Business_Segment_ID,
					Business_Segment.Business_Unit_ID,
					Business_Segment.Business_Unit_Desc
			FROM 	Business_Segment
					INNER JOIN Template_Business_Segment ON
					Template_Business_Segment.Deleted = 0 
					AND Template_Business_Segment.Business_Segment_ID = Business_Segment.Business_Segment_ID
					INNER JOIN Program_Control_Panel_Options on Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Template_Business_Segment.Template_ID
					AND Program_Control_Panel_Options.Include_Program_Upload_Template_List = 1
			WHERE	Business_Segment.Deleted = 0
			AND		Business_Segment.Active = 1
			ORDER BY Business_Segment.Business_Unit_Desc
		</cfquery>
	

		<cfreturn qGetActiveBusinessSegments />

	</cffunction>
	
</cfcomponent>