<!--- Template: \ReportWriter\ProgramsApprovedViaEmailReport.cfm
      Date:     Feb 9, 2011
      Author:   Chris Nguyen
      Purpose:  Generate Programs Approved Via Email Report in Excel format,
                and allow users to open or save the Excel report.
--->

<!---default to the last 367 days, custom value (in integer) may be specified in Reports.Report_URL_Options--->
<cfparam name="URL.daysRange" default="367">

<cfscript>
  ReportDirectory = ExpandPath("/common_documents/Temp_Files/ReportWriter");
  ReportTemplate  = "ProgramsApprovedViaEmail.cfm";
  ReportFileName  = "programs_approved_via_email_" & DateFormat(Now(),'mmmddyyyy') & ".xls";
  ReportFullPath  = ReportDirectory & "/" & ReportFileName;
</cfscript>

<!--- get the approved programs via email, sort them by date descending, name --->
<cfquery name="ReportContent" datasource="#application.datasource#">
	SELECT ( U.Name_first + ' ' + U.Name_last ) AS Name,
	       U.User_code                          AS Id,
	       Cm.Contract_number                   AS [PROGRAM_NUMBER],
	       Cm.Contract_title                    AS [PROGRAM_TITLE],
	       <!--- convert datetime field into a user friendly format (e.g. Jan 1 2005 1:29PM) --->
	       CONVERT(VARCHAR(20), Eaup.Approval_received_date, 100) AS ApprovalReceivedDate
	FROM   Email_Approval_User_Programs Eaup
	       INNER JOIN _users U ON U.User_id = Eaup.User_id
	       INNER JOIN Contract_Main Cm ON Cm.Contract_Main_ID = Eaup.Program_ID 
	WHERE Sent_id = Received_id
	  AND DateDiff(day, 
	               Eaup.Approval_received_date, 
				   Convert(varchar, Getdate(), 101))  <=  <cfoutput>#URL.daysRange#</cfoutput> 
	ORDER  BY Eaup.Approval_received_date DESC, Name
</cfquery>

<!--- Create an instance of the POIUtility.cfc. --->
<cfset objPOI = CreateObject("component", "components.POIUtility").Init()/>

<!--- 
        Create a sheet object for this query. This will 
        return a structure with the following keys:
        - Query
        - ColumnList
        - ColumnNames
        - SheetName
--->
<cfset objSheet = objPOI.GetNewSheetStruct() />
    
<!--- Set the query into the sheet. --->
<cfset objSheet.Query = ReportContent />
    
<!--- Define the order of the columns (and which columns to include). --->
<cfset objSheet.ColumnList = "ApprovalReceivedDate,Name,Id,Program_Number,Program_Title" />
    
<!--- We want to include a header Row in our outputted excel workbook. Therefore, provide header values in the SAME
        order as the column list above. --->
<cfset objSheet.ColumnNames = "Approval Received Date,Name,Id,Program Number,Program Title" />
        
<!--- Set the sheet name. --->
<cfset objSheet.SheetName = "Approved By Email As Of " & DateFormat(Now(), 'mmm d')/>
        
<cfset objPOI.WriteExcel(
        FilePath  = ReportFullPath,
        Sheets    = objSheet,
        HeaderCSS = "color:white; background-color:black; font-weight:bold;",
        RowCSS    = "border-bottom:1px dotted gray;"
        )/>

<cffile action="readBinary" file="#ReportFullPath#" variable="ReportContent">

<!--- Give users option to save or open the Excel report --->
<cfheader name="Content-Disposition" value="inline;filename=#ReportFileName#"  />
<cfcontent type="application/vnd.ms-excel" variable="#ReportContent#"  />
