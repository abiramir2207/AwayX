<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/OCR_Upload.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Upload from home page
---------------------------------------------------------------------------------->
<cfscript>
	OCRSettingsManager  = CreateObject("component","components.Billback.OCRUploadSettingsManager");
	qGetValidSources		= OCRSettingsManager.getValidSourcesForUpload();
</cfscript>

<cfif (isDefined("FORM.selSource") AND FORM.selSource NEQ "" AND  isDefined("FORM.selType") AND FORM.selType NEQ "" AND isDefined("Single_File") AND FORM.Single_File NEQ "" AND FORM.Submitted EQ "1")>
  
<!---  <cftry>	 --->
 		<cffile action="upload" destination="#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc" 
		nameconflict="overwrite" result="variables.upload"> 
		<cfset FileSize = variables.upload.fileSize>
		<cfset FileExt = variables.upload.ServerFileExt> <!--- ClientFileExt can also be used --->
		<cfset strFileName = variables.upload.ServerFile> <!--- ClientFile can also be used --->
		<cfset strServerFileName = variables.upload.ServerFileName>
		<!---If they uploaded a zero length or invalid file, redirect back with error information--->
		<cfset TotalFilePages = 0 />
		<cfif FileExt EQ "pdf">
			<cfpdf action = "getInfo" name="uploadedPDF" source="#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#strFileName#" />
			<cfset TotalFilePages = uploadedPDF.TotalPages />
		</cfif>
		
		<cfif (Filesize LT 1)>
				<!--- <BR><b><u>Upload Failed due to the below reason:</u></b><BR> --->
			<table align="center">
				<tr>
					<td style="font-weight:bold;font-color:red;">
						The size of the uploaded file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.
						<cfset activeTab = 0 />
					</td>
				</tr>
			</table>
			<cffile action="delete" file="#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#form.Single_File#" />
					<!--- <SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT>  
				<CFABORT>	--->
		<cfelseif (TotalFilePages GT 300)>
			<table align="center">
				<tr>
					<td style="font-weight:bold;font-color:red;">
						<cfoutput>
						<font color="red">
							Error: Please choose a file with less than 250 page. "#strFileName#" has #TotalFilePages# pages.
						</font>
						</cfoutput>
						<cfset activeTab = 0 />
					</td>
				</tr>
			</table>
			<!--- <cffile action="delete" file="#Application.Doc_Path#\data_files\uploaded\documents\uploaded_doc\#form.Single_File#" /> --->
		<cfelse>
			<cfquery name="getDuplicateOCRUpload" datasource="#application.datasource#">
				SELECT  top 1 File_Name
				FROM OCR_Upload_log
				WHERE 	File_Name = '#strFileName#'	and deleted = 0
			</cfquery>
			<cfif getDuplicateOCRUpload.RecordCount GTE 1>
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
				<cfset qGetOCRSettings = OCRSettingsManager.getOCRSettings(OCRTemplateSettingsID = #FORM.selType#) />
				<!--- BEGIN: CHECK IF THE CORRECT EXTENSION OF THE FILE IS UPLOADED --->	
				<cfset AllowableFileExt = qGetOCRSettings.Allowable_File_Ext />
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
					<cfset OCRUploadTestLogID  = 0 />
					<!--- END: CHECK IF THE CORRECT EXTENSION OF THE FILE IS UPLOADED --->	
					<cfinclude template="inc_OCR_Insert_Copy.cfm" />
					
				<br>
				<cfoutput>
					<!--- <BR><b><u>Upload Failed due to the below reason:</u></b><BR> --->
					<table align="center">
						<tr>
							<td style="font-weight:bold;">
								File "#strFileName#" has been uploaded for processing. You may monitor the progress in the Manage Status area.<br><br>
							</td>
						</tr>
					</table>
				</cfoutput>
					</cfif> <!--- END: <cfif fileExtAllowed EQ 0> --->	
				</cfif> <!--- <cfif getDuplicateOCRUpload.RecordCount GTE 1> --->
		</cfif>		<!--- <cfif Filesize LT 1>		 --->
		<!--- End Single File Upload and Copy --->	
		<!--- <cfcatch>
			<cfif (cfcatch.Detail NEQ "" AND FindNoCase("Saving empty (zero-length) files is prohibited", cfcatch.Detail) NEQ 0)>
			<!--- <BR><b><u>Upload Failed due to the below reason:</u></b><BR> --->
				<table align="center">
					<tr>
				  		<td style="font-weight:bold;color:red;">
							The size of the uploaded file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.<br><br>
							<cfset activeTab = 0 />
						</td>
					</tr>
				</table>
		  	<cfelse>
				<br><br>
				The below error occured in Step 1, when trying to "Upload/Read/Copy" File:
				<br><br>
				<cfoutput>
					<b>Type:</b> #cfcatch.Type# <br><br>
					<b>Message:</b> #cfcatch.Message# <br><br>
					<cfif cfcatch.Detail NEQ "">
						<b>Detail:</b> #cfcatch.Detail# <br><br>
					</cfif>
					<!--- 	<strong>TagContext:</strong> #cfcatch.TagContext# <br><br> --->
				</cfoutput>
			</cfif>
				<!--- <cfinclude template="errorCatcher.cfm"> 
				<cfabort> --->
		</cfcatch>
	</cftry>	 --->
<cfelse>
	<cfif (isDefined("FORM.Submitted") AND FORM.Submitted EQ "1")>
		<!--- TODO: Add checking for invoice/amount fields based on the picked type and setting --->
		
		<!--- --->
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
		</table>
	</cfif>
</cfif>
 	
<cfoutput>
	<form id="uploadOCRFiles" name="uploadOCRFiles" method="post" action="index.cfm" ENCTYPE="multipart/form-data" > 
		<table border="0" cellpadding="0" cellspacing="0" WIDTH="50%">
			<tr>
				<td align="left" width="25%">
					<strong>Source:</strong><br> 
						<select name="selSource" id="selSource" size="3" style="width:200px" data-placeholder="Select a Source" style="z-index: 5000 !important;">
							 <option></option><!--- needed for data-placeholder  --->
							<cfloop query="qGetValidSources">
								<option value="#BB_Claim_Source_XREF_ID#">#Source_Code#</option>
							</cfloop>
						</select>
				</td>
			</tr>	
 			<tr class="trType" style="display:none">
 				<td align="left"> <br>
					<strong>Type:</strong> <br>
						<div style="display: flex; justify-content: left; width:100%;min-width:700px;">
							<div id="makeMeScrollable">		
								<table border="0" cellpadding="2" cellspacing="2" class="tblType">
								<tr class="imgDisp"><td valign="bottom"><img src="/images/OCR/null.png"/></td></tr>
								<tr class="txtDisp"><td valign="bottom"><input type="radio" id="selType" class="selType" name="selType"></td></tr>
					  			</table> 
							</div>
						</div>	
				</td>
 			</tr> 
			<tr>
				<td colspan="100%">
					<div id="divAmount" style="display:block">
						<strong><p title="Sum of all the invoice amounts in the file">Total Invoice Amount:</strong><br><input type="Text" name="Amount" id="Amount"  class="inputRounded" onKeyUp="clenseText(this, '.0123456789');"  /></p>
					</div>
					<div id="divInvoiceDateOnly" class="divInvoiceDateOnly"><strong>Invoice Date:</strong><br></div>
					<cfset txtCount = 4 /> 
				<div id="divInvAmount" style="display:none">
							<br>
							<cfoutput>
							<table  border="1" width="550" cellpadding="0" cellspacing="2" rules="groups">
								<tr>
									<td colspan="100%">
										<table border="0" cellpadding="5" cellspacing="2" class="tblDivAmount" width="100%">
											<tr>
												<td bgcolor="##555555" colspan="100%">
													<font color="white"><div id="divTemplateName"></div></font>
												</td>
											</tr>
											<tr>
												<td width="3%">&nbsp;</td>
												<td width="26%"><div id="divInvNum"><strong>Invoice Number:</strong></div></td>
												<td width="26%"><div id="divNumAmt"><strong>Invoice Amount:</strong></div></td>
												<td width="15%"><div id="divStartDate"><strong>Start Date:</strong></div></td>
												<td width="15%"><div id="divEndDate"><strong>End Date:</strong></div></td>
												<td width="15%"><div id="divInvoiceDate"><strong>Invoice Date:</strong></div></td>												
											</tr>
										</table>	
									</td>
								</tr>		
								<tr>
									<td colspan="50%">
										&nbsp;&nbsp;&nbsp;&nbsp;<div id="divAddAnother">&nbsp;&nbsp;&nbsp;&nbsp;<a href="" class="add_field_button">+ Add another</a></div>
									</td>
								</tr>
							</table>
		</cfoutput>						
						</div><br>
				</td>
			</tr>
 			<tr>
				<td colspan="2">
					<!--- <div class="formLabel"> ---><strong>Select Invoice File to Upload</strong> <span id="err_single_file" style="display:none;">* Please Add File</span><!--- </div> --->
					<div>
						 <input type="file" size="90" name="single_file"  id="single_file"  accept=".pdf,.xlsx,.xls,.csv,.tab"/><!--- .pdf;.xlsx ---> 
					</div><br>
			</tr>	
			<tr>
				<td colspan="2" align="left">				
					<div align="left" width="100%" id="uploadActive"><a href="##" onclick="javascript:submitForm(this);" class="newLink">Initiate Billback</a></div>
					<div align="left" width="5" id="uploadInactive" style="display:none;"><button class="buttonDisabled" disabled>Initiate Billback</button></div>
 				</td>	
			</tr>
		</table>	

<!--- <div id="makeMeScrollable">
<img scr="/images/ocr/null_big.png">
</div>	 --->		
 		<br>
		<input type="hidden" value="1" id= "curTRCount" name="curTRCount" />
		<input type="hidden" value="0" id= "Submitted" name="Submitted" />
	</form> 
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