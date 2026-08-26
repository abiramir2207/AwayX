<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/OCR_Upload/Scheduled/incDocparser.cfm
Copyright    :  (c) 2017 Blacksmith Applications, Inc.
Created Date :  28-Feb-17
Created By   :  Anand Rao
Description  :  Upload from home page
---------------------------------------------------------------------------------->
<!--- <cfdump var="#qGetOCRUploadExtracted#" /> --->
	<cfif (qGetOCRUploadExtracted.OCR_Reader_Name EQ "ABBYY&DOCPARSER")>
		<cfset srcPDFFile =	qGetOCRUploadExtracted.OCR_File_PostProcess_Txt_Path & "\" & qGetOCRUploadExtracted.File_Name /> 
	<cfelse>
		<cfset srcPDFFile 		= qGetOCRUploadExtracted.OCR_File_PreProcess_Path & "\" & qGetOCRUploadExtracted.File_Name />
	</cfif>

	<cfset postPDFFile 		= qGetOCRUploadExtracted.OCR_File_PostProcess_Path & "\" & qGetOCRUploadExtracted.File_Name />
	<cfset archiveLocation 	= qGetOCRUploadExtracted.OCR_File_PostProcess_Path & "\archive" />
	<cfset DBDest		 	= qGetOCRUploadExtracted.DB_File_Preprocess_Path />
	<cfset DocParserAuth	= qGetOCRUploadExtracted.Account_ID />
<cftry>
	<cfif ((qGetOCRUploadExtracted.Document_ID EQ "") OR (qGetOCRUploadExtracted.Special_Processing_Flag EQ "1" AND qGetOCRUploadExtracted.Document_ID NEQ "" AND qGetOCRUploadExtracted.Document_ID_2 EQ "" AND qGetOCRUploadExtracted.OCR_Sub_Step EQ "3") AND FileExists(srcPDFFile))>
		<!--- DOCPARSER related code --->
		<cfset UUID = createUUID() />
		<cfset remoteID =  UUID & "_" & qGetOCRUploadExtracted.OCR_Upload_ID />
		<!--- SEND THE REQUEST TO DOC PARSER TO PROCESS THE FILE --->
 
		<cfhttp   method="post"  url = "https://api.docparser.com/v1/document/upload/#qGetOCRUploadExtracted.Parser_ID#"  result="getDocID">
			<cfhttpparam type="header" name="Authorization" value="Basic #DocParserAuth#" />
			<cfhttpparam type="file" file="#srcPDFFile#" name="file"/>
			<cfhttpparam type="FormField"  name="remote_id" value="#remoteID#"/>			
			<!--- <cfhttpparam type="formField" file="#qGetOCRUploadExtracted.OCR_Upload_ID#" name="remote_id"/> TEST  THIS LATER --->
		</cfhttp>
	
		<cfset record=deserializeJSON(getDocID.FileContent) />
  		<cfset recordError = "" />
  		<cfif isDefined("record.error")>
  			<cfset recordError = ToString(record.error) />
  		</cfif>
		<!--- HANDLE FOR CHECKING IF THE DOCPARSER IS RETURNING ERROR DUE TO NO OF PAGES IN THE PDF --->
 		<cfif (isDefined("record.error") AND recordError EQ "file has too many pages. max allowed page count for your account is 250.") ><!--- FindNoCase(recordError,'file has too many pages') --->
			<!--- <cfquery name="updateOCRUploadLogDocumentID" datasource="#application.datasource#">
				UPDATE OCR_Upload_Log 
						SET 
							OCR_Step = '2.CF_Error',
							OCR_Upload_Status = 'Could not read data from docparser due to Page limit error from docparser',
							Debug_Dev_Status = 'Error set by code after the docparser returned the error "#recordError#"',
							ProcessTries = ProcessTries + 1,
							Updated_Date = getDate(),
							Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice, due to exceeding the page limit of 250. Please try again or contact ciasupport@blacksmithapplications.com'
					WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
			</cfquery>	 --->

<!--- 			<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error - Source '#qGetOCRUploadExtracted.OCR_Code#' -  #qGetOCRUploadExtracted.OCR_Template_Description# on '#application.datasource#' Failed for Upload ID:#qGetOCRUploadExtracted.OCR_Upload_ID#">
				Please see what needs to be fixed:<br><br>
				<a href="#uploadInfoSiteURL##qGetOCRUploadExtracted.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadExtracted.OCR_Upload_ID#</a><br><br>
				Note: Customers may not see the invoices failing at SOURCE.
			</cfmail> --->
			<cffile action="move" source="#srcPDFFile#" destination="#archiveLocation#">
		<cfelseif (isDefined("record.id") and record.id NEQ "")>
			<cfquery name="updateOCRUploadLogDocumentID" datasource="#application.datasource#">
				UPDATE 
					OCR_Upload_Log 
				SET 
					-- Document_ID = '#record.id#',
					<cfif (qGetOCRUploadExtracted.Document_ID EQ "")>
						Document_ID = '#remoteID#',
						Debug_Dev_Status = 'Document ID updated'
					<cfelseif ((qGetOCRUploadExtracted.Document_ID NEQ "") AND (qGetOCRUploadExtracted.Document_ID_2 EQ ""))>
						Document_ID_2 = '#remoteID#',
						Debug_Dev_Status = 'Document ID 2 updated',
						OCR_Sub_Step = '4',
						OCR_Sub_Step_Description = 'Pass 4: Document ID 2 has been updated..'

					</cfif>
				WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
			</cfquery>	
			<cffile action="move" source="#srcPDFFile#" destination="#postPDFFile#">
		</cfif>	
	<cfelse>				
		<!--- SEND THE REQUEST TO RECEIVE THE EXTRACTED TEXT AS JSON  --->
		
		<cfhttp   method="get"  url = "https://api.docparser.com/v1/results/#qGetOCRUploadExtracted.Parser_ID#"  result="getFileContent"> <!--- /#qGetOCRUploadExtracted.Document_ID# --->
			<cfhttpparam type="header" name="Authorization" value="Basic #DocParserAuth#" />
			<cfhttpparam type="formfield"  name="format" value="object" /> <!--- This will return the result Filecontent as a JSON format --->
			<cfif qGetOCRUploadExtracted.Document_ID_2 NEQ "">
				<cfhttpparam type="formfield"  name="remote_id" value="#qGetOCRUploadExtracted.Document_ID_2#"/>
			<cfelse>	
				<cfhttpparam type="formfield"  name="remote_id" value="#qGetOCRUploadExtracted.Document_ID#"/>
			</cfif>
			<cfhttpparam type="formfield"  name="limit" value="9999" />		
			<cfhttpparam type="formfield"  name="include_processing_queue" value="true" />	
			<!--- <cfhttpparam type="formfield"  name="format" value="flat" />  This will give flat format output as Key/Value Pair ---> 
		</cfhttp>
		<cfset structFileContent=deserializeJSON(getFileContent.FileContent) />
		<!--- <cfif (isDefined("textData.error") and textData.error NEQ "File not yet processed.")> --->	
		<!--- TODO: HANDLE FOR ERROR --->
<!---  <cfdump var="#qGetOCRUploadExtracted#" />		
<cfdump var="#structFileContent#" />	 ---> 
		<cfif ( 
				( 
					qGetOCRUploadExtracted.OCR_Step EQ '2' AND		 
		 		 	(
						(isStruct(structFileContent) AND StructIsEmpty(structFileContent))  
						OR 
 		 		 		(isarray(structFileContent) AND ArrayIsEmpty(structFileContent))
					)
				 	AND qGetOCRUploadExtracted.Special_Processing_Flag NEQ "1"
				)
				 
				 OR
				(
					 qGetOCRUploadExtracted.OCR_Step EQ '2' AND		 
			 		 (
					 	(isStruct(structFileContent) AND StructIsEmpty(structFileContent))  
						OR 
	 		 		 	(isarray(structFileContent) AND ArrayIsEmpty(structFileContent))
					 )
					 AND qGetOCRUploadExtracted.Special_Processing_Flag EQ "1" AND qGetOCRUploadExtracted.Document_ID_2 NEQ ""
				 )
		)>
		<!--- IN IF --->
			<cfset useLakebaseForupdateOCRUploadLogStatusError1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ocr_upload_log")>
<cfif useLakebaseForupdateOCRUploadLogStatusError1>
	<cftry>
		<cfset application.oLakebase.updateRows("ocr_upload_log",
			{
				"ocr_upload_id" = "eq.#qGetOCRUploadExtracted.OCR_Upload_ID#"
			},
			{
				"ocr_step" = "2.CF_Error",
				"ocr_upload_status" = "Empty structure was returned from docparser because the invoice file did not have the required keyword",
				"debug_dev_status" = "Empty structure was returned from docparser",
				"processtries" = "1",
				"updated_date" = "#now()#",
				"error_tool_tip" = "Please try again with a different source type. The invoice file format did not match the format of the selected source type"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateOCRUploadLogStatusError1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateOCRUploadLogStatusError1>
<cfquery name="updateOCRUploadLogStatusError1" datasource="#application.datasource#">
					UPDATE OCR_Upload_Log 
						SET 
							OCR_Step = '2.CF_Error',
							OCR_Upload_Status = 'Empty structure was returned from docparser because the invoice file did not have the required keyword',
							Debug_Dev_Status = 'Empty structure was returned from docparser',
							ProcessTries = 1,
							Updated_Date = getDate(),
							Error_Tool_Tip = 'Please try again with a different source type. The invoice file format did not match the format of the selected source type'
					WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
				</cfquery>
</cfif>	<!--- ((isStruct(structFileContent) AND StructIsEmpty(structFileContent))  OR 
 		 		 (isarray(structFileContent) AND ArrayIsEmpty(structFileContent))  OR 	 --->
		 <cfelseif ( qGetOCRUploadExtracted.OCR_Step EQ '2' AND		 
 		  		 	(isDefined("getFileContent.FileContent") AND 
				 	 (FindNoCase(getFileContent.FileContent, 'File not yet processed') GTE 1 )
					) 
				 )>   
				<!--- IN ELSEIF 2 --->
<!---  			 <cfif ( qGetOCRUploadExtracted.OCR_Step EQ '2' AND		 
		 		 ((isStruct(structFileContent) AND StructIsEmpty(structFileContent))  OR 
 		 		 (isarray(structFileContent) AND ArrayIsEmpty(structFileContent))  OR 	
 		  		 (isDefined("getFileContent.FileContent") AND (FindNoCase(getFileContent.FileContent, 'File not yet processed') GTE 1 )))
				 )>	  --->
			<cfif (qGetOCRUploadExtracted.ProcessTries GT 10)>
				<cfquery name="updateOCRUploadLogStatusError1" datasource="#application.datasource#">
					UPDATE OCR_Upload_Log 
						SET 
							OCR_Step = '2.CF_Error',
							OCR_Upload_Status = 'Docparser slow or Docparser page limit has ran out',
							Debug_Dev_Status = 'Docparser failed to return data for more than 10 mins. Error set by code after ProcessTries flag reached max limit of 10.',
							ProcessTries = ProcessTries + 1,
							Updated_Date = getDate(),
							Error_Tool_Tip = 'Sorry, our service had a problem reading this invoice. Please rename the file and try again or contact ciasupport@blacksmithapplications.com'
					WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
				</cfquery>	
				<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error - '#qGetOCRUploadExtracted.Source_Code#' -  #qGetOCRUploadExtracted.OCR_Template_Description# on '#application.datasource#' Failed for Upload ID:#qGetOCRUploadExtracted.OCR_Upload_ID# at SOURCE">
				Please see what needs to be fixed:<br><br>
				<a href="#uploadInfoSiteURL##qGetOCRUploadExtracted.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadExtracted.OCR_Upload_ID#</a><br><br>
			</cfmail>
			<cfelse>
				<cfquery name="updateOCRUploadLogStatusError1" datasource="#application.datasource#">
					UPDATE OCR_Upload_Log 
					SET 
							/* OCR_Step = '1',	
							OCR_Upload_Status = 'Trying to Read data from doc parser',
							Debug_Dev_Status = 'Trying to read data in doc parser failed with error',*/ 
							ProcessTries = ProcessTries + 1,
							Updated_Date = getDate()				
					WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
				</cfquery>	
			</cfif>
		<cfelseif ( qGetOCRUploadExtracted.OCR_Step EQ '2' AND		 
		 		 ((isStruct(structFileContent) AND StructIsEmpty(structFileContent))  OR 
 		 		 (isarray(structFileContent) AND ArrayIsEmpty(structFileContent)))
				 AND qGetOCRUploadExtracted.Special_Processing_Flag EQ "1" AND  
				 qGetOCRUploadExtracted.Document_ID_2 EQ ""
		)>
		<!--- IN ELSEIF 3 --->
			<!--- <cfif (qGetOCRUploadExtracted.Special_Processing_Flag EQ "1" AND (qGetOCRUploadExtracted.Document_ID NEQ "") AND  (qGetOCRUploadExtracted.Document_ID_2 EQ ""))> --->
				<cfquery name="updateOCRUploadLogSubStep1" datasource="#application.datasource#">
					UPDATE OCR_Upload_Log 
					SET 
						OCR_Step	=  '1',	
						OCR_Sub_Step = '2',
						OCR_Sub_Step_Description = 'Pass 2: setting to OCR_Step = 1, OCR_Sub_Step = 2, to be picked by ABBYY', 
						OCR_Upload_Status = 'Setting the ocr_step to 1 To be picked up by ABBYY',
						ProcessTries = 0,
						Updated_Date = getDate()
					WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
				</cfquery>
			<!--- </cfif> --->
		<cfelse>
		<!--- IN ELSE --->
		 <!---- <cfdump var="#qGetOCRUploadExtracted.OCR_Code#" /> --->
 		<cfif (qGetOCRUploadExtracted.OCR_Code EQ "PFG_OT8")><!--- (qGetOCRUploadExtracted.DB_OCR_Source_Code EQ "Trackmax1") --->
 			<cfinclude template = "inc_PFG_OT8.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "PFG_OT1")>
			<cfinclude template = "inc_PFG_OT1.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "PFG_OT6")>
			<cfinclude template = "inc_PFG_OT6.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "PFG_OT11")>
			<cfinclude template = "inc_PFG_OT11.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "SYSCO_OT1_OT9")>
 			<cfinclude template = "inc_Sysco_OT1_OT9.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "SYSCO_OT2_OT4_OT6")>
 			<cfinclude template = "inc_Sysco_OT2_OT4_OT6.cfm" />
		<!--- <cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "SYSCO_OT7")>
 			<cfinclude template = "Inc_Sysco_OT7.cfm" /> --->
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "SYSCO_OT13")>
 			<cfinclude template = "Inc_Sysco_OT13.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "SYSCO_TT1")>
 			<cfinclude template = "Inc_Sysco_TT1.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "SYSCO_TT13")>
 			<cfinclude template = "Inc_Sysco_TT13.cfm" />
		<!--- <cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "SYSCO_TT7")>
 			<cfinclude template = "Inc_Sysco_TT7.cfm" /> --->
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "SYSCO_TT2_TT4_TT6")>
 			<cfinclude template = "inc_Sysco_TT2_TT4_TT6.cfm" />
 		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "KROGER")>				
			<cfinclude template = "inc_Kroger.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "GFS_CA_TRADE")>				
			<cfinclude template = "Inc_GFS_CA_TRADE.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "GFS_CA_OPR")>				
			<cfinclude template = "inc_GFS_CA_OPR.cfm" />		
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "GFS_US_TRADE_300")>
			<cfinclude template = "inc_GFS_US_TRADE.cfm" />
		<cfelseif (qGetOCRUploadExtracted.OCR_Code EQ "PFG_TT8")>
			<cfinclude template = "inc_PFG_TT8.cfm" />	
		</cfif>		<!--- END: <cfif (qGetOCRUploadExtracted.OCR_Code EQ "PFG_OT8")> --->
	
	</cfif> <!--- END: <cfif (isDefined("textData.error") and textData.error NEQ "File not yet processed.")>	 --->
</cfif> <!--- END: <cfif qGetOCRUploadExtracted.Document_ID EQ ""> --->
<cfcatch>
		<cfquery name="updateOCRUploadLogStatus5" datasource="#application.datasource#">
			UPDATE OCR_Upload_Log 
			SET 
				OCR_Step = '2.CF_Error',
				OCR_Upload_Status = 'Sorry, our service had a problem reading this invoice. Please rename the file and try again or contact ciasupport@blacksmithapplications.com',
				Debug_Dev_Status = 'In docParser.cfm Checkpoint 2. catch block. The parser failed to return the data. ERROR:"#cfcatch.Message#"::"#cfcatch.Detail#". The data location are not correct in the file and did not match the docparser template.',
				Updated_Date = getDate(),
				Error_Tool_Tip = 'Please try again with a different source type. The invoice file format did not match the format of the selected source type.'
			WHERE OCR_Upload_ID = '#qGetOCRUploadExtracted.OCR_Upload_ID#'
		</cfquery>
		<cfmail to="#toEmail#" from="#fromEmail#" type="HTML" subject="CIA-Error - '#qGetOCRUploadExtracted.Source_Code#' -  #qGetOCRUploadExtracted.OCR_Template_Description# on '#application.datasource#' Failed for Upload ID:#qGetOCRUploadExtracted.OCR_Upload_ID# at SOURCE">
				Please see what needs to be fixed:<br><br>
				<a href="#uploadInfoSiteURL##qGetOCRUploadExtracted.OCR_Upload_ID#">#uploadInfoSiteURL##qGetOCRUploadExtracted.OCR_Upload_ID#</a><br><br>
		</cfmail>
</cfcatch>
</cftry>