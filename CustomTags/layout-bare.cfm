<!---------------------------------------------------------------------------------------------------------------------
      Template: \CustomTags\layout-bare.cfm
      Date:     2016 March
      Author:   Chris Nguyen
      Purpose:  Bare website layout template with preloaded jQuery/jQueryUI(optional)

      Remarks:
---------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start"><!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<cfif structKeyExists(attributes, "page_title")>
	  <title><cfoutput>#attributes.page_title#</cfoutput></title>
	</cfif>
	<cfinclude template="/common_files/jQuery.cfm">
	<!--[if lt IE 9]>
	<script src="/script/javascript/html5shiv.min.js"></script>
	<![endif]-->
	<!--- load jQueryUI to take care of popup calendars ( datepicker() ) --->
	<cfif structKeyExists(attributes, "jQueryUI")>
	  <cfset jQueryUI.widgets = "full">
	<cfelseif structKeyExists(attributes, "jQueryUI_widgets")>
	  <cfset jQueryUI.widgets = attributes.jQueryUI_widgets>
	</cfif>
	<cfsavecontent variable="head_content">
		<cfinclude template="/common_files/jQueryUI.cfm">
	</cfsavecontent>
	<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
	<cfhtmlhead text="#application.util.string.compress( head_content )#">
</head>
<body>
<!---------------------------------------------------------------------------------------------------------------------><cfelse>
<!--- apply style to focused element --->
<cfinclude template="/common_files/focus.cfm">
</body>
</html>
</cfif>     <!--- if thisTag.executionMode is "start" --->
