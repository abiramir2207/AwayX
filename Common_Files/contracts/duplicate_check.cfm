<!------ duplicate_check.cfm ----->
<cfparam name="DuplicateProgramIDList" default="">
<cfparam name="URL.CID" 	default="">
<cfparam name="URL.Mode" 	default="">
<CFPARAM name="duplicateprogram" 				default="false">
<cfparam name="FORM.BUSINESS_CONSIDERATIONS" 	default="">
<CFPARAM name="url.bFromPlannerRFAApprove" 			default="0">
<cfparam name="url.anyStatus" default="0">
<cfparam name="url.plannerId" default="0">
<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET Program_ID = cryp.value>
<cfset FORM.ApproveContract = url.CID>


<CFQUERY NAME="getProgramTemplateInfo" datasource="#application.datasource#">
	SELECT  PCPO.Active,
			PCPO.Deleted,
			PCPO.Check_Duplicate_Program,
			PCPO.Market_Price,
			PCPO.Item_Fixed_Rebate_Paid_To_Dup_Message,
			CM.Parent_Revised_Contract_Main_ID,
			CM.Revision_of_Contract_Main_ID,
			CMAD.Market_Price_Approved,
			PCPO.Disable_Duplicate_Check_For_Revisions,
			PCPO.generic_type,
			PCPO.Pullbacks_On,
			PCPO.is_pullback_corporate_deal
			,CM.ProgramType_ID
	FROM	dbo.Contract_Main CM
	INNER JOIN Contract_Main_Aux_Data CMAD ON
		CMAD.Contract_Main_ID = CM.Contract_Main_ID
	INNER JOIN dbo.Program_Control_Panel_Options PCPO ON
		CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
	WHERE CM.Contract_Main_ID = '#Program_ID#'
</CFQUERY>

<cfif not isDefined("Get_Profile_Settings")>
<cfinclude template="/get_access_profile.cfm" />
</cfif>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset prgManager = CreateObject("component", "components.programs.programManager").init() />

<cfscript>
	// set defaults
	thisIsAPopUpWindow 	= 1;
	currentAction 		= "toApprovalPage";
	checkDuplicateProgram = getProgramTemplateInfo.Check_Duplicate_Program;
	//default redirect
	profitAnalysisPage = "/Common_Files/Contracts/contract_profit_analysis.cfm?CID=#URL.CID#";
	//if it is an Market Price Program Aand MP is Not approved send to MP approval
	if(getProgramTemplateInfo.Market_Price && !getProgramTemplateInfo.Market_Price_Approved){
		profitAnalysisPage = "/Programs/MarketPriceApproval.cfm?CID=#URL.CID#";
	}
	if(getProgramTemplateInfo.Item_Fixed_Rebate_Paid_To_Dup_Message == "2" || getProgramTemplateInfo.Item_Fixed_Rebate_Paid_To_Dup_Message == "3"){
		profitAnalysisPage = "/Common_Files/Contracts/program_product_fixed_rebate_paid_to_dup_check.cfm?CID=#URL.CID#";
	}
	//Recapture multi operator list
	if(appSettings.getPullbacksOn()){
		if(appSettings.get_Setting('Recapture_By_Operator_For_Multiple_Lists') EQ '1' && getProgramTemplateInfo.Pullbacks_On EQ 1 && getProgramTemplateInfo.generic_type EQ "Distributor Trade/Shelter" && getProgramTemplateInfo.is_pullback_corporate_deal EQ 1 && Get_Profile_Settings.View_LH_Pane_Recapture_Link EQ 1) {
			if(prgManager.getIsRecaptureOperatorOnForAnyProgramRebateComponent(Program_ID)){
				profitAnalysisPage = "/Common_Files/Contracts/Pullbacks/pullback_multiple_operator_list.cfm?CID=#URL.CID#&FromApprovalPage=1";
			}
		}
	}
</cfscript>

<CFSET ProgramIsARevision = 0 />
<CFIF len(trim(getProgramTemplateInfo.Parent_Revised_Contract_Main_ID)) NEQ 0 AND len(trim(getProgramTemplateInfo.Revision_of_Contract_Main_ID)) NEQ 0>
	<CFSET ProgramIsARevision = 1 />
</CFIF>

<!--- Dev Note(69720) - If the program is a revision and the template setting does not allow for "duplicate check" for revisions, then do not do "duplicate check". --->
<cfif ProgramIsARevision eq 1 AND getProgramTemplateInfo.Disable_Duplicate_Check_For_Revisions eq 1>
	<cfset checkDuplicateProgram = 0>
	<cfset duplicateprogram = 0>
</cfif>

<cfif checkDuplicateProgram>

	<CFQUERY NAME="GetContractInfo" datasource="#application.datasource#">
		SELECT Contract_Start_Date, Contract_End_Date, Revision_Of_Contract_Main_ID
		FROM Contract_Main
		WHERE Contract_Main_ID = '#Program_ID#'
	</CFQUERY>

	<CFINCLUDE Template="/includes/progress_bar.cfm" />
	<CFINCLUDE Template="duplicate_program_check.cfm" />

	<cfif duplicateprogram EQ "true" OR ListLen(DuplicateProgramIDList) GT 0>
		<!---<cfset profitAnalysisPage = "/Common_Files/Contracts/contract_profit_analysis.cfm?CID=#URL.CID#&duplicateprogram=true" />
		<cfset profitAnalysisPage = "/flex/program/MarketPriceFX.cfm?CID=#URL.CID#&duplicateprogram=true">--->
		<cfset profitAnalysisPage = profitAnalysisPage & "&duplicateprogram=true" />
		<cfset continueURL 		= profitAnalysisPage />
		<cfinclude template="dup_warning_window.cfm" />
		<cfabort>
	<cfelseif duplicateprogram EQ "false" AND URL.Mode EQ "showDup">
		<div align="center">
			<font color="red">
				<strong>THIS PROGRAM IS NOT A DUPLICATE OF AN EXISTING PROGAM</strong>
			</font><br>
			<br>
			 <input type="button" onclick="javascript:window.close();" title="Close window" value="Close window">
		</div>
		<cfabort>
	</cfif>
</cfif>

<cfoutput>
<!------ may not cflocate because of the cfflush we already have ----->
<script language="JavaScript">
	window.open('#profitAnalysisPage#','name','width=1150,height=600,scrollbars=yes');

</script>
</cfoutput>
<cflocation addtoken="No" url="#profitAnalysisPage#" />
