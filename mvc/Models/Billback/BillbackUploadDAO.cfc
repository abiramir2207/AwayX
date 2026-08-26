 <!-----------------------------------------------------------------------------

FILE NAME:		BillbackUploadDAO.cfc
DESCRIPTION:	All the data access Queries and SPs go here...
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	29-Apr-2011	Created

------------------------------------------------------------------------------>

<cfcomponent output="false" alias="mvc.Models.Billback.BillbackUploadDAO" extends="mvc.Models.SettingsService" hint="Data Access components, that does all the DB calls">

	<!--- DATA ACCESS FOR BillbackUploadManager --->

	<cffunction name="init" output="false" returntype="mvc.Models.Billback.BillbackUploadDAO">
		<cfreturn this />
	</cffunction>

	<!---
		This function will return all the rows that are open for viewing and not
		locked by any user from the BB_Upload_Header_Error_Correction table
	--->
	<cffunction name="getHeaderSummary" output="false" returntype="query">
		<cfargument name="uploadID" type="numeric" required="false" default="0">
		<cfargument name="BBUploadHeaderErrorCorrectionID" type="numeric" required="false" default="0">
		<cfscript>
			var local.DiffLocalTimeZoneAndEST = this.DiffLocalTimeZoneAndEST();
			var local.useDayLightSavingsTime = int(request.AccessStructure.useDayLightSavingsTime);
		</cfscript>
		<cfquery name="qryHeaderSummary" datasource="#application.datasource#">
			DECLARE @timeZoneOffSet int,
					@DateWithTimeZoneDiff INT,
					@useDayLightSavingsTime BIT

			SET @timeZoneOffSet = #this.DiffLocalTimeZoneAndEST()#

			SET @DateWithTimeZoneDiff = #local.DiffLocalTimeZoneAndEST#
			SET @useDayLightSavingsTime = #local.useDayLightSavingsTime#

 			SELECT Distinct
				BBUHEC.BB_Upload_Header_Error_Correction_ID,
				BBUHEC.Billback_Upload_III_PH_ID,
				BBUHEC.upload_id,
				BBUHEC.Vendor_ID,
				BBUHEC.Vendor_Master_ID,
				BBUHEC.Vendor_Name,
				BBUHEC.Claim_Org_ID,
				BBUHEC.Claim_Num,
				BBUHEC.Claim_Date,
				convert(varchar(25), BBUHEC.Due_Date, 120) AS Due_Date,
				BBUHEC.Trans_Type,
				BBUHEC.Ref_Trans_Num,
				convert(varchar(25), BBUHEC.Period_St_Date, 101) as Period_St_Date ,
				--BBUHEC.Period_St_Date,
				BBUHEC.Period_End_Date,
				BBUHEC.Agreement_Num,
				BBUHEC.Agreement_Name,
				BBUHEC.E_Total_Claimed_Amt,
				BBUHEC.Tot_Volume,
				BBUHEC.Claim_Reason_Code,
				BBUHEC.Claim_Package_ID,
				BBUHEC.Received_Date,
				BBUHEC.Err_Msg,
				BBUHEC.Err_Type,
				BBUHEC.Reference_Num,
				BBUHEC.Billback_Title,
				CASE
					BBUHEC.upload_type
				WHEN 2
					THEN 'Application'
				ELSE
					'3rd Party'
				END
					As upload_type,
				BBUHEC.Locked,
				BBUHEC.Locked_User,
				--CAST(TODATETIMEOFFSET(dateadd(mi,@timeZoneOffSet,BBUHEC.Locked_DateTime),+0) as DateTime) as Locked_DateTime,
				convert(varchar(25), dbo.get_TimeZoneOffset_Date(BBUHEC.Locked_DateTime,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 1, 1), 120) As Locked_DateTime,
				--dateadd(mi,@timeZoneOffSet,BBUHEC.Locked_DateTime) As Locked_DateTime,
				-- BBUHEC.Locked_DateTime,
				BBUHEC.Processed,
				BBUHEC.Operator_ID,
				BBUHEC.User_ID,
				--BBUHEC.Upload_Date,
				--dateadd(mi,@timeZoneOffSet,BBUHEC.Upload_Date) As Upload_Date,
				--CAST(TODATETIMEOFFSET(dateadd(mi,@timeZoneOffSet,BBUHEC.Upload_Date), +0) as DateTime) as Upload_Date,
				--convert(varchar(25), dbo.get_TimeZoneOffset_Date(BBUHEC.Upload_Date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 1, 1), 120) As Upload_Date,
				convert(varchar(25), BBUHEC.Upload_Date, 101) as Upload_Date ,
				convert(varchar(25), BBUHEC.updated_Date, 120) as updated_Date ,
				_Users.Name_First + ' ' + _Users.Name_Last AS Full_Name,
				usr2.Name_First + ' ' + usr2.Name_Last AS Uploaded_User,
				-- BB_upload_log.upload_status
				CASE WHEN  BBUHEC.InValid = 0 AND  BBUHEC.InValid_Detail_Records = 0 THEN 'Creation Complete'
                	WHEN  BBUHEC.InValid = 1 AND  BBUHEC.InValid_Detail_Records = 0 AND REPLACE(REPLACE(BBUHEC.Err_Msg,',',''),' ','') <> '' THEN 'Header Validation Failed'
                    WHEN  BBUHEC.InValid = 1 AND  BBUHEC.InValid_Detail_Records = 0 AND REPLACE(REPLACE(BBUHEC.Err_Msg,',',''),' ','') = '' THEN 'Detail Validation Failed'
                    WHEN  BBUHEC.InValid = 1 AND  BBUHEC.InValid_Detail_Records = 1 AND REPLACE(REPLACE(BBUHEC.Err_Msg,',',''),' ','') = '' THEN 'Detail Validation Failed'
                    WHEN  BBUHEC.InValid = 1 AND  BBUHEC.InValid_Detail_Records = 1 AND REPLACE(REPLACE(BBUHEC.Err_Msg,',',''),' ','') <> '' THEN 'Header Validation Failed; Detail Validation Failed'
                END as upload_status
			FROM
				BB_Upload_Header_Error_Correction BBUHEC
				LEFT JOIN _Users ON _Users.User_ID = BBUHEC.Locked_User
				LEFT JOIN _Users usr2 ON usr2.User_ID = BBUHEC.User_ID
				INNER JOIN BB_upload_log ON BB_upload_log.upload_id = BBUHEC.Upload_ID
			WHERE
				BBUHEC.Processed = 0 AND
				BBUHEC.Upload_WIP = 0
				<cfif arguments.uploadID NEQ 0>
					AND BBUHEC.BB_Upload_Header_Error_Correction_ID = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.BBUploadHeaderErrorCorrectionID#" />
				</cfif>
				<cfif arguments.BBUploadHeaderErrorCorrectionID NEQ 0>
					AND BBUHEC.Upload_ID = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.uploadID#" />
				</cfif>
				AND BBUHEC.Deleted = 0
			ORDER BY BBUHEC.upload_id DESC,BBUHEC.Billback_Upload_III_PH_ID ASC
		</cfquery>

		<!--- When returing all the records, Update the "last data refresh date" --->
		<cfif arguments.uploadID eq 0 AND arguments.BBUploadHeaderErrorCorrectionID eq 0>
			<cfset lastRefreshDt = setBBCorrectionsLastUserRefreshDate()>
		</cfif>

	<cfreturn qryHeaderSummary />
	</cffunction>

	<!---
		This function will return all the records from the BB_Upload_Details_Error_Correction table
		based on the BBUploadHeaderErrorCorrectionID passed to this function
	--->
	<cffunction name="getBBUploadDetails" output="false" returntype="query">
		<cfargument name="uploadID" type="numeric" required="true">
		<cfargument name="BBUploadHeaderErrorCorrectionID" type="numeric" required="true">
		<cfargument name="argbDisplayAll" type="boolean" default="0" required="false">
		<!--- <cfargument name="tblChosen"  type="string" required="false" default="errorCorrection"> --->

		<cfquery name="qryBBUploadDetails" datasource="#application.datasource#">
			SELECT DISTINCT
				CASE WHEN Upload_type = 2 THEN BB_Detail_Sum_ID
                     ELSE BB_Upload_Detail_Error_Correction_ID
                END BB_Upload_Detail_Error_Correction_ID,
				BB_Upload_Header_Error_Correction_ID,
				Upload_ID,
				Claim_Org_ID,
				Dup_Claim_Org_ID,
				Claim_Num,
				DC_Org_ID,
				DC_Org_Desc,
				Operator_Org_ID,
				Agreement_Num,
				Agreement_Name,
				CASE WHEN Upload_type = 2 THEN ''
                	 ELSE DC_AC_Num
                END DC_AC_Num,
                CASE when Upload_type = 2 THEN ''
                     ELSE DC_AC_Name
                END DC_AC_Name,
                CASE when Upload_type = 2 THEN ''
                     ELSE ST_Address_1
                END ST_Address_1,
                CASE when Upload_type = 2 THEN ''
                     ELSE ST_Address_2
                END ST_Address_2,
                CASE when Upload_type = 2 THEN ''
                     ELSE ST_City
                END ST_City,
                CASE when Upload_type = 2 THEN ''
                     ELSE ST_Country
                END ST_Country,
                CASE when Upload_type = 2 THEN ''
                     ELSE ST_State
                END ST_State,
                CASE when Upload_type = 2 THEN ''
                     ELSE ST_Zip_Code
                END ST_Zip_Code,
				Product_Num,
				DC_Product_Num,
				DC_Product_Desc,
				CASE WHEN Upload_type = 2 THEN Sum_Qty
                	 ELSE CS_Qty
                END  CS_Qty,-- SUM (CAST(CS_Qty as DECIMAL(18,5))) as CS_Qty,
				'' AS CS_Claim_Rate ,
				CASE WHEN Upload_type = 2 THEN Sum_Award_Amt
                     ELSE Award_amt
                END Award_Amt,
				Contract_ID,
				CASE WHEN Upload_type = 2 THEN BB_Detail_Sum_ID
                     ELSE Billback_Upload_III_PD_ID
                END Billback_Upload_III_PD_ID,
				Billback_Upload_III_PH_ID,
				Err_Msg,
				Err_Type,
				Discount_Type,
				Upload_Type
			FROM
					BB_Upload_Detail_Error_Correction
			WHERE
				BB_Upload_Header_Error_Correction_ID = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.BBUploadHeaderErrorCorrectionID#" /> AND
				Upload_ID = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.uploadID#" /> AND
				Deleted = 0
				<cfif (arguments.argbDisplayAll EQ 0)>
					AND LTRIM(RTRIM(REPLACE(err_msg,',',''))) <> ''
				</cfif>

		</cfquery>
		<!---
		FROM
				<cfif arguments.tblChosen EQ "errorCorrection">
					BB_Upload_Detail_Error_Correction  /* BB_Upload_Detail_Error_Correction  TEST:: BB_Upload_Detail_Log  */
				<cfelse>
					BB_Upload_Detail_Log
				</cfif>
			WHERE
				BBUploadHeaderErrorCorrectionID = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.uploadID#" /> AND
		</cfquery>
		bb_header_id = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbHeaderID#" /> --->
	<cfreturn qryBBUploadDetails />

	</cffunction>

	<cffunction name="saveUploadHeaderAndDetailsDAO" output="false" returntype="any">
		<cfargument name="bbUploadHeader" type="any" default="">
		<cfargument name="sAction" type="string" default="2">
			<cfset var bbUploadDetail = '' />
			<cfquery name="updUploadHeader" datasource="#application.datasource#">
				UPDATE BB_Upload_Header_Error_Correction
				SET
					Vendor_ID 			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.vendorID#" />,
					Vendor_Name			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.vendorName#" />,
					Claim_Num			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.BBReference#" />,
					Claim_Date			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.BBDate#" />,
					Period_St_Date 		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.startDate#" />,
					Period_End_Date 	= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.endDate#" />,
					E_Total_Claimed_Amt = <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.BBAmount#" />,
					Operator_ID   		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.operatorLegacyID#" />,
					Billback_Title 		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.billbackTitle#" />,
					Claim_org_ID 		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.shipTo#" />,
					<cfif arguments.sAction EQ "2">
						Processed			= <cfqueryParam cfsqltype="cf_sql_bit" value="1" />,
					<cfelse>
						Processed			= <cfqueryParam cfsqltype="cf_sql_bit" value="0" />,
					</cfif>
					Agreement_Num		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.agreementNum#" />,
					Agreement_Name		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.agreementName#" />,
					Updated_By			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#Request.AccessStructure.User_ID#" />,
					Updated_Date		= getDate(),
					Edited				= 1
				WHERE
					BB_Upload_Header_Error_Correction_ID =	<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.bbHeaderID#" />  AND
					upload_id = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.uploadID#" />

			</cfquery>
<!--- 			upload_type 		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.uploadType#" />, --->
			<!---  upload_id = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.uploadID#" /> AND  --->
			<!---
				Set the deleted flag to 1 on all the record and update each one as they are updated with the details
				This is done so that if a detail record is removed from the object in the front end that will
				be reflected in the backend too.
			--->
 			<!---
				31265: Detail error correction is set deleted = 1 for all claims in an upload/Anand Rao/04-Apr-2012
				Added the BB_Upload_Header_Error_Correction_ID in the condition

			--->
			<!--- <cfif sAction EQ "2">
				<cfquery name="updUploadDetailToDelete" datasource="#application.datasource#">
					UPDATE BB_Upload_Detail_Error_Correction
					SET
						Deleted = 1,
						Deleted_Date = getDate()
					WHERE 	BB_Upload_Header_Error_Correction_ID =	<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.bbHeaderID#" />  AND
						upload_id = <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.uploadID#" />
				</cfquery>
			</cfif>	--->
			<!---- Loop over the BBUploadDetail array in the Header object and update the BB_Upload_Detail_Error_Correction --->
			<!--- TODO: *********** In the below update it should be updating the claim_org_ID from the details ship_TO
			since there is no code to handle this at this point we are using the same ShipTo as the Header.
			This needs to be fixed. - Anand Rao/ 21-Jul-2011
						--->
			<!--- Claim_Org_ID		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.bbUploadDetail[i].shipTo#" />, --->
			<cfloop index = "i" from = "1" to="#ArrayLen(arguments.bbUploadHeader.bbUploadDetail)#">
				<cfset bbUploadDetail = arguments.bbUploadHeader.bbUploadDetail[i] />
				<!---  D108591 mws ::  Sporadic Missing Detail keys.  Still can't find a cause so defend anyway --->
				<cfscript>
					bbUploadDetail.operatorLegacyId = bbUploadDetail.operatorLegacyId ?: "";
					bbUploadDetail.item = bbUploadDetail.item ?: "";
					bbUploadDetail.ContractNumber = bbUploadDetail.ContractNumber ?: "";
					bbUploadDetail.dupShipTo = bbUploadDetail.dupShipTo ?: "";
				</cfscript>

				<cfif bbUploadDetail.bEdited EQ true >
					<cfquery name="updUploadDetail" datasource="#application.datasource#">
						UPDATE BB_Upload_Detail_Error_Correction
						SET
							Vendor_ID 			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.vendorID#" />,
							Claim_Num			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.BBReference#" />,
							Claim_Org_ID		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.shipTo#" />,
							Dup_Claim_Org_ID  	= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.dupShipTo#" />,
							DC_Org_ID  			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.custNumber#" />,
							DC_Org_Desc			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.custName#" />,
							Operator_Org_ID		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.operatorLegacyId#" />,
							Agreement_Num		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.custContractNumber#" />,
							Agreement_Name		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.custContractDescription#" />,
							DC_AC_Num			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.operatorId#" />,
							DC_AC_Name			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.operatorName#" />,
							ST_Address_1		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.operatorAddress1#" />,
							ST_Address_2		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.operatorAddress2#" />,
							ST_City				= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.operatorCity#" />,
							ST_State			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.operatorState#" />,
							ST_Zip_Code			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.operatorZip#" />,
							Product_Num			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#Trim(bbUploadDetail.item)#" />,
							DC_Product_Num		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.custItem#" />,
							DC_Product_Desc		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.custItemDescription#" />,
							Contract_ID			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#Trim(bbUploadDetail.contractNumber)#" />,
		 					Err_Msg				= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.errMsg#" />,
							Err_Type			= 1,
							Deleted				= 0,
							Deleted_Date 		= NULL,
							Edited				= 1
						WHERE
							BB_Upload_Header_Error_Correction_ID 		= <cfqueryParam cfsqltype="cf_sql_integer" value="#bbUploadDetail.bbHeaderID#" /> AND
							(
							 	(Upload_Type = 2 AND BB_Detail_Sum_ID = <cfqueryParam cfsqltype="cf_sql_integer" value="#bbUploadDetail.bbDetailID#" />)
								OR
								(Upload_Type = 3 AND BB_Upload_Detail_Error_Correction_ID 		= <cfqueryParam cfsqltype="cf_sql_integer" value="#bbUploadDetail.bbDetailID#" />)
							)
							AND
							upload_id 			= <cfqueryParam cfsqltype="cf_sql_integer" value="#bbUploadDetail.uploadID#" />
					</cfquery>
				</cfif>
				<!---
					<cfif (arguments.bbUploadHeader.uploadType EQ 3)>
						CS_Qty				= <cfqueryParam cfsqltype="cf_sql_varchar" value="#Replace(bbUploadDetail.BBProductQuantity,' ','','ALL')#" />,
						Award_Amt			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#Replace(Replace(bbUploadDetail.BBRate,' ','','ALL'),',','','ALL')#" />,
					<cfelseif (arguments.bbUploadHeader.uploadType EQ 2)>
						Sum_Qty 			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#Replace(bbUploadDetail.BBProductQuantity,' ','','ALL')#" />,
						Sum_Award_Amt			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#Replace(Replace(bbUploadDetail.BBRate,' ','','ALL'),',','','ALL')#" />,
					</cfif>
				--->

								<!--- /* CS_Claim_Rate		= <cfqueryParam cfsqltype="cf_sql_varchar" value="#bbUploadDetail.caseRate#" />, */ --->
<!---   upload_type			= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.bbUploadDetail[i].uploadType#" />,  --->
		 </cfloop>
		 <!---
		 Vendor				= <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.bbUploadDetail[i].vendor#" /> AND
						Customer_Reference  = <cfqueryParam cfsqltype="cf_sql_varchar" value="#arguments.bbUploadHeader.bbUploadDetail[i].customerReference#" /> AND
		 --->
		<cfreturn />
	</cffunction>

	<cffunction name="deleteUploadHeaderAndDetailsDAO" output="false" returntype="any">
		<cfargument name="bbUploadHeader" type="mvc.Models.Billback.vos.BBUploadHeader" default="">
			<cfquery name="delUploadHeader" datasource="#application.datasource#">
				UPDATE BB_Upload_Header_Error_Correction
				SET
					Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
					Deleted_Date = getDate(),
					Deleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				WHERE
					BB_Upload_Header_Error_Correction_ID =	<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.bbHeaderID#" /> AND
					Upload_ID =  <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.uploadID#" />
			</cfquery>
			<!--- upload_id =	<cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.uploadID#" /> AND --->
			<!---- Loop over the BBUploadDetail array in the Header object and update the BB_Upload_Detail_Error_Correction --->
			<cfloop index = "i" from = "1" to="#ArrayLen(arguments.bbUploadHeader.bbUploadDetail)#">
				<cfquery name="delUploadDetail" datasource="#application.datasource#">
					UPDATE BB_Upload_Detail_Error_Correction
					SET
						Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
						Deleted_Date = getDate(),
						Deleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
					WHERE
						upload_id					= <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.bbUploadDetail[i].uploadID#" /> AND
						BB_Upload_Detail_Error_Correction_ID 	= <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadHeader.bbUploadDetail[i].bbDetailID#" />
				</cfquery>
		 	</cfloop>
		 	<!--- Delete the records along with the the BB_Upload_log that created the upload --->
			<cfset this.deleteUploadAndBranchesDAO(arguments.bbUploadHeader.uploadID) />
	</cffunction>


 <cffunction name="deleteUploadAndBranchesDAO" output="false" returntype="any">
		<cfargument name="uploadIDList" type="any" default="">
		<cfquery name="delUploadDetail" datasource="#application.datasource#">
			UPDATE BB_Upload_Log
			SET
				Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
				Deleted_Date = getDate(),
				Deleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			WHERE
				Upload_ID IN (#uploadIDList#)
		</cfquery>
		<cfquery name="delUploadHeader" datasource="#application.datasource#">
			UPDATE BB_Upload_Header_Error_Correction
			SET
				Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
				Deleted_Date = getDate(),
				Deleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			WHERE
			Upload_ID IN (#uploadIDList#)
		</cfquery>
		<cfquery name="delUploadDetail" datasource="#application.datasource#">
			UPDATE BB_Upload_Detail_Error_Correction
			SET
				Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
				Deleted_Date = getDate(),
				Deleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			WHERE
				Upload_ID IN (#uploadIDList#)
		</cfquery>
 	</cffunction>


	<cffunction name="deleteCorrectionRecordsDAO" output="false" returntype="any">
		<cfargument name="BBHeaderIDList" type="any" default="">
		<cfquery name="qrySelectFields" datasource="#application.datasource#">
			SELECT
				Upload_ID,
				Billback_Upload_III_PH_ID
			FROM
				BB_Upload_Header_Error_Correction
			WHERE
				BB_Upload_Header_Error_Correction_ID IN (#arguments.BBHeaderIDList#)
		</cfquery>
		<cfloop query = "qrySelectFields">
			<cfquery name="updBBUploadIIIPHLog" datasource="#application.datasource#">
				UPDATE Billback_Upload_III_PH_Log
				SET
					Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
					Deleted_Date = getDate(),
					Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				WHERE
					Upload_ID = #qrySelectFields.Upload_ID# AND
					Billback_Upload_III_PH_ID = #qrySelectFields.Billback_Upload_III_PH_ID#
			</cfquery>
			<cfstoredproc procedure="Upload_EDI_Dup_Delete" datasource="#application.datasource#">
				<cfprocparam type="In" CFSQLType="CF_SQL_VARCHAR"	dbVarName = "@@Billback_ID" value="" null="true" />
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@Upload_ID" value="#qrySelectFields.Upload_ID#"  null="false"/>
				<cfprocparam type="In" CFSQLType="CF_SQL_INTEGER"	dbVarName = "@@Header_ID" value="#qrySelectFields.Billback_Upload_III_PH_ID#"  null="false"/>
			</cfstoredproc>
			<cfquery name="updBBUploadIIIPDLog" datasource="#application.datasource#">
				UPDATE Billback_Upload_III_PD_Log
				SET
					Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
					Deleted_Date = getDate(),
					Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				WHERE
					Upload_ID = #qrySelectFields.Upload_ID# AND
					Billback_Upload_III_PH_ID = #qrySelectFields.Billback_Upload_III_PH_ID#
			</cfquery>
			<cfquery name="delBBUploadHeaderLog" datasource="#application.datasource#">
				DELETE FROM  BB_Upload_Header_Log
				WHERE
					Upload_ID = #qrySelectFields.Upload_ID# AND
					BB_Header_ID = #qrySelectFields.Billback_Upload_III_PH_ID#
			</cfquery>
			<cfquery name="delBBUploadDetailLog" datasource="#application.datasource#">
				DELETE FROM  BB_Upload_Detail_Log
				WHERE
					Upload_ID = #qrySelectFields.Upload_ID# AND
					BB_Header_ID = #qrySelectFields.Billback_Upload_III_PH_ID#
			</cfquery>
		</cfloop>
		<cfquery name="updBBUploadHeaderErrorCorrection" datasource="#application.datasource#">
			UPDATE BB_Upload_Header_Error_Correction
			SET
				Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
				Deleted_Date = getDate(),
				Deleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			WHERE
			BB_Upload_Header_Error_Correction_ID IN (#arguments.BBHeaderIDList#)
		</cfquery>
		<cfquery name="updBBUploadDetailErrorCorrection" datasource="#application.datasource#">
			UPDATE BB_Upload_Detail_Error_Correction
			SET
				Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
				Deleted_Date = getDate(),
				Deleted_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			WHERE
				BB_Upload_Header_Error_Correction_ID IN (#arguments.BBHeaderIDList#)
		</cfquery>

	</cffunction>

   <cffunction name="deleteDetailRow" output="false">
   	   <cfargument name="bbUploadDetail" type="struct" default="">
	   <cfquery name="qrySelectFields" datasource="#application.datasource#">
			SELECT
				Upload_ID,
				Billback_Upload_III_PH_ID,
				 Billback_Upload_III_PD_ID
			FROM
				BB_Upload_Detail_Error_Correction
			WHERE
						upload_id					= <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadDetail.uploadID#" /> AND
						<cfif (arguments.bbUploadDetail.UploadType EQ 2)>
							BB_Detail_Sum_ID 	= <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadDetail.bbDetailID#" />
						<cfelse>
							BB_Upload_Detail_Error_Correction_ID 	= <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadDetail.bbDetailID#" />
						</cfif>
		</cfquery>
		<cfquery name="updBBUploadIIIPDLog" datasource="#application.datasource#">
				UPDATE Billback_Upload_III_PD_Log
				SET
					Deleted = <cfqueryParam cfsqltype="cf_sql_integer" value="1" />,
					Deleted_Date = getDate(),
					Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				WHERE
					Upload_ID = #qrySelectFields.Upload_ID# AND
					Billback_Upload_III_PH_ID = #qrySelectFields.Billback_Upload_III_PH_ID# AND
					Billback_Upload_III_PD_ID = #qrySelectFields.Billback_Upload_III_PD_ID#
		</cfquery>

		<cfquery name="delUploadDetail" datasource="#application.datasource#">
					DELETE FROM
						BB_Upload_Detail_Error_Correction
					WHERE
						upload_id					= <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadDetail.uploadID#" /> AND
						<cfif (arguments.bbUploadDetail.UploadType EQ 2)>
							BB_Detail_Sum_ID 	= <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadDetail.bbDetailID#" />
						<cfelse>
							BB_Upload_Detail_Error_Correction_ID 	= <cfqueryParam cfsqltype="cf_sql_integer" value="#arguments.bbUploadDetail.bbDetailID#" />
						</cfif>
				</cfquery>
	</cffunction>

	<cffunction name="getBBUploadErrorCodes" output="false" returntype="query">
		<cfquery name="qryBBUploadErrorCodes" datasource="#application.datasource#">
			SELECT
				Error_ID,
				Error_Code,
				Error_Desc,
				Error_Valid_Rules,
				Error_Type,
				Deleted
			FROM
				BB_Upload_Error_Codes
			WHERE
				Deleted = 0
		</cfquery>

		<cfreturn qryBbUploadErrorCodes />

	</cffunction>

	<cffunction name="getUploadHistory" output="false" returntype="query">
		<cfargument name="argStart" default="#dateAdd('m',-18,now())#" required="false">
		<cfargument name="argEnd" default="#now()#" required="false">
		<cfargument name="getCompleteHistory" default="0" />
		<cfscript>
			var local.DiffLocalTimeZoneAndEST = this.DiffLocalTimeZoneAndEST();
			var local.useDayLightSavingsTime = int(request.AccessStructure.useDayLightSavingsTime);
		</cfscript>
		<cfquery name="qGetHistoricUploadLog" datasource="#application.datasource#">
		DECLARE
			@DateWithTimeZoneDiff INT,
			@useDayLightSavingsTime BIT
			SET @DateWithTimeZoneDiff = #local.DiffLocalTimeZoneAndEST#
			SET @useDayLightSavingsTime = #local.useDayLightSavingsTime#

			SELECT DISTINCT
				   BB_Upload_Log.upload_id,
				   BB_Upload_Log.user_id,
				   BB_Upload_Log.total_header_count,
				   BB_Upload_Log.total_header_count_failed,
				   BB_Upload_Log.total_header_count_loaded,
				   BB_Upload_Log.total_detail_count,
				   BB_Upload_Log.total_detail_count_failed,
				   BB_Upload_Log.total_detail_count_loaded,
				   --dbo.get_TimeZoneOffset_Date(BB_Upload_Log.upload_date,@DateWithTimeZoneDiff,@useDayLightSavingsTime, 1, 1) As upload_date,
				   BB_Upload_Log.upload_date,
				   -- BB_Upload_Log.upload_status,
                   CASE WHEN BB_Upload_Log.upload_status = 'Creation Complete'
                                  THEN CASE WHEN (SELECT COUNT(*)
                                                          FROM BB_Upload_Header_Error_Correction BUHEC WHERE BUHEC.upload_id = BB_Upload_Log.upload_id AND BUHEC.Deleted = 0
                                                          )>0 THEN 'Creation Complete - Partial'
                                                ELSE BB_Upload_Log.upload_status
                                        END
                            ELSE BB_Upload_Log.upload_status
                      END   as upload_status,
          		   BB_Upload_Log.upload_type AS Upload_Type_ID,
				   CASE
						BB_Upload_Log.upload_type
					WHEN 2
						THEN 'Application'
					ELSE
						'3rd Party'
					END
						As upload_type,
				   BB_Upload_Log.deleted,
				   BB_Upload_Log.deleted_by,
				   BB_Upload_Log.deleted_date,
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
				   isnull(_users.user_code,'&nbsp;') AS user_code,
				   _users.Name_First as Name_First,
				    _users.Name_Last as Name_Last,
					ISNULL(
                          (STUFF((
                            SELECT DISTINCT ',' + BUHEC.vendor_ID + ',' + VM.Vendor_Name
                            FROM BB_Upload_Header_Error_Correction BUHEC
                            LEFT JOIN Vendor_Master VM ON BUHEC.vendor_ID = VM.Vendor_ID
                            WHERE BUHEC.upload_id = BB_Upload_Log.upload_id FOR XML PATH('')
                                ),1,1,'') )
                          , (STUFF((
                            SELECT DISTINCT  ',' + BTUHL.vendor + ',' + VM.Vendor_Name
                            FROM Billback_Txt_Upload_Header_log BTUHL
                            LEFT JOIN Vendor_Master VM ON BTUHL.vendor = VM.Vendor_ID
                            WHERE BTUHL.upload_id = BB_Upload_Log.upload_id FOR XML PATH('')
                                ),1,1,'') )
                          ) AS VendorSearchField,
					ISNULL(
                            (STUFF((
                                SELECT DISTINCT  ',' +  ISNULL(BTUHL1.Billback_Title,'') + ',' + ISNULL(BTUHL1.Reference_Num,'') + ',' + ISNULL(BTUHL1.Customer_Reference,'')
                                FROM Billback_Txt_Upload_Header_log BTUHL1 WHERE BTUHL1.upload_id = BB_Upload_Log.upload_id FOR XML PATH('')
                                ),1,1,''))
                            ,(STUFF((
                                SELECT DISTINCT  ',' +  BUHEC.Billback_Title + ',' + BUHEC.Claim_Num
                                FROM BB_Upload_Header_Error_Correction BUHEC WHERE BUHEC.upload_id = BB_Upload_Log.upload_id FOR XML PATH('')
                                ),1,1,''))
                                ) AS BBTitleSearchField,
                      STUFF((
                             SELECT DISTINCT ',' + BB.BB_Code
                             FROM Billback_Txt_Upload_Header_log BTUHL2
                             INNER JOIN Billback BB ON BTUHL2.Billback_ID = BB.Billback_ID
                             WHERE BTUHL2.upload_id = BB_Upload_Log.upload_id FOR XML PATH('')
                                 ),1,1,'') AS BBCodeSearchField

			FROM  BB_Upload_Log WITH (NOLOCK)
			LEFT JOIN _users ON BB_Upload_Log.user_id = _users.user_id

			WHERE BB_Upload_Log.deleted = 0
			<cfif arguments.getCompleteHistory NEQ 1>
					AND
					BB_Upload_Log.upload_date >= <cfqueryparam value="#ARGUMENTS.argStart#" cfsqltype="cf_sql_date"> AND
					DATEADD(day,-1,BB_Upload_Log.upload_date) <= <cfqueryparam value="#ARGUMENTS.argEnd#" cfsqltype="cf_sql_date">
			</cfif>
				 /*  AND BB_Upload_Log.upload_type = 2  */
			ORDER BY BB_Upload_Log.upload_id DESC
		</cfquery>

		<!--- Update the "last data refresh date" --->
		<cfset lastRefreshDt = setBBUploadLastUserRefreshDate()>

<!---  <cfdump var="#qGetHistoricUploadLog#" output="c:\temp\qGetHistoricUploadLog.TXT"/> --->
	<cfreturn qGetHistoricUploadLog />
	</cffunction>

	<!---
		 Returns all the records from the BB_Upload_Header_Log for the passed Upload_ID
	--->
	<cffunction name="getUploadHeaderSet" output="false" returntype="query">
		<cfargument name="uploadID" type="numeric" required="true">
		<cfquery name="qGetUploadHeaderSet" datasource="#application.datasource#">
			SELECT
				BB_Upload_Header_Error_Correction_ID,
				upload_id,
				Vendor_ID,
				Vendor_Master_ID
				Vendor_Name,
				Claim_Org_ID,
				Claim_Num,
				Claim_Date,
				Due_Date,
				Trans_Type,
				Ref_Trans_Num,
				Period_St_Date,
				Period_End_Date,
				Agreement_Num,
				Agreement_Name,
				E_Total_Claimed_Amt,
				Claim_Reason_Code,
				Claim_Package_ID,
				Received_Date,
				Err_Msg,
				Err_Type,
				Reference_Num,
				upload_type,
				Locked,
				Locked_User,
				Locked_DateTime,
				Processed
			FROM
				BB_Upload_Header_Error_Correction
 			WHERE Upload_ID = #arguments.uploadID#
		</cfquery>
		<!--- 	<cfelse>
					 BB_Upload_Header_Log
				</cfif>
				<cfif arguments.uploadType EQ 2>
					WHERE Manual_Upload_ID = #arguments.uploadID#
				<cfelseif arguments.uploadType EQ 3>
					WHERE Upload_ID = #arguments.uploadID#
				</cfif>
				 --->
		<cfreturn qGetUploadHeaderSet />
	</cffunction>

	<cffunction name="setBBLocked" access="public" output="false" returntype="numeric">

		<cfargument name="bbHeaderID" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />

		<cfscript>
			//set local variables
			var nBBHeaderID			= "";
			var strUserID			= "";
			var qSetBillbackLocked		= "";
			var nReturnSuccess		= 1;

			//assign local variables
			nBBHeaderID			= arguments.bbHeaderID;
			strUserID			= arguments.userId;
		</cfscript>

		<cftry>
			<!--- set the uploaded record locked --->
			<cfquery name="qSetBillbackLocked" datasource="#application.datasource#">
				UPDATE BB_Upload_Header_Error_Correction
				SET 	Locked = 1,
					Locked_User = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#strUserID#">,
					Locked_DateTime = getDate()
				WHERE
					BB_Upload_Header_Error_Correction_ID =	 <cfqueryParam cfsqltype="cf_sql_integer" value="#nBBHeaderID#" />
			</cfquery>

			<cfcatch type="database">
				<cfset nReturnSuccess = 0 />
			</cfcatch>
		</cftry>

		<cfreturn nReturnSuccess />

	</cffunction>

	<cffunction name="setBBUnLocked" access="public" output="false" returntype="numeric">

		<cfargument name="bbHeaderID" type="numeric" required="true" />

		<cfscript>
			//set local variables
			var nBBHeaderID			= "";
			var qSetBillbackUnLocked	= "";
			var nReturnSuccess		= 1;

			//assign local variables
			nBBHeaderID	= arguments.bbHeaderID;
		</cfscript>

		<cftry>
			<!--- set the uploaded record to unlocked --->
			<cfquery name="qSetBillbackUnLocked" datasource="#application.datasource#">
				UPDATE	BB_Upload_Header_Error_Correction
				SET		Locked =  0,
						Locked_User = NULL,
						Locked_DateTime = NULL

				WHERE	BB_Upload_Header_Error_Correction_ID = <cfqueryParam cfsqltype="cf_sql_integer" value="#nBBHeaderID#" />
			</cfquery>

			<cfcatch type="database">
				<cfset nReturnSuccess = 0 />
			</cfcatch>
		</cftry>

		<cfreturn nReturnSuccess />

	</cffunction>

	<cffunction name="getBBLockedByID" access="public" output="false" returntype="query">

		<cfargument name="bbHeaderID" type="numeric" required="true" />

		<cfscript>
			//set local variables
			var nBBHeaderID			= "";
			var qGetBillbackLocked		= "";
			var qRetQuery			= "";

			//assign local variables
			nBBHeaderID	= arguments.bbHeaderID;
		</cfscript>

		<!--- check to see if the uploaded record is locked --->
		<cfquery name="qGetBillbackLocked" datasource="#application.datasource#">
			SELECT	bbhec.BB_Upload_Header_Error_Correction_ID,bbhec.Locked_User As BB_Locked_By_User_ID
			FROM
				BB_Upload_Header_Error_Correction bbhec
			WHERE
				bbhec.BB_Upload_Header_Error_Correction_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nBBHeaderID#">
			AND	bbhec.Locked = 1
		</cfquery>

		<cfscript>
			qRetQuery = qGetBillbackLocked;
			return qRetQuery;
		</cfscript>

	</cffunction>

	<cffunction name="getBBLockedByUser" access="public" output="false" returntype="query">

		<cfargument name="userId" type="string" required="true" />
		<cfargument name="bbHeaderID" type="numeric" required="false" default="0" />

		<cfscript>
			//set local variables
			var strUserID			= "";
			var qGetBillbackUserLocked	= "";
			var qRetQuery			= "";
			var nBBHeaderID			= 0;

			//assign local variables
			strUserID	= arguments.userId;
			nBBHeaderID	= trim(arguments.bbHeaderID);
		</cfscript>

		<!--- check to see if this user has a uploaded record locked --->
		<cfquery name="qGetBillbackUserLocked" datasource="#application.datasource#">
			SELECT	bbhec.BB_Upload_Header_Error_Correction_ID, bbhec.Locked_User As BB_Locked_By_User_ID, _Users.Name_First + ' ' + _Users.Name_Last AS Locked_By_User_Name
			FROM	BB_Upload_Header_Error_Correction bbhec
					INNER JOIN _Users ON _Users.User_ID = bbhec.Locked_User
			WHERE	bbhec.Locked = 1 AND bbhec.deleted = 0
			AND		_Users.User_ID = <cfqueryparam value="#strUserID#" cfsqltype="CF_SQL_VARCHAR" />
			<!--- filter on nBBHeaderID is passed to the function --->
			<cfif nBBHeaderID neq 0>
			AND		bbhec.BB_Upload_Header_Error_Correction_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#nBBHeaderID#">
			</cfif>
		</cfquery>

		<cfscript>
			qRetQuery = qGetBillbackUserLocked;
			return qRetQuery;
		</cfscript>

	</cffunction>

	<cffunction name="setBBCorrectionsLastUserRefreshDate" access="private" output="false" returntype="void">

		<!--- update the last refresh date for the bb corrections --->
		<cfquery name="qSetBBCorrectionsLastUserRefreshDate" datasource="#application.datasource#" result="qLastUserRefreshDateResults">
			UPDATE BB_Corrections_User_Refresh_Date
			SET
				Updated_Date = getdate()
			WHERE
				User_ID = <cfqueryParam cfsqltype="cf_sql_varchar" value="#Request.AccessStructure.User_ID#">
		</cfquery>

		<!--- Insert the last refresh date for the bb corrections --->
		<cfif qLastUserRefreshDateResults.recordcount eq 0>
			<cfquery name="qInsertBBCorrectionsLastUserRefreshDate" datasource="#application.datasource#">
				IF NOT EXISTS
				(SELECT * FROM BB_Corrections_User_Refresh_Date WHERE User_ID = '#Request.AccessStructure.User_ID#')
				BEGIN
					INSERT INTO BB_Corrections_User_Refresh_Date(User_ID,Updated_Date)
					VALUES(<cfqueryParam cfsqltype="cf_sql_varchar" value="#Request.AccessStructure.User_ID#">,getDate())
				END
			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="getBBCorrectionsLastUserRefreshDate" access="public" output="false" returntype="query">

		<!--- get the last refresh date for the bb corrections --->
		<cfquery name="qGetBBCorrectionsLastUserRefreshDate" datasource="#application.datasource#">
			SELECT Updated_Date
			FROM BB_Corrections_User_Refresh_Date
			WHERE User_ID = <cfqueryParam cfsqltype="cf_sql_varchar" value="#Request.AccessStructure.User_ID#">
		</cfquery>

		<cfreturn qGetBBCorrectionsLastUserRefreshDate>

	</cffunction>

	<cffunction name="setBBUploadLastUserRefreshDate" access="private" output="false" returntype="void">

		<!--- update the last refresh date for the bb upload --->
		<cfquery name="qSetBBUploadLastUserRefreshDate" datasource="#application.datasource#" result="qLastUserRefreshDateResults">
			UPDATE BB_Upload_User_Refresh_Date
			SET
				Updated_Date = getdate()
			WHERE
				User_ID = <cfqueryParam cfsqltype="cf_sql_varchar" value="#Request.AccessStructure.User_ID#">
		</cfquery>

		<!--- insert the last refresh date for the bb upload --->
		<cfif qLastUserRefreshDateResults.recordcount eq 0>
			<cfquery name="qInsertBBUploadLastUserRefreshDate" datasource="#application.datasource#">
				IF NOT EXISTS
				(SELECT * FROM BB_Upload_User_Refresh_Date WHERE User_ID = '#Request.AccessStructure.User_ID#')
				BEGIN
					INSERT INTO BB_Upload_User_Refresh_Date(User_ID,Updated_Date)
					VALUES(<cfqueryParam cfsqltype="cf_sql_varchar" value="#Request.AccessStructure.User_ID#">,getDate())
				END
			</cfquery>
		</cfif>

	</cffunction>

	<cffunction name="getBBUploadLastUserRefreshDate" access="public" output="false" returntype="query">

		<!--- get the last refresh date for the bb upload --->
		<cfquery name="qGetBBUploadLastUserRefreshDate" datasource="#application.datasource#">
			SELECT Updated_Date
			FROM BB_Upload_User_Refresh_Date
			WHERE User_ID = <cfqueryParam cfsqltype="cf_sql_varchar" value="#Request.AccessStructure.User_ID#">
		</cfquery>

		<cfreturn qGetBBUploadLastUserRefreshDate>

	</cffunction>

</cfcomponent>
