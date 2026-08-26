<cfparam name="url.sortBy"    default="sold_to">
<cfparam name="url.sortOrder" default="asc">
<cfparam name="url.Operator" default=""> <!--- Blank = Default/Combined, 0 = Distributor TPA, 1 = Operator TPA ---->

<cfscript>
	variables.sold_to 	= 'sold_to';
	variables.name 		= 'name';
	variables.ascending = 'asc';
	variables.descending = 'desc';
	variables.aURL 		 = [];
</cfscript>
<cfloop collection="#url#" item="variables.urlEntry">
      <cfif variables.urlEntry neq "sortBy" and variables.urlEntry neq "sortOrder">
        <cfset arrayAppend(variables.aURL, variables.urlEntry & "=" & URL[variables.urlEntry])>
      </cfif>
</cfloop>
<cfset variables.reloadHref = cgi.script_name & '?' & arrayToList(variables.aURL, '&')>

<cfset displayName =  "#application.returned_customer_setting.Trade_Label# Adjustment"/>
<CFSET PAGE_TITLE="#displayName# Calculation">
<!DOCTYPE HTML>
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<script>
		function toggleRateDisplay(ID,sts) {
			tempVar = eval("document.all.RS_"+ID);
			if(tempVar != null){
				if(sts == 0) {
					if(tempVar[0].style.display == "none") {
						toggleStatus = ""
					}
					else {
						toggleStatus = "none"
					}
				}
				else{
					toggleStatus = sts
				}


				for(var x=0; x<tempVar.length;x++){
					tempVar[x].style.display = toggleStatus;
				}
			}
		}
	</script>

	<style>
		TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
		.header {font-size: 12px;}
		.hidden { display: none; }
	</style>

</HEAD>
<BODY>
<cfparam name="url.type"  default="LB">
<cfparam name="URL.CPID" 	default=0>
<cfparam name="URL.CID" 	default=0>
<cfparam name="url.ItemId" default=0>
<CFPARAM name="url.margin_type" default="1">
<CFPARAM NAME="STAT_MULTIPLIER" default= 1>
<CFPARAM NAME="URL.TPA_TYPE" default= 0>
<cfparam name="URL.PlannerID" 	default=0>


<cfif URL.TPA_TYPE neq "0" and URL.TPA_TYPE neq "1">
	<cfset URL.TPA_TYPE = 0 />
</cfif>
<cfif URL.TPA_TYPE eq 1>
	<cfset displayName =  "Component Cost"/>
</cfif>

<CF_Cryp type="de" key="#request.key#" string ="#URL.CID#">
<CFSET URL.CID = cryp.value>


<CFIF (((URL.CPID EQ 0 OR URL.CID EQ 0) AND (URL.ItemID EQ 0 OR URL.CID EQ 0)) OR (URL.CPID NEQ 0 AND NOT isNumeric(URL.CPID) OR NOT isNumeric(URL.CID)))
      AND (URL.ItemID EQ 0 OR URL.PlannerID EQ 0 OR NOT isNumeric(URL.PlannerID))>
	<BLOCKQUOTE>
	<BR><BR><BR><SPAN CLASS="TITLE2">Invalid Contract/Product information</SPAN>
	</BLOCKQUOTE>
	<CFABORT>
</CFIF>

<cfset type = url.type>
<CFSET CPID=URL.CPID>
<CFSET CID=URL.CID>
<CFSET ItemId = url.ItemId>
<CFSET PlannerID = Val(url.PlannerID)>


<cfset appSettings = application.appSettingsGet />
<cfset Margin_Display_Style = appSettings.get_Setting('Margin_Display_Style') />
<cfset WeightTPABasedOnDate = 1 />


<CFQUERY NAME="Program_Details" DATASOURCE="#Application.Datasource#">
    <cfif PlannerID eq 0>
	SELECT 	Contract_Number, Contract_Start_Date, Contract_End_Date, Search_Sequence_ID, Program_Control_Panel_Options.Exclude_Same_Spending_Cat_From_TPA, Program_Control_Panel_Options.Generic_Type
	FROM 	Contract_Main
	INNER JOIN Program_Control_Panel_Options
	ON		Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	WHERE 	Contract_Main_ID = <cfqueryparam value="#CID#" cfsqltype="CF_SQL_INTEGER">
    <cfelse>
    SELECT 	Planner_Number as Contract_Number, Planner_Start_Date as Contract_Start_Date, Planner_End_Date as Contract_End_Date,
            0 as Search_Sequence_ID,0 as Exclude_Same_Spending_Cat_From_TPA, 'Planner' as Generic_Type
	FROM 	Planners p
	INNER JOIN Planner_Template pt ON pt.Planner_Template_ID = p.Planner_Template_ID
	WHERE 	Planner_ID = <cfqueryparam value="#PlannerID#" cfsqltype="CF_SQL_INTEGER">
    </cfif>
</CFQUERY>

<cfset excludeOperatorTPA = 0 />
<cfset OperatorTPAInOperatorProgram = 0 />
<cfset Filter_Operator_Distributor_Value = url.Operator />
<!----- if current program is an operator program and if the application switch is on ----->
<!---
When getOperatorTPAInDistributorPrograms = 1, TPA table will have entry from distributor and operator programs.
When current program is an operator program, by default we will only include TPA from distributor programs (excludeOperatorTPA = 1).
		But when margin type = custom_t, vertical P & L has Operator Trade and Distributor Trade split into 2 buckets. Operator program will include TPA from other operator programs with same operator/item
When current program is a distributor program, we will include TPA from both distributor and operator programs (excludeOperatorTPA = 0).

Operator_Distributor has belwo values in TPA table,
0 = Distributor TPA (Show in all programs),  Source = Distributor programs
1 = Operator TPA (For distributor programs), Source = Billback
2 = Operator TPA (For operator programs),  Source = Distributor programs
--->
<cfif appSettings.getOperatorTPAInDistributorPrograms()>

	<!--- Operator template --->
	<cfif ListFindNOCase("Operator Direct or HQ Programs,Operator-Deviated Pricing", Program_Details.Generic_Type) NEQ 0>

		<cfset excludeOperatorTPA = 1 />

		<CFIF url.Operator EQ "1">
			<!---
			For custom_t, TPA is split into 2 buckets.
			We need to show operator TPA in operator programs for custom_t
			--->
			<cfset OperatorTPAInOperatorProgram = 1 />
			<cfset excludeOperatorTPA = 0 />
			<cfset Filter_Operator_Distributor_Value = 2 />
		</CFIF>
	<cfelse> <!--- Distributor template --->
		<CFIF url.Operator EQ "1">
			<cfset WeightTPABasedOnDate = 0 /> <!--- Don't do date overlap weighing for Operator TPA in distributor programs --->
		</CFIF>
	</cfif>
</cfif>


<cfset excludeSameSpendingCategoryFromTPAForThisProgram = 0 />
<cfif appSettings.getOperatingGroupOn() AND Program_Details.Exclude_Same_Spending_Cat_From_TPA EQ 1>
	<cfset excludeSameSpendingCategoryFromTPAForThisProgram = 1 />
</cfif>

<cfset searchSequenceNumber = 0 />
<cfset operatingGroupId = 0 />
<!------ If Operating Group is on ----->
<cfif appSettings.getOperatingGroupOn()>
	<!------ Get the search sequence number  ----->
	<cfset searchSequenceManager 			= CreateObject("component", "components.Search_Sequence.SearchSequenceManager").init() />
	<cfset Search_Sequence_Name = searchSequenceManager.getSearchSequenceInfo(Program_Details.Search_Sequence_ID) />
	<cfset searchSequenceNumber = Val(Search_Sequence_Name.Search_Sequence_Legacy) />

	<!------ operating group id ----->
	<cfset operatingGroupManager 	= CreateObject("component", "components.Operating_Group.OperatingGroupManager").init() />
	<cfset programLevel2Level 		= operatingGroupManager.getProgramLevel2Level() />
	<cfset operatingGroupId 		= operatingGroupManager.getProgramOperatingGroupID(level=programLevel2Level, programId=CID) />
</cfif>

<cfset productPrice = 0 />

<CFQUERY NAME="qDropTables" datasource="#application.datasource#">
    IF OBJECT_ID('tempdb..##tmp_tpa_exlude_programs') IS NOT NULL
    DROP TABLE ##tmp_tpa_exlude_programs
</CFQUERY>

	<CFQUERY NAME="getThisProductsDistCombos" datasource="#application.datasource#">
    IF OBJECT_ID('tempdb..##tmp_tpa_exlude_programs') IS NOT NULL
    DROP TABLE ##tmp_tpa_exlude_programs

    create table ##tmp_tpa_exlude_programs (Contract_Number nvarchar(20))

    <cfif PlannerID eq 0>
	-- Insert Contract_Number
	INSERT INTO ##tmp_tpa_exlude_programs (Contract_Number) VALUES ('#Program_Details.contract_number#')
    <cfelse>
    -- Get programs from planner
    insert into ##tmp_tpa_exlude_programs (Contract_Number)
    select	Contract_Number
    from	Contract_Main cm
    where	cm.Planner_ID = #PlannerID#
    </cfif>
</CFQUERY>

<cfif CPID NEQ 0>

<!--- Rate less than .0001 becomes 0, as we only consider values upto 4 decimal places --->
<CFQUERY NAME="getThisProductsDistCombos" datasource="#application.datasource#">
SELECT
			DISTINCT
			CAST(CAST(pdt.Rate As float) As decimal(30,10)) As Rate,
			cfc.Ship_To,
			cfc.Name,
			cfc.City,
			cfc.State,
			cd.Program_Weight,
			cfi.UPC,
			cfi.Description,
			cfi.net_weight,
			cfi.BSA_Foodservice_Items_Master_ID,
			cfc.BSA_Foodservice_Customers_ID,
			((CAST(CAST(pdt.Rate AS FLOAT) As decimal(30,10)) * CAST(cd.Program_Weight AS FLOAT)/100)) AS WTPR,
			0 Search_Sequence_Number
FROM
			(Contract_Products cp
				INNER JOIN BSA_Foodservice_Items_Master cfi
				ON cp.BSA_Foodservice_Items_Master_ID = cfi.BSA_Foodservice_Items_Master_ID)
			LEFT JOIN
			((Contract_Distributors cd
			INNER JOIN BSA_Foodservice_Customers cfc
			ON cfc.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID)
			LEFT JOIN Program_Distributors_Trade_Rate pdt
			ON(
			pdt.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID
			AND
			pdt.Deleted = 0
			))
			ON(
			cd.Contract_Main_ID = #CID#
			AND
			cd.Deleted = 0
			AND
			pdt.BSA_Foodservice_Items_Master_ID = cp.BSA_Foodservice_Items_Master_ID
			)
WHERE

			cp.Contract_Main_ID = #CID#
			AND
			cp.Contract_Products_ID = #CPID#
			AND
			cp.Deleted = 0
ORDER BY	cfi.UPC, cfc.Ship_To
</CFQUERY>

<cfelseif ItemId NEQ 0>

<cfif appSettings.getOperatingGroupOn()>

	<!--- Rate less than .0001 becomes 0, as we only consider values upto 4 decimal places --->
	<CFQUERY NAME="getThisProductsDistCombos" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##Tmp_Distributors') IS NOT NULL
		DROP TABLE ##Tmp_Distributors

		SET NOCOUNT ON
		CREATE TABLE ##Tmp_Distributors
		(
			BSA_Foodservice_Customers_ID uniqueidentifier,
			Ship_To varchar(100),
			Name varchar(100),
			City varchar(100),
			State varchar(100),
			Program_Weight float
		)
		-- Get customers from this program
		INSERT INTO ##Tmp_Distributors (BSA_Foodservice_Customers_ID, Ship_To, Name, City, State, Program_Weight)
		SELECT	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
				BSA_Foodservice_Customers.Ship_To,
				BSA_Foodservice_Customers.Name,
				BSA_Foodservice_Customers.City,
				BSA_Foodservice_Customers.State,
				Contract_Distributors.Program_Weight
		FROM	Contract_Distributors
		INNER JOIN BSA_Foodservice_Customers
		ON 		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
		WHERE	Contract_Distributors.Contract_Main_ID =  #CID#
		AND		Contract_Distributors.Deleted = 0

		SELECT	cfc.Ship_To,
			cfc.Name,
			cfc.City,
			cfc.State,
			cd.Program_Weight,
			cfi.UPC,
			cfi.Description,
			cfi.BSA_Foodservice_Items_Master_ID,
			cfi.net_weight,
			cfi.CASE_EQUIVALENT,
			cfc.BSA_Foodservice_Customers_ID,
			ISNULL(SUM(cast(cast(pdt.Rate as float) As Decimal (20,4))), 0) as Rate,
			ISNULL(SUM(cast(cast(pdt.Rate as float) As Decimal (20,4))) * (CAST(cd.Program_Weight AS FLOAT)/100), 0) as WTPR,
			ISNULL(SUM(cast(cast(pdt.Rate as float) As Decimal (20,4)) * cast(cfi.net_weight as float)), 0) as Rate_CS,
			ISNULL(SUM(cast(cast(pdt.Rate as float) As Decimal (20,4)) * cast(cfi.net_weight as float)) * (CAST(cd.Program_Weight AS FLOAT)/100), 0) as WTPR_CS
		FROM	Contract_Distributors cd

		INNER JOIN BSA_Foodservice_Customers cfc
		ON	cfc.BSA_Foodservice_Customers_ID = cd.BSA_Foodservice_Customers_ID

		INNER JOIN BSA_Foodservice_Items_Master cfi
		ON	cfi.BSA_Foodservice_Items_Master_Id = '#replace(ItemId, "_", "-", "ALL")#'

		LEFT JOIN Program_Distributors_Trade pdt
		ON	pdt.Deleted = 0
		AND pdt.TPA_Record_Type = #URL.TPA_TYPE#
		AND	pdt.BSA_Foodservice_Items_Master_Id = cfi.BSA_Foodservice_Items_Master_Id
		AND	pdt.BSA_Foodservice_Customers_ID = cfc.BSA_Foodservice_Customers_ID
		AND	pdt.Contract_Main_ID NOT IN (SELECT Contract_Main_ID FROM Contract_Main WHERE Contract_Number = '#Program_Details.contract_number#')
		<CFIF IsNumeric(Filter_Operator_Distributor_Value)>
		AND pdt.Operator_Distributor = #Filter_Operator_Distributor_Value#
		</CFIF>
		AND	pdt.Search_Sequence_ID = pdt.Min_Search_Sequence_ID
		<cfif excludeSameSpendingCategoryFromTPAForThisProgram><!------ do not include same spending category(operating group) ----->
		AND	pdt.Operating_Group_ID <> <cfqueryparam value="#operatingGroupId#" cfsqltype="CF_SQL_INTEGER">
		<!------ ignore rate if same spending category/operating group ----->
		</cfif>

		WHERE	cd.Deleted = 0
		AND	cd.Contract_Main_ID = #CID#

		Group By cfc.Ship_To,
		 	cfc.Name,
		 	cfc.City,
		 	cfc.State,
		 	cd.Program_Weight,
		 	cfi.UPC,
		 	cfi.Description,
		 	cfi.BSA_Foodservice_Items_Master_ID,
		 	cfi.net_weight,
		 	cfi.CASE_EQUIVALENT,
		 	cfc.BSA_Foodservice_Customers_ID
		<cfif url.sortBy eq variables.sold_to>
			ORDER BY cfc.Ship_To <cfif url.sortOrder eq variables.descending> desc </cfif>
		<cfelseif url.sortBy eq variables.name>
			ORDER BY cfc.Name <cfif url.sortOrder eq variables.descending> desc </cfif>
		</cfif>
	</CFQUERY>
<cfelse><!------ operating group is off ----->


    <cfif PlannerID eq 0>
        <CFQUERY NAME="getBasePrice" datasource="#application.datasource#">
        SELECT 	Program_Price_LB
        FROM 	contract_product_margin
        WHERE 	Contract_Main_ID = <cfqueryparam value="#CID#" cfsqltype="CF_SQL_INTEGER">
        AND 	product_id = '#replace(ItemId, "_", "-", "ALL")#'
        </CFQUERY>

        <cfif getBasePrice.recordCount and IsNumeric(getBasePrice.Program_Price_LB)>
            <cfset productPrice = getBasePrice.Program_Price_LB />
        </cfif>
    <cfelse>
        <CFQUERY NAME="getBasePrice" datasource="#application.datasource#">
        select  Sales_LB
        from    Planner_Margin_Data
        where   Planner_ID = #PlannerID#
        and     Product_ID = '#replace(ItemId, "_", "-", "ALL")#'
        and     Program_ID = 0
        </CFQUERY>

        <cfif getBasePrice.recordCount and IsNumeric(getBasePrice.Sales_LB)>
            <cfset productPrice = getBasePrice.Sales_LB />
        </cfif>
    </cfif>

    <CFQUERY NAME="qDropTables" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##Tmp_Distributors') IS NOT NULL
	DROP TABLE ##Tmp_Distributors
    IF OBJECT_ID('tempdb..##tmp_tpa_planner_distributors') IS NOT NULL
    DROP TABLE ##tmp_tpa_planner_distributors
	IF OBJECT_ID('tempdb..##Tmp_Operators') IS NOT NULL
	DROP TABLE ##Tmp_Operators
	IF OBJECT_ID('tempdb..##Tmp_Operator_TPA_In_Operator_Program_1') IS NOT NULL
	DROP TABLE ##Tmp_Operator_TPA_In_Operator_Program_1
	IF OBJECT_ID('tempdb..##Tmp_TPA_Initial') IS NOT NULL
	DROP TABLE ##Tmp_TPA_Initial
	IF OBJECT_ID('tempdb..##Tmp_TPA') IS NOT NULL
	DROP TABLE ##Tmp_TPA
    </CFQUERY>

	<!--- Rate less than .0001 becomes 0, as we only consider values upto 4 decimal places --->
	<CFQUERY NAME="getThisProductsDistCombos" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##Tmp_Distributors') IS NOT NULL
	DROP TABLE ##Tmp_Distributors

	IF OBJECT_ID('tempdb..##Tmp_TPA') IS NOT NULL
	DROP TABLE ##Tmp_TPA

	SET NOCOUNT ON
	CREATE TABLE ##Tmp_Distributors
	(
		BSA_Foodservice_Customers_ID uniqueidentifier,
		Ship_To varchar(100),
		Name varchar(100),
		City varchar(100),
		State varchar(100),
		Program_Weight float
	)
	CREATE TABLE ##Tmp_TPA_Initial
	(
		BSA_Foodservice_Customers_ID uniqueidentifier,
		BSA_Foodservice_Items_Master_ID uniqueidentifier,
		Rate decimal(30,10),
		Rate_Percent_On_Fixed_Price decimal(30,10),
		Contract_Main_ID int,
		Contract_Number varchar(20),
		Contract_Start_Date DATETIME,
		Contract_End_Date DATETIME,
		Overlap_Start DATE,
		Overlap_End DATE
	)
	CREATE TABLE ##Tmp_TPA
	(
		BSA_Foodservice_Customers_ID uniqueidentifier,
		BSA_Foodservice_Items_Master_ID uniqueidentifier,
		Rate decimal(30,10),
		Annualized_Rate decimal(30,10)
	)

    <cfif PlannerID eq 0>
	-- Get customers from this program
	INSERT INTO ##Tmp_Distributors (BSA_Foodservice_Customers_ID, Ship_To, Name, City, State, Program_Weight)
	SELECT	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
			BSA_Foodservice_Customers.Ship_To,
			BSA_Foodservice_Customers.Name,
			BSA_Foodservice_Customers.City,
			BSA_Foodservice_Customers.State,
			Contract_Distributors.Program_Weight
	FROM	Contract_Distributors
	INNER JOIN BSA_Foodservice_Customers
	ON 		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Contract_Distributors.BSA_Foodservice_Customers_ID
	WHERE	Contract_Distributors.Contract_Main_ID = #CID#
	AND		Contract_Distributors.Deleted = 0
    <cfelse>
    -- Get customers from planner

    IF OBJECT_ID('tempdb..##tmp_tpa_planner_distributors') IS NOT NULL
    DROP TABLE ##tmp_tpa_planner_distributors

    create table ##tmp_tpa_planner_distributors (Distributor_ID uniqueidentifier)

    -- If planner has individual distributor
    insert into ##tmp_tpa_planner_distributors (Distributor_ID)
    select	DISTINCT Customer_ID
    from	Planners p
    where	p.Planner_ID = #PlannerID#
    and		ISNULL(p.Distributor_Group_Level_ID, 0) = 0

    -- If planner has group distributor
    insert into ##tmp_tpa_planner_distributors (Distributor_ID)
    select	DISTINCT Distributor_ID
    from	Planner_Customer_Group_Members p
    where	p.Planner_ID = #PlannerID#

	INSERT INTO ##Tmp_Distributors (BSA_Foodservice_Customers_ID, Ship_To, Name, City, State, Program_Weight)
	SELECT	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID,
			BSA_Foodservice_Customers.Ship_To,
			BSA_Foodservice_Customers.Name,
			BSA_Foodservice_Customers.City,
			BSA_Foodservice_Customers.State,
			100.00 / Count(*) OVER (Partition By 1) as Program_Weight
	FROM	##tmp_tpa_planner_distributors d
	INNER JOIN BSA_Foodservice_Customers
	ON 		BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = d.Distributor_ID
    </cfif>

	<cfif OperatorTPAInOperatorProgram EQ 1>
		-- Get operators from this program
		SELECT	BSA_Operator_ID
		INTO	##Tmp_Operators
		FROM	Contract_Operators
		WHERE	Contract_Operators.Contract_Main_ID = #CID#
		AND		Contract_Operators.Deleted = 0
	</cfif>

	--Current program dates
	DECLARE @Program_Start DATE = '#DateFormat(Program_Details.Contract_Start_Date, "mm/dd/yyyy")#',
			@Program_End DATE = '#DateFormat(Program_Details.Contract_End_Date, "mm/dd/yyyy")#',
			@Program_Span DECIMAL(20, 4)
	SET @Program_Span = DATEDIFF(d, @Program_Start, @Program_End) + 1


	-- Get the TPA for the customer from this program for the current product

	INSERT INTO ##Tmp_TPA_Initial (BSA_Foodservice_Customers_ID, BSA_Foodservice_Items_Master_ID, Rate, Rate_Percent_On_Fixed_Price,
				Contract_Main_ID, Contract_Number, Contract_Start_Date, Contract_End_Date,
				Overlap_Start, Overlap_End)
	SELECT		Program_Distributors_Trade.BSA_Foodservice_Customers_ID, Program_Distributors_Trade.BSA_Foodservice_Items_Master_ID,
				ISNULL(Program_Distributors_Trade.Rate, 0) as Rate,
				ISNULL(Program_Distributors_Trade.Rate_Percent_On_Fixed_Price, 0) as Rate_Percent_On_Fixed_Price,
				Program_Distributors_Trade.Contract_Main_ID, Program_Distributors_Trade.Contract_Number,
				Program_Distributors_Trade.Contract_Start_Date, Program_Distributors_Trade.Contract_End_Date,
				CASE
				WHEN Program_Distributors_Trade.Operator_Distributor = 1 THEN @Program_Start
				WHEN Program_Distributors_Trade.Contract_Start_Date BETWEEN @Program_Start AND @Program_End THEN Program_Distributors_Trade.Contract_Start_Date
				WHEN @Program_Start BETWEEN Program_Distributors_Trade.Contract_Start_Date AND Program_Distributors_Trade.Contract_End_Date THEN @Program_Start
				END as Overlap_Start,
				CASE
				WHEN Program_Distributors_Trade.Operator_Distributor = 1 THEN @Program_End
				WHEN Program_Distributors_Trade.Contract_End_Date BETWEEN @Program_Start AND @Program_End THEN Program_Distributors_Trade.Contract_End_Date
				WHEN @Program_End BETWEEN Program_Distributors_Trade.Contract_Start_Date AND Program_Distributors_Trade.Contract_End_Date THEN @Program_End
				END as Overlap_End
	FROM		##Tmp_Distributors cfc
	INNER JOIN 	Program_Distributors_Trade
	ON			Program_Distributors_Trade.BSA_Foodservice_Customers_ID = cfc.BSA_Foodservice_Customers_ID
	AND			Program_Distributors_Trade.BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'
	AND			Program_Distributors_Trade.TPA_Record_Type = #URL.TPA_TYPE#
	AND			Program_Distributors_Trade.Deleted = 0
	<CFIF IsNumeric(Filter_Operator_Distributor_Value)>
	AND Program_Distributors_Trade.Operator_Distributor = #Filter_Operator_Distributor_Value#
	</CFIF>
	INNER JOIN	Contract_Main
	ON			Contract_Main.Contract_Main_ID = Program_Distributors_Trade.Contract_Main_ID
	INNER JOIN 	program_control_panel_options
	ON			program_control_panel_options.programcontrol_panel_options_id = contract_main.programtype_id
	WHERE		Contract_Main.Contract_Number NOT IN (SELECT Contract_Number FROM ##tmp_tpa_exlude_programs)
	<cfif excludeOperatorTPA>
	AND		program_control_panel_options.generic_type not in ('Operator Direct or HQ Programs', 'Operator-Deviated Pricing')
	</cfif>

	AND
			  (
				(@Program_Start >= Program_Distributors_Trade.Contract_Start_Date AND @Program_Start <= Program_Distributors_Trade.Contract_End_Date)
				OR
				(@Program_End >= Program_Distributors_Trade.Contract_Start_Date AND @Program_End <= Program_Distributors_Trade.Contract_End_Date)
				OR
				(Program_Distributors_Trade.Contract_Start_Date >= @Program_Start AND Program_Distributors_Trade.Contract_End_Date <= @Program_End)
				OR
				Program_Distributors_Trade.Operator_Distributor = 1 -- Do not check for date overlap for operator TPA in distributor programs
			   )
	<cfif OperatorTPAInOperatorProgram EQ 1>
	AND		EXISTS (
				SELECT	1
				FROM	Contract_Operators co
				INNER JOIN ##Tmp_Operators currpgm
				ON		currpgm.BSA_Operator_ID = co.BSA_Operator_ID
				WHERE	co.Contract_Main_ID = Program_Distributors_Trade.Contract_Main_ID
				AND		co.Deleted = 0
				AND		co.Is_Group = 0
		)
	</cfif>

	<cfif WeightTPABasedOnDate>
		IF @Program_Span != 0
		BEGIN
			UPDATE	##Tmp_TPA_Initial
			SET		Rate = 	Rate
							* CASE WHEN Overlap_Start IS NOT NULL AND Overlap_End IS NOT NULL THEN CAST(dateDiff(d, Overlap_Start, Overlap_End) + 1 as decimal(20, 4)) ELSE 0 END
							/ @Program_Span,
					Rate_Percent_On_Fixed_Price = 	Rate_Percent_On_Fixed_Price
							* CASE WHEN Overlap_Start IS NOT NULL AND Overlap_End IS NOT NULL THEN CAST(dateDiff(d, Overlap_Start, Overlap_End) + 1 as decimal(20, 4)) ELSE 0 END
							/ @Program_Span
		END
	</cfif>

	INSERT INTO ##Tmp_TPA (BSA_Foodservice_Customers_ID, BSA_Foodservice_Items_Master_ID, Rate, Annualized_Rate)
	SELECT		Program_Distributors_Trade.BSA_Foodservice_Customers_ID, Program_Distributors_Trade.BSA_Foodservice_Items_Master_ID,
				SUM(cast(cast(Rate as float) as decimal(30,10)))
				+ ISNULL(SUM(ISNULL(Rate_Percent_On_Fixed_Price, 0) / 100.00) * #productPrice#, 0)
				 as Rate,
				 SUM(cast(cast(Rate as float) * ((CAST(DateDiff(d, Program_Distributors_Trade.Contract_Start_Date, Program_Distributors_Trade.Contract_End_Date) as float) + 1) / 365.00) as decimal(30,10)))
				+ ISNULL(SUM((ISNULL(Rate_Percent_On_Fixed_Price, 0) * ((CAST(DateDiff(d, Program_Distributors_Trade.Contract_Start_Date, Program_Distributors_Trade.Contract_End_Date) as float) + 1) / 365.00)) / 100.00)  * #productPrice#, 0)
				 as Annualized_Rate
	FROM	##Tmp_TPA_Initial Program_Distributors_Trade
	GROUP BY Program_Distributors_Trade.BSA_Foodservice_Customers_ID, Program_Distributors_Trade.BSA_Foodservice_Items_Master_ID


	-- Get the final result of TPA per customer
	SELECT		DISTINCT
				ISNULL(Tmp_TPA.RATE, 0) as rate,
				ISNULL(Tmp_TPA.Annualized_Rate, 0) as Annualized_Rate,
				cfc.Ship_To,
				cfc.Name,
				cfc.City,
				cfc.State,
				cfc.Program_Weight,
				cfi.UPC,
				cfi.Description,
				cfi.BSA_Foodservice_Items_Master_ID,
				cfi.net_weight,
				cfi.CASE_EQUIVALENT,
				cfc.BSA_Foodservice_Customers_ID,
				 (cast(ISNULL(cast(
				 <cfif appSettings.getApprovalMarginType() eq 2>Tmp_TPA.Annualized_Rate<cfelse>Tmp_TPA.Rate</cfif>
				  as float),0) as decimal(30,10))
				 * CAST(cfc.Program_Weight AS FLOAT)/100) AS WTPR,
				 0 As Min_Search_Sequence_Number
	FROM		BSA_Foodservice_Items_Master cfi
	LEFT JOIN 	##Tmp_Distributors cfc
	ON			1=1
	LEFT JOIN 	##Tmp_TPA Tmp_TPA
	ON			Tmp_TPA.BSA_Foodservice_Customers_ID = cfc.BSA_Foodservice_Customers_ID
	AND			Tmp_TPA.BSA_Foodservice_Items_Master_ID = cfi.BSA_Foodservice_Items_Master_ID
	WHERE		cfi.BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'
	<cfif url.sortBy eq variables.sold_to>
		ORDER BY cfc.Ship_To <cfif url.sortOrder eq variables.descending> desc </cfif>
	<cfelseif url.sortBy eq variables.name>
		ORDER BY cfc.Name <cfif url.sortOrder eq variables.descending> desc </cfif>
	</cfif>
	</CFQUERY>

</cfif>

</cfif>


<!------<CFDUMP VAR="#getThisProductsDistCombos#">----->

<CFSET PreTPAList = ValueList(getThisProductsDistCombos.WTPR)>
<CFSET listOfUsedIDS = "">

<CFSET PreTPAArray = ListToArray(PreTPAList)>
<cfif type EQ "CS">
	<cfif url.margin_type EQ 2>
		<cfset STAT_MULTIPLIER = getThisProductsDistCombos.CASE_EQUIVALENT>
	<cfelse>
		<CFSET STAT_MULTIPLIER = 1>
	</cfif>
		<CFSET FinalTPASum = Val(ArraySum(PreTPAArray)) * Val(getThisProductsDistCombos.Net_Weight) * STAT_MULTIPLIER>
<cfelse>
	<CFSET FinalTPASum = ArraySum(PreTPAArray)>
</cfif>


<BLOCKQUOTE>
<!------<CFOUTPUT>#FinalTPASum#</CFOUTPUT>----->
<CFIF getThisProductsDistCombos.recordCount GT 0>
<BR><BR>
<DIV CLASS="TITLE2" STYLE="float: left;"><CFOUTPUT>#displayName#</CFOUTPUT> Calculation</DIV>
<cfif WeightTPABasedOnDate><DIV CLASS="TITLE2" ALIGN="RIGHT" STYLE="color:red;">Weight % is based on number of overlapping days</DIV></cfif>
<HR COLOR="Orange">
<CFOUTPUT QUERY="Program_Details">
<TABLE border="0" WIDTH="90%">
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B><cfif PlannerID eq 0>Program<cfelse>#Application.PlannerLabel#</cfif>:</B>&nbsp;&nbsp;[#Contract_Number#]</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Center"><B>Start Date:</B>&nbsp;&nbsp;#DateFormat(Contract_Start_Date,"mm/dd/yyyy")#</TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;" ALIGN="Right"><B>End Date:</B>&nbsp;&nbsp;#DateFormat(Contract_End_Date,"mm/dd/yyyy")#&nbsp;&nbsp;</TD>
	</TR>
</TABLE>
<HR COLOR="Orange">
<div style="font-weight:bold;">click here to <a onclick="toggleAllToSameStatus('inline')" style="cursor:pointer;">#application.util.string.actionLinkFormat2("show")#</a> or
	<a onclick="toggleAllToSameStatus('none')" style="cursor:pointer;">#application.util.string.actionLinkFormat2("hide")#</a> the product rate breakdowns</div>
</CFOUTPUT>
<br>
<cfinclude template="\includes\search_on_page.cfm">
<CFOUTPUT QUERY="getThisProductsDistCombos" GROUP="UPC">
<TABLE BORDER="0">
	<TR>
		<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;"><B>PRODUCT:</B></TD>
		<TD STYLE="border-bottom: 0px; font-size: 12px;" ALIGN="right"><B><cfif application.returned_customer_setting.upc_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.upc_switch EQ 1>#getThisProductsDistCombos.UPC# - </cfif></cfif>#getThisProductsDistCombos.Description#</B></TD>
	</TR>
</TABLE>


<TABLE CLASS="Maintable" WIDTH="90%" CELLPADDING="3" CELLSPACING="0" ALIGN="center" border="0">
		<TR BGCOLOR="##FFCE84" VALIGN="top">
			<td>&nbsp;</td>
			<cfset variables.sortURL = 'sortBy=sold_to&sortOrder=' & (url.sortBy neq variables.sold_to or url.sortOrder eq variables.descending ? 'asc' : variables.descending)>
			<TD class="header" NOWRAP WIDTH="75"><a href="#variables.reloadHref#&#variables.sortURL#"><B>#application.returned_customer_setting.shard_ship_to_label#</B></a>
				<cfif url.sortBy neq variables.sold_to>
					<img src="/images/sort.gif">
				<cfelseif url.sortOrder eq variables.ascending>
					<img src="/images/sort_asc.gif">
				<cfelse>
					<img src="/images/sort_desc.gif">
				</cfif>
				</TD>
			<cfset variables.sortURL = 'sortBy=name&sortOrder=' & (url.sortBy neq variables.name or url.sortOrder eq variables.descending ? 'asc' : variables.descending)>
			<TD class="header" WIDTH="100%"><a href="#variables.reloadHref#&#variables.sortURL#"><B>Name</B></a>
				<cfif url.sortBy neq variables.name>
					<img src="/images/sort.gif">
				<cfelseif url.sortOrder eq variables.ascending>
					<img src="/images/sort_asc.gif">
				<cfelse>
					<img src="/images/sort_desc.gif">
				</cfif>
			</TD>
			<TD class="header" ALIGN="left" NOWRAP>
				<B>Rate</B>
				<CF_SmallHelp
					imgPath="/Images/i.gif"
					displayShifyX = "-300"
					imgWidth="12"
					imgHeight="11"
					dropdownCheck="0"
					width="90%"
					>
				<!--- On IE 10, we have added "wid = wid + ' px'" on "smallHelp.cfm". That code change works in many places but not here. So, that we can see the entire hint on mouseover,
				I have added a couple of extra <br /> below.
				--->
				<center>#displayName# is calculated with a greater <br />precision than the display. <br />The actual resolved value may be <br />more finite than the value displayed.</center>
				</CF_SmallHelp>
			</TD>
			<cfif appSettings.getApprovalMarginType() eq 2>
			<TD class="header" ALIGN="left">
			<B>Annualized <BR>Rate</B>
			</TD>
			</cfif>
			<TD class="header">&nbsp;</TD>
			<TD class="header" ALIGN="CENTER"><B>Weight</B></TD>
			<TD class="header">&nbsp;</TD>
			<TD class="header" ALIGN="Left"><B>Weighted <BR>Rate</B></TD>
		</TR>

		<CFOUTPUT>
		<CFIF Ship_To NEQ "">

		<CFSET thisRandomID = replace(createuuid(), "-", "_", "ALL")>
		<CFSET FoundUniqueID = 0>
		<cfloop condition="FoundUniqueID EQ 0">
			<CFIF listfind(listOfUsedIDS,thisRandomID) EQ 0>
				<CFSET listOfUsedIDS = listappend(listOfUsedIDS,thisRandomID)>
				<CFSET FoundUniqueID = 1>
			<CFELSE>
				<CFSET thisRandomID = replace(createuuid(), "-", "_", "ALL")>
			</CFIF>
		</CFLOOP>

		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<td>&nbsp;</td>
			<TD>#Ship_To#</TD>
			<TD>#Name# (#City#, #State#)</TD>
			<TD ALIGN="right">
			<cfif type EQ "CS">
				<cfset item_rate = (Rate)* Net_Weight * STAT_MULTIPLIER>
			<cfelse>
				<cfset item_rate = Rate>
			</cfif>

			<CFSET data = trim(numberformat(item_rate,"___,___,___,___,___,___,___,___.____"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			#data#
			</TD>
			<cfif appSettings.getApprovalMarginType() eq 2>
			<TD ALIGN="right">
			<cfif type EQ "CS">
				<cfset data = (Annualized_Rate)* Net_Weight * STAT_MULTIPLIER>
			<cfelse>
				<cfset data = Annualized_Rate>
			</cfif>

			<CFSET data = trim(numberformat(data,"___,___,___,___,___,___,___,___.____"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			#data#
			</TD>
			</cfif>
			<TD ALIGN="CENTER">*</TD>
			<TD ALIGN="CENTER">#Program_Weight#%</TD>
			<TD ALIGN="CENTER">=</TD>
			<TD ALIGN="CENTER">
			<cfif type EQ "CS">

				<CFSET wtpr_rate = WTPR * Net_Weight * STAT_MULTIPLIER>
			<cfelse>
				<CFSET wtpr_rate = WTPR>
			</cfif>
			 <cfset data = trim(numberformat(wtpr_rate,"___,___,___,___,___,___,___,___.____"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			#data#
			</TD>
		</TR>
		<!--- Program_Distributors_Trade.Rate less than .0001 becomes 0, as we only consider values upto 4 decimal places --->
		<cfquery name="getRates" datasource="#Application.Datasource#">
			SELECT     	Contract_Main.Contract_Title, Program_Distributors_Trade.Contract_Start_Date, Program_Distributors_Trade.Contract_End_Date, Contract_Main.Contract_Main_ID,
						cast(cast((Program_Distributors_Trade.Rate) as float) AS Decimal (30,10))
						+ ISNULL((ISNULL(Rate_Percent_On_Fixed_Price, 0) / 100.00) * #productPrice#, 0)
						 AS RATE,
						 cast(cast((Program_Distributors_Trade.Rate) as float) * ((CAST(DateDiff(d, Program_Distributors_Trade.Contract_Start_Date, Program_Distributors_Trade.Contract_End_Date) as float) + 1) / 365.00) AS Decimal (30,10))
						+ ISNULL(((ISNULL(Rate_Percent_On_Fixed_Price, 0) * ((CAST(DateDiff(d, Program_Distributors_Trade.Contract_Start_Date, Program_Distributors_Trade.Contract_End_Date) as float) + 1) / 365.00)) / 100.00) * #productPrice#, 0)
						 AS Annualized_Rate,
						Contract_Main.Contract_Number
			FROM		##Tmp_TPA_Initial Program_Distributors_Trade
			INNER JOIN	Contract_Main
			ON 			Program_Distributors_Trade.Contract_Main_ID = Contract_Main.Contract_Main_ID
			WHERE     	Program_Distributors_Trade.BSA_Foodservice_Items_Master_ID = '#getThisProductsDistCombos.BSA_Foodservice_Items_Master_ID#'
			AND			Program_Distributors_Trade.BSA_Foodservice_Customers_ID = '#getThisProductsDistCombos.BSA_Foodservice_Customers_ID#'
			Order By Contract_Main.Contract_Number, Program_Distributors_Trade.Contract_Start_Date
		</cfquery>
		<TR class="hidden">
			<TD height="4">&nbsp;</TD>
			<TD height="4">&nbsp;</TD>
			<TD height="4">&nbsp;</TD>
			<TD height="4">&nbsp;</TD>
			<cfif appSettings.getApprovalMarginType() eq 2>
				<TD height="4">&nbsp;</TD>
			</cfif>
		</TR>
		<TR class="hidden" valign="top">
			<TD style="border-bottom: 0px;">&nbsp;</TD>
			<TD nowrap bgcolor="##000080" style="color:white;">Contract ##</TD>
			<TD bgcolor="##000080" style="color:white;">Title</TD>
			<TD bgcolor="##000080" style="color:white;">Rate</TD>
			<cfif appSettings.getApprovalMarginType() eq 2>
			<TD bgcolor="##000080" style="color:white;">Annualized<br>Rate</TD>
			</cfif>
		</TR>
		<CFLOOP query="getRates">
		<!--- Get the program label names from the template. One program may have multiple label names --->
		<cfquery name="ProgramLabelNames" datasource="#Application.Datasource#">
			SELECT Accounting_Program_Type.APT_Name
			FROM Contract_Main LEFT JOIN APT_Template_Mapping
			ON APT_Template_Mapping.Template_ID = Contract_Main.ProgramType_ID
			LEFT JOIN Accounting_Program_Type
			ON Accounting_Program_Type.Accounting_Program_Type_ID = APT_Template_Mapping.Accounting_Program_Type_ID
			WHERE Contract_Main.Contract_Main_ID = '#getRates.Contract_Main_ID#'
		</cfquery>
		<cfset APT_Name = ValueList(ProgramLabelNames.APT_Name)>
		<TR class="hidden">
			<TD style="border-bottom: 0px;">&nbsp;</TD>
			<TD nowrap>#getRates.Contract_Number#</TD>
			<!--- APT_Name is "program label" from the template --->
			<TD>
			#getRates.Contract_Title#<cfif APT_Name neq "">&nbsp;(#APT_Name#)</cfif>
			<br>(#DateFormat(Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(Contract_End_Date, "mm/dd/yyyy")#)
			</TD>
			<cfif type EQ "CS">
				<CFSET item_rate = val(getRates.Rate) * val(getThisProductsDistCombos.Net_Weight) * val(STAT_MULTIPLIER)>
			<cfelse>
				<CFSET item_rate = getRates.Rate>
			</cfif>
			<CFIF item_rate LT 0>
				<cfset data = item_rate * -1 />
				<cfset data = trim(numberformat(data,"___,___,___,___,___,___,___,___.____"))>
				<CFSET data = "[$#data#]">
			<CFELSE>
				<cfset data = trim(numberformat(item_rate,"___,___,___,___,___,___,___,___.____"))>
				<CFSET data = "$#data#">
			</CFIF>
			<TD>#data#</TD>
			<!--- Annualized rate --->
			<cfif appSettings.getApprovalMarginType() eq 2>
			<cfif type EQ "CS">
				<CFSET data = val(getRates.Annualized_Rate) * val(getThisProductsDistCombos.Net_Weight) * val(STAT_MULTIPLIER)>
			<cfelse>
				<CFSET data = getRates.Annualized_Rate>
			</cfif>
			<CFIF data LT 0>
				<cfset data = item_rate * -1 />
				<cfset data = trim(numberformat(data,"___,___,___,___,___,___,___,___.____"))>
				<CFSET data = "[$#data#]">
			<CFELSE>
				<cfset data = trim(numberformat(data,"___,___,___,___,___,___,___,___.____"))>
				<CFSET data = "$#data#">
			</CFIF>
			<TD>#data#</TD>
			</cfif>
		</TR>
		</CFLOOP>
		<TR class="hidden">
			<TD height="4">&nbsp;</TD>
			<TD height="4">&nbsp;</TD>
			<TD height="4">&nbsp;</TD>
			<TD height="4">&nbsp;</TD>
			<cfif appSettings.getApprovalMarginType() eq 2>
				<TD height="4">&nbsp;</TD>
			</cfif>
		</TR>
		</CFIF>
		</CFOUTPUT>
		<TR ALIGN="CENTER">
			<TD COLSPAN=7 ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>#displayName# / #type# (&##931; Weighted Rate) = </B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(FinalTPASum,"___,___,___,___,___,___,___,___.____"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
		</TR>
		<cfif type EQ "CS">
			<cfset FinalTPASum = FinalTPASum / getThisProductsDistCombos.Net_Weight>
		<cfelse>
			<cfset FinalTPASum = FinalTPASum * getThisProductsDistCombos.Net_Weight>
		</cfif>
		<TR ALIGN="CENTER">
			<TD COLSPAN=7 ALIGN=RIGHT STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<B>#displayName# / <cfif type EQ "CS">LB<cfelse>CS</cfif></B>
			</TD>
			<TD STYLE="border-bottom: 0px; font-size: 12px; color: NAVY;">
			<CFSET data = trim(numberformat(FinalTPASum,"___,___,___,___,___,___,___,___.____"))>
			<CFIF data LT 0><CFSET data = "<SPAN STYLE=""color: red;""><b>[$#data#]</b></SPAN>"><CFELSE><CFSET data = "<SPAN STYLE=""color: blue;""><B>$#data#</B></SPAN>"></CFIF>
			<B>#data#</B>
			</TD>
		</TR>
</TABLE>
</CFOUTPUT>
</CFIF>
<HR color ="orange">
<BR><BR>
<DIV ALIGN="center">
		<CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"parent.dhx_window_close ? parent.dhx_window_close() : window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</DIV>
		<BR><BR>
</BLOCKQUOTE>

<cf_include files="/common_files/jQuery.cfm">
<script>
	function toggleAllToSameStatus(status) {
		if (status == "none")
			$("tr.hidden").hide();
		else
			$("tr.hidden").show();
	}
</script>

<cfquery name="DropTempTables" datasource="#Application.Datasource#">
	IF OBJECT_ID('tempdb..##Tmp_Distributors') IS NOT NULL
	DROP TABLE ##Tmp_Distributors

	IF OBJECT_ID('tempdb..##Tmp_TPA') IS NOT NULL
	DROP TABLE ##Tmp_TPA
</cfquery>

<cfinclude template="/common_files/focus.cfm">
</BODY>
</HTML>