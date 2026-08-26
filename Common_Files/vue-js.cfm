<cfsetting enableCFoutputOnly = "yes">
<!---------------------------------------------------------------------------------------------------------------------
  Template: /Common_Files/vue-js.cfm
  Date:     2019 January
  Author:   Chris Nguyen
  Purpose:  Load Vue.js based on environment 
				  1. Development version with helpful console messages for development sites 
				  2. Production version with optimized size for production sites 
----------------------------------------------------------------------------------------------------------------------->
<cfscript>
	param name="request.vue_js_version" default="2.5";

	source_path = "/script/javascript/vue-js/" & trim(request.vue_js_version);
</cfscript>

<cfif application.util.io.isProduction()>
	<!-- production version, optimized for size and speed -->
	<cfoutput><cf_include files="#source_path#/vue.min.js"></cfoutput>
<cfelse>
	<!--- development version, includes helpful console warnings; download Vue.js devtools Chrome extension to debug --->
	<cfoutput><cf_include files="#source_path#/dist/vue.js"></cfoutput>
</cfif>

<cfsetting enableCFoutputOnly = "no">
