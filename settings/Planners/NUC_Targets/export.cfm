<!----------------------------------------------------------------------------------------------------------------------------------
	  Template: \settings\Planners\NUC_Targets\export.cfm
		Author: Chris Nguyen
		  Date: 2016 December
	   Purpose: Export NUC Targets to Excel XLSX file
----------------------------------------------------------------------------------------------------------------------------------->
<cfscript>
	plannerSettingsManager = createObject("component", "mvc.Models.planner.PlannerSettingsManager");

	qNUC_Targets = plannerSettingsManager.getNUCTargets(caller = "\settings\planners\nuc_targets\index.cfm");
	output_file  = "nuc-targets-" & lCase(dateformat(now(), "mmm-d-yyyy")) & '-' & lcase(replace(timeFormat(now(), "h:mm:ss"), ":", "", "all"));

	// pass true in the 2nd parameter to use the new XML format on XLSX file
	xlsx         = spreadSheetNew(output_file, true);

	spreadSheetAddRow(xlsx, arrayToList(qNUC_Targets.getColumnNames()));
	spreadSheetFormatRow(xlsx, {bold=TRUE, fgcolor="black", color="white"}, 1);

	// add rows in query
	spreadSheetAddRows(xlsx, qNUC_Targets);
	// hide Group_GUID
	spreadSheetSetColumnWidth(xlsx, listLen(qNUC_Targets.columnList), 0 );

	// center UOM columns
	//spreadsheetFormatColumns(xlsx, {alignment="center"}, "4,6");

	output_fullpath = (application.doc_path & "\temp_files\" & output_file & ".xlsx");
</cfscript>

<!--- <cfdump var="#arrayToList(qNUC_Targets.getColumnNames())#" abort="true"> --->

<cfspreadsheet action="write" name = "xlsx" filename = #output_fullpath# overwrite = "true">

<!--- Download spreadsheet --->
<cfheader name="Content-Disposition" value="attachment;filename=#output_file#.xlsx">
<cfcontent type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" file="#output_fullpath#" deletefile="no">
