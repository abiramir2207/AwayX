<cfsilent>
<!---
FILE:
FILENAME: 	billbacks/scorecard/billback_search_form.cfm
CREATED: 	??/??/???? - ???
EDITED:		12/02/2008 - RBL

FUNCTIONALITY:
- This template is a piece of the display billback search results puzzle...
--->
</cfsilent>

<!--------------------------------------------------------
Start Search Form
--------------------------------------------------------->
<cfparam name="Highlight" default="0">
<cfparam name="form.soldToNo" default="">
<cfparam name="form.operatorID" default="">
<cfparam name="form.vendorID" default="">
<cfparam name="form.vendorName" default="">

<!--- this is duplicitious but not sure where else it surfaces... RBL --->
<cfparam name="url.searchType" type="string" default="quick">

<style>
	select,input,td b
	{
		font-size : 10px;
		font-family:"Century Gothic", Verdana, Arial;
	}
	fieldset#border_9999 {
		margin: 0 auto !important;
		display: block !important;
	}
	form#SearchForm {
		width: 100%;
	}
</style>

<CFSET Layer_ID = 9999>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">

	var bNoPrevSearch = true;
	function showSearchResult(bchangeMode, pageNum)
	{
		document.SearchForm.startrow.value = pageNum;
		if(arguments.length > 2)
		{
			document.SearchForm.frompage.value = arguments[2];
		}
		var searchFormHideImg = document.all.image_<cfoutput>#Layer_ID#</cfoutput>;
		if(bchangeMode)
		{
			document.SearchForm.title.value = "";
			searchFormHideImg.click();
		}
		// document.all.image_<cfoutput>#Layer_ID#</cfoutput>.style.visibility="visible";
    document.all.legend_<cfoutput>#Layer_ID#</cfoutput>.style.visibility="visible";
		// statusHandler();
		processingPopUpDisplay('div.customContainer'); //D70951
		document.SearchForm.submit();
		bNoPrevSearch = false;
	}

	function payee_lookup_Pick(index,thisObj)
	{
		switch(index)
		{
			case 1:
				disableDiv("SP_Brokers",false,false);
				disableDiv("SP_Distributor",true,false);
				disableDiv("SP_Operator",true,false);
				break;
			case 2:
				disableDiv("SP_Brokers",true,false);
				disableDiv("SP_Distributor",false,false);
				disableDiv("SP_Operator",true,false);
				break;
			case 3:
				disableDiv("SP_Brokers",true,false);
				disableDiv("SP_Distributor",true,false);
				disableDiv("SP_Operator",false,false);
				break;
			default:
		}

	}

	function GTE_Operator(Op_Type,thisObj)
	{
		var spName;
		if(Op_Type == 1)
		{
			spName = "SP_Amount";
		}
		else if(Op_Type == 2)
		{
			spName = "SP_Date";
		}
		else if(Op_Type == 3)
		{
			spName = "SP_Start_Date";
		}
		else if (Op_Type == 4)
		{
			spName = "SP_End_Date";
		}
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv(spName,bDis,false);
	}

	function disable_Comparsion_Operators()
	{
		GTE_Operator(1,document.all.Amount_Operator);
		GTE_Operator(2,document.all.Date_Operator);
		GTE_Operator(3,document.all.Start_Date_Operator);
		GTE_Operator(4,document.all.End_Date_Operator);
		document.all.BB_Date.style.fontSize=10;
		document.all.Start_Date.style.fontSize=10;
		document.all.End_Date.style.fontSize=10;

		//payee_lookup_Pick(1);
	}


	function enterKeySearch()
	{
		showSearchResult(true, 1);
		<cfif listFindNoCase(CGI.SCRIPT_NAME,'billbacks','/')>
			document.all.headerTable.style.display = 'block';
		</cfif>
	}

	function disableSelect(sel1, sel2, findProperVal)
	{
		var selInd = 0;
		if(findProperVal)
		{
			selInd = Get_Select_Index(sel2, sel1.value);
			sel2.selectedIndex = selInd;
		}
		else
		{
			if(sel1.selectedIndex > 0)
			{
				sel2.selectedIndex = selInd;
			}
		}
		document.all.item("selectedUser").value = sel1.options[sel1.selectedIndex].label;
	}
	 document.body.onload=new Function ("disable_Comparsion_Operators();")
</SCRIPT>

<!--- SearchForm  ReturnBB --->

<CFPARAM NAME="FORM.Program_Status" DEFAULT="0">
<CFPARAM NAME="FORM.ProgramType" DEFAULT="0">
<CFPARAM NAME="FORM.Status" DEFAULT="0">
<CFPARAM NAME="FORM.Programs" DEFAULT="0">
<cfparam name="FORM.Payee_Filter" 	default="Broker">
<CFPARAM NAME="FORM.Broker_ID" DEFAULT="0">
<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
<cfparam name="FORM.Billback_Number" 	default="">
<cfparam name="FORM.Payable_Number" 	default="">
<cfparam name="FORM.payable_list" 	default="">
<CFPARAM NAME="FORM.Amount_Operator" DEFAULT="">
<cfparam name="FORM.Amount" 	default="">
<CFPARAM NAME="FORM.Date_Operator" DEFAULT="">
<cfparam name="FORM.BB_Date_Type" 	default="">
<cfparam name="FORM.BB_Date" 	default="">
<CFPARAM NAME="FORM.Start_Date_Operator" DEFAULT="">
<cfparam name="FORM.Start_Date" 	default="">
<CFPARAM NAME="FORM.Billback_Title" DEFAULT="">
<CFPARAM NAME="FORM.End_Date_Operator" DEFAULT="">
<cfparam name="FORM.End_Date" 	default="">
<cfparam name="FORM.BB_Aging" 	default=0>
<cfparam name="FORM.Deviated"	default=0>
<CFPARAM NAME="FORM.CURRENTBILLBACKLIST" default="">
<cfparam name="form.referenceNum" default="" />
<cfparam name="form.Search_Filter_Analyst_User_ID" default="" />
<cfparam name="FORM.Check_Number" 	default="">
<cfparam name="FORM.massPayBillbackList" default="">
<cfif Source IS "Deductions">
  <CFPARAM NAME="FORM.Deduction_ID" DEFAULT="#Deduction_ID#">
  <CFPARAM NAME="FORM.BB_Closing_Method" DEFAULT="2">
<CFELSE>
	<CFPARAM NAME="FORM.BB_Closing_Method" DEFAULT="">
</cfif>
<cfparam name="FORM.chk_duplicates" default="0" />
<cfparam name="FORM.chk_user_duplicates" default="0" />
<cfparam name="FORM.chk_opr_location_dup" default="0" />

<cfparam name="FORM.Item_Number" 	default="">
<cfparam name="FORM.Item_list" 	default="">
<cfparam name="FORM.billback_list" 	default="">
<cfparam name="FORM.reference_list" 	default="">
<cfparam name="FORM.program_list" 	default="">
<cfparam name="FORM.distributor_list" 	default="">
<cfparam name="FORM.operator_list" 	default="">
<cfparam name="FORM.operator_number_list" 	default="">
<cfparam name="FORM.vendor_list" 	default="">
<cfparam name="FORM.soldToNo_list" 	default="">
<cfparam name="FORM.match_type" 	default="">
<cfparam name="FORM.BB_Over_Budget" 	default="0">
<cfparam name="FORM.Program_Template" 	default="0">
<!---***************************************************************************************************************
TSF - Label 16253: Code to handle Billback Analyst search form
****************************************************************************************************************--->
<cfset oBillbackAssignmentManager = CreateObject("component", "components.billback.BillbackAssignmentManager") />
<cfset objSettingsService = createobject("component", "mvc.models.SettingsService") />
<cfset stBBLabels = objSettingsService.getBBLabels()>
<cfset qBillbackAnalysts = oBillbackAssignmentManager.getAnalysts(sortBy = "Name_Last") />
<cfset qGetBillbackAnalyst = oBillbackAssignmentManager.getAnalysts(analystUserId = request.AccessStructure.User_ID) />
<cfset bUserIsAnalyst = qGetBillbackAnalyst.RecordCount />
<cfif qGetBillbackAnalyst.RecordCount and not len(trim(form.Search_Filter_Analyst_User_ID)) and (qGetBillbackAnalyst.Is_Supervisor neq "1" AND qGetBillbackAnalyst.Is_Default_Supervisor neq "1") and Source neq "Deductions">
	<cfset form.Search_Filter_Analyst_User_ID = qGetBillbackAnalyst.Analyst_User_ID />
</cfif>

<cfset lGPSuppliedPosition = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) />
<cfset qHQPosition = CreateObject("component", "components.geography.position").getHQPosition() />

<cfset bHQUser = 0>
<cfif listcontains(lGPSuppliedPosition, qHQPosition.User_Positions_ID)>
	<cfset bHQUser = 1>
</cfif>

<cfset objSearchProgram  = CreateObject("component", "mvc.Models.Program.Search_Program")>
<cfset qTemplates = objSearchProgram.getAllTemplate()>
<CFSET GTE_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
<CFSET GTE_Operator_Symbols=" ,>=,=,<=">
<!--- 98106 :: Auto Deviations to consider if bb is beyond program budget START--->
<cfset useLakebaseForqGetToleranceSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_tolerance_settings")>
<cfif useLakebaseForqGetToleranceSettings>
	<cftry>
		<cfset qGetToleranceSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_tolerance_settings", {
				"select" = "autoprocess_check_bb_beyond_budget"
			}), "autoprocess_check_bb_beyond_budget"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetToleranceSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetToleranceSettings>
<CFQUERY NAME="qGetToleranceSettings" DATASOURCE="#Application.Datasource#">
	SELECT AutoProcess_Check_BB_Beyond_Budget
	FROM	Billback_Tolerance_Settings
</CFQUERY>
</cfif>
<!--- 98106 :: Auto Deviations to consider if bb is beyond program budget END--->
<cfif Source IS "Deductions">
	<!--- 17294 ? --->
	<FORM STYLE="margin-bottom: 0px;margin-top: 0px;" ACTION="/deductions/search_screens/billbacks.cfm?searched=1" METHOD="post" NAME="SearchForm" ID="SearchForm" >
		<CFOUTPUT>
			<input type="hidden" name="source" value="#source#">
			<input type="hidden" name="selectedItemValue" value="#form.selectedItemValue#">
		</CFOUTPUT>

<cfelse>

	<cfoutput>
			<FORM STYLE="margin-bottom: 0px;margin-top: 0px;" ACTION="/billbacks/scorecard/billback_Search_Result.cfm#form.IFRAME_Extra_URL#&searched=1&Type_search=#url.Type_search#" METHOD="post" NAME="SearchForm" ID="SearchForm" TARGET="Search_Result">
			<input type="hidden" name="source" value="search">
	</cfoutput>
</cfif>


	<cfoutput>
		<input type="hidden" name="payable_list" value="#form.payable_list#">
		<input type="hidden" name="soldToNo_list" value="#form.soldToNo_list#">
		<input type="hidden" name="Item_list" value="#form.Item_list#">
		<input type="hidden" name="billback_list" value="#form.billback_list#">
		<input type="hidden" name="reference_list" value="#form.reference_list#">
		<input type="hidden" name="program_list" value="#form.program_list#">
		<input type="hidden" name="distributor_list" value="#form.distributor_list#">
		<input type="hidden" name="operator_list" value="#form.operator_list#">
		<input type="hidden" name="operator_number_list" value="#form.operator_number_list#">
		<input type="hidden" name="vendor_list" value="#form.vendor_list#">
		<input type="hidden" name="match_type" value="#form.match_type#">
		<input type="hidden" name="currentBillbackList" value="#form.currentBillbackList#">
		<input type="hidden" name="massPayBillbackList" value="#form.massPayBillbackList#">
	</cfoutput>


<CFSCRIPT>
	Border="Yes";
	BorderSize=0;
	BorderColor="";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy";
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="No";
	WIDTH="1250px";
</CFSCRIPT>
<!--- 14479 (RBL) 01/24/08 [begin] {added #uCase(url.searchType)#} --->
<!--- 17544 testing correction [begin] --->
<cfif listFindNoCase(CGI.SCRIPT_NAME,'billbacks','/')>
	<cfset variables.bInitiallyVisible = 0>
<cfelse>
	<cfset variables.bInitiallyVisible = 1>
</cfif>
<CF_openLayer
	bEnabled="#variables.bInitiallyVisible#"
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Hide Billback #uCase(url.searchType)# Search Form"
	TitleClosed="Show Billback #uCase(url.searchType)# Search Form"
	TitleTooltip="Click here to toggle the view"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#"
  layerid="#Layer_ID#">
  <!--- 14479 (RBL) 01/24/08 [end] {added #uCase(url.searchType)#} --->

	<style>
		.sectionHead
			{
				font-weight:bold;
				font-size:15px;
				color:red;
				border-bottom:2px solid #0000CD;
			}
		table#t413 {
			width:100%;
		}
		table#t413 tr {
			line-height: 22px;
		}
		.full {
			width:98%;
		}
		a#createlist13 { margin-left: 10px; }
	</style>

	<table border="0" cellspacing="5" <cfif url.searchType EQ "quick">cellpadding="7"</cfif> bgcolor="WhiteSmoke" id="t413">

  	<!--- ============================== QUICK SEARCH [begin] ============================== --->
    <cfif url.searchType EQ "quick">
    	<col width="20%">
    	<col width="20%">
    	<col width="20%">
    	<col width="20%">
    	<col width="20%">
	<cfoutput>

  	<!--- I.) Quick Search > Billback Section [begin] --->
		<tr>
    		<td colspan="5" class="sectionHead">Billback</td>
		</tr>
		<tr>
    	<!--- 1.) BA Payable Number --->
    		<td>
				<b>#stBBLabels.Payable# ##</b><a href="javascript: createList2('Payable')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" name="Payable_Number" ID="Payable_Number" value="#FORM.Payable_Number#" class="full" onkeydown="if (event.keyCode == 13) enterKeySearch();">
			</td>
      <!--- 2.) Billback Number --->
      		<td>
				<b>#stBBLabels.Billback# ##</b><a  href="javascript: createList2('Billback')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" name="Billback_Number" ID="Billback_Number" value="#FORM.Billback_Number#" class="full" 	onkeydown="if (event.keyCode == 13) enterKeySearch();">
			</td>
      <!--- 3.) Status --->
      <td><cfset showStatus()></td>
      <!--- 4.) Closing Method --->
      <td>
           <!-----------------------------------------------------------------------------
            Dev Notes: D18281 - Solo - Add new closing method on billback entry
          	All the closing method dropdown and values now come from the DB based on
            the settings in the settings panel
            -Anand Rao/29-May-09
          ------------------------------------------------------------------------------>
        <cfquery NAME="getClosingMethods" datasource="#application.datasource#">
  SELECT  iBillback_Closing_Method_ID,
        	vchBillback_Closing_Method_Desc,
        	bEnabled,
      	  tiAutoPay_BB_Status,
      	  Deleted,
      	  Abbreviation
  FROM  Billback_Closing_Methods WHERE Deleted = 0
  <cfif (Source EQ "Deductions")>
    AND iBillback_Closing_Method_ID IN (1,2,5)
  </cfif>
  AND bEnabled = 1
  ORDER BY vchBillback_Closing_Method_Desc
</cfquery>
		      	<b>Closing Methods</b><br>
              <select name="BB_Closing_Method"  class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
              <option value="">**All** Closing Methods</option>
              <cfloop query="getClosingMethods">
              <option value="#getClosingMethods.iBillback_Closing_Method_ID#" <cfif FORM.BB_Closing_Method EQ getClosingMethods.iBillback_Closing_Method_ID>selected</cfif>>#getClosingMethods.vchBillback_Closing_Method_Desc#</option>
           </cfloop>
          </select>
			</td>
      <!--- 5.) Program Number --->
      <td>
      	<b>Program Number</b><a  href="javascript: createList2('Program')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<cfparam name="FORM.Contract_Number" 	default="">
				<input type="Text" name="Contract_Number" class="full" size="64" value="#trim(FORM.Contract_Number)#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
			</td>
		</tr>
		<!---TSF - Label 16253: Only display analyst dropdown if its on in the profile settings and the search is not coming from Deductions--->
		<cfif Source neq "Deductions">
			<cfif Get_Profile_Settings.BB_Search_By_Analyst or (bHQUser and not bUserIsAnalyst)>
				<tr>
				<!--- 6.) Billback Analyst --->
					<td>
						<b>Billback Analyst</b><br>
						<select name="Search_Filter_Analyst_User_ID" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
							<option value="0">Any Analyst</option>
							<cfloop query="qBillbackAnalysts">
								<OPTION VALUE="#Analyst_User_ID#" <cfif form.Search_Filter_Analyst_User_ID eq Analyst_User_ID>selected</cfif>>#Name_First# #Name_Last#</OPTION>
							</cfloop>
						</select>
					</td>
                    <!--- D17544 RBL 11/17/08 [begin] --->
					<!--- 7.) Title --->
                    <td colspan="2">
                    <b>Title</b><br>
                            <input type="Text" name="Billback_Title" class="full" size="64" value="#trim(FORM.Billback_Title)#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
                    </td>
                    <!--- D17544 RBL 11/17/08 [end] --->
				</tr>
			</cfif>
		</cfif>
	<!---
		D39812: Validate EDI files for potential billback duplicate/Anand Rao/12-Feb-2014
		Added a new field in the Billback Search for searching on the Duplicates.
	--->
	<tr>
		<cfset useLakebaseForgetBBSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForgetBBSettings>
	<cftry>
		<cfset getBBSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "enable_bb_dup_check"
			}), "enable_bb_dup_check"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBBSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBBSettings>
<cfquery name="getBBSettings" datasource="#application.datasource#">
			SELECT 	Enable_BB_Dup_Check
            FROM 		Billback_Settings
        </cfquery>
</cfif>
		<cfif (getBBSettings.Enable_BB_Dup_Check EQ 1)>

				<td >
					<strong>EDI Duplicates</strong> <input type="checkbox" name="chk_duplicates" value="1" <cfif Form.chk_duplicates eq "1">checked</cfif>><br><br>
				</td>

		</cfif>

			<td>
				<strong>User  Duplicates</strong> <input type="checkbox" name="chk_user_duplicates" value="1" <cfif Form.chk_user_duplicates eq "1">checked</cfif>><br><br>
			</td>
			<cfif (appSettings.get_Setting('BB_Oper_Location_Level_Dup_Checker') EQ 1)>
				<td>
					<strong>Operator Location Duplicates</strong> <input type="checkbox" name="chk_opr_location_dup" value="1" <cfif Form.chk_opr_location_dup eq "1">checked</cfif>><br><br>
				</td>
			</cfif>
		<!--- 98106 :: Auto Deviations to consider if bb is beyond program budget START--->
		<cfif qGetToleranceSettings.AutoProcess_Check_BB_Beyond_Budget>
			<td colspan="2" valign="top">
				<strong>Show Billback's In RFA Due To Over Budget</strong> <input type="checkbox" name="BB_Over_Budget" value="1" <cfif Form.BB_Over_Budget eq "1">checked</cfif>>
			</td>
		</cfif>
		<!--- 98106 :: Auto Deviations to consider if bb is beyond program budget END--->
		</tr>


    <!--- I.) Quick Search > Billback Section [end] --->

    <!--- II.) Quick Search > Customer Section [begin] --->
		<tr>
    	<td colspan="5" class="sectionHead">Customer</td>
		</tr>
		<tr>
    	<!--- 1.) Distributor Name aka customer --->
    	<td>
      	<b>#application.returned_customer_setting.distributor_label_singular# Name</b><a  href="javascript: createList2('Distributor')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
		<!--- BJF 19297 -- if app setting DD - Restrict Ship To for Billbacks is 1, then do not allow user to change distributor name --->
			<!--- If coming from deduction and app setting high --->
			<cfif Highlight IS 1 AND appSettings.getDD_Restrict_ShipTo_For_BB() IS 1>
				<input type="hidden" name="Distributor_Name" ID="Distributor_Name" value="#FORM.Distributor_Name#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
				#FORM.Distributor_Name#
			<!--- Not in deduction or app setting low --->
			<cfelse>
				<input type="text" name="Distributor_Name" class="full" ID="Distributor_Name" value="#FORM.Distributor_Name#" <cfif Highlight IS 1>style="background: lightsteelblue;"</cfif>  onkeydown="if (event.keyCode == 13) enterKeySearch();">
    		</cfif>
	 </td>
      <!--- 2.) Ship To --->
      <td colspan="2">
      	<b>#application.returned_customer_setting.Shard_Ship_To_Label#</b><a  href="javascript: createList2('soldToNo')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" name="soldToNo" ID="soldToNo" value="#form.soldToNo#" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
      <!--- 3.) Operator Name --->
      <td>
      	<b>#application.returned_customer_setting.operator_label_singular# Name</b><a  href="javascript: createList2('Operator')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" class="full" name="Operator_Name" ID="Operator_Name" value="#FORM.Operator_Name#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
      <!--- 4.) Operator Number --->
      <td>
      	<span ID="searchItemLabel"><B>#application.returned_customer_setting.operator_label_singular# ##</B></span><a  href="javascript: createList2('OperatorNumber')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" class="full" name="operatorID" ID="operatorID" value="#FORM.operatorID#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
    </tr>
    <!--- II.) Quick Search > Customer Section [end] --->

			<!--- it appears we default all to empty strings '', even numbers... --->
      <input type="hidden" name="BB_Date" value="" />
      <input type="hidden" name="Start_Date" value="" />
      <input type="hidden" name="End_Date" value="" />
      <input type="hidden" name="referenceNum" value="" />
      <input type="hidden" name="BB_Date_Type" value="" />
      <input type="hidden" name="Date_Operator" value="" />
      <input type="hidden" name="Start_Date_Operator" value="" />
      <input type="hidden" name="End_Date_Operator" value="" />
      <input type="hidden" name="Amount_Operator" value="" />
      <input type="hidden" name="Amount" value="" />
      <input type="hidden" name="BB_Aging" value="" />
      <input type="hidden" name="Deviated" value="" />
      <input type="hidden" name="Broker_ID" value="" />
      <input type="hidden" name="Program_Status" value="" />
      <input type="hidden" name="Generic_Type" value="" />
      <input type="hidden" name="Billback_Title" value="" />
      <input type="hidden" name="Discount_Identifier" value="" />
      <input type="hidden" name="PP_User_ID" value="" />
      <input type="hidden" name="Include_Eligible_Programs" value="" />
      <input type="hidden" name="vendorID" value="" />
      <input type="hidden" name="User_Position_Operator" value="" />
      <input type="hidden" name="User_Position_Of" value="" />
      <input type="hidden" name="chk_duplicates" value="" />
      <input type="hidden" name="chk_user_duplicates" value="" />
			<input type="hidden" name="chk_opr_location_dup" value="" />
			<input type="hidden" name="BB_Over_Budget" value="" /><!---98106--->

      <!--- ============================== QUICK SEARCH [end] ============================== --->

    <!--- ============================== ADVANCED SEARCH [begin] ============================== --->

</cfoutput>
    <cfelseif searchType EQ "advanced">
<cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1.2, 1, 1.35, 1, 1.2] )>
<cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
</cfloop>
<cfoutput>

    <!--- I.) Advanced Search > Billback Section [begin] --->
		<tr>
    	<td colspan="5" class="sectionHead">Billback</td>
		</tr>
    <tr>
    	<!--- 1.) BA Payable Number --->
    	<td>
				<b>#stBBLabels.Payable# ##</b><a  href="javascript: createList2('Payable')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" name="Payable_Number" ID="Payable_Number" value="#FORM.Payable_Number#" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
			</td>
      <!--- 2.) Billback Number --->
      <td>
				<b>#stBBLabels.Billback# ##</b><a  href="javascript: createList2('Billback')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" name="Billback_Number" ID="Billback_Number" value="#FORM.Billback_Number#" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
			</td>
      <!--- 3.) Status --->
      <td>
        <cfset showStatus()>
 	  </td>
      <!--- 4.) Closing Method --->
      <td>
           <!-----------------------------------------------------------------------------
            Dev Notes: 21980/Anand Rao/12-Jan-10
            This change was not made for the Advanced search which is being done now.
            So Advanced search and Quick search will now show the same options in the
            closing method.
            ---------------------------------------------------------------------------
            Dev Notes: D18281 - Solo - Add new closing method on billback entry
          	All the closing method dropdown and values now come from the DB based on
            the settings in the settings panel
            -Anand Rao/29-May-09
          ------------------------------------------------------------------------------>
				<cfquery NAME="getClosingMethods" datasource="#application.datasource#">
					SELECT  iBillback_Closing_Method_ID,
					  	vchBillback_Closing_Method_Desc,
					  	bEnabled,
						  tiAutoPay_BB_Status,
						  Deleted,
						  Abbreviation
					FROM  Billback_Closing_Methods WHERE Deleted = 0
					<cfif (Source EQ "Deductions")>
					AND iBillback_Closing_Method_ID IN (1,2,5)
					</cfif>
					AND bEnabled = 1
					ORDER BY vchBillback_Closing_Method_Desc
				</cfquery>
      	<b>Closing Methods</b><br>
         <select name="BB_Closing_Method"  class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
              <option value="">**All** Closing Methods</option>
              <cfloop query="getClosingMethods">
              <option value="#getClosingMethods.iBillback_Closing_Method_ID#" <cfif FORM.BB_Closing_Method EQ getClosingMethods.iBillback_Closing_Method_ID>selected</cfif>>#getClosingMethods.vchBillback_Closing_Method_Desc#</option>
           </cfloop>
          </select>

			</td>
      <!--- 5.) Program Number --->
			<td>
      	<b>Program Number</b><a  href="javascript: createList2('Program')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<cfparam name="FORM.Contract_Number" 	default="">
				<input type="Text" name="Contract_Number" class="full" size="64" value="#trim(FORM.Contract_Number)#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
			</td>
		</tr>
    <tr>
    	<!--- 6.) Deviated/Billback Analyst --->
    	<td>
			<!---TSF - Label 16253: Only display analyst dropdown if its on in the profile settings and the search is not coming from Deductions--->
			<cfif Source neq "Deductions">
				<cfif Get_Profile_Settings.BB_Search_By_Analyst or (bHQUser and not bUserIsAnalyst) >
					<b>Billback Analyst</b><br>
					<select name="Search_Filter_Analyst_User_ID"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
						<option value="0">Any Analysts</option>
						<cfloop query="qBillbackAnalysts">
							<OPTION VALUE="#Analyst_User_ID#" <cfif form.Search_Filter_Analyst_User_ID eq Analyst_User_ID>selected</cfif>>#Name_First# #Name_Last#</OPTION>
						</cfloop>
					</select>
				</cfif>
			</cfif>
      		<input type="checkbox" ID="Deviated" name="Deviated" value="1"<cfif FORM.Deviated> checked</cfif>>&nbsp;<b>Deviated</b>
      </td>
      <!--- 7.) Title --->
      <td>
      	<b>Title</b><br>
				<input type="Text" name="Billback_Title" class="full" size="64" value="#trim(FORM.Billback_Title)#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
      <!--- 8.) Date [moved] --->
      <td>
      	<cfsilent>
          <cfset useLakebaseForGet_Billback_Dates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_date_type")>
<cfif useLakebaseForGet_Billback_Dates>
	<cftry>
		<cfset Get_Billback_Dates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_date_type", {
				"deleted" = "eq.0",
				"select" = "bb_date_type,bb_date_field"
			}), "bb_date_type,bb_date_field"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Billback_Dates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Billback_Dates>
<cfquery NAME="Get_Billback_Dates" datasource="#application.datasource#">
            SELECT BB_Date_Type,BB_Date_Field
            FROM 	BB_Date_Type
            WHERE Deleted = 0
          </cfquery>
</cfif>
        </cfsilent>
	<table cellpadding="1" cellspacing="0" border="0" width="100%">
          <tr>
            <td>
              <b>Date</b><br>
              <select name="BB_Date_Type" style="width:60%"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
                <cfloop query="Get_Billback_Dates">
                  <option value="#trim(BB_Date_Field)#"#IIF(trim(FORM.BB_Date_Type) EQ BB_Date_Field, DE(" SELECTED"), DE(""))#>#trim(BB_Date_Type)#</option>
                </cfloop>
              </select>
              <select OnChange="JavaScript: GTE_Operator(2,this);" name="Date_Operator" ID="Date_Operator" style="width:30%">
                <cfset cnt=0>
                <cfloop list="#GTE_Operators#" index="thisOperator">
                  <cfset cnt=cnt+1>
                  <option value="#Trim(thisOperator)#"<cfif FORM.Date_Operator EQ Trim(thisOperator)> selected</cfif>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</option>
                </cfloop>
              </select>
            </td>
            <td valign="bottom" width="120"> <br>
              <span ID="SP_Date">
                <cf_easydate formname="SearchForm" fieldname="BB_Date" format="mm/dd/yyyy" default="#FORM.BB_Date#">
              </span>
            </td>
          </tr>
	</table>
      </td>
      <!--- 9.) Start Date [moved] --->
      <td>
      	<table cellpadding="2" cellspacing="0" border="0">
      		<tr>
      			<td>
				<b>Start Date</b><br>
              <select OnChange="JavaScript: GTE_Operator(3,this);" name="Start_Date_Operator" ID="Start_Date_Operator" style="width:50px"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
                <cfset cnt=0>
                <cfloop list="#GTE_Operators#" index="thisOperator">
                  <cfset cnt=cnt+1>
                  <option value="#Trim(thisOperator)#"<CFIF FORM.Start_Date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</option>
                </cfloop>
              </select>
						</td>
						<td valign="bottom"><br>
              <span ID="SP_Start_Date">
              	<cf_easydate formname="SearchForm" fieldname="Start_Date" format="mm/dd/yyyy" default="#FORM.Start_Date#">
              </span>
						</td>
					</tr>
				</table>
      </td>
      <!--- 10.) End Date [moved] --->
    	<td>
      	<table cellpadding="2" cellspacing="0" border="0">
      		<tr>
      			<td>
				<b>End Date</b><br>
              <select OnChange="JavaScript: GTE_Operator(4,this);" name="End_Date_Operator" ID="End_Date_Operator" style="width:50px"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
                <cfset cnt=0>
                <cfloop LIST="#GTE_Operators#" index="thisOperator">
                  <cfset cnt=cnt+1>
                  <option value="#Trim(thisOperator)#"<cfif FORM.End_Date_Operator EQ Trim(thisOperator)> selected</cfif>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</option>
                </cfloop>
              </select>
            </td>
                <td valign="bottom"><br>
                  <span ID="SP_End_Date">
										<cf_easydate formname="SearchForm" fieldname="End_Date" format="mm/dd/yyyy" default="#FORM.End_Date#">
									</span>
								</td>
						</tr>
					</table>
      </td>
    </tr>
    <tr>
    	<!--- 11.) Reference No. [moved] --->
      <td>
      	<b>Reference Number</b><a  href="javascript: createList2('Reference')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="Text" name="referenceNum" class="full" size="64" value="#trim(FORM.referenceNum)#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
      <!--- 12.) Claimed Amount --->
      <td>
      	<b>Claimed Amount</b><br>
				<cfif Source IS "Deductions">
          <input type="hidden" name="Amount_Operator" value="LIKE">&nbsp; &nbsp; &nbsp; &nbsp;
        <cfelse>
          <select OnChange="JavaScript: GTE_Operator(1,this);" name="Amount_Operator" ID="Amount_Operator" style="width:60px"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
            <cfset cnt=0>
            <cfloop LIST="#GTE_Operators#" index="thisOperator">
              <cfset cnt=cnt+1>
              <option value="#Trim(thisOperator)#"<cfif FORM.Amount_Operator EQ Trim(thisOperator)> selected</cfif>>#Trim(ListGetAt(GTE_Operator_Symbols,cnt))#</option>
            </cfloop>
          </select>
        </cfif>
				<span ID="SP_Amount">
					<input type="TEXT" ID="Amount" name="Amount" value="#FORM.Amount#" style="width:90px"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
				</span>
      </td>
      <!--- 13.) Template --->
      <td>
      	<b>Program Template</b><br>
				<select name="Program_Template" onkeydown="if (event.keyCode == 13) enterKeySearch();" class="multi" multiple="multiple">
					<cfloop query="qTemplates">
                <option value="#qTemplates.First_Parent_ID#"<cfif FORM.Program_Template EQ qTemplates.First_Parent_ID> selected</cfif>>#qTemplates.Created_Type#</option>
					</cfloop>
				</select>
      </td>
      <!--- 14.) Program Status --->
      <td>
      	<cfsilent>
          <cfquery name="Get_Status" datasource="#application.datasource#">
            SELECT		Contract_Status_Type_ID,Contract_Status_Type_Desc
            FROM 			Contract_Status_Types
            WHERE			Contract_Status_Type_ID > 3
            ORDER BY 	Contract_Status_Type_ID
          </cfquery>
        </cfsilent>
      	<b>Program Status</b><br>
				<select name="Program_Status" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
					<option value="0">**ALL** Status</option>
					<cfloop query="Get_Status">
          	<option value="#trim(Get_Status.Contract_Status_Type_ID)#"#IIF(trim(FORM.Program_Status) EQ Get_Status.Contract_Status_Type_ID, DE(" SELECTED"), DE(""))#>#trim(Get_Status.Contract_Status_Type_Desc)#</option>
          </cfloop>
				</select>
      </td>
      <!--- 15.) Program Generic Type --->
      <td>
      	<b>Program Generic Type</b><br>
				<cfparam name="FORM.Generic_Type" default="0">
        <cfsilent>
          <cfquery name="Get_Generic_Types" datasource="#application.datasource#">
          SELECT		Generic_Type
          FROM 			Generic_Type
          WHERE 		0 = 0
          <cfif appSettings.getDisplayDistributorOffInvoice() EQ 0>
            AND 		Generic_Type !='Distributor Off-Invoice'
          </cfif>
          <cfif appSettings.getDisplayProposal() EQ 0>
            AND 		Generic_Type !='Bid Request'
          </cfif>
          <cfif appSettings.getDisplayUSDANOI() EQ 0>
            AND 		Generic_Type !='USDA NOI'
          </cfif>
          ORDER BY 	Generic_Type
          </cfquery>
        </cfsilent>
				<select name="Generic_Type" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
					<option value="0">**ALL** Generic Type</option>
					<cfloop query="Get_Generic_Types">
          	<option value="#trim(Generic_Type)#"#IIF(trim(FORM.Generic_Type) EQ Generic_Type, DE(" SELECTED"), DE(""))#>#trim(ReReplaceNoCase(Generic_Type, "trade", application.returned_customer_setting.Trade_Label))#</option>
          </cfloop>
				</select>
      </td>
    </tr>
    <tr>
    	<!--- 16.) Discount Identifier --->
    	<td>
      	<cfset discountIdentifierManager = CreateObject("component","components.programs.discount_identifier.discountidentifier")>
				<cfif discountIdentifierManager.discountIdentifierOn()>
					<b>Discount Identifier</b><br>
					<cfparam name="FORM.Discount_Identifier" default="0">
					<cfset qDiscountIdentifiers = discountIdentifierManager.getActive()>
					<select name="Discount_Identifier" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
						<option value="0">**ALL** Discount Identifier</option>
						<cfloop query="qDiscountIdentifiers">
							<option value="#trim(Discount_Identifier_ID)#"#IIF(trim(FORM.Discount_Identifier) EQ Discount_Identifier_ID, DE(" SELECTED"), DE(""))#>
								#trim(Discount_Identifier_Desc)#
							</option>
						</cfloop>
					</select>
				<cfelse>
					&nbsp;
				</cfif>
      </td>
      <!--- 17.) Include Eligible Programs --->
      <td>

     	<!------ Payee search options ----->
		<b>Search Options</b>
	<cf_SmallHelp
		width="360">
          <table>
          	<tr>
            	<td colspan="3" nowrap>The search options will affect how the following fields are searched</td>
            </tr>
          	<tr>
          		<td nowrap><li>#application.returned_customer_setting.broker_label_singular#</li></td>
          		<td nowrap><li>#application.returned_customer_setting.distributor_label_singular#</li></td>
          		<td nowrap><li>#application.returned_customer_setting.operator_label_singular#</li></td>
          	</tr>
          </table>
        </cf_SmallHelp>
		<br />
		<input type="checkbox" value="1" name="Include_Eligible_Programs">&nbsp;<b>Include eligible programs</b>
      </td>
      <!--- 18.) Uploaded Billbacks --->
      <td>
      <cfset oBillbackTypeLabelSettings = createObject("component", "components.billback.BillbackSettingsManager") />
      <cfset qGetBBUploadedTypeLabels 	    = oBillbackTypeLabelSettings.getBBUploadedTypeLabels() />

      	<b>Type:</b><br>
				<select name="Uploaded_Billback" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
					<option value="0" selected>**ALL** payable</option>
          <option value="MANUAL">#qGetBBUploadedTypeLabels.Manual_BB_Label#</option>
					<option value="UPLOADED">#qGetBBUploadedTypeLabels.Uploaded_Via_App_Label#<!--- User ---></option>
					<option value="BATCH">#qGetBBUploadedTypeLabels.Batch_Interface_Label#<!--- Auto ---></option>
          <option value="AUTOPAY">#qGetBBUploadedTypeLabels.Auto_Pay_Label#</option>
          <option value="AUTOAPPROVED">#qGetBBUploadedTypeLabels.Auto_Approved_Label#</option>
					<option value="QUICKPAY">Quick Pay</option>
				</select>
      </td>
	  	<td>
			<b>Check ##</b><br>
			<input type="text" name="Check_Number" ID="Check_Number" value="#FORM.Billback_Number#" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
		</td>
		<td>
			<b>Item ##</b><a href="javascript: createList2('Item')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
			<cfparam name="FORM.Item_Number" 	default="">
			<input type="Text" name="Item_Number" class="full" value="#trim(FORM.Item_Number)#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
		</td>
	</tr>
	<tr>
		      <!--- Aging --->
					<td>
						<b>Aging</b><br>
						<select name="BB_Aging" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
							<option value="0">**ALL** Billbacks</OPTION>
							<option value="1"<cfif FORM.BB_Aging EQ 1> selected</cfif>>Aging Billbacks</option>
							<option value="2"<cfif FORM.BB_Aging EQ 2> selected</cfif>>Not Aging Billbacks</option>
						</select>
					</td>
		<!---
		D39812: Validate EDI files for potential billback duplicate/Anand Rao/12-Feb-2014
		Added a new field in the Billback Search for searching on the Duplicates.
		--->
		<cfquery name="getBBSettings" datasource="#application.datasource#">
			SELECT 	Enable_BB_Dup_Check
            FROM 		Billback_Settings
        </cfquery>

		<cfif (getBBSettings.Enable_BB_Dup_Check EQ 1)>
			<td><br>
				<strong>EDI Duplicates</strong> <input type="checkbox" name="chk_duplicates" value="1" <cfif Form.chk_duplicates eq "1">checked</cfif>>
			</td>
		</cfif>

		<td><br>
			<strong>User Duplicates</strong> <input type="checkbox" name="chk_user_duplicates" value="1" <cfif Form.chk_user_duplicates eq "1">checked</cfif>>
		</td>

		<!--- 98106 :: Auto Deviations to consider if bb is beyond program budget START--->
		<cfif qGetToleranceSettings.AutoProcess_Check_BB_Beyond_Budget>
		<td colspan="2">
			<strong>Show Billback's In RFA Due To Over Budget</strong> <input type="checkbox" name="BB_Over_Budget" value="1" <cfif Form.BB_Over_Budget eq "1">checked</cfif>>
		</td>
		</cfif>
		<!--- 98106 :: Auto Deviations to consider if bb is beyond program budget END--->

    </tr>
    <!--- I.) Advanced Search > Billback Section [end] --->

    <!--- II.) Advanced Search > Customer Section [begin] --->
		<tr>
    	<td colspan="5" class="sectionHead">Customer</td>
		</tr>
    <tr>
    	<!--- 1.) Distributor Name aka customer --->
    	<td>
      	<b>#application.returned_customer_setting.distributor_label_singular# Name</b><a  href="javascript: createList2('Distributor')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
			<input type="text" name="Distributor_Name" ID="Distributor_Name" value="#FORM.Distributor_Name#" class="full" <cfif Highlight IS 1>style="background: lightsteelblue;"</cfif>  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
      <!--- 2.) Ship To --->
      <td>
      	<b>#application.returned_customer_setting.Shard_Ship_To_Label#</b><a  href="javascript: createList2('soldToNo')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" class="full" name="soldToNo" ID="soldToNo" value="#form.soldToNo#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
      <!--- 3.) Operator Name --->
      <td>
      	<b>#application.returned_customer_setting.operator_label_singular# Name</b><a  href="javascript: createList2('Operator')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" class="full" name="Operator_Name" ID="Operator_Name" value="#FORM.Operator_Name#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
      <!--- 4.) Operator Number --->
      <td>
      	<span ID="searchItemLabel"><B>#application.returned_customer_setting.operator_label_singular# ##</B></span><a  href="javascript: createList2('OperatorNumber')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" class="full" name="operatorID" ID="operatorID" value="#FORM.operatorID#"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
      <!--- 5.) Broker --->
      <td>
      	<cfsilent>
        	<cfquery name="GetBrokers" datasource="#application.datasource#">
            SELECT BSA_Foodservice_Brokers_ID, Broker_Name
            FROM broker_active
            WHERE len(Broker_Name) > 0
            ORDER BY Broker_Name
          </cfquery>
        </cfsilent>
      	<b>#application.returned_customer_setting.broker_label_singular#</b><br>
		<cfset BrokerIDList = "">
</cfoutput>
        <select name="Broker_ID" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
          <option value="0">**ALL** <cfoutput>#application.returned_customer_setting.broker_label_plural#</cfoutput></option>
				<!--- GROUP BROKERS BY NAME TO DISPLAY THEM ONLY ONCE IN THE SEARCH TOOL --->
				<CFOUTPUT QUERY="GetBrokers" group="Broker_Name">
					<!--- CREATE LIST OF ID'S THAT SHARE A COMMON BROKER NAME FOR USING IN THE SEARCH QUERY --->
					<cfoutput>
						<cfset BrokerIDList = listAppend(BrokerIDList,trim(GetBrokers.BSA_Foodservice_Brokers_ID))>
					</cfoutput>
					<OPTION VALUE="#BrokerIDList#" <cfif BrokerIDList EQ FORM.Broker_ID>SELECTED</cfif>>
						#trim(GetBrokers.Broker_Name)#
					</OPTION>
					<!--- CLEAR IDLIST VARIABLE TO ALLOW CREATION OF A NEW LIST FOR THE NEXT BROKER NAME IN THE LOOP --->
					<cfset BrokerIDList = "">
				</CFOUTPUT>
        </select>
      </td>
    </tr>
<cfoutput>
    <tr>
    	<!--- 6.) vendor id --->
    	<td colspan="1">
      	<b>Vendor Name</b><br>
				<input type="text" id="vendorName" name="vendorName" value="#form.vendorName#" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
    	<td colspan="1">
      	<b>Vendor ID</b><a  href="javascript: createList2('VendorID')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a><br>
				<input type="text" id="vendorID" name="vendorID" value="#form.vendorID#" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
      </td>
    </tr>
    <!--- II.) Advanced Search > Customer Section [end] --->

    <!--- III.) Advanced Search > Ownership Section [begin] --->
		<tr>
    	<td colspan="5" class="sectionHead">Ownership</td>
		</tr>
    <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
		<cfset userPositionManager = CreateObject("component", "components.general.UserPositionManager").init() />
			<!--- <cfif NOT appSettings.getDistributorMultiPosition()> --->
        <tr>
          <!--- 1.) Billback --->
          <td colspan="2">
            <cfset User_Position_Operator_List = "Created By, Requesting Approval By,Approved By" />
            <b>Billback</b><br>
            <select ID="User_Position_Operator" name="User_Position_Operator" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
              <cfloop LIST="#User_Position_Operator_List#" index="This_Op">
                <option value="#Trim(This_Op)#">#This_Op#</option>
              </cfloop>
            </select>
          </td>
          <!--- 2.) User Name --->
          <td>
            <cfset usersAndPositions = userPositionManager.getUsersAndPositions() />
            <b>User Name</b><br>
            <select name="User_Position_Of" <!---onChange="javaScript:disableSelect(this,this.form.User_Position,true);"---> class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
              <option value="" selected>**ALL** Users</option>
              <cfloop query="usersAndPositions">
                <option value="#trim(User_ID)#">#trim(User_Name)#</option>
              </cfloop>
            </select>
          </td>
          <!--- 3.) User Position --->
          <td colspan="2">
            <cfset userPositions = userPositionManager.getUserPositions() />
            <b>User Position</b><br>
            <select name="User_Position" <!---onChange="javaScript: disableSelect(this,this.form.User_Position_Of,false);"---> class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
              <option value="" selected>**ALL** User Positions</option>
              <cfloop query="userPositions">
                <option value="#trim(User_Positions_ID)#">#trim(Position_Label)#</option>
              </cfloop>
            </select>
          </td>
        </tr>
     <!---  </cfif> --->
    	<!--- III.) Advanced Search > Ownership Section [end] --->
</cfoutput>
		</cfif>
<cfoutput>
    <!--- ============================== ADVANCED SEARCH [end] ============================== --->
    <tr>
    	<td>
      	<cfsilent>
          <cfquery name="GetDefaultProgram" datasource="#application.datasource#">
            SELECT 	Default_Program
            FROM 		Billback_Settings
          </cfquery>
				</cfsilent>
				<cfif len(trim(GetDefaultProgram.Default_Program)) GT 0>
        <b>Show Incomplete Uploaded Billbacks:</b>
          <input type="checkbox" value="#GetDefaultProgram.Default_Program#" name="ShowIncompleteBillbacks">
        <cfelse>
          &nbsp;
        </cfif>
      </td>
      <td>
      	<!---if payment processor is on--->
				<cfif application.returned_customer_setting.Accounting_Specialist eq 1>
					<!---get payment processors--->
          <cfset qPaymentProcessor = CreateObject("component", "components.settings.AccountingSpecialists.AccountingSpecialists").get() />
            <b>Payment Processor</b><br>
            <select name="PP_User_ID" class="full"  onkeydown="if (event.keyCode == 13) enterKeySearch();">
              <option value="" selected>**ALL** Payment Processors</option>
              <cfloop query="qPaymentProcessor">
              	<option value="#trim(User_ID)#">#trim(Name)#</option>
              </cfloop>
            </select>
        <cfelse>
        	&nbsp;
				</cfif>
      </td>
	<cfif Source IS "Deductions">
	<cfsilent>
       <cfset useLakebaseForGetDeductionDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetDeductionDetails>
	<cftry>
		<cfset GetDeductionDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Deduction_ID#",
				"select" = "dd_amount,distributor_id,distributor_bill_to_id"
			}), "dd_amount,distributor_id,distributor_bill_to_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDeductionDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDeductionDetails>
<cfquery name="GetDeductionDetails" datasource="#Application.Datasource#">
         SELECT	DD_Amount, Distributor_ID, Distributor_Bill_To_ID
         FROM	Deductions
         WHERE 	Deduction_ID = '#Deduction_ID#'
       </cfquery>
</cfif>
     </cfsilent>
	</cfif>
      <td>
      	<cfif Source IS "Deductions" AND appSettings.getMultiple_BB_Per_Deduction()>
        			<b>Available Amount</b><br>
					<cfset jvDisplayAmount = GetDeductionDetails.DD_Amount - form.selectedItemValue />
					<span ID="SP_DISPLAY_DIFF" STYLE="ALIGN:RIGHT;WIDTH:100px;TEXT-ALIGN:RIGHT;BORDER:1px solid navy;FONT-WEIGHT:BOLD;display:inline-block;">#DOLLARFORMAT(jvDisplayAmount)#</span>
					<input type="Hidden" name="SelectedAmtTot" value="#jvDisplayAmount#">
				<cfelse>
        	&nbsp;
		</cfif>
      </td>

	 <td>
      	<cfif Source IS "Deductions" AND (NOT isDefined("MATCHCentral") OR NOT MATCHCentral)>
			<b>Filter #application.returned_customer_setting.BillTo_Label# / #application.returned_customer_setting.Shard_Ship_To_Label#</b><br>
			<cfif GetDeductionDetails.Distributor_ID neq "">
				<cfif NOT isDefined("Form.DOSEARCH") OR Form.DOSEARCH eq 0>
					<cfset Form.Filter_Distributor_ID = GetDeductionDetails.Distributor_ID />
				<cfelse>
					<cfparam name="Form.Filter_Distributor_ID" default="">
				</cfif>
				<input type="checkbox" name="Filter_Distributor_ID" value="#GetDeductionDetails.Distributor_ID#" <cfif Form.Filter_Distributor_ID neq "">checked</cfif>>
			<cfelse>
				<cfif NOT isDefined("Form.DOSEARCH") OR Form.DOSEARCH eq 0>
					<cfset Form.Filter_Distributor_Bill_To_ID = GetDeductionDetails.Distributor_Bill_To_ID />
				<cfelse>
					<cfparam name="Form.Filter_Distributor_Bill_To_ID" default="">
				</cfif>
				<input type="checkbox" name="Filter_Distributor_Bill_To_ID" value="#GetDeductionDetails.Distributor_Bill_To_ID#" <cfif Form.Filter_Distributor_Bill_To_ID neq "">checked</cfif>>
			</cfif>
		</cfif>
      </td>

    </tr>
		<tr>
			<TD colspan="5" align="right" VALIGN="BOTTOM">
      		<!------ Payee search options (include to avoid errors on quick srch load) ----->
				<cfif searchType EQ "quick">
					<div style="display:none;"><cfmodule template="/CustomTags/SmallHelp.cfm"></cfmodule></div>
				</cfif>
				<input type="hidden" ID="sort_by" name="sort_by" value="#Default_Sort#">
				<input type="hidden" ID="sort_Order" name="sort_Order" value="#Default_Sort_Order#">
				<input type="hidden" ID="startrow" name="startrow" value="1">
				<input type="hidden" ID="frompage" name="frompage" value="1">
				<input type="hidden" NAME="pageLength" value="8">
				<input type="hidden" ID="DOSEARCH" name="DOSEARCH" value="1">
				<input type="hidden" name="finishedselecting" value="0">
				<input type="hidden" name="selectedUser" value="">
			<cfif Source IS "Deductions">
	            <input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
	            <input type="hidden" name="Distributor_ID" value="#Distributor_ID#">
	        </cfif>
				<FONT size="1" COLOR="FF0000">[</FONT> <a HREF="##" ONCLICK="javascript:resetFrm();disable_Comparsion_Operators();">reset form</a> <FONT COLOR="FF0000">]</FONT>&nbsp;&nbsp;
                <!--- 17544 testing correction [begin] --->
				<cfif listFindNoCase(CGI.SCRIPT_NAME,'billbacks','/')>
                    <FONT size="1" COLOR="FF0000">[</FONT> <a HREF="##" ONCLICK="javascript:showSearchResult(true, 1);document.all.headerTable.style.display = 'block';">search billbacks</a> <FONT COLOR="FF0000">]</FONT>
                <cfelse>
                    <FONT size="1" COLOR="FF0000">[</FONT> <a HREF="##" ONCLICK="javascript:showSearchResult(true, 1);">search billbacks</a> <FONT COLOR="FF0000">]</FONT>
                </cfif>
                <!--- 17544 testing correction [end] document.all.headerTable.style.display = 'block'; --->
                </B>
			</TD>
		</tr>
	</TABLE>
	</cfoutput>
	</CF_openLayer>
</FORM>

<cfif Source IS NOT "Deductions">
<SCRIPT LANGUAGE="JavaScript">
findselectboxes();
</SCRIPT>
</cfif>

<cfset jQuery.version = "1.12.4">
<cfinclude template="/common_files/jQuery.cfm">
<!--- D70951 PLEASE WAIT INDICATOR    Release START --->
<cfinclude template="/Common_Files/noty.cfm">
<!--- D70951 PLEASE WAIT INDICATOR    Release END --->

<cfset jQueryUI.widgets = "accordion, tooltip">
<cfinclude template="/common_files/multiselect.cfm">
<script>
function createList2(type){
	NewWindow('/common_files/createList2.cfm?parent=bb_search&type='+type, 'bb_search_create_list', 350, 425, 'no', 'no');
}

function resetFrm()
{
	document.SearchForm.reset();
	disable_Comparsion_Operators();
	SearchForm.Payable_Number.value="";
	SearchForm.Billback_Number.value="";
	SearchForm.BB_Closing_Method.value="";
	SearchForm.Contract_Number.value="";
	SearchForm.Distributor_Name.value="";
	SearchForm.soldToNo.value="";
	SearchForm.Operator_Name.value="";
	SearchForm.operatorID.value="";

	SearchForm.payable_list.value="";
	SearchForm.soldToNo_list.value="";
	SearchForm.Item_list.value="";
	SearchForm.billback_list.value="";
	SearchForm.reference_list.value="";
	SearchForm.distributor_list.value="";
	SearchForm.operator_list.value="";
	SearchForm.operator_number_list.value="";
	SearchForm.vendor_list.value="";

	if(SearchForm.Billback_Title)
	{
	SearchForm.Billback_Title.value="";
	}
}
//$("#Program_Template").multiselect();

let multi_select_min_rows_filter = <cfoutput>#val(application.util.query.get_setting("multi_select_min_rows_filter", 0))#</cfoutput>;
    if (multi_select_min_rows_filter == 0) {
        multi_select_min_rows_filter = 10;
    }
    config.multiselect.buttonWidth = "90%";
    config.multiselect.selectedList = 2;


    $("select.multi").each(function() {
        $(this).multiselect( config.multiselect );
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~ enable search feature when number of options in dropdown is large (customizable) ~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        if ($("option", this).length > multi_select_min_rows_filter) {
            $(this).multiselectfilter( { label: "Find", placeholder: "" } );
        }
    });

</script>
<!--------------------------------------------------------
End Search Form
--------------------------------------------------------->


<cffunction name="showStatus" returntype="void" output="true" hint="Display status dropdown based on bb user profile">
	<cfquery name="local.qStatus" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmp_status') IS NOT NULL
			DROP TABLE ##tmp_status

		CREATE      TABLE ##tmp_Status ( tmp_ID INT IDENTITY(1, 1)
		                                ,Status_ID INT
		                                ,Status_Desc VARCHAR(200) )

		INSERT  INTO ##tmp_Status ( Status_ID, Status_Desc )
		        SELECT  Status_ID = Billback_Status_ID, Status_Desc = BB_Status_Description
		        FROM    Billback_Status
		        ORDER BY Billback_Status_ID

		<!--- additional options for bb user profile 'rfa scorecard - agreed' setting when it is enabled --->
		<cfif Get_Profile_Settings.bb_rfa_agreed eq 1>
			INSERT  INTO ##tmp_Status ( Status_ID, Status_Desc )
			        SELECT  Status_ID = Program_Agree_Status_ID + 2000   -- add an offset of 2000 to differentiate with other statuses
			               ,Status_Desc = Program_Agree_Status_Desc
			        FROM    Program_Agree_Status
			        WHERE   Deleted = 0
			        ORDER BY Program_Agree_Status_Desc
		</cfif>

		SELECT  *
		  FROM  ##tmp_Status
	</cfquery>
	<b>Status</b><br>
	<select name="Status" class="full" onchange="javascript:document.all.allunpaidstatusoption.style.backgroundColor='white';" onkeydown="if (event.keyCode == 13) enterKeySearch();">
		<option value="0">**ALL** Status</option>
		<option value="-1" <cfif FORM.Status EQ "-1">selected style="background-color:C6FFC6;" </cfif> id="allunpaidstatusoption">**ALL** Unpaid Status</option><!---BJF 29196 Add option for "All unpaid Statuses" -- set to 00 because I know that won't be a valid entry in the select list--->
	<cfloop query="local.qStatus"><option value="#trim(local.qStatus.Status_ID)#" <cfif trim(FORM.Status) eq local.qStatus.Status_ID>selected=selected</cfif>>#trim(local.qStatus.Status_Desc)#</option></cfloop>
	</select>
</cffunction>