<cfsetting showDebugOutput="No">
<!DOCTYPE HTML>
<html>
	<head>
		<cfsilent>
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!--- Get the profile for this user																	 --->
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<cfinclude template="/get_access_profile.cfm">
			<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			<!--- gather user access information --->
            <cfquery name="qUser" datasource="#application.datasource#">
                SELECT  (   SELECT  COUNT(1)
                              FROM  Settings_Panel_Access_Modules                     tbl1
                                    INNER JOIN Settings_Panel_Access_Modules_Profiles tbl2
                                            ON tbl1.Settings_Panel_Access_Modules_ID = tbl2.Settings_Panel_Access_Modules_ID
                             WHERE  tbl2.Profiles_ID = <cfqueryparam value='#request.Accessstructure.Profiles_ID#'> ) AS SPAccess_Counter
                    ,(   SELECT  Is_USDA_User
                           FROM  _Users
                          WHERE  User_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.AccessStructure.User_ID#"> )  AS Is_USDA_User
                    ,(	 SELECT  DD_ACCESS_LEVEL
						   FROM  Deductions_Profiles_Settings
						  WHERE  Profiles_ID = <cfqueryparam value='#Get_Profile_Settings.Profiles_ID#'> ) AS DD_Access_Level
			</cfquery>
			<cfscript>
				param name="form.Link_Home_Disabled"         default="false";
				param name="form.Link_ToDoList_Disabled"     default="false";
				param name="form.Link_CompanyImage_Disabled" default="false";

				appSettings = application.appSettingsGet;

				if ( qUser.Is_USDA_User eq 1 ) {
                    // reset application only when it is needed
					if (application.returned_customer_setting.show_xm neq 0) {
					    application.returned_customer_setting.show_xm = 0;
                    }
                    if (application.appSettingsGet.getBillback_Module neq 0) {
                        application.appSettingsGet.getBillback_Module = 0;
                    }
                    if (application.appSettingsGet.getDeduction_Module neq 0) {
                        application.appSettingsGet.getDeduction_Module = 0;
                    }
					form.Link_Home_Disabled         = true;
					form.Link_ToDoList_Disabled     = true;
					form.Link_CompanyImage_Disabled = true;
				}
			</cfscript>
			<cfsavecontent variable="head_content">
				<meta charset="utf-8">
				<meta name="google-translate-customization" content="1d06f2ab974035a-e5ee11c62c2d43e4-g2ee81eac6be86099-12">
				<style>
                    body {
                        margin: 0;
                        padding: 0;
                    }
					#developer_tools { opacity:0; }
					#developer_tools:hover { opacity:1; }
					td {
						padding: 0px 4px;
						height: 50px;
					}
                </style>
			</cfsavecontent>
		</cfsilent>
		<!--- load all secondary .css files here :: the primary main_style.css is loaded by the 1st cfhtmlhead in Application_Common.cfm --->
		<cfhtmlhead text="#application.util.string.compress( head_content )#">
	</head>

    <body>
		<cfoutput>
		<cfsavecontent variable="body_content">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<!--- Header Goes here --->
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<table border="0" cellpadding="0" cellspacing="0" width="100%" background="/images/Header_Footer_New/Background_header2.gif">
			<tr>
				<td nowrap>
					<a href="#request.AccessStructure.User_Directory#/home.cfm" target="mywindowname" style="color:white;text-decoration:none;position:relative;top:-2px;">
						<span style="color:white; font-size:17px; font-weight:bold; padding:5px 3px; letter-spacing:0.65px;">
							#application.returned_customer_setting.Company_Name# &nbsp;-&nbsp;
						</span>
						<span ID="Page_Title" STYLE="color:white; font-size:17px; font-weight:bold; padding:5px 0;  letter-spacing:0.65px;"></SPAN>
						<br>
						<span style="color: white; font-size: 10px; font-weight: bold; padding: 5px 3px;">
							#request.AccessStructure.Name_First# #request.AccessStructure.Name_Last# - #dateformat(now(), 'dddd')#, #dateformat(now(), 'mmmm d yyyy')#
						</span>
                    </a>
                    <!--- add developer tools option to developers and 9999 users --->
                    <cfif request.accessstructure.user_rights_id eq 9999
                            OR listFindNoCase(application.util.query.get_Setting("developers", false), request.accessstructure.user_code)>
						<img id="developer_tools" onclick="open_devtools()" src="/developer/iconmonstr-weather-92-12.png" border="0">
					</cfif>
				</td>

				<cfset ShowProjectsScoreCard = application.oApplicationAppSettingsManager.getApplicationAppSettings().getShowProjectsScoreCard()>
				<td width="100%" align="left" valign="top">
					&nbsp;
				</td>

				<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getdisplayclientshelpdeskinfo() EQ 1>
					<td style="color: white; font-size:10px;" nowrap align="left">
						<cfoutput>#application.oApplicationAppSettingsManager.getApplicationAppSettings().getclientshelpdeskinfo()#</cfoutput>
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					</td>
				</cfif>
				<td>
					&nbsp;&nbsp;&nbsp;
				</td>

				<td>
					<cfif form.Link_Home_Disabled EQ false>
						<a href="#request.AccessStructure.User_Directory#/home.cfm" target="mywindowname">
							<img src="/images/Header_Footer_New/icon_home2.gif" title="Home" border="0" width="30" height="30">
						</a>
					<cfelse>
						<img src="/images/Header_Footer_New/icon_home2.gif" title="Home" border="0" width="30" height="30">
					</cfif>
				</td>

				<!--- ----------------------------------------------------------------------------------------- --->
				<!--- ----------------------------------------------------------------------------------------- --->
				<!--- ------ D51056 app setting for Dashboards to turn on/off BEGIN ------ --->
				<cfif appSettings.get_Setting('Dashboards') eq '1'>
                    <cfquery name="qDashboardAccessInfo" datasource="#application.datasource#">
                        SELECT Budget, Billback, Sales
                          FROM Dashboard_Access
                         WHERE Profile_ID = <cfqueryparam value=#request.AccessStructure.Profiles_ID#>
                    </cfquery>
                        <!--- gateway to the dashboards --------------------------------------------------------------- --->
					<cfif qDashboardAccessInfo.Budget EQUAL 1 OR qDashboardAccessInfo.Billback EQUAL 1 OR qDashboardAccessInfo.Sales EQUAL 1>
						<td>
							<a onclick="javascript:NewWindow('/dashboards/index.cfm','ticklerWindow','1024','650','Yes', 'Yes');return false;">
								<img src="/Images/Header_Footer_New/icon_dashboards2.png" title="Dashboards" border="0" width="30" height="30">
							</a>
						</td>
					</cfif>
					<!--- gateway to the dashboards --------------------------------------------------------------- --->
				</cfif>

				<!--- ------ D51056 app setting for Dashboards to turn on/off END ------ --->
				<!--- ----------------------------------------------------------------------------------------- --->
				<!--- ----------------------------------------------------------------------------------------- --->
				<!--- ----------------------------------------------------------------------------------------- --->
				<td>
					<cfif form.Link_ToDoList_Disabled EQ false>
						<A onclick="javascript:NewWindow('/todo/todo_view.cfm','ticklerWindow','450','300','Yes', 'Yes');return false;">
							<img border="0" src="/images/Header_Footer_New/icon_todo2.gif" title="ToDo List" WIDTH="30" HEIGHT="30">
						</a>
					<cfelse>
						<img border="0" src="/images/Header_Footer_New/icon_todo2.gif" title="ToDo List" WIDTH="30" HEIGHT="30">
					</cfif>
				</td>

				<!---D29446: blue banner Search program link issues. --->
				<td>
					<cfif abs(Get_Profile_Settings.Cont_Prog_View_Create_Program) EQ 1>
						<cfif appSettings.getFlexProgramSearch() EQ 1>
							<a href="/Scorecard/program_Search.cfm" target="mywindowname">
						<cfelseif (appSettings.getFlexProgramSearch() EQ 2) OR (appSettings.getFlexProgramSearch() EQ 3)>
							<a href="/flex/search/ProgramSearchFx.cfm" target="mywindowname">
						<cfelseif (appSettings.getFlexProgramSearch() EQ 4) OR (appSettings.getFlexProgramSearch() EQ 5)>
							<a href="/programs/program_search.cfm" target="mywindowname">
						<cfelse>
							<a href="/scorecard/scorecard1.cfm?SECTION_TO_OPEN=2" target="mywindowname">
						</cfif>
							<img border="0" src="/images/Header_Footer_New/icon_programs2.gif" title="Programs" width="30" height="30">
							</a>
					<cfelse>
						<img border="0" src="/images/Header_Footer_New/icon_programs2.gif" title="Programs" width="30" height="30">
					</cfif>
				</td>

				<!--- 57305: Retail Planner/09-Mar-2016/Anand Rao --->
				<cfif appSettings.get_Setting('Retail_Planner') eq '1'>
					<td>
						<a href="/Planners/Search/Planner_Search.cfm?LoadHeader=1" onclick="pageTitle('Search Planner')" target="mywindowname">
							<img border="0" src="/images/Header_Footer_New/icon_planners.gif" title="#Application.PlannerLabel#" width="35" height="30">
						</a>
					</td>
				</cfif>

				<cfif ShowProjectsScoreCard>
					<td>
						<cfif Get_Profile_Settings.PM_Access EQ 1>
							<a href="/ReportWriter/PM/index.cfm" target="mywindowname">
								<img src="/Images/Header_Footer_New/icon_projects2.gif" title="Projects" border="0" width="30" height="30">
							</a>
						<cfelse>
							<img src="/Images/Header_Footer_New/icon_projects2.gif" title="Projects" border="0" width="30" height="30">
						</cfif>
					</td>
				</cfif>

				<cfset PROGRAM_AGREE_STATUS_ID = ( Get_Profile_Settings.BB_RFA_Agreed EQ 1 ? 2 : 0 )>

				<td>
					<cfif application.appSettingsGet.getBillback_Module() EQ 1 AND ListFindNoCase("1,2", Get_Profile_Settings.BB_Create)>
						<!---
						31505:	App setting for Flex BB Module/Anand Rao/24-Apr-2012
						If it is Flex then take to flex pages to create for all other take to older method
						--->
						<cfif appsettings.getBillbackModuleType() EQ 2>
							<a href="/billbacks/2020/search_billbacks.cfm" target="mywindowname">	<!--- new GM --->
						<cfelse>
							<a href="/billbacks/scorecard/scorecard_main.cfm?SECTION_TO_OPEN=2&PROGRAM_AGREE_STATUS_ID=#PROGRAM_AGREE_STATUS_ID#" target="mywindowname">
						</cfif>
								<img border="0" src="/images/Header_Footer_New/icon_billbacks2.gif" title="Billbacks" width="30" height="30">
							</a>
					<cfelse>
						<img border="0" src="/images/Header_Footer_New/icon_billbacks2.gif" title="Billbacks" width="30" height="30">
					</cfif>
				</td>

				<cfif application.appSettingsGet.getDeduction_Module()>
					<!------ Deduction code ----->
 					<cfif qUser.DD_ACCESS_LEVEL gt 0>
						<td>
							<a href="/deductions/index.cfm" target="mywindowname">
								<img border="0" src="/images/icon_deducations.gif" title="Deductions" width="30" height="30">
							</a>
						</td>
					</cfif>
				</cfif>

				<td>
					<cfif qUser.SPAccess_Counter gt 0 or request.accessstructure.user_rights_id eq 9999>
						<a href="/settings/index2.cfm" target="mywindowname" onclick="pageTitle('Settings')" pagetitle="Settings">
							<img border="0" src="/images/Header_Footer_New/icon_settings2.gif" title="Settings Control Panel" WIDTH="30" HEIGHT="30">
						</a>
					<cfelse>
						<img border="0" src="/images/Header_Footer_New/icon_settings2.gif" title="Settings Control Panel" WIDTH="30" HEIGHT="30">
					</cfif>
				</td>

				<cfif not application.oApplicationAppSettingsManager.getApplicationAppSettings().getRemoveHelpIcon()>
					<td>
						<a href="/helpsystem/webhelp/blacksmith.htm" onclick="NewWindow(this.href,'name','1000','700','No', 'Yes');return false;" title="Helpful Information">
							<img border="0" src="/images/Header_Footer_New/icon_help2.gif" width="25" height="30">
						</a>
					</td>
				</cfif>

				<td>
					<a target="_top" style="position:relative; top2:-6px;" onclick="logoff()">
						<img border="0" src="/images/Header_Footer_New/icon_logoff2.gif" title="Logoff">
					</a>
				</td>

				<td>
					&nbsp;
				</td>
			</tr>
		</table>
		</cfsavecontent>

		#application.util.string.compress( body_content )#
		</cfoutput>

		<cfset request.focusHiLightOff = true>

		<script>
			function show_title( S_Title ) {
				document.all.Page_Title.innerText = S_Title;
            }

            function logoff() {
            	let lcd = '';

                try {
                    /* special logic for program search page - detect if save column changes function exists and run it prior to logging off */
                    if (typeof window.parent.mywindowname.save_program_search_columns === "function") {
                        window.parent.mywindowname.save_program_search_columns();
                        /* delay the logging off process to allow the above aJax function finishes otherwise session would expire and changes would be lost */
                        sleep(3000);
                    }

                    /* save user screen dimension (i.e. 1920x1080) into a variable */
                    lcd = screen.width + 'x' + screen.height;
                }
                catch (error) {
                };

                /* pass user screen dimension for stats */
                window.location = "/logoff.cfm?lcd=" + lcd + "&id=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>";
                return true;
            }

            let devtools_tab;       /* keep track of devtools tab */

            function open_devtools() {
                if (devtools_tab) {
                    /* devtools tab exists put it in focused */
                    devtools_tab.focus();
                }
                else {
                    /* create a new tab and place devtools on it */
                    devtools_tab = window.open("/developer/index.cfm", "_blank");
                }
            }
		</script>
</body>
</html>
