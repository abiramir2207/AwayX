<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFPARAM NAME="useragreed" 					default="0">
<CFPARAM NAME="displayagreed" 			default="0">
<CFPARAM NAME="Customerrequired" 		default="0">
<CFPARAM NAME="Operatorrequired" 		default="0">
<CFPARAM NAME="Discountrequired"		default="0">
<CFPARAM NAME="DiscountFound" 			default="1">
<CFPARAM NAME="duplicateprogram"		default="0">
<CFPARAM NAME="MarginRequestAction"				default="">
<!--- Dev Note: KAL; D21684: Functionality of View Margins Screen --->
<cfparam name="displayPreviousVersionMargin" default="1">	<!--- From the LH link in program, we set this to 0 --->
<cfparam name="margin_version" default="current">			<!--- set default version to current --->
<!--- End Note: KAL; D21684: Functionality of View Margins Screen --->
<cfparam name="url.verticalPNL" default="">

<!--- flag if approval is coming from planner --->
<cfparam name="url.bFromPlanner" default="0">

<cfset request.content = []>
<cfif url.verticalPNL eq "">         <!---  44017  --->
    <cfsavecontent variable="subcontent">
        <CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
        <br />
    </cfsavecontent>
    <cfset request.content.append( subcontent )>
</cfif>

<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Check if the volume is set.
If not redirect to volume page
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFSET URL.Program_ID = cryp.value>

<!------ Initialise ----->
<CFINCLUDE TEMPLATE="/Get_Access_Profile.cfm">
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset objProgram = CreateObject("component", "components.programs.Program") />
<cfset display_business_consideration = 0 ><!--- Dev Note: KAL; 8891 --->
<cfif Get_Profile_Settings.Internal_Notes EQ 1 and appSettings.getbusinessconsiderations_on() EQ 1>
	<cfset display_business_consideration = 1 ><!--- Dev Note: KAL; 9559 --->
</cfif>


<CFQUERY NAME="getProgramInfo" datasource="#application.datasource#">
	SELECT CM.Creating_User_Position_ID
				,CM.PTRM, CM.PTTM, CM.TLS
				,CM.contract_start_date
				,CM.contract_end_date
				,CM.contract_title
				,CM.contract_number
				,CM.ProgramType_ID
				,CM.Contract_Status_Type_IDX
				,CM.Parent_Revised_Contract_Main_ID
				,CM.Revision_of_Contract_Main_ID
				,CM.Auto_Renew
				,CM.Contract_Status_Type_IDX
				,CM.PTRM
				,CM.PTTM
				,CM.TLS
				,CM.PTER
				,CMAD.Market_Price_Approved
				,CM.Contract_Main_ID
		<cfif appSettings.getEquipment_Placement() IS 1>, CMAD.Equipment_Placement</cfif>
	FROM Contract_Main CM
		LEFT JOIN Contract_Main_Aux_Data CMAD
		ON CMAD.Contract_Main_ID = CM.Contract_Main_ID
	WHERE CM.Contract_Main_ID = '#FORM.Contract_Main_ID#'
</CFQUERY>

<CFQUERY NAME="getProgramSettngs" datasource="#application.datasource#">
	SELECT	*
	FROM	dbo.Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#getProgramInfo.ProgramType_ID#'
</CFQUERY>

<cfif appSettings.getOperatingGroupOn() AND getProgramInfo.Contract_Status_Type_IDX LTE 2>
	<!--- call SP to calculate/update the rate for rebate and off-invoice for basis code = buy x get y free type --->
	<!------ only if RFA or WIP ----->
	<cfstoredproc procedure="BASIS_CODE_CALC_RATE" datasource="#application.datasource#">

		<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER" dbVarName = "@@CONTRACT_MAIN_ID" value = "#FORM.Contract_Main_ID#">

	</cfstoredproc>
</cfif>
<cfset TemplateSettings = createObject("component", "components.programs.template.TemplateManager").getProgramTemplate(FORM.Contract_Main_ID)>
<cfset ApprovalManager = CreateObject("component", "components.programs.Approval.ApprovalManager") />

<!---TSF: Label 10245 - If the template setting to bypass the margin routine is on then bypass the margin routine and automatically approve the program--->
<cfif TemplateSettings.ByPass_Margin_Evaluation OR (TemplateSettings.EZButton_On and TemplateSettings.EzButton_Auto_Approve_On and getProgramInfo.Contract_Status_Type_IDX EQ 2) OR (TemplateSettings.Market_Price AND getProgramInfo.Contract_Status_Type_IDX EQ 2)>
  <!---
      Dev Notes:D23990/Anand Rao/30-Jun-2010
      Multi Discount Template Issues in QAS
  --->
	<!--- ByPass_Margin_Evaluation_Options: 1 = All Programs, 2 = Programs With Lump Sum --->
  <cfset doBypassMargin = 0 />

  <cfset Approve_LS = 0>

  <CFIF NOT TemplateSettings.Market_Price >
	<cfif (TemplateSettings.EZButton_On and TemplateSettings.EzButton_Auto_Approve_On and getProgramInfo.Contract_Status_Type_IDX EQ 2)>
		<!--- 28783	Release 7 EZ Button Max Rate
		If ez button flag the products that satisfy ez rules as approved.
		If all products are approved we can flag the program as approved.
		If not user needs to go to margin page --->


<!--- When template setting on the EZButton Page called "Max Rate should consider" is  NOT "Rebate & Lumpsum". --->
		<cfif getProgramSettngs.EzButton_Max_Rate_Consider neq 2>
			<!--- Check approval rights for lumpsum --->
			<cfinclude template="common_lumpsum_approval_check.cfm">
			<!--- If program has lump sum. --->
			<cfif programLumpSum GT 0>
				<cfif IsDefined("letUserProceed")>
					<cfif letUserProceed eq 1>
						<cfset Approve_LS = 1>
					</cfif>
				<!--- Default value of "letUserProceed" is 1 and so if the value is not 0, then use the default value. --->
				<cfelse>
					<cfset Approve_LS = 1>
				</cfif>
			<cfelse>
				<cfset Approve_LS = 1>
			</cfif>
		<cfelse>
				<cfset Approve_LS = 1>
		</cfif>

	<cfif  Approve_LS eq 1>
		<!--- D50297: Broker Routing Approvals: For EZ Rates when no products but just LS then route to regular approvals. --->
		<cfset qGetDiscountTypes = objProgram.getDiscountTypes(FORM.Contract_Main_ID) />
		<cfif not(len(objProgram.getprogramDiscounttypes(FORM.Contract_Main_ID)) eq 0 AND listFind(valuelist(qGetDiscountTypes.Product_Type_ID),3)) >
			<cfset qProductsNotApproved = ApprovalManager.autoApproveEZProducts(FORM.Contract_Main_ID, request.AccessStructure.user_id)>
			<cfif not qProductsNotApproved.recordCount> <!--- If all products are approved --->
				<cfset doBypassMargin = 1 />
			</cfif>
		</cfif>
	</cfif>

	<cfelseif TemplateSettings.ByPass_Margin_Evaluation_Options EQ 1>
	    <cfset doBypassMargin = 1 />
	<cfelse>
	    <cfquery name="qryIsLumpsumProgram" datasource="#application.datasource#">
	      SELECT TOP 1 Program_ID FROM Program_Lump_Sums WHERE Program_ID = #FORM.Contract_Main_ID# and Deleted = 0
	    </cfquery>
	    <cfif qryIsLumpsumProgram.RecordCount EQ 1>
	      <cfset doBypassMargin = 1 />
	    </cfif>
	</cfif>
  <!--- IF MARKET PRICE AND MARKET PRICE IS APPROVED, CHECK IF WE CAN BYPASS MARGIN SCREEN --->
  <CFELSEIF TemplateSettings.Market_Price EQ 1 AND getProgramInfo.Market_Price_Approved EQ 1 >
  		<cfset qMPProductsNotApproved = ApprovalManager.autoApproveMarketPriceProducts(FORM.Contract_Main_ID, request.AccessStructure.user_id)>
		<!---<cfdump var="#qMPProductsNotApproved#"/> --->
		<cfif not qMPProductsNotApproved.recordCount><!--- If all products are approved --->
			<cfset doBypassMargin = 1 /><!---xxx<cfabort>--->
		</cfif>
  </CFIF>

<!---  oooo<cfabort>--->
  <cfif doBypassMargin>
    <!---
      Set the program as approved only if the program is currently in RFA status, if the program is in
      WIP then just close the window without doing any thing - Anand Rao 02/16/09 - D18126--->

	<cfif (getProgramInfo.Contract_Status_Type_IDX EQ 2)>
  	  <!---if it's layered then run routines to handle for layered--->
    	<cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 6 OR Get_Profile_Settings.program_margin_approval_method IS 7>
    		<cfset form.approval_method = Get_Profile_Settings.program_margin_approval_method />
    		<cfset form.Approved_By_User_ID = request.AccessStructure.user_id />
    		<cfset Program_ID = FORM.Contract_Main_ID />
    		<cfinclude template="Contract_layered_approve_action_Auto.cfm" />
			<!--- D49082 :: Email settings for prg approval not working correctly START --->
			<cfset contract_main_id = cryp.value />
			<cfset CloseWindow = 0>
			<cfif ApproveProgram >	<!--- DEV NOTE: WR 108138 - Error when clicking on Approve This Program  --->
				<cfinclude template="generate_approve_email.cfm">
			</cfif>
			<!--- D49082 :: Email settings for prg approval not working correctly END --->
    	<cfelse>
    		<cfinclude template="contract_approve_action_include.cfm" />
    	</cfif>
    </cfif>

    <!--- Find the view program page and reload it --->
    <cfset targetpage = "winSummary_" & FORM.Contract_Main_ID>
    <script>
        let existingWin = window.open('', <cfoutput>'#targetpage#'</cfoutput>);
        if ( existingWin ) {
            // reload function in parent popup is available
            if ( typeof existingWin.reloadFromPopUp === "function" ) {
                existingWin.reloadFromPopUp( 1 );
            }
            /* the particular window did not exist - close it */
            else if ( existingWin.location.href === "about:blank" ) {
                existingWin.close();
            }
        }
        window.close();
    </script>
  	
  	<cfabort>
  </cfif>
</cfif>

<!--- if layered go to a different action file --->
<cfif Get_Profile_Settings.program_margin_approval_method IS 5 OR Get_Profile_Settings.program_margin_approval_method IS 6 OR Get_Profile_Settings.program_margin_approval_method IS 7>
	<!--- set the url parameters --->
	<cfset params = "" />
	<cfset params = "CID=" & "#Url.CID#" />
	<cfset params = params & "&" & "duplicateprogram=" & "#duplicateprogram#" />
	<cfset params = params & "&" & "MarginRequestAction=" & "#MarginRequestAction#" />
	<cfset params = params & "&" & "displayPreviousVersionMargin=" & "#displayPreviousVersionMargin#" />
    <cfset params = params & "&" & "margin_version=" & "#margin_version#" />
    <!---D45761 :: Approval Workflow START --->
    <cfif url.verticalPNL eq "" and (TemplateSettings.EZButton_On and appSettings.getCustomMaxRate())>
        <cflocation url="/common_files/contracts/ez_Rate_check.cfm?#params#">
    <cfelse>
    	<cfparam name="url.bReset" default="1">
        <!--- add intermediate loading spinner page due to slow loading in actual margin page --->
        <cflocation url="/common_files/processing.cfm?actualPage=/common_files/contracts/layered_margin_calculation.cfm&#params#&verticalPNL=#url.verticalPNL#&bFromPlanner=#url.bFromPlanner#&bReset=#url.bReset#">
    </cfif>
<!---D45761 :: Approval Workflow END --->
	<cfabort>
</cfif>


<cfif appSettings.getRFAAgree()>
	<cfset displayagreed = 1>
	<CFINCLUDE template="program_agree.cfm">
</CFIF>

<CFSET arrayMargins = ArrayNew(2)>
<CFSET arrayOfRowIDs = ArrayNew(1)>
<!--- initialze array of rejected margins --->
<CFSET arrayOfRejectedMarginsRowIDs = ArrayNew(2)>
<CFSET LetUserApprove = 0>


<cfquery name="getApprovalMethod" datasource="#application.datasource#">
	SELECT program_margin_target_enabled
	FROM General_Settings
</cfquery>

<!---Which approval scheme should we show?--->
<cfset approval_method 		= Get_Profile_Settings.program_margin_approval_method>
<cfset margin_target_status = getApprovalMethod.program_margin_target_enabled>
<cfset MarginTargetArray = ArrayNew(2)>

<cfset anyDiscountTypeHasAllProducts = 0>

<!--- decide if this program is a revision of an existing one --->
<CFSET Program_Is_A_Revision = 0>
<CFIF len(trim(getProgramInfo.Parent_Revised_Contract_Main_ID)) NEQ 0 AND len(trim(getProgramInfo.Revision_of_Contract_Main_ID)) NEQ 0>
	<CFSET Program_Is_A_Revision = 1>
	<DIV ALIGN="center">*** NOTE: This Is A Revision Of An Existing Program ***
	<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2 AND getProgramInfo.Auto_Renew>
	<cfif objProgram.getAutoRenewStatus(getProgramInfo.Contract_Number) EQ 1>
	<br>An auto renewed version of this program already exists. <br>The changes getting approved in this revision will not be reflected in that auto renewed program.
	</cfif>
	</cfif>
	</DIV><BR>
</CFIF>

<CFSET UserIsOnlyViewingMargins = "0">
<CFIF getProgramInfo.Contract_Status_Type_IDX GTE 3 AND getProgramInfo.Contract_Status_Type_IDX LTE 5>
	<CFSET UserIsOnlyViewingMargins = "1">
</CFIF>

<cfset bAllDistributorProgram = CreateObject("component", "components.programs.distributors.DistributorGroupManager").isAllDistributorProgram(URL.Program_ID)>


<!------ Find whether this is agroup deal ----->
<cfset groupDataManager = CreateObject("component", "components.products.Group.DataManager").init() />
<cfset isGroupDeal = groupDataManager.isGroupDeal(URL.Program_ID) />

<!------ no margin display for group deals ----->
<!--- <cfif NOT isGroupDeal> --->

<cfif Get_Profile_Settings.program_margin_approval_method IS 4>
	<cflocation url="/common_files/contracts/program_approval.cfm?Url.CID=#Url.CID#">
	<cfabort>
</cfif>

<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
<CFSET Program_Volume.Load_Basic_Information(URL.Program_ID, request.AccessStructure.Company_Main_ID)>
<CFSET TotalProgramVolume = Program_Volume.Get_Total_Program_Volume()>
<CFSET TotalProgramVolumeUOM = request.app_general_functions.getUOMDesc(Program_Volume.UOM)>
<cfset ProgramUOM = Program_Volume.UOM>

<cfset currentVolumeMultiplier = 7> <!------ volume is stored as weekly in the db ----->

<!------ if multiplier = 0, that means it is program span ----->
<cfif NOT Program_Volume.defaultUOT.getMultiplier()>
	<cfset Program_Volume.defaultUOT.setMultiplier(Program_Volume.Contract_Span) />
</cfif>

<cfset Current_Trade_Label = application.returned_customer_setting.Trade_Label />
<cfset Current_Rebate_Label = Application.RebateLabel />
<!------
<cfset Current_Trade_Label = "Trade" />
<cfset Current_Rebate_Label = "Rebate" />
 ----->


<CFParam name="MarginTooLow" default="1">
<CFPARAM NAME="getPercentRebateCID_List" default="0">
<cfset IDCApprovalRestriction = 0>
<cfset NoPriceListArray = ArrayNew(1)>
<cfscript>
	//make value = 0 if the value is empty or null
	function makeNumeric(sVal)
	{
		var returnValue = sVal;
		if(Len(Trim(returnValue)) EQ 0 OR NOT isNumeric(returnValue))
		{
			returnValue = 0;
		}
		return returnValue;
	}

	//does what valuelistcando, forgiven query, give list of dynamically given column
	function dyn_valuelist(queryColumnCombo){
		tempA = listtoarray(queryColumnCombo, ".");
		tempAQuery = "";
		outputList = "";

		if(arraylen(tempA) NEQ 2) {
			return false;
		}
		else{
			if(isquery(evaluate(tempA[1])) EQ false) {
				return false;
			}
			else{
				 tempAQuery = evaluate(tempA[1]);

				 count = 0;
				 while (count lt tempAQuery.RecordCount)
				 {
				  	count = count + 1;
				  	Column1 = evaluate("tempAQuery.#tempA[2]#[count]");
				  	outputList = listappend(outputList, Column1);
				 }
				 return outputList;
			}
		}
	}
</cfscript>



<!--- get contract product ids of products part of component with percent as the UOM --->
<cfquery name="getPercentRebateCID" datasource="#application.datasource#">
	SELECT     dbo.Program_Rebates_Product_Data.Contract_Products_ID, dbo.Program_Rebates_Product_Data.Program_ID
	FROM         dbo.Program_Rebates_Component_Data INNER JOIN
                    dbo.Program_Rebates_Product_Data ON
                    dbo.Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = dbo.Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
	WHERE     (dbo.Program_Rebates_Component_Data.Deleted = 0) AND (dbo.Program_Rebates_Product_Data.Deleted = 0) AND
                    (dbo.Program_Rebates_Component_Data.Unit_Of_Measure_ID = 3) AND (dbo.Program_Rebates_Product_Data.Program_ID = '#FORM.Contract_Main_ID#')
</cfquery>

<cfset getPercentRebateCID_List = valuelist(getPercentRebateCID.Contract_Products_ID)>
<cfif listlen(getPercentRebateCID_List) EQ 0>
	<cfset getPercentRebateCID_List = 0> <!--- default value, not gonna find this anywhere in the db --->
</cfif>

<!--- get contract product ids of products part of component with percent as the UOM --->
<cfquery name="getPercentOffInvoiceCID" datasource="#application.datasource#">
	SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Contract_Products.Product_Type_ID
	FROM         dbo.Contract_Products INNER JOIN
	                      dbo.Program_OffInvoice_Product_Data ON
	                      dbo.Contract_Products.Contract_Products_ID = dbo.Program_OffInvoice_Product_Data.Contract_Products_ID
	WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Program_OffInvoice_Product_Data.Deleted = 0) AND (dbo.Contract_Products.Product_Type_ID = 8) AND
	                    (dbo.Program_OffInvoice_Product_Data.UOM = 3) AND (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#')
</cfquery>

<cfset getPercentOffInvoiceCID_List = valuelist(getPercentOffInvoiceCID.Contract_Products_ID)>
<cfif listlen(getPercentOffInvoiceCID_List) EQ 0>
	<cfset getPercentOffInvoiceCID_List = 0> <!--- default value, not gonna find this anywhere in the db --->
</cfif>

<!--- get contract product ids of products part of component with percent as the UOM --->
<cfquery name="getPercentGrowthCID" datasource="#application.datasource#">
SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Contract_Products.Contract_Main_ID
FROM         dbo.Contract_Products INNER JOIN
                      dbo.Program_Growth_Component_Product_Data ON
                      dbo.Contract_Products.Contract_Products_ID = dbo.Program_Growth_Component_Product_Data.Contract_Products_ID INNER JOIN
                      dbo.Program_Growth_Components ON
                      dbo.Program_Growth_Component_Product_Data.Program_Growth_Component_ID = dbo.Program_Growth_Components.Program_Growth_Component_ID
WHERE     (dbo.Contract_Products.Product_Type_ID = 4) AND (dbo.Program_Growth_Components.Deleted = 0) AND
                      (dbo.Program_Growth_Component_Product_Data.Deleted = 0) AND (dbo.Contract_Products.Deleted = 0) AND
                      (dbo.Program_Growth_Components.component_uom = 3) AND (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#')
</cfquery>

<cfset getPercentGrowthCID_List = valuelist(getPercentGrowthCID.Contract_Products_ID)>
<cfif listlen(getPercentGrowthCID_List) EQ 0>
	<cfset getPercentGrowthCID_List = 0> <!--- default value, not gonna find this anywhere in the db --->
</cfif>

<cfscript>
	function marginDisplay(num, denom) {
		returnValue = "";
		num = vaildateNumber(num);
		denom = vaildateNumber(denom);

		if(denom EQ 0) {
			returnValue = "";
		}
		else{
			//num = (num) * 100000;
			//denom = (denom) * 100000;
			tempB =  (num)/(denom);
			tempB = tempB * 100;
			tempB = trim(numberformat((tempB), '_-___._'));
			returnValue = tempB;
			//returnValue = (returnValue)*(-1);
		}

		return returnValue;
	}

	function vaildateNumber(number){
		if(isnumeric(number) EQ False) {
			return 0;
		}
		else {
			return trim(numberformat(number, '_-________.____'));
		}
	}
</cfscript>

<!----------------- Add Spinner ------------------------>
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<SCRIPT>
	document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
<!----------------- Add Spinner ------------------------>

<!--- execute SP to update all info used on this page --->
<CFSTOREDPROC PROCEDURE="GET_PROFIT_MARGIN" datasource="#application.datasource#">
	<CFPROCPARAM TYPE="In" CFSQLTYPE="CF_SQL_INTEGER" VARIABLE="CA_ID" VALUE="#trim(FORM.Contract_Main_ID)#" NULL="No">
</CFSTOREDPROC>


<CFSET PAGE_TITLE= "Profit Analysis">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<CFOUTPUT>
	<SCRIPT>
		function showTradeCalculation(CPID){
			//window.open()
			NewWindow('Contract_Trade_Analysis.cfm?CPID='+CPID+'&CID=#URL.CID#','tradeAnalysis','750','350','Yes', 'Yes')
		}

		function showRebateCalculation(IMID){
			//window.open()
			NewWindow('Component_Rebate_Display.cfm?itemMasterId='+IMID+'&CID=#URL.CID#','rebateAnalysis','750','350','Yes', 'Yes')
		}

	</SCRIPT>
	</CFOUTPUT>
	<style type="text/css">

		/* POPup tooltip style*/
		#divTooltip {
			position:absolute;
			top:0px;
			width:200px;
			visibility:hidden;
			z-index:200;
			background-color:#f3f3f3;
			layer-background-color:#f3f3f3;
		}
		.normalStyle {
			padding:2px;
			text-align:center;
			font-weight:500;
			width:175px;
			color:#000000;
			top:100px;
			font-family:verdana,arial,helvetica;
			font-size:11px;
			background-color:#f3f3f3;
			layer-background-color:#f3f3f3;
			border-width:1px;
			border-style:solid;
			border-color:#000000;
			cursor:default;
		}

	</style>

	<style type="text/css" media="print">
		#DIV_DONT_PRINT
		{
			display:none;
		}
		#MyForm
		{
			display:none;
		}
	</style>


	<SCRIPT SRC="/common_files/scripts/Date_Difference.js"></SCRIPT>
</HEAD>



<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="popupInit()" ONBEFOREUNLOAD="verifySubmission()">
<div id="divTooltip"></div>
<TITLE>Program Profit Analysis</TITLE>





<CFSET ShowTPA = getProgramSettngs.Include_Trade>


<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>

<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>
<CFINCLUDE TEMPLATE="\settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm">

<!--- If the program is a revision of an active trade\shelter program and this program is a request for appoval adjust the TPA --->

<CFSET AdjustTPA = 0>
<CFIF Program_Is_A_Revision EQ 1 AND getProgramInfo.Contract_Status_Type_IDX EQ 2>
    <!---  is this a trade shelter program --->
    <cfquery name="getThisProgramsGenericProgramType" datasource="#application.datasource#">
        SELECT
			Generic_Type
        FROM
			Program_Control_Panel_Options
        WHERE
            ProgramControl_Panel_Options_ID = '#getProgramInfo.PROGRAMTYPE_ID#'
            AND
            Generic_Type = 'Distributor Trade/Shelter'
    </cfquery>


    <!--- program is a Revision, Is RFA, And is a Trade/Shelter program --->
    <CFIF getThisProgramsGenericProgramType.recordcount GT 0>
        <!--- is the parent active or expiring --->
        <cfquery name="getParentInformation" datasource="#application.datasource#">
            SELECT
				Contract_Status_Type_IDX
            FROM
				Contract_Main
            WHERE
				Contract_Main_ID = '#getProgramInfo.REVISION_OF_CONTRACT_MAIN_ID#'
				AND
				(Contract_Status_Type_IDX >= 5 OR Contract_Status_Type_IDX <= 6)
        </cfquery>

        <!--- the parent is active or expiring --->
        <CFIF getParentInformation.Recordcount GT 0>
           <!--- Rebate --->

		   <cfquery name="getRebateProductsInformationForThisProgram" datasource="#application.datasource#">
				SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Contract_Products.BSA_Foodservice_Items_Master_ID,
				                      dbo.Contract_Products.Contract_Main_ID, dbo.Contract_Product_Margin.RER_LB, dbo.Contract_Product_Margin.GRR_LB,
				                      dbo.Contract_Products.Product_Type_ID
				FROM         dbo.Contract_Products INNER JOIN
				                      dbo.Contract_Product_Margin ON dbo.Contract_Products.Contract_Products_ID = dbo.Contract_Product_Margin.Contract_Product_ID
				WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#') AND (dbo.Contract_Products.Product_Type_ID = 2)
		   </cfquery>

           <cfquery name="getRebateProductsInformationForParentProgram" datasource="#application.datasource#">
				SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Contract_Products.BSA_Foodservice_Items_Master_ID,
				                      dbo.Contract_Products.Contract_Main_ID, dbo.Contract_Product_Margin.RER_LB, dbo.Contract_Product_Margin.GRR_LB,
				                      dbo.Contract_Products.Product_Type_ID
				FROM         dbo.Contract_Products INNER JOIN
				                      dbo.Contract_Product_Margin ON dbo.Contract_Products.Contract_Products_ID = dbo.Contract_Product_Margin.Contract_Product_ID
				WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Contract_Products.Contract_Main_ID = '#getProgramInfo.REVISION_OF_CONTRACT_MAIN_ID#') AND (dbo.Contract_Products.Product_Type_ID = 2)
		   </cfquery>


		  <!--- initilize array with base approval information --->
		  	<CFSET tempData = ArrayNew(1)>
			<cfloop index="x" from="1" to="#getRebateProductsInformationForThisProgram.recordcount#" step="1">
				<CFSET tempData[x] = 0>
			</CFLOOP>

			<CFSET temp = QueryAddColumn(getRebateProductsInformationForThisProgram,"Parent_RER_LB", tempData)>

			<CFSET thisCurrentRow = 1>
			<cfloop query="getRebateProductsInformationForThisProgram">
				<cfquery name="getParentRERLB" dbtype="query">
					SELECT RER_LB
					FROM getRebateProductsInformationForParentProgram
					WHERE BSA_Foodservice_Items_Master_ID = '#getRebateProductsInformationForThisProgram.BSA_Foodservice_Items_Master_ID#'
				</cfquery>

				<CFIF getParentRERLB.recordcount GT 0>
					<CFSET temp = QuerySetCell(getRebateProductsInformationForThisProgram,"Parent_RER_LB",getParentRERLB.RER_LB,thisCurrentRow)>
				</CFIF>
				<CFSET thisCurrentRow = thisCurrentRow + 1>
			</CFLOOP>

           <!--- Growth --->
		   <cfquery name="getGrowthProductsInformationForThisProgram" datasource="#application.datasource#">
				SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Contract_Products.BSA_Foodservice_Items_Master_ID,
				                      dbo.Contract_Products.Contract_Main_ID, dbo.Contract_Product_Margin.RER_LB, dbo.Contract_Product_Margin.GRR_LB,
				                      dbo.Contract_Products.Product_Type_ID
				FROM         dbo.Contract_Products INNER JOIN
				                      dbo.Contract_Product_Margin ON dbo.Contract_Products.Contract_Products_ID = dbo.Contract_Product_Margin.Contract_Product_ID
				WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#') AND (dbo.Contract_Products.Product_Type_ID = 4)
		   </cfquery>

           <cfquery name="getGrowthProductsInformationForParentProgram" datasource="#application.datasource#">
				SELECT     dbo.Contract_Products.Contract_Products_ID, dbo.Contract_Products.BSA_Foodservice_Items_Master_ID,
				                      dbo.Contract_Products.Contract_Main_ID, dbo.Contract_Product_Margin.RER_LB, dbo.Contract_Product_Margin.GRR_LB,
				                      dbo.Contract_Products.Product_Type_ID
				FROM         dbo.Contract_Products INNER JOIN
				                      dbo.Contract_Product_Margin ON dbo.Contract_Products.Contract_Products_ID = dbo.Contract_Product_Margin.Contract_Product_ID
				WHERE     (dbo.Contract_Products.Deleted = 0) AND (dbo.Contract_Products.Contract_Main_ID = '#getProgramInfo.REVISION_OF_CONTRACT_MAIN_ID#') AND (dbo.Contract_Products.Product_Type_ID = 4)
		   </cfquery>

		  	<CFSET tempData = ArrayNew(1)>
			<cfloop index="x" from="1" to="#getGrowthProductsInformationForThisProgram.recordcount#" step="1">
				<CFSET tempData[x] = 0>
			</CFLOOP>

			<CFSET temp = QueryAddColumn(getGrowthProductsInformationForThisProgram,"Parent_GRR_LB", tempData)>

			<CFSET thisCurrentRow = 1>
			<cfloop query="getGrowthProductsInformationForThisProgram">
				<cfquery name="getParentGRRLB" dbtype="query">
					SELECT GRR_LB
					FROM getGrowthProductsInformationForParentProgram
					WHERE BSA_Foodservice_Items_Master_ID = '#getGrowthProductsInformationForThisProgram.BSA_Foodservice_Items_Master_ID#'
				</cfquery>

				<CFIF getParentGRRLB.recordcount GT 0>
					<CFSET temp = QuerySetCell(getGrowthProductsInformationForThisProgram,"Parent_GRR_LB",getParentGRRLB.GRR_LB,thisCurrentRow)>
				</CFIF>

				<CFSET thisCurrentRow = thisCurrentRow + 1>

			</CFLOOP>

            <CFSET AdjustTPA = 1>

        </CFIF>
    </CFIF>
</CFIF>

<CFSET ApproverInDefaultList = 0 />
<cfquery name="qGetMyPositionsListSameAsCreating_User_Position_ID" datasource="#application.datasource#">
	#GP_Position_List_From_My_Position_Down#
	AND Below_User_Positions_ID = #getProgramInfo.Creating_User_Position_ID#
</cfquery>
<CFSET ApproverInDefaultList = qGetMyPositionsListSameAsCreating_User_Position_ID.recordCount>

<!--- <CFSET ApproverInZoneList = listfind(Zone_Approver_List,request.AccessStructure.User_ID, ",")>
<CFSET ApproverInRegionList = listfind(Region_Approver_List,request.AccessStructure.User_ID, ",")>
<CFSET ApproverInMarketList = listfind(Market_Approver_List,request.AccessStructure.User_ID, ",")> --->

<!------Display Program Details----->
<CFQUERY NAME="Contract_Details" DATASOURCE="#application.datasource#">
	SELECT	Contract_Number, Contract_Title, Contract_Start_Date, Contract_End_Date
	FROM	Contract_Main
	WHERE	Contract_Main.Contract_Main_ID = #FORM.Contract_Main_ID#
</CFQUERY>

<CFOUTPUT>
<cfinclude template="/common_files/general_labels.cfm">
<SPAN CLASS="Title2">
[#Contract_Details.Contract_Number#] : #Contract_Details.Contract_Title#
<BR>
#general_labels[ delivery_period ]#: #DateFormat(Contract_Details.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(Contract_Details.Contract_End_Date, "mm/dd/yyyy")#
</SPAN>
<HR COLOR="orange">
<BR>
<p><b>* Insufficient Data Calculation</b></p>
</CFOUTPUT>
<!--- get contract products --->
<cfset approvalGroupType = CreateObject("component", "components.settings.ApprovalGroupManager").getGroupTypeInfo() />

<CFQUERY NAME="getProducts" datasource="#application.datasource#">
	SELECT	dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID,
			dbo.BSA_Foodservice_Items_Master.Item,
			dbo.BSA_Foodservice_Items_Master.UPC,
			dbo.BSA_Foodservice_Items_Master.Net_Weight,
			<!------ TODO ----->
			dbo.BSA_Foodservice_Items_Master.#approvalGroupType.productGroupIDField#,
			dbo.BSA_Foodservice_Items_Master.Description,
			dbo.Contract_Products.Product_Type_ID,
			dbo.Contract_Products.Contract_Products_ID,
			dbo.Contract_Products.Product_Group_Level_ID,
			dbo.Contract_Products.Product_Group_ID
	FROM	dbo.Contract_Products
			INNER JOIN	dbo.BSA_Foodservice_Items_Master ON
			dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
	WHERE 	dbo.Contract_Products.Contract_Main_ID = '#FORM.Contract_Main_ID#'
			AND dbo.Contract_Products.Deleted = 0
	AND 	( -- start
				(--start Product_Type_ID = 1
					dbo.Contract_Products.Product_Type_ID = 1
					AND	EXISTS
					(
						SELECT 	Program_Product_Volume_ID
						FROM	Program_Product_Volume
						WHERE	Deleted = 0
						AND		Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND		ISNULL(Program_Product_Volume.Volume_LB, 0) > 0
						AND		Contract_Products.Product_Type_ID = 1
					)

				)--end Product_Type_ID = 1
				OR
				(--start Product_Type_ID = 2
					dbo.Contract_Products.Product_Type_ID = 2
					AND EXISTS
					(
						SELECT 	Program_Product_Volume_ID
						FROM	Program_Product_Volume
						WHERE	Deleted = 0
						AND		Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND		ISNULL(Program_Product_Volume.Volume_LB, 0) > 0
						AND		Contract_Products.Product_Type_ID = 2
					)

				)--end Product_Type_ID = 2
				OR
				(--start Product_Type_ID = 4
					dbo.Contract_Products.Product_Type_ID = 4
					AND exists
					(
						SELECT 	Program_Product_Volume_ID
						FROM	Program_Product_Volume
						WHERE	Deleted = 0
						AND		Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND		ISNULL(Program_Product_Volume.Volume_LB, 0) > 0
						AND		Contract_Products.Product_Type_ID = 4
					)

				)--end Product_Type_ID = 4
				OR
				(--start Product_Type_ID = 5
					dbo.Contract_Products.Product_Type_ID = 5
					AND exists
					(
						SELECT 	Program_Product_Volume_ID
						FROM	Program_Product_Volume
						WHERE	Deleted = 0
						AND		Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND		ISNULL(Program_Product_Volume.Volume_LB, 0) > 0
						AND		Contract_Products.Product_Type_ID = 5
					)
				)--end Product_Type_ID = 5
				OR
				(--start Product_Type_ID = 8
					dbo.Contract_Products.Product_Type_ID = 8
					AND exists
					(
						SELECT 	Program_Product_Volume_ID
						FROM	Program_Product_Volume
						WHERE	Deleted = 0
						AND		Program_Product_Volume.BSA_Foodservice_Items_Master_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
						AND		ISNULL(Program_Product_Volume.Volume_LB, 0) > 0
						AND		Contract_Products.Product_Type_ID = 8
					)
				)--end Product_Type_ID = 8
				<!---TSF: Modification Bid Request--->
				OR
				(--start Product_Type_ID = 10
					dbo.Contract_Products.Product_Type_ID = 10
					AND exists
					(
						SELECT 	Program_Bid_Request_Product_ID
						FROM 	Program_Bid_Request_Product
						WHERE 	Deleted = 0
						AND 	Program_Bid_Request_Product.Contract_Products_ID = Contract_Products.Contract_Products_ID
					)

				)--end Product_Type_ID = 10

			)-- end

	ORDER BY dbo.BSA_Foodservice_Items_Master.Item
</CFQUERY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>


<!---What to multiply by in order to get the appropriate display--->
<cfquery name="GetMarginView" datasource="#application.datasource#">
SELECT *
FROM Margin_View
</cfquery>

<Cfset MarginViewType = GetMarginView.Margin_View_Type>

<!---How to describe the UOM for it--->
<cfif MarginViewType IS 1>
	<cfset MarginTypeDesc = "CS">
	<cfset LongDesc = "case">
	<cfset Multiplier = "Net_Weight">
<cfelseif MarginViewType IS 2>
	<cfset MarginTypeDesc = "LB">
	<cfset Multiplier = 1>
	<cfset LongDesc = "pound">
<cfelseif MarginViewType IS 3>
	<cfset MarginTypeDesc = "CS EQ">
	<cfset Multiplier ="Net_Weight">
	<cfset LongDesc = "case equivalent">
<cfelse>
	<!---Get the type for the program--->
	<cfif ProgramUOM IS 1>
		<cfset MarginTypeDesc = "CS">
		<cfset LongDesc = "case">
		<cfset Multiplier = "Net_Weight">
	<cfelseif ProgramUOM IS 2>
		<cfset MarginTypeDesc = "LB">
		<cfset Multiplier = 1>
		<cfset LongDesc = "pound">
	<cfelse>
		<cfset MarginTypeDesc = "CS EQ">
		<cfset Multiplier = "Net_Weight">
		<cfset LongDesc = "case equivalent">
	</cfif>
</cfif>


<!--- START OffInvoice --->
<CFQUERY NAME="getOffInvoiceProducts" DBTYPE="query">
	SELECT *
	FROM getProducts
	WHERE Product_Type_ID = 8
</CFQUERY>

<CFIF getProgramSettngs.Generic_Type IS "Distributor Off-Invoice">
	<cfif getOffInvoiceProducts.recordcount GT 0>
		<DIV STYLE="font-size: 15px; font-weight:bold; color: Navy;">Off Invoice</DIV>
		<HR COLOR="orange">
		<cfif ListFindNoCase(ValueList(getOffInvoiceProducts.Product_Group_Level_ID), "1", ",")>
			<cfset anyDiscountTypeHasAllProducts = anyDiscountTypeHasAllProducts + 1>
			<table width="100%" cellpadding="0" cellspacing="0" align="center">
                <tr>
                    <td style="color:red;">All products selected. Margin not available.</td>
                </tr>
			</table>
		<cfelse>
			<table class="Maintable" width="100%" cellpadding="0" cellspacing="0" align="center">
				<tr bgcolor="#FFCE84" valign="bottom">
					<td>&nbsp;</td>
					<td ID="header" width="100%"><B>Description</B></td>

					<cfoutput><TD ID="header" NOWRAP><B>#Program_Volume.defaultUOT.getDesc()# #MarginTypeDesc#</B></TD></cfoutput>
					<TD ID="header"><B>Rate</B></TD>
					<TD ID="header"><B>Cost</B></TD>
					<TD ID="header" NOWRAP><B>Cost Adj.</B></TD>
					<CFIF ShowTPA EQ 1><TD ID="header" NOWRAP><B><CFOUTPUT>#Current_Trade_Label#</CFOUTPUT> Adj.</B></TD></CFIF>
					<TD ID="header" align="center"><B>Margin</B></TD>
					<TD ID="header" align="center"><B>%</B></TD>
					<!--- margin target --->
					<cfif margin_target_status EQ 1>
                    	<TD ID="header" align="center" nowrap><B>Target %</B></TD>
					</cfif>
				</tr>
			<CFLOOP QUERY="getOffInvoiceProducts">
				<CFQUERY NAME="getOffInvoiceMargins" datasource="#application.datasource#">
				SELECT *
				FROM Contract_Product_Margin
				WHERE Contract_Product_ID = '#getOffInvoiceProducts.Contract_Products_ID#' AND Deleted = 0
				</CFQUERY>

				<CFSET ThisContractProductID = getOffInvoiceProducts.Contract_Products_ID>

				<cfset NoPriceListProductBit = 0>
				<cfif listfind(getPercentOffInvoiceCID_List, ThisContractProductID) NEQ 0 AND trim(numberformat(getOffInvoiceMargins.OER_LB,'_-___,___,___,___,___.____')) EQ "0.000" >
					<cfset NoPriceListProductBit = 1>
				</cfif>

				<CFOUTPUT>
				<CFSET MarginOutOfRangeColumnID = "Row_"&replace(createuuid(), "-","_","ALL")>
				<CFSET arrayOfRowIDs[arraylen(arrayOfRowIDs)+1] = MarginOutOfRangeColumnID>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
					<td ALIGN="right">&nbsp;</td>
					<TD NOWRAP>#getOffInvoiceProducts.Item# - #getOffInvoiceProducts.Description#</TD>
					<TD ALIGN="center" NOWRAP>
					<cfset productVolume = getOffInvoiceMargins.OEV_LB />
					<CFIF len(trim(productVolume)) GT 0>
						<cfset productVolume = Program_Volume.convertToDefaultVolumeUOT(productVolume, currentVolumeMultiplier) />

					<!---Sets the amount to multiply by--->
					<Cfif Multiplier IS "Net_Weight">
						<cfset ThisMultiplier = getOffInvoiceProducts.Net_Weight>
					<Cfelse>
						<cfset ThisMultiplier = Multiplier>
					</CFIF>

					<cfset ProductVolume = ProductVolume / ThisMultiplier>
						#trim(numberformat(Round(productVolume),'_-___,___,___,___,___'))#
					<CFELSE>
						No Data
					</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
					<CFIF NoPriceListProductBit EQ 1>
						<SPAN style="color: red">*IDC</SPAN>
					<CFELSE>
						<CFIF len(trim(getOffInvoiceMargins.OER_LB)) GT 0>
							<CFSET this = (makeNumeric(getOffInvoiceMargins.OER_LB) * ThisMultiplier)>
							<CFIF this LT 0>
								<span STYLE="color: red;">
									<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
									[ $ #displayThis# ]
								</span>
							<CFELSE>
								<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
								$ #this#
							</CFIF>
						<CFELSE>
							No Data
						</CFIF>
					</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
					<CFIF len(trim(getOffInvoiceMargins.ICC)) GT 0>
						<CFSET this = (makeNumeric(getOffInvoiceMargins.ICC) * ThisMultiplier)>
						<CFIF this LT 0>
							<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
								[ $ #displayThis# ]
							</span>
						<CFELSE>
							<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____')) >
							$ #this#
						</CFIF>
					<CFELSE>
						No Data
					</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
					<CFIF len(trim(getOffInvoiceMargins.NCA)) GT 0>
						<CFSET this = (makeNumeric(getOffInvoiceMargins.NCA) * ThisMultiplier)>
						<CFIF this LT 0>
							<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
								[ $ #displayThis# ]
							</span>
						<CFELSE>
							<CFSET this = (numberformat(this,'_-___,___,___,___,___.____'))>
							$ #this#
						</CFIF>
					<CFELSE>
						No Data
					</CFIF>
					</TD>
					<CFIF ShowTPA EQ 1>
						<TD ALIGN="center" NOWRAP>
						<CFIF len(trim(getOffInvoiceMargins.TPA)) GT 0>
							<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation(#ThisContractProductID#)">
							<CFSET this = (makeNumeric(getOffInvoiceMargins.TPA) * ThisMultiplier)>
							<CFIF this LT 0>
								<span STYLE="color: red;">
									<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
									[ $ #displayThis# ]
								</span>
							<CFELSE>
								<CFSET this = (numberformat(this,'_-___,___,___,___,___.____'))>
								$ #this#
							</CFIF>
							</A>
						<CFELSE>
							No Data
						</CFIF>
						</TD>
					</CFIF>
					<TD ALIGN="center" NOWRAP ID="#MarginOutOfRangeColumnID#_MarginValue">
					<cfif approval_method EQ 1>
						<SPAN ID="#MarginOutOfRangeColumnID#"></SPAN>
					</cfif>
					<CFIF len(trim(getOffInvoiceMargins.OEM)) GT 0>
						<CFSET this = (makeNumeric(getOffInvoiceMargins.OEM) * ThisMultiplier)>

						<CFIF this LT 0>
							<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
								[ $ #displayThis# ]
							</span>
						<CFELSE>
							<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
							$ #this#
						</CFIF>
					<CFELSE>
						<CFSET this ="*IDC">
						<SPAN style="color: red">#this#</SPAN>
					</CFIF>
					</TD>

					<!--- %%%%%%%%%%%%%%%%%%%%%%% --->
					<cfset pctMargin = marginDisplay(getOffInvoiceMargins.OEM, getOffInvoiceMargins.PLB_LB)>
					<TD align="center" nowrap>

						<cfif approval_method EQ 2><SPAN ID="#MarginOutOfRangeColumnID#"></SPAN></cfif>
						<CFIF len(trim(pctMargin)) GT 0>
							<cfif approval_method EQ 2>
								<cfset this = pctMargin>
							</cfif>

							<CFIF pctMargin LT 0>
								<cfset pctMargin = (pctMargin)*(-1)>
								<span STYLE="color: red;">[ #pctMargin#% ]</span>
								<cfset pctMargin = (pctMargin)*(-1)>
							<CFELSE>
								#pctMargin#%
							</CFIF>
						<CFELSE>
							<cfif approval_method EQ 2>
								<CFSET this ="*IDC">
								<SPAN style="color: red">#this#</SPAN>
							<cfelse>
								<SPAN style="color: red">*IDC</SPAN>
							</cfif>
						</CFIF>
					</TD>

					<CFSET arrayMargins[arraylen(arrayMargins)+1][1] = this>
					<CFSET arrayMargins[arraylen(arrayMargins)][2] = evaluate("getOffInvoiceProducts.#approvalGroupType.productGroupIDField#")>
					<CFSET arrayMargins[arraylen(arrayMargins)][3] = pctMargin>

					<!--- margin target ---><cfif margin_target_status EQ 1><TD align="center" id="#MarginOutOfRangeColumnID#_target" nowrap>&nbsp;</TD></cfif>

				</TR>
				</CFOUTPUT>
			</CFLOOP>

			<CFIF getOffInvoiceProducts.recordcount EQ 0>
				<TR>
					<TD COLSPAN="100%" ALIGN="center">
						<SPAN STYLE="color: red; font-size: 13px; font-weight: bold;">NO PRODUCTS SUPPLIED</SPAN>
					</TD>
				</TR>
			</CFIF>
			</table>
		</cfif>
		<BR><BR>
	</cfif>
</CFIF>
<!--- End Off Invoice --->

<!--- START Fixed Price --->
<CFQUERY NAME="getFixedPriceProducts" DBTYPE="query">
	SELECT *
	FROM getProducts
	WHERE Product_Type_ID = 1
</CFQUERY>

<CFIF getProgramSettngs.Discount_Fixed_Prices EQ 1>
<cfif getFixedPriceProducts.recordcount GT 0>
	<DIV STYLE="font-size: 15px; font-weight:bold; color: Navy;">Fixed Price</DIV>
	<HR COLOR="orange">
	<table class="Maintable" width="100%" cellpadding="0" cellspacing="0" align="center">
		<TR BGCOLOR="#FFCE84" VALIGN="bottom">
			<td>&nbsp;</td>
			<TD ID="header" WIDTH="100%"><B>Description</B></TD>
			<cfoutput><TD ID="header" NOWRAP><B>#Program_Volume.defaultUOT.getDesc()# #MarginTypeDesc#</B></TD></cfoutput>
			<TD ID="header"><B>Price</B></TD>
			<TD ID="header"><B>Cost</B></TD>
			<TD ID="header" NOWRAP><B>Cost Adj.</B></TD>
			<CFIF ShowTPA EQ 1><TD ID="header" NOWRAP><B><CFOUTPUT>#Current_Trade_Label#</CFOUTPUT> Adj.</B></TD></CFIF>
			<TD ID="header" align="center"><B>Margin</B></TD>
			<TD ID="header" align="center"><B>%</B></TD>
			<!--- margin target ---><cfif margin_target_status EQ 1><TD ID="header" align="center" nowrap><B>Target %</B></TD></cfif>
		</TR>
	<CFLOOP QUERY="getFixedPriceProducts">

	<!---Multiply by correct amount--->
	<Cfif Multiplier IS "Net_Weight">
		<cfset ThisMultiplier = getFixedPriceProducts.Net_Weight>
	<Cfelse>
		<cfset ThisMultiplier = Multiplier>
	</CFIF>

		<CFQUERY NAME="getFixedPriceMargins" datasource="#application.datasource#">
		SELECT *
		FROM Contract_Product_Margin
		WHERE Contract_Product_ID = '#getFixedPriceProducts.Contract_Products_ID#' AND Deleted = 0
		</CFQUERY>
		<CFSET ThisContractProductID = getFixedPriceProducts.Contract_Products_ID>
		<CFOUTPUT>
		<CFSET MarginOutOfRangeColumnID = "Row_"&replace(createuuid(), "-","_","ALL")>
		<CFSET arrayOfRowIDs[arraylen(arrayOfRowIDs)+1] = MarginOutOfRangeColumnID>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<td ALIGN="right">&nbsp;</td>
			<TD NOWRAP>#getFixedPriceProducts.Item# - #getFixedPriceProducts.Description#</TD>
			<TD ALIGN="center" NOWRAP>
			<cfset productVolume = getFixedPriceMargins.FPV_LB />
			<CFIF len(trim(productVolume)) GT 0>
				<cfset productVolume = (Program_Volume.convertToDefaultVolumeUOT(productVolume, currentVolumeMultiplier) / ThisMultiplier) />
				#trim(numberformat(Round(productVolume),'_-___,___,___,___,___'))#
			<CFELSE>
				No Data
			</CFIF>
			</TD>
			<TD ALIGN="center" NOWRAP>
			<CFIF len(trim(getFixedPriceMargins.FPR_LB)) GT 0>
				<CFSET this = (makeNumeric(getFixedPriceMargins.FPR_LB) * ThisMultiplier)>
				<CFIF this LT 0>
					<span STYLE="color: red;">
						<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
						[ $ #displayThis# ]
					</span>
				<CFELSE>
					<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
					$ #this#
				</CFIF>
			<CFELSE>
				No Data
			</CFIF>
			</TD>
			<TD ALIGN="center" NOWRAP>
			<CFIF len(trim(getFixedPriceMargins.ICC)) GT 0>
				<CFSET this = (makeNumeric(getFixedPriceMargins.ICC) * ThisMultiplier)>
				<CFIF this LT 0>
					<span STYLE="color: red;">
						<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
						[ $ #displayThis# ]
					</span>
				<CFELSE>
					<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
					$ #this#
				</CFIF>
			<CFELSE>
				No Data
			</CFIF>
			</TD>
			<TD ALIGN="center" NOWRAP>
			<CFIF len(trim(getFixedPriceMargins.NCA)) GT 0>
				<CFSET this = (makeNumeric(getFixedPriceMargins.NCA) * ThisMultiplier)>
				<CFIF this LT 0>
					<span STYLE="color: red;">
						<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
						[ $ #displayThis# ]
					</span>
				<CFELSE>
					<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
					$ #this#
				</CFIF>
			<CFELSE>
				No Data
			</CFIF>
			</TD>
			<CFIF ShowTPA EQ 1>
				<TD ALIGN="center" NOWRAP>
				<CFIF len(trim(getFixedPriceMargins.TPA)) GT 0>
					<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation(#ThisContractProductID#)">
					<CFSET this = (makeNumeric(getFixedPriceMargins.TPA) * ThisMultiplier)>
					<CFIF this LT 0>
						<span STYLE="color: red;">
							<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
							[ $ #displayThis# ]
						</span>
					<CFELSE>
						<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
						$ #this#
					</CFIF>
					</A>
				<CFELSE>
					No Data
				</CFIF>
				</TD>
			</CFIF>
			<TD ALIGN="center" NOWRAP ID="#MarginOutOfRangeColumnID#_MarginValue">
			<cfif approval_method EQ 1>
				<SPAN ID="#MarginOutOfRangeColumnID#"></SPAN>
			</cfif>
			<CFIF len(trim(getFixedPriceMargins.FPM)) GT 0>
				<CFSET this = (makeNumeric(getFixedPriceMargins.FPM)* ThisMultiplier)>
				<CFIF this LT 0>
					<span STYLE="color: red;">
						<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
						[ $ #displayThis# ]
					</span>
				<CFELSE>
					<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
					$ #this#
				</CFIF>
			<CFELSE>
				<CFSET this ="*IDC">
				<SPAN style="color: red">#this#</SPAN>
			</CFIF>
			</TD>

			<!--- %%%%%%%%%%%%%%%%%%%%%%% --->
			<cfset pctMargin = marginDisplay(getFixedPriceMargins.FPM, getFixedPriceMargins.FPR_LB)>
			<TD align="center" nowrap>

				<cfif approval_method EQ 2><SPAN ID="#MarginOutOfRangeColumnID#"></SPAN></cfif>
				<CFIF len(trim(pctMargin)) GT 0>
					<cfif approval_method EQ 2>
						<cfset this = pctMargin>
					</cfif>

					<CFIF pctMargin LT 0>
						<cfset pctMargin = (pctMargin)*(-1)>
						<span STYLE="color: red;">[ #pctMargin#% ]</span>
						<cfset pctMargin = (pctMargin)*(-1)>
					<CFELSE>
						#pctMargin#%
					</CFIF>
				<CFELSE>
					<cfif approval_method EQ 2>
						<CFSET this ="*IDC">
						<SPAN style="color: red">#this#</SPAN>
					<cfelse>
						<SPAN style="color: red">*IDC</SPAN>
					</cfif>
				</CFIF>
			</TD>

			<CFSET arrayMargins[arraylen(arrayMargins)+1][1] = this>
			<CFSET arrayMargins[arraylen(arrayMargins)][2] = evaluate("getFixedPriceProducts.#approvalGroupType.productGroupIDField#")>
			<CFSET arrayMargins[arraylen(arrayMargins)][3] = pctMargin>

			<!--- margin target ---><cfif margin_target_status EQ 1><TD align="center" id="#MarginOutOfRangeColumnID#_target" nowrap>&nbsp;</TD></cfif>

		</TR>
		</CFOUTPUT>
	</CFLOOP>

	<CFIF getFixedPriceProducts.recordcount EQ 0>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<SPAN STYLE="color: red; font-size: 13px; font-weight: bold;">NO PRODUCTS SUPPLIED</SPAN>
			</TD>
		</TR>
	</CFIF>
	</table>
	<BR><BR>
</cfif>
</CFIF>
<!--- End Fixed Price --->

<!--- START Rebate --->
<CFIF getProgramSettngs.Discount_Rebates EQ 1>
	<CFQUERY NAME="getRebateProducts" DBTYPE="query">
		SELECT *
		FROM getProducts
		WHERE Product_Type_ID = 2
	</CFQUERY>
	<cfif getRebateProducts.recordcount GT 0>
		<DIV STYLE="font-size: 15px; font-weight:bold; color: Navy;"><CFOUTPUT>#Current_Rebate_Label#</CFOUTPUT></DIV>
		<HR COLOR="orange">
		<cfif ListFindNoCase(ValueList(getRebateProducts.Product_Group_Level_ID), "1", ",")>
			<cfset anyDiscountTypeHasAllProducts = anyDiscountTypeHasAllProducts + 1>
			<table width="100%" cellpadding="0" cellspacing="0" align="center">
				<tr>
				<td style="color:red;">All products selected. Margin not available.</td>
				</tr>
			</table>
		<cfelse>
			<table class="Maintable" width="100%" cellpadding="0" cellspacing="0" align="center">
				<tr bgcolor="#FFCE84" VALIGN="bottom">
					<td>&nbsp;</td>
					<TD ID="header" WIDTH="100%"><B>Description</B></TD>
					<cfoutput><TD ID="header" NOWRAP><B>#Program_Volume.defaultUOT.getDesc()# #MarginTypeDesc#</B></TD></cfoutput>
					<TD ID="header"><B><CFOUTPUT>#Current_Rebate_Label#</CFOUTPUT></B></TD>
					<TD ID="header"><B>Cost</B></TD>
					<TD ID="header" NOWRAP><B>Cost Adj.</B></TD>
					<CFIF ShowTPA EQ 1><TD ID="header" NOWRAP><B><CFOUTPUT>#Current_Trade_Label#</CFOUTPUT> Adj.</B></TD></CFIF>
					<TD ID="header" align="center"><B>Margin</B></TD>
					<TD ID="header" align="center"><B>%</B></TD>
					<!--- margin target ---><cfif margin_target_status EQ 1><TD ID="header" align="center" nowrap><B>Target %</B></TD></cfif>
				</TR>

			<CFLOOP QUERY="getRebateProducts">
				<CFQUERY NAME="getRebateMargins" datasource="#application.datasource#">
				SELECT *
				FROM Contract_Product_Margin
				WHERE Contract_Product_ID = '#getRebateProducts.Contract_Products_ID#' AND Deleted = 0
				</CFQUERY>
				<CFSET ThisContractProductID = getRebateProducts.Contract_Products_ID>
				<!---set the item master id before going into the loop--->
				<cfset itemMasterID = getRebateProducts.BSA_Foodservice_Items_Master_ID />

				<Cfif Multiplier IS "Net_Weight">
					<cfset ThisMultiplier = getRebateProducts.Net_Weight>
				<Cfelse>
					<cfset ThisMultiplier = Multiplier>
				</CFIF>

				<!--- is this product in a % component with no pricelist value> --->
				<cfset NoPriceListProductBit = 0>
				<cfif listfind(getPercentRebateCID_List, ThisContractProductID) NEQ 0 AND trim(numberformat(getRebateMargins.RER_LB,'_-___,___,___,___,___.____')) EQ "0.000" >
					<cfset NoPriceListProductBit = 1>
				</cfif>

				<CFOUTPUT>
				<CFSET MarginOutOfRangeColumnID = "Row_"&replace(createuuid(), "-","_","ALL")>
				<CFSET arrayOfRowIDs[arraylen(arrayOfRowIDs)+1] = MarginOutOfRangeColumnID>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
					<td ALIGN="right">&nbsp;</td>
					<TD NOWRAP>#getRebateProducts.Item# - #getRebateProducts.Description#</TD>
					<TD ALIGN="center" NOWRAP>
					<cfset productVolume = getRebateMargins.REV_LB />
					<CFIF len(trim(productVolume)) GT 0>
						<cfset productVolume = (Program_Volume.convertToDefaultVolumeUOT(productVolume, currentVolumeMultiplier) / ThisMultiplier) />
						<CFSET this = #trim(numberformat(round(productVolume),'_-___,___,___,___,___'))#>
						#this#
					<CFELSE>
						No Data
					</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
					<CFIF len(trim(getRebateMargins.RER_LB)) GT 0>

						<!--- <A STYLE="cursor:pointer;" ONCLICK="showRebateCalculation(#ThisContractProductID#)"> --->

						<cfset RebateMargin = getRebateMargins.RER_LB * ThisMultiplier>
						<A STYLE="cursor:pointer;" ONCLICK="showRebateCalculation('#itemMasterID#')"><CFIF NoPriceListProductBit EQ 1><SPAN style="color: red">*IDC</SPAN><CFELSE>$ #trim(numberformat(RebateMargin,'_-___,___,___,___,___.____'))#</CFIF></a>
					<CFELSE>
						No Data
					</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
					<CFIF len(trim(getRebateMargins.ICC)) GT 0>
						<CFSET this = (makeNumeric(getRebateMargins.ICC) * ThisMultiplier)>
						<CFIF this LT 0>
							<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___,___.____'))>
								[ $ #displayThis# ]
							</span>
						<CFELSE>
							<CFSET this = trim(numberformat(this,'_-___,___,___,___,___,___.____'))>
							$ #this#
						</CFIF>
					<CFELSE>
						No Data
					</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
					<CFIF len(trim(getRebateMargins.NCA)) GT 0>
						<CFSET this = (makeNumeric(getRebateMargins.NCA) * ThisMultiplier)>
						<CFIF this LT 0>
							<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___,___.____'))>
								[ $ #displayThis# ]
							</span>
						<CFELSE>
							<CFSET this = trim(numberformat(this,'_-___,___,___,___,___,___.____'))>
							$ #this#
						</CFIF>
					<CFELSE>
						No Data
					</CFIF>
					</TD>
					<CFIF ShowTPA EQ 1>
		                <CFIF AdjustTPA EQ 0>
		                    <TD ALIGN="center" NOWRAP>
							<CFIF len(trim(getRebateMargins.TPA)) GT 0>
								<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation(#ThisContractProductID#)">
									<CFSET this = (makeNumeric(getRebateMargins.TPA) * ThisMultiplier)>
									<CFIF this LT 0>
										<CFSET this = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
										<span STYLE="color: red;">
											[ $ #this# ]
										</span>
									<CFELSE>
										<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
										$ #this#
									</CFIF>
								</A>
							<CFELSE>
								No Data
							</CFIF>
							</TD>
		                <CFELSE>
							<!--- adjust TPA --->
							<TD ALIGN="center" NOWRAP>
							<CFIF len(trim(getRebateMargins.TPA)) GT 0>
								<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation(#ThisContractProductID#)">
								<CFSET this = (makeNumeric(getRebateMargins.TPA) * ThisMultiplier)>
								<cfquery name="getTPAadjstment" dbtype="query">
									SELECT Parent_RER_LB
									FROM getRebateProductsInformationForThisProgram
									WHERE Contract_Products_ID = #ThisContractProductID#
								</cfquery>

								<CFIF getTPAadjstment.recordcount GT 0>
									<CFSET this = this - (makeNumeric(getTPAadjstment.Parent_RER_LB) * ThisMultiplier)>
								</CFIF>

								<CFIF this LT 0>
									<span STYLE="color: red;">
										<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
										[ $ #displayThis# ]
									</span>
								<CFELSE>
									<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
									$ #this#
								</CFIF>
								</A>
							<CFELSE>
								No Data
							</CFIF>
							</TD>
						</CFIF>
		            </CFIF>

					<TD ALIGN="center" NOWRAP ID="#MarginOutOfRangeColumnID#_MarginValue">
					<cfif approval_method EQ 1>
						<SPAN ID="#MarginOutOfRangeColumnID#"></SPAN>
					</cfif>

					<CFSET ThisMargin = getRebateMargins.REM>
					<CFIF NoPriceListProductBit EQ 1>
						<CFSET ThisMargin = "">
					</CFIF>

					<CFIF len(trim(ThisMargin)) GT 0>
						<CFSET this = (makeNumeric(getRebateMargins.REM) * ThisMultiplier)>
						<CFIF this LT 0>
							<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___,___.____'))>
								[ $ #displayThis# ]
							</span>
						<CFELSE>
							<CFSET this = trim(numberformat(this,'_-___,___,___,___,___,___.____'))>
							$ #this#
						</CFIF>
					<CFELSE>
						<CFSET this ="*IDC">
						<SPAN style="color: red">#this#</SPAN>
					</CFIF>
				</TD>

				<!--- %%%%%%%%%%%%%%%%%%%%%%% --->
				<cfset pctMargin = marginDisplay(getRebateMargins.REM, getRebateMargins.PLB_LB)>
				<TD align="center" nowrap>
					<cfif approval_method EQ 2><SPAN ID="#MarginOutOfRangeColumnID#"></SPAN></cfif>
					<CFIF len(trim(pctMargin)) GT 0>
						<cfif approval_method EQ 2>
							<cfset this = pctMargin>
						</cfif>

						<CFIF pctMargin LT 0>
								<cfset pctMargin = (pctMargin)*(-1)>
								<span STYLE="color: red;">[ #pctMargin#% ]</span>
								<cfset pctMargin = (pctMargin)*(-1)>
						<CFELSE>
							#pctMargin#%
						</CFIF>
					<CFELSE>
						<cfif approval_method EQ 2>
							<CFSET this ="*IDC">
							<SPAN style="color: red">#this#</SPAN>
						<cfelse>
							<SPAN style="color: red">*IDC</SPAN>
						</cfif>
					</CFIF>
				</TD>

				<CFSET arrayMargins[arraylen(arrayMargins)+1][1] = this>
				<CFSET arrayMargins[arraylen(arrayMargins)][2] = evaluate("getRebateProducts.#approvalGroupType.productGroupIDField#")>
				<CFSET arrayMargins[arraylen(arrayMargins)][3] = pctMargin>

				<!--- margin target ---><cfif margin_target_status EQ 1><TD align="center" id="#MarginOutOfRangeColumnID#_target" nowrap>&nbsp;</TD></cfif>


				</TR>
				</CFOUTPUT>
			</CFLOOP>

			<CFIF getRebateProducts.recordcount EQ 0>
				<TR>
					<TD COLSPAN="100%" ALIGN="center">
						<SPAN STYLE="color: red; font-size: 13px; font-weight: bold;">NO PRODUCTS SUPPLIED</SPAN>
					</TD>
				</TR>
			</CFIF>

			</TABLE>
		</cfif>
	<BR><BR>
	</cfif>
</CFIF>
<!--- End Rebate --->

<!--- START Growth --->
<CFIF getProgramSettngs.Discount_Growth EQ 1>
	<CFQUERY NAME="getGrowthProducts" DBTYPE="query">
		SELECT *
		FROM getProducts
		WHERE Product_Type_ID = 4
	</CFQUERY>

	<cfif getGrowthProducts.recordcount GT 0>
		<DIV STYLE="font-size: 15px; font-weight:bold; color: Navy;">Growth Rate (Tier 1)</DIV>
		<HR COLOR="orange">
		<cfif ListFindNoCase(ValueList(getGrowthProducts.Product_Group_Level_ID), "1", ",")>
			<cfset anyDiscountTypeHasAllProducts = anyDiscountTypeHasAllProducts + 1>
			<table width="100%" cellpadding="0" cellspacing="0" align="center">
			<TR>
				<TD style="color:red;">All products selected. Margin not available.</TD>
			</TR>
			</table>
		<cfelse>
			<table class="Maintable" width="100%" cellpadding="0" cellspacing="0" align="center">
				<TR BGCOLOR="#FFCE84" VALIGN="bottom">
					<td>&nbsp;</td>
					<TD ID="header" WIDTH="100%"><B>Description</B></TD>
					<cfoutput><TD ID="header" NOWRAP><B>#Program_Volume.defaultUOT.getDesc()# #MarginTypeDesc#</B></TD></cfoutput>
					<TD ID="header"><B><CFOUTPUT>#Current_Rebate_Label#</CFOUTPUT></B></TD>
					<TD ID="header"><B>Cost</B></TD>
					<TD ID="header" NOWRAP><B>Cost Adj.</B></TD>
					<CFIF ShowTPA EQ 1><TD ID="header" NOWRAP><B><CFOUTPUT>#Current_Trade_Label#</CFOUTPUT> Adj.</B></TD></CFIF>
					<TD ID="header" align="center"><B>Margin</B></TD>
					<TD ID="header" align="center"><B>%</B></TD>
					<!--- margin target ---><cfif margin_target_status EQ 1><TD ID="header" align="center" nowrap><B>Target %</B></TD></cfif>
				</TR>
				<CFLOOP QUERY="getGrowthProducts">
					<CFQUERY NAME="getGrowthMargins" datasource="#application.datasource#">
						SELECT *
						FROM Contract_Product_Margin
						WHERE Contract_Product_ID = '#getGrowthProducts.Contract_Products_ID#' AND Deleted = 0
					</CFQUERY>

					<CFSET ThisContractProductID = getGrowthProducts.Contract_Products_ID>

					<cfset NoPriceListProductBit = 0>
					<cfif listfind(getPercentGrowthCID_List, ThisContractProductID) NEQ 0 AND trim(numberformat(getGrowthMargins.GRR_LB,'_-___,___,___,___,___.____')) EQ "0.000" >
						<cfset NoPriceListProductBit = 1>
					</cfif>

					<Cfif Multiplier IS "Net_Weight">
						<cfset ThisMultiplier = getGrowthProducts.Net_Weight>
					<Cfelse>
						<cfset ThisMultiplier = Multiplier>
					</CFIF>

					<CFOUTPUT>

					<CFSET MarginOutOfRangeColumnID = "Row_"&replace(createuuid(), "-","_","ALL")>
					<CFSET arrayOfRowIDs[arraylen(arrayOfRowIDs)+1] = MarginOutOfRangeColumnID>
					<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
						<td ALIGN="right">&nbsp;</td>
						<TD NOWRAP>#getGrowthProducts.Item# - #getGrowthProducts.Description#</TD>
						<TD ALIGN="center" NOWRAP>
						<cfset productVolume = getGrowthMargins.GRV_LB />
						<CFIF len(trim(productVolume)) GT 0>
							<cfset productVolume = (Program_Volume.convertToDefaultVolumeUOT(productVolume, currentVolumeMultiplier) / ThisMultiplier) />
							<CFSET this = #trim(numberformat(round(productVolume),'_-___,___,___,___,___'))#>
							#this#
						<CFELSE>
							No Data
						</CFIF>
						</TD>
						<TD ALIGN="center" NOWRAP>
						<CFIF NoPriceListProductBit EQ 1>
							<SPAN style="color: red">*IDC</SPAN>
						<CFELSE>
							<CFIF len(trim(getGrowthMargins.GRR_LB)) GT 0>
								<cfset GrowthVolume = getGrowthMargins.GRR_LB * ThisMultiplier>
								$ #trim(numberformat(GrowthVolume,'_-___,___,___,___,___.____'))#
							<CFELSE>
								No Data
							</CFIF>
						</CFIF>
						</TD>
						<TD ALIGN="center" NOWRAP>
						<CFIF len(trim(getGrowthMargins.ICC)) GT 0><CFSET this = (trim(numberformat(getGrowthMargins.ICC,'_-___,___,___,___,___.____')) * ThisMultiplier)>
							<CFIF this LT 0>
								<span STYLE="color: red;">
									<cfset this = (this)*(-1)>
									[ $ #this# ]
									<cfset this = (this)*(-1)>
								</span>
							<CFELSE>
								$ #this#
							</CFIF>
						<CFELSE>
							No Data
						</CFIF>
						</TD>
						<TD ALIGN="center" NOWRAP>
						<CFIF len(trim(getGrowthMargins.NCA)) GT 0>
							<CFSET this = (makeNumeric(getGrowthMargins.NCA) * ThisMultiplier)>
							<CFIF this LT 0>
								<span STYLE="color: red;">
									<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
									[ $ #displayThis# ]
								</span>
							<CFELSE>
								<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
								$ #this#
							</CFIF>
						<CFELSE>
							No Data
						</CFIF>
						</TD>
			   			<CFIF ShowTPA EQ 1>
			                <CFIF AdjustTPA EQ 0>
			                    <TD ALIGN="center" NOWRAP>
									<CFIF len(trim(getGrowthMargins.TPA)) GT 0>
										<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation(#ThisContractProductID#)">
										<CFSET this = (makeNumeric(getGrowthMargins.TPA) * ThisMultiplier)>
										<CFIF this LT 0>
											<span STYLE="color: red;">
												<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
												[ $ #displayThis# ]
											</span>
										<CFELSE>
											<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
											$ #this#
										</CFIF>
										</A>
									<CFELSE>
										No Data
									</CFIF>
									</TD>
			                	<CFELSE>
			                    	<!--- adjust tpa --->
			                    	<TD ALIGN="center" NOWRAP>
									<CFIF len(trim(getGrowthMargins.TPA)) GT 0>
										<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation(#ThisContractProductID#)">
											<CFSET this = (makeNumeric(getGrowthMargins.TPA) * ThisMultiplier)>

											<cfquery name="getTPAadjstment" dbtype="query">
												SELECT Parent_GRR_LB
												FROM getGrowthProductsInformationForThisProgram
												WHERE Contract_Products_ID = #ThisContractProductID#
											</cfquery>

											<CFIF getTPAadjstment.recordcount GT 0>
												<CFSET this = this - makeNumeric(getTPAadjstment.Parent_GRR_LB)>
											</CFIF>

											<CFIF this LT 0>
												<span STYLE="color: red;">
													<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
													[ $ #displayThis# ]
												</span>
											<CFELSE>
												<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
												$ #this#
											</CFIF>
										</A>
									<CFELSE>
										No Data
									</CFIF>
									</TD>
								</CFIF>
			            	</CFIF>

							<TD ALIGN="center" NOWRAP ID="#MarginOutOfRangeColumnID#_MarginValue">
							<cfif approval_method EQ 1>
								<SPAN ID="#MarginOutOfRangeColumnID#"></SPAN>
							</cfif>

							<CFSET ThisMargin = getGrowthMargins.GRM>
							<CFIF NoPriceListProductBit EQ 1>
								<CFSET ThisMargin = "">
							</CFIF>

							<CFIF len(trim(ThisMargin)) GT 0>
								<CFSET this = (makeNumeric(getGrowthMargins.GRM) * ThisMultiplier)>
								<CFIF this LT 0>
									<span STYLE="color: red;">
										<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
										[ $ #displayThis# ]
									</span>
								<CFELSE>
								<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
									$ #this#
								</CFIF>
							<CFELSE>
								<CFSET this ="*IDC">
								<SPAN style="color: red">#this#</SPAN>
							</CFIF>
							</TD>

							<!--- %%%%%%%%%%%%%%%%%%%%%%% --->
							<cfset pctMargin = marginDisplay(getGrowthMargins.GRM, getGrowthMargins.PLB_LB)>
							<TD align="center" nowrap>
								<cfif approval_method EQ 2><SPAN ID="#MarginOutOfRangeColumnID#"></SPAN></cfif>
								<CFIF len(trim(pctMargin)) GT 0>
									<cfif approval_method EQ 2>
										<cfset this = pctMargin>
									</cfif>

									<CFIF pctMargin LT 0>
										<cfset pctMargin = (pctMargin)*(-1)>
										<span STYLE="color: red;">[ #pctMargin#% ]</span>
										<cfset pctMargin = (pctMargin)*(-1)>
									<CFELSE>
										#pctMargin#%
									</CFIF>
								<CFELSE>
									<cfif approval_method EQ 2>
										<CFSET this ="*IDC">
										<SPAN style="color: red">#this#</SPAN>
									<cfelse>
										<SPAN style="color: red">*IDC</SPAN>
									</cfif>
								</CFIF>
							</TD>

							<CFSET arrayMargins[arraylen(arrayMargins)+1][1] = this>
							<CFSET arrayMargins[arraylen(arrayMargins)][2] = evaluate("getGrowthProducts.#approvalGroupType.productGroupIDField#")>
							<CFSET arrayMargins[arraylen(arrayMargins)][3] = pctMargin>

							<!--- margin target ---><cfif margin_target_status EQ 1><TD align="center" id="#MarginOutOfRangeColumnID#_target" nowrap>&nbsp;</TD></cfif>

						</TR>
					</CFOUTPUT>
				</CFLOOP>

				<CFIF getGrowthProducts.recordcount EQ 0>
					<TR>
						<TD COLSPAN="100%" ALIGN="center">
							<SPAN STYLE="color: red; font-size: 13px; font-weight: bold;">NO PRODUCTS SUPPLIED</SPAN>
						</TD>
					</TR>
				</CFIF>
			</TABLE>
		</cfif>
		<BR><BR>
	</cfif>
</CFIF>

<!--- Start Formula Pricing --->
<CFIF getProgramSettngs.Discount_Formula_Pricing EQ 1>
	<CFQUERY NAME="getRules" datasource="#application.datasource#">
		SELECT     	Program_Formula_Pricing_Rule_Mapped.Program_ID, Formula_Pricing_Rule.Rule_Name, Program_Formula_Pricing_Rule_Mapped_ID
		FROM        Program_Formula_Pricing_Rule_Mapped
					INNER JOIN Formula_Pricing_Rule
					ON
					Formula_Pricing_Rule.Formula_Pricing_Rule_ID = Program_Formula_Pricing_Rule_Mapped.Formula_Pricing_Rule_ID
					AND
					Formula_Pricing_Rule.Deleted = 0
		WHERE
					Program_Formula_Pricing_Rule_Mapped.Deleted = 0
					AND
					Program_Formula_Pricing_Rule_Mapped.Program_ID = #FORM.Contract_Main_ID#
		ORDER BY Formula_Pricing_Rule.Rule_Name
	</CFQUERY>

	<cfif getRules.recordcount GT 0>
		<CFQUERY NAME="getFPProducts" DBTYPE="query">
			SELECT *
			FROM getProducts
			WHERE Product_Type_ID = 5
		</CFQUERY>

		<DIV STYLE="font-size: 15px; font-weight:bold; color: Navy;">Formula Pricing</DIV>
		<HR COLOR="orange">

		<TABLE CELLSPACING="0" CELLPADDING="3" WIDTH="100%" BORDER="0">
		<CFIF getFPProducts.recordcount EQ 0>
			<TR>
				<TD COLSPAN="100%" ALIGN="center">
					<SPAN STYLE="color: red; font-size: 13px; font-weight: bold;">NO PRODUCTS SUPPLIED</SPAN>
				</TD>
			</TR>
		</CFIF>

		<CFOUTPUT QUERY="getRules" GROUP="Program_Formula_Pricing_Rule_Mapped_ID">
			<TR>
				<TD VALIGN="top" COLSPAN="100%" STYLE="font-size: 15px;"><B><U><CFOUTPUT>#Rule_Name#</CFOUTPUT></U></B></TD>
			</TR>
			<TR>
				<TD height="10" COLSPAN="100%"></TD>
			</TR>

			<CFQUERY NAME="getRuleProducts" datasource="#application.datasource#">
				SELECT *
				FROM Program_Formula_Pricing_Rule_Products
				WHERE
					Program_Formula_Pricing_Rule_ID = '#getRules.Program_Formula_Pricing_Rule_Mapped_ID#'
					AND
					Active = 1
					AND
					Deleted = 0
			</CFQUERY>

			<CFSET ListOfCTIDs = valuelist(getRuleProducts.Contract_Product_ID)>

			<CFIF listlen(ListOfCTIDs) gt 0>
				<CFQUERY NAME="getFPMargins" datasource="#application.datasource#">
					SELECT     *, dbo.BSA_Foodservice_Items_Master.Item, dbo.BSA_Foodservice_Items_Master.UPC,
					                     dbo.BSA_Foodservice_Items_Master.Description
					FROM         dbo.Contract_Products INNER JOIN
					                     dbo.BSA_Foodservice_Items_Master ON
					                     dbo.Contract_Products.BSA_Foodservice_Items_Master_ID = dbo.BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID INNER
					                      JOIN
					                     dbo.Contract_Product_Margin ON dbo.Contract_Products.Contract_Products_ID = dbo.Contract_Product_Margin.Contract_Product_ID
					WHERE     (dbo.Contract_Product_Margin.Contract_Product_ID IN (#ListOfCTIDs#)) AND (dbo.Contract_Product_Margin.Deleted = 0)
				</CFQUERY>

				<TR>
					<TD>
						<table class="Maintable" width="100%" cellpadding="0" cellspacing="0" align="center">
							<TR BGCOLOR="##FFCE84" VALIGN="bottom">
								<td>&nbsp;</td>
								<TD ID="header" WIDTH="100%"><B>Description</B></TD>
								<cfoutput><TD ID="header" NOWRAP><B>#Program_Volume.defaultUOT.getDesc()# #MarginTypeDesc#</B></TD></cfoutput>
								<TD ID="header"><B>Price</B></TD>
								<TD ID="header"><B>Cost</B></TD>
								<TD ID="header" NOWRAP><B>Cost Adj.</B></TD>
								<CFIF ShowTPA EQ 1><TD ID="header" NOWRAP><B>#Current_Trade_Label# Adj.</B></TD></CFIF>
								<TD ID="header" align="center"><B>Margin</B></TD>
								<TD ID="header" align="center"><B>%</B></TD>
								<!--- margin target --->
								<cfif margin_target_status EQ 1>
                                	<TD ID="header" align="center" nowrap><B>Target %</B></TD>
								</cfif>
							</TR>

							<CFLOOP QUERY="getFPMargins">

							<Cfif Multiplier IS "Net_Weight">
								<cfset ThisMultiplier = getFPMargins.Net_Weight>
							<Cfelse>
								<cfset ThisMultiplier = Multiplier>
							</CFIF>

								<CFSET ThisContractProductID = getFPMargins.Contract_Products_ID>
								<CFSET MarginOutOfRangeColumnID = "Row_"&replace(createuuid(), "-","_","ALL")>
								<CFSET arrayOfRowIDs[arraylen(arrayOfRowIDs)+1] = MarginOutOfRangeColumnID>
								<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
									<td ALIGN="right">&nbsp;</td>
									<TD NOWRAP>#getFPMargins.Item# - #getFPMargins.Description#</TD>
									<TD ALIGN="center" NOWRAP>
									<cfset productVolume = getFPMargins.KPV_LB />
									<CFIF len(trim(productVolume)) GT 0>
										<cfset productVolume = (Program_Volume.convertToDefaultVolumeUOT(productVolume, currentVolumeMultiplier) / ThisMultiplier) />
										#trim(numberformat(Round(productVolume),'_-___,___,___,___,___'))#
									<CFELSE>
										No Data
									</CFIF>
									</TD>
									<TD ALIGN="center" NOWRAP>
									<CFIF len(trim(getFPMargins.KPR_LB)) GT 0>
										<CFSET this = (makeNumeric(getFPMargins.KPR_LB) * ThisMultiplier)>
										<CFIF this LT 0>
											<span STYLE="color: red;">
												<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
												[ $ #displayThis# ]
											</span>
										<CFELSE>
											<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
											$ #this#
										</CFIF>
									<CFELSE>
										No Data
									</CFIF>
									</TD>
									<TD ALIGN="center" NOWRAP>
									<CFIF len(trim(getFPMargins.ICC)) GT 0>
										<CFSET this = (makeNumeric(getFPMargins.ICC) * ThisMultiplier)>
										<CFIF this LT 0>
											<span STYLE="color: red;">
												<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
												[ $ #displayThis# ]
											</span>
										<CFELSE>
											<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
											$ #this#
										</CFIF>
									<CFELSE>
										No Data
									</CFIF>
									</TD>
									<TD ALIGN="center" NOWRAP>
									<CFIF len(trim(getFPMargins.NCA)) GT 0>
										<CFSET this = (makeNumeric(getFPMargins.NCA) * ThisMultiplier)>
										<CFIF this LT 0>
											<span STYLE="color: red;">
												<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
												[ $ #displayThis# ]
											</span>
										<CFELSE>
											<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
											$ #this#
										</CFIF>
									<CFELSE>
										No Data
									</CFIF>
									</TD>
									<CFIF ShowTPA EQ 1>
										<TD ALIGN="center" NOWRAP>
										<CFIF len(trim(getFPMargins.TPA)) GT 0>
											<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation(#ThisContractProductID#)">
											<CFSET this = (makeNumeric(getFPMargins.TPA) * ThisMultiplier)>
											<CFIF this LT 0>
												<span STYLE="color: red;">
													<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
													[ $ #displayThis# ]
												</span>
											<CFELSE>
												<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
												$ #this#
											</CFIF>
											</A>
										<CFELSE>
											No Data
										</CFIF>
										</TD>
									</CFIF>

									<TD ALIGN="center" NOWRAP ID="#MarginOutOfRangeColumnID#_MarginValue">

									<cfif approval_method EQ 1>
										<SPAN ID="#MarginOutOfRangeColumnID#"></SPAN>
									</cfif>

									<CFIF len(trim(getFPMargins.KPM)) GT 0>

										<CFSET this = (makeNumeric(getFPMargins.KPM) * ThisMultiplier)>

										<CFIF this LT 0>
											<span STYLE="color: red;">
												<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
												[ $ #displayThis# ]
											</span>
										<CFELSE>
											<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
											$ #this#
										</CFIF>

									<CFELSE>

										<CFSET this ="*IDC">
										<SPAN style="color: red">#this#</SPAN>

									</CFIF>

									</TD>

									<!--- %%%%%%%%%%%%%%%%%%%%%%% --->
									<cfset pctMargin = marginDisplay(getFPMargins.KPM, getFPMargins.KPR_LB)>
									<TD align="center" nowrap>
										<cfif approval_method EQ 2><SPAN ID="#MarginOutOfRangeColumnID#"></SPAN></cfif>
										<CFIF len(trim(pctMargin)) GT 0>
											<cfif approval_method EQ 2>
												<cfset this = pctMargin>
											</cfif>

											<CFIF pctMargin LT 0>
													<cfset pctMargin = (pctMargin)*(-1)>
													<span STYLE="color: red;">[ #pctMargin#% ]</span>
													<cfset pctMargin = (pctMargin)*(-1)>
											<CFELSE>
												#pctMargin#%
											</CFIF>
										<CFELSE>
											<cfif approval_method EQ 2>
												<CFSET this ="*IDC">
												<SPAN style="color: red">#this#</SPAN>
											<cfelse>
												<SPAN style="color: red">*IDC</SPAN>
											</cfif>
										</CFIF>
									</TD>

									<CFSET arrayMargins[arraylen(arrayMargins)+1][1] = this>
									<CFSET arrayMargins[arraylen(arrayMargins)][2] = evaluate("getFPProducts.#approvalGroupType.productGroupIDField#")>
									<CFSET arrayMargins[arraylen(arrayMargins)][3] = pctMargin>

									<!--- margin target ---><cfif margin_target_status EQ 1><TD align="center" id="#MarginOutOfRangeColumnID#_target" nowrap>&nbsp;</TD></cfif>

								</TR>
							</CFLOOP>
						</TABLE>
					</TD>
				</TR>
			<CFELSE>
				<TR>
					<TD COLSPAN="100%" ALIGN="center">
						<SPAN STYLE="color: red; font-size: 13px; font-weight: bold;">NO PRODUCTS SUPPLIED</SPAN>
					</TD>
				</TR>
			</CFIF>
		</CFOUTPUT>
		</TABLE>
	</cfif>
</CFIF>
<!--- End Formula Pricing --->
<!---TSF: Modification Bid Request--->
<!--- START Bid Request --->
<CFIF getProgramSettngs.Generic_Type EQ "Bid Request">
<cfoutput>

	<!---get bid request products--->
	<CFQUERY NAME="getBidRequestProducts" DBTYPE="query">
		SELECT *
		FROM getProducts
		WHERE Product_Type_ID = 10
	</CFQUERY>

	<DIV STYLE="font-size: 15px; font-weight:bold; color: Navy;">Proposal</DIV>
	<HR COLOR="orange">
	<table class="Maintable" width="100%" cellpadding="0" cellspacing="0" align="center">

		<TR BGCOLOR="##FFCE84" VALIGN="bottom">
			<td>&nbsp;</td>
			<TD ID="header" WIDTH="100%"><B>Description</B></TD>
			<TD ID="header" NOWRAP><B>#Program_Volume.defaultUOT.getDesc()# #MarginTypeDesc#</B></TD>
			<TD ID="header" nowrap><B>Price Offered</B></TD>
			<TD ID="header"><B>Cost</B></TD>
			<TD ID="header" NOWRAP><B>Cost Adj.</B></TD>
			<CFIF ShowTPA EQ 1><TD ID="header" NOWRAP><B>#Current_Trade_Label# Adj.</B></TD></CFIF>
			<TD ID="header" align="center"><B>Margin</B></TD>
			<TD ID="header" align="center"><B>%</B></TD>
			<!--- margin target --->
			<cfif margin_target_status EQ 1><TD ID="header" align="center" nowrap><B>Target %</B></TD></cfif>
		</TR>

		<!---if we have bid request products then show them--->
		<cfif getBidRequestProducts.RecordCount>

			<CFLOOP QUERY="getBidRequestProducts">

				<CFQUERY NAME="getBidRequestMargins" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Contract_Product_Margin
					WHERE 	Contract_Product_ID = '#getBidRequestProducts.Contract_Products_ID#'
					AND 	Deleted = 0
				</CFQUERY>

				<Cfif Multiplier IS "Net_Weight">
					<cfset ThisMultiplier = getBidRequestProducts.Net_Weight>
				<Cfelse>
					<cfset ThisMultiplier = Multiplier>
				</CFIF>

				<CFSET ThisContractProductID = getBidRequestProducts.Contract_Products_ID>

				<CFSET MarginOutOfRangeColumnID = "Row_"&replace(createuuid(), "-","_","ALL")>
				<CFSET arrayOfRowIDs[arraylen(arrayOfRowIDs)+1] = MarginOutOfRangeColumnID>
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
					<td ALIGN="right">&nbsp;</td>
					<TD NOWRAP>#getBidRequestProducts.Item# - #getBidRequestProducts.Description#</TD>
					<TD ALIGN="center" NOWRAP>
						<cfset productVolume = getBidRequestMargins.QPV_LB />
						<CFIF len(trim(productVolume)) GT 0>
							<cfset productVolume = (Program_Volume.convertToDefaultVolumeUOT(productVolume, currentVolumeMultiplier) / ThisMultiplier) />
							#trim(numberformat(Round(productVolume),'_-___,___,___,___,___'))#
						<CFELSE>
							No Data
						</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
						<CFIF len(trim(getBidRequestMargins.QPR_LB)) GT 0>
							<CFSET this = (makeNumeric(getBidRequestMargins.QPR_LB) * ThisMultiplier)>
								<CFIF this LT 0>
									<span STYLE="color: red;">
										<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
										[ $ #displayThis# ]
									</span>
								<CFELSE>
									<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
									$ #this#
								</CFIF>
						<CFELSE>
							No Data
						</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
						<CFIF len(trim(getBidRequestMargins.ICC)) GT 0>
							<CFSET this = (makeNumeric(getBidRequestMargins.ICC) * ThisMultiplier)>
							<CFIF this LT 0>
								<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
								[ $ #displayThis# ]
								</span>
							<CFELSE>
								<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
								$ #this#
							</CFIF>
						<CFELSE>
							No Data
						</CFIF>
					</TD>
					<TD ALIGN="center" NOWRAP>
						<CFIF len(trim(getBidRequestMargins.NCA)) GT 0>
							<CFSET this = (makeNumeric(getBidRequestMargins.NCA) * ThisMultiplier)>
							<CFIF this LT 0>
								<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
								[ $ #displayThis# ]
								</span>
							<CFELSE>
								<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
								$ #this#
							</CFIF>
						<CFELSE>
							No Data
						</CFIF>
					</TD>

					<CFIF ShowTPA EQ 1>
						<TD ALIGN="center" NOWRAP>
							<CFIF len(trim(getBidRequestMargins.TPA)) GT 0>
								<A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation(#ThisContractProductID#)">
								<CFSET this = (makeNumeric(getBidRequestMargins.TPA) * ThisMultiplier)>
								<CFIF this LT 0>
									<span STYLE="color: red;">
										<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
										[ $ #displayThis# ]
									</span>
								<CFELSE>
									<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
									$ #this#
								</CFIF>
								</A>
							<CFELSE>
								No Data
							</CFIF>
						</TD>
					</CFIF>

					<TD ALIGN="center" NOWRAP ID="#MarginOutOfRangeColumnID#_MarginValue">
						<cfif approval_method EQ 1>
							<SPAN ID="#MarginOutOfRangeColumnID#"></SPAN>
						</cfif>
						<CFIF len(trim(getBidRequestMargins.QPM)) GT 0>
							<CFSET this = (makeNumeric(getBidRequestMargins.QPM) * ThisMultiplier)>
							<CFIF this LT 0>
								<span STYLE="color: red;">
								<CFSET displayThis = trim(numberformat(Abs(this),'_-___,___,___,___,___.____'))>
								[ $ #displayThis# ]
								</span>
							<CFELSE>
								<CFSET this = trim(numberformat(this,'_-___,___,___,___,___.____'))>
								$ #this#
							</CFIF>
						<CFELSE>
							<CFSET this ="*IDC">
							<SPAN style="color: red">#this#</SPAN>
						</CFIF>
					</TD>

					<!--- %%%%%%%%%%%%%%%%%%%%%%% --->
					<cfset pctMargin = marginDisplay(getBidRequestMargins.QPM, getBidRequestMargins.QPR_LB)>
					<TD align="center" nowrap>

						<cfif approval_method EQ 2><SPAN ID="#MarginOutOfRangeColumnID#"></SPAN></cfif>
						<CFIF len(trim(pctMargin)) GT 0>
							<cfif approval_method EQ 2>
								<cfset this = pctMargin>
							</cfif>

							<CFIF pctMargin LT 0>
								<cfset pctMargin = (pctMargin)*(-1)>
								<span STYLE="color: red;">[ #pctMargin#% ]</span>
								<cfset pctMargin = (pctMargin)*(-1)>
							<CFELSE>
								#pctMargin#%
							</CFIF>
						<CFELSE>
							<cfif approval_method EQ 2>
								<CFSET this ="*IDC">
								<SPAN style="color: red">#this#</SPAN>
							<cfelse>
								<SPAN style="color: red">*IDC</SPAN>
							</cfif>
						</CFIF>
					</TD>

					<CFSET arrayMargins[arraylen(arrayMargins)+1][1] = this>
					<CFSET arrayMargins[arraylen(arrayMargins)][2] = evaluate("getBidRequestProducts.#approvalGroupType.productGroupIDField#")>
					<CFSET arrayMargins[arraylen(arrayMargins)][3] = pctMargin>

					<!--- margin target --->
					<cfif margin_target_status EQ 1>
						<TD align="center" id="#MarginOutOfRangeColumnID#_target" nowrap>&nbsp;</TD>
					</cfif>

				</TR>

			</CFLOOP>

		<CFELSE>
			<TR>
				<TD COLSPAN="100%" ALIGN="center">
					<SPAN STYLE="color: red; font-size: 13px; font-weight: bold;">NO PRODUCTS SUPPLIED</SPAN>
				</TD>
			</TR>
		</CFIF>
	</TABLE>
	<BR><BR>
</cfoutput>

</CFIF>
<!--- End Bid Request --->

			<CFQUERY NAME="getProgramMargins" datasource="#application.datasource#">
				SELECT PTRM, PTTM, TLS, PTER
				FROM Contract_Main
				WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
			</CFQUERY>
			<CFOUTPUT>
				<BR>
				<DIV STYLE="font-size: 15px; font-weight:bold; color: Navy;" class="forceLeft">Program Summary</DIV>
				<HR COLOR="orange">
				<cfif anyDiscountTypeHasAllProducts GT 0>
				<table width="100%" cellpadding="0" cellspacing="0" align="center">
				<TR>
					<TD style="color:red;">All products selected. Margin not available.</TD>
				</TR>
				</TABLE>
				<cfelse>
				<TABLE BORDER="0">
					<TR>
						<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right"><B>TOTAL REVENUE:</B></TD>
						<CFSET data = makeNumeric(getProgramMargins.PTER)>
						<CFIF data LT 0><CFSET data = trim(numberformat(Abs(data),"_-__________.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $ #numberformat(data, '_,___,___,___.__')# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"_-__________.__"))><CFSET data = "<SPAN STYLE=""color: green;""><B>$#numberformat(data, '_,___,___,___.__')#</B></SPAN>"></CFIF><TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">#data#</TD>
					</TR>
					<TR>
						<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right"><B>RATED MARGINS:</B></TD>
						<CFSET data = makeNumeric(getProgramMargins.PTRM)>
						<CFIF data LT 0><CFSET data = trim(numberformat(Abs(data),"_-__________.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b> [ $ #numberformat(data, '_,___,___,___.__')# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"_-__________.__"))><CFSET data = "<SPAN STYLE=""color: green;""><B>$#numberformat(data, '_,___,___,___.__')#</B></SPAN>"></CFIF><TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">#data#</TD>
					</TR>
					<TR>
						<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right"><B>LUMP SUM:</B></TD>
						<CFSET data = makeNumeric(getProgramMargins.TLS)>
						<CFIF data LT 0><CFSET data = trim(numberformat(Abs(data),"_-__________.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $ #numberformat(data, '_,___,___,___.__')# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"_-__________.__"))><CFSET data = "<SPAN STYLE=""color: green;""><B>$#numberformat(data, '_,___,___,___.__')#</B></SPAN>"></CFIF><TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">#data#</TD>
					</TR>
					<TR>
						<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right"><B>TOTAL VOLUME:</B></TD>
						<CFSET data = makeNumeric(TotalProgramVolume)>
						<CFIF data LT 0><CFSET data = trim(numberformat(Abs(data),"___,___,___,___,___,___-__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ #data# #TotalProgramVolumeUOM# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"___,___,___,___,___,___-__"))><CFSET data = "<SPAN STYLE=""color: green;""><B>#data# #TotalProgramVolumeUOM#</B></SPAN>"></CFIF>
						<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><span id="overallMarginErrorSpan"></span>#data#</TD>
					</TR>
					<TR>
						<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right"><B>MARGIN:</B></TD>
						<CFSET data = makeNumeric(getProgramMargins.PTTM)>
						<CFIF data LT 0><CFSET data = trim(numberformat(Abs(data),"_-__________.__"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ $ #numberformat(data, '_,___,___,___.__')# ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"_-__________.__"))><CFSET data = "<SPAN STYLE=""color: green;""><B>$#numberformat(data, '_,___,___,___.__')#</B></SPAN>"></CFIF>
						<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right">#data#</TD>
					</TR>
					<TR>
						<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="right"><B>OVERALL MARGIN:</B></TD>
						<CFSET data = makeNumeric(marginDisplay(getProgramMargins.PTTM, getProgramMargins.PTER))>
						<CFIF data LT 0><CFSET data = trim(numberformat(Abs(data),"_-___._"))><CFSET data = "<SPAN STYLE=""color: red;""><b>[ #data#% ]</b></SPAN>"><CFELSE><CFSET data = trim(numberformat(data,"_-___._"))><CFSET data = "<SPAN STYLE=""color: green;""><B>#data#%</B></SPAN>"></CFIF>
						<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><span id="overallMarginErrorSpan"></span>#data#</TD>
					</TR>
				</TABLE>
				</cfif>
			</CFOUTPUT>

<cfset overallMargin = marginDisplay(trim(getProgramMargins.PTTM),trim(getProgramMargins.PTER))>
<CFSET LetUserApprove = 0>

<CFSET ICanApproveTheseProducts_Count = 0>

<!--- check the margins --->
<!--- <CFIF ApproverInZoneList GT 0 OR ApproverInRegionList GT 0 OR ApproverInMarketList GT 0 OR ApproverInDefaultList GT 0> --->
<CFIF ApproverInDefaultList GT 0>
	<!--- check for good margin data --->
	<CFSET VaildData = 1>

	<CFIF VaildData EQ 0>
		<!--- 1 or More Profit Margin Calculations Is Missing. --->
		<CFSET LetUserApprove = 0>
	</CFIF>

	<CFIF VaildData EQ 1>
		<cfif approvalGroupType.prodHierLevel GT 0>
			<!------ TODO, 6 should be from a variable ----->
			<cfset qGetProductHierarchyLevels = CreateObject("component", "components.products.Group.DataManager").getDistinctHierarchyLevel(getMaxLevel=1) />
			<cfset maxProdHierLevel = qGetProductHierarchyLevels.Product_Hierarchy_Level>
		</cfif>
		<cfloop index="x" from="1" to="#application.returned_customer_setting.approval_group_count#" step="1">
			<CFQUERY NAME="Group#x#Groups" datasource="#application.datasource#">
				SELECT
							<cfif approvalGroupType.prodHierLevel GT 0 AND approvalGroupType.prodHierLevel NEQ maxProdHierLevel>
							ph#maxProdHierLevel#.Product_Hierarchy_ID
							<cfelse>
							Margin_Group_Any_Group.Group_ID
							</cfif>	AS Group_ID,
							#approvalGroupType.tableName#.Target_Margin
				FROM		Margin_Group_Any_Group
							INNER JOIN	#approvalGroupType.tableName#
							ON Margin_Group_Any_Group.Group_ID = #approvalGroupType.tableName#.#approvalGroupType.IDField#
							<cfif approvalGroupType.prodHierLevel GT 0>
							AND Product_Hierarchy_Level = #approvalGroupType.prodHierLevel#
							<cfif approvalGroupType.prodHierLevel NEQ maxProdHierLevel>
							<!------ If the approval is not based on the last product hierarchy level, have to join and get the last level values ----->
								<cfloop index="thisProdHierLevel" from="#Evaluate(approvalGroupType.prodHierLevel+1)#" to="#maxProdHierLevel#" step="1">
								INNER JOIN Product_Hierarchy ph#thisProdHierLevel#
								ON	ph#thisProdHierLevel#.Deleted = 0
								AND	ph#thisProdHierLevel#.Product_Hierarchy_Level = #thisProdHierLevel#
								AND	ph#thisProdHierLevel#.Parent_Product_Hierarchy_ID =
									<cfif thisProdHierLevel EQ approvalGroupType.prodHierLevel+1>
									#approvalGroupType.tableName#.Product_Hierarchy_ID
									<cfelse>
									ph#Evaluate(thisProdHierLevel-1)#.Product_Hierarchy_ID
									</cfif>
								</cfloop>
							</cfif>
							</cfif>
				WHERE 		Margin_Group_Any_Group.Margin_Group_ID = #x#
							AND Margin_Group_Any_Group.DELETED = 0
			</CFQUERY>

			<cfset tempquery = evaluate('Group#x#Groups')>

			<CFSET "g#x#_List" = dyn_valuelist("tempquery.Group_ID")>
			<CFSET "g#x#_MarginTargetList" = dyn_valuelist("tempquery.target_margin")>

			<CFQUERY NAME="getProfileMargin" datasource="#application.datasource#">
				SELECT 	Amount
				FROM 	Margin_Group_Profile_Approval_Margins
				WHERE 	Profile_ID = #request.AccessStructure.Profiles_ID#
						AND Group_ID = #x#
						AND Approval_Method = #approval_method#
			</CFQUERY>
			<CFSET "g#x#_Margin" = getProfileMargin.Amount>
		</cfloop>


		<CFSET ICanApproveTheseProducts_Count = 0>
		<!--- verify margins against the profile data  --->

		<CFLOOP INDEX="LoopCount" FROM="1" TO="#arraylen(arrayMargins)#" STEP="1">

			<CFSET thisMarginData = arrayMargins[LoopCount][1]>

			<cfset MarginTargetArray[arraylen(MarginTargetArray)+1][1] 	= arrayOfRowIDs[LoopCount]><!--- row id --->
			<cfset MarginTargetArray[arraylen(MarginTargetArray)][2] 	= arrayMargins[LoopCount][3]><!--- calculated_margin --->
			<cfset MarginTargetArray[arraylen(MarginTargetArray)][3] 	= "*IDC"><!--- target_margin --->

			<!------ If the approval_method is total program margin, do not have to look at each product margin ----->

			<cfif approval_method EQ 3>

				<CFIF trim(thisMarginData) EQ "*IDC">
					<CFSET arrayOfRejectedMarginsRowIDs[arraylen(arrayOfRejectedMarginsRowIDs)+1][1] = arrayOfRowIDs[LoopCount]>
					<CFSET arrayOfRejectedMarginsRowIDs[arraylen(arrayOfRejectedMarginsRowIDs)][2] = thisMarginData>
					<cfset IDFound = 1>
				<CFELSE>
					<CFSET ICanApproveTheseProducts_Count = ICanApproveTheseProducts_Count+1>
				</CFIF>

			<cfelse>
				<CFSET Type_Code_ID_Found = false>
				<CFLOOP INDEX="InnerCount" FROM="1" TO="#application.returned_customer_setting.approval_group_count#" STEP="1">

					<CFSET ThisList = evaluate("g#InnerCount#_List")>
					<CFSET ThisMarginMin = evaluate("g#InnerCount#_Margin")>
					<CFSET ThisMarginTarget = evaluate("g#InnerCount#_MarginTargetList")>
					<cfset listlocation = Listfind(ThisList, arrayMargins[LoopCount][2])>
					<CFIF listlocation NEQ 0>
						<CFSET Type_Code_ID_Found = true>
						<cfset IDFound = 0>
						<CFIF trim(thisMarginData) EQ "*IDC">
							<CFSET arrayOfRejectedMarginsRowIDs[arraylen(arrayOfRejectedMarginsRowIDs)+1][1] = arrayOfRowIDs[LoopCount]>
							<CFSET arrayOfRejectedMarginsRowIDs[arraylen(arrayOfRejectedMarginsRowIDs)][2] = thisMarginData>
							<cfset IDFound = 1>
						</CFIF>

						<cfset MarginTargetArray[arraylen(MarginTargetArray)][3] 	= listgetat(ThisMarginTarget, listlocation)><!--- target_margin --->

						<CFIF (isnumeric(arrayMargins[LoopCount][1]) AND arrayMargins[LoopCount][1] GTE ThisMarginMin) OR ThisMarginMin EQ "*">
							<CFSET ICanApproveTheseProducts_Count = ICanApproveTheseProducts_Count+1>
						<CFELSE>
							<cfif IDFound EQ 0>
								<CFSET arrayOfRejectedMarginsRowIDs[arraylen(arrayOfRejectedMarginsRowIDs)+1][1] = arrayOfRowIDs[LoopCount]>
								<CFSET arrayOfRejectedMarginsRowIDs[arraylen(arrayOfRejectedMarginsRowIDs)][2] = ThisMarginMin>
							</cfif>
	 					</CFIF>
					</CFIF>
				</CFLOOP>
				<CFIF NOT Type_Code_ID_Found AND  ThisMarginMin EQ "*">
					<CFSET ICanApproveTheseProducts_Count = ICanApproveTheseProducts_Count+1>
					<CFSET arrayOfRejectedMarginsRowIDs[arraylen(arrayOfRejectedMarginsRowIDs)+1][1] = arrayOfRowIDs[LoopCount]>
					<CFSET arrayOfRejectedMarginsRowIDs[arraylen(arrayOfRejectedMarginsRowIDs)][2] = thisMarginData>
				</CFIF>

			</cfif><!------ approval_method EQ 3 ----->
		</CFLOOP>
	</CFIF>
	<CFIF ICanApproveTheseProducts_Count EQ arraylen(arrayMargins)>
		<CFSET LetUserApprove = 1>
	<CFELSE>
		<!--- One Of the Margins Is Out Of Your Reach --->
		<CFSET LetUserApprove = 0>
	</CFIF>

	<cfif approval_method EQ 3>
		<CFQUERY NAME="getProfileMargin" datasource="#application.datasource#">
			SELECT 	Amount
			FROM 	Margin_Group_Profile_Approval_Margins
			WHERE 	Profile_ID = #request.AccessStructure.Profiles_ID#
					AND Group_ID = 1
					AND Approval_Method = #approval_method#
		</CFQUERY>

		<cfset ThisMarginMin = getProfileMargin.Amount>

		<cfif isnumeric(ThisMarginMin)>
			<cfset ThisMarginMin = trim(numberformat(ThisMarginMin, '_-___._'))>
		</cfif>

		<cfif arraylen(arrayOfRejectedMarginsRowIDs) EQ 0>
			<CFIF (isnumeric(overallMargin) AND overallMargin GTE ThisMarginMin) OR ThisMarginMin EQ "*">
				<CFSET LetUserApprove = 1>
				<CFSET MarginTooLow = 0>
			</CFIF>
		<cfelse>
			<CFIF ThisMarginMin EQ "*">
				<CFSET LetUserApprove = 1>
				<CFSET MarginTooLow = 0>
			<cfelse>
				<cfset IDCApprovalRestriction = 1>
			</CFIF>
		</cfif>
	</cfif>

</CFIF>
<CFIF Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 0>
	<cfset ICanApproveTheseProducts_Count = 0>
	<cfset VaildData = 0>
	<cfset LetUserApprove = 0>
	<cfset approvalMessageToShow = 0>
</CFIF>

<!--- if this user if god no reason to run any analisys --->



<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: black; font-size: 10px; font-weight: bold;">All rates are per <cfoutput>#LongDesc#</cfoutput></DIV>
<HR WIDTH="50%" COLOR="orange" ID="DIV_DONT_PRINT">

<!------
Include file which checks for the program levels checks to
stop the user from requesting approval and also approval.
----->
<cfset getSettings = getProgramSettngs>
<cfset Contract_Main_ID = FORM.Contract_Main_ID>
<cfinclude template="common_approval_check.cfm">

<cfif getProgramInfo.Contract_Status_Type_IDX LTE 2 AND LetUserApprove EQ 1>
	<cfinclude template="contract_lumpsum_balance_info.cfm">
</cfif>
<!--------------------------------- Check LumpSum Cap ---------------------------------------------------->



<cfset XMaterialNotAvailable = 0 />
<!------ if group deal and distrubutor and operator is selected is required, check for X Material ----->
<cfif isGroupDeal AND LetUserApprove>
	<cfif appSettings.getUseXMaterial()>
		<cfset qXMaterialNotAvailable = CreateObject("component", "components.products.group.DataManager").isXMaterialNotInMaterialMaster(FORM.Contract_Main_ID) />
		<cfif qXMaterialNotAvailable.recordCount>
			<cfset XMaterialNotAvailable = 1 />
			<cfset LetUserApprove = 0 />
		</cfif>
	</cfif>
</cfif>


<cfset NumberOfRejectMargins = arraylen(arrayOfRejectedMarginsRowIDs)>
<cfset approvalMessageToShow = 0>
<CFIF letUserProceed EQ 0  AND LetUserApprove EQ 1>
	<cfset LetUserApprove = 0>
	<cfset approvalMessageToShow = 5>
<cfelseif XMaterialNotAvailable>
	<cfset approvalMessageToShow = 7>
<cfelseif LetUserApprove EQ 1 AND (anyDiscountTypeHasAllProducts GT 0 OR bAllDistributorProgram GT 0)>
	<cfset approvalMessageToShow = 4>
	<cfif Get_Profile_Settings.Approve_All_Products_Program NEQ 1>
		<cfset LetUserApprove = 0>
		<cfset approvalMessageToShow = 3>
	</cfif>
<CFELSEIF LetUserApprove EQ 1 AND isGroupDeal>
	<cfset approvalMessageToShow = 6>
	<CFIF Get_Profile_Settings.Approve_Group_Deals EQ 0>
		<CFSET LetUserApprove = 0>
	</CFIF>
<CFELSE>
	<CFIF approval_method neq 3>
		<CFIF NumberOfRejectMargins GT 0 and LetUserApprove EQ 0>
			<cfset approvalMessageToShow = 1>
		<CFELSEIF LetUserApprove EQ 1>
			<cfset approvalMessageToShow = 2>
		</CFIF>
	<cfelse>
		<CFIF LetUserApprove EQ 0>
			<cfset approvalMessageToShow = 1>
		<CFELSEIF LetUserApprove EQ 1>
			<cfset approvalMessageToShow = 2>
		</CFIF>
	</CFIF>
</CFIF>

<!---  the user can only view the margins not trying to approve --->
<CFIF UserIsOnlyViewingMargins EQ 1>
	<CFSET LetUserApprove = 0>
</CFIF>

<CFIF getProgramInfo.Contract_Status_Type_IDX GTE 3>
	<CFSET LetUserApprove = 0>
</CFIF>


<cfif getProgramInfo.Contract_Status_Type_IDX EQ 2>
	<CFIF approvalMessageToShow EQ 1>
		<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: red;"><IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"> The margin is lower than you are allowed to approve.</DIV>
	<CFELSEIF approvalMessageToShow EQ 2>
		<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: green;"> The margin is within your approval limits.</DIV>
	<CFELSEIF approvalMessageToShow EQ 3>
		<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: red;"><IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"> You do not have rights to approve programs with 'All products' or 'All <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>'.</DIV>
	<CFELSEIF approvalMessageToShow EQ 4>
		<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: green;"> You are authorized to approve programs with 'All products' or 'All <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput>'.</DIV>
	<CFELSEIF approvalMessageToShow EQ 5>
		<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: red;">
		<cfoutput>
		<cfloop index="i" from="1" to="#ArrayLen(messageArray)#">
			#messageArray[i]#<br>
		</cfloop>
		</cfoutput>
		</DIV>
	<CFELSEIF approvalMessageToShow EQ 6>
		<DIV ID="DIV_DONT_PRINT" ALIGN="center" STYLE="color: green;">
		<CFIF LetUserApprove>
		You are authorized to approve group deals.
		<CFELSE>
		You are not authorized to approve group deals.
		</CFIF>
		</DIV>
	<CFELSEIF approvalMessageToShow EQ 7>
		<cfoutput>
		<br>
		<cfinclude template="/get_Contact_Admin_Email_Address.cfm">
		<table align="center" width="70%" bgcolor="navy" cellpadding="2" cellspacing="1">
		<caption align="center" style="color:red;">
		The group/product you want to approve does not exist in the SAP installation. Please contact the system administrator (<a href="mailto:#Contact_Admin_Email_Address#">#Contact_Admin_Email_Address#</a>)
		</caption>
		<cfloop query="qXMaterialNotAvailable">
			<tr bgcolor="white">
				<td>#Group_ID#</td>
				<td>#Group_Desc#</td>
			</tr>
		</cfloop>
		</table>
		</cfoutput>
	</CFIF>
</cfif>

<br>


<CFIF LetUserApprove EQ 1 AND (getProgramInfo.Contract_Status_Type_IDX NEQ 1 OR getProgramInfo.Contract_Status_Type_IDX NEQ 3)>
	<FORM ACTION="contract_Approve_Action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<cfset parent_program_id = getProgramInfo.Revision_of_Contract_Main_ID>
<!--- 		<cfinclude template="approve_contract_revision.cfm"> --->
<INPUT NAME="APPROVECONTRACT" TYPE="Hidden" VALUE="<CFOUTPUT>#URL.CID#</CFOUTPUT>">
</FORM>
			<cfif appSettings.getRFAAgree()>
			<cfinclude template="users_agreed.cfm">
		</CFIF>
		<br><br>
		<DIV ALIGN="center" ID="DIV_DONT_PRINT">
		<TABLE ALIGN="center"><TR><TD>
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"printPage()"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"print"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		></TD>
		<TD>&nbsp; &nbsp;&nbsp;&nbsp;</TD>
		<TD>
		<CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		<cfif getProgramInfo.Contract_Status_Type_IDX NEQ 1 and approvaltype EQ 1>
		<TD><CF_button
			button_name		=	""
			button_caption	=	"approve this program"
			button_action	=	"approveProgram()"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"approve program"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</cfif>
		</TD></TR></TABLE><br />
        </DIV>





	<CFELSE>

		<DIV ALIGN="center" ID="DIV_DONT_PRINT">
		<TABLE ALIGN="center"><TR><TD>
		<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"printPage()"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"print"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		></TD>
		<TD>&nbsp; &nbsp;&nbsp;&nbsp;</TD>
		<TD><CFIF displayagreed EQ 1 and useragreed EQ 0 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 and (Customerrequired EQ 0 and Operatorrequired EQ 0) and approvaltype EQ 1>
		<CF_button
			button_name		=	""
			button_caption	=	"I Agree"
			button_action	=   "agreeProgram()"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"Agree"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		<CFELSEIF displayagreed EQ 1 and useragreed EQ 1 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 and (Customerrequired EQ 0 and Operatorrequired EQ 0) and approvaltype EQ 1>
		<CF_button
			button_name		=	""
			button_caption	=	"Agreed"
			button_action	=   ""
			button_type		=	""
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"Agree"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</CFIF></TD><TD>&nbsp; &nbsp;&nbsp;&nbsp;</TD>
		<TD><CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"130"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</TD></TR></TABLE><br /></DIV>
	</CFIF>

	<!---  mark the margins the user cannot approve --->
	<CFIF NumberOfRejectMargins GT 0 AND approval_method NEQ 3 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 AND getProgramInfo.Contract_Status_Type_IDX EQ 2>
		<SCRIPT>

		<CFLOOP INDEX="LoopCount" FROM="1" TO="#NumberOfRejectMargins#" STEP="1">
			<cfset approvalData = arrayOfRejectedMarginsRowIDs[LoopCount][2]>

			<cfif approval_method EQ 2>
				<cfif lcase(isnumeric(approvalData)) EQ "yes">
					<cfset approvalData = trim(numberformat(approvalData,'_-___._'))>
				</cfif>
			</cfif>

			<CFOUTPUT>
				document.all.#arrayOfRejectedMarginsRowIDs[LoopCount][1]#.innerHTML  = "<IMG ALIGN='absmiddle' STYLE='cursor:pointer;' SRC='/images/exclamation.gif' HEIGHT='10' WIDTH='10' onmouseover='initTheTooltip(\"#approvalData#\")' onmouseout='popOut()'>&nbsp;"

			</CFOUTPUT>
		</CFLOOP>
		</SCRIPT>
	</CFIF>

	<cfif arraylen(MarginTargetArray) GT 0 AND margin_target_status EQ 1>
		<SCRIPT>
		<cfoutput>

		<CFLOOP INDEX="LoopCount" FROM="1" TO="#arraylen(MarginTargetArray)#" STEP="1">
			<cfset finalInnerHTML = "">

			<cfif isnumeric(MarginTargetArray[LoopCount][2]) AND isnumeric(MarginTargetArray[LoopCount][3])>
				<cfif MarginTargetArray[LoopCount][2] LT MarginTargetArray[LoopCount][3]>
					<cfset finalInnerHTML = "<b style='color: red;'> #MarginTargetArray[LoopCount][3]#%</b>">
				<cfelse>
					<cfset finalInnerHTML = "#MarginTargetArray[LoopCount][3]#%">
				</cfif>
			<cfelse>
				<cfif isnumeric(MarginTargetArray[LoopCount][3])>
					<cfset finalInnerHTML = "#MarginTargetArray[LoopCount][3]#%">
				<cfelse>
					<cfset finalInnerHTML = "<span style='color: red;'>IDC*</span>">
				</cfif>
			</cfif>

			document.all.#MarginTargetArray[LoopCount][1]#_target.innerHTML = "#finalInnerHTML#";


		</cfloop>
		</cfoutput>
		</SCRIPT>
	</cfif>

	<cfparam name="ThisMarginMin" default="0">
	<CFIF LetUserApprove EQ 0 AND approval_method EQ 3 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 AND getProgramInfo.Contract_Status_Type_IDX EQ 2>
		<script>
			document.all.overallMarginErrorSpan.innerHTML  = "<IMG ALIGN='absmiddle' STYLE='cursor:pointer;' SRC='/images/exclamation.gif' HEIGHT='10' WIDTH='10' onmouseover='initTheTooltip(\"<cfoutput>#trim(ThisMarginMin)#</cfoutput>\")' onmouseout='popOut()'>&nbsp;&nbsp;"
		</script>
	</cfif>


	<script>
		function printPage()
		{
			window.print();
		}
	</script>

	<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js"></SCRIPT>
	<script>

		function initTheTooltip(ToolTipText){
			if(ToolTipText == "*IDC") {
				<cfif approval_method EQ 1>
					messages[0]="Insufficient Data To Approve This Margin"
				</cfif>

				<cfif approval_method EQ 2 OR approval_method EQ 3>
					messages[0]="Insufficient Data To Calculate This Margin"
				</cfif>

				popUp(0)
			}
			else{
				textHolder = ToolTipText;
				messages[0]="";

				<cfif approval_method EQ 1>
					messages[0]="Your minimum margin approval level for this item is: <B>$" + textHolder +"</B>"
				</cfif>

				<cfif approval_method EQ 2>
					messages[0]="Your minimum margin approval level for this item is: <B>" + textHolder +"%</B>"
				</cfif>

				<cfif approval_method EQ 3>
					<cfif IDCApprovalRestriction EQ 1>
						messages[0]="Your minimum margin approval level is: <B>" + textHolder +"%</B> but due to the insolvability of the profit margin of at least one item you cannot approve this program."
					<cfelse>
						messages[0]="Your minimum margin approval level is: <B>" + textHolder +"%</B>"
					</cfif>
				</cfif>

				popUp(0)
			}
		}

		var programGettingApproved = 0;

		function verifySubmission(){
			if(opener){
				if(programGettingApproved == 0){

				}
			}
		}

		function approveProgram(){
				ErrorCount = 0;
			if(ErrorCount == 0){
					if(confirm("Are you sure you want to approve this program ?")) {
						programGettingApproved = 1;
						<cfif display_business_consideration >
							NewWindow('evaluationnotes.cfm?mode=6&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&User_id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>','EvaluationNotes','1050','600','Yes', 'Yes');
						<cfelse>
							document.MyForm.submit()
						</cfif>
					}
				}
				else {
					showMessageWindow()
				}
			}

		function agreeProgram(){
			if(confirm("Are you sure you want to agree to this program ?")) {
				<cfif display_business_consideration>
					NewWindow('evaluationnotes.cfm?mode=7&NoteType=2&Formname=MyForm&CID=<cfoutput>#URL.CID#</cfoutput>&User_id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>&agree=1&ProgramAgree=1','EvaluationNotes','1050','600','Yes', 'Yes');
				<cfelse>
					window.location.href = "program_agree_action.cfm?CID=<cfoutput>#URL.CID#</cfoutput>&User_Id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>";
				</cfif>
			}
		}

	</script>

</BODY>
</HTML>