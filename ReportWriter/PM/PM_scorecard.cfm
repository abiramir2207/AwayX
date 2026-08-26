<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<!--- D17674 [begin] RBL 12/08/08 --->
<cfparam name="form.projectView" type="string" default="owner">
<CFPARAM name="URL.useCache" default="#appSettings.getProjectScorecardCache()#">
<!--- D17674 [end] RBL 12/08/08 --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>Untitled</TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<STYLE>
	TD.UNDERLINED
		{
		border-bottom: 1px solid #7575FF;
		}
	TR.highlight TD.UNDERLINED
		{
		background-color: #EAFFEA;
		border-bottom: 1px solid #7575FF;
		cursor:pointer;
		}
	TR.nothighlight TD.UNDERLINED  
		{
		border-bottom: 1px solid #7575FF;
		}
</STYLE>
</HEAD>


<BODY 
	TEXT="Black" 
	LINK="Blue" 
	VLINK="Blue" 
	ALINK="Red"
	BGCOLOR="#FFFFFF"  
	LEFTMARGIN="10" 
	TOPMARGIN="0" 
	MARGINWIDTH="0" 
		STYLE="scrollbar-base-color: #bbbbbb; 
		scrollbar-darkshadow-color: #bbbbbb; 
		scrollbar-highlight-color: #dddddd; 
		scrollbar-shadow-color: #bbbbbb; 
		scrollbar-track-color: #eeeeee; 
		scrollbar-face-color: #ffffff;">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header Goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Dynamically retrieve the list of the different priorities										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!---  initial user position--->
<cfset useLakebaseForgetUserPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForgetUserPosition>
	<cftry>
		<cfset getUserPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetUserPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetUserPosition>
<CFQUERY NAME="getUserPosition" datasource="#application.datasource#">
	SELECT User_Positions_ID
	FROM User_Position_Holders
	WHERE User_ID = '#request.AccessStructure.user_id#' AND Deleted = 0
</CFQUERY>
</cfif>
<!--- locate those positions underneath the supplied position --->
<CFSET GP_Supplied_Position = ValueList(getUserPosition.User_Positions_ID)>

<!------<CFQUERY NAME="getUserIDs" datasource="#application.datasource#">
	SELECT 	User_ID
	FROM 	User_Position_Holders
	WHERE 	User_Positions_ID IN (#ListOfPositionsUnderMine#) AND Deleted = 0
</CFQUERY>

<CFSET eligibleUserID=ValueList(getUserIDs.User_ID)>
<CFSET eligibleUserID=ListQualify(eligibleUserID, "'", ",")>----->

<!--- Get the list of the diferent priorities --->
<CFQUERY NAME="Get_Priorities" datasource="#application.datasource#">
	Select DISTINCT	PM_Priority_ID,
					PM_Priority_Description 
	from 			PM_Priority
	where 			PM_Priority_Deleted = 0					
</CFQUERY>

<!--- Get the list of phases --->
<cfset useLakebaseForGet_Phases = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_phase")>
<cfif useLakebaseForGet_Phases>
	<cftry>
		<cfset Get_Phases = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pm_phase", {
				"pm_phase_deleted" = "eq.0",
				"select" = "pm_phase_id"
			}), "pm_phase_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Phases = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Phases>
<CFQUERY NAME="Get_Phases" datasource="#application.datasource#">
	Select		PM_Phase_ID
	From		PM_Phase
	Where		PM_Phase_Deleted	=	0
</CFQUERY>
</cfif>

<!--- Get list of status --->
<cfset useLakebaseForGet_Status = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("pm_status")>
<cfif useLakebaseForGet_Status>
	<cftry>
		<cfset Get_Status = application.oLakebase.toQuery(
			application.oLakebase.selectRows("pm_status", {
				"pm_status_deleted" = "eq.0",
				"select" = "pm_status_id"
			}), "pm_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Status = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Status>
<CFQUERY NAME="Get_Status" datasource="#application.datasource#">
	Select		PM_Status_ID
	From		PM_Status
	Where		PM_Status_Deleted	=	0
</CFQUERY>
</cfif>

<cfset cacheSpan = DateAdd("n",2,Now())  />    <!--- This is a fix for a CF Bug.  Set it to a future date or else it uses cache --->
<cfif URL.useCache EQ 1>
	<cfset cacheSpan = createodbcdatetime("#DateFormat(Now(), "mm/dd/yyyy")#") />
</cfif>

<!--- D17674 [begin] RBL 12/08/08 --->
<cfquery name="Get_Priorities_Count" datasource="#application.datasource#" cachedafter="#cacheSpan#">
    <cfswitch expression="#form.projectView#">
        <!--- owner --->
        <cfcase value="owner">
            Select 		PM_Owner_Position.User_Positions_ID AS projectViewID, 
                        User_Positions.Position_Label AS projectViewDescription,
                        0 AS PM_IsCritical, Count(PM_Item_Master.PM_Acct_Project) AS projectViewCount			
            from 		PM_Item_Master					
                        INNER JOIN PM_Owner_Position
                        ON	PM_Owner_Position.PM_Item_Master_ID = PM_Item_Master.PM_Item_Master_ID			
                        AND
                        PM_Owner_Position.User_Positions_ID IN 
                        (
                        SELECT	DISTINCT Below_User_Positions_ID
                        FROM	Positions_Below_Me
                        WHERE	User_Positions_ID IN (#GP_Supplied_Position#)
                        )
                        INNER JOIN User_Positions
                        ON	User_Positions.User_Positions_ID = PM_Owner_Position.User_Positions_ID
            where 			PM_Item_Master.PM_Deleted=0
            AND 			PM_Item_Master.PM_Hide=0		
            Group By 		PM_Owner_Position.User_Positions_ID, User_Positions.Position_Label
            Order By 		User_Positions.Position_Label
        </cfcase>
        <!--- priority --->
        <cfcase value="priority">
            Select 			PM_Priority.PM_Priority_ID AS projectViewID, 
                            Count(PM_Item_Master.PM_Acct_Project) AS projectViewCount,
                            PM_Priority.PM_Priority_Description AS projectViewDescription,
                            PM_Priority.PM_IsCritical,
                            PM_Priority.PM_Weight 
            from 			PM_Priority
                            LEFT JOIN PM_Item_Master					
                            ON (
                                (PM_Item_Master.PM_Priority_ID = PM_Priority.PM_Priority_ID) 
                                AND (PM_Item_Master.PM_Deleted=0) 
                                AND (PM_Item_Master.PM_Hide=0)
                                AND EXISTS
                                (
                                    SELECT 	TOP 1 PM_Owner_Position.PM_Item_Master_ID
                                    FROM	PM_Owner_Position
                                    WHERE
                                            PM_Owner_Position.PM_Item_Master_ID = PM_Item_Master.PM_Item_Master_ID
                                            AND
                                            PM_Owner_Position.User_Positions_ID IN 
                                            (
                                            SELECT	DISTINCT Below_User_Positions_ID
                                            FROM	Positions_Below_Me
                                            WHERE	User_Positions_ID IN (#GP_Supplied_Position#)
                                            )
                                )
                            )
            where 			PM_Priority_Deleted = 0
            Group By 		PM_Weight,PM_Priority.PM_Priority_Description, PM_Priority.PM_Priority_ID,PM_Priority.PM_IsCritical
            Order By 		PM_Weight,PM_Priority.PM_Priority_Description, PM_Priority.PM_Priority_ID
        </cfcase>
    </cfswitch>
</cfquery>
<!---
<CFQUERY NAME="Get_Priorities_Count" datasource="#application.datasource#">
	Select 			PM_Priority.PM_Priority_ID, 
					Count(PM_Item_Master.PM_Acct_Project) AS Priority_Count,
					PM_Priority.PM_Priority_Description,
					PM_Priority.PM_IsCritical,
					PM_Priority.PM_Weight 
	from 			PM_Priority
					LEFT JOIN PM_Item_Master					
					ON (
						(PM_Item_Master.PM_Priority_ID = PM_Priority.PM_Priority_ID) 
						AND (PM_Item_Master.PM_Deleted=0) 
						AND (PM_Item_Master.PM_Hide=0)
						AND EXISTS
						(
							SELECT 	TOP 1 PM_Owner_Position.PM_Item_Master_ID
							FROM	PM_Owner_Position
							WHERE
									PM_Owner_Position.PM_Item_Master_ID = PM_Item_Master.PM_Item_Master_ID
									AND
									PM_Owner_Position.User_Positions_ID IN 
									(
									SELECT	DISTINCT Below_User_Positions_ID
									FROM	Positions_Below_Me
									WHERE	User_Positions_ID IN (#GP_Supplied_Position#)
									)
						)
					)
	where 			PM_Priority_Deleted = 0
<!--- 
					AND
					PM_Item_Master.PM_Status_ID
					IN ('#valuelist(Get_Status.PM_Status_ID)#')
 --->					
	Group By 		PM_Weight,PM_Priority.PM_Priority_Description, PM_Priority.PM_Priority_ID,PM_Priority.PM_IsCritical
	Order By 		PM_Weight,PM_Priority.PM_Priority_Description, PM_Priority.PM_Priority_ID
</CFQUERY>
D17674 [end] RBL 12/08/08 --->

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<!--- <IMG SRC="/images/fill.gif" HEIGHT="5" WIDTH="1"><BR>
<BR> --->

	<script>
		function showPM(pmid) {
			
			<cfif form.projectView EQ "owner">
				finalURL = "/ReportWriter/PM/PM_display.cfm?PM_Position_ID=" + pmid + "&PM_Hide=0"
			<cfelseif form.projectView EQ "priority">
				finalURL = "/ReportWriter/PM/PM_display.cfm?PM_Priority_ID=" + pmid + "&PM_Hide=0"
			</cfif>

			window.parent.location.href=finalURL;
		}

		function refreshView() {
			window.location.href = "PM_SCORECARD.cfm?useCache=0";
			return false;
		}
    </script>
	<!--- <FIELDSET STYLE="padding:8px; width: 1%; border: 1px solid Silver;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Navy;">Projects Scorecard...</LEGEND> --->
		<TABLE border="0" CELLPADDING="0" CELLSPACING="0" width="100%" height="100%">
		<CFOUTPUT QUERY="Get_Priorities_Count">
		<!--- <TR> --->
		<tr id="nothighlight" class="nothighlight" onMouseOver="this.className='highlight'" onMouseOut="this.className='nothighlight'" ONCLICK="showPM('#projectViewID#');" <cfif Get_Priorities_Count.currentrow eq 1>style="padding-top:2px;"</cfif>>
			<TD CLASS="UNDERLINED"><CFIF Get_Profile_Settings.PM_Access EQ 1><B>#projectViewDescription#</B><CFELSE><FONT SIZE="2"><B>#projectViewDescription#</B></FONT></CFIF></TD>
			 <TD nowrap CLASS="UNDERLINED" align="right"><FONT SIZE="2" COLOR="Red"><B>#projectViewCount#</B></FONT>&nbsp;&nbsp;</TD>	
			 <TD><CFIF PM_IsCritical EQ 1><img src="../../Images/alert_icon_small.gif" alt="Critical Project" width="10" height="10" border="0"></CFIF></TD>
		</TR>
		</CFOUTPUT>
			<TR>
				<TD COLSPAN="100%" height="100%" valign="bottom" align="center">
                	<!--- D17674 [begin] RBL 12/08/08 --->
                    <form name="viewForm" action="PM_scorecard.cfm" method="post" target="_self">
                        <table width="100%" cellpadding="0" cellspacing="0" border="0">
                            <tr>
                                <td height="30" width="100%" colspan="2">&nbsp;</td>
                            </tr>
                            <tr>
                                <td align="center" valign="middle" width="50%"><input type="radio" value="priority" name="projectView" <cfif form.projectView EQ "priority">checked</cfif> onClick="viewForm.submit()">&nbsp;Priority View</td>
                                <td align="center" valign="middle" width="50%"><input type="radio" value="owner" name="projectView" <cfif form.projectView EQ "owner">checked</cfif> onClick="viewForm.submit()">&nbsp;Owner View</td>
                            </tr>
                        </table>
                    </form>
                    <br clear="all">
                    <!--- D17674 [end] RBL 12/08/08 --->
				<!--- <B><FONT COLOR="Red" SIZE="2">[</FONT>&nbsp;<FONT SIZE="2">glossary</FONT>&nbsp;<FONT COLOR="Red" SIZE="2">]</FONT></B> --->
				<B><font COLOR="red">[</font> <CFIF Get_Profile_Settings.PM_Access EQ 1><A target="_parent" HREF="/ReportWriter/PM/index.cfm">search</A><CFELSE>search</CFIF> <font COLOR="red">]</FONT></B>			
				&nbsp;
				<B><font COLOR="red">[</font> <CFIF Get_Profile_Settings.PM_Access EQ 1><A target="_parent" HREF="/ReportWriter/PM/PM_Create.cfm">create</A><CFELSE>create</CFIF> <font COLOR="red">]</FONT></B>
				&nbsp;
				<B><FONT COLOR="Red">[</FONT>&nbsp;<a href="##" ONCLICK="javascript:return refreshView();">refresh view</a>&nbsp;<FONT COLOR="Red">]</FONT></B><BR><BR>
				</TD>
			</TR>			
			<TR>
				<TD align="center" COLSPAN="100%">
				<B>
				<FONT  COLOR="Red">[</FONT>
					<CFIF Get_Profile_Settings.PM_Access EQ 1><A HREF="/ReportWriter/PM/PM_Glossary.cfm" onClick="NewWindow(this.href,'name','600','500','Yes', 'No');return false;" TITLE="Glossary">glossary</A><CFELSE>glossary</CFIF>
				<FONT COLOR="Red">]</FONT>
				</B>	
				&nbsp;
				<B><font COLOR="red">[</font> <CFIF Get_Profile_Settings.PM_Access EQ 1><A target="_parent" HREF="/ReportWriter/PM/PM_display.cfm">show all</A><CFELSE>show all</CFIF> <font COLOR="red">]</FONT></B>
				</TD
			</TR>
		</TABLE>
<!--- </FIELDSET> --->

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>