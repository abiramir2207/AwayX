<!------
Get the program lump sum, 2 purpose
- check whether the lump sum cap is met
- check whether the user has lump sum approval rights
----->
<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

<!--- This file is being inclouded from more than one file --->
<cfif IsDefined("getProgramInfo")>
	<cfset templateID = getProgramInfo.ProgramType_ID>
	<cfset CM_ID =	getProgramInfo.Contract_Main_ID>
	<cfset RevisionOfCMID = getProgramInfo.Revision_of_Contract_Main_ID>
	<cfset Contract_Status = getProgramInfo.Contract_Status_Type_IDX>
<cfelseif IsDefined("CSLGetContractInfo")>
	<cfset templateID = CSLGetContractInfo.ProgramType_ID>
	<cfset CM_ID =	CSLGetContractInfo.Contract_Main_ID>
	<cfset RevisionOfCMID = CSLGetContractInfo.Revision_of_Contract_Main_ID>
	<cfset Contract_Status = CSLGetContractInfo.Contract_Status_Type_IDX>
</cfif>

<!--- "messageArray" is being initialized in some other file. --->
<cfif NOT IsDefined("messageArray")>
	<cfset messageArray = ArrayNew(1)>
</cfif>


<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset programLumpSum = templateManager.getLumpSumTotal(templateID,CM_ID)>

<cfset lumpSumAvailableBalance = 0>

<!--------------------------------- Check LumpSum Cap ---------------------------------------------------->
<!------ get the lump sum cap in the latest version of the template ----->
<cfset latestTemplateLumpSumCap = templateManager.getLatestLumpSumCap(templateID)>
<cfset currentLumpSumCapAllocation = 0>
<cfset ParentProgramLumpSum = 0>
<cfset lumpSumAvailableBalance = 0>

<cfif Contract_Status LTE 2 AND isNumeric(latestTemplateLumpSumCap) AND latestTemplateLumpSumCap NEQ 0>
	<cfset currentLumpSumCapAllocation = templateManager.getLumpSumTotal(templateID)>
	<cfif Program_Is_A_Revision>
		<cfset ParentProgramLumpSum = templateManager.getLumpSumTotal(templateID, RevisionOfCMID)>
		<cfset currentLumpSumCapAllocation = currentLumpSumCapAllocation - ParentProgramLumpSum>
	</cfif>
	<cfset lumpSumAvailableBalance = latestTemplateLumpSumCap - currentLumpSumCapAllocation>
	<cfif programLumpSum GT lumpSumAvailableBalance>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "Total #Application.LumpsumLabel# for this program exceeds the available balance (#DollarFormat(lumpSumAvailableBalance)#).")>
	</cfif>

</cfif>


<!--------------------------------- Check LumpSum Cap ---------------------------------------------------->

<!--------------------------------- Check LumpSum Approval Rights ---------------------------------------------------->
<cfset cannotApproveLumpsum = 0 />
<cfif programLumpSum GT 0><!------ If program has lump sum ----->
	<cfif forbidType EQ 0>
		<cfset cannotApproveLumpsum = 1 />
	</cfif>
	<cfset qGetTemplateLumpApproval = templateManager.getProfileForbidTemplate(templateID, forbidType, 3, Get_Profile_Settings.Profiles_id) />
	<cfif qGetTemplateLumpApproval.recordcount GT 0>
		<cfif forbidType EQ 0>
			<cfset cannotApproveLumpsum = 0>
		<cfelse>
			<cfset cannotApproveLumpsum = 1>
		</cfif>
	</cfif>
	<cfif cannotApproveLumpsum eq 1><!------ do not have approve rights for lump sum ----->
			<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "Program template does not allow you to approve #LCase(Application.LumpsumLabel)#.")>
	</cfif>
</cfif>
<!--------------------------------- Check LumpSum Approval Rights ---------------------------------------------------->

<cfif Get_Profile_Settings.program_margin_approval_method IS 5>
	<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />

	<!--- get maximum approvable volume --->
	<cfset annualvolume_CS = Get_Profile_Settings.Max_Approval_Volume>
	<cfset annualvolume_UOM = Get_Profile_Settings.Max_Approval_Volume_Uom>


	<cfelseif Get_Profile_Settings.program_margin_approval_method IS 6>
	<cfset maxlumpsumapproval = Get_Profile_Settings.Lumpsum_Approval_Amount>

	<cfif programLumpSum GT 0>
	<cfif programLumpSum GT maxlumpsumapproval>
			<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "Total #Application.LumpsumLabel# for this program exceeds the approval limits.")>
	</cfif>
	</cfif>

	<!---<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.disposable_program_approval") />--->

</cfif>


<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////// Tim Ford - Label 16888: Check Lump Sum Approval based on Profile Settings /////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->
<cfif appsettings.getApproveLSComponentByProfile()>

	<!---Set the inactive, growth and total Lump Sum approval amounts for this profile--->
	<cfset variables.inActiveApprovalAmount 	= Get_Profile_Settings.Inactive_LS_Approval_Amount>
	<cfset variables.growthApprovalAmount 		= Get_Profile_Settings.Lump_Sum_Approval_Amount>
	<cfset variables.totalLumpSumApprovalAmount	= Get_Profile_Settings.Total_LS_Approval_Amount>

	<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />

	<!---Check whether profile lumpsum amount for any LS component is not set as yet --->
	<cfset variables.qgetLumpsumAmountForProfile 	= ApprovalProgramManager.getLumpsumAmountForProfile(CM_ID, request.Accessstructure.Profiles_ID) />
		<cfloop query="variables.qgetLumpsumAmountForProfile">
			<cfif Approval_Amount eq "" AND Profile_LS_Approval_Program_Lump_Sum_Name_ID eq "">
				<cfset letUserProceed = 0>
				<cfset CannotApproveSettings = 1>
			 <cfset ArrayAppend(messageArray, "You cannot approve since #LCase(Application.LumpsumLabel)# amounts for  #Program_Lump_Sum_Name# is beyond your approval limit of $0.00")>
			</cfif>
		</cfloop>

	<!---Check access amounts set in profiles--->
	<cfset variables.qActiveExceededLSComponents 	= ApprovalProgramManager.getActiveExceededLumpSumComponents(CM_ID, request.Accessstructure.Profiles_ID) />
	<!---Handle for Active Lump Sum Components--->
	<cfif variables.qActiveExceededLSComponents.RecordCount>
		<cfset letUserProceed = 0>
		<cfset CannotApproveSettings = 1>
		<cfloop query="variables.qActiveExceededLSComponents">
			<cfset ArrayAppend(messageArray, "You cannot approve since #LCase(Application.LumpsumLabel)# amounts for #Program_Lump_Sum_Name# is beyond your approval limit of #DollarFormat(Approval_Amount)#")>
		</cfloop>
	</cfif>

	<!---only check inactive appoval amounts if the amount is not "*" --->
	<cfif trim(variables.inActiveApprovalAmount) neq "*">
		<cfset variables.qInActiveExceededLSComponents 	= ApprovalProgramManager.getInActiveExceededLumpSumComponents(CM_ID, variables.inActiveApprovalAmount) />
		<!---Handle for In Active Lump Sum Components--->
		<cfif variables.qInActiveExceededLSComponents.RecordCount>
			<cfset letUserProceed = 0>
			<cfset CannotApproveSettings = 1>
			<cfloop query="variables.qInActiveExceededLSComponents">
				<cfset ArrayAppend(messageArray, "You cannot approve since the total inactive #LCase(Application.LumpsumLabel)# dollars for #Program_Lump_Sum_Name# is beyond your approval limit of #DollarFormat(variables.inActiveApprovalAmount)#")>
			</cfloop>
		</cfif>
	</cfif>

	<!---only check growth appoval amounts if the amount is not "*" --->
	<cfif trim(variables.growthApprovalAmount) neq "*">
		<cfset variables.qGrowthExceededLSComponents 	= ApprovalProgramManager.getGrowthExceededLumpSumComponents(CM_ID, variables.growthApprovalAmount) />
		<!---Handle for Growth Lump Sum Components--->
		<cfif variables.qGrowthExceededLSComponents.RecordCount>
			<cfset letUserProceed = 0>
			<cfset CannotApproveSettings = 1>
			<cfloop query="variables.qGrowthExceededLSComponents">
				<cfset ArrayAppend(messageArray, "You cannot approve since #LCase(Application.LumpsumLabel)# amounts for #Component_Name# is beyond your approval limit of #DollarFormat(variables.growthApprovalAmount)#")>
			</cfloop>
		</cfif>
	</cfif>

	<!---Get the Lump Sum total amounts including the ones from Growth if the appoval amount is not "*"--->
	<cfif trim(variables.totalLumpSumApprovalAmount) neq "*">
		<cfset variables.qGetTotalProgramLumpSumAmount 	= ApprovalProgramManager.getTotalLumpSumAmountWithGrowth(CM_ID) />
		<!---if the total amount exceeds the profile amount then set CannotApproveSettings = 1 and add message to the messageArray--->
		<cfif variables.qGetTotalProgramLumpSumAmount.Total_Lump_Sum_Amount gt variables.totalLumpSumApprovalAmount>
			<cfset letUserProceed = 0>
			<cfset CannotApproveSettings = 1>
			<cfset ArrayAppend(messageArray, "You cannot approve since the total #LCase(Application.LumpsumLabel)# dollars is beyond your approval limit of #DollarFormat(variables.totalLumpSumApprovalAmount)#")>
		</cfif>
	</cfif>

</cfif>
<!--- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////// END Label 16888: Check Lump Sum Approval based on Profile Settings ////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --->