<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<!--- <CFDUMP VAR="#URL#"> --->
<cfset useLakebaseForGet_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGet_Details>
	<cftry>
		<cfset Get_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"select" = "dd_dedid,sp_number",
				"deduction_id" = "eq.#URL.Deduction_ID#",
				"deleted" = "eq.0"
			}),
			"dd_dedid,sp_number"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForGet_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Details>
<CFQUERY NAME="Get_Details" DATASOURCE="#Application.Datasource#">
	SELECT 		DD_DedID,
			 	SP_Number,
				Name,
				Shr_Bill_To
				
	FROM 		Deductions
	INNER JOIN 	Distributor_Bill_To ON Distributor_Bill_To.Distributor_Bill_To_ID = Deductions.Distributor_Bill_To_ID AND Distributor_Bill_To.Deleted=0
	
	WHERE 		Deduction_ID = '#URL.Deduction_ID#' AND Deductions.Deleted=0
</CFQUERY>
</cfif>
<CFOUTPUT>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	<TR>
		<TD><B>DEDUCTION ##:</B> &nbsp;#Get_Details.DD_DedID# - <CFIF Get_Details.SP_Number EQ "">000<CFELSE>#Get_Details.SP_Number#</CFIF></TD>				
	</TR>
</TABLE>
</CFOUTPUT>
</body>
</html>
