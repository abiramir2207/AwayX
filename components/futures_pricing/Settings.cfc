<cfcomponent hint="Futures Pricing Settings" extends="components.Base">
	
	<cfset this.leadTime = 0 />
	<cfset this.restrictCustDeadline = 0 />	
	<cfset this.notifyCustDeadlineLeadTime = 0 />
	<cfset this.notifyOfferGoodUntilLeadTime = 0 />
	<cfset this.defaultPeriodType = 1 />
	<cfset this.updatedBy = "" />
	<cfset this.updatedByUserName = "" />
	<cfset this.updatedOn = "" />
	
	<cffunction name="init" output="false" returntype="components.futures_pricing.Settings">
	
		<cfreturn this />
		
	</cffunction>
	
	
	<!--- leadTime setter --->
	<cffunction name="setLeadTime" access="public" output="false">
		<cfargument name="leadTime" type="numeric" required="true" />
		<cfset this.leadTime = arguments.leadTime />
	</cffunction>
	<!--- leadTime getter --->
	<cffunction name="getLeadTime" access="public" returntype="string" output="false">
		<cfreturn this.leadTime />
	</cffunction>
	
	<!--- restrictCustDeadline setter --->
	<cffunction name="setRestrictCustDeadline" access="public" output="false">
		<cfargument name="restrictCustDeadline" type="numeric" required="true" />
		<cfset this.restrictCustDeadline = arguments.restrictCustDeadline />
	</cffunction>
	<!--- restrictCustDeadline getter --->
	<cffunction name="getRestrictCustDeadline" access="public" returntype="string" output="false">
		<cfreturn this.restrictCustDeadline />
	</cffunction>
		
	<!--- notifyCustDeadlineLeadTime setter --->
	<cffunction name="setNotifyCustDeadlineLeadTime" access="public" output="false">
		<cfargument name="notifyCustDeadlineLeadTime" type="numeric" required="true" />
		<cfset this.notifyCustDeadlineLeadTime = arguments.notifyCustDeadlineLeadTime />
	</cffunction>
	<!--- notifyCustDeadlineLeadTime getter --->
	<cffunction name="getNotifyCustDeadlineLeadTime" access="public" returntype="string" output="false">
		<cfreturn this.notifyCustDeadlineLeadTime />
	</cffunction>
	
	
	<!--- notifyOfferGoodUntilLeadTime setter --->
	<cffunction name="setNotifyOfferGoodUntilLeadTime" access="public" output="false">
		<cfargument name="notifyOfferGoodUntilLeadTime" type="numeric" required="true" />
		<cfset this.notifyOfferGoodUntilLeadTime = arguments.notifyOfferGoodUntilLeadTime />
	</cffunction>
	<!--- notifyCustDeadlineLeadTime getter --->
	<cffunction name="getNotifyOfferGoodUntilLeadTime" access="public" returntype="string" output="false">
		<cfreturn this.notifyOfferGoodUntilLeadTime />
	</cffunction>
	
	<!--- defaultPeriodType setter --->
	<cffunction name="setDefaultPeriodType" access="public" output="false">
		<cfargument name="defaultPeriodType" type="numeric" required="true" />
		<cfset this.defaultPeriodType = arguments.defaultPeriodType />
	</cffunction>
	<!--- defaultPeriodType getter --->
	<cffunction name="getDefaultPeriodType" access="public" returntype="string" output="false">
		<cfreturn this.defaultPeriodType />
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
	
</cfcomponent>