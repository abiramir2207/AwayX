<cfcomponent hint="Authority Sequence Manager" extends="components.base">

	<cffunction name="init" output="false" returntype="components.user.AuthoritySequenceManager">
	  <cfargument name="datasource" type="string" required="false" />
	    <cfif structKeyExists(arguments,"datasource") and arguments.datasource neq "">
	     <cfset variables.dsn = arguments.datasource />
		<cfelse>
		 <cfset variables.dsn = application.datasource />
		</cfif>
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getAll" output="false" returntype="query">
	
		<cfargument name="authoritySequenceId" type="numeric" required="false" default="0">
	     <cfset var qGetAllAuthoritySequence = "" />
		
		<cfquery name="qGetAllAuthoritySequence" datasource="#Application.Datasource#">
			SELECT	*
			FROM	Authority_Sequence
			WHERE	Deleted = 0
			<cfif arguments.authoritySequenceId>
					AND Authority_Sequence_ID = #arguments.authoritySequenceId#
			</cfif>
			ORDER BY Authority_Sequence_Order Asc
		</cfquery>
	
		<cfreturn qGetAllAuthoritySequence />
		
	</cffunction>
	
	<cffunction name="getAuthoritySequenceLevel" output="false" returntype="query">
	
		<cfargument name="authoritySequenceId" type="numeric" required="true">
	
		<cfquery name="qGetAuthoritySequenceLevel" datasource="#application.datasource#">
			SELECT	Authority_Sequence_Order
			FROM	Authority_Sequence
			WHERE	Deleted = 0
					AND Authority_Sequence_ID = #arguments.authoritySequenceId#			
		</cfquery>
	
		<cfreturn qGetAuthoritySequenceLevel />
		
	</cffunction>
	
	<cffunction name="addEditSequence" output="false" returntype="string">
	
		<cfargument name="authoritySequenceId" type="numeric" required="true">
		<cfargument name="authoritySequenceOrder" type="numeric" required="true">
		<cfargument name="authoritySequenceDesc" type="string" required="true">
		<cfargument name="AccessStructure" type="struct" required="false">
		
		<cfset returnValue = "">
		<!------ Find if same desc exist for other record ----->
		<cfquery name="qGetSameName" datasource="#application.datasource#">
			SELECT	*
			FROM	Authority_Sequence
			WHERE	Authority_Sequence.Deleted = 0
					AND Authority_Sequence.Authority_Sequence_ID <> #arguments.authoritySequenceId#
					AND Authority_Sequence.Authority_Sequence_Name = '#arguments.authoritySequenceDesc#'
		</cfquery>
		
		<cfif NOT qGetSameName.recordCount>
		
			<cfif arguments.authoritySequenceId><!------ Edit ----->
			
				<!------ Edit the description alone ----->
				<cfquery name="qUpdateAS" datasource="#application.datasource#">
					UPDATE	Authority_Sequence
					SET		Authority_Sequence_Name = '#arguments.authoritySequenceDesc#',
							Updated_By = '#arguments.AccessStructure.user_id#',
							Updated_Date = GetDate()
					WHERE	Authority_Sequence_ID = #arguments.authoritySequenceId#
				</cfquery>
				
			<cfelse><!------ Insert ----->
			
				<!------ 1: Increment order # for all order >= current order ----->
				<cfquery name="qUpdateOrder" datasource="#application.datasource#">
					UPDATE	Authority_Sequence
					SET		Authority_Sequence_Order = Authority_Sequence_Order+1,
							Updated_By = '#arguments.AccessStructure.User_ID#',
							Updated_Date = GetDate()
					WHERE	Deleted = 0
							AND Authority_Sequence_Order >= #arguments.authoritySequenceOrder#
				</cfquery>
				
				<cfquery name="qInsertAS" datasource="#application.datasource#">
					INSERT INTO Authority_Sequence (Authority_Sequence_Order, Authority_Sequence_Name, updated_by, updated_date)
					VALUES (#arguments.authoritySequenceOrder#, '#arguments.authoritySequenceDesc#','#arguments.AccessStructure.user_id#',GetDate())
				</cfquery>
			
			</cfif>
			
			<cfset returnValue = "">
		
		<cfelse>
		
			<cfset returnValue = "Description already exists">
		
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	
	<cffunction name="getUserAssosiated" output="false" returntype="query">
	
		<cfargument name="authoritySequenceId" type="numeric" required="true">
		
		<cfquery name="qGetUserAssosiated" datasource="#application.datasource#">
			SELECT 	TOP 1 *
			FROM	_Users
			WHERE	Deleted = 0
					AND Authority_Sequence_ID = #arguments.authoritySequenceId#
		</cfquery>
		
		<cfreturn qGetUserAssosiated />
		
	</cffunction>
	
	<cffunction name="deleteSequence" output="false" returntype="string">
	
		<cfargument name="authoritySequenceId" type="numeric" required="true">
		<cfargument name="AccessStructure" type="struct" required="false">

		
		<cfset returnValue = "">
		
		<cfset qGetUserAssosiated = this.getUserAssosiated(arguments.authoritySequenceId) />
		
		<cfif NOT qGetUserAssosiated.recordCount>
		
			<!------ Get current order ----->
			<cfquery name="qGetAuthOrder" datasource="#application.datasource#">
				SELECT	Authority_Sequence_Order
				FROM	Authority_Sequence
				WHERE	Authority_Sequence_ID = #arguments.authoritySequenceId#
			</cfquery>
			
			<cfif qGetAuthOrder.recordCount>
			
				<!------ 1: Decrease order # for all order > current order ----->
				<cfquery name="qUpdateOrder" datasource="#application.datasource#">
					UPDATE	Authority_Sequence
					SET		Authority_Sequence_Order = Authority_Sequence_Order - 1,
							Updated_By = '#arguments.AccessStructure.user_id#',
							Updated_Date = GetDate()
					WHERE	Deleted = 0
							AND Authority_Sequence_Order > #qGetAuthOrder.Authority_Sequence_Order#
				</cfquery>
					
				<!------ Delete ----->
				<cfquery name="qUpdateAS" datasource="#application.datasource#">
					UPDATE	Authority_Sequence
					SET		Deleted = 1,
							Updated_By = '#arguments.AccessStructure.user_id#',
							Updated_Date = GetDate()
					WHERE	Authority_Sequence_ID = #arguments.authoritySequenceId#
				</cfquery>
				
				<cfset returnValue = "">
			
			</cfif>
		
		<cfelse>
		
			<cfset returnValue = "In Use">
		
		</cfif>
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="editSequenceOrder" output="false" returntype="string">
	
		<cfargument name="authoritySequenceId" type="numeric" required="true">
		<cfargument name="newAuthoritySequenceOrder" type="numeric" required="true">
		<cfargument name="AccessStructure" type="struct" required="false">

		
		<cfset returnValue = "">
		
		<!------ Update Order ----->
		<cfquery name="qUpdateAS" datasource="#application.datasource#">
			UPDATE	Authority_Sequence
			SET		Authority_Sequence_Order = #arguments.newAuthoritySequenceOrder#,
					Updated_By = '#arguments.AccessStructure.user_id#',
					Updated_Date = GetDate(),
					HQ_Position_id = 0
			WHERE	Authority_Sequence_ID = #arguments.authoritySequenceId#
		</cfquery>		
		
		<cfreturn returnValue />
		
	</cffunction>
	
	<cffunction name="removeHQPositions" output="false">
		
		<!------ Update Order ----->
		<cfquery name="removeHQPositions" datasource="#application.datasource#">
			UPDATE	Authority_Sequence
			SET		HQ_Position_id = 0
			WHERE	deleted = 0
		</cfquery>		
		
	</cffunction>	
	
</cfcomponent>
