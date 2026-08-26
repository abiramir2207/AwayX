<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \planners\consumer_events\types\list.cfm
	Created Date:  2017 October
	  Created By:  Chris Nguyen
	 Description:  Display a list of consumer events types
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cf_layout_planner_event>

<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm">
<cfset jQueryUI.widgets = "tooltip">
<cfinclude template="/common_files/jQueryUI.cfm">

<style>
	body { min-width: 0; }
	fieldset.base { height: 600px; height: 85vh; }
	div.action { margin: 0.25% 0 1% 0; }
	div.actions { position: relative; top: -2px; }
	a.edit { margin-right: 20px; }
	.clicked { background-color:#E5E5E5 !important; }
	div.dataTables_filter input { width: 200px; }
</style>

<cfscript>
	param name="form.action" default="";
	oProfiles = CreateObject("component","components.settings.profiles.profile");
	getProfileSettings = oProfiles.getAllProfiles(request.AccessStructure.Profiles_ID);
	planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	if (form.action eq "delete") {
		planner_event_obj.deleteEventType( form.rowid );
	}

	qEventTypes  = planner_event_obj.getEventTypes();
</cfscript>

<form name="event_types" method="post">
	<input type=hidden name=action>
	<input type=hidden name=rowid>
	<fieldset class="base">
		<cfif getProfileSettings.Marketing_Events_Create eq 2 >
		<div class="action">
			<cfoutput><a class="create">#application.util.string.linkFormat("create new event type")#</a></cfoutput>
		</div>
		</cfif>
		<cfoutput>
		<table class="dataTable row-border order-column hover">
			<thead>
				<th class="dt-head-left">Event Type</th>
				<th>#request.planner_labels.distributor_plural#</th>
				<th>Positions</th>
				<th>Products</th>
				<th>Discounts</th>
				<th>Documents</th>
				<th>Color</th>
				<th>Action</th>
			</thead>
			<tbody></tbody>
		</table>
		</cfoutput>
	</fieldset>
</form>

<cfset data_set = []>
<cfoutput query="qEventTypes">
	<cfset arrayAppend(data_set, [	qEventTypes.Title
									,(qEventTypes.Customer ? "yes" : "no")
									,(qEventTypes.Position ? "yes" : "no")
									,(qEventTypes.Product  ? "yes" : "no")
									,(qEventTypes.Discount ? "yes" : "no")
									,(qEventTypes.Document ? "yes" : "no")
									,(qEventTypes.Color)
									,qEventTypes.Planner_Event_Type_ID
									])>
</cfoutput>

<cfsavecontent variable="color_styles">
<style>
	<cfset defined_colors = []>
	<cfoutput query="qEventTypes">
		<cfif qEventTypes.color neq "">
			<cfset perf_color = replace( qEventTypes.color, "##", "", "all" )>
			<!--- create color style if it does not exist --->
			<cfif not arrayFindNoCase(defined_colors, perf_color)>
				<cfset arrayAppend(defined_colors, perf_color)>
				.color_#perf_color# {
					color: #application.util.string.foregroundColor( perf_color )#;
					background-color: ###perf_color#;
				}
			</cfif>
		</cfif>
	</cfoutput>
</style>
</cfsavecontent>
<cfoutput>#application.util.string.compress( color_styles )#

<cfsavecontent variable="no_data">No event type yet. &nbsp; <cfif getProfileSettings.Marketing_Events_Create eq 2 > Click &nbsp; <a class=create>#application.util.string.linkFormat("create new event type")#</a> &nbsp; to add the first event type.</cfif></cfsavecontent>
</cfoutput>

<script>
	function checkbox( checked ) {
		return "<input type=checkbox disabled " + (checked ? "checked" : "") + ">";
	}

	$("table.dataTable").DataTable({
		data   : <cfoutput>#serializeJSON( data_set )#</cfoutput>,
		dom    : "ti",
		columns: [ 	{},
					{ orderable:false, className:"dt-body-center", render:function( cell ){ return checkbox( cell ) } },
					{ orderable:false, className:"dt-body-center", render:function( cell ){ return checkbox( cell ) } },
					{ orderable:false, className:"dt-body-center", render:function( cell ){ return checkbox( cell ) } },
					{ orderable:false, className:"dt-body-center", render:function( cell ){ return checkbox( cell ) } },
					{ orderable:false, className:"dt-body-center", render:function( cell ){ return checkbox( cell ) } },
					{ orderable:false, createdCell:function(td, cellData, rowData, row, col) {
						$(td).addClass("color_" + cellData.replace("#","")); }, render:function( cell ) { return cell; } },
					{ orderable:false, className:"dt-body-center actions", width:"20%", render:function( cell ) {
						return <cfoutput> "<div class=actions><a class=edit rowid=" + cell + ">#application.util.string.linkFormat('edit')#</a>"
								+ "<a class=delete rowid=" + cell + ">#application.util.string.linkFormat('delete')#</a></div>" </cfoutput>; } }
				],
		language: { emptyTable: <cfoutput>"#no_data#"</cfoutput> },
		order  : [ [0, 'asc'] ],
		scrollY: "60vh",
		paging : false
	});

	$("a.delete").click(function(){
		var rowid         = ( $( this ).attr("rowid") )
		    ,selected_row = $( this ).parents( "tr" );
		selected_row.addClass( "clicked" );

		dhtmlx.confirm({
		    type:"confirm",
		    text: "Are you sure you want to delete?",
		    ok: "DELETE",
		    callback: function( ok_to_delete ){
		        if ( !ok_to_delete ) {
					selected_row.removeClass( "clicked" );
		        }
		        else {
		        	$("input[name=rowid]").val( rowid );
		        	$("input[name=action]").val( "delete" );
		        	$("form[name=event_types]").submit();
		        };
		    }
		});
	});

	$("a.edit").click(function(){
		var rowid = ( $( this ).attr("rowid") );
		window.location = "/planners/consumer_events/types/edit.cfm?rowid=" + rowid;
	});

	$("a.create").click(function(){
		window.location = "/planners/consumer_events/types/edit.cfm";
	});
	<cfif getProfileSettings.Marketing_Events_Create neq 2 >
	$("div.actions").hide();
	</cfif>
</script>
</cf_layout_planner_event>
