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

<cfscript>
  th_count = 0;
  // this image placeholder is used to keep the gridviewscroll horizontal scrolling working properly
  img_1010 = '<img src="/images/exclamation.gif" height="10" width="10" style="opacity:0" alt="1010">';
</cfscript>

<!---
FILE:
FILENAME:   Common_Files/contracts/layered_program_approval.cfm
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
<cfparam name="margin_version" default="current">     <!--- set default version to current --->
<!--- End Note: KAL; D21684: Functionality of View Margins Screen --->
<cfparam name="url.verticalPNL" default="">
<cfparam name="url.showProducts" default="1">


<cfset original_margin_version = margin_version />
<cfif url.verticalPNL eq "">         <!---  44017  --->
  <SCRIPT language=JavaScript1.2 src="/common_files/scripts/demenu.js"></SCRIPT>
  <style>
    th.header { font-size:11px; }
    .neg { color: red; }
  </style>
<cfelse>
  <link href="/common_files/GridviewScroll.css" rel="stylesheet" />
  <style>
    /*table input { width:80%; }*/
    .changed { background-color: #DADBDD !important; }
    #actions { margin: 0px 0 16px 0; float:left;}
    #actions a { margin: 0 20px 0 0; font-size: 1.1em; letter-spacing: 0.5px; }
    .neg { color: red; }
    th { vertical-align: top !important; }
    td.une82 { padding-left:70px; background-color: #efefef; font-weight: bold; text-align: left; }
    td.une82b { padding-left:90px; background-color: #efefef; font-weight: normal; text-align: left; }
    .right, td { text-align: right; }
    th.grp82, /*group product*/
    td.grp82, /*group product*/
    td.per82g, td.sum82, th.sum82 {
      background-color: #EBF1DE;
    }
    th.noar, th.noar *, td.noar, td.noar * { background-color: #d3d3d3; }
    #GridView1 a { font-weight: bold; }
    #uom35 { float:right; margin-right:10px; font-weight: bold; }
    .upd14 { font-weight: bold; font-size: 1.1em; margin-left:15px }
    #not07 label { font-weight:bold; vertical-align:top; font-size:1em; }
    #not07 textarea { width:95%; }
  </style>
</cfif>  <!--- url.verticalPNL neq "1" --->

<style>
  #approval_consideration { font-size: 1.2em; color: green;}
  i.tooltip { font-size: 12px; font-style: normal; color: red; cursor: help; }
</style>

<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->

<cfsavecontent variable="unitOfTime4Volume">
      Unit of Time :
      <input type="radio" value = "6" name="unitOfTime" <cfif url.UoT EQ 6 >checked</cfif> onClick = "changeUnitOfTime(6);">Annualized
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
    request.nondollar_format = "9,." & repeatString("9", val(decimal_places) ? val(decimal_places): 4);
    request.numeric_format = "(9,.99)";
  </cfscript>

<!---TSF: Label D9704 - This is very painful to do but I have to inline a query to get the margin uot. UUUUUUUUUUGH! --->
<CFQUERY NAME="qGetMarginUOT" datasource="#application.datasource#">
  SELECT  Volume_UOT.UOT_Desc, Volume_UOT.Unit_Multiplier,
      _Users_Settings.margin_uot_Id
  FROM  _Users_Settings
      INNER JOIN Volume_UOT ON
      Volume_UOT.Volume_UOT_ID = _Users_Settings.Margin_UOT_ID
  WHERE _Users_Settings.User_ID = <cfqueryparam value="#trim(request.AccessStructure.Company_Main_ID)#" cfsqltype="cf_sql_idstamp">
</CFQUERY>
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

<!--- get all the products of the program --->
<cfif appSettings.getShowORHideGroupsInViewMargin()>
  <cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, formCopy=form, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM, Lower_Than_Ideal = url.Lower_Than_Ideal)>
<cfelse>
  <cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM, Lower_Than_Ideal = url.Lower_Than_Ideal)>
</cfif>

<!--- Get Program Margins --->
<cfset getProgramMargins = ApprovalProgramManager.getProgramMargins(program_id=contract_main_id,margin_type=form.Margin_Type, margin_version="#margin_version#",DefaultUnitMargin=DefaultUnitMargin, PrgSpan=ProgramSpan)>
<!---  get total program volume --->
<cfset TotalProgramVolume = getProgramMargins.totalprogramvolume>

<!--- Dev Note: KAL; 9/13/2010; D23601: Margin Exclude Items --->
<cfif appSettings.getMarginItemsExclude()>
  <cfif appSettings.getShowORHideGroupsInViewMargin()>
    <cfset getAllExcludedProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, formCopy=form, excludeMarginItems = true, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM) />
  <cfelse>
    <cfset getAllExcludedProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, excludeMarginItems=true, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM) />
  </cfif>
  <!--- Get Program Margins for excluded items --->
  <cfset getProgramExcludedProductMargins = ApprovalProgramManager.getProgramMargins(program_id=contract_main_id, margin_type=form.Margin_Type, margin_version="#margin_version#", excludeMarginItems=true,DefaultUnitMargin=DefaultUnitMargin, PrgSpan=ProgramSpan)>
  <!---  get total program volume for excluded items --->
  <cfset TotalProgramExcludedProductVolume = getProgramExcludedProductMargins.totalprogramvolume>


  <!--- get all the typecode info --->
  <cfif getProgramExcludedProductMargins.recordcount GT 0>
    <cfset getAllExcludedGroupMargins = ApprovalProgramManager.getAllGroupMargins(program_id=contract_main_id, Profiles_ID=request.AccessStructure.Profiles_ID, margin_type=form.Margin_Type, excludeMarginItems = true, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
  </cfif>
</cfif>
<!--- End Note: KAL; 9/13/2010; D23601: Margin Exclude Items --->

<!--- Dev Note: KAL; D21684/D13380: Functionality of View Margins Screen; Approved Margins & Approved Volume --->
<!--- If program is a revision then then get product margins for the previous version of the program --->
<cfif Program_Is_A_Revision>
  <!--- Previous Product Margins --->
  <cfset getProductPreviousVersionMargins = ApprovalProgramManager.getAllProductMargins(program_id = getProgramInfo.Revision_of_Contract_Main_ID, margin_type = form.Margin_Type, Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
  <!--- D21684: Moved rest of the code here to below sections --->
</cfif>
<!--- End Note: KAL; D21684/D13380: Functionality of View Margins Screen --->

<cfif getAllProductMargins.recordcount GT 0>
  <!--- get all the typecode info --->
  <cfset getAllGroupMargins = ApprovalProgramManager.getAllGroupMargins(program_id=contract_main_id, Profiles_ID=request.AccessStructure.Profiles_ID, margin_type=form.Margin_Type, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
</cfif>

<!--- Dev Note: KAL; D13380: Margin Page Highlight Changes --->
<!---  get program volume UOM --->
<cfif form.Margin_Type eq 1>
  <cfset totalprogramvolumeUOM = "CS">
<cfelseif form.Margin_Type eq 3>
  <cfset totalprogramvolumeUOM = application.UOMPoundSingular>
<cfelse>
  <cfset totalprogramvolumeUOM = "STAT CS">
</cfif>

<!---   Dev Note: CPM 11029
    Obtain Program Volume in the same UOM as the user profile:
        - Access_Rights_Matrix.cfm (For layered - UOM excludes 2,3 (CS only)) --->

<!--- Cases --->
<cfif Get_Profile_Settings.Max_Approval_Volume_UOM eq 1>
  <CFQUERY NAME="getProgramVolumeForProfiles" datasource="#application.datasource#">
    select  ISNULL(Sum(round(Product_Program_Volume_CS, 0)),0) as totalprogramvolume
    from  Contract_Product_Margin
    where Contract_Main_ID  = <cfqueryparam value="#CONTRACT_MAIN_ID#" cfsqltype="cf_sql_integer"> and deleted = 0
    and   Exclude_From_Margin = 0
  </CFQUERY>

  <cfset totalProgramVolumeByProfileUOM = getProgramVolumeForProfiles.totalprogramvolume />
</cfif>

<cfset program_spend = Val(getProgramInfo.program_spend) />
<cfset program_spend_in_margin_uot = Val(getProgramInfo.program_spend_in_margin_uot) />
<cfset budget_program_spend = round(
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
<cfif getAllProductMargins.recordCount eq 0
   and isDefined("getAllExcludedProductMargins") and getAllExcludedProductMargins.recordCount gt 0>
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
<cfset NetSalesPass = 0 />
<cfif appSettings.getApprovalMarginType() eq 0>
    <cfset varAbsNetSales = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume) />
  <!--- <cfoutput>#varAbsNetSales# :: #Get_Profile_Settings.Max_Net_Sales_Dollar#</cfoutput> --->
  <cfset NetSalesPass = 1 />
  <cfif (varAbsNetSales GT Get_Profile_Settings.Max_Net_Sales_Dollar) AND TRIM(Get_Profile_Settings.Max_Net_Sales_Dollar) NEQ "*">
  <cfif GetSettings.Sequential_Net_Sales_Operating_Margin eq 1>
    <!--- No need to stop user, margin check is done below --->
    <cfset NetSalesPass = 0 />
  <cfelse>
      <cfset CannotApproveSettings = 1>
      <!--- cfset varAbsNetSales = trim(numberformat(varAbsNetSales,"___,___,___,___,___,___-__")) / --->
      <cfset temp = ArrayAppend(messageArray, "You cannot approve since the net sales of the program exceeds your limits.")>
  </cfif>
  </cfif>
</cfif>

<!--- Dev Note: KAL; D20537: Display margin as trade percent --->
<cfset ignoreOperatingMarginCheck = 0 />
<cfif appSettings.getApprovalMarginType() eq 1>
  <cfif (getProgramMargins.Total_TradePercent GT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*">
    <cfif GetSettings.Sequential_Net_Sales_Operating_Margin eq 1 AND NetSalesPass eq 1>
      <cfset ignoreOperatingMarginCheck = 1 />
    <cfelse>
      <cfset CannotApproveProgramMargin = 1>
      <cfset temp = ArrayAppend(messageArray, "The margin of the program is greater than the maximum approval limits.")>
    </cfif>
  </cfif>
<cfelseif appSettings.getApprovalMarginType() eq 0>
  <cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*"
        and skipMinRules eq 0>   <!---27355--->
    <cfif GetSettings.Sequential_Net_Sales_Operating_Margin eq 1 AND NetSalesPass eq 1>
      <cfset ignoreOperatingMarginCheck = 1 />
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

<cfset template = templateManager.get(getProgramInfo.ProgramType_ID) />

<!--- 17289 > 16314 follow up 10/14/08 [begin] --->
<cfset variables.bDisplayContractPrice = template.Discount_Fixed_Prices>
<!--- 17289 > 16314 follow up 10/14/08 [end] --->

<cfscript>
  BudgetManager = CreateObject("component", "components.budgets.BudgetManager").init();
</cfscript>

<!-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfset absTotalOperIncome = 0>
<cfset variables.spacer2  = "  ">


<!--- D56447 :: EZ Rates Indicator inside a Program START --->

    <CFQUERY NAME="qProductsBeyondMaxRateList" datasource="#application.datasource#">
      select	BSA_Foodservice_Items_Master_ID, cast(EZ_Rate AS varchar) +' / '+ EZ_UOM_AB AS Rate
      from	DBO.UDF_EZ_GET_PROGRAM_PRODUCTS (#Contract_Main_ID#, 'NOT_WITHIN_EZ_RATE', #request.AccessStructure.Profiles_ID#)
    </CFQUERY>
    <cfset ProductsBeyoundMaxRateList = valuelist(qProductsBeyondMaxRateList.BSA_Foodservice_Items_Master_ID)>
    <cfset ProductsMaxRateList = valuelist(qProductsBeyondMaxRateList.Rate)>

<!--- D56447 :: EZ Rates Indicator inside a Program END --->
<cfif url.verticalPNL neq "">
  <!--- <cfdump var="#variables#"> --->
  <!---------------------------------------------------------------------------------------------------------------------->
  <!------- VERTICALPNL() ------------------------------------------------------------------------------------------------>
  <!---------------------------------------------------------------------------------------------------------------------->
  <cfoutput>
  <input type="hidden" name="product_count" value="#getAllProductMargins.recordCount#">
  <input type="hidden" name="next_page_url">
  <input type="hidden" name="action">
  <input type="hidden" name="page_view" value="#(url.detail7 eq "show" ? 'detail' : 'compact')#">   <!--- compact (w/o elements under discount, trade, cost) | detail  (with elements under discount, trade, cost) --->
  </cfoutput>
  <cfoutput query="getAllProductMargins">
      <!--- keep track of product IDs: first product is stored in input element named as 'prod_id_1' and has a value of BSA_Foodservice_Items_Master_ID --->
      <input type="hidden" name="prod_id_#getAllProductMargins.currentRow#"        value="#getAllProductMargins.BSA_Foodservice_Items_Master_ID#">
  </cfoutput>
  <cfsavecontent variable="variables.mainContent">
    <cfoutput>
    <div id="actions">
      <cfset variables.moreless = (url.detail7 eq "show" ? "less -" : "more +")>
      <cfif url.verticalPNL eq "2">
        <a href="##" id="calc38">#application.util.string.actionLinkFormat2("calculate", "important")#</a>
        <a href="##" id="moreless">#application.util.string.actionLinkFormat2( variables.moreless )#</a>
        <a href="##" id="save38">#application.util.string.actionLinkFormat2("save")#</a>
        <a href="##" id="reset38">#application.util.string.actionLinkFormat2("reset")#</a>
        <a href="##" id="export82">#application.util.string.actionLinkFormat2("export to csv")#</a>
      <cfelse>
        <a href="##" id="moreless">#application.util.string.actionLinkFormat2( variables.moreless )#</a>
        <a href="##" id="export82">#application.util.string.actionLinkFormat2("export to csv")#</a>
        <a href="##" id="showProducts">#application.util.string.actionLinkFormat2((url.showProducts eq "1" ? "hide " : "show ") & lcase(application.returned_customer_setting.item_label) & "s")#</a>
      </cfif>
      <a href="##" id="close82">#application.util.string.actionLinkFormat2("close window")#</a>
      <!--- 114617 :: Ideal Price START --->
      <cfif getProgramInfo.Ideal_Price AND (getProgramInfo.Contract_Is_Locked AND getProgramInfo.Contract_Status_Type_IDX LT 3 AND getProgramInfo.Contract_Locked_By_User_ID EQ request.AccessStructure.User_ID)>
        <cfset HTTPURL = ReplaceNocase(HTTP_URL, 'verticalPNL=1', '1=1','ALL')>
        <cfif ! listfind(HTTPURL,'&idealPriceAnalysis=1')>
          <cfset urlString = HTTPURL &  "&idealPriceAnalysis=1"/>
        <cfelse>
          <cfset urlString = HTTPURL/>
        </cfif>
        <a href="#urlString#">#application.util.string.actionLinkFormat2('ideal price analysis')#</a>
      </cfif>
      <!--- 114617 :: Ideal Price END --->
      <cfif url.verticalPNL eq "2" and variables.qWhatIf.recordCount gt 0>
            <!--- <span class="upd14">Page was last updated on #application.util.dateTime.dateTimeFormat(variables.qWhatIf.Changed_date)# by #variables.qWhatIf.Name_First# #variables.qWhatIf.Name_Last#</span> --->
            <cfscript>
                arrayAppend(variables.noty.Message, "This what if p&l was last modified by <b>#variables.qWhatIf.Name_First#  #variables.qWhatIf.Name_Last#</b> on #dateFormat(variables.qWhatIf.Changed_date, 'medium')#");
                arrayAppend(variables.noty.timeout, 0);
            </cfscript>
      </cfif>
      <br>
      <span id="approval_consideration">#variables.approval_consideration.getProgramText( getProgramInfo.contract_main_id )#</span>
    </div>
    <div id="uom35" style="text-align: right">
    <cfset newSpan = 1>
      <cfif DisplayMarginUOMCS>
        <cfset newSpan = newSpan + 1>
      </cfif>
      <cfif DisplayMarginUOMLB>
        <cfset newSpan = newSpan + 1>
      </cfif>
      <cfif DisplayMarginUOMEQ>
        <cfset newSpan = newSpan + 1>
      </cfif>
    <table >
      <tr>
        <td align="left" colspan="#newSpan#">#unitOfTime4Volume#</td>
      </tr>
      <tr>
        <td style="width:68px;text-align: right;">UOM :</td>
        <td style="text-align: left">
          <input type="radio" value="case" <cfif form.margin_type eq 1>checked</cfif> onClick = "changemarginTypePNL(1);">Physical Case
        </td>
        <td style="text-align: left">
          <input type="radio" value="lbs" <cfif form.margin_type eq 3>checked</cfif> onClick = "changemarginTypePNL(3);">#Application.UOMPoundPlural#
        </td>
      </tr>
    </table>
    <input type="hidden" name="margin_type" value="#form.margin_type#">
    </div>

    <div style="clear:both;"></div>

    <cfif url.verticalPNL eq "2">
        <div id="not07" style="margin-bottom:8px;">
            <label>Notes:</label> <textarea name="whatif_notes" rows="2"><cfif variables.qWhatIf.recordCount>#variables.qWhatIf.Notes#</cfif></textarea>
        </div>
    </cfif>

    <cfquery name="local.qMisc" datasource="#application.datasource#">
      SELECT Rsp = _Users.Name_First + ' ' + _Users.Name_Last
             ,po.Position_Label
             ,fixed_discount_count  = (SELECT COUNT(*)
                                         FROM PROGRAM_FIXED_COMPONENT pfc
                                        WHERE cm.Contract_Main_Id = pfc.Program_Id AND pfc.Deleted = 0)
             ,rebate_discount_count = (SELECT COUNT(*)
                                         FROM PROGRAM_REBATES_COMPONENT prc
                                        WHERE cm.Contract_Main_Id = prc.Program_Id AND prc.Deleted = 0)
             ,growth_discount_count = (SELECT COUNT(*)
                                         FROM Program_Growth_Components pgc
                                        WHERE cm.Contract_Main_Id = pgc.Program_Id AND pgc.Deleted = 0)
             ,ls_discount_count     = (SELECT COUNT(*)
                                         FROM PROGRAM_LUMP_SUMS pls
                                        WHERE cm.Contract_Main_Id = pls.Program_Id AND pls.Deleted = 0)
        FROM Contract_Main cm
             LEFT JOIN _Users ON _Users.User_ID = cm.Responsible_User_ID
             LEFT JOIN User_Positions po ON po.User_Positions_ID = '#getProgramInfo.Creating_User_Position_ID#'
       WHERE cm.Contract_Main_Id = #getProgramInfo.contract_main_id#
    </cfquery>

    <!--- cost detail information - applicable only when individual products are visible --->
    <cfif url.showProducts eq "1">
      <cfquery name="qCostDetail" datasource="#application.datasource#">
        SELECT
                CASE ISNULL(CAST(Contract_Product_Margin.Net_weight as FLOAT), 0)
                  WHEN 0 THEN 1
                  ELSE ISNULL(CAST(Contract_Product_Margin.Net_weight as FLOAT), 0)
                END                                              AS Net_weight
               ,IsNull(fpr_cs, 0)                                AS Fixed_Price_CS
               ,IsNull(rer_cs, 0)                                AS Rebate_Price_CS
               ,IsNull(grr_cs, 0)                                AS Growth_Price_CS
               ,IsNull(kpr_cs, 0)                                AS Formula_Price_CS
               ,IsNull(oer_cs, 0)                                AS Offinvoice_Price_CS
               ,IsNull(LumpSumAmount_cs, 0)                      AS LumpsumAmount_CS
               ,IsNull(LumpSumAmount_lb, 0)                      AS LumpsumAmount_LB
               ,Description
               ,Item
               ,Upc
               ,IsNull(Base_Sales_lb, 0)                         AS Base_Sales_LB
               ,IsNull(Base_Sales_cs, 0)                         AS Base_Sales_CS
               ,IsNull(Program_Fixed_Price_cs, 0)                AS Program_Fixed_Price_CS
               ,IsNull(Used_Fixed_Price, 0)                      AS Used_Fixed_Price
               ,IsNull(Net_Price_cs, 0)                          AS Net_Price_CS
               ,IsNull(Used_Net_Price, 0)                        AS Used_Net_Price
               ,( IsNull(Item_Allowance_cs, 0)
                  + IsNull(LumpSumAmount_cs, 0) )                AS Item_Allowance_CS
               ,( IsNull(Item_Allowance_lb, 0)
                  + IsNull(LumpSumAmount_lb, 0) )                AS Item_Allowance_LB
               ,( IsNull(AnnualiZed_Allowance_cs, 0)
                  + IsNull(AnnualiZed_LumpSum_Allowance_cs, 0) ) AS Item_Annualized_Allowance_CS
               ,( IsNull(AnnualiZed_Allowance_lb, 0)
                  + IsNull(AnnualiZed_LumpSum_Allowance_lb, 0) ) AS Item_Annualized_Allowance_LB
               ,IsNull(tPa_cs, 0)                                AS TPA_CS
               ,IsNull(PullBackAmount_cs, 0)                     AS PullbackAmount_CS
               ,IsNull(Cash_Discount_cs, 0)                      AS Cash_Discount_CS
               ,IsNull(Net_Sales_cs, 0)                          AS Net_Sales_CS
               ,IsNull(Cost_cs, 0)                               AS Cost_CS
               ,IsNull(dIff_Fixed_Price_cs, 0)                   AS Diff_Fixed_Price_CS
               ,IsNull(dIff_Formula_Price_cs, 0)                 AS Diff_Formula_Price_CS
               ,IsNull(var_Man_Cost, 0)                          AS Variable_Mfg_Cost
               ,IsNull(fx_Man_Cost, 0)                           AS Fixed_Mfg_Cost
               ,IsNull(del_frt_Cost, 0)                          AS Del_Frt_Cost
               ,IsNull(del_del_Cost, 0)                          AS Del_Del_Cost
               ,IsNull(del_var_Warhs, 0)                         AS Del_Var_Warhs
               ,IsNull(del_cUst_Pickup, 0)                       AS Del_Cust_Pickup
               ,IsNull(Fob_frt_Cost, 0)                          AS FOB_Frt_Cost
               ,IsNull(Fob_Warhs, 0)                             AS FOB_Warhs
               ,IsNull(cs_Curr_Cost, 0)                          AS Current_Cost
               ,IsNull(Cost_From_Component_cs, 0)                AS Cost_From_Component_CS
               ,Item_DeliveryType
               ,IsNull(TargetMargin, 0)                          AS TargetMargin,

                <!--- 66894 Margin Target ENH Forge START --->
                <cfif OperatorProgram>
                  ISNULL(Group_ID_Margin_Operator,0)
                <cfelse>
                  IsNull(Group_Id_Margin, 0)
                </cfif> AS Margin_Target_Variation
                <!--- 66894 Margin Target ENH Forge END --->

               ,GROUP_APPROVAL_RIGHTS.Group_Id_Margin
               ,Product_ID

          FROM dbo.CONTRACT_PRODUCT_MARGIN
               INNER JOIN BSA_FOODSERVICE_ITEMS_MASTER
                       ON BSA_FOODSERVICE_ITEMS_MASTER.bsa_FoodService_Items_Master_Id = CONTRACT_PRODUCT_MARGIN.Product_Id
                          AND BSA_FOODSERVICE_ITEMS_MASTER.Deleted = 0
               INNER JOIN TYPE_CODE_DESC
                       ON TYPE_CODE_DESC.Type_Code_desc_Id = BSA_FOODSERVICE_ITEMS_MASTER.Type_Code_desc_Id
                          AND TYPE_CODE_DESC.Deleted = 0
               LEFT JOIN GROUP_APPROVAL_RIGHTS
                      ON GROUP_APPROVAL_RIGHTS.Group_Id = TYPE_CODE_DESC.Type_Code_desc_Id
                         AND GROUP_APPROVAL_RIGHTS.User_Profile_Id = #request.Accessstructure.Profiles_ID#
                         AND GROUP_APPROVAL_RIGHTS.Deleted = 0
         WHERE Contract_Main_Id = #getProgramInfo.contract_main_id#
      </cfquery>

      <cfset useLakebaseForlocal_Item_Deliverytype1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qcostdetail")>
<cfif useLakebaseForlocal_Item_Deliverytype1>
	<cftry>
		<cfset local.Item_Deliverytype1 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qcostdetail", {
				"item_deliverytype" = "eq.1",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_Item_Deliverytype1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_Item_Deliverytype1>
<cfquery name="local.Item_Deliverytype1" dbtype="query">
        SELECT 1 FROM qCostDetail WHERE Item_Deliverytype = '1'
      </cfquery>
</cfif>
      <cfset useLakebaseForlocal_Item_Deliverytype2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qcostdetail")>
<cfif useLakebaseForlocal_Item_Deliverytype2>
	<cftry>
		<cfset local.Item_Deliverytype2 = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qcostdetail", {
				"item_deliverytype" = "eq.2",
				"select" = "1"
			}), "1"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_Item_Deliverytype2 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_Item_Deliverytype2>
<cfquery name="local.Item_Deliverytype2" dbtype="query">
        SELECT 1 FROM qCostDetail WHERE Item_Deliverytype = '2'
      </cfquery>
</cfif>

      <cfquery name="qTradeDetail" datasource="#application.datasource#">
        IF Object_Id( 'tempdb..##tmp_cp' ) IS NOT NULL
          DROP TABLE ##tmp_cp

        SELECT DISTINCT cp.bsa_FoodService_Items_Master_Id
                        ,Cast( 0 AS DECIMAL( 20, 2 )) AS Cash_Discount
                        ,Cast( 0 AS DECIMAL( 20, 2 )) AS Other_Allowances
                        ,Cast( 0 AS DECIMAL( 20, 2 )) AS Distributor_Trade
          INTO ##tmp_cp
          FROM Contract_Products cp
         WHERE cp.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#getProgramInfo.contract_main_id#">
               AND cp.Deleted = 0

        IF Object_Id( 'tempdb..##tmp_tpa' ) IS NOT NULL
          DROP TABLE ##tmp_tpa

        SELECT bsa_FoodService_Items_Master.bsa_FoodService_Items_Master_Id
               ,bsa_FoodService_Items_Master.Item
               ,CASE Contract_Main.Contract_Title
                  WHEN 'Cash Discount' THEN 'Cash Discount'
                  WHEN 'Other Allowances' THEN 'Other Allowances'
                  ELSE 'Distributor Trade'
                END                                                                                                                                                                        AS Trade_Type
               ,Sum( Cast( Cast( Program_Distributors_Trade.Rate AS FLOAT ) * 0.01 * Cast( cd.Program_Weight AS FLOAT ) AS DECIMAL ( 30, 10 )) )                                           AS Rate_lb
               ,Sum( Cast( Cast( Program_Distributors_Trade.Rate AS FLOAT ) * 0.01 * Cast( cd.Program_Weight AS FLOAT ) * bsa_FoodService_Items_Master.Net_Weight AS DECIMAL ( 30, 10 )) ) AS Rate_cs
          INTO ##tmp_tpa
          FROM Contract_Distributors cd
               INNER JOIN Program_Distributors_Trade ON Program_Distributors_Trade.bsa_FoodService_Customers_Id = cd.bsa_FoodService_Customers_Id
                                                        AND Program_Distributors_Trade.tPa_Record_Type = 0
                                                        AND ( Program_Distributors_Trade.Deleted = 0 )
               INNER JOIN Contract_Main ON Program_Distributors_Trade.Contract_Main_Id = Contract_Main.Contract_Main_Id
                                            AND Contract_Main.Contract_Number != <cfqueryparam cfsqltype="cf_sql_varchar" value="#getProgramInfo.contract_number#">
               INNER JOIN ##tmp_cp ON ##tmp_cp.bsa_FoodService_Items_Master_Id = Program_Distributors_Trade.bsa_FoodService_Items_Master_Id
               INNER JOIN bsa_FoodService_Items_Master ON Program_Distributors_Trade.bsa_FoodService_Items_Master_Id = bsa_FoodService_Items_Master.bsa_FoodService_Items_Master_Id
         WHERE cd.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#getProgramInfo.contract_main_id#">
               AND cd.Deleted = 0
         GROUP BY bsa_FoodService_Items_Master.bsa_FoodService_Items_Master_Id
                  ,bsa_FoodService_Items_Master.Item
                  ,CASE Contract_Main.Contract_Title
                     WHEN 'Cash Discount' THEN 'Cash Discount'
                     WHEN 'Other Allowances' THEN 'Other Allowances'
                     ELSE 'Distributor Trade'
                   END

        UPDATE cp
           SET Cash_Discount = <cfif form.margin_type eq 3> tpa.Rate_lb <cfelse> tpa.Rate_cs </cfif>
          FROM ##tmp_cp cp
               INNER JOIN ##tmp_tpa tpa ON tpa.bsa_FoodService_Items_Master_Id = cp.bsa_FoodService_Items_Master_Id
                                          AND tpa.Trade_Type = 'Cash Discount'

        UPDATE cp
           SET Other_Allowances = <cfif form.margin_type eq 3> tpa.Rate_lb <cfelse> tpa.Rate_cs </cfif>
          FROM ##tmp_cp cp
               INNER JOIN ##tmp_tpa tpa ON tpa.bsa_FoodService_Items_Master_Id = cp.bsa_FoodService_Items_Master_Id
                                          AND tpa.Trade_Type = 'Other Allowances'

        UPDATE cp
           SET Distributor_Trade = <cfif form.margin_type eq 3> tpa.Rate_lb <cfelse> tpa.Rate_cs </cfif>
          FROM ##tmp_cp cp
               INNER JOIN ##tmp_tpa tpa ON tpa.bsa_FoodService_Items_Master_Id = cp.bsa_FoodService_Items_Master_Id
                                          AND tpa.Trade_Type = 'Distributor Trade'

        SELECT *
          FROM ##tmp_cp
      </cfquery>
    </cfif>
    </cfoutput>

    <table cellspacing="0" id="GridView1" style="width:100%;border-collapse:collapse;">
      <!----------------------->
      <!--- COLUMNS HEADING --->
      <!----------------------->
      <tr class="GridviewScrollHeader">
        <th class="une82 670" id="one82"><cfoutput>
          #getProgramInfo.Contract_Number# -
          #dateFormat(getProgramInfo.Contract_Start_Date,'mmm d, yyyy')# to #dateFormat(getProgramInfo.Contract_End_Date,'mmm d, yyyy')#<br>
          #getProgramInfo.Contract_Title#<br>
          #local.qMisc.Rsp# (#trim(local.qMisc.Position_Label)#)
          </cfoutput>
        </th>
        <!--- Summary --->
        <th class="sum82 678" style="text-align:center;">Summary<br>Absolute $</th>
        <th class="sum82 679" style="text-align:center;">Summary<br>Rate / <cfoutput>#(form.margin_type eq '1' ? "CS" : application.UOMPoundSingular)#</cfoutput></th>

        <!--- Products & Type Code --->
        <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
          <cfset useLakebaseForlocal_getGroupValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallgroupmargins")>
<cfif useLakebaseForlocal_getGroupValues>
	<cftry>
		<cfset local.getGroupValues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallgroupmargins", {
				"type_code_desc_id" = "eq.#getallproductmargins.type_code_desc_id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_getGroupValues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_getGroupValues>
<cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
            select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
          </cfquery>
</cfif>
          <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? " noar" : "")>
          <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
          <cfif url.showProducts eq "1">
            <cfoutput>  <!--- invidual products cfoutput loop --->
              <th class="prod82 #variables.noApprovalClass# 690">   <!--- do not change class name it would break the what-if calculation logic --->

          <cfset item_UPC =''>
          <cfif (appSettings.get_Setting('Display_Item_No') eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND application.returned_customer_setting.upc_switch EQ 1>
            <cfset item_UPC = getAllProductMargins.upc>
         <cfelse>
            <cfset item_UPC = getAllProductMargins.Item>
         </cfif>
              <cfif appSettings.getViewPgmSortBy()>
                    #application.util.string.wrapText(getAllProductMargins.Description & ' ' & item_UPC)#
              <cfelse>
                    #application.util.string.wrapText(item_UPC & ' ' & getAllProductMargins.Description)#
              </cfif>
              </th>
            </cfoutput>
          </cfif>  <!--- url.showProducts eq "1" --->

          <!--- type code group cfoutput --->
          <th class="grp82 #variables.noApprovalClass# 708">    <!--- do not change class name it would break the what-if calculation logic --->
            #application.util.string.wrapText( getAllProductMargins.Type_Code_Desc )#
          </th>
        </cfoutput>  <!--- query="getAllProductMargins"> --->
      </tr>  <!--- class="GridviewScrollHeader"> --->

  <!--- 114617 :: Ideal Price START --->
  <cfif getProgramInfo.Ideal_Price>
    <tr class="GridviewScrollItem">
      <td class="une82">Ideal Price</td>
      <td class="sum82" id="albs"></td>
      <td class="sum82"> </td>

        <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <td>#application.util.string.cellFormat(value=getAllProductMargins.Ideal_Price ,decimalplaces = request.dollar_format )#</td>
              </cfoutput>
            </cfif>  <!--- url.showProducts eq "1" --->
        </cfoutput>  <!--- query="getAllProductMargins"> --->
    </tr>
    <tr class="GridviewScrollItem">
        <td class="une82">Difference</td>
        <td class="sum82" id="albs"></td>
        <td class="sum82"> </td>

          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
              <cfif url.showProducts eq "1">
                <cfset useLakebaseForlocal_detail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qcostdetail")>
<cfif useLakebaseForlocal_detail>
	<cftry>
		<cfset local.detail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qcostdetail", {
				"product_id" = "eq.#getAllProductMargins.Product_ID#",
				"select" = "net_weight,fixed_price_cs"
			}), "net_weight,fixed_price_cs"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_detail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_detail>
<cfquery name="local.detail" dbtype="query">
                  SELECT Net_weight,Fixed_Price_CS FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                </cfquery>
</cfif>

                <cfscript>
                  multiplier     = "*";
                  statMultiplier = "1";
                  IdealPrice = getAllProductMargins.Ideal_Price;

                  if (form.margin_type eq 3) {
                    multiplier     = "/";
                    statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
                  }
                  if(! statMultiplier){
                    statMultiplier = "1";
                  }
                  if(!IdealPrice){
                    IdealPrice = "1";
                  }

                  variables.value = local.detail.Fixed_Price_CS;
                  variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
                  variables.valuePer = (100 * variables.value)/IdealPrice;
                </cfscript>
                <cfoutput>  <!--- invidual products cfoutput loop --->
                  <td>
                    #application.util.string.cellFormat(value=variables.value, decimalplaces = request.dollar_format )#<br>
                    #application.util.string.cellFormat(value=variables.valuePer, decimalplaces = request.numeric_format )#%
                  </td>
                </cfoutput>
              </cfif>  <!--- url.showProducts eq "1" --->
          </cfoutput>  <!--- query="getAllProductMargins"> --->
    </tr>
    <tr class="GridviewScrollItem">
        <td class="une82">Ideal Price Diff $</td>
        <td class="sum82" id="albs"></td>
        <td class="sum82"> </td>

          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
              <cfif url.showProducts eq "1">
                <cfoutput>  <!--- invidual products cfoutput loop --->
                  <cfquery name="local.detail" dbtype="query">
                    SELECT Net_weight,Fixed_Price_CS FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                  </cfquery>

                  <cfscript>
                    multiplier     = "*";
                    statMultiplier = "1";

                    if (form.margin_type eq 3) {
                      multiplier     = "/";
                      statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
                    }
                    variables.value = local.detail.Fixed_Price_CS;
                    variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
                    variables.value = (variables.value - getAllProductMargins.Ideal_Price) * getAllProductMargins.Product_Program_Volume;
                  </cfscript>

                  <td>#application.util.string.cellFormat(value=variables.value ,decimalplaces = request.dollar_format )#</td>
                </cfoutput>
              </cfif>  <!--- url.showProducts eq "1" --->
          </cfoutput>  <!--- query="getAllProductMargins"> --->
    </tr>
  </cfif>
<!--- 114617 :: Ideal Price END --->
      <cfif form.margin_type eq '1'>
        <!------------------------->
        <!--- 002 - VOL. CS ------->
        <!------------------------->
        <tr class="GridviewScrollItem">
          <td class="une82 ln_719">Cases</td>
          <td class="sum82 ln_720" id="acases"><cfoutput>#application.util.string.cellFormat(round(getProgramMargins.totalprogramvolume), 'int')#</cfoutput></td>
          <td class="sum82 ln_721"> </td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfset variables.value = application.util.string.cellFormat(round(getAllProductMargins.Product_Program_Volume), 'int')>
                <td class="#variables.noApprovalClass# ln_733"><cfif url.verticalPNL eq '1'>
                      #variables.value#
                    <cfelse>
                      <!--- see if there is a saved what if row for this product --->
                      <cfquery dbtype="query" name="variables.whatIF">
                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfif variables.whatIF.recordCount>
                        <cfset variables.value = variables.whatIF.User_Volume>
                      </cfif>
                      <!--- control tabbing navigation from top to bottom & stay in the same product --->
                      <cfset variables.tabIndex = getAllProductMargins.currentRow * 1000>
                      <!--- assign unique name with prefix "cases_" and suffix of record number
                           ,assign common class with prefix "gcases_" and suffix of group number
                            for all products inside a group
                            IMPORTANT: GridViewScroll() adds "_Copy" suffix to the names! When reference is needed remember to use "_Copy" suffix.
                          --->
                      <input type="text" name="cases_#getAllProductMargins.currentRow#" class="gcases_#variables.group_idx# right" value="#variables.value#" #variables.disabled2# tabindex="#variables.tabIndex#">
                    </cfif>
                </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_757" id="gcases_#variables.group_idx#">#application.util.string.cellFormat(round(local.getGroupValues.Total_Product_Program_Volume), 'int')#</td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif> <!--- form.margin_type eq '1'> --->

      <cfif form.margin_type eq '3'>
        <!------------------------->
        <!--- 002X POUNDS --------->
        <!------------------------->
        <tr class="GridviewScrollItem">
          <td class="une82 ln_768">Pounds</td>
          <td class="sum82 ln_769" id="albs"><cfoutput>#application.util.string.cellFormat(round(getProgramMargins.totalprogramvolumelb), 'int')#</cfoutput></td>
          <td class="sum82 ln_770"> </td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
              <cfif form.margin_type eq '1'>
                <cfset variables.value = getAllProductMargins.Product_Program_Volume_LB>
              <cfelse>
                <cfset variables.value = getAllProductMargins.Product_Program_Volume>
              </cfif>
              <cfset variables.value = application.util.string.cellFormat(round(variables.value), 'int')>
                <td class="#variables.noApprovalClass# ln_787"><cfif url.verticalPNL eq '1'>
                      #variables.value#
                    <cfelse>
                      <!--- see if there is a saved what if row for this product --->
                      <cfquery dbtype="query" name="variables.whatIF">
                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfif variables.whatIF.recordCount>
                        <cfset variables.value = variables.whatIF.User_Volume>
                      </cfif>
                      <!--- control tabbing navigation from top to bottom & stay in the same product --->
                      <cfset variables.tabIndex = getAllProductMargins.currentRow * 1000>
                      <!--- assign unique name with prefix "lbs_" and suffix of record number
                           ,assign common class with prefix "glbs_" and suffix of group number
                            for all products inside a group
                            IMPORTANT: GridViewScroll() adds "_Copy" suffix to the names! When reference is needed remember to use "_Copy" suffix.
                          --->
                      <input type="text" name="lbs_#getAllProductMargins.currentRow#" class="glbs_#variables.group_idx# right" value="#variables.value#" #variables.disabled2#  tabindex="#variables.tabIndex#">
                    </cfif>
                </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <cfif form.margin_type eq '1'>
              <cfset variables.value = local.getGroupValues.Total_Product_Program_Volume_LB>
            <cfelse>
              <cfset variables.value = local.getGroupValues.Total_Product_Program_Volume>
            </cfif>
            <td class="grp82 #variables.noApprovalClass# ln_816" id="glbs_#variables.group_idx#">#application.util.string.cellFormat(round(variables.value), 'int')#</td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif> <!--- form.margin_type eq '3'> --->

      <!------------------->
      <!--- NET WEIGHT ---->
      <!------------------->
      <tr class="GridviewScrollItem">
        <td class="une82 ln_826">Net Weight</td>
        <td class="sum82 ln_827"> </td>
        <td class="sum82 ln_828"> </td>

        <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
          <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
            select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
          </cfquery>
          <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
          <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
          <cfif url.showProducts eq "1">
            <cfoutput>  <!--- invidual products cfoutput loop --->
              <cfquery name="local.detail" dbtype="query">
                SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
              </cfquery>
              <td class="#variables.noApprovalClass# ln_841">#local.detail.Net_weight#</td>
            </cfoutput>
          </cfif>  <!--- url.showProducts eq "1" --->

          <!--- type code group cfoutput --->
          <td class="grp82 #variables.noApprovalClass# ln_846"> </td>
        </cfoutput>  <!--- query="getAllProductMargins"> --->
      </tr>

      <!-------------------------------------->
      <!--- 003 - BASE SALES | LIST PRICE ---->
      <!-------------------------------------->
      <tr class="GridviewScrollItem">
        <td class="une82 ln_854"><cfoutput>#appsettings.getMarginColHeader2()#</cfoutput></td>
        <td class="sum82 ln_855" id="alist_price"><cfoutput>#application.util.string.cellFormat(value = round(getProgramMargins.Total_BaseSales * getProgramMargins.TotalProgramVolume), decimalplaces = request.dollar_format )# </cfoutput>
        </td>
        <td class="sum82 ln_857" id="ulist_price"><cfoutput>#application.util.string.cellFormat(value = getProgramMargins.Total_BaseSales, decimalplaces = request.dollar_format)#</cfoutput></td>

        <cfset variables.group_idx = 1>
        <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
          <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
            select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
          </cfquery>
          <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
          <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
          <cfif url.showProducts eq "1">
            <cfoutput>  <!--- invidual products cfoutput loop --->
              <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Base_Sales,decimalplaces = request.dollar_format)>
              <td class="#variables.noApprovalClass# ln_869"><cfif url.verticalPNL eq '1'>
                    <a href="##" onclick="showBaseSalesDetails('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#')">#variables.value#</a>
                  <cfelse>
                    <!--- see if there is a saved what if row for this product --->
                    <cfquery dbtype="query" name="variables.whatIF">
                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                    </cfquery>
                    <cfif variables.whatIF.recordCount>
                        <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_List_Price,decimalplaces = request.dollar_format)>
                    </cfif>
                    <!--- control tabbing navigation from top to bottom & stay in the same product --->
                    <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 10>
                    <!--- assign unique name with prefix "list_price_" and suffix of record number for all products inside a group --->
                    <input type="text" name="list_price_#getAllProductMargins.currentRow#" class="right" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                  </cfif>
              </td>
            </cfoutput>
          </cfif>  <!--- url.showProducts eq "1" --->

          <!--- type code group cfoutput --->
          <td class="grp82 #variables.noApprovalClass# ln_889" id="glist_price_#variables.group_idx#">#application.util.string.cellFormat(value = local.getGroupValues.Total_Base_Sales, decimalplaces = request.dollar_format)#</td>
          <cfset variables.group_idx++>
        </cfoutput>  <!--- query="getAllProductMargins"> --->
      </tr>

      <!---------------------------->
      <!--- 004 - CASH DISCOUNT ---->
      <!---------------------------->
      <cfif appsettings.getDisplayCashDiscountMargin() eq 1 >
        <tr class="GridviewScrollItem">
          <td class="une82 ln_899"><cfoutput><cfif appsettings.getlocalcostvariables() neq 1>#appsettings.getMarginColHeader3()#<cfelse>#appsettings.getMarginColHeader4()#</cfif></cfoutput></td>
          <td class="sum82 ln_900" id="acash_disc"><cfoutput>#application.util.string.cellFormat(value=round(getProgramMargins.Total_Cash_discount  * getProgramMargins.TotalProgramVolume),decimalplaces = request.dollar_format )# </cfoutput></td>
          <td class="sum82 ln_901" id="ucash_disc"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Cash_discount,decimalplaces = request.dollar_format)#</cfoutput></td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Cash_discount,decimalplaces = request.dollar_format)>
                <td class="#variables.noApprovalClass# 913"><cfif url.verticalPNL eq '1'>
                        #variables.value#
                    <cfelse>
                      <!--- see if there is a saved what if row for this product --->
                      <cfquery dbtype="query" name="variables.whatIF">
                          SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfif variables.whatIF.recordCount>
                          <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Cash_Disc,decimalplaces = request.dollar_format)>
                      </cfif>
                      <!--- control tabbing navigation from top to bottom & stay in the same product --->
                      <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 15>
                      <!--- assign unique name with prefix "cash_disc" and suffix of record number for all products inside a group --->
                      <input type="text" name="cash_disc_#getAllProductMargins.currentRow#" class="right" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                    </cfif>
                </td>
              </cfoutput>
            </cfif>  <!--- url.showProducts eq "1" --->

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_933" id="gcash_disc_#variables.group_idx#">#application.util.string.cellFormat(value=local.getGroupValues.Total_Cash_discount,decimalplaces = request.dollar_format)#</td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif>    <!--- <cfif appsettings.getDisplayCashDiscountMargin() eq 1 > --->

      <!---------------------------------->
      <!--- 005 - ALLOWANCE | DISCOUNT --->
      <!---------------------------------->
      <cfif direct_pricing eq 0>
        <tr class="GridviewScrollItem">
          <cfif form.Margin_Type eq 1 OR form.margin_type eq 3>
            <cfparam name="addExtra" default="0">
            <cfif getProgramMargins.TotalProgramVolume neq "" and getProgramMargins.TotalProgramVolume neq 0>
              <cfset addExtra = getProgramLumpsum.Lumpsum_Amount / getProgramMargins.TotalProgramVolume/>
            </cfif>
            <cfset local.TOTAL_Allowance = getProgramMargins.TOTAL_Allowance + addExtra>
          <cfelse>
            <cfset local.TOTAL_Allowance = getProgramMargins.TOTAL_Allowance/>
          </cfif>

          <td class="une82 master11 ln_954"><cfoutput>#appsettings.getMarginColHeader5()#</cfoutput></td>
          <td class="sum82 ln_955" id="adisc"><cfoutput>#application.util.string.cellFormat(value=local.TOTAL_Allowance * getProgramMargins.TotalProgramVolume,decimalplaces = request.dollar_format)#</cfoutput></td>
          <td class="sum82 ln_956" id="udisc"><cfoutput>#application.util.string.cellFormat(value=local.TOTAL_Allowance,decimalplaces = request.dollar_format)#</cfoutput></td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfset variables.value = application.util.string.cellFormat(appSettings.getApprovalMarginType() eq 2 ? getAllProductMargins.Item_Allowance_Annualized : getAllProductMargins.Item_Allowance)>
                <td class="#variables.noApprovalClass# ln_968" id="disc_#getAllProductMargins.currentRow#">
      <!--- D56447 :: EZ Rates Indicator inside a Program START --->
        <cfset EZrateIndicator = 0>
        <cfif getsettings.EZButton_On EQ 1 AND ListFind(ProductsBeyoundMaxRateList, getAllProductMargins.BSA_Foodservice_Items_Master_ID)>
          <cfset ezrate = listgetat(ProductsMaxRateList, ListFind(ProductsBeyoundMaxRateList, getAllProductMargins.BSA_Foodservice_Items_Master_ID))>
          <cfset EZrateIndicator = 0>
        </cfif>
     <!--- D56447 :: EZ Rates Indicator inside a Program END --->
                <cfif url.verticalPNL eq '1'>
                      <!--- <a href="##" onclick="showCalculation('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#','A','')">#variables.value#</a> --->
                      <cfif EZrateIndicator><b title="Item Rate above EZ rate. EZ Rate = $#ezrate#" style="font-size:12px;color:red;font-weight:bold;cursor:pointer;" align="absmiddle">( ! )</b></cfif> #trim(application.util.string.cellFormat(value=variables.value,decimalplaces = request.dollar_format))#
                    <cfelse>
                        <!--- see if there is a saved what if row for this product --->
                        <cfquery dbtype="query" name="variables.whatIF">
                            SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                        </cfquery>
                        <cfif variables.whatIF.recordCount>
                            <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Discount, decimalplaces = request.dollar_format)>
                        </cfif>
                        <cfif EZrateIndicator><b title="Item Rate above EZ rate. EZ Rate = $#ezrate#" style="font-size:12px;color:red;font-weight:bold;cursor:pointer;" align="absmiddle">( ! )</b></cfif> #variables.value#
                    </cfif>
                </td>
              </cfoutput>
            </cfif>  <!--- url.showProducts eq "1" --->

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_994" id="gdisc_#variables.group_idx#">
              <cfset variables.value = application.util.string.cellFormat(appSettings.getApprovalMarginType() eq 2 ? local.getGroupValues.Total_Item_Allowance_Annualized : local.getGroupValues.Total_Item_Allowance)>
             #application.util.string.cellFormat(value=variables.value,decimalplaces = request.dollar_format)#
            </td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>

        <cfif url.detail7 eq "show">
            <!------------------------->
            <!--- 001 - FIXED PRICE --->
            <!------------------------->
            <cfif variables.bDisplayContractPrice and local.qMisc.fixed_discount_count>
                <tr class="GridviewScrollItem detail11">
                  <cfoutput>
                  <td class="une82b ln_1009">#variables.spacer2#
                    <cfif len(trim(appsettings.getMarginColHeader15()))>
                      #appsettings.getMarginColHeader15()#
                    <cfelse>
                      Fixed Price
                    </cfif>
                  </td>
                  </cfoutput>
                  <td class="sum82 ln_1017"> </td>
                  <td class="sum82 ln_1018"> </td>

                  <cfset variables.group_idx = 1>
                  <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                      select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                    </cfquery>
                    <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                    <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <cfif url.showProducts eq "1">
                      <cfoutput>  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                          SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                        </cfquery>

                        <cfscript>
                            multiplier     = "*";
                            statMultiplier = "1";

                            if (form.margin_type eq 3) {
                              multiplier     = "/";
                              statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
                            }
                            variables.value = local.detail.Fixed_Price_CS;
                            variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
                            variables.value = application.util.string.cellFormat(value=variables.value,decimalplaces = request.dollar_format);
                        </cfscript>

                        <td class="#variables.noApprovalClass# ln_1046"><cfif url.verticalPNL eq '1'>
                              #variables.value#
                            <cfelse>
                                <!--- see if there is a saved what if row for this product --->
                                <cfquery dbtype="query" name="variables.whatIF">
                                    SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                                </cfquery>
                              <cfif variables.whatIF.recordCount and variables.whatIF.User_Fixed_Price neq "">
                                    <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Fixed_Price,decimalplaces = request.dollar_format)>
                                </cfif>
                                <!--- control tabbing navigation from top to bottom & stay in the same product --->
                                <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 40>
                                <!--- assign unique name with prefix "fixed_price_" and suffix of record number
                                   ,assign common class with prefix "gfixed_price_" and suffix of group number
                                    for all products inside a group
                                  --->
                                <input type="text" name="fixed_price_#getAllProductMargins.currentRow#" class="gfixed_price_#variables.group_idx# right" value="#variables.value#" #variables.disabled2#  tabindex="#variables.tabIndex#">
                            </cfif>
                        </td>
                      </cfoutput>  <!--- invidual products cfoutput loop --->
                    </cfif>  <!--- url.showProducts eq "1" --->

                    <!--- type code group cfoutput --->
                    <td class="grp82 #variables.noApprovalClass# ln_1069"> </td>
                    <cfset variables.group_idx++>
                  </cfoutput>  <!--- query="getAllProductMargins"> --->
                </tr>
            </cfif>  <!--- variables.bDisplayContractPrice> --->


            <!--------------------->
            <!--- 001b - REBATE --->
            <!--------------------->
            <cfif local.qMisc.rebate_discount_count>
                <tr class="GridviewScrollItem detail11">
                  <td class="une82b ln_1081"><cfoutput>#variables.spacer2#</cfoutput> Rebate</td>
                  <td class="sum82 ln_1082"> </td>
                  <td class="sum82 ln_1083"> </td>
                  <cfset variables.group_idx = 1>
                  <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                      select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                    </cfquery>
                    <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                    <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <cfif url.showProducts eq "1">
                      <cfoutput>  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                          SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                        </cfquery>

                        <cfscript>
                            multiplier     = "*";
                            statMultiplier = "1";

                            if (form.margin_type eq 3) {
                              multiplier     = "/";
                              statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
                            }
                            variables.value = local.detail.Rebate_Price_CS;
                            variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
                            variables.value = application.util.string.cellFormat(value=variables.value,decimalplaces = request.dollar_format);
                        </cfscript>

                        <td class="#variables.noApprovalClass# ln_1110"><cfif url.verticalPNL eq '1'>
                              #variables.value#
                            <cfelse>
                              <!--- see if there is a saved what if row for this product --->
                              <cfquery dbtype="query" name="variables.whatIF">
                                SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                              </cfquery>
                              <cfif variables.whatIF.recordCount and variables.whatIF.User_Rebate neq "">
                                <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Rebate,decimalplaces = request.dollar_format)>
                              </cfif>
                              <!--- control tabbing navigation from top to bottom & stay in the same product --->
                              <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 41>
                              <!--- assign unique name with prefix "rebate_" and suffix of record number for all products inside a group --->
                              <input type="text" name="rebate_#getAllProductMargins.currentRow#" class="right" value="#variables.value#" #variables.disabled2#  tabindex="#variables.tabIndex#">
                            </cfif>
                        </td>
                      </cfoutput>
                    </cfif>
                    <!--- type code group cfoutput --->
                    <td class="grp82 #variables.noApprovalClass# ln_1129"> </td>
                    <cfset variables.group_idx++>
                  </cfoutput>
                </tr>
            </cfif>    <!--- local.qMisc.rebate_discount_count> --->


            <!--------------------->
            <!--- 001c - GROWTH --->
            <!--------------------->
            <cfif local.qMisc.growth_discount_count>
                <tr class="GridviewScrollItem detail11">
                  <td class="une82b ln_1141"><cfoutput>#variables.spacer2#</cfoutput> Growth</td>
                  <td class="sum82 ln_1142"> </td>
                  <td class="sum82 ln_1143"> </td>
                  <cfset variables.group_idx = 1>
                  <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                      select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                    </cfquery>
                    <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                    <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <cfif url.showProducts eq "1">
                      <cfoutput>  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                          SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                        </cfquery>

                        <cfscript>
                            multiplier     = "*";
                            statMultiplier = "1";

                            if (form.margin_type eq 3) {
                              multiplier     = "/";
                              statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
                            }
                            variables.value = local.detail.Growth_Price_CS;
                            variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
                            variables.value = application.util.string.cellFormat(value=variables.value,decimalplaces = request.dollar_format);
                        </cfscript>

                        <td class="#variables.noApprovalClass# ln_1170"><cfif url.verticalPNL eq '1'>
                              #variables.value#
                            <cfelse>
                              <!--- see if there is a saved what if row for this product --->
                              <cfquery dbtype="query" name="variables.whatIF">
                                SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                              </cfquery>
                              <cfif variables.whatIF.recordCount and variables.whatIF.User_Growth neq "">
                                <cfset variables.value = application.util.string.cellFormat(value= variables.whatIF.User_Growth,decimalplaces = request.dollar_format)>
                              </cfif>
                              <!--- control tabbing navigation from top to bottom & stay in the same product --->
                              <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 42>
                              <!--- assign unique name with prefix "growth_" and suffix of record number for all products inside a group --->
                              <input type="text" name="growth_#getAllProductMargins.currentRow#" class="right" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                            </cfif>
                        </td>
                      </cfoutput>
                    </cfif>
                    <!--- type code group cfoutput --->
                    <td class="grp82 #variables.noApprovalClass# ln_1189"> </td>
                    <cfset variables.group_idx++>
                  </cfoutput>
                </tr>
            </cfif>    <!--- local.qMisc.growth_discount_count --->


            <!----------------------->
            <!--- 001d - LUMP SUM --->
            <!----------------------->
            <cfif local.qMisc.ls_discount_count>
                <tr class="GridviewScrollItem detail11">
                  <td class="une82b ln_1201"><cfoutput>#variables.spacer2#</cfoutput> Lump Sum</td>
                  <td class="sum82 ln_1202"> </td>
                  <td class="sum82 ln_1203"> </td>
                  <cfset variables.group_idx = 1>
                  <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                      select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                    </cfquery>
                    <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                    <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <cfif url.showProducts eq "1">
                      <cfoutput>  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                          SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                        </cfquery>

                        <cfscript>
                            multiplier     = "*";
                            statMultiplier = "1";

                            if (form.margin_type eq 3) {
                              multiplier     = "/";
                              statMultiplier = (NOT local.detail.Net_weight ? 1 : local.detail.Net_weight);
                            }
                            variables.value = local.detail.LumpsumAmount_CS;
                            variables.value = (multiplier eq "*" ? variables.value * statMultiplier : variables.value / statMultiplier);
                            variables.value = application.util.string.cellFormat(value=variables.value,decimalplaces = request.dollar_format);
                        </cfscript>

                        <td class="#variables.noApprovalClass# ln_1230"><cfif url.verticalPNL eq '1'>
                              #variables.value#
                            <cfelse>
                              <!--- see if there is a saved what if row for this product --->
                              <cfquery dbtype="query" name="variables.whatIF">
                                SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                              </cfquery>
                              <cfif variables.whatIF.recordCount and variables.whatIF.User_Lump_Sum neq "">
                                <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Lump_Sum,decimalplaces = request.dollar_format)>
                              </cfif>
                              <!--- control tabbing navigation from top to bottom & stay in the same product --->
                              <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 43>
                              <!--- assign unique name with prefix "lump_sum_" and suffix of record number for all products inside a group --->
                              <input type="text" name="lump_sum_#getAllProductMargins.currentRow#" class="right" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                            </cfif>
                        </td>
                      </cfoutput>
                    </cfif>
                    <!--- type code group cfoutput --->
                    <td class="grp82 #variables.noApprovalClass# ln_1249"> </td>
                    <cfset variables.group_idx++>
                  </cfoutput>
                </tr>
            </cfif>    <!--- local.qMisc.ls_discount_count --->
        </cfif>   <!--- url.detail7 eq "show"> --->

        <!---------------------------------->
        <!--- 006 - ALLOW % | DISCOUNT % --->
        <!---------------------------------->
        <tr class="GridviewScrollItem">
          <td class="une82 ln_1260"><cfoutput>#appsettings.getMarginColHeader23()#</cfoutput></td>
          <td class="sum82 ln_1261" id="adisc_percent">
            <cfif local.TOTAL_Allowance eq 0 or getProgramMargins.Total_BaseSales eq 0>
              N/A
            <cfelseif local.TOTAL_Allowance lt 0>
              0.00%
            <cfelse>
              <cfoutput>#application.util.string.cellFormat(value= 100 * (local.TOTAL_Allowance / getProgramMargins.Total_BaseSales), decimalplaces = request.numeric_format)# %</cfoutput>
            </cfif>
          </td>
          <td class="sum82 ln_1270"> </td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfset local.Allowance_Display_Value = ( appSettings.getApprovalMarginType() eq 2 ? getAllProductMargins.Item_Allowance_Annualized : getAllProductMargins.Item_Allowance )/>
                <td class="per82 prod #variables.noApprovalClass# ln_1282" id="disc_percent_#getAllProductMargins.currentRow#">
                  <cfscript>
                    if (local.Allowance_Display_Value eq 0 or getAllProductMargins.Base_Sales eq 0)
                      variables.cellValue = "N/A";
                    else if ( val(local.Allowance_Display_Value) lt 0 )
                      variables.cellValue = "0.00%";
                    else
                      variables.cellValue = application.util.string.cellFormat(value=100 * (local.Allowance_Display_Value / getAllProductMargins.Base_Sales),decimalplaces = request.numeric_format) & "%";
                  </cfscript>
                  <cfif url.verticalPNL eq '2'>
                      <!--- see if there is a saved what if row for this product --->
                      <cfquery dbtype="query" name="variables.whatIF">
                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfif variables.whatIF.recordCount>
                        <cfset variables.cellValue = " ">   <!--- to be calculated later by calculate() --->
                      </cfif>
                  </cfif>
                  #variables.cellValue#
                </td>
              </cfoutput>
            </cfif>  <!--- url.showProducts eq "1" --->

            <!--- type code group cfoutput --->
            <td class="per82g #variables.noApprovalClass# ln_1306" id="gdisc_percent_#variables.group_idx#">
              <cfset local.Total_Item_Allowance_Display_Value = ( appSettings.getApprovalMarginType() eq 2 ? local.getGroupValues.Total_Item_Allowance_Annualized : local.getGroupValues.Total_Item_Allowance )>
              <cfif local.Total_Item_Allowance_Display_Value eq 0 OR local.getGroupValues.Total_Base_Sales eq 0>
                N/A
              <cfelseif local.Total_Item_Allowance_Display_Value LT 0>
                0.00%
              <cfelse>
                #application.util.string.cellFormat(value=100 * (local.Total_Item_Allowance_Display_Value / local.getGroupValues.Total_Base_Sales),decimalplaces = request.numeric_format)#%
              </cfif>
            </td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif> <!--- direct_pricing eq 0> --->

      <!------------------------------------->
      <!--- 007 - TPA | TRADE --------------->
      <!------------------------------------->
      <cfif showtpa eq 1>
        <tr class="GridviewScrollItem">
          <td class="une82 ln_1326"><cfoutput>#appsettings.getMarginColHeader6()#</cfoutput></td>
          <td class="sum82 ln_1327" id="atrade"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TPA * getProgramMargins.TotalProgramVolume,decimalplaces = request.dollar_format)#</cfoutput></td>
          <td class="sum82 ln_1328" id="utrade"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TPA,decimalplaces = request.dollar_format)#</cfoutput></td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfquery dbtype="query" name="qOneTrade">
                  SELECT * FROM qTradeDetail WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                </cfquery>
        <cfif (qOneTrade.Distributor_Trade EQ '')>
          <cfset DistTrade = 0.00 />
        <cfelse>
          <cfset DistTrade = qOneTrade.Distributor_Trade />
        </cfif>
                <cfset variables.value = application.util.string.cellFormat( value=qOneTrade.Cash_discount + qOneTrade.Other_Allowances + DistTrade,decimalplaces = request.dollar_format )>
                <td class="#variables.noApprovalClass# ln_1348" id="trade_#getAllProductMargins.currentRow#">
                    <cfif url.verticalPNL eq '1'>
                      #variables.value#
                    <cfelse>
                      <!--- see if there is a saved what if row for this product --->
                      <cfquery dbtype="query" name="variables.whatIF">
                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfif variables.whatIF.recordCount>
                        <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Trade,decimalplaces = request.dollar_format)>
                      </cfif>
                      #variables.value#
                    </cfif>
                </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_1366" id="gtrade_#variables.group_idx#">#application.util.string.cellFormat(local.getGroupValues.Total_TPA)#</td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>

        <cfif url.detail7 eq "show">
              <cfif appsettings.getDisplayCashDiscountMargin() neq 1 >
                <!----------------------->
                <!--- TRADE CASH DISC --->
                <!----------------------->
                <tr class="GridviewScrollItem">
                  <td class="une82b ln_1377"><cfoutput>#variables.spacer2#</cfoutput> <cfoutput>Cash Discount</cfoutput></td>
                  <td class="sum82 ln_1378"> </td>
                  <td class="sum82 ln_1379"> </td>

                  <cfset variables.group_idx = 1>
                  <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                      select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                    </cfquery>
                    <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                    <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <cfif url.showProducts eq "1">
                      <cfoutput>  <!--- invidual products cfoutput loop --->
                        <cfquery dbtype="query" name="qOneTrade">
                          SELECT * FROM qTradeDetail WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                        </cfquery>
                        <cfset variables.value = application.util.string.cellFormat( value=qOneTrade.Cash_discount,decimalplaces = request.dollar_format )>
                        <td class="#variables.noApprovalClass# ln_1394">
                            <cfif url.verticalPNL eq '1'>
                                #variables.value#
                            <cfelse>
                              <!--- see if there is a saved what if row for this product --->
                              <cfquery dbtype="query" name="variables.whatIF">
                                SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                              </cfquery>
                              <cfif variables.whatIF.recordCount>
                                <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Trade_Cash_Disc,decimalplaces = request.dollar_format)>
                              </cfif>
                              <!--- control tabbing navigation from top to bottom & stay in the same product --->
                              <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 51>
                              <!--- assign unique name with prefix "cash_disc_" and suffix of record number
                                   ,assign common class with prefix "gcash_disc_" and suffix of group number
                                    for all products inside a group
                                  --->
                              <input type="text" name="trade_cash_disc_#getAllProductMargins.currentRow#" class="gtrade_cash_disc_#variables.group_idx# right" value="#variables.value#" #variables.disabled2# tabindex="#variables.tabIndex#">
                            </cfif>
                        </td>
                      </cfoutput>
                    </cfif>  <!--- url.showProducts eq "1" --->

                    <!--- type code group cfoutput --->
                    <td class="grp82 #variables.noApprovalClass# ln_1418" id="gcash_disc_#variables.group_idx#"> </td>
                    <cfset variables.group_idx++>
                  </cfoutput>  <!--- query="getAllProductMargins"> --->
                </tr>

                <!---------------------------->
                <!--- 888 OTHER ALLOWANCES --->
                <!---------------------------->
                <tr class="GridviewScrollItem">
                  <td class="une82b ln_1427"><cfoutput>#variables.spacer2#</cfoutput> <cfoutput>Other Allowances</cfoutput></td>
                  <td class="sum82 ln_1428"> </td>
                  <td class="sum82 ln_1429"> </td>

                  <cfset variables.group_idx = 1>
                  <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                      select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                    </cfquery>
                    <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                    <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <cfif url.showProducts eq "1">
                      <cfoutput>  <!--- invidual products cfoutput loop --->
                        <cfquery dbtype="query" name="qOneTrade">
                          SELECT * FROM qTradeDetail WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                        </cfquery>
                        <cfset variables.value = application.util.string.cellFormat( value=qOneTrade.Other_Allowances, decimalplaces = request.dollar_format)>
                        <td class="#variables.noApprovalClass# ln_1444">
                            <cfif url.verticalPNL eq '1'>
                                #variables.value#
                            <cfelse>
                              <!--- see if there is a saved what if row for this product --->
                              <cfquery dbtype="query" name="variables.whatIF">
                                SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                              </cfquery>
                              <cfif variables.whatIF.recordCount>
                                <cfset variables.value = application.util.string.cellFormat(value= variables.whatIF.User_trade_other_allowances, decimalplaces = request.dollar_format)>
                              </cfif>
                              <!--- control tabbing navigation from top to bottom & stay in the same product --->
                              <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 52>
                              <!--- assign unique name with prefix "cash_disc_" and suffix of record number
                                   ,assign common class with prefix "gcash_disc_" and suffix of group number
                                    for all products inside a group
                                  --->
                              <input type="text" name="trade_other_allowances_#getAllProductMargins.currentRow#" class="gcash_disc_#variables.group_idx# right" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                            </cfif>
                        </td>
                      </cfoutput>
                    </cfif>  <!--- url.showProducts eq "1" --->

                    <!--- type code group cfoutput --->
                    <td class="grp82 #variables.noApprovalClass# ln_1468" id="gcash_disc_#variables.group_idx#"> </td>
                    <cfset variables.group_idx++>
                  </cfoutput>  <!--- query="getAllProductMargins"> --->
                </tr>
              </cfif>     <!--- <cfif appsettings.getDisplayCashDiscountMargin() neq 1 > --->


              <!----------------------------->
              <!--- 999 DISTRIBUTOR TRADE --->
              <!----------------------------->
              <tr class="GridviewScrollItem">
                <td class="une82b ln_1479"><cfoutput>#variables.spacer2#</cfoutput> <cfoutput>Distributor Trade</cfoutput></td>
                <td class="sum82 ln_1480"> </td>
                <td class="sum82 ln_1481"> </td>

                <cfset variables.group_idx = 1>
                <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                  <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                    select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                  </cfquery>
                  <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                  <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                  <cfif url.showProducts eq "1">
                    <cfoutput>  <!--- invidual products cfoutput loop --->
                      <cfquery dbtype="query" name="qOneTrade">
                        SELECT * FROM qTradeDetail WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfset variables.value = application.util.string.cellFormat( value= qOneTrade.Distributor_Trade,decimalplaces = request.dollar_format )>
                      <td class="#variables.noApprovalClass# ln_1496">
                          <cfif url.verticalPNL eq '1'>
                              #variables.value#
                          <cfelse>
                            <!--- see if there is a saved what if row for this product --->
                            <cfquery dbtype="query" name="variables.whatIF">
                              SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                            </cfquery>
                            <cfif variables.whatIF.recordCount>
                              <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Distributor_Trade,decimalplaces = request.dollar_format)>
                            </cfif>
                            <!--- control tabbing navigation from top to bottom & stay in the same product --->
                            <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 53>
                            <!--- assign unique name with prefix "distributor_trade_" and suffix of record number
                                 ,assign common class with prefix "gdistributor_trade_" and suffix of group number
                                  for all products inside a group
                                --->
                            <input type="text" name="distributor_trade_#getAllProductMargins.currentRow#" class="gdistributor_trade_#variables.group_idx# right" value="#variables.value#" #variables.disabled2# tabindex="#variables.tabIndex#">
                          </cfif>
                      </td>
                    </cfoutput>
                  </cfif>  <!--- url.showProducts eq "1" --->

                  <!--- type code group cfoutput --->
                  <td class="grp82 #variables.noApprovalClass# ln_1520" id="gdistributor_trade_#variables.group_idx#"> </td>
                  <cfset variables.group_idx++>
                </cfoutput>  <!--- query="getAllProductMargins"> --->
              </tr>
        </cfif>    <!--- url.detail7 eq "show"> --->
      </cfif> <!--- showtpa eq 1> --->

      <!------------------------------------->
      <!--- 008 - PULLBACK AMOUNT | AMT + --->
      <!------------------------------------->
      <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
        <tr class="GridviewScrollItem">
          <td class="une82 ln_1532"><cfoutput>#appsettings.getMarginColHeader7()#</cfoutput></td>
          <td class="sum82 ln_1533" id="aamt_plus"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_pullbackamount,decimalplaces = request.dollar_format)#</cfoutput></td>
          <td class="sum82 ln_1534"> </td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Pullbackamount,decimalplaces = request.dollar_format)>
                <td class="#variables.noApprovalClass# ln_1546"><cfif url.verticalPNL eq '1'>
                      #variables.value#
                    <cfelse>
                      <!--- see if there is a saved what if row for this product --->
                      <cfquery dbtype="query" name="variables.whatIF">
                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfif variables.whatIF.recordCount>
                        <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Pullback,decimalplaces = request.dollar_format)>
                      </cfif>
                      <!--- control tabbing navigation from top to bottom & stay in the same product --->
                      <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 60>
                      <!--- assign unique name with prefix "amt_plus_" and suffix of record number for all products inside a group --->
                      <input type="text" name="amt_plus_#getAllProductMargins.currentRow#" class="right" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                    </cfif>
                </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_1566" id="gamt_plus_#variables.group_idx#" #variables.noApprovalClass#>#application.util.string.cellFormat(value=local.getGroupValues.Total_Pullbackamount,decimalplaces = request.dollar_format)#</td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif> <!--- appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1> --->

      <!----------------------->
      <!--- 009 - NET SALES --->
      <!----------------------->
      <cfif appSettings.getApprovalMarginType() eq 0>
        <tr class="GridviewScrollItem">
          <td class="une82 ln_1577"><cfoutput>#appsettings.getMarginColHeader8()#</cfoutput></td>
          <td class="sum82 ln_1578" id="anet_sales"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.TOTAL_NetSales * getProgramMargins.TotalProgramVolume,decimalplaces = request.dollar_format)#</cfoutput></td>
          <td class="sum82 ln_1579" id="unet_sales"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.TOTAL_NetSales,decimalplaces = request.dollar_format)#</cfoutput></td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Net_Sales,decimalplaces = request.dollar_format)>
                <td id="net_sales_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass# ln_1591">
                    <cfif url.verticalPNL eq '1'>
                      <a href="##" onclick="showCalculation('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#','N','')">#variables.value#</a>
                    <cfelse>
                      <!--- see if there is a saved what if row for this product --->
                      <cfquery dbtype="query" name="variables.whatIF">
                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfif variables.whatIF.recordCount>
                        <cfset variables.value = " ">
                      </cfif>
                      #variables.value#
                    </cfif>
                </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_1609" id="gnet_sales_#variables.group_idx#">#application.util.string.cellFormat(value=local.getGroupValues.Total_Net_Sales,decimalplaces = request.dollar_format)#</td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif> <!--- appSettings.getApprovalMarginType() eq 0> --->

      <!------------------>
      <!--- 010 - COST --->
      <!------------------>
      <cfif Get_Profile_Settings.View_Cost eq 1>
        <tr class="GridviewScrollItem">
          <td class="une82 ln_1620"><cfoutput>#appsettings.getMarginColHeader9()#</cfoutput></td>
          <td class="sum82 ln_1621" id="acost"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Cost * getProgramMargins.TotalProgramVolume,decimalplaces = request.dollar_format)#</cfoutput></td>
          <td class="sum82 ln_1622" id="ucost"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Cost,decimalplaces = request.dollar_format)#</cfoutput></td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <td id="cost_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass# ln_1633">
                  <!--- <a href="##" onclick="showCalculation('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#','C','')"> --->
                  <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Cost,decimalplaces = request.dollar_format)>
                  <cfif url.verticalPNL eq '2'>
                      <!--- see if there is a saved what if row for this product --->
                      <cfquery dbtype="query" name="variables.whatIF">
                        SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                      </cfquery>
                      <cfif variables.whatIF.recordCount>
                        <cfset variables.value = " ">  <!--- value to be calculated in calculate() --->
                      </cfif>
                  </cfif>
                  #variables.value#
                </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_1651" id="gcost_#variables.group_idx#">#application.util.string.cellFormat(value=local.getGroupValues.Total_Cost,decimalplaces = request.dollar_format)#</td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>

        <cfif url.detail7 eq "show">
            <!--------------------------------------->
            <!--- COST DETAIL INFORMATION | START --->
            <!--------------------------------------->
            <cfif appsettings.getApprovalLayeredCosts() eq 1 and url.showProducts eq "1">
                <!------------------------>
                <!--- 200 Current Cost --->
                <!------------------------>
                <tr class="GridviewScrollItem">
                  <td class="une82b ln_1665"><cfoutput>#variables.spacer2#</cfoutput> Current Cost</td>
                  <td class="sum82 ln_1666"> </td>
                  <td class="sum82 ln_1667"> </td>

                  <cfset variables.group_idx = 1>
                  <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                      select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                    </cfquery>
                    <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                    <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <cfif url.showProducts eq "1">
                      <cfoutput>  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                          SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                        </cfquery>
                        <cfset variables.value = application.util.string.cellFormat(value=local.detail.Current_Cost / (form.margin_type eq '3' ? local.detail.Net_Weight : 1),decimalplaces = request.dollar_format)>
                        <td class="#variables.noApprovalClass# ln_1682"><cfif url.verticalPNL eq '1'>
                              #variables.value#
                            <cfelse>
                              <!--- control tabbing navigation from top to bottom & stay in the same product --->
                              <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 80>
                              <input type="text" name="curr_cost_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#" #variables.disabled2# tabindex="#variables.tabIndex#">
                            </cfif>
                        </td>
                      </cfoutput>
                    </cfif>

                    <!--- type code group cfoutput --->
                    <td class="grp82 #variables.noApprovalClass# ln_1694"> </td>
                  </cfoutput>  <!--- query="getAllProductMargins"> --->
                </tr>

      <cfelseif appsettings.getApprovalLayeredCosts() EQ 2>
        <!--------------------------------------->
                <!--- 100 Variable Manufacturing Cost --->
        <!--------------------------------------->
        <cfif not appSettings.getMarginCostColHeader1_delete()>
          <tr class="GridviewScrollItem">
            <td class="une82b ln_1704"><cfoutput>#variables.spacer2# #appsettings.getMarginCostColHeader1()#</cfoutput></td>
            <td class="sum82 ln_1705"> </td>
            <td class="sum82 ln_1706"> </td>

            <cfset variables.group_idx = 1>
            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
              <cfquery name="local.detail" dbtype="query">
                SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
              </cfquery>
              <cfset variables.value = application.util.string.cellFormat(value=local.detail.Variable_Mfg_Cost / (form.margin_type eq '3' ? local.detail.Net_Weight : 1),decimalplaces = request.dollar_format)>
              <td class="#variables.noApprovalClass# ln_1721"><cfif url.verticalPNL eq '1'>
                  #variables.value#
                <cfelse>
                  <!--- see if there is a saved what if row for this product --->
                  <cfquery dbtype="query" name="variables.whatIF">
                  SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                  </cfquery>
                  <cfif variables.whatIF.recordCount>
                  <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_DVL,decimalplaces = request.dollar_format)>
                  </cfif>
                  <!--- control tabbing navigation from top to bottom & stay in the same product --->
                  <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 110>
                  <input type="text" name="dvl_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                </cfif>
              </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_1740"> </td>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr>
        </cfif>

                <!------------------------------------>
                <!--- 101 Fixed Manufacturing Cost --->
                <!------------------------------------>
        <cfif not appSettings.getMarginCostColHeader2_delete()>
          <tr class="GridviewScrollItem">
            <td class="une82b ln_1750"><cfoutput>#variables.spacer2# #appsettings.getMarginCostColHeader2()#</cfoutput></td>
            <td class="sum82 ln_1751"> </td>
            <td class="sum82 ln_1752"> </td>

            <cfset variables.group_idx = 1>
            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
              <cfquery name="local.detail" dbtype="query">
                SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
              </cfquery>
              <cfset variables.value = application.util.string.cellFormat(value=local.detail.Fixed_mfg_cost / (form.margin_type eq '3' ? local.detail.Net_Weight : 1),decimalplaces = request.dollar_format)>
              <td class="#variables.noApprovalClass# ln_1767"><cfif url.verticalPNL eq '1'>
                  #variables.value#
                <cfelse>
                  <!--- see if there is a saved what if row for this product --->
                  <cfquery dbtype="query" name="variables.whatIF">
                  SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                  </cfquery>
                  <cfif variables.whatIF.recordCount>
                  <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Fixed_Cost,decimalplaces = request.dollar_format)>
                  </cfif>
                  <!--- control tabbing navigation from top to bottom & stay in the same product --->
                  <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 120>
                  <input type="text" name="fixed_cost_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                </cfif>
              </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_1786"> </td>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr>
        </cfif>

                <!------------------------------------------------------------>
                <!--- 103 Delivery (applicable to Item_Deliverytype = "1") --->
                <!------------------------------------------------------------>
        <cfif not appSettings.getMarginCostColHeader3_delete() and url.showProducts eq "1">
          <!--- <cfif url.showProducts eq "1" and local.Item_Deliverytype1.recordCount gt 0> --->
          <tr class="GridviewScrollItem">
            <td class="une82b ln_1797"><cfoutput>#variables.spacer2# #appsettings.getMarginCostColHeader3()#</cfoutput></td>
            <td class="sum82 ln_1798"> </td>
            <td class="sum82 ln_1799"> </td>

            <cfset variables.group_idx = 1>
            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
              <cfquery name="local.detail" dbtype="query">
                SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
              </cfquery>
              <cfset variables.value = (local.detail.Item_Deliverytype eq "1" ? application.util.string.cellFormat(local.detail.Del_Del_Cost / (form.margin_type eq '3' ? local.detail.Net_Weight : 1)) : "0")>
              <td class="#variables.noApprovalClass# ln_1814"><cfif url.verticalPNL eq '1'>
                  #application.util.string.cellFormat(value= variables.value ,decimalplaces = request.dollar_format)#
                <cfelse>
                  <!--- see if there is a saved what if row for this product --->
                  <cfquery dbtype="query" name="variables.whatIF">
                  SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                  </cfquery>
                  <cfif variables.whatIF.recordCount>
                  <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Raw_Material,decimalplaces = request.dollar_format)>
                  </cfif>
                  <!--- control tabbing navigation from top to bottom & stay in the same product --->
                  <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 90>
                  <input type="text" name="raw_material_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                </cfif>
              </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_1833"> </td>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr>
        </cfif>

                <!------------------------------------------------------------------------------>
                <!--- 104 Customer Pick up Allowance (applicable to Item_Deliverytype = "1") --->
                <!------------------------------------------------------------------------------>
                <!--- <cfif url.showProducts eq "1" and local.Item_Deliverytype1.recordCount gt 0> --->
                <cfif not appSettings.getMarginCostColHeader4_delete() and url.showProducts eq "1">
                  <tr class="GridviewScrollItem">
                    <td class="une82b ln_1844"><cfoutput>#variables.spacer2# #appsettings.getMarginCostColHeader4()#</cfoutput></td>
                    <td class="sum82 ln_1845"> </td>
                    <td class="sum82 ln_1846"> </td>

                    <cfset variables.group_idx = 1>
                    <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                      <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                        select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                      </cfquery>
                      <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                      <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                      <cfif url.showProducts eq "1">
                        <cfoutput>  <!--- invidual products cfoutput loop --->
                          <cfquery name="local.detail" dbtype="query">
                            SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                          </cfquery>
                          <cfset variables.value = (local.detail.Item_Deliverytype eq "1" ? application.util.string.cellFormat(local.detail.Del_Cust_Pickup / (form.margin_type eq '3' ? local.detail.Net_Weight : 1)) : "0")>
                          <td class="#variables.noApprovalClass# ln_1861"><cfif url.verticalPNL eq '1'>
                                #application.util.string.cellFormat(value=variables.value,decimalplaces = request.dollar_format)#
                              <cfelse>
                                <!--- see if there is a saved what if row for this product --->
                                <cfquery dbtype="query" name="variables.whatIF">
                                  SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                                </cfquery>
                                <cfif variables.whatIF.recordCount>
                                  <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Packaging,decimalplaces = request.dollar_format)>
                                </cfif>
                                <!--- control tabbing navigation from top to bottom & stay in the same product --->
                                <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 100>
                                <input type="text" name="packaging_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                              </cfif>
                          </td>
                        </cfoutput>
                      </cfif>

                      <!--- type code group cfoutput --->
                      <td class="grp82 #variables.noApprovalClass# ln_1880"> </td>
                    </cfoutput>  <!--- query="getAllProductMargins"> --->
                  </tr>
                </cfif>  <!--- local.Item_Deliverytype1.Count gt 0> --->


                <!------------------------------------------------------------------------>
                <!--- 105 Variable Warehousing (applicable to Item_Deliverytype = "1") --->
                <!------------------------------------------------------------------------>
                <!--- <cfif url.showProducts eq "1" and local.Item_Deliverytype1.recordCount gt 0> --->
        <cfif not appSettings.getMarginCostColHeader5_delete() and url.showProducts eq "1">
          <tr class="GridviewScrollItem">
            <td class="une82b ln_1892"><cfoutput>#variables.spacer2# #appsettings.getMarginCostColHeader5()#</cfoutput></td>
            <td class="sum82 ln_1893"> </td>
            <td class="sum82 ln_1894"> </td>

            <cfset variables.group_idx = 1>
            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
              <cfquery name="local.detail" dbtype="query">
                SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
              </cfquery>
              <cfset variables.value = (local.detail.Item_Deliverytype eq "1" ? application.util.string.cellFormat(local.detail.Del_Var_Warhs / (form.margin_type eq '3' ? local.detail.Net_Weight : 1)) : "0")>
              <td class="#variables.noApprovalClass# ln_1909"><cfif url.verticalPNL eq '1'>
                  #application.util.string.cellFormat(value=variables.value,decimalplaces = request.dollar_format)#
                <cfelse>
                  <!--- see if there is a saved what if row for this product --->
                  <cfquery dbtype="query" name="variables.whatIF">
                  SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                  </cfquery>
                  <cfif variables.whatIF.recordCount>
                  <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Equip_CEMA,decimalplaces = request.dollar_format)>
                  </cfif>
                  <!--- control tabbing navigation from top to bottom & stay in the same product --->
                  <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 140>
                  <input type="text" name="equip_cema_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                </cfif>
              </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_1928"> </td>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr>
        </cfif>


        <!----------------------------------------------------------------------------------->
                <!--- 102 - Freight Delivered cost factor (applicable to Item_Deliverytype = "1") --->
                <!----------------------------------------------------------------------------------->
                <!--- <cfif url.showProducts eq "1" and local.Item_Deliverytype1.recordCount gt 0> --->
        <cfif not appSettings.getMarginCostColHeader6_delete() and url.showProducts eq "1">
                  <tr class="GridviewScrollItem">
                    <td class="une82b ln_1940"><cfoutput>#variables.spacer2# #appsettings.getMarginCostColHeader6()#</cfoutput></td>
                    <td class="sum82 ln_1941"> </td>
                    <td class="sum82 ln_1942"> </td>

                    <cfset variables.group_idx = 1>
                    <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                      <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                        select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                      </cfquery>
                      <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                      <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                      <cfif url.showProducts eq "1">
                        <cfoutput>  <!--- invidual products cfoutput loop --->
                          <cfquery name="local.detail" dbtype="query">
                            SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                          </cfquery>
                          <cfset variables.value = (local.detail.Item_Deliverytype eq "1" ? application.util.string.cellFormat(local.detail.Del_frt_cost / (form.margin_type eq '3' ? local.detail.Net_Weight : 1)) : "0")>
                          <td class="#variables.noApprovalClass# ln_1957"><cfif url.verticalPNL eq '1'>
                                #application.util.string.cellFormat(value=variables.value, decimalplaces = request.dollar_format)#
                              <cfelse>
                                <!--- see if there is a saved what if row for this product --->
                                <cfquery dbtype="query" name="variables.whatIF">
                                  SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                                </cfquery>
                                <cfif variables.whatIF.recordCount>
                                  <cfset variables.value = application.util.string.cellFormat(value= variables.whatIF.User_DNT, decimalplaces = request.dollar_format)>
                                </cfif>
                                <!--- control tabbing navigation from top to bottom & stay in the same product --->
                                <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 130>
                                <input type="text" name="dnt_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                              </cfif>
                          </td>
                        </cfoutput>
                      </cfif>

                      <!--- type code group cfoutput --->
                      <td class="grp82 #variables.noApprovalClass# ln_1976"> </td>
                    </cfoutput>  <!--- query="getAllProductMargins"> --->
                  </tr>
                </cfif>  <!--- local.Item_Deliverytype1.Count gt 0> --->

                <!--------------------------------------------------------------->
                <!--- 106 Freight FOB (applicable to Item_Deliverytype = "2") --->
                <!--------------------------------------------------------------->
                <!--- <cfif url.showProducts eq "1" and local.Item_Deliverytype2.recordCount gt 0> --->
        <cfif not appSettings.getMarginCostColHeader7_delete() and url.showProducts eq "1">
                  <tr class="GridviewScrollItem">
                    <td class="une82b ln_1987"><cfoutput>#variables.spacer2#  #appsettings.getMarginCostColHeader7()#</cfoutput></td>
                    <td class="sum82 ln_1988"> </td>
                    <td class="sum82 ln_1989"> </td>

                    <cfset variables.group_idx = 1>
                    <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                      <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                        select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                      </cfquery>
                      <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                      <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                      <cfif url.showProducts eq "1">
                        <cfoutput>  <!--- invidual products cfoutput loop --->
                          <cfquery name="local.detail" dbtype="query">
                            SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                          </cfquery>
                          <cfset variables.value = (local.detail.Item_Deliverytype eq "2" ? application.util.string.cellFormat(local.detail.FOB_Frt_Cost / (form.margin_type eq '3' ? local.detail.Net_Weight : 1)) : "0")>
                          <td class="#variables.noApprovalClass# ln_2004"><cfif url.verticalPNL eq '1'>
                                #application.util.string.cellFormat(value=variables.value, decimalplaces = request.dollar_format)#
                              <cfelse>
                                <!--- see if there is a saved what if row for this product --->
                                <cfquery dbtype="query" name="variables.whatIF">
                                  SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                                </cfquery>
                                <cfif variables.whatIF.recordCount>
                                  <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Freight_FOB, decimalplaces = request.dollar_format)>
                                </cfif>
                                <!--- control tabbing navigation from top to bottom & stay in the same product --->
                                <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 150>
                                <input type="text" name="Freight_FOB_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                              </cfif>
                          </td>
                        </cfoutput>
                      </cfif>

                      <!--- type code group cfoutput --->
                      <td class="grp82 #variables.noApprovalClass# ln_2023"> </td>
                    </cfoutput>  <!--- query="getAllProductMargins"> --->
                  </tr>
                </cfif>  <!--- local.Item_Deliverytype2.Count gt 0> --->

                <!----------------------------------------------------------------->
                <!--- 107 Warehouse FOB (applicable to Item_Deliverytype = "2") --->
                <!----------------------------------------------------------------->
                <!--- <cfif url.showProducts eq "1" and local.Item_Deliverytype2.recordCount gt 0> --->
        <cfif not appSettings.getMarginCostColHeader8_delete() and url.showProducts eq "1">
                  <tr class="GridviewScrollItem">
                    <td class="une82b ln_2034"><cfoutput>#variables.spacer2# #appsettings.getMarginCostColHeader8()#</cfoutput></td>
                    <td class="sum82 ln_2035"> </td>
                    <td class="sum82 ln_2036"> </td>

                    <cfset variables.group_idx = 1>
                    <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                      <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                        select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                      </cfquery>
                      <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                      <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                      <cfif url.showProducts eq "1">
                        <cfoutput>  <!--- invidual products cfoutput loop --->
                          <cfquery name="local.detail" dbtype="query">
                            SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                          </cfquery>
                          <cfset variables.value = (local.detail.Item_Deliverytype eq "2" ? application.util.string.cellFormat(local.detail.FOB_Warhs / (form.margin_type eq '3' ? local.detail.Net_Weight : 1)) : "0")>
                          <td class="#variables.noApprovalClass# ln_2051"><cfif url.verticalPNL eq '1'>
                                #application.util.string.cellFormat(value=variables.value, decimalplaces = request.dollar_format)#
                              <cfelse>
                                <!--- see if there is a saved what if row for this product --->
                                <cfquery dbtype="query" name="variables.whatIF">
                                  SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                                </cfquery>
                                <cfif variables.whatIF.recordCount>
                                  <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Warehouse_FOB, decimalplaces = request.dollar_format)>
                                </cfif>
                                <!--- control tabbing navigation from top to bottom & stay in the same product --->
                                <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 160>
                                <input type="text" name="Warehouse_FOB_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                              </cfif>
                          </td>
                        </cfoutput>
                      </cfif>

                      <!--- type code group cfoutput --->
                      <td class="grp82 #variables.noApprovalClass# ln_2070"> </td>
                    </cfoutput>  <!--- query="getAllProductMargins"> --->
                  </tr>
                </cfif>  <!--- local.Item_Deliverytype2.Count gt 0> --->
            </cfif>  <!--- appsettings.getApprovalLayeredCosts() EQ 2> --->

            <cfif url.showProducts eq "1">
              <!--- 300 Component Cost --->
              <tr class="GridviewScrollItem">
                <td class="une82b ln_2079"><cfoutput>#variables.spacer2#</cfoutput> Component Cost</td>
                <td class="sum82 ln_2080"> </td>
                <td class="sum82 ln_2081"> </td>

                <cfset variables.group_idx = 1>
                <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                  <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                    select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
                  </cfquery>
                  <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
                  <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                  <cfif url.showProducts eq "1">
                    <cfoutput>  <!--- invidual products cfoutput loop --->
                      <cfquery name="local.detail" dbtype="query">
                        SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                      </cfquery>
                      <cfset variables.value = application.util.string.cellFormat(local.detail.Cost_From_Component_CS / (form.margin_type eq '3' ? local.detail.Net_Weight : 1))>
                      <td class="#variables.noApprovalClass# ln_2096"><cfif url.verticalPNL eq '1'>
                            <a href="##" onclick="displayComponentCostDetails('#getAllProductMargins.Product_ID#')">#application.util.string.cellFormat(value=variables.value, decimalplaces = request.dollar_format)#</a>
                          <cfelse>
                            <!--- see if there is a saved what if row for this product --->
                            <cfquery dbtype="query" name="variables.whatIF">
                              SELECT * FROM variables.qWhatIfProduct WHERE BSA_Foodservice_Items_Master_ID = '#getAllProductMargins.BSA_Foodservice_Items_Master_ID#'
                            </cfquery>
                            <cfif variables.whatIF.recordCount>
                              <cfset variables.value = application.util.string.cellFormat(value=variables.whatIF.User_Comp_Cost, decimalplaces = request.dollar_format)>
                            </cfif>
                            <!--- control tabbing navigation from top to bottom & stay in the same product --->
                            <cfset variables.tabIndex = (getAllProductMargins.currentRow * 1000) + 170>
                            <input type="text" name="comp_cost_#getAllProductMargins.currentRow#" class="right subcost_#getAllProductMargins.currentRow#" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                          </cfif>
                      </td>
                    </cfoutput>
                  </cfif>

                  <!--- type code group cfoutput --->
                  <td class="grp82 #variables.noApprovalClass# ln_2115"> </td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->
              </tr>
            </cfif>  <!--- url.showProducts eq "1"> --->
            <!--------------------------------------->
            <!--- COST DETAIL INFORMATION | END   --->
            <!--------------------------------------->
        </cfif>    <!--- url.detail7 eq "show"> --->
      </cfif> <!--- Get_Profile_Settings.View_Cost eq 1> --->

      <!----------------------->
      <!--- 011 - BROKERAGE --->
      <!----------------------->
      <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
        <tr class="GridviewScrollItem">
          <td class="une82 ln_2130"><cfoutput>#appsettings.getMarginColHeader10()#</cfoutput></td>
          <td class="sum82 ln_2131" id="abrokerage"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Brokerage  * getProgramMargins.TotalProgramVolume, decimalplaces = request.dollar_format)#</cfoutput></td>
          <td class="sum82 ln_2132" id="ubrokerage"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_Brokerage, decimalplaces = request.dollar_format)#</cfoutput></td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
              <td class="#variables.noApprovalClass# ln_2143"><cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Broker_Cost, decimalplaces = request.dollar_format)>
                  <cfif url.verticalPNL eq '1'>
                  <a href="##" onclick="showBrokerage('#replace(getAllProductMargins.Product_Id, "-", "_", "ALL")#')">
                  #variables.value#
                  </a>
                  <cfelse>
                    <!--- control tabbing navigation from top to bottom & stay in the same product --->
                    <cfset variables.tabIndex = (getAllProductMargins.currentRow * 2000) + 10>
                    <!--- assign unique name with prefix "brokerage_" and suffix of record number for all products inside a group --->
                    <input type="text" name="brokerage_#getAllProductMargins.currentRow#" class="right" value="#variables.value#"  #variables.disabled2# tabindex="#variables.tabIndex#">
                  </cfif>
              </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_2159" id="gbrokerage_#variables.group_idx#">
              #application.util.string.cellFormat(value=local.getGroupValues.Total_Brokerage, decimalplaces = request.dollar_format)#
            </td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif> <!--- appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1> --->

      <!------------------------------>
      <!--- 012 - OPERATING INCOME --->
      <!------------------------------>
      <cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
        <tr class="GridviewScrollItem">
          <td class="une82 ln_2172"><cfoutput>#appsettings.getMarginColHeader11()#</cfoutput></td>
          <td class="sum82 ln_2173" id="aopr_inc">
            <cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_OprIncome  * getProgramMargins.TotalProgramVolume, decimalplaces = request.dollar_format)#</cfoutput>
          </td>
          <td class="sum82 ln_2176" id="uopr_inc">
            <cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_OprIncome, decimalplaces = request.dollar_format)#</cfoutput>
          </td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Operating_Income, decimalplaces = request.dollar_format)>
                <td id="opr_inc_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass# ln_2190">#variables.value#
                  <!---<input type="hidden" name="opr_income_#getAllProductMargins.currentRow#" class="right" value="#variables.value#">--->
                </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_2197" id="gopr_inc_#variables.group_idx#">
            #application.util.string.cellFormat(value=local.getGroupValues.Total_Operating_Income, decimalplaces = request.dollar_format)#
            </td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif>  <!--- Get_Profile_Settings.View_Operating_Income eq 1> --->

      <!------------------------------>
      <!--- 013 - OPERATING MARGIN --->
      <!------------------------------>
      <cfif Get_Profile_Settings.View_Target_Margins eq 1>
        <cfif appSettings.getApprovalMarginType() eq 2><!--- Approval = Annual Case Rate --->
          <!------------------------------->
          <!--- 013a - Annual Case Rate --->
          <!------------------------------->
          <tr class="GridviewScrollItem">
            <td class="une82 ln_2214"><cfoutput>#appsettings.getMarginColHeader18()#</cfoutput></td>
            <td class="sum82 ln_2215" id="aopr_margin"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TradeAmt, decimalplaces = request.dollar_format)#</cfoutput></td>
            <td class="sum82 ln_2216"> </td>

            <cfset variables.group_idx = 1>
            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
              <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
              </cfquery>
              <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
              <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
              <cfif url.showProducts eq "1">
                <cfoutput>  <!--- invidual products cfoutput loop --->
                  <td class="#variables.noApprovalClass# ln_2227">
                    <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Trade, decimalplaces = request.dollar_format)>
                    #variables.value#
                  </td>
                </cfoutput>
              </cfif>

              <!--- type code group cfoutput --->
              <td class="grp82 #variables.noApprovalClass# ln_2235">#application.util.string.cellFormat(value=local.getGroupValues.Total_Trade, decimalplaces = request.dollar_format)#</td>
              <cfset variables.group_idx++>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr>

          <!------------>
          <!--- 013z --->
          <!------------>
          <!--- <tr class="GridviewScrollItem">
            <td class="une82">&nbsp;</td>
            <td class="sum82">&nbsp;</td>
            <td class="sum82">&nbsp;</td>

            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <td>&nbsp;</td>
              </cfoutput>

              <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
              </cfquery>
              <!--- type code group cfoutput --->
              <td>&nbsp;</td>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr> --->

          <!------------------------------->
          <!--- 013B - TARGET CASE RATE --->
          <!------------------------------->
          <tr class="GridviewScrollItem">
            <td class="une82 ln_2265"><cfoutput>#appsettings.getMarginColHeader19()#</cfoutput></td>
            <td class="sum82 ln_2266"> </td>
            <td class="sum82 ln_2267"> </td>

            <cfset variables.group_idx = 1>
            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
              <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
              </cfquery>
              <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
              <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
              <cfif url.showProducts eq "1">
                <cfoutput>  <!--- invidual products cfoutput loop --->
                  <td class="#variables.noApprovalClass# 2278"> </td>
                </cfoutput>
              </cfif>

              <!--- type code group cfoutput --->
              <td class="#variables.noApprovalClass# 2283"> </td>
              <cfset variables.group_idx++>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr>
        <cfelse>  <!--- appSettings.getApprovalMarginType() eq 2 --->
          <!--------------------------------------->
          <!--- 013M - OPERATING MARGIN PERCENT --->
          <!--------------------------------------->
          <tr class="GridviewScrollItem">
            <td class="une82 ln_2292"><cfoutput>#appsettings.getMarginColHeader12()#</cfoutput></td>
            <td class="sum82 ln_2293" id="aopr_margin"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_OprMargin, decimalplaces = request.numeric_format)#%</cfoutput></td>
            <td class="sum82 ln_2294"> </td>

            <cfset variables.group_idx = 1>
            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
              <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
              </cfquery>
              <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
              <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
              <cfif url.showProducts eq "1">
                <cfoutput>  <!--- invidual products cfoutput loop --->
                  <td id="opr_margin_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass# ln_2305">
                    <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.OperatingMargin_percent, decimalplaces = request.numeric_format)>
                    #variables.value#%
                    <!---<input type="hidden" name="opr_margin_#getAllProductMargins.currentRow#" class="right" value="#variables.value#">--->
                  </td>
                </cfoutput>
              </cfif>

              <!--- type code group cfoutput --->
              <td class="grp82 #variables.noApprovalClass# ln_2314" id="gopr_margin_#variables.group_idx#">
                #application.util.string.cellFormat(value=local.getGroupValues.Total_OperatingMargin_percent, decimalplaces = request.numeric_format)#%
              </td>
              <cfset variables.group_idx++>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr>

          <!----------------------->
          <!--- 013N - TARGET % --->
          <!----------------------->
          <tr class="GridviewScrollItem">
            <td class="une82 ln_2325"><cfoutput>#appsettings.getMarginColHeader13()#</cfoutput></td>
            <td class="sum82 ln_2326"> </td>
            <td class="sum82 ln_2327"> </td>

            <cfset variables.group_idx = 1>
            <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
              <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
                select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
              </cfquery>
              <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
              <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
              <cfif url.showProducts eq "1">
                <cfoutput>  <!--- invidual products cfoutput loop --->
                <cfif marginTagetEnabled and appSettings.getuploadmargintargets_on()>
                  <cfset margin = trim(numberformat(TargetMargin,'_-___,___,___,___,___._'))>
                  <cfset variationmargin  = Get_Profile_Settings.Margin_Target_Variation>
                  <cfif trim(variationmargin) NEQ "*">
                    <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
                    <cfif appSettings.getApprovalMarginType() eq 1>
                        <cfset approvalmargin  = margin + ((margin * variationmargin)/100)>
                    <cfelse>
                        <cfset approvalmargin  = margin - ((margin * variationmargin)/100)>
                    </cfif>
                    <td class="ln_2348">#application.util.string.cellFormat(value = approvalmargin, decimalplaces = request.numeric_format)# %</td>
                  <cfelse>
                    <cfset approvalmargin  = "*">
                    <td class="#variables.noApprovalClass# ln_2351">#approvalmargin#</td>
                  </cfif>
                <cfelse>  <!--- marginTagetEnabled and appSettings.getuploadmargintargets_on()> --->
                  <td class="prod #variables.noApprovalClass# ln_2354"> </td>
                </cfif>
                </cfoutput>
              </cfif>  <!--- url.showProducts eq "1" --->

              <cfif trim(local.getGroupvalues.Group_ID_Margin) NEQ "*" and trim(local.getGroupvalues.Group_ID_Margin) NEQ "">
                <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
                <cfif appSettings.getApprovalMarginType() eq 1>
                  <cfset groupapprovalmargin = Target_Margin + ((Target_Margin * local.getGroupvalues.Group_ID_Margin)/100)>
                <cfelse>
                  <cfset groupapprovalmargin = Target_Margin - ((ABS(Target_Margin) * local.getGroupvalues.Group_ID_Margin)/100)>
                </cfif>
              <cfelse>
                <cfset groupapprovalmargin = "*">
              </cfif>
              <!--- type code group cfoutput --->
              <td class="grp82 #variables.noApprovalClass# ln_2370">
                <a href="##" onclick="showCalculation('#replace(Type_code_desc_id, "-", "_", "ALL")#','T','G')">
                  <cfif groupapprovalmargin LT 0 and groupapprovalmargin NEQ "*">
                    #application.util.string.cellFormat(value = groupapprovalmargin, decimalplaces = request.numeric_format)# %
                  <cfelseif groupapprovalmargin eq "*">
                    #application.util.string.cellFormat(value=Target_Margin, decimalplaces = request.numeric_format)# %
                  <cfelse>
                    #application.util.string.cellFormat(value=groupapprovalmargin, decimalplaces = request.numeric_format)# %
                  </cfif>
                </a>
              </td>
              <cfset variables.group_idx++>
            </cfoutput>  <!--- query="getAllProductMargins"> --->
          </tr>
        </cfif> <!--- appSettings.getApprovalMarginType() eq 2> --->
      </cfif> <!--- Get_Profile_Settings.View_Target_Margins eq 1> --->

      <!---------------------->
      <!--- 014 - TRADE CS --->
      <!---------------------->
      <cfif appSettings.getApprovalMarginType() eq 1>
        <tr class="GridviewScrollItem">
          <td class="une82 ln_2392"><cfoutput>#appsettings.getMarginColHeader16()#</cfoutput></td>
          <td class="sum82 ln_2393"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TradeAmt * getProgramMargins.TotalProgramVolume, decimalplaces = request.dollar_format)#</cfoutput></td>
          <td class="sum82 ln_2394"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TradeAmt, decimalplaces = request.dollar_format)#</cfoutput></td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <td class="#variables.noApprovalClass# ln_2405"> </td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="#variables.noApprovalClass# ln_2410"> </td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif> <!--- appSettings.getApprovalMarginType() eq 1> --->

      <!---------------------->
      <!--- 015 - TRADE %  --->
      <!---------------------->
      <cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>

        <tr class="GridviewScrollItem">
          <td class="une82 ln_2422"><cfoutput>#appsettings.getMarginColHeader17()#</cfoutput></td>
          <td class="sum82 ln_2423"><cfoutput>#application.util.string.cellFormat(value=getProgramMargins.Total_TradePercent, decimalplaces = request.numeric_format)# %</cfoutput></td>
          <td class="sum82 ln_2424"> </td>

          <cfset variables.group_idx = 1>
          <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
            <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
              select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
            </cfquery>
            <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
            <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
            <cfif url.showProducts eq "1">
              <cfoutput>  <!--- invidual products cfoutput loop --->
                <td class="#variables.noApprovalClass# ln_2435">#application.util.string.cellFormat(value= getAllProductMargins.Trade_Percent, decimalplaces = request.numeric_format)# %</td>
              </cfoutput>
            </cfif>

            <!--- type code group cfoutput --->
            <td class="grp82 #variables.noApprovalClass# ln_2440">#application.util.string.cellFormat(value=local.getGroupValues.Total_Trade_Percent, decimalplaces = request.numeric_format)# %</td>
            <cfset variables.group_idx++>
          </cfoutput>  <!--- query="getAllProductMargins"> --->
        </tr>
      </cfif> <!--- (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 ...> --->

      <!-------------------------------->
      <!--- 016 - TRADE SPENT | CSA  --->
      <!-------------------------------->
      <tr class="GridviewScrollItem">
        <td class="une82 ln_2450"><cfoutput>#appsettings.getMarginColHeader14()#</cfoutput></td>
        <td class="sum82 ln_2451" id="acsa"><cfoutput>#application.util.string.cellFormat(value=program_spend_in_margin_uot, decimalplaces = request.dollar_format)#</cfoutput></td>
        <td class="sum82 ln_2452"> </td>

        <cfset variables.group_idx = 1>
        <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
          <cfquery name="local.getGroupValues" dbtype="query" maxRows="1">
            select * from getAllGroupMargins where type_code_desc_id = '#getallproductmargins.type_code_desc_id#'
          </cfquery>
          <cfset variables.noApprovalClass = (local.getGroupValues.Group_ID_Approval eq 0 ? "noar" : "")>
          <cfset variables.disabled2       = (local.getGroupValues.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
          <cfif url.showProducts eq "1">
            <cfoutput>  <!--- invidual products cfoutput loop --->
              <td id="csa_#getAllProductMargins.currentRow#" class="#variables.noApprovalClass# ln_2463">
                <cfset variables.value = application.util.string.cellFormat(value=getAllProductMargins.Item_Allowance * round(getAllProductMargins.Product_Program_Volume), decimalplaces = request.dollar_format)>
                #variables.value#
              </td>
            </cfoutput>
          </cfif>

          <!--- type code group cfoutput --->
          <td class="grp82 #variables.noApprovalClass# ln_2471" id="gcsa_#variables.group_idx#">#application.util.string.cellFormat(value=local.getGroupValues.Total_Item_Allowance * round(local.getGroupValues.Total_Product_Program_Volume), decimalplaces = request.dollar_format)#</td>
          <cfset variables.group_idx++>
        </cfoutput>  <!--- query="getAllProductMargins"> --->
      </tr>
    </table>    <!--- id="t82"> --->
  </cfsavecontent>
  <cfoutput>#application.util.string.compress( variables.mainContent )#</cfoutput>

<cfelse>

    <cf_include files="/script/javascript/gridviewscroll/1.0/gridviewscroll.js, \Script\javascript\gridviewscroll\1.0\gridviewscroll-for-margin.css">

    <cfquery name="getGlobalUOM" datasource="#application.datasource#">
        SELECT Global_Target_UOM
        FROM General_Settings
    </cfquery>
    <cfif appSettings.getApprovalMarginType() NEQ 3>
        <cfset UOMdisplay = '%'>
    <cfelse>
        <cfif getGlobalUOM.Global_Target_UOM EQ 1>
            <cfset UOMdisplay = 'CS'>
        <cfelseif getGlobalUOM.Global_Target_UOM EQ 2>
            <cfset UOMdisplay = 'LB'>
        <cfelseif getGlobalUOM.Global_Target_UOM EQ 3>
            <cfset UOMdisplay = 'Equiv Cs'>
        <cfelse>
            <cfset UOMdisplay = 'CS'>
        </cfif>
    </cfif>



<cfoutput>
<cfif ! url.idealPriceAnalysis>
<span id="approval_consideration">#variables.approval_consideration.getProgramText( getProgramInfo.contract_main_id )#</span>
  <!-------------------------------------------------------------------------------------------------------------------->
  <!---  HORIZONTALPNL()  ---------------------------------------------------------------------------------------------->
  <!-------------------------------------------------------------------------------------------------------------------->
  <table class="Maintable" cellpadding="0" cellspacing="0" width="100%"  >
    <TR>
      <TD align="left" style="color:red;font-size:11px;border-bottom:none;" class="ln_2511">
      <!---D50860 :: Release 8.0 - Improvements to the 'View Margin' page inside a program START --->
        <cfif isDefined("ProgramIsARevision") AND ProgramIsARevision NEQ 0>
          <div style="float:left;margin-right:80px;">*** NOTE: This Is A Revision Of An Existing Program ***</div>
        </cfif>
      <!---D50860 :: Release 8.0 - Improvements to the 'View Margin' page inside a program END --->
      </TD>
      <TD class="title6 ln_2518"  STYLE="font-size: 12px; font-weight:bold; color: Navy;border-bottom:none;" align="right">
        <cfset newSpan = 1>
        <cfif DisplayMarginUOMCS>
          <cfset newSpan = newSpan + 1>
        </cfif>
        <cfif DisplayMarginUOMLB>
          <cfset newSpan = newSpan + 1>
        </cfif>
        <cfif DisplayMarginUOMEQ>
          <cfset newSpan = newSpan + 1>
        </cfif>
        <table >
          <tr>
            <td style="border:none;" class="ln_2531" align="left" colspan="#newSpan#">#unitOfTime4Volume#</td>
          </tr>
          <tr>
            <td style="width:58px;border:none;text-align: right;" class="ln_2534">UOM :</td>
            <cfif DisplayMarginUOMCS>
            <td  style="border:none;" class="ln_2536">
              <input type="radio" name="Margin_Type" value="1" <cfif form.margin_type eq 1>checked</cfif> onClick = "changemarginType();">Physical Case &nbsp;&nbsp;
            </td>
          </cfif>
          <cfif DisplayMarginUOMLB>
            <td  style="border:none;" class="ln_2541">
              <input type="radio" name="Margin_Type" value="3" <cfif form.margin_type eq 3>checked</cfif> onClick = "changemarginType();"><cfoutput>#Application.UOMPoundPlural# &nbsp;&nbsp;</cfoutput>
            </td>
          </cfif>
          <cfif DisplayMarginUOMEQ>
            <td  style="border:none;" class="ln_2546">
              <input type="radio" name="Margin_Type" value="2" <cfif form.margin_type eq 2>checked</cfif> onClick = "changemarginType();"><cfoutput>#appsettings.getMarginColHeader22()#</cfoutput>
            </td>
          </cfif>
          </tr>
        </table>
      </TD>
   </TR>
   <TR>
      <TD colspan="2"  class="ln_2555">
          <cfif isDefined("MarginDate")>
            #MarginDate#
          </cfif>
      </TD>
    </TR>
  </table>
<cfelse>
  <!--- 114617 :: Ideal Price START --->
  <table cellpadding="5" cellspacing="0" width="100%" border="0">
    <tr style="width:49%">
      <td colspan="3"><SPAN CLASS="Title4">Ideal Price Analysis</span><br>Try different prices to see the effect.</td>
    </tr>
    <tr style="width:49%">
      <td style="width:33%">
        <table border="0" width="100%">
          <tr>
            <td style="width:28%">
              <button type="button" id="SelectItems" title="Select All Items" class="button recommended">Select All Items</button>
              <button type="button" id="UnselectItems" title="Unselect All Items" class="button recommended" style="display:none;">Un Select All Items</button>
            </td>
            <td>
              <button type="button" id="IdealPriceUpdate" title="Ideal Price Update" class="button">Set to Ideal Price Plus</button>
              <input type="text" size="2" name="IdealPricePlus" id="IdealPricePlus" value="0">%
            </td>
          </tr>
        </table>
      </td>
      <td style="width:33%">
        <input type="checkbox" name="LowerThanIdeal" id="LowerThanIdeal" value="1" <cfif url.Lower_Than_Ideal>Checked</cfif>>Show only lower than Ideal
      </td>
      <td style="width:33%">
        <cfif getProgramInfo.Contract_Status_Type_IDX LTE 2>
        <button type="button" id="Save" title="Save Ideal Price" class="button recommended">Save</button>
        </cfif>
        <button type="button" id="Reset" title="Reset Ideal Price" class="button">Reset</button>
        <button type="button" id="Download" title="Download Ideal Price" class="button">Download</button>
        <button type="button" id="Margins" title="Back To Margins" class="button">View Margins</button>
      </td>
    </tr>
  </table>
  <!--- 114617 :: Ideal Price END --->
</cfif>
</cfoutput>

<link rel="stylesheet" type="text/css" href="/styles/table.css">

<style>
    #tbl-container22 {
        height: calc(100vh - 255px);
        min-height: calc(100vh - 255px);
        max-height: calc(100vh - 255px);
        overflow-y: auto;
    }
    .datagrid td {
      height: 18px !important;
    }
    .datagrid tbody td.colspan100 {
      padding-left: 9px;
    }
    img.small_help {
      padding: 0 4px;
      position: relative;
      top: 2px;
    }
</style>

<div id="tbl-container22">
  <table class="datagrid" cellpadding="0" cellspacing="0" width="100%" id="GridView1">
   <tr>
    <cfset tdLen = 0 />
  <!---   check if they can see the base view --->
    <cfif Get_Profile_Settings.Base_View eq 1>
      <th valign="middle" width="150" class="header forceLeft 2590"> <cfset th_count++> <B>Description</B></TH>
      <cfset tdLen = tdLen + 1 />
  <!--- 114617 :: Ideal Price START --->
    <cfif getProgramInfo.Ideal_Price>
      <th valign="middle" width="150" class="header 2590" > <cfset th_count++> <B>Ideal Price</B></TH>
    </cfif>
    <cfset tdLen = tdLen + 1 />
    <!--- 114617 :: Ideal Price END --->


    <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
      <cfif variables.bDisplayContractPrice>
      <!--- 16314 [begin] --->
          <th class="header" valign="middle" class="verticalBorders padRight 2595" style="padding-top:2;" nowrap> <cfset th_count++>
            <!--- default to "Fixed Price" --->
              <span style="cursor:help;">
                  <b><cfoutput><cfif len(trim(appsettings.getMarginColHeader15()))>#replace(appsettings.getMarginColHeader15()," ","<br />","All")#<cfelse>Fixed Price</cfif></cfoutput></b>
          <IMG SRC="/Images/i.gif"  onmouseover="initTheTooltip('The value represents the fixed price offered on the program for this item.')" onmouseout="popOut()" />
              </span>
          </TH>
          <cfset tdLen = tdLen + 1 />
          <!--- 16314 [end] --->
      </cfif>
      <!--- 17289 > 16314 follow up 10/14/08 [end] --->
  <!--- 114617 :: Ideal Price START --->
  <cfif getProgramInfo.Ideal_Price>
    <th valign="middle" class="header">
      Diff
      <cfset tdLen = tdLen + 1>
    </th>
    <th valign="middle" class="header">
      Dollars
      <cfset tdLen = tdLen + 1>
    </th>
  </cfif>
  <!--- 114617 :: Ideal Price END --->
      <!--- The reason why we have "z-index:1" for multiple cells below is so that the content of <smallhelp> above can be fully be above these cells.
      Without using z-index,the contents of <smallhelp> gets hidden behind these cells.
      --->
       <th class="header 2610" valign="middle" style="z-index:1"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader1()," ","<br />","All")#</cfoutput></B></TH>
    <cfset tdLen = tdLen + 1 />

    <!--- Base Sales --->
        <th class="header 2614" valign="middle" style="z-index:1"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader2()," ","<br />","All")#</cfoutput></B>
      <cfif appSettings.getUseFixedPriceType()><br><cfoutput>
            <!--- Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  START
                  What  I did: added ListLast to display numbers after "_"--->
            (<!---#getProgramInfo.Price_List_ID#--->
              #ListLast(getProgramInfo.price_list_id, "_")#
              <!--- End Dev Note: drachala; D28453: When displaying price bracket do not display the price list id  --->
              <cfif getProgramInfo.priceBracket_Update eq 1><sup class="overriddenShow">*</sup></cfif>)</cfoutput></cfif>
      </TH>
    <cfset tdLen = tdLen + 1 />
    <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
    <!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
    <cfif appsettings.getDisplayCashDiscountMargin() eq 1 >
      <cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
          <th class="header 2828" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader3()," ","<br />","All")#</cfoutput></B></TH>
        <cfset tdLen = tdLen + 1 />
      </cfif>
      <cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
          <th class="header 2632" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader4()," ","<br />","All")#</cfoutput></B></TH>
        <cfset tdLen = tdLen + 1 />
      </cfif>
    </cfif>
    <!--- allowance --->
    <cfif direct_pricing eq 0>
        <th class="header 2638" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader5()," ","<br />","All")#</cfoutput></B>
      <cfif appSettings.getApprovalMarginType() eq 2>
      <img src="/Images/i.gif" title="The spending rates expressed represent the annualized values for this program as well as other concurrent programs. For example, a rebate of $1.00 per case offered for 6 months will contribute $0.50 per case on an annual basis.">
      </cfif>
      </TH>
      <cfset tdLen = tdLen + 1 />
    <!--- Allow % --->
        <th class="header 2645" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader23()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    </cfif>
    <CFIF ShowTPA eq 1>
      <th class="header 2649" valign="middle" > <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader6()," ","<br />","All")#</cfoutput></B>
      <cfif appSettings.getApprovalMarginType() eq 2>
      <img src="/Images/i.gif" title="The spending rates expressed represent the annualized values for this program as well as other concurrent programs. For example, a rebate of $1.00 per case offered for 6 months will contribute $0.50 per case on an annual basis.">
      </cfif>
      </TH>
      <cfset tdLen = tdLen + 1 />
    </CFIF>
    <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
      <th class="header 2657" valign="middle" > <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader7()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    </cfif>
    <!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
    <cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
      <!--- net sales --->
        <th class="header 2663" valign="middle" > <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader8()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    </cfif>
    </cfif>
    <!---   check if they can see the cost --->
    <cfif Get_Profile_Settings.View_Cost eq 1>
      <th class="header 2669" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader9()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    </cfif>
      <!---   check if they can see the brokerage --->
    <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
      <th class="header 2674" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader10()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    </cfif>
    <!---   check if they can see the Operating_Income --->
    <cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
     <th class="header 2679" valign="middle" > <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader11()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    </cfif>
     <!---   check if they can see the Target_Margins --->
    <cfif Get_Profile_Settings.View_Target_Margins eq 1>
    <cfif appSettings.getApprovalMarginType() eq 2><!--- Approval = Annual Case Rate --->
    <!--- Annual Case Rate --->
    <th class="header 2686" valign="middle" align="left"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader18()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    <!--- Target Case Rate --->
    <th class="header 2689 csvExclude"> <cfset th_count++> &nbsp;</th>
      <cfset tdLen = tdLen + 1 />
      <th class="header 2691" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader19()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    <cfelse>
    <!--- Operating Margin Percent --->
    <cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
    <th class="header 2696" valign="middle" align="left"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader12()," ","<br />","All")#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    </cfif>
     <!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START --->
  <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
      <th class="header 2701" valign="middle" align="left"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader24()," ","<br />","All")#</cfoutput></B></TH>
        <cfset tdLen = tdLen + 1 />
      <th class="header 2703" valign="middle" align="left"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader25()," ","<br />","All")#</cfoutput></B></TH>
        <cfset tdLen = tdLen + 1 />
    </cfif>
     <!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
    <!--- margin target --->
    <th class="header 2708 csvExclude"> <cfset th_count++> <cfoutput> #img_1010# </cfoutput> </th>
      <cfset tdLen = tdLen + 1 />
      <th class="header 2710" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader13()," ","<br />","All")# #UOMdisplay#</cfoutput></B></TH>
      <cfset tdLen = tdLen + 1 />
    </cfif>
    </cfif>

    <cfif appSettings.getApprovalMarginType() eq 1>
      <TH align="center 2716" ID="header" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader16()," ","<br />","All")#</cfoutput></B></TH>
        <cfset tdLen = tdLen + 1 />
    </cfif>
    <!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
    <cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>
      <TH class="2721" align="center" ID="header" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader17()," ","<br />","All")#</cfoutput></B></TH>
        <cfset tdLen = tdLen + 1 />
    </cfif>
    <!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
    <cfif Get_Profile_Settings.Base_View eq 1>
      <TH class="2726" align="center" ID="header" valign="middle"> <cfset th_count++> <B><cfoutput>#Replace(appsettings.getMarginColHeader14()," ","<br />","All")#</cfoutput></B></TH>
        <cfset tdLen = tdLen + 1 />
    </cfif>

    <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
      <th class="header 2731 csvExclude" valign="middle"> <cfset th_count++> <input type="checkbox" value="1" name="checkall" ONCLICK="selectAll()" checked></TH>
      <th class="header 2732" valign="middle"> <cfset th_count++> <B>Approve/ Agree</B></TH>
      <th class="header 2733 csvExclude"> <cfset th_count++> &nbsp;</th>
      <th class="header 2734 csvExclude"> <cfset th_count++> &nbsp;</th>
    <cfelse>
        <th class="header 2736 csvExclude"> <cfset th_count++> &nbsp;</th>
        <th class="header 2737 csvExclude"> <cfset th_count++> &nbsp;</th>
    </cfif>
  </TR>

    <cfset count = 0>
    <cfset OuterLoopcount = 1>
    <CFQUERY NAME="getProductMarginCount" DBTYPE="query">
      SELECT COUNT(*) As ProductMarginCount
      FROM getAllProductMargins
      GROUP BY Type_Code_Desc_ID
    </CFQUERY>
    <cfset ProductMarginCount = getProductMarginCount.Recordcount>
    <cfif appSettings.getMarginItemsExclude()>
      <CFQUERY NAME="getExcludedProductMarginCount" DBTYPE="query">
        SELECT COUNT(*) As ExcludedProductMarginCount
        FROM getAllExcludedProductMargins
        GROUP BY Type_Code_Desc_ID
      </CFQUERY>
      <cfset ExcludedProductMarginCount = getExcludedProductMarginCount.Recordcount>
    </cfif>

  <!--- Dev Note: KAL; 9/13/2010; D23601: Margin display for regualar items --->
  <!--------------------------------------------------------------------------->
  <!--- Products main loop group by type code - start ------------------------->
  <!--------------------------------------------------------------------------->
    <cfset TotalDiffDollar = 0>
    <cfset itemCount = 0>
  <CFOUTPUT query="getAllProductMargins" group="Type_Code_Desc_ID">

    <!--- mass approve --->
    <cfset itemCheckBoxDisabled = 0 />

    <cfset useLakebaseForgetGroupvalues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getallgroupmargins")>
<cfif useLakebaseForgetGroupvalues>
	<cftry>
		<cfset getGroupvalues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getallgroupmargins", {
				"type_code_desc_id" = "eq.#getAllProductMargins.Type_Code_Desc_Id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGroupvalues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGroupvalues>
<CFQUERY name="getGroupvalues" dbtype="query">
      select * from getAllGroupMargins
      where Type_Code_Desc_Id = '#getAllProductMargins.Type_Code_Desc_Id#'
    </CFQUERY>
</cfif>
    <!--- add variation to group margin --->
    <cfif trim(getGroupvalues.Group_ID_Margin) eq "">
      <cfset getGroupvalues.Group_ID_Margin = 0>
    </cfif>

    <cfif trim(getGroupvalues.Group_ID_Margin) NEQ "*" and trim(getGroupvalues.Group_ID_Margin) NEQ "">
      <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
      <cfif appSettings.getApprovalMarginType() eq 1>
        <cfset groupapprovalmargin = Target_Margin + ((Target_Margin * getGroupvalues.Group_ID_Margin)/100)>
      <cfelse>
        <cfset groupapprovalmargin = Target_Margin - ((ABS(Target_Margin) * getGroupvalues.Group_ID_Margin)/100)>
      </cfif>
    <cfelse>
      <cfset groupapprovalmargin = "*">
    </cfif>

    <cfset groupTargetCaseRateUOM = Target_Case_Rate_UOM />
    <cfset groupTargetCaseRate = Target_Case_Rate />
    <cfset groupTargetLBRate = Target_LB_Rate />

    <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
    <cfif appSettings.getApprovalMarginType() eq 1>
      <!--- check if the group margin is within limits, if not they cannot approve items either --->
      <cfif getGroupvalues.Total_Trade_Percent GT groupapprovalmargin  AND Trim(getGroupvalues.Group_ID_Margin) NEQ "*">
        <cfset CannotApproveGroupMargin = 1>
        <cfset CannotApproveItemMargin = 1>
        <cfif getGroupvalues.Group_ID_Approval eq 1>
          <cfset itemmarginfailure = 1>
          <cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Type_Code_Desc#.")>
        </cfif>
      </cfif>
    <cfelseif appSettings.getApprovalMarginType() eq 0>
      <!--- check if the group margin is within limits, if not they cannot approve items either --->
      <cfif getGroupvalues.Total_OperatingMargin_percent LT groupapprovalmargin  AND Trim(getGroupvalues.Group_ID_Margin) NEQ "*">
        <cfset CannotApproveGroupMargin = 1>
        <cfset CannotApproveItemMargin = 1>
        <cfif getGroupvalues.Group_ID_Approval eq 1>
          <cfset itemmarginfailure = 1>
          <cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Type_Code_Desc#.")>
        </cfif>
      </cfif>
    <cfelseif appSettings.getApprovalMarginType() eq 2 AND Get_Profile_Settings.Approve_Beyond_Annual_Case_Rate eq 0>
      <cfif groupTargetCaseRateUOM eq 1 AND getGroupvalues.Total_Trade_CS GT groupTargetCaseRate>
        <cfset CannotApproveGroupMargin = 1>
        <cfset CannotApproveItemMargin = 1>
        <cfif getGroupvalues.Group_ID_Approval eq 1>
          <cfset itemmarginfailure = 1>
          <cfset temp = ArrayAppend(messageArray, "Annual case rate is not within the target for #Type_Code_Desc#.")>
        </cfif>
      <cfelseif groupTargetCaseRateUOM eq 2 AND getGroupvalues.Total_Trade_LB GT groupTargetLBRate>
        <cfset CannotApproveGroupMargin = 1>
        <cfset CannotApproveItemMargin = 1>
        <cfif getGroupvalues.Group_ID_Approval eq 1>
          <cfset itemmarginfailure = 1>
          <cfset temp = ArrayAppend(messageArray, "Annual pound rate is not within the target for #Type_Code_Desc#.")>
        </cfif>
      </cfif>
    <!--- 70104 Absolute Net Sales $ per Lb or Equiv Case --->
    <cfelseif appSettings.getApprovalMarginType() eq 3>
      <cfif getGroupvalues.Global_Total_Margin GT groupapprovalmargin  AND Trim(getGroupvalues.Group_ID_Margin) NEQ "*">
        <cfset CannotApproveGroupMargin = 1>
        <cfset CannotApproveItemMargin = 1>
        <cfif getGroupvalues.Group_ID_Approval eq 1>
          <cfset itemmarginfailure = 1>
          <cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Type_Code_Desc#.")>
        </cfif>
      </cfif>
    </cfif>

<!--- 72497 :: Program Approval - Annual Volume and % of List Price START--->
    <cfset groupApprovalMarginListPrice = 0 />
    <cfif trim(getGroupvalues.Group_ID_List_Price) NEQ "*" and trim(getGroupvalues.Group_ID_List_Price) NEQ "">
        <cfset groupApprovalMarginListPrice = Target_Margin_ListPrice + ((Target_Margin_ListPrice * getGroupvalues.Group_ID_List_Price)/100) />
    <cfelse>
      <cfset groupApprovalMarginListPrice = "*">
    </cfif>

    <cfset Total_Allowance_Percent = 100 />
    <cfif appSettings.getApprovalMarginType() eq 2>
      <cfset Total_Item_Allowance_Display_Value = getGroupvalues.Total_Item_Allowance_Annualized />
    <cfelse>
      <cfset Total_Item_Allowance_Display_Value = getGroupvalues.Total_Item_Allowance />
    </cfif>

    <cfif Total_Item_Allowance_Display_Value eq 0 OR getGroupvalues.Total_Base_Sales eq 0>
      <cfset Total_Allowance_Percent = 100 />
    <cfelseif Total_Item_Allowance_Display_Value LT 0>
      <cfset Total_Allowance_Percent = 0 />
    <cfelse>
        <cfset Total_Allowance_Percent = (Total_Item_Allowance_Display_Value/getGroupvalues.Total_Base_Sales) * 100>
    </cfif>

    <cfif Total_Allowance_Percent GT groupApprovalMarginListPrice  AND Trim(getGroupvalues.Group_ID_List_Price) NEQ "*">
        <cfset CannotApproveGroupMargin = 1>
        <cfset CannotApproveItemMargin = 1>
       <cfif getGroupvalues.Group_ID_Approval eq 1>
          <cfset itemmarginfailure = 1>
          <cfset temp = ArrayAppend(messageArray, "Discount % is not within your limits for #Type_Code_Desc#.")>
        </cfif>
    </cfif>
<!--- 72497 :: Program Approval - Annual Volume and % of List Price END --->

    <CFIF getGroupvalues.Group_ID_Approval eq 0>
      <cfset CannotApproveGroupMargin = 1>
      <cfset disablecheckbox = "disabled">
      <cfset itemCheckBoxDisabled = 1 />
      <cfset temp = ArrayAppend(messageArray, "You cannot approve #Type_Code_Desc#")>
      <cfset grouptrbgcolor = "##d3d3d3">
      <cfset itemtrbgcolor ="##d3d3d3">
      <cfset form.RestrictedList = listAppend(form.RestrictedList,BSA_Foodservice_Items_Master_Id ) >
    </CFIF>

    <!------------------------------------------------------------------------------------------------------------------->
    <!--- Begin: Outputs the individual items  -------------------------------------------------------------------------->
    <!------------------------------------------------------------------------------------------------------------------->
    <cfoutput>
      <cfif getGroupvalues.Group_ID_Approval eq 0>
        <cfset CannotApproveItemMargin = 1>
      </cfif>

      <!--- check if the group margin is within limits, if not they cannot approve items either --->
      <cfif (appSettings.getApprovalMarginType() eq 0) AND (getGroupvalues.Total_OperatingMargin_percent LT groupapprovalmargin)  AND (Trim(getGroupvalues.Group_ID_Margin) NEQ "*")>
        <cfset CannotApproveItemMargin = 1>
      <cfelseif (appSettings.getApprovalMarginType() eq 1) AND (getGroupvalues.Total_Trade_Percent GT groupapprovalmargin)  AND (Trim(getGroupvalues.Group_ID_Margin) NEQ "*")>
        <cfset CannotApproveItemMargin = 1>
      <cfelseif appSettings.getApprovalMarginType() eq 2 AND Get_Profile_Settings.Approve_Beyond_Annual_Case_Rate eq 0>
        <cfif groupTargetCaseRateUOM eq 1 AND getGroupvalues.Total_Trade_CS GT groupTargetCaseRate>
          <cfset CannotApproveItemMargin = 1>
        <cfelseif groupTargetCaseRateUOM eq 2 AND getGroupvalues.Total_Trade_LB GT groupTargetLBRate>
          <cfset CannotApproveItemMargin = 1>
        </cfif>
      </cfif>

      <!--- Check if item is beyond ez max rate --->
      <cfif ListFind(lProductsBeyondMaxRateList, BSA_Foodservice_Items_Master_ID)>
        <cfset CannotApproveItemMargin = 1>
        <cfset CannotApproveGroupMargin = 1>
      </cfif>
      <cfset itemCount = itemCount + 1>
    <!--- check if the profile has rights to have base view --->
   <cfif Get_Profile_Settings.Base_View eq 1>
        <tr class="csv" BGCOLOR="#itemtrbgcolor#" valign="middle" bsaid="#BSA_Foodservice_Items_Master_ID#" tcid="#Type_Code_Desc_ID#" id="#Type_Code_Desc_ID#_#itemCount#">  <!--- 34662 --->
      <td width="150" class="forceLeft ln_2915">
    <!--- Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  START
      Added/Changed: Added IF condition to toggle display--->
      <!--- 114617 :: Ideal Price START --->
      <cfif url.idealPriceAnalysis>
            <input type="checkbox" class ="BSAID_Single csvExclude" name="#BSA_Foodservice_Items_Master_ID#" id="#BSA_Foodservice_Items_Master_ID#" value="1" TypeCode="#Type_Code_Desc_ID#">
      </cfif>
      <!--- 114617 :: Ideal Price END --->
  <cfif form.margin_type eq 2>
  <span style="cursor:pointer;" onmouseover="initTheTooltip('Stat Case Value:#trim(numberformat(CASE_EQUIVALENT,'_-___,___,___,___,___.___'))#')" onmouseout="popOut()">
    <cfif appSettings.getViewPgmSortBy()>
      #Description#<br>
      <cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>
        #upc#
      <cfelse>
        #Item#
      </cfif>
    <cfelse>
      <cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>
        #upc#
      <cfelse>
        #Item#
      </cfif>
      <br><cfif url.idealPriceAnalysis>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif>#Description#
    </cfif>
  </span>
  <cfelse>
    <cfif appSettings.getViewPgmSortBy()>
      #Description#<br>
      <cfif (appSettings.get_Setting('Display_Item_No') eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND application.returned_customer_setting.upc_switch EQ 1>
        #upc#
      <cfelse>
        #Item#
      </cfif>
    <cfelse>
      <cfif (appSettings.get_Setting('Display_Item_No') eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND application.returned_customer_setting.upc_switch EQ 1>
        #upc#
      <cfelse>
        #Item#
      </cfif>
      <br><cfif url.idealPriceAnalysis>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif>#Description#
    </cfif>
  </cfif>
<!--- End Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  --->
</td>
        <!--- 114617 :: Ideal Price START --->
        <cfif getProgramInfo.Ideal_Price>
          <td valign="middle" class="header" id="prodid_#getAllProductMargins.Product_ID#" IdealPrice=#Ideal_Price#>
            #application.util.string.cellFormat(value=Ideal_Price ,decimalplaces = request.dollar_format)#
          </td>
        </cfif>
        <!--- 114617 :: Ideal Price END --->
      <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
      <cfif variables.bDisplayContractPrice>

      <!--- 16314 [begin] style="border-left: 1px black;" --->
      <!------------------------->
      <!--- 001 - Fixed Price --->
      <!------------------------->
          <td class="verticalBorders padRight ln_2935" align="right" nowrap>
              <cfsilent>
                  <!---
                  form.margin_type
                  variables.Program_ID
                  variables.getAllProductMargins.Product_ID
                  --->
                  <cfif form.margin_type eq 2>
                      <cfquery name="qGetStatValue" datasource="#application.datasource#">
                          SELECT ISNULL(CAST(CASE_EQUIVALENT as float),0) as CASE_EQUIVALENT
                          FROM BSA_Foodservice_Items_Master
                          where BSA_Foodservice_Items_Master_ID = '#variables.getAllProductMargins.Product_ID#'
                      </cfquery>
                      <cfset statMultiplier = qGetStatValue.CASE_EQUIVALENT>
                      <cfif NOT statMultiplier>
                          <cfset multiplier = "*">
                      <cfelse>
                          <cfset multiplier = "/">
                      </cfif>
                  <cfelseif form.margin_type eq 3>
                      <cfquery name="qGetNetValue" datasource="#application.datasource#">
                          SELECT ISNULL(CAST(NET_WEIGHT as float),0) as NET_WEIGHT
                          FROM BSA_Foodservice_Items_Master
                          where BSA_Foodservice_Items_Master_ID = '#variables.getAllProductMargins.Product_ID#'
                      </cfquery>
                      <cfif NOT qGetNetValue.NET_WEIGHT>
                          <cfset Net = 1>
                      <cfelse>
                          <cfset Net = qGetNetValue.NET_WEIGHT[1]>
                      </cfif>
                      <cfset statMultiplier = Net>
                      <cfset multiplier = "/">
                  <cfelseif form.margin_type eq 4>
                      <cfquery name="qGetVolume" datasource="#application.datasource#">
                          SELECT ISNULL(Product_Program_Volume_CS,0) as Volume_Equivalent
                          FROM contract_product_margin
                          where product_id = '#variables.getAllProductMargins.Product_ID#'
                          and deleted = 0
                          and contract_main_id = '#contract_main_id#'
                      </cfquery>
                      <cfset statMultiplier = qGetVolume.Volume_Equivalent>
                      <cfset multiplier = "*">
                  <cfelse>
                      <cfset statMultiplier = 1>
                      <cfset multiplier = "*">
                  </cfif>
                  <cfquery name="qGetContractPrice" datasource="#application.datasource#">
          SELECT ISNULL(FPR_CS,0) as Fixed_Price_CS, FPR_CS , FPR_LB, FPR_STAT
                      FROM        dbo.Contract_Product_Margin
                      INNER JOIN BSA_Foodservice_Items_Master
                      ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Contract_Product_Margin.Product_Id
                      --AND BSA_Foodservice_Items_Master.deleted = 0
                      LEFT JOIN Type_Group_Desc
                      ON Type_Group_Desc.Type_Group_Desc_ID = BSA_Foodservice_Items_Master.Type_Group_Desc_ID
                      AND Type_Group_Desc.deleted = 0
                      LEFT JOIN Group_Approval_Rights
                      ON Group_Approval_Rights.Group_ID = Type_Group_Desc.Type_Group_Desc_ID
                      AND Group_Approval_Rights.User_Profile_ID = #request.Accessstructure.Profiles_ID#
                      AND Group_Approval_Rights.deleted = 0
                      WHERE Contract_Main_ID = #contract_main_id#
                      AND Contract_Product_Margin.product_id = '#getAllProductMargins.Product_ID#'
                  </cfquery>
          <cfif (isDefined("qGetContractPrice.Fixed_Price_CS") and qGetContractPrice.Fixed_Price_CS NEQ "")>
                    <cfset fixed_price = "#qGetContractPrice.Fixed_Price_CS##multiplier##statMultiplier#">
                    <cfset fixed_price = evaluate(fixed_price) />
          <cfelse>
            <cfset fixed_price = 0 />
          </cfif>

                  <!--- do we have more than 1 fixed component for this program ? [begin] --->
                  <cfquery name="qGetFixedComponentIDs" datasource="#application.datasource#">
                      SELECT  Program_Fixed_Component_ID
                      FROM  Program_Fixed_Component
                      WHERE   Program_ID = #contract_main_id#
                      AND   deleted = 0
                  </cfquery>
                  <!--- do we have more than 1 fixed component for this program ? [end] --->
              </cfsilent>
          <!--- D17218 [begin]
          <span onmouseover="initTheTooltip('The value represents the fixed price offered on the program for this item.')" onmouseout="popOut()" style="cursor:help;>
          D17218 [end] --->
  <cfif url.idealPriceAnalysis>
    <input type="text" name="#getAllProductMargins.Product_ID#_Fixed_Price" id="#getAllProductMargins.Product_ID#_Fixed_Price" value="#fixed_price#" size="5" ONKEYUP="IdealPriceCalculation('0', '#getAllProductMargins.Product_ID#', '#getAllProductMargins.Type_Code_Desc_ID#')">
    <input type="hidden" name="#getAllProductMargins.Product_ID#_Fixed_Price_Change" id="#getAllProductMargins.Product_ID#_Fixed_Price_Change" value="0">
  <cfelse>
    #application.util.string.cellFormat(value=fixed_price ,decimalplaces = request.dollar_format)#
    <cfif qGetFixedComponentIDs.recordCount GT 1> <span class="redLarge">*</span></cfif>
  </cfif>
</td>
          <!--- 16314 [end] --->

      </cfif>
      <!--- 17289 > 16314 follow up 10/14/08 [end] --->
  <!--- 114617 :: Ideal Price START --->
  <cfif getProgramInfo.Ideal_Price>
    <td valign="right" class="header">
      <cfif fixed_price GT Ideal_Price>
        <cfset IPRateDiff = '0'>
        <cfset IPRateDiffPer = '0'>
      <cfelse>
        <cfset 	IPRateDiff = Ideal_Price - fixed_price>
                <cfif Ideal_Price>
                  <cfset 	IPRateDiffPer = (100 * IPRateDiff)/Ideal_Price >
                <cfelse>
                  <cfset 	IPRateDiffPer = 0 >
                </cfif>
      </cfif>
        #application.util.string.cellFormat(value=IPRateDiff ,decimalplaces = request.dollar_format)#<br>
        #numberformat(IPRateDiffPer)#%
    </td>
    <td valign="right" class="header">
      <cfif fixed_price GT Ideal_Price>
        <cfset DiffDollar = '0'>
      <cfelse>
        <cfset DiffDollar = (fixed_price - Ideal_Price) * Product_Program_Volume>
        <cfset TotalDiffDollar = TotalDiffDollar + DiffDollar>
      </cfif>
      #application.util.string.cellFormat(value=DiffDollar ,decimalplaces = request.dollar_format)#
    </td>
  </cfif>
  <!--- 114617 :: Ideal Price END --->
    <!--------------------->
    <!--- 002 - Vol. CS --->
    <!--------------------->
    <td align="right" nowrap  class="ln_3026" id="#Product_Id#_Volume" volume=#Product_Program_Volume#>#trim(numberformat(round(Product_Program_Volume),'_-___,___,___,___,___'))# </td>
    <!------------------------>
    <!--- 003 - Base Sales --->
    <!------------------------>
    <td align="right" nowrap  class="ln_3030">
      <a STYLE="cursor:pointer;" ONCLICK="showBaseSalesDetails('#replace(Product_Id, "-", "_", "ALL")#')">
        #application.util.string.cellFormat(value=Base_Sales, decimalplaces = request.dollar_format)#
      </a>
    </td>

    <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
    <!--- Display Cash Discount only if the app setting is on. This setting is off when margin = trade percent of gross sales. --->
    <!--------------------->
    <!--- 004 Cash Disc --->
    <!--------------------->
    <cfif appsettings.getDisplayCashDiscountMargin() eq 1>
      <cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
        <td align="right" nowrap class="ln_3043">
          <cfif appsettings.getlocalcostvariables() eq 2>
          <A STYLE="cursor:pointer;" ONCLICK="showCashDiscountDetails('#replace(Product_Id, "-", "_", "ALL")#')">
          </cfif>
          #application.util.string.cellFormat(value=Cash_discount, decimalplaces = request.dollar_format)#
          <cfif appsettings.getlocalcostvariables() eq 2>
          </a>
          </cfif>
        </td>
      </cfif>

      <cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
        <td align="right" nowrap class="ln_3055">
          <A STYLE="cursor:pointer;" ONCLICK="showLocalCostCalculation('#replace(Product_Id, "-", "_", "ALL")#','L','')">
            #application.util.string.cellFormat(value=Cash_discount,decimalplaces = request.dollar_format)#
          </A>
        </td>
      </cfif>
    </cfif>

    <!------------------------------>
    <!--- 005 - Allowance column --->
    <!------------------------------>
    <cfif direct_pricing eq 0>
      <td align="right" nowrap class="ln_3067" id="#Product_Id#_Allowance" typecode=#Type_Code_Desc_ID# RER= #RER# GRR= #GRR# OER= #OER# DiffFormulaPrice= #Diff_Formula_Price# BaseSales=#Base_Sales# NetSales=#Net_Sales# ItemAllowance=#Item_Allowance# LumpsumAmount=#Lumpsum_Amount# AnnualizedAllowance=#AnnualizedAllowance# ItemAllowance=#ItemAllowance#>
        <!--- D56447 :: EZ Rates Indicator inside a Program START --->
        <cfset EZrateIndicator = 0>
        <cfif getsettings.EZButton_On EQ 1 AND ListFind(ProductsBeyoundMaxRateList, variables.getAllProductMargins.Product_ID)>
        <cfset ezrate = listgetat(ProductsMaxRateList, ListFind(ProductsBeyoundMaxRateList, variables.getAllProductMargins.Product_ID))>
        <cfset EZrateIndicator = 1>
      </cfif>
     <!--- D56447 :: EZ Rates Indicator inside a Program END --->
        <A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','A','')">
        <cfif appSettings.getApprovalMarginType() eq 2>
          <cfset Allowance_Display_Value = Item_Allowance_Annualized />
        <cfelse>
          <cfset Allowance_Display_Value = Item_Allowance />
        </cfif>
  <cfif url.idealPriceAnalysis>
    #trim(application.util.string.cellFormat(value=Allowance_Display_Value ,decimalplaces = request.dollar_format))#
  <cfelse>
  <A style="cursor:pointer;" onclick="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','A','')">
  <cfif EZrateIndicator>
    <b title="Item Rate above EZ rate. EZ Rate = $#ezrate#" style="font-size:12px;color:red;font-weight:bold;cursor:pointer;" align="absmiddle">( ! )</b>
  </cfif> #trim(application.util.string.cellFormat(value=Allowance_Display_Value ,decimalplaces = request.dollar_format))#
  </A>
  </cfif>
      </td>
      <!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
      <!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Allowance_Display_Value".
      I could have used IsDefined("Allowance_Display_Value") to show or hide this column, but it was simpler to just rely on the logic for "Allowance_Display_Value",
      as the below calculated value relies on ""Allowance_Display_Value".
      --->
      <!--------------------->
      <!--- 006 - allow % --->
      <!--------------------->
      <td align="right" nowrap class="ln_3092" id="#Product_Id#_Allowance_Percentage">
        <cfif Allowance_Display_Value eq 0 OR Base_Sales eq 0>
          N/A
    <cfset Allowance_Percent = 0>
        <cfelseif Allowance_Display_Value LT 0>
          0%
    <cfset Allowance_Percent = 0>
        <cfelse>
        <cfset Allowance_Percent = (Allowance_Display_Value/Base_Sales) * 100>
          #application.util.string.cellFormat(value=Allowance_Percent,decimalplaces = request.numeric_format)#%
        </cfif>
      </td>
    </cfif>

    <!----------------->
    <!--- 007 - TPA --->
    <!----------------->
    <CFIF ShowTPA eq 1>
    <td align="right" nowrap class="ln_3108">
      <A STYLE="cursor:pointer;" ONCLICK="showTradeCalculation('#replace(Product_Id, "-", "_", "ALL")#')">
        #application.util.string.cellFormat(value=TPA,decimalplaces = request.dollar_format)#
      </A>
    </td>
    </CFIF>

    <!----------------------------->
    <!--- 008 - pullback amount --->
    <!----------------------------->
     <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
    <td align="right" nowrap class="ln_3119">
      <A STYLE="cursor:pointer;" ONCLICK="showPullbackCalculation('#replace(Product_Id, "-", "_", "ALL")#')">
        #application.util.string.cellFormat(value=Pullbackamount,decimalplaces = request.dollar_format)#
      </A>
    </td>
    </cfif>

    <!----------------------->
    <!--- 009 - net sales --->
    <!----------------------->
    <!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
    <cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
    <td align="right" nowrap class="ln_3131" id="#Product_Id#_Net_Sales" BaseSales=#Base_Sales# BaseDiscount=#Base_Discount# TPAOper=#TPA_Oper# TPA=#TPA# PullbackAmount=#PullbackAmount# AllowanceSurcharges=#Allowance_Surcharges# CustomerFreight=#Customer_Freight#  OtherSpend=#Other_Spend#>
  <cfif url.idealPriceAnalysis>
    #application.util.string.cellFormat(value=Net_Sales ,decimalplaces = request.dollar_format)#
  <cfelse>
    <A style="cursor:pointer;" onclick="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','N','')">
      #application.util.string.cellFormat(value=Net_Sales ,decimalplaces = request.dollar_format)#
    </A>
  </cfif>
    </td>
    </cfif>
  </cfif>

  <!--- Dev Note: KAL; D21003: Margin Approval - Trade as Percent of Gross Sales, $0 price  --->
  <cfif Base_Sales eq 0 and Get_Profile_Settings.Approve_Zero_Product_Price eq 0>
    <cfset CannotApproveItemMargin = 1>
    <cfset CannotApproveGroupMargin = 1>
    <cfset temp = ArrayAppend(messageArray, "You cannot approve #Description# #Item# which has zero price.")>
  </cfif>

  <cfif Cost eq 0 and Get_Profile_Settings.Approve_Zero_Product_Cost eq 0>
    <cfset CannotApproveItemMargin = 1>
    <cfset CannotApproveGroupMargin = 1>
    <cfset temp = ArrayAppend(messageArray, "You cannot approve #Description# #Item# which has zero cost.")>
  </cfif>

  <!------------------>
  <!--- 010 - cost --->
  <!------------------>
  <cfif Get_Profile_Settings.View_Cost eq 1>
    <td align="right" nowrap class="ln_3156">
      <A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','C','')">
      #application.util.string.cellFormat(value=Cost,decimalplaces = request.dollar_format)#
      </A>
    </td>
  </cfif>

  <!----------------------->
  <!--- 011 - Brokerage --->
  <!----------------------->
  <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
    <td align="right" nowrap class="ln_3167">
      <A STYLE="cursor:pointer;" ONCLICK="showBrokerage('#replace(Product_Id, "-", "_", "ALL")#')">
        #application.util.string.cellFormat(value=Broker_Cost,decimalplaces = request.dollar_format)#
      </A>
    </td>
  </cfif>

  <!------------------------------>
  <!--- 012 - operating income --->
  <!------------------------------>
  <cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
    <td align="right" nowrap class="ln_3178" id="#Product_Id#_Operating_Income" MapMdf=#Map_Mdf# SGA=#SGA#>
        #application.util.string.cellFormat(value=Operating_Income,decimalplaces = request.dollar_format)#
        <!---Tim Ford - Label 19381: Show if the Program is a revision and Operating Income is different from Revised program--->
        <cfif Program_Is_A_Revision and isDefined("getProductPreviousVersionMargins")>
          <cfset useLakebaseForqGetPreviousOperatingIncome = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getproductpreviousversionmargins")>
<cfif useLakebaseForqGetPreviousOperatingIncome>
	<cftry>
		<cfset qGetPreviousOperatingIncome = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getproductpreviousversionmargins", {
				"product_id" = "eq.#Product_ID#",
				"select" = "operating_income,operatingmargin_percent"
			}), "operating_income,operatingmargin_percent"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetPreviousOperatingIncome = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetPreviousOperatingIncome>
<cfquery name="qGetPreviousOperatingIncome" dbtype="query">
            SELECT  Operating_Income, OperatingMargin_percent
            FROM  getProductPreviousVersionMargins
            WHERE Product_ID = '#Product_ID#'
          </cfquery>
</cfif>
          <cfif qGetPreviousOperatingIncome.RecordCount>
            <cfif DecimalFormat(qGetPreviousOperatingIncome.Operating_Income) neq DecimalFormat(Operating_Income)>
        <i class="tooltip" title="Previous Version #trim(replace(replace(appsettings.getMarginColHeader11(),'%',''),'$',''))#: &nbsp; #UnitNumberFormat(qGetPreviousOperatingIncome.Operating_Income,form.Margin_Type)# &nbsp; #round(qGetPreviousOperatingIncome.OperatingMargin_percent)#%">&bigstar;</i>
            </cfif>
          </cfif>
        </cfif>
    </td>
  </cfif>

    <!--- check if the user profile has rights to view margins --->
    <!--- add item variation to the item --->
    <cfset margin = trim(numberformat(TargetMargin,'_-___,___,___,___,___._'))>
    <cfset variationmargin  = Get_Profile_Settings.Margin_Target_Variation>
    <cfif trim(variationmargin) NEQ "*">
      <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
      <cfif appSettings.getApprovalMarginType() eq 1>
          <cfset approvalmargin  = margin + ((margin * variationmargin)/100)>
      <cfelse>
          <cfset approvalmargin  = margin - ((margin * variationmargin)/100)>
      </cfif>
    <cfelse>
      <cfset approvalmargin  = "*">
    </cfif>

    <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
    <cfif appSettings.getApprovalMarginType() eq 1>
      <!--- If (margin = trade %) and App Setting (Margin Target on = OFF) ignore item level targets. --->
      <cfif appSettings.getuploadmargintargets_on()>
        <cfif Trade_Percent GT approvalmargin AND approvalmargin NEQ "*">
          <cfset CannotApproveItemMargin = 1>
          <cfset CannotApproveGroupMargin = 1>
          <cfif getGroupvalues.Group_ID_Approval eq 1>
            <cfset itemmarginfailure = 1>
          </cfif>
          <cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Description# #Item#.")>
        </cfif>
      </cfif>
    <cfelseif appSettings.getApprovalMarginType() eq 0>
      <cfif OperatingMargin_percent LT approvalmargin AND approvalmargin NEQ "*">
        <cfset CannotApproveItemMargin = 1>
        <cfset CannotApproveGroupMargin = 1>
        <cfif getGroupvalues.Group_ID_Approval eq 1>
          <cfset itemmarginfailure = 1>
        </cfif>
        <cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Description# #Item#.")>
      </cfif>
    <cfelseif appSettings.getApprovalMarginType() eq 2 AND Get_Profile_Settings.Approve_Beyond_Annual_Case_Rate eq 0>
        <cfif groupTargetCaseRateUOM eq 1 AND Trade_CS GT groupTargetCaseRate>
          <cfset CannotApproveItemMargin = 1>
          <cfset CannotApproveGroupMargin = 1>
          <cfif getGroupvalues.Group_ID_Approval eq 1>
            <cfset itemmarginfailure = 1>
          </cfif>
          <cfset temp = ArrayAppend(messageArray, "Annual case rate is not within the target for #Description# #Item#.")>
        <cfelseif groupTargetCaseRateUOM eq 2 AND Trade_LB GT groupTargetLBRate>
          <cfset CannotApproveItemMargin = 1>
          <cfset CannotApproveGroupMargin = 1>
          <cfif getGroupvalues.Group_ID_Approval eq 1>
            <cfset itemmarginfailure = 1>
          </cfif>
          <cfset temp = ArrayAppend(messageArray, "Annual pound rate is not within the target for #Description# #Item#.")>
        </cfif>
    <!--- 70104 Absolute Net Sales $ per Lb or Equiv Case --->
    <cfelseif appSettings.getApprovalMarginType() eq 3>
      <cfif Global_Net_Sales GT approvalmargin AND approvalmargin NEQ "*">
        <cfset CannotApproveItemMargin = 1>
        <cfset CannotApproveGroupMargin = 1>
        <cfif getGroupvalues.Group_ID_Approval eq 1>
          <cfset itemmarginfailure = 1>
        </cfif>
          <cfset temp = ArrayAppend(messageArray, "Margin is not within your limits for #Description# #Item#.")>
      </cfif>
    </cfif>

    <!------------------------------>
    <!--- 013 - operating margin --->
    <!------------------------------>
    <cfif Get_Profile_Settings.View_Target_Margins eq 1>
      <cfif appSettings.getApprovalMarginType() eq 2><!--- Annual Case Rate --->
        <!------------------------------->
        <!--- 013a - Annual Case Rate --->
        <!------------------------------->
        <td align="right" nowrap class="ln_3269">

            <!--- Dev Note: Drachala; D27335: Add UOM display to margin page for spend rate ADDED groupTargetCaseRateUOM--->
          #application.util.string.cellFormat(value=Trade, decimalplaces = request.dollar_format)#/<cfif groupTargetCaseRateUOM eq 1>CS<cfelseif groupTargetCaseRateUOM eq 2>LB</cfif>

        </td>
        <!------------>
        <!--- 013z --->
        <td  class="ln_3277">&nbsp;</td>

        <!------------------------------->
        <!--- 013b - Target Case Rate --->
        <!------------------------------->
        <td align="right" nowrap class="ln_3282">
          <cfif groupTargetCaseRateUOM eq 2>
            <cfset data = groupTargetLBRate />
          <cfelse>
            <cfset data = groupTargetCaseRate />
          </cfif>
            <!--- Dev Note: Drachala; D27335: Add UOM display to margin page for spend rate ADDED groupTargetCaseRateUOM--->
          #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format)#/<cfif groupTargetCaseRateUOM eq 1>CS<cfelseif groupTargetCaseRateUOM eq 2>LB</cfif>
          </td>
      <cfelse>
      <!--------------------------------------->
      <!--- 013m - Operating Margin Percent --->
      <!--------------------------------------->
          <cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
            <td align="right" nowrap class="ln_3296" id="#Product_Id#_Operating_Margin_percent">
              #(OperatingMargin_percent lt 0
                  ? NegativeFormat( numberFormat( OperatingMargin_percent * -1, ",.99" ) )
                  : numberformat( OperatingMargin_percent, ",.99" ))#%
            </td>
          </cfif>
<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START --->
<cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
  <td align="right" nowrap class="ln_3304">

          <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
            <cfset ContribMarginAmount = #Operating_Income# - #Fixed_Mfg_Cost#>
          <cfelse>
           <cfset ContribMarginAmount = #Operating_Income# + #Fixed_Mfg_Cost#>
          </cfif>

            #application.util.string.cellFormat(value=ContribMarginAmount,decimalplaces = request.dollar_format)#
  </td>
  <td align="right" nowrap class="ln_3314">
    <!--- Dev Note(63711): Since "Net_Sales" is a column name, it should be used as "variables.Net_Sales", if we need to override it by using
    a variable. Using <cfset Net_Sales = 1> will not override the "Net_Sales" variable.
    --->

    <cfif len(Net_Sales) EQ 0 OR Net_Sales EQ 0>
      <cfset variables.Net_Sales = 1>
    <cfelse>
      <cfset variables.Net_Sales = Net_Sales>
    </cfif>
            <cfset ContribMarginPer = (ContribMarginAmount / variables.Net_Sales) * 100>
           #application.util.string.cellFormat(value=ContribMarginPer,decimalplaces = request.numeric_format)#%
  </td>
</cfif>
<!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END --->
      <TD BGCOLOR="#itemtrbgcolor#" class="csvExclude ln_3329">
        <CFIF CannotApproveItemMargin eq 1>
          <IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle">
        <cfelse>
          #img_1010#
        </cfif>
      </TD>
      <!----------------------->
      <!--- 013n - margin % --->
      <!----------------------->
      <TD align="right" nowrap class="ln_3339">
        <cfif marginTagetEnabled and appSettings.getuploadmargintargets_on()>
          <A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Product_Id, "-", "_", "ALL")#','T','P')">

            <cfif approvalmargin eq "*">
                #application.util.string.cellFormat(value=margin, decimalplaces = request.numeric_format)#%
            <cfelse>
              #application.util.string.cellFormat(value=approvalmargin,decimalplaces = request.numeric_format)#%
            </cfif>

          </A>
        </cfif>
      </TD>
      </cfif>
      <CFIF CannotApproveItemMargin eq 1>
        <cfset form.AgreeList = ListAppend(form.AgreeList, BSA_Foodservice_Items_Master_Id) >
      <cfelse>
        <cfset form.ApproveList = ListAppend(form.ApproveList, BSA_Foodservice_Items_Master_Id)>
      </cfif>
    </cfif>

    <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
    <!---------------------->
    <!--- 014 - Trade CS --->
    <!---------------------->
    <cfif appSettings.getApprovalMarginType() eq 1>
      <td align="right" nowrap class="ln_3365">
        #application.util.string.cellFormat(value=Trade, decimalplaces = request.dollar_format)#
      </td>
    </cfif>
    <!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
    <!---------------------->
    <!--- 015 - trade %  --->
    <!---------------------->
    <cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>
      <td align="right" nowrap class="ln_3374">
        #application.util.string.cellFormat(value=Trade_Percent,decimalplaces = request.numeric_format)# #UOMdisplay#
      </td>
    </cfif>
    <!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
    <!------------------------->
    <!--- 016 - Trade Spent --->
    <!------------------------->
    <cfif Get_Profile_Settings.Base_View eq 1>
      <TD align="right" nowrap class="ln_3383" id="#Product_Id#_Trade_Spent" typecode=#Type_Code_Desc_ID#>
        <cfset tradespend = Item_Allowance * round(Product_Program_Volume)>
          #application.util.string.cellFormat(value=tradespend, decimalplaces = request.dollar_format)#
      </TD>
    </cfif>

      <cfif url.idealPriceAnalysis>
        <input type="hidden" name="#Product_Id#_Trade_Spent_TB" id="#Product_Id#_Trade_Spent_TB" value="#numberFormat(tradespend,request.nondollar_format)#">
        <input type="hidden" name="#Product_Id#_Operating_Margin_percent_TB" id="#Product_Id#_Operating_Margin_percent_TB" value="#numberFormat(OperatingMargin_percent,request.numeric_format)#">
        <input type="hidden" name="#Product_Id#_Operating_Income_TB" id="#Product_Id#_Operating_Income_TB" value="#numberFormat(Operating_Income,request.nondollar_format)#">
        <input type="hidden" name="#Product_Id#_Variable_Contribution_Margin_TB" id="#Product_Id#_Variable_Contribution_Margin_TB" value="#numberFormat(Variable_Contribution_Margin,request.nondollar_format)#">
        <input type="hidden" name="#Product_Id#_Contribution_Margin_TB" id="#Product_Id#_Contribution_Margin_TB" value="#numberFormat(Contribution_Margin_Alt,request.nondollar_format)#">
        <input type="hidden" name="#Product_Id#_Gross_Margin_TB" id="#Product_Id#_Gross_Margin_TB" value="#numberFormat(Gross_Margin,request.nondollar_format)#">
        <input type="hidden" name="#Product_Id#_Net_Sales_TB" id="#Product_Id#_Net_Sales_TB" value="#numberFormat(Net_Sales,request.nondollar_format)#">
        <input type="hidden" name="#Product_Id#_Allowance_Percentage_TB" id="#Product_Id#_Allowance_Percentage_TB" value="#numberFormat(Allowance_Percent,request.numeric_format)#">
        <input type="hidden" name="#Product_Id#_Allowance_TB" id="#Product_Id#_Allowance_TB" value="#numberFormat(Allowance_Display_Value,request.nondollar_format)#">
      </cfif>
    <!--- check if the program is RFA only then display the check boxes --->
    <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>

      <!--- get all the previous approved items  --->
      <cfquery name="getitemapprovedvalues" datasource="#application.datasource#">
          select isnull(approve,0) as item_approve,Name_Last,Name_First
          from Program_Type_Code_Approval_Info
          LEFT JOIN  _Users
          ON _Users.user_id = Program_Type_Code_Approval_Info.User_Id
          and _Users.deleted = 0
          and ISNULL(Program_Type_Code_Approval_Info.System_Agreement, 0) = 0
          where product_id = '#BSA_Foodservice_Items_Master_Id#'
          and program_id = #contract_main_id#
          and Program_Type_Code_Approval_Info.deleted = 0
          and isnull(approve,0) = 1
          order by Program_Type_Code_Approval_Info.System_Agreement
      </cfquery>
      <cfquery name="getitemagreedcount" datasource="#application.datasource#">
          select count(agree) as agreecount
          from Program_Type_Code_Approval_Info
          where product_id = '#BSA_Foodservice_Items_Master_Id#'
          and program_id = #contract_main_id#
          and Program_Type_Code_Approval_Info.deleted = 0
          and isnull(agree,0) = 1
        </cfquery>



      <!--- if the approve settings like growth and upfront funds are not allowed to be approved and if the item margin is not within limits --->
      <!--- display the label either approve or label after checking all the above conditions --->
      <cfif (CannotApproveSettings eq 0 and CannotApproveItemMargin eq 0 and CannotApproveProgramMargin eq 0) OR (getitemapprovedvalues.recordcount GT 0 and getitemapprovedvalues.item_approve eq 1)>
        <cfset feildname = "ProductApprove_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#">
        <cfset itemlabel = "Approve">
        <cfif getitemagreedcount.agreecount GT 0>
          <cfset imagesrc = "Gaya_i18.gif">
          <cfset title = "Click here to view the list of users who agreed">
        <cfelse>
          <cfset imagesrc = "Gaya_i12.gif">
          <cfset title = "">
        </cfif>
         <cfif getitemapprovedvalues.item_approve eq 1>
          <cfset itemlabel = "Approved">
          <cfset checkitemvalue = "checked disabled">
          <cfset imagesrc = "Gaya_i11.gif">
          <cfset title = "">
          <cfset approveditemuser = #getitemapprovedvalues.Name_First# & ' ' & #getitemapprovedvalues.Name_Last#>
        </cfif>
      <cfelseif (getitemapprovedvalues.item_approve eq 0 OR getitemapprovedvalues.recordcount eq 0) and (CannotApproveSettings eq 1 OR CannotApproveItemMargin eq 1 OR CannotApproveProgramMargin eq 1)>
        <cfset cannotapprove = 1>
        <cfset feildname = "ProductAgree_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#">
        <cfquery name="getitemvalues" datasource="#application.datasource#">
          select isnull(agree,0) as item_agree
          from Program_Type_Code_Approval_Info
          where product_id = '#BSA_Foodservice_Items_Master_Id#'
          and user_id = '#request.AccessStructure.User_ID#'
          and program_id = #contract_main_id#
          and deleted = 0
        </cfquery>
        <cfset itemlabel = "Agree">
        <cfset imagesrc = "Gaya_i12.gif">
         <cfif getitemvalues.item_agree eq 1 and getitemvalues.recordcount GT 0>
          <cfset itemlabel = "Agreed">
          <cfset checkitemvalue = "checked disabled">
          <cfset title = "Click here to view the list of users who agreed">
          <cfset imagesrc = "Gaya_i18.gif">
        </cfif>
        <cfset button_label = "Agree">
        <cfset showagreepopup = 1>
      </cfif>

      <td BGCOLOR="#itemtrbgcolor#" valign="middle" class="csvExclude ln_3459">
      <span ID="checkAllProducts"><input type="checkbox" original_name="#feildname#" idToken="#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" name="#feildname#" value="1" #checkitemvalue# #disablecheckbox# <cfif disablecheckbox eq "">checked</cfif>></span></td>
      <!--- mass approve --->
      <cfif not itemCheckBoxDisabled>
        <cfset stMassApproval["#feildname#"] = 1 />
      </cfif>

      <td BGCOLOR="#itemtrbgcolor#" class="Title6 csvExclude ln_3466" valign="middle">
        <span class="title5" id="approve_agree_label_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" original_approve_agree_label="#itemlabel#">#itemlabel#</span></td>
      <td BGCOLOR="#itemtrbgcolor#" class="ln_3468">
        <IMG SRC="/images/Layered_Approval/#imagesrc#"
        <cfif imagesrc eq 'Gaya_i11.gif'>
        <cfif trim(approveditemuser) neq "">
        onmouseover="initTheTooltip('Approved by #approveditemuser#')" onmouseout="popOut()"
        </cfif>
        <cfelseif imagesrc eq 'Gaya_i18.gif'>
         onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
         onclick="showCalculation('#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#','AG','P')"
        </cfif> STYLE="cursor:pointer;"></td>
        <td class="csvExclude ln_3478">&nbsp;</td>
        <cfelse>
          <td class="csvExclude ln_3480">&nbsp;</td>
          <td class="csvExclude ln_3481">&nbsp;</td>
    </cfif>
     </TR>

      <cfset count = count + 1>
      <cfset checkitemvalue = "">
      <cfset itemlabel ="">
      <cfset CannotApproveItemMargin = 0>

    </cfoutput>
      <input type="hidden" name="#Type_Code_Desc_ID#" value="#itemCount#">
      <cfset itemCount = 0>
    <!------------------------------------------------------------------------------------------------------------------->
    <!--- End: Outputs the individual items  ---------------------------------------------------------------------------->
    <!------------------------------------------------------------------------------------------------------------------->


    <!------------------------------------------------------------------------------------------------------------------->
    <!--- Type Code Groups - START -------------------------------------------------------------------------------------->
    <!------------------------------------------------------------------------------------------------------------------->
      <tr bgcolor="#grouptrbgcolor#" id="#Type_Code_Desc_ID#_ProdID">
    <CFLOOP query="getGroupvalues">
    <cfif Get_Profile_Settings.Base_View eq 1>
    <TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" width="150" class="forceLeft ln_3502">
  <cfif url.idealPriceAnalysis>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</cfif>#Type_Code_Desc#
  </td>
      <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
      <!--- 114617 :: Ideal Price START --->
      <cfif getProgramInfo.Ideal_Price>
        <td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3255">&nbsp;</td>
      </cfif>
      <!--- 114617 :: Ideal Price END --->
      <!------------------------->
      <!--- 001 - Fixed Price --->
      <!------------------------->
      <cfif variables.bDisplayContractPrice>
      <!--- 16314 [begin] --->
          <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="ln_3509">&nbsp;</td>
          <!--- 16314 [end] --->
      </cfif>
      <!--- 17289 > 16314 follow up 10/14/08 [end] --->
    <!--- 114617 :: Ideal Price START --->
    <cfif getProgramInfo.Ideal_Price>
      <td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3255">&nbsp;</td>
      <td style="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="3255">
        #application.util.string.cellFormat(value=TotalDiffDollar ,decimalplaces = request.dollar_format)#
      </td>
    </cfif>
    <!--- 114617 :: Ideal Price END --->
      <!------------------------->
      <!--- 002 - Vol. CS ------->
      <!------------------------->
    <TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3516">
    #trim(numberformat(round(Total_Product_Program_Volume),'_-___,___,___,___,___'))#
    </TD>
    <!------------------------->
    <!--- 003 - Base Sales ---->
    <!------------------------->
    <TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3522">
       #application.util.string.cellFormat(value=Total_Base_Sales ,decimalplaces = request.dollar_format )#
    </TD>

    <cfif direct_pricing eq 0>
      <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
      <!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
      <!--------------------->
      <!--- 004 Cash Disc --->
      <!--------------------->
      <cfif appsettings.getDisplayCashDiscountMargin() eq 1>
        <TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3533">
          #application.util.string.cellFormat(value=Total_Cash_discount ,decimalplaces = request.dollar_format )#
        </TD>
      </cfif>
      <!----------------------->
      <!--- 005 - allowance --->
      <!----------------------->
      <TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3540" id="#Type_Code_Desc_ID#_TypeCode_Allowance">
        <cfif appSettings.getApprovalMarginType() eq 2>
          <cfset Total_Item_Allowance_Display_Value = Total_Item_Allowance_Annualized />
        <cfelse>
          <cfset Total_Item_Allowance_Display_Value = Total_Item_Allowance />
        </cfif>
          #application.util.string.cellFormat(value=Total_Item_Allowance_Display_Value ,decimalplaces = request.dollar_format )#
      </TD>

      <!--- Dev Note:Milan (42990) ******* Allow % column ******* --->
      <!--- The reason why the logic to add this column is the same as the "Allowance" column above is because "Allow %" relies on "Total_Item_Allowance_Display_Value".
      I could have used IsDefined("Total_Item_Allowance_Display_Value") to show or hide this column, but it was simpler to just rely on the logic for "Total_Item_Allowance_Display_Value",
      as the below calculated value relies on ""Total_Item_Allowance_Display_Value".
      --->
      <!--------------------->
      <!--- 006 - allow % --->
      <!--------------------->
      <td align="right" nowrap class="ln_3557" id="#Type_Code_Desc_ID#_TypeCode_AllowancePer">
        <cfif Total_Item_Allowance_Display_Value eq 0 OR Total_Base_Sales eq 0>
          N/A
        <cfelseif Total_Item_Allowance_Display_Value LT 0>
          0.00%
        <cfelse>
        <cfset Total_Allowance_Percent = (Total_Item_Allowance_Display_Value/Total_Base_Sales) * 100>
          #application.util.string.cellFormat(value=Total_Allowance_Percent ,decimalplaces = request.numeric_format )#%
        </cfif>
      </TD>
    </cfif>

    <!----------------------------->
    <!--- 007 - TPA --------------->
    <!----------------------------->
    <CFIF ShowTPA eq 1>
    <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3573">
        #application.util.string.cellFormat(value=Total_TPA ,decimalplaces = request.dollar_format )#
    </td>
    </CFIF>
    <!----------------------------->
    <!--- 008 - pullback amount --->
    <!----------------------------->
     <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
      <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3581">
        #application.util.string.cellFormat(value=Total_Pullbackamount ,decimalplaces = request.dollar_format )#
    </td>
    </cfif>
    <!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
    <!----------------------->
    <!--- 009 - net sales --->
    <!----------------------->
    <cfif appSettings.getApprovalMarginType() eq 0 OR appSettings.getApprovalMarginType() eq 3>
      <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3590"  id="#Type_Code_Desc_ID#_TypeCode_Net_Sales">
          #application.util.string.cellFormat(value=Total_Net_Sales ,decimalplaces = request.dollar_format )#
      </td>
    </cfif>
  </cfif>
  <!------------------>
  <!--- 010 - cost --->
  <!------------------>
  <cfif Get_Profile_Settings.View_Cost eq 1>
    <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3599">
      #application.util.string.cellFormat(value=Total_Cost ,decimalplaces = request.dollar_format )#
    </td>
  </cfif>
  <!----------------------->
  <!--- 011 - Brokerage --->
  <!----------------------->
  <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
    <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3607">
      #application.util.string.cellFormat(value=Total_Brokerage ,decimalplaces = request.dollar_format )#
    </td>
  </cfif>
  <!------------------------------>
  <!--- 012 - operating income --->
  <!------------------------------>
  <cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
    <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3615" id="#Type_Code_Desc_ID#_TypeCode_Opr_Income">
      #application.util.string.cellFormat(value=Total_Operating_Income ,decimalplaces = request.dollar_format )#
    </td>
  </cfif>

  <cfif Get_Profile_Settings.View_Target_Margins eq 1>
    <cfif appSettings.getApprovalMarginType() eq 2><!--- Annual Case Rate --->
      <!------------------------------->
      <!--- 013a - Annual Case Rate --->
      <!------------------------------->
      <TD STYLE="border-top: 1px solid 0000FF " BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3625">
         <!--- Dev Note: Drachala; D27335: Add UOM display to margin page for spend rate ADDED groupTargetCaseRateUOM--->
        #application.util.string.cellFormat(value=Total_Trade,decimalplaces = request.dollar_format )#/<cfif groupTargetCaseRateUOM eq 1>CS<cfelseif groupTargetCaseRateUOM eq 2>LB</cfif>

      </td>
      <!------------>
      <!--- 013z --->
      <TD STYLE="border-top: 1px solid 0000FF " BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3632">&nbsp;</td>

      <!------------------------------->
      <!--- 013b - Target Case Rate --->
      <!------------------------------->
      <TD STYLE="border-top: 1px solid 0000FF " BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3637">
        <cfif groupTargetCaseRateUOM eq 2>
          <cfset groupTargetRate = groupTargetLBRate />
        <cfelse>
          <cfset groupTargetRate = groupTargetCaseRate />
        </cfif>
        <!--- Dev Note: Drachala; D27335: Add UOM display to margin page for spend rate ADDED groupTargetCaseRateUOM--->
        #application.util.string.cellFormat(value=groupTargetRate,decimalplaces = request.dollar_format )#/<cfif groupTargetCaseRateUOM eq 1>CS<cfelseif groupTargetCaseRateUOM eq 2>LB</cfif>
      </td>
    <cfelse>
        <cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
          <TD STYLE="border-top: 1px solid 0000FF " BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3648"  id="#Type_Code_Desc_ID#_TypeCode_Opr_Margin_Percentage">
              #(Total_OperatingMargin_percent lt 0
                  ? NegativeFormat( numberFormat( Total_OperatingMargin_percent * -1, ",.99" ) )
                  : numberformat( Total_OperatingMargin_percent, ",.99" ))#%
          </TD>
        </cfif>
  <!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START --->
  <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
  <td align="right" nowrap class="ln_3656">
    <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
      <cfset Total_ContribMarginAmount = #Total_Operating_Income# - #Total_Fixed_Mfg_Cost#>
    <cfelse>
     <cfset Total_ContribMarginAmount = #Total_Operating_Income# + #Total_Fixed_Mfg_Cost#>
    </cfif>
     #application.util.string.cellFormat(value=Total_ContribMarginAmount ,decimalplaces = request.dollar_format )#
  </td>
  <td align="right" nowrap class="ln_3664">
    <cfif len(Total_Net_Sales) EQ 0 OR Total_Net_Sales EQ 0>
      <cfset variables.Total_Net_Sales = 1>
    <cfelse>
      <cfset variables.Total_Net_Sales = Total_Net_Sales>
    </cfif>

    <cfset Total_ContribMarginPer = (Total_ContribMarginAmount / variables.Total_Net_Sales) * 100>
        #application.util.string.cellFormat(value=Total_ContribMarginPer,decimalplaces = request.numeric_format )#%
  </td>
   </cfif>
   <!--- 62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END --->
    <TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="csvExclude ln_3676">
      <CFIF CannotApproveGroupMargin eq 1>
        <IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10" onmouseover="initTheTooltip('You do not have approval rights.')" onmouseout="popOut()" align="absmiddle">
      <cfelse>
      </cfif>
    </TD>

    <TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3683">
      <A STYLE="cursor:pointer;" ONCLICK="showCalculation('#replace(Type_code_desc_id, "-", "_", "ALL")#','T','G')">
          <cfif groupapprovalmargin eq "*">
              #application.util.string.cellFormat(value=Target_Margin,decimalplaces = request.numeric_format )#%
          <cfelse>
              #application.util.string.cellFormat(value=groupapprovalmargin,decimalplaces = request.numeric_format )#%
          </cfif>
      </A>
    </TD>
    </cfif>
  </cfif>

  <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
  <cfif appSettings.getApprovalMarginType() eq 1>
    <td align="right" nowrap class="ln_3697">
      #application.util.string.cellFormat(value=Total_Trade,decimalplaces = request.dollar_format )#
    </td>
  </cfif>
  <!--- Dev Note: KAL; D21595: HZ Trade as Percent of Base Sales, for display only.  Forge changes --->
  <cfif (appSettings.getApprovalMarginType() eq 1) or (appSettings.getApprovalMarginType() eq 0 and appSettings.getDisplay_Trade_Percent_on_Margin() eq 1)>
    <td align="right" nowrap class="ln_3703">
      #application.util.string.cellFormat(value=Total_Trade_Percent,decimalplaces = request.numeric_format )#%
    </td>
  </cfif>

  <!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
  <!--- Dev Note: KAL; D21859: CAG Instill - trade as a % of sales questions - DISPLAY TRADE SPEND AT THE TYPE CODE ROWS --->
  <cfif Get_Profile_Settings.Base_View eq 1>
    <cfset Total_Trade_Spend = Total_Item_Allowance * round(Total_Product_Program_Volume)>
    <TD STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" align="right" nowrap class="ln_3712" id="#Type_Code_Desc_ID#_TypeCode_Trade_Spend">
        #application.util.string.cellFormat(value=Total_Trade_Spend,decimalplaces = request.dollar_format )#
    </TD>
  </cfif>

  <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>

    <cfquery name="getgroupapprovedvalues" datasource="#application.datasource#">
        select isnull(approve,0) as group_approve, Name_Last, Name_First
        from Program_Type_Code_Approval_Info
        Left JOIN  _users
        On _Users.user_id = Program_Type_Code_Approval_Info.User_Id
        and _Users.deleted = 0
        where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
        and program_id = #contract_main_id#
        and Program_Type_Code_Approval_Info.deleted = 0
        and isnull(approve,0) = 1
    </cfquery>

      <cfquery name="getgroupagreedcount" datasource="#application.datasource#">
        select count(agree) as agreecount
        from Program_Type_Code_Approval_Info
        where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
        and program_id = #contract_main_id#
        and Program_Type_Code_Approval_Info.deleted = 0
        and isnull(agree,0) = 1
      </cfquery>

    <cfif (CannotApproveSettings eq 0 and Group_ID_Approval eq 1 and CannotApproveProgramMargin eq 0 and CannotApproveGroupMargin eq 0) OR (getgroupapprovedvalues.recordcount gt 0 and getgroupapprovedvalues.group_approve GT 0)>
      <cfset feildname = "GroupApprove_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#">
      <cfset grouplabel = "Approve">
      <cfset showColumn = 0 />
      <cfif getgroupagreedcount.agreecount GT 0>
        <cfset imagesrc = "Gaya_i18.gif">
        <cfset title = "Click here to view the list of users who agreed">
      <cfelse>
        <cfset imagesrc = "Gaya_i12.gif">
        <cfset title = "">
      </cfif>
       <cfif getgroupapprovedvalues.group_approve eq 1>
        <cfset grouplabel = "Approved">
        <cfset checkgroupvalue = "checked disabled">
        <cfset imagesrc = "Gaya_i11.gif">
        <cfset title = "">
        <cfset approvedgroupuser = #getgroupapprovedvalues.Name_First# & ' ' & #getgroupapprovedvalues.Name_Last#>
        <cfset showColumn = 1 />
      </cfif>
    <cfelseif (getgroupapprovedvalues.group_approve eq 0 OR getgroupapprovedvalues.recordcount eq 0) and (CannotApproveSettings eq 1 OR Group_ID_Approval eq 0 OR CannotApproveGroupMargin eq 1 or CannotApproveProgramMargin eq 1)>
      <cfset cannotapprove = 1>
      <cfset showColumn = 0 />
      <cfset feildname = "GroupAgree_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#">
      <cfquery name="getgroupagreevalues" datasource="#application.datasource#">
        select isnull(agree,0) as group_agree
        from Program_Type_Code_Approval_Info
        where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
        and user_id = '#request.AccessStructure.User_ID#'
        and program_id = #contract_main_id#
        and deleted = 0
      </cfquery>
      <cfset grouplabel = "Agree">
      <cfset imagesrc = "Gaya_i12.gif">
       <cfif getgroupagreevalues.recordcount GT 0 and getgroupagreevalues.group_agree eq 1>
        <cfset grouplabel = "Agreed">
        <cfset checkgroupvalue = "checked disabled">
        <cfset title = "Click here to view the list of users who agreed">
        <cfset imagesrc = "Gaya_i18.gif">
        <cfset showColumn = 1 />
      </cfif>
    </cfif>
      <cfif isDefined("showColumn") and showColumn eq 0 and grouplabel is not "Approve" and grouplabel is not "Agree">

      <td class="ln_3783">&nbsp;</td>

    </cfif>
    <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="csvExclude ln_3786">
    <span ID="checkAllProducts"><input type="checkbox" original_name="#feildname#" idToken="#replace(Type_Code_Desc_Id, "-", "_", "ALL")#" name="#feildname#" value="1" #checkgroupvalue# #disablecheckbox# <cfif disablecheckbox eq "">checked</cfif>></span></td>
    <cfif not itemCheckBoxDisabled>
      <cfset stMassApproval["#feildname#"] = 1 />
    </cfif>
    <td STYLE="border-top:1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="ln_3791"><b><span class="title6" id="approve_agree_label_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#" original_approve_agree_label="#grouplabel#">#grouplabel#</span></B></td>
  <td STYLE="border-top: 1px solid 0000FF" BGCOLOR="#grouptrbgcolor#" class="ln_3792">
      <IMG SRC="/images/Layered_Approval/#imagesrc#"
      <cfif imagesrc eq 'Gaya_i11.gif'>
      <cfif trim(approvedgroupuser) neq "">
  onmouseover="initTheTooltip('Approved by #approvedgroupuser#')" onmouseout="popOut()"
      </cfif>
      <cfelseif imagesrc eq 'Gaya_i18.gif'>
       onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
       onclick="showCalculation('#replace(Type_Code_Desc_Id, "-", "_", "ALL")#','AG','G')"
      </cfif>
       STYLE="cursor:pointer;"></td>
         <td class="ln_3803">&nbsp;</td>
       <cfelse>
       <td class="ln_3805">&nbsp;</td>
       <td class="ln_3806">&nbsp;</td>

  </cfif>

  <cfset checkgroupvalue = "">
  <cfset grouplabel = "">
  </CFLOOP>
    <!------------------------------------------------------------------------------------------------------------------->
    <!--- Type Code Groups - END ---------------------------------------------------------------------------------------->
    <!------------------------------------------------------------------------------------------------------------------->
    </TR>

  <TR>
    <td style="border-bottom: 0px solid blue;" class="ln_3819">&nbsp;</td>
  </TR>
  <cfset CannotApproveGroupMargin = 0>
  <cfset disablecheckbox = "">
  <cfset grouptrbgcolor = "##CCFFCC">
  <cfset itemtrbgcolor = "##f4f4f4">

  <cfif massapproval eq 0>

  <cfset LastPercent = 0>

  <!--- This will return values of 1 through 10 (1 being 10%, 2 being 20%....10 being 100%) --->
  <cfset PercentDone = Int(Ceiling((OuterLoopcount/ProductMarginCount) * 100)/10)>

  <!--- Show the Image based on product count --->
  <cfif LastPercent neq PercentDone>
    <cfset Block = "Block" & PercentDone>
    <cfset LastPercent = PercentDone>
  </cfif>

  <cfset OuterLoopcount = OuterLoopcount + 1>

  </cfif>

  </CFOUTPUT>
  <!--------------------------------------------------------------------------->
  <!--- Products main loop group by type code - end  -------------------------->
  <!--------------------------------------------------------------------------->

  <cfset colCount = 0 />
   <cfoutput>
    <tr>
      <td id="header" colspan="#th_count#" class="ln_3866"><br /><strong>#qGetMarginUOT.UOT_Desc# Summary</strong></td>
    </tr>

    <cfset OriginalTotalProgramVolume = TotalProgramVolume />

    <!------------------------------------------------------------------------------------------------------------------->
    <!------ Annual/Program Summary : Rate / UOM START ------------------------------------------------------------------>
    <!------------------------------------------------------------------------------------------------------------------->
    <cfset displayUOM = totalprogramvolumeUOM>
    <cfset qProgramSummaryMargins = getProgramMargins />
    <cfinclude template="layered_margin_program_rate_summary.cfm">
    <!--- <cfset layered_margin_program_rate_summary()> --->

    <!--------------------------------------------------------------------------------------------------->
    <!--- display additional summary line for cs/lb if annual spending rate approval app switch is ON --->
    <!--------------------------------------------------------------------------------------------------->
    <cfif appSettings.getApprovalMarginType() eq 2>
      <cfif form.Margin_Type eq 1><!--- case --->
        <!--- Display pound --->
        <cfset displayUOM = application.UOMPoundSingular>
        <cfset qProgramSummaryMargins = ApprovalProgramManager.getProgramMargins(contract_main_id, 3, "#margin_version#")>
      <cfelse><!--- pound --->
        <!--- Display case --->
        <cfset displayUOM = "CS">
        <cfset qProgramSummaryMargins = ApprovalProgramManager.getProgramMargins(contract_main_id, 1, "#margin_version#")>
      </cfif>
      <cfinclude template="layered_margin_program_rate_summary.cfm">
      <!--- <cfset layered_margin_program_rate_summary()> --->
    </cfif>
    <!------------------------------------------------------------------------------------------------------------------->
    <!------ Annual/Program Summary : Rate / UOM end -------------------------------------------------------------------->
    <!------------------------------------------------------------------------------------------------------------------->


    <!------------------------------------------------------------------------------------------------------------------->
    <!------ Annual/Program Summary : Absolute $ start ------------------------------------------------------------------>
    <!------------------------------------------------------------------------------------------------------------------->
    <cfset TotalProgramVolume = OriginalTotalProgramVolume />
    <tr valign="middle">
      <td align="left" id="header" class="ln_3905"><strong>Absolute $</strong></td>
          <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
        <!--- 114617 :: Ideal Price START --->
        <cfif getProgramInfo.Ideal_Price>
          <td>&nbsp;</td>
        </cfif>
        <!--- 114617 :: Ideal Price END --->
        <!------------------------->
        <!--- 001 - Fixed Price --->
        <!------------------------->
        <cfif variables.bDisplayContractPrice>
        <!--- 16314 [begin] --->
              <td class="ln_3912">&nbsp;</td>
              <!--- 16314 [end] --->
          </cfif>
          <!--- 17289 > 16314 follow up 10/14/08 [end] --->
        <!--- 114617 :: Ideal Price START --->
        <cfif getProgramInfo.Ideal_Price>
          <td>&nbsp;</td>
          <td>
            #application.util.string.cellFormat(value=TotalDiffDollar ,decimalplaces = request.dollar_format)#
          </td>
      </cfif>
      <!--- 114617 :: Ideal Price END --->
      <!------------------------->
      <!--- 002 - Vol. CS ------->
      <!------------------------->
      <cfif Get_Profile_Settings.Base_View eq 1>
        <cfset data = makeNumeric(TotalProgramVolume) />
      <cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)>
        <td class="ln_3922">
          <cfset colCount = colCount + 1 />
          <cfif ((TotalProgramVolume GT AnnualVolume_CS) and TRIM(AnnualVolume_CS) NEQ "*")
            OR  ((TotalProgramVolume LT MinVolume_CS) and TRIM(MinVolume_CS) NEQ "*")>
            <IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
              onmouseover="initTheTooltip('Volume not within your approval limits.')"
              onmouseout="popOut()"
              align="absmiddle">
          </cfif>&nbsp;
        </td>
        <!------------------------->
        <!--- 003 - Base Sales ---->
        <!------------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(TotalProgramVolume) />
        <cfset tempABS_BaseSales = data />
        <td align="right" nowrap class="ln_3937"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>

        <cfif direct_pricing eq 0>
          <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
          <!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
          <!--- 004 --->
          <!--------------------->
          <!--- 004 Cash Disc --->
          <!--------------------->
          <cfif appsettings.getDisplayCashDiscountMargin() eq 1>
            <cfset data = makeNumeric(getProgramMargins.Total_Cash_Discount) * makeNumeric(TotalProgramVolume) />
        <td align="right" nowrap class="ln_3948"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
          </cfif>
          <!----------------------->
          <!--- 005 - allowance --->
          <!----------------------->
          <cfparam name="addExtra" default="0">
          <cfif TotalProgramVolume neq "" and TotalProgramVolume neq 0>
            <cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/TotalProgramVolume) />
          </cfif>
          <cfif form.Margin_Type eq 1 OR form.margin_type eq 3>
            <cfset data = (makeNumeric(getProgramMargins.TOTAL_Allowance) + addExtra) * makeNumeric(TotalProgramVolume) />
          <cfelse>
            <cfset data = makeNumeric(getProgramMargins.TOTAL_Allowance) * makeNumeric(TotalProgramVolume) />
          </cfif>

          <cfset AllowAbs1 = makeNumeric(data)>

        <td align="right" nowrap class="ln_3965" id="PrgABSummary_Allowance" LumpsumAmount=#application.util.string.cellFormat(value=getProgramLumpsum.Lumpsum_Amount ,decimalplaces = request.nondollar_format)#> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
          <!--------------------->
          <!--- 006 - allow % --->
          <!--------------------->
          <td align="right" nowrap class="ln_3969">&nbsp;</TD>
        </cfif>

        <cfif ShowTPA eq 1>
          <!----------------------------->
          <!--- 007 - TPA --------------->
          <!----------------------------->
          <cfset data = makeNumeric(getProgramMargins.Total_TPA) * makeNumeric(TotalProgramVolume) />
        <td align="right" nowrap class="ln_3977"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        </cfif>

        <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
          <!----------------------------->
          <!--- 008 - pullback amount --->
          <!----------------------------->
          <cfset data = makeNumeric(getProgramMargins.Total_pullbackamount) * makeNumeric(TotalProgramVolume) />
        <td align="right" nowrap class="ln_3985"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        </cfif>

        <!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
        <cfif appSettings.getApprovalMarginType() eq 0>
          <!----------------------->
          <!--- 009 - net sales --->
          <!----------------------->
          <cfset data = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume) />
          <cfset tempABS_NetSales = data />

        <td align="right" nowrap class="ln_3996" id="PrgABSummary_NetSales"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        </cfif>
      </cfif>

      <cfif Get_Profile_Settings.View_Cost eq 1>
        <!------------------>
        <!--- 010 - cost --->
        <!------------------>
        <cfset data = makeNumeric(getProgramMargins.Total_Cost) * makeNumeric(TotalProgramVolume) />
        <td align="right" nowrap class="ln_4005"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
      </cfif>

      <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
        <!----------------------->
        <!--- 011 - Brokerage --->
        <!----------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_Brokerage) * makeNumeric(TotalProgramVolume) />
        <td align="right" nowrap class="ln_4013"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
      </cfif>

      <cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
        <!------------------------------>
        <!--- 012 - operating income --->
        <!------------------------------>
        <cfset data = makeNumeric(getProgramMargins.Total_OprIncome) * makeNumeric(TotalProgramVolume) />
        <cfset absTotalOperIncome = data />
        <td align="right" nowrap class="ln_4022" id="PrgABSummary_Operating_Income"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
      </cfif>

      <cfif Get_Profile_Settings.View_Target_Margins eq 1>

        <cfif appSettings.getApprovalMarginType() eq 2>
          <!------------------------------->
          <!--- 013a - Annual Case Rate --->
          <!------------------------------->
          <cfset data = makeNumeric(getProgramMargins.Total_TradeAmt_CS) * makeNumeric(getProgramMargins.totalprogramvolumecs) />

          <cfset AllowAbs1 = makeNumeric(data)>

        <td align="right" nowrap class="ln_4035"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        <cfelse>
          <!--------------------------------------->
          <!--- 013m - Operating Margin Percent --->
          <!--------------------------------------->
          <cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
            <cfset data = makeNumeric(getProgramMargins.Total_OprMargin)>
              <cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)>
              <cfset data = "<b>#data#%</b>">
            <td class="ln_4044">
              <cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin) and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*" and ignoreOperatingMarginCheck eq 0>
              <IMG SRC="/images/exclamation.gif" HEIGHT="10" WIDTH="10"
                onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')"
                onmouseout="popOut()"
                align="absmiddle">
            </cfif>&nbsp;
          </td>
        </cfif>
        </cfif>

      </cfif>
  <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
  <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
        <cfset data = (makeNumeric(getProgramMargins.Total_Fixed_Mfg_Cost)+makeNumeric(getProgramMargins.Total_OprIncome)) * makeNumeric(TotalProgramVolume)/>
        <cfset TotalContribMargin = data />
        <td align="right" nowrap class="ln_4060"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
    <cfset variables.Total_Net_Sales = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume)>

    <cfif len(variables.Total_Net_Sales) EQ 0 OR variables.Total_Net_Sales EQ 0>
      <cfset variables.Total_Net_Sales = 1>
    </cfif>
    <cfset data = (TotalContribMargin/makeNumeric(variables.Total_Net_Sales)) * 100/>
        <td align="right" nowrap class="ln_4067"> #application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )# %</td>
  </cfif>
  <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
      <!------------>
      <!--- 013z --->
      <!------------>
      <cfif Get_Profile_Settings.View_Target_Margins eq 1>
        <td valign="bottom" class="csvExclude ln_4074">&nbsp;</td>
      <!------------------->
      <!--- 013b | 013n --->
        <td class="ln_4077">&nbsp;</td>
      </cfif>

      <!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
      <cfif appSettings.getApprovalMarginType() eq 1>
        <!---------------------->
        <!--- 014 - Trade CS --->
        <!---------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_TradeAmt) * makeNumeric(TotalProgramVolume)  />
        <td align="right" nowrap class="ln_4086"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>

        <!---------------------->
        <!--- 015 - trade %  --->
        <!---------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_TradePercent) />
        <td align="right" nowrap class="ln_4092"> #application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )# %</td>
      </cfif>

      <!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
      <cfif Get_Profile_Settings.Base_View eq 1>
        <!------------------------->
        <!--- 016 - Trade Spent --->
        <!------------------------->
        <cfset data = makeNumeric(program_spend_in_margin_uot) />
        <td align="right" nowrap class="ln_4101" id="PrgABSummary_Trade_Spent"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
      </cfif>

      <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
        <td class="ln_4105">&nbsp;</td>
        <td class="ln_4106">&nbsp;</td>
        <td class="ln_4107">&nbsp;</td>
        <td class="ln_4108">&nbsp;</td>
      <cfelse>
        <td class="ln_4110" >&nbsp;</td>
        <td class="ln_4111" >&nbsp;</td>
      </cfif>

    </tr>
    <!------------------------------------------------------------------------------------------------------------------->
    <!------ Annual/Program Summary : Absolute $ end -------------------------------------------------------------------->
    <!------------------------------------------------------------------------------------------------------------------->
    <!--- 114617 --->
    <cfif ! url.idealPriceAnalysis>

    <!------------------------------------------------------------------------------------------------------------------->
    <!------ Program Summary: Absolute#2 $ START ------------------------------------------------------------------------>
    <!------------------------------------------------------------------------------------------------------------------->
    <cfif qGetMarginUOT.Unit_Multiplier NEQ 0>
    <tr>
            <td id="header" colspan="#th_count#" class="ln_4126"><br><strong>Program Summary</strong></td>
     </tr>

    <tr valign="middle">
    <td align="left" id="header" class="ln_4130"><strong>Absolute $</strong></td>
      <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
      <cfif variables.bDisplayContractPrice>
      <!--- 16314 [begin] --->
          <td class="ln_4134">&nbsp;</td>
          <!--- 16314 [end] --->
      </cfif>
      <!--- 17289 > 16314 follow up 10/14/08 [end] --->
    <cfset ProgramVolume_For_Program_Span = (TotalProgramVolume * getProgramInfo.Program_Span) / qGetMarginUOT.Unit_Multiplier />
        <cfif Get_Profile_Settings.Base_View eq 1>

          <!--- volume --->
        <td class="ln_4142">&nbsp;</td>
       <!--- 003 - base sales --->
       <cfset data = makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(ProgramVolume_For_Program_Span) />
           <cfset tempABS_BaseSales = data />
        <td align="right" nowrap class="ln_4146"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
       <!--- cash disc --->
       <cfif direct_pricing eq 0>
        <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
        <!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
        <cfif appsettings.getDisplayCashDiscountMargin() eq 1>
                <cfset data = makeNumeric(getProgramMargins.Total_Cash_Discount) * makeNumeric(ProgramVolume_For_Program_Span) />
              <td align="right" nowrap class="ln_4153"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        </cfif>
         <!--- 005 - allowance --->
               <cfparam name="addExtra" default="0">
               <cfif ProgramVolume_For_Program_Span neq "" and ProgramVolume_For_Program_Span neq 0>
               <cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/ProgramVolume_For_Program_Span) />
               </cfif>
         <cfif form.Margin_Type eq 1 OR form.margin_type eq 3>
                 <cfset data = (makeNumeric(getProgramMargins.TOTAL_Allowance) + addExtra) * makeNumeric(ProgramVolume_For_Program_Span) />
               <cfelse>
                 <cfset data = makeNumeric(getProgramMargins.TOTAL_Allowance) * makeNumeric(ProgramVolume_For_Program_Span) />
               </cfif>

        <cfset AllowAbs1 = makeNumeric(data)>

        <td align="right" nowrap class="ln_4168"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        <!--- 006 -skip a column for "Allow %" --->
        <td align="right" nowrap class="ln_4170">&nbsp;</TD>
        </cfif>
        <!--- 007 - TPA --->
        <cfif ShowTPA eq 1>
        <cfset data = makeNumeric(getProgramMargins.Total_TPA) * makeNumeric(ProgramVolume_For_Program_Span) />
        <td align="right" nowrap class="ln_4175"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
             </cfif>
         <!--- 008 - pullback amount --->
             <cfif appSettings.getPullbacksOn() eq 1
                and GetSettings.Pullbacks_On eq 1>
                  <cfset data = makeNumeric(getProgramMargins.Total_pullbackamount) * makeNumeric(ProgramVolume_For_Program_Span) />
        <td align="right" nowrap class="ln_4181"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
             </cfif>

        <!--- 009 - net sales --->
        <!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
        <cfif appSettings.getApprovalMarginType() eq 0>
          <cfset data = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(ProgramVolume_For_Program_Span) />
          <cfset tempABS_NetSales = data />
        <td align="right" nowrap class="ln_4189"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        </cfif>
      </cfif>
         <!--- 010 - cost --->
         <cfif Get_Profile_Settings.View_Cost eq 1>
               <cfset data = makeNumeric(getProgramMargins.Total_Cost) * makeNumeric(ProgramVolume_For_Program_Span) />
        <td align="right" nowrap class="ln_4195"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
             </cfif>
        <!--- 011 - Brokerage --->
        <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
               <cfset data = makeNumeric(getProgramMargins.Total_Brokerage) * makeNumeric(ProgramVolume_For_Program_Span) />
        <td align="right" nowrap class="ln_4200"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
             </cfif>
             <cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
              <!--- 012 - operating income --->
         <cfset data = makeNumeric(getProgramMargins.Total_OprIncome) * makeNumeric(ProgramVolume_For_Program_Span) />
                <cfset absTotalOperIncome = data />
        <td align="right" nowrap class="ln_4206"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
             </cfif>
         <!--- 013 - operating margin --->
         <cfif Get_Profile_Settings.View_Target_Margins eq 1>
          <cfif appSettings.getApprovalMarginType() eq 2>
          <!--- 013a - Annual Case Rate --->
          <cfset data = makeNumeric(getProgramMargins.Total_TradeAmt_CS) * makeNumeric(getProgramMargins.totalprogramvolumecs) />

          <cfset AllowAbs1 = makeNumeric(data)>

        <td align="right" nowrap class="ln_4216"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        <cfelse>
         <!--- 013m - Operating Margin Percent --->
         <cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
              <cfset data = makeNumeric(getProgramMargins.Total_OprMargin)>

                <cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format) >
                <cfset data = "<b>#data#%</b>">
                 <td class="ln_4224">
             <cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin)
                 and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*" and ignoreOperatingMarginCheck eq 0>
                          <IMG SRC="/images/exclamation.gif"
                   HEIGHT="10"
                 WIDTH="10"
                 onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')"
                 onmouseout="popOut()"
                 align="absmiddle">
                   </cfif>&nbsp;</td>
          </cfif>
        </cfif>

         </cfif>
  <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
  <cfif appSettings.get_Setting('Contribution_Margin_Calculation') EQ '1'>
        <cfset data = absTotalOperIncome/>
        <cfset TotalContribMargin = data />

        <td align="right" nowrap class="ln_4243"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        <cfset TOTALNetSales = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(ProgramVolume_For_Program_Span)>
      <cfif TOTALNetSales EQ 0>
        <cfset TOTALNetSales = 1>
      </cfif>
    <cfset data = (TotalContribMargin/makeNumeric(TOTALNetSales)) * 100 />

        <td align="right" nowrap class="ln_4250"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
  </cfif>
  <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
      <td class="csvExclude ln_4253">&nbsp;</td>
      <td class="ln_4254">&nbsp;</td>
        <!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
        <cfif appSettings.getApprovalMarginType() eq 1>
          <!--- Trade CS --->
          <cfset data = makeNumeric(getProgramMargins.Total_TradeAmt) * makeNumeric(ProgramVolume_For_Program_Span) />

        <td align="right" nowrap class="ln_4260"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>

          <!--- Trade Percent --->
          <cfset data = makeNumeric(getProgramMargins.Total_TradePercent) />

        <td align="right" nowrap class="ln_4265"> #application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )# %</td>
        </cfif>

        <!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
        <cfif Get_Profile_Settings.Base_View eq 1>
          <!--- trade spend --->
          <cfset data = makeNumeric(program_spend) />
        <td align="right" nowrap class="ln_4272"> #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
        </cfif>

         <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
          <td class="ln_4276">&nbsp;</td>
          <td class="ln_4277">&nbsp;</td>
          <td class="ln_4278">&nbsp;</td>
          <td class="ln_4279">&nbsp;</td>
         <cfelse>
           <td class="ln_4281">&nbsp;</td>
           <td class="ln_4282">&nbsp;</td>
         </cfif>

    </tr>
    </cfif>
    <!------------------------------------------------------------------------------------------------------------------->
    <!------ Program Summary: Absolute#2 $ END -------------------------------------------------------------------------->
    <!------------------------------------------------------------------------------------------------------------------->

    <!---   Dev Note: KAL; D21684: Functionality of View Margins Screen
        Code from this section is moved to separate files for code reusability and ease of development purposes.
        Previous Version - Annual/Program Summary: Code is moved to layered_margin_parent_program_summary.cfm
        Margin Variance: Code is moved to layered_margin_parent_program_variance.cfm.
        First the code was moved and checked in and then changes were made to the code.
    --->


    <cfif Program_Is_A_Revision AND displayPreviousVersionMargin>
      <!--- *** Previous Program Margins - Current Date -- Start *** --->

      <!--- variable to set which margin_version; used in layered_margin_parent_program_summary.cfm --->
      <cfset margin_version = "current" />

      <!--- Previous Program Margins Current Date --->
      <cfset getPgmPrevVerMargins_Current = ApprovalProgramManager.getProgramMargins(getProgramInfo.Revision_of_Contract_Main_ID, form.Margin_Type, "current")>

  <!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg START --->
  <cfif getPgmPrevVerMargins_Current.recordcount>
      <!--- set previous margin to this variable as we use this variable in the included templates --->
      <cfset getProgramPreviousVersionMargins = getPgmPrevVerMargins_Current />

      <cfset TotalProgramPreviousVersionVolume = getProgramPreviousVersionMargins.totalprogramvolume>
      <cfset PreviousVersion_program_spend = Val(getProgramPreviousVersionInfo.program_spend) />
      <cfset PreviousVersion_program_spend_in_margin_uot = Val(getProgramPreviousVersionInfo.program_spend_in_margin_uot) />
      <cfset PreviousVersion_Margin_Calculated_Date = ApprovalProgramManager.getMarginCalculatedDate(getProgramInfo.Revision_of_Contract_Main_ID, "current") />

      <!------ Previous Version - Annual/Program Summary : Rate/UOM & Absolute $ ----->
      <cfinclude template="layered_margin_parent_program_summary.cfm">
      <!--- <cfset layered_margin_parent_program_summary()> --->

      <!------ Previous Version - Margin Variance ----->
      <cfinclude template="layered_margin_parent_program_variance.cfm">
      <!--- <cfset layered_margin_parent_program_variance()> --->
  </cfif>
  <!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg END --->
      <!--- *** Previous Program Margins - Current Date -- End *** --->

      <!--- **** Previous Program Approved Margins -- Start **** --->
      <!--- variable to set which margin_version; used in layered_margin_parent_program_summary.cfm --->
      <cfset margin_version = "approved" />

      <!--- Previous Program Approved Margins --->
      <cfset getPgmPrevVerMargins_Approved = ApprovalProgramManager.getProgramMargins(getProgramInfo.Revision_of_Contract_Main_ID, form.Margin_Type, "approved")>

  <!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg START --->
  <cfif getPgmPrevVerMargins_Approved.recordcount>
      <!--- set previous margin to this variable as we use this variable in the included templates --->
      <cfset getProgramPreviousVersionMargins = getPgmPrevVerMargins_Approved />

      <cfset TotalProgramPreviousVersionVolume = getProgramPreviousVersionMargins.totalprogramvolume>
      <cfset PreviousVersion_program_spend = Val(getProgramPreviousVersionInfo.program_spend) />
      <cfset PreviousVersion_program_spend_in_margin_uot = Val(getProgramPreviousVersionInfo.program_spend_in_margin_uot) />
      <cfset PreviousVersion_Margin_Calculated_Date = ApprovalProgramManager.getMarginCalculatedDate(getProgramInfo.Revision_of_Contract_Main_ID, "approved") />

      <!------ Previous Version - Annual/Program Summary : Rate/UOM & Absolute $ ----->
      <cfinclude template="layered_margin_parent_program_summary.cfm">
      <!--- <cfset layered_margin_parent_program_summary()> --->

      <!------ Previous Version - Margin Variance ----->
      <cfinclude template="layered_margin_parent_program_variance.cfm">
      <!--- <cfset layered_margin_parent_program_variance()> --->
  </cfif>
  <!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg END --->
      <!--- **** Previous Program Approved Margins -- Start **** --->

    </cfif>

     <cfif CannotApproveSettings eq 1>
      <cfset button_label = "Agree">
     </cfif>
     <cfif button_label eq "Approve">
      <cfset bProgramFinalApprove = 1 /><!------ this var should be set only when either all product are approved, or the current user can approve all the product left to approve ----->
      </cfif>

     <!------ display the pullback checkbox ----->
       <cfif bPullbackAvailable>
         <!------
         Different possible scenario
         - pullback already approved
         - pullback not approved and user do not have approval right for this template
         - pullback not approved and user do have approval right for this template
         ----->

        <cfset pullbackBgColor = "gray" />
        <cfset pullbackCheckDisabled = " disabled" />
        <cfset pullbackCheckChecked = "" />
        <cfif bUserCanApprovePullbackForThisPgm>
        <cfset pullbackBgColor = "ffdead" />
        <cfset pullbackCheckDisabled = "" />
        </cfif>
        <cfif bPullbackApproved>
        <cfset pullbackCheckChecked = " checked" />
        <cfset pullbackCheckDisabled = " disabled" />
        </cfif>

       <!------ If pullback not yet approved and needs approval ----->
        <cfif bPullbackAvailable AND NOT bPullbackApproved>
        <cfif bUserCanApprovePullbackForThisPgm eq 1>
        <cfset bApprovingPullbackApprovesProgram = bProgramFinalApprove /><!------ this var should be set only when either all product are approved, or the current user can approve all the product left to approve ----->
        </cfif>
        </cfif>
        <tr>
      <td  class="ln_4394">&nbsp;</td>
        </tr>
      <tr>
        <td  class="ln_4397" bgcolor="#pullbackBgColor#" id="header" colspan="8"><b>Approve #appSettings.getPullbackLabel()#</b></td>
          <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
        <cfif variables.bDisplayContractPrice>
        <!--- 16314 [begin] --->
              <td class="ln_4401">&nbsp;</td>
              <!--- 16314 [end] --->
          </cfif>
          <!--- 17289 > 16314 follow up 10/14/08 [end] --->
        <td bgcolor="#pullbackBgColor#" class="ln_4405">
       <input type="checkbox"
              name="Approve_Pullback"
              value="1" #pullbackCheckDisabled# #pullbackCheckChecked#
          <cfif bApprovingPullbackApprovesProgram>onPropertyChange="javaScript:changeApproveLabel(this.checked);"</cfif>
          bApprovingPullbackApprovesProgram="#bApprovingPullbackApprovesProgram#"
          >
          </td>
                <td bgcolor="#pullbackBgColor#" class="ln_4413"><span class="title6">Approve</span></td>
                <td bgcolor="#pullbackBgColor#" class="ln_4414">
                 <cfif bPullbackApproved>
                 <IMG SRC="/images/Layered_Approval/Gaya_i11.gif"
                  onmouseover="initTheTooltip('#sPullbackApprovedMessage#')"
              onmouseout="popOut()" />
                 <cfelse>
                 <IMG SRC="/images/Layered_Approval/Gaya_i12.gif" />
                 </cfif>
                 </td>
           <td class="ln_4423">&nbsp;</td>
                  </tr>
      </cfif>
    <!------ END display the pullback checkbox END ----->

    <!---- Freight Calculator - START --->
       <cfif appSettings.getFreight_Calculator_On()>
    <tr>
             <cfif Get_Profile_Settings.Base_View eq 1>
             <td class="ln_4432">&nbsp;</td>
               <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
           <cfif variables.bDisplayContractPrice>
           <!--- 16314 [begin] --->
                   <td class="ln_4436">&nbsp;</td>
                   <!--- 16314 [end] --->
               </cfif>
               <!--- 17289 > 16314 follow up 10/14/08 [end] --->
             <td class="ln_4440">&nbsp;</td>
             <td class="ln_4441">&nbsp;</td>
            </cfif>
            <cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
             <td class="ln_4444">&nbsp;</td>
            </cfif>
            <cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
             <td class="ln_4447">&nbsp;</td>
            </cfif>
            <cfif direct_pricing eq 0>
             <td class="ln_4450">&nbsp;</td>
            </cfif>
            <CFIF ShowTPA eq 1>
             <td class="ln_4453">&nbsp;</td>
            </cfif>
             <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
             <td class="ln_4456">&nbsp;</td>
             </cfif>
         <cfif Get_Profile_Settings.View_Cost eq 1>
          <td class="ln_4459">&nbsp;</td>
         </cfif>
         <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
             <td class="ln_4462">&nbsp;</td>
        </cfif>
        <cfif Get_Profile_Settings.View_Operating_Income eq 1>
        <td class="ln_4465">&nbsp;</td>
        </cfif>
        <cfif Get_Profile_Settings.View_Operating_Income eq 1>
             <td class="ln_4468" align="left" colspan="2">Freight Estimate:</td>
             <td class="ln_4469" align="left" colspan="2"><input type="text" id="marginFreightCalc"
                name="marginFreightCalc"
          onBlur="javascript:calcFreight();"
          size="3" />%</td>
               <td class="ln_4473" align="left" colspan="2">Est. Freight $:</td>
             <td class="ln_4474" id="marginFreightCalcTarget" align="left"></td>
         <cfelse>
          <td class="ln_4476" colspan="7">&nbsp;</td>
         </cfif>
             <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
           <td class="ln_4479">&nbsp;</td>
           <td class="ln_4480">&nbsp;</td>
         </cfif>
            </tr>
             <cfif Get_Profile_Settings.Base_View eq 1>
            <tr>
             <td class="ln_4485">&nbsp;</td>
              <!--- 17289 > 16314 follow up 10/14/08 [begin] --->
          <cfif variables.bDisplayContractPrice>
          <!--- 16314 [begin] --->
                  <td class="ln_4489">&nbsp;</td>
                  <!--- 16314 [end] --->
              </cfif>
              <!--- 17289 > 16314 follow up 10/14/08 [end] --->
             <td class="ln_4493">&nbsp;</td>
             <td class="ln_4494">&nbsp;</td>
            </cfif>
            <cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
             <td class="ln_4497">&nbsp;</td>
            </cfif>
            <cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
             <td class="ln_4500">&nbsp;</td>
            </cfif>
            <cfif direct_pricing eq 0>
             <td class="ln_4503">&nbsp;</td>
            </cfif>
            <CFIF ShowTPA eq 1>
             <td class="ln_4506">&nbsp;</td>
            </cfif>
             <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
             <td class="ln_4509">&nbsp;</td>
             </cfif>
         <cfif Get_Profile_Settings.View_Cost eq 1>
          <td class="ln_4512">&nbsp;</td>
         </cfif>
        <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
             <td class="ln_4515">&nbsp;</td>
        </cfif>
        <cfif Get_Profile_Settings.View_Operating_Income eq 1>
        <td class="ln_4518">&nbsp;</td>
        </cfif>
        <cfif Get_Profile_Settings.View_Operating_Income eq 1>
                <td class="ln_4521" align="left" colspan="2">Est. Operating Margin Dollars: </td>
                <td class="ln_4522" align="left" colspan="2" id="marginDollars"></td>
                <td class="ln_4523" align="left" colspan="2">Est. Operating Margin %:</td>
                <td class="ln_4524" id="marginPercent" align="left"></td>
          <cfelse>
          <td class="ln_4526" colspan="7">&nbsp;</td>
         </cfif>
         <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
          <td class="ln_4529">&nbsp;</td>
          <td class="ln_4530">&nbsp;</td>
       </cfif>
      </tr>
       </cfif>
      <!---- Freight Calculator - END --->


    <!--- Dev Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->
    <cfif appSettings.getMarginItemsExclude()>
      <tr> <td class="ln_4539" style="border-bottom: 0px solid blue;">&nbsp;</td> </tr>
      <tr>
        <td class="ln_4541" align="left" colspan="#th_count#" id="highlight">
          <strong>
            <a href="##" onClick="toggleProdExcludeView();">
              Products Excluded From Margin
            </a>
          </strong>
        </td>
      </tr>
        <cfinclude template="layered_margin_items_exclude.cfm" />
    </cfif>
    <!--- End Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->

    <!---- NEW BUDGET DISPLAY ---->
    <cfif appSettings.getBudgetsFunctionalityOn()>
      <cfoutput>#budgetDisplayString#</cfoutput>
      <!---
      25715: Budgeting
      <cfset BudgetManager.loadBudgetLabels() />
      <cfinclude template="budget_program_select.cfm">
      --->
    </cfif>
    <!---- NEW BUDGET DISPLAY - END ---->
</cfif>
<!--- 114617 --->
      </cfoutput>

        <!--- </tbody> --->
       </table>
       </div>
</cfif>  <!--- <cfif url.verticalPNL neq ""> --->
<!----------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

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
    <cfset Below_Program_Margin = 1 />
    <cfset CannotApproveSettings = 1 />
    </cfif>
  <input type="hidden"
         name="below_program_margin"
       value="<cfoutput>#Below_Program_Margin#</cfoutput>" />
  <input type="hidden"
         name="program_margin_value"
       value="<cfoutput>#getProgramMargins.Total_OprMargin#</cfoutput>" />
  <input type="hidden"
         name="approvable_program_margin_value"
       value="<cfoutput>#Get_Profile_Settings.Max_Opr_Margin#</cfoutput>" />
  <input type="hidden"
         name="programid"
       value="<cfoutput>#url.CID#</cfoutput>" />
  <input type="hidden"
         name="ProgramIsARevision"
       value="<cfoutput>#getProgramInfo.Is_A_Revision#</cfoutput>" />
  <input type="hidden"
         name="AllowRetroRevision"
       value="<cfoutput>#getSettings.ALLOW_RETRO_REVISION#</cfoutput>" />
  <input type="hidden"
         name="MaxDuration"
       value="<cfoutput>#getSettings.max_duration#</cfoutput>" />
  <input type="hidden"
         name="Allow_Retro_Revision_Span"
       value="<cfoutput>#getSettings.Allow_Retro_Revision_Span#</cfoutput>" />
  <input type="hidden"
         name="Business_considerations" value="" />
  <input type="hidden"
         name="AgreeList"
       value="<cfoutput>#form.AgreeList#</cfoutput>" />
  <input type="hidden"
         name="ApproveList"
       value="<cfoutput>#form.ApproveList#</cfoutput>" />
  <input type="hidden"
         name="RestrictedList"
       value="<cfoutput>#form.RestrictedList#</cfoutput>" />
  <input type="hidden"
         name="preAgreeList"
       value="<cfoutput>#form.preAgreeList#</cfoutput>" />
  <input type="hidden"
         name="preApproveList"
       value="<cfoutput>#form.preApproveList#</cfoutput>" />
  <input type="hidden"
         name="preRestrictedList"
       value="<cfoutput>#form.preRestrictedList#</cfoutput>" />
  <cfif CannotApproveSettings eq 1 and ProgramAgree eq 0>
    <cfset ProgramAgree = 1 />
  </cfif>
  <input type="hidden"
         name="ProgramAgree"
       value="<cfoutput>#ProgramAgree#</cfoutput>" />
  <!--- Dev Note: KAL; 8891 --->
  <input type="hidden"
         name="userName"
       value="" />
  <input type="hidden"
         name="evalAction"
       value="" />
  <input type="hidden"
         name="notes"
       value="N/A" />
  <input type="hidden"
         name="mode"
       value="" />
  <input type="hidden"
         name="Contract_Number"
       value="" />
  <input type="hidden"
         name="NoteType"
       value="2" />
  <input type="hidden"
         name="reject"
       value="0" />
  <input type="hidden"
         name="Disagreed"
       value="0" />
</form>

<cfif ! isdefined('ProgramVolume_For_Program_Span')>
  <cfif qGetMarginUOT.Unit_Multiplier>
    <cfset ProgramVolume_For_Program_Span = (TotalProgramVolume * getProgramInfo.Program_Span) / qGetMarginUOT.Unit_Multiplier>
  <cfelse>
    <cfset ProgramVolume_For_Program_Span = 1>
  </cfif>
</cfif>

<cfif url.verticalPNL eq "">         <!---  44017  --->
<script>
function changemarginType()
{
  document.MyForm.action = "layered_approval_include.cfm?<cfoutput>CID=#URL.CID#&UoT=#url.UoT#&duplicateprogram=#duplicateprogram#</cfoutput>"
                            + <cfif isDefined("MarginCalculatedDate")> "&MarginCalculatedDate=<cfoutput>#MarginCalculatedDate#</cfoutput>" <cfelse> "" </cfif>;
  MyForm.submit();
}

function showrevisiondetails(contractid,status)
{
  NewWindow('/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id='+contractid+'&Contract_Status='+status,'ProgramRevisionDetails','1200','550','Yes', 'Yes')

}
</script>

<!--- Freight Calc Js --->
  <script type="text/javascript">
  <cfif Get_Profile_Settings.View_Operating_Income eq 1>
    function calcFreight(){
    var totalBaseSales = <cfoutput>#tempABS_BaseSales#</cfoutput>;
    var percentage = parseInt(document.all.marginFreightCalc.value);
    var totalOperatingMargin = <cfoutput>#absTotalOperIncome#</cfoutput>;
    var netSales = <cfoutput>#tempABS_NetSales#</cfoutput>;
    var calcTarget = 0;
    var marginDollars = 0;
    var marginPercentage = 0;
    if(isNaN(percentage))
    {
      document.all.marginFreightCalcTarget.innerText =  0;
      document.all.marginFreightCalc.value = 0;
    }
    else
    {
      if (percentage > 1000 || percentage < 0)
      {
        document.all.marginFreightCalc.value = 0;
      }
      else
      {
      calcTarget = parseInt((percentage * .01) * totalBaseSales);
      marginDollars = (totalOperatingMargin - calcTarget);
      marginPercentage  = ( marginDollars / netSales ) * 100.0;
      document.all.marginFreightCalcTarget.innerText =  "$" + FormatTextWithCommas(calcTarget);
      document.all.marginDollars.innerText =  "$" + FormatTextWithCommas(marginDollars);
      if (isNaN(marginPercentage) || marginDollars == 0)
      {
         document.all.marginPercent.innerText = 0 + "%";
      }
      else
      {
      document.all.marginPercent.innerText = parseInt(marginPercentage) + "%";
       }
      }
    }
  }
  </cfif>
  //function to add commas to a given string -  TODO: Put this in a .js file where it can be accessed everywhere
  function FormatTextWithCommas(oText) {
    var nf = new NumberFormat();
    nf.setNumber(oText);
    nf.setCommas(true);
    nf.setCurrency(false);
    nf.setPlaces(0);
    return nf.toFormatted()
  }
  </script>
  <!--- Dev Note: KAL; D21684: Functionality of View Margins Screen: To Toggle previous margin displays --->
  <script type="text/javascript" language="javascript">
    togglePreviousView = function(objName)
    {
      obj1 = 'previous_rate_' + objName
      obj2 = 'previous_dollar_' + objName
      obj3 = 'variance_rate_' + objName
      obj4 = 'variance_dollar_' + objName
      Effect.toggle(obj1, 'slide', { duration: .100 });
      Effect.toggle(obj2, 'slide', { duration: .100 });
      Effect.toggle(obj3, 'slide', { duration: .100 });
      Effect.toggle(obj4, 'slide', { duration: .100 });
    }
  </script>
  <!--- Dev Note: KAL; D23601: Margin Items Exclude To Toggle the display --->
  <script type="text/javascript" language="javascript">
    toggleProdExcludeView = function(){
    /* Regular JS Code */
    var cellObject = document.getElementsByTagName("tr");

    /*Loop through the "<tr>" object. Look for specific "id" (below)*/
       for(i=0;i<cellObject.length;i++)
       {
        if (cellObject[i].getAttribute('id') == 'excludeditems') {
          if (cellObject[i].style.display =='block' || cellObject[i].style.display == '')  {
            cellObject[i].style.display='none';
          }
          else{
            cellObject[i].style.display='block';
          }
        }
      }
    }
  </script>
  <script language="JavaScript" type="text/javascript" src="/script/javascript/string_functions.js"></script>

  <cf_include files="/script/javascript/table2csv.js, /script/javascript/gridviewscroll_init.js">

    <script>
      const margin_table_id = "GridView1";
      const is_debugging    = 0;
      const begin           = performance.now();
      let column_count      = 0;
      let margin_Table      = document.getElementById( margin_table_id );

      /* gather table content BEFORE gridviewscroll breaks it apart */
      let margin_table_content = $( '#' + margin_table_id ).table2CSV( { findTHEAD: 'tr:first-child', csvExclude: 'csvExclude' } );

      gridviewscroll_init( margin_table_id );

      // get the cells collection of the header row.
      let objCells = margin_Table.rows.item( 0 ).cells;
      // apply right alignment to all columns in header except the first one
      for ( let col = 1; col < objCells.length; col++ ) {
        objCells.item( col ).style.textAlign = "right";
      }
    </script>





  <cfset products_limit = val( application.util.query.get_setting("max_program_products_for_fixed_header_margin_page", 0) )>
  <!--- apply GridViewScroll only for fixed header when limit is defined in program setting and number of program products is below the limit --->
  <cfif products_limit gt 0 and getAllProductMargins.recordCount lte products_limit>
    <!--- load our handling for window resize event --->
    <cf_include files="/script/javascript/window_resize.js">

    <script>
      column_count = objCells.length;
      $( document ).ready( function() {
          gridViewScroll = new GridViewScroll( {
                                                  elementID : margin_table_id,
                                                  freezeColumn : ( column_count > 20 ? true : false ),
                                                  freezeColumnCssClass : "GridViewScrollItemFreeze",
                                                  freezeFooter : false,
                                                  freezeHeaderRowCount : 1,
                                                  freezeColumnCount : 1,
                                                  width: "99%",
                                                  height: "99%"
                                              } );

          gridViewScroll.enhance();
      } );

//114617 :: Ideal Price START
  //Select and deselect all checkboxes
  $("#SelectItems").click(function(){
    $('.BSAID_Single:checkbox').prop('checked', true);
    $('#UnselectItems').show();
    $('#SelectItems').hide();
  });
  $("#UnselectItems").click(function(){
    $('.BSAID_Single:checkbox').prop('checked', false);
    $('#UnselectItems').hide();
    $('#SelectItems').show();
  });

  $("#IdealPriceUpdate").click(function(){
    var IPChange = $('#IdealPricePlus').val();
    var count = 0 ;
    var typeCodeCount = 0;
    var Items = 0;
    var totalItems = $('input[name=ApproveList]').val();
          totalItems = totalItems.split(",").length;

      $("#GridView1_Content_Fixed input:checkbox").each(function() {
        if(this.checked){
          count = count + 1;
          // typ, id & Type Code
          IdealPriceCalculation('1', this.id, $(this).attr("typecode"));

          var itemCount = $('input[name='+$(this).attr("typecode")+']').val();
                typeCodeCount = typeCodeCount + 1

          if( itemCount == typeCodeCount){
            TypeCodeCalculation('1', $(this).attr("typecode"));
            typeCodeCount = 0;
            Items = parseFloat(Items) + parseFloat(itemCount);
            if(totalItems == Items){
              PrgSummary();
            }
          }

        }
      });
      if(! count){
        alert('Please select atleast one item.')
      }
  });

  function IdealPriceCalculation(typ, id, TypeCode){
    /*
    typ:
      1 :: Mass Apply
      0 :: Text Box
    */
            var IPChange = $('#IdealPricePlus').val();
            var IdealPrice = $('#prodid_'+id).attr('idealprice');
            var decimalPlaces = <cfoutput>#decimal_places#</cfoutput>;
            var TotalAllowance = 0;
            var TotalAllowancePercentage = 0;
            var Volume = id+'_Volume';
            var FPid = id+'_Fixed_Price';
            var FPidChange = id+'_Fixed_Price_Change';
            var Allowance = id+'_Allowance';
            var Allowance_TB = id+'_Allowance_TB';
            var AllowancePercentage = id+'_Allowance_Percentage';
            var NetSales = id+'_Net_Sales';
            var NetSales_TB = id+'_Net_Sales_TB';
            var GrossMargin = id+'_Gross_Margin';
            var GrossMargin_TB = id+'_Gross_Margin_TB';
            var ContributionMargin = id+'_Contribution_Margin';
            var ContributionMargin_TB = id+'_Contribution_Margin_TB';
            var VariableCM = id+'_Variable_Contribution_Margin';
            var VariableCM_TB = id+'_Variable_Contribution_Margin_TB';
            var OPRIncome = id+'_Operating_Income';
            var OPRIncome_TB = id+'_Operating_Income_TB';
            var OPRIncomePer = id+'_Operating_Margin_percent';
            var TradeSpend = id+'_Trade_Spent';
            var TradeSpend_TB = id+'_Trade_Spent_TB';

            //count = count + 1;
            $('#'+FPidChange).val('1');
            var FixedPrice = parseFloat($('#'+FPid).val());
            if(typ ==1){
              //CALCULATE NEW FIXED PRICE
              var NewPrice = parseFloat( (IPChange * IdealPrice)/100 )
                    NewPrice = NewPrice +  parseFloat(IdealPrice);
                    $('#'+FPid).val(NewPrice.toFixed(decimalPlaces));
            }else{
              var NewPrice = parseFloat($('#'+FPid).val());
            }
            //ALLOWANCE CALCULATIONS
            var NewAllowance = parseFloat($('#'+Allowance).attr("rer")) + parseFloat($('#'+Allowance).attr("grr")) + parseFloat($('#'+Allowance).attr("oer"))+ parseFloat($('#'+Allowance).attr("diffformulaprice"))+ parseFloat($('#'+Allowance).attr("lumpsumamount"))+ (parseFloat($('#'+Allowance).attr("basesales"))-parseFloat(NewPrice))
                  $('#'+Allowance).html('$ ' +NewAllowance.toFixed(decimalPlaces));
                  $('#'+Allowance_TB).val(NewAllowance.toFixed(decimalPlaces));

            //ALLOWANCE PERCENTAGE CALCULATIONS
            if(parseFloat($('#'+Allowance).attr("basesales")) == 0){
              var NewAllowancePercentage = 0;
            }else{
              var NewAllowancePercentage = (parseFloat(NewAllowance)/parseFloat($('#'+Allowance).attr("basesales"))) * 100;
            }
            $('#'+AllowancePercentage).html(NewAllowancePercentage.toFixed(2)+' %');

            //NET SALES CALCULATIONS
            var NewNetSales = parseFloat($('#'+Allowance).attr("basesales"))  - (parseFloat($('#'+NetSales).attr("basediscount")) + parseFloat(NewAllowance) +  parseFloat($('#'+NetSales).attr("tpaoper")) + parseFloat($('#'+NetSales).attr("tpa")) - parseFloat($('#'+NetSales).attr("pullbackamount")) ) - parseFloat($('#'+NetSales).attr("allowancesurcharges")) - parseFloat($('#'+NetSales).attr("customerfreight")) - parseFloat($('#'+NetSales).attr("otherspend"))
                  $('#'+NetSales).html('$ ' +NewNetSales.toFixed(decimalPlaces));
                  $('#'+NetSales_TB).val(NewNetSales.toFixed(decimalPlaces));

            //GROSS MARGIN CALCULATIONS
            var NewGrossMargin = NewNetSales - parseFloat($('#'+GrossMargin).attr("cost")) - parseFloat($('#'+GrossMargin).attr("shuttlefreight")) - parseFloat($('#'+GrossMargin).attr("customwarehouse"));
                  $('#'+GrossMargin).html('$ ' +NewGrossMargin.toFixed(decimalPlaces));
                  $('#'+GrossMargin_TB).val(NewGrossMargin.toFixed(decimalPlaces));

            //CONTRIBUTION MARGIN CALCULATIONS
            var NewContributionMargin = parseFloat(NewGrossMargin) - parseFloat($('#'+ContributionMargin).attr("CustomBrokerage"));
                  $('#'+ContributionMargin).html('$ ' +NewContributionMargin.toFixed(decimalPlaces));
                  $('#'+ContributionMargin_TB).val(NewContributionMargin.toFixed(decimalPlaces));

            //VARIABLE CONTRIBUTION MARGIN CALCULATIONS
            var NewVariableCM = parseFloat(NewContributionMargin) + parseFloat($('#'+VariableCM).attr("FixedCost"));
                  $('#'+VariableCM).html('$ ' +NewVariableCM.toFixed(decimalPlaces));
                  $('#'+VariableCM_TB).val(NewVariableCM.toFixed(decimalPlaces));

            //OPERATING INCOME CALCULATIONS
            var NewOperatingIncome = parseFloat(NewContributionMargin) - parseFloat($('#'+OPRIncome).attr("MapMdf")) - parseFloat($('#'+OPRIncome).attr("SGA"));
                  $('#'+OPRIncome).html('$ ' +NewOperatingIncome.toFixed(decimalPlaces));
                  $('#'+OPRIncome_TB).val(NewOperatingIncome.toFixed(decimalPlaces));

            //OPERATING INCOME PERCENTAGE CALCULATIONS
            if(<cfoutput>#appSettings.getApprovalMarginType()#</cfoutput> == 0 && <cfoutput>#appSettings.getMarginOperatingIncomePercentType()#</cfoutput> == 2) {
              if(parseFloat($('#'+Allowance).attr("basesales")) !=  0 ){
                var OperatingMargin_percent = (NewOperatingIncome /parseFloat($('#'+Allowance).attr("basesales"))) * 100.00
                if (parseFloat($('#'+Allowance).attr("basesales")) < 0 && NewOperatingIncome <0) {
                    OperatingMargin_percent = OperatingMargin_percent * -1;
                }
            }else{
              if( parseFloat($('#'+Allowance).attr("netsales")) != 0){
                var OperatingMargin_percent = (NewOperatingIncome  /parseFloat($('#'+Allowance).attr("netsales"))) * 100.00
                if (parseFloat(NewNetSales) < 0 && NewOperatingIncome <0){
                  OperatingMargin_percent = OperatingMargin_percent * -1;
                }
              }
            }
            $('#'+OPRIncomePer).html(OperatingMargin_percent.toFixed(2)+' %');
          }

            //TRADE SPEND CALCULATIONS
            var NewTradeSpend = parseFloat(NewAllowance) * parseFloat($('#'+Volume).attr("volume"));
                  $('#'+TradeSpend).html('$ ' +NewTradeSpend.toFixed(decimalPlaces));
                  $('#'+TradeSpend_TB).val(NewTradeSpend.toFixed(decimalPlaces));

                if(! typ){
                  TypeCodeCalculation(typ, TypeCode);
                }
  }

  function TypeCodeCalculation(typ, TypeCode){
    var decimalPlaces = <cfoutput>#decimal_places#</cfoutput>;
        //TYPE CODE FORM FIELDS
    var TypeCodeAllowance = TypeCode+'_TypeCode_Allowance';
    var TypeCodeAllowancePer = TypeCode+'_TypeCode_AllowancePer';
    var TypeCodeNetSales = TypeCode+'_TypeCode_Net_Sales';
    var TypeCodeGrossMargin = TypeCode+'_TypeCode_Gross_Margin';
    var TypeCodeContributionMargin = TypeCode+'_TypeCode_Contribution_Margin';
    var TypeCodeVariableContributionMargin = TypeCode+'_TypeCode_Variable_Contribution_Margin';
    var TypeCodeOprIncome = TypeCode+'_TypeCode_Opr_Income';
    var TypeCodeOprMarginPercentage = TypeCode+'_TypeCode_Opr_Margin_Percentage';
    var TypeCodeTradeSpend = TypeCode+'_TypeCode_Trade_Spend';


    var TCItemCount = $('input[name='+TypeCode+']').val();
    var TotalAllowance = 0;
    var TotalAllowancePercentage = 0;
    var TotalVolume = 0;
    var TotalLSAmount = 0;
    var TotalBaseSales = 0;
    var TotalNetSales = 0;
    var TotalGrossMargin = 0;
    var TotalContributionMargin = 0;
    var TotalVariableContributionMargin = 0;
    var TotalOperationgIncome = 0;
    var TotalOperationgIncomePer=0;
    var OIP = 0;
    var TotalTradeSpend = 0;

      for(i=1;i<=TCItemCount;i++){
        var id= TypeCode+'_'+i;
        var BSATc = $('#'+id).attr("tcid");

      if(BSATc == TypeCode){
          var BSAID = $('#'+id).attr("bsaid");
          var Allowance = BSAID+'_Allowance_TB'; // WE USE TEXTBOX TO ASSIGN AND RETRIVE NEW ALLOWANCE WHICH CALCULATED
          var NetSales = BSAID+'_Net_Sales_TB';
          var GrossMargin = BSAID+'_Gross_Margin_TB';
          var ContributionMargin = BSAID+'_Contribution_Margin_TB';
          var VariableCM = BSAID+'_Variable_Contribution_Margin_TB';
          var OPRIncome = BSAID+'_Operating_Income_TB';
          var OPRIncomePer = BSAID+'_Operating_Margin_percent';
          var TradeSpend = BSAID+'_Trade_Spent_TB';
          var Volume = parseFloat($('#'+BSAID+'_Volume').attr("Volume"));
          var BaseSales = parseFloat($('#'+BSAID+'_Allowance').attr("basesales"));
          var NetSales = parseFloat($('#'+BSAID+'_Allowance').attr("netsales"));

          TotalVolume = parseFloat(TotalVolume) + Volume;

      //TYPE CODE ALLOWANCE CALCULATIONS
      //(ISNULL(SUM((LumpsumAmount+Item_Allowance)*Product_Program_Volume),0) / SUM(Product_Program_Volume))
        TotalAllowance =	parseFloat(TotalAllowance) + (parseFloat( $('#'+BSAID+'_Allowance').attr("lumpsumamount") ) + parseFloat($('#'+Allowance).val())) * Volume;

        //TYPE CODE ALLOWANCE PERCENTAGE CALCULATIONS
        //Total_Allowance_Percent = (TotalAllowance/Total_Base_Sales) * 100
        TotalBaseSales = parseFloat(TotalBaseSales) + ( BaseSales * Volume);

        //TYPE CODE NET SALES CALCULATIONS
        //ISNULL(SUM(Product_Program_Volume * Net_Sales),0)/SUM(Product_Program_Volume)
        TotalNetSales = parseFloat(TotalNetSales)  + ( Volume * NetSales )

        //TYPE CODE GROSS MARGIN CALCULATIONS
        //SUM(GrossMargin * Volume),0) / SUM(Volume)
        TotalGrossMargin = parseFloat(TotalGrossMargin) + ( Volume * parseFloat( $('#'+GrossMargin).val() ) );

        //TYPE CODE CONTRIBUTION MARGIN CALCULATIONS
        //SUM(ContributionMargin * Volume),0) / SUM(Volume)
        TotalContributionMargin = parseFloat(TotalContributionMargin) + ( Volume * parseFloat( $('#'+ContributionMargin).val() ) );

        //TYPE CODE VARIABLE CONTRIBUTION MARGIN CALCULATIONS
        //SUM(VariableCM * Volume),0) / SUM(Volume)
        TotalVariableContributionMargin = parseFloat(TotalVariableContributionMargin) + ( Volume * parseFloat( $('#'+VariableCM).val() ) );

        //TYPE CODE OPERATING INCOME CALCULATIONS
        //ISNULL(SUM(Product_Program_Volume*Operating_Income),0)/SUM(Product_Program_Volume)
        TotalOperationgIncome = parseFloat(TotalOperationgIncome) + (Volume * parseFloat($('#'+OPRIncome).val()));

        //TYPE CODE OPERATING INCOME PERCENTAGE CALCULATIONS
        if( <cfoutput>#application.appSettingsGet.getMarginOperatingIncomePercentType()#</cfoutput> == 2){
          if( BaseSales == 0 || Volume == 0 ){
            TotalOperationgIncomePer =  parseFloat(TotalOperationgIncomePer) + 0;
          }else{
            OIP = OIP + ( (Volume * parseFloat($('#'+OPRIncome).val()) ) / (Volume * BaseSales) );
            TotalOperationgIncomePer = parseFloat(TotalOperationgIncomePer) + OIP
          }
        }else{
          if( NetSales == 0 || Volume == 0 ){
            TotalOperationgIncomePer =  parseFloat(TotalOperationgIncomePer) + 0;
          }else{
            OIP = OIP + ( ( Volume * parseFloat($('#'+OPRIncome).val())) / (Volume * NetSales) );
            TotalOperationgIncomePer = parseFloat(TotalOperationgIncomePer) + OIP;
          }
        }

        //TYPE CODE TRADE SPEND CALCULATIONS
        // TotalTradeSpend = Total_Item_Allowance * round(Total_Product_Program_Volume)>
        TotalTradeSpend = parseFloat(TotalTradeSpend) + ( parseFloat(TotalAllowance) * Volume );
    }
  }
  //TO PREVENT DIVISON BY 0 ISSUE
  if(! TotalVolume){
    TotalVolume = 1;
  }
  if(! TotalBaseSales){
    TotalBaseSales = 1;
  }
    //TYPE CODE ALLOWANCE UPDATE
    $('#'+TypeCodeAllowance).html('$ ' +(TotalAllowance/TotalVolume).toFixed(decimalPlaces));
    //TYPE CODE ALLOWANCE PERCENTAGE  UPDATE
    $('#'+TypeCodeAllowancePer).html(((TotalAllowance/TotalBaseSales)*100).toFixed(2)+' %');
    //TYPE CODE NET SALES UPDATE
    $('#'+TypeCodeNetSales).html('$ ' +(TotalNetSales/TotalVolume).toFixed(decimalPlaces));
    //TYPE CODE GROSS MARGIN UPDATE
    $('#'+TypeCodeGrossMargin).html('$ ' +(TotalGrossMargin/TotalVolume).toFixed(decimalPlaces));
    //TYPE CODE CONTRIBUTION MARGIN UPDATE
    $('#'+TypeCodeContributionMargin).html('$ ' +(TotalContributionMargin/TotalVolume).toFixed(decimalPlaces));
    //TYPE CODE VARIABLE CONTRIBUTION MARGIN UPDATE
    $('#'+TypeCodeVariableContributionMargin).html('$ ' +(TotalVariableContributionMargin/TotalVolume).toFixed(decimalPlaces));
    //TYPE CODE OPERATING INCOME UPDATE
    $('#'+TypeCodeOprIncome).html('$ ' +(TotalOperationgIncome/TotalVolume).toFixed(decimalPlaces));
    //TYPE CODE OPERATING INCOME PERCENTAGE  UPDATE
    $('#'+TypeCodeOprMarginPercentage).html((TotalOperationgIncomePer).toFixed(2)+' %');
    //TYPE CODE TRADE SPEND UPDATE
    $('#'+TypeCodeTradeSpend).html('$ ' +TotalTradeSpend.toFixed(decimalPlaces));
    if(!typ){
      PrgSummary();
    }
  }

function PrgSummary() {
  var PrgRateSummary_Allowance = 0;
  var PrgRateSummary_Net_Sales = 0;
  var PrgRateSummary_Gross_Margin = 0;
  var PrgRateSummary_Contribution_Margin = 0;
  var PrgRateSummary_Variable_Contribution_Margin = 0;
  var PrgRateSummary_Operating_Income = 0;
  var PrgRateSummary_Operating_IncomePer = 0

  var PrgABSummary_Allowance = 0;
  var PrgABSummary_Net_Sales = 0;
  var PrgABSummary_Gross_Margin = 0;
  var PrgABSummary_Contribution_Margin = 0;
  var PrgABSummary_Variable_Contribution_Margin = 0;
  var PrgABSummary_Operating_Income = 0;
  var PrgABSummary_Operating_IncomePer = 0

  var decimalPlaces = <cfoutput>#decimal_places#</cfoutput>;
  var TotalProgramVolume = parseFloat($('#PrgRateSummary_Allowance').attr("TotalProgramVolume"));
  var Lumpsum_Amount = parseFloat($('#PrgRateSummary_Allowance').attr("LumpsumAmount"));
   var TotalBaseSale = parseFloat($('#PrgRateSummary_Allowance').attr("TotalBaseSales"));

  var addExtra = 0;
  var addExtra1 = 0;
  var PrgSummary_Operating_Margin_percent= 0;
  var OIP = 0;
  var PrgSummary_Trade_Spent = 0;

  $('#GridView1 > tbody  > tr.GridViewScrollItem').each(function(index, tr) {
      var id = this.id;
      var TypeCode = $('#'+id).attr("tcid");
      var bsaid = $('#'+id).attr("bsaid");
      var Volume = parseFloat($('#'+bsaid+'_Volume').attr("Volume"));

if(TypeCode != undefined){
      if(<cfoutput>#application.appSettingsGet.getApprovalMarginType()#</cfoutput>  == 2){
        PrgRateSummary_Allowance = PrgRateSummary_Allowance + (Volume * parseFloat($('#'+bsaid+'_Allowance').attr("AnnualizedAllowance")) );
      }else{
        PrgRateSummary_Allowance = PrgRateSummary_Allowance + (Volume * parseFloat($('#'+bsaid+'_Allowance').attr("ItemAllowance")) );
      }

      PrgRateSummary_Net_Sales = PrgRateSummary_Net_Sales + (Volume * parseFloat($('#'+bsaid+'_Allowance').attr("netsales")) );
      PrgRateSummary_Gross_Margin = PrgRateSummary_Gross_Margin + (Volume * parseFloat( $('#'+bsaid+'_Gross_Margin_TB').val() ) );
      PrgRateSummary_Contribution_Margin = PrgRateSummary_Contribution_Margin + (Volume * parseFloat( $('#'+bsaid+'_Contribution_Margin_TB').val() ) );
      PrgRateSummary_Variable_Contribution_Margin = PrgRateSummary_Variable_Contribution_Margin + (Volume * parseFloat( $('#'+bsaid+'_Variable_Contribution_Margin_TB').val() ) );
      PrgRateSummary_Operating_Income = PrgRateSummary_Operating_Income + (Volume * parseFloat($('#'+bsaid+'_Operating_Income_TB').val()));

      if( <cfoutput>#application.appSettingsGet.getMarginOperatingIncomePercentType()#</cfoutput> == 2){
          if($('#'+bsaid+'_Allowance').attr("basesales") == 0){
            PrgSummary_Operating_Margin_percent =  parseFloat(PrgSummary_Operating_Margin_percent) + 0;
          }else{
            OIP = OIP + ( (Volume * parseFloat($('#'+bsaid+'_Operating_Income_TB').val()) ) / (Volume *parseFloat($('#'+bsaid+'_Allowance').attr("basesales"))) );
            PrgSummary_Operating_Margin_percent = parseFloat(PrgSummary_Operating_Margin_percent) + OIP
          }
        }else{
          if($('#'+bsaid+'_Allowance').attr("netsales") == 0){
            PrgSummary_Operating_Margin_percent =  parseFloat(PrgSummary_Operating_Margin_percent) + 0;
          }else{
            OIP = OIP + ( ( Volume * parseFloat($('#'+bsaid+'_Operating_Income_TB').val())) / (Volume *parseFloat($('#'+bsaid+'_Allowance').attr("netsales"))) );
            PrgSummary_Operating_Margin_percent = parseFloat(PrgSummary_Operating_Margin_percent) + OIP;
          }
        }
      PrgSummary_Trade_Spent = PrgSummary_Trade_Spent + ( parseFloat(PrgRateSummary_Allowance) *Volume ); ///???? CHECK WITH DEEPA REGARDING VARIABLE "PrgRateSummary_Allowance"
      }
  });
  // TO PREVENT DIVISION BY 0 ISSUE
if(! TotalBaseSale){
  TotalBaseSale = 1;
}
if(! TotalProgramVolume){
  TotalProgramVolume= 1;
}
        //PROGRAM SUMMARY ALLOWANCE CALCULATIONS
        //RATE
        if (TotalProgramVolume != "" && TotalProgramVolume != 0){
          var addExtra = Lumpsum_Amount / parseFloat(TotalProgramVolume);
        }
        //ABS
        if (<cfoutput>#ProgramVolume_For_Program_Span#</cfoutput> != "" && <cfoutput>#ProgramVolume_For_Program_Span#</cfoutput> != 0){
          var addExtra1 = Lumpsum_Amount / <cfoutput>#ProgramVolume_For_Program_Span#</cfoutput>;
        }

        if(<cfoutput>#form.Margin_Type# == 1 || #form.margin_type# == 3</cfoutput>){
          PrgRateSummary_Allowance = ( (parseFloat(PrgRateSummary_Allowance)  + parseFloat(addExtra)) /  parseFloat(TotalProgramVolume)  ) ;
          PrgABSummary_Allowance = ( ( parseFloat(PrgABSummary_Allowance)   +  parseFloat(addExtra)) * parseFloat(TotalProgramVolume)  )
        }else{
          PrgRateSummary_Allowance =  parseFloat(PrgRateSummary_Allowance) / parseFloat(TotalProgramVolume)  ;
          PrgABSummary_Allowance = (parseFloat(PrgABSummary_Allowance)  * parseFloat(TotalProgramVolume)  );
        }

        $('#PrgRateSummary_Allowance').html('$ ' +PrgRateSummary_Allowance.toFixed(decimalPlaces));
        $('#PrgABSummary_Allowance').html('$ ' +PrgABSummary_Allowance.toFixed(decimalPlaces));

        $('#PrgRateSummary_Allowance_Per').html(((PrgRateSummary_Allowance/TotalBaseSale) * 100).toFixed(2)+ ' %');

        $('#PrgRateSummary_Net_Sales').html('$ ' +(PrgRateSummary_Net_Sales / TotalProgramVolume ).toFixed(decimalPlaces));
        $('#PrgABSummary_Net_Sales').html('$ ' +(PrgRateSummary_Net_Sales * TotalProgramVolume ).toFixed(decimalPlaces));

        $('#PrgRateSummary_Gross_Margin').html('$ ' +(PrgRateSummary_Gross_Margin / TotalProgramVolume ).toFixed(decimalPlaces) );
        $('#PrgABSummary_Gross_Margin').html('$ ' +(PrgRateSummary_Gross_Margin * TotalProgramVolume ).toFixed(decimalPlaces) );

        $('#PrgRateSummary_Contribution_Margin').html('$ ' +(PrgRateSummary_Contribution_Margin / TotalProgramVolume ).toFixed(decimalPlaces) );
        $('#PrgABSummary_Contribution_Margin').html('$ ' +(PrgABSummary_Contribution_Margin * TotalProgramVolume ).toFixed(decimalPlaces) );

        $('#PrgRateSummary_Variable_Contribution_Margin').html('$ ' +(PrgRateSummary_Variable_Contribution_Margin / TotalProgramVolume ).toFixed(decimalPlaces) );
        $('#PrgABSummary_Variable_Contribution_Margin').html('$ ' +(PrgABSummary_Variable_Contribution_Margin * TotalProgramVolume ).toFixed(decimalPlaces) );

        $('#PrgRateSummary_Operating_Income').html('$ ' +PrgRateSummary_Operating_Income.toFixed(decimalPlaces) );
        $('#PrgABSummary_Operating_Income').html('$ ' +(PrgABSummary_Operating_Income * TotalProgramVolume ).toFixed(decimalPlaces) );

        if( <cfoutput>#application.appSettingsGet.getMarginOperatingIncomePercentType()#</cfoutput> == 2){/// Use Base Sales
          PrgRateSummary_Operating_IncomePer = ( parseFloat(TotalProgramVolume) * parseFloat(PrgRateSummary_Operating_Income) / parseFloat(TotalProgramVolume) * parseFloat(TotalBaseSale) )*100;
        }else{
          PrgRateSummary_Operating_IncomePer = ( parseFloat(TotalProgramVolume) * parseFloat(PrgRateSummary_Operating_Income) / parseFloat(TotalProgramVolume) * parseFloat(PrgRateSummary_Net_Sales) )*100;
        }
        $('#PrgRateSummary_Operating_IncomePer').html(PrgRateSummary_Operating_IncomePer.toFixed(2) +' %' );
}
//114617 :: Ideal Price END
    </script>
  </cfif>

<!--- End Freight Calc Js --->
</cfif>


<cfset stMassApproval.bProgramFinalApprove = bProgramFinalApprove />
