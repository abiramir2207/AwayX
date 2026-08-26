<!--
  * ====================================================================================================
  *    @File: \common_Files\contracts\verticalpnl_hm_udf.cfm
  *  @Author: Chris Nguyen
  *    @Date: January 2021
  *
  * @Remarks: Render vertical P&L for Huhtamaki
  *
  *
  *
  *
  * ====================================================================================================
 -->


<cfoutput>
<cfparam name="url.bReset" default="0">
<input type="hidden" name="product_count" value="#getAllProductMargins.recordCount#">
<input type="hidden" name="next_page_url">
<input type="hidden" name="action">
<input type="hidden" name="page_view" value="#(url.detail7 eq "show" ? 'detail' : 'compact')#">   <!--- compact (w/o elements under discount, trade, cost) | detail  (with elements under discount, trade, cost) --->
</cfoutput>
<cf_include files=#arrayToList( [ "/common_files/jQuery.cfm"] )#>

<cfoutput query="getAllProductMargins">
    <!--- keep track of product IDs: first product is stored in input element named as 'prod_id_1' and has a value of BSA_Foodservice_Items_Master_ID --->
    <input type="hidden" name="prod_id_#getAllProductMargins.currentRow#" value="#getAllProductMargins.BSA_Foodservice_Items_Master_ID#">
</cfoutput>

<cfset variables.noApprovalClass =	 "">
<cfset variables.disabled2       =  "">

<!--- <cfsavecontent variable="variables.mainContent"> --->
    <cfoutput>
    <div id="actions">
        <cfset url.detail7 = "show">    <!--- displays all rows for Tyson --->
        <cfset variables.moreless = (url.detail7 eq "show" ? "less -" : "more +")>

        <cfif url.verticalPNL eq "2">
            <a href="##" id="calc38">#application.util.string.actionLinkFormat2("calculate", "important")#</a>
            <a href="##" id="save38">#application.util.string.actionLinkFormat2("save")#</a>
            <a href="##" id="reset38">#application.util.string.actionLinkFormat2("reset")#</a>
            <a href="##" id="export82">#application.util.string.actionLinkFormat2("export to csv")#</a>
        <cfelse>
            <cfquery name="qProductLevel" datasource="#application.datasource#">
                /*** Common_Files\contracts\verticalpnl_hm_udf.cfm - around line 44 ***/
                SELECT l.Product_Group_Level_ID
                        , l.Group_Level_Desc
                        , l.Group_Internal_Label
                FROM   Product_Group_Level l
                WHERE l.Deleted                    = 0
                AND   l.Active                     = 1
                AND   l.Is_PG                      = 0
                AND   l.Product_Group_Level_Type != 2
            </cfquery>

            <input name="product_group_level_list" type="hidden" value="#form.product_group_level_list#">

      <!---       <select name="product_group_level_id" style="margin:0 8px 0 5px;">
                <option value="0">#application.returned_customer_setting.item_label# Level</option>
                <cfloop query="qProductLevel">
                    <option value="#qProductLevel.Product_Group_Level_ID#" <cfif form.product_group_level_id eq qProductLevel.Product_Group_Level_ID>selected</cfif>>#qProductLevel.Group_Level_Desc#</option>
                </cfloop>
            </select> --->
         <!---    <a href='javaScript:void(0);' id="apply_groups">#application.util.string.linkFormat('apply')#</a> --->
            <cfif isEditing.recordCount and form.product_group_level_list eq "">
                <a href='javaScript:void(0);' id="save_vertical_pnl">#application.util.string.linkFormat('save')#</a>
                <a href='javaScript:void(0);' id="update_to_system_values">#application.util.string.linkFormat('update to system values')#</a>
            </cfif>

           <!---  <a href="##" id="export82">#application.util.string.linkFormat("export to csv")#</a> --->
        </cfif>

        <a href="javascript:parent.window.close();" id="close_window">#application.util.string.linkFormat("close window")#</a>
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
     <input type="hidden" name="margin_type" value="#form.margin_type#">
    <div style="clear:both;padding-bottom:5px;"></div>
    <cfset qMargin_Override = ApprovalProgramManager.getMarginOverride(getProgramInfo.contract_main_id, form.margin_type)>
    </cfoutput>

    <cfquery name="local.qMisc" datasource="#application.datasource#">
        /*** Common_Files\contracts\verticalpnl_hm_udf.cfm - around line 123 ****/
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
   <!--- <cfset qCostDetail = get_cost_detail( getProgramInfo.contract_main_id )> --->
   <cfscript>
        GetSettings = CreateObject("component", "components.programs.template.TemplateManager").getProgramTemplate(getProgramInfo.contract_main_id);
        qGetPreviousMargins = ApprovalProgramManager.getAllProductMarginsHM(program_id=getProgramInfo.Revision_of_Contract_Main_ID, margin_type=1, margin_version = "approved");
        bDistributorMargin = GetSettings.P_And_L_Type == 'Distributor Trade' ? 1 : 0;
   </cfscript>
   
    <!---   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
             XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                                                            WE NEED DATA FROM Contract_Product_Margin_Approved
                                                                            NOT "Current"
                                                                           -> "Approved"
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX--->
    <!--- ngt --->
    <style>
        #actions {margin: 0px 0 0px 0;float:left;padding-top: 9px;}
        .GridViewScrollHeader TH, .GridViewScrollHeader TD {
            background-color: #FFCE84;
        }
        .GridViewScrollHeader TH {
            text-align: right;
            width: 125px !important;
        }
 /*       .GridViewScrollHeader th:first-child {
            text-align: left;
        }*/
        th.sum82, td.sum82 {
            display: none;
        }
        span.bottom {
          position: relative;
          bottom: -8px;
          left: -8px;
          text-align: left;
          width:100%;
        } 
        td.total82 {
            background-color: #FFEDD2 !important;
            font-weight: bold;
            letter-spacing: 0.5px;
            text-align: left;
            text-transform: uppercase;
            border-left: none;
            border-right: none;
        }
        td.spacer {
            background-color: #FFEDD2 !important;
            padding-left: 5px;
        }
        td.empty82 {
            background-color: white;
        }
        tr.GridViewScrollItem:hover td2, td.active {
            background-color: #e6f0ff;
        }
        td.une82, th.une82 {
            padding-left: 5px;
        }
        tr.GridViewScrollItem td.empty {
            background-color: white !important;
            border-left: none;
            border-right: none;
        }
        tr.GridViewScrollItem td.right {
            text-align: right;
        }
        td.right {
            text-align: right;
        }
    </style>

    <cffunction name="render_row" output="true">
        <cfargument name="data" required="true" type="array">

        <tr class="GridViewScrollItem">
            <cfscript>
                // define a very short & sweet function scoped structure variable
                var l = {};

                l.first_cell     = arrayLen(arguments.data) gte 1 ? arguments.data[1] : '';
                l.is_total       = l.first_cell contains "Total ";
                l.first_cell     = (l.is_total ? "" : "&nbsp; &nbsp; &nbsp; ") & l.first_cell;
                l.first_cell_css = l.is_total ? "total82" : "une82";
                l.empty          = l.is_total ? "" : "0";
                l.prefix         = l.first_cell contains "$" ? "$" : '';
                l.postfix        = l.first_cell contains "%" ? "%" : '';

                // TODO: adjust this constant value based on number of actual frozen columns
                l.FROZEN_COLUMNS = 1;
                l.counter        = l.FROZEN_COLUMNS;
            </cfscript>
            
            <td class="#l.first_cell_css#">#l.first_cell#</td>
            <!--- <td class="sum82 empty82">#(arrayLen(arguments.data) gte 2 ? arguments.data[2] : '')#</td>
            <td class="sum82 empty82">#(arrayLen(arguments.data) gte 3 ? arguments.data[3] : '')#</td> --->

            <cfoutput query="getAllProductMargins">
                        <cfset l.counter++>
                        <td <cfif l.is_total>class="total82"</cfif>>#l.prefix##(arrayLen(arguments.data) gte l.counter ? arguments.data[l.counter] : l.empty)##l.postfix#</td>
            </cfoutput>
        </tr>    
    </cffunction>

    <cffunction name="render_item_row" output="true">
        <cfargument name="col" required="true" type="String">
        <cfargument name="title" required="true" type="String"  default="">
        <cfargument name="dType" required="true" type="String" default="">
        <cfargument name="decPlaces" required="true" type="any" default="">
        <cfargument name="bEdit" required="true" type="any" default="0">
        <cfargument name="bPrevious" required="true" type="any" default="0">
            <cfscript>
                // define a very short & sweet function scoped structure variable
                var a = arguments;
            </cfscript>
         <tr class="GridViewScrollItem">
            <td class="une82"><cfoutput>#a.title#</cfoutput></td>
            <cfoutput query="getAllProductMargins">
                <cfscript>
                    var l = {};
                    l.noApprovalClass = (getAllProductMargins.Group_ID_Approval eq 0 ? "noar" : "");
                     if(bPrevious){ /* USE PREVIOUS VOLUME */
                        l.value = 0;
                        l.vol = 0;
                        if(qGetPreviousMargins.recordcount){
                            l.q = queryExecute( "select * from qGetPreviousMargins where  Product_ID = '#getAllProductMargins.Product_ID#'", [],{dbtype="query"} );
                            if(l.q.recordcount){
                                l.vol = l.q.Product_Program_Volume;
                            } /* IF l.q.recordcount */
                        } /* IF qGetPreviousMargins.recordcount*/
                     }
                     else{  /*ELSE USE CURRENT VOLUME */
                        l.vol = getAllProductMargins.Product_Program_Volume;
                     }

                    l.net = getAllProductMargins.Net_Sales;
                    l.netSales = l.vol * l.net;
                    switch(a.col) {   
                        case "Case_Count,Product_Program_Volume":
                            l.cc = getAllProductMargins.Case_Count;
                            l.value = l.cc * l.vol;
                            break; 
                        case "Net_Sales,Product_Program_Volume":
                            l.value = l.netSales;
                            break; 
                        case "Contribution_Margin_Alt,Product_Program_Volume":
                            l.cm = getAllProductMargins.Contribution_Margin_Alt;
                            l.value = l.cm * l.vol;
                            break;
                        case "Contribution_Margin_Alt,Net_Sales":   /* CM %*/
                            l.cm = getAllProductMargins.Contribution_Margin_Alt;
                            l.cmDollar = l.vol * l.cm;
                            l.value = l.netSales == 0 ? 0 : (l.cmDollar/l.netSales) * 100;
                            break;
                        case "Operating_Income,Product_Program_Volume":  /*  GP $ */
                            l.gp = getAllProductMargins.Operating_Income;
                            l.value = l.gp * l.vol;
                            break;
                        case "Operating_Income,Net_Sales":  /*  GP % */
                            l.gpDollar = l.vol * getAllProductMargins.Operating_Income;
                            l.value = l.netSales == 0 ? 0 : (l.gpDollar/l.netSales) * 100;
                            break;
                        default:
                            if(bPrevious && l.vol == 0){ /* USE PREVIOUS VOLUME */
                                l.value = 0;
                            }
                            else if(bPrevious){
                                l.value = l.q[a.col];
                            }
                            else{
                                l.value = getAllProductMargins[a.col];
                            }
                            break; 
                    } /* SWITCH */
                     
                     // else{ /*ELSE USE CURRENT VOLUME */
                     //    l.vol = getAllProductMargins.Product_Program_Volume;
                     //    l.net = getAllProductMargins.Net_Sales;
                     //    l.netSales = l.vol * l.net;
                     //    switch(a.col) {
                     //        case "Case_Count,Product_Program_Volume":
                     //            l.cc = getAllProductMargins['Case_Count'];
                     //            l.value = l.cc * l.vol;
                     //            break; 
                     //        case "Net_Sales,Product_Program_Volume":
                     //            l.value = l.netSales;
                     //            break; 
                     //        case "Contribution_Margin_Alt,Product_Program_Volume":
                     //            l.cm = getAllProductMargins.Contribution_Margin_Alt;
                     //            l.value = l.cm * l.vol;
                     //            break;
                     //        case "Contribution_Margin_Alt,Net_Sales":   /* CM %*/
                     //            l.cm = getAllProductMargins.Contribution_Margin_Alt;
                     //            l.cmDollar = l.vol * l.cm;
                     //            l.value = l.netSales == 0 ? 0 : (l.cmDollar/l.netSales) * 100;
                     //            break;
                     //        case "Operating_Income,Product_Program_Volume":  /*  GP $ */
                     //            l.gp = getAllProductMargins.Operating_Income;
                     //            l.value = l.gp * l.vol;
                     //            break;
                     //        case "Operating_Income,Net_Sales":  /*  GP % */
                     //            l.gpDollar = l.vol * getAllProductMargins.Operating_Income;
                     //            l.value = l.netSales == 0 ? 0 : (l.gpDollar/l.netSales) * 100;
                     //            break;
                     //        default: 
                     //            l.value = getAllProductMargins[a.col];
                     //            break; 
                     //     }

                     // }

                     l.value = trim(application.util.string.cellFormat(value=l.value, category = a.dType, decimalplaces = a.decPlaces ));
                     variables.value = l.value;
                </cfscript>

                <cfif a.bEdit>
                    <td class="#l.noApprovalClass#">
                        #big_star(a.col, getAllProductMargins.Product_ID, getAllProductMargins.currentRow)#
                        <input type="text" name="#a.col#_#getAllProductMargins.currentRow#" class="right numeric #neg_css(variables.value )#" #tabIndex(8)#  value="#sanitize_input(variables.value)#" >
                    </td>
                <cfelse>
                    <td>#variables.value#<cfif a.title contains'%'>%</cfif></td>
                </cfif>
                
                <!--- <td>#l.value#</td> --->
            </cfoutput>  
        </tr>    
    </cffunction>
    <table cellspacing="0" id="GridView1" style="border-collapse:collapse;">

        <!----------------------->
        <!--- COLUMNS HEADING --->
        <!----------------------->
        <tr class="GridViewScrollHeader">
            <th class="une82" id="one82" style="text-align: left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="bottom"><input type="checkbox" id="selectAll" onclick="selectCheck(this);"></span></th>

            <cfoutput query="getAllProductMargins">
                    <th class="une82" id="one82">   <!--- do not change class name it would break the what-if calculation logic --->
                        <!--- <input type="checkbox" id="cbox" name="chk_upd_#getAllProductMargins.currentRow#"> --->
                        <cfset item_UPC =''>
                        <cfif (showItem eq '0' OR showItem eq '') AND application.returned_customer_setting.upc_switch EQ 1>
                            <cfset item_UPC = getAllProductMargins.upc>
                        <cfelse>
                            <cfset item_UPC = getAllProductMargins.Item>
                        </cfif>
                        <cfif appSettings.getViewPgmSortBy()>  <!--- YES --->
                               <span  class="bottom"><input type="checkbox" id="cbox" name="chk_upd_#getAllProductMargins.currentRow#"></span>&nbsp;#application.util.string.wrapText(getAllProductMargins.Description & ' ' & item_UPC,25)#
                        <cfelse>
                                <span  class="bottom"><input type="checkbox" id="cbox" name="chk_upd_#getAllProductMargins.currentRow#"></span>&nbsp;#application.util.string.wrapText(item_UPC & ' ' & getAllProductMargins.Description,25)#
                        </cfif>
                    
                    </th>
            </cfoutput>  
        </tr>

       
        <!------------------------->
        <!--- fix align right ------->
        <!------------------------->
         <tr class="GridViewScrollItem" style="line-height: 1px;" >
            <td class="spacer"></td>
            <cfoutput query="getAllProductMargins">
                    <td class="spacer"></td>
            </cfoutput>
        </tr>

        <cfscript>
            bEdit = !bDistributorMargin;
            render_item_row(col='Case_Count',                       title='Case Pack', decPlaces=request.numeric_format);
            render_item_row(col='Case_Cube',                        title='Case Cube', decPlaces=request.numeric_format);
            render_item_row(col='Net_weight',                       title='Net Weight', decPlaces=request.numeric_format);
            render_item_row(col='Product_Program_Volume',           title='Requested Case Volume', dType='int', decPlaces='');
            render_item_row(col='Case_Count,Product_Program_Volume',title='Requested Units Volume', dType='int', decPlaces='');
            if(bDistributorMargin == 0){
                render_item_row(col='program_fixed_price_cs',           title='Requested Price /CS', dType='', decPlaces=request.dollar_format, bEdit=1);
                render_item_row(col='Program_Fixed_Price_M',            title='Requested Price /M', dType='', decPlaces=request.dollar_format);
                render_item_row(col='Product_Program_Volume',           title='Current Case Volume', dType='int', decPlaces='', bPrevious = 1);
                render_item_row(col='Case_Count,Product_Program_Volume',title='Current Units Volume', dType='int', decPlaces='', bPrevious = 1);
                render_item_row(col='Program_Fixed_Price_CS',           title='Current Price /CS', dType='', decPlaces=request.dollar_format, bPrevious = 1);
                render_item_row(col='Program_Fixed_Price_M',            title='Current Price /M', dType='', decPlaces=request.dollar_format, bPrevious = 1);
            }
            render_item_row(col='Base_Sales',                       title='Price List /CS', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Base_Sales_M',                     title='Price List /M', dType='', decPlaces=request.dollar_format);
            render_item_row(col='cash_disc_cs',                     title='Cash Disc.', dType='', decPlaces=request.dollar_format,  bEdit=bEdit);
            render_item_row(col='Allowance_Surcharges_CS',          title='Other Allowances', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Other_Spend',                      title='Redi', dType='', decPlaces=request.dollar_format);
            render_item_row(col='tpa_cs',                           title='TPA', dType='', decPlaces=request.dollar_format,  bEdit=bEdit);
            render_item_row(col='Net_Sales',                        title='Net Sales /CS', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Net_Sales_M',                      title='Net Sales /M', dType='', decPlaces=request.dollar_format);
            render_item_row(col='map_mdf_cs',                       title='Variable Product Costs', dType='', decPlaces=request.dollar_format,  bEdit=1);
            render_item_row(col='custom_brokerage_cs',              title='Commission', dType='', decPlaces=request.dollar_format,  bEdit=1);
            render_item_row(col='custom_warehouse_cs',              title='Warehouse', dType='', decPlaces=request.dollar_format,  bEdit=1);
            render_item_row(col='customer_freight_cs',              title='Inbound', dType='', decPlaces=request.dollar_format,  bEdit=1);
            render_item_row(col='shuttle_freight_cs',               title='Outbound', dType='', decPlaces=request.dollar_format,  bEdit=1);
            render_item_row(col='Cost',                             title='VC /CS', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Cost_M',                           title='VC /M', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Contribution_Margin_Alt',          title='CM $ /CS', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Contribution_Margin_Alt_M',        title='CM $ /M', dType='', decPlaces=request.dollar_format);
            render_item_row(col='variable_contribution_margin_cs',  title='CM /%', dType='', decPlaces=request.numeric_format,  bEdit=bEdit);
            render_item_row(col='sga_cs',                           title='POH /CS', dType='', decPlaces=request.dollar_format,  bEdit=1);
            render_item_row(col='SGA_M',                            title='POH /M', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Operating_Income',                 title='GP $ /CS', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Operating_Income_M',               title='GP $ /M', dType='', decPlaces=request.dollar_format);
            render_item_row(col='OperatingMargin_percent',          title='GP %', dType='', decPlaces=request.dollar_format);
            render_row(["Total Requested"]);
            render_item_row(col='Product_Program_Volume',           title='&nbsp;&nbsp;&nbsp;Case Volume', dType='int', decPlaces='');
            render_item_row(col='Case_Count,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;Units Volume', dType='int', decPlaces='');
            render_item_row(col='Net_Sales,Product_Program_Volume', title='&nbsp;&nbsp;&nbsp;Net Sales', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Contribution_Margin_Alt,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;CM $', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Contribution_Margin_Alt,Net_Sales',    title='&nbsp;&nbsp;&nbsp;CM %', dType='', decPlaces=request.numeric_format);
            render_item_row(col='Operating_Income,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;GP $', dType='', decPlaces=request.dollar_format);
            render_item_row(col='Operating_Income,Net_Sales',       title='&nbsp;&nbsp;&nbsp;GP %', dType='', decPlaces=request.dollar_format);
            if(bDistributorMargin == 0){
                render_row(["Total Current"]);
                render_item_row(col='Product_Program_Volume',           title='&nbsp;&nbsp;&nbsp;Case Volume', dType='int', decPlaces='', bPrevious = 1);
                render_item_row(col='Case_Count,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;Units Volume', dType='int', decPlaces='', bPrevious = 1);
                render_item_row(col='Net_Sales,Product_Program_Volume', title='&nbsp;&nbsp;&nbsp;Net Sales', dType='', decPlaces=request.dollar_format, bPrevious = 1);
                render_item_row(col='Contribution_Margin_Alt,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;CM $', dType='', decPlaces=request.dollar_format, bPrevious = 1);
                render_item_row(col='Contribution_Margin_Alt,Net_Sales',    title='&nbsp;&nbsp;&nbsp;CM %', dType='', decPlaces=request.numeric_format, bPrevious = 1);
                render_item_row(col='Operating_Income,Product_Program_Volume',  title='&nbsp;&nbsp;&nbsp;GP $', dType='', decPlaces=request.dollar_format, bPrevious = 1);
                render_item_row(col='Operating_Income,Net_Sales',       title='&nbsp;&nbsp;&nbsp;GP %', dType='', decPlaces=request.numeric_format, bPrevious = 1);
            }
        </cfscript>
        <!-------------------------------->
        <!--- TOTAL CURRENT APPROVED ----->
        <!-------------------------------->
        <cfset render_row(["Total Current Approved"])>
         <!---    <cfset render_row(["CM $"])>
            <cfset render_row(["CM %"])> --->
                    <!--- ~~~~~~~~~~ CM $ ~~~~~~~~~~~ --->
            <!--- <cfset render_row(["CM $"])> --->
                 <tr class="GridViewScrollItem">
                    <td class="une82">&nbsp; &nbsp; &nbsp;CM $</td>
                    <cfoutput query="getAllProductMargins">
                             <cfquery name="local.detail" dbtype="query">
                                SELECT  Product_Program_Volume, Contribution_Margin_Alt FROM qGetPreviousMargins WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                            </cfquery>
                            <cfscript>
                                data = 0;
                                if(local.detail.recordcount){
                                    data = local.detail.Product_Program_Volume * local.detail.Contribution_Margin_Alt;
                                }
                            </cfscript>
                            <td class="#variables.noApprovalClass#">#application.util.string.cellFormat(value=data,decimalplaces = request.dollar_format )#</td>
                    </cfoutput>
                </tr>


            <!--- ~~~~~~~~~~ CM % ~~~~~~~~~~~ --->
            <!--- <cfset render_row(["CM %"])> --->
                <tr class="GridViewScrollItem">
                    <td class="une82">&nbsp; &nbsp; &nbsp;CM %</td>
                    <cfoutput query="getAllProductMargins">
                             <cfquery name="local.detail" dbtype="query">
                                SELECT  Product_Program_Volume, Contribution_Margin_Alt, Net_Sales FROM qGetPreviousMargins WHERE Product_ID = '#getAllProductMargins.Product_ID#'
                            </cfquery>
                            <cfscript>
                                cmDollar = 0;
                                netSales = 0;
                                if(local.detail.recordcount){
                                    cmDollar = local.detail.Product_Program_Volume * local.detail.Contribution_Margin_Alt;
                                    netSales = local.detail.Product_Program_Volume * local.detail.Net_Sales;
                                }
                                if(netSales == 0){
                                    data = 0;
                                }
                                else{
                                    data = (cmDollar/netSales) * 100;
                                }
                            </cfscript>
                            <td class="#variables.noApprovalClass#">#application.util.string.cellFormat(value=data,decimalplaces = request.numeric_format )#%</td>
                    </cfoutput>
                </tr>

      <!--- Get_Profile_Settings.View_Operating_Income eq 1> --->

<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

<!--- XXXXXXXXXXXXXXXXX  	BELOW COMMENT GOES TO LINE 1625		XXXXXXXXXXXXXXXXXX --->
<!---
--->
    <!--- ngt --->
   <!---  <cfinclude template="verticalpnl_total_hm.cfm"> --->

    </table>    <!--- id="t82"> --->
<!--- </cfsavecontent>
<cfoutput>#application.util.string.compress( variables.mainContent )#</cfoutput> --->

<script>
    let $jq = jQuery.noConflict();
    function showPullbackCalculation(CPID){
        <cfoutput>
            NewWindow('/common_files/contracts/pullbacks/Contract_Pullback_Analysis.cfm?ProductId='+CPID+'&CID=#URL.CID#&type=CS&margin_type=#form.margin_type#','PullbackAnalysis','750','350','Yes', 'Yes')
        </cfoutput>
    }
    <cfif isEditing.recordcount GT 0 AND URL.bReset EQ 1>
        var bReload = false;
        $jq(document).ready(function (e) {
            window.addEventListener("pagehide", function(e) {  
                            debugger; 
                            var t = '';
                            if (typeof event.srcElement != "undefined") {
                              t = event.srcElement.activeElement.id;
                            }
                            if (    (t == 'close_window' || t == 'verticalPNL') ) {
                                //debugger;
                                parent.window.opener.reloadFromPopUp();  
                            }
                }, false);
            console.log('READY');
        });
    </cfif>

    function selectCheck(c){
        var checked = c.checked;
        var checkboxes = document.querySelectorAll('input[id="cbox"]');
        for (var checkbox of checkboxes){
            checkbox.checked = checked;
        }
    }

</script>
