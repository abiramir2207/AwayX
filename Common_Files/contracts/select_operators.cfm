<cfsilent>
<CFPARAM NAME="URL.CID" DEFAULT="">
<CFPARAM NAME="varTotRows" DEFAULT="0">

<CFPARAM NAME="SelectSingleSearchResultOnly" default="0">
<CFPARAM NAME="form.Contract_Main_ID" DEFAULT="">
<cfparam name="form.Operator_Search_Name" default="">

<cfset cacheSpan = APPLICATION.masterDataCacheSpan>

<cfset Header_Display_List = "">
<cfset Header_Value_List = "">
<cfset Headers_from_Query = "" />
<cfset Headers_from_Query_dummy = "" />
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<!---72360 :: Add customer label for BSA ID START --->
<cfset CustomerSettingsLabels = createObject("component", "mvc.Models.SettingsService").getCustomerSettingsLabels() />
<!---72360 :: Add customer label for BSA ID END --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
</cfsilent>
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

		<!--- D50074 :: Viewing and Editing prior program versions START --->
		<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(GetContractInfo.Contract_Main_ID,Get_Profile_Settings.Modify_Expired_Programs) />
		<!--- D50074 :: Viewing and Editing prior program versions END --->
		<!--- Do not show the tabs if the contract is approved --->
	<CFIF GetContractInfo.Contract_Status_Type_IDX GT 2 AND ModifyDeletedPrograms EQ 0><!--- D50074 :: Viewing and Editing prior program versions --->
		<script>
			history.back();
		</script>

		<CFABORT>
	</CFIF>
</CFIF>

<CFSET PAGE_TITLE="Select Program #application.returned_customer_setting.operator_label_plural#">
<CFSET GROUP="Contracts">



<CFSET FORM.Contract_Main_ID = cryp.value>

<CFPARAM name="FORM.button_caption"					DEFAULT="continue">
<CFPARAM NAME="FORM.searchstring" 					DEFAULT="">
<CFPARAM NAME="FORM.SelectedITEMS" 				DEFAULT="">
<CFPARAM NAME="FORM.FinalItemList" 					DEFAULT="">
<CFPARAM NAME="FORM.AlreadySelectedItems" 			DEFAULT="">
<CFPARAM NAME="FORM.finishedselectingitems" 			DEFAULT="0">
<CFPARAM NAME="FORM.LoadSavedOperators"				Default="1">

<CFPARAM NAME="FORM.OPERATOR_NAME" 				DEFAULT="">
<CFPARAM NAME="FORM.OPERATOR_DBA" 				DEFAULT="">
<CFPARAM NAME="FORM.OPERATOR_CITY" 				DEFAULT="">
<CFPARAM NAME="FORM.Operator_Type" 				DEFAULT="">
<CFPARAM NAME="FORM.Operator_Location_Type" 			DEFAULT="">
<CFPARAM NAME="FORM.Operator_State" 				DEFAULT="">
<CFPARAM NAME="FORM.Operator_Country_Code" 			DEFAULT="0">
<cfparam name="FORM.Operator_Number_Of_Locations" 		DEFAULT="">
<cfparam name="FORM.Number_Locations_Operation" 		DEFAULT="">
<cfparam name="FORM.Customer_Type"					DEFAULT="">
<cfparam name="FORM.Operator_Category" 				DEFAULT="">
<cfparam name="FORM.Operator_Priority" 				DEFAULT="">
<cfparam name="FORM.Market_ID" 						DEFAULT="">
<cfparam name="FORM.Position_ID" 					DEFAULT="">
<cfparam name="form.LOADPRODUCTSFROMTHESEPROGRAMS" 	DEFAULT="">
<cfparam name="Form.legacy_id" 						DEFAULT="">
<cfparam name="Form.BSA_Operator_id" 					DEFAULT="">
<cfparam name="donotallowaddoperatorsDE" 				DEFAULT="0">
<cfparam name="form.deletedateexclusions" 				DEFAULT="0">
<cfparam name="FORM.PGCode" Default="" />
<cfparam name="form.Operator_Status" 				DEFAULT="A">    <!---26199--->

<!---default params for business segments--->
<CFPARAM name="FORM.Business_Segment_ID" default="0">
<CFPARAM name="form.businessSegmentsOn" default="0">
<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment START --->
<cfparam name="busSegIdForProgram" default="0">
<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  END --->
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabledForOperator()><!---D50739  --->
	<cfset form.businessSegmentsOn = 1 />
	<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(FORM.Contract_Main_ID) />
	<cfset form.Business_Segment_Id = trim(busSegIdForProgram) />
	<!---get the description to display--->
	<cfset qGetThisBusSegment = businessSegManager.get(busSegIdForProgram) />
	<cfset Bus_Segment_Desc = qGetThisBusSegment.Business_Unit_Desc />
</cfif>
<cfset LegacyIdOn = application.returned_customer_setting.operator_legacy_id_on>
<cfif form.businessSegmentsOn eq 1 and isDefined("FORM.BUSINESS_SEGMENT_ID")>
	<cfset OperatorBSFilter = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager").get(FORM.Business_Segment_Id) />
	<CFSET FORM.BUSINESS_SEGMENT_ID = OperatorBSFilter.Operator_BS_Filter>
	<!---<cfset LegacyIdOn =  OperatorBSFilter.LegacyIdOn> ---> <!--- removed with 28231 --->
</cfif>



  <!--- Dev Note: Drachala; D27266: Operator variable labeling START--->
  <cfset LabelComp 			    = Createobject("component", "components.settings.labels.labels").init() />
  <cfset qGetOperatorTypeLabel 	  = LabelComp.getGeneralLabels('Operator Type') />
  <cfset qGetLocationTypeLabel 	= LabelComp.getGeneralLabels('Location Type') />
  <cfset qGetOperatorCategoryLabel 	= LabelComp.getGeneralLabels('Operator Category') />
  <cfset qGetOperatorPriorityLabel 	= LabelComp.getGeneralLabels('Operator Priority') />
  <!--- Dev Note: Drachala; D27266: Operator variable labeling END--->
  <cfset OprSearchResultsColumnsDisplayAdditionalSettings = LabelComp.getOperatorStaticSearchFieldsDisplayStatus() />

<!---If Customer type is turned on in application settings--->

<CFPARAM NAME="StartRow" DEFAULT="1">
<CFPARAM NAME="frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=25>

<cfif not StructKeyExists(form, "Is_group")>
	<cfinvoke component="components.programs.operators.OperatorManager"
						method="getOperatorGroupInfo"
						programID="#FORM.Contract_Main_ID#"
						returnvariable="query.OperatorGroupInfo" 			>
	<cfset form.Is_Group = query.OperatorGroupInfo.Specify_Operator_Groups>
</cfif>

<cfinclude template="/get_access_profile.cfm">

<!------ all restrictions are based on responsible user ----->
<cfset userManager = CreateObject("component", "components.user.UserManager") />
<cfset qUser = userManager.getUser(GetContractInfo.Responsible_User_Id) />
<cfset rspProfileID = qUser.profiles_id>
<cfset Get_CustType_Profile_Settings = profile.getCusttypeProfileSettings(rspProfileID, 'O')>

<!--- ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
			D31561 - April 2012
			Operators search fields       = template search fields  +  settings labels additional fields
			Operator groups search fields = template group search fields (only)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<cfset useLakebaseForGetTemplateInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForGetTemplateInfo>
	<cftry>
		<cfset GetTemplateInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#GetContractInfo.ProgramType_ID#",
				"select" = "first_parent_id"
			}), "first_parent_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTemplateInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTemplateInfo>
<cfquery name="GetTemplateInfo" datasource="#application.datasource#">
  SELECT First_parent_ID
    FROM Program_Control_Panel_Options
   WHERE ProgramControl_Panel_Options_ID =  #GetContractInfo.ProgramType_ID#
</cfquery>
</cfif>

<!---Gather operator search fields defined in program template --->
<cfset DataManager = CreateObject("component", "components.operator.Group.DataManager").init() />
<cfset vars.AllTemplateFields = DataManager.getOperatorLevelsGroupTemplate( bActive=1, templateID=GetTemplateInfo.First_Parent_ID )>

<!---include only fields that are searchable--->
<cfquery name="vars.TemplateSearchFields" dbtype="query">
	SELECT DISTINCT Field_Name
	       ,Operator_Group_Level_Id
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
	<cfset vars.sCriteria = "GSearch">
	<!---do not include additional fields from settings labels for operator groups search --->
	<cfset vars.qSearchField = vars.TemplateSearchFields>
<cfelse>
	<cfset vars.sCriteria = "FSearch">
	<cfinvoke component="components.settings.Labels.Labels"
						method="getOperatorsStaticSearchFieldsActive"
						returnvariable="vars.AdditionalFields" 			>
	<!---combine template fields and operator attribute labels additional fields--->
	<cfquery name="vars.qSearchField" dbtype="query">
		SELECT *
		  FROM vars.TemplateSearchFields
		 UNION
		SELECT Field_Name
		       ,Operator_Group_Level_Id
		       ,List_Order
		       ,Is_PG
		  FROM vars.AdditionalFields
		ORDER BY List_Order
	</cfquery>
</cfif>

<!--- Get all the types that can be shown as a drop down --->
<cfset qGetTopLevelGroups = DataManager.getOperatorLevels(bActive = 1, allowList= "", disAllowList="",sCriteria=vars.sCriteria, FirstTemplateID=GetTemplateInfo.First_parent_ID) />

<CFIF FORM.LoadSavedOperators EQ 1>
	<cfquery name="CheckForExistingOperators" datasource="#application.datasource#">
		SELECT Operator_Group_ID, BSA_Operator_ID
		FROM Contract_Operators
		WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
		AND Deleted = 0
					<cfif form.Is_Group>
						AND Is_group = 1
					</cfif>
	</cfquery>
	<CFSET FORM.button_caption = "save">
	<cfif form.Is_Group>
		<CFSET FORM.FinalItemList = valuelist(CheckForExistingOperators.Operator_Group_ID)>
	<cfelse>
		<CFSET FORM.FinalItemList = valuelist(CheckForExistingOperators.BSA_Operator_ID)>
	</cfif>
</CFIF>

<CFSET listofitemstodelete = "">

<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedItems#" DELIMITERS=",">
	<CFIF listfind(FORM.SelectedITEMS, ListItem, ",") EQ 0>
		<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFLOOP INDEX="ListItem" LIST="#FORM.SelectedITEMS#" DELIMITERS=",">
	<CFIF listfind(Form.FinalItemList, ListItem, ",") EQ 0>
		<CFSET Form.FinalItemList = listappend(FinalItemList, ListItem, ",")>
	</CFIF>
</CFLOOP>

<CFIF SelectSingleSearchResultOnly EQ 0>
	<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
		<CFIF listfind(FORM.FinalItemList,ListItem, ",") GT 0>
			<CFSET Form.FinalItemList = listdeleteat(FORM.FinalItemList, listfind(FORM.FinalItemList,ListItem, ","), ",")>
		</CFIF>
	</CFLOOP>
<CFELSE>
	<cfif len(trim(FORM.SelectedITEMS)) GT 0>
		<CFSET Form.FinalItemList = FORM.SelectedITEMS>
	</cfif>
</CFIF>


<CFIF FORM.finishedselectingitems EQ 1>

	<!--- lock checker --->
	<CFSET LockChecker_CID  = FORM.Contract_Main_ID>
	<CFINCLUDE TEMPLATE="LockChecker.cfm">
	<!--- lock checker --->

	<cfquery name="CheckForExistingOperators" datasource="#application.datasource#">
		SELECT 	*
		FROM Contract_Operators
		WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#' AND Deleted = 0
		<CFIF listlen(FORM.FinalItemList) GT 0>
			<cfif not form.Is_Group>
				AND BSA_Operator_ID NOT IN(#replace(listqualify(FORM.FinalItemList, "'", ","), '"', "'", "ALL")#)
			</cfif>
		</CFIF>
	</cfquery>
	<cfif form.deletedateexclusions EQ 1>
	<CFQUERY NAME = "Date_exclusion_settings" datasource="#Application.Datasource#">
			SELECT
			Date_Exclusions_ON
			FROM
			 Contract_Main
			 INNER JOIN Program_Control_Panel_Options
			 ON
			 Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			WHERE Contract_Main.Contract_Main_ID =  #Form.Contract_Main_ID#
		</CFQUERY>
	<cfif Date_exclusion_settings.Date_Exclusions_ON EQ 1>
			<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
			<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(Form.Contract_Main_ID,0)>
		<cfif form.deletedateexclusions EQ 1>
			<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update contract_main
				set deleted = 1
				where contract_main_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			<cfquery name="deletedateexclusions" datasource="#application.datasource#">
				update program_exclusions
				set deleted = 1
				where revision_program_id in (#valuelist(getDateExclusionprogramIDs.revision_program_id)#)
			</cfquery>
			</CFIF>
		</cfif>
		</cfif>
</cfif>
	<cfset useLakebaseFordeletedCurrentOperators = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_operators")>
<cfif useLakebaseFordeletedCurrentOperators>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_operators",
			{
				"contract_main_id" = "eq.#Form.Contract_Main_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeletedCurrentOperators = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeletedCurrentOperators>
<CFQUERY NAME="deletedCurrentOperators" datasource="#application.datasource#">
		UPDATE Contract_Operators
		SET Deleted = 1
		WHERE Contract_Main_ID = '#Form.Contract_Main_ID#'
	</CFQUERY>
</cfif>

	<!---make sure the list of operators is distinct--->
	<cfset operatorStruct = structNew() />
	<cfloop index="operator_indx" list="#trim(FORM.FinalItemList)#">
		<cfset structInsert(operatorStruct, operator_indx, "", "true") />
	</cfloop>
	<cfset FORM.FinalItemList = StructKeyList(operatorStruct) />

	<!---remove any operators if remove all selected operators was selected--->
	<cfif form.removeOperators>
		<cfparam name="FORM.SelectedITEMS" default="" />
		<cfloop index="remove_indx" list="#trim(FORM.SelectedITEMS)#">
			<cfset FORM.FinalItemList = ListDeleteAt(FORM.FinalItemList, ListFindNoCase(FORM.FinalItemList, remove_indx)) />
		</cfloop>
	</cfif>

	<CFLOOP INDEX="ListOperator_ID" LIST="#trim(FORM.FinalItemList)#" DELIMITERS=",">
		<cfquery name="SaveOperator" datasource="#application.datasource#">
			<cfif form.Is_Group>
				INSERT INTO Contract_operators
				            ( Operator_Group_ID
				              ,Is_Group
				              ,bsa_operator_id
				              ,contract_main_id
							)
				     VALUES ( '#ListOperator_ID#'
				              ,1
				              ,0
				              ,'#FORM.Contract_Main_ID#'
							)
			<cfelse>
				INSERT INTO Contract_operators
				            ( bsa_operator_id
				              ,contract_main_id
							)
				     VALUES ( '#ListOperator_ID#'
				              ,'#FORM.Contract_Main_ID#'
						)
			</cfif>
		</cfquery>
	</CFLOOP>

	<cfif form.Is_Group>
		<cfstoredproc procedure="CAPTURE_OPERATOR_GROUPS" datasource="#application.datasource#">
			<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#FORM.Contract_Main_ID#" null="no">
		</cfstoredproc>
	</cfif>

				<CFIF CheckForExistingOperators.Recordcount EQ 0>
						<!--- REDIRECTOR --->
						<cfset useLakebaseForgetContractProgramID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForgetContractProgramID>
	<cftry>
		<cfset getContractProgramID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Form.Contract_Main_ID#",
				"select" = "programtype_id"
			}), "programtype_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetContractProgramID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetContractProgramID>
<cfquery name="getContractProgramID" datasource="#application.datasource#">
								SELECT ProgramType_ID
								FROM Contract_Main
								WHERE COntract_Main_ID = '#Form.Contract_Main_ID#'
						</cfquery>
</cfif>
							<CFSET redirector_Program_ID = getContractProgramID.ProgramType_ID>
							<CFSET redirector_FromPage_ID = 2>
						<cfinclude template="internal_redirector_based_on_settings.cfm">
						<CFLOCATION url="redirect.cfm?destination=#redirector_NextLocation#&CID=#URL.CID#">
				<CFELSE>
								<cflocation url="Contract_Edit_Menu.cfm?CID=#URL.CID#">
				</CFIF>


</CFIF>


<!--- <cfset LegacyIdOn = form.businessSegmentsOn eq 1 and isDefined("FORM.BUSINESS_SEGMENT_ID") and (FORM.BUSINESS_SEGMENT_ID EQ 2 OR FORM.BUSINESS_SEGMENT_ID EQ 4) and application.returned_customer_setting.customer_keyword IS "conagra" /> --->
<cfset restrictBusinessSegmentId = 0>
<cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") and application.returned_customer_setting.customer_keyword IS "conagra">
	<cfset restrictBusinessSegmentId = FORM.BUSINESS_SEGMENT_ID>
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<cfinclude template="/Common_Files/jQuery.cfm">
	<!--- Please Wait Indicator --->
	<cfinclude template="/Common_Files/noty.cfm">
	<!--- �Please Wait Indicator --->

	<SCRIPT>
		function showOperatorSearchWindow()
		{
			<cfoutput>
				var params	= "Formname=MyForm&programID=#FORM.Contract_Main_ID#&businessSegmentsOn=#FORM.businessSegmentsOn#&Business_Segment_Id=#FORM.Business_Segment_Id#";
				params		= params+"&preSelected=#FORM.FinalItemList#";
			</cfoutput>
				var sURL = "/Flex/search/OperatorSearchFx.cfm?"+params ;
				NewWindowTopLeft(sURL, "operatorSearchWindow", 900, 720, "yes", "yes");
		}

		function createOperator()
		{//-D50739
			NewWindowTopLeft("/profiles/operators/Operator_Creation_Entry_Form_Stripped.cfm?businessSegementId=<cfoutput>#restrictBusinessSegmentId#&ProgramBusinessSegmentID=#FORM.BUSINESS_SEGMENT_ID#&FinalItemList=#FinalItemList#&CID=#CID#</cfoutput>","CreateOperator",660,650,"yes","yes");
		}

		function editOperator(BSA_Operator_ID)
		{
			NewWindowTopLeft("/profiles/operators/operator_creation_entry_form_stripped.cfm?OID=" + BSA_Operator_ID + "&Action=Edit&CID=<cfoutput>#CID#</cfoutput>","EditOperator",660,650,"yes","yes");
		}

		function doSearch()
		{
			processingPopUpDisplay('div.customContainer');
			document.all.startrow.value = 1;
			document.all.frompage.value = 1;
			restricted_Operator_Search();
			//showstartingWith('');
		}

		function restricted_Operator_Search()
		{
			var searchForm = document.MyForm;
			searchForm.startrow.value = 1;
			searchForm.frompage.value = 1;
			//searchForm.submit();
			check_Filters(searchForm);
		}
		function check_Filters(searchForm)
		{
			if(document.all.LoadProductsFromThesePrograms.value.length != 0) {
				searchForm.submit();
				return;
		}

		var any_Filter = false;
		var availOptions = "";
		if (searchForm.Operator_Type)
		{
			if(searchForm.Operator_Type.value.toUpperCase() != "ALL")
			{
				any_Filter = true;
			}
			availOptions = availOptions + "\n - Type of <CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT>";
		}
		if(searchForm.Operator_Location_Type)
		{
			if(searchForm.Operator_Location_Type.value.toUpperCase() != "ALL")
			{
				any_Filter = true;
			}
			availOptions = availOptions + "\n - Location Type";
		}
		if(searchForm.Operator_State)
		{
			if(searchForm.Operator_State.value.toUpperCase() != "ALL")
			{
				any_Filter = true;
			}
			availOptions = availOptions + "\n - Country";
		}
		if(searchForm.Operator_Country_Code)
		{
			if(searchForm.Operator_Country_Code.value != "0")
			{
				any_Filter = true;
			}
			availOptions = availOptions + "\n - State";
		}
		<cfif LegacyIdOn>
		if(searchForm.legacy_id)
		{
			if(searchForm.legacy_id.value != "")
			{
				any_Filter = true;
			}
			availOptions = availOptions + "\n - Legacy Id";
		}
		</cfif>
		if(searchForm.BSA_Operator_id)
		{
			if(searchForm.BSA_Operator_id.value != "")
			{
				any_Filter = true;
			}
		}
		availOptions = availOptions + "\n - BSA Operator Id";

		<cfif application.operatorVariableAvailable>
		if(searchForm.Market_ID)
		{
			if(searchForm.Market_ID.value != "")
			{
				any_Filter = true;
			}
		}
		availOptions = availOptions + "\n - Market";
		if(searchForm.Position_ID)
		{
			if(searchForm.Position_ID.value != "")
			{
				any_Filter = true;
			}
		}
		availOptions = availOptions + "\n - Position";
		if(searchForm.Operator_Category)
		{
			if(searchForm.Operator_Category.value.toUpperCase() != "ALL")
			{
				any_Filter = true;
			}
		}
		availOptions = availOptions + "\n - Category";
		if(searchForm.Operator_Priority)
		{
			if(searchForm.Operator_Priority.value.toUpperCase() != "ALL")
			{
				any_Filter = true;
			}
		}
		availOptions = availOptions + "\n - Priority";

		</cfif>
		//bypass the confirm message
		any_Filter = true;
		if(any_Filter)
		{
			searchForm.submit();
		}
		else
		{
			<cfif appSettings.getOperatorSearchRestrict()>
			alert("You have to select atleast one of the following filters" + availOptions);
			<cfelse>
			if(window.confirm("Your search may take some time as you have not selected any of the following filters. Do you want to continue?" + availOptions))
			{
				searchForm.submit();
			}
			</cfif>
		}
	}

	function importSelectedOperators(){
		processingPopUpDisplay('div.customContainer');
		document.all.finishedselectingitems.value = 1;
		MyForm.submit();
	}

	</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" <cfif appSettings.getFlexOperatorSearch() eq 0 and not form.is_group> onLoad="document.all.Operator_Name.focus();" </cfif>>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
<style>
TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header
{
	font-size: 12px;
}
#OperatorFilters tr {
	vertical-align: bottom;
}
</style>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET CSL_Contract_Main_ID = FORM.Contract_Main_ID>
<CFSET CSL_CallingPageCode = "op">


<cfif application.programlayout EQ 1>
				<div id="Layer2" style="position:absolute; width: 130px; height: 400px; z-index: 5; left: 10px; top: 0px">
						<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
				</div>
		<cfelse>
						<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
		</cfif>




<CFINCLUDE TEMPLATE="commonqueries.cfm">
<!--- Add the Revision Settings Component --->
<cfset revisionsettingsmanager = createobject("component", "components.programs.display_program.revision_settings") />
<cfset revisionsettings = revisionsettingsmanager.getrevisionsettings(templateid = getsettings.programcontrol_panel_options_id,profilesID = request.AccessStructure.Profiles_ID, ContractMainID = csl_contract_main_id)>
<cfset biscontractarevision = 0 />

		<cfif url.cid neq "">
			<cf_cryp type="de" string="#url.cid#" key="#request.key#">
			<cfset revisionstatus = revisionsettingsmanager.getrevisionstatus(cryp.value)>
			<cfif len(trim(csl_contract_main_id))>
				<cfset biscontractarevision = createobject("component", "components.programs.program").isarevision(#csl_contract_main_id#) />
			</cfif>
			<cfif revisionsettings.apply_to_all eq 1 or (revisionsettings.apply_to_all eq 2 and revisionstatus.contract_reference_number neq "")>
				<cfset revision_settings_allowed = 1>
			</cfif>
		<cfelse>
			<cfset revisionstatus = querynew("is_a_revision, contract_reference_number, client_sent")>
		</cfif>

<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"> </script>
<SCRIPT SRC="/Common_Files/Delete_Functions.js"></SCRIPT>

 <!---If the template says you can only select one operator, check it here--->

<cfif GetSettings.One_Operator IS 1>
	<cfset SelectSingleSearchResultOnly = 1>
</cfif>

<cfif GetSettings.Date_Exclusions_ON EQ 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
<CFIF getDateExclusionprogramIDs.Recordcount gt 0>
	<cfset donotallowaddoperatorsDE = 1>
</CFIF>
</cfif>

<!---Allow import all or not--->
<CFPARAM NAME="FORM.AllowImportAll"	Default="#NOT SelectSingleSearchResultOnly#">

<BLOCKQUOTE><BLOCKQUOTE>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This is help file that goes with this content													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; width:200px; z-index:1; left:80px; top: 10px; height:430px;">
</cfif>
<CFSET helpfilenumber=3>
<cfinclude template="minimal_contract_info.cfm">
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT language="JavaScript">
function reset_Form_Fields()
	{
		var search_form = $("form[name='MyForm']");
		$('select', search_form).each(function() {
				if ( $(this).attr('id') === 'sort_by' ) {}
				else {
					$(this).val( $('option:first', $(this)).val() )  // reset select dropdown with default 1st option
								 .trigger('change');                       // trigger onchange event
				}
		});
		// reset all non-hidden input to blank
		$('input:visible', search_form).val( '' );
		document.MyForm.Operator_Search_Name.value="";	//D 29939: Reset

	}

	function resetSelect(selName)
		{
		var sObj = document.getElementById(selName);
		if(sObj)
		{
			sObj.selectedIndex = 0;
			callfireEvent(document,sObj,'Change');
		}
	}

		function deleteThisFixedPrice(FieldNameRe, prodID)
	{
		var trObj = document.getElementById("TR_" + FieldNameRe);
		var trIndex = trObj.rowIndex;
		var FINALITEMLIST = document.MyForm.FinalItemList.value;
		var resultString = ListDeleteItem(FINALITEMLIST, ",", prodID);
		var bDelete = true;

		if(resultString == FINALITEMLIST)
		{
			resultString = ListAppendItem(FINALITEMLIST, ",", prodID);
			bDelete = false;
		}

		document.MyForm.FinalItemList.value = resultString;

		if(trObj)
		{
			var srcObj = event.srcElement;
			if(bDelete)
			{
				propogateProperty(trObj, "style.backgroundColor", "#CCCCCC", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);

				srcObj.title = "undo <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> deletion";
				srcObj.src = undodeleteImg.src;
			}
			else
			{
				var bgCol = "#eeeeee";

				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);

				srcObj.title = "delete this <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>";
				srcObj.src = deleteImg.src;
			}
		}
		event.cancelBubble = true;
	}

	function searchPrograms() {
		searchResults = window.showModalDialog('/common_files/contracts/program_search_for_component.cfm','','dialogHeight: 600px; dialogWidth: 940px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;');
		if(searchResults != 0 && searchResults.length != 0) {
			document.all.LoadProductsFromThesePrograms.value = searchResults;
			doSearch();
		}
	}


</SCRIPT>

<CFOUTPUT>
	<FORM ACTION="select_operators.cfm?CID=#URL.CID#" METHOD="post" NAME="MyForm" ID="MyForm" STYLE="DISPLAY:INLINE">
</CFOUTPUT>

	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> search <cfif form.Is_Group>by Groups</cfif></LEGEND>

<!--- Dev Note: Milan:(Only for old (CF) operator search)--->
<cfif appSettings.getFlexOperatorSearch() eq 0>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Location_Type														 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Operator_Location_Type" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
	Select	distinct Operator_Location_Type
	From	awayX_Operator_Location_Type
	where 	0=0
	<cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") and application.returned_customer_setting.customer_keyword IS "conagra">
	 and Business_segment_id = #FORM.BUSINESS_SEGMENT_ID#
	</cfif>
</CFQUERY>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the list of Operator_Type																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="Get_Operator_Type" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
	Select	distinct Operator_Type
	From	awayX_Operator_Type
	where 	0=0
	<cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") and application.returned_customer_setting.customer_keyword IS "conagra">
	 and Business_segment_id = #FORM.BUSINESS_SEGMENT_ID#
	</cfif>
</CFQUERY>
<cfif application.operatorVariableAvailable>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get the list of Operator_Category																	 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfset useLakebaseForGet_Operator_Category = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operator_category")>
<cfif useLakebaseForGet_Operator_Category>
	<cftry>
		<cfset Get_Operator_Category = application.oLakebase.toQuery(
			application.oLakebase.selectRows("operator_category", {
				"deleted" = "eq.0",
				"select" = "operator_category_id,category_label"
			}), "operator_category_id,category_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Category = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Category>
<CFQUERY NAME="Get_Operator_Category" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
		Select	Operator_Category_ID, Category_Label
		From	Operator_Category
		Where	deleted = 0
	</CFQUERY>
</cfif>

	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<!--- Get the list of Operator_Category																	 --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfset useLakebaseForGet_Operator_Priority = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("operator_priority")>
<cfif useLakebaseForGet_Operator_Priority>
	<cftry>
		<cfset Get_Operator_Priority = application.oLakebase.toQuery(
			application.oLakebase.selectRows("operator_priority", {
				"deleted" = "eq.0",
				"select" = "operator_priority_id,priority_label"
			}), "operator_priority_id,priority_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Operator_Priority = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Operator_Priority>
<CFQUERY NAME="Get_Operator_Priority" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
	Select	Operator_Priority_ID, Priority_Label
	From	Operator_Priority
	Where	deleted = 0
	</CFQUERY>
</cfif>
</cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the states																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfquery name="Get_States" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
	SELECT DISTINCT Operator_State as State_Code, State_Name, Country_Sort_Order
	FROM BSA_Operator o
	join _States s on s.State_Code = o.Operator_State
	join _Country c on s.Country_ID = c.Country_ID
	WHERE	LEN(State_Code) > 0
	ORDER BY Country_Sort_Order, State_Name
</cfquery>



<STYLE>
	.LONGINPUT
	{
		width: 175px;
	}
	SELECT
	{
		width: 175px;
	}
</STYLE>

	<!---    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> search</LEGEND>
--->
</cfif>
<!--- Dev Note: Milan:(Only for old (CF) operator search)--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<cfscript>
	function isNextRow(maxCols, currCols){
		if(currCols LTE 1){
			return 0;
		}
		else{
			return (not(currCols) mod maxCols);
		}
	}
</cfscript>

<cfset maxColsPerRow = 4/>
<cfset currentColCount = 0/>

<!--- Dev Note: Milan:(Only for old (CF) operator search)--->
<cfif appSettings.getFlexOperatorSearch() eq 0>

<TABLE width="700" border="0" cellpadding="4" id="OperatorFilters">
<TR>

<cfloop query="vars.qSearchField">
	<cfif vars.qSearchField.Is_PG EQ 0>
		<cfswitch expression = "#vars.qSearchField.Field_Name#">
			<cfcase value = "Operator Name">
			<TD width="100"><B><CFOUTPUT>#application.returned_customer_setting.operator_label_singular#</CFOUTPUT> Name:</B><BR><INPUT CLASS="LONGINPUT" TYPE="text" NAME="Operator_Name" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_Name#</CFOUTPUT>" onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}"></TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value = "Doing Business As">
				<TD>
					<B>Doing business as:</B><BR>
					<INPUT CLASS="LONGINPUT" TYPE="Text" NAME="Operator_DBA" MAXLENGTH="510" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_DBA#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value = "City">
			<TD>
					<B>City:</B><BR>
					<INPUT CLASS="LONGINPUT" TYPE="Text" NAME="Operator_City" MAXLENGTH="510" STYLE="font-size: 10px;" VALUE="<CFOUTPUT>#FORM.Operator_City#</CFOUTPUT>" onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value = "State">
			<TD>
					<B>State:</B><BR>
					<SELECT NAME="Operator_State" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
					<OPTION VALUE="All" SELECTED>Select State</OPTION>
					<OPTION VALUE="All">Any State</OPTION>
					<CFOUTPUT QUERY="Get_States"><OPTION VALUE="#State_Code#" <CFIF FORM.Operator_State EQ Get_States.State_Code>selected</CFIF>>#State_Name#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value="Location Type">
				<TD>
					<B><cfoutput>#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#</cfoutput>:</B><BR>
					<SELECT NAME="Operator_Location_Type" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
					<OPTION VALUE="All" <CFIF Get_Operator_Location_Type.recordcount NEQ 1>SELECTED</CFIF>>Select <cfoutput>#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
					<OPTION VALUE="All">All <cfoutput>#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
					<CFOUTPUT QUERY="Get_Operator_Location_Type"><OPTION VALUE="#Operator_Location_Type#" <CFIF FORM.Operator_Location_Type EQ Get_Operator_Location_Type.Operator_Location_Type OR Get_Operator_Location_Type.recordcount EQ 1>selected</CFIF>>#Operator_Location_Type#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value="Type of Operator">
				<TD>
					<B><CFOUTPUT>#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#</CFOUTPUT>:</B><BR>
					<SELECT NAME="Operator_Type" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
					<OPTION VALUE="All" <CFIF Get_Operator_Type.recordcount NEQ 1>SELECTED</CFIF>>Select <CFOUTPUT>#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#</CFOUTPUT></OPTION>
					<OPTION VALUE="All">All <CFOUTPUT>#qGetOperatorTypeLabel.GENERAL_LABELS_LABEL#</CFOUTPUT></OPTION>
					<CFOUTPUT QUERY="Get_Operator_Type"><OPTION VALUE="#Operator_Type#" <CFIF FORM.Operator_Type EQ Get_Operator_Type.Operator_Type OR Get_Operator_Type.recordcount EQ 1>selected</CFIF>>#Operator_Type#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value="Operator Category">
				<cfif application.operatorVariableAvailable>
				<TD>
					<B><cfoutput>#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#</cfoutput>:</B><BR>
					<SELECT NAME="Operator_Category" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
					<OPTION VALUE="All" SELECTED>Select <cfoutput>#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
					<OPTION VALUE="All">All <cfoutput>#qGetOperatorCategoryLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
					<CFOUTPUT QUERY="Get_Operator_Category"><OPTION VALUE="#Operator_Category_ID#" <CFIF FORM.Operator_Category EQ Operator_Category_ID>selected</CFIF>>#Category_Label#</OPTION></CFOUTPUT>
					</SELECT>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
				</cfif>
			</cfcase>
			<cfcase value="Operator Priority">
				<cfif application.operatorVariableAvailable>
					<TD>
						<B><cfoutput>#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#</cfoutput>:</B><BR>
						<SELECT NAME="Operator_Priority" STYLE="font-size: 10px;"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
						<OPTION VALUE="All" SELECTED>Select <cfoutput>#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
						<OPTION VALUE="All">All <cfoutput>#qGetOperatorPriorityLabel.GENERAL_LABELS_LABEL#</cfoutput></OPTION>
						<CFOUTPUT QUERY="Get_Operator_Priority"><OPTION VALUE="#Operator_Priority_ID#" <CFIF FORM.Operator_Priority EQ Operator_Priority_ID>selected</CFIF>>#Priority_Label#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />
				</cfif>
			</cfcase>
			<cfcase value="## of Locations">
				<TD>
					<B># Locations:</B><BR>
					<CFSET OperationList = " ,>=,<=,=">
					<nobr><SELECT NAME="Number_Locations_Operation" STYLE="width:40px;font-size: 10px;"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
					<CFOUTPUT>
					<CFLOOP list="#OperationList#" delimiters="," index="ThisItem">
						<cfset ThisItem = Trim(ThisItem)>
						<OPTION VALUE="#ThisItem#"<CFIF FORM.Number_Locations_Operation EQ ThisItem> SELECTED</CFIF>>#ThisItem#</OPTION>
					</CFLOOP>
					</CFOUTPUT>
					</SELECT>
					<INPUT onKeyUp="clenseText(this, '0123456789');" TYPE="Text" NAME="Operator_Number_Of_Locations" MAXLENGTH="8" STYLE="width:80px;font-size: 10px;" VALUE="<CFOUTPUT>#Replace(FORM.Operator_Number_Of_Locations,'-','','ALL')#</CFOUTPUT>"></nobr>
				</TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value="Customer Type">
				<!---Initialize the appliation settings--->
				<cfset UseCustomerType = appSettings.getCustomertype()>
				<!---Only do this if we're using customer types--->
				<cfif UseCustomerType IS 1>
				<TD NOWRAP ALIGN="left"><strong>Customer Type:</strong><Br>
					<SELECT NAME="Customer_Type"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
						<option value="">**ALL TYPES**</option>
						<cfoutput query="Get_CustType_Profile_Settings">
							<cfif Get_CustType_Profile_Settings.PROFILE_CUSTOMER_TYPE_VALUE IS 1><option value="#Customer_Type#" <cfif Form.Customer_Type IS Customer_Type>selected</cfif>>#Customer_Type_Desc#</option></cfif>
						</cfoutput>
					</SELECT>
				</td>
				<cfinclude template="_incTrSeparator.cfm" />
				</cfif>
			</cfcase>
			<cfcase value="Market">
				<cfif application.operatorVariableAvailable>
					<TD NOWRAP ALIGN="left">
						<B><CFOUTPUT>#application.returned_customer_setting.market_label_singular#</CFOUTPUT>:</B><BR>
						<CFQUERY NAME="GetMarkets" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
						SELECT Market_Name, Service_Market_ID
						FROM Service_Markets
						WHERE len(Market_Name) > 0 AND Deleted = 0
						<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  START
						Added/Changed: Added if condition to filter based on Business segment id--->
				        <cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") AND appSettings.getPositionFieldsFilterOnProgramSegment()>
											and Business_segment_id = #busSegIdForProgram#
						</cfif>
						<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->
						ORDER BY Market_Name
						</CFQUERY>
						<SELECT NAME="Market_ID"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
							<OPTION VALUE="">**ALL** <CFOUTPUT>#application.returned_customer_setting.market_label_plural#</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetMarkets"><OPTION VALUE="#trim(Service_Market_ID)#"#IIF(trim(FORM.Market_ID) EQ Service_Market_ID, DE(" SELECTED"), DE(""))#>#trim(Market_Name)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />
				</cfif>
			</cfcase>
			<cfcase value="Position">
				<cfif application.operatorVariableAvailable>
					<TD NOWRAP ALIGN="left">
						<B>Position:</B><BR>
						<CFQUERY NAME="GetPositions" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
						SELECT 	User_positions_ID, Position_Label
						FROM 	User_positions
						<!--- Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  START
						Added/Changed: Added Joins to filter based on Business segment id--->
						<cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") AND appSettings.getPositionFieldsFilterOnProgramSegment()>
						LEFT JOIN Service_Zones
						ON 	Service_Zones.Service_Zone_ID = User_positions.Service_Zone_ID
						AND	User_positions.Service_Region_ID IS NULL
						LEFT JOIN Service_Regions
						ON 	Service_Regions.Service_Region_ID = User_positions.Service_Region_ID
						AND	User_positions.Service_Market_ID IS NULL
						LEFT JOIN Service_Markets
						ON 	Service_Markets.Service_Market_ID = User_positions.Service_Market_ID
						</cfif>
						<!--- End Dev Note: drachala; D28618: Position Drop Down Fields filtered based on Program Business Segment  --->
						WHERE 	len(Position_Label) > 0
						AND 	User_positions.Deleted = 0
						<cfif form.businessSegmentsOn eq 1 and isDefined("BUSINESS_SEGMENT_ID") AND appSettings.getPositionFieldsFilterOnProgramSegment()>
						AND	(CASE
							WHEN User_positions.Service_Region_ID IS NULL THEN Service_Zones.Business_Segment_ID
							WHEN User_positions.Service_Market_ID IS NULL THEN Service_Regions.Business_Segment_ID
							ELSE Service_Markets.Business_Segment_ID
							END) = #busSegIdForProgram#
						</cfif>
						ORDER BY Position_Label
						</CFQUERY>
						<SELECT NAME="Position_ID"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
							<OPTION VALUE="">**ALL** <CFOUTPUT>Positions</CFOUTPUT></OPTION>
							<CFOUTPUT QUERY="GetPositions"><OPTION VALUE="#trim(User_positions_ID)#"#IIF(trim(FORM.Position_ID) EQ User_positions_ID, DE(" SELECTED"), DE(""))#>#trim(Position_Label)#</OPTION></CFOUTPUT>
						</SELECT>
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />
				</cfif>
			</cfcase>
			<cfcase value="Country">
				<TD NOWRAP ALIGN="left">
					<CFPARAM NAME="Form.Operator_Country_Code" DEFAULT="0">
					<!--- Country code --->
					<CFQUERY NAME="getCountry" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#">
						SELECT distinct c.country_code, country_name, Country_id
						FROM BSA_Operator o
						Join  _Country c on o.operator_country_code = c.country_code
						where active = 1
						ORDER BY Country_id ASC
					</CFQUERY>
					<strong>Country:</strong><BR>
					<CFOUTPUT>
						<SELECT NAME="Operator_Country_Code" STYLE="WIDTH:175px"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
						  <OPTION SELECTED value="0">**ALL** Countries</OPTION>
						    <CFLOOP QUERY="getCountry">
								<OPTION VALUE="#getCountry.Country_Code#" #IIF(trim(FORM.Operator_Country_Code) EQ trim(GetCountry.country_code), DE(" SELECTED"), DE(""))#>#getCountry.Country_Name#</OPTION>
							</CFLOOP>
					     </SELECT>
					</CFOUTPUT>
				 </TD>
				<cfinclude template="_incTrSeparator.cfm" />
			</cfcase>
			<cfcase value="Operator ID">
				<cfif LegacyIdOn>
				    <TD><strong><cfoutput>#application.returned_customer_setting.Operator_Legacy_Id_label#</cfoutput>:</strong>
				    <BR><cfset DisplayCreateList("Operator_Legacy_Id")>
				    <BR>
						<input type="Text" name="legacy_id" maxlength="510" style="font-size: 10px;" value="<CFOUTPUT>#FORM.legacy_id#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
				    </TD>
					<cfinclude template="_incTrSeparator.cfm" />
				</cfif>
			</cfcase>
			<cfcase value="BSA Operator ID">
				<cfif appSettings.getShowBSAOperators() EQ 1> <!--- 27449 hide if setting is OFF --->
					<TD>
				    	<p><strong><CFOUTPUT>#CustomerSettingsLabels.BSA_ID_label#</CFOUTPUT>:</strong>
				    	<cfset DisplayCreateList("BSA_Operator_Id")>
				    	<BR><!--- <br> --->
						<input type="Text" name="BSA_Operator_id" maxlength="50" style="width:80px;font-size: 10px;" value="<CFOUTPUT>#FORM.BSA_Operator_id#</CFOUTPUT>"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
					</TD>
					<cfinclude template="_incTrSeparator.cfm" />
				<cfelse>
					<INPUT TYPE="Hidden" NAME="BSA_Operator_id" VALUE="<CFOUTPUT>#FORM.BSA_Operator_id#</CFOUTPUT>">
				</cfif>
	  		</cfcase>
			<cfcase value="Operator Status">
				 <!--26199 - New setting for inactive operators in programs ChrisN 2011/feb/23-->
				  <td><strong>Operator Status:</strong><br>
				    <select name="Operator_Status"  onkeydown="if (event.keyCode == 13){document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();}">
				        <option value="A">Active</option>
				        <!--26199 allows inactive option based on user profile setting -->
				        <cfif Get_Profile_Settings.Search_Inactive_Operators_Programs eq 1>
				          <option value="N" <cfif FORM.Operator_Status eq "N">SELECTED</cfif>>Inactive</option>
				        </cfif>
				    </select>
				  </td>
				<cfinclude template="_incTrSeparator.cfm" />
	 		</cfcase>
		</cfswitch>
	<cfelseif vars.qSearchField.Is_PG EQ 1>
	<!--- START: D30185:Label Settings, PG and Operator Search Tool/Anand Rao/26-Jan-2012 --->
		 <!--- D25657: Planning Group Module start--->
		  <cfif (appSettings.getPlanningGroups()) AND isDefined("GetContractInfo") AND GetContractInfo.RecordCount GTE 1>
		    <cfloop query="qGetTopLevelGroups">
					<!---- Display the drop down only if it is present in the var.qsearchField structure --->
					<cfif qGetTopLevelGroups.Operator_Group_Level_Type_ID EQ vars.qSearchField.Operator_Group_Level_ID>
				        <td>
			          	<cfset OperatorAttributeDropDownName = "Operator_Attribute_#Operator_Group_Level_Type_ID#" />
									<CFPARAM NAME="FORM.#OperatorAttributeDropDownName#" DEFAULT="0">
										<cfmodule 	template="/Customtags/OperatorGroupDropDown.cfm"
													groupLevelType = "#Operator_Group_Level_Type_ID#"
													dropDownName = "#OperatorAttributeDropDownName#"
													selectedValue = "#Evaluate("FORM.#OperatorAttributeDropDownName#")#"
													cachedwithin="#APPLICATION.masterDataCacheSpan#"
				                  FirstParentID = "#GetTemplateInfo.First_parent_ID#"
													/>
				             <cfset  Headers_from_Query = ListAppend(Headers_from_Query,qGetTopLevelGroups.Group_Level_Desc,":")/>
				             <cfset Headers_from_Query_dummy=ListAppend(Headers_from_Query_dummy,"a",":") />

				        </td>
						<cfinclude template="_incTrSeparator.cfm" />
					</cfif>
		    </cfloop>

		       <!---
		         TODO: We will do this during the Enhancements phase as it becomes more complex at this stage and we will
		        need to do the same thing on the other two Planning Groups also.
		        <td>
		          <strong>PG Code:</strong> <br><input  type="text" name="pgCode" width="15" maxlength="20" value="<CFOUTPUT>#FORM.pgCode#</CFOUTPUT>">
		        </td>
		      --->
		      <!---   <cfinclude template="_incTrSeparator.cfm" /> --->

		</cfif>
		<!--- D25657: Planning Group Module End--->

	<!--- END: D30185:Label Settings, PG and Operator Search Tool/Anand Rao/26-Jan-2012 --->
	</cfif>
</cfloop>

<tr>
<cfif form.businessSegmentsOn eq 1  AND isDefined("FORM.BUSINESS_SEGMENT_ID") AND FORM.BUSINESS_SEGMENT_ID NEQ 0>
    <td colspan="2"><cfoutput>#appSettings.getbusiness_segment_label()#</cfoutput>:&nbsp;&nbsp;<b><cfoutput>#Bus_Segment_Desc#</cfoutput></b></td>
</cfif>
<td colspan="100%" align="left">
<!---<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>--->
		<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();"> search <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)# <cfif form.Is_Group>groups</cfif></cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>

		<FONT COLOR="ff0000" >&nbsp;&nbsp;<B>[</B></FONT>
			<A HREF="javascript: reset_Form_Fields();"><B>reset</B></A>
		<FONT COLOR="ff0000" ><B>]</B></FONT>
		<!---Show create if the business segment is dry or refridgerated, but business segments need to be on first--->

		<cfparam name="ShowCreateOperator" default="1">
		<cfif (Get_Profile_Settings.Create_Operator_Access NEQ 1) or form.Is_Group>
			<cfset ShowCreateOperator = 0 />
		</cfif>

		<cfif ShowCreateOperator IS 1>
		<B>&nbsp;&nbsp;<font COLOR="Red">[</font>
			<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Operators_Added eq 2>
				<span style="color:gray">create <cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput></span>
		 <cfelse>
				<A ONCLICK="createOperator()" STYLE="cursor: pointer;">create <cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput></A>
			</cfif>
		<font COLOR="Red">]</font></B>
		</cfif>
</td>
</tr>

</TABLE>
</CFIF>
<!--- Dev Note: Milan:(Only for old (CF) operator search)--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Dev Note: Milan:(Only for new (flex) operator search)--->
<cfif appSettings.getFlexOperatorSearch() eq 1>
			<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10"><BR>
			&nbsp;&nbsp;
			<!--- <B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="document.all.LoadProductsFromThesePrograms.value = ''; return doSearch();">search <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput></a><FONT COLOR="#FF0000">]</FONT></B> --->
			<B><FONT COLOR="#FF0000">[</FONT><a HREF="#" ONCLICK="return showOperatorSearchWindow();">search <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput></a><FONT COLOR="#FF0000">]</FONT></B>

			<cfparam name="ShowCreateOperator" default="1">
			<cfif Get_Profile_Settings.Create_Operator_Access NEQ 1>
				<cfset ShowCreateOperator = 0 />
			</cfif>

			<cfif ShowCreateOperator IS 1>
			<B>&nbsp;&nbsp;<font COLOR="Red">[</font>
				<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Operators_Added eq 2>
					<span style="color:gray">create <cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput></span>
			 <cfelse>
					<A ONCLICK="createOperator()" STYLE="cursor: pointer;">create <cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput></A>
				</cfif>
			<font COLOR="Red">]</font></B>
			</cfif>
</cfif>
<!--- Dev Note: Milan:(Only for new (flex) operator search)--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		<CFPARAM NAME="FORM.sort_Order" DEFAULT="ASC">
 		<INPUT type="Hidden" value="#FORM.sort_by#" NAME="sort_by">
		<INPUT type="Hidden" value="#FORM.sort_Order#" NAME="sort_Order">
		<INPUT TYPE="Hidden" NAME="DoSearch" VALUE="1">
		<INPUT TYPE="hidden" NAME="Operator_Search_Name" value="<cfoutput>#form.Operator_Search_Name#</cfoutput>">
	</FIELDSET>

<BR>

	<CFQUERY NAME="GetOperatorInfo" datasource="#application.datasource#" CACHEDWITHIN="#cacheSpan#" result="vars.dbResult">
		<cfif form.Is_Group>
				SELECT  BSA_Operator_ID = poc.pg_Operator_Category_Id
							 ,Operator_Name = poc.pg_Operator_Category_Name + ' - ' + poc.pg_Operator_Category_Code
							 ,Operator_City = ''
							 ,Operator_State = ''
							 ,Operator_Zip = ''
							 ,Operator_Phone = ''
							 ,USER_ADDED = ''
							 ,Legacy_ID
				  FROM PG_OPERATOR_CATEGORY poc
				 WHERE <cfif len(FORM.FinalItemList)>
								pg_Operator_Category_Id IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.FinalItemList#" list="yes">)
							 <cfelse>
								1=2
							</cfif>
		<cfelse>
				SELECT 	BSA_Operator_ID, Operator_Name,Operator_City, Operator_State, Operator_Zip, Operator_Phone, USER_ADDED, Legacy_ID
				  FROM 	BSA_Operator
				 WHERE  <cfif len(FORM.FinalItemList)>
									BSA_Operator_ID IN(#FORM.FinalItemList#)
								<cfelse>
									1=2
								</cfif>
					<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ '1'>
							AND BSA_Operator.is_pg = 0
					</cfif>
		</cfif>
	</CFQUERY>
	<!--- �Please Wait Indicator --->
	<div class="customContainer" style="display:none;margin-left:250px;"></div>
	<!--- �Please Wait Indicator --->

	<FIELDSET STYLE="padding:8px; width: 800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">currently selected <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput></LEGEND>
			<CFIF isdefined('GetOperatorInfo') AND GetOperatorInfo.recordcount GT 0>
				<cfoutput>
					<TABLE border="0" cellspacing="3" cellpadding="3" align="left" WIDTH="100%" BGCOLOR="white">
						<TR><CFLOOP QUERY="GetOperatorInfo">
						<cfset ScreenedOperator = Replace(GetOperatorInfo.BSA_Operator_ID,"-","_", "ALL")>
							<TD NOWRAP BGCOLOR="eeeeee" ID="TR_#ScreenedOperator#" valign="top">
							<cfif NOT(Revision_Settings_Allowed eq 1 and RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Operators_Removed eq 2)>
	 						<img src="/images/scissor.gif" title="click here to delete this <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput>" border="0" onClick="deleteThisFixedPrice('#ScreenedOperator#', '#GetOperatorInfo.BSA_Operator_ID#')" style="cursor: pointer;">
							</cfif>
							<img src="/Images/fill.gif" width="4" height="1">#GetOperatorInfo.operator_name# <cfif ! appSettings.getShowBSAOperators()> ( #GetOperatorInfo.Legacy_ID# )</cfif>
							<BR><img src="/Images/fill.gif" width="18" height="1">#Operator_City# <cfif not form.Is_Group>-</cfif> #Operator_State# #Operator_Zip#<cfif len(trim(Operator_Phone)) GT 0><br><img src="/Images/fill.gif" width="18" height="1">#Operator_Phone#</cfif>
							<!--- do not allow editing on operator group --->
							<cfif form.Is_Group>
							<cfelseif ShowCreateOperator IS 1>
								<br><img src="/Images/fill.gif" width="18" height="1">
									<CF_smallLink
									title = "edit #application.returned_customer_setting.operator_label_singular#"
									url = "##"
									parameters = "onClick=""javascript: return editOperator('#BSA_Operator_ID#');"""
									>
							</cfif>
							</TD>
			 				<CFIF GetOperatorInfo.currentrow mod 4><CFELSE></TR><TR></CFIF>
						</CFLOOP>
					</TABLE>
				</cfoutput>
			<CFELSE>
				<CFIF FORM.FinalItemList EQ "ALL"><B>ALL <cfoutput>#ucase(application.returned_customer_setting.operator_label_plural)#</cfoutput></B><CFELSE><B>None</B></CFIF>
			</CFIF>
			<BR>
	</FIELDSET>


<BR><BR>

<input type="hidden" name="button_caption" value="<CFOUTPUT>#FORM.Button_Caption#</CFOUTPUT>">
 <cfif NOT(Revision_Settings_Allowed eq 1 and RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Operators_Removed eq 2)>
	<TABLE>
		<TR>
			<TD>
				<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"javascript: importSelectedOperators();"
					button_type		=	"link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</TABLE>
 </cfif>

<!--- Dev Note: Milan:(Only for old (cf) operator search)--->
<cfif appSettings.getFlexOperatorSearch() eq 0>
<CFIF isdefined("FORM.DoSearch") AND FORM.DoSearch IS 1>
	<CFSET form.searchstring = trim(form.searchstring)>

	<cfif listlen(trim(form.LoadProductsFromThesePrograms)) GT 0>
		<cfset FORM.Position_ID = "">
		<cfset FORM.Market_ID 	= "">
		<cfset Operator_State = "All">
		<cfset Operator_Country_Code = "0">
		<cfset Operator_Type = "All">
		<cfset Operator_Location_Type = "All">
		<cfset Operator_Name = "">
		<cfset Operator_City = "">
		<cfset Operator_DBA = "">
		<cfset FORM.Operator_Number_Of_Locations = "">
		<cfset Operator_Category = "">
		<cfset Operator_Priority = "">
	</cfif>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---><!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve operators																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--------------------------------------------------------------------
Add Sort By
---------------------------------------------------------------------->



<CFSET sql_Sort_By="Operator_Name">
<CFSWITCH expression="#Form.sort_by#">
	<CFCASE value="Operator Name">
		<CFSET sql_Sort_By="Operator_Name">
	</CFCASE>
	<CFCASE value="Location Type">
		<CFSET sql_Sort_By="Operator_Location_Type">
	</CFCASE>
	<CFCASE value="City">
		<CFSET sql_Sort_By="Operator_City">
	</CFCASE>
	<CFCASE value="State">
		<CFSET sql_Sort_By="Operator_State">
	</CFCASE>
	<CFCASE value="Country Code">
		<CFSET sql_Sort_By="Operator_Country_Code">
	</CFCASE>
	<CFCASE value="Number of Locations">
		<CFSET sql_Sort_By="Operator_Number_Of_Locations">
	</CFCASE>
	<CFCASE value="Doing Business As">
		<CFSET sql_Sort_By="Operator_DBA">
	</CFCASE>
	<CFCASE value="Legacy Id">
		<CFSET sql_Sort_By="legacy_id">
	</CFCASE>
 <!---  D39828  :: Added BSA Operator id to Operator search and Results.... START --->
   	<CFCASE value="BSA Operator ID">
  		<CFSET sql_Sort_By="BSA_Operator_ID">
  	</CFCASE>
 <!---  D39828  :: Added BSA Operator id to Operator search and Results.... END --->
</CFSWITCH>

<CFSET sql_Sort_By_Order=" ASC">
<CFSET sql_Sort_By_Order_Rev=" DESC">
<CFIF Form.sort_Order EQ "DESC">
	<CFSET sql_Sort_By_Order=" DESC">
	<CFSET sql_Sort_By_Order_Rev=" ASC">
</CFIF>

<!--------------------------------------------------------------------
Add Sort By
---------------------------------------------------------------------->
<!---
D35657: Planning Group Module/ Anand Rao/ 09-Feb-2011
--->

<!---:::::::::::::::::::::::::::::::::--->
<!---:::: OPERATOR GROUPS SEARCH :::::--->
<!---:::::::::::::::::::::::::::::::::--->
<cfif form.Is_Group>
	<cfquery name="TheQuery" datasource="#application.datasource#" result="vars.dbResult">
		SELECT BSA_Operator_ID = poc.PG_Operator_Category_ID
		       ,poc.Pg_Operator_Category_Name
		       ,poc.Pg_Operator_Category_Code
		  FROM Pg_operator_category poc
		       LEFT JOIN GROUP_TEMPLATE gt ON gt.Template_Id = #GetTemplateInfo.First_parent_ID#
		                                   AND gt.pg_Group_Type = 3
		                                   AND gt.Group_Level_Id = poc.pg_Type_Id
		 WHERE poc.deleted = 0
		       AND poc.active = 1
		       AND poc.pg_type_id IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#ValueList(vars.TemplateSearchFields.Operator_Group_Level_Id)#" list="yes">)
			   AND gt.deleted = 0
		       AND ( gt.Allow_Filter = 0 or gt.Allow_Filter is null
		       				<!---allow filter setting in template is enabled, filter out unwanted elements--->
		              OR EXISTS ( SELECT Operator_Group_Id
		                            FROM OPERATOR_GROUP_TEMPLATE_SELECTION ogts
		                           WHERE ogts.Deleted = 0
		                                 AND ogts.Active = 1
		                                 AND ogts.Template_Id = gt.Template_Id
		                                 AND ogts.Operator_Group_Level_Id = poc.pg_Type_Id
		                                 AND ogts.Operator_Group_Id = poc.pg_Operator_Category_Id ) )

		       <!---go thru all dropdowns and if an option is selected add a filter--->
		       <cfloop query="vars.TemplateSearchFields">
		       	<cfset vars.DropDownOption = form["Operator_Attribute_" & vars.TemplateSearchFields.Operator_Group_Level_Id]>
		       	<!---is option selected?--->
		       	<cfif vars.DropDownOption neq "0">
		       	  <!---apply appropriate filter--->
		       		AND poc.PG_Operator_Category_ID = '#vars.DropDownOption#'
		       	</cfif>
		       </cfloop>

					<!---users clicked on an alphabet character at the bottom--->
					<cfif form.Operator_Search_Name neq "">
						AND lower(Pg_Operator_Category_Name) like '#lcase(form.Operator_Search_Name)#%'
					</cfif>
		 ORDER BY poc.pg_operator_category_name #sql_Sort_By_Order#
	</cfquery>

<!---:::::::::::::::::::::::::::::::::--->
<!---::::::: OPERATOR SEARCH :::::::::--->
<!---:::::::::::::::::::::::::::::::::--->
<cfelse>
	<CFQUERY NAME="TheQuery" datasource="#application.datasource#" result="vars.dbResult">
		/*		D113650 :: mws 3/7/22 :: CF Service high memory high CPU. Implement paging in the DB		*/
		DECLARE @startRow INT ; 
		SET @startrow = #StartRow#
		;WITH cols
		AS
			(
						SELECT	BSA_Operator.*,
							ROW_NUMBER() OVER(ORDER BY #sql_Sort_By# #sql_Sort_By_Order#) AS seq,
							ROW_NUMBER() OVER(ORDER BY #sql_Sort_By# #sql_Sort_By_Order_Rev#) AS rowNum
						FROM		BSA_Operator
								<CFIF FORM.Position_ID NEQ "" OR FORM.Market_ID NEQ "">
										LEFT JOIN Market_ZipCode ON
										Market_ZipCode.Deleted = 0 AND
										BSA_Operator.User_positions_ID IS NULL
										AND Market_ZipCode.ZipCode = Left(BSA_Operator.Operator_Zip, 5)
											<CFIF FORM.Market_ID NEQ "">
												AND
												Market_ZipCode.Service_Market_ID = #FORM.Market_ID#
											</CFIF>
										INNER JOIN User_Positions ON
										User_Positions.Deleted = 0
										AND
										(
											(
												BSA_Operator.User_Positions_ID IS NULL
												AND User_Positions.Service_Market_ID = Market_ZipCode.Service_Market_ID
											)
											OR
											(
												BSA_Operator.User_Positions_ID IS NOT NULL
												AND User_Positions.User_Positions_ID = BSA_Operator.User_Positions_ID
											)
										)
											<CFIF FORM.Position_ID NEQ "">
												AND User_Positions.User_Positions_ID = #FORM.Position_ID#
											</CFIF>
											<CFIF FORM.Market_ID NEQ "">
												AND User_Positions.Service_Market_ID = #FORM.Market_ID#
											</CFIF>
									</CFIF>
						  <!---30593 - Chris: re-find top level groups regardless settings for field in search, in group search, allow filter.
						  						 We wanted to apply operator filters (defined in template) when allow filter setting is enabled.--->
						  <cfset qGetTopLevelGroups = DataManager.getOperatorLevels(bActive = 1, allowList= "", disAllowList="",sCriteria="",FirstTemplateID=GetTemplateInfo.First_parent_ID) />
						  <cfif (appSettings.getPlanningGroups()) AND isDefined("GetContractInfo") AND GetContractInfo.RecordCount GTE 1>
						    <cfset PGManager = CreateObject("component", "components.settings.PlanningGroups.PlanningGroupsManager").init() />
						      <cfloop query="qGetTopLevelGroups">
								<cfset typeId = qGetTopLevelGroups.Operator_Group_Level_ID />
								<cfset applyFilter = 0 />
								<cfif qGetTopLevelGroups.Allow_Filter>
									<cfset applyFilter = 1 />
						        <cfelseif isDefined("FORM.Operator_Attribute_#Operator_Group_Level_Type_ID#") AND evaluate("FORM.Operator_Attribute_" & Operator_Group_Level_Type_ID) NEQ 0>
									<cfset applyFilter = 1 />
						        </cfif> <!--- checking for the FORM.Operator_Attribute_## --->

								<cfif applyFilter>
									INNER JOIN PG_Operator_Members as PGOM_#typeId#
									ON 	BSA_Operator.BSA_Operator_ID = PGOM_#typeId#.BSA_Operator_ID
									INNER JOIN PG_Operator_Category as PGOC_#typeId#
						        	ON	PGOC_#typeId#.PG_Operator_Category_ID = PGOM_#typeId#.PG_Operator_Category_ID
									AND	PGOC_#typeId#.PG_Type_ID = #typeId#
									<cfif qGetTopLevelGroups.Allow_Filter>
									AND	PGOM_#typeId#.PG_Operator_Category_ID IN (SELECT Operator_Group_ID
																					FROM Operator_Group_Template_Selection
																					WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 1 AND
																					Template_ID = #GetTemplateInfo.First_parent_ID#
																					<cfif GetContractInfo.Template_Filters_Id NEQ 0 AND IsNumeric(GetContractInfo.Template_Filters_Id)>
																						 AND Template_Filters_Id	= #GetContractInfo.Template_Filters_Id#
																					</cfif>
																					 AND Operator_Group_Level_ID = #qGetTopLevelGroups.Operator_Group_Level_ID#)
									</cfif>
									<cfif isDefined("FORM.Operator_Attribute_#Operator_Group_Level_Type_ID#") AND evaluate("FORM.Operator_Attribute_" & Operator_Group_Level_Type_ID) NEQ 0>
									AND	PGOM_#typeId#.PG_Operator_Category_ID = '#evaluate("FORM.Operator_Attribute_" & Operator_Group_Level_Type_ID)#'
									</cfif>
								</cfif>
						      </cfloop> <!--- Loop for qGetTopLevelGroups --->
						  </cfif><!--- Checking appsettings.getPlanningGroups() --->

						Where		Display_Code = 'A'
									<cfif appsettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1>
										AND operator_type != 'gpo_roster'
									</cfif>
									<!---
									D32444: PRG-1009597 Agree Reason
									Display_Code is not same as Active_Code.
									Display_Code = N records should never be displayed in the application
									To get active Operators use Deleted = 0
									To get inactive Operators use Deleted = 1
									--->
									<cfif FORM.Operator_Status eq "N">
									AND BSA_Operator.Deleted = 1
									<cfelse>
									AND BSA_Operator.Deleted = 0
									</cfif>

									<!---30286 - if we are coming from the create list form then use this criteria only, otherwise use the rest of the logic--->
									<cfif form.passed_form NEQ "" and form.itemList NEQ "">
									  <cfif form.itemList EQ "0">     <!---invalid items was selected in create list--->
									  	AND 1 = 0
									  <cfelseif legacyIDon>
											AND BSA_Operator.Legacy_Id in ( #PreserveSingleQuotes(form.itemList)# )
									  <cfelse>
											AND BSA_Operator.BSA_Operator_Id in ( #PreserveSingleQuotes(form.itemList)# )
										</cfif>
									<cfelse>

												<CFIF Operator_State NEQ "All" AND Operator_State NEQ "">  <!---29687--->
													and
													Operator_State	=	'#Operator_State#'
												</CFIF>
												<CFIF Operator_Country_Code NEQ "0">
													and
													Operator_Country_Code	=	'#Operator_Country_Code#'
												</CFIF>

												<CFIF Operator_Type NEQ "All" AND Operator_Type NEQ "">    <!---29687--->
													and
													Operator_Type	=	'#Operator_Type#'
												</CFIF>

												<CFIF Operator_Location_Type NEQ "All" AND Operator_Location_Type NEQ "">    <!---29687--->
													and
													Operator_Location_Type	=	'#Operator_Location_Type#'
												</CFIF>

												<CFIF trim(Operator_Name) NEQ "">
													and
													Operator_Name 	like 	'%#Operator_Name#%'
												</CFIF>

												<CFIF trim(Operator_City) NEQ "">
													and
													Operator_City 	like 	'%#Operator_City#%'
												</CFIF>

												<CFIF trim(Operator_DBA) NEQ "">
													and
													Operator_DBA 	like 	'%#Operator_DBA#%'
												</CFIF>
												<CFIF trim(form.legacy_id) NEQ "">
													and
													BSA_Operator.legacy_id 	like 	'%#form.legacy_id#%'
												</CFIF>

												<CFIF trim(form.BSA_Operator_ID) NEQ "">
													and
													BSA_Operator.BSA_Operator_ID	 =	<cfif isnumeric(form.BSA_Operator_ID)>#form.BSA_Operator_ID#<cfelse>''</cfif>
												</CFIF>

												<CFIF trim(FORM.Operator_Number_Of_Locations) NEQ "" AND isNumeric(Replace(FORM.Operator_Number_Of_Locations,"-","","ALL")) AND FORM.Number_Locations_Operation NEQ "">
													and
													CAST(Replace(Operator_Number_Of_Locations,'-','') AS BIGINT) #FORM.Number_Locations_Operation# #Replace(FORM.Operator_Number_Of_Locations,"-","","ALL")#
												</CFIF>

												<CFIF Operator_Category NEQ "All" AND Operator_Category NEQ "">
													and
													Operator_Category_ID	=	#Operator_Category#
												</CFIF>

												<CFIF Operator_Priority NEQ "All" AND Operator_Priority NEQ "">
													and
													Operator_Priority_ID	=	#Operator_Priority#
												</CFIF>
												<cfif not appSettings.getShowBSAOperators()>
													AND (BSA_Operator.Legacy_ID IS NOT NULL OR Len(BSA_Operator.Legacy_ID) != 0)
												</cfif>

												<!---Limits to customer types--->
												<cfif isDefined("UseCustomerType") AND UseCustomerType IS 1>
													<cfif len(trim(Customer_Type)) IS NOT 0>
													AND #Customer_Type# = 1
													</cfif>

												</cfif>

												<cfif listlen(trim(form.LOADPRODUCTSFROMTHESEPROGRAMS))>
													and
													BSA_Operator.BSA_Operator_ID IN(SELECT BSA_Operator_ID FROM Contract_Operators WHERE Deleted = 0 and Contract_Main_ID IN(#form.LOADPRODUCTSFROMTHESEPROGRAMS#))
												</cfif>
												<cfif form.businessSegmentsOn eq 1 and form.Business_Segment_ID neq 0>
													AND Business_Segment_ID = #form.Business_Segment_ID#
												</cfif>
												<cfif Get_CustType_Profile_Settings.recordcount GT 0>
											<cfloop query="Get_CustType_Profile_Settings">
												AND (dbo.BSA_Operator.#Get_CustType_Profile_Settings.Customer_Type# = 0 OR #Get_CustType_Profile_Settings.PROFILE_CUSTOMER_TYPE_VALUE# = 1 )
											</cfloop>
											</cfif>
											<!--- This is for alphabetical search --->
											<cfif form.Operator_Search_Name neq "">
												AND BSA_Operator.Operator_Name like '#form.Operator_Search_Name#%'
											</cfif>
									</cfif>   <!--- end of create list criteria--->
														<!-----ORDER BY 	Operator_Name--->
						)
					/*		D113650 :: mws 3/7/22 :: CF Service high memory high CPU. Implement paging in the DB		*/
					SELECT cols.*, rowNum + seq -1 as TotRows
					FROM cols
					WHERE seq BETWEEN @startRow AND @startRow + 24
					ORDER BY seq
	</CFQUERY>
</cfif>     <!---cfif form.Is_Group--->

<SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(<CFIF isDefined("TheQuery.RecordCount") AND TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> in the list below while selecting them all. Press OK if you wish to continue")<CFELSE>0==0</CFIF>) {
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
			/*
			var SelObj = document.all.sort_by;
			var next_Index = Get_Select_Index(SelObj, sortVal);
			if(next_Index >=0)
			{
				SelObj.selectedIndex = next_Index;
				SelObj = document.all.sort_Order;
				SelObj.selectedIndex = Get_Select_Index(SelObj, sortOrder);
				document.MyForm.submit();
			} */
			var OprForm = document.MyForm;
			OprForm.sort_by.value = sortVal;
			OprForm.sort_Order.value = sortOrder;
			OprForm.submit();
		}
</SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<cfif NOT isDefined("TheQuery.TotRows") AND isDefined("TheQuery.RecordCount")>
	<cfset varTotRows = TheQuery.RecordCount />
<cfelseif isDefined("TheQuery.TotRows")>
	<cfset varTotRows = TheQuery.recordCount
							? TheQuery.TotRows
							: 0 />
<cfelse>
	<cfset varTotRows = 0 />
</cfif>
	<FIELDSET STYLE="padding:8px; width:800px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF varTotRows EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>#varTotRows#</CFOUTPUT> <CFIF varTotRows EQ 1><cfoutput>#lcase(application.returned_customer_setting.operator_label_singular)#</cfoutput><CFELSE><cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput></CFIF> that <CFIF varTotRows EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>
		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF varTotRows GT 0>

		<CFSET showHideColumnsSetting()>

			<!--- <CFIF TheQuery.recordcount GTE 500> --->
			<CFIF 1 EQ 0>
				<FONT SIZE="+1"><B>Your query returned more than 500 records. Please narrow your search.</B></FONT>
			<CFELSE>

				<TABLE border="0" cellspacing="0" cellpadding="2" align="center" CLASS="Maintable" width="700">
					<TR ID="header" BGCOLOR="#ffce84" VALIGN="top">
						<TD align="center"><CFIF SelectSingleSearchResultOnly EQ 0><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all #application.returned_customer_setting.operator_label_plural#"><cfelse>&nbsp;</cfif></TD>
						<cfif form.Is_Group>
							<CFSET Header_Display_List = "#application.returned_customer_setting.operator_label_singular# Groups">
							<CFSET Header_Value_List = "Operator Name">
						<cfelse>
							<CFSET Header_Display_List = "#application.returned_customer_setting.operator_label_singular#">
							<CFSET Header_Value_List = "Operator Name">
							<cfif LegacyIdOn>
								<CFSET Header_Display_List = ListAppend(Header_Display_List, "#application.returned_customer_setting.Operator_Legacy_Id_label#", ",")>
								<CFSET Header_Value_List = ListAppend(Header_Value_List, "Legacy Id", ",")>
							</cfif>
						 <!--- D39828  :: Added BSA Operator id to Operator search and Results....  START--->
							<cfif appSettings.getShowBSAOperators() EQ 1 AND OprResults_DisplayBSAOperatorID>
								<CFSET Header_Display_List = ListAppend(Header_Display_List, "#CustomerSettingsLabels.BSA_ID_label#",",")>
								<CFSET Header_Value_List =  ListAppend(Header_Value_List,"BSA Operator ID", ",")>
							 </cfif>
							<!---  D39828  :: Added BSA Operator id to Operator search and Results.... END --->
							<!--- D42730 :: Operator Search Results - inside Programs
							<CFSET Header_Display_List = ListAppend(Header_Display_List, "#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#<br>,City:State,## of<BR>Locations,Doing Business As,list<br>programs", ",")>
							<CFSET Header_Value_List = ListAppend(Header_Value_List, "Location Type,City:State,Number of Locations,Doing Business As,list programs", ",")>
							--->
							<cfif OprResults_DisplayCity AND OprResults_DisplayState>
								<CFSET Header_Display_List = ListAppend(Header_Display_List, "City:State", ",")>
								<CFSET Header_Value_List = ListAppend(Header_Value_List, "City:State", ",")>
							<cfelseif OprResults_DisplayCity>
								<CFSET Header_Display_List = ListAppend(Header_Display_List, "City", ",")>
								<CFSET Header_Value_List = ListAppend(Header_Value_List, "City", ",")>
							<cfelseif OprResults_DisplayState>
								<CFSET Header_Display_List = ListAppend(Header_Display_List, "State", ",")>
								<CFSET Header_Value_List = ListAppend(Header_Value_List, "State", ",")>
							</cfif>

							<cfif OprResults_DisplayLocationType>
								<CFSET Header_Display_List = ListAppend(Header_Display_List, "#qGetLocationTypeLabel.GENERAL_LABELS_LABEL#<br>", ",")>
								<CFSET Header_Value_List = ListAppend(Header_Value_List, "Location Type", ",")>
							</cfif>

							<cfif OprResults_DisplayListPrograms>
								<CFSET Header_Display_List = ListAppend(Header_Display_List, "list<br>programs", ",")>
								<CFSET Header_Value_List = ListAppend(Header_Value_List, "list programs", ",")>
							</cfif>
						</cfif>

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
								<CFIF CompareNoCase(This_Value_Token, FORM.sort_by) EQ 0 or form.Is_Group><!--- current sort --->
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
					</TR>
				<CFOUTPUT QUERY="TheQuery"> <!--- startrow="#StartRow#" maxrows="#MaxRows#" --->
						<cfset record_count = varTotRows>
					<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: pointer;">
						<TD align="center">
						<CFIF SelectSingleSearchResultOnly EQ 0>
						<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#"
							<CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED="CHECKED"<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")>
								<cfif RevisionSettings.Operators_Removed eq 2 AND listfind(ValueList(ParentProgramOperators.BSA_Operator_ID), trim(TheQuery.BSA_Operator_ID)) NEQ 0>DISABLED="DISABLED"</cfif>
							<cfelse>
						<cfif RevisionSettings.Operators_Added eq 2>DISABLED="DISABLED"</cfif></CFIF>>
							<cfif RevisionSettings.Operators_Removed eq 2 OR RevisionSettings.Operators_Added eq 2>
								<cfif RevisionSettings.Operators_Removed eq 2 AND listfind(ValueList(ParentProgramOperators.BSA_Operator_ID), trim(TheQuery.BSA_Operator_ID)) NEQ 0>
									<INPUT type="hidden" name="SelectedITEMS" value="#trim(TheQuery.BSA_Operator_ID)#">
								</cfif>
							</cfif>
						<cfelse>
							<INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF>>
						</cfif>
						<CFELSE>
						<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1>
						<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#"
						<CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED="CHECKED"<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")>
						<CFIF RevisionSettings.Operators_Removed eq 2 AND 	listfind(ValueList(ParentProgramOperators.BSA_Operator_ID), trim(TheQuery.BSA_Operator_ID)) NEQ 0>DISABLED="DISABLED"</CFIF><CFELSE><CFIF RevisionSettings.Operators_Added eq 2 OR RevisionSettings.Operators_Removed eq 2>DISABLED="DISABLED"</CFIF></CFIF>>
						<cfif RevisionSettings.Operators_Removed eq 2 OR RevisionSettings.Operators_Added eq 2>
							<cfif RevisionSettings.Operators_Removed eq 2 AND listfind(ValueList(ParentProgramOperators.BSA_Operator_ID), trim(TheQuery.BSA_Operator_ID)) NEQ 0>
							<INPUT type="hidden" name="SelectedITEMS" value="#trim(TheQuery.BSA_Operator_ID)#">
							</cfif>
						</cfif>
					<cfelse>
						<INPUT type="Radio" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#" <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF>>
					</cfif>
						</CFIF>
						</TD>
						<cfif form.Is_Group>
							<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.Pg_Operator_Category_Name# - #TheQuery.Pg_Operator_Category_Code#</TD>
						<cfelse>
							<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.operator_name#<CFIF trim(TheQuery.legacy_id) EQ ""> [#TheQuery.BSA_Operator_Id#]</cfif></TD>
							<cfif LegacyIdOn>
								<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.legacy_id#&nbsp;</TD>
							</cfif>
						<!---  D39828  :: Added BSA Operator id to Operator search and Results....  START--->
						<cfif appSettings.getShowBSAOperators() EQ 1 AND OprResults_DisplayBSAOperatorID>
  							<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.bsa_operator_id#&nbsp;</TD>
						</cfif>
						<!---  D39828  :: Added BSA Operator id to Operator search and Results.... END --->
							<cfif OprResults_DisplayCity OR OprResults_DisplayState>
							<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">
							<cfset operatorOtherInfo = "#TheQuery.Operator_Zip#&nbsp;#Ucase(TheQuery.Operator_Country_Code)#<br>#TheQuery.Operator_Phone#">
							<cfif OprResults_DisplayCity AND OprResults_DisplayState>
								#TheQuery.Operator_City#<BR>#TheQuery.Operator_State#&nbsp;#operatorOtherInfo#
							<cfelseif OprResults_DisplayCity>
								#TheQuery.Operator_City#&nbsp;#operatorOtherInfo#
							<cfelseif OprResults_DisplayState>
								#TheQuery.Operator_State#&nbsp;#operatorOtherInfo#
							</cfif>
							</TD>
							</cfif>
							<cfif OprResults_DisplayLocationType>
							<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#(TheQuery.Operator_Location_Type eq 'NONE' ? 'None' : TheQuery.Operator_Location_Type)#&nbsp;</TD>
							</cfif>
							<!--- D42730 :: Operator Search Results - inside Programs
								<TD NOWRAP onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#numberformat(Replace(TheQuery.Operator_Number_Of_Locations,"-","","ALL"),'_,___,___')#&nbsp;</TD>
								<TD onClick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;">#TheQuery.Operator_DBA#&nbsp;</TD>
							--->
							<cfif OprResults_DisplayListPrograms>
							<TD onClick="NewWindow('operator_programs_list.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','925','600','Yes', 'Yes');return false;">view&nbsp;</TD>
							</cfif>
						</cfif>
	 				</TR>
				<!--- 	<cfflush> --->
				</CFOUTPUT>
				</TABLE>
				<HR COLOR="Orange" SIZE="2">
				<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">		
					<CF_Next_Previous_For_Forms
					formname="MyForm"
					query="TheQuery"
					record_count="#record_count#"
					maxpages="40"
					previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
					next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
					previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
					nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
					addparams="">
				</DIV>
				<HR COLOR="Orange" SIZE="2">
			</CFIF>
		</CFIF>
	<script language="javascript">
	function showstartingWith(sValue)
	{
		document.MyForm.Operator_Search_Name.value =sValue;
		doSearch();
	}
	</script>
	<tr>
		<TABLE CELLPADDING="2" CELLSPACING="1" BORDER="0" ALIGN="CENTER"><TR>
			<cfoutput>
			<cfloop index="LoopCount" from="65" to="90">
				<TD class="notranslate">
					<B>
				 <CFIF chr(LoopCount) EQ form.Operator_Search_Name>
					<FONT COLOR="FF0000">[</FONT>
				</CFIF>
					<A HREF="##" onClick="javaScript: return showstartingWith('#chr(LoopCount)#');">#chr(LoopCount)#</A>
				<CFIF chr(LoopCount) EQ form.Operator_Search_Name>
					<FONT COLOR="FF0000">]</FONT></CFIF>
					</B>
				</TD>
			</cfloop>
			<cfloop index="LoopCount" from="0" to="9">
				<TD>
					<B>
				 <CFIF LoopCount EQ form.Operator_Search_Name>
					<FONT COLOR="FF0000">[</FONT>
				 </CFIF>
					<A HREF="##" onClick="javaScript: return showstartingWith('#LoopCount#');">#LoopCount#</A>
				 <CFIF LoopCount EQ form.Operator_Search_Name>
					 <FONT COLOR="FF0000">]</FONT></CFIF>
					</B>
				</TD>
			</cfloop>
				<TD>
					<B>
				<CFIF "" EQ form.Operator_Search_Name>
					<FONT COLOR="FF0000">[</FONT>
				</CFIF>
				 <A HREF="##" onClick="javaScript: return showstartingWith('');">ALL</A>
				<CFIF "" EQ form.Operator_Search_Name>
					<FONT COLOR="FF0000">]</FONT></CFIF>
					</B>
				</TD>
	</cfoutput>
</TR></TABLE>
	</tr>
	</FIELDSET>
</CFIF>
</CFIF>
<!--- Dev Note: Milan:(Only for old (cf) operator search)--->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

 <!--- <CFPARAM name="TheQuery.totRows" default="0">  --->
<!--- Changing cfset to structInsert on TheQuery.Recordcount to handle for ColdFusion 2021 --->
<!---<cfset TheQuery.Recordcount = TheQuery.totRows>--->
<!---  <cfset structInsert(TheQuery,"Recordcount",varTotRows,true)> --->


<cfif varTotRows gt 0>

	<FIELDSET STYLE="padding:8px; width: 800; border: none;">
		<DIV ALIGN="center">
		<FONT SIZE="2">
			<B><FONT COLOR="#FF0000">[</FONT>
			<a HREF="#" onClick="importSelectedOperators()">
				import selected <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput>
			</a>
			<FONT COLOR="#FF0000">]</FONT></B>
		</FONT>
		<CFIF SelectSingleSearchResultOnly EQ 0>
			<FONT SIZE="2">
			<B><FONT COLOR="#FF0000">[</FONT>
			<cfif Revision_Settings_Allowed eq 1 AND RevisionStatus.Is_A_Revision eq 1 AND RevisionSettings.Operators_Added eq 2>
				<span style="color:gray">
					import all returned <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput>
				</span>
			<cfelse>
				<a HREF="#" STYLE="cursor: pointer;" onClick="importAllProducts(<CFOUTPUT>#varTotRows#</CFOUTPUT>)">
					import all returned <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput>
				</a>
			</cfif>
			<FONT COLOR="#FF0000">]</FONT></B>
			</FONT>
			<FONT SIZE="2">
				<B><FONT COLOR="#FF0000">[</FONT>
				<a HREF="#" STYLE="cursor: pointer;" onClick="removeAllOperators()">
					remove all selected <cfoutput>#lcase(application.returned_customer_setting.operator_label_plural)#</cfoutput>
				</a>
				<FONT COLOR="#FF0000">]</FONT></B>
			</FONT>
		</cfif>
		</DIV>
	</FIELDSET>

	<script>

		function importAllProducts(recordcount)
		{
			if(confirm("Do you want to import all " + recordcount + " records from your search?"))
			{
				processingPopUpDisplay('div.customContainer');
				/* true or false based on browser - IE 10 and above or IE 9 and below.
				'1' as an argument below means "true". */
				document.all.allbox.checked = checkOrUncheckBeforeFireEvent(1);
				callfireEvent(document,document.all.allbox,'Click');

				document.all.finishedselectingitems.value = 1;
				if(document.MyForm.FinalItemList.value.length > 0)
				{

					document.MyForm.FinalItemList.value = document.MyForm.FinalItemList.value + "," + "<CFOUTPUT>#valuelist(TheQuery.BSA_Operator_ID)#</CFOUTPUT>";
				}
				else
				{
					document.MyForm.FinalItemList.value 	= "<CFOUTPUT>#valuelist(TheQuery.BSA_Operator_ID)#</CFOUTPUT>";
				}
				document.MyForm.submit();
			}
		}

		function removeAllOperators()
		{
			processingPopUpDisplay('div.customContainer');
			document.MyForm.removeOperators.value = 1;
			document.all.finishedselectingitems.value = 1;
			document.MyForm.submit();
		}

	</script>

</cfif>

<SCRIPT>
	function saveoperators()
	{
		<cfif donotallowaddoperatorsDE EQ 1>
		if (confirm("Do you wish to Contine with the modification(s) you have made?   If you click Yes, then the existing date exclusion will be deleted and you will need to re-create a new date exclusion that captures your recent modification(s).If you click Cancel, then your modification will not be saved and you may submit your program for approal as it exists."))
		{
			document.all.deletedateexclusions.value = 1;
			document.all.finishedselectingitems.value = 1;
			 MyForm.submit();
		}
		else
		{

		}
		<cfelse>
			document.all.deletedateexclusions.value = 0;
			document.all.finishedselectingitems.value = 1;
			 MyForm.submit();
		</cfif>
	}

	function resetform() {
		document.all.LoadProductsFromThesePrograms.value = '';
		document.all.FinalItemList.value = 0;
		document.all.AlreadySelectedItems.value = 0;

		<CFIF varTotRows GT 0>
			document.all.SelectedITEMS.value = 0;
			for(var x=0; x<document.all.MyForm.elements.length;x++) {
				document.all.MyForm.elements[x].checked = false
			}

		</CFIF>
		document.all.MyForm.submit();
	}
</SCRIPT>

<cfoutput>

<INPUT TYPE="hidden" NAME="FinalItemList" VALUE="#Form.FinalItemList#">
<INPUT TYPE="hidden" NAME="AlreadySelectedItems" VALUE="#Form.AlreadySelectedItems#">
<INPUT TYPE="hidden" NAME="finishedselectingitems" VALUE="0">
<INPUT TYPE="hidden" NAME="deletedateexclusions" VALUE="0">
<INPUT TYPE="hidden" NAME="LoadSavedOperators" VALUE="0">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="LoadProductsFromThesePrograms"  		VALUE="#form.LoadProductsFromThesePrograms#">
<input type="Hidden" NAME="SelectSingleSearchResultOnly" 		VALUE="#SelectSingleSearchResultOnly#">
<input type="Hidden" NAME="removeOperators" value="0">
<INPUT TYPE="hidden" NAME="passed_form">     <!---30286--->
<INPUT TYPE="hidden" NAME="itemList">        <!---30286--->
</cfoutput>
</FORM>

</BLOCKQUOTE></BLOCKQUOTE>
<SCRIPT>
	//load the name of the select boxes to hide
	findselectboxes();
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- delete other section --->
<cfset opdisbro.CID = URL.CID>
<cfinclude template="delete_op_dis_bro_include.cfm">
<!--- delete other section --->
<cfif application.programlayout EQ 1></div></cfif>

<!--------------------------------------------------------------------------------------------------------------------->

<cffunction name="DisplayCreateList" output="true">
	<cfargument name="searchType" type="string" required="true" >   <!---either be operator_legacy_id or bsa_operator_id--->
	<b><font color="red">[</font>
	<font color="blue"><A HREF="javascript:void(0)"
					onclick="window.showModalDialog('/Common_Files/createList.cfm?passObj=#arguments.searchType#&passForm=MyForm&CID=#URL.CID#',window,'dialogHeight:375px;dialogWidth:350px;center:yes;edge:raised'); return false;" >create list</A>
	<font color="red">]</font></b>
</cffunction>

<!---
Determines search result column's visibility.
Go to "settings>application settings>Labels>Settings labels" to set visibility
--->
<cffunction name="showHideColumnsSetting" output="false">

	<cfset OprResults_DisplayCity = 0>
	<cfset OprResults_DisplayState = 0>
	<cfset OprResults_DisplayLocationType = 0>
	<cfset OprResults_DisplayBSAOperatorID = 0>
	<cfset OprResults_DisplayListPrograms = 0>
	<cfloop query="OprSearchResultsColumnsDisplayAdditionalSettings">
		<cfif field_name eq "City">
			<cfset OprResults_DisplayCity = 1>
		</cfif>
		<cfif field_name eq "State">
			<cfset OprResults_DisplayState = 1>
		</cfif>
		<cfif field_name eq "Location Type">
			<cfset OprResults_DisplayLocationType = 1>
		</cfif>
		<cfif field_name eq "BSA Operator ID">
			<cfset OprResults_DisplayBSAOperatorID = 1>
		</cfif>
		<cfif field_name eq "List Programs">
			<cfset OprResults_DisplayListPrograms = 1>
		</cfif>
	</cfloop>

</cffunction>


