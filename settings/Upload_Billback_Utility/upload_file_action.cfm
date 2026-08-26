<!---  
       Name:          upload_file_action.cfm           
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:		  11367
       Description:   
--->
<cfparam name="form.userID" default="#request.accessstructure.user_id#" />
<cfparam name="form.userCode" default="#request.accessstructure.user_code#" />
<cfparam name="form.header_file" default=""/>
<cfparam name="form.detail_file" default=""/>
<cfparam name="form.single_file" default=""/>
<cfparam name="form.Billback_Upload_Business_Segment" default="0"/><!--- D29947 Update billback upload for SO/DC  --->
<cfset headerFilePath = "" />
<cfset detailFilePath = "" />
<cfset singleFilePath = "" />
<cfoutput>
<script type='text/javascript'>
	_ajaxConfig = {	'_cfscriptLocation':'/components/billback/BillbackUtilityAjax.cfc','_jsscriptFolder':'/script/javascript/Ajax_JS/','debug':false};
</script>

<cfset returnpath = "index.cfm?Show_Tab=1">
<cfset uploadUtility = CreateObject("component","components.billback.billbackuploadutility") />
<cfset uploadFilePath = uploadUtility.getUploadPath() />
<body>		
<cfif (appSettings.getBillbackFileUploadType() EQ 2)>	
	<!--- Check Header file for Zero-Length --->
	<cfset TempDirectoryLocation = GetDirectoryFromPath(form.header_file)>
	<cfset TempFileName = GetFileFromPath(form.header_file)>
	<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">
	<cfset FileSize = Tempdirectory.Size>
	
	<!---If they uploaded a zero length or invalid file, redirect back with error information--->
		<cfif Filesize LT 1>
			<BR><BR><BR><BR>
				<TABLE ALIGN="CENTER">
				  <TR>
			  		<TD style="font-weight:bold;">The size of the uploaded header file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.</TD>
				  </TR>
				</TABLE>
				<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT> 
			<CFABORT>	
		</CFIF>	

	<!--- Check Detail file for Zero-Length --->
	<cfset TempDirectoryLocation = GetDirectoryFromPath(form.detail_file)>
	<cfset TempFileName = GetFileFromPath(form.detail_file)>
	<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">
	<cfset FileSize = Tempdirectory.Size>
	
	<!---If they uploaded a zero length or invalid file, redirect back with error information--->
		<cfif Filesize LT 1>
			<BR><BR><BR><BR>
				<TABLE ALIGN="CENTER">
				  	<TR>
			  			<TD style="font-weight:bold;">The size of the uploaded detail file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.</TD>
				  	</TR>
				</TABLE>
				<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT> 
			<CFABORT>	
		</CFIF>	
	
		<!--- Header File Upload and Copy --->
			<cffile action = "upload" fileField = "header_file"   
			destination = "#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files" 
			nameConflict="MAKEUNIQUE" accept="text/plain">
			
			<cffile action="read" file="#cffile.serverDirectory#\#cffile.serverFile#" 
			variable = "uploadedHeaderFile">
			
			<cfset headerFilePath = "#uploadFilePath.File_Path##cffile.serverFile#">
		
			<cffile action="copy" destination="#headerFilePath#" source="#cffile.serverDirectory#\#cffile.serverFile#">
		<!--- End Header File Upload and Copy --->	
			
		<!--- Detail File Upload and Copy --->	
			<cffile action = "upload" fileField = "form.detail_File"   
			destination = "#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files" 
			nameConflict = "makeUnique" accept="text/plain">
		
			<cffile action="read"  file="#cffile.serverDirectory#\#cffile.serverFile#" 
			variable = "uploadedDetailFile">
			
			<cfset detailFilePath = "#uploadFilePath.File_Path##cffile.serverFile#">
			
			<cffile action="copy" destination="#detailFilePath#" source="#cffile.serverDirectory#\#cffile.serverFile#">
		<!--- End Detail File Upload and Copy --->
<cfelseif (appSettings.getBillbackFileUploadType() EQ 1 OR appSettings.getBillbackFileUploadType() EQ 3)>	
<!--- Check Header file for Zero-Length --->
	  <cftry>	
		<cfset TempDirectoryLocation = GetDirectoryFromPath(form.single_file)>
		<cfset TempFileName = GetFileFromPath(form.single_file)>
		<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">
		<cfset FileSize = Tempdirectory.Size>
		
		<!---If they uploaded a zero length or invalid file, redirect back with error information--->
			<cfif Filesize LT 1>
				<BR><BR><BR><BR>
					<TABLE ALIGN="CENTER">
					  <TR>
				  		<TD style="font-weight:bold;">The size of the uploaded file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.</TD>
					  </TR>
					</TABLE>
					<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT> 
				<CFABORT>	
			</CFIF>	
			
			
		<!--- Single File Upload and Copy --->
	 
			<cffile action = "upload" fileField = "single_file"   
			destination = "#Application.Doc_Path#\Data_Files\Settings\Billback_Upload_Files" 
			nameConflict="OVERWRITE" ><!--- accept="text/plain" --->
 			<!--- 
				46232: Reject Duplicate File names in the BB Upload process/Anand Rao/14-Nov-2014
			--->
			<cfset useLakebaseForgetDuplicateUpload = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_upload_log")>
<cfif useLakebaseForgetDuplicateUpload>
	<cftry>
		<cfset getDuplicateUpload = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_upload_log", {
				"header_file_name" = "eq.#cffile.serverFile#",
				"limit" = "1",
				"select" = "header_file_name"
			}), "header_file_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDuplicateUpload = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDuplicateUpload>
<cfquery name="getDuplicateUpload" datasource="#application.datasource#">
				SELECT  top 1 header_file_name
						FROM BB_Upload_log
				WHERE 	header_file_name = '#cffile.serverFile#'	
			</cfquery>
</cfif>
			
			<cfif getDuplicateUpload.RecordCount GTE 1>
				<!--- <cffile action="delete" file="#cffile.serverDirectory#\#cffile.serverFile#"> --->
				<BR><BR><b><u>Upload Failed due to the below reason:</u></b><BR><BR>
					<TABLE>
					  <TR>
				  		<TD style="font-weight:bold;">
						
						The File with the same name is already in the System!! Please try a different file.
						</TD>
					  </TR>
					</TABLE>
					<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 10000);</SCRIPT> 
				<CFABORT>	
			</cfif>
			
			<cffile action="read" file="#cffile.serverDirectory#\#cffile.serverFile#" 
			variable = "uploadedSingleFile">
		
			<cfset singleFilePath = "#uploadFilePath.File_Path#\#cffile.serverFile#">
			<cfset singleFileName = "#cffile.serverFile#">
			<cffile action="copy" destination="#singleFilePath#" source="#cffile.serverDirectory#\#cffile.serverFile#">
		<!--- End Single File Upload and Copy --->	
		  <cfcatch>
			<br><br>
			The below error occured in Step 1, when trying to "Upload/Read/Copy" File:
			<cfinclude template="errorCatcher.cfm">
			<cfabort>
		</cfcatch>
	</cftry>	  
</cfif>	

<!--- Ajax script to perform the upload asynchronously --->
<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>
<script type="text/javascript">
	function doTest(headerFile, detailFile, userID, bus_seg_ID, singleFile)	{
		// send data to CF
		DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'upload_billback_validate_sp', headerFile, detailFile, userID, bus_seg_ID, singleFile, doEcho);//D29947 Update billback upload for SO/DC 
		window.location.href = "index.cfm?show_tab=1";
	}
	
	// This function is required for the execute signature but does nothing but redirect.
	function doEcho(r){
	
		document.write("");
		window.location.href = "index.cfm?show_tab=1";
	}
	
	
</script>
<!--- D29947 Update billback upload for SO/DC  --->
 

<cfif (appSettings.getBillbackFileUploadType() EQ 1 OR appSettings.getBillbackFileUploadType() EQ 2)>	
	<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">doTest('#jsstringformat(headerFilePath)#','#jsstringformat(detailFilePath)#','#jsstringformat(form.userID)#', '#jsstringformat(form.Billback_Upload_Business_Segment)#', '#jsstringformat(singleFilePath)#');</SCRIPT>
<!--- D43358: New Upload Alias Fixer: Handle for Displaying the Alias fixer window --->
<cfelseif (appSettings.getBillbackFileUploadType() EQ 3)>
	<cftry>
		<!--- STEP 1: Insert into the BB_Upload_Log Table  ---> 
		<cfquery name="qInsBBUploadLog" datasource="#application.datasource#">
			DECLARE  @upload_id int, 
	           		 @upload_date datetime,
	          		 @user_id varchar(50),
			         @single_file varchar(255)
	
		    SET @upload_date = getdate()
	      	SET @user_id = '#form.userID#'
	      	SET @single_file ='#singleFileName#'
				
			INSERT INTO BB_upload_log(
				User_ID,
				total_header_count ,
				total_header_count_failed ,
	            total_header_count_loaded ,
				total_detail_count ,
				total_detail_count_failed,
				total_detail_count_loaded,
				upload_date ,
				upload_status,
				header_file_name,
				detail_file_name,
				Upload_Type,
				Upload_Type_Desc
			    )
	      SELECT 
				@user_id,
				0, 
				0,
				0,
				0, 
				0,
				0,
				@upload_date,
				'File Received',
				@single_file,
				@single_file,
				2,
				1
			
		      SELECT 
			  	Upload_ID 
			  FROM 
			  	BB_upload_log 
			  WHERE User_ID = @user_id AND Upload_Status = 'File Received' AND Upload_Date = @Upload_Date AND Header_File_Name = @single_file
			</cfquery>	
			<cfset UploadID = qInsBBUploadLog.Upload_ID />
		<cfcatch>
			<br><br>
			The below error occured in Step 2, when trying to "INSERT DATA INTO BB_upload_log":
			<cfinclude template="errorCatcher.cfm">
			<cfabort>
		</cfcatch>
	</cftry>	
	<cftry>
		<!--- STEP 2: Create the temp table to store the details --->
		<cfquery name="Create_Data_Table" datasource="#application.datasource#">
			IF object_id('tempdb..##BB_New_Single_File_BLK_INS') IS NOT NULL
			BEGIN	 
                 DROP TABLE ##BB_New_Single_File_BLK_INS
			END

                  CREATE TABLE ##BB_New_Single_File_BLK_INS(
                   [Source] [varchar](max), 
                   [Vendor_Number] [varchar](max),
                   [Program_Number] [varchar](max),
                   [Customer_Reference] [varchar](max),
                   --[Total_Dollar_Amount] [varchar](max),
                   [Payee_Type] [varchar](max),
                   [Distributor_ID] [varchar](max),
                   [Operator_ID] [varchar](max),
                   [Closing_Method] [varchar](max),
                   [Billback_Date] [varchar](max),
                   [BB_Start_Date] [varchar](max),
                   [BB_End_Date] [varchar](max),
                   [Item_Number] [varchar](max),
                   [Item_Volume_Qty] [varchar](max),
                   [Item_Dollar_Amount] [varchar](max),
                   [Associated_Distributor_ID] [varchar](max),
                   [UOM] [varchar](max),
                   [Trade_Indicator] [varchar](max),
                   [Lump_Sum_Indicator] [varchar](max),
                   [File_Name] [varchar](max),
				   [Component_Name] [varchar](max),
                   [Unknown] [varchar](max),                             
                   [Upload_File_Name] [varchar](max),
				   [Cust_Desc] [VARCHAR](max),
				   [Address] [VARCHAR](max),
				   [State] [VARCHAR](max)
                   )
			 
		 	 	IF object_id('tempdb..##BB_Unmapped_Alias_List') IS NOT NULL
				BEGIN	 
			        DROP TABLE ##BB_Unmapped_Alias_List
				END
						  
			CREATE TABLE ##BB_Unmapped_Alias_List(
				Upload_ID INT,
				Alias_Type INT, /* 1 = Distributor, 2 = Operator, 3 = Item */
				Source_Code VARCHAR(255),
				BB_Claim_Source_XREF_ID INT,
				BB_Claim_Alias_XREF_ID INT,
				External_Code VARCHAR(255),
				External_Description VARCHAR(255),
				BA_ID VARCHAR(255),
				BA_Desc VARCHAR(255),
				Unknown BIT
			)	
				
				UPDATE 
					BB_upload_log
				SET 
					upload_status = 'Transferring file data to DB'
				WHERE 
					upload_ID = #UploadID#
	 	</cfquery>	

		<!--- Call the New SP for single file and Alias validation 
			 @Upload_Type  (1 = Populate Bulk Insert table & 2  = Upload Alias )
		---> 

		<cfquery name="chkUnmappedAliasList" datasource="#application.datasource#">
			SELECT * FROM ##BB_Unmapped_Alias_List 	
		</cfquery>
		<cfcatch>
			<br><br>
			The below error occured in Step 3, when trying to "Create Temp Tables and Update BB_Upload_Log":
			<cfinclude template="errorCatcher.cfm">
			<cfabort>
		</cfcatch>
	</cftry>	
 	
	<cftry>
 		<cfstoredproc datasource="#application.datasource#" procedure="Upload_BB_Single_File_Excel">
			<cfprocparam type="IN"  dbVarName="@Uploaded_Single_File" value="#singleFilePath#" cfsqltype="CF_SQL_VARCHAR">
			<cfprocparam type="IN"  dbVarName="@FileNameExt" value="#singleFileName#" cfsqltype="CF_SQL_VARCHAR">
		</cfstoredproc>

		<cfquery name="checkUpload" datasource="#application.datasource#">
			SELECT  *
			FROM 
			 ##BB_New_Single_File_BLK_INS
			WHERE Upload_File_Name = '#singleFileName#'
		</cfquery> 
		<cfcatch>
			<br><br>
			The below error occured in Step 4, the SP "Upload_BB_Single_File_Excel" threw an error:
			<cfinclude template="errorCatcher.cfm">
			<!--- Delete when there is an error in the upload --->
			<!--- <cfset useLakebaseFordelDataFromTable = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_new_single_file_blk_ins")>
<cfif useLakebaseFordelDataFromTable>
	<cftry>
		<cfset application.oLakebase.deleteRows("bb_new_single_file_blk_ins", {
			"upload_id" = "eq.#UploadID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelDataFromTable = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelDataFromTable>
<cfquery name="delDataFromTable" datasource="#application.datasource#">
				DELETE FROM BB_New_Single_File_BLK_INS WHERE Upload_ID = #UploadID#
			</cfquery>
</cfif> ---> 
			<cfabort>
		</cfcatch>
	</cftry>	
		
		<cfif checkUpload.recordCount>
			<cftry>
				<cfstoredproc datasource="#application.datasource#" procedure="Upload_Single_File_Alias_Validate">
					<cfprocparam type="IN"  dbVarName="@Uploaded_Single_File" value="#singleFilePath#" cfsqltype="CF_SQL_VARCHAR">
					<cfprocparam type="IN"  dbVarName="@Upload_ID" value="#UploadID#" cfsqltype="CF_SQL_INTEGER">
					<cfprocparam type="IN"  dbVarName="@Process_Type" value="1" cfsqltype="CF_SQL_INTEGER">  
					<cfprocresult name = "UploadSingleFileResult">
				</cfstoredproc>
				<cfcatch>
					<br><br>
					The below error occured in Step 5, the SP "Upload_Single_File_Alias_Validate" threw an error:
					<cfinclude template="errorCatcher.cfm">
					<!--- Delete when there is an error in the upload --->
					<!--- <cfquery name="delDataFromTable" datasource="#application.datasource#">
						DELETE FROM BB_New_Single_File_BLK_INS WHERE Upload_ID = #UploadID#
					</cfquery> ---> 
					<cfabort>
				</cfcatch>
			</cftry>	

		<!--- Upload_Single_File_Alias_Validate_txt used old text upload --->
		
		
 		<cfif (UploadSingleFileResult.RecordCount GTE 1)>
		<!--- 
			Status = 1:  Always Error =  Get the Error Message from column: ErrorMessage
			Status = 2:  Message = ' Alias needs to be fixed '
			Status = 3:  Message = ' All the Alias in the file have been fixed '
		--->
 		
			<cfif (UploadSingleFileResult.Status EQ 1)><br>
			<br>
				The Upload Encountered the following error in SP "Upload_Single_File_Alias_Validate": "Error Number: #UploadSingleFileResult.ErrorNumber#", <br>
				Error Message: <font color="red">"#UploadSingleFileResult.ErrorMessage#"</font>
				<!--- <cfquery name="delDataFromTable" datasource="#application.datasource#">
					DELETE FROM BB_New_Single_File_BLK_INS WHERE Upload_ID = #UploadID#
				</cfquery> ---> 
			<cfelseif (UploadSingleFileResult.Status EQ 2)><br>
					<font size="2">
				&nbsp;&nbsp;&nbsp;Alias needs to be fixed!! Alias fixing window currently open!! <br><br>
				<font color="red"><b>&nbsp;&nbsp;&nbsp;Note: Closing the Alias window will ABORT the whole upload!!</b></font>
			 
				<script type="text/javascript">
				/* "window.onload" syntax is needed for Chrome when using "window.showModalDialog" */
					window.onload = function (){
						window.showModalDialog("AliasFixerMain.cfm?UploadID=#UploadID#",window,"dialogHeight:700px;dialogWidth:900px;center:yes;resizable:yes;edge:raised");  
					}
				</script>	


				</font>
			<cfelseif (UploadSingleFileResult.Status EQ 3)>
				<cfset useLakebaseForchkBBUploadLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_upload_log")>
<cfif useLakebaseForchkBBUploadLog>
	<cftry>
		<cfset chkBBUploadLog = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_upload_log", {
				"upload_id" = "eq.#UploadID#",
				"select" = "upload_status"
			}), "upload_status"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForchkBBUploadLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForchkBBUploadLog>
<cfquery name="chkBBUploadLog" datasource="#application.datasource#">
					SELECT Upload_Status FROM BB_Upload_Log where Upload_id = #UploadID#
				</cfquery>
</cfif>
				<cfif chkBBUploadLog.Upload_Status EQ "Creation Complete" OR chkBBUploadLog.Upload_Status EQ "Validation Completed">
					<br><br>
					<strong>Billback is Queued for Creation!!</strong> 
				<cfelse>
					<br>
					The Upload Encountered the following error: <strong><cfoutput>#chkBBUploadLog.Upload_Status#</cfoutput></strong>			
				</cfif>	
				<!--- <cfquery name="delDataFromTable" datasource="#application.datasource#">
						DELETE FROM BB_New_Single_File_BLK_INS WHERE Upload_ID = #UploadID#
				</cfquery>  --->
			</cfif> <!--- <cfif (UploadSingleFileResult.Status EQ 1)> --->
		</cfif>	<!--- <cfif (UploadSingleFileResult.RecordCount GTE 1)> --->
	<cfelse>		
	<br><br><strong>Excel File Upload Failed!!</strong> 
		<!--- <cfquery name="delDataFromTable" datasource="#application.datasource#">
			DELETE FROM BB_New_Single_File_BLK_INS WHERE Upload_ID = #UploadID#
		</cfquery>  --->
	</cfif>		<!--- checkUpload.recordCount --->
	<br><br>
	<font color="red">[</font> 
		<a href="/Settings/upload_billback_utility/index.cfm?Show_Tab=1">Return to File upload</a> 
	<font color="red">]</font>		
	
</cfif>	<!--- <cfif (appSettings.getBillbackFileUploadType() EQ 1 OR appSettings.getBillbackFileUploadType() EQ 2)> --->	
</cfoutput> 

			
<cfif (appSettings.getBillbackFileUploadType() EQ 1) OR (appSettings.getBillbackFileUploadType() EQ 2)>	
<br><br>
	<p>The validation report will be emailed to you upon completion.</p> 
</cfif>	
</body>