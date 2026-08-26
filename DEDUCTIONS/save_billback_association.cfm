<!------ /deductions/save_billback_association.cfm ----->
<!------ 
Called From	:	/deductions/search_screens/billbacks.cfm
				/billbacks/capture/deductions.cfm
Arguments	:	Billback_ID
				Deduction_ID
----->

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />

<!------*********************************************************************************
D16948: JRS - Deduction record was sent in GL Credit interface file
check if this deduction can be associated to a billback - START
It is possible that someone has already flagged it as write-off, associated to a billback or credit
*********************************************************************************------>
<cfset DeductionLinkManager = CreateObject("component", "components.deduction.DeductionLinkManager").init() />
<cfset bCanAssocToBillback = DeductionLinkManager.isAssocToBillbackAvailable(deductionId = Deduction_ID) />


<cfif bCanAssocToBillback eq 0>


	<BR><BR><BR><BR>
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD>
				<FONT COLOR="Red" SIZE="2">
					<FONT SIZE="3"><B>You cannot associate this deduction to a billback at this point.</B></FONT>
					<br><br>Below are possible reasons
					<ul>
						<li>Deduction is already flagged as write-off</li>
						<li>Deduction is already associated to a billback<CFIF Appsettings.getDDAllowNegativeAmountCredits()>/credit</CFIF></li>
						<li>Deduction is being edited by another user</li>
					</ul>
				</FONT>
			
			</TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function closewindow()
	{
		<cfoutput>
		window.opener.location.href = "/deductions/deduction.cfm?Deduction_ID=#Deduction_ID#";
		</cfoutput>
		window.close();
	}
	window.setTimeout('closewindow()', 3000);	
	</SCRIPT>
	
	<cfabort>

</cfif>
<!------*********************************************************************************
check if this deduction can be associated to a billback - END
*********************************************************************************------>

<cftransaction action="begin">

<CFIF NOT appSettings.getDDCloseWithEqualBBAmt() AND NOT appSettings.getMultiple_BB_Per_Deduction()>	
<!------ 
check the billback amount, 
if it is greater than deduction amount, split the billback and use the first child
TODO: if the billback is already a split child, create one sibling and give the remainign amount to that child
----->
	<!------ Get deduction amount ----->
	<cfquery name="qGetDeductionAmount" datasource="#application.datasource#">
		SELECT 	DD_Amount, DD_DedID, SP_Number
		FROM 	Deductions 
		WHERE 	Deduction_ID = '#Deduction_ID#'
	</cfquery>
	<!------ Get Billback Amount ----->
	<cfquery name="qGetBillbackAmount" datasource="#application.datasource#">
		SELECT 	Paid_Amount 
		FROM 	BB_Approved 
		WHERE 	Billback_ID = '#Billback_ID#'
	</cfquery>
	<cfoutput><cfsavecontent variable="deductionNumber">#qGetDeductionAmount.DD_DedID# <CFIF qGetDeductionAmount.SP_Number NEQ "">- #qGetDeductionAmount.SP_Number#<CFELSE>- 000</CFIF></cfsavecontent></cfoutput>
	
	<cfset BillbackPaidAmount = qGetBillbackAmount.Paid_Amount />
	<cfset DeductionAmount = qGetDeductionAmount.DD_Amount />
	<cfif BillbackPaidAmount GT DeductionAmount>
		<!------ preserver current values ----->
		<cfif isDefined("FORM.BBID")>
			<cfset FORM_BBID = FORM.BBID />
		</cfif>
		
		<!------ do split ----->
		<cfset fromBBDedAssoc = 1 />
		<cfset SelectedBillback_ID = Billback_ID />	
		<cfset FORM.Form_Submitted = 1 />
		<cfset Form_Submitted = 1 />
		<cfset FORM.BBID = Billback_ID />
		<cfset FORM.FromSplit = 1 />
		
		<!------ find if the selected billback is already a split child ----->
		<cfquery name="qGetSplitInfo" datasource="#application.datasource#">
			SELECT	BB_Parent_ID
			FROM 	Billback
			WHERE 	Billback_ID = '#Billback_ID#'
		</cfquery>
		<cfset isThisBBASplit = 0 />
		<cfif qGetSplitInfo.BB_Parent_ID NEQ "">
			<cfset isThisBBASplit = 1 />
			<cfset FORM.BBID = qGetSplitInfo.BB_Parent_ID />
		</cfif>
		
		<cfif isThisBBASplit>
			<!------ If already a split child, instea dof splitting, w ehave create another split sibling ----->
			<cfset Parent = FORM.BBID />
			<CFQUERY NAME="Get_all_Children" DATASOURCE="#Application.Datasource#">
				SELECT 		* 
				FROM 		Billback 
				LEFT JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
				WHERE 		BB_Parent_ID = '#Parent#' AND
							Billback.Deleted = 0
				ORDER BY 	BB_Split_Number
			</CFQUERY>
			<CFQUERY NAME="GetMaxSPNumber" DATASOURCE="#Application.Datasource#">
				SELECT Max(BB_Split_Number) MaxSP FROM Billback WHERE BB_Parent_ID = '#Parent#' AND Deleted = 0
			</CFQUERY>	
			<CFSET LastSPNumber = Replace(GetMaxSPNumber.MaxSP,"0","","All")>	
			<CFSET LastSPNumber = TRIM(LastSPNumber)>
			
			<cfset FORM.Mode = "Edit" />
			<cfset FORM.CurChildren = LastSPNumber />
			<cfset FORM.NoOfChildren = Get_all_Children.RecordCount />
			<cfset FORM.CurLargeSPNumber = LastSPNumber + 1 />
	
			<cfset diffAmountForNewSibling = 0 />
			<CFLOOP QUERY="Get_all_Children">		
				<CFQUERY NAME="CheckLock" DATASOURCE="#Application.Datasource#">
					SELECT * FROM Billback_Allied WHERE Billback_ID='#Billback_ID#' AND BB_Is_Locked = 1 AND BB_Locked_By_User_ID <> '#request.AccessStructure.User_ID#'
				</CFQUERY>
				<CFSET LastDigitSPNumber = Replace(BB_Split_Number,"0","","All")>	
				<CFSET LastDigitSPNumber = TRIM(LastDigitSPNumber)>
				
				<CFSET "FORM.Child_ID_#LastDigitSPNumber#" = BB_Split_Number />
				<CFSET "FORM.Child_UUID_#LastDigitSPNumber#" = Billback_ID />
				<CFSET "FORM.IsDeleted_#LastDigitSPNumber#" = 0 />
				<CFSET "FORM.IsCreated_#LastDigitSPNumber#" = 0 />
				<cfif Billback_ID EQ SelectedBillback_ID>				
					<cfset diffAmountForNewSibling = Paid_Amount - DeductionAmount />
					<CFSET "FORM.Amt_Child_#LastDigitSPNumber#" = DeductionAmount />
				<cfelse>
					<CFSET "FORM.Amt_Child_#LastDigitSPNumber#" = Paid_Amount />
				</cfif>
				<CFSET "FORM.Closing_Method_#LastDigitSPNumber#" = BB_Closing_Method />
				<CFSET "FORM.Split_Reason_#LastDigitSPNumber#" = BB_Split_Reason />
				
			</CFLOOP>
			
			<!------ Add the last new one ----->
				<CFSET LastDigitSPNumber = Replace(GetMaxSPNumber.MaxSP+1,"0","","All")>	
				<CFSET LastDigitSPNumber = TRIM(LastDigitSPNumber)>
				
				<!------ for each bb children 1 ----->
				<cfset "FORM.IsDeleted_#LastDigitSPNumber#" = 0 />
				<cfset "FORM.IsCreated_#LastDigitSPNumber#" = 1 />
				<cfset "FORM.Closing_Method_#LastDigitSPNumber#" = 2 />
				<cfset "FORM.Amt_Child_#LastDigitSPNumber#" = diffAmountForNewSibling />
				<cfset "FORM.Split_Reason_#LastDigitSPNumber#" = "Another version of the billback associated to deduction #deductionNumber# (#DollarFormat(DeductionAmount)#)" />
				
			<!------ Add the last new one ----->
			
		<cfelse>
			<!------ If this is not a split, split into 2 ----->
		
			<!------ set form variables ----->		
			<cfset FORM.CurLargeSPNumber = 2 />		
			
			<!------ for each bb children 1 ----->
			<cfset FORM.IsDeleted_1 = 0 />
			<cfset FORM.IsCreated_1 = 1 />
			<cfset FORM.Closing_Method_1 = 2 />
			<cfset FORM.Amt_Child_1 = DeductionAmount />
			<cfset FORM.Split_Reason_1 = "Associated to deduction #deductionNumber# (#DollarFormat(DeductionAmount)#)" />
			
			<!------ for each bb children 2 ----->
			<cfset FORM.IsDeleted_2 = 0 />
			<cfset FORM.IsCreated_2 = 1 />
			<cfset FORM.Closing_Method_2 = 2 />
			<cfset FORM.Amt_Child_2 = (BillbackPaidAmount - DeductionAmount) />
			<cfset FORM.Split_Reason_2 = "Another version of the billback associated to deduction #deductionNumber# (#DollarFormat(DeductionAmount)#)" />
			
		</cfif>
		
		<cfinclude template="/billbacks/approval/Split_BB.cfm" />
		
		<cfif NOT isThisBBASplit>
			<!------ now get the new child billback id ----->
			<cfquery name="qGteChildBBID" datasource="#application.datasource#">
				SELECT	TOP 1 BB_Code, Billback.Billback_ID
				FROM	Billback
				
				INNER JOIN BB_Approved
				ON	BB_Approved.Billback_ID = Billback.Billback_ID
				AND	BB_Approved.Paid_Amount = #DeductionAmount#
				
				WHERE	Billback.Deleted = 0
				AND		BB_Parent_ID IS NOT NULL
				AND		BB_Parent_ID = '#Billback_ID#'
				Order By BB_Code
			</cfquery>
			<cfset Billback_ID = qGteChildBBID.Billback_ID />
		</cfif>
		
		<!------ get back the preserved values ----->
		<cfif isDefined("FORM_BBID")>
			<cfset FORM.BBID = FORM_BBID />
		</cfif>
	</cfif>
	
	<!---Get Distributor ID from Billback--->
	<cfquery name="GetDistributorIDFromBillback" datasource="#application.datasource#">
		SELECT 	Distributor_ID
		FROM 	Billback_Distributor
		WHERE 	Billback_ID = '#Billback_ID#'
	</cfquery>
	
	<cfif GetDistributorIDFromBillback.Recordcount GT 0>
		<!---Change the Ship To--->
		<cfquery name="ChangeShipTo" datasource="#application.datasource#">
			UPDATE 	Deductions
			Set 	Distributor_ID = '#GetDistributorIDFromBillback.Distributor_ID#'
			WHERE 	Deduction_ID = '#Deduction_ID#'
		</cfquery>
	
	</cfif>
</CFIF>

<!------ deallocate any previous associations ----->
<cfset useLakebaseForCheckPreviousAssoci = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForCheckPreviousAssoci>
	<cftry>
		<cfset CheckPreviousAssoci = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#Deduction_ID#",
				"dd_closure_type" = "eq.1",
				"dd_closure_id" = "not.is.null"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckPreviousAssoci = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckPreviousAssoci>
<CFQUERY NAME="CheckPreviousAssoci" DATASOURCE="#Application.Datasource#">
	SELECT 	* 
	FROM 	Deductions 
	WHERE 	Deduction_ID = '#Deduction_ID#' 
	AND		DD_Closure_Type = 1 
	AND		DD_Closure_ID IS NOT NULL
</CFQUERY>
</cfif>
<CFIF CheckPreviousAssoci.RecordCount GT 0>	
	<CFQUERY NAME="UpdateBBBit" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback 
		SET 	BB_Associated_To_DD = 0
		WHERE 	Billback_ID IN 
				(	SELECT 	DD_Closure_ID 
					FROM 	DD_Closure_Detail 
					WHERE 	Deduction_ID = '#Deduction_ID#' AND 
							Interfaced_On IS NULL AND 
							Ack_Received IS NULL AND 
							Deleted = 0
				)
	</CFQUERY>	
	<CFQUERY NAME="DeletedPreAsso" DATASOURCE="#Application.Datasource#">
		UPDATE 	DD_Closure_Detail 
		SET 	Deleted = 1 
		WHERE 	Deduction_ID = '#Deduction_ID#' AND 
				Interfaced_On IS NULL AND 
				Ack_Received IS NULL AND 
				Deleted = 0
	</CFQUERY>
</CFIF>

<cfif Billback_ID EQ "">
	<cfif (isDefined("FORM.SelectedReasons") and FORM.SelectedReasons NEQ "")>
		<cfset Billback_ID = Replace(FORM.SelectedReasons,'_','-','ALL') />
	</cfif>
</cfif>
<CFQUERY NAME="ValidateBB" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback WHERE Billback_ID IN (#LISTQUALIFY(Billback_ID,"'",",","All")#) AND (BB_Associated_To_DD = 1 OR Billback_Status_ID <> 3 OR Deleted = 1)
</CFQUERY>
<CFIF ValidateBB.RecordCount GT 0>
	<BR><BR><BR><BR>
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">
			Billback is not in "approved" status. Can't associate this billback to the deduction.
			</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function closewindow()
	{
		window.close()
	}
	window.setTimeout('closewindow()', 3000);		
	</SCRIPT>
	<CFABORT>	
<CFELSE>
	<CFSET LoopCount = 0>
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Allocate the dollar amount to the allowance code if the corresponding app switch is on.
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<!--- 9093,9892 --->
	<CFIF appSettings.getOperatingGroupOn()>	
	<cfset BillbackAllowanceCodeManager = CreateObject("component", "components.Billback.BillbackAllowanceCodeManager").init() /> 	
	<CFLOOP LIST="#Billback_ID#" INDEX="BBIDItem">
	
		<CFQUERY NAME="DeletePre" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation SET Deleted = 1 WHERE Billback_ID = <cfqueryparam value="#BBIDItem#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<CFQUERY NAME="DelPre" DATASOURCE="#Application.Datasource#">
			UPDATE BB_AllowanceCode_Allocation_Summary SET Deleted = 1 WHERE Billback_ID = <cfqueryparam value="#BBIDItem#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	
		<CFQUERY NAME="CheckIfChild" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Billback 
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = BB_Approved.Billback_ID	
			WHERE Billback.Billback_ID = <cfqueryparam value="#BBIDItem#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
		<!--- Do the allocation for the parent first if it is not available --->
		<CFIF CheckIfChild.BB_Is_Child EQ 1>
			<CFQUERY NAME="GetParentInfo" DATASOURCE="#Application.Datasource#">
				SELECT Paid_Amount FROM BB_Approved 
				WHERE Billback_ID = <cfqueryparam value="#CheckIfChild.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>
			<CFQUERY NAME="CheckForParentRecords" DATASOURCE="#Application.Datasource#">
				SELECT 		SUM(CAST(Allocated_Amount AS Decimal(18,2))) Allocated_Amount,CAST(BB_Approved.Paid_Amount AS Decimal(18,2)) Paid_Amount FROM BB_AllowanceCode_Allocation_Summary 
				INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = BB_AllowanceCode_Allocation_Summary.Billback_ID
				WHERE 		BB_AllowanceCode_Allocation_Summary.Billback_ID = '#CheckIfChild.BB_Parent_ID#'  AND 
							AllowanceCode_level_Sum = 1 AND Deleted = 0
				GROUP BY 	BB_AllowanceCode_Allocation_Summary.Billback_ID,BB_Approved.Paid_Amount
			</CFQUERY>
			<CFIF CheckForParentRecords.RecordCount EQ 0 OR CheckForParentRecords.Allocated_Amount NEQ CheckForParentRecords.Paid_Amount>
				<CFQUERY NAME="DeletePre" DATASOURCE="#Application.Datasource#">
					UPDATE BB_AllowanceCode_Allocation SET Deleted = 1 WHERE Billback_ID = <cfqueryparam value="#CheckIfChild.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				<CFQUERY NAME="DelPre" DATASOURCE="#Application.Datasource#">
					UPDATE BB_AllowanceCode_Allocation_Summary SET Deleted = 1 WHERE Billback_ID = <cfqueryparam value="#CheckIfChild.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
				</CFQUERY>
				<CFSET BillbackAllowanceCodeManager.AllowanceCodeAllocation(CheckIfChild.BB_Parent_ID) />
			</CFIF>	
			<CFQUERY NAME="InsBAAS" DATASOURCE="#Application.Datasource#">
				INSERT INTO BB_AllowanceCode_Allocation_Summary (Billback_ID,
				Allowance_Code_ID,AllowanceCode_level_Sum,
				Allocated_Amount)
				SELECT '#BBIDItem#',
				Allowance_Code_ID,AllowanceCode_level_Sum,
				(Allocated_Amount * #CheckIfChild.Paid_Amount#)/#GetParentInfo.Paid_Amount#
				FROM BB_AllowanceCode_Allocation_Summary BAAS
				WHERE BAAS.Billback_ID = <cfqueryparam value="#CheckIfChild.BB_Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND AllowanceCode_level_Sum = 1 AND Deleted = 0
			</CFQUERY>				
			
			<CFQUERY NAME="AllocatedAmt_Rounding" DATASOURCE="#Application.Datasource#">
				UPDATE BB_AllowanceCode_Allocation_Summary
				SET Allocated_Amount = (
				Allocated_Amount + (CAST(Paid_Amount AS Decimal(18,2)) - 
				(
				SELECT SUM(Allocated_Amount)
				FROM BB_AllowanceCode_Allocation_Summary BAAS1
				WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND AllowanceCode_level_Sum = 1 AND Deleted = 0
				)))
				FROM BB_AllowanceCode_Allocation_Summary BAAS
				INNER JOIN BB_Approved ON BB_Approved.Billback_ID = BAAS.Billback_ID
				WHERE BAAS.Billback_ID = <cfqueryparam value="#BBIDItem#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND Deleted = 0 AND
				BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1(BB_AllowanceCode_Allocation_Summary_ID)
				FROM BB_AllowanceCode_Allocation_Summary BAAS2 WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = 1 AND 
				BAAS2.Deleted = 0 AND Allocated_Amount = (SELECT MAX(Allocated_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
				WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = 1 AND 
				BAAS3.Deleted = 0)
				)
			</CFQUERY>
			<!---
			<cfif appSettings.getBillbacksSalesTax()>
				<CFSET BillbackAllowanceCodeManager.AllocateTaxAmount(BBIDItem) />
			</cfif>
			--->
		<CFELSE>
			<CFSET BillbackAllowanceCodeManager.AllowanceCodeAllocation(BBIDItem) />	
		</CFIF>
		
		<CFQUERY NAME="ValidateAllocation" DATASOURCE="#Application.Datasource#">
			SELECT 		SUM(CAST(Allocated_Amount AS Decimal(18,2))) Allocated_Amount,CAST(BB_Approved.Paid_Amount AS Decimal(18,2)) Paid_Amount FROM BB_AllowanceCode_Allocation_Summary 
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = BB_AllowanceCode_Allocation_Summary.Billback_ID
			WHERE 		BB_AllowanceCode_Allocation_Summary.Billback_ID = '#BBIDItem#'  AND 
						AllowanceCode_level_Sum = 1 AND Deleted = 0
			GROUP BY 	BB_AllowanceCode_Allocation_Summary.Billback_ID,BB_Approved.Paid_Amount
		</CFQUERY>
		<CFIF ValidateAllocation.RecordCount EQ 0 OR ValidateAllocation.Allocated_Amount NEQ ValidateAllocation.Paid_Amount>			
			<BR><BR><BR><BR>
		
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
				<TR>
					<TD><B><FONT COLOR="Red" SIZE="3">All or part of the Billback dollars of <CFOUTPUT>#CheckIfChild.BB_Code#</CFOUTPUT> could not be allocated properly to an allowance code, this billback association will be cancelled.</FONT></B></TD>
				</TR>
			</TABLE>
			<CFABORT>
		</CFIF>
	</CFLOOP>	
	<CFSET LoopCount = 0>
	</CFIF>
	<!--- 9093,9892 --->
	
	<!------ 
	D16948: JRS - Deduction record was sent in GL Credit interface file
	If the deduction is already flagged as write-off, re-set it
	We already have a check at the top of the page to check if someone has already flagged it as write-off, associated to a billback or deduction
	But it is possible for the current deduction to be flagged as write-of meanwhile if this page takes a long time to execute 
	We don't want a deduction flagged as both write-off and associated to a billback
	So it is safer to re-set if ever the deduction was flagged as write-off by now.		   
	----->
	<CFQUERY NAME="ResetWriteOff" DATASOURCE="#Application.Datasource#">
		UPDATE 	Deductions
		SET 	Is_Write_Off = 0,
				Write_Off_By = NULL,
				Write_Off_Date = NULL,
				Write_Off_ToOpen_Reason = 'Deduction is getting associated to billback'	
		WHERE 	Deduction_ID = '#Deduction_ID#'
		AND		Is_Write_Off = 1 
	</CFQUERY>
	
	
	<!--- moved to component 
	<CFLOOP LIST="#Billback_ID#" INDEX="BBIDItem">
		<CFSET LoopCount = LoopCount + 1>
		<!---Insert into reason code and  relocate to closure--->
		<CFIF LoopCount EQ 1>
			<cfset useLakebaseForAddReason = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForAddReason>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#Deduction_ID#"
			},
			{
				"dd_closure_id" = "#BBIDItem#",
				"dd_closure_type" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAddReason = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAddReason>
<cfquery name="AddReason" datasource="#application.datasource#">
				UPDATE 	Deductions
				Set 	DD_Closure_ID = '#BBIDItem#',
						DD_Closure_Type = 1
				WHERE 	Deduction_ID = '#Deduction_ID#'
			</cfquery>
</cfif>
		</CFIF>
		<CFQUERY NAME="InsData" DATASOURCE="#Application.Datasource#">
			INSERT INTO DD_Closure_Detail (Deduction_ID,DD_Closure_ID) VALUES ('#Deduction_ID#','#BBIDItem#')
		</CFQUERY>
		<CFQUERY NAME="UpdateBBBit" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback 
			SET 	BB_Associated_To_DD = 1,
					BB_Closing_Method = 2
			WHERE 	Billback_ID = '#BBIDItem#'
		</CFQUERY>
	</CFLOOP>
	 --->
	<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager").init() />
	<cfset DeductionManager.setAssociatedBB(Deduction_ID,Billback_ID)>
	
</CFIF>

<cftransaction action="commit" />

</cftransaction>

<!--- Commentted one to one deduction - billback logic 
<!------ deallocate any previous associations ----->
<CFQUERY NAME="CheckPreviousAssoci" DATASOURCE="#Application.Datasource#">
	SELECT 	* 
	FROM 	Deductions 
	WHERE 	Deduction_ID = '#Deduction_ID#' 
	AND		DD_Closure_Type = 1 
	AND		DD_Closure_ID IS NOT NULL
</CFQUERY>
<CFIF CheckPreviousAssoci.RecordCount GT 0>	
	<CFQUERY NAME="UpdateBBBit" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback 
		SET 	BB_Associated_To_DD = 0
		WHERE 	Billback_ID = '#CheckPreviousAssoci.DD_Closure_ID#'
	</CFQUERY>	
</CFIF>

<!--- Deduction and BB one to one logic --->
<CFQUERY NAME="UnAssociateBBWithOtherDD" DATASOURCE="#Application.Datasource#">
	UPDATE 	Deductions
	SET 	DD_Closure_ID = NULL,
			DD_Closure_Type = NULL
	WHERE 	DD_Closure_ID = '#Billback_ID#' AND DD_Closure_Type = 1
</CFQUERY>

<cfset useLakebaseForCheckStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForCheckStatus>
	<cftry>
		<cfset CheckStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#Billback_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckStatus>
<CFQUERY NAME="CheckStatus" DATASOURCE="#Application.Datasource#">
	SELECT * FROM Billback WHERE Billback_ID = '#Billback_ID#'
</CFQUERY>
</cfif>
<CFIF CheckStatus.Billback_Status_ID EQ 3>
	<!---Insert into reason code and  relocate to closure--->
	<cfquery name="AddReason" datasource="#application.datasource#">
		UPDATE 	Deductions
		Set 	DD_Closure_ID = '#Billback_ID#',
				DD_Closure_Type = 1
		WHERE 	Deduction_ID = '#Deduction_ID#'
	</cfquery>
	<CFQUERY NAME="UpdateBBBit" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback 
		SET 	BB_Associated_To_DD = 1,
				BB_Closing_Method = 2
		WHERE 	Billback_ID = '#Billback_ID#'
	</CFQUERY>
<CFELSE>
	<BR><BR><BR><BR>
	
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="3">
			Billback is not in "approved" status. Can't associate this billback to the deduction.
			</FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function closewindow()
	{
		window.close()
	}
	window.setTimeout('closewindow()', 3000);		
	</SCRIPT>
	<CFABORT>	
</CFIF> 
--->