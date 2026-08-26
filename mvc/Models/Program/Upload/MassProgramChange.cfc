<cfcomponent name="MassProgramChange" hint="handles all the function call for mass program upload">

	<!--- init --->
	<cffunction name="init" output="false" returntype="mvc.Models.Program.Upload.MassProgramChange">
		<cfreturn this />
	</cffunction>

	<!--- Check if the upload is locked --->
	<cffunction name="checkLock" access="public" returntype="query" output="false" >
		
		<cfset var qCheckLock = "" />	
		<cfquery name="qCheckLock" datasource="#application.datasource#">
			SELECT 		ISNULL(MPCU_LOCK.IS_LOCKED, 0) AS IS_LOCKED, 
						MPCU_LOCK.USER_ID, 
						(NAME_FIRST + ' ' + NAME_LAST) AS LOCKER 
			FROM		MPCU_LOCK
			LEFT JOIN	_USERS 
			ON			_USERS.USER_ID =  MPCU_LOCK.USER_ID
			WHERE		MPCU_LOCK.DELETED = 0
			AND			MPCU_LOCK.IS_LOCKED = 1
			ORDER BY	IS_LOCKED DESC 
		</cfquery>
		
		<cfreturn qCheckLock />
	</cffunction>
	
	
	<!--- Lock the page --->
	<cffunction name="lockPage" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">
					
		<cfset var qLock = "" />
		<cfset var temp = this.unlockPage()/> <!--- unlock first others --->
			
		<cfquery name="qLock" datasource="#application.datasource#">
			INSERT INTO		MPCU_LOCK (USER_ID,IS_LOCKED)
			VALUES			(<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
							 <cfqueryparam value="1" cfsqltype="cf_sql_varchar">)
		</cfquery>
		
		<cfreturn true />
	</cffunction>	


	<!--- Unlock the page --->
	<cffunction name="unlockPage" access="public" returntype="boolean" >
	
		<cfset var qUnlock = "" />		
		<cfquery name="qUnlock" datasource="#application.datasource#">
			UPDATE		MPCU_LOCK
			SET			IS_LOCKED = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
						DELETED = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
			WHERE		IS_LOCKED = 1
			AND			DELETED = 0 
		</cfquery>
		
		<cfreturn true />
	</cffunction>	

	
	<!--- Check Data exists --->
	<cffunction name="getDataExists" access="remote" returntype="boolean">
		<cfset var qGetData = "" />
		<cfset var returnVar = 0 />
		
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT	COUNT(*) AS COUNTS
			FROM	MPCU_Data
		</cfquery>
				
		<!--- if count greater than 0 return true --->		
		<cfif qGetData.counts>
			<cfset returnVar = 1 />
		</cfif>
		
		<cfreturn returnVar/>
		
	</cffunction>
	
	
	<!--- Check errors exist --->
	<cffunction name="getErrors" access="remote" returntype="boolean">
		<cfset var qGetErrors = "" />
		<cfset var returnVar = 0 />
		
		<cfquery name="qGetErrors" datasource="#application.datasource#">
			SELECT	COUNT(*) AS COUNTS
			FROM	MPCU_Errors
		</cfquery>
		
		<!--- if count greater than 0 return true --->		
		<cfif qGetErrors.counts>
			<cfset returnVar = 1 />
		</cfif>
		
		<cfreturn returnVar/>
		
	</cffunction>	

	
	<!--- get records with errors from the upload table --->
	<cffunction name="getErrorRecords" access="public">

		<cfset var qGetErrorRecords = "" />
		
		<cfquery name="qGetErrorRecords" datasource="#application.datasource#" >
			SELECT	MPCU_Data_ID,
					Contract_Number,
					Contract_Title,
					Convert(varchar(10), Contract_Start_Date, 101) as Contract_Start_Date,
					Convert(varchar(10), Contract_End_Date, 101) as Contract_End_Date,
					Component_ID,
					Discount_Type,
					Item,
					Price,
					UOM,
					Volume,
					Currency,
					Notes
			FROM	MPCU_Data
			WHERE	MPCU_Data_ID IN (SELECT DISTINCT MPCU_Data_ID FROM MPCU_ERRORS)
		</cfquery>
		
		<cfreturn qGetErrorRecords />

	</cffunction>

	<!--- Check if Contract is Locked --->
	<cffunction name="checkContractLock" access="public" output="false" >
		<cfargument name="contractNumber" type="string" required="true">
		<cfset var qCheckContractLock = "" />
		<cfset var isLocked = 0 />	
		<cfquery name="qCheckContractLock" datasource="#application.datasource#">
			SELECT Contract_Is_Locked,
							Contract_Locked_By_User_ID,
							Contract_Lock_Date,
							Sent_To_External_Client,
							Contract_Main_ID
			FROM CONTRACT_MAIN CM
			WHERE CONTRACT_NUMBER = '#arguments.contractNumber#'
				and		CM.Deleted = 0
				and		CM.Manual_Cancel = 0
				and		CM.Approved = 1
				and		CM.Contract_Status_Type_IDX in (4,5,6,7)
		</cfquery>
		
		<cfif application.appSettingsGet.getProgramLockTypeID() and qCheckContractLock.recordcount >
			<cfset objProgramLockType = createObject("component", "components.programs.ProgramLockType") />
			<cfset isLocked = objProgramLockType.getProgramLockStatus(qCheckContractLock.Contract_Main_ID) />
		</cfif>

		<cfreturn isLocked />
	</cffunction>

	<!--- get records with errors from the upload table for bindable grid --->
	<cffunction name="getErrorRecordsAJAX" access="remote">
		<cfargument name="page" default="1" />
		<cfargument name="pageSize" default="20" />
		<cfargument name="sortColumn" default="MPCU_Data_ID" />
		<cfargument name="sortDirection" default="ASC" />
				
		<cfset var qGetErrorRecordsAJAX = "" />
		<cfset qGetErrorRecordsAJAX = this.GetErrorRecords()/>
		<cfreturn queryconvertforgrid(qGetErrorRecordsAJAX,arguments.page,arguments.pageSize) />

	</cffunction>
	

	<!--- get error details --->
	<cffunction name="getErrorDetails" access="remote">
		<cfargument name="errorRecordID" default="1" />
		<cfargument name="page" default="1" />
		<cfargument name="pageSize" default="10" />
		<cfargument name="sortColumn" default="ERROR_COLUMN" />
		<cfargument name="sortDirection" default="ASC" />

		<cfset var qGetErrorDetails = "" />
		<cfset var local_errorRecordID = 1/>
		<cfif len(arguments.errorRecordID) AND NOT isNull(arguments.errorRecordID) >
			<cfset local_errorRecordID = arguments.errorRecordID />
		</cfif>		

		<cfset useLakebaseForqGetErrorDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("mpcu_errors")>
<cfif useLakebaseForqGetErrorDetails>
	<cftry>
		<cfset qGetErrorDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("mpcu_errors", {
				"mpcu_data_id" = "eq.#local_errorRecordID#",
				"select" = "mpcu_data_id,error_column,error_msg"
			}), "mpcu_data_id,error_column,error_msg"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetErrorDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetErrorDetails>
<cfquery name="qGetErrorDetails" datasource="#application.datasource#" >
			SELECT	MPCU_Data_ID, ERROR_COLUMN, ERROR_MSG
			FROM		MPCU_Errors
			WHERE 	MPCU_Data_ID = #local_errorRecordID#
		</cfquery>
</cfif>
		
		<cfreturn queryconvertforgrid(qGetErrorDetails,arguments.page,arguments.pageSize) />
			
	</cffunction>


	<!--- check if there is a schedule --->
	<cffunction name="checkSchedule" access="public" returntype="boolean">
		<cfset var qCheckSchedule= "" />
		<cfset var returnVar = 0 />
		
		<cfquery name="qCheckSchedule" datasource="#application.datasource#" >
			SELECT 	COUNT(*) AS COUNTS
			FROM	MPCU_Schedule
			WHERE	Deleted = 0
			AND		Scheduled = 1
		</cfquery>
		
		<!--- if count greater than 0 return true --->
		<cfif qCheckSchedule.counts>
			<cfset returnVar = 1 />
		</cfif>
		
		<cfreturn returnVar/>
	</cffunction>


	<!--- get updateType --->
	<cffunction name="getUpdateType" access="public" returntype="string">
		<cfargument name="user_id" type="string" required="true">
		
		<cfset var qGetUpdateType = ""  />
		<cfset var updateType = ""  />
		
		<cfquery name="qGetUpdateType" datasource="#application.datasource#" >
			SELECT 	isnull(Update_Type,'') as Update_Type
			FROM	MPCU_Schedule
			WHERE 	User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
			AND		Deleted = 0
		</cfquery>
		
		<cfif qGetUpdateType.recordcount>
			<cfset updateType = qGetUpdateType.Update_Type />
		</cfif>
		
		<cfreturn updateType />
		
	</cffunction>


	<!--- set updateType --->
	<cffunction name="setUpdateType" access="public" returntype="void">
		<cfargument name="user_id" type="string" required="true">
		<cfargument name="update_type" type="string" required="true">

		<cfquery name="qDelUpdateType" datasource="#application.datasource#" >
			UPDATE 	MPCU_Schedule 
			SET 	Deleted = 1,
					Scheduled = 0
			WHERE	User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
			AND		Deleted = 0 
		</cfquery>
			
		<cfquery name="qSetUpdateType" datasource="#application.datasource#" >
			INSERT INTO	MPCU_Schedule (User_ID, Update_Type)
			VALUES 	(
						<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
						<cfqueryparam value="#arguments.update_type#" cfsqltype="cf_sql_varchar">
					)
		</cfquery>
	</cffunction>	

	
	<!--- Date: 2/23/2011 Usage: Update the grid data all at once --->
	<cffunction name="updateGridDataAll" output="false" access="remote" returntype="void">
		<cfargument	name="gridName"		type="string"	required="true">
		<cfargument	name="colNameList"	type="string"	required="true">
		<cfargument	name="formVars"		type="struct"	required="true">
		

			<cfset var action = "" />
			<cfset var looper = 0 />
			<cfset var rowID = 0 />

			<cfset var colListLen = 0 />
			<cfset var dataGridName = "" />
			<cfset var formArgs = "" />
			<cfset var gridAction = "" />

			<cfset colListLen 	= listLen(arguments.colNameList) />
			<cfset dataGridName = arguments.gridName />
			<cfset formArgs 	= arguments.formVars />
			<cfset gridAction 	= formArgs['#dataGridName#.RowStatus.Action'] />
			
			<cfloop index="i" from="1" to="#arrayLen(gridAction)#" >
				<cfset action = gridAction[i] />
				<cfset looper = 0 />
				<cfswitch expression="#action#">
					<cfcase value="U">
						<cfset rowID = formArgs['#dataGridName#.MPCU_Data_ID'][i] />
						<cfquery name="qUpdateGridData" datasource="#application.datasource#">
							Update 	MPCU_Data	Set	
								<cfloop index="j" list="#colNameList#">
									#j# = <cfqueryparam value="#formArgs['#dataGridName#.#j#'][i]#" cfsqltype="cf_sql_varchar">
									<cfset looper = looper+1 />
									<cfif looper LT colListLen>,</cfif>
								</cfloop>
							WHERE	MPCU_Data_ID = <cfqueryparam value="#rowID#" cfsqltype="cf_sql_integer">
						</cfquery>
					</cfcase>
					<cfcase value="D">
						<cfset rowID = formArgs['#dataGridName#.original.MPCU_Data_ID'][i] />
						<cfquery name="qUpdateGridData" datasource="#application.datasource#">
							Delete 	From MPCU_Data
							WHERE	MPCU_Data_ID = <cfqueryparam value="#rowID#" cfsqltype="cf_sql_integer">
						</cfquery>						
					</cfcase>
					<cfcase value="I">
						<cfset rowID = formArgs['#dataGridName#.MPCU_Data_ID'][i] />
						<cfquery name="qUpdateGridData" datasource="#application.datasource#">
							insert into	MPCU_Data 
							(
								<cfloop index="j" list="#arguments.colNameList#">
									#j#
									<cfset looper = looper+1 />
									<cfif looper LT colListLen>,</cfif>
								</cfloop>
								<cfset looper = 0 />						
							)
							values(
								<cfloop index="j" list="#arguments.colNameList#">
									<cfqueryparam value="#formArgs['#dataGridName#.#j#'][i]#" cfsqltype="cf_sql_varchar">
									<cfset looper = looper+1 />
									<cfif looper LT colListLen>,</cfif>
								</cfloop>
							)
						</cfquery>
					</cfcase>
				</cfswitch>
			</cfloop>
	</cffunction>


	<!--- execute mass update --->
	<cffunction name="executeMassUpdate" access="public" returntype="void">
		<cfargument name="user_id" type="string" required="true">
		<cfargument name="update_type" type="string" required="true">
		
		<cfset var qSetSchedule = "" />
		<cfquery name="qSetSchedule" datasource="#application.datasource#" >
			UPDATE	MPCU_Schedule
			SET		Scheduled = 1
			WHERE	User_ID = <cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">
			AND		Update_Type = <cfqueryparam value="#arguments.update_type#" cfsqltype="cf_sql_varchar">
			AND		Deleted = 0
			AND		Scheduled = 0
		</cfquery>

		<!---
			D57544: Invalid extension of the file name. Valid extensions are : log,txt. 
			Adobe limited the file types for logging  to .log or .txt for CFSchedule- File attribute from CF10. 
			"The file can only have a .txt or .log extension by default. You can add more extensions in cfusion\lib\neo-cron xml."
		--->
		<cfschedule action = "update"
			task = "#application.returned_customer_setting.Company_Name# - Mass Program Upload" 
			operation = "HTTPRequest"
			url = "http://#HTTP_HOST#/Scheduled/scheduleMassProgramChange.cfm?user_ID=#arguments.user_id#&updateType=#arguments.update_type#"
			startDate = "#DateFormat(Now(),"mm/dd/yyyy")#"
			startTime = "#TimeFormat(Now(), "short")#"
			interval = "once"
			resolveURL = "Yes"
			publish = "Yes"
			path = "#expandPath('/Scheduled/')#"
			file = "scheduleMassProgramChange.log" <!--- D57544 --->
			requestTimeOut = "600">	
				
	</cffunction>

	
	<!--- cancel mass update : delete the data --->
	<cffunction name="cancelMassUpdate" access="public" returntype="void">
	
		<cfset useLakebaseForqCancelMassUpdate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("mpcu_schedule")>
<cfif useLakebaseForqCancelMassUpdate>
	<cftry>
		<cfset application.oLakebase.updateRows("mpcu_schedule",
			{
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1",
				"scheduled" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCancelMassUpdate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCancelMassUpdate>
<cfquery name="qCancelMassUpdate" datasource="#application.datasource#">
			UPDATE 	MPCU_Schedule 
			SET 	Deleted = 1,
					Scheduled = 0
			WHERE 	Deleted = 0 
		</cfquery>
</cfif>

		<cfquery name="qEmptyMassUpdate" datasource="#application.datasource#">
			TRUNCATE TABLE MPCU_DATA
			TRUNCATE TABLE MPCU_ERRORS
		</cfquery>
		
		<cfschedule action = "delete" task = "#application.returned_customer_setting.Company_Name# - Mass Program Upload" />
	</cffunction>

	
	<!--- mass update: last user who executed --->
	<cffunction name="lastMassUpdateUser" access="public" returntype="query">
	
		<cfset var qLastMassUpdateUser = "" />
		<cfquery name="qLastMassUpdateUser" datasource="#application.datasource#" >
			SELECT 		Top 1 MPCU_SCHEDULE.USER_ID, 
						(NAME_FIRST + ' ' + NAME_LAST) AS USER_FULLNAME,
						MPCU_SCHEDULE.UPDATE_TYPE,
						MPCU_SCHEDULE.CREATED_DATE
			FROM		MPCU_SCHEDULE
			INNER JOIN	_USERS 
			ON			_USERS.USER_ID =  MPCU_SCHEDULE.USER_ID
			WHERE		MPCU_SCHEDULE.DELETED = 1
			AND 		MPCU_SCHEDULE.SCHEDULED = 1
			ORDER BY	MPCU_SCHEDULE.CREATED_DATE DESC  
		</cfquery>
		
		<cfreturn qLastMassUpdateUser />
		
	</cffunction>


	<!--- gets data for file download --->
  <cffunction name="getDataForFile" output="false" access="public" returntype="query">
		
		<cfset var qGetDataForFile = "" />
		<cfquery name="qGetDataForFile" datasource="#application.datasource#" >
				SELECT 		MPCU_Data.MPCU_Data_ID as Row_ID,
							Contract_Number,
							Contract_Title,
							Contract_Start_Date,
							Contract_End_Date,
							Component_ID,
							Discount_Type,
							Item,
							Price,
							UOM,
							Volume,
							Currency,
							Notes,
							ISNULL(LEFT(Errors.Error_Msg,Len(Errors.Error_Msg)-1), '') AS Error_Msg
				FROM		(SELECT DISTINCT ME2.MPCU_Data_ID, 
							   (SELECT ME1.Error_Msg + ';  ' AS [text()]
								FROM MPCU_ERRORS ME1
								WHERE ME1.MPCU_Data_ID = ME2.MPCU_Data_ID
								ORDER BY ME1.MPCU_Data_ID
								FOR XML PATH ('')) Error_Msg
							FROM MPCU_ERRORS ME2) Errors
				RIGHT JOIN 	MPCU_Data 
				ON 			MPCU_Data.MPCU_Data_ID = Errors.MPCU_Data_ID
				ORDER BY	MPCU_Data.MPCU_Data_ID 
		</cfquery>
		
		<cfreturn qGetDataForFile />
		
	</cffunction>
	
	<!--- Insert data from .xls file --->
	<cffunction name="insertFileData" access="public" returntype="void">
		<cfset var qLastMassUpdateUser = "" />
		<cfquery name="qInsertFile" datasource="#application.datasource#">
				INSERT INTO MPCU_Data (COMPONENT_ID,
								CONTRACT_END_DATE,
								CONTRACT_NUMBER,
								CONTRACT_START_DATE,
								CONTRACT_TITLE,
								CURRENCY,
								DISCOUNT_TYPE,
								ITEM,
								NOTES,
								PRICE,
								UOM,
								VOLUME )
				VALUES (<cfqueryParam value="#arguments.COMPONENT_ID#" />,
						<cfqueryParam value="#arguments.CONTRACT_END_DATE#" />,
						<cfqueryParam value="#arguments.CONTRACT_NUMBER#" />,
						<cfqueryParam value="#arguments.CONTRACT_START_DATE#" />,
						<cfqueryParam value="#arguments.CONTRACT_TITLE#" />,
						<cfqueryParam value="#arguments.CURRENCY#" />,
						<cfqueryParam value="#arguments.DISCOUNT_TYPE#" />,
						<cfqueryParam value="#arguments.ITEM#" />,
						<cfqueryParam value="#arguments.NOTES#" />,
						<cfqueryParam value="#arguments.PRICE#" />,
						<cfqueryParam value="#arguments.UOM#" />,
						<cfqueryParam value="#arguments.VOLUME#" />)
			</cfquery>
	</cffunction>
	
	<!--- clear lock --->
	<cffunction name="clearLock" access="public" returntype="void">
		
		<cfquery name="qResetUploadLock" datasource="#application.datasource#">
			UPDATE		MPCU_LOCK
			SET			IS_LOCKED = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
						DELETED = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
			WHERE		IS_LOCKED = 1
			AND			DELETED = 0 
		</cfquery>
	</cffunction>
	
	<!--- processEnd:  final step of process to release locks etc. --->
	<cffunction name="processEnd" access="public" returntype="void">
		
		<!--- copy the upload data into Log table --->
		<cfset this.logData() />
		<!--- truncate the upload data table --->
		<!--- truncate the error detail table --->
		<cfset this.clearData() />
		
		<!--- reset the lock for the upload utility --->
		<cfset this.clearLock() />
		
		<!--- remove the scheduled flag --->
		<cfset this.clearSchedule() />
	</cffunction>

	<!--- clear Schedule --->
	<cffunction name="clearSchedule" access="public" returntype="void">
		
		<cfset useLakebaseForqqResetUploadSchedule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("mpcu_schedule")>
<cfif useLakebaseForqqResetUploadSchedule>
	<cftry>
		<cfset application.oLakebase.updateRows("mpcu_schedule",
			{
				"deleted" = "eq.0"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqqResetUploadSchedule = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqqResetUploadSchedule>
<cfquery name="qqResetUploadSchedule" datasource="#application.datasource#">
			UPDATE 	MPCU_Schedule
			SET		Deleted = 1
			WHERE	Deleted = 0
		</cfquery>
</cfif>
	</cffunction>
	
	<!--- clear Data --->
	<cffunction name="clearData" access="public" returntype="void">
		
		<cfquery name="qEmptyUploadData" datasource="#application.datasource#">
		 	IF OBJECT_ID('MPCU_Data') IS NOT NULL
			TRUNCATE TABLE MPCU_Data
		</cfquery>
		
		<cfquery name="qEmptyUploadErrors" datasource="#application.datasource#">
		  	IF OBJECT_ID('MPCU_Errors') IS NOT NULL
			TRUNCATE TABLE MPCU_Errors
		</cfquery>
		
	</cffunction>
	
	<!--- log Data --->
	<cffunction name="logData" access="public" returntype="void">
		
		<cfquery name="qCopyUploadLog" datasource="#application.datasource#">
	
			DECLARE @Max_Upload_ID INT
			
			SELECT	@Max_Upload_ID = (ISNULL(MAX(MPCU_Data_Upload_ID),0) + 1)
			FROM	MPCU_Data_Log
			
			INSERT INTO MPCU_Data_Log
				(
					MPCU_Data_Upload_ID, MPCU_Data_ID, Contract_Number, Contract_Title,
					Contract_Start_Date, Contract_End_Date, 
					Component_ID, Discount_Type, Item, 
					Price, UOM, Volume, Currency, Notes
				)
			SELECT	@Max_Upload_ID,
					MPCU_Data_ID,
					Contract_Number,
					Contract_Title,
					Contract_Start_Date,
					Contract_End_Date,
					Component_Id,
					Discount_Type,
					Item,
					Price,
					Uom,
					Volume,
					Currency,
					Notes
			FROM	MPCU_Data
			
		</cfquery>
		
	</cffunction>
</cfcomponent>