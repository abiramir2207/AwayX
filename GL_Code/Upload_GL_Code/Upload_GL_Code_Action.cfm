


<CFIF FORM.JustActivateToNight EQ 1>
	<cfset useLakebaseForOnActivateBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_upload")>
<cfif useLakebaseForOnActivateBit>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_upload",
			{
				"gl_code_upload_id" = "eq.#FORM.RID#"
			},
			{
				"activate_tonight" = "#FORM.ActivateStatus#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForOnActivateBit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForOnActivateBit>
<CFQUERY NAME="OnActivateBit" DATASOURCE="#Application.Datasource#">
		UPDATE 	GL_Code_Upload
		SET  	Activate_Tonight = #FORM.ActivateStatus#
		WHERE 	GL_Code_Upload_ID = '#FORM.RID#'
	</CFQUERY>
</cfif>
	<BR><BR><BR><BR>
	<TABLE ALIGN="Center">
		<TR>
			<TD><FONT COLOR="Red" SIZE="3"><B><CFIF FORM.ActivateStatus EQ 1>The selected spread sheet data will be activated tonight.<CFELSE>The selected spread sheet data will not be activated tonight.</CFIF></B></FONT></TD>
		</TR>
	</TABLE>
	
	<SCRIPT language="JavaScript">
	function relocate()
	{
		window.location.href="index.cfm?Show_Tab=3";
	}
	window.setTimeout('relocate();', 3000);		
	</SCRIPT>
<CFELSE>
	<CFIF FORM.RID EQ "">
		
		<CFQUERY NAME="AnyAliveProcess" DATASOURCE="#Application.Datasource#">
			SELECT * FROM GL_Code_Upload WHERE GL_Code_Process_Status_ID < 5 AND GL_Code_Process_Status_ID <> 3 AND Deleted = 0
		</CFQUERY>
		
		<CFIF AnyAliveProcess.RecordCount GT 0>
			<TABLE ALIGN="Center">
				<TR>
					<TD><FONT COLOR="Red" SIZE="3"><B>Some other user is uploading GL Code data now. Please try after few second.</B></FONT></TD>
				</TR>
			</TABLE>
			
			<SCRIPT language="JavaScript">
			function redirect()
			{
				window.location.href="index.cfm?Show_Tab=3";
			}
			window.setTimeout('redirect();', 3000);	
			</SCRIPT>			
		<CFELSE>
			<CFSET GL_Code_File_Path = "#Application.Doc_Path#\data_files\uploaded\GL_Code\GL_Code_Data">
			<CFFILE ACTION = "upload"
					FILEFIELD = "File_Path"
					DESTINATION = "#Application.Doc_Path#\data_files\uploaded\GL_Code\GL_Code_Data"
					NAMECONFLICT =	"MakeUnique">
					
			<CFSET File_name = CFFILE.serverFile>	
			<CFSET GetGuid = CreateUUID()>
			<CFSET GetGuid = REPLACE(GetGuid,"-","_","All")>
			<CFSET Build_File_Name = GetGuid>
			
			<CFSET Build_File_Name = REReplaceNoCase(Build_File_Name,"[^0-9A-Za-z_]","_","All")>
			<CFSET Build_File_Name = REReplace(Build_File_Name,"_+","_","All")>
			<CFSET Build_File_Name = Left(Build_File_Name,100)>
			<CFSET Build_File_Name = "Renamed_#Build_File_Name#.xls">
			
			<!---
			<CFFILE ACTION 		= "COPY"
					SOURCE 		= "#Application.Doc_Path#\data_files\uploaded\GL_Code\GL_Code_Data\#File_name#"
					DESTINATION = "#Application.Doc_Path#\data_files\uploaded\GL_Code\GL_Code_Data\#Build_File_Name#">
			--->
			
			<cfif FileExists("#Application.Doc_Path#\data_files\uploaded\GL_Code\GL_Code_Data\GL_Code_Data.xls")>
				<CFFILE ACTION 		= "delete" file="#Application.Doc_Path#\data_files\uploaded\GL_Code\GL_Code_Data\GL_Code_Data.xls">
			</cfif>
				
			<CFFILE ACTION 		= "COPY"
					SOURCE 		= "#Application.Doc_Path#\data_files\uploaded\GL_Code\GL_Code_Data\#File_name#"
					DESTINATION = "#Application.Doc_Path#\data_files\uploaded\GL_Code\GL_Code_Data\GL_Code_Data.xls">		
					
			
			<CFSET DateStamp = DateFormat(Now(),"mm/dd/yyyy")>
			<CFSET DateStamp = REPLACE(DateStamp,"/","_","All")>
			
			<CFSET TimeStamp = TimeFormat(Now(),"HH:mm:ss")>						
			<CFSET TimeStamp = REPLACE(TimeStamp,":","_","All")>					
			<CFSET DateStampedGLCode = "GLCode_#DateStamp#_#TimeStamp#">
			
			<!--- <CFQUERY NAME="UpdateOtherStatus" DATASOURCE="#Application.Datasource#">
				UPDATE	GL_Code_Upload
				SET 	Deleted = 1
				WHERE	GL_Code_Process_Status_ID = 2
			</CFQUERY> --->
			
			<!--- 
			<cfset useLakebaseForResetOtherUpload = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_upload")>
<cfif useLakebaseForResetOtherUpload>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_upload",
			{
				"activation_date" = "eq.#FORM.Activation_Date#"
			},
			{
				"activate_tonight" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForResetOtherUpload = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForResetOtherUpload>
<CFQUERY NAME="ResetOtherUpload" DATASOURCE="#Application.Datasource#">
				UPDATE GL_Code_Upload
				SET Activate_Tonight = 0
				WHERE Activation_Date = '#FORM.Activation_Date#'
			</CFQUERY>
</cfif> --->
						
			<CFQUERY NAME="deleteallOthers" DATASOURCE="#Application.Datasource#">
				UPDATE 	GL_Code_Upload 
				SET 	Deleted = 1
				WHERE 	DATEDIFF(d, Activation_Date, '#FORM.Activation_Date#') = 0 AND 
						Fiscal_year = '#FORM.Fiscal_year#' AND
						Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="DataInsert" DATASOURCE="#Application.Datasource#">
				INSERT INTO 
				
				GL_Code_Upload	(	GL_Code_Uni_Name,
									GL_Code_File_Path,
									Server_Name,
									GL_Code_Title,
									Uploaded_By,
									GL_Code_Process_Status_ID,
									Activation_Date,
									Fiscal_Year,
									WorkSheetName			)
									
				VALUES			(	'#Build_File_Name#',
									'#GL_Code_File_Path#',
									'#Application.WebServerName#',
									'#DateStampedGLCode#',
									'#request.AccessStructure.User_ID#',
									'2',
									'#FORM.Activation_Date#',
									'#FORM.Fiscal_Year#',
									'#FORM.WorkSheetName#'		)
			</CFQUERY>
			
			<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_Activation_Temp
			</CFQUERY>
			
			<CFQUERY NAME="DeleteValidTemp" DATASOURCE="#Application.Datasource#">
				DELETE FROM Gl_Code_Activation_Valid_Temp 
				WHERE GL_Code_Upload_ID IN (	SELECT GL_Code_Upload_ID 
												FROM GL_Code_Upload
												WHERE Fiscal_year = '#FORM.Fiscal_year#'	)
			</CFQUERY>
			
			<CFQUERY NAME="RunDTS" DATASOURCE="#Application.Datasource#">
				EXEC GL_Code_Call_DTS_Through_Job
			</CFQUERY>
			
			<CFLOCATION URL="index.cfm?Show_Tab=3&ProcessWait=1" ADDTOKEN="No">
		</CFIF>
	<CFELSE>	
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
	</CFIF>
</CFIF>

