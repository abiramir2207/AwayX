<!---
  * ==================================================================================================== 
  *    @File: /settings/ADL/adl_edit.cfm
  *  @Author: Sharon Harris
  *    @Date: April 2021
  * 
  * @Remarks: Edit an Authorized Distribution List
  *
  * ==================================================================================================== 
--->

<cfsilent>
	<cfparam name="form.ExistingProductList" default="" />
	<cfparam name="form.Product_List" default="" />
	
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <!--- ~~~~~ Backend posting logic ~~~~~~ --->
    <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
    <cfif cgi.request_method is "post">
    	<cfif form.action is "addProd" and form.Product_List neq "">
    		<cfscript>
    			adl_cfc = createObject("component", "mvc.models.settings.ADLManager");
    			adl_cfc.addProducts(form.id, form.Product_List);
    		</cfscript>
			<cflocation url="/settings/ADL/adl_edit.cfm?id=#form.id#" addToken="no" /> 
		<cfelseif form.action is "likeProd">
			<cfscript>
    			adl_cfc = createObject("component", "mvc.models.settings.ADLManager");
    			adl_cfc.updateLikeProduct(form.id, form.rowId, form.Product_List);
    		</cfscript>
			<cflocation url="/settings/ADL/adl_edit.cfm?id=#form.id#" addToken="no" /> 
    	</cfif>
    </cfif>
</cfsilent>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<style>
		* { box-sizing: border-box; margin: 0; padding: 0; }
		html { background-color: white; }
        div.header p { margin: 10px 5px; }
        div#actions { margin: 5px; }
		div#aggrid { margin: 0 5px; height: 600px; }
        .rightA { text-align: right; }
        div.edit { padding-left: 7px; }
    </style>
</head>
<body>
    <cfscript>
		adl_cfc = createObject("component", "mvc.models.settings.ADLManager");
		qHeader = adl_cfc.getADLHeader(headerId=url.id);
		qryADLDetail = adl_cfc.getADLdetail(url.id);
		qADLDetail = adl_cfc.getQueryAsArray(qryADLDetail);
		
		header_height = qHeader.Updated_Date neq '' ? 75 : 36;
		jQueryUI.widgets = "datepicker";
		jQuery.version = "1.12.4";

		request.ag_grid_dense = 0;
		request.ag_grid_version = "23";
    </cfscript>
	
    <cf_include files="/common_files/ag-Grid.cfm, /common_files/jQuery.cfm, /common_files/jQueryUI.cfm, /common_files/dhx_windows.cfm, /script/javascript/numeral.min.js, /styles/css-loader.css, /styles/font-awesome.min.css, /common_files/noty.cfm">


    <cfoutput>       
        <div class="header">
            <cfif qHeader.Updated_Date neq ''>
                <p class="last_changed">Last updated on <b class="last_changed_d">#dateFormat(qHeader.Updated_Date, "medium")#</b> at <span class="last_changed_t">#timeFormat(qHeader.Updated_Date, "short")#</span> by <b class="last_changed_by">#qHeader.Updated_By_User_Name#</b>
                    <span class="changes_made" style="display:none;float:right;padding-right:5px;color:red;"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Changes have been made. Remember to save them.</span>
                </p>
            </cfif>

            <div id="actions">
                <button class="button" id="addItem">Add #application.returned_customer_setting.Item_Label#s</button>
                <!--- <button class="button save recommended">Save</button> --->
				<!--- <button class="button cancel">Cancel</button> --->

            </div>            
        </div>

        <form name="adl_edit" method="post" action="adl_edit.cfm?id=#url.id#">
            <input type="hidden" name="id" value="#url.id#">
            <input type="hidden" name="action">
            <input type="hidden" name="ExistingProductList">
            <input type="hidden" name="Product_List" value="#form.Product_List#">
            <input type="hidden" name="rowId">
            <div id="aggrid" class="ag-theme-balham"></div>   
		</form>
    </cfoutput>
		
	<cfinclude template="/settings/ADL/adl_detail_grid.cfm">

    <script>

		// $("button.cancel").click(function(){
            // parent.delete_new_tab();
        // });


        'use strict';
        
        <!--- ~~~~~~~~~~ glob = global variables  ~~~~~~~~~~ --->
        let glob = { grid_id: "#aggrid", tab_name:"edit" };

		// Create the Grid as editable.  Function is shared with the details viewer
		glob.my_grid = create_detail_grid (glob.grid_id, true);


		$("#addItem").click(function() {
			let prodList = getProductList(glob.my_grid);
			//set ExistingProductList = current list of items, so that product search tool can show those records as selected by default
			$("input[name=ExistingProductList]").val(prodList);
			$("input[name=action]").val("addProd");
			NewWindow("/Common_Files/contracts/product_Select_V1.cfm?Formname=adl_edit", 
							 "productwindow_old", 
							 1000, 700, "yes", "yes")
			
		});
		
		function getProductList (oGrid) {
			let prodList = [];
			
			oGrid.api.forEachNode(function(rowNode, index) {
				prodList.push(rowNode.data.PRODUCT_ID);
            });
			
			return prodList.join();
		}

		
    </script>

    <cfset request.focusHiLightOff = true>
</body>
</html>