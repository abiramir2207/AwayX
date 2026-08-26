<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM NAME="FORM.PerReassign" DEFAULT="">

<CFSET Unavailable = "">
<CFSET UnSuccessful = "">
<CFLOOP LIST="#FORM.Selected_Billback_ID#" INDEX="Item">
	<cfset useLakebaseForCheckLock = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForCheckLock>
	<cftry>
		<cfset CheckLock = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_allied", {
				"billback_id" = "eq.#Item#",
				"select" = "bb_is_locked"
			}), "bb_is_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckLock = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckLock>
<cfquery NAME="CheckLock" DATASOURCE="#Application.Datasource#">
		SELECT BB_Is_Locked FROM Billback_Allied WHERE Billback_ID = '#Item#'
	</cfquery>
</cfif>

	<CFIF CheckLock.BB_Is_Locked EQ 0>
		<cfset useLakebaseForLockBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForLockBillback>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_allied",
			{
				"billback_id" = "eq.#Item#"
			},
			{
				"bb_is_locked" = "1",
				"bb_locked_by_user_id" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLockBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLockBillback>
<cfquery NAME="LockBillback" DATASOURCE="#Application.Datasource#">
			UPDATE	Billback_Allied
			SET		BB_Is_Locked = 1,
					BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#'
			WHERE 	Billback_ID = '#Item#'
		</cfquery>
</cfif>

		<cfset useLakebaseForIsAvailable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForIsAvailable>
	<cftry>
		<cfset IsAvailable = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Item#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsAvailable = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsAvailable>
<cfquery NAME="IsAvailable" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Billback WHERE Billback_ID = '#Item#'
		</cfquery>
</cfif>

		<cfset useLakebaseForGetSourceAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetSourceAnalyst>
	<cftry>
		<cfset GetSourceAnalyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#IsAvailable.Analyst_User_ID#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSourceAnalyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSourceAnalyst>
<cfquery NAME="GetSourceAnalyst"  DATASOURCE="#Application.Datasource#">
			SELECT 	Name_First, Name_Last
			FROM 	_Users
			WHERE 	User_ID='#IsAvailable.Analyst_User_ID#'
		</cfquery>
</cfif>

		<cfset useLakebaseForGetTargetAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetTargetAnalyst>
	<cftry>
		<cfset GetTargetAnalyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#FORM.Tar_Analyst#",
				"deleted" = "eq.0",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetTargetAnalyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetTargetAnalyst>
<cfquery NAME="GetTargetAnalyst"  DATASOURCE="#Application.Datasource#">
			SELECT 	Name_First, Name_Last
			FROM 	_Users
			WHERE 	User_ID = '#FORM.Tar_Analyst#'
			AND 	Deleted = 0
		</cfquery>
</cfif>

		<CFIF IsAvailable.Recordcount GT 0 AND GetSourceAnalyst.Recordcount GT 0>

			<CFTRANSACTION ACTION="BEGIN">

				<cfquery NAME="Reassign_BB" DATASOURCE="#Application.Datasource#">
					UPDATE 	Billback
					SET		Analyst_User_ID = '#FORM.Tar_Analyst#'
					WHERE 	Billback_ID = '#Item#'
					AND 	Analyst_User_ID = '#IsAvailable.Analyst_User_ID#'
					AND 	Deleted = 0
				</cfquery>

				<cfquery NAME="Log_Reassign" DATASOURCE="#Application.Datasource#">
					INSERT INTO BB_Reassign
						(Billback_ID, From_User_ID, To_User_ID, By_User_ID)
					VALUES
						('#Item#', '#IsAvailable.Analyst_User_ID#', '#FORM.Tar_Analyst#', '#request.AccessStructure.User_ID#')
				</cfquery>

				<!--- The new analyst becomes the creator of the billback. --->
				<cfquery NAME="updBBData" DATASOURCE="#Application.Datasource#">
					UPDATE Billback
					SET BB_Creator_ID = '#FORM.Tar_Analyst#'
					WHERE Billback_ID = '#Item#'
				</cfquery>

			<CFTRANSACTION ACTION = "commit">

			</CFTRANSACTION>

		<CFELSE>

			<CFSET Unavailable = "#Unavailable##Item#,">

		</CFIF>

		<!--- The "BB_Creator_ID" above has been changed above and so call "Populate_Billback_Approvable_Positions", so that we can get the new CRA. --->
		<cfquery NAME="UpdateApprovablePositions" DATASOURCE="#Application.Datasource#">
			EXEC Populate_Billback_Approvable_Positions '#Item#'
		</cfquery>

		<cfquery NAME="UnLockBillback" DATASOURCE="#Application.Datasource#">
			UPDATE	Billback_Allied
			SET		BB_Is_Locked = 0,
					BB_Locked_By_User_ID = ''
			WHERE 	Billback_ID = '#Item#'
		</cfquery>

	<CFELSE>

		<CFSET UnSuccessful = "#UnSuccessful##Item#,">

	</CFIF>

</CFLOOP>

<CFIF Unavailable EQ "" AND UnSuccessful EQ "">
	<BR><BR><BR><BR><BR><BR>
	<CFSET ReassignedBB = ListQualify(FORM.Selected_Billback_ID,"'",",","All")>
	<cfquery NAME="DispDetails" DATASOURCE="#Application.Datasource#">
		SELECT BB_Code, BB_Title FROM Billback WHERE Billback_ID IN (#PreserveSingleQuotes(ReassignedBB)#)
	</cfquery>

	<CFSET Count = 0>
	<CFSET BGCount = 1>
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="5" ALIGN="Center">
		<TR>
			<TD COLSPAN="5"><B><FONT COLOR="Red" SIZE="3"><CFOUTPUT>Selected Billbacks are being reassigned to '#GetTargetAnalyst.Name_First# #GetTargetAnalyst.Name_Last#'.</CFOUTPUT></FONT></B></TD><!--- Please wait while selected Billbacks are being reassigned... --->
		</TR>
		<TR>
			<TD COLSPAN="5"><B><FONT SIZE="3"><BR>List of selected Billbacks</FONT></B></TD>
		</TR>
		<TR>
		<CFOUTPUT QUERY="DispDetails">
			<CFSET Count = Count + 1>
			<CFIF Count LT 6>
				<TD BGCOLOR = "C6FFC6" STYLE = "Border: solid C0C0C0 1px">#BB_Code#
			<CFELSE>
				<CFSET Count = 0>
				<CFSET BGCount = BGCount + 1>
				</TR>
				<TR>
				<TD BGCOLOR = "C6FFC6" STYLE = "Border: solid C0C0C0 1px">#BB_Title#</td>
			</CFIF>
		</CFOUTPUT>
	</TABLE>

<CFELSEIF Unavailable NEQ "">

	<CFSET Unavailable = ListQualify(Unavailable,"'",",","All")>

	<cfquery NAME="Unavailable_Title" DATASOURCE="#Application.Datasource#">
		SELECT BB_Code FROM Billback WHERE Billback_ID IN (#PreserveSingleQuotes(UnAvailable)#)
	</cfquery>

	<CFSET UnavailableItems = "">

	<CFOUTPUT QUERY="Unavailable_Title">
		<CFSET UnavailableItems = "#UnavailableItems# [ #BB_Code# ]">
	</CFOUTPUT>

<CFELSEIF UnSuccessful NEQ "">

	<CFSET UnSuccessful = ListQualify(UnSuccessful,"'",",","All")>

	<cfquery NAME="Unavailable_Title" DATASOURCE="#Application.Datasource#">
		SELECT BB_Code FROM Billback WHERE Billback_ID IN (#PreserveSingleQuotes(UnSuccessful)#)
	</cfquery>

	<CFSET UnSuccessfulItems = "">

	<CFOUTPUT QUERY="Unavailable_Title">

		<CFSET UnSuccessfulItems = "#UnSuccessfulItems# [ #BB_Code# ]">

	</CFOUTPUT>

</CFIF>


<SCRIPT language="JavaScript">
	function delayLocate()
	{
	<cfif (isDefined("FORM.pageOrigin") AND FORM.pageOrigin EQ "BillbackPage")>
	 window.opener.location.reload();
		window.close();
	<cfelse>
		window.location.href = "/Billbacks/Reassign/BB_Reassign.cfm";
	</cfif>
	}
	<CFIF UnAvailable NEQ "">
		var unAvai = "<CFOUTPUT>#UnavailableItems#</CFOUTPUT>";
		alert("Billback(s) " + unAvai + " can't be reassigned (These Billbacks are not available in the given source).");
		window.setTimeout('delayLocate()', 0);
	</CFIF>

	<CFIF UnSuccessful EQ "" AND UnAvailable EQ "">
		window.setTimeout('delayLocate()', 5000);
	<CFELSEIF UnSuccessful NEQ "">
		var unSucc = "<CFOUTPUT>#UnSuccessfulItems#</CFOUTPUT>";
		alert("Billback(s) " + unSucc + " can't be reassigned (These Billbacks are currently locked by someother user).");
		window.setTimeout('delayLocate()', 0);
	</CFIF>

</SCRIPT>



</body>
</html>
