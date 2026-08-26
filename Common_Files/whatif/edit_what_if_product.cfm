<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\whatif\edit_what_if.cfm
      Label:    45383
      Date:     2014 October
      Author:   Chris Nguyen
      Purpose:  Edit what if products generic ( no program )

      Notes:

        What-IF Layout: (DO NOT DELETE THESE NOTES)

          *** REMEMBER TO USE UNIQUE NAMES ***

        HEADING
        Field        System                      Input
        ===========  ==========================  ==========================   ==============================
        Product      .system                     .input


        product_count hidden input
                      JS variable
        margin_type   hidden input, JS variable


        PRODUCT
        Field        System                       Input                        Notes
        ===========  ==========================   ==========================   ==============================
        Product_ID   prod_id_#record_no#                                       hidden input, contains BSA_Foodservice_Items_Master_ID for each row
        Volume         sys_volume_#record_no#     user_volume_#record_no#
        List Price     sys_list_price_..          user_list_price_..
        Fixed_price    sys_fixed_price_..         user_fixed_price_..
        Cash Disc      sys_cash_disc_..           user_cash_disc_..
        Discount       n/a                        disc_..
        Disc %         n/a                        disc_percent_..
        Trade          sys_trade_..               user_trade_..
        Amt +          sys_amt_plus_..            user_amt_plus_..
        Net Sales      sys_net_sales_..           user_net_sales_..
        Cost           sys_cost_..                user_cost_..
         Raw material  sys_raw_material_..        user_raw_material_..
         Packaging     sys_packaging_..           user_packaging_..
         DVL           sys_dvl_..                 user_dvl_..
         Fixed Cost    sys_fixed_cost_..          user_fixed_cost_..
         DNT           sys_dnt_..                 user_dnt_..
         Equip         sys_equip_..               user_equip_..
         Comp Cost     sys_comp_cost_..           user_comp_cost_..
        Opr. Income    sys_opr_inc_..             user_opr_inc_..
        Opr. Margin    sys_opr_margin_..          user_opr_margin_..
        CSA $          sys_csa_..                 user_csa_..
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML>
<html>
<head>
    <cfsavecontent variable="head_content">
		<link href="/common_files/GridviewScroll.css" rel="stylesheet" />
        <link rel="stylesheet" type="text/css" href="/common_files/jquery.maxlength.css">
        <style>
            #uom35 { float:right; margin-right:15px; font-weight: bold; position:relative; top:3px;}
            .changed { background-color: #DADBDD !important; }
            #actions { margin: 0 0 2px 0; float: left; }
            #actions a { margin: 0 10px 0 0; font-size: 1em; letter-spacing: 0px; -ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=75)"; opacity:0.75; }
            .important { font-size: 1.1em; font-weight: bold; letter-spacing: 0.2px;  }
            th { vertical-align: top !important; }
            td.system, th.system {
              background-color: #EBF1DE;
              text-align: right;
            }
            td.une82 { padding-left:6px; background-color: #efefef; font-weight: bold; text-align: left; }
            td.une82b { padding-left:12px; background-color: #efefef; font-weight: normal; text-align: left; }
            th.sum38, td.sum38 { background-color: #efefef; text-align: right;}

            .right, td, th.user, td.user, td.user input { text-align: right; }
            .calc { font-weight: bold; color: green; }
            th.noar, th.noar *, td.noar, td.noar * { background-color: #d3d3d3; }
            #not07 label { font-weight:bold; vertical-align:top; font-size:1em; }
            #not07 textarea { width:95%; }
            #not07 textarea + .maxlength-feedback { display: block; width: auto; margin-left: 2.5%; }
            .btn-primary { background-color:blue; color:white; font-weight:bold; }
            form[name=whatif_product] { margin:0; }
            #approval_consideration { font-size: 1.2em; color: green; margin: 0 0 6px 0;}
        </style>
    </cfsavecontent>
    <!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
    <cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
<!--- notification structure --->
<cfscript>
    variables.noty         = {};
    variables.noty.Message = [];
	variables.noty.timeout = [];

	// copy the same list from C:\Forge\base\AwayX\settings\app_settings_6.cfm & convert it into array for easy references
	labelListCostPage      = [ 	"Variable Manufacturing Cost",
								"Fixed Manufacturing Cost",
								"Delivery",
								"Customer Pick up Allowance",
								"Variable Warehousing",
								"Freight Delivered",
								"Freight FOB",
								"Warehouse FOB"
							];
	cost_labels            = {};
	deleted_costs          = {};

	// wr 73472 - load custom labels for costs
	for (i = 1; i <= arrayLen(labelListCostPage); i++) {
		single_label = trim(labelListCostPage[i]);
		cost_labels[ single_label ]   = application.util.query.get_setting("MarginCostColHeader" & i, 0);
		deleted_costs[ single_label ] = application.util.query.get_setting("MarginCostColHeader" & i & "_delete", 0);
		if (trim(cost_labels[ single_label ]) is "") {
			cost_labels[ single_label ] = single_label;
		}
	}
</cfscript>

<cfif CGI.Request_Method eq "post">
    <cfset variables.whatIfCFC = createObject("component", "components.programs.whatif")>

    <!--- switch to edit mode --->
    <cfif form.action contains "edit">
        <cfscript>
            structDelete(url, "ro36");
            variables.message = variables.whatIfCFC.updateLock( form.id, form.action );

            // was switching to edit mode a failure?
            if (len(variables.message)) {
                // capture failure message to display at the bottom
                arrayAppend(variables.noty.Message, trim(variables.message));
                arrayAppend(variables.noty.timeout, 10000);
            }
        </cfscript>

    <!--- switch to readonly mode --->
    <cfelseif form.action contains "readonly">
        <cfscript>
            variables.message = variables.whatIfCFC.updateLock( form.id, form.action );
            // was switching to read only mode a failure?
            if (len(variables.message)) {
                // capture failure message to display at the bottom
                arrayAppend(variables.noty.Message, trim(variables.message));
                arrayAppend(variables.noty.timeout, 10000);
            }
        </cfscript>

    <cfelseif form.action contains "delete_product">
        <cfset variables.whatIfCFC.deleteWhatIfProduct( form.id, form['prod_id_' & form.delete_row] )>
        <cfif form.product_count eq '1'>
            <cflocation url="\common_files\whatIF\edit_what_if.cfm?id=#form.id#">
        </cfif>

    <!--- reset by pulling latest pricing information from db --->
    <cfelseif form.action contains "reset">
        <cfset variables.whatIfCFC.resetWhatIf( form.id )>

    <!--- add products --->
    <cfelseif form.action contains "prod">
        <cfset variables.whatIfCFC.saveWhatIfProduct()>
        <cfoutput>
            <cflocation url="\common_files\whatIF\edit_what_if.cfm?id=#form.id#">
        </cfoutput>

    <!--- change distributor --->
    <cfelseif form.action contains "dist">
        <cfset variables.whatIfCFC.saveWhatIfProduct()>
        <cfoutput>
            <cflocation url="\common_files\whatIF\choose_distributor.cfm?id=#form.id#">
        </cfoutput>

    <!--- save and return back to listing --->
    <cfelseif form.action contains "save">
        <cfset variables.whatIfCFC.saveWhatIfProduct()>
        <!--- <cflocation url="\common_files\whatIF\list_what_if.cfm"> --->
    </cfif>
</cfif>

<cfscript>
  appSettings              = application.appSettingsGet;

  variables.whatIfCFC      = createObject("component", "components.programs.whatif");
  variables.qWhatIf        = variables.whatIfCFC.getWhatIf( url.id );
  variables.qWhatIfProduct = variables.whatIfCFC.getWhatIfProduct( url.id );
  variables.read_only      = structKeyExists(url, "ro36") or variables.qWhatIf.locked_by neq request.AccessStructure.User_ID;
  variables.disabled       = (variables.read_only ? "disabled=disabled" : "");

  variables.dollarFormat4  = "($,.____";
</cfscript>


<cfsavecontent variable="variables.bodyText">
<cfoutput>
<div id="actions">
    <cfif variables.read_only>
        <!--- if nobody has locked this or the locked person is the logged in user provide option to edit --->
        <cfif variables.qWhatIf.locked_by eq "" or variables.qWhatIf.locked_by eq request.AccessStructure.User_ID>
            <a href="##" id="edit38" title="click to edit">#application.util.string.actionLinkFormat2("edit", "important")#</a>
        <cfelse>
            <!--- offer refresh option to display the latest locking info --->
            <a href="##" onclick="$('body').fadeOut(350); window.location = location.href;">#application.util.string.actionLinkFormat2("refresh", "important")#</a>
        </cfif>

        <a href="##" id="export82" onclick="getCSVData()">#application.util.string.actionLinkFormat2("export to csv")#</a>
        <a href="list_what_if.cfm" id="return82">#application.util.string.actionLinkFormat2("close & return to list")#</a>
    <cfelse>
        <!--- logged in user = locked by user so offer ability to switch to read only mode --->
        <cfif variables.qWhatIf.locked_by eq request.AccessStructure.User_ID>
            <a href="##" id="readonly38" title="click for read only">#application.util.string.actionLinkFormat2("read only", "important")#</a>
        </cfif>
        <a href="##" id="calc38">#application.util.string.actionLinkFormat2("calculate")#</a>
        <a href="##" id="save38" class="default">#application.util.string.actionLinkFormat2("save")#</a>
        <a href="##" id="prod38">#application.util.string.actionLinkFormat2("add products")#</a>
        <a href="##" id="reset38">#application.util.string.actionLinkFormat2("reset")#</a>
        <a href="##" id="dist38">#application.util.string.actionLinkFormat2(application.returned_customer_setting.Distributor_Label_Singular & ": " & application.util.string.capFirstTitle( variables.qWhatIf.Distributor_Name ) & " (change)")#</a>
        <a href="##" id="export82" onclick="getCSVData()">#application.util.string.actionLinkFormat2("export to csv")#</a>
        <a href="\common_files\whatIF\list_what_if.cfm">#application.util.string.actionLinkFormat2("close & return to list")#</a>
    </cfif>   <!--- cfif variables.read_only --->
    <!--- create notification message --->
    <cfset variables.timeout = 0>
    <cfsavecontent variable="variables.message">
        <cfif variables.qWhatIf.Editor neq "" and variables.qWhatIf.locked_by neq request.AccessStructure.User_ID>
            <!--- important message, do not time out --->
            <cfset variables.timeout = 0>
            This what if p&l is currently being locked by <b>#variables.qWhatIf.Editor#</b>
        <cfelseif variables.qWhatIf.Modifier neq "">
            <!--- unimportant message, time out in 10 secs --->
            <cfset variables.timeout = 0>
            This what if p&l was last modified by <b>#variables.qWhatIf.Modifier#</b> <cfif isDate(variables.qWhatIf.Modified_Date)>on #dateFormat(variables.qWhatIf.Modified_Date, 'medium')#</cfif>
        </cfif>
    </cfsavecontent>
    <cfif len(variables.message)>
        <cfset arrayAppend(variables.noty.Message, trim(variables.message))>
        <cfset arrayAppend(variables.noty.timeout, variables.timeout)>
    </cfif>
</div>

<div id="uom35">
  <input type="radio" value="1" name="uom" <cfif variables.qWhatIf.margin_type eq 1>checked</cfif> >PHYSICAL CASE
  <input type="radio" value="3" name="uom" <cfif variables.qWhatIf.margin_type eq 3>checked</cfif> >#Application.UOMPoundPlural#
</div>
<div style="clear:both"></div>
<cfset variables.approval_consideration = createObject("component","mvc.Models.Program.ApprovalConsiderationsManager").getText()>

<div id="approval_consideration">#variables.approval_consideration.Approval_Considerations_Text# <cfif variables.approval_consideration.recordCount gt 1>
    <a href="##" id="moretext">(more)</a>
</cfif></div>


</cfoutput>

<form name="whatif_product" method="post">
    <cfoutput>
    <input type="hidden" name="action">
    <input type="hidden" name="delete_row">
    <input type="hidden" name="margin_type" value="#variables.qWhatIf.margin_type#">
    <input type="hidden" name="product_count" value="#variables.qWhatIfProduct.recordCount#">
    <input type="hidden" name="id" value="#url.id#">   <!--- what_if primary key --->
    </cfoutput>

    <cfoutput query="variables.qWhatIfProduct">
        <!--- keep track of product IDs: first product is stored in input element named as 'prod_id_1' and has a value of BSA_Foodservice_Items_Master_ID --->
        <input type="hidden" name="prod_id_#variables.qWhatIfProduct.currentRow#"            value="#variables.qWhatIfProduct.BSA_Foodservice_Items_Master_ID#">
        <!--- these are calculated values: they are display-only on the page --->
        <input type="hidden" name="user_disc_#variables.qWhatIfProduct.currentRow#"          value="#variables.qWhatIfProduct.user_discount#">
        <input type="hidden" name="user_disc_percent_#variables.qWhatIfProduct.currentRow#"  value="#variables.qWhatIfProduct.user_discount_percent#">
        <input type="hidden" name="user_net_sales_#variables.qWhatIfProduct.currentRow#"     value="#variables.qWhatIfProduct.user_net_sales#">
        <input type="hidden" name="user_cost_#variables.qWhatIfProduct.currentRow#"          value="#variables.qWhatIfProduct.user_cost#">
        <input type="hidden" name="user_opr_income_#variables.qWhatIfProduct.currentRow#"    value="#variables.qWhatIfProduct.user_opr_income#">
        <input type="hidden" name="user_opr_margin_#variables.qWhatIfProduct.currentRow#"    value="#variables.qWhatIfProduct.user_opr_margin#">
        <input type="hidden" name="user_csa_#variables.qWhatIfProduct.currentRow#">
    </cfoutput>

    <div id="not07" style="margin-bottom:4px;">
        <label>Notes:</label> <textarea name="whatif_notes" <cfoutput>#variables.disabled#</cfoutput> rows="2"><cfif variables.qWhatIf.recordCount><cfoutput>#variables.qWhatIf.Notes#</cfoutput></cfif></textarea>
    </div>

    <table cellspacing="0" id="GridView1" style="width:100%;border-collapse:collapse;border:1px solid black;">
        <!----------------------->
        <!--- COLUMNS HEADING --->
        <!----------------------->
        <tr class="GridviewScrollHeader">
            <th> <cfoutput>#application.util.string.wrapText( variables.qWhatIf.Title )#</cfoutput> </th>
            <th class="sum38">Annual Summary Absolute $</th>
            <th class="sum38">Annual Summary Rate / <cfif variables.qWhatIf.margin_type eq 1>CS<cfelse>LB</cfif></th>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.product = ( appSettings.getViewPgmSortBy() ? variables.qWhatIfProduct.Description & ' ' & variables.qWhatIfProduct.Item
                                                                            : variables.qWhatIfProduct.Item        & ' ' & variables.qWhatIfProduct.Description )>
                <th class="system #variables.noApprovalClass#">
                    <cfif not variables.read_only>
                        <a href="##" onclick="zapit(#variables.qWhatIfProduct.currentRow#, '#variables.qWhatIfProduct.Item#')">
                            <img src="/Images/scissor.gif" width="14" height="9" border="0" title="Click to delete this product">
                        </a>
                    </cfif>
                    System - #application.util.string.wrapText(variables.product)#
                </th>
                <th class="user #variables.noApprovalClass#">
                    <cfif not variables.read_only>
                        <a href="##" onclick="zapit(#variables.qWhatIfProduct.currentRow#, '#variables.qWhatIfProduct.Item#')">
                            <img src="/Images/scissor.gif" width="14" height="9" border="0" title="Click to delete this product">
                        </a>
                    </cfif>
                    User - #application.util.string.wrapText(variables.product)#
                </th>
            </cfoutput>
        </tr>

        <!--- cases | pounds --->
        <tr class="GridviewScrollItem">
            <td class="une82 uom_label" id2="uom_label"><cfif variables.qWhatIf.margin_type eq 1>Cases<cfelse>Pounds</cfif></td>
            <td class="sum38" id="uom38">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <!--- control tabbing navigation from top to bottom & stay in the same product --->
                <cfset variables.tabIndex        = variables.qWhatIfProduct.currentRow * 1000>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#" id="system_volume_#variables.qWhatIfProduct.currentRow#" >#numberFormat( variables.qWhatIfProduct.system_volume, ",_.__" )#</td>
                <td class="user #variables.noApprovalClass#"><input class="uomi" type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_volume_#variables.qWhatIfProduct.currentRow#" value="#numberFormat( variables.qWhatIfProduct.user_volume, ",_.__" )#"></td>
            </cfoutput>
        </tr>

        <!--- net weight --->
        <tr class="GridviewScrollItem">
            <td class="une82">Net Weight</td>
            <td class="sum38">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 10>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <td class="system #variables.noApprovalClass#">#numberFormat( variables.qWhatIfProduct.System_Net_Weight, ",_.___" )#</td>
                <td class="user #variables.noApprovalClass#" id="user_net_weight_#variables.qWhatIfProduct.currentRow#">#numberFormat( variables.qWhatIfProduct.System_Net_Weight, ",_.___" )#</td>
            </cfoutput>
        </tr>

        <!--- list price --->
        <tr class="GridviewScrollItem">
            <td class="une82">List Price</td>
            <td class="sum38" id="lp38a">&nbsp;</td>
            <td class="sum38" id="lp38r">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 20>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#" id="system_list_price_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_List_Price, variables.dollarFormat4)#</td>
                <td class="user #variables.noApprovalClass#"><input class="lp38i" type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" class="right" name="user_list_price_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_List_Price, variables.dollarFormat4)#"></td>
            </cfoutput>
        </tr>

        <!--- cash discount --->
        <cfif appsettings.getDisplayCashDiscountMargin() eq 1 >
            <tr class="GridviewScrollItem">
                <td class="une82">
                    <cfoutput><cfif appsettings.getlocalcostvariables() neq 1>#appsettings.getMarginColHeader3()#<cfelse>#appsettings.getMarginColHeader4()#</cfif></cfoutput>
                </td>
                <td class="sum38" id="cd38a">&nbsp;</td>
                <td class="sum38" id="cd38r">&nbsp;</td>
                <cfoutput query="variables.qWhatIfProduct">
                    <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 25>
                    <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                    <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <td class="system #variables.noApprovalClass#" id="system_cash_disc_#variables.qWhatIfProduct.currentRow#">#numberFormat(0, variables.dollarFormat4)#</td>
                    <td class="user #variables.noApprovalClass#"><input class="cd38i" type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" class="right" name="user_cash_disc_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_cash_disc, variables.dollarFormat4)#"></td>
                </cfoutput>
            </tr>
        </cfif>

        <!--- discount total --->
        <tr class="GridviewScrollItem">
            <td class="une82">Discount</td>
            <td class="sum38" id="disc38a">&nbsp;</td>
            <td class="sum38" id="disc38r">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <td class="system #variables.noApprovalClass#">&nbsp;</td>
                <td class="user disc38t calc #variables.noApprovalClass#" id="user_disc_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.user_discount, variables.dollarFormat4)#</td>
            </cfoutput>
        </tr>

        <!--- fixed price --->
        <tr class="GridviewScrollItem">
            <td class="une82b">Fixed Price</td>
            <td class="sum38">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 30>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#">&nbsp;</td>
                <td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_fixed_price_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_fixed_price, variables.dollarFormat4)#"></td>
            </cfoutput>
        </tr>

        <!--- rebate --->
        <tr class="GridviewScrollItem">
            <td class="une82b">Rebate</td>
            <td class="sum38">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 40>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#">&nbsp;</td>
                <td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_rebate_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_rebate_discount, variables.dollarFormat4)#"></td>
            </cfoutput>
        </tr>

        <!--- lump sum --->
        <tr class="GridviewScrollItem">
            <td class="une82b">Lump Sum</td>
            <td class="sum38">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 50>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#">&nbsp;</td>
                <td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_ls_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_ls_discount, variables.dollarFormat4)#"></td>
            </cfoutput>
        </tr>

        <!--- growth --->
        <tr class="GridviewScrollItem">
            <td class="une82b">Growth</td>
            <td class="sum38">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 60>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#">&nbsp;</td>
                <td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_growth_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_growth_discount, variables.dollarFormat4)#"></td>
            </cfoutput>
        </tr>

        <!--- discount percent --->
        <tr class="GridviewScrollItem">
            <td class="une82">Discount %</td>
            <td class="sum38" id="dp38a">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 70>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#">&nbsp;</td>
                <td class="user calc #variables.noApprovalClass#" id="user_disc_percent_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.user_discount_percent, ",_.__")#%</td>
            </cfoutput>
        </tr>

        <!--- trade --->
        <tr class="GridviewScrollItem">
            <td class="une82">Trade</td>
            <td class="sum38" id="tra38a">&nbsp;</td>
            <td class="sum38" id="tra38r">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 80>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#">&nbsp;</td>
                <td class="user tra38t #variables.noApprovalClass#" id="user_trade_#variables.qWhatIfProduct.currentRow#">&nbsp;</td>
            </cfoutput>
        </tr>

        <cfif appsettings.getDisplayCashDiscountMargin() neq 1 >
            <!--- trade cash discount --->
            <tr class="GridviewScrollItem">
                <td class="une82b">Cash Discount</td>
                <td class="sum38">&nbsp;</td>
                <td class="sum38">&nbsp;</td>
                <cfoutput query="variables.qWhatIfProduct">
                    <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 81>
                    <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                    <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <td class="system #variables.noApprovalClass#">&nbsp;</td>
                    <td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_trade_cash_disc_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.User_Trade_Cash_Disc, variables.dollarFormat4)#"></td>
                </cfoutput>
            </tr>

            <!--- trade other allowances --->
            <tr class="GridviewScrollItem">
                <td class="une82b">Other Allowances</td>
                <td class="sum38">&nbsp;</td>
                <td class="sum38">&nbsp;</td>
                <cfoutput query="variables.qWhatIfProduct">
                    <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 82>
                    <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                    <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                    <td class="system #variables.noApprovalClass#">&nbsp;</td>
                    <td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_trade_other_allowances_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.User_Trade_Other_Allowances, variables.dollarFormat4)#"></td>
                </cfoutput>
            </tr>
        </cfif>

        <!--- distributor trade --->
        <tr class="GridviewScrollItem">
            <td class="une82b">Distributor Trade</td>
            <td class="sum38">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 83>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#">&nbsp;</td>
                <td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_distributor_trade_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.User_Distributor_Trade, variables.dollarFormat4)#"></td>
            </cfoutput>
        </tr>

        <!--- net sales --->
        <tr class="GridviewScrollItem">
            <td class="une82">Net Sales</td>
            <td class="sum38" id="ns38a">&nbsp;</td>
            <td class="sum38" id="ns38r">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 90>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#" id="system_net_sales_#variables.qWhatIfProduct.currentRow#">#dollarFormat(variables.qWhatIfProduct.System_Net_Sales)#</td>
                <td class="user calc ns38t #variables.noApprovalClass#" id="user_net_sales_#variables.qWhatIfProduct.currentRow#">#dollarFormat(variables.qWhatIfProduct.user_Net_Sales)#</td>
            </cfoutput>
        </tr>

        <!--- cost total --->
        <tr class="GridviewScrollItem">
            <td class="une82">Cost</td>
            <td class="sum38" id="co38a">&nbsp;</td>
            <td class="sum38" id="co38r">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 100>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#" id="system_cost_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_Cost, variables.dollarFormat4)#</td>
                <td class="user calc co38t #variables.noApprovalClass#" id="user_cost_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.User_Cost, variables.dollarFormat4)#</td>
            </cfoutput>
        </tr>

		<!--- dvl/dve --->
		<cfset cost_name = "Variable Manufacturing Cost">
		<cfif deleted_costs[ cost_name ] neq "1">
			<tr class="GridviewScrollItem">
				<!--- <td class="une82b">DVL / DVE</td> --->
				<td class="une82b"><cfoutput>#cost_label( cost_name )#</cfoutput></td>   <!--- wr 73472 --->
				<td class="sum38">&nbsp;</td>
				<td class="sum38">&nbsp;</td>
				<cfoutput query="variables.qWhatIfProduct">
					<cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 130>
					<cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
					<cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<td class="system #variables.noApprovalClass#" id="system_dvl_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_DVL, variables.dollarFormat4)#</td>
					<td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_dvl_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_DVL, variables.dollarFormat4)#"></td>
				</cfoutput>
			</tr>
		</cfif>

        <!--- fixed cost --->
		<cfset cost_name = "Fixed Manufacturing Cost">
		<cfif deleted_costs[ cost_name ] neq "1">
			<tr class="GridviewScrollItem">
				<!--- <td class="une82b">Fixed Cost</td> --->
				<td class="une82b"><cfoutput>#cost_label( cost_name )#</cfoutput></td>   <!--- wr 73472 --->
				<td class="sum38">&nbsp;</td>
				<td class="sum38">&nbsp;</td>
				<cfoutput query="variables.qWhatIfProduct">
					<cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 140>
					<cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
					<cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<td class="system #variables.noApprovalClass#" id="system_fixed_cost_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_Fixed_Cost, variables.dollarFormat4)#</td>
					<td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_fixed_cost_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_Fixed_Cost, variables.dollarFormat4)#"></td>
				</cfoutput>
			</tr>
		</cfif>

        <!--- raw material --->
		<cfset cost_name = "Delivery">
		<cfif deleted_costs[ cost_name ] neq "1">
			<tr class="GridviewScrollItem">
				<!--- <td class="une82b">Raw Materials</td> --->
				<td class="une82b"><cfoutput>#cost_label( cost_name )#</cfoutput></td>   <!--- wr 73472 --->
				<td class="sum38">&nbsp;</td>
				<td class="sum38">&nbsp;</td>
				<cfoutput query="variables.qWhatIfProduct">
					<cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 110>
					<cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
					<cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<td class="system #variables.noApprovalClass#" id="system_raw_material_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_Raw_Material, variables.dollarFormat4)#</td>
					<td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_raw_material_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_raw_material, variables.dollarFormat4)#"></td>
				</cfoutput>
			</tr>
		</cfif>

        <!--- packaging --->
		<cfset cost_name = "Customer Pick up Allowance">
		<cfif deleted_costs[ cost_name ] neq "1">
			<tr class="GridviewScrollItem">
				<!--- <td class="une82b">Packaging</td> --->
				<td class="une82b"><cfoutput>#cost_label( cost_name )#</cfoutput></td>   <!--- wr 73472 --->
				<td class="sum38">&nbsp;</td>
				<td class="sum38">&nbsp;</td>
				<cfoutput query="variables.qWhatIfProduct">
					<cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 120>
					<cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
					<cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<td class="system #variables.noApprovalClass#" id="system_packaging_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_Packaging, variables.dollarFormat4)#</td>
					<td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_packaging_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_packaging, variables.dollarFormat4)#"></td>
				</cfoutput>
			</tr>
		</cfif>

        <!--- equip / service / cema --->
		<cfset cost_name = "Variable Warehousing">
		<cfif deleted_costs[ cost_name ] neq "1">
			<tr class="GridviewScrollItem">
				<!--- <td class="une82b">Equip / Service / CEMA</td> --->
				<td class="une82b"><cfoutput>#cost_label( cost_name )#</cfoutput></td>   <!--- wr 73472 --->
				<td class="sum38">&nbsp;</td>
				<td class="sum38">&nbsp;</td>
				<cfoutput query="variables.qWhatIfProduct">
					<cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 160>
					<cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
					<cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<td class="system #variables.noApprovalClass#" id="system_equip_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_Equip_CEMA, variables.dollarFormat4)#</td>
					<td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_equip_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_Equip_CEMA, variables.dollarFormat4)#"></td>
				</cfoutput>
			</tr>
		</cfif>

        <!--- d&t --->
		<cfset cost_name = "Freight Delivered">
		<cfif deleted_costs[ cost_name ] neq "1">
			<tr class="GridviewScrollItem">
				<!--- <td class="une82b">D&T</td> --->
				<td class="une82b"><cfoutput>#cost_label( cost_name )#</cfoutput></td>   <!--- wr 73472 --->
				<td class="sum38">&nbsp;</td>
				<td class="sum38">&nbsp;</td>
				<cfoutput query="variables.qWhatIfProduct">
					<cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 150>
					<cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
					<cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
					<td class="system #variables.noApprovalClass#" id="system_dnt_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_DNT, variables.dollarFormat4)#</td>
					<td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_dnt_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_DNT, variables.dollarFormat4)#"></td>
				</cfoutput>
			</tr>
		</cfif>




        <!--- component cost --->
        <tr class="GridviewScrollItem">
            <td class="une82b">Component Cost</td>
            <td class="sum38">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 170>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#" id="system_comp_cost_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.System_Comp_Cost, variables.dollarFormat4)#</td>
                <td class="user #variables.noApprovalClass#"><input type="text" #variables.disabled# #variables.disabled2# tabindex="#variables.tabIndex#" name="user_comp_cost_#variables.qWhatIfProduct.currentRow#" value="#numberFormat(variables.qWhatIfProduct.user_Comp_Cost, variables.dollarFormat4)#"></td>
            </cfoutput>
        </tr>

        <!--- operating income --->
        <tr class="GridviewScrollItem">
            <td class="une82">Opr. Income</td>
            <td class="sum38" id="oi38a">&nbsp;</td>
            <td class="sum38" id="oi38r">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 180>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#" id="system_opr_income_#variables.qWhatIfProduct.currentRow#">#dollarFormat(variables.qWhatIfProduct.System_Opr_Income)#</td>
                <td class="user oi38t calc #variables.noApprovalClass#" id="user_opr_income_#variables.qWhatIfProduct.currentRow#">#dollarFormat(variables.qWhatIfProduct.User_Opr_Income)#</td>
            </cfoutput>
        </tr>

        <!--- opering margin --->
        <tr class="GridviewScrollItem">
            <td class="une82">Opr. Margin</td>
            <td class="sum38" id="om38a">&nbsp;</td>
            <td class="sum38" id="om38r">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 190>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#" id="system_opr_margin_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.system_opr_margin, ",_")#%</td>
                <td class="user calc om38t #variables.noApprovalClass#" id="user_opr_margin_#variables.qWhatIfProduct.currentRow#">#numberFormat(variables.qWhatIfProduct.user_opr_margin, ",_")#%</td>
            </cfoutput>
        </tr>

        <!--- csa --->
        <tr class="GridviewScrollItem">
            <td class="une82">CSA</td>
            <td class="sum38" id="csa38a">&nbsp;</td>
            <td class="sum38">&nbsp;</td>
            <cfoutput query="variables.qWhatIfProduct">
                <cfset variables.tabIndex        = (variables.qWhatIfProduct.currentRow * 1000) + 210>
                <cfset variables.noApprovalClass = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? " noar" : "")>
                <cfset variables.disabled2       = (variables.qWhatIfProduct.Group_ID_Approval eq 0 ? "disabled=disabled" : "")>
                <td class="system #variables.noApprovalClass#"></td>
                <td class="user calc csa38t #variables.noApprovalClass#" id="user_csa_#variables.qWhatIfProduct.currentRow#">$#numberFormat(variables.qWhatIfProduct.user_csa, ",_")#</td>
            </cfoutput>
        </tr>
    </table>
</form>  <!--- name="whatif_product"> --->
</cfsavecontent>

<cfoutput>#application.util.string.compress(variables.bodyText)#</cfoutput>

<cffunction name="cost_label" output="false">
	<cfargument name="cost_name" required="true">

	<!--- return a custom cost name if it exists --->
	<cfreturn structKeyExists(cost_labels, arguments.cost_name)
					? cost_labels[ arguments.cost_name ]
					: arguments.cost_name>
</cffunction>

<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->
<cfset jQueryUI.version = "1.9.1">
<cfset jQueryUI.widgets = "full">
<cfinclude template="/common_files/jQuery.cfm">

<form action="/common_files/csv.cfm" method ="post" id="csv_form">
    <input type="hidden" name="csv_text" id="csv_text">
    <input type="hidden" name="csv_file_name">
</form>

<script type="text/javascript" src="/Script/javascript/GridViewScroll2Csv.js"></script>

<script type="text/javascript" src="/Script/javascript/gridviewScroll.min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.util.js"></script>
<script type="text/javascript" src="/script/javascript/numeral.min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.plugin.min.js"></script>
<script type="text/javascript" src="/script/javascript/jquery.maxlength.min.js"></script>

<script>
var product_count = <cfoutput>#variables.qWhatIfProduct.recordCount#</cfoutput>;
var jsdebug = 0;   <!---  set this value to zero to turn off js debug console feature --->

<!--- starts with an empty console --->
if (jsdebug) {
    console.clear();
}

getCSVData = function() {
    $('input[name=csv_file_name]').val( <cfoutput>'whatif_generic_'</cfoutput>
                                                                         + Math.random().toString(36).slice(2)  // append an arbitrary unique substring
                                                                         + ".csv");

    var csv_value=$('#tbl-container table, #GridView1')
                                .table2CSV( {  csvExclude: 'csvExclude'         // filter out elements with csvExclude class
                              } );
    $("#csv_text").val(csv_value);
    $("#csv_form").submit();
};

<!--------------------->
<!--- switching UOM --->
<!--------------------->
$('input[name=uom]').change(function() {
    $('body').hide();
    var mt = $(this).val()
       ,mt_label = (mt == 1 ? "Cases" : "Pounds");

    $('input[name=margin_type]').val( mt );
    $('td.uom_label').find("div.GridCellDiv").text( mt_label );

    if (jsdebug) {
        console.clear();
    }

    <!--- change all subcosts --->
    <!--- scanning thru all products on the page --->
    for (var idx = 1; idx <= product_count; idx++) {
        <!--- first iteration = system values; second iteration = user values --->
        for (var cdx = 1; cdx <= 2; cdx++ ) {

            <!--- gather existing values --->
            var net_weight   = $('#user_net_weight_' + idx).text()
               ,prefix       = (cdx == 1 ? '#system' : 'input[name=user')
               ,suffix       = (cdx == 1 ? '' : ']')
               <!--- use id selector for system elements and name selector for user elements --->

               ,volume       = stringToNumeric2( $(prefix + '_volume_'       + idx + suffix) )
               ,list_price   = stringToNumeric2( $(prefix + '_list_price_'   + idx + suffix) )
               ,cash_disc    = stringToNumeric2( $(prefix + '_cash_disc_'    + idx + suffix) )

               ,fixed_price  = stringToNumeric2( $(prefix + '_fixed_price_'  + idx + suffix) )
               ,rebate       = stringToNumeric2( $(prefix + '_rebate_'       + idx + suffix) )
               ,lump_sum     = stringToNumeric2( $(prefix + '_ls_'           + idx + suffix) )
               ,growth       = stringToNumeric2( $(prefix + '_growth_'       + idx + suffix) )

               ,trade_cash_disc         = stringToNumeric2( $(prefix + '_trade_cash_disc_'         + idx + suffix) )
               ,trade_other_allowances  = stringToNumeric2( $(prefix + '_trade_other_allowances_'  + idx + suffix) )
               ,trade_distributor_trade = stringToNumeric2( $(prefix + '_distributor_trade_' + idx + suffix) )


               ,raw_material = stringToNumeric2( $(prefix + '_raw_material_' + idx + suffix) )
               ,packaging    = stringToNumeric2( $(prefix + '_packaging_'    + idx + suffix) )
               ,dvl          = stringToNumeric2( $(prefix + '_dvl_'          + idx + suffix) )
               ,fixed_cost   = stringToNumeric2( $(prefix + '_fixed_cost_'   + idx + suffix) )
               ,dnt          = stringToNumeric2( $(prefix + '_dnt_'          + idx + suffix) )
               ,equip        = stringToNumeric2( $(prefix + '_equip_'        + idx + suffix) )
               ,comp_cost    = stringToNumeric2( $(prefix + '_comp_cost_'    + idx + suffix) );

            var pounds = 3, cases = 1;

            <!--- convert from cases to pounds --->
            if (mt == pounds) {
                volume       = (volume * net_weight);
                list_price   = (net_weight == 0 ? 0 : list_price   / net_weight);
                cash_disc    = (net_weight == 0 ? 0 : cash_disc    / net_weight);

                fixed_price  = (net_weight == 0 ? 0 : fixed_price  / net_weight);
                rebate       = (net_weight == 0 ? 0 : rebate       / net_weight);
                lump_sum     = (net_weight == 0 ? 0 : lump_sum     / net_weight);
                growth       = (net_weight == 0 ? 0 : growth       / net_weight);

                trade_cash_disc          = (net_weight == 0 ? 0 : trade_cash_disc          / net_weight);
                trade_other_allowances   = (net_weight == 0 ? 0 : trade_other_allowances   / net_weight);
                trade_distributor_trade  = (net_weight == 0 ? 0 : trade_distributor_trade  / net_weight);

                raw_material = (net_weight == 0 ? 0 : raw_material / net_weight);
                packaging    = (net_weight == 0 ? 0 : packaging    / net_weight);
                dvl          = (net_weight == 0 ? 0 : dvl          / net_weight);
                fixed_cost   = (net_weight == 0 ? 0 : fixed_cost   / net_weight);
                dnt          = (net_weight == 0 ? 0 : dnt          / net_weight);
                equip        = (net_weight == 0 ? 0 : equip        / net_weight);
                comp_cost    = (net_weight == 0 ? 0 : comp_cost    / net_weight);
            }
            <!--- convert from pounds to cases --->
            else if (mt == cases) {
                volume       = (net_weight == 0 ? 0 : volume / net_weight);
                list_price   = (list_price   * net_weight);
                cash_disc    = (cash_disc    * net_weight);

                fixed_price  = (fixed_price  * net_weight);
                rebate       = (rebate       * net_weight);
                lump_sum     = (lump_sum     * net_weight);
                growth       = (growth       * net_weight);

                trade_cash_disc          = (trade_cash_disc          * net_weight);
                trade_other_allowances   = (trade_other_allowances   * net_weight);
                trade_distributor_trade  = (trade_distributor_trade  * net_weight);

                raw_material = (raw_material * net_weight);
                packaging    = (packaging    * net_weight);
                dvl          = (dvl          * net_weight);
                fixed_cost   = (fixed_cost   * net_weight);
                dnt          = (dnt          * net_weight);
                equip        = (equip        * net_weight);
                comp_cost    = (comp_cost    * net_weight);
            };

            <!--- refresh with newly converted values --->
            refreshContent( $(prefix + '_volume_'       + idx + suffix), numeral(volume).format('(0,.00)') );
            refreshContent( $(prefix + '_list_price_'   + idx + suffix), numeral(list_price).format() );
            refreshContent( $(prefix + '_cash_disc_'    + idx + suffix), numeral(cash_disc).format() );

            refreshContent( $(prefix + '_fixed_price_'  + idx + suffix), numeral(fixed_price).format() );
            refreshContent( $(prefix + '_rebate_'       + idx + suffix), numeral(rebate).format() );
            refreshContent( $(prefix + '_ls_'           + idx + suffix), numeral(lump_sum).format() );
            refreshContent( $(prefix + '_growth_'       + idx + suffix), numeral(growth).format() );

            refreshContent( $(prefix + '_trade_cash_disc_'         + idx + suffix), numeral(trade_cash_disc).format() );
            refreshContent( $(prefix + '_trade_other_allowances_'  + idx + suffix), numeral(trade_other_allowances).format() );
            refreshContent( $(prefix + '_distributor_trade_'       + idx + suffix), numeral(trade_distributor_trade).format() );

            refreshContent( $(prefix + '_raw_material_' + idx + suffix), numeral(raw_material).format() );
            refreshContent( $(prefix + '_packaging_'    + idx + suffix), numeral(packaging).format() );
            refreshContent( $(prefix + '_dvl_'          + idx + suffix), numeral(dvl).format());
            refreshContent( $(prefix + '_fixed_cost_'   + idx + suffix), numeral(fixed_cost).format());
            refreshContent( $(prefix + '_dnt_'          + idx + suffix), numeral(dnt).format());
            refreshContent( $(prefix + '_equip_'        + idx + suffix), numeral(equip).format());
            refreshContent( $(prefix + '_comp_cost_'    + idx + suffix), numeral(comp_cost).format());

            if (jsdebug && idx == 2) {
                console.log('switch uom: product idx = ' + idx + ' prefix = ' + prefix);
                console.log('      volume         = ' + numeral(volume).format("0,.00") );
                console.log('      list_price     = ' + numeral(list_price).format() );
                console.log('');
                console.log('      fixed_price    = ' + numeral(fixed_price).format() );
                console.log('      rebate         = ' + numeral(rebate).format() );
                console.log('      lump_sum       = ' + numeral(lump_sum).format() );
                console.log('      growth         = ' + numeral(growth).format() );
                console.log('');
                console.log('      trade cashdisc          = ' + numeral(trade_cash_disc).format() );
                console.log('      trade_other_allowances  = ' + numeral(trade_other_allowances).format() );
                console.log('      trade_distributor_trade = ' + numeral(trade_distributor_trade).format() );
                console.log('');
                console.log('      raw_material   = ' + numeral(raw_material).format() );
                console.log('      packaging      = ' + numeral(packaging).format() );
                console.log('      dvl            = ' + numeral(dvl).format() );
                console.log('      fixed_cost     = ' + numeral(fixed_cost).format() );
                console.log('      dnt            = ' + numeral(dnt).format() );
                console.log('      equip          = ' + numeral(equip).format() );
                console.log('      comp_cost      = ' + numeral(comp_cost).format() );
                console.log('');
            };

        };
    };

    calculate();
    <!--- show body to provide visual indication that calculation is done --->
    $('body').fadeIn(400);
});

<!------------------------->
<!--- document is ready --->
<!------------------------->
$(document).ready(function () {
    gridviewScroll();

    numeral.defaultFormat('($0,0.0000)');  <!--- default to dollar format --->

    <!--------------------------------->
    <!--- reset, add products, save --->
    <!--------------------------------->
    $('#reset38, #prod38, #save38, #dist38').click(function(){
      <!---  hide body to provide visual indication that something is taking place --->
      $('#actions').html("<span class='legend'>Processing...</span>");
      $('body').fadeOut(350);

      <!--- perform calculation before changes take place --->
      calculate();

      <!--- need to enable read-only inputs to avoid event errors --->
      $("input[disabled=disabled]").removeAttr("disabled");
      $('input[name=action]').val( $(this).prop("id") );

      $('form[name=whatif_product]').submit();
    });

    <!--------------------->
    <!--- calculate     --->
    <!--------------------->
    $('#calc38').click(function(){
        <!---  hide body to provide visual indication that calculation is taking place --->
        $('body').hide();
        if (jsdebug) {
            console.clear();
        }
        calculate();
        <!--- show body to provide visual indication that calculation is done --->
        $('body').fadeIn(400);
    });

    calculate();
});

var dollarFormat2 = "($0,0.00)";

function calculate() {
    <!--- scanning thru all products on the page --->
    for (var idx = 1; idx <= product_count; idx++) {

        <!--- first iteration = system values; second iteration = user values --->
        for (var cdx = 1; cdx <= 2; cdx++ ) {

            <!--- gather existing values --->
            var net_weight   = $('#user_net_weight_' + idx).text()
               ,prefix       = (cdx == 1 ? '#system' : 'input[name=user')
               ,suffix       = (cdx == 1 ? '' : ']')
               <!--- use id selector for system elements and name selector for user elements --->

            <!--- calculate discount --->
            var fixed_price = stringToNumeric2( $(prefix + '_fixed_price_' + idx + suffix) )
               ,rebate      = stringToNumeric2( $(prefix + '_rebate_' + idx + suffix) )
               ,lump_sum    = stringToNumeric2( $(prefix + '_ls_' + idx + suffix) )
               ,growth      = stringToNumeric2( $(prefix + '_growth_' + idx + suffix) )
               ,list_price  = stringToNumeric2( $(prefix + '_list_price_' + idx + suffix) )
               ,discount    = (fixed_price == 0 ? 0 : list_price - fixed_price) + rebate + lump_sum + growth
               ,cash_disc   = stringToNumeric2( $(prefix + '_cash_disc_' + idx + suffix) )

               ,trade_cash_disc        = stringToNumeric2( $(prefix + '_trade_cash_disc_' + idx + suffix) )
               ,trade_other_allowances = stringToNumeric2( $(prefix + '_trade_other_allowances_' + idx + suffix) )
               ,distributor_trade      = stringToNumeric2( $(prefix + '_distributor_trade_' + idx + suffix) )


               ,sum_abs     = 0
               ,lp_abs      = 0
               ,disc_abs    = 0
               ,ns_abs      = 0
               ,cost_abs    = 0
               ,oi_abs      = 0
               ,csa_abs     = 0
               ,trade_abs   = 0
               ,cash_disc_abs = 0
               ,trade       = trade_cash_disc + trade_other_allowances + distributor_trade;

            <!--- calculate discount percent --->
            var disc_percent  = (list_price == 0 ? 0 : ( discount /  list_price ) * 100 );

            <!--- calculate net sales --->
            var net_sales  = list_price - discount - trade - cash_disc;

            <!--- calculate cost total --->
            var raw_material = stringToNumeric2( $(prefix + '_raw_material_' + idx + suffix) )
               ,packaging    = stringToNumeric2( $(prefix + '_packaging_' + idx + suffix) )
               ,dvl          = stringToNumeric2( $(prefix + '_dvl_' + idx + suffix) )
               ,fixed_cost   = stringToNumeric2( $(prefix + '_fixed_cost_' + idx + suffix) )
               ,dnt          = stringToNumeric2( $(prefix + '_dnt_' + idx + suffix) )
               ,equip        = stringToNumeric2( $(prefix + '_equip_' + idx + suffix) )
               ,comp_cost    = stringToNumeric2( $(prefix + '_comp_cost_' + idx + suffix) )
               ,cost         = raw_material + packaging + dvl + fixed_cost + dnt + equip + comp_cost;

            <!--- calculate operating income, operating margin, csa --->
            var opr_income  = net_sales - cost
                ,opr_margin = (list_price == 0 ? 0 : opr_income / list_price) * 100
                ,volume     = stringToNumeric2( $(prefix + '_volume_' + idx + suffix) )
                ,csa        = discount * volume;

            if (cdx == 1) {  // system values
                <!--- display calculated values --->
                $('#system_net_sales_' + idx).text(numeral( net_sales ).format( dollarFormat2 ) );
                $('#system_cost_' + idx).text(numeral( cost ).format() );
                $('#system_opr_income_' + idx).text(numeral( opr_income ).format( dollarFormat2 ) );
                $('#system_opr_margin_' + idx).text(numeral( opr_margin ).format('(0') );
                $('#system_csa_' + idx).text(numeral( csa ).format() );
            }
            else {   // user values
                <!--- calculate summary absolute --->
                $('input.uomi').each(function() {
                    sum_abs += stringToNumeric( $(this).val() );
                });
                $('td#uom38 div.GridCellDiv').text( numeral( sum_abs ).format('(0,0') );

                <!--- calculate list price summaries --->
                $('input.lp38i').each(function() {
                    lp_abs += stringToNumeric( $(this).val() );
                });
                $('td#lp38a').text( numeral( lp_abs ).format("$0,0") );
                $('td#lp38r').text( numeral( sum_abs == 0 ? 0 : lp_abs / sum_abs ).format() );

                <!--- calculate cash discount summaries --->
                $('input.cd38i').each(function() {
                    cash_disc_abs += stringToNumeric( $(this).val() );
                });
                $('td#cd38a').text( numeral( cash_disc_abs ).format("$0,0") );
                $('td#cd38r').text( numeral( sum_abs == 0 ? 0 : cash_disc_abs / sum_abs ).format() );

                <!--- reformat values entered by user with commas, decimal digits and dollar sign --->
                $('input[name=user_volume_' + idx + ']').val(numeral( volume ).format("0,0.00") );

                $('input[name=user_fixed_price_' + idx + ']').val(numeral( fixed_price ).format() );
                $('input[name=user_rebate_' + idx + ']').val(numeral( rebate ).format() );
                $('input[name=user_ls_' + idx + ']').val(numeral( lump_sum ).format() );

                $('input[name=user_growth_' + idx + ']').val(numeral( growth ).format() );
                $('input[name=user_list_price_' + idx + ']').val(numeral( list_price ).format() );

                $('input[name=user_trade_cash_disc_' + idx + ']').val(numeral( trade_cash_disc ).format() );
                $('input[name=user_trade_other_allowances_' + idx + ']').val(numeral( trade_other_allowances ).format() );
                $('input[name=user_distributor_trade_' + idx + ']').val(numeral( distributor_trade ).format() );
                $('#user_trade_' + idx).text(numeral( trade ).format() );

                $('input[name=user_raw_material_' + idx + ']').val(numeral( raw_material ).format() );
                $('input[name=user_packaging_' + idx + ']').val(numeral( packaging ).format() );
                $('input[name=user_dvl_' + idx + ']').val(numeral( dvl ).format() );

                $('input[name=user_fixed_cost_' + idx + ']').val(numeral( fixed_cost ).format() );
                $('input[name=user_dnt_' + idx + ']').val(numeral( dnt ).format() );
                $('input[name=user_equip_' + idx + ']').val(numeral( equip ).format() );

                $('input[name=user_comp_cost_' + idx + ']').val(numeral( comp_cost ).format() );

                <!--- display calculated values, save them into hidden inputs to store in db later --->
                $('#user_disc_' + idx).text(numeral( discount ).format() );
                $('input[name=user_disc_' + idx + ']').val(numeral( discount ).format() );

                $('#user_disc_percent_' + idx).text(numeral( disc_percent ).format('(0.00') + '%' );
                $('input[name=user_disc_percent_' + idx + ']').val(numeral( disc_percent ).format() );

                $('#user_net_sales_' + idx).text(numeral( net_sales ).format( dollarFormat2 ) );
                $('input[name=user_net_sales_' + idx + ']').val(numeral( net_sales ).format( dollarFormat2 ) );

                $('#user_cost_' + idx).text(numeral( cost ).format() );
                $('input[name=user_cost_' + idx + ']').val(numeral( cost ).format() );

                $('#user_opr_income_' + idx).text(numeral( opr_income ).format( dollarFormat2 ) );
                $('input[name=user_opr_income_' + idx + ']').val(numeral( opr_income ).format( dollarFormat2 ) );

                $('#user_opr_margin_' + idx).text(numeral( opr_margin ).format('(0') + '%' );
                $('input[name=user_opr_margin_' + idx + ']').val(numeral( opr_margin ).format('(0') );

                $('#user_csa_' + idx).text(numeral( csa ).format('($0,0') );
                $('input[name=user_csa_' + idx + ']').val(numeral( csa ).format() );

                $('input[name=user_cash_disc_' + idx + ']').val(numeral( cash_disc ).format() );

                <!--- calculate discount summaries --->
                $('td.disc38t').each(function() {
                    disc_abs += stringToNumeric( $(this).text() );
                });
                $('td#disc38a').text( numeral( disc_abs ).format("($0,0") );
                $('td#disc38r').text( numeral( sum_abs == 0 ? 0 : disc_abs / sum_abs ).format() );

                $('td#dp38a').text( numeral( lp_abs == 0 ? 0 : disc_abs / lp_abs * 100 ).format("0.0") + '%' );

                <!--- calculate trade summaries --->
                $('td.tra38t').each(function() {
                    trade_abs += stringToNumeric( $(this).text() );
                });
                $('td#tra38a').text( numeral( trade_abs ).format("($0,0") );
                $('td#tra38r').text( numeral( sum_abs == 0 ? 0 : trade_abs / sum_abs ).format() );

                <!--- calculate net sales summaries --->
                $('td.ns38t').each(function() {
                    ns_abs += stringToNumeric( $(this).text() );
                });
                $('td#ns38a').text( numeral( ns_abs ).format("($0,0") );
                $('td#ns38r').text( numeral( sum_abs == 0 ? 0 : ns_abs / sum_abs ).format() );

                <!--- calculate cost summaries --->
                $('td.co38t').each(function() {
                    cost_abs += stringToNumeric( $(this).text() );
                });
                $('td#co38a').text( numeral( cost_abs ).format("($0,0") );
                $('td#co38r').text( numeral( sum_abs == 0 ? 0 : cost_abs / sum_abs ).format() );

                <!--- calculate operating income summaries --->
                $('td.oi38t').each(function() {
                    oi_abs += stringToNumeric( $(this).text() );
                });
                $('td#oi38a').text( numeral( oi_abs ).format("($0,0") );
                $('td#oi38r').text( numeral( sum_abs == 0 ? 0 : oi_abs / sum_abs ).format() );

                <!--- calculate operating margin summaries --->
                $('td#om38a').text( numeral( lp_abs == 0 ? 0 : oi_abs / lp_abs * 100 ).format("(0,0.000") + '%' );

                <!--- calculate csa summaries --->
                $('td.csa38t').each(function() {
                    csa_abs += stringToNumeric( $(this).text() );
                });
                $('td#csa38a').text( numeral( csa_abs ).format("$0,0") );
            }   //if (cdx == 1)

            if (jsdebug && idx == 1) {
                console.log('calculate(): product idx = ' + idx);
                console.log('      sum absolute   = ' + numeral(sum_abs).format('0,0') );
                console.log('      fixed price    = ' + numeral(fixed_price).format() );
                console.log('      rebate         = ' + numeral(rebate).format() );
                console.log('      lump sum       = ' + numeral(lump_sum).format() );
                console.log('      growth         = ' + numeral(growth).format() );
                console.log('      discount       = ' + numeral(discount).format() );
                console.log('      discount %     = ' + numeral(disc_percent).format('0.00') );
                console.log('      list price     = ' + numeral(list_price).format() );
                console.log('      trade          = ' + numeral(trade).format() );
                console.log('      net sales      = ' + numeral(net_sales).format() );
                console.log('');
                console.log('      raw_material   = ' + numeral(raw_material).format() );
                console.log('      packaging      = ' + numeral(packaging).format() );
                console.log('      dvl            = ' + numeral(dvl).format() );
                console.log('      fixed_cost     = ' + numeral(fixed_cost).format() );
                console.log('      dnt            = ' + numeral(dnt).format() );
                console.log('      equip          = ' + numeral(equip).format() );
                console.log('      comp_cost      = ' + numeral(comp_cost).format() );
                console.log('      cost           = ' + numeral(cost).format() );
                console.log('');
                console.log('      opr_income     = ' + numeral(opr_income).format() );
                console.log('      opr_margin     = ' + numeral(opr_margin).format() );
                console.log('      csa            = ' + numeral(csa).format() );
            };
        }
    };
}

function gridviewScroll() {
  var  gridWidth = $(window).width() - 40
      ,gridHeight = $(window).height() - 140;
  gridView1 = $('#GridView1').gridviewScroll({
        arrowsize: 30,
        barcolor: "#CDCDCD",
        barhovercolor: "#606060",
        barsize: 18,
        bgcolor: "#F0F0F0",
        freezesize: 3,
        harrowleftimg: "/Images/arrowhl.png",
        harrowrightimg: "/Images/arrowhr.png",
        headerrowcount: 1,
        height: gridHeight,
        railcolor: "#F0F0F0",
        railsize: 16,
        varrowbottomimg: "/Images/arrowvb.png",
        varrowtopimg: "/Images/arrowvt.png",
        width: gridWidth
    });
};

$('table').on('change', 'input', function() { $(this).addClass('changed') });

$('input').forceNumeric();


stringToNumeric = function( str ) {
    <!---  avoid JS error when expected parameter is not a string --->
    if ( typeof str !== 'string' )
        return 0;

    return numeral().unformat( str );
};

stringToNumeric2 = function( $obj ) {
    if ( $obj.is("input") )
        var str = $obj.val();
    else {
        var str = $obj.text();
    }

    <!---  avoid JS error when expected parameter is not a string --->
    if ( typeof str !== 'string' )
        return 0;

    return numeral().unformat( str );
};

refreshContent = function( $obj, s ) {
    <!--- if content is an input tag use val() to update otherwise use text() --->
    if ( $obj.is("input") )
        $obj.val( s );
    else {
        <!--- grid view scroll inserts div.gridcelldiv in header so we need to check for its existence --->
        var div = $obj.find("div.GridCellDiv");
        <!--- just update the content inside the div tag --->
        if (div.length) {
            div.text( s );
        }
        <!--- div.gridcelldiv not found, object does not have any child element --->
        else {
            $obj.text( s );
        }
    }
};

function zapit( row, product ) {
  noty( { text: "Click <b>Delete</b> to remove product <b>" + product + "</b>,<br> otherwise click Cancel."
          ,type:'confirm'
          ,layout:'center'
          ,animation: { open: {height: 'toggle'}, close: {height: 'toggle'}, easing: 'swing', speed: 250 }
          ,buttons: [  { text:'Delete', addClass:'btn-primary', onClick:function($noty) {   $noty.close();
                                                                                            $('body').hide();
                                                                                            $('input[name=delete_row]').val( row );
                                                                                            $('input[name=action]').val( "delete_product" );
                                                                                            $('form[name=whatif_product]').submit();
                                                                                       } }
                      ,{ text:'Cancel', onClick:function($noty) { $noty.close(); } } ]
        });
}

$('#edit38').click(function() {
    $('body').hide();
    $('input[name=action]').val( "edit" );
    $('form[name=whatif_product]').submit();
});

$('#readonly38').click(function() {
    $('body').hide();
    $('input[name=action]').val( "readonly" );
    $('form[name=whatif_product]').submit();
});

<!--- display notification messages at the bottom --->
<cfoutput>
<cfloop from="1" to="#arrayLen(variables.noty.Message)#" index="variables.idx">
    <cfif len(variables.noty.Message[ variables.idx ])>
      noty( { text: "<cfoutput>#variables.noty.Message[ variables.idx ]#</cfoutput>"
              ,type:'information'
              <cfif variables.noty.timeout[ variables.idx ] gt 0>
                  ,timeout: #variables.noty.timeout[ variables.idx ]#
              </cfif>
              ,layout:'bottom'
              ,closeWith: ['click']
            });
    </cfif>
</cfloop>
</cfoutput>

$('textarea[name=whatif_notes]').maxlength( { max: 1000 } );

$('#moretext').click(function() {
    <cfset variables.text = []>
    <cfloop query="variables.approval_consideration" startrow="2">
        <cfset arrayAppend(variables.text, replace(variables.approval_consideration.Approval_Considerations_Text, '"', '', 'all'))>
    </cfloop>
    noty( { text: "<cfoutput>#arrayToList(variables.text, "<br>")#</cfoutput>"
              ,type:'information'
              ,timeout: 30000
              ,layout:'bottom'
              ,killer:true
              ,closeWith: ['click', 'hover']
            });
});
</script>
</body>
</html>