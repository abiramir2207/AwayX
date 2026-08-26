 <!---
* ==================================================================================================== 
* @Remarks: The code on this file has been taken from "flex\billback\BillbackDevAppFX.cfm".
* ==================================================================================================== 
--->
<cfset appSettings = application.appSettingsGet />

<cfif appSettings.get_Setting('BB_Deviation_Format') eq 'Flex'>
	<br><br><br><br>
	<div align="center">
	<span style="color:red;font-size:12px;">Looks like you have tried to access a page directly typing the URL. The setting switch has been turned off for this page. <br>
		Kindly contact your System Administrator!!
	</span>
	</div>
	<cfabort>
</cfif>

<cffunction name="showDeviationScreen" output="false" returntype="struct">
    <cfargument name="bbid" required="true"> 
    <cfargument name="FromDupScreen" default="0" />
	<cfargument name="Submitted" default="0" />
	<cfargument name="caller" default="" />
	<cfargument name="actionType" default="" />
	<cfargument name="BillbackOperatorLocationDetailID" default="" />
	
	<cfset var iAccessError = 0 />
	<cfset var strShowError = "" />
	<cfset var UpdMessage = "" />
	<cfset var displayOperDupScreen = 0 />
	<cfset var strValidate = structNew()>
	<cfset var appSettings = application.appSettingsGet />

	<!--- 
	Set the BBAgGridSource which tells us where the user called this page from and make decisions based on that.
	"SESSION.BBFlexSource" was originally added for flex deviation screen. Here a similar variable called "SESSION.BBAgGridSource" is being used.
	---->
	<cfif isDefined("SESSION.BBAgGridSource")>
	  <cfset StructDelete(SESSION,  "BBAgGridSource" )>  
	</cfif>
	<cfset SESSION.BBAgGridSource = arguments.caller>

	<cftry>

	<cfif appSettings.get_Setting('BB_Deviation_Format') eq 'Flex'>
		<cfset iAccessError = 1 />
		<cfset strShowError = "Looks like you have tried to access a page directly typing the URL. The setting switch has been turned off for this page.  <br>
		Kindly contact your System Administrator!!" />
	</cfif>

	<cfset useLakebaseForqryBillbackLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForqryBillbackLocked>
	<cftry>
		<cfset qryBillbackLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_allied", {
				"billback_id" = "eq.#arguments.bbid#",
				"select" = "bb_locked_by_user_id,bb_is_locked"
			}), "bb_locked_by_user_id,bb_is_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryBillbackLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryBillbackLocked>
<cfquery name="qryBillbackLocked" datasource="#application.datasource#">
	SELECT BB_LOCKED_BY_USER_ID,BB_IS_LOCKED 
	FROM Billback_Allied
	WHERE Billback_id = '#arguments.bbid#'
	</cfquery>
</cfif>

	<cfset profile = CreateObject("component","components.user.Profile").init() />
	<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>
  
	<cfif (Get_Profile_Settings.BB_VIEW_DEVIATION NEQ 1)>
		<cfset iAccessError = 1 />
		<cfset strShowError = "Your Profile does not have access to this functionality!" />
	<cfelse>

	<cfif ((qryBillbackLocked.BB_LOCKED_BY_USER_ID NEQ request.AccessStructure.User_ID) AND (qryBillbackLocked.BB_IS_LOCKED EQ 1))>
		<!--- // locked by someone else SHOW ERROR MESSAGE --->
		<cfset iAccessError = 1 />
		<cfset strShowError = " This billback has been locked by another user! Please try later!!" /> 
    <cfelse>

	<cfset useLakebaseForqCheckIfDuplicate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqCheckIfDuplicate>
	<cftry>
		<cfset qCheckIfDuplicate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.bbid#",
				"select" = "bb_loc_duplicate"
			}), "bb_loc_duplicate"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckIfDuplicate = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckIfDuplicate>
<cfquery name="qCheckIfDuplicate" datasource="#application.datasource#">
		SELECT	BB_Loc_Duplicate
		FROM 	Billback                
		WHERE 	Billback_ID = '#arguments.bbid#'
	</cfquery>
</cfif>

	<!--- START: 76536: BB Oper Location Level - dup check --Anand Rao/10-Aug-2018
	Note: On "flex\billback\BillbackDevAppFX.cfm" (where the code is copied from), we use "NOT isDefined("URL.FromDupScreen")", 
	but here we will use "arguments.FromDupScreen eq 0".It will do the same thing. We cannot use "NOT isDefined("URL.FromDupScreen")" here, 
	as "URL.FromDupScreen" will always be defined. It's default value will be 0.
	--->
	<cfif ((appSettings.get_Setting('BB_Oper_Location_Level_Dup_Checker') EQ 1) AND (arguments.FromDupScreen eq 0) AND (qCheckIfDuplicate.BB_Loc_Duplicate EQ 1))>
		<cfset displayOperDupScreen = 1 />
	</cfif>
		
	<cfif (qCheckIfDuplicate.BB_Loc_Duplicate EQ 1)>
		<cfif (appSettings.get_Setting('BB_Oper_Location_Level_Dup_Checker') EQ 1 AND arguments.FromDupScreen EQ 1 AND arguments.Submitted EQ 1)>
 				<!--- Handle for different buttons clicked here --->
				<cfif arguments.actionType NEQ "">
					<cfset displayOperDupScreen = 1 />
					<cfswitch expression="#arguments.actionType#">
						<cfcase value="ACCEPT">
							 <cfset useLakebaseForupdBBOperatorLocationAccept = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationAccept>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_operator_location_detail_id" = "eq.#arguments.BillbackOperatorLocationDetailID#"
			},
			{
				"denied" = "0",
				"updated_date" = "#now()#",
				"updated_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBBOperatorLocationAccept = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBBOperatorLocationAccept>
<cfquery name="updBBOperatorLocationAccept" datasource="#application.datasource#">
					            UPDATE Billback_Operator_Location_Detail 
					            SET 
									Denied = 0,
		  							Updated_date = getdate(),
									Updated_By = '#request.AccessStructure.User_ID#'
					            WHERE Billback_Operator_Location_Detail_ID = #arguments.BillbackOperatorLocationDetailID#
					          </cfquery>
</cfif>
						</cfcase>
						<cfcase value="DENY">
							<cfset useLakebaseForupdBBOperatorLocationDeny = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationDeny>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_operator_location_detail_id" = "eq.#arguments.BillbackOperatorLocationDetailID#"
			},
			{
				"denied" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBBOperatorLocationDeny = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBBOperatorLocationDeny>
<cfquery name="updBBOperatorLocationDeny" datasource="#application.datasource#">
					            UPDATE Billback_Operator_Location_Detail 
					            SET 
									Denied = 1,
		  							Updated_date = getdate(),
									Updated_By = '#request.AccessStructure.User_ID#'
					            WHERE Billback_Operator_Location_Detail_ID = #arguments.BillbackOperatorLocationDetailID#
					          </cfquery>
</cfif>
						</cfcase>
						<cfcase value="ACCEPTALL">
							<cfset useLakebaseForupdBBOperatorLocationAcceptall = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationAcceptall>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_id" = "eq.#arguments.bbid#"
			},
			{
				"denied" = "0",
				"updated_date" = "#now()#",
				"updated_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBBOperatorLocationAcceptall = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBBOperatorLocationAcceptall>
<cfquery name="updBBOperatorLocationAcceptall" datasource="#application.datasource#">
					            UPDATE Billback_Operator_Location_Detail 
					            SET 
									Denied = 0,
		  							Updated_date = getdate(),
									Updated_By = '#request.AccessStructure.User_ID#'
					            WHERE Billback_ID = '#arguments.bbid#'
							</cfquery>
</cfif>
						</cfcase>
						<cfcase value="DENYALL">
							<cfstoredproc procedure="Billback_Operator_Location_Duplicate_Checker" datasource="#application.datasource#">
						    	<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID"   value="#arguments.bbid#">
						    		<cfprocresult name="getBBOperLocationDupsDenyAll">  
						    </cfstoredproc>	
							<cfloop query="getBBOperLocationDupsDenyAll">
								<cfset useLakebaseForupdBBOperatorLocationDenyall = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationDenyall>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_id" = "eq.#arguments.bbid#",
				"billback_operator_location_detail_id" = "eq.#getBBOperLocationDupsDenyAll.Billback_Operator_Location_Detail_ID#"
			},
			{
				"denied" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBBOperatorLocationDenyall = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBBOperatorLocationDenyall>
<cfquery name="updBBOperatorLocationDenyall" datasource="#application.datasource#">
						            UPDATE Billback_Operator_Location_Detail 
						            SET 
										Denied = 1,
			  							Updated_date = getdate(),
										Updated_By = '#request.AccessStructure.User_ID#'
						            WHERE Billback_ID = '#arguments.bbid#' AND 
										  Billback_Operator_Location_Detail_ID = '#getBBOperLocationDupsDenyAll.Billback_Operator_Location_Detail_ID#'
								</cfquery>
</cfif>
							</cfloop>
						</cfcase>
						<cfcase value="RESET">
							<cfquery name="updBBOperatorLocationReset" datasource="#application.datasource#">
					            UPDATE Billback_Operator_Location_Detail 
					            SET 
									Denied = 0,
		  							Updated_date = NULL,
									Updated_By = NULL
					            WHERE Billback_ID = '#arguments.bbid#'
							</cfquery>
						</cfcase>
						<cfcase value="GOTODEV">
							<cfset displayOperDupScreen = 0 />
							<cfset MaxBBOprLocationLevelDupApprovalAmount = Get_Profile_Settings.Max_BB_Oper_Location_Level_Dup_Approval_Amount />							
							<cfif MaxBBOprLocationLevelDupApprovalAmount EQ "*">
								<cfset CanAcceptAll = 1 />
							<cfelseif MaxBBOprLocationLevelDupApprovalAmount EQ "0">	
								<cfset CanAcceptAll = 0 />
							<cfelse>
								<cfloop query="getBBOperLocationDups">
									<cfif MaxBBOprLocationLevelDupApprovalAmount GTE getBBOperLocationDups.Dup_Loc_Claimed_Amount>
										<cfset CanAcceptAll = 1 />
									<cfelse>
										<cfset CanAcceptAll = 0 />
										<cfbreak />
									</cfif>
								 </cfloop>
							</cfif>	
							<cfif (CanAcceptAll EQ 1)>
								<cfset useLakebaseForselRowsUpdatedAcceptAll = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForselRowsUpdatedAcceptAll>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_id" = "eq.#arguments.bbid#",
				"updated_date" = "is.null",
				"updated_by" = "is.null"
			},
			{
				"denied" = "0",
				"updated_date" = "#now()#",
				"updated_by" = "#request.AccessStructure.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForselRowsUpdatedAcceptAll = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForselRowsUpdatedAcceptAll>
<cfquery name="selRowsUpdatedAcceptAll" datasource="#application.datasource#">
									UPDATE Billback_Operator_Location_Detail 
						            SET 
										Denied = 0,
			  							Updated_date = getdate(),
										Updated_By = '#request.AccessStructure.User_ID#' 
									WHERE Billback_ID = '#arguments.bbid#' AND Updated_date IS NULL AND Updated_By IS NULL
								</cfquery>
</cfif>
							<cfelse>
								<cfquery name="selRowsNotUpdated" datasource="#application.datasource#">
									UPDATE Billback_Operator_Location_Detail 
						            SET 
										Denied = 0,
			  							Updated_date = getdate(),
										Updated_By = '#request.AccessStructure.User_ID#' 
									WHERE Billback_ID = '#arguments.bbid#' AND Updated_date IS NULL AND Updated_By IS NULL 
										 AND Amount <= #MaxBBOprLocationLevelDupApprovalAmount#
									
									UPDATE Billback_Operator_Location_Detail 
						            SET 
										Denied = 1,
			  							Updated_date = getdate(),
										Updated_By = '#request.AccessStructure.User_ID#' 
									WHERE Billback_ID = '#arguments.bbid#' AND Updated_date IS NULL AND Updated_By IS NULL 
										 AND Amount > #MaxBBOprLocationLevelDupApprovalAmount#
								</cfquery>
							</cfif>
						</cfcase>
					</cfswitch>
			</cfif> <!--- <cfif (isdefined("arguments.actionType") AND arguments.actionType NEQ "")> --->
		</cfif>
	</cfif> <!--- 	<cfif (qCheckIfDuplicate.BB_Loc_Duplicate EQ 1)> --->

	<!--- 
		Call SP "Billback_Operator_Location_Duplicate_checker" to see, if there are rows returned. If yes, 
		then display the popup with the operator dup check table. Else procedd to Deviation Grid.
	--->
	<cfif displayOperDupScreen EQ 1>
		<cfstoredproc procedure="Billback_Operator_Location_Duplicate_Checker" datasource="#application.datasource#">
			<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID"   value="#arguments.bbid#">
				<cfprocresult name="getBBOperLocationDups">  
		  </cfstoredproc>	
		<cfif (isDefined("getBBOperLocationDups.RecordCount") AND getBBOperLocationDups.RecordCount GTE 1)>
			<cfinclude template="/Billbacks/Approval/BBOperLocationDupChecker.cfm" />
			<cfabort>
		</cfif> <!--- <cfif (getBBOperLocationDups.RecordCount GTE 1)> --->
	</cfif>	<!--- <cfif displayOperDupScreen EQ 1> --->
		
 	<!--- END: 76536: BB Oper Location Level - dup check --Anand Rao/10-Aug-2018 ---> 

	<cfif arguments.caller eq "AgGridBB"><!--- if from inside the billback --->
		<!--- 1) update the record as locked by deviation grid 
		We don't want users making changes to the billback while working with deviation grid
		--->
		<cfset useLakebaseForupdLockBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForupdLockBillback>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_allied",
			{
				"billback_id" = "eq.#arguments.bbid#"
			},
			{
				"bb_locked_by_deviation_grid" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdLockBillback = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdLockBillback>
<cfquery name="updLockBillback" datasource="#application.datasource#">
		  UPDATE Billback_Allied
		  SET    BB_Locked_By_Deviation_Grid = 1
		  WHERE  Billback_id = '#arguments.bbid#'
		</cfquery>
</cfif>
	<cfelse>
		<!--- 2) update all the other records in billbacks not locked through match central as unlocked --->
		<cfquery name="unlockLockedBillbacks" datasource="#application.datasource#">
		  UPDATE Billback_Allied
		  SET    BB_Is_Locked = 0,
				 BB_Locked_By_User_ID = NULL,
				 BB_Lock_Date = NULL
		  WHERE  BB_Is_Locked = 1 AND
				 BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#' AND   
				 Billback_id <> '#arguments.bbid#' AND
				 BB_Locked_By_Match_Central = 0
		</cfquery>
		
		<!--- 2) update the record as locked by the current user --->
		<cfquery name="updLockBillback" datasource="#application.datasource#">
		  UPDATE Billback_Allied
		  SET    BB_Is_Locked = 1,
				 BB_Locked_By_User_ID = '#request.AccessStructure.User_ID#',
				 BB_Lock_Date = GetDate(),
				 BB_Locked_By_Deviation_Grid = 1
		  WHERE  Billback_id = '#arguments.bbid#'
		</cfquery>
	</cfif>
        
	<cfset useLakebaseForgetDeviationHistory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetDeviationHistory>
	<cftry>
		<cfset getDeviationHistory = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.bbid#",
				"select" = "deviation_ran_by,deviation_ran_date,uploaded_billback,billback_status_id,bb_deviations_override_price as bb_level_deviations_override_price_flag"
			}), "deviation_ran_by,deviation_ran_date,uploaded_billback,billback_status_id,bb_deviations_override_price as bb_level_deviations_override_price_flag"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetDeviationHistory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetDeviationHistory>
<cfquery name="getDeviationHistory" datasource="#application.datasource#">
	 SELECT Deviation_Ran_By,
			Deviation_Ran_Date,
			Uploaded_Billback,
			Billback_Status_ID,
			Billback.BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag
	 FROM Billback                
	 WHERE Billback_ID = '#arguments.bbid#'
	</cfquery>
</cfif>
	
	<!--- Tim Ford - 03/28/2016: WR 57983 - Call a function to determine if deviations should run --->
	<cfset oBillbackDevAppManager = CreateObject("component","mvc.Models.Billback.BillbackDevAppManager") />
	<cfset bRunDeviations = oBillbackDevAppManager.checkToRunDeviation(arguments.bbid) />
		
	<!--- 3) run the deviations--->
	<!---<cfif (getDeviationHistory.Deviation_Ran_Date EQ "")> --->
	<cfif bRunDeviations>
		<cfset useLakebaseForCheckUpdProgress = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckUpdProgress>
	<cftry>
		<cfset CheckUpdProgress = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.bbid#",
				"select" = "bb_upd_inprogress"
			}), "bb_upd_inprogress"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckUpdProgress = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckUpdProgress>
<CFQUERY NAME="CheckUpdProgress" datasource="#application.datasource#">
			SELECT BB_Upd_InProgress
			FROM Billback
			WHERE Billback_ID = '#arguments.bbid#'
		</CFQUERY>
</cfif>
		<CFIF CheckUpdProgress.BB_Upd_InProgress EQ 0>	
			<cfset useLakebaseForchkIsBBApproved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_approved")>
<cfif useLakebaseForchkIsBBApproved>
	<cftry>
		<cfset chkIsBBApproved = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_approved", {
				"billback_id" = "eq.#arguments.bbid#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForchkIsBBApproved = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForchkIsBBApproved>
<CFQUERY NAME="chkIsBBApproved" datasource="#application.datasource#">
				SELECT *
				FROM BB_Approved
				WHERE Billback_ID = '#arguments.bbid#'
			</CFQUERY>
</cfif>
			<cfif ((chkIsBBApproved.RecordCount EQ 0) OR (chkIsBBApproved.Date_Approved EQ ""))>
				<cftry>
					<cflock timeout="5" type="Exclusive" name="#request.accessstructure.user_id#_#arguments.bbid#">
				          <cfstoredproc procedure="BB_Deviation_Run_All" datasource="#application.datasource#">
							<cfprocparam type = "IN" 
							  	CFSQLType ="CF_SQL_VARCHAR" 
							  	dbVarName = "@Billback_ID"   
							  	value="#arguments.bbid#">
							<cfprocresult name="getDeviation">  
						</cfstoredproc>
						<!--- Update the deviation history that it was run --->
						<cfset useLakebaseForupdDeviationHistory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForupdDeviationHistory>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#arguments.bbid#"
			},
			{
				"deviation_ran_by" = "#request.AccessStructure.User_ID#",
				"deviation_ran_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdDeviationHistory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdDeviationHistory>
<cfquery name="updDeviationHistory" datasource="#application.datasource#">
							UPDATE Billback 
							SET Deviation_Ran_By = '#request.AccessStructure.User_ID#',
								Deviation_Ran_Date = getdate()
							WHERE Billback_ID = '#arguments.bbid#'
						</cfquery>
</cfif>
				   </cflock>
					<cfcatch>
						<cfif cfcatch.type EQ 'LOCK'>
							<cfset  iAccessError = 1>
							<cfset strShowError = "Deviations are currently executing for this billback.  Please check back shortly to see if it has completed.">
							<!--- <cfdump var='#session.accessstructure.user_id#'/><br>
							<cfdump var="#cfcatch.type#">  --->
						<cfelse>
							<cfrethrow/>
						</cfif>
					</cfcatch>
				</cftry>
			</cfif>
			<!---
			Rules for deleting entries from BB_Item_Invoice_Level
			For client who do not allow editing of claimed amount and claimed quantity, only delete for WIP/RFA billbacks which are not third party upload 
			For client who allow editing of claimed amount and claimed quantity, delete for any WIP/RFA billbacks
			--->
			  <cfif 
				NOT(
					(getDeviationHistory.Uploaded_Billback EQ 3 
					AND (appSettings.getBB_Upload_III_P_Qty_Amt_Editable() EQ 0 OR getDeviationHistory.BB_Level_Deviations_Override_Price_Flag EQ 1))
					OR 
					(getDeviationHistory.Uploaded_Billback EQ 2 
					AND (appSettings.getEditableClaimedDollarsQuantity() EQ 0 OR getDeviationHistory.BB_Level_Deviations_Override_Price_Flag EQ 1))

					)
				 AND getDeviationHistory.Billback_Status_ID LT 3>
				<cfset useLakebaseFordelDeviationHistory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_item_invoice_level")>
<cfif useLakebaseFordelDeviationHistory>
	<cftry>
		<cfset application.oLakebase.deleteRows("bb_item_invoice_level", {
			"billback_id" = "eq.#arguments.bbid#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelDeviationHistory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelDeviationHistory>
<cfquery name="delDeviationHistory" datasource="#application.datasource#">
				  DELETE FROM BB_Item_Invoice_Level
				  WHERE Billback_ID = '#arguments.bbid#'
				</cfquery>
</cfif>
			 <cfelse>
				<cfset useLakebaseForUpdBBItemInvoiceLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_item_invoice_level")>
<cfif useLakebaseForUpdBBItemInvoiceLevel>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_item_invoice_level",
			{
				"billback_id" = "eq.#arguments.bbid#"
			},
			{
				"volume_override" = "0",
				"rate_override" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdBBItemInvoiceLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdBBItemInvoiceLevel>
<cfquery name="UpdBBItemInvoiceLevel" datasource="#application.datasource#">
				  UPDATE BB_Item_Invoice_Level
				  SET Volume_Override = 0,
				  Rate_Override = 0
				  WHERE Billback_ID = '#arguments.bbid#'
				</cfquery>
</cfif>            
			  </cfif>
		<CFELSE>
			<CFIF CheckUpdProgress.BB_Upd_InProgress EQ 1>
				<CFSET UpdMessage = "Basic Info update">
			<CFELSEIF CheckUpdProgress.BB_Upd_InProgress EQ 2>
				<CFSET UpdMessage = "Payee Update">
			<CFELSEIF CheckUpdProgress.BB_Upd_InProgress EQ 3>
				<CFSET UpdMessage = "Program Update">
			<CFELSEIF CheckUpdProgress.BB_Upd_InProgress EQ 4>
				<CFSET UpdMessage = "Switch Program">
			<CFELSEIF CheckUpdProgress.BB_Upd_InProgress EQ 5>
				<CFSET UpdMessage = "Switch Product">
			</CFIF>
		</CFIF><!--- <CFIF CheckUpdProgress.BB_Upd_InProgress EQ 0>	 --->
        </cfif>     
      </cfif>
   </cfif> 

	<cfset strValidate.iAccessError = iAccessError>
	<cfset strValidate.UpdMessage = UpdMessage>
	<cfset strValidate.strShowError = strShowError>
s
	<cfcatch>
		<cfquery name="updLockBillback" datasource="#application.datasource#">
		  UPDATE Billback_Allied
		  SET    BB_Locked_By_Deviation_Grid = 0
		  WHERE  Billback_id = '#arguments.bbid#'
		</cfquery>
		 <cfrethrow />
	</cfcatch>

	</cftry>

	<cfreturn strValidate />
		
</cffunction>