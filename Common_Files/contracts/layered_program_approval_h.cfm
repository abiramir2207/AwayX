<!--
  * ====================================================================================================
  *    @File: \common_Files\contracts\layered_program_approval_T.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2018-06-15 06:42:29
  *
  * @Remarks: - This file supports margin_display_style of 'custom_t'.
  *
  *           - Changes made to this file would need to carry over to the other layered_program_approval.cfm
  *				( to support the other margin_display_style = 'blacksmith' )
  *
  *
  *
  * ====================================================================================================
-->

<!---------------------------------------------------------------------------------------------------------------
What-IF Layout: (DO NOT DELETE THESE NOTES)

  *** REMEMBER TO USE UNIQUE NAMES ***

HEADING
   Field        Name                        Class                        Notes
   ===========  ==========================  ==========================   ==============================
   Product                                  th.prod82
   Group Product                            th.grp82

PRODUCT
   Field        Name                        Class                        Notes
   ===========  ==========================  ==========================   ==============================
   Cases        cases_#currentRecord#       gcases_#groupNumber#         GridViewScroll() renames it to cases_#currentRecord#_Copy
   Pounds       lbs_#currentRecord#         glbs_#groupNumber#           GridViewScroll() renames it to lbs_#currentRecord#_Copy
   List Price   list_price_#currentRecord#  glist_price_#groupNumber#(n/a)
   Fixed_price  fixed_price_#currentRecord# gfixed_price_#groupNumber#(n/a)
   Cash Disc    cash_disc_#currentRecord#   gcash_disc_#groupNumber#(n/a)
   Discount     disc_#currentRecord#        gdisc_#groupNumber#(n/a)
   Disc %       disc_percent_#currentRecord#
   Trade        trade_#currentRecord#
   Amt +        amt_plus_#currentRecord#
   Net Sales    net_sales_#currentRecord#
   Cost         cost_#currentRecord#
   Subcosts     n/a                         subcost_#currentRecord#
   Opr. Income  opr_inc_#currentRecord#
   Opr. Margin  opr_margin_#currentRecord#
   Target %     target_percent_#currentRecord#
   CSA $        csa_#currentRecord#
   ..
   Brokerage    brokerage_#currentRecord#

GROUP PRODUCT
   Field        Name                        Class
   ===========  ==========================  =====================
   Cases        gcases_#groupNumber#
   Pounds       glbs_#groupNumber#
   List Price   glist_price_#groupNumber#
   Fixed_price  n/a
   Discount     gdisc_#groupNumber#
   Disc %       gdisc_percent_#groupNumber#
   Trade        gtrade_#groupNumber#
   Amt +        gamt_plus_#groupNumber#
   Net Sales    gnet_sales_#groupNumber#
   Cost         gcost_#groupNumber#
   Subcosts     n/a
   Opr. Income  gopr_inc_#groupNumber#
   Opr. Margin  gopr_margin_#groupNumber#
   Target %     gtarget_percent_#groupNumber#
   CSA $        gcsa_#groupNumber#
   ..
   Brokerage    gbrokerage_#groupNumber#

SUMMARY
   Field        Annual                      Per UOM
   ===========  ==========================  =====================
   Cases        acases                      n/a
   Pounds       albs                        n/a
   List Price   alist_price                 ulist_price
   Fixed_price  n/a                         n/a
   Discount     adisc                       udisc
   Disc %       adisc_percent               udisc_percent
   Trade        atrade                      utrade
   Net Sales    anet_sales                  unet_sales
   Cost         acost                       ucost
   Subcosts     n/a                         n/a
   Opr. Income  aopr_inc                    uopr_inc
   Opr. Margin  aopr_margin                 n/a
   Target %     atarget_percent             utarget_percent
   CSA $        acsa                        ucsa

----------------------------------------------------------------------------------------------------------------->
<cfsetting showdebugoutput="yes">
<cfparam name="massapproval" default = "0">
<cfparam name="stMassApproval" default = "#StructNew()#">

<!---
FILE:
FILENAME:   Common_Files/contracts/layered_program_approval_h.cfm
CREATED:  ??/??/200? - ??
EDITED:   10/14/2008 - RBL [17289 > 16314: Margin Analysis - Add Contract Price - follow-up]

FUNCTIONALITY:
DEPENDENCIES:

--->
<!--- These parameters are required for this template to process correctly --->
<CFPARAM NAME="MarginTypeDesc" default="CS">
<CFPARAM name="CannotApproveItemMargin" default="0">
<CFPARAM name="CannotApproveItem" default="0">
<CFPARAM name="CannotApproveGroupMargin" default="0">
<CFPARAM name="CannotApproveSettings" default="0">
<cfparam name="checkgroupvalue" default="">
<cfparam name="checkitemvalue" default="">
<cfparam name="grouptrbgcolor" default = "##CCFFCC">
<cfparam name="itemtrbgcolor" default = "##f4f4f4">
<cfparam name="CannotApproveProgramMargin" default = "0">
<cfparam name="Below_Program_Margin" default = "0">
<cfparam name="approvable_program_margin_value" default = "0">
<cfparam name="itemmarginfailure" default = "0">
<cfparam name="programAgree" default = "0">
<cfparam name="totalProgramVolumeByProfileUOM" default = "0">
<cfparam name="duplicateprogram" default = "0">
<cfif not isDefined("AlreadyBeenHere")>
  <cfinclude template="/script/cf/string_functions.cfm">
</cfif>
<cfparam name="tempABS_BaseSales" default="0">
<cfparam name="tempABS_NetSales" default="0">

<!--- Dev Note: KAL; D21684: Functionality of View Margins Screen --->
<cfparam name="displayPreviousVersionMargin" default="1"> <!--- From the LH link in program, we set this to 0 --->
<cfparam name="url.margin_version" default="current">     <!--- set default version to current --->
<cfparam name="variables.margin_version" default="#url.margin_version#">     <!--- set default version to current --->
<!--- End Note: KAL; D21684: Functionality of View Margins Screen --->
<cfparam name="url.verticalPNL" default="">
<cfparam name="url.showProducts" default="1">

<cfset original_margin_version = margin_version>
<cfif url.verticalPNL eq "">         <!---  44017  --->
	<cf_include files="/common_files/scripts/demenu.js">
	<style>
		th.header { font-size:11px; }
		.neg { color: red; }
	</style>
<cfelse>
    <!--- <cf_include files="/common_files/GridviewScroll.css, /styles/css-loader.css"> --->
    <cf_include files="/script/javascript/gridviewscroll/1.0/gridviewscroll.css, /styles/css-loader.css">
	<style>
		/*table input { width:80%; }*/
		.changed { background-color: #DADBDD !important; }
		#actions { margin: 0px 0 16px 0; float:left;}
		#actions a { margin: 0 20px 0 0; font-size: 1.1em; letter-spacing: 0.5px; }
		.neg { color: red; }
		th { vertical-align: top !important; }
		td.une82 { padding-left:35px; background-color: #efefef; font-weight: bold; text-align: left; }
		td.une82b { padding-left:45px; background-color: #efefef; font-weight: normal; text-align: left; }
		.right, td { text-align: right; }
		th.grp82, /*group product*/
		td.grp82, /*group product*/
		td.per82g, td.sum82, th.sum82 {background-color: #EBF1DE;}
		th.noar, th.noar *, td.noar, td.noar * { background-color: #d3d3d3; }
		#GridView1 a { font-weight: bold; }
		#uom35 { float:right; margin-right:10px; font-weight2: bold; }
		.upd14 { font-weight: bold; font-size: 1.1em; margin-left:15px }
		#not07 label { font-weight:bold; vertical-align:top; font-size:1em; }
		#not07 textarea { width:95%; }
		i.audit {
			font-size: 14px;
			font-weight: bold;
			font-style: normal;
			color: green;
			cursor: pointer;
		}
		input[type=text] {width: 60%;}
	</style>
</cfif>  <!--- url.verticalPNL neq "1" --->

<style>
	#approval_consideration { font-size: 1.2em; color: green;}
</style>

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<!--- avoid loading this udfs file more than once (e.g. in mass approval) --->
<cfif !structKeyExists(request, "layered_program_approval_h_udf")>
	<cfinclude template="layered_program_approval_h_udf.cfm">
</cfif>


<cfparam name="url.uot" default="1">

<cfsavecontent variable="unitOfTime4Volume">
			<b>Unit of Time:</b> <input type="radio" value = "6" name="unitOfTime" <cfif url.UoT EQ 6 >checked</cfif> onClick = "changeUnitOfTime(6);">Annualized
			<input type="radio" value = "1" name="unitOfTime" <cfif url.UoT EQ 1 >checked</cfif> onClick = "changeUnitOfTime(1);"> Program Duration
</cfsavecontent>

<cfif appSettings.getApprovalMarginType() eq 3>
	<cfset useLakebaseForgetGlobalUOM = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetGlobalUOM>
	<cftry>
		<cfset getGlobalUOM = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "global_target_uom"
			}), "global_target_uom"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGlobalUOM = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGlobalUOM>
<cfquery name="getGlobalUOM" datasource="#application.datasource#">
		SELECT Global_Target_UOM
			FROM General_Settings
	</cfquery>
</cfif>
  <cfset Global_Target_UOM = getGlobalUOM.Global_Target_UOM>
<cfelse>
	<cfset Global_Target_UOM = 0>
</cfif>

<cfsilent>
	<cfscript>
		variables.approval_consideration = createObject("component","mvc.Models.Program.ApprovalConsiderationsManager");

		if (url.verticalPNL eq "2") {
			variables.whatIfCFC      = createObject("component", "components.programs.ContractWhatif");
			variables.qWhatIf        = variables.whatIfCFC.getWhatIf( contract_main_id );
			variables.qWhatIfProduct = variables.whatIfCFC.getWhatIfProduct( contract_main_id );

			// writedump(variables.qWhatIf);
			// writedump(variables.qWhatIfProduct);

			// override margin type with saved margin type when coming from left hand side option on view program
			// do not override when switching margin type on what-if page
			if (variables.qWhatIf.recordCount and URL.fixed_type eq "") {
				form.margin_type = variables.qWhatIf.margin_type;
			}
		}
		/* decimal places setting created for Tyson */
		decimal_places        = (form.margin_type eq "1" ? application.util.query.get_setting("decimal_display_for_cs", 0) : application.util.query.get_setting("decimal_display_for_lb", 0));
		request.dollar_format = "($9,." & repeatString("9", val(decimal_places) ? val(decimal_places): 4);
		request.numeric_format = "(9,.99)";
	</cfscript>

<!---TSF: Label D9704 - This is very painful to do but I have to inline a query to get the margin uot. UUUUUUUUUUGH! --->
<cfquery NAME="qGetMarginUOT" datasource="#application.datasource#">
	SELECT  Volume_UOT.UOT_Desc, Volume_UOT.Unit_Multiplier,
		_Users_Settings.margin_uot_Id
	FROM  _Users_Settings
		INNER JOIN Volume_UOT ON
		Volume_UOT.Volume_UOT_ID = _Users_Settings.Margin_UOT_ID
	WHERE _Users_Settings.User_ID = <cfqueryparam value="#trim(request.AccessStructure.Company_Main_ID)#" cfsqltype="cf_sql_idstamp">
</cfquery>
<!--- 72497 Program Approval - Annual Volume and % of List Price START --->
<cfif qGetMarginUOT.margin_uot_Id EQ 6>
	<cfset DefaultUnitMargin = 1>
<cfelse>
	<cfset DefaultUnitMargin = 0>
</cfif>
<!--- get the program span --->
<cfset ProgramSpan =  DATEDIFF('d', getProgramInfo.Contract_Start_Date, getProgramInfo.Contract_End_Date) + 1 >
<!--- 72497 Program Approval - Annual Volume and % of List Price END --->

<!--- 66894 Margin Target ENH Forge START --->
<cfif getSettings.Generic_Type EQ 'Operator Direct or HQ Programs' OR getSettings.Generic_Type EQ 'Operator-Deviated Pricing'>
	<cfset OperatorProgram = 1>
<cfelse>
	<cfset OperatorProgram = 0>
</cfif>
  <!--- 66894 Margin Target ENH Forge END --->

<cfparam name="form.product_group_level_id" default="0">
<cfparam name="form.product_group_level_list" default="">

<!--- get all the products of the program --->
<cfscript>
	 /*if the contract is already approved, don't re-calc margin For "Custom RFP" logic.  Display Approved Margins from Contract_product_Margin_Approved table 
                     This same logic is also in /Common_Files/contracts/verticalpnl_hm.cfm   		 */
    margin_version  =   getProgramInfo.Approved == 1 ? 'Approved' : 'Current';
    getAllProductMargins = ApprovalProgramManager.getAllProductMarginsHM(program_id=contract_main_id, margin_type=form.Margin_Type, formCopy=form, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM);
</cfscript>



<!--- <cfif url.verticalPNL neq "">
	<cfset getAllProductMargins = ApprovalProgramManager.getAllProductMarginsHM(program_id=contract_main_id, margin_type=form.Margin_Type, formCopy=form, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
<cfelse>
	<cfif appSettings.getShowORHideGroupsInViewMargin()>
		<cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, formCopy=form, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
	<cfelse>
		<cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
	</cfif> 
</cfif> --->

<!--- --->

<!--- Get Program Margins --->
<cfset getProgramMargins = ApprovalProgramManager.getProgramMargins(program_id=contract_main_id,margin_type=form.Margin_Type, margin_version="#margin_version#",DefaultUnitMargin=DefaultUnitMargin, PrgSpan=ProgramSpan)>
<!---  get total program volume --->
<cfset TotalProgramVolume = getProgramMargins.totalprogramvolume>

<!--- Dev Note: KAL; 9/13/2010; D23601: Margin Exclude Items --->
<!--- <cfif appSettings.getMarginItemsExclude()>
  <cfif appSettings.getShowORHideGroupsInViewMargin()>
	<cfset getAllExcludedProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, formCopy=form, excludeMarginItems = true, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
  <cfelse>
	<cfset getAllExcludedProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, excludeMarginItems=true, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
  </cfif>
  <!--- Get Program Margins for excluded items --->
  <cfset getProgramExcludedProductMargins = ApprovalProgramManager.getProgramMargins(program_id=contract_main_id, margin_type=form.Margin_Type, margin_version="#margin_version#", excludeMarginItems=true,DefaultUnitMargin=DefaultUnitMargin, PrgSpan=ProgramSpan)>
  <!---  get total program volume for excluded items --->
  <cfset TotalProgramExcludedProductVolume = getProgramExcludedProductMargins.totalprogramvolume>


  <!--- get all the typecode info --->
  <cfif getProgramExcludedProductMargins.recordcount GT 0>
	<cfset getAllExcludedGroupMargins = ApprovalProgramManager.getAllGroupMargins(program_id=contract_main_id, Profiles_ID=request.AccessStructure.Profiles_ID, margin_type=form.Margin_Type, excludeMarginItems = true, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM, productGroupLevelId=form.product_group_level_id, productGroupLevelFilterList=form.product_group_level_list)>
  </cfif>
</cfif> --->
<!--- End Note: KAL; 9/13/2010; D23601: Margin Exclude Items --->

<!--- Dev Note: KAL; D21684/D13380: Functionality of View Margins Screen; Approved Margins & Approved Volume --->
<!--- If program is a revision then then get product margins for the previous version of the program --->
<!--- <cfif Program_Is_A_Revision>
	<!--- Previous Product Margins --->
	<cfset getProductPreviousVersionMargins = ApprovalProgramManager.getAllProductMargins(program_id = getProgramInfo.Revision_of_Contract_Main_ID, margin_type = form.Margin_Type, Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
	<!--- D21684: Moved rest of the code here to below sections --->
</cfif> --->
<!--- End Note: KAL; D21684/D13380: Functionality of View Margins Screen --->

<cfif getAllProductMargins.recordcount GT 0>
	<!--- get all the typecode info --->
	<cfif url.verticalPNL neq "">
		<!--- We added this into main getAllProductMargins sql --->
		<!--- <cfset getAllGroupMargins = ApprovalProgramManager.getAllGroupMargins(program_id=contract_main_id, Profiles_ID=request.AccessStructure.Profiles_ID, margin_type=form.Margin_Type, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM, productGroupLevelId=form.product_group_level_id, productGroupLevelFilterList=form.product_group_level_list)> --->
	<cfelse>
		<cfset getAllGroupMargins = ApprovalProgramManager.getAllGroupMargins(program_id=contract_main_id, Profiles_ID=request.AccessStructure.Profiles_ID, margin_type=form.Margin_Type, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM, productGroupLevelId=form.product_group_level_id, productGroupLevelFilterList=form.product_group_level_list)>
	</cfif>
</cfif>

<!--- Dev Note: KAL; D13380: Margin Page Highlight Changes --->
<!---  get program volume UOM --->
<cfif form.Margin_Type eq 1>
	<cfset totalprogramvolumeUOM = "CS">
<cfelseif form.Margin_Type eq 3>
	<cfset totalprogramvolumeUOM = "LB">
<cfelse>
	<cfset totalprogramvolumeUOM = "STAT CS">
</cfif>

<!---   Dev Note: CPM 11029
	Obtain Program Volume in the same UOM as the user profile:
		- Access_Rights_Matrix.cfm (For layered - UOM excludes 2,3 (CS only)) --->

<!--- Cases --->
<cfif Get_Profile_Settings.Max_Approval_Volume_UOM eq 1>
	<cfquery NAME="getProgramVolumeForProfiles" datasource="#application.datasource#">
		select  ISNULL(Sum(round(Product_Program_Volume_CS, 0)),0) as totalprogramvolume
		from  Contract_Product_Margin
		where Contract_Main_ID  = <cfqueryparam value="#CONTRACT_MAIN_ID#" cfsqltype="cf_sql_integer"> and deleted = 0
		and   Exclude_From_Margin = 0
	</cfquery>

	<cfset totalProgramVolumeByProfileUOM = getProgramVolumeForProfiles.totalprogramvolume>
</cfif>

<cfset program_spend               = Val(getProgramInfo.program_spend)>
<cfset program_spend_in_margin_uot = Val(getProgramInfo.program_spend_in_margin_uot)>
<cfset budget_program_spend        = round(
											Val(getProgramInfo.Program_Spend_Non_Lumpsum_Distributor) +
											Val(getProgramInfo.Program_Spend_Lumpsum_Distributor) +
											Val(getProgramInfo.Program_Spend_Non_Lumpsum_Operator) +
											Val(getProgramInfo.Program_Spend_Lumpsum_Operator) +
											Val(getProgramInfo.Program_Spend_Non_Lumpsum_Broker) +
											Val(getProgramInfo.Program_Spend_Lumpsum_Broker)
										)/>
</cfsilent>

<!--- check growthapproval --->
<!--- Dev Note: Clay 11029 - Add comparison of program volume to maximum approval using the UOM of the Profile Setting --->
<cfif (((TotalProgramVolume GT AnnualVolume_CS) AND (FORM.MARGIN_TYPE eq AnnualVolume_UOM)) OR (totalProgramVolumeByProfileUOM GT AnnualVolume_CS)) and TRIM(AnnualVolume_CS) NEQ "*">
	<cfset CannotApproveSettings = 1>
	<cfset temp = ArrayAppend(messageArray, "You cannot approve since the volume of the program exceeds your approval limits.")>
</cfif>

<!---27355 - when included (regular) product does not exist and excluded product exists we should skip the minimum rules--->
<cfif getAllProductMargins.recordCount eq 0 and isDefined("getAllExcludedProductMargins") and getAllExcludedProductMargins.recordCount gt 0>
	<cfset skipMinRules = 1>
<cfelse>
	<cfset skipMinRules = 0>
</cfif>

<!--- Dev Note: Clay 11029 - Add comparison of program volume to minimum approval using the UOM of the Profile Setting --->
<cfif (((TotalProgramVolume LT minvolume_CS) AND (FORM.MARGIN_TYPE eq minvolume_UOM)) OR (totalProgramVolumeByProfileUOM LT minvolume_CS)) and TRIM(minvolume_CS) NEQ "*" and skipMinRules eq 0>   <!---27355--->
	<cfset CannotApproveSettings = 1>
	<cfset temp = ArrayAppend(messageArray, "You cannot approve since the volume is below your minimum required volume threshold.")>
</cfif>

<!--- 72497  Program Approval - Annual Volume and % of List Price START --->
<cfif (((getProgramMargins.AnnualVolumeCS GT approvableannualvolume_CS) AND (FORM.MARGIN_TYPE eq approvableannualvolume_UOM)) OR (totalProgramVolumeByProfileUOM GT approvableannualvolume_CS)) and TRIM(approvableannualvolume_CS) NEQ "*">
	<cfset CannotApproveSettings = 1>
	<cfset temp = ArrayAppend(messageArray, "You cannot approve since the volume of the program exceeds your max annual approval limits.")>
</cfif>
<!--- 72497  Program Approval - Annual Volume and % of List Price END --->

<!--- <cfoutput>#appSettings.getApprovalMarginType()# :: XXXXXXXX</cfoutput> --->
<cfset NetSalesPass = 0>
<cfif appSettings.getApprovalMarginType() eq 0>
	<cfset varAbsNetSales = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume)>
	<!--- <cfoutput>#varAbsNetSales# :: #Get_Profile_Settings.Max_Net_Sales_Dollar#</cfoutput> --->
	<cfset NetSalesPass = 1>
	<cfif (varAbsNetSales GT Get_Profile_Settings.Max_Net_Sales_Dollar) AND TRIM(Get_Profile_Settings.Max_Net_Sales_Dollar) NEQ "*">
		<cfif GetSettings.Sequential_Net_Sales_Operating_Margin eq 1>
			<!--- No need to stop user, margin check is done below --->
			<cfset NetSalesPass = 0>
		<cfelse>
			<cfset CannotApproveSettings = 1>
			<!--- cfset varAbsNetSales = trim(numberformat(varAbsNetSales,"___,___,___,___,___,___-__")) / --->
			<cfset temp = ArrayAppend(messageArray, "You cannot approve since the net sales of the program exceeds your limits.")>
		</cfif>
	</cfif>
</cfif>

<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
<cfset ignoreOperatingMarginCheck = 0>
<cfif appSettings.getApprovalMarginType() eq 1>
	<cfif (getProgramMargins.Total_TradePercent GT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*">
		<cfif GetSettings.Sequential_Net_Sales_Operating_Margin eq 1 AND NetSalesPass eq 1>
			<cfset ignoreOperatingMarginCheck = 1>
		<cfelse>
			<cfset CannotApproveProgramMargin = 1>
			<cfset temp = ArrayAppend(messageArray, "The margin of the program is greater than the maximum approval limits.")>
		</cfif>
	</cfif>
<cfelseif appSettings.getApprovalMarginType() eq 0>
	<cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*"
		and skipMinRules eq 0>   <!---27355--->
		<cfif GetSettings.Sequential_Net_Sales_Operating_Margin eq 1 AND NetSalesPass eq 1>
			<cfset ignoreOperatingMarginCheck = 1>
		<cfelse>
			<cfset CannotApproveProgramMargin = 1>
			<cfset temp = ArrayAppend(messageArray, "The operating margin of the program is less than the minimum approval limits.")>
		</cfif>
	</cfif>
</cfif>

<cfif Get_Profile_Settings.Max_Program_Spend NEQ "*" AND Program_Spend GT Get_Profile_Settings.Max_Program_Spend>
  <cfset CannotApproveSettings = 1>
  <cfset temp = ArrayAppend(messageArray, "You cannot approve since the #LCase(appsettings.getMarginColHeader14())# of the program exceeds your approval limits.")>
</cfif>


<cfscript>
	template = templateManager.get(getProgramInfo.ProgramType_ID);
	// <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
	variables.bDisplayContractPrice = template.Discount_Fixed_Prices;
	// <!--- 17289 > 16314 follow up 10/14/08 [end] --->
	BudgetManager      = CreateObject("component", "components.budgets.BudgetManager").init();
	absTotalOperIncome = 0;
	variables.spacer2  = "  ";
</cfscript>

<!-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- D56447 :: EZ Rates Indicator inside a Program START --->
<cfset ProductsBeyoundMaxRateList = "">
<cfset ProductsMaxRateList = "">
<cfif getsettings.EZButton_On EQ 1>
	<cfquery NAME="qProductsBeyondMaxRateList" datasource="#application.datasource#">
		select	BSA_Foodservice_Items_Master_ID, cast(EZ_Rate AS varchar) +' / '+ EZ_UOM_AB AS Rate
		from	DBO.UDF_EZ_GET_PROGRAM_PRODUCTS (#Contract_Main_ID#, 'NOT_WITHIN_EZ_RATE', #request.AccessStructure.Profiles_ID#)
	</cfquery>
	<cfset ProductsBeyoundMaxRateList = valuelist(qProductsBeyondMaxRateList.BSA_Foodservice_Items_Master_ID)>
	<cfset ProductsMaxRateList = valuelist(qProductsBeyondMaxRateList.Rate)>
</cfif>
<!---  D56447 :: EZ Rates Indicator inside a Program END ---> 
<cfquery name="isEditing" datasource="#application.datasource#">
	SELECT 1
	FROM Contract_Main
	WHERE Contract_Main_ID = #getProgramInfo.contract_main_id#
			AND Contract_Is_Locked = 1
			AND Contract_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
			AND Approved = 0
			AND Contract_Status_Type_IDX < 3
</cfquery>
<cfif url.verticalPNL neq "">
	<cfset verticalPNL()>
<cfelse>
	<cfset horizontalPNL()>
	<!--- </div> --->
</cfif>  <!--- <cfif url.verticalPNL neq ""> --->
<!-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

<!--- remove the restricted list from agree list --->
<cfif form.RestrictedList neq "" and form.AgreeList neq "">
	<cfloop list="#form.RestrictedList#" index="restrictedItem">
		<cfif ListFind(form.AgreeList, restrictedItem) gt 0 >
			<cfset form.AgreeList = ListDeleteAt(form.AgreeList, ListFind(form.AgreeList, restrictedItem)) >
		</cfif>
	</cfloop>
</cfif>

<cfif CannotApproveProgramMargin eq 1
		and CannotApproveSettings eq 0
	  and itemmarginfailure eq 0>
	<cfset Below_Program_Margin = 1>
	<cfset CannotApproveSettings = 1>
</cfif>

<cfif CannotApproveSettings eq 1 and ProgramAgree eq 0>
	<cfset ProgramAgree = 1>
</cfif>

<cfoutput>
<input type="hidden" name="below_program_margin" value="#Below_Program_Margin#">
<input type="hidden" name="program_margin_value" value="#getProgramMargins.Total_OprMargin#">
<input type="hidden" name="approvable_program_margin_value" value="#Get_Profile_Settings.Max_Opr_Margin#">
<input type="hidden" name="programid" value="#url.CID#">
<input type="hidden" name="ProgramIsARevision" value="#getProgramInfo.Is_A_Revision#">
<input type="hidden" name="AllowRetroRevision" value="#getSettings.ALLOW_RETRO_REVISION#">
<input type="hidden" name="MaxDuration" value="#getSettings.max_duration#">
<input type="hidden" name="Allow_Retro_Revision_Span" value="#getSettings.Allow_Retro_Revision_Span#">
<input type="hidden" name="Business_considerations" value="">
<input type="hidden" name="AgreeList" value="#form.AgreeList#">
<input type="hidden" name="ApproveList" value="#form.ApproveList#">
<input type="hidden" name="RestrictedList" value="#form.RestrictedList#">
<input type="hidden" name="preAgreeList" value="#form.preAgreeList#">
<input type="hidden" name="preApproveList" value="#form.preApproveList#">
<input type="hidden" name="preRestrictedList" value="#form.preRestrictedList#">
<input type="hidden" name="ProgramAgree" value="<cfoutput>#ProgramAgree#</cfoutput>">
<!--- Dev Note: KAL; 8891 --->
<input type="hidden" name="userName" value="">
<input type="hidden" name="evalAction" value="">
<input type="hidden" name="notes" value="N/A">
<input type="hidden" name="mode" value="">
<input type="hidden" name="Contract_Number" value="">
<input type="hidden" name="NoteType" value="2">
<input type="hidden" name="reject" value="0">
<input type="hidden" name="Disagreed" value="0">
</cfoutput>

<cfset stMassApproval.bProgramFinalApprove = bProgramFinalApprove>

<!--------------->
<!--- the end --->
<!--------------->


