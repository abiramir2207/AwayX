<cfcomponent hint="Payment Cycle" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.programs.PaymentCycleManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getPaymentCycles" output="false" returntype="query">
	
		<cfargument name="templateId" type="numeric" required="false" default="0">
		<cfargument name="GrowthAutoPay" type="numeric" required="false" default="0"><!--- D35731 Growth Auto Pay --->
				
		<cfquery name="qGetPaymentCycles" datasource="#application.datasource#">
			
			SELECT 	Payment_Cycle.*,PayCycleDefaultOption, 
					<cfif arguments.GrowthAutoPay>
					CASE  
					WHEN Program_Control_Panel_Options.PayCycleDefaultOption IN (3,4, 5, 6, 7, 8,10,11,12) THEN Program_Control_Panel_Options.PayCycleDefaultOption
					ELSE 7
					END as PayCycleDefaultOption
					<cfelse>
					Program_Control_Panel_Options.PayCycleDefaultOption
					</cfif>
			FROM 	Payment_Cycle
					LEFT JOIN Program_Control_Panel_Options
					ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = #arguments.templateId#
			WHERE	Deleted = 0
			<!--- D35731 Growth Auto Pay 
			4 Quarterly, 5 Semi-Annual, 6 Annual, 7 Upon Expiration, 8 Upon Due
			--->
			<cfif arguments.GrowthAutoPay>
				AND Payment_Cycle_ID IN (3,4, 5, 6, 7, 8,10,11,12)
			</cfif>	
			<!--- D35731 Growth Auto Pay --->
				<cfif arguments.templateId GT 0>
				AND (
				1=2
				<cfloop index="i" from="1" to="12">
				OR
				(
				Payment_Cycle_ID = #i#
				AND PayCycleOption_#i# = 1
				)
				</cfloop>
				)
					<cfif application.appsettingsget.get_Setting('Auto_Pay_Use_Calendar_Months') eq '1'>
					AND Payment_Cycle_ID NOT IN (10, 11, 12) <!--- Fiscal Month, Fiscal Quarter, Fiscal Year --->
					</cfif>
				</cfif>
		</cfquery>

		<cfreturn qGetPaymentCycles />
		
	</cffunction>
	
<!--- 	<cffunction name="savePaymentCycle" output="false">
	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="discountTypeId" type="numeric" required="true">
		<cfargument name="paymentCycleId" type="numeric" required="true">
		
		<cfquery name="qDeleteExisting" datasource="#application.datasource#">
			UPDATE	Program_Payment_Cycle
			SET		Deleted = 1
			WHERE	Program_ID = #arguments.programId#
			AND 	Discount_Type_ID = #arguments.discountTypeId#
			AND 	Deleted = 0
		</cfquery>
		
		<cfquery name="qInsertPaymentType" datasource="#application.datasource#">
			INSERT INTO Program_Payment_Cycle (Program_ID, Discount_Type_ID, Payment_Cycle_ID)
			VALUES	(#arguments.programId#, #arguments.discountTypeId#, #arguments.paymentCycleId#)
		</cfquery>
		
	</cffunction> --->

	<cffunction name="DeletePaymentCycle" output="false">	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="discountTypeId" type="numeric" required="true">
		<cfargument name="componentId" type="string" required="false" default="0">
		<cfquery name="qDeleteExisting" datasource="#application.datasource#">
			UPDATE	Program_Payment_Cycle
			SET		Deleted = 1
			WHERE	Program_ID = #arguments.programId#
			AND 	Discount_Type_ID = #arguments.discountTypeId#
			AND 	Deleted = 0
			<cfif trim(arguments.componentId) neq 0 and (arguments.discountTypeId neq 1 and arguments.discountTypeId neq 2)>
			AND		Component_ID = '#arguments.componentId#'
			</cfif>
		</cfquery>
	</cffunction>
	
	<cffunction name="savePaymentCycle" output="false">
	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="discountTypeId" type="numeric" required="true">
		<cfargument name="paymentCycleId" type="numeric" required="true">
		<cfargument name="componentId" type="string" required="false" default="0">
		<cfargument name="payment_locked" type="numeric" required="false" default="0">

	 <cfif (arguments.discountTypeId neq 1 and arguments.discountTypeId neq 2)>
		<cfquery name="qDeleteExisting" datasource="#application.datasource#">
			UPDATE	Program_Payment_Cycle
			SET		Deleted = 1
			WHERE	Program_ID = #arguments.programId#
			AND 	Discount_Type_ID = #arguments.discountTypeId#
			AND 	Deleted = 0
			<cfif trim(arguments.componentId) neq 0>
				AND		Component_ID = '#arguments.componentId#'
			</cfif>
		</cfquery>
	 </cfif>

		<cfquery name="qInsertPaymentType" datasource="#application.datasource#">
			INSERT INTO Program_Payment_Cycle (Program_ID, Discount_Type_ID, Payment_Cycle_ID, Component_ID,Payment_Cycle_Is_Locked)
			VALUES	(#arguments.programId#, #arguments.discountTypeId#, #arguments.paymentCycleId#, '#arguments.componentId#',#arguments.payment_locked#)
		</cfquery>
		
	</cffunction>
	
	<cffunction name="getPaymentCycle" output="false" returntype="string">
	
		<cfargument name="programId" type="numeric" required="true" default="0">
		<cfargument name="discountTypeId" type="numeric" required="true" default="0">
		<cfargument name="componentId" type="string" required="false" default="0">
		
		<cfset returnValue = "">		
		
		<cfquery name="qGetExisting" datasource="#application.datasource#">
			SELECT	Payment_Cycle_ID
			FROM	Program_Payment_Cycle			
			WHERE	Program_ID = #arguments.programId#
			AND 	Discount_Type_ID = #arguments.discountTypeId#
			<cfif arguments.componentId neq 0>
			AND		Component_ID = '#arguments.componentId#'
			</cfif>
			AND 	Deleted = 0
		</cfquery>
		
		<cfif qGetExisting.recordCount>
			<cfset returnValue = qGetExisting.Payment_Cycle_ID>
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="isPaymentCycleLocked" output="false" returntype="boolean">
	
		<cfargument name="programId" type="numeric" required="true" default="0">
		<cfargument name="discountTypeId" type="numeric" required="true" default="0">
		<cfargument name="componentId" type="string" required="false" default="0">
		
		<cfset isLocked = 0 />		
		
		<cfset useLakebaseForqCheckLocked = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_payment_cycle")>
<cfif useLakebaseForqCheckLocked>
	<cftry>
		<cfset qCheckLocked = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_payment_cycle", {
				"program_id" = "eq.#arguments.programId#",
				"discount_type_id" = "eq.#arguments.discountTypeId#",
				"component_id" = "eq.#arguments.componentId#",
				"deleted" = "eq.0",
				"select" = "payment_cycle_is_locked"
			}), "payment_cycle_is_locked"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqCheckLocked = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqCheckLocked>
<cfquery name="qCheckLocked" datasource="#application.datasource#">
			SELECT	Payment_Cycle_Is_Locked
			FROM	Program_Payment_Cycle			
			WHERE	Program_ID = #arguments.programId#
			AND 	Discount_Type_ID = #arguments.discountTypeId#
			AND		Component_ID = '#arguments.componentId#'
			AND 	Deleted = 0
		</cfquery>
</cfif>
		
		<cfif qCheckLocked.recordCount>
			<cfset isLocked = qCheckLocked.Payment_Cycle_Is_Locked>
		</cfif>
		
		<cfreturn isLocked />
		
	</cffunction>
	
	<cffunction name="getPaymentCycleDescription" access="public" returntype="string">

		<cfargument name="PaymentCycleId" type="string" required="true" />
		
		<cfset returnValue = "">
		
		<cfif isNumeric(arguments.PaymentCycleId)>
		
			<cfquery name="qGetPaymentCycles" datasource="#application.datasource#" blockfactor="100">
			
				SELECT 	Payment_Cycle
				FROM 	Payment_Cycle
				WHERE 	Payment_Cycle_ID = '#arguments.PaymentCycleId#'
					
			</cfquery>
			
			<cfif qGetPaymentCycles.recordCount>
				<cfset returnValue = qGetPaymentCycles.Payment_Cycle>
			</cfif>
		
		</cfif>
			
		<cfreturn returnValue />
	
	</cffunction>
	
	<cffunction name="getProgramPaymentCycles" output="false" returntype="query">
	
		<cfargument name="programId" type="numeric" required="true">
		
		<cfquery name="qGetExisting" datasource="#application.datasource#">
			SELECT	*
			FROM	Program_Payment_Cycle			
			WHERE	Program_ID = #arguments.programId#
			AND 	Deleted = 0
		</cfquery>
		
		<cfreturn qGetExisting />
		
	</cffunction>

	<cffunction name="lockPaymentCycles" output="false">
	
		<cfargument name="programId" type="numeric" required="true">
		
		<cfquery name="qLockCycles" datasource="#application.datasource#">
			UPDATE	Program_Payment_Cycle
			SET		Payment_Cycle_Is_Locked = 1			
			WHERE	Program_ID = #arguments.programId#
			AND		Discount_Type_ID IN (3,4)
			AND 	Deleted = 0
		</cfquery>
		
	</cffunction>
	
	<cffunction name="revisePaymentCycle" output="false">
	
		<cfargument name="programId" type="numeric" required="true">
		<cfargument name="ParentprogramId" type="numeric" required="false">
		
		<cfquery name="qUpdatePayCycleLumpSums" datasource="#application.datasource#">
			UPDATE	Program_Payment_Cycle
			SET		Program_Payment_Cycle.Component_ID = Program_Lump_Sums.Program_Lumps_Sum_Ext_ID
			FROM 	Program_Payment_Cycle
					INNER JOIN Program_Lump_Sums ON
					CAST(Program_Lump_Sums.Lump_Revision_Comp_ID AS NVARCHAR(50)) = Program_Payment_Cycle.Component_ID
					AND Program_Lump_Sums.Program_ID = Program_Payment_Cycle.Program_ID
					AND Program_Lump_Sums.Deleted = 0
			WHERE 	Program_Payment_Cycle.Deleted = 0
			AND		Program_Payment_Cycle.Discount_Type_ID = 3
			AND 	Program_Payment_Cycle.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfquery name="qUpdatePayCycleGrowth" datasource="#application.datasource#">
			UPDATE	Program_Payment_Cycle
			SET		Program_Payment_Cycle.Component_ID = PGC_Child.Program_Growth_Component_ID
			FROM 	Program_Payment_Cycle
	
					INNER JOIN Program_Growth_Components PGC_Parent
					ON	CAST(PGC_Parent.Program_Growth_Component_ID AS nvarchar(50))  = Program_Payment_Cycle.Component_ID
					AND PGC_Parent.Program_ID = <cfqueryparam value="#arguments.ParentprogramId#" cfsqltype="cf_sql_integer">
					AND PGC_Parent.Deleted = 0
	
					INNER JOIN Program_Growth_Components PGC_Child
					ON	PGC_Child.Growth_Revision_Comp_ID = PGC_Parent.Growth_Component_Name_ID 
					AND PGC_Child.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
					AND PGC_Child.Deleted = 0
	
			WHERE 	Program_Payment_Cycle.Deleted = 0
			AND		Program_Payment_Cycle.Discount_Type_ID = 4
			AND 	Program_Payment_Cycle.Program_ID = <cfqueryparam value="#arguments.programId#" cfsqltype="cf_sql_integer">
		</cfquery>
				
		<!--- The Program_Fixed_component_Id (Component_ID) of the current program needs to change from that of parent program 
			  to that of the current new program, created while copying or revising 
	     --->
		<cfquery name="qUpdatePayCycleFixed" datasource="#application.datasource#">
			UPDATE Program_Payment_Cycle
			SET Component_ID = a.Program_Fixed_Component_ID
			FROM Program_Fixed_Component a
			INNER JOIN Program_Fixed_Component b
			ON a.program_fixed_component_name_id = b.program_fixed_component_name_id 
			AND a.fixed_component_paid_to = b.fixed_component_paid_to
			INNER JOIN Program_Payment_Cycle c
			ON b.program_fixed_component_id = c.component_id
			AND a.Program_ID = '#arguments.programId#'
			AND b.Program_ID = '#arguments.ParentprogramId#'
			AND c.Program_ID = '#arguments.programId#'
			AND c.Discount_Type_ID = 1
			AND a.deleted = 0
			AND b.deleted= 0
			AND c.deleted = 0
		</cfquery>

		<!--- The Program_rebate_component_Id (Component_ID) of the current program needs to change from that of parent program 
			  to that of the current new program, created while copying or revising  
	     --->
		<cfquery name="qUpdatePayCycleRebate" datasource="#application.datasource#">
			UPDATE Program_Payment_Cycle
			SET Component_ID = a.Program_Rebates_Component_ID
			FROM Program_Rebates_Component a
			INNER JOIN Program_Rebates_Component b
			ON a.program_rebates_component_name_id = b.program_rebates_component_name_id 
			AND a.component_paid_to = b.component_paid_to
			INNER JOIN Program_Payment_Cycle c
			ON b.program_rebates_component_id = c.component_id
			AND a.Program_ID = '#arguments.programId#'
			AND b.Program_ID = '#arguments.ParentprogramId#'
			AND c.Program_ID = '#arguments.programId#'
			AND c.Discount_Type_ID = 2
			AND a.deleted = 0
			AND b.deleted= 0
			AND c.deleted = 0
		</cfquery>
	</cffunction>
	
</cfcomponent>