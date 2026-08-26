<cfcomponent>

		<cfset this.DDMgr = createObject("Component","components.Deduction.DeductionManager").init()>
		<cfset this.BBMgr = createObject("Component","components.Billback.BillbackManager").init()>

	<cffunction name="getDDAutoMatchSettings" 	access="public" returntype="query" output="true" displayname="getDDAutoMatchSettings">
		<CFQUERY NAME="qGetAutoMatch" DATASOURCE="#Application.Datasource#">
			SELECT	DD_Auto_Match_ID,Enabled,Dollar_Amount,Dollar_Amount_Value,Match_Reference_Number,Match_Distributor_Bill_To,
						Match_Distributor_Ship_To,Auto_Match_DD_Reason_Code_ID,	Write_Off_DD_Reason_Code_ID,Use_Auto_Match_DD_Reason_Code,
						Use_Write_Off_DD_Reason_Code,Deduction_Status_After_Auto_Match,Write_Off_Dollar_Amount_Value,Auto_Match_Reconcile <!--- 61842 --->
			FROM	DD_Auto_Match
		</CFQUERY>
		<cfreturn qGetAutoMatch />
	</cffunction>	

	<cffunction name="AssociateDDtoBB" access="public" returntype="any" output="true" displayname="AssociateDDtoBB">
						
		<cfargument name="BBParentID" required="true" type="string">
		<cfargument name="DDList" required="true" type="string">
		<cfargument name="splitStartCount" required="true" type="numeric">
		
		<cfset loopCount = arguments.splitStartCount />
		<cfloop list="#arguments.DDList#" index="DDID">
			<cfset loopCount = loopCount + 1>
			<cfif loopCount LT 10>
				<cfset splitNum = "0#loopCount#">
			<cfelse>
				<cfset splitNum = "#loopCount#">
			</cfif>
			<cfquery name="qGetDDAmount" datasource="#application.datasource#">
				SELECT DD_Amount
				FROM Deductions
				WHERE Deduction_ID = '#DDID#'
			</cfquery>
			<cfquery name="qGetBBInfo" datasource="#application.datasource#">
				SELECT BB.Billback_ID
				FROM Billback BB INNER JOIN BB_Approved BBA ON BBA.Billback_ID = BB.Billback_ID
				WHERE BB.BB_Parent_ID = '#arguments.BBParentID#'
					AND BBA.Paid_Amount = '#qGetDDAmount.DD_Amount#'
					AND BB.BB_Split_Number = '#splitNum#'
					AND BB.Billback_Status_ID <> 5
			</cfquery>
			
			<cfset this.DDMgr.setAssociatedBB(Deduction_ID = DDID,Billback_ID = qGetBBInfo.Billback_ID)>
			
		</cfloop>
	
	</cffunction>

<cffunction name="writeOffDD" access="public" returntype="void" 	output="false" displayname="writeOffDD" hint="">
						
		<cfargument name="Deduction_ID" required="true" type="string">
		<cfargument name="DD_Write_Off_Reason" required="true" type="string">
		
		
		<CFQUERY NAME="UpdateRebill" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	Is_Write_Off = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					Write_Off_By = <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="cf_sql_varchar">,
					Write_Off_Date = getdate(),
					Write_Off_Reason = <cfqueryparam value="#arguments.DD_Write_Off_Reason#" cfsqltype="cf_sql_varchar">
	
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar">
		</CFQUERY>
		
	</cffunction>
	<!--- Ana D19384 - Rebill Integration  --->
	<cffunction name="rebillDD" access="public" returntype="void" output="false" displayname="rebillDD" hint="">

		<cfargument name="Deduction_ID" required="true" type="string">
		<cfargument name="DD_Rebill_Package_Hrd_ID" required="true" type="numeric">
		<cfargument name="Rebill_Message_DF" required="true" type="string">
		<cfargument name="Rebill_Message_AddOn" required="true" type="string">
		<cfargument name="DD_Classification_ID" required="true" type="numeric">
		<cfargument name="DD_Reason_Code_ID" required="true" type="numeric">

		<CFQUERY NAME="DelExist" DATASOURCE="#Application.Datasource#">
			UPDATE 	DD_Rebill_Integration 
			SET 	Deleted = 1
						, Deleted_Date = getdate() 
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar"> 
			AND Deleted = 0
		</CFQUERY>
		
		<CFIF arguments.Rebill_Message_DF NEQ "">
		<CFSET Rebill_Message = "#arguments.Rebill_Message_DF#  #arguments.Rebill_Message_AddOn#">
		</CFIF>
		
		<CFQUERY NAME="InsRebill" DATASOURCE="#Application.Datasource#">
			INSERT 	DD_Rebill_Integration 
					(	Deduction_ID,
						DD_Rebill_Package_Hrd_ID,
						Rebill_Message_DF,
						Rebill_Message_AddOn,						
						DD_Classification_ID,
						DD_Reason_Code_ID,
						Rebill_By,
						Rebill_Ack_Status

					)
			SELECT 	<cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.DD_Rebill_Package_Hrd_ID#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#arguments.Rebill_Message_DF#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.Rebill_Message_AddOn#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#arguments.DD_Classification_ID#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#arguments.DD_Reason_Code_ID#" cfsqltype="cf_sql_numeric">,
					<cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="cf_sql_varchar">			,
					1
		</CFQUERY>
		
		<CFQUERY NAME="UpdateRebill" DATASOURCE="#Application.Datasource#">
			UPDATE 	Deductions
			SET 	DD_Status = <cfqueryparam value="7" cfsqltype="cf_sql_numeric">,
					DD_Classification_ID = <cfqueryparam value="#arguments.DD_Classification_ID#" cfsqltype="cf_sql_numeric">,
					DD_Resolution_Code = <cfqueryparam value="#arguments.DD_Reason_Code_ID#" cfsqltype="cf_sql_numeric">,
					Is_Last_Status_Rebill = <cfqueryparam value="1" cfsqltype="cf_sql_numeric">,
					rebill_date = getdate()		
			WHERE 	Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar">
		</CFQUERY>
		
	</cffunction>
	
		<cffunction name="getIsDeductionAvailableForMatching" access="public" returntype="numeric" output="true" displayname="getCanDeductionsBeMatched">
						
		<cfargument name="Deduction_ID" required="true" type="string">
		
		<!--- Below logic comes from "DEDUCTIONS\search_screens\Ded_Search_Query.cfm".
		The issue is that there are duplicate splits for a deduction. This query will
		not return this deduction, so it cannot be processed more than once.
		--->
		<cfquery name="qGetCanDeductionsBeMatched" datasource="#application.datasource#">
			SELECT count(*) As Dedcount
			FROM Deductions
			WHERE Deduction_ID = <cfqueryparam value="#arguments.Deduction_ID#" cfsqltype="cf_sql_varchar"> AND
			Deductions.DD_Status NOT IN (4,5,6,9) AND 
			<!--- If a deduction (parent or child) is closed (deduction amount matching the billback amount),
			then DD_Closure_ID will not be NULL and so this condition will prevent it from being returned.
			--->
			Deductions.DD_Closure_ID IS NULL AND
			Deductions.Is_Write_Off = 0 AND
			<!--- If a parent deduction is split, then Split_Count will be more than 0, 
			and so this condition will prevent it from being returned. --->
			Deductions.Split_Count = 0
			<!--- If a child deduction(split) is further split, then that child deduction will be set to
			deleted = 1, and so this condition will prevent it from being returned. 
			--->
			AND Deductions.deleted = 0
		</cfquery>

		<cfreturn qGetCanDeductionsBeMatched.Dedcount />
	
	</cffunction>

	<cffunction name="getBBToAssociate" 	access="public" returntype="any" output="true" displayname="getBBToAssociate">
						
		<cfargument name="BBParentID" required="true" type="string">
		<cfargument name="BBAmount" required="true" type="string">
		<cfargument name="splitIndex" required="true" type="numeric">
		
		<cfset loopCount = arguments.splitIndex />
		<cfif loopCount LT 10>
			<cfset splitNum = "0#loopCount#">
		<cfelse>
			<cfset splitNum = "#loopCount#">
		</cfif>
		
		<cfquery name="qGetBBInfo" datasource="#application.datasource#">
			SELECT BB.Billback_ID
			FROM Billback BB INNER JOIN BB_Approved BBA ON BBA.Billback_ID = BB.Billback_ID
			WHERE BB.BB_Parent_ID = '#arguments.BBParentID#'
				AND BBA.Paid_Amount = '#arguments.BBAmount#'
				AND BB.BB_Split_Number = '#splitNum#'
				AND BB.Billback_Status_ID <> 5
		</cfquery>
		
		<cfreturn qGetBBInfo.Billback_ID />
	
	</cffunction>	

	<cffunction name="splitDD" access="public" returntype="array" 	output="false" displayname="splitRemaining" hint="">
		
		<cfargument name="ddID" required="true" type="string">
		<cfargument name="bbID" required="true" type="string">
		<cfargument name="classificationID" required="true" type="numeric">
		<cfargument name="splitReason" required="true" type="string">
		<cfargument name="classificationIDForSplit" required="true" type="numeric">

		<cfscript>
			totalBillbackApprovedAmount = this.BBMgr.getBillbackPaidAmountMulti(billbackIDList = bbID);
			returnArray = this.DDMgr.splitDeduction(
				deductionId = ddID,
				newDeductionAmount = totalBillbackApprovedAmount,
				currentRecordSplitClassificationID = classificationID,
				currentRecordSplitReason = splitReason,
				balanceRecordSplitClassificationID = classificationIDForSplit,
				balanceRecordSplitReason = splitReason);
		</cfscript>
		
		<cfreturn returnArray>
	
	</cffunction>

		<cffunction name="deductionLocking" access="public" returntype="void" output="false" 	displayname="billbackLocking" hint="">
						
		<cfargument name="ddid" required="true" type="string">
		<cfargument name="lock" required="true" type="string">

		<cfif arguments.lock EQ "lock">
			<cfquery name="lockBillback" datasource="#Application.Datasource#">
				UPDATE Deductions
				SET Is_Locked = 1
					,Locked_By = <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="cf_sql_varchar">
					,DD_Locked_By_Match_Central = 1
				WHERE Deduction_ID = <cfqueryparam value="#arguments.ddid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfelse>
			<cfquery name="unLockBillback" datasource="#Application.Datasource#">
				UPDATE Deductions
				SET Is_Locked = 0
					,DD_Locked_By_Match_Central = 0
					,Locked_By = NULL
				WHERE Deduction_ID = <cfqueryparam value="#arguments.ddid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>

	</cffunction>

		<cffunction name="billbackLocking" access="public" returntype="void" 	output="false" displayname="billbackLocking" hint="">
						
		<cfargument name="bbid" required="true" type="string">
		<cfargument name="lock" required="true" type="string">
		
		<cfif arguments.lock EQ "lock">
			<cfquery name="lockBillback" datasource="#Application.Datasource#">
				UPDATE Billback_Allied
				SET BB_Is_Locked = 1
					,BB_Locked_By_User_ID = <cfqueryparam value="#request.AccessStructure.user_id#" cfsqltype="cf_sql_varchar">
					,BB_Lock_Date = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
					,BB_Locked_By_Match_Central = 1
				WHERE Billback_ID = <cfqueryparam value="#arguments.bbid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		<cfelse>
			<cfquery name="unLockBillback" datasource="#Application.Datasource#">
				UPDATE Billback_Allied
				SET BB_Is_Locked = 0
					,BB_Locked_By_Match_Central = 0
				WHERE Billback_ID = <cfqueryparam value="#arguments.bbid#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
	</cffunction>

</cfcomponent>