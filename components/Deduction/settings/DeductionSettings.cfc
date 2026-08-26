<cfcomponent hint="Deduction Settings" extends="components.Base">
	
	<!------ Updated Info ----->
	<cfset this.updatedBy = "" />
	<cfset this.updatedByUserName = "" />
	<cfset this.updatedOn = "" />

	
	<!------ Add new variables here ----->
	<cfset this.ddNewAddReminderAfterDays = 0 />
	
	<cffunction name="init" output="false" returntype="components.deduction.settings.DeductionSettings">
	
		<cfreturn this />
		
	</cffunction>
	
	
	<!--- updatedBy setter --->
	<cffunction name="setUpdatedBy" access="public" output="false">
		<cfargument name="updatedBy" type="string" required="true" />
		<cfset this.updatedBy = arguments.updatedBy />
	</cffunction>
	<!--- updatedBy getter --->
	<cffunction name="getUpdatedBy" access="public" returntype="string" output="false">
		<cfreturn this.updatedBy />
	</cffunction>
	
	<!--- updatedByUserName setter --->
	<cffunction name="setUpdatedByUserName" access="public" output="false">
		<cfargument name="updatedByUserName" type="string" required="true" />
		<cfset this.updatedByUserName = arguments.updatedByUserName />
	</cffunction>
	<!--- updatedByUserName getter --->
	<cffunction name="getUpdatedByUserName" access="public" returntype="string" output="false">
		<cfreturn this.updatedByUserName />
	</cffunction>
	
	<!--- updatedOn setter --->
	<cffunction name="setUpdatedOn" access="public" output="false">
		<cfargument name="updatedOn" type="string" required="true" />
		<cfset this.updatedOn = arguments.updatedOn />
	</cffunction>
	<!--- updatedOn getter --->
	<cffunction name="getUpdatedOn" access="public" returntype="string" output="false">
		<cfreturn this.updatedOn />
	</cffunction>
	
	
	
	<!------ Add new functions here ----->
	
	<!--- ddNewAddReminderAfterDays --->
	<cffunction name="setDDNewAddReminderAfterDays" output="false" returntype="void" access="public">
		<cfargument name="ddNewAddReminderAfterDays" type="numeric" required="true">
		<cfset this.ddNewAddReminderAfterDays = arguments.ddNewAddReminderAfterDays />
	</cffunction>
	
	<cffunction name="getDDNewAddReminderAfterDays" output="false" access="public" returntype="numeric">
		<cfreturn this.ddNewAddReminderAfterDays />
	</cffunction>
	
</cfcomponent>