<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \planners\consumer_events\events\list.cfm
	Created Date:  2017 October
	  Created By:  Kal
	 Description:  Display a list of consumer events
------------------------------------------------------------------------------------------------------------------------------->
<cfscript>
	param name="url.rowid"   default="";
	param name="form.action" default="";
	if (! structKeyExists(request, "planner_event_obj")) {
		request.planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	}
	if (form.action eq "delete") {
		request.planner_event_obj.deleteEvent( form.rowid );
	}
	if (form.action eq "activate") {
		request.planner_event_obj.activateEvent( form.rowid );
	}
	if (form.action eq "deactivate") {
		request.planner_event_obj.deactivateEvent( form.rowid );
	}
	oProfiles = CreateObject("component","components.settings.profiles.profile");
	getProfileSettings = oProfiles.getAllProfiles(request.AccessStructure.Profiles_ID);
</cfscript>

<cf_layout_planner_event>

<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm">
<cfset jQueryUI.widgets = "tooltip">
<cfinclude template="/common_files/jQueryUI.cfm">

<style>
	body { min-width: 0; }
	fieldset.base { height: 600px; height: 85vh; }
	div.actions { position: relative; top: -2px; }
	div.actions a { margin-right: 20px; }
	.clicked { background-color:#E5E5E5 !important; }
	div.dataTables_filter input { width: 200px; }
	div.create { display:inline-block; margin-left:25px; position:relative; top:-2px; font-size:12px; }
	th.dt-head-left { padding-left: 16px !important; }
</style>

<form name="events_list" method="post">
	<input type=hidden name=action>
	<input type=hidden name=rowid>
	<fieldset class="base">
		<table class="dataTable row-border order-column hover">
			<thead>
				<th class="dt-head-left">Event</th>
				<th class="dt-head-left">Event Type</th>
				<th class="dt-head-left">Fiscal Year</th>
				<th class="dt-head-left">Start Date</th>
				<th class="dt-head-left">End Date</th>
				<th class="dt-head-left">Action</th>
			</thead>
			<tbody></tbody>
		</table>
	</fieldset>
</form>

<cfset data_set = []>
<cfoutput query="request.qEventsList">
	<cfset activateWarning = 1 />
	<cfif 		(position eq 0 OR Event_Has_Positions gt 0)
			AND (customer eq 0 OR Event_Has_Distributors gt 0)
			AND (product eq 0 OR Event_Has_Products gt 0)
			AND (document eq 0 OR Event_Has_Documents gt 0)
		>
		<cfset activateWarning = 0 />
	</cfif>
	<cfset arrayAppend(data_set, [	request.qEventsList.event_title
									,request.qEventsList.title
									,request.qEventsList.fiscal_year
									,( request.qEventsList.event_start eq "1/1/1900" ? "" : dateformat(request.qEventsList.event_start, "mmm d, yyyy") )
									,( request.qEventsList.event_end eq "1/1/1900" ? "" : dateformat(request.qEventsList.event_end, "mmm d, yyyy") )
									,request.qEventsList.planner_event_id
		   							,request.qEventsList.active
		   							,activateWarning
									])>
</cfoutput>

<cfoutput>
	<cfsavecontent variable="no_data">No events yet. &nbsp; <cfif getProfileSettings.Marketing_Events_Create eq 2> Click &nbsp; <a class=create>#application.util.string.linkFormat("create new event")#</a> &nbsp; to add the first event. </cfif> </cfsavecontent>
	<cfsavecontent variable="create_new"><a class=create>#application.util.string.linkFormat("create new event")#</a> </cfsavecontent>
</cfoutput>

<script>
	activate_format = function(cell, row) {
		<cfoutput>
		if(row[6] == 0){
			if(row[7] == 0)
				return  "<a class=activate rowid=" + cell + ">#application.util.string.linkFormat('activate')#</a>";
			else
				return  "<a class=activateWarning rowid=" + cell + ">#application.util.string.linkFormat('activate')#</a>";
		}
		else if(row[6] == 1)
			return  "<a class=deactivate rowid=" + cell + ">#application.util.string.linkFormat('deactivate')#</a>";
		</cfoutput>
	}

	$("table.dataTable").DataTable({
		data   : <cfoutput>#serializeJSON( data_set )#</cfoutput>,
		dom    : 'f<"create">ti',
		columns: [ 	{},
					{},
					{},
					{},
					{},
					{ orderable:false, className:"dt-body-left actions", width:"35%", render:function( cell, type, row ) {
						return <cfoutput> "<div class=actions><a class=edit rowid=" + cell + ">#application.util.string.linkFormat('edit')#</a>"
								+ "<a class=delete rowid=" + cell + ">#application.util.string.linkFormat('delete')#</a>"
								+ "<a class=copy rowid=" + cell + ">#application.util.string.linkFormat('copy')#</a>"
								+ activate_format(cell, row)
								+ "</div>";
						</cfoutput>
					} }
				],
		language: { emptyTable: <cfoutput>"#no_data#"</cfoutput> },
		order  : [ [2, 'desc'], [3, 'asc'] ],
		scrollY: "60vh",
		paging : false
	});

	// If create=2 then show create and edit links otherwise hide
	<cfif getProfileSettings.Marketing_Events_Create eq 2 >
	$("div.create").html( <cfoutput>"#create_new#"</cfoutput> );
	<cfelse>
	$("div.actions").hide();
	</cfif>

	$("a.delete").click(function(){
		var rowid        = ( $( this ).attr("rowid") );
		var selected_row = $( this ).parents( "tr" );
		selected_row.addClass( "clicked" );

		dhtmlx.confirm({
			title:"Delete Event",
		    type:"confirm-error",
		    text: "Are you sure you want to delete?",
		    ok: "DELETE",
		    callback: function( ok_to_delete ){
		        if ( !ok_to_delete ) {
					selected_row.removeClass( "clicked" );
		        }
		        else {
		        	$("input[name=rowid]").val( rowid );
		        	$("input[name=action]").val( "delete" );
		        	$("form[name=events_list]").submit();
		        };
		    }
		});
	});

	$("a.edit").click(function(){
		var rowid = ( $( this ).attr("rowid") );
		window.location = "/planners/consumer_events/events/edit.cfm?rowid=" + rowid;
	});

	$("a.copy").click(function(){
		var rowid = ( $( this ).attr("rowid") );
		window.location = "/planners/consumer_events/events/edit.cfm?copy=1&rowid=" + rowid;
	});

	$("a.activate").click(function(){
		var rowid        = ( $( this ).attr("rowid") );
		activate(rowid);
	});

	$("a.activateWarning").click(function(){
		var rowid        = ( $( this ).attr("rowid") );
		var selected_row = $( this ).parents( "tr" );
		selected_row.addClass( "clicked" );

		dhtmlx.confirm({
			title:"Activate Event",
		    type:"confirm-error",
		    text: "Event is incomplete. Are you sure you want to activate?",
		    ok: "ACTIVATE",
		    callback: function( ok_to_proceed ){
		        if ( !ok_to_proceed ) {
					selected_row.removeClass( "clicked" );
		        }
		        else {
		        	activate(rowid);
		        };
		    }
		});
	});


	function activate(rowid){
		$("input[name=rowid]").val( rowid );
		$("input[name=action]").val( "activate" );
		$("form[name=events_list]").submit();
	}

	$("a.deactivate").click(function(){
		var rowid        = ( $( this ).attr("rowid") );
		var selected_row = $( this ).parents( "tr" );
		selected_row.addClass( "clicked" );

		dhtmlx.confirm({
			title:"Deactivate Event",
		    type:"confirm-error",
		    text: "Are you sure you want to deactivate?",
		    ok: "DEACTIVATE",
		    callback: function( ok_to_proceed ){
		        if ( !ok_to_proceed ) {
					selected_row.removeClass( "clicked" );
		        }
		        else {
		        	$("input[name=rowid]").val( rowid );
		        	$("input[name=action]").val( "deactivate" );
		        	$("form[name=events_list]").submit();
		        };
		    }
		});
	});

	$("a.create").click(function(){
		window.location = "/planners/consumer_events/events/edit.cfm";
	});
</script>
</cf_layout_planner_event>
