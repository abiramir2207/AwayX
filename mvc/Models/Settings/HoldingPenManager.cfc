<!----------------------------------------------------------------------------------
Name: 			HoldingPenManager.cfc
Copyright:		(c) 2014 Blacksmith Applications, Inc.
Created Date: 	09/24/2014
Created By:    	Anand Rao
Description:	DB edit/access for Holding Pen Data
Parameters:		N/A
Usage:			N/A
---------------------------------------------------------------------------------->

<cfcomponent name="HoldingPenManager" displayname="HoldingPenManager" hint="Manages Holding Pen settings">

	<!--- Check to see if the holding pen is locked by another user --->
	<cffunction name="checkHoldingPenLock" access="public" returntype="query" output="false" >
		<cfset var qCheckHoldingPenLock = "" />	
		<cfquery name="qCheckHoldingPenLock" datasource="#application.datasource#">
			SELECT 		ISNULL(BB_Upload_Hold_Lock.IS_LOCKED, 0) AS IS_LOCKED, 
						BB_Upload_Hold_Lock.USER_ID, 
						(NAME_FIRST + ' ' + NAME_LAST) AS LOCKER 
			FROM		BB_Upload_Hold_Lock
			LEFT JOIN	_USERS 
			ON			_USERS.USER_ID =  BB_Upload_Hold_Lock.USER_ID
			WHERE		BB_Upload_Hold_Lock.DELETED = 0
			AND			BB_Upload_Hold_Lock.IS_LOCKED = 1
			ORDER BY	IS_LOCKED DESC 
		</cfquery>
		
		<cfreturn qCheckHoldingPenLock />
	</cffunction>

	<!--- CHECK IF HOLDING PEN "GO" SP IS RUNNING --->
	<cffunction name="checkIsRunning" access="public" returntype="boolean" >
	
		<cfset var qUnlock = "" />		
		<cfquery name="qCheckIsRunning" datasource="#application.datasource#">
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
		</cfscript>

	</cffunction>	

	<cffunction name="toggleInterface" access="remote" returntype="string" returnformat="JSON">
		<cfscript>
			s= deserializejson(this.getInterfaceOn());
			if(S == 1){
				b=0;
			}
			else{
				b=1;
			}
		</cfscript>	
		<<cfset useLakebaseForqToggleInterface = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_settings")>
<cfif useLakebaseForqToggleInterface>
	<cftry>
		<cfset application.oLakebase.updateRows("_settings",
			{
				"input_name" = "eq.Interface_700_Is_On"
			},
			{
				"value" = "#b#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqToggleInterface = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqToggleInterface>
<cfquery name="qToggleInterface" datasource="#application.datasource#">
			UPDATE _Settings SET Value = '#b#' WHERE Input_Name = 'Interface_700_Is_On'
		</cfquery>
</cfif> 
		<cfset useLakebaseForqGetInterfaceOn = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_settings")>
<cfif useLakebaseForqGetInterfaceOn>
	<cftry>
		<cfset qGetInterfaceOn = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_settings", {
				"input_name" = "eq.Interface_700_Is_On",
				"select" = "value"
			}), "value"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetInterfaceOn = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetInterfaceOn>
<cfquery name="qGetInterfaceOn" datasource="#application.datasource#">
			SELECT Value
            FROM _Settings
            WHERE Input_Name = 'Interface_700_Is_On'
		</cfquery>
</cfif>
		<cfdump var='#qGetInterfaceOn#' output='c:\dump.log'>
		<cfscript>
			Return '#qGetInterfaceOn.value#';
		</cfscript>
	</cffunction>	

	<cffunction name="getInterfaceOn" access="remote" returntype="string" returnformat="JSON">	
		
		<cfquery name="qGetInterfaceOn" datasource="#application.datasource#">
			SELECT Value
            FROM _Settings
            WHERE Input_Name = 'Interface_700_Is_On'
		</cfquery> 
		<cfscript>
				Return qGetInterfaceOn.value;
		</cfscript>

	</cffunction>


	<!--- Lock the page --->
	<cffunction name="lockHoldingPenPage" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">
					
		<cfset var qLock = "" />
		<cfset var temp = this.unlockHoldingPenPage()/> <!--- unlock first others --->
			
		<cfquery name="qLock" datasource="#application.datasource#">
			INSERT INTO		BB_Upload_Hold_Lock (User_ID,Is_Locked)
			VALUES			(<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
							 <cfqueryparam value="1" cfsqltype="cf_sql_varchar">)
		</cfquery>
		
		<cfreturn true />
	</cffunction>	


	<!--- Unlock the page --->
	<cffunction name="unlockHoldingPenPage" access="public" returntype="boolean" >
	
		<cfset var qUnlock = "" />		
		<cfquery name="qUnlock" datasource="#application.datasource#">
			UPDATE		BB_Upload_Hold_Lock
			SET			Is_Locked = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
						Deleted = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
			WHERE		Is_Locked = 1
			AND			Deleted = 0 
		</cfquery>
		
		<cfreturn true />
	</cffunction>		
	
	<!--- Returns the Date for the Holding Pen page and the Download link data to be downloaded as csv --->
	<cffunction name="getHoldingPenData" access="public" returntype="query" >
		<cfargument name="BBUploadHoldScorecardID" type="string" required="false" default="">
		<cfset var qHoldingpen = "" />		
		<cfquery name="qHoldingpen" datasource="#application.datasource#">
			SELECT
				BB_Upload_Hold_Scorecard_ID,
		    	Upload_ID,
				Upload_Date,
				Source,
				Total_Invoices,
				Item_Alias_Count,
				Distributor_Alias_Count,
				Operator_Alias_Count,
				Invalid_Program_Count,
				Created_Date,
				FileName,
				Upload_Type
			FROM
				[BB_Upload_Hold_Scorecard]
			WHERE	
				Deleted = 0
				<cfif arguments.BBUploadHoldScorecardID NEQ "">
				AND BB_Upload_Hold_Scorecard_ID = '#arguments.BBUploadHoldScorecardID#'
				</cfif>
		</cfquery>

		<cfreturn qHoldingpen />
	</cffunction>				
		
	<!--- Returns the Report data for the "Report" link to be downloaded as csv --->			
	<cffunction name="getReportData" access="public" returntype="query">	
		<cfargument name="UploadID" type="string" required="false" default="">
		<cfargument name="sFullPath" type="string" required="false" default="">
		<cfargument name="sFileName" type="string" required="false" default="">
		<cfargument name="sUploadType" type="string" required="false" default="">
		<cfargument name="dUploadDate" type="string" required="false" default="">
		<cfargument name="sSourceCode" type="string" required="false" default="">
		
		<!--- <cfdump var="#arguments#" output="c:\temp.txt" /> --->
		<cfset var qReportData = "" />		
		
		<cfif arguments.UploadID EQ "">
			<cfset isNull = "Yes" />
		<cfelse>
			<cfset isNull = "No" />				
		</cfif>	
			<!--- Create the temp table to write the data from the file --->
			<cfquery name="Create_Data_Table" datasource="#application.datasource#">
			IF object_id('tempdb..##Success_Failure_Status') IS NOT NULL
				BEGIN	
	    	    	DROP TABLE ##Success_Failure_Status
				END	
				 
				CREATE TABLE ##Success_Failure_Status
				(
					[Message]  [varchar](max), 
					[Status]  [varchar](max)
				)			
			</cfquery>
			<cfif sUploadType EQ "3">
				<cfstoredproc procedure = "Upload_BB_Hold_Report" dataSource="#application.datasource#">
					<cfprocparam type="IN"  variable="@Upload_ID"	value="#arguments.UploadID#" cfsqltype="CF_SQL_INTEGER" null="#isNull#">
					<cfprocparam type="IN"  variable="@FilePath" value="#arguments.sFullPath#" cfsqltype="CF_SQL_VARCHAR" null="No">
					<cfprocparam type="IN"  variable="@FilenameExt" value="#arguments.sFileName#" cfsqltype="CF_SQL_VARCHAR" null="No">
					<cfprocresult name = "qryResult">
				</cfstoredproc>
			<cfelseif sUploadType EQ "2">
				<cfstoredproc procedure = "Upload_User_BB_Hold_Report" dataSource="#application.datasource#">
					<cfprocparam type="IN"  variable="@Upload_ID"	value="#arguments.UploadID#" cfsqltype="CF_SQL_INTEGER" null="#isNull#">
					<cfprocparam type="IN"  variable="@FilePath" value="#arguments.sFullPath#" cfsqltype="CF_SQL_VARCHAR" null="No">
					<cfprocparam type="IN"  variable="@FilenameExt" value="#arguments.sFileName#" cfsqltype="CF_SQL_VARCHAR" null="No">
					<cfprocresult name = "qryResult">
				</cfstoredproc>
			<cfelseif (sUploadType EQ "4")>
				<cfif arguments.dUploadDate EQ "">
					<cfset isDateNull = "Yes" />
				<cfelse>
					<cfset isDateNull = "No" />				
				</cfif>	
				<cfif arguments.sSourceCode EQ "">
					<cfset isCodeNull = "Yes" />
				<cfelse>
					<cfset isCodeNull = "No" />				
				</cfif>	
								
				<cfstoredproc procedure = "Upload_BB_Hold_Ignore_Report" dataSource="#application.datasource#">
					<cfprocparam type="IN"  variable="@Upload_Date"	value="#arguments.dUploadDate#" cfsqltype="CF_SQL_VARCHAR" null="#isDateNull#">
					<cfprocparam type="IN"  variable="@Source_Code"	value="#arguments.sSourceCode#" cfsqltype="CF_SQL_VARCHAR" null="#isCodeNull#">
					<cfprocparam type="IN"  variable="@FilePath" value="#arguments.sFullPath#" cfsqltype="CF_SQL_VARCHAR" null="No">
					<cfprocparam type="IN"  variable="@FilenameExt" value="#arguments.sFileName#" cfsqltype="CF_SQL_VARCHAR" null="No">
					<cfprocresult name = "qryResult">
				</cfstoredproc>
			</cfif>	
			
			<cfquery name="selSuccessFailureStatus" datasource="#application.datasource#">
				SELECT * FROM ##Success_Failure_Status 	
			</cfquery>
			
			<!--- <cfquery name="qReportData" datasource="#application.datasource#">
				SELECT 
					DISTINCT
					Upload_ID,
					Billback_Upload_III_PH_ID,
					Billback_Upload_III_PD_ID,
					FileName,
					Source,
					Claim_Number, 
					Claim_Start_Date,
					Claim_End_Date,
					Alias_Distributor,
					Alias_Distributor_Name,
					Xrefed_Shipto,
					Alias_Associated_Dist,
					Alias_Associated_Dist_Name,
					Xrefed_Associated_Shipto,
					Alias_Item,Alias_Item_Description,
					Xrefed_Item,
					Alias_Operator,
					Alias_Operator_Name,
					Xrefed_Operator,
					Alias_Program,
					Alias_Program_Name,
					Xrefed_Program,
					Program_Validation,
					Total_Claim_Dollars
				FROM  BB_Upload_Hold_Report
					<cfif arguments.UploadID NEQ "">
					WHERE Upload_ID = '#arguments.UploadID#'
					</cfif>
			</cfquery> --->
		 
		<cfreturn selSuccessFailureStatus />
	</cffunction>			

	<!--- BB without Vendor updates/Anand Rao/01-July-2015 --->
	
	<cffunction name="logUploadDownloadHistory" access="public" returntype="boolean" >
		<cfargument name="HP_Download_Upload_Type" type="string" required="true">
		<cfargument name="BBUploadHoldScorecardID" type="string" required="true">
		<cfargument name="User_ID" type="string" required="true">
							
		<cfset var qLock = "" />
		<cfset var temp = this.unlockHoldingPenPage()/> <!--- unlock first others --->
			
		<cfquery name="qUpDownLog" datasource="#application.datasource#">
			INSERT INTO		HP_Download_Upload_History 
							(
								HP_Download_Upload_Type,
							 	BB_Upload_Hold_Scorecard_ID, 
							 	Created_By, 
							 	Created_Date
							)
			VALUES			(
								<cfqueryparam value="#arguments.HP_Download_Upload_Type#" cfsqltype="CF_SQL_INTEGER">,
							 	<cfqueryparam value="#arguments.BBUploadHoldScorecardID#" cfsqltype="CF_SQL_INTEGER">,
								<cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
								getDate()
							)
		</cfquery>
		
		<cfreturn true />
	</cffunction>	
	
	<cffunction name="delHoldingPenRec" access="public" returntype="boolean" >
		<cfargument name="User_ID" type="string" required="true">
		<cfargument name="BBUploadHoldScorecardID" type="string" required="false" default="0">
		
		<cfset useLakebaseForBBScoreCardUploadID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_upload_hold_scorecard")>
<cfif useLakebaseForBBScoreCardUploadID>
	<cftry>
		<cfset BBScoreCardUploadID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_upload_hold_scorecard", {
				"bb_upload_hold_scorecard_id" = "eq.#arguments.BBUploadHoldScorecardID#",
				"deleted" = "eq.0",
				"select" = "upload_id"
			}), "upload_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBBScoreCardUploadID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBBScoreCardUploadID>
<cfquery name="BBScoreCardUploadID" datasource="#application.datasource#">
			SELECT Upload_ID
			FROM BB_Upload_Hold_Scorecard
			WHERE		BB_Upload_Hold_Scorecard_ID = #arguments.BBUploadHoldScorecardID# 
			AND			Deleted = 0  
		</cfquery>
</cfif>
		<cfquery name="updDeletedFlags" datasource="#application.datasource#">
			UPDATE 	BB_User_Upload_Hold_log
			SET			Deleted = 1,
						Updated_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
						Updated_Date = getDate()
			WHERE		Upload_ID = #BBScoreCardUploadID.Upload_ID# 
			AND			Deleted = 0 

		
			UPDATE	BB_Upload_Hold_Scorecard
			SET			Deleted = 1,
						Deleted_By = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar">,
						Deleted_Date = getDate()
			WHERE		BB_Upload_Hold_Scorecard_ID = #arguments.BBUploadHoldScorecardID# 
			AND			Deleted = 0 
		</cfquery>
		
		<cfreturn true />
	</cffunction>		

	<cffunction name="fnReportDownloadLog" access="public" returntype="any" >
		<cfargument name="BBUploadHoldScorecardID" type="string" required="false" default="0">
		
		<cfset useLakebaseForqryReportDownloadLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("hp_download_upload_history") AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqryReportDownloadLog>
	<cftry>
		<cfset qryReportDownloadLog = application.oLakebase.toQuery(
			application.oLakebase.selectRowsJoin("hp_download_upload_history", {
				"bb_upload_hold_scorecard_id" = "eq.#arguments.BBUploadHoldScorecardID#",
				"order" = "created_date.asc",
				"select" = "created_by,created_date"
			}, "created_by", "_users", "user_id", "name_first,name_last"), "created_date,name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryReportDownloadLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryReportDownloadLog>
<cfquery name="qryReportDownloadLog" datasource="#application.datasource#">
			SELECT 	HPH.Created_Date,
					U.Name_First,U.Name_Last 
			FROM 	HP_Download_Upload_History HPH 
			INNER JOIN _users U ON U.User_ID = HPH.Created_By 
			WHERE HPH.BB_Upload_Hold_Scorecard_ID = #arguments.BBUploadHoldScorecardID#
			ORDER BY HPH.Created_Date
		</cfquery>
</cfif>
		
		<cfreturn qryReportDownloadLog />
	</cffunction>
	
</cfcomponent>
	