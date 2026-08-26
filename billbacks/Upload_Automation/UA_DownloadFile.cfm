<!---------------------------------------------------------------------------------------------------------------------
      Template: \AwayX\billbacks\Upload_Automation\UA_DownloadFile.cfm
      Date:     17-Jun-2020
      Author:   Anand Rao
      Purpose:  Download files for the Upload Automation

      Notes:

----------------------------------------------------------------------------------------------------------------------->


<cfparam name="URL.fileParam" default="" />

<cfquery name="getDTSPath" datasource="#application.datasource#">
	SELECT DTSPATH = DTS_Reference_Path+'\Extract'
	FROM   DataInt_Settings
	ORDER BY Dataint_setting_ID
</cfquery>

<cfset pathFileName = getDTSPath.DTSPATH  />		
<cfif (URL.fileParam EQ "DownloadHLV")>
	<cfset strFileName =  "Clorox_3000_Rebate_Intake_Validate_Extract.xlsx" />
<cfelseif (URL.fileParam EQ "DownloadBBReport")>
	<cfset strFileName =  "Clorox_Extract_BB_Report.txt" /> 
<cfelseif (URL.fileParam EQ "DownloadDRReport")>
	<cfset strFileName =  "Clorox_Distributor_Rebate_Extract.txt" /> 	
<cfelseif (URL.fileParam EQ "DownloadAFReport")>
	<cfset strFileName =  "Clorox_GPO_Admin_Fee_Extract.txt" /> 
</cfif>

<cfset desCFPath = "#Application.Doc_Path#\Data_Files\Uploaded\billbacks\uploadAutomation\Download\" />
<cfset pathFileName = pathFileName & "\" & strFileName />

<cfif FileExists("#pathFileName#") >  
	<cffile action = "copy" 
		  source = "#pathFileName#" 
		  destination = "#desCFPath#"
		  nameconflict="OVERWRITE">	
	<cflocation URL="/getDocument.cfm?filePath=#desCFPath#\#strFileName#" />	
<cfelse>
	Error copying the file!
</cfif>  
<cfabort>

<cfset uploadAutomationManager = CreateObject("component", "components.billback.AutomationUploadManager") />
 
<script language="javascript">
	function fnSubmitForm()
	{
	
		var thisForm 	= document.getElementById('frmDownloadFile');
		thisForm.submitted.value =  1;
		thisForm.submit();
	}
</script>

<cfquery name="qryGetDBServerType" datasource="#application.datasource#">
	DECLARE @IPString VARCHAR(15), 
	@Stage_IP_Range VARCHAR(50),
	@Prod_IP_Range VARCHAR(50),
	@AzureStage_IP_Range VARCHAR(50),
	@AzureProd_IP_Range VARCHAR(50),
	@Other_IP_Range VARCHAR(50),
	@Server_Type VARCHAR(50)
	
	-- SET @IPString = '10.40.3.9'  
	SELECT @IPString = CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR(15)) 
	
	SET @AzureStage_IP_Range = '10.40'  
	SET @AzureProd_IP_Range = '10.30'
	SET @Stage_IP_Range = '10.2'  
	SET @Prod_IP_Range = '10.1'
	
	 SET @Server_Type = 'STAGE'
	
	IF ( (@IPString LIKE '%' + @AzureStage_IP_Range + '%') OR (@IPString LIKE '%' + @Stage_IP_Range + '%'))
	    SET @Server_Type = 'AZURESTAGE'
	ELSE IF ( (@IPString LIKE '%' + @AzureProd_IP_Range + '%') OR (@IPString LIKE '%' + @Prod_IP_Range + '%') )
	    SET @Server_Type = 'AZUREPROD' 
	ELSE  
	    SET @Server_Type = 'OTHER'
	
	SELECT @Server_Type as Server_Type
</cfquery>

<!--- query the data for file --->
<cfif (URL.fileParam EQ "Report")>
	<cfset holdingPenManager.logUploadDownloadHistory("1","#URL.BBUploadHoldScorecardID#","#request.accessstructure.User_ID#") />
	
	<cfset DownloadFileName = "Report_HoldingPen_UID_"& URL.UploadID & "_" & DateFormat(now(), "mm_dd_yyyy") & ".xlsx" />
	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Download\" & DownloadFileName  />  
	<cfif FindNoCase("C:", pathFileName)>
		<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "C:", "")>
	<cfelseif FindNoCase("E:", pathFileName)>
		<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "E:", "")>
	<cfelseif FindNoCase("D:", pathFileName)>
		<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "D:", "")>
	<cfelse>
		<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "F:", "")>
	</cfif>
	
<!--- 	WR 77891 :: Azure no longer uses a File share for the Common_Documents Dir.  The result is that Application.Doc_Path is in the webroot.
		This pathFileName is used in the DB server so it needs the \\ mapping from the above code.
	<cfif (qryGetDBServerType.RecordCount NEQ 0)>
			<cfif ((qryGetDBServerType.Server_Type EQ "AZURESTAGE") OR (qryGetDBServerType.Server_Type EQ "AZUREPROD"))>
				<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Download\" & DownloadFileName  /> 
			</cfif>
	</cfif> --->

	<cfset qryResult = holdingPenManager.getReportData(UploadID = URL.UploadID, sFullPath = pathFileName, sFileName = DownloadFileName, sUploadType = URL.UploadType) />
	<cfif (qryResult.RecordCount NEQ 0 AND IsDefined("qryResult.Status") AND qryResult.Status EQ 2)>
			<cflocation URL="/getDocument.cfm?filePath=#pathFileName#" />
		<cfelse>
		 	<p align="center">
				<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
					Download Failed!! 
				</span>
			</p>
		</cfif><br>	 
	<cfabort>
<!--- 48281: Holding pen upgrade/Anand Rao/02-Mar-2015 --->
<cfelseif (URL.fileParam EQ "Download")>	
	<cfset UploadID = "" />
	<cfset DownloadFileName = "BB_Upload_Hold_Report_All.xlsx" />
 	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Uploaded\billbacks\uploadAutomation\Download\" & DownloadFileName  /> 
	<cfif FindNoCase("C:", pathFileName)>
		<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "C:", "")>
	<cfelseif FindNoCase("E:", pathFileName)>
		<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "E:", "")>
	<cfelseif FindNoCase("D:", pathFileName)>
		<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "D:", "")>
	<cfelse>
		<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "F:", "")>
	</cfif> 
 <!--- 	WR 77891 :: Azure no longer uses a File share for the Common_Documents Dir.  The result is that Application.Doc_Path is in the webroot.
		This pathFileName is used in the DB server so it needs the \\ mapping from the above code.
 	<cfif (qryGetDBServerType.RecordCount NEQ 0)>
			<cfif ((qryGetDBServerType.Server_Type EQ "AZURESTAGE") OR (qryGetDBServerType.Server_Type EQ "AZUREPROD"))>
				<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Download\" & DownloadFileName  /> 
			</cfif>
	</cfif> --->
	
	<cfset qryResult = holdingPenManager.getReportData(UploadID = '', sFullPath = pathFileName, sFileName = DownloadFileName, sUploadType = URL.UploadType) />
 	<cfif (qryResult.RecordCount NEQ 0 AND IsDefined("qryResult.Status") AND qryResult.Status EQ 2)>
		<cflocation URL="/getDocument.cfm?filePath=#pathFileName#" />		
	<cfelse>
		<p align="center">
		<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
			Download Failed!! 
		</span>
		</p>
	</cfif><br>	 
	<cfabort>
<!--- START:  D79233 - Holding Pen Ignore report - Anand Rao/21-Aug-2018 --->
<cfelseif (URL.fileParam EQ "IgnoreReport")>
<!--- <cfdump var="#FORM#" /> --->
	<cfif (FORM.submitted NEQ 1)>
		<CFSET URL.PageTitle="Holding Pen: Ignore rows Report Download">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<cfoutput>
			<form name="frmDownloadFile" id="frmDownloadFile" method="post" action="downloadFile.cfm?fileParam=#URL.fileParam#&UploadID=#URL.UploadID#&UploadType=#URL.UploadType#&BBUploadHoldScorecardID=#URL.BBUploadHoldScorecardID#"><br>
				<div align="center">
				<table cellpadding="3" cellspacing="3">
					<tr>
						<td>
							<strong>Upload Date:</strong>
						</td>
						<td>
							<CF_EASYDATE FORMNAME="frmDownloadFile" FIELDNAME="upload_date" FORMAT="mm/dd/yyyy" DEFAULT="">
						</td>
					</tr>
					<tr>
						<td>
							<strong>Source:</strong>
						</td>
						<td>
						<cfquery name="qryGetSourceCode" datasource="#application.datasource#">
							SELECT DISTINCT(source) FROM BB_Upload_Hold_Header_Log
						</cfquery>
						
							<select name="selSource_Code">
								<option value="">Select a source</option>
								<cfloop query="qryGetSourceCode">
									<option value="#qryGetSourceCode.source#">#qryGetSourceCode.Source#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table><br>
				<br>
				<input type="hidden" name="submitted" value="1">
				<div style="margin-top:5px; margin-bottom:5px;">
				<button type="button" onclick="javascript:fnSubmitForm();" class="button" style="margin:0 4px;cursor:hand;">Download</button>
				<button type="button" onclick="javascript:window.close();" class="button" style="margin:0 4px;cursor:hand;">Close</button>
				</div>
				</div>
			</form> 
		</cfoutput>	
	<cfelseif (FORM.submitted EQ 1)>	
	
		<cfset UploadID = "" />
	 
		<cfset DownloadFileName = "Ignore_Report_HoldingPen_UID_" & URL.UploadID & "_" & DateFormat(now(), "mm_dd_yyyy") & ".xlsx" />
	 	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Download\" & DownloadFileName  /> 
		<cfif FindNoCase("C:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "C:", "")>
		<cfelseif FindNoCase("E:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "E:", "")>
		<cfelseif FindNoCase("D:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "D:", "")>
		<cfelse>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "F:", "")>
		</cfif> 

		<cfset qryResult = holdingPenManager.getReportData(sFullPath = pathFileName, sFileName = DownloadFileName, sUploadType = 4, dUploadDate = FORM.upload_date, sSourceCode = FORM.selSource_Code) />
	 	<cfif (qryResult.RecordCount NEQ 0 AND IsDefined("qryResult.Status") AND qryResult.Status EQ 2)>
			<cflocation URL="/getDocument.cfm?filePath=#pathFileName#" />		
		<cfelse>
			<p align="center">
			<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
				Download Failed!! 
			</span>
			</p>
		</cfif><br>	 
		<cfabort>
	</cfif>	<!--- <cfif	(FORM.submitted EQ 1)> --->
<!--- END: D79233 - Holding Pen Ignore report - Anand Rao/21-Aug-2018 --->	
	
<cfelseif (URL.fileParam EQ "Snapshot")>
	<cfset fileData = holdingPenManager.getHoldingPenData() />
	<cfset DownloadFileName = "HoldingPen_Data_" & DateFormat(now(), "mm_dd_yyyy") & ".csv" />	
	<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\" & DownloadFileName  />
<cfelseif URL.fileParam EQ "RFDownload">

		<cfquery name="qFilePath" datasource="#application.datasource#">
			DECLARE 
			@DTSPATH varchar(1000),
			@DTSSYSCOPATH varchar(1000),
			@DTSUSFSPATH varchar(1000),
			@DTSCBSPATH varchar(1000),
			@DTSBEKPATH varchar(1000),
			@DTSPFGPATH varchar(1000), 
			@DTSBUNZLPATH varchar(1000), 
			@DTSIIIPartyPATH varchar(1000),
			@DTSREFERENCEPATH varchar(1000)

			SELECT      @DTSPATH = DTS_Reference_Path,
						@DTSREFERENCEPATH = DTS_Reference_Path
			FROM  DataInt_Settings
			ORDER BY Dataint_setting_ID
				
			SET @DTSPATH 		=  @DTSPATH + '\Interface_Backup\InBound\EDI_TXT_Bak' 
			SET @DTSSYSCOPATH   =  @DTSPATH + '\SYSCO'                                                      
			SET @DTSUSFSPATH 	=  @DTSPATH + '\USFS' 	
			SET @DTSBEKPATH 	=  @DTSPATH + '\BEK'
			SET @DTSPFGPATH		=  @DTSPATH + '\PFG'
			SET @DTSBUNZLPATH	=  @DTSPATH + '\BUNZL'
			SET @DTSCBSPATH 	=  @DTSREFERENCEPATH + '\Interface_BackUp\Inbound\Claims_Bak\User_Upload'
			SET @DTSIIIPartyPATH 	=  @DTSREFERENCEPATH + '\Interface_BackUp\Inbound\Claims_Bak'
			
			SELECT @DTSPATH 	 AS DTSPath, 
			@DTSSYSCOPATH as DTSSYSCOPATH, 
			@DTSUSFSPATH as DTSUSFSPATH, 
			@DTSCBSPATH AS DTSCBSPATH,
			@DTSBEKPATH AS DTSBEKPATH,
			@DTSPFGPATH AS DTSPFGPATH,
			@DTSBUNZLPATH AS DTSBUNZLPATH,
			@DTSIIIPartyPATH AS DTSIIIPartyPATH
		</cfquery>
		<cfset qHoldingPen = holdingPenManager.getHoldingPenData(URL.BBUploadHoldScorecardID) />
		<cfset SyscoFile	= qFilePath.DTSSYSCOPATH & "\" & qHoldingpen.FileName />
		<cfset USFSFile 	= qFilePath.DTSUSFSPATH & "\" & qHoldingpen.FileName />
		<cfset CBSFile 		= qFilePath.DTSCBSPATH & "\" & qHoldingpen.FileName />
		<cfset BEKFile		= qFilePath.DTSBEKPATH & "\" & qHoldingpen.FileName />
		<cfset PFGFile		= qFilePath.DTSPFGPATH & "\" & qHoldingpen.FileName />
		<cfset BUNZLFile	= qFilePath.DTSBUNZLPATH & "\" & qHoldingpen.FileName />
		<cfset IIIPartyFile 	= qFilePath.DTSIIIPartyPATH & "\" & qHoldingpen.FileName />
		
				
		<cfset DownloadFileName = qHoldingpen.FileName />
		 <cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Download\" & DownloadFileName  />
		 
		<cfif FindNoCase("C:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "C:", "")>
		<cfelseif FindNoCase("E:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "E:", "")>
		<cfelseif FindNoCase("D:", pathFileName)>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "D:", "")>
		<cfelse>
			<cfset pathFileName  = "\\" & Application.WebServerName & Replace(pathFileName, "F:", "")>
		</cfif>

		<cfif (qryGetDBServerType.RecordCount NEQ 0)>
				<cfif ((qryGetDBServerType.Server_Type EQ "AZURESTAGE") OR (qryGetDBServerType.Server_Type EQ "AZUREPROD"))>
					<cfset pathFileName = "#Application.Doc_Path#\Data_Files\Created\settings\HOLDING_PEN\Download\" & DownloadFileName  /> 
				</cfif>
		</cfif>		 
		
		<cfif (qHoldingpen.Upload_Type EQ "3" AND qHoldingpen.Source EQ "SYSCO" AND FileExists(SyscoFile))>
		 	<cffile action = "copy" 
			  source = "#SyscoFile#" 
			  destination = "#pathFileName#"
			  nameconflict="OVERWRITE">	
			 copied
		<cfelseif (qHoldingpen.Upload_Type EQ "3" AND qHoldingpen.Source EQ "USFS" AND FileExists(USFSFile)) >
			<cffile action = "copy" 
			  source = "#USFSFile#" 
			  destination = "#pathFileName#"
			  nameconflict="OVERWRITE">	
		<cfelseif (qHoldingpen.Upload_Type EQ "3" AND qHoldingpen.Source EQ "BEK" AND FileExists(BEKFile)) >
			<cffile action = "copy" 
			  source = "#BEKFile#" 
			  destination = "#pathFileName#"
			  nameconflict="OVERWRITE">
		<cfelseif (qHoldingpen.Upload_Type EQ "3" AND qHoldingpen.Source EQ "PFG" AND FileExists(PFGFile)) >
			<cffile action = "copy" 
			  source = "#PFGFile#" 
			  destination = "#pathFileName#"
			  nameconflict="OVERWRITE">	  
		<cfelseif (qHoldingpen.Upload_Type EQ "3" AND qHoldingpen.Source EQ "BUNZL" AND FileExists(BUNZLFile)) >
			<cffile action = "copy" 
			  source = "#BUNZLFile#" 
			  destination = "#pathFileName#"
			  nameconflict="OVERWRITE">
		<cfelseif (qHoldingpen.Upload_Type EQ "2" AND FileExists(CBSFile)) >
			<cffile action = "copy" 
			  source = "#CBSFile#" 
			  destination = "#pathFileName#"
			  nameconflict="OVERWRITE">	
		<cfelseif (III_P_Upload_Use_Holding_Pen EQ 1 AND qHoldingpen.Source EQ "3rd Party" AND FileExists(IIIPartyFile)) >
			<cffile action = "copy" 
			  source = "#IIIPartyFile#" 
			  destination = "#pathFileName#"
			  nameconflict="OVERWRITE">	
		<cfelse>
			<br><br>
			<p align="center">
			<span style="FONT-SIZE: 12pt; FONT-FAMILY: 'Century Gothic'; font-weight:bold">
			File not found. <cfoutput>#IIIPartyFile#</cfoutput><!--- [<cfoutput>#filePath#</cfoutput>]--->
			<br><br>
			<input type="button" onclick="javascript:window.close();" title="Close window" value="Close window">
		</span>
		</p><br>
		<br>
		<cfabort>
		</cfif> <!--- <cfif (qHoldingpen.Source EQ "SYSCO" AND FileExists(SyscoFile))> --->
</cfif> <!--- <cfif (URL.fileParam EQ "Report")> --->
  

<!--- Create a STRING BUFFER to hold the output --->
<cfset fileOutput= CreateObject("java","java.lang.StringBuffer").Init() >

<!--- header row --->
<cfif URL.fileParam EQ "Report">
	<cfset fileOutput.append("UPLOAD ID" & ",")>
	<cfset fileOutput.append("Billback_Upload_III_PH_ID" & ",")>
	<cfset fileOutput.append("Billback_Upload_III_PD_ID" & ",")>	
	<cfset fileOutput.append("FILENAME" & ",")>
	<cfset fileOutput.append("SOURCE" & ",")>
	<cfset fileOutput.append("CLAIM NUMBER" & ",")>
	<cfset fileOutput.append("CLAIM START DATE" & ",")>
	<cfset fileOutput.append("CLAIM END DATE" & ",")>
	<cfset fileOutput.append("ALIAS DISTRIBUTOR" & ",")>
	<cfset fileOutput.append("ALIAS DISTRIBUTOR NAME" & ",")>
	<cfset fileOutput.append("XREFED SHIPTO" & ",")>
	<cfset fileOutput.append("ALIAS ASSOCIATED DIST" & ",")>
	<cfset fileOutput.append("ALIAS ASSOCIATED DIST NAME" & ",")>
	<cfset fileOutput.append("XREFED ASSOCIATED SHIPTO" & ",")>
	<cfset fileOutput.append("ALIAS ITEM" & ",")>
	<cfset fileOutput.append("ALIAS ITEM Description" & ",")>
	<cfset fileOutput.append("XREFED ITEM" & ",")>
	<cfset fileOutput.append("ALIAS OPERATOR" & ",")>
	<cfset fileOutput.append("ALIAS OPERATOR NAME" & ",")>
	<cfset fileOutput.append("XREFED OPERATOR" & ",")>
	<cfset fileOutput.append("ALIAS PROGRAM" & ",")>
	<cfset fileOutput.append("ALIAS PROGRAM NAME" & ",")>
	<cfset fileOutput.append("XREFED PROGRAM" & ",")>
	<cfset fileOutput.append("PROGRAM_VALIDATION" & ",")>
	<cfset fileOutput.append("TOTAL CLAIM DOLLARS")>
	<cfset fileOutput.append(Chr(13) & Chr(10))>
	
	<!--- detail row: loop through the query, and append the records to the buffer	--->
	<cfloop query="fileData">
		<cfset fileOutput.append('"' & UPLOAD_ID & '"' & ",")>
		<cfset fileOutput.append('"' & Billback_Upload_III_PH_ID & '"' & ",")>
		<cfset fileOutput.append('"' & Billback_Upload_III_PD_ID & '"' & ",")>
		<cfset fileOutput.append('"' & FILENAME & '"' & ",")>
		<cfset fileOutput.append('"' & SOURCE & '"' & ",")>
		<cfset fileOutput.append('"' & CLAIM_NUMBER & '"' & ",")>
		<cfset fileOutput.append('"' & CLAIM_START_DATE & '"' & ",")>
		<cfset fileOutput.append('"' & CLAIM_END_DATE & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_DISTRIBUTOR & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_DISTRIBUTOR_NAME & '"' & ",")>
		<cfset fileOutput.append('"' & XREFED_SHIPTO & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_ASSOCIATED_DIST & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_ASSOCIATED_DIST_NAME & '"' & ",")>
		<cfset fileOutput.append('"' & XREFED_ASSOCIATED_SHIPTO & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_ITEM & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_ITEM_Description & '"' & ",")>
		<cfset fileOutput.append('"' & XREFED_ITEM & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_OPERATOR & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_OPERATOR_NAME & '"' & ",")>
		<cfset fileOutput.append('"' & XREFED_OPERATOR & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_PROGRAM & '"' & ",")>
		<cfset fileOutput.append('"' & ALIAS_PROGRAM_NAME & '"' & ",")>
		<cfset fileOutput.append('"' & XREFED_PROGRAM & '"' & ",")>
		<cfset fileOutput.append('"' & PROGRAM_VALIDATION & '"' & ",")>	
		<cfset fileOutput.append('"' & TOTAL_CLAIM_DOLLARS & '"')>
		<cfset fileOutput.append(Chr(13) & Chr(10))>
	</cfloop>
<cfelseif (URL.fileParam EQ "Snapshot")>
	<cfset fileOutput.append("BATCH" & ",")>
	<cfset fileOutput.append("BATCH DATE" & ",")>
	<cfset fileOutput.append("SOURCE" & ",")>
	<cfset fileOutput.append("TOTAL INVOICES" & ",")>
	<cfset fileOutput.append("ITEM ALIAS COUNT" & ",")>
	<cfset fileOutput.append("DISTRIBUTOR ALIAS_COUNT" & ",")>
	<cfset fileOutput.append("OPERATOR ALIAS COUNT" & ",")>
	<cfset fileOutput.append("INVALID PROGRAM COUNT" & ",")>
	<cfset fileOutput.append("CREATED DATE" & ",")>
	<cfset fileOutput.append("FILENAME")>
 	<cfset fileOutput.append(Chr(13) & Chr(10))>
	
	<!--- detail row: loop through the query, and append the records to the buffer	--->
	<cfloop query="fileData">
		<cfset fileOutput.append(UPLOAD_ID & ",")>
		<cfset fileOutput.append("=" & '"#UPLOAD_DATE#"' & ",")>
		<cfset fileOutput.append(SOURCE & ",")>
		<cfset fileOutput.append(TOTAL_INVOICES & ",")>
		<cfset fileOutput.append(ITEM_ALIAS_COUNT & ",")>
		<cfset fileOutput.append(DISTRIBUTOR_ALIAS_COUNT & ",")>
		<cfset fileOutput.append(OPERATOR_ALIAS_COUNT & ",")>
		<cfset fileOutput.append(INVALID_PROGRAM_COUNT & ",")>
		<cfset fileOutput.append("=" & '"#CREATED_DATE#"' & ",")>
		<cfset fileOutput.append(FILENAME)>
	 	<cfset fileOutput.append(Chr(13) & Chr(10))>
	</cfloop>
</cfif>

<!--- BB without Vendor updates/Anand Rao/01-July-2015 --->
  
<!--- download link --->
<cfif (URL.fileParam EQ "Report" OR URL.fileParam EQ "Snapshot")>
<!--- Write the string buffer to the file, convert to String ---->
	<cffile action="write" file="#pathFileName#" output="#fileOutput.ToString()#" >
	<cflocation URL="/getDocument.cfm?filePath=#pathFileName#" />
<cfelseif (URL.fileParam EQ "RFDownload")>
	<cflocation URL="/getDocument.cfm?filePath=#pathFileName#" />	
</cfif>