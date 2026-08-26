<!---
	FILENAME: settings/app_settings_6.cfm
	Copyright (c) 2008 Blacksmith Applications, Inc.
	Description: Management screen for the application's Margin Page settings.
	CREATED: 	01/29/2007 Ben Densmore
	EDITED:		10/02/2008 RBL [D16314 > 17218: Margin Analysis - Add Contract Price]
	Purpose: Administration of column headers in Margin page.

	FUNCTIONALITY:
	DEPENDENCIES:
--->

<!--- These parameters are required for this template to process correctly --->
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>
<cfoutput>

<style>
	.appSettingsInput
	{
		text-align:right;
		width:50px;
	}
</style>
<!--- 16314 [added 'Fixed Price'] --->
<cfset LabelListMarginPage = "Annual Vol. CS,Base Sales,Cash Disc.,Local Costs,Allow,Trade Adj.,Amt +,Net Sales,Cost,Brokerage,Opr. Income $,Opr. Margin %, Target %,Trade Spend $,Fixed Price,Trade,Trade %,Annual Case Rate,Target Case Rate,Annual LB Rate,Target LB Rate, Equiv UOM,Allow %,Contrib.Margin $,Contrib.Margin %,Margin Targets">
<!--- D42028	Cost fields in Huhtamaki stage: re-label and remove ones not using--->
<cfset labelListCostPage = "Variable Manufacturing Cost,Fixed Manufacturing Cost,Delivery,Customer Pick up Allowance,Variable Warehousing,Freight Delivered, Freight FOB, Warehouse FOB">

<div id="masterContainer">
<form name="MarginLabels" method="post">
		<input type="hidden" name="modifyMarginLabels" value="1">
	<div id="headerContainer">
		<div id="innerheaderContainer">Default Label</div>
		<div id="innerheaderContainer">Client Label</div>
		<div id="innerheaderContainer" style="width:100px; text-align:right;">Active</div>
		<div id="innerheaderContainerSM"></div>
		<div id="innerheaderContainerSM"></div>
	</div>
	<cfset row = 0>
	<cfloop list="#LabelListMarginPage#" index="i">
		<cfset row = row + 1>
		<cfif row MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				#i#
			</div>
			<div id="innerBodyContainer">
            	<!--- 16314 > 17218 RBL [begin] --->
            	<cfif i EQ "Fixed Price">
                    <input name="marginColHeader#row#"
                            type="text"
                            onKeyUp="modified();"
                            value="#evaluate('appSettings.getMarginColHeader#row#()')#"
                            size="18"
                            maxlength="20" />
				<cfelse>
                	<input name="marginColHeader#row#"
                            type="text"
                            onKeyUp="modified();"
                            value="#evaluate('appSettings.getMarginColHeader#row#()')#"
                            size="18"
                            maxlength="14" />
                </cfif>
                <!--- 16314 > 17218 RBL [end] --->
			</div>
			<div id="innerBodyContainer"></div>
			<div id="innerBodyContainerSM"></div>
			<div id="innerBodyContainerSM"></div>
		</div>
	</cfloop>
	<cfset row = 0>
	<cfloop list="#LabelListCostPage#" index="i">
		<cfset row = row + 1>
		<cfif row MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				#i#
			</div>
			<div id="innerBodyContainer">
				<input name="marginCostColHeader#row#"
						type="text"
						onKeyUp="modified();"
						value="#evaluate('appSettings.getMarginCostColHeader#row#()')#"
						size="40"
						maxlength="27" />
			</div>
			<div id="innerBodyContainerSM"></div>
			<div id="innerBodyContainerSM"
					onMouseOver="this.style.cursor='pointer';"
					onMouseOut="this.style.cursor='';"
					onClick="
								modified();
								var imgYes = $('imgYes#row#');
								var imgNo = $('imgNo#row#');
								var box = $('box#row#');
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
					<cfif evaluate('appSettings.getMarginCostColHeader#row#_delete()')>
                     	<img id="imgYes#row#" src='/images/yes_small.gif' title="Click to make inactive" style="display:none;"/>
						<img id="imgNo#row#" src='/images/no_small.gif' title="Click to make active"/>
					<cfelse>
						<img id="imgYes#row#" src='/images/yes_small.gif' title="Click to make inactive"/>
						<img id="imgNo#row#" src='/images/no_small.gif' title="Click to make active" style="display:none;"/>
					</cfif>
					<input id="box#row#"
							type="checkbox"
							value="1"
							name="marginCostColHeader#row#_delete"
						    style="display:none;"
							<cfif evaluate('appSettings.getMarginCostColHeader#row#_delete()')>
								CHECKED
							</cfif>
							>
			</div>
			<div id="innerBodyContainerSM"></div>
		</div>
	</cfloop>
	<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
		<CF_button
				button_name		=	""
				button_caption	=	"Save"
				button_action	=	"MarginLabels.submit(document.MarginSettings);"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
	</div>
</form>
</div>
</cfoutput>
