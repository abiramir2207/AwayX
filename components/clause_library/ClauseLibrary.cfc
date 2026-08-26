<cfcomponent hint="Clause Library" extends="components.Base">
	<!--- 
	The app setting (simple clauses) is ON for clients using our new clauses functionality. The clients use different functions based on app setting.
	The code for app setting (simple clauses) ON and OFF is very different. On any environment,we cannot turn ON or OFF this switch. If is not possible for 
	any client to move from simple (simple clauses app setting ON) to non-simple(simple clauses app setting OFF).
	To move from non-simple to simple clauses, please refer to label 25647 first.

	For any change to this file, first check whether the client requesting the modification has the "simple clauses" app switch ON or OFF. The clients with this
	app setting OFF use files with the "original" prefix for some of the clause library files and so a change in one file with or without the "original" prefix 
	might require a corresponding change in the other file, if the functionality affected is the same for both. Please refer to label 25647.
	--->
	<cfset this.id = 0 />
	<cfset this.categoryId = 0 />
	<cfset this.category = CreateObject("component", "components.clause_library.ClauseCategory").init() />
	<cfset this.parentId = 0 />
	<cfset this.status = 0 />
	<cfset this.version = 1 />
	<cfset this.body = "" />
	<cfset this.bodyFrench = "" />
	<cfset this.createdBy = "" />
	<cfset this.updatedBy = "" />
	<cfset this.updatedDate = "" />
	<cfset this.applyToExisting = 0 />
	<cfset this.editFromProgram = 0 />
	<cfset this.discountTypeId = 0 />
	<cfset this.clauseType = "" />
	<cfset this.isRequired = "" />
	<cfset this.programId = "" />
	<cfset this.isDefault = 0 />

	<cffunction name="init" output="false" returntype="components.clause_library.ClauseLibrary">
		
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
	
	<!--- categoryId setter --->
	<cffunction name="setCategoryId" access="public" output="false">
		<cfargument name="categoryId" type="string" required="true" />
		<cfset this.categoryId = arguments.categoryId />
	</cffunction>
	<!--- categoryId getter --->
	<cffunction name="getCategoryId" access="public" returntype="string" output="false">
		<cfreturn this.categoryId />
	</cffunction>
	
	<!--- category setter --->
	<cffunction name="setCategory" access="public" output="false">
		<cfargument name="category" type="components.clause_library.ClauseCategory" required="true" />
		<cfset this.category = arguments.category />
	</cffunction>
	<!--- category getter --->
	<cffunction name="getCategory" access="public" returntype="components.clause_library.ClauseCategory" output="false">
		<cfreturn this.category />
	</cffunction>
	
	<!--- parentId setter --->
	<cffunction name="setParentId" access="public" output="false">
		<cfargument name="parentId" type="string" required="true" />
		<cfset this.parentId = arguments.parentId />
	</cffunction>
	<!--- parentId getter --->
	<cffunction name="getParentId" access="public" returntype="string" output="false">
		<cfreturn this.parentId />
	</cffunction>
	
	<!--- status setter --->
	<cffunction name="setStatus" access="public" output="false">
		<cfargument name="status" type="string" required="true" />
		<cfset this.status = arguments.status />
	</cffunction>
	<!--- status getter --->
	<cffunction name="getStatus" access="public" returntype="string" output="false">
		<cfreturn this.status />
	</cffunction>
	
	<!--- version setter --->
	<cffunction name="setVersion" access="public" output="false">
		<cfargument name="version" type="string" required="true" />
		<cfset this.version = arguments.version />
	</cffunction>
	<!--- version getter --->
	<cffunction name="getVersion" access="public" returntype="string" output="false">
		<cfreturn this.version />
	</cffunction>
	
	<!--- body setter --->
	<cffunction name="setBody" access="public" output="false">
		<cfargument name="body" type="string" required="true" />
		<cfset this.body = arguments.body />
		<cfset this.body = stripHTMLTag(this.body, "span") />
		<cfset this.body = stripHTMLTag(this.body, "font") />
	</cffunction>
	<!--- body getter --->
	<cffunction name="getBody" access="public" returntype="string" output="false">
		<cfreturn this.body />
	</cffunction>

	<!--- body setter (french) --->
	<cffunction name="setBodyFrench" access="public" output="false">
		<cfargument name="bodyFrench" type="string" required="true" />
		<cfset this.bodyFrench = arguments.bodyFrench />
		<cfset this.bodyFrench = stripHTMLTag(this.bodyFrench, "span") />
		<cfset this.bodyFrench = stripHTMLTag(this.bodyFrench, "font") />
	</cffunction>
	<!--- body getter (french) --->
	<cffunction name="getBodyFrench" access="public" returntype="string" output="false">
		<cfreturn this.bodyFrench />
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
	
	<!--- applyToExisting setter --->
	<cffunction name="setApplyToExisting" access="public" output="false">
		<cfargument name="applyToExisting" type="string" required="true" />
		<cfset this.applyToExisting = arguments.applyToExisting />
	</cffunction>
	<!--- applyToExisting getter --->
	<cffunction name="getApplyToExisting" access="public" returntype="string" output="false">
		<cfreturn this.applyToExisting />
	</cffunction>
	
	<!--- editFromProgram setter --->
	<cffunction name="setEditFromProgram" access="public" output="false">
		<cfargument name="editFromProgram" type="numeric" required="true" />
		<cfset this.editFromProgram = arguments.editFromProgram />
	</cffunction>
	<!--- editFromProgram getter --->
	<cffunction name="getEditFromProgram" access="public" returntype="numeric" output="false">
		<cfreturn this.editFromProgram />
	</cffunction>
	
	<!--- programId setter --->
	<cffunction name="setProgramId" access="public" output="false">
		<cfargument name="programId" type="numeric" required="true" />
		<cfset this.programId = arguments.programId />
	</cffunction>
	<!--- programId getter --->
	<cffunction name="getProgramId" access="public" returntype="numeric" output="false">
		<cfreturn this.programId />
	</cffunction>
	
	<!--- isDefault setter --->
	<cffunction name="setIsDefault" access="public" output="false">
		<cfargument name="isDefault" type="numeric" required="true" />
		<cfset this.isDefault = arguments.isDefault />
	</cffunction>
	<!--- isDefault getter --->
	<cffunction name="getIsDefault" access="public" returntype="numeric" output="false">
		<cfreturn this.isDefault />
	</cffunction>
	
</cfcomponent>