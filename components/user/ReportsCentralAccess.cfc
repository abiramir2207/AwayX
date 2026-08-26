<cfcomponent hint="Reports Central Access" extends="components.Base">

	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<!--- This function returns a list of all reports with access details. 
		  Optionally, if a reportID is passed only that row is returned. --->
	
	<cffunction name="getRcAccess" output="false">
		<cfargument name="reportID" required="false" type="numeric" />
		<cfquery name="qGetAccesslevel" datasource="#application.datasource#">
			SELECT     	report_id, report_name, report_url, report_url_jscript, report_group,
						report_url_options, active, level_code, description, status
			FROM		view_full_report_data
			<cfif isdefined("arguments.reportID")>
			WHERE 		report_id = '#arguments.reportID#'
			</cfif>
		</cfquery>
		<cfreturn qGetAccesslevel />
	</cffunction>

	<!--- Get Reports; can filter if report_group is supplied --->	

	<cffunction name="getReports" output="false">
		<cfargument name="report_group" required="false" type="numeric" />
		<cfquery name="qGetReports" datasource="#application.datasource#">
			SELECT     	report_id, report_name, report_url, report_url_jscript, report_group,
						report_url_options, active, level_code, description, status
			FROM		view_full_report_data
			WHERE 		active = 1
			<cfif isdefined("arguments.report_group")>
			AND 		report_group = '#arguments.report_group#'
			</cfif>
		</cfquery>
		<cfreturn qGetReports />
	</cffunction>
	
	<!--- This function the specific level code for the requested report id	--->

	<cffunction name="getReportLevel" output="false">
		<cfargument name="reportID" required="true" type="numeric" />
		
		<cfparam name="rCode" default="0">
		
		<cfset useLakebaseForqGetReportLevel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_central_access")>
<cfif useLakebaseForqGetReportLevel>
	<cftry>
		<cfset qGetReportLevel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("report_central_access", {
				"reportid" = "eq.#arguments.reportID#",
				"select" = "level_code,"
			}), "level_code,"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetReportLevel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetReportLevel>
<cfquery name="qGetReportLevel" datasource="#application.datasource#">
			SELECT level_code,  
			FROM report_central_access
			WHERE reportID = '#arguments.reportID#'
		</cfquery>
</cfif>
		
		<cfif qGetReportLevel GT 0>
			<cfset rCode = qGetReportLevel.level_code />
		</cfif>
		<cfreturn rCode />
	</cffunction>
	
	<!--- This function returns a listing of Access Levels	--->
	
	<cffunction name="getRcaCodeList" output="false">
		<cfargument name="maint" default="0" type="numeric" required="false">
		<cfquery name="qGetRcaCodes" datasource="#application.datasource#">
			select level_code, description, status, custom, editable 
			from report_access_levels
			<cfif arguments.maint>
				where level_code <> 0
			</cfif>
		</cfquery>		
		<cfreturn qGetRcaCodes />
	</cffunction>
	
	<!--- Edit Report & Update Report_Central_Access --->
		<cffunction name="UpdateReport" output="false">
			<cfargument name="Report_ID" required="true" type="numeric" />
			<cfargument name="Report_Name" required="true" type="string" />
			<cfargument name="Report_Desc" required="true" type="string" />
			<cfargument name="Report_Author" required="true" type="string" />
			<cfargument name="Report_URL" required="true" type="string" />
			<cfargument name="Report_URL_Jscript" required="true" type="string" />
			<cfargument name="Report_URL_Options" required="true" type="string" />
			<cfargument name="Report_Group" required="true" type="numeric" />
			<cfargument name="Active" required="true" type="numeric" />
			<cfargument name="Level_Code" required="true" type="numeric"/>
			<cfargument name="User_ID" required="true" type="string" />
			
			<cfparam name="rCode" Default='0'>
			
			<cftransaction>
			<cfquery name="qUpdateReport" datasource="#application.datasource#">
				Update Reports
				Set Report_Name = '#Arguments.Report_Name#',
					Report_Desc = '#Arguments.Report_Desc#',
					Report_Author = '#Arguments.Report_Author#',
					Report_URL = '#Arguments.Report_URL#',
					Report_URL_Jscript = '#Arguments.Report_URL_Jscript#',
					Report_Url_Options = '#Arguments.Report_URL_Options#',
					Report_Group= '#Arguments.Report_Group#',
					Active = '#Arguments.Active#',
					LastUpdated = getdate(),
					Updated_UserID = '#Arguments.User_ID#'
				Where Report_ID = '#Arguments.Report_ID#'		
			</cfquery>
			
			<cfquery name="qUpdateReportAccess" datasource="#application.datasource#">
				Update Report_Central_Access
				Set Level_Code = '#Arguments.Level_Code#',
					LastUpdated = getdate(),
					Updated_UserID = '#Arguments.User_ID#'
				Where Report_ID = '#Arguments.Report_ID#'
			</cfquery>
			</cftransaction>
		<cfreturn rCode />
		</cffunction>
		
	<!--- Insert Report & Report_Central_Access --->
	
		<cffunction name="InsertReport" output="false">
			<cfargument name="Report_Name" required="true" type="string" />
			<cfargument name="Report_Desc" required="true" type="string" />
			<cfargument name="Report_Author" required="true" type="string" />
			<cfargument name="Report_URL" required="true" type="string" />
			<cfargument name="Report_URL_Jscript" required="true" type="string" />
			<cfargument name="Report_URL_Options" required="true" type="string" />
			<cfargument name="Report_Group" required="true" type="numeric" />
			<cfargument name="Active" required="true" type="numeric" />
			<cfargument name="Level_Code" required="true" type="numeric"/>
			<cfargument name="User_ID" required="true" type="string" />
			
			<cfparam name="rCode" Default='0'>
			
			<cftransaction>
				<cfquery name="qInsertReport" datasource="#application.datasource#">
				Insert INTO Reports (report_name, report_desc, report_url, report_author, report_group, active, report_url_options, report_url_jscript, Updated_UserID)
							Values('#arguments.report_name#','#arguments.report_desc#','#arguments.report_url#','#arguments.report_author#','#arguments.report_group#','#arguments.active#','#arguments.report_url_options#','#arguments.report_url_jscript#','#Arguments.User_ID#')
				</cfquery>
				
				<cfquery name="qGetReportID" datasource="#application.datasource#">
				Select top 1 report_ID from reports 
				where 	Report_Name = '#arguments.Report_Name#' AND
						Report_URL = '#arguments.Report_URL#' AND
						Report_Author = '#arguments.Report_Author#' 
				</cfquery>
				
				<cfif qGetReportID.RecordCount EQ 1>
				<cfquery name="qInsertReportAccess" datasource="#application.datasource#">
				Insert INTO Report_Central_Access (report_id,level_code)
											Values('#qGetReportID.Report_ID#','#arguments.Level_Code#')
				</cfquery>
				<cfelse>
					<cfset rCode = 1>
				</cfif>
			</cftransaction>
		<cfreturn rCode />
		</cffunction>
	
	<!--- Get Report Groups --->
		
		<cffunction name="getReportGroups" output="false">
			<cfargument name="filterdeleted" required="false" type="numeric" />
			<cfquery name="qGetReportGroups" datasource="#application.datasource#">
				SELECT     	group_id, group_label, group_icon, icon_used
				FROM		report_groups
				WHERE 1 = 1
				<cfif isdefined("arguments.includedeleted") EQ "NO">
				AND deleted <> 1
				</cfif>
			</cfquery>
			<cfreturn qGetReportGroups />
		</cffunction>

	<!--- Insert a Report Group --->
				
		<cffunction  name="InsertReportGroup" output="false">
			<cfargument name="Group_Label" required="true" type="string" />
			<cfargument name="Icon_Used" required="true" type="numeric" />
			<cfargument name="Group_Icon" required="true" type="string" />
			<cfargument name="User_ID" required="true" type="string" />
			
			<cfset useLakebaseForqInsertReportGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_groups")>
<cfif useLakebaseForqInsertReportGroup>
	<cftry>
		<cfset application.oLakebase.insertRow("report_groups", {
			"group_label" = "#Arguments.Group_Label#",
			"icon_used" = "#Arguments.Icon_Used#",
			"group_icon" = "#Arguments.Group_Icon#",
			"updated_userid" = "#Arguments.User_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForqInsertReportGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqInsertReportGroup>
<cfquery name="qInsertReportGroup" datasource="#application.datasource#">
				Insert Into Report_Groups (Group_Label,Icon_Used,Group_Icon,Updated_UserID)
								Values	 ('#Arguments.Group_Label#','#Arguments.Icon_Used#','#Arguments.Group_Icon#','#Arguments.User_ID#')
			</cfquery>
</cfif>
			
		</cffunction>
		
	<!--- Set the Deleted Flag on a Specific ReportGroup --->
		
		<cffunction name="DeleteReportGroup" output="false">
			<cfargument name="group_id" required="true" type="numeric" />
			
			<cfset useLakebaseForqDeleteReportGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_groups")>
<cfif useLakebaseForqDeleteReportGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("report_groups",
			{
				"group_id" = "eq.#arguments.group_id#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqDeleteReportGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqDeleteReportGroup>
<cfquery name="qDeleteReportGroup" datasource="#application.datasource#">
				Update Report_Groups
				Set Deleted = 1
				Where Group_ID = '#arguments.group_id#'
			</cfquery>
</cfif>
		</cffunction>

	<!--- Update Report Group Details --->
		
		<cffunction  name="UpdateReportGroup" output="false">
			<cfargument name="Group_ID" required="true" type="numeric" />
			<cfargument name="Group_Label" required="true" type="string" />
			<cfargument name="Icon_Used" required="true" type="numeric" />
			<cfargument name="Group_Icon" required="true" type="string" />
			<cfargument name="User_ID" required="true" type="string" />
		
			<cfset useLakebaseForqUpdateReportGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("report_groups")>
<cfif useLakebaseForqUpdateReportGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("report_groups",
			{
				"group_id" = "eq.#Arguments.Group_ID#"
			},
			{
				"group_label" = "#Arguments.Group_Label#",
				"icon_used" = "#Arguments.Icon_Used#",
				"group_icon" = "#Arguments.Group_Icon#",
				"lastupdated" = "#now()#",
				"updated_userid" = "#Arguments.User_ID#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqUpdateReportGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqUpdateReportGroup>
<cfquery name="qUpdateReportGroup" datasource="#application.datasource#">
				Update Report_Groups
				Set Group_Label = '#Arguments.Group_Label#',
					Icon_Used = '#Arguments.Icon_Used#',
					Group_Icon = '#Arguments.Group_Icon#',
					LastUpdated = getdate(),
					Updated_UserID = '#Arguments.User_ID#'
				Where Group_ID = '#Arguments.Group_ID#'
			</cfquery>
</cfif>
		</cffunction>
</cfcomponent>