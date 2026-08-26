<!------ current_file.cfm ----->

<br><br>
<cfset qGetWeeklyReport = crucibleFileManager.getWeeklyReport() />

<cfif qGetWeeklyReport.recordCount>

	<cfset weeklyReportId = qGetWeeklyReport.Crucible_Weekly_Report_ID />
	<cfoutput>
	<strong>Data for the week of #DateFormat(qGetWeeklyReport.Weekly_Report_Date, "mm/dd/yyyy")#</strong>&nbsp;
	</cfoutput>
	
	
	<cfset qFiles = crucibleFileManager.getReportFiles(weeklyReportId, request.AccessStructure.user_id) />
	
	<cfif qFiles.recordCount>
	
		<cfloop query="qFiles">
		<cfset sDownloadFilePath = "#sAPP_Relative_Path#/#Weekly_Report_Folder#/#Folder_Name#.#sCompressed_File_Extension#" />
		<CF_smallLink 
			title = "download file" 
			url = "/GetDocument.cfm?FilePath=#sDownloadFilePath#"
		>
		</cfloop>	
	
	<cfelse>
	
		No file found
	
	</cfif>

</cfif>