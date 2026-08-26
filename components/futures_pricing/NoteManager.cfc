<cfcomponent hint="Futures Pricing Raw Material Manager" extends="components.futures_pricing.RequestManager">
	
	<cffunction name="init" output="false" returntype="components.futures_pricing.NoteManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getRequestNotes" output="false" returntype="components.futures_pricing.Request">
	
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="pagePhase" type="numeric" required="false" default="0" />
		<cfargument name="noteId" type="numeric" required="false" default="0" />
		
		<cfset this.get(arguments.id, arguments.pagePhase)>
		<cfset this.getNotes(arguments.id, arguments.noteId) />

		<cfreturn this.request	/>
	
	</cffunction>
	
	<cffunction name="getNotes" output="false">
		
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="noteId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetNotes" datasource="#application.datasource#">
		
			SELECT 	FP_Note_ID,
					Note,
					isPrivate,
					Created_By,
					Created_Date
			FROM	FP_Note
			WHERE	Deleted = 0
			AND		FP_Request_Master_ID = #arguments.id#
			<cfif arguments.noteId>
			AND		FP_Note_ID = #arguments.noteId#
			</cfif>
		
		</cfquery>		
		
		<cfloop query="qGetNotes">
			
			<!---create an instance of the Note object--->
			<cfset noteObj = CreateObject("component", "components.futures_pricing.Note") />
			<cfset noteObj.setNoteId(FP_Note_ID) />
			<cfset noteObj.setNote(Note) />
			<cfset noteObj.setIsPrivate(isPrivate) />
			<cfset noteObj.setCreatedBy(Created_By) />
			<cfset noteObj.setCreatedDate(Created_Date) />

			<cfset this.request.setNotes(noteObj)	/>
			
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getNotesExist" output="false">
		
		<cfargument name="id" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetNotes" datasource="#application.datasource#">
		
			SELECT 	TOP 1 FP_Note_ID
			FROM	FP_Note
			WHERE	Deleted = 0
			AND		FP_Request_Master_ID = #arguments.id#
		
		</cfquery>
		
		<cfreturn qGetNotes.recordCount GT 0 />
		
	</cffunction>
	
	<cffunction name="getNoteCount" output="false">
		
		<cfargument name="id" type="numeric" required="false" default="0" />
		<cfargument name="userId" required="false" default="0" />
		
		<!---return count--->
		<cfset rCount = 0 />
		
		<cfquery name="qGetNotes" datasource="#application.datasource#">
		
			SELECT 	FP_Note_ID,
					isPrivate,
					Created_By
			FROM	FP_Note
			WHERE	Deleted = 0
			AND		FP_Request_Master_ID = #arguments.id#
			AND
					(
						isPrivate = 0
						OR
						Created_By = '#arguments.userId#'
					)
		</cfquery>
		
		<cfset rCount = qGetNotes.recordCount />
		
		<cfreturn rCount />
		
	</cffunction>
	
	<cffunction name="set" output="false" returntype="components.futures_pricing.Note">
		
		<cfargument name="stData" type="struct" required="false" default="" />		
		<cfparam name="arguments.stData.isPrivate" default=0 />
		
		<!---create an instance of the Note object--->
		<cfset noteObj = CreateObject("component", "components.futures_pricing.Note") />
		<cfset noteObj.setNoteId(arguments.stData.noteId) />
		<cfset noteObj.setRequestId(arguments.stData.id) />
		<cfset noteObj.setNote(arguments.stData.note) />
		<cfset noteObj.setIsPrivate(arguments.stData.isPrivate) />
		<cfset noteObj.setCreatedBy(arguments.stData.createdBy) />

		<cfreturn noteObj />
		
	</cffunction>
	
	<cffunction name="save" output="false">
		
		<cfargument name="noteObj" required="true" default="" type="components.futures_pricing.Note" />

		<!---if we have a note id then update--->
		<cfif arguments.noteObj.getNoteId()>
		
			<cfquery name="qUpdateNotes" datasource="#application.datasource#">
			
				UPDATE 	FP_Note
				SET		Note = <cfqueryparam value="#arguments.noteObj.getNote()#" cfsqltype="CF_SQL_VARCHAR">, 
						isPrivate = <cfqueryparam value="#arguments.noteObj.getIsPrivate()#" cfsqltype="CF_SQL_BIT">
				WHERE	FP_Note_ID = <cfqueryparam value="#arguments.noteObj.getNoteId()#" cfsqltype="CF_SQL_NUMERIC">
		
			</cfquery>
		
		<!---otherwise insert--->
		<cfelse>
		
			<cfquery name="qInsertNotes" datasource="#application.datasource#">
			
				INSERT INTO FP_Note
					(FP_Request_Master_ID, Note, isPrivate, Created_By)
				VALUES
					(
						<cfqueryparam value="#arguments.noteObj.getRequestId()#" cfsqltype="CF_SQL_NUMERIC">,
						<cfqueryparam value="#arguments.noteObj.getNote()#" cfsqltype="CF_SQL_VARCHAR">,
						<cfqueryparam value="#arguments.noteObj.getIsPrivate()#" cfsqltype="CF_SQL_NUMERIC">,
						<cfqueryparam value="#arguments.noteObj.getCreatedBy()#">
					)
		
			</cfquery>
		
		</cfif>
		
	</cffunction>
	
</cfcomponent>
