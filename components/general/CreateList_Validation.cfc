<cfcomponent displayname="Retrieve Information for Create List Validation" hint="Create List">
	<cfproperty name="DataToBeValidated" 		type="string"/>
	<cfproperty name="DataValidationInfo" 		type="struct"/>

	<!--- Constructor --->
	<cfscript>
		this.DataValidationInfo = StructNew();
		this.DataValidationInfo.ValidData = ArrayNew(1);
		this.DataValidationInfo.InValidData = ArrayNew(1);
		this.DataValidationInfo.DuplicateData = ArrayNew(1);
		this.DataValidationInfo.ValidListData = ArrayNew(1);
	</cfscript>
	<!--- /Constructor --->

	<cffunction name="getDataValidationInfo" access="public" returntype="struct">
		<cfargument name="PassedObject" type="array" required="true">
		<cfargument name="thisObject" type="string" required="true">
		<cfargument name="match_type" type="string" required="false" default="">   <!--- 57142 --->
		<cfargument name="Program_ID" type="numeric" required="false" default="0">
		<cfargument name="fromPrgUpload" type="numeric" required="false" default="0">
	  	<cfargument name="tablename" type="string" required="false">
		<cfargument name="discountype" type="numeric" required="false" default="0">

		<cfset useLakebaseForcheckTemplateSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main") AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForcheckTemplateSettings>
	<cftry>
		<cfset checkTemplateSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("contract_main", {
				"contract_main_id" = "eq.#arguments.Program_ID#",
				"select" = "programtype_id"
			}, "programtype_id", "program_control_panel_options", "programcontrol_panel_options_id", "discount_fixed_group_level,discount_fixed_item_level,discount_rebates_group_level,discount_rebates_item_level"), "programtype_id,discount_fixed_group_level,discount_fixed_item_level,discount_rebates_group_level,discount_rebates_item_level"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckTemplateSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckTemplateSettings>
<cfquery name="checkTemplateSettings" datasource="#application.datasource#">
			SELECT PCPO.Discount_Rebates_Item_Level,  PCPO.Discount_Rebates_Group_Level , PCPO.Discount_Fixed_Group_Level, PCPO.Discount_Fixed_Item_Level, CM.ProgramType_ID
			FROM Contract_Main CM
			INNER JOIN Program_Control_Panel_Options PCPO
			ON PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			WHERE CM.Contract_Main_ID = #arguments.Program_ID#
		</cfquery>
</cfif>

		<cfset profile = CreateObject("component","components.user.Profile").init() />
		<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>

		<cfif  arguments.thisObject EQ 'PRODUCTGROUP'>
			<cfquery name="create_temp_table" datasource="#application.datasource#">
					IF object_id('tempdb..##ProductGroupList') IS NOT NULL
					BEGIN
					DROP TABLE ##ProductGroupList
					END
					CREATE TABLE ##ProductGroupList(
						[Group_Level_Desc] [varchar](max),
						[Product_Group_ID] [varchar](max),
						[Group_ID] [varchar](max),
						[Product_Group_Level_ID] [varchar](max),
						[Product_Group_Level_Type] [varchar](max),
						[Hierarchy_Level] [varchar](max),
						[Parent_Hierarchy_ID] [varchar](max)
					)
			</cfquery>
		</cfif>

		<cfloop index="i" from="1" to="#ArrayLen(PassedObject)#" step="1">
			<cfset this.DataToBeValidated = #arguments.PassedObject[i]# />
			<cfset ValidateData(this.DataToBeValidated, arguments.thisObject, arguments.match_type, arguments.Program_ID, arguments.fromPrgUpload,arguments.tablename,arguments.discountype,checkTemplateSettings,Get_Profile_Settings) />   <!--- 57142 --->
		</cfloop>
		<cfif  arguments.thisObject EQ 'PRODUCTGROUP'>
			<cfquery name="temptabledump" datasource="#application.datasource#">
				SELECT * FROM ##ProductGroupList
			</cfquery>
		</cfif>

		<cfreturn this.DataValidationInfo>
	</cffunction>

	<cffunction name="ValidateData" access="public" returntype="string">
		<cfargument name="InputObject" type="string" required="true">
		<cfargument name="thisObject" type="string" required="true">
		<cfargument name="match_type" type="string" required="false" default="">   <!--- 57142 --->
		<cfargument name="Program_ID" type="numeric" required="false" default="0">
		<cfargument name="fromPrgUpload" type="numeric" required="false" default="0">
		<cfargument name="tablename" type="string" required="false">
		<cfargument name="discountype" type="numeric" required="false" default="0">
		<cfargument name="checkTemplateSettings" type="query" required="true">
		<cfargument name="Get_Profile_Settings" type="query" required="true">

		<cfset checkTemplateSettings = arguments.checkTemplateSettings />
		<cfset Get_Profile_Settings = arguments.Get_Profile_Settings />

		<cfset var vars = structnew()>
		<!--- check for duplicate input --->
		<cfif ListFind(ArrayToList(this.Get(), ","), InputObject)>
      <cfif arguments.fromPrgUpload>
        <cfquery name="variables.Update_tempdb_Duplicates" datasource="#application.datasource#">
          IF OBJECT_ID('tempdb..#tablename#') IS NOT NULL
					BEGIN
            UPDATE #arguments.tablename#
            SET Invalid = 1,  valid = 0, Reason = CONCAT (Reason, 'Duplicate item')
            WHERE Products_ID = '#arguments.InputObject#'
         	END
        </cfquery>
      </cfif>
			<cfset Set("Duplicate",  arguments.InputObject)/>
			<cfreturn>
		</cfif>

		<!--- check for the wild character --->
		<!--- <cfset foundPos = findoneof("@%^*()$##_-+=|\/&!`~,?:",InputObject) /> --->
		<cfset foundPos = findoneof("@%^*()$##+=|\/&!`~,?:",InputObject) />
		<cfif foundPos GT 0>
			<cfif arguments.fromPrgUpload>
				<cfquery name="variables.Update_tempdb_Duplicates" datasource="#application.datasource#">
					IF OBJECT_ID('tempdb..#tablename#') IS NOT NULL
					BEGIN
    				UPDATE #arguments.tablename#
    				SET Invalid = 1,  valid = 0, Reason = CONCAT (Reason, 'Product Formatting Error')
    				WHERE Products_ID = '#arguments.InputObject#'
  				END
				</cfquery>
			</cfif>
			<cfset Set("Invalid",  arguments.InputObject)/>
			<cfreturn>
		</cfif>

		<cfquery name="qGetFirstParentID" datasource="#application.datasource#">
			SELECT PCPO.First_Parent_ID AS FirstParentID, Planner_ID FROM contract_main CM
			INNER JOIN dbo.Program_Control_Panel_Options PCPO ON PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
			WHERE CM.Contract_Main_ID =  #arguments.Program_ID#
		</cfquery>

		<!--- check to see if it's existing in the database --->
<cfif  arguments.thisObject EQ 'PRODUCT'>
	<cfif (arguments.Program_ID NEQ 0 AND arguments.Program_ID NEQ "")>
		<cfset stStruct.Item_Number = arguments.InputObject />
		<cfset stStruct.itemList = arguments.InputObject />
		<cfset stStruct.Program_ID = arguments.Program_ID />
		<cfset stStruct.CalledFrom = "createList" />

        <cfset stStruct.match_type = arguments.match_type>

		<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
	  	<cfset qGetProductGroupAttributesGroupTemplate = ProductGroupAttributeManager.getProductGroupAttributesGroupTemplate(active=1,FirstParentID=qGetFirstParentID.FirstParentID) />
		<cfset stStruct.qGetProductGroupAttributesGroupTemplate = qGetProductGroupAttributesGroupTemplate />
		<cfset stStruct.FirstParentID =  qGetFirstParentID.FirstParentID />

		<cfset stStruct.plannerID = qGetFirstParentID.Planner_ID>
		<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
		<cfset searchProducts = productManager.search(search = stStruct, useCache = 1)>
	</cfif>

	<CFQUERY NAME="getItems" DATASOURCE="#application.datasource#">
		SELECT DISTINCT
		    dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
		    dbo.BSA_Foodservice_Items_Master.Description,
		    dbo.BSA_Foodservice_Items_Master.UPC,
		    dbo.BSA_Foodservice_Items_Master.Item,
		    dbo.BSA_Foodservice_Items_Master.Item as InputObjectMatchedItem,
		    dbo.Type_Code_Desc.Type_Code_Desc,
		    dbo.Brand.Brand_Name,
		    Q_Brand_Table.Q_Brand_ID,
		    dbo.Type_Group_Desc.Type_Group_Desc
		    ,0 AS Product_Group_Level_ID
			,0 AS IsGroup
			,dbo.BSA_Foodservice_Items_Master.Active_Code, dbo.BSA_Foodservice_Items_Master.Deleted
		FROM    dbo.BSA_Foodservice_Items_Master
		INNER JOIN 	Line_Of_Business
		ON Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID
		INNER JOIN	dbo.Type_Code_Desc
		ON dbo.BSA_Foodservice_Items_Master.Type_Code_Desc_ID = dbo.Type_Code_Desc.Type_Code_Desc_ID
		INNER JOIN	dbo.Brand
		ON dbo.BSA_Foodservice_Items_Master.Brand_ID = dbo.Brand.Brand_ID
	<cfif application.returned_customer_setting.use_product_q_brand EQ 1>
	  INNER JOIN	Product_Q_Brand_Desc
	  ON 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID
	  AND Product_Q_Brand_Desc.LOB = Line_Of_Business.Line_Of_Business
	  INNER JOIN	Q_Brand_Desc Q_Brand_Table
	  ON 	Product_Q_Brand_Desc.Q_Brand_ID = Q_Brand_Table.Q_Brand_ID
	<cfelse>
	  INNER JOIN	Q_Brand_Desc Q_Brand_Table
	  ON BSA_Foodservice_Items_Master.Q_Brand_ID = Q_Brand_Table.Q_Brand_ID
	</cfif>
	  INNER JOIN	dbo.Type_Group_Desc
	  ON dbo.BSA_Foodservice_Items_Master.Type_Group_Desc_ID = dbo.Type_Group_Desc.Type_Group_Desc_ID
		WHERE 0=0
	  AND BSA_Foodservice_Items_Master.Deleted = 0
	<cfif Get_Profile_Settings.Search_Inactive_Products_Programs eq 0>
	  AND BSA_Foodservice_Items_Master.Active_Code = 'A'
	</cfif>
	<cfif (arguments.Program_ID NEQ 0 AND arguments.Program_ID NEQ "")>
		<cfif (isDefined("searchProducts") AND searchProducts.Recordcount GTE 1)>
	 		<cfif application.returned_customer_setting.upc_switch EQ 1 AND application.appSettingsget.get_Setting('Display_Item_No') eq ''>
		  	 	AND	BSA_Foodservice_Items_Master.UPC
		  	<cfelse>
		  		AND BSA_Foodservice_Items_Master.Item
		  	</cfif>
			IN ( <cfqueryparam value="#ValueList(searchProducts.Item)#" list="true" cfsqltype="cf_sql_varchar"> )
		<cfelse>
		and 1=0
	 	</cfif>
	<cfelse>
		  AND (
		  	<cfif application.returned_customer_setting.upc_switch EQ 1 AND application.appSettingsget.get_Setting('Display_Item_No') eq ''>
		  		BSA_Foodservice_Items_Master.UPC
		  	<cfelse>
		  		BSA_Foodservice_Items_Master.Item
		  	</cfif>
		<cfif arguments.match_type eq "exact" or application.appSettingsget.getExact_List_Matching_On() IS 1>      <!--- 57142 --->
		  = <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
		<cfelse>
		  like <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
		</cfif>
		    )
	</cfif>
	</CFQUERY>

	<cfif arguments.fromPrgUpload>
		<cfif getItems.recordCount EQ 0>


			<cfset bApplyPlannerTemplateFilter = 0>
            <cfif val( qGetFirstParentID.planner_Id )>
                <cfset bApplyPlannerTemplateFilter = createObject( "component", "mvc.Models.Planner.PlannerManager" ).tmp_planner_template_filter_products( qGetFirstParentID.planner_Id )>
            </cfif>

			<cfscript>
				local.ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init();
            	qGetCoreTemplateFilter = local.ProductGroupAttributeManager.getProductGroupAttributesGroupTemplate( active = 1, FirstParentID = qGetFirstParentID.FirstParentID );
			</cfscript>

			<CFQUERY NAME="getItems" DATASOURCE="#application.datasource#">
			   SELECT  DISTINCT
				 	Group_GUID AS BSA_Foodservice_Items_Master_ID,
					'' AS Description,
					'' AS UPC,
					'' AS Item,
					'' AS InputObjectMatchedItem,
					'' AS Type_Code_Desc,
					'' AS Brand_Name,
					'00000000-0000-0000-0000-000000000000' AS Q_Brand_ID,
					'' AS Type_Group_Desc
					,TMP.Product_Group_Level_ID
					,1 AS IsGroup
					,'A' AS Active_Code
					, All_Product_Group_Types.Deleted
			FROM  All_Product_Group_Types
					INNER JOIN  #arguments.tablename# TMP
						ON TMP.BSA_Foodservice_Items_Master_ID = All_Product_Group_Types.Group_GUID
					INNER JOIN All_product_Group_Type_Members mem
                                             ON mem.Product_Group_ID = All_Product_Group_Types.Group_GUID
			WHERE All_Product_Group_Types.Deleted = 0
			AND Group_Number
				  <cfif arguments.match_type eq "exact" or application.appSettingsget.getExact_List_Matching_On() IS 1>
					= <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
				  <cfelse>
					like <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
				  </cfif>

                    <cfif bApplyPlannerTemplateFilter>
                        AND EXISTS ( SELECT 1
                                       FROM All_product_Group_Type_Members m
                                            INNER JOIN ##tmp_planner_template_filter_products p ON p.Product_ID = m.BSA_Foodservice_Items_Master_ID
                                      WHERE  m.Product_Group_ID = All_Product_Group_Types.Group_GUID
                                	)
                    </cfif>

					<!--- Apply program template filter --->
					<cfloop query="qGetCoreTemplateFilter">
						<cfif qGetCoreTemplateFilter.Allow_Filter eq 1>
							AND EXISTS (
											SELECT 1
											  FROM Product_Group_Template_Selection ts
													INNER JOIN All_product_Group_Type_Members m
														ON   ts.Product_Group_ID = m.Product_Group_ID
														AND  ts.Product_Group_Level_ID = m.Product_Group_Level_ID
														AND  m.BSA_Foodservice_Items_Master_ID = mem.BSA_Foodservice_Items_Master_ID
											  WHERE  ts.Template_ID = #qGetCoreTemplateFilter.Template_ID#
														AND  ts.Deleted = 0
														AND  ts.Active = 1
														AND  ts.Product_Group_Level_ID = #qGetCoreTemplateFilter.Group_Level_ID#
										)
						</cfif>
					</cfloop>
			</CFQUERY>
		</cfif>

		<cfquery name="Update_tempdb" datasource="#application.datasource#">
			Declare @AC varchar(1) = 'A', @deleted bit = 0, @IsGroup bit = 0, @Product_Group_Level_Id INT = 0

			<cfif getItems.recordCount GT 0>
				SELECT @AC = '#getItems.Active_Code#', @deleted = '#getItems.Deleted#', @IsGroup = '#getItems.IsGroup#', @Product_Group_Level_Id = '#getItems.Product_Group_Level_ID#'
			<cfelse>
				SELECT @AC = Active_Code, @deleted = Deleted, @IsGroup = IsGroup, @Product_Group_Level_Id = Product_Group_Level_Id
				FROM (
							SELECT Active_Code, Deleted, 0 AS IsGroup, 0 AS Product_Group_Level_Id
							FROM BSA_Foodservice_Items_Master
							INNER JOIN  #arguments.tablename# TMP
							ON TMP.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
							WHERE <cfif application.returned_customer_setting.upc_switch EQ 1 AND application.appSettingsget.get_Setting('Display_Item_No') eq ''>
											dbo.BSA_Foodservice_Items_Master.UPC
										<cfelse>
											dbo.BSA_Foodservice_Items_Master.Item
										</cfif>
										<cfif arguments.match_type eq "exact" or application.appSettingsget.getExact_List_Matching_On() IS 1>      <!--- 57142 --->
										= <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
										<cfelse>
										like <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
										</cfif>

							UNION

							SELECT 'A' AS Active_Code, APGT.Deleted, 1 AS IsGroup, APGT.Product_Group_Level_Id
							FROM Program_Control_Panel_Options PCPO
							INNER JOIN Group_Template GT
							ON GT.Template_ID = PCPO.First_Parent_ID
							AND GT.Deleted = 0
							AND GT.PG_Group_Type  = 1
							INNER JOIN All_Product_Group_Types APGT
							ON APGT.Product_Group_Level_ID = GT.Group_Level_ID
							INNER JOIN  #arguments.tablename# TMP
							ON TMP.BSA_Foodservice_Items_Master_ID = APGT.Group_GUID
							WHERE PCPO.ProgramControl_Panel_Options_ID = #checkTemplateSettings.ProgramType_ID#
							AND GT.Allow_In_Group_Search  = 1
							AND APGT.Deleted = 0
						AND  APGT.Group_Number
										<cfif arguments.match_type eq "exact" or application.appSettingsget.getExact_List_Matching_On() IS 1>
										= <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
										<cfelse>
										like <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
										</cfif>
							) q1
			</cfif>

			IF OBJECT_ID('tempdb..#tablename#') IS NOT NULL
			BEGIN
				UPDATE #arguments.tablename#
				SET
				<cfif getItems.recordCount LE 0>
					Invalid = 1,
					valid = 0,
					Reason = CONCAT (Reason,
								CASE
								WHEN @deleted = 1 AND CHARINDEX('App',Reason) = 0
									THEN
										CASE WHEN LEN(Reason) = 0 THEN 'Removed From Application' ELSE '&nbsp;/&nbsp;Removed From Application' END
								WHEN @AC = 'N'  AND CHARINDEX('Active',Reason) = 0
									THEN
										CASE WHEN LEN(Reason) = 0 THEN 'Not Active' ELSE '&nbsp;/&nbsp;Not Active' END

								WHEN @AC = 'A'  AND @deleted = 0 AND CHARINDEX('Exist',Reason) = 0
									THEN
										CASE WHEN LEN(Reason) = 0 THEN  'Does Not Exist'  ELSE '&nbsp;/&nbsp;Does Not Exist' END
								END),
				</cfif>
					IsGroup =  @IsGroup,
					Product_Group_Level_Id = @Product_Group_Level_Id
				WHERE Products_ID = <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
			END
		</cfquery>
	</cfif>

<cfif (arguments.discountype EQ 2 AND (checkTemplateSettings.Discount_Rebates_Item_Level EQ 0  OR checkTemplateSettings.Discount_Rebates_Group_Level EQ 0))
  OR (arguments.discountype EQ 1 AND (checkTemplateSettings.Discount_Fixed_Item_Level EQ 0  OR checkTemplateSettings.Discount_Fixed_Group_Level EQ 0))>
		<cfquery name="Update_tempdb" datasource="#application.datasource#">
			UPDATE #arguments.tablename#
						SET	 Invalid = 1
						,		valid = 0
						<cfif checkTemplateSettings.Discount_Rebates_Item_Level EQ 0>
						,		Reason = CONCAT (Reason, CASE WHEN LEN(Reason) = 0 THEN 'Template does not allow products.' ELSE '&nbsp;/&nbsp;Template does not allow products.' END)
						<cfelseif checkTemplateSettings.Discount_Rebates_Group_Level EQ 0 OR checkTemplateSettings.Discount_Fixed_Group_Level EQ 0>
						,		Reason = CONCAT (Reason, CASE WHEN LEN(Reason) = 0 THEN 'Template does not allow product groups.' ELSE '&nbsp;/&nbsp;Template does not allow product groups.' END)
						</cfif>
				WHERE Products_ID = <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
				<cfif arguments.discountype EQ 2>
					<cfif checkTemplateSettings.Discount_Rebates_Item_Level EQ 0 AND checkTemplateSettings.Discount_Rebates_Group_Level EQ 1>
						AND IsGroup = 0
					<cfelseif checkTemplateSettings.Discount_Rebates_Group_Level EQ 0 AND checkTemplateSettings.Discount_Rebates_Item_Level EQ 1>
						AND IsGroup = 1
				  <cfelseif checkTemplateSettings.Discount_Rebates_Group_Level EQ 1 AND checkTemplateSettings.Discount_Rebates_Item_Level EQ 1>
				  	AND 1 = 2
				  <cfelse>

					</cfif>
				<cfelseif arguments.discountype EQ 1>
					<cfif checkTemplateSettings.Discount_Fixed_Group_Level EQ 0>
						AND IsGroup = 1
					<cfelse>
						AND 1 = 2
					</cfif>
				</cfif>
		 </cfquery>
</cfif>

	<cfif getItems.recordCount LE 0>
		<cfset Set("Invalid",  arguments.InputObject)/>
		<cfreturn>
	</cfif>
</cfif>
<!---- START: D42821 - Add Group Number to Product Rebate Entry Screen/Anand Rao/15-May-2014 --->
<cfif  arguments.thisObject EQ 'PRODUCTGROUP'>
	<cfset productGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
	<!--- Create a temp table first to insert the records from different groups --->

	<cfloop index = "i" list = "#FORM.ProductGroupLevelTypes#"  delimiters = ",">
		<cfset productGroupType = productGroupAttributeManager.getGroupTypeInfo(groupLevelId = #i#) />
		<cfif (arguments.InputObject NEQ "")>
		<CFQUERY NAME="qryInsIntoTempTable" DATASOURCE="#application.datasource#">
			INSERT INTO ##ProductGroupList
			SELECT DISTINCT #productGroupType.tableName#.#productGroupType.NameField# As Group_Level_Desc,
						 #productGroupType.tableName#.#productGroupType.IDField# As Product_Group_ID,
						 #productGroupType.tableName#.#productGroupType.NumberField# As Group_ID,    <!---31360--->
						 #productGroupType.groupLevelID# As Product_Group_Level_ID,
						 #productGroupType.groupLevelType# As Product_Group_Level_Type,
							 '' As Hierarchy_Level,
						 '' As Parent_Hierarchy_ID
			FROM	#productGroupType.tableName#
			WHERE
			<cfif arguments.match_type eq "exact" or application.appSettingsget.getExact_List_Matching_On() IS 1>   <!--- 57142 --->
			#productGroupType.tableName#.#productGroupType.NameField# = <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar"> OR
				#productGroupType.tableName#.#productGroupType.NumberField# = <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
			<cfelse>
			#productGroupType.tableName#.#productGroupType.NameField# LIKE <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar"> OR
				#productGroupType.tableName#.#productGroupType.NumberField# LIKE <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
			</cfif>
			AND #productGroupType.tableName#.Deleted = 0
			<cfif (productGroupType.groupLevelType GTE 2000)>
			AND PG_Product_Category.PG_Type_ID = #productGroupType.groupLevelType#
			</cfif>
		</CFQUERY>
		</cfif>
	</cfloop>

	<cfquery name="getItems" datasource="#application.datasource#">
		SELECT *,Group_ID AS InputObjectMatchedItem
		FROM ##ProductGroupList
		WHERE Group_ID LIKE <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
		OR 		GROUP_Level_Desc LIKE <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
	</cfquery>


	<cfif (NOT isDefined("getItems") OR getItems.recordCount LE 0)>
		<cfset Set("Invalid",  arguments.InputObject)/>
		<cfreturn>
	</cfif>
<!--- END: D42821 - Add Group Number to Product Rebate Entry Screen/Anand Rao/15-May-2014 --->
<cfelseif  arguments.thisObject EQ 'CUSTOMERS'>
	<!------ Get application settings ----->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfset sKeywordSearchDelimiter = " " /> <!--- space --->
	<CFQUERY NAME="getItems" DATASOURCE="#application.datasource#">
		SELECT	dbo.BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
					dbo.BSA_Foodservice_Customers.Name,
					dbo.BSA_Foodservice_Customers.Address_1,
					dbo.BSA_Foodservice_Customers.City,
					dbo.BSA_Foodservice_Customers.State,
					dbo.BSA_Foodservice_Customers.ZipCode,
					dbo.Distributor_Family.Family_Name,
					dbo.BSA_Foodservice_Customers.Ship_To,
					dbo.BSA_Foodservice_Customers.Active_Code,
					dbo.BSA_Foodservice_Brokers.Broker_Name,
					dbo.Service_Zones.Zone_Name,
					dbo.Service_Regions.Region_Name,
					dbo.Distributor_Buying_Groups.Buying_Group_Name,
					dbo.BSA_Foodservice_Customers.Shr_Ship_To,
					dbo.BSA_Foodservice_Customers.Shr_Ship_To as InputObjectMatchedItem
		FROM	dbo.BSA_Foodservice_Customers
		INNER JOIN	dbo.Distributor_Family
		ON dbo.BSA_Foodservice_Customers.Family_ID = dbo.Distributor_Family.Family_ID
		INNER JOIN	dbo.Distributor_Buying_Groups
		ON dbo.BSA_Foodservice_Customers.Buying_Group_ID = dbo.Distributor_Buying_Groups.Buying_Group_ID
		INNER JOIN  dbo.Line_Of_Business
		ON dbo.BSA_Foodservice_Customers.Line_Of_Business_ID = dbo.Line_Of_Business.Line_Of_Business_ID
		<cfif appSettings.getDistributorMultiPosition()>
		LEFT JOIN 	Market_Distributor
		ON Market_Distributor.Deleted = 0
		AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		LEFT JOIN Service_Markets
		ON Service_Markets.Service_Market_ID = Market_Distributor.Service_Market_ID
		</cfif>
		LEFT JOIN	dbo.BSA_Foodservice_Brokers
		ON
				<cfif appSettings.getDistributorMultiPosition()>
				BSA_Foodservice_Brokers.Service_Market_ID = Service_Markets.Service_Market_ID
				<cfelse>
				BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
				</cfif>
		LEFT JOIN	dbo.Service_Regions
		ON
				<cfif appSettings.getDistributorMultiPosition()>
				Service_Markets.Service_Region_ID = Service_Regions.Service_Region_ID
				<cfelse>
				BSA_Foodservice_Brokers.Service_Region_ID = Service_Regions.Service_Region_ID
				</cfif>
		LEFT JOIN	dbo.Service_Zones
		ON Service_Regions.Service_Zone_ID = Service_Zones.Service_Zone_ID
		WHERE	0 = 0
		AND 	dbo.BSA_Foodservice_Customers.DELETED = 0
		AND 	dbo.BSA_Foodservice_Customers.Active_Code = 'A'
		<cfif application.appSettingsget.getExact_List_Matching_On() IS 1>
		AND 	(
						<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
							dbo.BSA_Foodservice_Customers.Shr_Ship_To = <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
						<cfelse>
							dbo.BSA_Foodservice_Customers.Ship_To = <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
						</cfif>
				OR
				<!--- Do not remove the delimuter and like from below value, The field is supposed to have space separated tokens like 459998 460005 460383 --->
				dbo.BSA_Foodservice_Customers.Keyword_Search like <cfqueryparam value="%#trim(arguments.InputObject)##sKeywordSearchDelimiter#%" cfsqltype="cf_sql_varchar">
				)
		<cfelse>
		AND 	(
						<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
							dbo.BSA_Foodservice_Customers.Shr_Ship_To like <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
						<cfelse>
							dbo.BSA_Foodservice_Customers.Ship_To like <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
						</cfif>
				OR
				dbo.BSA_Foodservice_Customers.Keyword_Search like <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
				)
		</cfif>
	</CFQUERY>
	<cfif getItems.recordCount LE 0>
		<cfset Set("Invalid",  arguments.InputObject)/>
		<cfreturn>
	</cfif>
<!---30286 - Added logic to support operators--->
<cfelseif arguments.thisObject EQ 'OPERATOR_LEGACY_ID'>
	<cfquery name="vars.operators" datasource="#application.datasource#">
		SELECT Legacy_ID
		FROM bsa_Operator
		WHERE bsa_Operator.Deleted = 0
		AND bsa_Operator.Display_Code = 'A'
		<cfif application.appSettingsget.getExact_List_Matching_On() IS 1>
		AND Legacy_Id = <cfqueryparam value="#trim(arguments.InputObject)#" cfsqltype="cf_sql_varchar">
		<cfelse>
		AND Legacy_Id LIKE <cfqueryparam value="%#trim(arguments.InputObject)#%" cfsqltype="cf_sql_varchar">
		</cfif>
		AND ( Legacy_Id IS NOT NULL OR Len( Legacy_Id ) != 0 )
		<cfif application.appSettingsget.get_Setting('GPO_One_Page_Program_Creation') EQ 1>
			AND   operator_type != 'GPO_Roster'
		</cfif>
	</cfquery>
	<cfif vars.operators.recordCount eq 0>
		<cfset Set("Invalid",  arguments.InputObject)/>
	<cfelse>
		<cfset Set("ValidList",  ValueList( vars.operators.legacy_ID ))/>
		<cfset Set("Valid",  arguments.InputObject)/>
	</cfif>
	<cfreturn>
<!---30286 - Added logic to support operators--->
<cfelseif arguments.thisObject EQ 'BSA_OPERATOR_ID'>
	<cfquery name="vars.operators" datasource="#application.datasource#">
		SELECT Bsa_Operator_Id
		FROM bsa_Operator
		WHERE bsa_Operator.Deleted = 0
		AND bsa_Operator.Display_Code = 'A'
		AND Bsa_Operator_Id = <cfif isnumeric(arguments.InputObject)>#arguments.InputObject#<cfelse>''</cfif>
		<cfif application.appSettingsget.get_Setting('GPO_One_Page_Program_Creation') EQ 1>
			AND   operator_type != 'GPO_Roster'
		</cfif>
	</cfquery>
	<cfif vars.operators.recordCount eq 0>
		<cfset Set("Invalid",  arguments.InputObject)/>
	<cfelse>
		<cfset Set("ValidList",  ValueList( vars.operators.Bsa_Operator_Id ))/>
		<cfset Set("Valid",  arguments.InputObject)/>
	</cfif>
	<cfreturn>
</cfif>

	<!--- Dev Note: kvangapalli;  D13278: Make the create list tool just like the distributor search --->
	<cfset Set("ValidList",  ValueList(getItems.InputObjectMatchedItem))/>
	<cfset Set("Valid",  arguments.InputObject)/>
</cffunction>

	<cffunction name="Set" access="public">
		<cfargument name="Category" 	type="string" required="true">
		<cfargument name="Object" 		type="string" required="true">
		<cfswitch expression="#arguments.Category#">
			<cfcase value="Invalid">
				<cfscript>
					ArrayAppend(this.DataValidationInfo.InValidData, Object);
				</cfscript>
			</cfcase>
			<cfcase value="Duplicate">
				<cfscript>
					ArrayAppend(this.DataValidationInfo.DuplicateData, Object);
				</cfscript>
			</cfcase>
			<cfcase value="Valid">
				<cfscript>
					ArrayAppend(this.DataValidationInfo.ValidData, Object);
				</cfscript>
			</cfcase>
			<!--- Dev Note: kvangapalli;  D13278: Make the create list tool just like the distributor search --->
			<cfcase value="ValidList">
				<cfscript>
					ArrayAppend(this.DataValidationInfo.ValidListData, Object);
				</cfscript>
			</cfcase>
		</cfswitch>
	</cffunction>

	<cffunction name="Get" access="public" returntype="Array">
		<cfreturn this.DataValidationInfo.ValidData />
	</cffunction>

<cffunction name="updatePricingLevels" access="public" returntype="any">
	<cfargument name="tablename" type="string" required="true">

	<cfquery name="qGroupslevelID" datasource="#application.datasource#">
		SELECT DISTINCT Product_Group_Level.Product_Group_Level_ID, Display_Sequence
		FROM Product_Group_Level
		INNER JOIN #arguments.tablename# t
		ON t.Product_Group_Level_Id = Product_Group_Level.Product_Group_Level_Id
		WHERE Display_Sequence <> 0
		AND is_pg = 0
		AND Active = 1
		And Valid = 1
		ORDER BY Display_Sequence
	</cfquery>

	<cfset GrouplevelOrder = valueList(qGroupslevelID.Product_Group_Level_ID)>

	<cfquery name="qPGGroupslevelID" datasource="#application.datasource#">
		SELECT DISTINCT Product_Group_Level.Product_Group_Level_ID, Display_Sequence
		FROM Product_Group_Level
		INNER JOIN #arguments.tablename# t
		ON t.Product_Group_Level_Id = Product_Group_Level.Product_Group_Level_Id
		WHERE Display_Sequence <> 0
		AND is_pg = 1
		AND Active = 1
		AND Valid = 1
		ORDER BY Display_Sequence
	</cfquery>

	<cfset PGGrouplevelOrder = valueList(qPGGroupslevelID.Product_Group_Level_ID)>

	<cfset orderNo = 1>
<!--- UPDATE GROUPS PRICING LEVEL --->
	<cfloop list="#GrouplevelOrder#" index="PGID" delimiters=",">
		<cfquery name="uGroupPricinglevel" datasource="#application.datasource#">
				UPDATE #arguments.tablename#
				SET Pricing_Level_ID = #orderNo#
				WHERE Product_Group_Level_ID = #PGID#
				AND  IsGroup = 1
				AND Valid = 1
				<cfset orderNo = orderNo + 1>
		</cfquery>
	</cfloop>

<!--- CHECK IF ANY PG EXISITS --->
	<cfquery name="qCheckPG" datasource="#application.datasource#">
		SELECT *
		FROM #arguments.tablename#
		WHERE Product_Group_Level_ID IN ( <cfqueryparam value="#PGGrouplevelOrder#" list="true">)
	</cfquery>
<!--- UPDATE PG GROUPS PRICING LEVEL IF ANY EXISITS --->
	<cfif qCheckPG.recordCount>
			<cfquery name="uPGPricinglevel" datasource="#application.datasource#">
				UPDATE #arguments.tablename#
				SET Pricing_Level_ID = #orderNo#
				WHERE Product_Group_Level_ID IN ( <cfqueryparam value="#PGGrouplevelOrder#" list="true">)
				AND Valid = 1
		</cfquery>

		<cfset orderNo = orderNo + 1>
	</cfif>
<!--- UPDATE ITEMS PRICING LEVEL --->
		<cfquery name="uItemPricinglevel" datasource="#application.datasource#">
				UPDATE #arguments.tablename#
				SET Pricing_Level_ID = #orderNo#
				WHERE IsGroup = 0
				AND Valid = 1
		</cfquery>

</cffunction>

</cfcomponent>