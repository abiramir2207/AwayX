<cfcomponent hint="Clause Category">
	<!--- 
	The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients use different functions based on app setting.
	The code for app setting (simple clauses) ON and OFF is very different. On any environment,we cannot turn ON or OFF this switch. If is not possible for 
	any client to move from simple (simple clauses app setting ON) to non-simple(simple clauses app setting OFF).
	To move from non-simple to simple clauses, please refer to label 25647 first.

	For any change to this file, first check whether the client requesting the modification has the "simple clauses" app switch ON or OFF. The clients with this
	app setting OFF use files with the "original" prefix for some of the clause library files and so a change in one file with or without the "original" prefix 
	might require a corresponding change in the other file, if the functionality affected is the same for both. Please refer to label 25647.
	--->
 <cfset variables.appsettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
	<cfset this.id = 0 />

	<cfset this.title = "" />
	<cfset this.createdBy = "" />
	<cfset this.updatedBy = "" />
	<cfset this.updatedDate = "" />
	<cfset this.isRequired = "" />
	
	<!--- New Settings - Dev Note: Milan - 19623/25647 --->
	<cfif appSettings.getSimpleClause() eq 1>
	  <cfset this.defaultClauseId = 1 />	
	  <cfset this.requireAll = 1 />
	  <cfset this.requireApproval = 0 />
	  <cfset this.applyToExisting = 2 />
	<cfelse>
	<!--- Old settings - Dev Note: Milan - 19623/25647 --->
	  <cfset this.defaultClauseId = 0 />	
	  <cfset this.requireAll = 0 />
	  <cfset this.requireApproval = 1 />
	  <cfset this.applyToExisting = 0 />
	</cfif>

	<cffunction name="init" output="false" returntype="components.clause_library.ClauseCategory">
		
		<cfreturn this />
		
	</cffunction>
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" type="string" required="true" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" returntype="string" output="false">
		<cfreturn this.id />
	</cffunction>
	
	<!--- defaultClauseId setter --->
	<cffunction name="setDefaultClauseId" access="public" output="false">
		<cfargument name="defaultClauseId" type="string" required="true" />
		<cfset this.defaultClauseId = arguments.defaultClauseId />
	</cffunction>
	<!--- defaultClauseId getter --->
	<cffunction name="getDefaultClauseId" access="public" returntype="string" output="false">
		<cfreturn this.defaultClauseId />
	</cffunction>
	
	<!--- title setter --->
	<cffunction name="setTitle" access="public" output="false">
		<cfargument name="title" type="string" required="true" />
		<cfset this.title = arguments.title />
	</cffunction>
	<!--- title getter --->
	<cffunction name="getTitle" access="public" returntype="string" output="false">
		<cfreturn this.title />
	</cffunction>
	
	<!--- createdBy setter --->
	<cffunction name="setCreatedBy" access="public" output="false">
		<cfargument name="createdBy" type="string" required="true" />
		<cfset this.createdBy = arguments.createdBy />
	</cffunction>
	<!--- createdBy getter --->
	<cffunction name="getCreatedBy" access="public" returntype="string" output="false">
		<cfreturn this.createdBy />
	</cffunction>
	
	<!--- updatedBy setter --->
	<cffunction name="setUpdatedBy" access="public" output="false">
		<cfargument name="updatedBy" type="string" required="true" />
		<cfset this.updatedBy = arguments.updatedBy />
	</cffunction>
	<!--- updatedBy setter --->
	<cffunction name="getUpdatedBy" access="public" returntype="string" output="false">
		<cfreturn this.updatedBy />
	</cffunction>
	
	<!--- updatedDate setter --->
	<cffunction name="setUpdatedDate" access="public" output="false">
		<cfargument name="updatedDate" type="string" required="true" />
		<cfset this.updatedDate = arguments.updatedDate />
	</cffunction>
	<!--- updatedDate setter --->
	<cffunction name="getUpdatedDate" access="public" returntype="string" output="false">
		<cfreturn this.updatedDate />
	</cffunction>
	
	<!--- requireAll setter --->
	<cffunction name="setRequireAll" access="public" output="false">
		<cfargument name="requireAll" type="string" required="true" />
		<cfset this.requireAll = arguments.requireAll />
	</cffunction>
	<!--- requireAll getter --->
	<cffunction name="getRequireAll" access="public" returntype="string" output="false">
		<cfreturn this.requireAll />
	</cffunction>
	
	<!--- requireApproval setter --->
	<cffunction name="setRequireApproval" access="public" output="false">
		<cfargument name="requireApproval" type="numeric" required="true" />
		<cfset this.requireApproval = arguments.requireApproval />
	</cffunction>
	<!--- requireApproval getter --->
	<cffunction name="getRequireApproval" access="public" returntype="numeric" output="false">
		<cfreturn this.requireApproval />
	</cffunction>	
	
	<!--- applyToExisting setter --->
	<cffunction name="setApplyToExisting" access="public" output="false">
		<cfargument name="applyToExisting" type="string" required="true" />
		<cfset this.applyToExisting = arguments.applyToExisting />
	</cffunction>
	<!--- applyToExisting getter --->
	<cffunction name="getApplyToExisting" access="public" returntype="string" output="false">
		<cfreturn this.applyToExisting />
	</cffunction>
	
</cfcomponent>