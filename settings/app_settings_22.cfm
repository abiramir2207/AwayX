<!----------------------------------------------------------------------------------
Name         :  AwayX/settings/app_settings_22.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  31-JAN-2017
Created By   :  KAL
Description  :  Planner Label Settings
---------------------------------------------------------------------------------->
<cfif not isDefined("request.qLabels")>
	<cfset request.qLabels = createObject("component", "components.settings.Labels.Labels").init()>
</cfif>
<cfset qPlannerLabels = request.qLabels.GetPlannerLabels()>
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>

<cfoutput>

<div id="masterContainer">
<form name="frmPlannerLabelModify" method="post">
<cfif isDefined("URL.updated") AND URL.updated EQ 1>
	<div id="masterContainer">
		<strong style="color:green; font-size:18px;">#Application.PlannerLabel# Labels updated successfully.</strong>
	</div>
</cfif>
	<input type="hidden" name="PlannerLabelModify" value="1">
	<div id="headerContainer">
		<div id="innerHeaderContainer">Default Label</div>
		<div id="innerHeaderContainer">Client Label</div>
		<div id="innerHeaderContainer">Plural</div>
	</div>
	<cfset rowCounter = 0>
	<cfloop query="qPlannerLabels">
		<cfset rowCounter = rowCounter + 1>
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				#qPlannerLabels.Planner_Labels_Desc#
			</div>
			<div id="innerBodyContainer">
				<input type="text" onKeyUp="modified();" name="Planner_Labels_Singular_#rowCounter#" value="#qPlannerLabels.Planner_Labels_Singular#" size="30">
			</div>
			<div id="innerBodyContainer">
				<input type="text" onKeyUp="modified();" name="Planner_Labels_Plural_#rowCounter#" value="#qPlannerLabels.Planner_Labels_Plural#" size="30">
			</div>
		</div>
		<input type="hidden" name="Planner_Labels_ID_#rowCounter#" value="#qPlannerLabels.Planner_Labels_ID#">
	</cfloop>
	<input type="hidden" name="loopCnt" value="#rowCounter#">


	<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
		<CF_button
				button_name		=	"plannerLabelModify"
				button_caption	=	"save"
				button_action	=	"frmPlannerLabelModify.submit();"
				button_type		=	"javascript_link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"10"
				font_weight		=	"bold"
				>
	</div>

</form>
</div>
</cfoutput>
