<!--
  * ====================================================================================================
  *    @File: \common_Files\contracts\verticalpnl_total_hm.cfm
  *  @Author: Chris Nguyen
  *    @Date: 2021 January
  *
  * @Remarks: Renders P&L totals for Huhtamaki
  *
  *
  * ====================================================================================================
-->
<cffunction name="render_empty_row" output="true">
    <tr class="GridViewScrollItem">
        <cfscript>
            // define a very short & sweet function scoped structure variable
            var l = {};
            // TODO: adjust this constant value based on number of actual frozen columns
            l.FROZEN_COLUMNS = 1;
        </cfscript>

        <cfoutput query="getAllProductMargins">
                    <td class="empty"> &nbsp; </td>
        </cfoutput>

    </tr>    
</cffunction>

<!--- <cfset render_empty_row()> --->
<!--------------------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~----->
<!--- TOTAL REQUESTED ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~----->
<!--------------------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~----->
<!--- <cfset render_row(["Total Requested"])> --->
    <cfscript>
         // render_row(["Total Requested"]);
         // render_item_row(col='Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;Case Volume', dType='int', decPlaces='');
         // render_item_row(col='Case_Count,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;Units Volume', dType='int', decPlaces='');
         // render_item_row(col='Net_Sales,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;Net Sales', dType='', decPlaces=request.dollar_format);
         // render_item_row(col='Contribution_Margin_Alt,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;CM $', dType='', decPlaces=request.dollar_format);
         // render_item_row(col='Contribution_Margin_Alt,Net_Sales',title='&nbsp;&nbsp;&nbsp;CM %', dType='', decPlaces=request.numeric_format);
         // render_item_row(col='Operating_Income,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;GP $', dType='', decPlaces=request.dollar_format);
         // render_item_row(col='Operating_Income,Net_Sales',title='&nbsp;&nbsp;&nbsp;GP %', dType='', decPlaces=request.dollar_format);
         // render_row(["Total Current"]);
         // render_item_row(col='Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;Case Volume', dType='int', decPlaces='', bPrevious = 1);
         // render_item_row(col='Case_Count,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;Units Volume', dType='int', decPlaces='', bPrevious = 1);
         // render_item_row(col='Net_Sales,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;Net Sales', dType='', decPlaces=request.dollar_format, bPrevious = 1);
         // render_item_row(col='Contribution_Margin_Alt,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;CM $', dType='', decPlaces=request.dollar_format, bPrevious = 1);
         // render_item_row(col='Contribution_Margin_Alt,Net_Sales',title='&nbsp;&nbsp;&nbsp;CM %', dType='', decPlaces=request.numeric_format, bPrevious = 1);
         // render_item_row(col='Operating_Income,Product_Program_Volume',title='&nbsp;&nbsp;&nbsp;GP $', dType='', decPlaces=request.dollar_format, bPrevious = 1);
         // render_item_row(col='Operating_Income,Net_Sales',title='&nbsp;&nbsp;&nbsp;GP %', dType='', decPlaces=request.numeric_format, bPrevious = 1);
    </cfscript>
<!-----------------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~------>
<!--- TOTAL CURRENT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~----->
<!------------------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~----->

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
