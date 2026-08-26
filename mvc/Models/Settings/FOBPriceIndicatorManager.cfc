<!---
	Created by: Deepa Kunnath
	Created on: 5/24/2010
	Label for creation: D23415 Payment Against Excluded Invoice Events
	Lowest build available: 6.1
	 
	This functionality allows users to select the list of FOB price indicators per payee type to be used in auto pay.
	This seting will replace the hard coded values for X, K and C inside auto pay.
		
 --->

<cfcomponent displayname="FOB Price Indicator Manager" output="false">

<cffunction name="getProgramComponentFOBPriceIndicators" hint="return all the FOB Price Indicator records that macthes the criteria and the program component relationship" access="public" output="false" returntype="query">
	
	<cfargument name="payeeTypeId" type="numeric" required="true" />
	<cfargument name="discountTypeId" type="numeric" required="true" />
	<cfargument name="componentNameId" type="numeric" required="true" />
	
	<cfset var qGetProgramComponentFOBPriceIndicators = "" />
	
	<cfquery name="qGetProgramComponentFOBPriceIndicators" datasource="#application.datasource#">
		SELECT	Fob_Price_Indicator.Fob_Price_Indicator_ID,
				Fob_Price_Indicator.Fob_Price_Indicator,
				Fob_Price_Indicator.Fob_Price_Indicator_Desc,
				<cfif arguments.componentNameId eq 0>
					<!--- adding a new component, nothing in the database yet, so provide default values --->
					<cfif arguments.discountTypeId eq 2>
						<!--- rebate can have different rules for net sales / gross sales, let user make the selection --->
						0 as Component_Selected
					<cfelse>
						<!--- all discount type other than rebate follows same rule --->
						<cfif arguments.payeeTypeId eq 1><!--- when payee = distributor, X is excluded --->
							CASE 
							WHEN Fob_Price_Indicator.Fob_Price_Indicator IN ('X') THEN 0
							ELSE 1
							END as Component_Selected
						<cfelse><!--- when payee = operator or broker, all are included --->
							1 as Component_Selected
						</cfif>						
					</cfif>				
				<cfelse>
					<!--- editing a component, give the saved values --->				
					CASE 
					WHEN Program_Component_Fob_Price_Indicator.Fob_Price_Indicator IS NULL THEN 0
					ELSE 1
					END as Component_Selected
				</cfif>
		FROM	Fob_Price_Indicator
		
		LEFT JOIN Program_Component_Fob_Price_Indicator
		ON		Program_Component_Fob_Price_Indicator.Payee_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payeeTypeId#" />
		AND		Program_Component_Fob_Price_Indicator.Discount_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.discountTypeId#" />
		AND		Program_Component_Fob_Price_Indicator.Component_Name_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.componentNameId#" />
		AND		Program_Component_Fob_Price_Indicator.Fob_Price_Indicator = Fob_Price_Indicator.Fob_Price_Indicator
		
		WHERE	Fob_Price_Indicator.Deleted = 0
		
		ORDER BY Fob_Price_Indicator.Fob_Price_Indicator_ID
	</cfquery>
	
	<cfreturn qGetProgramComponentFOBPriceIndicators />
		
</cffunction>

<cffunction name="saveProgramComponentFOBPriceIndicator" returntype="void" output="false">
	<cfargument name="payeeTypeId" type="numeric" required="true" />
	<cfargument name="discountTypeId" type="numeric" required="true" />
	<cfargument name="componentNameId" type="numeric" required="true" />
	<cfargument name="FOBList" type="string" required="true" />
	
	<cfset var qDeleteExistingProgramComponentFOBPriceIndicator = "" />
	<cfset var qInsertProgramComponentFOBPriceIndicator = "" />
	<cfset var qInsertProgramComponentFOBPriceIndicatorHistory = "" />
	<cfset var FOBPriceIND = "" />
	
	<cfquery name="qDeleteExistingProgramComponentFOBPriceIndicator" datasource="#application.datasource#">
		DELETE 	Program_Component_Fob_Price_Indicator
		WHERE	Program_Component_Fob_Price_Indicator.Payee_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payeeTypeId#" />
		AND		Program_Component_Fob_Price_Indicator.Discount_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.discountTypeId#" />
		AND		Program_Component_Fob_Price_Indicator.Component_Name_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.componentNameId#" />
	</cfquery>
	
	<cfif arguments.FOBList neq "">
		<cfloop list="#arguments.FOBList#" index="FOBPriceIND">
			<cfquery name="qInsertProgramComponentFOBPriceIndicator" datasource="#application.datasource#">
				INSERT INTO Program_Component_Fob_Price_Indicator
				(Payee_Type_ID, Discount_Type_ID, Component_Name_ID, Fob_Price_Indicator)
				VALUES (
				<cfqueryparam value="#payeeTypeId#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#discountTypeId#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#componentNameId#" cfsqltype="cf_sql_integer">,
				<cfqueryparam value="#FOBPriceIND#" cfsqltype="cf_sql_varchar">
				)
			</cfquery>
		</cfloop>
		<cfquery name="qInsertProgramComponentFOBPriceIndicatorHistory" datasource="#application.datasource#">
			INSERT INTO Program_Component_Fob_Price_Indicator_History (Program_Component_Fob_Price_Indicator_ID, Payee_Type_ID, Discount_Type_ID, Component_Name_ID, Fob_Price_Indicator)
			SELECT	Program_Component_Fob_Price_Indicator_ID, Payee_Type_ID, Discount_Type_ID, Component_Name_ID, Fob_Price_Indicator
			FROM	Program_Component_Fob_Price_Indicator
			WHERE	Program_Component_Fob_Price_Indicator.Payee_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.payeeTypeId#" />
			AND		Program_Component_Fob_Price_Indicator.Discount_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.discountTypeId#" />
			AND		Program_Component_Fob_Price_Indicator.Component_Name_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.componentNameId#" />
		</cfquery>
	</cfif>
	
</cffunction>

</cfcomponent>