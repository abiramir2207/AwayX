<cfset qGetGeneralLabels = request.qLabels.GetGeneralLabels()>
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>

<cfoutput>

<div id="masterContainer">
<form name="frmGeneralLabelModify" method="post">
<cfif isDefined("URL.updated") AND URL.updated EQ 1>
	<div id="masterContainer">
		<strong style="color:green; font-size:18px;">General Labels updated successfully.</strong>
	</div>
</cfif>
	<input type="hidden" name="generalLabelModify" value="1">
	<div id="headerContainer">
		<div id="innerHeaderContainer">Default General Label</div>
		<div id="innerHeaderContainer">Client General Label</div>
	</div>
	<cfset rowCounter = 0>
	<cfloop query="qGetGeneralLabels">
		<cfset rowCounter = rowCounter + 1>
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				#qGetGeneralLabels.General_Labels_Desc#
			</div>
			<div id="innerBodyContainer">
				<input type="text" onKeyUp="modified();" name="labelName#rowCounter#" value="#qGetGeneralLabels.General_Labels_Label#" size="30">
			</div>
		</div>
		<input type="hidden" name="General_Labels_ID#rowCounter#" value="#qGetGeneralLabels.General_Labels_ID#">
	</cfloop>
	<input type="hidden" name="loopCnt" value="#rowCounter#">
	

	<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
		<CF_button
				button_name		=	"generalLabelModify"
				button_caption	=	"save"
				button_action	=	"frmGeneralLabelModify.submit();"
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
