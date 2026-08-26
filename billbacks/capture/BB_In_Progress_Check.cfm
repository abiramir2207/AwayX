

<CFQUERY NAME="CheckDeviationProgress" datasource="#application.datasource#">
	SELECT 	Billback.Deviation_InProgress,
			Billback_Allied.BB_Locked_By_Deviation_Grid
	FROM 	Billback
	INNER JOIN Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID 
	WHERE 	Billback.Billback_ID = '#In_Progress_Check_BBID#'
</CFQUERY>
<CFQUERY NAME="CheckDeviationIsLocked" datasource="#application.datasource#">
	SELECT 	Billback.Deviation_InProgress,
			Billback_Allied.BB_Locked_By_Deviation_Grid
			/* ,u.Name_First,
			u.Name_Last */
	FROM 	Billback
	INNER JOIN Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID 
	/*INNER JOIN _users u ON U.user_ID = Billback.BB_Locked_By_User_ID*/
	WHERE 	Billback.Billback_ID = '#In_Progress_Check_BBID#' AND BB_Locked_By_User_ID <> '#request.AccessStructure.User_ID#'
</CFQUERY>
<cfset bContinueWithUpdate = 1 />
<CFOUTPUT>	
<CFIF CheckDeviationProgress.Deviation_InProgress NEQ 0>
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="2">Deviation is in progress. Cannot update #PageName_InProgress#.</FONT></B></TD>
		</TR>
	</TABLE>
	<cfset bContinueWithUpdate = 0 />
	<CFABORT>
<CFELSEIF CheckDeviationIsLocked.BB_Locked_By_Deviation_Grid EQ 1 AND application.oApplicationAppSettingsManager.getApplicationAppSettings().getThirdPartyBBUpload() NEQ 3>
<!--- If combo, allow the user to modify the billback when the grid is open --->
<!--- All others, do not allow the user to modify the billback when the grid is open --->
	<!--- check if deviation grid is open --->
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="2">Deviation grid is open. Cannot update #PageName_InProgress#.</FONT></B></TD>
		</TR>
	</TABLE>
	<cfset bContinueWithUpdate = 0 />
	<CFABORT>
</CFIF>
</CFOUTPUT>

<!--- No other process running, can continue with update --->
<CFIF bContinueWithUpdate>
	<CFQUERY NAME="CheckDeviationProgress" datasource="#application.datasource#">
		UPDATE Billback
		SET BB_Upd_InProgress = 
			<CFIF PageName_InProgress EQ "Basic Info" AND Progress_Type EQ 1>1 
			<CFELSEIF PageName_InProgress EQ "Payee" AND Progress_Type EQ 1>2
			<CFELSEIF PageName_InProgress EQ "Programs" AND Progress_Type EQ 1>3
			<CFELSEIF PageName_InProgress EQ "Swtich Programs" AND Progress_Type EQ 1>4		
			<CFELSEIF PageName_InProgress EQ "Swtich Products" AND Progress_Type EQ 1>5	
			<CFELSEIF Progress_Type EQ 2> 0
			</CFIF>
		WHERE Billback_ID = '#In_Progress_Check_BBID#'
	</CFQUERY>
</CFIF>




