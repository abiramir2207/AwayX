<!---
FILE:
FILENAME: 	Common_Files/contracts/contract_edit_menu.cfm
CREATED: 	??/??/200? - ??
EDITED:		10/15/2008 - RBL [17289 follow up]

FUNCTIONALITY:

DEPENDENCIES:

--->
<CFSET PAGE_TITLE="Program Summary">
<CFSET GROUP="Contracts">

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
<CFIF Get_Profile_Settings.Cont_Prog_View_Create_Program EQ 0>
	<CFLOCATION URL="#application.HomePage#" ADDTOKEN="No">
</CFIF>
<cfif isNumeric(URL.CID)><!---  D49936: rare issue where cid passed in is the real id.  can't re-create so use it. --->
	<cfset cryp = structNew() />
	<cfset cryp.value = URL.CID />
<cfelse>
	<cf_cryp type="de" string ="#URL.CID#" key="#request.key#">
</cfif>
<CFPARAM NAME="FORM.IsCopyProgram" DEFAULT="0">
<cfif isdefined("URL.IsCopyProgram") AND URL.IsCopyProgram EQ "1">
	<cfset FORM.IsCopyProgram = 1 />
</cfif>
<cfif (isDefined ("URL.lockProgram") AND URL.lockProgram EQ 1)>
	<cfset useLakebaseForupdDontAllowEdit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForupdDontAllowEdit>
	<cftry>
		<cfset application.oLakebase.updateRows("contract_main",
			{
				"contract_main_id" = "eq.#cryp.value#"
			},
			{
				"dont_allow_edit" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdDontAllowEdit = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdDontAllowEdit>
<cfquery name="updDontAllowEdit" datasource="#application.datasource#">
		UPDATE Contract_Main
		SET Dont_Allow_Edit = 1
		WHERE Contract_Main_ID = #cryp.value#
	</cfquery>
</cfif>
</cfif>
<!--- D50074 :: Viewing and Editing prior program versions START --->
<cfset ModifyDeletedPrograms = CreateObject("component","components.programs.program").ModifyDeletedProgram(cryp.value,Get_Profile_Settings.Modify_Expired_Programs) />
<!--- D50074 :: Viewing and Editing prior program versions END --->
<!--- D41339: Prod Event 3861 START --->
<cfif len(cryp.value) EQ 0>
	<div align="center" style="font-size:14px; border:solid;border-color:red;border-width:2px;padding:10px;">
		<B>Oops! we were unable to decrypt due to incorrect key, please try again.</B>
	</div>
	<cfabort>
</cfif>
<!--- D41339: Prod Event 3861 END --->
<CFSET URL.Contract_Main_ID = cryp.value>
<cfparam name="URL.inactiveprodpopup" default="0">
<!--- This variable is being passed from "redirect.cfm. It is used to open up the volume window automatically --->
<cfparam name="ShowVolumePage" default="0">
<cfparam name="ShowLSAutoApproveMessage" default="0" />
<cfparam name="IncludeProgressBar" default="0">

<cfset EncrypContractId = URL.CID>

<!--- check to make sure this program is not Deleted = 1. If it is then w need to get the latest version that isn't deleted --->
<cfset useLakebaseForqCheckIfDeleted = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqCheckIfDeleted>
	<cftry>
		<cfset qCheckIfDeleted = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#URL.Contract_Main_ID#",
				"deleted" = "eq.1",
				"select" = "contract_number"
			}), "contract_number"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckIfDeleted = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckIfDeleted>
<cfquery name="qCheckIfDeleted" datasource="#application.datasource#">
	SELECT 	Contract_Number
	FROM 	Contract_Main
	WHERE 	Contract_Main_ID = '#URL.Contract_Main_ID#'
	AND 	Deleted = 1
</cfquery>
</cfif>
<!--- Get latest versions Contract_Main_ID --->
<!---
D50074 :: Viewing and Editing prior program versions
Added code to prevent user redirecting to lastest version when coming from Modify programs link in revision history.
 --->
<cfif ModifyDeletedPrograms EQ 0 AND qCheckIfDeleted.RecordCount>
	<cfset useLakebaseForqGetLatestVersionCMID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetLatestVersionCMID>
	<cftry>
		<cfset qGetLatestVersionCMID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_number" = "eq.#qCheckIfDeleted.Contract_Number#",
				"deleted" = "eq.0",
				"approved" = "eq.1",
				"order" = "revision_version.desc",
				"limit" = "1",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetLatestVersionCMID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetLatestVersionCMID>
<cfquery name="qGetLatestVersionCMID" datasource="#application.datasource#">
		SELECT 	TOP 1 Contract_Main_ID
		FROM 	Contract_Main
		WHERE 	Contract_Number = '#qCheckIfDeleted.Contract_Number#'
		AND 	Deleted = 0
		AND		Approved = 1
		ORDER BY Contract_Main.revision_version DESC
	</cfquery>
</cfif>

	<!--- Then redirect using the new Contract_Main_ID --->
	<cf_cryp type="en" string ="#qGetLatestVersionCMID.Contract_Main_ID#" key="#request.key#">
	<cfset nContractMainId = cryp.value>
	<cflocation url="Contract_Edit_Menu.cfm?CID=#nContractMainId#" />
	<cfabort />
</cfif>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>

	<link rel="stylesheet" type="text/css" href="/common_files/contracts/subModal/subModal.css" />
	<script type="text/javascript" src="/common_files/contracts/subModal/common.js"></script>
	<script type="text/javascript" src="/common_files/contracts/subModal/subModal.js"></script>

	<script type="text/javascript" src="/script/tTip.js"></script>
	<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
	<cf_include files=#arrayToList(["/styles/css-loader.css"])#>
</HEAD>

<BODY id="CED_Body" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<cfset margin_popup_width = application.util.query.get_setting("margin_popup_width", 0)>
<cfif (margin_popup_width eq '')>
	<cfset margin_popup_width = "LG">
</cfif>
<!--- pull in new JS popupCenter2022() function --->
<cfinclude template="/common_files/popup2022.cfm">

<script>
/* popinit() is a function being called on body onload on "contract_status_legend.cfm. Here I am checking for the existence
	 for that function. If it exists, then call both of these functions, else call just the checkpopop function */
document.body.onload = function() {
  if("popupInit"){
		checkpopups();;
		popupInit();
	}
	else
	{
	checkpopups();
	}
	initPopUp();
}

	function checkpopups()
	{
	<cfif url.inactiveprodpopup eq 1>
	ShowInactiveProdPage();
	</cfif>
	}

	function toggleCloseLink()
	{
			document.getElementById('closeActive').style.display = 'none';
			document.getElementById('closeInActive').style.display = 'block';
			document.getElementById('closeInActive').style.cursor = 'pointer';
			// document.getElementById('customContainer').style.display='block';//D51575
	}

	function reloadFromPopUp ( emailFax )
	{
		emailFax = emailFax || 0;
	    show_loader( "PROCESSING REQUEST, PLEASE WAIT...");
		//Construct the current URL
		var currentURL = window.location.pathname + window.location.search;

		// remove existing emailFax parameter in URL
		currentURL = currentURL.replace("&emailFax=0", "");
		currentURL = currentURL.replace("?emailFax=0", "");
		currentURL = currentURL.replace("&emailFax=1", "");
		currentURL = currentURL.replace("?emailFax=1", "");

		currentURL = currentURL + "&emailFax=" + emailFax;
		// Redirect to the current URL
		window.location.href = currentURL;
	}

</script>
<cfset ProgramMarginLog = CreateObject("component","components.programs.MarginLog") />
<cfset MarginLogInfo = ProgramMarginLog.getMarginLogInfo(trim(Contract_Main_ID))>

<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="#Now()#">
<cfset Cache_Control_Header_Already_Added = 1>
<!--- If the Program_margin_log table has no records and we do not have our real progress bar
			at the top of the page already being shown, then show this
--->
<cfif MarginLogInfo[4] eq 0>
		<cfif IncludeProgressBar eq 0>
			<CFINCLUDE template="/includes/call_please_wait.cfm">
		</cfif>
</cfif>
<style>
TABLE.Maintable TD {
	border-bottom:solid #93BEE2 1px;
	font-size : 10px;
}
#header {
	font-size: 12px;
}
#customContainer {
    background-color:#e6e6e6;
    border: 1px solid #CCC;
    box-shadow: 5px 5px 8px #aaaaaa;
    color: black;
    display: none;
    font-weight: bold;
    height: 30px;
    letter-spacing: 0.35px;
    margin-bottom: -2.5%;
    margin-left: 30%;
    text-align: center;
    width: 370px;
}
</style>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx height:15px;background-color:#3498db;padding:6px;color:white;font-size:12px--->

<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release START --->
<span id="customContainer"> <img src="/images/prettyPhoto/default/loader.gif" style="position:relative;top:4px;margin-right:7px"> Processing please wait... </span>
<!--- D51575 :: ‘Please Wait’ Indicator    8.0 Release END --->

<CFSET CSL_Contract_Main_ID = cryp.value>
<CFSET CSL_CallingPageCode = "viewcontract">
<cfparam name="Sent_To_External_Client" default="0">
<cfparam name="group_processed" default="0">
<cfparam name="agreed" default="0">
<cfparam name="parent_program_id" default="">
<cfset showPullbackForm = 0 />
<cfif application.programlayout EQ 1>
	<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 5; left : 10px; top: 0px">
 	<CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
	<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<!------
Include file which checks for the program levels checks to
stop the user from requesting approval and also approval.
----->
<cfset Contract_Main_ID = CSL_Contract_Main_ID>
<cfinclude template="common_program_level_check.cfm">
<cfif isdefined("Var")><cfset var1 =  Var></cfif>
<BLOCKQUOTE><BLOCKQUOTE>
<cfif Not isDefined("var1")>
	<cfsavecontent variable = "var1">
		<CFINCLUDE TEMPLATE="thin_contract_general_display.cfm">
	</cfsavecontent>
</cfif>
<!------
<cfif Get_Profile_Settings.program_margin_approval_method IS 5>
	<cfif CSLGetContractInfo.Contract_Status_Type_IDX EQ 2>
		<cfset ApprovalProgramManager = CreateObject("component","components.programs.Approval.layered_program_approval") />
		<cfset getagreedprogramtypecodes = ApprovalProgramManager.getagreedprograms(CSL_Contract_Main_ID,request.AccessStructure.user_id)>
		<CFIF getagreedprogramtypecodes.RECORDCOUNT eq 0>
			<cfif ApprovalProgramManager.getAnyProgramProducts(CSL_Contract_Main_ID)>
				<cfset agreed = 1>
			</cfif>
		</CFIF>
	</cfif>
</cfif>
----->



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- This section handles the contract Approval								 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Display The Appropriate Status --->
<CFSET StatusDisplay_CELLSPACING	= 4>
<CFSET StatusDisplay_CELLPADDING	= 0>
<CFSET StatusDisplay_FONTCOLOR		= "white">
<CFSET StatusDisplay_CELLBGCOLOR	= "green">

<cfset APVL_Contract_Status = CSLGetContractInfo.Contract_Status_Type_IDX>

<cfset oProgram = CreateObject("component", "components.programs.program") />
<cfset objRebateComponent = CreateObject("component", "components.programs.rebates.RebateComponent") />
<cfset qGetProgramUserSettings = oProgram.getProgramUserSettings() />



<CFSWITCH EXPRESSION="#APVL_Contract_Status#">
	<CFCASE VALUE="1">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Work In Progress">
		<CFELSE>
			<cfif IsLimitedRevise>
				<cfset StatusDisplay_DisplayText = "Limited Revision In Progress">
			<cfelse>
				<CFSET StatusDisplay_DisplayText	= "Revision In Progress">
			</cfif>
		</CFIF>

		<CFSET StatusDisplay_BGCOLOR		= "gray">
		<CFSET StatusDisplay_CELLBGCOLOR	= "gray">
		<cfoutput>
		<SCRIPT>
			//D44999 :: Max Rate Approval Workflow START
			function ezRatesCheck(){
				   window.open("ez_Rate_check.cfm?CID=<cfoutput>#EncrypContractId#</cfoutput>", "ezRatesCheck", "toolbar=0, scrollbars=1, resizable=0, top=200, left=200, width=700, height=420");
			}
			//D44999 :: Max Rate Approval Workflow END
			function confirmApproval() {
			<cfset ShowLSAutoApproveMessage = 0>
			<cfif appsettings.getDistributor_Product_Integrity_On()  AND len(trim(getSettings.Distributor_Product_Integrity_Rule_ID)) GT 0>

				<cfset RestrictOnRule = 0>


				<cfset useLakebaseForGetIntegrityRuleType = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("distributor_product_integrity_rule")>
				<cfif useLakebaseForGetIntegrityRuleType>
					<cftry>
						<cfset GetIntegrityRuleType = application.oLakebase.toQuery(
							application.oLakebase.selectRows("distributor_product_integrity_rule", { "distributor_product_integrity_rule_id" = "eq.#getSettings.Distributor_Product_Integrity_Rule_ID#", "select" = "distributor_product_integrity_rule_id,inclusive_restriction,rule_name,error_msg" })
						)>
						<cfcatch type="any">
							<cfset useLakebaseForGetIntegrityRuleType = false>
						</cfcatch>
					</cftry>
				</cfif>
				<cfif NOT useLakebaseForGetIntegrityRuleType>
					<cfquery name="GetIntegrityRuleType" datasource="#application.datasource#">
					SELECT Distributor_Product_Integrity_Rule_ID, Inclusive_Restriction, Rule_Name, Error_Msg
					FROM Distributor_Product_Integrity_Rule
					WHERE Distributor_Product_Integrity_Rule_ID = #getSettings.Distributor_Product_Integrity_Rule_ID#
					</cfquery>
				</cfif>

				<cfquery name="DoItemsPassRule" datasource="#application.datasource#">
				SELECT count(Contract_Products.BSA_Foodservice_Items_Master_ID) AS ProductCount
				FROM Contract_Products
					INNER JOIN Distributor_Product_Integrity_Products
					ON Distributor_Product_Integrity_Products.Product_ID = Contract_Products.BSA_Foodservice_Items_Master_ID
					AND Distributor_Product_Integrity_Products.Deleted = 0
					AND Distributor_Product_Integrity_Products.Distributor_Product_Integrity_Rule_ID = '#GetIntegrityRuleType.Distributor_Product_Integrity_Rule_ID#'
				WHERE Contract_Products.Contract_Main_ID = '#Contract_Main_ID#'
				AND Contract_Products.Deleted = 0
				</cfquery>

				<cfset ItemNumbers = DoItemsPassRule.ProductCount>

				<cfquery name="DoDistributorsPassRule" datasource="#application.datasource#">
				SELECT count(Contract_Distributors.BSA_Foodservice_Customers_ID) AS DistributorCount
				FROM Contract_Distributors
					INNER JOIN Distributor_Product_Integrity_Distributors
					ON Distributor_Product_Integrity_Distributors.Distributor_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
					AND Distributor_Product_Integrity_Distributors.Deleted = 0
					AND Distributor_Product_Integrity_Distributors.Distributor_Product_Integrity_Rule_ID = '#GetIntegrityRuleType.Distributor_Product_Integrity_Rule_ID#'
				WHERE Contract_Distributors.Contract_Main_ID = '#Contract_Main_ID#'
				AND Contract_Distributors.Deleted = 0
				</cfquery>

				<cfset DistributorNumbers = DoDistributorsPassRule.DistributorCount>

				<!--- There must be at least one distributor or one item on the rule --->
				<cfif GetIntegrityRuleType.Inclusive_Restriction IS 0>

					<cfif DistributorNumbers EQ 0 OR ItemNumbers EQ 0>
						<cfset RestrictOnRule = 1>
					</cfif>

					<!--- All products and distributors must be on rule --->
				<cfelseif GetIntegrityRuleType.Inclusive_Restriction IS 1>

					<cfquery name="GetProductCount" datasource="#application.datasource#">
					SELECT count(Contract_Products.BSA_Foodservice_Items_Master_ID) as ProgramProductCount
					FROM Contract_Products
					WHERE Contract_Main_ID = '#Contract_Main_ID#'
					AND Deleted = 0
					</cfquery>

					<cfset ProgramProductCount = GetProductCount.ProgramProductCount>

					<cfquery name="GetDistributorCount" datasource="#application.datasource#">
					SELECT count(Contract_Distributors.BSA_Foodservice_Customers_ID) as ProgramDistributorCount
					FROM Contract_Distributors
					WHERE Contract_Main_ID = '#Contract_Main_ID#'
					AND Deleted = 0
					</cfquery>

					<cfset ProgramDistributorCount = GetDistributorCount.ProgramDistributorCount>

					<Cfif ProgramDistributorCount NEQ DistributorNumbers OR ProgramProductCount NEQ ItemNumbers>
						<cfset RestrictOnRule = 1>
					</CFIF>

				</cfif>

				<cfif RestrictOnRule IS 1>
					alert("#GetIntegrityRuleType.Error_Msg#")
					return false;
				</cfif>

			</cfif>

			<cfquery name="GetAutoPayLS" datasource="#application.datasource#">
			SELECT	Program_Lump_Sums.Program_Lump_Sum_ID,
					Program_Lump_Sums.Split_For_Auto_Pay
			FROM 	Program_Lump_Sums
				INNER JOIN Payment_Type
				ON 	Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
				AND	Payment_Type.Is_Auto_Pay = 1
			WHERE 	Program_Lump_Sums.Program_ID = '#Contract_Main_ID#'
				AND	Program_Lump_Sums.Deleted = 0
			</cfquery>

			<cfif GetAutoPayLS.Recordcount GT 0>
				<cfset ShowLSAutoApproveMessage = 1>
			</cfif>

			<cfset bPayeeNotOnProgram = 0>
			<cfif appSettings.getBBAutoReport()>
				<cfset bPayeeNotOnProgram = objRebateComponent.IsPayeeNotOnProgramForAutoPayRebate(Contract_Main_ID)>
			</cfif>
			<!--- Dev Note (43235) - Check if payee and distributor(s) on the program are in sync. --->
			<cfif bPayeeNotOnProgram eq 1>
					if (confirm('Be advised that the Payee and Distributor(s) on the program are not in sync. Do you want to continue?  (OK = Yes   Cancel = No)')) {
					    // Do nothing!
					}
					else {
						document.all.ApproveContractButton.checked=false;
						/* Do not let the user proceed for RFA. */
						return false;
					}
			</cfif>

			<cfif ShowLSAutoApproveMessage IS 1>
					<cfif variables.bShowRFA>
						alert("Please note: this program has a lump sum created as an auto payment. When this program is approved, that lump sum will immediately be released for payment.");
					<cfelse>
						//alert("Please Select a Payee (Operator, Distributor, or Broker) before Requesting Approval.");
						//document.all.ApproveContractButton.checked = false;
						//return false;
					</cfif>
			</cfif>

<!---D43479	:: When Qualifications are turned ON - validate q's with answers req'd are filled out prior to RFA & Approval.START --->
	<cfif CSLGetContractInfo.Enable_Program_Qualifications>

		<cfset useLakebaseForCheckProgramQualificationsRequired = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qualification_template_mapping")>
<cfif useLakebaseForCheckProgramQualificationsRequired>
	<cftry>
		<cfset CheckProgramQualificationsRequired = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qualification_template_mapping", {
				"template_id" = "eq.#CSLGetContractInfo.ProgramType_ID#",
				"answer_required" = "eq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckProgramQualificationsRequired = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckProgramQualificationsRequired>
<cfquery name="CheckProgramQualificationsRequired" datasource="#application.datasource#">
		 	SELECT *
			FROM  Qualification_Template_Mapping
			WHERE Template_Id = #CSLGetContractInfo.ProgramType_ID#
			AND Answer_Required = 1
		</cfquery>
</cfif>

<cfif CheckProgramQualificationsRequired.recordcount>
		<cfquery name="CheckProgramQualifications" datasource="#application.datasource#">
		 	SELECT *
			FROM Program_Qualifications_Info
			WHERE Program_ID = #CSLGetContractInfo.contract_main_id#
			AND Program_Qualification_ID = <cfqueryparam value="#CheckProgramQualificationsRequired.Program_Qualification_ID#" cfsqltype="cf_sql_varchar" list="yes"/>
		</cfquery>

			<cfif CheckProgramQualifications.recordcount EQ 0 >
				alert("Qualifications must be completed before moving forward.")
				document.getElementById("ApproveContractButton").checked = false;
				return false;
			</cfif>
</cfif>

	</cfif>
<!---D43479	:: When Qualifications are turned ON - validate q's with answers req'd are filled out prior to RFA & Approval.END --->

<!---D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release START--->
<cfif appSettings.GetProgramAlertOnRFARate0()>
	<cfquery name="RebateRateCheck" datasource="#application.datasource#">
		SELECT	Count(Program_Rebates_Component_Data.rate) AS rate
		FROM	Contract_Products
		INNER JOIN Program_Rebates_Product_Data PRPD
		ON	PRPD.Contract_Products_ID = Contract_Products.Contract_Products_ID
		AND	PRPD.Deleted = 0
		INNER JOIN Program_Rebates_Component_Data
		ON	Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
		AND	Program_Rebates_Component_Data.Deleted = 0
		INNER JOIN Program_Rebates_Component
		ON	Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
		AND	Program_Rebates_Component.Deleted = 0
		WHERE	Contract_Products.Contract_Main_ID = '#Contract_Main_ID#'
		AND 	Contract_Products.product_Type_ID = 2
		AND 	Contract_Products.Deleted = 0
		AND		Cast(Program_Rebates_Component_Data.rate as float) = 0
	</cfquery>

	<cfquery name="FixedRateCheck" datasource="#application.datasource#">
		SELECT	Count(Program_Fixed_Price_Product_Data.Fixed_Price_Value) rate
		FROM	Contract_Products
		INNER JOIN	dbo.Program_Fixed_Price_Product_Data
		ON Program_Fixed_Price_Product_Data.Contract_Products_ID = Contract_Products.Contract_Products_ID
		AND Program_Fixed_Price_Product_Data.Deleted = 0
		WHERE Contract_Products.Deleted = 0
		AND	  Contract_Products.Contract_Main_ID = '#Contract_Main_ID#'
		AND   Contract_Products.product_type_id =1
		AND	  Cast(Program_Fixed_Price_Product_Data.Fixed_Price_Value as float) = 0
	</cfquery>

	<cfif RebateRateCheck.rate OR FixedRateCheck.rate>
		if (confirm("This program has items with a $0 rate.  Please confirm this is okay") == false) {
			document.getElementById("ApproveContractButton").checked = false;
	        return false;
	    }
	</cfif>
</cfif>
<!---D50884 :: Improvements to the Rebate Page inside a Program 8.0 Release END--->


			<!------ If user cannot continue, show the message ----->
			<cfif letUserProceed EQ 0>
				var sMsg = "";
				<cfloop index="i" from="1" to="#ArrayLen(messageArray)#">
					sMsg = sMsg + "#messageArray[i]#\n";
				</cfloop>
				alert(sMsg);
				document.all.ApproveContractButton.checked = false;
			<CFELSE>
				var ConfirmMessage = "Are you sure you want this program to be ready for approval?";
			<!--- 	check if pullbacks on and if it is an opr or dis local program,and if pullbacks are not applied on distributors, prompt the user if he want to apply pullback rules --->
				<cfif appSettings.getPullbacksOn()>
				<CFIF
					(
						(GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.Pullbacks_On EQ 1 and GetSettings.is_pullback_corporate_deal EQ 0 	and GetSettings.pullback_from_corporate EQ 1)
					OR 	(GetSettings.generic_type EQ "Operator Direct or HQ Programs" OR GetSettings.generic_type EQ "Operator-Deviated Pricing")
					)
					and GetSettings.Pullbacks_On EQ 1 and CSLGetContractInfo.applied_pullbacks NEQ 1 and Get_Profile_Settings.Approve_Pullback EQ 1
					and qGetProgramUserSettings.Pullback_Modify_Operator_Program_Rates EQ 1>
					<cfset showPullbackForm = 1 />
					if(confirm("Do you want to apply <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> rates?"))
					{
						document.getElementById('customContainer').style.display='block';//D51575
						document.all.PullbackForm.submit();
						return false;
					}
				</CFIF>

				</cfif>
  		  document.all.ApproveContractButton.disabled = true;
		  // D48315 :: Reduce Business Consideration auto pop-ups---- 8.0 Release ONLY
				<cfif appSettings.getbusinessconsiderations_on() and Get_Profile_Settings.Internal_Notes eq 1 AND (CSLGetContractInfo.Creator_ID NEQ request.AccessStructure.user_id OR appSettings.get_Setting('Business_Considerations_All_Time') eq '1')>
					NewWindowTopLeft('evaluationnotes.cfm?MODE=5&NoteType=2&Formname=BrokerApprovalForm&CID=<cfoutput>#EncrypContractId#</cfoutput>','EvaluationNotes','1050','600','yes', 'no');
				<cfelse>
					document.getElementById('customContainer').style.display='block';//D51575
					document.all.BrokerApprovalForm.submit();
				</cfif>
			</CFIF>
			}
		</SCRIPT>
		</cfoutput>
	</CFCASE>
	<CFCASE VALUE="2">
 		<CFIF IsRollOver EQ 1>
			<CFSET StatusDisplay_DisplayText	= "Roll-Over Ready For Approval">
		<CFELSEIF  Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Ready For Approval">
		<CFELSE>
			<cfif IsLimitedRevise>
				<cfset StatusDisplay_DisplayText = "Limited Revision Ready For Approval">
			<cfelse>
				<CFSET StatusDisplay_DisplayText	= "Revision Ready For Approval">
			</cfif>
		</CFIF>
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
		<SCRIPT>
			function confirmApproval()
			{
  			<cfquery name="GetAutoPayLS" datasource="#application.datasource#">
				SELECT	Program_Lump_Sums.Program_Lump_Sum_ID,
						Program_Lump_Sums.Split_For_Auto_Pay
				FROM 	Program_Lump_Sums
					INNER JOIN Payment_Type
					ON 	Payment_Type.Payment_Type_ID = Program_Lump_Sums.Claim_Mechanics
					AND	Payment_Type.Is_Auto_Pay = 1
				WHERE 	Program_Lump_Sums.Program_ID = '#Contract_Main_ID#'
					AND	Program_Lump_Sums.Deleted = 0
				</cfquery>

				<cfif GetAutoPayLS.Recordcount GT 0>
					<cfset ShowLSAutoApproveMessage = 1>
				</cfif>

				<cfif ShowLSAutoApproveMessage IS 1>
					<cfif variables.bShowRFA>
						alert("Please note: this program has a lump sum created as an auto payment. When this program is approved, that lump sum will immediately be released for payment.");
					<cfelse>
						//alert("Please Select a Payee (Operator, Distributor, or Broker) before Approval.");
						//return false;
					</cfif>
				</cfif>

				<!---TSF: Label 10305 - Handle for any min/max template volume rule error messages from common_program_level_check.cfm --->
				<cfif isDefined("variables.alertMessageOnApprove")>
					alert("<cfoutput>#variables.alertMessageOnApprove#</cfoutput>");
					return false;
				</cfif>
			<!---(Start) Count the number of components and do not allow to approve if more than one component exists (if pullbacks and corporate deal are on) (Milan - 9956) --->
				<CFIF appSettings.getAllowOneComponentforPullbacks() EQ 1 AND GetSettings.Pullbacks_On EQ 1 AND GetSettings.is_pullback_corporate_deal EQ 1>
					<cfstoredproc procedure="Component_Number_Count" datasource="#application.datasource#">
						<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@PROGRAM_ID" value="#Contract_Main_ID#" null="no">
						<cfprocparam type = "Out" CFSQLType ="CF_SQL_INTEGER" variable="NumberOfComponents" dbVarName = "@ComponentCount" null="no">
					</cfstoredproc>
					<CFIF NumberOfComponents GT 1>
							alert("Due to potential <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>, only one component is allowed for this program type. Please remove all but one before requesting approval");
							return false;
					</CFIF>
				</CFIF>
			<!--- (End) Count the number of components and do not allow to approve if more than one component exists (Milan - 9956) --->

			<cfif appSettings.getPullbacksOn()>
				<CFIF 	(
							<!--- corporate program --->
							(GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.is_pullback_corporate_deal EQ 1 and CSLGetContractInfo.Pullback_From_This_Program EQ 1 and qGetProgramUserSettings.Pullback_Modify_Corporate_Program_Rates EQ 1)
					 		OR
					 		<!--- operator/distributor program --->
					 		(
						 		(
									(GetSettings.generic_type EQ "Operator Direct or HQ Programs" OR GetSettings.generic_type EQ "Operator-Deviated Pricing")
									OR
									(GetSettings.generic_type EQ "Distributor Trade/Shelter" and GetSettings.is_pullback_corporate_deal EQ 0 and GetSettings.pullback_from_corporate EQ 1)
								) AND qGetProgramUserSettings.Pullback_Modify_Operator_Program_Rates EQ 1
							)
						)
						and GetSettings.Pullbacks_On EQ 1 and Get_Profile_Settings.Approve_Pullback EQ 1>

						<cfset showPullbackForm = 1 />
						showPopWin('/Common_files/Contracts/Clawback_Choice_Form.cfm', 520, 150, null);

				<CFELSE>
					confirmApprovalNext();
				</CFIF>
			<cfelse>
				confirmApprovalNext();
			</cfif>

			}
			function editClawbacks(choice){
					if(choice==1){
						<Cfif GetSettings.generic_type EQ "Distributor Trade/Shelter">
						document.all.PullbackForm.FromDistributor_Prg.value = 1;
						</CFIF>
						document.all.PullbackForm.submit();
					}
					else{confirmApprovalNext();}
				}
			function confirmApprovalNext(){
			// D48315 :: Reduce Business Consideration auto pop-ups---- 8.0 Release ONLY
			<cfif appSettings.getDisplayEvaluationNotes() AND (CSLGetContractInfo.Broker_User_ID NEQ request.AccessStructure.user_id OR appSettings.get_Setting('Business_Considerations_All_Time') eq '1')>
					NewWindowTopLeft('evaluationnotes.cfm?MODE=2&NoteType=1&Formname=BrokerApprovalForm&CID=<cfoutput>#EncrypContractId#</cfoutput>','EvaluationNotes','1050','600','Yes', 'Yes');
			<cfelseif appSettings.getbusinessconsiderations_on() and Get_Profile_Settings.Internal_Notes eq 1 AND (CSLGetContractInfo.Broker_User_ID NEQ request.AccessStructure.user_id OR appSettings.get_Setting('Business_Considerations_All_Time') eq '1')>
				<cfif appSettings.getRequire_Business_Considerations_On_New_Programs() AND CSLGetContractInfo.is_a_revision EQ 0>
					NewWindowTopLeft('evaluationnotes.cfm?MODE=2&EDIT=1&NoteType=2&Formname=BrokerApprovalForm&CID=<cfoutput>#EncrypContractId#</cfoutput>','EvaluationNotes','1050','600','Yes', 'Yes');
				<cfelse>
					NewWindowTopLeft('evaluationnotes.cfm?MODE=2&EDIT=0&NoteType=2&Formname=BrokerApprovalForm&CID=<cfoutput>#EncrypContractId#</cfoutput>','EvaluationNotes','1050','600','Yes', 'Yes');
				</cfif>
			<cfelse>
				<cfif appSettings.getpaymenthistoryon() and CSLGetContractInfo.is_a_revision EQ 1 AND Get_Profile_Settings.payment_history_alert EQ 1>
					if(confirm("Review Settlement History")){
						NewWindowTopLeft('/common_files/contracts/view_contract_payment_history.cfm?ContractId=<cfoutput>#CSLGetContractInfo.contract_main_id#</cfoutput>&approval=1','paymenthistorywindow','1150','620','Yes', 'Yes');
					}else{
						NewWindowTopLeft('/clause_library/clause_approval.cfm?CID=<cfoutput>#EncrypContractId#</cfoutput>','name','1150','800','Yes', 'Yes');
				
					}
				<cfelse>
					NewWindowTopLeft('/clause_library/clause_approval.cfm?CID=<cfoutput>#EncrypContractId#</cfoutput>','name','1150','800','Yes', 'Yes');
				
			</cfif>
			</cfif>
			}

		</SCRIPT>
	</CFCASE>

	<CFCASE VALUE="3">
		<CFSET StatusDisplay_DisplayText	= "Approved">
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
	</CFCASE>

	<CFCASE VALUE="4">
		<CFSET StatusDisplay_DisplayText	= "Pre Active">
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
	</CFCASE>


	<CFCASE VALUE="5">
		<CFIF Program_Is_A_Revision EQ 0>
			<CFSET StatusDisplay_DisplayText = "Active">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText = "Active Revision">
		</CFIF>

		<CFSET StatusDisplay_BGCOLOR = "Green">
	</CFCASE>

	<CFCASE VALUE="6">
		<CFSET DayCount = datediff('d', dateformat(now(), 'm/d/yyy'), dateformat(CSLGetContractInfo.Contract_End_Date, 'm/d/yyy'))>
		<CFSET Temp = " Day">
		<cfif DayCount GT 1><CFSET Temp = " Days"></cfif>

		<CFIF DayCount EQ 0>
			<CFSET StatusDisplay_DisplayText	= "Will Expire Today">
		<CFELSE>
			<CFSET StatusDisplay_DisplayText	= "Expires In " & DayCount & Temp>
		</CFIF>


		<CFSET StatusDisplay_BGCOLOR		= "Red">
		<CFSET StatusDisplay_CELLBGCOLOR	= "Red">
	</CFCASE>

	<CFCASE VALUE="7">
		<CFSET StatusDisplay_DisplayText	= "Expired">
		<CFSET StatusDisplay_BGCOLOR		= "black">
		<CFSET StatusDisplay_CELLBGCOLOR	= "black">
	</CFCASE>
	<CFCASE VALUE="8">
		<CFSET StatusDisplay_DisplayText	= "Rejected/Lost">
		<CFSET StatusDisplay_BGCOLOR		= "red">
		<CFSET StatusDisplay_CELLBGCOLOR	= "red">
	</CFCASE>
	<CFCASE VALUE="10">
		<CFSET StatusDisplay_DisplayText	= "Pending Accept">
		<CFSET StatusDisplay_BGCOLOR		= "green">
		<CFSET StatusDisplay_CELLBGCOLOR	= "white">
		<CFSET StatusDisplay_FONTCOLOR		= "green">
	</CFCASE>

	<cfdefaultcase>
      <cfscript>
            StatusDisplay_DisplayText = "";
            StatusDisplay_BGCOLOR     = "white";
            StatusDisplay_CELLBGCOLOR = "white";
            StatusDisplay_FONTCOLOR   = "black";
      </cfscript>
</cfdefaultcase>

</CFSWITCH>
<!--- if the program is a revision than the rules about templates does not apply to this program  --->
<CFIF Program_Is_A_Revision EQ 1 AND IsProgramTemplateAvailable EQ 0>
	<CFSET IsProgramTemplateAvailable = 1>
</CFIF>


<!--- if the template for this program is inactive than let the user know  --->
<CFIF IsProgramTemplateAvailable EQ 0>
		<CFSET StatusDisplay_DisplayText	= "Program Template Is Inactive">
		<CFSET StatusDisplay_BGCOLOR		= "Orange">
		<CFSET StatusDisplay_CELLBGCOLOR	= "Orange">
		<CFSET StatusDisplay_FONTCOLOR		= "Yellow">
</CFIF>
<CFOUTPUT>
<cfif user_acess_approval_tabs EQ 0>
	  		<div id="Layer4" style="position:relative; width:700px; z-index:1; left: 100px; top: 20px;">
		<font color="red" size = "2"><b>You cannot agree/approve this program
		while the program is being modified by "#modifyingusername#".</b></font>
	  </div>
</cfif>
	<cfif application.programlayout EQ 1>
		<div id="Layer1" style="position:relative; width:200px; z-index:1; left: 100px; top: 40px;">
	 </cfif>


<!---
<table width="710" border="0" cellspacing="0" cellpadding="0">
</table>
--->

	<TABLE
		BORDER="0"
		CELLSPACING="#StatusDisplay_CELLSPACING#"
		CELLPADDING="#StatusDisplay_CELLPADDING#"
		WIDTH="750"
		BGCOLOR="#StatusDisplay_BGCOLOR#">
	<TR>
		<TD BGCOLOR="#StatusDisplay_CELLBGCOLOR#" WIDTH="100%">
			<FONT COLOR="#StatusDisplay_FONTCOLOR#" SIZE="3"><B>#application.util.string.fCase(StatusDisplay_DisplayText)#</B></FONT>
	<!--- Move between child (Date exclusion) and parent programs --->
			<cfif GetSettings.Date_Exclusions_ON EQ 1>
				<cfif CSLGETCONTRACTINFO.IsExclusionRevision EQ 1>
				<br /><FONT COLOR="#StatusDisplay_FONTCOLOR#">This is a Date Exclusion program.
				 Click <a href="contract_edit_menu.cfm?CID=#Parent_Program_ID#">here</a> to go to the Parent Program</FONT>
				 <cfelse>
				 <cfif ListLen(ChildProgramIDList) neq 0>
					 <br />
					 <FONT COLOR="#StatusDisplay_FONTCOLOR#">Go to Date Exclusion Program Number
					 [
					 <cfloop from="1" to="#ListLen(ChildProgramIDList)#" index="IDNumber">

						  <a href="contract_edit_menu.cfm?CID=#Child_Program_ID[IDNumber]#">#IDNumber#</a>&nbsp;
					 </cfloop>
					 ]
					 </FONT>
				 </cfif>
				</cfif>
			</cfif>
		</TD>

		<!------ Find if there are any Rate UOM changes in this program, if so diaply message ----->
		<cfif CreateObject("component", "components.programs.products.ProgramProductRateUOMChangeManager").checkUOMChanged(CSL_Contract_Main_ID)>
		<TD TITLE="some of the products in this program have a rate unit of measure change... click to see details..." ALIGN="right" BGCOLOR="Red" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor:pointer;" ONCLICK="NewWindow('Program_Product_Rate_UOM_Change.cfm?Program_ID=#URL.Contract_Main_ID#','name','1150','650','Yes', 'Yes')">
		&nbsp;UOM change&nbsp;
		</TD>
		</cfif>


<!------ Get volume Info ----->
<!------ Program_Volume is already loaded in thin contract general display ----->
<cfif NOT isDefined("Program_Volume")>
	<CFSET Program_Volume = CreateObject("component", "components.programs.volume.ProgramVolume")>
	<CFSET Program_Volume.Load_Basic_Information(URL.Contract_Main_ID, request.AccessStructure.Company_Main_ID)>
</cfif>

<!--- If "Date_Exclusions_ON" is enabled,Pass all the Program IDs
		(including the date exclusion program id's) --->
<cfif GetSettings.Zero_Volume IS NOT 1>
	<cfif GetSettings.Date_Exclusions_ON EQ 1>
		<CFSET Volume_Good = Program_Volume.Check_Any_NULL_Volume(ContractIDs)>
	<cfelse>
		<CFSET Volume_Good = Program_Volume.Check_Any_NULL_Volume()>
	</cfif>

<cfelse>
	<cfset Volume_Good = true>
</cfif>

<cfif isDefined("Program_Volume.Volume_Packet_Builder")>
	<CFSET volumePacket = Program_Volume.Volume_Packet_Builder.volumePacket>
</cfif>

<CFSET VolumeTitle = "Apply volume for products">
<CFSET VolumeForecastTitle = "">
<CFIF NOT Volume_Good>
	<CFSET VolumeTitle = "Automatically apply volume for products">
	<CFSET Null_Vol_Prod_Count = Program_Volume.Null_Volume_Products.recordCount>
	<CFSET VolumeTitle = ListAppend(VolumeTitle, "- #Null_Vol_Prod_Count# product#IIF(Null_Vol_Prod_Count GT 1, DE('s'), DE(''))# does not have proper volume", "#chr(13)#")>
</CFIF>

<CFSET Forecast_Good = true>

<cfset showVolume = true>
<cfif isDefined("Program_Volume.Volume_Packet_Builder") and ArrayLen(volumePacket.products) LTE 0 and programManager.programHasGroups(URL.Contract_Main_ID) neq 1>
	<cfset showVolume = false>
	<cfset noProductMsg = "There are no products selected">
	<CFSET VolumeTitle = noProductMsg>
</cfif>


<!---
<CFIF isDefined("Program_Volume.Volume_Packet_Builder")  and Program_Volume.Can_Do_Forecast AND volumePacket.forecastInfo.priorForecast>
	<CFIF volumePacket.proudctsNotInForecast GT 0>
		<CFSET VolumeForecastTitle = ListAppend(VolumeForecastTitle, "- There #IIF(volumePacket.proudctsNotInForecast GT 1, DE('are'), DE('is'))# #volumePacket.proudctsNotInForecast# product#IIF(volumePacket.proudctsNotInForecast GT 1, DE('s'), DE(''))# that exist in the program but does not exist in the recent forecast", "#chr(13)#")>
		<CFSET Forecast_Good = false>
	</CFIF>
	<CFIF volumePacket.distributorsNotInAppArea GT 0>
		<CFSET VolumeForecastTitle = ListAppend(VolumeForecastTitle, "- There #IIF(volumePacket.distributorsNotInAppArea GT 1, DE('are'), DE('is'))# #volumePacket.distributorsNotInAppArea# #IIF(volumePacket.distributorsNotInAppArea GT 1, DE(LCase(application.returned_customer_setting.distributor_label_plural)), DE(LCase(application.returned_customer_setting.distributor_label_singular)))# who exist in the recent forecast but does not exist in the program", "#chr(13)#")>
		<CFSET Forecast_Good = false>
	</CFIF>
	<CFIF volumePacket.distributorsNotInForecast GT 0>
		<CFSET VolumeForecastTitle = ListAppend(VolumeForecastTitle, "- There #IIF(volumePacket.distributorsNotInForecast GT 1, DE('are'), DE('is'))# #volumePacket.distributorsNotInForecast# #IIF(volumePacket.distributorsNotInForecast GT 1, DE(LCase(application.returned_customer_setting.distributor_label_plural)), DE(LCase(application.returned_customer_setting.distributor_label_singular)))# who exist in the program but does not exist in the recent forecast", "#chr(13)#")>
		<CFSET Forecast_Good = false>
	</CFIF>
	<CFIF isDate(volumePacket.forecastInfo.appAreaStartDate) AND IsDate(volumePacket.forecastInfo.appAreaEndDate)>
		<CFIF DATEDIFF("d", volumePacket.forecastInfo.appAreaStartDate, volumePacket.appAreaStartDate) NEQ 0 OR DATEDIFF("d", volumePacket.forecastInfo.appAreaEndDate, volumePacket.appAreaEndDate) NEQ 0>
			<CFSET VolumeForecastTitle = ListAppend(VolumeForecastTitle, "- The delivery period during last forecast was #DateFormat(volumePacket.forecastInfo.appAreaStartDate, "mm/dd/yyyy")# - #DateFormat(volumePacket.forecastInfo.appAreaEndDate, "mm/dd/yyyy")#", "#chr(13)#")>
			<CFSET Forecast_Good = false>
		</CFIF>
	</CFIF>
</CFIF>
--->

<!---run logic to determine if groups have to be processed. Dont run this logic when Generic_type is Brokerage (13542)--->
<CFIF Volume_Good and NOT (ListFindNoCase("Brokerage", GetSettings.Generic_Type))>

	<!---if the program has groups then check to make sure we have a distributor--->
	<cfif programManager.programHasGroups(URL.Contract_Main_ID) eq 1>

		<!---if we are populating the 180 day table right from item master then we don't have to check for a distributor--->
		<!--- Dev Note: Clay 9770 Don't Restrict Volume for Groups based on presence of Distributor--->
		<cfquery name="qCheckGroupProcessed" datasource="#application.datasource#">
					SELECT  Group_Processed
					FROM	Contract_Main
					WHERE	Deleted = 0
					AND 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.Contract_Main_ID#" />
		</cfquery>

		<!---if the groups need to be processed then set Volume_Good to false--->
		<cfif qCheckGroupProcessed.Group_Processed eq 1>
			<cfset Volume_Good = false >
		</cfif>
	</cfif>

</CFIF>

<cfif showVolume AND Volume_Good>
	<cfset oNewVolumeApplicator = CreateObject("component", "mvc.Models.Program.Volume.VolumeApplicator") />
	<cfset stForecastValid = oNewVolumeApplicator.getForecastValidity (ProgramId = URL.Contract_Main_ID) />

	<CFSET VolumeForecastTitle = "">
	<CFIF stForecastValid.distributorsNotInProgram GT 0>
		<CFSET VolumeForecastTitle = ListAppend(VolumeForecastTitle, "- There #IIF(stForecastValid.distributorsNotInProgram GT 1, DE('are'), DE('is'))# #stForecastValid.distributorsNotInProgram# #IIF(stForecastValid.distributorsNotInProgram GT 1, DE(LCase(application.returned_customer_setting.distributor_label_plural)), DE(LCase(application.returned_customer_setting.distributor_label_singular)))# who exist in the recent forecast but does not exist in the program", "#chr(13)#")>
		<CFSET Forecast_Good = false>
	</CFIF>
	<CFIF stForecastValid.distributorsNotInForecast GT 0>
		<CFSET VolumeForecastTitle = ListAppend(VolumeForecastTitle, "- There #IIF(stForecastValid.distributorsNotInForecast GT 1, DE('are'), DE('is'))# #stForecastValid.distributorsNotInForecast# #IIF(stForecastValid.distributorsNotInForecast GT 1, DE(LCase(application.returned_customer_setting.distributor_label_plural)), DE(LCase(application.returned_customer_setting.distributor_label_singular)))# who exist in the program but does not exist in the recent forecast", "#chr(13)#")>
		<CFSET Forecast_Good = false>
	</CFIF>
	<CFIF stForecastValid.operatorsNotInProgram GT 0>
		<CFSET VolumeForecastTitle = ListAppend(VolumeForecastTitle, "- There #IIF(stForecastValid.operatorsNotInProgram GT 1, DE('are'), DE('is'))# #stForecastValid.operatorsNotInProgram# #IIF(stForecastValid.operatorsNotInProgram GT 1, DE(LCase(application.returned_customer_setting.operator_label_plural)), DE(LCase(application.returned_customer_setting.operator_label_singular)))# who exist in the recent forecast but does not exist in the program", "#chr(13)#")>
		<CFSET Forecast_Good = false>
	</CFIF>
	<CFIF stForecastValid.operatorsNotInForecast GT 0>
		<CFSET VolumeForecastTitle = ListAppend(VolumeForecastTitle, "- There #IIF(stForecastValid.operatorsNotInForecast GT 1, DE('are'), DE('is'))# #stForecastValid.operatorsNotInForecast# #IIF(stForecastValid.operatorsNotInForecast GT 1, DE(LCase(application.returned_customer_setting.operator_label_plural)), DE(LCase(application.returned_customer_setting.operator_label_singular)))# who exist in the program but does not exist in the recent forecast", "#chr(13)#")>
		<CFSET Forecast_Good = false>
	</CFIF>

	<CFIF NOT Forecast_Good>
		<CFSET Volume_Good = false>
		<CFSET VolumeTitle = VolumeForecastTitle />
	</CFIF>
</cfif>

<cfif Not isDefined("Volume_Good")>
	<cfset Volume_Good = false >
</cfif>
<cfif Not isDefined("Forecast_Good")>
	<cfset Forecast_Good = false >
</cfif>
<cfif Not isDefined("VolumeTitle")>
	<cfset VolumeTitle = "" >
</cfif>
<cfif Not isDefined("noProductMsg")>
	<cfset noProductMsg = "" >
</cfif>

<!--- check to see if the profile has approval rights at the template level --->
<cfparam name="approvaltype" default="1">
<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />
<cfif forbidType EQ 0>
	<cfset approvaltype = 0>
</cfif>

 <cfset useLakebaseForgetapprovalTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_forbidden_template")>
<cfif useLakebaseForgetapprovalTypes>
	<cftry>
		<cfset getapprovalTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_forbidden_template", {
				"deleted" = "eq.0",
				"template_id" = "eq.#CSLGetContractInfo.ProgramType_ID#",
				"forbid_type" = "eq.#forbidType#",
				"forbid_access_type" = "eq.2",
				"profile_id" = "eq.#Get_Profile_Settings.profiles_id#",
				"select" = "template_id"
			}), "template_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetapprovalTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetapprovalTypes>
<cfquery name="getapprovalTypes" datasource="#application.datasource#">
	select 	distinct template_id
						from 	Profile_Forbidden_Template
						where 	Deleted = 0
								AND Template_ID = #CSLGetContractInfo.ProgramType_ID#
								AND Forbid_Type = #forbidType#
								AND	Forbid_Access_Type = 2
								AND profile_id = #Get_Profile_Settings.profiles_id#
</cfquery>
</cfif>

<cfif getapprovalTypes.recordcount GT 0>
	<cfif forbidType EQ 0>
		<cfset approvaltype = 1>
	<cfelse>
		<cfset approvaltype = 0>
	</cfif>
</cfif>


<cfset useLakebaseForgetagreeTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_forbidden_template")>
<cfif useLakebaseForgetagreeTypes>
	<cftry>
		<cfset getagreeTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_forbidden_template", {
				"deleted" = "eq.0",
				"template_id" = "eq.#CSLGetContractInfo.ProgramType_ID#",
				"forbid_type" = "eq.#forbidType#",
				"forbid_access_type" = "eq.5",
				"profile_id" = "eq.#Get_Profile_Settings.profiles_id#",
				"select" = "template_id"
			}), "template_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetagreeTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetagreeTypes>
<cfquery name="getagreeTypes" datasource="#application.datasource#">
	select 	distinct template_id
						from 	Profile_Forbidden_Template
						where 	Deleted = 0
								AND Template_ID = #CSLGetContractInfo.ProgramType_ID#
								AND Forbid_Type = #forbidType#
								AND	Forbid_Access_Type = 5
								AND profile_id = #Get_Profile_Settings.profiles_id#
</cfquery>
</cfif>

<cfif getagreeTypes.recordcount GT 0>
		<cfset approvaltype = 1>
</cfif>

<!--- end check to see if the profile has approval rights at the template level --->
<CFIF GetSettings.Date_Exclusions_ON EQ 0>
	<CFSET Volume_Not_Good_Str = "You have to establish the volume for all the products in the program before you can continue..." />
<CFELSE>
	<CFSET Volume_Not_Good_Str = "You have to establish the volume for all the products in the program (Including Date Exclusion Programs, If any) before you can continue..." />
</CFIF>
<!--- 60308 :: Best Plans Enhancement START--->
<cfif CSLGETCONTRACTINFO.Best_Plan_Program EQ 1>
	<cfset Volume_Not_Good_Str = "Best Plan Programs must remain in WIP ">
</cfif>
<!--- 60308 :: Best Plans Enhancement END--->
<!--- If it is not a Date Exclusion Program --->


	<CFIF CSLGETCONTRACTINFO.IsExclusionRevision NEQ 1>
			<CFIF Volume_Good AND APVL_Contract_Status EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnPosition EQ 0 AND DisAllowAccessBasedOnLockStatus EQ 0 AND DisAllowAccessBasedOnProfile EQ 0 and checkuom EQ 0 AND CSLGETCONTRACTINFO.Best_Plan_Program EQ 0>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP>
				&nbsp;&nbsp;&nbsp;
				<FONT COLOR="Black" SIZE="3"><B>Ready For Approval</B></FONT>
				<!---D44999 :: Max Rate Approval Workflow --->
								<cfif appSettings.getCustomMaxRate()><!---D45761 :: Approval Workflow--->
									<cfset nextAction = "ezRatesCheck()"/>
								<cfelse>
									<cfset nextAction = "confirmApproval()"/>
								</cfif>
				<INPUT TYPE="checkbox" NAME="ApproveContractButton" TITLE="Click Here to Pre-Approve This Program" VALUE="#URL.CID#" onClick="#nextAction#" id="ApproveContractButton">
				&nbsp;&nbsp;&nbsp;
				<!---D44999 :: Max Rate Approval Workflow --->
				</TD>
			<CFELSEIF (NOT Volume_Good AND (APVL_Contract_Status EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnPosition EQ 0 AND DisAllowAccessBasedOnLockStatus EQ 0 AND DisAllowAccessBasedOnProfile EQ 0)) OR checkuom EQ 1 OR CSLGETCONTRACTINFO.Best_Plan_Program EQ 1>
				<TD ALIGN="right" BGCOLOR="##DDDDDD" style="cursor:pointer;border:2px solid yellow;" NOWRAP onClick="javaScript: alert('#Volume_Not_Good_Str#');" TITLE="#Volume_Not_Good_Str#">
				&nbsp;&nbsp;&nbsp;
				<FONT COLOR="Black" SIZE="3"><B>Ready For Approval</B></FONT>
				<INPUT TYPE="checkbox" disabled>
				&nbsp;&nbsp;&nbsp;
				</TD>
			</CFIF>
	</CFIF>

	<!--- NOI & Brokerage programs do not have volume --->


	<cfif ListFindNoCase("USDA NOI,Brokerage", GetSettings.Generic_Type) OR ListFindNoCase("LSAutoPay", GetSettings.Generic_Type)
	      OR (application.appSettingsGet.getTemplateMultipleProductAttrGroups() eq 1 AND getSettings.Custom_Fixed_Price_Options eq 1)>            <!--- 41835 --->
		<cfset showVolume = 0>
		<cfset Volume_Good = 1>
		<!--- This is a placeholder function --->
		<script language ="javascript">
			function ShowVolumePage(){
				void(0); /* Do Nothing */
			}
		</script>
		<!---Show volume if not USDA --->
	<cfelse>
		<!---<CFIF APVL_Contract_Status LT 3 AND DisAllowAccessBasedOnPosition EQ 0 AND DisAllowAccessBasedOnLockStatus EQ 0 AND DisAllowAccessBasedOnProfile EQ 0 and edit_program EQ 1>--->
		<CFIF DisAllowAccessBasedOnPosition EQ 0 AND DisAllowAccessBasedOnLockStatus EQ 0 AND DisAllowAccessBasedOnProfile EQ 0 and edit_program EQ 1>
		<!--- show volume button --->
			<CFIF Volume_Good AND Forecast_Good AND showVolume>
			<CFELSEIF NOT Forecast_Good>
				<CFSET VolumeTitle = VolumeForecastTitle />
			</CFIF>

			<cfset VolumeButtonLabel = "Volume" />
			<script language="javascript">
				function AutoApplyVolume(thisObj){
					document.getElementById('customContainer').style.display='block';//D51575
					document.body.style.cursor = 'wait';
					thisObj.style.backgroundColor = '##D6D6D6';
					thisObj.onclick = new Function ("return false;");
					window.location.href = 'contract_volume_forecast.cfm?Program_ID=#URL.Contract_Main_ID#';
				}
			</script>
      <!--- ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" --->
			<TD TITLE="#VolumeTitle#" ALIGN="right" BGCOLOR="Yellow" NOWRAP STYLE="font-size: 15px; font-weight: bold; "
				<cfif showVolume>
					<CFIF Volume_Good> <<!--- take them to volume applicator --->
						<cfset VolumeButtonLabel = "Edit Volume" />
                        <cfset edit_volume_file = application.util.query.get_setting("edit_volume_format", 0) contains "CF"
                                                    ? "/programs/volume/edit_volume.cfm"
                                                    : "/flex/Program/VolumeApplicatorFX.cfm">
						STYLE=" cursor: pointer;" ONCLICK="NewWindow('#edit_volume_file#?Program_ID=#URL.Contract_Main_ID#&CID=#URL.CID#','name','1200','650','Yes', 'Yes')" ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''"
					<CFELSE> <!--- do the forecast and save the volume --->
						<cfset VolumeButtonLabel = "Auto Apply Volume" />
						<!--- STYLE=" cursor: pointer;" ONCLICK="NewWindow('contract_volume_forecast.cfm?Program_ID=#URL.Contract_Main_ID#','name','850','650','Yes', 'Yes')" --->
            <!---
                Dev Notes: 21333/Anand Rao/18-Nov-09
                Added code to change the cursor to hourglass and change the background to grey on Click.
                Removed the Mouseover and Mouseout effects after discussing with Karen.
                 --->
						STYLE=" cursor: pointer;" ONCLICK="AutoApplyVolume(this);"
					</CFIF>
				<cfelse> onClick="alert('#noProductMsg#');"</cfif>
				>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<CFIF Volume_Good AND Forecast_Good AND showVolume>
					<CFSET Volume_Img = "yes_small.gif">
				<CFELSEIF NOT Forecast_Good>
					<CFSET Volume_Img = "exclamation.gif">
				<CFELSE>
					<CFSET Volume_Img = "no_small.gif">
				</CFIF><IMG SRC="/Images/#Volume_Img#">&nbsp;#VolumeButtonLabel#
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</CFIF>
		<cfif ModifyDeletedPrograms>
			<TD TITLE="Displays all versions" ALIGN="right" BGCOLOR="Yellow" NOWRAP STYLE="font-size: 15px; font-weight: bold; ">
				<a href="contract_revision_history.cfm?CID=#EncryptedCID#&editOldProgram=0&showallversions=1&contract_number=#CSLGetContractInfo.Contract_Number#" target="_self" style="crusor:hand;color:black;text-decoration: none">
				&nbsp;Return To Revision History&nbsp;
				</a>
			</TD>
		</cfif>

			<script language ="javascript">
			function RefreshPage(){
				/* This is to reset the value of passed variable to zero (0). If we do not do this,
					 this function will call the pop up window again */
						window.location.href="#CGI.SCRIPT_NAME#?CID=#URL.CID#&RO=1";
			}
			</script>

	<!---Don't show volume for USDA programs --->
	</cfif>

	<cfif NOT ListFindNoCase("Brokerage", GetSettings.Generic_Type) AND NOT ListFindNoCase("LSAutoPay", GetSettings.Generic_Type) >

		<cfif getSettings.ByPass_Margin_Evaluation neq "1">       <!---31775--->
			<CFIF Volume_Good AND APVL_Contract_Status EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1>
	        	<!--- D17289 17330 RBL Follow up (1 of 3) [begin] --->
				<cfset popup_onclick = "popupCenter2022('contract_profit_analysis.cfm?CID=#URL.CID#', 'name', '#margin_popup_width#', 'LG')">

				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;" ONCLICK="#popup_onclick#">

	            <!--- D17289 17330 RBL Follow up (1 of 3) [end] --->
					&nbsp;&nbsp;&nbsp;
					View Margins
					&nbsp;&nbsp;&nbsp;
				</TD>
			<CFELSEIF NOT Volume_Good AND (APVL_Contract_Status EQ 1 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1)>
				<td ALIGN="right"  BGCOLOR="##DDDDDD" style="cursor:pointer;border:2px solid yellow;font-size:15px;font-weight:bold;" NOWRAP onClick="javaScript: alert('#Volume_Not_Good_Str#');" TITLE="#Volume_Not_Good_Str#">
					&nbsp;&nbsp;&nbsp;
					View Margins
					&nbsp;&nbsp;&nbsp;
				</TD>
				</CFIF>
		</CFIF>

	</cfif> <!--- Not Brokerage --->
		<!--- If it is not a Date Exclusion Program --->
		<CFIF CSLGETCONTRACTINFO.IsExclusionRevision NEQ 1>
				<!--- this user has full approval abilities ---><cfset cryp.value = Contract_Main_ID>
				<CFIF Volume_Good AND APVL_Contract_Status EQ 2 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 AND approvaltype EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0 AND DisAllowAccessBasedOnPosition EQ 0 and Sent_To_External_Client EQ 0 and agreed EQ 0 and group_processed EQ 0 and user_acess_approval_tabs EQ 1>
					<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;" ONCLICK="confirmApproval()">
						&nbsp;&nbsp;&nbsp;
						Click Here to Approve This Program
						&nbsp;&nbsp;&nbsp;
					</TD>
				<CFELSEIF NOT Volume_Good AND (APVL_Contract_Status EQ 2 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 AND approvaltype EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0 AND DisAllowAccessBasedOnPosition EQ 0) and agreed EQ 0 and user_acess_approval_tabs EQ 1>
					<TD ALIGN="right"  BGCOLOR="##DDDDDD"  style="cursor:pointer;border:2px solid yellow;font-size: 15px; font-weight: bold;" NOWRAP onclick="javaScript: alert('#Volume_Not_Good_Str#');" TITLE="#Volume_Not_Good_Str#">
						&nbsp;&nbsp;&nbsp;
						Click Here to Approve This Program
						&nbsp;&nbsp;&nbsp;
					</TD>
				<cfelseif Volume_Good AND APVL_Contract_Status EQ 2 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 1 AND approvaltype EQ 1 AND IsProgramTemplateAvailable EQ 1 AND DisAllowAccessBasedOnLockStatus EQ 0 AND DisAllowAccessBasedOnPosition EQ 0 AND Sent_To_External_Client EQ 0 and agreed EQ 1  and group_processed EQ 0 and user_acess_approval_tabs EQ 1>
					<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;" ONCLICK="confirmApproval()">
						&nbsp;&nbsp;&nbsp;
						Agreed
						&nbsp;&nbsp;&nbsp;
					</TD>
				</CFIF>
			</CFIF>
		<cfif NOT ListFindNoCase("Brokerage", GetSettings.Generic_Type) AND NOT ListFindNoCase("LSAutoPay", GetSettings.Generic_Type) >
			<cfif getSettings.ByPass_Margin_Evaluation neq "1">       <!---31775--->
			<!--- this user can only view the margins --->
			<CFIF APVL_Contract_Status EQ 2 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND (Get_Profile_Settings.Cont_Prog_Approval_Rights EQ 0 OR approvaltype EQ 0) AND IsProgramTemplateAvailable EQ 1>
            	<!--- D17289 17330 RBL Follow up (2 of 3) [begin] --->
				<cfset popup_onclick = "popupCenter2022('contract_profit_analysis.cfm?CID=#URL.CID#', 'name', '#margin_popup_width#', 'LG')">
				<td ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;" ONCLICK="#popup_onclick#">
                <!--- D17289 17330 RBL Follow up (2 of 3) [end] --->
					&nbsp;&nbsp;&nbsp;
					View Margins
					&nbsp;&nbsp;&nbsp;
				</td>
				</CFIF>
			</CFIF>
		</cfif>

			<!--- the contract is now in a post approved state so make the margins avaiable only --->
			<!--- Dev Note: Clay 8967: Users can modify an expired program's Post-Approval Status. --->
			<CFIF APVL_Contract_Status GTE 3 AND APVL_Contract_Status LTE 7 AND Get_Profile_Settings.Cont_Prog_View_Margins EQ 1 AND IsProgramTemplateAvailable EQ 1>
				<!------ D8399: Post-Approval Status ----->
				<cfif appSettings.getPgmPostApprovalStatus() EQ 1>
					<cfsilent>
					<cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
					<cfset iProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getProgramPostApprovalStatusForProgram(CSL_Contract_Main_ID) />
					</cfsilent>
					<cfif IsNumeric(iProgramPostApprovalStatus) AND iProgramPostApprovalStatus GT 0>
					<cfset arProgramPostApprovalStatusAccessForUserProfile = ProgramPostApprovalStatusManager.getSelectedProfileProgramPostApprovalStatusArray(request.AccessStructure.Profiles_ID) />
					<cfif iProgramPostApprovalStatus LTE ArrayLen(arProgramPostApprovalStatusAccessForUserProfile)>
					<cfsilent>
					<cfset post_approval_status_erp_research_action = "" />
					<cfset post_approval_status_erp_research_message = "" />
					<cfset post_approval_status_erp_research_checked = 0 />
					<cfset post_approval_status_erp_research_show = 0 />
					<cfset post_approval_status_erp_research_next_status = 0 />
					<cfset post_approval_status_erp_research_enabled = 0 />

					<!------ if this user have access to post approval status=1 research ----->
					<cfif DisAllowAccessBasedOnLockStatus EQ 0>
						<cfset post_approval_status_erp_research_enabled = 1 />
					</cfif>

					<cfif iProgramPostApprovalStatus EQ 1>
						<cfset post_approval_status_erp_research_action = "set this program to #arProgramPostApprovalStatusAccessForUserProfile[1][2]# Complete" />
						<cfif post_approval_status_erp_research_enabled EQ 1>
							<cfset post_approval_status_erp_research_message = "Click here to #post_approval_status_erp_research_action#" />
						<cfelse>
							<cfset post_approval_status_erp_research_message = "" />
						</cfif>
						<cfset post_approval_status_erp_research_checked = 0 />
						<cfset post_approval_status_erp_research_show = 1 />
						<!------ set the next status to 2 only if 2 is available in the template ----->
						<cfset qGetSelectedTemplateProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getSelectedTemplateProgramPostApprovalStatus(
									templateId = CSLGetContractInfo.ProgramType_ID,
									programPostApprovalStatusId = 2) />
						<cfif qGetSelectedTemplateProgramPostApprovalStatus.recordCount>
							<cfset post_approval_status_erp_research_next_status = 2 />
						</cfif>
					</cfif>
					<cfif iProgramPostApprovalStatus EQ 2>
						<cfset qGetProgramPostApprovalStatusHistory = ProgramPostApprovalStatusManager.getProgramPostApprovalStatusHistory(
									programId = CSL_Contract_Main_ID,
									postApprovalStatusId = 1) />
						<cfif qGetProgramPostApprovalStatusHistory.recordCount>
							<cfset post_approval_status_erp_research_action = "re-set this program to #arProgramPostApprovalStatusAccessForUserProfile[1][2]#" />
							<cfset post_approval_status_erp_research_message = "" />
							<cfif post_approval_status_erp_research_enabled EQ 1>
								<cfset post_approval_status_erp_research_message = "Click here to #post_approval_status_erp_research_action#" />
								<cfset post_approval_status_erp_research_message = "#post_approval_status_erp_research_message##chr(10)##chr(13)#" />
							</cfif>
							<cfset post_approval_status_erp_research_message = "#post_approval_status_erp_research_message#Set complete by #qGetProgramPostApprovalStatusHistory.Complete_User_Name# on #DateFormat(qGetProgramPostApprovalStatusHistory.Complete_Date, "mm/dd/yyyy")# #TimeFormat(qGetProgramPostApprovalStatusHistory.Complete_Date, "hh:mm:ss tt")#" />
							<cfset post_approval_status_erp_research_checked = 1 />
							<cfset post_approval_status_erp_research_show = 1 />
							<cfset post_approval_status_erp_research_next_status = 1 />
						</cfif>
					</cfif>
					<cfif arProgramPostApprovalStatusAccessForUserProfile[iProgramPostApprovalStatus][1] EQ 0>
						<cfset post_approval_status_erp_research_show = 0 />
					</cfif>
					</cfsilent>
				<!--- (Begin) If a program is not cancelled --->
				<cfif CSLGetContractInfo.Manual_Cancel eq 0>
					<cfif post_approval_status_erp_research_show>
					<TD ALIGN="right" NOWRAP <cfif post_approval_status_erp_research_enabled EQ 0> BGCOLOR="##DDDDDD"<cfelse> BGCOLOR="Yellow" ONMOUSEOVER="this.style.backgroundColor = 'red'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''"  STYLE="cursor: pointer;"</cfif> STYLE="font-size: 15px; font-weight: bold;">
					&nbsp;&nbsp;&nbsp;
					#arProgramPostApprovalStatusAccessForUserProfile[1][2]# Complete
					<INPUT TYPE="checkbox" NAME="post_approval_status_erp_research_chk" TITLE="#post_approval_status_erp_research_message#" VALUE="#URL.CID#" <cfif post_approval_status_erp_research_checked EQ 1>CHECKED</cfif>  onClick="confirmChangePostApprovalStatus(#iProgramPostApprovalStatus#, #post_approval_status_erp_research_next_status#, '#post_approval_status_erp_research_action#')" <cfif post_approval_status_erp_research_enabled EQ 0>DISABLED</cfif>>
					&nbsp;&nbsp;&nbsp;
					</TD>
					</cfif>
				</cfif>	<!--- (End) If a program is not cancelled --->
					</cfif>
					</cfif>
				</cfif>
				<cfif appSettings.getProgramBudgetOn()>
				<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;" ONCLICK="javaScript:showBudgetingPage();">
					&nbsp;&nbsp;&nbsp;
					Trade Expense
					&nbsp;&nbsp;&nbsp;
				</TD>
				</cfif>

				<cfif getSettings.ByPass_Margin_Evaluation neq "1">       <!---31775--->
					<cfif NOT ListFindNoCase("Brokerage", GetSettings.Generic_Type)AND NOT ListFindNoCase("LSAutoPay", GetSettings.Generic_Type) >
						<cfset popup_onclick = "popupCenter2022('contract_profit_analysis.cfm?CID=#URL.CID#', 'name', '#margin_popup_width#', 'LG')">
						<TD ALIGN="right" BGCOLOR="Yellow" NOWRAP ONMOUSEOVER="this.style.backgroundColor = 'green'; this.style.color = 'white'" ONMOUSEOUT="this.style.backgroundColor = ''; this.style.color = ''" STYLE="font-size: 15px; font-weight: bold; cursor: pointer;" ONCLICK="#popup_onclick#">

							&nbsp;&nbsp;&nbsp;
							View Margins
							&nbsp;&nbsp;&nbsp;
						</TD>
					</cfif> <!--- Not Brokerage --->
				</cfif>
			</CFIF>
	</TR>
	</TABLE>
	<cfif (appSettings.getModifyExpiredPrograms()
			AND Get_Profile_Settings.Modify_Expired_Programs
			AND CSLGetContractInfo.Approved
			AND CSLGetContractInfo.Deleted
			AND CSLGetContractInfo.Contract_Status_Type_IDX EQ 7
			AND len(CSLGetContractInfo.Effective_Start_Date)
			AND CSLGetContractInfo.Contract_Is_Locked
			AND CSLGetContractInfo.Dont_Allow_Edit EQ 0
			AND request.AccessStructure.Blacksmith_User EQ 1
			AND request.AccessStructure.User_Rights_ID EQ '9999'

			)>
		<table width="750">
			<tr>
				<td align="right">
					<a  id="#cryp.value#" href="##" onclick="lockProgram('#cryp.value#');">#application.util.string.actionLinkFormat("Submit Changes")#</a>
				</td>

			</tr>
		</table>
	</cfif>
	<script language="JavaScript">
	function confirmChangePostApprovalStatus(fromStatusId, toStatusId, newStatusMessage)
	{
		if(confirm("Are you sure you want to " + newStatusMessage + "?"))
		{
			document.PostApprovalForm.post_approval_status_erp_research_from_hidden.value = fromStatusId;
			document.PostApprovalForm.post_approval_status_erp_research_to_hidden.value = toStatusId;
			document.all.post_approval_status_erp_research_chk.disabled = true;
			<cfif Get_Profile_Settings.Internal_Notes eq 1>
				NewWindowTopLeft('evaluationnotes.cfm?MODE=8&NoteType=2&Formname=PostApprovalForm&CID=<cfoutput>#EncrypContractId#</cfoutput>','EvaluationNotes','1050','600','Yes', 'Yes');
			</cfif>
		}
		else
		{
			if(toStatusId == 1)
			{
				document.all.post_approval_status_erp_research_chk.checked = true;
			}
			else if(toStatusId == 2)
			{
				document.all.post_approval_status_erp_research_chk.checked = false;
			}
			else
			{
				document.all.post_approval_status_erp_research_chk.checked = !document.all.post_approval_status_erp_research_chk.checked;
			}
		}
	}
	</script>
	<!---TSF: Modification Bid Request--->

	<cfif (DisAllowAccessBasedOnLockStatus EQ 0 AND CSLGetContractInfo.BidRequestStatusOn EQ 1)>
		<!---initialize bid request manager--->
		<cfset bidRequestManager = CreateObject("component", "components.programs.bid_request.BidRequestManager") />
		<cfset bidRequestObj = createObject("component", "components.programs.bid_request.BidRequestStatus")>

		<!---get bid history for this program--->
		<cfset lastBidHistory = bidRequestManager.getBidHistory(URL.Contract_Main_ID)>

		<!---get bid request status--->
		<cfset qGetBidReqStatus = bidRequestManager.getStatus(URL.Contract_Main_ID) />

		<!---check to see if this is a line item--->
		<cfset lineItem = bidRequestManager.getBidRequest(URL.Contract_Main_ID).getLineItem() />
		<!---if the template generic type is bid request and the program is pre active then give the ability to apply the bid request status--->
		<!---first check to see if it's pending, or if Program_Control_Panel_Options.BidRequestStatusChangePgmStatus Is set to 0--->
		<cfset currStatusId = qGetBidReqStatus.Bid_Request_Status_ID />
		<cfif (Program_Is_A_Revision gt 1 and CSLGetContractInfo.Contract_Status_Type_IDX lt 4)
				OR (currStatusId eq 1 and CSLGetContractInfo.Contract_Status_Type_IDX eq 4 or CSLGetContractInfo.Contract_Status_Type_IDX eq 10)
				OR (currStatusId eq 1 and CSLGetContractInfo.BidRequestStatusChangePgmStatus EQ 0 AND CSLGetContractInfo.Contract_Status_Type_IDX GT 4)
				OR (appSettings.AllowBidStatusEditAnytime AND CSLGetContractInfo.Contract_Status_Type_IDX GT 2)
				OR (appSettings.AllowBidStatusEditAnytime AND Program_Is_A_Revision)>

			<br>

			<table width="780px">
				<tr>
					<td colspan="100%">
					      <cfif  CSLGetContractInfo.BidRequestStatusChangePgmStatus EQ 0 and  ( CSLGetContractInfo.Contract_Status_Type_IDX GT 3 and CSLGetContractInfo.Contract_Status_Type_IDX  LT 8) >
						Please apply a Status below.<br>
						<b>Note:</b> If a proposal is a Line Item and a status of "Split" is applied, then you will be prompted to select which items have been won or lost.
					      <cfelse>
						This proposal needs a status of <b>Won</b> or <b>Lost</b> before it can become active. Please apply a status below.<br>
						<b>Note:</b> If a proposal is a Line Item and a status of "Split" is applied, then you will be prompted to select
						which items have been won or lost.
					      </cfif>
					</td>
				</tr>

				<tr>

                <cfset bMissingFinalPrice = 0>
             	<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and CSLGetContractInfo.RFP_Process EQ 1>
					<cfscript>
					 		oRFP		= CreateObject("component", "mvc.Models.Program.RfpManager");
					        q = oRFP.getFreightDataQuery(CSLGetContractInfo.Contract_Main_ID);
					</cfscript>
					<cfquery name="CheckMatrixSelectedPrice" dbtype = "query">
						Select 1 from q where fixed_component_type IN (8,9) and Final_Price = 0
					</cfquery>
					<cfif CheckMatrixSelectedPrice.recordcount GT 0 >		<!--- && session.Get_Profile_Settings.RFP_Freight_FOB_Delivered_View_Create GT 0 --->
						<cfset bMissingFinalPrice = 1>
					</cfif>
				</cfif>

                <cfset qBidRequestStatus = bidRequestObj.getBidRequestStatus(0,lineItem) />
				<cfscript>
					objComponentManager	= CreateObject("component","mvc.Models.Program.Component.ComponentManager");
					sProposalTitle = "";
					bProgramWonLossEligible = objComponentManager.programWonLossEligible(Contract_Main_Id);
					//this check is specific to template setting Custom_Fixed_Price_Options
					if( bProgramWonLossEligible == false){
						sProposalTitle = "This Proposal Has Group Records with a 'NONE' Print Code.</br>Please Convert these to a Valid Print Code Before Accepting the Proposal.</br>";
					}
					if(bMissingFinalPrice == 1){
						sProposalTitle = sProposalTitle & 'User must fill out FOB / DEL grid to set final price before updating proposal status';
					}
				</cfscript>
				<!--- Form to apply a status to a bid request--->
				<FORM ACTION="bid_request/bid_request_apply_status.cfm" METHOD="post" NAME="ApplyBidRequestStatus">
					<TD colspan="100%">
						<b><font size="2">Proposal Status:</font></b>&nbsp;
							<select name="Bid_Request_Status_ID" <cfif bProgramWonLossEligible EQ false OR bMissingFinalPrice EQ 1>disabled</cfif> >
							<cfloop query="qBidRequestStatus">
								<option value="#Bid_Request_Status_ID#" <cfif Bid_Request_Status_ID eq currStatusId>selected</cfif>>#Status_Desc#</option>
							</cfloop>
						</select>
						  <cfif bProgramWonLossEligible EQ false OR bMissingFinalPrice EQ 1>
						  	  	<b><font color="FF0000">[</font><a href="##" disabled="true"> apply </a><font color="FF0000">]</font></b>
								<span title="" onmouseout="popUpTip(event,'proposal_Tip');" onmouseover="popUpTip(event,'proposal_Tip');"><img src="/images/help_small.gif" /></span>
								<div id="proposal_Tip" class="tip">
						            <p style="margin:4px;font:12px Arial,Helvetica,sans-serif;font-weight:bold;">#sProposalTitle#</p>
						      	</div>
						   <cfelse>
								<b><font color="FF0000">[</font><a href="javascript:verifyBidReqStatus();"> apply </a><font color="FF0000">]</font></b>
						   </cfif>

						<hr>
					</td>
					<INPUT TYPE="hidden" NAME="Program_ID" VALUE="#URL.CID#" />
					<INPUT TYPE="hidden" NAME="lineItem" VALUE="#lineItem#" />
				</FORM>

			</tr>
			</table>
		</cfif>
	</cfif>

</CFOUTPUT>

<table BORDER="0">
	<TR>
		<TD>
			<CFOUTPUT>#var1#</CFOUTPUT>
		</TD>
	</TR>
<TR><TD>



	<!--- Keeps all of the logic to generate email and faxes --->
	<!--- <CFINCLUDE TEMPLATE="email_fax_handler.cfm">		 --->
	<!--- Keeps all of the logic to generate email and faxes --->


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Button bar at the bottom																		 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BR><BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="1%">
		<TR>
<cfset CHECKFORREVISION = QueryNew("Contract_Main_ID")>
<!--- encrypt the contract main ID --->

<!--- revise button logic --->
		<!--- check for existing revisions that arent yet active. --->
		<CFQUERY NAME="checkForRevision" datasource="#application.datasource#">
			SELECT *
			FROM Contract_Main
			WHERE 	Revision_Of_Contract_Main_ID = '#CSLGetContractInfo.Contract_Main_ID#'
					AND Deleted = 0
					AND Force_Expiration_Flag = 0
					AND Flagged_As_Purged = 0
					AND contract_status_type_idx <= 2
				<cfif GetSettings.Date_Exclusions_ON EQ 1>
					AND contract_main_id not in (select revision_program_id from program_exclusions where 	original_program_id = '#CSLGetContractInfo.Contract_Main_ID#'  and deleted = 0)
				</cfif>

		</CFQUERY>

			<TD WIDTH="100%">&nbsp;</TD>
		</TR>
	</TABLE>
	</TD>
	</TR>
</table>

</BLOCKQUOTE></BLOCKQUOTE>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- Form with the data needed to approve the contract --->

<!--- Dev Note: drachala; D28582: Element CID is undefined in URL error when submitting prg for approval  START
Added/Changed: Added URL variable CID to FORM action url --->

<FORM ACTION="contract_approve_broker_action.cfm?CID=<cfoutput>#EncrypContractId#</cfoutput>" METHOD="post" NAME="BrokerApprovalForm" ID="BrokerApprovalForm">
	<INPUT TYPE="hidden" NAME="ApproveContract" VALUE="<CFOUTPUT>#EncrypContractId#</CFOUTPUT>" >
	<!--- Dev Note: drachala; D28431: Close on RFA  and unlock  START   --->
	<INPUT TYPE="hidden" NAME="approvaltype" VALUE="<cfoutput>#approvaltype#</cfoutput>">
	<!--- End Dev Note: drachala; D28431: Close on RFA and unlock  --->
	<INPUT TYPE="hidden" name="Business_considerations" value="">
	<!--- Tim Ford - 11/14/2013: Label 40275 - EVENT ERRORS:  Element CONT_PROG_APPROVAL_RIGHTS is undefined in GET_PROFILE_SETTINGS --->
	<INPUT TYPE="hidden" name="Cont_Prog_Approval_Rights" value="<cfoutput>#Get_Profile_Settings.Cont_Prog_View_Create_Program#</cfoutput>">
</FORM>
<!--- End Dev Note: drachala; D28582: Element CID is undefined in URL error when submitting prg for approval  --->

<!--- Form with the data needed to approve the contract --->
<FORM ACTION="program_post_approval_status_change.cfm" METHOD="post" NAME="PostApprovalForm" ID="PostApprovalForm">
	<CFOUTPUT>
	<INPUT TYPE="hidden" NAME="EncrypContractId" VALUE="#EncrypContractId#" >
	</CFOUTPUT>
	<INPUT TYPE="hidden" NAME="post_approval_status_erp_research_from_hidden" VALUE="0" >
	<INPUT TYPE="hidden" NAME="post_approval_status_erp_research_to_hidden" VALUE="0" >
	<INPUT TYPE="hidden" name="Business_considerations" value="">
</FORM>

<!--- Form with the data needed to delete the contract --->
<FORM ACTION="delete_program.cfm" METHOD="post" NAME="DeleteForm" ID="DeleteForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#EncrypContractId#</CFOUTPUT>" >
</FORM>

<!--- Form with the data needed to purge the contract --->
<FORM ACTION="contract_purge_action.cfm" METHOD="post" NAME="PurgeForm" ID="PurgeForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#EncrypContractId#</CFOUTPUT>" >
</FORM>

<!--- Form with the data needed to cancel the contract --->
<FORM ACTION="contract_cancel_action.cfm" METHOD="post" NAME="CancelForm" ID="CancelForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#EncrypContractId#</CFOUTPUT>" >
	<INPUT TYPE="hidden" NAME="cancel_option" VALUE="0" >
</FORM>

<!--- Form with the data needed to cancel the contract --->
<!--- If the Program has formula periods (dates) set up,program dates are locked --->
<cfset useLakebaseForcheckFormulaPeriod = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_formula_pricing_periods")>
<cfif useLakebaseForcheckFormulaPeriod>
	<cftry>
		<cfset checkFormulaPeriod = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_formula_pricing_periods", {
				"program_id" = "eq.#URL.Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "program_formula_pricing_period_id"
			}), "program_formula_pricing_period_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheckFormulaPeriod = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheckFormulaPeriod>
<CFQUERY NAME="checkFormulaPeriod" datasource="#application.datasource#">
	SELECT Program_Formula_Pricing_Period_Id FROM Program_Formula_Pricing_Periods
	WHERE Program_Id = #URL.Contract_Main_ID# AND
	Deleted = 0
</CFQUERY>
</cfif>
<CFOUTPUT>
	<FORM ACTION="contract_renewal_action.cfm" METHOD="post" NAME="RenewForm" ID="RenewForm">
		<INPUT TYPE="hidden" NAME="Program_ID" VALUE="#EncrypContractId#" >
		<INPUT TYPE="hidden" NAME="IsRevisionOfExistingContract" VALUE="0" >
		<INPUT TYPE="hidden" NAME="IsRollOver" VALUE="0" >
		<INPUT TYPE="hidden" NAME="IsCopyProgram" <cfif isdefined("URL.IsCopyProgram") AND URL.IsCopyProgram EQ "1">value="1"<cfelse>VALUE="0"</cfif> >
		<INPUT TYPE="hidden" NAME="EZTemplate" VALUE="#GetSettings.EZButton_on#" >
		<input TYPE="hidden" name="contract_reference_number" value="">
		<!--- Only send start and end date if formula pricing periods exist.  we do not want then out of sync --->
		<cfif checkFormulaPeriod.recordCount GT 0 >
			<INPUT TYPE="hidden" NAME="start_date" VALUE="#CSLGetContractInfo.Contract_Start_Date#" >
			<INPUT TYPE="hidden" NAME="end_date" VALUE="#CSLGetContractInfo.Contract_End_Date#" >
		</cfif>
		<INPUT TYPE="hidden" NAME="Limited_Revise" VALUE="#Get_Profile_Settings.Limited_Revise#" >
	</FORM>
</CFOUTPUT>

<!--- Form with the data needed to cancel the contract --->
<FORM ACTION="contract_kickback_action.cfm" METHOD="post" NAME="KBForm" ID="KBForm">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="<CFOUTPUT>#EncrypContractId#</CFOUTPUT>">
	<cfif ListFindNoCase("LSAutoPay", GetSettings.Generic_Type)>
		<INPUT TYPE="hidden" NAME="LSAutoPay" VALUE="1"/>
	<cfelse>
		<INPUT TYPE="hidden" NAME="LSAutoPay" VALUE="0"/>
	</cfif>
</FORM>
<cfoutput>
<script language="JavaScript">
function showBudgetingPage()
{
	NewWindow('program_budget.cfm?CID=#URL.CID#','program_budget','950','600','Yes', 'Yes');
	return false;
}
</script>
</cfoutput>

<cfparam name="url.emailFax" 	default="0">
<cfif url.emailFax>

	<cf_cryp	type = "en" string = "#filename_email#" key = "#request.key#">
	<CFSET Program_Number=cryp.value>

	<!------
	<cfif appSettings.getProgramBudgetOn()>
	<script language="JavaScript">
	showBudgetingPage();
	</script>
	</cfif>
	 ----->
	<CF_displayLayer
			layerName="divEmailFax"
			width="400"
			bgColor="FFEFD5"
			scroll="1"
			>
		<table width="100%" cellpadding="3" cellspacing="0" border="0" background="Images/yellow.gif">
		<tr>
			<td align="right" colspan="100%"><a href="void(0);" onClick="javaScript: return closeDivWindow();"><img src="/Images/close_1.gif" border="0" width="16" height="14"></a></td>
		</tr>
		<tr>
			<td colspan="100%">
			&nbsp;&nbsp;&nbsp;&nbsp;
			<B>Please select your next action.</B>
			<br><br><br>
			</td>
		</tr>
		<tr>

			<CFIF Print_Button_Show EQ 1>
			<cfif CSLGetContractInfo.Contract_Status_Type_IDX LT 3>
			<cfset showimage =1>
			<cfelse>
			<cfset showimage =0>
			</cfif>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"print"
						button_action	=	"NewWindow('printer_friendly.cfm?id=#Program_Number#&PID=#Encoded_Contract_Main_ID#&bgimage=#showimage#','name','1050','600','Yes', 'No')"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			</CFIF>

			<!--- Dev Note: drachala; D29588: Clicking on email redirects to quote letter  START
						Added/Changed: Added condition in if statement START
				(appSettings.getDisplayQuoteLetter() neq 1) ANd  --->
			<CFIF  (Email_Button_Show EQ 1)>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"email"
						button_action	=	"window.location.href='contract_email_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare an email contents"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			</CFIF>
			<!--- End Dev Note: drachala; D29588: Clicking on email redirects to quote letter END --->
		<!--- DEV NOTE: DAA; D15409    REMOVE FAX LINK
			<CFIF Fax_Button_Show EQ 1>
				<TD align="center">
					<CF_button
						button_name		=	""
						button_caption	=	"fax"
						button_action	=	"window.location.href='contract_fax_create.cfm?PID=#Encoded_Contract_Main_ID#&FID=#Encoded_completepath_email#'"
						button_type		=	"javascript_link"
						button_width	=	"50"
						button_color	=	"Navy"
						button_tip		=	"Prepare the contents of a fax to be sent"
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</TD>
			</CFIF>
		 --->
		</tr>
		<tr>

			<td align="center" colspan="100%" valign="top">
			<br><br>
			<!--- <cf_smallLink
					title="close"
					url="void(0);"
					parameters=" onClick=""javaScript: return closeDivWindow();"""
					> --->
					<!--- Dev Note: drachala; D27186: Close on approval and unlock  START--->
			<cfoutput>
				<div id="closeActive">
					<span style="color:red;font-weight: bold;">[</span> <a href="/Common_Files/Contracts/UnLock_Contract.cfm?CID=#EncryptedCID#&close=1" style="font-weight: bold;" onclick="toggleCloseLink();">close</a> <span style="color:red;font-weight: bold;">]</span>
				</div>
				<div id="closeInActive" style="display:none;cursor:pointer;">
				<font color="gray">[ close ]</font>
				</div><br><br>
			</cfoutput>
			<!--- End Dev Note: drachala; D27186: Close on approval and unlock  --->
			</td>
		</tr>
	</table>
	</CF_displayLayer>

</cfif>
<cfset cancelProgramMessage = appSettings.getDeleteProgramMessage()>
<cfif Len(cancelProgramMessage) GT 0>
	<cfset cancelProgramMessage = "#cancelProgramMessage#\n">
</cfif>
<cfset deleteProgramMessage = "">
<cfif appSettings.getDeleteIsCancelAutoRenew() AND CSLGetContractInfo.Is_AutoRenew EQ 1>
	<cfset deleteProgramMessage = cancelProgramMessage>
</cfif>
<script>
	<cfoutput>
	function ShowInactiveProdPage()
	{
	<cfif CSLGetContractInfo.Renewal_Of_Contract_Main_ID NEQ "" AND CSLGetContractInfo.Renewal_Of_Contract_Main_ID NEQ 0 and URL.inactiveprodpopup EQ 1>
	NewWindow('view_contract_inactive_products.cfm?ContractID=<cfoutput>#CSLGetContractInfo.Contract_Main_ID#</cfoutput>','name','650','400','Yes', 'Yes');
	RefreshPage();
	</cfif>
	}
	function verifyDelete(){
		if(confirm("#deleteProgramMessage#Are you sure you want to delete this program?")){
			document.all.DeleteForm.submit()
		}
	}
	</cfoutput>
	function verifyPurge(){
		if(confirm("Are you sure you want to purge this program?")){
			document.all.PurgeForm.submit()
		}
	}
	function verifyCancelation(){
		<!------ DEV Note: DRK D9376: Cancel - New Options ----->
		<!------ pop up the modal dialog which will give the options to the user ----->
		<cfoutput>
		window.showModalDialog('contract_cancel_form.cfm?CID=#URL.CID#&RAND=#CreateUUID()#', window, 'dialogHeight:400px;dialogWidth:500px;center:yes;edge:raised');
		</cfoutput>
	}
	function verifyRenewal(confirmation){
		if (confirmation =='1')
		{
			document.all.IsCopyProgram.value = 1;
			document.all.RenewForm.submit();
		}
		else{
			if(confirm("Are you sure you want to copy this program?")){
				<cfif GetSettings.Date_Exclusions_ON EQ 1>
						<cfif ListLen(ChildProgramIDList) neq 0>
							if(confirm("Do you wish to contine?   If you click Yes, then the existing date exclusions will be deleted and you will need to re-create a new date exclusion.")){			document.all.RenewForm.submit();
							}
						<cfelse>
						document.all.IsCopyProgram.value = 1;
						document.all.RenewForm.submit();
						</cfif>
					<cfelse>
							document.all.IsCopyProgram.value = 1;
							document.all.RenewForm.submit();
					</cfif>
			}
		}
	}

	function verifyRollover(){
		if(confirm("Are you sure you want to roll over this program?")){
			<cfif GetSettings.Date_Exclusions_ON EQ 1>
					<cfif ListLen(ChildProgramIDList) neq 0>
						if(confirm("Do you wish to contine?   If you click Yes, then the existing date exclusions will be deleted and you will need to re-create a new date exclusion.")){				document.all.IsRollOver.value = 1;
			document.all.RenewForm.submit()
						}
					<cfelse>
						document.all.IsRollOver.value = 1;
						document.all.RenewForm.submit();
					</cfif>
			<cfelse>
				document.all.IsRollOver.value = 1;
				document.all.RenewForm.submit()
			</cfif>
		}
	}

	function verifyRevision(){
		<CFIF checkForRevision.recordcount EQ 0>
			if(confirm("Are you sure you want to revise this program?")){
				<cfif GetSettings.Date_Exclusions_ON EQ 1 AND ListLen(ChildProgramIDList) neq 0>
					if(confirm("Do you wish to contine?   If you click Yes, then the existing date exclusions will be deleted and you will need to re-create a new date exclusion for the revised program.")){
						<cfif appSettings.getDisplayEvaluationNotes() EQ 1>
							NewWindowTopLeft('EvaluationNotes.cfm?MODE=4&CID=<cfoutput>#EncryptedCID#</cfoutput>','EvaluationNotes','1050','450','Yes', 'Yes');
						</cfif>
						document.all.RenewForm.IsRevisionOfExistingContract.value = 1;
						<cfif NOT application.returned_customer_setting.reference_number_editable>
							document.all.RenewForm.contract_reference_number.value = '<cfoutput>#jsStringFormat(CSLGETCONTRACTINFO.CONTRACT_REFERENCE_NUMBER)#</cfoutput>';   /*31965*/
						</cfif>
						document.all.RenewForm.submit();
					}
				<cfelse>
						<cfif appSettings.getDisplayEvaluationNotes() EQ 1>
							NewWindowTopLeft('EvaluationNotes.cfm?MODE=4&CID=<cfoutput>#EncryptedCID#</cfoutput>','EvaluationNotes','1050','450','Yes', 'Yes');
						</cfif>
					document.all.RenewForm.IsRevisionOfExistingContract.value = 1;
					<cfif NOT application.returned_customer_setting.reference_number_editable>
						document.all.RenewForm.contract_reference_number.value = '<cfoutput>#jsStringFormat(CSLGETCONTRACTINFO.CONTRACT_REFERENCE_NUMBER)#</cfoutput>';   /*31965*/
					</cfif>
					document.all.RenewForm.submit();
				</cfif>

			}
		<CFELSE>
			<CF_cryp type="en" key="#request.key#" string="#checkForRevision.Contract_main_Id#" return="enc">
			document.location.href="contract_edit_menu.cfm?CID=<CFOUTPUT>#enc.value#</CFOUTPUT>"
		</CFIF>
	}

	function verifyKB(){
		if(confirm("Are you sure you want to reset this to Work in Progress status?")){
			<cfif Get_Profile_Settings.Internal_Notes EQ 1 and appSettings.getbusinessconsiderations_on() EQ 1>
				NewWindowTopLeft('EvaluationNotes.cfm?MODE=3&CID=<cfoutput>#EncryptedCID#</cfoutput>','EvaluationNotes','1050','450','Yes', 'Yes');
			</cfif>
			document.all.KBForm.submit();
		}
	}

	function viewRevisionHistory()
	{
		// NewWindowTopLeft('/common_files/contracts/contract_revision_history.cfm?Contract_number=<cfoutput>#CSLGetContractInfo.contract_number#</cfoutput>&CID=<cfoutput>#EncrypContractId#</cfoutput>','RevisionHistory','800','600','Yes', 'No');
 		<!--- 49859 --->
		// Kal - instead of passing program id, trying to pass program number and the process bombed.
		// NewWindowTopLeft('/reportwriter/performance_reports/revisionreport.cfm?Contract_number=<cfoutput>#CSLGetContractInfo.contract_number#</cfoutput>&CID=<cfoutput>#EncrypContractId#</cfoutput>','ProgramRevisionDetails','1000','600','Yes', 'Yes');

		NewWindowTopLeft('/reportwriter/performance_reports/revisionreport.cfm?Contract_main_id=<cfoutput>#CSLGetContractInfo.Contract_Main_ID#</cfoutput>&Contract_Status=<cfoutput>#CSLGetContractInfo.Contract_Status_Type_IDX#</cfoutput>&CID=<cfoutput>#EncrypContractId#</cfoutput>&contract_number=<cfoutput>#CSLGetContractInfo.Contract_Number#</cfoutput>','ProgramRevisionDetails','1200','550','Yes', 'Yes');
	}

	//TSF: Modification Bid Request
	function verifyBidReqStatus()
	{
		var bidStatus = document.all.ApplyBidRequestStatus.Bid_Request_Status_ID.options[document.all.ApplyBidRequestStatus.Bid_Request_Status_ID.selectedIndex];
		var isLineItem = document.all.ApplyBidRequestStatus.lineItem.value;

		if (bidStatus.value == 1)
		{
			alert("Program can not be applied to proposal pending status.");
		}
		else
		{
			if(confirm("Are you sure you want to set this proposal to " + bidStatus.text + "?"))
			{
								//if the status is won and the bid request is line item then show form to apply what items won and lost
				if(bidStatus.value == 3 && isLineItem == 1)
				{
				    NewWindowTopLeft('bid_request/competitive_data.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1200','850','Yes','Yes');
					//self.close();
				}

				else if (bidStatus.value == 4)
				{
					<cfif GetSettings.Track_Price_Comp eq 1>
					if(confirm("Would you like to enter information about who this was won by?"))
					{
					document.all.ApplyBidRequestStatus.submit();
						NewWindowTopLeft('bid_request/competitive_data.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1200','850','Yes','Yes');
						//self.close();
					}
					else
					{
						document.all.ApplyBidRequestStatus.submit();
					}
					 <cfelse>
					 document.all.ApplyBidRequestStatus.submit();
					</cfif>

				}
				<!--- Dev Note: Drachala; D27340 : Competitive Data Page - user not redirected upon 'won' START--->
				 <cfif #CSLGetContractInfo.Display_Reminder_Comp_Data_Page# NEQ 0>
				else if(bidStatus.value == 2)
				{
				   document.all.ApplyBidRequestStatus.submit();
				   NewWindowTopLeft('bid_request/competitive_data.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1200','850','Yes','Yes');
				   //self.close();
				}
				 </cfif>
				<!--- Dev Note: Drachala; D27340 : Competitive Data Page - user not redirected upon 'won' END --->
				else
				{
					document.all.ApplyBidRequestStatus.submit();
				}

			}
		}
	}

	function confirmagree()
	{
		var confirmagree = confirm("Are you sure you want to agree?");
		if(confirmagree)
		{
			<cfif appSettings.getDisplayEvaluationNotes() EQ 1>
				NewWindowTopLeft('EvaluationNotes.cfm?MODE=1&CID=<cfoutput>#EncryptedCID#</cfoutput>','EvaluationNotes','1050','450','Yes', 'Yes');
			</cfif>
		<cfoutput>location.href = "program_agree_action.cfm?CID=#URL.CID#&User_Id=#request.AccessStructure.User_id#&Programagree=1";</cfoutput>
		}
		else
		return false;
	}

	function verifyMassCopy()
	{
		if(confirm("Are you sure you want to mass copy this program?"))
		{
			NewWindow('/common_files/contracts/mass_program_copy.cfm?CID=<cfoutput>#EncrypContractId#</cfoutput>','MassCopyProgram','1050','600','Yes', 'No');
		}
	}

 	function lockProgram(program_ID){
		window.location.href = 'Contract_Edit_Menu.cfm?lockProgram=1&CID=<cfoutput>#EncrypContractId#</cfoutput>';
	}

</script>

<cfif showPullbackForm>
<FORM ACTION="/Common_Files/contracts/pullbacks/Pullback_Index.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="PullbackForm" STYLE="DISPLAY:INLINE">
<input type="hidden" name="pagetype" value="D">
<input type="hidden" name="applied_pullbacks" value="1">
<input type="hidden" name="command" value="edit">
<input type="hidden" name="FromDistributor_Prg" value="0">
</FORM>
</cfif>
<!---D27190 Added view/hide operators--->
<script type="text/javascript" src="/script/javascript/ajax_js/jquery-1.6.2-min.js"></script>
<script type="text/javascript" src="/script/javascript/ajax_js/jquery.cookie.js"></script>

<script type="text/javascript">
<cfif isDefined("cookie.googtrans")
    and listlen(cookie.googtrans, '/') gte 2
    and listGetAt(cookie.googtrans, 2, '/') eq "Fr" and CSLGetContractInfo.Label_Set_Default eq "French">
	var constant = {
	    	 hide: '[ cacher ]'     <!---text for hide link--->
	    	,show: '[ montrer ]'    <!---text for show link--->
	    	,cookie: 'cem_'         <!---cookie names are prefixed with this template initial--->
	    	,expires: 365           <!---cookie expires in a year--->
	    };
<cfelse>
	var constant = {
	    	 hide: '[ hide ]'       <!---text for hide link--->
	    	,show: '[ show ]'       <!---text for show link--->
	    	,cookie: 'cem_'         <!---cookie names are prefixed with this template initial--->
	    	,expires: 365           <!---cookie expires in a year--->
	    };
</cfif>
<!---events for hide/show info----------------------------------------------------------------------------------------->
function hideShowEvent( toggleID, eligibleID ) {
 $('#' + toggleID).click(function(e) {
  var $toggle = $(this);                                   <!---save link element--->
  e.preventDefault();
  $('#' + eligibleID).fadeToggle( function() {             <!---hide eligible section--->
    if ( $(this).is(':visible') ) {
     $.cookie(constant.cookie + toggleID, constant.hide, { expires: constant.expires, path: '/' });    <!---save hide setting in cookie for future reference--->
     $toggle.html( constant.hide );   <!---change link content--->
    }
    else {
     $.cookie(constant.cookie + toggleID, constant.show, { expires: constant.expires, path: '/' });    <!---save show setting in cookie for future reference--->
     $toggle.html( constant.show );   <!---change link content--->
    }
  });
 });
}
<!---handle initial display of hide/show link-------------------------------------------------------------------------->
function defaultHideShow( toggleID, eligibleID ) {
	if(toggleID == 'toggleHeader' || toggleID == 'toggleOperators' || toggleID == 'toggleDistributors'){
		$('#' + toggleID).html( constant.hide ); <!---update link to hide--->
	}else{
		$('#' + eligibleID).toggle();
		$('#' + toggleID).html( constant.show );  <!---update link to show--->
}
}
<!---set up hide/show initial display & events------------------------------------------------------------------------->
function setupHideShow( toggleID, eligibleID ) {
  defaultHideShow( toggleID, eligibleID );     <!---set up initial display--->
  hideShowEvent( toggleID, eligibleID );       <!---set up events--->
}
<!---hide/show info---------------------------------------------------------------------------------------------------->
<!---these IDs are defined in \Common_Files\contracts\display_view_program_html.cfm--->
setupHideShow( 'toggleOperators',    'eligibleOperators' );
setupHideShow( 'toggleDistributors', 'eligibleDistributors' );
setupHideShow( 'toggleDistributors', 'distributorInclusionsHeading' );
setupHideShow( 'toggleDistributors', 'distributorExclusionsHeading' );
setupHideShow( 'toggleDistributors', 'eligibleDistributorExceptions' );
setupHideShow( 'toggleBrokers',      'eligibleBrokers' );
<!--- Dev Note: drachala; D28861: Show / Hide component information  START
Added/Changed: Added Below two functions--->
setupHideShow( 'toggleRebateComponent', 'eligibleRebateComponent' );
setupHideShow( 'toggleFixedComponent', 'eligibleFixedComponent' );
setupHideShow( 'toggleHeader', 'headerInfo' );<!--- D38353: View Program Header Clean Up...  --->

//$.getScript("//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit");

<!--- 44400 - open qualifications page automatically --->
<cfparam name="url.pop019" default="">
<cfif len(url.pop019)>
	<cfif url.pop019 eq "qualifications">
		<cfoutput>NewWindow("/Common_Files/contracts/qualifications.cfm?Program_ID=#URL.Contract_Main_ID#", 'help', '1200', '600', 'Yes', 'No');</cfoutput>
	</cfif>
</cfif>
<!--- Dev Note: (76484) - When we create a new program OR copy OR revise a program, the original window name of this popup page does not match the newly assigned "contract_main_id".
This causes an issue on "common_files\contracts\contract_layered_approve_action.cfm", as the window names do not match and so a duplicate program summary page opens up.
So, we are setting the new window name below.
--->
<cfif CSL_Contract_Main_ID neq "0" AND CSL_Contract_Main_ID neq "">
	<cfset win_name =  'winSummary_' &  CSL_Contract_Main_ID>
	window.name= <cfoutput>'#win_name#'</cfoutput>;
</cfif>
</script>
</BODY>
</HTML>

<!---  D96288:[Copy] Link in Preview in Program Search does not work / Anand Rao / 12-Mar-2020
		Redirect to the copy page, if URL.IsCopyProgram is set to 1
--->
<cfif FORM.IsCopyProgram EQ "1">
	<script>
		verifyRenewal('1');
	</script>
</cfif>