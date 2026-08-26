<cfoutput>
<!---77408 Product Group sequencing START--->
<cfset ApplicationSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").get(1) />
<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1'>
		<cfset command ="selectMultiLevelView">
<cfelse>
		<cfset command ="selectListView">
</cfif>
<cfparam name="form.command" default ="#command#" />
	<!---77408 Product Group sequencing END--->

<cfparam name="url.formName" default ="" />
<cfparam name="form.formName" default ="#url.formName#" />
<cfparam name="url.SelectSingleSearchResultOnly" default ="0" />
<cfparam name="form.SelectSingleSearchResultOnly" default ="#url.SelectSingleSearchResultOnly#">
<cfparam name="url.programId" default ="0" />
<CFPARAM NAME="form.programId" DEFAULT="#url.programId#">
<cfparam name="url.plannerId" default="0" />
<CFPARAM NAME="form.plannerId" DEFAULT="#url.plannerId#">
<cfparam name="url.lExcludeFormField" default ="" />
<cfparam name="form.lExcludeFormField" default ="#url.lExcludeFormField#">
<cfparam name="form.rebateTypeSelected" default ="">
<cfparam name="form.sub_command" default ="">
<cfparam name="form.Product_List" default ="" />
<cfparam name="form.Product_Group_List" default ="" />
<cfparam name="form.init" default ="0" />
<cfparam name="url.init" default ="0" />
<cfparam name="form.GroupLevel" default ="">
<cfparam name="form.Allow_Multi_Levels" default ="0">
<cfparam name="form.Product_Group_Level_ID" default ="0">
<cfparam name="form.Product_Group_ID" default ="">
<cfparam name="form.Remove_Product_Group_ID" default ="">
<cfparam name="form.Pricing_Level_ID" default ="" />
<cfparam name="form.lExclusion" default ="">
<CFPARAM NAME="form.GroupExclusionList" DEFAULT="">
<CFPARAM NAME="url.Discountype" DEFAULT ="0">
<!--- added for price protection --->
<cfparam name="url.Search_Sequence_ID" default="">
<cfparam name="SearchSequenceId" default="0">
<cfparam name="url.EZTemplate" default="0">
<cfparam name="EZ_ProductList" default="">
<cfparam name="EzButton_Products" default="0">
<cfparam name="url.isparent" default ="0">
<cfparam name="url.component_id" default ="0">
<cfparam name="form.passed_form" default ="">
<cfparam name="form.itemList" default ="">
<cfparam name="form.ProductsGroupLevels" default ="">

<!---77408 Product Group sequencing START--->
<cfparam name="form.GroupDS" default ="">
<cfparam name="form.CurrentLevel" default ="">
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
	<cfparam name="form.GroupLevel_#levels#" default ="">
	<cfparam name="form.Level_#levels#" default ="">
</cfloop>
<cfparam name="url.userSelectedLevel" default="0">
<cfparam name="url.userSelectedprodGroupId" default="0">
<!---77408 Product Group sequencing END--->

<cfif form.passed_form EQ "groupDataForm">
	<cfset form.passed_form = "">
</cfif>

<cfif form.passed_form NEQ "" and form.passed_form NEQ "groupDataForm" and form.itemList NEQ "">
	<cfset form.itemList = #trim(replace(ListQualify(form.itemList, "'", ",", "ALL"), "''", "'", "ALL"))# >
</cfif>
<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm"><!--- 77408 --->

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<cfparam name="form.check" default ="0"><!--- D30271:simplifiy product group search --->
<cfset GroupManager = CreateObject("component", "components.products.Group.GroupManager") />
<cfset GroupDataManager = CreateObject("component", "components.products.Group.DataManager") />
<cfset ProductMessagesComponent = createobject("component", "components.programs.Message")>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset qGetProgramTemplate = templateManager.getProgramTemplate(programId = form.programId) />
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />

<!------ Additional code to handle group of groups (groupCombination) ----->
<cfset searchSequenceManager 			= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
<cfset GroupCombinationManager 			= CreateObject("component", "components.products.group.GroupCombinationManager").init() />
<cfset groupCombinationOn = 0 />
<cfif ApplicationSettingsManager.getSearchSequenceOn()>
<!--- added for price protection - b'cos price protection does not have a program id but still should have the same functionality as regular group pop up--->
<cfif url.Search_Sequence_ID EQ "" and form.ProgramID NEQ 0>
	<cfset SearchSequenceId = searchSequenceManager.getSearchSequenceForProgram(form.ProgramID) />
<cfelseif url.Search_Sequence_ID NEQ "" and form.ProgramID EQ 0>
	<cfset SearchSequenceId = url.Search_Sequence_ID>
</cfif>
	<!------ Get the new group combination for this search sequence ----->
	<cfset qGetSearchSequenceInfo = searchSequenceManager.getSearchSequenceInfo(SearchSequenceId) />
	<cfif isNumeric(qGetSearchSequenceInfo.Group_Combination_Definition_Header_ID)>
		<cfset qGetGroupCombinationDefinitionHeader = GroupCombinationManager.getGroupCombinationDefinitionHeader(qGetSearchSequenceInfo.Group_Combination_Definition_Header_ID) />
		<cfset groupCombinationProductGroupLevelId = qGetGroupCombinationDefinitionHeader.Product_Group_level_ID />
		<cfset groupCombinationDefHeaderId = qGetGroupCombinationDefinitionHeader.Group_Combination_Definition_Header_ID />
		<cfset groupCombinationOn = 1 />
		<!------ Get the group members ----->
		<cfset qGetGroupCombinationDefinitionDetail = GroupCombinationManager.getGroupCombinationDefinitionDetail(groupCombinationDefHeaderId) />
	</cfif>
</cfif>
<cfset RevisionSettingsManager = CreateObject("component", "components.programs.Display_Program.revision_settings") />

<cfset Revision_Settings_Allowed = 0>
<cfif PROGRAMID NEQ "">
	<cfset RevisionSettings = RevisionSettingsManager.getRevisionSettings(templateId = qGetProgramTemplate.ProgramControl_Panel_Options_ID,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = PROGRAMID)>
	<cfset RevisionStatus = RevisionSettingsManager.getRevisionStatus(PROGRAMID)>

	<cfif RevisionSettings.Apply_to_All eq 1 OR (RevisionSettings.Apply_to_All eq 2 AND RevisionStatus.Contract_Reference_Number eq 1)>
		<cfset Revision_Settings_Allowed = 1>
	</cfif>
<cfelse>

	<cfset RevisionStatus = QueryNew("Is_A_Revision, Sent_to_External_Client")>

</cfif>

<cfif Not IsDefined("ProgramManager")>
	<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
</cfif>

<cfif NOT IsDefined("ParentprogramInfo")>
	<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(PROGRAMID)>
</cfif>

<cfif NOT IsDefined("ProgramProducts")>
	<cfset ProgramProducts = CreateObject("component", "components.products.products")/>
</cfif>

<cfset GetSettings = ProgramManager.GetSettings(PROGRAMID)>

<cfset productGroupFilterBusinessSegmentId = 0 />
<cfif businessSegManager.isEnabledForProduct()>
	<cfset oProductBSFilter = businessSegManager.get(GetSettings.Business_Segment_ID) />
	<cfset productGroupFilterBusinessSegmentId = oProductBSFilter.Product_Group_BS_Filter />
</cfif>

<cfset ProductMessages = ProductMessagesComponent.GetMessageSettings(PROGRAMID,Discountype)>

<cfif Revision_Settings_Allowed eq 1  AND RevisionStatus.Is_A_Revision eq 1>
	<cfset ParentprogramInfo = ProgramManager.getParentProgramInfo(PROGRAMID)>
	<cfset getProgramProducts = ProgramProducts.getproducts('',url.discountype,ParentProgramInfo.Revision_of_Contract_main_id)>
</cfif>

<!---
D28783: Release 7 EZ Button Max Rate
Do not filter program product search tool based on ez template when it is set as max rate
--->
<cfif GetSettings.EZButton_On EQ 1 and url.EZTemplate EQ 0 and GetSettings.Discount_Rebate_Max_Rate_On EQ 0>
	<cfset EzButton_Products = 1>
<cfelse>
	<cfset EzButton_Products = 0>
</cfif>

	<cfif EzButton_Products EQ 1>
	<cfset EZButtonProgramProductList = ProgramProducts.getEZButtonProductList(getsettings.EZ_Contract_Id,url.Discountype,url.component_id,url.isparent,1)/>
	<cfset EZ_ProductList = valuelist(EZButtonProgramProductList.BSA_Foodservice_Items_Master_ID)>
	</cfif>

<cfset ProductItemList = "">
<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
	<cfif getProgramProducts.recordcount neq 0>
		<cfif url.Discountype eq 1>
			<cfset ProductItemList = ValueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
		<cfelseif url.Discountype eq 2>
			<cfset ProductItemList = valueList(getProgramProducts.MasterItemID)>
		<cfelseif url.Discountype eq 4>
			<cfset ProductItemList = valueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
		<cfelseif url.Discountype eq 8>
			<cfset ProductItemList = valueList(getProgramProducts.BSA_Foodservice_Items_Master_ID)>
		<cfelseif url.Discountype eq 10>
			<cfset ProductItemList = valueList(getProgramProducts.ItemMasterID)>
		</cfif>
	</cfif>
</cfif>

<!------ DEV NOTE: 9595 DRK : find the allow list based on templates ----->
<cfset arAllowGroupLevel = ArrayNew(1) />
<cfif ApplicationSettingsManager.getSearchSequenceOn() EQ 0>
	<!------ If search seq is off, find the allow group level list from templates, if applicable ----->
	<cfif qGetProgramTemplate.Restrict_Product_Group_Level eq 1>
		<cfset arAllowGroupLevel[ArrayLen(arAllowGroupLevel) + 1] = templateManager.getTemplateAllowProductGroupLevelList(qGetProgramTemplate.ProgramControl_Panel_Options_ID) />
	</cfif>
</cfif>

<!---set whether we should use the product hierarchy display or not--->
<cfset bUseProdHierarchy = ApplicationSettingsManager.getUseProductHierarchy() />

<!---change views based on product hierarchy--->
<cfif bUseProdHierarchy and form.init neq 1>
	<cfset form.command = "selectMultiLevelView" />
</cfif>



<cfif form.init eq 1>

	<cfset request.lLevelList = "1" />
	<!---allow multi level select if it's on--->
	<cfif form.Allow_Multi_Levels eq 1>

	<!---77408 Product Group sequencing START--->
	<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') neq '1'>
		<!---don't allow group levels that have products in them or no groups in the previous level--->
		<cfif form.GroupLevel_2 neq 9 and trim(form.GroupLevel_1) neq "" and trim(form.Level_1) neq "" >
			<cfset request.lLevelList = ListAppend(request.lLevelList, "2") />
		</cfif>

		<!---don't allow group levels that have products in them or no groups in the previous level--->
		<cfif form.GroupLevel_3 neq 9 and form.GroupLevel_2 neq 9
						and form.GroupLevel_1 neq "" and form.GroupLevel_2 neq ""
						and trim(form.Level_1) neq "" and trim(form.Level_2) neq "">
			<cfset request.lLevelList = ListAppend(request.lLevelList, "3") />
		</cfif>

<cfelse>

		<!---don't allow group levels that have products in them or no groups in the previous level--->
		<cfif trim(form.GroupLevel_1) neq "" and trim(form.Level_1) neq "" >
			<cfset request.lLevelList = ListAppend(request.lLevelList, "2") />
		</cfif>

		<!---don't allow group levels that have products in them or no groups in the previous level--->
		<cfif form.GroupLevel_1 neq "" and form.GroupLevel_2 neq ""
						and trim(form.Level_1) neq "" and trim(form.Level_2) neq "">
			<cfset request.lLevelList = ListAppend(request.lLevelList, "3") />
		</cfif>

		<cfif form.GroupLevel_1 neq "" and form.GroupLevel_2 neq ""
						and form.GroupLevel_3 neq "" and trim(form.Level_1) neq ""
						and trim(form.Level_2) neq "" and trim(form.Level_3) neq "">
			<cfset request.lLevelList = ListAppend(request.lLevelList, "4") />
		</cfif>

		<cfif form.GroupLevel_1 neq "" and form.GroupLevel_2 neq ""
						and form.GroupLevel_3 neq "" and form.GroupLevel_4 neq ""
						and trim(form.Level_1) neq "" and trim(form.Level_2) neq ""
						and trim(form.Level_3) neq "" and trim(form.Level_4) neq "">
			<cfset request.lLevelList = ListAppend(request.lLevelList, "5") />
		</cfif>

		<cfif form.GroupLevel_1 neq "" and form.GroupLevel_2 neq ""
					and form.GroupLevel_3 neq "" and form.GroupLevel_4 neq ""
					and form.GroupLevel_5 neq ""and trim(form.Level_1) neq ""
					and trim(form.Level_2) neq "" and trim(form.Level_3) neq ""
					and trim(form.Level_4) neq "" and trim(form.Level_5) neq ""	>
			<cfset request.lLevelList = ListAppend(request.lLevelList, "6") />
		</cfif>

		<cfif form.GroupLevel_7 neq 9 and form.GroupLevel_6 neq 9
						and form.GroupLevel_1 neq "" and form.GroupLevel_2 neq ""
						and form.GroupLevel_3 neq "" and form.GroupLevel_4 neq ""
						and form.GroupLevel_5 neq "" and form.GroupLevel_6 neq ""
						and trim(form.Level_1) neq "" and trim(form.Level_2) neq ""
						and trim(form.Level_3) neq "" and trim(form.Level_4) neq ""
						and trim(form.Level_5) neq "" and trim(form.Level_6) neq "">
			<cfset request.lLevelList = ListAppend(request.lLevelList, "7") />
		</cfif>

		<cfif form.GroupLevel_1 neq "" and form.GroupLevel_2 neq ""
						and form.GroupLevel_3 neq "" and form.GroupLevel_4 neq ""
						and form.GroupLevel_5 neq "" and form.GroupLevel_6 neq ""
						and form.GroupLevel_7 neq ""	and trim(form.Level_1) neq ""
						and trim(form.Level_2) neq "" and trim(form.Level_3) neq ""
						and trim(form.Level_4) neq "" and trim(form.Level_5) neq ""
						and trim(form.Level_6) neq "" and trim(form.Level_7) neq "">
			<cfset request.lLevelList = ListAppend(request.lLevelList, "8") />
		</cfif>
		<cfloop list="	#request.lLevelList#" index="levels">
				<cfset level = trim(levels)>
			<cfif Evaluate("form.GroupLevel_#level#") EQ 9>
				<cfset nextLevel = level + 1>		<!--- NEXT LEVEL --->
				<cfset Form["GroupLevel_#nextLevel#"] =  Form["GroupLevel_#level#"] ><!--- MOVE ITEMS FROM CURRENT LEVEL TO BELOW LEVE --->
				<cfset Form["Level_#nextLevel#"] =  Form["Level_#level#"]>
				<cfset Form["GroupLevel_#level#"] = ''><!--- EMPTY CURRENT LEVEL TO INCLUDE GROUPS --->
				<cfset Form["Level_#level#"] = ''>
				<cfset form.Pricing_Level_ID = level>
				<cfset request.lLevelList = listDeleteAt(request.lLevelList, listLen(request.lLevelList))>
				<cfbreak>
			</cfif>
		</cfloop>
</cfif>
<!---77408 Product Group sequencing END--->
</cfif>
<!---handle for each command--->

	<cfif form.command eq "validate_import"><!------ only applicable for group of groups ----->

		<!------ get the groups which have zero products ----->

		<cfset qGetGroupsWithNoProducts = GroupDataManager.getGroupsWithNoProducts(programId = form.ProgramID,
																																							 groupLevelId = form.GroupLevel_1,
																																							 groupLevelList = form.Level_1,
																																							 FirstParentID = qGetProgramTemplate.First_Parent_ID,
																																							 setGroupTemplateSelectionOn = 1
																																							 ) />
		<cfif qGetGroupsWithNoProducts.recordCount EQ 0><!------ If all groups have product, go ahead ----->
			<cfset form.command = "import" />
		</cfif>

	</cfif>

	<cfif form.command eq "select">

		<cfset objGroupManager = GroupManager.getProductGroups() />

		<!---set the groups object from the group manager--->
		<cfset objTopGroups = objGroupManager.getGroups() />

	<cfelseif form.command eq "selectListView">

<cfset qGetTopLevelGroups = GroupDataManager.getProductGroupsData(arAllowGroupLevel = arAllowGroupLevel,
																																	allowInGroupSearch = 1,
																																	FirstParentID = qGetProgramTemplate.First_Parent_ID , EZTemplate = URL.EZTemplate) />

		<cfset sPricingLevelDesc = GroupDataManager.getPricingLevelDesc(1) />

		<!---if the sub command is get groups and clear level is 1 then clear level_1--->
		<cfif form.sub_command eq "getGroups">

			<cfif form.clearLevel eq 1>
				<cfset form.Level_1 = "" />
			</cfif>

			<cfset form.GroupLevel_1 = form.GroupLevel />

		</cfif>

		<cfset form.Product_List = listRemoveDuplicates(form.Level_1) />

	<cfelseif form.command eq "selectMultiLevelView">
	<!---77408 Product Group sequencing START--->
		<!---clear for a each level if it's set--->
		<cfif ApplicationSettingsManager.get_Setting('Product_Group_Sequencing') eq '1'>
				<cfset listValues = '1,2,3,4,5,6,7,8,9'>
		<cfelse>
				<cfset listValues = '1,2,3'>
		</cfif>
		<cfloop index="tmpIndx" list="#listValues#">

			<cfparam name="form.Clear_Level_#tmpIndx#" default ="" />

			<cfif form["Clear_Level_#tmpIndx#"] eq 1>
				<cfset "form.Level_#tmpIndx#" = "" />
			</cfif>

		</cfloop>
	<!---77408 Product Group sequencing END--->

		<!---if the sub command is add then set the group id's to the proper level buckets--->
		<cfif form.sub_command eq "add">
			<!---- make sure the groups follow the operating group-business segment restrictions --->
			<cfif application.appsettingsget.getOperatingGroupOn() EQ 1>
				<!--- make sure there is atleast one product belonging to this group in the item master which satisfies the operating group-business segment conditions --->
				<cfset OperatingGroupManager = CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
				<cfset programLevel1Level 				= operatingGroupManager.getProgramLevel1Level() />
				<!------ Get the operating group for this program ----->
				<cfset operatingGroupProgramLevel1 	= operatingGroupManager.getProgramOperatingGroupID(level=programLevel1Level, programId=form.programId) />

				<cfset productGroupLevelId = Evaluate("form.GroupLevel_#form.Pricing_Level_ID#") />

				<cfset groupIdListToValidate = Evaluate("form.Level_#form.Pricing_Level_ID#") />
				<cfset groupIdListAfterValidate = OperatingGroupManager.validateProductGroups(
							operatingGroupId=operatingGroupProgramLevel1,
							productGroupLevelId=productGroupLevelId,
							groupIdList=groupIdListToValidate) />
				<cfset "form.Level_#form.Pricing_Level_ID#" = groupIdListAfterValidate />
			</cfif>

			<cfif form.Pricing_Level_ID neq request.AccessStructure.numberOfProductGroupLevels and Len(form["Level_#form.Pricing_Level_ID#"]) GT 0>
				<cfset form.Pricing_Level_ID = form.Pricing_Level_ID + 1 />
			</cfif>

			<cfset form.sub_command = "" />
			<cfset url.userSelectedLevel = 0>
			<cfset url.userSelectedprodGroupId = 0>
		</cfif>

	<cfelseif form.command eq "import">
		<!--- 76386 :: Ability to add [product group] when items already exist
		flush the product list <cfset form.Product_List = "" />
		--->
		<!---initialise Base object for the makeUniqueList() function--->
		<cfset baseObj = CreateObject("component", "components.Base") />
		<!---always make sure that GroupLevel_1 only holds one value--->
		<cfset form.GroupLevel_1 = ListFirst(form.GroupLevel_1) />

		<!---77408 Product Group sequencing START--->
		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">

			<!--- 	CHECK IF ANY LEVEL IS EMPTY AND ADJUST VALUES ACCORDINGLY --->
		<cfif form["Level_#levels#"] eq "" AND form["GroupLevel_#levels#"] eq "">
			<cfset nextLevel = levels + 1>
			<cfif nextLevel LTE request.AccessStructure.numberOfProductGroupLevels>
				<cfset "form.Level_#levels#" = form["Level_#nextLevel#"] />
				<cfset "form.GroupLevel_#levels#" = form["GroupLevel_#nextLevel#"] />
				<cfset form["Level_#nextLevel#"] = "">
				<cfset form["GroupLevel_#nextLevel#"] = "">
			</cfif>
		</cfif>

			<!---ensure that all level buckets are distinct--->
			<cfset "form.Level_#levels#" = baseObj.makeUniqueList(form["Level_#levels#"]) />
			<cfparam name="form.GroupLevel_#levels#" default="">

			<!--- handle the exception senario --->
			<cfif form["GroupLevel_#levels#"] eq "">
				<cfset "form.Level_#levels#" = "" >
			</cfif>

			<!------ clear group levels if levels are empty ----->
			<cfif form["Level_#levels#"] eq "">
				<cfset "form.GroupLevel_#levels#" = "" />
			</cfif>

				<!---loop over each level list and set product list--->
			<cfloop index="lev1Indx" list="#form["Level_#levels#"]#">
				<!---add product group id to product list if it's not in there--->
				<cfif not ListFindNoCase(form.Product_List, lev1Indx)>
				<cfset form.Product_List = ListAppend(form.Product_List, lev1Indx) />
				</cfif>
			</cfloop>
		</cfloop>

	<!---77408 Product Group sequencing END--->
		<script>
			var openerFormObj = opener.document.all.#form.formName#;
						openerFormObj.Product_List.value = '#form.Product_List#';

			if(openerFormObj.ProductsGroupLevels){
				openerFormObj.ProductsGroupLevels.value='#form.ProductsGroupLevels#';
			}

			<!---77408 Product Group sequencing START--->
			<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
					if (openerFormObj.Level_#levels#){
						openerFormObj.Level_#levels#.value = '#form["Level_#levels#"]#';
					}
					if (openerFormObj.GroupLevel_#levels#){
						openerFormObj.GroupLevel_#levels#.value = '#form["GroupLevel_#levels#"]#';
					}
			</cfloop>
		 <!---77408 Product Group sequencing END--->

			openerFormObj.action.value = 'addProductGroups';
			openerFormObj.submit();
			window.close();
		</script>

	</cfif>
	<cfloop index="levlIndx" list="#request.lLevelList#">
		<cfparam name="form.GroupLevelSelect_#levlIndx#" default="" />
		<cfparam name="form.Level_#levlIndx#" default="" />
		<cfparam name="form.Parent_Product_Hierarchy_ID_#levlIndx#" default="" />

		<cfif ListFindNoCase("selectListView,selectMultiLevelView", form.command)>
			<cfset currentParentHierarchyId = "" />
			<cfset currentProdGroupId = "" />
			<cfif form.command EQ "selectListView">
				<cfset currentGroupLevel = form.GroupLevel_1 />
				<cfset currentExclusion = form.lExclusion />
				<cfif form.sub_command NEQ "getGroups"><!------ if not searching for others, show what is already selected ----->
					<cfset currentProdGroupId = form.Level_1 />
				</cfif>
			<cfelseif form.command EQ "selectMultiLevelView">
					<cfset currentGroupLevel = Evaluate("form.GroupLevelSelect_#levlIndx#") />
					<cfset currentExclusion = form.lExclusion />
					<cfset currentParentHierarchyId = Evaluate("form.Parent_Product_Hierarchy_ID_#levlIndx#") />
			</cfif>

			<!---get all selected groups--->
			<cfif trim(currentGroupLevel) eq "">
				<cfset qGetGroups = GroupDataManager.getByProductGroupData(0) />
			<cfelse>
				<!---get all the groups for this category--->
				<cfset qGetGroups = GroupDataManager.getByProductGroupData
                            (
                              prodGroupLevelId = currentGroupLevel,
                              prodGroupId = '',
                              programId = form.programId,
                              lExcludeProdGroup = currentExclusion,
                              FirstParentID  = qGetProgramTemplate.First_Parent_ID,
							  setGroupTemplateSelectionOn = 1,
                              businessSegmentId = productGroupFilterBusinessSegmentId,
							  IncludeActiveOnly = 1,
							  EZTemplate = URL.EZTemplate,
                                plannerId = form.plannerId
                            ) />
        <!---
        <cfargument name="prodGroupLevelId" required="false" default="" />
		<cfargument name="prodGroupId" required="false" default="" />
		<cfargument name="programId" required="false" default="0" />
		<cfargument name="lExcludeProdGroup" required="false" default="" />
        --->
				<!------ Build the member group filter array ----->
				<cfset arGroupMembers = ArrayNew(1) />
				<cfif groupCombinationOn>
				<cfloop query="qGetGroupCombinationDefinitionDetail">
					<cfparam name="FORM.Group_Combination_Member_#Product_Group_Level_Type#" 	default="">
					<cfset thisGroupId = Evaluate("FORM.Group_Combination_Member_#Product_Group_Level_Type#") />
					<cfif thisGroupId NEQ "" AND thisGroupId NEQ "0">
						<cfset stGroupMember = StructNew() />
						<cfset stGroupMember.groupLevelId = Member_Group_Level_ID />
						<cfset stGroupMember.groupId = thisGroupId />
						<cfset ArrayAppend(arGroupMembers, stGroupMember) />
					</cfif>
				</cfloop>
				</cfif>

				<!---get all the groups for this category--->
				<cfset qGetGroups = GroupDataManager.getByProductGroupData(
								prodGroupLevelId = currentGroupLevel,
								prodGroupId = currentProdGroupId,
								programId = form.programId,
								lExcludeProdGroup = currentExclusion,
								parentHierarchyId = currentParentHierarchyId,
								addParentName = 2,
								arGroupMembers = arGroupMembers,
								OnlyEZProducts = EZ_ProductList,
								EZbutton_On	   = EzButton_Products,
								suppressGroups = application.appsettingsget.getSuppressGroupsZeroItems(),
								FirstParentID  = qGetProgramTemplate.First_Parent_ID,
								setGroupTemplateSelectionOn = 1,
								businessSegmentId = productGroupFilterBusinessSegmentId,
								IncludeActiveOnly = 1,
								EZTemplate = URL.EZTemplate,
                                plannerId = form.plannerId
                ) />
			<cfif Revision_Settings_Allowed eq 1  AND RevisionStatus.Is_A_Revision eq 1>
				<cfset qGetParentProgramGroups = GroupDataManager.getByProductGroupData(
							prodGroupLevelId = currentGroupLevel,
							prodGroupId = ProductItemList,
							programId = ParentProgramInfo.Revision_of_Contract_main_id,
							lExcludeProdGroup = currentExclusion,
							parentHierarchyId = currentParentHierarchyId,
							addParentName = 2,
							arGroupMembers = arGroupMembers,
							OnlyEZProducts = EZ_ProductList,
							EZbutton_On	   = EzButton_Products,
							suppressGroups = application.appsettingsget.getSuppressGroupsZeroItems(),
              				FirstParentID  = qGetProgramTemplate.First_Parent_ID,
							setGroupTemplateSelectionOn = 1,
							IncludeActiveOnly = 1,
							EZTemplate = URL.EZTemplate,
                            plannerId = form.plannerId
              ) />
			</cfif>

			</cfif>
			<cfif form.command EQ "selectMultiLevelView">
				<cfset "qGetGroups_#levlIndx#" = qGetGroups />
			 <cfif Revision_Settings_Allowed eq 1  AND RevisionStatus.Is_A_Revision eq 1 and isDefined("qGetParentProgramGroups")>
				<cfset "qGetParentProgramGroups_#levlIndx#" = qGetParentProgramGroups />
			 </cfif>
			</cfif>
		</cfif>

	</cfloop>

</cfif>

<html lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>Product Group Select</title>
<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
<link rel="stylesheet" type="text/css" href="/common_files/main_style.css">
<style>
.tool { position:relative; left:35px; font-size:9pt; font-weight:bold; color:navy; }
.mid { text-align:center; }
</style>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cf_include files='groups.js,/Script/javascript/string_functions.js'>
</head>

<body>
<form action="" method="post" name="groupDataForm" id="groupDataForm">

<cfif NOT ListFindNoCase("validate_import", form.command)>
<font color="##000066" size="4">Select Product Groups</font>
<hr color="navy">
</cfif>

<cfif form.init eq 1>

	<cfheader name="Cache-Control" value="no-store">
	<cfheader name="expires" value="-100">
	<cfset Cache_Control_Header_Already_Added = 1>
	<CFINCLUDE template="/includes/call_please_wait.cfm">
	<cfswitch expression="#form.command#">

		<cfcase value="select">
			<cfinclude template="select_product_group.cfm" />
		</cfcase>

		<cfcase value="selectListView_old">
			<cfinclude template="select_list_view.cfm" />
		</cfcase>

		<cfcase value="selectListView">
			<cfinclude template="select_list_view_jquery.cfm" />
		</cfcase>

		<cfcase value="selectMultiLevelView">
			<cfinclude template="select_multi_level_view.cfm" />
		</cfcase>

		<cfcase value="validate_import"><!------ only applicable for group of groups ----->
			<cfinclude template="display_group_no_products.cfm" />
		</cfcase>

	</cfswitch>

<cfelse>
	<font size="+1" color="##FF0000">Loading...</font>
</cfif>

<!---77408 Product Group sequencing START--->
<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
	<input type="hidden" name="Level_#levels#" id="Level_#levels#_Hidden" value="#Evaluate("form.Level_#levels#")#" />
	<input type="hidden" name="GroupLevel_#levels#" value="#Evaluate("form.GroupLevel_#levels#")#" />
	<input type="hidden" name="RemoveFromLevel_#levels#" value="" id="RemoveFromLevel_#levels#"/>
</cfloop>
<!---77408 Product Group sequencing END--->

<input type="hidden" name="init" value="1" />
<input type="hidden" name="formName" value="#form.formName#" />
<input type="hidden" name="Product_Group_List" value="#form.Product_Group_List#" />
<input type="hidden" name="Product_List" value="#form.Product_List#" />
<input type="hidden" name="command" value="#form.command#" />
<input type="hidden" name="sub_command" value="#form.sub_command#" />
<input type="hidden" name="Allow_Multi_Levels" value="#Form.Allow_Multi_Levels#" />
<input type="hidden" name="SelectSingleSearchResultOnly" value="#Form.SelectSingleSearchResultOnly#" />
<input type="hidden" name="programId" value="#form.programId#" />
<input type="hidden" name="plannerId" value="#form.plannerId#" />
<input type="hidden" name="lExclusion" value="#form.lExclusion#" />
<input type="hidden" name="clearLevel" value="0" />
<input type="hidden" name="Pricing_Level_ID" value="#form.Pricing_Level_ID#" />
<input type="hidden" name="GroupExclusionList" value="#form.GroupExclusionList#" />
<input type="hidden" name="check" value="#form.check#" id="check"/><!--- D30271:simplifiy product group search --->
<input type="hidden" name="passed_form" 						value="#form.passed_form#">
<input type="hidden" name="itemList" value="#form.itemList#">
<input type="hidden" name="ProductsGroupLevels" value="#form.ProductsGroupLevels#"><br>
<input type="hidden" name="numberOfLevels" value="#request.AccessStructure.numberOfProductGroupLevels#">
<input type="hidden" name="GroupDS" value="#form.GroupDS#">
<input type="hidden" name="CurrentLevel" value="#form.CurrentLevel#">
</form>

<!---if init is not eq to 1 then we know this page hasn't been loaded yet so do initialization--->
<cfif form.init neq 1>

	<script>
		var openerFormObj = opener.document.all.#form.formName#;
		var thisForm = document.all.groupDataForm;
		thisForm.Product_List.value = openerFormObj.Product_List.value;

		if(openerFormObj.ProductsGroupLevels){
			thisForm.ProductsGroupLevels.value = openerFormObj.ProductsGroupLevels.value;
		}
		//thisForm.GroupExclusionList.value = openerFormObj.GroupExclusionList.value;
		if (openerFormObj.GroupExclusionList){
			thisForm.GroupExclusionList.value = openerFormObj.GroupExclusionList.value;
		}

		<!---77408 Product Group sequencing END--->
		<cfloop from="1" to="#request.AccessStructure.numberOfProductGroupLevels#" index="levels">
			if (openerFormObj.Level_#levels#){
				thisForm.Level_#levels#.value = openerFormObj.Level_#levels#.value;
				thisForm.GroupLevel_#levels#.value = openerFormObj.GroupLevel_#levels#.value;
			}
		</cfloop>
		<!---77408 Product Group sequencing END--->

		if (openerFormObj.Allow_Multi_Levels){
			thisForm.Allow_Multi_Levels.value = openerFormObj.Allow_Multi_Levels.value;
		}
		//if a value for exclude form field was passed then grab it
		<cfif trim(form.lExcludeFormField) neq "">
			if (openerFormObj.#form.lExcludeFormField#){
				thisForm.lExclusion.value = openerFormObj.#form.lExcludeFormField#.value;
			}
		</cfif>
		thisForm.submit();
	</script>

</cfif>

</body>
</html>
</cfoutput>
