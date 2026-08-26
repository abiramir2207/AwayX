ï»¿<!---
Name: 			BillbackSettlementDAO.cfc
Copyright:		(c) 2011 Blacksmith Applications, Inc.
Created Date:  	06.27.2011
Created By:    	Mark Saunders
Description:	Manager for Handling BB settlement DAO requests for
				Flex BB workflow tool
Parameters:		N/A
Usage:			N/A
--->

<cfcomponent  name="BillbackSettlementDAO" displayname="BillbackSettlementDAO" alias="mvc.Models.Billback.BillbackSettlementDAO" extends="mvc.Models.SettingsService">
	
	<cffunction name="init" access="public" output="false">
		<cfreturn this >
	</cffunction>
	
	<cfscript>
 		variables.oBillbackDAO = CreateObject("component","mvc.Models.Billback.BillbackDAO");
		variables.billbackSettingsManager = CreateObject("component", "components.billback.BillbackSettingsManager");  
		appSettings = application.appSettingsGet;
 	</cfscript>
	
	<cffunction name="lockDeduction" output="false" access="public">
		<cfargument name="ddId" type="string" required="true">
		<cfargument name="userId" type="string" required="true">
		
			<cfquery name="lockBillback" datasource="#application.datasource#">
				UPDATE Deductions
				SET Is_Locked = 1
					,Locked_By = <cfqueryparam value="#arguments.userId#" cfsqltype="cf_sql_varchar">
					,DD_Locked_By_Match_Central = 1,
					Deduction_Lock_Date= getDate()
				WHERE Deduction_ID = <cfqueryparam value="#arguments.ddid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			
			<cfreturn true/>
	
	</cffunction>
	
	<cffunction name="unLockDeduction" output="false" access="public">
		<cfargument name="ddId" type="string" required="true">
		
			<cfquery name="unLockBillback" datasource="#application.datasource#">
				UPDATE Deductions
				SET Is_Locked = 0
					,DD_Locked_By_Match_Central = 0
					,Locked_By = NULL
				WHERE Deduction_ID = <cfqueryparam value="#arguments.ddid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			
		<cfreturn true/>

	</cffunction>
	
	<cffunction name="GetDDClassification" output="false" access="public">
		<cfset useLakebaseForgetClassification = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
<cfif useLakebaseForgetClassification>
	<cftry>
		<cfset getClassification = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_classification", {
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "dd_classification_id"
			}), "dd_classification_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetClassification = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetClassification>
<cfquery name="getClassification" datasource="#application.datasource#">
			SELECT TOP 1 DD_Classification_ID FROM DD_Classification WHERE Deleted = 0
		</cfquery>
</cfif>
	<cfreturn getClassification />

	</cffunction>
	
	<cffunction name="UpdateBillbacks" output="false" access="public">
		<cfargument name="BB_Closing_method" type="numeric" />
		<cfargument name="Billback_ID" type="string" />
		<cfargument name="BB_Status_ID" type="numeric" />
		
		<cfquery name="qryUpdateBillbacks" datasource="#application.datasource#">
			UPDATE 
				Billback
			SET 
				Billback_Status_ID = #arguments.BB_Status_ID#,
				BB_Closing_Method = #arguments.BB_Closing_Method#
				<!--- set the below fields only if closing method is either Payment or Payment EFT --->
				<cfif (arguments.BB_Closing_Method EQ 1 Or arguments.BB_Closing_Method EQ 8)>
					, 
					BB_Payment_Request_Approved = 1,
					BB_Payment_Request_Approved_By = '#request.AccessStructure.User_ID#',
					BB_Payment_Request_Approved_Date = #now()#,
					BB_Payment_Request_Prepared 	 = 1,
					BB_Payment_Request_Prepared_By 	 =  '#request.AccessStructure.User_ID#',
					BB_Payment_Request_Prepared_Date = #now()#
				</cfif> 
			WHERE 
				Billback_ID = '#arguments.Billback_ID#'
		</cfquery>
		
		<!--- Tim Ford - 07/21/2014: Label 43983 - Billbacks not being set to Payment Request with Payment Closing Method on Approval.
			Adding code to handle for Billbacks with a closing method of Payment and a Status of Approved. 
			Set the Billback Status to 4 if:
				Closing Method = Payment
				Billback Status = Approved
				Billback is not split
		--->
		<cfquery name="qUpdateBillbackStatus" datasource="#application.datasource#">
			UPDATE	b
			SET		b.Billback_Status_ID = 4
			FROM	Billback b
					left join Billback b2 on b2.BB_Parent_ID = b.Billback_ID and b2.Deleted = 0
			WHERE	b.Billback_ID = '#arguments.Billback_ID#'
			AND		b.Deleted = 0
			AND		b.Billback_Status_ID = 3
			AND		b.BB_Closing_Method in (1,8)
			AND		b.BB_Is_Child = 0
			AND		b.BB_Parent_ID IS NULL
			AND		b2.Billback_ID IS NULL
		</cfquery>
		
	</cffunction>
	
		
		
   <cffunction name="getApprovalAmount" returntype="struct" access="public" hint="get expected amount for approval">
		<cfargument name="bbHeader" type="struct">
		<cfscript>
			//set local variables
			var Billback_ID		= 	variables.oBillbackDAO.getBillbackUUID(arguments.bbHeader.billbackIDInt);
			var qGetApprovalAmount = queryNew('Final_Selected_Amount,Expected_Amt');
			var qGetApprovalAmountTake2 = queryNew('Approved_Amount,Paid_Amount');
			var _bbHeader = arguments.bbHeader;
			var final_amount = 0;
		</cfscript>

		<cfif len(Billback_ID) GT 30>
			<cfquery name="qGetApprovalAmount" datasource="#application.datasource#">
				
				SELECT SUM(CAST(Final_Payment As decimal(18,2))) AS Final_Selected_Amount,
			       SUM(	CASE 
						WHEN UOM = 1 THEN
							CAST(Allocated_Expected_CS * Expected_Rate_CS As decimal(18,2))
						ELSE
							CAST(Allocated_Expected_LB * Expected_Rate_LB  As decimal(18,2))
					END
			    	)   AS Expected_Amt
			     FROM BB_Item_Invoice_Level WHERE Billback_ID = '#Billback_ID#'
			</cfquery>
			<cfset final_amount = qGetApprovalAmount.Final_Selected_Amount />
			
		<cfif isNull(qGetApprovalAmount.Final_Selected_Amount) || qGetApprovalAmount.Final_Selected_Amount EQ ''>
				<cfquery name="qGetApprovalAmountTake2" datasource="#application.datasource#">
					SELECT 
						Approved_Amount,
						Paid_Amount
					FROM BB_approved BA
					WHERE BA.Billback_ID = '#Billback_ID#'
				</cfquery>
				<cfset final_amount = qGetApprovalAmountTake2.Approved_Amount />
			</cfif>
			
			<cfscript>
				_bbHeader["finalSelectedAmount"] = final_amount;
				_bbHeader["expectedAmt"] = qGetApprovalAmount.Expected_Amt;
			</cfscript>
		</cfif>
		
		<cfreturn _bbHeader />
	</cffunction>
	
	<cffunction name="getSingleClosingMethod" output="false" access="public" returntype="query">
		<cfargument name="closingMethodID" type="numeric" />
		<cfquery name="qGetSingleClosingMethod" datasource="#application.datasource#">
			SELECT 
				BCM.iBillback_Closing_Method_ID,
				BCM.vchBillback_Closing_Method_Desc,
				BCM.bEnabled,
				BCM.tiAutoPay_BB_Status,
				BCM.Deleted,
				BCM.Abbreviation,
				BCM.Payee_Type,
				BCM.bDefault,
				BCM.Updated_On,
				BCM.Updated_By,
				BCM.Auto_Dev_BB_Status_Below,
				BCM.Auto_Dev_BB_Status_Exceed
			FROM
				Billback_Closing_Methods BCM
				<cfif isDefined("Request.AccessStructure.profiles_id")>
					INNER JOIN 
			   			BB_Profile_Closing_Methods AS BPCM
	           		ON BCM.iBillback_Closing_Method_ID = BPCM.Billback_Closing_Method_ID
	           		AND BPCM.Profile_ID = #Request.AccessStructure.profiles_id#
			   		AND BPCM.Deleted = 0
		   		</cfif>				
			WHERE 	BCM.iBillback_Closing_Method_ID = #arguments.closingMethodID#		
		</cfquery>
	<cfreturn qGetSingleClosingMethod />

	</cffunction>
	

	<cffunction name="insUpdBBApproved" output="false" returntype="void">
		<cfargument name="Billback_ID" type="string" />
		<cfargument name="frmDD_Reason_Code_ID" type="numeric" />
		<cfargument name="totalClosed" type="numeric" />
		<cfargument name="BBAmount" type="numeric" />
		<cfargument name="paymentNotes" type="string" />
		<cfargument name="bSpecialHandling" type="string" />
		<cfargument name="Reason_Code" type="string" />
		<cfargument name="expectedAmount" type="numeric" />

		<cfset Billback_ID 		= arguments.Billback_ID />
		<cfset DDReasonCodeID 	= arguments.frmDD_Reason_Code_ID />
		<cfset totalClosed		= arguments.totalClosed />
		<cfset BBAmount			= arguments.BBAmount />
		<cfset paymentNotes	 	= arguments.paymentNotes />
		<cfset bSpecialHandling	= arguments.bSpecialHandling />
	    <cfset Reason_Code		= arguments.Reason_Code />
		<cfset nExpectedAmount	= arguments.expectedAmount />
		

		<cfquery name="UpdateOrInsert" datasource="#application.datasource#">
			SELECT BB_Approved_ID 
			FROM BB_Approved
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		 
		<cfif UpdateOrInsert.Recordcount IS 0>
			<cfquery name="insBBApproved" datasource="#application.datasource#">
			INSERT INTO BB_Approved
				(
				Billback_ID,
				Paid_Amount,
				BB_Amount_Before_Exclusions,
				Total_Adjustment_Applied,
				Total_Exclusion_Applied,
				Approved_Amount,
				BB_Amount,
				Expected_Amount,
				Authorized_Amount, 
				Date_Approved,
				User_Approved,
				/* 
				Payment_Notes,
				Special_Handling,  */
				<!--- 	<CFIF FORM.Approved_Amount_Type NEQ 1>
				Claim_Adjust_Tot,
				</CFIF>
				<CFIF InTwoClaimColValue EQ 1>	
				Updated_Paid_Amount_For_Claim_Adjust,
				</CFIF> --->
				<cfif DDReasonCodeID NEQ 0>BB_Reason_Code_ID,</cfif>
				Adjustment_Created
				<!--- Approved_Amt_Type, --->
				)
				VALUES
				(
				<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#totalClosed#" cfsqltype="CF_SQL_FLOAT">,
				<cfqueryparam value="#BBAmount#" cfsqltype="CF_SQL_FLOAT">,
				<cfqueryparam value="0" cfsqltype="CF_SQL_FLOAT">,<!--- D30588  View Program Payments CHANGED TO ZERO--->
				<cfqueryparam value="0" cfsqltype="CF_SQL_FLOAT">,<!--- D30588  View Program Payments CHANGED TO ZERO--->
				<cfqueryparam value="#totalClosed#" cfsqltype="CF_SQL_FLOAT">,
				<cfqueryparam value="#BBAmount#" cfsqltype="CF_SQL_FLOAT">,
				<cfqueryparam value="#nExpectedAmount#" cfsqltype="CF_SQL_FLOAT">,
				<cfqueryparam value="#totalClosed#" cfsqltype="CF_SQL_FLOAT">,
				GetDate(),
				<cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
				<!--- ,
				<cfqueryparam value="#paymentNotes#" cfsqltype="CF_SQL_VARCHAR">,
				<cfqueryparam value="#bSpecialHandling#" cfsqltype="cf_sql_bit" >, --->
				<!--- 		
				<CFIF FORM.Approved_Amount_Type NEQ 1>
					<cfqueryparam value="#GetTotClaim.ClaimAd_Tot#" cfsqltype="CF_SQL_FLOAT">,
				</CFIF>
		 		<CFIF InTwoClaimColValue EQ 1>
					1,
				</CFIF> --->
				<cfif DDReasonCodeID NEQ 0><cfqueryparam value="#Reason_Code#" cfsqltype="CF_SQL_INTEGER">,</cfif>
				<cfqueryparam value="#totalClosed#" cfsqltype="CF_SQL_FLOAT">
				<!--- <cfqueryparam value="#FORM.Approved_Amount_Type#" cfsqltype="CF_SQL_INTEGER">, --->
				)
			</cfquery>
		<cfelse>
		 		<cfquery name="updBBApproved" datasource="#application.datasource#">
				UPDATE BB_Approved
				SET Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
					Paid_Amount = <cfqueryparam value="#totalClosed#" cfsqltype="CF_SQL_FLOAT">,
					BB_Amount_Before_Exclusions = <cfqueryparam value="#BBAmount#" cfsqltype="CF_SQL_FLOAT">,
					Approved_Amount = <cfqueryparam value="#totalClosed#" cfsqltype="CF_SQL_FLOAT">,
					BB_Amount = <cfqueryparam value="#BBAmount#" cfsqltype="CF_SQL_FLOAT">,
					Expected_Amount = <cfqueryparam value="#BBAmount#" cfsqltype="CF_SQL_FLOAT">,
					Authorized_Amount = <cfqueryparam value="#totalClosed#" cfsqltype="CF_SQL_FLOAT">,
					Date_Approved = GetDate(),
					User_Approved = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">, 
					<cfif DDReasonCodeID NEQ 0>BB_Reason_Code_ID = <cfqueryparam value="#Reason_Code#" cfsqltype="CF_SQL_INTEGER">,</cfif>
					Adjustment_Created = <cfqueryparam value="#totalClosed#" cfsqltype="CF_SQL_FLOAT">
					<!--- ,
					Payment_Notes = <cfqueryparam value="#paymentNotes#" cfsqltype="CF_SQL_VARCHAR">,
					Special_Handling = <cfqueryparam value="#bSpecialHandling#" cfsqltype="cf_sql_bit" > --->
			 	WHERE BB_Approved_ID = <cfqueryparam value="#UpdateOrInsert.BB_Approved_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery> 
				<!---Update instead of insert--->
			</cfif>	
	
			<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
				Step 13. Save gl account # for component
			xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
 			<cfstoredproc procedure="BB_Save_GL_Account" datasource="#application.datasource#">
				<cfprocparam cfsqltype="CF_SQL_VARCHAR" dbvarname="@@BILL_ID" value="#Billback_ID#" />
			</cfstoredproc>

		<cfreturn />
	</cffunction>
	

	<!---- 
		This function will get the Deduction_ID and Billback_ID and Unassociate the Billback and the DeductionID
	--->
	<cffunction name="checkTemplateApprovalRights" returntype="query" access="public">
		<cfargument name="billbackId" default="12345678-1234-1234-1234-123456789012">
		<cfargument name="profilesId" default="0" >
		<cfargument name="ForbidAllowProfilesInTemplates" default="0" >
		<cfscript>
			var qCheckTemplateApprovalRights = QueryNew('temp');
		</cfscript>
	
		<cfquery NAME="qCheckTemplateApprovalRights" DATASOURCE="#Application.Datasource#">
			SELECT 		* 
			FROM 		Billback
			INNER JOIN 	Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID AND Billback_Program.Deleted = 0
			INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID 
			INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
			INNER JOIN 	Profile_Forbidden_Template ON Profile_Forbidden_Template.template_id = Program_Latest_Template_ID.Latest 
						AND Profile_Forbidden_Template.Profile_ID = <cfqueryparam value="#arguments.profilesId# " cfsqltype="CF_SQL_INTEGER">
						AND Profile_Forbidden_Template.Deleted = 0	
						AND Forbid_Type = <cfqueryparam value="#arguments.ForbidAllowProfilesInTemplates# " cfsqltype="CF_SQL_INTEGER">
						AND Forbid_Access_Type = 4
			WHERE Billback.Billback_ID = <cfqueryparam value="#arguments.billbackId#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfreturn qCheckTemplateApprovalRights/>
	</cffunction>
	
		
 	<cffunction name="fnUnAssociateDeductionOnDDIDDAO" returntype="any" access="remote" hint="">
		<cfargument name="Deduction_ID" type="string"> 
		<cfargument name="Billback_ID" type="string"> 
		<!--- <cfset ClosingMethodObj = getBillbackSettlement(argBillbackIDInt = arguments.bbHeader.billbackIDInt) /> --->
		
		<!--- check to see if there are any splits for the given Deduction_ID --->
		<cfquery name="checkDDHasSplits" datasource="#Application.Datasource#"> 
			SELECT Deduction_ID,DD_IsParent,DD_IsChild,Split_Count,Split_By_Billback_ID FROM Deductions where Deduction_ID = '#arguments.Deduction_ID#' AND Deleted = 0 AND (DD_Status IN (1,2,3,4,9))
		</cfquery>
		<!--- 
			Steps to happen when UnAssociating a Deduction from a Billback are:
			
			a) Select the Splits for the Parent Deduction and only those that are associated to the given Billback_ID (For now select all those that have deleted = 0), if any
				1) Check to see if all the splits are associated only to this bilback, if so 
				+ Delete the splits
				+ Change the splitCount and other fields in the parent Deduction
			b) if there are no splits then change the status of the parent alonel.
		--->	
		
		<!--- If it is the only DD associated and not splits then just change the statuses and leave it alone --->

		<cfif (checkDDHasSplits.RecordCount GTE 1)>
			<!--- Scenario 1: basic scenario with just 1 DD associated and no splits --->
			<cfif (checkDDHasSplits.DD_ISParent EQ 1 AND checkDDHasSplits.DD_IsChild EQ 0 AND checkDDHasSplits.Split_Count EQ 0)>
				<!--- Just unattach the deduction --->

				<cfset this.fnUnAssociateDeductionDAO(Deduction_ID = arguments.Deduction_ID, Billback_ID = arguments.Billback_ID) />
			<cfelseif (checkDDHasSplits.DD_ISParent EQ 1 AND checkDDHasSplits.DD_IsChild EQ 0 AND checkDDHasSplits.Split_Count GTE 1)>
				<!--- if there are splits for the given deduction --->
				<cfquery name="qryGetDDSplits" datasource="#Application.Datasource#"> 
					SELECT Deduction_ID,DD_IsParent,DD_IsChild,Split_Count,Is_Write_Off,is_Credit FROM Deductions where DD_Parent_ID = '#qryOnDDSplitBy.DD_Parent_ID#' AND Deleted = 0 AND (DD_Status IN (1,2,3,4,9))
				</cfquery>
				<!--- <cfif (checkDDHasSplits.Split_Count EQ qryGetDDSplits.RecordCount)> --->
					<cfloop query="qryGetDDSplits">
							<!--- This will only delete the Children and not the Parent Deduction --->
						<cfquery name="delDDsplits" datasource="#Application.Datasource#"> 
							UPDATE Deductions 
							SET Deleted = 1
							WHERE Deduction_ID =  '#qryGetDDSplits.Deduction_ID#' AND Deleted = 0 AND (DD_Status IN (1,2,3,4,9))
						</cfquery>	
							<!--- After updating the Deduction --->
			 			<cfset  this.fnUnAssociateDeductionDAO(Deduction_ID = qryGetDDSplits.Deduction_ID, Billback_ID = arguments.Billback_ID) />
					</cfloop>
					<cfset splitCount = checkDDHasSplits.Split_Count - qryGetDDSplits.RecordCount />
						<!--- After deleting the splits update the split_count of the parent Billback to 0 --->
					<cfquery name="delDDsplits" datasource="#Application.Datasource#"> 
						UPDATE Deductions 
						SET Split_Count = #splitCount#
						WHERE Deduction_ID =  '#checkDDHasSplits.Deduction_ID#' AND Deleted = 0 AND (DD_Status IN (1,2,3,4,9))
					</cfquery>	
				<!--- <cfelse>  --->
					<!--- if the split_count and recordCount are not equal, this means there are other billbacks that is associated with the deduction --->
					<!--- <cfset fnUnAssociateDeductionOnBBIDDAO(Deduction_ID=arguments.Deduction_ID ,Billback_ID = arguments.Billback_ID) /> --->
				<!--- </cfif>  ---><!--- <cfif (checkDDHasSplits.Split_Count EQ qryGetDDSplits.RecordCount)> --->
			<cfelseif (checkDDHasSplits.DD_ISParent EQ 0 AND checkDDHasSplits.DD_IsChild EQ 1 AND checkDDHasSplits.Split_Count EQ 0)>	
				<cfset fnUnAssociateDeductionOnBBIDDAO(Deduction_ID=arguments.Deduction_ID ,Billback_ID = arguments.Billback_ID) />
				<!--- incase the deduction is not a parent OR it is a child --->	
			</cfif> <!--- ENDS : <cfif checkDDHasSplits.DD_ISParent EQ 1 AND checkDDHasSplits.DD_IsChild = 0 AND checkDDHasSplits.Split_Count EQ 0> --->
		<cfelse>
			<cfset fnUnAssociateDeductionOnBBIDDAO(Deduction_ID=arguments.Deduction_ID ,Billback_ID = arguments.Billback_ID) />	
		</cfif> <!---- ENDS: <cfif checkDDHasSplits.RecordCount GTE 1> --->

	<cfreturn />
		
	</cffunction>  
		
		
			<!--- Scenario 2: In case there are no records for the given deduction check to see if there are any that have been split by the given Billback_ID --->
			
	<cffunction name="fnUnAssociateDeductionOnBBIDDAO" returntype="any" access="remote" hint="">			
		<cfargument name="Deduction_ID" type="string"> 
		<cfargument name="Billback_ID" type="string"> 
			<cfquery name="qryOnDDSplitBy" datasource="#Application.Datasource#"> 
				SELECT Deduction_ID,DD_IsParent,DD_IsChild,Split_Count,Is_Write_Off,is_Credit,DD_Parent_ID 
				FROM Deductions 
				WHERE Split_By_Billback_ID = '#arguments.Billback_ID#' AND 
					Deleted = 0 AND 
					(DD_Status IN (1,2,3,4,9))
			</cfquery>
			<cfif qryOnDDSplitBy.RecordCount GTE 1>
					<!--- Loop through each record and get the parent so that we could check the splitCount and then delete the split child  --->				
				<cfquery name="getDDParent" datasource="#Application.Datasource#"> 
					SELECT Deduction_ID,DD_IsParent,DD_IsChild,Split_Count,Is_Write_Off,is_Credit 
					FROM Deductions 
					WHERE Deduction_ID = '#qryOnDDSplitBy.DD_Parent_ID#' AND 
						Deleted = 0 AND 
						(DD_Status IN (1,2,3,4,9))
				</cfquery>
					<!--- 
						if the split_count on the parent record and the recordCount on the qryOnDDSplitBy are equal
						then we can get rid of the splits and have only the parent deductions
					--->
					<cfloop query="qryOnDDSplitBy">
							<!--- This will only delete the Children and not the Parent Deduction --->
						<cfquery name="delDDsplits" datasource="#Application.Datasource#"> 
							UPDATE Deductions 
							SET Deleted = 1
							WHERE Deduction_ID =  '#qryOnDDSplitBy.Deduction_ID#' AND Deleted = 0 AND (DD_Status IN (1,2,3,4,9))
						</cfquery>	
							<!--- After updating the Deduction --->
			 			<cfset this.fnUnAssociateDeductionDAO(Deduction_ID = qryOnDDSplitBy.Deduction_ID, Billback_ID = arguments.Billback_ID) />
					</cfloop>
					<!--- After updating the Children reset the parent --->
			 		<cfset this.fnUnAssociateDeductionDAO(Deduction_ID = getDDParent.Deduction_ID, Billback_ID = arguments.Billback_ID) />
						<!--- After deleting the splits update the split_count of the parent Billback to 0 --->
					<cfset splitCount = getDDParent.Split_Count - qryOnDDSplitBy.RecordCount />
					<cfquery name="delDDsplits" datasource="#Application.Datasource#"> 
						UPDATE Deductions 
						SET Split_Count = #splitCount#
						WHERE Deduction_ID =  '#getDDParent.Deduction_ID#' AND Deleted = 0 AND (DD_Status IN (1,2,3,4,9))
					</cfquery>	
			<!--- New handle in the scenario where the Deduction a child of a split from another Billback --->
			<cfelse>
					<!--- Just remove the Deduction and delete from the closure table --->
					<cfset this.fnUnAssociateDeductionDAO(Deduction_ID = arguments.Deduction_ID, Billback_ID = arguments.Billback_ID) />
			</cfif> <!--- <cfif qryOnDDSplitBy.RecordCount GTE 1> --->
		 
 		
		<!--- <cfset strMessage = "successfully done!" /> 
		<cfreturn strMessage/> --->
		<cfreturn />
		
	</cffunction>  
		
	<cffunction name="fnUnAssociateDeductionDAO" output="false" returntype="void">
		<cfargument name="Deduction_ID" type="string"> 
		<cfargument name="Billback_ID" type="string"> 
		<cfquery name="UpdUnAssociateDDStep1" datasource="#Application.Datasource#"> 
			UPDATE 
				Deductions 
			SET 
				DD_Closure_ID = NULL,
				DD_Closure_Type = NULL,
				DD_Closed_by = NULL,
				DD_Status 	= 2,
				DD_Date_Closed = NULL,
				DD_Resolution_Code = NULL,
				Cleared_Amount = NULL,
				Updated_Date = getDate(),
				Split_By_Billback_ID = NULL,
				DD_Closure_Sent = 0
			WHERE 
				Deduction_ID = '#arguments.Deduction_ID#'
		</cfquery>
		<cfquery name="UpdUnAssociateDDStep2" datasource="#Application.Datasource#">
			UPDATE 
				DD_Closure_Detail
			SET 
				Deleted = 1 
			WHERE 
				Deduction_ID = '#arguments.Deduction_ID#'
			/*AND	
				DD_Closure_ID = '#arguments.Billback_ID#'*/
		</cfquery>
		<cfset useLakebaseForUpdUnAssociateDDStep3 = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForUpdUnAssociateDDStep3>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#arguments.Billback_ID#"
			},
			{
				"bb_associated_to_dd" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdUnAssociateDDStep3 = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdUnAssociateDDStep3>
<cfquery name="UpdUnAssociateDDStep3" datasource="#Application.Datasource#">
			UPDATE 
				Billback
			SET 
				BB_Associated_To_DD = 0
			WHERE 
				Billback_ID = '#arguments.Billback_ID#'
		</cfquery>
</cfif>
		
		<cfreturn />
	</cffunction>

	<cffunction name="removeBillbackSplits" output="false" returntype="void">
		<cfargument name="Billback_ID" type="string"> 
			
		<!--- 
		First check to see if the Billback_ID passed is the parent or is it the child
			a) If it is parent then delete all the split children and update the Parent Billback 
			b) If it is a child then find the parent Billback and do step a.
		--->		
		
		<cfset useLakebaseForqryCheckBBIDIsParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqryCheckBBIDIsParent>
	<cftry>
		<cfset qryCheckBBIDIsParent = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"bb_is_child" = "eq.1",
				"billback_id" = "eq.#arguments.Billback_ID#",
				"select" = "bb_parent_id"
			}), "bb_parent_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqryCheckBBIDIsParent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqryCheckBBIDIsParent>
<cfquery name="qryCheckBBIDIsParent" datasource="#Application.Datasource#"> 
			SELECT 
				BB_Parent_ID 
			FROM 
				Billback 
			WHERE BB_IS_Child = 1 AND Billback_ID = '#arguments.Billback_ID#'
		</cfquery>
</cfif>
		
		<cfif (qryCheckBBIDIsParent.RecordCount GTE 1)>
			<cfset BillbackID = qryCheckBBIDIsParent.BB_Parent_ID />
		<cfelse>
			<cfset BillbackID = arguments.Billback_ID />
		</cfif> 
		
		<cfset useLakebaseFordelSplitChildren = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseFordelSplitChildren>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"bb_parent_id" = "eq.#BillbackID#",
				"bb_is_child" = "eq.1"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordelSplitChildren = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelSplitChildren>
<cfquery name="delSplitChildren" datasource="#Application.Datasource#"> 
			UPDATE 
				Billback
			SET 
				Deleted = 1 
			WHERE 
				BB_Parent_ID = '#BillbackID#' AND BB_IS_Child = 1
		</cfquery>
</cfif>
		<!--- 
			a) No change to status of the billback is made here as the approveBillback settlement will split this BB again and set the status for the Child BBs 
			b) No change to the BB_Approved table 
		--->
		<cfreturn />
	</cffunction>

	
	<!--- 
			These checking happen in the 
				index.cfm,
				payment.cfm 
				payment_confimation.cfm 
				pages that are replicated here 
	--->
		 
	<cffunction name="BBCheckerAndSetter" output="false" returntype="void">
		<cfargument name="Billback_ID" type="string"> 	
		<cfset Adj_Default_settings = variables.billbackSettingsManager.getAdjustment_Default()>
		<cfquery name="IsApproved" datasource="#application.datasource#">
		SELECT 	Billback.Billback_Status_ID, 
			Billback.Billback_Payee_Type_ID, 
			Billback.Auto_Billback,
			Billback.BB_Modify_Agree
		FROM 	Billback
		WHERE 	Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	
		<cfquery name="GetRealBBAmount" datasource="#application.datasource#">
			SELECT CAST(BB_Amount As Decimal(18,2)) As BB_Amount
			FROM Billback
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	
	<!---Gets Billback Amount from Database--->
	<cfset BillbackTotal = GetRealBBAmount.BB_Amount>
	<cfset ExpectedTotal = 0>
	
	<cfinclude template="/billbacks/approval/inc_expected_total.cfm">

	<!---Add Growth Amounts--->
	
	<cfquery name="GrowthTotal" datasource="#application.datasource#">
	SELECT 	Round(ISNull(Sum(Expected_Amount), 0), 2) AS Expected_Amount
	FROM 	Billback_Program	
		INNER JOIN BB_Growth_Program
		ON
		(
			(BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
			AND
			(BB_Growth_Program.Deleted = 0)
		)	
	
	WHERE Billback_Program.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	AND Billback_Program.Deleted = 0
	AND Exists
	( 	SELECT Billback_Program.Billback_Program_ID
		FROM Billback_Program
		WHERE (BB_Growth_Program.Billback_Program_ID = Billback_Program.Billback_Program_ID)
		AND	(BB_Growth_Program.Deleted = 0)
	)
	</cfquery>
	
	
	<cfoutput>
	<cfif GrowthTotal.Recordcount GT 0>
	<cfset ExpectedTotal = ExpectedTotal + GrowthTotal.Expected_Amount>
	</cfif>
	
	</cfoutput>

	<!---Add Lump Sum Totals--->
	
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
		<cfset ExpectedTotal = ExpectedTotal + GetLSTotals.LS_Expected_Amount>
			
			<cfquery name="qIsCritical" datasource="#application.datasource#">
				SELECT BB_PNF, BB_UP, Scheduled_Auto_BB
				FROM Billback
				WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
			<cfset IsCritical = StructNew() />
			<cfset IsCritical.BB_PNF = qIsCritical.BB_PNF />
			<cfset IsCritical.BB_UP = qIsCritical.BB_UP />
			<cfset IsCritical.BB_ALTERNATEPAYEE = 0 />
		<cfset SHOW_BILLBACK_PAY 	= 0>
	<cfset SHOW_EXPECTED_PAY 	= 0>
	<cfset SHOW_NONE_PAY 		= 0>
	<cfset SHOW_DETAILED_PAY 	= 0>
	<cfset SHOW_CONTINUE		= 0>
	
	<cfset SHOW_BILLBACK_MSG 	= "">
	<cfset SHOW_EXPECTED_MSG 	= "">
	<cfset SHOW_DETAILED_MSG 	= "">
	<cfif IsCritical.BB_PNF IS 0 AND ISCritical.BB_UP IS 0>
	<!------ If not Critical ----->
	
		<cfset SHOW_BILLBACK_PAY = 1>
		
		<cfset SHOW_EXPECTED_PAY = 1>
		
		<cfset SHOW_DETAILED_PAY = 1>
	</cfif>

	<cfif appsettings.getBillbackModifyAgree() EQ 1 >
	
		<cfquery name="HasBeenAgreed" datasource="#application.datasource#">
		SELECT BB_Agreed_Info.Agreed_Amount
		FROM BB_Agreed_Info
		WHERE BB_Agreed_Info.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND BB_Agreed_Info.Deleted = 0
		</cfquery>
		
		<cfif HasBeenAgreed.Recordcount GT 0 AND IsApproved.BB_Modify_Agree EQ 0>
			<!---Hide most choices but add a "Continue" button --->
			<cfset SHOW_BILLBACK_PAY = 0>
			<cfset SHOW_EXPECTED_PAY = 0>
			<cfset SHOW_DETAILED_PAY = 0>
			<cfset SHOW_NONE_PAY 	 = 0>
			<cfset SHOW_CONTINUE	 = 1>
			
			<!--- Figure out what the last user picked and select that --->
			<cfset AgreedSelectionType = "">
			<cfset AgreedAmount = "">
			<cfset Rate_Paid_Type = "A" />
			<!--- If the Agreed Amount EQ the Billback Amount, set it to be Billback Amount --->
			<cfif HasBeenAgreed.Agreed_Amount EQ BillbackTotal>
				<cfset AgreedSelectionType = "BB">
				<cfset AgreedAmount =  BillbackTotal>
			<!--- If the Agreed Amount EQ the Expected Amount, set it to be Expected Amount (if BB and expected are smae, this will overwrite the previous select) --->
			<cfelseif HasBeenAgreed.Agreed_Amount EQ ExpectedTotal>
				<cfset AgreedSelectionType = "E">
				<cfset AgreedAmount =  ExpectedTotal>
			<!--- If it's not one of those two, it must be manual --->
			<cfelse>
				<cfset AgreedSelectionType = "M">
				<cfset AgreedAmount =  HasBeenAgreed.Agreed_Amount>
			</cfif>
			
		</cfif>
	<!--- Checking app setting for modify agree --->
	</cfif>

	<cfif SHOW_BILLBACK_PAY EQ 1>
		<cfset Rate_Paid_Type ="BB" />
	
	<cfelseif (qIsCritical.Scheduled_Auto_BB and trim(ExpectedTotal) neq trim(BillbackTotal)) OR (SHOW_EXPECTED_PAY EQ 1 and Not qIsCritical.Scheduled_Auto_BB)>
		<cfset Rate_Paid_Type ="E" />		
				
	<cfelseif SHOW_NONE_PAY EQ 1>
			<cfset Rate_Paid_Type ="None" />
	</cfif>


	<!--- Populate "BB_Item_Final_Detail" table first --->
	<cfquery name="updBBItemFinalDetail" datasource="#application.datasource#">
		UPDATE BB_Item_Final_Detail
		SET
			Paid_Rate_CS = Approved_Rate_CS,
			Paid_Rate_LB = Approved_Rate_LB
		FROM BB_Item_Final
			INNER JOIN BB_Item_Final_Detail
		ON 
			BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID
		WHERE	
			BB_Item_Final.Billback_ID =  '#arguments.Billback_ID#' AND
			BB_Item_Final.deleted = 0 AND 
			BB_Item_Final_Detail.deleted = 0
	</cfquery>

	
	<!--- Now populate "BB_Item_Final" table as population of "Item_Total_Paid" column for this table 
	depends on "BB_Item_Final_Detail" table.
	Note: As of now (11/7/2012), "Item_Total_Paid" is probably not being used anywhere.
	--->
	<cfquery name="updBBItemFinal" datasource="#application.datasource#">
		UPDATE BB_Item_Final
		SET
			Item_Volume_Paid_CS = Item_Volume_Approved_CS,
			Item_Volume_paid_LB = Item_Volume_Approved_LB,
			Item_Total_Paid = 
			
			<!--- For GM, we have 1 to 1 relationship between "BB_Item_Final" and "BB_Item_Final_Detail", but for some other clients
			the relationship is 1 to many and so we are using the SUM function.
			--->
			(
			SELECT SUM(BB_Item_Final_Detail.Paid_Rate_LB) * BB_Item_Final.Item_Volume_Approved_LB
			FROM BB_Item_Final_Detail
			WHERE 
				BB_Item_Final.BB_Item_Final_ID = BB_Item_Final_Detail.BB_Item_Final_ID AND
				BB_Item_Final_Detail.deleted = 0
			)
		FROM BB_Item_Final
		WHERE 
			BB_Item_Final.Billback_ID = '#arguments.Billback_ID#' AND
			BB_Item_Final.deleted = 0
	</cfquery>
	
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Step 4. Get Payee and new status information
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
		<cfquery name="GetPayeeType" datasource="#application.datasource#">
		SELECT 	Billback.Billback_Payee_Type_ID, 
				Billback_Status_ID, 
				Billback.BB_Request_Approval_User_ID,
				Billback.BB_Code,
				Billback.BB_Title
		FROM Billback		
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfset Payee_Type = GetPayeeType.Billback_Payee_Type_ID>
		
		<cfinclude template="/billbacks/Approval/Payee_ID_Finder.cfm">		
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Step 5. Update / Insert into BB_Adjustment table
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->	 
	
	<cfquery name="GetApprovedTotal" datasource="#application.datasource#">
		SELECT 	
				SUM(
				CASE 
				WHEN Billback_Product.BB_Product_UOM = 1 THEN
					CAST(IsNull(BB_Item_Final.Item_Volume_Approved_CS, 0) * IsNull(Approved_Rate_CS, 0) As decimal(18,2))
				ELSE
					CAST(IsNull(BB_Item_Final.Item_Volume_Approved_LB, 0) * IsNull(Approved_Rate_LB, 0) As decimal(18,2))
				END
				)
				As ApprovedTotal
		FROM 	BB_Item_Final
				INNER JOIN Billback_Product
				ON
				Billback_Product.Deleted = 0
				AND
				Billback_Product.Billback_Product_ID = BB_Item_Final.Billback_Product_ID
				INNER JOIN BB_Item_Final_Detail
				ON BB_Item_Final.BB_Item_Final_id = BB_Item_Final_Detail.BB_Item_Final_id
		WHERE 	BB_Item_Final.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND BB_Item_Final.Deleted = 0 
				AND BB_Item_Final_Detail.Deleted = 0
				AND BB_Item_Final_Detail.BB_Product_Type != 3 
				AND BB_Item_Final_Detail.BB_Product_Type !=4
	</cfquery>
	
	<cfset ApprovedTotal = GetApprovedTotal.ApprovedTotal>
	<cfif ApprovedTotal EQ ''>
		<cfset ApprovedTotal = 0 />
	</cfif>
	
	
	<!---Add Growth Amounts--->
	
	  <cfquery name="GrowthApprovedTotal" datasource="#application.datasource#">
	    SELECT ROUND(ISNULL(SUM(Approved_Amount), 0), 2) as ApprovedGrowth
	    FROM BB_Growth_Program
	    WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	  </cfquery>
	  <cfset ApprovedTotal = (ApprovedTotal) + GrowthApprovedTotal.ApprovedGrowth>
	  <!---Add Lump Sum Amounts--->
	  <cfquery name="LSApprovedTotal" datasource="#application.datasource#">
	    SELECT ROUND(ISNULL(SUM(LS_Approved_Amount), 0), 2) AS ApprovedLS
	    FROM BB_Lump_Sums
	    WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	  </cfquery>
	
		<cfset ApprovedTotal = ApprovedTotal + LSApprovedTotal.ApprovedLS>
		<cfinclude template="/get_access_profile.cfm">
		<cfset E_Amount_Total = ExpectedTotal />
		<cfset Approve_Amount = Get_Profile_Settings.BB_Approve_Amount> 
		<cfset E_Amount_Total = Round(E_Amount_Total * 100) / 100><!------ round to 2 decimal places ----->
		<cfset ApprovedTotal = Round(ApprovedTotal * 100) / 100><!------ round to 2 decimal places ----->
		<cfset B_Approval_Difference = (ApprovedTotal - E_Amount_Total)>
	   <!---  <cfset Rate_Paid_Type="A"> --->
		<cfset Payment_Amount="#ApprovedTotal#">
		<cfset Billback_Amount_Total="#BillbackTotal#">
		<cfset ApprovedTotal="#ApprovedTotal#">
		<cfset Adjustment_Created = Payment_Amount - E_Amount_Total>
	
		<cfif Adjustment_Created GT 0>
			<cfquery name="CreateOrUpdateAdjustment" datasource="#application.datasource#">
			SELECT TOP 1 BB_Adjustment_ID
			FROM BB_Adjustment
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND BB_Adjustment.Deleted = 0
			</cfquery>
			
			<cfset Deviation_Type = 1>
			<cfset PullBackProgram = "">
			<cfset RegularProgram = "">
			<cfset PullBackBBProgram = "">
			<cfset RegularBBProgram = "">
			<cfset AmtToRemove = 0>
			<cfset AnyProgram_SameAdjAction = 0>
			
			<cfquery name="BBProgram" datasource="#application.datasource#">
				SELECT 	Program_ID,
						Billback_Program_ID
				FROM 	Billback_Program
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
						Deleted = 0
			</cfquery>	
			
			<cfif appSettings.getPullbacksOn()>
				<cfquery name="checkifeligibleforpullbacklogentry" datasource="#application.datasource#">
					SELECT 		DISTINCT Billback_Program.Program_ID,
								Billback_Program.Billback_Program_ID,
								Program_Control_Panel_Options.pullback_from_corporate,
								Pullbacks_On,generic_type,is_pullback_corporate_deal
					FROM 		Billback
					INNER JOIN 	Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID AND Billback_Program.Deleted = 0
					INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
					INNER JOIN 	Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.Programtype_ID
					WHERE 		Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
				</cfquery>
				
				<cfloop query="checkifeligibleforpullbacklogentry">
					<cfif ( 
							(	checkifeligibleforpullbacklogentry.generic_type EQ "Distributor Trade/Shelter" AND 
								checkifeligibleforpullbacklogentry.is_pullback_corporate_deal EQ 0 AND
					            checkifeligibleforpullbacklogentry.pullback_from_corporate EQ 1
							) OR 
					        (	checkifeligibleforpullbacklogentry.generic_type EQ "Operator Direct or HQ Programs" OR 
								checkifeligibleforpullbacklogentry.generic_type EQ "Operator-Deviated Pricing"
							)
					      ) AND 
						  checkifeligibleforpullbacklogentry.Pullbacks_On EQ 1>
							<cfset Deviation_Type = 2>
							<cfset PullBackProgram = LISTAPPEND(PullBackProgram,Program_ID,",")>		
							<cfset PullBackBBProgram = LISTAPPEND(PullBackBBProgram,Billback_Program_ID,",")>					
					<cfelse>
							<cfset RegularProgram = LISTAPPEND(RegularProgram,Program_ID,",")>	
							<cfset RegularBBProgram = LISTAPPEND(RegularBBProgram,Billback_Program_ID,",")>
					</cfif>
				</cfloop>
			<cfelse>				
				<cfset RegularProgram = VALUELIST(BBProgram.Program_ID)>
				<cfset RegularBBProgram = VALUELIST(BBProgram.Billback_Program_ID)>
			</cfif>
	
	 		<cfquery name="AdjustmentSettings" datasource="#application.datasource#">
				SELECT 	Adjustment_From_Program_WithOut_PullBack, Adjustment_From_Program_With_PullBack
				FROM 	Billback_Settings				
			</cfquery>	
	
			<cfif AdjustmentSettings.Adjustment_From_Program_WithOut_PullBack NEQ AdjustmentSettings.Adjustment_From_Program_With_PullBack AND
			(
				(RegularProgram NEQ "" AND BBProgram.RecordCount NEQ LISTLEN(RegularProgram,',') ) OR
				(PullBackProgram NEQ "" AND BBProgram.RecordCount NEQ LISTLEN(PullBackProgram,',') )
			)
			>
				<cfquery name="RemoveAdjAmount" datasource="#application.datasource#">
					DECLARE
						@Expected_Amt Decimal(18,2),
						@LS_Expected_Amt Decimal(18,2),
						@Paid_Amt Decimal(18,2),
						@LS_Paid_Amt Decimal(18,2),
						@Deviated_Amt DECIMAL(18,2)
						
					IF OBJECT_ID('tempdb..##Temp_Expected_Amt') IS NOT NULL
						DROP TABLE ##Temp_Expected_Amt
					
					SELECT
								CASE 
									WHEN Item_E_Volume_CS >= Item_BB_Volume_CS THEN
										Item_BB_Volume_CS
									ELSE
										Item_E_Volume_CS
								END Expected_CASE,
		
								CASE 
									WHEN Expected_Rate_CS >= Billback_Rate_CS THEN
										Billback_Rate_CS
									ELSE
										Expected_Rate_CS
								END Expected_Rate,
								Item_Volume_Paid_CS AS Paid_CS,
								Paid_Rate_CS 
								
					INTO		##Temp_Expected_Amt
					FROM		BB_Item_Final 
					INNER JOIN	BB_Item_Final_Detail ON BB_Item_Final.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
								<cfif AdjustmentSettings.Adjustment_From_Program_WithOut_PullBack EQ 2>
								BB_Item_Final.Billback_Program_ID IN (#LISTQUALIFY(RegularBBProgram,"'",",","All")#) AND
								<cfelseif AdjustmentSettings.Adjustment_From_Program_With_PullBack EQ 2>
								BB_Item_Final.Billback_Program_ID IN (#LISTQUALIFY(PullBackBBProgram,"'",",","All")#) AND
								</cfif>
								BB_Item_Final_Detail.BB_Item_Final_ID = BB_Item_Final.BB_Item_Final_ID AND
								BB_Item_Final_Detail.Deleted = 0 AND BB_Item_Final.Deleted = 0
					
					SELECT @Expected_Amt = CAST((SUM(Expected_CASE * Expected_Rate)) AS Decimal(18,2)),
							@Paid_Amt = CAST((SUM(Paid_CS * Paid_Rate_CS)) AS Decimal(18,2))
					FROM ##Temp_Expected_Amt			
		
					IF @Expected_Amt IS NULL 
						SET @Expected_Amt = 0
					IF @Paid_Amt IS NULL
						SET @Paid_Amt = 0
						
					SELECT 	@LS_Expected_Amt = SUM(ISNULL(LS_Expected_Amount,0)) ,
							@LS_Paid_Amt = SUM(ISNULL(LS_Paid_Amount,0)) 
					FROM 	BB_Lump_Sums WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND 
							<cfif AdjustmentSettings.Adjustment_From_Program_WithOut_PullBack EQ 2>
								Billback_Program_ID IN (#LISTQUALIFY(RegularBBProgram,"'",",","All")#) AND
							<cfelseif AdjustmentSettings.Adjustment_From_Program_With_PullBack EQ 2>
								Billback_Program_ID IN (#LISTQUALIFY(PullBackBBProgram,"'",",","All")#) AND
							</cfif>
							Deleted = 0
					
					SET @Expected_Amt = @Expected_Amt + ISNULL(@LS_Expected_Amt,0)
					SET @Paid_Amt = @Paid_Amt + ISNULL(@LS_Paid_Amt,0)
					--SELECT @Deviated_Amt = ISNULL(@Paid_Amt,0) - ISNULL(@Expected_Amt,0)
					SELECT ISNULL(@Paid_Amt,0) - ISNULL(@Expected_Amt,0) AmtToRemove				
				</cfquery>		
				<cfset AmtToRemove = RemoveAdjAmount.AmtToRemove>
			<cfelse>
				<cfset AnyProgram_SameAdjAction = 1>
			</cfif>
		<cfset New_Adjustment_Created = Adjustment_Created - AmtToRemove>
		
		<cfset Remove = 0>
		<cfif (AdjustmentSettings.Adjustment_From_Program_WithOut_PullBack EQ 2 AND AdjustmentSettings.Adjustment_From_Program_With_PullBack EQ 2)
				OR
				(AdjustmentSettings.Adjustment_From_Program_WithOut_PullBack EQ 2 AND PullBackBBProgram EQ "") 
				OR
				(AdjustmentSettings.Adjustment_From_Program_With_PullBack EQ 2 AND RegularBBProgram EQ "")
				>
			<cfset Remove = 1>
		</cfif>
		
	 	<cfif CreateOrUpdateAdjustment.Recordcount IS 0>	
		
		 	<cfquery name="CreateAdjustment" datasource="#application.datasource#">
			INSERT INTO BB_Adjustment
			(
			Billback_ID,
			Billback_Payee_Type_ID,
			Payee_ID,		
			<cfif Remove EQ 1>
				Hidden,
			<cfelse>
				<cfif  Adj_Default_settings eq 2>Ignore,</cfif>
				<cfif  Adj_Default_settings eq 3>Hidden,</cfif>
			</cfif>
			Adjustment_Amount,
			Deviation_Type
			)
			VALUES
			(
			<cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#Payee_Type#" cfsqltype="CF_SQL_INTEGER">,
			<cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">,
			<cfif Remove EQ 1>
				1,
			<cfelse>
				<cfif Adj_Default_settings eq 2>1,</cfif>
				<cfif Adj_Default_settings eq 3>1,</cfif>
			</cfif>
			<cfqueryparam value="#New_Adjustment_Created#" cfsqltype="CF_SQL_FLOAT">,
			#Deviation_Type#
			)
			</cfquery>
		<cfelse>
			<cfquery name="UpdateAdjustment" datasource="#Application.datasource#">
			UPDATE BB_Adjustment
			SET
			Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">,
			Billback_Payee_Type_ID = <cfqueryparam value="#Payee_Type#" cfsqltype="CF_SQL_INTEGER">,
			Payee_ID = <cfqueryparam value="#Payee_ID#" cfsqltype="CF_SQL_VARCHAR">,
			Adjustment_Amount = <cfqueryparam value="#New_Adjustment_Created#" cfsqltype="CF_SQL_FLOAT">,
			<cfif Remove EQ 1>Hidden = 1,</cfif>
			Deviation_Type = #Deviation_Type#
			WHERE BB_Adjustment_ID = <cfqueryparam value="#CreateOrUpdateAdjustment.BB_Adjustment_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery>
		</cfif>
		
		<cfquery name="DelAdjRemove" datasource="#Application.datasource#">
			DELETE FROM BB_Adjustment_Removal
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfif AdjustmentSettings.Adjustment_From_Program_WithOut_PullBack EQ 2 OR AdjustmentSettings.Adjustment_From_Program_With_PullBack EQ 2>		
			<cfquery name="InsAdjremove" datasource="#Application.datasource#">
				INSERT INTO BB_Adjustment_Removal
					(	Billback_ID,
						Removed_Program_Type,
						Removed_From_Program_IDS,
						Removed_Amount
					)
				VALUES 
					(	'#Billback_ID#',
						<cfif AdjustmentSettings.Adjustment_From_Program_WithOut_PullBack EQ 2 AND AdjustmentSettings.Adjustment_From_Program_With_PullBack EQ 2>
						1,'#LISTAPPEND(RegularProgram,PullBackProgram)#',#Adjustment_Created#
						<cfelseif AdjustmentSettings.Adjustment_From_Program_WithOut_PullBack EQ 2>
						2,'#RegularProgram#',#AmtToRemove#
						<cfelseif AdjustmentSettings.Adjustment_From_Program_With_PullBack EQ 2>			
						3,'#PullBackProgram#',#AmtToRemove#
						</cfif>					
						
					)
			</cfquery>
		</cfif>
	 
	</cfif>
	
	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Step 6. Update growth and lumpsum paid tables
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<cfif Rate_Paid_Type IS "BB">
		<cfquery name="UpdateGrowth" datasource="#application.datasource#">
		UPDATE BB_Growth_Program
		SET Paid_Amount = BB_Growth_Amount
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		<cfquery name="UpdateLS" datasource="#application.datasource#">
		UPDATE BB_Lump_Sums
		SET LS_Paid_Amount = LS_Billback_Amount
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	
	<cfelseif Rate_Paid_Type IS "E">
		
		<cfquery name="UpdateGrowth" datasource="#application.datasource#">
		UPDATE BB_Growth_Program
		SET Paid_Amount = Expected_Amount
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfquery name="UpdateLS" datasource="#application.datasource#">
		UPDATE BB_Lump_Sums
		SET LS_Paid_Amount = LS_Expected_Amount
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
	<cfelseif Rate_Paid_Type IS "A">
		
		<cfquery name="UpdateGrowth" datasource="#application.datasource#">
		UPDATE BB_Growth_Program
		SET Paid_Amount = Approved_Amount
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfquery name="UpdateLS" datasource="#application.datasource#">
		UPDATE BB_Lump_Sums
		SET LS_Paid_Amount = LS_Approved_Amount
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
	<cfelseif Rate_Paid_Type IS "None">
		
		<cfquery name="UpdateGrowth" datasource="#application.datasource#">
		UPDATE BB_Growth_Program
		SET Paid_Amount = 0
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
			
		<cfquery name="UpdateLS" datasource="#application.datasource#">
		UPDATE BB_Lump_Sums
		SET LS_Paid_Amount = 0
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
	
	<cfelse>
		
		<cfquery name="UpdateGrowth" datasource="#application.datasource#">
		UPDATE BB_Growth_Program
		SET Paid_Amount = 0
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
			
		<cfquery name="UpdateLS" datasource="#application.datasource#">
		UPDATE BB_Lump_Sums
		SET LS_Paid_Amount = LS_Approved_Amount
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
	</cfif>

	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Step 6a. Update lump sum cap allocation table
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<cfquery name="qUpdatePaidAmountInAllocTable" datasource="#application.datasource#">
		UPDATE	BB_Program_Lump_Sum_Distributor 
		SET 	Paid_Amount = Selected_Amount
		WHERE 	BB_Program_Lump_Sum_Distributor.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND 	BB_Program_Lump_Sum_Distributor.Deleted = 0
	</cfquery>


	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Step 6b. Delete any worksheet tables for the billback
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	
	<cfquery name="DeleteWSVolume" datasource="#application.datasource#">
	DELETE FROM BB_Worksheet_Volume
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>
	
	<cfquery name="DeleteWSDollars" datasource="#application.datasource#">
	DELETE FROM BB_Worksheet_Dollars
	WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</cfquery>

	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Step 7. Check if pullbacks are On. If so find this billback program + Customer + products are eligible for pullback from Pullback_details table. 
	and make entry in the Pullback Log tables. All this should be executed in a SP below.
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<!--- Moved to file BillbackSettlementManager.cfc ---> 

	<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	Step 8. Update Modify Agree Details
	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
	<cfif appsettings.getBillbackModifyAgree() EQ 1>
		<!--- Check If modify agree is 1 --->
		<cfquery name="getBBInfo" datasource="#application.datasource#">
			select BB_Modify_Agree
			from billback
			where Billback_Id = '#Billback_ID#'
		</cfquery>
	
		<cfif getBBInfo.BB_Modify_Agree EQ 1>
		<cfinclude template="save_modifyagree_BBchanges.cfm">
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
<cfquery NAME="UpdateModifyAgreeInfo" DATASOURCE="#Application.Datasource#">
		update Billback
		set BB_modify_agree = 0
		where Billback_Id = '#Billback_ID#'
		</cfquery>
</cfif>
		</cfif>
	</cfif>		
	
	<cfreturn />
 </cffunction>

	<!--- 
		This function will be called in the Approve step to check, if there are any splits for the billback 
		and if all the children are either Approved(3), PaymentRequest(4) or Paid(5) status then change the 
		Parent BB to be of status Approved(3)
	--->
	
	<cffunction name="updateParentBBID" output="false" returntype="void">
		<cfargument name="Billback_ID" type="string"> 
		
		<cfset useLakebaseForcheckForSplits = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForcheckForSplits>
	<cftry>
		<cfset checkForSplits = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"bb_parent_id" = "eq.#arguments.Billback_ID#",
				"deleted" = "eq.0",
				"select" = "bb_closing_method,billback_status_id,bb_parent_id"
			}), "bb_closing_method,billback_status_id,bb_parent_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckForSplits = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckForSplits>
<cfquery name="checkForSplits" datasource="#application.datasource#">
			SELECT 
				BB_Closing_Method, 
				Billback_Status_ID,
				BB_Parent_ID
			FROM 
				Billback 
			WHERE 
				BB_Parent_ID = '#arguments.Billback_ID#' AND 
				Deleted = 0
		</cfquery>
</cfif>	
		
		<cfif isDefined("checkForSplits.RecordCount") AND checkForSplits.RecordCount GTE 1>
			<cfquery name="qSelSplits" datasource="#application.datasource#">
				SELECT 
					BB_Closing_Method, 
					Billback_Status_ID 
				FROM 
					Billback 
				WHERE 
					BB_Parent_ID = '#arguments.Billback_ID#' AND 
					Deleted = 0 AND 
					Billback_Status_ID IN (1,2)
			</cfquery>
			
			<cfif isDefined("qSelSplits.RecordCount") AND qSelSplits.RecordCount EQ 0>

				<!--- Get closing method of a child billback and set that closing method for the parent --->
				<cfset qGetChildBBClosingMethod = getAnyClosingMethodChildBB(checkForSplits.BB_Parent_ID)>

				<cfquery name="UpdBBParent" datasource="#application.datasource#">
					UPDATE
						Billback
					SET Billback_Status_ID = 3,
					BB_Closing_Method = #qGetChildBBClosingMethod.BB_Closing_Method#
					WHERE 
						Billback_ID = '#arguments.Billback_ID#'  AND
						Deleted = 0
				</cfquery>	
			</cfif>
		</cfif>				
		
		<!--- Code below is for setting up the vendor id on the BB_approved table  --->
		<cfset useLakebaseForselPayeeType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForselPayeeType>
	<cftry>
		<cfset selPayeeType = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"billback_id" = "eq.#arguments.Billback_ID#",
				"deleted" = "eq.0",
				"select" = "billback_payee_type_id"
			}), "billback_payee_type_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForselPayeeType = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForselPayeeType>
<cfquery name="selPayeeType"  datasource="#application.datasource#">
			SELECT Billback_Payee_Type_ID
			FROM
				Billback
			WHERE 	
				Billback_ID = '#arguments.Billback_ID#' AND
				Deleted = 0
		</cfquery>
</cfif>
		<cfif (isDefined("selPayeeType.RecordCount") AND selPayeeType.RecordCount GTE 1)>
			<!--- Check if the payee is Distributor --->
			<cfif (selPayeeType.Billback_Payee_Type_ID EQ 1)>
				<cfset useLakebaseForselVendorID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_distributor")>
<cfif useLakebaseForselVendorID>
	<cftry>
		<cfset selVendorID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_distributor", {
				"billback_id" = "eq.#arguments.Billback_ID#",
				"deleted" = "eq.0",
				"select" = "uploaded_vendor_id"
			}), "uploaded_vendor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForselVendorID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForselVendorID>
<cfquery name="selVendorID"  datasource="#application.datasource#">
					SELECT Uploaded_Vendor_ID
					FROM
						Billback_Distributor
					WHERE 	
						Billback_ID = '#arguments.Billback_ID#' AND
						Deleted = 0
				</cfquery>
</cfif>
			<!--- Check if the payee is Operator --->
			<cfelseif (selPayeeType.Billback_Payee_Type_ID EQ 2)>
				<cfquery name="selVendorID"  datasource="#application.datasource#">
					SELECT Uploaded_Vendor_ID
					FROM
						Billback_Operator
					WHERE 	
						Billback_ID = '#arguments.Billback_ID#' AND
						Deleted = 0
				</cfquery>
			</cfif>
			<cfif (isDefined("selVendorID") AND selVendorID.RecordCount GTE 1)>
				<cfset useLakebaseForselVendorMasterID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForselVendorMasterID>
	<cftry>
		<cfset selVendorMasterID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", {
				"vendor_id" = "eq.#selVendorID.Uploaded_Vendor_ID#",
				"deleted" = "eq.0",
				"select" = "vendor_master_id"
			}), "vendor_master_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForselVendorMasterID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForselVendorMasterID>
<cfquery name="selVendorMasterID"  datasource="#application.datasource#">
		 			SELECT 
						Vendor_Master_ID 
					FROM 
						Vendor_Master 
					WHERE 
						Vendor_ID = '#selVendorID.Uploaded_Vendor_ID#'
						AND Deleted = 0
				</cfquery>
</cfif>
			</cfif>
			<cfif (isDefined("selVendorMasterID") AND selVendorMasterID.RecordCount GTE 1)>
				<cfset useLakebaseForupdVendorMasterID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_approved")>
<cfif useLakebaseForupdVendorMasterID>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_approved",
			{
				"billback_id" = "eq.#arguments.Billback_ID#"
			},
			{
				"vendor_master_id" = "#selVendorMasterID.Vendor_Master_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdVendorMasterID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdVendorMasterID>
<cfquery name="updVendorMasterID"  datasource="#application.datasource#">
					UPDATE 
							BB_Approved
					SET 	
							Vendor_Master_ID = '#selVendorMasterID.Vendor_Master_ID#'
					WHERE 
							Billback_ID = '#arguments.Billback_ID#'  
				</cfquery>
</cfif>
			</cfif> <!--- <cfif isDefined("selVendorMasterID") AND selVendorMasterID.RecordCount GTE 1> --->
		</cfif>	<!--- <cfif (isDefined("selPayeeType.RecordCount") AND selPayeeType.RecordCount GTE 1)> --->
		
		<!--- Tim Ford - 05/10/2016: WR 60819 - Was Remittance information sent on BB 3590608:
				Adding code to set the payment notes on child splits equal to the parent if the closing method is payment.
		--->
		<cfquery name="qUpdateChildPaymentNotes" datasource="#application.datasource#">
			UPDATE	bb2
			SET		bb2.Payment_Notes =  b.Payment_Notes
			FROM	Billback b
					inner join Billback bb2 on bb2.BB_Parent_ID = b.Billback_ID and bb2.Deleted = 0 and bb2.BB_Closing_Method = 1
			WHERE 	b.Billback_ID 		= '#arguments.Billback_ID#' 
			AND		b.BB_Closing_Method	= 1
			AND		b.Deleted = 0
		</cfquery>
				 
	</cffunction>
	
	<!---	Get closing methods of any 1 child billback of a split billback.
		Note: Since "ORDER BY BB_Closing_Method" is being used, the closing method returned will be the lowest integer possible.
		Eg: If any of the child closing method has "payment" as the closing method, "payment" will always be returned as it has
		an id of 1.--->
	<cffunction name="getAnyClosingMethodChildBB" output="false" returntype="query">
		<cfargument name="BBParentID" type="string">

		<cfset useLakebaseForqAnyClosingMethodChildBB = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForqAnyClosingMethodChildBB>
	<cftry>
		<cfset qAnyClosingMethodChildBB = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback", {
				"bb_parent_id" = "eq.#arguments.BBParentID#",
				"deleted" = "eq.0",
				"bb_is_child" = "eq.1",
				"order" = "bb_closing_method.asc",
				"limit" = "1",
				"select" = "bb_closing_method"
			}), "bb_closing_method"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqAnyClosingMethodChildBB = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqAnyClosingMethodChildBB>
<cfquery name="qAnyClosingMethodChildBB" datasource="#application.datasource#">
			SELECT TOP 1 BB_Closing_Method
			FROM 
				Billback
			WHERE 
				BB_Parent_ID = '#arguments.BBParentID#' AND
				Deleted = 0 AND
				BB_Is_Child = 1
			ORDER BY BB_Closing_Method
		</cfquery>
</cfif>

		<cfreturn qAnyClosingMethodChildBB>

	</cffunction>
	

	<cffunction name="qGetIsCritical" output="false" returntype="query">
		<cfargument name="Billback_ID" type="string"> 

		<cfquery name="qIsCritical" datasource="#application.datasource#">
		SELECT BB_PNF, BB_UP, Scheduled_Auto_BB
		FROM Billback
		WHERE Billback_ID = <cfqueryparam value="#arguments.Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
			
		<cfreturn qIsCritical>
	</cffunction>

	<cffunction name="qGetIsAgreed" output="false" returntype="query">
		<cfargument name="BillbackIDInt" type="string"> 

		<cfset Billback_ID = variables.oBillbackDAO.getBillbackUUID(arguments.BillbackIDInt)>

		<cfquery name="qIsAgreed" datasource="#application.datasource#">
		SELECT BB_Agreed_Info_ID
		FROM BB_Agreed_Info
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND deleted = 0	
		</cfquery>
			
		<cfreturn qIsAgreed>
	</cffunction>

	<cffunction name="updateBBSettlementData" output="false" returntype="void">
		
		<cfargument name="Billback_ID" 		type="string" />
		<cfargument name="paymentNotes" 	type="string" />
		<cfargument name="bSpecialHandling" type="string" />
		<cfargument name="billTo" 			type="string" default="" />

		<cfset Billback_ID 		= arguments.Billback_ID />
		<cfset paymentNotes	 	= Trim(REReplace(arguments.paymentNotes,"#chr(13)#|#chr(9)#|\n|\r"," ","ALL")) />
		<cfset bSpecialHandling	= arguments.bSpecialHandling />
		<cfset strBillTo		= trim(arguments.billTo) />
		
<!--- 		<cfquery name="qCheckForRecord" datasource="#application.datasource#">
			SELECT	BB_Approved_ID 
			FROM 	BB_Approved
			WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery> --->

		<!--- <cfif qCheckForRecord.RecordCount> --->
			<cfquery name="qUpdate" datasource="#application.datasource#">
				UPDATE 	Billback
				SET 	Payment_Notes 			= <cfqueryparam value="#paymentNotes#" cfsqltype="CF_SQL_VARCHAR">,
						Special_Handling 		= <cfqueryparam value="#bSpecialHandling#" cfsqltype="cf_sql_bit">,
						Distributor_Bill_To_ID	= <cfqueryparam value="#strBillTo#" cfsqltype="cf_sql_varchar" null="#IIF(len(strBillTo) is 0, DE("yes"), DE("no"))#">
				WHERE 	Billback_ID 		= <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
			</cfquery> 
		<!--- </cfif> --->
		
	</cffunction>
	
</cfcomponent>


