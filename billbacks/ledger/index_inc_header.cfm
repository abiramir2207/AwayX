<cfif isDefined("URL.ShowDetails")>
	<cfset ShowDetails = Url.ShowDetails>
</cfif>

<!---Sets the basic variables from the form--->
<CFPARAM name="FORM.FinalDistributorList"	default="0">
<CFPARAM name="FORM.FinalProgramList"		default="0">
<CFPARAM name="Start_Date"					default="">
<CFPARAM name="End_Date" 					default="">
<CFPARAM name="UOM"							default="">
<CFPARAM name="LumpsumCredit"				default="0">
<CFPARAM name="LumpsumDebit"				default="0">
<CFPARAM name="LumpsumTotal"				default="0">
<CFPARAM name="RebateCredit"				default="0">
<CFPARAM name="RebateDebit"					default="0">
<CFPARAM name="TotalRebate"					default="0">
<CFPARAM name="FixedPriceCredit"			default="0">
<CFPARAM name="FixedPriceDebit"				default="0">
<CFPARAM name="FixedPriceTotal"				default="0">
<CFPARAM name="FormulaPriceCredit"			default="0">
<CFPARAM name="FormulaPriceDebit"			default="0">
<CFPARAM name="FormulaPriceTotal"			default="0">
<CFPARAM name="GrowthCredit"				default="0">
<CFPARAM name="GrowthDebit"					default="0">
<CFPARAM name="TotalGrowth"					default="0">


<!---Select preferences from Billback Settings--->
<cfset useLakebaseForBB_Preferences = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForBB_Preferences>
	<cftry>
		<cfset BB_Preferences = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "bb_tolerance_tet"
			}), "bb_tolerance_tet"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForBB_Preferences = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForBB_Preferences>
<cfquery name="BB_Preferences" datasource="#application.datasource#">
	SELECT BB_Tolerance_TET
	FROM Billback_Settings
</cfquery>
</cfif>

<cfset BB_Tolerance_TET = BB_Preferences.BB_Tolerance_TET>

<cfset ContractID=FinalProgramList>
<cfset DistributorNumber=FinalDistributorList>

<!---Gets program dates--->

<cfquery name="PopulateBBTables" datasource="#application.datasource#">
exec BB_D_Program_Detail
@@A_ID = '#ContractID#'
</cfquery>

<!---Gets user friendly names--->
<cfset useLakebaseForGetDistributorName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetDistributorName>
	<cftry>
		<cfset GetDistributorName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#DistributorNumber#",
				"select" = "name"
			}), "name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistributorName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributorName>
<cfquery name="GetDistributorName" datasource="#application.datasource#">
SELECT Name 
FROM BSA_Foodservice_Customers 
WHERE BSA_Foodservice_Customers_ID = '#DistributorNumber#'
</cfquery>
</cfif>

<!---Gets program number--->
<cfquery name="GetProgramNumber" datasource="#application.datasource#">
SELECT Contract_Main.Contract_Quantity_UOM_IDX, Contract_Main.Contract_Title, Contract_Main.Contract_Number, Contract_Main.ClaimMechanics, Contract_Status_Types.Contract_Status_Type_Desc
FROM Contract_Main
	INNER JOIN Contract_Status_Types
	ON
	Contract_Status_Types.Contract_Status_Type_ID = Contract_Main.Contract_Status_Type_IDX
WHERE Contract_Main_ID = #ContractID#
</cfquery>

<cfset useLakebaseForGetProgramNumbers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_main")>
<cfif useLakebaseForGetProgramNumbers>
	<cftry>
		<cfset GetProgramNumbers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("contract_main", {
				"contract_number" = "eq.#GetProgramNumber.Contract_Number#",
				"select" = "contract_main_id"
			}), "contract_main_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetProgramNumbers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetProgramNumbers>
<cfquery name="GetProgramNumbers" datasource="#application.datasource#">
SELECT Contract_Main_ID
FROM Contract_Main
WHERE Contract_Number = '#GetProgramNumber.Contract_Number#'
</cfquery>
</cfif>

<cfset ProgramNumber = listqualify(valuelist(GetProgramNumbers.Contract_Main_ID), chr(39))>

<cfquery name="GetProgramDates" datasource="#application.datasource#">
SELECT Min(Approval_start_Date) as Start_Date, Max(Approval_End_Date) as End_Date
FROM BB_Program_Info
WHERE Contract_Number = '#GetProgramNumber.Contract_Number#'
</cfquery>

<!---Sets program variables--->
<cfset DistributorName = GetDistributorName.Name>
<cfset ProgramName = GetProgramNumber.Contract_Title>
<cfset StartDate = GetProgramDates.Start_Date>
<cfset EndDate = GetProgramDates.End_Date>
<cfset UOM = GetProgramNumber.Contract_Quantity_UOM_IDX>


