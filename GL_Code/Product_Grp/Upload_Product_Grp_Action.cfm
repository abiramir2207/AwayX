<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFIF IsDefined("FORM.JustActivateToNight")>
<CFELSE>
	<CFIF FORM.RID EQ "">		
		<CFQUERY NAME="AnyAliveProcess" DATASOURCE="#Application.Datasource#">
			SELECT * FROM GL_Code_Pro_Grp_Upload WHERE GL_Code_Process_Status_ID < 5 AND GL_Code_Process_Status_ID <> 3 AND Deleted = 0
		</CFQUERY>

		<CFIF AnyAliveProcess.RecordCount GT 0>
			<TABLE ALIGN="Center">
				<TR>
					<TD><FONT COLOR="Red" SIZE="3"><B>Some other user is uploading product group data now. Please try after few second.</B></FONT></TD>
				</TR>
			</TABLE>
			
			<SCRIPT language="JavaScript">
			function redirect()
			{
				window.location.href="Upload_Product_Grp.cfm";
			}
			window.setTimeout('redirect();', 3000);	
			</SCRIPT>			
		<CFELSE>
			<CFSET Product_Grp_File_Path = "#Application.Doc_Path#\data_files\uploaded\GL_Code\Product_Grp_Data">
			<CFFILE ACTION = "upload"
					FILEFIELD = "File_Path"
					DESTINATION = "#Application.Doc_Path#\data_files\uploaded\GL_Code\Product_Grp_Data"
					NAMECONFLICT =	"MakeUnique">
					
			<CFSET File_name = CFFILE.serverFile>	
			<CFSET GetGuid = CreateUUID()>
			<CFSET GetGuid = REPLACE(GetGuid,"-","_","All")>
			<CFSET Build_File_Name = GetGuid>
			
			<CFSET Build_File_Name = REReplaceNoCase(Build_File_Name,"[^0-9A-Za-z_]","_","All")>
			<CFSET Build_File_Name = REReplace(Build_File_Name,"_+","_","All")>
			<CFSET Build_File_Name = Left(Build_File_Name,100)>
			<CFSET Build_File_Name = "Renamed_#Build_File_Name#.xls">
			
			<CFFILE ACTION 		= "COPY"
					SOURCE 		= "#Application.Doc_Path#\data_files\uploaded\GL_Code\Product_Grp_Data\#File_name#"
					DESTINATION = "#Application.Doc_Path#\data_files\uploaded\GL_Code\Product_Grp_Data\#Build_File_Name#">
			
			<CFSET DateStamp = DateFormat(Now(),"mm/dd/yyyy")>
			<CFSET DateStamp = REPLACE(DateStamp,"/","_","All")>
			
			<CFSET TimeStamp = TimeFormat(Now(),"HH:mm:ss")>						
			<CFSET TimeStamp = REPLACE(TimeStamp,":","_","All")>					
			<CFSET DateStampedProGrp = "ProductGrp_#DateStamp#_#TimeStamp#">
			
			<!--- <CFQUERY NAME="UpdateOtherStatus" DATASOURCE="#Application.Datasource#">
				UPDATE	GL_Code_Upload
				SET 	Deleted = 1
				WHERE	GL_Code_Process_Status_ID = 2
			</CFQUERY> --->
			
			<!--- 
			<CFQUERY NAME="ResetOtherUpload" DATASOURCE="#Application.Datasource#">
				UPDATE GL_Code_Upload
				SET Activate_Tonight = 0
				WHERE Activation_Date = '#FORM.Activation_Date#'
			</CFQUERY> --->
						
			<CFQUERY NAME="deleteallOthers" DATASOURCE="#Application.Datasource#">
				UPDATE 	GL_Code_Pro_Grp_Upload 
				SET 	Deleted = 1
				WHERE 	DATEDIFF(d, ProGrp_Activation_Date, '#FORM.ProGrp_Activation_Date#') = 0 AND 
						Fiscal_year = '#FORM.Fiscal_year#' AND
						Deleted = 0
			</CFQUERY>
			
			<cfset useLakebaseForDataInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_pro_grp_upload")>
<cfif useLakebaseForDataInsert>
	<cftry>
		<cfset application.oLakebase.insertRow("gl_code_pro_grp_upload", {
			"uni_name" = "#Build_File_Name#",
			"file_path" = "#Product_Grp_File_Path#",
			"server_name" = "#application.WebServerName#",
			"title" = "#DateStampedProGrp#",
			"uploaded_by" = "#request.AccessStructure.User_ID#",
			"gl_code_process_status_id" = "2",
			"progrp_activation_date" = "#FORM.ProGrp_Activation_Date#",
			"fiscal_year" = "#FORM.Fiscal_Year#",
			"worksheetname" = "#FORM.WorkSheetName#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForDataInsert = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDataInsert>
<CFQUERY NAME="DataInsert" DATASOURCE="#Application.Datasource#">
				INSERT INTO 
				
				GL_Code_Pro_Grp_Upload	(	Uni_Name,
											File_Path,
											Server_Name,
											Title,
											Uploaded_By,
											GL_Code_Process_Status_ID,
											ProGrp_Activation_Date,
											Fiscal_Year,
											WorkSheetName			)
									
				VALUES					(	'#Build_File_Name#',
											'#Product_Grp_File_Path#',
											'#application.WebServerName#',
											'#DateStampedProGrp#',
											'#request.AccessStructure.User_ID#',
											'2',
											'#FORM.ProGrp_Activation_Date#',
											'#FORM.Fiscal_Year#',
											'#FORM.WorkSheetName#'		)
			</CFQUERY>
</cfif>
			
			<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_Pro_Group_Mapping_Temp 
				WHERE GL_Code_Pro_Grp_Upload_ID IN (	SELECT GL_Code_Pro_Grp_Upload_ID 
														FROM GL_Code_Pro_Grp_Upload
														WHERE Fiscal_year = '#FORM.Fiscal_year#'	)
			</CFQUERY>
			
			<CFQUERY NAME="RunDTS" DATASOURCE="#Application.Datasource#">
				EXEC GL_Code_Prod_Grp_Call_DTS_Through_Job
			</CFQUERY>
			<CFLOCATION URL="Check_Prod_Grp_Upload_Status.cfm" ADDTOKEN="No">
		</CFIF>
	<CFELSE>	
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
			<CFQUERY NAME="UpdateUpload" DATASOURCE="#Application.Datasource#">
				UPDATE GL_Code_Upload
				SET Activation_Date = '#FORM.Activation_Date#'
				WHERE GL_Code_Upload_ID = '#RID#'
			</CFQUERY>		
		</CFIF>		
		 --->
	</CFIF>
</CFIF>
</body>
</html>
