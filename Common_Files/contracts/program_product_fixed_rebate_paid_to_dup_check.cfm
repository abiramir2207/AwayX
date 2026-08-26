<!---
	Name:          	program_product_fixed_rebate_paid_to_dup_check.cfm
	Copyright:     	Copyright (c) 2011 Blacksmith Applications, Inc.
	Created Date:  	09/23/2011
	Created By:    	Deepa Kunnath
	Description:   	Calls the module that will check for duplicates - list of items inside a program that have fixed price and rebate for different paid to
	Parameters:		Program_ID
	Usage:
--->

<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET Program_ID = cryp.value>

<CFQUERY NAME="getProgramTemplateInfo" datasource="#application.datasource#">
	SELECT  CM.Contract_Number, CM.Contract_Title,
			PCPO.Market_Price,
			PCPO.Item_Fixed_Rebate_Paid_To_Dup_Message,
			CMAD.Market_Price_Approved
	FROM    dbo.Contract_Main CM
	INNER JOIN Contract_Main_Aux_Data CMAD ON
		CMAD.Contract_Main_ID = CM.Contract_Main_ID
	INNER JOIN dbo.Program_Control_Panel_Options PCPO ON 
	        CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
	WHERE CM.Contract_Main_ID = '#Program_ID#'
</CFQUERY>

<cfscript>
	// set defaults 
	thisIsAPopUpWindow 	= 1;
	currentAction 		= "toApprovalPage";
	//default redirect
	profitAnalysisPage = "/Common_Files/Contracts/contract_profit_analysis.cfm?CID=#URL.CID#";
	//if it is an Market Price Program Aand MP is Not approved send to MP approval
	if(getProgramTemplateInfo.Market_Price && !getProgramTemplateInfo.Market_Price_Approved){
		profitAnalysisPage = "/flex/program/MarketPriceFX.cfm?CID=#URL.CID#";
	}
</cfscript>

<cfif getProgramTemplateInfo.Item_Fixed_Rebate_Paid_To_Dup_Message eq "2" or getProgramTemplateInfo.Item_Fixed_Rebate_Paid_To_Dup_Message eq "3">

	<cfset continueURL 		= profitAnalysisPage />
	
	<cfset bDispalyProgramProductsPaidToWithDuplicateDiscountTypesMessage = 0 />
	<cfmodule template="program_product_fixed_rebate_paid_to_dup.cfm"
				Program_ID = #cryp.value#
				Contract_Number = #getProgramTemplateInfo.Contract_Number#
				Contract_Title = #getProgramTemplateInfo.Contract_Title#
				CID = #URL.CID#
				Item_Fixed_Rebate_Paid_To_Dup_Message = #getProgramTemplateInfo.Item_Fixed_Rebate_Paid_To_Dup_Message#
				thisIsAPopUpWindow = 1
				continueURL = #continueURL#
				ReturnVariable="bDispalyProgramProductsPaidToWithDuplicateDiscountTypesMessage"
				/>	
	<cfif bDispalyProgramProductsPaidToWithDuplicateDiscountTypesMessage>
		<cfabort>
	</cfif>

</cfif>

<cflocation  url="#profitAnalysisPage#">
