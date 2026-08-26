<!---
  * ====================================================================================================
  *    @File:   AwayX\mvc\Models\Admin\SelfServe\SelfServeManager.cfc
  *    @Author: Anand Rao
  *    @Date:   16 Sep 2024
  *
  *    @Remarks: Self Service Manager File 
  *
  * ====================================================================================================
--->

<cfcomponent output="false" alias="mvc.Models.Admin.SelfServe.SelfServeManager">
	
	<cfset appSettings = application.appSettingsGet />

	<cffunction name="init" output="false" returntype="mvc.Models.Admin.SelfServe.SelfServeManager">
		<cfreturn this />
	</cffunction>

	<cffunction name="checkSelfServeLock" access="public" returntype="query" output="false" >

		<cfset var qCheckSelfServeLock = "" />
		<cfquery name="qCheckSelfServeLock" datasource="#application.datasource#">
			SELECT 		ISNULL(Self_Serve_Lock.IS_LOCKED, 0) AS IS_LOCKED,
						Self_Serve_Lock.USER_ID AS Locked_By_User_ID,
						(NAME_FIRST + ' ' + NAME_LAST) AS Locked_By_User_Name
			FROM		Self_Serve_Lock
			LEFT JOIN	_USERS
			ON			_USERS.USER_ID =  Self_Serve_Lock.USER_ID
			WHERE		Self_Serve_Lock.DELETED = 0
			AND			Self_Serve_Lock.IS_LOCKED = 1
			ORDER BY	IS_LOCKED DESC
		</cfquery>

		<cfreturn qCheckSelfServeLock />
	</cffunction>

	<cffunction name="getActionLookup" access="public" returntype="query" output="false" >
		<cfargument name="Self_Serve_Action_Category_Type_Lookup_ID" type="string" required="false" default="">
			<cfquery name="qGetLookupData" datasource="#application.datasource#">
				SELECT * FROM Self_Serve_Action_Category_Type_Lookup WHERE Deleted = 0 AND Active = 1
				<cfif (arguments.Self_Serve_Action_Category_Type_Lookup_ID NEQ "")>
					AND Self_Serve_Action_Category_Type_Lookup_ID = <cfqueryparam value="#arguments.Self_Serve_Action_Category_Type_Lookup_ID#" cfsqltype="cf_sql_varchar">
				</cfif>
				 ORDER BY Action_Type 
			</cfquery>
		<cfreturn qGetLookupData />

	</cffunction>

	<cffunction name="lock" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">

		<cfset var qLock = "" />
		<!--- cfset var temp = this.unlockSelfServePage()/ ---> <!--- unlock first others --->

		<cfset local.lock = checkSelfServeLock() />
		<cfset bCanLock = 1 />
		<cfif (local.lock.is_Locked EQ 1)>
			<cfset bCanLock = 0 />
		</cfif>	

		<cfif (local.lock.recordCount EQ 0)>
		<cfquery name="qLock" datasource="#application.datasource#">
			INSERT INTO		Self_Serve_Lock (User_ID,Is_Locked)
			VALUES			(<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
							 <cfqueryparam value="1" cfsqltype="cf_sql_varchar">)
		</cfquery>
		</cfif>
		<cfset local.lock = checkSelfServeLock() />
		<cfreturn (isDefined("local.lock.Locked_By_User_ID") ? local.lock.Locked_By_User_ID eq request.AccessStructure.User_ID : false)>
	</cffunction>

	<!--- Unlock the page --->
	<cffunction name="unlockSelfServePage" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">
		<cfset var qUnlock = "" />
		<cfset local.lock = checkSelfServeLock() />
		<!--- unlock only if it is locked by the current user --->
		<cfif (local.lock.recordcount NEQ 0 AND   local.lock.Locked_By_User_ID eq request.AccessStructure.User_ID)>
			<cfquery name="qUnlock" datasource="#application.datasource#">
				UPDATE		Self_Serve_Lock
				SET			Is_Locked = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
							Deleted = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
				WHERE		Is_Locked = 1
				AND			Deleted = 0
			</cfquery>
			<cfreturn true />
		<cfelse>	
			<cfreturn false />
		</cfif>
		
	</cffunction>

    
   <!--- cffunction name="getSSUploadDetail" output="false" returntype="array" access="remote" returnformat="json">
    
        <cfargument name="SelfServeLogID" required="false" type="string" default="">

        <cfquery name="qGetUploadHistory" datasource="#application.datasource#" returntype="array">
            SELECT  
            	Self_Serve_Log_ID, Self_Serve_Action_Category_Type_Lookup_ID, Action_type, Category_Type,Upload_FileName, Upload_Status,
				Action_user_ID, Action_Date,Record_Count, Error_Count, Success_Count, Process_Flag, File_Validation_Failed,u.User_Code 
			FROM Self_Serve_Log sslog
			INNER JOIN _Users u on u.user_ID = sslog.Action_user_ID
			<cfif arguments.SelfServeLogID NEQ "">
				WHERE Self_Serve_Log_ID = 1
			</cfif>
			ORDER BY Self_Serve_Log_ID
        </cfquery>
		<cfreturn  qgetSSUploadDetail />
         
	</cffunction --->

 
<cfscript>

 	remote function getUploadHistory( SelfServeLogID ) output="false" hint="Retrieve uploaded detail" returnformat="json" {
            // return data in JSON format
            cfcontent ( type="application/json" ) {
                // use short names to minimize the download size
 				param name="arguments.where_clause" default="";
 				param name="arguments.SelfServeLogID" default="";
 				if (arguments.SelfServeLogID != ""){
					arguments.where_clause = " WHERE Self_Serve_Log_ID = #arguments.SelfServeLogID#";
				}
                return queryExecute( " SELECT  
            		Self_Serve_Log_ID, Self_Serve_Action_Category_Type_Lookup_ID, Action_Type, Category_Type,Upload_FileName, Upload_Status,
				Created_By, FORMAT(Created_Date, 'MM/dd/yyyy HH:mm:ss') AS Created_Date,Record_Count, Error_Count, Success_Count, Process_Flag, File_Size, u.User_Code 
				FROM Self_Serve_Log sslog
			INNER JOIN _Users u on u.user_ID = sslog.Created_By
			
				#arguments.where_clause#
			ORDER BY Self_Serve_Log_ID ", {}, { returntype = "json/array", datasource: application.datasource } );
            }
        }
 
 	remote function getUploadByID( SelfServeLogID ) output="false" hint="" {
            // return data in JSON format
                return queryExecute( " SELECT  
            		Self_Serve_Log_ID, Self_Serve_Action_Category_Type_Lookup_ID, Action_Type, Category_Type,Upload_FileName, Upload_Status,
				Created_By, FORMAT(Created_Date, 'MM/dd/yyyy HH:mm:ss') AS Created_Date,Record_Count, Error_Count, Success_Count, Process_Flag, File_Size, u.User_Code 
				FROM Self_Serve_Log sslog
			INNER JOIN _Users u on u.user_ID = sslog.Created_By
			WHERE Self_Serve_Log_ID = #arguments.SelfServeLogID# ", { }, { datasource: application.datasource } );
        }


	remote function getLookupByID( SelfServeActionCategoryTypeLookupID ) output="false" hint="" {
            // return data in JSON format
                return queryExecute( " SELECT 
										Self_Serve_Action_Category_Type_Lookup_ID,
										Category_Type,Action_Type,
										File_Upload_Required,
										Deleted,
										Active,Created_Date,
										Failed_Report_Display_Columns,
										Failed_Report_Table_Name,
										Success_Report_Display_Columns,
										Success_Report_Table_Name
										FROM Self_Serve_Action_Category_Type_Lookup 
										WHERE Self_Serve_Action_Category_Type_Lookup_ID  = #arguments.SelfServeActionCategoryTypeLookupID# ", 
										{ }, { datasource: application.datasource } );
        }

 

	remote function getSSUploadDetail( required ssID ) output="false" hint="Retrieve uploaded detail" returnformat="json" {
            // return data in JSON format
            cfcontent ( type="application/json" ) {
                // use short names to minimize the download size
                return queryExecute( " SELECT  
											Self_Serve_BB_Update_Data_log_ID, Self_Serve_Log_ID, Billback_ID,
											BB_Code, Start_Date, End_Date, Reference_Number, BB_Status,
											Item, Operator, Distributor, Program, Component, Processed, Processed_On,
											Validation_Status
 										FROM Self_Serve_BB_Update_Data_log
                                        WHERE Self_Serve_Log_ID = #arguments.ssID# ", {}, { returntype = "json/array", datasource: application.datasource } );
            }
        }

		remote function unLockByUser( required user_id ) output="false" hint="Unlock locks based on user ID" {
			return queryExecute( " UPDATE  Self_Serve_Lock
											SET  Is_Locked = 0
												,Locked_By_User_ID = NULL
												,Locked_Date = NULL
										WHERE Locked_By_User_ID = '#arguments.user_id#' ", { }, { datasource: application.datasource } );
		}

		remote function Lock2( required user_id ) output="false" returnFormat="JSON" {
			var success = lock( user_id);
			var message = '';
			if ( success is false ) {
				message = 'The selected option is currently locked by #getStatus( user_id ).Locked_By_User_Name#.\nPlease try again later.';
			}
			return serializeJSON( { success: success, message: message } );
		}

		remote function unLockByID2( required user_id ) output="false" returnFormat="JSON" {
			return serializeJSON( { success: unlockSelfServePage( user_id ) } );
		}
	</cfscript>


</cfcomponent>	