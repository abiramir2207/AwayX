<!------ Clause_Discount_Type_Add_Remove.cfm ----->

<!------ Find if discount type is active in this program ----->
<cfif NOT isDefined("addClauseMode") AND isDefined("discountTypeId") AND isDefined("programId")>
	<cfswitch expression="#discountTypeId#">
		<cfcase value="3"><!------ lump sum ----->
			<cfquery name="getDiscTypeCount" datasource="#application.datasource#">
				SELECT	TOP 1 Program_Lump_Sum_ID
				FROM	Program_Lump_Sums
				WHERE
						Deleted = 0
						AND
						Program_ID = #programId#
			</cfquery>
			<cfset addClauseMode = getDiscTypeCount.recordCount GT 0>
		</cfcase>
		<cfcase value="4"><!------ growth ----->
			<cfset useLakebaseForGetDiscTypeCount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_growth_components")>
			<cfif useLakebaseForGetDiscTypeCount>
				<cftry>
					<cfset getDiscTypeCount = application.oLakebase.toQuery(
						application.oLakebase.selectRows("program_growth_components", {
							"deleted" = "eq.false",
							"program_id" = "eq.#programId#",
							"select" = "program_growth_component_id",
							"limit" = "1"
						})
					)>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForGetDiscTypeCount = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForGetDiscTypeCount>
				<cfquery name="getDiscTypeCount" datasource="#application.datasource#">
					SELECT     	TOP 1 Program_Growth_Component_ID
					FROM       	Program_Growth_Components
					WHERE     
								Deleted = 0
								AND 
								Program_ID = #programId#
				</cfquery>
			</cfif>
			<cfset addClauseMode = getDiscTypeCount.recordCount GT 0>
		</cfcase>
		<cfcase value="5"><!------ formula ----->
			<cfquery name="getDiscTypeCount" datasource="#application.datasource#">
				SELECT		TOP 1 Program_Formula_Pricing_Rule_Mapped_ID
				FROM		Contract_Products 
							INNER JOIN Program_Formula_Pricing_Rule_Products 
							ON 
								Contract_Products.Contract_Products_ID = Program_Formula_Pricing_Rule_Products.Contract_Product_ID
							AND Program_Formula_Pricing_Rule_Products.Deleted = 0
							INNER JOIN Program_Formula_Pricing_Rule_Mapped
							ON
								Program_Formula_Pricing_Rule_Mapped.Program_Formula_Pricing_Rule_Mapped_ID = Program_Formula_Pricing_Rule_Products.Program_Formula_Pricing_Rule_ID
							AND	Program_Formula_Pricing_Rule_Mapped.Deleted = 0							
				WHERE     
							Contract_Products.Deleted = 0
							AND Contract_Products.Contract_Main_ID = #programId#							
			</cfquery>
			<cfset addClauseMode = getDiscTypeCount.recordCount GT 0>
		</cfcase>
	</cfswitch>
</cfif>

<!------ Find the template id of this program ----->
<cfif NOT isDefined("templateId") AND isDefined("programId")>
	<cfquery name="getTemplateId" datasource="#application.datasource#">
		SELECT 	ProgramType_ID
		FROM 	Contract_Main 
		WHERE 	Contract_Main_ID = #programId#
	</cfquery>
	<cfset templateId = getTemplateId.ProgramType_ID>
</cfif>

<cfif isDefined("addClauseMode") AND isDefined("programId")  AND isDefined("templateId") AND isDefined("discountTypeId")>
	<cfset clauseProgramManager = CreateObject("component", "components.clause_library.ClauseProgramManager").init() />
	<cfif addClauseMode>
		<!------  Bring all required clauses from the template ----->	
		<cfset clauseProgramManager.importRequiredClause(templateId, programId, request.AccessStructure.User_ID, 2, discountTypeId)>
	<cfelse>
		<!------  Delete all required clauses from the program ----->
		<cfset clauseProgramManager.removeRequiredClause(programId, request.AccessStructure.User_ID, 2, discountTypeId)>	
	</cfif>
</cfif>