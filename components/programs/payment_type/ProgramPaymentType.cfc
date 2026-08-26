<!--- ProgramPaymentType.cfc - Copyright (c) 2004 Blacksmith Applications, Inc. --->
<!---
	Created By:		Tim Ford
	Created Date:	01/20/2005
--->

<cfcomponent hint="Payment Type is also known as Claim Mechanic">

	<cffunction access="public" name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<!---get the payment types for this program--->
	<cffunction name="getProgramPaymentTypes" output="false" returntype="query">
		<cfargument name="programId" required="true" default="" />
		
		<cfquery name="qGetPaymentTypes" datasource="#application.datasource#">
			SELECT	Payment_Type.Payment_Type_Name
			FROM	Contract_Main
					INNER JOIN Payment_Type ON
					Payment_Type.Payment_Type_ID = Contract_Main.ClaimMechanics
					AND Payment_Type.Deleted = 0
			WHERE	Contract_Main.Contract_Main_ID = #arguments.programId#
		</cfquery>
		
		<cfreturn qGetPaymentTypes />
	</cffunction>


	<!--- This query is used to determine whether the Claim Rates Report and/or Pricing Reports be included 
		  for the program.
	---> 
	<cffunction name="getShowProgramReportStatus" output="false" returntype="query">
		<cfargument name="programId" required="true" type="numeric" />
		
		<cfquery name="qGetShowProgramReportStatus" datasource="#application.datasource#">
			SELECT Payment_Type.Include_Claim_Rates_Report,Payment_Type.Include_Pricing_Report,
			Program_Fixed_Component.fixed_component_paid_to As component_paid_to
			FROM Program_Fixed_Component
			INNER JOIN Payment_Type
			ON Program_Fixed_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
			WHERE Program_Fixed_Component.Program_ID = '#arguments.programId#'
			AND Program_Fixed_Component.deleted = 0

			UNION

			SELECT Payment_Type.Include_Claim_Rates_Report,Payment_Type.Include_Pricing_Report,
			Program_Rebates_Component.component_paid_to
			FROM Program_Rebates_Component
			INNER JOIN Payment_Type
			ON Program_Rebates_Component.Claim_Mechanics = Payment_Type.Payment_Type_ID
			WHERE Program_Rebates_Component.Program_ID = '#arguments.programId#'
			AND Program_Rebates_Component.deleted = 0
		</cfquery>

		<cfreturn qGetShowProgramReportStatus />
	</cffunction>

	<!---get program id's based on billback--->
	<cffunction name="getBillbackProgramPaymentTypes" output="false" returntype="query">
		<cfargument name="billbackId" required="true" default="" />
		<cfquery name="qGetProgramBillbacks" datasource="#application.datasource#">
			SELECT 	distinct
					Payment_Type.Payment_Type_Name,
					Billback_Program.Billback_ID,
					billback_program.billback_program_id,	
					Contract_Main.Contract_Main_ID,
					contract_main.contract_number,
					contract_main.contract_title,
					Contract_Main.ClaimMechanics
			FROM 	Billback_Program
					INNER JOIN Contract_Main
					ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
					INNER JOIN Payment_Type ON
					Payment_Type.Payment_Type_ID = Contract_Main.ClaimMechanics
			WHERE 	Billback_Program.Billback_ID = '#arguments.billbackId#'
			AND 	Billback_Program.Deleted = 0
			order by 2,3
		</cfquery>
		<cfreturn qGetProgramBillbacks />
	</cffunction>
	
</cfcomponent>