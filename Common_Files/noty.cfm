<cfsetting enableCFoutputOnly = "yes">
<!---
  * ====================================================================================================
  *  @Author: Chris Nguyen
  *    @Date: 2018-03-15 06:54:33
  *
  * @Remarks:
  *	NOTY is a jQuery plugin that makes it easy to create alert - success - error - warning - information -
  * confirmation messages as an alternative the standard alert dialog. Each notification is added to a queue.
  * For More Information :: http://ned.im/noty/#/about
  *
  * ====================================================================================================
--->
<cfparam name="request.noty_version" default="2">
<cfif request.noty_version is "3">
	<cfoutput>
	<cf_include files="/script/javascript/noty/3.1.4/noty.min.js, /script/javascript/noty/3.1.4/noty.css">
    <style>
        .noty_body {
            font-size: 13px;
        }
    </style>
    <script>
        function noty_message( msg ) {
            return msg + "<br><br><i class=noty_close>Please click anywhere in this box to close.</i>"
        }
        Noty.overrideDefaults({
            closeWith: ["click", "button"],
            layout: "bottomCenter",
            killer: true,
            theme: "relax",
            timeout: false,
            type: "information"
        });
	</script>
	</cfoutput>

<cfelseif request.noty_version is "2">
	<cfoutput>
	<style>
		.customContainer{
			margin: 5px auto;
		}
	</style>
	<cf_include files="/script/javascript/jquery.noty.packaged.min.js">
	<script>
		function processingPopUpDisplay(container) {
			jQuery( ".customContainer" ).css("width", "320px").show();
			
			jQuery(container).noty({
				text         : 	"PROCESSING, PLEASE WAIT..."
				,type        : 	"information"
				//,layout      : 	"center"
				,theme    	 : 	"defaultTheme"
				,killer		 :	true
				,timeout	 :	0
				,closeWith   : []
			});				
		}
	</script>
	</cfoutput>
</cfif>
<cfsetting enableCFoutputOnly = "no">
