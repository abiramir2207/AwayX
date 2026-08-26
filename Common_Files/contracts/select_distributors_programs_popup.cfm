<!DOCTYPE HTML>
<html>
<head>
	<style>
		table.filters br {
			line-height: 16px;
		}
	</style>
</head>
<body>
<!---
FILENAME:	select_distributors_programs_popup.cfm
CREATED:	12/16/2016 - Milan Mushran
FUNCTIONALITY:
Used to select distributors on a program.
Below code used to be a part of "select_distributors.cfm". Part of that code (functionality to select distributors),
is a part of this file now. Additional code has been added so that this file can work as a popup.
--->
<cfset DistGroupManager = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
<cfset DistGroupDataManager = CreateObject("component", "components.customer.Group.DataManager").init() />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset DistSearchSettingsManager = CreateObject("component", "components.settings.Labels.Labels") />
<cfset DistSearchResultsColumnsDisplaySettings = DistSearchSettingsManager.getDistributorSearchFieldsDisplayStatus() />
<cfset DistSearchResultsColumnsDisplayAdditionalSettings = DistSearchSettingsManager.getDistributorStaticSearchFieldsDisplayStatus() />
<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->
<cfinclude template="/get_access_profile.cfm">

<cfparam name="form.passed_form" default="">
<cfparam name="form.itemList" default="">
<cfparam name="form.Dist_Name" default="">
<cfparam name="form.searchstring" default="">
<cfparam name="form.DOSEARCH" default="0">
<cfparam name="form.FinalItemList" default="">
<cfparam name="startrow" default="1">
<cfparam name="form.Contract_Main_ID" default="">
<cfparam name="form.excludeDistributor" default="">
<cfparam name="TheQuery.Recordcount" default="0">
<cfparam name="Revision_Settings_Allowed" default="0">
<cfparam name="form.Zone_ID" default="0">
<cfparam name="form.Region_ID" default="0">
<cfparam name="form.Broker" default="0">
<cfparam name="form.Customer_Type" default="">
<cfparam name="form.Country_Code" default="0">
<cfparam name="form.State" default="0">
<cfparam name="form.Distributor_Status" default="A">
<cfparam name="form.SelectSingleSearchResultOnly"  default="0">
<cfparam name="TemplateFiltersId" default="0">
<cfparam name="ShowDropDown"  default="1">
<cfparam name="ShowBrokerInResult"  default="0">
<cfparam name="frompage" default="1">
<cfparam name="form.Business_Segment_ID" default="0">
<cfparam name="form.businessSegmentsOn" default="0">

<cfparam name="URL.plannerID" default="0">
<cfparam name="URL.bEdit" default="0">
<cfparam name="form.plannerID" default="#URL.plannerID#" />

<cfif IsDefined("URL.Is_Group")>
	<cfparam name="form.Is_Group" default="#URL.Is_Group#" />
</cfif>
<cfparam name="form.grpSubmitted" default="0" />
<cfparam name="indDistSubmitted" default="0" />
<cfif (Find(",", form.plannerID)  GTE 1)>
	<cfset form.plannerID = URL.plannerID />
</cfif>

<!---
	65364: Customer Group Search / Anand Rao / 24-Jan-2017
	Comment the below "if" statement to display the old Customer group search
--->
<cfset vars.isearchVersion = "new" /> <!--- Change this variable to "old" to see the old search // for DEV use --->
<cfif vars.isearchVersion EQ "new" AND form.Is_Group EQ 1>
	<cfinclude template = "Groups/select_distributor_groups.cfm" />
	<cfabort>
</cfif>

<cf_Number_of_Rows maxrows=25>

<cfset Header_Display_List = "">
<cfset Header_Value_List = "">

<!--- reformat the itemList --->
<cfif form.passed_form NEQ "" and form.itemList NEQ "">
	<cfset form.itemList = trim(replace(ListQualify(form.itemList, "'", ",", "ALL"), "''", "'", "ALL")) >
</cfif>

<CFIF len(trim(URL.CID)) GT 0>
	<CF_Cryp type="de" key="#request.key#" string="#URL.CID#">

	<cfset useLakebaseForGetContractInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetContractInfo>
	<cftry>
		<cfset GetContractInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#cryp.value#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetContractInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetContractInfo>
<cfquery name="GetContractInfo" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Main
		WHERE Contract_Main_ID = '#cryp.value#'
	</cfquery>
</cfif>
	<!---D42322 ::  Programs cannot be submitted for approval
		Added : "Custom_Fixed_Price_Options" to below Query--->
	 <cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#GetContractInfo.ProgramType_ID#",
				"select" = "first_parent_id,base_sales_equal_to_lowest_bracket,custom_fixed_price_options,filter_distributor_results_based_on_program_position,one_distributor"
			}), "first_parent_id,base_sales_equal_to_lowest_bracket,custom_fixed_price_options,filter_distributor_results_based_on_program_position,one_distributor"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID, Base_Sales_Equal_To_Lowest_Bracket, Custom_Fixed_Price_Options,Filter_Distributor_Results_Based_On_Program_Position, One_Distributor
		FROM Program_Control_Panel_Options
		WHERE ProgramControl_Panel_Options_ID = #GetContractInfo.ProgramType_ID#
	 </cfquery>
</cfif>

	<cfset TemplateFiltersId = GetContractInfo.Template_Filters_Id />
	<cfset form.Line_Of_Business_ID = GetContractInfo.Line_Of_Business_ID>
</CFIF>

	<cfset objProgram = CreateObject("component", "components.programs.program") />
	<cfset distributorManager = CreateObject("component", "components.customer.DistributorManager").init()>

	<cfset qryProgram = objProgram.getProgramInfo(cryp.value) />
	<cfset qPrgDistExceptions = distributorManager.getProgramDistributorExceptions(cryp.value)>

	<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />
	<cfset RevisionStatus = RevisionSettingsManager.getRevisionStatus(cryp.value)>

	<!--- if program is a revision --->
	<cfif RevisionStatus.Is_A_Revision eq 1>

		<!--- get revision settings --->
		<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = qryProgram.programtype_id,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = cryp.value)>
		<cfset Revision_Settings_Allowed = 0 />
		<cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND RevisionStatus.Contract_Reference_Number neq "")>
			<cfset Revision_Settings_Allowed = 1 />
		</cfif>
	</cfif>

<cfset checkSearchSequence = 0 />
<cfif appSettings.getSearchSequenceOn() AND len(trim(CSLGETCONTRACTINFO.Search_Sequence_ID)) GT 0>
	<cfset  SearchSequenceManager 	= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
	<cfset 	Program_Search_Sequence 	= SearchSequenceManager.getSearchSequenceInfo(CSLGETCONTRACTINFO.Search_Sequence_ID) />
	<cfset checkSearchSequence = 1 />
</cfif>

<cfset qGetDistGroupData = DistGroupManager.getDistGroupInfo(cryp.value) />

<cfset CSL_Contract_Main_ID = cryp.value>
<CFINCLUDE TEMPLATE="commonqueries.cfm" />

<cfset FORM.Contract_Main_ID = cryp.value>
<cfset IsFreightProgram = GenProgramManager.GetIsProgramFreightOn(FORM.Contract_Main_ID)>

<!------ all restrictions are based on responsible user ----->
<cfif appSettings.getApplyRSPFilters() EQ 1>
	<cfset userManager = CreateObject("component", "components.user.UserManager") />
	<cfset qUser = userManager.getUser(GetContractInfo.Responsible_User_Id) />
	<cfset rspProfileID = qUser.profiles_id>
	<cfset Get_CustType_Profile_Settings = Profile.getCusttypeProfileSettings(rspProfileID, 'D')>
</cfif>

 <cfif GetSettings.One_Distributor IS 1>
	<cfset form.SelectSingleSearchResultOnly = 1>
<cfelse>
	<cfset form.SelectSingleSearchResultOnly = 0>
</cfif>

<cfset groupCombinationOn = 0 />
<cfset groupCombinationDefinitionHeaderID = 0 />
<cfif form.Is_Group eq 1 AND checkSearchSequence EQ 1 AND isDefined("Program_Search_Sequence.Customer_Group_Combination_Definition_Header_ID") AND isNumeric(Program_Search_Sequence.Customer_Group_Combination_Definition_Header_ID)>
	<cfset groupCombinationOn = 1 />
	<cfset groupCombinationDefinitionHeaderID = Program_Search_Sequence.Customer_Group_Combination_Definition_Header_ID />
</cfif>

<!---check to see if the business segment components exist before we run this--->
<!---check whether the directory exists or not--->
<cfset theDir = "#request.app_general_functions.get_Application_Path()#\components\programs\business_segment\" />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(CSL_Contract_Main_ID) />
<cfif businessSegManager.isEnabledForDistributor()>
	<cfset form.businessSegmentsOn = 1 />
	<cfset form.Business_Segment_Id = trim(busSegIdForProgram) />
	<cfset form.businessSegmentsOn = 1 />
	<!---get the description to display--->
	<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
	<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />

</cfif>

<cfset Group_Business_segment_id = 0>
<cfset Lookup_BS_General_Dropdowns = 0>

<cfif form.businessSegmentsOn eq 1 and isDefined("FORM.BUSINESS_SEGMENT_ID")><!------ signature meat shares customers with ref ----->
	<cfset CustomerBSFilter = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").get(FORM.Business_Segment_Id) />
	<cfset ShowBrokerInResult = CustomerBSFilter.Customer_Show_Broker>
	<cfset ShowDropDown = CustomerBSFilter.Customer_Show_Broker>
	<cfset Group_Business_segment_id = CustomerBSFilter.Customer_Group_BS_Filter>
</cfif>

<cfif appSettings.getDistributorMultiPosition()>
	<cfset ShowBrokerInResult = 0>
</cfif>

<cfif appSettings.getPositionFieldsFilterOnProgramSegment() and businessSegManager.isEnabled()>
     <cfset Lookup_BS_General_Dropdowns = 1>
</cfif>

<!--- <cfset qGetDistributorLevels = DistGroupDataManager.getDistributorLevels() /> --->
<cfset qGetDistributorLevelsGroupTemplate = DistGroupDataManager.getDistributorLevelsGroupTemplate(templateID=GetTemplateInfo.First_Parent_ID) />

<cfquery name="GetLinesOfBiz" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
	SELECT *
	FROM Line_Of_Business
	WHERE Deleted = 0
	<cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") AND Lookup_BS_General_Dropdowns EQ 1>
		and Business_segment_id = #FORM.BUSINESS_SEGMENT_ID#
	</cfif>
	ORDER BY Line_Of_Business_Name
</cfquery>
<!--- Get Foodservice Line Of Business ID --->
<!---
D39427  :: CMI STAGE - error within program on distributor page
<cfquery name="GetFirstDefaultBiz" dbtype="query">
	SELECT 	Line_Of_Business_ID
	FROM 	GetLinesOfBiz
	WHERE 	Line_Of_Business = '#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#'
</cfquery>--->

<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  START
Added/Changed: Added value to busSegIdForProgram to filter Position Drop Down Fields
<cfif appSettings.getPositionFieldsFilterOnProgramSegment() and businessSegManager.isEnabled()>
     <cfset Lookup_BS_General_Dropdowns = 1>
</cfif>--->
<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->
 
<FORM ACTION="select_distributors_programs_popup.cfm?CID=<CFOUTPUT>#URL.CID#&plannerID=#form.plannerID#&bEdit=#URL.bEdit#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE">
 
<cfset maxColsPerRow = 4/>
<cfset currentColCount = 0/>

	<cfif form.Is_Group EQ 1 OR appSettings.getFlexDistributorSearch() eq 0>
		<Div id="dvSearchFields" style="display:block;">
	<cfelse>
		<Div id="dvSearchFields" style="display:none;">
	</CFIF>
	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;display:table">
	    <cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#application.returned_customer_setting.distributor_label_plural# search <cfif form.Is_Group EQ 1>by Groups</cfif></LEGEND></cfoutput>

			<cfif not isDefined("GetTemplateInfo.First_Parent_ID")>
				<cfset FirstParentID = 0 />
				<!---29684: get all distributor search fields from labels - settings--->
		    <cfset vars.qSearchField = DistSearchSettingsManager.getDistributorSearchFields()>
			<cfelse>
				<cfset FirstParentID = GetTemplateInfo.First_Parent_ID />
				<!---30072,31409 Gather distributor search fields defined in program template and enabled in settings labels--->
				<cfset vars.AllTemplateFields = DistGroupDataManager.getDistributorLevelsGroupTemplate( bActive=1, templateID=FirstParentID, disAllowList="23,24,25" )>
				<!---filter out distributor groups v.s. distributors--->
				<cfquery name="vars.TemplateSearchFields" dbtype="query">
					SELECT Field_Name
					       ,Distributor_Group_Level_Id
					       ,List_Order
					       ,Is_PG
					  FROM vars.AllTemplateFields
					 WHERE <cfif form.Is_Group>
					 			 	Allow_In_Group_Search = 1
					 			 <cfelse>
					 			 	Allow_In_Search = 1
					 			 </cfif>
				</cfquery>
				<cfif form.Is_Group>
					<cfset vars.allowInSearch = 0>
					<cfset vars.allowInGroupSearch = 1>
					<!---do not include additional fields from settings labels for groups search --->
					<cfset vars.qSearchField = vars.TemplateSearchFields>
				<cfelse>
					<cfset vars.allowInSearch = 1>
					<cfset vars.allowInGroupSearch = 0>
					<!---31309 - include market, region, zone & static fields--->
					<cfset vars.qDistributorAttributeLabels = DistSearchSettingsManager.getDistributorSearchFields( includeGroups = 'Market,Region,Zone,Broker' )>
					<!---combine template fields and distributor attribute labels fields--->
					<cfquery name="vars.qSearchField" dbtype="query">

						SELECT Field_Name
					       ,Distributor_Group_Level_Id
					       ,List_Order
					       ,CAST(Is_PG as INTEGER) as Is_PG
						  FROM vars.TemplateSearchFields
						 UNION

						SELECT Field_Name
						       ,Distributor_Group_Level_Id
						       ,List_Order
						       ,Is_PG
						  FROM vars.qDistributorAttributeLabels
						ORDER BY List_Order
					</cfquery>
				</cfif>
			</cfif>

			<cfset qGetTopLevelGroups = DistGroupDataManager.getDistributorLevels(
											bActive = 1,
											allowList = "",
											disAllowList = "",
											Template_ID = "#FirstParentID#",
											allowInSearch = vars.allowInSearch,
											allowInGroupSearch = vars.allowInGroupSearch
											) />

			<cfset qGetAllGroupLevels = DistGroupDataManager.getDistributorLevels(
											bActive = 1,
											allowList = "",
											disAllowList = "",
											Template_ID = "#FirstParentID#"
											) />

			<CFSET showHideColumnsSetting()>

			<CFIF ShowBrokerInResult EQ 1 AND DistResults_DisplayBroker EQ 1>
				<CFSET sort_By_List1="Name,#application.returned_customer_setting.shard_ship_to_label#,Address,City,State,Postal Code,Country Code,Broker,Family,Buying Group">
				<CFSET sort_By_List_Value="Name,Ship To,Address,City,State,Postal Code,Country Code,Broker,Family,Buying Group">
			<CFELSE>
				<CFSET sort_By_List1="Name,#application.returned_customer_setting.shard_ship_to_label#,Address,City,State,Postal Code,Country Code,Family,Buying Group">
				<CFSET sort_By_List_Value="Name,Ship To,Address,City,State,Postal Code,Country Code,Family,Buying Group">
			</CFIF>
			<CFIF appSettings.getcustid_on() EQ 1>
				<CFSET sort_By_List1 = LISTAPPEND(sort_By_List1,"Customer Id")>
				<CFSET sort_By_List_Value = LISTAPPEND(sort_By_List_Value,"Customer Id")>
			</CFIF>
			<CFPARAM NAME="FORM.sort_by" DEFAULT="#Trim(ListFirst(sort_By_List1))#">
			<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC1">

			<cfset sort_by_present = 0 />
			<cfset sort_order_present = 0 />

			<cfset UseCustomerType = appSettings.getCustomertype()>

			<TABLE border="0" align="center" cellpadding="4" class="filters">
				<TR>
			<!---29684: loop to display search fields--->
			<cfloop query="vars.qSearchField">
<!-------------------------------------------------------- Family ------------------------------------------------------------>
				<cfif vars.qSearchField.Field_Name eq "Family">
					<TD>
						<span class="searchItemLabel"><strong><CFOUTPUT>#application.returned_customer_setting.family_name_label_plural#</CFOUTPUT></strong></span><BR>
						<cfquery name="GetFamilyNames" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Family
							WHERE Deleted = 0
							<cfif appSettings.getSuppressGroupsZeroItems()>
								AND EXISTS (SELECT * FROM BSA_Foodservice_Customers WHERE Family_ID = Distributor_Family.Family_ID AND Deleted = 0 AND Active_Code = 'A')
							</cfif>
							<cfif form.businessSegmentsOn>
								<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0>
								and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
								<cfelse>
									<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
										and 1 = 1
									<cfelse>
										and 1=2
									</cfif>
								</cfif>
							</cfif>
							ORDER BY Family_Name
						</cfquery>
						<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">
						<SELECT NAME="Family_Name" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**All** <CFOUTPUT>#application.returned_customer_setting.family_name_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetFamilyNames"><OPTION VALUE="#trim(GetFamilyNames.Family_ID)#"#IIF(trim(FORM.Family_Name) EQ trim(GetFamilyNames.Family_ID), DE(" SELECTED"), DE(""))#>#trim(GetFamilyNames.Family_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Buying Group ------------------------------------------------------>
				<cfelseif vars.qSearchField.Field_Name eq "Buying Group">
					<TD>
						<span class="searchItemLabel"><strong><CFOUTPUT>#application.returned_customer_setting.buying_group_label_plural#</CFOUTPUT></strong></span><BR>
						<cfquery name="GetBuyingGroups" Datasource="#application.datasource#">
							SELECT *
							FROM Distributor_Buying_Groups
							WHERE Deleted = 0
							<cfif appSettings.getSuppressGroupsZeroItems()>
								AND EXISTS (SELECT * FROM BSA_Foodservice_Customers WHERE Buying_Group_ID = Distributor_Buying_Groups.Buying_Group_ID AND Deleted = 0 AND Active_Code = 'A')
							</cfif>
							<cfif form.businessSegmentsOn>
								<cfif Len(FORM.BUSINESS_SEGMENT_ID) GT 0>
								and Business_segment_id IN (#FORM.BUSINESS_SEGMENT_ID#)
								<cfelse>
									<cfif application.returned_customer_setting.Business_Segments_On EQ 1>
										and 1 = 1
									<cfelse>
										and 1=2
									</cfif>
								</cfif>
							</cfif>
							ORDER BY Buying_Group_Name
						</cfquery>
						<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">
						<SELECT NAME="Buying_Group" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION VALUE="0">**All** <CFOUTPUT>#application.returned_customer_setting.buying_group_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetBuyingGroups"><OPTION VALUE="#trim(GetBuyingGroups.Buying_Group_ID)#"#IIF(trim(FORM.Buying_Group) EQ trim(GetBuyingGroups.Buying_Group_ID), DE(" SELECTED"), DE(""))#>#trim(GetBuyingGroups.Buying_Group_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- Customer Type ------------------------------------------------------->
			<!--- 	<cfelseif vars.qSearchField.Field_Name eq "Customer Type">
					<cfif form.Is_Group EQ 0>
						<!---Initialize the appliation settings--->


							<!---Only do this if we're using customer types--->
							<cfif UseCustomerType IS 1 and appSettings.getApplyRSPFilters() EQ 1>
								<TD NOWRAP ALIGN="left"><strong>Customer Type:</strong><br>

									<SELECT NAME="Customer_Type">
										<option value="">**All Types**</option>
										<cfoutput query="Get_CustType_Profile_Settings">
											<cfif Get_CustType_Profile_Settings.PROFILE_CUSTOMER_TYPE_VALUE IS 1><option value="#Customer_Type#" <cfif Form.Customer_Type IS Customer_Type>selected</cfif>>#Customer_Type_Desc#</option></cfif>
										</cfoutput>
									</SELECT>
								</td>
							</cfif>

					</cfif>
			--->

<!-------------------------------------------------------- Line Of Biz ------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Line Of Business">
					<CFSET First_Time = NOT Isdefined("FORM.Line_Of_Biz")>
					<CFPARAM NAME="FORM.Line_Of_Biz" DEFAULT="0">
					<cfif application.returned_customer_setting.lob_search_switch EQ 1>
					<TD>
						<span class="searchItemLabel"><CFOUTPUT><strong>#application.returned_customer_setting.lob_label_singular#</strong></CFOUTPUT></span><BR>
						<SELECT NAME="Line_Of_Biz" style="width: 200px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
						<!--- If there's only one LOB automatically select it so it won't give you the "you must select" popup --->
						<CFIF GetLinesOfBiz.Recordcount EQ 1>
							<cfoutput>
								<OPTION
									VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"
									#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>
										#trim(GetLinesOfBiz.Line_Of_Business_Name)#
								</OPTION>
							</CFOUTPUT>
						<CFELSE>
								<OPTION VALUE="0">
									**All** <CFOUTPUT>#application.returned_customer_setting.lob_label_plural#</CFOUTPUT>
								</OPTION>
							<CFOUTPUT QUERY="GetLinesOfBiz">
								<CFIF Line_Of_Business EQ "#ListFirst(application.returned_customer_setting.Line_Business_Default,",")#" AND First_Time>
									<CFSET FORM.Line_Of_Biz = GetLinesOfBiz.Line_Of_Business_ID>
								</CFIF>
									<OPTION
										VALUE="#trim(GetLinesOfBiz.Line_Of_Business_ID)#"
										#IIF(trim(FORM.Line_Of_Biz) EQ trim(GetLinesOfBiz.Line_Of_Business_ID), DE(" SELECTED"), DE(""))#>
											#trim(GetLinesOfBiz.Line_Of_Business_Name)#
									</OPTION>
							</CFOUTPUT>
						</CFIF>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Zone -------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Zone">
					<cfif form.Is_Group EQ 0>
						<TD><!--- Zone --->
							<cfoutput><span class="searchItemLabel"><strong>#application.returned_customer_setting.zone_label_singular#:</strong></span><BR></cfoutput>
							<CFQUERY NAME="GetZones" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
							SELECT *
							FROM Service_Zones
							WHERE len(Zone_Name) != 0 AND Deleted = 0
									<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  START
									Added/Changed: Changed IF condition removed form.businessSegmentsOn eq 1--->
							<cfif isDefined("busSegIdForProgram") AND Lookup_BS_General_Dropdowns EQ 1>
								and Business_segment_id = #busSegIdForProgram#
							</cfif>
							<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->
							ORDER BY Zone_Name
							</CFQUERY>
							<CFPARAM NAME="FORM.Zone_ID" DEFAULT="0">
							<CFIF ShowDropDown EQ 1>
							<SELECT NAME="Zone_ID" style="width: 200px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
								<cfoutput><OPTION VALUE="0">**All** #application.returned_customer_setting.zone_label_plural#</OPTION></cfoutput>
								<CFOUTPUT QUERY="GetZones"><OPTION VALUE="#trim(GetZones.Service_Zone_ID)#"#IIF(trim(FORM.Zone_ID) EQ GetZones.Service_Zone_ID, DE(" SELECTED"), DE(""))#>#trim(GetZones.Zone_Name)#</OPTION></CFOUTPUT>
							</SELECT>
							<CFELSE>
								<IMG SRC="/images/disabled_dropdown.gif"><BR>
							</CFIF>
						</TD>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Region ------------------------------------------------------------>
				<cfelseif vars.qSearchField.Field_Name eq "Region">
					<cfif form.Is_Group EQ 0>
						<TD><!--- Regions --->
							<cfoutput><span class="searchItemLabel"><strong>#application.returned_customer_setting.region_label_singular#:

							</strong></span><BR></cfoutput>
							<CFQUERY NAME="GetRegions" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
							SELECT *
							FROM Service_Regions
							WHERE len(Region_Name) != 0 AND Deleted = 0
							<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  START
								Added/Changed: Changed IF condition removed form.businessSegmentsOn eq 1--->
							<cfif isDefined("busSegIdForProgram") AND Lookup_BS_General_Dropdowns EQ 1>
								and Business_segment_id = #busSegIdForProgram#
							</cfif>
							<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->
							ORDER BY Region_Name
							</CFQUERY>
							<CFPARAM NAME="FORM.Region_ID" DEFAULT="0">
							<CFIF ShowDropDown EQ 1>
							<SELECT NAME="Region_ID" style="width: 200px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
								<cfoutput><OPTION VALUE="0">**All** #application.returned_customer_setting.region_label_plural#</OPTION></cfoutput>
								<CFOUTPUT QUERY="GetRegions"><OPTION VALUE="#trim(GetRegions.Service_Region_ID)#"#IIF(trim(FORM.Region_ID) EQ getRegions.Service_Region_ID, DE(" SELECTED"), DE(""))#>#trim(GetRegions.Region_Name)#</OPTION></CFOUTPUT>
							</SELECT>
							<CFELSE>
								<IMG SRC="/images/disabled_dropdown.gif"><BR>
							</CFIF>
						</TD>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Broker ------------------------------------------------------------>
				<cfelseif vars.qSearchField.Field_Name eq "Broker">
					<cfif form.Is_Group EQ 0>
						<TD><!--- Brokers --->
							<cfoutput><span class="searchItemLabel"><strong>#application.returned_customer_setting.broker_label_singular#:</strong></span><BR></cfoutput>

							<cfquery name="GetAllBrokers" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
								SELECT a.Broker_Name, a.BSA_Foodservice_Brokers_ID, b.Market_Name
								FROM BSA_Foodservice_Brokers a
									INNER JOIN Service_Markets b ON a.Service_Market_ID = b.Service_Market_ID
								WHERE  ACTIVE_CODE = 'A'
									<!---
										D39427 :: CMI STAGE - error within program on distributor page
										AND a.Line_Of_Business_ID = '#GetFirstDefaultBiz.Line_Of_Business_ID#'
									  --->
									AND a.Deleted = 0
									<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  START
									Added/Changed: Changed IF condition removed form.businessSegmentsOn eq 1--->
								<cfif isDefined("busSegIdForProgram") AND Lookup_BS_General_Dropdowns EQ 1>
									AND a.Business_segment_id = #busSegIdForProgram#
								</cfif>
								<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->
								ORDER BY a.Broker_Name
							</cfquery>

							<cfset useLakebaseForGetBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallbrokers")>
<cfif useLakebaseForGetBrokers>
	<cftry>
		<cfset GetBrokers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallbrokers", {
				"select" = "broker_name"
			}), "broker_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokers>
<cfquery name="GetBrokers" dbtype="query">
								SELECT DISTINCT Broker_Name
								FROM GetAllBrokers
							</cfquery>
</cfif>

							<CFIF ShowDropDown EQ 1 AND Get_Profile_Settings.View_Broker_List EQ 1>
							<SELECT NAME="Broker" style="width: 200px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
								<cfoutput>
									<OPTION VALUE="0">**All** #application.returned_customer_setting.broker_label_plural#</OPTION>
								</cfoutput>
								<CFOUTPUT QUERY="GetBrokers">

									<cfset useLakebaseForGetBrokerIDs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallbrokers")>
<cfif useLakebaseForGetBrokerIDs>
	<cftry>
		<cfset GetBrokerIDs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallbrokers", {
				"broker_name" = "eq.#GetBrokers.Broker_Name#",
				"order" = "broker_name.asc",
				"select" = "bsa_foodservice_brokers_id"
			}), "bsa_foodservice_brokers_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBrokerIDs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBrokerIDs>
<cfquery name="GetBrokerIDs" dbtype="query">
										SELECT BSA_Foodservice_Brokers_ID
										FROM GetAllBrokers
										WHERE Broker_Name = '#GetBrokers.Broker_Name#'
										ORDER BY Broker_Name
									</cfquery>
</cfif>
									<cfset IDList = valueList(GetBrokerIDs.BSA_Foodservice_Brokers_ID)>
									<OPTION
										VALUE="#trim(IDList)#"
										#IIF(trim(FORM.Broker) EQ trim(IDList), DE(" SELECTED"), DE(""))#>
											#trim(GetBrokers.Broker_Name)#
									</OPTION>
								</CFOUTPUT>
							</SELECT>
							<CFELSE>
								<IMG SRC="/images/disabled_dropdown.gif"><BR>
							</CFIF>
						</TD>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>
<!---D57063 :: Added Below code to display MARKETS --->
<!-------------------------------------------------------- Market ------------------------------------------------------------>
				<cfelseif vars.qSearchField.Field_Name eq "Market">
					<cfif form.Is_Group EQ 0>
						<TD><!--- Markets --->
							<cfoutput><span class="searchItemLabel"><strong>#application.returned_customer_setting.market_label_singular#:</strong></span><BR></cfoutput>
							<CFQUERY NAME="GetMarkets" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
								SELECT *
								FROM Service_Markets
								WHERE len(Market_Name) != 0
								AND Deleted = 0
								<cfif isDefined("busSegIdForProgram") AND Lookup_BS_General_Dropdowns EQ 1>
									AND Business_segment_id = #busSegIdForProgram#
								</cfif>
								ORDER BY Market_Name
							</CFQUERY>
							<CFPARAM NAME="FORM.Market_ID" DEFAULT="0">
							<CFIF ShowDropDown EQ 1>
							<SELECT NAME="Market_ID" style="width: 200px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
								<cfoutput><OPTION VALUE="0">**All** #application.returned_customer_setting.market_label_plural#</OPTION></cfoutput>
								<CFOUTPUT QUERY="GetMarkets"><OPTION VALUE="#trim(GetMarkets.Service_Market_ID)#"#IIF(trim(FORM.Market_ID) EQ GetMarkets.Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(GetMarkets.Market_Name)#</OPTION></CFOUTPUT>
							</SELECT>
							<CFELSE>
								<IMG SRC="/images/disabled_dropdown.gif"><BR>
							</CFIF>
						</TD>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Planning Group ---------------------------------------------------->
				<cfelseif vars.qSearchField.Is_PG>
					<cfloop query="qGetTopLevelGroups">
						<cfif qGetTopLevelGroups.Distributor_Group_Level_Id eq vars.qSearchField.Distributor_Group_Level_Id>
			      	<cfif
								(<!--- form.Is_Group EQ 0 AND DistGroupDataManager.getDistributorLevelSearchFilterOn(qGetDistributorLevels, Distributor_Group_Level_Type_ID)) --->
			          form.Is_Group EQ 0 AND DistGroupDataManager.getDistributorLevelSearchFilterOnGroupTemplate(qGetDistributorLevelsGroupTemplate, Distributor_Group_Level_Type_ID))
								OR
								(form.Is_Group EQ 1 AND (checkSearchSequence EQ 0 OR SearchSequenceManager.enableThisDistributorGroupSelection(Program_Search_Sequence, Search_Sequence_Name)))>
								<TD>
									<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
									<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment ID--->
									<cfset groupDropDownBusinessSegmentFilter = 0 />
									<cfif Is_PG>
										<cfset groupDropDownBusinessSegmentFilter = Form.Business_Segment_Id />
									</cfif>

									<CFPARAM NAME="FORM.#DistributorAttributeDropDownName#" DEFAULT="0">
										<cfmodule 	template="/Customtags/DistributorGroupDropDown.cfm"
													groupLevelType = "#Distributor_Group_Level_Type_ID#"
													dropDownName = "#DistributorAttributeDropDownName#"
													selectedValue = "#Evaluate("FORM.#DistributorAttributeDropDownName#")#"
													cachedwithin="#APPLICATION.masterDataCacheSpan#"
													businessSegmentId="#groupDropDownBusinessSegmentFilter#"
													FirstParentID = "#GetTemplateInfo.First_parent_ID#"
													TemplateFiltersID = "#TemplateFiltersID#"
													/>
									<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
						</TD>
								<cfinclude template="_incTrSeparator.cfm" />
							</cfif>
						</cfif>
					</cfloop>

<!-------------------------------------------------------- Sort By ----------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Sort By">
					<cfif form.Is_Group EQ 0>
						<TD align="left" NOWRAP>
						<strong>Sort By:</strong><BR>

						<CFOUTPUT>
							<cfset InitHeader()>    <!---29687 Chris: get the column header assignments--->

							<!---break combo entries (separated by ':') into twos--->
							<cfset hdr.display = Replace(Header_Display_List, ":", ",", "all")>
							<cfset hdr.value   = Replace(Header_Value_List,   ":", ",", "all")>

							<CFSET sort_By_List=ListSort(hdr.display, "Text")>
							<SELECT ID="sort_by" NAME="sort_by" STYLE="WIDTH:200px" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
								<cfset thisValue = ListGetAt(hdr.value, ListFindNoCase(hdr.display, thisItem))>
								<CFSET thisItem=Trim(thisItem)>
								<OPTION VALUE="#thisValue#"<CFIF thisValue EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>

							</CFLOOP>
							</SELECT>
						</CFOUTPUT>
						<cfset sort_by_present = 1 />
						</TD>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Order ------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Order">
					<cfif form.Is_Group EQ 0>
						<TD NOWRAP ALIGN="left">
							<strong>Order:</strong><BR>
							<SELECT ID="sort_Order" NAME="sort_Order" STYLE="WIDTH:200px" onkeydown="if (event.keyCode == 13) doSearchNow();">
								<OPTION VALUE="ASC"<CFIF FORM.sort_Order EQ "ASC"> SELECTED</CFIF>>Ascending</OPTION>
								<OPTION VALUE="DESC"<CFIF FORM.sort_Order EQ "DESC"> SELECTED</CFIF>>Descending</OPTION>
							</SELECT>
							<cfset sort_order_present = 1 />
						</td>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Name -------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Name">
						<cfif form.Is_Group EQ 0>
							<!--- 29964: Search tool issues/Anand Rao/20-Jan-2012
								If the colspan column happens to be the 4th column then it extends beyond the page hence
								to avoid it a special handling is added here so that this will get pushed to the next
								row.
							--->
							<cfif currentColCount GTE 3>
								<cfset currentColCount = currentColCount + 1 />
								<cfinclude template="_incTrSeparator.cfm" />
							</cfif>
	 						<TD colspan="2">
	 						<strong>Name:</strong><br>
							<INPUT TYPE="Text" NAME="searchstring" STYLE="WIDTH:360px" SIZE="40"<CFIF len(trim(FORM.searchstring)) GT 0>VALUE="<CFOUTPUT>#trim(FORM.searchstring)#</CFOUTPUT>"</CFIF> onkeydown="if (event.keyCode == 13) doSearchNow();">
							</TD>
							<cfset currentColCount = currentColCount + 1 />
							<cfinclude template="_incTrSeparator.cfm" />
						</cfif>

<!-------------------------------------------------------- Ship To ----------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Ship To">
						<cfif form.Is_Group EQ 0>
							<CFPARAM NAME="Form.Ship_To" 	DEFAULT="">
							<TD nowrap align="left">
							<span class="searchItemLabel"><cfoutput><strong>#application.returned_customer_setting.shard_ship_to_label#:</strong></cfoutput></span>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<A HREF="javascript:void(0)"  onclick="window.showModalDialog('/Common_Files/createList.cfm?passObj=Customers&passForm=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&programID=<cfoutput>#FORM.Contract_Main_ID#</cfoutput>',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >
								<CFOUTPUT>#application.util.string.actionLinkFormat('create list')#</CFOUTPUT>
							</A><br>
							<INPUT SIZE="12" TYPE="TEXT" NAME="Ship_To" VALUE="<CFOUTPUT>#Form.Ship_To#</CFOUTPUT>" onkeydown="if (event.keyCode == 13) doSearchNow();">
							</TD>
							<cfinclude template="_incTrSeparator.cfm" />
						</cfif>

<!-------------------------------------------------------- Country ----------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Country">
					<TD>
						<CFQUERY NAME="getCountry" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
							SELECT distinct bc.country_code, country_name, Country_id
							FROM BSA_Foodservice_Customers bc
							Join  _Country c on
							(
							bc.country_code = c.country_code
							OR
							bc.country_code = c.country_code2
							)
							<cfif appsettings.getShowExportPrograms()>
							 Inner Join Export_Lookup_Destination_Country
							 On
							 (
							 Export_Lookup_Destination_Country.country_code = c.country_code
							 OR
							 Export_Lookup_Destination_Country.country_code = c.country_code2
							 )
							<cfelse>
							where active = 1
							</cfif>
							ORDER BY Country_id ASC
						</CFQUERY>
						<span class="searchItemLabel"><strong>Country:</strong></span><BR>
						<SELECT NAME="Country_Code" STYLE="WIDTH:115px;font-size: 11px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
							<OPTION SELECTED value="0">**All** Countries</OPTION>
							<CFOUTPUT QUERY="getCountry">
							<OPTION VALUE="#getCountry.Country_Code#" #IIF(trim(FORM.country_code) EQ trim(GetCountry.country_code), DE(" SELECTED"), DE(""))#>#getCountry.Country_Name#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />

<!-------------------------------------------------------- State ------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "State">
					<cfif form.Is_Group EQ 0>
							<TD>
								<strong>State:</strong><br>
							<cfquery name="GetStates" datasource="#application.datasource#" cachedwithin="#APPLICATION.masterDataCacheSpan#">
								SELECT DISTINCT State, State_Name, Country_Sort_Order
								FROM BSA_Foodservice_Customers c
								join _States s on s.State_Code =  c.state
								join _Country on s.Country_ID = _Country.Country_ID
								WHERE	LEN(State) > 0
								ORDER BY Country_Sort_Order, State
							</cfquery>

									<SELECT NAME="State" STYLE="WIDTH:115px;font-size: 11px;" onkeydown="if (event.keyCode == 13) doSearchNow();">
										<OPTION VALUE="0">**All** States</OPTION>
										<CFOUTPUT QUERY="GetStates"><OPTION VALUE="#trim(GetStates.state)#"#IIF(trim(FORM.state) EQ trim(GetStates.state), DE(" SELECTED"), DE(""))#><CFIF len(trim(GetStates.state)) EQ 0>Sate Not Specified<CFELSE>#trim(GetStates.state_name)#</CFIF></OPTION></CFOUTPUT>
									</SELECT>
							</TD>
							<cfinclude template="_incTrSeparator.cfm" />
					</cfif>

<!-------------------------------------------------------- Status ------------------------------------------------------------->
				<cfelseif vars.qSearchField.Field_Name eq "Status">
					<cfif form.Is_Group EQ 0>
						<TD NOWRAP ALIGN="left">
							<strong>Status:</strong>
							<BR>
							<SELECT NAME="Distributor_Status" onkeydown="if (event.keyCode == 13) doSearchNow();">
								<OPTION VALUE="A">Active</OPTION>
								<!--26199 allows inactive option based on user profile setting -->
								<cfif Get_Profile_Settings.Search_Inactive_Distributors_Programs eq 1>
								<OPTION VALUE="N" <CFIF FORM.Distributor_Status EQ "N">SELECTED</CFIF>>Inactive</OPTION>
								</cfif>
							</SELECT>
						</TD>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>
<!---------------------------------------- All other Fields not checked above and NOT in PG ------------------------------->
				<cfelseif vars.qSearchField.Is_PG EQ 0>
					<cfloop query="qGetTopLevelGroups">
						<cfif qGetTopLevelGroups.Distributor_Group_Level_Id eq vars.qSearchField.Distributor_Group_Level_Id>
					<cfif
								(<!--- form.Is_Group EQ 0 AND DistGroupDataManager.getDistributorLevelSearchFilterOn(qGetDistributorLevels, Distributor_Group_Level_Type_ID)) --->
					form.Is_Group EQ 0 AND DistGroupDataManager.getDistributorLevelSearchFilterOnGroupTemplate(qGetDistributorLevelsGroupTemplate, Distributor_Group_Level_Type_ID))
								OR
								(form.Is_Group EQ 1 AND (checkSearchSequence EQ 0 OR SearchSequenceManager.enableThisDistributorGroupSelection(Program_Search_Sequence, Search_Sequence_Name)))>
								<TD>
									<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
									<CFPARAM NAME="FORM.#DistributorAttributeDropDownName#" DEFAULT="0">
										<cfmodule 	template="/Customtags/DistributorGroupDropDown.cfm"
													groupLevelType = "#Distributor_Group_Level_Type_ID#"
													dropDownName = "#DistributorAttributeDropDownName#"
													selectedValue = "#Evaluate("FORM.#DistributorAttributeDropDownName#")#"
													cachedwithin="#APPLICATION.masterDataCacheSpan#"
													businessSegmentId="#Group_Business_segment_id#"
													FirstParentID = "#GetTemplateInfo.First_parent_ID#"
													TemplateFiltersID = "#TemplateFiltersID#"
													/>
								</TD>
								<cfinclude template="_incTrSeparator.cfm" />
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>    <!---end of vars.qSearchField loop--->

<!-------------------------------------------------------- Customer Type ------------------------------------------------------->
					<cfif form.Is_Group EQ 0>
						<!---Initialize the appliation settings--->
							<!---Only do this if we're using customer types--->
							<cfif UseCustomerType IS 1 and appSettings.getApplyRSPFilters() EQ 1>
								<TD NOWRAP ALIGN="left"><strong>Customer Type:</strong><br>

									<SELECT NAME="Customer_Type" onkeydown="if (event.keyCode == 13) doSearchNow();">
										<option value="">**All Types**</option>
										<cfoutput query="Get_CustType_Profile_Settings">
											<cfif Get_CustType_Profile_Settings.PROFILE_CUSTOMER_TYPE_VALUE IS 1><option value="#Customer_Type#" <cfif Form.Customer_Type IS Customer_Type>selected</cfif>>#Customer_Type_Desc#</option></cfif>
										</cfoutput>
									</SELECT>
								</td>
								<cfinclude template="_incTrSeparator.cfm" />
							</cfif>
						</cfif>

<!--- END: D29392/Anand Rao/05-Dec-2011 Distributor and Operator search tools  --->

				</TR>
				<TR>
					<TD colspan="100%">
					<!--- BJF D11212 Distributor Product Integrity --->
					<cfset RestrictByRule = 0>
					<cfset Rule_Name = "">
					<cfif appsettings.getDistributor_Product_Integrity_On() IS 1 AND len(trim(getSettings.Distributor_Product_Integrity_Rule_ID)) GT 0>
						<cfquery name="GetIntegrityRuleType" datasource="#application.datasource#">
						SELECT Inclusive_Restriction, Rule_Name
						FROM Distributor_Product_Integrity_Rule
						WHERE Distributor_Product_Integrity_Rule_ID = #getSettings.Distributor_Product_Integrity_Rule_ID#
						</cfquery>
						<!--- You only restrict the search if the rule is inclusive, otherwise your just pick it up on RFA --->
						<cfif GetIntegrityRuleType.Inclusive_Restriction EQ 1>
							<cfset RestrictByRule = 1>
							<cfset Rule_Name = GetIntegrityRuleType.Rule_Name>
						</cfif>
					</cfif>

					<cfif RestrictByRule IS 1><font color="red" size="-2">* The results returned are modified by the <cfoutput>#lcase(application.returned_customer_setting.distributor_label_singular)#</cfoutput>/product integrity rule <cfoutput>#Rule_Name#</cfoutput></font></cfif>
					<TABLE align="center">
						<TR>
						<TD ALIGN="center" NOWRAP width="25%">
							<!--- &nbsp;&nbsp; --->
							<cfset searchDistributorLabel = "search #lcase(application.returned_customer_setting.distributor_label_plural)# " />
							<cfif form.Is_Group>
								<cfset searchDistributorLabel = "search #lcase(application.returned_customer_setting.distributor_label_singular)# groups" />
							</cfif>
							<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" name="searchButton" ONCLICK="javascript: return doSearchNow();"><cfoutput> #trim(searchDistributorLabel)# </cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="javascript: reset_Form_Fields();"> reset </a><FONT COLOR="#FF0000">]</FONT></B>
						</TD>
						</TR>
					</TABLE>
					</TD>
				</TR>
				<!---if business segements are on then display--->
				<cfif form.businessSegmentsOn eq 1>
				<tr>
					<td colspan="100%"><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>:&nbsp;&nbsp;<b><cfoutput>#Bus_Segment_Desc#</cfoutput></b></td>
				</tr>
				</cfif>
			</TABLE>

		<!--- D29781: Distributor Search and Sorting/Anand Rao/03-Jan-2012
			 if the Sort_by/sort_order is not included we will be adding a dummy sort_by and sort_order with
			 a display set to 0 so that the user cannot see this and also the script will work for sorting
			 the data.
		--->
			<cfoutput>
			<cfif sort_by_present EQ 0>
				<cfset InitHeader()>    <!---29687 Chris: get the column header assignments--->
				<!---break combo entries (separated by ':') into twos--->
				<cfset hdr.display = Replace(Header_Display_List, ":", ",", "all")>
				<cfset hdr.value   = Replace(Header_Value_List,   ":", ",", "all")>
				<CFSET sort_By_List=ListSort(hdr.display, "Text")>
				<SELECT ID="sort_by" NAME="sort_by" STYLE="WIDTH:0px;display:none;" onkeydown="if (event.keyCode == 13) doSearchNow();">
				<CFLOOP LIST="#sort_By_List#" INDEX="thisItem">
					<cfset thisValue = ListGetAt(hdr.value, ListFindNoCase(hdr.display, thisItem))>
					<CFSET thisItem=Trim(thisItem)>
					<OPTION VALUE="#thisValue#"<CFIF thisValue EQ FORM.sort_by> SELECTED</CFIF>>#thisItem#</OPTION>
				</CFLOOP>
				</SELECT>
			</cfif>
			<cfif sort_order_present EQ 0>
				<select id="sort_Order" name="sort_Order" style="width:0px;display:none" onkeydown="if (event.keyCode == 13) doSearchNow();">
					<option value="ASC"<cfif FORM.sort_Order EQ "ASC"> SELECTED</cfif>>Ascending</option>
					<option value="DESC"<cfif FORM.sort_Order EQ "DESC"> SELECTED</cfif>>Descending</option>
				</select>
			</cfif>
			</cfoutput>

	</FIELDSET>
<!--- D70951 :: ‘Please Wait’ Indicator     Release START --->
<div class="customContainer" style="display:none;"></div>
<!--- D70951 :: ‘Please Wait’ Indicator     Release END --->
	</Div>
			<cfparam name="Form.groupLevelDistributors" default="0">
			<cfoutput>
			<input type="hidden" name="Line_Of_Business_ID" value="#form.Line_Of_Business_ID#">
			<input type="hidden" name="DOSEARCH" value="1">
			<input type="hidden" name="groupLevelDistributors" 	value="#Form.groupLevelDistributors#" />
			<input type="hidden" name="passed_form"				value="#form.passed_form#">
			<input type="hidden" name="itemList" 				value="#form.itemList#">
			<input type="hidden" name="SelectSingleSearchResultOnly" value="#form.SelectSingleSearchResultOnly#">
			<input type="hidden" name="Is_Group" value="#form.Is_Group#">
			<input type="hidden" name="Dist_Name" value="#form.Dist_Name#">
			</cfoutput>

	<script language="JavaScript">
	<cfoutput>

	/*function checkAddAllIsOn()
	{
		var bSelectedAllDistributors = false;
		var groupLevel = 0;
		if(document.all.groupLevelDistributors)
		{
			if(document.all.groupLevelDistributors.value == "1")
			{
				groupLevel = 1;
				bSelectedAllDistributors = true;
			}
		}
		if(bSelectedAllDistributors)
		{
			if(window.confirm("Your current action will remove 'All #application.returned_customer_setting.distributor_label_plural#'." + "\n" + "Do you want to continue?"))
			{
				//if groupLevel = 1
				document.all.groupLevelDistributors.value = "0";
				document.all.Distributor_Level_1.value = "";
				document.all.FinalItemList.value = "";
				bSelectedAllDistributors = false;
			}
		}
		return bSelectedAllDistributors;
	}*/

	function doSearchNow()	{

		processingPopUpDisplay('div.customContainer'); //D51575
		//add restricted search
		var oSearchForm = document.MyForm;
		//reset the hidden value used to communicate with createList
		$("input[name=passed_form]").val('');
		$("input[name=itemList]").val('');

		/*if(checkAddAllIsOn())
		{
			return false;
		}*/

		var any_Filter = false;
		var availOptions = "";
		if(oSearchForm.Line_Of_Biz && oSearchForm.Is_Group.value == 0)
		{
			if(oSearchForm.Line_Of_Biz.value != "0")
			{
				any_Filter = true;
			}
		}
		else
		{
			any_Filter = true;
		}
		availOptions = availOptions + "\n - #application.returned_customer_setting.lob_label_plural#";
		if(!any_Filter)
		{
			alert("You have to select at least one of the following filters" + availOptions);
		}
		else
		{
			oSearchForm.startrow.value = 1;
			oSearchForm.frompage.value = 1;
			oSearchForm.submit();
		}
		return false;

	}
	</cfoutput>
	</script>

<!--- ON SEARCH --->
<CFIF FORM.DOSEARCH EQ 1>
<cfsilent>

	<CFSET form.searchstring = trim(Replace(form.searchstring, "'", "''", "all"))>

	<cfif form.Is_Group eq 1>

		<cfset TheQuery = DistGroupDataManager.getCustomerGroups(
				searchFilter=Form,
				qGetTopLevelGroups=qGetAllGroupLevels,
				searchFilterRequired=1,
				groupCombinationOn=groupCombinationOn,
				groupCombinationDefinitionHeaderID=groupCombinationDefinitionHeaderID,
				Distributor_Name= form.Dist_Name,
				businessSegmentId=Group_Business_segment_id,
				Program_ID=FORM.Contract_Main_ID,
				FirstParentID=FirstParentID,
				TemplateFiltersId=TemplateFiltersId) />

	<cfelse>

		<!--- get the distributor information --->
		<cfset stStruct = StructNew()>
		<cfset stStruct 				= Form>
		<cfset stStruct.appSettings 	= appSettings>
		<cfset stStruct.GetSettings 	= GetSettings>
		<cfset stStruct.qGetTopLevelGroups = qGetAllGroupLevels>
		<cfset stStruct.FirstParentID = FirstParentID>
		<cfset stStruct.TemplateFiltersID = TemplateFiltersID>

		<cfif UseCustomerType and appSettings.getApplyRSPFilters() EQ 1>
			<cfset stStruct.profileCustTypeSettings	= Get_CustType_Profile_Settings>
		</cfif>

		<cfset distributorManager = CreateObject("component", "components.customer.DistributorManager").init()>
		<!--- Dev Note(82139) - Filter distributor results based on program position --->
		<cfset variables.DistributorFilterPositionID = 0>
		<CFIF GetTemplateInfo.Filter_Distributor_Results_Based_On_Program_Position EQ 1>
			<cfset variables.DistributorFilterPositionID = GetContractInfo.Creating_User_Position_ID>
		</CFIF>

		<cfset TheQuery = distributorManager.search(search=stStruct, useCache=0, showDistExceptions=0 , positionID=variables.DistributorFilterPositionID,PlannerID=FORM.plannerID)>

	</cfif>
</cfsilent>
<SCRIPT>

function savedistributors(){
	processingPopUpDisplay('div.customContainer'); //D51575

	var r = false;
	<cfif appSettings.getAutoWeightDistributorsProgramRevision() EQ 1>
		r = true;
	</cfif>

	opener.document.MyForm.FinalItemList.value = $('input[name=FinalItemList]').val();
	opener.document.MyForm.updateFinalItemListFrompopup.value = 1;
	/* In this case the weight is auto-applied, but the user is taken to the next step in creating the program (e.g. rebate page)
	and not to the "distributor" page on import.
	*/
	if(r == true){
		opener.document.MyForm.editcurrentweight.value = 0;
		opener.document.MyForm.autoApplyWeight.value = 1;
	}
	/* In this case the weight is also auto-applied, but the user is taken to the "distributor" page on import. */
	else{
		opener.document.MyForm.editcurrentweight.value = 1;
	}
	opener.document.MyForm.LoadSavedDistributors.value = 0;
	opener.document.MyForm.finishedselectingitems.value = 1;
	opener.document.MyForm.submit();
	window.close();
}
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				<!----
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
				----->
				if(0==0) {
					for (var i=0;i<MyForm.elements.length;i++)
						{
							var e = MyForm.elements[i];
							if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
								e.checked = MyForm.allbox.checked;
							}
						}
				//toggleRowColors()
				}
				else {
					document.all.allbox.checked = false;
				}
			}
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		function setThisSortItem(sortVal, sortOrder)
		{
			event.returnValue = false;
			//document.MyForm.reset();
			var SelObj = document.all.sort_by;
			var next_Index = Get_Select_Index(SelObj, sortVal);
			if(next_Index >=0)
			{
				SelObj.selectedIndex = next_Index;
				SelObj = document.all.sort_Order;
				SelObj.selectedIndex = Get_Select_Index(SelObj, sortOrder);
				document.MyForm.submit();
			}
		}
		
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->		
		<!--- 113201	Planner Program - Alternate Customer / Anand Rao / 25-Feb-2022 --->
		function addSelAltDists()
		{
			 
			document.getElementById("indDistSubmitted").value = "1";
			<cfoutput>
			document.getElementById('MyForm').action = "/Planners/Create/planner_alternate_customers.cfm?CID=#URL.CID#&plannerID=#form.plannerID#&bEdit=#URL.bEdit#";
			document.getElementById('MyForm').target = "_top";
			</cfoutput>
			this.MyForm.submit();
		}
		
		/* 	This function will submit the opening page, "planner_program_create.cfm" and will close the 
			distributor addition popup */
		function saveAndCloseAltDist()
		{
			addSelAltDists(); 
			parent.opener.document.getElementById("bLoadVolumeFromDB").value="1";
			parent.opener.document.MyForm.submit();
			parent.window.close();
		}		
	</SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<CFIF FORM.DOSEARCH EQ 1>
	<cfset variables.bShowSave = "visible">
<CFELSE>
	<cfset variables.bShowSave = "hidden">
</CFIF>
<cfif form.plannerID EQ 0>
	<TABLE style="margin:12px 0;">
		<TR>
			<cfif variables.bShowSave NEQ 'hidden'>
				<TD id="showSaveLink">
					<CF_button
						button_name		=	""
						button_caption	=	"save"
						button_action	=	"javascript:savedistributors();this.disabled=true;"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			</cfif>
			<TD>
		</TR>
	</TABLE>
<cfelse>
	<br>	
</cfif>
<FIELDSET STYLE="padding:8px; width: 860; border: 1px solid Blue;">
		<cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>#application.returned_customer_setting.distributor_label_singular#<CFELSE>#application.returned_customer_setting.distributor_label_plural#</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND></cfoutput>
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="5" align="center" WIDTH="100%" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84" VALIGN="top">
					<cfoutput>
						<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
							<TD align="center">
								<INPUT Name="allbox" TYPE="Checkbox" TITLE="Click here to select all #application.returned_customer_setting.distributor_label_plural#">
							</TD>
						<CFELSE>
							<TD>&nbsp;</TD>
						</CFIF>
					</cfoutput>

					<cfset InitHeader()>	<!---29687 Chris: moved header variable assignments into a function so it can be used in another place--->

					<CFSET Counter = 1>
					<CFOUTPUT>
					<CFLOOP LIST="#Header_Display_List#" INDEX="This_Header" DELIMITERS=",">
						<CFSET This_Value = ListGetAt(Header_Value_List, Counter, ",")>
						<TD ID="header"><B>
						<CFSET Counter_1 = 1>
						<CFLOOP LIST="#This_Header#" INDEX="Each_Token" DELIMITERS=":">
							<CFSET This_Value_Token = ListGetAt(This_Value, Counter_1, ":")>
							<CFIF Counter_1 GT 1>
							<BR>/
							</CFIF>
							<CFSET Next_Sort_Item = This_Value_Token>
							<CFSET Next_Sort_Order = "ASC">
							<CFSET Img_String = "">
							<CFIF CompareNoCase(This_Value_Token, FORM.sort_by) EQ 0><!--- current sort --->
								<CFIF FORM.sort_Order EQ "ASC"><!--- current sort --->
									<CFSET Next_Sort_Order = "DESC">
									<CFSET Img_String = "<IMG SRC=""/Images/down_1.gif"">">
								<CFELSE>
									<CFSET Img_String = "<IMG SRC=""/Images/up_1.gif"">">
								</CFIF>
							</CFIF>
							<CFIF Trim(Next_Sort_Item) NEQ "">
							<A HREF="##" onClick="javaScript:return setThisSortItem('#Next_Sort_Item#', '#Next_Sort_Order#');">
							</CFIF>
							#Each_Token#
							<CFIF Trim(Next_Sort_Item) NEQ "">
							</A> #Img_String#
							</CFIF>
							<CFSET Counter_1 = Counter_1 + 1>
						</CFLOOP>
						</B></TD>
						<CFSET Counter = Counter + 1>
					</CFLOOP>
					</CFOUTPUT>
					<!------<cfoutput><TD align="left" ID="header"><B>#application.returned_customer_setting.distributor_label_singular# Name / Ship To</B></TD></cfoutput>
					<TD ID="header"><B>Address</B></TD>
					<cfoutput><TD ID="header"><B>#application.returned_customer_setting.broker_label_singular#</B></TD></cfoutput>
					<cfoutput><TD ID="header"><B>#application.returned_customer_setting.family_name_label_singular# / #application.returned_customer_setting.buying_group_label_singular#</B></TD></cfoutput>					----->
				</TR>
			<!---<cfset Group_Level_ID_List = "">--->
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<!--- <cf_cryp type="en" string="#TheQuery.BSA_Foodservice_Customers_ID#" key="#request.key#"> --->
				<TR STYLE="cursor:pointer;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
					<!--- When distributors are excluded from a group, they are retrieved on the "distributor weight page" from the "Contract_Distributors_Exceptions" table,
					and not the "Contract_Distributors" table.
					In that case, we disable those distributors on this page, so that they are not imported twice.
					--->
					<cfset IsExcludeDistributor = 0>
					<cfif (ListFindNoCase(Replace(form.excludeDistributor,"_","-","ALL"), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0)>
							<cfset IsExcludeDistributor = 1>
					</cfif>
					<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
						<TD align="center">
							<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
							<INPUT CLASS="distCheckBox" type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" onClick="addRemoveCustomers()"
							<cfif ListFindNoCase(ValueList(qPrgDistExceptions.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED="CHECKED" DISABLED="DISABLED"</cfif>
							<CFIF (ListFindNoCase(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0)
							OR
								(IsExcludeDistributor eq 1)
							>
							CHECKED="CHECKED"
							<cfif (RevisionSettings.Distributors_Removed eq 2 AND ListFindNoCase(ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0)
							OR
								(IsExcludeDistributor eq 1)
							>
							DISABLED="DISABLED"
							</cfif>
					<cfelse>
						<cfif RevisionSettings.Distributors_Added eq 2>DISABLED="DISABLED"</cfif></CFIF>>
							<cfif RevisionSettings.Distributors_Removed eq 2 OR RevisionSettings.Distributors_Added eq 2>
								<cfif RevisionSettings.Distributors_Removed eq 2 AND ListFindNoCase(ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>
									<INPUT type="hidden" class="check_items" name="SelectedITEMS" value="#trim(TheQuery.BSA_Foodservice_Customers_ID)#">
								</cfif>
							</cfif>
						<cfelse>
							<INPUT class="distCheckBox" type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" onClick="addRemoveCustomers()"
							<CFIF (ListFindNoCase(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0)
							OR
								(IsExcludeDistributor eq 1)
							>
							CHECKED
							<cfif IsExcludeDistributor eq 1>disabled</cfif>
							</CFIF>
							>
						</cfif>
						</TD>
					<CFELSE>
						<TD align="center">
						<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
						<INPUT type="Radio" NAME="SelectedITEMS" class="distCheckBox" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" onClick="addRemoveCustomers()"
						<CFIF ListFindNoCase(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED="CHECKED"
					<CFIF RevisionSettings.Distributors_Removed eq 2 AND 	ListFindNoCase(ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>DISABLED="DISABLED"</CFIF><CFELSE><CFIF RevisionSettings.Distributors_Added eq 2 OR RevisionSettings.Distributors_Removed eq 2>DISABLED="DISABLED"</CFIF></CFIF>>
						<cfif RevisionSettings.Distributors_Removed eq 2 OR RevisionSettings.Distributors_Added eq 2>
							<cfif RevisionSettings.Distributors_Removed eq 2 AND ListFindNoCase(ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>
							<INPUT type="hidden" name="SelectedITEMS" value="#trim(TheQuery.BSA_Foodservice_Customers_ID)#">
							</cfif>
						</cfif>
					<cfelse>
						<INPUT type="Radio" NAME="SelectedITEMS" class="distCheckBox" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" onClick="addRemoveCustomers()" <CFIF ListFindNoCase(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED</CFIF>>
					</cfif>
						</TD>
					</CFIF>

					<!--- <TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#TheQuery.Ship_To#&nbsp;</TD> --->
					<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#TheQuery.Distributor_Group_Level_ID#&Is_Group=#form.Is_Group#&programID=#form.Contract_Main_ID#','name','400','450','Yes', 'No');return false;" NOWRAP>#TheQuery.Name# <cfif thequery.WHSE NEQ "">(#thequery.WHSE#)</cfif>
						<BR>
						<cfif appSettings.get_Setting('Display_Distributor_ID') eq '1'>
							#TheQuery.Shr_Ship_To#
						<cfelse>
							#TheQuery.Ship_To#
						</cfif>&nbsp;
					</TD>
					<cfif DistResults_DisplayAddress>
					<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#TheQuery.Distributor_Group_Level_ID#&Is_Group=#form.Is_Group#&programID=#form.Contract_Main_ID#','name','400','450','Yes', 'No');return false;">#TheQuery.Address_1#<BR>#TheQuery.City#,#TheQuery.State# #TheQuery.ZipCode#&nbsp;#UCase(TheQuery.Country_Code)#</TD>
					</cfif>
					<!--- <TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >#TheQuery.Buying_Group_Name#&nbsp;</TD> --->
					<CFIF ShowBrokerInResult EQ 1 AND DistResults_DisplayBroker EQ 1>
					<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#TheQuery.Distributor_Group_Level_ID#&Is_Group=#form.Is_Group#&programID=#form.Contract_Main_ID#','name','400','450','Yes', 'No');return false;" >#TheQuery.Broker_Name#&nbsp;</TD>
					</CFIF>
					<TD valign="top" onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#TheQuery.Distributor_Group_Level_ID#&Is_Group=#form.Is_Group#&programID=#form.Contract_Main_ID#','name','400','450','Yes', 'No');return false;" NOWRAP><cfif TheQuery.Family_Name NEQ "" AND DistResults_DisplayFamily>#(TheQuery.Family_Name eq 'NONE' ? 'None' : TheQuery.Family_Name)#</cfif><cfif TheQuery.Buying_Group_Name NEQ "" AND DistResults_DisplayBuyingGroup><BR>#(TheQuery.Buying_Group_Name eq 'NONE' ? 'None' : TheQuery.Buying_Group_Name)#</cfif>
					<cfif appSettings.getPlanningGroups() and isDefined("TheQuery.PG_Type_Name")>
					<BR>#TheQuery.PG_Type_Name#
					</cfif>
					&nbsp;
					</TD>
					<!--- <TD NOWRAP onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">&nbsp;(#TheQuery.Active_Code#)<cfif TheQuery.Active_Code EQ "A">Active<cfelse>Inactive</cfif>&nbsp;</TD> --->
 				</TR>
			</CFOUTPUT>
			</TABLE>

			<HR COLOR="Orange" SIZE="2">
			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
			<CF_Next_Previous_For_Forms
				formname="MyForm"
				query="TheQuery"
				maxpages="40"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams=""
			>

			<HR COLOR="Orange" SIZE="2">
		</CFIF>
		<script language="javascript">
		function showstartingWith(sValue)
		{
			document.MyForm.Dist_Name.value =sValue;
			doSearchNow();
		}
		</script>
		<tr>
		<TABLE CELLPADDING="2" CELLSPACING="1" BORDER="0" ALIGN="CENTER"><TR>
		<cfoutput>
			<cfloop index="LoopCount" from="65" to="90">
					<TD class="notranslate">
						<B>
						<CFIF chr(LoopCount) EQ form.Dist_Name>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
					 <CFIF chr(LoopCount) EQ form.Dist_Name>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
			<cfloop index="LoopCount" from="0" to="9">
					<TD>
						<B>
						<CFIF LoopCount EQ form.Dist_Name>
							<FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('#LoopCount#');">#LoopCount#</A>
						<CFIF LoopCount EQ form.Dist_Name>
							<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
			</cfloop>
					<TD>
						<B>
						<CFIF "" EQ form.Dist_Name>
						 <FONT COLOR="FF0000">[</FONT>
						</CFIF>
						<A HREF="##" onClick="javaScript: return showstartingWith('');">ALL</A>
					 <CFIF "" EQ form.Dist_Name>
						<FONT COLOR="FF0000">]</FONT></CFIF>
						</B>
					</TD>
	</cfoutput>
	 </TR>
	</TABLE>
	</tr>
	</FIELDSET>
</CFIF><!---  IF FORM.DOSEARCH --->
<cfoutput>
	<input type="hidden" name="Line_Of_Business_ID" value="#form.Line_Of_Business_ID#">
	<input type="hidden" name="Business_Segment_ID" value="#FORM.Business_Segment_ID#">
	<input type="hidden" name="businessSegmentsOn" value="#form.businessSegmentsOn#">
	<input type="hidden" name="FinalItemList" ID="FinalItemList" value="#Form.FinalItemList#">
	<input type="hidden" name="frompage" value="#frompage#">
	<input type="hidden" name="startrow" value="#startrow#">
	<input type="hidden" name="Contract_Main_ID" value="#form.Contract_Main_ID#">
	<input type="hidden" name="ExcludeDistributor" value="#request.app_general_functions.listRemoveDupes(form.ExcludeDistributor,',')#">
	<input type="hidden" name="plannerID" value="#form.plannerID#">
	<input type="hidden" name="indDistSubmitted" id="indDistSubmitted" value="0" />

</cfoutput>
</FORM>

<cfif TheQuery.recordcount GT 0>
	<FIELDSET STYLE="padding:8px; width: 800; border: none;">
	<DIV ALIGN="center">
	<cfif form.plannerID EQ 0>
		<FONT SIZE="2">													<!--- finishedSearching() --->
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" onClick="javascript: savedistributors()"> import selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
	<CFIF FORM.SelectSingleSearchResultOnly EQ 0>
		<FONT SIZE="2">
		<B><FONT COLOR="#FF0000">[</FONT>
		<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 and RevisionSettings.Distributors_Added eq 2>
		<span style="color:gray">import all returned <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput>
		</span>
		<cfelse>
		<a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT>)"> import all returned <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a>
		</cfif>
		<FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
		<FONT SIZE="2">
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" STYLE="cursor: pointer;" onClick="removeAllProducts()"> remove all selected <cfoutput>#lcase(application.returned_customer_setting.distributor_label_plural)#</cfoutput> </a><FONT COLOR="#FF0000">]</FONT></B>
		</FONT>	</cfif>
	<cfelse>
		<cfoutput>
			<cfset addSelAltDistLabel = "add selected " & lcase(application.returned_customer_setting.distributor_label_plural)/>
			<a href="##" onclick="javascript:addSelAltDists();"  title="Add and save selected records">#application.util.string.actionLinkFormat2(addSelAltDistLabel)#</a>
			<a href="##" onclick="javascript:saveAndCloseAltDist();" style="margin-left:10px;" title="close window">#application.util.string.actionLinkFormat2("close")#</a>
		</cfoutput>
	</cfif>	
	</DIV>
	</FIELDSET>
	<BR>
	</cfif>
	<SCRIPT>
	<cfif TheQuery.recordcount GT 0>
		function importAllProducts(recordcount){
			if(confirm("Do you want to import all " + recordcount + " records from your search?")){

				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'1' as an argument below means "true". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(1);
				callfireEvent(document,document.all.allbox,'Click');

				if(document.MyForm.FinalItemList.value.length > 0){
					document.MyForm.FinalItemList.value = document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.BSA_Foodservice_Customers_ID)#</CFOUTPUT>";
					opener.document.MyForm.FinalItemList.value = document.MyForm.FinalItemList.value;
				}
				else{
					document.MyForm.FinalItemList.value = "<CFOUTPUT>#valuelist(TheQuery.BSA_Foodservice_Customers_ID)#</CFOUTPUT>";
					opener.document.MyForm.FinalItemList.value = document.MyForm.FinalItemList.value;
				}
				savedistributors();//d65768 fix - all save in one place

					// d65768 fix //opener.document.MyForm.updateFinalItemListFrompopup.value = 1;
					/* "editcurrentweight" - 1 or 0 depending on auto apply. 0 is auto apply, which means that on import, the request will go to the db.
					So, the user will not stay on the "weight" page after import. */
					//d65768 fix //opener.document.MyForm.editcurrentweight.value = 1;
					//d65768 fix //opener.document.MyForm.LoadSavedDistributors.value = 0;
					//d65768 fix //opener.document.MyForm.submit();
					//d65768 fix //window.close();
			}
		}

		function removeAllProducts(){
			if(confirm("By pressing OK all records will be unselected")){

				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'1' as an argument below means "true". */
				//$('input.distCheckBox:checked').attr("checked", "");
				$("input:checkbox").prop('checked', false);
				$('input[name=FinalItemList]').val('');
				//savedistributors(); //d65768 fix - all save in one place
			}
		}

		function finishedSearching() {
			processingPopUpDisplay('div.customContainer'); //D51575
			opener.document.MyForm.finishedselectingitems.value = 1;
			opener.document.MyForm.FinalItemList.value = $('input[name=FinalItemList]').val( );
			opener.document.MyForm.updateFinalItemListFrompopup.value = 1;
			/* "editcurrentweight" - 1 or 0 depending on auto apply. 1 is "No auto apply", which means that on import, the request will not go to the db. */
			if(document.MyForm.FinalItemList.value != ''){
				opener.document.MyForm.editcurrentweight.value = 1;
			}
			else{
				/* "editcurrentweight" - 1 or 0 depending on auto apply. 0 is auto apply, which means that on import, the request will go to the db.
				So, the user will not stay on the "weight" page after import. */
				opener.document.MyForm.editcurrentweight.value = 0;
				/* "autoApplyWeight" - Set it to 1. This is useful when a user removes all the distributors from the popup
				and then clicks on "import selected distributors". In this case, since zero distrbutors are selected, zero should be imported.
				By setting autoApplyWeight to 1, the request goes to the db and all the existing distributors (if any) get deleted. */
				opener.document.MyForm.autoApplyWeight.value = 1;
			}
			opener.document.MyForm.LoadSavedDistributors.value = 0;
			opener.document.MyForm.submit();
			window.close();
		}
	</cfif>
</SCRIPT>
<SCRIPT>
function hide_Spinner()
{
	if(document.all.PleaseWaitMessage)
	{
		if(document.all.PleaseWaitMessage.style)
		{
			document.all.PleaseWaitMessage.style.display='none';
		}
	}
}
hide_Spinner();

//load the name of the select boxes to hide
//findselectboxes();
</SCRIPT>
<cfif application.programLayout EQ 1>
	</div>
</cfif>

<cfinclude template="/Common_Files/jQuery.cfm">

<!--- D51575 PLEASE WAIT INDICATOR    8.0 Release START --->
<cfinclude template="/Common_Files/noty.cfm">
<!--- D51575 PLEASE WAIT INDICATOR    8.0 Release END --->

<script language="JavaScript">
	function reset_Form_Fields()
	{
			var search_form = $("form[name='MyForm']");
			$('select', search_form).each(function() {
					if ( $(this).attr('id') === 'sort_by' ) {}
					else {
						$(this).val( $('option:first', $(this)).val() ) // reset select dropdown with default 1st option
							.trigger('change'); // trigger onchange event
					}
			});
			// reset all non-hidden (visible) input to blank
			$('input:visible', search_form).val( '' );

			document.MyForm.Dist_Name.value = ""; //D 29939: Reset
	}

	/* When "select all" checkbox is "Checked/Unchecked". */
	$('input[name=allbox]').change(function() {
		$("input.distCheckBox").attr("checked", (this.checked ? true : false));
		 addRemoveCustomers();
	});

	function addRemoveCustomers(){
        let hiddenCBoxes     = '';
		let aDistributorList = [];
        let allowed_multiple_distributors = <cfif GetTemplateInfo.One_Distributor> false <cfelse> true </cfif>;

        if ( allowed_multiple_distributors ) {
            /* all checked rows are saved in a hidden input with a name of 'FinalItemList' */
		    hiddenCBoxes = $('input[name=FinalItemList]').val().toLowerCase();

		    /* convert the list into an array for easy manipulation */
		    if (hiddenCBoxes.length) {
			    aDistributorList = hiddenCBoxes.split(",");
            }
        }
		/* scan thru all checkboxes (or radio buttons for single selection) on the page */
		$('input.distCheckBox').each( function() {
		/* Kept it lowercase for being used in case-insensitive search using "$.inArray" */
		var distributorID = $(this).val().toLowerCase();

			if ( $(this).prop('checked') ) {
				 /* checked box is not in the array, add it */
				if($.inArray(distributorID, aDistributorList) == -1){

					aDistributorList.push( distributorID );
				}
			}
			else {
				 /* box is not checked so we need to remove it */
				while($.inArray(distributorID, aDistributorList) != -1) {
					aDistributorList.splice($.inArray(distributorID , aDistributorList),1);
				}
			}
		});

		/* convert array back to a list for usage in form action */
		hiddenCBoxes = aDistributorList.join(",");

		/* refresh the hidden input with ALL selected rows */
		$('input[name=FinalItemList]').val( hiddenCBoxes );
	}
</script>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxx CF FUNCTIONS BELOW xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cffunction name="InitHeader" output="false">
	<CFSET Header_Display_List = "#application.returned_customer_setting.distributor_label_singular# Name:#application.returned_customer_setting.shard_ship_to_label#">
	<CFSET Header_Value_List = "Name:Ship To">

	<cfset showHideColumnsSetting()>

	<CFIF DistResults_DisplayAddress eq 1>
		<CFSET Header_Display_List = ListAppend(Header_Display_List, "Address")>
		<CFSET Header_Value_List = ListAppend(Header_Value_List, "Address", ",")>
	</CFIF>

	<CFIF ShowBrokerInResult EQ 1 AND DistResults_DisplayBroker EQ 1>
		<CFSET Header_Display_List = ListAppend(Header_Display_List, "#application.returned_customer_setting.broker_label_singular#", ",")>
		<CFSET Header_Value_List = ListAppend(Header_Value_List, "Broker", ",")>
	</CFIF>

	<cfif DistResults_DisplayFamily AND DistResults_DisplayBuyingGroup>
		<CFSET Header_Display_List = ListAppend(Header_Display_List, "#application.returned_customer_setting.family_name_label_singular#:#application.returned_customer_setting.buying_group_label_singular#", ",")>
		<CFSET Header_Value_List = ListAppend(Header_Value_List, "Family:Buying Group", ",")>

	<cfelseif DistResults_DisplayFamily>
		<CFSET Header_Display_List = ListAppend(Header_Display_List, "#application.returned_customer_setting.family_name_label_singular#", ",")>
		<CFSET Header_Value_List = ListAppend(Header_Value_List, "Family", ",")>

	<cfelseif DistResults_DisplayBuyingGroup>
		<CFSET Header_Display_List = ListAppend(Header_Display_List, "#application.returned_customer_setting.buying_group_label_singular#", ",")>
		<CFSET Header_Value_List = ListAppend(Header_Value_List, "Buying Group", ",")>
	</cfif>
</cffunction>

<!---
Determines search result column's visibility.
Go to "settings>application settings>Labels>Settings labels" to set visibility
--->
<cffunction name="showHideColumnsSetting" output="false">

	<!--- Address --->
	<cfset DistResults_DisplayAddress = 0>
	<cfloop query="DistSearchResultsColumnsDisplayAdditionalSettings">
		<cfif field_name eq "Address">
			<cfset DistResults_DisplayAddress = 1>
		</cfif>
	</cfloop>

	<cfset DistResults_DisplayBroker = 0>
	<cfset DistResults_DisplayFamily = 0>
	<cfset DistResults_DisplayBuyingGroup = 0>
	<cfloop query="DistSearchResultsColumnsDisplaySettings">
		<!--- Broker  --->
		<cfif Group_Level_Desc_Internal eq "Broker">
			<cfset DistResults_DisplayBroker = 1>
		</cfif>
		<!--- Family --->
		<cfif Group_Level_Desc_Internal eq "Family">
			<cfset DistResults_DisplayFamily = 1>
		</cfif>
		<!--- Buying Group --->
		<cfif Group_Level_Desc_Internal eq "Buying Group">
			<cfset DistResults_DisplayBuyingGroup = 1>
		</cfif>
	</cfloop>

</cffunction>
<cfinclude template="/common_Files/focus.cfm">
</body>
</html>
