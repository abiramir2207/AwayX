
		<cfset useLakebaseForAnyAliveProcess = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("accrual_upload")>
<cfif useLakebaseForAnyAliveProcess>
	<cftry>
		<cfset AnyAliveProcess = application.oLakebase.toQuery(
			application.oLakebase.selectRows("accrual_upload", {
				"order" = "accrual_upload_id.desc",
				"limit" = "1",
				"select" = "accrual_process_status_id"
			}), "accrual_process_status_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAnyAliveProcess = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAnyAliveProcess>
<CFQUERY NAME="AnyAliveProcess" DATASOURCE="#Application.Datasource#">
			SELECT TOP 1 Accrual_Process_Status_ID FROM Accrual_Upload
			ORDER BY Accrual_Upload_ID DESC
		</CFQUERY>
</cfif>
		
		<CFIF AnyAliveProcess.Accrual_Process_Status_ID IS 3>
			<TABLE ALIGN="Center">
				<TR>
					<TD><FONT COLOR="Red" SIZE="3"><B>Another user is uploading corporate data right now. This page will refresh after a few seconds. Click "ok" to resubmit form data.</B></FONT></TD>
				</TR>
			</TABLE>
			
			<SCRIPT language="JavaScript">
			function refresh()
			{
				window.location.refresh
			}
			window.setTimeout('refresh();', 300);	
			</SCRIPT>			
		<CFELSE>
		
			<cfset useLakebaseForGetFilePath = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dataint_settings")>
<cfif useLakebaseForGetFilePath>
	<cftry>
		<cfset GetFilePath = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dataint_settings", {
				"select" = "dts_reference_path"
			}), "dts_reference_path"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFilePath = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFilePath>
<cfquery name="GetFilePath" datasource="#application.datasource#">
			SELECT DTS_Reference_Path 
			FROM DataInt_Settings
			</cfquery>
</cfif>
			
			<cfset filepath = application.Doc_Path & "\data_files\uploaded\CorpData\Transfer\">
			
			<cfset SecondaryFilePath = application.Doc_Path & "\data_files\uploaded\CorpData\">
			
			<!---Testing only, remove to go live --->
			<!--- <cfset filepath = "c:\Temp\Sarudir\">
			<cfset SecondaryFilePath = "c:\Temp\Localdir\">
			<!---End testing --->
		 --->
			<!---formats fiscal year the way Saru wants it --->
			<cfset FiscalYear = "FY" & form.Fiscal_Year>
			
			
			<!---Upload files to directory where they will be saved for 90 days--->
						
			<CFFILE ACTION = "upload"
			FILEFIELD = "form.AccrualFile"
			DESTINATION = "#SecondaryFilePath#"
			NAMECONFLICT =	"makeunique">
			
			<cfset AccrualFileLocation = application.Doc_Mapping & "/data_files/uploaded/CorpData/" & cffile.serverFile>
			
			<CFFILE ACTION = "upload"
			FILEFIELD = "form.AccrualItemFile"
			DESTINATION = "#SecondaryFilePath#"
			NAMECONFLICT =	"makeunique">
			
			<cfset AccrualItemFileLocation = application.Doc_Mapping & "/data_files/uploaded/CorpData/" & cffile.serverFile>
			
			<CFFILE ACTION = "upload"
			FILEFIELD = "form.CDPFile"
			DESTINATION = "#SecondaryFilePath#"
			NAMECONFLICT =	"makeunique">
			
			<cfset CDPFileLocation = application.Doc_Mapping & "/data_files/uploaded/CorpData/" & cffile.serverFile>
			
			<CFFILE ACTION = "upload"
			FILEFIELD = "form.CDPItemFile"
			DESTINATION = "#SecondaryFilePath#"
			NAMECONFLICT =	"makeunique">
			
			<cfset CDPItemFileLocation = application.Doc_Mapping & "/data_files/uploaded/CorpData/" & cffile.serverFile>
			
			<!---Deletes previous files --->
			<cfif fileExists("#Filepath#\TRADEWINDS_SHELTER.xls")>
				<cffile action = "delete"  file = "#Filepath#\TRADEWINDS_SHELTER.xls">
			</cfif>
			<cfif fileExists("#Filepath#\TRADEWINDS_SHELTER_ITEM.xls")>
				<cffile action = "delete"  file = "#Filepath#\TRADEWINDS_SHELTER_ITEM.xls">
			</cfif>
			<cfif fileExists("#Filepath#\TRADEWINDS_ACCRUAL.xls")>
				<cffile action = "delete"  file = "#Filepath#\TRADEWINDS_ACCRUAL.xls">
			</cfif>
			<cfif fileExists("#Filepath#\TRADEWINDS_ACCRUAL_ITEM.xls")>
				<cffile action = "delete"  file = "#Filepath#\TRADEWINDS_ACCRUAL_ITEM.xls"> 
			</cfif>

			<!---Upload files to the directory where they will be processed --->
			
			<CFFILE ACTION = "upload"
			FILEFIELD = "form.AccrualFile"
			DESTINATION = "#filepath#"
			NAMECONFLICT =	"overwrite">
			
			<cfset DBAccrualFileUploaded = cffile.serverDirectory & "\" & cffile.ServerFile>
			
			<!---Rename to names that Saru expects --->
			<cffile action = "rename"
			  source = "#DBAccrualFileUploaded#"
			  destination = "#filepath#\TRADEWINDS_ACCRUAL.XLS"
			 > 
			 
			<cfset DBAccrualPath = "\\" & Application.WebServerName & "\" & Replace(filepath, "D:", "")>
			
			<CFFILE ACTION = "upload"
			FILEFIELD = "form.AccrualItemFile"
			DESTINATION = "#filepath#"
			NAMECONFLICT =	"overwrite">
			
			<cfset DBAccrualItemFileUploaded = cffile.serverDirectory & "\" & cffile.ServerFile>
			
			<cffile action = "rename"
			  source = "#DBAccrualItemFileUploaded#"
			  destination = "#filepath#\TRADEWINDS_ACCRUAL_ITEM.xls"
			 > 
			 
			 <cfset DBAccrualItemPath = "\\" & Application.WebServerName & "\" & Replace(filepath, "D:", "")>
			 			
			<CFFILE ACTION = "upload"
			FILEFIELD = "form.CDPFile"
			DESTINATION = "#filepath#"
			NAMECONFLICT =	"overwrite">
			
			<cfset DBCDPFileUploaded = cffile.serverDirectory & "\" & cffile.ServerFile>
			
			<cffile action = "rename"
			  source = "#DBCDPFileUploaded#"
			  destination = "#filepath#\TRADEWINDS_SHELTER.xls"
			 > 
			 
			  <cfset DBShelterPath = "\\" & Application.WebServerName & "\" & Replace(filepath, "D:", "")>
			
			<CFFILE ACTION = "upload"
			FILEFIELD = "form.CDPItemFile"
			DESTINATION = "#filepath#"
			NAMECONFLICT =	"overwrite">
			
			<cfset DBCDPItemFileUploaded = cffile.serverDirectory & "\" & cffile.ServerFile>
			
			 <cffile action = "rename"
			  source = "#DBCDPItemFileUploaded#"
			  destination = "#filepath#\TRADEWINDS_SHELTER_ITEM.xls"
			 >
			 
			 <cfset DBShelterItemPath = "\\" & Application.WebServerName & "\" & Replace(filepath, "D:", "")>
			 
			
			 <!---Inserts into database  -- one for each of the four files--->
			
			<!---AccrualFile --->
			<cfset useLakebaseForInsertAccrualFile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("accrual_upload")>
<cfif useLakebaseForInsertAccrualFile>
	<cftry>
		<cfset application.oLakebase.insertRow("accrual_upload", {
			"file_type" = "Accrual",
			"filelocation" = "#AccrualFileLocation#",
			"start_date" = "#form.Start_Date#",
			"end_date" = "#form.End_Date#",
			"uploaded_by" = "#request.AccessStructure.User_ID#",
			"created_date" = "#now()#",
			"fiscal_year" = "#FiscalYear#",
			"worksheetname" = "#AccrualWorkSheetName#",
			"dbfilelocation" = "#DBAccrualPath#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertAccrualFile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertAccrualFile>
<cfquery name="InsertAccrualFile" datasource="#application.datasource#">
			INSERT INTO Accrual_Upload
			(
				<!--- Accrual_File_Path, --->
				File_Type,
				FileLocation,
				Start_Date,
				End_Date,
				Uploaded_By,
				Created_Date,
				Fiscal_Year,
				Worksheetname,
				DBFileLocation
			)
			VALUES
			(
				<!--- '#form.AccrualFile#', --->
				'Accrual',
				'#AccrualFileLocation#',
				'#form.Start_Date#',
				'#form.End_Date#',
				'#request.AccessStructure.User_ID#',
				#now()#,
				'#FiscalYear#',
				'#AccrualWorkSheetName#',
				'#DBAccrualPath#'
			)
			</cfquery>
</cfif>
			
			<!--- AccrualItemFile --->
			<cfset useLakebaseForInsertAccrualItemFile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("accrual_upload")>
<cfif useLakebaseForInsertAccrualItemFile>
	<cftry>
		<cfset application.oLakebase.insertRow("accrual_upload", {
			"file_type" = "Accrual Items",
			"filelocation" = "#AccrualItemFileLocation#",
			"start_date" = "#form.Start_Date#",
			"end_date" = "#form.End_Date#",
			"uploaded_by" = "#request.AccessStructure.User_ID#",
			"created_date" = "#now()#",
			"fiscal_year" = "#FiscalYear#",
			"worksheetname" = "#AccrualItemWorkSheetName#",
			"dbfilelocation" = "#DBAccrualItemPath#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertAccrualItemFile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertAccrualItemFile>
<cfquery name="InsertAccrualItemFile" datasource="#application.datasource#">
			INSERT INTO Accrual_Upload
			(
				<!--- Accrual_File_Path, --->
				File_Type,
				FileLocation,
				Start_Date,
				End_Date,
				Uploaded_By,
				Created_Date,
				Fiscal_Year,
				Worksheetname,
				DBFileLocation
			)
			VALUES
			(
				<!--- '#form.AccrualItemFile#', --->
				'Accrual Items',
				'#AccrualItemFileLocation#',
				'#form.Start_Date#',
				'#form.End_Date#',
				'#request.AccessStructure.User_ID#',
				#now()#,
				'#FiscalYear#',
				'#AccrualItemWorkSheetName#',
				'#DBAccrualItemPath#'
			)
			</cfquery>
</cfif>
			
			<!--- CDPFile --->
			<cfset useLakebaseForInsertCDPFile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("accrual_upload")>
<cfif useLakebaseForInsertCDPFile>
	<cftry>
		<cfset application.oLakebase.insertRow("accrual_upload", {
			"file_type" = "CDP",
			"filelocation" = "#CDPFileLocation#",
			"start_date" = "#form.Start_Date#",
			"end_date" = "#form.End_Date#",
			"uploaded_by" = "#request.AccessStructure.User_ID#",
			"created_date" = "#now()#",
			"fiscal_year" = "#FiscalYear#",
			"worksheetname" = "#CDPWorkSheetName#",
			"dbfilelocation" = "#DBShelterPath#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertCDPFile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertCDPFile>
<cfquery name="InsertCDPFile" datasource="#application.datasource#">
			INSERT INTO Accrual_Upload
			(
				<!--- Accrual_File_Path, --->
				File_Type,
				FileLocation,
				Start_Date,
				End_Date,
				Uploaded_By,
				Created_Date,
				Fiscal_Year,
				Worksheetname,
				DBFileLocation
			)
			VALUES
			(
				<!--- '#form.CDPFile#', --->
				'CDP',
				'#CDPFileLocation#',
				'#form.Start_Date#',
				'#form.End_Date#',
				'#request.AccessStructure.User_ID#',
				#now()#,
				'#FiscalYear#',
				'#CDPWorkSheetName#',
				'#DBShelterPath#'
			)
			</cfquery>
</cfif>
			
			<!--- CDPFItemile --->
			<cfset useLakebaseForInsertCDPItemFile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("accrual_upload")>
<cfif useLakebaseForInsertCDPItemFile>
	<cftry>
		<cfset application.oLakebase.insertRow("accrual_upload", {
			"file_type" = "CDP Items",
			"filelocation" = "#CDPItemFileLocation#",
			"start_date" = "#form.Start_Date#",
			"end_date" = "#form.End_Date#",
			"uploaded_by" = "#request.AccessStructure.User_ID#",
			"created_date" = "#now()#",
			"fiscal_year" = "#FiscalYear#",
			"worksheetname" = "#CDPItemWorkSheetName#",
			"dbfilelocation" = "#DBShelterItemPath#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsertCDPItemFile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsertCDPItemFile>
<cfquery name="InsertCDPItemFile" datasource="#application.datasource#">
			INSERT INTO Accrual_Upload
			(
				<!--- Accrual_File_Path, --->
				File_Type,
				FileLocation,
				Start_Date,
				End_Date,
				Uploaded_By,
				Created_Date,
				Fiscal_Year,
				Worksheetname,
				DBFileLocation
			)
			VALUES
			(
				<!--- '#form.CDPItemFile#', --->
				'CDP Items',
				'#CDPItemFileLocation#',
				'#form.Start_Date#',
				'#form.End_Date#',
				'#request.AccessStructure.User_ID#',
				#now()#,
				'#FiscalYear#',
				'#CDPItemWorkSheetName#',
				'#DBShelterItemPath#'
			)
			</cfquery>
</cfif>
			 
			 <!---The name of the job varies by location -- get the correct one from db ---> 
			 <cfquery name="ThisJobName" datasource="#application.datasource#">
			 SELECT TOP 1 TABLE_CATALOG  from INFORMATION_SCHEMA.TABLES
			 </cfquery>
			 
			 <cfset JobName = ThisJobName.TABLE_CATALOG & '_CDP_CorporateAccrual'>
			 			 			
			 <CFQUERY NAME="RunDTS" DATASOURCE="#Application.Datasource#">
				EXEC  msdb..sp_start_job @job_name = '#JobName#'
			 </CFQUERY>
			
			
			<CFLOCATION URL="index.cfm" ADDTOKEN="No">
		</CFIF>
	

