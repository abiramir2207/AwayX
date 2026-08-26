<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\jQueryUI.cfm
      Date:     2016 October
      Author:   Chris Nguyen
      Purpose:  Include jQuery UI .js file and .css file

	  Notes:    jQuery UI 1.12 does NOT work with jQuery 1.7.2 - do NOT use 1.12 version
				CDN includes ALL widgets therefore it is very large - do NOT use CDN
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="jQueryUI.folder"  default="jQueryUI_1_11">
<cfparam name="jQueryUI.widgets" default="all">
</cfsilent>
<cfoutput>
<!--- load all Forge's widgets (accordion, datepicker, tabs, tooltip) --->
<cfif jQueryUI.widgets eq "all">
	<cf_include files="/script/javascript/#jQueryUI.folder#/jquery-ui.js, /script/javascript/#jQueryUI.folder#/jquery-ui.css">
<!--- gridviewscroll plugin needs a complete full library with all widgets, all interactions, all effects --->
<cfelseif jQueryUI.widgets eq "full">
	<cf_include files="/script/javascript/#jQueryUI.folder#/jquery-ui.full.js, /script/javascript/#jQueryUI.folder#/jquery-ui.full.css">
<!--- load individual widgets selectively --->
<cfelseif jQueryUI.widgets neq "">
	<!--- append tooltip widget --->
	<cfif not jQueryUI.widgets contains "tooltip">
		<cfset jQueryUI.widgets = listAppend(jQueryUI.widgets, "tooltip")>
	</cfif>
	<!--- <cfdump var="#jqueryUI#"> --->
	<cfloop list="#jQueryUI.widgets#" index="single_widget">
		<script src="/script/javascript/#jQueryUI.folder#/#trim(single_widget)#.js"></script>
	</cfloop>
	<cf_include files="/script/javascript/#jQueryUI.folder#/jquery-ui.css">
</cfif>
<!--- reset to prevent loading the same .js more than once --->
<cfset jQueryUI.widgets = "">
</cfoutput>