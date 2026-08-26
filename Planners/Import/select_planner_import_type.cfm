<!------------------------------------------------------------------------------------------------------------------------------------------
	   File Name:  AwayX/Planners/Import/select_planner_import_type.cfm
	Created Date:  2019 Sept
	  Created By:  kal
	 Description:  displays option to choose the  planner import type.
	 				This page is shown as include when using import from home page also as a modal/popup when clicking from planner calendar
------------------------------------------------------------------------------------------------------------------------------------------->

<style>
	div.rowHeader {margin: 10px 30px; font-weight: bold;}
	a.rowLink  {margin-left: 20px; margin-top: 30px; font-style: normal;}
</style>
<cfparam name="url.popup" default="0" />
<cfparam name="url.templateId" default="" />
<cf_include files="/common_files/jQuery.cfm, /common_files/jQueryUI.cfm, /styles/css-loader.css">
<!--- create the links here --->
<cfoutput>

<h3>
	<div class="rowHeader">Select an import type:
		<div><a href='##' class="rowLink" value="1">#application.util.string.linkFormat("copy from different customer - same template")#</a></div>
		<div><a href='##' class="rowLink" value="2">#application.util.string.linkFormat("copy from same customer, different dates")#</a></div>
	</div>
</h3>


<cfif url.popup >
	<script>
		$("a.rowLink").click(function() {
			var type = $(this).attr("value");
			$("input[name=planner_import_type]", parent.document).val( type ); // import type
			if (type == 1)
				$("input[name=planner_template_id]", parent.document).val('#url.templateId#');

			// submit parent form
			parent.import_programs();
			// close this page
			parent.dhx_window_close();
		});
	</script>
<cfelse>
	<form name="select_planner_import_type" method="post">
		<cfset saveHiddenValues()>
	</form>

	<script>
		$("a.rowLink").click(function() {
            show_loader();
			$("input[name=planner_import_type]").val( $(this).attr("value") );
			$("form[name=select_planner_import_type]").submit();
		});
	</script>
</cfif>
</cfoutput>
