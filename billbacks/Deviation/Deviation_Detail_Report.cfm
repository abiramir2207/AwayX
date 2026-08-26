<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<!-------
Deviation_Detail_Report.cfm
http://dev8.venus.awayx.com/billbacks/deviation/Deviation_Detail_Report.cfm?bbid=618cd2ac-be53-405f-a3e6-702da1bae20c
---------->

<cfparam name="url.command" default="init">
<cfparam name="url.filePath" default="init">
<cfparam name="url.FileName" default="init">
<cfparam name="url.applied" default="0">


<cfif url.command eq "showFromFile">
	<cfif url.filePath neq "" and url.FileName neq "">
		<cfheader name="Content-Disposition" value="attachment; filename=#url.FileName#">
		<cfcontent type="text/plain"  file="#url.filePath#">
	</cfif>
	<cfabort>
</cfif>

<cfset BBID_LIST = "" />
<cfset displayMessage = 1 />
<cfif isDefined("URL.BBID")>
	<cfset BBID_LIST = URL.BBID />
	<cfset displayMessage = 0 />
<cfelseif isDefined("FORM.Billback_ID_List")>
	<cfset BBID_LIST = FORM.Billback_ID_List />
</cfif>

<cfif displayMessage>
<cfoutput>
	<head>
		<title>Generating deviation detail report, please wait...</title>
	</head>
	<body>
	<cfinclude template="/includes/call_please_wait.cfm" />
</cfoutput>
</cfif>

	<cfset objDeviationDetailReport = CreateObject("component", "components.billback.BillbackDeviationDetailReport").init() />

	<cfset qDeviationDetailReport = objDeviationDetailReport.getDeviationDetailReport(	billbackIDList = BBID_LIST,
																						applied = URL.applied) />

	<cfset deviationReportFileName = "Deviations.csv" />
	<cfif isDefined("URL.BBID")>
		<cfset deviationReportFileName = "Deviations-#qDeviationDetailReport.BB_Code#.csv" />
	<cfelseif isDefined("FORM.Billback_ID_List")>
		<cfset deviationReportFileName = "Deviations-#DateFormat(Now(), "mmddyyyy")#.csv" />
	</cfif>

	<cfsavecontent variable="sDeviationDetailReportContent">
	<cfinclude template="/billbacks/deviation/Display_Deviation_Detail_Report.cfm">
	</cfsavecontent>

<cfif displayMessage>
	<cfset subFolderName="folder_name" />
	<CF_Writing_Email_Attachment
 			Naming_Format="#deviationReportFileName#"
			File_Extension="csv"
			Relative_Path="\Temp_Files\Billback\"
			Output_Content="#sDeviationDetailReportContent#"
			addNewLine="No"
			folder_name="#subFolderName#"
			Return_File_Name="sDeviationDetailReportFilePath"
			Return_Letter_Name="sDeviationDetailReportFileName"
			 />

	<cfoutput>
		<br><br>
		<center>
		Deviation detail report has been generated<br><br>
		<CF_smallLink
			title = "click here to download the report"
			url = "Deviation_Detail_Report.cfm?command=showFromFile&filePath=#sDeviationDetailReportFilePath#&FileName=#sDeviationDetailReportFileName#"
		>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<CF_smallLink
			title = "close window"
			url = "##"
			parameters = " onClick=""javascript: window.close();return false;"""
		>
		</center>
		</body>
	</cfoutput>
</cfif>

<cfif not displayMessage>
	<cfset pathFileName = "#Application.Doc_Path#\Temp_Files\Billback\" & deviationReportFileName />

	<cffile action="write" file="#pathFileName#" output="#sDeviationDetailReportContent#" nameconflict="overwrite" />

	<cfheader name="Content-Disposition" value="attachment;filename=#deviationReportFileName#"  />
	<cfcontent type="application/csv" file="#pathFileName#"  />
</cfif>



