
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
		window.location.href="index.cfm?Show_Tab=4";
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
				window.location.href="index.cfm?Show_Tab=4";
			}
			window.setTimeout('redirect();', 3000);	
			</SCRIPT>			
		<CFELSE>
			<CFSET GL_Code_File_Path = "#Application.Doc_Path#\data_files\uploaded\billbacks\GL_Code_Data">
			<CFFILE ACTION = "upload"
					FILEFIELD = "File_Path"
					DESTINATION = "#GL_Code_File_Path#"
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
					SOURCE 		= "#GL_Code_File_Path#\#File_name#"
					DESTINATION = #GL_Code_File_Path#\#Build_File_Name#">
			
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
			<CFIF FORM.ActivateStatus EQ 1>
				<cfset useLakebaseForResetOtherUpload = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_upload")>
<cfif useLakebaseForResetOtherUpload>
	<cftry>
		<cfset application.oLakebase.updateRows("gl_code_upload",
			{
				"activate_tonight" = "eq.1"
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
					WHERE Activate_Tonight = 1
				</CFQUERY>
</cfif>
			</CFIF>
			
			<CFQUERY NAME="deleteallOthers" DATASOURCE="#Application.Datasource#">
				UPDATE 	GL_Code_Upload 
				SET 	Deleted = 1
				WHERE 	DATEDIFF(d, Created_Date, GetDate()) = 0 AND 
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
									Activate_Tonight,
									Fiscal_Year			)
									
				VALUES			(	'#Build_File_Name#',
									'#GL_Code_File_Path#',
									'#CGI.SERVER_NAME#',
									'#DateStampedGLCode#',
									'#request.AccessStructure.User_ID#',
									'2',
									#FORM.ActivateStatus#,
									'#FORM.Fiscal_Year#'		)
			</CFQUERY>
			
			<cfset useLakebaseForDeletedTempData = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_activation_temp")>
<cfif useLakebaseForDeletedTempData>
	<cftry>
		<cfset application.oLakebase.deleteRows("gl_code_activation_temp", {})>
		<cfcatch type="any">
			<cfset useLakebaseForDeletedTempData = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeletedTempData>
<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
				DELETE FROM GL_Code_Activation_Temp
			</CFQUERY>
</cfif>
			
			<cfset useLakebaseForDeleteValidTemp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_activation_valid_temp")>
<cfif useLakebaseForDeleteValidTemp>
	<cftry>
		<cfset application.oLakebase.deleteRows("gl_code_activation_valid_temp", {})>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteValidTemp = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteValidTemp>
<CFQUERY NAME="DeleteValidTemp" DATASOURCE="#Application.Datasource#">
				DELETE FROM Gl_Code_Activation_Valid_Temp
			</CFQUERY>
</cfif>
			
			<CFQUERY NAME="RunDTS" DATASOURCE="#Application.Datasource#">
				EXEC GL_Code_Call_DTS_Through_Job
			</CFQUERY>
			
			<CFLOCATION URL="index.cfm?Show_Tab=4&ProcessWait=1" ADDTOKEN="No">
		</CFIF>
	<CFELSEIF FORM.DeleteRecord EQ 1>
		<CFQUERY NAME="Permanent_Delete" DATASOURCE="#Application.Datasource#">
			DELETE FROM GL_Code_Upload WHERE GL_Code_Upload_ID = '#RID#'
		</CFQUERY>
		<CFLOCATION URL="index.cfm?Show_Tab=4" ADDTOKEN="No">
	</CFIF>
</CFIF>

