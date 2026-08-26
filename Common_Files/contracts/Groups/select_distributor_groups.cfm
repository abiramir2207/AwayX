<cfinclude template="/actionFormat.cfm">
<cf_Number_of_Rows maxrows=25>
<cfparam name="form.loaded" default="0">

<cfset Header_Display_List = "">
<cfset Header_Value_List = "">

<cfif form.passed_form NEQ "" and form.itemList NEQ "">
	<cfset form.itemList = trim(replace(ListQualify(form.itemList, "'", ",", "ALL"), "''", "'", "ALL")) >
</cfif>

<cfif isDefined("URL.CID") AND len(trim(URL.CID)) GT 0>
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
	 <cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#GetContractInfo.ProgramType_ID#",
				"select" = "first_parent_id,base_sales_equal_to_lowest_bracket,custom_fixed_price_options"
			}), "first_parent_id,base_sales_equal_to_lowest_bracket,custom_fixed_price_options"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
		SELECT First_parent_ID, Base_Sales_Equal_To_Lowest_Bracket, Custom_Fixed_Price_Options
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
<CFINCLUDE TEMPLATE="../commonqueries.cfm" />

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
<cfif (form.Is_Group eq 1 OR form.Is_Group eq 2) AND checkSearchSequence EQ 1 AND isDefined("Program_Search_Sequence.Customer_Group_Combination_Definition_Header_ID") AND isNumeric(Program_Search_Sequence.Customer_Group_Combination_Definition_Header_ID)>
	<cfset groupCombinationOn = 1 />
	<cfset groupCombinationDefinitionHeaderID = Program_Search_Sequence.Customer_Group_Combination_Definition_Header_ID />
</cfif>

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

<FORM ACTION="/Common_Files/contracts/select_distributors_programs_popup.cfm?CID=<CFOUTPUT>#URL.CID#&plannerID=#form.plannerID#&bEdit=#URL.bEdit#</CFOUTPUT>" METHOD="post" NAME="distForm" ID="distForm" STYLE="DISPLAY:INLINE">

<cfset maxColsPerRow = 4/>
<cfset currentColCount = 0/>

	<cfif (form.Is_Group EQ 1 OR form.Is_Group EQ 2) OR appSettings.getFlexDistributorSearch() eq 0>
		<Div id="dvSearchFields" style="display:block;">
	<cfelse>
		<Div id="dvSearchFields" style="display:none;">
	</CFIF>
	<!--- <FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;display:table"> --->
	    <!--- <cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#application.returned_customer_setting.distributor_label_plural# search <cfif form.Is_Group EQ 1 OR form.Is_Group EQ 2>by Groups</cfif></LEGEND></cfoutput> --->
<cfoutput><font color="##000066" size="4">Select  #application.returned_customer_setting.distributor_label_singular# Groups</font></cfoutput>
<hr color="navy">
			<cfif not isDefined("GetTemplateInfo.First_Parent_ID")>
				<cfset FirstParentID = 0 />
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
						   ,Group_Level_Desc
					  FROM vars.AllTemplateFields
					 WHERE <cfif form.Is_Group>
					 			 	Allow_In_Group_Search = 1
					 			 <cfelse>
					 			 	Allow_In_Search = 1
								  </cfif>
							ORDER BY List_Order
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
						SELECT *
						  FROM vars.TemplateSearchFields
						 UNION
						SELECT Field_Name
						       ,Distributor_Group_Level_Id
						       ,List_Order
						       ,Is_PG
							   ,Group_Level_Desc
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
			<cfif (isDefined("form.plannerID") AND form.plannerID NEQ 0)>
				<cfset useLakebaseForqGetCustID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("planners")>
<cfif useLakebaseForqGetCustID>
	<cftry>
		<cfset qGetCustID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("planners", {
				"planner_id" = "eq.#form.plannerID#",
				"select" = "distributor_group_level_id"
			}), "distributor_group_level_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCustID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCustID>
<cfquery name="qGetCustID"  datasource="#application.datasource#">
					SELECT Distributor_Group_Level_ID FROM planners WHERE planner_id = #form.plannerID#
				</cfquery>
</cfif>
				<cfset plannerCUstID = qGetCustID.Distributor_Group_Level_ID />
			</cfif>
<p>
<table width="100%" border="0" cellpadding="1" cellspacing="0" style="border:thin">
	<tr>
		<td colspan="100%" bgcolor="#EAEAEA" id="header">
			<!--- Remove duplicates --->
			<cfquery name="qTopLevelGroup" dbtype="query">
				SELECT DISTINCT   Distributor_Group_Level_Id
								, Field_Name
								, Group_Level_Desc
				  FROM vars.qSearchField
				  <cfif (isDefined("form.plannerID") AND form.plannerID NEQ 0)>
					  WHERE Distributor_Group_Level_Id != '#plannerCUstID#'
				  </cfif>
			</cfquery>


			<strong>&nbsp;&nbsp;Select Top Level Group:</strong>
			<select name="Top_Level" style="width: 200px;"  onkeydown="if (event.keyCode == 13) doSearchNow();" id="TopLevel" <cfif qTopLevelGroup.recordcount EQ 1>onload="doSearchNow();"</cfif>>
				<cfif vars.qSearchField.recordcount GT 1>
				<option value="0">Select Group</option>
				</cfif>
				<cfoutput query="qTopLevelGroup">
					<option value="#trim(qTopLevelGroup.Distributor_Group_Level_Id)#" <cfif (isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ 0 AND FORM.Top_Level EQ trim(qTopLevelGroup.Distributor_Group_Level_Id)) OR qTopLevelGroup.recordcount EQ 1 AND(isDefined("form.plannerID") AND form.plannerID EQ 0)>selected </cfif>>
						<cfif (qTopLevelGroup.Field_Name eq "Family")>#application.returned_customer_setting.family_name_label_plural#
						<cfelseif (qTopLevelGroup.Field_Name eq "Buying Group")>#application.returned_customer_setting.buying_group_label_plural#
						<cfelseif (qTopLevelGroup.Field_Name eq "Line Of Business")>#application.returned_customer_setting.lob_label_plural#
						<cfelseif (qTopLevelGroup.Field_Name eq "Zone")>#application.returned_customer_setting.zone_label_plural#
						<cfelseif (qTopLevelGroup.Field_Name eq "Region")>#application.returned_customer_setting.region_label_plural#
						<cfelseif (qTopLevelGroup.Field_Name eq "Broker")>#application.returned_customer_setting.broker_label_plural#
						<cfelseif (qTopLevelGroup.Field_Name eq "Market")>#application.returned_customer_setting.market_label_plural#
						<!--- <cfelseif (qTopLevelGroup.Is_PG EQ 1)>#qTopLevelGroup.Field_Name# --->
						<cfelse>
							#trim(qTopLevelGroup.Group_Level_Desc)#
						</cfif>
					</option>
				</cfoutput>
			</SELECT>&nbsp;
			<!---  <CF_smallLink
				title = "get groups"
				url = "##"
				parameters = "onClick=""javascript: submitForm()"""
			>
			--->
			&nbsp;
			<CF_smallLink
				title = "cancel"
				url = "##"
				parameters = "onClick=""javascript: window.close();"""
			>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<!--- <CF_smallLink
		title = "import groups"
		url = "##"
		parameters = "onClick=""javascript: finishedSearching();"""
		> --->
		</td>
	</tr>
</table>
</p>
 <br>

			<cfif isDefined("FORM.Top_Level") AND FORM.Top_Level NEQ 0>
			<cfloop query="vars.qSearchField">
				<cfloop query="qGetAllGroupLevels">

<!-------------------------------------------------------- Family ------------------------------------------------------------>
				<cfif vars.qSearchField.Field_Name eq "Family" AND vars.qSearchField.Distributor_Group_Level_ID EQ qGetAllGroupLevels.Distributor_Group_Level_ID AND FORM.Top_Level EQ vars.qSearchField.Distributor_Group_Level_ID>
						<cfquery name="TheQuery" Datasource="#application.datasource#">
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
						<!--- Dev Note: (76832) - Removed "FORM.Family_Name" and replaced with ""FORM.#DistributorAttributeDropDownName#" --->
						<!---<CFPARAM NAME="FORM.Family_Name" DEFAULT="0">--->
						<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
						<CFPARAM NAME="FORM.#DistributorAttributeDropDownName#" DEFAULT="0">
 <!-------------------------------------------------------- Buying Group ------------------------------------------------------>
				<cfelseif vars.qSearchField.Field_Name eq "Buying Group" AND vars.qSearchField.Distributor_Group_Level_ID EQ qGetAllGroupLevels.Distributor_Group_Level_ID AND FORM.Top_Level EQ vars.qSearchField.Distributor_Group_Level_ID>
						<cfquery name="TheQuery" Datasource="#application.datasource#">
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
						<!--- Dev Note: (76832) - Removed "FORM.Buying_Group" and replaced with ""FORM.#DistributorAttributeDropDownName#" --->
						<!---<CFPARAM NAME="FORM.Buying_Group" DEFAULT="0">--->
						<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
						<CFPARAM NAME="FORM.#DistributorAttributeDropDownName#" DEFAULT="0">
<!-------------------------------------------------------- Planning Group ---------------------------------------------------->
				<cfelseif vars.qSearchField.Is_PG  AND vars.qSearchField.Distributor_Group_Level_ID EQ qGetAllGroupLevels.Distributor_Group_Level_ID AND FORM.Top_Level EQ vars.qSearchField.Distributor_Group_Level_ID>
 					<cfloop query="qGetTopLevelGroups">
						<cfif qGetTopLevelGroups.Distributor_Group_Level_Id eq vars.qSearchField.Distributor_Group_Level_Id>
			      	<cfif
								(form.Is_Group EQ 0 AND DistGroupDataManager.getDistributorLevelSearchFilterOnGroupTemplate(qGetDistributorLevelsGroupTemplate, Distributor_Group_Level_Type_ID))
								OR
								((form.Is_Group EQ 1) AND (checkSearchSequence EQ 0 OR SearchSequenceManager.enableThisDistributorGroupSelection(Program_Search_Sequence, Search_Sequence_Name)))>
									<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
									<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment START Added Business Segment ID--->
									<cfset groupDropDownBusinessSegmentFilter = 0 />
									<cfif Is_PG>
										<cfset groupDropDownBusinessSegmentFilter = Form.Business_Segment_Id />
									</cfif>

									<CFPARAM NAME="FORM.#DistributorAttributeDropDownName#" DEFAULT="0">
										<!--- <cfmodule 	template="/Customtags/DistributorGroupDropDown.cfm"
													groupLevelType = "#Distributor_Group_Level_Type_ID#"
													dropDownName = "#DistributorAttributeDropDownName#"
													selectedValue = "#Evaluate("FORM.#DistributorAttributeDropDownName#")#"
													cachedwithin="#APPLICATION.masterDataCacheSpan#"
													businessSegmentId="#groupDropDownBusinessSegmentFilter#"
													FirstParentID = "#GetTemplateInfo.First_parent_ID#"
													TemplateFiltersID = "#TemplateFiltersID#"
													/> --->

										<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
		<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = "#Distributor_Group_Level_Type_ID#") />
		<cfset TheQuery = DistributorGroupAttributeManager.getDistributorGroupValues(
								DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
								businessSegmentId				= "#groupDropDownBusinessSegmentFilter#",
								cachedwithin					= "#APPLICATION.masterDataCacheSpan#",
                				TemplateID            			= "#GetTemplateInfo.First_parent_ID#",
								TemplateFiltersID            	= "#TemplateFiltersID#")
                />

		<!---  <B>#stGetGroupAttributeInfo.Label#</B><br>
									<!--- Dev Note: Drachala; D27578: Planning Group setup - require business segment END--->
						</TD> --->
								<!--- <cfinclude template="/Common_Files/contracts/_incTrSeparator.cfm" /> --->
							</cfif>
						</cfif>
					</cfloop>


 <!---------------------------------------- All other Fields not checked above and NOT in PG ------------------------------->
				<cfelseif vars.qSearchField.Is_PG EQ 0  AND vars.qSearchField.Distributor_Group_Level_ID EQ qGetAllGroupLevels.Distributor_Group_Level_ID AND FORM.Top_Level EQ vars.qSearchField.Distributor_Group_Level_ID>
					<cfloop query="qGetTopLevelGroups">
						<cfif qGetTopLevelGroups.Distributor_Group_Level_Id EQ vars.qSearchField.Distributor_Group_Level_Id AND FORM.Top_Level EQ qGetTopLevelGroups.Distributor_Group_Level_Id>
					<cfif (form.Is_Group EQ 0 AND DistGroupDataManager.getDistributorLevelSearchFilterOnGroupTemplate(qGetDistributorLevelsGroupTemplate, Distributor_Group_Level_Type_ID))
								OR
							((form.Is_Group EQ 1 OR form.Is_Group EQ 2) AND FORM.Top_Level EQ vars.qSearchField.Distributor_Group_Level_Id AND (checkSearchSequence EQ 0 OR SearchSequenceManager.enableThisDistributorGroupSelection(Program_Search_Sequence, Search_Sequence_Name)))>

									<cfset DistributorAttributeDropDownName = "Distributor_Attribute_#Distributor_Group_Level_Type_ID#" />
									<CFPARAM NAME="FORM.#DistributorAttributeDropDownName#" DEFAULT="0">
										<!--- <cfmodule 	template="/Customtags/DistributorGroupDropDown.cfm"
													groupLevelType = "#Distributor_Group_Level_Type_ID#"
													dropDownName = "#DistributorAttributeDropDownName#"
													selectedValue = "#Evaluate("FORM.#DistributorAttributeDropDownName#")#"
													cachedwithin="#APPLICATION.masterDataCacheSpan#"
													businessSegmentId="#Group_Business_segment_id#"
													FirstParentID = "#GetTemplateInfo.First_parent_ID#"
													TemplateFiltersID = "#TemplateFiltersID#"
													/> --->
									<cfset DistributorGroupAttributeManager = CreateObject("component", "components.customer.group.DistributorGroupAttributeManager").init() />
									<cfset stGetGroupAttributeInfo = DistributorGroupAttributeManager.getGroupAttributeInfo(groupLevelTypeId = Distributor_Group_Level_Type_ID) />
									<cfset TheQuery = DistributorGroupAttributeManager.getDistributorGroupValues(
															DistributorGroupAttributeInfo 	= stGetGroupAttributeInfo,
															businessSegmentId				= "#Group_Business_segment_id#",
															cachedwithin					= "#APPLICATION.masterDataCacheSpan#",
							                				TemplateID            			= "#GetTemplateInfo.First_parent_ID#",
															TemplateFiltersID            	= "#TemplateFiltersID#")
							                />

							</cfif>
						</cfif>
					</cfloop>
				</cfif>

				</cfloop> <!--- <cfloop query="qGetAllGroupLevels">  --->
			</cfloop>    <!--- END of vars.qSearchField loop --->
		</cfif>	<!--- END <cfif isDefined(FORM.Top_Level) AND FORM.Top_Level NEQ 0> ---->
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
			<input type="hidden" name="grpSubmitted" id="grpSubmitted" value="0" />
			<input type="hidden" name="indDistSubmitted" id="indDistSubmitted" value="0" />
			</cfoutput>

	<script language="JavaScript">
	<cfoutput>

	function doSearchNow()	{

		processingPopUpDisplay('div.customContainer'); //D51575
		//add restricted search
		var oSearchForm = document.MyForm;
		//reset the hidden value used to communicate with createList
		$("input[name=passed_form]").val('');
		$("input[name=itemList]").val('');

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


	<link rel="stylesheet" type="text/css" href="/Common_Files/datatable.css">
		<table class="datagrid" id="datagrid"  style='table-layout:fixed'>
			<col width="5%"><!--- checkbox --->
			<col width="35%"><!--- ID --->
			<col width="50%"><!--- Name --->
			<thead>
				<tr>
    				<th style="text-align:center;">
						<cfif FORM.SelectSingleSearchResultOnly EQ 0>
							<input type="checkbox" id="select_all" name="allbox">
						<cfelse>
							&nbsp;
						</cfif>
					</th>
		 			<th align="left"><strong>Group Number</strong></th>
					<th align="left"><strong>Group</strong></th>
				</tr>
 			</thead>
			<tbody>
<!--- ON SEARCH --->
<CFIF FORM.DOSEARCH EQ 1>
	<cfset form.searchstring = trim(Replace(form.searchstring, "'", "''", "all"))>
	<cfif (form.Is_Group eq 1 OR form.Is_Group EQ 2)>
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
				TemplateFiltersId=TemplateFiltersId,
				plannerID=form.plannerID) />
<!--- 	<cfelse>
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
		<cfset TheQuery = distributorManager.search(stStruct, 0)>
 --->
	</cfif>
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
	
	/* <!--- 113201	Planner Program - Alternate Customer / Anand Rao / 25-Feb-2022 ---> */
		function addSelAltDistGroups() 
		{
			document.getElementById("grpSubmitted").value = "1";
			<cfoutput>
				document.getElementById('distForm').action = "/Planners/Create/planner_alternate_customers.cfm?CID=#URL.CID#&plannerID=#form.plannerID#&bEdit=#URL.bEdit#";
				document.getElementById('distForm').target = "_top";
			</cfoutput>
			this.distForm.submit();
		}
		
		/* 	This function will submit the opening page, "planner_program_create.cfm" and will close the 
			distributor addition popup */
		function saveAndCloseAltDistGroups()
		{
			addSelAltDistGroups();
			parent.opener.document.getElementById("bLoadVolumeFromDB").value="1";
			parent.opener.document.MyForm.submit();
			parent.window.close();
		}
		
	</SCRIPT>
	<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>

<cfif FORM.DOSEARCH EQ 1>
	<cfset variables.bShowSave = "visible">
<cfelse>
	<cfset variables.bShowSave = "hidden">
</cfif>

<cfif TheQuery.recordcount GT 0>
	<cfsavecontent variable="tbody_content">
	<cfoutput Query="TheQuery"><!--- startrow="#StartRow#" maxrows="#MaxRows#"> --->
		<tr>
 			<cfset IsExcludeDistributor = 0>
			<cfif (listfind(Replace(form.excludeDistributor,"_","-","ALL"), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0)>
				<cfset IsExcludeDistributor = 1>
			</cfif>
			<cfif FORM.SelectSingleSearchResultOnly EQ 0>
				<td align="center">
					<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
						<input class="distCheckBox" type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" onClick="addRemoveCustomers()"
							<cfif listfind(ValueList(qPrgDistExceptions.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED="CHECKED" DISABLED="DISABLED"</cfif>
							<CFIF (listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0)
							OR
								(IsExcludeDistributor eq 1)
							>
							CHECKED="CHECKED"
							<cfif (RevisionSettings.Distributors_Removed eq 2 AND listfind(ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0)
							OR
								(IsExcludeDistributor eq 1)
							>
							DISABLED="DISABLED"
							</cfif>
					<cfelse>
						<cfif RevisionSettings.Distributors_Added eq 2>DISABLED="DISABLED"</cfif></CFIF>>
							<cfif RevisionSettings.Distributors_Removed eq 2 OR RevisionSettings.Distributors_Added eq 2>
								<cfif RevisionSettings.Distributors_Removed eq 2 AND listfind(ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>
									<input type="hidden" class="check_items" name="SelectedITEMS" value="#trim(TheQuery.BSA_Foodservice_Customers_ID)#">
								</cfif>
							</cfif>
						<cfelse>
							<input class="distCheckBox" type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" onClick="addRemoveCustomers()"
							<CFIF (listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0)
							OR
								(IsExcludeDistributor eq 1)
							>
							CHECKED
							<cfif IsExcludeDistributor eq 1>disabled</cfif>
							</CFIF>
							>
						</cfif>
						</TD>
					<cfelse>
						<td align="center">
						<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
						<input type="Radio" NAME="SelectedITEMS" class="distCheckBox" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" onClick="addRemoveCustomers()"
						<CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED="CHECKED"
					<cfif RevisionSettings.Distributors_Removed eq 2 AND 	listfind(ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>DISABLED="DISABLED"</CFIF><CFELSE><CFIF RevisionSettings.Distributors_Added eq 2 OR RevisionSettings.Distributors_Removed eq 2>DISABLED="DISABLED"</CFIF></CFIF>>
						<cfif RevisionSettings.Distributors_Removed eq 2 OR RevisionSettings.Distributors_Added eq 2>
							<cfif RevisionSettings.Distributors_Removed eq 2 AND listfind(ValueList(ParentProgramDistributors.BSA_Foodservice_Customers_ID), trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>
							<input type="hidden" name="SelectedITEMS" value="#trim(TheQuery.BSA_Foodservice_Customers_ID)#">
							</cfif>
						</cfif>
					<cfelse>
						<input type="Radio" NAME="SelectedITEMS" class="distCheckBox" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" onClick="addRemoveCustomers()" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED</CFIF>>
					</cfif>
						</TD>
					</cfif>
					<td><a href="##" onclick="profile('#TheQuery.BSA_Foodservice_Customers_ID#','#TheQuery.Distributor_Group_Level_ID#')">#TheQuery.Group_Number#</a></td>
					<td>#TheQuery.Group_Name# </td>
					<!--- <CFIF ShowBrokerInResult EQ 1 AND DistResults_DisplayBroker EQ 1>
				<TD onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#TheQuery.Distributor_Group_Level_ID#&Is_Group=#form.Is_Group#&programID=#form.Contract_Main_ID#','name','400','450','Yes', 'No');return false;" >#TheQuery.Broker_Name#&nbsp;</TD>
					</CFIF>
					<TD valign="top" onClick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#TheQuery.Distributor_Group_Level_ID#&Is_Group=#form.Is_Group#&programID=#form.Contract_Main_ID#','name','400','450','Yes', 'No');return false;" NOWRAP><cfif TheQuery.Family_Name NEQ "" AND DistResults_DisplayFamily>#(TheQuery.Family_Name eq 'NONE' ? 'None' : TheQuery.Family_Name)#</cfif><cfif TheQuery.Buying_Group_Name NEQ "" AND DistResults_DisplayBuyingGroup><BR>#(TheQuery.Buying_Group_Name eq 'NONE' ? 'None' : TheQuery.Buying_Group_Name)#</cfif>
					<cfif appSettings.getPlanningGroups() and isDefined("TheQuery.PG_Type_Name")>
					<BR>#TheQuery.PG_Type_Name#
					</cfif>
					&nbsp;
					</TD> --->
					<!--- <TD NOWRAP onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">&nbsp;(#TheQuery.Active_Code#)<cfif TheQuery.Active_Code EQ "A">Active<cfelse>Inactive</cfif>&nbsp;</TD> --->
 				</TR>
			</CFOUTPUT>
	</cfsavecontent>
	<cfoutput>#application.util.string.compress(tbody_content)#</cfoutput>
		</CFIF>
<!--- <cfelse>
	<div align="center"><strong>No data available!</strong></div> --->
</cfif><!---  IF FORM.DOSEARCH --->
</tbody>
		</table>
<cfoutput>
<div style="clear:both"></div>
<cfif TheQuery.recordcount GT 0>
	<div style="margin-top:10px;">
		<cfif form.plannerID NEQ 0>
			<a href="##" onclick="javascript:addSelAltDistGroups();" title="Add and save selected groups">#application.util.string.actionLinkFormat2("add selected groups")#</a>
			<a href="##" onclick="javascript:saveAndCloseAltDistGroups();" style="margin-left:10px;" title="close window">#application.util.string.actionLinkFormat2("close")#</a>
		<cfelse>
			<a href="##" onclick="javascript:savedistributors();">#application.util.string.actionLinkFormat2("import selected groups")#</a>
			<a href="##" onclick="javascript:window.close();" style="margin-left:10px;">#application.util.string.actionLinkFormat2("cancel")#</a>
		</cfif>
		
</div>
</cfif>
	<input type="hidden" name="Line_Of_Business_ID" value="#form.Line_Of_Business_ID#">
	<input type="hidden" name="Business_Segment_ID" value="#FORM.Business_Segment_ID#">
	<input type="hidden" name="businessSegmentsOn" value="#form.businessSegmentsOn#">
	<input type="hidden" name="FinalItemList" ID="FinalItemList" value="#Form.FinalItemList#">
	<input type="hidden" name="frompage" value="#frompage#">
	<input type="hidden" name="startrow" value="#startrow#">
	<input type="hidden" name="Contract_Main_ID" value="#form.Contract_Main_ID#">
	<input type="hidden" name="ExcludeDistributor" value="#request.app_general_functions.listRemoveDupes(form.ExcludeDistributor,',')#">
	<input type="hidden" name="loaded" value="0">
</cfoutput>
</FORM><br>
<br>
 	<SCRIPT>

	<cfif TheQuery.recordcount GT 0>
 		function finishedSearching() {
			processingPopUpDisplay('div.customContainer'); //D51575
			opener.document.MyForm.finishedselectingitems.value = 1;
			opener.document.MyForm.FinalItemList.value = $('input[name=FinalItemList]').val( );
			opener.document.MyForm.updateFinalItemListFrompopup.value = 1;
			/* "editcurrentweight" - 1 or 0 depending on auto apply. 1 is "No auto apply", which means that on import, the request will not go to the db. */
			if(document.distForm.FinalItemList.value != ''){
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
</BLOCKQUOTE>
<SCRIPT>
function submitForm(){
	if(document.all.Top_Level.value != 0){
			this.distForm.submit();
	}else{
		alert('Please select a group.')
		return false;
	}
}

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

</SCRIPT>
<cfif application.programLayout EQ 1>
	</div>
</cfif>

<cfinclude template="/Common_Files/jQuery.cfm">

<!--- D51575 PLEASE WAIT INDICATOR    8.0 Release START --->
<cfinclude template="/Common_Files/noty.cfm">
<!--- D51575 PLEASE WAIT INDICATOR    8.0 Release END --->

<script language="JavaScript">
	/* When "select all" checkbox is "Checked/Unchecked". */
	$('input[name=allbox]').change(function() {
		$("input.distCheckBox").attr("checked", (this.checked ? true : false));
		 addRemoveCustomers();
	});

	$('#TopLevel').change(function(){
	  submitForm();
	});
<cfif vars.qSearchField.recordcount EQ 1 and #form.loaded# EQ 0>
	$( document ).ready(function() {
	$('input[name=loaded]').val( 1 );
	    submitForm();
	});
</cfif>
	function addRemoveCustomers(){

		/* all checked rows are saved in a hidden input with a name of 'FinalItemList' */
		var hiddenCBoxes = $('input[name=FinalItemList]').val().toLowerCase();

		/* convert the list into an array for easy manipulation */
		if (hiddenCBoxes.length == 0)
			var aDistributorList = [];
		else
			var aDistributorList = hiddenCBoxes.split(",");

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
 <cfinclude template="/common_files/jQuery.cfm">
<cfset datatables.version = "1.9.1">
<cfinclude template="/common_files/dataTables.cfm">
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
var oTable = $('table#datagrid').dataTable({
     "bAutoWidth": false
    ,"bPaginate": false
    ,"bSortClasses": false
    ,"bScrollCollapse": true
    ,"sDom": 'fti'
	<cfif TheQuery.recordcount GT 0>
    ,"sScrollY": '400px'
	</cfif>
    ,"aoColumns": [   {"bSortable":false, "bSearchable":false }
                    , {"bSortable":true, "bSearchable":true}
                    , {"bSortable":true, "bSearchable":true}
                   ]
  }).fnSetFilteringDelay();
/* delay dataTable search until there are more than 2 characters */
$('.dataTables_filter input')
	.unbind('keypress keyup')
	.bind('keypress keyup', function(e) {
		if ($(this).val().length < 3 && e.keyCode > 13)
			return;
		oTable.fnFilter($(this).val());
  });

<!--- hovering background color switching --->
$('table#datagrid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

$('#delete_selected').click(function(e) {
	oTable.fnFilter( '', 1 );
 	oTable.fnFilter( '' );   // display hidden rows while saving, only displayed records will be saved
 	$('#save_action').val("delete_selected");
 	$('#data_form').submit();
});

$('#select_operator').click(function(e) {
	$('#save_action').val("select_operator");
	NewWindow("/billbacks/search_screens/PM_select_operators.cfm?Formname=data_form&SelectSingleSearchResultOnly=0", "operatorwindow", 800, 600, "yes", "yes")
});

$('#select_all').change(function(e){      <!---listen for the change event on the toggle--->
 $('.distCheckBox').prop('checked', ( this.checked ) ? true : false );
 e.stopPropagation();
});


function profile(did, d_group_level_id) {
	<cfoutput>
	NewWindow('/profiles/Distributors/Distributor_profile.cfm?'
					+ 'DID=' + did
					+ '&Distributor_Group_Level_ID=' + d_group_level_id
					+ '&Is_Group=#form.Is_Group#'
					+ '&programID=#form.Contract_Main_ID#', 'name', '400', '450', 'Yes', 'No');
	</cfoutput>
	return false;
}
</script>