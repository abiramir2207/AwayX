<!----------------------------------------------------------------------------------------------------------------------------------
	  Template: \Planners\Create\topnav_form.cfm
		Author: Chris Nguyen
		  Date: 2016 Oct
	   Purpose: Create a topnav form with parameters to pass in opening a new planner page
----------------------------------------------------------------------------------------------------------------------------------->
<!--- the action attribute is assigned dynamically by JS code --->
<form name=topnav method=post>
<cfscript>
	// save existing form.action value & clear it out temporarily to avoid unintended action
	// topnav form creates new page, it does not carry any other action so action should be blank
	if ( structKeyExists(form, "action") ) {
		previous$form$action = form.action;
		form.action          = "";
	}
	topnav_elements  = [	"action",
							"filter_product_group_level_id",
							"filter_product_list",
							"forecasts",
							"mode",
							"page_creating",                   // new page creating indicator
							"period",
							"plannerID",
							"totals",
							"uom",
							"show_base_lift",
							"calendar_init_date",
							"include_slotting"
					   ];

	writeOutput(#application.util.struct.saveToHiddenInput( form, arrayToList(topnav_elements) )#);

	// restore form.action value
	if ( isDefined("previous$form$action") )
		form.action = previous$form$action;
</cfscript>
</form>
