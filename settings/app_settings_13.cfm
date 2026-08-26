<cfset variables.claimSummaryObj = createObject("component", "components.Products.Group.AttributeManager") />
<cfset variables.claimSummaryLabels = variables.claimSummaryObj.getAllClaimSummary() />
<cfset mode = "claimSummary" />

<!--- REQUIRED SETTINGS FOR PROPER REDIRECT AFTER SAVE --->
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>

<cfoutput>

<div id="masterContainer">
<form name="claimSummaryLabelsModify" method="post">
<cfif isDefined("URL.updated") AND URL.updated EQ 1>
	<div id="masterContainer">
		<strong style="color:green; font-size:18px;">Claim Summary Labels updated successfully.</strong>
	</div>
</cfif>
	<input type="hidden" name="#mode#LabelsModify" value="1">
	<div id="headerContainer">
		<div id="innerHeaderContainer">Default Label</div>
		<div id="innerHeaderContainer">Client Label</div>
		<div id="innerHeaderContainer" style="width:265px; text-align:right;">Active</div>
	</div>
	<cfset rowCounter = 0>
	<cfloop query="variables.claimSummaryLabels">
	<cfset rowCounter = rowCounter + 1>
		<input type="hidden" name="id#rowCounter#" value="#Claim_SummaryID#">
		<cfif rowCounter MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<!---
		<cfif evaluate("getAll#mode#Attributes.search_filter_on NEQ 1>
			<cfset rowHilite = "inactive">
		</cfif>
		 --->
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				#BALabel#
				<input type="hidden" name="BALabel#rowCounter#" value="#BALabel#">
			</div>
			<div id="innerBodyContainer">
				<input type="text" onkeyup="modified();" name="CustomLabel#rowCounter#" value="#Client_Label#" size="30">
			</div>
			<div id="innerBodyContainer" nowrap> </div>
      <!--- Commented for D19840 for cleaner alignment -Anand Rao/22-Jul-09 --->
		<!--- 	<div id="innerBodyContainerSM" nowrap style="text-align:right;" style="border:1px solid gray;"></div> --->
			<div id="innerBodyContainerSM" nowrap style="text-align:right;">
				<div nowrap
					style="text-align:right; padding:5 6 3 6;"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgYes = $('imgYes#rowCounter#');
								var imgNo = $('imgNo#rowCounter#');
								var box = $('box#rowCounter#');
								if (imgYes.style.display == 'none') {
									imgYes.style.display='block';
									imgNo.style.display='none';
									box.checked=false;
								} else {
									imgYes.style.display='none';
									imgNo.style.display='block';
									box.checked=true;
								}
							">
					<cfif Deleted>
                     	<img id="imgYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgNo#rowCounter#" src='/images/no_small.gif' title="Click to make active"/>
					<cfelse>
						<img id="imgYes#rowCounter#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgNo#rowCounter#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					</cfif>
					<input id="box#rowCounter#"
							type="checkbox"
							value="1"
							name="Active#rowCounter#"
						    style="display:none;"
							<cfif Deleted>
								CHECKED
							</cfif>
							>

				</div>
			</div>
		</div>

	</cfloop>
	<input type="hidden" name="loopCnt" value="#rowCounter#">
	<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
		<CF_button
				button_name		=	"claimSummaryLabelsModify"
				button_caption	=	"save"
				button_action	=	"claimSummaryLabelsModify.submit(document.claimSummaryLabelsModify);"
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
