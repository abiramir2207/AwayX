<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\billbacks\OCR_Upload\OCR_Download.cfm
      Date:     30-Mar-2017
      Author:   Anand Rao
      Purpose:  Download files for the Excel format from the OCR Upload screen.

      Notes:

----------------------------------------------------------------------------------------------------------------------->

<cfparam name="URL.fileParam" default="" />
<cfparam name="URL.OCRUploadID" default=0 />
<cfparam name="URL.OCRFileCaptureID" default=0 />

<cfquery name="getFilePath" datasource="#application.datasource#">
			SELECT File_Path,* FROM dbo.Billback_Upload_Settings	
</cfquery>

<!--- Initiate the CFC --->
<cfset OCRSettingsManager = CreateObject("component","components.Billback.OCRUploadSettingsManager") />

<cfoutput>
<!--- query the data for file --->
<cfif (URL.fileParam EQ "OCRDownload")>
<!--- 	<cfset holdingPenManager.logUploadDownloadHistory("1","#URL.BBUploadHoldScorecardID#","#request.accessstructure.User_ID#") /> --->

	<cfquery name="updXLDownloadedCount" datasource="#application.datasource#">
		UPDATE OCR_Upload_Log SET XLDownloaded_Count = XLDownloaded_Count + 1 WHERE OCR_Upload_ID = #URL.OCRUploadID#
	</cfquery>
	
	<cfquery name="selXLDownloadedCount" datasource="#application.datasource#">
		SELECT XLDownloaded_Count,File_Name FROM OCR_Upload_Log WHERE OCR_Upload_ID = #URL.OCRUploadID#
	</cfquery>

	<cfif (selXLDownloadedCount.RecordCount GTE 1)>
		<cfset DownloadFileNameNoQuotes = ListDeleteAt(selXLDownloadedCount.File_Name, ListLen(selXLDownloadedCount.File_Name, "."), ".") & "_Forge_#selXLDownloadedCount.XLDownloaded_Count#.xlsx" >
		<cfset DownloadFileName = '"' & DownloadFileNameNoQuotes & '"' />
	<cfelse>
		<cfset DownloadFileNameNoQuotes = "OCR_File_ID_"& URL.OCRUploadID & "_" & DateFormat(now(), "mm_dd_yyyy") & ".xlsx" />
		<cfset DownloadFileName = "OCR_File_ID_"& URL.OCRUploadID & "_" & DateFormat(now(), "mm_dd_yyyy") & ".xlsx" />
	</cfif>
	
	<cfset pathFileNameNoQuotes = Replace(getFilePath.File_Path,"BB_upload","OCR_Upload")& "Download\" &  DownloadFileNameNoQuotes />  
	<cfset pathFileName = Replace(getFilePath.File_Path,"BB_upload","OCR_Upload")& "Download\" &  DownloadFileName />  

	<cfset qryResult = OCRSettingsManager.getDownloadData(OCRUploadID = URL.OCRUploadID, OCRFileCaptureID = URL.OCRFileCaptureID, sFullPath = pathFileNameNoQuotes, sFileName = DownloadFileNameNoQuotes, IsDebug = 0) />
 
	<cfif (qryResult.RecordCount NEQ 0 AND IsDefined("qryResult.Status") AND qryResult.Status EQ 2)>
		<cflocation URL="/getDocument.cfm?filePath=#URLEncodedFormat(pathFileNameNoQuotes)#" />
	<cfelse>
	 	<p align="center">
			<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
				Download Failed!! 
			</span>
		</p>
	</cfif><br>	 
	<cfabort>
<!--- 48281: Holding pen upgrade/Anand Rao/02-Mar-2015 --->
<cfelse>	
	<p align="center">
		<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
			Download Failed!! 
		</span>
	</p>
</cfif>
</cfoutput>
