<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/Upload_Automation/Automation_Upload.cfm
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  18-Jun-2020
Created By   :  Anand Rao
Description  :  Upload from Settings
---------------------------------------------------------------------------------->
<cfscript>
	UASettingsManager  = CreateObject("component","components.Billback.AutomationUploadManager");
</cfscript>

<cfif (isDefined("Single_File") AND FORM.Single_File NEQ "" AND FORM.Submitted EQ "1")>
  
<!---  <cftry>	 --->
 		<cffile action="upload" destination="#Application.Doc_Path#\data_files\uploaded\billbacks\uploadAutomation\" 
		nameconflict="overwrite" result="variables.upload"   accept="text/plain" > 
		<cfset FileSize = variables.upload.fileSize>
		<cfset FileExt = variables.upload.ServerFileExt> <!--- ClientFileExt can also be used --->
		<cfset strFileName = variables.upload.ServerFile> <!--- ClientFile can also be used --->
		<cfset strServerFileName = variables.upload.ServerFileName>
		<!---If they uploaded a zero length or invalid file, redirect back with error information--->
		<cfset TotalFilePages = 0 />
		<cfif FileExt EQ "pdf">
			<cfpdf action = "getInfo" name="uploadedPDF" source="#Application.Doc_Path#\data_files\uploaded\billbacks\uploadAutomation\#strFileName#" />
			<cfset TotalFilePages = uploadedPDF.TotalPages />
		</cfif>
		
		<cfif (Filesize LT 1)>
			<table align="center">
				<tr>
					<td style="font-weight:bold;font-color:red;">
						The size of the uploaded file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.
						<cfset activeTab = 0 />
					</td>
				</tr>
			</table>
			<cffile action="delete" file="#Application.Doc_Path#\data_files\uploaded\billbacks\uploadAutomation\#form.Single_File#" />
			<!--- <cffile action="delete" file="#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#form.Single_File#" /> --->
		<!--- D111243: Error message for improper file name - 3000 Billback Upload / Anand Rao / 29-Oct-21  --->
		<cfelseif ((FindNocase("3000_PPD_REBATE_INTAKE_",strFileName,1) EQ 0) OR (REFindNoCase("[^._a-z0-9-]",strFileName) NEQ 0))>
			<table align="center">
				<tr>
					<td style="font-weight:bold;font-color:red;">
						<font color="red">
							<cfif (FindNocase("3000_PPD_REBATE_INTAKE_",strFileName,1) EQ 0)>
								- The File name has to be in the format "3000_PPD_REBATE_INTAKE_XXXXXXXXXXX.txt" <br>
							</cfif>
							<cfif (FindNocase(" ",strFileName,1) NEQ 0)>
								- Spaces are not allowed in the File Name <br>
							</cfif>
							<cfif (REFindNoCase("[^._a-z0-9-]",strFileName) NEQ 0)>
								- Special characters are not allowed in the File Name
							</cfif>
						</font>	
					</td>
				</tr>
			</table>
			<cfset activeTab = 0 />
			<!--- <cffile action="delete" file="#Application.Doc_Path#\data_files\uploaded\billbacks\uploadAutomation\#form.Single_File#" /> --->
		<cfelse>
			<cfset useLakebaseForgetDuplicateUAUpload = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("upload_automation_log")>
<cfif useLakebaseForgetDuplicateUAUpload>
	<cftry>
		<cfset getDuplicateUAUpload = application.oLakebase.toQuery(
			application.oLakebase.selectRows("upload_automation_log", {
				"file_name" = "eq.#strFileName#",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "file_name"
			}), "file_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDuplicateUAUpload = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDuplicateUAUpload>
<cfquery name="getDuplicateUAUpload" datasource="#application.datasource#">
				SELECT  top 1 File_Name
				FROM Upload_Automation_Log
				WHERE 	File_Name = '#strFileName#'	and deleted = 0
			</cfquery>
</cfif>
			<cfif getDuplicateUAUpload.RecordCount GTE 1>
				<!--- <cffile action="delete" file="#cffile.serverDirectory#\#cffile.serverFile#"> --->
				<!--- <!--- <BR><b><u>Upload Failed due to the below reason:</u></b><BR> ---> --->
				<table align="center">
					<tr>
						<td style="font-weight:bold;color:red;">
							The invoice file with same name has already been uploaded. Please try a different invoice file.<br>
							<cfset activeTab = 0 />
						</td>
					</tr>
				</table>
				<!--- <SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 10000);</SCRIPT> 
					<CFABORT>	 --->
			<cfelse>
				<!--- <cffile action="read" file="#cffile.serverDirectory#\#cffile.serverFile#" 
				variable = "uploadedSingleFile">
				<cfset singleFilePath = "#uploadFilePath.File_Path#\#cffile.serverFile#">
				<cfset singleFileName = "#cffile.serverFile#"> 
				<cfset qGetOCRSettings = OCRSettingsManager.getOCRSettings(BBClaimSourceXrefID = #FORM.selSource#) /> --->
				<!--- <cfset qGetUASettings = UASettingsManager.getUASettings(UATemplateSettingsID = #FORM.selType#) /> --->
				<!--- BEGIN: CHECK IF THE CORRECT EXTENSION OF THE FILE IS UPLOADED --->	
				<cfset AllowableFileExt = 'txt' />
				<cfset uploadedFileExtension = ListLast(strFileName,".")>
				<cfset fileExtAllowed = 0 />
				<cfloop index = "extName" list = "#AllowableFileExt#"  delimiters = ",">
					<cfif Replace(extName,'.','') EQ uploadedFileExtension>
						<cfset fileExtAllowed = 1 />
					</cfif>
				</cfloop>
				<cfif fileExtAllowed EQ 0>
					<table align="center">
						<tr>
							<td style="font-weight:bold;color:red;">
								Please upload a "<cfoutput>#AllowableFileExt#</cfoutput>" file.
								<!--- The File with extension "<cfoutput>#uploadedFileExtension#</cfoutput>" is not correct for the Type picked. --->
								<cfset activeTab = 0 />
							</td>
						</tr>
					</table>
				<cfelse>	
					<cfset UAUploadTestLogID  = 0 />
					<!--- END: CHECK IF THE CORRECT EXTENSION OF THE FILE IS UPLOADED --->	
					<cfinclude template="inc_UA_Insert_Copy.cfm" />
					
				<br>
				<cfoutput>
					<!--- <BR><b><u>Upload Failed due to the below reason:</u></b><BR> --->
					<table align="center">
						<tr>
							<td style="font-weight:bold;">
								File "#strFileName#" has been uploaded for processing. You may monitor the progress in the below Automation File Status area.<br><br>
							</td>
						</tr>
					</table>
				</cfoutput>
					</cfif> <!--- END: <cfif fileExtAllowed EQ 0> --->	
				</cfif> <!--- <cfif getDuplicateOCRUpload.RecordCount GTE 1> --->
		</cfif>		<!--- <cfif Filesize LT 1>		 --->
		<!--- End Single File Upload and Copy --->	
<cfelse>
	<cfif (isDefined("FORM.Submitted") AND FORM.Submitted EQ "1")>
		<!--- TODO: Add checking for invoice/amount fields based on the picked type and setting --->
		in submitted...
		<!--- 
		<table align="center">
			<tr>
				<td style="font-weight:bold;color:red;">
				<cfif (NOT isDefined("FORM.selSource")) OR FORM.selSource EQ "">
					-- Source was not picked.<br>
				</cfif>
				<cfif (NOT isDefined("FORM.selType")) OR FORM.selType EQ "">
					-- Type was not picked.
				</cfif>
				<cfset activeTab = 0 />
				</td>
			</tr>
		</table>--->
	</cfif>
</cfif>
 	
<cfoutput>
		<table border="0" cellpadding="0" cellspacing="0" WIDTH="50%">
 			<tr>
				<td colspan="2">
					<!--- <div class="formLabel"> ---><strong>Select File to Upload</strong> <span id="err_single_file" style="display:none;">* Please Add File</span><!--- </div> --->
					<div>
						 <input type="file" size="90" name="single_file"  id="single_file"  accept=".txt" 
						 <cfif ((variables.inEditMode EQ 1 AND qGetAutoUploadStatus.recordcount NEQ 0 AND
									(qGetAutoUploadStatus.Upload_3000_Link EQ 0 OR qGetAutoUploadStatus.Upload_3000_Link EQ "")
									 ) OR variables.inEditMode EQ 0)>disabled </cfif> />  
					</div><br>
			</tr>	
			<tr>
				<td colspan="2" align="left">
				<cfif ((variables.inEditMode EQ 1 AND qGetAutoUploadStatus.Upload_3000_Link EQ 1) OR (variables.inEditMode EQ 1 AND qGetAutoUploadStatus.recordcount EQ 0))>
					<div align="left" width="100%" id="uploadActive"><a href="##" onclick="javascript:submitForm(this);" class="newLink">Initiate Upload</a></div>
					<div align="left" width="5" id="uploadInactive" style="display:none;"><button class="buttonDisabled" disabled>Initiate Billback</button></div>
				<cfelse>
				<div align="left" width="5" id="uploadInactive"><button class="buttonDisabled" disabled>Initiate Billback</button></div>
				</cfif>
 				</td>	
			</tr>
		</table>	
 		<br>
		<input type="hidden" value="0" id= "Submitted" name="Submitted" />
</cfoutput>
	<script>
		$( document ).ready(function() {
		    var uploadField = document.getElementById("single_file");

			uploadField.onchange = function() {
				//alert(this.files[0].size);
			    if(this.files[0].size > 50000000){
			    	var iSize = this.files[0].size/1000000;
			    	var sFileName = this.files[0].name;
			    	alert("The maximum file size is 50 MB.  Please upload a smaller file.  Current file (" + sFileName + ") is " + Math.round(iSize).toString() + " MB.");
			    	this.value = "";
			    };
			};
		});	
	</script>