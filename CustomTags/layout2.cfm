<!---------------------------------------------------------------------------------------------------------------------
	  Template: \customtags\layout2.cfm
	  Date:     2017 October
	  Author:   Chris Nguyen
	  Purpose:  Layout template for web pages

	  Remarks:  For new layoutID you will need to:

				  a.  Specify page title & put it in 'page_title' variable
				  b.  Specify menu links & put them in 'menus' array of structures
						* text = required, string value to be displayed in the menu
						* href = required only when onclick is not defined
						* onclick = required only when href is not defined
---------------------------------------------------------------------------------------------------------------------->
<cfif thisTag.executionMode is "start"><!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<cfsilent>
		<cfparam name="attributes.layoutID" default="">                 <!---value is optional--->
		<cfparam name="attributes.selectedIndex" default="">            <!---value is required when onclick is used and href is not--->
		<cfset nav_menu = []>

		<cfswitch expression="#attributes.layoutID#">
		  <!--------------------------------->
		  <!--- consumer events --->
		  <!--------------------------------->
		  <cfcase value="consumer_events">
			<cfset nav_menu = [  { text="Events", href="/planners/consumer_events/events/list.cfm" }
								,{ text="Types",  href="/planners/consumer_events/types/list.cfm" }
							]>
			<cfset page_title = "CONSUMER EVENTS">
		  </cfcase>

		  <cfdefaultcase>   <!--- we should never reach to here --->
			<cfset page_title = "Untitled">
			<cfset nav_menu   = []>
		  </cfdefaultcase>
		</cfswitch>
	</cfsilent>
	<title><cfoutput>#page_title#</cfoutput></title>
	<cfsavecontent variable="head_content">
		<cfset include_files = [ "/styles/css-loader.css", "/common_files/jQuery.cfm" ]>
		<cf_include files=#arrayToList( include_files )#>
		<style>
		  body { margin:0; padding:0; }
		  /* styles for horizontal menu options */
		  #hMenU {list-style:none;background:url(/Images/gradient.jpg) #a7caf2 no-repeat;color:#FFF;line-height:30px !important;margin:0;padding:0;}
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
<cfsilent>
<!------------------------------->
<!--- display horizontal menu --->
<!------------------------------->
<cfset nav_menuCnt = 0>
<cfsavecontent variable="variables.horizontal_menu">
<ul id="hMenU">
  <cfloop array=#nav_menu# index="menuItem">
	<cfset nav_menuCnt = nav_menuCnt + 1>
	<cfoutput>
	<li>
	  <cfif nav_menuCnt gt 1> | </cfif>
	  <a <cfif structKeyExists(menuItem, 'onclick')> onclick="#menuItem.onclick#" </cfif>
		  <cfif structKeyExists(menuItem, 'href')> href="#menuItem.href#" <cfelse> href="##" </cfif>
		  > #lcase(menuItem.text)# </a>
	</li></cfoutput>
  </cfloop>
</ul>
</cfsavecontent>
</cfsilent>
<cfoutput>#application.util.string.compress( variables.horizontal_menu )#</cfoutput>
<!--------------------------------------------------------------------------------------------------------------------->
<div id="layoutBody">

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
   var jMenuSelected = 0;
   <cfif len(attributes.selectedIndex)>
	 jMenuSelected = jQuery('#hMenU li:eq(<cfoutput>#attributes.selectedIndex#</cfoutput>) a');
	 jMenuSelected.addClass( 'selected' );
   <cfelse>
	 /* find selected option & then highlight it */
	 jQuery('#hMenU li a[href]').each(function() {
	   if ( jQuery(this).attr('href').toLowerCase().indexOf( <cfoutput>'#template_name#'</cfoutput> ) !== -1 ) {
		 jMenuSelected = jQuery(this);
		 jMenuSelected.addClass( 'selected' );
		 return false;
	   }
	 });
   </cfif>

   jQuery('#hMenU a').click( function() {
	 show_loader();
   });
});
</script>
<!--- injects style for focused element here instead of using Application.cfc which places the same code oustide of </html> tag --->
<cfinclude template="/common_files/focus.cfm">     <!--- 47143 --->
</body>
</html>
</cfif>     <!--- if thisTag.executionMode is "start" --->
