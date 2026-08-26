<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\jQueryHead.cfm
      Date:     Oct 11 2011
      Author:   Chris Nguyen
      Purpose:  Load jQuery
----------------------------------------------------------------------------------------------------------------------->


<cfparam name="jQuery.version"   default="1.7.2">
<cfparam name="jQueryUI.version" default="">         <!--- optional plug-in --->

<cfoutput>
<script type="text/javascript">
 <!---if jQuery is not yet loaded--->
 (window.jQuery  ||  (document.write('<script type="text/javascript" src="/script/javascript/ajax_js/jquery-#jQuery.version#-min.js"><\/script>')) );
</script>

<!---  do not load jQuery UI when it is blank since most of our web pages do not need jQuery UI  --->
<cfif len(trim(jQueryUI.version))>
  <!--- Jquery UI --->
  <!---for better performance, load jQuery UI from Google CDN--->
  <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jqueryui/#jQueryui.version#/jquery-ui.min.js"></script>
  <!---if jQuery UI fails to load from Google CDN (due to DNS blocking) load it from local server--->
  <script type="text/javascript">
   (window.jQuery.ui  ||  (document.write('<script type="text/javascript" src="/script/javascript/ajax_js/jquery-ui-#jQueryui.version#.min.js"><\/script>')) );
  </script>

  <!--- TOOLTIP --->
  <script type="text/javascript" src="/script/javascript/jquery.tools.min.js"></script>
</cfif>
</cfoutput>
