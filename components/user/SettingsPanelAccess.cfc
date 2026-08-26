<!--- 
##  called from settings panel (settings_frame_mainwindow.cfm) to get access level
##  
##  Module is derived from the template name without the extension...ie. /settings/Access_Rights/brokers_search_form.cfm = brokers_search_form
##  for index.cfm files, go up one dir and add _index...ie. /GL_Code/Upload_Gl_Code/index.cfm = Upload_Gl_Code_index
##  mws --->

<cfcomponent hint="settings Panel Access" extends="components.Base">

	<cffunction name="init" output="false">
		<cfreturn this />
	</cffunction>

	
	<cffunction name="getSPAccess" output="false">	
		<cfargument name="maintenance" type="boolean" required="false" default="0" />
		<cfargument name="profileId" type="numeric" required="false" default="0" />

		<cfquery name="local.qlocal.getAccesslevel" datasource="#application.datasource#">
			SELECT	tbl1.module_name, 
					CASE 
						WHEN tbl2.Settings_Panel_Access_Modules_ID IS NULL THEN 0
						ELSE 1
					END AS Show
			FROM Settings_Panel_Access_Modules tbl1
					LEFT JOIN Settings_Panel_Access_Modules_Profiles tbl2 ON tbl1.Settings_Panel_Access_Modules_ID = tbl2.Settings_Panel_Access_Modules_ID
					<cfif arguments.maintenance eq 1>
						AND tbl2.Profiles_ID = <cfqueryparam value='#arguments.profileId#'>
					<cfelse>
						AND tbl2.Profiles_ID = <cfqueryparam value='#request.Accessstructure.Profiles_ID#'>
					</cfif>
		</cfquery>

		<cfset local.getAccess = {}>
		<cfoutput query="local.qlocal.getAccesslevel">
			<cfset local.ShowLink = local.qlocal.getAccesslevel.Show>
			<cfset local.temp     = structinsert(local.getAccess, module_name, local.ShowLink)>			
		</cfoutput>

		<cfreturn local.getAccess />
	</cffunction>

	
	<cffunction name="getCheckSPAccessAllowed" output="false" returntype="boolean">
		<cfset local.IsSPAccessAllowed = 0>

		<cfif request.AccessStructure.User_Rights_ID eq "9999">
			<cfset local.IsSPAccessAllowed = 1>
		<cfelse>
			<cfquery name="local.qGetCheckSPAccessAllowed" datasource="#application.datasource#">
				SELECT COUNT(1) AS Record_Counter
				  FROM Settings_Panel_Access_Modules tbl1
						INNER JOIN Settings_Panel_Access_Modules_Profiles tbl2 ON tbl1.Settings_Panel_Access_Modules_ID = tbl2.Settings_Panel_Access_Modules_ID
				 WHERE tbl2.Profiles_ID = <cfqueryparam value='#request.Accessstructure.Profiles_ID#'>
			</cfquery>

			<cfif local.qGetCheckSPAccessAllowed.Record_Counter gt 0>
				<cfset local.IsSPAccessAllowed = 1>
			</cfif>
		</cfif>

		<cfreturn local.IsSPAccessAllowed />
	</cffunction>
	
</cfcomponent>