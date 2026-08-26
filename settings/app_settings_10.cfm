<cfset GetPricingLevel = request.qLabels.GetPricingLevel()>
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>

<cfoutput>

<div id="masterContainer">
<form name="priceLevelModify" method="post">
<cfif isDefined("URL.updated") AND URL.updated EQ 1>
	<div id="masterContainer">
		<strong style="color:green; font-size:18px;">Pricing Level updated successfully.</strong>
	</div>
</cfif>
	<input type="hidden" name="priceLevelModify" value="1">
	<div id="headerContainer">
		<div id="innerHeaderContainerSM">Level</div>
		<div id="innerHeaderContainer">Default Label</div>
		<div id="innerHeaderContainer">Client Label</div>
		<div id="innerHeaderContainer"></div>
		<div id="innerHeaderContainerSM"></div>
	</div>
	<cfset rowCounter = 0>
	<cfloop query="getPricingLevel">
		<cfset rowCounter = rowCounter + 1>
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainerSM">
				<!--- DEV NOTE: DAA; D16736 Check for null values, if null, then generate new pricing_External_ID values. --->
					<cfif getPricingLevel.pricing_External_ID NEQ "">
						#getPricingLevel.pricing_External_ID#
						<input type="hidden" name="extId#rowCounter#" value="#getPricingLevel.pricing_External_ID#">
					<cfelse>
						Level #rowCounter#
						<input type="hidden" name="extId#rowCounter#" value="Level #rowCounter#">
					</cfif>
				<input type="hidden" name="pricing_level_id#rowCounter#" value="#getPricingLevel.pricing_level_id#">
			</div>
			<div id="innerBodyContainer">
				<CFIF request.AccessStructure.USER_RIGHTS_ID EQ 9999>
					<input type="text" onKeyUp="modified();" name="labelDesc#rowCounter#" value="#getPricingLevel.pricing_level_desc#" size="30">
				<CFELSE>
					#getPricingLevel.pricing_level_desc#
					<input type="hidden" name="labelDesc#rowCounter#" value="#getPricingLevel.pricing_level_desc#">
				</CFIF>
			</div>
			<div id="innerBodyContainer">
				<input type="text" onKeyUp="modified();" name="labelName#rowCounter#" value="#getPricingLevel.pricing_level_label#" size="30">
			</div>
			<div id="innerBodyContainerSM" nowrap></div>
			<div id="innerBodyContainerSM" nowrap></div>
		</div>
<!--- DEV NOTE: DAA; D16736 Forgot to remove this when label D15346 was fixed.
	<cfset labelNum = listgetat(getPricingLevel.pricing_External_ID,2," ") + 1>
 --->
	</cfloop>
	<input type="hidden" name="loopCnt" value="#rowCounter#">

<!--- DEV NOTE: DAA; D15346 Removed because only 3 price levels are allowed.
	<cfif not isDefined("labelNum")>
		<cfset labelNum = 1>
	</cfif>
	<cfset counter = rowCounter + 1>
	<input type="hidden" name="loopCnt" value="#counter#">
	<cfif rowHilite EQ "rowBg1">
		<cfset overflowBG = "rowBg2">
	<cfelse>
		<cfset overflowBG = "rowBg1">
	</cfif>
	<CFIF request.AccessStructure.USER_RIGHTS_ID EQ 9999>
		<div id="bodyContainer" class="sortSection #overflowBG#">
			<div id="innerBodyContainerSM">
				Level #labelNum#
				<input type="hidden" name="extId#counter#" value="Level #labelNum#">
			</div>
			<div id="innerBodyContainer"><input type="text" name="labelDesc#counter#" size="30"></div>
			<div id="innerBodyContainer"><input type="text" name="labelName#counter#" size="30"></div>
			<div id="innerBodyContainer" nowrap style="text-align:right;"></div>
			<div id="innerBodyContainer" nowrap style="text-align:right;"></div>
		</div>
	</CFIF>
 --->

	<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
		<CF_button
				button_name		=	"priceLevelModify"
				button_caption	=	"save"
				button_action	=	"priceLevelModify.submit(document.priceLevelModify);"
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
