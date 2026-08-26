<!----------------------------------------------------------------------------------
Name         :  AwayX/billbacks/Upload_Action/inc_UA_Actions.cfm
Copyright    :  (c) 2020 Blacksmith Applications, Inc.
Created Date :  19-Jun-20
Created By   :  Anand Rao
Description  :  All the actions that happen on the Actions are columns are handled here
---------------------------------------------------------------------------------->

<cfparam name="URL.doAction" default="0">
<!--- Generate HLV Report --->

<cfif URL.doAction EQ "generateHLV">

	<cfstoredproc procedure = "Upload_3000_UA_Log" dataSource="#application.datasource#">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar"	value="2_0" dbvarname="@Upload_Status">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar" value="#request.AccessStructure.user_ID#"  dbvarname="@user_ID">
	</cfstoredproc>

	<cfthread action="RUN" NAME="CallGenerateHLV">
		<cfstoredproc procedure = "Upload_3000_Generate_Update_HLV_Convert_To_III_Format" dataSource="#application.datasource#">
			<cfprocparam type="in" value="1" cfsqltype="cf_sql_bit" dbvarname="@generate_HLV">
			<cfprocparam type="in" value="0" cfsqltype="cf_sql_bit" dbvarname="@update_HLV">
			<cfprocparam type="in" value="0" cfsqltype="cf_sql_bit" dbvarname="@Validate_check_points">
		</cfstoredproc>
	</cfthread>

<cfelseif URL.doAction EQ "startProcess">

	<cfstoredproc procedure = "Upload_3000_UA_Log" dataSource="#application.datasource#">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar"	value="4_0" dbvarname="@Upload_Status">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar" value="#request.AccessStructure.user_ID#"  dbvarname="@user_ID">
	</cfstoredproc>

	<cfthread action="RUN" NAME="CallStartProcess">
		<cfstoredproc procedure = "Upload_3000_Generate_Update_HLV_Convert_To_III_Format" dataSource="#application.datasource#">
			<cfprocparam type="in" value="0" cfsqltype="cf_sql_bit" dbvarname="@generate_HLV">
			<cfprocparam type="in" value="0" cfsqltype="cf_sql_bit" dbvarname="@update_HLV">
			<cfprocparam type="in" value="1" cfsqltype="cf_sql_bit" dbvarname="@Validate_check_points">
		</cfstoredproc>
	</cfthread>

<cfelseif URL.doAction EQ "cleanupHP">

	<cfstoredproc procedure = "Upload_3000_UA_Log" dataSource="#application.datasource#">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar"	value="5_0" dbvarname="@Upload_Status">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar" value="#request.AccessStructure.user_ID#"  dbvarname="@user_ID">
	</cfstoredproc>

	<cfthread action="RUN" NAME="CallCleanHP">
		<cfstoredproc procedure = "Upload_3000_Cleanup_HoldingPen" dataSource="#application.datasource#">
		</cfstoredproc>
	</cfthread>

<cfelseif URL.doAction EQ "generateDRAFReport">

	<cfstoredproc procedure = "Upload_3000_UA_Log" dataSource="#application.datasource#">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar"	value="8_0" dbvarname="@Upload_Status">
		<cfprocparam type="in" cfsqltype = "cf_sql_varchar" value="#request.AccessStructure.user_ID#"  dbvarname="@user_ID">
	</cfstoredproc>

	<cfthread action="RUN" NAME="CallGenerateReport">
		<cfstoredproc procedure = "Generate_DR_AF_Reports" dataSource="#application.datasource#">
		</cfstoredproc>
		<!--- <cfstoredproc procedure = "Admin_Fee_Extract" dataSource="#application.datasource#">
		</cfstoredproc>
		<cfstoredproc procedure = "Distributor_Rebate_Extract" dataSource="#application.datasource#">
		</cfstoredproc> --->
	</cfthread>

<cfelseif URL.doAction EQ "deleteRec">
<cfset frmDelIdExisted = 0 />

	<cfif isDefined("FORM.deleteUploadID") AND FORM.deleteUploadID NEQ "">

		<cfset useLakebaseForqryUploadID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("upload_automation_log")>
<cfif useLakebaseForqryUploadID>
	<cftry>
		<cfset qryUploadID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("upload_automation_log", {
				"upload_automation_log_id" = "eq.#FORM.deleteUploadID#",
				"deleted" = "eq.0",
				"select" = "upload_automation_log_id,upload_status"
			}), "upload_automation_log_id,upload_status"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryUploadID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryUploadID>
<cfquery name="qryUploadID" datasource="#application.datasource#">
				SELECT Upload_Automation_Log_ID,Upload_Status FROM Upload_Automation_Log
				WHERE Upload_Automation_Log_ID = '#FORM.deleteUploadID#' AND Deleted = 0
		</cfquery>
</cfif>
		<cfif (qryUploadID.RecordCount NEQ 0 AND qryUploadID.Upload_Automation_Log_ID NEQ "" ) ><!--- //Check which one can be deleted later // AND qryUploadID.OCR_Step EQ "11" --->
			<cftry>
				<cfinvoke component="components.billback.AutomationUploadManager" method="purge_upload">
					<cfinvokeargument name="Upload_Automation_Log_ID" value="#qryUploadID.Upload_Automation_Log_ID#">
					<cfinvokeargument name="user_code" value="#request.accessstructure.user_code#">
				</cfinvoke>
			<cfcatch type="any">
				<!--- <cfmail to="developers@bigredflame.com" from="devenv@bigredflame.com" server="mail.bigredflame.com" subject="purge failed">
					#cfcatch.ExtendedInfo#<br>#cfcatch.Detail#
				</cfmail> --->
			</cfcatch>
			</cftry>
		</cfif>

		<cfset useLakebaseForqGetUAUploadID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("upload_automation_log")>
<cfif useLakebaseForqGetUAUploadID>
	<cftry>
		<cfset qGetUAUploadID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("upload_automation_log", {
				"upload_automation_log_id" = "eq.#FORM.deleteUploadID#",
				"deleted" = "eq.0",
				"select" = "upload_automation_log_id"
			}), "upload_automation_log_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetUAUploadID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetUAUploadID>
<cfquery name="qGetUAUploadID" datasource="#application.datasource#">
			SELECT Upload_Automation_Log_ID FROM Upload_Automation_Log WHERE Upload_Automation_Log_ID = '#FORM.deleteUploadID#' AND Deleted = 0
		</cfquery>
</cfif>
		<cfif qGetUAUploadID.RecordCount EQ 1 AND qGetUAUploadID.Upload_Automation_Log_ID NEQ "">
		<cfinvoke component="components.billback.AutomationUploadManager" method="purge_upload">
					<cfinvokeargument name="Upload_Automation_Log_ID" value="#qGetUAUploadID.Upload_Automation_Log_ID#">
					<cfinvokeargument name="user_code" value="#request.accessstructure.user_code#">
				</cfinvoke>
			<!--- <cfquery name="qUpdUAUploadLog" datasource="#application.datasource#">
				UPDATE
					Upload_Automation_Log
				SET
					Deleted = 1,
					Deleted_By = '#Request.AccessStructure.User_ID#',
					Deleted_Date = getDate()
				WHERE Upload_Automation_Log_ID = '#qGetUAUploadID.Upload_Automation_Log_ID#' AND Deleted = 0
			</cfquery> --->

		</cfif>
		<cfset frmDelIdExisted = 1 />
	</cfif>

</cfif>

