<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\jQuery.cfm
      Date:     Oct 11 2011
      Author:   Chris Nguyen
      Purpose:  Load jQuery from Google CDN for better performance (or from local server when Google CDN is blocked)
----------------------------------------------------------------------------------------------------------------------->
<cfparam name="jQuery.version"   default="1.7.2">
<cfparam name="jQueryUI.version" default="">         <!--- optional plug-in --->
<!--- 2015 may 1: jQuery 1.7.2 bug discovered in IE 10 IE7 document mode IE 5 quirks mode :: http://bugs.jquery.com/ticket/12577
	  			  a.  documented reported problem on http://kb/index.php?/article/AA-00367/10/Script3%3A-Member-Not-Found.html
	  			  b.  modified jQuery-1.7.2-min.js to trap the js error
	  			  c.  modified to load our custom jQuery-1.7.2-min.js
	  			  d.  removed the option to load jQuery-1.7.2-min.js from Google CDN (content delivery network)
--->
<!--- if jQuery is not yet loaded --->
<!--- for better performance, load jQuery from Google CDN --->
<!--- if jQuery fails to load from Google CDN (due to DNS blocking) load it from local server --->
</cfsilent>
<cfoutput>
<cf_include files="/script/javascript/ajax_js/jquery-#jQuery.version#-min.js">
<cfif len(trim(jQueryUI.version)) or isDefined("jQueryUI.widgets")> <!---  do not load jQuery UI when it is blank since most of our web pages do not need jQuery UI  --->
  <cfinclude template="/common_Files/jQueryUI.cfm">
</cfif>
</cfoutput>
