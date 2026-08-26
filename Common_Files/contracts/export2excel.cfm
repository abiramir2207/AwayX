<cf_cryp type="de" string="#URL.CID#" key="#request.key#">
<cfset contract_main_id = cryp.value>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />
<cfset qGetTemplateData = templateManager.getProgramTemplate(contract_main_id) />

<cfif NOT isDefined("application.oLetterManager")>
	<cfset application.oLetterManager = CreateObject("component", "mvc.Models.LetterManager")>
</cfif>

<cfquery name="dropTables" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##Tmp_Fixed_Price') IS NOT NULL
	DROP TABLE ##Tmp_Fixed_Price

	IF OBJECT_ID('tempdb..##Tmp_Rebate_Price') IS NOT NULL
	DROP TABLE ##Tmp_Rebate_Price

	IF OBJECT_ID('tempdb..##Tmp_Lumpsum_Price') IS NOT NULL
	DROP TABLE ##Tmp_Lumpsum_Price

	IF OBJECT_ID('tempdb..##Tmp_Growth_Price') IS NOT NULL
	DROP TABLE ##Tmp_Growth_Price
</cfquery>

<!--- OPERATORS INFO--->
<cfset OperatorDetails = application.oLetterManager.getOperatorDetails(contract_main_id)>
<cfquery NAME="OperatorDetails" dbtype="query">
	SELECT <cfif appSettings.getShowBSAOperators()>BSA_Operator_ID<cfelse>Legacy_ID</cfif> AS Operator_ID,Operator_Name
	FROM	OperatorDetails
	WHERE 0 = 0
</cfquery>

<!--- DISTRIBUTORS INFO--->
<cfset DistributorDetails = application.oLetterManager.getDistributorDetails(contract_main_id)>
<cfquery NAME="DistributorDetails" dbtype="query">
	SELECT shr_ship_to,Name
	FROM	DistributorDetails
	WHERE 0 = 0
</cfquery>


<!--- get decimal precision --->
<cfset decimalprecision = programManager.decimalPrecisionByUOM(0,1)>


<!--- FIXED COMPONENT INFO--->
<cfset FixedPriceProducts = application.oLetterManager.getFixedPriceProducts(contract_main_id)>
<cfset FixedCompColumns = "">

<cfquery NAME="FixedDistinctProducts" dbtype="query">
	SELECT Distinct Item, BSA_Foodservice_Items_Master_ID AS Product_ID, Description
	FROM	FixedPriceProducts
	WHERE 0 = 0
</cfquery>

<cfset FixedComps = ListRemoveDuplicates( ListChangeDelims( Replace( ValueList(FixedPriceProducts.CompName,"|") , ",", " ", "ALL") , ",", "|" ) )>
<cfset fixedComponentsHeader = "Description,Item">

<cfloop list="#FixedComps#" item="Comp" index="count">
	<cfset fixedComponentsHeader = listAppend(fixedComponentsHeader, Comp)>
	<cfset fixedComponentsHeader = listAppend(fixedComponentsHeader, 'UOM_'&count)>
	<cfset FixedCompColumns = listAppend(FixedCompColumns, '['&Comp&']'&' varchar(100)')>
	<cfset FixedCompColumns = listAppend(FixedCompColumns, '[UOM_'&count&']'&' varchar(10)')>
</cfloop>

<cfquery name="FixedPriceInfo" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##Tmp_Fixed_Price') IS NOT NULL
	DROP TABLE ##Tmp_Fixed_Price

	CREATE TABLE ##Tmp_Fixed_Price (
				Item varchar(50)
				,Product_ID uniqueidentifier
				,Description varchar(500)
				,#FixedCompColumns#
			)

	<cfoutput query="FixedDistinctProducts" group="Item">
		INSERT INTO ##Tmp_Fixed_Price (Item, Product_ID, Description <cfloop list="#FixedComps#" item="Comp" index="count">, [#comp#]</cfloop>)
		Values ('#Item#', '#Product_ID#', '#Description#'<cfloop list="#FixedComps#" item="Comp" index="count">, '#Comp#'</cfloop>)
	</cfoutput>

	<cfloop list="#FixedComps#" item="Comp" index="count">
		<cfloop query="FixedPriceProducts">
			<cfset discountRate = "#numberformat(fixed_Price_Value, decimalprecision)#" />

			UPDATE ##Tmp_Fixed_Price
			SET [#comp#] = '#discountRate#',
				      [UOM_#count#] = '#Abbreviation#'
			WHERE Product_ID = '#FixedPriceProducts.BSA_Foodservice_Items_Master_ID#'
			AND [#comp#] = '#Replace(CompName, ",", " ", "ALL")#'

		</cfloop>

		UPDATE ##Tmp_Fixed_Price
		SET [#comp#] = '0.00',
		       [UOM_#count#] = 'CS'
		WHERE  [#comp#] = '#comp#'

	</cfloop>

	Select #listqualify(fixedComponentsHeader,'"')# From ##Tmp_Fixed_Price
</cfquery>

<!--- LUMP SUM COMPONENT INFO--->
<cfset LumpSums = application.oLetterManager.getLumpSums(contract_main_id)>
<cfset LumpsumCompColumns = "">

<cfquery NAME="LumpsumProducts" datasource="#application.datasource#">
	SELECT CASE WHEN Component_Paid_To = 1
		THEN Program_Lump_Sum_Name+'_Distributor'+ ' ( $ '+Lump_Sum_Amount+' )'
		ELSE  Program_Lump_Sum_Name+'_Operator'+  '( $ '+Lump_Sum_Amount+' )'
		END AS CompName,
		ISNULL(T.Item, APGT.Group_Number) as Product_Code, *
	FROM	##TMP_LumpSum_Details T
	LEFT JOIN All_Product_Group_Types APGT
	ON APGT.Group_GUID = T.BSA_Foodservice_Items_Master_ID
	WHERE 0 = 0
----	AND T.BSA_Foodservice_Items_Master_ID  <> ''
</cfquery>

<cfquery NAME="LumpsumDistinctProducts" dbtype="query">
	SELECT Distinct Product_Code, BSA_Foodservice_Items_Master_ID AS Product_ID, Description
	FROM	LumpsumProducts
	WHERE  BSA_Foodservice_Items_Master_ID  IS NOT NULL
</cfquery>

<cfset LumpsumpComps = ListRemoveDuplicates( ListChangeDelims( Replace( ValueList(LumpsumProducts.CompName,"|") , ",", " ", "ALL") , ",", "|" ) )>
<cfset lumpsumComponentsHeader = "Description,Item">

<cfloop list="#LumpsumpComps#" item="Comp" index="count">
	<cfset lumpsumComponentsHeader = listAppend(lumpsumComponentsHeader, Comp)>
	<!--- <cfset lumpsumComponentsHeader = listAppend(lumpsumComponentsHeader,  'UOM_'&count)> --->
	<cfset LumpSumCompColumns = listAppend(LumpSumCompColumns, '['&Comp&']'&' varchar(100)')>
	<!--- <cfset LumpSumCompColumns = listAppend(LumpSumCompColumns, '[UOM_'&count&']'&' varchar(10)')> --->
</cfloop>


<cfquery name="LumpsumpPriceInfo" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##Tmp_Lumpsum_Price') IS NOT NULL
	DROP TABLE ##Tmp_Lumpsum_Price

	CREATE TABLE ##Tmp_Lumpsum_Price (
				Item varchar(50)
				,Product_ID uniqueidentifier
				,Description varchar(500)
				,#LumpSumCompColumns#
			)

<cfif LumpsumDistinctProducts.recordCount>
		<cfoutput query="LumpsumDistinctProducts" group="Product_Code">
			INSERT INTO ##Tmp_Lumpsum_Price (Item, Product_ID, Description <cfloop list="#LumpsumpComps#" item="Comp" index="count">, [#comp#]</cfloop>)
			Values ('#Product_Code#', '#Product_ID#', '#Description#'<cfloop list="#LumpsumpComps#" item="Comp" index="count">, '#Comp#'</cfloop>)
		</cfoutput>


	<cfloop list="#LumpsumpComps#" item="Comp" index="count">
		<cfloop query="LumpsumProducts">
<cfif len(LumpsumProducts.BSA_Foodservice_Items_Master_ID)>
			UPDATE ##Tmp_Lumpsum_Price
			SET [#comp#] = ''
			WHERE Product_ID = '#LumpsumProducts.BSA_Foodservice_Items_Master_ID#'
			AND [#comp#] = '#Replace(CompName, ",", " ", "ALL")#'
</cfif>
		</cfloop>

		UPDATE ##Tmp_Lumpsum_Price
		SET [#comp#] = ''
		WHERE  [#comp#] = '#Comp#'

	</cfloop>
</cfif>
	Select #listqualify(lumpsumComponentsHeader,'"')# From ##Tmp_Lumpsum_Price
</cfquery>

<!--- REBATE COMPONENT INFO--->
<cfset Rebates = application.oLetterManager.getRebateProducts(contract_main_id)>
<cfset RebateCompColumns = "">

<cfset application.oLetterManager.getRebateAlterateRecaptureRates(contract_main_id)>

<cfquery NAME="RebateProducts" datasource="#application.datasource#">
	SELECT CASE WHEN Component_Paid_To = 1 THEN Program_Rebates_Component_Name+'_Distributor' ELSE  Program_Rebates_Component_Name+'_Operator' END AS CompName,
			ISNULL(T.Item, APGT.Group_Number) as Product_Code, *
	FROM	##TMP_Rebate_Price_Details T
	LEFT JOIN All_Product_Group_Types APGT
	ON APGT.Group_GUID = T.BSA_Foodservice_Items_Master_ID
	WHERE 0 = 0
</cfquery>

<cfquery NAME="RebateDistinctProducts" dbtype="query">
	SELECT Distinct Product_Code, BSA_Foodservice_Items_Master_ID AS Product_ID, Description
	FROM	RebateProducts
</cfquery>

<cfquery name="temp_Table_Drop" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##tmp_pgm_rebate_comp_list') IS NOT NULL
	DROP TABLE ##tmp_pgm_rebate_comp_list
</cfquery>
<cfquery NAME="RebateDistinctComponents" datasource="#application.datasource#">
	SELECT 	DISTINCT Program_Rebates_Component_ID,
			CASE WHEN Component_Paid_To = 1 THEN Program_Rebates_Component_Name + '_Distributor' ELSE Program_Rebates_Component_Name + '_Operator' END AS CompName
	INTO	##tmp_pgm_rebate_comp_list
	FROM	##TMP_Rebate_Price_Details T

	SELECT 	c.*, ISNULL(alt.Alternate_Recapture_Rate_Index, 0) as Alternate_Recapture_Rate_Index, alt.Alternate_Recapture_Rate_Label
	FROM 	##tmp_pgm_rebate_comp_list c
	LEFT JOIN ##tmp_pgm_rebate_comp_alt alt
	ON		alt.Program_Rebates_Component_ID = c.Program_Rebates_Component_ID
</cfquery>

<cfset rebatesComponentsHeader = "Description,Item">
<cfset rebatesComponentsSelect = "Description,Item">
<cfset compCounter = 0 />
<cfset altCounter = 0 />
<cfoutput query="RebateDistinctComponents" group="Program_Rebates_Component_ID">
	<cfset Comp = Replace(CompName , ",", " ", "ALL") />
	<cfset compCounter = compCounter + 1 />
	<cfset compFieldName = '[' & Comp & ']' />
	<cfset compDisplayName = Comp />
	<cfset compUOMFieldName = '[UOM_' & Program_Rebates_Component_ID & ']' />
	<cfset compUOMDisplayName = 'UOM_' & compCounter />

	<!--- 1. Column names for excel - name doesn't have to be unique --->
	<cfset rebatesComponentsHeader = listAppend(rebatesComponentsHeader, compDisplayName)>
	<cfset rebatesComponentsHeader = listAppend(rebatesComponentsHeader, compUOMDisplayName)>
	<!--- 2. For Select - name doesn't have to be unique, enclosed in [] --->
	<cfset rebatesComponentsSelect = listAppend(rebatesComponentsSelect, compFieldName & ' as [' & compDisplayName & ']')>
	<cfset rebatesComponentsSelect = listAppend(rebatesComponentsSelect, compUOMFieldName & ' as [' & compUOMDisplayName & ']')>
	<!--- 3. Temp table field name - name has to be unique --->
	<cfset RebateCompColumns = listAppend(RebateCompColumns, compFieldName & ' varchar(100)')>
	<cfset RebateCompColumns = listAppend(RebateCompColumns, compUOMFieldName & ' varchar(10)')>

	<cfoutput> <!--- we need this cfoutput to loop over alternate recapture rates per component --->
		<cfif Alternate_Recapture_Rate_Index neq 0>
			<cfset altCounter = altCounter + 1 />
			<cfset altRateFieldName = '[Alt_recap_Rate_' & Program_Rebates_Component_ID & '_' & Alternate_Recapture_Rate_Index & ']' />
			<cfset altRateDisplayName = Alternate_Recapture_Rate_Label />
			<cfset altRateUOMFieldName = '[Alt_recap_UOM_' & Program_Rebates_Component_ID & '_' & Alternate_Recapture_Rate_Index & ']' />
			<cfset altRateUOMDisplayName = 'Alt UOM ' & altCounter />

			<!--- 1. Column names for excel - name doesn't have to be unique --->
			<cfset rebatesComponentsHeader = listAppend(rebatesComponentsHeader, altRateDisplayName)>
			<cfset rebatesComponentsHeader = listAppend(rebatesComponentsHeader, altRateUOMDisplayName)>
			<!--- 2. For Select - name doesn't have to be unique, enclosed in [] --->
			<cfset rebatesComponentsSelect = listAppend(rebatesComponentsSelect, altRateFieldName & ' as [' & altRateDisplayName & ']')>
			<cfset rebatesComponentsSelect = listAppend(rebatesComponentsSelect, altRateUOMFieldName & ' as [' & altRateUOMDisplayName & ']')>
			<!--- 3. Temp table field name - name has to be unique --->
			<cfset RebateCompColumns = listAppend(RebateCompColumns, altRateFieldName & ' varchar(100)')>
			<cfset RebateCompColumns = listAppend(RebateCompColumns, altRateUOMFieldName & ' varchar(10)')>
		</cfif>
	</cfoutput>
</cfoutput>

<cfquery name="RebatePriceInfo" datasource="#application.datasource#">

	IF OBJECT_ID('tempdb..##Tmp_Rebate_Price') IS NOT NULL
	DROP TABLE ##Tmp_Rebate_Price

	CREATE TABLE ##Tmp_Rebate_Price	(
				Item varchar(50)
				,Product_ID uniqueidentifier
				,Description varchar(500)
				,#RebateCompColumns#
			)

	<cfoutput query="RebateDistinctProducts">
		INSERT INTO ##Tmp_Rebate_Price (Item, Product_ID, Description)
		Values ('#Product_Code#', '#Product_ID#', '#Description#')
	</cfoutput>

	<!--- Update temp table with rebate rates --->
	<cfloop query="RebateProducts">
		<cfset discountRate = "#numberformat(Rate, decimalprecision)#" />
		<cfset comp = Replace(CompName, ",", " ", "ALL") />

		UPDATE ##Tmp_Rebate_Price
		SET [#comp#] = '#discountRate#',
			[UOM_#Program_Rebates_Component_ID#] = '#Abbreviation#'
		WHERE Product_ID = '#RebateProducts.BSA_Foodservice_Items_Master_ID#'
	</cfloop>

	<!--- Update temp table with alternate recapture rates --->
	<cfoutput query="RebateDistinctComponents">
		<cfif Alternate_Recapture_Rate_Index neq 0>
			<cfset altRateFieldName = '[Alt_recap_Rate_' & Program_Rebates_Component_ID & '_' & Alternate_Recapture_Rate_Index & ']' />
			<cfset altRateUOMFieldName = '[Alt_recap_UOM_' & Program_Rebates_Component_ID & '_' & Alternate_Recapture_Rate_Index & ']' />

			update	t
			set		#altRateFieldName# = alt.Rate,
					#altRateUOMFieldName# = alt.UOM_Desc
			from	##tmp_pgm_alt_recap_rates alt
			inner join ##Tmp_Rebate_Price t
			on		t.Product_ID = alt.BSA_Foodservice_Items_Master_ID
			where	alt.Program_Rebates_Component_ID = #Program_Rebates_Component_ID#
			and		alt.Alternate_Recapture_Rate_Index = #Alternate_Recapture_Rate_Index#

		</cfif>
	</cfoutput>

	Select 	#rebatesComponentsSelect#
	From 	##Tmp_Rebate_Price

</cfquery>


<!--- GROWTH COMPONENT INFO--->
<cfset Growths = application.oLetterManager.getGrowthProducts(contract_main_id)>
<cfset growthCompColumns = "">

<cfquery NAME="GrowthProducts" datasource="#application.datasource#">
	SELECT CASE WHEN Component_Paid_To = 1 THEN Program_Growth_Components_Name+'_Distributor' ELSE  Program_Growth_Components_Name+'_Operator' END AS CompName,
			ISNULL(T.Item, APGT.Group_Number) as Product_Code, *
	FROM	##TMP_Growth_Details T
	LEFT JOIN All_Product_Group_Types APGT
	ON APGT.Group_GUID = T.BSA_Foodservice_Items_Master_ID
	WHERE 0 = 0
</cfquery>

<cfquery NAME="GrowthDistinctProducts" dbtype="query">
	SELECT Distinct Product_Code, BSA_Foodservice_Items_Master_ID AS Product_ID, Description
	FROM	GrowthProducts
</cfquery>

<cfset GrowthComps =  ListRemoveDuplicates( ListChangeDelims( Replace( ValueList(GrowthProducts.CompName,"|") , ",", " ", "ALL") , ",", "|" ) )>
<cfset GrowthTiers =  ListRemoveDuplicates(valuelist(GrowthProducts.Tier_Number))>
<cfset growthComponentsHeader = "Description,Item">

<cfloop list="#GrowthComps#" item="Comp" index="count">
	<cfloop list="#GrowthTiers#" item="TierNum" index="num">
		<cfset growthComponentsHeader = listAppend(growthComponentsHeader, Comp&'_Tier_'&TierNum)>
		<cfset growthComponentsHeader = listAppend(growthComponentsHeader, 'UOM_'&count&'_Tier_'&TierNum)>
		<cfset growthCompColumns = listAppend(growthCompColumns, '['&Comp&'_Tier_'&TierNum&']'&' varchar(100)')>
		<cfset growthCompColumns = listAppend(growthCompColumns, '[UOM_'&count&'_Tier_'&TierNum&']'&' varchar(10)')>
	</cfloop>
</cfloop>

<cfquery name="GrowthPriceInfo" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##Tmp_Growth_Price') IS NOT NULL
	DROP TABLE ##Tmp_Growth_Price

	CREATE TABLE ##Tmp_Growth_Price	(
				Item varchar(50)
				,Product_ID uniqueidentifier
				,Description varchar(500)
				,#growthCompColumns#
		)

	<cfoutput query="GrowthDistinctProducts">
		INSERT INTO ##Tmp_Growth_Price (Item, Product_ID, Description <cfloop list="#GrowthComps#" item="Comp" index="count"> <cfloop list="#GrowthTiers#" item="TierNum" index="num"> , [#comp#_Tier_#TierNum#] </cfloop> </cfloop>)
		Values ('#Product_Code#', '#Product_ID#', '#Description#' <cfloop list="#GrowthComps#" item="Comp" index="count"> <cfloop list="#GrowthTiers#" item="TierNum" index="num"> , '#Comp#_Tier_#TierNum#' </cfloop> </cfloop> )
	</cfoutput>

	<cfloop list="#GrowthComps#" item="Comp" index="count">
		<cfloop list="#GrowthTiers#" item="TierNum" index="num">
			<cfloop query="GrowthProducts">
				<cfset discountRate = "#numberformat(Rate, decimalprecision)#" />

				UPDATE ##Tmp_Growth_Price
				SET [#comp#_Tier_#TierNum#] = '#discountRate#',
					[UOM_#count#_Tier_#TierNum#] = '#Abbreviation#'
				WHERE Product_ID = '#GrowthProducts.BSA_Foodservice_Items_Master_ID#'
				AND [#comp#_Tier_#TierNum#] = '#Replace(CompName, ",", " ", "ALL")#_Tier_#TierNum#'
				AND '#GrowthProducts.Tier_Number#'  = '#TierNum#'

			</cfloop>
		</cfloop>
	</cfloop>

	Select #listqualify(growthComponentsHeader,'"')# From ##Tmp_Growth_Price
</cfquery>

<!--- SAP PRICING UPLOAD INFO--->
<cfset marginDisplay = application.util.query.get_Setting("Margin_Display_Style", 0)>
<cfset discountFormulaPricing = qGetTemplateData.Discount_Formula_Pricing />

<!--- only show sap pricing upload if margin display setting is Custom_T and program template has formula pricing --->
<cfif trim(marginDisplay) eq "Custom_T" and discountFormulaPricing eq 1>

	<cfset sapPricingUploadHeader = "COND TYPE,DC,CUSTOMER,MATERIAL,RATE,CURR,PER,UOM,START DATE,END DATE,COMMENT,COMPONENT">

	<cfquery NAME="sapPricingUpload" datasource="#application.datasource#">

		DECLARE @Contract_Main_ID INT = #contract_main_id#,
             	@Contract_Start VARCHAR(10),
             	@Contract_End VARCHAR(10),
             	@Title VARCHAR(40)

		/* Program details */
		SELECT @Contract_Start = CONVERT(VARCHAR(10), cm.Contract_Start_Date, 101),
					@Contract_End = CONVERT(VARCHAR(10), cm.Contract_End_Date, 101),
					@Title = LTRIM(RTRIM(SUBSTRING(dbo.UDF_REMOVE_NON_ASCIICharOnly(cm.Contract_Title), 1, 40)))
		FROM   Contract_Main cm
		WHERE  cm.Contract_Main_ID = @Contract_Main_ID

		/* Fixed price component */
		DROP TABLE IF EXISTS ##tmp_pu_fpcomp

		SELECT c.Program_Fixed_Component_ID, cn.Program_Fixed_Component_Name
		INTO   ##tmp_pu_fpcomp
		FROM   Program_Fixed_Component c
		INNER JOIN Program_Fixed_Component_Name cn
		ON           cn.Program_Fixed_Component_Name_ID = c.Program_Fixed_Component_Name_ID
		WHERE  c.Program_ID = @Contract_Main_ID
		AND          c.Deleted = 0

		/* Distributors */
		DROP TABLE IF EXISTS ##tmp_pu_dist

		SELECT c.Shr_Ship_To as CUSTOMER
		INTO   ##tmp_pu_dist
		FROM   Contract_Distributors cd
		INNER JOIN BSA_Foodservice_Customers c
		ON           c.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
		WHERE  cd.Contract_Main_ID = @Contract_Main_ID
		AND          cd.Deleted = 0
		AND          cd.Is_Group = 0

		/* Products */
		DROP TABLE IF EXISTS ##tmp_pu_prod

		SELECT i.Item as MATERIAL,
					pd.Fixed_Price_Value as RATE,
					u.Abbreviation as UOM,
					fp.Program_Fixed_Component_Name as COMPONENT
		INTO   ##tmp_pu_prod
		FROM   Contract_Products cp
		INNER JOIN BSA_Foodservice_Items_Master i
		ON           i.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
		INNER JOIN Program_Fixed_Price_Product_Data pd
		ON           pd.Contract_Products_ID = cp.Contract_Products_ID
		AND          pd.Deleted = 0
		INNER JOIN ##tmp_pu_fpcomp fp
		ON           fp.Program_Fixed_Component_ID = pd.Program_Fixed_Component_ID
		INNER JOIN Units_of_Measure u
		ON           u.Unit_Of_Measure_ID = pd.Unit_Of_Measure_ID
		WHERE  cp.Contract_Main_ID = @Contract_Main_ID
		AND          cp.Deleted = 0
		AND          cp.Is_Group = 0
		AND          CAST(pd.Fixed_Price_Value as float) != 0

		/* Final */
		SELECT 'YLST' as [COND TYPE], '15' as [DC],
					d.CUSTOMER, p.MATERIAL, p.RATE,
					'USDN' AS CURR, '1' AS PER, p.UOM,
					@Contract_Start as [START DATE], @Contract_End as [END DATE],
					@Title as COMMENT,
					p.COMPONENT
		FROM   ##tmp_pu_prod p
		CROSS JOIN ##tmp_pu_dist d

	</cfquery>

</cfif>
<!--- Create & Add Contnet to Excel File --->
<cfset firstSheet = 1>
<cfscript>

	//Use an absolute path for the files.
	FileName = "#url.ContractNumber#.xls";
	donwloadfilepath = application.Doc_Path & "\Temp_Files\settings\" & FileName;

	objSpreadsheet=spreadsheetnew("#lcase(application.returned_customer_setting.operator_label_plural)#");

	SpreadSheetAddRow(objSpreadsheet,"#application.returned_customer_setting.operator_label_plural# ID,#application.returned_customer_setting.operator_label_plural# Name");
	SpreadSheetAddRows(objSpreadsheet,OperatorDetails);

	// create Distributors Sheet
	SpreadSheetCreateSheet(objSpreadsheet, "#lcase(application.returned_customer_setting.distributor_label_plural)#");
	// Add your data to Distributors Sheet
	SpreadSheetSetActiveSheet(objSpreadsheet,"#application.returned_customer_setting.distributor_label_plural#");
	SpreadSheetAddRow(objSpreadsheet,"#application.returned_customer_setting.Shard_Ship_To_Label#, #application.returned_customer_setting.distributor_label_plural# Name");
	SpreadSheetAddRows(objSpreadsheet,DistributorDetails);

	// create Fixed Price Sheet
	SpreadSheetCreateSheet(objSpreadsheet, "#lcase(Application.FixedPriceLabel)#");
	//	Add your data to Fixed Price Sheet
	SpreadSheetSetActiveSheet(objSpreadsheet,"#lcase(Application.FixedPriceLabel)#");
	SpreadSheetAddRow(objSpreadsheet,"#fixedComponentsHeader#");
	SpreadSheetAddRows(objSpreadsheet,FixedPriceInfo);

	 //	create Rebate Sheet
	SpreadSheetCreateSheet(objSpreadsheet, "#lcase(Application.RebateLabel)#");
	//	Add your data to Rebate Sheet
	SpreadSheetSetActiveSheet(objSpreadsheet,"#lcase(Application.RebateLabel)#");
	SpreadSheetAddRow(objSpreadsheet,"#rebatesComponentsHeader#");
	SpreadSheetAddRows(objSpreadsheet,RebatePriceInfo);

	 //	create Lump Sum Sheet
	SpreadSheetCreateSheet(objSpreadsheet, "#lcase(Application.lumpsumlabel)#");
	//	Add your data to Lump Sum Sheet
	SpreadSheetSetActiveSheet(objSpreadsheet,"#lcase(Application.lumpsumlabel)#");
	SpreadSheetAddRow(objSpreadsheet,"#lumpsumComponentsHeader#");
	SpreadSheetAddRows(objSpreadsheet,LumpsumpPriceInfo);

	 //	create Growth Sheet
	SpreadSheetCreateSheet(objSpreadsheet, "#lcase(Application.GrowthLabel)#");
	//	Add your data to Growth Sheet
	SpreadSheetSetActiveSheet(objSpreadsheet,"#lcase(Application.GrowthLabel)#");
	SpreadSheetAddRow(objSpreadsheet,"#growthComponentsHeader#");
	SpreadSheetAddRows(objSpreadsheet,GrowthPriceInfo);

	 //	create SAP Pricing Upload Sheet
	 // only show sap pricing upload if margin display setting is Custom_T and program template has formula pricing
	if (trim(marginDisplay) eq "Custom_T" and discountFormulaPricing eq 1){
	SpreadSheetCreateSheet(objSpreadsheet, "SAP Pricing Upload");
	//	Add your data to SAP Pricing Upload Sheet
	SpreadSheetSetActiveSheet(objSpreadsheet,"SAP Pricing Upload");
	SpreadSheetAddRow(objSpreadsheet,"#sapPricingUploadHeader#");
	SpreadSheetAddRows(objSpreadsheet,sapPricingUpload);
	}

	SpreadsheetSetActiveSheet(objSpreadsheet, #lcase(application.returned_customer_setting.operator_label_plural)#);
</cfscript>

<cfspreadsheet action="write" filename="#donwloadfilepath#" name="objSpreadsheet" sheetname="#lcase(application.returned_customer_setting.operator_label_plural)#" overwrite=true>

<cfheader name="Content-Disposition" value="attachment; filename=#FileName#" >
<cfcontent type="application/vnd.ms-excel" file="#donwloadfilepath#">