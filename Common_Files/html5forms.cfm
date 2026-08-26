<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \common_files\html5forms.cfm
          Date: 2017 November
        Author: Chris Nguyen
       Purpose: Load files that are needed for HTML5 Forms
----------------------------------------------------------------------------------------------------------------------->
</cfsilent>

<cf_include files="/script/javascript/html5Forms/js/modernizr.com/Modernizr-2.5.3.forms.js">

<cfscript>
	param name="request.data_webforms2_support"             default="";
	param name="request.data_webforms2_force_js_validation" default="true";

	html5Forms_js = "/script/javascript/html5Forms/js/html5Forms.js";
</cfscript>

<cfoutput>
<script src="#html5Forms_js#?v=#application.util.dateTime.fileVersion( html5Forms_js )#" 
		data-webforms2-support="#request.data_webforms2_support#" 
		data-webforms2-force-js-validation="#request.data_webforms2_force_js_validation#"></script>
</cfoutput>

