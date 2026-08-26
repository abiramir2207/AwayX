<cfsetting showDebugOutput="No">
<!DOCTYPE HTML>
<html>
<head>
<title>Settings Control Panel</title>
<style>
	body { margin:0; padding:0; }
	div#root {
	    position: fixed;
	    width: 100%;
	    height: 100%;
	}
	iframe {
	    border: none;
	    float: left;
	    height: 100%;
	    margin: 0;
	}
	    /* total width is 99.5% + 0.4% (for paddings) = 99.9% :: cannot use 100% because it would move the 2nd iframe below the 1st iframe */
		iframe.left  { width: 9%;    padding: 0.15%;}
		iframe.right { width: 90.5%; padding: 0.05%; }
</style>
</head>
<body>
<div id="root">
	<!--- Get the profile for this user --->
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfinclude template="/get_access_profile.cfm">
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
	<cfset IsSPAccessAllowed = SPA.getCheckSPAccessAllowed()>

	<cfif IsSPAccessAllowed EQ 0>
		<cflocation url="/Manufacturers/home.cfm" addtoken="yes">
	</cfif>

	<cfset GROUP = "Control_Panel">
	<cfset mainwindowsrc = "settings_frame_mainwindow.cfm">

	<cfif isdefined("url.new_program")>
		<cfset mainwindowsrc = "/settings/program_type_settings.cfm?PageTitle=programs: programs">
	</cfif>

	<cfinclude template="/includes/header.cfm">
	<iframe class="left"  src="settings_frame_toc.cfm" name="toc" scrolling="auto" frameborder="0" id="toc"></iframe>
	<iframe class="right" src="<CFOUTPUT>#mainwindowsrc#</CFOUTPUT>" name="mainwindow" id="mainwindow" frameborder="0" resize="auto"></iframe>
</div>
<cfset request.focusHiLightOff = true>
</body>
</html>
