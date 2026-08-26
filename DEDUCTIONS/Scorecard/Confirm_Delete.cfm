<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFIF URL.DelFlag EQ 1>
	<cfset useLakebaseForDD_Delete = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForDD_Delete>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#URL.Deduction_ID#" },
				{
					"dd_status" = 6,
					"dd_date_closed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"dd_closed_by" = request.AccessStructure.User_ID
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDD_Delete = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDD_Delete>
	<CFQUERY NAME="DD_Delete" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	DD_Status = 6,
				DD_Date_Closed = getdate(),
				DD_Closed_By = '#request.AccessStructure.User_ID#'
				
		WHERE 	Deduction_ID = '#URL.Deduction_ID#'
	</CFQUERY>
	</cfif>
<CFELSEIF URL.DelFlag EQ 2>
	<cfset useLakebaseForDD_Undelete = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForDD_Undelete>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#URL.Deduction_ID#" },
				{
					"dd_status" = 2,
					"dd_date_closed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"dd_closed_by" = request.AccessStructure.User_ID
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForDD_Undelete = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForDD_Undelete>
	<CFQUERY NAME="DD_Undelete" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	DD_Status = 2,
				DD_Date_Closed = getdate(),
				DD_Closed_By = '#request.AccessStructure.User_ID#'
				
		WHERE 	Deduction_ID = '#URL.Deduction_ID#'
	</CFQUERY>
	</cfif>
</CFIF>

<BR><BR><BR><BR>
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Blue" SIZE="3">Deduction [#URL.DD_DedID#] has been <CFIF URL.DelFlag EQ 1>deleted<CFELSE>undeleted</CFIF> successfully.</FONT></B></TD>			
	</TR>	
</TABLE>	

<SCRIPT language="JavaScript">
function RefeshOpener()
{
	if (window.opener)
	{
		//window.opener.location.reload();
		window.opener.document.DD_Scorecard.submit()
	}	
}
RefeshOpener()

window.setTimeout('window.close()', 3000);
</SCRIPT> 
</CFOUTPUT>
</body>
</html>
