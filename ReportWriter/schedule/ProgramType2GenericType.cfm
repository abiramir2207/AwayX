<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program type -> Generic Type</title>
</head>

<body>

<cfset useLakebaseForGetEachReportEntry = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_structure")>
<cfif useLakebaseForGetEachReportEntry>
	<cftry>
		<cfset GetEachReportEntry = application.oLakebase.toQuery(
			application.oLakebase.selectRows("report_structure", {
				"report_structure" = "eq.rProgramTypes",
				"select" = "report_structure_value,report_type_id"
			}), "report_structure_value,report_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetEachReportEntry = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetEachReportEntry>
<CFQUERY NAME="GetEachReportEntry" DATASOURCE="#application.datasource#">
	SELECT	Report_Structure_Value, Report_Type_ID
	FROM	Report_Structure	
	WHERE
		Report_Structure = 'rProgramTypes'
</CFQUERY>
</cfif>

<CFOUTPUT QUERY="GetEachReportEntry">
	#Report_Structure_Value#<BR>
	<CFSET rGenericType = "-1">
	<CFIF Report_Structure_Value NEQ "-1">
		<CFQUERY NAME="Get_Corresponding_Generic_Type" DATASOURCE="#application.datasource#">
			SELECT	DISTINCT Generic_Type.Generic_Type_ID
			FROM	Program_Control_Panel_Options
					LEFT JOIN Generic_Type
					ON
					Generic_Type.Generic_Type = Program_Control_Panel_Options.Generic_Type
			WHERE
					Program_Control_Panel_Options.ProgramControl_Panel_Options_ID IN (#Report_Structure_Value#)
		</CFQUERY>
		<CFIF Get_Corresponding_Generic_Type.RecordCount GT 0>
			<CFSET rGenericType = ValueList(Get_Corresponding_Generic_Type.Generic_Type_ID, ",")>
		</CFIF>		
	</CFIF>
	<cfset useLakebaseForCheck_Existing_Generic_Type_For_This_Report = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_structure")>
<cfif useLakebaseForCheck_Existing_Generic_Type_For_This_Report>
	<cftry>
		<cfset Check_Existing_Generic_Type_For_This_Report = application.oLakebase.toQuery(
			application.oLakebase.selectRows("report_structure", {
				"report_type_id" = "eq.#Report_Type_ID#",
				"report_structure" = "eq.rGenericTypes",
				"select" = "report_structure_value"
			}), "report_structure_value"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_Existing_Generic_Type_For_This_Report = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_Existing_Generic_Type_For_This_Report>
<CFQUERY NAME="Check_Existing_Generic_Type_For_This_Report" DATASOURCE="#application.datasource#">
		SELECT	Report_Structure_Value
		FROM	Report_Structure
		WHERE
				Report_Type_ID = #Report_Type_ID#
				AND
				Report_Structure = 'rGenericTypes'
	</CFQUERY>
</cfif>
	<CFIF Check_Existing_Generic_Type_For_This_Report.RecordCount EQ 0>		
		Insert #rGenericType# for report #Report_Type_ID#<HR>
		<CFQUERY NAME="Insert_Values" DATASOURCE="#application.datasource#">
			INSERT INTO Report_Structure(Report_Structure, Report_Structure_Value, Report_Type_ID)
			VALUES ('rGenericTypes', '#rGenericType#', #Report_Type_ID#)
		</CFQUERY>
	</CFIF>
</CFOUTPUT>

</body>
</html>
