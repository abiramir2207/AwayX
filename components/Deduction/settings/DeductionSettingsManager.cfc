<cfcomponent hint="Deduction Settings Manager" extends="components.Base">

	<cfset this.settings = CreateObject("component","components.deduction.settings.DeductionSettings").init() />
		
	<cffunction name="init" output="false" returntype="components.deduction.settings.DeductionSettingsManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="get" output="false" returntype="components.deduction.settings.DeductionSettings">
	
		<cfargument name="loadSettings" type="numeric" required="false" default="1">
		
		<cfif arguments.loadSettings>			
			<cfquery name="qGetSettings" datasource="#application.datasource#">
				SELECT	Deduction_External_Settings.*,
						_Users.Name_First + ' ' + _Users.Name_Last AS UpdatedByFullName
				FROM	Deduction_External_Settings
						LEFT JOIN _Users
						ON
						_Users.Deleted = 0
						AND
						_Users.User_ID = Deduction_External_Settings.Deduction_Settings_Updated_By										
			</cfquery>
			<cfloop query="qGetSettings">
			
				<!------ 1 ----->
				<cfset this.settings.setDDNewAddReminderAfterDays(DD_New_Add_Reminder_After_Days) />
				<cfset this.settings.setUpdatedBy(Deduction_Settings_Updated_By) />
				<cfset this.settings.setUpdatedByUserName(UpdatedByFullName) />
				<cfset this.settings.setUpdatedOn(Deduction_Settings_Updated_On) />
			</cfloop>
		
		</cfif>
		<cfreturn this.settings />
		
	</cffunction>
	
	<cffunction name="save" output="false">
		<cftransaction action="BEGIN">
			<cftry>
				<!------ UPDATE CURRENT ----->
				<cfquery name="qUpdateSettings" datasource="#application.datasource#">
					UPDATE	Deduction_External_Settings
					SET		DD_New_Add_Reminder_After_Days = <cfqueryparam value="#this.settings.getDDNewAddReminderAfterDays()#" cfsqltype="CF_SQL_INTEGER">,
							Deduction_Settings_Updated_By = <cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">,
							Deduction_Settings_Updated_On = GetDate()
					SELECT * 
					FROM Deduction_External_Settings
				</cfquery>
				
				<!------ INSERT NEW ----->
				<!--- DEV NOTE: DAA; D15356 - ADDED TO CREATE THE RECORD IF NOTHING EXISTS FOR qUpdateSettings --->
				<cfif NOT qUpdateSettings.recordcount>
					<cfquery name="qInsertSettings" datasource="#application.datasource#">
						INSERT INTO Deduction_External_Settings
							(
								DD_New_Add_Reminder_After_Days
								,Deduction_Settings_Updated_By
								,Deduction_Settings_Updated_On
							)
						VALUES
							(
								<cfqueryparam value="#this.settings.getDDNewAddReminderAfterDays()#" cfsqltype="CF_SQL_INTEGER">
								,<cfqueryparam value="#this.settings.getUpdatedBy()#" cfsqltype="CF_SQL_VARCHAR">
								,GetDate()
							)
					</cfquery>
				</cfif>
				
				<cfcatch>
					<cftransaction action="ROLLBACK">
					<cfrethrow>
				</cfcatch>
			</cftry>
		</cftransaction>
		
	</cffunction>
	
	<!--- Dev Note: KAL; 7821 --->
	<cffunction name="DD_Status_Control" output="false">
		<cfargument name="profiles_ID" required="Yes" />
		<cfquery name="qDD_Status_Control" datasource="#application.datasource#">
			SELECT 	DD_Status_ID 
			FROM	DD_Status_Profile_Control 
			WHERE	IS_Checked = 1	AND 	Deleted = 0 
			AND		Profiles_ID = <cfqueryparam value="#arguments.profiles_ID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfset DD_Status_toHide = ValueList(qDD_Status_Control.DD_Status_ID,",") />
		<cfreturn DD_Status_toHide />	
	
	</cffunction>
	
</cfcomponent>