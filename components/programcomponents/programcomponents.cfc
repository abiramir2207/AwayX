<cfcomponent output="false">

	<cffunction name="GetComponentDetails" output="true" returntype="query">
		<cfargument name="Component_Name_ID" required="true">
		<cfargument name="Discount_Type_ID"  required="false" default="">

		<cfswitch expression="#arguments.Discount_Type_ID#">
		<!--- Fixed Price --->
			<cfcase value="1">
				<cfset useLakebaseForqCompDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_fixed_component_name")>
<cfif useLakebaseForqCompDetails>
	<cftry>
		<cfset qCompDetails = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_fixed_component_name", {
				"program_fixed_component_name_id" = "eq.#arguments.Component_Name_ID#",
				"select" = "program_fixed_component_name_id as component_name_id,program_fixed_component_name as component_name,external_id,fixed_component_type as component_type,accrual_on,exclude_brokerage,off_invoice_on,floor_pricing_on,0 as rebate_type"
			}), "program_fixed_component_name_id as component_name_id,program_fixed_component_name as component_name,external_id,fixed_component_type as component_type,accrual_on,exclude_brokerage,off_invoice_on,floor_pricing_on,0 as rebate_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCompDetails = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCompDetails>
<cfquery name="qCompDetails" datasource="#application.datasource#">
				SELECT 	Program_Fixed_Component_Name_ID AS Component_Name_ID,
						Program_Fixed_Component_Name AS Component_Name,
						External_ID,
						Fixed_Component_Type AS Component_Type,
						Accrual_On,
						Exclude_Brokerage,
						Off_Invoice_On,
						Floor_Pricing_On
						,0 AS rebate_type
				FROM 	Program_Fixed_Component_Name
				WHERE	Program_Fixed_Component_Name_ID = '#arguments.Component_Name_ID#'
				</cfquery>
</cfif>
			</cfcase>
		<!--- Rebate --->
			<cfcase value="2">
				<cfquery name="qCompDetails" datasource="#application.datasource#">
				SELECT 	Program_Rebates_Component_Name_ID AS Component_Name_ID,
						Program_Rebates_Component_Name AS Component_Name,
						External_ID,
						Component_Type AS Component_Type,
						Accrual_On,
						Exclude_Brokerage,
						Off_Invoice_On,
						null as Floor_Pricing_On,
						rebate_type
				FROM 	Program_Rebates_Component_Name
				WHERE	Program_Rebates_Component_Name_ID = '#arguments.Component_Name_ID#'
				</cfquery>
			</cfcase>
		<!--- Lump Sum --->
			<cfcase value="3">
				<cfquery name="qCompDetails" datasource="#application.datasource#">
				SELECT 	Program_Lump_Sum_Name_ID AS Component_Name_ID,
						Program_Lump_Sum_Name AS Component_Name,
						External_ID,
						null AS Component_Type,
						null as Accrual_On,
						null as Exclude_Brokerage,
						0 as Off_Invoice_On,
						null as Floor_Pricing_On
				FROM 	Program_Lump_Sum_Name
				WHERE	Program_Lump_Sum_Name_ID = '#arguments.Component_Name_ID#'
				</cfquery>
			</cfcase>
		<!--- Growth --->
			<cfcase value="4">
				<cfquery name="qCompDetails" datasource="#application.datasource#">
				SELECT 	Program_Growth_Components_Name_ID AS Component_Name_ID,
						Program_Growth_Components_Name AS Component_Name,
						External_ID,
						null AS Component_Type,
						Accrual_On,
						Exclude_Brokerage,
						0 as Off_Invoice_On,
						null as Floor_Pricing_On
				FROM 	Program_Growth_Components_Name
				WHERE	Program_Growth_Components_Name_ID = '#arguments.Component_Name_ID#'
				</cfquery>
			</cfcase>

		</cfswitch>

	<cfreturn qCompDetails />

	</cffunction>


</cfcomponent>