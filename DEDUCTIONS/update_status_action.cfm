<!--- 
BJF: This is designed to be a quick way to update information on a 
particular deduction, and will be accessed from the scorecard.

This is the save page

Sections:
*Check to see if user can modify deductions
*Lock deduction
*Header information on deduction
Each of these will have user permissions and deduction status verified using existing logic
*Reassign (this parent/child only?)
*Classification
*Action

*Reject
*Upload document
*Notes

Information is passed from /deductions/update_status.cfm. 
Please note that many fields from the parent may not be defined if the user doesn't have permission to do that action 

--->

<!--- Defaults --->
<!--- Deduction_ID required -- fail without it --->
<cfparam 	name="To_Analyst"								default="#Form.Old_Analyst#">
<cfparam 	name="DD_Classification_ID"					default="#Form.Old_Classification#">
<cfparam 	name="DeductionType_ID"						default="#Form.Old_DeductionType#">
<cfparam 	name="DD_Stage_ID"							default="#Form.Old_Stage#">
<cfparam 	name="Reject"									default="0">
<cfparam	name="DD_Rejected_Reason"					default="">
<cfparam	name="DD_Note"								default="">
<cfparam 	name="Doc_File"								default="">
<cfparam 	name="Doc_File_Name"						default="">
<cfparam 	name="Doc_Title"								default="">
<cfparam 	name="Doc_Public"							default="0">
<cfparam 	name="Doc_Description"						default="">
<!--- D42846 :: Deduction tool upgrades START--->
<cfparam 	name="DD_User_Reference1"					default="#Form.DD_User_Reference1#">
<cfparam 	name="DD_User_Reference2"					default="#Form.DD_User_Reference2#">
<cfparam 	name="Old_DD_User_Reference1"				default="#Form.Old_DD_User_Reference1#">
<cfparam 	name="Old_DD_User_Reference2"				default="#Form.Old_DD_User_Reference2#">
<!--- D42846 :: Deduction tool upgrades END--->
<cfparam 	name="Reference_Number"					default="0">
<cfparam 	name="Old_Reference_Number"				default="#Form.Old_Reference_Number#">

<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() /> 

	<!--- BEGIN REASSIGN --->
	<cfif To_Analyst IS NOT Old_Analyst>
		<cfset useLakebaseForStore_Data = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_reassign")>
		<cfif useLakebaseForStore_Data>
			<cftry>
				<cfset application.oLakebase.insertRow("dd_reassign", {
					"deduction_id" = Deduction_ID,
					"from_analyst" = Old_Analyst,
					"to_analyst" = To_Analyst,
					"by_analyst" = request.AccessStructure.User_ID
				})>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForStore_Data = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForStore_Data>
		<CFQUERY NAME="Store_Data" DATASOURCE="#Application.Datasource#">
			INSERT INTO 
			
			DD_Reassign (	Deduction_ID,
							From_Analyst,
							To_Analyst,
							By_Analyst		)
				
			VALUES		(	'#Deduction_ID#',
							'#Old_Analyst#',
							'#To_Analyst#',
							'#request.AccessStructure.User_ID#'		)
		</CFQUERY>	
		</cfif>
		
		<cfset useLakebaseForUpdate_DD_Analyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdate_DD_Analyst>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Deduction_ID#" },
					{ "analyst_user_id" = To_Analyst }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdate_DD_Analyst = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdate_DD_Analyst>
		<CFQUERY NAME="Update_DD_Analyst" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions	
			SET 			Analyst_User_ID = 	'#To_Analyst#'					
			WHERE 	Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
		</cfif>
		
		<cfset useLakebaseForqCheckStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForqCheckStatus>
			<cftry>
				<cfset qCheckStatus = application.oLakebase.toQuery(
					application.oLakebase.selectRows("deductions", {
						"select" = "dd_status",
						"deduction_id" = "eq.#Deduction_ID#",
						"dd_status" = "in.(1,2)"
					}),
					"dd_status"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForqCheckStatus = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForqCheckStatus>
		<CFQUERY NAME="qCheckStatus" DATASOURCE="#Application.Datasource#">
			SELECT	DD_Status
			FROM		Deductions
			WHERE 	Deduction_ID = '#Deduction_ID#'
			AND		DD_Status IN (1,2)
		</CFQUERY>
		</cfif>
		
		<cfif qCheckStatus.RecordCount>
			<cfset useLakebaseForqResetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
			<cfif useLakebaseForqResetStatus>
				<cftry>
					<cfset application.oLakebase.updateRows("deductions",
						{ "deduction_id" = "eq.#Deduction_ID#" },
						{ "dd_status" = 1 }
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForqResetStatus = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForqResetStatus>
			<CFQUERY NAME="qResetStatus" DATASOURCE="#Application.Datasource#">
				UPDATE 	Deductions	
				SET 			DD_Status = 1				
				WHERE 	Deduction_ID = '#Deduction_ID#'
			</cfquery>
			</cfif>
		</cfif>
		
	</cfif>
	<!--- END REASSIGN --->
	
	<!--- CLASSIFICATION --->
	<cfif DD_Classification_ID IS NOT Old_Classification>
		<cfset useLakebaseForUpdateClassification1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateClassification1>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Deduction_ID#" },
					{ "dd_classification_id" = DD_Classification_ID }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateClassification1 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateClassification1>
		<CFQUERY NAME="UpdateClassification" DATASOURCE="#Application.Datasource#">
			UPDATE Deductions
			SET DD_Classification_ID = '#DD_Classification_ID#'
			WHERE Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
		</cfif>
	</cfif>
	<!--- END CLASSIFICATION --->

	<!--- DEDUCTION TYPE --->
	<cfif DeductionType_ID IS NOT Old_DeductionType>
		<cfset useLakebaseForUpdateClassification2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateClassification2>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Deduction_ID#" },
					{ "deductiontype_id" = DeductionType_ID }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateClassification2 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateClassification2>
		<CFQUERY NAME="UpdateClassification" DATASOURCE="#Application.Datasource#">
			UPDATE Deductions
			   SET DeductionType_ID = '#DeductionType_ID#'
			 WHERE Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
		</cfif>
	</cfif>
	<!--- END CLASSIFICATION --->
	
	<!--- Reference Number --->
	<cfif Reference_Number IS NOT Old_Reference_Number>
		<cfset useLakebaseForUpdateReferenceNumber = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateReferenceNumber>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Deduction_ID#" },
					{ "dd_reference" = Reference_Number }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateReferenceNumber = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateReferenceNumber>
		<CFQUERY NAME="UpdateReferenceNumber" DATASOURCE="#Application.Datasource#">
			UPDATE Deductions
			SET DD_Reference = '#Reference_Number#'
			WHERE Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
		</cfif>
	</cfif>
	<!--- END Reference Number --->

	<!--- ACTION --->
	<cfif DD_Stage_ID IS NOT Old_Stage>
	<cfquery name="InsertDeductions" datasource="#application.datasource#">
		INSERT INTO DD_Ded_Actions
		(
			Deduction_ID,
			DD_Stage_ID,
			Action_Completed,
			Completed_By,
			Date_Completed			
		)
		VALUES
		(
			'#Deduction_ID#',
			'#DD_Stage_ID#',
			'#Old_Stage#',
			'#request.AccessStructure.user_id#',
			#now()#
		)
	</cfquery>				
	
	<cfquery name="UpdateDeductions" datasource="#application.datasource#">
		UPDATE Deductions
		SET DD_Stage = #DD_Stage_ID#,
		DD_Ded_Action_ID = '#InsertDeductions.DD_Ded_Action_ID#'
		WHERE Deduction_ID = '#Deduction_ID#'
	</cfquery>
	<!---- add reminder ---->
	<cfset DeductionManager.loadDDStageInfo(DD_Stage_ID) />
	 <cfset DeductionManager.loadDDActionInfo(InsertDeductions.DD_Ded_Action_ID) />
	<cfif DeductionManager.getDDStageIsAutoReminded() and DeductionManager.getDDStageAutoDefaultDays() gt 0>
			<cfset reminderMessage = "Auto Reminder - " & DeductionManager.getDDStageDescription() />
			<cfset insertReminderID = DeductionManager.addReminder(Deduction_ID,reminderMessage,dateAdd("d",DeductionManager.getDDStageAutoDefaultDays(),DeductionManager.getDDActionCompletedDate()),2) />				
		<cfset DeductionManager.updateAction(InsertDeductions.DD_Ded_Action_ID,insertReminderID) />	
	</cfif> 
	</cfif>
	<!--- END ACTION --->
	
	<!--- REJECT --->
	<CFIF Reject EQ 1>
	<cfset useLakebaseForUpdateReject = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForUpdateReject>
		<cftry>
			<cfset application.oLakebase.updateRows("deductions",
				{ "deduction_id" = "eq.#Deduction_ID#" },
				{
					"dd_rejected" = 1,
					"dd_rejected_by" = request.AccessStructure.User_ID,
					"dd_rejected_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"dd_rejected_reason" = DD_Rejected_Reason
				}
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateReject = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateReject>
	<CFQUERY NAME="UpdateReject" DATASOURCE="#Application.Datasource#">
		UPDATE Deductions
		SET DD_Rejected = 1,
			DD_Rejected_By = '#request.AccessStructure.User_ID#',
			DD_Rejected_Date = getdate(),
			DD_Rejected_Reason = '#DD_Rejected_Reason#'
		WHERE Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
	</cfif>
	<CFIF LEFT(application.returned_customer_setting.customer_keyword,1) IS "H">
		<CFSET Log_1520_DataInsert = CreateObject("Component", "Components.Interfaces.Log1520").init(Deduction_ID) />
		<CFSET Log_1520_DataInsert.AddtoLog()>
		<CFSET Close_1520 = 1>
		<!--- Ana 15454 - Commentting to avoid DeadLock 
		<CFINCLUDE TEMPLATE="/GL_Code/GL_Code_In_Billback/Close_All_Interface_Insert.cfm"> --->
	</CFIF>		
	</CFIF>
				
	<!--- END REJECT --->
	
	<!--- NOTES --->
	<cfif len(trim(DD_Note)) GT 0>
		<cfset useLakebaseForInsertNote = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_notes")>
		<cfif useLakebaseForInsertNote>
			<cftry>
				<cfset application.oLakebase.insertRow("dd_notes", {
					"deduction_id" = Deduction_ID,
					"dd_note" = trim(DD_Note),
					"dd_note_date" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
					"dd_note_by" = request.AccessStructure.User_ID
				})>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForInsertNote = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForInsertNote>
		<cfquery name="InsertNote" datasource="#application.datasource#">
			INSERT INTO DD_notes
			(
				Deduction_ID,
				DD_Note,
				DD_Note_Date,
				DD_Note_By
			)
			VALUES
			(
				'#Deduction_ID#',
				'#trim(DD_Note)#', 
				#Now()#,
				'#request.AccessStructure.User_ID#'
			)
		</cfquery>
		</cfif>
		
		<cfquery name="Latest_Notes" datasource="#application.datasource#">
			UPDATE Deductions
			SET Notes_Count = (SELECT COUNT(Deleted) FROM DD_Notes WHERE Deduction_ID  = Deductions.Deduction_ID AND Deleted = 0),
			Latest_DD_Note_ID = (SELECT TOP 1 DD_Note_ID FROM DD_Notes WHERE Deduction_ID  = Deductions.Deduction_ID AND Deleted = 0 ORDER BY Created_Date DESC)
			FROM Deductions WHERE Deleted = 0 AND Deduction_ID = '#Deduction_ID#'
		</cfquery>
	</cfif>
	<!--- END NOTES --->

<!--- START User Ref --->
<!--- D42846 :: Deduction tool upgrades START--->

<cfif DD_User_Reference1 IS NOT Old_DD_User_Reference1>
		<cfset useLakebaseForUpdateUserReference1 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateUserReference1>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Deduction_ID#" },
					{ "dd_user_reference1" = DD_User_Reference1 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateUserReference1 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateUserReference1>
		<CFQUERY NAME="UpdateUserReference1" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 			DD_User_Reference1 = '#DD_User_Reference1#'
			WHERE 	Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
		</cfif>
</cfif>
<cfif DD_User_Reference2 IS NOT Old_DD_User_Reference2>
		<cfset useLakebaseForUpdateUserReference2 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
		<cfif useLakebaseForUpdateUserReference2>
			<cftry>
				<cfset application.oLakebase.updateRows("deductions",
					{ "deduction_id" = "eq.#Deduction_ID#" },
					{ "dd_user_reference2" = DD_User_Reference2 }
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateUserReference2 = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateUserReference2>
		<CFQUERY NAME="UpdateUserReference2" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 			DD_User_Reference2 = '#DD_User_Reference2#'
			WHERE 	Deduction_ID = '#Deduction_ID#'
		</CFQUERY>
		</cfif>
</cfif>	

<!--- D42846 :: Deduction tool upgrades END--->
<!--- END User Ref --->
	
	<!--- UPLOAD DOCUMENT --->
	<cfif len(trim(Doc_File_Name)) GT 0>
	<cfoutput>
		<cfset TempDirectoryLocation = GetDirectoryFromPath(File_Path)>
		<cfset TempFileName = GetFileFromPath(File_Path)>
		<cfdirectory directory="#TempDirectoryLocation#" filter="#TempFileName#" name="Tempdirectory">
		<Cfset FileSize = Tempdirectory.Size>
		<!---If they uploaded a zero length or invalid file, redirect back with error information--->
		<Cfif Filesize LT 1>
			<BR><BR><BR><BR>
				<TABLE ALIGN="CENTER">
				  <TR>
			  		<TD style="font-weight:bold;">The size of the uploaded file is 0 bytes.&nbsp;&nbsp;Please upload a larger file.</TD>
				  </TR>
				</TABLE>
				<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT> 
			<CFABORT>	
		</CFIF>	

		<CFFILE ACTION = "upload"
					FILEFIELD = "File_Path"
					DESTINATION = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc"
					NAMECONFLICT ="MakeUnique">
<!--- 		<CFFILE ACTION = "upload"
					FILEFIELD = "File_Path"
					DESTINATION = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc"
					NAMECONFLICT ="MakeUnique"> --->
		
			<CFSET Temp_File_name = CFFILE.serverFile>
			
			<CFSET sizeoffile = CFfile.FileSize>
			<CFIF sizeoffile GT 10485760><!--- 5242880 --->
				<cffile action = "delete"
		  				file = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\#temp_file_name#"> 
				
				<BR><BR><BR><BR>
				<TABLE ALIGN="CENTER">
				  <TR>
			  		<TD style="font-weight:bold;">The size of the uploaded file is more than 10MB.&nbsp;&nbsp;Please upload a smaller file.</TD>
				  </TR>
				</TABLE>
				<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT> 
			<CFABORT>
			
			</CFIF>
		
			<CFSET search = ".">
			<CFSET content = Temp_File_name>
			<CFSET family = Find(search,content)>
			<CFSET length = len(content)>
			<CFSET right_len = length-family>
			<CFSET family = ListLast(content, ".")>
			
		
			<cfset badstring = "()[]{}*^%$##@!~`'," />
			<cfif FindOneOf(badstring,content) NEQ 0>
			<BR><BR><BR><BR>
				<TABLE ALIGN="CENTER">
				  <TR>
			  		<TD style="font-weight:bold;">The uploaded file contains invalid characters; possibly including "()[]{}*^%$##@!~`',".&nbsp;&nbsp;Prior to upload, please rename the file.</TD>
				  </TR>
				</TABLE>
				<SCRIPT LANGUAGE="JavaScript1.1" TYPE="text/javascript" FOR="window" EVENT="onLoad()">setTimeout("history.back();", 7000);</SCRIPT> 
			<CFABORT>	
			</cfif>
			
			
			<!---
			<CFSET Unique_ID = createUUID()>
			<CFSET Actual_File_Name = "#Replace(Unique_ID,"-","_","all")#.#family#">
		
		
			<CFFILE ACTION = "rename"
					SOURCE = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\#temp_file_name#"
		  			DESTINATION = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_Doc\#Actual_file_name#">
					
			<CFFILE ACTION = "copy"
					SOURCE = "#Application.Doc_Path#\Temp_Files\Documents\Temp_Uploaded_doc\#Actual_file_name#"
		  			DESTINATION = "#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\#Actual_file_name#">
			--->

			<cffile action="upload" destination="#Application.Doc_Path#\Data_Files\Uploaded\Documents\Uploaded_Doc\" nameconflict="makeunique">
		
			<cfset useLakebaseForGetPosition = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_position_holders")>
<cfif useLakebaseForGetPosition>
	<cftry>
		<cfset GetPosition = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_position_holders", {
				"user_id" = "eq.#request.AccessStructure.user_id#",
				"user_position_type" = "eq.P",
				"deleted" = "eq.0",
				"select" = "user_positions_id"
			}), "user_positions_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetPosition = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetPosition>
<CFQUERY NAME="GetPosition" DATASOURCE="#Application.Datasource#">
				SELECT 	User_Positions_ID
				
				FROM 	User_Position_Holders
				
				WHERE 	User_ID = '#request.AccessStructure.user_id#' AND 
				User_Position_Type = 'P' AND
						Deleted = 0
			</CFQUERY>
</cfif>	
		<!--- Insert the record --->
			<CFQUERY NAME="Save_Data" datasource="#application.datasource#">
				SET NOCOUNT ON
				INSERT INTO		Document_Details
								(	Doc_Uni_Name,
									Doc_Title,
									Doc_Description,
									Uploaded_Date,
									Uploaded_By,
									Deleted,
									Doc_File_Name,
									Doc_Size,
									LastUpdated_UserId,
									User_Position_ID,
									Public_View
								)
								
				Values			(	'#cffile.serverFile#',
									'#Form.Doc_Title#',
									'#Doc_Description#',
									#now()#,
									'#request.AccessStructure.user_id#',
									0,
									'#Doc_File_Name#',
									#sizeoffile#,
									'#request.AccessStructure.user_id#',
									#GetPosition.User_Positions_ID#,
									#Doc_Public#
								)
				SELECT Doc_ID = @@IDENTITY
				SET NOCOUNT OFF			
			</CFQUERY>	
			
			<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
			INSERT	INTO Contract_Attachments
					(
						Deduction_ID,
						Doc_ID
					)
			VALUES
					(
						'#Deduction_ID#',
						'#Save_Data.Doc_ID#'
					)
			</CFQUERY>	
		
		</cfoutput>
	</cfif>
	<!--- END UPLOAD DOCUMENT --->
	
	<!--- Unlock Deduction --->
	<cfset useLakebaseForLockDD = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForLockDD>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#Deduction_ID#"
			},
			{
				"is_locked" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForLockDD = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForLockDD>
<CFQUERY NAME="LockDD" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	Is_Locked = 0		
		WHERE 	Deduction_ID = '#Deduction_ID#'
	</CFQUERY>
</cfif>	
	<!--- Unlock Deduction --->
	
	<BR><BR><BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">
			Your changes have been made. <br>You will need to refresh the list of records to see the changes displayed there.
			</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function closeWindow()
	{
		window.close()
	}
	window.setTimeout('closeWindow()', 2000);	
	</SCRIPT>
	