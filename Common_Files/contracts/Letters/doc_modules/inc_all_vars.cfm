<cfsilent>
	<!---
	FILENAME:     doc_modules/inc_all_vars.cfm
	CREATED:     12/19/2007 - RBL
	EDITED:        03/16/2009 - RBL [MVC v11]
	EDITED:        08/16/2010 - Milan [Convert to Itext in Java]
	EDITED:        09/15/2010 - Milan [Add template setting to show/hide info on the letter]

	FUNCTIONALITY:
	- This include template represents all legacy var ingredients for Deal Letters v2...
	ACTION Tech Note: This should really get looked at some time to minimize duplicitious calls for vars
	Employed the ViewProgramTemplateManager.cfc RBL
	--->
	<!--- These parameters are required for this template to process correctly --->
	<cfparam name="url.CMID" type="numeric" default="0">
	<cfparam name="url.claim_rate_date" default="#DateFormat(now(), 'mm/dd/yyyy')#">
	<cfparam name="url.dist_id" type="string" default="0">
	<cfparam name="url.pages" default="">
	<cfparam name="url.bNoDistributors" type="numeric" default="0">
	<cfparam name="url.custprodnum" default="0">

	<cfparam name="url.letterInclFixedPrice" type="boolean" default="0">
	<cfparam name="url.letterInclFreightPricing" type="boolean" default="0">
	<cfparam name="url.letterInclLumpsum" type="boolean" default="0">
	<cfparam name="url.letterInclRebate" type="boolean" default="0">
	<cfparam name="url.manuallyGenerated" type="boolean" default="0">
	<cfparam name="url.IncludeInactive" type="boolean" default="0">

	<cfset CSL_Contract_Main_ID = url.CMID>

	<cfif isdefined("attributes.claimRateDate")>
		<cfset url.claim_rate_date = attributes.claimRateDate>
	</cfif>

	<cfparam name="opr_list_names" type="string" default="">
	<cfparam name="opr_dis_list" type="string" default="">
	<cfparam name="dis_list_names" type="string" default="">
	<cfparam name="dis_opr_list" type="string" default="">
	<cfparam name="template_name" type="string" default="">

	<cfparam name="variables.company_name" type="string" default="">
	<!--- should be numeric but was not prior, so safer to leave alone for now... --->
	<cfparam name="variables.user_id" default="">

	<!--- /// some bandaids for some legacy schtuff... [begin] /// --->
	<!--- IF we have a request.accessstructure AND it has a user_id key AND it has something in it...--->
	<cfif isDefined("request.accessstructure") AND structKeyExists(request.accessstructure, "user_id") AND len(trim(request.accessstructure.user_id))>
		<cfset variables.user_id = request.accessstructure.user_id>
		<!--- OR if we have a url.user_id and it has something in it... --->
	<cfelseif isdefined("url.user_id") AND len(trim(url.user_id))>
		<cfset variables.user_id = url.user_id>
		<!--- <cfelse>
		    <cfset variables.user_id = ""> --->
	</cfif>
	<!--- IF we have a request.accessstructure AND it has a company_name key AND it has something in it... --->
	<cfif isDefined("request.accessstructure") AND structKeyExists(request.accessstructure,"company_name") AND len(trim(request.accessstructure.company_name))>
		<cfset variables.company_name = request.accessstructure.company_name>
		<!--- OR if we have a url.company_name and it has something in it... --->
	<cfelseif isdefined("url.company_name") AND len(trim(url.company_name))>
		<cfset variables.company_name = url.company_name>
	<cfelseif isDefined("application.returned_customer_setting.company_name") AND len(trim(application.returned_customer_setting.company_name))>
		<cfset variables.company_name = application.returned_customer_setting.company_name>
		<!--- <cfelse>
		    <cfset variables.company_name = ""> --->
	</cfif>
	<!--- /// some bandaids for some legacy schtuff... [end] /// --->

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset StructDelete(application, "oLetterManager")>
<!--- MVC V11 Edit [begin] --->
<cfscript>
 application.oController.getObject("mvc.Models.LetterManager");
 application.oController.getObject("components.programs.Letters.ProgramLetterFreightManager");

/* Dev Note (Milan) - 42196.
"application.oController.getObject("mvc.Models.LetterManager")" line above normally puts "oLetterManager" in the application scope,
but sometimes it does not when called from the scheduled task (most of the time there is no issue).
Adding the line below to put "oLetterManager" in the application scope for those situations.
*/
if(not isDefined("application.oLetterManager")){
	application.oLetterManager = CreateObject("component", "mvc.Models.LetterManager");
}
</cfscript>
<!--- MVC V11 Edit [end] --->

<!--- NOTE: This may replace LetterManager. At the moment, perhaps duplicating? RBL [begin] --->
<cfset ProgramTemplateManager = CreateObject("component", "components.programs.Display_Program.ViewProgramTemplateManager") />

<cfset labelComp = CreateObject("component", "components.settings.labels.labels").init() />

<!--- NOTE: This may replace LetterManager here. At the moment, perhaps duplicating? RBL [end] --->
<cfset gettemplatesettings = application.oLetterManager.gettemplatesettings(CSL_Contract_Main_ID)>
<cfset getLetterSettings = application.oLetterManager.getLetterSettings(CSL_Contract_Main_ID,variables.user_id)>
<cfset getprogramdetails = application.oLetterManager.getprogramdetails(CSL_Contract_Main_ID)>
<cfset getoperatordetails = application.oLetterManager.getoperatordetails(CSL_Contract_Main_ID)>
<cfset getdistributordetails = application.oLetterManager.getdistributordetails(CSL_Contract_Main_ID)>


<!--- || 0 || create our pdf document BODY container... [begin] --->
<cfset variables.stPDFBodyInfo = structNew()>

<cfif getprogramdetails.Generic_Type EQ "Bid Request">
	<cfset structInsert(variables.stPDFBodyInfo,"bDisplayBidRequest",1,true)>
<cfelse>
	<cfset structInsert(variables.stPDFBodyInfo,"bDisplayBidRequest",0,true)>
</cfif>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::: Let's bring some key values into the 'House of Letters' [begin] ::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->


<!--- General Labels --->
<cfset variables.legacyIDLabel 	= labelComp.GetGeneralLabels('Legacy ID').General_Labels_Label />

<cfset addDiscountTypeDataOnLetters = 0>
<!--- De Note: (48572 and 49898) - If "standard letters" app setting is OFF OR the letters are to be auto generated,
then we should not look for "include lumpsum" or "include rebate" or "include fixed price" or any other discount type
checkbox value which comes from contract_letters.cfm".
The feature to show or not show data at the discount type level is only for standard letters.
--->
<cfif appSettings.getlettersavailable() neq 1 or url.manuallyGenerated eq 0>
	<cfset addDiscountTypeDataOnLetters = 1>
</cfif>

<!--- > Program level... --->
<cfif addDiscountTypeDataOnLetters eq 1 or url.letterInclFixedPrice eq 1>
	<cfset structInsert(variables.stPDFBodyInfo,"bDisplayFixedPrice",getprogramdetails.discount_fixed_prices[1],true)>
<cfelse>
	<cfset structInsert(variables.stPDFBodyInfo,"bDisplayFixedPrice",0,true)>
</cfif>
<cfif addDiscountTypeDataOnLetters eq 1 or url.letterInclRebate eq 1>
	<cfset structInsert(variables.stPDFBodyInfo,"bDisplayRebate",getprogramdetails.discount_rebates[1],true)>
<cfelse>
	<cfset structInsert(variables.stPDFBodyInfo,"bDisplayRebate",0,true)>
</cfif>
<cfif addDiscountTypeDataOnLetters eq 1 or url.letterInclLumpsum eq 1>
	<cfset structInsert(variables.stPDFBodyInfo,"bDisplayLumpSum",getprogramdetails.discount_lump_sums[1],true)>
<cfelse>
	<cfset structInsert(variables.stPDFBodyInfo,"bDisplayLumpSum",0,true)>
</cfif>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayGrowth",getprogramdetails.discount_growth[1],true)>


<!--- D16586 [begin] --->
<cfset structInsert(variables.stPDFBodyInfo,"bTemplateAllowFreightLetters",gettemplatesettings.include_freight_summary[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bPreDefinedPageBreaks",gettemplatesettings.Pre_Defined_Page_Break[1],true)>
<!--- D16586 [end] --->

<!--- > Template level... --->
<cfset structInsert(variables.stPDFBodyInfo,"bBonusField",gettemplatesettings.Bonus_Field[1],true)>

<!--- . distributor aka customer --->
<cfset structInsert(variables.stPDFBodyInfo,"bDisLettersRequired",gettemplatesettings.distributor_letters_required[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisPaysToDistributor",gettemplatesettings.distributor_paysto_dis[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisPaysToOperator",gettemplatesettings.distributor_paysto_opr[1],true)>

<cfset structInsert(variables.stPDFBodyInfo,"bDisplayBidRequestDis",gettemplatesettings.distributor_bid_request[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayFixedPriceDis",gettemplatesettings.distributor_fixed_pricing[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayLumpSumDis",gettemplatesettings.distributor_lumpsum[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayRebateDis",gettemplatesettings.distributor_rebate[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayGrowthDis",gettemplatesettings.distributor_growth[1],true)>

<cfset structInsert(variables.stPDFBodyInfo,"bDistributorDiscountType",gettemplatesettings.Distributor_Discount_Type[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorComponentName",gettemplatesettings.Distributor_Component_Name[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorClaimMechanism",gettemplatesettings.Distributor_Claim_Mechanism[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorPayableTo",gettemplatesettings.Distributor_Payable_To[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorPricingType",gettemplatesettings.Distributor_Pricing_Type[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorPaymentFrequency",gettemplatesettings.Distributor_Payment_Frequency[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorUOM",gettemplatesettings.Distributor_UOM[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorGTIN",gettemplatesettings.Distributor_GTIN[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorProductAttribute_1",gettemplatesettings.Distributor_Product_Attribute_1[1],true)>

<cfset structInsert(variables.stPDFBodyInfo,"bDistributorPriceBrackets",gettemplatesettings.Distributor_Price_Brackets[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorOpenDate",gettemplatesettings.Distributor_Open_Date[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorDateNeeded",gettemplatesettings.Distributor_Date_Needed[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorExpectedDate",gettemplatesettings.Distributor_Expected_Date[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorEstValueVolume",gettemplatesettings.Distributor_Est_Value_Volume[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorDistProductCodes",gettemplatesettings.Distributor_Dist_Product_Codes[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorCustomerAcceptanceBlock",gettemplatesettings.Distributor_Customer_Acceptance_Block[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorLine",gettemplatesettings.Distributor_Line[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorNotes",gettemplatesettings.Distributor_Notes[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorShowVolumeSummary",gettemplatesettings.Distributor_show_volume_summary[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDistributorProductNetWeight",gettemplatesettings.Distributor_Product_Net_Weight[1],true)>

<!--- operator --->
<cfset structInsert(variables.stPDFBodyInfo,"bOprLettersRequired",gettemplatesettings.operator_letters_required[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOprPaysToDistributor",gettemplatesettings.operator_paysto_dis[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOprPaysToOperator",gettemplatesettings.operator_paysto_opr[1],true)>

<cfset structInsert(variables.stPDFBodyInfo,"bDisplayBidRequestOpr",gettemplatesettings.operator_bid_request[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayFixedPriceOpr",gettemplatesettings.operator_fixed_pricing[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayLumpSumOpr",gettemplatesettings.operator_lumpsum[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayRebateOpr",gettemplatesettings.operator_rebate[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bDisplayGrowthOpr",gettemplatesettings.operator_growth[1],true)>

<cfset structInsert(variables.stPDFBodyInfo,"bOperatorDiscountType",gettemplatesettings.Operator_Discount_Type[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorComponentName",gettemplatesettings.Operator_Component_Name[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorClaimMechanism",gettemplatesettings.Operator_Claim_Mechanism[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorPayableTo",gettemplatesettings.Operator_Payable_To[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorPricingType",gettemplatesettings.Operator_Pricing_Type[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorPaymentFrequency",gettemplatesettings.Operator_Payment_Frequency[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorUOM",gettemplatesettings.Operator_UOM[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorGTIN",gettemplatesettings.Operator_GTIN[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorProductAttribute_1",gettemplatesettings.Operator_Product_Attribute_1[1],true)>

<cfset structInsert(variables.stPDFBodyInfo,"bOperatorPriceBrackets",gettemplatesettings.Operator_Price_Brackets[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorOpenDate",gettemplatesettings.Operator_Open_Date[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorDateNeeded",gettemplatesettings.Operator_Date_Needed[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorExpectedDate",gettemplatesettings.Operator_Expected_Date[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorEstValueVolume",gettemplatesettings.Operator_Est_Value_Volume[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorCustomerAcceptanceBlock",gettemplatesettings.Operator_Customer_Acceptance_Block[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorLine",gettemplatesettings.Operator_Line[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorNotes",gettemplatesettings.Operator_Notes[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorShowVolumeSummary",gettemplatesettings.Operator_show_volume_summary[1],true)>
<cfset structInsert(variables.stPDFBodyInfo,"bOperatorProductNetWeight",gettemplatesettings.Operator_Product_Net_Weight[1],true)>

<!--- || 0 || create our pdf document BODY container... [end] --->

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::: Let's bring some key values into the 'House of Letters' [end] ::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->

<!--- TESTING [begin]
<cfoutput>
	<cfmail from="blee@bigredflame.com" to="blee@bigredflame.com" subject="#UCase(cgi.server_name)# - Inside the include all vars" type="html" server="mail.bigredflame.com">
		#cgi.server_protocol# | #cgi.server_name# | #cgi.path_translated# | #cgi.server_port# | #createODBCDateTime(now())#<br />
		<cfdump var="#variables#" label="variables">
	</cfmail>
</cfoutput>
TESTING [end] --->

<cfset List_Of_Contract_Main_IDs = ValueList(getprogramdetails.CONTRACT_MAIN_ID)>

<!------ For date exclusions ----->
<cfif getprogramdetails.Date_Exclusions_ON eq 1>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
	<cfset getParentContractInfo = GenProgramManager.ParentProgramInfo(CSL_Contract_Main_ID)>
	<cfset displayGroupType = genSettingsManager.getDisplayGroupType(appSettings.getViewProgramProductGroupType()) />
	<cfset displayGroupTypeDesc = appSettings.getViewProgramProductGroupTypeDesc() />

	<cfif getParentContractInfo.RecordCount eq 0>
		<!------ If no parent,  then this is the parent? ----->
		<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(CSL_Contract_Main_ID,0)>
	<cfelse>
		<cfset getDateExclusionprogramIDs = GenProgramManager.ChildProgramIDs(getParentContractInfo.Contract_Main_ID,1)>
	</cfif>
	<cfif getParentContractInfo.RecordCount eq 0>
		<cfset List_Of_Contract_Main_IDs = ValueList(getprogramdetails.CONTRACT_MAIN_ID)>

		<cfif getDateExclusionprogramIDs.Revision_Program_ID neq "">
			<cfset List_Of_Contract_Main_IDs = ListAppend(List_Of_Contract_Main_IDs, ValueList(getDateExclusionprogramIDs.Revision_Program_ID))>
		</cfif>
	<cfelse>
		<cfset List_Of_Contract_Main_IDs = ValueList(getParentContractInfo.Contract_Main_ID)>

		<cfif getDateExclusionprogramIDs.Revision_Program_ID neq "">
			<cfset List_Of_Contract_Main_IDs = ListAppend(List_Of_Contract_Main_IDs, ValueList(getDateExclusionprogramIDs.Revision_Program_ID))>
		</cfif>
	</cfif>
<cfelse>
	<cfset List_Of_Contract_Main_IDs = QuotedvalueList(getprogramdetails.CONTRACT_MAIN_ID)>
</cfif>

<!--- Note: Dev Note(69526) - Alias data is common for the different discount types. Populate that data just once.
The populated temp table can then be used for the different discount types.
---->
<cfif url.Dist_ID neq 0 AND len(url.Dist_ID) neq 0>
	<cfset application.oLetterManager.getProductAliases(CSL_Contract_Main_ID,url.Dist_ID,url.custprodnum)>
</cfif>

<cfif variables.stPDFBodyInfo.bDisplayFixedPrice AND (variables.stPDFBodyInfo.bDisplayFixedPriceDis OR variables.stPDFBodyInfo.bDisplayFixedPriceOpr) >
	<!--- Employing ViewProgramTemplateManager.cfc instead RBL --->
	<cfset getFixedPriceProducts  = ProgramTemplateManager.getFixedPriceProducts(Contract_Main_ID = CSL_Contract_Main_ID,UseTableResults = 1, dist_id = url.Dist_ID,
	bDistributorProductAttribute_1 = variables.stPDFBodyInfo.bDistributorProductAttribute_1,bOperatorProductAttribute_1 = variables.stPDFBodyInfo.bOperatorProductAttribute_1,IncludeInactive = url.IncludeInactive)>
	<!--- employ cols of the following w/a merge in the FP include...
	<cfset getFixedPriceProducts  = application.oLetterManager.getFixedPriceProducts(List_Of_Contract_Main_IDs)>
	--->
<cfelse>
<cfset getFixedPriceProducts  = queryNew('Fixed_Price_Products')>
</cfif>

<cfif variables.stPDFBodyInfo.bDisplayRebate AND (variables.stPDFBodyInfo.bDisplayRebateDis OR variables.stPDFBodyInfo.bDisplayRebateOpr) >
	<cfset getRebateProducts = application.oLetterManager.getRebateProducts(List_Of_Contract_Main_IDs, url.Dist_ID,
	variables.stPDFBodyInfo.bDistributorProductAttribute_1,variables.stPDFBodyInfo.bOperatorProductAttribute_1,url.IncludeInactive)>
<!--- Get a count of rebate products. "getRebateProducts" does not return a query. It only populates a temp table (##TMP_Rebate_Price_Details).
So, we need to get the count from ##TMP_Rebate_Price_Details.
--->
<cfquery name="getRebateProdCount" datasource="#application.datasource#">
	SELECT COUNT(*) As ProdCount
	FROM ##TMP_Rebate_Price_Details
</cfquery>
<cfelse>
<cfset getRebateProducts  = queryNew('Rebate_Products')>
</cfif>

<cfif variables.stPDFBodyInfo.bDisplayBidRequest AND (variables.stPDFBodyInfo.bDisplayBidRequestDis OR variables.stPDFBodyInfo.bDisplayBidRequestOpr) >
	<!--- Employing ViewProgramTemplateManager.cfc instead RBL --->
	<cfset getBidRequestProducts = ProgramTemplateManager.BidProducts(CSL_Contract_Main_ID,0,url.IncludeInactive)>
	<!--- <cfset getBidRequestProducts = application.oLetterManager.getBidRequestProducts(List_Of_Contract_Main_IDs)> --->
<cfelse>
<cfset getBidRequestProducts  = queryNew('Bid_Request_Products')>
</cfif>

<cfset variables.bid_request_status_id = 0>
<cfif getprogramdetails.BidRequestStatusOn>
    <cfquery name="variables.qProgramBidRequestStatus" datasource="#application.datasource#">
        SELECT 	Bid_Request_Status_ID
        FROM 	Program_Bid_Request
        WHERE 	Program_Bid_Request.Program_ID = #CSL_Contract_Main_ID#
    </cfquery>

    <cfif variables.qProgramBidRequestStatus.recordCount>
        <cfset variables.bid_request_status_id = variables.qProgramBidRequestStatus.Bid_Request_Status_ID[1]>
    </cfif>
</cfif>

<!---	Note: "getLumpSums" will not return any value as a temp table is being populated instead. --->
<cfif variables.stPDFBodyInfo.bDisplayLumpSum AND (variables.stPDFBodyInfo.bDisplayLumpSumDis OR variables.stPDFBodyInfo.bDisplayLumpSumOpr) >
	<cfset getlumpsums = application.oLetterManager.getlumpsums(List_Of_Contract_Main_IDs,variables.bid_request_status_id, url.Dist_ID,
	variables.stPDFBodyInfo.bDistributorProductAttribute_1,variables.stPDFBodyInfo.bOperatorProductAttribute_1,url.IncludeInactive)>
<cfelse>
<cfset getLumpSums  = queryNew('Lump_Sums')>
</cfif>

<!---	Note: "getGrowthProducts" will not return any value as a temp table is being populated instead. --->
<cfif variables.stPDFBodyInfo.bDisplayGrowth AND (variables.stPDFBodyInfo.bDisplayGrowthDis OR variables.stPDFBodyInfo.bDisplayGrowthOpr) >
	<cfset getGrowthProducts = application.oLetterManager.getGrowthProducts(List_Of_Contract_Main_IDs, url.Dist_ID,
	variables.stPDFBodyInfo.bDistributorProductAttribute_1,variables.stPDFBodyInfo.bOperatorProductAttribute_1,url.IncludeInactive)>
<cfelse>
<cfset getGrowthProducts  = queryNew('Growth')>
</cfif>

<cfset clauseProgramManager = CreateObject("component", "components.clause_library.ClauseProgramManager")>
<cfset getProgramClause = clauseProgramManager.getProgramClause(CSL_Contract_Main_ID, 1)>

<cfset contract_number = Right(getprogramdetails.contract_number,7) & "-00" & getprogramdetails.revision_version>
<cfset start_date = getprogramdetails.contract_start_date>
<cfset end_date = getprogramdetails.contract_end_date>
<cfset payment_cycle = getprogramdetails.payment_cycle>
<cfset opr_path = "\data_files\created\contracts\letters\output\operators\">
<cfset dis_path = "\data_files\created\contracts\letters\output\distributors\">

<!--- let's get our program info for the letter Intro, Header & Footer... RBL --->

<!--- create some temporary objects... RBL --->
<cfset variables.oProgramData = createObject("component","components.programs.program") />
<cfset variables.oUserData = createObject("component","components.user.usermanager") />
<!--- retreive the query data... RBL --->
<cfset variables.qProgramInfo = variables.oProgramData.getProgramInfo(programId=CSL_Contract_Main_ID,calculateTimeZoneDiff=0,fromBillback=0,fromProgramLetters=1)>
<cfset variables.qUserInfo = variables.oUserData.getUser(variables.qProgramInfo.responsible_user_id[1])>

<!--- For HTML Letters --->
<cfif appSettings.getlettersavailable() eq 2>
	<cfif IsDefined("getRebateProdCount") AND getRebateProdCount.ProdCount>
<!--- Get the Minimum "Price List Start Date" --->
	<cfquery name="variables.priceListData"  datasource="#application.datasource#">
	    SELECT 	CONVERT(Char(10), MIN(Price_List_Start_Date),101) As Price_List_Start_Date
	    FROM	##TMP_Rebate_Price_Details
	    GROUP BY Price_List_Start_Date
	</cfquery>
	</cfif>
</cfif>

<!--- ================================================================================================
===== Compile Specific Structures of VARS to explicitly pass to the 3 Generator Files [begin] ========
================================================================================================= --->

<!--- || 1 || create our pdf document INTRO container... (alpha) [begin] --->
<cfset variables.stPDFIntroInfo = structNew()>
<cfset structInsert(variables.stPDFIntroInfo,"company_name",variables.company_name,true)>
<cfset structInsert(variables.stPDFIntroInfo,"contract_end_date",variables.qProgramInfo.contract_end_date[1],true)>
<cfset structInsert(variables.stPDFIntroInfo,"contract_start_date",variables.qProgramInfo.contract_start_date[1],true)>
<cfset structInsert(variables.stPDFIntroInfo,"program_payment_frequency",variables.getprogramdetails.payment_cycle[1],true)>
<cfset structInsert(variables.stPDFIntroInfo,"program_pricing_type",variables.qProgramInfo.fixed_type[1],true)>
<cfset structInsert(variables.stPDFIntroInfo,"program_spend",variables.qProgramInfo.program_spend[1],true)>
<cfset structInsert(variables.stPDFIntroInfo,"contract_reference_number",variables.qProgramInfo.contract_reference_number[1],true)>
<cfset structInsert(variables.stPDFIntroInfo,"legacyIDLabel",variables.legacyIDLabel,true)>
<cfset structInsert(variables.stPDFIntroInfo,"legacy_deal_id",variables.getprogramdetails.legacy_deal_id[1],true)>
<!--- For HTML (cfdocument) based PDF Letters --->
<cfif appSettings.getlettersavailable() eq 2>
	<cfif IsDefined("getRebateProdCount") AND getRebateProdCount.ProdCount>
                <cfset structInsert(variables.stPDFIntroInfo,"price_list_start_date",variables.priceListData.Price_List_Start_Date[1],true)>
                <cfset structInsert(variables.stPDFIntroInfo,"price_protection_date",variables.qProgramInfo.Price_Protection_Date[1],true)>
<cfelse>
                <cfset structInsert(variables.stPDFIntroInfo,"price_list_start_date","",true)>
                <cfset structInsert(variables.stPDFIntroInfo,"price_protection_date","",true)>
	</cfif>
</cfif>


<!--- If it is not "one distributor per letter" option --->
<cfif url.bNoDistributors eq 0>
<!--- ACTION: MAY BE DELETING Freight Bracket LIST [begin] RBL - not sure 2/20/08 --->
<cfquery name="variables.qGetFreightBracket" datasource="#application.datasource#">
	SELECT 	DISTINCT(freight_bracket_history.freight_bracket_label)
	FROM 	freight_bracket_history
	INNER JOIN 	program_distributor_freight
	ON 		freight_bracket_history.freight_bracket_setting_id = program_distributor_freight.freight_bracket_setting_id
	WHERE 	program_distributor_freight.program_id = #variables.qProgramInfo.contract_main_id[1]#
</cfquery>
<cfset structInsert(variables.stPDFIntroInfo,"lsFreightBrackets",valueList(variables.qGetFreightBracket.freight_bracket_label,","),true)>
<!--- Freight Bracket LIST [end] --->

<!--- For HTML (cfdocument) based PDF Letters, check whether the distributors have groups. --->
<cfset useLakebaseForvariables_qIsDistGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_distributors")>
<cfif useLakebaseForvariables_qIsDistGroups>
	<cftry>
		<cfset variables.qIsDistGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_distributors", {
				"contract_main_id" = "eq.#variables.qProgramInfo.contract_main_id[1]#",
				"is_group" = "eq.1",
				"deleted" = "eq.0",
				"limit" = "1",
				"select" = "contract_distributors_id"
			}), "contract_distributors_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qIsDistGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qIsDistGroups>
<cfquery name="variables.qIsDistGroups" datasource="#application.datasource#">
 SELECT TOP 1 Contract_Distributors_ID
 FROM Contract_Distributors
 WHERE Contract_Main_ID = #variables.qProgramInfo.contract_main_id[1]#
 AND Is_Group = 1
 AND deleted = 0
</cfquery>
</cfif>

<cfquery datasource="#application.datasource#">
		if object_id('tempdb..##TMP_qProgramAllDistributorInfo') is not null
		drop table ##TMP_qProgramAllDistributorInfo

		CREATE TABLE ##TMP_qProgramAllDistributorInfo
		(
		 BSA_Foodservice_Customers_id nvarchar(50),
		 Group_Desc varchar(100),
		 distributor_group_id varchar(50),
		 is_group bit,
		 captured_from_group bit,
		 Name nvarchar(255),
		 address_1 varchar(255),
		 city nvarchar(75),
		 state nvarchar(25),
		 zipcode varchar(50),
		 Contract_Distributors_id int,
		 warehouse_code nvarchar(25),
		 warehouse_name nvarchar(100),
		 warehouse_city nvarchar(50),
		 warehouse_state nvarchar(25),
		 shr_ship_to nvarchar(50),
		 Freight_Bracket_Setting_ID int,
		 Freight_Bracket_Label nvarchar(100)
		 )
		 CREATE CLUSTERED  INDEX [I_ProgramAllDistributorInfo_tmp] ON [##TMP_qProgramAllDistributorInfo]([BSA_Foodservice_Customers_id],[Contract_Distributors_id]) ON [PRIMARY]
</cfquery>

<!--- Get All Distributor data. It is needed for Operator letters --->
<cfquery name="variables.qInsertProgramAllDistributorInfo" datasource="#application.datasource#">
	<!--- For HTML Letter. Get the distributor group info, so that group and its members can be queried. --->
	<cfif appSettings.getlettersavailable() eq 2 AND variables.qIsDistGroups.recordcount>
	INSERT INTO ##TMP_qProgramAllDistributorInfo(BSA_Foodservice_Customers_id,Group_Desc,distributor_group_id,is_group,captured_from_group,Name,address_1,
	city,state,zipcode,Contract_Distributors_id,shr_ship_to)

	SELECT 	bsafc.BSA_Foodservice_Customers_id, LTRIM(RTRIM(acgt.Group_Desc)), cd.distributor_group_id, cd.is_group, cd.captured_from_group, LTRIM(RTRIM(REPLACE(bsafc.Name, NCHAR(160),' '))),
	LTRIM(RTRIM(bsafc.Address_1)), LTRIM(RTRIM(bsafc.city)), LTRIM(RTRIM(bsafc.state)),LTRIM(RTRIM(bsafc.zipcode)),cd.Contract_Distributors_id,LTRIM(RTRIM(bsafc.shr_ship_to))

	FROM Contract_Distributors cd
	INNER JOIN All_Customer_Group_Types acgt
	ON cast(acgt.Group_GUID AS VARCHAR(50)) = cd.Distributor_Group_ID
	AND acgt.Distributor_Group_Level_ID = cd.Distributor_Group_Level_ID
	INNER JOIN BSA_Foodservice_Customers bsafc
	ON cd.BSA_Foodservice_Customers_ID = bsafc.BSA_Foodservice_Customers_ID
	WHERE cd.Contract_Main_ID = #variables.qProgramInfo.contract_main_id[1]#
	AND cd.deleted = 0
	AND acgt.deleted = 0
	ORDER BY bsafc.Name

	<!--- No distributor group info --->
	<cfelse>

	INSERT INTO ##TMP_qProgramAllDistributorInfo(BSA_Foodservice_Customers_id,is_group,captured_from_group,Name,address_1,city,state,zipcode,Contract_Distributors_id
	,warehouse_code,warehouse_name,warehouse_city,warehouse_state,shr_ship_to)

	SELECT 	BSA_Foodservice_Customers.BSA_Foodservice_Customers_id,Contract_Distributors.is_group,Contract_Distributors.captured_from_group,LTRIM(RTRIM(REPLACE(BSA_Foodservice_Customers.Name, NCHAR(160),' '))),
	LTRIM(RTRIM(BSA_Foodservice_Customers.Address_1)),LTRIM(RTRIM(BSA_Foodservice_Customers.city)), LTRIM(RTRIM(BSA_Foodservice_Customers.state)),LTRIM(RTRIM(BSA_Foodservice_Customers.zipcode)),
	Contract_Distributors.Contract_Distributors_id,LTRIM(RTRIM(warehouse_master.warehouse_code)),LTRIM(RTRIM(warehouse_master.warehouse_name)),LTRIM(RTRIM(warehouse_master.warehouse_city)),
	LTRIM(RTRIM(warehouse_master.warehouse_state)),LTRIM(RTRIM(BSA_Foodservice_Customers.shr_ship_to))

	FROM 		Contract_Distributors
	INNER JOIN BSA_Foodservice_Customers
	ON Contract_Distributors.BSA_Foodservice_Customers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
	LEFT JOIN Warehouse_Master
	ON 	Contract_Distributors.Warehouse_Master_id = Warehouse_Master.Warehouse_Master_id
	WHERE 		Contract_Distributors.Contract_Main_id = #variables.qProgramInfo.contract_main_id[1]#
	AND			Contract_Distributors.deleted = 0
	ORDER BY	BSA_Foodservice_Customers.Name
	</cfif>
</cfquery>

<cfquery datasource="#application.datasource#">
		if object_id('tempdb..##TMP_qProgramDistributorInfo') is not null
		drop table ##TMP_qProgramDistributorInfo

		CREATE TABLE ##TMP_qProgramDistributorInfo
		(
		 BSA_Foodservice_Customers_id nvarchar(50),
		 Group_Desc varchar(100),
		 distributor_group_id varchar(50),
		 is_group bit,
		 captured_from_group bit,
		 Name nvarchar(255),
		 address_1 varchar(255),
		 city nvarchar(75),
		 state nvarchar(25),
		 zipcode varchar(50),
		 Contract_Distributors_id int,
		 warehouse_code nvarchar(25),
		 warehouse_name nvarchar(100),
		 warehouse_city nvarchar(50),
		 warehouse_state nvarchar(25),
		 shr_ship_to nvarchar(50),
		 Freight_Bracket_Setting_ID int,
		 Freight_Bracket_Label nvarchar(100)
		 )
		 CREATE CLUSTERED  INDEX [I_ProgramDistributorInfo_tmp] ON [##TMP_qProgramDistributorInfo]([BSA_Foodservice_Customers_id],[Contract_Distributors_id]) ON [PRIMARY]
</cfquery>

<!--- Get the SPECIFIC Distributor data needed for pdf intro section [begin] RBL --->
<cfquery name="variables.qInsertProgramDistributorInfo" datasource="#application.datasource#">
	<!--- For HTML Letter. Get the distributor group info, so that group and its members can be queried. --->
	<cfif appSettings.getlettersavailable() eq 2 AND variables.qIsDistGroups.recordcount>
	INSERT INTO ##TMP_qProgramDistributorInfo(BSA_Foodservice_Customers_id,Group_Desc, distributor_group_id, is_group,captured_from_group,Name,address_1,city,state,zipcode,Contract_Distributors_id,shr_ship_to)
	SELECT 	bsafc.BSA_Foodservice_Customers_id, LTRIM(RTRIM(acgt.Group_Desc)), cd.distributor_group_id, cd.is_group, cd.captured_from_group, LTRIM(RTRIM(bsafc.Name)), LTRIM(RTRIM(bsafc.Address_1)), LTRIM(RTRIM(bsafc.city)),
	LTRIM(RTRIM(bsafc.state)),LTRIM(RTRIM(bsafc.zipcode)),cd.Contract_Distributors_id,LTRIM(RTRIM(bsafc.shr_ship_to))
	FROM Contract_Distributors cd
	INNER JOIN All_Customer_Group_Types acgt
	ON cast(acgt.Group_GUID AS VARCHAR(50)) = cd.Distributor_Group_ID
	AND acgt.Distributor_Group_Level_ID = cd.Distributor_Group_Level_ID
	INNER JOIN BSA_Foodservice_Customers bsafc
	ON cd.BSA_Foodservice_Customers_ID = bsafc.BSA_Foodservice_Customers_ID
	WHERE cd.Contract_Main_ID = #variables.qProgramInfo.contract_main_id[1]#
	<CFIF dist_id NEQ 0 AND len(dist_id) neq 0>
	AND cd.BSA_Foodservice_Customers_id IN (#ListQualify(dist_id,"'")#)
	</CFIF>
	AND cd.deleted = 0
	AND acgt.deleted = 0
	ORDER BY bsafc.Name

	<!--- No distributor group info --->
	<cfelse>

	INSERT INTO ##TMP_qProgramDistributorInfo(BSA_Foodservice_Customers_id,is_group,captured_from_group,Name,address_1,city,state,zipcode,Contract_Distributors_id
	,warehouse_code,warehouse_name,warehouse_city,warehouse_state,shr_ship_to)
	SELECT 		BSA_Foodservice_Customers.BSA_Foodservice_Customers_id,Contract_Distributors.is_group,Contract_Distributors.captured_from_group,
	LTRIM(RTRIM(BSA_Foodservice_Customers.Name)),LTRIM(RTRIM(BSA_Foodservice_Customers.Address_1)),LTRIM(RTRIM(BSA_Foodservice_Customers.city)),
	LTRIM(RTRIM(BSA_Foodservice_Customers.state)),LTRIM(RTRIM(BSA_Foodservice_Customers.ZipCode)),Contract_Distributors.Contract_Distributors_id,
	LTRIM(RTRIM(warehouse_master.warehouse_code)),LTRIM(RTRIM(warehouse_master.warehouse_name)),LTRIM(RTRIM(warehouse_master.warehouse_city)),
	LTRIM(RTRIM(warehouse_master.warehouse_state)),LTRIM(RTRIM(BSA_Foodservice_Customers.shr_ship_to))

	FROM 		Contract_Distributors
	INNER JOIN BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_id = Contract_Distributors.BSA_Foodservice_Customers_id
	LEFT JOIN Warehouse_Master
	ON Contract_Distributors.Warehouse_Master_id = Warehouse_Master.Warehouse_Master_id
	WHERE Contract_Distributors.Contract_Main_id = #variables.qProgramInfo.contract_main_id[1]#
	<CFIF dist_id NEQ 0 AND len(dist_id) neq 0>
	AND 		Contract_Distributors.BSA_Foodservice_Customers_id IN (#ListQualify(dist_id,"'")#)
	</CFIF>
	AND			Contract_Distributors.deleted = 0
	ORDER BY	BSA_Foodservice_Customers.Name
	</cfif>

</cfquery>


<cfquery name="variables.qProgramDistributorInfo" datasource="#application.datasource#">
	SELECT *
	FROM ##TMP_qProgramDistributorInfo
	Order by Name
</cfquery>

<!--- Get the SPECIFIC Distributor data needed for pdf intro section [end] --->

<cfquery name="variables.qProgramAllDistributorInfo" datasource="#application.datasource#">
	SELECT *
	FROM ##TMP_qProgramAllDistributorInfo
	Order By Name
</cfquery>

<!--- Let's reach out and grab the freight_bracket_setting_id for each distributor for this program... [begin]
<cfif NOT listFindNoCase(variables.qProgramDistributorInfo.columnList,"freight_bracket_setting_id",",")>--->

  	<cfloop query="variables.qProgramDistributorInfo">
    	<cfquery name="variables.qGetFreightBracketSettingIDs" datasource="#application.datasource#">
      	SELECT 		DISTINCT Freight_Lookup_Bracket_Settings.Freight_Bracket_Setting_ID,Freight_Bracket_Label
        FROM		Freight_Lookup_Bracket_Settings
				INNER JOIN Program_Distributor_Freight
				ON Freight_Lookup_Bracket_Settings.Freight_Bracket_Setting_ID = Program_Distributor_Freight.Freight_Bracket_Setting_ID
				INNER JOIN Contract_Distributors
				ON Program_Distributor_Freight.Distributor_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
        WHERE	Program_Distributor_Freight.Program_ID = #variables.qProgramInfo.contract_main_id[1]#
				AND Program_Distributor_Freight.Distributor_ID = '#variables.qProgramDistributorInfo.BSA_Foodservice_Customers_ID#'
        AND	Contract_Distributors.Contract_Main_ID = Program_Distributor_Freight.Program_ID
      </cfquery>
			<cfquery name="variables.qGetFreightBracketSettingIDs" datasource="#application.datasource#">
				UPDATE ##TMP_qProgramDistributorInfo
				SET Freight_Bracket_Setting_ID = '#qGetFreightBracketSettingIDs.Freight_Bracket_Setting_ID[1]#',
				Freight_Bracket_Label = '#qGetFreightBracketSettingIDs.Freight_Bracket_Label[1]#'
				WHERE BSA_Foodservice_Customers_id = '#variables.qProgramDistributorInfo.BSA_Foodservice_Customers_ID#'
			</cfquery>

    </cfloop>
<!--- Let's reach out and grab the freight_bracket_setting_id for each distributor for this program... [end] --->

<cfelse>

<cfset variables.qProgramDistributorInfo = queryNew('Name,contract_distributors_id')>
<!---D41200 ::  Prod Event 12466--->
<cfset variables.qProgramAllDistributorInfo = queryNew('Name,contract_distributors_id')>

</cfif>

<cfquery datasource="#application.datasource#">
		if object_id('tempdb..##TMP_qProgramOperatorInfo') is not null
		drop table ##TMP_qProgramOperatorInfo

		CREATE TABLE ##TMP_qProgramOperatorInfo
		(
		 Operator_ID int,
		 Operator_Name nvarchar(255),
		 Operator_City nvarchar(75),
		 Operator_State nvarchar(15),
		 Legacy_ID nvarchar(50),
		 Operator_Address varchar(255),
		 Operator_Zip varchar(50)
		 )
		 CREATE CLUSTERED INDEX [I_ProgramOperatorInfo_tmp] ON [##TMP_qProgramOperatorInfo]([Operator_ID]) ON [PRIMARY]
</cfquery>

<!--- Get the SPECIFIC Operator data needed for pdf intro section [begin] (IF we have a legacy_ID use it, otherwise use BA Oper ID) --->
<cfquery name="variables.qInsertProgramOperatorInfo" datasource="#application.datasource#">
	INSERT INTO ##TMP_qProgramOperatorInfo(Operator_ID,Operator_Name,Operator_City,Operator_State,Legacy_ID,Operator_Address,Operator_Zip)
	SELECT	BSA_Operator.BSA_Operator_ID, dbo.UDF_REMOVE_NON_ASCIICharOnly(BSA_Operator.Operator_Name) As Operator_Name, REPLACE(BSA_Operator.Operator_City, CHAR(160), ''), BSA_Operator.Operator_State, Legacy_ID,
	Operator_Address,Operator_Zip
	FROM 	Contract_Operators,BSA_operator
	WHERE	BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
	AND 	Contract_Operators.Contract_Main_id = #variables.qProgramInfo.contract_main_id[1]#
	AND 	Contract_Operators.deleted = 0
	ORDER BY BSA_Operator.Operator_Name
</cfquery>

<cfquery name="variables.qProgramOperatorInfo" datasource="#application.datasource#">
	SELECT	*
	FROM ##TMP_qProgramOperatorInfo
</cfquery>

<!--- Get the Secondary Operators needed for the "pdf Appendix" sections --->
<cfquery datasource="#application.datasource#">
		if object_id('tempdb..##TMP_qProgramOperatorSecondaryInfo') is not null
		drop table ##TMP_qProgramOperatorSecondaryInfo

		CREATE TABLE ##TMP_qProgramOperatorSecondaryInfo
		(
		 BSA_Operator_ID int,
		 Secondary_Operator_ID varchar(75),
		 Secondary_Operator_Name varchar(150),
		 Secondary_Operator_City varchar(50),
		 Secondary_Operator_State varchar(15),
		 Secondary_Operator_Address_1 varchar(250),
		 Legacy_ID varchar(50),
		 Secondary_Operator_ZipCode varchar(50)
		 )
		 CREATE CLUSTERED INDEX [I_ProgramOperatorSecondaryInfo_tmp] ON [##TMP_qProgramOperatorSecondaryInfo]([BSA_Operator_ID]) ON [PRIMARY]
</cfquery>

<cfquery name="variables.qInsertProgramOperatorSecondaryInfo" datasource="#application.datasource#">
	INSERT INTO ##TMP_qProgramOperatorSecondaryInfo(BSA_Operator_ID,Secondary_Operator_ID,Secondary_Operator_Name,Secondary_Operator_City,
													Secondary_Operator_State,Secondary_Operator_Address_1,Legacy_ID,Secondary_Operator_ZipCode)
	SELECT BSA_OS.BSA_Operator_ID,BSA_OS.Secondary_Operator_ID,BSA_OS.Secondary_Operator_Name,BSA_OS.Secondary_Operator_City,BSA_OS.Secondary_Operator_State,
	        BSA_OS.Secondary_Operator_Address_1,BSA_OS.Legacy_ID,BSA_OS.Secondary_Operator_ZipCode
	FROM Contract_operators CO
	INNER JOIN BSA_Operator_Secondary BSA_OS
	ON CO.BSA_Operator_ID = BSA_OS.BSA_Operator_ID
	WHERE CO.Contract_Main_ID = #variables.qProgramInfo.contract_main_id[1]#
	AND CO.deleted = 0
	AND BSA_OS.deleted = 0
	AND BSA_OS.Active = 'A'
	ORDER BY BSA_OS.Secondary_Operator_Name
</cfquery>

<!--- EVALUATING <cfquery name="variables.qProgramOperatorInfo" datasource="#application.datasource#">
SELECT
	<!--- BSA_Operator.BSA_Operator_ID AS Operator_ID, --->
    CASE
    	WHEN ISNULL(BSA_Operator.Legacy_ID,'') <> '' THEN BSA_Operator.Legacy_ID
	ELSE
    	CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(50))
	END
    	AS Operator_ID,
        BSA_Operator.Operator_Name, BSA_Operator.Operator_City, BSA_Operator.Operator_State, Legacy_ID
	FROM 				Contract_Operators,BSA_operator
	WHERE				BSA_Operator.BSA_Operator_ID = Contract_Operators.BSA_Operator_ID
	AND 				Contract_Operators.Contract_Main_id = #variables.qProgramInfo.contract_main_id[1]#
	AND 				Contract_Operators.deleted = 0
	ORDER BY		BSA_Operator.Operator_Name
</cfquery> --->

<!---
3/9/08: We need this to be an int... so I am grabbing both. At display level, we will display Legacy if we have it, otherwise we will display other.
SELECT
BSA_Operator.Operator_Name, BSA_Operator.Operator_City, BSA_Operator.Operator_State,BSA_Operator.Legacy_ID,BSA_Operator.BSA_Operator_ID
FROM 				Contract_Operators,BSA_operator
WHERE				BSA_Operator.Legacy_ID IS NOT NULL
AND 				Contract_Operators.deleted = 0
ORDER BY			BSA_Operator.Operator_Name
employ this...
Deepa's suggestion: CASE WHEN ISNULL(BSA_Operator.Legacy_ID,'') <> '' THEN BSA_Operator.Legacy_ID
			ELSE CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(50))
			END AS Operator_ID
ACTION: SAVE This MAY be needed for printed output...qGetDistributorInfo
	CASE WHEN BSA_Operator.Legacy_ID IS NOT NULL THEN BSA_Operator.Legacy_ID
			ELSE CAST(BSA_Operator.BSA_Operator_ID AS VARCHAR(50))
			END AS Operator_ID, RBL per TF ...
Contract_Operators.BSA_Operator_ID, --->

<!--- [begin] For HTML Letters, Get the "Bid Request" information --->
<cfset bidReqObj = CreateObject("component", "components.programs.bid_request.BidRequestManager")>
<cfset getbidReqObj = bidReqObj.getBidRequest(CSL_Contract_Main_ID) />

<cfset structInsert(variables.stPDFIntroInfo,"open_date",getbidReqObj.getOpenDate(),true)>
<cfset structInsert(variables.stPDFIntroInfo,"date_needed",getbidReqObj.getDateNeeded(),true)>
<cfset structInsert(variables.stPDFIntroInfo,"expected_reply_date",getbidReqObj.getExpectedReplyDate(),true)>
<!--- [end] For HTML Letters, Get the "Bid Request" information --->


<!--- let's grab a more accurate document title... --->
<cfquery name="variables.qGetDocumentTitle" datasource="#application.datasource#">
  SELECT	program_control_panel_options.created_type
  FROM		program_control_panel_options
  INNER JOIN contract_main ON contract_main.programtype_id = program_control_panel_options.programcontrol_panel_options_id
  WHERE		contract_main.contract_main_id = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
</cfquery>

<!--- The position label should be of the "creating_user_position_id" in the program --->
<cfquery name="variables.qGetPosition" datasource="#application.datasource#">
  SELECT	position_label
  FROM		user_positions
  WHERE user_positions_id =  <cfqueryparam value="#variables.qProgramInfo.creating_user_position_id[1]#" cfsqltype="cf_sql_integer">
</cfquery>

<cfset variables.lsFreightNotes = valueList(qProgramInfo.freight_notes,',')>
	<!--- ACTION TO DELETE
	<cfset  structInsert(variables.stPDFIntroInfo,"freight_notes",variables.qProgramInfo.freight_notes[1],true)>
	 --->
	<cfset structInsert(variables.stPDFIntroInfo, "freight_notes", variables.lsFreightNotes, true)>
	<cfset structInsert(variables.stPDFIntroInfo, "responsible_sales_person_email", variables.qUserInfo.user_email[1],true)>
	<cfset structInsert(variables.stPDFIntroInfo, "responsible_sales_person_first_name", variables.qUserInfo.name_first[1],true)>
	<cfset structInsert(variables.stPDFIntroInfo, "responsible_sales_person_user_id", variables.qProgramInfo.responsible_user_id[1],true)>
	<cfset structInsert(variables.stPDFIntroInfo, "responsible_sales_person_last_name", variables.qUserInfo.name_last[1],true)>
	<cfset structInsert(variables.stPDFIntroInfo, "responsible_sales_person_phone", variables.qUserInfo.user_work_phone[1],true)>
	<cfset structInsert(variables.stPDFIntroInfo, "responsible_sales_person_title", variables.qGetPosition.position_label,true)>
	<cfset structInsert(variables.stPDFIntroInfo, "program_notes", variables.qProgramInfo.notes[1], true)>
	<!--- <cfset structInsert(variables.stPDFIntroInfo,"template_name",variables.company_name
	 & ' ' & appSettings.getOperatorLetterName(),true)> --->
	<cfset structInsert(variables.stPDFIntroInfo, "template_name", variables.qGetDocumentTitle.created_type[1],true)>

	<!--- let's identify our company_main_id from db instead of request.accessstructure for automated letter generation... --->
	<cfquery name="variables.qGetCompanyMainID" datasource="#application.datasource#">
		SELECT		company_main_ID
		FROM		company_main
		WHERE		ltrim(rtrim(company_name)) = '#trim(variables.company_name)#'
	</cfquery>

	<cfset structInsert(variables.stPDFIntroInfo, "company_id", variables.qGetCompanyMainID.company_main_ID[1],true)>

	<!--- Total Program Value STRING [begin] --->
	<!--- Get the default Unit of time (uot) settings being used in the control panel-programs-settings--->
	<cfquery name="variables.qGetSettings" datasource="#application.datasource#">
		SELECT		Volume_UOT_ID
		FROM		_Users_Settings
		WHERE		User_ID		=		'#trim(variables.qGetCompanyMainID.company_main_ID[1])#'
	</cfquery>

	<!---  TO DELETE #request.accessStructure.Company_Main_ID# --->
	<cfset variables.program_span = datediff('d', variables.qProgramInfo.contract_start_date[1], variables.qProgramInfo.contract_end_date[1]) + 1>
	<cfset variables.progVolQty = createObject("component", "components.programs.volume.ProgramVolume").getProgramQty(variables.qProgramInfo.contract_main_id[1],
	                                                                                                                  variables.program_span,
	                                                                                                                  variables.qGetSettings.Volume_UOT_ID)/>
	<cfset variables.program_qtg_cases = variables.progVolQty.programQtgCases>
	<cfset variables.program_qtg_lbs = variables.progVolQty.programQtglbs>
	<cfset variables.volume_UOT_cases = variables.progVolQty.volumeUOTCases>
	<cfset variables.volume_UOT_lbs = variables.progVolQty.volumeUOTlbs>

	<cfif isStruct(variables.progVolQty)>
		<cfset variables.total_program_value = trim(numberformat(round(variables.program_qtg_cases), '___,___,___,___,___,___')) & " Cases / " & trim(numberformat(round(variables.program_qtg_lbs),'___,___,___,___,___,___')) & " Pounds">
	<cfelse>
		<cfset variables.total_program_value = trim(numberformat(round(variables.program_info_detail.contract_quantity[1]), '___,___,___,___,___,___')) & " " & getContractUOMLabel.Unit_Of_Measure_Desc>
	</cfif>

	<!--- Maybe #application.returned_customer_setting.Program_Quantity_Label# --->
	<cfset structInsert(variables.stPDFIntroInfo, "total_program_value", variables.total_program_value,true)>
	<cfset structInsert(variables.stPDFIntroInfo, "program_qtg_cases", variables.program_qtg_cases, true)>
	<!--- Total Program Value STRING [end] --->

	<!--- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	|||||||||||||||| BID REQUEST STATUS [begin] ||||||||||||||||||
	||||||||||||||| pending | won | split | lost |||||||||||| --->
	<!--- First of all, IF the BidRequestStatusOn switch is turned ON (1), then... --->
	<cfif getprogramdetails.BidRequestStatusOn>

		<cfswitch expression="#variables.bid_request_status_id#">
			<cfcase value="0,1" delimiters=",">
				<!--- ACTION: show ALL products [begin] --->
				<!--- if 0 --->
				<cfif NOT variables.bid_request_status_id>
					<cfset variables.bid_request_status = "">
					<!--- if 1 --->
				<cfelse>
					<cfset variables.bid_request_status = "Pending">
				</cfif>
				<!--- ACTION: show ALL products [end] --->
			</cfcase>
			<cfcase value="2,3,4" delimiters=",">
				<!--- ACTION: FILTER products [begin] --->
				<!--- 1.) let's grab the id's... --->
				<cfset useLakebaseForvariables_qGetProductIDs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_product_bid_info")>
<cfif useLakebaseForvariables_qGetProductIDs>
	<cftry>
		<cfset variables.qGetProductIDs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_product_bid_info", {
				"program_id" = "eq.#variables.qProgramInfo.contract_main_id[1]#",
				"won" = "eq.1",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForvariables_qGetProductIDs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForvariables_qGetProductIDs>
<cfquery name="variables.qGetProductIDs" datasource="#application.datasource#">
					SELECT	Product_ID
					FROM	program_product_bid_info
					WHERE	program_product_bid_info.program_id = #variables.qProgramInfo.contract_main_id[1]#
					AND		program_product_bid_info.won = 1
				</cfquery>
</cfif>
				<!--- 2.) make an overall list of the id's... --->
				<cfset variables.lsProductIDs = valueList(variables.qGetProductIDs.Product_ID, ",")>

				<!--- FILTER fixed_price [begin] --->
				<cfif getFixedPriceProducts.recordCount>
					<cfif len(variables.lsProductIDs)>

						<cfquery name="qStatusFilteredFixedPriceProducts" datasource="#application.datasource#">
             SELECT 	*
             FROM	##TMP_Fixed_Price_Details
						 WHERE Contract_Main_ID = #variables.qProgramInfo.contract_main_id[1]#
						 AND 	BSA_Foodservice_Items_Master_ID IN (#replace(listQualify(variables.lsProductIDs,"'",",")," ","","ALL")#)
						</cfquery>

						<cfset getFixedPriceProducts = variables.qStatusFilteredFixedPriceProducts>
					<cfelse>
						<!--- IF No approved id's, then let's not show this section... --->
						<cfset variables.stPDFBodyInfo.bDisplayFixedPrice = 0>
					</cfif>
				</cfif>
				<!--- FILTER fixed_price [end] --->
				<!--- FILTER rebate [begin] --->
				<cfif IsDefined("getRebateProdCount") AND getRebateProdCount.ProdCount>
						<cfif len(variables.lsProductIDs)>
						<cfquery name="variables.qStatusFilteredRebateProducts" datasource="#application.datasource#">
							SELECT *
							FROM	##TMP_Rebate_Price_Details
              WHERE 	BSA_Foodservice_Items_Master_ID IN (#replace(listQualify(variables.lsProductIDs,"'",",")," ","","ALL")#)
						</cfquery>
						<cfset getRebateProducts = variables.qStatusFilteredRebateProducts>
				<cfelse>
						<!--- IF No approved id's, then let's not show this section... --->
						<cfset variables.stPDFBodyInfo.bDisplayRebate = 0>
						</cfif>
				</cfif>
				<!--- FILTER rebate [end] --->
				<!--- FILTER bid_request [begin] --->
				<cfif getBidRequestProducts.recordCount>
					<cfif len(variables.lsProductIDs)>
						<cfquery name="variables.qStatusFilteredBidRequestProducts" dbtype="query">
							SELECT *
							FROM	getBidRequestProducts
							WHERE BSA_Foodservice_Items_Master_ID IN (#replace(listQualify(variables.lsProductIDs, "'", ",")," ","", "ALL")#)
						</cfquery>
						<cfset getBidRequestProducts = variables.qStatusFilteredBidRequestProducts>
					<cfelse>
						<!--- IF No approved id's, then let's not show this section... --->
						<cfset variables.stPDFBodyInfo.bDisplayBidRequest = 0>
					</cfif>
				</cfif>
				<!--- FILTER bid_request [end] --->
				<!--- LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS
				LS LS LS LS  NOTE: lump_sum handled in the 2 lump_sump include modules  LS LS LS LS LS
				LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS LS  --->
				<!--- NOTE: Freight summary WILL reflect the NET Fixed Price query AFTER this logic --->
				<cfif variables.bid_request_status_id EQ 2>
					<cfset variables.bid_request_status = "Won">
				<cfelseif variables.bid_request_status_id EQ 3>
					<cfset variables.bid_request_status = "Split">
				<cfelseif variables.bid_request_status_id EQ 4>
					<cfset variables.bid_request_status = "Lost">
				</cfif>
				<!--- ACTION: FILTER products [end] --->
			</cfcase>
		</cfswitch>

		<!--- Otherwise... IF the BidRequestStatusOn switch is turned OFF (0), then... --->
	<cfelse>
		<cfset variables.bid_request_status_id = 0>
		<cfset variables.bid_request_status = "">
	</cfif>
	<!--- ||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	|||||||||||||||| BID REQUEST STATUS [end] ||||||||||||||||||||
	||||||||||||||| pending | won | split | lost |||||||||||| --->
	<!--- || 1 || create our pdf document INTRO container... [end] --->
	<!--- || 2 || create our pdf document HEADER container... (alpha) [begin] --->
	<cfset variables.stPDFHeaderInfo = structNew()>
	<cfset structInsert(variables.stPDFHeaderInfo, "company_address", application.appsettingsget.letters_address,true)>
	<cfset structInsert(variables.stPDFHeaderInfo, "company_logo_path", application.appsettingsget.letters_company_logo_path,true)>
	<cfset structInsert(variables.stPDFHeaderInfo, "contract_number", variables.qProgramInfo.contract_number[1],true)>
	<cfset structInsert(variables.stPDFHeaderInfo, "program_id", variables.qProgramInfo.contract_main_id[1],true)>
	<cfset structInsert(variables.stPDFHeaderInfo, "program_title", variables.qProgramInfo.contract_title[1],true)>
	<!--- BID REQUEST STATUS NOTE: this is always injected into the header structure HERE, but not the
	XML ever, because it may change prior to subsequent letter edits - letters will always display current status from DB --->
	<cfset structInsert(variables.stPDFHeaderInfo, "program_bid_request_status", variables.bid_request_status,true)>
	<!--- BID REQUEST STATUS NOTE: this is always injected into the header structure HERE, but not the
	XML ever, because it may change prior to subsequent letter edits - letters will always display current status from DB --->
	<cfset structInsert(variables.stPDFHeaderInfo, "program_bid_request_status_id", variables.bid_request_status_id,true)>
	<!--- || 2 || create our pdf document HEADER container... [end] --->
	<!--- || 3 || create our pdf document END container... [begin] --->
	<cfset variables.stPDFEndInfo = structNew()>

	<!--- Get Clauses for THIS Program ID [begin] --->
	<cfquery name="variables.qProgramClauseInfo" datasource="#application.datasource#">
		SELECT Clause_Library.Clause_Library_Body,Clause_Program.Clause_Library_ID
		FROM	Clause_Library,Clause_Program
		WHERE	Clause_Library.Clause_Library_ID = Clause_Program.Clause_Library_ID
		AND	Clause_Program.Program_ID = #variables.qProgramInfo.contract_main_id[1]#
		AND  Clause_Library.deleted = 0
		AND	Clause_Program.deleted = 0
	</cfquery>
	<!--- || 3 || create our pdf document END container... [end] --->
	<!--- || 4 || NO FOOTER container structure... --->
	<!--- ================================================================================================
	===== Compile Specific Structures of VARS to explicitly pass to the 3 Generator Files [end] ==========
	================================================================================================= --->
	<!--- 1.) Distributor [begin] --->
	<cfset structInsert(variables, "qProgramDistributorInitial", variables.qProgramDistributorInfo, true)>
	<cfset structInsert(variables, "qProgramAllDistributorInitial", variables.qProgramAllDistributorInfo,true)>
	<!--- 1.) Distributor [end] --->
	<!--- 2.) Operator [begin] --->
	<cfset structInsert(variables, "qProgramOperatorInitial", variables.qProgramOperatorInfo, true)>
	<!--- 2.) Operator [end] --->
	<!--- Dev Note: KAL; D15961: Include claim rate on PDF Letters. Lets get the claim rates for the  distributors --->
	<cfquery name="variables.qGetFixedComponentPaymentType" datasource="#application.datasource#">
		SELECT Count(*) as ComponentClaimRateCount
		FROM Program_Fixed_Component
		INNER JOIN Payment_Type
		ON Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
		WHERE Program_Fixed_Component.Program_ID = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
		AND Program_Fixed_Component.deleted = 0
		AND		Payment_Type.Include_Claim_Rates_Report = 1
	</cfquery>

	<!--- Dev Note:Milan (24557). Add "Item" to this table. On freight, this table is being queried only for
	"BSA_Foodservice_Customers_ID" and "Component_Type" and so I removed the indexes on the other fields.
	On fixed price, more fields are being used in the query, but that query runs only when we have 1 distributor (15961) and so
	the freight query is the more important one
	--->
	<!--- Dev Note: Milan (24684).- url.pages has a value when we click on the "Modify" letter image to edit a letter.
	      There is no need to run "claim reports" while loading the letter in the "edit" mode
	--->

<cfset variables.qProgramClaimRatesReport = queryNew("expected_fixed_price_claim_rate_per_case, net_weight", "Decimal, Decimal") />
	<cfif url.pages eq "">
		<cfset variables.lsCustomerIDs = valueList(variables.qProgramDistributorInitial.BSA_Foodservice_Customers_ID, ",")>

		<cfset useLakebaseForqDefaultConfig = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("claim_rates_setting")>
<cfif useLakebaseForqDefaultConfig>
	<cftry>
		<cfset qDefaultConfig = application.oLakebase.toQuery(
			application.oLakebase.selectRows("claim_rates_setting", {
				"deleted" = "eq.0",
				"default_setting" = "eq.1",
				"select" = "config_id"
			}), "config_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDefaultConfig = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDefaultConfig>
<cfquery name="qDefaultConfig" datasource="#application.datasource#">
			SELECT Config_ID
			FROM CLAIM_RATES_SETTING
			WHERE Deleted = 0
			AND default_setting = 1
		</cfquery>
</cfif>

		<cfquery name="getProgramNumber" datasource="#application.datasource#">
			SELECT contract_number,ISNULL(CLAIM_RATES_SETTING.Config_ID, #qDefaultConfig.Config_ID#) AS config_id
			FROM Contract_Main
			INNER JOIN Program_Control_Panel_Options
			ON Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
			LEFT JOIN CLAIM_RATES_SETTING ON Program_Control_Panel_Options.Claim_Rates_Config_ID = CLAIM_RATES_SETTING.Config_ID
			WHERE Contract_Main.Contract_Main_ID = <cfqueryparam value="#CSL_Contract_Main_ID#" cfsqltype="cf_sql_integer">
		</cfquery>

		<!--- get info as to whether the claim reports should be handled for groups. --->
		<cfset useLakebaseForgetClaimRatesInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("claim_rates_setting")>
<cfif useLakebaseForgetClaimRatesInfo>
	<cftry>
		<cfset getClaimRatesInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("claim_rates_setting", {
				"config_id" = "eq.#getProgramNumber.config_id#",
				"select" = "by_group"
			}), "by_group"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetClaimRatesInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetClaimRatesInfo>
<cfquery name="getClaimRatesInfo" datasource="#application.datasource#">
			SELECT By_Group
			FROM CLAIM_RATES_SETTING
			WHERE Config_ID = #getProgramNumber.config_id#
		</cfquery>
</cfif>

		<!--- Dev Note: Milan (24785). Originally, this page used to call the "components.programs.ProgramClaimRatesReport",
		but that component requires a query to be returned and I am leaving it as it is for the original claim report.
		I have basically copied the code from "getProgramClaimRatesReport" function on  "components.programs.ProgramClaimRatesReport".
		I did it so that cfquery (coldfusion) does not have to load the data. I can rely on  ##tmp_claim_report_results table to query
		the data (using cfquery) for a single distributor (one by one) in the letter. ##tmp_claim_report_result will
		contain the records of all the distributors.
		--->
		<!--- we do not show "claim rates" for "letters available - custom 2" app setting OR when "Dont_Show_Claim_Rates_On_Program_Letters" app setting is ON  --->
		<cfif appSettings.getlettersavailable() neq 2 AND val(appSettings.get_Setting('Dont_Show_Claim_Rates_On_Program_Letters')) eq '0'>
			<cfquery name="variables.qProgramClaimRatesReportResults" datasource="#application.datasource#">
				if object_id('tempdb..##tmp_claim_report_results') is not null
				drop table ##tmp_claim_report_results

				if object_id('tempdb..##tmp_cmid') is not null
				drop table ##tmp_cmid

				create table ##tmp_cmid (contract_number varchar(35))

				insert into ##tmp_cmid (contract_number) values ('#getProgramNumber.contract_number#')

				if object_id('tempdb..##tmp_distid') is not null
				drop table ##tmp_distid

				create table ##tmp_distid (distributor_id uniqueidentifier)
				<cfloop list="#variables.lsCustomerIDs#" index="distid">
					insert into ##tmp_distid (distributor_id) values ('#distid#')
				</cfloop>

				if object_id('tempdb..##tmp_oprid') is not null
				drop table ##tmp_oprid

				create table ##tmp_oprid (operator_id varchar(50))

				CREATE TABLE ##tmp_claim_report_results
				(
				Expected_fixed_price_claim_rate_per_case decimal(20, 2),
				net_weight float,
				BSA_Foodservice_Customers_ID varchar(50),
				BSA_Foodservice_Items_Master_ID varchar(50),
				Component_Name_ID int,
				Component_Type varchar(15),
				Item varchar(100)
				)
				CREATE CLUSTERED INDEX [I_claim_report_results_tmp] ON [##tmp_claim_report_results]([BSA_Foodservice_Customers_ID],[Component_Type]) ON [PRIMARY]
				<cfif appSettings.getProgramClaimRatesReportAvailable()>
					EXEC PROGRAM_CLAIM_RATES_REPORT '#url.claim_rate_date#', 1, 1, #val(getClaimRatesInfo.By_Group)#,#url.IncludeInactive#
				</cfif>

				drop table ##tmp_cmid
				drop table ##tmp_distid
			</cfquery>
		</cfif>
	</cfif>
</cfsilent>