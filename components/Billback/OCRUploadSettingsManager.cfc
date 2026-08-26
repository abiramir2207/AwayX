<cfcomponent hint="Billback Settings Manager" extends="components.Base">

	<cffunction name="getOCRSettings" returntype="any">		
		<cfargument name="bActive" required="false" default="" />
		<cfargument name="OCRTemplateSettingsID" required="false" default="" />
		<cfargument name="BBClaimSourceXrefID" required="false" default="" />
		
		<cfquery name="qGetOCRSettings" datasource="#application.datasource#">
			SELECT * FROM OCR_Template_Settings		
			WHERE 1=1 
			<cfif isDefined("arguments.bActive") AND arguments.bActive NEQ "" >
				AND Active = #arguments.bActive#
			</cfif>	
			<cfif (isDefined("arguments.OCRTemplateSettingsID") AND arguments.OCRTemplateSettingsID NEQ "")>
				AND OCR_Template_Settings_ID = #arguments.OCRTemplateSettingsID#
			</cfif>	
			<cfif (isDefined("arguments.BBClaimSourceXrefID") AND arguments.BBClaimSourceXrefID NEQ "")>
					AND BB_Claim_Source_XREF_ID = #arguments.BBClaimSourceXrefID#
			</cfif>
			ORDER BY Rank_Order
		</cfquery>
		
		<cfreturn qGetOCRSettings>
	</cffunction>

	<cffunction name="getValidSources" returntype="any">		
 		<cfquery name="qGetValidSources" datasource="#application.datasource#">
			SELECT 
				BB_Claim_Source_XREF_ID,
				Source_Type,
				Source_Type_Description,
				Source_Code
			FROM 
				dbo.BB_Claim_Source_XREF 
			WHERE 
				Display_in_OCR = 1 AND 
				Deleted = 0 AND 
				Active = 1
		</cfquery>
		<cfreturn qGetValidSources>
	</cffunction>
	
	<cffunction name="getValidSourcesForUpload" returntype="any">		
		<cfquery name="qGetValidSources" datasource="#application.datasource#">
			SELECT Distinct
				-- OTS.OCR_Template_Settings_ID,
				-- OTS.OCR_Template_Name,
				-- BBCSX.Source_Code + ' - '+OTS.OCR_Template_Name AS Source, 
				BBCSX.BB_Claim_Source_XREF_ID,
				BBCSX.Source_Type,
				BBCSX.Source_Type_Description,
				BBCSX.Source_Code
			FROM 
				BB_Claim_Source_XREF BBCSX
			INNER JOIN OCR_Template_Settings OTS ON OTS.BB_Claim_Source_XREF_ID = BBCSX.BB_Claim_Source_XREF_ID
				-- AND BBCSX.IS_OCR_Required = 1
				AND BBCSX.Display_In_OCR = 1
			WHERE 
				BBCSX.Display_in_OCR = 1 AND 
				BBCSX.Deleted = 0 AND 
				BBCSX.Active = 1
				AND OTS.Deleted = 0
			ORDER BY BBCSX.Source_Code	
		</cfquery>
		<cfreturn qGetValidSources>
	</cffunction>	
	
	<!--- <cffunction name="getOCRSettings" returntype="any">		
	<cfargument name="BB_Claim_Source_XREF_ID" 				required="false" default="" />
		<cfquery name="qGetOCRSettings" datasource="#application.datasource#">
			SELECT OCR_Template_Settings_ID,
					OCR_Template_Name,
					OCR_File_Landing_Path,
					OCR_File_Landing_Path_Processed,
					OCR_File_PreProcess_Path,
					OCR_File_PostProcess_Path,
					OCR_File_PostProcess_Txt_Path,
					DB_File_Preprocess_Path,
					Created_User_ID,
					Created_Date,
					OCR_Template_Status,
					Search_String,
					Active,
					Deleted,
					Deleted_By,
					Deleted_Date,
					BB_Claim_Source_XREF_ID,
					Source_Code,
					Allowable_File_Ext,
					Search_Order,
					Client_Name,
					DB_OCR_Root_Path,
					DB_OCR_Source_Code,
					IS_OCR_Required,
					Search_Order,
					DB_OCR_Root_Path,
					DB_OCR_Source_Code,
					IS_OCR_Required
			FROM 
				OCR_Template_Settings
			WHERE 
				Deleted = 0 AND 
				Active = 1
				<cfif isDefined("arguments.BB_Claim_Source_XREF_ID") AND arguments.BB_Claim_Source_XREF_ID NEQ "")>
					AND BB_Claim_Source_XREF_ID = #arguments.BB_Claim_Source_XREF_ID#
				</cfif>
		</cfquery>
		
	<cfreturn qGetOCRSettings>
	</cffunction>	
	 --->
	
	<cffunction name="insUpdOCRSettings" returntype="any">	
		<cfargument name="OCR_Action" 						required="false" default="" />
		<cfargument name="OCRTemplateSettingsID" 			required="false" default="" />
		<cfargument name="OCR_Template_Name" 				required="false" default="" />
		<cfargument name="OCR_File_Landing_Path" 			required="false" default="" />
		<cfargument name="OCR_File_Landing_Path_Processed" 	required="false" default="" />
		<cfargument name="OCR_File_PreProcess_Path" 		required="false" default="" />
		<cfargument name="OCR_File_PostProcess_Path" 		required="false" default="" />
		<cfargument name="OCR_File_PostProcess_Txt_Path" 	required="false" default="" />
		<cfargument name="DB_File_Preprocess_Path" 			required="false" default="" />
		<cfargument name="Search_String" 					required="false" default="" />
		<cfargument name="Allowable_File_Ext" 				required="false" default="" />
		<cfargument name="BB_Claim_Source_XREF_ID"			required="false" default="" />
		<cfargument name="Search_Order"						required="false" default="" />		
		<cfargument name="DB_OCR_Root_Path"					required="false" default="" />		
		<cfargument name="DB_OCR_Source_Code"				required="false" default="" />		
		<cfargument name="IS_OCR_Required"					required="false" default="0" />
		<cfargument name="Customer_Reference_Prefix"		required="false" default="" />		
		<cfargument name="OCR_Reader_Name"					required="false" default="" />
		<cfargument name="Parser_ID"						required="false" default="" />
				
			
		<cfargument name="Account_ID"						required="false" default="" />
		<cfargument name="OCR_Code"							required="false" default="" />
		<cfargument name="OCR_Image_Path"					required="false" default="" />
		<cfargument name="OCR_User_Input_Required"			required="false" default="0" />
		<cfargument name="Invoice_Number_Amount_Required"	required="false" default="0" />
		<cfargument name="Invoice_Date_Required"			required="false" default="0" />
		<cfargument name="Invoice_Start_Date_Required"		required="false" default="0" />
		<cfargument name="Invoice_End_Date_Required"		required="false" default="0" />
		<cfargument name="OCR_Template_Description"			required="false" default="" />
		<cfargument name="Allowed_Invoice_Rows_Count"		required="false" default="" />
		<cfargument name="OCR_Image_Helptext"				required="false" default="" />
		<cfargument name="Rank_Order"						required="false" default="" />
		<cfargument name="Is_Double_Processing_On" 			required="false" default="0" />
		<cfargument name="Special_Processing_Flag" 			required="false" default="0" />
						
		<cfset bSettingNameExists = 0 />
		
		<cfif arguments.OCRTemplateSettingsID EQ ""> 
			<cfset strPerformAction = "INSERT" />
		<cfelse>
			<cfset strPerformAction = "UPDATE" />
		</cfif>
		
		<cfquery name="qGetActiveNames" datasource="#application.datasource#">
			SELECT	
				OCR_Template_Settings_ID,
				OCR_Template_Name
			FROM	OCR_Template_Settings
			WHERE	0=0
			AND OCR_Template_Name = '#trim(arguments.OCR_Template_Name)#'
			AND	Deleted = 0
			<cfif arguments.OCRTemplateSettingsID NEQ ""> 
				AND OCR_Template_Settings_ID <> #arguments.OCRTemplateSettingsID# 
			</cfif>
		</cfquery>
		
		<cfif qGetActiveNames.RecordCount>
			<cfset bSettingNameExists = 1 />
			<cfset strPerformAction = "NONE" />
		</cfif>	
		<cfset useLakebaseForqGetSourceCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_claim_source_xref")>
<cfif useLakebaseForqGetSourceCode>
	<cftry>
		<cfset qGetSourceCode = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_claim_source_xref", {
				"bb_claim_source_xref_id" = "eq.#arguments.BB_Claim_Source_XREF_ID#",
				"select" = "bb_claim_source_xref_id,source_type,source_type_description,source_code"
			}), "bb_claim_source_xref_id,source_type,source_type_description,source_code"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetSourceCode = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetSourceCode>
<cfquery name="qGetSourceCode" datasource="#application.datasource#">
			SELECT 
				BB_Claim_Source_XREF_ID,
				Source_Type,
				Source_Type_Description,
				Source_Code
			FROM
				BB_Claim_Source_XREF
			WHERE 
				BB_Claim_Source_XREF_ID = '#arguments.BB_Claim_Source_XREF_ID#'
		</cfquery>
</cfif>	
		<cfset sourceCode = qGetSourceCode.Source_Code />
		
		<cfif strPerformAction EQ "INSERT">
			<cfquery name="qInsertSetting" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO	OCR_Template_Settings
					(	OCR_Template_Name, 
						OCR_File_Landing_Path,
						OCR_File_Landing_Path_Processed,
						OCR_File_PreProcess_Path,
						OCR_File_PostProcess_Path,
						OCR_File_PostProcess_Txt_Path,
						DB_File_Preprocess_Path,
						Created_User_ID,
						Created_Date,
						Search_String,
						Allowable_File_Ext,
						BB_Claim_Source_XREF_ID,
						Source_Code,
						Search_Order,
						DB_OCR_Root_Path,
						DB_OCR_Source_Code,
						Is_OCR_Required,
						Customer_Reference_Prefix,
						OCR_Reader_Name,
						Parser_ID,
						Account_ID ,
			            OCR_Code ,
			            OCR_Image_Path ,
			            OCR_User_Input_Required ,
			            Invoice_Number_Amount_Required ,
			            Invoice_Date_Required ,
			            Invoice_Start_Date_Required ,
			            Invoice_End_Date_Required ,
			            OCR_Template_Description ,
			            Allowed_Invoice_Rows_Count,
						OCR_Image_Helptext,
						Rank_Order,
						Is_Double_Processing_On,
						Special_Processing_Flag
						)
				VALUES
					(
						'#arguments.OCR_Template_Name#',
						'#arguments.OCR_File_Landing_Path#',
						'#arguments.OCR_File_Landing_Path_Processed#',
						'#arguments.OCR_File_PreProcess_Path#',
						'#arguments.OCR_File_PostProcess_Path#',
						'#arguments.OCR_File_PostProcess_Txt_Path#',
						/* '#arguments.DB_File_Preprocess_Path#', */
						 CASE WHEN '#arguments.OCR_Reader_Name#' = 'DOCPARSER' THEN '' ELSE '#arguments.DB_File_Preprocess_Path#' END,
						'#request.AccessStructure.user_id#',
						getDate(),
						'#arguments.Search_String#',
						'#arguments.Allowable_File_Ext#',
						'#arguments.BB_Claim_Source_XREF_ID#',
						'#sourceCode#',
						'#arguments.Search_Order#',
						'#arguments.DB_OCR_Root_Path#',
						'#arguments.DB_OCR_Source_Code#',
						/* '#arguments.IS_OCR_Required#', */
						CASE WHEN '#arguments.OCR_Reader_Name#' = 'EXCELCSV' THEN '0' ELSE '#arguments.IS_OCR_Required#' END,
						'#arguments.Customer_Reference_Prefix#',
						'#arguments.OCR_Reader_Name#',
						'#arguments.Parser_ID#',	
						'#arguments.Account_ID#',	
						'#arguments.OCR_Code#',
						'#arguments.OCR_Image_Path#',
						CASE WHEN '#arguments.OCR_User_Input_Required#'='' THEN '0' ELSE '#arguments.OCR_User_Input_Required#' END,
						CASE WHEN '#arguments.Invoice_Number_Amount_Required#'='' THEN '0' ELSE '#arguments.Invoice_Number_Amount_Required#' END,
						CASE WHEN '#arguments.Invoice_Date_Required#'='' THEN '0' ELSE '#arguments.Invoice_Date_Required#' END,
						CASE WHEN '#arguments.Invoice_Start_Date_Required#'='' THEN '0' ELSE '#arguments.Invoice_Start_Date_Required#' END,
						CASE WHEN '#arguments.Invoice_End_Date_Required#'='' THEN '0' ELSE '#arguments.Invoice_End_Date_Required#' END,
						'#arguments.OCR_Template_Description#',
						'#arguments.Allowed_Invoice_Rows_Count#',
						'#arguments.OCR_Image_Helptext#',
						'#arguments.Rank_Order#',
						'#arguments.Is_Double_Processing_On#',
						'#arguments.Special_Processing_Flag#'
					)	
					
				SELECT OCRTemplateSettingsID = @@IDENTITY	
			SET NOCOUNT OFF
			</cfquery>
			
			<cfif (arguments.OCR_Reader_Name NEQ "DOCPARSER")>
				<cfstoredproc procedure = "Upload_OCR_Source_Folder_CHECK" dataSource="#application.datasource#">
					<cfprocparam type="IN"  variable="@OCR_Template_Settings_ID"	value="#qInsertSetting.OCRTemplateSettingsID#" cfsqltype="CF_SQL_INTEGER" null="no">
				</cfstoredproc>
			</cfif>			
			
			<cfset  form.display = "active" />
		<cfelseif strPerformAction EQ "UPDATE">
			<cfquery name="qUpdateSetting" datasource="#application.datasource#">
				SET NOCOUNT ON
				UPDATE OCR_Template_Settings
					SET OCR_Template_Name = '#arguments.OCR_Template_Name#', 
						OCR_File_Landing_Path = '#arguments.OCR_File_Landing_Path#',
						OCR_File_Landing_Path_Processed = '#arguments.OCR_File_Landing_Path_Processed#',
						OCR_File_PreProcess_Path = '#arguments.OCR_File_PreProcess_Path#',
						OCR_File_PostProcess_Path = '#arguments.OCR_File_PostProcess_Path#',
						OCR_File_PostProcess_Txt_Path = '#arguments.OCR_File_PostProcess_Txt_Path#',
						DB_File_Preprocess_Path = CASE WHEN '#arguments.OCR_Reader_Name#' = 'DOCPARSER' THEN '' ELSE '#arguments.DB_File_Preprocess_Path#' END,
						-- DB_File_Preprocess_Path = '#arguments.DB_File_Preprocess_Path#',
						Updated_By = '#request.AccessStructure.user_id#',
						Updated_Date = getDate(),
						Search_String = '#arguments.Search_String#',
						Allowable_File_Ext = '#arguments.Allowable_File_Ext#',
						BB_Claim_Source_XREF_ID = '#arguments.BB_Claim_Source_XREF_ID#',
						Source_Code = '#sourceCode#',
						Search_Order = '#arguments.Search_Order#',
						DB_OCR_Root_Path = '#arguments.DB_OCR_Root_Path#',
						DB_OCR_Source_Code = '#arguments.DB_OCR_Source_Code#',
						IS_OCR_Required = CASE WHEN '#arguments.OCR_Reader_Name#' = 'EXCELCSV' THEN '0' ELSE '1' END,
						Customer_Reference_Prefix = '#arguments.Customer_Reference_Prefix#',
						OCR_Reader_Name	= '#arguments.OCR_Reader_Name#',
						Parser_ID	= '#arguments.Parser_ID#',						
						Account_ID = '#arguments.Account_ID#',	
						OCR_Code = '#arguments.OCR_Code#',
						OCR_Image_Path = '#arguments.OCR_Image_Path#',
						OCR_User_Input_Required = '#arguments.OCR_User_Input_Required#',
						Invoice_Number_Amount_Required = '#arguments.Invoice_Number_Amount_Required#',
						Invoice_Date_Required = '#arguments.Invoice_Date_Required#',
						Invoice_Start_Date_Required = '#arguments.Invoice_Start_Date_Required#',
						Invoice_End_Date_Required = '#arguments.Invoice_End_Date_Required#',
						OCR_Template_Description = '#arguments.OCR_Template_Description#',
						Allowed_Invoice_Rows_Count = '#arguments.Allowed_Invoice_Rows_Count#',
						OCR_Image_Helptext = '#arguments.OCR_Image_Helptext#',
						Rank_Order 			= '#arguments.Rank_Order#',
						Is_Double_Processing_On = '#arguments.Is_Double_Processing_On#',
						Special_Processing_Flag = '#arguments.Special_Processing_Flag#'
						
				WHERE OCR_Template_Settings_ID = #arguments.OCRTemplateSettingsID#
				SET NOCOUNT OFF
			</cfquery>
			<cfif (arguments.OCR_Reader_Name NEQ "DOCPARSER")>
				<cfstoredproc procedure = "Upload_OCR_Source_Folder_CHECK" dataSource="#application.datasource#">
					<cfprocparam type="IN"  variable="@OCR_Template_Settings_ID"	value="#arguments.OCRTemplateSettingsID#" cfsqltype="CF_SQL_INTEGER" null="no">
				</cfstoredproc>
			</cfif>			
			
			<cfset  form.display = "active" />
		</cfif>
		
		<cfreturn bSettingNameExists />

   	</cffunction>
	
	<cffunction name="deactivateOCRSettings" returntype="any">
		<cfargument name="CID" 						required="false" default="" />
		<cfquery name="updSelOCRSetting" datasource="#application.datasource#">
			UPDATE OCR_Template_Settings
			SET 
				Active = 0,
				Updated_By = '#request.AccessStructure.user_id#',
				Updated_Date = getDate()
			WHERE 
				OCR_Template_Settings_ID IN (#arguments.CID#)
		</cfquery>
		
	</cffunction>

	<cffunction name="activateOCRSettings" returntype="any">	
		<cfargument name="CID" 						required="false" default="" />
		<cfquery name="updSelOCRSetting" datasource="#application.datasource#">
			UPDATE OCR_Template_Settings
			SET 
				Active = 1,
				Updated_By = '#request.AccessStructure.user_id#',
				Updated_Date = getDate()
			WHERE 
				OCR_Template_Settings_ID IN (#arguments.CID#)
		</cfquery>	
	</cffunction>
	
	<cffunction name="updateOCRSettings" returntype="any">		
	</cffunction>	
	
	<cffunction name="deleteOCRSettings" returntype="any">		
	</cffunction>

	<!--- Returns the Report data for the "Report" link to be downloaded as csv --->			
	<cffunction name="getDownloadData" access="public" returntype="query">	
		<cfargument name="OCRUploadID" 		type="string" required="false" default="">
		<cfargument name="OCRFileCaptureID" type="string" required="false" default="">		
		<cfargument name="sFullPath" type="string" required="false" default="">
		<cfargument name="sFileName" type="string" required="false" default="">
		<cfargument name="IsDebug" type="string" required="false" default="0">		
		
		<cfset var qDownloadData = "" />		
		
		<cfif arguments.OCRUploadID EQ "">
			<cfset isNull = "Yes" />
		<cfelse>
			<cfset isNull = "No" />				
		</cfif>	
		<cfif arguments.OCRFileCaptureID EQ "">
			<cfset isCaptureNull = "Yes" />
		<cfelse>
			<cfset isCaptureNull = "No" />				
		</cfif>	
		
			<!--- Create the temp table to write the data from the file --->
		<cfquery name="Create_Data_Table" datasource="#application.datasource#">
			IF object_id('tempdb..##OCR_Success_Failure_Status') IS NOT NULL
				BEGIN
	    	    	DROP TABLE ##OCR_Success_Failure_Status
				END	
				 
				CREATE TABLE ##OCR_Success_Failure_Status
				(
					[Message]  [varchar](max), 
					[Status]  [varchar](max)
				)			
		</cfquery>
			 
		<cfstoredproc procedure = "OCR_Source_Extract" dataSource="#application.datasource#">
			<cfprocparam type="IN"  variable="@OCR_Upload_ID"	value="#arguments.OCRUploadID#" cfsqltype="CF_SQL_INTEGER" null="#isNull#">
			<cfprocparam type="IN"  variable="@OCR_File_Capture_ID"	value="#arguments.OCRFileCaptureID#" cfsqltype="CF_SQL_INTEGER" null="#isCaptureNull#">			
			<cfprocparam type="IN"  variable="@FilePath" value="#arguments.sFullPath#" cfsqltype="CF_SQL_VARCHAR" null="No">
			<cfprocparam type="IN"  variable="@FilenameExt" value="#arguments.sFileName#" cfsqltype="CF_SQL_VARCHAR" null="No">
			<cfprocparam type="IN"  variable="@Is_Debug" value="#arguments.IsDebug#" cfsqltype="CF_SQL_BIT" null="No">
			
			<cfprocresult name = "qryResult">
		</cfstoredproc>
		
		<cfquery name="selSuccessFailureStatus" datasource="#application.datasource#">
			SELECT * FROM ##OCR_Success_Failure_Status	
		</cfquery>
		 
		<cfreturn selSuccessFailureStatus />
	</cffunction>	

	<cffunction name="getOCRSettingsOnXref" returntype="any" access="remote" output="false" >		
		<cfargument name="BBClaimSourceXrefID" required="false" default="" />
		<cfquery name="qGetOCRSettings" datasource="#application.datasource#">
			/* !!!!!!!!!!!!!! DO NOT CHANGE THE ORDER OF THIE BELOW QUERY OR ELSE THE PAGE WILL BREAK !!!!!!!!!!! */
			SELECT 
				OCR_Template_Settings_ID, 
				OCR_Template_Name,
				OCR_Code,
				OCR_Image_Path,
				OCR_Image_Helptext,
				OCR_Template_Description
			FROM OCR_Template_Settings		
			WHERE 1=1 
			AND Active = 1
			AND Deleted = 0
			<cfif (isDefined("arguments.BBClaimSourceXrefID") AND arguments.BBClaimSourceXrefID NEQ "")>
				AND BB_Claim_Source_XREF_ID = #arguments.BBClaimSourceXrefID#
			</cfif>
			ORDER BY Rank_Order
		</cfquery>
		<cfreturn qGetOCRSettings>
	</cffunction>
	 
	<cffunction name="getOCRSettingsOnID" returntype="any" access="remote" output="false" >		
		<cfargument name="OCRTemplateSettingsID" required="false" default="" />
		<cfquery name="qGetOCRSettings" datasource="#application.datasource#">
		/* !!!!!!!!!!!!!! DO NOT CHANGE THE ORDER OF THIE BELOW QUERY OR ELSE THE PAGE WILL BREAK !!!!!!!!!!! */
			SELECT 
				OCR_Template_Settings_ID, 
				OCR_Image_Path,
				OCR_User_Input_Required,
				Invoice_Number_Amount_Required,
				Invoice_Date_Required,
				Invoice_Start_Date_Required,
				Invoice_End_Date_Required,
				Allowed_Invoice_Rows_Count,
				OCR_Template_Name,
				OCR_Code,
				OCR_Image_Helptext,
				OCR_Template_Description
			FROM OCR_Template_Settings		
			WHERE 1=1 
			AND Active = 1
			AND Deleted = 0
			<cfif (isDefined("arguments.OCRTemplateSettingsID") AND arguments.OCRTemplateSettingsID NEQ "")>
				AND OCR_Template_Settings_ID = #arguments.OCRTemplateSettingsID#
			</cfif>
			ORDER BY Rank_Order
		</cfquery>
		<cfreturn qGetOCRSettings>
	</cffunction>	
	<cffunction name="xxxxx" returntype="any">		
	</cffunction>
	
	 <cffunction name="getUploadIDData" returntype="query">		
		 <cfargument name="OCRUploadID" required="false" default="" />
 		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT * FROM 
				OCR_Upload_Log OUL
				INNER JOIN OCR_Template_Settings OTS /* was LEFT JOIN before*/
				ON OTS.OCR_Template_Settings_ID = OUL.OCR_Template_Settings_ID 
				AND OTS.Deleted = 0
			
			WHERE 
					OUL.Deleted = 0	
					<cfif (isDefined("arguments.OCRUploadID") AND arguments.OCRUploadID NEQ "")>
					AND OCR_Upload_ID = #arguments.OCRUploadID#
			</cfif>
			ORDER BY
			OUL.OCR_Upload_Date DESC 
		</cfquery>
		<cfreturn qGetData>
	</cffunction>
</cfcomponent>
 