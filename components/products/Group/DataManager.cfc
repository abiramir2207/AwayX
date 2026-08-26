<cfcomponent hint="This class is only used for database access. It holds all the queries for Products Groups">

	<cfset this.timeSpan = CreateTimeSpan(0, 12, 0, 0) />

	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

	<cffunction name="init" output="false">

		<cfreturn this />

	</cffunction>

	<cffunction name="getProductGroupsData" output="false" returntype="query">

		<cfargument name="productGroupId" required="false" default="" />
		<cfargument name="filterGroups" required="false" default="" />
		<cfargument name="filterGroupTypes" required="false" default="" />
		<cfargument name="isCombination" required="false" default="0" />
		<cfargument name="isActive" required="false" default="1" />
		<cfargument name="arAllowGroupLevel" required="false" default="#ArrayNew(1)#" />
		<cfargument name="allowInGroupSearch" required="false" default="1" />
		<cfargument name="FirstParentID" required="false" default="0" />
		<cfargument name="filterProgramVolume" required="false" default="0" />
		<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
		<cfargument name="EZTemplate" type="numeric" required="false" default="0" />
		<cfargument name="includeProduct" type="numeric" required="false" default="0" />

		<cfset arguments.filterGroupTypes = "0,1" />

		<!---check to see if class codes are turned on --->
		<!--- mws performance --->
		<!--- <cfset GenSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() /> --->

		<cfset classCodesOn = appSettings.getClassCodesOn() >

		<!---if class codes aren't on then filter on it  <cfif classcode.Classcodes_On eq 0>--->
		<cfif classCodesOn eq 0>
			<cfset arguments.filterGroupTypes = ListAppend(arguments.filterGroupTypes, 4) />
		</cfif>
		<cfparam name="URL.EZ_Button_Rate_ID" default="0"/>

		<cfquery name="qGetProductGroups" datasource="#application.datasource#">
			SELECT
			<cfif isDefined("arguments.allowInGroupSearch") AND arguments.allowInGroupSearch EQ "1" AND
			isDefined("arguments.FirstParentID") AND arguments.FirstParentID NEQ "0" >
				DISTINCT
			</cfif>
				PGL.Product_Group_Level_ID,
				PGL.Group_Level_Desc,
				PGL.Product_Group_Level_Type,
				PGL.Hierarchy_Level,
				PGA.Product_Group_Attribute_Search_Sequence_Field Search_Sequence_Field,
				PGL.Is_Group_Combination,PGL.Is_PG,PGL.List_Order
			<!---77408 Product Group sequencing START--->
			, PGL.Display_Sequence, PGL.Active
			<!---77408 Product Group sequencing END--->
			FROM	Product_Group_Level PGL

			LEFT JOIN Product_Group_Attribute PGA
				ON	PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID
			<cfif isDefined("arguments.allowInGroupSearch") AND arguments.allowInGroupSearch EQ "1" AND
				isDefined("arguments.FirstParentID") AND arguments.FirstParentID NEQ "0" AND isDefined("arguments.EZTemplate") AND (arguments.EZTemplate EQ "0" AND URL.EZ_Button_Rate_ID EQ 0)>
				INNER JOIN Group_Template GT
					ON GT.Group_Level_ID = PGL.Product_Group_Level_ID AND
					GT.Allow_In_Group_Search = 1 AND
					GT.Deleted = 0 AND
					GT.Active = 1 AND
					GT.Template_ID = #arguments.FirstParentID# AND
					GT.PG_Group_Type = 1
				<cfif arguments.filterProgramVolume eq 1>
					AND GT.Prg_Vol_By_Attribute = 1
				</cfif>
				<cfif arguments.TemplateFiltersID NEQ 0 and isNumeric(arguments.TemplateFiltersID)>
					INNER JOIN Product_Group_Template_Selection PGTS ON
						PGTS.Template_ID = GT.Template_ID AND
						PGTS.Template_Filters_Id = <cfqueryparam value="#arguments.TemplateFiltersID#" cfsqltype="cf_sql_integer" /> AND
						PGTS.Product_Group_Level_ID = GT.Group_Level_ID
				</cfif>
			</cfif>
			WHERE	PGL.Deleted = 0
			<!--- Do not Select planning groups if the appsetting is OFF./Anand Rao/10-Jan-2011--->
			<cfif NOT(appSettings.getPlanningGroups())>
			AND PGL.Is_PG = 0
			</cfif>
			<!---if we have a product group id then get just for this product group--->
			<cfif Len(trim(arguments.productGroupId)) AND arguments.productGroupId NEQ 0>
				AND		PGL.Product_Group_Level_ID = #arguments.productGroupId#
			</cfif>
			<!---filter group id's--->
			<cfif Len(trim(arguments.filterGroups))>
				AND		PGL.Product_Group_Level_ID NOT IN (#arguments.filterGroups#)
			</cfif>
			<!---if we have a product group type id then get just for these product types--->
			<cfif Len(trim(arguments.filterGroupTypes))>
				AND		Product_Group_Level_Type NOT IN (#arguments.filterGroupTypes#)
			</cfif>
			<cfif arguments.isCombination EQ 0>
				<cfif arguments.isActive EQ 1>
					AND		PGL.Active = 1
				</cfif>
			<cfelse>
				AND		(PGL.Active = 1 OR PGL.Is_Group_Combination = 1)<!------ In the case of group combination dummy entries it won't be active ----->
			</cfif>
			<cfset arAllowGroupLevelLen = ArrayLen(arAllowGroupLevel) />
			<cfloop from="1" to="#arAllowGroupLevelLen#" index="i">
				<cfset allowGroupList = arAllowGroupLevel[i] />
				<cfif allowGroupList neq "">
					AND		PGL.Product_Group_Level_ID IN (#allowGroupList#)
				<cfelse>
					AND		1=2
				</cfif>
			</cfloop>
			<cfif arguments.includeProduct >
				UNION
				SELECT
					PGL.Product_Group_Level_ID,
					PGL.Group_Level_Desc,
					PGL.Product_Group_Level_Type,
					PGL.Hierarchy_Level,
					PGA.Product_Group_Attribute_Search_Sequence_Field Search_Sequence_Field,
					PGL.Is_Group_Combination,PGL.Is_PG,PGL.List_Order
					<!---77408 Product Group sequencing START--->
					, PGL.Display_Sequence, PGL.Active
					<!---77408 Product Group sequencing END--->
				FROM	Product_Group_Level PGL
				LEFT JOIN Product_Group_Attribute PGA
					ON	PGA.Product_Group_Level_ID = PGL.Product_Group_Level_ID
				WHERE	PGL.Deleted = 0
				AND 	PGL.Product_Group_Level_ID IN (0,9)
			</cfif>

			ORDER BY Group_Level_Desc ASC
		</cfquery>

		<cfreturn qGetProductGroups />

	</cffunction>

	<!--- START:  D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ---->
	<cffunction name="getProductGroupsDataNoPG" output="false" returntype="query">
		<cfset qGetProductGroupTypesMain = this.getProductGroupsData() />
		<cfset useLakebaseForqGetProductGroupTypesNoPG = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetproductgrouptypesmain")>
<cfif useLakebaseForqGetProductGroupTypesNoPG>
	<cftry>
		<cfset qGetProductGroupTypesNoPG = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetproductgrouptypesmain", {
				"is_pg" = "eq.0",
				"order" = "list_order.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProductGroupTypesNoPG = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProductGroupTypesNoPG>
<cfquery name="qGetProductGroupTypesNoPG" dbtype="query">
			SELECT
				*
			FROM
				qGetProductGroupTypesMain
			WHERE
				IS_PG = 0
			ORDER BY
				List_Order
		</cfquery>
</cfif>

		<cfreturn qGetProductGroupTypesNoPG />
	</cffunction>
	<!--- END: D29684 - Planning Groups and Search Tools/Anand Rao/04-Jan-2012 ---->

	<cffunction name="getByProductGroupData" output="false" returntype="query">
		<cfargument name="prodGroupLevelId" required="false" default="" />
		<cfargument name="prodGroupId" required="false" default="" />
		<cfargument name="programId" required="false" default="0" />
		<cfargument name="lExcludeProdGroup" required="false" default="" />
		<cfargument name="parentHierarchyId" required="false" default="" />
		<cfargument name="addParentName" required="false" default="2" />
		<cfargument name="arGroupMembers" required="false" default="#ArrayNew(1)#" type="array" />
		<cfargument name="isCombination" required="false" default="0" type="numeric" />
		<cfargument name="byPassUserClassCodeRestriction" required="false" default="0" type="boolean" />
		<cfargument name="OnlyEZProducts" required="false" default="" />
		<cfargument name="EZbutton_On" required="false" default="0" />
		<cfargument name="suppressGroups" required="false" default="0" />
		<cfargument name="showAllProductHierarchy" required="false" default="0" />
		<cfargument name="IncludeDeleted" required="false" default="0" />
    	<cfargument name="FirstParentID" type="string" required="false" default="0" />
		<cfargument name="allowInGroupSearch" required="false" default="1" />
		<cfargument name="setGroupTemplateSelectionOn" required= "false" default="0" />
		<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
		<cfargument name="businessSegmentId" required="false" type="numeric" default="0">
		<cfargument name="IncludeActiveOnly" required="false" default="1" />
		<cfargument name="EZTemplate" required="false" default="0" />
        <cfargument name="plannerId" type="numeric" required="false" default="0" />



		<cfset ProgramManager = CreateObject("component", "components.programs.ProgramManager").init()>
		<cfset programInfo = programManager.getProgramInfo(arguments.programId)>

		<!---param the restrict list and what to restrict---->
		<cfparam name="approvalGroupType" default="" />
		<cfparam name="restrictOnProductGroupList" default="" />
		<cfset restrictOnThisProductGroupLevel = 0 />
		<cfset restrictOnProductGroup = 0 />
		<cfset prodHierLevel = 0 />

		<cfif trim(programInfo.Restrict_On_Approval_Group) neq "" and programInfo.Restrict_On_Approval_Group>
			<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init()>
			<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(productGroupLevelId=appSettings.getTemplateRestrictGroupLevel()) />
			<cfset restrictOnProductGroup = 1>
			<cfset prodHierLevel = approvalGroupType.prodHierLevel />
			<cfset qRestrictOnProductGroupList = approvalGroupManager.getTemplateAllowApprovalGroups(programInfo.ProgramType_ID)>
			<cfset restrictOnProductGroupList = ValueList(qRestrictOnProductGroupList.Group_ID)>
		</cfif>

		<cfif arguments.prodGroupLevelId eq 0>
			<cfset qGetProdGroupData = QueryNew("Product_Group_Level_Type") />
		<cfelse>

			<cfset qGetProdGroupData = this.getProductGroupsData(productGroupId = arguments.prodGroupLevelId,
																	isActive=0,
																	allowinGroupSearch 	= arguments.allowinGroupSearch,
																	FirstParentID 		= arguments.FirstParentID,
																	TemplateFiltersID	= arguments.TemplateFiltersID,
																	EZTemplate = arguments.EZTemplate
																) />

			<cfif restrictOnProductGroup AND approvalGroupType.groupLevelType EQ qGetProdGroupData.Product_Group_Level_Type>
				<cfset restrictOnThisProductGroupLevel = 1>
			</cfif>

		</cfif>


		<!---handle for each product type--->
		<cfif qGetProdGroupData.Product_Group_Level_Type eq 0>

			<cfscript>
				qGetProductGroupData = QueryNew("Product_Group_ID, Group_Level_Desc, Product_Group_Level_Type, Hierarchy_Level, Parent_Hierarchy_ID");
				QueryAddRow(qGetProductGroupData);
				QuerySetCell(qGetProductGroupData, "Product_Group_ID", "99999999-9999-9999-9999-999999999999");
				QuerySetCell(qGetProductGroupData, "Group_Level_Desc", "Products");
				QuerySetCell(qGetProductGroupData, "Product_Group_Level_Type", "0");
				QuerySetCell(qGetProductGroupData, "Hierarchy_Level", "");
				QuerySetCell(qGetProductGroupData, "Parent_Hierarchy_ID", "");
			</cfscript>

		<cfelseif qGetProdGroupData.Product_Group_Level_Type eq 1><!------ Business segment ----->

			<cfset qGetProductGroupData = this.getBusinessSegments(suppressGroups = arguments.suppressGroups) />

		<cfelseif qGetProdGroupData.Product_Group_Level_Type eq 2>

			<cfset qGetProductGroupData = this.getHierarchyLevel(hierarchyLevel=qGetProdGroupData.Hierarchy_Level, prodGroupId=arguments.prodGroupId, addParentName=arguments.addParentName, restrictOnProductHierarchy=restrictOnThisProductGroupLevel, restrictOnProductHierarchyLevel=prodHierLevel, restrictOnProductHierarchyList=restrictOnProductGroupList, lExcludeProdGroup=arguments.lExcludeProdGroup, parentHierarchyId=arguments.parentHierarchyId, programId=arguments.programId,OnlyEZProducts=arguments.OnlyEZProducts,EZbutton_On= arguments.EZbutton_On, suppressGroups = arguments.suppressGroups, showAllProductHierarchy = arguments.showAllProductHierarchy) />

		<cfelseif qGetProdGroupData.Product_Group_Level_Type eq 4><!------ Class Code ----->

			<cfset qGetProductGroupData = this.getClassCodes(prodGroupId=arguments.prodGroupId, lExcludeProdGroup=arguments.lExcludeProdGroup, programId=arguments.programId, restrictOnClassCode=restrictOnThisProductGroupLevel, restrictOnClassCodeList=restrictOnProductGroupList, byPassUserClassCodeRestriction=arguments.byPassUserClassCodeRestriction,OnlyEZProducts=arguments.OnlyEZProducts,EZbutton_On= arguments.EZbutton_On, suppressGroups = arguments.suppressGroups) />

		<cfelseif qGetProdGroupData.Product_Group_Level_Type NEQ "">

			<!------ Get the group values ----->
			<cfset qGetProductGroupData = this.getProductGroupAttributeValues
											(productGroupLevelId 		= arguments.prodGroupLevelId,
											programId 					= arguments.programId,
											prodGroupId 				= arguments.prodGroupId,
											restrictOn 					= restrictOnThisProductGroupLevel,
											restrictOnProductGroupList	= restrictOnProductGroupList,
											lExcludeProdGroup 			= arguments.lExcludeProdGroup,
											arGroupMembers				= arguments.arGroupMembers,
											OnlyEZProducts				= arguments.OnlyEZProducts,
											EZbutton_On					= arguments.EZbutton_On,
											suppressGroups				= arguments.suppressGroups,
											IncludeDeleted				= arguments.IncludeDeleted,
											FirstParentID     			= arguments.FirstParentID,
											setGroupTemplateSelectionOn = arguments.setGroupTemplateSelectionOn,
											TemplateFiltersID			= arguments.TemplateFiltersID,
											businessSegmentId			= arguments.businessSegmentId,
											IncludeActiveOnly			= arguments.IncludeActiveOnly,
                                            plannerId                   = arguments.plannerId
											) />

		<cfelse>

			<cfscript>
				qGetProductGroupData = QueryNew("Product_Group_ID, Group_Level_Desc, Product_Group_Level_Type, Hierarchy_Level, Parent_Hierarchy_ID");
			</cfscript>

		</cfif>


		<cfreturn qGetProductGroupData />

	</cffunction>

	<cffunction name="getHierarchyLevel" output="false" returntype="query">

		<cfargument name="hierarchyLevel" required="false" default="" />
		<cfargument name="prodGroupId" required="false" default="" />
		<cfargument name="addParentName" required="false" default="2" hint="1=show parent, 2=show full path" />
		<cfargument name="getLevelNames" required="false" default="0" />
		<cfargument name="restrictOnProductHierarchy" required="false" default="0" />
		<cfargument name="restrictOnProductHierarchyLevel" required="false" default="0" />
		<cfargument name="restrictOnProductHierarchyList" required="false" default="" />
		<cfargument name="lExcludeProdGroup" required="false" default="" />
		<cfargument name="parentHierarchyId" required="false" default="" />
		<cfargument name="displayFullPath" required="false" default="" />
		<cfargument name="excludeLevelList" required="false" default="" />
		<cfargument name="programId" required="false" default="0" />
		<cfargument name="OnlyEZProducts" required="false" default="" />
		<cfargument name="EZbutton_On" required="false" default="0" />
		<cfargument name="suppressGroups" required="false" default="0" />
		<cfargument name="showAllProductHierarchy" required="false" default="0" />

		<cfset businessSegmentManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").init() />
		<cfset templateClassCodeRestrict = 0 />
		<cfset templateClassCodeUUIDList = "" />
		<cfset templateClassCodeList = "" />
		<!------ get the class codes for the user and also the class codes allowed by the template ----->
		<!------ if pgm is is passed and searchs eq is off and template - restrict group level is class code and Restrict hierarchy levels on class code is not empty ----->
		<cfif arguments.programId neq 0 and appSettings.getSearchSequenceOn() EQ 0 and appSettings.getTemplateRestrictGroupLevel() eq 10 and appSettings.getRestrictHierarchyLevelOnClassCode() neq "">
			<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
			<!------ If search seq is off, find the allow group level list (class code list) from templates, if applicable ----->
			<cfset qGetProgramTemplate = templateManager.getProgramTemplate(programId = arguments.programId) />
			<cfif qGetProgramTemplate.Restrict_On_Approval_Group eq 1>
				<cfset templateClassCodeUUIDList = templateManager.getTemplateAllowApprovalGroupList(qGetProgramTemplate.ProgramControl_Panel_Options_ID) />
				<cfset templateClassCodeRestrict = 1 />
				<cfset templateClassCodeList = businessSegmentManager.getClassCodeIDList(templateClassCodeUUIDList) />
			</cfif>
		</cfif>

<!--- <cfset iNumberHierarchyLevels = getNumberHierarchyLevels() /> --->

		<cfquery name="qGetHierarchy" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">

			SELECT	DISTINCT
					<cfif arguments.addParentName eq 1>
						CASE WHEN Product_Hierarchy.Parent_Product_Hierarchy_ID IS NOT NULL THEN
							RTRIM(Product_Hierarchy_Join.Product_Hierarchy_Name) + '\' + Product_Hierarchy.Product_Hierarchy_Name
							ELSE Product_Hierarchy.Product_Hierarchy_Name
						END
					<cfelseif arguments.addParentName eq 2>

						CASE
							WHEN Product_Hierarchy_4.Parent_Product_Hierarchy_ID IS NOT NULL THEN
								RTRIM(Product_Hierarchy_5.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_4.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_3.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_2.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
							WHEN Product_Hierarchy_3.Parent_Product_Hierarchy_ID IS NOT NULL THEN
								RTRIM(Product_Hierarchy_4.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_3.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_2.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
							WHEN Product_Hierarchy_2.Parent_Product_Hierarchy_ID IS NOT NULL THEN
								RTRIM(Product_Hierarchy_3.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_2.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
							WHEN Product_Hierarchy_1.Parent_Product_Hierarchy_ID IS NOT NULL THEN
								RTRIM(Product_Hierarchy_2.Product_Hierarchy_Name) + ' \ ' + RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
							WHEN Product_Hierarchy.Parent_Product_Hierarchy_ID IS NOT NULL THEN
								RTRIM(Product_Hierarchy_1.Product_Hierarchy_Name) + ' \ ' + Product_Hierarchy.Product_Hierarchy_Name
							ELSE Product_Hierarchy.Product_Hierarchy_Name

						END

					<cfelse>
						Product_Hierarchy.Product_Hierarchy_Name
					</cfif>
					as Group_Level_Desc,
					Product_Hierarchy.Product_Hierarchy Group_ID,
					Product_Hierarchy.Product_Hierarchy_ID as Product_Group_ID,
					2 as Product_Group_Level_Type,
					Product_Hierarchy.Product_Hierarchy_Level as Hierarchy_Level,
					Product_Hierarchy.Parent_Product_Hierarchy_ID as Parent_Hierarchy_ID,
					Product_Hierarchy.Product_Hierarchy,
					Product_Hierarchy.Unit_Of_Measure_ID
					<cfif arguments.getLevelNames>
					,Product_Group_Level.Group_Level_Desc Group_Level_Name
					</cfif>
			FROM	Product_Hierarchy
					<!---TSF - Label 11075: Check to see if there are any items for this group. If there are not then return nothing--->
					<cfif arguments.suppressGroups>
					INNER JOIN Product_Customer_Group ON Product_Customer_Group.Product_Hierarchy_ID = Product_Hierarchy.Product_Hierarchy_ID
					</cfif>
					<cfif arguments.getLevelNames>
					INNER JOIN Product_Group_Level
					ON
					Product_Group_Level.Deleted = 0
					AND Product_Group_Level.Hierarchy_Level = Product_Hierarchy_Level
					</cfif>
					<cfif arguments.addParentName eq 1>
					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_Join
					ON Product_Hierarchy.Parent_Product_Hierarchy_ID = Product_Hierarchy_Join.Product_Hierarchy_ID
					<cfelseif arguments.addParentName eq 2>
					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_1
					ON Product_Hierarchy_1.Product_Hierarchy_ID = Product_Hierarchy.Parent_Product_Hierarchy_ID

					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_2
					ON Product_Hierarchy_2.Product_Hierarchy_ID = Product_Hierarchy_1.Parent_Product_Hierarchy_ID

					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_3
					ON Product_Hierarchy_3.Product_Hierarchy_ID = Product_Hierarchy_2.Parent_Product_Hierarchy_ID

					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_4
					ON Product_Hierarchy_4.Product_Hierarchy_ID = Product_Hierarchy_3.Parent_Product_Hierarchy_ID

					LEFT OUTER JOIN Product_Hierarchy Product_Hierarchy_5
					ON Product_Hierarchy_5.Product_Hierarchy_ID = Product_Hierarchy_4.Parent_Product_Hierarchy_ID
					</cfif>
			WHERE	0 = 0
			<!---TSF - Label 11978: Change logic for deleted group hierarchy search & display--->
			<cfif not arguments.showAllProductHierarchy>
				AND Product_Hierarchy.Deleted = 0
			</cfif>
			<cfif Len(arguments.excludeLevelList) GT 0>
			AND		Product_Hierarchy.Product_Hierarchy_Level NOT IN (#arguments.excludeLevelList#)
			</cfif>
			<cfif arguments.restrictOnProductHierarchy>
			AND
			(
				(
					Product_Hierarchy.Product_Hierarchy_Level = #arguments.restrictOnProductHierarchyLevel#
					AND
					<cfif Len(arguments.restrictOnProductHierarchyList) EQ 0>
						1=2
					<cfelse>
						Product_Hierarchy.Product_Hierarchy_ID IN (#ListQualify(arguments.restrictOnProductHierarchyList, "'", ",")#)
					</cfif>
					<cfif arguments.EZbutton_On EQ 1>
					<cfif Len(arguments.OnlyEZProducts) EQ 0>
						1=2
					<cfelse>
						Product_Hierarchy.Product_Hierarchy_ID IN (#ListQualify(arguments.OnlyEZProducts, "'", ",")#)
					</cfif>
					</cfif>
				)
				OR
				(
					Product_Hierarchy.Product_Hierarchy_Level < #arguments.restrictOnProductHierarchyLevel#
					AND
					<cfif Len(arguments.restrictOnProductHierarchyList) EQ 0>
						1=2
					<cfelse>
						(1=2
						<cfloop list="#arguments.restrictOnProductHierarchyList#" index="thisRestrictProdHierId">
							OR Product_Hierarchy.Product_Hierarchy_ID IN
								(SELECT	Product_Hierarchy_ID FROM dbo.udf_GetProductChain('#thisRestrictProdHierId#'))
						</cfloop>
						)
					</cfif>
				)
				OR
				(
					Product_Hierarchy.Product_Hierarchy_Level > #arguments.restrictOnProductHierarchyLevel#
					AND
					<cfif Len(arguments.restrictOnProductHierarchyList) EQ 0>
						1=2
					<cfelse>
						(1=2
						<cfloop list="#arguments.restrictOnProductHierarchyList#" index="thisRestrictProdHierId">
							OR Product_Hierarchy.Product_Hierarchy_ID IN
							(SELECT	Product_Hierarchy_ID FROM dbo.udf_GetProductChainBelow('#thisRestrictProdHierId#'))
						</cfloop>
						)
					</cfif>
				)
			)
			</cfif>
			<cfif Len(trim(arguments.hierarchyLevel))>
			AND 	Product_Hierarchy.Product_Hierarchy_Level = #arguments.hierarchyLevel#
			</cfif>
			<cfif Len(trim(arguments.prodGroupId))>
			AND Product_Hierarchy.Product_Hierarchy_ID IN (#ListQualify(arguments.prodGroupId, "'", ",")#)
			</cfif>
			<!---exclude on list if passed--->
			<cfif Len(trim(arguments.lExcludeProdGroup))>
			AND Product_Hierarchy.Product_Hierarchy_ID NOT IN (#ListQualify(arguments.lExcludeProdGroup, "'", ",")#)
			</cfif>
			<!---filter by parent hierarchy--->
			<cfif Len(trim(arguments.parentHierarchyId))>
			AND Product_Hierarchy.Parent_Product_Hierarchy_ID = '#arguments.parentHierarchyId#'
			</cfif>

			<cfif templateClassCodeRestrict and appSettings.getRestrictHierarchyLevelOnClassCode() neq "">
				AND	(Product_Hierarchy.Product_Hierarchy_Level NOT IN (#appSettings.getRestrictHierarchyLevelOnClassCode()#)
				<cfif templateClassCodeList eq "">
				OR	1 = 2
				<cfelse>
				OR	Product_Hierarchy.Product_Hierarchy_ID IN
				(
				SELECT	Product_Hierarchy_ID
				FROM	Product_Hierarchy_Class_Code
				WHERE	Deleted = 0
				AND		Product_Hierarchy_Class_Code.Class_Code_ID IN (#templateClassCodeList#)
				)
				</cfif>
				)
			</cfif>

			<!--- if addParentName eq 2 then we have to order by the top level hierarchy --->
			<cfif arguments.addParentName eq 2>

				ORDER BY Group_Level_Desc

			<cfelse>

				ORDER BY Product_Hierarchy.Product_Hierarchy_Level, Product_Hierarchy.Product_Hierarchy_Name

			</cfif>

		</cfquery>

		<cfreturn qGetHierarchy />

	</cffunction>

	<cffunction name="getClassCodes" output="false" returntype="query">

		<cfargument name="prodGroupId" required="false" default="" />
		<cfargument name="lExcludeProdGroup" required="false" default="" />
		<cfargument name="programId" required="false" default="0" />
		<cfargument name="restrictOnClassCode" required="false" default="0" />
		<cfargument name="restrictOnClassCodeList" required="false" default="" />
		<cfargument name="byPassUserClassCodeRestriction" required="false" default="0" type="boolean" />
		<cfargument name="OnlyEZProducts" required="false" default="" />
		<cfargument name="EZbutton_On" required="false" default="0" />
		<cfargument name="suppressGroups" required="false" default="0" />


		<cfset userClassCodeID = "" />

		<!---get the Responsible_User_ID to filter on from contract main--->
		<cfif arguments.programId neq 0 and isNumeric(arguments.programId)>

			<cfquery name="qGetRespseUserId" datasource="#application.datasource#">
				SELECT	Responsible_User_ID
				FROM	Contract_Main
				WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.programId#" />
			</cfquery>

			<cfif qGetRespseUserId.RecordCount>
				<cfset userClassCodeID = qGetRespseUserId.Responsible_User_ID />
			</cfif>

		</cfif>

		<!---get the class codes from the BusinessSegmentManager object--->
		<cfif Len(trim(arguments.prodGroupId))>

			<!---get the class codes--->
			<cfquery name="qGetClassCodes" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">

				SELECT	DISTINCT Class_Code.Class_Code_UUID as Product_Group_ID,
						Class_Code_Desc as Group_Level_Desc,
						4 as Product_Group_Level_Type,
						'' as Hierarchy_Level,
						'' as Parent_Hierarchy_ID,
						Class_Code as Group_ID
				FROM 	Class_Code
						<!---TSF - Label 11075: Check to see if there are any items for this group. If there are not then return nothing--->
						<cfif arguments.suppressGroups>
						INNER JOIN Product_Customer_Group ON Product_Customer_Group.Class_Code_UUID = Class_Code.Class_Code_UUID
						</cfif>
						<!---TSF: Label 10767 - Bypass user class code restriction when loading from Rebate.cfc--->
						<cfif not arguments.byPassUserClassCodeRestriction>
							INNER JOIN User_Class_Code ON
							Class_Code.Class_Code_ID = User_Class_Code.Class_Code_Id
							AND User_Class_Code.User_ID = '#userClassCodeID#'
							AND User_Class_Code.Deleted = 0
						</cfif>
				WHERE 	Class_Code.Deleted = 0
				AND		Class_Code_UUID IN (#ListQualify(arguments.prodGroupId, "'", ",")#)
				<!---exclude on list if passed--->
				<cfif Len(trim(arguments.lExcludeProdGroup))>
				AND		Class_Code_UUID NOT IN (#ListQualify(arguments.lExcludeProdGroup, "'", ",")#)
				</cfif>
				<cfif arguments.restrictOnClassCode>
					<cfif arguments.restrictOnClassCodeList EQ "">
					AND		1=2
					<cfelse>
					AND		Class_Code_UUID IN (#ListQualify(arguments.restrictOnClassCodeList, "'", ",")#)
					</cfif>
				</cfif>
				<cfif arguments.EZbutton_On EQ 1>
					<cfif Len(arguments.OnlyEZProducts) EQ 0>
						1=2
					<cfelse>
						Class_Code_UUID IN (#ListQualify(arguments.OnlyEZProducts, "'", ",")#)
					</cfif>
				</cfif>
			</cfquery>
<!--- 			<cfset qClassCodes = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").getClasscode(arguments.prodGroupId) /> --->

		<cfelse>

			<cfset qClassCodes = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").getActiveClasscodes(userClassCodeID, 0, arguments.suppressGroups) />

			<!---do a query on query do modify column names--->
			<cfquery name="qGetClassCodes" dbtype="query">

				SELECT	Class_Code_UUID as Product_Group_ID,
						Class_Code_Desc as Group_Level_Desc,
						4 as Product_Group_Level_Type,
						'' as Hierarchy_Level,
						'' as Parent_Hierarchy_ID,
						Class_Code as Group_ID
				FROM 	qClassCodes
				WHERE	1=1
				<!---exclude on list if passed--->
				<cfif Len(trim(arguments.lExcludeProdGroup))>
				AND	Class_Code_UUID NOT IN (#ListQualify(arguments.lExcludeProdGroup, "'", ",")#)
				</cfif>
				<cfif arguments.restrictOnClassCode>
					<cfif arguments.restrictOnClassCodeList EQ "">
					AND		1=2
					<cfelse>
					AND		Class_Code_UUID IN (#ListQualify(arguments.restrictOnClassCodeList, "'", ",")#)
					</cfif>
				</cfif>
				<cfif arguments.EZbutton_On EQ 1>
					<cfif Len(arguments.OnlyEZProducts) EQ 0>
						1=2
					<cfelse>
						Class_Code_UUID IN (#ListQualify(arguments.OnlyEZProducts, "'", ",")#)
					</cfif>
				</cfif>
			</cfquery>

		</cfif>

		<cfreturn qGetClassCodes />

	</cffunction>

	<cffunction name="getBusinessSegments" output="false">

		<cfargument name="suppressGroups" required="false" default="0" />

		<CFQUERY NAME="qGetBusinessSegment" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">

			SELECT 	DISTINCT NEWID() as Product_Group_ID,
					Business_Unit_Desc as Group_Level_Desc,
					1 as Product_Group_Level_Type,
					'' as Hierarchy_Level,
					'' as Parent_Hierarchy_ID
			FROM 	Business_Segment
					<!---TSF - Label 11075: Check to see if there are any items for this group. If there are not then return nothing--->
					<cfif arguments.suppressGroups>
					INNER JOIN Product_Customer_Group ON Product_Customer_Group.Business_Segment_ID = Business_Segment.Business_Segment_ID
					</cfif>
			WHERE	Deleted = 0
		</CFQUERY>

		<cfreturn qGetBusinessSegment />

	</cffunction>


	<!------ This function gets the product group values dynamically using the ProductGroupAttributeManager component ----->
	<cffunction name="getProductGroupAttributeValues" output="false" returntype="query">

		<cfargument name="productGroupLevelId" required="true" />
		<cfargument name="programId" required="true" type="numeric" />
		<cfargument name="prodGroupId" required="false" default="" />
		<cfargument name="restrictOn" required="false" default="0" />
		<cfargument name="restrictOnProductGroupList" required="false" default="" />
		<cfargument name="lExcludeProdGroup" required="false" default="" />
		<cfargument name="arGroupMembers" required="false" default="#ArrayNew(1)#" type="array" />
		<cfargument name="OnlyEZProducts" required="false" default="" />
		<cfargument name="EZbutton_On" required="false" default="0" />
		<cfargument name="suppressGroups" required="false" default="0" />
		<cfargument name="IncludeDeleted" required="false" default="0" />
    	<cfargument name="FirstParentID" type="string" required="false" />
		<cfargument name="setGroupTemplateSelectionOn" type="any" required = "false" default="0" />
		<cfargument name="TemplateFiltersID" type="numeric" required="false" default="0" />
		<cfargument name="businessSegmentId" required="false" type="numeric" default="0">
		<cfargument name="IncludeActiveOnly" required="false" default="1" />
        <cfargument name="plannerId" type="numeric" required="false" default="0" />

    <cfset arAllowLists = ArrayNew(1) />

		<!------ Build the allow group list array, from template restrictions ----->
		<cfif arguments.restrictOn>
			<cfset ArrayAppend(arAllowLists, arguments.restrictOnProductGroupList) />
		</cfif>
		<cfif arguments.EZbutton_On>
			<cfset ArrayAppend(arAllowLists, arguments.OnlyEZProducts) />
		</cfif>

		<!------ Build the allow group list array, from prodGroupId ----->
		<cfif Len(arguments.prodGroupId) GT 0>
			<cfset ArrayAppend(arAllowLists, arguments.prodGroupId) />
		</cfif>


		<!------ operating group ----->
		<!--- check to see if operating group are turned on --->
		<cfset GenSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />

		<!--- <cfif genSettingsManager.get(1, 2).getOperatingGroupOn()> --->
		<cfif appSettings.getOperatingGroupOn()>
			<cfset operatingGroupManager 			= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
			<!------ Find the operating group level 1 for the program ----->
			<cfset operatingGroupSelectLevel		= operatingGroupManager.getProductGroupSelectLevel() />
			<cfset operatingGroupSelectLevelValue	= operatingGroupManager.getProgramOperatingGroupID(level=operatingGroupSelectLevel, programId=arguments.programId) />
			<cfif isnumeric(operatingGroupSelectLevelValue)>
				<cfset qGetProductGroupSelection 		= operatingGroupManager.getProductGroupSelection(operatingGroupId = operatingGroupSelectLevelValue, productGroupLevelId = arguments.productGroupLevelId) />
				<cfset opGroupRestrictOnGroupList 		= ValueList(qGetProductGroupSelection.Group_ID, ",") />
				<!------ Build the allow group list array, from operating group restriction ----->
				<cfif Len(opGroupRestrictOnGroupList) GT 0>
					<cfset ArrayAppend(arAllowLists, opGroupRestrictOnGroupList) />
				</cfif>
			</cfif>
		</cfif>

		<cfset productGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
			<cfif arguments.productGroupLevelId EQ "">
				<cfset arguments.productGroupLevelId = "0" />
			</cfif>
		<cfset stProductGroupType = productGroupAttributeManager.getGroupTypeInfo(groupLevelId = arguments.productGroupLevelId) />
		<cfset qGetProductGroupAttributeValues = productGroupAttributeManager.getProductGroupValuesExt
												(productGroupType 	= stProductGroupType,
												arAllowLists		= arAllowLists,
												excludeGroupList 	= arguments.lExcludeProdGroup,
												arGroupMembers		= arguments.arGroupMembers,
												suppressGroups		= arguments.suppressGroups,
												IncludeDeleted		= arguments.IncludeDeleted,
                        						FirstParentID     	= arguments.FirstParentID,
												setGroupTemplateSelectionOn = arguments.setGroupTemplateSelectionOn,
												TemplateFiltersID	= arguments.TemplateFiltersID,
												businessSegmentId 	= arguments.businessSegmentId,
												IncludeActiveOnly   = arguments.IncludeActiveOnly,
                                                plannerId           = arguments.plannerId

                        ) />

		<cfreturn qGetProductGroupAttributeValues />

	</cffunction>

	<cffunction name="getPricingLevel" output="false" returntype="query">

		<cfargument name="levelId" required="false" default="0" />

		<CFQUERY NAME="qGetPricingLevel" datasource="#application.datasource#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
			SELECT 	Pricing_Level_ID,
					Pricing_Level_Desc,
					Pricing_Level_Label
			FROM 	Pricing_Level
			WHERE	Deleted = 0
			<cfif arguments.levelId NEQ 0>
			AND		Pricing_Level_ID = <cfqueryparam value="#arguments.levelId#" cfsqltype="CF_SQL_INTEGER">
			</cfif>
		</CFQUERY>

		<cfreturn qGetPricingLevel />

	</cffunction>

	<cffunction name="getPricingLevelDesc" output="false" returntype="string">

		<cfargument name="levelId" required="false" default="0" />

		<cfset qGetPricingLevel = getPricingLevel(arguments.levelId) />

		<cfset returnString = "" />
		<cfif qGetPricingLevel.recordCount>
			<cfset returnString = qGetPricingLevel.Pricing_Level_Desc />
		</cfif>

		<cfreturn returnString />

	</cffunction>

	<cffunction name="getParentHierarchy" output="false" returntype="query">

		<cfargument name="productHierarchyId" required="false" default="" />

		<CFQUERY NAME="qGetParentHierarchy" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">

			SELECT 	Product_Hierarchy_ID,
					Parent_Product_Hierarchy_ID,
					Product_Hierarchy,
					Product_Hierarchy_Level,
					Product_Hierarchy_Name
			FROM 	udf_GetProductChain('#arguments.productHierarchyId#')

			ORDER BY Product_Hierarchy_Level

		</CFQUERY>

		<cfreturn qGetParentHierarchy />

	</cffunction>

	<cffunction name="getGroupLevelIdByHierLevel" output="false" returntype="query">

		<cfargument name="productHierarchyId" required="false" default="" />

		<CFQUERY NAME="qGetParentHierarchy" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">

			SELECT 	Product_Hierarchy_ID,
					Parent_Product_Hierarchy_ID,
					Product_Hierarchy,
					Product_Hierarchy_Level
			FROM 	udf_GetProductChain('#arguments.productHierarchyId#')

		</CFQUERY>

		<cfreturn qGetParentHierarchy />

	</cffunction>

	<cffunction name="getDummyId" output="false">

		<cfargument name="grpLevelId" required="false" default="" />

		<cfset useLakebaseForqGetDummyProductId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_product")>
<cfif useLakebaseForqGetDummyProductId>
	<cftry>
		<cfset qGetDummyProductId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_group_product", {
				"deleted" = "eq.0",
				"product_group_level_id" = "eq.#arguments.grpLevelId#",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDummyProductId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDummyProductId>
<CFQUERY NAME="qGetDummyProductId" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">

			SELECT	Product_ID
			FROM	Product_Group_Product
			WHERE	Deleted = 0
			AND		Product_Group_Level_ID = #arguments.grpLevelId#

		</CFQUERY>
</cfif>

		<cfreturn qGetDummyProductId.Product_ID />

	</cffunction>

	<cffunction name="isGroupDeal" output="false">

		<cfargument name="programId" required="true" type="numeric">

		<CFQUERY NAME="qGetAnyGroupDealProduct" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,0,30)#">

			SELECT 	TOP 1 Contract_Products.Contract_Main_ID
			FROM	Contract_Products
					LEFT JOIN Product_Group_Level
					ON
					Product_Group_Level.Deleted = 0
					AND Product_Group_Level.Product_Group_Level_ID = Contract_Products.Product_Group_Level_ID
					AND Product_Group_Level.Product_Group_Level_Type <> 0
			WHERE	Contract_Products.Contract_Main_ID = #arguments.programId#
			AND		Contract_Products.Deleted = 0
			AND		Contract_Products.Is_Group = 1

		</CFQUERY>

		<cfreturn qGetAnyGroupDealProduct.recordCount />

	</cffunction>

	<cffunction name="isXMaterialNotInMaterialMaster" output="false">

		<cfargument name="programId" required="true" type="numeric">

		<CFQUERY NAME="qGetAnyXMaterialNotInMaterialMaster" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">

			SELECT	Contract_Products.Contract_Products_ID,
					CASE
					WHEN Product_Group_Level.Product_Group_Level_Type = 2 THEN
						Product_Hierarchy.Product_Hierarchy
					WHEN Product_Group_Level.Product_Group_Level_Type = 3 THEN
						Type_Group_Desc.Type_Group_Legacy
					ELSE
						''
					END As Group_ID,
					CASE
					WHEN Product_Group_Level.Product_Group_Level_Type = 2 THEN
						ISNULL(hParent.Product_Hierarchy_Name, '') +
						(CASE
						WHEN hParent.Product_Hierarchy_Name IS NOT NULL THEN
							' \ '
						ELSE
							''
						END)
						 + Product_Hierarchy.Product_Hierarchy_Name
					WHEN Product_Group_Level.Product_Group_Level_Type = 3 THEN
						Type_Group_Desc.Type_Group_Desc
					ELSE
						''
					END As Group_Desc

			FROM	Contract_Main
				INNER JOIN Contract_Products
				ON
				Contract_Products.Contract_Main_ID = Contract_Main.Contract_Main_ID
				AND
				Contract_Products.Deleted = 0
				INNER JOIN Product_Group_Level
				ON
				Product_Group_Level.Product_Group_Level_ID = Contract_Products.Product_Group_Level_ID
				<!------ Product Hierarchy ----->
				LEFT JOIN Product_Hierarchy
				ON
				Product_Hierarchy.Deleted = 0
				AND CAST(Product_Hierarchy.Product_Hierarchy_ID AS NVARCHAR(50)) = Contract_Products.Product_group_ID
				AND Product_Group_Level.Product_Group_Level_Type = 2
				AND
				(
					(
					Product_Hierarchy.Product_Hierarchy_Level <= 5
					AND 'X' + Product_Hierarchy.Product_Hierarchy
					NOT IN
					(
						SELECT DISTINCT Item
						FROM	BSA_Foodservice_Items_Master
						WHERE	Deleted = 0
							AND Left(Item, 1) = 'X'
					)
					)
					OR
					(
					Product_Hierarchy.Product_Hierarchy_Level = 6
					AND 'x' + Left(Product_Hierarchy.Product_Hierarchy, 14)
					NOT IN
					(
						SELECT DISTINCT Item
						FROM	BSA_Foodservice_Items_Master
						WHERE	Deleted = 0
							AND Left(Item, 1) = 'x'
					)
					)
				)
				LEFT JOIN Product_Hierarchy hParent
				ON
				hParent.Deleted = 0
				AND hParent.Product_Hierarchy_ID = Product_Hierarchy.Parent_Product_Hierarchy_ID
				AND Product_Hierarchy.Product_Hierarchy_Level > 1
				<!------ Type Group / Label ----->
				LEFT JOIN Type_Group_Desc
				ON
				Type_Group_Desc.Deleted = 0
				AND CAST(Type_Group_Desc.Type_Group_Desc_ID AS NVARCHAR(50)) = Contract_Products.Product_group_ID
				AND Product_Group_Level.Product_Group_Level_Type = 3
				AND NOT EXISTS
				(
					SELECT TOP 1 Item
					FROM	BSA_Foodservice_Items_Master
					WHERE	Deleted = 0
						AND Item = 'PLABEL'
				)
			WHERE
				Contract_Main.Contract_Main_ID = #arguments.programId#
				AND
				(
					(
					Product_Group_Level.Product_Group_Level_Type = 2
					AND Product_Hierarchy.Product_Hierarchy_ID IS NOT NULL
					)
					OR
					(
					Product_Group_Level.Product_Group_Level_Type = 3
					AND Type_Group_Desc.Type_Group_Desc_ID IS NOT NULL
					)
				)
		</CFQUERY>

		<cfreturn qGetAnyXMaterialNotInMaterialMaster />

	</cffunction>

	<cffunction name="getGroupsForProgram" output="false">

		<cfargument name="programId" required="true" type="numeric">
		<cfargument name="productTypeId" required="false" default="">

		<CFQUERY NAME="qGetGroupsProgram" datasource="#application.datasource#">

			SELECT 	Contract_Products.Product_Group_Level_ID,
					Contract_Products.Product_Group_ID,
					Contract_Products.Pricing_Level_ID,
					Contract_Products.Product_Type_ID
			FROM	Contract_Products
					INNER JOIN Product_Group_Level
					ON
					Product_Group_Level.Deleted = 0
					AND Product_Group_Level.Product_Group_Level_ID = Contract_Products.Product_Group_Level_ID
					AND Product_Group_Level.Product_Group_Level_Type <> 0
			WHERE	Contract_Products.Contract_Main_ID = #arguments.programId#
			AND		Contract_Products.Deleted = 0
			AND		Contract_Products.Is_Group = 1
			<cfif trim(arguments.productTypeId) neq "">
			AND		Contract_Products.Product_Type_ID = #arguments.productTypeId#
			</cfif>

		</CFQUERY>

		<cfreturn qGetGroupsProgram />

	</cffunction>

	 <!--- D35295  --->
	<cffunction name="getItemsInMultiAttrGroup" output="false" returntype="Query" >
		<cfargument name="ProductGroupId" required="false" default="" />
		<cfargument name="TemplateId" required="false" default="0" />
		<cfargument name="programId" required="false" default="" />
		<cfargument name="producttype_id" required="false" default="" />
		<cfscript>
			var prgId = 0;
			if(arguments.programId != ''){
				prgId = arguments.programId;
			}
		</cfscript>
		<CFQUERY NAME="qGetMultiAttrItems" datasource="#application.datasource#">
			EXEC Get_Multi_Product_Attr_Group_Members '#arguments.ProductGroupId#', #arguments.TemplateId#, #prgId#,0,#producttype_id#
		</CFQUERY>

		<cfreturn qGetMultiAttrItems />
	</cffunction>

	<cffunction name="getItemsInGroup" output="false">

		<cfargument name="groupId" required="false" default="" />
		<cfargument name="groupLevelId" required="false" default="" />
		<cfargument name="programId" required="false" default="" />
		<cfargument name="producttype_id" required="false" default="" />
		<cfargument name="cacheQuery" required="false" default="1" />
		<cfargument name="ItemBusSegID" required="false" default="" />
   		<cfargument name=templateFiltePRogramID required="false" default="0" /><!--- D34317 Incorrect group items in pop-up --->
		<cfargument name="EZTemplate" required="false" default="0" />

		<cfset var categoryList = "" />
		<cfset var lineOfBusiness = "" />
		<cfset var businessSegment = "" />
		<cfset cacheTimeSpan = this.timeSpan />
  	<cfif arguments.cacheQuery EQ 0>
			<cfset cacheTimeSpan = CreateTimeSpan(0, 0, 0, 0) />
	</cfif>

		<cfset qGetGroup = this.getProductGroupsData(productGroupId=arguments.groupLevelId, isActive=0) />


		<!---set the group type--->
		<cfset groupType = qGetGroup.Product_Group_Level_Type />
    <cfset isPG = qGetGroup.Is_PG />

		<!---set hierarchy level--->
		<cfset hLevel = qGetGroup.Hierarchy_Level />

		<cfset isDynamic = 0 />
		<!---if program was passed then check to see if this is dynamic. if it is then set is dynamic to high--->
		<cfif trim(arguments.programId) neq "">

			<cfset useLakebaseForqCheckDynamic = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_products")>
<cfif useLakebaseForqCheckDynamic>
	<cftry>
		<cfset qCheckDynamic = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_products", {
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.programId#",
				"is_group" = "eq.1",
				"dynamic_static_groups" = "eq.1",
				"limit" = "1",
				"select" = "contract_products_id"
			}), "contract_products_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckDynamic = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckDynamic>
<cfquery name="qCheckDynamic" datasource="#application.datasource#">
				SELECT TOP 1 Contract_Products_ID
				FROM	Contract_Products
				WHERE	Deleted = 0
				AND		Contract_Main_ID = #arguments.programId#
				AND		Is_Group = 1
				AND		Dynamic_Static_Groups = 1
			</cfquery>
</cfif>

			<!---if we get a record then we know it's dynamic, so set it to 1--->
			<cfif qCheckDynamic.RecordCount>
				<cfset isDynamic = 1 />
			</cfif>

			<!---if we have a program id then check to see if there are any product category filters--->
			<cfset categoryList = CreateObject("component", "components.products.Category.ProductCategory").getCategoryFiltersByProgram(arguments.programId) />
			<!---check to see if line of business is turned on--->
			<cfset generalSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<cfset lobOn = generalSettingsManager.get(1, 2).getSalesOrgOn() >
			<!---if lob is on then get the lob id--->
			<cfif lobOn eq 1>

				<cfset useLakebaseForqGetProgramLob = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetProgramLob>
	<cftry>
		<cfset qGetProgramLob = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.programId#",
				"select" = "line_of_business_id"
			}), "line_of_business_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramLob = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramLob>
<cfquery name="qGetProgramLob" datasource="#application.datasource#">
					SELECT	Line_Of_Business_ID
					FROM	Contract_Main
					WHERE	Deleted = 0
					AND		Contract_Main_ID = '#arguments.programId#'
				</cfquery>
</cfif>

				<cfset lineOfBusiness = qGetProgramLob.Line_Of_Business_ID />

			</cfif>

			<!---check to see if business segment is enabled  isEnabled()--->
				<!--- D28304program and current group items,considering business segment settings : changed isEnable to isEnabledForProduct--->
			<cfset busSegManager = CreateObject("component", "components.Programs.business_segment.BusinessSegmentManager")>
			<cfset busSegEnabled = busSegManager.isEnabledForProduct() />
			<!---if it's enabled then get the business segment id--->
			<cfif busSegEnabled>

				<cfset useLakebaseForqGetProgramBusSegId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetProgramBusSegId>
	<cftry>
		<cfset qGetProgramBusSegId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"deleted" = "eq.0",
				"contract_main_id" = "eq.#arguments.programId#",
				"select" = "business_segment_id"
			}), "business_segment_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramBusSegId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramBusSegId>
<cfquery name="qGetProgramBusSegId" datasource="#application.datasource#">
					SELECT	Business_Segment_ID
					FROM	Contract_Main
					WHERE	Deleted = 0
					AND		Contract_Main_ID = '#arguments.programId#'
				</cfquery>
</cfif>

				<cfset businessSegment = qGetProgramBusSegId.Business_Segment_ID />


			<cfset qryBusSegList = busSegManager.getBusinessSegmentTemplateSettings() />
			<cfset BusSegList = valueList(qryBusSegList.Business_Segment_ID)>

				<cfset bBusinessSettingONinTemplate = 0 />
				<cfif appSettings.Filter_Business_Segments EQ 1>
					<cfset bBusinessSettingONinTemplate = 1 />
				</cfif>
			</cfif>

		</cfif>
		<cfset useGroupWhereClause = 0 />
<!--- D34317 Incorrect group items in pop-up --->
		<cfif isNumeric(arguments.templateFiltePRogramID) and arguments.templateFiltePRogramID gt 0>
			<cfset local.programID = arguments.templateFiltePRogramID>
		<cfelseif isNumeric(arguments.programID) and arguments.programID gt 0>
			<cfset local.programID = arguments.programID>
		<cfelse>
			<cfset local.programID = 0>
		</cfif>
		<cfif local.programID neq 0>
			<cfquery name="qGetFirstParentID" datasource="#application.datasource#">
				SELECT First_Parent_Id
				  FROM PROGRAM_CONTROL_PANEL_OPTIONS
				 WHERE ProgramControl_Panel_Options_Id = ( SELECT ProgramType_Id
				                                             FROM CONTRACT_MAIN
				                                            WHERE Contract_Main_Id = <cfqueryparam value="#local.programID#"  cfsqltype="cf_sql_integer"> )
			</cfquery>
			<cfset FirstParentID = qGetFirstParentID.First_Parent_ID />
			<cfset ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
			<cfset qGetProductGroupAttributesGroupTemplate = ProductGroupAttributeManager.getProductGroupAttributesGroupTemplate(active=1,FirstParentID=FirstParentID) />
		</cfif>
	<!--- Get Items from the Mini Item Master table (180 days table) for the groups --->


		<CFQUERY NAME="qGetItems" datasource="#application.datasource#" cachedwithin="#cacheTimeSpan#">

			SELECT DISTINCT Item,
					     UPC,
					     Description
			FROM 	BSA_Foodservice_Items_Master
		  <!--- Planning Group --->
	<cfif trim(arguments.programId) eq ""><!--- D34317 Incorrect group items in pop-up////Moved from line 1084--->
	        <cfif isPG EQ 1>
		            INNER JOIN PG_Product_Members PGPM
					ON PGPM.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		            AND PGPM.PG_Product_Category_ID = '#arguments.groupId#'
		            AND PGPM.PG_Type_ID = #groupType#
			</cfif>
     		<cfif isDefined("qGetProductGroupAttributesGroupTemplate")>
				<cfloop query="qGetProductGroupAttributesGroupTemplate">
	          		<!--- We need to filter the search results in 2 situations
					-- Tempalte is filtered on a product group
					-- A drop down value is selected
					 --->
					<!--- do this only for planning groups --->
					<!--- Below logic is to add extra JOINs on planning group tables so that we can filter later in the where clause --->
					<cfset typeId = qGetProductGroupAttributesGroupTemplate.Group_Level_ID />
					<cfset ProductAttributeDropDownName = "Product_Attribute_#qGetProductGroupAttributesGroupTemplate.Group_Level_ID#" />

					<cfif qGetProductGroupAttributesGroupTemplate.PG_Flag>
					<cfset applyThisGroupInFilter = 0 />
					<cfset ProductAttributeDropDownName = "Product_Attribute_#qGetProductGroupAttributesGroupTemplate.Group_Level_ID#" />

					<cfif qGetProductGroupAttributesGroupTemplate.Allow_Filter><!--- Tempalte is filtered on a product group --->
						<cfset applyThisGroupInFilter = 1 />
					<cfelseif isDefined("#ProductAttributeDropDownName#")>
						<cfset ProductAttributeDropDownValue = Evaluate("#ProductAttributeDropDownName#") />
						<cfif ProductAttributeDropDownValue NEQ "" AND ProductAttributeDropDownValue NEQ "0"><!--- A drop down value is selected --->
			                <cfset applyThisGroupInFilter = 1 />
						</cfif>
					</cfif>
					<cfif applyThisGroupInFilter>
						INNER JOIN PG_Product_Members as PGPM_#typeId#
		                ON		PGPM_#typeId#.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
		                INNER JOIN PG_Product_Category as PGPC_#typeId#
		                ON		PGPC_#typeId#.PG_Product_Category_ID = PGPM_#typeId#.PG_Product_Category_ID
					</cfif>
				</cfif>
        		</cfloop>
			</cfif>


					<!---type group--->
					<cfif groupType eq 3>

						INNER JOIN Type_Group_Desc ON
						BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
						AND Type_Group_Desc.Type_Group_Desc_ID = '#arguments.groupId#'

					<!---class code--->
					<cfelseif groupType eq 4>

						INNER JOIN Class_Code ON
						Class_Code.Class_Code_ID = BSA_Foodservice_Items_Master.Class_Code_ID
						AND Class_Code.Class_Code_UUID = '#arguments.groupId#'

					<!---q brand--->
					<cfelseif groupType eq 5>

						INNER JOIN Q_Brand_Desc ON
						Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID
						AND Q_Brand_Desc.Q_Brand_ID = '#arguments.groupId#'

					<!---type code desc--->
					<cfelseif groupType eq 6>

						INNER JOIN Type_Code_Desc ON
						Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
						AND Type_Code_Desc.Type_Code_Desc_ID = '#arguments.groupId#'

					<!---brand--->
					<cfelseif groupType eq 7>

						INNER JOIN Brand ON
						Brand.Brand_ID = BSA_Foodservice_Items_Master.Brand_ID
						AND Brand.Brand_ID = '#arguments.groupId#'

					<!---brand--->
					<cfelseif groupType eq 8>

						INNER JOIN BSA_Product_Group ON
						BSA_Product_Group.BSA_Product_Group_ID = BSA_Foodservice_Items_Master.BSA_Product_Group_ID
						AND BSA_Product_Group.BSA_Product_Group_ID = '#arguments.groupId#'

					<!---default to nothing--->
					<cfelse>

					<!--- Dev Note: Milan; 8493. If it's not product hierarchy --->
					<cfif groupType neq 2>
						<cfset useGroupWhereClause = 1 />
					</cfif>

					</cfif>
			  </cfif>

				<!---filter if a program id was passed--->
				<cfif trim(arguments.programId) neq "">

					INNER JOIN Contract_Products ON
					Contract_Products.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
					AND Contract_Products.Contract_Main_ID = #arguments.programId#
					AND Contract_Products.Deleted = 0
					AND Contract_Products.Is_Group = 0
					<cfif arguments.producttype_id NEQ "">
					and contract_products.product_type_id = '#arguments.producttype_id#'
					</cfif>
					<!---if it's dynamic--->
					<cfif isDynamic>

						INNER JOIN Contract_Main ON
						Contract_Main.Contract_Main_ID = Contract_Products.Contract_Main_ID
						AND Contract_Main.Deleted = 0
						INNER JOIN Group_Members ON
						Group_Members.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND CAST(Group_Members.Product_Group_ID AS NVARCHAR(50)) = Contract_Products.Product_Group_ID
						AND Group_Members.Start_Date < Contract_Main.Contract_Start_Date
						AND Group_Members.End_Date > Contract_Main.Contract_End_Date

					</cfif>

				</cfif>

				WHERE 1=1

				<!---if a program id wasn't passed then get items based off of what's in item master--->
				<cfif trim(arguments.programId) eq "">

					AND BSA_Foodservice_Items_Master.Active_Code = 'A'
					AND BSA_Foodservice_Items_Master.Deleted = 0

				</cfif>

				<cfif trim(arguments.programid) eq "">

				<cfif groupType eq 2>

					AND	Product_Hierarchy_ID IN
					(
						SELECT 	Product_Hierarchy_ID
						FROM 	udf_GetProductChainBelow('#arguments.groupId#')
						WHERE	Product_Hierarchy_Level = #this.getNumberHierarchyLevels()#
					)

				</cfif>

				<cfif trim(categoryList) neq "">
					AND BSA_Foodservice_Items_Master.Category_ID IN (#ListQualify(categoryList,"'",",","ALL")#)
				</cfif>

				<cfif trim(arguments.programId) neq "" and trim(lineOfBusiness) neq "">
					AND BSA_Foodservice_Items_Master.Line_Of_Business_ID = '#lineOfBusiness#'
				</cfif>

				<cfset busSegEnabled = CreateObject("component", "components.Programs.business_segment.BusinessSegmentManager").isEnabledForProduct() />

				<!--- "Program ID" can not only exist from inside a program, but also inside a template, when the template is an Ezbutton template
				and the programID is of the Ezbutton template.
				Note: "Contract_Number" for Ezbutton templates start with "TMP".
				--->
				<cfif trim(arguments.programId) neq "" AND busSegEnabled>
					<!--- If the request is from anEzbutton template, --->
					<cfif arguments.EZTemplate EQ 1>
						<cfif bBusinessSettingONinTemplate EQ 1 AND BusSegList neq "">
							AND BSA_Foodservice_Items_Master.Business_Segment_ID IN (#BusSegList#)
						</cfif>
					<cfelse>
						<cfif trim(businessSegment) neq "">
							AND BSA_Foodservice_Items_Master.Business_Segment_ID = #businessSegment#
						<!--- It seems like that in this case, we are not always using "business_segment_ID" from the "contract_main_table".
						Sometimes it can be used from the "business_segment" table and that is why this condition is important too.
						--->
						<cfelseif arguments.ItemBusSegID neq "" and arguments.ItemBusSegID neq 0>
							AND BSA_Foodservice_Items_Master.Business_Segment_ID = #arguments.ItemBusSegID#
						</cfif>
					</cfif>
				</cfif>
				<cfif useGroupWhereClause AND isPG EQ 0>
					<cfset productGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init() />
					<cfset stProductGroupType = productGroupAttributeManager.getGroupTypeInfo(groupLevelTypeId = groupType) />
					AND BSA_Foodservice_Items_Master.#stProductGroupType.MasterIDField# = '#arguments.groupId#'
      			  <cfelseif useGroupWhereClause AND isPG EQ 1>
          			 AND PGPM.PG_Product_Category_ID = '#arguments.groupId#'
				</cfif>

				<!---  D28878: Results mismatch in the product search screens - Anand Rao/19-Oct-2011 --->
				<cfif (isDefined("qGetProductGroupAttributesGroupTemplate") AND qGetProductGroupAttributesGroupTemplate.RecordCount GTE 1)>
					<cfloop query="qGetProductGroupAttributesGroupTemplate">
						<cfset ProductAttributeDropDownName = "Product_Attribute_#qGetProductGroupAttributesGroupTemplate.Group_Level_ID#" />
						<cfset typeId = qGetProductGroupAttributesGroupTemplate.Group_Level_ID />
						<cfif qGetProductGroupAttributesGroupTemplate.Allow_Filter>
						<!--- Template is filtered on a product group --->
							<cfif (qGetProductGroupAttributesGroupTemplate.PG_Flag EQ 0) AND (qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field NEQ "PG_Product_Category_ID")>
					    		AND CAST(BSA_Foodservice_Items_Master.#qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field# as varchar(50))
												IN (SELECT Product_group_ID FROM Product_Group_Template_Selection
												WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 0 AND
												Template_ID = #FirstParentID# AND
												Product_Group_Level_ID = #qGetProductGroupAttributesGroupTemplate.Group_Level_ID#)
             				<cfelse>
             			<!--- Planning groups / Anand Rao/10-Jan-2011 --->
                				AND PGPM_#typeId#.PG_Product_Category_ID IN (SELECT Product_group_ID
																				FROM Product_Group_Template_Selection
																				WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 1 AND
																				Template_ID = #FirstParentID#
																				AND Product_Group_Level_ID = #qGetProductGroupAttributesGroupTemplate.Group_Level_ID#)
             				</cfif>
						</cfif>
						<cfif isDefined("#ProductAttributeDropDownName#")>
							<cfset ProductAttributeDropDownValue = Evaluate("#ProductAttributeDropDownName#") />
							<cfif ProductAttributeDropDownValue NEQ "" AND ProductAttributeDropDownValue NEQ "0">
								<cfif (qGetProductGroupAttributesGroupTemplate.PG_Flag EQ 0) AND (qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field NEQ "PG_Product_Category_ID")>
						    		AND BSA_Foodservice_Items_Master.#qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field# = '#ProductAttributeDropDownValue#'
	             				<cfelse>
	                				AND PGPM_#typeId#.#qGetProductGroupAttributesGroupTemplate.Product_Group_Attribute_Master_ID_Field# = '#ProductAttributeDropDownValue#'
	             				</cfif>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>


				<cfelse>
				<!--- The Product_Group_ID is used to get the products belonging to a group for a program --->
					AND Contract_Products.Product_Group_ID =  '#arguments.groupId#'
				</cfif>
		</CFQUERY>

		<cfreturn qGetItems />

	</cffunction>


	<cffunction name="getGroupCount" output="false">

		<cfargument name="groupId" required="false" default="" />
		<cfargument name="groupLevelId" required="false" default="" />
		<cfargument name="programId" required="false" default="" />

		<cfset rThisCount = 0 />
		<cfset categoryList = "" />
		<cfset lineOfBusiness = "" />
		<cfset businessSegment = "" />

		<cfset qGetGroup = this.getProductGroupsData(arguments.groupLevelId) />

		<!---set the group type--->
		<cfset groupType = qGetGroup.Product_Group_Level_Type />

		<!---set hierarchy level--->
		<cfset hLevel = qGetGroup.Hierarchy_Level />

		<cfset isDynamic = 0 />
				<!---if program was passed then check to see if this is dynamic. if it is then set is dynamic to high--->
		<cfif trim(arguments.programId) neq "">

			<cfquery name="qCheckDynamic" datasource="#application.datasource#">
				SELECT TOP 1 Contract_Products_ID
				FROM	Contract_Products
				WHERE	Deleted = 0
				AND		Contract_Main_ID = #arguments.programId#
				AND		Is_Group = 1
				AND		Dynamic_Static_Groups = 1
			</cfquery>

			<!---if we get a record then we know it's dynamic, so set it to 1--->
			<cfif qCheckDynamic.RecordCount>
				<cfset isDynamic = 1 />
			</cfif>

			<!---if we have a program id then check to see if there are any product category filters--->
			<cfset categoryList = CreateObject("component", "components.products.Category.ProductCategory").getCategoryFiltersByProgram(arguments.programId) />
			<!---check to see if line of business is turned on--->
			<cfset generalSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
			<cfset lobOn = generalSettingsManager.get(1, 2).getSalesOrgOn() >
			<!---if lob is on then get the lob id--->
			<cfif lobOn eq 1>

				<cfquery name="qGetProgramLob" datasource="#application.datasource#">
					SELECT	Line_Of_Business_ID
					FROM	Contract_Main
					WHERE	Deleted = 0
					AND		Contract_Main_ID = '#arguments.programId#'
				</cfquery>

				<cfset lineOfBusiness = qGetProgramLob.Line_Of_Business_ID />

			</cfif>

			<!---check to see if business segment is enabled--->
				<!--- D28304program and current group items,considering business segment settings : changed isEnable to isEnabledForProduct--->
			<cfset busSegEnabled = CreateObject("component", "components.Programs.business_segment.BusinessSegmentManager").isEnabledForProduct() />
			<!---if it's enabled then get the business segment id--->
			<cfif busSegEnabled>

				<cfquery name="qGetProgramBusSegId" datasource="#application.datasource#">
					SELECT	Business_Segment_ID
					FROM	Contract_Main
					WHERE	Deleted = 0
					AND		Contract_Main_ID = '#arguments.programId#'
				</cfquery>

				<cfset businessSegment = qGetProgramBusSegId.Business_Segment_ID />

			</cfif>

		</cfif>

		<CFQUERY NAME="qGetItemCount" datasource="#application.datasource#">

			SELECT	Count(*) AS Count
			FROM 	BSA_Foodservice_Items_Master

					<!---type group--->
					<cfif groupType eq 3>

						INNER JOIN Type_Group_Desc ON
						BSA_Foodservice_Items_Master.Type_Group_Desc_ID = Type_Group_Desc.Type_Group_Desc_ID
						AND Type_Group_Desc.Type_Group_Desc_ID = '#arguments.groupId#'

					<!---class code--->
					<cfelseif groupType eq 4>

						INNER JOIN Class_Code ON
						Class_Code.Class_Code_ID = BSA_Foodservice_Items_Master.Class_Code_ID
						AND Class_Code.Class_Code_UUID = '#arguments.groupId#'

					<!---q brand--->
					<cfelseif groupType eq 5>

						INNER JOIN Q_Brand_Desc ON
						Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID
						AND Q_Brand_Desc.Q_Brand_ID = '#arguments.groupId#'

					<!---type code desc--->
					<cfelseif groupType eq 6>

						INNER JOIN Type_Code_Desc ON
						Type_Code_Desc.Type_Code_Desc_ID = BSA_Foodservice_Items_Master.Type_Code_Desc_ID
						AND Type_Code_Desc.Type_Code_Desc_ID = '#arguments.groupId#'

					<!---brand--->
					<cfelseif groupType eq 7>

						INNER JOIN Brand ON
						Brand.Brand_ID = BSA_Foodservice_Items_Master.Brand_ID
						AND Brand.Brand_ID = '#arguments.groupId#'

					<!---brand--->
					<cfelseif groupType eq 8>

						INNER JOIN BSA_Product_Group ON
						BSA_Product_Group.BSA_Product_Group_ID = BSA_Foodservice_Items_Master.BSA_Product_Group_ID
						AND BSA_Product_Group.BSA_Product_Group_ID = '#arguments.groupId#'

					<!---default to nothing--->
					<cfelse>

					</cfif>

				WHERE 1=1

				<!---if a program id wasn't passed then get items based off of what's in item master--->
				<cfif trim(arguments.programId) eq "">

					AND BSA_Foodservice_Items_Master.Active_Code = 'A'
					AND BSA_Foodservice_Items_Master.Deleted = 0

				</cfif>

				<cfif groupType eq 2>

					AND	Product_Hierarchy_ID IN
					(
						SELECT 	Product_Hierarchy_ID
						FROM 	udf_GetProductChainBelow('#arguments.groupId#')
						WHERE	Product_Hierarchy_Level = #this.getNumberHierarchyLevels()#
					)

				</cfif>

				<cfif trim(categoryList) neq "">
					AND BSA_Foodservice_Items_Master.Category_ID IN (#ListQualify(categoryList,"'",",","ALL")#)
				</cfif>

				<cfif trim(arguments.programId) neq "" and trim(lineOfBusiness) neq "">
					AND BSA_Foodservice_Items_Master.Line_Of_Business_ID = '#lineOfBusiness#'
				</cfif>

				<cfif trim(arguments.programId) neq "" and trim(businessSegment) neq "">
					AND BSA_Foodservice_Items_Master.Business_Segment_ID = #businessSegment#
				</cfif>

		</CFQUERY>

		<cfset rThisCount = qGetItemCount.Count />

		<cfreturn rThisCount />

	</cffunction>

	<cffunction name="getDistinctHierarchyLevel" output="false" returntype="query">

		<cfargument name="hierarchyLevel" required="false" default="0" />
		<cfargument name="getMaxLevel" required="false" default="0" />

		<cfquery name="qGetProductHierarchyLevels" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">
			SELECT	DISTINCT Product_Hierarchy_Level, Product_Group_Level.Group_Level_Desc
			FROM	Product_Hierarchy
					INNER JOIN Product_Group_Level
					ON
					Product_Group_Level.Deleted = 0
					AND Product_Group_Level.Hierarchy_Level = Product_Hierarchy_Level
			WHERE	Product_Hierarchy.Deleted = 0
			<cfif isNumeric(arguments.hierarchyLevel) AND arguments.hierarchyLevel GT 0>
			AND		Product_Group_Level.Hierarchy_Level = #arguments.hierarchyLevel#
			</cfif>
			<cfif arguments.getMaxLevel>
			AND	 Product_Hierarchy_Level >= (SELECT Max(Product_Hierarchy_Level) FROM Product_Hierarchy)
			</cfif>
		</cfquery>

		<cfreturn qGetProductHierarchyLevels />

	</cffunction>

	<cffunction name="getChildParentGroupLevelId" output="false">

		<cfargument name="groupLevelId" required="false" default="0" />
		<cfargument name="childParent" required="no" default="1" hint="1=child, 2=parent, 3=child of top level" />

		<cfset useLakebaseForqGetHierarchyLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_level")>
<cfif useLakebaseForqGetHierarchyLevel>
	<cftry>
		<cfset qGetHierarchyLevel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_group_level", {
				"deleted" = "eq.0",
				"product_group_level_id" = "eq.#arguments.groupLevelId#",
				"select" = "hierarchy_level"
			}), "hierarchy_level"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetHierarchyLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetHierarchyLevel>
<cfquery name="qGetHierarchyLevel" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">
			SELECT 	Hierarchy_Level
			FROM	Product_Group_Level
			WHERE	Deleted = 0
			AND  	Product_Group_Level_ID = #arguments.groupLevelId#
		</cfquery>
</cfif>

		<!---if childParent is 1 then get the child id--->
		<cfif arguments.childParent eq 1>
			<cfset hierarchyLevel = IncrementValue(qGetHierarchyLevel.Hierarchy_Level) />
		<!---if childParent is 2 then get the parent id--->
		<cfelseif arguments.childParent eq 2>
			<cfset hierarchyLevel = DecrementValue(qGetHierarchyLevel.Hierarchy_Level) />
		<!---if childParent is 3 then get the child of the top level--->
		<cfelseif arguments.childParent eq 3>
			<cfset hierarchyLevel = 2 />
		</cfif>

		<cfset useLakebaseForqGetGroupLevelId = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_level")>
<cfif useLakebaseForqGetGroupLevelId>
	<cftry>
		<cfset qGetGroupLevelId = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_group_level", {
				"deleted" = "eq.0",
				"hierarchy_level" = "eq.#hierarchyLevel#",
				"select" = "product_group_level_id"
			}), "product_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGroupLevelId = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGroupLevelId>
<cfquery name="qGetGroupLevelId" datasource="#application.datasource#" cachedwithin="#this.timeSpan#">
			SELECT 	Product_Group_Level_ID
			FROM	Product_Group_Level
			WHERE	Deleted = 0
			AND  	Hierarchy_Level = #hierarchyLevel#
		</cfquery>
</cfif>

		<cfreturn qGetGroupLevelId.Product_Group_Level_ID />

	</cffunction>

	<cffunction name="getAllParentGroupLevelId" output="false">

		<cfargument name="groupLevelId" required="false" default="0" />

		<!---if the group level id is an empty string then set it to 0--->
		<cfif trim(arguments.groupLevelId) eq "">
			<cfset arguments.groupLevelId = 0 />
		</cfif>

		<cfquery name="qGetHierarchyLevel" datasource="#application.datasource#">
			SELECT 	Hierarchy_Level
			FROM	Product_Group_Level
			WHERE	Deleted = 0
			AND  	Product_Group_Level_ID = #arguments.groupLevelId#
			AND		Hierarchy_Level IS NOT NULL
		</cfquery>

		<!---if we get a record count back then get the group level id's of parents--->
		<cfif qGetHierarchyLevel.RecordCount>

			<cfquery name="qGetAllParentGroupLevelId" datasource="#application.datasource#">
				SELECT 	Product_Group_Level_ID
				FROM	Product_Group_Level
				WHERE	Deleted = 0
				AND  	Hierarchy_Level <= #qGetHierarchyLevel.Hierarchy_Level#
			</cfquery>

		<!---return an empty query if a record doesn't exist--->
		<cfelse>

			<cfset qGetAllParentGroupLevelId = QueryNew("Product_Group_Level_ID") />
			<cfset QueryAddRow(qGetAllParentGroupLevelId)>
			<cfset QuerySetCell(qGetAllParentGroupLevelId, "Product_Group_Level_ID", "0")>


		</cfif>

		<cfreturn qGetAllParentGroupLevelId />

	</cffunction>

	<cffunction name="getNumberHierarchyLevels" output="false">

		<cfquery name="qGetNumberOfHierarchyLevels" datasource="#application.datasource#">

			SELECT	ISNULL(MAX(Product_Hierarchy_Level), 0) as NumberOfLevels
			FROM	Product_Hierarchy
			WHERE	Deleted = 0

		</cfquery>

		<cfreturn qGetNumberOfHierarchyLevels.NumberOfLevels />

	</cffunction>

	<cffunction name="getGroupsWithNoProducts" output="false" returnType="query">

		<cfargument name="programId" type="numeric" required="true" />
		<cfargument name="groupLevelId" type="numeric" required="true" />
		<cfargument name="groupLevelList" type="string" required="true" />
		<cfargument name="FirstParentID" type="string" required="false" />
		<cfargument name="setGroupTemplateSelectionOn" type="any" required= "false" default="0" />

		<cfset returnQuery = QueryNew("") />

		<cfset noProductsGroupList = "" />
		<cfif arguments.groupLevelList NEQ "" AND IsNumeric(arguments.groupLevelId)>

			<cfloop list="#arguments.groupLevelList#" index="thisGroup">

				<cfstoredproc procedure="PROGRAM_GROUPS_WITH_NO_PRODUCTS" datasource="#application.datasource#">

					<!--- cfprocparam tags --->
					<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value="#arguments.programId#" null="no">
					<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@PRODUCT_GROUP_LEVEL_ID" null="no" value="#arguments.groupLevelId#">
					<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_GROUP_ID" null="no" value="#thisGroup#">
					<cfprocparam type = "In" CFSQLType ="CF_SQL_BIT" dbVarName = "@@DYNAMIC_STATIC_GROUPS" value="0" null="no">

					<cfprocresult name = "qGetProductExist">

				</cfstoredproc>

				<cfif NOT qGetProductExist.recordCount>
					<cfset noProductsGroupList = ListAppend(noProductsGroupList, thisGroup) />
				</cfif>

			</cfloop>

			<cfif ListLen(noProductsGroupList) GT 0>
				<cfset returnQuery = getByProductGroupData(
					prodGroupLevelId = arguments.groupLevelId,
					prodGroupId = noProductsGroupList,
					programId = arguments.programId,
					isCombination = 1,
          FirstParentID  = arguments.FirstParentID,
					setGroupTemplateSelectionOn = arguments.setGroupTemplateSelectionOn
          ) />
			</cfif>

		</cfif>

		<cfreturn returnQuery />

	</cffunction>

<!--- New Function added for Inserting/Updating the value for the Filters --->
  <cffunction name="fnQryExistingProductData" output="false" returntype="query">
    <cfargument name="TemplateID"          required="true" type="numeric" />
    <cfargument name="TemplateFiltersID"   required="true" type="numeric" />
    <cfargument name="ProductGroupLevelID" required="true" type="numeric" />
    <cfargument name="bActive"             required="false" type="numeric"  default="0" />

    <cfquery name="qGetExistingData" datasource="#application.datasource#">
      SELECT  Product_Group_Template_Selection_ID,
              Template_ID,
              Product_Group_Level_ID,
              Product_Group_ID,
              Active,
              Deleted,
              Created_Date,
              Updated_Date,
              Created_By,
              Updated_BY,
              PG_Flag,
              Updated_From,
              Template_Filters_Id
      FROM    Product_Group_Template_Selection
      WHERE   Template_ID = #arguments.TemplateID#
      AND   Template_Filters_ID = #arguments.TemplateFiltersID#
      AND   Product_Group_Level_ID = #arguments.ProductGroupLevelID#
      AND 	Deleted = 0
      <cfif arguments.bActive EQ "1">
      	AND Active = 1 AND Deleted = 0
      </cfif>
    </cfquery>
    <cfreturn qGetExistingData />
  </cffunction>

  <cffunction name="fnSaveFilterDataProduct" output="false" returntype="string">
    <cfargument name="UserID"         required="true" type="string"  />
    <cfargument name="stForm"     required="true" default="" type="any" />
    <cfset returnValue = "0" />
    <!--- Update all the records to inactive before activating them again. --->
   <!---  <cftry> --->
    <cfset useLakebaseForqUpdateAllRecs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_template_selection")>
<cfif useLakebaseForqUpdateAllRecs>
	<cftry>
		<cfset application.oLakebase.updateRows("product_group_template_selection",
			{
				"template_id" = "eq.#arguments.stForm.TemplateID#",
				"template_filters_id" = "eq.#arguments.stForm.TemplateFiltersID#",
				"product_group_level_id" = "eq.#arguments.stForm.GroupLevelID#"
			},
			{
				"active" = "0",
				"deleted" = "1",
				"updated_by" = "#arguments.UserID#",
				"updated_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateAllRecs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateAllRecs>
<cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
      UPDATE Product_Group_Template_Selection
      SET Active = 0,
          Deleted = 1,
          Updated_By = '#arguments.UserID#',
          Updated_Date = GetDate()
      WHERE   Template_ID = #arguments.stForm.TemplateID#
      AND     Template_Filters_ID = #arguments.stForm.TemplateFiltersID#
      AND     Product_Group_Level_ID = #arguments.stForm.GroupLevelID#
    </cfquery>
</cfif>
  	<cfset qGetExistingData = this.fnQryExistingProductData( TemplateID = arguments.stForm.TemplateID,
                                                             TemplateFiltersID = arguments.stForm.TemplateFiltersID,
                                                             ProductGroupLevelID = arguments.stForm.GroupLevelID,
                                                             bActive = 0 ) />
	 <!--- <cfdump Var="#arguments#" output="c:\dump.log" >
	 <cfdump Var="#qGetExistingData#" output="c:\dump.log" > --->

    <cfloop index = "ID" list = "#arguments.stForm.FinalItemList#" >
      <cfset bRecExists = "0" />
	  <cfif ID NEQ 'undefined' >
	      <!--- Loop through qGetExistingData only, if there is already Data for the Combination --->
	      <cfif qGetExistingData.RecordCount GTE 1>
	        <cfloop query="qGetExistingData">
	          <cfif (ID EQ qGetExistingData.Product_Group_ID)>
	            <!--- record exist so update to active  = 1--->
	            <cfset bRecExists = "1" />
	            <cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
	              UPDATE Product_Group_Template_Selection
	              SET Active = 1,
	                  Deleted = 0,
	                  Updated_By = '#arguments.UserID#',
	                  Updated_Date = GetDate(),
	                  Updated_From = 'Template Page'
	              WHERE   Template_ID = #arguments.stForm.TemplateID#
	              AND     Template_Filters_ID = #arguments.stForm.TemplateFiltersID#
	              AND     Product_Group_Level_ID = #arguments.stForm.GroupLevelID#
	              AND Product_Group_ID = '#ID#'
	            </cfquery>
	          </cfif>
	        </cfloop>
	      </cfif>
	      <cfif bRecExists EQ "0">

		        <cfset useLakebaseForqryChkISPG = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("product_group_level")>
<cfif useLakebaseForqryChkISPG>
	<cftry>
		<cfset qryChkISPG = application.oLakebase.toQuery(
			application.oLakebase.selectRows("product_group_level", {
				"product_group_level_id" = "eq.#arguments.stForm.GroupLevelID#",
				"limit" = "1",
				"select" = "is_pg"
			}), "is_pg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryChkISPG = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryChkISPG>
<cfquery name="qryChkISPG" datasource="#application.datasource#">
		          SELECT TOP 1 IS_PG  FROM
		          Product_Group_Level
		          WHERE Product_Group_Level_ID = #arguments.stForm.GroupLevelID#
		        </cfquery>
</cfif>
		        <cfquery name="qUpdateAllRecs" datasource="#application.datasource#">
		          INSERT INTO Product_Group_Template_Selection
		          (
		              Template_ID,
		              Product_Group_Level_ID,
		              Product_Group_ID,
		              Active,
		              Deleted,
		              Created_Date,
		              Created_By,
		              PG_Flag,
		              Updated_From,
		              Template_Filters_Id
		          )
		          VALUES
		          (
		              #arguments.stForm.TemplateID#,
		              #arguments.stForm.GroupLevelID#,
		              '#ID#',
		              1,
		              0,
		              GetDate(),
		              '#arguments.UserID#',
		              <cfif ((qryChkISPG.RecordCount EQ 1) AND (qryChkISPG.IS_PG EQ 1))>1<cfelse>0</cfif>,
		              'Template Page',
		               #arguments.stForm.TemplateFiltersID#
		          )
		      </cfquery>
		  </cfif>
	    </cfif>
	  </cfloop>
    <cfset returnValue = "1" />
	<!---   <cfcatch>
	    <cfreturn returnValue />
	  </cfcatch>
	 </cftry> --->

     <cfreturn returnValue />
  </cffunction>



</cfcomponent>
