<cfcomponent hint="HQ PositionManager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.user.HQPositionManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
	
		<cfargument name="HQ_Position_ID" type="numeric" required="false" default="0">
	
		<cfquery name="qGetAllHQPositions" datasource="#application.datasource#">
			SELECT	*
			FROM	HQ_Positions
			WHERE	Deleted = 0
			<cfif arguments.HQ_Position_ID>
					AND HQ_Position_ID = #arguments.HQ_Position_ID#
			</cfif>
			ORDER BY HQ_Position_Order
		</cfquery>
	
		<cfreturn qGetAllHQPositions />
		
	</cffunction>
	
	<cffunction name="getAStoAssign" output="false" returntype="query">
	
		<cfargument name="HQ_Position_ID" type="numeric" required="false" default="0">
		<cfargument name="HQ_Position_Order" type="numeric" required="false" default="0">

 		<cfquery name="getMaxASAssigned" datasource="#application.datasource#">
		select ISNULL(max(Authority_Sequence_order),0) as max_AS
		from Authority_Sequence
		inner join HQ_Positions on
		HQ_Positions.HQ_Position_id =Authority_Sequence.HQ_Position_id
		and HQ_Positions.deleted = 0
		where Authority_Sequence.HQ_Position_id ! = 0
		and Authority_Sequence.deleted = 0
		and HQ_Positions.HQ_Position_order < #arguments.HQ_Position_Order#
		</cfquery>
		
		<cfquery name="getMinASAssigned" datasource="#application.datasource#">
				select ISNULL(min(Authority_Sequence_order),0) as max_AS
				from Authority_Sequence
				inner join HQ_Positions on
				HQ_Positions.HQ_Position_id =Authority_Sequence.HQ_Position_id
				and HQ_Positions.deleted = 0
				where Authority_Sequence.HQ_Position_id ! = 0
				and Authority_Sequence.deleted = 0
				and HQ_Positions.HQ_Position_order > #arguments.HQ_Position_Order#
		</cfquery>
	
		<cfquery name="qgetAStoAssign" datasource="#application.datasource#">
			SELECT	*
			FROM	Authority_Sequence
			WHERE	Deleted = 0
			and (HQ_Position_ID = 0 OR HQ_Position_ID = #arguments.HQ_Position_ID#)
			<cfif getMaxASAssigned.max_AS NEQ 0>
			and Authority_Sequence_order > #getMaxASAssigned.max_AS#
			</cfif>
			<cfif getMinASAssigned.max_AS NEQ 0>
			and Authority_Sequence_order < #getMinASAssigned.max_AS#
			</cfif>
			ORDER BY Authority_Sequence_Order
		</cfquery>
	
		<cfreturn qgetAStoAssign />
		
	</cffunction>
	
	<cffunction name="getASAssigned" output="false" returntype="query">
		<cfargument name="HQ_Position_ID" type="numeric" required="false" default="0">
			<cfset useLakebaseForqgetASAssigned = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("authority_sequence")>
<cfif useLakebaseForqgetASAssigned>
	<cftry>
		<cfset qgetASAssigned = application.oLakebase.toQuery(
			application.oLakebase.selectRows("authority_sequence", {
				"deleted" = "eq.0",
				"hq_position_id" = "eq.#arguments.HQ_Position_ID#",
				"order" = "authority_sequence_order.asc",
				"select" = "authority_sequence_id"
			}), "authority_sequence_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetASAssigned = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetASAssigned>
<cfquery name="qgetASAssigned" datasource="#application.datasource#">
			SELECT	Authority_Sequence_ID
			FROM	Authority_Sequence
			WHERE	Deleted = 0
			and HQ_Position_ID = #arguments.HQ_Position_ID#
			ORDER BY Authority_Sequence_Order
		</cfquery>
</cfif>
	
		<cfreturn qgetASAssigned />
	</cffunction>
	
	<cffunction name="InsertAssignAS" output="false">
		<cfargument name="HQ_Position_ID" type="numeric" required="false" default="0">
		<cfargument name="Authority_Sequence_ID" type="string" required="false" default="">
		<cfset useLakebaseForqDeleteAssignAS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("authority_sequence")>
<cfif useLakebaseForqDeleteAssignAS>
	<cftry>
		<cfset application.oLakebase.updateRows("authority_sequence",
			{
				"hq_position_id" = "eq.#arguments.HQ_Position_ID#"
			},
			{
				"hq_position_id" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteAssignAS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteAssignAS>
<cfquery name="qDeleteAssignAS" datasource="#application.datasource#">
			update Authority_Sequence
			set HQ_Position_ID =  0
			where HQ_Position_ID =  #arguments.HQ_Position_ID#
		</cfquery>
</cfif>
		<cfif LEN(arguments.Authority_Sequence_ID) GT 0>
		<cfquery name="qInsertAssignAS" datasource="#application.datasource#">
			update Authority_Sequence
			set HQ_Position_ID =  #arguments.HQ_Position_ID#
			where Authority_Sequence_id in (#arguments.Authority_Sequence_ID#)
		</cfquery>
		</cfif>
		
	</cffunction>
	
		<cffunction name="DeleteAssignAS" output="false">
		<cfargument name="HQ_Position_ID" type="numeric" required="false" default="0">
		<cfquery name="qDeleteAssignAS" datasource="#application.datasource#">
			update Authority_Sequence
			set HQ_Position_ID =  0
			where HQ_Position_ID =  #arguments.HQ_Position_ID#
		</cfquery>
		</cffunction>
		
	<cffunction name="getHQPositionLevel" output="false" returntype="query">
	
		<cfargument name="HQPositionId" type="numeric" required="true">
	
		<cfset useLakebaseForqGetHQPositionLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("hq_positions")>
<cfif useLakebaseForqGetHQPositionLevel>
	<cftry>
		<cfset qGetHQPositionLevel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("hq_positions", {
				"deleted" = "eq.0",
				"hq_position_id" = "eq.#arguments.HQPositionId#",
				"select" = "hq_position_order"
			}), "hq_position_order"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetHQPositionLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetHQPositionLevel>
<cfquery name="qGetHQPositionLevel" datasource="#application.datasource#">
			SELECT	HQ_Position_Order
			FROM	HQ_Positions
			WHERE	Deleted = 0
					AND HQ_Position_ID = #arguments.HQPositionId#			
		</cfquery>
</cfif>
	
		<cfreturn qGetHQPositionLevel />
		
	</cffunction>
	
	<cffunction name="addEditSequence" output="false" returntype="string">
	
		<cfargument name="HQPositionId" type="numeric" required="true">
		<cfargument name="HQPositionOrder" type="numeric" required="true">
		<cfargument name="HQPositionDesc" type="string" required="true">
		<cfargument name="AccessStructure" type="struct" required="false">
		
		<cfset returnValue = "">
		<!------ Find if same desc exist for other record ----->
		<cfset useLakebaseForqGetSameName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("hq_positions")>
<cfif useLakebaseForqGetSameName>
	<cftry>
		<cfset qGetSameName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("hq_positions", {
				"deleted" = "eq.0",
				"hq_position_id" = "neq.#arguments.HQPositionId#",
				"hq_position_name" = "eq.#arguments.HQPositionDesc#"
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
			FROM	HQ_Positions
			WHERE	HQ_Positions.Deleted = 0
					AND HQ_Positions.HQ_Position_ID <> #arguments.HQPositionId#
					AND HQ_Positions.HQ_Position_Name = '#arguments.HQPositionDesc#'
		</cfquery>
</cfif>
		
		<cfif NOT qGetSameName.recordCount>
		
			<cfif arguments.HQPositionId><!------ Edit ----->
			
				<!------ Edit the description alone ----->
				<cfset useLakebaseForqUpdateAS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("hq_positions")>
<cfif useLakebaseForqUpdateAS>
	<cftry>
		<cfset application.oLakebase.updateRows("hq_positions",
			{
				"hq_position_id" = "eq.#arguments.HQPositionId#"
			},
			{
				"hq_position_name" = "#arguments.HQPositionDesc#",
				"updated_by" = "#arguments.AccessStructure.user_id#",
				"updated_date" = "#now()#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateAS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateAS>
<cfquery name="qUpdateAS" datasource="#application.datasource#">
					UPDATE	HQ_Positions
					SET		HQ_Position_Name = '#arguments.HQPositionDesc#',
							Updated_By = '#arguments.AccessStructure.user_id#',
							Updated_Date = GetDate()
					WHERE	HQ_Position_ID = #arguments.HQPositionId#
				</cfquery>
</cfif>
				
			<cfelse><!------ Insert ----->
			
				<!------ 1: Increment order # for all order >= current order ----->
				<cfquery name="qUpdateOrder" datasource="#application.datasource#">
					UPDATE	HQ_Positions
					SET		HQ_Position_Order = HQ_Position_Order + 1,
							Updated_By = '#arguments.AccessStructure.user_id#',
							Updated_Date = GetDate()
					WHERE	Deleted = 0
							AND HQ_Position_Order >= #arguments.HQPositionOrder#
				</cfquery>
				
				<cfset useLakebaseForqInsertAS = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("hq_positions")>
<cfif useLakebaseForqInsertAS>
	<cftry>
		<cfset application.oLakebase.insertRow("hq_positions", {
			"hq_position_order" = "#arguments.HQPositionOrder#",
			"hq_position_name" = "#arguments.HQPositionDesc#",
			"updated_by" = "#arguments.AccessStructure.user_id#",
			"updated_date" = "#now()#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertAS = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertAS>
<cfquery name="qInsertAS" datasource="#application.datasource#">
					INSERT INTO HQ_Positions (HQ_Position_Order, HQ_Position_Name, Updated_By, Updated_Date)
					VALUES (#arguments.HQPositionOrder#, '#arguments.HQPositionDesc#', '#arguments.AccessStructure.user_id#', GetDate())
				</cfquery>
</cfif>
			
			</cfif>
			
			<cfset returnValue = "">
		
		<cfelse>
		
			<cfset returnValue = "Description already exists">
		
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	
	<cffunction name="getASAssosiated" output="false" returntype="query">
	
		<cfargument name="HQPositionId" type="numeric" required="true">
		
		<cfset useLakebaseForqGetASAssosiated = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("authority_sequence")>
<cfif useLakebaseForqGetASAssosiated>
	<cftry>
		<cfset qGetASAssosiated = application.oLakebase.toQuery(
			application.oLakebase.selectRows("authority_sequence", {
				"deleted" = "eq.0",
				"hq_position_id" = "neq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetASAssosiated = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetASAssosiated>
<cfquery name="qGetASAssosiated" datasource="#application.datasource#">
			SELECT 	TOP 1 *
			FROM	Authority_Sequence
			WHERE	Deleted = 0
					AND HQ_Position_ID = #arguments.HQPositionId#
					AND HQ_Position_ID <> 0
		</cfquery>
</cfif>
		
		<cfreturn qGetASAssosiated />
		
	</cffunction>
	
	<cffunction name="deleteSequence" output="false" returntype="string">
	
		<cfargument name="HQPositionId" type="numeric" required="true">
		<cfargument name="AccessStructure" type="struct" required="false">
		
		<cfset returnValue = "">
		
		<cfset qgetASAssosiated = this.getASAssosiated(arguments.HQPositionId) />
		
		<cfif NOT qgetASAssosiated.recordCount>
		
			<!------ Get current order ----->
			<cfset useLakebaseForqGetAuthOrder = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("hq_positions")>
<cfif useLakebaseForqGetAuthOrder>
	<cftry>
		<cfset qGetAuthOrder = application.oLakebase.toQuery(
			application.oLakebase.selectRows("hq_positions", {
				"hq_position_id" = "eq.#arguments.HQPositionId#",
				"select" = "hq_position_order"
			}), "hq_position_order"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetAuthOrder = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetAuthOrder>
<cfquery name="qGetAuthOrder" datasource="#application.datasource#">
				SELECT	HQ_Position_Order
				FROM	HQ_Positions
				WHERE	HQ_Position_ID = #arguments.HQPositionId#
			</cfquery>
</cfif>
			
			<cfif qGetAuthOrder.recordCount>
			
				<!------ 1: Decrease order # for all order > current order ----->
				<cfquery name="qUpdateOrder" datasource="#application.datasource#">
					UPDATE	HQ_Positions
					SET		HQ_Position_Order = HQ_Position_Order - 1,
							Updated_By = '#arguments.AccessStructure.user_id#',
							Updated_Date = GetDate()
					WHERE	Deleted = 0
							AND HQ_Position_Order > #qGetAuthOrder.HQ_Position_Order#
				</cfquery>
					
				<!------ Delete ----->
				<cfquery name="qUpdateAS" datasource="#application.datasource#">
					UPDATE	HQ_Positions
					SET		Deleted = 1,
							Updated_By = '#arguments.AccessStructure.user_id#',
							Updated_Date = GetDate()
					WHERE	HQ_Position_ID = #arguments.HQPositionId#
				</cfquery>
				
				<cfset returnValue = "">
			
			</cfif>
		
		<cfelse>
		
			<cfset returnValue = "In Use">
		
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="editSequenceOrder" output="false" returntype="string">
	
		<cfargument name="HQPositionId" type="numeric" required="true">
		<cfargument name="newHQPositionOrder" type="numeric" required="true">
		
		<cfset returnValue = "">
		
		<!------ Update Order ----->
		<cfquery name="qUpdateAS" datasource="#application.datasource#">
			UPDATE	HQ_Position
			SET		HQ_Position_Order = #arguments.newHQPositionOrder#
			WHERE	HQ_Position_ID = #arguments.HQPositionId#
		</cfquery>		
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="InsertAssignRT" output="false">
		<cfargument name="formScope" required="true" type="struct" />
		<cfset useLakebaseFordeleteRT = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("revisiontype_approval")>
<cfif useLakebaseFordeleteRT>
	<cftry>
		<cfset application.oLakebase.deleteRows("revisiontype_approval", {})>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteRT = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteRT>
<cfquery name="deleteRT" datasource="#application.datasource#">
			Delete from RevisionType_Approval
		</cfquery>
</cfif>
		<cfquery name="qInsertRT" datasource="#application.datasource#">
			INSERT INTO RevisionType_Approval (Revision_TypeA, Revision_TypeB,Revision_TypeC)
			VALUES ( #Evaluate("arguments.formScope.HQPosition_A")#,  #Evaluate("arguments.formScope.HQPosition_B")#, #Evaluate("arguments.formScope.HQPosition_C")#)
		</cfquery>
	</cffunction>
	
	<cffunction name="getRevisionHQAssigned" output="false" returntype="query">
		<cfset useLakebaseForqgetRevisionHQAssigned = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("revisiontype_approval")>
<cfif useLakebaseForqgetRevisionHQAssigned>
	<cftry>
		<cfset qgetRevisionHQAssigned = application.oLakebase.toQuery(
			application.oLakebase.selectRows("revisiontype_approval", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqgetRevisionHQAssigned = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqgetRevisionHQAssigned>
<cfquery name="qgetRevisionHQAssigned" datasource="#application.datasource#">
			select * from
			RevisionType_Approval
		</cfquery>
</cfif>
		<cfreturn qgetRevisionHQAssigned>
	</cffunction>
	
</cfcomponent>
