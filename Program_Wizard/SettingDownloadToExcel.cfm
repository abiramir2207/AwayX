<cfparam name="url.ID" default="0">
<cfparam name="url.DownloadSettings" default="1">
<cfparam name="Generic_Type" default="DTS">
<cfparam name="Created_Type" default="">
<cfparam name="action" default="">

<cfquery name="SelectBasic" datasource="#application.datasource#">
	SELECT	*
	FROM 	Program_Control_Panel_Options
	WHERE 	ProgramControl_Panel_Options_ID = <cfqueryparam value="#url.ID#" cfsqltype="cf_sql_integer">
</cfquery>

<CFQUERY NAME="qGetBillbackStatus" DATASOURCE="#Application.Datasource#">
	SELECT	Billback_Status_ID,BB_Status_Description
	FROM	Billback_Status
	WHERE 	Billback_Status_ID NOT IN (1,6,7,8)
	ORDER BY Status_Order_Number
</CFQUERY>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
<cfset template = templateManager.get(url.id)>
<cfset clauseTemplateManager = CreateObject("component", "components.clause_library.ClauseTemplateManager").init() />
<cfset getTemplateClause = clauseTemplateManager.getTemplateClause(url.id)>
<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
<cfset templateRevisionSettings = templateManager.getTemplateRevisionSettings(url.id) />
<cfset businessSegmentManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<cfquery name="dropTables" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##Tmp_Profiles') IS NOT NULL
		DROP TABLE ##Tmp_Profiles

		IF OBJECT_ID('tempdb..##Tmp_Rebate_Price') IS NOT NULL
		DROP TABLE ##Tmp_Rebate_Price

		IF OBJECT_ID('tempdb..##Tmp_Lumpsum_Price') IS NOT NULL
		DROP TABLE ##Tmp_Lumpsum_Price

		IF OBJECT_ID('tempdb..##Tmp_Growth_Price') IS NOT NULL
		DROP TABLE ##Tmp_Growth_Price

		IF OBJECT_ID('tempdb..##TSD_To_Excel') IS NOT NULL
		DROP TABLE ##TSD_To_Excel
</cfquery>

<cfquery name="TemplateSetting" datasource="#application.datasource#">
<!--- TSD_To_Excel :: TEMPLATE SETTING DOWNLOAD TO EXCEL --->
		IF OBJECT_ID('tempdb..##TSD_To_Excel') IS NOT NULL
		DROP TABLE ##TSD_To_Excel

		CREATE TABLE ##TSD_To_Excel(
			  Setting_Order INT IDENTITY(1,1)
			, Setting_Name VARCHAR(250)
			, Setting_Field_Name VARCHAR(250)
			,	Setting_Value VARCHAR(250)
			,	Parent_ID VARCHAR(10) NULL
			, Set_As_Default VARCHAR(5)
			, In_Volume VARCHAR(5)
			, Show_Hide VARCHAR(5)
			, Business_Segment BIT DEFAULT (0)
			, Page INT
		)

		IF OBJECT_ID('tempdb..##TFSD_To_Excel') IS NOT NULL
		DROP TABLE ##TFSD_To_Excel

		CREATE TABLE ##TFSD_To_Excel(
			  Setting_Order INT IDENTITY(1,1)
			, Attribute_Name VARCHAR(250)
			, Field_In_Search VARCHAR(5)
			, In_Group_Search VARCHAR(5)
			, Allow_Filters VARCHAR(5)
			, Prg_Vol_By_Attribute VARCHAR(5)
			, Filter_Type VARCHAR(100)
		)

</cfquery>

	<cfset SettingsManagerTemplate = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getTemplateSettings(Generic_Type,url.ID)>
	<cfset templateMgmtSettingsSecPage = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getTemplateMgmtSettingsSecPage(Generic_Type,url.ID)>

<cffunction name="SettingsToExcel" output="false">
		<cfargument name="Setting_Name" required="true">
		<cfargument name="Setting_Field_Name" required="true">
		<cfargument name="Setting_Value" required="false" default="">
		<cfargument name="Is_Child_Of" default="" required="false">
		<cfargument name="SetAsDefault" default="No" required="false">
		<cfargument name="InVolume" default="" required="false">
		<cfargument name="ShowHide" default="Hide" required="false">
		<cfargument name="SkipQuery" default="0" required="false">
		<cfargument name="BusinessSegment" default="0" required="false">
		<cfargument name="Page" default="1" required="false">

<cfif len(arguments.Is_Child_Of)>
	<cfquery name="getParentId" datasource="#application.datasource#">
		SELECT Setting_Order
		FROM ##TSD_To_Excel
		WHERE Setting_Field_Name = '#arguments.Is_Child_Of#'
	</cfquery>
	<cfset  Parent_ID = getParentId.Setting_Order>
<cfelse>
	<cfset Parent_ID = 0>
</cfif>


<cfif arguments.SkipQuery>
	<cfset SValue = arguments.Setting_Value>
<cfelse>

<cfif len(arguments.Setting_Value)>
	<cfset SValue = '#arguments.Setting_Value#'>
<cfelse>
	<cfif arguments.page IS '5'>
		<cfset SettingValue = Evaluate("templateRevisionSettings.#arguments.Setting_Field_Name#")>
		<cfif arguments.Setting_Field_Name IS 'Require_Public_Notes_Changed' OR arguments.Setting_Field_Name IS 'Require_Private_Notes_Changed'>
			<cfif len(SettingValue) EQ 0 OR SettingValue EQ '2'>
				<cfset SValue = 'No'>
			<cfelse>
				<cfset SValue = 'Yes'>
			</cfif>
		<cfelse>
			<cfif len(SettingValue) AND SettingValue EQ '2'>
				<cfset SValue = 'No'>
			<cfelse>
				<cfset SValue = 'Yes'>
			</cfif>
		</cfif>
	<cfelse>
		<cfif  isdefined("SettingsManagerTemplate.#arguments.Setting_Field_Name#") >
			<cfset SettingValue = Evaluate("SelectBasic.#arguments.Setting_Field_Name#")>
			<cfif isNumeric(SettingValue)>
				<cfif SettingValue GTE 1>
					<cfset SValue = 'Yes'>
				<cfelse>
					<cfset SValue = 'No'>
				</cfif>
			<cfelse>
				<cfset SValue = Evaluate("SelectBasic.#arguments.Setting_Field_Name#")>
			</cfif>
		<cfelse>
			<cfset SValue = ''>
	 </cfif>

</cfif>

</cfif>

</cfif>

<cfset ShowHide = arguments.ShowHide>
<cfif arguments.page EQ 1>
	<cfif isdefined("SettingsManagerTemplate.#arguments.Setting_Field_Name#") AND Evaluate("SettingsManagerTemplate.#arguments.Setting_Field_Name#")>
		<cfif Evaluate("SettingsManagerTemplate.#arguments.Setting_Field_Name#")>
			<cfset ShowHide = 'Show'>
		</cfif>
	</cfif>
<!--- DETAILS PAGE --->
<cfelseif arguments.page EQ 2>
	<cfif isdefined("templateMgmtSettingsSecPage.#arguments.Setting_Field_Name#") AND Evaluate("templateMgmtSettingsSecPage.#arguments.Setting_Field_Name#")>
		<cfif Evaluate("templateMgmtSettingsSecPage.#arguments.Setting_Field_Name#")>
			<cfset ShowHide = 'Show'>
		</cfif>
	</cfif>
</cfif>

	<cfif len(arguments.Is_Child_Of)>
		<cfset ShowHide = ''>
	</cfif>

	<cfquery name="insertSettings" datasource="#application.datasource#">
	INSERT INTO ##TSD_To_Excel(Setting_Name, Setting_Field_Name, Setting_Value, Parent_ID,  Set_As_Default, In_Volume, Show_Hide, Business_Segment, Page)
	VALUES ('#arguments.Setting_Name#', '#arguments.Setting_Field_Name#', '#SValue#', '#Parent_ID#', '#arguments.SetAsDefault#', '#arguments.InVolume#', '#ShowHide#', #arguments.BusinessSegment#,#arguments.Page#)
	</cfquery>

</cffunction>

<!--- Basic Info --->
<CFINCLUDE TEMPLATE="create_edit.cfm">

<cfquery name="BasicInfo" datasource="#application.datasource#">
	SELECT Setting_Name, Setting_Value, Show_Hide
	FROM ##TSD_To_Excel
	WHERE Page = 1
	AND Business_Segment = 0
	ORDER BY Setting_Order ASC
</cfquery>

<cfset BasicInfoHeaders ='Template Setting,Setting Value,Show Hide'>

<!--- BUSINESS SEGEMENTS --->
<cfif businessSegmentManager.isEnabled() and appSettings.getFilterBusinessSegments()>
	<cfquery name="BusinessSegmentInfo" datasource="#application.datasource#">
		SELECT Setting_Name, Setting_Value
		FROM ##TSD_To_Excel
		WHERE Page = 1
		AND Business_Segment = 1
		ORDER BY Setting_Order ASC
	</cfquery>

	<cfset BusinessSegmentHeaders ='Business Segment,Include'>
</cfif>

<!--- Details --->
<CFINCLUDE TEMPLATE="secondpage.cfm">

<cfquery name="DetilsInfo" datasource="#application.datasource#">
	SELECT Setting_Name, Setting_Value, Show_Hide, Set_AS_Default, In_Volume
	FROM ##TSD_To_Excel
	WHERE Page = 2
	ORDER BY Setting_Order ASC
</cfquery>

<cfset DetailHeaders ='Template Setting,Setting Value,Show Hide,Set As Default,In Volume'>

<!--- PROFILES --->
<cfset actionListShort = "Access, Approval,Lumpsum,Billback,Agree,#appSettings.getPullbackLabelLower()#,Limited Revise">
<cfset variables.Options = listlen(actionListShort) />

<cfset forbidTypes = "Profile,Access,Approval,Lumpsum,Billback,Agree,#appSettings.getPullbackLabelLower()#,Limited Revise">

<cfquery name="getCurProfiles" datasource="#application.datasource#">
	SELECT 	DISTINCT Profiles.Profiles_ID, Profiles_Desc, Profiles_Short_Desc,ISNULL(Profiles_Settings.Approve_Pullback, 0) As Approve_Pullback, 2 as s_order
	FROM 	Profiles
	LEFT JOIN Profiles_Settings
	ON		Profiles_Settings.Deleted = 0
	AND		Profiles_Settings.Profiles_ID = Profiles.Profiles_ID
	WHERE 	Profiles.Deleted = 0

	UNION

	SELECT	TOP 1 0, 'Any New Profiles', 'ANP',
	1 As Approve_Pullback, 1 as s_order
	FROM	Profiles
	WHERE	Deleted = 0
	ORDER BY s_order, Profiles_Desc
</cfquery>

<cfset profiles = valueList(getCurProfiles.profiles_desc)>

<cfquery name="getCurChecks" datasource="#application.datasource#">
	SELECT	*
	FROM	Profile_Forbidden_Template
	WHERE	template_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.id#">
</cfquery>

	<cfset profileColumns = ''>

	<cfloop list="#forbidTypes#" index="profile">
		<cfset profileColumns = listAppend(profileColumns, '['&trim(profile)&']'&' varchar(100)')>
	</cfloop>

	<cfquery name="ProfilesTable" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##Tmp_Profiles') IS NOT NULL
		DROP TABLE ##Tmp_Profiles

		CREATE TABLE ##Tmp_Profiles	(
		#profileColumns#
		)
	</cfquery>


	<cfoutput query="getCurProfiles">

		<cfquery name="ProfileRecord" datasource="#application.datasource#">
			INSERT INTO ##Tmp_Profiles (Profile)
			values ('#getCurProfiles.profiles_desc#')
		</cfquery>

		<cfloop index="i" from="1" to="#variables.Options#">

			<cfquery name="ShouldBeChecked" dbtype="query">
				SELECT 	*
				FROM getCurChecks
				WHERE Profile_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getCurProfiles.Profiles_ID#">
				AND forbid_access_type = <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">
			</cfquery>

			<CFIF ShouldBeChecked.Recordcount>
				<cfset Profileval ='ON'>
			<cfelse>
				<cfset Profileval = 'OFF'>
			</CFIF>

		<cfquery name="ProfileRecordUpdate" datasource="#application.datasource#">
			UPDATE ##Tmp_Profiles
			SET [#trim(listgetat(actionListShort, i))#] = '#Profileval#'
			WHERE Profile = '#getCurProfiles.profiles_desc#'
		</cfquery>

		</cfloop>
	</cfoutput>

<cfquery name="ProfileRecord" datasource="#application.datasource#">
	SELECT * FROM ##Tmp_Profiles
</cfquery>

<!--- COMPONENTS --->

<!--- GET COMPONENTS --->
<cfset qGetAllDiscountTypes = templateManager.getAllComponentDiscountTypes(url.id)>

<!--- GET PAYMENT TYPES --->
<cfset useLakebaseForGetPaymentPaidToTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("payment_paid_to_types")>
<cfif useLakebaseForGetPaymentPaidToTypes>
	<cftry>
		<cfset GetPaymentPaidToTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("payment_paid_to_types", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPaymentPaidToTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPaymentPaidToTypes>
<cfquery name="GetPaymentPaidToTypes" datasource="#application.datasource#">
	SELECT distinct *
	FROM Payment_Paid_To_Types
	WHERE Deleted = 0
</cfquery>
</cfif>

<cfset fixedprice_freight = template.getFixedFreight()>
<cfset qGetAllDiscountTypes = templateManager.getAllComponentDiscountTypes(url.id)>
<cfset discountTypeList = ValueList(qGetAllDiscountTypes.DISCOUNT_TYPE_ID) />
<cfset qGetAllTemplateDiscountComponents = templateManager.getAllTemplateDiscountComponents(templateId=url.id, discountTypeList=discountTypeList,returnSelected=0,fixedprice_freight=fixedprice_freight) />

<cfloop query="qGetAllDiscountTypes">

		<cfset compColumns= ''>

		<cfset compColumnName = trim(replace(Discount_Type_Desc&'_Components',' ','_'))>
		<cfset compColumns = listAppend(compColumns, compColumnName&' varchar(100)')>
		<cfset compColumns = listAppend(compColumns, 'Include varchar(100)')>

		<cfset tableName = 'Tmp_'&#replace(Discount_Type_Desc,' ','_')#>

		<cfloop query="GetPaymentPaidToTypes">
			<cfif Payment_Paid_To_Type_Name EQ 'Both'>
					<cfset PaymentPaid2TypeName = 'Distributor_And_Operator'>
			<cfelse>
				<cfset PaymentPaid2TypeName = Payment_Paid_To_Type_Name>
			</cfif>
			<cfset compColumns = listAppend(compColumns, trim(replace(PaymentPaid2TypeName,' ','_'))&' varchar(100)')>
		</cfloop>

		<cfset "#replace(Discount_Type_Desc,' ','_')#" = compColumns>

		<cfquery name="#replace(Discount_Type_Desc,' ','_')#" datasource="#application.datasource#">
			IF OBJECT_ID('tempdb..###tableName#') IS NOT NULL
			DROP TABLE ###tableName#

			CREATE TABLE ###tableName#	(
				#compColumns#
			)
		</cfquery>

		<cfset useLakebaseForqGetTemplateComponents = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetalltemplatediscountcomponents")>
<cfif useLakebaseForqGetTemplateComponents>
	<cftry>
		<cfset qGetTemplateComponents = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetalltemplatediscountcomponents", {
				"discount_type_id" = "eq.#DISCOUNT_TYPE_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetTemplateComponents = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetTemplateComponents>
<cfquery name="qGetTemplateComponents" dbtype="query">
			SELECT	*
			FROM	qGetAllTemplateDiscountComponents
			WHERE	DISCOUNT_TYPE_ID = #DISCOUNT_TYPE_ID#
		</cfquery>
</cfif>

	<cfloop query="qGetTemplateComponents">
	<cfif Component_Selected>
		<cfset ComponentSelected = 'Yes'>
	<cfelse>
		<cfset ComponentSelected = 'No'>
	</cfif>
			<cfquery name="InsertComp" datasource="#application.datasource#">
				INSERT INTO ###tableName#(#compColumnName#, include)
				VALUES ('#Component_Name#', '#ComponentSelected#')
			</cfquery>

			<cfset qGetAllTemplateDiscountComponentPaidTo = templateManager.getAllTemplateDiscountComponentPaidTo(qGetTemplateComponents.Program_Template_component_ID)>
			<cfset ListGetAllTemplateDiscountComponentPaidTo = ValueList(qGetAllTemplateDiscountComponentPaidTo.Payment_Paid_To_ID)>

			<cfloop query="GetPaymentPaidToTypes">
				<cfif Payment_Paid_To_Type_Name EQ 'Both'>
				<cfset PaymentPaid2TypeName = 'Distributor_And_Operator'>
				<cfelse>
				<cfset PaymentPaid2TypeName = Payment_Paid_To_Type_Name>
				</cfif>

				<cfif ListFindNoCase(ListGetAllTemplateDiscountComponentPaidTo,Payment_Paid_To_ID)>
				<cfset PaidTo = 'Yes'>
				<cfelse>
				<cfset PaidTo = 'No'>
				</cfif>

				<cfquery name="UpdateComp" datasource="#application.datasource#">
				UPDATE ###tableName#
				SET #PaymentPaid2TypeName# = '#PaidTo#'
				WHERE #compColumnName# = '#qGetTemplateComponents.Component_Name#'
				</cfquery>
			</cfloop>
	</cfloop>

   	<cfset QName = #replace(Discount_Type_Desc,' ','_')#&'_Table'>

		<cfquery name="#QName#" datasource="#application.datasource#">
			SELECT * FROM ###tableName#
		</cfquery>

</cfloop>

<!--- DUPLICATES --->
<cfset PageName = "Duplicate Program">
<CFINCLUDE TEMPLATE="Dup_Program_Def.cfm">

<cfquery name="DuplicateSettings" datasource="#application.datasource#">
	SELECT Setting_Name, Setting_Value, Set_AS_Default
	FROM ##TSD_To_Excel
	WHERE Page = 3
	ORDER BY Setting_Order ASC
</cfquery>

<cfset DuplicateHeaders ='Duplicate Setting,Setting Value,Selected'>

<!--- CLAUSE LIBRARY --->
<cfset useLakebaseForqGetDistinctClause = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gettemplateclause")>
<cfif useLakebaseForqGetDistinctClause>
	<cftry>
		<cfset qGetDistinctClause = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gettemplateclause", {
				"order" = "clause_category_name.asc",
				"select" = "clause_category_name"
			}), "clause_category_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistinctClause = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistinctClause>
<cfquery name="qGetDistinctClause" dbtype="query">
	SELECT 	DISTINCT Clause_Category_Name
	FROM	getTemplateClause
	ORDER BY Clause_Category_Name
</cfquery>
</cfif>

<!--- REVISION --->

<CFINCLUDE TEMPLATE="revision_settings.cfm">

<cfquery name="RevisionSettings" datasource="#application.datasource#">
	SELECT  Setting_Name, Setting_Value
	FROM ##TSD_To_Excel
	WHERE Page = 5
	ORDER BY Setting_Order ASC
</cfquery>

<cfset RevisionSettingsHeaders ='Revision Setting,Revision Setting Value'>

<!--- LETTERS --->

<CFINCLUDE TEMPLATE="Letters_Template_Add_Remove.cfm">

<cfquery name="LetterSettings" datasource="#application.datasource#">
	SELECT  Setting_Name, Setting_Value, CASE WHEN Set_AS_Default = '0' THEN ' ' ELSE Set_AS_Default END AS Set_AS_Default
	FROM ##TSD_To_Excel
	WHERE Page = 4
	ORDER BY Setting_Order ASC
</cfquery>

<cfset LetterSettingsHeaders ='Letter Setting,Letter Setting Value, Default'>


<cffunction name="FilterSettingsToExcel" output="false">
		<cfargument name="Attribute_Name" required="true">
		<cfargument name="Field_In_Search" required="false" default="0">
		<cfargument name="In_Group_Search" required="false" default="0">
		<cfargument name="Allow_Filters" required="false" default="0">
		<cfargument name="Prg_Vol_By_Attribute" required="false" default="0">
		<cfargument name="Filter_Type" required="false" default="">

		<cfif arguments.Field_In_Search EQ '1'>
			<cfset Field_In_Search = 'Yes'>
		<cfelse>
			<cfset Field_In_Search = 'No'>
		</cfif>

		<cfif arguments.In_Group_Search EQ '1'>
			<cfset In_Group_Search = 'Yes'>
		<cfelse>
			<cfset In_Group_Search = 'No'>
		</cfif>

		<cfif arguments.Allow_Filters EQ '1'>
			<cfset Allow_Filters = 'Yes'>
		<cfelse>
			<cfset Allow_Filters = 'No'>
		</cfif>

		<cfif arguments.Prg_Vol_By_Attribute EQ '1'>
			<cfset Prg_Vol_By_Attribute = 'Yes'>
		<cfelse>
			<cfset Prg_Vol_By_Attribute = 'No'>
		</cfif>

		<cfquery name="TemplateFilterSetting" datasource="#application.datasource#">
			INSERT INTO ##TFSD_To_Excel(Attribute_Name, Field_In_Search, In_Group_Search, Allow_Filters, Prg_Vol_By_Attribute, Filter_Type)
			VALUES ('#arguments.Attribute_Name#','#Field_In_Search#','#In_Group_Search#','#Allow_Filters#','#Prg_Vol_By_Attribute#','#arguments.Filter_Type#')
		</cfquery>
</cffunction>

<!--- CUSTOMER FILTERS --->
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
<cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfset OprGroupDataManager = CreateObject("component", "components.operator.Group.DataManager").init() />

<cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData() />
<cfset Template_ID = SelectBasic.First_Parent_ID />

<cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(Template_ID,2)/>

<cfquery name="qryDistList" datasource="#application.datasource#">
  SELECT DISTINCT(Distributor_Group_Level_ID)
  FROM Distributor_Group_Level
  WHERE Active= 1
  AND Deleted = 0
  AND Distributor_Group_Level_ID NOT IN (23, 24, 25)
</cfquery>

<cfset qGetTopLevelGroupsList = DistGroupDataManager.getDistributorLevelsAll(1, "#ValueList(qryDistList.Distributor_Group_Level_ID)#", "") />

<cfloop Query = "qGetTopLevelGroupsList">
  <cfset bAllowInSearch = 0 />
  <cfset bAllowInGroupSearch = 0 />
  <cfset bAllowFilter = 0 />
  <cfloop query = "qryGetGroupTemplateByTemplateID">
    <cfif qGetTopLevelGroupsList.Distributor_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
      <cfset bAllowInSearch = qryGetGroupTemplateByTemplateID.Allow_In_Search />
      <cfset bAllowInGroupSearch = qryGetGroupTemplateByTemplateID.Allow_In_Group_Search />
       <cfset bAllowFilter = qryGetGroupTemplateByTemplateID.Allow_Filter />
    </cfif>
   </cfloop>

	<cfset Setting_Name = #qGetTopLevelGroupsList.Group_Level_Desc#>
	<cfif (qGetTopLevelGroupsList.IS_PG EQ 1)>
		<cfset Setting_Name = Setting_Name & '(PGP)'>
	</cfif>

	<cfset FilterSettingsToExcel (Attribute_Name='#Setting_Name#', Field_In_Search='#bAllowInSearch#', In_Group_Search='#bAllowInGroupSearch#', Allow_Filters='#bAllowFilter#', Prg_Vol_By_Attribute='0', Filter_Type='Distributors Filters')>
</cfloop>

<cfquery name="DistributorFilters" datasource="#application.datasource#">
	SELECT Attribute_Name, Field_In_Search, In_Group_Search, Allow_Filters
	FROM ##TFSD_To_Excel
	WHERE Filter_Type = 'Distributors Filters'
</cfquery>
<cfset CFiltersHeaders = 'Attribute, Field In Search, In Group Search, Allow Filters'>

<!--- ITEM FILTERS --->
<cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(Template_ID,1)/>
<cfloop Query = "qGetTopLevelGroups">
	<cfset bAllowInSearch = 0 />
	<cfset bAllowInGroupSearch = 0 />
	<cfset bAllowFilter = 0 />
	<cfset bPrgVolByAttribute = 0 />

	<cfloop query = "qryGetGroupTemplateByTemplateID">
		<cfif qGetTopLevelGroups.Product_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
			<cfset bAllowInSearch = qryGetGroupTemplateByTemplateID.Allow_In_Search />
			<cfset bAllowInGroupSearch = qryGetGroupTemplateByTemplateID.Allow_In_Group_Search />
			<cfset bAllowFilter = qryGetGroupTemplateByTemplateID.Allow_Filter />
			<cfset bPrgVolByAttribute = qryGetGroupTemplateByTemplateID.Prg_Vol_By_Attribute />
		</cfif>
	</cfloop>

    <cfset Setting_Name = #qGetTopLevelGroups.Group_Level_Desc#>
    <cfif (qGetTopLevelGroups.IS_PG EQ 1)>
    	<cfset Setting_Name = Setting_Name & '(PGP)'>
    </cfif>

	<cfset FilterSettingsToExcel (Attribute_Name='#Setting_Name#', Field_In_Search='#bAllowInSearch#', In_Group_Search='#bAllowInGroupSearch#', Allow_Filters='#bAllowFilter#', Prg_Vol_By_Attribute='#bPrgVolByAttribute#', Filter_Type='Item Filters')>
</cfloop>

<cfquery name="ProductFilters" datasource="#application.datasource#">
	SELECT Attribute_Name, Field_In_Search, In_Group_Search, Allow_Filters, Prg_Vol_By_Attribute
	FROM ##TFSD_To_Excel
	WHERE Filter_Type = 'Item Filters'
</cfquery>
<cfset PFiltersHeaders = 'Attribute, Field In Search, In Group Search, Allow Filters, Prg Vol By Attributes'>

<!--- OPERATOR FILTERS --->
<cfif Template.Specify_Operators EQ 1>
<cfquery name="qryOprList" datasource="#application.datasource#">
  SELECT DISTINCT(Operator_Group_Level_ID) FROM Operator_Group_Level WHERE Active= 1 AND Deleted = 0
</cfquery>

<cfset qGetTopLevelGroupsList = OprGroupDataManager.getOperatorLevelsAll(1, "#ValueList(qryOprList.Operator_Group_Level_ID)#", "") />
<cfset qryGetGroupTemplateByTemplateID = PGManager.fnGetGroupTemplateByTemplateID(Template_ID,3)/>

<cfloop Query = "qGetTopLevelGroupsList">
    <cfset bAllowInSearch = 0 />
    <cfset bAllowInGroupSearch = 0 />
    <cfset bAllowFilter = 0 />

    <cfloop query = "qryGetGroupTemplateByTemplateID">
      <cfif qGetTopLevelGroupsList.Operator_Group_Level_ID EQ  qryGetGroupTemplateByTemplateID.Group_Level_ID>
        <cfset bAllowInSearch = qryGetGroupTemplateByTemplateID.Allow_In_Search />
        <cfset bAllowInGroupSearch = qryGetGroupTemplateByTemplateID.Allow_In_Group_Search />
         <cfset bAllowFilter = qryGetGroupTemplateByTemplateID.Allow_Filter />
      </cfif>
   </cfloop>

    <cfset Setting_Name = #qGetTopLevelGroupsList.Group_Level_Desc#>
    <cfif (qGetTopLevelGroupsList.IS_PG EQ 1)>
    	<cfset Setting_Name = Setting_Name & '(PGP)'>
    </cfif>

    <cfset FilterSettingsToExcel (Attribute_Name='#Setting_Name#', Field_In_Search='#bAllowInSearch#', In_Group_Search='#bAllowInGroupSearch#', Allow_Filters='#bAllowFilter#', Prg_Vol_By_Attribute='0', Filter_Type='Operator Filters')>
 </cfloop>

<cfquery name="OperatorFilters" datasource="#application.datasource#">
	SELECT Attribute_Name, Field_In_Search, In_Group_Search, Allow_Filters
	FROM ##TFSD_To_Excel
	WHERE Filter_Type = 'Operator Filters'
</cfquery>

</cfif>

<cfset OFiltersHeaders = 'Attribute, Field In Search, In Group Search, Allow Filters'>

<cfset firstSheet = 1>

<cfscript>

    //Use an absolute path for the files.
    FileName = "#REReplace(template.Createdtype,"[^0-9A-Za-z ]","","all")#.xls";
    donwloadfilepath = application.Doc_Path & "\Temp_Files\settings\" & FileName;

 	objSpreadsheet=spreadsheetnew("BasicInfo");

  //	Add your data to Rebate Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"BasicInfo");

			SpreadSheetAddRow(objSpreadsheet,"#BasicInfoHeaders#");
			SpreadSheetAddRows(objSpreadsheet,BasicInfo);

if( businessSegmentManager.isEnabled() && appSettings.getFilterBusinessSegments()){
   //	create Details Info Sheet
 				SpreadSheetCreateSheet(objSpreadsheet, "#appSettings.getbusiness_segment_label()#");

  //	Add your data to Details Info Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"#appSettings.getbusiness_segment_label()#");

			SpreadSheetAddRow(objSpreadsheet,"#BusinessSegmentHeaders#");
			SpreadSheetAddRows(objSpreadsheet,BusinessSegmentInfo);
}

   //	create Details Info Sheet
 				SpreadSheetCreateSheet(objSpreadsheet, "Details");

  //	Add your data to Details Info Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Details");

			SpreadSheetAddRow(objSpreadsheet,"#DetailHeaders#");
			SpreadSheetAddRows(objSpreadsheet,DetilsInfo);

   //	create Profiles Sheet
 				SpreadSheetCreateSheet(objSpreadsheet, "Profiles");

  //	Add your data to Profile Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Profiles");

				SpreadSheetAddRow(objSpreadsheet,"#forbidTypes#");
				SpreadSheetAddRows(objSpreadsheet,ProfileRecord);

for(i = 1; i <= qGetAllDiscountTypes.Recordcount; i++){
		QName='';
		compColumns= '';

		compColumnName = trim(replace(qGetAllDiscountTypes['Discount_Type_Desc'][i]&'_Components',' ','_'));
		compColumns = listAppend(compColumns, compColumnName);
		compColumns = listAppend(compColumns, 'Include');

for(j = 1; j <= GetPaymentPaidToTypes.Recordcount; j++){
			if(GetPaymentPaidToTypes['Payment_Paid_To_Type_Name'][j] == 'Both'){
					PaymentPaid2TypeName = 'Distributor_And_Operator';
					compColumns = listAppend(compColumns, PaymentPaid2TypeName);
				}
			else{
				PaymentPaid2TypeName = GetPaymentPaidToTypes['Payment_Paid_To_Type_Name'][j];
				compColumns = listAppend(compColumns, trim(replace(PaymentPaid2TypeName,' ','_')));
			}

}
QName = #replace(qGetAllDiscountTypes['Discount_Type_Desc'][i],' ','_')#&'_Table';
SheetName = #replace(qGetAllDiscountTypes['Discount_Type_Desc'][i],' ','_')#;

  // create Distributors Sheet
 			SpreadSheetCreateSheet(objSpreadsheet, "#SheetName#");

  // Add your data to Distributors Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"#SheetName#");

			SpreadSheetAddRow(objSpreadsheet,"#compColumns#");
			SpreadSheetAddRows(objSpreadsheet,#Evaluate(QName)#);

}

   //	create Duplicate Setting Sheet
 				SpreadSheetCreateSheet(objSpreadsheet, "Duplicate Settings");

  //	Add your data to  Duplicate Setting Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Duplicate Settings");

			SpreadSheetAddRow(objSpreadsheet,"#DuplicateHeaders#");
			SpreadSheetAddRows(objSpreadsheet,DuplicateSettings);

  // create Clause Library Sheet
 			SpreadSheetCreateSheet(objSpreadsheet, "Clause");

  //	Add your data to Clause Library Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Clause");

			SpreadSheetAddRow(objSpreadsheet,"Clause");
			SpreadSheetAddRows(objSpreadsheet,qGetDistinctClause);

  // create Letter Setting Sheet
 			SpreadSheetCreateSheet(objSpreadsheet, "Letters");

  //	Add your data to Letter Setting Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Letters");

			SpreadSheetAddRow(objSpreadsheet,"#LetterSettingsHeaders#");
			SpreadSheetAddRows(objSpreadsheet,LetterSettings);

   //	create Duplicate Setting Sheet
 				SpreadSheetCreateSheet(objSpreadsheet, "Revision Settings");

  //	Add your data to Duplicate Setting Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Revision Settings");

			SpreadSheetAddRow(objSpreadsheet,"#RevisionSettingsHeaders#");
			SpreadSheetAddRows(objSpreadsheet,RevisionSettings);

   //	create Distributor Filter Sheet
 				SpreadSheetCreateSheet(objSpreadsheet, "Distributor Filters");

  //	Add your data to Distributor Filter Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Distributor Filters");

			SpreadSheetAddRow(objSpreadsheet,"#CFiltersHeaders#");
			SpreadSheetAddRows(objSpreadsheet,DistributorFilters);

   //	create Product Filters Sheet
 				SpreadSheetCreateSheet(objSpreadsheet, "Product Filters");

  //	Add your data to Product Filters Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Product Filters");

			SpreadSheetAddRow(objSpreadsheet,"#PFiltersHeaders#");
			SpreadSheetAddRows(objSpreadsheet,ProductFilters);

if(Template.Specify_Operators EQ 1){
	   //	create Product Filters Sheet
 				SpreadSheetCreateSheet(objSpreadsheet, "Operator Filters");

  //	Add your data to Product Filters Sheet
 			SpreadSheetSetActiveSheet(objSpreadsheet,"Operator Filters");

			SpreadSheetAddRow(objSpreadsheet,"#OFiltersHeaders#");
			SpreadSheetAddRows(objSpreadsheet,OperatorFilters);
}

			SpreadsheetSetActiveSheet(objSpreadsheet, 'BasicInfo');
</cfscript>

	<cfspreadsheet action="write" filename="#donwloadfilepath#" name="objSpreadsheet" sheetname="BasicInfo" overwrite=true>

	<cfheader name="Content-Disposition" value="attachment; filename=#FileName#" >
	<cfcontent type="application/vnd.ms-excel" file="#donwloadfilepath#">
