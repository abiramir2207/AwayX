<!--
  * ====================================================================================================
  *    @File: \common_Files\contracts\verticalpnl_summary_hm.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2021 January
  *
  * @Remarks: Renders P&L summary for Huhtamaki
  *
  *
  * ====================================================================================================
-->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>

<cffunction name="render_empty_row" output="true">
    <tr class="GridViewScrollItem">
        <cfscript>
            // define a very short & sweet function scoped structure variable
            var l = {};
            l.ITEM_COUNT = 6;
        </cfscript>

        <cfoutput>
            <cfloop from="1" to="#(l.ITEM_COUNT + 2)#" index="l.counter">
                <td class="empty"> &nbsp; </td>
            </cfloop>
        </cfoutput>
    </tr>
</cffunction>

<cffunction name="render_row" output="true">
    <cfargument name="data" required="true" type="array">

    <tr class="GridViewScrollItem">
        <cfscript>
            // define a very short & sweet function scoped structure variable
            var l = {};
            l.first_cell     = arguments.data[1];
            l.prefix         = l.first_cell contains "$" ? "$" : '';
            l.postfix        = l.first_cell contains "%" ? "%" : '';
            l.is_summary     = arrayLen(arguments.data) eq 1;
            l.empty          = l.is_summary ? '' : '0';
            l.ITEM_COUNT = getAllProductMargins.recordcount ? getAllProductMargins.TC_Count + getAllProductMargins.TC_No_Companion_Count : 0;
        </cfscript>

        <cfoutput>
            <td <cfif arrayLen(arguments.data) eq 1>class="summary"<cfelse>class="x"</cfif>>
                #(arrayLen(arguments.data) eq 1  ? '' : "&nbsp; &nbsp; ")# #(arrayLen(arguments.data) gte 1 ? arguments.data[1] : '')#
            </td>

            <cfloop from="2" to="#(l.ITEM_COUNT + 2)#" index="l.counter">
                <td <cfif l.is_summary>class="summary"</cfif>>#l.prefix##(arrayLen(arguments.data) gte l.counter ? arguments.data[l.counter] : l.empty)##l.postfix#</td>
            </cfloop>
        </cfoutput>
    </tr>
</cffunction>

<cffunction name="render_row_Parent" output="true">
    <cfargument name="data" required="true" type="array">

    <tr class="GridViewScrollItem">
        <cfscript>
            // define a very short & sweet function scoped structure variable
            var l = {};
            l.first_cell     = arguments.data[1];
            l.prefix         = l.first_cell contains "$" ? "$" : '';
            l.postfix        = l.first_cell contains "%" ? "%" : '';
            l.is_summary     = arrayLen(arguments.data) eq 1;
            l.empty          = l.is_summary ? '' : '0';
            l.ITEM_COUNT = getAllProductMargins.recordcount ? getAllProductMargins.TC_Count + getAllProductMargins.TC_No_Companion_Count : 0;
        </cfscript>
        <cfoutput>
            <td <cfif arrayLen(arguments.data) eq 1>class="summary"<cfelse>class="x"</cfif>>
                #(arrayLen(arguments.data) eq 1  ? '' : "&nbsp; &nbsp; ")# #(arrayLen(arguments.data) gte 1 ? arguments.data[1] : '')#
            </td>
        </cfoutput>
        <td class="summary"><!--- <b>Grand Total</b> ---></td><!---  Grand Total Col --->
        <cfoutput query="qParent" group="Type_Code_Desc_ID">
                <cfset useLakebaseForlocal_detail = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qparent")>
<cfif useLakebaseForlocal_detail>
	<cftry>
		<cfset local.detail = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qparent", {
				"type_code_desc_id" = "eq.#qParent.Type_Code_Desc_ID#",
				"select" = "type_code_desc"
			}), "type_code_desc"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForlocal_detail = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForlocal_detail>
<cfquery name="local.detail" dbtype="query">
                    SELECT  Type_Code_Desc FROM qParent WHERE Type_Code_Desc_ID = '#qParent.Type_Code_Desc_ID#'
                </cfquery>
</cfif>
                <cfset data = local.detail.Type_Code_Desc>
                <td class="summary"><b>#application.util.string.wrapText(data,25)#</b></td>
        </cfoutput>

        <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                <td class="summary">&nbsp;</td>
        </cfoutput>
    </tr>
</cffunction>

<cffunction name="render_row_Companion" output="true">
    <cfargument name="data" required="true" type="array">

    <tr class="GridViewScrollItem">
        <cfscript>
            // define a very short & sweet function scoped structure variable
            var l = {};
            l.first_cell     = arguments.data[1];
            l.prefix         = l.first_cell contains "$" ? "$" : '';
            l.postfix        = l.first_cell contains "%" ? "%" : '';
            l.is_summary     = arrayLen(arguments.data) eq 1;
            l.empty          = l.is_summary ? '' : '0';
            l.ITEM_COUNT = getAllProductMargins.recordcount ? getAllProductMargins.TC_Count + getAllProductMargins.TC_No_Companion_Count : 0;
        </cfscript>
        <cfoutput>
            <td <cfif arrayLen(arguments.data) eq 1>class="summary"<cfelse>class="x"</cfif>>
                #(arrayLen(arguments.data) eq 1  ? '' : "&nbsp; &nbsp; ")# #(arrayLen(arguments.data) gte 1 ? arguments.data[1] : '')#
            </td>
        </cfoutput>
        <td class="summary"><!--- <b>Grand Total</b> ---></td><!---  Grand Total Col --->
        <cfoutput query="qChild" group="Type_Code_Desc_ID">
                <cfquery name="local.detail" dbtype="query">
                    SELECT  Child_Type_Code_Desc FROM qChild WHERE Type_Code_Desc_ID = '#qChild.Type_Code_Desc_ID#'
                </cfquery>
                <cfset data = local.detail.Child_Type_Code_Desc>
                <td class="summary"><b>#application.util.string.wrapText(data,25)#</b></td>
        </cfoutput>

        <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                <td class="summary">&nbsp;</td>
        </cfoutput>
    </tr>
</cffunction>

<cfscript>
    decimal_places          = application.util.query.get_setting("decimal_display_for_cs", 0);
    request.dollar_format   = "($9,." & repeatString("9", val(decimal_places));
    request.numeric_format  = "(9,.99)";
</cfscript>

<body>

    <CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
    <CFSET contract_main_id = cryp.value>

    <cfparam name="displayPreviousVersionMargin" default="1"> <!--- From the LH link in program, we set this to 0 --->
    <cfparam name="url.margin_version"           default="current">
    <cfparam name="variables.margin_version"     default="#url.margin_version#">     <!--- set default version to current --->
    <cfparam name="url.verticalPNL"              default="1">
    <cfparam name="url.showProducts"             default="1">
    <cfparam name="form.Margin_Type"             default="1">
    <cfparam name="form.agree"                   default="">
    <cfparam name="form.approve"                 default="">
    <cfparam name="form.restricted"              default="">

    <cfset appSettings = application.appSettingsGet>
    <cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval")>

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



    <cfset getProgramInfo = ApprovalProgramManager.getProgramInfo(contract_main_id)>
    <cfset getSettings = ApprovalProgramManager.getProgramSettngs(getProgramInfo.ProgramType_ID)>

    <!--- 66894 Margin Target ENH Forge START --->
    <cfif getSettings.Generic_Type EQ 'Operator Direct or HQ Programs' OR getSettings.Generic_Type EQ 'Operator-Deviated Pricing'>
        <cfset OperatorProgram = 1>
    <cfelse>
        <cfset OperatorProgram = 0>
    </cfif>

    <cfparam name="form.product_group_level_id" default="0">
    <cfparam name="form.product_group_level_list" default="">

    <!--- get all the products of the program --->
    <cfscript>
        getAllProductMargins = ApprovalProgramManager.getAllProductMarginsHM(program_id=contract_main_id, margin_type=form.Margin_Type, formCopy=form, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM);
        getCurrentProductMargins = ApprovalProgramManager.getAllProductMarginsHM(program_id=getProgramInfo.Revision_of_Contract_Main_ID, margin_type=form.Margin_Type, formCopy=form, margin_version = "approved", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM);
        GetSettings = CreateObject("component", "components.programs.template.TemplateManager").getProgramTemplate(contract_main_id);
        bDistributorMargin = GetSettings.P_And_L_Type == 'Distributor Trade' ? 1 : 0;
   </cfscript>
<!---     <cfelse>
        <cfset getAllProductMargins = ApprovalProgramManager.getAllProductMargins(program_id=contract_main_id, margin_type=form.Margin_Type, margin_version = "#margin_version#", Operator_Program= OperatorProgram, GlobalUom= Global_Target_UOM)>
    </cfif>
     --->
<cfif bDistributorMargin EQ 0>
     <cfquery name="qCompanions" dbtype="query">
        SELECT  * FROM getAllProductMargins WHERE Is_Parent_Item = 1 or Is_Companion_Item = 1 order by Type_Code_Desc,Item
    </cfquery>

    <cfquery name="qParent" dbtype="query">
        SELECT  * FROM getAllProductMargins WHERE Is_Parent_Item = 1 order by Type_Code_Desc,Item
    </cfquery>

    <cfquery name="qChild" dbtype="query">
        SELECT  * FROM getAllProductMargins WHERE Is_Companion_Item = 1 order by Type_Code_Desc,Item
    </cfquery>

    <cfquery name="qNoCompanion" dbtype="query">
         SELECT  * FROM getAllProductMargins WHERE Is_Parent_Item = 0 and Is_Companion_Item = 0 order by Type_Code_Desc,Item
    </cfquery>


     <cfquery name="qCompanionsCurrent" dbtype="query">
        SELECT  * FROM getCurrentProductMargins WHERE Is_Parent_Item = 1 or Is_Companion_Item = 1 order by Type_Code_Desc,Item
    </cfquery>

    <cfquery name="qNoCompanionCurrent" dbtype="query">
         SELECT  * FROM getCurrentProductMargins WHERE Is_Parent_Item = 0 and Is_Companion_Item = 0 order by Type_Code_Desc,Item
    </cfquery>
</cfif>
    <cfinclude template="/common_files/jQuery.cfm">

    <cf_include files=#arrayToList([	"/Script/javascript/GridViewScroll2Csv.js"
                                        , "/script/javascript/gridviewscroll/1.0/gridviewscroll.css"
                                        , "/script/javascript/gridviewscroll/1.0/gridviewscroll.js"
                                        ])#>
    <style>
        body {
            overflow: hidden;
        }
        .GridViewScrollHeader TH:first-child {
            text-align: right;
            width: 125px !important;

        }
        .GridViewScrollHeader th:first-child {
            text-align: center;
        }
        tr.GridViewScrollItem td, tr.GridViewScrollItemFreeze td {
            text-align: right;
        }
        th.summary,
        tr.GridViewScrollItem td.summary {
            background-color: #FFEDD2 !important;
        }
        tr.GridViewScrollItem td.empty {
            background-color: white !important;
        }
        tr.GridViewScrollItem td:first-child {
            text-align: left;
            background-color: #efefef;
            font-weight: bold;
        }
    </style>
    <br>
    <table cellspacing="0" id="pnl_summary" style="border-collapse:collapse;">
		<!----------------------->
		<!--- COLUMNS HEADING --->
		<!----------------------->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                                                                                    <!--- DISTRIBUTOR P&L VERSION IS AT tHE BOTTOM  --->
                                                                                            <!--- if bDistributorMargin EQ 1 --->
                                                                            <!---    *********  THIS NEEDS TO BE AUTOMATED *********  --->
                                                                        <!---    *********  VERTICALPNL_HM_UDF.CFM APPROACH *********  --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif bDistributorMargin EQ 0>
		<tr class="GridViewScrollHeader">
            <cfset br_tag_max = 0>
            <!--- find maximum number of br tags used in header columns --->
            <cfoutput query="qCompanions"  group="Type_Code_Desc_ID">
                <cfset br_tag_max = max(br_tag_max, ListValueCountNoCase( application.util.string.wrapText(qCompanions.Type_Code_Desc & ' ' & qCompanions.Child_Type_Code_Desc, 25), "br", "<,>" ))>
            </cfoutput>
			<cfoutput>
                <th class="une82">&nbsp;#repeatString("<br>&nbsp;", br_tag_max)#</th>
            </cfoutput>
            <th class="une82">Grand Total</th>
            <cfoutput query="qCompanions"  group="Type_Code_Desc_ID">
                <th>#application.util.string.wrapText(qCompanions.Type_Code_Desc & ' ' &qCompanions.Child_Type_Code_Desc,25)#</th>
            </cfoutput>
            <cfoutput query="qNoCompanion"  group="Type_Code_Desc_ID">
                <th>#application.util.string.wrapText(qNoCompanion.Type_Code_Desc,25)#</th>
            </cfoutput>
        </tr>

        <cfset render_row([ "<b>REQUESTED</b>" ])>
        <!--- <cfset render_row([ "Net Sales", 0 ])> --->
        <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
        <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;Net Sales $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM getAllProductMargins
                </cfquery>
                <cfset data = local.detail.Net_Sales>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>
                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.Net_Sales>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.Net_Sales>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;CM $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM getAllProductMargins
                </cfquery>
                <cfset data = local.detail.CM_D>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>

                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.CM_D>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.CM_D>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM %", 0 ])> --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;CM %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    cmDollar = local.detail.CM_D;
                    netSales = local.detail.Net_Sales;
                    if(netSales == 0 || !isNumeric(netSales)){
                        data = 0;
                    }
                    else{
                        data = (cmDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>

                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            cmDollar = local.detail.CM_D;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0 || !isNumeric(netSales)){
                                data = 0;
                            }
                            else{
                                data = (cmDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                         <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            cmDollar = local.detail.CM_D;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0 || !isNumeric(netSales)){
                                data = 0;
                            }
                            else{
                                data = (cmDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "GP $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    data = local.detail.Operating_Income;
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>

                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                             data = local.detail.Operating_Income;
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                         <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = local.detail.Operating_Income;
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
          <!---   <cfset render_row([ "GP %", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    gpDollar = local.detail.Operating_Income;
                    netSales = local.detail.Net_Sales;
                    if(netSales == 0 || !isNumeric(netSales)){
                        data = 0;
                    }
                    else{
                        data = (gpDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>

                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            gpDollar = local.detail.Operating_Income;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0){
                                data = 0;
                            }
                            else{
                                data = (gpDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                         <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            gpDollar = local.detail.Operating_Income;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0 || !isNumeric(netSales)){
                                data = 0;
                            }
                            else{
                                data = (gpDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>
            </tr>
            <!--- <cfset render_row([ "&nbsp;" ])> --->
            <!--- <cfset render_empty_row()> --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~          DELTA       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
          <!---   <cfdump var = '#getCurrentProductMargins#'> --->
            <cfset render_row([ "<b>DELTA</b>" ])>
            <cfif getCurrentProductMargins.recordcount EQ 0>
                <cfset render_row([ "Delta vs Current - Rev $", 0 ])>
                <cfset render_row([ "Delta vs Current - Rev %", 0 ])>
                <cfset render_row([ "Delta vs Current - CM $", 0 ])>
                <cfset render_row([ "Delta vs Current - CM %", 0 ])>
            <cfelse>
                 <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;Delta vs Current - Rev $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM getAllProductMargins
                </cfquery>
                <cfquery name="local.detailCurrent" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM getCurrentProductMargins
                </cfquery>
                <cfscript>
                    data = local.detail.recordCount && local.detailCurrent.recordCount ? local.detail.Net_Sales - local.detailCurrent.Net_Sales : 0;
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>
                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfquery name="local.detailCurrent" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.recordcount && local.detailCurrent.recordcount ? local.detail.Net_Sales - local.detailCurrent.Net_Sales : 0 >
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfquery name="local.detailCurrent" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = local.detail.recordcount && local.detailCurrent.recordcount ? local.detail.Net_Sales - local.detailCurrent.Net_Sales : 0;
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;Delta vs Current - Rev %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM getAllProductMargins
                </cfquery>
                <cfquery name="local.detailCurrent" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM getCurrentProductMargins
                </cfquery>
                <cfscript>
                    if(local.detail.recordCount == 0 || local.detailCurrent.recordCount == 0){
                        data = 0;
                    }
                    else{
                        data = local.detail.Net_Sales - local.detailCurrent.Net_Sales;
                        data = (data/local.detailCurrent.Net_Sales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>
                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfquery name="local.detailCurrent" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            if(local.detailCurrent.recordcount && local.detailCurrent.Net_Sales == 0){
                                data = 0;
                            }
                            else{
                                data = local.detail.Net_Sales - local.detailCurrent.Net_Sales;
                                data = (data/local.detailCurrent.Net_Sales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfquery name="local.detailCurrent" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            if(local.detail.recordCount == 0 || local.detailCurrent.recordCount == 0){
                                data = 0;
                            }
                            else{
                                data = local.detail.Net_Sales - local.detailCurrent.Net_Sales;
                                data = (data/local.detailCurrent.Net_Sales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM %", 0 ])> --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;Delta vs Current - CM $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS Net_Sales FROM getAllProductMargins
                </cfquery>
                <cfquery name="local.detailCurrent" dbtype="query">
                    SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS Net_Sales FROM getCurrentProductMargins
                </cfquery>
                <cfscript>
                    data = local.detail.recordCount && local.detailCurrent.recordCount ? local.detail.Net_Sales - local.detailCurrent.Net_Sales : 0;
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>
                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS Net_Sales FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfquery name="local.detailCurrent" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS Net_Sales FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.Net_Sales - local.detailCurrent.Net_Sales >
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS Net_Sales FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfquery name="local.detailCurrent" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS Net_Sales FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            if(local.detail.recordCount == 0 || local.detailCurrent.recordCount == 0){
                                data = 0;
                            }
                            else{
                                data = local.detail.Net_Sales - local.detailCurrent.Net_Sales;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "GP $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;Delta vs Current - CM %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM getAllProductMargins
                </cfquery>
                <cfquery name="local.detailCurrent" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM getCurrentProductMargins
                </cfquery>
                <cfscript>
                    cmDollar = local.detail.CM_D;
                    netSales = local.detail.Net_Sales;
                    if(netSales == 0 || local.detail.recordcount == 0){
                        data = 0;
                    }
                    else{
                        data = (cmDollar/netSales) * 100;
                    }
                    cmDollarCurr = local.detailCurrent.CM_D;
                    netSalesCurr = local.detailCurrent.Net_Sales;
                    if(netSalesCurr == '' || netSalesCurr == 0){
                        dataCurr = 0;
                    }
                    else{
                        dataCurr = (cmDollarCurr/netSalesCurr) * 100;
                    }
                    data = data - dataCurr;
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>
                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfquery name="local.detailCurrent" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            cmDollar = local.detail.CM_D;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0){
                                data = 0;
                            }
                            else{
                                data = (cmDollar/netSales) * 100;
                            }
                            cmDollarCurr = local.detailCurrent.CM_D;
                            netSalesCurr = local.detailCurrent.Net_Sales;
                            if(netSalesCurr == '' || netSalesCurr == 0){
                                dataCurr = 0;
                            }
                            else{
                                dataCurr = (cmDollarCurr/netSalesCurr) * 100;
                            }
                            data = data - dataCurr;
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfquery name="local.detailCurrent" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            cmDollar = local.detail.CM_D;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0 || local.detail.recordcount == 0){
                                data = 0;
                            }
                            else{
                                data = (cmDollar/netSales) * 100;
                            }
                            cmDollarCurr = local.detailCurrent.CM_D;
                            netSalesCurr = local.detailCurrent.Net_Sales;
                            if(netSalesCurr == '' || netSalesCurr == 0){
                                dataCurr = 0;
                            }
                            else{
                                dataCurr = (cmDollarCurr/netSalesCurr) * 100;
                            }
                            data = data - dataCurr;
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
          <!---   <cfset render_row([ "GP %", 0 ])> --->
      <!---       <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    gpDollar = local.detail.Operating_Income;
                    netSales = local.detail.Net_Sales;
                    if(netSales == 0){
                        data = 0;
                    }
                    else{
                        data = (gpDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>

                <cfoutput query="qCompanions" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qCompanions WHERE Type_Code_Desc_ID = '#qCompanions.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            gpDollar = local.detail.Operating_Income;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0){
                                data = 0;
                            }
                            else{
                                data = (gpDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                         <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            gpDollar = local.detail.Operating_Income;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0){
                                data = 0;
                            }
                            else{
                                data = (gpDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>
            </tr> --->
            </cfif>
            <!--- <cfset render_empty_row()> --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         CURRENT             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <cfset render_row([ "<b>CURRENT</b>" ])>
            <cfif getCurrentProductMargins.recordcount EQ 0>
                <cfset render_row([ "Net Sales $", 0 ])>
                <cfset render_row([ "CM $", 0 ])>
                <cfset render_row([ "CM %", 0 ])>
                <cfset render_row([ "GP $", 0 ])>
                <cfset render_row([ "GP %", 0 ])>
            <cfelse>
                 <!--- <cfset render_row([ "Net Sales", 0 ])> --->
                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                 <tr class="GridViewScrollItem">
                    <td class="une82">&nbsp; &nbsp; &nbsp;Net Sales $</td>
                    <cfquery name="local.detail" dbtype="query">
                        SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM getCurrentProductMargins
                    </cfquery>
                    <cfset data = local.detail.Net_Sales>
                    <cfoutput>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    </cfoutput>
                    <cfoutput query="qCompanionsCurrent" group="Type_Code_Desc_ID">
                        <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                            <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanionsCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfset data = local.detail.Net_Sales>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                        <!--- </cfoutput> --->
                    </cfoutput>  <!--- query="getAllProductMargins"> --->

                    <cfoutput query="qNoCompanionCurrent" group="Type_Code_Desc_ID">
                        <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                            <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanionCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfset data = local.detail.Net_Sales>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                        <!--- </cfoutput> --->
                    </cfoutput>
                </tr>

                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- <cfset render_row([ "CM $", 0 ])> --->
                <tr class="GridViewScrollItem">
                    <td class="une82">&nbsp; &nbsp; &nbsp;CM $</td>
                    <cfquery name="local.detail" dbtype="query">
                        SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM getCurrentProductMargins
                    </cfquery>
                    <cfset data = local.detail.CM_D>
                    <cfoutput>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    </cfoutput>

                    <cfoutput query="qCompanionsCurrent" group="Type_Code_Desc_ID">
                        <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                            <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanionsCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfset data = local.detail.CM_D>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                        <!--- </cfoutput> --->
                    </cfoutput>  <!--- query="getAllProductMargins"> --->

                    <cfoutput query="qNoCompanionCurrent" group="Type_Code_Desc_ID">
                        <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                            <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanionCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfset data = local.detail.CM_D>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                        <!--- </cfoutput> --->
                    </cfoutput>
                </tr>
                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- <cfset render_row([ "CM %", 0 ])> --->
                 <tr class="GridViewScrollItem">
                    <td class="une82">&nbsp; &nbsp; &nbsp;CM %</td>
                    <cfquery name="local.detail" dbtype="query">
                        SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM getCurrentProductMargins
                    </cfquery>
                    <cfscript>
                        cmDollar = local.detail.CM_D;
                        netSales = local.detail.Net_Sales;
                        if(netSales == 0){
                            data = 0;
                        }
                        else{
                            data = (cmDollar/netSales) * 100;
                        }
                    </cfscript>
                    <cfoutput>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                    </cfoutput>

                    <cfoutput query="qCompanionsCurrent" group="Type_Code_Desc_ID">
                            <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanionsCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfscript>
                                cmDollar = local.detail.CM_D;
                                netSales = local.detail.Net_Sales;
                                if(netSales == 0){
                                    data = 0;
                                }
                                else{
                                    data = (cmDollar/netSales) * 100;
                                }
                            </cfscript>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                    </cfoutput>  <!--- query="getAllProductMargins"> --->

                    <cfoutput query="qNoCompanionCurrent" group="Type_Code_Desc_ID">
                             <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanionCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfscript>
                                cmDollar = local.detail.CM_D;
                                netSales = local.detail.Net_Sales;
                                if(netSales == 0){
                                    data = 0;
                                }
                                else{
                                    data = (cmDollar/netSales) * 100;
                                }
                            </cfscript>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                    </cfoutput>
                </tr>
                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- <cfset render_row([ "GP $", 0 ])> --->
                <tr class="GridViewScrollItem">
                    <td class="une82">&nbsp; &nbsp; &nbsp;GP $</td>
                    <cfquery name="local.detail" dbtype="query">
                        SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getCurrentProductMargins
                    </cfquery>
                    <cfscript>
                        data = local.detail.Operating_Income;
                    </cfscript>
                    <cfoutput>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    </cfoutput>

                    <cfoutput query="qCompanionsCurrent" group="Type_Code_Desc_ID">
                            <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanionsCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfscript>
                                 data = local.detail.Operating_Income;
                            </cfscript>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    </cfoutput>  <!--- query="getAllProductMargins"> --->

                    <cfoutput query="qNoCompanionCurrent" group="Type_Code_Desc_ID">
                             <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanionCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfscript>
                                data = local.detail.Operating_Income;
                            </cfscript>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    </cfoutput>
                </tr>

                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
              <!---   <cfset render_row([ "GP %", 0 ])> --->
                <tr class="GridViewScrollItem">
                    <td class="une82">&nbsp; &nbsp; &nbsp;GP %</td>
                    <cfquery name="local.detail" dbtype="query">
                        SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getCurrentProductMargins
                    </cfquery>
                    <cfscript>
                        gpDollar = local.detail.Operating_Income;
                        netSales = local.detail.Net_Sales;
                        if(netSales == 0){
                            data = 0;
                        }
                        else{
                            data = (gpDollar/netSales) * 100;
                        }
                    </cfscript>
                    <cfoutput>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                    </cfoutput>

                    <cfoutput query="qCompanionsCurrent" group="Type_Code_Desc_ID">
                            <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qCompanionsCurrent WHERE Type_Code_Desc_ID = '#qCompanionsCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfscript>
                                gpDollar = local.detail.Operating_Income;
                                netSales = local.detail.Net_Sales;
                                if(netSales == 0){
                                    data = 0;
                                }
                                else{
                                    data = (gpDollar/netSales) * 100;
                                }
                            </cfscript>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                    </cfoutput>  <!--- query="getAllProductMargins"> --->

                    <cfoutput query="qNoCompanionCurrent" group="Type_Code_Desc_ID">
                             <cfquery name="local.detail" dbtype="query">
                                SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qNoCompanionCurrent WHERE Type_Code_Desc_ID = '#qNoCompanionCurrent.Type_Code_Desc_ID#'
                            </cfquery>
                            <cfscript>
                                gpDollar = local.detail.Operating_Income;
                                netSales = local.detail.Net_Sales;
                                if(netSales == 0){
                                    data = 0;
                                }
                                else{
                                    data = (gpDollar/netSales) * 100;
                                }
                            </cfscript>
                            <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                    </cfoutput>
                </tr>
            </cfif>
            <!--- <cfset render_empty_row()> --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~         MAIN ITEM SUMMARY       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
           <!---  <cfset render_row([ "<b>MAIN ITEM SUMMARY</b>" ])> --->
           <cfset render_row_Parent([ "<b>MAIN ITEM SUMMARY</b>" ])>
            <!--- <cfset render_row([ "Net Sales", 0 ])>
            <cfset render_row([ "CM $", 0 ])>
            <cfset render_row([ "CM %", 0 ])>
            <cfset render_row([ "GP $", 0 ])>
            <cfset render_row([ "GP %", 0 ])> --->
             <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;Net Sales $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qParent
                </cfquery>
                <cfscript>
                    data = 0;
                    if(local.detail.recordcount){
                        data = local.detail.Net_Sales;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )# ---></td>
                </cfoutput>
                <cfoutput query="qParent" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qParent WHERE Type_Code_Desc_ID = '#qParent.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = 0;
                            if(local.detail.recordcount){
                                data = local.detail.Net_Sales;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <!--- <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.Net_Sales>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td> --->
                        <td>&nbsp;</td>
                    <!--- </cfoutput> --->
                </cfoutput>
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;CM $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qParent
                </cfquery>
                <cfscript>
                    data = 0;
                    if(local.detail.recordcount){
                        data = local.detail.CM_D;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )# ---></td>
                </cfoutput>

                <cfoutput query="qParent" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qParent WHERE Type_Code_Desc_ID = '#qParent.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = 0;
                            if(local.detail.recordcount){
                                data = local.detail.CM_D;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <!--- <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.CM_D>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td> --->
                        <td>&nbsp;</td>
                    <!--- </cfoutput> --->
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM %", 0 ])> --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;CM %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM qParent
                </cfquery>
                <cfscript>
                    cmDollar = local.detail.CM_D;
                    netSales = local.detail.Net_Sales;
                    data = 0;
                    if(netSales != 0 AND local.detail.recordcount){
                        data = (cmDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#% ---></td>
                </cfoutput>

                <cfoutput query="qParent" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qParent WHERE Type_Code_Desc_ID = '#qParent.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            cmDollar = local.detail.CM_D;
                            netSales = local.detail.Net_Sales;
                            data = 0;
                            if(netSales != 0 AND local.detail.recordcount){
                                data = (cmDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                        <td>&nbsp;</td>
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "GP $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qParent
                </cfquery>
                <cfscript>
                    data = 0;
                    if(local.detail.recordcount){
                        data = local.detail.Operating_Income;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )# ---></td>
                </cfoutput>

                <cfoutput query="qParent" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qParent WHERE Type_Code_Desc_ID = '#qParent.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                             data = 0;
                            if(local.detail.recordcount){
                                data = local.detail.Operating_Income;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                         <!--- cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = local.detail.Operating_Income;
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td> --->
                        <td>&nbsp;</td>
                </cfoutput>
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
          <!---   <cfset render_row([ "GP %", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qParent
                </cfquery>
                <cfscript>
                    gpDollar = local.detail.Operating_Income;
                    netSales = local.detail.Net_Sales;
                    data = 0;
                    if(netSales != 0 AND local.detail.recordcount){
                        data = (gpDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#% ---></td>
                </cfoutput>

                <cfoutput query="qParent" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qParent WHERE Type_Code_Desc_ID = '#qParent.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            gpDollar = local.detail.Operating_Income;
                            netSales = local.detail.Net_Sales;
                            data = 0;
                            if(netSales != 0 AND local.detail.recordcount){
                                data = (gpDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                        <td>&nbsp;</td>
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      COMPANION ITEM SUMMARY  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_empty_row()> --->
            <!--- <tr class="GridViewScrollHeader">
                <th></th>
                <th>Grand Total</th>
                <cfoutput query="qChild"  group="Type_Code_Desc_ID">
                    <cfquery name="local.detail" dbtype="query">
                            SELECT  Child_Type_Code_Desc FROM qChild WHERE Type_Code_Desc_ID = '#qChild.Type_Code_Desc_ID#'
                    </cfquery>
                    <th>#local.detail.Child_Type_Code_Desc#</th>
                </cfoutput>
                <cfoutput query="qNoCompanion"  group="Type_Code_Desc_ID">
                    <th>&nbsp;</th>
                </cfoutput>
            </tr> --->
            <cfset render_row_Companion([ "<b>COMPANION ITEM SUMMARY</b>" ])>
            <!--- <cfset render_row([ "Net Sales", 0 ])>
            <cfset render_row([ "CM $", 0 ])>
            <cfset render_row([ "CM %", 0 ])>
            <cfset render_row([ "GP $", 0 ])>
            <cfset render_row([ "GP %", 0 ])> --->
             <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;Net Sales $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qChild
                </cfquery>
                <cfscript>
                    data = 0;
                    if(local.detail.recordcount){
                        data = local.detail.Net_Sales;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )# ---></td>
                </cfoutput>
                <cfoutput query="qChild" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qChild WHERE Type_Code_Desc_ID = '#qChild.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = 0;
                            if(local.detail.recordcount){
                                data = local.detail.Net_Sales;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <!--- <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.Net_Sales>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td> --->
                        <td>&nbsp;</td>
                    <!--- </cfoutput> --->
                </cfoutput>
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;CM $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    data = 0;
                    if(local.detail.recordcount){
                        data = local.detail.CM_D;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )# ---></td>
                </cfoutput>

                <cfoutput query="qChild" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qChild WHERE Type_Code_Desc_ID = '#qChild.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = 0;
                            if(local.detail.recordcount){
                                data = local.detail.CM_D;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <!--- <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.CM_D>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td> --->
                        <td>&nbsp;</td>
                    <!--- </cfoutput> --->
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM %", 0 ])> --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;CM %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    cmDollar = local.detail.CM_D;
                    netSales = local.detail.Net_Sales;
                    data = 0;
                    if(netSales != 0 AND local.detail.recordcount){
                        data = (cmDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#% ---></td>
                </cfoutput>

                <cfoutput query="qChild" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qChild WHERE Type_Code_Desc_ID = '#qChild.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            cmDollar = local.detail.CM_D;
                            netSales = local.detail.Net_Sales;
                            data = 0;
                            if(netSales != 0 AND local.detail.recordcount){
                                data = (cmDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                         <!--- <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            cmDollar = local.detail.CM_D;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0){
                                data = 0;
                            }
                            else{
                                data = (cmDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td> --->
                        <td>&nbsp;</td>
                </cfoutput>
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "GP $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    data = 0;
                    if(local.detail.recordcount){
                        data = local.detail.Operating_Income;
                    }
                </cfscript>
                <cfoutput>
                     <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )# ---></td>
                </cfoutput>

                <cfoutput query="qChild" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qChild WHERE Type_Code_Desc_ID = '#qChild.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = 0;
                            if(local.detail.recordcount){
                                data = local.detail.Operating_Income;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                         <!--- <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            data = local.detail.Operating_Income;
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td> --->
                        <td>&nbsp;</td>
                </cfoutput>
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
          <!---   <cfset render_row([ "GP %", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    gpDollar = local.detail.Operating_Income;
                    netSales = local.detail.Net_Sales;
                    data = 0;
                    if(netSales != 0 AND local.detail.recordcount){
                        data = (gpDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td><!--- #application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#% ---></td>
                </cfoutput>

                <cfoutput query="qChild" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qChild WHERE Type_Code_Desc_ID = '#qChild.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            gpDollar = local.detail.Operating_Income;
                            netSales = local.detail.Net_Sales;
                            data = 0;
                            if(netSales != 0 AND local.detail.recordcount){
                                data = (gpDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->

                <cfoutput query="qNoCompanion" group="Type_Code_Desc_ID">
                         <!--- <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM qNoCompanion WHERE Type_Code_Desc_ID = '#qNoCompanion.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            gpDollar = local.detail.Operating_Income;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0){
                                data = 0;
                            }
                            else{
                                data = (gpDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td> --->
                        <td>&nbsp;</td>
                </cfoutput>
            </tr>
    </cfif>     <!--- END bDistributorMargin EQ 0 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--->
        <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                                                                                    <!--- RFP P&L VERSION END  --->
                                                                                <!--- if bDistributorMargin EQ 0 END--->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                                                                                    <!--- DISTRIBUTOR P&L VERSION  --->
                                                                                <!--- if bDistributorMargin EQ 1 --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

    <cfif bDistributorMargin EQ 1>    <!--- START ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <tr class="GridViewScrollHeader">
                <th></th>
                <th>Grand Total</th>
                <cfoutput query="getAllProductMargins"  group="Type_Code_Desc_ID">
                    <th>#application.util.string.wrapText(getAllProductMargins.Type_Code_Desc & ' ' &getAllProductMargins.Child_Type_Code_Desc,25)#</th>
                </cfoutput>
            </tr>

            <cfset render_row([ "<b>REQUESTED</b>" ])>
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;Net Sales $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM getAllProductMargins
                </cfquery>
                <cfset data = local.detail.Net_Sales>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>
                <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Net_Sales * Product_Program_Volume) AS Net_Sales FROM getAllProductMargins WHERE Type_Code_Desc_ID = '#getAllProductMargins.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.Net_Sales>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>  <!--- query="getAllProductMargins"> --->
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;CM $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM getAllProductMargins
                </cfquery>
                <cfset data = local.detail.CM_D>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>

                <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                    <!--- <cfoutput> --->  <!--- invidual products cfoutput loop --->
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM getAllProductMargins WHERE Type_Code_Desc_ID = '#getAllProductMargins.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfset data = local.detail.CM_D>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    <!--- </cfoutput> --->
                </cfoutput>  <!--- query="getAllProductMargins"> --->
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "CM %", 0 ])> --->
             <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;CM %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D  FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    cmDollar = local.detail.CM_D;
                    netSales = local.detail.Net_Sales;
                    if(netSales == 0){
                        data = 0;
                    }
                    else{
                        data = (cmDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>

                <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, SUM(Contribution_Margin_Alt * Product_Program_Volume) AS CM_D FROM getAllProductMargins WHERE Type_Code_Desc_ID = '#getAllProductMargins.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            cmDollar = local.detail.CM_D;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0){
                                data = 0;
                            }
                            else{
                                data = (cmDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->
            </tr>
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!--- <cfset render_row([ "GP $", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP $</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    data = local.detail.Operating_Income;
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>

                <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume,  sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins WHERE Type_Code_Desc_ID = '#getAllProductMargins.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                             data = local.detail.Operating_Income;
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->
            </tr>

            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
            <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
          <!---   <cfset render_row([ "GP %", 0 ])> --->
            <tr class="GridViewScrollItem">
                <td class="une82">&nbsp; &nbsp; &nbsp;GP %</td>
                <cfquery name="local.detail" dbtype="query">
                    SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins
                </cfquery>
                <cfscript>
                    gpDollar = local.detail.Operating_Income;
                    netSales = local.detail.Net_Sales;
                    if(netSales == 0){
                        data = 0;
                    }
                    else{
                        data = (gpDollar/netSales) * 100;
                    }
                </cfscript>
                <cfoutput>
                    <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>

                <cfoutput query="getAllProductMargins" group="Type_Code_Desc_ID">
                        <cfquery name="local.detail" dbtype="query">
                            SELECT  sum(Product_Program_Volume) AS Product_Program_Volume, sum(Net_Sales * Product_Program_Volume) AS Net_Sales, sum(Operating_Income * Product_Program_Volume) AS Operating_Income FROM getAllProductMargins WHERE Type_Code_Desc_ID = '#getAllProductMargins.Type_Code_Desc_ID#'
                        </cfquery>
                        <cfscript>
                            gpDollar = local.detail.Operating_Income;
                            netSales = local.detail.Net_Sales;
                            if(netSales == 0){
                                data = 0;
                            }
                            else{
                                data = (gpDollar/netSales) * 100;
                            }
                        </cfscript>
                        <td>#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                </cfoutput>  <!--- query="getAllProductMargins"> --->
            </tr>
        </cfif> <!--- END bDistributorMargin EQ 1   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                                                                                    <!--- DISTRIBUTOR P&L VERSION END  --->
                                                                                     <!--- if bDistributorMargin EQ 0 --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!---  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    </table>

    <script>
        "use strict";


        let gridViewScroll = new GridViewScroll( {
                                                elementID : "pnl_summary", // Target element id

                                                width : ( $(window).width() - 15 ), // Integer or String(Percentage)
                                                height : ( $(window).height() - 35 ), // Integer or String(Percentage)

                                                freezeColumn : true, // Boolean
                                                freezeFooter : false, // Boolean
                                                freezeColumnCssClass : "GridViewScrollItemFreeze", // String
                                                freezeFooterCssClass : "", // String
                                                freezeHeaderRowCount : 1, // Integer
                                                freezeColumnCount : 2 // Integer
                                        });
        gridViewScroll.enhance();
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>