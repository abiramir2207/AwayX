<cffunction name="GetContractInfo" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
<CFQUERY NAME="qGetContractInfo" datasource="#application.datasource#">
	SELECT Program_Control_Panel_Options.Created_Type, Contract_Main.*, dbo.Program_Control_Panel_Options.Generic_Type
	FROM Contract_Main
		INNER JOIN	Program_Control_Panel_Options
		ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
	WHERE Contract_Main_ID = '#arguments.program_id#'
	AND Contract_Main.Deleted = 0
</CFQUERY>
<cfreturn qGetContractInfo />
</cffunction>

<cffunction name="GetTemplateSettings" access="public" returntype="query">
	<cfargument name="programtype_id" type="string" required="true" />
<cfquery name="qGetTemplateSettings" datasource="#application.datasource#">
	SELECT *
	FROM 
		Program_Control_Panel_Options
	WHERE 
		ProgramControl_Panel_Options_ID = '#trim(arguments.programtype_id)#'
</cfquery>
<cfreturn qGetTemplateSettings />
</cffunction>

<cffunction name="GetLumpSumAmount" access="public" returntype="query">
	<cfargument name="program_id" type="string" required="true" />
		<CFQUERY name="qGetLumpSumAmount" datasource="#application.datasource#">
		select ISNULL(sum(ISNULL(cast(Lump_Sum_Amount as float),0)),0) as TotalLumpsumAmount
		from Program_Lump_Sums
		where program_id = '#arguments.program_id#'
		and deleted = 0
		</CFQUERY>
	<cfreturn qGetLumpSumAmount />
</cffunction>


<cffunction name="GetFixedAmount" access="public" returntype="query">
	<cfargument name="parentprogram_id" type="string" required="true" />
	<cfargument name="currentprogram_id" type="string" required="true" />
		<CFQUERY name="qGetFixedAmount" datasource="#application.datasource#">
		SELECT  distinct   BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,

(
SELECT
ISNULL(AVG(
		CASE
		WHEN F1.Unit_Of_Measure_ID = 2 THEN
		cast(F1.Fixed_Price_Value as float)
		WHEN F1.Unit_Of_Measure_ID = 1 THEN
	(cast(F1.Fixed_Price_Value as float) / cast(P1.Net_Weight as float))
END
),0) 
 
FROM	contract_products CP1
	INNER JOIN Program_Fixed_Price_Product_Data F1
	ON 
	F1.Deleted = 0
	AND F1.program_id = CP1.Contract_Main_ID
	AND CP1.contract_products_ID = F1.contract_products_ID	
	INNER JOIN BSA_Foodservice_Items_Master P1
	ON
	P1.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
WHERE
	CP1.Deleted = 0
	AND CP1.BSA_Foodservice_Items_Master_Id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
	AND (CP1.Contract_Main_ID = contract_products.Contract_Main_ID)
) as CurrentProgramFixedPrice,

(
SELECT
ISNULL(AVG(
		CASE
		WHEN F2.Unit_Of_Measure_ID = 2 THEN
		cast(F2.Fixed_Price_Value as float)
		WHEN F2.Unit_Of_Measure_ID = 1 THEN
	(cast(F2.Fixed_Price_Value as float) / cast(P2.Net_Weight as float))
END
),0) 

FROM	contract_products CP2
	INNER JOIN Program_Fixed_Price_Product_Data F2
	ON 
	F2.Deleted = 0
	AND F2.program_id = CP2.Contract_Main_ID
	AND CP2.contract_products_ID = F2.contract_products_ID
	INNER JOIN BSA_Foodservice_Items_Master P2
	ON
	P2.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
WHERE
	CP2.Deleted = 0
	AND CP2.BSA_Foodservice_Items_Master_Id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
	AND (CP2.Contract_Main_ID = '#arguments.parentprogram_id#')
) as ParentProgramFixedPrice

FROM         dbo.Program_Fixed_Price_Product_Data
INNER JOIN contract_products ON Program_Fixed_Price_Product_Data.program_id = contract_products.Contract_Main_ID
	AND contract_products.contract_products_ID = Program_Fixed_Price_Product_Data.contract_products_ID
INNER JOIN BSA_Foodservice_Items_Master ON
contract_products.BSA_Foodservice_Items_Master_Id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
AND BSA_Foodservice_Items_Master.deleted = 0
WHERE     (Program_Fixed_Price_Product_Data.Deleted = 0) 
AND (contract_products.Contract_Main_ID = '#arguments.currentprogram_id#')
and contract_products.deleted = 0

		</CFQUERY>
	<cfreturn qGetFixedAmount />
</cffunction>

<cffunction name="GetRebateAmount" access="public" returntype="query">
	<cfargument name="parentprogram_id" type="string" required="true" />
	<cfargument name="currentprogram_id" type="string" required="true" />
		<CFQUERY name="qGetRebateAmount" datasource="#application.datasource#">
SELECT   distinct  BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id,
(
SELECT
ISNULL(SUM(
		CASE
		WHEN R1.Unit_Of_Measure_ID = 2 THEN
		cast(R1.Rate as float)
		WHEN R1.Unit_Of_Measure_ID = 1 THEN
	(cast(R1.Rate as float) / cast(P1.Net_Weight as float))
END
) ,0) 
FROM	contract_products CP1
	INNER JOIN
        dbo.Program_Rebates_Product_Data  RP1 ON
	CP1.contract_products_ID = RP1.contract_products_ID
	AND CP1.contract_main_ID = RP1.program_ID
	AND RP1.deleted = 0
	 INNER JOIN
        dbo.Program_Rebates_Component_Data R1 ON 
        R1.Program_Rebates_Product_Data_ID = RP1.Program_Rebates_Product_Data_ID
	AND 
	R1.Deleted = 0
	INNER JOIN BSA_Foodservice_Items_Master P1
	ON
	P1.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
WHERE
	CP1.Deleted = 0
	AND CP1.BSA_Foodservice_Items_Master_Id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
	AND (CP1.Contract_Main_ID = contract_products.Contract_Main_ID)
) as CurrentProgramRebatePrice,
(
SELECT
ISNULL(SUM(
		CASE
		WHEN R2.Unit_Of_Measure_ID = 2 THEN
		cast(R2.rate as float)
		WHEN R2.Unit_Of_Measure_ID = 1 THEN
	(cast(R2.rate as float) / cast(P2.Net_Weight as float))
END
),0)

FROM	contract_products CP2
	INNER JOIN
        dbo.Program_Rebates_Product_Data  RP2 ON
	CP2.contract_products_ID = RP2.contract_products_ID
	AND CP2.contract_main_ID = RP2.program_ID
	AND RP2.deleted = 0
	 INNER JOIN
        dbo.Program_Rebates_Component_Data R2 ON 
        R2.Program_Rebates_Product_Data_ID = RP2.Program_Rebates_Product_Data_ID
	AND 
	R2.Deleted = 0
	INNER JOIN BSA_Foodservice_Items_Master P2
	ON
	P2.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
WHERE
	CP2.Deleted = 0
	AND CP2.BSA_Foodservice_Items_Master_Id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
	AND (CP2.Contract_Main_ID = '#arguments.parentprogram_id#')
) as ParentProgramRebatePrice

FROM         dbo.Program_Rebates_Product_Data
INNER JOIN contract_products ON Program_Rebates_Product_Data.program_id = contract_products.Contract_Main_ID
	AND contract_products.contract_products_ID = Program_Rebates_Product_Data.contract_products_ID
INNER JOIN Program_Rebates_Component_Data ON
Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
INNER JOIN BSA_Foodservice_Items_Master ON
contract_products.BSA_Foodservice_Items_Master_Id = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_Id
AND BSA_Foodservice_Items_Master.deleted = 0
WHERE     (Program_Rebates_Product_Data.Deleted = 0) 
AND (contract_products.Contract_Main_ID = '#arguments.currentprogram_id#')
and contract_products.deleted = 0
AND Program_Rebates_Product_Data.deleted = 0
AND Program_Rebates_Component_Data.deleted = 0
	</CFQUERY>
	<cfreturn qGetRebateAmount />
</cffunction>