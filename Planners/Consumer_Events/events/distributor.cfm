<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \Planners\Consumer_Events\events\distributor.cfm
	Created Date:  2017 November
	  Created By:  Kal
	 Description:  Add/edit a consumer event
------------------------------------------------------------------------------------------------------------------------------->


<cfscript>
	param name="url.rowid"                  default="";
	param name="form.action"                default="";
	param name="form.groupLevelId"          default="";
	
	if (! structKeyExists(request, "planner_event_obj")) {
		request.planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	}
	if (! structKeyExists(request, "rowid")) {
		request.rowid = url.rowid;
	}

	if (form.action eq "save") {
		request.planner_event_obj.saveEventDistributors(request.rowid, form);
	
		request.qEventsList = request.planner_event_obj.getEvents( request.rowid );
		include "/planners/consumer_events/events/planner_event_navigation.cfm";
		locateToNextPage(currentPageName = constants.page.name_distributor, rowid = request.rowid);
	}

	if (! structKeyExists(form, "SelectedDistributors")) {
		// Get the saved values from DB
		
		// Get saved individual distributors and set form variable
		qPlannerEventDistributors = request.planner_event_obj.getPlannerEventDistributorList(request.rowid, 0);
		form.SelectedDistributors = ValueList(qPlannerEventDistributors.Distributor_GUID);

		// Get saved group distributors and set form variable	
		qPlannerEventDistributors = request.planner_event_obj.getPlannerEventDistributorList(request.rowid, 1);
		form.SelectedGroupDistributors = ValueList(qPlannerEventDistributors.Distributor_GUID);	
		form.groupLevelId = qPlannerEventDistributors.Distributor_Group_Level_ID;
	
	}
	
	// Get display details for the selected distributors
	qEventDistributors = request.planner_event_obj.getDistributorsFromList( ListAppend(form.SelectedDistributors, form.SelectedGroupDistributors) );
	labels_obj = createObject("component", "components.settings.Labels.Labels").init();
	qPlannerLabels = labels_obj.plannerLabels();
	
	// Distributor group levels
	DistGroupDataManager			= CreateObject("component", "components.customer.Group.DataManager").init();
	qGetCustomerGroupLevels			= DistGroupDataManager.getDistributorLevelsAll(bActive = 1, disAllowList="23,24,25,26");
</cfscript>



<cf_layout_planner_event>

<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm, /common_files/dhx_message.cfm">

<cfset jQueryUI.widgets = "tooltip,datepicker">
<cfinclude template="/common_files/jQueryUI.cfm">


<style>
	body { min-width: 0; }
	fieldset.base { min-height: 650px; height: 65vh; }
	div.actions a { margin-right: 20px; }
	div.actions { display:inline-block; margin: 0px 25px 10px 25px ; position:relative; top:-2px; }
	label.lb { font-size:12px; width:100px; float:left;}
	div.dataTables_filter input { width: 200px; }
	.cut { background-color:#E5E5E5 !important; text-decoration: line-through; }
	.undo {display: none; width: 50px}
	.del {width: 50px}
</style>


<cfoutput>
	<cfsavecontent variable="action_links">
		<select id=chooseGroupLevelId><option value=0>choose #lcase(qPlannerLabels.distributor_singular)# group level</option>
			<cfloop query="qGetCustomerGroupLevels"><option value=#Distributor_Group_Level_ID# <cfif form.groupLevelId eq Distributor_Group_Level_ID>selected</cfif>>#Group_Level_Desc#</option></cfloop>
		</select>
		<a class=primary  id=dist_group>#application.util.string.linkFormat( "select " &  lcase(qPlannerLabels.distributor_singular) & " group" )#</a>
		<a class=primary id=dist>#application.util.string.linkFormat( "select " &  lcase(qPlannerLabels.distributor_plural) )#</a>
		<a class=primary id=save>#application.util.string.linkFormat( "save" )#</a>
		<a class=secondary id=cancel>#application.util.string.linkFormat( "return to event list" )#</a>
	</cfsavecontent>
</cfoutput>


<cfoutput>
	<form name="event_distributor" method="post">
		<input type=hidden name=action>
		<input type=hidden name=groupLevelId value="#form.groupLevelId#">
		<input type=hidden name=SelectedGroupDistributors value="#form.SelectedGroupDistributors#">
		<input type=hidden name=SelectedDistributors value="#form.SelectedDistributors#">		

		<fieldset class="base">
			<table class="dataTable row-border order-column hover" id="grid">
				<thead>
					<th class="dt-head-left"></th> <!--- scissors --->
					<th class="dt-head-left"></th> <!--- undo --->
					<th class="dt-head-left">ID</th>
					<th class="dt-head-left">Description</th>
					<th class="dt-head-left">Type</th>
					<th class="dt-head-left">Level</th>
				</thead>
				<tbody></tbody>
			</table>
		</fieldset>
	</form>
	
	<form name="event_distributor_group_search" method="post" target="Select_Groups">
		<input type=hidden name=FinalDistList>
	</form>
</cfoutput>
<cfset data_set = []>
<cfoutput query="qEventDistributors">
	<cfset arrayAppend(data_set, [	qEventDistributors.Distributor_GUID
									,qEventDistributors.Distributor_GUID
									,qEventDistributors.Distributor
									,qEventDistributors.Distributor_Name
									,qEventDistributors.Record_Type
									,qEventDistributors.Distributor_Group_Level_ID
									])>
</cfoutput>

<cfoutput>
	<cfsavecontent variable="no_data">No data.</cfsavecontent>
</cfoutput>

<script>
	// console.clear();
	cut_format = function(row) {
		return  "<img src='/images/scissor.gif' name='scissor' id='" + row[0] + "'  class='hand' value='" + row[0] + "'>";
	}
	
	undo_format = function(row) {
		return  "<img src='/images/undo.gif' name='undo' id='" + row[0] + "'  class='hand' value='" + row[0] + "'>";
	}

	var table = $("table.dataTable").DataTable({
		data   : <cfoutput>#serializeJSON( data_set )#</cfoutput>,
		dom    : 'f<"actions">ti',
		columns: [
					{ visible:true, className: "hand del", orderable: false, render: function(data, type, row){return cut_format(row); } },
					{ visible:true, className: "hand undo", orderable: false, render: function(data, type, row){return undo_format(row); } },
					{},
					{},
					{},
					{visible:false}
				],
		language: { emptyTable: <cfoutput>"#no_data#"</cfoutput> },
		order  : [ [2, 'asc'] ],
		scrollY: "60vh",
		paging : false
	});
	$("div.actions").html( <cfoutput>"#application.util.string.compress(action_links)#"</cfoutput> );

	// distributor group search
	$("a#dist_group").click(function(){ selectDistributorGroups(); });

	// distributor search
	$("a#dist").click(function(){ selectDistributors(); });

	$("a#cancel").click(function(){ window.location = "list.cfm"; });

	$("a#save").click(function(){
		$("input[name=action]").val( "save" );
		$("form[name=event_distributor]").submit();
	});


	selectDistributorGroups  = function()
	{
		var lsValsToDel = "";
		var sURL = "";
		
		var GroupLevelID = $("#chooseGroupLevelId option:selected" ).val();
		if(GroupLevelID == "0") {
			/*
			alert("Please select a distributor group type");
			$("#chooseGroupLevelId" ).focus();
			*/
			
			dhtmlx.alert({
				title: "Error",
				type: "alert-error",
				<cfoutput>
				text: "Choose a #lcase(qPlannerLabels.distributor_singular)# group level",
				</cfoutput>
				width: "500px",
				callback:function(response){
					if(response){
						$("#chooseGroupLevelId" ).focus();
					} // if(response)
				} // callback function
			}); // dhtmlx.confirm
			
			return;
		}
		
		sURL = "/Planners/Templates/DistributorGroup_Search.cfm?FormName=event_distributor&FieldName=SelectedGroupDistributors&GroupLevelFieldName=groupLevelId&groupLevelId=" + GroupLevelID + "&submitParentForm=1" ;
		
		// Submit the form so we can pass already selected distributor groups to teh pop-up
		var frmDistSearch = document.event_distributor_group_search;
		var SelectedGroupDistributors = $('input[name=SelectedGroupDistributors]').val();
		frmDistSearch.action = sURL;
		$('input[name=FinalDistList]').val(SelectedGroupDistributors);
					
		NewWindow("about:blank", 'Select_Groups', 1000, 800, 'yes', 'yes');
		
		frmDistSearch.submit();
	}

	selectDistributors  = function()
	{
		var lsValsToDel = "";
		var sURL = "";
		sURL = "/billbacks/search_screens/PM_select_distributors.cfm?FormName=event_distributor&FieldName=SelectedDistributors&SelectSingleSearchResultOnly=0";
		NewWindow(sURL, 'Select Groups', 1000, 800, 'yes', 'yes');
	}
	
	$('#grid tbody').on('click', 'td.del', function () {
		var selected_row = $( this ).parents( "tr" );
		var data = table.row(selected_row).data();
		var recordId = data[0];
		var recordLevelId = data[5];
		var listObj;
		
		// Remove recordId from the list
		if(recordLevelId == "0"){
			listObj = $('input[name=SelectedDistributors]');
		}
		else {
			listObj = $('input[name=SelectedGroupDistributors]');
		}
		var recordList = listObj.val();
		var recordList = removeFromList(recordList, recordId);
		listObj.val(recordList); // set the new value back into the input
		
		// Change the table style
		selected_row.addClass('cut');
		selected_row.find('td:nth-child(1)').hide(); // hide scissor column #1
		selected_row.find('td:nth-child(2)').show(); // show undo column #2
		
		
    } );
	
	
	$('#grid tbody').on('click', 'td.undo', function () {
		var selected_row = $( this ).parents( "tr" );
		var data = table.row(selected_row).data();
		var recordId = data[0];
		var recordLevelId = data[5];
		var listObj;
		
		// Remove recordId from the list
		if(recordLevelId == "0"){
			listObj = $('input[name=SelectedDistributors]');
		}
		else {
			listObj = $('input[name=SelectedGroupDistributors]');
		}
		var recordList = listObj.val();
		var recordList = addToList(recordList, recordId);
		listObj.val(recordList); // set the new value back into the input
		
		// Change the table style
		selected_row.removeClass('cut');
		selected_row.find('td:nth-child(1)').show(); // show scissor column #1
		selected_row.find('td:nth-child(2)').hide(); // hide undo column #2
		
		
    } );

	
	function removeFromList(sList, itemToRemove){
		var items = sList.split(',');
		var index = items.indexOf(itemToRemove);
		if(index!==-1) {
			items.splice(index, 1);			
		}
		return items.join(',');
	}
	
	function addToList(sList, itemToAdd){
		var items = sList.split(',');
		items.push(itemToAdd);	
		return items.join(',');
	}

</script>

</cf_layout_planner_event>