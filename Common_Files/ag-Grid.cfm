<cfsetting enableCFoutputOnly = "yes">
<!---------------------------------------------------------------------------------------------------------------------
  Template: /Common_Files/ag-Grid.cfm
  Date:     2017 December
  Author:   Chris Nguyen
  Purpose:  Set up ag-Grid using FORGE enterprise license key and provide default features

  Remark:   After include this file you need to call ag_grid_default(gridOptions) to assign default ag_grid.settings
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
	param name="request.ag_grid_theme"         default="ba-ag-theme-balham";
	param name="request.ag_grid_version"       default="21";
    param name="request.ag_grid_dense"         default="1";
    param name="request.ag_expand_header_bars" default="0";
    
    // scheduled tasks need these variable definitions
    param name="request.forge_module"            default="";      
    param name="request.accessStructure.User_ID" default="";

	request.ag_grid_theme   = trim(request.ag_grid_theme);
	request.ag_grid_version = trim(request.ag_grid_version);

	source_path = "/script/javascript/ag-grid/" & request.ag_grid_version;
</cfscript>

<cfoutput>
<!--- load a compressed version on production site --->
<cfset js_file = "ag-grid-enterprise" 
                    & ( application.util.io.isProduction()
                            ? ".min"
                            : "" )
                    & ".nostyle.js">

<cf_include files="/script/javascript/loglevel/1.6.8/loglevel.min.js">

<script>
    // place all parameters that you want to pass to JS into this object
    <cfoutput>
        cf_settings = {
                               ag_grid_cacheBlockSize: #val(application.util.query.get_setting("ag_grid_cacheBlockSize", 0))#
                             , ag_grid_license:        '#application.util.query.get_setting("ag_grid_license")#'
                             , ag_grid_theme:          '#lcase(request.ag_grid_theme)#'
                             , ag_grid_version:        '#request.ag_grid_version#'
                             , script_name:            '#lcase(cgi.script_name)#'
                             , user_id:                '#request.accessStructure.User_ID#'
                             , ag_grid_dense:          '#request.ag_grid_dense#'
        };
    </cfoutput>        

    <cfif structKeyExists(request, "is_developer") and request.is_developer>
        log.enableAll();
    </cfif>
</script>

<cf_include files="#source_path#/#js_file#, /script/javascript/ag-grid/ag-grid.js">

<cfif request.ag_grid_theme is "ba-ag-theme-balham">
	<cf_include files="#source_path#/ba/ba-ag-theme-balham.css">    
<cfelse>
	<cf_include files="#source_path#/ag-grid.css, #source_path#/ag-theme-balham.css">
</cfif>
</cfoutput>

<cfsetting enableCFoutputOnly = "no">
<!--- 87493, 85971 --->
<style>
    /* removed extra white space on the right of sidebar panel */
    div.ag-tool-panel-wrapper {
        padding-right: 10px;
        width: auto;
    }
    /* get rid of sidebar buttons panel */
    div.ag-side-buttons {
        display: none;
    }
    /* reduce checkbox size to support large zoom levels */
    span.ag-selection-checkbox {
        font-size: 10px;
    }
    /* hide pagination buttons First Previous Next Last */
    div.ag-paging-button > button {
        display: none;
    }
    .ag-theme-balham .ag-status-bar {
        line-height: 0.85;
        font-size: 11px;
    }
    /* multi-columns sorting number */
    span[ref=eSortOrder] {
        display: none;
    }

    <cfif request.forge_module is "planners">
        .ag-theme-balham .ag-header {
            background-color: #9BC2E6;
        }
    </cfif>
    
    input.ag-floating-filter-input:focus {
        background-color:#FFFE9D;
    }

    div.editable {
        background-color: #ffffff;
        box-shadow: inset 0 1px 2px rgba(0,0,0,.39);
        height: 18px;
    }

    div.attention {
        background-color:#FFFE9D;
        box-shadow: inset 0 1px 2px rgba(0,0,0,.39);
        height: 18px;
    }

    .last_changed {
        background-color: #ffedd2;
        border-bottom: 1px solid #d8d9dd;
        border-radius: 5px;
        color: #343540;
        font-size: 12px;
        margin-bottom: 10px;
        padding: 7px 0 5px 5px;
    }
    .textRight{
        text-align: right;
    }


    <cfif request.ag_expand_header_bars neq "0">
        div.ag-header-cell-resize {
            width: 5px !important;
            height: 100%;
            background-color: #cdb590;
            opacity: 0.7;
        }
        .ag-theme-balham .ag-header-cell::after, .ag-theme-balham .ag-header-group-cell::after {
            height: 100%;
            margin-top: 0;
        }    
    </cfif>

    div.user_edited { background-color: #defade }
    div.user_edited::after { content: " *" }
    p.user_edited { 
        color: #393939;
        font-size: 11px;
        margin-right: 20px;
        background-color: #defade;
        padding-left: 10px
        padding-right: 10px
    }
</style>