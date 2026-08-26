<cffunction name="GetGDW4Info" access="public" returntype="query">
<cfset useLakebaseForqGetGDW4Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("type_code_desc")>
<cfif useLakebaseForqGetGDW4Info>
	<cftry>
		<cfset qGetGDW4Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("type_code_desc", {
				"deleted" = "eq.0",
				"order" = "type_code_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetGDW4Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetGDW4Info>
<CFQUERY NAME="qGetGDW4Info" datasource="#application.datasource#">
	SELECT * from
	Type_Code_Desc
	where deleted = 0
	ORDER BY Type_Code_Desc
</CFQUERY>
</cfif>
<cfreturn qGetGDW4Info />
</cffunction>

<cffunction name="GetItemInfo" access="public" returntype="query">
<cfargument name="item_number" type="string" required="false" default="">
<CFQUERY NAME="qGetItemInfo" datasource="#application.datasource#">
	SELECT * from
	ITEM_MARGIN_TARGETS
	where
	Deleted = 0
	<cfif arguments.item_number NEQ "">
	and item_number like '%#arguments.item_number#%'
	</cfif>
	ORDER BY ITEM_NUMBER
</CFQUERY>
<cfreturn qGetItemInfo />
</cffunction>

<cffunction name="AnyAliveProcess" access="public" returntype="query">
<cfargument name="filetype" type="numeric" required="true" default="">

<CFQUERY NAME="qAnyAliveProcess" DATASOURCE="#Application.Datasource#">
			SELECT *
			FROM Generic_Files_Upload
			WHERE 
			Generic_Files_Upload_Process_Status_ID < 5 
			AND Generic_Files_Upload_Process_Status_ID <> 3 
			AND Generic_File_Type = #arguments.filetype#	
			AND Deleted = 0
</CFQUERY>
<cfreturn qAnyAliveProcess />
</cffunction>

<cffunction name="getCurrentActiveProcess" access="public" returntype="query">
<cfargument name="filetype" type="numeric" required="true" default="">

<CFQUERY NAME="qgetCurrentActiveProcess" DATASOURCE="#Application.Datasource#">
			SELECT Generic_Files_Upload.*,Uploaded_By,_Users.Name_First,
			_Users.Name_Last 
			FROM Generic_Files_Upload
			LEFT JOIN _Users ON _Users.User_ID = 	
			Generic_Files_Upload.Uploaded_By AND _Users.Deleted = 0
			WHERE 
			Generic_Files_Upload_ID = (SELECT MAX(Generic_Files_Upload_ID) FROM Generic_Files_Upload 
				where (Generic_Files_Upload_Process_Status_ID = 5 OR Generic_Files_Upload_Process_Status_ID = 3) AND Generic_File_Type = #arguments.filetype#)
</CFQUERY>
<cfreturn qgetCurrentActiveProcess />
</cffunction>

<cffunction name="AnyErrors" access="public" returntype="query">
<cfargument name="filetype" type="numeric" required="true" default="">
<cfargument name="Generic_Files_Upload_ID" type="numeric" required="true" default="">
<cfargument name="upload_details" type="numeric" required="false" default="0">

<CFQUERY NAME="qAnyErrors" DATASOURCE="#Application.Datasource#">
			SELECT  Generic_Files_Upload_Log.*,Uploaded_By,_Users.Name_First,_Users.Name_Last 
FROM Generic_Files_Upload_Log LEFT JOIN	Generic_Files_Upload ON 	
				Generic_Files_Upload.Generic_Files_Upload_ID =
				Generic_Files_Upload_Log.Generic_Files_Upload_ID
				LEFT JOIN _Users ON _Users.User_ID = 	
				Generic_Files_Upload.Uploaded_By AND _Users.Deleted = 0
				WHERE 
				Generic_Files_Upload_Type = #arguments.filetype#	
				--AND Generic_Files_Upload.Deleted = 0
				--AND Generic_Files_Upload_Log.Deleted = 0
				AND Generic_Files_Upload_Log.Generic_Files_Upload_ID = #arguments.Generic_Files_Upload_ID#	
				<cfif arguments.upload_details EQ 1>
				and Generic_Files_Upload_Log.GDWL4_Margin_Target_temp_id is not null
				</cfif>
</CFQUERY>
<cfreturn qAnyErrors />
</cffunction>

<cffunction name="FileFormatErrors" access="public" returntype="query">
<cfargument name="filetype" type="numeric" required="true" default="">

<CFQUERY NAME="qFileFormatErrors" DATASOURCE="#Application.Datasource#">
			SELECT  Generic_Files_Upload_Log.*,Uploaded_By,_Users.Name_First,_Users.Name_Last 
FROM Generic_Files_Upload_Log LEFT JOIN	Generic_Files_Upload ON 	
				Generic_Files_Upload.Generic_Files_Upload_ID =
				Generic_Files_Upload_Log.Generic_Files_Upload_ID
				LEFT JOIN _Users ON _Users.User_ID = 	
				Generic_Files_Upload.Uploaded_By AND _Users.Deleted = 0
				WHERE 
				Generic_Files_Upload_Type = #arguments.filetype#	
				AND Generic_Files_Upload.Deleted = 0
				AND Generic_Files_Upload_Log.Deleted = 0
			AND GDWL4_Margin_Target_Temp_Id IS NULL
</CFQUERY>
<cfreturn qFileFormatErrors />
</cffunction>

<cffunction name="ItemsNotFound" access="public" returntype="query">
<cfargument name="filetype" type="numeric" required="true" default="">
<cfargument name="Generic_Files_Upload_ID" type="numeric" required="true" default="">

<CFIF arguments.filetype EQ 2>
<CFQUERY NAME="qItemsNotFound" DATASOURCE="#Application.Datasource#">	
		SELECT ITEM_MARGIN_TARGETS_VALID_TEMP.*,Uploaded_By,_Users.Name_First,
				_Users.Name_Last
		FROM ITEM_MARGIN_TARGETS_VALID_TEMP
		LEFT JOIN	Generic_Files_Upload ON 	
		Generic_Files_Upload.Generic_Files_Upload_ID =
		ITEM_MARGIN_TARGETS_VALID_TEMP.Generic_Files_Upload_ID
		LEFT JOIN _Users ON _Users.User_ID = 	
		Generic_Files_Upload.Uploaded_By AND _Users.Deleted = 0
		where Generic_File_type = 2	
		AND Generic_Files_Upload.Generic_Files_Upload_ID = #arguments.Generic_Files_Upload_ID#
		AND
		(NOT EXISTS(select BSA_Foodservice_Items_Master.item from 			
				BSA_Foodservice_Items_Master
				where BSA_Foodservice_Items_Master.item = 		
				ITEM_MARGIN_TARGETS_VALID_TEMP.ITEM_NUMBER))
</CFQUERY>
<CFELSEIF arguments.filetype EQ 1>
	<CFQUERY NAME="qItemsNotFound" DATASOURCE="#Application.Datasource#">		
		SELECT GDWL4_Margin_Targets_Valid_Temp.*,Uploaded_By,_Users.Name_First,
				_Users.Name_Last
		FROM GDWL4_Margin_Targets_Valid_Temp
		LEFT JOIN	Generic_Files_Upload ON 	
		Generic_Files_Upload.Generic_Files_Upload_ID =
		GDWL4_Margin_Targets_Valid_Temp.Generic_Files_Upload_ID
		LEFT JOIN _Users ON _Users.User_ID = 	
		Generic_Files_Upload.Uploaded_By AND _Users.Deleted = 0
		where Generic_File_type = 1	
		AND Generic_Files_Upload.Generic_Files_Upload_ID = 
		#arguments.Generic_Files_Upload_ID# 
			AND
		(NOT EXISTS(select Type_Code_Desc.Type_Code_Legacy from Type_Code_Desc
			where Type_Code_Desc.Type_Code_Legacy =
				 GDWL4_Margin_Targets_Valid_Temp.GDWL4_ID))
</CFQUERY>
</CFIF>
<cfreturn qItemsNotFound />
</cffunction>

<cffunction name="GetLogDetails" access="public" returntype="query">
<cfargument name="Generic_Files_Upload_Log_ID" type="string" required="true" default="">
<cfset useLakebaseForqGetLogDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("generic_files_upload_log")>
<cfif useLakebaseForqGetLogDetails>
	<cftry>
		<cfset qGetLogDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("generic_files_upload_log", {
				"generic_files_upload_log_id" = "eq.#arguments.Generic_Files_Upload_Log_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLogDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLogDetails>
<CFQUERY NAME="qGetLogDetails" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Generic_Files_Upload_Log WHERE Generic_Files_Upload_Log_ID = '#arguments.Generic_Files_Upload_Log_ID#'
</CFQUERY>
</cfif>
<cfreturn qGetLogDetails />
</cffunction>

<cffunction name="GetItemNotfoundDetails" access="public" returntype="query">
<cfargument name="Margin_Target_Temp_Valid_Id" type="numeric" required="true" default="">
<cfargument name="filetype" type="numeric" required="true" default="">
<CFIF arguments.filetype EQ 1>
	<cfset useLakebaseForqGetItemNotfoundDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gdwl4_margin_targets_valid_temp")>
<cfif useLakebaseForqGetItemNotfoundDetails>
	<cftry>
		<cfset qGetItemNotfoundDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gdwl4_margin_targets_valid_temp", {
				"gdwl4_margin_target_temp_valid_id" = "eq.#arguments.Margin_Target_Temp_Valid_Id#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetItemNotfoundDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetItemNotfoundDetails>
<CFQUERY NAME="qGetItemNotfoundDetails" DATASOURCE="#Application.Datasource#">
		select * from GDWL4_Margin_Targets_Valid_Temp
		where GDWL4_Margin_Target_Temp_Valid_Id = #arguments.Margin_Target_Temp_Valid_Id#
	</CFQUERY>
</cfif>
<CFELSEIF arguments.filetype EQ 2>
	<CFQUERY NAME="qGetItemNotfoundDetails" DATASOURCE="#Application.Datasource#">
		select * from ITEM_MARGIN_TARGETS_VALID_TEMP
		where Item_Margin_Target_VALID_TEMP_Id = #arguments.Margin_Target_Temp_Valid_Id#
	</CFQUERY>
</CFIF>
<cfreturn qGetItemNotfoundDetails />
</cffunction>

<cffunction name="CheckProcessStatus" access="public" returntype="query">
<cfargument name="filetype" type="numeric" required="true" default="">
	<CFQUERY NAME="qCheckProcessStatus" DATASOURCE="#Application.Datasource#">
		SELECT 	Generic_Files_Upload_Process_Status_ID,
				Generic_Files_Upload_ID
		FROM 	Generic_Files_Upload
		WHERE 	Generic_Files_Upload_ID = ( SELECT MAX(Generic_Files_Upload_ID) FROM Generic_Files_Upload ) AND 
				Generic_File_type = #arguments.filetype#	
				AND
				Deleted = 0 
	</CFQUERY>
	<cfreturn qCheckProcessStatus />
</cffunction>

<cffunction name="CheckForLog" access="public" returntype="query">
<cfargument name="Generic_Files_Upload_ID" type="numeric" required="true" default="">
	<cfset useLakebaseForqCheckForLog = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("generic_files_upload_log")>
<cfif useLakebaseForqCheckForLog>
	<cftry>
		<cfset qCheckForLog = application.oLakebase.toQuery(
			application.oLakebase.selectRows("generic_files_upload_log", {
				"generic_files_upload_id" = "eq.#arguments.Generic_Files_Upload_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckForLog = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckForLog>
<CFQUERY NAME="qCheckForLog" DATASOURCE="#Application.Datasource#">
			SELECT 	* 
			FROM 	Generic_Files_Upload_Log 
			WHERE 	Generic_Files_Upload_ID = #arguments.Generic_Files_Upload_ID# AND
					Deleted = 0
		</CFQUERY>
</cfif>
	<cfreturn qCheckForLog />
</cffunction>

<cffunction name="updatedefaultitemsettings" access="public" output="false">
<cfargument name="default_item_margin_target_fob" type="string" required="true" default="">
<cfargument name="default_item_margin_target_del" type="string" required="true" default="">
<cfargument name="default_item_delivery_type" type="string" required="true" default="">
<cfargument name="default_FOB_Price" type="string" required="true" default="">
<cfargument name="default_Del_Price" type="string" required="true" default="">
<cfargument name="default_FOB_Cash" type="string" required="true" default="">
<cfargument name="default_Del_Cash" type="string" required="true" default="">
	<CFQUERY NAME="qupdatedefaultitemsettings" DATASOURCE="#Application.Datasource#">
			UPDATE general_settings
			SET default_item_margin_target_fob = '#arguments.default_item_margin_target_fob#',
			default_item_margin_target_del = '#arguments.default_item_margin_target_del#',
			default_item_delivery_type = '#arguments.default_item_delivery_type#',
			default_FOB_Price = '#arguments.default_FOB_Price#',
			default_Del_Price = '#arguments.default_Del_Price#',
			default_FOB_Cash_Discount  = '#arguments.default_FOB_Cash#',
			default_Del_Cash_Discount  = '#arguments.default_Del_Cash#'
		</CFQUERY>
</cffunction>
<cffunction name="updatedefaultGDW4settings" access="public" output="false">
<cfargument name="default_item_margin_target" type="string" required="true" default="">
	<CFQUERY NAME="qupdatedefaultGDW4settings" DATASOURCE="#Application.Datasource#">
			UPDATE general_settings
			SET default_GDW4_margin_target = '#arguments.default_item_margin_target#'
		</CFQUERY>
</cffunction>

<cffunction name="getdefaultitemsettings" access="public" output="false">
<cfset useLakebaseForqgetdefaultitemsettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForqgetdefaultitemsettings>
	<cftry>
		<cfset qgetdefaultitemsettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "default_item_margin_target_fob,default_item_margin_target_del,default_item_delivery_type,default_fob_price,default_del_price,default_fob_cash_discount,default_del_cash_discount"
			}), "default_item_margin_target_fob,default_item_margin_target_del,default_item_delivery_type,default_fob_price,default_del_price,default_fob_cash_discount,default_del_cash_discount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetdefaultitemsettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetdefaultitemsettings>
<CFQUERY NAME="qgetdefaultitemsettings" DATASOURCE="#Application.Datasource#">
			SELECT default_item_margin_target_fob,default_item_margin_target_del,default_item_delivery_type,
			default_FOB_Price, default_Del_Price, default_FOB_Cash_Discount,
			default_Del_Cash_Discount
			from
			general_settings
</CFQUERY>
</cfif>
	<cfreturn qgetdefaultitemsettings />
</cffunction>

<cffunction name="getdefaultGDW4settings" access="public" output="false">
<cfset useLakebaseForqgetdefaultGDW4settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForqgetdefaultGDW4settings>
	<cftry>
		<cfset qgetdefaultGDW4settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "default_gdw4_margin_target"
			}), "default_gdw4_margin_target"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetdefaultGDW4settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetdefaultGDW4settings>
<CFQUERY NAME="qgetdefaultGDW4settings" DATASOURCE="#Application.Datasource#">
			SELECT default_GDW4_margin_target
			from
			general_settings
</CFQUERY>
</cfif>
	<cfreturn qgetdefaultGDW4settings />
</cffunction>

<cffunction name="resetUpload" access="public" output="false">
<cfargument name="Generic_Files_Upload_ID" type="numeric" required="true" default="">
<cfset useLakebaseForqresetUpload = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("generic_files_upload")>
<cfif useLakebaseForqresetUpload>
	<cftry>
		<cfset application.oLakebase.updateRows("generic_files_upload",
			{
				"generic_files_upload_id" = "eq.#arguments.Generic_Files_Upload_ID#"
			},
			{
				"deleted" = "1",
				"generic_files_upload_process_status_id" = "3"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqresetUpload = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqresetUpload>
<CFQUERY NAME="qresetUpload" DATASOURCE="#Application.Datasource#">
			update Generic_Files_Upload
			set deleted = 1,
			Generic_Files_Upload_Process_Status_ID = 3
			where Generic_Files_Upload_ID = #arguments.Generic_Files_Upload_ID#
</CFQUERY>
</cfif>
</cffunction>


<cffunction name="getlastsuccessfuluploaddetails" access="public" returntype="query">
<cfargument name="filetype" type="numeric" required="true" default="">

<CFQUERY NAME="qgetlastsuccessfuluploaddetails" DATASOURCE="#Application.Datasource#">
			SELECT Generic_Files_Upload.*,Uploaded_By,_Users.Name_First,
			_Users.Name_Last 
			FROM Generic_Files_Upload
			LEFT JOIN _Users ON _Users.User_ID = 	
			Generic_Files_Upload.Uploaded_By AND _Users.Deleted = 0
			WHERE 
			Generic_Files_Upload_ID = (SELECT MAX(Generic_Files_Upload_ID) FROM Generic_Files_Upload 
				where (Generic_Files_Upload_Process_Status_ID = 5) AND Generic_File_Type = #arguments.filetype#)
</CFQUERY>
<cfreturn qgetlastsuccessfuluploaddetails />
</cffunction>

<cffunction name="getvalidgdw4fromupload" access="public" returntype="query">
<CFQUERY NAME="qgetvalidgdw4fromupload" DATASOURCE="#Application.Datasource#">
			SELECT count(*) as validgdw4count from 
			GDWL4_Margin_Targets_Valid_Temp
			inner join type_code_desc on
			Type_Code_Desc.Type_Code_Legacy = GDWL4_Margin_Targets_Valid_Temp.GDWL4_ID
			and Type_Code_Desc.deleted = 0
</CFQUERY>
<cfreturn qgetvalidgdw4fromupload />
</cffunction>

<cffunction name="getinvalidgdw4fromupload" access="public" returntype="query">
<CFQUERY NAME="qgetinvalidgdw4fromupload" DATASOURCE="#Application.Datasource#">
			SELECT count(*) as invalidgdw4count from 
			GDWL4_Margin_Targets_Valid_Temp
			where GDWL4_ID NOT IN (select Type_Code_Legacy from Type_Code_Desc where deleted = 0)
</CFQUERY>
<cfreturn qgetinvalidgdw4fromupload />
</cffunction>

<cffunction name="getgdw4notfromupload" access="public" returntype="query">
<CFQUERY NAME="qgetgdw4notfromupload" DATASOURCE="#Application.Datasource#">
			SELECT * from 
			type_code_desc where Type_Code_Legacy NOT IN
			(select GDWL4_ID from GDWL4_Margin_Targets_Valid_Temp)
			and deleted = 0
</CFQUERY>
<cfreturn qgetgdw4notfromupload />
</cffunction>


<cffunction name="getvaliditemfromupload" access="public" returntype="query">
<CFQUERY NAME="qgetvaliditemfromupload" DATASOURCE="#Application.Datasource#">
			SELECT count(*) as validitemcount from 
			Item_Margin_Targets_Valid_Temp
			inner join Item_Margin_Targets on
			Item_Margin_Targets.item_number = Item_Margin_Targets_Valid_Temp.item_number
</CFQUERY>
<cfreturn qgetvaliditemfromupload />
</cffunction>

<cffunction name="getinvaliditemfromupload" access="public" returntype="query">
<CFQUERY NAME="qgetinvaliditemfromupload" DATASOURCE="#Application.Datasource#">
			SELECT count(*) as invaliditemcount from 
			Item_Margin_Targets_Valid_Temp
			where item_number NOT IN (select item_number from Item_Margin_Targets)
</CFQUERY>
<cfreturn qgetinvaliditemfromupload />
</cffunction>

<cffunction name="getitemnotfromupload" access="public" returntype="query">
<CFQUERY NAME="qgetitemnotfromupload" DATASOURCE="#Application.Datasource#">
			SELECT * from 
			Item_Margin_Targets where item_number NOT IN
			(select item_number from Item_Margin_Targets_Valid_Temp)
</CFQUERY>
<cfreturn qgetitemnotfromupload />
</cffunction>

