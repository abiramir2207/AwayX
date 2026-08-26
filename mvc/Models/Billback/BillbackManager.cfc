<cfcomponent extends="mvc.Models.SettingsService">
	<cfset appSettings = application.appSettingsGet />


	<cfscript>
		variables.oBillbackDAO = CreateObject("component","mvc.Models.Billback.BillbackDAO");
	</cfscript>

	<cffunction name="init" output="false" returntype="mvc.Models.Billback.BillbackManager">

		<cfreturn this />

	</cffunction>

	<cffunction name="checkBBEligibleForDeleteJSON" output="false" returntype="string" returnformat="JSON" access="remote">

		<cfargument name="userId" type="string" required="true"><!--- default="00000000-9999-9999-0000000000000000" --->
		<cfargument name="billbackList" type="string" required="true">

		<cfscript>
			var a = arguments;
			var b = this.checkBBEligibleForDelete(a.userId, a.billbackList);
			b = application.util.struct.structSortLowerCase(b);

			var jsonData = '';
			jsonData = serializeJson(b);

			return jsonData;
		</cfscript>
	</cffunction>

	<!--- Check whether a Billback is eligible for deleting --->
	<cffunction name="checkBBEligibleForDelete" returntype="Struct" access="remote">
		<cfargument name="userId" type="string" required="true"><!--- default="00000000-9999-9999-0000000000000000" --->
		<cfargument name="billbackList" type="string" required="true">

		<cfset var stReturnValue = StructNew()>
		<cfset var ShowMsg = "">
		<cfset var strBBList = "">
		<cfset var BBList = "">
		<cfset var ErrorMsgSplit = "">
		<cfset var bOnlyDisplayBillbackParent = appSettings.getDisplayOnlyBillbackParent() />
		<cfset var isParentBBWhenChildAllowed = 0>
		<cfset var isChildBBWhenParentAllowed = 0>

		<cfset stBBLabels = getBBLabels()>


		<cfloop list="#arguments.billbackList#" index="i">
			<CFQUERY name="qryBillback" datasource="#Application.Datasource#">
			   SELECT Billback.Billback_ID,Billback.Billback_Status_ID,BB_Code,Billback.DD_Closure_Sent_On,
				  Billback.BB_Payment_Request_Sent,Billback.BB_Received_Ack_Type,Billback.BB_Approved_Void_Ack_Type,
				  Billback_Allied.BB_Is_Locked,Billback_Allied.BB_Locked_By_User_ID,Billback.BB_Parent_ID
			   FROM	Billback
			   INNER JOIN Billback_Allied
			   ON Billback.Billback_ID = Billback_Allied.Billback_ID
			   WHERE Billback.billback_ID_Int = '#i#'
			</CFQUERY>

			<!--- When we display only parent billbacks on the bb search screen, reset is only allowed for parent billbacks and not for child billbacks (splits) --->
			<cfif (bOnlyDisplayBillbackParent eq 1 AND qryBillback.BB_Parent_ID neq "")>
				<cfset isChildBBWhenParentAllowed = 1>
			<!--- When we display parent billbacks and child billbacks on the bb search screen, reset is only allowed for child billbacks (split) and not for the parent billback --->
			<cfelseif (bOnlyDisplayBillbackParent eq 0 AND qryBillback.Billback.BB_Parent_ID eq "")>
				<cfset isParentBBWhenChildAllowed = 1>
			</cfif>

			<!--- When from inside a billback. We send the bbheader as stReturnValue.
			Note: When a user opens a billback, the query fired will check for conditions as to whether a billback can be deleted and so we do not need
			to send the users a list of reasons as to whether a billback cannot be reset when a user deletes a billback from the edit screen. The "delete"
			link will be already enabled/disabled based on logic. --->

			<!--- Check whether a billback can be "deleted" --->
			<CFIF isChildBBWhenParentAllowed eq 0
				AND isParentBBWhenChildAllowed eq 0
				AND (qryBillback.BB_Is_Locked eq 0 OR qryBillback.BB_Locked_By_User_ID eq request.AccessStructure.User_ID)
				AND
				(	(
					<!--- WIP,RFA,Approved,Pending Fund Update,Pending Vendor ID --->
					 qryBillback.Billback_Status_ID eq 1 OR qryBillback.Billback_Status_ID eq 2 OR qryBillback.Billback_Status_ID eq 3
					 OR qryBillback.Billback_Status_ID eq 6 OR qryBillback.Billback_Status_ID eq 7
					)
					OR
					(<!--- Payment Request --->
					 (qryBillback.Billback_Status_ID eq 4 AND qryBillback.BB_Payment_Request_Sent eq 0)
					)
					OR
					(<!--- Approved - VOID  --->
					 (qryBillback.Billback_Status_ID eq 8 AND (#appSettings.getBBAllowReverse()# eq 0 OR qryBillback.BB_Approved_Void_Ack_Type eq 1))
					)
				)
				AND qryBillback.DD_Closure_Sent_On eq ""
			>
			<CFELSE>
				<!--- List of billbacks that cannot be deleted --->
				 <CFSET BBList = ListAppend(BBList,qryBillback.BB_Code)>
			</CFIF>
		</cfloop>

		<!--- If there are billbacks that cannot be deleted --->
		<cfif BBList neq "">
			<cfset arrBBList = BBList.split(",")>

				<!--- When only parent billbacks are displayed on the bb search. Do not allow deleting the split. (In case the app setting is modified) --->
				<cfif isChildBBWhenParentAllowed>
					<cfset ErrorMsgSplit = "Is a split of a parent #stBBLabels.billback#">
				<cfelseif isParentBBWhenChildAllowed>
				<!--- When all billbacks (parent and splits) are displayed on the bb search, do not allow deleting the parent billback. --->
					<cfset ErrorMsgSplit = "Is a parent of a split #stBBLabels.billback#">
				</cfif>

				<!--- Error reasons --->
				<cfset stReturnValue.ShowMsg ="The following #stBBLabels.billback# cannot be deleted due to one of the reasons below:"
				& chr(13) & chr(10) & "- Is Locked by some other user" & chr(13) & chr(10) & "- Has already interfaced to your accounting system">

				<!--- Additional error reason: if applicable --->
				<cfif ErrorMsgSplit neq "">
					<cfset stReturnValue.ShowMsg = stReturnValue.ShowMsg & chr(13) & chr(10) & "- #ErrorMsgSplit#">
				</cfif>

				<cfloop from ="1" to="#ArrayLen(arrBBList)#" index="i">
					<cfset strBBList = strBBList & arrBBList[i] & chr(13)>
				</cfloop>

				<!--- List of billbacks that cannot be deleted --->
				<cfset stReturnValue.ShowMsg = stReturnValue.ShowMsg  & chr(13) & chr(10) & strBBList>

		<cfelse>
				<!--- If all the billbacks can be deleted --->
				<cfset stReturnValue = deleteBBList(arguments.userId,arguments.billbackList)>
		</cfif>

		<!---
			DELETE FROM BB EDIT SCREEN CODE BELOW
		---->
		<!--- If only one billback: When the user deletes a billback from inside a billback, we need to return the bbheader, so that the header can
		be refreshed on the grid.
		Note: The user can select just one billback from the grid and does not have to select multiple billbacks. In that case,
		bbheader will be returned, but not be used. --->
		<cfif ListLen(arguments.billbackList) eq 1>

			<cfscript>
			objBillbackLoadManager = CreateObject("component", "mvc.Models.Billback.BillbackLoadManager");
			//get the query object to pass to getCreateBillbackHeaderObject() and use the returned struct for BBHeader
			qGetBillbackData =  getBillbackData(arguments.billbackList);

			//build BBHeader data structure
			stHeaderData = structNew();
			stHeaderData["__type__"] = "mvc.Models.Billback.vos.BBHeader";
			stHeaderData = objBillbackLoadManager.getCreateBillbackHeaderObject(qGetBillbackData);
			</cfscript>

			<cfset stReturnValue.bbHeader = stHeaderData>

		</cfif>

		 <cfreturn stReturnValue>
	</cffunction>

	<cffunction name="deleteBBList" returntype="Struct" access="private">
		<cfargument name="userId" type="string" required="true"><!--- default="00000000-9999-9999-0000000000000000" --->
		<cfargument name="billbackList" type="string" required="true">

		<cfset var returnDeleteSuccess = 0 />
		<cfset var ShowMsg = "">
		<cfset var stReturnValue = StructNew()>
		<cfset var arrBillbackIDList = ArrayNew(1)>
		<cfset var recordNumber = 0>

		<cfif Not isDefined("request.AccessStructure")>
			<cfset request.AccessStructure = structNew() />
			<cfset request.AccessStructure.userId = arguments.userId />
			<!---<cfset request.AccessStructure.profiles_id = arguments.profiles_id />--->
		</cfif>


		<cfloop list="#arguments.billbackList#" index="i">
		<cfset recordNumber = recordNumber + 1>

		  <cfquery name="qryBillback" datasource="#application.datasource#">
		  SELECT bb.Billback_ID,bb.Auto_Billback, bba.BB_pullbacks_applied,bb.BB_Code
		  FROM Billback bb
		  LEFT JOIN BB_Approved bba
		  ON bb.billback_ID = bba.billback_ID
		  WHERE bb.billback_ID_Int = '#i#'
		  </cfquery>

		  <cfset FORM.Billback_ID = qryBillback.Billback_ID>

		  <!--- Use "auto_bb_delete.cfm" to delete the billback, if it is an auto billback --->
		  <cfif qryBillback.Auto_Billback eq 1>
			<cfinclude template="/billbacks/common/auto_bb_delete.cfm">
		  <cfelse>
		  <!--- Use "deleteBillback" to delete all non auto billback --->
			<cfset returnDeleteSuccess = CreateObject("component", "components.billback.BillbackManager").deleteBillback(FORM.Billback_ID, request.AccessStructure.User_ID) />
		  </cfif>

		  <cfif qryBillback.BB_pullbacks_applied EQ 1>
			<cfset CreateObject("component","components.programs.pullbacks.PullbackManager").deleteBillbackPullbacks(FORM.Billback_ID) />
		  </cfif>
				<!--- Return a list of "Billback_Id_Int" to flex, so that the billbacks can be deleted from the grid --->
				<cfset stReturnValue.arrBillbackIDList[recordNumber] = "#i#">
		</cfloop>
				<!--- Message to be shown to the user --->
				<cfset stReturnValue.ShowMsg = "The selected billbacks have been deleted successfully">


	   <cfreturn stReturnValue />
	</cffunction>

	<!--- Call this function to reset a billback --->
	<cffunction name="resetBB" returntype="struct" access="remote">
		<cfargument name="userId" type="string" required="true"><!--- default="00000000-9999-9999-0000000000000000" --->
		<cfargument name="billbackID" type="string" required="true">

		<cfset var bOnlyDisplayBillbackParent = appSettings.getDisplayOnlyBillbackParent() />
		<cfset var ShowMsg = "">
		<cfset var stHeaderData = structNew()>
		<cfset var isParentBBWhenChildAllowed = 0>
		<cfset var isChildBBWhenParentAllowed = 0>

		<cfset stBBLabels = getBBLabels()>

		<cfif Not isDefined("request.AccessStructure")>
			<cfset request.AccessStructure = structNew() />
			<cfset request.AccessStructure.userId = arguments.userId />
			<!---<cfset request.AccessStructure.profiles_id = arguments.profiles_id />--->
		</cfif>

		<CFQUERY name="qryBillback" datasource="#Application.Datasource#">
			SELECT	Billback.Billback_ID,Billback.Billback_Status_ID,Billback.BB_Code,DD_Closure_Sent_On,
				Billback.BB_Payment_Request_Sent,Billback.BB_Associated_To_DD,Billback.BB_Reversed,
				Billback.BB_Received_Ack_Type,Billback.BB_parent_ID,Billback_Allied.BB_Is_Locked,
				Billback_Allied.BB_Locked_By_User_ID
			FROM	Billback
			INNER JOIN
				Billback_Allied
			ON Billback.billback_id = Billback_Allied.billback_id
			WHERE Billback_ID_Int = '#arguments.billbackID#'
		</CFQUERY>

		<cfset URL.BBID = qryBillback.Billback_ID>
		<cfset FromFlex = 1>

		<!--- When we display only parent billbacks on the bb search screen, reset is only allowed for parent billbacks and not for child billbacks (splits) --->
		<cfif (bOnlyDisplayBillbackParent eq 1 AND qryBillback.BB_Parent_ID neq "")>
			<cfset isChildBBWhenParentAllowed = 1>
		<!--- When we display parent billbacks and child billbacks on the bb search screen, reset is only allowed for child billbacks (split) and not for the parent billback --->
		<cfelseif (bOnlyDisplayBillbackParent eq 0 AND qryBillback.Billback.BB_Parent_ID eq "")>
			<cfset isParentBBWhenChildAllowed = 1>
		</cfif>

		<!--- Note: This function is not called from the bb edit screen:
		When a user opens a billback, the query fired will check for conditions as to whether a billback can be reset and so we do not need
		to send the users a list of reasons as to whether a billback cannot be reset when a user deletes a billback from the edit screen. The "delete"
		link will be already enabled/disabled based on logic.
		--->

		<!--- Check whether a billback can be "Reset" --->
		<CFIF isChildBBWhenParentAllowed eq 0
			AND isParentBBWhenChildAllowed eq 0
			AND (bOnlyDisplayBillbackParent eq 1 OR qryBillback.BB_Associated_To_DD eq 0)
			AND (qryBillback.BB_Is_Locked eq 0 OR qryBillback.BB_Locked_By_User_ID eq request.AccessStructure.User_ID)
			AND
			(   qryBillback.Billback_Status_ID eq 2
				OR
				qryBillback.Billback_Status_ID eq 3
				OR
				(
				qryBillback.Billback_Status_ID eq 4
				AND
					(
					<!--- To allow reset, getBBAllowResetBeforePMTInterfacePRStatus is 1 and interface has not been sent --->
					(#appSettings.getBBAllowResetBeforePMTInterfacePRStatus()# eq 1 AND qryBillback.BB_Payment_Request_Sent eq 0)
					AND
					<!--- To allow reset, billback.DD_Closure_Sent_On should be blank when getBBAllowResetAfterDEDInterface is 0.
					When getBBAllowResetAfterDEDInterface is 1, it is allowed --->
					(#appSettings.getBBAllowResetAfterDEDInterface()# eq 1 OR qryBillback.DD_Closure_Sent_On eq "")
					)
				OR
					(
					<!--- This condition has been initially added for GM. It can be used by other clients too --->
					(#appSettings.getBBAllowResetBeforePMTInterfacePRStatus()# eq 1 AND qryBillback.BB_Reversed eq 0)
					AND
					(qryBillback.BB_Payment_Request_Sent eq 1 OR qryBillback.DD_Closure_Sent_On neq "")
					AND
					(qryBillback.BB_Received_Ack_Type eq 0)
					)
				)
			 )
		>

			<!--- Set variables required for reset - "bb_reset2.cfm" requires "resetBillback" and "Billback_ID" variables --->
			<cfset resetBillback = 1>
			<cfset Billback_ID = URL.BBID>

			<!--- Reset the billback --->
			<cfinclude template="/billbacks/common/bb_reset2.cfm">

			<!---- This if for the DD detaching from the BB --->
			<cfset removeDDAndSplits(Billback_ID)>

			<cfset stHeaderData.bbh = getBBHeader(arguments.billbackID)> <!---Pass "Billback_ID_int"--->
			<cfset stHeaderData.ShowMsg = "">
		<CFELSE>

			<cfset ShowMsg = "The #stBBLabels.billback# cannot be reset due to the reason(s) below." />

			<cfif qryBillback.BB_Is_Locked eq 1 AND (qryBillback.BB_Locked_By_User_ID neq request.AccessStructure.User_ID)>
				 <cfset ShowMsg = ShowMsg & chr(13) & chr(10) & "It is locked by another user." />
			</cfif>

			<cfif isChildBBWhenParentAllowed eq 1>
				 <cfset ShowMsg = ShowMsg & chr(13) & chr(10) & "It is a split of a parent #stBBLabels.billback#." />
			</cfif>

			<cfif isParentBBWhenChildAllowed eq 1>
				 <cfset ShowMsg = ShowMsg & chr(13) & chr(10) & "It is a parent of a split #stBBLabels.billback#." />
			</cfif>

			<cfif qryBillback.BB_Associated_To_DD eq 1>
				 <cfset ShowMsg = ShowMsg & chr(13) & chr(10) & "It is associated to a deduction." />
			</cfif>

			<!--- We only allow billbacks in payment request status to be reset from flex, if certain conditions (above) are met.
			If the user could reset from flex, that means certain conditions have changed since then and it is most likely
			that the billback has already been interfaced --->
			<cfif qryBillback.Billback_Status_ID eq 4>
				<cfset ShowMsg = ShowMsg & chr(13) & chr(10) & "It may have already interfaced to your accounting system." />
			</cfif>

			<cfset stHeaderData.ShowMsg = ShowMsg>

		</CFIF>

	   <cfreturn stHeaderData />
	</cffunction>

	<cffunction name="removeDDAndSplits" returntype="void" access="public">
		<cfargument name="billbackID" type="string" required="true">

		<cfset var BBID = arguments.billbackID>

			<!--- Set these values on billback reset --->
			<cfquery name="updBBonReset" datasource="#Application.Datasource#">
			UPDATE Billback
			SET
					BB_Payment_Request_Sent = 0,
					DD_Closure_Sent_On = NULL,
					Reversal_Sent = 0
			WHERE 	(Billback_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#BBID#">
				OR
				BB_Parent_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#BBID#">
				)
			</cfquery>

			<cfset useLakebaseForgetAllChildBBs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetAllChildBBs>
	<cftry>
		<cfset getAllChildBBs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"bb_parent_id" = "eq.#BBID#",
				"deleted" = "eq.0",
				"select" = "billback_id_int,billback_id"
			}), "billback_id_int,billback_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAllChildBBs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAllChildBBs>
<cfquery name="getAllChildBBs" datasource="#Application.Datasource#">
				SELECT Billback_ID_Int,Billback_ID
				FROM Billback
				WHERE BB_parent_ID = '#BBID#'
				AND Deleted = 0
			</cfquery>
</cfif>

			<cfif getAllChildBBs.RecordCount GTE 1>
				<cfloop query="getAllChildBBs">
					<cfset useLakebaseForgetAssociatedDeductionID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_closure_detail")>
<cfif useLakebaseForgetAssociatedDeductionID>
	<cftry>
		<cfset getAssociatedDeductionID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_closure_detail", {
				"dd_closure_id" = "eq.#getAllChildBBs.Billback_ID#",
				"deleted" = "eq.0",
				"select" = "deduction_id"
			}), "deduction_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAssociatedDeductionID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAssociatedDeductionID>
<cfquery name="getAssociatedDeductionID" datasource="#application.datasource#">
						SELECT	Deduction_ID
						FROM	DD_Closure_Detail
						WHERE	DD_Closure_ID = '#getAllChildBBs.Billback_ID#' AND Deleted = 0
					</cfquery>
</cfif>
					<cfif (getAssociatedDeductionID.RecordCount GTE 1)>
						<cfloop query="getAssociatedDeductionID">
							<cfset createobject("component", "mvc.Models.Billback.BillbackSettlementDAO").fnUnAssociateDeductionOnDDIDDAO(Deduction_ID = getAssociatedDeductionID.Deduction_ID, Billback_ID = getAllChildBBs.Billback_ID) />
						</cfloop>
					</cfif>
				</cfloop>
			<cfelse>
					<cfquery name="getAssociatedDeductionID" datasource="#application.datasource#">
						SELECT	Deduction_ID
						FROM	DD_Closure_Detail
						WHERE	DD_Closure_ID = '#BBID#' AND Deleted = 0
					</cfquery>
					<cfif (getAssociatedDeductionID.RecordCount GTE 1)>
						<cfloop query="getAssociatedDeductionID">
							<cfset createobject("component", "mvc.Models.Billback.BillbackSettlementDAO").fnUnAssociateDeductionOnDDIDDAO(Deduction_ID = getAssociatedDeductionID.Deduction_ID, Billback_ID = BBID) />
						</cfloop>
					</cfif>
			</cfif>

			<cfset Createobject("component", "mvc.Models.Billback.BillbackSettlementDAO").removeBillbackSplits(Billback_ID = BBID) />
	</cffunction>

	<!--- Call this function to "Reassign" a billback --->
	<cffunction name="reassignBB" returntype="Array" access="remote">
		<cfargument name="BBFilterParams" required="true">
		<cfargument name="billbackList" type="string" required="true">

		<cfset var arrHeaderData = ArrayNew(1)>
		<cfset var stHeaderData = structNew()>
		<cfset var ArrreassignToBBUser = ArrayNew(1)>
		<cfset var strArrreassignToBBUser = "">
		<cfset var BillbackIDList = "">
		<cfset var stHeaderData.success = false>

		<!--- Get the "Analyst" to which the billbacks are to be reassigned --->
		<cfif IsDefined("arguments.BBFilterparams.reassignBBUserSelect")>
			<cfif IsArray("#arguments.BBFilterparams.reassignBBUserSelect#")>
					<cfset ArrreassignToBBUser[1] = arguments.BBFilterparams.reassignBBUserSelect[1].idInt>
					<cfset strArrreassignToBBUser = ArrayToList(ArrreassignToBBUser)>
			</cfif>
		<cfelse>
			<cfset strArrreassignToBBUser = arguments.BBFilterparams>
		</cfif>

		<CFQUERY name="qryBillback" datasource="#Application.Datasource#">
			SELECT	Billback_ID
			FROM	Billback
			WHERE Billback_ID_Int IN (#arguments.billbackList#)
		</CFQUERY>

		<cfset useLakebaseForqryGetUserID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForqryGetUserID>
	<cftry>
		<cfset qryGetUserID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"sales_person_id" = "eq.#strArrreassignToBBUser#",
				"select" = "user_id"
			}), "user_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryGetUserID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryGetUserID>
<CFQUERY name="qryGetUserID" datasource="#Application.Datasource#">
			SELECT	User_ID
			FROM	_Users
			WHERE Sales_Person_ID = '#strArrreassignToBBUser#'
		</CFQUERY>
</cfif>

		<cfset BillbackIDList = ListQualify(ValueList(qryBillback.Billback_ID), chr(39))>

		<!--- Reassign the billbacks --->
		<cfquery name="updAnalyst" datasource="#application.datasource#">
		 UPDATE Billback
		 SET Analyst_User_ID = '#qryGetUserID.User_ID#'
		 WHERE Billback_ID IN (#preservesinglequotes(BillbackIDList)#)

		SELECT Rows_Count = @@ROWCOUNT
		SET NOCOUNT OFF
		</cfquery>

		<!--- If the "Reassign" was successful --->
		<cfif updAnalyst.Rows_Count>
			<cfset stHeaderData.success = true>
		</cfif>

		<!--- Loop through the billback list and create a structure of bbHeaders. Add the struct to the "arrHeaderData" array --->
		<cfloop list="#arguments.billbackList#" index="bbIDInt">
			<cfset stHeaderData.bbh = getBBHeader(bbIDInt)> <!---Pass "Billback_ID_int"--->
			<cfset ArrayAppend(arrHeaderData,duplicate(stHeaderData))>
		</cfloop>

	   <cfreturn arrHeaderData />
	</cffunction>

	<cffunction name="getUserProfile" returntype="string">
		<cfargument name="userId" type="string" required="true" />
		<cfset var p = 0/>
		<cfif not isdefined("request.AccessStructure")>
			<cfquery name="qryGetUserProfile" datasource="#application.datasource#">
				SELECT profiles.profiles_id
				FROM profiles inner join _users
				ON profiles.profiles_id = _users.profiles_id
				WHERE _users.user_id ='#arguments.userId#'
				AND profiles.deleted = 0
			</cfquery>
			<cfset request.AccessStructure.profiles_id = qryGetUserProfile.profiles_id />
			<cfset request.AccessStructure.user_id = arguments.userId />
		</cfif>
			<cfreturn request.AccessStructure.profiles_id />
	</cffunction>

	<cffunction name="getBillbackUUID" output="false" access="public" returntype="String">
		<cfargument name="billbackIDInt" required="true" type="numeric">

			<cfquery name="qryBillback" datasource="#Application.Datasource#">
			  SELECT Billback_ID
			  FROM	Billback
			  WHERE Billback_ID_Int  = #arguments.billbackIDInt#
			</cfquery>

	  <cfreturn qryBillback.Billback_ID />

	</cffunction>

	<cffunction name="getBillbackJSON"  access="remote" output="false" returnformat="JSON">
		<cfargument name="billbackIDInt" required="true" type="numeric">
		<cfargument name="copyAction" required="false" type="any" default="0">

		<cfscript>
			var jsonData = '';
			if(arguments.billbackIDInt){
				var bb = getBillback(arguments.billbackIDInt, arguments.copyAction);
			}else{
				var bb  = CreateObject("component", "mvc.Models.Billback.vos.Billback").init();
				var bbHeader = CreateObject("component", "mvc.Models.Billback.vos.BBHeader").init();
				bb.bbHeader = bbHeader;
			}
			bb = application.util.struct.structSortLowerCase(bb);
			jsonData = serializeJSON(bb, "struct");
		</cfscript>
		<cfreturn jsonData/>
	</cffunction>

	<cffunction name="getBillback" returntype="struct" access="remote">

		<cfargument name="billbackIDInt" required="true" type="numeric">
		<cfargument name="copyAction" required="false" type="any" default="0">

		<cfscript>
			//set local variables
			var nBillbackID							= "";
			var strBillbackID						= "";
			var qGetBillbackData					= "";
			var qGetBillbackProgramDisItemRateData	= "";
			var objBillbackLoadManager 				= "";
			var objBillbackManager					= "";
			var stData								= structNew();
			var stHeaderData						= structNew();
			var stProgramData						= structNew();
			var stCustomerData						= structNew();
			var stProdRateData						= structNew();
			var stAddrData							= structNew();
			var arrBBPrgDistItemRate 				= arrayNew(1);
			var stRetData 							= structNew();
			var stClosingMethodDetails				= structNew();
			var arrUomDp 							= arrayNew(1);
			var arrBBComponent 						= arrayNew(1);
			var qGetExpectedData					= "";
			var strExpectedAmount					= "";
			var strExpectedCS						= "";
			var strExpectedLB						= "";
			var qGetBBComponent						= "";
			var idxRow								= "";
			var objProductRateManager				= "";
			var oSettlementDAO = CreateObject("component","mvc.Models.Billback.BillbackSettlementDAO");
			var oSettlement = CreateObject("component","mvc.Models.Billback.BillbackSettlementManager");
			var nAmount								= 0;
			var nVolume								= 0;
			var nRate								= 0;
			var strMessage							= "";
			var qGetBillbackLockData				= "";
			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
			//Uom choices (dp for combo) may be at header so get it once and send it
			arrUomDp = this.getUomDp();

			/***********************   Construct BBHeader BEGIN *****************************/
			//initialize load manager to get the data for BBHeader
			objBillbackLoadManager = CreateObject("component", "mvc.Models.Billback.BillbackLoadManager");

			/* Populate "stHeaderData" with the updated data */
			stHeaderData = getBBHeader(nBillbackID);

			qGetBillbackData =  getBillbackData(nBillbackID);

			/* Get other BBHeader Info */
			qGetBillbackLockData = getBillbackMiscInfo(qGetBillbackData.Billback_ID);

			stHeaderData["locked"] = qGetBillbackLockData.Locked;
			stHeaderData["lockedBy"] = qGetBillbackLockData.Locked_By;
			stHeaderData["copyAction"] = JavaCast("boolean", arguments.copyAction);

			/***********************   Construct BBHeader END *******************************/

			//call the function to get the data to populate BBPrgDistItemRate
			qGetBillbackProgramDisItemRateData = getBillbackProgramDisItemRateData(nBillbackID);

			//assign local var objProductRateManager to an instance of mvc.Models.Program.Component.ProductRateManager
			// objProductRateManager = CreateObject("component", "mvc.Models.Program.Component.ProductRateManager");
		</cfscript>
		<cfloop query="qGetBillbackProgramDisItemRateData">

			<cfscript>

				stData = structNew();
				stData["__type__"] = "mvc.Models.Billback.vos.BBPrgDistItemRate";
				/***********************   Construct Address BEGIN *****************************/
				stAddrData = structNew();
				stAddrData["__type__"] = "mvc.Models.Entity.vos.Address";
				stAddrData["addressLine1"] = qGetBillbackProgramDisItemRateData.addressLine1;
				stAddrData["addressLine2"] = qGetBillbackProgramDisItemRateData.addressLine2;
				stAddrData["city"] = qGetBillbackProgramDisItemRateData.city;
				stAddrData["state"] = qGetBillbackProgramDisItemRateData.state;
				stAddrData["zipCode"] = qGetBillbackProgramDisItemRateData.zipCode;
				/***********************   Construct Address BEGIN *****************************/

				//structure to hold data structure for Customer
				stCustomerData = structNew();

				/***********************   Construct Customer BEGIN *****************************/
				stCustomerData["__type__"] = "mvc.Models.Entity.vos.Customer";
				stCustomerData["shipTo"] = qGetBillbackProgramDisItemRateData.shipTo;
				stCustomerData["name"] = qGetBillbackProgramDisItemRateData.name;
				stCustomerData["customerId"] = qGetBillbackProgramDisItemRateData.customerId;
				stCustomerData["address"] = duplicate(stAddrData);
				/***********************   Construct Customer END *****************************/

				//structure to hold data structure for uom
				stUom = structNew();
				stUom["__type__"] = "mvc.Models.Program.Component.vos.Uom";
				stUom["uomId"] = trim(qGetBillbackProgramDisItemRateData.uomId);
				stUom["description"] = trim(qGetBillbackProgramDisItemRateData.uomDescription);
				stUom["abbreviation"] = trim(qGetBillbackProgramDisItemRateData.uomAbbreviation);


				//structure to hold data structure for bbProdRate
				stProdRateData = structNew();

				/***********************   Construct bbProdRate BEGIN *****************************/

				nAmount	= 	qGetBillbackProgramDisItemRateData.amount;
				nVolume	=	qGetBillbackProgramDisItemRateData.volume;
				if (isNumeric(nAmount) and isNumeric(nVolume) AND (nvolume != "0.00" OR nvolume != "0") AND (nAmount != "0.00" OR nAmount != "0"))
				{
					nRate = nAmount / nVolume;
				}
				else
				{
					nRate = 0.00;
				}

				stProdRateData["__type__"] = "mvc.Models.Billback.vos.BBProdRate";
				stProdRateData["itemGuid"] = qGetBillbackProgramDisItemRateData.itemGuid;
				stProdRateData["itemNumber"] = qGetBillbackProgramDisItemRateData.itemNumber;
				stProdRateData["description"] = qGetBillbackProgramDisItemRateData.description;
				stProdRateData["netWeight"] = qGetBillbackProgramDisItemRateData.netWeight;
				//stProdRateData["progRate"] = objProductRateManager.getProgramProductRate(qGetBillbackProgramDisItemRateData.programID, qGetBillbackProgramDisItemRateData.discountType, qGetBillbackProgramDisItemRateData.itemGuid);
				stProdRateData["rate"] = nRate;
				stProdRateData["amount"] = qGetBillbackProgramDisItemRateData.amount;
				stProdRateData["volume"] = qGetBillbackProgramDisItemRateData.volume;
				stProdRateData["discountType"] = qGetBillbackProgramDisItemRateData.discountType;
				stProdRateData["bNotOnProgram"] = qGetBillbackProgramDisItemRateData.bNotOnProgram;
				stProdRateData["uom"] = duplicate(stUom);
				/***********************   Construct bbProdRate END *****************************/

				//structure to hold data structure for bbProgram
				stProgramData = structNew();

				/***********************   Construct bbProgram BEGIN *****************************/
				stProgramData["__type__"] = "mvc.Models.Billback.vos.BBProgram";
				stProgramData["programId"] = qGetBillbackProgramDisItemRateData.programID;
				stProgramData["number"] = qGetBillbackProgramDisItemRateData.programNumber;
				stProgramData["title"] = qGetBillbackProgramDisItemRateData.programTitle;
				stProgramData["startDate"] = qGetBillbackProgramDisItemRateData.programStartDate;
				stProgramData["endDate"] = qGetBillbackProgramDisItemRateData.programEndDate;
				stProgramData["effectiveStartDate"] = qGetBillbackProgramDisItemRateData.EffectiveStartDate;
				stProgramData["effectiveEndDate"] = qGetBillbackProgramDisItemRateData.EffectiveEndDate;
				stProgramData["bIsLatestVersion"] = qGetBillbackProgramDisItemRateData.bIsLatestVersion;
				/***********************   Construct bbProgram END *****************************/

				strMessage = "";
				/* if bNotOnProgram = 1 then set the message product not on program */
				if (qGetBillbackProgramDisItemRateData.bNotOnProgram eq 1)
				{
					strMessage = "Product Not on Program";
				}
				stData["bbProgram"] = duplicate(stProgramData);
				stData["bbDistributor"] = duplicate(stCustomerData);
				stData["bbProdRate"] = duplicate(stProdRateData);
				stData["uomDp"] = arrUomDp;
				stData["message"] = strMessage;
				stData["bFirstTime"] = javacast("boolean", 0);


				ArrayAppend(arrBBPrgDistItemRate, duplicate(stData));
			</cfscript>

		</cfloop>

		<cfscript>

			//call the function to get the data to populate BBComponent
			qGetBBComponent = variables.oBillbackDAO.getBBComponentData(nBillbackID);

			//Loop over query object and build an array of BBComponent VOs
			for (idxRow = 1; idxRow LTE qGetBBComponent.RecordCount; idxRow = (idxRow + 1))
			{
				stPaidTo = structNew();
				stPaidTo["__type__"] = "mvc.Models.Program.Component.vos.PaidTo";
				stPaidTo["paidToId"] = qGetBBComponent["paidTo"][idxRow];
				stPaidTo["description"] =  qGetBBComponent["description"][idxRow];

				//Populate BB Component VO
				stData = structNew();
				stData["__type__"] = "mvc.Models.Billback.vos.BBComponent";
				stData["isSelected"] = javacast("boolean", 1);
				stData["programID"] = qGetBBComponent["programID"][idxRow];
				stData["bbProgramID"] = qGetBBComponent["bbProgramID"][idxRow];
				stData["componentTypeId"] = qGetBBComponent["componentTypeId"][idxRow];
				stData["componentNameId"] = qGetBBComponent["componentNameId"][idxRow];
				stData["componentName"] = qGetBBComponent["componentName"][idxRow];
				stData["componentDesc"] = qGetBBComponent["componentDesc"][idxRow];
				stData["componentAmount"] = qGetBBComponent["componentAmount"][idxRow];
				stData["programNumber"] = qGetBBComponent["programNumber"][idxRow];
				stData["programTitle"] = qGetBBComponent["programTitle"][idxRow];
				stData["bIsLatestVersion"] = qGetBBComponent["bIsLatestVersion"][idxRow];
				stData["compDescription"] = qGetBBComponent["compDescription"][idxRow];
				stData["compRate"] = qGetBBComponent["compRate"][idxRow];
				stData["programComponentId"] = qGetBBComponent["programComponentId"][idxRow];
				stData["paidTo"] = stPaidTo;
				ArrayAppend(arrBBComponent, duplicate(stData));
			}

			//stuff BBPrgDistItemRate array of structs data into return struct
			stRetData["bbPrgDistItemRate"] = arrBBPrgDistItemRate;
			//stuff BBHeader struct data into return struct
			stRetData["bbHeader"] = stHeaderData;

			//initialize the BillbackManager in the components directory to call the functions that will return the expected amount, CS and LB values
			objBillbackManager = CreateObject("component", "components.Billback.BillbackManager");

			//set the billback UUID
			strBillbackID = qGetBillbackData.Billback_ID;

			//get then set the expected CS and LB
			qGetExpectedData = objBillbackManager.getBillbackItemizedVolumeSum(strBillbackID);
			strExpectedCS = qGetExpectedData.Volume_CS;
			strExpectedLB = qGetExpectedData.Volume_LB;

			//get and set the expected amount
			strExpectedAmount = objBillbackManager.getBillbackItemizedAmount(strBillbackID);

			//set the return struct type as Billback and populate its values
			stRetData["__type__"] = "mvc.Models.Billback.vos.Billback";
			stRetData["receivedDate"] = qGetBillbackData.BB_Received_Date;
			stRetData["postDate"] = qGetBillbackData.Postmark_Date;
			stRetData["claimedAmount"] = qGetBillbackData.BB_Amount;
			stRetData["claimedCS"] = qGetBillbackData.Claim_Cases;
			stRetData["claimedLB"] = qGetBillbackData.Claim_Pounds;
			stRetData["expectedAmount"] = strExpectedAmount;
			stRetData["expectedCS"] = strExpectedCS;
			stRetData["expectedLB"] = strExpectedLB;
			stRetData["variedAmount"] = val(qGetBillbackData.BB_Amount) - val(strExpectedAmount);
			stRetData["variedCS"] = val(qGetBillbackData.Claim_Cases) - val(strExpectedCS);
			stRetData["variedLB"] = val(qGetBillbackData.Claim_Pounds) - val(strExpectedLB);
			stRetData["bbNotes"] = trim(qGetBillbackData.BB_Creator_Notes);
			stRetData["bbDocs"] = "";
			// this is moved into bbHeader object
			// stRetData["BBClosingDetails"] = qGetClosingMethodDetails;

			stRetData["bbComponent"] = arrBBComponent;

			stRetData["uomDp"] = arrUomDp;
			//return the mvc.Models.Billback.vos.Billback struct
			return stRetData;

		</cfscript>

	</cffunction>

	<cffunction name="getUomDp" access="remote" returntype="Array" >

		<cfscript>
			var arrUomDp = arrayNew(1);
			var stUomData = structNew();
		</cfscript>
		<cfquery datasource="#application.datasource#" name="qGetBBDetail">

			SELECT 	TOP 50
					UOM.Unit_Of_Measure_Id as uomId,
					UOM.Abbreviation as uomAbbreviation,
					UOM.unit_Of_Measure_Desc as uomDescription
			FROM  	Units_Of_Measure UOM
			WHERE 	Unit_Of_Measure_Id <= 2

		</cfquery>
		<cfloop query="qGetBBDetail">
			<cfscript>
				stUomData = structNew();
				stUomData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
				stUomData["uomId"] = trim(qGetBBDetail.uomId);
				stUomData["description"] = trim(qGetBBDetail.uomDescription);
				stUomData["abbreviation"] = trim(qGetBBDetail.uomAbbreviation);

				ArrayAppend(arrUomDp, duplicate(stUomData));
			</cfscript>
		</cfloop>

		<cfreturn arrUomDp />
	</cffunction>

	<cffunction name="getBillbackData" output="false" returntype="query">

		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<cfscript>
			//set local variables
			var nBillbackID			= "";
			var qRetBillbackData	= "";
			var objBillbackDAO		= "";

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
			objBillbackDAO	= variables.oBillbackDAO;

			//call the BillbackDAO to get data from the DB and return the query object
			qRetBillbackData = objBillbackDAO.getBBData(nBillbackID);
			return qRetBillbackData;
		</cfscript>

	</cffunction>

	<cffunction name="getBillbackProgramDisItemRateData" output="false" returntype="query">

		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<cfscript>
			//set local variables
			var nBillbackID							= "";
			var qRetBillbackProgramDisItemRateData	= "";
			var objBillbackDAO						= "";

			//assign local variables
			nBillbackID		= arguments.billbackIDInt;
			objBillbackDAO	= variables.oBillbackDAO;

			//call the BillbackDAO to get data from the DB and return query object
			qRetBillbackProgramDisItemRateData = objBillbackDAO.getBBProgramDistributorProductRateData(nBillbackID);
			return qRetBillbackProgramDisItemRateData;
		</cfscript>

	</cffunction>

	<!--- This is called from flex directly for billback attachments. BBDetails has many properties but only the properties relevant to
		  documents is populated and sent back to flex.
	--->
	<cffunction name="getBillbackAttachmentList" output="false"  access="remote" returntype="Struct">
		<cfargument name="billbackIDInt" required="true" type="numeric">
		<cfargument name="userID" required="true" type="string">

		 <cfset var Billback_ID = getBillbackUUID(arguments.billbackIDInt)>

		   <!--- get BB Attachment Info --->
		  <cfset var qgetBillbackAttachmentsTitle = getBillbackAttachments(Billback_ID,arguments.userID,1)>
		  <cfset var qgetBillbackAttachmentsFileName = getBillbackAttachments(Billback_ID,arguments.userID,2)>

		  <cfscript>
			stData = structNew();
			stData["__type__"] = "mvc.Models.Billback.vos.BBDetails";
			stData["documentList"] = qgetBillbackAttachmentsTitle;
			stData["domainName"] = "http://#HTTP_HOST#";
			stData["uniqueFileName"] = qgetBillbackAttachmentsFileName;
		  </cfscript>

		<cfreturn stData />

	</cffunction>

	<cffunction name="getBillbackDetails" output="false"  access="remote" returntype="Struct">
		<cfargument name="billbackIDInt" required="true" type="numeric">
		<cfargument name="userID" required="true" type="string">

		  <cfset var Billback_ID = getBillbackUUID(arguments.billbackIDInt)>

		  <!--- get BB Misc Info --->
		  <cfset var qgetBillbackMiscInfo = getBillbackMiscInfo(Billback_ID)>

		  <!--- get BB Attachment Info --->
		  <cfset var qgetBillbackAttachmentsTitle = getBillbackAttachments(Billback_ID,arguments.userID,1)>
		  <cfset var qgetBillbackAttachmentsFileName = getBillbackAttachments(Billback_ID,arguments.userID,2)>

		   <!--- get BB Interface Info --->
		  <cfset var qgetBBInterfaceInfo = getBBInterfaceInfo(Billback_ID)>

		   <!--- get BB Approval Info --->
		  <cfset var qgetBillbackApprovalInfo = getBillbackApprovalInfo(Billback_ID)>

		  <!--- get BB CRA Info --->
		  <cfset var qgetApprovableUserList = getApprovableUserList(Billback_ID)>

		  <!--- get BB Workflow Info --->
		  <cfset var qgetWorkFlowData = getWorkFlowData(Billback_ID)>

		  <!--- get NRA Info --->
		  <cfset var qgetNextApprovableUsers = getNextApprovableUsers(Billback_ID)>

		  <cfscript>
			stData = structNew();
			stData["__type__"] = "mvc.Models.Billback.vos.BBDetails";
			stData["billbackIDInt"] = qgetBillbackMiscInfo.Billback_ID_Int;
			stData["lockedBy"] = qgetBillbackMiscInfo.Locked_By;
			stData["documentList"] = qgetBillbackAttachmentsTitle;
			stData["domainName"] = "http://#HTTP_HOST#";
			stData["uniqueFileName"] = qgetBillbackAttachmentsFileName;
			stData["interfaceMessage"] = qgetBBInterfaceInfo;
			stData["expectedAmount"] = qgetBillbackApprovalInfo.Expected_Amount;
			stData["paidAmount"] = qgetBillbackApprovalInfo.Paid_Amount;
			stData["claimedVsExpected"] = qgetBillbackApprovalInfo.ClaimedVsExpected;
			stData["claimedVsPaid"] = qgetBillbackApprovalInfo.ClaimedVsPaid;
			stData["expectedVsPaid"] = qgetBillbackApprovalInfo.ExpectedVsPaid;
			stData["CRADetails"] = qgetApprovableUserList;
			stData["workflowAction"] = qgetWorkFlowData;
			stData["NRADetails"] = qgetNextApprovableUsers;
		  </cfscript>

		<cfreturn stData />

	</cffunction>

	<cffunction name="getBillbackMiscInfo" output="false"  access="public" returntype="query">
		<cfargument name="billbackID" required="true" type="string">

		  <cfquery name="qgetBillbackMiscInfo" datasource="#application.datasource#">
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT  B.Billback_ID_Int,
				CASE BA.BB_Is_Locked
					WHEN 1
						THEN U1.Name_First + ' ' + U1.Name_last
				ELSE ''
				END
			 As Locked_By,
			  BA.BB_Is_Locked AS Locked
			 FROM Billback B

				INNER JOIN Billback_Allied BA
				ON B.Billback_ID = BA.Billback_ID
				LEFT JOIN _Users U1
				ON BA.BB_Locked_By_User_ID = U1.User_ID
			WHERE B.Billback_ID = <cfqueryparam value="#arguments.billbackID#" cfsqltype="CF_SQL_VARCHAR" />
		  </cfquery>

		<cfreturn qgetBillbackMiscInfo />

	</cffunction>

	<cffunction name="getBillbackAttachments" output="false"  access="public" returntype="Array">
		<cfargument name="billbackID" required="true" type="string">
		<cfargument name="userID" required="true" type="string">
		<cfargument name="columnType" required="true" type="numeric">

			<cfset var profiles_id = getUserProfile('#arguments.userid#')>
			<cfset var arrDocs = ArrayNew(1)>

			<cfif Not isDefined("request.AccessStructure")>
				<cfset request.AccessStructure = structNew() />
				<cfset request.AccessStructure.user_id = arguments.user_id />
				<cfset request.AccessStructure.profiles_id = arguments.profiles_id />
			</cfif>

			<!--- Tim Ford - Label 32254: Billback - display attached document for parent and all splits --->
			<!--- Get the billback ids for all the billbacks based on BB Code --->
			<cfquery name="qGetBillbackIds" datasource="#application.datasource#">
				SELECT DISTINCT Billback_ID FROM Billback WHERE LEFT(BB_CODE, 10) IN
					(
						SELECT DISTINCT LEFT(BB_CODE, 10) from Billback WHERE	Billback_ID = '#arguments.billbackID#' AND Deleted = 0
					)
				AND Deleted = 0
			</cfquery>

			<cfquery name="qgetBillbackAttachments" datasource="#application.datasource#">
			  DECLARE @ViewPrivateDocuments bit

				SELECT @ViewPrivateDocuments = View_Private_Documents
				FROM Profiles_Settings
				WHERE Profiles_ID = #request.AccessStructure.Profiles_ID#

			 <!--- Use the query result to populate "documentList" property in the "BBDetails" object. --->
			 <!--- Dev note: Milan (34290) - Earlier we had DISTINCT here, but we do not need it. I tested attachment in program search where if a document
			 has been attached more than once to a program, it shows up that many times. So, here if a document has been attached to a parent billback and
			 one or more child billbacks, it will show up as many times in the parent and the split OR if a document has been attached more than once on a
			 billback, then show it as many times on that billback.
			 --->
			  SELECT <cfif arguments.columnType eq 1>Document_Details.Doc_Title <cfelseif arguments.columnType eq 2>Document_Details.Doc_Uni_Name</cfif>
				As Doc_Info

				FROM    Document_Details
					INNER JOIN 	Contract_Attachments
					ON Document_Details.Doc_ID = Contract_Attachments.Doc_ID
				<!---WHERE  cast(Contract_Attachments.Billback_ID AS varchar(100)) = <cfqueryparam list="yes" value="#lBillbackids#" cfsqltype="cf_sql_varchar" >---><!---D35479: Incorrect syntax near ')'--->
				WHERE  cast(Contract_Attachments.Billback_ID AS NVARCHAR(300)) IN (<cfqueryparam value="#ValueList(qGetBillbackIds.Billback_ID)#" cfsqltype="CF_SQL_VARCHAR" list="yes" >)<!---D35637: Flex BB - Incorrect syntax near ','--->
				AND Document_Details.Deleted = 0
				AND
				(
				<!--- Public_View = 0 means "public" --->
				Public_View = 0 OR (Public_View = 1  AND @ViewPrivateDocuments = 1) OR (Document_Details.Uploaded_By = '#Request.AccessStructure.User_ID#')
				)
				<!--- Dev Note: 55043 - Adding "ORDER BY" is inportant, so that correct documents open in flex. Sometimes, without it,
				clicking on doc 1 from flex will open doc 2 and vice-versa.
				--->
				ORDER BY Document_Details.doc_title DESC
			</cfquery>

				<cfloop query="qgetBillbackAttachments">
					<cfset arrDocs[qgetBillbackAttachments.currentrow] = Doc_Info>
				</cfloop>

		<cfreturn arrDocs />

	</cffunction>

	<cffunction name="getBBInterfaceInfo" output="false"  access="public" returntype="String">
	  <cfargument name="BillbackID" type="string" required="true">
	  <cfargument name="HTML_Code" type="boolean" required="false" default="0">

		<cfset var interface_message = "">
		<cfset var add_new_Line = "">
		<cfset stBBLabels = getBBLabels()>
		<cfquery name="qgetBBInterfaceInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT b.Billback_Status_ID,b.BB_Payment_Request_Sent,b.BB_Payment_Request_Sent_On,b.BB_Received_Ack_Type,b.BB_Approved_Void_Ack_Date,
			CONVERT(VARCHAR(10), b.Paid_Date, 101) AS Paid_Date,b.BB_Received_Ack_Date,b.BB_Approved_Void_Ack_Type,b.BB_Approved_Void_Sent_On,bba.Voucher_Number,
			bba.Document_Number_1,bba.Document_Number_2
				FROM Billback b
					LEFT JOIN BB_Approved bba
				ON b.Billback_ID = bba.Billback_ID
			WHERE b.Billback_ID =  '#arguments.BillbackID#'
		</cfquery>

		<cfif arguments.HTML_Code eq 0>
			<cfset add_new_Line = "#chr(13)##chr(10)#">
		<cfelse>
			<cfset add_new_Line = "<br><br>">
		</cfif>

			<cfif (qgetBBInterfaceInfo.Billback_Status_ID EQ 3 OR qgetBBInterfaceInfo.Billback_Status_ID EQ 4 OR qgetBBInterfaceInfo.Billback_Status_ID EQ 5) AND qgetBBInterfaceInfo.BB_Payment_Request_Sent EQ 1>
				<cfset BB_Payment_Request_Sent_Date = "#DateFormat(qgetBBInterfaceInfo.BB_Payment_Request_Sent_On, "mm/dd/yyyy")# #TimeFormat(qgetBBInterfaceInfo.BB_Payment_Request_Sent_On, "hh:mm:ss tt")#" />
				<cfset BB_Received_Ack_Date_Str = "#DateFormat(qgetBBInterfaceInfo.BB_Received_Ack_Date, "mm/dd/yyyy")# #TimeFormat(qgetBBInterfaceInfo.BB_Received_Ack_Date, "hh:mm:ss tt")#" />

				<cfif qgetBBInterfaceInfo.BB_Received_Ack_Type EQ 0>
						<cfset interface_message ="This billback is being sent to ERP#add_new_Line#Send Date: #BB_Payment_Request_Sent_Date#">
				<cfelseif qgetBBInterfaceInfo.BB_Received_Ack_Type EQ 1>
					<cfif len(trim(BB_Received_Ack_Date_Str))>
							<cfset ackDate = "Acknowledge Date: #BB_Received_Ack_Date_Str#" />
							<cfset paidDate = "Paid Date: #qgetBBInterfaceInfo.Paid_Date#" />
					<cfelse>
						<cfset ackDate = ""/>
						<cfset paidDate = "" />
					</cfif>
					<cfif (len(trim(qgetBBInterfaceInfo.Document_Number_2)) AND len(trim(qgetBBInterfaceInfo.Document_Number_1)))>
						<cfset vchNumber = "#stBBLabels.Variable_1#: #qgetBBInterfaceInfo.Document_Number_1#,#qgetBBInterfaceInfo.Document_Number_2#" />
					<cfelseif (len(trim(qgetBBInterfaceInfo.Document_Number_2)) EQ 0 AND len(trim(qgetBBInterfaceInfo.Document_Number_1)))>
						<cfset vchNumber = "#stBBLabels.Variable_1#: #qgetBBInterfaceInfo.Document_Number_1#" />
					<cfelseif (len(trim(qgetBBInterfaceInfo.Document_Number_2))  AND len(trim(qgetBBInterfaceInfo.Document_Number_1)) EQ 0)>
						<cfset vchNumber = "#stBBLabels.Variable_2#: #qgetBBInterfaceInfo.Document_Number_2#" />
					<cfelseif len(trim(qgetBBInterfaceInfo.Voucher_Number))>
						<cfset vchNumber = "#stBBLabels.Variable_1#: #qgetBBInterfaceInfo.Voucher_Number#" /> <!--- Voucher Number--->
					<cfelse>
						<cfset vchNumber = "" />
					</cfif>
						<cfset interface_message ="This billback has been successfully loaded in ERP                         #ackDate# #add_new_Line#Send Date: #BB_Payment_Request_Sent_Date#                                          #paidDate# #add_new_Line##vchNumber#">
				<cfelseif qgetBBInterfaceInfo.BB_Received_Ack_Type EQ 2>
						<cfset interface_message ="This billback failed to get loaded in ERP #add_new_Line# Send Date: #BB_Payment_Request_Sent_Date# #add_new_Line#Acknowledge Date: #BB_Received_Ack_Date_Str# #add_new_Line# Paid Date: #qgetBBInterfaceInfo.Paid_Date#">
				</cfif>
			<cfelseif qgetBBInterfaceInfo.Billback_Status_ID EQ 8 AND qgetBBInterfaceInfo.BB_Approved_Void_Sent_On NEQ "">
				<cfset BB_Approved_Void_Sent_Date = "#DateFormat(qgetBBInterfaceInfo.BB_Approved_Void_Sent_On, "mm/dd/yyyy")# #TimeFormat(qgetBBInterfaceInfo.BB_Approved_Void_Sent_On, "hh:mm:ss tt")#" />
				<cfset BB_Approved_Void_Ack_Date_Str = "#DateFormat(qgetBBInterfaceInfo.BB_Approved_Void_Ack_Date, "mm/dd/yyyy")# #TimeFormat(qgetBBInterfaceInfo.BB_Approved_Void_Ack_Date, "hh:mm:ss tt")#" />

					<cfif (len(trim(qgetBBInterfaceInfo.Document_Number_2)) AND len(trim(qgetBBInterfaceInfo.Document_Number_1)))>
						<cfset vchNumber = "#stBBLabels.Variable_1#: #qgetBBInterfaceInfo.Document_Number_1#,#qgetBBInterfaceInfo.Document_Number_2#" />
					<cfelseif (len(trim(qgetBBInterfaceInfo.Document_Number_2)) EQ 0 AND len(trim(qgetBBInterfaceInfo.Document_Number_1)))>
						<cfset vchNumber = "#stBBLabels.Variable_1#: #qgetBBInterfaceInfo.Document_Number_1#" />
					<cfelseif (len(trim(qgetBBInterfaceInfo.Document_Number_2))  AND len(trim(qgetBBInterfaceInfo.Document_Number_1)) EQ 0)>
						<cfset vchNumber = "#stBBLabels.Variable_2#: #qgetBBInterfaceInfo.Document_Number_2#" />
					<cfelseif len(trim(qgetBBInterfaceInfo.Voucher_Number))>
						<cfset vchNumber = "#stBBLabels.Variable_1#: #qgetBBInterfaceInfo.Voucher_Number#" /> <!--- Voucher Number--->
					<cfelse>
						<cfset vchNumber = "" />
					</cfif>

				<cfif qgetBBInterfaceInfo.BB_Approved_Void_Ack_Type EQ 0>
						<cfset interface_message ="This billback reverse is being sent to ERP #add_new_Line# Send Date: #BB_Approved_Void_Sent_Date#">
				<cfelseif qgetBBInterfaceInfo.BB_Approved_Void_Ack_Type EQ 1>
						<cfset interface_message ="This billback reverse has been successfully loaded in ERP #add_new_Line#Send Date: #BB_Approved_Void_Sent_Date# #add_new_Line#Acknowledge Date: #BB_Approved_Void_Ack_Date_Str# #add_new_Line# #vchNumber#">
				<cfelseif qgetBBInterfaceInfo.BB_Approved_Void_Ack_Type EQ 2>
						<cfset interface_message ="This billback reverse failed to get loaded in ERP #add_new_Line# Send Date: #BB_Approved_Void_Sent_Date# #add_new_Line# Acknowledge Date: #BB_Approved_Void_Ack_Date_Str#">
				</cfif>
			</cfif>
		<cfreturn interface_message>
	</cffunction>

	<cffunction name="getBillbackApprovalInfo" output="false"  access="public" returntype="query">
	  <cfargument name="BillbackID" type="string" required="true">

		<cfquery name="qgetBillbackApprovalInfo" datasource="#application.datasource#">
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
			SELECT IsNull(bba.Expected_Amount,0) As Expected_Amount, IsNull(bba.Paid_Amount,0) As Paid_Amount,
				   IsNull((b.BB_Amount - bba.Expected_Amount),0) As ClaimedVsExpected, IsNull((b.BB_Amount - bba.Paid_Amount),0) As ClaimedVsPaid,
				   IsNull((bba.Expected_Amount - bba.Paid_Amount),0) As ExpectedVsPaid
				FROM Billback b
				LEFT JOIN BB_Approved bba
			  ON b.billback_id = bba.billback_id
			WHERE b.Billback_ID =  '#arguments.BillbackID#'
		</cfquery>

			<cfreturn qgetBillbackApprovalInfo>
	</cffunction>

	<cffunction name="getApprovableUserList" output="false" returntype="query" access="public">
	   <cfargument name="billbackID" type="string" required="true">

		<cfset var BillbackManager = CreateObject("component", "components.billback.BillbackManager").init() />
		<cfset qGetApprovableUsers = BillbackManager.getApprovableUsers(arguments.billbackID) />

		 <cfreturn qGetApprovableUsers>
	</cffunction>

	<cffunction name="getWorkFlowData" access="public" output="false" returntype="query">

		<cfargument name="billbackID" type="string" required="true" />
		<cfargument name="getTimeZoneOffSet" type="boolean" required="false" default="1" />
		<cfargument name="callFromCF" type="boolean" required="false" default="0" />

			<cfscript>
			 //set local variables
			 var sBillbackID		= "";
			 var objWorkflow		= "";
			 var qWorkflowData		= "";
			 var sReasonsForAgree		= "";
			 var arrRetData 		= ArrayNew(1);
			 var arrBBAgreeReason		= ArrayNew(1);

			 //assign local variables
			 sBillbackID 			= arguments.billbackID;
			</cfscript>

		<cfset objWorkflow = CreateObject("component", "components.workflow.BillbackWorkFlowManager") />
		<cfset qWorkflowData = objWorkflow.getWorkFlowData(sBillbackID,arguments.getTimeZoneOffSet,arguments.callFromCF) />

		<cfloop query="qWorkflowData">
			<cfset sReasonsForAgree = "">

			<!--- If the "Action" is "Agreed", then get the reasons for agreeing to the billback --->
			<cfif qWorkflowData.Action eq "Agreed">
				<cfset qgetBillbackAgreeReason = objWorkflow.getBillbackAgreeReason(sBillbackID,qWorkflowData.Action_User_ID)>

				<cfloop query="qgetBillbackAgreeReason">
					<cfset sReasonsForAgree =  ListAppend(sReasonsForAgree,qgetBillbackAgreeReason.Agree_Reason)>
				</cfloop>
			</cfif>
			 <!--- Add the billback agree reasons to the array. We need an array for "QueryAddColumn" --->
			<cfset arrBBAgreeReason[qWorkflowData.currentrow] = sReasonsForAgree>
		</cfloop>

		<!--- Add "Agree_Reasons" to the "qWorkflowData" query --->
		<cfset QueryAddColumn(qWorkflowData, "Agree_Reasons", "varchar", arrBBAgreeReason)>

		<cfreturn qWorkflowData />

	</cffunction>

	<cffunction name="getNextApprovableUsers" access="public" output="false" returntype="query">

		<cfargument name="billbackID" type="string" required="true" />

			<cfscript>
			//set local variables
			var sBillbackID			= "";
			var objWorkflowApprovableUser	= "";
			var qNextApprovableUserRet	= "";

			//assign local variables
			sBillbackID	= arguments.billbackID;

		</cfscript>

		<cfset objWorkflowApprovableUser = CreateObject("component", "components.workflow.BillbackWorkFlowManager") />
		<cfset qNextApprovableUserRet = objWorkflowApprovableUser.getNextApprovableUsers(sBillbackID) />

		<cfreturn qNextApprovableUserRet />

	</cffunction>

	<cffunction name="lockUnlockBBJSON" access="remote" output="false" returntype="string" returnformat="JSON">

		<cfargument name="billbackIDInt" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="lockUnlock" type="boolean" default="1" hint="1 = Lock, 0 = Unlock" />
		<cfargument name="toggleBB" type="boolean" default="0" hint="1 = action is Billback lock toggle, 0 = action is NOT Billback lock toggle" />
		<cfargument name="unlockExistingLockedByUser" type="boolean" default="0" hint="1 = Unlock, 0 = Nothing" />
		<cfargument name="bbClose" type="boolean" default="0" hint="1 = Called on closing a billback" />

		<cfscript>
			var a = arguments;
			var st = this.lockUnlockBB(a.billbackIDInt , a.userId , a.lockUnlock , a.toggleBB , a.unlockExistingLockedByUser, a.bbClose);
			st = application.util.struct.structSortLowerCase(st);

			var jsonData = '';
			jsonData = serializeJson(st);

			return jsonData;
		</cfscript>
	</cffunction>

	<!--- lockUnlockBB --->
	<cffunction name="lockUnlockBB" access="remote" output="false" returntype="struct">

		<cfargument name="billbackIDInt" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="lockUnlock" type="boolean" default="1" hint="1 = Lock, 0 = Unlock" />
		<cfargument name="toggleBB" type="boolean" default="0" hint="1 = action is Billback lock toggle, 0 = action is NOT Billback lock toggle" />
		<cfargument name="unlockExistingLockedByUser" type="boolean" default="0" hint="1 = Unlock, 0 = Nothing" />
		<cfargument name="bbClose" type="boolean" default="0" hint="1 = Called on closing a billback" /><!--- "bbClose" is not being used now in CF (only in flex), but it might be useful at a later time. --->

		<cfscript>
			//set local variables
			var nBillbackID					= "";
			var strUserID					= "";
			var qCheckBillbackLocked		= "";
			var qCheckBillbackUserLocked	= "";
			var qGetBillbackUserLocked		= "";
			var objBillbackDAO				= "";
			var qGetUserOnLock				= "";
			var strUserNameOnLock			= "";
			var stRetStruct					= structNew();
			var	bLockId						= 1;
			var stData						= structNew();

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
			strUserID	= arguments.userId;
			bLockId		= arguments.lockUnlock;

			objBillbackDAO = variables.oBillbackDAO;
			qCheckBillbackLocked 		= objBillbackDAO.getBBLockedByID(nBillbackID);
			qCheckBillbackUserLocked 	= objBillbackDAO.getBBLockedByUser(strUserID);
			//WriteLog("bb Lock AA :: #qCheckBillbackUserLocked.BB_Locked_By_User_ID# :: bLockId");
			/***********************************************************************************************************************
			Handle for the following scenarios:
				1:	Billback is locked by the user id passed to this function
				2:	Billback is locked not by the user id passed to this function
				3:	Billback is not locked but the user id passed in to this function has another billback locked
				4:	Billback is not locked and the user id passed in to this function does not have another billback locked
				objId:			Billback ID passed to function
				userId: 		User ID passed to function
				objIdLocked:	Billback ID locked by the user id passed to function
				userLocked:		User object currently locking the Billback ID passed to function
			*************************************************************************************************************************/
			//if lockUnlock = 0 then unlock this billback else lock this billback
			if (bLockId eq 0) // unlock
			{
				//call unlock function
				objBillbackDAO.setBBUnLocked(billbackIDInt = nBillbackID,userId = arguments.userId,unlockExistingLockedByUser = arguments.unlockExistingLockedByUser);
				structInsert(stRetStruct, "objId", nBillbackID);
				structInsert(stRetStruct, "userId", strUserID);
				structInsert(stRetStruct, "objIdLocked", "");
				structInsert(stRetStruct, "bLocked", JavaCast("boolean", 0));

				stData = structNew();
				structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
				structInsert(stData, "id", "");
				structInsert(stData, "idInt", "");
				structInsert(stData, "fullName", "");
				structInsert(stRetStruct, "userLocked", stData);
			}
			else // lock
			{
				//scenario 1 - billback is locked by the user id passed to this function
				if (qCheckBillbackLocked.RecordCount and qCheckBillbackUserLocked.RecordCount and (qCheckBillbackLocked.BB_Locked_By_User_ID eq strUserID))
				{
					structInsert(stRetStruct, "objId", nBillbackID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", nBillbackID);
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", strUserID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", qCheckBillbackUserLocked.Locked_By_User_Name);
					structInsert(stRetStruct, "userLocked", stData);
				}
				//scenario 2 - billback is locked not by the user id passed to this function
				if (qCheckBillbackLocked.RecordCount and (qCheckBillbackLocked.BB_Locked_By_User_ID neq strUserID))
				{
					qGetBillbackUserLocked =  objBillbackDAO.getBBLockedByUser(qCheckBillbackLocked.BB_Locked_By_User_ID);
					structInsert(stRetStruct, "objId", nBillbackID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", "");
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", qGetBillbackUserLocked.BB_Locked_By_User_ID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", qGetBillbackUserLocked.Locked_By_User_Name);
					structInsert(stRetStruct, "userLocked", stData);
				}
				//scenario 3 - billback is not locked but the user id passed in to this function has another billback locked
				else if (not qCheckBillbackLocked.RecordCount and qCheckBillbackUserLocked.RecordCount)
				{
					//temporary MWS.  Need to give user option to unlock*************************************
					//objBillbackDAO.setBBUnLocked(qCheckBillbackUserLocked.Billback_ID_Int);
					///temp**********************************************************************************
					structInsert(stRetStruct, "objId", nBillbackID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", qCheckBillbackUserLocked.Billback_ID_Int);
					structInsert(stRetStruct, "objIdLockedDesc", qCheckBillbackUserLocked.BB_Code);
					if (nBillbackID eq 0){
						structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));
					}
					else{
						structInsert(stRetStruct, "bLocked", JavaCast("boolean", 0));
					}

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", "");
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", "");
					structInsert(stRetStruct, "userLocked", stData);
				}
				//scenario 4 - billback is not locked and the user id passed in to this function does not have another billback locked
				else if (not qCheckBillbackLocked.RecordCount and not qCheckBillbackUserLocked.RecordCount)
				{	//WriteLog("bb Lock :: #qCheckBillbackUserLocked.BB_Locked_By_User_ID#");

					if (objBillbackDAO.setBBLocked(nBillbackID, strUserID) eq 1)
					{
						qGetUserOnLock = objBillbackDAO.getBBLockedByUser(strUserID);
						strUserNameOnLock = qGetUserOnLock.Locked_By_User_Name;
					}
					structInsert(stRetStruct, "objId", nBillbackID);
					structInsert(stRetStruct, "userId", strUserID);
					structInsert(stRetStruct, "objIdLocked", nBillbackID);
					structInsert(stRetStruct, "objIdLockedDesc", "");
					structInsert(stRetStruct, "bLocked", JavaCast("boolean", 1));

					stData = structNew();
					structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
					structInsert(stData, "id", strUserID);
					structInsert(stData, "idInt", "");
					structInsert(stData, "fullName", strUserNameOnLock);
					structInsert(stRetStruct, "userLocked", stData);
				}
			}

				/* Set "toggleLock" to 1, as it is being called from the "ToggleLock" functionality */
				if(arguments.toggleBB == 1)
				{
					structInsert(stRetStruct, "toggleLock", JavaCast("boolean", 1));
				}

				/* Set "unlockExistingLockedByUser" to whatever is being passed from flex.
				   Note: "unlockExistingLockedByUser" is true when the user copies a billback. This is necessary
				   as when the user copies a billback, the current billback is locked and the others are unlocked.
				*/
				structInsert(stRetStruct, "unlockExistingLockedByUser", JavaCast("boolean", arguments.unlockExistingLockedByUser));

			//stuff type into return struct
			structInsert(stRetStruct, "__type__", "mvc.Models.Entity.vos.Lock");

			return stRetStruct;
		</cfscript>

	</cffunction>

	<cffunction name="getDuplicateBillbacksJSON"  access="remote" output="false" returnformat="JSON">
		<cfargument name="billbackIDInt" 	required="true"	type="numeric" />
		<cfargument name="billbackNumber" 	required="true" type="string" />
		<cfargument name="vendorNumber" 	required="true" type="string" />

        <cfscript>
			var a = arguments;
			var st = this.getDuplicateBillbacks(a.billbackIDInt , a.billbackNumber, a.vendorNumber);
            st = application.util.struct.structSortLowerCase(st);

			var jsonData = '';
			jsonData = serializeJson(st);

			return jsonData;
		</cfscript>
    </cffunction>

	<!--- get duplicate billbacks --->
	<cffunction name="getDuplicateBillbacks" access="remote" output="false" returntype="array" hint="Retruns a struct of duplicate billbacks"><!--- returntype="mvc.Models.Billback.vos.BBHeader" --->
		<cfargument name="billbackIDInt" 	required="true"	type="numeric" />
		<cfargument name="billbackNumber" 	required="true" type="string" />
		<cfargument name="vendorNumber" 	required="true" type="string" />

		<cfscript>
			//set local variables
			var nBillbackIntId		= "";
			var strBillbackNumber	= "";
			var strVendorNumber		= "";
			var qGetDuplicates		= "";
			var retBBHeader			= createObject("component","mvc.Models.Billback.vos.BBHeader");
			var objUser				= createObject("component","mvc.Models.Entity.vos.User").init();
			var arrRetBBHeader 		= ArrayNew(1);

			//assign local variables
			nBillbackIntId		= arguments.billbackIDInt;
			strBillbackNumber 	= trim(arguments.billbackNumber);
			strVendorNumber		= trim(arguments.vendorNumber);

			qGetDuplicates = variables.oBillbackDAO.getBBDuplicateData(nBillbackIntId, strBillbackNumber, strVendorNumber);
		</cfscript>
		<cfset cntLoop = 1 />
		<cfloop query="qGetDuplicates">
			<cfscript>
				retBBHeader			= createObject("component","mvc.Models.Billback.vos.BBHeader");
				objUser.fullName = Created_By;
				retBBHeader.creator = objUser;
				retBBHeader.BBCode = trim(BB_Code);
				retBBHeader.title = BB_Title;
				retBBHeader.startDate = BB_Start_Date;
				retBBHeader.endDate = BB_End_Date;
				retBBHeader.amount = BB_Amount;
				retBBHeader.createdDate = Created_Date;
				arrRetBBHeader[cntLoop] = retBBHeader;
				cntLoop = cntLoop + 1;
			</cfscript>
		</cfloop>

		<cfscript>
			return arrRetBBHeader;
		</cfscript>

	</cffunction>

	<cffunction name="getProgramRatesJSON" access="remote" output="false" returntype="string" returnformat="JSON" hint="returns the bbPrgDistItemRate array with the program rates populated for blanks">

		<cfargument name="bbPrgDistItemRate"	required="true"		type="array" />
		<cfargument name="bbComponent"	required="true"		type="array" />

		<cfscript>
            var arrBBPDIR = this.getProgramRates(arguments.bbPrgDistItemRate , arguments.bbComponent);
            // Dont need to convert as the inoming is already lowercase object
			// arrBBPDIR = application.util.struct.structSortLowerCase(arrBBPDIR);
			var jsonData = '';
			jsonData = serializeJSON(arrBBPDIR);

			return jsonData;
		</cfscript>

    </cffunction>

	<!--- populate program rates for billback --->
	<cffunction name="getProgramRates" access="remote" output="false" returntype="array" hint="returns the bbPrgDistItemRate array with the program rates populated for blanks">

		<cfargument name="bbPrgDistItemRate"	required="true"		type="array" />
		<cfargument name="bbComponent"	required="true"		type="any" />

		<cfscript>
			var objProductRateManager 	= "";
			var arrBBPDIR 				= "";
			var arrBBComponent			= "";
			var compNameIDList				= "";

			// local variables
			objProductRateManager 		= CreateObject("component", "mvc.Models.Program.Component.ProductRateManager");
			arrBBPDIR					= arguments.bbPrgDistItemRate;
			arrBBComponent				= arguments.bbComponent;
			/* get the component name id from the component list */

			for(j=1; j <= ArrayLen(arrBBComponent); j++)
			{
                if (arrBBComponent[j].isselected){
                     compNameIDList = ListAppend(compNameIDList, arrBBComponent[j].ComponentNameID, ",");
                }
			}

			for(i=1; i <= ArrayLen(arrBBPDIR); i++)
			{
				var programId			=	'';
				var discountType		=	2;	//default to rebate(2)
				var itemGuid			=	'';
				var rate				=	0;
				var bbPDIR				=	arrBBPDIR[i];

				// if itemNumber and volume exist and no rate - then get the program rates				if(len(bbPDIR.bbProdRate.itemNumber) && (val(bbPDIR.bbProdRate.volume) == bbPDIR.bbProdRate.volume) && (!val(bbPDIR.bbProdRate.rate)))
				{
					programID 			= bbPDIR.bbProgram.programId;
					itemGuid 			= bbPDIR.bbProdRate.itemGuid;
					// discountType
					if(val(bbPDIR.bbProdRate.discountType) == bbPDIR.bbProdRate.discountType){discountType = val(bbPDIR.bbProdRate.discountType);}
					// get rate & amount
					rate 						= objProductRateManager.getProgramProductRate(programID, discountType, itemGuid, compNameIDList);
					bbPDIR.bbProdRate.rate		= val(rate);
					bbPDIR.bbProdRate.amount	= (bbPDIR.bbProdRate.rate * bbPDIR.bbProdRate.volume) ;
					arrBBPDIR[i] 				= bbPDIR;
				}
			}
			return arrBBPDIR;
		</cfscript>
	</cffunction>

	<!--- analyst for the billback payee--->
	<cffunction name="getBBAnalyst" access="remote" output="false" returntype="mvc.Models.Entity.vos.User"
				hint="returns the analyst/default analyst based on the payee for the billback">

		<cfargument name="bbPayee"	required="true"		type="struct" />

		<cfscript>

			// local variables
			var stBBPayee					= "";
			var sAnalystId					= "";
			var stAnalyst					= "";
			var qGetAnalysts				= "";
			var oBillbackAssignmentManager	= "";

			stBBPayee						=  arguments.bbPayee;
			stAnalyst					 	= CreateObject("component", "mvc.Models.Entity.vos.User").init();
			oBillbackAssignmentManager 		= CreateObject("component", "components.billback.BillbackAssignmentManager");

			if(stBBPayee.payeeTypeId == 1)
			{
				sAnalystId = oBillbackAssignmentManager.getAnalystForDistributor(stBBPayee.payeeId);
			}
			else if(stBBPayee.payeeTypeId == 2)
			{
				sAnalystId = oBillbackAssignmentManager.getAnalystForOperator(stBBPayee.payeeId);
			}

			// if still blank then get default analyst
			if (len(sAnalystId)){
				qGetAnalysts = oBillbackAssignmentManager.getAnalysts(analystUserId = sAnalystId,sourceCaller="FLEXBB");
			}else{
				qGetAnalysts = oBillbackAssignmentManager.getAnalysts(bDefaultAnalyst = 1);
			}

			stAnalyst.id		= qGetAnalysts.Analyst_User_ID;
			stAnalyst.idInt 	= qGetAnalysts.User_ID_Int;
			stAnalyst.fullName	= qGetAnalysts.Name_First & ' ' & qgetAnalysts.Name_Last;

			return stAnalyst;
		</cfscript>
	</cffunction>

	<!--- reverse billback --->
	<cffunction name="reverseBillback" access="remote" output="false" returntype="struct">
		<cfargument name="billbackIDInt" 	required="true"	type="numeric" />
		<cfargument name="userId" 			required="true"	type="string" />

		<cfscript>
			//set local variables
			var sBillbackId			= "";
			var sUserId				= "";
			var bReverseBB			= "";
			var stRetData 			= structNew();

			//assign local variables
			sBillbackId				= this.getBillbackUUID(arguments.billbackIDInt);
			sUserId					= arguments.userId;

			bReverseBB				= variables.oBillbackDAO.setReverseBillback(sBillbackId,sUserId);
			stRetData				= this.getBillback(arguments.billbackIDInt);

			return stRetData;
		</cfscript>

	</cffunction>

	<cffunction name="reverseBillbackJSON" access="remote" output="false" returntype="string" returnformat="JSON">
		<cfargument name="billbackIDInt" 	required="true"	type="numeric" />
		<cfargument name="userId" 			required="true"	type="string" />

		<cfscript>
			var a = arguments;
			var st = this.reverseBillback(a.billbackIDInt, a.userId);
			st = application.util.struct.structSortLowerCase(st);

			var jsonData = '';
			jsonData = serializeJson(st);

			return jsonData;
		</cfscript>

	</cffunction>

	<!--- set billback in queue for reinterface --->
	<cffunction name="setBBForReinterface" access="remote" output="false" returntype="struct">
		<cfargument name="billbackIDInt" required="true" type="numeric" />

		<cfscript>
		var stReturnData = structnew();
		stReturnData  = variables.oBillbackDAO.UpdateBBForReinterface(arguments.billbackIDInt);

		/* Return BBHeader so that BB search and edit can be refreshed on flex */
		return stReturnData;
		</cfscript>

	</cffunction>

	<!--- set billback in queue for reinterface --->
	<cffunction name="setBBForReinterfaceJSON" access="remote" output="false" returntype="string"  returnformat="JSON">
		<cfargument name="billbackIDInt" required="true" type="numeric" />

		<cfscript>
		var stReturnData = structnew();
		stReturnData  = variables.oBillbackDAO.UpdateBBForReinterface(arguments.billbackIDInt);
		stReturnData = application.util.struct.structSortLowerCase(stReturnData);

		var jsonData = '';
		jsonData = serializeJson(stReturnData);

		return jsonData;
		</cfscript>

	</cffunction>

	<cffunction name="getLockUnlockBBJSON" access="remote" output="false" returntype="string" returnformat="JSON">

		<cfargument name="billbackIDInt" type="numeric" required="true" />
		<cfargument name="unlockExistingLockedByUser" type="boolean" required="false" default="0" />

		<cfscript>
			var a = arguments;
			var st = this.getLockUnlockBB(a.billbackIDInt , a.unlockExistingLockedByUser);
			st = application.util.struct.structSortLowerCase(st);

			var jsonData = '';
			jsonData = serializeJson(st);

			return jsonData;
		</cfscript>
	</cffunction>

	<!--- getLockUnlockBB --->
	<cffunction name="getLockUnlockBB" access="remote" output="false" returntype="struct">

		<cfargument name="billbackIDInt" type="numeric" required="true" />
		<cfargument name="unlockExistingLockedByUser" type="boolean" required="false" default="0" />

		<cfscript>
			//set local variables
			var nBillbackID					= "";
			var strUserID					= "";
			var strUserNameOnLock			= "";
			var nIdLocked					= "";
			var strLockObjDesc				= "";
			var bBBIsLocked					= 0;
			var qCheckBillbackLocked		= "";
			var qGetBillbackUserLocked		= "";
			var bUnlockExistingLockedByUser		= 0;
			var objBillbackDAO				= "";
			var stRetStruct					= structNew();
			var stData						= structNew();

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;

			objBillbackDAO 				= variables.oBillbackDAO;
			qCheckBillbackLocked 		= objBillbackDAO.getBBLockedByID(nBillbackID);
			bUnlockExistingLockedByUser	= arguments.unlockExistingLockedByUser;
			/***********************************************************************************************************************
				objId:			Billback ID passed to function
				userId: 		User ID passed to function
				objIdLocked:	Billback ID locked by the user id passed to function
				userLocked:		User object currently locking the Billback ID passed to function
			*************************************************************************************************************************/

			// if the billback is locked then get the user data for the user who has it locked
			if (qCheckBillbackLocked.RecordCount){
				strUserID				= qCheckBillbackLocked.BB_Locked_By_User_ID;
				nIdLocked				= nBillbackID;
				bBBIsLocked				= 1;
				qGetBillbackUserLocked 	= objBillbackDAO.getBBLockedByUser(strUserID, nBillbackID);
				strUserNameOnLock		= qGetBillbackUserLocked.Locked_By_User_Name;
				strLockObjDesc			= qGetBillbackUserLocked.BB_Code;
			}
			structInsert(stRetStruct, "objId", nBillbackID);
			structInsert(stRetStruct, "userId", strUserID);
			structInsert(stRetStruct, "objIdLocked", nIdLocked);
			structInsert(stRetStruct, "objIdLockedDesc", strLockObjDesc);
			structInsert(stRetStruct, "bLocked", JavaCast("boolean", bBBIsLocked));

			stData = structNew();
			structInsert(stData, "__type__", "mvc.Models.Entity.vos.User");
			structInsert(stData, "id", strUserID);
			structInsert(stData, "idInt", "");
			structInsert(stData, "fullName", strUserNameOnLock);
			structInsert(stRetStruct, "userLocked", stData);

			/* Set "unlockExistingLockedByUser" to whatever is being passed from flex */
			structInsert(stRetStruct, "unlockExistingLockedByUser", JavaCast("boolean", bUnlockExistingLockedByUser));


			//stuff type into return struct
			structInsert(stRetStruct, "__type__", "mvc.Models.Entity.vos.Lock");

			return stRetStruct;
		</cfscript>

	</cffunction>

	<!--- Return BBHeader. This can be used whenever BBHeader on flex needs to be refreshed. --->
	<cffunction name="getBBHeader" access="remote" returntype="struct">
		<cfargument name="billbackIDInt" required="true" type="numeric" />

		<cfscript>
			var oBillbackLoadMgr = CreateObject("component","mvc.Models.Billback.BillbackLoadManager");
			var oBillbackSettlementMgr = CreateObject("component","mvc.Models.Billback.BillbackSettlementManager");
			var oBillbackSettlementDAO = CreateObject("component","mvc.Models.Billback.BillbackSettlementDAO").init();

			qGetBillbackData = variables.oBillbackDAO.getBBData(arguments.billbackIDInt);

			//build BBHeader data structure
			stHeaderData = structNew();
			stHeaderData["__type__"] = "mvc.Models.Billback.vos.BBHeader";
			//pass the query object to getCreateBillbackHeaderObject() and use the returned struct for BBHeader
			stHeaderData = oBillbackLoadMgr.getCreateBillbackHeaderObject(qGetBillbackData);
			//get approved amount from deviations
			stHeaderData = oBillbackSettlementDAO.getApprovalAmount(stHeaderData);
			//get closing details (payment info)
			stHeaderData = oBillbackSettlementMgr.setBBHeaderBBClosingDetail(stHeaderData);

			return stHeaderData;
		</cfscript>

	</cffunction>

	<!--- Returns an array of BBheader. This can be used whenever a list of BBHeader(s) on flex needs to be refreshed. --->
	<cffunction name="getBBHeaderList" access="remote" returntype="Array">
		<cfargument name="billbackIDIntList" required="true" type="string" />

		<cfset var arrBBHeaderList = ArrayNew(1)>

		<!--- build BBHeader data structure --->
		<cfset stHeaderData = structNew()>

		<!--- Loop through the billback list and create a structure of bbHeaders. Add the struct to the "arrHeaderData" array --->
		<cfloop list="#arguments.billbackIDIntList#" index="bbIDInt">
			<cfset stHeaderData = getBBHeader(bbIDInt)> <!---Pass "Billback_ID_int"--->
			<cfset ArrayAppend(arrBBHeaderList,duplicate(stHeaderData))>
		</cfloop>

		<cfreturn arrBBHeaderList>

	</cffunction>

	<!---
		This function is useful to dump the value to a output file from <cfscript> block
		USAGE:
			<cfscript>
				dumper(dumpVariable,"C:\temp\filename.txt");
			</cfscript>

	--->
	<cffunction name="dumper" access="remote" output="false">
		<cfargument name="arrBBPDIR"	required="true"		type="any" />
		<cfargument name="filename" required = "true" type="string" />
		<cfdump var="#arguments.arrBBPDIR#" output="#arguments.filename#" />
		<cfreturn />
	</cffunction>

	<!--- Find whether the billback is split or not, i.e. whether the billback has children billbacks associated with it. --->
	<cffunction name="getIsSplit" access="public" returntype="boolean">
		<cfargument name="Billback_ID" 	required="true"	type="string" />

		<cfset var bIsSplit = 0>

		<cfquery name="qgetIsSplit" datasource="#application.datasource#">
			SELECT Billback_ID
			FROM Billback
			WHERE bb_Parent_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="CF_SQL_VARCHAR" />
			AND deleted = 0
		</cfquery>

		<cfset bIsSplit = qgetIsSplit.recordcount>

		<cfreturn bIsSplit>
	</cffunction>

<cffunction name="checkReprocessLock" access="public" returntype="query" output="false" >

		<cfset var qCheckReprocessLock = "" />
		<cfquery name="qCheckReprocessLock" datasource="#application.datasource#">
			SELECT 		ISNULL(BB_Reprocess_Lock.IS_LOCKED, 0) AS IS_LOCKED,
						BB_Reprocess_Lock.USER_ID,
						(NAME_FIRST + ' ' + NAME_LAST) AS LOCKER
			FROM		BB_Reprocess_Lock
			LEFT JOIN	_USERS
			ON			_USERS.USER_ID =  BB_Reprocess_Lock.USER_ID
			WHERE		BB_Reprocess_Lock.DELETED = 0
			AND			BB_Reprocess_Lock.IS_LOCKED = 1
			ORDER BY	IS_LOCKED DESC
		</cfquery>

		<cfreturn qCheckReprocessLock />
	</cffunction>

	<!--- Lock the page --->
	<cffunction name="lockReprocessPage" access="public" returntype="boolean" >
		<cfargument name="user_id" type="string" required="true">

		<cfset var qLock = "" />
		<cfset var temp = this.unlockReprocessPage()/> <!--- unlock first others --->

		<cfquery name="qLock" datasource="#application.datasource#">
			INSERT INTO		BB_Reprocess_Lock (User_ID,Is_Locked)
			VALUES			(<cfqueryparam value="#arguments.user_id#" cfsqltype="cf_sql_varchar">,
							 <cfqueryparam value="1" cfsqltype="cf_sql_varchar">)
		</cfquery>

		<cfreturn true />
	</cffunction>


	<!--- Unlock the page --->
	<cffunction name="unlockReprocessPage" access="public" returntype="boolean" >

		<cfset var qUnlock = "" />
		<cfquery name="qUnlock" datasource="#application.datasource#">
			UPDATE		BB_Reprocess_Lock
			SET			Is_Locked = <cfqueryparam value="0" cfsqltype="cf_sql_bit">,
						Deleted = <cfqueryparam value="1" cfsqltype="cf_sql_bit">
			WHERE		Is_Locked = 1
			AND			Deleted = 0
		</cfquery>

		<cfreturn true />
	</cffunction>

</cfcomponent>


