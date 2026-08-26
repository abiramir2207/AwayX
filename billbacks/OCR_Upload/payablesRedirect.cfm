
<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/payablesRedirect.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Redirects to the Upload Payables page from the status page.
---------------------------------------------------------------------------------->

<cfparam name="URL.redirectTo" default="UPLOAD"/>
<cfparam name="URL.Upload_ID" default="0"/>

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
		<cfset getSPA = SPA.getSPAccess()>

		<cfif getSPA.Upload_Billback_index eq 0>
			<cflocation url="/Manufacturers/home.cfm" addtoken="yes">
		</cfif>
		
		<cfoutput>
			<cfset GROUP = "Control_Panel">
			<cfif redirectTo EQ "UPLOAD">
				<cfset mainwindowsrc = "/Settings/upload_billback_utility/index.cfm?Show_Tab=1">
			<cfelseif redirectTo EQ "BBDETAILS">
				<cfset mainwindowsrc = "/Settings/upload_billback_utility/index.cfm?show_tab=6&Upload_ID=#URL.Upload_ID#&tab_title=billbacks&upload_type_id=2">
		 	<cfelseif redirectTo EQ "BBVALIDATIONFAIL">
				<cfset mainwindowsrc = "/Settings/upload_billback_utility/index.cfm?show_tab=6&tab_title=Upload Detail&upload_id=#URL.Upload_ID#">
			 </cfif>
		</cfoutput>
	
		<cfinclude template="/includes/header.cfm">
		<iframe class="left"  src="/settings/settings_frame_toc.cfm?subnav=Payables" name="toc" scrolling="auto" frameborder="0" id="toc"></iframe>
		<iframe class="right" src="<cfoutput>#mainwindowsrc#</cfoutput>" name="mainwindow" id="mainwindow" frameborder="0" resize="auto"></iframe>
	</div>
</body>
</html>
