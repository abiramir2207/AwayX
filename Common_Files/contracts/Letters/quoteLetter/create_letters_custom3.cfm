<!---------------------------------------------------------------------------------------------------------------------
	Template: C:\Forge\base\AwayX\Common_Files\contracts\Letters\quoteLetter\custom3.cfm
	Date:     2014 August
	Author:   Chris Nguyen
	Purpose:  Generate Quote Letter Custom Type 3 ( Kraft )

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
	vars = StructNew();
	vars.appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
	vars.programCFC = CreateObject('component', 'components.programs.display_program.viewProgramTemplateManager');
	vars.LetterManager = CreateObject("component", "mvc.Models.LetterManager");
	vars.BusinessSegmentManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
	vars.GenProgramManager = CreateObject("component", "components.programs.programManager");
	vars.PaymentCycleManager = CreateObject("component", "components.programs.PaymentCycleManager") ;

	vars.qOperators = vars.programCFC.getOperators( URL.Contract_Main_ID );
	vars.qFixedPricedItems = vars.programCFC.getFixedPriceOnEmail( URL.Contract_Main_ID );
	vars.qLabels = createObject("component", "components.settings.Labels.Labels").init();

	LegacyIdOn = vars.BusinessSegmentManager.getOperatorlegacyIDOn(URL.Contract_Main_ID);
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
			,Approved
			,CONVERT(VARCHAR(10), Approval_Date, 101) AS Approval_Date
			,DateDiff(d, Effective_Start_Date, Effective_End_Date)+1 as Effective_Span
			,RSP_Name = _Users.Name_First + ' ' + _Users.Name_Last
			,RSP_Phone = _Users.Work_Phone_1 + ' ' + _Users.Work_Phone_2 + ' ' + _Users.Work_Phone_3
			,RSP_Email = _Users.User_Email
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
	</cfquery>

</cfoutput>
<!--------------------------------------------------------------------------------------------------------------------->


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

	<cfif vars.qOperators.recordCount AND vars.qTemplateLetterSettings.Operator_Letters_Required>

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
	<cfset variables.letterContentGenerated = variables.letterHeaderSection & variables.letterMessageSection & variables.letterOperatorsSection />

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

	<cfif isDefined("VARIABLES.letterProducts.growth")>
		<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.growth />
	</cfif>

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
				<cfset variables.letterHeaderSection =  fnLetterHeader(letterType="2", operatorNamesList="", distributorStruct=structNew()) />

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
				<cfset variables.letterOperatorsSection = fnLetterOperators() />

				<!--- add distributor section --->
				<cfset variables.letterDistributorsSection = "" />
				<cfif vars.qLtrDistributors.name eq "All Distributors">
					<cfif vars.qPrgDistributors.RecordCount>
						<cfset variables.letterDistributorsSection =  fnLetterDistributors(2) />
					</cfif>
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
			<cfset variables.letterContentGenerated = variables.letterHeaderSection & variables.letterMessageSection & variables.letterOperatorsSection />

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

			<cfif isDefined("VARIABLES.letterProducts.growth")>
				<cfset variables.letterContentGenerated = variables.letterContentGenerated & VARIABLES.letterProducts.growth />
			</cfif>

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

<cfreturn />

<!--------------------------------------------------------------------------------------------------------------------->
<!--- Get the number of lines which can fit on a page based on Image size.
Note: below logic is not tested properly for image sizes greater than 40.
--->
<cffunction name="fnNumberOfLinesBasedonImageSize" returntype="numeric" output="false">

	<cfset var number_of_lines = 0>

	<cfset var variables.logo_path = 'file:///' & ExpandPath(vars.appsettings.getletterscompanylogopath())>

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
	<cfset vars.fileName = "#vars.qProgram.Contract_Number#-#vars.qProgram.Revision_Version#_#vars.qProgram.Contract_Title#_AllDistributors_#dateformat(now(), "mm_dd_yyyy")#">
  <cfelse>
	<cfset vars.fileName = "#vars.qProgram.Contract_Number#-#vars.qProgram.Revision_Version#_#vars.qProgram.Contract_Title#_#arguments.customerName#_#customerNumber#_#dateformat(now(), "mm_dd_yyyy")#">
  </cfif>
  <cfset vars.fileName = REReplace(vars.fileName,"[^0-9A-Za-z_-]","_","all") >

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
  <cfset vars.tempFilePath = "">
  <cfif IsDefined("request.ApplicationPath")>
    <cfset vars.tempFilePath = request.ApplicationPath>
  <cfelseif IsDefined("ApplicationPath")>
    <cfset vars.tempFilePath = ApplicationPath>
  </cfif>
  <cfif IsDefined("Application.Doc_Path")>
    <cfset vars.tempFilePath = Application.Doc_Path>
  </cfif>

  <!--- folder path --->
  <cfset vars.folderPath = "#vars.tempFilePath#\data_files\created\contracts\letters\output\" >
  <cfif arguments.letterType eq 1>
  <cfset vars.folderPath =  vars.folderPath & "operators" >
  <cfelse>
    <cfset vars.folderPath =  vars.folderPath & "distributors">
  </cfif>
  <cfset vars.folderPath =  vars.folderPath & "\#URL.Contract_Main_ID#" />
  <cfif NOT DirectoryExists(vars.folderPath) >
    <cfdirectory action = "create" directory="#vars.folderPath#" />
  </cfif>

<!--- Dev Note (68588) - When we make a GoogleTranslate call for the entire document at one time below, GoogleTranslate will not process data if
it exceeds a certain size. So, commented the below code. We already have code below in the file to call GoogleTranslate for each section at a time.
--->
<!---
  <cfif request.language eq "french">
    <!---<cfset variables.letterContentFinal =  application.util.string.GoogleTranslate( application.util.string.compress( variables.letterFileContent ), 'fr' ) />--->
    <cfset variables.letterContentFinal =  application.util.string.GoogleTranslate(variables.letterFileContent, 'fr') />
  <cfelse>
    <!---<cfset variables.letterContentFinal = application.util.string.compress( variables.letterFileContent ) />--->
    <cfset variables.letterContentFinal = variables.letterFileContent />
  </cfif>
--->

  <!--- html file path --->
  <cfset vars.htmlfilePath = "#vars.folderPath #\#vars.fileName#.htm" >
  <cfset vars.htmlfilePath  = ReplaceNoCase(vars.htmlfilePath, '/', '\', 'all')>
  <!---
  <cffile action="write" file="#vars.htmlfilePath#" output="#variables.letterContentFinal#">
  --->

  <!--- convert it into pdf format --->
	<cfset pdf_footer = "#vars.qProgram.Contract_Number# #vars.qProgram.Revision_Version# - " />
	<cfdocument format="PDF" name="vars.pdf" pageType="letter">
		<cfif len(trim(pdf_footer))>
			<!--- Use a footer with current page of totalpages format. --->
			<cfdocumentitem type="footer">
				<div style="text-align:center;font:arial;font-size:10px;">
					#pdf_footer# Page #cfdocument.currentPageNumber# of #cfdocument.TotalPageCount#
				</div>
			</cfdocumentitem>
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
            <cfparam name="variables.letterProducts.lumpSum.page_heading" default=''>
            <cfparam name="variables.letterProducts.lumpSum.page_body"    default=''>
            <cfparam name="variables.letterProducts.lumpSum.page_closing" default=''>

			<cfif request.language EQ "french">
				<!--- Translate everyting into French --->

				#translate_to_french(VARIABLES.letterHeaderSection)#
				#translate_to_french(VARIABLES.letterMessageSection)#
				#translate_to_french(VARIABLES.letterOperatorsSection)#

				<cfif isDefined("VARIABLES.letterDistributorsSection.firstPage")>
					#translate_to_french(VARIABLES.letterDistributorsSection.firstPage)#
				</cfif>
				<cfif isDefined("VARIABLES.letterDistributorsSection.remainingPages") AND isArray(VARIABLES.letterDistributorsSection.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterDistributorsSection.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<cfdocumentitem type="pagebreak" />
						#translate_to_french(VARIABLES.letterDistributorsSection.remainingPages[VARIABLES.theRemainingPageIndex])#
					</cfloop>
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.fixedPrice.firstPage")>
					#translate_to_french(VARIABLES.letterProducts.fixedPrice.firstPage)#
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.fixedPrice.remainingPages") AND isArray(VARIABLES.letterProducts.fixedPrice.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.fixedPrice.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<cfdocumentitem type="pagebreak" />
						#translate_to_french(VARIABLES.letterProducts.fixedPrice.remainingPages[VARIABLES.theRemainingPageIndex])#
					</cfloop>
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.rebateProducts.firstPage")>
					#translate_to_french(VARIABLES.letterProducts.rebateProducts.firstPage)#
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.rebateProducts.remainingPages") AND isArray(VARIABLES.letterProducts.rebateProducts.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.rebateProducts.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<cfdocumentitem type="pagebreak" />
						#translate_to_french(VARIABLES.letterProducts.rebateProducts.remainingPages[VARIABLES.theRemainingPageIndex])#
					</cfloop>
				</cfif>

                <cfif len(trim(variables.letterProducts.lumpSum.page_body))>
                    #translate_to_french( variables.letterProducts.lumpSum.page_heading)#
                    #translate_to_french( variables.letterProducts.lumpSum.page_body)#
                    #translate_to_french( variables.letterProducts.lumpSum.page_closing)#
                </cfif>

				<cfif isDefined("VARIABLES.letterProducts.growth")>
					#translate_to_french(VARIABLES.letterProducts.growth)#
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.clauses")>
					#translate_to_french(VARIABLES.letterProducts.clauses)#
				</cfif>

				<cfif arguments.letterType eq 1>
					<cfif isDefined("VARIABLES.letterOperatorSignatureSection")>
						#translate_to_french(VARIABLES.letterOperatorSignatureSection)#
					</cfif>
				<cfelse>
					<cfif isDefined("VARIABLES.letterDistributorSignatureSection")>
						#translate_to_french(VARIABLES.letterDistributorSignatureSection)#
					</cfif>
				</cfif>

			<cfelse>

				<!--- English Version --->
				#string_replace(variables.letterHeaderSection)#
				#string_replace(variables.letterMessageSection)#
				#string_replace(variables.letterOperatorsSection)#

				<cfif isDefined("VARIABLES.letterDistributorsSection.firstPage")>
					#string_replace(VARIABLES.letterDistributorsSection.firstPage)#
				</cfif>
				<cfif isDefined("VARIABLES.letterDistributorsSection.remainingPages") AND isArray(VARIABLES.letterDistributorsSection.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterDistributorsSection.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<cfdocumentitem type="pagebreak" />
						#string_replace(VARIABLES.letterDistributorsSection.remainingPages[VARIABLES.theRemainingPageIndex])#
					</cfloop>
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.fixedPrice.firstPage")>
					#string_replace(VARIABLES.letterProducts.fixedPrice.firstPage)#
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.fixedPrice.remainingPages") AND isArray(VARIABLES.letterProducts.fixedPrice.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.fixedPrice.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<cfdocumentitem type="pagebreak" />
						#string_replace(VARIABLES.letterProducts.fixedPrice.remainingPages[VARIABLES.theRemainingPageIndex])#
					</cfloop>
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.rebateProducts.firstPage")>
					#string_replace(VARIABLES.letterProducts.rebateProducts.firstPage)#
				</cfif>
				<cfif isDefined("VARIABLES.letterProducts.rebateProducts.remainingPages") AND isArray(VARIABLES.letterProducts.rebateProducts.remainingPages)>
					<cfloop from="1" to="#arrayLen(VARIABLES.letterProducts.rebateProducts.remainingPages)#" index="VARIABLES.theRemainingPageIndex">
						<cfdocumentitem type="pagebreak" />
						#string_replace(VARIABLES.letterProducts.rebateProducts.remainingPages[VARIABLES.theRemainingPageIndex])#
					</cfloop>
				</cfif>

                <cfif len(trim(variables.letterProducts.lumpSum.page_body))>
                    #string_replace(variables.letterProducts.lumpSum.page_heading)#
                    #string_replace(variables.letterProducts.lumpSum.page_body)#
                    #string_replace(variables.letterProducts.lumpSum.page_closing)#
                </cfif>


				<cfif isDefined("VARIABLES.letterProducts.growth")>
					#string_replace(VARIABLES.letterProducts.growth)#
				</cfif>

				<cfif isDefined("VARIABLES.letterProducts.clauses")>
					#string_replace(VARIABLES.letterProducts.clauses)#
				</cfif>

				<cfif arguments.letterType eq 1>
					<cfif isDefined("VARIABLES.letterOperatorSignatureSection")>
						#string_replace(VARIABLES.letterOperatorSignatureSection)#
					</cfif>
				<cfelse>
					<cfif isDefined("VARIABLES.letterDistributorSignatureSection")>
						#string_replace(VARIABLES.letterDistributorSignatureSection)#
					</cfif>
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
<!--------------------------------------------------------------------------------------------------------------------->


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
		<!---need to specify the full URL so image would be shown up on email--->
		<div class="container_16 mb74">
			<div class="grid_16 mb74" style="margin-bottom:10px;">
				<!---<img src="http://#cgi.server_name#/#vars.appsettings.getletterscompanylogopath()#" title="Company Logo" alt="Company Logo" />--->
				<!--- Dev Note: 63830 (Logo not loading)--->
				<img src="file:///#ExpandPath('#vars.appsettings.getletterscompanylogopath()#')#" title="Company Logo" alt="Company Logo" />
			</div>
      </div>
      <div class="container_16 mb74">
		<div class="grid_2"><strong>Program Name:</strong></div>
		<div class="grid_7 notranslate">#vars.qProgram.Contract_Title#</div>
		<div class="grid_7" id="pc13"><strong>#application.returned_customer_setting.program_number_label# :</strong> #vars.qProgram.Contract_Number#</div>
      </div>

		<cfif arguments.letterType eq 2>
			<div class="container_16 mb74">
				<div class="grid_2"><strong>Recipient:</strong></div>
				<!--- If it is an "All Distributor" letter --->
				<cfif StructCount(distributorStruct) eq 0>
					<div class="grid_7">See List Below</div>
				<cfelse>
					<!--- When we do not need to show broker ID, we need to add "suffix_7" to the class, so that the total adds to 16, i.e. 2 + 7 + 7. When we need to display
					broker ID, then we use the "grid_7"  and not "suffix_7". The total is still 16, i.e.  2 + 7 + 7.
					--->
					<div <cfif bDisplayBrokerNumber>class="grid_7 notranslate"<cfelse>class="grid_7 suffix_7 notranslate"</cfif>>
						#arguments.distributorStruct.Name#<br />
						#arguments.distributorStruct.Address#<br />
						#trim(arguments.distributorStruct.City)# #trim(arguments.distributorStruct.State)# #arguments.distributorStruct.Zip#
					</div>
					<cfif bDisplayBrokerNumber>
					<div class="grid_7 notranslate"><strong>#application.returned_customer_setting.broker_label_singular# :</strong> #arguments.distributorStruct.Broker_ID#</div>
					</cfif>
				</cfif>
			</div>
		<cfelseif arguments.letterType eq 1>
			<cfif request.language neq "french">
				<div class="container_16 mb74 notranslate">
					<div class="grid_2"><strong>Recipient:</strong></div>
					<div class="grid_14">#arguments.operatorNamesList#</div>
				</div>
			<cfelse>
				<div class="container_16 mb74 notranslate">
					<div class="grid_2"><strong>Exploitant:</strong></div>
					<div class="grid_14">#arguments.operatorNamesList#</div>
				</div>
			</cfif>
		</cfif>
		<cfif bDisplayApprovalDate and vars.qProgram.Approval_Date neq "" and vars.qProgram.Approved eq 1>
				<div class="container_16 mb74 notranslate">
					<div class="grid_2"><strong>Approval Date:</strong></div>
					<div class="grid_14">#vars.qProgram.Approval_Date#</div>
				</div>
		</cfif>
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
			<div class="grid_16"><hr /></div>
			<div class="grid_2 notranslate">
				<cfif request.language neq "french">
				<strong>Effective Dates:</strong>
				<cfelse>
				<strong>Dates d’entrée en vigueur:</strong>
				</cfif>
			</div>
			<div class="grid_7 notranslate">
				<cfif request.language neq "french">
				#LSDateFormat(vars.qProgram.Effective_Start_Date,'long')# through #LSDateFormat(vars.qProgram.Effective_End_Date,'long')#
				<cfelse>
				#LSDateFormat(vars.qProgram.Effective_Start_Date,'long')# au #LSDateFormat(vars.qProgram.Effective_End_Date,'long')#
				</cfif>
			</div>
			<cfif request.language neq "french">
				<div class="grid_7"><cfif vars.qDiscountTypes neq ""><strong>Price Type:</strong> #vars.qDiscountTypes#<cfelse>&nbsp;</cfif></div>
				<cfelse>
				<div class="grid_7 notranslate"><cfif vars.qDiscountTypes neq ""><strong>Type de contrat:</strong> #ReplaceList(vars.qDiscountTypes, "Rebate,Fixed Price", "Rabais,Taux Fixe")#<cfelse>&nbsp;</cfif></div>
			</cfif>
			<div class="grid_16"><hr /></div>
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
			<cfif request.language neq "french">
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
			<cfelse>  <!--- french version of pleasantries --->
				<cfif arguments.letterType eq 1>
				<p>Nous sommes ravis de confirmer les prix des produits devant être livrés entre les dates du #LSDateFormat(vars.qProgram.Effective_Start_Date,'long')# au #LSDateFormat(vars.qProgram.Effective_End_Date,'long')# à destinataires dont le nom est indiqué ci-dessus.<br/>Pendant cette période, les commandes passées par à destinataires auprès de parti autorisé seront facturées par #application.returned_customer_setting.company_name# au montant maximum correspondant au taux et au rabais indiqués dans la grille de prix.</p>
				<cfelse>
				<p>Nous sommes ravis de confirmer les prix des produits devant être livrés seulement à destinataires dont le nom est indiqué ci-dessus entre les dates du #LSDateFormat(vars.qProgram.Effective_Start_Date,'long')# au #LSDateFormat(vars.qProgram.Effective_End_Date,'long')#.<br/>Pendant cette période, les produits vendus à #trim(arguments.distributorName)# et devant être livrés à destinaraires bénéficieront du rabais accordé à #trim(arguments.distributorName)# conformément à la grille de prix.</p>
				</cfif>
				<p>Les prix ne comprennent pas les marges ou les autres majorations. Ces dernières doivent être négociées entre le parties.</p>
				<p>La présente traite uniquement des prix, de la conformité et de la confidentialité, et ne constitue pas une garantie de disponibilité ou d’approvisionnement des produits.</p>
				<p>Sincères salutations,</p>
				<br /><br />
				<p>#vars.qProgram.RSP_Name#</p>
				<p>Représentant #application.returned_customer_setting.company_name#</p>
			</cfif>
		</div>
	</div>
	</cfoutput>
	</cfsavecontent>
	<!--- Update the Page Length Counter with Message Content --->
	<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByString(theContent = VARIABLES.sLetterMessage) />

	<cfreturn variables.sLetterMessage />
</cffunction>
<!--------------------------------------------->
<!---  OPERATORS LIST IN OPERATOR LETTER --->
<!--------------------------------------------->
<cffunction name="fnLetterOperators" returntype="string" output="true">
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
							<cfif request.language neq "french"> <th>#application.returned_customer_setting.operator_label_singular# Number</th>
								<cfelse><th>Numéro de client</th>
							</cfif>
							</div>
									<th>#application.returned_customer_setting.operator_label_singular# Name</th>
									<th>Address</th>
						</tr>
						</thead>
						<tbody class="notranslate english">
						<cfoutput query="vars.qOperators">
						<tr>
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

	<cfif VARIABLES.theRecordsToDisplayOnExistingPage NEQ 0>
		<!--- variable for Distributors section (first page) --->
		<cfsavecontent variable="VARIABLES.sLetterDistributors.firstPage">
		<div class="container_16">
			<div class="grid_16">
				<p class="opa_group">List of Authorized #application.returned_customer_setting.distributor_label_plural#</p>
				<table id="opa_distributors" class="Design2" cellspacing="0" cellpadding="0">
					<thead>
						<tr>
							<th>Customer Number</th>
							<th>Company Name</th>
							<th>Address</th>
							<cfif bDisplayBrokerNumber><th>#application.returned_customer_setting.broker_label_singular# ##</th></cfif>
						</tr>
					</thead>

					<tbody class="notranslate english">
						<cfoutput query="#VARIABLES.qName#" startRow="1" maxRows="#VARIABLES.theRecordsToDisplayOnExistingPage#">
						<tr>
							<cfif (appSettings.get_Setting('Display_Distributor_ID') EQ '1')>
								<td>#Shr_Ship_To#</td>
							<cfelse>
								<td>#Ship_To#</td>
							</cfif>
							<td>#Name#</td>
							<td>#trim(Address_1)# #trim(City)# #State# #ZipCode#</td>
							<cfif bDisplayBrokerNumber><td>#Broker_ID#</td></cfif>
						</tr>
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
		<!--- All distributors --->
		<cfset VARIABLES.Distcount = vars.qPrgDistributors.recordcount>
	</cfif>

	<!--- Determine if there are more records to display for Distributors (AKA: remaining pages) --->
	<cfif VARIABLES.Distcount GT VARIABLES.theRecordsToDisplayOnExistingPage>
		<!--- Determine the number of remaining pages --->
		<cfset VARIABLES.theNumberOfRemainingPages = ceiling(evaluate((VARIABLES.Distcount - VARIABLES.theRecordsToDisplayOnExistingPage) / 45)) />

		<!--- Create the Array for the remaining pages --->
		<cfset VARIABLES.sLetterDistributors.remainingPages = arrayNew(1) />

		<!--- Create the empty Array Element(s) for the remaining pages --->
		<cfset arraySet(VARIABLES.sLetterDistributors.remainingPages, 1, VARIABLES.theNumberOfRemainingPages, "") />

		<!--- Calculate the "startRow" and "endRow" for the query records to display on the current remaining page --->
		<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theRecordsToDisplayOnExistingPage + 1 />
		<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + 44 />

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
					<table id="opa_distributors" class="Design2" cellspacing="0" cellpadding="0">
						<thead>
							<tr>
								<th>Customer Number</th>
								<th>Company Name</th>
								<th>Address</th>
								<cfif bDisplayBrokerNumber><th>#application.returned_customer_setting.broker_label_singular# ##</th></cfif>
							</tr>
						</thead>
						<tbody class="notranslate english">
							<cfloop query="#VARIABLES.qName#" startRow="#VARIABLES.theCurrentPageStartRow#" endRow="#VARIABLES.theCurrentPageEndRow#">
							<cfset VARIABLES.rowCounter ++ />
							<tr>
								<cfif (appSettings.get_Setting('Display_Distributor_ID') EQ '1')>
									<td>#Shr_Ship_To#</td>
								<cfelse>
									<td>#Ship_To#</td>
								</cfif>
								<td>#Name#</td>
								<td>#trim(Address_1)# #trim(City)# #State# #ZipCode#</td>
								<cfif bDisplayBrokerNumber><td>#Broker_ID#</td></cfif>
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
			<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + 44 />

			<!--- Update the Page Length Counter using the approximate size of the last Page's Content  --->
			<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByNumber(evaluate((VARIABLES.rowCounter + 1) * 100)) />
		</cfloop>
	</cfif>

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

		<!--- display the components only if the components paysto is set to display in template letter settings --->
		<cfif (distPaysToDisplay AND findNoCase('1', "#valuelist(vars.qFixedPricedItems.Fixed_Component_Paid_to)#")) OR (operPaysToDisplay AND findNoCase('2', "#valuelist(vars.qFixedPricedItems.Fixed_Component_Paid_to)#"))>

			<!--- gather unique items --->
			<cfquery name="vars.qFixedUniqueItems" dbtype="query">
			SELECT
				DISTINCT (bsa_FoodService_Items_Master_Id),
				Item,
				Description,
				Alt_Description,
				volume_cs,
				volume_lb,
				GTIN,
				UPC
			FROM
				vars.qFixedPricedItems
			ORDER BY
				Item
			</cfquery>

			<cfset VARIABLES.letterProducts.fixedPrice = structNew() />

			<!--- Determine how many Fixed Price items we can display on the current Page --->
			<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />

			<cfset VARIABLES.theRecordsToDisplayOnExistingPage = ceiling(numberOfLinesOnPage - (VARIABLES.thePageLength / 2)) />



			<cfif VARIABLES.theRecordsToDisplayOnExistingPage LT 5>
				<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />
			</cfif>

			<cfif VARIABLES.theRecordsToDisplayOnExistingPage NEQ 0>
				<!--- variable for Fixed Price items (first page) --->
				<cfsavecontent variable="VARIABLES.letterProducts.fixedPrice.firstPage">
				<div class="container_16">
					<div class="grid_16">
						<p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - <cfif request.language neq "french">Fixed Price<cfelse>Taux Fixe</cfif></cfif></p>
						<table class="Design2" cellspacing="0" cellpadding="0">
							<thead>
								<tr>
									<th>#productLabel###</th>
									<cfif bDisplayGTIN><th>GTIN</th></cfif>
									<cfif bDisplayUPC><th>UPC</th></cfif>
									<th>#application.returned_customer_setting.Item_Label# Description</th>
									<cfif vars.customerProduct>
									<th>Customer #application.returned_customer_setting.Item_Label# Number</th>
									</cfif>
									<!--- display each component in separate column only if paysto is set as display in template letter --->
									<cfset List_Component_name_paid_to = "">
									<cfoutput query="vars.qFixedPricedItems">
									<!--- If the "component name and paid to combination" already does not exist. --->
									<cfif NOT ListFind(List_Component_name_paid_to,Component_name_paid_to)>
										<cfset List_Component_name_paid_to = ListAppend(List_Component_name_paid_to,Component_name_paid_to)>
										<cfif (distPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '2')>
											<th class="center">
												<cfif arguments.componentNameDisplay>#vars.qFixedPricedItems.Program_Fixed_Component_Name#</cfif>
												<cfif arguments.payableToDisplay>
												<br />
												<div class"notranslate english">
													<cfif request.language neq "french">
													Pays To: #(vars.qFixedPricedItems.Fixed_Component_Paid_To eq '1' ? 'Distributor' : 'Operator')#
													<cfelse>
													Payé à: #(vars.qFixedPricedItems.Fixed_Component_Paid_To eq '1' ? 'Distributeur' : 'Opérateur')#
													</cfif>
												</div>
												</cfif>
												<cfif
												(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Claim_Mechanism eq 1)
												OR
												(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Claim_Mechanism eq 1)
												>
												<div>
													Claim Mechanism: #vars.qFixedPricedItems.Payment_Type_Name#
												</div>
												</cfif>
												<cfif
												(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Payment_Frequency eq 1)
												OR
												(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Payment_Frequency eq 1)
												>
												<div>
													Payment Cycle: #vars.PaymentCycleManager.getPaymentCycleDescription(vars.PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 1, vars.qFixedPricedItems.Program_Fixed_Component_ID))#
												</div>
												</cfif>
											</th>
											<cfif bDisplayRateChange AND IsDefined("vars.qFixedPricedItems.Rate_Change")>
											<th>
												<div class"notranslate english">
													Rate<br />Change
												</div>
											</th>
											</cfif>
										</cfif>
									</cfif>
									</cfoutput>
								</tr>
							</thead>
							<tbody class="notranslate english">
								<!--- loop thru all unique items --->
								<cfloop query="vars.qFixedUniqueItems" startRow="1" endRow="#VARIABLES.theRecordsToDisplayOnExistingPage#">
								<tr>
									<td>#vars.qFixedUniqueItems.Item#</td>
									<cfif bDisplayGTIN><td>#vars.qFixedUniqueItems.GTIN#</td></cfif>
									<cfif bDisplayUPC><td>#vars.qFixedUniqueItems.UPC#</td></cfif>
									<cfif request.language eq "french">
									<td>#vars.qFixedUniqueItems.ALt_Description#</td>
									<cfelse>
									<td>#vars.qFixedUniqueItems.Description#</td>
									</cfif>
									<!--- loop over matching items and display the rates --->
									<cfoutput query="vars.qFixedPricedItems" group="BSA_Foodservice_Items_Master_ID" >
									<cfif vars.qFixedUniqueItems.BSA_Foodservice_Items_Master_ID eq vars.qFixedPricedItems.BSA_Foodservice_Items_Master_ID>
									<cfoutput> <!--- this ouput loops the query group - dont remove this output --->
									<cfif (distPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '2')>
									<cfset decimalprecision = vars.GenProgramManager.decimalPrecisionByUOM(vars.qFixedPricedItems.Unit_Of_Measure_ID,1)>
									<td class="dollar">#numberformat(vars.qFixedPricedItems.Fixed_Price_Value,"$#decimalprecision#")# / #vars.qFixedPricedItems.Abbreviation# </td>
										<cfif bDisplayRateChange AND IsDefined("vars.qFixedPricedItems.Rate_Change")>
												<td class="dollar">
													<cfif vars.qFixedPricedItems.Rate_Change neq 0>
														<cfif vars.qFixedPricedItems.Rate_Change eq "999999"><!--- When UOM is neither CS nor LB --->
														<cfelse>
														#numberformat(vars.qFixedPricedItems.Rate_Change, "$#decimalprecision#")#
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
								</cfloop> <!--- query="vars.qFixedUniqueItems" --->
							</tbody>
						</table>
					</div>  <!--- grid_16 --->
				</div>  <!--- container_16 --->
				</cfsavecontent> <!--- VARIABLES.letterProducts.fixedPrice.firstPage --->
				<!--- Update the Page Length Counter with Fixed Price Content --->
				<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByString(theContent = VARIABLES.letterProducts.fixedPrice.firstPage) />
			<cfelse>
				<cfset VARIABLES.letterProducts.fixedPrice.firstPage = "" />
			</cfif>

			<!--- Determine if there are more records to display for Fixed Price items (AKA: remaining pages) --->
			<cfif vars.qFixedUniqueItems.recordCount GT VARIABLES.theRecordsToDisplayOnExistingPage>
				<!--- Determine the number of remaining pages --->
				<cfset VARIABLES.theNumberOfRemainingPages = ceiling(evaluate((vars.qFixedUniqueItems.recordCount - VARIABLES.theRecordsToDisplayOnExistingPage) / 45)) />

				<!--- Create the Array for the remaining pages --->
				<cfset VARIABLES.letterProducts.fixedPrice.remainingPages = arrayNew(1) />

				<!--- Create the empty Array Element(s) for the remaining pages --->
				<cfset arraySet(VARIABLES.letterProducts.fixedPrice.remainingPages, 1, VARIABLES.theNumberOfRemainingPages, "") />

				<!--- Calculate the "startRow" and "endRow" for the query records to display on the current remaining page --->
				<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theRecordsToDisplayOnExistingPage + 1 />
				<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + 44 />

				<!--- Loop through the remaining pages, and populate the content for them --->
				<cfloop from="1" to="#VARIABLES.theNumberOfRemainingPages#" index="VARIABLES.thePageIndex">
					<!--- Reset the Page Length Counter and Row Counter, since we'll be forcing a new page in the <cfcontent /> tag --->
					<cfset VARIABLES.thePageLength 	= 0 />
					<cfset VARIABLES.rowCounter 	= 0 />

					<cfsavecontent variable="VARIABLES.thePageContents">
					<div class="container_16">
						<div class="grid_16">
							<cfif VARIABLES.theCurrentPageStartRow EQ 1>
							<p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - <cfif request.language neq "french">Fixed Price<cfelse>Taux Fixe</cfif></cfif></p>
							</cfif>
							<table class="Design2" cellspacing="0" cellpadding="0">
								<thead>
									<tr>
										<th>#productLabel###</th>
										<cfif bDisplayGTIN><th>GTIN</th></cfif>
										<cfif bDisplayUPC><th>UPC</th></cfif>
										<th>#application.returned_customer_setting.Item_Label# Description</th>
										<cfif vars.customerProduct>
										<th>Customer #application.returned_customer_setting.Item_Label# Number</th>
										</cfif>
										<!--- display each component in separate column only if paysto is set as display in template letter --->
										<cfset List_Component_name_paid_to = "">
										<cfoutput query="vars.qFixedPricedItems">
										<!--- If the "component name and paid to combination" already does not exist. --->
										<cfif NOT ListFind(List_Component_name_paid_to,Component_name_paid_to)>
											<cfset List_Component_name_paid_to = ListAppend(List_Component_name_paid_to,Component_name_paid_to)>
											<cfif (distPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '2')>
												<th class="center">
													<cfif arguments.componentNameDisplay>#vars.qFixedPricedItems.Program_Fixed_Component_Name#</cfif>
													<cfif arguments.payableToDisplay>
													<br />
													<div class"notranslate english">
														<cfif request.language neq "french">
														Pays To: #(vars.qFixedPricedItems.Fixed_Component_Paid_To eq '1' ? 'Distributor' : 'Operator')#
														<cfelse>
														Payé à: #(vars.qFixedPricedItems.Fixed_Component_Paid_To eq '1' ? 'Distributeur' : 'Opérateur')#
														</cfif>
													</div>
													</cfif>
													<cfif
													(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Claim_Mechanism eq 1)
													OR
													(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Claim_Mechanism eq 1)
													>
													<div>
														Claim Mechanism: #vars.qFixedPricedItems.Payment_Type_Name#
													</div>
													</cfif>
													<cfif
													(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Payment_Frequency eq 1)
													OR
													(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Payment_Frequency eq 1)
													>
													<div>
														Payment Cycle: #vars.PaymentCycleManager.getPaymentCycleDescription(vars.PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 1, vars.qFixedPricedItems.Program_Fixed_Component_ID))#
													</div>
													</cfif>
													&nbsp;
												</th>
												<cfif bDisplayRateChange AND IsDefined("vars.qFixedPricedItems.Rate_Change")>
													<th>
														<div class"notranslate english">
															Rate<br />Change
														</div>
													</th>
												</cfif>
											</cfif>
										</cfif>
										</cfoutput>
									</tr>
								</thead>
								<tbody class="notranslate english">
									<!--- loop thru all unique items --->
									<cfloop query="vars.qFixedUniqueItems" startRow="#VARIABLES.theCurrentPageStartRow#" endRow="#VARIABLES.theCurrentPageEndRow#">
									<cfset VARIABLES.rowCounter ++ />
									<tr>
										<td>#vars.qFixedUniqueItems.Item#</td>
										<cfif bDisplayGTIN><td>#vars.qFixedUniqueItems.GTIN#</td></cfif>
										<cfif bDisplayUPC><td>#vars.qFixedUniqueItems.UPC#</td></cfif>
										<cfif request.language eq "french">
										<td>#vars.qFixedUniqueItems.ALt_Description#</td>
										<cfelse>
										<td>#vars.qFixedUniqueItems.Description#</td>
										</cfif>
										<!--- loop over matching items and display the rates --->
										<cfoutput query="vars.qFixedPricedItems" group="BSA_Foodservice_Items_Master_ID" >
										<cfif vars.qFixedUniqueItems.BSA_Foodservice_Items_Master_ID eq vars.qFixedPricedItems.BSA_Foodservice_Items_Master_ID>
										<cfoutput> <!--- this ouput loops the query group - dont remove this output --->
										<cfif (distPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qFixedPricedItems.Fixed_Component_Paid_to eq '2')>
										<cfset decimalprecision = vars.GenProgramManager.decimalPrecisionByUOM(vars.qFixedPricedItems.Unit_Of_Measure_ID,1)>
										<td class="dollar">#numberformat(vars.qFixedPricedItems.Fixed_Price_Value,"$#decimalprecision#")# / #vars.qFixedPricedItems.Abbreviation# </td>
											<cfif bDisplayRateChange AND IsDefined("vars.qFixedPricedItems.Rate_Change")>
													<td class="dollar">
														<cfif vars.qFixedPricedItems.Rate_Change neq 0>
															<cfif vars.qFixedPricedItems.Rate_Change eq "999999"><!--- When UOM is neither CS nor LB --->
															<cfelse>
															#numberformat(vars.qFixedPricedItems.Rate_Change, "$#decimalprecision#")#
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
									</cfloop> <!--- query="vars.qFixedUniqueItems" --->
								</tbody>
							</table>
						</div>  <!--- grid_16 --->
					</div>  <!--- container_16 --->
					</cfsavecontent>

					<!--- Insert the page contents into the remaining pages Array --->
					<cfset VARIABLES.letterProducts.fixedPrice.remainingPages[#VARIABLES.thePageIndex#] = VARIABLES.thePageContents />

					<!--- Update the "startRow" and "endRow" for the query records to display --->
					<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theCurrentPageStartRow + VARIABLES.rowCounter />
					<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + 44 />

					<!--- Update the Page Length Counter using the approximate size of the last Page's Content  --->
					<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByNumber(evaluate((VARIABLES.rowCounter + 1) * 100)) />
				</cfloop>

			</cfif>

		</cfif> <!--- display based on template letters paysTo setting --->

	</cfif> <!--- vars.qFixedPricedItems.recordCount  --->



	<!------------------------>
	<!---  REBATE PRODUCTS --->
	<!------------------------>
	<!--- Note: Below code may actually not be called, because clients will either set "Display product groups" on the letters tab of the template to be either "yes",
	or "no" for both OPERATOR and DISTRIBUTOR. Below code will be called only if the setting is "yes" for one and "no" for the other.
	--->
	<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '0'>
		<!--- If an operator letter AND the template configuration "Display product groups" (operator) on the letters tab of the template does not match  "bDisplayProductGroups".--->
		<cfif arguments.letterType eq 1 AND ((vars.qTemplateLetterSettings.Operator_Display_Product_Groups neq bDisplayProductGroups) OR (NOT IsDefined("vars.qRebateItems")))>
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

		<cfif (distPaysToDisplay AND findNoCase('1', "#valuelist(vars.qRebateItems.Component_Paid_to)#")) OR (operPaysToDisplay AND findNoCase('2', "#valuelist(vars.qRebateItems.Component_Paid_to)#"))>

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
			</cfif>
			<!--- Dev Note(61239): We need this ORDER BY in this order so that the product rate where distributor is the payee should
			correctly be under the distributor header and the same for operator. This is for the OPERATOR LETTER.
			Note: A similar change has been made on "viewprogramtemplatemanager.cfc" (getRebateOnEmail function).
			--->
			ORDER BY
				Pricing_Level_ID,Component_name_paid_to, Item
			</cfquery>

			<cfset VARIABLES.letterProducts.rebateProducts = structNew() />

			<!--- Determine how many Rebate Product items we can display on the current Page --->
			<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />

			<cfset VARIABLES.theRecordsToDisplayOnExistingPage = ceiling(numberOfLinesOnPage - (VARIABLES.thePageLength / 2)) />

			<cfif VARIABLES.theRecordsToDisplayOnExistingPage LT 5>
				<cfset VARIABLES.theRecordsToDisplayOnExistingPage = 0 />
			</cfif>

			<cfset List_Item = "">
			<cfset VARIABLES.ExistingPricingLevelList = "">
			<cfset VARIABLES.NumberOfColumns = 0>
			<cfif VARIABLES.theRecordsToDisplayOnExistingPage NEQ 0>
				<!--- variable for Rebate Product items (first page) --->
				<cfsavecontent variable="VARIABLES.letterProducts.rebateProducts.firstPage">
					<div class="container_16">
						<div class="grid_16">
							<p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - <cfif request.language neq "french">Rebate<cfelse>Rabais</cfif></cfif></p>
							<table class="Design2" cellspacing="0" cellpadding="0">
								<thead>
									<tr>
										<th>#productLabel###</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif bDisplayGTIN><th>GTIN</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<cfif bDisplayUPC><th>UPC</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<th>#application.returned_customer_setting.Item_Label# Description</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif vars.customerProduct>
										<th>Customer #application.returned_customer_setting.Item_Label# Number</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										</cfif>
										<!--- display each component in separate column only if paysto is set as display in template letter --->
										<cfset List_Component_name_paid_to = "">
										<cfoutput query="vars.qRebateItems">
										<!--- If the "component name and paid to combination" already does not exist. --->
										<cfif NOT ListFind(List_Component_name_paid_to,Component_name_paid_to)>
											<cfset List_Component_name_paid_to = ListAppend(List_Component_name_paid_to,Component_name_paid_to)>
											<cfif (distPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '2')>
												<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
												<th class="center">
													<cfif arguments.componentNameDisplay>
													#vars.qRebateItems.Program_Rebates_Component_Name#
													<!--- #ReplaceList(vars.qRebateItems.Program_Rebates_Component_Name, "Rebate,Fixed Price", "Rabais,Taux Fixe")# --->
													</cfif>
													<cfif arguments.payableToDisplay>
													<br />
													<div class"notranslate english">
														<cfif request.language neq "french">
														Pays To: #(vars.qRebateItems.Component_Paid_To eq '1' ? 'Distributor' : 'Operator')#
														<cfelse>
														Payé à: #(vars.qRebateItems.Component_Paid_To eq '1' ? 'Distributeur' : 'Opérateur')#
														</cfif>
													</div>
													</cfif>
													<cfif
													(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Claim_Mechanism eq 1)
													OR
													(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Claim_Mechanism eq 1)
													>
													<div>
														Claim Mechanism: #vars.qRebateItems.Payment_Type_Name#
													</div>
													</cfif>
													<cfif
													(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Payment_Frequency eq 1)
													OR
													(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Payment_Frequency eq 1)
													>
													<div>
														Payment Cycle: #vars.PaymentCycleManager.getPaymentCycleDescription(vars.PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 2, vars.qRebateItems.Program_Rebates_Component_ID))#
													</div>
													</cfif>
												</th>
												<cfif bDisplayRateChange AND IsDefined("vars.qRebateItems.Rate_Change")>
												<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
												<th>
													<div class"notranslate english">
														Rate<br />Change
													</div>
												</th>
												</cfif>
											</cfif>
										</cfif>
										</cfoutput>
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
											<td>#(vars.qRebateUniqueItems.item eq '' ? 'Group' : vars.qRebateUniqueItems.item)#</td>
											<cfif bDisplayGTIN><td>#vars.qRebateUniqueItems.GTIN#</td></cfif>
											<cfif bDisplayUPC><td>#vars.qRebateUniqueItems.UPC#</td></cfif>
											<cfif request.language eq "french">
											<td>#vars.qRebateUniqueItems.ALt_Description#</td>
											<cfelse>
											<td>#vars.qRebateUniqueItems.Description#</td>
											</cfif>
											<!--- loop over matching items and display the rates --->
											<cfoutput query="vars.qRebateItems" group="BSA_Foodservice_Items_Master_ID">
											<cfif vars.qRebateUniqueItems.BSA_Foodservice_Items_Master_ID eq vars.qRebateItems.BSA_Foodservice_Items_Master_ID>
											<cfoutput> <!--- this ouput loops the query group - dont remove this output --->
											<cfif (distPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '2')>
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
				<cfset VARIABLES.theNumberOfRemainingPages = ceiling(evaluate((vars.qRebateUniqueItemsCount.ItemCount - VARIABLES.theRecordsToDisplayOnExistingPage) / 45)) />

				<!--- Create the Array for the remaining pages --->
				<cfset VARIABLES.letterProducts.rebateProducts.remainingPages = arrayNew(1) />

				<!--- Create the empty Array Element(s) for the remaining pages --->
				<cfset arraySet(VARIABLES.letterProducts.rebateProducts.remainingPages, 1, VARIABLES.theNumberOfRemainingPages, "") />

				<!--- Calculate the "startRow" and "endRow" for the query records to display on the current remaining page --->
				<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theRecordsToDisplayOnExistingPage + 1 />
				<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + 44 />

				<!--- Loop through the remaining pages, and populate the content for them --->
				<cfloop from="1" to="#VARIABLES.theNumberOfRemainingPages#" index="VARIABLES.thePageIndex">
					<!--- Reset the Page Length Counter and Row Counter, since we'll be forcing a new page in the <cfcontent /> tag --->
					<cfset VARIABLES.thePageLength 	= 0 />
					<cfset VARIABLES.rowCounter 	= 0 />

					<cfsavecontent variable="VARIABLES.thePageContents">
					<div class="container_16">
						<div class="grid_16">
							<cfif VARIABLES.theCurrentPageStartRow EQ 1>
							<p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - <cfif request.language neq "french">Rebate<cfelse>Rabais</cfif></cfif></p>
							</cfif>
							<table class="Design2" cellspacing="0" cellpadding="0">
								<thead>
									<tr>
										<th>#productLabel###</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif bDisplayGTIN><th>GTIN</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<cfif bDisplayUPC><th>UPC</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
										<th>#application.returned_customer_setting.Item_Label# Description</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<cfif vars.customerProduct>
										<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
										<th>Customer #application.returned_customer_setting.Item_Label# Number</th>
										</cfif>
										<!--- display each component in separate column only if paysto is set as display in template letter --->
										<cfset List_Component_name_paid_to = "">
										<cfoutput query="vars.qRebateItems">
										<!--- If the "component name and paid to combination" already does not exist. --->
										<cfif NOT ListFind(List_Component_name_paid_to,Component_name_paid_to)>
											<cfset List_Component_name_paid_to = ListAppend(List_Component_name_paid_to,Component_name_paid_to)>
											<cfif (distPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '2')>
												<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
												<th class="center">
													<cfif arguments.componentNameDisplay>
													#vars.qRebateItems.Program_Rebates_Component_Name#
													<!--- #ReplaceList(vars.qRebateItems.Program_Rebates_Component_Name, "Rebate,Fixed Price", "Rabais,Taux Fixe")# --->
													</cfif>
													<cfif arguments.payableToDisplay>
													<br />
													<div class"notranslate english">
														<cfif request.language neq "french">
														Pays To: #(vars.qRebateItems.Component_Paid_To eq '1' ? 'Distributor' : 'Operator')#
														<cfelse>
														Payé à: #(vars.qRebateItems.Component_Paid_To eq '1' ? 'Distributeur' : 'Opérateur')#
														</cfif>
													</div>
													</cfif>
													<cfif
													(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Claim_Mechanism eq 1)
													OR
													(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Claim_Mechanism eq 1)
													>
													<div>
														Claim Mechanism: #vars.qRebateItems.Payment_Type_Name#
													</div>
													</cfif>
													<cfif
													(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Payment_Frequency eq 1)
													OR
													(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Payment_Frequency eq 1)
													>
													<div>
														Payment Cycle: #vars.PaymentCycleManager.getPaymentCycleDescription(vars.PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 2, vars.qRebateItems.Program_Rebates_Component_ID))#
													</div>
													</cfif>
												</th>
												<cfif bDisplayRateChange AND IsDefined("vars.qRebateItems.Rate_Change")>
												<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
												<th>
													<div class"notranslate english">
														Rate<br />Change
													</div>
												</th>
												</cfif>
											</cfif>
										</cfif>
										</cfoutput>
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

											<cfif request.language eq "french">
											<td>#vars.qRebateUniqueItems.ALt_Description#</td>
											<cfelse>
											<td>#vars.qRebateUniqueItems.Description#</td>
											</cfif>
											<!--- loop over matching items and display the rates --->
											<cfoutput query="vars.qRebateItems" group="BSA_Foodservice_Items_Master_ID">
												<cfif vars.qRebateUniqueItems.BSA_Foodservice_Items_Master_ID eq vars.qRebateItems.BSA_Foodservice_Items_Master_ID>
												<cfoutput> <!--- this ouput loops the query group - dont remove this output --->
												<cfif (distPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '1') OR (operPaysToDisplay AND vars.qRebateItems.Component_Paid_to eq '2')>
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
					</cfsavecontent> <!--- VARIABLES.letterProducts.rebateProducts.remainingPages --->

					<!--- Insert the page contents into the remaining pages Array --->
					<cfset VARIABLES.letterProducts.rebateProducts.remainingPages[#VARIABLES.thePageIndex#] = VARIABLES.thePageContents />

					<!--- Update the "startRow" and "endRow" for the query records to display --->
					<cfset VARIABLES.theCurrentPageStartRow = VARIABLES.theCurrentPageStartRow + VARIABLES.rowCounter />
					<cfset VARIABLES.theCurrentPageEndRow 	= VARIABLES.theCurrentPageStartRow + 44 />

					<!--- Update the Page Length Counter using the approximate size of the last Page's Content  --->
					<cfset VARIABLES.thePageLength = VARIABLES.thePageLength + fnCalculateContentSizeByNumber(evaluate((VARIABLES.rowCounter + 1) * 100)) />
				</cfloop>
			</cfif>

		</cfif> <!--- display based on template letters paysTo setting --->

	</cfif> <!--- vars.qRebateItems.recordCount  --->



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
		<cfif (distPaysToDisplay
                AND findNoCase('1', "#valuelist(vars.qLumpSums.Component_Paid_To)#"))
                OR (operPaysToDisplay AND findNoCase('2', "#valuelist(vars.qLumpSums.Component_Paid_To)#"))>

			<cfset VARIABLES.letterProducts.lumpSum = {}>

            <!--- lump sum heading page tags --->
            <cfsavecontent variable="VARIABLES.letterProducts.lumpSum.page_heading">
                <div class="container_16">
                    <div class="grid_16">
                        <p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> - #Application.LumpsumLabel#</cfif></p>
                    </div> <!--- class="grid_16"> --->
                    <div class="grid_16">
                        <table class="Design2" cellspacing="0" cellpadding="0">
                            <thead>
                                <tr>
                                    <th>#productLabel###</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
                                    <cfif bDisplayGTIN><th>GTIN</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
                                    <cfif bDisplayUPC><th>UPC</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
                                    <th>#application.returned_customer_setting.Item_Label# Description<cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></th>
                                </tr>
                            </thead>
                            <tbody>
            </cfsavecontent>
            <!--- lump sum closing page tags --->
            <cfsavecontent variable="VARIABLES.letterProducts.lumpSum.page_closing">
                            </tbody>
                        </table>
                    </div>   <!--- class="grid_16"> --->
                </div>      <!--- <div class="container_16"> --->
            </cfsavecontent>

            <!--- lump sum body --->
            <cfsavecontent variable="VARIABLES.letterProducts.lumpSum.page_body">
                <cfif NOT (arguments.letterType eq 2 AND vars.qLumpSums.Component_Paid_To eq 2)>
                    <cfloop query="vars.qLumpSums">
                        <cfset vars.qLumpSumProducts = LSDataManager.getProgramLumpSumProducts(vars.qLumpSums.Program_Lump_Sum_ID, URL.Contract_Main_ID)>
                        <cfloop query="vars.qLumpSumProducts">
                            <cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1'
                                and ListFind(VARIABLES.ExistingPricingLevelList,vars.qLumpSumProducts.Pricing_Level_ID) eq 0>
                                <cfset VARIABLES.Group_Level_Desc = vars.qLumpSumProducts.Group_Level_Desc>
                                <cfif VARIBLES.productGroupsExist eq 1>
                                    <tr>
                                        <td colspan="#VARIABLES.NumberOfColumns#"><strong>#VARIABLES.Group_Level_Desc#</strong></td>
                                    </tr>
                                    <cfset VARIABLES.ExistingPricingLevelList = ListAppend(VARIABLES.ExistingPricingLevelList,vars.qLumpSumProducts.Pricing_Level_ID)>
                                </cfif>
                            </cfif>
                            <tr>
                                <td>#(vars.qLumpSumProducts.item eq '' ? 'Group' : vars.qLumpSumProducts.item)#</td>
                                <cfif bDisplayGTIN><td>#vars.qLumpSumProducts.GTIN#</td></cfif>
                                <cfif bDisplayUPC><td>#vars.qLumpSumProducts.UPC#</td></cfif>
                                <cfif request.language eq "french">
                                    <td>#vars.qLumpSumProducts.ALt_Description#</td>
                                <cfelse>
                                    <td>#vars.qLumpSumProducts.Description#</td>
                                </cfif>
                            </tr>
                        </cfloop>

                        <tr style="border:none;">
                            <td colspan="9" style="border:none;">
                                <strong>Component</strong>: #vars.qLumpSums.Program_lump_sum_name#
                                <br />
                                <strong>Payable To</strong>: #templateManager.getPaymentPaidToTypeDesc(paidToID = vars.qLumpSums.Component_Paid_To, paidToDesc="")#
                                <br />
                                <strong>#vars.qLumpSums.Program_Lump_Sum_Name#</strong>
                            </td>
                        </tr>

                        <tr style="border:none;">
                            <td colspan="9" style="border:none;">
                                <strong>Claim Mechanism:</strong> #vars.qLumpSums.Payment_Type_Name#
                                <br />
                                <strong>Payment Cycle</strong>: #vars.PaymentCycleManager.getPaymentCycleDescription(vars.PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 3, vars.qLumpSums.Program_Lumps_Sum_Ext_Id))#
                                <br />
                                <strong>Amount</strong>: #dollarFormat(vars.qLumpSums.Lump_Sum_Amount)#
                            </td>
                        </tr>

                        <tr style="border:none;">
                            <td colspan="9" style="border:none;">
                                <i>(#vars.qLumpSums.Lump_Sum_Description#)</i>
                            </td>
                        </tr>
                    </cfloop>
                </cfif>
            </cfsavecontent>

            <cfscript>
                // empty out lump sum heading/closing when body is empty
                if ( trim(variables.letterProducts.lumpSum.page_body) eq '' ) {
                    variables.letterProducts.lumpSum.page_heading = '';
                    variables.letterProducts.lumpSum.page_closing = '';
                }
            </cfscript>
		</cfif>  <!--- display only if the display option is checked on template--->
	</cfif>  <!--- vars.qLumpSums.recordCount gt 0> --->

	<!---------------->
	<!---  GROWTH  --->
	<!---------------->
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset getComponents      = vars.programCFC.getgrowthComponents(URL.Contract_Main_ID, vars.appSettings.getGrowthExpansion1())>

	<cfif getComponents.recordCount>
		<cfset VARIABLES.ExistingPricingLevelList = "">
		<cfset VARIABLES.NumberOfColumns = 0>
		<!--- Dev Note (83568) - Check whether product groups exist for Growth --->
		<cfset VARIBLES.productGroupsExist = vars.GenProgramManager.programHasGroups(URL.Contract_Main_ID,4)>

		<cfsavecontent variable="VARIABLES.letterProducts.growth">

			<div class="container_16">
				<div class="grid_16">
					<p class="opa_group">#vars.qProgram.Contract_Number#<cfif arguments.discountTypeDisplay> -  #Application.GrowthLabel#</cfif></p>
				</div>  <!--- class="grid_16"> --->

				<cfloop query="getComponents">
				<cfset getComponentTiers    = vars.programCFC.getComponentTiers(URL.Contract_Main_ID, getComponents.Program_Growth_Component_ID)>
				<cfset displayGroupType     = genSettingsManager.getDisplayGroupType(vars.appSettings.getViewProgramProductGroupType()) />
				<cfset getComponentProducts = vars.programCFC.getComponentProducts(getComponents.Program_Growth_Component_ID, URL.Contract_Main_ID, displayGroupType)>


				<!------------------------------->
				<!---  GROWTH  |   PRODUCTS   --->
				<!------------------------------->
				<cfif getComponentProducts.recordCount>
				<div class="grid_16">
					<table class="Design2" cellspacing="0" cellpadding="0">
						<thead>
							<tr>
								<th>#productLabel###</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
								<cfif bDisplayGTIN><th>GTIN</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
								<cfif bDisplayUPC><th>UPC</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1></cfif>
								<th>#application.returned_customer_setting.Item_Label# Description</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
								<th>FPL</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
								<th>Rates</th><cfset VARIABLES.NumberOfColumns = VARIABLES.NumberOfColumns + 1>
							</tr>
						</thead>
						<tbody>
							<cfloop query="getComponentProducts">
							<cfset getComponentProductTierData  = vars.programCFC.getComponentProductTierData(URL.Contract_Main_ID,getComponentProducts.Contract_Products_ID)>
							<cfset decimalprecision = vars.GenProgramManager.decimalPrecisionByUOM(getComponentProductTierData.Unit_Of_Measure_ID,1)>
							<!--- Dev Note (78291 and 77408): When "Product_Group_Sequencing" app setting is ON and one group of one pricing level has not already been added to
							"ExistingPricingLevelList".This logic is needed so that we can only show the "group_level_desc" once for all the groups belonging to a single pricing level.
							Note: "group_level_desc" is shown on a single row for every pricing level.
							--->
							<cfif appSettings.get_Setting('Product_Group_Sequencing') eq '1' and ListFind(VARIABLES.ExistingPricingLevelList,getComponentProducts.Pricing_Level_ID) eq 0>
							<cfset VARIABLES.Group_Level_Desc = getComponentProducts.Group_Level_Desc>
							<cfif VARIBLES.productGroupsExist eq 1>
							<tr>
								<td colspan="#VARIABLES.NumberOfColumns#"><strong>#VARIABLES.Group_Level_Desc#</strong></td>
							</tr>
								<cfset VARIABLES.ExistingPricingLevelList = ListAppend(VARIABLES.ExistingPricingLevelList,getComponentProducts.Pricing_Level_ID)>
							</cfif>
							</cfif>
							<tr>
								<td>#(getComponentProducts.item eq '' ? 'Group' : getComponentProducts.item)#</td>
								<cfif bDisplayGTIN><td>#getComponentProducts.GTIN#</td></cfif>
								<cfif bDisplayUPC><td>#getComponentProducts.UPC#</td></cfif>
								<td>#getComponentProducts.Description#</td>
								<cfif request.language eq "french">
								<td>#getComponentProducts.ALt_Description#</td>
								<cfelse>
								<td>#getComponentProducts.Description#</td>
								</cfif>
								<td>#getComponentProducts.DisplayGroupName#</td>
								<td>
									<cfloop query="getcomponentproducttierdata">
									Tier #Tier_Number#:
									<cfif len(trim(getComponentProductTierData.Rate)) EQ 0>
									Pending...
									<cfelse>
									<cfif trim(getComponentProductTierData.Abbreviation) EQ "%">
									#trim(numberformat(getComponentProductTierData.Rate, decimalprecision))# #left(getComponentProductTierData.Abbreviation,2)#
									<cfelse>
									<cfif getComponentProductTierData.Unit_Of_Measure_ID EQ 1>
									$#trim(numberformat(getComponentProductTierData.Rate, decimalprecision))# per  #left(getComponentProductTierData.Abbreviation,2)#
									<cfelse>
									#trim(numberformat(getComponentProductTierData.Rate, decimalprecision))# per  #left(getComponentProductTierData.Abbreviation,2)#
									</cfif>   <!--- getComponentProductTierData.Unit_Of_Measure_ID EQ 1> --->
									</cfif>   <!--- trim(getComponentProductTierData.Abbreviation) EQ "%"> --->
									</cfif>   <!--- len(trim(getComponentProductTierData.Rate)) EQ 0 --->
									<br />
									</cfloop>  <!--- query="getcomponentproducttierdata" startrow="2"> --->
								</td>
							</tr>
							</cfloop>  <!--- query="getComponentProducts"> --->
						</tbody>
					</table>
				</div>  <!--- class="grid_16"> --->
				</cfif>  <!--- getComponentProducts.recordCount> --->

				<!------------------------------->
				<!---  GROWTH  |   COMPONENT  --->
				<!------------------------------->
				<div class="grid_6">
					<strong>Component</strong>: #getComponents.Component_Name#
					<br />
					<strong>Payable To</strong>: #templateManager.getPaymentPaidToTypeDesc( paidToID=getComponents.Component_Paid_To, paidToDesc="" )#
					<br />
					<cfloop query="getComponentTiers">
					<strong>Tier</strong>: #getComponentTiers.Tier_Number#
					<br />
					</cfloop>  <!--- query="getComponentTiers"> --->
				</div>  <!--- class="grid_6"> --->

				<div class="grid_6">
					<strong>Description:</strong> #replace(getComponents.Component_Description,"&##44",",","ALL")#
					<br />
					<strong>Payment Cycle</strong>:
					<cfmodule template="\common_files\contracts\payment_cycle_selection.cfm"
						Template_ID               = "#vars.qProgram.ProgramType_ID#"
						Program_ID                = "#URL.Contract_Main_ID#"
						discount_Type_ID          = "4"
						Selected_Payment_Cycle_ID = "#vars.PaymentCycleManager.getPaymentCycle(URL.Contract_Main_ID, 4, Growth_Component_Name_Id)#"
						Component_ID              = "#getComponents.Program_Growth_Component_ID#"
						Action                    = "display"
					>
					<br />
					<cfset tierFormat = "___,___,___,___,___,___,___," />
					<cfif getComponents.component_UOM EQ 3 AND appSettings.getGrowthDecimal4PercentTier() EQ 1>
					<cfset tierFormat = "___,___,___,___,___,___,___.___" />
					</cfif>
					<cfloop query="getComponentTiers">
					<strong>Range</strong>: #trim(numberformat(val(getComponentTiers.Range_Start), tierFormat))# <cfif trim(getComponentTiers.Range_End) EQ "*"> or More<cfelse>to #trim(numberformat(val(getComponentTiers.Range_End), tierFormat))#</cfif><br />
					</cfloop>  <!--- query="getComponentTiers"> --->
				</div>  <!--- class="grid_6"> --->

				<div class="grid_4">
					<br />
					<cfif
					(arguments.letterType eq 1 AND vars.qTemplateLetterSettings.Operator_Claim_Mechanism eq 1)
					OR
					(arguments.letterType eq 2 AND vars.qTemplateLetterSettings.Distributor_Claim_Mechanism eq 1)
					>
					<strong>Claim Mechanism</strong>: #getComponents.Payment_Type_Name#
					</cfif>
					<br />
					<cfloop query="getComponentTiers">
					<strong>Amount</strong>: #numberformat(getComponentTiers.Growth_Amount, '$,_')#
					<br />
					</cfloop>  <!--- query="getComponentTiers"> --->
				</div>  <!--- class="grid_4"> --->
				<br />
				<br />
				</cfloop>  <!--- query="getComponents"> --->
			</div>  <!--- class="container_16"> --->
		</cfsavecontent>

	</cfif>  <!---  getComponents.recordCount> --->

	<!----------------->
	<!---  CLAUSES  --->
	<!----------------->
	<cfsavecontent variable="VARIABLES.letterProducts.clauses">
		<cfloop query="vars.qClauses">
		<!--- Dev Note (71665) - "page-break-before:always;" puts every clause in it's own page --->
		<div class="container_16 notranslate english" style="page-break-before:always;">
			<div>
				<cfif request.language neq "french">
				#vars.qClauses.Clause_library_body#
				<cfelseif len(vars.qClauses.Clause_library_body_French)>
				#vars.qClauses.Clause_library_body_French#
				</cfif>
			</div>
		</div>
		</cfloop>

		<div class="container_16 confidentiality">
			<div class="grid_16">
				#application.returned_customer_setting.confidentiality_content#
			</div>
		</div>
	</cfsavecontent>   <!--- variable="variables.letterProducts"> --->

	<cfreturn variables.letterProducts />

</cffunction>

<cffunction name="fnCalculateContentSizeByString">
	<cfargument name="theContent" type="string" required="true" />

	<cfset VARIABLES.theContentSize = 0 />

<!---
	<!--- Update the Page Length Counter --->
	<cfif (len(ARGUMENTS.theContent) GT 0) AND (len(ARGUMENTS.theContent) LTE 2000)>
		<!--- The Content length is small --->
		<cfset VARIABLES.theContentSize = 30 />
	<cfelseif (len(ARGUMENTS.theContent) GTE 2001) AND (len(ARGUMENTS.theContent) LTE 4000)>
		<!--- The Content length is medium --->
		<cfset VARIABLES.theContentSize = 60 />
	<cfelseif len(ARGUMENTS.theContent) GTE 4001>
		<!--- The Content length is large --->
		<cfset VARIABLES.theContentSize = 90 />
	</cfif>

	<cfreturn VARIABLES.theContentSize />
--->
	<cfreturn round(len(ARGUMENTS.theContent) / 50) />
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


<cfscript>
    function translate_to_french ( required string ) output="false" {
        return replaceNoCase( application.util.string.GoogleTranslate( arguments.string, 'fr' ), 'Paye à', 'Payé à' );
    }

    function string_replace ( required string ) output="false" {
        return replaceNoCase(arguments.string, 'Paye à', 'Payé à');
    }
</cfscript>

