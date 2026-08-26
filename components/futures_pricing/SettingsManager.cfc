<cfcomponent hint="Futures Pricing Settings Manager" extends="components.Base">

	<cfset this.settings = CreateObject("component","components.futures_pricing.Settings").init() />
		
	<cffunction name="init" output="false" returntype="components.futures_pricing.SettingsManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getSettings" output="false" returntype="components.futures_pricing.Settings">
		
		<cfreturn this.settings />
	
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.futures_pricing.Settings">
	
		<cfquery name="qGetSettings" datasource="#application.datasource#">
			SELECT	Lead_Time, 
					RestrictCustDeadline, 
					NotifyCustDeadlineLeadTime, 
					NotifyOfferGoodUntilLeadTime,
					DefaultPeriodType,
					UpdatedBy,
					_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName,
					UpdatedOn					
			FROM	FP_Settings					
					LEFT JOIN _Users
					ON
					_Users.Deleted = 0
					AND
					_Users.User_ID = FP_Settings.UpdatedBy
			WHERE
					FP_Settings.Deleted = 0
		</cfquery>
		<cfloop query="qGetSettings">
		
			<cfset this.settings.setLeadTime(Lead_Time) />
			<cfset this.settings.setRestrictCustDeadline(RestrictCustDeadline) />
			<cfset this.settings.setNotifyCustDeadlineLeadTime(NotifyCustDeadlineLeadTime) />
			<cfset this.settings.setNotifyOfferGoodUntilLeadTime(NotifyOfferGoodUntilLeadTime) />
			<cfset this.settings.setDefaultPeriodType(DefaultPeriodType) />
			<cfset this.settings.setUpdatedBy(UpdatedBy) />
			<cfset this.settings.setUpdatedByUserName(UpdatedByFullName) />
			<cfset this.settings.setUpdatedOn(UpdatedOn) />
			
		</cfloop>
		
		<cfreturn this.settings />
		
	</cffunction>
	
	
	<cffunction name="save" output="false">
	
		<cftransaction action="BEGIN">
			<cftry>
				<!------ set deleted for existing entry ----->
				<cfquery name="qDeleteOld" datasource="#application.datasource#">
					UPDATE	FP_Settings
					SET		Deleted = 1
					WHERE
							Deleted = 0
				</cfquery>
				
				<!------ insert new ----->
				<cfquery name="qInsertSettings" datasource="#application.datasource#">
					INSERT INTO	FP_Settings
						(
							Lead_Time, 
							RestrictCustDeadline, 
							NotifyCustDeadlineLeadTime, 
							NotifyOfferGoodUntilLeadTime, 
							DefaultPeriodType,
							UpdatedBy
						)
					VALUES
						(
							<cfqueryparam value="#this.settings.getLeadTime()#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#this.settings.getRestrictCustDeadline()#" cfsqltype="CF_SQL_BIT">,
							<cfqueryparam value="#this.settings.getNotifyCustDeadlineLeadTime()#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#this.settings.getNotifyOfferGoodUntilLeadTime()#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#this.settings.getDefaultPeriodType()#" cfsqltype="CF_SQL_INTEGER">,
							<cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
						)
				</cfquery>
				
				<cfcatch>
					<cftransaction action="ROLLBACK">
					<cfrethrow>
				</cfcatch>
			</cftry>
		</cftransaction>
		
	</cffunction>
	
</cfcomponent>