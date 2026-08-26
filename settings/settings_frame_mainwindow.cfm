<cfsetting showDebugOutput="Yes">
<head>
<STYLE TYPE="text/css">
	.subButton {
		font-size: 11px;
		WIDTH: 122px;
		background-color : transparent;
		color : blue;
		border-style : none none none none;
		font-weight : bold;

	}
	.subButtonOver {
		font-size: 11px;
		WIDTH: 122px;
		background-color : transparent;
		color : red;
		border-style : none none none none;
		font-weight : bold;
		text-decoration : underline;
		cursor:pointer;
	}
	.categoryMain {
		font-size: 14px;
		background-color : transparent;
		color : black;
		font-weight : bold;
	}
	.show {
		font-size: 9px;
		background-color : transparent;
		color : blue;
	}
	.showOver {
		font-size: 9px;
		background-color : transparent;
		color : red;
		text-decoration : underline;
		cursor:pointer;
	}
	.no_access
	{
		color:gray;
		cursor : not-allowed;
	}
	.al0 {
		color: Silver;
		font-size: 10px;
		WIDTH: 25px;
	}
	.al1 {
		color: red;
		font-size: 10px;
		WIDTH: 25px;
	}
	.al2 {
		color: #DAA520;
		font-size: 10px;
		WIDTH: 25px;
	}
	.al3 {
		color: green;
		font-size: 10px;
		WIDTH: 25px;
	}
	.al4 {
		color: #00008B;
		font-size: 10px;
		WIDTH: 25px;
	}
	.al5 {
		color: #261056;
		font-size: 10px;
		WIDTH: 25px;
	}
	.tal0 {
		color: Silver;
		font-size: 10px;
		WIDTH: 12px;
		cursor:pointer;
	}
	.tal1 {
		color: red;
		font-size: 10px;
		WIDTH: 12px;
		cursor:pointer;
	}
	.tal2 {
		color: #DAA520;
		font-size: 10px;
		WIDTH: 12px;
		cursor:pointer;
	}
	.tal3 {
		color: green;
		font-size: 10px;
		WIDTH: 12px;
		cursor:pointer;
	}
	.tal4 {
		color: #00008B;
		font-size: 10px;
		WIDTH: 12px;
		cursor:pointer;
	}
	.tal5 {
		color: #261056;
		font-size: 10px;
		WIDTH: 12px;
		cursor:pointer;
	}
</STYLE>
<SCRIPT SRC="/Script/javascript/prototype/prototype.min.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/prototype/scriptaculous.js"></SCRIPT>
</head>
<body>
<cfset PageTitle="CONTROL PANEL">
<cfset currentPage = #GetFileFromPath(GetCurrentTemplatePath())#>
<cfinclude template="/helpsystem/help_link.cfm">
<cfinclude template="/settings/settings_title.cfm">

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

	<cfquery name="isUSDANOI_enabled" datasource="#application.datasource#">
		SELECT 		usdanoi_enabled
		FROM 		_Application_Settings
	</cfquery>

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
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<cfparam name="url.maint" default="0">
<cfparam name="url.profileId" default="0">
<!--- *****************************************************************************************************--->
<!--- ***
get settings panel access struct...new settings panel links on this page require record in the "Settings_Panel_Access_modules_profiles" 
table for that module.
*****--->
<!--- *****************************************************************************************************--->
<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
<cfset getSPA = SPA.getSPAccess(url.maint,url.profileId)>
<cfset IsSPAccessAllowed = SPA.getCheckSPAccessAllowed()>
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

<CFIF (IsSPAccessAllowed AND url.maint EQ 0) OR url.maint EQ 1>


<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<span id="customContainer" style="margin-left:30%;margin-bottom:-4%;padding-top:6px;display:none;border:solid;width:370px;height:35px;color:white;text-align:center;background: url(\Images\Animation\images\ajax-loader.gif);">
	PROCESSING PLEASE WAIT...
</span>
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->


	<cfparam name="subnav" default="">
	<cfparam name="application.returned_customer_setting.Accounting_Specialist" default="0" />

	<cfif Url.maint eq 1>
		<form method="post" name="SPAForm" action="/settings/SPAFormAction.cfm">
	</cfif>

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

	<div style="padding-bottom:25px;width:900px;">
			<cfif Url.maint eq 1>
                 <cfoutput>
                    <input type="hidden" name="profile_Id" value="#url.profileId#">
					<input type="hidden" name="Original_profileId" value="#url.profileId#">
                </cfoutput>
                
                <div style="float:left;width:150px;">
					<FONT COLOR="Red">[</FONT>&nbsp;<input type="Submit" value="Update Access Rights" name="submit" class="subbutton"onmouseover="this.className='subbuttonover'" onmouseout="this.className='subbutton'">&nbsp;<FONT COLOR="Red">]</FONT>
				</div>
				<!--- DISPLAYS LAST UPDATED BY INFORMATION --->
				<cfset appSettings = genSettingsManager.get(1,14,1)>
				<cfif Len(appSettings.getUpdatedByUserName()) GT 0>
					<cfoutput>
						<DIV style="float:left;margin-left:10;width:700px;">
							<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;margin-left:10;" CELLPADDING="3" CELLSPACING="0">
								<TR>
									<TD>
										<FONT SIZE="2">
											<B>
												The settings were last updated on #dateformat(appSettings.getUpdatedOn(), 'mm/dd/yyyy')# at
												#timeformat(appSettings.getUpdatedOn(), 'hh:mm:ss TT')# by #appSettings.getUpdatedByUserName()#
											</B>
										</FONT>
									</TD>
								</TR>
							</TABLE>
						</DIV>
					</cfoutput>
				</cfif>
			</cfif>
	</div>
	<cfif NOT URL.maint>
		<div id="showAll"
			class="show"
			style="width:5px;margin-left:300px;"
			onmouseover="this.className='showOver';this.style.cursor='pointer';"
			onmouseout="this.className='show';this.style.cursor='';"
			onclick="
			var catList = '<cfoutput>#categoryList#</cfoutput>';
			var catList = catList.split(',');
				for(var i=0; i<catList.length; i++){
					if (this.innerHTML == 'Expand') {
							if ($('showAction' + catList[i]).innerHTML == '(show)') {
								new Effect.BlindDown(catList[i],{duration: .450});
								$('showAction' + catList[i]).innerHTML = '(hide)';
								var expand = true;
							}
						} else if (this.innerHTML == 'Collapse') {
							new Effect.BlindUp(catList[i],{duration: .250});
							$('showAction' + catList[i]).innerHTML = '(show)';
							var expand = false;
						}
				}
					if (expand){
						this.innerHTML = 'Collapse';
					} else {
						this.innerHTML = 'Expand';
					}
				">Expand</div>
	</cfif>
	<cfoutput>
		<cfset row = 0>
		<cfloop list="#categoryList#" index="i">
		<cfset row = row + 1>
			<div nowrap style="width:270;">
				<div nowrap style="width:270;margin:4px 0;"
						<cfif NOT URL.maint>	
						 	onmouseover="$('showAction#i#').className='showOver';this.style.cursor='pointer';"
							onmouseout="$('showAction#i#').className='show';this.style.cursor='';"
							onclick="
							if ($('showAction#i#').innerHTML == '(show)') {
									new Effect.BlindDown('#i#',{duration: .250});
									$('showAction#i#').innerHTML = '(hide)';
								} else if ($('showAction#i#').innerHTML == '(hide)') {
									new Effect.BlindUp('#i#',{duration: .150});
									$('showAction#i#').innerHTML = '(show)';
								}
							"
						</cfif>>
					#imgArray[row]#
					<span class="categoryMain" style="padding-bottom:3px;">#i#</span>
					<cfif NOT URL.maint>
						<span class="show showAction" id="showAction#i#">(show)</span>
					</cfif>
				</div>
				<div id="#i#" style="<cfif NOT URL.maint>display:none; </cfif>padding-left: 40px;" onclick="document.getElementById('customContainer').style.display='block';">
					#linksArray[row]#&nbsp;
				</div>
				<hr style="width:450;margin:6px 0;">
			</div>
		</cfloop>
	</cfoutput>

	<cfif Url.maint eq 1>
        <cfinclude template="/settings/access_rights/select_grouplevelaccess_profiles.cfm" />
		</form>
	
	</cfif>
<cfelse>
	<cflocation url="#application.HomePage#">
</cfif>

<cfset request.focusHiLightOff = true>

<script>
	pageTitle( "Settings", 1 );
</script>
</body>
</html>