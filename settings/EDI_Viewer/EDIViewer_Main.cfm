<!---
  * ====================================================================================================
  *  @Author: Sharon Harris
  *  @Date: 21-Mar-2019
  *  @Remarks: New EDI Viewer, replacing Flex version EDIViewerFx.cfm
  *
  *  This page loads the EDIViewer_Raw template to show the main content.
  *  If the user double-clicks a row in the grid, we dynamically create a new tab and also
  *  a new div in the dynamic content area, use Ajax to load the EDIViewer_Detail content, and 
  *  call setActiveArea to show/hide the correct content (main or detail).
  *
  * ====================================================================================================
--->
<!doctype html>
<html lang="en">
<head>
	<title>EDI Viewer</title>
	<cfsavecontent variable="head_content">
	<style>
		html, body {
			margin: 0;
			padding: 0;
			width: 99.5%
		} 
    <!--- Tab styles --->
	div.nav {
			border-bottom: 1px solid #d8d9dd;
			box-sizing: content-box;
			font-weight: bold;
			height: 30px;
			margin: 0 0 5px 0;
			padding: 0 0 0 5px;
			display: flex;
		}

	/* Inactive tabs */
	div.nav > a  {
		margin: 9px 3px 0 0;
		background: #c4c5c7;
		border: 1px solid #C4C5C7;
		border-radius: 3px 3px 0 0;
		color: #343540;
		cursor: pointer;
		font-size: 12px;
		height: 20px;
		line-height: 20px;
		padding: 0 10px 0 10px;
		text-decoration: none;
		text-align: center;
	}
	/* The active tab */
	div.nav > a.active, div.nav > a:active {
		background: #FFF;
		border-bottom: 1px solid #FFF;
		cursor: auto;
		height: 22px;
		line-height: 22px;
		margin-top: 7px;
	}
	div.nav > a:hover {
		background: #D8D9DD;
		color: #406be4;
	}
	div.nav > a.active:hover, div.nav > a:active:hover {
		background: #fff;
	}
	div.nav > a.hidden {
		display:none;
	}
	#rawTab {
		padding: 0 40px 0 40px;
    }
    div.edi_grid {
        box-sizing: border-box;
        width: 100%;
        height: 500px;
        margin: 4px 4px 0 4px;
    }
    a.edit {
        display: inline-block;
        width: 15%;
        font-size: 10px !important;
        white-space: nowrap;
        overflow: hidden;
    }
    i.closeEdit {
        float: right;
        color: green;
        font-style: normal;
        padding-left: 5px;
    }
	</style>
	<link rel="stylesheet" TYPE="text/css" HREF="/settings/EDI_Viewer/EDI_style.css">
	</cfsavecontent>
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>

<body>
	<cfset request.noty_version = "3">
	<cfset jQueryUI.widgets = "tooltip,datepicker">
	<cfset request.ag_grid_theme = "ba-ag-theme-balham">

	<cf_include files=#arrayToList( [ "  /common_files/jQuery.cfm",
										"/common_files/jQueryUI.cfm",
										"/common_Files/ag-Grid.cfm",
										"/styles/font-awesome.min.css",
										"/common_files/tailwind-css.cfm",
                                        "/common_files/noty.cfm"
										] )#>

	<!--- override the ag-grid styles included above --->
	<style>
		.ag-theme-balham {
			font-size: 11px;
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
	</style>


	<div class="page_title1"> EDI Viewer </div>

	<div class="mainwrapper">
		<!-------------------->
		<!--- Navigation  ---->
		<!-------------------->
		<div class="nav" id="navList">
			<a href="##" id="rawTab" class="active">Raw EDI</a>
			<!--- Detail tabs are added/removed dynamically by createDetailTab and closeDetailTab
			<a href="/settings/EDI_Viewer/EDIViewer_Detail.cfm?id=1">Detail 1 </a>
			<a href="/settings/EDI_Viewer/EDIViewer_Detail.cfm?id=2">Detail 2 </a>
			--->
		</div>

		<!--- What's happening here... --->
		<!--- We always have the main content area for the "Raw EDI" tab contents --->
		<!--- If the user opens details, then we create new tabs and new content areas for those detail tabs --->
		<!--- Then depending on which tab they click on, we show/hide the desired content --->


		<!-------------------->
		<!----- Raw EDI ------>
		<!-------------------->
		<div id="main-content">
			<!--- include the main content here by default --->
			<cfinclude template="/settings/EDI_Viewer/EDIViewer_Raw.cfm">
		</div>

		<!-------------------->
		<!--- Details tabs --->
		<!-------------------->
		<div id="dynamic-content">
			<!--- content will be loaded here via ajax call --->
			<!--- Divs for the content of each Detail page are created here dynamically in createDetailTab  --->
			<!--- The visibility is controlled via setActiveArea  --->
			<!--- The id's that are created dynamically all must start with "content-" --->
		</div>
	</div>

<!-------------------------------------------------------------------------------------->
<!--------------------------------- SCRIPTS -------------------------------------------->
<!-------------------------------------------------------------------------------------->
	<script>

		// Handle tab clicks
		// When a user clicks a tab, highlight that tab, hide current content and show new tab's content
		$(document).ready(function() {

			// Note: "on" also binds to dynamically added tabs
			$('#navList').on("click", 'a', function(e) {
			e.preventDefault();
			setActiveTab (e.target.id);		// turns the tab white
			
			// Make the chosen area visible
			setActiveArea(e.target.id);		// shows the tab contents
			})
		});


		<!--- ------ Tab management code ------ --->
		// EDI Details pages are shown on additional tabs
		// We support a max of 5 Details tabs at a time
		var DetailsTabList=[];            // GLOBAL for this page


		// Create a new Detail Tab
		// First check if maxed out (5) or already existing
		// 1 - Append details tab to the navList (and tracking array),
		// 2 - Append a new content Div to the dynamic area
		// 3 - Use ajax to load the Details page (passing detail ID as parameter)
		// 4 - set the new tab&contents as the active one
		function createDetailTab(id, urlString, title) {
			id = id || "ID"+detailTabCount();
			title = title || "Details";

            let is_tab_opened = (isDetailTabOpen(id) !== -1);
            if (is_tab_opened) {
                // Tab already exists, be kind and open it
                $('#'+id).click();
                return;
            }

            if (detailTabCount() >= 5) {
				new Noty({ text:"Unable to open EDI Details. Max number of open items ( 5 ) has been reached." }).show();
            }
            else if (!is_tab_opened) {
					// Create the new tab
                    let tabs = $("#navList");
                    let areaHref = "/settings/EDI_Viewer/EDIViewer_Detail.cfm?id="+id+'&'+urlString;
                    tabs.append( $("<a></a>", {
                                                  "id": id
                                                , "text":  title.substring(0, Math.min(title.length, 25)) + "..."
                                                , "title": title
                                                , "class": "edit"
                                                , "href": areaHref
                                            })
                                            // append letter x to allow closing tab
                                            .append( $("<i></i>", {
                                                                      "class": "closeEdit"
                                                                    , "text":  "X"
                                                                    , "click": function(e) {
                                                                                                e.stopPropagation();
                                                                                                closeDetailTab(id);
                                                                                                // disable href event
                                                                                                return false;
                                                                                            }                        
                                                                } )
                                                    )
                            );

					// Keep track of tabs in our array
					DetailsTabList.push (id);

					// Create the new content area inside the dynamic section
					let newArea = document.createElement("div");
					let areaId = "content-"+id;
					newArea.setAttribute("id", areaId);
					// newArea.style.display ="none";  // initially hidden till ready
					document.getElementById("dynamic-content").appendChild(newArea);

					// Load the contents into it
					$('#'+areaId).load(areaHref);   // load dynamic tab contents via ajax

					// Make the new tab the active one
					$('#'+id).click();
				}
		}

		function detailTabCount() {
			return DetailsTabList.length;
		}

		// Set boolean if tab already open or not
		function isDetailTabOpen(id) {
			return DetailsTabList.indexOf(id);
		}

		// Controls which tab looks active
		function setActiveTab(id) {
			// first re-set existing 
			$("#navList .active").removeClass('active');

			// then set this one to active
			$('#'+id).addClass("active");
		}

		// when user closes a Detail tab, we must clean up, get rid of dynamic elements and grid
		function closeDetailTab(id) {           
			id = id || "ID"+0;
			let areaId = "content-"+id;

			// remove it from the tab div
			$('#'+id).remove();

			// remove it from our list
			for (let i = 0; i < detailTabCount(); i++) {
				if (DetailsTabList[i] == id) {
					let removed = DetailsTabList.splice (i, 1);   // remove it from the list
					break;
				}
			}

			// remove the content area
			$('#'+areaId).remove();

			// Destroy grid
			// SAH TODO

			// Move on to another tab
			$('#rawTab').click();
		}

		// There are two wrapper divs for contents: main and dynamic
		// Within dynamic there are content divs per each open Detail tab
		// This function is used to show/hide the correct content, based on the tabID
		function setActiveArea(tabID) {
			let contentId = "main-content";

			// If details tab, hide the main tab and setup the content id
			if (tabID != "rawTab") {
				contentId = "content-"+tabID;
				$('#main-content').hide();
			}

			// Get all elements in the dynamic content area and hide them
			$('#dynamic-content').children().hide();

			// show the one area requested
            $('#'+contentId).show();           
            resize_ag_grid();
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

        function resize_ag_grid() {
            set_grid_full_height("#" + $("div.ag-theme-balham:visible").attr("id"));
        }

        // adjust the active ag-grid height to fit when window is resized
        $(window).resize( resize_ag_grid );
	</script>

	<cfinclude template="/Common_Files/focus.cfm">

</body>
</html>