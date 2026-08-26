<!---
Name: 			BillbackSettlementManager.cfc
Copyright:		(c) 2011 Blacksmith Applications, Inc.
Created Date:  	06.27.2011
Created By:    	Mark Saunders
Description:	Manager for Handling BB settlement service requests for
				Flex BB workflow tool
Parameters:		N/A
Usage:			N/A
--->

<cfcomponent  name="BillbackSettlementManager" displayname="BillbackSettlementManager" alias="mvc.Models.Billback.BillbackSettlementManager" extends="mvc.Models.SettingsService"  >

	<cfscript>
		// DAO
		this.BBSettlementDAO 		= CreateObject("component","mvc.Models.Billback.BillbackSettlementDAO");
		this.DedDAO 				= CreateObject("component","mvc.Models.Deduction.DeductionDAO");
		this.DedMgr 				= CreateObject("component","mvc.Models.Deduction.DeductionManager");
		this.MCObject 				= createObject('component','components.Match_Central.MatchCentral').init();
		this.oBillbackDAO 			= CreateObject("component","mvc.Models.Billback.BillbackDAO");
		this.BBMgr					= CreateObject("component","mvc.Models.Billback.BillbackManager");
		this.BillbackSplitManager	= CreateObject("component","components.billback.BillbackSplitManager").init();
		this.profileMgr				= CreateObject("component","components.user.Profile").init();
		this.objBillbackLoadManager	= CreateObject("component","mvc.Models.Billback.BillbackLoadManager");
	</cfscript>

	<cffunction name="lockDeductionJSON" output="false" access="remote" returntype="string" returnformat="JSON">
		<cfargument name="arrDeduction" type="string" required="true">
		<cfargument name="bLock" type="boolean" required="true">

		<cfscript>
			var arr = deserializejson(arguments.arrDeduction);
			var response = lockDeduction(arr,arguments.bLock);
			return serializeJson(response);
		</cfscript>

	</cffunction>
	<!--- lock deviation --->
	<cffunction name="lockDeduction" output="false" access="remote" returntype="Array">
		<cfargument name="arrDeduction" type="Array" required="true">
		<cfargument name="bLock" type="boolean" required="true">
		<cfscript>
			//set local variables
			var ddId				= 	'';
			var oDeduction			= 	'';
			var objLock				= 	'';
			var lockUserId			=	'';
			var thisUserId			=	'';
			var arrObjLock			= 	ArrayNew(1);
			for (i=1;i LTE ArrayLen(arrDeduction);i=i+1) {
				ddId				= 	arrDeduction[i].deductionID;
				oDeduction			= 	this.DedMgr.getDeduction(ddId);
				objLock				= 	oDeduction.lockObj;
				lockUserId			=	objLock.userLocked.id;
				thisUserId			=	request.accessStructure.User_ID;

				if (arguments.bLock && !objLock.bLocked){
					this.BBSettlementDAO.lockDeduction(ddId,thisUserId);
					oDeduction = this.DedMgr.getDeduction(ddId);
					oDeduction = this.DedMgr.getDeduction(ddId);
				}
				else if(!arguments.bLock && lockUserId == thisUserId) {
					this.BBSettlementDAO.unLockDeduction(ddId);
					oDeduction = this.DedMgr.getDeduction(ddId);
				}
				ArrayAppend(arrObjLock,Duplicate(oDeduction));
			}
			return arrObjLock;
		</cfscript>

	</cffunction>
	<!--- take a bbheader obj and set the bbClosingDetail property --->
	<cffunction name="setBBHeaderBBClosingDetail" returntype="struct" access="public" hint="get expected amount for approval">
		<cfargument name="bbHeader" type="struct">
		<cfargument name="bAllClosingMethods" type="boolean" default="1">

		<cfscript>
			//set local variables
			var _bbHeader = arguments.bbHeader;
			var billbackProgramManager = CreateObject("component", "components.billback.Programs.BillbackProgramsManager").init();
			var budgetManager = CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager");

			_bbHeader.bbSettlement.bbClosingDetail = this.getBillbackSettlement(arguments.bbHeader.billbackIDInt,arguments.bAllClosingMethods);
			//this.dmp(_bbHeader.bbSettlement.bbClosingDetail);
			_bbHeader.bbSettlement.templateApproval = this.getBBTemplateApproval(bbHeader.billbackIDGUID,request.AccessStructure.Profiles_ID);
			//last date to claim
			billbackProgramManager.setBillbackProgramID(billbackProgramManager.getBillbackPrograms(_bbHeader.billbackIDGUID).Program_ID);
			billbackProgramManager.setBillbackID(_bbHeader.billbackIDGUID);
			//boolean
			_bbHeader.bbSettlement.lastDateToClaim = ( billbackProgramManager.getLastDateToClaim().RecordCount > 0 );
			//budgets - only find if within budget if billback not approved
			if(_bbHeader.status.id < 3) {
				_bbHeader.bbSettlement.bIsBillbackWithinBudget = budgetManager.isBillbackDollarWithinBudget(bbHeader.billbackIDGUID) ;
			}
			else {
				_bbHeader.bbSettlement.bIsBillbackWithinBudget = 1;
			}
			_bbHeader.bbSettlement.bIsReversible		   = this.getIsBBReversible(arguments.bbHeader.billbackIDInt);
		</cfscript>

		<cfset BBClosingDetailObj 	  		= _bbHeader.bbSettlement.bbClosingDetail/>
		<cfset BBClosingDetailObjLen 		= arrayLen(BBClosingDetailObj) />
		 <cfif BBClosingDetailObjLen GTE 1>
			<cfloop index="i" from="1" to="#BBClosingDetailObjLen#">
				<cfif _bbHeader.bbSettlement.bbClosingDetail[i].PaymentNotes NEQ "">  <!--- isDefined(("_bbHeader.bbSettlement.bbClosingDetail[i].PaymentNotes")) AND  --->
					<cfset _bbHeader.bbSettlement.paymentNotes = BBClosingDetailObj[i].paymentNotes />
				</cfif>
				<cfset _bbHeader.bbSettlement.bSpecialHandling = evaluate(#BBClosingDetailObj[i].specialHandling#) />
			</cfloop>
		</cfif>

		<cfreturn _bbHeader />
	</cffunction>

	<!---
			D30670: Flex BB Reverse - do not allow until billback is ackd/Anand Rao/29-Feb-2012
			This function checks the no. of closing methods in the Billback and also checks if that
			many no. of SapDocument# is available in the BB_Approved table(Max No. of SAP # is 2
			and the BB can have a max of 2 closing methods, which should cover 99.999% of the
			possibilities).  Also we do not include Write off and Reinstate as closing methods
			here.
	--->
<!---	<cffunction name="getIsBBReversible" returntype ="Boolean"	access="remote" hint="check the parent and children BB and return if the BB is reversible based on the Doc number field">
		<cfargument name="argBillbackIDInt" type="numeric">

		<cfscript>
			var bReverseIsPossible = 0;
			var Billback_ID  		  = this.oBillbackDAO.getBillbackUUID(arguments.argBillbackIDInt);
			var BBInfo				  = this.MCObject.getBBInfo(Billback_ID);
			var arrBillbackWithCMs 	  = this.getBillbackSettlement(argBillbackIDInt = arguments.argBillbackIDInt,bReturnOnlyAvailableCMs=1);
			var arrBillbackWithCMsLen = arrayLen(arrBillbackWithCMs);
			var availableCMsCount	  = 0;
			var is_WO_InClosingmethod = 0;
		</cfscript>

		<!---- Check to see if the Billback can be reversed --->
		<cfloop index="iLoopCtr" from ="1" to="#arrBillbackWithCMsLen#">
			<cfswitch expression="#arrBillbackWithCMs[iLoopCtr].closingMethod.ID#">
			<!--- Special handle for Closing method = writeoff --->
				<cfcase value="9">
					<cfset availableCMsCount = availableCMsCount + 1 />
					<cfset is_WO_InClosingmethod = 1 />
				</cfcase>
				<cfcase value="1,2,5,6,7,8">
					<cfset availableCMsCount = availableCMsCount + 1 />
				</cfcase>
			</cfswitch>
		</cfloop>

		<!--- Has this billback been split, i.e. more than 1 closing method associated with it,
		where the others are the child of the parent bb.
		--->
		<cfset bIsSplit = this.BBMgr.getIsSplit(Billback_ID)>

		<!--- if writeoff was one of the closing method,then remove it from the total count,
			  if there were more than 2 closing methods since we will have only one
			  document numner
			  --->
		<cfif (is_WO_InClosingmethod EQ 1 AND availableCMsCount GTE 2)>
			<cfset availableCMsCount = availableCMsCount - 1 />
		</cfif>

		<!--- This should take care of a billback with 1 split (eg: payment and deduction) OR billback with no splits (eg: payment only) --->
		<cfif (availableCMsCount EQ 1) OR bIsSplit eq 0>
			<cfif ((BBInfo.Document_Number_1 NEQ "" OR BBInfo.Document_Number_2 NEQ "") AND BBInfo.BB_Reversed EQ 0)>
				<cfset bReverseIsPossible = 1 />
			</cfif>
		<cfelseif availableCMsCount EQ 2>
			<cfif ((BBInfo.Document_Number_1 NEQ "" AND BBInfo.Document_Number_2 NEQ "") AND BBInfo.BB_Reversed EQ 0)>
				<cfset bReverseIsPossible = 1 />
			</cfif>
		</cfif>

		<cfreturn bReverseIsPossible />
	</cffunction>

--->
      <cffunction name="getIsBBReversible" returntype ="Boolean"  access="remote" hint="check the parent and children BB and return if the BB is reversible based on the Doc number field">
            <cfargument name="argBillbackIDInt" type="numeric">

            <cfscript>
                  var bReverseIsPossible = 0;
                  var Billback_ID           = this.oBillbackDAO.getBillbackUUID(arguments.argBillbackIDInt);
                  var BBInfo                      = this.MCObject.getBBInfo(Billback_ID);
                  var arrBillbackWithCMs   = this.getBillbackSettlement(argBillbackIDInt = arguments.argBillbackIDInt,bReturnOnlyAvailableCMs=1);
                  var arrBillbackWithCMsLen = arrayLen(arrBillbackWithCMs);
                  var otherCMsCount   = 0;
                  var is_DD_InClosingmethod = 0;
            </cfscript>

            <!---- Check to see if the Billback can be reversed --->
            <cfloop index="iLoopCtr" from ="1" to="#arrBillbackWithCMsLen#">
                  <cfswitch expression="#arrBillbackWithCMs[iLoopCtr].closingMethod.ID#">
                  <!--- Special handle for Closing method = writeoff --->
                        <cfcase value="2">
                              <cfset is_DD_InClosingmethod = 1 />
                        </cfcase>
                        <cfcase value="1,5,6,7,8"><!--- not deduction ()2), not write off (9) --->
                              <cfset otherCMsCount = 1 />
                        </cfcase>
                  </cfswitch>
            </cfloop>

            <!---
            If the BB is split as deduction and another closing method other than BB write off â€“ Only then expect 2 document #s
            If the BB is split with closing methods other than deduction then either Doc #1 or Doc #2 should be populated.
            If the BB is not split then either Doc #1 or Doc #2 should be populated.
            --->
            <cfif is_DD_InClosingmethod EQ 1 AND otherCMsCount GT 0>
                  <cfif ((BBInfo.Document_Number_1 NEQ "" AND BBInfo.Document_Number_2 NEQ "") AND BBInfo.BB_Reversed EQ 0)>
                        <cfset bReverseIsPossible = 1 />
                  </cfif>
            <cfelse>
                  <cfif ((BBInfo.Document_Number_1 NEQ "" OR BBInfo.Document_Number_2 NEQ "") AND BBInfo.BB_Reversed EQ 0)>
                        <cfset bReverseIsPossible = 1 />
                  </cfif>
            </cfif>

            <cfreturn bReverseIsPossible />
      </cffunction>



    <!---
		This function will get the BBHeader object and do the below:
		a) check to see if there are any child BBs for a billback and so
	--->
	<cffunction name="getBillbackSettlement" returntype="Array" access="remote" hint="processes and saves the settlement tab records"><!--- processAndSaveMatched --->
		<cfargument name="argBillbackIDInt" type="numeric">
		<cfargument name="bAllClosingMethods" type="boolean" default="1">
		<cfargument name="bReturnOnlyAvailableCMs" type="boolean" default="0">


		<cfscript>
			//var oBillbackDAO 			= CreateObject("component","mvc.Models.Billback.BillbackDAO");
			var Billback_ID  			= this.oBillbackDAO.getBillbackUUID(arguments.argBillbackIDInt);
			var qGetBBChildren		 	= this.oBillbackDAO.getBBChildren(Billback_ID);
			var BBInfo					= this.MCObject.getBBInfo(Billback_ID,1);
		//	var oBillbackMan 			= CreateObject("component","mvc.Models.Billback.BillbackManager").init();
			var BBClosingDetail 		= createObject("component","mvc.Models.Billback.vos.BBClosingDetail").init();
			var BBStatus				= createObject("component","mvc.Models.Billback.vos.Status").init();
			var ClosingMethodObj		= createObject("component","mvc.Models.Billback.vos.ClosingMethod").init();
			var deductionObj			= createObject("component","mvc.Models.Deduction.vos.Deduction").init();
			var arrClosingMethodDetails = ArrayNew(1);
			var bIncludeProfile			= 1;
		</cfscript>
		<cfquery name="HasBeenAgreed" datasource="#application.datasource#">
		 	SELECT BB_Agreed_Info.Agreed_Amount
			FROM BB_Agreed_Info
			WHERE BB_Agreed_Info.Billback_ID = <cfqueryparam value="#BBInfo.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND BB_Agreed_Info.Deleted = 0
		</cfquery>
		<cfif (BBInfo.Billback_Status_ID GTE 3)>
			<cfset bIncludeProfile = 0 />
		</cfif>

 		<cfset arrGetAllClosingMethods = this.objBillbackLoadManager.getAllClosingMethods(UseselectedRecords = 0,selectedRecords="",includeBEnabled=0,includeProfile=bIncludeProfile) />
		<cfif (isDefined("qGetBBChildren") AND qGetBBChildren.RecordCount GTE 1)>
		<!--- TODO: Loop through each record and get the approval status--->
			<cfloop query="qGetBBChildren">

				<cfswitch expression="#qGetBBChildren.BB_Closing_Method#">
				<cfcase value="1,5,6,7,8,9,10">
					<cfloop index="iLoop" from ="1" to="#ArrayLen(arrGetAllClosingMethods)#">
						<cfif ((qGetBBChildren.Billback_Status_ID GTE 3) OR  (arrGetAllClosingMethods[iLoop].id EQ qGetBBChildren.BB_Closing_Method))>
							<cfset BBStatus.id 						= qGetBBChildren.Billback_Status_ID />
							<cfset BBStatus.description 			= qGetBBChildren.BB_Status_Description />
							<cfset BBStatus.abbreviation 			= qGetBBChildren.BB_Status_Abbreviation />
							<!--- <cfset BBClosingDetail.billbackID 		= qGetBBChildren.billback_ID /> --->
							<cfset qGetBillbackData 				=  this.BBMgr.getBillbackData(arguments.argBillbackIDInt) />

							<cfset ClosingMethodObj.id				= qGetBBChildren.BB_Closing_Method />
							<cfset ClosingMethodObj.description		= qGetBBChildren.Closing_Method_Description />
							<cfset ClosingMethodObj.abbreviation 	= qGetBBChildren.Abbreviation />
							<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />

							<cfset BBClosingDetail.amount 		 	= qGetBBChildren.BB_Amount />
							<cfset BBClosingDetail.deduction		= duplicate(deductionObj)  />
							<!---<cfset BBClosingDetail.bbStatus			= BBStatus />--->
							<!--- cfset BBClosingDetail.specialHandling 	= qGetBBChildren.SpecialHandling /--->
							<cfset BBClosingDetail.specialHandling 	= BBInfo.SpecialHandling />
							<cfset BBClosingDetail.paymentNotes 	= BBInfo.Payment_Notes />
						</cfif>
					</cfloop>
				</cfcase>
				<cfcase value="2">
				<cfloop index="iLoop" from ="1" to="#ArrayLen(arrGetAllClosingMethods)#">
						<cfif ((qGetBBChildren.Billback_Status_ID GTE 3) OR  (arrGetAllClosingMethods[iLoop].id EQ qGetBBChildren.BB_Closing_Method))>
				<cfset thisBBId = qGetBBChildren.Billback_ID />
				<cfset BBClosingDetail = this.getClosingMethodDetailsSingle(
																	billbackID=thisBBId,
																	BB_Closing_Method=qGetBBChildren.BB_Closing_Method,
																	BB_Associated_To_DD=qGetBBChildren.BB_Associated_To_DD,
																	Billback_Status_ID=qGetBBChildren.Billback_Status_ID,
																	BB_Status_Description = qGetBBChildren.BB_Status_Description,
																	BB_Status_Abbreviation = qGetBBChildren.BB_Status_Abbreviation,
																	BB_Amount = qGetBBChildren.Approved_Amount,
																	SplHandlingMessage = qGetBBChildren.SpecialHandling,
																	billbackIDInt	   = qGetBBChildren.Billback_ID_Int
																	) />

							<cfset ClosingMethodObj.id				= qGetBBChildren.BB_Closing_Method />
							<cfset ClosingMethodObj.description		= qGetBBChildren.Closing_Method_Description />
							<cfset ClosingMethodObj.abbreviation 	= qGetBBChildren.Abbreviation />
							<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />

					<!--- <cfset BBClosingDetail.specialHandling 	= qGetBBChildren.SpecialHandling /> --->
						<cfset BBClosingDetail.specialHandling 	= BBInfo.SpecialHandling />
						<cfset BBClosingDetail.paymentNotes 	= BBInfo.Payment_Notes />
					</cfif>
					</cfloop>
				</cfcase>
				<!--- TODO: Handling for other closing method to be done! ---->
				<!--- <cfcase value="8">
					<cfset BBStatus.id 						= qGetBBChildren.Billback_Status_ID />
					<cfset BBStatus.description 			= qGetBBChildren.BB_Status_Description />
					<cfset BBStatus.abbreviation 			= qGetBBChildren.BB_Status_Abbreviation />
					<!--- <cfset BBClosingDetail.billbackID 		= qGetBBChildren.billback_ID /> --->
					<cfset qGetBillbackData 				=  this.BBMgr.getBillbackData(arguments.argBillbackIDInt) />
					<!--- //build BBHeader data structure --->
					<cfset stHeaderData						= structNew() />
					<cfset stHeaderData["__type__"] 		= "mvc.Models.Billback.vos.BBHeader" />
					<cfset stHeaderData 					= this.objBillbackLoadManager.getCreateBillbackHeaderObject(qGetBillbackData) />
					<cfset BbClosingDetail.bbHeader			= stHeaderData />
					<cfset ClosingMethodObj.id				= qGetBBChildren.BB_Closing_Method />
					<cfset ClosingMethodObj.description		= qGetBBChildren.Closing_Method_Description />
					<cfset ClosingMethodObj.abbreviation 	= qGetBBChildren.Abbreviation />
					<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />
					<cfset BBClosingDetail.amount 		 	= qGetBBChildren.BB_Amount />
					<cfset BBClosingDetail.deduction		= duplicate(deductionObj)  />
					<!---<cfset BBClosingDetail.bbStatus			= BBStatus />--->
					<cfset BBClosingDetail.specialHandling 	= qGetBBChildren.SpecialHandling />
				</cfcase> --->

			</cfswitch>
				<!--- <cfset arrayAppend(arrClosingMethodDetails,BBClosingDetail) />	 --->
				 <cfset ArrayAppend(arrClosingMethodDetails, duplicate(BBClosingDetail))>
			</cfloop>
		<cfelse>
			<!--- <cfquery name="GetBBApprovedRecords" datasource="#application.datasource#">
				SELECT *
				FROM BB_Approved
				WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery> --->
			<!---
				Case 1: Only one billback, no children, 1 record in BB_Approved
		 	--->

			<cfswitch expression="#BBInfo.BB_Closing_Method#">
				<cfcase value="1,5,6,7,8,9,10">
					<cfloop index="iLoop" from ="1" to="#ArrayLen(arrGetAllClosingMethods)#">
						<cfif ((BBInfo.Billback_Status_ID GTE 3) OR  (arrGetAllClosingMethods[iLoop].id EQ BBInfo.BB_Closing_Method))>
							<cfset BBStatus.id 						= BBInfo.Billback_Status_ID />
							<cfset BBStatus.description 			= BBInfo.BB_Status_Description />
							<cfset BBStatus.abbreviation 			= BBInfo.BB_Status_Abbreviation />
							<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />
							<cfset ClosingMethodObj.id				= BBInfo.BB_Closing_Method />
							<cfset ClosingMethodObj.description		= BBInfo.Closing_Method_Description />
							<cfset ClosingMethodObj.abbreviation 	= BBInfo.Abbreviation />
							<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />

						    <cfset BBClosingDetail.deduction		= duplicate(deductionObj) />
							<!---<cfset BBClosingDetail.bbStatus			= BBStatus />--->
							<cfset BBClosingDetail.specialHandling 	= BBInfo.SpecialHandling />
							<cfset BBClosingDetail.paymentNotes 	= BBInfo.Payment_Notes />

							<!---	BBInfo.Approved_Amount NEQ 0 AND  --->
							<!---	Dev Note: Milan (30792) We do need an amount for billbacks which are not in approved status as we
								have removed the "save" button from the settlement page. If we need to add that feature back, please do not
								add this code back. Instead, save the amount in a table, just like agreed amount.
							--->
							<!--- Dev Note: Tim Ford (31246)
								Had to add the BBInfo.Billback_Status_ID LTE 2 if statement back but changed the set amount to BB_Approved_Amount.
								This handles for the scenario where a user agrees to a billback with just a single payment closing method.

							<cfif BBInfo.Billback_Status_ID LTE 2>
								<cfset BBClosingDetail.amount	= BBInfo.BB_Approved_Amount />
							<cfelse>
								<cfset BBClosingDetail.amount	= BBInfo.Approved_Amount />
							</cfif>
							--->
							<cfif (BBInfo.Billback_Status_ID LTE 2 AND HasBeenAgreed.RecordCount EQ 0)>
								<cfset BBClosingDetail.amount	= 0.00 />
							<cfelse>
								<cfset BBClosingDetail.amount	= BBInfo.BB_Approved_Amount />
							</cfif>
							<cfset ArrayAppend(arrClosingMethodDetails, duplicate(BBClosingDetail))>
						</cfif>
					</cfloop>
				</cfcase>
				<cfcase value="2">
					<cfloop index="iLoop" from ="1" to="#ArrayLen(arrGetAllClosingMethods)#">
						<cfif ((BBInfo.Billback_Status_ID GTE 3) OR  (arrGetAllClosingMethods[iLoop].id EQ BBInfo.BB_Closing_Method))>
 							<cfset BBClosingDetail = this.getClosingMethodDetailsSingle(
										billbackID=BBInfo.Billback_ID,
										BB_Closing_Method=BBInfo.BB_Closing_Method,
										BB_Associated_To_DD=BBInfo.BB_Associated_To_DD,
										Billback_Status_ID=BBInfo.Billback_Status_ID,
										BB_Status_Description = BBInfo.BB_Status_Description,
										BB_Status_Abbreviation = BBInfo.BB_Status_Abbreviation,
										BB_Amount = BBInfo.BB_Amount,
										SplHandlingMessage = BBInfo.SpecialHandling,
										billbackIDInt	   = BBInfo.Billback_ID_Int
										) />


							<cfset ClosingMethodObj.id				= BBInfo.BB_Closing_Method />
							<cfset ClosingMethodObj.description		= BBInfo.Closing_Method_Description />
							<cfset ClosingMethodObj.abbreviation 	= BBInfo.Abbreviation />
							<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />
							<cfset BBClosingDetail.specialHandling 	= BBInfo.SpecialHandling />
							<cfset BBClosingDetail.paymentNotes 	= BBInfo.Payment_Notes />
							<cfset ArrayAppend(arrClosingMethodDetails, duplicate(BBClosingDetail))>
						</cfif>
					</cfloop>
				</cfcase>
			</cfswitch>
		</cfif>

		<!---
			D30670: Flex BB Reverse - do not allow until billback is ackd/Anand Rao/29-Feb-2012
			based on the argument passed this will stop the processing of the function and return what it has got in the
			array ie., only the BBs and its closing methods.
		--->
		<cfif arguments.bReturnOnlyAvailableCMs EQ 1>
			<cfreturn arrClosingMethodDetails />
		</cfif>

		<!---	Dev Note: Milan - 28817 - arguments.bAllClosingMethods is 1, when we approve multiple billbacks from the flex grid and need to call this function
			to get the closing method details. In that case, I do not need to call the code below. Calling the code below createsissues for multiple
			billback approval while clicking on the "save" button on the "settlement" screen. The issue occurs when using deductions is included in the closing method.
		--->
		<cfif arguments.bAllClosingMethods eq 1>
			<!--- Check to see if there are any more deductions for the given Billback_ID --->
			<cfset useLakebaseForchkForOtherDDs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForchkForOtherDDs>
	<cftry>
		<cfset chkForOtherDDs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"split_by_billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForchkForOtherDDs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForchkForOtherDDs>
<cfquery name="chkForOtherDDs" datasource="#application.datasource#">
				SELECT * FROM
				Deductions WHERE
				Split_By_Billback_ID = '#Billback_ID#' AND Deleted = 0
			</cfquery>
</cfif>

			<cfset arrDedIdsToAdd = ArrayNew(1) />
			<cfif isDefined("chkForOtherDDs") AND chkForOtherDDs.RecordCount GTE 2>

				<cfloop query = "chkForOtherDDs">
					<cfset MatchFound = 0 />
					<cfloop index = "idx" from = "1" to ="#ArrayLen(arrClosingMethodDetails)#">
					 <cfset currDeduction = arrClosingMethodDetails[idx].Deduction />
						<cfif (isStruct(currDeduction) AND structKeyExists(currDeduction, "DeductionID"))>
							<cfif  arrClosingMethodDetails[idx].Deduction.DeductionID NEQ "">
								<cfif (chkForOtherDDs.Deduction_ID EQ arrClosingMethodDetails[idx].Deduction.DeductionID)>
									<cfset MatchFound = 1 />
									<cfbreak>
								</cfif>
							</cfif>
						</cfif>
					</cfloop>
					<cfif MatchFound EQ 0>
						<!--- Add the Deduction to the array--->
						<cfset ArrayAppend(arrDedIdsToAdd,chkForOtherDDs.Deduction_ID) />
					</cfif>
				</cfloop>

			</cfif>

			<cfif (ArrayLen(arrDedIdsToAdd) GTE 1)>

				<cfloop index="iLooper" from ="1" to="#ArrayLen(arrDedIdsToAdd)#">

					<cfset BBClosingDetail = this.getClosingMethodDetailsSingle(
											billbackID=BBInfo.Billback_ID,
											BB_Closing_Method=BBInfo.BB_Closing_Method,
											BB_Associated_To_DD=BBInfo.BB_Associated_To_DD,
											Billback_Status_ID=BBInfo.Billback_Status_ID,
											BB_Status_Description = BBInfo.BB_Status_Description,
											BB_Status_Abbreviation = BBInfo.BB_Status_Abbreviation,
											BB_Amount = BBInfo.BB_Amount,
											SplHandlingMessage = BBInfo.SpecialHandling,
											billbackIDInt	   = BBinfo.Billback_ID_Int
											) />
					<cfset BBClosingDetail.specialHandling 	= BBInfo.SpecialHandling />
					<cfset BBClosingDetail.paymentNotes 	= BBInfo.Payment_Notes />
					<cfset qGetDeductions =	this.DedDAO.getDeductionOnID('#arrDedIdsToAdd[iLooper]#') />

					<cfif qGetDeductions.RecordCount GTE 1>
						<cfset deductionsData = this.DedMgr.getDeductionObject(this.GetQueryRow(qGetDeductions,1)) />
					</cfif>

					<cfset BBClosingDetail.Deduction = deductionsData />

					<cfif (qGetDeductions.Is_Write_Off EQ 1)>

						<cfset qGetSingleClosingMethod			= this.BBSettlementDAO.GetSingleClosingMethod(closingMethodID = 9) />
						<cfif (qGetSingleClosingMethod.RecordCount EQ 1)>

							<cfset ClosingMethodObj.id				= 9 />
							<cfset ClosingMethodObj.description		= qGetSingleClosingMethod.vchBillback_Closing_Method_Desc />
							<cfset ClosingMethodObj.abbreviation 	= qGetSingleClosingMethod.Abbreviation />
						<!--- <cfelse>
							<cfset ClosingMethodObj.id				= 9 />
							<cfset ClosingMethodObj.description		= "WriteOff" />
							<cfset ClosingMethodObj.abbreviation 	= "WO" /> --->
						</cfif>

						<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />
						<cfset BBClosingDetail.amount 			= abs(BBClosingDetail.Deduction.Amount) * -1 />

					<cfelse>

						<cfset qGetSingleClosingMethod			= this.BBSettlementDAO.GetSingleClosingMethod(closingMethodID = 10) />
						<cfif (qGetSingleClosingMethod.RecordCount EQ 1)>
							<cfset ClosingMethodObj.id				= 10 />
							<cfset ClosingMethodObj.description		= qGetSingleClosingMethod.vchBillback_Closing_Method_Desc />
							<cfset ClosingMethodObj.abbreviation 	= qGetSingleClosingMethod.Abbreviation />
						 <!--- <cfelse>
							<cfset ClosingMethodObj.id				= 10 />
							<cfset ClosingMethodObj.description		= "REInstate" />
							<cfset ClosingMethodObj.abbreviation 	= "RI" /> --->
						</cfif>

						<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />
						<cfset BBClosingDetail.amount 			= abs(BBClosingDetail.Deduction.Amount) * -1 />

					</cfif>

					<cfset ArrayAppend(arrClosingMethodDetails, duplicate(BBClosingDetail))>

				</cfloop>

			</cfif>

			<!---
				This code snippet will check to see which closing method are not available in the arrClosingMethodDetails
				and will add the ones that are missing with $0.00 value, so that all the closing methods can be seen in
				the grid in the front end. - Anand Rao/20-July-2011
			 --->
			<cfset avlClosingMethodslist = "" />

			<cfloop index="iCount" from ="1" to="#ArrayLen(arrClosingMethodDetails)#">

				<cfscript>
					if(structKeyExists(arrClosingMethodDetails[iCount],"ClosingMethod")){
						avlClosingMethodslist = ListAppend(avlClosingMethodslist,arrClosingMethodDetails[iCount].ClosingMethod.ID,  ",");
					}
				</cfscript>

			</cfloop>

			<!---	<cfset arrGetAllClosingMethods = this.objBillbackLoadManager.getAllClosingMethods(UseselectedRecords = 0,selectedRecords="",includeBEnabled=0) />--->
				<!--- Dev Note: Milan - 28817 - Do not call this code for multiple billback approval. It just creates various splits for a billback
				with different closing methods
			--->
			<cfset arrGetAllClosingMethods = this.objBillbackLoadManager.getAllClosingMethods(UseselectedRecords = 0,selectedRecords="",includeBEnabled=1,includeProfile=1) />
			<!--- <cfdump var="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" output="c:\dump.log">
			<cfdump var="#arrGetAllClosingMethods#" output="c:\dump.log">
			<cfdump var="#ArrayLen(arrGetAllClosingMethods)#" output="c:\dump.log">
			<cfdump var="#arrClosingMethodDetails#" output="c:\dump.log"> --->
			<cfloop index="iLoop" from ="1" to="#ArrayLen(arrGetAllClosingMethods)#">

				 <cfif ((ListFind(avlClosingMethodslist, arrGetAllClosingMethods[iLoop].id,",") EQ 0)  OR (BBInfo.Billback_Status_ID LTE 2 AND HasBeenAgreed.RecordCount EQ 0))>

					<cfset BBClosingDetail	= CreateObject("component","mvc.Models.Billback.vos.BBClosingDetail").init() />
					<cfset BBClosingDetail.Amount = 0.00 />
					<cfset BBClosingDetail.specialHandling 	= BBInfo.SpecialHandling />
					<cfset BBClosingDetail.paymentNotes 	= BBInfo.Payment_Notes />
					<cfset ClosingMethodObj.id				= arrGetAllClosingMethods[iLoop].id />
					<cfset ClosingMethodObj.description		= arrGetAllClosingMethods[iLoop].description />
					<cfset ClosingMethodObj.abbreviation 	= arrGetAllClosingMethods[iLoop].Abbreviation />
					<cfset BBClosingDetail.closingMethod 	= ClosingMethodObj />
					<cfset ArrayAppend(arrClosingMethodDetails, duplicate(BBClosingDetail))>

				</cfif>

			</cfloop>

		</cfif>

		<!--- <cfdump var="#arrClosingMethodDetails#" output="C:\temp\arrClosingMethodDetails.txt" />   --->
		<cfreturn arrClosingMethodDetails />

	</cffunction>

	<!--- Call function for Mass approving billbacks --->
	<cffunction name="getApproveBB" access="remote" returntype="struct">
		<cfargument name="bbHeader" type="array" required="true">
	  	<cfargument name="argAction" type="struct" required="true">

		<cfscript>
			var arrObjBBHeader = ArrayNew(1);
			var stReturnValue = StructNew();
			var stReturnValue.approvedList = ArrayNew(1);
			var stReturnValue.errorMsg = ArrayNew(1);
			var idxApprovedBillbackIDInt = 0;
			var idxErrMsgBillbackIDInt = 0;
			var approvalOrAgree = 0;
			var bIsApprovable = 0;

			/* loop through the array of billback headers */
			for (j=1;j LTE ArrayLen('#arguments.bbHeader#');j=j+1)
			{
				/* get approved amount from deviations. Here, when BBHeader is passed to the "getApprovalAmount" function,
				   that function adds few more properties to the existing BBHeader.
				 */
				arguments.bbHeader[j] = this.BBSettlementDAO.getApprovalAmount(arguments.bbHeader[j]);

				/* get closing details (payment info). Here, when BBHeader is passed to the "setBBHeaderBBClosingDetail" function,
				   that function adds few more properties to the existing BBHeader.
				*/
				arguments.bbHeader[j] = setBBHeaderBBClosingDetail(arguments.bbHeader[j], 0);

				/* Check whether the billback is in RFA status and the total amount matches the final Selected Amount */
				bIsApprovable = getIsApprovable(arguments.bbHeader[j]);

				if(bIsApprovable == 1)
				{

					idxApprovedBillbackIDInt = idxApprovedBillbackIDInt + 1;

					/* Pass BBHeader data structure to flex */
					stReturnValue.approvedList[idxApprovedBillbackIDInt] = massApproveBillbackSettlement(arguments.bbHeader[j],arguments.argAction);
				}
				else
				{
					idxErrMsgBillbackIDInt = idxErrMsgBillbackIDInt + 1;
					qGetBillbackData =  this.BBMgr.getBillbackData(arguments.bbHeader[j].billbackIDInt);
					/* build BBHeader data structure to pass to flex */
					stHeaderData = structNew();
					stHeaderData["__type__"] = "mvc.Models.Billback.vos.BBHeader";
					stHeaderData = this.objBillbackLoadManager.getCreateBillbackHeaderObject(qGetBillbackData);
					tReturnValue.errorMsg[idxErrMsgBillbackIDInt] = 'This billback cannot be approved';
				}

			}

		</cfscript>

		<!--- Send email of the approved list of billbacks to the user who took the "Mass Approval" action --->
		<cfinclude template ="/billbacks/approval/MassApprovalEmail.cfm">

		<cfreturn stReturnValue>

	</cffunction>

	<!--- Check whether this billback can be sent for approval/Agree --->
	<cffunction name="getIsApprovable" returntype="boolean" access="private" hint="returns whether the billback can be send for Approval/Agree">
		<cfargument name="bbHeader" type="struct">

		<cfscript>
			var bApprovalAllowed =  0;
			var totalAmount = 0;

			/* Add up the approval amount of the different closing methods on the BB Settlement tab (flex) */
			for (i=1;i LTE ArrayLen('#arguments.bbHeader.bbSettlement.bbClosingDetail#');i=i+1) {

				totalAmount = totalAmount + val(arguments.bbHeader.bbSettlement.bbClosingDetail[i].amount);
				if(arguments.bbHeader.bbSettlement.bbClosingDetail[i].amount != 0)
				{

					totalAmount = val(totalAmount);
				}
			}

			/* If RFA status and if the approval amount on the "BBSettlement" tab (flex) matches the sum of amounts for the
			   billback closing methods on that page
			*/
			if(arguments.bbHeader.status.id == 2 && totalAmount == arguments.bbHeader.finalSelectedAmount){
				bApprovalAllowed = 1;
			}

		</cfscript>

		<cfreturn bApprovalAllowed>

	</cffunction>

	<!--- Decides Approve OR Agree logic. This function accepts BBHeader and returns a boolean value of whether a billback can be agreed or approved. --->
	<cffunction name="getIsApproveORAgree" returntype="boolean" access="private" hint="returns whether the billback can be in approved or agreed status">
		<cfargument name="bbHeader" type="struct">
		<cfargument name="bWriteOffExists" type="boolean">
		<cfargument name="nwriteOffAmt" type="numeric">

		<cfscript>
			var Get_Profile_Settings = this.profileMgr.getProfileSettings(request.AccessStructure.Profiles_ID);
			var bApprove = Get_Profile_Settings.BB_APPROVE;
			var deviAmount = 0;
			var approveAmount = Get_Profile_Settings.BB_TOT_APPROVE_AMOUNT;
			var approveDeviAmount = Get_Profile_Settings.BB_APPROVE_AMOUNT;
			var approveLastDateToClaim = Get_Profile_Settings.APPROVE_LAST_DATE_TO_CLAIM;
			var approveBillbackBeyondBudget = Get_Profile_Settings.Approve_BB_Beyond_Budget;
			var ddMatchCentralWriteOffamount = Get_Profile_Settings.DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT;
			var appSettings = application.appSettingsGet;
			/* bApproval = 0 means that billback can be agreed and not approved. If the below logic changes this value to 1, then this billback
			   can be approved.
			*/
			var bApproval = 0;

			/* get the deviation amount */
			deviAmount = val(arguments.bbHeader.finalSelectedAmount) - val(arguments.bbHeader.expectedAmt);
			/* get the billback id from billbackidInt */
			Billback_ID = this.oBillbackDAO.getBillbackUUID(arguments.bbHeader.billbackIDInt);
			qIsCritical = this.BBSettlementDAO.qGetIsCritical(Billback_ID);

			if(bApprove)
			{
				if(
						(
						/* If "writeoff" closing method does not exist */
						 arguments.bWriteOffExists == 0
						 ||
						  (
						   /* If the writeoff closing method amount is within the limit of the writeoff profile amount.
						      Note: I use the abs function here - so, even the negative writeoff amount cannot exceed the profile writeoff amount
						    */
						   (val(ddMatchCentralWriteOffamount) >= val(Abs(nwriteOffAmt)))
						   ||
						   (ddMatchCentralWriteOffamount == '*')
						  )
						)
						&&
						(
						/* Approval amount within approval range */
						 ((val(approveAmount) > 0) && approveAmount >= val(arguments.bbHeader.finalSelectedAmount))
						  ||
						  (approveAmount == '*' )
						)
						&&
						(
						/* deviation amount within deviation approval range */
						  ((val(approveDeviAmount) > 0) && val(approveDeviAmount) >= (deviAmount))
						  ||
						  (approveDeviAmount == '*' )
						)
						/* Profile can approve "last date to claim" or it is NOT BEYOND "last date to claim" */
						&&
						(
						  approveLastDateToClaim == 1
						  ||
						  arguments.bbHeader.bbSettlement.lastDateToClaim == 0 || Trim(arguments.bbHeader.bbSettlement.lastDateToClaim) == 'NO'
						)
						&&
						/* template approval */
						(arguments.bbHeader.bbSettlement.templateApproval ==  1 || Trim(arguments.bbHeader.bbSettlement.templateApproval) == 'YES')
						/* Check whether it is not a critical billback OR the user can approve a critical billback */
						/* Commented the code for now as the same logic needs to be in BBSettlementPModel.as in flex */
						/*
						&&
						(
						 (qIsCritical.BB_PNF == 0 && qIsCritical.BB_UP == 0)
						 ||
						  Get_Profile_Settings.BB_Approve_Critical == 1
						)
						*/
						&&
					   (
						(appSettings.getBudgetsFunctionalityOn() == 0)
						||
						(arguments.bbHeader.bbSettlement.bIsBillbackWithinBudget ==  1 || Trim(arguments.bbHeader.bbSettlement.bIsBillbackWithinBudget) == 'YES')
						||
						(approveBillbackBeyondBudget == 1)
					   )
				 	)
					{
						/* billback can be approved */
						bApproval = 1;
					}
				}
			</cfscript>

		<cfreturn bApproval>

	</cffunction>

	<!--- Call the approval function. This is called from the Mass Approval tool --->
	<cffunction name="massApproveBillbackSettlement" returntype="any" access="private" hint="calls the approval function" output="TRUE">
		<cfargument name="bbHeader" type="struct">
		<cfargument name="argAction" type="struct">

	 	<!--- Call the approval function --->
		<cfset stHeaderData = approveBillbackSettlement(arguments.bbHeader,arguments.argAction)>

		<!--- Check whether the billback has been agreed by the user. If it has been, then set the "subStatus" of the status to 3 (Agreed).
		1 is "Under Review" and 2 is "pending Approval"
		--->
		<cfscript>
		qBBAgreedInfo = this.BBSettlementDAO.qGetIsAgreed(stHeaderData.billbackIDInt);

			if(qBBAgreedInfo.BB_Agreed_Info_ID != '')
			{
				stHeaderData.status.subStatus = 3;
				stHeaderData.status.subStatusDescription = 'Agreed';
			}
		</cfscript>

		<cfreturn stHeaderData>
	</cffunction>

	<!---
		This is the Major function that will get called whenever the user click on Approve/Agree/Save in the flex settlement screen
	--->
	<cffunction name="approveBillbackSettlementJSON" returntype="string" access="remote" returnformat="JSON" output="false" hint="processes and saves the settlement tab records">
		<cfargument name="bbHeader" type="string">
		<cfargument name="argAction" type="string">
		<cfscript>
			local.bbHeader = deserializeJSON( arguments.bbHeader );
			local.action   = deserializeJSON( arguments.argAction );
			local.result   = this.approveBillbackSettlement( local.bbHeader, local.action );

			return serializeJSON( application.util.struct.structSortLowerCase( local.result, 0 ) );
		</cfscript>

	</cffunction>

	<cffunction name="approveBillbackSettlement" returntype="any" access="remote" hint="processes and saves the settlement tab records" output="false"><!--- processAndSaveMatched --->
		<cfargument name="bbHeader" type="struct">
		<cfargument name="argAction" type="struct">

		<cfscript>
			var appSettings = application.appSettingsGet;
			//set local variables
			var Billback_ID			  		= this.oBillbackDAO.getBillbackUUID(arguments.bbHeader.billbackIDInt);
			var Parent_ID 			  		= Billback_ID;
			var BBClosingDetailObj 	  		= arguments.bbHeader.bbSettlement.bbClosingDetail;
			var BBClosingDetailObjLen 		= arrayLen(BBClosingDetailObj);
			var BBInfo				  		= this.MCObject.getBBInfo(Billback_ID);
			var BBAmount 			  		= BBInfo.bb_approved_amount;
			var isExactMatch 		  		= 0;
			// Variables for checking if a BBClosingMethod exists so that we can handles deductions accordingly
			var bPaymentExists		  		= 0;
			var bPaymentEFTExists	 		= 0;
			var bDeductionExists	  		= 0;
			var bCreditExists		  		= 0;
			var bDebitExists		  		= 0;
			var bBudgetEntryExists	  		= 0;
			var bReInstateExists	  		= 0;
			var bWriteOffExists		  		= 0;
			var nPaymentAmt			  		= 0;
			var nPaymentEftAmt		  		= 0;
			var nDeductionAmt		  		= 0;
			var nCreditAmt			  		= 0;
			var nDebitAmt			  		= 0;
			var nBudgetEntryAmt		  		= 0;
			var nwriteOffAmt				= 0;
			var bReInstateAmt		  		= 0;
			var bWriteOffAmt		  		= 0;
			var dd1 				  		= "";
			var dd2 				  		= "";
			var remBalID			  		= "";
			var settlementAction 	  		= "";
			var totalClosed 		 		= 0;
			var dummyReasonID		  		= "";
			var matchlist 			  		= "";
			var Reason_Code 		  		= "";
			var dummySplitReason 	  		= "Split from Flex Settlement";
			var dummyWriteOffReason	  		= "WriteOff from Flex Settlement";
			var objBBEmailManager	  		= "";
			var BBAssociatedToPayment 		= "";
			var BBAssociatedToDD	  		= "";
			var BBAssociatedToCreditMemo 	= "";
			var BBAssociatedToDebitMemo  	= "";
			var BBAssociatedToBudgetEntry 	= "";
			var BBAssociatedToPaymentEFT  	= "";
			var BBAssociatedToWriteOff		= "";
			var totalClosedWithoutDed		= 0;
			var OriginalDDAttached			= "";
			var BBAction					= "";
			var lAgreeReasonList			= "";
			var objBBEmailManager 				= CreateObject("component","mvc.Models.Billback.BillbackEmailManager");
			//this.dmp(bbHeader.bbSettlement.BBCLOSINGDETAIL);
			var qGetBBVendor = this.oBillbackDAO.getVendor(Billback_ID);
			//used for splitBB
			var strPayeeID = qGetBBVendor.Vendor_Master_ID;

		</cfscript>

		<!--- Tim Ford - 02/10/2014: Label 40126 - EFT Payment setup: If there is a closing method of Payment EFT then make sure the payee is eligable for EFT payment START--->
		<cfscript>
			for (i=1; i LTE arrayLen(BBClosingDetailObj); i++) {
				if(BBClosingDetailObj[i].closingMethod.ID == 8 && BBClosingDetailObj[i].amount neq "" && BBClosingDetailObj[i].amount gt 0){
					if (bIsPayeeValidEFT(strPayeeID) eq false){
						stHeaderData = structNew();
						stHeaderData = arguments.bbHeader;
						stHeaderData.strErrorMessage = "Payee cannot use EFT.";
						return stHeaderData;
					}
				}
			}
		</cfscript>
		<!--- Tim Ford - 02/10/2014: Label 40126 - EFT Payment setup: If there is a closing method of Payment EFT then make sure the payee is eligable for EFT payment END--->


		<!---
			********************************************************************
			Step 1: Declare variables [variables used in the function]
			Step 2:	Start looping over the bbClosingDetails Object and
					set the available closing methods and their amounts
			Step 3: Start looping over the bbClosingDetails Object again
					and process each closing method record.
				 3a) Check if payment method exists and
			Step 4: Update the BB_Approved Table and do the other updates/call
					the other procedures to do the requried updates.

			********************************************************************
		--->

		<!---
			Step 1: Declare variables [variables used in the function]
		--->
		<cfscript>
			// Check to see, if there are any closing methods for the given Billback
			BBExistingClosingDetailObj 	= this.getBillbackSettlement(arguments.bbHeader.billbackIDInt);
			BBExistingClosingDetailObjLen = arrayLen(BBExistingClosingDetailObj);

			// Logic to find if the BBHeader that was returned has same/different closing methods
			arrClosingMethodsToSave = ArrayNew(1);

			//If this arrClosingMethodToSave is not empty then that means something has changed in the closing method
			arrClosingMethodsToSave = this.fnClosingMethodsCompareAndRemove(BBHeader=arguments.bbHeader);
			arrClosingMethodsToSaveLen = arrayLen(arrClosingMethodToSave);
			//Decide if we need to splid Deduction and BB
			local.dedCount 	= 0;
			local.bbCount 	= arrClosingMethodsToSaveLen;
			local.dedExists = false;
			//see if a deduction exists
			for (i=1;i LTE arrClosingMethodsToSaveLen;i=i+1) {
				if(arrClosingMethodsToSave[i].ID == 2){
					local.dedExists = true;
					break;
				}
			}
			//then total deduction splits(deduction + write-off or re-instate records)

			if(local.dedExists){
				for (i=1;i LTE arrClosingMethodsToSaveLen;i=i+1) {
					if(listContains('2,9,10',arrClosingMethodsToSave[i].ID,',')){
						if(	structKeyExists(arrClosingMethodsToSave[i],'Deduction') AND isStruct(arrClosingMethodsToSave[i].Deduction) AND structKeyExists(arrClosingMethodsToSave[i].Deduction,'deductionID') AND
							arrClosingMethodsToSave[i].Deduction.deductionID != ''){
							//increment if this is a ded or associated to a ded via writeoff or reinstate
							local.dedCount++;
						}
					}
				}
				//don't count extra dd splits in the BB split count.  The  Deds will create 1 BB split so add one
				local.bbCount = local.bbCount - local.dedCount + 1;
			}
		</cfscript>

		<!---- 	If the array is greater than or equal to 1 OR (dedCount = CmCount -> Deduction & writeoff)
				then we will reset the earlier closing methods for the billback and save the new one --->
		<cfif local.bbCount GT 1>  <!---(arrClosingMethodsToSaveLen GTE 2 && arrClosingMethodsToSaveLen GT dedCount)--->

			<cfloop index="k" from ="1" to="#arrClosingMethodsToSaveLen#">
				<cfset "frmStruct.IsDeleted_#k#" 	  = 0 />
				<cfset "frmStruct.IsCreated_#k#" 	  = 1 />
				<cfset "frmStruct.Closing_method_#k#" = arrClosingMethodsToSave[k].ID />
				<cfset "frmStruct.Amt_Child_#k#" 	  = arrClosingMethodsToSave[k].Amount />
				<cfset "frmStruct.Split_Reason_#k#"   = dummySplitReason />
			</cfloop>

			<cfset frmStruct.existingChildCount = 0 />
			<!---
				Before calling the splitBillback Make sure that all the values that the splitBillback needs are properly set here.
			--->
			<cfset Parent_ID = this.BillbackSplitManager.SplitBillback(
									billbackID = Billback_ID,
									form = frmStruct,
									splitCount = local.bbCount,
									existingChildCount = 0,
									payeeID = strPayeeID
									) />
		</cfif>

		<cfset qGetBBChildren =  this.oBillbackDAO.getBBChildren(Parent_ID) />

		<cfif (isDefined("qGetBBChildren") AND qGetBBChildren.RecordCount GTE 1)>
			<cfset BBsToProcess = qGetBBChildren />
		<cfelse>
			<cfset BBsToProcess = BBInfo />
		</cfif>

		<!--- Loop through the closing detail object to get the total amount--->
		<cfset Get_Profile_Settings = this.profileMgr.getProfileSettings(request.AccessStructure.Profiles_ID)>
		<!--- <cfif (isDefined("arguments.argAction.action") AND arguments.argAction.action NEQ "")>
		<cfset settlementAction = arguments.argAction.action />
		</cfif> --->
			<!---
			<cfif (BBAmount EQ "" OR BBAmount EQ 0)>
				<cfset BBAmount = arguments.bbHeader.approvedAmount />
			</cfif>
			--->
		<cfset BBAmount = arguments.bbHeader.finalSelectedAmount />
			<!--- <cfif (BBAmount EQ "" OR BBAmount EQ 0)>
				<cfset BBAmount = arguments.bbHeader.finalSelectedAmount />
			</cfif> --->

		<cfset closingMethodCount = 0 />

		<!--- Dev Note: Milan (36094) - Sometimes (eg: When the closing method of billback on the edit page is "writeoff" and the closing methods on the settlement screen are deduction and writeoff),
		the "BBClosingDetailObj" below starts from closing method 9 (writeoff) and then 2 (deduction). In the future, if we have any issues, perhaps sorting ""BBClosingDetailObj" could be a solution, as
		the loop will increment in an ascending manner.
		Note: "BBClosingDetailObj" is an arrayofStructs and sorting it is not like sorting a simple array.
		--->
		<cfloop index="i" from="1" to="#BBClosingDetailObjLen#">
			<!--- <cfset totalClosed = totalClosed + abs(BBClosingDetailObj[i].amount) /> --->
			<cfset totalClosed = totalClosed + BBClosingDetailObj[i].amount />
			<!--- <cfif (BBClosingDetailObj[i].closingMethod.ID NEQ "2" OR BBClosingDetailObj[i].closingMethod.ID NEQ "9" OR BBClosingDetailObj[i].closingMethod.ID NEQ "10")>
				<cfset totalClosedWithoutDed = totalClosedWithoutDed + BBClosingDetailObj[i].amount />
			</cfif>  --->

			<!--- <cfset outputdump = i & " : totalClosedWithoutDed = " & totalClosedWithoutDed /> --->
			<!--- <cfdump var="#outputdump#" output="C:\temp\dumper.txt" /> --->

			<!--- Dev Note: Milan (36094). In an earlier label, I had modified the below query to return records based on closing method starting from 1, sicne we want to process "payment" first,
			deduction second and so on.
			--->
			<cfloop query="BBstoProcess">

				<cfswitch expression = "#BBClosingDetailObj[i].closingMethod.ID#">
					<!--- if there are multiple records then change this to bpaymentExists + 1 --->
					<cfcase value = "1">
						<!--- Payment --->
						<cfif  ((BBsToProcess.BB_Closing_Method EQ 1 AND BBClosingDetailObj[i].amount EQ BBsToProcess.BB_Amount) OR BBClosingDetailObjLen EQ 1)>
							<cfset bPaymentExists = 1 />
							<cfset closingMethodCount++ />
							<cfset BBAssociatedToPayment = BBsToProcess.Billback_ID />
							<cfset totalClosedWithoutDed = totalClosedWithoutDed + BBClosingDetailObj[i].amount />
						</cfif>
					</cfcase>
					<cfcase value = "2">
						<!--- Deduction --->
						<cfif  (BBsToProcess.BB_Closing_Method EQ 2 OR BBClosingDetailObjLen EQ local.dedCount) >  <!---  OR BBClosingDetailObjLen EQ dedCount AND BBClosingDetailObj[i].amount EQ BBsToProcess.BB_Amount) --->
							<cfset bDeductionExists = 1 />
							<cfset closingMethodCount++ />
							<cfset BBAssociatedToDD = BBsToProcess.Billback_ID />
							<!--- Dev Note: Milan (36094) - "BBAssociatedToWriteOff" does not seem to be needed here. How can a bb split which has a closing method of "deduction" be asociated to "writeoff"?  --->
							<!---<cfset BBAssociatedToWriteOff = BBsToProcess.Billback_ID />--->
						</cfif>
					</cfcase>
					<cfcase value="3">
						<!--- Off invoice --->
						<cfset totalClosedWithoutDed = totalClosedWithoutDed + BBClosingDetailObj[i].amount />
					</cfcase>
					<cfcase value="4">
						<!--- Adjustment --->
						<cfset totalClosedWithoutDed = totalClosedWithoutDed + BBClosingDetailObj[i].amount />
					</cfcase>
					<cfcase value="5">
						<!--- Credit Memo --->
						<cfif  ((BBsToProcess.BB_Closing_Method EQ 5 AND BBClosingDetailObj[i].amount EQ BBsToProcess.BB_Amount) OR BBClosingDetailObjLen EQ 1)>
							<cfset bCreditExists = 1 />
							<cfset closingMethodCount++ />
							<cfset BBAssociatedToCreditMemo = BBsToProcess.Billback_ID />
							<cfset totalClosedWithoutDed = totalClosedWithoutDed + BBClosingDetailObj[i].amount />
						</cfif>
						<!--- <cfset closingMethodCount++ /> --->
					</cfcase>
					<cfcase value="6">
						<!--- Debit Memo --->
						<cfif  ((BBsToProcess.BB_Closing_Method EQ 6 AND BBClosingDetailObj[i].amount EQ BBsToProcess.BB_Amount) OR BBClosingDetailObjLen EQ 1)>
							<cfset bDebitExists = 1 />
							<cfset closingMethodCount++ />
							<cfset BBAssociatedToDebitMemo = BBsToProcess.Billback_ID />
							<cfset totalClosedWithoutDed = totalClosedWithoutDed + BBClosingDetailObj[i].amount />
						</cfif>
						<!--- <cfset closingMethodCount++ /> --->
					</cfcase>
					<cfcase value="7">
						<!--- Budget Entry  --->
						<cfif  ((BBsToProcess.BB_Closing_Method EQ 7 AND BBClosingDetailObj[i].amount EQ BBsToProcess.BB_Amount) OR BBClosingDetailObjLen EQ 1)>
							<cfset bBudgetEntryExists = 1 />
							<cfset closingMethodCount++ />
							<cfset BBAssociatedToBudgetEntry = BBsToProcess.Billback_ID />
							<cfset totalClosedWithoutDed = totalClosedWithoutDed + BBClosingDetailObj[i].amount />
						</cfif>
						<!--- <cfset closingMethodCount++ /> --->
					</cfcase>
					<cfcase value="8">
						<!--- Payment EFT --->
						<cfif  ((BBsToProcess.BB_Closing_Method EQ 8 AND BBClosingDetailObj[i].amount EQ BBsToProcess.BB_Amount) OR BBClosingDetailObjLen EQ 1)>
							<cfset bPaymentEFTExists = 1 />
							<cfset closingMethodCount++ />
							<cfset BBAssociatedToPaymentEFT = BBsToProcess.Billback_ID />
							<cfset totalClosedWithoutDed = totalClosedWithoutDed + BBClosingDetailObj[i].amount />
						</cfif>
					</cfcase>
					<cfcase value="9">
						<cfif  (BBsToProcess.BB_Closing_Method EQ 9 OR BBClosingDetailObjLen EQ local.dedCount OR trim(BBClosingDetailObj[i].amount) NEQ "") >
							<cfset bWriteOffExists = 1 />
							<!--- <cfset closingMethodCount++ /> --->
							<!--- Dev Note: Milan (36094) - Only when the closing method of a split is "writeoff", should that billback be associated to writeoff.  --->
							<cfif BBsToProcess.BB_Closing_Method EQ 9>
								<cfset BBAssociatedToWriteOff = BBsToProcess.Billback_ID />
							</cfif>
							<cfif trim(BBClosingDetailObj[i].amount) NEQ "">
								<!--- Get the writeoff amount --->
								<cfset nwriteOffAmt = BBClosingDetailObj[i].amount>
							</cfif>
						</cfif>

					</cfcase>
				</cfswitch>

			</cfloop> <!---- End BBstoProcess loop--->

		</cfloop>	<!---- End i loop--->

		<!--- Based on the ClosingMethodCount split the billback to that many children and associate each one --->

		<cfset remainingBalance = BBAmount - totalClosed />

		<cfif (isDefined("arguments.argAction.action") AND arguments.argAction.action NEQ "")>
			<cfset BBAction = arguments.argAction.action>
		<cfelse>
			<cfset BBAction = "SAVE">
		</cfif>

		<!---Now check whether the user can APPROVE OR AGREE to the billback based on various profile settings if BBAction has not been passed --->
		     <!---if(BBAction != "SAVE" AND trim(BBAction) != "APPROVE" AND trim(BBAction) != "AGREE")--->
		<cfif (BBAction neq "SAVE")>
			<cfset approvalOrAgree = getIsApproveORAgree(arguments.bbHeader,bWriteOffExists,nwriteOffAmt)>

				<cfif approvalOrAgree eq 1>
					<cfset BBAction = 'APPROVE'>
				<cfelse>
					<cfset lAgreeReasonList = this.getAgreeReasons(arguments.bbHeader,bWriteOffExists,nwriteOffAmt) />
					<cfset BBAction = 'AGREE'>
				</cfif>
		</cfif>

		<cfif (BBAction EQ "AGREE")>
			<cfset agreeToThisBB = this.fnAgreeToBB(bbHeader = arguments.bbHeader,Billback_ID = Billback_ID, agreeReasons = lAgreeReasonList) />
		</cfif>

		<cfloop index="inx" from="1" to="#BBClosingDetailObjLen#">

		<!---
			Billback_Closing_methods:
			1 - Payment
			2 - Deduction
			3 - Off Invoice
			4 - Adjustment
			5 - Credit Memo
			6 - Debit Memo
			7 - Budget Entry Only
			8 - Payment EFT
			--->

			<!--- Payment handling starts here --->
			<cfscript>
				if(BBClosingDetailObj[inx].closingMethod.ID EQ 1){
					if (BBAction EQ "APPROVE"){
						this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 1,Billback_ID = BBAssociatedToPayment,BB_Status_ID = 4);}
					else if (BBAction EQ "AGREE"){
						this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 1,Billback_ID = BBAssociatedToPayment,BB_Status_ID = 2);}
					else if (BBAction EQ "SAVE"){
						this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 1,Billback_ID = BBAssociatedToPayment,BB_Status_ID = BBInfo.Billback_Status_ID);}
				}
			</cfscript>
			<!--- Payment handling ends here --->

			<!--- START: Deduction handling starts  here --->
			<cfif structkeyexists(BBClosingDetailObj[inx],'deduction') >
				<cfset varDeduction = BBClosingDetailObj[inx].deduction />
			</cfif>

			<cfif structKeyExists(BBClosingDetailObj[inx],'deduction') && (BBClosingDetailObj[inx].closingMethod.ID EQ 2 AND isDefined("varDeduction.Amount") AND BBClosingDetailObj[inx].deduction.Amount NEQ 0)>

				<cfset matchList = BBClosingDetailObj[inx].deduction.deductionID />
				<!--- Set the Defaults to be passed into the function --->
				<cfset DDClassificationIDDefault = this.BBSettlementDAO.GetDDClassification() />
				<cfif isDefined(DDClassificationIDDefault.DD_Classification_ID)>
					<cfset DDClassificationIDDefault = DDClassificationIDDefault.DD_Classification_ID />
					<cfset balanceRecordSplitClassificationID = DDClassificationIDDefault.DD_Classification_ID />
				<cfelse>
					<cfset DDClassificationIDDefault = 0 />
					<cfset balanceRecordSplitClassificationID = 0 />
				</cfif>
				<cfif BBAmount EQ BBClosingDetailObj[inx].amount>
					<cfset isExactMatch = 1 />
				<cfelse>
					<cfset isExactMatch = 0 />
				</cfif>

				<!---
				Not checking for a +ve or -ve value as the front end will not send a -ve balance
				and the deduction split can only be positive for now
				--->
				<!--- <cfif ((NOT(isExactMatch)) AND bPaymentExists EQ 0 AND bPaymentEFTExists EQ 0 AND bCreditExists EQ 0 AND bDebitExists EQ 0 AND bBudgetEntryExists EQ 0 AND bReInstateExists EQ 0 AND bWriteOffExists EQ 0
				AND (BBClosingDetailObj[inx].deduction.deductionID NEQ ""))> --->
				<cfscript>
					if (bDeductionExists EQ 1 AND BBClosingDetailObj[inx].deduction.deductionID NEQ ""){
						qDedInfo = this.MCObject.DDMgr.getDeduction(BBClosingDetailObj[inx].deduction.deductionID);
						/*if(BBAmount <= qDedInfo.DD_Amount){
							newDedAmount = BBAmount;
						}
						else {
							newDedAmount = qDedInfo.DD_Amount;
						}*/

						if (totalClosedWithoutDed EQ 0 AND BBAmount < qDedInfo.DD_Amount)
						{
							newDedAmount = BBAmount;
						}
						else if (totalClosedWithoutDed EQ 0 AND BBAmount >= qDedInfo.DD_Amount)
						{
							newDedAmount = qDedInfo.DD_Amount;
						}
						else if(totalClosedWithoutDed GT 0 and BBClosingDetailObj[inx].amount eq qDedInfo.DD_Amount and (totalClosedWithoutDed + BBClosingDetailObj[inx].amount) lte BBAmount)
						{
							newDedAmount = qDedInfo.DD_Amount;
						}
						else if(totalClosedWithoutDed GT 0)
						{
							// newDedAmount = qDedInfo.DD_Amount - totalClosedWithoutDed;
							newDedAmount = BBAmount - totalClosedWithoutDed ;

						}
						//D35189: Variable NEWDEDAMOUNT is undefined
						else if(totalClosedWithoutDed LT 0){
							newDedAmount = BBClosingDetailObj[inx].amount;
						}
						OriginalDDAttached = BBClosingDetailObj[inx].deduction.deductionID;
						if (qDedInfo.DD_Closure_Type EQ ""){
							splitArray = this.MCObject.DDMgr.splitDeduction(
								deductionId = BBClosingDetailObj[inx].deduction.deductionID,
								newDeductionAmount = newDedAmount,
								currentRecordSplitClassificationID = DDClassificationIDDefault,
								currentRecordSplitReason = dummySplitReason,
								balanceRecordSplitClassificationID = balanceRecordSplitClassificationID,
								balanceRecordSplitReason = dummySplitReason);
							dd1 = splitArray[1];
							dd2 = splitArray[2];
							matchList = Replace(matchList,BBClosingDetailObj[inx].deduction.deductionID,dd1);
							remBalID = dd2;
							if (dd1 NEQ ""){
								//this.DedDAO.updDedSplitWithBB(dd1,Billback_ID);
								this.DedDAO.updDedSplitWithBB(dd1,BBAssociatedToDD,0,BBAction);
							}
							if(dd2 NEQ ""){
								// this.DedDAO.updDedSplitWithBB(dd2,Billback_ID);
								this.DedDAO.updDedSplitWithBB(dd2,BBAssociatedToDD,bWriteOffExists,BBAction);
							}
						}
					}
				</cfscript>

				<!--- if only one deduction and balance is not against bb we do not have to split the billback --->
				<!--- <cfif (isExactMatch EQ 1 AND remainingBalance EQ 0 AND listLen(matchList) EQ 1
				AND bPaymentExists EQ 0 AND bPaymentEFTExists EQ 0
				AND bCreditExists EQ 0 AND bDebitExists EQ 0
				AND bBudgetEntryExists EQ 0 AND bReInstateExists EQ 0 AND bWriteOffExists EQ 0)> --->
				<cfif (isExactMatch EQ 1 OR listLen(matchList) EQ 1)>

					<!---TSF - Label 30543 - GM Settlement Rework - Un-Associating Deductions and Balance Tally. MARKER --->
					<cfset matchingID = listGetAt(matchList,1) />
					<cfset tempVar = this.MCObject.DDMgr.setAssociatedBB(
							Deduction_ID = matchingID,
							Billback_ID = BBAssociatedToDD) /> <!--- was Billback_ID earlier --->

					<!---
						Added this code to make sure that when there is multiple closing methods along with
						Deduction and both DD Split and BB split happens they are associated correctly
					--->
					<cfif totalClosedWithoutDed GT 0 AND bDeductionExists EQ 1 AND OriginalDDAttached NEQ "">

						<!---
							<cfquery name="qrySplitBBs" datasource="#application.datasource#">
								SELECT * FROM Billback
								WHERE BB_Parent_ID = '#Parent_ID#' AND BB_Closing_Method = 2
							</cfquery>
						--->
						<cfset useLakebaseForupdBBSplit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForupdBBSplit>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"bb_parent_id" = "eq.#Parent_ID#",
				"bb_closing_method" = "eq.2"
			},
			{
				"bb_amount" = "#newDedAmount#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdBBSplit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdBBSplit>
<cfquery name="updBBSplit" datasource="#application.datasource#">
							UPDATE	Billback
							SET		BB_Amount = #newDedAmount#
							WHERE 	BB_Parent_ID = '#Parent_ID#'
							AND 	BB_Closing_Method = 2
						</cfquery>
</cfif>

					</cfif>

					<!--- Since it is an exact match with the deduction amount update the Billback status to PAID --->
					<!--- D30435: Flex BB settlement page - don't set to Paid status when DD associated/Anand Rao/15-Feb-2012
								  Changed the status to be 3 - Approved from 5- Paid when there was only deduction attached
					--->
					<cfif (BBAction EQ "APPROVE")>
						<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 2,Billback_ID = BBAssociatedToDD,BB_Status_ID = 3) />
					<cfelseif (BBAction EQ "AGREE")>
						<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 2,Billback_ID = BBAssociatedToDD,BB_Status_ID = 2) />
						<!--- <cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 2,Billback_ID = Billback_ID,BB_Status_ID = 2) /> --->
					<cfelseif (BBAction EQ "SAVE")>
						<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 2,Billback_ID = BBAssociatedToDD,BB_Status_ID = BBInfo.Billback_Status_ID) />
					</cfif>
					<!--- </cfif> --->
					<!--- Parent_ID = WorkItemID; --->

				</cfif>

			</cfif> <!--- END: <cfif BBClosingDetailObj[inx].closingMethod.ID EQ 2> --->

			<!--- END: Deduction handling ends here --->

			<!--- Credit handling starts here --->
			<cfif (BBClosingDetailObj[inx].closingMethod.ID EQ 5 AND BBAction EQ "APPROVE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 5,Billback_ID = BBAssociatedToCreditMemo,BB_Status_ID = 3) />
			<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 5 AND BBAction EQ "AGREE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 5,Billback_ID = BBAssociatedToCreditMemo,BB_Status_ID = 2) />
			<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 5 AND BBAction EQ "SAVE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 5,Billback_ID = BBAssociatedToCreditMemo,BB_Status_ID = BBInfo.Billback_Status_ID) />
			</cfif>
			<!--- Credit Memo handling ends here --->

			<!--- Debit Memo handling starts here --->
			<cfif (BBClosingDetailObj[inx].closingMethod.ID EQ 6 AND BBAction EQ "APPROVE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 6,Billback_ID = BBAssociatedToDebitMemo,BB_Status_ID = 3) />
			<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 6 AND BBAction EQ "AGREE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 6,Billback_ID = BBAssociatedToDebitMemo,BB_Status_ID = 2) />
			<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 6 AND BBAction EQ "SAVE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 6,Billback_ID = BBAssociatedToDebitMemo,BB_Status_ID = BBInfo.Billback_Status_ID) />
			</cfif>
			<!--- Debit Memo handling ends here --->

			<!--- Budget Entry handling starts here --->
			<cfif (BBClosingDetailObj[inx].closingMethod.ID EQ 7  AND BBAction EQ "APPROVE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 7,Billback_ID = BBAssociatedToBudgetEntry,BB_Status_ID = 5) />
			<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 7 AND BBAction EQ "AGREE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 7,Billback_ID = BBAssociatedToBudgetEntry,BB_Status_ID = 2) />
			<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 7 AND BBAction EQ "SAVE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 7,Billback_ID = BBAssociatedToBudgetEntry,BB_Status_ID = BBInfo.Billback_Status_ID) />
			</cfif>
			<!--- Budget Entry handling ends here --->

			<!--- Payment EFT handling starts here --->
			<cfif (BBClosingDetailObj[inx].closingMethod.ID EQ 8  AND BBAction EQ "APPROVE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 8,Billback_ID = BBAssociatedToPaymentEFT,BB_Status_ID = 4) />
			<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 8 AND BBAction EQ "AGREE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 8,Billback_ID = BBAssociatedToPaymentEFT,BB_Status_ID = 2) />
			<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 8 AND BBAction EQ "SAVE") >
				<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 8,Billback_ID = BBAssociatedToPaymentEFT,BB_Status_ID = BBInfo.Billback_Status_ID) />
			</cfif>
			<!--- Payment EFT handling ends here --->

			<!--- Check if closing method 9 exists in the closingDetail Obj, if so then it is writeoff --->
			<cfif BBClosingDetailObj[inx].closingMethod.ID EQ 9 && (!structKeyExists(BBClosingDetailObj[inx],'DEDUCTION') || !isStruct(BBClosingDetailObj[inx].Deduction) || BBClosingDetailObj[inx].Deduction.DeductionId EQ '' )>
				<cfset settlementAction = "writeoff" />
				<!--- Tim Ford - 02/04/2013: Label 36246: BB approve throws error when CM edit and settlement are different
				Adding code to handle for the scenario where the Billback is getting closed with Write-Off but another closing method was seleted in Billback Edit
				--->
				<cfif BBAssociatedToWriteOff eq "">
					<cfset BBAssociatedToWriteOff = BBInfo.Billback_ID />
				</cfif>
				<cfif (BBClosingDetailObj[inx].closingMethod.ID EQ 9  AND BBAction EQ "APPROVE") >
					<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 9,Billback_ID = BBAssociatedToWriteOff,BB_Status_ID = 3) />
				<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 9 AND BBAction EQ "AGREE") >
					<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 9,Billback_ID = BBAssociatedToWriteOff,BB_Status_ID = 2) />
				<cfelseif (BBClosingDetailObj[inx].closingMethod.ID EQ 9 AND BBAction EQ "SAVE") >
					<cfset this.BBSettlementDAO.UpdateBillbacks(BB_Closing_method = 9,Billback_ID = BBAssociatedToWriteOff,BB_Status_ID = BBInfo.Billback_Status_ID) />
				</cfif>
			</cfif>

		</cfloop>

		<!--- All actions go below
		variable dd2 will hold the split deduction id, if the deduction was split
		--->
		<cfif bWriteOffExists AND dd2 NEQ "">
		<!--- The logic below for "Match_Central_Write_Off_Amount" should aleady exist on the bb settlement screen --->
			<!---
			If the user has permission to write it off, then do so if it is within the profile threshold
			If not, then just leave it open.

			<cfset writeoffVal = Get_Profile_Settings.DD_Match_Central_Write_Off_Amount />
			<cfif (writeOffVal NEQ "*")>
				<cfset minWriteOff = writeOffVal - (writeOffVal * 2) />
				<cfset maxWriteOff = writeOffVal />
			</cfif>
			<cfif ((writeOffVal EQ "*") OR (remainingBalance GTE minWriteOff AND remainingBalance LTE maxWriteOff))>
				<cfset tempVar = this.MCObject.writeOffDD(dd2,dummyWriteOffReason) />
			</cfif>
			--->

			<!--- Update DD w/o info --->
			<cfset tempVar = this.MCObject.writeOffDD(dd2,dummyWriteOffReason) />
		</cfif>

		<!--- ****************************************************************************************************************************************************************************************
		******	Tim Ford 02/13/2012 - Label 30369: BB Settlement with write off - user is able to approve over profile limit *************************************************************************
		******	Put approval code below inside the BBAction EQ APPROVE if statement                                          *************************************************************************
		**********************************************************************************************************************************************************************************************
		Approval_Type values:
		1 - Manual Approval (Default)
		2  - Flex Approval
		3 - Approved BB update in progress
		4 - Approved BB update completed successfully
		5 - Approved by Settlements Tab
		--->
		<!---<cfif (BBAction EQ "APPROVE") OR (BBAction EQ "AGREE")>
		<cfset iApprovalType = 5 />

		<cfif isDefined("FORM.DD_Reason_Code_ID")>
			<cfset DDReasonCodeID = FORM.DD_Reason_Code_ID />
		<cfelse>
			<cfset DDReasonCodeID = 0 />
		</cfif>

		<cfset this.BBSettlementDAO.insUpdBBApproved(
									Billback_ID = Billback_ID,
									frmDD_Reason_Code_ID = DDReasonCodeID,
									totalClosed = totalClosed,
									BBAmount = BBAmount,
									paymentNotes = bbHeader.bbSettlement.paymentNotes,
									bSpecialHandling = bbHeader.bbSettlement.bSpecialHandling,
									Reason_Code = Reason_Code
									) />
		**************************************************************************************************************************************************************************************</cfif>	 --->

		<!--- Update Special Handling and Payment Notes --->
		<cfset this.BBSettlementDAO.updateBBSettlementData(Billback_ID, bbHeader.bbSettlement.paymentNotes, bbHeader.bbSettlement.bSpecialHandling, bbHeader.billTo.billToId) />

		<!--- TODO: need to check if these are required steps --->
		<cfif (BBAction EQ "APPROVE")>

			<!---
			Approval_Type values:
			1 - Manual Approval (Default)
			2  - Flex Approval
			3 - Approved BB update in progress
			4 - Approved BB update completed successfully
			5 - Approved by Settlements Tab
			--->
			<cfset iApprovalType = 5 />

			<cfif isDefined("FORM.DD_Reason_Code_ID")>
				<cfset DDReasonCodeID = FORM.DD_Reason_Code_ID />
			<cfelse>
				<cfset DDReasonCodeID = 0 />
			</cfif>

			<cfset this.BBSettlementDAO.insUpdBBApproved(
									Billback_ID = Billback_ID,
									frmDD_Reason_Code_ID = DDReasonCodeID,
									totalClosed = BBAmount,<!--- This was totalClosed earlier changing this to BBAmount --->
									BBAmount = BBAmount,
									paymentNotes = bbHeader.bbSettlement.paymentNotes,
									bSpecialHandling = bbHeader.bbSettlement.bSpecialHandling,
									Reason_Code = Reason_Code,
									expectedAmount = bbHeader.expectedAmt
									) />


			<cfif bDeductionExists GTE 1>
			<cfset j = 1 />
				<cfloop from= "1" to="#j LTE listLen(matchList)#" index="iCounter">
					<cfset matchingID = listGetAt(MatchList,iCounter) />
					<cfset qMatchInfo = this.MCObject.DDMgr.getDeduction(matchingID) />
					<cfset thisMatchItemAmount = qMatchInfo.DD_Amount />
					<cfif (thisMatchItemAmount EQ this.MCObject.DDMgr.getAssociatedBBTotal(deductionId=matchingID))>
						<!--- close only if the billbacks got attached properly (we validate on the amount) --->
						<cfset this.MCObject.DDMgr.closeDeduction(Deduction_ID = matchingID,
							 ReasonCode = dummyReasonID,
							 ClearedAmount = thisMatchItemAmount,
							 isMatchCentral = true) />
					</cfif>

					<cfset j = j + 1 />

				</cfloop>
			</cfif>

			<!--- variable dd2 will hold the split deduction id, if the deduction was split
			<cfif bWriteOffExists AND dd2 NEQ "">
				<cfset tempVar = this.MCObject.DDMgr.closeDeduction(Deduction_ID = dd2,
					ReasonCode = dummyReasonID,
					ClearedAmount = -1 * remainingBalance,
					isMatchCentral = true) />
			</cfif>
			--->

			<cfset this.BBSettlementDAO.BBCheckerAndSetter(Billback_ID = Billback_ID) />

			<CFQUERY NAME="DataValidation" DATASOURCE="#Application.Datasource#">
				EXEC BB_Approve_Data_Validation '#Billback_ID#'
			</CFQUERY>

			<cfset useLakebaseForSel_DataVal_Result = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForSel_DataVal_Result>
	<cftry>
		<cfset Sel_DataVal_Result = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "bb_approve_data_validation_success"
			}), "bb_approve_data_validation_success"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSel_DataVal_Result = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSel_DataVal_Result>
<CFQUERY NAME="Sel_DataVal_Result" DATASOURCE="#Application.Datasource#">
				SELECT BB_Approve_Data_Validation_Success FROM BIllback WHERE Billback_ID = '#Billback_ID#'
			</CFQUERY>
</cfif>

			<CFIF Sel_DataVal_Result.BB_Approve_Data_Validation_Success EQ 1>
				<cfquery name="CreateExclusion" datasource="#application.datasource#">
					EXEC BB_Exclusion_Log <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">, <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
			<CFELSE>
				<cfset local_bbid = Billback_ID>
			</CFIF>

			<!---   <cfquery name="SelBBApproved" datasource="#application.datasource#">
			SELECT Approval_Type, Approval_Updated_By, Approval_Updated_Date
			FROM BB_Approved
			WHERE
			Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery> --->

			<!--- <cfif SelBBApproved.Approval_Type GT 1 AND iApprovalType EQ 1> --->

			<cfquery name="updApproved" datasource="#application.datasource#">
				UPDATE 	BB_Approved
				SET 	Approval_Type = <cfqueryparam value="#iApprovalType#" cfsqltype="CF_SQL_INTEGER">,
						Approval_Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						Approval_Updated_Date = GetDate()
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>

			<cfquery name="insApprovalHistory" datasource="#application.datasource#">
				INSERT INTO BB_Approval_History
					(Billback_ID, Approved_By, Created_Date)
				VALUES
					(
						<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
						GetDate()
					)
			</cfquery>
			<!---
				D29997: Update Items proposal status based on approved billback/Anand Rao/16-Feb-2012
			 	Setting the Items proposal status if the BBAction is Approve, then set the Program Items proposal status.
				In the if we check for the condition and then add the Distributor.
			--->
			<!--- Note: appSettings.getPrgWonLostOnBBApproval() EQ 1 means (On BB Approve)--->
			<cfif ((BBAction EQ "APPROVE") AND (appSettings.getPrgWonLostOnBBApproval() EQ 1))>
				<cfstoredproc procedure="USP_Set_Program_Won_On_Billback_Approve" datasource="#application.datasource#">
					<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR"	dbvarname="@@Billback_ID" value="#Billback_ID#" null="no">
				</cfstoredproc>

				<!--- Check to see if the Billback is of type Distributor and is a 3rd party BB --->
				<cfif (BBInfo.Uploaded_Billback EQ 3)> <!--- BBInfo.Billback_Payee_Type_ID EQ 1 AND --->
				<!--- Get all the program on the Billback --->
					<!--- Get the setting "Update Distributors on Program based on 3rd Party Billbacks" for the program --->
					<cfquery name="selBBProgramList" datasource="#application.datasource#">
						SELECT DISTINCT Program_ID,Billback_Program_ID,PCPO.AutoAdd_Distributor_ThirdPartyClaims
						FROM Billback_Program
						INNER JOIN Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
						INNER JOIN Program_Control_Panel_Options PCPO ON PCPO.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
						AND PCPO.AutoAdd_Distributor_ThirdPartyClaims = 1
						WHERE Billback_ID =  <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
						AND  Billback_Program.Deleted = 0
					</cfquery>
					<!--- Loop over the list of programs in the BB --->
					<cfloop query="selBBProgramList">
					<!--- Only if the template setting is on then add the distributor --->
						<cfquery name="distOnBillback" datasource="#application.datasource#">
							SELECT Distinct(Distributor_ID) FROM Billback_Product
				 			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
							AND Billback_Program_ID = <cfqueryparam value="#selBBProgramList.Billback_Program_ID#" cfsqltype="CF_SQL_VARCHAR">
							AND Deleted = 0
						</cfquery>
						<cfloop query="distOnBillback">
							<cfstoredproc procedure="USP_Add_Program_Distributor_From_Billback" datasource="#application.datasource#">
								<cfprocparam type="In" 	cfsqltype="CF_SQL_INTEGER"	dbvarname="@@Program_ID" value="#selBBProgramList.Program_ID#" null="no">
								<cfprocparam type="In" 	cfsqltype="CF_SQL_VARCHAR"	dbvarname="@@Distributor_ID" value="#distOnBillback.Distributor_ID#" null="no">
							</cfstoredproc>
						</cfloop>
					</cfloop>
				</cfif>	<!--- END: BBinfo.Billback_Payee_Type_ID EQ 1 AND BBInfo.Uploaded_Billback EQ 3 --->
	 		</cfif>	<!--- END: BBAction EQ "Approve" AND ......... --->
			<!---
				Check and update the parent BillbackID, incase of a split, if all the others are approved then update the Billback to approved
			--->
			<cfset this.BBSettlementDAO.updateParentBBID(Billback_ID) />

			<cfif appSettings.getPullbacksOn()>
				<!--- PULLBACK LOG IS MAINTAINED AT THE TIME AUTO PAY RUNS D40634  --->
				<!---<cfquery name="Call_Create_Pullback_Log" datasource="#application.datasource#">
					/* Call Create_Pullback_Log.  UDF checks App setting and template settings for BB */
						IF dbo.Call_Create_Pullback_Log('#Billback_ID#') = 1
						BEGIN
							EXEC Create_Pullback_Log '#Billback_ID#',0,0,NULL,0
						END
				</cfquery>--->

			</cfif>

			<!--- Update budget actual dollar --->
			<!--- D33775: Update v7 Budgets for billback status of PAID
			Modified billback approval logic to not add billbck to budget on approval.
			<cfset CreateObject("component", "mvc.Models.AdvancedBudget.BudgetManager").addBillbackToBudget(billbackId=Billback_ID) />
			--->

			<!--- TODO: Return the Header object update it with new changes
						The issue is that since the queries are based on different
						status flags and since the update changes the statuses we do not
						see the same records that we initially get in the arguments of this
						function
			--->
			<!--- Check to make sure that if all the deductions are closed then --->
			<cfif (bDeductionExists EQ 1)>

				<cfquery name="qrySplitDDs" datasource="#application.datasource#">
					SELECT 	*
					FROM 	Deductions
					WHERE 	(DD_Parent_ID = '#OriginalDDAttached#' OR Deduction_ID = '#OriginalDDAttached#')
					AND 	DD_Status IN (4,9)
				</cfquery>

				<cfif qrySplitDDs.RecordCount NEQ 0>
					<!--- Tim Ford - 08/23/2012: Label D33738 - Approved Billbacks not interfacing because DD Status not set to Closed
					OriginalDDAttached isn't always the parent so we have to do some checking to determine which Deduction_ID
					to pass into closeParent()
					--->
					<cfif qrySplitDDs.DD_IsParent neq 1 and trim(qrySplitDDs.DD_Parent_ID) neq "">
						<cfset tempVar = this.MCObject.DDMgr.closeParent(qrySplitDDs.DD_Parent_ID) />
					<cfelse>
						<cfset tempVar = this.MCObject.DDMgr.closeParent(qrySplitDDs.Deduction_ID) />
					</cfif>

					<cfquery name="qAdjustDDSplitStatus" datasource="#application.datasource#">
						UPDATE	d
						SET		d.DD_Status = 4
						FROM	Billback b
								INNER JOIN BB_Approved ba on ba.Billback_ID = b.Billback_ID
								INNER JOIN DD_Closure_Detail on DD_Closure_Detail.DD_Closure_ID = b.Billback_ID and DD_Closure_Detail.Deleted = 0
								INNER JOIN Deductions dd on dd.Deduction_ID = DD_Closure_Detail.Deduction_ID and dd.Deleted = 0
								INNER JOIN Deductions d on dd.DD_DedID = d.DD_DedID and d.Deleted = 0
						WHERE	b.Deleted = 0
						AND		((d.DD_IsParent = 1 and d.DD_Status < 4) or (d.Is_Write_Off = 1 and d.DD_Status < 4) or (d.DD_IsParent = 0 and d.DD_Status < 4))
						AND		b.Billback_ID = '#Billback_ID#'
					</cfquery>
				</cfif>

			</cfif>

		</cfif>

		<cfscript>
			stHeaderData = structNew();
			/* Get data for the BBHeader */
			stHeaderData = this.BBMgr.getBBHeader(arguments.bbHeader.billbackIDInt);

			// send out emails on approve and agree
			if (trim(BBAction) EQ "APPROVE")
			{
				objBBEmailManager.sendApproveEmail(Billback_ID, request.AccessStructure.User_ID);
			}
			else if (trim(BBAction) EQ "AGREE")
			{
				objBBEmailManager.sendAgreeEmail(Billback_ID, request.AccessStructure.User_ID);
			}
		</cfscript>

		<cfreturn stHeaderData />

	</cffunction>


	<!---
		This method will get the billbackIDInt(numeric) and return the details
		of the closing method in an array - Anand Rao/06-Jun-2011
	--->
	<cffunction name="getClosingMethodDetails" output="false" returntype="array">
		<!---<cfargument name="bbHeader" type="mvc.Models.Billback.vos.BBHeader" required="true" default="">--->
		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<!--- Get the UUID of the Billback --->
		<cfset qGetBillback =   this.oBillbackDAO.getBBRecord(#arguments.billbackIDInt#) />
		<cfset Billback_ID = qGetBillback.Billback_ID />

		<!--- Check if there are any splits for this billback --->
		<cfset qGetBBChildren =  this.oBillbackDAO.getBBChildren('#Billback_ID#') />
		<!---
			If there are splits then check if, the closing method is deduction and
			if so get the deduction ID associated with it
		--->
		<cfset arrClosingMethodDetails = ArrayNew(1) />
		<!---
			This is for the Parent Billback_ID uncomment this code to add the
			Parent Billback_ID closing Detail in the BBClosingDetail object
		--->
		<!--- <cfset BBClosingDetail = this.getClosingMethodDetailsSingle(
																		billbackID=qGetBillback.Billback_ID,
																		BB_Closing_Method=qGetBillback.BB_Closing_Method,
																		BB_Associated_To_DD=qGetBillback.BB_Associated_To_DD,
																		Billback_Status_ID=qGetBillback.Billback_Status_ID,
																		BB_Status_Description = qGetBillback.BB_Status_Description,
																		BB_Status_Abbreviation = qGetBillback.BB_Status_Abbreviation,
																		BB_Amount = qGetBillback.BB_Amount,
																		SplHandlingMessge = qGetBillback.SpecialHandling
																		) />
		<cfset arrayAppend(arrClosingMethodDetails,BBClosingDetail) /> --->

		<cfif qGetBBChildren.RecordCount GTE 1>

			<cfloop query="qGetBBChildren">

				<cfset BBClosingDetail = this.getClosingMethodDetailsSingle(
																				billbackID = qGetBBChildren.Billback_ID,
																				BB_Closing_Method = qGetBBChildren.BB_Closing_Method,
																				BB_Associated_To_DD = qGetBBChildren.BB_Associated_To_DD,
																				Billback_Status_ID = qGetBBChildren.Billback_Status_ID,
																				BB_Status_Description = qGetBBChildren.BB_Status_Description,
																				BB_Status_Abbreviation = qGetBBChildren.BB_Status_Abbreviation,
																				BB_Amount = qGetBBChildren.BB_Amount,
																				SplHandlingMessage = qGetBBChildren.SpecialHandling,
																				billbackIDInt	   = qGetBBChildren.Billback_ID_Int
																				) />
				<cfset arrayAppend(arrClosingMethodDetails,BBClosingDetail) />

			</cfloop>

		</cfif>

		<!--- MARK WILL Add Code Below This Line --->
		<!--- HERE IS MY CODE --->
		<cfreturn arrClosingMethodDetails />

	</cffunction>

	<!---
		This Method will take a set of arguments and check to see if there are any
		deductions for the given BillbackID and then will return the BBClosingDetail
		Object along with the Deductions Objects embedded, if it existed, else will
		return the empty Deductions object. - Anand Rao/06-Jun-2011
	--->

	<cffunction name="getClosingMethodDetailsSingle" output="false"  access="remote" returntype="mvc.Models.Billback.vos.BBClosingDetail" >
		<cfargument name="billbackID" type="string" required="true" default="">
		<cfargument name="BB_Closing_Method" type="numeric" required="true" default="">
		<cfargument name="BB_Associated_To_DD" type="numeric" required="true" default="">
		<cfargument name="Billback_Status_ID" type="numeric" required="true" default="">
		<cfargument name="BB_Status_Description" type="string" required="true" default="">
		<cfargument name="BB_Status_Abbreviation" type="string" required="true" default="">
		<cfargument name="BB_Amount" type="string" required="true" default="">
		<cfargument name="SplHandlingMessage" type="string" required="true" default="">
		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<!--- <cfset aryDeductionsData	   = ArrayNew(1) /> --->
		<cfset DedDAOObj = CreateObject("component","mvc.Models.Deduction.DeductionDAO") />
		<cfset dedDataObj = CreateObject("component","mvc.Models.Deduction.vos.Deduction") />

		<cfif arguments.BB_Closing_Method EQ 2 AND arguments.BB_Associated_To_DD EQ 1>

			<cfquery name="qGetAssociatedDD" datasource="#application.datasource#">
				SELECT 	DD_Closure_Detail_ID,Deduction_ID, DD_Closure_Status_ID
				FROM	DD_Closure_Detail
				WHERE	Deleted = 0
				AND		DD_Closure_ID = '#arguments.billbackID#'
			</cfquery>
		 	<!--- Get the Deduction record associated with the Deduction_ID  --->
			<!---<cfset qGetDeductions =	DedDAOObj.getDeductionOnID('#qGetAssociatedDD.Deduction_ID#') />--->
			<!--- if there are deductions send it to the below function to return an array --->

			<cfif qGetAssociatedDD.RecordCount GTE 1>
				<cfset deductionsData = this.DedMgr.getDeduction(qGetAssociatedDD.Deduction_ID) />
				<cfset dedDataObj = deductionsData />
			</cfif>

		</cfif>

		<cfset BBClosingDetail 					= createObject("component","mvc.Models.Billback.vos.BBClosingDetail").init() />
		<cfset BBStatus							= createObject("component","mvc.Models.Billback.vos.Status").init() />
		<cfset BBStatus.id 						= arguments.Billback_Status_ID />
		<cfset BBStatus.description 			= arguments.BB_Status_Description />
		<cfset BBStatus.abbreviation 			= arguments.BB_Status_Abbreviation />
		<!--- <cfset BBClosingDetail.billbackID 		= arguments.billbackID />		 --->
		<!---<cfset qGetBillbackData 				= this.BBMgr.getBillbackData(arguments.billbackIDInt) />
					<!--- //build BBHeader data structure --->
		<cfset stHeaderData 					= structNew() />
		<cfset stHeaderData["__type__"] 		= "mvc.Models.Billback.vos.BBHeader" />
		<cfset stHeaderData 					= this.objBillbackLoadManager.getCreateBillbackHeaderObject(qGetBillbackData) />
		<cfset BbClosingDetail.bbHeader			= stHeaderData />		--->
		<cfset BBClosingDetail.closingMethod 	= arguments.BB_Closing_Method />
		<cfset BBClosingDetail.amount 		 	= dedDataObj.amount />  <!--- arguments.BB_Amount --->

		<cfset BBClosingDetail.deduction		= dedDataObj />
	<!---	<cfset BBClosingDetail.bbStatus			= BBStatus />--->
		<cfset BBClosingDetail.specialHandling 	= arguments.SplHandlingMessage />

		<cfreturn BBClosingDetail />

	</cffunction>

	<!---
		The below function should take care of the AGREE logic and is incomplete at this point should be finished soon
		- Anand Rao / 22-Jul-2011
	--->

	 <cffunction name="fnAgreeToBB" returntype="void" access="remote" hint="processes and saves the settlement tab records">
		<cfargument name="bbHeader" type="struct">
		<cfargument name="Billback_ID" type="string">
		<cfargument name="agreeReasons"	type="string" default="">

		<cfset var lAgreeReasons	= "" />

		<cfset lAgreeReasons		= arguments.agreeReasons />
		<cfset billbackManager		= CreateObject("component", "components.billback.BillbackManager") />
		<cfset BBWorkFlowManager 	= createObject("component", "components.workflow.BillbackWorkFlowManager")>
	  	<cfset appSettings 			= CreateObject("component", "components.settings.ApplicationSettingsManager").get() />

		<cfset useLakebaseForUpdateAgreeBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdateAgreeBB>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#arguments.Billback_ID#"
			},
			{
				"billback_status_id" = "2"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateAgreeBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateAgreeBB>
<cfquery name="UpdateAgreeBB" datasource="#Application.Datasource#">
    		UPDATE 	Billback
      		SET 	Billback_Status_ID = 2
			WHERE 	Billback_Id = '#arguments.Billback_ID#'
  		</cfquery>
</cfif>

		<cfset Billback_ID = arguments.Billback_ID />
		<cfset profile = CreateObject("component","components.user.Profile").init() />
		<cfset Get_Profile_Settings = profile.getProfileSettings(request.AccessStructure.Profiles_ID)>

		<cfset BBInfo				= this.MCObject.getBBInfo(arguments.Billback_ID) />
		<cfset BillbackTotal 		= BBInfo.bb_approved_amount />
		<cfif (BillbackTotal EQ "" OR BillbackTotal EQ 0)>
			<cfset BillbackTotal = arguments.bbHeader.finalSelectedAmount />
		</cfif>
		<!--- START: Calculating the ExpectedTotal Variable --->

		<!---Add Growth Amounts--->
		<cfset ExpectedTotal = 0>
		<cfinclude template="/billbacks/approval/inc_expected_total.cfm">
		<cfquery name="GrowthTotal" datasource="#application.datasource#">
			SELECT 	Round(ISNull(Sum(Expected_Amount), 0), 2) AS Expected_Amount
			FROM 	Billback_Program
					INNER JOIN BB_Growth_Program ON
					((BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID) AND (BB_Growth_Program.Deleted = 0))
			WHERE 	Billback_Program.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 	Billback_Program.Deleted = 0
			AND 	Exists
					( 	SELECT Billback_Program.Billback_Program_ID
						FROM Billback_Program
						WHERE (BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
						AND	(BB_Growth_Program.Deleted = 0)
					)
		</cfquery>

		<cfif GrowthTotal.Recordcount GT 0>
			<cfset ExpectedTotal = ExpectedTotal + GrowthTotal.Expected_Amount>
		</cfif>
		<cfquery name="GetLSTotals" datasource="#application.datasource#">
			SELECT 	Round(ISNull(Sum(LS_Expected_Amount), 0), 2) AS LS_Expected_Amount
			FROM BB_Lump_Sums
			WHERE BB_Lump_Sums.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND BB_Lump_Sums.Deleted = 0
			AND Exists
			(
				SELECT  Billback_Program_Lumpsum_Component.Billback_Program_Lumpsum_Component_ID
				FROM	Billback_Program_Lumpsum_Component
				WHERE
				Billback_Program_Lumpsum_Component.Billback_Program_ID = BB_Lump_Sums.Billback_Program_ID
				AND
				Billback_Program_Lumpsum_Component.Deleted = 0
				AND
				(Billback_Program_Lumpsum_Component.Amount IS NOT NULL)
				AND
				(LEN(Billback_Program_Lumpsum_Component.Amount) > 0)
				AND
				(ISNUMERIC(Billback_Program_Lumpsum_Component.Amount) = 1)
				AND
				(CAST(Replace(Billback_Program_Lumpsum_Component.Amount,'NaN',0) AS Float) > 0)
			)
		</cfquery>
		<cfif GetLSTotals.Recordcount GT 0>
			<cfset ExpectedTotal = ExpectedTotal + GetLSTotals.LS_Expected_Amount>
		</cfif>

		<cfset qIsCritical = this.BBSettlementDAO.qGetIsCritical(Billback_ID)>

		<!---
		*******************************************************************************************************************************************************
		****************		For Auto BB, deviations are not run...the expected total will come from the sum									***************
		****************		of BB_rates in the BB_Product Table.  The Billback Total is the original BB_Amount from the BillBack Table		***************
		*******************************************************************************************************************************************************
		 --->
		<cfif qIsCritical.Scheduled_Auto_BB>

			<cfquery name="getRateInfo" datasource="#Application.Datasource#">
				SELECT	sum(cast(BB_Rate as decimal(18,2)))) as bb_rate
				FROM 	Billback_Product
						INNER JOIN Billback_Product_Detail ON Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID
				WHERE 	Billback_Product.Billback_ID = '#Billback_ID#'
				AND		Billback_Product.Deleted = 0
				--AND	Billback_Product_Detail.BB_Product_Type_ID != 10
				AND		Billback_Product_Detail.Deleted = 0
			</cfquery>

			<cfset ExpectedTotal = getRateInfo.bb_rate>

		</cfif>
		<!--- END: Calculating the ExpectedTotal Variable --->
		<cfset Approve_Tot_Amount = Get_Profile_Settings.BB_Tot_Approve_Amount />
		<cfset Approve_Devi_Amount = Get_Profile_Settings.BB_Approve_Amount />
		<cfset IsBBTot_In_Range = 0>
		<cfset ISExpected_In_Range = 0>

		<cfif Approve_Tot_Amount NEQ "*">
			<cfif BillbackTotal LTE Approve_Tot_Amount>
				<cfset IsBBTot_In_Range = 1>
			</cfif>
			<cfif ExpectedTotal LTE Approve_Tot_Amount>
				<cfset ISExpected_In_Range = 1>
			</cfif>
		<cfelse>
			<cfset IsBBTot_In_Range = 1>
			<cfset ISExpected_In_Range = 1>
		</cfif>

		<cfquery name="checkAgreeInfo" datasource="#Application.Datasource#">
			SELECT	BB_Agreed_Info_ID,
					Billback_ID,
					User_ID,
					Profile_ID,
					User_Position_ID,
					Authority_Sequence_ID,
					Is_Agreed,
					Agreed_Amount,
					Profile_Approval_Amount,
					Profile_Deviation_Amount,
					Created_Date,
					Deleted
			FROM	BB_Agreed_Info
			WHERE	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND		User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 	Deleted = 0
		</cfquery>

		<!---
			Check to see if the user already agreed to the Billback. If Yes, then UPDATE else INSERT
		Dev Note:Milan (30792) - A user cannot agree to a billback more than once, so UPDATE query is not being used.
		--->
		<!---<cfif checkAgreeInfo.RecordCount EQ 0>--->
			<cfquery name="InsertAgreeInfo" datasource="#Application.Datasource#">
				INSERT INTO
				BB_Agreed_Info(	Billback_ID,
								User_ID,
								Profile_ID,
								User_Position_ID,
								Authority_Sequence_ID,
								Is_Agreed,
								Profile_Approval_Amount,
								Profile_Deviation_Amount,
								Agreed_Amount)
				SELECT 			<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
								_Users.User_ID,
								Profiles_ID,
								User_Positions_ID,
								ISNULL(Authority_Sequence_ID,0),
								1,
								<cfqueryparam value="#Approve_Tot_Amount#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#Approve_Devi_Amount#" cfsqltype="CF_SQL_VARCHAR">,
								<cfqueryparam value="#BillbackTotal#" cfsqltype="CF_SQL_FLOAT">
				FROM 				_Users
				INNER JOIN 			User_Position_Holders ON User_Position_Holders.User_ID = _Users.User_ID AND User_Position_Holders.User_Positions_ID <> 0 AND
									User_Position_Holders.Deleted = 0

				WHERE 				_Users.User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		<!---
		<cfelse>
			<cfquery name="UpdateAgreeInfo" datasource="#Application.Datasource#">
				UPDATE 	BB_Agreed_Info
				SET		Is_Agreed = 1,
						Profile_Approval_Amount = <cfqueryparam value="#Approve_Tot_Amount#" cfsqltype="CF_SQL_VARCHAR">,
						Profile_Deviation_Amount = <cfqueryparam value="#Approve_Devi_Amount#" cfsqltype="CF_SQL_VARCHAR">,
						Agreed_Amount = <cfqueryparam value="#BillbackTotal#" cfsqltype="CF_SQL_FLOAT">
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND		User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
		--->
		<!--- There should be code here to update the selected reason code, but since there is no reason code to select we skip those steps --->

		<!--- Save the reasons for billback agree --->
		<cfset BBWorkFlowManager.saveBillbackAgreeReason(Billback_ID,request.AccessStructure.User_ID, lAgreeReasons) />

		<cfquery name="UpdateApprovablePositions" datasource="#Application.Datasource#">
			exec Populate_Billback_Approvable_Positions '#Billback_ID#'
		</cfquery>

		<cfif appsettings.getBillbackModifyAgree() EQ 1>
			<!--- Check If modify agree is 1 --->
			<cfset useLakebaseForgetBBInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForgetBBInfo>
	<cftry>
		<cfset getBBInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#",
				"select" = "bb_modify_agree"
			}), "bb_modify_agree"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBBInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBBInfo>
<cfquery name="getBBInfo" datasource="#application.datasource#">
				SELECT BB_Modify_Agree
				FROM Billback
				WHERE Billback_Id = '#Billback_ID#'
			</cfquery>
</cfif>
			<cfif getBBInfo.BB_Modify_Agree EQ 1>
				<cfinclude template="/billbacks/Approval/save_modifyagree_BBchanges.cfm">
				<cfset useLakebaseForUpdateModifyAgreeInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdateModifyAgreeInfo>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#Billback_ID#"
			},
			{
				"bb_modify_agree" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateModifyAgreeInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateModifyAgreeInfo>
<cfquery name="UpdateModifyAgreeInfo" datasource="#Application.Datasource#">
					UPDATE	Billback
					SET 	BB_modify_agree = 0
					WHERE 	Billback_Id = '#Billback_ID#'
				</cfquery>
</cfif>
			</cfif>
		</cfif>

		<!---
		<cfset this.sendAgreeEmail(argBillback_ID = Billback_ID) />
		--->
		<cfreturn />

	</cffunction>

	<!--- This function has been checked for any other variable and we only need the Billback_ID --->
	 <cffunction name="sendAgreeEmail" access="remote" hint="processes and saves the settlement tab records">
		<cfargument name="argBillback_ID" type="string">

		<cfset Billback_ID = arguments.argBillback_ID />
		<cfset AgreeEmailBillbackId = arguments.argBillback_ID />
		<cfset AgreeEmailUserId = request.AccessStructure.User_ID />

		<cfset appSettings = CreateObject("component", "components.settings.ApplicationSettingsManager").get() />
		<cfset BillbackManager = CreateObject("component", "components.billback.BillbackManager").init() />
		<cfif appSettings.getBBAgreeEmail()>
			<cfif BillbackManager.sendEmailtoNextCRA(AgreeEmailBillbackId, AgreeEmailUserId)>
				<cfset LocationFrom = "UponAgree">
				<cfset Billback_ID = AgreeEmailBillbackId>
				<!--- This file has been checked for any other variable and we only need the Billback_ID --->
				<cfinclude template="/ANYTHING_AUTOMATED/EMAIL/rfa_billback_emailer.cfm">
				<cfparam name="didWeSendEmail" 	default="0">
				<cfif didWeSendEmail>
					<cfset BillbackManager.setSentEmailtoNextCRA(AgreeEmailBillbackId, AgreeEmailUserId) />
				</cfif>
			</cfif>
		</cfif>
	</cffunction>

 	<cffunction name="getBBTemplateApproval" returntype="boolean" access="public">
		<cfargument name="billbackId" default="12345678-1234-1234-1234-123456789012">
		<cfargument name="profilesId" default="0" >
		<cfscript>
			var GetFA_AppSetting = QueryNew('ForbidAllowProfilesInTemplates');
			var CheckTemplateApprovalRights = QueryNew('temp');
			var TemplateApprovalRight = 0;
		</cfscript>
		<cfset useLakebaseForGetFA_AppSetting = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGetFA_AppSetting>
	<cftry>
		<cfset GetFA_AppSetting = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "forbidallowprofilesintemplates"
			}), "forbidallowprofilesintemplates"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetFA_AppSetting = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetFA_AppSetting>
<CFQUERY NAME="GetFA_AppSetting" DATASOURCE="#Application.Datasource#">
			SELECT ForbidAllowProfilesInTemplates FROM _Application_Settings
		</CFQUERY>
</cfif>
		<cfscript>
			CheckTemplateApprovalRights = this.BBSettlementDAO.checkTemplateApprovalRights(	arguments.billbackId,
																							arguments.profilesId,
																							GetFA_AppSetting.ForbidAllowProfilesInTemplates);
			IF (GetFA_AppSetting.ForbidAllowProfilesInTemplates EQ 1 AND CheckTemplateApprovalRights.RecordCount EQ 0){
				TemplateApprovalRight = 1;
			}
			ELSE IF (GetFA_AppSetting.ForbidAllowProfilesInTemplates EQ 0 AND CheckTemplateApprovalRights.RecordCount GT 0){
				TemplateApprovalRight = 1;
			}

			return TemplateApprovalRight;
		</cfscript>
	</cffunction>

	<cffunction name="fnClosingMethodsCompareAndRemove" returntype="array" access="remote" hint="">
		<cfargument name="bbHeader" type="struct">

		<cfset var stDeductionIdKeys		= structNew() />
		<cfset var stDeductionNumberKeys	= structNew() />
		<cfset var lDeductionIds 			= "" />
		<cfset var lDeductionNumberIds 		= "" />

		<!--- Check to see, if there are any closing methods for the given Billback --->
		<cfset BBExistingClosingDetailObj 		= this.getBillbackSettlement(arguments.bbHeader.billbackIDInt) />
		<cfset BBExistingClosingDetailObjLen	= arrayLen(BBExistingClosingDetailObj) />
		<cfset BBArgClosingDetailObj 	  		= arguments.bbHeader.bbSettlement.bbClosingDetail />
		<cfset BBArgClosingDetailObjLen 		= arrayLen(BBArgClosingDetailObj) />
		<!---
			Compare each closingMethodID between Existing and argument
			- check if closingmethodID  exists and
			- if amount is different
		--->

		<cfset 	stClosingMethodsToSave =	StructNew() />
		<cfset	arrClosingMethodToSave = 	ArrayNew(1) />

		<cfloop index="ARG" from="1" to="#BBArgClosingDetailObjLen#">
			<!--- We are discarding the closing method where the amount are equal since those are already saved and we won't be saving it again --->
			<!--- <cfif (BBExistingClosingDetailObj[EX].closingMethod.ID EQ BBArgClosingDetailObj[ARG].closingMethod.ID AND BBExistingClosingDetailObj[EX].amount NEQ  BBArgClosingDetailObj[ARG].Amount AND BBExistingClosingDetailObj[EX].amount NEQ 0)> --->
			 	<!--- <cfset 	stClosingMethodsToSave =	StructNew() /> --->
				<cfset stClosingMethodsToSave["ID"] 	 	   	= BBArgClosingDetailObj[ARG].closingMethod.ID />
				<cfset stClosingMethodsToSave["Amount"] 	   	= BBArgClosingDetailObj[ARG].Amount />
				<cfset stClosingMethodsToSave["Description"]  	= BBArgClosingDetailObj[ARG].closingMethod.Description />
				<cfset stClosingMethodsToSave["Abbreviation"]	= BBArgClosingDetailObj[ARG].closingMethod.Abbreviation />
				<cfif StructKeyExists(BBArgClosingDetailObj[ARG],"deduction") and isStruct(BBArgClosingDetailObj[ARG].deduction)>
					<cfset stClosingMethodsToSave["deduction"] 		= BBArgClosingDetailObj[ARG].deduction />
				<cfelse>
					<cfset stClosingMethodsToSave["deduction"] = CreateObject("component","mvc.Models.Deduction.vos.Deduction").init() />
					<cfset BBArgClosingDetailObj[ARG]["deduction"] = CreateObject("component","mvc.Models.Deduction.vos.Deduction").init() />
				</cfif>
				<!--- <cfset ArrayAppend(arrClosingMethodToSave, stClosingMethodsToSave)> --->
				<cfset ArrayAppend(arrClosingMethodToSave, duplicate(stClosingMethodsToSave))>

				<!--- Compile a list of Deduction IDs passed into this function if they exist. We'll need this list in the sceario where the user is saving a Deduction that's already saved --->
				<!---<cfif structKeyExists(BBArgClosingDetailObj[ARG],"deduction.DeductionID") and trim(BBArgClosingDetailObj[ARG].deduction.DeductionID) neq "">--->
				<cfif StructKeyExists(BBArgClosingDetailObj[ARG],"deduction") and isStruct(BBArgClosingDetailObj[ARG].deduction) and structKeyExists(BBArgClosingDetailObj[ARG].deduction,"DeductionID") and trim(BBArgClosingDetailObj[ARG].deduction.DeductionID) neq "">
					<cfset structInsert(stDeductionIdKeys, trim(BBArgClosingDetailObj[ARG].deduction.DeductionID), "" , "true") />
					<cfset structInsert(stDeductionNumberKeys, trim(BBArgClosingDetailObj[ARG].deduction.deductionNumber), "" , "true") />
				</cfif>

			<!--- </cfif> --->
		</cfloop>

		<cfset lDeductionIds 		= StructKeyList(stDeductionIdKeys) />
		<cfset lDeductionNumberIds	= StructKeyList(stDeductionNumberKeys) />

		<cfset arrClosingMethodsToSaveLen = ArrayLen(arrClosingMethodToSave) />
		<!--- Remove the Closing methods from the current Billback so that the new one can be associated in the approvesettlement function --->
		<cfif (arrClosingMethodsToSaveLen GTE 1)>
			<!--- Since there is atleast one closing method that does not match with the previous we will flush the existing ones and --->
			<cfloop index="EX" from="1" to="#BBExistingClosingDetailObjLen#">
				<cfset thisDetailObj = BBExistingClosingDetailObj[EX] />

				<!--- Unassociate the Deduction if the Deduction and its relative write off or re-instate getting passed in doesn't already exist in the DB --->
				<cfif structKeyExists(thisDetailObj,"closingMethod") and thisDetailObj.Deduction.DeductionID NEQ "">
					<cfif (trim(lDeductionIds) neq "" and ListFindNoCase(lDeductionIds, trim(thisDetailObj.Deduction.DeductionID)) eq 0) and (trim(lDeductionNumberIds) neq "" and ListFindNoCase(lDeductionNumberIds, trim(thisDetailObj.Deduction.deductionNumber)) eq 0)>
						<cfset fnUnAssociateDeduction (Deduction_ID = thisDetailObj.Deduction.DeductionID, Billback_ID =  arguments.BBHeader.BillbackIDGUID) />
					</cfif>
				</cfif>
			</cfloop>

			<!--- Function to delete all the split billbacks and leaving the parent alone --->
			<cfset this.BBSettlementDAO.removeBillbackSplits(Billback_ID = arguments.BBHeader.BillbackIDGUID) />
		</cfif>
		<cfreturn arrClosingMethodToSave />

	</cffunction>

 	<cffunction name="fnUnAssociateDeduction" returntype="any" access="remote" hint="">
		<cfargument name="Deduction_ID" type="string">
		<cfargument name="Billback_ID" type="string">

		<cfset this.BBSettlementDAO.fnUnAssociateDeductionOnDDIDDAO(Deduction_ID = arguments.Deduction_ID, Billback_ID = arguments.Billback_ID) />

		<cfreturn />

	</cffunction>

	<cffunction name="NumericRoundDecimal" output="false" returntype="string">
		<cfargument name="iValue" type="numeric" required="true" />
		<cfargument name="iDecimalLen" type="numeric" required="true" />
		<cfset var divVal = 10 ^ arguments.iDecimalLen />
		<cfset var newAmount = arguments.iValue />
		<cfset newAmount = newAmount * divVal />
		<cfset newAmount = Round(newAmount) />
		<cfset newAmount = newAmount / divVal />

		<cfreturn newAmount />

	</cffunction>

	<cffunction access="public" name="getAgreeReasons" output="false" returntype="string" hint="returns list of agree reasons">

		<cfargument name="bbHeader"			type="struct"	required="true" />
		<cfargument name="bWriteOffExists" 	type="boolean" 	required="true" />
		<cfargument name="nWriteOffAmt" 	type="numeric" 	required="true" />

		<cfscript>

			//set local variables
			var stData							= structNew();
			var	bWOExists						= 0;
			var nWOAmount						= 0;
			var lAgreeReasons					= "";
			var deviationAmount 				= 0;
			var qGetProfileSettings 			= "";
			var bCanApprove 					= 0;
			var profileApproveAmount 			= 0;
			var profileDeviationAmount 			= 0;
			var bApproveLastDateToClaim 		= 0;
			var bApproveBillbackBeyondBudget	= 0;
			var profileWriteOffamount			= 0;
			var appSettings 					= "";

			//assign local variables
			stData							= arguments.bbHeader;
			bWOExists						= arguments.bWriteOffExists;
			nWOAmount						= arguments.nWriteOffAmt;
			qGetProfileSettings 			= this.profileMgr.getProfileSettings(request.AccessStructure.Profiles_ID);
			bCanApprove 					= trim(qGetProfileSettings.BB_APPROVE);
			profileApproveAmount 			= trim(qGetProfileSettings.BB_TOT_APPROVE_AMOUNT);
			profileDeviationAmount 			= trim(qGetProfileSettings.BB_APPROVE_AMOUNT);
			bApproveLastDateToClaim 		= trim(qGetProfileSettings.APPROVE_LAST_DATE_TO_CLAIM);
			bApproveBillbackBeyondBudget	= trim(qGetProfileSettings.Approve_BB_Beyond_Budget);
			profileWriteOffamount			= trim(qGetProfileSettings.DD_MATCH_CENTRAL_WRITE_OFF_AMOUNT);
			appSettings 					= application.appSettingsGet;
			deviationAmount 				= val(trim(stData.finalSelectedAmount)) - val(trim(stData.expectedAmt));

			//-----------------------------APPROVE-----------------------------------------------------
			if (bCanApprove neq 1){
				lAgreeReasons = listAppend(lAgreeReasons, "User cannot approve billbacks.", "|");
			}

			//-----------------------------WRITE OFF-----------------------------------------------------
			// Note: I use the abs function here - so, even the negative writeoff amount cannot exceed the profile writeoff amount.
			if (profileWriteOffamount neq "*" and bWOExists and (val(profileWriteOffamount) lt val(abs(nWOAmount)))){
				lAgreeReasons = listAppend(lAgreeReasons, "The billback write off amount exceeds the approval level." , "|");
			}

			//---------------------------------APPROVAL AMOUNT-------------------------------------------------
			if (profileApproveAmount neq "*" and (val(profileApproveAmount) gt 0) and (profileApproveAmount lt val(stData.finalSelectedAmount))){
				lAgreeReasons = listAppend(lAgreeReasons, "The billback approval amount exceeds the approval level." , "|");
			}

			//----------------------------------DEVIATION AMOUNT------------------------------------------------
			if (profileDeviationAmount neq "*" and val(profileDeviationAmount) gt 0 and val(profileDeviationAmount) lt deviationAmount){
				lAgreeReasons = listAppend(lAgreeReasons, "The billback deviation amount exceeds the approval level." , "|");
			}

			//------------------------------LAST DATE TO CLAIM----------------------------------------------------
			if (bApproveLastDateToClaim neq 1 and trim(stData.bbSettlement.lastDateToClaim) eq "YES"){
				lAgreeReasons = listAppend(lAgreeReasons, "User cannot approve billbacks beyond last date to claim." , "|");
			}

			//-----------------------------------TEMPLATE APPROVAL-----------------------------------------------
			if (trim(stData.bbSettlement.templateApproval) eq 0){
				lAgreeReasons = listAppend(lAgreeReasons, "User does not have approval rights for program template." , "|");
			}

			//---------------------------------------BUDGET-------------------------------------------
			if(appSettings.getBudgetsFunctionalityOn() and bApproveBillbackBeyondBudget neq 1 and stData.bbSettlement.bIsBillbackWithinBudget neq  1){
				lAgreeReasons = listAppend(lAgreeReasons, "User cannot approve billbacks beyond budget." , "|");
			}

			return lAgreeReasons;

		</cfscript>

	</cffunction>

	<!---TODO: Move this function to a DAO --->
	<cffunction name="bIsPayeeValidEFT" output="false" returntype="boolean">

		<cfargument name="payeeId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strPayeeId		= "";
			var qCheckPayee		= "";
			var bIsValidPayee	= false;

			//assign local variables
			strPayeeId	= trim(arguments.payeeId);
		</cfscript>
		<!--- EFT is at the "Vendor" level.--->
		<cfquery name="qCheckPayee" datasource="#application.datasource#">
			SELECT Count(Vendor_Master_ID) As IsEFT
			FROM	Vendor_Master
			WHERE	Deleted = 0
			AND Vendor_Master_ID = '#strPayeeId#'
			AND EFT_Customer = 'YES'
		</cfquery>

		<cfif qCheckPayee.IsEFT GT 0>
			<cfset bIsValidPayee = true />
		</cfif>

		<cfreturn bIsValidPayee />

	</cffunction>

	<!---
		within <cfscript> tag add MyDump(Var1,"C:\temp\filename.txt"); to dump the value in this location.
	--->
	<cffunction name="MyDump">
    	<cfargument name="OBJ" Required="TRUE">
		<cfargument name="filename" Required="False" default="C:\Dump.log">
    	<cfdump var="#Obj#" output="#filename#">
	</cffunction>

</cfcomponent>
