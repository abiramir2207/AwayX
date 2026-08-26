<cfcomponent hint="crucble.crucibleFileManager" extends="components.Base">

	<cffunction name="init" output="false" returntype="components.crucble.crucibleFileManager">
	
		<cfreturn this />
		
	</cffunction>

	<cffunction name="getWeeklyReport" output="false" returntype="query">
	
		
		<cfset useLakebaseForqGetCrucibleWeeklyReport = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("crucible_weekly_report")>
<cfif useLakebaseForqGetCrucibleWeeklyReport>
	<cftry>
		<cfset qGetCrucibleWeeklyReport = application.oLakebase.toQuery(
			application.oLakebase.selectRows("crucible_weekly_report", {
				"deleted" = "eq.0",
				"is_current" = "eq.1",
				"limit" = "1",
				"select" = "crucible_weekly_report_id,weekly_report_folder,weekly_report_date"
			}), "crucible_weekly_report_id,weekly_report_folder,weekly_report_date"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCrucibleWeeklyReport = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCrucibleWeeklyReport>
<cfquery name="qGetCrucibleWeeklyReport" datasource="#application.datasource#">
			SELECT	Top 1 Crucible_Weekly_Report.Crucible_Weekly_Report_ID, Crucible_Weekly_Report.Weekly_Report_Folder,
					Crucible_Weekly_Report.Weekly_Report_Date
					
			FROM	Crucible_Weekly_Report
			
			WHERE	Crucible_Weekly_Report.Deleted = 0
			AND		Crucible_Weekly_Report.Is_Current = 1
		</cfquery>
</cfif>
		
		<cfreturn qGetCrucibleWeeklyReport />
	
	</cffunction>
		
	<cffunction name="getReportFiles" output="false" returntype="query">
	
		<cfargument name="weeklyReportId" type="numeric" required="true" />
		<cfargument name="userId" type="string" required="true" />
		
		<cfquery name="qGetCrucibleReportFiles" datasource="#application.datasource#">
			SELECT	Crucible_Weekly_Report.Crucible_Weekly_Report_ID, Crucible_Weekly_Report.Weekly_Report_Folder,
					Crucible_Weekly_Report.Weekly_Report_Date,
					Crucible_Report_User.Folder_Name
					
			FROM	Crucible_Weekly_Report
			
			INNER JOIN Crucible_Report_User
			ON		Crucible_Report_User.Deleted = 0
			AND		Crucible_Report_User.Crucible_Weekly_Report_ID = Crucible_Weekly_Report.Crucible_Weekly_Report_ID
			<cfif arguments.userId EQ "">
			AND		1=2
			<cfelse>
			AND		Crucible_Report_User.User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			
			WHERE	Crucible_Weekly_Report.Deleted = 0
			AND		Crucible_Weekly_Report.Is_Current = 1
			AND		Crucible_Weekly_Report.Crucible_Weekly_Report_ID = <cfqueryparam value="#arguments.weeklyReportId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfreturn qGetCrucibleReportFiles />
	
	</cffunction>
	
	<cffunction name="searchReportFiles" output="false" returntype="query">
	
		<cfargument name="userId" type="string" required="true" />
		<cfargument name="search" type="struct" required="false" default="#StructNew()#" />
		
		<cfset this.search = arguments.search>
		
		<cfquery name="qSearchReportFiles" datasource="#application.datasource#">
			SELECT	DISTINCT Crucible_Weekly_Report.Crucible_Weekly_Report_ID, Crucible_Weekly_Report.Weekly_Report_Folder,
					Crucible_Weekly_Report.Weekly_Report_Date,
					Crucible_Report_User.Folder_Name, User_Positions.Position_Label
					
			FROM	Crucible_Weekly_Report
			
			INNER JOIN Crucible_Report_User
			ON		Crucible_Report_User.Deleted = 0
			AND		Crucible_Report_User.Crucible_Weekly_Report_ID = Crucible_Weekly_Report.Crucible_Weekly_Report_ID
			<cfif arguments.userId EQ "">
			AND		1=2
			<cfelse>
			AND		Crucible_Report_User.User_ID = <cfqueryparam value="#arguments.userId#" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			
			LEFT JOIN Crucible_Report_Position
			ON		Crucible_Report_Position.Deleted = 0
			AND		Crucible_Report_Position.Crucible_Weekly_Report_ID = Crucible_Weekly_Report.Crucible_Weekly_Report_ID
			AND		Crucible_Report_Position.Folder_Name = Crucible_Report_User.Folder_Name
			
			LEFT JOIN User_Positions
			ON		User_Positions.Deleted = 0
			AND		Crucible_Report_Position.Crucible_Weekly_Report_ID IS NOT NULL
			AND		((User_Positions.Service_Zone_ID IS NULL AND Crucible_Report_Position.Service_Zone_ID IS NULL) OR (User_Positions.Service_Zone_ID = Crucible_Report_Position.Service_Zone_ID))
			AND		((User_Positions.Service_Region_ID IS NULL AND Crucible_Report_Position.Service_Region_ID IS NULL) OR (User_Positions.Service_Region_ID = Crucible_Report_Position.Service_Region_ID))
			AND		((User_Positions.Service_Market_ID IS NULL AND Crucible_Report_Position.Service_Market_ID IS NULL) OR (User_Positions.Service_Market_ID = Crucible_Report_Position.Service_Market_ID))
			
			
			
			WHERE	Crucible_Weekly_Report.Deleted = 0
			AND		Crucible_Weekly_Report.Weekly_Latest = 1
			<cfif Super.variableExist("this.search.Start_date", "")>
			AND		DateDiff(d, '#this.search.Start_Date#', Crucible_Weekly_Report.Weekly_Report_Date) >= 0
			</cfif>
			<cfif Super.variableExist("this.search.End_date", "")>
			AND		DateDiff(d, Crucible_Weekly_Report.Weekly_Report_Date, '#this.search.End_date#') >= 0
			</cfif>
			
			Order by Weekly_Report_Date
			
		</cfquery>
		
		<cfreturn qSearchReportFiles />
	
	</cffunction>	
	
	<cffunction name="getCrucibleFileSettings" output="false" returntype="query">
	
		<cfset useLakebaseForqGetCrucibleFileSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("crucible_extract_folder_setting")>
<cfif useLakebaseForqGetCrucibleFileSettings>
	<cftry>
		<cfset qGetCrucibleFileSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("crucible_extract_folder_setting", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetCrucibleFileSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetCrucibleFileSettings>
<cfquery name="qGetCrucibleFileSettings" datasource="#application.datasource#">
			SELECT	*
			FROM	Crucible_Extract_Folder_Setting
		</cfquery>
</cfif>
		
		<cfreturn qGetCrucibleFileSettings />
	
	</cffunction>
	
	
</cfcomponent>