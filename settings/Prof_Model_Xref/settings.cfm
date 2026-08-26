<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\settings\Prof_Model_Xref\settings.cfm
      Date:     2013 Mar
      Author:   Chris Nguyen
      Purpose:  Allow users to manage profit settings
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "profit-models-xref">
<link rel="stylesheet" type="text/css" href="/common_files/960.css">
<style>
#fs960 { width: 100%; border: 1px solid gray; }
#fs960 legend { font-weight: bold; font-size: 1.1em; padding: 5px; }
div.container_12 { margin-left: 20px !important; }
div.container_12 label { display: block; font-weight: bold; }
.grid_12 { margin: 10px; }
.action { padding-bottom: 15px; }
</style>
<cfscript>
  dataCFC = createObject("component", "components.general.Profitability_Models");
</cfscript>

<cfif cgi.request_method eq "post">
	<!---<cfdump var="#form#">--->
	<cfset dataCFC.saveSettings()>
</cfif>

<cfscript>
  qSettings = dataCFC.getSettings();
</cfscript>

<fieldset id="fs960">
	<legend>Settings</legend>
<div class="container_12">
	<form name="settings" method="post">
	<cfoutput>
	<div class="grid_12">
		<label for="Marketing_Cost_Percentage">Marketing Cost Percentage (0 to 100)</label>
		<input name="Marketing_Cost_Percentage" type="text" class="numeric" value="#qSettings.Marketing_Cost_Percentage#" size="40">%
	</div>
	<div class="grid_12">
		<label for="SGA_Cost_Percentage">SG & A Cost Percentage (0 to 100)</label>
		<input name="SGA_Cost_Percentage" type="text" class="numeric" value="#qSettings.SGA_Cost_Percentage#" size="40">%
	</div>
	<div class="grid_12">
		<label for="Other_SGA_Cost_Percentage">Other SG & A Cost Percentage (0 to 100)</label>
		<input name="Other_SGA_Cost_Percentage" type="text" class="numeric" value="#qSettings.Other_SGA_Cost_Percentage#" size="40">%
	</div>
	<div class="grid_12 action">
		<a href="##" class="action" id="save222">#application.util.string.actionLinkFormat("save")#</a>
	</div>
	</cfoutput>
	</form>
</div>	
</fieldset> 

<script type="text/javascript" src="/script/javascript/jquery.util.js"></script>

<script>
  $(".numeric").forceNumeric();
  $("#save222").click(function() {
  	$("form[name=settings]").submit();
  });
</script>
</cfmodule>