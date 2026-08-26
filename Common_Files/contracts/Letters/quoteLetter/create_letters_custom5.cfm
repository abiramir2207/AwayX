<!---------------------------------------------------------------------------------------------------------------------
	Template: C:\Forge\base\AwayX\Common_Files\contracts\Letters\quoteLetter\create_letters_custom5.cfm
	Date:     Nov 2020
	Author:   Chris Nguyen
	Purpose:  Generate Quote Letter Custom Type 5 ( Huhtamaki )

	Required parameter:
	- URL.Contract_Main_ID (integer)
----------------------------------------------------------------------------------------------------------------------->

<cfprocessingdirective pageencoding="utf-8">

<cfparam name="request.language" default="">

<cfif request.language eq "french">
	<cfset SetLocale("fr_FR")>
</cfif>

<!--- The Page Length Counter; Possible Values are in increments of 10 --->
<cfset VARIABLES.thePageLength = 0 />

<cfscript>
    param name="form.Non_Blended_Delivered_Freight_Matrix_Excel_Export" default="0";
    param name="form.Blended_Delivered_Freight_Matrix_Excel_Export" default="0";
    param name="form.escalator_excel_export" default="0";
    param name="form.term" default="";
	param name="form.txtNotes" default="";

    param name="form.fixed_price" default="0";
    param name="form.rebate"      default="0";
    param name="form.lump_sum"    default="0";

    vars = StructNew();
	vars.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
	vars.programCFC = CreateObject('component', 'components.programs.display_program.viewProgramTemplateManager');
	vars.LetterManager = CreateObject("component", "mvc.Models.LetterManager");
	vars.BusinessSegmentManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
	vars.GenProgramManager = CreateObject("component", "components.programs.programManager");
	vars.PaymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager") ;
	vars.RFPManager = CreateObject("component", "mvc.Models.Program.RfpManager");

	vars.qOperators = vars.programCFC.getOperators( URL.Contract_Main_ID );
 	//vars.qFixedPricedItemsOld = vars.programCFC.getFixedPriceOnEmail( URL.Contract_Main_ID );
	vars.qFixedPricedItems = vars.RFPManager.getRfpFixedProductData(contractId=URL.Contract_Main_ID, ExcludeProductsWithNoPrice=1 );
	vars.qLabels = createObject("component", "components.settings.Labels.Labels").init();

	LegacyIdOn = vars.BusinessSegmentManager.getOperatorlegacyIDOn(URL.Contract_Main_ID);
    PAGE_BREAK_GOES_HERE = "PAGE_BREAK_GOES_HERE";
    MAX_ROWS_PER_PAGE = 45;
</cfscript>

<cfquery name="vars.qTemplateLetterSettings" datasource="#application.datasource#">
	SELECT	CM.ProgramType_ID, CM.Business_Segment_ID,BS.Business_Unit_Desc,
			PCPO.Label_Set_Default,PCPO.Operator_Letters_Required,PCPO.Distributor_Letters_Required,PCPO.Distributor_Fixed_Pricing,PCPO.Operator_Fixed_Pricing,
			PCPO.Distributor_Rebate,PCPO.Operator_Rebate,PCPO.Distributor_Lumpsum,PCPO.Operator_Lumpsum,PCPO.Distributor_Paysto_Opr,PCPO.Distributor_Paysto_Dis,
			PCPO.Operator_Paysto_Opr,PCPO.Operator_Paysto_Dis,PCPO.Operator_Bid_Request,PCPO.Distributor_Bid_Request,PCPO.Pre_Defined_Page_Break,
			PCPO.Include_Freight_Summary,PCPO.Freight_UOM,PCPO.Distributor_UOM,PCPO.Operator_UOM,PCPO.Distributor_Discount_Type,PCPO.Operator_Discount_Type,
			PCPO.Distributor_Component_Name,PCPO.Operator_Component_Name,PCPO.Distributor_Claim_Mechanism,PCPO.Operator_Claim_Mechanism,PCPO.Distributor_Payable_To,PCPO.Operator_Payable_To,
			PCPO.Distributor_Pricing_Type,PCPO.Operator_Pricing_Type,PCPO.Distributor_Payment_Frequency,PCPO.Operator_Payment_Frequency,PCPO.Distributor_GTIN,PCPO.Operator_GTIN,
			PCPO.Distributor_Product_Attribute_1,PCPO.Operator_Product_Attribute_1,PCPO.Email_Letters_On_Approval,PCPO.Generate_Letters_On_Approval,
			PCPO.Distributor_Price_Brackets,PCPO.Operator_Price_Brackets,PCPO.Distributor_Open_Date,PCPO.Operator_Open_Date,PCPO.Distributor_Date_Needed,PCPO.Operator_Date_Needed,
			PCPO.Distributor_Expected_Date,PCPO.Operator_Expected_Date,PCPO.Distributor_Est_Value_Volume,PCPO.Operator_Est_Value_Volume,PCPO.Distributor_Dist_Product_Codes,
			PCPO.Distributor_Line,PCPO.Operator_Line,PCPO.Distributor_Notes,PCPO.Operator_Notes,
			PCPO.Letters_Accepted_By,PCPO.Operator_Rate_Change,PCPO.Distributor_Rate_Change,PCPO.Operator_Display_Product_Groups,PCPO.Distributor_Display_Product_Groups,
			PCPO.Customer_Acceptance,PCPO.Distributor_Customer_Acceptance_Block,PCPO.Operator_Customer_Acceptance_Block,
			PCPO.Operator_Broker_Number,PCPO.Distributor_Broker_Number,PCPO.Operator_UPC,PCPO.Distributor_UPC,PCPO.Operator_Approval_Date,PCPO.Distributor_Approval_Date,
			PCPO.Distributor_Generate_Excel_File_Product_Group_Members,PCPO.Operator_Generate_Excel_File_Product_Group_Members
	FROM Program_Control_Panel_Options PCPO
	INNER JOIN Contract_Main CM
		ON CM.Contract_Main_ID = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
	LEFT JOIN Business_Segment BS
		ON CM.Business_Segment_ID = BS.Business_Segment_ID
	WHERE PCPO.ProgramControl_Panel_Options_ID = CM.ProgramType_ID
</cfquery>

<cfset bDisplayProductGroups = 0>
<!--- Dev Note(78291) - When "Product Group Sequencing" app setting is ON, we we need to show the added groups and products and
always need to sort first by "pricing_level_id". --->
<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'>
	<cfset vars.qRebateItems = vars.programCFC.getRebateOnEmail(Contract_Main_ID=URL.Contract_Main_ID, getItemLevel=0)>
<!--- If the letters tab of the template has "Display product groups" ON for distributor and operator loetters --->
<cfelseif vars.qTemplateLetterSettings.Operator_Display_Product_Groups eq 1 AND vars.qTemplateLetterSettings.Distributor_Display_Product_Groups eq 1>
	<cfset bDisplayProductGroups = 1>
	<!--- If product groups exist, get product groups. else just get the products --->
	<cfset vars.qRebateItems = vars.programCFC.getRebateOnEmail(Contract_Main_ID=URL.Contract_Main_ID, getItemLevel=0)>
	<!--- If the letters tab of the template has "Display product groups" OFF for distributor and operator loetters --->
<cfelseif vars.qTemplateLetterSettings.Operator_Display_Product_Groups eq 0 AND vars.qTemplateLetterSettings.Distributor_Display_Product_Groups eq 0>
	<!--- If product groups exist, get product group members, else just get the products --->
	<cfset vars.qRebateItems = vars.programCFC.getRebateOnEmail(Contract_Main_ID=URL.Contract_Main_ID, getItemLevel=1)>
</cfif>

<cfinvoke component="components.programs.business_segment.BusinessSegmentManager"
		method="isEnabled"
		returnVariable="busSegMgr.isEnabled">
</cfinvoke>
<cfset vars.qPrgDistributors = vars.programCFC.getDistributors( URL.Contract_Main_ID, busSegMgr.isEnabled, false )>
<cfset productLabel = vars.qLabels.GetProgramLettersLabels('Product').Program_Letters_Labels_Label>

<cfoutput>
	<cfif not StructKeyExists(URL, "All_Distributors")>
		<cfquery name="vars.qDistributors" dbtype="query">
			SELECT *
			FROM  vars.qPrgDistributors
			WHERE BSA_Foodservice_Customers_ID IN (<cfqueryparam value='#form.operLtrDistributors#' list="true">)
			</cfquery>
	</cfif>
</cfoutput>

<!--- Queries for the page --->
<!--------------------------------------------------------------------------------------------------------------------->
<cfoutput>
	<cfquery name="vars.qProgram" Datasource="#application.datasource#">
		SELECT	Contract_Main_ID
				,Contract_Title
				,Contract_Number
				,Revision_Version = CASE
									WHEN LEN(revision_version) = 4 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 4)
									WHEN LEN(revision_version) = 5 THEN RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 5)
									ELSE RIGHT('000' + CAST(revision_version AS VARCHAR(10)), 3)
								END
				,Contract_Created_Date
				,Effective_Start_Date
				,Effective_End_Date
				,Contract_Start_Date
				,Contract_End_Date
				,Approved
				,CONVERT(VARCHAR(10), Approval_Date, 101) AS Approval_Date
				,DateDiff(d, Effective_Start_Date, Effective_End_Date)+1 as Effective_Span
				,RSP_Name = _Users.Name_First + ' ' + _Users.Name_Last
				,RSP_Phone = _Users.Work_Phone_1 + ' ' + _Users.Work_Phone_2 + ' ' + _Users.Work_Phone_3
				,_Users.Work_Phone_1
				,_Users.Work_Phone_2
				,_Users.Work_Phone_3
				,RSP_Email = _Users.User_Email
				,RSP_Title = _Users.Title
				,Creator = _Users2.Name_First + ' ' + _Users2.Name_Last
				,ProgramType_ID
				,LTRIM(RTRIM(Notes)) As Notes
		FROM Contract_Main
		LEFT JOIN _Users ON Contract_Main.Responsible_user_ID = _Users.User_ID
		LEFT JOIN _Users _Users2 ON Contract_Main.Creator_ID = _Users2.User_ID
		WHERE Contract_Main.Contract_Main_ID = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
	</cfquery>

	<cfquery name="vars.qClauses" datasource="#application.datasource#">
		SELECT l.Clause_Library_Body, l.Clause_Library_Body_French
			FROM Clause_Program p
				INNER JOIN dbo.Clause_Library l ON l.Clause_Library_ID = p.Clause_Library_ID AND l.Deleted = 0
		WHERE p.Program_Id = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
		AND p.Deleted = 0
		ORDER BY l.Clause_Category_ID
	</cfquery>

</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<!---------------------------------------------------- QuoteLetter ---------------------------------------------------->
<!--------------------------------------------------------------------------------------------------------------------->

<!--- Call the functions to generate the different content sections of letter --->
<!--- Get products & rate section; This is common for both the operators & distributor letters --->

<cfset VARIABLES.theLetterBody =  "" />  <!--- temp variable for letter body --->

<cfset numberOfLinesOnPage =  fnNumberOfLinesBasedonImageSize()>

<cfset numberOfLinesOnPage =  fnNumberOfLinesBasedonProgramNotes(numberOfLinesOnPage)>

<cfset variables.LetterTypeList = "">

<!----------------------->
<!--- operator letter --->
<!----------------------->
<cfif len(form.operLtrDistributors)>

	<cfif vars.qOperators.recordCount> <!--- AND vars.qTemplateLetterSettings.Operator_Letters_Required --->

	<cfset variables.distributorStruct = structNew() />
	<cfset variables.operatorNamesList = valueList(vars.qOperators.Operator_Name, ", ") />

  <cfset vars.qDiscountTypes = ""/>
  <cfset vars.qDiscountTypes = vars.LetterManager.fnDiscountTypes(letterType="1", Contract_Main_ID=URL.Contract_Main_ID)/>

	<!--- add header section --->
	<cfset variables.letterHeaderSection =  fnLetterHeader(letterType="1", operatorNamesList=variables.operatorNamesList, distributorStruct=variables.distributorStruct) />

	<!--- add message section --->
	<cfset variables.letterMessageSection =  fnLetterMessage(letterType="1", operatorName="", distributorName="") />

	<!--- add operator section --->
	<cfset variables.letterOperatorsSection = "" />
	<cfset variables.letterOperatorsSection =  fnLetterOperators() />

	<!--- add distributor section --->
	<cfset variables.letterDistributorsSection = "" />
	<cfif len(form.operLtrDistributors) AND vars.qPrgDistributors.RecordCount>
    	<cfset variables.letterDistributorsSection =  fnLetterDistributors(1) />
	</cfif>

	<!--- add signature section for operator --->
	<cfif vars.qTemplateLetterSettings.Operator_Customer_Acceptance_Block eq 1>
		<cfset VARIABLES.letterOperatorSignatureSection =  fnSetSignature() />
	</cfif>

	<!--- operator letter body --->
	<cfset VARIABLES.theLetterBody =  fnletterProducts(
		letterType  			= 1,
		discountTypeDisplay 	= vars.qTemplateLetterSettings.Operator_Discount_Type,
		componentNameDisplay 	= vars.qTemplateLetterSettings.Operator_Component_Name,
		operPaysToDisplay 		= vars.qTemplateLetterSettings.Operator_Paysto_Opr,
		distPaysToDisplay 		= vars.qTemplateLetterSettings.Operator_Paysto_Dis,
		payableToDisplay 		= vars.qTemplateLetterSettings.Operator_Payable_To
	) />

	<!--- stitch together letter content parts --->
	<!--- <cfset variables.letterContentGenerated = variables.letterHeaderSection & variables.letterMessageSection & variables.letterOperatorsSection /> --->
		<cfset variables.letterContentGenerated = variables.letterMessageSection />

	<cfif isDefined("VARIABLES.letterDistributorsSection") AND isStruct(VARIABLES.letterDistributorsSection)>
		<cfif isDefined("VARIABLES.letterDistributorsSection.firstPage")>
			<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterDistributorsSection.firstPage />
		</cfif>
		<cfif isDefined("VARIABLES.letterDistributorsSection.remainingPages") AND isArray(VARIABLES.letterDistributorsSection.remainingPages)>
			<cfloop from="1" to="#arrayLen(VARIABLES.letterDistributorsSection.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
				<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterDistributorsSection.remainingPages[VARIABLES.theRemainingPageIndex] />
			</cfloop>
		</cfif>
	</cfif>

	<cfif isDefined("VARIABLES.letterProducts.fixedPrice") AND isStruct(VARIABLES.letterProducts.fixedPrice)>
		<cfif isDefined("VARIABLES.letterProducts.fixedPrice.firstPage")>
			<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.fixedPrice.firstPage />
		</cfif>
		<cfif isDefined("VARIABLES.letterProducts.fixedPrice.remainingPages") AND isArray(VARIABLES.letterProducts.fixedPrice.remainingPages)>
			<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.fixedPrice.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
				<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.fixedPrice.remainingPages[VARIABLES.theRemainingPageIndex] />
			</cfloop>
		</cfif>
	</cfif>


	<cfif isDefined("VARIABLES.letterProducts.rebateProducts") AND isStruct(VARIABLES.letterProducts.rebateProducts)>
		<cfif isDefined("VARIABLES.letterProducts.rebateProducts.firstPage")>
			<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.rebateProducts.firstPage />
		</cfif>
		<cfif isDefined("VARIABLES.letterProducts.rebateProducts.remainingPages") AND isArray(VARIABLES.letterProducts.rebateProducts.remainingPages)>
			<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.rebateProducts.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
				<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.rebateProducts.remainingPages[VARIABLES.theRemainingPageIndex] />
			</cfloop>
		</cfif>
	</cfif>

	<cfif isDefined("VARIABLES.letterProducts.lumpSum") AND isStruct(VARIABLES.letterProducts.lumpSum)>
		<cfif isDefined("VARIABLES.letterProducts.lumpSum.firstPage")>
			<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.lumpSum.firstPage />
		</cfif>
		<cfif isDefined("VARIABLES.letterProducts.lumpSum.remainingPages") AND isArray(VARIABLES.letterProducts.lumpSum.remainingPages)>
			<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.lumpSum.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
				<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.lumpSum.remainingPages[VARIABLES.theRemainingPageIndex] />
			</cfloop>
		</cfif>
	</cfif>

	<!--- 	GROWTH WAS HERE --->

	<cfif isDefined("VARIABLES.letterProducts.clauses")>
		<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.clauses />
	</cfif>

	<cfif isDefined("variables.letterOperatorSignatureSection")>
		<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterOperatorSignatureSection />
	</cfif>

	<!--- save the letter --->
	<cfset fnSaveLetter(1, vars.qOperators.Operator_Name, vars.qOperators.BSA_Operator_ID) />

	<cfset variables.LetterTypeList = ListAppend(variables.LetterTypeList,1)>

	</cfif>
</cfif>

<!-------------------------->
<!--- distributor letter --->
<!-------------------------->

<cfif len(form.distLtrDistributors)>

		<cfquery name="vars.qLtrDistributors" dbtype="query">
			SELECT 	*
			FROM 		vars.qPrgDistributors
			WHERE 	BSA_Foodservice_Customers_ID IN (<cfqueryparam value='#form.distLtrDistributors#' list="true">)
		</cfquery>
		<!--- Add a new row for "All distributors(Start) --->
		<cfset qAllDistributors = QueryNew(ArrayToList(vars.qLtrDistributors.getColumnList())) />
		<cfset newRow = QueryAddRow(vars.qLtrDistributors) />
		<cfset querySetCell(vars.qLtrDistributors, "name", "All Distributors")>
		<!--- Add a new row for "All distributors(End) --->

		<cfset vars.qDiscountTypes = ""/>
		<cfset vars.qDiscountTypes = vars.LetterManager.fnDiscountTypes(letterType="2", Contract_Main_ID=URL.Contract_Main_ID)/>
		<cfset variables.operatorNamesList 		= valueList(vars.qOperators.Operator_Name, ", ") />
		<cfoutput query="vars.qLtrDistributors">
			<!--- Reset the Page Length Counter --->
			<cfset VARIABLES.thePageLength = 0 />

			<cfif vars.qLtrDistributors.name eq "All Distributors">
				<!--- add header section --->
				<cfset variables.letterHeaderSection =  fnLetterHeader(letterType="2", operatorNamesList=variables.operatorNamesList, distributorStruct=structNew()) />
				<!--- change operatorNamesList to "", if this is an issuein distributor letter --->

				<!--- add message section --->
				<cfset variables.letterMessageSection =  fnLetterMessage(letterType="2", operatorName="", distributorName="") />

			<cfelse>

				<cfset variables.distributorStruct 	= structNew() />
				<cfset variables.distributorStruct 	= { Name=vars.qLtrDistributors.Name, Address=vars.qLtrDistributors.Address_1, City=vars.qLtrDistributors.City, State=vars.qLtrDistributors.State, Zip=vars.qLtrDistributors.ZipCode, Broker_ID =vars.qLtrDistributors.Broker_ID } />

				<!--- add header section --->
				<cfset variables.letterHeaderSection =  fnLetterHeader(letterType="2", operatorNamesList=variables.operatorNamesList, distributorStruct=variables.distributorStruct) />

				<!--- add message section --->
				<cfset variables.letterMessageSection =  fnLetterMessage(letterType="2", operatorName="", distributorName="#vars.qLtrDistributors.Name#") />
			</cfif>

				<!--- build operator section --->
				<cfset variables.letterOperatorsSection = "" />
				<!--- THIS SECTION IS NOT NEEDED FOR custom5, MAY BE NEEDED IF THERE ARE MULTIPLE, BUT WILL NEED MEGHAN TO CONFIRM --->
				<!-- cfset variables.letterOperatorsSection = fnLetterOperators() / --->

				<!--- add distributor section --->
				<cfset variables.letterDistributorsSection = "" />
				<cfif vars.qLtrDistributors.name eq "All Distributors">
					<cfif vars.qPrgDistributors.RecordCount>
						<cfset variables.letterDistributorsSection =  fnLetterDistributors(2) />
					</cfif>
				<cfelse>
						<cfset variables.letterDistributorsSection =  fnLetterDistributors(2, vars.qLtrDistributors.BSA_FoodService_Customers_ID) />
				</cfif>

				<!--- add signature section for distributor --->
				<cfif vars.qTemplateLetterSettings.Distributor_Customer_Acceptance_Block eq 1>
					<cfset VARIABLES.letterDistributorSignatureSection =  fnSetSignature() />
				</cfif>

				<!--- distributor letter body --->
				<cfset variables.theLetterBody =  fnletterProducts(
					letterType  			= 2,
					discountTypeDisplay 	= vars.qTemplateLetterSettings.Distributor_Discount_Type,
					componentNameDisplay 	= vars.qTemplateLetterSettings.Distributor_Component_Name,
					operPaysToDisplay 		= vars.qTemplateLetterSettings.Distributor_Paysto_Opr,
					distPaysToDisplay 		= vars.qTemplateLetterSettings.Distributor_Paysto_Dis,
					payableToDisplay 		= vars.qTemplateLetterSettings.Distributor_Payable_To
				) />

			<!--- stitch together letter content parts --->
			<!--- <cfset variables.letterContentGenerated = variables.letterHeaderSection & variables.letterMessageSection & variables.letterOperatorsSection /> --->
			<cfset variables.letterContentGenerated = variables.letterMessageSection & variables.letterOperatorsSection />

			<!--- Only if the letter is for all distributors, should a "distributor section" be added to the distributor letter --->
			<cfif vars.qLtrDistributors.name eq "All Distributors">
				<cfif isDefined("VARIABLES.letterDistributorsSection") AND isStruct(VARIABLES.letterDistributorsSection)>
					<cfif isDefined("VARIABLES.letterDistributorsSection.firstPage")>
						<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterDistributorsSection.firstPage />
					</cfif>
					<cfif isDefined("VARIABLES.letterDistributorsSection.remainingPages") AND isArray(VARIABLES.letterDistributorsSection.remainingPages)>
						<cfloop from="1" to="#arrayLen(VARIABLES.letterDistributorsSection.remainingPages)#" index="theRemainingPageIndex">
							<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterDistributorsSection.remainingPages[theRemainingPageIndex] />
						</cfloop>
					</cfif>
				</cfif>
			</cfif>

			<cfif isDefined("VARIABLES.letterProducts.fixedPrice") AND isStruct(VARIABLES.letterProducts.fixedPrice)>
				<cfif isDefined("VARIABLES.letterProducts.fixedPrice.firstPage")>
					<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.fixedPrice.firstPage />
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.fixedPrice.remainingPages") AND isArray(VARIABLES.letterProducts.fixedPrice.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.fixedPrice.remainingPages)#" index="theRemainingPageIndex">
						<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.fixedPrice.remainingPages[theRemainingPageIndex] />
					</cfloop>
				</cfif>
			</cfif>

			<cfif isDefined("VARIABLES.letterProducts.rebateProducts") AND isStruct(VARIABLES.letterProducts.rebateProducts)>
				<cfif isDefined("VARIABLES.letterProducts.rebateProducts.firstPage")>
					<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.rebateProducts.firstPage />
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.rebateProducts.remainingPages") AND isArray(VARIABLES.letterProducts.rebateProducts.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.rebateProducts.remainingPages)#" index="theRemainingPageIndex">
						<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.rebateProducts.remainingPages[theRemainingPageIndex] />
					</cfloop>
				</cfif>
			</cfif>

			<cfif isDefined("VARIABLES.letterProducts.lumpSum") AND isStruct(VARIABLES.letterProducts.lumpSum)>
				<cfif isDefined("VARIABLES.letterProducts.lumpSum.firstPage")>
					<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.lumpSum.firstPage />
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.lumpSum.remainingPages") AND isArray(VARIABLES.letterProducts.lumpSum.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.lumpSum.remainingPages)#" index="theRemainingPageIndex">
						<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.lumpSum.remainingPages[theRemainingPageIndex] />
					</cfloop>
				</cfif>
			</cfif>

			<!--- GROWTH WAS HERE --->

			<cfif isDefined("VARIABLES.letterProducts.clauses")>
				<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.clauses />
			</cfif>

			<cfif isDefined("variables.letterDistributorSignatureSection")>
				<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterDistributorSignatureSection />
			</cfif>

			<!--- save the letter --->
			<cfset fnSaveLetter(2, vars.qLtrDistributors.Name, vars.qLtrDistributors.Shr_Ship_To, vars.qLtrDistributors.BSA_Foodservice_Customers_ID) />

			<cfset variables.LetterTypeList = ListAppend(variables.LetterTypeList,2)>

		</cfoutput>

</cfif>

<!--- Dev Note(78294): Generate the "product group members" Excel file.
Note: The logic to figure out whether to generate the Excel file or not is on the same file (\Common_Files\contracts\Letters\generate_group_members_excel.cfm).
Since the "product group members" Excel file is the same regardless of any distributor or operator letter being generated, we just need to generate it once.
"variables.LetterTypeList" logic will make sure the letter does not get generated more than once.
If distributor letter(s) have been generated the the associated template setting is ON OR operatpr letter(s) have been generated the the associated template setting is on.
--->
<cfif (listFind(variables.LetterTypeList,1) neq 0 AND vars.qTemplateLetterSettings.Operator_Generate_Excel_File_Product_Group_Members eq 1)
	OR
	(listFind(variables.LetterTypeList,2) neq 0 AND vars.qTemplateLetterSettings.Distributor_Generate_Excel_File_Product_Group_Members eq 1)
>
	<cfinclude template="\Common_Files\contracts\Letters\generate_group_members_excel.cfm">
</cfif>


<cfif form.non_blended_delivered_freight_matrix_excel_export>
    <cfset report_name = "non_blended_delivered_freight_matrix_excel_export">
    <cfinclude template="#report_name#.cfm">
    <cfset generate_excel_export(report_name, 11, 'Non Blended Freight Matrix')>
</cfif>
<cfif form.blended_delivered_freight_matrix_excel_export>
    <cfset report_name = "blended_delivered_freight_matrix_excel_export">
    <cfinclude template="#report_name#.cfm">
    <cfset generate_excel_export(report_name, 12, 'Blended Freight Matrix')>
</cfif>
<cfif form.escalator_excel_export>
    <cfset report_name = "escalator_excel_export">
    <cfinclude template="#report_name#.cfm">
    <cfset generate_excel_export(report_name, 13 , 'Escalator')>
</cfif>
<cfreturn>

<cfscript>
    function get_function(string name){
        return variables[name];
    }
</cfscript>

<cffunction name="generate_excel_export" output="false">
    <cfargument name="report_name" required="true">
    <cfargument name="report_type" required="true">
    <cfargument name="report_title" required="true">

    <cfscript>
        local.output_path = get_output_path();
        Local.title = Replace(vars.qProgram.Contract_Title,"/","","all");
        Local.title = Replace(Local.title,"\","","all");
        Local.title = REReplace(Local.title,"[^0-9A-Za-z_-]","_","all");
        Local.title = Replace(Local.title,"__","_","all");
        local.output_file =	Local.title
							& " - " & arguments.report_Title
							& ' - ' & dateformat(now(), "mmm dd yyyy")
							& ".xlsx";

        local.export_function = get_function( arguments.report_name );
        local.export_function( { contract_main_id:url.contract_main_id, export_fulpath:local.output_path & '/' & local.output_file, term:form.term } );
    </cfscript>


    <cfquery datasource="#application.datasource#" result="local.qResult">
        UPDATE Program_Letters
           SET  Letter_Name = '#local.output_file#',
				Letter_Path = '#local.output_path#',
				Created_By  = <cfqueryparam value="#request.accessstructure.user_ID#">,
				Created_Date = GETDATE(),
                Deleted = 0
		 WHERE Program_ID = <cfqueryparam value="#URL.Contract_Main_ID#">
		        AND Letter_Type = #arguments.report_type#
    </cfquery>

    <cfif local.qResult.recordCount eq 0>
        <cfquery datasource="#application.datasource#">
            INSERT INTO Program_Letters
                    (    Letter_Type
                        ,Letter_Name
                        ,Letter_Path
                        ,Created_By
                        ,Created_Date
                        ,Program_ID
                    )
            VALUES  (    #arguments.report_type#
                        ,'#local.output_file#'
                        ,'#local.output_path#'
                        ,<cfqueryparam value="#request.accessstructure.user_ID#">
                        ,GETDATE()
                        ,<cfqueryparam value="#URL.Contract_Main_ID#">
                    )
        </cfquery>
    </cfif>
</cffunction>


<!--------------------------------------------------------------------------------------------------------------------->
<!--- Get the number of lines which can fit on a page based on Image size.
Note: below logic is not tested properly for image sizes greater than 40.
--->
<cffunction name="fnNumberOfLinesBasedonImageSize" returntype="numeric" output="false">

	<cfset var number_of_lines = 0>

    <!--- Since this file is going to be used only by huhtamaki, we are hardcoding the logo of huhtamaki here --->
	<cfset var variables.logo_path = 'file:///' & ExpandPath('/images/Logon_Blacksmith/index_huhtamaki_02_small.png')>

	<cfimage
		action="INFO"
		source="#variables.logo_path#"
		structname="objImageInfo"
	/>

	<cfif objImageInfo.height LTE 40>
		<cfset number_of_lines = 40>
	<cfelseif objImageInfo.height LTE 70>
		<cfset number_of_lines = 39>
	<cfelseif objImageInfo.height LTE 100>
		<cfset number_of_lines = 38>
	<cfelseif objImageInfo.height LTE 130>
		<cfset number_of_lines = 37>
	<cfelseif objImageInfo.height LTE 160>
		<cfset number_of_lines = 36>
	<cfelse>
		<cfset number_of_lines = 35>
	</cfif>

	<cfreturn number_of_lines>
</cffunction>

<!--- Get the number of lines which can fit on a page based on program notes --->
<cffunction name="fnNumberOfLinesBasedonProgramNotes" returntype="numeric" output="false">
	<cfargument name="numberOfLinesOnPage" type="numeric">

	<cfset var number_of_lines = 0>

	<cfif len(vars.qProgram.Notes) GTE 4000>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 19>
	<cfelseif len(vars.qProgram.Notes) GTE 3800>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 18>
	<cfelseif len(vars.qProgram.Notes) GTE 3600>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 17>
	<cfelseif len(vars.qProgram.Notes) GTE 3400>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 16>
	<cfelseif len(vars.qProgram.Notes) GTE 3200>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 15>
	<cfelseif len(vars.qProgram.Notes) GTE 3000>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 14>
	<cfelseif len(vars.qProgram.Notes) GTE 2800>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 13>
	<cfelseif len(vars.qProgram.Notes) GTE 2600>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 12>
	<cfelseif len(vars.qProgram.Notes) GTE 2400>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 11>
	<cfelseif len(vars.qProgram.Notes) GTE 2200>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 10>
	<cfelseif len(vars.qProgram.Notes) GTE 2000>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 9>
	<cfelseif len(vars.qProgram.Notes) GTE 1800>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 8>
	<cfelseif len(vars.qProgram.Notes) GTE 1600>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 7>
	<cfelseif len(vars.qProgram.Notes) GTE 1400>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 6>
	<cfelseif len(vars.qProgram.Notes) GTE 1200>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 5>
	<cfelseif len(vars.qProgram.Notes) GTE 1000>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 4>
	<cfelseif len(vars.qProgram.Notes) GTE 800>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 3>
	<cfelseif len(vars.qProgram.Notes) GTE 600>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 2>
	<cfelseif len(vars.qProgram.Notes) GTE 400>
		<cfset number_of_lines = arguments.numberOfLinesOnPage - 1>
	<cfelse>
		<cfset number_of_lines = arguments.numberOfLinesOnPage>
	</cfif>

	<cfreturn number_of_lines>
</cffunction>

<!----------------------->
<!--- create and save --->
<!----------------------->
<cffunction name="fnSaveLetter" returntype="void" output="true">
  <cfargument name="letterType" type="numeric">   <!--- letterType 1=operator; 2=distributor --->
  <cfargument name="customerName" type="string">
  <cfargument name="customerNumber" type="string">
  <cfargument name="customerID" type="string" default="">

  <!------------------------------------ save the letters for operator & distrubutor ------------------------------------>
  <!--- file name format:  Program #  Program Title  Operator Name  Date generated --->
  <cfif arguments.customerName eq "All Distributors">
	<cfset vars.fileName = "#vars.qProgram.Contract_Title#_AllDistributors_#dateformat(now(), "mm_dd_yyyy")#">
  <cfelse>
	<cfset vars.fileName = "#vars.qProgram.Contract_Title#_#arguments.customerName#_#dateformat(now(), "mm_dd_yyyy")#">
  </cfif>
    <cfscript>
        vars.fileName = Replace(vars.fileName,"/","","all");
        vars.fileName = Replace(vars.fileName,"\","","all");
        vars.fileName = REReplace(vars.fileName,"[^0-9A-Za-z_-]","_","all");
        vars.fileName = Replace(vars.fileName,"__","_","all");
    </cfscript>

  <!--- file content with css/grid formatting --->
  <cfsilent>
	<cfsavecontent variable="variables.letterFileContent">
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<title>#vars.fileName#</title>
		<style type="text/css">
		<cfinclude template="/common_files/main_style.css">
		<cfinclude template="/common_files/960_16_col.css">
		.mb74 { margin-top:5px;margin-bottom:5px;font-size:12px; }
		p{font-size:10px;line-height:120%}
		hr{padding:3px 0;border:none;border-top:1px solid ##333}
		.dollar{text-align:right!important}
		.center{text-align:center!important}
		.right{text-align:right!important}
		.opa_group{color:##000;margin:35px 0 5px 0;font-weight:bold}
		.small{font-size:10px;font-weight:normal;position:relative;top:-5px}
		table.Design2{border-top:1px solid ##666;border-left:1px solid ##666;margin-bottom:10px;width:99%}
		table.Design2 td{border-right:1px solid ##666;border-bottom:1px solid ##666;padding:.4em .4em;vertical-align:top}
		table.Design2 th{border-right:1px solid ##666;border-bottom:1px solid ##666;border-collapse:collapse;font-weight:400;padding:.4em .4em}
		table.Design2 th.Corner{text-align:left}
		table.Design2 thead th{background-color:##E5E5E5;color:##000;font-weight:bold;font-size:10px;text-align:left}
		div.confidentiality{margin-top:20px}
		thead {display: table-header-group;}
		</style>
	</head>
	<body>
		#variables.letterContentGenerated#
	</body>
	</html>
	</cfsavecontent>
  </cfsilent>

  <!--- write the html letter and save a pdf version of the letter --->
  <cfset vars.htmlfilePath = get_output_path( arguments.letterType ) & "\#vars.fileName#.htm" >

<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~ convert it into pdf format ~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
	<cfset pdf_footer = "#vars.qProgram.Contract_Number# #vars.qProgram.Revision_Version# - " />
	<cfdocument format="PDF" name="vars.pdf" pageType="letter" margintop="2">
		<cfdocumentitem type="header"><br><br><br>#variables.letterHeaderSection#</cfdocumentitem>
		<cfif len(trim(pdf_footer))>
			<!--- Use a footer with current page of totalpages format. --->
			<cfdocumentitem type="footer"><div style="text-align:center;font:arial;font-size:10px;">#pdf_footer# Page #cfdocument.currentPageNumber# of #cfdocument.TotalPageCount#</div></cfdocumentitem>
		</cfif>
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<title>#vars.fileName#</title>
			<style type="text/css">
				<cfinclude template="/common_files/main_style.css">
				<cfinclude template="/common_files/960_16_col.css">
			    .mb74 { margin-top:5px;margin-bottom:5px;font-size:12px; }
			    p{font-size:10px;line-height:120%}
			    hr{padding:3px 0;border:none;border-top:1px solid ##333}
			    .dollar{text-align:right!important}
			    .center{text-align:center!important}
			    .right{text-align:right!important}
			    .opa_group{color:##000;margin:35px 0 5px 0;font-weight:bold}
			    .small{font-size:10px;font-weight:normal;position:relative;top:-5px}
			    table.Design2{border-top:1px solid ##666;border-left:1px solid ##666;margin-bottom:10px;width:99%}
			    table.Design2 td{border-right:1px solid ##666;border-bottom:1px solid ##666;padding:.4em .4em;vertical-align:top}
			    table.Design2 th{border-right:1px solid ##666;border-bottom:1px solid ##666;border-collapse:collapse;font-weight:400;padding:.4em .4em}
			    table.Design2 th.Corner{text-align:left}
			    table.Design2 thead th{background-color:##E5E5E5;color:##000;font-weight:bold;font-size:10px;text-align:left}
			    div.confidentiality{margin-top:20px}
			    thead {display: table-header-group;}
			</style>
		</head>
		<body>
				#ReplaceNoCase(variables.letterMessageSection, 'Paye à', 'Payé à')#
				<cfif (Trim(FORM.txtNotes) NEQ "")>
		 		<table width="950"  style="font-family:Arial; font-size:12px;" align="center"><tr><td valign="bottom"><strong>Notes:</strong> #FORM.txtNotes#</td></tr></table>
				</cfif>
				<cfif isDefined("VARIABLES.letterDistributorsSection.firstPage")>
					#ReplaceNoCase(VARIABLES.letterDistributorsSection.firstPage, 'Paye à', 'Payé à')#
				</cfif>

				<cfif isDefined("VARIABLES.letterDistributorsSection.remainingPages") AND isArray(VARIABLES.letterDistributorsSection.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterDistributorsSection.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<cfdocumentitem type="pagebreak" />
						#ReplaceNoCase(VARIABLES.letterDistributorsSection.remainingPages[VARIABLES.theRemainingPageIndex], 'Paye à', 'Payé à')#
					</cfloop>
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.fixedPrice.firstPage")>
                    <!--- ngt --->
                    <cfif VARIABLES.letterProducts.fixedPrice.firstPage is PAGE_BREAK_GOES_HERE>
                        <cfdocumentitem type="pagebreak" />
                    <cfelse>
                        #ReplaceNoCase(VARIABLES.letterProducts.fixedPrice.firstPage, 'Paye à', 'Payé à')#
                    </cfif>
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.fixedPrice.remainingPages") AND isArray(VARIABLES.letterProducts.fixedPrice.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.fixedPrice.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<cfdocumentitem type="pagebreak" />
						#ReplaceNoCase(VARIABLES.letterProducts.fixedPrice.remainingPages[VARIABLES.theRemainingPageIndex], 'Paye à', 'Payé à')#
					</cfloop>
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.rebateProducts.firstPage")>
					#ReplaceNoCase(VARIABLES.letterProducts.rebateProducts.firstPage, 'Paye à', 'Payé à')#
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.rebateProducts.remainingPages") AND isArray(VARIABLES.letterProducts.rebateProducts.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.rebateProducts.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<!--- <cfdocumentitem type="pagebreak" /> --->
						#ReplaceNoCase(VARIABLES.letterProducts.rebateProducts.remainingPages[VARIABLES.theRemainingPageIndex], 'Paye à', 'Payé à')#
					</cfloop>
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.lumpSum.firstPage")>
					#ReplaceNoCase(VARIABLES.letterProducts.lumpSum.firstPage, 'Paye à', 'Payé à')#
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.lumpSum.remainingPages") AND isArray(VARIABLES.letterProducts.lumpSum.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.lumpSum.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<!--- <cfdocumentitem type="pagebreak" /> --->
						#ReplaceNoCase(VARIABLES.letterProducts.lumpSum.remainingPages[VARIABLES.theRemainingPageIndex], 'Paye à', 'Payé à')#
					</cfloop>
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.clauses")>
					#ReplaceNoCase(VARIABLES.letterProducts.clauses, 'Paye à', 'Payé à')#
				</cfif>

				<cfif arguments.letterType eq 1>
					<cfif isDefined("VARIABLES.letterOperatorSignatureSection")>
						#ReplaceNoCase(VARIABLES.letterOperatorSignatureSection, 'Paye à', 'Payé à')#
					</cfif>
				<cfelse>
					<cfif isDefined("VARIABLES.letterDistributorSignatureSection")>
						#ReplaceNoCase(VARIABLES.letterDistributorSignatureSection, 'Paye à', 'Payé à')#
					</cfif>
				</cfif>
		</body>
		</html>
	</cfdocument>





  <!--write pdf file-->
  <cfset vars.pdfFilePath = ReplaceNoCase(vars.htmlfilePath, '.htm', '.pdf')>
  <cfpdf action="write" destination="#vars.pdfFilePath#" source="vars.pdf" overwrite="yes">
  <!--------------------------------------------------------------------------------------------------------------------->


  <!------------------------------------ make entries in the db for the letter view page -------------------------------->
  <!--- check if there is a letter with the same name created by the same user on the same date. --->
	<cfquery name="vars.qCheckLetterExists"  datasource="#application.datasource#">
		SELECT Program_Letters_ID
		FROM Program_Letters
		WHERE Program_ID = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">
		AND Letter_Type = <cfqueryparam value="#arguments.letterType#" cfsqltype="cf_sql_numeric">
		<cfif arguments.letterType eq 1>
		AND Operator_Name = <cfqueryparam value="#arguments.customerName#" cfsqltype="cf_sql_varchar">
		<cfelse>
			<cfif arguments.customerName eq "All Distributors">
				AND Distributor_Name = 'All Distributors'
			<cfelse>
				AND Distributor_ID = <cfqueryparam value="#arguments.customerID#" cfsqltype="cf_sql_varchar">
			</cfif>
		</cfif>
		AND Deleted = 0
  </cfquery>

	<cfif vars.qCheckLetterExists.recordCount>
		<cfquery name="vars.qUpdateLetters" datasource="#application.datasource#">
			UPDATE Program_Letters
				SET Letter_Type = <cfqueryparam value="#arguments.letterType#" cfsqltype="cf_sql_numeric">,
					Letter_Name = <cfqueryparam value="#vars.fileName#" cfsqltype="cf_sql_varchar">,
					Letter_Path = <cfqueryparam value="#vars.pdfFilePath#" cfsqltype="cf_sql_varchar">,
					<cfif arguments.letterType eq 1>
					Operator_Name = <cfqueryparam value="#arguments.customerName#" cfsqltype="cf_sql_varchar">,
					<cfelse>
					Distributor_Name = <cfqueryparam value="#arguments.customerName#" cfsqltype="cf_sql_varchar">,
					<cfif arguments.customerName neq "All Distributors">Distributor_ID = <cfqueryparam value="#arguments.customerID#" cfsqltype="cf_sql_varchar">,</cfif>
					</cfif>
					Program_ID = <cfqueryparam value="#URL.Contract_Main_ID#" cfsqltype="cf_sql_integer">,
					Created_By = <cfqueryparam value="#request.accessstructure.user_ID#" cfsqltype="cf_sql_varchar">,
					Created_Date = getdate()
			WHERE Program_Letters_ID = <cfqueryparam value="#vars.qCheckLetterExists.Program_Letters_ID#" cfsqltype="cf_sql_integer">
			AND Deleted = 0
		</cfquery>
	<cfelse>
		<cfquery name="vars.qInsertLetters" datasource="#application.datasource#">
			INSERT INTO Program_Letters (Program_ID,Letter_Type,Letter_Name,Letter_Path,Operator_Name,Distributor_Name,<cfif arguments.customerName neq "All Distributors">Distributor_ID,</cfif>Created_By)
			VALUES ('#URL.Contract_Main_ID#',
					#arguments.letterType#,
					'#vars.fileName#',
					'#vars.pdfFilePath#',
					<cfif arguments.letterType eq 1>
					'#arguments.customerName#','',null,
					<cfelse>
					'','#arguments.customerName#',<cfif arguments.customerName neq "All Distributors">'#arguments.customerID#',</cfif>
					</cfif>
					'#request.accessstructure.user_ID#')
    </cfquery>
  </cfif>

</cffunction>

<!---------------------------------------------------------------------------------------------------------------------->
<!--------------------------------------------------- Letter Content --------------------------------------------------->
<!---------------------------------------------------------------------------------------------------------------------->

<!---------------------->
<!---     HEADER     --->
<!---------------------->
<cffunction name="fnLetterHeader" returntype="string" output="true">
  <cfargument name="letterType" type="numeric"> <!--- letterType 1=operator; 2=distributor --->
  <cfargument name="operatorNamesList" type="string" >
  <cfargument name="distributorStruct" type="struct" >

  	<cfset bDisplayBrokerNumber = 0>
	<cfif (arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Broker_Number eq 1)
			OR
			(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Broker_Number eq 1)>
			<cfset bDisplayBrokerNumber = 1>
	</cfif>

  	<cfset bDisplayApprovalDate = 0>
	<cfif (arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Approval_Date eq 1)
			OR
			(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Approval_Date eq 1)>
			<cfset bDisplayApprovalDate = 1>
	</cfif>

  <cfsavecontent variable="variables.sLetterHeader">
	 <div style="width:100%;height:60px;">
		<div style="width:40%;height:60px; float:left;padding-left:20px;">
			<img src="file:///#ExpandPath('/images/Huhtamaki_logo_02.png')#" title="Company Logo" alt="Company Logo" />		<!--- /images/huh_export.png 	/images/Logon_Blacksmith/index_huhtamaki_02.png     index_huhtamaki_02_small.png--->
		</div>
		<div style="width:40%; height:60px; float:left; vertical-align:middle; align-items: center;">
			<br>
			<font style="font-family:Arial;font-size:28px;"><strong>Price Quote</strong></font>
		</div>
		<div style="margin-left:80%; height:60px; padding-left:10px;">
			<font style="font-size:16px;font-family:Arial;">
			9201 Packaging Dr.<br>
			DeSoto, KS 66018<br>
			(800) 539-3726</font>
		</div>
      </div>
      <div class="container_16 mb74">
		<table width="960px"  style="font-family:Arial; font-size:12px;">
			<tr>
				<td rowspan="4" width="2%"></td>
				<td><strong>#application.returned_customer_setting.program_number_label#</strong></td>
				<td>#vars.qProgram.Contract_Number# #vars.qProgram.Revision_Version#</td>
				<td rowspan="4" width="20%"></td>
				<td><strong>Contact Name</strong></td>
				<td>#vars.qProgram.RSP_Name#</td>
			</tr>
			<tr>
				<td><strong>Operator</strong></td>
				<td>#arguments.operatorNamesList#</td>
				<td><strong>Contact Title</strong></td>
				<td>#vars.qProgram.RSP_Title#</td>
			</tr>
			<tr>
				<td><strong>Terms</strong></td>
				<td><cfif isDefined("FORM.Term")>#FORM.Term#<cfelse>1% 15 Net 30</cfif></td>
				<td><strong>Phone Number</strong></td>
				<cfset  newPhoneNumber = "(" &  vars.qProgram.Work_Phone_1 & ") " & vars.qProgram.Work_Phone_2 & "-" & vars.qProgram.Work_Phone_3 />
				<td>#newPhoneNumber#</td>
			</tr>
			<tr>
				<td><strong>Date</strong></td>
				<td>#Dateformat(now(),'mm/dd/yyyy')#</td>
				<td><strong></strong></td>
				<td></td>
			</tr>

		</table>
      </div>
		<!--- // NOTES // --->
		<cfif vars.qProgram.Notes neq "">
			<cfif (arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Notes EQ 1)
				OR
				(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Notes EQ 1)>
				<div class="container_16 mb74">
					<!--- There is no "french" translation, as the KraftHeinz Canadian users do not want to see "Notes" on the letter.
					In fact, regardless of language, none of the KraftHeinz Canadian users want to see "Notes" on the letter.
					--->
					<div class="grid_2 notranslate"><strong>Notes:</strong></div>
					<div class="grid_14">#vars.qProgram.Notes#</div>
				</div>
			</cfif>
		</cfif>
		<div class="container_16 mb74">
			<div class="grid_16"><hr style="height:2px;border-width:0;color:black;background-color:black"></div>
			<div class="grid_16 notranslate">
					<cfif (vars.qProgram.Effective_Start_Date NEQ "" AND vars.qProgram.Effective_End_Date NEQ "" )>
						<cfset startDate = LSDateFormat(vars.qProgram.Effective_Start_Date,'long') />
						<cfset endDate = LSDateFormat(vars.qProgram.Effective_End_Date,'long') />
					<cfelse>
						<cfset startDate = LSDateFormat(vars.qProgram.Contract_Start_Date,'long') />
						<cfset endDate = LSDateFormat(vars.qProgram.Contract_End_Date,'long') />
					</cfif>
				<table width="660px" border="0">
					<tr><td width="10">&nbsp;</td><td width="90"><font style="font-family:Arial;font-size:14px;"><strong>&nbsp;Effective Dates:</strong></font></td><td><font style="font-family:Arial;font-size:14px;"> #startDate# through #endDate#</font>
				</td></tr></table>
			</div>
			<div class="grid_16"><hr style="height:2px;border-width:0;color:black;background-color:black"></div>
		</div>
	</cfsavecontent> <!--- variables.sLetterHeader --->

	<!---
	<!--- Update the Page Length Counter with Header Content --->
	<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByString(theContent = VARIABLES.sLetterHeader) />
	--->

  <cfreturn variables.sLetterHeader />
</cffunction>


<!--------------------------->
<!---   MESSAGE SECTION   --->
<!--------------------------->
<cffunction name="fnLetterMessage" returntype="string" output="true">
	<cfargument name="letterType" type="numeric"> <!--- letterType 1=operator; 2=distributor --->
	<cfargument name="operatorName" type="string"  >
	<cfargument name="distributorName" type="string" >

	<!--- variable for message section  --->
	<cfsavecontent variable="variables.sLetterMessage">
	<cfoutput>
		<div class="container_16 notranslate">
		<div class="grid_16">
		<p><cfif arguments.letterType eq 2>#trim(arguments.distributorName)#,</cfif></p>
			<!--- english version of pleasantries --->

				<cfif arguments.letterType eq 1>
				<p>We are pleased to confirm pricing information for orders <cfif vars.qTemplateLetterSettings.Business_Unit_Desc EQ "Canada">requested for delivery<cfelse>placed</cfif> between #LSDateFormat(vars.qProgram.Effective_Start_Date,'long')# and #LSDateFormat(vars.qProgram.Effective_End_Date,'long')# for the below named recipients. During this time period, orders placed by recipients through your authorized party will be priced by #application.returned_customer_setting.company_name# to your authorized party at a maximum of the #lcase(vars.qDiscountTypes)# type for the product(s) found in the pricing table (showing prices, allowance and contract volume).</p>
				<cfelse>
				<p>We are pleased to confirm pricing information for orders <cfif vars.qTemplateLetterSettings.Business_Unit_Desc EQ "Canada">requested for delivery<cfelse>placed</cfif> between #LSDateFormat(vars.qProgram.Effective_Start_Date,'long')# and #LSDateFormat(vars.qProgram.Effective_End_Date,'long')#<cfif vars.qOperators.recordCount> for the below named recipients only</cfif>.   During this time period, product sold to #trim(arguments.distributorName)#<cfif vars.qOperators.recordCount> for delivery to recipients</cfif> will receive the #lcase(vars.qDiscountTypes)# type price to #trim(arguments.distributorName)# for the product(s) found in the pricing table (showing prices and rates).</p>
				</cfif>
				<p>The prices do not include any mark-up or surcharges.  Mark-ups and other charges are to be negotiated solely between the parties.</p>
				<p>This letter deals with pricing, compliance and confidentiality matters only and is not to be construed as a guarantee of product availability or supply.</p>
				<p>Sincerely,</p>
				<br /><br />
				<p>#vars.qProgram.RSP_Name#</p>
				<p>#application.returned_customer_setting.company_name# Representative</p>

		</div>
	</div>
	</cfoutput>
	</cfsavecontent>
	<!--- Update the Page Length Counter with Message Content --->
	<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByString(theContent = VARIABLES.sLetterMessage) />

<!--- 	<cfreturn variables.sLetterMessage /> --->
		<cfreturn "" />
</cffunction>
<!--------------------------------------------->
<!---  OPERATORS LIST IN OPERATOR LETTER --->
<!--------------------------------------------->
<cffunction name="fnLetterOperators" returntype="string" output="true">
    <cfset operators_printed = 0>
	<!--- variable for products section  --->
	<cfsavecontent variable="variables.sLetterOperators">
		<cfif vars.qOperators.recordCount>
			<div class="container_16">
				<div class="grid_16">
					<p class="opa_group">List of Authorized #application.returned_customer_setting.operator_label_plural#</p>
					<table id="opa_operators" class="Design2" cellspacing="0" cellpadding="0">
						<thead>
						<tr>
							<div class"notranslate">
							 <th>#application.returned_customer_setting.operator_label_singular# Number</th>
							</div>
									<th>#application.returned_customer_setting.operator_label_singular# Name</th>
									<th>Address</th>
						</tr>
						</thead>
						<tbody class="notranslate english">
                        <cfset operators_printed = 0>
						<cfoutput query="vars.qOperators">
						<tr>
                            <cfset operators_printed++>
							<td><cfif LegacyIdOn>#vars.qOperators.Legacy_ID#<cfelse>#vars.qOperators.Operator_ID#</cfif></td>
							<td>#vars.qOperators.Operator_Name#</td>
							<td>#trim(vars.qOperators.Operator_Address)# #trim(vars.qOperators.Operator_City)# #vars.qOperators.Operator_State# #vars.qOperators.Operator_Zip#</td>
						</tr>
						</cfoutput>
						</tbody>
					</table>
				</div>
			</div>
		</cfif>
	</cfsavecontent> <!--- variables.sLetterOperators --->
	<!--- Update the Page Length Counter with Operators Content --->
	<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByString(theContent = VARIABLES.sLetterOperators) />

  <cfreturn variables.sLetterOperators />
</cffunction>


<!--------------------------------------------->
<!---  DISTRIBUTORS LIST IN OPERATOR LETTER OR "ALL DISTRIBUTORS" LIST IN THE DISTRIBUTOR LETTER --->
<!--------------------------------------------->
<cffunction name="fnLetterDistributors" output="true">
	<cfargument name="letterType" type="numeric" required="true" />
	<cfargument name="DispDistributor_ID" type="any" required="false"  default="0" />


	<cfset VARIABLES.rowCounter 			= 0 />
	<cfset VARIABLES.sLetterDistributors 	= structNew() />
	<cfset VARIABLES.qName	= "" />

	<!--- Determine how many Fixed Price items we can display on the current Page --->
	<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />

	<cfset VARIABLES.theRecordsToDisplayOnExistingPage = ceiling(numberOfLinesOnPage - (VARIABLES.thePageLength / 2)) />

	<cfif VARIABLES.theRecordsToDisplayOnExistingPage LT 5>
		<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />
	</cfif>

	<cfif arguments.letterType eq 1>
		<!--- distributors selected on the "generate letters" page --->
		<cfset VARIABLES.qName	= "vars.qDistributors" />
	<cfelseif  arguments.letterType eq 2>
		<!--- All distributors --->
		<cfset VARIABLES.qName	= "vars.qPrgDistributors" />
	</cfif>

    <!--- keep track of number of distributors printed on current page --->
    <cfset distributors_printed = 0>

	<cfif VARIABLES.theRecordsToDisplayOnExistingPage NEQ 0>
		<!--- variable for Distributors section (first page) --->
		<cfsavecontent variable="VARIABLES.sLetterDistributors.firstPage">
		<div class="container_16">
			<div class="grid_16">
				<p class="opa_group">List of Authorized #application.returned_customer_setting.distributor_label_plural#</p>
				<table id="opa_distributors" class="Design2" cellspacing="0" cellpadding="0">
					<thead>
						<tr>
							<th>#application.returned_customer_setting.distributor_label_singular# Number</th>
							<th>#application.returned_customer_setting.distributor_label_singular# Name</th>
							<th>City</th>
							<th>State</th>
							<th>Shipping Facility</th>
							<!--- <cfif bDisplayBrokerNumber><th>#application.returned_customer_setting.broker_label_singular# ##</th></cfif> --->
						</tr>
					</thead>

					<tbody class="notranslate english">
						<cfoutput query="#VARIABLES.qName#" startRow="1" maxRows="#VARIABLES.theRecordsToDisplayOnExistingPage#">
						<cfif (arguments.letterType EQ  1 OR (arguments.letterType EQ 2 AND arguments.DispDistributor_ID NEQ 0 AND DispDistributor_ID EQ BSA_FOODSERVICE_CUSTOMERS_ID) OR (arguments.letterType EQ 2 AND arguments.DispDistributor_ID EQ 0))>
						<tr>
                            <cfset distributors_printed++>
							<cfif (appSettings.get_Setting('Display_Distributor_ID') EQ '1')>
								<td>#Shr_Ship_To#</td>
							<cfelse>
								<td>#Ship_To#</td>
							</cfif>
							<td>#Name#</td>
							<td>#trim(City)#</td>
							<td>#State#</td>
							<td>#Warehouse_Name#</td>
						</tr>
						</cfif>
						</cfoutput>
					</tbody>
				</table>
			</div>
		</div>
		</cfsavecontent> <!--- variables.sLetterDistributors.firstPage --->
		<!--- Update the Page Length Counter with Distributor Content --->

		<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByString(theContent = VARIABLES.sLetterDistributors.firstPage) />
	<cfelse>
		<cfset VARIABLES.sLetterDistributors.firstPage = "" />
	</cfif>

	<cfif arguments.letterType eq 1>
		<!--- distributors selected on the "generate letters" page --->
		<cfset VARIABLES.Distcount = vars.qDistributors.recordcount>
	<cfelseif  arguments.letterType eq 2>
        <!--- skip the remaining distributors when a specific distributor letter was chosen --->
        <cfset variables.DistCount = arguments.DispDistributor_ID neq 0
                                        ? 0
                                        : vars.qPrgDistributors.recordcount>
	</cfif>

	<!--- Determine if there are more records to display for Distributors (AKA: remaining pages) --->
	<cfif VARIABLES.Distcount GT VARIABLES.theRecordsToDisplayOnExistingPage>
		<!--- Determine the number of remaining pages --->
		<cfset VARIABLES.theNumberOfRemainingPages = ceiling(evaluate((VARIABLES.Distcount - VARIABLES.theRecordsToDisplayOnExistingPage) / MAX_ROWS_PER_PAGE)) />

		<!--- Create the Array for the remaining pages --->
		<cfset VARIABLES.sLetterDistributors.remainingPages = arrayNew(1) />

		<!--- Create the empty Array Element(s) for the remaining pages --->
		<cfset arraySet(VARIABLES.sLetterDistributors.remainingPages, 1, VARIABLES.theNumberOfRemainingPages, "") />

		<!--- Calculate the "startRow" and "endRow" for the query records to display on the current remaining page --->
		<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theRecordsToDisplayOnExistingPage + 1 />
		<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + MAX_ROWS_PER_PAGE - 1 />

		<!--- Loop through the remaining pages, and populate the content for them --->
		<cfloop from="1" to="#VARIABLES.theNumberOfRemainingPages#" index="VARIABLES.thePageIndex">
			<!--- Reset the Page Length Counter and Row Counter, since we'll be forcing a new page in the <cfcontent /> tag --->
			<cfset VARIABLES.thePageLength 	= 0 />
			<cfset VARIABLES.rowCounter 	= 0 />

			<cfsavecontent variable="VARIABLES.thePageContents">
			<div class="container_16">
				<div class="grid_16">
					<cfif VARIABLES.theCurrentPageStartRow EQ 1>
						<p class="opa_group">List of Authorized #application.returned_customer_setting.distributor_label_plural#</p>
					</cfif>
                    <!--- keep track of number of distributors printed on current page --->
                    <cfset distributors_printed = 0>
					<table id="opa_distributors" class="Design2" cellspacing="0" cellpadding="0">
						<thead>
							<tr>
								<th>#application.returned_customer_setting.distributor_label_singular# Number</th>
								<th>#application.returned_customer_setting.distributor_label_singular# Name</th>
								<th>City</th>
								<th>State</th>
								<th>Shipping Facility</th>
								<!--- <cfif bDisplayBrokerNumber><th>#application.returned_customer_setting.broker_label_singular# ##</th></cfif> --->
							</tr>
						</thead>
						<tbody class="notranslate english">
							<cfloop query="#VARIABLES.qName#" startRow="#VARIABLES.theCurrentPageStartRow#" endRow="#VARIABLES.theCurrentPageEndRow#">
							<cfset VARIABLES.rowCounter ++ />
							<tr>
                                <cfset distributors_printed++>
								<cfif (appSettings.get_Setting('Display_Distributor_ID') EQ '1')>
									<td>#Shr_Ship_To#</td>
								<cfelse>
									<td>#Ship_To#</td>
								</cfif>
								<td>#Name#</td>
								<td>#trim(City)#</td>
								<td>#State#</td>
								<td>#Warehouse_Name#</td>
								<!--- <cfif bDisplayBrokerNumber><td>#Broker_ID#</td></cfif> --->
							</tr>
							</cfloop>
						</tbody>
					</table>
				</div>
			</div>
			</cfsavecontent> <!--- VARIABLES.sLetterDistributors.remainingPages --->

			<!--- Insert the page contents into the remaining pages Array --->
			<cfset VARIABLES.sLetterDistributors.remainingPages[#VARIABLES.thePageIndex#] = VARIABLES.thePageContents />

			<!--- Update the "startRow" and "endRow" for the query records to display --->
			<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theCurrentPageStartRow + VARIABLES.rowCounter />
			<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + MAX_ROWS_PER_PAGE - 1 />

			<!--- Update the Page Length Counter using the approximate size of the last Page's Content  --->
			<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByNumber(evaluate((VARIABLES.rowCounter + 1) * 100)) />
		</cfloop>
	</cfif>
<!--- <cfdump var="#variables.sLetterDistributors#" />
<cfabort> --->
  <cfreturn variables.sLetterDistributors />
</cffunction>



<!--------------------------------->
<!---  PRODUCTS & RATE PRODUCTS --->
<!--------------------------------->
<cffunction name="fnletterProducts" output="true">

	<cfargument name="letterType" type="numeric">   <!--- letterType 1=operator; 2=distributor --->
	<cfargument name="discountTypeDisplay" type="numeric">
	<cfargument name="componentNameDisplay" type="numeric">
	<cfargument name="operPaysToDisplay" type="numeric">
	<cfargument name="distPaysToDisplay" type="numeric">
	<cfargument name="payableToDisplay" type="numeric">

	<cfset vars.customerProduct = false>

	<cfset VARIABLES.letterProducts = structNew() />

	<!--- Logic to show/hide "Rate change" based on template setting --->
	<cfset bDisplayRateChange = 0>
	<cfif (arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Rate_Change eq 1)
			OR
			(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Rate_Change eq 1)>
			<cfset bDisplayRateChange = 1>
	</cfif>

	<!--- Logic to show/hide "GTIN" based on template setting --->
	<cfset bDisplayGTIN = 0>
	<cfif (arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_GTIN eq 1)
			OR
			(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_GTIN eq 1)>
			<cfset bDisplayGTIN = 1>
	</cfif>

	<cfset bDisplayUPC = 0>
	<cfif (arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_UPC eq 1)
			OR
			(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_UPC eq 1)>
			<cfset bDisplayUPC = 1>
	</cfif>

	<!---------------------------->
	<!---  FIXED RATE PRODUCTS --->
	<!---------------------------->

	<cfif vars.qFixedPricedItems.recordCount gt 0>

		<cfset VARIABLES.rowCounter = 0 />
		<cfif (form.fixed_price EQ 1)>
			<!--- gather unique items --->
			<cfquery name="qFilteredFPRows" dbtype="query">
				SELECT
					*
				FROM
					vars.qFixedPricedItems
				WHERE Fixed_price_value > 0.00
				ORDER BY Item
			</cfquery>
			<!--- <cfset vars.qFixedPricedItems = qFilteredFPRows /> --->
			<cfset VARIABLES.letterProducts.fixedPrice = structNew() />

			<!--- Determine how many Fixed Price items we can display on the current Page.
                    Note - The above distributors section could span over multiple pages --->
			<cfset VARIABLES.theCurrentPageEndRow = max(0, numberOfLinesOnPage - (distributors_printed mod numberOfLinesOnPage))>

			<!--- no space on current page to show fixed price items --->
            <cfif VARIABLES.theCurrentPageEndRow lte 0>
                <!--- flag to insert page break here --->
				<cfset VARIABLES.letterProducts.fixedPrice.firstPage = PAGE_BREAK_GOES_HERE>
            <cfelse>
                <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- ~~~~~~~~~~~~~~~~~ Fixed Price items (FIRST Page) ~~~~~~~~~~~~~~~~~ --->
                <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->

				<cfsavecontent variable="VARIABLES.letterProducts.fixedPrice.firstPage">
				<div class="container_16">
					<div class="grid_16">
						<table class="Design2" cellspacing="0" cellpadding="0">
							<thead>
								<tr>
									<th>#productLabel# Number</th>
									<th>#productLabel# Description</th>
									<th>Component Name</th>
									<th>Annual Cases</th>
									<th>Case Pack</th>
									<th>Minimum Run (Cases)</th>
									<th>Price / Case</th>
									<th>Price / M</th>
									<th>Shipping Terms</th>
								</tr>
							</thead>

							<tbody class="notranslate english">
								<cfloop query="vars.qFixedPricedItems" startRow="1" endRow="#VARIABLES.theCurrentPageEndRow#">
                                    <tr>
                                        <cfset fixed_price_row()>
                                        </td>
                                    </tr>
								</cfloop>
							</tbody>
						</table>
					</div>  <!--- grid_16 --->
				</div>  <!--- container_16 --->
				</cfsavecontent> <!--- VARIABLES.letterProducts.fixedPrice.firstPage --->
			</cfif>


			<!--- Determine if there are more records to display for Fixed Price items (AKA: remaining pages) --->
			<cfif vars.qFixedPricedItems.recordCount GT VARIABLES.theCurrentPageEndRow>
				<!--- Determine the number of remaining pages --->
				<cfset VARIABLES.theNumberOfRemainingPages = ceiling(((vars.qFixedPricedItems.recordCount - VARIABLES.theCurrentPageEndRow) / MAX_ROWS_PER_PAGE)) />

				<!--- Create the Array for the remaining pages --->
				<cfset VARIABLES.letterProducts.fixedPrice.remainingPages = arrayNew(1) />

				<!--- Create the empty Array Element(s) for the remaining pages --->
				<cfset arraySet(VARIABLES.letterProducts.fixedPrice.remainingPages, 1, VARIABLES.theNumberOfRemainingPages, "") />

                <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
                <!--- ~~~~~~~~~~~~~~~~~ Fixed Price items (2ND+ Page) ~~~~~~~~~~~~~~~~~ --->
                <!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
				<!--- Loop through the remaining pages, and populate the content for them --->
				<cfloop from="1" to="#VARIABLES.theNumberOfRemainingPages#" index="VARIABLES.thePageIndex">

                    <!--- Calculate the "startRow" and "endRow" for the query records to display on the current remaining page --->
                    <cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theCurrentPageEndRow + 1>
                    <cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + MAX_ROWS_PER_PAGE - 1>

					<cfsavecontent variable="VARIABLES.thePageContents">
                        <div class="container_16">
                            <div class="grid_16">
                                <table class="Design2" cellspacing="0" cellpadding="0">
                                    <thead>
                                        <tr><cfoutput>
                                            <th>#productLabel# Number</th>
                                            <th>#application.returned_customer_setting.Item_Label# Description</th>
                                            <th>Component Name</th>
                                            <th>Annual Cases</th>
                                            <th>Case Pack</th>
                                            <th>Minimum Run (Cases)</th>
                                            <th>Price / Case</th>
                                            <th>Price / M</th>
                                            <th>Shipping Terms</th>
                                        </cfoutput>
                                        </tr>
                                    </thead>
                                    <tbody class="notranslate english">
                                        <!--- loop thru all unique items --->
                                        <cfloop query="vars.qFixedPricedItems" startRow="#VARIABLES.theCurrentPageStartRow#" endRow="#VARIABLES.theCurrentPageEndRow#">
                                            <cfset VARIABLES.rowCounter ++ />
                                            <tr>
                                                <cfset fixed_price_row()>
                                            </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>  <!--- grid_16 --->
                        </div>  <!--- container_16 --->
					</cfsavecontent>

					<!--- Insert the page contents into the remaining pages Array --->
					<cfset VARIABLES.letterProducts.fixedPrice.remainingPages[#VARIABLES.thePageIndex#] = VARIABLES.thePageContents />
				</cfloop>

			</cfif>
		</cfif> <!--- vars.qFixedPricedItems.recordCount  --->
	</cfif> <!--- form.fixed_price EQ 1--->


	<!------------------------>
	<!---  REBATE PRODUCTS --->
	<!------------------------>
	<!--- Note: Below code may actually not be called, because clients will either set "Display product groups" on the letters tab of the template to be either "yes",
	or "no" for both OPERATOR and DISTRIBUTOR. Below code will be called only if the setting is "yes" for one and "no" for the other.
	--->
<cfif (form.rebate EQ 1)>
<!--- <cfset vars.qTemplateLetterSettings.Distributor_Display_Product_Groups 	 = 0 />
<cfset vars.qTemplateLetterSettings.Operator_Display_Product_Groups = 0 /> --->
<cfset componentNameDisplay = 1 />
<cfset operPaysToDisplay = 1 />
<cfset distPaysToDisplay = 1 />
<cfset payableToDisplay = 1 />
<cfset discountTypeDisplay  = 2 />


	<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '0'>
		<!--- If an operator letter AND the template configuration "Display product groups" (operator) on the letters tab of the template does not match  "bDisplayProductGroups".--->


		<cfif arguments.letterType eq 1 AND (NOT IsDefined("vars.qRebateItems"))> <!--- 	<cfif arguments.letterType eq 1 AND ((vars.qTemplateLetterSettings.Operator_Display_Product_Groups neq bDisplayProductGroups) OR (NOT IsDefined("vars.qRebateItems")))>
 --->
			<cfif vars.qTemplateLetterSettings.Operator_Display_Product_Groups>
			<!--- If product groups exist, get product groups. else just get the products --->
					<cfset vars.qRebateItems = vars.programCFC.getRebateOnEmail(Contract_Main_ID=URL.Contract_Main_ID, getItemLevel=0)>
			<cfelse>
			<!--- If product groups exist, get product group members, else just get the products --->
					<cfset vars.qRebateItems = vars.programCFC.getRebateOnEmail(Contract_Main_ID=URL.Contract_Main_ID, getItemLevel=1)>
			</cfif>
		<!--- If a distributor letter AND the template configuration "Display product groups" (distributor) on the letters tab of the template does not match  "bDisplayProductGroups".--->
		<cfelseif arguments.letterType eq 2 AND ((vars.qTemplateLetterSettings.Distributor_Display_Product_Groups neq bDisplayProductGroups) OR (NOT IsDefined("vars.qRebateItems")))>
			<cfif vars.qTemplateLetterSettings.Distributor_Display_Product_Groups>
			<!--- If product groups exist, get product groups. else just get the products --->
					<cfset vars.qRebateItems = vars.programCFC.getRebateOnEmail(Contract_Main_ID=URL.Contract_Main_ID, getItemLevel=0)>
			<cfelse>
			<!--- If product groups exist, get product group members, else just get the products --->
					<cfset vars.qRebateItems = vars.programCFC.getRebateOnEmail(Contract_Main_ID=URL.Contract_Main_ID, getItemLevel=1)>
			</cfif>
		 </cfif>
	</cfif>
	<cfif vars.qRebateItems.recordCount gt 0>

		<cfset VARIABLES.rowCounter = 0 />
		<!--- Dev Note (83568) - Check whether product groups exist for Rebate --->
		<cfset VARIBLES.productGroupsExist = vars.GenProgramManager.programHasGroups(URL.Contract_Main_ID,2)>
		<!--- <cfif (distPaysToDisplay AND findNoCase('1', "#valuelist(vars.qRebateItems.Component_Paid_to)#")) OR (operPaysToDisplay AND findNoCase('2', "#valuelist(vars.qRebateItems.Component_Paid_to)#"))> --->

			<!--- gather unique items --->
			<cfquery name="vars.qRebateUniqueItems" dbtype="query">
				SELECT
					DISTINCT (bsa_FoodService_Items_Master_Id),
					Item,
					Description,
					Alt_Description,
					volume_cs,
					volume_lb,
					Rate,
					GTIN,
					UPC,
					Pricing_Level_ID,
					Group_Level_Desc
				FROM
					vars.qRebateItems

				<!--- distributor letter --->
				<cfif arguments.letterType eq 2>
				<!--- Paid to distributor only --->
					WHERE component_paid_to = 1
					<cfif vars.appSettings.getdisplayzerosviewprogram() eq 0>
					AND Rate > 0.0000
					</cfif>
				<!--- operator letter --->
				<cfelseif arguments.letterType eq 1>
				<!--- Paid to operator only --->
					WHERE component_paid_to = 2
					<cfif vars.appSettings.getdisplayzerosviewprogram() eq 0>
					AND Rate > 0.0000
					</cfif>
				</cfif>
				ORDER BY
					Pricing_Level_ID,Component_name_paid_to, Item
			</cfquery>

			<cfset oprRecCount = 0 />
			<cfset distRecCount = 0 />
			<cfif (arguments.letterType eq 1)>
				<cfset oprRecCount = vars.qRebateUniqueItems.RecordCount />
			<cfelseif (arguments.letterType eq 2)>
				<cfset distRecCount = vars.qRebateUniqueItems.RecordCount />
			</cfif>
			<cfset VARIABLES.letterProducts.rebateProducts = structNew() />

			<!--- Determine how many Rebate Product items we can display on the current Page --->
			<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />

			<cfset VARIABLES.theRecordsToDisplayOnExistingPage = ceiling(numberOfLinesOnPage - (VARIABLES.thePageLength / 2)) />
<!--- <cfdump var="#vars.qRebateItems#" />
<cfdump var="#arguments.letterType#" />
<Cfif arguments.letterType EQ 2>
<cfabort>
</CFIF> --->
			<cfif VARIABLES.theRecordsToDisplayOnExistingPage LT 5>
				<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />
			</cfif>
			<cfset VARIABLES.letterProducts.rebateProducts.firstPage = ""/>
			<cfset List_Item = "">
			<cfset VARIABLES.ExistingPricingLevelList = "">
			<cfset VARIABLES.NumberOfColumns = 0>
			<cfif (VARIABLES.theRecordsToDisplayOnExistingPage NEQ 0 AND ((arguments.letterType EQ 1 AND oprRecCount NEQ 0) OR (arguments.letterType EQ 2 AND distRecCount NEQ 0)))>
				<!--- variable for Rebate Product items (first page) --->
				<cfsavecontent variable="VARIABLES.letterProducts.rebateProducts.firstPage">
					<div class="container_16">
						<div class="grid_16">
							<!--- <p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - Rebate</cfif></p> --->
							<table class="Design2" cellspacing="0" cellpadding="0">
								<thead>
									<tr><cfoutput>
										<th>#productLabel# Number</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif bDisplayGTIN><th>GTIN</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<cfif bDisplayUPC><th>UPC</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<th>#application.returned_customer_setting.Item_Label# Description</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif vars.customerProduct>
										<th>Customer #application.returned_customer_setting.Item_Label# Number</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										</cfif>
									</cfoutput>
										<!--- NEW COLS FOR HUHTAMAKI --->
										<th>Component Name1</th>
										<th>Pays To</th>
										<th>Rate</th>
									</tr>
								</thead>
								<tbody class="notranslate english">
								<!--- loop thru all unique items --->
									<cfloop query="vars.qRebateUniqueItems" startRow="1" endRow="#VARIABLES.theRecordsToDisplayOnExistingPage#">
									<!--- If the "item" already does not exist. This is to make sure that "item" does not repeat.--->
									<cfif NOT ListFind(List_Item,item)>
									<cfset List_Item = ListAppend(List_Item,item)>
										<!--- Dev Note (78291 and 77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to
										"ExistingPricingLevelList".This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
										Note: "group_level_desc" is shown on a single row for every pricing level.
										--->
										<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1' AND ListFind(VARIABLES.ExistingPricingLevelList,vars.qRebateUniqueItems.Pricing_Level_ID) eq 0>
										<cfset VARIABLES.Group_Level_Desc = vars.qRebateUniqueItems.Group_Level_Desc>
										<cfif VARIBLES.productGroupsExist eq 1>
										<tr>
											<td colspan="#VARIABLES.NumberOfColumns#"><strong>#VARIABLES.Group_Level_Desc#</strong></td>
										</tr>
											<cfset VARIABLES.ExistingPricingLevelList = ListAppend(VARIABLES.ExistingPricingLevelList,vars.qRebateUniqueItems.Pricing_Level_ID)>
										</cfif>
										</cfif>
										<tr>
											<td>#(vars.qRebateUniqueItems.item eq '' ? 'Group' : vars.qRebateUniqueItems.item)#
											</td>
											<cfif bDisplayGTIN><td>#vars.qRebateUniqueItems.GTIN#</td></cfif>
											<cfif bDisplayUPC><td>#vars.qRebateUniqueItems.UPC#</td></cfif>
											<td>#vars.qRebateUniqueItems.Description#</td>

											<!--- loop over matching items and display the rates --->
											<cfoutput query="vars.qRebateItems" group="BSA_Foodservice_Items_Master_ID">
											<cfif vars.qRebateUniqueItems.BSA_Foodservice_Items_Master_ID eq vars.qRebateItems.BSA_Foodservice_Items_Master_ID>
											<cfoutput> <!--- this ouput loops the query group - dont remove this output --->
											<cfif (distPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '2')>
											<td>#vars.qRebateItems.Program_Rebates_Component_Name#</td>
											<td>#(vars.qRebateItems.Component_Paid_To eq '1' ? 'Distributor' : 'Operator')#</td>
											<cfset decimalprecision = vars.GenProgramManager.decimalPrecisionByUOM(vars.qRebateItems.Unit_Of_Measure_ID,1)>
												<cfif trim(vars.qRebateItems.Abbreviation) eq '%'>
													<td class="dollar">#numberformat(vars.qRebateItems.Rate, "#decimalprecision#")#%</td>
												<cfelse>
													<td class="dollar">#numberformat(vars.qRebateItems.Rate, "$#decimalprecision#")# / #vars.qRebateItems.Abbreviation#</td>
												</cfif>
												<cfif bDisplayRateChange AND IsDefined("vars.qRebateItems.Rate_Change")>
													<td class="dollar">
														<cfif vars.qRebateItems.Rate_Change neq 0>
															<cfif vars.qRebateItems.Rate_Change eq "999999"><!--- When UOM is neither CS nor LB --->
															<cfelse>
															#numberformat(vars.qRebateItems.Rate_Change, "$#decimalprecision#")#
															</cfif>
														<cfelse>
														N/C
														</cfif>
													</td>
												</cfif>
											</cfif>
											</cfoutput>
											</cfif>
											</cfoutput>
											<!--- loop over matching items and display the rates --->
										</tr>
									</cfif>
									</cfloop>  <!--- vars.qRebateUniqueItems --->
								</tbody>
							</table>
						</div>  <!--- grid_16 --->
					</div>  <!--- container_16 --->
				</cfsavecontent> <!--- VARIABLES.letterProducts.rebateProducts.firstPage --->
				<!--- Update the Page Length Counter with Rebate Product Content --->
				<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByString(theContent = VARIABLES.letterProducts.rebateProducts.firstPage) />
			<cfelse>
				<cfset VARIABLES.letterProducts.rebateProducts.firstPage = "" />
			</cfif>

			<!--- Get the count of unique records.
			If there is more than one component, then the query will have that many records for each product, but the product and all the component rates
			will only be displayed on one line and so we need to find the unique product count, so that we can figure out the logic for how many records to
			display on one page.
			--->
			<cfquery name="vars.qRebateUniqueItemsCount" dbtype="query">
				SELECT COUNT(DISTINCT bsa_FoodService_Items_Master_Id) As ItemCount
				FROM vars.qRebateUniqueItems
			</cfquery>

			<!--- Determine if there are more records to display for Rebate Product items (AKA: remaining pages) --->
			<cfif vars.qRebateUniqueItemsCount.ItemCount GT VARIABLES.theRecordsToDisplayOnExistingPage>
				<cfset VARIABLES.NumberOfColumns = 0>
				<!--- Determine the number of remaining pages --->
				<cfset VARIABLES.theNumberOfRemainingPages = ceiling(evaluate((vars.qRebateUniqueItemsCount.ItemCount - VARIABLES.theRecordsToDisplayOnExistingPage) / MAX_ROWS_PER_PAGE)) />

				<!--- Create the Array for the remaining pages --->
				<cfset VARIABLES.letterProducts.rebateProducts.remainingPages = arrayNew(1) />

				<!--- Create the empty Array Element(s) for the remaining pages --->
				<cfset arraySet(VARIABLES.letterProducts.rebateProducts.remainingPages, 1, VARIABLES.theNumberOfRemainingPages, "") />

				<!--- Calculate the "startRow" and "endRow" for the query records to display on the current remaining page --->
				<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theRecordsToDisplayOnExistingPage + 1 />
				<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + MAX_ROWS_PER_PAGE - 1 />

				<!--- Loop through the remaining pages, and populate the content for them --->
				<cfloop from="1" to="#VARIABLES.theNumberOfRemainingPages#" index="VARIABLES.thePageIndex">
					<!--- Reset the Page Length Counter and Row Counter, since we'll be forcing a new page in the <cfcontent /> tag --->
					<cfset VARIABLES.thePageLength 	= 0 />
					<cfset VARIABLES.rowCounter 	= 0 />

					<cfsavecontent variable="VARIABLES.thePageContents">
					<div class="container_16">
						<div class="grid_16">
							<cfif VARIABLES.theCurrentPageStartRow EQ 1>
							<!--- <p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - Rebate</cfif></p> --->
							</cfif>
							<table class="Design2" cellspacing="0" cellpadding="0">
								<thead>
									<tr> <cfoutput>
										<th>#productLabel# Number</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif bDisplayGTIN><th>GTIN</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<cfif bDisplayUPC><th>UPC</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<th>#application.returned_customer_setting.Item_Label# Description</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>

										<cfif vars.customerProduct>
										<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<th>Customer #application.returned_customer_setting.Item_Label# Number</th>
										</cfif>
										</cfoutput>
										<!--- NEW COLS FOR HUHTAMAKI --->
										<th>Component Name</th>
										<th>Pays To</th>
										<th>Rate</th>
									</tr>
								</thead>
								<tbody class="notranslate english">
									<!--- loop thru all unique items --->
									<cfloop query="vars.qRebateUniqueItems" startRow="#VARIABLES.theCurrentPageStartRow#" endRow="#VARIABLES.theCurrentPageEndRow#">
									<!--- If the "item" already does not exist. This is to make sure that "item" does not repeat.--->
									<cfif NOT ListFind(List_Item,item)>
									<cfset List_Item = ListAppend(List_Item,item)>
										<cfset VARIABLES.rowCounter ++ />
										<!--- Dev Note (78291 and 77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to
										"ExistingPricingLevelList".This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
										Note: "group_level_desc" is shown on a single row for every pricing level.
										--->
										<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1' AND ListFind(VARIABLES.ExistingPricingLevelList,vars.qRebateUniqueItems.Pricing_Level_ID) eq 0>
										<cfset VARIABLES.Group_Level_Desc = vars.qRebateUniqueItems.Group_Level_Desc>
										<cfif VARIBLES.productGroupsExist eq 1>
										<tr>
											<td colspan="#VARIABLES.NumberOfColumns#"><strong>#VARIABLES.Group_Level_Desc#</strong></td>
										</tr>
											<cfset VARIABLES.ExistingPricingLevelList = ListAppend(VARIABLES.ExistingPricingLevelList,vars.qRebateUniqueItems.Pricing_Level_ID)>
										</cfif>
										</cfif>
										<tr>
											<td>#(vars.qRebateUniqueItems.item eq '' ? 'Group' : vars.qRebateUniqueItems.item)#</td>
											<cfif bDisplayGTIN><td>#vars.qRebateUniqueItems.GTIN#</td></cfif>
											<cfif bDisplayUPC><td>#vars.qRebateUniqueItems.UPC#</td></cfif>
											<td>#vars.qRebateUniqueItems.Description#</td>
											<!--- loop over matching items and display the rates --->
											<cfoutput query="vars.qRebateItems" group="BSA_Foodservice_Items_Master_ID">
												<cfif vars.qRebateUniqueItems.BSA_Foodservice_Items_Master_ID eq vars.qRebateItems.BSA_Foodservice_Items_Master_ID>
												<cfoutput> <!--- this ouput loops the query group - dont remove this output --->
												<cfif (distPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '2')>
												<td>#vars.qRebateItems.Program_Rebates_Component_Name#</td>
												<td>#(vars.qRebateItems.Component_Paid_To eq '1' ? 'Distributor' : 'Operator')#</td>
												<cfset decimalprecision = vars.GenProgramManager.decimalPrecisionByUOM(vars.qRebateItems.Unit_Of_Measure_ID,1)>
													<cfif trim(vars.qRebateItems.Abbreviation) eq '%'>
														<td class="dollar">#numberformat(vars.qRebateItems.Rate, "#decimalprecision#")#%</td>
													<cfelse>
														<td class="dollar">#numberformat(vars.qRebateItems.Rate, "$#decimalprecision#")# / #vars.qRebateItems.Abbreviation#</td>
													</cfif>
													<cfif bDisplayRateChange AND IsDefined("vars.qRebateItems.Rate_Change")>
														<td class="dollar">
															<cfif vars.qRebateItems.Rate_Change neq 0>
																<cfif vars.qRebateItems.Rate_Change eq "999999"><!--- When UOM is neither CS nor LB --->
																<cfelse>
																#numberformat(vars.qRebateItems.Rate_Change, "$#decimalprecision#")#
																</cfif>
															<cfelse>
															N/C
															</cfif>
														</td>
													</cfif>
												</cfif>
												</cfoutput>
												</cfif>
											</cfoutput>
											<!--- loop over matching items and display the rates --->
										</tr>
									</cfif>
									</cfloop>  <!--- vars.qRebateUniqueItems --->
								</tbody>
							</table>
						</div>  <!--- grid_16 --->
					</div>  <!--- container_16 --->
					</cfsavecontent>  <!--- VARIABLES.letterProducts.rebateProducts.remainingPages --->

					<!--- Insert the page contents into the remaining pages Array --->
					<cfset VARIABLES.letterProducts.rebateProducts.remainingPages[#VARIABLES.thePageIndex#] = VARIABLES.thePageContents />

					<!--- Update the "startRow" and "endRow" for the query records to display --->
					<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theCurrentPageStartRow + VARIABLES.rowCounter />
					<!--- <cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + MAX_ROWS_PER_PAGE - 1 /> --->

					<!--- Update the Page Length Counter using the approximate size of the last Page's Content  --->
					<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByNumber(evaluate((VARIABLES.rowCounter + 1) * 100)) />
				</cfloop>
			</cfif>

		<!--- </cfif>  ---><!--- display based on template letters paysTo setting --->

	</cfif> <!--- vars.qRebateItems.recordCount  --->
</cfif>		<!--- form.rebate EQ 1 --->

	<!------------------>
	<!---  LUMP SUM  --->
	<!------------------>
	<cfscript>
	LSDataManager       = createObject("component", "components.programs.lump_sum_components.DataManager").init() ;
	templateManager     = CreateObject("component", "components.programs.template.TemplateManager").init() ;
	vars.qLumpSums      = vars.programCFC.getLumpSums( URL.Contract_Main_ID );
	</cfscript>

	<!--- letterType: 1=operator; 2=distributor --->
	<!--- Component_Paid_To: 1=distributor; 2=operator --->
	<cfif vars.qLumpSums.recordCount gt 0>

		<cfset VARIABLES.rowCounter = 0 />
		<cfset VARIABLES.ExistingPricingLevelList = "">
		<cfset VARIABLES.NumberOfColumns = 0>
		<!--- Dev Note (83568) - Check whether product groups exist for Lumpsum --->
		<cfset VARIBLES.productGroupsExist = vars.GenProgramManager.programHasGroups(URL.Contract_Main_ID,3)>

		<!--- display only if the display option is checked on template--->
		<!--- <cfif (distPaysToDisplay AND findNoCase('1', "#valuelist(vars.qLumpSums.Component_Paid_To)#")) OR (operPaysToDisplay AND findNoCase('2', "#valuelist(vars.qLumpSums.Component_Paid_To)#"))> --->
		<cfif (form.lump_sum EQ 1)>

			<cfset VARIABLES.letterProducts.lumpSum = structNew() />

			<!--- Determine how many Rebate Product items we can display on the current Page --->
			<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />

			<cfset VARIABLES.theRecordsToDisplayOnExistingPage = ceiling(numberOfLinesOnPage - (VARIABLES.thePageLength / 2)) />

			<cfif VARIABLES.theRecordsToDisplayOnExistingPage LT 5>
				<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />
			</cfif>

			<cfif VARIABLES.theRecordsToDisplayOnExistingPage NEQ 0>
				<!--- variable for Lump Sum items (first page) --->
				<cfsavecontent variable="VARIABLES.letterProducts.lumpSum.firstPage">
					<div class="container_16">
						<!--- <div class="grid_16">
							<p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - #Application.LumpsumLabel#</cfif></p>
						</div> ---> <!--- class="grid_16"> --->

						<cfloop query="vars.qLumpSums">
						<cfif NOT (arguments.letterType eq 2 AND vars.qLumpSums.Component_Paid_To eq 2)>
						<cfset vars.qLumpSumProducts = LSDataManager.getProgramLumpSumProducts(vars.qLumpSums.Program_Lump_Sum_ID, URL.Contract_Main_ID) />
						<cfif vars.qLumpSumProducts.recordCount>
						<div class="grid_16">
							<table class="Design2" cellspacing="0" cellpadding="0">
								<thead>
									<tr>
										<th>#productLabel# Number</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif bDisplayGTIN><th>GTIN</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<cfif bDisplayUPC><th>UPC</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<th>#application.returned_customer_setting.Item_Label# Description<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></th>
									</tr>
								</thead>
								<tbody>
									<cfloop query="vars.qLumpSumProducts" startRow="1" endRow="#VARIABLES.theRecordsToDisplayOnExistingPage#">
									<!--- Dev Note (78291 and 77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to
									"ExistingPricingLevelList".This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
									Note: "group_level_desc" is shown on a single row for every pricing level.
									--->
									<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1' and ListFind(VARIABLES.ExistingPricingLevelList,vars.qLumpSumProducts.Pricing_Level_ID) eq 0>
									<cfset VARIABLES.Group_Level_Desc = vars.qLumpSumProducts.Group_Level_Desc>
									<cfif VARIBLES.productGroupsExist eq 1>
									<tr>
										<td colspan="#VARIABLES.NumberOfColumns#"><strong>#VARIABLES.Group_Level_Desc#</strong></td>
									</tr>
										<cfset VARIABLES.ExistingPricingLevelList = ListAppend(VARIABLES.ExistingPricingLevelList,vars.qLumpSumProducts.Pricing_Level_ID)>
									</cfif>
									</cfif>
									<tr>
										<td>#(vars.qLumpSumProducts.item eq '' ? 'Group' : vars.qLumpSumProducts.item)#
										</td>
										<cfif bDisplayGTIN><td>#vars.qLumpSumProducts.GTIN#</td></cfif>
										<cfif bDisplayUPC><td>#vars.qLumpSumProducts.UPC#</td></cfif>
										<td>#vars.qLumpSumProducts.Description#</td>
									</tr>
									</cfloop> <!--- query="vars.qLumpSumProducts.recordCount"> --->
								</tbody>
							</table>
						</div> <!--- class="grid_16"> --->
						</cfif> <!--- vars.qLumpSumProducts.recordCount> --->

						<cfif vars.qLumpSumProducts.recordCount LTE VARIABLES.theRecordsToDisplayOnExistingPage>
						<div class="grid_8"><br>
							<strong>Component</strong>: #vars.qLumpSums.Program_lump_sum_name#
							<br />
							<strong>Payable To</strong>: #templateManager.getPaymentPaidToTypeDesc(paidToID = vars.qLumpSums.Component_Paid_To, paidToDesc="")#
							<br />
							<strong>Description: <!--- #vars.qLumpSums.Program_Lump_Sum_Name# ---></strong>: <i>(#vars.qLumpSums.Lump_Sum_Description#)</i>
						</div>

						<div class="grid_8"><br>
							<strong>Claim Mechanism:</strong> #vars.qLumpSums.Payment_Type_Name#
							<br />
							<strong>Payment Cycle</strong>: #vars.PaymentCycleManager.getPaymentCycleDescription(vars.PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 3, vars.qLumpSums.Program_Lumps_Sum_Ext_Id))#
							<br />
							<strong>Amount</strong>: #dollarFormat(vars.qLumpSums.Lump_Sum_Amount)#
						</div>
						</cfif>
						</cfif>
						</cfloop>  <!--- query="vars.qLumpSums"> --->
					</div>  <!--- class="container_16"> --->
				</cfsavecontent>
				<!--- Update the Page Length Counter with Lump Sum Content --->
				<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByString(theContent = VARIABLES.letterProducts.lumpSum.firstPage) />
			<cfelse>
				<cfset VARIABLES.letterProducts.lumpSum.firstPage = "" />
			</cfif>

			<!--- Determine if there are more records to display for Lump Sum items (AKA: remaining pages) --->
			<cfif vars.qLumpSums.recordCount GT VARIABLES.theRecordsToDisplayOnExistingPage>
				<cfset VARIABLES.NumberOfColumns = 0>

				<!--- Determine the number of remaining pages --->
				<cfset VARIABLES.theNumberOfRemainingPages = ceiling(evaluate((vars.qLumpSums.recordCount - VARIABLES.theRecordsToDisplayOnExistingPage) / MAX_ROWS_PER_PAGE)) />

				<!--- Create the Array for the remaining pages --->
				<cfset VARIABLES.letterProducts.lumpSum.remainingPages = arrayNew(1) />

				<!--- Create the empty Array Element(s) for the remaining pages --->
				<cfset arraySet(VARIABLES.letterProducts.lumpSum.remainingPages, 1, VARIABLES.theNumberOfRemainingPages, "") />

				<!--- Calculate the "startRow" and "endRow" for the query records to display on the current remaining page --->
				<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theRecordsToDisplayOnExistingPage + 1 />
				<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + MAX_ROWS_PER_PAGE - 1 />

				<!--- Loop through the remaining pages, and populate the content for them --->
				<cfloop from="1" to="#VARIABLES.theNumberOfRemainingPages#" index="VARIABLES.thePageIndex">
					<!--- Reset the Page Length Counter and Row Counter, since we'll be forcing a new page in the <cfcontent /> tag --->
					<cfset VARIABLES.thePageLength 	= 0 />
					<cfset VARIABLES.rowCounter 	= 0 />

					<cfsavecontent variable="VARIABLES.thePageContents">
					<div class="container_16">
						<cfif VARIABLES.theCurrentPageStartRow EQ 1>
						<!--- <div class="grid_16">
							<p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - #Application.LumpsumLabel#</cfif></p>
						</div> ---> <!--- class="grid_16"> --->
						</cfif>
						<cfloop query="vars.qLumpSums">
						<cfif NOT (arguments.letterType eq 2 AND vars.qLumpSums.Component_Paid_To eq 2)>
						<cfset vars.qLumpSumProducts = LSDataManager.getProgramLumpSumProducts(vars.qLumpSums.Program_Lump_Sum_ID, URL.Contract_Main_ID) />
						<cfif vars.qLumpSumProducts.recordCount>
						<div class="grid_16">
							<table class="Design2" cellspacing="0" cellpadding="0">
								<thead>
									<tr>
										<th>#productLabel# Number</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif bDisplayGTIN><th>GTIN</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<cfif bDisplayUPC><th>UPC</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<th>#application.returned_customer_setting.Item_Label# Description<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></th>
									</tr>
								</thead>
								<tbody>
									<cfloop query="vars.qLumpSumProducts" startRow="#VARIABLES.theCurrentPageStartRow#" endRow="#VARIABLES.theCurrentPageEndRow#">
									<cfset VARIABLES.rowCounter ++ />
									<!--- Dev Note (78291 and 77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to
									"ExistingPricingLevelList".This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
									Note: "group_level_desc" is shown on a single row for every pricing level.
									--->
									<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1' and ListFind(VARIABLES.ExistingPricingLevelList,vars.qLumpSumProducts.Pricing_Level_ID) eq 0>
									<cfset VARIABLES.Group_Level_Desc = vars.qLumpSumProducts.Group_Level_Desc>
									<cfif VARIBLES.productGroupsExist eq 1>
									<tr>
										<td colspan="#VARIABLES.NumberOfColumns#"><strong>#VARIABLES.Group_Level_Desc#</strong></td>
									</tr>
										<cfset VARIABLES.ExistingPricingLevelList = ListAppend(VARIABLES.ExistingPricingLevelList,vars.qLumpSumProducts.Pricing_Level_ID)>
									</cfif>
									</cfif>
									<tr>
										<td>#(vars.qLumpSumProducts.item eq '' ? 'Group' : vars.qLumpSumProducts.item)#
										</td>
										<cfif bDisplayGTIN><td>#vars.qLumpSumProducts.GTIN#</td></cfif>
										<cfif bDisplayUPC><td>#vars.qLumpSumProducts.UPC#</td></cfif>
										<td>#vars.qLumpSumProducts.Description#</td>
									</tr>
									</cfloop> <!--- query="vars.qLumpSumProducts.recordCount"> --->
								</tbody>
							</table>
						</div> <!--- class="grid_16"> --->
						</cfif> <!--- vars.qLumpSumProducts.recordCount> --->

						<div class="grid_8">
							<strong>Component</strong>: #vars.qLumpSums.Program_lump_sum_name#
							<br />
							<strong>Payable To</strong>: #templateManager.getPaymentPaidToTypeDesc(paidToID = vars.qLumpSums.Component_Paid_To, paidToDesc="")#
							<br />
							<strong>#vars.qLumpSums.Program_Lump_Sum_Name#</strong>
						</div>

						<div class="grid_8">
							<strong>Claim Mechanism:</strong> #vars.qLumpSums.Payment_Type_Name#
							<br />
							<strong>Payment Cycle</strong>: #vars.PaymentCycleManager.getPaymentCycleDescription(vars.PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 3, vars.qLumpSums.Program_Lumps_Sum_Ext_Id))#
							<br />
							<strong>Amount</strong>: #dollarFormat(vars.qLumpSums.Lump_Sum_Amount)#
						</div>
						<div class="grid_16">
							<i>(#vars.qLumpSums.Lump_Sum_Description#)</i>
						</div>
						</cfif>
						</cfloop>  <!--- query="vars.qLumpSums"> --->
					</div>  <!--- class="container_16"> --->
					</cfsavecontent>

					<!--- Insert the page contents into the remaining pages Array --->
					<cfset VARIABLES.letterProducts.lumpSum.remainingPages[#VARIABLES.thePageIndex#] = VARIABLES.thePageContents />

					<!--- Update the "startRow" and "endRow" for the query records to display --->
					<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theCurrentPageStartRow + VARIABLES.rowCounter />
					<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + MAX_ROWS_PER_PAGE - 1 />

					<!--- Update the Page Length Counter using the approximate size of the last Page's Content  --->
					<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByNumber(evaluate((VARIABLES.rowCounter + 1) * 100)) />
				</cfloop>
			</cfif>

		<!--- </cfif>  ---> <!--- display only if the display option is checked on template--->
		</cfif> <!--- <cfif (form.lump_sum EQ 1)> --->
	</cfif>  <!--- vars.qLumpSums.recordCount gt 0> --->


	<!----------------->
	<!---  CLAUSES  --->
	<!----------------->
	<cfsavecontent variable="VARIABLES.letterProducts.clauses">
		<cfloop query="vars.qClauses">
		<!--- Dev Note (71665) - "page-break-before:always;" puts every clause in it's own page --->
		<div class="container_16 notranslate english" style="page-break-before:always;">
			<div>
				#vars.qClauses.Clause_library_body#
			</div>
		</div>
		</cfloop>

		<!-- div class="container_16 confidentiality">
			<div class="grid_16">
				#application.returned_customer_setting.confidentiality_content#
			</div>
		</div --->
	</cfsavecontent>   <!--- variable="variables.letterProducts"> --->

	<cfreturn variables.letterProducts />

</cffunction>

<cffunction name="substringCount" output="false" hint="Returns number of substrings inside a given string">
    <cfargument name="string" required="true" type="string">
    <cfargument name="substring" required="true" type="string">

        <cfreturn ( len(arguments.string) - len(replace(arguments.string, arguments.substring, '', 'all')) ) / len(arguments.substring)>
</cffunction>

<cffunction name="fnCalculateContentSizeByString">
	<cfargument name="theContent" type="string" required="true">

	<cfreturn substringCount(arguments.theContent, "</tr>")>
</cffunction>

<cffunction name="fnCalculateContentSizeByNumber">
	<cfargument name="theContentLength" type="numeric" required="true" />

	<cfset VARIABLES.theContentSize = 0 />

<!---
	<!--- Update the Page Length Counter --->
	<cfif (ARGUMENTS.theContentLength GT 0) AND (ARGUMENTS.theContentLength LTE 2000)>
		<!--- The Content length is small --->
		<cfset VARIABLES.theContentSize = 30 />
	<cfelseif (ARGUMENTS.theContentLength GTE 2001) AND (ARGUMENTS.theContentLength LTE 4000)>
		<!--- The Content length is medium --->
		<cfset VARIABLES.theContentSize = 60 />
	<cfelseif ARGUMENTS.theContentLength GTE 4001>
		<!--- The Content length is large --->
		<cfset VARIABLES.theContentSize = 90 />
	</cfif>

	<cfreturn VARIABLES.theContentSize />
--->
	<cfreturn round(ARGUMENTS.theContentLength / 50) />
</cffunction>


<cffunction name="fnSetSignature" output="false">
	<cfoutput>
		<cfsavecontent variable="VARIABLES.signature">
			<div class="container_16">
				<br />
				<div class="grid_8">
					<strong>APPROVAL BY CUSTOMER</strong>
				</div>
				<div class="grid_8">
					<strong>APPROVAL BY #UCASE(request.AccessStructure.Company_Name)#</strong>
				</div>
				<p>&nbsp;</p>
				<div class="grid_8">
					<strong>NAME___________________________________________</strong>
				</div>
				<div class="grid_8">
					<strong>NAME___________________________________________</strong>
				</div>
				<br />&nbsp;
				<div class="grid_8">
					<strong>TITLE___________________________________________</strong>
				</div>
				<div class="grid_8">
					<strong>TITLE___________________________________________</strong>
				</div>
				<br />&nbsp;
				<div class="grid_8">
					<strong>SIGNATURE_____________________________________</strong>
				</div>
				<div class="grid_8">
					<strong>SIGNATURE_____________________________________</strong>
				</div>
				<br />&nbsp;
				<div class="grid_8">
					<strong>DATE___________________________________________</strong>
				</div>
				<div class="grid_8">
					<strong>DATE___________________________________________</strong>
				</div>
			</div>
		</cfsavecontent>
	</cfoutput>
		<cfreturn VARIABLES.signature />
</cffunction>


<cffunction name="get_output_path" output="false">
    <cfargument name="letter_type" required="false" default="0">

    <cfscript>
        local.temp_path = "";
        if ( IsDefined("request.ApplicationPath") )
            local.temp_path = request.ApplicationPath;
        else if ( IsDefined("ApplicationPath") )
            local.temp_path = ApplicationPath;

        if ( IsDefined("Application.Doc_Path") )
            local.temp_path = Application.Doc_Path;

        local.output_path = "#local.temp_path#\data_files\created\contracts\letters\output\";

        if ( arguments.letter_type eq 1 )
            local.output_path = local.output_path & "operators\";
        else if ( arguments.letter_type eq 2 )
            local.output_path = local.output_path & "distributors\";

        local.output_path =  local.output_path & URL.Contract_Main_ID;

        if ( !directoryExists(local.output_path) ) {
            cfdirectory(action="create", directory="#local.output_path#");
        }

        return replaceNoCase(local.output_path, '/', '\', 'all');
    </cfscript>
</cffunction>

<cffunction name="fixed_price_row" output="true">
    <td style="white-space:nowrap;">#vars.qFixedPricedItems.Item#</td>
    <td style="white-space:nowrap;">#application.util.string.wrapText( vars.qFixedPricedItems.Description, 40 )#</td>
    <td style="white-space:nowrap;">#vars.qFixedPricedItems.Program_Fixed_Component_Name#</td>
    <td style="white-space:nowrap;" align="right">#NumberFormat(vars.qFixedPricedItems.volume)#</td>
    <td style="white-space:nowrap;" align="right">#NumberFormat(vars.qFixedPricedItems.Case_Count)#</td>
    <cfif vars.qFixedPricedItems.Item_Bracket EQ 3>
        <td style="white-space:nowrap;" align="right">#NumberFormat(vars.qFixedPricedItems.Run_Vol_CS)#</td>
    <cfelse>
        <td style="white-space:nowrap;" align="right"></td>
    </cfif>

    <td style="white-space:nowrap;" align="right">#DollarFormat(vars.qFixedPricedItems.Fixed_Price_Value)#</td>
    <td style="white-space:nowrap;" align="right">#DollarFormat((vars.qFixedPricedItems.Fixed_Price_Value/Case_Count) * 1000)#</td>
    <td style="white-space:nowrap;"><cfswitch expression = "#vars.qFixedPricedItems.Item_Bracket#">
            <cfcase value="1">TL</cfcase>
            <cfcase value="2">LTL</cfcase>
            <cfcase value="3">Custom Items - Make & Ship</cfcase>
            <cfdefaultcase></cfdefaultcase>
        </cfswitch>
    </td>
</cffunction>
