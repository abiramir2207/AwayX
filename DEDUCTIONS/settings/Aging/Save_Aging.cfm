<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<!--- <CFDUMP VAR="#FORM#"> --->

<CFSET useLakebaseForDelete_All = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_aging")>
<CFIF useLakebaseForDelete_All>
	<cftry>
		<cfset application.oLakebase.updateRows("dd_aging",
			{ "deleted" = "eq.0" },
			{ "deleted" = 1 }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDelete_All = false>
		</cfcatch>
	</cftry>
</CFIF>
<CFIF NOT useLakebaseForDelete_All>
<CFQUERY NAME="Delete_All" DATASOURCE="#Application.Datasource#">
	UPDATE 	DD_Aging 
	SET		Deleted = 1
	WHERE 	Deleted = 0
</CFQUERY>
</CFIF>


<CFLOOP INDEX="LoopCount" FROM="1" TO="#FORM.TotTRNumber#">	

	<CFSET PreLoopCount = LoopCount - 1>
	<CFIF LoopCount EQ FORM.TotTRNumber>
		<CFSET endToInsert = EVALUATE("FORM.ED_RG_#PreLoopCount#")>
		<CFSET StartToInsert = endToInsert + 1>
		<CFSET endToInsert = "*">
		<CFSET labelToInsert = EVALUATE("FORM.Label_#LoopCount#")>
		<CFSET ColorToInsert = EVALUATE("FORM.ColorID_#LoopCount#")>
		<CFSET FontTOInsert = EVALUATE("FORM.FontID_#LoopCount#")>
	<CFELSEIF LoopCount EQ 1>
		<CFSET StartToInsert = 0>
		<CFSET endToInsert = EVALUATE("FORM.ED_RG_#LoopCount#")>
		<CFSET labelToInsert = EVALUATE("FORM.Label_#LoopCount#")>
		<CFSET ColorToInsert = EVALUATE("FORM.ColorID_#LoopCount#")>
		<CFSET FontTOInsert = EVALUATE("FORM.FontID_#LoopCount#")>		
	<CFELSE>
		<CFSET endToInsert = EVALUATE("FORM.ED_RG_#PreLoopCount#")>
		<CFSET StartToInsert = endToInsert + 1>
		<CFSET endToInsert = EVALUATE("FORM.ED_RG_#LoopCount#")>
		<CFSET labelToInsert = EVALUATE("FORM.Label_#LoopCount#")>
		<CFSET ColorToInsert = EVALUATE("FORM.ColorID_#LoopCount#")>
		<CFSET FontTOInsert = EVALUATE("FORM.FontID_#LoopCount#")>
	</CFIF>
	<!--- <CFOUTPUT>
	#StartToInsert#,#endToInsert#,#labelToInsert#,
	
	</CFOUTPUT> --->
<CFSET useLakebaseForInsert_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_aging")>
	<CFIF useLakebaseForInsert_Data>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_aging", {
				"dd_aging_label" = labelToInsert,
				"start_range" = StartToInsert,
				"end_range" = (endToInsert EQ "*") ? javaCast("null", "") : endToInsert,
				"tier_number" = LoopCount,
				"aging_count" = FORM.TotTRNumber,
				"colorid" = ColorToInsert,
				"fontid" = FontTOInsert
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForInsert_Data = false>
			</cfcatch>
		</cftry>
	</CFIF>
	<CFIF NOT useLakebaseForInsert_Data>
		<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
			INSERT INTO 	
			
			DD_Aging	(	DD_Aging_Label,
							Start_Range,							
							End_Range,				
							Tier_Number,
							Aging_Count,
							ColorID,
							FontID		)
			
			
			VALUES		(	'#labelToInsert#',
							'#StartToInsert#',
							<CFIF endToInsert EQ "*">
								NULL,
							<CFELSE>
								'#endToInsert#',
							</CFIF>
							'#LoopCount#',
							'#FORM.TotTRNumber#',
							'#ColorToInsert#',
							'#FontTOInsert#'	)											
		</CFQUERY>	 
	</CFIF>
	</CFLOOP>

	
<BR><BR><BR><BR>	
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="3">Please wait while data is being saved...</FONT></B></TD>
	</TR>
</TABLE>	
	
	
<SCRIPT language="JavaScript">
function goBackToOtherPage()
{
	window.location.href = "Create_Aging.cfm";		
}
window.setTimeout('goBackToOtherPage()', 3000);
</SCRIPT>
<!--- <CFLOCATION URL="Create_Aging.cfm" ADDTOKEN="No"> --->
</body>
</html>
