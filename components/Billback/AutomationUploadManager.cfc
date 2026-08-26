<!-----------------------------------------------------------------------------

FILE NAME:		Awayx/components/Billback/AutomationUploadManager.cfc
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  18-Jun-2020
Created By   :  Anand Rao
Description  :  Lock/Unlock upload automation screen
------------------------------------------------------------------------------>

<cfcomponent hint="Automation Upload Manager" extends="components.Base">


	<cffunction name="purge_upload" output="no">
		<cfargument name="Upload_Automation_Log_ID" required="true" type="Numeric">
		<cfargument name="user_code" required="true" type="String">

		<!--- <cfstoredproc datasource="#application.datasource#" procedure="purge_upload_sp">
			<cfprocparam type="IN"  variable="@upload_id"	value="#arguments.upload_id#" cfsqltype="CF_SQL_INTEGER">
			<cfprocparam type="IN"  variable="@user_code"	value="#arguments.user_code#" cfsqltype="CF_SQL_VARCHAR">
		</cfstoredproc> --->
		<cfquery name="purge_upload" datasource="#application.datasource#">
		DECLARE @File_name varchar(2000),
				@File_size float,
				@Upload_Status varchar(50),
				@UA_Step  varchar(15),
				@Update_HLV_FileName  varchar(2000),
				@Upload_Date Datetime,
				@Updated_Date Datetime, 
				@Updated_User_ID varchar(50),
				@Deleted bit,
				@Deleted_By nvarchar(100),
				@Deleted_Date Datetime,
				@Upload_Complete_Date Datetime,
				@curDate Datetime = getdate(),
				@User_ID varchar(50)
		
		UPDATE Upload_Automation_Log 
			SET Deleted = 1, 
			Deleted_By = '#request.accessstructure.user_ID#',
			Deleted_Date = @curDate
		WHERE Upload_Automation_Log_ID = #arguments.Upload_Automation_Log_ID#
		
		SELECT 
			@File_name 		= File_Name,
			@File_size 		= File_Size,
			@User_ID		= User_ID,
			@Upload_Status 	= Upload_Status,
			@UA_Step		= UA_Step,
			@Upload_Date	= Upload_Date,
			@Updated_Date	= Updated_Date,
			@Updated_User_ID = Updated_User_ID,
			@Deleted		=	Deleted,
			@Deleted_By		= Deleted_By,
			@Deleted_Date	= Deleted_Date,
			@Upload_Complete_Date = Upload_Complete_Date,
			@Update_HLV_FileName = Update_HLV_FileName
		FROM 		
		Upload_Automation_Log	
		WHERE Upload_Automation_Log_ID = #arguments.Upload_Automation_Log_ID#
		
		INSERT INTO	
		Upload_Automation_Log_History
		(	 
			Upload_Automation_Log_ID,
			User_ID,
			File_Name,
			File_Size,
			Upload_Date,
			Upload_Status,
			UA_Step,
			Deleted,
			Deleted_By,
			Deleted_Date,
			Upload_Complete_Date,
			Created_Date,
			Updated_Date,
			Update_HLV_FileName,
			Updated_User_ID
		)
		VALUES	
		(	 
			#arguments.Upload_Automation_Log_ID#,
			@User_ID,
			@File_name,
			@File_size,
			@curDate,
			@Upload_Status,
			@UA_Step,
			@Deleted,
			@Deleted_By,
			@Deleted_Date,
			@Upload_Complete_Date,
			@curDate,
			@Updated_Date ,
			@Update_HLV_FileName,
			@Updated_User_ID
		)
 		DELETE FROM Upload_Automation_Log WHERE Upload_Automation_Log_ID = #arguments.Upload_Automation_Log_ID#
		</cfquery>
		
		
		<!--- ADD THE OTHER TABLES AND THEN MOVE ALL THE QUERIES TO A SP ---> 
	</cffunction>


	<cffunction name="getUASettings" returntype="any">		
		<cfargument name="bActive" required="false" default="" />
		<cfargument name="OCRTemplateSettingsID" required="false" default="" />
		<cfargument name="BBClaimSourceXrefID" required="false" default="" />
		
		<cfquery name="qGetUASettings" datasource="#application.datasource#">
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


	
 
 
 
	
	
		<!--- Check to see if the holding pen is locked by another user 
		AutomationUpload 
		Upload_Automation_Lock
		--->
	<cffunction name="checkAutomationUploadLock" access="public" returntype="query" output="false" >
		<cfset var qCheckAutomationUploadLock = "" />	
		<cfquery name="qCheckAutomationUploadLock" datasource="#application.datasource#">
			SELECT 		ISNULL(Upload_Automation_Lock.IS_LOCKED, 0) AS IS_LOCKED, 
						Upload_Automation_Lock.USER_ID, 
						(NAME_FIRST + ' ' + NAME_LAST) AS LOCKER 
			FROM		Upload_Automation_Lock
			LEFT JOIN	_USERS 
			ON			_USERS.USER_ID =  Upload_Automation_Lock.USER_ID
			WHERE		Upload_Automation_Lock.DELETED = 0
			AND			Upload_Automation_Lock.IS_LOCKED = 1
			ORDER BY	IS_LOCKED DESC 
		</cfquery>
		
		<cfreturn qCheckAutomationUploadLock />
	</cffunction>
	
	<!--- Lock the page --->
	<cffunction name="lockAutomationUploadPage" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">
					
		<cfset var qLock = "" />
		<cfset var temp = this.unlockAutomationUploadPage()/> <!--- unlock first others --->
			
		<cfquery name="qLock" datasource="#application.datasource#">
			INSERT INTO		Upload_Automation_Lock (User_ID,Is_Locked)
			VALUES			(<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
							 <cfqueryparam value="1" cfsqltype="cf_sql_varchar">)
		</cfquery>
		
		<cfreturn true />
	</cffunction>	


	<!--- Unlock the page --->
	<cffunction name="unlockAutomationUploadPage" access="public" returntype="boolean" >
	
		<cfset var qUnlock = "" />		
		<cfquery name="qUnlock" datasource="#application.datasource#">
			UPDATE		Upload_Automation_Lock
			SET			Is_Locked = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
						Deleted = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
			WHERE		Is_Locked = 1
			AND			Deleted = 0 
		</cfquery>
		
		<cfreturn true />
	</cffunction>		
	
	<!--- CHECK IF Automation Upload "GO" SP IS RUNNING --->
	<cffunction name="checkIsRunning" access="public" returntype="boolean" >
	
		<cfset var qUnlock = "" />		
		<!--- cfquery name="qCheckIsRunning" datasource="#application.datasource#">
			declare @i int = 0
			declare @x int = 0
			exec isSP_Running 'Upload_BB_Hold_Validate',@out = @i OUTPUT;
			exec isSP_Running 'Upload_BB_Program_Matching',@out = @x OUTPUT;
			select @i AS Validate,@x AS Program_Matching
		</cfquery>
		<cfscript>
			if(qCheckIsRunning.Validate == 1 OR qCheckIsRunning.Program_Matching == 1){
				Return True;
			}
			else{
				Return False;
			}
		</cfscript --->
<cfreturn false />
	</cffunction>	

	 
</cfcomponent>
 
 
 
 