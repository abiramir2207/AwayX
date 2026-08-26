<!--------------------------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \planners\consumer_events\types\edit.cfm
	Created Date:  2017 October
	  Created By:  Chris Nguyen
	 Description:  Add/edit a consumer events type
--------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfset request.script_name = "/planners/consumer_events/types/">

<cf_layout_planner_event>

<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm">

<cfscript>
	jQueryUI.widgets               = "tooltip";
	request.data_webforms2_support = "color";
</cfscript>

<cfinclude template="/common_files/jQueryUI.cfm">
<cfinclude template="/common_files/html5Forms.cfm">

<style>
	fieldset.base {
		height: 450px;
		width: 50%;
	}
	form {
		margin-left: 20px;
	}
	label.lb {
		display: block;
		font-size: 13px;
		font-weight: bold;
		margin-bottom: 5px;
		margin-top: 25px;
	}
	div.cb {
		height: 24px;
	}
	div.actions {
		margin-top: 25px;
	}
	div.actions a {
		margin-right: 25px;
	}
	input.base {
		height: 16px;
	}
</style>

<cfscript>
	param name="url.rowid"   default="";
	param name="form.action" default="";

	param name="form.event_title" default="";
	param name="form.positions"   default="1";
	param name="form.customers"   default="";
	param name="form.products"    default="1";
	param name="form.discounts"   default="";
	param name="form.documents"   default="";
	param name="form.color"       default="##9BC2E6";

	if (! structKeyExists(form, "rowid")) {
		form.rowid = url.rowid;
	}

	planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");

	if (form.action eq "save") {
		planner_event_obj.updateEventType( form );
		location( "list.cfm", "false" );
	}

	qEventTypes = planner_event_obj.getEventTypes( form.rowid );

	if ( qEventTypes.recordCount ) {
		form.event_title = qEventTypes.title;
		form.positions   = ( qEventTypes.position ? "1" : "0" );
		form.customers   = ( qEventTypes.customer ? "1" : "0" );
		form.products    = ( qEventTypes.product  ? "1" : "0" );
		form.discounts   = ( qEventTypes.discount ? "1" : "0" );
		form.documents   = ( qEventTypes.document ? "1" : "0" );
		form.color       = qEventTypes.color;
	}
</cfscript>

<fieldset class="base">
	<cfoutput>
	<header class="base">
		<h2 class="base"><cfif form.rowid eq "">Create New<cfelse>Edit</cfif> Event Type</h2>
		<cfif ( qEventTypes.recordCount )>
			<div class="updated">
				<cfif qEventTypes.Updated_by neq "">
					Last updated on #application.util.datetime.DateTimeFormat(qEventTypes.Updated_Date, "long")# by #qEventTypes.Updated_By#
				<cfelse>
					Created on #application.util.datetime.DateTimeFormat(qEventTypes.Created_Date, "long")# by #qEventTypes.Created_By#
				</cfif>
			</div>
		</cfif>
	</header>

	<form name="event_type" method="post">
		<input type=hidden name=action>
		<input type=hidden name=rowid value="#form.rowid#">
		<label class="lb">Event Type <span class="required">*</span></label>
		<div> <input type="text" class="base" name="event_title" size="70" required value="#form.event_title#"> </div>

		<label class="lb">Choose sections to include</label>
		<div class="cb">
			<input type="checkbox" <cfif form.positions eq "1">checked</cfif> name="positions" id="positions">
			<label class="cb" for="positions">Positions</label>
		</div>
		<div class="cb">
			<input type="checkbox" <cfif form.customers eq "1">checked</cfif> name="customers" id="customers">
			<label class="cb" for="customers">#request.planner_labels.distributor_plural#</label>
		</div>
		<div class="cb">
			<input type="checkbox" <cfif form.products eq "1">checked</cfif> name="products"  id="products">
			  <label class="cb" for="products">Products</label>
		</div>
		<div class="cb">
			<input type="checkbox" <cfif form.discounts eq "1">checked</cfif> name="discounts" id="discounts">
			<label class="cb" for="discounts">Discounts</label>
		</div>
		<div class="cb">
			<input type="checkbox" <cfif form.documents eq "1">checked</cfif> name="documents" id="documents">
			<label class="cb" for="documents">Documents</label>
		</div>

		<label class="lb">Color</label>
		<div> <input type="color" name="color" class="base" value="#form.color#"> </div>

		<div class="actions">
			<a id="save" class="primary">#application.util.string.linkFormat( "save" )#</a>
			<a id="cancel" class="secondary">#application.util.string.linkFormat( "cancel" )#</a>
		</div>
	</form>
	</cfoutput>
</fieldset>

<script>
	$("a#cancel").click(function(){
		window.location = "list.cfm";
	});

	$("a#save").click(function(){
		var errors = [];
		if ( $("input[name=event_title]").val() == "" ) {
			errors.push( "Please enter an event type." );
		}
		if ( $("input[name=color]").val() == "" ) {
			errors.push( "Please select a color." );
		}
		if ( errors.length ) {
			dhx_alert( errors.join( "<br>" ) );
			return;
		}
		show_loader();
		$("input[name=action]").val( "save" );
		$("form[name=event_type]").submit();
	});

	$("form[name=event_type] input[type=text]").first().focus();
</script>
</cf_layout_planner_event>
