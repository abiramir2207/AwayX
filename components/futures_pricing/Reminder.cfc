<cfcomponent hint="Notes" extends="components.Base">

	<cfset this.id 				= 0 />
	<cfset this.requestId 		= 0 />
	<cfset this.desc 			= "" />
	<cfset this.emailReminder 	= 0 />
	<cfset this.reminderDate 	= "" />
	<cfset this.isPrivate	 	= 0 />
	<cfset this.createdBy 		= "" />
	<cfset this.createdDate	 	= "" />
	
	<cffunction name="init" output="false" returntype="components.futures_pricing.Reminder">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- id setter --->
	<cffunction name="setId" access="public" output="false">
		<cfargument name="id" required="true" default="" />
		<cfset this.id = arguments.id />
	</cffunction>
	<!--- id getter --->
	<cffunction name="getId" access="public" output="false">
		<cfreturn this.id />
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
	
	<!--- desc setter --->
	<cffunction name="setDesc" access="public" output="false">
		<cfargument name="desc" type="string" required="true" />
		<cfset this.desc = arguments.desc />
	</cffunction>
	<!--- desc name --->
	<cffunction name="getDesc" access="public" returntype="string" output="false">
		<cfreturn this.desc />
	</cffunction>
	
	<!--- emailReminder setter --->
	<cffunction name="setEmailReminder" access="public" output="false">
		<cfargument name="emailReminder" required="true" />
		<cfset this.emailReminder = arguments.emailReminder />
	</cffunction>
	<!--- emailReminder getter --->
	<cffunction name="getEmailReminder" access="public" output="false">
		<cfreturn this.emailReminder />
	</cffunction>
	
	<!--- reminderDate setter --->
	<cffunction name="setReminderDate" access="public" output="false">
		<cfargument name="reminderDate" required="true" />
		<cfset this.reminderDate = arguments.reminderDate />
	</cffunction>
	<!--- reminderDate getter --->
	<cffunction name="getReminderDate" access="public" output="false">
		<cfreturn this.reminderDate />
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
	</cffunction>
	<!--- createdBy getter --->
	<cffunction name="getCreatedBy" access="public" output="false">
		<cfreturn this.createdBy />
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