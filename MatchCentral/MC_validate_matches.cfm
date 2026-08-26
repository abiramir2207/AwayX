<cfsetting showdebugoutput="false">
<cfset MCObject = createObject("Component","components.Match_Central.MatchCentral").init()>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfscript>
	workList = MCObject.CurUserWorkListIDList;
	writeOffVal = Get_Profile_Settings.DD_Match_Central_Write_Off_Amount;
    getDDAutoMatchSettings = MCObject.getDDAutoMatchSettings();
		Reconcile_Dollar_Amount_Value = getDDAutoMatchSettings.Reconcile_Dollar_Amount_Value;
  /***** Code was breaking if the writeOffVal was "" so setting this to 0 - Anand Rao 01/12/09 *****/
  if (writeOffVal EQ "") {
    writeOffVal = 0;
	}  
  
	if (writeOffVal NEQ "*") {
		minWriteOff = writeOffVal - (writeOffVal * 2);
		maxWriteOff = writeOffVal;
	}
	currentRow = 0;
	negativeBalanceWhenNoCredit = 0;
	autoReconcileDollarAmount = 0; /* WR 64833 */
	ErrorBBSplitNotAllowed = 0;
</cfscript>

<cfoutput>
<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
<table class="formError" id="negativeMessageTable" style="width:610px;display:none;" align="center">
	<tr><td>
	At least one of your matches results in a negative balance, which is not allowed based on the current configuration.<br>  
	Please adjust your matches accordingly and re-validate your match results.
	</td></tr>
</table>
<!--- WR 64833 Auto Reconcile usses Auto Close Amount value (DD_Auto_Match.Reconcile_Dollar_Amount_Value ) --->
<table class="formError" id="autoRecoAmtMessageTable" style="width:610px;display:none;" align="center">
	<tr><td>
	At least one of your total Auto Reconcile amounts is greater than <cfoutput>#Dollarformat(Reconcile_Dollar_Amount_Value)#</cfoutput> maximum allowed in the current configuration.<br>
	Please adjust your matches accordingly and re-validate your match results.
	</td></tr>
</table>
<form name="matchProcessorForm" id="matchProcessorForm" style="display:inline;">
<table id="validationTable" border="0" cellspacing="0" cellpadding="4" width="610px" align="center">

	<cfloop list="#workList#" index="idx">
		<cfscript>
			workItemType = MCObject.getWorkItemType(idx);
			matchingType = MCObject.getMatchingType(idx);
			displaySelectForSplit = 1;
			splitAction = "";
			if (workItemType EQ "CR" OR workItemType EQ "DD"){
				workItemInfo = MCObject.DDMgr.getDeduction(idx);
				workItemCode = workItemInfo.DD_DedID;
				resolutionCode = workItemInfo.DD_Resolution_Code;
				workItemAmt = workItemInfo.dd_amount;
				if (workItemType EQ "CR"){
					workItemLabel = "Credit";	
				} else if (workItemType EQ "DD"){
					workItemLabel = "Deduction";
				}
				
			} else if (workItemType EQ "BB"){
				workItemInfo = MCObject.getBBInfo(idx);
				workItemAmt = workItemInfo.bb_approved_amount;
				workItemCode = workItemInfo.BB_Code;
        // changed the below value from 0 to "" as the checking is done for "" and not for 0 in the 
        // default setting code below - Anand Rao 
				resolutionCode = ""; 
				workItemLabel = "Billback";
				displaySelectForSplit = 1;
				splitAction = "keepOpen";
			}			
			
			matchAmt = 0; // Empty value to add to
			GetReasonCodes = MCObject.getReasonCodes(idx);
			matchList = MCObject.selectedMatchListByTyp(idx);
		</cfscript>
		<!--- BB splitting not allowed --->
		<cfif workItemType EQ "BB" AND appSettings.getSplitBillbacks() EQ 0 AND Listlen(matchList) GT 1>
			<cfset ErrorBBSplitNotAllowed = 1 />
		</cfif>
		
		<cfquery name="SavedClass" datasource="#application.datasource#">
			SELECT DD_Classification_ID 
			  FROM Deductions 
			 WHERE Deduction_ID = '#idx#'
			 AND (DD_Classification_ID  is not NULL AND DD_Classification_ID <> 0)
		</cfquery>
		<cfquery name="getAllClass" datasource="#application.datasource#">
			SELECT * 
			FROM DD_Classification 
			WHERE Deleted = 0 
		        	<!--- 75969 includes saved classification regardless of its deleting status --->
					<cfif SavedClass.recordCount and SavedClass.DD_Classification_ID neq "">
						OR DD_Classification_ID = #SavedClass.DD_Classification_ID#
					</cfif>
			ORDER BY DD_Classification_Desc
		</cfquery>
		<cfquery name="getDefaultClass" dbtype="query">
			SELECT DD_Classification_ID
			FROM getAllClass 
			WHERE IS_Default = 1
		</cfquery>
		<cfquery name="getMatchCentralDefaultClass" dbtype="query">
			SELECT DD_Classification_ID
			FROM getAllClass 
			WHERE IS_MatchCentral_Default = 1
		</cfquery>
		<!--- Ana D19384 Rebill Interface package --->	
		<cfquery name="getAllRebillPackages" datasource="#application.datasource#">
			SELECT DD_Rebill_Package_Hdr_ID,Rebill_Package_Title 
			FROM DD_Rebill_Package_Hdr
			WHERE Deleted = 0 AND Active = 1
			ORDER BY Rebill_Package_Title
		</cfquery>
    <!---Gets data about deduction--->
	<cfif workItemType eq "DD">
    <cfset Deduction_ID = idx />
    <cfinclude template="/deductions/sql_Deduction_Info.cfm">
	</cfif>
    
		<cfif listLen(matchList) GT 0>
			<cfscript>
				currentRow = currentRow + 1;
				if (currentRow mod 2){
					style = "rowEven";
				} else {
					style = "rowOdd";
				}
			</cfscript>
			<input type="hidden" name="workItemID_#currentRow#" id="workItemID_#currentRow#" value="#idx#">
			<input type="hidden" name="matchList_#currentRow#" id="matchList_#currentRow#" value="#matchList#">
			<tr>
				<th width="20px" style="border-bottom:1px solid ##CCC;">#currentRow#.</th>
				<th width="150px" nowrap style="border-bottom:1px solid ##CCC;"><strong>#workItemCode#</strong></th>
				<th width="370px" style="border-bottom:1px solid ##CCC;">&nbsp;</th>
				<th nowrap style="text-align:right;border-bottom:1px solid ##CCC;">#dollarformat(workItemAmt)#</th>
			</tr>
			<tr>
				<td colspan="4" style="padding:5px;">
					<fieldset><legend>Original #workItemLabel# Actions &nbsp;</legend>
						<table border="0" cellspacing="0" cellpadding="5" width="100%">
							<tr>
								<td>
									Closure #MCObject.stDeductionLabels["Reason Code"]#:<br />
									<select name="ReasonCode_#currentRow#" id="ReasonCode_#currentRow#">
										<cfif GetReasonCodes.RecordCount GT 1>
											<option value="">
										</cfif>
										<cfloop query="GetReasonCodes">
											<option value="#DD_Reason_Code_ID#" 
											<cfif ((resolutionCode EQ "") AND (Is_Default EQ 1))>
											 selected
											<cfelseif (DD_Reason_Code_ID EQ resolutionCode)>selected</cfif>>#trim(DD_Reason_Code_Description)#</option>
										</cfloop>
									</select>
									<div class="formError" id="ReasonCode_#currentRow#_error" style="display:none;">
										Please select a #LCase(MCObject.stDeductionLabels["Reason Code"])#.
									</div>
								</td>
								<td>
									<cfif appSettings.getDD_Show_Classification()>
									#MCObject.stDeductionLabels["Classification"]#:<br />
										<cfif appSettings.getDDChangeClassificationBeforeRFA()>
											<input type="hidden" name="DefaultClass_#currentRow#" id="DefaultClass_#currentRow#" value="#getDefaultClass.DD_Classification_ID#">
										<cfelse>
											<input type="hidden" name="DefaultClass_#currentRow#" id="DefaultClass_#currentRow#" value="0">
										</cfif>
										
										<cfif getMatchCentralDefaultClass.recordcount AND ((workItemType EQ "DD" AND matchingType EQ "BB") OR (workItemType EQ "BB" AND matchingType EQ "DD"))>
											<cfset selected_classification = SavedClass.DD_Classification_ID>
											<cfif selected_classification is ''>
												<cfset selected_classification = getMatchCentralDefaultClass.DD_Classification_ID>
											</cfif>
											<select name="ClassificationID_#currentRow#" id="ClassificationID_#currentRow#">
												<option value=""></option>
												<cfloop query="GetAllClass">
													<option value="#DD_Classification_ID#" 
														<cfif GetAllClass.DD_Classification_ID eq selected_classification>selected</cfif>>
															#DD_Classification_Desc#
													</option>						
												</cfloop>
											</select>
										<cfelse>
											<cfset selected_classification = SavedClass.DD_Classification_ID>
											<cfif selected_classification is ''>
												<cfset selected_classification = getDefaultClass.DD_Classification_ID>
											</cfif>
											<select name="ClassificationID_#currentRow#" id="ClassificationID_#currentRow#">
												<option value="" <cfif selected_classification is ''>selected</cfif>></option>
												<cfloop query="GetAllClass">
													<option value="#DD_Classification_ID#" 
														<cfif GetAllClass.DD_Classification_ID eq selected_classification>selected</cfif>>
															#DD_Classification_Desc#
													</option>						
												</cfloop>
											</select>
										</cfif>
										<div class="formError" id="ClassificationID_#currentRow#_error" style="display:none;">
											Please select a #LCase(MCObject.stDeductionLabels["Classification"])# id.
										</div>
										<div class="formError" id="DefaultClass_#currentRow#_error" style="display:none;">
											** Change the default #LCase(MCObject.stDeductionLabels["Classification"])# To Enable RFA.
										</div>
									</cfif>
								</td>
							</tr>
						</table>
					</fieldset>
				</td>
			</tr>
			
			<cfswitch expression="#matchingType#">
				<cfcase value="BB">
					<cfloop list="#matchList#" index="matchIdx">
						<cfscript>
							matchInfo = MCObject.getBBInfo(matchIdx);
							matchAmt = matchAmt + matchInfo.BB_Approved_Amount;
						</cfscript>
						<tr>
							<td width="20px">#matchingType#:</td>
							<td width="150px" nowrap><strong>#matchInfo.bb_code#</strong></td>
							<td width="370px">#matchInfo.bb_title#</td>
							<td nowrap style="text-align:right;">#dollarformat(matchInfo.BB_Approved_Amount)#</td>
						</tr>
					</cfloop>
					<cfscript>
						remAmt = workItemAmt - matchAmt;
						remAmt = numberFormat(remAmt,'9.9999');	
						
						if (remAmt EQ 0) {
							remAmt = decimalFormat(remAmt);
						}
					</cfscript>
				</cfcase>
				<cfcase value="CR,DD">
					<cfloop list="#matchList#" index="matchIdx">
						<cfscript>
							matchInfo = MCObject.DDMgr.getDeduction(matchIdx);
							matchAmt = matchAmt - matchInfo.DD_Amount;
						</cfscript>
						
						<tr>
							<td width="20px">#matchingType#:</td>
							<td width="150px" nowrap><strong>#matchInfo.DD_DedID#</strong></td>
							<td width="370px">&nbsp;</td>
							<td nowrap style="text-align:right;">#dollarformat(matchInfo.DD_Amount)#</td>
						</tr>
					</cfloop>
					<cfscript>
						if (workItemType EQ "DD" OR workItemType EQ "CR"){
							remAmt = workItemAmt - matchAmt;
						} else if (workItemType EQ "BB"){
							remAmt = workItemAmt + matchAmt;
						}
						
						remAmt = numberFormat(remAmt,'9.9999');
						
						if (remAmt EQ 0) {
							remAmt = decimalFormat(remAmt);
						}			
						
					</cfscript>
				</cfcase>
			</cfswitch>
			
			<input type="hidden" name="RemainingAmount_#currentRow#" id="RemainingAmount_#currentRow#" value="#remAmt#">
			<tr>
				<td width="540px" colspan="3" style="text-align:right;border-top:1px solid ##CCC;">Remaining Balance:</td>
				<td style="text-align:right;border-top:1px solid ##CCC;">#dollarformat(remAmt)#</td>
			</tr>
			<cfif remAmt NEQ 0>
				<tr>
					<td colspan="4" style="padding:5px;">
						<fieldset><legend>Remaining Balance Split Actions &nbsp;</legend>
							<table border="0" cellspacing="0" cellpadding="5" width="100%">
              <!--- 
	              Dev Notes: D23421/Anand Rao/18-May-10
            	  New Rebill - Force Ship to
              --->
              <tr>
                <td colspan="100%">
						<cfif  workItemType eq "DD" >
						<cfif (Deduction_Info.Shr_Ship_To EQ "" AND ((writeOffVal EQ "*") OR (remAmt GTE minWriteOff AND remAmt LTE maxWriteOff)) AND workItemType eq "DD" AND appSettings.getIntegrated_Rebill())>
                      A valid "#application.returned_customer_setting.shard_ship_to_label#" is required to add a rebill package.  Please add a "#application.returned_customer_setting.shard_ship_to_label#"
                  to the Deduction before changing the status to Rebill.
                </cfif></cfif> </td>
              </tr>
								<tr>
									<cfset colSpan = 1 />
									<cfset col2Width = "50%" />
									<cfset col3Width = "50%" />
									<cfif displaySelectForSplit>
										<cfset colSpan = 2 />
										<cfset col2Width = "30%" />
										<cfset col3Width = "40%" />
										<td width="30%">
											Split Billback/Deduction/Credit: <br />
											<select name="SplitRecord_#currentRow#" id="SplitRecord_#currentRow#" onChange="adjustSplitAction(#currentRow#)">
											<!--- 35703 REWORK (SPLITTING BILLBACKS IN MATCH CENTRAL) --->	
												<cfif workItemType NEQ "BB" OR appSettings.getSplitBillbacks()>
												<option value="#workItemType#:#idx#" <cfif workItemType eq "BB">allowWriteOff="0" allowAutoReconcile="1"<cfelse>allowWriteOff="1" allowAutoReconcile="1"</cfif>>#workItemType# : #workItemCode#</option>
												</cfif>
												
						<cfif appSettings.getDDAllowNegativeAmountCredits()><!--- D25418: If credit is OFF, only allow to split work type item --->
									<cfif matchingType NEQ "BB" OR appSettings.getSplitBillbacks()>
												<cfloop list="#matchList#" index="matchIdx">											
													<!--- TODO: instead of querying the table again, we should cache it above --->
													<cfif matchingType eq "BB">>
															<cfset matchInfo = MCObject.getBBInfo(matchIdx) />
															<option value="BB:#matchIdx#" allowWriteOff="0" allowAutoReconcile="0">BB: #matchInfo.BB_Code#</option>
													<cfelse>
															<!---D41078 -- match central -- credit/deduction & deduction/credit matching logic update
•If the Deduction has an amount of $500.00 and the Credit has an amount of ($400.00); then the user should only have the option to select the deduction in the Split Billback/Deduction/Credit: Dropdown.
•If the Deduction has an amount of $100.00 and the Credit has an amount of ($500.00); then the user should only have the option to select the credit in the Split Billback/Deduction/Credit: Dropdown.
																 --->
															<cfset matchInfo = MCObject.DDMgr.getDeduction(matchIdx, Abs(workItemAmt), listlen(matchList)) />
															<cfif matchInfo.recordcount>
															<option value="#matchingType#:#matchIdx#" allowWriteOff="1" allowAutoReconcile="0"><cfif matchInfo.Is_Credit eq 0>DD: <cfelse>CR: </cfif>#matchInfo.DD_DedID_Sp_Number#</option>
															</cfif>													
													</cfif>
												</cfloop>
									</cfif>
										<!--- 35703 REWORK (SPLITTING BILLBACKS IN MATCH CENTRAL) --->
						<cfelse><!--- D25418: If credit is OFF, do not allow user to continue if the balance is negative amount --->
								<!--- WR 64833 Auto Reconcile usses Auto Close Amount value (DD_Auto_Match.Reconcile_Dollar_Amount_Value ) --->
								<cfif application.appSettingsget.getAuto_Reconcile_Match_Central_BB() EQ 1>  <!--- WR 64833 IF APPSETTING Auto_Reconcile_BB ON Check then Amount Against the getDDAutoMatchSettings--->
									<cfif abs(remAmt) GT Reconcile_Dollar_Amount_Value> <!--- If DIFF is greater than Auto reconcile amount setting, Flag Auto Reconcile Balance Error --->
										<cfset autoReconcileDollarAmount = 1 />
									</cfif>
								<cfelse> <!---AppSetting Off, so check if it is a negative balance--->
									<cfif remAmt lt 0>
										<cfset negativeBalanceWhenNoCredit = 1 />   <!---Flag Negative Balance Error--->
									</cfif>
								</cfif>	
						</cfif>
											</select>										
										</td>
									<cfelse><!--- dummy field --->
									<input type="hidden" name="SplitRecord_#currentRow#" id="SplitRecord_#currentRow#">
									</cfif>
									<cfset bAutoReconcile = 0/>
									<cfif application.appSettingsget.getAuto_Reconcile_Match_Central_BB() AND (workItemType eq "BB" OR getDDAutoMatchSettings.Enabled)>
										<cfset bAutoReconcile = 1/>
									</cfif>
                                    			<cfset bDisplayKeepItOpen = 1 />
									<cfif application.appSettingsget.get_Setting('DD_Match_Central_Keep_It_Open') neq '1'>
										<cfset bDisplayKeepItOpen = 0 />
									</cfif>
									<!--- 98259 :: Auto Reconcile Logic - Update to Match Central Write-off Feature START--->
									<cfset bDisplayWriteOff = 1 />
									<cfif application.appSettingsget.get_Setting('DD_Match_Central_Write_Off') neq '1'>
										<cfset bDisplayWriteOff = 0 />
									</cfif>
									<!--- 98259 :: Auto Reconcile Logic - Update to Match Central Write-off Feature END--->
									<td width="#col2Width#">
										<cfif (writeOffVal EQ "*") OR (remAmt GTE minWriteOff AND remAmt LTE maxWriteOff)>
											Split Action:<br />
											<select name="whatToDo_#currentRow#" id="whatToDo_#currentRow#" 	onChange="adjustWriteOffDetails(this, #currentRow#);">
											<cfif application.appSettingsget.getAuto_Reconcile_Match_Central_BB()>
												<option value="auto"<cfif bAutoReconcile>selected</cfif>>Auto Reconcile</option>
											</cfif>
											<cfif bDisplayKeepItOpen>
												<option value="keepOpen" <cfif splitAction eq "keepOpen" AND bAutoReconcile EQ 0> selected</cfif> >Keep it open</option>
											</cfif>
											<!--- Ana D19384 Rebill Interface Arrows --->	
											<cfif workItemType eq "DD" AND appSettings.getIntegrated_Rebill() AND (Deduction_Info.Shr_Ship_To NEQ "") >
												<option value="rebill">Rebill</option>
											</cfif>
											<!--- 98259 --->
											<cfif bDisplayWriteOff>
												<option value="writeOff">Write it off</option>
											</cfif>
											</select>											
										<cfelse>
											Split Action: <CF_smallLink title = "note" url = "javascript:showToolTip('accessNote#currentRow#');"><br />
											<select name="whatToDo_#currentRow#" id="whatToDo_#currentRow#" >
												<cfif bAutoReconcile>	
													<option value="auto" <cfif bAutoReconcile >selected</cfif>>Auto Reconcile</option>
												</cfif>
												<cfif bDisplayKeepItOpen>
													<option value="keepOpen">Keep it open</option>
												<cfelseif appSettings.getAuto_Reconcile_Match_Central_BB() EQ 0>
													<option value="">Select Split Action</option>
												</cfif>
											</select>
											<div id="accessNote#currentRow#" class="toolTip" style="display:none;">
												You do not have access rights to write off this amount.  Please
												contact your system administrator if you believe this is an error.
											</div>
										</cfif>
									</td>
									<td width="#col3Width#">
									<div id="writeOffOpenClass#currentRow#" <cfif splitAction eq "rebill">style="display:none;"</cfif>>
									<cfif appSettings.getDD_Show_Classification()>
									#MCObject.stDeductionLabels["Classification"]#:<br />
										<cfif appSettings.getDDChangeClassificationBeforeRFA()>
											<input type="hidden" name="DefaultClassForSplit_#currentRow#" id="DefaultClassForSplit_#currentRow#" value="#getDefaultClass.DD_Classification_ID#">
										<cfelse>
											<input type="hidden" name="DefaultClassForSplit_#currentRow#" id="DefaultClassForSplit_#currentRow#" value="0">
										</cfif>
										
										<cfif getMatchCentralDefaultClass.recordcount AND ((workItemType EQ "DD" AND matchingType EQ "BB") OR (workItemType EQ "BB" AND matchingType EQ "DD"))>
											<select name="ClassificationIDForSplit_#currentRow#" id="ClassificationIDForSplit_#currentRow#">
													<option value=""></option>
												<cfloop query="GetAllClass">
													<option value="#DD_Classification_ID#" 
														<CFIF DD_Classification_ID EQ getMatchCentralDefaultClass.DD_Classification_ID>selected</CFIF>>
															#DD_Classification_Desc#
															<!--- Change made for D17976 - Anand Rao [01/19/09]
                              <cfif Is_Default EQ 1><em> - [system default]</em></cfif>
															<cfif Is_MatchCentral_Default EQ 1><em> - [bb close default]</em></cfif> 
                              --->
													</option>						
												</cfloop>
											</select>
										<cfelse>
											<select name="ClassificationIDForSplit_#currentRow#" id="ClassificationIDForSplit_#currentRow#">
													<option value=""></option>
												<cfloop query="GetAllClass">
													<option value="#DD_Classification_ID#" 
														<cfif ((SavedClass.DD_Classification_ID EQ "") AND (Is_Default EQ 1))>selected
														<cfelseif (DD_Classification_ID EQ SavedClass.DD_Classification_ID)>selected</CFIF>>
															#DD_Classification_Desc#
															<!--- Change made for D17976 - Anand Rao [01/19/09]
                              <cfif Is_Default EQ 1><em> - [system default]</em></cfif>
															<cfif Is_MatchCentral_Default EQ 1><em> - [bb close default]</em></cfif> 
                              --->
													</option>						
												</cfloop>
											</select>
										</cfif>
										<div class="formError" id="ClassificationIDForSplit_#currentRow#_error" style="display:none;">
											Please select a #LCase(MCObject.stDeductionLabels["Classification"])# id for the split.
										</div>
										<div class="formError" id="DefaultClassForSplit_#currentRow#_error" style="display:none;">
											** Change the default #LCase(MCObject.stDeductionLabels["Classification"])# To Enable RFA.
										</div>																			
									<CFELSE>
										<input type="hidden" name="ClassificationID_#currentRow#" id="ClassificationID_#currentRow#" value="0">		
										<input type="hidden" name="ClassificationIDForSplit_#currentRow#" id="ClassificationIDForSplit_#currentRow#" value="0">													
									</cfif>
									</div>
									<!--- Ana D19384 Rebill Interface package --->	
									<div id="rebillPackage#currentRow#" <cfif splitAction eq "keepOpen" OR splitAction eq "writeOff" OR splitAction eq "">style="display:none;"</cfif>>
										Rebill Package:<br />
											<select name="RebillPakID_#currentRow#" id="RebillPakID_#currentRow#" onChange="populateRebillPakData(this, #currentRow#);" >
													<option value=""></option>
												<cfloop query="getAllRebillPackages">
													<option value="#DD_Rebill_Package_Hdr_ID#" >
															#Rebill_Package_Title#															
													</option>						
												</cfloop>
											</select>
											<div class="formError" id="RebillPackageIDForSplit_#currentRow#_error" style="display:none;">
												Please select a Rebill Package id for the split.
											</div>
										</div>
									</td>
								</tr>
								<TR>
								<TD colspan="100%">
								<div id ="rebillDtl#currentRow#">								
								</div>
								</TD>
								</TR>
								<tr>
									<td colspan="2" align="right">
									<div align="left" class="formError" id="whatToDo_#currentRow#_error" style="display:none;">
										Write off is not an option for billbacks
									</div>
									</td>
								</tr>
								<tr>
									<td colspan="#colSpan#">
										<cfif (writeOffVal EQ "*") OR (remAmt GTE minWriteOff AND remAmt LTE maxWriteOff)>
											<div id="ReasonCodeForSplit#currentRow#" <cfif splitAction eq "keepOpen" or bAutoReconcile eq 1>style="display:none;"</cfif>>
												Write off Closure #MCObject.stDeductionLabels["Reason Code"]#:<br />
												<select name="ReasonCodeForSplit_#currentRow#" id="ReasonCodeForSplit_#currentRow#">
													<cfif GetReasonCodes.RecordCount GT 1>
														<option value="">
													</cfif>
													<cfloop query="GetReasonCodes">
														<option value="#DD_Reason_Code_ID#">#trim(DD_Reason_Code_Description)#</option>
													</cfloop>
												</select>
												<div class="formError" id="ReasonCodeForSplit_#currentRow#_error" style="display:none;">
													Please select a #LCase(MCObject.stDeductionLabels["Reason Code"])# for the split.
												</div>
											</div>
										<cfelse><!--- dummy field --->
										<input type="hidden" name="ReasonCodeForSplit_#currentRow#" id="ReasonCodeForSplit_#currentRow#">
										</cfif>
									</td>
									<td>
									<cfif (writeOffVal EQ "*") OR (remAmt GTE minWriteOff AND remAmt LTE maxWriteOff)>
										<div id="writeOffReasonContainer#currentRow#" <cfif splitAction eq "keepOpen" or bAutoReconcile eq 1>style="display:none;"</cfif>>
										Write Off Reason:<br />
											<textarea name="WriteOffReason_#currentRow#" id="WriteOffReason_#currentRow#" rows="2" cols="40"
												onkeyPress="javaScript: return textareaChecklength('250', this);"
												onpaste="javaScript: return textareaChecklength('250', this);"
											></textarea>
										</div>
									<cfelse>
										<input type="hidden" name="WriteOffReason_#currentRow#" id="WriteOffReason_#currentRow#" value="">
									</cfif>
									</td>
								</tr>
							</table>
						</fieldset>
					</td>
				</tr>
				<input type="hidden" name="isExactMatch_#currentRow#" id="isExactMatch_#currentRow#" value="0">
				<input type="hidden" name="ClearedAmount_#currentRow#" id="ClearedAmount_#currentRow#" value="#matchAmt#">
				<input type="hidden" name="SplitReason_#currentRow#" id="SplitReason_#currentRow#" value="match central split">
			<cfelse>
				<tr>
					<td colspan="4" style="padding:10px;">
						<input type="hidden" name="whatToDo_#currentRow#" id="whatToDo_#currentRow#" value="">
						<input type="hidden" name="ClassificationID_#currentRow#" id="ClassificationID_#currentRow#" value="">
						<input type="hidden" name="ClassificationIDForSplit_#currentRow#" id="ClassificationIDForSplit_#currentRow#" value="">
						<input type="hidden" name="ReasonCodeForSplit_#currentRow#" id="ReasonCodeForSplit_#currentRow#" value="">
						<input type="hidden" name="SplitReason_#currentRow#" id="SplitReason_#currentRow#" value="match central split">
						<input type="hidden" name="WriteOffReason_#currentRow#" id="WriteOffReason_#currentRow#" value="">
						<input type="hidden" name="isExactMatch_#currentRow#" id="isExactMatch_#currentRow#" value="1">
						<input type="hidden" name="ClearedAmount_#currentRow#" id="ClearedAmount_#currentRow#" value="#matchAmt#">
						<input type="hidden" name="SplitRecord_#currentRow#" id="SplitRecord_#currentRow#">
						<input type="hidden" name="RebillPakID_#currentRow#"  id="RebillPakID_#currentRow#" value="">
						<input type="hidden" name="Default_Message_#currentRow#"  id="Default_Message_#currentRow#" value="">	
						<input type="hidden" name="RebillClassIDForSplit_#currentRow#"  id="RebillClassIDForSplit_#currentRow#" value="">	
						<input type="hidden" name="RebillRCForSplit_#currentRow#"  id="RebillRCForSplit_#currentRow#" value="">	
					</td>
				</tr>
			</cfif>
		<cfelse>
			<tr>
				<td colspan="4" style="padding:10px;border-bottom:3px solid black;background-color:##EEE;">
					<strong>#workItemCode#</strong>: There are no matches for this item.
				</td>
			</tr>
		</cfif>
	</cfloop>
	<input type="hidden" name="loopCount" id="loopCount" value="#currentRow#">
	<input type="hidden" name="negativeBalanceWhenNoCredit" id="negativeBalanceWhenNoCredit" value="#negativeBalanceWhenNoCredit#">	
	<input type="hidden" name="autoReconcileDollarAmount" id="autoReconcileDollarAmount" value="#autoReconcileDollarAmount#">
	<input type="hidden" name="ErrorBBSplitNotAllowed" id="ErrorBBSplitNotAllowed" value="#ErrorBBSplitNotAllowed#">
</table>
</form>
</cfoutput>