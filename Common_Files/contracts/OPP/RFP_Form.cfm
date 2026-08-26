<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: \Common_files\contracts\RFP_Form.cfm
   Author: Mark Saunderss
   Date: 3/25/2020
 
   Usage: Main Entry for RFP deal (Request For Pricing).  Custom feature.
       
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->
</cfsilent>
<CF_CRYP type="de" string="#trim(URL.CID)#" key="#request.key#">

    <cfscript>
    variables.ContractMainID = cryp.value;
    Contract_Main_ID         = cryp.value;
    CSL_Contract_Main_ID     = Contract_Main_ID;

    userManager = CreateObject("component", "components.user.UserManager") ;
    appSettings = application.appsettingsGet ;

    programManager      = CreateObject("component", "components.programs.ProgramManager").init();
    templateManager     = CreateObject("component", "components.programs.template.TemplateManager").init() ;
    variables.labelComp = CreateObject("component", "components.settings.labels.labels").init() ;

	oRFP		= CreateObject("component", "mvc.Models.Program.RfpManager");
	GetSettings = programManager.getProgramTemplateInfo(Contract_Main_ID);
	RevisionVersion = oRFP.getRevisionVersion(Contract_Main_ID);
</cfscript>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<!------ get user positions id ----->
<cfset This_User_Positions_ID = userManager.getPositionId(request.AccessStructure.User_ID, 1) />

<CFPARAM NAME="Form.Document_ID" DEFAULT="ContractGeneralInfo">

<cfset labelnotes = appSettings.getLabelNotes()>

<!doctype html>
<html lang="en">
<head>
	<title>Program Editor</title>
	<cfsavecontent variable="head_content">
	<style>
		html, body {
			margin: 0;
            padding: 0;
            width: 99.5%;
            /* height: 95%; */
            overflow: hidden;
        }

        legend {
            font-size: 11px;
            font-weight: 600;
        }

        /* Section headers have blue dot, name, then horizontal line */
        .sectionHeader {
            overflow: hidden;
            font-weight: normal;
            margin-bottom: 5px;
        }
        .sectionHeader:before {
            /* blue dot */
            content: "";
            display: block;
            background: #222A97;
            width: 9px;
            height: 9px;
            border-radius: 50%;
            float: left;
            margin: 1px 6px 0 0;
        }
        .sectionHeader:after {
            /* h line */
            /* display: inline-block; */
            position: relative;
            vertical-align: middle;
            margin-left: 6px;
            height: 1px;
            content: "";
            text-shadow: none;
            background-color: #d8d9dd;
            margin-right: -100%;
            width: 100%; 
        }
        .sectionContents {
            margin-left: 10px;
        }

        .fieldGroup {
			background-color: #edeef2;
			border: 1px solid #c4c5c7;
			border-radius: 8px;
			margin-top: 3px;
		}
	.formGrayOut{
          background: #ccc;
       }
 
	</style>
    </cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</HEAD>

<body>
    <cfscript>
        verb                    = "CREATE";                // <!--- could be CREATE, EDIT, or VIEW --->
        request.noty_version    = "3";
        jQuery.version          = "1.12.4";
        jQueryUI.widgets        = "tooltip,datepicker";
        jQueryUI.widgets        = "all";
        jQueryUI.version        = "1.11";
        request.ag_grid_theme   = "ba-ag-theme-balham";
        request.ag_grid_version = "21";
        request.ag_expand_header_bars = true;
    </cfscript>

    <cf_include files="/common_files/tailwind-css.cfm, /common_files/noty.cfm">
        
    <cf_include files=#arrayToList( [ "/common_files/jQuery.cfm",
                                       "/common_Files/ag-Grid.cfm",
                                       "/styles/css-loader.css",
                                       "/styles/font-awesome.min.css",
                                       "/script/javascript/jQueryUI_1_11/datepicker.js",
                                       "/script/javascript/jQueryUI_1_11/jquery-ui.css",
                                       "/script/javascript/chosen/chosen.jquery.min.js", 
                                       "/styles/chosen/chosen.css"
                                    ] )#>
                                        
 <style>
        <!--- override the ag-grid styles included above --->
		.ag-theme-balham {
			font-size: 11px;
			borders-critical: ag-derived(borders);
		}
		.ag-header {
			font-size: 11px !important;
		}
		.ag-theme-balham .ag-cell {
			/* padding-left: 4px; */
			padding-right: 2px;
        }
        .ag-theme-balham .ag-header-cell-label {
			width: 100%;	/* work around ag-grid bug #2328 which leaves space for menu icon */
		}
        .ag-theme-balham .ag-header-cell {
            padding-left: 6px;  /* get checkbox to line up */
        }
  		.ag-theme-balham .ag-row-selected {
    		border-bottom-color: #b5b5b5; /* don't hide lines when selected */
		}
		.ag-theme-balham .ag-selection-checkbox span {
		    left: 2px; /* center the checkbox */
    	}
    	.number-cell {
	        text-align: right;
	    }
    </style>

<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "gi">

<cfset form.contract_main_id = temp>




<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT 	PCPO.Created_Type,
        ( SELECT Count( 1 )
            FROM CONTRACT_PRODUCTS p
                 INNER JOIN PRINT_PROGRAM_CUSTOM_OPTIONS ppco ON ppco.Contract_Main_Id = p.Contract_Main_Id
                                                                 AND p.Contract_Products_Id = ppco.Contract_Products_Id
                                                                 AND ppco.Deleted = 0
           WHERE p.Contract_Main_Id = cm.Contract_Main_Id
		   		<!---  Tim Ford - 10/23/2013 Label 39712 - Update Program Summary: Commented out Is_Group = 0 --->
                 --AND p.Is_Group = 0
                 AND p.Deleted = 0 ) AS custom_print,
		PCPO.BidRequestStatusOn,
		PCPO.BidRequestStatusChangePgmStatus,
		PCPO.Generic_Type,
		PCPO.revision_not_allowed,
		PCPO.copy_not_allowed,
		PCPO.pullbacks_on,
		PCPO.generic_type,
		PCPO.Release_Settlement,
		PCPO.Market_Price,
		PCPO.Shared,
		PCPO.Discount_Lump_Sums_Item_Mandated,
		PCPO.Display_Reminder_Comp_Data_Page,
		PCPO.Single_Component_Per_Discount_Type,
		PCPO.ItemMarked_Lost_Program_Volume_Automation,
		PCPO.Previous_Fiscal_Year_Volume,
		PCPO.EzButton_On,
		CM.*,
		CMAD.*,
		<!---  D38942 :: Program Blackout Period on Frontend --->
		PCPO.Blackout_Periods,
		PCPO.Auto_Volume,
		'WeeksAfter' = CASE
				WHEN PCPO.Blackout_Periods = 2
				THEN CMAD.Program_Start_Zero
				ELSE PCPO.Start_Zero
				END,
		'WeeksBefore' = CASE
				WHEN PCPO.Blackout_Periods = 1
				THEN CMAD.Program_Future_Zero
				ELSE PCPO.Future_Zero
				END,
		<!---  D38942 :: Program Blackout Period on Frontend --->
		TF.Description AS Template_Filter_Description
		,PCPO.Enable_Program_Qualifications <!---D43479--->
		,PCPO.Price_List_Download <!---D47306 --->
		,PCPO.specify_distributor_groups  		<!---D56899 --->
		,PCPO.specify_individual_distributors <!---D56899 --->
		,PCPO.Label_Set_Default <!--- D63927 --->
        ,cm.Contract_status_type_idx
	FROM 	Contract_Main CM
	LEFT JOIN Contract_Main_Aux_Data CMAD
	ON		CMAD.Contract_Main_ID = CM.Contract_Main_ID
	INNER JOIN	Program_Control_Panel_Options PCPO
	ON 		CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
	LEFT JOIN Template_Filters TF ON
		TF.Template_Filters_Id = CM.Template_Filters_Id
	WHERE 	CM.Contract_Main_ID = '#CSL_Contract_Main_ID#'
</CFQUERY>


    <!--------------------->
    <!------- HEADER ------>
    <!--------------------->

    <div class="min-h-screen md:flex" style="padding-bottom: 10px;">
        
        <!--------------------->
        <!--- MAIN CONTENTS --->
        <!--------------------->

        <div class="flex-1 bg-white mx-1 text-sm text-black">

            <!--- ngt - place approved program in an internal review mode - to allow viewing rfp form --->
            <cfset review_mode       = "review">
            <cfset request.page_mode = CSLGetContractInfo.Contract_status_type_idx gte 4 ? review_mode : "edit">

            <cfif CSLGetContractInfo.Contract_status_type_idx eq 2 and Get_profile_settings.RFP_Page_Edit_RFA eq 0>
                <cfset request.page_mode = review_mode>
            </cfif>

            <cfif request.page_mode is review_mode>
                <!--- disable clickable elements --->
                <style>
                    .review {
                        display: none;
                    }
                </style>
            </cfif>
                    
            <section name="section_CPA_Components" class="mr-1 mb-1">
            	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				 <CFINCLUDE template="/Common_Files/contracts/OPP/RFP_Components_Form.cfm" />
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
            </section>

         <section name="section_CPA_Products" class="mr-1">
        		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
				 <CFINCLUDE template="/Common_Files/contracts/OPP/RFP_Products_Form.cfm" />
				<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
         </section> 
        </div>
      </div>


    <!-------------------------------------------------------------------------------------->
    <!--------------------------------- SCRIPTS -------------------------------------------->
    <!-------------------------------------------------------------------------------------->
    <script>
    	// Currency formatter to use in cells
	const usdFormat = new Intl.NumberFormat('en-US', {
												style: 'currency',
												currency: 'USD',
												minimumFractionDigits: 2
											});
	// Grid Utilities, can be used by each section
	//
	// Use this to let ag-grid set the grid height dynamically
	// Don't use this if expecting lots of rows (>1000)
	function setAutoHeight(gridOptions, gridID) {
		gridOptions.api.setDomLayout('autoHeight');
		// auto height will get the grid to fill the height of the contents,
		// so the grid div should have no height set, the height is dynamic.
		document.querySelector(gridID).style.height = '';
	}

	// Use this when you want a specific grid height, or when there is no data, use with height ~ '70px' to center the "No Rows" text
	function setFixedHeight(gridOptions, gridID, height) {
		height = height || '100px';
		gridOptions.api.setDomLayout('normal');
		// when auto height is off, the grid has a fixed height, and then the grid
		// will provide scrollbars if the data does not fit into it.
		document.querySelector(gridID).style.height = height;
	}

	function setGridHeight(gridOptions, gridID, rows) {
		if (rows > 0) {
			setAutoHeight(gridOptions, gridID);
			setFixedHeight(gridOptions, gridID, "80%");
		} else {
			setFixedHeight(gridOptions, gridID, "70px");
		}
	}


	// Init Noty msgs
	Noty.overrideDefaults({
		closeWith: ["click", "button"],
		layout: "center",
		killer: true,
		theme: "metroui",
		timeout: false,
		type: "error"
	});
	function openPopup(url, winW, winH, winN)
		{
			var windowWidth = 640;
			var windowHeight = 480;
			var windowName = 'popupWindow';

			if(winW)
			{
				windowWidth = winW;
			}
			if(winH)
			{
				windowHeight = winH;
			}
			if(winN)
			{
				windowName = winN;
			}
			var w = 640/3;
			var h = 480/3;
			var cw = w/2;
			var ch = h/2;

			if (window.screen)
			{
				w = Math.floor(screen.availWidth/3);
	    		h = Math.floor(screen.availHeight/3);
	    		cw = Math.floor((screen.availWidth-windowWidth)/2);
	    		ch = Math.floor((screen.availHeight-windowHeight)/2);
			}

	    	myPopup = window.open(url,windowName,'resizable=yes,scrollbars=yes,,width='+windowWidth+',height='+windowHeight+',top='+ch+',left='+cw);
	    	if (!myPopup.opener)
	        	myPopup.opener = self;
		}

    </script>

    <cfinclude template="/Common_Files/focus.cfm">
</body>
<html>
