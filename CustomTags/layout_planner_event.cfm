<!---------------------------------------------------------------------------------------------------------------------
	  Template: \customtags\layout_planner_event.cfm
	  Date:     2017 October
	  Author:   Chris Nguyen
	  Purpose:  Layout template for planner events
---------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start"><!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<cfsavecontent variable="head_content">
		<cf_include files=#arrayToList( [ "/styles/css-loader.css", "/common_files/jQuery.cfm", "/common_files/tabnav.css" ] )#>
		<style>
		  body { margin:0; padding:0; }
		  /* styles for horizontal menu options */
		  #hMenU {list-style:none;background:url(/Images/gradient.jpg) #a7caf2 no-repeat;color:#FFF;line-height:32px !important;margin:0;padding:0;}
		  #hMenU li {display:inline;padding:0 4.5px;}
		  #hMenU a:link,#hMenU a:visited,#hMenU a:hover,#hMenU a:active {font-weight:700;font-size:1.25em;color:#FFF;padding:0 8px 2px;margin-left:8px; text-decoration:none;}
		  #hMenU a:hover,#hMenU a.selected {background-color:#FFF;color:#000 !important;}
		  #toPtiTle table, #toPtiTle td {border-style:none;}
		</style>
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head><!--------------------------------------------------------------------------------------------------------------------->
<body>
<cfset oProfiles = CreateObject("component","components.settings.profiles.profile") />
<cfset getProfileSettings = oProfiles.getAllProfiles(request.AccessStructure.Profiles_ID)>
<cfsilent>
<cfparam name="url.rowid" default="">
<cfparam name="request.rowid" default="#url.rowid#">
<cfparam name="request.mode" default="edit">
<!------------------------------->
<!--- display horizontal menu --->
<!------------------------------->
<cfsavecontent variable="uncompressed">
<ul id="hMenU">
	<cfif getProfileSettings.Marketing_Events_Create>
	<li> <a href="/planners/consumer_events/events/list.cfm">events</a> </li> |
	<li> <a href="/planners/consumer_events/types/list.cfm">types</a> </li> |
	</cfif>
	<cfif getProfileSettings.Planner_Product_Calendar>
	<li> <a href="/planners/consumer_events/events/calendar.cfm">calendar</a> </li>
	</cfif>
</ul>
</cfsavecontent>
</cfsilent>
<cfscript>
	request.planner_event_obj = createObject("component", "mvc.models.planner.plannereventmanager");
	request.qEventsList = request.planner_event_obj.getEvents( request.rowid );
</cfscript>
<cfinclude template="/planners/consumer_events/events/planner_event_navigation.cfm">
<cfoutput>#application.util.string.compress( uncompressed )#</cfoutput>
<!--------------------------------------------------------------------------------------------------------------------->
<div id="layoutBody">
<cfscript>
	plannerEventPage = arrayFilter(pageList, function(n) {
		return FindNoCase(n.file, cgi.script_name);
	});
</cfscript>

<cfif ArrayLen(plannerEventPage)>
	<cfif request.rowid neq "">

		<cfsavecontent variable="uncompressed">
			<cfoutput>
			<h2 class="base" style="float:left;padding:0;margin:0 0 0 10px;">Edit Event - #request.qEventsList.event_title#</h2>
			<div class="updated" style="float:right;position:relative;top:6px;margin-right:10px;">
				Last updated on #application.util.datetime.DateTimeFormat(request.qEventsList.Updated_Date, "long")# by #request.qEventsList.Updated_By#
			</div>
			<div style="clear:both"></div>
			<div class="nav" style="margin-top:0px;">
				<ul class="nav">

					<cfloop array="#pageList#" index="thisPage">
						<cfif thisPage.enabled>
						<cfset nav_script = thisPage.file>
						<li <cfif cgi.script_name contains nav_script> class="active" </cfif>>
							<a class="topnav hand" data-script="#nav_script#">#thisPage.desc#</a>
						</li>
						</cfif>
					</cfloop>

				</ul>
			</div>
			<div style="clear:both"></div>
			</cfoutput>
		</cfsavecontent>
		<cfoutput>#application.util.string.compress( uncompressed )#</cfoutput>
	<cfelse>
		<header class="base"><h2 class="base">Create New Event</h2></header>
	</cfif>		<!--- <cfif form.rowid neq ""> --->
</cfif> <!--- ArrayLen(plannerEventPage) --->

<!---------------------------------------------------------------------------------------------------------------------> <cfelse>

<!--- main content from parent code is displayed here --->
</div>   <!---id="layoutBody"--->
<!--------------------------------------------------------------------------------------------------------------------->
 <!--- footer section --->
<div id="layoutFoot" style='margin-top:10px;'>
</div>
<cfset template_name = lCase( structKeyExists(request, "script_name") ? request.script_name : cgi.script_name )>

<script>
jQuery(function(){
	jQuery('#hMenU a').click( function() {
		show_loader();
	});
	<cfif request.rowid neq "">
	jQuery('.topnav').click( function() {
		show_loader();
		<cfoutput>
		window.location = jQuery( this ).data( "script" ) + "?rowid=" + #request.rowid#;
		</cfoutput>
	});
	</cfif>
	/* find selected option & then highlight it */
	jQuery('#hMenU li a[href]').each(function() {
		if ( jQuery(this).attr('href').toLowerCase() === <cfoutput>'#cgi.script_name#'.toLowerCase()</cfoutput>) {
			jMenuSelected = jQuery(this);
			jMenuSelected.addClass( 'selected' );
			return false;
		}
	});
});

</script>
<!--- injects style for focused element here instead of using Application.cfc which places the same code oustide of </html> tag --->
<cfinclude template="/common_files/focus.cfm">     <!--- 47143 --->
</body>
</html>
</cfif>     <!--- if thisTag.executionMode is "start" --->
