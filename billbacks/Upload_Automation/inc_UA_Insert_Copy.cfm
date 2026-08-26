<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/Upload_Automation/inc_UA_Insert_Copy.cfm
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  19-May-2020
Created By   :  Anand Rao
Description  :  Upload from home page
---------------------------------------------------------------------------------->

	<cfquery name="qgetCopyPath" datasource="#application.datasource#">
       SELECT DTSPATH = DTS_Reference_Path+'\inbox\Claims_Upload'
       FROM   DataInt_Settings
       ORDER BY Dataint_setting_ID
	</cfquery>

<cftry>
	<cfset pathFileName = qgetCopyPath.DTSPATH & "\" & strFileName />

	<cffile action = "copy" 
		  source = "#Application.Doc_Path#\data_files\uploaded\billbacks\uploadAutomation\#strFileName#" 
		  destination = "#pathFileName#"
		  nameconflict="OVERWRITE">	
	
	<cfquery name="qInsUAUploadLog" datasource="#application.datasource#">
		DECLARE  @upload_id int, 
		@Upload_date datetime,
		@User_id varchar(50),
		@File_name varchar(255),
		@File_ext varchar(15),
		@UploadAutomationLogID int
		
		SET @upload_date = getdate()
		SET @User_id = '#request.AccessStructure.user_id#'
		SET @File_name = '#strFileName#'
		INSERT INTO	
		Upload_Automation_Log
		(	 
			User_ID,
			File_Name,
			File_Size,
			Upload_Date,
			Upload_Status,
			UA_Step
		)
		VALUES	
		(	 
			@User_id,
			@File_name,
			'#FileSize#',
			@Upload_date,
			1,
			'1_0'
			
		)
			
		SET @UploadAutomationLogID = (	SELECT 
											Upload_Automation_Log_ID 
										FROM 
											Upload_Automation_Log 
										WHERE User_ID = @user_id AND Upload_Status = 1 AND Upload_Date = @Upload_Date AND File_Name = @File_name AND Deleted = 0
										)
		
		
		INSERT INTO	
		Upload_Automation_Log_History
		(	 
			Upload_Automation_Log_ID,
			User_ID,
			File_Name,
			File_Size,
			Upload_Date,
			Upload_Status,
			UA_Step
		)
		VALUES	
		(	 
			@UploadAutomationLogID,
			@User_id,
			@File_name,
			'#FileSize#',
			@Upload_date,
			1,
			'1_0'
		)	
		SELECT @UploadAutomationLogID AS Upload_Automation_Log_ID
	</cfquery>	
	<cfset UploadID = qInsUAUploadLog.Upload_Automation_Log_ID />
					
<cfthread action="RUN" NAME="CallTheProcessingSP">
 	<cfstoredproc procedure = "Upload_3000_File" dataSource="#application.datasource#">
	</cfstoredproc>
</cfthread>

<cfcatch>
	<cfoutput>
		Encountered the below error:<br>
		<P>#cfcatch.message#</P>
	</cfoutput>
</cfcatch>
 
</cftry>