<cfsetting showDebugOutput="No">
<!DOCTYPE HTML>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<CFPARAM name="URL.useCache" default="#appSettings.getBillbackScorecardCache()#">
<html>
<head>
</head>


<body>
<style>
	table.normal-home td {
		font-size:13px;
		padding:0 5px;
	}
	table.normal-home td.count {
		font-weight: bold;
		color: red;
	}
	TD.UNDERLINED
		{
		border-bottom: 1px dotted #7575FF;
		}
	TR.highlight TD.UNDERLINED
		{
		background-color: #E5E5E5;
		border-bottom: 1px dotted #7575FF;
		cursor:pointer;
		}
	TR.nothighlight TD.UNDERLINED
		{
		border-bottom: 1px dotted #7575FF;
		}
	BODY
		{
		margin-top: 5px;
		margin-left: 10px;
		margin-right: 10px;
		}
	tr {
		height: 20px;
		}
	.subtle
		{
		color:#7c7c7c;
		font-size:11px;
		margin-bottom: 3px;
		}
	.scorecardFooter
		{
			position: absolute;
			text-align: center;
			left: 0;
			right: 0;
			margin: auto;
			bottom: 6px;
		}
</style>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Header Goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->




<!---
Document Name:	bb_scorecard_home.cfm
Directory:		/scorecard
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	December 11, 2002

This is the brief homepage description of the scorecard for the billbacks.

Data from include of \settings\Access_Rights\approval_tree\get_positions_underneath_supplied_position.cfm:

*	#GP_Position_List_From_My_Position_Down# -- shows the position list from the position of the user logging in to access this information and below.

--->

<script>
	function refreshView() {
		window.location.href = "scorecard_home.cfm?useCache=0";
		return false;
	}

	function getParentObject(thisObj, tagName)
		{
			if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
			{
				return thisObj;
			}
			else if(thisObj.tagName.toLowerCase() == "body")
			{
				return null;
			}
			else
			{
				return getParentObject(thisObj.parentElement, tagName);
			}
		}
	function showSCBFx(BBStatusID) {
		finalURL = "/billbacks/2020/search_billbacks.cfm?status="+BBStatusID
		window.parent.location.href=finalURL;
		return false;
	}

	function showSCB(Section,RFA_Sub_Sction) {
		//finalURL = "/billbacks/scorecard/scorecard_detail.cfm?SECTION_TO_OPEN=" + Section
		/*if (RFA_Sub_Sction != 0)
		{*/
			finalURL = "/billbacks/scorecard/scorecard_main.cfm?SECTION_TO_OPEN=" + Section +"&Program_Agree_Status_ID="+RFA_Sub_Sction
		/*}
		else
		{
			finalURL = "/billbacks/scorecard/scorecard_main.cfm?SECTION_TO_OPEN=" + Section
		}*/
		//document.location.href = finalURL
		window.parent.location.href=finalURL;
		return false;
	}

</script>
<cfinclude template="/get_access_profile.cfm">


<!---Gets user permissions--->
<CFINCLUDE TEMPLATE="/billbacks/Billback_Access_Permission.cfm">

<CFSILENT>
<CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1>
	<CFSET Auth_Sequence_Order = 0>
	<CFSET Auth_Sequence_ID = 0>
	<CFQUERY NAME="AuthoritySeq" DATASOURCE="#Application.Datasource#">
		SELECT Authority_Sequence_Order,Authority_Sequence_ID FROM Authority_Sequence WHERE Authority_Sequence_ID = (SELECT Authority_Sequence_ID FROM _Users WHERE User_ID = '#request.AccessStructure.User_ID#')
	</CFQUERY>
	<CFIF AuthoritySeq.recordCount GT 0>
		<CFSET Auth_Sequence_Order = AuthoritySeq.Authority_Sequence_Order>
		<CFSET Auth_Sequence_ID = AuthoritySeq.Authority_Sequence_ID>
	</CFIF>
</CFIF>

<cfset UserPositionList = CreateObject("component", "components.user.UserManager").getPositionId(request.AccessStructure.user_id, 0, 1) /><br>

<cfset scorecardTime = Now() />
<cfset cacheSpan = DateAdd("n",2,Now())  />    <!--- This is a fix for a CF Bug.  Set it to a future date or else it uses cache --->
<cfif URL.useCache EQ 1>
	<cfset cacheSpan = createodbcdatetime("#DateFormat(Now(), "mm/dd/yyyy")#") /> <!--- this creates a data with 0 hour,minute, seconds.... midnight so the cache gets used all day --->
</cfif>

<cfset var_apply_template_profile_filter = 1 />

<cfset businessSegmentsMgr = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfset businessSegmentSettings = businessSegmentsMgr.getEnabled() />
<cfset businessSegmentsOn = businessSegmentSettings.Display_Segment_In_Billbacks>

<CFQUERY NAME="delete_tmp_tables" DATASOURCE="#application.datasource#">
	if object_id('tempdb..##tmp_billack_pre_filter') is not null
	drop table ##tmp_billack_pre_filter

	if object_id('tempdb..##tmp_billacks_cannot_see') is not null
	drop table ##tmp_billacks_cannot_see

	if object_id('tempdb..##tmp_billack_templates') is not null
	drop table ##tmp_billack_templates
</CFQUERY>

<!------ get all status count ----->
<CFQUERY NAME="get_All_Status_Count" DATASOURCE="#application.datasource#" cachedafter="#cacheSpan#">
	set transaction isolation level read uncommitted
	<cfif UserIsAnalyst EQ 0>
	#PreserveSingleQuotes(AllowBillbackIDs)#
	<cfelse>
	#PreserveSingleQuotes(AllowAnalystIds)#
	</cfif>

		<cfif var_apply_template_profile_filter>

			<cfset var_forbidType = appSettings.getForbidAllowProfilesInTemplates() />

			DECLARE @Profile_Forbidden_Template table
			(
			Template_ID   int          NOT NULL,
			Forbid_Access_Type int          NOT NULL
			)
			INSERT INTO @Profile_Forbidden_Template (Template_ID, Forbid_Access_Type)
			select 	distinct template_id, Forbid_Access_Type
			from 	Profile_Forbidden_Template
			where 	Deleted = 0
			AND Forbid_Type = #var_forbidType#
			AND Forbid_Access_Type = 1
			AND profile_id = #Get_Profile_Settings.Profiles_ID#

			DECLARE @Profile_Forbidden_Template_BB_Approve table
			(
				Template_ID   int          NOT NULL PRIMARY KEY,
				Forbid_Access_Type int          NOT NULL
			)
			INSERT INTO @Profile_Forbidden_Template_BB_Approve (Template_ID, Forbid_Access_Type)
			select 	distinct template_id, Forbid_Access_Type
			from 	Profile_Forbidden_Template
			where 	Deleted = 0
			AND Forbid_Type = #var_forbidType#
			AND Forbid_Access_Type = 4
			AND profile_id = #Get_Profile_Settings.Profiles_ID#


			IF OBJECT_ID('tempdb..##tmp_billack_pre_filter') IS NOT NULL
					DROP TABLE ##tmp_billack_pre_filter

			SELECT 	Billback_ID
			INTO	##tmp_billack_pre_filter
			FROM	Billback
			WHERE	Deleted = 0

			<!--- find the distinct templates in each billback --->
			SELECT 	DISTINCT Billback_Program.Billback_ID, Contract_Main.ProgramType_ID
			INTO	##tmp_billack_templates
			              FROM 	##tmp_billack_pre_filter
			INNER JOIN Billback_Program
			ON	##tmp_billack_pre_filter.Billback_ID = Billback_Program.Billback_ID
			AND	Billback_Program.Deleted = 0
			              INNER JOIN Contract_Main
			              ON 	Billback_Program.Program_ID = Contract_Main.Contract_Main_ID

			<!--- find the billbacks with templates that the current user should not see --->
			SELECT	Billback_ID
			INTO	##tmp_billacks_cannot_see
			FROM	##tmp_billack_templates
			WHERE	ProgramType_ID
			<cfif var_forbidType EQ 0>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
			IN (select Template_ID from @Profile_Forbidden_Template)

			IF OBJECT_ID('tempdb..##tmp_billacks_cannot_approve') IS NOT NULL
	    	DROP TABLE ##tmp_billacks_cannot_approve
			CREATE table ##tmp_billacks_cannot_approve
			(
				Billback_ID uniqueidentifier NOT NULL PRIMARY KEY
			)
			INSERT INTO ##tmp_billacks_cannot_approve (Billback_ID)
			SELECT     DISTINCT Billback.Billback_ID
			FROM Billback
			INNER JOIN Billback_Program
			ON    Billback.Billback_ID = Billback_Program.Billback_ID
			AND   Billback_Program.Deleted = 0
			INNER JOIN Contract_Main
			ON      Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
			WHERE Billback.Deleted = 0
			and   ProgramType_ID
			<cfif var_forbidType EQ 0>not </cfif><!------ forbit type=1, forbid, 0=allow ----->
			IN (select Template_ID from @Profile_Forbidden_Template_BB_Approve)

			drop table ##tmp_billack_templates

		</cfif>

	SELECT 	Billback_Status.Billback_Status_ID,
			<CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1>
				CASE
				WHEN Billback_Status.Billback_Status_ID = 2 THEN
					Program_Agree_Status.Program_Agree_Status_Desc
				ELSE
					Billback_Status.BB_Status_Description
				END BB_Status_Description,
			<CFELSE>
				Billback_Status.BB_Status_Description,
			</CFIF>
			count(Billback.BB_Code) AS This_Status_Count,
			ISNULL(Program_Agree_Status.Program_Agree_Status_ID, 0) Program_Agree_Status_ID

	FROM 	Billback_Status
			LEFT JOIN Program_Agree_Status
			ON
			1=2
			<cfif Get_Profile_Settings.BB_RFA_Agreed EQ 1>
			OR
			Billback_Status.Billback_Status_ID = 2
			</cfif>
			LEFT JOIN Billback
			ON
			Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
			AND Billback.Deleted = 0
			<cfif var_apply_template_profile_filter>
			AND Billback.Billback_ID NOT IN (select Billback_ID FROM ##tmp_billacks_cannot_see)
			</cfif>
		<cfif Get_Profile_Settings.Program_Scorecard_Restrict_Created_By>
				<!--- If the below profile settings is on, then the user should only be allowed to see programs
			that have him/her as an RSP OR where the program creator's RSP has the user number same as
			this user's User number
		--->
		AND NOT EXISTS
		(
			<cfset programScorecardRestrictCreatedByUserId = request.AccessStructure.user_id>
			<cfset qUserNumber = "" />
			<cfif appSettings.getUserNumberRestrict()>
				<cfset qUser = CreateObject("component", "components.user.UserManager").getUser(programScorecardRestrictCreatedByUserId) />
				<cfset qUserNumber = qUser.User_Number />
			</cfif>
			SELECT Billback_ID
			FROM Billback_Program
			INNER JOIN Contract_Main
			ON Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
			LEFT JOIN _Users responsibleSalesPerson
			ON 	responsibleSalesPerson.User_ID = Contract_Main.Responsible_User_ID
			AND	responsibleSalesPerson.Deleted = 0
			WHERE Billback_Program.Billback_ID = Billback.Billback_ID
			AND Billback_Program.Deleted = 0
			AND(
			Isnull(rtrim(ltrim(Contract_Main.Responsible_User_ID)),'') != '#programScorecardRestrictCreatedByUserId#'
				<cfif Len(qUserNumber) GT 0>
			AND Isnull(rtrim(ltrim(responsibleSalesPerson.User_Number)),'') != '#qUserNumber#'
				</cfif>
			)
		)
		</cfif>

			<cfif HQUser IS NOT 1 OR UserIsAnalyst EQ 1><!--- if user is an analyst or not HQ --->
			AND
			(
				Billback.BB_Creator_ID = '#request.AccessStructure.User_ID#'
				<cfif UserIsAnalyst EQ 0>
					OR Billback.BB_Creator_User_Position_ID IN (#PreserveSingleQuotes(UserPositionList)#)
					<cfif listlen(BillbackIDs) GT 0>
					OR Billback.Billback_ID IN (#preservesinglequotes(BillBackIDs)#)
					</cfif>
				<cfelse><!------ If billback analyst do not look at the position tree, use the analyst logic alone ----->
					<cfif AnalystList NEQ "">
					OR	Billback.Analyst_User_ID IN (#PreserveSingleQuotes(AnalystList)#)
					OR	Billback.BB_Creator_ID IN (#PreserveSingleQuotes(AnalystList)#)
					</cfif>
				</cfif>
			)
			</cfif>
			AND
			<CFIF Get_Profile_Settings.BB_RFA_Agreed EQ 1>
				(
					Billback_Status.Billback_Status_ID <> 2
					OR
					----------- Under Review Starts
					( Billback_Status.Billback_Status_ID = 2 AND Program_Agree_Status.Program_Agree_Status_ID = 1 AND
					  Not Exists
					 	(SELECT * FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
					  AND
						(
							#Get_Profile_Settings.BB_Approve# = 0
							<cfif var_apply_template_profile_filter><!--- User cannot approve this billback --->
			            		OR Billback.Billback_ID IN (select Billback_ID FROM ##tmp_billacks_cannot_approve)
			            	</cfif>

							OR

							((	SELECT 	Top 1 User_positions_ID
									FROM 	BillbackApprovablePositions
									WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
											NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR

														Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
																						FROM 		BB_Agreed_Info
																						INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
																						WHERE 		Billback_ID = Billback.Billback_ID
																						AND			BB_Agreed_Info.Deleted = 0)
													) AND
													User_positions_ID IN (		SELECT 	DISTINCT User_position_ID
																				FROM 	BB_Agreed_Info
																				WHERE 	Billback_ID = Billback.Billback_ID AND
																				Deleted = 0)
												)
								ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
								) NOT IN (#PreserveSingleQuotes(UserPositionList)#))
							OR

							(	ISNULL((	SELECT 	Top 1 Authority_Sequence_Order
											FROM 	BillbackApprovablePositions
											WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
													NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
																Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
																								FROM	 	BB_Agreed_Info
																								INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
																								WHERE 		Billback_ID = Billback.Billback_ID
																								AND			BB_Agreed_Info.Deleted = 0)
															) AND
															User_positions_ID IN (		SELECT 	DISTINCT User_position_ID
																						FROM 	BB_Agreed_Info
																						WHERE 	Billback_ID = Billback.Billback_ID AND
																						Deleted = 0)
														)
											ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
										),0) <> '#Auth_Sequence_Order#')
						)
					)

					OR
					------------ Pending Approval starts
					( Billback_Status.Billback_Status_ID = 2 AND Program_Agree_Status.Program_Agree_Status_ID = 2 AND
					  Not Exists
					 	(SELECT * FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
					  AND
						(
							#Get_Profile_Settings.BB_Approve# = 1
							<cfif var_apply_template_profile_filter><!--- User can approve this billback --->
			            		AND Billback.Billback_ID NOT IN (select Billback_ID FROM ##tmp_billacks_cannot_approve)
			            	</cfif>

							AND

							((	SELECT 	Top 1 User_positions_ID
									FROM 	BillbackApprovablePositions
									WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
											NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
														Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
																						FROM 		BB_Agreed_Info
																						INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
																						WHERE 		Billback_ID = Billback.Billback_ID
																						AND			BB_Agreed_Info.Deleted = 0)
													) AND
													User_positions_ID IN (	SELECT 	DISTINCT User_position_ID
																			FROM 	BB_Agreed_Info
																			WHERE 	Billback_ID = Billback.Billback_ID AND
																					Deleted = 0)
												)
								ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
								) IN (#PreserveSingleQuotes(UserPositionList)#))
							AND

							(	ISNULL((	SELECT 	Top 1 Authority_Sequence_Order
											FROM 	BillbackApprovablePositions
											WHERE 	BillbackApprovablePositions.Billback_ID = Billback.Billback_ID AND
													NOT (	(	ISNULL(Authority_Sequence_Order, 0) = 0 OR
																Authority_Sequence_Order IN (	SELECT 		ISNULL(Authority_Sequence_ORDER,0)
																								FROM 		BB_Agreed_Info
																								INNER JOIN 	Authority_Sequence ON Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
																								WHERE 		Billback_ID = Billback.Billback_ID
																								AND			BB_Agreed_Info.Deleted = 0)
															) AND
															User_positions_ID IN (	SELECT 	DISTINCT User_position_ID
																					FROM 	BB_Agreed_Info
																					WHERE 	Billback_ID = Billback.Billback_ID AND
																							Deleted = 0)
														)
											ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
										),0) = '#Auth_Sequence_Order#'
							)
						)
					)
					OR
					--------- Agreed starts
					(Billback_Status.Billback_Status_ID = 2 AND Program_Agree_Status.Program_Agree_Status_ID = 3 AND
					  Exists
					  (SELECT * FROM BB_Agreed_Info WHERE Deleted = 0 AND Billback_ID = Billback.Billback_ID AND User_position_ID IN (#PreserveSingleQuotes(UserPositionList)#) AND Authority_Sequence_ID = '#Auth_Sequence_ID#')
					)
				)
			<CFELSE>
			1=1
			</CFIF>

	WHERE 	<CFIF LCase(application.returned_customer_setting.Show_Billback_Payment_Tab) EQ 1>
				<CFIF application.returned_customer_setting.Upload_GL_Code NEQ 1>
					Billback_Status.Billback_Status_ID NOT IN (5,6)
				<CFELSE>
					Billback_Status.Billback_Status_ID IN (1,2,3,4,6,7,8)
				</CFIF>
			<CFELSE>
				Billback_Status.Billback_Status_ID NOT IN  (4,5,6)
			</CFIF><!--- DEV NOTE D10619: Do not display the billback status of PAID on the home page, use the view paid link given below --->

			<!--- 114068: Billback authority not checking Segment / Anand Rao / 29-Mar-2022 --->
			<cfif (businessSegmentsOn AND structKeyExists(request.AccessStructure, "User_Business_Segments") and len(request.AccessStructure.User_Business_Segments))>
            	AND   ( isnull(( select top 1 Business_Segment_ID from contract_main where deleted = 0 and contract_main_id in (select top 1 program_id from billback_program where 
					billback_program.billback_id = billback.billback_id)),0) IN (#request.AccessStructure.User_Business_Segments#))
			</cfif>

	GROUP BY Billback_Status.Billback_Status_ID, ISNULL(Program_Agree_Status.Program_Agree_Status_ID, 0), Billback_Status.BB_Status_Description, Program_Agree_Status.Program_Agree_Status_Desc, Status_Order_Number
	ORDER BY Status_Order_Number

	<cfif var_apply_template_profile_filter>
	drop table ##tmp_billack_pre_filter
	drop table ##tmp_billacks_cannot_see
	</cfif>
</CFQUERY>
<CFQUERY NAME="getManualRejectProfileCount" DATASOURCE="#application.datasource#" cachedafter="#cacheSpan#">
	SELECT 1
	FROM Profiles_Settings
	WHERE Manual_Reject_Billback = 1
	AND Deleted = 0
</CFQUERY>
</CFSILENT>
	<TABLE CLASS="normal-home" border="0" CELLPADDING="0" CELLSPACING="0" width="100%" HEIGHT="96%" valign="top">
		<CFOUTPUT QUERY="get_All_Status_Count">

		<cfset BB_Status_ID = Billback_Status_ID>

		<!--- 201 is Agreed, 202 is pending Approval and 203 is Under Review --->
		<cfif BB_Status_Description eq "Agreed">
		<cfset BB_Status_ID = 201>
		<cfelseif  BB_Status_Description eq "Pending Approval">
		<cfset BB_Status_ID = 202>
		<cfelseif  BB_Status_Description eq "Under Review">
		<cfset BB_Status_ID = 203>
		</cfif>
<!---
	31505: App setting for Flex BB Module/Anand Rao/24-Apr-2012
	Made changes in the code to go to flex/CF based on the BillbackModuleType appsetting.
--->
		<cfset showManualReject = 1>
		<cfif BB_Status_Description EQ 'Manual Reject' AND getManualRejectProfileCount.recordcount EQ 0>
			<cfset showManualReject = 0>
		</cfif>
		<TR id="nothighlight" class="nothighlight" onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'"
			<cfif appsettings.getBillbackModuleType() EQ 1>ONCLICK="showSCB(#Billback_Status_ID#,#Program_Agree_Status_ID#);"<cfelse>ONCLICK="showSCBFx('#BB_Status_ID#');"</cfif>
			<cfif get_All_Status_Count.currentrow eq 1>style="padding-top:2px;"</cfif>>
			<cfif showManualReject>
				<TD WIDTH="80%" CLASS="UNDERLINED">#BB_Status_Description#</TD>
				<TD align="right" CLASS="UNDERLINED count">#numberFormat(This_Status_Count, ",9")#</TD>
			</cfif>
		</TR>
		</CFOUTPUT>
	</TABLE>
	
	<cfoutput>
	<div class="scorecardFooter">
		<div class="subtle">
			Last refreshed #DateFormat(Now(), "d mmm yyyy")# <cfif URL.useCache neq 1>#TimeFormat(scorecardTime, "h:mm tt")#</cfif>
		</div>
		<!--- Two buttons at bottom --->
		<!---- view paid ---->
		<cfset onclick = ( appsettings.getBillbackModuleType() EQ 2
							? "return showSCBFx(5);"
							: "return showSCB(5, 0)" )>
		<a href="##" onclick="#onclick#" style="margin-right:30px;">#application.util.string.linkFormat("view paid")#</a>
		<a href="##" onclick="return refreshView();">#application.util.string.linkformat("refresh view")#</a>
	</div>
	</cfoutput>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Footer Goes here --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfset request.focusHiLightOff = true>
</BODY>
</HTML>



