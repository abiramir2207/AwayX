<cfcomponent hint="Cost Sequence Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.settings.CostSequenceManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
	
		<cfargument name="CostSequenceId" type="numeric" required="false" default="0">
	
		<cfquery name="qGetAllCostSequence" datasource="#application.datasource#">
			SELECT	Cost_Sequence.*
			FROM	Cost_Sequence
			WHERE	Deleted = 0
			<cfif arguments.CostSequenceId>
					AND Cost_Sequence_id = #arguments.CostSequenceId#
			</cfif>
			ORDER BY Cost_Sequence_Order
		</cfquery>
	
		<cfreturn qGetAllCostSequence />
		
	</cffunction>
	
	<cffunction name="getCostSequenceLevel" output="false" returntype="query">
	
		<cfargument name="CostSequenceId" type="numeric" required="true">
	
		<cfquery name="qGetCostSequenceLevel" datasource="#application.datasource#">
			SELECT	Cost_Sequence_Order
			FROM	Cost_Sequence
			WHERE	Deleted = 0
					AND Cost_Sequence_ID = #arguments.CostSequenceId#			
		</cfquery>
	
		<cfreturn qGetCostSequenceLevel />
		
	</cffunction>
	
	<cffunction name="addEditSequence" output="false" returntype="string">
	
		<cfargument name="CostSequenceId" type="numeric" required="true">
		<cfargument name="CostSequenceOrder" type="numeric" required="true">
		<cfargument name="CostSequenceDesc" type="string" required="true">
		
		<cfset returnValue = "">
		<!------ Find if same desc exist for other record ----->
		<cfset useLakebaseForqGetSameName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cost_sequence")>
<cfif useLakebaseForqGetSameName>
	<cftry>
		<cfset qGetSameName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cost_sequence", {
				"deleted" = "eq.0",
				"cost_sequence_id" = "neq.#arguments.CostSequenceId#",
				"cost_sequence_name" = "eq.#arguments.CostSequenceDesc#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetSameName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetSameName>
<cfquery name="qGetSameName" datasource="#application.datasource#">
			SELECT	*
			FROM	Cost_Sequence
			WHERE	Cost_Sequence.Deleted = 0
					AND Cost_Sequence.Cost_Sequence_ID <> #arguments.CostSequenceId#
					AND Cost_Sequence.Cost_Sequence_Name = '#arguments.CostSequenceDesc#'
		</cfquery>
</cfif>
		
		<cfif NOT qGetSameName.recordCount>
		
			<cfif arguments.CostSequenceId><!------ Edit ----->
			
				<!------ Edit the description alone ----->
				<cfset useLakebaseForqUpdateAS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cost_sequence")>
<cfif useLakebaseForqUpdateAS>
	<cftry>
		<cfset application.oLakebase.updateRows("cost_sequence",
			{
				"cost_sequence_id" = "eq.#arguments.CostSequenceId#"
			},
			{
				"cost_sequence_name" = "#arguments.CostSequenceDesc#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateAS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateAS>
<cfquery name="qUpdateAS" datasource="#application.datasource#">
					UPDATE	Cost_Sequence
					SET		Cost_Sequence_Name = '#arguments.CostSequenceDesc#'
					WHERE	Cost_Sequence_ID = #arguments.CostSequenceId#
				</cfquery>
</cfif>
				
			<cfelse><!------ Insert ----->
			
				<!------ 1: Increment order # for all order >= current order ----->
				<cfquery name="qUpdateOrder" datasource="#application.datasource#">
					UPDATE	Cost_Sequence
					SET		Cost_Sequence_Order = Cost_Sequence_Order+1
					WHERE	Deleted = 0
							AND Cost_Sequence_Order >= #arguments.CostSequenceOrder#
				</cfquery>
				
				<cfquery name="qInsertAS" datasource="#application.datasource#">
					INSERT INTO Cost_Sequence (Cost_Sequence_Order, Cost_Sequence_Name)
					VALUES (#arguments.CostSequenceOrder#, '#arguments.CostSequenceDesc#')
				</cfquery>
				
				<cfset tocount = arguments.CostSequenceOrder>
				<cfloop from="9" to="#tocount#" index ="i" step="-1">
				<cfset column_id = i + 1>
				<cfquery name="qUpdategroupcosts" datasource="#application.datasource#">
						update group_local_costs
						set cost#column_id#_rate = cost#i#_rate,
						cost#column_id#_uom = cost#i#_uom
				</cfquery>
				</cfloop>
				<cfquery name="qremovegroupcosts" datasource="#application.datasource#">
						update group_local_costs
						set cost#arguments.CostSequenceOrder#_rate = 0,
						 cost#arguments.CostSequenceOrder#_uom = 1
				</cfquery>
				
			</cfif>
			
			<cfset returnValue = "">
		
		<cfelse>
		
			<cfset returnValue = "Description already exists">
		
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	
<!--- 	<cffunction name="getUserAssosiated" output="false" returntype="query">
	
		<cfargument name="CostSequenceId" type="numeric" required="true">
		
		<cfquery name="qGetUserAssosiated" datasource="#application.datasource#">
			SELECT 	TOP 1 *
			FROM	_Users
			WHERE	Deleted = 0
					AND Cost_Sequence_ID = #arguments.CostSequenceId#
		</cfquery>
		
		<cfreturn qGetUserAssosiated />
		
	</cffunction> --->
	
	<cffunction name="deleteSequence" output="false" returntype="string">
	
		<cfargument name="CostSequenceId" type="numeric" required="true">
		
		<cfset returnValue = "">
		
		<!--- <cfset qGetUserAssosiated = this.getUserAssosiated(arguments.CostSequenceId) />
		
		<cfif NOT qGetUserAssosiated.recordCount> --->
		
			<!------ Get current order ----->
			<cfset useLakebaseForqGetAuthOrder = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cost_sequence")>
<cfif useLakebaseForqGetAuthOrder>
	<cftry>
		<cfset qGetAuthOrder = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cost_sequence", {
				"cost_sequence_id" = "eq.#arguments.CostSequenceId#",
				"select" = "cost_sequence_order"
			}), "cost_sequence_order"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAuthOrder = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAuthOrder>
<cfquery name="qGetAuthOrder" datasource="#application.datasource#">
				SELECT	Cost_Sequence_Order
				FROM	Cost_Sequence
				WHERE	Cost_Sequence_ID = #arguments.CostSequenceId#
			</cfquery>
</cfif>
			
			<cfif qGetAuthOrder.recordCount>
			
				<!------ 1: Decrease order # for all order > current order ----->
				<cfquery name="qUpdateOrder" datasource="#application.datasource#">
					UPDATE	Cost_Sequence
					SET		Cost_Sequence_Order = Cost_Sequence_Order - 1
					WHERE	Deleted = 0
							AND Cost_Sequence_Order > #qGetAuthOrder.Cost_Sequence_Order#
				</cfquery>
					
			
				<!------ Delete ----->
				<cfquery name="qUpdateAS" datasource="#application.datasource#">
					UPDATE	Cost_Sequence
					SET		Deleted = 1
					WHERE	Cost_Sequence_ID = #arguments.CostSequenceId#
				</cfquery>
					<cfloop from="#qGetAuthOrder.Cost_Sequence_Order#" to="9" index="i">
					<cfset column = i + 1>
					<cfquery name="qUpdategroupcosts" datasource="#application.datasource#">
						update group_local_costs
						set cost#i#_rate = cost#column#_rate,
						cost#i#_uom = cost#column#_uom
					</cfquery>
				</cfloop>
				<cfset returnValue = "">
			
			</cfif> 
		
		<!--- <cfelse>
		
			<cfset returnValue = "In Use">
		
		</cfif> --->
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="editSequenceOrder" output="false" returntype="string">
	
		<cfargument name="CostSequenceId" type="numeric" required="true">
		<cfargument name="newCostSequenceOrder" type="numeric" required="true">
		
		<cfset returnValue = "">
		
		<!------ Update Order ----->
		<cfquery name="qUpdateAS" datasource="#application.datasource#">
			UPDATE	Cost_Sequence
			SET		Cost_Sequence_Order = #arguments.newCostSequenceOrder#
			WHERE	Cost_Sequence_ID = #arguments.CostSequenceId#
		</cfquery>		
		
		<cfreturn returnValue />
		
	</cffunction>
	
</cfcomponent>
