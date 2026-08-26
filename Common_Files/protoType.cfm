<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\Common_Files\protoType.cfm
      Date:
      Author:   Chris Nguyen
      Purpose:  Load prototype from Google CDN for better performance (or from local server when Google CDN is blocked)
----------------------------------------------------------------------------------------------------------------------->


<cfparam name="protoType.version"   default="1.6.0.3">

<cfoutput>
<script type="text/javascript">
 <!---if prototype is not yet loaded--->
 <!---for better performance, load prototype from Google CDN--->
 (window.Prototype  ||  (document.write('<script type="text/javascript" src="\/\/ajax.googleapis.com/ajax/libs/prototype/#protoType.version#/prototype.js"><\/script>')) );

 <!---if Prototype fails to load from Google CDN (due to DNS blocking) load it from local server--->
 (window.Prototype  ||  (document.write('<script type="text/javascript" src="/script/javascript/ajax_js/prototype-#protoType.version#.js"><\/script>')) );
</script>