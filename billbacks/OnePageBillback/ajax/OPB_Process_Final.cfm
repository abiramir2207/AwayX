<!--- Match Central Processing Controller --->
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

	<cfset MatchListArray = ListToArray(form.MATCHLIST, ',')>
	<cfset form.loopCount = ArrayLen(MatchListArray)>

<cfscript>
	MCObject = CreateObject("component", "MVC.Models.OnePageBillback.OPBProcessFinal");
	DDMgr = CreateObject("Component","components.Deduction.DeductionManager").init();
	BBMgr = CreateObject("Component","components.Billback.BillbackManager").init();

	bAutoReconcile = application.appSettingsget.getAuto_Reconcile_Match_Central_BB();
	getDDAutoMatchSettings = MCObject.getDDAutoMatchSettings();
	Dollar_Amount_Value = getDDAutoMatchSettings.Dollar_Amount_Value;
	matchCentralUserID = request.AccessStructure.User_ID;

	for (i=1 ; i LTE FORM.loopCount ; i=i+1) {
		// Set variables for each work item
		WorkItemID 					= form.workItemID;
		MatchList 					= form.matchlist;
		ClassificationID 			= form.ClassificationID;
		ReasonCode 					= form.ReasonCode;
		SplitReason 				= form.SplitReason;
		WhatToDo 					= form.whatToDo;
		isExactMatch				= form.isExactMatch;
		RemainingAmount				= form.RemainingAmount;
		writeOffReason				= form.WriteOffReason;
		reasonCodeForSplit 			= form.ReasonCodeForSplit;
		ClassificationIDForSplit 	= form.ClassificationIDForSplit;
		ClearedAmount		 		= form.ClearedAmount;
		SplitRecord					= form.SplitRecord;
		// Ana - 19384 - rebill Package
		RebillPakID					= form.RebillPakID;
		if (RebillPakID NEQ "")
		{
		RebillDefaultMsg				= form.Default_Message;
		RebillAddOnMsg					= form.rebillMessage;	
		RebillClassID				= form.RebillClassIDForSplit;
		RebillRCID					= form.RebillRCForSplit;
		}
		
		var_split_record_type 		= "";
		var_split_record_id 		= "";
		dd1 						= "";
		dd2 						= "";
		bb1							= "";
		bb2							= "";
		remBalID					= "";
		Parent_ID					= "";
		WorkItemDeductionId			= "";
		FinalClearedAmount			= 0;
		j = 0; // just to make sure we are using the same j
		
		if (NOT isNumeric(ClassificationIDForSplit)) {
			ClassificationIDForSplit = 0;
		}
		//D34319:Wendy can't match Gordon's credit to Deduction
		if (NOT isNumeric(ClassificationID)) {
			ClassificationID = 0;
		}

		matchType = form.MatchItemType;
		workType = form.WorkItemType;

		if (workType EQ "BB") { // IF WORK TYPE IS BILLBACK
			if (matchType EQ "DD" OR matchType EQ "CR"){ // FOR MATCHING DEDUCTIONS/CREDITS TO BILLBACKS
				
				/*if there is a balance we need to split the billback/deduction selected by the user
						and use the appropriate id in the match list if deduction is getting split*/
				dd1 = "";
				dd2 = "";

				if (!isExactMatch and SplitRecord neq ""){
					var_split_record_type = ListFirst(SplitRecord, ":");
					var_split_record_id = ListLast(SplitRecord, ":");

					if(var_split_record_type neq "BB" and var_split_record_id neq ""){//slit the deduction for the balance
						qDedInfo = DDMgr.getDeduction(Trim(var_split_record_id));
						newDedAmount = qDedInfo.DD_Amount + RemainingAmount;
						// Split the deduction and create id values for each remaining
						splitArray = DDMgr.splitDeduction(
								deductionId = Trim(var_split_record_id),
								newDeductionAmount = newDedAmount,
								currentRecordSplitClassificationID = classificationID,
								currentRecordSplitReason = splitReason,
								balanceRecordSplitClassificationID = classificationIDForSplit,
								balanceRecordSplitReason = splitReason);
					
						dd1 = splitArray[1]; // Original child or new first split
						dd2 = splitArray[2]; // Split deduction to write off or keep open
						
						MatchList = Replace(MatchList, Trim(var_split_record_id), dd1);
					}
				}
				
				if(listLen(MatchList) eq 1 and var_split_record_type neq "BB"){//if only one deduction and balance is not against bb we do not have to split the billback
					
					matching_id = listGetAt(MatchList,1);
					DDMgr.setAssociatedBB( Deduction_ID = matching_id, Billback_ID = WorkItemID );							
					Parent_ID = WorkItemID;
												
				}
				else{
				//if more than one deduction or if the balance is against bb we need to split the billback
		
					BillbackSplitManager = CreateObject("component", "components.Billback.BillbackSplitManager").init();
								
					frmStruct = StructNew();
					splitCount = 0;
			
					/* now that we allow users to select already split billback to work list
					    we need to handle so that existing siblings are in tact.
					    so let us first find if the billback already has split siblings */
					 
					qBillbackDetails = BBMgr.getBillbackDetails(billbackID = WorkItemID);
					var_max_sp_number = 0;

					//writedump(var=MatchList,output='c:\dump2.log');

					if(qBillbackDetails.BB_Split_Number != ""){//this billback is a split
						qExistingSplitChildren = BillbackSplitManager.getExistingSplitChildren(billbackID = WorkItemID);
						
						// loop over all existing children and add to the form scope struct.
						for (j=1;j LTE qExistingSplitChildren.RecordCount;j=j+1){
							// insert a row for current billback, so that record will get deleted. 
							StructInsert(frmStruct, "Closing_method_#j#", qExistingSplitChildren["BB_Closing_Method"][j]); // 2 = deduction
							StructInsert(frmStruct, "IsCreated_#j#", 0); // do not create (INSERT)
							if(qExistingSplitChildren["Billback_ID"][j] eq WorkItemID){
								StructInsert(frmStruct, "IsDeleted_#j#", 1); // set deleted = 1
							}
							else{
								StructInsert(frmStruct, "IsDeleted_#j#", 0);
							} 						
							StructInsert(frmStruct, "Amt_Child_#j#", qExistingSplitChildren["Paid_Amount"][j]);
							StructInsert(frmStruct, "Split_Reason_#j#", qExistingSplitChildren["BB_Split_Reason"][j]);
							StructInsert(frmStruct, "Child_UUID_#j#", qExistingSplitChildren["Billback_ID"][j]);
							
							/*var_max_sp_number = Val(qExistingSplitChildren["BB_Split_Number"][j]);
							    D40598 :: Event error and system time out when using Matchcentral... */
							var_max_sp_number = j;
							splitCount = var_max_sp_number;						
						}

					}
					
					for (j=1;j LTE listLen(MatchList);j=j+1){
						matching_id = listGetAt(MatchList,j);
						qMatchInfo = DDMgr.getDeduction(matching_id);
						thisMatchItemAmount = qMatchInfo.DD_Amount;
						var_split_counter = j + var_max_sp_number;
						
						StructInsert(frmStruct, "Closing_method_#var_split_counter#", 2); // 2 = deduction
						StructInsert(frmStruct, "IsCreated_#var_split_counter#", 1);
						StructInsert(frmStruct, "IsDeleted_#var_split_counter#", 0);
						StructInsert(frmStruct, "Amt_Child_#var_split_counter#", thisMatchItemAmount);
						StructInsert(frmStruct, "Split_Reason_#var_split_counter#", "match central split");
						StructInsert(frmStruct, "Child_UUID_#var_split_counter#", "");
						
						splitCount = var_split_counter;
					}			
					
					/*handle remaining balance
					 user selected to split the billback to leave the balance*/
					autoReconcile = 0;
					if(var_split_record_type eq "BB" and var_split_record_id neq ""){//slit the billback for the balance
						if(WhatToDo == 'auto' || bAutoReconcile){ //Auto Reconcile the BB splits so there is no remainder
							autoReconcile = 1;
						}
						
						var_balance_index = var_max_sp_number + listLen(MatchList) + 1;
						splitCount = splitCount + 1;
						
						StructInsert(frmStruct, "Closing_method_#var_balance_index#", 2); // 2 = deduction
						StructInsert(frmStruct, "IsCreated_#var_balance_index#", 1);
						StructInsert(frmStruct, "IsDeleted_#var_balance_index#", 0);
						StructInsert(frmStruct, "Amt_Child_#var_balance_index#", RemainingAmount);
						StructInsert(frmStruct, "Split_Reason_#var_balance_index#", "match central split");
						StructInsert(frmStruct, "Child_UUID_#var_balance_index#", "");
						
					}

					Parent_ID = BillbackSplitManager.SplitBillback(billbackID = WorkItemID, form = frmStruct, splitCount = splitCount, existingChildCount = var_max_sp_number, autoReconcile = autoReconcile);
					
					/*  ASSOCIATE DEDUCTIONS TO EACH RESPECTIVE BILLBACK, 
						FUNCTION FINDS CHILDREN AND ASSOCIATES BASED ON DD_AMOUNT */
					MCObject.AssociateDDtoBB(BBParentID = Parent_ID, DDList = MatchList, splitStartCount = var_max_sp_number);
				
				}		
				
				/* CLOSE ALL THE DEDUCTIONS
					 Billback ->  many deductions*/
				for (j=1;j LTE listLen(MatchList);j=j+1){
					matching_id = listGetAt(MatchList,j);
					qMatchInfo = DDMgr.getDeduction(matching_id);
					thisMatchItemAmount = qMatchInfo.DD_Amount;
					if(thisMatchItemAmount eq DDMgr.getAssociatedBBTotal(deductionId=matching_id)){// close only if the billbacks got attached properly (we validate on the amount)
						DDMgr.closeDeduction(Deduction_ID = matching_id, ReasonCode = ReasonCode, ClearedAmount = thisMatchItemAmount, isMatchCentral = true, Classification_ID = classificationID);
					}
				}
				
				
				if (WhatToDo EQ "writeOff" and dd2 NEQ "" and var_split_record_type neq "BB")
				{
					/*	
						If the user has permission to write it off, 
						then do so if it is within the profile threshold
						If not, then just leave it open. 
					*/
					writeOffVal = Get_Profile_Settings.DD_Match_Central_Write_Off_Amount;
					
					if (writeOffVal NEQ "*"){
						minWriteOff = writeOffVal - (writeOffVal * 2);
						maxWriteOff = writeOffVal;
					}
					if ((writeOffVal EQ "*") OR (RemainingAmount GTE minWriteOff AND RemainingAmount LTE maxWriteOff))
					{
						MCObject.writeOffDD(dd2,writeOffReason);
					}
					
					// Close deduction 2
					// Write-Off
					DDMgr.closeDeduction(
						Deduction_ID = dd2, 
						ReasonCode = reasonCodeForSplit, 
						ClearedAmount = -1 * RemainingAmount, 
						isMatchCentral = true
						,Classification_ID = classificationID);
				}
				//Ana - D19384 - Rebill Integration 
				else if (WhatToDo EQ "rebill" and dd2 NEQ "" and var_split_record_type neq "BB")
				{					
					MCObject.rebillDD(dd2,RebillPakID,RebillDefaultMsg,RebillAddOnMsg,RebillClassID,RebillRCID);										
				}
				
			}
		} else { // IF WORK TYPE IS CREDIT OR DEDUCTION

			/* Check whether deduction is available for matching. 
			This will prevent processing more than once, in case of an error.
			Multiple processing can cause duplicate records. 
			*/
			dedForMatching = MCObject.getIsDeductionAvailableForMatching(WorkItemID);

			if (matchType EQ "BB" AND dedForMatching GT 0){ 
			// FOR MATCHING BILLBACKS TO DEDUCTIONS 
				// Check to see if the match is exact
				if (isExactMatch){			
					// Attach billbacks to deduction
					for (j=1;j LTE listLen(MatchList);j=j+1){
						billback_id = listGetAt(MatchList,j);
						DDMgr.setAssociatedBB(Deduction_ID = WorkItemID,Billback_ID = billback_id);
					}
					
					// Close deduction
					// deduction ->  many billbacks (exact match)
					if(Val(ClearedAmount) eq DDMgr.getAssociatedBBTotal(deductionId=WorkItemID)){
					// close only if the billbacks got attached properly (we validate on the amount)
						DDMgr.closeDeduction(
								Deduction_ID = WorkItemID, 
								ReasonCode = ReasonCode, 
								ClearedAmount = ClearedAmount, 
								isMatchCentral = true
								,Classification_ID = classificationID);
					}
					
				} 
				else{ // If not exact match
					var_split_record_type = ListFirst(SplitRecord, ":");
					var_split_record_id = ListLast(SplitRecord, ":");

					if(var_split_record_type eq "BB"){

						//split the billback to leave the balance
						// split the billback record and replace with new id in the match list
						
						BillbackSplitManager = CreateObject("component", "components.billback.BillbackSplitManager").init();
								
						frmStruct = StructNew();
						splitCount = 0;
						 
						qBillbackDetails = BBMgr.getBillbackDetails(billbackID = Trim(var_split_record_id));
						var_max_sp_number = 0;
						
						// if the current record we are going to split is already a split, get those records and add to form scope
						if(qBillbackDetails.BB_Split_Number != ""){
							//this billback is a split
							qExistingSplitChildren = BillbackSplitManager.getExistingSplitChildren(billbackID = var_split_record_id);
							
							// loop over all existing children and add to the form scope struct.
							for (j=1;j LTE qExistingSplitChildren.RecordCount;j=j+1){
								// insert a row for current billback, so that record will get deleted. 
								StructInsert(frmStruct, "Closing_method_#j#", qExistingSplitChildren["BB_Closing_Method"][j]); // 2 = deduction
								StructInsert(frmStruct, "IsCreated_#j#", 0); // do not create (INSERT)
									if(qExistingSplitChildren["Billback_ID"][j] eq var_split_record_id){
										StructInsert(frmStruct, "IsDeleted_#j#", 1); // set deleted = 1
									}
									else{
										StructInsert(frmStruct, "IsDeleted_#j#", 0);
									} 						
								StructInsert(frmStruct, "Amt_Child_#j#", qExistingSplitChildren["Paid_Amount"][j]);
								StructInsert(frmStruct, "Split_Reason_#j#", qExistingSplitChildren["BB_Split_Reason"][j]);
								StructInsert(frmStruct, "Child_UUID_#j#", qExistingSplitChildren["Billback_ID"][j]);
								
								var_max_sp_number = Val(qExistingSplitChildren["BB_Split_Number"][j]);
								splitCount = var_max_sp_number;
							}
						}
						
						// add record 1 which will be matched against the deduction / credit
						var_bb_index = var_max_sp_number + 1;
						splitCount = splitCount + 1;
						
						StructInsert(frmStruct, "Closing_method_#var_bb_index#", 2); // 2 = deduction
						StructInsert(frmStruct, "IsCreated_#var_bb_index#", 1);
						StructInsert(frmStruct, "IsDeleted_#var_bb_index#", 0);
						StructInsert(frmStruct, "Amt_Child_#var_bb_index#", qBillbackDetails.Paid_Amount + RemainingAmount);
						StructInsert(frmStruct, "Split_Reason_#var_bb_index#", "match central split");
						StructInsert(frmStruct, "Child_UUID_#var_bb_index#", "");
						
						// add record 2 which will be the balance
						var_bb_index = var_bb_index + 1;
						splitCount = splitCount + 1;
						
						StructInsert(frmStruct, "Closing_method_#var_bb_index#", 2); // 2 = deduction
						StructInsert(frmStruct, "IsCreated_#var_bb_index#", 1);
						StructInsert(frmStruct, "IsDeleted_#var_bb_index#", 0);
						StructInsert(frmStruct, "Amt_Child_#var_bb_index#", -1 * RemainingAmount);
						StructInsert(frmStruct, "Split_Reason_#var_bb_index#", "match central split");
						StructInsert(frmStruct, "Child_UUID_#var_bb_index#", "");

						Parent_ID = BillbackSplitManager.SplitBillback(billbackID = Trim(var_split_record_id), form = frmStruct, splitCount = splitCount, existingChildCount = var_max_sp_number);						
						bb1 = MCObject.getBBToAssociate(BBParentID = Parent_ID, BBAmount = qBillbackDetails.Paid_Amount + RemainingAmount, splitIndex = var_max_sp_number + 1);								
						bb2 = MCObject.getBBToAssociate(BBParentID = Parent_ID, BBAmount = RemainingAmount, splitIndex = var_max_sp_number + 2);

						// use bb1 to match against bb
						MatchList = Replace(MatchList, Trim(var_split_record_id), bb1);					
						WorkItemDeductionId = WorkItemID;
						FinalClearedAmount = ClearedAmount + RemainingAmount;
						
					}// end: if(var_split_record_type eq "BB")
					else{
					//split the deduction to leave the balance

						IF(WhatToDo NEQ "auto"){  //ONLY SPLIT iF NOT AutoReconcile
							// Split the deduction and create id values for each remaining
							splitArray = MCObject.splitDD(ddID = WorkItemID, bbID = MatchList, classificationID = ClassificationID, splitReason = SplitReason, classificationIDForSplit = ClassificationIDForSplit, splitReasonForSplit = SplitReason);
							dd1 = splitArray[1]; // Original child or new first split
							dd2 = splitArray[2]; // Split deduction to write off or keep open						
							WorkItemDeductionId = dd1;							
							FinalClearedAmount = ClearedAmount;	
						}

						if (WhatToDo EQ "writeOff"){
							/*	
								If the user has permission to write it off, 
								then do so if it is within the profile threshold
								If not, then just leave it open. 
							*/
							writeOffVal = Get_Profile_Settings.DD_Match_Central_Write_Off_Amount;

							if (writeOffVal NEQ "*"){
								minWriteOff = writeOffVal - (writeOffVal * 2);
								maxWriteOff = writeOffVal;
							}
							if ((writeOffVal EQ "*") OR (RemainingAmount GTE minWriteOff AND RemainingAmount LTE maxWriteOff)){
								MCObject.writeOffDD(dd2,writeOffReason);
							}
							// Close deduction 2
							// write-off
							DDMgr.closeDeduction(Deduction_ID = dd2, ReasonCode = reasonCodeForSplit, ClearedAmount = RemainingAmount, isMatchCentral = true	, Classification_ID = classificationID);
						}else if (WhatToDo EQ "rebill" and dd2 NEQ "" and var_split_record_type neq "BB"){					
							MCObject.rebillDD(dd2,RebillPakID,RebillDefaultMsg,RebillAddOnMsg,RebillClassID,RebillRCID);										
						}
						else if (WhatToDo EQ "auto"){ ///same as bAutoReconcile = 1

							WorkItemDeductionId = WorkItemID;
							if(abs(REMAININGAMOUNT) <= Dollar_Amount_Value){ ///We should not be here if this is Not true, but check anyway
								//close the DD.  Decide if we need to adjust BB or DD
								if(REMAININGAMOUNT < 0){
										// REMAININGAMOUNT < 0 so we reduce bb Paid amount
									vaiables.setUpdateBBPaidAutoReconcile = DDMgr.setUpdateBBPaidAutoReconcile(
										REMAININGAMOUNT = REMAININGAMOUNT, 
										MatchList = MatchList);
									FinalClearedAmount = ClearedAmount + REMAININGAMOUNT;	
										// ABORT if we have an issue else let it roll
										if(vaiables.setUpdateBBPaidAutoReconcile == 0){
										 Writeoutput('THERE WAS AN ERROR.  Check the Auto Reconcile and Auto match settings');
											abort;
										}
										
								}
								else{
									//adjust the DD.  ClearedAmount is less than actual DD amount but within the automatch threshold.  we will close it to the cleared Amount
									DDMgr.closeDeduction(Deduction_ID = WorkItemID, ReasonCode = ReasonCode, ClearedAmount = ClearedAmount, 	isMatchCentral = true, autoReconcile = bAutoReconcile);
								}
							}
							else{ ///something is wrong.  we are not allowed to autoReconcile past "Dollar_Amount_Value" from ddautoMatchSettings
								Writeoutput('THERE WAS AN ERROR.  Check the Auto Reconcile and Auto match settings');
								abort;
							}
						}
																				
					}			

					// above if else handled the split of billback or deduction or credit to leave the balance
					// now we need to associate the billbacks to deduction / credit
					// Attach billbacks to deduction
					for (j=1;j LTE listLen(MatchList);j=j+1){
						billback_id = listGetAt(MatchList,j);
						DDMgr.setAssociatedBB(Deduction_ID = WorkItemDeductionId,Billback_ID = billback_id);
					}
					
					// Close deduction 1
					// deduction ->  many billbacks (with balance)
					if(Val(FinalClearedAmount) eq DDMgr.getAssociatedBBTotal(deductionId=WorkItemDeductionId)){// close only if the billbacks got attached properly (we validate on the amount)
						DDMgr.closeDeduction(Deduction_ID = WorkItemDeductionId, ReasonCode = ReasonCode, ClearedAmount = FinalClearedAmount, 	isMatchCentral = true, Classification_ID = classificationID);
					}	
					
				}
				
			}
			if (matchType EQ "DD"){ // FOR MATCHING DEDUCTIONS TO CREDITS 
				matchArray = arrayNew(1);
				remBalID = "";
				
				if (!isExactMatch){
					
					var_split_record_type = ListFirst(SplitRecord, ":");
					var_split_record_id = ListLast(SplitRecord, ":");
					
					if(var_split_record_type EQ "DD"){ 
						// if user close to leave the balance against the deduction instead of the credit
						// we need to split the deduction
						// update the matchlist with new id
						// write-off / unlock the new balance record
						
						qDedInfo = DDMgr.getDeduction(Trim(var_split_record_id));
						newDedAmount = qDedInfo.DD_Amount - RemainingAmount;
						// Split the deduction and create id values for each remaining
						splitArray = DDMgr.splitDeduction(
								deductionId = Trim(var_split_record_id),
								newDeductionAmount = newDedAmount,
								currentRecordSplitClassificationID = classificationID,
								currentRecordSplitReason = splitReason,
								balanceRecordSplitClassificationID = classificationIDForSplit,
								balanceRecordSplitReason = splitReason);
					
						dd1 = splitArray[1]; // Original child or new first split
						dd2 = splitArray[2]; // Split deduction to write off or keep open
						
						MatchList = Replace(MatchList, Trim(var_split_record_id), dd1);				
						remBalID = dd2;
					}
					
				}
				
				for (j=1;j LTE listLen(MatchList);j=j+1)
				{
					matchStruct = structNew();
					matching_id = listGetAt(MatchList,j);
					qMatchInfo = DDMgr.getDeduction(matching_id);
					thisMatchItemAmount = qMatchInfo.DD_Amount * -1;
					
					StructInsert(matchStruct, "dd_amount", thisMatchItemAmount);
					StructInsert(matchStruct, "classification", ClassificationID);
					StructInsert(matchStruct, "split_reason", SplitReason);
					
					arrayAppend(matchArray,matchStruct);
				}
				
				splitArray = DDMgr.splitDeductionMulti(
					deductionId = WorkItemID,
					arSplit = matchArray,
					balanceRecordSplitClassificationID = ClassificationIDForSplit,
					balanceRecordSplitReason = SplitReason,
					matchCentralLock = 1);
				
				/* 
					If there is a balance, you must loop through all the 
					array elements, except for the last one, which needs 
					to be written off of kept open. The loopCount below
					will handle for this.
				*/
				loopCount = listLen(MatchList);
				
				if (!isExactMatch){
					
					if(var_split_record_type EQ "CR"){ // balance record is in the credit
						
						remBalID = splitArray[arrayLen(splitArray)].deduction_id;
						
					}
					
					
					/*
						Write off the remaining balance, this will not process if there was an exact match
						this will also not process if keep it open was selected
					*/
					if (WhatToDo EQ "writeOff" AND remBalID neq "") {
						
						/*	
							If the user has permission to write it off, 
							then do so if it is within the profile threshold
							If not, then just leave it open. 
						*/
						writeOffVal = Get_Profile_Settings.DD_Match_Central_Write_Off_Amount;
						
						if (writeOffVal NEQ "*"){
							minWriteOff = writeOffVal - (writeOffVal * 2);
							maxWriteOff = writeOffVal;
						}
						if ((writeOffVal EQ "*") OR (RemainingAmount GTE minWriteOff AND RemainingAmount LTE maxWriteOff))
						{
							MCObject.writeOffDD(remBalID,writeOffReason);
						}
						
						// Close deduction 2
						// write-off
						DDMgr.closeDeduction(
							Deduction_ID = remBalID, 
							ReasonCode = reasonCodeForSplit, 
							ClearedAmount = RemainingAmount, 
							isMatchCentral = true
							,Classification_ID = classificationID);
						
					}
					else if (WhatToDo EQ "rebill" and dd2 NEQ "" and var_split_record_type neq "BB")
					{					
						MCObject.rebillDD(dd2,RebillPakID,RebillDefaultMsg,RebillAddOnMsg,RebillClassID,RebillRCID);										
					}
					
				}
				
				// Close each deduction/credit that was created by the split
				// the loopCount above will handle the balance record
				for (j=1;j LTE loopCount;j=j+1) {
						
					// attach deduction to credit
					matching_id = listGetAt(MatchList,j);
					crdToDedReturnValue = DDMgr.associateCreditsToDeduction(
						deductionId = matching_id,
						creditIdList = splitArray[j].deduction_id,
						fromCredit = 1,
						fromMatchCentral = 1);
					
					// close the deduction
					// credit ->  many deductions
					// we should not close the deduction if crdToDedReturnValue = 0
					//  we need to close the deduction and not the credit
					// credit will be already closed when we associate the crd to ded
					if(crdToDedReturnValue){
						currentAmount = -1 * splitArray[j].dd_amount;
						if(abs(currentAmount) eq abs(DDMgr.getAssociatedCRDTotal(deductionId=matching_id))){// close only if the billbacks got attached properly (we validate on the amount)
							DDMgr.closeDeduction(
								Deduction_ID = matching_id, 
								ReasonCode = ReasonCode, 
								ClearedAmount = currentAmount, 
								isMatchCentral = true
								,Classification_ID = classificationID);
						}
					}	
					// Unlock the deduction

					MCObject.deductionLocking(splitArray[j].deduction_id,'unlock');
				}
				
			}
			if (matchType EQ "CR"){ // FOR MATCHING CREDITS TO DEDUCTIONS
				// Check to see if the match is exact
				if (isExactMatch)
				{			
					// Attach credits to deduction
					crdToDedReturnValue = DDMgr.associateCreditsToDeduction(
							deductionId = WorkItemID, 
							creditIdList = MatchList, 
							fromCredit = 0);
					
					// Close deduction
					// deductions ->  many credits (exact match) 
					if(crdToDedReturnValue){
						if(abs(ClearedAmount) eq abs(DDMgr.getAssociatedCRDTotal(deductionId=WorkItemID))){// close only if the billbacks got attached properly (we validate on the amount)
							DDMgr.closeDeduction(
									Deduction_ID = WorkItemID, 
									ReasonCode = ReasonCode, 
									ClearedAmount = ClearedAmount, 
									isMatchCentral = true
									,Classification_ID = classificationID);
						}
					}
				} 
				else // If not exact match
				{
					var_split_record_type = ListFirst(SplitRecord, ":");
					var_split_record_id = ListLast(SplitRecord, ":");
					remBalID = "";
					
					if(var_split_record_type EQ "CR"){ // the credit should be split to leave the balance
						
						// Split the deduction and create id values for each remaining
						splitArray = DDMgr.splitDeduction(
										deductionId = Trim(var_split_record_id),
										newDeductionAmount = RemainingAmount,
										currentRecordSplitClassificationID = ClassificationID,
										currentRecordSplitReason = SplitReason,
										balanceRecordSplitClassificationID = ClassificationIDForSplit,
										balanceRecordSplitReason = SplitReason);
		
						dd1 = splitArray[2]; // Original child or new first split
						dd2 = splitArray[1]; // Split deduction to write off or keep open
												
						WorkItemDeductionId = WorkItemID;
						MatchList = Replace(MatchList, Trim(var_split_record_id), dd1); // replace match list with new credit id
						remBalID = dd2;
						FinalClearedAmount = ClearedAmount + RemainingAmount;
						
					}
					else{ // the deduction should be split to leave the balance
						
						// Split the deduction and create id values for each remaining
						splitArray = DDMgr.splitDeduction(
										deductionId = WorkItemID,
										newDeductionAmount = RemainingAmount,
										currentRecordSplitClassificationID = ClassificationID,
										currentRecordSplitReason = SplitReason,
										balanceRecordSplitClassificationID = ClassificationIDForSplit,
										balanceRecordSplitReason = SplitReason);
		
						dd1 = splitArray[2]; // Original child or new first split
						dd2 = splitArray[1]; // Split deduction to write off or keep open
						
						WorkItemDeductionId = dd1;
						remBalID = dd2;
						FinalClearedAmount = ClearedAmount;
					}
					
					
					// Attach credits to deduction
					crdToDedReturnValue = DDMgr.associateCreditsToDeduction(
							deductionId = WorkItemDeductionId, 
							creditIdList = MatchList, 
							fromCredit = 0);
					
					// Close deduction 1
					// deductions ->  many credits (with balance)
					if(crdToDedReturnValue){
						if(val(abs(FinalClearedAmount)) eq abs(DDMgr.getAssociatedCRDTotal(deductionId=WorkItemDeductionId))){// close only if the billbacks got attached properly (we validate on the amount)
							DDMgr.closeDeduction(Deduction_ID = WorkItemDeductionId, 
															ReasonCode = ReasonCode, 
															ClearedAmount = FinalClearedAmount, 
															isMatchCentral = true
															,Classification_ID = classificationID);
						}
					}
													
					// WHAT TO DO TO THE REMAINING BALANCE
					if (WhatToDo EQ "writeOff" AND remBalID neq "")
					{
						/*	
							If the user has permission to write it off, 
							then do so if it is within the profile threshold
							If not, then just leave it open. 
						*/
						writeOffVal = Get_Profile_Settings.DD_Match_Central_Write_Off_Amount;
						
						if (writeOffVal NEQ "*"){
							minWriteOff = writeOffVal - (writeOffVal * 2);
							maxWriteOff = writeOffVal;
						}
						if ((writeOffVal EQ "*") OR (RemainingAmount GTE minWriteOff AND RemainingAmount LTE maxWriteOff))
						{
							MCObject.writeOffDD(remBalID,writeOffReason);
						}
						
						// Close deduction 2
						// write-off
						DDMgr.closeDeduction(
							Deduction_ID = remBalID, 
							ReasonCode = reasonCodeForSplit, 
							ClearedAmount = RemainingAmount, 
							isMatchCentral = true
							,Classification_ID = classificationID);
					}
					else if (WhatToDo EQ "rebill" and dd2 NEQ "" and var_split_record_type neq "BB")
					{					
						MCObject.rebillDD(dd2,RebillPakID,RebillDefaultMsg,RebillAddOnMsg,RebillClassID,RebillRCID);										
					}
										
				}
			}
		}

		// unlock the deduction records used in this page
		if(WorkItemDeductionId neq "")
			MCObject.deductionLocking(WorkItemDeductionId,'unlock');
		if(remBalID neq "")
			MCObject.deductionLocking(remBalID,'unlock');
		if(dd1 neq "")
			MCObject.deductionLocking(dd1,'unlock');
		if(dd2 neq "")
			MCObject.deductionLocking(dd2,'unlock');
		if(var_split_record_type neq "BB" and var_split_record_id neq "")
			MCObject.deductionLocking(Trim(var_split_record_id),'unlock');
				


		// unlock the billback records used in this page
		if(Parent_ID neq "")
			MCObject.billbackLocking(Parent_ID,'unlock');
		if(bb1 neq "")
			MCObject.billbackLocking(bb1,'unlock');
		if(bb2 neq "")		
			MCObject.billbackLocking(bb2,'unlock');
		if(var_split_record_type eq "BB" and var_split_record_id neq "")
			MCObject.billbackLocking(Trim(var_split_record_id),'unlock');
		
		
		// unlock the workitem record	
		if (workType EQ "BB") {
			
			if(Parent_ID neq WorkItemID)
					MCObject.billbackLocking(WorkItemID,'unlock');
		}
		else{
			
			MCObject.deductionLocking(WorkItemID,'unlock');
			
		}
		
		// unlock the match item records
		if(matchType EQ "BB"){
			// Unlock all the matched billbacks
			for (j=1;j LTE listLen(MatchList);j=j+1)
			{
				MCObject.billbackLocking(listGetAt(MatchList,j),'unlock');
			}
		}
		else{
			for (j=1;j LTE listLen(MatchList);j=j+1)
			{
				MCObject.deductionLocking(listGetAt(MatchList,j),'unlock');
			}
		}
		
		/* Remove the work items from the worklist.
		MCObject.clearWorkListItem(WorkItemID);*/
	}
</cfscript>