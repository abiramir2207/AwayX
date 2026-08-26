<!---------------------------------------------------------------------------------------------------------------------
	  Template:  planners/consumer_events/events/planner_event_navigation.cfm
		  Date:  2017 November
		Author:  Deepa Kunnath
	   Purpose:  This page defines the default content on planner event page

----------------------------------------------------------------------------------------------------------------------->

<cfscript>
	constants.page.name_basic				= "basic";
	constants.page.name_geography			= "geography";
	constants.page.name_distributor			= "distributor";
	constants.page.name_product				= "product";
	constants.page.name_documents			= "documents";
	constants.page.name_summary				= "summary";
	
	labelManager                          = createObject( "component", "components.settings.Labels.Labels" ).init();
	request.planner_labels   = labelManager.plannerLabels();
	
	//pageList.desc can come from a labelling tool
	pageList = [	  
		      {name=constants.page.name_basic, desc=constants.page.name_basic, file="/planners/consumer_events/events/edit.cfm", enabled=1}
		   	, {name=constants.page.name_geography, desc=constants.page.name_geography, file="/planners/consumer_events/events/geography.cfm", enabled=val(request.qEventsList.position)}
		   	, {name=constants.page.name_distributor, desc=lcase(request.planner_labels.distributor_singular), file="/planners/consumer_events/events/distributor.cfm", enabled=val(request.qEventsList.customer)}
		   	, {name=constants.page.name_product, desc=constants.page.name_product, file="/planners/consumer_events/events/product.cfm", enabled=val(request.qEventsList.product)}
		   	, {name=constants.page.name_documents, desc=constants.page.name_documents, file="/planners/consumer_events/events/documents.cfm", enabled=val(request.qEventsList.document)}
		   	, {name=constants.page.name_summary, desc="summary", file="/planners/consumer_events/events/summary.cfm", enabled=1}
		   ];
</cfscript>	


<cffunction name="locateToNextPage" access="public" returntype="void" output="no" hint="Finds the next page and will change location to next page">
	<cfargument name="currentPageName" required="false" type="string" default="" />
	<cfargument name="currentPageFile" required="false" type="string" default="#cgi.script_name#" />
	<cfargument name="rowid" required="true" type="numeric" />

	<cfscript>
		local.locateToFile = getNextPage(arguments.currentPageName, arguments.currentPageFile).file;
		local.locateToFile = local.locateToFile & "?rowid=" & arguments.rowid;
		location(locateToFile);
	</cfscript>

</cffunction>


<cffunction name="getNextPage" access="public" returntype="struct" output="no" hint="Finds the next page">
	<cfargument name="currentPageName" required="false" type="string" default="" />
	<cfargument name="currentPageFile" required="false" type="string" default="#cgi.script_name#" />

	<cfscript>
		local.currentIndex = 0;
		local.currentPageIndex = 100;
		local.nextPageHasData = 1;
		local.nextPageIndex = ArrayLen(pageList); // default next page = summary
		if(request.rowid neq ""){
			for(item in pageList) {
				local.currentIndex++;
		
				//Loop till the current page is found
				if(item.name eq arguments.currentPageName or FindNoCase(item.file, arguments.currentPageFile)){
					local.currentPageIndex = local.currentIndex;
				}

				//once current page is found, find if the next page has data
				if(local.currentIndex > local.currentPageIndex && item.enabled){
					if(item.name eq constants.page.name_geography) {
						local.nextPageHasData = request.qEventsList.Event_Has_Positions;
					}
					else if(item.name eq constants.page.name_distributor) {
						local.nextPageHasData = request.qEventsList.Event_Has_Distributors;
					}
					else if(item.name eq constants.page.name_product) {
						local.nextPageHasData = request.qEventsList.Event_Has_Products;
					}
					else if(item.name eq constants.page.name_documents) {
						local.nextPageHasData = request.qEventsList.Event_Has_Documents;
					}

					// if next page does not have data, then return
					if(local.nextPageHasData eq 0) {
						local.nextPageIndex = local.currentIndex;
						break;
					}
				}
			}
		}
		
		return pageList[local.nextPageIndex];
	</cfscript>

</cffunction>






