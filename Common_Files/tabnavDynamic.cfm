<!--- ---------------------------------------------------------------------------------------------------------------------------------
      Template: \common_files\tabnavDynamic.cfm
          Date:  2019 October
	   Purpose:  Styles for horizontal tab menu, optionally support adding dynamic tabs (ex to open an edit tab)
	   
	   Note: 	Key terms to use:
					   class "navi" for the navigation area, and create an id
					   For each tab, create an "a" link, and give a "name" that matches the content area "id"
					   Create a div with id "allTabContent" which wraps all the content divs
					Set the default tab and contents class = "active" to show them

	   Example with 2 static tabs:
	   		<div class="navi" id="navList">
				<a href="##" name="content1" class="active">Main Tab</a>
				<a href="##" name="content2">Secondary Tab</a>
				<!--- Additional tabs are added/removed dynamically by createDynamicTab and closeDynamicTab --->
			</div>


			<!--- Also include an area for all the tab content --->
			<!--- For each tab, the "name" attribute should match the "id" of the content area --->

			<div id="allTabContent">

				<div id="content1" class="active">			<!--- static --->
					<cfinclude template="programs.cfm">
				</div>

				<div id="content2">							<!--- static --->
					<cfinclude template="matches.cfm">
				</div>

				<!--- Dynamic tab content are divs appended to the "allTabContent" area --->
				<!--- Divs for the content of each dynamic page are created here in createDynamicTab  --->
				<!--- The visibility is controlled via setActiveArea  --->
				<!--- The id's that are created dynamically all start with "content-" --->
			</div>

    ---------------------------------------------------------------------------------------------------------------------------------
 --->
<style>
    <!--- Tab styles --->
	div.navi {
			border-bottom: 1px solid #d8d9dd;
			box-sizing: content-box;
			font-weight: bold;
			height: 19px;
			margin: 0 0 5px 0;
			padding: 0 0 0 5px;
			display: flex;
		}

	/* Inactive tabs */
	div.navi > a  {
		/* margin: 9px 3px 0 0; */
		margin: 0px 3px 0 0;
		background: #c4c5c7;
		border: 1px solid #C4C5C7;
		border-radius: 3px 3px 0 0;
		color: #343540;
		cursor: pointer;
		font-size: 12px;
		height: 18px;
		line-height: 18px;
		padding: 0 10px 0 10px;
		text-decoration: none;
		text-align: center;
	}
	/* The active tab */
	div.navi > a.active, 
	div.navi > a:active {
		background: #FFF;
		border-bottom: 1px solid #FFF;
		cursor: auto;
		height: 20px;
		line-height: 20px;
		margin-top: -2px;
	}
	div.navi > a:hover {
		background: #D8D9DD;
		color: #406be4;
	}
	div.navi > a.active:hover, 
	div.navi > a:active:hover {
		background: #fff;
	}
	a.dynamic {
		display: inline-block;
		white-space: nowrap;
		overflow: hidden;
	}
	i.closeDynamic {
		float: right;
		color: #7c7c7c;
		font-style: normal;
		font-size: 10px !important;
		padding-left: 5px;
	}
	/* Show/Hide the content areas via active class */
	#allTabContent > div {
		display: none;
	}
	#allTabContent > div.active {
		display: block;
		height: 100%;
	}
</style>


<script>
	<!--- ------ Tab management code ------ --->
	// Dynamic pages are shown on additional tabs
	// We support a max of 5 dynamic tabs at a time
	var DynamicTabList=[];            // GLOBAL for this page, tab list

	function DynamicTabCount() {
			return DynamicTabList.length;
		}

	// Set boolean if tab already open or not
	function isDynamicTabOpen(tabId) {
		return DynamicTabList.indexOf(tabId);
	}

	// Initialize tabs.  Binds tabs, including any dynamic ones added later, to the click event.  
	// Param: the "id" of the div containing the tabs, ex: "#navList"
	function initTabs(naviID) { 
		// Note: "on" also binds to dynamically added tabs
		$(naviID).on("click", 'a', function(e) {
			e.preventDefault();
			setActiveTab (e.target.id);		// turns the tab white
			// Make the chosen area visible
			setActiveArea(e.target.name);		// shows the tab contents
		})
	}

	// Controls which tab looks active
	function setActiveTab(tabId) {
		// first re-set existing 
		$(".navi .active").removeClass('active');
		// then set this one to active
		$('#'+tabId).addClass("active");
	}

	// There is a wrapper div for contents with the id: "allTabContent"
	// This function is used to show/hide the correct content, based on the contentID
	function setActiveArea(contentId) {
		// first re-set existing 
		$('#allTabContent .active').removeClass('active');

		// then display this one
		$('#'+contentId).addClass("active");
	}

	
	// Create a new Dynamic Tab
		// First check if already existing Or maxed out (5).  Otherwise,
		// 1 - Append Dynamic tab to the navList (and tracking array),
		// 2 - Append a new content Div to the tab content area
		// 3 - Optionally Use ajax to load the Dynamic page (pass Dynamic ID as parameter)
		// 4 - set the new tab&contents as the active one
		// Params:
		// naviID - string name of the "id" of the div containing the tabs, ex: "navList"
		// tabId - string unique name of element id for the tab, ex: "BB-10101233"
		// title - string title for tab
		// urlContentString = url to load dynamic tab content
		//
		// Return:
		// -1 - not open, max # tabs reached
		// 0 - opened existing
		// 1 - opened new
	function createDynamicTab(naviID, tabId, title, urlContentString) {
		naviID = naviID || "navList";
		tabId = tabId || "ID" + DynamicTabCount();
		title = title || "Details";

		let is_tab_opened = (isDynamicTabOpen(tabId) !== -1);
		if (is_tab_opened) {
			// Tab already exists, be kind and open it
			$('#'+ tabId).click();
			return 0;
		}

		if (DynamicTabCount() >= 5) {
			return -1;
		}
		else if (!is_tab_opened) {
			// Create the new tab
			let tabs = $('#'+ naviID);
			tabs.append( $("<a></a>", {
								"href": urlContentString
								, "id": tabId
								, "name": "content-"+tabId	// associate tab with content area
								, "text":  title.substring(0, Math.min(title.length, 25))
								, "title": title
								, "class": "dynamic"
							})
							// append letter x to allow closing tab
							.append( $("<i></i>", {
											"class": "closeDynamic"
											, "text":  "x"
											, "click": function(e) {
															e.stopPropagation();
															closeDynamicTab(tabId);
															// disable href event
															return false;
														}                        
										} )
							)
			);

			// Keep track of tabs in our array
			DynamicTabList.push (tabId);

			// Create the new content area and append to the tab content section
			let newArea = document.createElement("div");
			let areaId = "content-"+tabId;

			newArea.setAttribute("id", areaId);
			document.getElementById("allTabContent").appendChild(newArea);

			if (urlContentString) {
				// Load the contents into it
				$('#'+areaId).load(urlContentString);   // load dynamic tab contents via ajax
			}

			// Make the new tab the active one
			$('#'+tabId).click();
			return 1;
		}
	}



	// when user closes a Dynamic tab, we must clean up, get rid of dynamic elements
	function closeDynamicTab(tabId) {           
		tabId = tabId || "ID"+0;
		let areaId = "content-"+tabId;
		let tabs = $('#'+ tabId).parent(); 

		// remove it from the tab div
		$('#'+tabId).remove();

		// remove it from our list
		for (let i = 0; i < DynamicTabCount(); i++) {
			if (DynamicTabList[i] == tabId) {
				let removed = DynamicTabList.splice (i, 1);   // remove it from the list
				break;
			}
		}

		// remove the content area
		$('#'+areaId).remove();

		// Move on to another tab (first in list)
		$(tabs).find("a:eq(0)").click();
	}

</script>

