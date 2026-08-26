<!----
Document Name:	/common_files/contracts/common_program_level_check.cfm
Directory:		/
Author:			Deepa Kunnath
Contact:		dkunnath@bigredflame.com
Date Created:	June 2, 2004
Revised:		This file can contain all the common code which stops the user from requesting approval and approval.
--->

<!------
Set letUserProceed = 0 if you want to stop the user
ArrayAppend the message to messageArray, what you want to display to the user.
----->
<CFPARAM NAME="compUUID" DEFAULT="#CreateUUID()#">

<cfif Not isdefined("letUserProceed")>
<cfset letUserProceed = 1>
</cfif>
<cfif Not isdefined("messageArray")>
<cfset messageArray = ArrayNew(1)>
</cfif>

<!--- Initialise the CFC's here --->
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset LumpSumManager = CreateObject("component", "components.programs.lump_sum_components.LumpSumManager").init() />
<cfset oProgramMgr = CreateObject("component", "components.programs.program") />

<!------ Check for distributor required ----->
<CFIF getSettings.require_distributor EQ 1>
	<CFQUERY NAME="getCustomers" datasource="#application.datasource#">
	
		SELECT 	count(*) as Customercount
		FROM 	Contract_Distributors
		WHERE 	contract_main_id =  #Contract_Main_ID#
		AND 	deleted = 0
	</CFQUERY>
	<CFSET Customercount = getCustomers.Customercount>
	<CFIF Customercount EQ 0>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "You should have at least one #application.returned_customer_setting.distributor_label_singular# selected to approve this program")>
	</CFIF>
</CFIF>

<!------ Check for operator required ----->
<CFIF getSettings.require_operator EQ 1>
	<CFQUERY NAME="getOperators" datasource="#application.datasource#">
		SELECT 	count(*) as Operatorcount
		FROM 	Contract_Operators
		WHERE 	contract_main_id =  #Contract_Main_ID#
		AND		deleted = 0
	</CFQUERY>
	<CFSET Operatorcount = getOperators.Operatorcount>
	<CFIF Operatorcount EQ 0>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "You should have at least one #application.returned_customer_setting.operator_label_singular# selected to approve this program")>
	</CFIF>
</CFIF>
<cfscript>
	oOPP		= CreateObject("component", "mvc.Models.Program.OnePageProgramManager");
	discNum 	= oOpp.getDiscountIdentifier(Contract_Main_ID);
</cfscript>
<!--- Check for performance requirement -- appseting and discount identifier dependent --->
<CFIF appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND discNum EQ "CPA">
	<CFQUERY NAME="checkPerfReq" datasource="#application.datasource#" MAXROWS="1">
			Select PPM.Contract_Main_Id
			FROM One_Program_Perf_Mapping PPM
			INNER JOIN Program_Perf_Req PPR ON
				PPR.Program_Perf_Req_ID = PPM.Program_Perf_Req_ID
				AND (PPR.Requirement_Name = 'Parent' OR PPR.Requirement_Name = 'Child')
			WHERE PPM.Contract_Main_Id = #Contract_Main_ID#
	</CFQUERY>

	<CFIF checkPerfReq.recordcount EQ 0>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "This program requires Parent/Child and Acute/Non-Acute configuration.  Please modify this program and make the approriate selections.")>
	</CFIF>
</CFIF>

<!------ Check for "Allow Vendor Only: ----->
<CFIF getSettings.Allow_Vendor_Only EQ 1>
	<cfif not isDefined("labelSettings")>
		<cfset labelSettings = Createobject("component", "mvc.Models.SettingsService") />
	</cfif>
	<cfset stBBLabels = labelSettings.getBBLabels() />
	<!--- Vendors added to a program are stored in the "Contract_Distributors" table. 
	In programs where vendor as a payee exists, none of the other payees - distributor,operator or broker can exist.
	--->
	<CFQUERY NAME="getVendors" datasource="#application.datasource#">
		SELECT 	count(*) as Vendorcount
		FROM 	Contract_Distributors
		WHERE 	contract_main_id =  #Contract_Main_ID#
		AND 	deleted = 0
	</CFQUERY>
	<CFSET Vendorcount = getVendors.Vendorcount>
	<CFIF Vendorcount EQ 0>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "You should select a #stBBLabels.vendor# to approve this program")>
	</CFIF>
</CFIF>

	<!---TSF - Label 11313: Allow program to be submitted for approval if operator ID is not active--->
	<cfif not application.appsettingsget.getProgramApprovalForInactiveOperators()>

		<!------ Check for inactive operators (Milan - 8961) ----->
    <!---
        Dev Notes:22300/Anand Rao/04-Feb-10/
        Added the AND co.Deleted = 0 in the below query
    --->
		<CFQUERY NAME="getInActiveOperators" datasource="#application.datasource#">
			SELECT bsao.Operator_Name, bsao.Legacy_ID
			  FROM CONTRACT_OPERATORS co
			       INNER JOIN BSA_OPERATOR bsao
			               ON co.bsa_Operator_Id = bsao.bsa_Operator_Id
			 WHERE Contract_Main_Id = #Contract_Main_ID#
			       AND bsao.Deleted = 1
			       AND bsao.Display_Code = 'A'
			       AND co.Deleted = 0
		</CFQUERY>
		<CFSET InActiveOperators = getInActiveOperators.recordcount>
		<CFIF getInActiveOperators.recordcount>
			<cfset letUserProceed = 0>
			<cfset ArrayAppend(messageArray, "The following #lcase(application.returned_customer_setting.operator_label_plural)# currently have a status of Not Active:\n")>
			<cfloop query="getInActiveOperators">
				<cfset arrayAppend(messageArray, getInActiveOperators.Legacy_ID & " - " & getInActiveOperators.Operator_Name)>
			</cfloop>
		</CFIF>

	</cfif>

<!---(Start) Count the number of components and do not allow to approve if more than one component exists (if pullbacks and corporate deal are on) (Milan - 9956) --->
<CFIF appSettings.getAllowOneComponentforPullbacks() EQ 1 AND GetSettings.Pullbacks_On EQ 1 AND GetSettings.is_pullback_corporate_deal EQ 1>
	<cfstoredproc procedure="Component_Number_Count" datasource="#application.datasource#">
		<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@PROGRAM_ID" value="#Contract_Main_ID#" null="no">
		<cfprocparam type = "Out" CFSQLType ="CF_SQL_INTEGER" variable="NumberOfComponents" dbVarName = "@ComponentCount" null="no">
	</cfstoredproc>
	<CFIF NumberOfComponents GT 1>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "Due to potential #appsettings.getPullbackLabelLower()#, only one component is allowed for this program type. Please remove all but one before requesting approval")>
	</CFIF>
</CFIF>
<!--- (End) Count the number of components and do not allow to approve if more than one component exists (Milan - 9956) --->

<!---(Start) Require document attachment (Milan - 10471) --->
	<CFQUERY NAME="getAttachedDocuments" datasource="#application.datasource#">
		SELECT 	TOP 1 ca.Doc_ID, pcpo.Discount_Lump_Sums_Document_Attachment_Mandated,
		pcpo.Document_Attachment_Required,
		pls.Program_Lump_Sum_ID,
		pfc.Program_Fixed_Component_ID,
		prc.Program_Rebates_Component_ID,
		pgc.Program_Growth_Component_ID
		FROM contract_attachments ca RIGHT OUTER JOIN contract_main cm
		ON ca.program_ID = cm.contract_main_id
		AND ca.Deleted = 0
		INNER JOIN Program_Control_Panel_Options pcpo
		ON cm.ProgramType_ID = pcpo.ProgramControl_Panel_Options_ID
		AND pcpo.deleted = 0
		LEFT OUTER JOIN Program_Lump_Sums pls
		ON cm.contract_main_ID = pls.Program_ID
		AND pls.deleted = 0
		LEFT OUTER JOIN Program_Fixed_Component pfc
		ON cm.contract_main_ID = pfc.Program_ID
		AND pfc.Deleted = 0
		LEFT OUTER JOIN Program_Rebates_Component prc
		ON cm.contract_main_ID = prc.Program_ID
		AND prc.Deleted = 0
		LEFT OUTER JOIN Program_Growth_Components pgc
		ON cm.contract_main_ID = pgc.Program_ID
		AND pgc.Deleted = 0

		WHERE cm.contract_main_ID =#Contract_Main_ID#

	</CFQUERY>
	<CFSET RequireDocumentAttachment = getAttachedDocuments.Discount_Lump_Sums_Document_Attachment_Mandated>
	<CFSET LumpSumExists = getAttachedDocuments.Program_Lump_Sum_ID>
	<CFIF RequireDocumentAttachment EQ 1>
			<CFSET AttachedDocuments = getAttachedDocuments.Doc_ID>
		<CFIF LumpSumExists NEQ "">
			<CFIF AttachedDocuments EQ "">
				<CFSET letUserProceed = 0>
				<CFSET ArrayAppend(messageArray, "You should have at least one document attached to this program.")>
			</CFIF>
		</CFIF>
	</CFIF>
<!---(End) Require document attachment (Milan - 10471) --->

<!--- START: 42591: Template setting - document attachment required/ Anand Rao/09-May-2014 --->
	<cfset RequireDocumentAttachmentForAllTypes = getAttachedDocuments.Document_Attachment_Required />
	<cfset FixedExists = getAttachedDocuments.Program_Fixed_Component_ID />
	<cfset RebateExists = getAttachedDocuments.Program_Rebates_Component_ID />
	<cfset GrowthExists = getAttachedDocuments.Program_Growth_Component_ID />
	<cfif RequireDocumentAttachmentForAllTypes EQ 1>
			<cfset AttachedDocuments = getAttachedDocuments.Doc_ID>
		<cfif (LumpSumExists NEQ "" OR FixedExists NEQ "" OR RebateExists NEQ "" OR GrowthExists NEQ "")>
			<cfif (AttachedDocuments EQ "")>
				<cfset letUserProceed = 0>
				<cfset ArrayAppend(messageArray, "You should have at least one document attached to this program")>
			</cfif>
		</cfif>
	</cfif>

<!--- END: 42591: Template setting - document attachment required --->

<!---
	Dev Notes: 22308/Anand Rao/04-Feb-10
	CAG - multi discount type template/ Added or condition
	and TotalDiscounts variable
--->
<CFIF ((getSettings.One_Discount_Mandated EQ 1) OR (GetSettings.Allow_Only_One_Discount EQ 1))>
	<!---This include queries each discount type to see if one has been added to the program--->
	<cfset Contract_Main_ID = Contract_Main_ID>

	<cfinclude template="discount_queries.cfm">
	<!---This include has the following queries:
		FixedPricesStatus
		FormulaStatus
		RebateStatus
		GrowthStatus
		LumpStatus
		getBidRequestProducts
		Off_Invoice
	--->

	<cfset DiscountFound=0>
  <cfset TotalDiscounts = 0 />

	<!---Fixed--->
	<CFIF GetSettings.Discount_Fixed_Prices EQ 1>
	<cfif FixedPricesStatus.Recordcount GT 0>
		<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />
	</cfif>
	</cfif>
	<!---Formula--->
	<CFIF GetSettings.Discount_Formula_Pricing EQ 1>
	<cfif FormulaStatus.Recordcount GT 0>
		<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />
	</cfif>
	</cfif>

	<!---Rebate--->
	<CFIF GetSettings.Discount_Rebates EQ 1>
	<cfif RebateStatus.Recordcount GT 0>
		<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />
	</cfif>
	</cfif>
	<!---Growth--->
	<CFIF GetSettings.Discount_Growth EQ 1>
	<cfif GrowthStatus.Recordcount GT 0>
		<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />
	</cfif>
	</cfif>

	<!---Lump Sum--->
	<CFIF GetSettings.Discount_Lump_Sums EQ 1>
	<cfif LumpStatus.Recordcount GT 0>
		<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />
	</cfif>
	</cfif>
	<!---Bid request--->
	<cfif GetSettings.Generic_Type IS "Bid Request" and GetSettings.Discount_BidRequest EQ 1>
		<cfif BidStatus.recordcount GT 0>
			<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />
		</cfif>
	</cfif>

	<!---Off Invoice--->
	<cfif GetSettings.Generic_Type IS "Distributor Off-Invoice">
		<cfif Off_Invoice.Recordcount GT 0>
			<cfset DiscountFound = 1>
    <cfset TotalDiscounts = TotalDiscounts + 1 />
		</cfif>
	</cfif>

	<!---Bid rules--->
	<!---Bid rules logic not in palce--->

	<cfif DiscountFound IS 0>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "You should have at least one discount offered to approve this program")>
	</cfif>

	<cfif (GetSettings.Allow_Only_One_Discount EQ 1)>
    <cfif (TotalDiscounts GT 1)>
      <cfset letUserProceed = 0 />
      <cfset ArrayAppend(messageArray, "This program can only have one discount type.  Please remove a discount type.")>
    </cfif>
  </cfif>


<!---Require discount--->
</CFIF>

<!--- START START FIRST CHECK TO SEE IF THERE ARE REBATE PRODUCTS AND NO REBATE COMPONENT D17887
	** Changes to rebate page save products First and then User may go back to set program to RFA--->
<CFQUERY NAME="RebateStatus" datasource="#application.datasource#" MAXROWS="1">
		SELECT	Contract_Products.Deleted
		FROM 	Contract_Products
		WHERE (Contract_Products.Deleted = 0)
			AND (Contract_Products.Contract_Main_ID = #Contract_Main_ID#)
			AND Product_Type_ID = 2
</CFQUERY>
<CFQUERY NAME="RebateCompStatus" datasource="#application.datasource#" MAXROWS="1">
	SELECT 	PRC.Program_Rebates_Component_ID
	FROM 	Program_Rebates_Component PRC
	WHERE 	PRC.Program_ID = #Contract_Main_ID#
	AND		PRC.Deleted = 0
</CFQUERY>
<!--- IF WE HAVE REBATE PRODUCTS, MAKE SURE THERE IS A COMPONENT --->
<CFIF RebateStatus.recordcount GT 0 OR RebateCompStatus.Recordcount GT 0>
	<CFQUERY NAME="RebateProductsWithoutComponent" datasource="#application.datasource#" MAXROWS="1">
			SELECT 	PRCD.Program_Rebates_Product_Data_ID
			FROM 	Program_Rebates_Product_Data PRPD
			INNER JOIN Program_Rebates_Component_Data PRCD ON
					PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
					<cfif NOT appSettings.getdisplayzerosviewprogram()>
						AND CAST(PRCD.rate AS DECIMAL(12,4)) > 0.0
					</cfif>
			WHERE 	PRPD.Program_ID = #Contract_Main_ID#
			AND		PRPD.Deleted = 0
	</CFQUERY>

	<CFIF RebateProductsWithoutComponent.recordcount EQ 0 AND (appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 0 OR (discNum NEQ "GPO" AND discNum NEQ "CPA"))>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "This program has a component without products, or, a product selected without components.  Please review your rebate page.")>
	</CFIF>
</CFIF>
<!--- END END CHECK TO SEE IF THERE ARE REBATE PRODUCTS AND NO REBATE COMPONENT D17887 --->

<!--- Dev Note: KAL; 10/20/2010; D25120: Duplicate / No items per LS component --->
<!--- NOTE: Replaced the old content with the below (Label 25120)
When lump sum product is mandatory check if there is any lump sum component without products  --->
<cfif GetSettings.Discount_Lump_Sums AND GetSettings.Discount_Lump_Sums_Item_Mandated >
	<cfif LumpSumManager.getLumpSumComponentWithoutItems(Contract_Main_ID)>
		<cfset letUserProceed = 0 />
		<cfset temp = ArrayAppend(messageArray, "#LCase(Application.LumpsumLabel)# component must have product/product group associated to it")>
	</cfif>
	<cfif LumpSumManager.getLumpSumComponentRepeatedItems(Contract_Main_ID)>
		<cfset letUserProceed = 0 />
		<cfset temp = ArrayAppend(messageArray, "#LCase(Application.LumpsumLabel)# component cannot have duplicate product/product group associated to it")>
	</cfif>
</cfif>
<!--- End Note: KAL; 10/20/2010; D25120: Duplicate / No items per LS component --->

<!------ Check for lump sum min / max ----->
<cfif len(trim(GetSettings.Min_Lump_Sum)) GT 0 AND GetSettings.Min_Lump_Sum NEQ 0>
	<cfset Use_Min_Lump_Sum = 1>
	<cfset MinLumpSum = GetSettings.Min_Lump_Sum>
<cfelse>
	<cfset Use_Min_Lump_Sum = 0>
</cfif>

<cfif len(trim(GetSettings.Max_Lump_Sum)) GT 0 AND GetSettings.Max_Lump_Sum NEQ 0>
	<cfset Use_Max_Lump_Sum = 1>
	<cfset MaxLumpSum = GetSettings.Max_Lump_Sum>
<cfelse>
	<cfset Use_Max_Lump_Sum = 0>
</cfif>
<cfset checkProgramLumpSum = 0 />
<cfif Use_Min_Lump_Sum OR Use_Max_Lump_Sum OR GetSettings.Discount_Lump_Sums_Distributor_Mandated EQ 1>
	<!------ Get the total lump sum in the program ----->
	<cfset checkProgramLumpSum = templateManager.getLumpSumTotal(GetSettings.ProgramControl_Panel_Options_ID, Contract_Main_ID)>
</cfif>
<cfif Use_Min_Lump_Sum OR Use_Max_Lump_Sum>

	<!------ Check only if there is any lump sum added ----->
	<cfif checkProgramLumpSum GT 0>
		<cfif Use_Min_Lump_Sum>
			<cfif checkProgramLumpSum LT MinLumpSum>
				<cfset letUserProceed = 0>
				<cfset ArrayAppend(messageArray, "Program level #Application.LumpsumLabel# total #DollarFormat(checkProgramLumpSum)# cannot be less than #DollarFormat(MinLumpSum)#")>
			</cfif>
		</cfif>

		<cfif Use_Max_Lump_Sum>
			<cfif checkProgramLumpSum GT MaxLumpSum>
				<cfset letUserProceed = 0>
				<cfset ArrayAppend(messageArray, "Program level #Application.LumpsumLabel# total #DollarFormat(checkProgramLumpSum)# cannot be greater than #DollarFormat(MaxLumpSum)#")>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<!------ check customers required for lump sum condition is met ----->
<cfif GetSettings.Discount_Lump_Sums_Distributor_Mandated EQ 1 AND checkProgramLumpSum GT 0>
	<!------ Check if there is any lump sum without customers ----->
	<cfset bAnyLumpSumWithoutDistributor  = LumpSumManager.anyLumpSumWithoutDistributor(Contract_Main_ID)>
	<cfif bAnyLumpSumWithoutDistributor>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "All #LCase(Application.LumpsumLabel)# component should have atleast one #LCase(application.returned_customer_setting.distributor_label_singular)# associated")>
	</cfif>
	<!------ Check if there is any customer without lump sum ----->
	<cfset bAnyDistributorWithoutLumpSum  = LumpSumManager.anyDistributorWithoutLumpSum(Contract_Main_ID)>
	<cfif bAnyDistributorWithoutLumpSum>
		<cfset letUserProceed = 0>
		<cfset ArrayAppend(messageArray, "All #LCase(application.returned_customer_setting.distributor_label_singular)# in the program should have atleast one #LCase(Application.LumpsumLabel)# component associated")>
	</cfif>

</cfif>

<!---TSF: Label 10305 - Check Volume against Min/Max Template Volume if it's set--->
<!---get the uom from contract_main--->
<cfset useLakebaseForqGetProgramUOMIDX = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForqGetProgramUOMIDX>
	<cftry>
		<cfset qGetProgramUOMIDX = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_main_id" = "eq.#Contract_Main_ID#",
				"deleted" = "eq.0",
				"select" = "contract_quantity_uom_idx"
			}), "contract_quantity_uom_idx"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetProgramUOMIDX = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetProgramUOMIDX>
<cfquery name="qGetProgramUOMIDX" datasource="#application.datasource#">
	SELECT	Contract_Quantity_UOM_IDX
	FROM	Contract_Main
	WHERE	Contract_Main_ID = #Contract_Main_ID#
	AND		Deleted = 0
</cfquery>
</cfif>

<cfset variables.programUOM			= qGetProgramUOMIDX.Contract_Quantity_UOM_IDX />
<cfset variables.minGlobalVolume 	= GetSettings.Min_Global_Volume />
<cfset variables.minGlobalVolumeCS 	= GetSettings.Min_Global_Volume_Size_CS />
<cfset variables.minGlobalVolumeLB 	= GetSettings.Min_Global_Volume_Size_LBS />
<cfset variables.maxGlobalVolume 	= GetSettings.Max_Global_Volume />
<cfset variables.maxGlobalVolumeCS 	= GetSettings.Max_Global_Volume_Size_CS />
<cfset variables.maxGlobalVolumeLB 	= GetSettings.Max_Global_Volume_Size_LBS />

<!---determine if we need to get program data--->
<cfif (variables.minGlobalVolume eq 1) or (variables.maxGlobalVolume eq 1)>

	<!---get the contract span--->
	<cfquery name="qGetContractSpan" datasource="#application.datasource#">
		SELECT	(DateDiff(d,Contract_Start_Date, Contract_End_Date) + 1) AS Contract_Span
		FROM	Contract_Main
		WHERE	Contract_Main_ID = #Contract_Main_ID#
		AND		Deleted = 0
	</cfquery>

	<!---get the default unit of time--->
	<cfset useLakebaseForqGetDefaultUOT = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users_settings")>
<cfif useLakebaseForqGetDefaultUOT>
	<cftry>
		<cfset qGetDefaultUOT = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users_settings", {
				"user_id" = "eq.#request.AccessStructure.Company_Main_ID#",
				"select" = "volume_uot_id"
			}), "volume_uot_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDefaultUOT = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDefaultUOT>
<cfquery name="qGetDefaultUOT" datasource="#application.datasource#">
		SELECT		Volume_UOT_ID
		FROM		_Users_Settings
		WHERE		User_ID = '#request.AccessStructure.Company_Main_ID#'
	</CFQUERY>
</cfif>

	<!---get program volume--->
	<cfset ProgramVolumeQuantity 		= CreateObject("component", "components.programs.volume.ProgramVolume").getProgramQty(Contract_Main_ID, qGetContractSpan.Contract_Span, qGetDefaultUOT.Volume_UOT_ID) />
	<cfset variables.programQtyCases	= ProgramVolumeQuantity.ProgramQtgCases>
	<cfset variables.programQtyPounds	= ProgramVolumeQuantity.ProgramQtglbs>

</cfif>

<!---if min is set but not max--->
<cfif variables.minGlobalVolume eq 1 and variables.maxGlobalVolume neq 1>
	<!---if the program uom is cs--->
	<cfif variables.programUOM eq 1>
		<cfif variables.programQtyCases lt variables.minGlobalVolumeCS>
			<cfset letUserProceed = 0 />
			<cfset ArrayAppend(messageArray, "Program Volume is less than the minimum volume for this program type.")>
			<cfset variables.alertMessageOnApprove = "Program Volume is less than the minimum volume for this program type.">
		</cfif>
	<!---if the program uom is lb--->
	<cfelse>
		<cfif variables.programQtyPounds lt variables.minGlobalVolumeLB>
			<cfset letUserProceed = 0 />
			<cfset ArrayAppend(messageArray, "Program Volume is less than the minimum volume for this program type.")>
			<cfset variables.alertMessageOnApprove = "Program Volume is less than the minimum volume for this program type.">
		</cfif>
	</cfif>
<!---if max is set but not min--->
<cfelseif variables.maxGlobalVolume eq 1 and variables.minGlobalVolume neq 1>
	<!---if the program uom is cs--->
	<cfif variables.programUOM eq 1>
		<cfif variables.programQtyCases gt variables.maxGlobalVolumeCS>
			<cfset letUserProceed = 0 />
			<cfset ArrayAppend(messageArray, "Program Volume is greater than the maximum volume for this program type.")>
			<cfset variables.alertMessageOnApprove = "Program Volume is greater than the maximum volume for this program type.">
		</cfif>
	<!---if the program uom is lb--->
	<cfelse>
		<cfif variables.programQtyPounds gt variables.maxGlobalVolumeLB>
			<cfset letUserProceed = 0 />
			<cfset ArrayAppend(messageArray, "Program Volume is greater than the maximum volume for this program type.")>
			<cfset variables.alertMessageOnApprove = "Program Volume is greater than the maximum volume for this program type.">
		</cfif>
	</cfif>
<!---if both min and max are set--->
<cfelseif variables.maxGlobalVolume eq 1 and variables.minGlobalVolume eq 1>
	<!---if the program uom is cs--->
	<cfif variables.programUOM eq 1>
		<cfif variables.programQtyCases lt variables.minGlobalVolumeCS>
			<cfset letUserProceed = 0 />
			<cfset ArrayAppend(messageArray, "Program Volume is less than the minimum volume for this program type.")>
			<cfset variables.alertMessageOnApprove = "Program Volume is less than the minimum volume for this program type.">
		<cfelseif variables.programQtyCases gt variables.maxGlobalVolumeCS>
			<cfset letUserProceed = 0 />
			<cfset ArrayAppend(messageArray, "Program Volume is greater than the maximum volume for this program type.")>
			<cfset variables.alertMessageOnApprove = "Program Volume is greater than the maximum volume for this program type.">
		</cfif>
	<!---if the program uom is lb--->
	<cfelse>
		<cfif variables.programQtyPounds lt variables.minGlobalVolumeLB>
			<cfset letUserProceed = 0 />
			<cfset ArrayAppend(messageArray, "Program Volume is less than the minimum volume for this program type.")>
			<cfset variables.alertMessageOnApprove = "Program Volume is less than the minimum volume for this program type.">
		<cfelseif variables.programQtyPounds gt variables.maxGlobalVolumeLB>
			<cfset letUserProceed = 0 />
			<cfset ArrayAppend(messageArray, "Program Volume is greater than the maximum volume for this program type.")>
			<cfset variables.alertMessageOnApprove = "Program Volume is greater than the maximum volume for this program type.">
		</cfif>
	</cfif>
</cfif>
<!---END TSF: Label 10305 --->

 <cfif appsettings.getPayeeFromPlanningGroups() eq 1>
 	<cfset ErrorMsg = "">
	<cfset DistWithoutPGForRebate = oProgramMgr.checkProgramDistributorsWithoutPlanningGroupForRebate(Contract_Main_ID)>
	<cfset DistWithoutPGForGrowth = oProgramMgr.checkProgramDistributorsWithoutPlanningGroupForGrowth(Contract_Main_ID)>
	<cfif DistWithoutPGForRebate.recordcount GT 0 OR DistWithoutPGForGrowth.recordcount GT 0>
			<cfset letUserProceed = 0 />
			<cfset ErrorMsg = "The configuration for this environment relies upon a Vendor and/or Distributor for Auto Pay processing involving planning groups.  The planning groups selected must each identify the Payee [Vendor or Distributor]. Additionally, this configuration does not allow for programs created using master data variables or hierarchies other than FORGE planning groups.">
			<cfset ErrorMsg = ErrorMsg & '\n\n' & 'The following distributor(s) on the program are not planning groups:' & '\n\n'>
			<cfloop query="DistWithoutPGForRebate">
				<cfset ErrorMsg = ErrorMsg & ' #Shr_Ship_To# - #Name#' & '\n'>
			</cfloop>
			<cfloop query="DistWithoutPGForGrowth">
				<cfset ErrorMsg = ErrorMsg & ' #Shr_Ship_To# - #Name#' & '\n'>
			</cfloop>

			<cfset ArrayAppend(messageArray, "#ErrorMsg#")>
			<cfset variables.alertMessageOnApprove = "#ErrorMsg#">
	</cfif>

	<cfif ErrorMsg eq "">
		<cfset PGWithoutPayeeForRebate = oProgramMgr.checkPlanningGroupWithoutPayeeForRebate(Contract_Main_ID)>
		<cfset PGWithoutPayeeForGrowth = oProgramMgr.checkPlanningGroupWithoutPayeeForGrowth(Contract_Main_ID)>
		<cfif PGWithoutPayeeForRebate.recordcount GT 0 OR PGWithoutPayeeForGrowth.recordcount GT 0>
			<cfset letUserProceed = 0 />
			<cfset ErrorMsg = "The configuration for this environment relies upon a Vendor and/or Distributor for Auto Pay processing involving planning groups.  The planning groups selected must each identify the Payee [Vendor or Distributor]. Additionally, this configuration does not allow for programs created using master data variables or hierarchies other than FORGE planning groups.">
			<cfset ErrorMsg = ErrorMsg & '\n\n' & 'Following planning group(s) do not have a payee selected:' & '\n\n'>
			<cfloop query="PGWithoutPayeeForRebate">
				<cfset ErrorMsg = ErrorMsg & ' #PG_Customer_Category_Name#' & ' - No #PayeeType# payee selected'  & '\n'>
			</cfloop>	
			<cfloop query="PGWithoutPayeeForGrowth">
				<cfset ErrorMsg = ErrorMsg & ' #PG_Customer_Category_Name#' & ' - No #PayeeType# payee selected'  & '\n'>
			</cfloop>	

			<cfset ArrayAppend(messageArray, "#ErrorMsg#")>
			<cfset variables.alertMessageOnApprove = "#ErrorMsg#">
		</cfif>
	</cfif>		
</cfif>


<!--- Moved EZButton_Approve_Beyond_MaxRate logic to common_approval_check.cfm ---->
