<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM NAME="URL.SC_Shr_Ship_To" DEFAULT="">
<CFPARAM NAME="URL.SC_Broker_Shard" DEFAULT="">
<CFPARAM NAME="URL.chkHideParent" DEFAULT="0">
<CFPARAM NAME="URL.chkRefreshView" DEFAULT="0">

<cfset useLakebaseForGet_SC_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard")>
<cfif useLakebaseForGet_SC_ID>
	<cftry>
		<cfset Get_SC_ID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("scorecard", {
				"scorecard_name" = "eq.Deductions"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_SC_ID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_SC_ID>
<CFQUERY NAME="Get_SC_ID" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Scorecard WHERE Scorecard_Name = 'Deductions'
</CFQUERY>
</cfif>

<cfset useLakebaseForGet_SC_GP_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_grouping")>
<cfif useLakebaseForGet_SC_GP_ID>
	<cftry>
		<cfset Get_SC_GP_ID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("scorecard_grouping", {
				"scorecard_grouping_name" = "eq.#URL.ScorecardToShow#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_SC_GP_ID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_SC_GP_ID>
<CFQUERY NAME="Get_SC_GP_ID" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Scorecard_Grouping WHERE Scorecard_Grouping_Name = '#URL.ScorecardToShow#'
</CFQUERY>
</cfif>

<cfset useLakebaseForGet_Disp_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_display")>
<cfif useLakebaseForGet_Disp_ID>
	<cftry>
		<cfset Get_Disp_ID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("scorecard_display", {
				"scorecard_display_name" = "eq.#URL.ScorecardToShow_basedon#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Disp_ID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Disp_ID>
<CFQUERY NAME="Get_Disp_ID" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Scorecard_Display WHERE Scorecard_Display_Name = '#URL.ScorecardToShow_basedon#'
</CFQUERY>
</cfif>

<cfset useLakebaseForCheckExist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
<cfif useLakebaseForCheckExist>
	<cftry>
		<cfset Check_Exist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("scorecard_customize", { "user_id" = "eq.#request.AccessStructure.User_ID#", "scorecard_id" = "eq.#Get_SC_ID.Scorecard_ID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCheckExist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckExist>
	<cfset useLakebaseForCheck_Exist = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
<cfif useLakebaseForCheck_Exist>
	<cftry>
		<cfset Check_Exist = application.oLakebase.toQuery(
			application.oLakebase.selectRows("scorecard_customize", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"scorecard_id" = "eq.#Get_SC_ID.Scorecard_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_Exist = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_Exist>
<CFQUERY NAME="Check_Exist" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Scorecard_Customize WHERE User_ID = '#request.AccessStructure.User_ID#' AND Scorecard_ID = '#Get_SC_ID.Scorecard_ID#'
	</CFQUERY>
</cfif>
</cfif>

<CFIF Check_Exist.recordcount GT 0>
	<cfset useLakebaseForUpdateData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
	<cfif useLakebaseForUpdateData>
		<cftry>
			<cfset application.oLakebase.updateRows("scorecard_customize",
				{ "scorecard_customize_id" = "eq.#Check_Exist.Scorecard_Customize_ID#", "deleted" = "eq.false" },
				{
					"scorecard_grouping_id" = Get_SC_GP_ID.Scorecard_Grouping_ID,
					"scorecard_display_id" = Get_Disp_ID.Scorecard_Display_ID,
					"shr_ship_to" = URL.SC_Shr_Ship_To,
					"broker_shard" = URL.SC_Broker_Shard,
					"chk_hide_parent" = URL.chkHideParent,
					"chk_refresh_view" = URL.chkRefreshView
				}
			)>
			<cfcatch type="any">
				<cfset useLakebaseForUpdateData = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateData>
		<cfset useLakebaseForUpdate_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
<cfif useLakebaseForUpdate_Data>
	<cftry>
		<cfset application.oLakebase.updateRows("scorecard_customize",
			{
				"scorecard_customize_id" = "eq.#Check_Exist.Scorecard_Customize_ID#",
				"deleted" = "eq.0"
			},
			{
				"scorecard_grouping_id" = "#Get_SC_GP_ID.Scorecard_Grouping_ID#",
				"scorecard_display_id" = "#Get_Disp_ID.Scorecard_Display_ID#",
				"shr_ship_to" = "#URL.SC_Shr_Ship_To#",
				"broker_shard" = "#URL.SC_Broker_Shard#",
				"chk_hide_parent" = "#URL.chkHideParent#",
				"chk_refresh_view" = "#URL.chkRefreshView#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Data = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Data>
<CFQUERY NAME="Update_Data" DATASOURCE="#Application.Datasource#">
			UPDATE Scorecard_Customize
			SET		Scorecard_Grouping_ID = '#Get_SC_GP_ID.Scorecard_Grouping_ID#',
					Scorecard_Display_ID = '#Get_Disp_ID.Scorecard_Display_ID#',
					Shr_Ship_To	=	'#URL.SC_Shr_Ship_To#',
					Broker_Shard = '#URL.SC_Broker_Shard#',
					chk_Hide_Parent = '#URL.chkHideParent#',
					chk_Refresh_View = '#URL.chkRefreshView#'

			WHERE Scorecard_Customize_ID = '#Check_Exist.Scorecard_Customize_ID#' AND Deleted=0
		</CFQUERY>
</cfif>
	</cfif>
<CFELSE>
	<cfset useLakebaseForInsertData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("scorecard_customize")>
	<cfif useLakebaseForInsertData>
		<cftry>
			<cfset application.oLakebase.insertRow("scorecard_customize", {
				"user_id" = request.AccessStructure.User_ID,
				"scorecard_id" = Get_SC_ID.Scorecard_ID,
				"scorecard_display_id" = Get_Disp_ID.Scorecard_Display_ID,
				"scorecard_grouping_id" = Get_SC_GP_ID.Scorecard_Grouping_ID,
				"shr_ship_to" = URL.SC_Shr_Ship_To,
				"broker_shard" = URL.SC_Broker_Shard,
				"chk_hide_parent" = URL.chkHideParent,
				"chk_refresh_view" = URL.chkRefreshView,
				"deleted" = false
			})>
			<cfcatch type="any">
				<cfset useLakebaseForInsertData = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForInsertData>
		<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
			INSERT INTO
			Scorecard_Customize	(	User_ID,
									Scorecard_ID,
									Scorecard_Display_ID,
									Scorecard_Grouping_ID,
									Shr_Ship_To,
									Broker_Shard,
									chk_Hide_Parent,
									chk_Refresh_View	)

			VALUES				(	'#request.AccessStructure.User_ID#',
									'#Get_SC_ID.Scorecard_ID#',
									'#Get_Disp_ID.Scorecard_Display_ID#',
									'#Get_SC_GP_ID.Scorecard_Grouping_ID#',
									'#URL.SC_Shr_Ship_To#',
									'#URL.SC_Broker_Shard#',
									'#URL.chkHideParent#',
									'#URL.chkRefreshView#'	)
		</CFQUERY>
	</cfif>
</CFIF>

<SCRIPT language="JavaScript">
function BackToIndex1()
{
	window.location.href="/deductions/index1.cfm?<CFOUTPUT>CurSel=#URL.CurSel#&chkHideParent=#URL.chkHideParent#&chkRefreshView=#chkRefreshView#&Selected_Distributor_Num=#URL.SC_Shr_Ship_To#&Selected_Broker_Num=#URL.SC_Broker_Shard#</CFOUTPUT>";
}
BackToIndex1()
</SCRIPT>

<!--- <CFABORT> --->

<!--- <CFLOCATION URL="/deductions/Index.cfm?CurSel=#URL.CurSel#&Selected_Distributor_Num=#URL.SC_Shr_Ship_To#&Selected_Broker_Num=#URL.SC_Broker_Shard#" ADDTOKEN="No"> --->
<!--- ScorecardToShow=#ScorecardToShow#&ScorecardToShow_basedon=#ScorecardToShow_basedon#" --->
<!--- <SCRIPT language="JavaScript">
function relocate()
{
	
}
</SCRIPT> --->
</body>
</html>
