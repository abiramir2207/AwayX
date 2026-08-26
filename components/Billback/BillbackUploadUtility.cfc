<!---
       Name:          BillbackUploadUtility.cfc
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.
       Created Date:  3/30/2007
       Created By:    cmorse
       Label:	      11367
       Description:   Contains all of the data access queries for the billback upload process.
--->

<cfcomponent  displayname="BillbackUploadUtilityFunctions" hint="Billback Upload Utility Functions">

	<cffunction name="init" description="Returns instance of the utility.cfc" returntype="components.billback.billbackuploadutility">
		<cfreturn this />
	</cffunction>

	<!--- Todo: Temp code to simulate getting data from db --->
	<cffunction name="getErrorCodes" returntype="any">
		<cfquery name="tempQry" datasource="#application.datasource#">
			select 		error_id,
						error_code,
				   		error_Desc,
				   		error_Valid_Rules,
						cast(replace(replace(substring(error_code, 2, 2),'k', ''), '-', '') as int) as err
			from 		bb_upload_error_codes
			where		deleted = 0
			order by 	error_type, substring(error_code, 1, 1), err, error_id ASC
		</cfquery>
		<cfreturn tempQry />
	</cffunction>

	<!--- Todo: Upload History --->
	<cffunction name="getHistoricUploadLog" returntype="any">
		<CFARGUMENT NAME="m" DEFAULT="#datepart("m",now())#">
		<CFARGUMENT NAME="y" DEFAULT="#datepart("yyyy",now())#">
		<CFARGUMENT NAME="searchForm" DEFAULT="">
		
		<!--- get max month and year from log --->
		<cfquery name="qUniqueMonthDay" datasource="#application.datasource#">
			SELECT top 1
				CAST(YEAR(upload_date) AS Varchar(4)) + ' ' +
				DATENAME(MONTH,upload_date) AS ComboText,
				YEAR(upload_date) AS ComboYear,
				MONTH(upload_date) AS ComboMonth
			FROM
				bb_upload_log
			WHERE upload_date >= (DateAdd(m,- 24,GetDate()))
			GROUP BY
				YEAR(upload_date),
				DATENAME(MONTH,upload_date),
				MONTH(upload_date)
			ORDER BY YEAR(upload_date) DESC,
					MONTH(upload_date) DESC,
					DATENAME(MONTH,upload_date)
		</cfquery>
		<!--- If the max dates are less than the args, we know that the args are using the default, so reset them.
		when a user selects a date the drop downs will not have a valuee outside of the range of dates present in the log --->
		<cfif ARGUMENTS.m GT qUniqueMonthDay.ComboMonth AND ARGUMENTS.y GTE qUniqueMonthDay.ComboYear>
			<cfset ARGUMENTS.m = qUniqueMonthDay.ComboMonth>
			<cfset ARGUMENTS.y = qUniqueMonthDay.ComboYear>
		</cfif>
		
		<cfif structKeyExists(arguments.searchForm, "payable_list")>    <!--- 50885 --->
            <!--- payable list exists :: remove carriage returns & line feeds, then split entries into an array --->
            <cfset local.payable_numbers = listToArray( replace(arguments.searchForm.payable_list, chr(13) & chr(10), " ", "all"), " " )>
        </cfif>
		<cfif structKeyExists(arguments.searchForm, "Reference_Number_list")>    <!--- 50885 --->
            <!--- payable list exists :: remove carriage returns & line feeds, then split entries into an array --->
            <cfset local.reference_numbers = listToArray( replace(arguments.searchForm.Reference_Number_list, chr(13) & chr(10), " ", "all"), " " )>
        </cfif>
		
		<cfquery name="qGetHistoricUploadLog" datasource="#application.datasource#">
			select Distinct bb_upload_log.upload_id,
				   bb_upload_log.user_id,
				   bb_upload_log.total_header_count,
				   bb_upload_log.total_header_count_failed,
				   bb_upload_log.total_header_count_loaded,
				   bb_upload_log.total_detail_count,
				   bb_upload_log.total_detail_count_failed,
				   bb_upload_log.total_detail_count_loaded,
				   bb_upload_log.upload_date,
				  /*  bb_upload_log.upload_status, */
				 CASE WHEN BB_Upload_Log.upload_status = 'Creation Complete' /*  (upload Type = 2,3) */
                              THEN CASE WHEN (SELECT COUNT(*)
                                    FROM BB_User_Upload_Hold_log BUHEC WHERE BUHEC.upload_id = BB_Upload_Log.upload_id AND BUHEC.Deleted = 0
                                                          )>0 THEN 'Creation Complete - Partial' /*  only for upload_type =2 (Nightly) */
                                                ELSE BB_Upload_Log.upload_status
                                        END
                               WHEN BB_Upload_Log.upload_status <> 'Creation Complete' AND BB_Upload_Log.upload_type = 3 AND -- (upload Type =3)
                                                      BB_upload_log.total_detail_count_loaded <> 0 AND BB_Upload_Log.total_header_count_loaded <>0 
                                                       AND BB_Upload_Log.total_header_count_failed <> BB_Upload_Log.total_header_count_loaded
                                                      THEN  'Creation Complete - Partial'                                                        
                               ELSE BB_Upload_Log.upload_status
                      END   as upload_status,
           		bb_upload_log.upload_type AS Upload_Type_ID,
				   CASE
						bb_upload_log.upload_type
					WHEN 2
						THEN 'Application'
					ELSE
						'3rd Party'
					END
						As upload_type,
				   bb_upload_log.deleted,
				   bb_upload_log.deleted_by,
				   bb_upload_log.deleted_date,
				   CASE
				   WHEN header_file_name IS NOT NULL THEN
				   /* right(header_file_name,(charindex('\',reverse(header_file_name))) - 1) */
				   right(header_file_name,CASE WHEN (charindex('\',reverse(header_file_name))) = 0 THEN LEN(header_file_name) ELSE (charindex('\',reverse(header_file_name))) - 1 END)
				   ELSE
				   ''
				   END
				    AS "header_file_name",
				   CASE
				   WHEN Detail_file_name IS NOT NULL THEN
				   /* right(detail_file_name,(charindex('\',reverse(detail_file_name))) - 1) */
				   right(detail_file_name,CASE WHEN (charindex('\',reverse(detail_file_name))) = 0 THEN LEN(detail_file_name) ELSE (charindex('\',reverse(detail_file_name))) - 1 END)
				   ELSE
				   ''
				   END
				    AS "detail_file_name",
				   isnull(_users.user_code,'&nbsp;') AS user_code
			from bb_upload_log WITH (NOLOCK)
			left join _users on bb_upload_log.user_id = _users.user_id
			
			LEFT JOIN Billback_txt_upload_header_log ON Billback_txt_upload_header_log.Upload_ID  = bb_upload_log.Upload_ID 
			LEFT JOIN Billback ON Billback.Billback_ID  = Billback_txt_upload_header_log.BIllback_ID
			<cfif arguments.searchForm.Vendor_ID NEQ ''>
				LEFT JOIN Billback_Distributor bd on Billback.billback_id = bd.billback_id
				LEFT JOIN Billback_Operator bo on Billback.billback_id = bo.billback_id
			</cfif>
			
			WHERE bb_upload_log.deleted = 0 
				<cfif (arguments.searchForm.lnkClick EQ 0)>	
				AND
					datepart(mm, bb_upload_log.upload_date) = <cfqueryparam value="#ARGUMENTS.m#"> AND
					datepart(yyyy, bb_upload_log.upload_date) = <cfqueryparam value="#ARGUMENTS.y#">
				<cfelse>	
					<cfif arguments.searchForm.Upload_Type NEQ 0> 
						AND bb_upload_log.upload_type = '#arguments.searchForm.Upload_Type#'
					</cfif>
					<cfif arguments.searchForm.Uploaded_User NEQ 0>
						AND bb_upload_log.user_id = '#arguments.searchForm.Uploaded_User#'
					</cfif>
					<cfif arguments.searchForm.Uploaded_Date NEQ ''>
						AND CAST(bb_upload_log.upload_date AS DATE) = '#arguments.searchForm.Uploaded_Date#'
					</cfif>
					<cfif arguments.searchForm.BB_Code NEQ ''>
						AND Billback.BB_Code like '%#arguments.searchForm.BB_Code#%'
					</cfif>
					<cfif arrayLen(local.payable_numbers)>
						<cfif (arguments.searchForm.match_type EQ 'partial')>
                			AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.payable_numbers)#" index="local.payable_index"> OR Billback.BB_Code LIKE '%#trim(local.payable_numbers[ local.payable_index ])#%' </cfloop> )
						<cfelse>
							AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.payable_numbers)#" index="local.payable_index"> OR Billback.BB_Code = '#trim(local.payable_numbers[ local.payable_index ])#' </cfloop> )
						</cfif>
            		</cfif>
					<cfif arguments.searchForm.BB_Reference NEQ ''>
						AND Billback.BB_Reference like '%#arguments.searchForm.BB_Reference#%'
					</cfif>
					<cfif arrayLen(local.reference_numbers)>
						<cfif (arguments.searchForm.match_type EQ 'partial')>
                		AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.reference_numbers)#" index="local.reference_index"> OR Billback.BB_Reference LIKE '%#trim(local.reference_numbers[ local.reference_index ])#%' </cfloop> )				
						<cfelse>
						AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.reference_numbers)#" index="local.reference_index"> OR Billback.BB_Reference = '#trim(local.reference_numbers[ local.reference_index ])#' </cfloop> )				
						</cfif>
            		</cfif>
					<cfif (isdefined("arguments.searchForm.Vendor_ID") AND arguments.searchForm.Vendor_ID NEQ '')>
						/* AND (Billback_txt_upload_header_log.vendor like '%#arguments.searchForm.Vendor_ID#%' OR Billback_txt_upload_header_log.Operator_Legacy_ID like '%#arguments.searchForm.Vendor_ID#%') */
						AND (bd.Uploaded_Vendor_ID LIKE '%#arguments.searchForm.Vendor_ID#%' OR bo.Uploaded_Vendor_ID LIKE '%#arguments.searchForm.Vendor_ID#%') 
						
					</cfif>
					<cfif arguments.searchForm.File_Name NEQ ''>
						AND bb_upload_log.header_file_name like '%#arguments.searchForm.File_Name#%'
					</cfif>
					<cfif arguments.searchForm.BB_Upload_Status NEQ '0'>
						<cfif arguments.searchForm.BB_Upload_Status EQ "Validation Failed">
							AND bb_upload_log.upload_status IN (	'ValidatingDetail Validation Failed',
																'Header Validation Failed', 
																'Header Validation Failed; Detail Validation Failed')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Alias needs to be fixed"> 					
							AND bb_upload_log.upload_status IN ('Alias needs to be fixed')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Atleast One Source is Invalid">
							AND bb_upload_log.upload_status IN ('Atleast One Source is Invalid')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Creation Complete">
							AND bb_upload_log.upload_status IN ('Creation Complete')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Check for file FORMAT">
							AND bb_upload_log.upload_status IN ('Check for file FORMAT')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Validation Completed">
							AND bb_upload_log.upload_status IN ('Validation Completed')
						</cfif>
					</cfif>
				</cfif>
			order by upload_id DESC
		</cfquery>

		<cfreturn qGetHistoricUploadLog>

	</cffunction>

	<!--- Todo: getUploadLog --->
	<cffunction name="getUploadLog"  returntype="any">
		<cfargument name="upload_id" type="any" required="false" default="-1">

		<cfquery name="qGetUploadLog" datasource="#application.datasource#">
			select bb_upload_log.upload_id,
				   bb_upload_log.user_id,
				   bb_upload_log.total_header_count,
				   bb_upload_log.total_header_count_failed,
				   bb_upload_log.total_header_count_loaded,
				   bb_upload_log.total_detail_count,
				   bb_upload_log.total_detail_count_failed,
				   bb_upload_log.total_detail_count_loaded,
				   bb_upload_log.upload_date,
				   bb_upload_log.upload_status,
           bb_upload_log.upload_type AS Upload_Type_ID,
				   CASE
						bb_upload_log.upload_type
					WHEN 2
						THEN 'Application'
					ELSE
						'3rd Party'
					END
						As upload_type,
				   bb_upload_log.deleted,
				   bb_upload_log.deleted_by,
				   bb_upload_log.deleted_date,
				    CASE
				   WHEN header_file_name IS NOT NULL THEN
				   --right(header_file_name,(charindex('\',reverse(header_file_name))) - 1)
				   right(header_file_name,CASE WHEN (charindex('\',reverse(header_file_name))) = 0 THEN LEN(header_file_name) ELSE (charindex('\',reverse(header_file_name))) - 1 END)
				   ELSE
				   ''
				   END
				    AS "header_file_name",
				   CASE
				   WHEN Detail_file_name IS NOT NULL THEN
				   --right(detail_file_name,(charindex('\',reverse(detail_file_name))) - 1)
				   right(detail_file_name,CASE WHEN (charindex('\',reverse(detail_file_name))) = 0 THEN LEN(detail_file_name) ELSE (charindex('\',reverse(detail_file_name))) - 1 END)
				   ELSE
				   ''
				   END
				    AS "detail_file_name",
				/*
				   right(header_file_name,(charindex('\',reverse(header_file_name))) - 1) AS "header_file_name",
				   right(detail_file_name,(charindex('\',reverse(detail_file_name))) - 1) AS "detail_file_name",
				   */
				   isnull(_users.user_code,'&nbsp;') AS user_code
			from bb_upload_log	WITH (NOLOCK) <!--- Todo: CPM - Used to prevent deadlocking on during validation runs --->
			left join _users on bb_upload_log.user_id = _users.user_id
			WHERE bb_upload_log.deleted = 0
			<cfif arguments.upload_id GTE 1> <!--- Todo: CPM -For single record retrieval (upload details) --->
				and upload_id = #arguments.upload_id#
				order by upload_id ASC
			<cfelse>
			<!--- Todo: CPM - For pending uploads grab all results unprocessed results --->
 				and ((datediff(day,upload_date,getdate()) <= 0 and upload_status IN ('Validation Completed'))
					OR upload_status IN ('Validating'))
				order by upload_id DESC
			</cfif>
		</cfquery>

		<cfreturn qGetUploadLog />
	</cffunction>

	<!--- Todo: getUploadLogDetail --->
	<cffunction name="getUploadDetailLog"  returntype="any">
		<cfargument name="upload_id" type="any" required="true">

		<cfquery name="qGetUploadDetailLog" datasource="#application.datasource#">
			select 		DISTINCT *
			from 		bb_upload_detail_log
			where 		upload_id = '#arguments.upload_id#'
			and 		len(err_msg) >= 15
			order by 	bb_detail_id ASC
		</cfquery>
		<cfreturn qGetUploadDetailLog />
	</cffunction>

	<!--- Todo: getUploadLogHeader 	--->
	<cffunction name="getUploadHeaderLog"  returntype="any">
		<cfargument name="upload_id" type="any" required="true">
		<cfquery name="qGetUploadHeaderLog" datasource="#application.datasource#">
			select 		*
			from 		bb_upload_header_log
			where 		upload_id = #arguments.upload_id#
			and 		len(err_msg) >= 15
			order by 	bb_header_id ASC
		</cfquery>
		<cfreturn qGetUploadHeaderLog />
	</cffunction>

	<!--- 83129 - Hormel Billback upload ,Deviations and outbound interface issues / Anand Rao / 22-Jan-2019 --->
	<cffunction name="getUploadHeaderDtlDownloadLog"  returntype="any">
		<cfargument name="upload_id" type="any" required="true">
		<cfquery name="qGetUploadHdrDtlLog" datasource="#application.datasource#">
			SELECT 
				DISTINCT
				BBUH.BB_Header_id,
				BBUD.BB_Detail_id,
				BBUH.Vendor,
				BBUH.Customer_Reference,
				BBUH.Total_Amount,
				BBUH.Volume_Qty,
				BBUH.Payee_Type,
				BBUH.Distributor_ID,
				BBUH.Operator_ID ,
				BBUH.Billback_Title, 
				BBUH.Closing_Method ,
				BBUH.Billback_Date, 
				BBUH.Receipt_Date,
				BBUH.BB_Start_Date,
				BBUH.BB_End_Date,
				BBUH.Postmark_Date,
				BBUH.Reference_Num,
				BBUH.Err_Msg AS Header_Err_Msg,
				BBUD.Vendor,
				BBUD.Customer_Reference,
				BBUD.Item_Number,
				BBUD.Program_Number,
				BBUD.Item_Vol_Qty,
				BBUD.Item_Amount,
				BBUD.Discount_Type,
				BBUD.Component_Name,
				BBUD.Distributor_ID,
				BBUD.Operator_Legacy_ID,
				BBUD.Err_Msg AS Detail_Err_Msg
			FROM 		
				bb_upload_detail_log  BBUD 
			INNER JOIN bb_upload_header_log BBUH ON 
				BBUD.upload_id = BBUH.upload_id 
			  	AND BBUD.bb_header_id = BBUH.bb_header_id
				WHERE BBUH.upload_id = #arguments.upload_id#
						/* and 		len(BBUH.err_msg) >= 15 OR len(BBUD.err_msg) >= 15 */
				ORDER BY BBUH.bb_header_id ASC
		</cfquery>
		<cfreturn qGetUploadHdrDtlLog />
	</cffunction>
	
	<!--- Todo: Get Related Billbacks --->
	<cffunction name="getRelatedBB" returntype="any">
		<cfargument name="upload_id" required="true">
	  <cfargument name="upload_type_id" required="true">

    <cfquery name="qGetRelatedBB" datasource="#application.datasource#">
			select BB_Code,
				billback.Billback_ID,
				BB_Title,
				
				CASE WHEN billback.Deleted = 0 THEN
					Billback_Status.BB_Status_Abbreviation
				ELSE
					''
				END AS	BB_Status_Abbreviation,
				CASE WHEN billback.Deleted = 0 THEN
					Billback_Status.BB_Status_Description
				ELSE
					''
				END AS BB_Status_Description,		
				Convert(varchar,BB_Date,101) As BB_Date,
				BB_Start_Date,
				ISNULL(BB_Reference,'&nbsp;') AS BB_Reference,
				CLAIM_CASES,
				BB_Amount,
				CASE
					WHEN Billback_Payee_Type_ID = 1 THEN
						IsNull(bd.uploaded_vendor_id,'999999')
					WHEN Billback_Payee_Type_ID = 2 THEN
						IsNull(bo.uploaded_vendor_id,'999999')
				END AS vendor_id,
				billback.deleted,
				_Users.Name_First + ' ' + _Users.Name_Last AS deletedbyfullname,
				FORMAT(billback.deleted_date,'MM/dd/yyyy hh:mm:s tt') AS deleted_date
			from billback
			left join billback_distributor bd on billback.billback_id = bd.billback_id
			left join billback_operator bo on billback.billback_id = bo.billback_id
			LEFT JOIN Billback_Status ON Billback_Status.Billback_Status_ID = Billback.Billback_Status_ID
			LEFT JOIN _Users ON billback.Deleted_By_User_id = _Users.User_Id
			where 
			/*** D89272: Upload Payables / Upload History page modifications/Anand Rao/08-Oct-2019 
					Show all the claims that were received/loaded.
			***/
			/*	billback.deleted = 0 and */
			billback.billback_id IN (select billback_id from Billback_Txt_Upload_Header_log where upload_id = '#arguments.upload_id#' AND upload_type = #arguments.upload_type_id#)
			order by bb_code DESC
		</cfquery>

		<cfreturn qGetRelatedBB />
	</cffunction>		

	<cffunction name="getUploadPath" returntype="any">
		<cfquery name="qGetUploadPath" datasource="#application.datasource#">
			SELECT [File_Path]
  			FROM [Billback_Upload_Settings]
		</cfquery>

		<cfreturn qGetUploadPath />
	</cffunction>

	<cffunction name="isValidating" output="no">
		<cfargument name="userid" type="string" required="true">
		<cfquery name="qIsValidating" datasource='#application.datasource#'>
			select * from bb_upload_log
			where upload_status = 'validating'
			and deleted = 0
			and user_id = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<cfreturn qIsValidating />
	</cffunction>

	<cffunction name="logUploadError" output="no">
		<cfargument name="error_message" required="true" type="any">
		<cfargument name="user_id" required="true" type="any">

		<cfquery name="setUploadError" datasource="#application.datasource#">
 			Update	bb_upload_log
			set 	upload_status = '#arguments.error_message#'
			where	upload_ID =
			(
				Select 	max(upload_ID) from bb_upload_log
				where	user_ID = '#arguments.user_id#'
				and		upload_status like  '%Validating%'
			)
		</cfquery>
	</cffunction>

	<cffunction name="purge_upload" output="no">
		<cfargument name="upload_id" required="true" type="Numeric">
		<cfargument name="user_code" required="true" type="String">

		<cfstoredproc datasource="#application.datasource#" procedure="purge_upload_sp">
			<cfprocparam type="IN"  variable="@upload_id"	value="#arguments.upload_id#" cfsqltype="CF_SQL_INTEGER">
			<cfprocparam type="IN"  variable="@user_code"	value="#arguments.user_code#" cfsqltype="CF_SQL_VARCHAR">
		</cfstoredproc>
	</cffunction>

	<cffunction name="getPurgedUploads" output="no">
		<cfquery name="qGetPurgedUploads" datasource="#application.datasource#">
			select bb_upload_log.upload_id,
				   bb_upload_log.user_id,
				   bb_upload_log.total_header_count,
				   bb_upload_log.total_header_count_failed,
				   bb_upload_log.total_header_count_loaded,
				   bb_upload_log.total_detail_count,
				   bb_upload_log.total_detail_count_failed,
				   bb_upload_log.total_detail_count_loaded,
				   bb_upload_log.upload_date,
				   bb_upload_log.upload_status,
				   bb_upload_log.deleted,
				   bb_upload_log.deleted_by,
				   bb_upload_log.deleted_date,
				 --  right(header_file_name,(charindex('\',reverse(header_file_name))) - 1) AS "header_file_name",
				  -- right(detail_file_name,(charindex('\',reverse(detail_file_name))) - 1) AS "detail_file_name"
				   right(header_file_name,CASE WHEN (charindex('\',reverse(header_file_name))) = 0 THEN LEN(header_file_name) ELSE (charindex('\',reverse(header_file_name))) - 1 END) AS "header_file_name",
				   right(detail_file_name,CASE WHEN (charindex('\',reverse(detail_file_name))) = 0 THEN LEN(detail_file_name) ELSE (charindex('\',reverse(detail_file_name))) - 1 END) AS "detail_file_name"
			from bb_upload_log where deleted = 1 and datediff("d",deleted_date,getdate()) < 30
			order by deleted_date DESC
		</cfquery>

		<cfreturn qGetPurgedUploads>
	</cffunction>

	<cffunction name="getUniqueMonthDay" returntype="query" output="false">
		<cfset var qUniqueMonthDay = "" />
		<cfquery name="qUniqueMonthDay" datasource="#application.datasource#">
			SELECT
				CAST(YEAR(upload_date) AS Varchar(4)) + ' ' +
				DATENAME(MONTH,upload_date) AS ComboText,
				YEAR(upload_date) AS ComboYear,
				MONTH(upload_date) AS ComboMonth
			FROM
				bb_upload_log
			WHERE upload_date >= (DateAdd(m,- 24,GetDate()))
			GROUP BY
				YEAR(upload_date),
				DATENAME(MONTH,upload_date),
				MONTH(upload_date)
			ORDER BY YEAR(upload_date) DESC,
					MONTH(upload_date) DESC,
					DATENAME(MONTH,upload_date)
		</cfquery>
		<cfreturn qUniqueMonthDay />
	</cffunction>

	<cffunction name="getBillbackUploadSettings" returntype="query">

		<cfquery name="qGetBillbackUploadSettings" datasource="#application.datasource#">
			SELECT	Billback_Upload_Settings.Vendor_Field_Type,
					Billback_Upload_Settings.Operator_Type,
					Billback_Upload_Settings.Distributor_Required,
					Billback_Upload_Settings.Reject_Invalid_Programs,
					ISNULL(Billback_Upload_Settings.Updated_By, '') AS Updated_By,
					Billback_Upload_Settings.Updated_Date,
					_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
					Auto_BB_Title
					,Manual_Upload_Ship_To_Column    <!--- 35663 --->
					,User_Upload_create_BB_per_Associated_Shipto
					,Vendor_Closing_Method_Required
					,Payee_As_Associated_Shipto
					,Operator_Location_Is_Required
					,Program_Picker_For_Trade
			FROM	Billback_Upload_Settings
					LEFT JOIN _Users ON
					_Users.User_Id = Billback_Upload_Settings.Updated_By
		</cfquery>

		<cfreturn qGetBillbackUploadSettings />

	</cffunction>

	<cffunction name="saveBillbackUploadSettings" returntype="void">

		<cfargument name="Vendor_Field_Type"		required="true">
		<cfargument name="Operator_Type"		required="true">
		<cfargument name="Distributor_Required" 	required="true">
		<cfargument name="Reject_Invalid_Programs"	required="true">
		<cfargument name="Updated_By" 			required="true">
		<cfargument name="Auto_BB_Title"		required="true">
		<cfargument name="incl_BB_UOM"		required="true"><!--- Dev Note: drachala; D29378 --->
		<cfargument name="Manual_Upload_Ship_To_Column"		required="true">    <!--- 35663 --->
		<cfargument name="User_Upload_create_BB_per_Associated_Shipto" required="true"> <!--- 44290/Anand Rao/08-Aug-2014 --->
		<cfargument name="Vendor_Closing_Method_Required" required="true">     <!--- D49989/Anand Rao/05-May-2015 --->
		<cfargument name="Payee_As_Associated_Shipto" required="true">     <!--- 51890 --->
		<cfargument name="Operator_Location_Is_Required" required="true">     <!--- 63222 --->
		<cfargument name="Program_Picker_For_Trade" required="true">     <!--- 74377 --->

		<cfset useLakebaseForqCheckBillbackUploadSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_upload_settings")>
<cfif useLakebaseForqCheckBillbackUploadSettings>
	<cftry>
		<cfset qCheckBillbackUploadSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_upload_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckBillbackUploadSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckBillbackUploadSettings>
<cfquery name="qCheckBillbackUploadSettings" datasource="#application.datasource#">
			SELECT	*
  			FROM	Billback_Upload_Settings
		</cfquery>
</cfif>
<!--- Dev Note: drachala; D29378: Display Billback settings Use_UOM on the upload payables settings page  START--->
		<cfquery name="qCheckBillbackSettings" datasource="#application.datasource#">
			UPDATE Billback_Settings
			SET USE_UOM = <cfqueryparam value="#arguments.incl_BB_UOM#" cfsqltype="CF_SQL_BIT" />
		</cfquery>
<!--- End Dev Note: drachala; D29378: Display Billback settings Use_UOM on the upload payables settings page	  --->
		<cfif qCheckBillbackUploadSettings.RecordCount>

			<cfquery name="qUpdateBillbackUploadSettings" datasource="#application.datasource#">
				UPDATE	Billback_Upload_Settings
				SET		Vendor_Field_Type 		= 	<cfqueryparam value="#arguments.Vendor_Field_Type#" cfsqltype="CF_SQL_INTEGER" />,
						Operator_Type			=	<cfqueryparam value="#arguments.Operator_Type#" cfsqltype="CF_SQL_INTEGER" /> ,
						Distributor_Required		= 	<cfqueryparam value="#arguments.Distributor_Required#" cfsqltype="CF_SQL_BIT" />,
						Reject_Invalid_Programs		=	<cfqueryparam value="#arguments.Reject_Invalid_Programs#" cfsqltype="CF_SQL_BIT" />,
						Auto_BB_Title		=	<cfqueryparam value="#arguments.Auto_BB_Title#" cfsqltype="CF_SQL_BIT" />,
						Updated_By			= 	<cfqueryparam value="#arguments.Updated_By#" cfsqltype="CF_SQL_VARCHAR" />,
						Updated_Date			= 	getDate()
						,Manual_Upload_Ship_To_Column = <cfqueryparam value="#arguments.Manual_Upload_Ship_To_Column#" cfsqltype="CF_SQL_VARCHAR" />   <!--- 35663 --->
						,User_Upload_create_BB_per_Associated_Shipto =  <cfqueryparam value="#arguments.User_Upload_create_BB_per_Associated_Shipto#" cfsqltype="CF_SQL_BIT" />  <!--- 44290/Anand Rao/08-Aug-2014 --->
						,Vendor_Closing_Method_Required =  <cfqueryparam value="#arguments.Vendor_Closing_Method_Required#" cfsqltype="CF_SQL_BIT" />  <!--- D49989/Anand Rao/05-May-2015 --->
						,Payee_As_Associated_Shipto = <cfqueryparam value="#arguments.Payee_As_Associated_Shipto#" cfsqltype="CF_SQL_BIT" />
						,Operator_Location_Is_Required = <cfqueryparam value="#arguments.Operator_Location_Is_Required#" cfsqltype="CF_SQL_BIT" />
						,Program_Picker_For_Trade = <cfqueryparam value="#arguments.Program_Picker_For_Trade#" cfsqltype="CF_SQL_BIT" />

			</cfquery>

		<cfelse>

			<cfquery name="qInsertBillbackUploadSettings" datasource="#application.datasource#">
				INSERT INTO	Billback_Upload_Settings
					(Vendor_Field_Type, Operator_Type, Distributor_Required, Reject_Invalid_Programs, Auto_BB_Title, Updated_By, Updated_Date, Manual_Upload_Ship_To_Column,Vendor_Closing_Method_Required, Payee_As_Associated_Shipto, Operator_Location_Is_Required, Program_Picker_For_Trade)
				VALUES
					(
						<cfqueryparam value="#arguments.Vendor_Field_Type#" cfsqltype="CF_SQL_INTEGER" />,
						<cfqueryparam value="#arguments.Operator_Type#" cfsqltype="CF_SQL_INTEGER" />,
						<cfqueryparam value="#arguments.Distributor_Required#" cfsqltype="CF_SQL_BIT" />,
						<cfqueryparam value="#arguments.Reject_Invalid_Programs#" cfsqltype="CF_SQL_BIT" />,
						<cfqueryparam value="#arguments.Auto_BB_Title#" cfsqltype="CF_SQL_BIT" />,
						<cfqueryparam value="#arguments.Updated_By#" cfsqltype="CF_SQL_VARCHAR" />,
						getDate()
						,<cfqueryparam value="#arguments.Manual_Upload_Ship_To_Column#" cfsqltype="CF_SQL_VARCHAR" />    <!--- 35663 --->
						,<cfqueryparam value="#arguments.Vendor_Closing_Method_Required#" cfsqltype="CF_SQL_BIT" />
						,<cfqueryparam value="#arguments.Payee_As_Associated_Shipto#" cfsqltype="CF_SQL_BIT" />
						,<cfqueryparam value="#arguments.Operator_Location_Is_Required#" cfsqltype="CF_SQL_BIT" />
						,<cfqueryparam value="#arguments.Program_Picker_For_Trade#" cfsqltype="CF_SQL_BIT" />
					)
			</cfquery>


		</cfif>

	</cffunction>

	<cffunction name="getUploadDetailsOnBillbackID" output="false"  access="public" returntype="any">
		<cfargument name="billbackID" required="true" type="string">
		
		<cfquery name="qGetUploadDetailsOnBillbackID" datasource="#application.datasource#">
			select bb_upload_log.upload_id,
				   bb_upload_log.user_id,
				   bb_upload_log.total_header_count,
				   bb_upload_log.total_header_count_failed,
				   bb_upload_log.total_header_count_loaded,
				   bb_upload_log.total_detail_count,
				   bb_upload_log.total_detail_count_failed,
				   bb_upload_log.total_detail_count_loaded,
				   bb_upload_log.upload_date,
				   bb_upload_log.upload_status,
           		   bb_upload_log.upload_type AS Upload_Type_ID,
				   CASE
						bb_upload_log.upload_type
					WHEN 2
						THEN 'Application'
					ELSE
						'3rd Party'
					END
						As upload_type,
				   bb_upload_log.deleted,
				   bb_upload_log.deleted_by,
				   bb_upload_log.deleted_date,
				   CASE
				   WHEN header_file_name IS NOT NULL THEN
				   --right(header_file_name,(charindex('\',reverse(header_file_name))) - 1)
				   right(header_file_name,CASE WHEN (charindex('\',reverse(header_file_name))) = 0 THEN LEN(header_file_name) ELSE (charindex('\',reverse(header_file_name))) - 1 END)
				   ELSE
				   ''
				   END
				    AS "header_file_name",
				   CASE
				   WHEN Detail_file_name IS NOT NULL THEN
				   --right(detail_file_name,(charindex('\',reverse(detail_file_name))) - 1)
				   right(detail_file_name,CASE WHEN (charindex('\',reverse(detail_file_name))) = 0 THEN LEN(detail_file_name) ELSE (charindex('\',reverse(detail_file_name))) - 1 END)
				   ELSE
				   ''
				   END
				    AS "detail_file_name",
				   isnull(_users.user_code,'&nbsp;') AS user_code
			from bb_upload_log WITH (NOLOCK)
			left join _users on bb_upload_log.user_id = _users.user_id
			WHERE bb_upload_log.deleted = 0  and BB_upload_log.upload_id = (select upload_ID from Billback_Txt_Upload_Header_log where Billback_ID = '#arguments.BillbackID#')
		</cfquery>
		<cfreturn qGetUploadDetailsOnBillbackID />
	</cffunction>
	
	<!--- Return all the users that uploaded the files --->
	<cffunction name="getAllUploadingUsers" output="false"  access="public" returntype="any">
	
		<cfquery name="qGetAllUploadingUsers" datasource="#application.datasource#">
			SELECT User_ID, Name_First, Name_Last FROM _Users WHERE User_ID IN (
				SELECT DISTINCT(User_ID) FROM bb_upload_log WHERE deleted = 0
			)
			Order by Name_Last
		</cfquery>
	<cfreturn qGetAllUploadingUsers />
	</cffunction>
	
<!---- function with rowcount returned --->

	<!--- Todo: Upload History --->
	<cffunction name="getHistoricUploadLogData" returntype="any">
		<CFARGUMENT NAME="m" DEFAULT="#datepart("m",now())#">
		<CFARGUMENT NAME="y" DEFAULT="#datepart("yyyy",now())#">
		<CFARGUMENT NAME="NewForm" DEFAULT="" type="any">
		<cfargument name="searchForm" default="" type="any" required="true" hint="SearcFilters">
		<cfargument name="startRow" type="numeric" required="false" default="0">
		<cfargument name="endRow" type="numeric" required="false" default="0">
		<cfargument name="sortColumn" type="string" required="false" default="">
		<cfargument name="sortOrder" type="string" required="false" default="">
		
		<cfset var end_row = arguments.endRow - arguments.startRow>		
		
		<cfset vars = structnew()>
		<cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnvariable="vars.appSettings"> 
		<!--- 
		<cfset component="components.settings.ApplicationSettingsManager" method="get" returnvariable="vars.appSettings">  --->
		<!---30227 when app settings 3rd party bb upload  = Instill and BB Approve Expected Rate Less Tolerance = ON turn on audit report--->
		<cfset vars.audit_rpt_on = ( vars.appSettings.ThirdPartyBbUpload eq "1" and vars.appSettings.Bb_Approve_Expected_Rate_Less_Tolerance eq "1" )>
		
		<!--- get max month and year from log --->
		<cfquery name="qUniqueMonthDay" datasource="#application.datasource#">
			SELECT top 1
				CAST(YEAR(upload_date) AS Varchar(4)) + ' ' +
				DATENAME(MONTH,upload_date) AS ComboText,
				YEAR(upload_date) AS ComboYear,
				MONTH(upload_date) AS ComboMonth
			FROM
				bb_upload_log
			WHERE upload_date >= (DateAdd(m,- 24,GetDate()))
			GROUP BY
				YEAR(upload_date),
				DATENAME(MONTH,upload_date),
				MONTH(upload_date)
			ORDER BY YEAR(upload_date) DESC,
					MONTH(upload_date) DESC,
					DATENAME(MONTH,upload_date)
		</cfquery>
		<!--- If the max dates are less than the args, we know that the args are using the default, so reset them.
		when a user selects a date the drop downs will not have a valuee outside of the range of dates present in the log --->
		<cfif (isdefined("arguments.searchForm.lnkClick") AND (arguments.searchForm.lnkClick EQ 0))>
			 <cfif (arguments.searchForm.UploadMonthYear EQ FORM.UploadMonthYear)>
				<cfif ARGUMENTS.m GT qUniqueMonthDay.ComboMonth AND ARGUMENTS.y GTE qUniqueMonthDay.ComboYear>
					<cfset ARGUMENTS.m = qUniqueMonthDay.ComboMonth>
					<cfset ARGUMENTS.y = qUniqueMonthDay.ComboYear>
				</cfif>
			<cfelse>
				<Cfset ARGUMENTS.m  = Month(arguments.searchForm.UploadMonthYear) />
				<Cfset ARGUMENTS.y  = Year(arguments.searchForm.UploadMonthYear) />
			</cfif>	
		</cfif>
 
		<cfif (isDefined("arguments.searchForm.payable_list") AND structKeyExists(arguments.searchForm, "payable_list"))>    <!--- 50885 --->
            <!--- payable list exists :: remove carriage returns & line feeds, then split entries into an array --->
            <cfset local.payable_numbers = listToArray(replace(replace(serializeJSON(arguments.searchForm.payable_list), '\n', ' ', 'all'), '"', ' ', 'all' ), ' ' )>
        </cfif>
		<cfif (isDefined("arguments.searchForm.Reference_Number_list") AND structKeyExists(arguments.searchForm, "Reference_Number_list"))>    <!--- 50885 --->
            <!--- payable list exists :: remove carriage returns & line feeds, then split entries into an array --->
            <cfset local.reference_numbers = listToArray(replace(replace(serializeJSON(arguments.searchForm.Reference_Number_list), '\n', ' ', 'all'), '"', ' ', 'all' ), ' ' )>
        </cfif>
		
		<!--- <cfquery name="qGetHistoricUploadLog" datasource="#application.datasource#"> --->
<cfquery name="qGetHistoricUploadLog" datasource="#application.datasource#">	
SELECT  *,Rows_Cnt = COUNT(1) OVER()
		FROM (	
			select Distinct bb_upload_log.upload_id,
				   bb_upload_log.user_id,
				   bb_upload_log.total_header_count,
				   bb_upload_log.total_header_count_failed,
				   bb_upload_log.total_header_count_loaded,
				   bb_upload_log.total_detail_count,
				   bb_upload_log.total_detail_count_failed,
				   bb_upload_log.total_detail_count_loaded,
				   /* bb_upload_log.upload_date, */
				   CONVERT(VARCHAR(10), bb_upload_log.upload_date, 101) AS upload_date,
				  /*  bb_upload_log.upload_status, */
		  
				 CASE WHEN BB_Upload_Log.upload_status = 'Creation Complete' /*  (upload Type = 2,3) */
                              THEN CASE WHEN (SELECT COUNT(*)
                                    FROM BB_User_Upload_Hold_log BUHEC WHERE BUHEC.upload_id = BB_Upload_Log.upload_id AND BUHEC.Deleted = 0
                                                          )>0 THEN 'Creation Complete - Partial' /*  only for upload_type =2 (Nightly) */
                                                ELSE BB_Upload_Log.upload_status
                                        END
                               WHEN BB_Upload_Log.upload_status <> 'Creation Complete' AND BB_Upload_Log.upload_type = 3 AND -- (upload Type =3)
                                                      BB_upload_log.total_detail_count_loaded <> 0 AND BB_Upload_Log.total_header_count_loaded <>0 
                                                       AND BB_Upload_Log.total_header_count_failed <> BB_Upload_Log.total_header_count_loaded
                                                      THEN  'Creation Complete - Partial'                                                        
                               ELSE BB_Upload_Log.upload_status
                      END   as upload_status,
					  
           		bb_upload_log.upload_type AS Upload_Type_ID,
				   CASE
						bb_upload_log.upload_type
					WHEN 2
						THEN 'Application'
					ELSE
						'3rd Party'
					END
						As upload_type,
				   bb_upload_log.deleted,
				   bb_upload_log.deleted_by,
				   bb_upload_log.deleted_date,
				   CASE
				   WHEN header_file_name IS NOT NULL THEN
				   /* right(header_file_name,(charindex('\',reverse(header_file_name))) - 1) */
				   right(header_file_name,CASE WHEN (charindex('\',reverse(header_file_name))) = 0 THEN LEN(header_file_name) ELSE (charindex('\',reverse(header_file_name))) - 1 END)
				   ELSE
				   ''
				   END
				    AS "header_file_name",
				   CASE
				   WHEN Detail_file_name IS NOT NULL THEN
				   /* right(detail_file_name,(charindex('\',reverse(detail_file_name))) - 1) */
				   right(detail_file_name,CASE WHEN (charindex('\',reverse(detail_file_name))) = 0 THEN LEN(detail_file_name) ELSE (charindex('\',reverse(detail_file_name))) - 1 END)
				   ELSE
				   ''
				   END
				    AS "detail_file_name",
				  /* isnull(_users.user_code,'&nbsp;') AS user_code,*/
				  isnull(_users.user_code,CONCAT(_Users.Name_First,' ',_Users.Name_Last)) AS user_code,
				   '' AS upload_status_link,
					'' AS action_link,	 
					<cfif vars.audit_rpt_on>
						isNull((SELECT TOP 1 Report_fileName FROM Billback_Upload_III_PH_Log WHERE  Upload_ID = bb_upload_log.Upload_ID AND Report_fileName IS NOT NULL),'') AS Report_Header_Filename,
						isNull((SELECT TOP 1 Report_fileName from Billback_Upload_III_PD_Log WHERE  Upload_ID = bb_upload_log.Upload_ID AND Report_fileName IS NOT NULL),'') AS Report_Detail_Filename
					<cfelse>	
					'' AS Report_Header_Filename,
					'' AS Report_Detail_Filename 
					</cfif>   
			from bb_upload_log WITH (NOLOCK)
			left join _users on bb_upload_log.user_id = _users.user_id
			
			LEFT JOIN Billback_txt_upload_header_log ON Billback_txt_upload_header_log.Upload_ID  = bb_upload_log.Upload_ID 
			LEFT JOIN Billback ON Billback.Billback_ID  = Billback_txt_upload_header_log.BIllback_ID
			<cfif (isDefined("arguments.searchForm.Vendor_ID") AND (arguments.searchForm.Vendor_ID NEQ ''))>
				LEFT JOIN Billback_Distributor bd on Billback.billback_id = bd.billback_id
				LEFT JOIN Billback_Operator bo on Billback.billback_id = bo.billback_id
			</cfif>

			WHERE bb_upload_log.deleted = 0 
				<cfif (isdefined("arguments.searchForm.lnkClick") AND (arguments.searchForm.lnkClick EQ 0))>	
						AND
							datepart(mm, bb_upload_log.upload_date) = <cfqueryparam value="#ARGUMENTS.m#"> AND
							datepart(yyyy, bb_upload_log.upload_date) = <cfqueryparam value="#ARGUMENTS.y#">
				<cfelse>	
					<cfif (isdefined("arguments.searchForm.Upload_Type") AND (arguments.searchForm.Upload_Type NEQ 0))> 
						AND bb_upload_log.upload_type = '#arguments.searchForm.Upload_Type#'
					</cfif>
					<cfif (isdefined("arguments.searchForm.Uploaded_User") AND (arguments.searchForm.Uploaded_User NEQ 0))>
						AND bb_upload_log.user_id = '#arguments.searchForm.Uploaded_User#'
					</cfif>
					<cfif (isdefined("arguments.searchForm.Uploaded_Date") AND (arguments.searchForm.Uploaded_Date NEQ ''))>
						AND CAST(bb_upload_log.upload_date AS DATE) = '#arguments.searchForm.Uploaded_Date#'
					</cfif>
					<cfif (isdefined("arguments.searchForm.Upload_ID") AND (arguments.searchForm.Upload_ID NEQ ''))>
						AND bb_upload_log.Upload_ID = '#arguments.searchForm.Upload_ID#'
					</cfif>
					<cfif (isdefined("arguments.searchForm.BB_Code") AND (arguments.searchForm.BB_Code NEQ ''))>
						AND Billback.BB_Code like '%#arguments.searchForm.BB_Code#%'
					</cfif>
					<cfif (isDefined("local.payable_numbers") AND arrayLen(local.payable_numbers))>
						<cfif (arguments.searchForm.match_type EQ 'partial')>
                			AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.payable_numbers)#" index="local.payable_index"> OR Billback.BB_Code LIKE '%#trim(local.payable_numbers[ local.payable_index ])#%' </cfloop> )
						<cfelse>
							AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.payable_numbers)#" index="local.payable_index"> OR Billback.BB_Code = '#trim(local.payable_numbers[ local.payable_index ])#' </cfloop> )
						</cfif>
            		</cfif>
					<cfif (isdefined("arguments.searchForm.BB_Reference") AND (arguments.searchForm.BB_Reference NEQ ''))>
						AND Billback.BB_Reference like '%#arguments.searchForm.BB_Reference#%'
					</cfif>
					<cfif (isDefined("local.reference_numbers") AND arrayLen(local.reference_numbers))>
						<cfif (arguments.searchForm.match_type EQ 'partial')>
                		AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.reference_numbers)#" index="local.reference_index"> OR Billback.BB_Reference LIKE '%#trim(local.reference_numbers[ local.reference_index ])#%' </cfloop> )				
						<cfelse>
						AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.reference_numbers)#" index="local.reference_index"> OR Billback.BB_Reference = '#trim(local.reference_numbers[ local.reference_index ])#' </cfloop> )				
						</cfif>
            		</cfif>
					<cfif (isdefined("arguments.searchForm.Vendor_ID") AND (arguments.searchForm.Vendor_ID NEQ ''))>
						/* AND (Billback_txt_upload_header_log.vendor like '%#arguments.searchForm.Vendor_ID#%' OR Billback_txt_upload_header_log.Operator_Legacy_ID like '%#arguments.searchForm.Vendor_ID#%') */
						AND (bd.Uploaded_Vendor_ID LIKE '%#arguments.searchForm.Vendor_ID#%' OR bo.Uploaded_Vendor_ID LIKE '%#arguments.searchForm.Vendor_ID#%') 
					</cfif>
					
					<cfif (isdefined("arguments.searchForm.File_Name") AND (arguments.searchForm.File_Name NEQ ''))>
						AND bb_upload_log.header_file_name like '%#arguments.searchForm.File_Name#%'
					</cfif>
					<cfif (isdefined("arguments.searchForm.BB_Upload_Status") AND (arguments.searchForm.BB_Upload_Status NEQ '0'))>
						<cfif arguments.searchForm.BB_Upload_Status EQ "Validation Failed">
							AND bb_upload_log.upload_status IN (	'ValidatingDetail Validation Failed',
																'Header Validation Failed', 
																'Validation Failed',
																'Header Validation Failed; Detail Validation Failed')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Alias needs to be fixed"> 					
							AND bb_upload_log.upload_status IN ('Alias needs to be fixed')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Atleast One Source is Invalid">
							AND bb_upload_log.upload_status IN ('Atleast One Source is Invalid')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Creation Complete">
							AND bb_upload_log.upload_status IN ('Creation Complete')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Check for file FORMAT">
							AND bb_upload_log.upload_status IN ('Check for file FORMAT')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "File received">
							AND bb_upload_log.upload_status IN ('File received')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "File Rejected">
							AND bb_upload_log.upload_status IN ('File Rejected')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Transferring file data to DB">
							AND bb_upload_log.upload_status IN ('Transferring file data to DB')	
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Validating">
							AND bb_upload_log.upload_status IN ('Validating')								
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Validation Completed">
							AND bb_upload_log.upload_status IN ('Validation Completed')
						<cfelseif arguments.searchForm.BB_Upload_Status EQ "Validating">
							AND bb_upload_log.upload_status IN ('Validating')
	
						</cfif>
					</cfif>
				</cfif>
				
) AS tmp
<cfif arguments.endRow gt 0>
				ORDER BY 
<cfif arguments.sortColumn neq "">
					<cfswitch expression="#arguments.sortColumn#">
						<cfcase value="Claim_Date">CAST(Claim_Date As datetime)</cfcase>
						<cfcase value="E_Total_Claimed_Amt">CAST(E_Total_Claimed_Amt As float)</cfcase>
						<cfcase value="Tot_Volume">CAST(Tot_Volume As float)</cfcase>
						<cfdefaultcase>#arguments.sortColumn#</cfdefaultcase>
					</cfswitch>
					#arguments.sortOrder#
				<cfelse>
				Upload_ID DESC
				</cfif>
			OFFSET #arguments.startRow# ROWS
				FETCH NEXT #end_row# ROWS ONLY
			</cfif>								
				 
		</cfquery>
		
<!--- <cfset reply.lastrow = reply.ROWS.RecordCount> --->
 
 <!--- <cfoutput>#serializeJSON(reply, "struct")#</cfoutput>   --->
		<cfreturn qGetHistoricUploadLog>

	</cffunction>
	
	
	
</cfcomponent>