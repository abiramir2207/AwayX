<CFSET PAGE_TITLE="Deductions Home">
<p></p>
<!--- D13901 We don't populate the DD_Date_Closed field in Deductions
      with the Auto Close Procedure. This will find all Deductions
	  with a Status of 5(Auto Closed) and Null dates and set them
	  to the current date --->
<cfset useLakebaseForGetAutoClosedDeductions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGetAutoClosedDeductions>
	<cftry>
		<cfset getAutoClosedDeductions = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", { "dd_status" = "eq.5", "dd_date_closed" = "is.null", "deleted" = "eq.false", "select" = "deduction_id" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGetAutoClosedDeductions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAutoClosedDeductions>
	<cfquery name="getAutoClosedDeductions" datasource="#application.datasource#">
	 Select Deduction_ID
	 From Deductions
	 Where DD_Status = <cfqueryparam cfsqltype="cf_sql_integer" value="5" />
	 And  DD_Date_Closed is Null
	 And Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0" />
	</cfquery>
</cfif>

<cfoutput>
<cfif getAutoClosedDeductions.RecordCount gte 1>
<cfloop query="getAutoClosedDeductions">
<cfset useLakebaseForUpdateDDClosedDate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDDClosedDate>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{ "deduction_id" = "eq.#Deduction_ID#" },
			{ "dd_date_closed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss") }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForUpdateDDClosedDate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDDClosedDate>
	<cfquery name="updateDDClosedDate" datasource="#application.datasource#">
	 update Deductions
	 Set DD_Date_Closed = <cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdatetime(now())#" />
	 where Deduction_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Deduction_ID#" />
	 </cfquery>
</cfif>
</cfloop>
</cfif>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<HTML>
<HEAD>
<TITLE>Deductions Home</TITLE>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
</HEAD>

<BODY>

<div id="pageWrapper" style="width:100%;text-align:center;">

<!--- Show parent records  (Parent Deductions) by default --->
<CFPARAM NAME="chkHideParent" DEFAULT="1">
<CFPARAM NAME="chkRefreshView" DEFAULT="0">
<CFPARAM NAME="URL.ShowAll" DEFAULT="0">
<!--- Checking permissions --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", { "profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
	<CFQUERY NAME="DeductionsProfilesSettings" DATASOURCE="#application.datasource#">
		SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
	</CFQUERY>
</cfif>

<CFIF DeductionsProfilesSettings.DD_ACCESS_LEVEL EQ 0>
<CFLOCATION URL="/Manufacturers/home.cfm" ADDTOKEN="No">
</CFIF>
<!--- End Checking permissions --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<cfset useLakebaseForUnlockDDUnderThisUser = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUnlockDDUnderThisUser>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"locked_by" = "eq.#request.AccessStructure.user_ID#",
				"dd_locked_by_match_central" = "eq.0"
			},
			{
				"is_locked" = "0",
				"locked_by" = ""
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUnlockDDUnderThisUser = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUnlockDDUnderThisUser>
<CFQUERY NAME="UnlockDDUnderThisUser" DATASOURCE="#Application.Datasource#">
	UPDATE	Deductions
	SET 	Is_Locked=0,
			Locked_By=''
	WHERE	Locked_By = '#request.AccessStructure.user_ID#'
		AND DD_Locked_By_Match_Central = 0
</CFQUERY>
</cfif>

<cfset headercolor="FFE083">

<cfset useLakebaseForDefaultSC = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
<cfif useLakebaseForDefaultSC>
	<cftry>
		<cfset Default_SC = application.oLakebase.toQuery(
			application.oLakebase.selectRows("scorecard_customize", {
				"scorecard_id" = "eq.4",
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.false",
				"select" = "scorecard_grouping_id,scorecard_display_id"
			})
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDefaultSC = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDefaultSC>
	<cfset useLakebaseForDefault_SC = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
<cfif useLakebaseForDefault_SC>
	<cftry>
		<cfset Default_SC = application.oLakebase.toQuery(
			application.oLakebase.selectRows("scorecard_customize", {
				"scorecard_id" = "eq.4",
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0",
				"select" = "scorecard_grouping_id,scorecard_display_id"
			}), "scorecard_grouping_id,scorecard_display_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDefault_SC = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDefault_SC>
<CFQUERY NAME="Default_SC" DATASOURCE="#Application.Datasource#">
		SELECT 		Scorecard_Grouping_ID,
					Scorecard_Display_ID

		FROM 		Scorecard_Customize

		WHERE 		Scorecard_ID = '4' AND
					USER_ID = '#request.AccessStructure.User_ID#' AND
					Deleted = 0
	</CFQUERY>
</cfif>
</cfif>

<CFIF Default_SC.recordcount GT 0>
	<CFIF Default_SC.Scorecard_Grouping_ID EQ 1 AND Default_SC.Scorecard_Display_ID EQ 1>
		<CFSET DefaultCurSel = 2>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 1 AND Default_SC.Scorecard_Display_ID EQ 2>
		<CFSET defaultCurSel = 1>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 2 AND Default_SC.Scorecard_Display_ID EQ 1>
		<CFSET defaultCurSel = 4>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 2 AND Default_SC.Scorecard_Display_ID EQ 2>
		<CFSET defaultCurSel = 3>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 3 AND Default_SC.Scorecard_Display_ID EQ 1>
		<CFSET defaultCurSel = 6>
	<CFELSEIF Default_SC.Scorecard_Grouping_ID EQ 3 AND Default_SC.Scorecard_Display_ID EQ 2>
		<CFSET defaultCurSel = 5>
	</CFIF>
<CFELSE>
	<CFSET defaultCurSel = 1>
</CFIF>
<CFPARAM NAME="URL.CurSel" DEFAULT="#defaultCurSel#">
<STYLE>

	body,td
		{
			font-family:	Arial, Helvetica, sans-serif;
			font-size:		12px;
		}
	.sectiontitle
		{
			color:			##000000;
			font-weight:	bold;
		}
</STYLE>
<cfset iframeWidth = 1250 />
<DIV STYLE="text-align:left; height:20px; width:100%; vertical-align:top;">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
</div>
<!---Scorecard--->
<DIV STYLE="text-align:left; width:100%; height: 70px;	 left: 20px;	top: 15px;	background-color: ###headercolor#;" ID="scorecard_header" >
<IFRAME name="scorecard_Filter" width="100%" height="60" src="index1.cfm?CurSel=#URL.CurSel#&chkHideParent=#chkHideParent#" border="0" frameborder="0"  MARGINWIDTH="0" MARGINHEIGHT="0"></IFRAME>
</DIV>
<CFOUTPUT>
<DIV STYLE="width:100%;	height: 242px; left: 20px;	top: 70px;	background-color: ##FFFFEA" ID="scorecard_body">

<!--- Tech Note 14337, 14424 correction by RBL 01/23/08 [begin] (6 options in 1 instance - else clauses made all into a switch) --->
<cfswitch expression="#URL.CurSel#">
	<cfcase value="1">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=age&ScorecardToShow_basedon=count&CurSel=1&chkHideParent=1">
		<cfelse>
			<cfset SRCURL="ScorecardToShow=age&ScorecardToShow_basedon=count&CurSel=1&chkHideParent=0">
		</cfif>
	</cfcase>
	<cfcase value="2">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=age&ScorecardToShow_basedon=dollar&CurSel=2&chkHideParent=1">
		<cfelse>
			<cfset SRCURL="ScorecardToShow=age&ScorecardToShow_basedon=dollar&CurSel=2&chkHideParent=0">
		</cfif>
	</cfcase>
	<cfcase value="3">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=action&ScorecardToShow_basedon=count&CurSel=3&chkHideParent=1">
		<cfelse>
			<cfset SRCURL="ScorecardToShow=action&ScorecardToShow_basedon=count&CurSel=3&chkHideParent=0">
		</cfif>
	</cfcase>
	<cfcase value="4">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=action&ScorecardToShow_basedon=dollar&CurSel=4&chkHideParent=1">
		<cfelse>
			<cfset SRCURL="ScorecardToShow=action&ScorecardToShow_basedon=dollar&CurSel=4&chkHideParent=0">
		</cfif>
	</cfcase>
	<cfcase value="5">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=class&ScorecardToShow_basedon=count&CurSel=5&chkHideParent=1">
		<cfelse>
			<cfset SRCURL="ScorecardToShow=class&ScorecardToShow_basedon=count&CurSel=5&chkHideParent=0">
		</cfif>
	</cfcase>
	<cfcase value="6">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=class&ScorecardToShow_basedon=dollar&CurSel=6&chkHideParent=1">
		<cfelse>
			<cfset SRCURL="ScorecardToShow=class&ScorecardToShow_basedon=dollar&CurSel=6&chkHideParent=0">
		</cfif>
	</cfcase>
</cfswitch>
<!--- Tech Note 14337, 14424 correction by RBL 01/23/08 [end] (6 options in 1 instance - else clauses made all into a switch) --->

<!--- Tech Note 14337, 14424 fix by RBL 01/23/08 comment [begin] <cfif URL.CurSel EQ 1>
	<cfset SRCURL="ScorecardToShow=age&ScorecardToShow_basedon=count&CurSel=1">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=age&ScorecardToShow_basedon=count&CurSel=1&chkHideParent=1">
		<cfelse>

		</cfif>
<cfelseif URL.CurSel EQ 2>
	<cfset SRCURL="ScorecardToShow=age&ScorecardToShow_basedon=dollar&CurSel=2">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=age&ScorecardToShow_basedon=dollar&CurSel=2&chkHideParent=1">
		<cfelse>

		</cfif>
<cfelseif URL.CurSel EQ 3>
	<cfset SRCURL="ScorecardToShow=action&ScorecardToShow_basedon=count&CurSel=3">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=action&ScorecardToShow_basedon=count&CurSel=3&chkHideParent=1">
		<cfelse>

		</cfif>
<cfelseif URL.CurSel EQ 4>
	<cfset SRCURL="ScorecardToShow=action&ScorecardToShow_basedon=dollar&CurSel=4">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=action&ScorecardToShow_basedon=dollar&CurSel=4&chkHideParent=1">
		<cfelse>

		</cfif>
<cfelseif URL.CurSel EQ 5>
	<cfset SRCURL="ScorecardToShow=class&ScorecardToShow_basedon=count&CurSel=5">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=class&ScorecardToShow_basedon=count&CurSel=5&chkHideParent=1">
		<cfelse>

		</cfif>
<cfelseif URL.CurSel EQ 6>
	<cfset SRCURL="ScorecardToShow=class&ScorecardToShow_basedon=dollar&CurSel=6">
		<cfif chkHideParent>
			<cfset SRCURL="ScorecardToShow=class&ScorecardToShow_basedon=dollar&CurSel=6&chkHideParent=1">
		<cfelse>

		</cfif>
</cfif> Tech Note 14337, 14424 fix by RBL 01/23/08 comment [end] --->

<cfset SRCURL="#SRCURL#&chkRefreshView=#chkRefreshView#">
<cfset JustVariables = SRCURL>
<cfset SRCURL= "/deductions/scorecard.cfm?#SRCURL#">

<IFRAME name="deduction_scorecard" width="100%" height="242" src="#SRCURL#" border="0" frameborder="4" style="border:0;"></IFRAME>
</DIV>
</CFOUTPUT>
<!---Deduction search--->
<DIV STYLE="display:flex; height:24px; padding-top:3px; background-color: ###headercolor#; align-items:center;" ID="search_header" CLASS="sectiontitle">
	<div style="padding-left:10px;">
		Search Deductions
	</div>
<!---26487 - 2011-mar-9 chrisn: added deduction type--->
	<div style="margin-left:580px;">
		<a href="/deductions/search_screens/Ded_Advanced_Search.cfm"> #application.util.string.linkFormat("advanced search")# </a> &nbsp;
		<a href="/deductions/scorecard/index.cfm?SC_Shr_Ship_To=&amp;SC_Broker_Shard=&amp;Show_Status=1&amp;Program_Agree_Status_ID="> #application.util.string.linkFormat("scorecard")# </a>

		<!--- <FONT COLOR="Red" SIZE="2" class="indent01">[ </FONT><a href="/deductions/search_screens/Ded_Advanced_Search.cfm">advanced search</a><FONT COLOR="Red" SIZE="2"> ]</FONT>
		<FONT COLOR="Red" SIZE="2">[ </FONT><a href="/deductions/scorecard/index.cfm" target="_parent">scorecard</a><FONT COLOR="Red" SIZE="2"> ]</FONT><br/> --->
	</div>
</DIV>

<DIV STYLE="width:100%;	left: 20px;	top: 365px;	background-color: ##FFFFEA" ID="search_body">
<IFRAME name="I4" width="100%"  src="/deductions/search_screens/deduction_search.cfm?ID=#CreateUUID()#" border="0" frameborder="0"></IFRAME>
</DIV>

</div>

</BODY>
</HTML>
<form name="Refresh" method="post" action="/deductions/index.cfm?#JustVariables#">
</form>
</cfoutput>