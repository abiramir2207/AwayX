<!---
* ==================================================================================================== 
*    @File: \deployment\redistribution\index.cfm
*  @Author: Chris Nguyen
*    @Date: 2019 May - 85971
* 
* @Remarks: Redistribution page - main file
*
* ==================================================================================================== 
--->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Redistribution @ Blacksmith Applications</title>
	<cfsavecontent variable="head_content">
        <cf_include files="/common_files/tabnav-css.cfm, /styles/fontawesome/5.8/all.css, /common_files/jQuery.cfm, /Common_Files/dhx_message.cfm">

        <style>
            #page-container {
                position: relative;
                min-height: 100vh;
            }
            div#edit_corr {
                min-height: 125px;
                max-height: 125px;
                background-color: #EDEEF2;
            }
            div#open_corr, div#open_history {
                min-height: 28px;
                max-height: 28px;
                background-color: #EDEEF2;
            }
            div#corr_action {
                min-height: 28px;
                max-height: 28px;
            }
            div#corr_list {
                height: 55.5vh;
            }
            .corrections {
                display: block;
            }
            .history {
                display: none;
            }
			input[type="checkbox"] {
				vertical-align: middle;
            }
            ul#pagetabs {
                width: 100%;
            }
            li.navi {
                border-width: 1px;
                border-top-left-radius: .25rem;
                border-top-right-radius: .25rem;
                cursor: pointer;
                width: 11%;
            }


            #read_edit {
                width: 70px;
            }
            button.editing, button.read_only {
                width: 70px;        
            }
            button.editing, button.editing:hover {
                background-color: red;
                border-color: red;
            }
            button.read_only {
                background-color: ##406be4;
                border-color: ##406be4;
            }
            input[readonly] {
                border: none;
                background-color: ##EDEEF2;
            }
            i.distributor {
                margin-left: 4px;
                cursor: pointer;
                color: ##406be4;
            }
            input.item {
                border-left: 1px solid #95A5A6; 
                border-right: 1px solid #95A5A6;
                margin-right: 3px;
                padding-left: 2px;
                width: 70%;
            }
		</style>
    </cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
    <!--- release all locks from current user --->
    <cfquery datasource="#application.datasource#">
        UPDATE REDI_EC_Header
            SET Locked = 0
                ,User_Id_Locked = NULL
                ,Locked_Date = getDate()
        WHERE User_Id_Locked = '#request.AccessStructure.User_ID#'
    </cfquery>

    <cfinclude template="/common_files/ag-grid.cfm">
    <cf_include files="/common_files/tailwind-css.cfm, /common_files/noty.cfm, /script/javascript/moment.min.js, /script/javascript/numeral.min.js">
    <style>
		.ag-theme-balham {
			font-size: 11px;
		}
    </style>
    <cfscript>
        setting_comp = createObject("component", "mvc.Models.settingsService");
        config       = setting_comp.getSettingsObject();
    </cfscript>

	<!---------------------->
	<!--- Whole document --->
	<!---------------------->
    <div class="p-2" id="page-container">
       <div id="content-wrap">
            <!-------------->
            <!--- Header --->
            <!-------------->
            <div id="header" class="flex rounded p-3 text-white font-semibold text-sm bg-blue-darkest mb-1 text justify-between">
                <section class="flex-1">REDISTRIBUTION</section>
            </div>

            <!-------------------->
            <!--- Navigation  --->
            <!-------------------->
            <div id="navi" class="flex justify-between border-b mb-2">
                <ul class="flex list-reset nav mx-2 -mb-px" id="pagetabs">
                    <cfoutput>					
                        <li name="corrections" class="navi">Corrections</li>
                        <li name="history"     class="navi">History</li>
                    </cfoutput>
                </ul>
            </div>
        </div>
        
        <!--- render corrections --->
        <cfinclude template="corrections.cfm">

        <!--- define hidden history elements --->
        <cfinclude template="history.cfm">
    </div>        


    <script>
        "use strict";

        // global constants in browser localStorage 
        const REDISTRIBUTION_IS_OPENED = "redistribution_is_opened";   // exists only when redistribution tab is opened
        localStorage.setItem(REDISTRIBUTION_IS_OPENED, "true");

        // global array stores grid options for all edit tabs
        const edit_grids = {};
        // global array keeps track of locked IDs
        const locked_ids = [];
        // global array keeps track of popups
        const popups = [];
        // global flag keeps track of history content loading
        let is_history_loaded = false;

        activate_tab("corrections");

        // adjust columns to fit when window is resized
        $(window).resize(function(){ resize_grid(); });

        // unlock all selected records from current user before window is closed
        $(window).unload(function(){
            localStorage.removeItem(REDISTRIBUTION_IS_OPENED);
            $.ajax({
                    url: "./ajax/lock_correction.cfm"
                    ,data: { mode: "unlock_all" }
                    ,type: "POST"
            });           
            // close popups (e.g. distributor search) created by this page
            for (var i = 0; i < popups.length; i++) {
                popups[i] && popups[i].close();
            }
        });
        
        function resize_grid() {
            let current_tab = $("li.navi.active").attr("name");
            switch (current_tab) {
                case "corrections":
                    set_grid_full_height("correction_grid");
                    // correction_grid.api.sizeColumnsToFit();
                    autoSizeAllColumns(correction_grid);
                    break;        
                case "history":
                    set_grid_full_height("history_grid");
                    // history_grid.api.sizeColumnsToFit();                
                    autoSizeAllColumns(history_grid);
                    break;        
                default:
                    set_grid_full_height("agdiv_" + current_tab);
                    if (edit_grids[current_tab]) {
                        // edit_grids[current_tab].api.sizeColumnsToFit();
                        autoSizeAllColumns(edit_grids[current_tab]);
                    }
                    break;
            }
        }

        ///////////////////////////////////////
        //  navigation tab switching event   //
        ///////////////////////////////////////
        $("#page-container").on("click", "li.navi", function(e){
            let target = $(e.target);
            activate_tab( $(target).attr("name") );
        });

        function activate_tab( new_tab ) {
            // activate new tab
            if (new_tab) {
                // hide divs in current tab
                let current_tab = $("li.navi.active").attr("name");
                if (current_tab) {
                    $("div." + current_tab).hide();
                    // deactivate current tab
                    $("li[name=" + current_tab + "]").removeClass("active");
                }

                $("li.navi[name=" + new_tab + "]").addClass("active");
                // show divs in new tab
                $("div." + new_tab).show();
                resize_grid();
    
                if (new_tab === 'history' && !is_history_loaded) {
                    is_history_loaded = true;
                    // this function is defined in history.cfm
                    load_history();
                }
            }
        }

        function close_edit_tab( header_primary_key ) {
            $("." + header_primary_key).remove();
            let id_index = locked_ids.indexOf(parseInt(header_primary_key));
            // release lock if it was locked previously
            if (id_index != -1) {
                locked_ids.splice(id_index);
                $.ajax({
                         url:  "./ajax/lock_correction.cfm"
                        ,data: { header_primary_key: header_primary_key, mode: "read only" }
                        ,type: "POST"
                });
            }
            // disable close all edit button when number of tabs is less than 3
            if ($("li.navi").length < 3) {
                $("button#close_all_edit").attr("disabled", "disabled");
            }
            // go back to corrections tab
            activate_tab( "corrections" );
        }

        /////////////////////////////////
        //  [ close edit tab ] event   //
        /////////////////////////////////
        $("#page-container").on("click", "button.close,i.close", function(e){
            e.preventDefault();
            e.stopPropagation();
            // grap the unique header primary key 
            let header_primary_key = $(e.target).attr("header_id");
            close_edit_tab( header_primary_key );
        });

        /////////////////////////////////////////
        //  [ read-only/edit button ] event   //
        ////////////////////////////////////////
        $("#page-container").on("click", "button.read_edit", function(e){ 
            e.preventDefault();
            let re_button = $(e.target);
            let header_primary_key = re_button.attr("header_id");
            let new_mode  = (re_button.text().trim() === "editing" ? "read only" : "editing");
            $("div." + header_primary_key).fadeOut();
            // update locking status in database
            $.ajax({
                  url:      "./ajax/lock_correction.cfm"
                 ,data:     { header_primary_key: header_primary_key, mode: new_mode }
                 ,dataType: "text"
                 ,type:     "POST"
                 ,error:    function(xhr, status, error) { error_handler(arguments) }
                 ,success:  function( result ) {
                                                if (result.trim() !== "success") {
                                                    $("div." + header_primary_key).fadeIn();
                                                    dhx_alert( result.trim() );
                                                }
                                                else {
                                                    load_edit_tab(header_primary_key);
                                                    // keep track of locked IDs in global variable "locked_ids"
                                                    let id_index = locked_ids.indexOf(header_primary_key);
                                                    if (new_mode === "editing") {
                                                        // add currrent locked ID
                                                        if (id_index == -1)
                                                            locked_ids.push(header_primary_key);
                                                    }
                                                    else {
                                                        // remove current locked ID
                                                        if (id_index != -1)
                                                            locked_ids.splice(id_index);
                                                    }
                                                }
                                            }
            });
        });

        function load_edit_tab( header_primary_key ) {
            // clears out existing grid to avoid memory leaks
            edit_grids[header_primary_key] && edit_grids[header_primary_key].api.destroy();

            $.ajax({
                     url:      "ajax/edit_correction.cfm"
                    ,data:     {     header_primary_key:       header_primary_key
                                    <cfoutput>            
                                    ,Original_Buyer_Label:     '#config.appSettings.Original_Buyer_Label#'
                                    ,Final_Buyer_Label:        '#config.appSettings.Final_Buyer_Label#'
                                    ,redistribution_page_size: '#redistribution_page_size#'
                                    </cfoutput>
                                }
                    ,dataType: "text"
                    ,error:    function(xhr, status, error) { error_handler(arguments) }
                    ,success:  function( result ) { $("div." + header_primary_key).empty().append(result).fadeIn(); 
                                                    set_grid_full_height("agdiv_" + header_primary_key);
                                                    // console.log("height2 = ", get_grid_full_height("agdiv_" + header_primary_key))                
                                                }
                    ,type:     "POST"
                });
            $("button#close_all_edit").removeAttr("disabled");
        }

        $("#page-container").on("click", "a.alias_management", function(e){ 
            opentab('alias_management');
        });

        //////////////////////////////////////////
        //  [ distributor search icon ] event   //
        //////////////////////////////////////////
        $("#page-container").on("click", "i.distributor", function(e){ 
            let target     = $(e.target);
            let input_guid = target.prev();
            let input_text = input_guid.prev();
            // keep track of popups
            popups.push( 
                        popupCenter( "/billbacks/search_screens/PM_select_distributors.cfm"
                                                + "?formName=form_" + target.attr("header_id")
                                                + "&fieldName=" + input_guid.attr("name")
                                                + "&reloadForm=false"
                                                + "&SelectSingleSearchResultOnly=1"
                                                + "&PageSource=redistribution"
                                                + "&parent_ShipTo=" + input_text.attr("name")
                                            , "redistribution_distributor_search"
                                    )
                    );
        });

        ///////////////////////////////////
        //  [ item search icon ] event   //
        ///////////////////////////////////
        $("#page-container").on("click", "i.item", function(e){ 
            let target = $(e.target);
            let form   = target.closest("form");
            let item   = target.prev ("input");
            // keep track of popups
            popups.push( 
                        popupCenter( "/common_files/contracts/product_Select_V1.cfm"
                                                + "?formName=form_" + form.attr("header_id")
                                                + "&SelectSingleSearchResultOnly=1"
                                                + "&PageSource=redistribution"
                                                + "&Return_Value_Field_Name=" + item.attr("name")
                                            , "redistribution_item_search"
                                    )
                    );
        });

        /////////////////////////////////////////////////
        // call back function from product lookup popup
        /////////////////////////////////////////////////
        function refresh_item(item_name, selected_items) {
            if (selected_items.length)
                $("input[name=" + item_name + "]").val( selected_items[0].product );
        }

        ///////////////////////////////////
        // getting data ready to validate
        ///////////////////////////////////
        function get_validation_json( edit_form ){
            let outcome        = {};
                outcome.header = {};
            // save all header elements into a structure
            edit_form.find("input.header").each(function(){
                outcome.header[ $(this).attr("name") ] = $(this).val();
            });

            outcome.detail = [];
            // save all detail elements into an array
            edit_form.find("input.item").each(function(){
                // split elements in item name and reverse the order so detail identity appears in the 1st array slot
                let splitted_item_name = $(this).attr("name").split("_").reverse();
                outcome.detail.push( { item:$(this).val(), row_identity:splitted_item_name[0] } );
            });

            return JSON.stringify(outcome);
        }

        //////////////////////////////////
        //  [ validate button ] event   //
        //////////////////////////////////
        $("#page-container").on("click", "button.validate", function(e){ 
            e.preventDefault();
            
            let errors                    = [];
            let form                      = $(e.target).closest("form");
            let original_customer_ship_to = form.find("input.original_customer_ship_to").val();
            let final_customer_ship_to    = form.find("input.final_customer_ship_to").val();
            <cfoutput>                
            let original_customer_error   = '<b>Man. #(config.appSettings.Original_Buyer_Label)# Sold To</b> is required.';
            let final_customer_error      = '<b>Man. #(config.appSettings.Final_Buyer_Label)# Sold To</b> is required.';
            </cfoutput>                            
            
            // validate required inputs
            if (original_customer_ship_to === '') {
                errors.push( original_customer_error );            }
            if (final_customer_ship_to === '') 
                errors.push( final_customer_error );

            form.find("input.item").each(function(){
                if ($(this).val() === '') {
                    errors.push( "<b>Item</b> is required." );
                    return false;
                }
            });

            if (errors.length) {
                dhx_alert("Please enter all required information.<br><br>" + errors.join("<br>"), "Alert", "alert-error");
            }
            else {
                let header_primary_key = form.attr("header_id");
                let this_grid          = edit_grids[ header_primary_key ];
                this_grid.api.showLoadingOverlay();
                // required inputs exist, now submit to server for additional validations
                $.ajax({
                        url:      "ajax/validate_correction.cfm"
                        ,data:     { submitted_json: get_validation_json( form ) }
                        ,type:     "POST"
                        ,error:    function(xhr, status, error) { 
                                                                    this_grid.api.hideOverlay();
                                                                    error_handler(arguments); // unexpected issue
                                                                }  
                        ,success:  function( result ) {
                                                        this_grid.api.hideOverlay();
                                                        if (typeof result === 'string') { 
                                                           result = JSON.parse(result); 
                                                           if (result.STATUS.toLowerCase() === "success") {
                                                                dhx_alert( result.MESSAGES, "Validate Result", "alert" );
                                                                close_edit_tab( header_primary_key );
                                                           }
                                                           else {
                                                                dhx_alert( result.MESSAGES, "Alert", "alert-error" );
                                                           }
                                                        }
                                                    }
                    });                
            }
        });

        ///////////////////////////////////
        //  [ reprocess ] button event   //
        ///////////////////////////////////
        $("#page-container").on("click", "button.reprocess", function(e){
            e.preventDefault();
            e.stopPropagation();
            let selected = correction_grid.api.getSelectedNodes();
            if (selected.length == 0) {
                dhx_alert( "Please select at least one entry from the list to reprocess." );
                return;
            }
            correction_grid.api.showLoadingOverlay();
            let ids = [];
            for (let i = 0; i < selected.length; i++) {
                ids.push(selected[i].data[ corr_index.header_primary_key ]);
            }
            // required entries exist, now submit to server for reprocessing
            $.ajax({
                     url:      "ajax/reprocess_corrections.cfm"
                    ,data:     {  ids_list: ids.join(",") }
                    ,dataType: "text"
                    ,type:     "POST"
                    ,error:    function(xhr, status, error) { 
                                                                correction_grid.api.hideOverlay();
                                                                error_handler(arguments); // unexpected issue
                                                            }  
                    ,success:  function( result ) {  
                                                        if (typeof result === 'string') { 
                                                           result = JSON.parse(result); 
                                                           correction_grid.api.setRowData( result.ROWS );
                                                           dhx_alert( result.MESSAGES, "Reprocess Results", "alert" );
                                                        }
                                                }
                });
        });

        $("#page-container").on("submit", "form.edit_tab", function(event){ 
            event.preventDefault();
            return false;
        });
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>