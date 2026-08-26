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

	<cfquery name="qryBillbackLocked" datasource="#application.datasource#">
	SELECT BB_LOCKED_BY_USER_ID,BB_IS_LOCKED 
	FROM Billback_Allied
	WHERE Billback_id = '#arguments.bbid#'
	</cfquery>

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

	<cfquery name="qCheckIfDuplicate" datasource="#application.datasource#">
		SELECT	BB_Loc_Duplicate
		FROM 	Billback                
		WHERE 	Billback_ID = '#arguments.bbid#'
	</cfquery>

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
							 <cfquery name="updBBOperatorLocationAccept" datasource="#application.datasource#">
					            UPDATE Billback_Operator_Location_Detail 
					            SET 
									Denied = 0,
		  							Updated_date = getdate(),
									Updated_By = '#request.AccessStructure.User_ID#'
					            WHERE Billback_Operator_Location_Detail_ID = #arguments.BillbackOperatorLocationDetailID#
					          </cfquery>
						</cfcase>
						<cfcase value="DENY">
							<cfquery name="updBBOperatorLocationDeny" datasource="#application.datasource#">
					            UPDATE Billback_Operator_Location_Detail 
					            SET 
									Denied = 1,
		  							Updated_date = getdate(),
									Updated_By = '#request.AccessStructure.User_ID#'
					            WHERE Billback_Operator_Location_Detail_ID = #arguments.BillbackOperatorLocationDetailID#
					          </cfquery>
						</cfcase>
						<cfcase value="ACCEPTALL">
							<cfquery name="updBBOperatorLocationAcceptall" datasource="#application.datasource#">
					            UPDATE Billback_Operator_Location_Detail 
					            SET 
									Denied = 0,
		  							Updated_date = getdate(),
									Updated_By = '#request.AccessStructure.User_ID#'
					            WHERE Billback_ID = '#arguments.bbid#'
							</cfquery>
						</cfcase>
						<cfcase value="DENYALL">
							<cfstoredproc procedure="Billback_Operator_Location_Duplicate_Checker" datasource="#application.datasource#">
						    	<cfprocparam type = "IN" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@Billback_ID"   value="#arguments.bbid#">
						    		<cfprocresult name="getBBOperLocationDupsDenyAll">  
						    </cfstoredproc>	
							<cfloop query="getBBOperLocationDupsDenyAll">
								<cfquery name="updBBOperatorLocationDenyall" datasource="#application.datasource#">
						            UPDATE Billback_Operator_Location_Detail 
						            SET 
										Denied = 1,
			  							Updated_date = getdate(),
										Updated_By = '#request.AccessStructure.User_ID#'
						            WHERE Billback_ID = '#arguments.bbid#' AND 
										  Billback_Operator_Location_Detail_ID = '#getBBOperLocationDupsDenyAll.Billback_Operator_Location_Detail_ID#'
								</cfquery>
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
								<cfquery name="selRowsUpdatedAcceptAll" datasource="#application.datasource#">
									UPDATE Billback_Operator_Location_Detail 
						            SET 
										Denied = 0,
			  							Updated_date = getdate(),
										Updated_By = '#request.AccessStructure.User_ID#' 
									WHERE Billback_ID = '#arguments.bbid#' AND Updated_date IS NULL AND Updated_By IS NULL
								</cfquery>
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
		<cfquery name="updLockBillback" datasource="#application.datasource#">
		  UPDATE Billback_Allied
		  SET    BB_Locked_By_Deviation_Grid = 1
		  WHERE  Billback_id = '#arguments.bbid#'
		</cfquery>
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
        
	<cfquery name="getDeviationHistory" datasource="#application.datasource#">
	 SELECT Deviation_Ran_By,
			Deviation_Ran_Date,
			Uploaded_Billback,
			Billback_Status_ID,
			Billback.BB_Deviations_Override_Price as BB_Level_Deviations_Override_Price_Flag
	 FROM Billback                
	 WHERE Billback_ID = '#arguments.bbid#'
	</cfquery>
	
	<!--- Tim Ford - 03/28/2016: WR 57983 - Call a function to determine if deviations should run --->
	<cfset oBillbackDevAppManager = CreateObject("component","mvc.Models.Billback.BillbackDevAppManager") />
	<cfset bRunDeviations = oBillbackDevAppManager.checkToRunDeviation(arguments.bbid) />
		
	<!--- 3) run the deviations--->
	<!---<cfif (getDeviationHistory.Deviation_Ran_Date EQ "")> --->
	<cfif bRunDeviations>
		<CFQUERY NAME="CheckUpdProgress" datasource="#application.datasource#">
			SELECT BB_Upd_InProgress
			FROM Billback
			WHERE Billback_ID = '#arguments.bbid#'
		</CFQUERY>
		<CFIF CheckUpdProgress.BB_Upd_InProgress EQ 0>	
			<CFQUERY NAME="chkIsBBApproved" datasource="#application.datasource#">
				SELECT *
				FROM BB_Approved
				WHERE Billback_ID = '#arguments.bbid#'
			</CFQUERY>
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
						<cfquery name="updDeviationHistory" datasource="#application.datasource#">
							UPDATE Billback 
							SET Deviation_Ran_By = '#request.AccessStructure.User_ID#',
								Deviation_Ran_Date = getdate()
							WHERE Billback_ID = '#arguments.bbid#'
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
				<cfquery name="delDeviationHistory" datasource="#application.datasource#">
				  DELETE FROM BB_Item_Invoice_Level
				  WHERE Billback_ID = '#arguments.bbid#'
				</cfquery>
			 <cfelse>
				<cfquery name="UpdBBItemInvoiceLevel" datasource="#application.datasource#">
				  UPDATE BB_Item_Invoice_Level
				  SET Volume_Override = 0,
				  Rate_Override = 0
				  WHERE Billback_ID = '#arguments.bbid#'
				</cfquery>            
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