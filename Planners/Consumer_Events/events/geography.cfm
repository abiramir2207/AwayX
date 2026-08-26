<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \Planners\Consumer_Events\events\geography.cfm
	Created Date:  2017 November
	  Created By:  Deepa
	 Description:  Add/remove consumer event geography

Remarks      	:
list (default) 	- Main page which lists selected position and displays select link
positionSearch 	- Display position search
positionSelect 	- Display position search results
save 			- Save data
------------------------------------------------------------------------------------------------------------------------------->


<cfscript>
	param name="url.rowid"					default="";
	param name="form.action"				default="";	
	param name="form.parent_action"			default="consumerEventPosition";
	param name="form.position_select_type"	default="checkbox";	

	if (! structKeyExists(request, "planner_event_obj")) {
		request.planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	}
	if (! structKeyExists(form, "rowid")) {
		form.rowid = url.rowid;
	}
	if (! structKeyExists(request, "rowid")) {
		request.rowid = form.rowid;
	}
	
	if (form.action eq "save") {
		request.planner_event_obj.savePlannerEventPositions(plannerEventId=form.rowid, positionList=form.chosen_position_id);
		form.action = "";
		//Locate to next page
		request.qEventsList = request.planner_event_obj.getEvents( form.rowid );
		include "/planners/consumer_events/events/planner_event_navigation.cfm";
		locateToNextPage(currentPageName = constants.page.name_geography, rowid = form.rowid);
	}

	if (! structKeyExists(form, "chosen_position_id")) {
		// Get the saved position list from DB
		qPlannerEventPositions = request.planner_event_obj.getPlannerEventPositions(form.rowid);
		form.chosen_position_id = ValueList(qPlannerEventPositions.User_positions_ID);
	}

</cfscript>


<cf_layout_planner_event>
	
<cfif form.action eq "positionSearch">
	<fieldset  class="base">
	<cfinclude template="/planners/include/search_positions.cfm">
	</fieldset>
<cfelseif form.action eq "positionSelect">
	<fieldset class="base">
	<cfinclude template="/planners/include/select_position.cfm">
	</fieldset>
<cfelse>
	<cfinclude template="geography_list.cfm">
</cfif>

</cf_layout_planner_event>
	
<cffunction name="saveHiddenValues" output="true" hint="Save input elements needed on all pages">
	<!---  store persisted + hidden elements in all pages in this array --->
	<cfset local.hidden_inputs = [	"rowid",
		   							"action",
		   							"parent_action",
		   							"chosen_position_id"
								]>
	<cfloop array="#local.hidden_inputs#" index="local.hidden_entry">
		<cfif local.hidden_entry eq "action">
			<cfset currentAction = form[ local.hidden_entry ] />
			<cfif currentAction eq "positionSearch">
				<cfset currentAction = "positionSelect" />
			<cfelseif currentAction eq "positionSelect">
				<cfset currentAction = "choose" />
			</cfif>
			<!---  update action  --->
			<input type="hidden" name="#local.hidden_entry#" value="#currentAction#">
		<cfelse>
			<cfparam name="form.#local.hidden_entry#" default="">  
			<input type="hidden" name="#local.hidden_entry#" value="#form[ local.hidden_entry ]#">
		</cfif>
	</cfloop>
</cffunction>