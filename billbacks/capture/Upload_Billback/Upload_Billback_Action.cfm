<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFIF FORM.RID EQ "">		
	<CFQUERY NAME="AnyAliveProcess" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Upload_Master WHERE (Process_Status_ID < 5 AND Process_Status_ID <> 3) OR Alive_Upload = 1 AND Deleted = 0
	</CFQUERY>
	<CFQUERY NAME="AnyAliveProcess2" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Upload_Details WHERE D_Process_Status_ID < 5 AND D_Process_Status_ID <> 3 AND Deleted = 0
	</CFQUERY>
	
	<CFIF AnyAliveProcess.RecordCount GT 0 OR AnyAliveProcess2.RecordCount GT 0>
		<TABLE ALIGN="Center">
			<TR>
				<TD><FONT COLOR="Red" SIZE="3"><B>Some other user is uploading GL Code data now. Please try after few second.</B></FONT></TD>
			</TR>
		</TABLE>
		
		<SCRIPT language="JavaScript">
		function redirect()
		{
			window.location.href="index.cfm?Show_Tab=1";
		}
		window.setTimeout('redirect();', 3000);	
		</SCRIPT>			
	<CFELSE>	
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- Header Upload --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<CFSET WebServerName = appSettings.getWebserverInternalIPAddress()>
	<!--- If the "Application.Doc_Path" already has a servername, then use that path as that already has the webservername info --->
			<cfif Find("\\",Application.Doc_Path) neq 0>
				<cfset WebServerName = "">
				<cfset AppDocPath = Application.Doc_Path>
			<cfelseif trim(WebServerName) neq "">
				<cfset WebServerName =  "\\" & WebServerName & "\">
				<cfset AppDocPath = Replace(Application.Doc_Path, ":", "$")>
			<cfelse>
			<!--- Dev Note: 10747 Milan --->
				<CFLOCATION URL = "index.cfm?Show_Tab=1&EmptyWebServerInfo=1">
			</cfif>
		
		<CFSET TempFile_Path = "#WebServerName##AppDocPath#\Temp_Files\Upload_Billback">

		<CFFILE ACTION = "upload"
				FILEFIELD = "Header_File_Path"
				DESTINATION = "#TempFile_Path#"
				NAMECONFLICT =	"MakeUnique">
				
		<CFSET File_name = CFFILE.serverFile>	
		
		<CFSET Header_File_Path = "#WebServerName##AppDocPath#\Data_Files\Uploaded\billbacks\capture\Upload_Billback\Data_Files">
		<CFSET GetGuid = CreateUUID()>
		<CFSET GetGuid = REPLACE(GetGuid,"-","_","All")>
		<CFSET Build_File_Name = GetGuid>
		
		<CFSET Build_File_Name = REReplaceNoCase(Build_File_Name,"[^0-9A-Za-z_]","_","All")>
		<CFSET Build_File_Name = REReplace(Build_File_Name,"_+","_","All")>
		<CFSET Build_File_Name = Left(Build_File_Name,100)>
		<CFSET Build_File_Name = "Hearder_#Build_File_Name#.xls">
				
		<CFFILE ACTION 		= "COPY"
				SOURCE 		= "#TempFile_Path#\#File_name#"
				DESTINATION = "#Header_File_Path#\#Build_File_Name#">
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- End Header Upload --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		
		
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- Detail Upload --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->	
		<CFFILE ACTION = "upload"
				FILEFIELD = "Detail_File_Path"
				DESTINATION = "#TempFile_Path#"
				NAMECONFLICT =	"MakeUnique">
				
		<CFSET Detail_File_name = CFFILE.serverFile>	
		
		<CFSET Detail_File_Path = "#WebServerName##AppDocPath#\Data_Files\Uploaded\billbacks\capture\Upload_Billback\Data_Files">
		<CFSET GetGuid = CreateUUID()>
		<CFSET GetGuid = REPLACE(GetGuid,"-","_","All")>
		<CFSET Detail_Build_File_Name = GetGuid>
		
		<CFSET Detail_Build_File_Name = REReplaceNoCase(Detail_Build_File_Name,"[^0-9A-Za-z_]","_","All")>
		<CFSET Detail_Build_File_Name = REReplace(Detail_Build_File_Name,"_+","_","All")>
		<CFSET Detail_Build_File_Name = Left(Detail_Build_File_Name,100)>
		<CFSET Detail_Build_File_Name = "Detail_#Detail_Build_File_Name#.xls">

		<CFFILE ACTION 		= "COPY"
				SOURCE 		= "#TempFile_Path#\#Detail_File_name#"
				DESTINATION = "#Detail_File_Path#\#Detail_Build_File_Name#">
		
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- End Detail Upload --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<CFSET DateStamp = DateFormat(Now(),"mm/dd/yyyy")>
		<CFSET DateStamp = REPLACE(DateStamp,"/","_","All")>
		
		<CFSET TimeStamp = TimeFormat(Now(),"HH:mm:ss")>						
		<CFSET TimeStamp = REPLACE(TimeStamp,":","_","All")>					
		<CFSET DateStampedBBUpload = "BB_Upload_#DateStamp#_#TimeStamp#">
		
		<cfset useLakebaseForUpdateLatest = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_master")>
<cfif useLakebaseForUpdateLatest>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_upload_master",
			{
				"latest_upload" = "eq.1"
			},
			{
				"latest_upload" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateLatest = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateLatest>
<CFQUERY NAME="UpdateLatest" DATASOURCE="#Application.Datasource#">
			UPDATE Billback_Upload_Master
			SET Latest_Upload = 0
			WHERE Latest_Upload = 1
		</CFQUERY>
</cfif>
		
		<cfset useLakebaseForUpdateLatest1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_details")>
<cfif useLakebaseForUpdateLatest1>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_upload_details",
			{
				"latest_upload" = "eq.1"
			},
			{
				"latest_upload" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateLatest1 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateLatest1>
<CFQUERY NAME="UpdateLatest1" DATASOURCE="#Application.Datasource#">
			UPDATE Billback_Upload_Details
			SET Latest_Upload = 0
			WHERE Latest_Upload = 1
		</CFQUERY>
</cfif>
				
		<cfset useLakebaseForHeaderInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_master")>
<cfif useLakebaseForHeaderInsert>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_upload_master", {
			"unique_name" = "#Build_File_Name#",
			"master_file_path" = "#Header_File_Path#",
			"title" = "#DateStampedBBUpload#",
			"uploaded_by" = "#request.AccessStructure.User_ID#",
			"process_status_id" = "2",
			"latest_upload" = "1",
			"alive_upload" = "1",
			"worksheetname" = "#FORM.Header_WS_Name#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForHeaderInsert = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForHeaderInsert>
<CFQUERY NAME="HeaderInsert" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			
			Billback_Upload_Master	(	Unique_Name,
										Master_File_Path,
										Title,
										Uploaded_By,
										Process_Status_ID,
										Latest_Upload,
										Alive_Upload,
										WorkSheetName		)
								
			VALUES					(	'#Build_File_Name#',
										'#Header_File_Path#',
										'#DateStampedBBUpload#',
										'#request.AccessStructure.User_ID#',
										'2',
										1,
										1,
										'#FORM.Header_WS_Name#'					)
		</CFQUERY>
</cfif>
		
		<CFSET Master_ID = HeaderInsert.Billback_Upload_Master_ID>
			
		<cfset useLakebaseForDetailInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_details")>
<cfif useLakebaseForDetailInsert>
	<cftry>
		<cfset application.oLakebase.insertRow("billback_upload_details", {
			"billback_upload_master_id" = "#Master_ID#",
			"d_unique_name" = "#Detail_Build_File_Name#",
			"d_file_path" = "#Detail_File_Path#",
			"d_title" = "#DateStampedBBUpload#",
			"d_process_status_id" = "2",
			"latest_upload" = "1",
			"worksheetname" = "#FORM.Detail_WS_Name#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDetailInsert = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDetailInsert>
<CFQUERY NAME="DetailInsert" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			
			Billback_Upload_Details	(	Billback_Upload_Master_ID,
										D_Unique_name,
										D_File_Path,
										D_Title,
										D_Process_Status_ID,
										Latest_Upload,
										WorkSheetName		)
								
			VALUES					(	'#Master_ID#',
										'#Detail_Build_File_Name#',
										'#Detail_File_Path#',
										'#DateStampedBBUpload#',
										'2',
										1,
										'#FORM.Detail_WS_Name#'			)
		</CFQUERY>
</cfif>
		
		<CFQUERY NAME="DeleteMaster" DATASOURCE="#Application.Datasource#">
			DELETE FROM Billback_Upload_Master_Data
		</CFQUERY>
		
		<CFQUERY NAME="DeleteDetail" DATASOURCE="#Application.Datasource#">
			DELETE FROM Billback_Upload_Details_Data
		</CFQUERY>
		
		<CFQUERY NAME="DeleteLog" DATASOURCE="#Application.Datasource#">
			DELETE FROM Billback_Upload_Log
		</CFQUERY>
		
		<CFQUERY NAME="RunDTSs" DATASOURCE="#Application.Datasource#">
			EXEC Billback_Call_DTS_Through_Job	
		</CFQUERY>
		
		<CFLOCATION URL="index.cfm?Show_Tab=1&ProcessWait=1" ADDTOKEN="No">	
	</CFIF>	
	
<CFELSE>	
	
</CFIF>

<!--- 
<CFIF FORM.DeleteRecord EQ 1>
		<CFQUERY NAME="Permanent_Delete" DATASOURCE="#Application.Datasource#">
			DELETE FROM GL_Code_Upload WHERE GL_Code_Upload_ID = '#RID#'
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="deleteallOthers" DATASOURCE="#Application.Datasource#">
			UPDATE 	GL_Code_Upload 
			SET 	Deleted = 1
			WHERE 	DATEDIFF(d, Activation_Date, '#FORM.Activation_Date#') = 0 AND 
					Deleted = 0 AND GL_Code_Upload_ID <> '#RID#'
		</CFQUERY>
		<cfset useLakebaseForUpdateUpload = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_upload")>
<cfif useLakebaseForUpdateUpload>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_upload",
			{
				"gl_code_upload_id" = "eq.#RID#"
			},
			{
				"activation_date" = "#FORM.Activation_Date#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateUpload = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateUpload>
<CFQUERY NAME="UpdateUpload" DATASOURCE="#Application.Datasource#">
			UPDATE GL_Code_Upload
			SET Activation_Date = '#FORM.Activation_Date#'
			WHERE GL_Code_Upload_ID = '#RID#'
		</CFQUERY>
</cfif>		
	</CFIF>
	<CFLOCATION URL="index.cfm?Show_Tab=3" ADDTOKEN="No">
 --->

</body>
</html>
