<!------------------------------------------------------------------------------------------------------------------------------
	   File Name:  \planners\consumer_events\events\edit.cfm
	Created Date:  2017 October
	  Created By:  Kal
	 Description:  Add/edit a consumer event
------------------------------------------------------------------------------------------------------------------------------->
<cfset request.script_name = "/planners/consumer_events/events/">

<cfscript>
	param name="url.rowid"                  default="";
	param name="form.action"                default="";

	if (! structKeyExists(request, "planner_event_obj")) {
		request.planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	}
	if (! structKeyExists(request, "rowid")) {
		request.rowid = url.rowid;
	}
	param name="form.planner_event_type_id" default="";
	param name="form.event_title"           default="";
	param name="form.fiscal_year"           default="";
	param name="form.event_start"           default="";
	param name="form.event_end"             default="";
	param name="form.discount_info"         default="";
	param name="form.document_info"         default="";
	param name="form.copy_from_event_id"    default="";

	if (form.action eq "save") {
		request.rowid = request.planner_event_obj.updateEvent( form );
		//Locate to next page
		request.qEventsList = request.planner_event_obj.getEvents( request.rowid );
		include "/planners/consumer_events/events/planner_event_navigation.cfm";
		locateToNextPage(currentPageName = constants.page.name_basic, rowid = request.rowid);
	}

	request.qEventsList = request.planner_event_obj.getEvents( request.rowid );
	qEventTypes         = request.planner_event_obj.getEventTypes();
	qFiscalYear         = request.planner_event_obj.getFiscalYear( fiscalYear = "" );

	if ( len(request.rowid) ) {
		form.planner_event_type_id = request.qEventsList.planner_event_type_id;
		form.event_title           = request.qEventsList.event_title;
		form.fiscal_year           = request.qEventsList.fiscal_year;
		form.event_start           = dateformat(request.qEventsList.event_start, "m/d/yyyy");
		form.event_end             = dateformat(request.qEventsList.event_end, "m/d/yyyy");
		form.discount_info         = request.qEventsList.discount_info;
		form.document_info         = request.qEventsList.document_info;
	}

	if (structKeyExists(url, "copy") && url.copy) {
		form.copy_from_event_id   = request.rowid;
		request.rowid    = "";
		form.event_title = "";
		form.event_start = "";
		form.event_end   = "";
	}
</cfscript>

<cf_layout_planner_event>

<cf_include files="/styles/css-loader.css, /common_files/dhx_message.cfm, /common_files/datatable2.css, /common_files/dataTables2.cfm">

<cfset jQueryUI.widgets = "tooltip,datepicker">
<cfinclude template="/common_files/jQueryUI.cfm">


<style>
	fieldset.base { height: 300px; width: 50%; }
	form { margin-left: 20px; }
	div.row { height:20px; width:50%; margin-top:10px;}
	div.actions { margin-top: 10px; }
	div.actions a { margin-right: 25px; }
	label.lb { font-size:12px; width:100px; float:left;}
	input.date { width:66px; margin-right:1px;}
	input.base { width:150px;}
	select.base { width:150px;}
	input, select{ width:100%; box-sizing:border-box; }
</style>

<fieldset class="base">
	<cfoutput>
	<form name="edit_event" action="edit.cfm?rowid=#request.rowid#" method="post">
		<input type=hidden name=action>
		<input type=hidden name=rowid value="#request.rowid#">
		<input type=hidden name=copy_from_event_id value="#form.copy_from_event_id#">
		<div class="row">
			<label class="lb" for="planner_event_type_id">Event Type</label>
			<select name="planner_event_type_id" id="planner_event_type_id" class="base" <cfif request.rowid neq "">disabled</cfif>>
				<cfloop query="qEventTypes">
				<option
					value="#qEventTypes.planner_event_type_id#"
					data-discount="#qEventTypes.discount#"
					data-document="#qEventTypes.document#"
					<cfif form.planner_event_type_id eq qEventTypes.planner_event_type_id>selected</cfif> >#qEventTypes.title#
				</option>
				</cfloop>
			</select>
		</div>

		<div class="row">
			<label class="lb" for="event_title">Event Title</label>
			<input type="text" class="base" name="event_title" id="event_title" value="#form.event_title#">
		</div>

		<div class="row">
			<label class="lb" for="fiscal_year">Fiscal Year</label>
			<select name="fiscal_year" id="fiscal_year" class="base">
				<cfloop query="qFiscalYear">
				<option
					value="#qFiscalYear.fiscal_year#"
					data-mindate="#dateformat(qFiscalYear.start_date, "m/d/yyyy")#"
					data-maxdate="#dateformat(qFiscalYear.end_date, "m/d/yyyy")#"
					<cfif form.fiscal_year eq qFiscalYear.fiscal_year>selected=selected</cfif> >#qFiscalYear.fiscal_year#
				</option>
				</cfloop>
			</select>
			<img src="/images/i.gif" title="Changing fiscal year resets the event dates">
		</div>

		<div class="row">
			<label class="lb" for="event_dates">Event Dates</label>
			<input type="text" class="date" name="event_start" id="event_start" value="#form.event_start#">
			<label> to </label>
			<input type="text" class="date" name="event_end" id="event_end" value="#form.event_end#">
		</div>

		<div class="row">
			<label class="lb" for="discount_info">Discount</label>
			<input type="text" class="base" name="discount_info" id="discount_info" value="#form.discount_info#">
		</div>

		<input type="hidden" class="base" name="document_info" id="document_info" value="#form.document_info#">

		<div class="actions">
			<a id="save" class="primary">#application.util.string.linkFormat( "save" )#</a>
			<a id="cancel" class="secondary">#application.util.string.linkFormat( "return to events list" )#</a>
		</div>

	</form>
	</cfoutput>
</fieldset>

<script>
	$("a#cancel").click(function(){
		window.location = "list.cfm";
	});

	$("a#save").click(function(){
		var errors     = [],
			startDate  = Date.parse($("input[name=event_start]").val()),
			endDate    = Date.parse($("input[name=event_end]").val());

		if ( $("input[name=event_title]").val() == "" ) {
			errors.push( "Please enter an event title." );
		}
		if ( $("input[name=fiscal_year]").val() == "" ) {
			errors.push( "Please select a fiscal year." );
		}
		if ( $("input[name=event_start]").val() == "" ) {
			errors.push( "Please enter an event start date." );
		}
		if ( $("input[name=event_end]").val() == "" ) {
			errors.push( "Please enter an event end date." );
		}
		if ( startDate > endDate ) {
			errors.push( "Please fix: start date is after end date." );
		}
		if ( errors.length ) {
			dhx_alert( errors.join( "<br>" ) );
			return;
		}
		show_loader();
		$("input[name=action]").val( "save" );
		$("form[name=edit_event]").submit();
	});

	$("#planner_event_type_id").change(function() { updateFields(); });

	$("#fiscal_year").change(function() {
	  dhtmlx.message( "please enter event start and end dates" );
	  updateDates();
	  $("input[name=event_start]").val("");
	  $("input[name=event_end]").val("");
	});

	updateFields = function() {
		( $("select[name=planner_event_type_id]").find("option:selected").attr("data-discount") == 1
			? $("input[name=discount_info]").prop( "disabled", false ) : $("input[name=discount_info]").prop( "disabled", true ) );
		( $("select[name=planner_event_type_id]").find("option:selected").attr("data-document") == 1
			? $("input[name=document_info]").prop( "disabled", false ) : $("input[name=document_info]").prop( "disabled", true ) );
	}

	updateDates = function() {
		$("input.date" ).datepicker( { numberOfMonths: 1 });
		$("input.date" ).datepicker( "option", "minDate", new Date($("select[name=fiscal_year]").find("option:selected").attr("data-mindate") ) );
		$("input.date" ).datepicker( "option", "maxDate", new Date($("select[name=fiscal_year]").find("option:selected").attr("data-maxdate") ) );
	}

	 updateFields();
	 updateDates();
	$("form[name=edit_event] input[type=text]").first().focus();
</script>


</cf_layout_planner_event>
