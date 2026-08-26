<cfcomponent hint="Notes" extends="components.Base">

	<cfset this.noteId 			= 0 />
	<cfset this.requestId 		= 0 />
	<cfset this.note 			= "" />
	<cfset this.isPrivate 		= 0 />
	<cfset this.createdBy 		= "" />
	<cfset this.createdByName 	= "" />
	<cfset this.createdDate 	= "" />	

	<cffunction name="init" output="false" returntype="components.futures_pricing.Note">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- noteId setter --->
	<cffunction name="setNoteId" access="public" output="false">
		<cfargument name="noteId" required="true" default="" />
		<cfset this.noteId = arguments.noteId />
	</cffunction>
	<!--- noteId getter --->
	<cffunction name="getNoteId" access="public" output="false">
		<cfreturn this.noteId />
	</cffunction>
	
	<!--- requestId setter --->
	<cffunction name="setRequestId" access="public" output="false">
		<cfargument name="requestId" required="true" default="" />
		<cfset this.requestId = arguments.requestId />
	</cffunction>
	<!--- requestId getter --->
	<cffunction name="getRequestId" access="public" output="false">
		<cfreturn this.requestId />
	</cffunction>
	
	<!--- note setter --->
	<cffunction name="setNote" access="public" output="false">
		<cfargument name="note" required="true" />
		<cfset this.note = arguments.note />
	</cffunction>
	<!--- note getter --->
	<cffunction name="getNote" access="public" output="false">
		<cfreturn this.note />
	</cffunction>
	
	<!--- isPrivate setter --->
	<cffunction name="setIsPrivate" access="public" output="false">
		<cfargument name="isPrivate" required="true" />
		<cfset this.isPrivate = arguments.isPrivate />
	</cffunction>
	<!--- isPrivate getter --->
	<cffunction name="getIsPrivate" access="public" output="false">
		<cfreturn this.isPrivate />
	</cffunction>
	
	<!--- createdBy setter --->
	<cffunction name="setCreatedBy" access="public" output="false">
		<cfargument name="createdBy" required="true" />
		<cfset this.createdBy = arguments.createdBy />
		
		<!---get username and password from database--->
		<cfquery name="qGetUser" datasource="#application.datasource#">
			SELECT 	Name_First,
					Name_Last 
			FROM 	_users
			WHERE	User_ID = '#arguments.createdBy#'
		</cfquery>
		
		<cfset tmpUserName = qGetUser.Name_First & " " & qGetUser.Name_Last />
		
		<cfset setCreatedByName(tmpUserName) />
		
	</cffunction>
	<!--- createdBy getter --->
	<cffunction name="getCreatedBy" access="public" output="false">
		<cfreturn this.createdBy />
	</cffunction>
	
	<!--- createdByName setter --->
	<cffunction name="setCreatedByName" access="public" output="false">
		<cfargument name="createdByName" required="true" />
		<cfset this.createdByName = arguments.createdByName />
	</cffunction>
	<!--- createdByName getter --->
	<cffunction name="getCreatedByName" access="public" output="false">
		<cfreturn this.createdByName />
	</cffunction>
	
	<!--- createdDate setter --->
	<cffunction name="setCreatedDate" access="public" output="false">
		<cfargument name="createdDate" required="true" />
		<cfset this.createdDate = arguments.createdDate />
	</cffunction>
	<!--- createdDate getter --->
	<cffunction name="getCreatedDate" access="public" output="false">
		<cfreturn this.createdDate />
	</cffunction>
	
</cfcomponent>