<!--
  * ====================================================================================================
  *    @File: \common_Files\contracts\horizontalpnl_hm_udf.cfm
  *  @Author: Chris Nguyen
  *    @Date: January 2021
  *
  * @Remarks: Render horizontal P&L for Huhtamaki
  *
  *
  *
  *
  * ====================================================================================================
 -->

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

<cfset UOMdisplay = 'CS'>
<cfsavecontent variable="body_content">


<cfoutput>
<span id="approval_consideration">#variables.approval_consideration.getProgramText( getProgramInfo.contract_main_id )#</span>

<cfif isDefined("ProgramIsARevision") AND ProgramIsARevision NEQ 0>
    <div style="float:left;margin-right:80px;">*** NOTE: This Is A Revision Of An Existing Program ***<br></div>
</cfif>
</cfoutput>

<cfscript>
   // qCostDetail = get_cost_detail( getProgramInfo.contract_main_id );
    variables.bDisplayContractPrice = 0;

    col = {};

    // set up columns array to display based on profile settings
    // this visible_columns controls the columns displayed on the page
    // visible_columns array has the structure keys mapped to the displaying values

    visible_columns = [ "Description" ];

    if (Get_Profile_Settings.Base_View eq 1) {
        visible_columns.append( "Requested_CS_Volume" );
        visible_columns.append( "Requested_Price_CS" );
        visible_columns.append( "Price_List_CS" );

        if (appsettings.getDisplayCashDiscountMargin() eq 1) {
            visible_columns.append( "Cash_Disc" );
        }

        if (direct_pricing eq 0) {
            visible_columns.append( "Other_Allowances" );
        }

        visible_columns.append( "Redi" );

        if (ShowTPA eq 1) {
            visible_columns.append( "TPA" );
        }

        visible_columns.append( "Net_Sales_CS" );
        visible_columns.append( "VC_CS" );
        visible_columns.append( "CM_CS" );
    }

    visible_columns.append( "CM_Percent" );
    visible_columns.append( "POH_CS" );
    visible_columns.append( "GP_CS" );
    visible_columns.append( "GP_Percent" );


    if (getProgramInfo.Contract_Status_Type_IDX eq 2) {
        visible_columns.append( "CheckBox_1" );
        visible_columns.append( "Approve_Agree" );
        visible_columns.append( "nbsp_1" );
    }


    // set up column headers for ALL potential columns
    columns_header = { Description: "Description<br>&nbsp;"
                    ,Requested_CS_Volume: "Requested<br>CS Volume"
                    ,Requested_Price_CS: "Requested<br>Price / CS"
                    ,Price_List_CS: "Price<br>List / CS"
                    ,Cash_Disc: "Cash Disc."
                    ,Other_Allowances: "Other Allowances"
                    ,Redi: "Redi"
                    ,TPA: "TPA"
                    ,Net_Sales_CS: "Net Sales / CS"
                    ,VC_CS: "VC / CS"
                    ,CM_CS: "CM $ / CS"
                    ,CM_Percent: "CM %"
                    ,POH_CS: "POH / CS"
                    ,GP_CS: "GP $ / CS"
                    ,GP_Percent: "GP %"
                    ,CheckBox_1: '<input type="checkbox" value="1" name="checkall" checked>'
                    ,Approve_Agree: "Approve<br>/ Agree"
                    ,nbsp_1: "&nbsp;"
                    };


    // this is the empty row with ALL potential structure keys
    empty_row = { Description: ''
                        ,Requested_CS_Volume: ''
                        ,Requested_Price_CS: ''
                        ,Price_List_CS: ''
                        ,Cash_Disc: ''
                        ,Other_Allowances: ''
                        ,Redi: ''
                        ,TPA: ''
                        ,Net_Sales_CS: ''
                        ,VC_CS: ''
                        ,CM_CS: ''
                        ,CM_Percent: ''
                        ,POH_CS: ''
                        ,GP_CS: ''
                        ,GP_Percent: ''
                        ,CheckBox_1: ''
                        ,Approve_Agree: ''
                        ,nbsp_1: "&nbsp;"
                        };
</cfscript>

<cf_include files="/script/javascript/gridviewscroll/1.0/gridviewscroll.css">

<style>
    input[type=radio] {
        position: relative;
        top: 2px;
    }
    input.action[type=checkbox] {
        top: 0;
    }
    body.dhxwins_vp_dhx_skyblue {
        overflow: auto;
    }
    tr.GridViewScrollHeader th
    ,tr.GridViewScrollItem td {
        text-align: right;
    }
    tr.GridViewScrollItem TD.type-code {
        text-align: right;
        font-weight: bold;
    }
    tr.GridViewScrollHeader th:first-child
    ,tr.GridViewScrollItem td:first-child
    ,tr.GridViewScrollItem TD.type-code:first-child {
        text-align: left;
    }
    tr.GridViewScrollItemFreeze td.type-code {
        font-weight: bold;
    }
    td.spacer {
        background-color: #FFEDD2 !important;
    }
</style>
<table cellspacing="0" id="GridView1" style="width:100%;border-collapse:collapse;">
    <tr class="GridViewScrollHeader">
        <cfoutput>
            <cfloop array="#visible_columns#" item="column_name">
                <!--- set up to ignore some columns from cvs export --->
                <cfset csvExclude = arrayFindNoCase(["CheckBox_1", "approve_agree", "nbsp_1"], column_name )
                                        ? "class='csvExclude'"
                                        : ''>
                <th #csvExclude#>#columns_header[ column_name ]#</th>
            </cfloop>
        </cfoutput>
    </tr>

    <tr class="GridViewScrollItem" style="line-height: 1px;" id="spacer">
        <cfloop array="#visible_columns#" item="column_name">
                <td class="spacer">&nbsp;</td>
        </cfloop>
    </tr>

    <cfset   count          = 0>
    <cfset   OuterLoopcount = 1>

    <cfquery name="getProductMarginCount" dbtype="query">
        SELECT COUNT(*) As ProductMarginCount
        FROM getAllProductMargins
        GROUP BY Type_Code_Desc_ID
    </cfquery>

    <cfset ProductMarginCount = getProductMarginCount.Recordcount>

    <cfif appSettings.getMarginItemsExclude()>
        <cfquery NAME="getExcludedProductMarginCount" DBTYPE="query">
            SELECT COUNT(*) As ExcludedProductMarginCount
            FROM getAllExcludedProductMargins
            GROUP BY Type_Code_Desc_ID
        </cfquery>
        <cfset ExcludedProductMarginCount = getExcludedProductMarginCount.Recordcount>
    </cfif>



    <!--- Dev Note: KAL; 9/13/2010; D23601: Margin display for regualar items --->
    <!--------------------------------------------------------------------------->
    <!--- Products main loop group by type code - start ------------------------->
    <!--------------------------------------------------------------------------->
    <!--- Get the entire data from the "Program_Type_Code_Approval_Info" table for this program.
    This query can be used as a "Query of Query" below.
    --->
    <cfquery name="getTypeCodeApprovalInfo" datasource="#application.datasource#">
        /*** Common_Files\contracts\horizontalpnl_hm_udf.cfm - around line 267 ***/
        select tbl1.Type_code_Desc_ID,tbl1.Product_ID,IsNull(tbl1.Approve,0) As Approve, IsNull(tbl1.Agree,0) As Agree
                ,tbl1.User_ID, IsNull(tbl1.System_Agreement, 0) As System_Agreement,_Users.Name_Last,_Users.Name_First
        from Program_Type_Code_Approval_Info tbl1
        LEFT JOIN  _Users
        ON _Users.user_id = tbl1.User_Id
        and _Users.deleted = 0
        where program_id = #contract_main_id#
        and tbl1.deleted = 0
    </cfquery>
    <cfoutput query="getAllProductMargins">
       <!---  <cfoutput> --->
        <!--- mass approve --->
        <cfset itemCheckBoxDisabled = 0>

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
<cfquery name="getGroupvalues" dbtype="query">
            select * from getAllGroupMargins
            where Type_Code_Desc_Id = '#getAllProductMargins.Type_Code_Desc_Id#'
        </cfquery>
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

        <cfset groupTargetCaseRateUOM = Target_Case_Rate_UOM>
        <cfset groupTargetCaseRate    = Target_Case_Rate>
        <cfset groupTargetLBRate      = Target_LB_Rate>

        <!--- Dev Note: KAL; D20537: Display margin as trade percent --->
        <cfif appSettings.getApprovalMarginType() eq 1>
            <!--- check if the group margin is within limits, if not they cannot approve items either --->
            <cfif getGroupvalues.Total_Trade_Percent GT groupapprovalmargin  AND Trim(getGroupvalues.Group_ID_Margin) NEQ "*">
                <cfset CannotApproveGroupMargin = 1>
                <cfset CannotApproveItemMargin  = 1>
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
        <cfset groupApprovalMarginListPrice = 0>
        <cfif trim(getGroupvalues.Group_ID_List_Price) NEQ "*" and trim(getGroupvalues.Group_ID_List_Price) NEQ "">
            <cfset groupApprovalMarginListPrice = Target_Margin_ListPrice + ((Target_Margin_ListPrice * getGroupvalues.Group_ID_List_Price)/100)>
        <cfelse>
            <cfset groupApprovalMarginListPrice = "*">
        </cfif>

        <cfset Total_Allowance_Percent = 100>
        <cfif appSettings.getApprovalMarginType() eq 2>
            <cfset Total_Item_Allowance_Display_Value = getGroupvalues.Total_Item_Allowance_Annualized>
        <cfelse>
            <cfset Total_Item_Allowance_Display_Value = getGroupvalues.Total_Item_Allowance>
        </cfif>

        <cfif Total_Item_Allowance_Display_Value eq 0 OR getGroupvalues.Total_Base_Sales eq 0>
            <cfset Total_Allowance_Percent = 100>
        <cfelseif Total_Item_Allowance_Display_Value LT 0>
            <cfset Total_Allowance_Percent = 0>
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

        <cfif getGroupvalues.Group_ID_Approval eq 0>
            <cfset CannotApproveGroupMargin = 1>
            <cfset disablecheckbox          = "disabled">
            <cfset itemCheckBoxDisabled     = 1>
            <cfset temp                     = ArrayAppend(messageArray, "You cannot approve #Type_Code_Desc#")>
            <cfset grouptrbgcolor           = "##d3d3d3">
            <cfset itemtrbgcolor            = "##d3d3d3">
            <cfset form.RestrictedList      = listAppend(form.RestrictedList,BSA_Foodservice_Items_Master_Id ) >
        </cfif>



        <!------------------------------------------------------------------------------------------------------------>
        <!--- Outputs the individual items  -------------------------------------------------------------------------->
        <!------------------------------------------------------------------------------------------------------------>
        <cfset render_horizontal_item()>

        <!----------------------------------------------------------------------------------------------------------->
        <!--- Type Code Groups -------------------------------------------------------------------------------------->
        <!----------------------------------------------------------------------------------------------------------->
       <!---  <cfset render_horizontal_type_code()> --->

<!---         <cfif 0>
            <tr class="GridViewScrollItem">
                <td colspan="#(1 + arrayLen(visible_columns))#">+&nbsp;+</td>
            </tr>
        </cfif> --->

        <cfset CannotApproveGroupMargin = 0>
        <cfset disablecheckbox          = "">
        <cfset grouptrbgcolor           = "CCFFCC">
        <cfset itemtrbgcolor            = "f4f4f4">
<!---         </cfoutput> --->
    </cfoutput>		<!--- <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID"> --->

    <cfset colCount = 0>
    <cfoutput>
    <cfif 1>
        <tr class="GridViewScrollItem">
            <td style="background-color: ##ffce84;font-weight: bold" colspan="#(1 + arrayLen(visible_columns))#">#qGetMarginUOT.UOT_Desc# Summary</td>
        </tr>

        <cfset OriginalTotalProgramVolume = TotalProgramVolume>

 <!------------------------------------
                                        COMMENTED OUT CUSTOM RFP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~        <!------------------------------------------------------------------------------------------------------------------->
        <!------ Annual/Program Summary : Rate / UOM START ------------------------------------------------------------------>
        <!------------------------------------------------------------------------------------------------------------------->
        <cfset displayUOM = totalprogramvolumeUOM>
        <cfset qProgramSummaryMargins = getProgramMargins>
        <cfinclude template="layered_margin_program_rate_summary_hm.cfm">

        <!--------------------------------------------------------------------------------------------------->
        <!--- display additional summary line for cs/lb if annual spending rate approval app switch is ON --->
        <!--------------------------------------------------------------------------------------------------->

        <cfif appSettings.getApprovalMarginType() eq 2>
            <cfif form.Margin_Type eq 1><!--- case --->
                <!--- Display pound --->
                <cfset displayUOM = "LB">
                <cfset qProgramSummaryMargins = ApprovalProgramManager.getProgramMargins(contract_main_id, 3, "#margin_version#")>
            <cfelse><!--- pound --->
                <!--- Display case --->
                <cfset displayUOM = "CS">
                <cfset qProgramSummaryMargins = ApprovalProgramManager.getProgramMargins(contract_main_id, 1, "#margin_version#")>
            </cfif>
            <cfinclude template="layered_margin_program_rate_summary_hm.cfm">
        </cfif>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                         COMMENTED OUT CUSTOM RFP   --------------------------------------------------------->

        <!------------------------------------------------------------------------------------------------------------------->
        <!------ Annual/Program Summary : Rate / UOM end -------------------------------------------------------------------->
        <!------------------------------------------------------------------------------------------------------------------->
<!--- <cfset render_horizontal_absolute()> --->

<!--- <cfset render_horizontal_program_summary()> --->

        <!---   Dev Note: KAL; D21684: Functionality of View Margins Screen
            Code from this section is moved to separate files for code reusability and ease of development purposes.
            Previous Version - Annual/Program Summary: Code is moved to layered_margin_parent_program_summary.cfm
            Margin Variance: Code is moved to layered_margin_parent_program_variance.cfm.
            First the code was moved and checked in and then changes were made to the code.
        --->


 <!----------------------------------
                                        COMMENTED OUT CUSTOM RFP
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        <cfif Program_Is_A_Revision AND displayPreviousVersionMargin>
            <!--- *** Previous Program Margins - Current Date -- Start *** --->

            <!--- variable to set which margin_version; used in layered_margin_parent_program_summary.cfm --->
            <cfset margin_version = "current">

            <!--- Previous Program Margins Current Date --->
            <cfset getPgmPrevVerMargins_Current = ApprovalProgramManager.getProgramMargins(getProgramInfo.Revision_of_Contract_Main_ID, form.Margin_Type, "current")>

            <!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg START --->
            <cfif getPgmPrevVerMargins_Current.recordcount>
                <!--- set previous margin to this variable as we use this variable in the included templates --->
                <cfset getProgramPreviousVersionMargins = getPgmPrevVerMargins_Current>

                <cfset TotalProgramPreviousVersionVolume = getProgramPreviousVersionMargins.totalprogramvolume>
                <cfset PreviousVersion_program_spend = Val(getProgramPreviousVersionInfo.program_spend)>
                <cfset PreviousVersion_program_spend_in_margin_uot = Val(getProgramPreviousVersionInfo.program_spend_in_margin_uot)>
                <cfset PreviousVersion_Margin_Calculated_Date = ApprovalProgramManager.getMarginCalculatedDate(getProgramInfo.Revision_of_Contract_Main_ID, "current")>

                <!------ Previous Version - Annual/Program Summary : Rate/UOM & Absolute $ ----->
                <cfinclude template="layered_margin_parent_program_summary.cfm">

                <!------ Previous Version - Margin Variance ----->
                <cfinclude template="layered_margin_parent_program_variance.cfm">
            </cfif>
            <!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg END --->
            <!--- *** Previous Program Margins - Current Date -- End *** --->

            <!--- **** Previous Program Approved Margins -- Start **** --->
            <!--- variable to set which margin_version; used in layered_margin_parent_program_summary.cfm --->
            <cfset margin_version = "approved">

            <!--- Previous Program Approved Margins --->
            <cfset getPgmPrevVerMargins_Approved = ApprovalProgramManager.getProgramMargins(getProgramInfo.Revision_of_Contract_Main_ID, form.Margin_Type, "approved")>

            <!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg START --->
            <cfif getPgmPrevVerMargins_Approved.recordcount>
                <!--- set previous margin to this variable as we use this variable in the included templates --->
                <cfset getProgramPreviousVersionMargins = getPgmPrevVerMargins_Approved>

                <cfset TotalProgramPreviousVersionVolume = getProgramPreviousVersionMargins.totalprogramvolume>
                <cfset PreviousVersion_program_spend = Val(getProgramPreviousVersionInfo.program_spend)>
                <cfset PreviousVersion_program_spend_in_margin_uot = Val(getProgramPreviousVersionInfo.program_spend_in_margin_uot)>
                <cfset PreviousVersion_Margin_Calculated_Date = ApprovalProgramManager.getMarginCalculatedDate(getProgramInfo.Revision_of_Contract_Main_ID, "approved")>

                <!------ Previous Version - Annual/Program Summary : Rate/UOM & Absolute $ ----->
                <cfinclude template="layered_margin_parent_program_summary.cfm">

                <!------ Previous Version - Margin Variance ----->
                <cfinclude template="layered_margin_parent_program_variance.cfm">
            </cfif>
            <!--- D37324 :: Event error 'The value ' cannot be converted to a number' creating prg END --->
            <!--- **** Previous Program Approved Margins -- Start **** --->
        </cfif>

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                         COMMENTED OUT CUSTOM RFP       ---------------------------------------->


        <cfif CannotApproveSettings eq 1>
            <cfset button_label = "Agree">
        </cfif>
        <cfif button_label eq "Approve">
            <cfset bProgramFinalApprove = 1><!------ this var should be set only when either all product are approved, or the current user can approve all the product left to approve ----->
        </cfif>

        <!------ display the pullback checkbox ----->
        <cfif bPullbackAvailable>
            <!------
            Different possible scenario
            - pullback already approved
            - pullback not approved and user do not have approval right for this template
            - pullback not approved and user do have approval right for this template
            ----->

            <cfset pullbackBgColor = "gray">
            <cfset pullbackCheckDisabled = " disabled">
            <cfset pullbackCheckChecked = "">
            <cfif bUserCanApprovePullbackForThisPgm>
                <cfset pullbackBgColor = "ffdead">
                <cfset pullbackCheckDisabled = "">
            </cfif>
            <cfif bPullbackApproved>
                <cfset pullbackCheckChecked = " checked">
                <cfset pullbackCheckDisabled = " disabled">
            </cfif>

            <!------ If pullback not yet approved and needs approval ----->
            <cfif bPullbackAvailable AND NOT bPullbackApproved>
                <cfif bUserCanApprovePullbackForThisPgm eq 1>
                    <cfset bApprovingPullbackApprovesProgram = bProgramFinalApprove><!------ this var should be set only when either all product are approved, or the current user can approve all the product left to approve ----->
                </cfif>
            </cfif>
            <!--- <tr> --->
            <tr class="GridViewScrollItem">
                <td>&nbsp;</td>
            </tr>
            <!--- <tr> --->
            <tr class="GridViewScrollItem">
                <td bgcolor="#pullbackBgColor#" class="header" colspan="8"><b>Approve #appSettings.getPullbackLabel()#</b></td>
                <td bgcolor="#pullbackBgColor#">
                    <input type="checkbox"
                            name="Approve_Pullback"
                            value="1" #pullbackCheckDisabled# #pullbackCheckChecked#
                        <cfif bApprovingPullbackApprovesProgram>onPropertyChange="javaScript:changeApproveLabel(this.checked);"</cfif>
                            bApprovingPullbackApprovesProgram="#bApprovingPullbackApprovesProgram#">
                </td>
                <td bgcolor="#pullbackBgColor#"><span class="title6">Approve</span></td>
                <td bgcolor="#pullbackBgColor#">
                    <cfif bPullbackApproved>
                        <IMG SRC="/images/Layered_Approval/Gaya_i11.gif"
                            onmouseover="initTheTooltip('#sPullbackApprovedMessage#')"
                            onmouseout="popOut()">
                    <cfelse>
                        <IMG SRC="/images/Layered_Approval/Gaya_i12.gif">
                    </cfif>
                </td>
                <td>&nbsp;</td>
            </tr>
        </cfif>
        <!------ END display the pullback checkbox END ----->

        <!---- Freight Calculator - START --->
        <cfif appSettings.getFreight_Calculator_On()>
            <!--- <tr> --->
            <tr class="GridViewScrollItem">
                <cfif Get_Profile_Settings.Base_View eq 1>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </cfif>
                <cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
                    <td>&nbsp;</td>
                </cfif>
                <cfif direct_pricing eq 0>
                    <td>&nbsp;</td>
                </cfif>
                <cfif ShowTPA eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif Get_Profile_Settings.View_Cost eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif Get_Profile_Settings.View_Operating_Income eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif Get_Profile_Settings.View_Operating_Income eq 1>
                    <td align="left" colspan="2">Freight Estimate:</td>
                    <td align="left" colspan="2"><input type="text" id="marginFreightCalc"
                        name="marginFreightCalc"
                        onBlur="javascript:calcFreight();"
                        size="3">%</td>
                    <td align="left" colspan="2">Est. Freight $:</td>
                    <td id="marginFreightCalcTarget" align="left"></td>
                <cfelse>
                    <td colspan="7">&nbsp;</td>
                </cfif>
                <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </cfif>
            </tr>

            <tr class="GridViewScrollItem">
                <cfif Get_Profile_Settings.Base_View eq 1>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                </cfif>

                <cfif direct_pricing eq 0 and appsettings.getlocalcostvariables() neq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif appsettings.getlocalcostvariables() eq 1 and direct_pricing eq 0>
                    <td>&nbsp;</td>
                </cfif>
                <cfif direct_pricing eq 0>
                    <td>&nbsp;</td>
                </cfif>
                <cfif ShowTPA eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif Get_Profile_Settings.View_Cost eq 1>
                    <td>&nbsp;</td>
                </cfif>

                <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif Get_Profile_Settings.View_Operating_Income eq 1>
                    <td>&nbsp;</td>
                </cfif>
                <cfif Get_Profile_Settings.View_Operating_Income eq 1>
                    <td align="left" colspan="2">Est. Operating Margin Dollars: </td>
                    <td align="left" colspan="2" id="marginDollars"></td>
                    <td align="left" colspan="2">Est. Operating Margin %:</td>
                    <td id="marginPercent" align="left"></td>
                <cfelse>
                    <td colspan="7">&nbsp;</td>
                </cfif>
                <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </cfif>
            </tr>
        </cfif>
        <!---- Freight Calculator - END --->
    </cfif>




    <!--- Dev Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->
    <cfif appSettings.getMarginItemsExclude()>
        <tr class="GridViewScrollItem">
            <td>&nbsp;</td>
        </tr>

        <tr class="GridViewScrollItem">
            <td align="left" colspan="100%" id="highlight">
                <strong>
                <a href="##" onclick="toggleProdExcludeView();">
                    Products Excluded From Margin
                </a>
                </strong>
            </td>
        </tr>
        <cfinclude template="layered_margin_items_exclude.cfm">
    </cfif>
    <!--- End Note: KAL; 9/13/2010; D23601: Margin Items Exclude --->

    <!---- NEW BUDGET DISPLAY ---->
    <cfif appSettings.getBudgetsFunctionalityOn()>
        #budgetDisplayString#
    </cfif>
    <!---- NEW BUDGET DISPLAY - END ---->
    </cfoutput>
</table>

</cfsavecontent>    <!--- variable="body_content" --->


<!--- <cfoutput>#application.util.string.compress( body_content )#</cfoutput> --->
<cfoutput>#( body_content )#</cfoutput>



<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~ Render Individual Item ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="render_horizontal_item">
    <!--- <cfoutput> --->
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
        <cfset CannotApproveItemMargin  = 1>
        <cfset CannotApproveGroupMargin = 1>
    </cfif>


    <cfset row = duplicate( empty_row )>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~ Product ~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfsavecontent variable="row.Description">
        <!--- Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  START
                Added/Changed: Added IF condition to toggle display--->
        <cfoutput> 
            <cfif form.margin_type eq 2>
                <span style="cursor:pointer;" onmouseover="initTheTooltip('Stat Case Value:#trim(numberformat(CASE_EQUIVALENT,'_-___,___,___,___,___.___'))#')" onmouseout="popOut()">
                <cfif appSettings.getViewPgmSortBy()> #Description#<br><cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>#upc# <cfelse>#Item# </cfif> <cfelse> <cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>#upc# <cfelse>#Item# </cfif><br> #Description#  </cfif>
                </span>
            <cfelse>
                <cfif appSettings.getViewPgmSortBy()> #Description#<br><cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>#upc# <cfelse>#Item# </cfif> <cfelse> <cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>#upc# <cfelse>#Item# </cfif><br>#Description# </cfif>
            </cfif>
        </cfoutput>
        <!--- End Dev Note: drachala; D28637: In View Margin Page Display Description text in order user selected  --->
    </cfsavecontent>


 <!---    <cfquery name="local.detail" dbtype="query">
        SELECT * FROM qCostDetail WHERE Product_ID = '#getAllProductMargins.Product_ID#'
    </cfquery> --->

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~ Requested Case Volume ~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfset row.Requested_CS_Volume = numberFormat(Product_Program_Volume, "9,9")>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~ Requested Price / Case Vol   --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfset row.Requested_Price_CS = numberFormat(Program_Fixed_Price_CS, request.dollar_format)>


    <!--- Price List / Case (old = allow/surge)---->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~ Price List / Case ~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfset row.Price_List_CS = numberFormat(Base_Sales, request.dollar_format)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~ Cash Disc. ~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfset row.Cash_Disc = numberFormat(Cash_discount, request.dollar_format)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~ Allowance column ~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfset row.Other_Allowances = numberFormat(Allowance_Surcharges_CS, request.dollar_format)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~ Redi ~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- Redi - (old = TPA Operator) --->
    <cfset row.Redi = numberFormat(Other_Spend, request.dollar_format)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~ TPA ~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- TPA - (old = TPA Distributor (Distributor Trade) --->
    <cfset row.TPA = numberFormat(TPA, request.dollar_format)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~ Net Sales / CS ~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- Net Sales / CS (old = pullback amount) --->
    <cfset row.Net_Sales_CS = numberFormat(Net_Sales, request.dollar_format)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~ VC / CS ~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- VC / CS (old = Other Spend) --->
    <cfset row.VC_CS = numberFormat(Cost, request.dollar_format)>

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~ CM $ / CS ~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- CM $ / CS (old - net sales) --->
    <cfset row.CM_CS = numberFormat(Contribution_Margin_Alt, request.dollar_format)>


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

    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~ CM ~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- CM % (old = cost) --->
    <cfset row.CM_Percent  = numberFormat(Variable_Contribution_Margin, "9.99") & '%'>

    <!--- POH / CS (old = Shuttle Freight) --->
    <cfset row.POH_CS = numberFormat(SGA, request.dollar_format)>

    <!--- GP $ / CS (old = Warehouse) --->
    <cfset row.GP_CS  = numberFormat(Operating_Income, request.dollar_format)>

    <!--- GP % (old = Gross Margin) --->
    <cfset row.GP_Percent  = numberFormat(OperatingMargin_percent, "9.99") & '%'>
    


    <!--- check if the program is RFA only then display the check boxes --->
    <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
        <!--- get all the previous approved items  --->
        <cfset useLakebaseForgetitemapprovedvalues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gettypecodeapprovalinfo")>
<cfif useLakebaseForgetitemapprovedvalues>
	<cftry>
		<cfset getitemapprovedvalues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gettypecodeapprovalinfo", {
				"product_id" = "eq.#BSA_Foodservice_Items_Master_Id#",
				"system_agreement" = "eq.0",
				"approve" = "eq.1",
				"order" = "system_agreement.asc",
				"select" = "approve as item_approve,name_last,name_first"
			}), "approve as item_approve,name_last,name_first"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetitemapprovedvalues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetitemapprovedvalues>
<cfquery name="getitemapprovedvalues" dbtype="query">
            select approve as item_approve,Name_Last,Name_First
            from getTypeCodeApprovalInfo
            where product_id = '#BSA_Foodservice_Items_Master_Id#'
            and System_Agreement = 0
            and approve = 1
            order by System_Agreement
        </cfquery>
</cfif>

        <cfquery name="getitemagreedcount" dbtype="query">
            select count(Product_ID) as agreecount
            from getTypeCodeApprovalInfo
            where product_id = '#BSA_Foodservice_Items_Master_Id#'
            and agree = 1
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
                <cfquery name="getitemvalues" dbtype="query">
                    select agree as item_agree
                    from getTypeCodeApprovalInfo
                    where product_id = '#BSA_Foodservice_Items_Master_Id#'
                    and user_id = '#request.AccessStructure.User_ID#'
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

        <cfsavecontent variable="row.checkbox_1">
            <!--- <span id="checkAllProducts"> --->
            <cfoutput>
                <input type="checkbox" class="action" original_name="#feildname#" idToken="#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" name="#feildname#" value="1" #checkitemvalue# #disablecheckbox# <cfif disablecheckbox eq "">checked</cfif>>
            </cfoutput>
                <!--- </span> --->
        </cfsavecontent>

        <!--- mass approve --->
        <cfif not itemCheckBoxDisabled>
            <cfset stMassApproval["#feildname#"] = 1>
        </cfif>

        <cfsavecontent variable="row.approve_agree">
            <cfoutput>
                <span class="title5" id="approve_agree_label_#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#" original_approve_agree_label="#itemlabel#">#itemlabel#</span>
        </cfoutput>
        </cfsavecontent>

        <cfsavecontent variable="row.nbsp_1">
            <cfoutput>
                <IMG SRC="/images/Layered_Approval/#imagesrc#"
                    <cfif imagesrc eq 'Gaya_i11.gif'>
                        <cfif trim(approveditemuser) neq "">
                            onmouseover="initTheTooltip('Approved by #approveditemuser#')" onmouseout="popOut()"
                        </cfif>
                    <cfelseif imagesrc eq 'Gaya_i18.gif'>
                        onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
                        onclick="showCalculation('#replace(BSA_Foodservice_Items_Master_Id, "-", "_", "ALL")#','AG','P')"
                    </cfif>
                    style="cursor:pointer;">
            </cfoutput>
        </cfsavecontent>
    </cfif>


    <tr class="GridViewScrollItem csv">
        <cfoutput>
            <cfloop array="#visible_columns#" item="column_name">
                <!--- set up to ignore some columns from cvs export --->
                <cfset csvExclude = arrayFindNoCase(["CheckBox_1", "approve_agree", "nbsp_1"], column_name )
                                        ? "class='csvExclude'"
                                        : ''>
                <td #csvExclude#>#row[ column_name ]#</td>
            </cfloop>
        </cfoutput>
    </tr>

    <cfset count                   = count + 1>
    <cfset checkitemvalue          = "">
    <cfset itemlabel               = "">
    <cfset CannotApproveItemMargin = 0>

 <!---    </cfoutput> --->
</cffunction>
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~ End of Render Individual Item ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->







<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Render Type Code Row ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="render_horizontal_type_code">
    <cfoutput>
    <cfloop query="getGroupvalues">

        <cfset row = duplicate( empty_row )>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~ Product ~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.Description = "&nbsp;<br>" & Type_Code_Desc>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ Requested Case Volume ~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.Requested_CS_Volume = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~ Requested Price / Case Vol   --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.Requested_Price_CS = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~ Price List / Case ~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.Price_List_CS = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~ Cash Disc. ~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.Cash_Disc = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~ Allowance column ~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.Other_Allowances = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~ Redi ~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.Redi = ''>


        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~ TPA ~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.TPA = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~ Net Sales / CS ~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.Net_Sales_CS = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~ VC / CS ~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.VC_CS = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~ CM $ / CS ~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.CM_CS = ''>

        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~ CM ~~~~~~~~~~~~~~~ --->
        <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <cfset row.CM_Percent = ''>

        <!--- POH / CS (old = Shuttle Freight) --->
        <cfset row.POH_CS = ''>

        <!--- GP $ / CS (old = Warehouse) --->
        <cfset row.GP_CS = ''>

        <!--- GP % (old = Gross Margin) --->
        <cfset row.GP_Percent = ''>


        <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
            <cfset useLakebaseForgetgroupapprovedvalues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gettypecodeapprovalinfo")>
<cfif useLakebaseForgetgroupapprovedvalues>
	<cftry>
		<cfset getgroupapprovedvalues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gettypecodeapprovalinfo", {
				"type_code_desc_id" = "eq.#getGroupvalues.Type_Code_Desc_Id#",
				"approve" = "eq.1",
				"select" = "approve as group_approve,name_last,name_first"
			}), "approve as group_approve,name_last,name_first"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetgroupapprovedvalues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetgroupapprovedvalues>
<cfquery name="getgroupapprovedvalues" dbtype="query">
                select approve as group_approve, Name_Last, Name_First
                from getTypeCodeApprovalInfo
                where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
                and approve = 1
            </cfquery>
</cfif>

            <cfquery name="getgroupagreedcount" dbtype="query">
                select count(Type_Code_Desc_Id) as agreecount
                from getTypeCodeApprovalInfo
                where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
                and agree = 1
            </cfquery>

            <cfif (CannotApproveSettings eq 0 and Group_ID_Approval eq 1 and CannotApproveProgramMargin eq 0 and CannotApproveGroupMargin eq 0) OR (getgroupapprovedvalues.recordcount gt 0 and getgroupapprovedvalues.group_approve GT 0)>
                <cfset feildname = "GroupApprove_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#">
                <cfset grouplabel = "Approve">
                <cfset showColumn = 0>
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
                    <cfset showColumn = 1>
                </cfif>
            <cfelseif (getgroupapprovedvalues.group_approve eq 0 OR getgroupapprovedvalues.recordcount eq 0) and (CannotApproveSettings eq 1 OR Group_ID_Approval eq 0 OR CannotApproveGroupMargin eq 1 or CannotApproveProgramMargin eq 1)>
                <cfset cannotapprove = 1>
                <cfset showColumn = 0>
                <cfset feildname = "GroupAgree_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#">
                <cfquery name="getgroupagreevalues" dbtype="query">
                    select agree as group_agree
                    from getTypeCodeApprovalInfo
                    where Type_Code_Desc_Id = '#getGroupvalues.Type_Code_Desc_Id#'
                    and user_id = '#request.AccessStructure.User_ID#'
                </cfquery>
                <cfset grouplabel = "Agree">
                <cfset imagesrc = "Gaya_i12.gif">
                <cfif getgroupagreevalues.recordcount GT 0 and getgroupagreevalues.group_agree eq 1>
                    <cfset grouplabel = "Agreed">
                    <cfset checkgroupvalue = "checked disabled">
                    <cfset title = "Click here to view the list of users who agreed">
                    <cfset imagesrc = "Gaya_i18.gif">
                    <cfset showColumn = 1>
                </cfif>
            </cfif>

            <cfif isDefined("showColumn") and showColumn eq 0 and grouplabel is not "Approve" and grouplabel is not "Agree">
                <td class="type-code">&nbsp;</td>
            </cfif>


            <cfsavecontent variable="row.checkbox_1">
                <!--- <span id="checkAllProducts"> --->
                <input type="checkbox" class="action" original_name="#feildname#" idToken="#replace(Type_Code_Desc_Id, "-", "_", "ALL")#" name="#feildname#" value="1" #checkgroupvalue# #disablecheckbox# <cfif disablecheckbox eq "">checked</cfif>>
                <!--- </span> --->
            </cfsavecontent>

            <cfif not itemCheckBoxDisabled>
                <cfset stMassApproval["#feildname#"] = 1>
            </cfif>

            <cfsavecontent variable="row.approve_agree">
                <span class="title6" id="approve_agree_label_#replace(Type_Code_Desc_Id, "-", "_", "ALL")#" original_approve_agree_label="#grouplabel#">#grouplabel#</span>
            </cfsavecontent>

            <cfsavecontent variable="row.nbsp_1">
                <IMG SRC="/images/Layered_Approval/#imagesrc#"
                    <cfif imagesrc eq 'Gaya_i11.gif'>
                        <cfif trim(approvedgroupuser) neq "">
                            onmouseover="initTheTooltip('Approved by #approvedgroupuser#')" onmouseout="popOut()"
                        </cfif>
                    <cfelseif imagesrc eq 'Gaya_i18.gif'>
                        onmouseover="initTheTooltip('#title#')" onmouseout="popOut()"
                        onclick="showCalculation('#replace(Type_Code_Desc_Id, "-", "_", "ALL")#','AG','G')"
                    </cfif>
                style="cursor:pointer;">
            </cfsavecontent>
        </cfif>

        <tr class="GridViewScrollItem csv">
            <cfoutput>
                <cfloop array="#visible_columns#" item="column_name">
                    <!--- set up to ignore some columns from cvs export --->
                    <cfset csvExclude = arrayFindNoCase(["CheckBox_1", "approve_agree", "nbsp_1"], column_name )
                                            ? "class='csvExclude'"
                                            : ''>
                    <cfset css = 'class="type-code"'>
                    <td #csvExclude# #css#>#row[ column_name ]#</td>
                </cfloop>
            </cfoutput>
        </tr>

        <cfset checkgroupvalue = "">
        <cfset grouplabel = "">
    </cfloop>
    </cfoutput>
</cffunction>
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~ End Of Render Type Code Row ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->






<!------------------------------------------------------------------------------------------------------------------->
<!------ Annual/Program Summary : Absolute $ start ------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------->
<cffunction name="render_horizontal_absolute">
    <cfset TotalProgramVolume = OriginalTotalProgramVolume>
    <!--- <tr valign="middle"> --->
    <tr class="GridViewScrollItem">
        <td align="left" class="header"><strong>Absolute $</strong></td>

        <!------------------------->
        <!--- 002 - Vol. CS ------->
        <!------------------------->
        <cfif Get_Profile_Settings.Base_View eq 1>
            <cfset data = makeNumeric(TotalProgramVolume)>

        <cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)>
            <td>
                <cfset colCount = colCount + 1>
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
            <cfset data = makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(TotalProgramVolume)>
            <cfset tempABS_BaseSales = data>

            <td>
                #application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#
            </td>

            <!----------------------->
            <!--- ALlow/Surch --->
            <!----------------------->
            <cfset data = makeNumeric(getProgramMargins.Total_Allowance_Surcharges) * makeNumeric(TotalProgramVolume)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!----------------------->
            <!--- Customer Freight --->
            <!----------------------->
            <cfset data = makeNumeric(getProgramMargins.Total_Customer_Freight) * makeNumeric(TotalProgramVolume)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <cfif direct_pricing eq 0>
                <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
                <!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
                <!--- 004 --->
                <!--------------------->
                <!--- 004 Cash Disc --->
                <!--------------------->
                <cfif appsettings.getDisplayCashDiscountMargin() eq 1>
                    <cfset data = makeNumeric(getProgramMargins.Total_Cash_Discount) * makeNumeric(TotalProgramVolume)>

                    <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                </cfif>
                <!----------------------->
                <!--- 005 - allowance --->
                <!----------------------->
                <cfparam name="addExtra" default="0">
                <cfif TotalProgramVolume neq "" and TotalProgramVolume neq 0>
                    <cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/TotalProgramVolume)>
                </cfif>
                <cfif form.Margin_Type eq 1 OR form.margin_type eq 3>
                    <cfset data = (makeNumeric(getProgramMargins.TOTAL_Allowance) + addExtra) * makeNumeric(TotalProgramVolume)>
                <cfelse>
                    <cfset data = makeNumeric(getProgramMargins.TOTAL_Allowance) * makeNumeric(TotalProgramVolume)>
                </cfif>

                <cfset AllowAbs1 = makeNumeric(data)>


                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                <!--------------------->
                <!--- 006 - allow % --->
                <!--------------------->
                <td>&nbsp;</td>
            </cfif>

            <cfif ShowTPA eq 1>
                <!----------------------------->
                <!--- TPA Operator --------------->
                <!----------------------------->
                <cfset data = makeNumeric(getProgramMargins.Total_TPA_Oper) * makeNumeric(TotalProgramVolume)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                <!----------------------------->
                <!--- TPA Distributor (Distributor Trade) --------------->
                <!----------------------------->
                <cfset data = makeNumeric(getProgramMargins.Total_TPA) * makeNumeric(TotalProgramVolume)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            </cfif>

            <cfif appSettings.getPullbacksOn() eq 1 and GetSettings.Pullbacks_On eq 1>
                <!----------------------------->
                <!--- 008 - pullback amount --->
                <!----------------------------->
                <cfset data = makeNumeric(getProgramMargins.Total_pullbackamount) * makeNumeric(TotalProgramVolume)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            </cfif>

            <!----------------------------->
            <!--- Other Spend --------------->
            <!----------------------------->
            <cfset data = makeNumeric(getProgramMargins.Total_Other_Spend) * makeNumeric(TotalProgramVolume)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
            <cfif appSettings.getApprovalMarginType() eq 0>
                <!----------------------->
                <!--- 009 - net sales --->
                <!----------------------->
                <cfset data = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume)>
                <cfset tempABS_NetSales = data>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            </cfif>
        </cfif>

        <cfif Get_Profile_Settings.View_Cost eq 1>
            <!------------------>
            <!--- 010 - cost --->
            <!------------------>
            <cfset data = makeNumeric(getProgramMargins.Total_Cost) * makeNumeric(TotalProgramVolume)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
        </cfif>

        <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
            <!----------------------->
            <!--- 011 - Brokerage --->
            <!----------------------->
            <cfset data = makeNumeric(getProgramMargins.Total_Brokerage) * makeNumeric(TotalProgramVolume)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
        </cfif>

        <!----------------------------->
        <!--- Shuttle Freight --------------->
        <!----------------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_shuttle_freight) * makeNumeric(TotalProgramVolume)>

        <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

        <!----------------------------->
        <!--- Warehouse --------------->
        <!----------------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_Custom_Warehouse) * makeNumeric(TotalProgramVolume)>

        <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

        <!----------------------------->
        <!--- Gross Margin --------------->
        <!----------------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_Gross_Margin) * makeNumeric(TotalProgramVolume)>

        <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

        <!----------------------->
        <!--- Brokerage --->
        <!----------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_Custom_Brokerage) * makeNumeric(TotalProgramVolume)>

        <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

        <!----------------------->
        <!--- Contribution Margin --->
        <!----------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_Contribution_Margin_Alt) * makeNumeric(TotalProgramVolume)>

        <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

        <!----------------------->
        <!--- Variable Contribution Margin --->
        <!----------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_Variable_Contribution_Margin) * makeNumeric(TotalProgramVolume)>

        <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

        <!----------------------->
        <!--- MAP and MDF --->
        <!----------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_Map_Mdf) * makeNumeric(TotalProgramVolume)>

        <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

        <!----------------------->
        <!--- SG & A --->
        <!----------------------->
        <cfset data = makeNumeric(getProgramMargins.Total_SGA) * makeNumeric(TotalProgramVolume)>

        <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>


        <cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
            <!------------------------------>
            <!--- 012 - operating income --->
            <!------------------------------>
            <cfset data = makeNumeric(getProgramMargins.Total_OprIncome) * makeNumeric(TotalProgramVolume)>
            <cfset absTotalOperIncome = data>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
        </cfif>

        <cfif Get_Profile_Settings.View_Target_Margins eq 1>
            <cfif appSettings.getApprovalMarginType() eq 2>
                <!------------------------------->
                <!--- 013a - Annual Case Rate --->
                <!------------------------------->
                <cfset data = makeNumeric(getProgramMargins.Total_TradeAmt_CS) * makeNumeric(getProgramMargins.totalprogramvolumecs)>
                <cfset AllowAbs1 = makeNumeric(data)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            <cfelse>
                <!--------------------------------------->
                <!--- 013m - Operating Margin Percent --->
                <!--------------------------------------->
                <cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
                    <cfset data = makeNumeric(getProgramMargins.Total_OprMargin)>

                        <cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)>
                        <cfset data = "<br>#data#%</br>">
                    <td>
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
        <cfif Cont_Margin_Calculation EQ '1'>
            <cfset data = (makeNumeric(getProgramMargins.Total_Fixed_Mfg_Cost)+makeNumeric(getProgramMargins.Total_OprIncome)) * makeNumeric(TotalProgramVolume)/>
            <cfset TotalContribMargin = data>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            <cfset variables.Total_Net_Sales = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(TotalProgramVolume)>

            <cfif len(variables.Total_Net_Sales) EQ 0 OR variables.Total_Net_Sales EQ 0>
                <cfset variables.Total_Net_Sales = 1>
            </cfif>
            <cfset data = (TotalContribMargin/makeNumeric(variables.Total_Net_Sales)) * 100/>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
        </cfif>

        <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
        <!------------>
        <!--- 013z --->
        <!------------>
        <td valign="bottom">&nbsp;</td>
        <!------------------->
        <!--- 013b | 013n --->
    <cfif margin_display_style neq "custom_t">
        <td>&nbsp;</td>
    </cfif>
        <!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
        <cfif appSettings.getApprovalMarginType() eq 1>
            <!---------------------->
            <!--- 014 - Trade CS --->
            <!---------------------->
            <cfset data = makeNumeric(getProgramMargins.Total_TradeAmt) * makeNumeric(TotalProgramVolume) >

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!---------------------->
            <!--- 015 - trade %  --->
            <!---------------------->
            <cfset data = makeNumeric(getProgramMargins.Total_TradePercent)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
        </cfif>
        <!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
        <cfif Get_Profile_Settings.Base_View eq 1>
            <!------------------------->
            <!--- 016 - Trade Spent --->
            <!------------------------->
            <cfset data = makeNumeric(program_spend_in_margin_uot)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
        </cfif>

        <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        <cfelse>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </cfif>
    </tr>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------->
<!------ Annual/Program Summary : Absolute $ end -------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------------------------------->






<!------------------------------------------------------------------------------------------------------------------->
<!------ Program Summary: Absolute#2 $ START ------------------------------------------------------------------------>
<!------------------------------------------------------------------------------------------------------------------->
<cffunction name="render_horizontal_program_summary">
    <cfif qGetMarginUOT.Unit_Multiplier NEQ 0>
        <!--- <tr> --->
        <tr class="GridViewScrollItem">
            <td class="header" colspan="#(1 + arrayLen(visible_columns))#"><strong>Program Summary</strong></td>
        </tr>

        <!--- <tr valign="middle"> --->
        <tr class="GridViewScrollItem">
            <td align="left" class="header"><strong>Absolute $</strong></td>
            <cfset ProgramVolume_For_Program_Span = (TotalProgramVolume * getProgramInfo.Program_Span) / qGetMarginUOT.Unit_Multiplier>

            <cfif Get_Profile_Settings.Base_View eq 1>
                <!--- volume --->
                <td>&nbsp;</td>
                <!--- 003 - base sales --->
                <cfset data = makeNumeric(getProgramMargins.Total_BaseSales) * makeNumeric(ProgramVolume_For_Program_Span)>
                <cfset tempABS_BaseSales = data>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

                <!--- ALlow/Surch --->
                <cfset data = makeNumeric(getProgramMargins.Total_Allowance_Surcharges) * makeNumeric(ProgramVolume_For_Program_Span)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

                <!--- Customer Freight --->
                <cfset data = makeNumeric(getProgramMargins.Total_Customer_Freight) * makeNumeric(ProgramVolume_For_Program_Span)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

                <!--- cash disc --->
                <cfif direct_pricing eq 0>
                    <!--- Dev Note: KAL; D20537: Margin Approval - Trade as Percent of Gross Sales. Forge changes --->
                    <!--- Display Cash Discount only if the app setting is on. This setting is only off when margin = trade percent of gross sales. --->
                    <cfif appsettings.getDisplayCashDiscountMargin() eq 1>
                            <cfset data = makeNumeric(getProgramMargins.Total_Cash_Discount) * makeNumeric(ProgramVolume_For_Program_Span)>

                            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                    </cfif>
                    <!--- 005 - allowance --->
                    <cfparam name="addExtra" default="0">
                    <cfif ProgramVolume_For_Program_Span neq "" and ProgramVolume_For_Program_Span neq 0>
                        <cfset addExtra = makenumeric(getProgramLumpsum.Lumpsum_Amount/ProgramVolume_For_Program_Span)>
                    </cfif>
                    <cfif form.Margin_Type eq 1 OR form.margin_type eq 3>
                        <cfset data = (makeNumeric(getProgramMargins.TOTAL_Allowance) + addExtra) * makeNumeric(ProgramVolume_For_Program_Span)>
                    <cfelse>
                        <cfset data = makeNumeric(getProgramMargins.TOTAL_Allowance) * makeNumeric(ProgramVolume_For_Program_Span)>
                    </cfif>

                    <cfset AllowAbs1 = makeNumeric(data)>

                    <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                    <!--- 006 -skip a column for "Allow %" --->
                    <td>&nbsp;</td>
                </cfif>

                <!--- 007 - TPA --->
                <cfif ShowTPA eq 1>
                    <!--- TPA Operator --->
                    <cfset data = makeNumeric(getProgramMargins.Total_TPA_Oper) * makeNumeric(ProgramVolume_For_Program_Span)>

                    <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                    <!--- TPA Distributor (Distributor Trade) --->
                    <cfset data = makeNumeric(getProgramMargins.Total_TPA) * makeNumeric(ProgramVolume_For_Program_Span)>

                    <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                </cfif>

                <!--- 008 - pullback amount --->
                <cfif appSettings.getPullbacksOn() eq 1
                        and GetSettings.Pullbacks_On eq 1>
                    <cfset data = makeNumeric(getProgramMargins.Total_pullbackamount) * makeNumeric(ProgramVolume_For_Program_Span)>

                    <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                </cfif>

                <!--- Other Spend --->
                <cfset data = makeNumeric(getProgramMargins.Total_Other_Spend) * makeNumeric(ProgramVolume_For_Program_Span)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

                <!--- 009 - net sales --->
                <!--- Dev Note: KAL; D20537: Dont display net sales only when margin = trade percent --->
                <cfif appSettings.getApprovalMarginType() eq 0>
                    <cfset data = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(ProgramVolume_For_Program_Span)>
                    <cfset tempABS_NetSales = data>

                    <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                </cfif>
            </cfif>

            <!--- 010 - cost --->
            <cfif Get_Profile_Settings.View_Cost eq 1>
                <cfset data = makeNumeric(getProgramMargins.Total_Cost) * makeNumeric(ProgramVolume_For_Program_Span)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            </cfif>

            <!--- 011 - Brokerage --->
            <cfif appSettings.getBrokerage_Margin_Calculation() eq 1 AND Get_Profile_Settings.Cont_Prog_View_Brokerage_Margins eq 1>
                <cfset data = makeNumeric(getProgramMargins.Total_Brokerage) * makeNumeric(ProgramVolume_For_Program_Span)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            </cfif>

            <!--- Shuttle Freight --->
            <cfset data = makeNumeric(getProgramMargins.Total_shuttle_freight) * makeNumeric(ProgramVolume_For_Program_Span)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!--- Warehouse --->
            <cfset data = makeNumeric(getProgramMargins.Total_Custom_Warehouse) * makeNumeric(ProgramVolume_For_Program_Span)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!--- Gross Margin --->
            <cfset data = makeNumeric(getProgramMargins.Total_Gross_Margin) * makeNumeric(ProgramVolume_For_Program_Span)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!--- Brokerage --->
            <cfset data = makeNumeric(getProgramMargins.Total_Custom_Brokerage) * makeNumeric(ProgramVolume_For_Program_Span)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!--- Contribution Margin --->
            <cfset data = makeNumeric(getProgramMargins.Total_Contribution_Margin_Alt) * makeNumeric(ProgramVolume_For_Program_Span)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!--- Variable Contribution Margin --->
            <cfset data = makeNumeric(getProgramMargins.Total_Variable_Contribution_Margin) * makeNumeric(ProgramVolume_For_Program_Span)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!--- MAP and MDF --->
            <cfset data = makeNumeric(getProgramMargins.Total_Map_Mdf) * makeNumeric(ProgramVolume_For_Program_Span)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <!--- SG & A --->
            <cfset data = makeNumeric(getProgramMargins.Total_SGA) * makeNumeric(ProgramVolume_For_Program_Span)>

            <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

            <cfif Get_Profile_Settings.View_Operating_Income eq 1 AND appSettings.getApprovalMarginType() neq 3>
                <!--- 012 - operating income --->
                <cfset data = makeNumeric(getProgramMargins.Total_OprIncome) * makeNumeric(ProgramVolume_For_Program_Span)>
                <cfset absTotalOperIncome = data>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            </cfif>

            <!--- 013 - operating margin --->
            <cfif Get_Profile_Settings.View_Target_Margins eq 1>
                <cfif appSettings.getApprovalMarginType() eq 2>
                    <!--- 013a - Annual Case Rate --->
                    <cfset data = makeNumeric(getProgramMargins.Total_TradeAmt_CS) * makeNumeric(getProgramMargins.totalprogramvolumecs)>
                    <cfset AllowAbs1 = makeNumeric(data)>

                    <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                <cfelse>
                    <!--- 013m - Operating Margin Percent --->
                    <cfif appSettings.getApprovalMarginType() neq 3 AND appSettings.getApprovalMarginType() neq 1>
                        <cfset data = makeNumeric(getProgramMargins.Total_OprMargin)>

                            <cfset data = application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format) >
                            <cfset data = "<b>#data#%</b>">

                        <td>
                            <cfif (getProgramMargins.Total_OprMargin LT Get_Profile_Settings.Max_Opr_Margin)
                                and TRIM(Get_Profile_Settings.Max_Opr_Margin) NEQ "*" and ignoreOperatingMarginCheck eq 0>
                                <IMG SRC="/images/exclamation.gif"
                                    HEIGHT="10"
                                WIDTH="10"
                                onmouseover="initTheTooltip('Opr. Margin not within your approval limits.')"
                                onmouseout="popOut()"
                                align="absmiddle">
                            </cfif>&nbsp;
                        </td>
                    </cfif>
                </cfif>
            </cfif>

            <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost START--->
            <cfif Cont_Margin_Calculation EQ '1'>
                <cfset data = absTotalOperIncome/>
                <cfset TotalContribMargin = data>


                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
                <cfset TOTALNetSales = makeNumeric(getProgramMargins.TOTAL_NetSales) * makeNumeric(ProgramVolume_For_Program_Span)>
                <cfif TOTALNetSales EQ 0>
                    <cfset TOTALNetSales = 1>
                </cfif>
                <cfset data = (TotalContribMargin/makeNumeric(TOTALNetSales)) * 100>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
            </cfif>

            <!---62143 Margin Page - if Multiple costs for products setting is ON, display new column for Opr Mar + Fixed Cost END--->
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <!--- Dev Note: KAL; D20537: Display margin as trade percent; Group --->
            <cfif appSettings.getApprovalMarginType() eq 1>
                <!--- Trade CS --->
                <cfset data = makeNumeric(getProgramMargins.Total_TradeAmt) * makeNumeric(ProgramVolume_For_Program_Span)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>

                <!--- Trade Percent --->
                <cfset data = makeNumeric(getProgramMargins.Total_TradePercent)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.numeric_format)# %</td>
            </cfif>

            <!--- Dev Note: KAL; D21101: Margin page - include Trade Spend column as part of base view --->
            <cfif Get_Profile_Settings.Base_View eq 1>
                <!--- trade spend --->
                <cfset data = makeNumeric(program_spend)>

                <td>#application.util.string.cellFormat(value=data ,decimalplaces = request.dollar_format)#</td>
            </cfif>

            <cfif getProgramInfo.Contract_Status_Type_IDX eq 2>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            <cfelse>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
            </cfif>
        </tr>
    </cfif>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------->
<!------ Program Summary: Absolute#2 $ END -------------------------------------------------------------------------->
<!------------------------------------------------------------------------------------------------------------------->


<cffunction name="render_cell" output="true">
    <cfargument name="value" required="true">
    <cfargument name="onclick" required="false" default="">
    <cfargument name="calculation_popup" required="false" default="0">

    <cfif arguments.calculation_popup>
        <a style="cursor:pointer;" onclick="#arguments.onclick#">#arguments.value#</a>
    <cfelse>
        #arguments.value#
    </cfif>
</cffunction>

<cf_include files="/script/javascript/gridviewscroll/1.0/gridviewscroll.js">

<script>
    function changemarginType(){
        document.MyForm.action = "layered_approval_include.cfm?<cfoutput>CID=#URL.CID#&UoT=#url.UoT#&duplicateprogram=#duplicateprogram#</cfoutput>"
                                    + <cfif isDefined("MarginCalculatedDate")> "&MarginCalculatedDate=<cfoutput>#MarginCalculatedDate#</cfoutput>" <cfelse> "" </cfif>;
        MyForm.submit();
    }
    function showrevisiondetails(contractid,status){
        NewWindow('/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id='+contractid+'&Contract_Status='+status,'ProgramRevisionDetails','1200','550','Yes', 'Yes')

    }
    <!--- Freight Calc Js --->
    <cfif Get_Profile_Settings.View_Operating_Income eq 1>
        function calcFreight() {
            var totalBaseSales       = < cfoutput > #tempABS_BaseSales# < /cfoutput>;
            var percentage           = parseInt(document.all.marginFreightCalc.value);
            var totalOperatingMargin = < cfoutput > #absTotalOperIncome# < /cfoutput>;
            var netSales             = < cfoutput > #tempABS_NetSales# < /cfoutput>;
            var calcTarget           = 0;
            var marginDollars        = 0;
            var marginPercentage     = 0;
            if (isNaN(percentage)) {
                document.all.marginFreightCalcTarget.innerText = 0;
                document.all.marginFreightCalc.value           = 0;
            } else {
                if (percentage > 1000 || percentage < 0) {
                    document.all.marginFreightCalc.value = 0;
                } else {
                    calcTarget                                     = parseInt((percentage * .01) * totalBaseSales);
                    marginDollars                                  = (totalOperatingMargin - calcTarget);
                    marginPercentage                               = (marginDollars / netSales) * 100.0;
                    document.all.marginFreightCalcTarget.innerText = "$" + FormatTextWithCommas(calcTarget);
                    document.all.marginDollars.innerText           = "$" + FormatTextWithCommas(marginDollars);
                    if (isNaN(marginPercentage) || marginDollars == 0) {
                        document.all.marginPercent.innerText = 0 + "%";
                    } else {
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
    <!--- Dev Note: KAL; D21684: Functionality of View Margins Screen: To Toggle previous margin displays --->
    togglePreviousView = function(objName){
        obj1 = 'previous_rate_' + objName
        obj2 = 'previous_dollar_' + objName
        obj3 = 'variance_rate_' + objName
        obj4 = 'variance_dollar_' + objName
        Effect.toggle(obj1, 'slide', { duration: .100 });
        Effect.toggle(obj2, 'slide', { duration: .100 });
        Effect.toggle(obj3, 'slide', { duration: .100 });
        Effect.toggle(obj4, 'slide', { duration: .100 });
    }
    <!--- Dev Note: KAL; D23601: Margin Items Exclude To Toggle the display --->
    toggleProdExcludeView = function(){
        /* Regular JS Code */
        var cellObject = document.getElementsByTagName("tr");

        /*Loop through the "<tr>" object. Look for specific "id" (below)*/
        for(i=0;i<cellObject.length;i++){
            if (cellObject[i].getAttribute('id') == 'excludeditems') {
            if (cellObject[i].style.display =='block' || cellObject[i].style.display == '')  {
                cellObject[i].style.display='none';
            }else{
                cellObject[i].style.display='block';
            }
            }
        }
    }

    $("input[name=checkall_Copy]").click(function() {
        let checkall = $(this).attr("checked") ? true : false;
        $("input.action").attr("checked", checkall);
    });

    window.onload = function () {
        let gridViewScroll = new GridViewScroll( {
                                                    elementID : "GridView1", // Target element id
                                                    width : ( $(window).width() - 10 ), // Integer or String(Percentage)
                                                    height : ( $(window).height() - 135 ), // Integer or String(Percentage)
                                                    freezeColumn : true, // Boolean
                                                    freezeFooter : false, // Boolean
                                                    freezeColumnCssClass : "GridViewScrollItemFreeze", // String
                                                    freezeFooterCssClass : "", // String
                                                    freezeHeaderRowCount : 1, // Integer
                                                    freezeColumnCount : 1 // Integer
                                            });

        gridViewScroll.enhance();
    }

<cfset targetpage = "winSummary_" & getProgramInfo.contract_main_id>
    function reloadFromPopUp()    /* reloadFromVerticalPNL */
        {
            bRefreshView = 1;
            var existingWin = window.open('', <cfoutput>'#targetpage#'</cfoutput>);
            existingWin.reloadFromPopUp();
            show_loader( "PROCESSING REQUEST, PLEASE WAIT...");
            location.reload();
        }
</script>

<cf_include files="/script/javascript/string_functions.js">





