

<cfparam name="form.filetype" default="">
<cfparam name="form.sheet_name" default="sheet1">

<cfif form.sheet_name EQ "">
<cfset form.sheet_name = "sheet1">
</cfif>
<CFIF form.filetype NEQ "">
<cfset uploadmargintargetManager = CreateObject("component","components.settings.upload_margin_targets.uploadmargintargetManager") />
<cfset qAnyAliveProcess = uploadmargintargetManager.AnyAliveProcess(form.filetype)>
		
		<CFIF qAnyAliveProcess.RecordCount GT 0>
			<TABLE ALIGN="Center">
				<TR>
					<TD><FONT COLOR="Red" SIZE="3"><B>Some other user is uploading the file now. Please try after few seconds.</B></FONT></TD>
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
			
				<CFSET Margin_File_Path = "#Application.Doc_Path#\Data_Files\uploaded\Settings\Upload_Margin_Targets">
			<CFFILE ACTION = "upload"
					FILEFIELD = "File_Path"
					DESTINATION = "#Margin_File_Path#"
					NAMECONFLICT =	"MakeUnique">
					
			<CFSET File_name = CFFILE.serverFile>	
			<CFSET GetGuid = CreateUUID()>
			<CFSET GetGuid = REPLACE(GetGuid,"-","_","All")>
			<CFSET Build_File_Name = GetGuid>

			<CFSET Build_File_Name = REReplaceNoCase(Build_File_Name,"[^0-9A-Za-z_]","_","All")>
			<CFSET Build_File_Name = REReplace(Build_File_Name,"_+","_","All")>
			<CFSET Build_File_Name = Left(Build_File_Name,100)>
			<CFSET Build_File_Name = "Renamed_#Build_File_Name#.xls">
			
			<CFSET Common_File_Name = "Heinz_Uploaded_GDW4.xls">
			<cfif form.filetype eq 3>
				<CFSET Common_File_Name = "Heinz_Uploaded_GDW4.xls">
			<cfelseif form.filetype eq 5>
				<CFSET Common_File_Name = "Uploaded_Item_Temp.xls">
			<cfelseif form.filetype eq 2>
				<CFSET Common_File_Name = "Uploaded_Item_Temp.xls">
			</cfif>
			<cftry>
			<cffile ACTION		="delete" file="#Margin_File_Path#\#Common_File_Name#" >
				<cfcatch>
					ok
				</cfcatch>
			</cftry> 
			
			<CFFILE ACTION 		= "COPY"
					SOURCE 		= "#Margin_File_Path#\#File_name#"
					DESTINATION = "#Margin_File_Path#\#Build_File_Name#">
					
			<CFFILE ACTION 		= "COPY"
					SOURCE 		= "#Margin_File_Path#\#File_name#"
					DESTINATION = "#Margin_File_Path#\#Common_File_Name#" >
			
			<CFSET DateStamp = DateFormat(Now(),"mm/dd/yyyy")>
			<CFSET DateStamp = REPLACE(DateStamp,"/","_","All")>
			
			<CFSET TimeStamp = TimeFormat(Now(),"HH:mm:ss")>						
			<CFSET TimeStamp = REPLACE(TimeStamp,":","_","All")>					
			<CFSET DateStampedMarginName = "Margin_#DateStamp#_#TimeStamp#">
			
			
			<CFQUERY NAME="deleteallOthers" DATASOURCE="#Application.Datasource#">
				UPDATE 	Generic_Files_Upload 
				SET 	Deleted = 1
				WHERE 	DATEDIFF(d, Created_Date, GetDate()) = 0 AND 
						Deleted = 0
			</CFQUERY>
			
			<CFQUERY NAME="DataInsert" DATASOURCE="#Application.Datasource#">
				INSERT INTO 
				
				Generic_Files_Upload	
									(	
									Generic_Files_Uni_Name,
									Generic_Files_File_Path,
									Server_Name,
									Generic_Files_Title,
									Generic_File_type,
									generic_worksheet_name,
									Uploaded_By,
									Generic_Files_Upload_Process_Status_ID
									)
									
				VALUES			(	'#Build_File_Name#',
									'#Margin_File_Path#',
									'#application.WebServerName#',
									'#DateStampedMarginName#',
									#form.filetype#,
									'#form.sheet_name#',
									'#request.AccessStructure.User_ID#',
									2	)
			</CFQUERY>
			
			 <CFIF form.filetype EQ 1>
				<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
					DELETE FROM GDWL4_Margin_Targets_Temp
				</CFQUERY>
				<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
					DELETE FROM GDWL4_Margin_Targets_Valid_Temp
				</CFQUERY>
				<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
					UPDATE Generic_Files_Upload_Log
					SET DELETED = 1
					where Generic_Files_Upload_Type = 1
				</CFQUERY>
			<CFQUERY NAME="RunDTS" DATASOURCE="#Application.Datasource#">
				EXEC Call_GDW4_Upload_DTS_Through_Job
			</CFQUERY>
			
			<CFELSEIF form.filetype EQ 2>
				<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
					DELETE FROM ITEM_MARGIN_TARGETS_TEMP
				</CFQUERY>
				<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
					DELETE FROM ITEM_MARGIN_TARGETS_VALID_TEMP
				</CFQUERY>
				<CFQUERY NAME="DeletedTempData" DATASOURCE="#Application.Datasource#">
					UPDATE Generic_Files_Upload_Log
					SET DELETED = 1
					where Generic_Files_Upload_Type = 2
				</CFQUERY>
			<CFQUERY NAME="RunDTS" DATASOURCE="#Application.Datasource#">
				EXEC Call_Item_Upload_DTS_Through_Job
			</CFQUERY>
			</CFIF>

			<CFIF form.filetype EQ 1>
				<cflocation url="refresh_upload_marginfile.cfm?filetype=#form.filetype#&defaultmargin=#form.defaulttarget#">
			<CFELSEIF form.filetype EQ 2>
				<cflocation url="refresh_upload_marginfile.cfm?filetype=#form.filetype#&defaultmargin_fob=#form.defaulttarget_fob#&defaultmargin_del=#form.defaulttarget_del#&defaulttype=#form.defaulttype#&defaultfob=#form.defaultFOBPrice#&defaultdel=#form.defaultDelPrice#&defaultfobcash=#form.defaultFOBCashDiscount#&defaultDelCash=#form.defaultDelCashDiscount#">
			</CFIF>
		</CFIF>
	</CFIF>



