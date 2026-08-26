<cfsilent>
<!---
	Name         : upload_file.cfm
	Copyright    : Copyright (c) 2010 Blacksmith Applications, Inc.
	Created Date : 12/01/2010
	Created By   : Kal
	Label        : 25195
	Description  : Mass Program Change Upload Utility
--->
</cfsilent>
<SCRIPT type="text/javascript">
	function submitForm(submitter)
	{
		var thisForm = document.all.uploadFile;
		var uploadedFile = thisForm.upload_file;

		var errors = 0;
		var errorMsg = '';

		// no action type
		if (!($('input[name=updateType]:checked').val() == 'revise'
			|| $('input[name=updateType]:checked').val() == 'revise-copy'
			|| $('input[name=updateType]:checked').val() == 'cancel'
			|| $('input[name=updateType]:checked').val() == 'copy'
			))
		{
			errors ++;
			errorMsg = errorMsg + 'select and upload action';
		}

		// no file selected
		if(uploadedFile.value.length == 0){
			errors++;
			errorMsg = errorMsg + '\n' + 'select a file to upload';
		}


		if(errors == 0){
			thisForm.submit();
		}
		else {
			alert(errorMsg);
			return false;
		}
	}

</SCRIPT>
<cfparam name="bValidSpreadSheet" default="1" />
<cfparam name="spreadSheetError" default="" />

<cfif isdefined("form.upload_file") AND len(form.upload_file)>
	<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
	<cfset uploadFilePath = uploadUtility.getUploadPath() />
	<!---<cfdump var="#Application.Doc_Path#" >--->
	<cffile
			action="upload" result="uploadResult"
			filefield="upload_file"
			destination="#Application.Doc_Path#\Data_Files\Uploaded\programs"
			nameconflict="overwrite" />

	<cftry>
		<cfspreadsheet action="read" src="#uploadResult.serverDirectory#\#uploadResult.serverFile#"
					   sheet=1 headerrow="1" excludeheaderrow="true" query="qData">
		<cfcatch type="any">
			<cfscript>
				//make sure all the cols are there
				bValidSpreadSheet = 0;
				spreadSheetError = 'Could not parse file (#uploadResult.serverFile#).  <br>Be sure it is a valid Excel (.xls or .xlsx) file.';
				qData = queryNew('x');
			</cfscript>
		</cfcatch>
	</cftry>

	<!--- Clear Data from last run --->
	<cfquery name="qClearData" datasource="#application.datasource#">
			TRUNCATE TABLE MPCU_Data
	</cfquery>

	<cfif bValidSpreadSheet>
		<cfscript>
			//make sure all the cols are there (if it is a valid file)
			keyArray = 	['COMPONENT_ID',
						'CONTRACT_END_DATE',
						'CONTRACT_NUMBER',
						'CONTRACT_START_DATE',
						'CONTRACT_TITLE',
						'CURRENCY',
						'DISCOUNT_TYPE',
						'ITEM',
						'NOTES',
						'PRICE',
						'UOM',
						'VOLUME'];
			//loop the 'keys' and make sure the spreadsheet (qData)	has an entry for each one
			for (i=1;i LTE ArrayLen(keyArray);i=i+1) {
				if(!StructKeyExists(qData,keyArray[i])){
					bValidSpreadSheet = 0;
					if(spreadSheetError == ''){
						spreadSheetError = '  Missing Columns:';
					}
					spreadSheetError = spreadSheetError & '<li>' & keyArray[i];
				}
			}
			//default for next section
			objLocked = structNew();
		</cfscript>
		<!--- loop over the spread sheet data [stored as a query] and insert into db --->
		<cfif bValidSpreadSheet>
			<cfoutput query="qData">
				<cfscript>
				
					//Tim Ford - 10/11/2013: Label 39717 - EVENT ERROR - MASS PROGRAM CHANGE UPLOAD UTILITY - We have to validate some data to eliminate empty records from the spreadsheet
					if(len(trim(qData.CONTRACT_NUMBER)) and len(trim(qData.CONTRACT_START_DATE)) and len(trim(qData.CONTRACT_END_DATE))){
						
						// when year is 99, it will be converted to 1999. 12/31/99 will be converted to 12/31/1999 instead of 12/31/9999. so manually convert it to 12/31/9999
						if (datePart('yyyy', qData.CONTRACT_START_DATE) eq '1999'){ qData.CONTRACT_START_DATE = dateAdd('yyyy', 8000, qData.CONTRACT_START_DATE);}
						if (datePart('yyyy', qData.CONTRACT_END_DATE) eq '1999'){ qData.CONTRACT_END_DATE = dateAdd('yyyy', 8000, qData.CONTRACT_END_DATE);}
	
						//dates are read in as mm/dd/yy, so converting to mm/dd/yyyy;
						qData.CONTRACT_START_DATE = dateFormat(qData.CONTRACT_START_DATE, 'mm/dd/yyyy');
						qData.CONTRACT_END_DATE = dateFormat(qData.CONTRACT_END_DATE, 'mm/dd/yyyy');
	
						//create arguments obj to insert into db
						objArgs = structNew();
						for (i=1;i LTE ArrayLen(keyArray);i=i+1) {
							value = qData[keyArray[i]];
							value = REPLACE(value,'\/','/',"all" );
							objArgs[keyArray[i]] = value;
						}
						//Check Program Lock only once
						isLocked = 0;
						contractKey = replace(objArgs.CONTRACT_NUMBER,'-','','all' );
						if(structKeyExists(objLocked,contractKey) == true){
							//no messages here.  just set locked bool
							isLocked = objLocked[contractKey];
						}
						else{
							islocked = MPCUManager.checkContractLock(objArgs.CONTRACT_NUMBER);
							//set display message here.  happens only once per contract_number
							if(islocked){
								spreadSheetError = spreadSheetError & '<li>' & objArgs.CONTRACT_NUMBER & ' is Locked by another process.  Please check the program or try again later.';
							}
							else{
								spreadSheetError = spreadSheetError & '<li>' & objArgs.CONTRACT_NUMBER & ' sent to validation.';
							}
							//set key in struct so we dont need to test again
							objLocked[contractKey] = isLocked;
						}
						
						//every row needs to go to validation if it is not locked
						if(islocked == false){
							//insert into db.  Ignore empty rows (no contract_number)
							if(trim(objArgs.CONTRACT_NUMBER) != ''){
								MPCUManager.insertFileData(argumentcollection = objArgs);
							}
						}
					}
				</cfscript>
			</cfoutput>

			<!--- set the update type and the user  --->
			<cfset MPCUManager.setUpdateType(request.accessstructure.user_ID, variables.updateType)>
			<!--- validate the uploaded file --->
			<cfstoredproc procedure="USP_Program_Upload_Validate" datasource="#application.datasource#">
				<cfprocparam cfsqltype = "cf_sql_varchar" type = "in" value = "#variables.updateType#">
			</cfstoredproc>
		</cfif> <!--- END: bValidSpreadSheet STEP 2  --->
	</cfif> <!--- END: bValidSpreadSheet  --->
</cfif> <!---END: isdefined("form.upload_file")  --->


<!--- when the form is locked by other user, we will replace the html in this div --->
<div id="uploadFileForm" class="buttonText" >
	<cfoutput>#spreadSheetError#</cfoutput>
	<table>
		<tr>
			<td valign="top">
				<form id="uploadFile" name="uploadFile" class="buttonText" method="post" action="index.cfm" enctype="multipart/form-data">
					<fieldset>
						<legend class="buttonText">Select Upload File</legend>
						<br/>
						<input type="radio" name="updateType" value="revise">revise
						<input type="radio" name="updateType" value="revise-copy">revise & copy
						<input type="radio" name="updateType" value="cancel">cancel
						<input type="radio" name="updateType" value="copy">copy
						<br/><br/>
						<input type="file" size="70" name="upload_file" /> <span id="err_upload_file" style="display:none;">* Please Add File</span><br>
						<div align="right" width="100%" class="buttonText">
							<cfoutput>
								<span class="redBracket">[</span><a href="errorFileDownload.cfm" title="recent file">download file</a><span class="redBracket">]</span>
								<span class="redBracket">[</span><a href="##" onclick="javascript:submitForm(this);">upload file</a><span class="redBracket">]</span>
							</cfoutput>
						</div>
					</fieldset>
				</form>
			<td>
		<tr>
	</table>
</div>