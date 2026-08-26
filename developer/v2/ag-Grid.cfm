<cfsetting enableCFoutputOnly = "yes">
<!---------------------------------------------------------------------------------------------------------------------
  Template: /developer/v2//ag-Grid.cfm
  Date:     2020 June
  Author:   Chris Nguyen
  Purpose:  Set up ag-Grid using FORGE enterprise license key and provide default features

  Remark:   After include this file you need to call ag_grid_default(gridOptions) to assign default ag_grid.settings
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
	param name="request.ag_grid_theme"   default="ba-ag-theme-balham";
	param name="request.ag_grid_version" default="22";
    param name="request.ag_grid_dense"   default="0";

	request.ag_grid_theme   = trim(request.ag_grid_theme);
	request.ag_grid_version = trim(request.ag_grid_version);

	source_path = "/script/javascript/ag-grid/" & request.ag_grid_version;
</cfscript>

<cfoutput>
<!--- load a compressed version on production site --->
<!--- <cfset js_file = "ag-grid-enterprise.min.nostyle.js"> --->

<script>
    // place all parameters that you want to pass to JS into this object
    <cfoutput>
        cf_settings = {
                               ag_grid_cacheBlockSize: #val(application.util.query.get_setting("ag_grid_cacheBlockSize", 0))#
                             , ag_grid_license:        'Blacksmith_Applications_Inc_Forge_Single_Application_7_Devs_2_Deployment_Licenses_27_March_2021_[v2]_MTYxNjgwMzIwMDAwMA==d7baa87c1d87ee74751c5c898c1b8cd9'
                             , ag_grid_theme:          '#lcase(request.ag_grid_theme)#'
                             , ag_grid_version:        '#request.ag_grid_version#'
                             , script_name:            '#lcase(cgi.script_name)#'
                             , user_id:                '#request.accessStructure.User_ID#'
                             , ag_grid_dense:          '#request.ag_grid_dense#'
        };
    </cfoutput>        
</script>

<script src="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ag-grid/22/ag-grid-enterprise.min.js"></script>
<script src="ag-grid.js"></script>

<link rel="stylesheet" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ag-grid/22/ag-grid.css">
<link rel="stylesheet" href="<cfoutput>#request.forge_cdn#</cfoutput>/script/javascript/ag-grid/22/ag-theme-balham.css">
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
    .ag-theme-balham .ag-selection-checkbox span {
        top: -1.5px;
    }

    <cfif request.forge_module is "planners">
        .ag-theme-balham .ag-header {
            background-color: #9BC2E6;
        }
    </cfif>

    .ag-theme-balham .ag-row-odd {
        /* background-color: #F3F3F3; */
    }
    .ag-theme-balham .ag-row-hover2 {
        font-weight: bold !important;
        /* box-shadow: rgba(50, 50, 93, 0.25) 0px 30px 60px -12px inset, rgba(0, 0, 0, 0.3) 0px 18px 36px -18px inset; */
        /* box-shadow: rgba(50, 50, 93, 0.25) 0px 3px 3px -2px inset, rgba(0, 0, 0, 0.3) 0px 2px 2px -1px inset; */
        /* box-shadow: inset 0 -.3em .3em rgba(0,0,0,0.1), 0 0  0 2px rgb(255,255,255), 0.3em 0.3em 1em rgba(0,0,0,0.3); */
        color: white;
        background-color: transparent;
        background-image: linear-gradient(white, rgb(128,0,0));
        background-image: linear-gradient(white, rgb(128,0,0,0.9));
    }
    input:focus, select:focus, textarea:focus {
        background-color:#FFFE9D;
        outline: none;
    	border-color: #9ecaed;
    	box-shadow: 0 0 10px #9ecaed;
    }
</style>