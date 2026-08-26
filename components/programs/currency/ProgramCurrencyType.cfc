<!--- ProgramCurrencyType.cfc - Copyright (c) 2004 Blacksmith Applications, Inc. --->
<!---
	Created By:		Tim Ford
	Created Date:	01/20/2005
--->

<cfcomponent>

	<cffunction access="public" name="init" output="false">

		<cfreturn this />

	</cffunction>

	<!---get the payment types for this program--->
	<cffunction name="getProgramCurrencies" output="false" returntype="query">
		<cfargument name="programId" required="true" default="" />

		<cfquery name="qGetCurrencies" datasource="#application.datasource#">
			SELECT	Currency.Currency_Name, Currency.Currency_Code
			FROM	Contract_Main
					INNER JOIN Currency ON
					Currency.Currency_ID = Contract_Main.Currency
					AND Currency.Deleted = 0
			WHERE	Contract_Main.Contract_Main_ID = #arguments.programId#
		</cfquery>

		<cfreturn qGetCurrencies />
	</cffunction>

	<!---get program id's based on billback--->
	<cffunction name="getBillbackProgramCurrencies" output="false" returntype="query">
		<cfargument name="billbackId" required="true" default="" />
		<cfquery name="qGetProgramBillbacks" datasource="#application.datasource#">
			SELECT 	distinct
					Currency.Currency_Name,
					Billback_Program.Billback_ID,
					billback_program.billback_program_id,
					Contract_Main.Contract_Main_ID,
					contract_main.contract_number,
					contract_main.contract_title,
					Contract_Main.ClaimMechanics
			FROM 	Billback_Program
					INNER JOIN Contract_Main
					ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
					INNER JOIN Currency ON
					Currency.Currency_ID = Contract_Main.ClaimMechanics
			WHERE 	Billback_Program.Billback_ID = '#arguments.billbackId#'
			AND 	Billback_Program.Deleted = 0
			order by 2,3
		</cfquery>
		<cfreturn qGetProgramBillbacks />
	</cffunction>

</cfcomponent>