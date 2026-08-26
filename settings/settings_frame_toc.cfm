<cfsetting showDebugOutput="No">
<!doctype html>
<html>
<head>
	<title>xxxxxxxxxxxxxxxxxxxxxxxxx</title>
<STYLE TYPE="text/css">
	body {
		margin-left: 0;
	}
	.categoryMain {
		font-size: 10px;
		background-color : transparent;
		color : black;
		font-weight : bold;
	}
	.no_access
	{
		color:gray;
		cursor : not-allowed;
	}
</STYLE>
<SCRIPT SRC="/Script/javascript/prototype/prototype.min.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/prototype/scriptaculous.js"></SCRIPT>
<cfset currentPage = #GetFileFromPath(GetCurrentTemplatePath())#>

<cfsilent>
<!---Checks to see if NOI link should be displayed--->
<!--- USDANOI --->
<cfset usdanoi_on = 0>
<cfset usdanoi_component_id = "0">
<cfquery name="checkForSettingColumnExistance"  datasource="#application.datasource#">
	SELECT 		*
	FROM		INFORMATION_SCHEMA.COLUMNS
	WHERE		TABLE_NAME = '_Application_Settings'
		AND		COLUMN_NAME = 'usdanoi_enabled'
</cfquery>
<CFIF checkForSettingColumnExistance.recordcount GT 0>

	<cfset useLakebaseForisUSDANOI_enabled = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForisUSDANOI_enabled>
	<cftry>
		<cfset isUSDANOI_enabled = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "usdanoi_enabled"
			}), "usdanoi_enabled"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForisUSDANOI_enabled = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForisUSDANOI_enabled>
<cfquery name="isUSDANOI_enabled" datasource="#application.datasource#">
		SELECT 		usdanoi_enabled
		FROM 		_Application_Settings
	</cfquery>
</cfif>

	<cfif isUSDANOI_enabled.recordcount GT 0>
		<cfif isUSDANOI_enabled.usdanoi_enabled EQ 1>
			<cfset useLakebaseForgetusdanoicomponentid = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_rebates_component_name")>
<cfif useLakebaseForgetusdanoicomponentid>
	<cftry>
		<cfset getusdanoicomponentid = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_rebates_component_name", {
				"is_usda_noi_comp" = "eq.1",
				"deleted" = "eq.0",
				"select" = "program_rebates_component_name_id"
			}), "program_rebates_component_name_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetusdanoicomponentid = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetusdanoicomponentid>
<cfquery name="getusdanoicomponentid" datasource="#application.datasource#">
				SELECT 		Program_Rebates_Component_Name_ID
				FROM 		Program_Rebates_Component_Name
				WHERE 		Is_USDA_NOI_Comp = 1
					AND 	Deleted = 0
			</cfquery>
</cfif>

			<cfif getusdanoicomponentid.recordcount GT 0>
				<cfset usdanoi_on = 1>
				<cfset usdanoi_component_id = getusdanoicomponentid.Program_Rebates_Component_Name_ID>
			</cfif>
		</cfif>
	</cfif>

</CFIF>
</cfsilent>
<cfsilent>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfparam name="url.maint" default="0">
<!--- *****************************************************************************************************--->
<!--- ***
get settings panel access struct...new settings panel links on this page require record in the "Settings_Panel_Access_modules_profiles" 
table for that module.
*****--->
<!--- *****************************************************************************************************--->
<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess()>

</cfsilent>

<!---<cfif application.deductionLinksAvailable> ---> 
<cfif application.appSettingsGet.getDeduction_Module()>
	<!------ deduction code ----->
	<cfoutput>
		<cfset useLakebaseForWhoRebills = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
<cfif useLakebaseForWhoRebills>
	<cftry>
		<cfset WhoRebills = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_settings", {
				"select" = "rebill"
			}), "rebill"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForWhoRebills = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForWhoRebills>
<cfquery name="WhoRebills" datasource="#application.datasource#">
			SELECT 	Deduction_Settings.Rebill
			FROM Deduction_Settings
		</cfquery>
</cfif>
	</cfoutput>
</cfif>

	<cfparam name="subnav" default="">
	<cfparam name="application.returned_customer_setting.Accounting_Specialist" default="0" />


<!--- *************************************  INSTRUCTIONS TO ADD A LINK  ************************************--->
<!--- ***  Create the link within the category variable (<cfsavecontent> tags) desired.      			*****--->
<!--- *******************************************************************************************************--->

<!--- **********************************  INSTRUCTIONS TO ADD A CATEGORY  ***********************************--->
<!--- ***  1. Create a new <cfsavecontent> tag and add the desired links.      							*****--->
<!--- ***  2. Create an image tag variable.								      							*****--->
<!--- ***  3. Create an append group using the variable from the <cfsavecontent> tag.					*****--->
<!--- *******************************************************************************************************--->


<!--- Lists of links stored as variables (Variable is the category name that will display on the page) --->

<cfinclude template="settings_frame_links.cfm">

<!--- Output display data --->

<cfoutput>
</head>

<cfif isDefined("url.subnav")>

<body style="border-right:1px solid ##DDDDDD;"
		text="black"
		link="blue"
		vlink="blue"
		alink="red"
		leftmargin="0"
		topmargin="15"
		onload="new Effect.BlindDown('#url.subnav#',{duration: .01}); $('showAction#url.subnav#').innerHTML = '^';">

	<div class="categoryMain" style="padding-bottom:15px;">
		<img src="/Images/Control_panel/Control_panel_closed.gif" width="24" alt="Control Panel" border="0">
	  	<A href="/settings/index2.cfm" target="mywindowname" title="Settings Control Panel">
			<b>Control panel</b>
		</A>
	</div>
	<cfset row = 0>
	<cfloop list="#categoryList#" index="i">
	<cfset title = i>
	<cfif i EQ "BSA Administration"><cfset i = "BSAAdmin"></cfif>
	<cfset row = row + 1>
		<div>
			<div nowrap style="width:100;" onmouseover="this.style.cursor='pointer';"
					onmouseout="this.style.cursor='';"
					onclick="
					if ($('showAction#i#').innerHTML == '') {
							new Effect.BlindDown('#i#',{duration: .2});
							$('showAction#i#').innerHTML = '^';
						} else if ($('showAction#i#').innerHTML == '^') {
							new Effect.BlindUp('#i#',{duration: .1});
							$('showAction#i#').innerHTML = '';
						}
					">
				#imgArray[row]#
				<span nowrap class="categoryMain">#title#</span>
				<span nowrap class="show" id="showAction#i#" class="showAction"></span>
			</div>
			<div nowrap id="#i#" style="display:none; padding-left: 10px;">
				#linksArray[row]#
			</div>
		</div>
	</cfloop>
</body>

<cfelse>
<BODY TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<P align="center"><BR>
<IMG border="0" src="/Images/Control_panel/Control_panel_open.gif" width="64" height="64"><BR>
<BR>
<IMG border="0" src="/Images/Control_panel/Control_panel_label.gif" width="64" height="377"></P>

</cfif>
<cfset request.focusHiLightOff = true>
</cfoutput>
</body>
</html>
