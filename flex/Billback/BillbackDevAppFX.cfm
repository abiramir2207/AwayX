<!-----------------------------------------------------------------------------

FILE NAME:		BillbackDevAppFX.cfm
DESCRIPTION: This file displays the flex tool for the volume applicator
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
Anand Rao 30-Jul-09 Created 

Arguments:
 returns to calling page
------------------------------------------------------------------------------> 
 
<!--- <CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFPARAM NAME="URL.packetId" 	DEFAULT="">
 --->
<cfparam name="URL.bbid" 	default="">
<cfparam name="URL.UserID" 	default="">
<cfparam name="URL.caller" default="">

<!--- 
Set the BBFlexSource which tells us where the user called this page from and 
make decisions based on that.
--->
<cfif isDefined("SESSION.BBFlexSource")>
  <cfset StructDelete(SESSION,  "BBFlexSource" )>  
</cfif>
<cfset SESSION.BBFlexSource = URL.caller>
<cftry>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
 
<html>
<head>
	<title>Billback Deviations</title>
  <!--- BEGIN Browser History required section --->
  <link rel="stylesheet" type="text/css" href="history/history.css" /> 
  	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
  <!---  END Browser History required section --->
</head>

<!--- This is for 6.0 --->
  <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<!--- <cfset testing = CreateObject("component","mvc.models.Billback.BillbackDevAppManager").getBillbackHeader() />  />
 <cfdump var="#testing#" />
<Cfabort>
 --->

 <!---  
 This is for 5.1
 <cfset appSettings = request.applicationAppSettingsManager.getApplicationAppSettings()> --->
 
  <cfset iAccessError = 0 />
  <cfset strShowError="" />
    <cfset bFlexBBDeviationOn   = appSettings.get_Setting('BB_Deviation_Format') contains 'Flex' ? 1 : 0>
    <cfif bFlexBBDeviationOn EQ 0>
      <cfset iAccessError = 1 />
      <cfset strShowError = "Looks like you have tried to access a page directly typing the URL. The setting switch has been turned off for this page.  <br>
      Kindly contact your System Administrator!!" />
    </cfif>
  <cfif URL.bbid NEQ "">
    <cfset useLakebaseForqryBillbackLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForqryBillbackLocked>
	<cftry>
		<cfset qryBillbackLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_allied", {
				"billback_id" = "eq.#URL.bbid#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryBillbackLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryBillbackLocked>
<cfquery name="qryBillbackLocked" datasource="#application.datasource#">
      SELECT * FROM Billback_Allied
  	  WHERE 
  	  Billback_id = '#URL.bbid#'
    </cfquery>
</cfif>
  <cfelse>
    <cfset iAccessError = 1 />
    <cfset strShowError = "Your Profile does not have access to this functionality!" />
  </cfif>

  <cfset profile = CreateObject("component","components.user.Profile").init() />
  <cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>
<!--- Get_Profile_Settings.BB_VIEW_DEVIATION: <cfoutput>-#Get_Profile_Settings.BB_VIEW_DEVIATION#-</cfoutput><br> --->

  
  <cfif (Get_Profile_Settings.BB_VIEW_DEVIATION NEQ 1)>
    <!--- Profile access is denied if 0 --->
    <cfset iAccessError = 1 />
    <cfset strShowError = "Your Profile does not have access to this functionality!" />
  <cfelse>
    <cfif ((qryBillbackLocked.BB_LOCKED_BY_USER_ID NEQ URL.UserID) AND (qryBillbackLocked.BB_IS_LOCKED EQ 1))>
      <!---     // locked by someone else SHOW ERROR MESSAGE --->
        <cfset iAccessError = 1 />
        <cfset strShowError = " This billback has been locked by another user! Please try later!!" />
        
    <cfelse>
      <!--- 
            conditions: if locked by the current user or not locked by anyone
            TODO: 
                  3) run the deviations
                  4) display the Flex
        ---> 



		
		<cfset useLakebaseForqCheckIfDuplicate = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqCheckIfDuplicate>
	<cftry>
		<cfset qCheckIfDuplicate = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#URL.bbid#",
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
         	WHERE 	Billback_ID = '#URL.bbid#'
        </cfquery>
</cfif>		

		<!--- START: 76536: BB Oper Location Level - dup check --Anand Rao/10-Aug-2018 --->
		<cfset displayOperDupScreen = 0 />		
		<cfif ((appSettings.get_Setting('BB_Oper_Location_Level_Dup_Checker') EQ 1) AND (NOT isDefined("URL.FromDupScreen")) AND (qCheckIfDuplicate.BB_Loc_Duplicate EQ 1))>
			<cfset displayOperDupScreen = 1 />
		</cfif> <!--- <cfif ((appSettings.get_Setting('BB_Oper_Location_Level_Dup_Checker') EQ 1) AND (NOT isDefined("URL.FromDupScreen")))> --->
		
	<cfif (qCheckIfDuplicate.BB_Loc_Duplicate EQ 1)>
		<cfif (appSettings.get_Setting('BB_Oper_Location_Level_Dup_Checker') EQ 1 AND isDefined("URL.FromDupScreen") AND URL.FromDupScreen EQ 1 AND isDefined("FORM.Submitted") AND FORM.Submitted EQ 1)>
 				<!--- Handle for different buttons clicked here --->
				<cfif (isdefined("FORM.actionType") AND FORM.actionType NEQ "")>
					<cfset displayOperDupScreen = 1 />
					<cfswitch expression="#FORM.actionType#">
						<cfcase value="ACCEPT">
							 <cfset useLakebaseForupdBBOperatorLocationAccept = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationAccept>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_operator_location_detail_id" = "eq.#FORM.BillbackOperatorLocationDetailID#"
			},
			{
				"denied" = "0",
				"updated_date" = "#now()#",
				"updated_by" = "#URL.UserID#"
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
									Updated_By = '#URL.UserID#'
					            WHERE Billback_Operator_Location_Detail_ID = #FORM.BillbackOperatorLocationDetailID#
					          </cfquery>
</cfif>
						</cfcase>
						<cfcase value="DENY">
							<cfset useLakebaseForupdBBOperatorLocationDeny = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationDeny>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_operator_location_detail_id" = "eq.#FORM.BillbackOperatorLocationDetailID#"
			},
			{
				"denied" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#URL.UserID#"
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
									Updated_By = '#URL.UserID#'
					            WHERE Billback_Operator_Location_Detail_ID = #FORM.BillbackOperatorLocationDetailID#
					          </cfquery>
</cfif>
						</cfcase>
						<cfcase value="ACCEPTALL">
							<cfset useLakebaseForupdBBOperatorLocationAcceptall = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationAcceptall>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_id" = "eq.#URL.bbid#"
			},
			{
				"denied" = "0",
				"updated_date" = "#now()#",
				"updated_by" = "#URL.UserID#"
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
									Updated_By = '#URL.UserID#'
					            WHERE Billback_ID = '#URL.bbid#'
							</cfquery>
</cfif>
						</cfcase>
						<cfcase value="DENYALL">
							<cfstoredproc procedure="Billback_Operator_Location_Duplicate_Checker" datasource="#application.datasource#">
						    	<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID"   value="#URL.bbid#">
						    		<cfprocresult name="getBBOperLocationDupsDenyAll">  
						    </cfstoredproc>	
							<cfloop query="getBBOperLocationDupsDenyAll">
								<cfset useLakebaseForupdBBOperatorLocationDenyall = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationDenyall>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_id" = "eq.#URL.bbid#",
				"billback_operator_location_detail_id" = "eq.#getBBOperLocationDupsDenyAll.Billback_Operator_Location_Detail_ID#"
			},
			{
				"denied" = "1",
				"updated_date" = "#now()#",
				"updated_by" = "#URL.UserID#"
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
										Updated_By = '#URL.UserID#'
						            WHERE Billback_ID = '#URL.bbid#' AND 
										  Billback_Operator_Location_Detail_ID = '#getBBOperLocationDupsDenyAll.Billback_Operator_Location_Detail_ID#'
								</cfquery>
</cfif>
							</cfloop>
						</cfcase>
						<cfcase value="RESET">
							<cfset useLakebaseForupdBBOperatorLocationReset = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_operator_location_detail")>
<cfif useLakebaseForupdBBOperatorLocationReset>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_operator_location_detail",
			{
				"billback_id" = "eq.#URL.bbid#"
			},
			{
				"denied" = "0",
				"updated_date" = javaCast("null",""),
				"updated_by" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBBOperatorLocationReset = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBBOperatorLocationReset>
<cfquery name="updBBOperatorLocationReset" datasource="#application.datasource#">
					            UPDATE Billback_Operator_Location_Detail 
					            SET 
									Denied = 0,
		  							Updated_date = NULL,
									Updated_By = NULL
					            WHERE Billback_ID = '#URL.bbid#'
							</cfquery>
</cfif>
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
				"billback_id" = "eq.#URL.bbid#",
				"updated_date" = "is.null",
				"updated_by" = "is.null"
			},
			{
				"denied" = "0",
				"updated_date" = "#now()#",
				"updated_by" = "#URL.UserID#"
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
										Updated_By = '#URL.UserID#' 
									WHERE Billback_ID = '#URL.bbid#' AND Updated_date IS NULL AND Updated_By IS NULL
								</cfquery>
</cfif>
							<cfelse>
								<cfquery name="selRowsNotUpdated" datasource="#application.datasource#">
									UPDATE Billback_Operator_Location_Detail 
						            SET 
										Denied = 0,
			  							Updated_date = getdate(),
										Updated_By = '#URL.UserID#' 
									WHERE Billback_ID = '#URL.bbid#' AND Updated_date IS NULL AND Updated_By IS NULL 
										 AND Amount <= #MaxBBOprLocationLevelDupApprovalAmount#
									
									UPDATE Billback_Operator_Location_Detail 
						            SET 
										Denied = 1,
			  							Updated_date = getdate(),
										Updated_By = '#URL.UserID#' 
									WHERE Billback_ID = '#URL.bbid#' AND Updated_date IS NULL AND Updated_By IS NULL 
										 AND Amount > #MaxBBOprLocationLevelDupApprovalAmount#
								</cfquery>
							</cfif>
						</cfcase>
					</cfswitch>
			</cfif> <!--- <cfif (isdefined("FORM.actionType") AND FORM.actionType NEQ "")> --->
		</cfif>
	</cfif> <!--- 	<cfif (qCheckIfDuplicate.BB_Loc_Duplicate EQ 1)> --->
			<!--- 
				Call SP "Billback_Operator_Location_Duplicate_checker" to see, if there are rows returned. If yes, 
				then display the popup with the operator dup check table. Else procedd to Deviation Grid.
		--->
			<cfif displayOperDupScreen EQ 1>
				<cfstoredproc procedure="Billback_Operator_Location_Duplicate_Checker" datasource="#application.datasource#">
		            <cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID"   value="#URL.bbid#">
		    		    <cfprocresult name="getBBOperLocationDups">  
		          </cfstoredproc>	
				<cfif (isDefined("getBBOperLocationDups.RecordCount") AND getBBOperLocationDups.RecordCount GTE 1)>
					<cfinclude template="/Billbacks/Approval/BBOperLocationDupChecker.cfm" />
					<cfabort>
				</cfif> <!--- <cfif (getBBOperLocationDups.RecordCount GTE 1)> --->
			</cfif>	<!--- <cfif displayOperDupScreen EQ 1> --->
		
		
	
 		<!--- END: 76536: BB Oper Location Level - dup check --Anand Rao/10-Aug-2018 --->       
		
		<!--- IF USER VISITS THE DEVIATION SCREEN FROM INSIDE THE BILLBACK --->
		<cfif URL.caller eq "flexBB"><!--- if from inside the billback --->
			<!--- 1) update the record as locked by deviation grid 
			We don't want users making changes to the billback while working with deviation grid
			--->
	        <cfset useLakebaseForupdLockBillback = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForupdLockBillback>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_allied",
			{
				"billback_id" = "eq.#URL.bbid#"
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
	          WHERE  Billback_id = '#URL.bbid#'
	        </cfquery>
</cfif>
		<cfelse>
		<!--- IF USER VISITS THE DEVIATION SCREEN FROM THE BB SEARCH SCREEN --->
			<!--- 2) update all the other records in billbacks not locked through match central as unlocked --->
	        <cfset useLakebaseForunlockLockedBillbacks = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_allied")>
<cfif useLakebaseForunlockLockedBillbacks>
	<cftry>
		<cfset application.oLakebase.updateRows("billback_allied",
			{
				"bb_is_locked" = "eq.1",
				"bb_locked_by_user_id" = "eq.#URL.UserID#",
				"billback_id" = "neq.#URL.bbid#",
				"bb_locked_by_match_central" = "eq.0"
			},
			{
				"bb_is_locked" = "0",
				"bb_locked_by_user_id" = javaCast("null",""),
				"bb_lock_date" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForunlockLockedBillbacks = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForunlockLockedBillbacks>
<cfquery name="unlockLockedBillbacks" datasource="#application.datasource#">
	          UPDATE Billback_Allied
	          SET    BB_Is_Locked = 0,
	                 BB_Locked_By_User_ID = NULL,
	                 BB_Lock_Date = NULL
	          WHERE  BB_Is_Locked = 1 AND
	                 BB_Locked_By_User_ID = '#URL.UserID#' AND   
	                 Billback_id <> '#URL.bbid#' AND
	                 BB_Locked_By_Match_Central = 0
	        </cfquery>
</cfif>
	        
	        <!--- 2) update the record as locked by the current user --->
	        <cfquery name="updLockBillback" datasource="#application.datasource#">
	          UPDATE Billback_Allied
	          SET    BB_Is_Locked = 1,
	                 BB_Locked_By_User_ID = '#URL.UserID#',
	                 BB_Lock_Date = GetDate(),
	                 BB_Locked_By_Deviation_Grid = 1
	          WHERE  Billback_id = '#URL.bbid#'
	        </cfquery>
		</cfif>
        
        <cfset useLakebaseForgetDeviationHistory = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetDeviationHistory>
	<cftry>
		<cfset getDeviationHistory = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#URL.bbid#",
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
         WHERE Billback_ID = '#URL.bbid#'
        </cfquery>
</cfif>
        
		<!--- Tim Ford - 03/28/2016: WR 57983 - Call a function to determine if deviations should run --->
		<cfset oBillbackDevAppManager = CreateObject("component","mvc.Models.Billback.BillbackDevAppManager") />
		<cfset bRunDeviations = oBillbackDevAppManager.checkToRunDeviation(URL.bbid) />
		
        <!--- 3) run the deviations--->
        <!---<cfif (getDeviationHistory.Deviation_Ran_Date EQ "")> --->
		<cfif bRunDeviations>
			<cfset useLakebaseForCheckUpdProgress = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckUpdProgress>
	<cftry>
		<cfset CheckUpdProgress = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#URL.bbid#",
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
				WHERE Billback_ID = '#URL.bbid#'
			</CFQUERY>
</cfif>
		<CFIF CheckUpdProgress.BB_Upd_InProgress EQ 0>	
			<cfset useLakebaseForchkIsBBApproved = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_approved")>
<cfif useLakebaseForchkIsBBApproved>
	<cftry>
		<cfset chkIsBBApproved = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_approved", {
				"billback_id" = "eq.#URL.bbid#"
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
				WHERE Billback_ID = '#URL.bbid#'
			</CFQUERY>
</cfif>
			<cfif ((chkIsBBApproved.RecordCount EQ 0) OR (chkIsBBApproved.Date_Approved EQ ""))>
				<cftry>
					<cflock timeout = "5" 
							type = "Exclusive"
							name = "#session.accessstructure.user_id#_#URL.bbid#" >
				          <cfstoredproc procedure="BB_Deviation_Run_All" datasource="#application.datasource#">
				            <cfprocparam type = "IN" 
				              CFSQLType ="CF_SQL_VARCHAR" 
				              dbVarName = "@Billback_ID"   
				              value="#URL.bbid#">
				    		    <cfprocresult name="getDeviation">  
				          </cfstoredproc>
				          <!--- Update the deviation history that it was run --->
				          <cfquery name="updDeviationHistory" datasource="#application.datasource#">
					            UPDATE Billback 
					            SET Deviation_Ran_By = '#URL.UserID#',
					                Deviation_Ran_Date = getdate()
					            WHERE Billback_ID = '#URL.bbid#'
				          </cfquery>
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
			"billback_id" = "eq.#URL.bbid#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseFordelDeviationHistory = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelDeviationHistory>
<cfquery name="delDeviationHistory" datasource="#application.datasource#">
              DELETE FROM BB_Item_Invoice_Level
              WHERE Billback_ID = '#URL.bbid#'
            </cfquery>
</cfif>
         <cfelse>
            <cfset useLakebaseForUpdBBItemInvoiceLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_item_invoice_level")>
<cfif useLakebaseForUpdBBItemInvoiceLevel>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_item_invoice_level",
			{
				"billback_id" = "eq.#URL.bbid#"
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
              WHERE Billback_ID = '#URL.bbid#'
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
		  	<BR><BR><BR><BR>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD><B><FONT COLOR="Red" SIZE="2"><CFOUTPUT>#UpdMessage#</CFOUTPUT> is in progress. Cannot Run Deviation.</FONT></B></TD>
				</TR>
			</TABLE>
			<CFABORT>
		  </CFIF><!--- <CFIF CheckUpdProgress.BB_Upd_InProgress EQ 0>	 --->
        </cfif>     
      </cfif>
   </cfif> 
    
<cfif (iAccessError EQ 1)>
  <br>
  <br>
    <div align="center"><font color="red"><cfoutput><strong>#strShowError#</strong></cfoutput></font>
    <br>
    <br>
    <input type="button" onclick="javascript:window.close();" title="Close window" value="Close window">
    </div> 
    <br>
    <br>
  <cfelse>    
	  
	  
	  <!---- Check for  ---->
	  <cfset useLakebaseForqGetBillbackInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqGetBillbackInfo>
	<cftry>
		<cfset qGetBillbackInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#URL.bbid#",
				"select" = "validate_bb_uom,validate_bb_uom_failure"
			}), "validate_bb_uom,validate_bb_uom_failure"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetBillbackInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetBillbackInfo>
<cfquery name="qGetBillbackInfo" datasource="#application.datasource#">
		  SELECT Validate_BB_UOM, Validate_BB_UOM_Failure
		  FROM	Billback
		  WHERE	Billback_ID = '#URL.bbid#'
	  </cfquery>
</cfif> 
	  
	  <cfparam name="url.ValidateUOMFailureMsgDisplayed" 	default="0">
	  <cfset bDisplayValidateUOMFailureMsg = 0 />
		
		<!--- Message was not displayed and setting is ON and billback has UOM failure --->
	  <cfif url.ValidateUOMFailureMsgDisplayed NEQ "1" AND qGetBillbackInfo.Validate_BB_UOM EQ "1" AND qGetBillbackInfo.Validate_BB_UOM_Failure EQ "1">
		  <cfset bDisplayValidateUOMFailureMsg = 1 />
	  </cfif>
	
	<!---<cfif url.ValidateUOMFailureMsgDisplayed NEQ "1">
		  <cfset bDisplayValidateUOMFailureMsg = 1 />
	  </cfif>--->
		  
	<cfif bDisplayValidateUOMFailureMsg>
		<cfset vars.qBBLabels = Createobject("component", "components.settings.Labels.Labels").getBillBackLabels("Payable") />
		<cfset vars.payableLabel = Lcase(vars.qBBLabels.Billback_Labels_Desc) />
		<cfif vars.payableLabel eq ""><cfset vars.payableLabel = "payable" /></cfif>
		<br>
		<br>
		<cfoutput>
		<div align="center"><font color="red"><strong>The #lcase(application.returned_customer_setting.item_label)#s on the #vars.payableLabel# have an issue with UOM. Please review the #lcase(application.returned_customer_setting.item_label)#'s UOM to ensure it is correct. </strong></font>
		<br>
		<br>
		<a title="close window" onclick="javascript: window.close();return false;">#application.util.string.LinkFormat("close window")#</a>
		&nbsp;
			
		<!--- Get all the URL variables --->
		 <cfset local.query_string = []>
		 <cfloop collection="#url#" item="local.item">
			 <cfif local.item neq "ValidateUOMFailureMsgDisplayed">
				<cfset arrayAppend(local.query_string, lcase(local.item) & "=" & url[ local.item ])>
			</cfif>
		 </cfloop>
		<cfset arrayAppend(local.query_string, "ValidateUOMFailureMsgDisplayed=1")>
		<cfset local.query_string = arrayToList(local.query_string,'&')>
		<a title="continue" href="BillbackDevAppFX.cfm?#local.query_string#">#application.util.string.LinkFormat("continue")#</a>
		</cfoutput>
		</div> 
		<br>
		<br>
	<cfelse>
    
  <cfscript>
    flashVarsString = 	"";
  </cfscript>

  <cfscript>
	  flashVarsString = 	"userID=" & #URL.UserID# & "&BBID=" & #URL.bbid# & "&source=" & #URL.caller#;
	</cfscript>  
<!---   <cfoutput>#flashVarsString#</cfoutput>  --->

 <!--- LOOKS LIKE BELOW CODE IS NOT BEING USED (START) --->

  <cfquery name="qryBillbackHeader" datasource="#application.datasource#">
     DECLARE	@Payee_Name nvarchar(200)
    
    IF OBJECT_ID('tempdb..##tmp_bb_header') IS NOT NULL
    DROP TABLE ##tmp_bb_header
    
    SELECT	
      Billback.Billback_ID, 
      LTRIM(RTRIM(Billback.BB_Title)) AS BB_Title, 
      CONVERT(VARCHAR(10), Billback.BB_Start_Date, 101) AS BB_Start_Date,
      CONVERT(VARCHAR(10), Billback.BB_End_Date, 101) AS BB_End_Date, 
      Billback.BB_Amount, 
      Billback.BB_Code, 
      CONVERT(VARCHAR(10), Billback.BB_Date, 101) AS BB_Date, 
      Billback.Billback_Status_ID,
    	Billback.Billback_Payee_Type_ID,
		Billback.BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag
    INTO	##tmp_bb_header
    FROM	Billback	
    WHERE 	Billback.Billback_ID = '#URL.BBID#'
    
    -- Payee is distributor
    SELECT	@Payee_Name = BSA_Foodservice_Customers.Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Distributor
    ON	Billback_Distributor.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Distributor.Deleted = 0
    INNER JOIN	BSA_Foodservice_Customers
    ON	Billback_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
    WHERE	Billback_Payee_Type_ID = 1
    
    -- Payee is distributor (unknown)
    SELECT	@Payee_Name = Billback_Distributor.BB_Distributor_Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Distributor
    ON	Billback_Distributor.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Distributor.Deleted = 0
    WHERE	Billback_Payee_Type_ID = 5
    
    -- Payee is operator
    SELECT	@Payee_Name = BSA_Operator.Operator_Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Operator
    ON	Billback_Operator.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Operator.Deleted = 0
    INNER JOIN	BSA_Operator
    ON	Billback_Operator.Operator_ID = BSA_Operator.BSA_Operator_ID
    WHERE	Billback_Payee_Type_ID = 2
    
    -- Payee is operator (unknown)
    SELECT	@Payee_Name = Billback_Operator.BB_Operator_Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Operator
    ON	Billback_Operator.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Operator.Deleted = 0
    WHERE	Billback_Payee_Type_ID = 6
    
    
    -- Payee is broker
    SELECT	@Payee_Name = BSA_Foodservice_Brokers.Broker_Name
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Broker
    ON	Billback_Broker.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Broker.Deleted = 0
    INNER JOIN	BSA_Foodservice_Brokers
    ON	Billback_Broker.Broker_ID = BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID
    WHERE	Billback_Payee_Type_ID = 3
    
    
    -- Payee is broker (unknown)
    SELECT	@Payee_Name = Billback_Broker.BB_Broker_Name 
    FROM	##tmp_bb_header
    INNER JOIN	Billback_Broker
    ON	Billback_Broker.Billback_ID = ##tmp_bb_header.Billback_ID
    AND	Billback_Broker.Deleted = 0
    WHERE	Billback_Payee_Type_ID = 7
    
    
    SELECT 	*, LTRIM(RTRIM(@Payee_Name)) as Payee_Name
    FROM	##tmp_bb_header 
  </cfquery>  


  <cfset iBBDevOverridePrice = appSettings.BB_DEVIATIONS_OVERRIDE_PRICE />
  <cfif qryBillbackHeader.BB_Level_Deviations_Override_Price_Flag EQ 1>
		<cfset iBBDevOverridePrice = 1 />
  </cfif>

  <cfset arrBBDev = ArrayNew(1)>
  <cfset arrBBDev[1] = iBBDevOverridePrice> 
  <cfset addColumn1 = QueryAddColumn(qryBillbackHeader, "BB_DEVIATIONS_OVERRIDE_PRICE", arrBBDev)>
   
  <!---    <cfdump var="#qryBillbackHeader#" />
   <cfabort> 
 BB_DEVIATIONS_OVERRIDE_PRICE-  <cfdump var="#appSettings.BB_DEVIATIONS_OVERRIDE_PRICE#"/>
 <cfdump var="#application.returned_customer_setting#"/> 
 --->


 	<CFSET SHOW_PROGRAM_PNF=0>
	<CFSET SHOW_PROGRAM_UN_AUTH_PAYEE=0>
	<CFSET SHOW_PROGRAM_DATE_MISMATCH=0>
	<CFSET SHOW_DISCOUNT_DATE_OVERLAP=0>
	<CFSET SHOW_DISCOUNT_RATE="">
	<CFSET SHOW_DISCOUNT_VOLUME="">    
<cfif isDefined("url.showCountNoCount")>
	<cfset showCountNoCount = url.showCountNoCount />
<cfelse>
	<cfset showCountNoCount = 0 />
</cfif>  
 <!--- LOOKS LIKE ABOVE CODE IS NOT BEING USED (END) --->
 
	<script type='text/javascript'>	
	   	_ajaxConfig = {'_cfscriptLocation':'/components/billback/BillbackAjaxManager.cfc','_jsscriptFolder':'/script/javascript/Ajax_JS/','debug':false};
	</script>
	<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>	  

    <script src="/flex/AC_OETags.js" language="javascript"></script> 
    <!--  BEGIN Browser History required section -->
    <script src="/flex/history/history.js" language="javascript"></script>
    <!--  END Browser History required section --> 
    <style> 
    body { margin: 0px; overflow:hidden }
    </style>
    <script language="JavaScript" type="text/javascript"> 
    <!--
    // -----------------------------------------------------------------------------
    // Globals
    // Major version of Flash required
    var requiredMajorVersion = 9;
    // Minor version of Flash required
    var requiredMinorVersion = 0;
    // Minor version of Flash required
    var requiredRevision = 28;
    // -----------------------------------------------------------------------------
    // -->
	
	function unlockBillback()
	{
		DWREngine.setAsync(false);
		<cfoutput>
		DWREngine._execute(
				_ajaxConfig._cfscriptLocation, 
				null, 
				'unlockBillback', 
				'#URL.bbid#', 
				'#URL.UserID#', 
				1, 
				functionResponse);
		</cfoutput>
	}
	
	function unlockDeviationGridLock()
	{
		DWREngine.setAsync(false);
		<cfoutput>
		DWREngine._execute(
				_ajaxConfig._cfscriptLocation, 
				null, 
				'unlockDeviationGridLock', 
				'#URL.bbid#',
				'#URL.UserID#',
				functionResponse);
		</cfoutput>
	}
	
	function functionResponse(response) 
	{
		// do nothing		
	}
	
	function refreshParent() 
	{
		var i = window.opener.location.href.indexOf('&filterIds');
		var n = window.opener.location.href.length;
		var str = window.opener.location.href.substring(i, n);
		window.opener.location.href.replace(str, '');
		
		window.opener.location.href += "&filterIds=<cfoutput>#URL.bbid#</cfoutput>";
				
	}
	
    </script>
    </head>
    <body scroll="no"  onbeforeunload="javascript: unlockDeviationGridLock();">
	
	<script language="JavaScript" type="text/javascript">
	
	/* Check whether "flash" is installed.
	Note: A user was having an issue with the old code on Windows 10 machine, so the older code was removed.
	older code also seems unnecessary since nowadays users should see an appropriate message when flash is not installed.
	There is also no need to check the Flash version as everyone has the  minimum of Flash version 9.
	In fact, as of today the latest version of Flash is version 25.
	*/
	var hasFlashPluginEnabled = true;
	function hasFlash()
	{
	var hasFlash = false;
	
		try {
		  var fo = new ActiveXObject('ShockwaveFlash.ShockwaveFlash');
		  if (fo) {
			hasFlash = true;
		  }
		} catch (e) {
		  if (navigator.mimeTypes
				&& navigator.mimeTypes['application/x-shockwave-flash'] != undefined
				) {
			hasFlash = true;
		  }
		}
		return hasFlash;
	}

    var hasProductInstall =  hasFlash(); /* DetectFlashVer(6, 0, 65); */

	if (hasProductInstall) {
    	// if we've detected an acceptable version
    	// embed the Flash Content SWF when all tests are passed
      ///FlexDev/BillbackDevApp/bin-debug/BillbackDevApp -- EARLIER
    	AC_FL_RunContent(
    			"src", "/flex/Billback/BillbackDevApp",
          "FlashVars", "<cfoutput>#flashVarsString#</cfoutput>",
    			"width", "100%",
    			"height", "100%",
    			"align", "middle",
    			"id", "BillbackDevApp",
    			"quality", "high",
    			"bgcolor", "#869ca7",
    			"name", "BillbackDevApp",
    			"allowScriptAccess","sameDomain",
    			"type", "application/x-shockwave-flash",
    			"pluginspage", "http://www.adobe.com/go/getflashplayer"
    	);
      } else {  // no flash or we cant detect the plugin
        var alternateContent = 'Alternate HTML content should be placed here. '
      	+ 'This content requires the Adobe Flash Player. '
       	+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
        document.write(alternateContent);  // insert non-flash content
      }
    </script>
    <noscript>
      	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
    			id="BillbackDevApp" width="100%" height="100%"
    			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
    			<param name="movie" value="BillbackDevApp.swf" />
    			<param name="quality" value="high" />
    			<param name="bgcolor" value="#869ca7" />
    			<param name="allowScriptAccess" value="sameDomain" />
    			<embed src="/flex/Billback/BillbackDevApp.swf" quality="high" bgcolor="#869ca7"
    				width="100%" height="100%" name="VolumeApplicator" align="middle"
    				play="true"
    				loop="false"
    				quality="high"
    				allowScriptAccess="sameDomain"
    				type="application/x-shockwave-flash"
    				pluginspage="http://www.adobe.com/go/getflashplayer">
    			</embed>
    	</object>
    </noscript>
    
  </body>

</cfif>	<!--- <cfif Validate_BB_UOM_Failure> --->
</cfif> <!--- <cfif (iAccessError EQ 1)> --->

</html>

<cfcatch>
	<cfquery name="updLockBillback" datasource="#application.datasource#">
	  UPDATE Billback_Allied
	  SET    BB_Locked_By_Deviation_Grid = 0
	  WHERE  Billback_id = '#URL.bbid#'
	</cfquery>
	 <cfrethrow />
</cfcatch>

</cftry>