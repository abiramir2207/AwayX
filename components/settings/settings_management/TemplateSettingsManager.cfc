
<cfcomponent hint="settings management">
	
	<cffunction name="init" output="false" >
		<cfreturn this />
	</cffunction>

	<cffunction name="getTemplateSettings" output="false"  returntype="struct">
		<cfargument name="Generic_Type"  type="string" required="true" default="">
		<cfargument name="ID" required="false" default=0 type="numeric" />
		
		<cfset templateSettings = StructNew()>
		<cfif arguments.ID EQ 0 >
			<cfquery name="qGetSettings" datasource="#application.datasource#">
				select distinct Setting_Name,ISNULL(Settings_Template_Display.Setting_Display_Value, 1) as Setting_Display_Value
				from Settings_List
				left join Settings_Template_Display 
				on Settings_Template_Display.Setting_ID = Settings_List.Setting_ID 
				and Settings_Template_Display.Generic_Type= '#arguments.Generic_Type#'
				and Settings_Template_Display.Excluded_First_Parent_ID IS NULL
				and Settings_Template_Display.deleted = 0
				where Settings_List.setting_Type = 'Template'
			</cfquery>
			<cfloop query="qGetSettings">
				<cfset a = StructInsert(templateSettings, "#setting_name#", "#Setting_Display_Value#")>
			</cfloop>
		<cfelse>
			<cfquery name="qGetExceptionSettingID" datasource="#application.datasource#">
				select distinct Setting_ID
				from Settings_Template_Display
				where deleted = 0
				and Excluded_First_Parent_ID  = (select First_Parent_ID 
				from Program_Control_Panel_Options
				where ProgramControl_Panel_Options_ID = #ID#)
				and Generic_Type= '#Generic_Type#'
			</cfquery>
			<cfquery name="qGetSettings" datasource="#application.datasource#">
				select distinct Setting_Name,Settings_List.Setting_ID,ISNULL(Settings_Template_Display.Setting_Display_Value, 1) as Setting_Display_Value
				from Settings_List
				left join Settings_Template_Display 
				on Settings_Template_Display.Setting_ID = Settings_List.Setting_ID 
				and Settings_Template_Display.Generic_Type= '#Generic_Type#'
				and Settings_Template_Display.Excluded_First_Parent_ID IS NULL
				and Settings_Template_Display.deleted = 0
				where Settings_List.setting_Type = 'Template'
			</cfquery>
			<cfif qGetExceptionSettingID.recordcount GT 0>
				<cfloop query="qGetSettings">
					<cfset Display_Value = qGetSettings.Setting_Display_Value>
					<cfloop query="qGetExceptionSettingID">
						<cfif qGetSettings.Setting_ID EQ  qGetExceptionSettingID.Setting_ID>
							<cfif qGetSettings.Setting_Display_Value EQ 0>
								<cfset Display_Value = 1>
							<cfelse>
								<cfset Display_Value = 0>
							</cfif>

						</cfif>
					</cfloop>
					<cfset a = StructInsert(templateSettings, "#setting_name#", "#Display_Value#")>
				</cfloop>
			<cfelse>
				<cfloop query="qGetSettings">
					<cfset a = StructInsert(templateSettings, "#setting_name#", "#Setting_Display_Value#")>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfreturn templateSettings>
	</cffunction>
	
	<cffunction name="getSettingIDs" output="false"  returntype="struct">
		<cfargument name="TemplatePageSequence"  type="string" required="false" default="1">
		<cfset SettingIDs = StructNew()>
		<cfquery name="qGetSettingIDs" datasource="#application.datasource#">
			select Setting_Name, Setting_ID
			from Settings_List
			<cfif TemplatePageSequence eq 2>
				where TemplatePageSequence = 2
			<cfelse>
				where Setting_Type = 'Template'
			</cfif>
		</cfquery>

		<cfloop query="qGetSettingIDs">
			<cfset a = StructInsert(SettingIDs, "#setting_name#", "#Setting_ID#")>
		</cfloop>
		
		<cfreturn SettingIDs>
	</cffunction>

	<cffunction name="getException_Active" output="false"  returntype="struct">
		<cfargument name="Generic_Type"  type="string" required="true" default="">
		<cfargument name="TemplatePageSequence"  type="string" required="false" default="1">

		<cfset Exception_Active_Value = StructNew()>
		<cfset useLakebaseForqGetExceptionSettingIDs = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("settings_template_display")>
<cfif useLakebaseForqGetExceptionSettingIDs>
	<cftry>
		<cfset qGetExceptionSettingIDs = application.oLakebase.toQuery(
			application.oLakebase.selectRows("settings_template_display", {
				"deleted" = "eq.0",
				"excluded_first_parent_id" = "not.is.null",
				"generic_type" = "eq.#arguments.Generic_Type#",
				"select" = "setting_id"
			}), "setting_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetExceptionSettingIDs = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetExceptionSettingIDs>
<cfquery name="qGetExceptionSettingIDs" datasource="#application.datasource#">
			select distinct Setting_ID
			from Settings_Template_Display
			where deleted = 0
			and Excluded_First_Parent_ID IS NOT NULL
			and Generic_Type= '#arguments.Generic_Type#'
		</cfquery>
</cfif>
		
		<cfif qGetExceptionSettingIDs.recordcount eq 0>
			<cfquery name="qGetException" datasource="#application.datasource#">
				select Setting_Name
				from Settings_List
				where Deleted = 0
				<cfif TemplatePageSequence eq 2>
					and TemplatePageSequence = 2
				<cfelse>
					and setting_Type = 'Template'
				</cfif>
			</cfquery>
			<cfloop query="qGetException">
				<cfset a = StructInsert(Exception_Active_Value, "#qGetException.setting_name#", "0")>
			</cfloop>
		<cfelse>
			<cfset AllExceptionSettingIDs = ValueList(qGetExceptionSettingIDs.Setting_ID,",")>
			<cfquery name="qGetException_Active" datasource="#application.datasource#">
				select Setting_Name
				from Settings_List
				where Deleted = 0
				<cfif TemplatePageSequence eq 2>
					and TemplatePageSequence = 2
				<cfelse>
					and setting_Type = 'Template'
				</cfif>
				and Setting_ID in (#AllExceptionSettingIDs#)
			</cfquery>
			<cfquery name="qGetException_inActive" datasource="#application.datasource#">
				select Setting_Name
				from Settings_List
				where Deleted = 0
				<cfif TemplatePageSequence eq 2>
					and TemplatePageSequence = 2
				<cfelse>
					and setting_Type = 'Template'
				</cfif>
				and Setting_ID not in (#AllExceptionSettingIDs#)
			</cfquery>
			<cfloop query="qGetException_Active">
				<cfset a = StructInsert(Exception_Active_Value, "#qGetException_Active.setting_name#", "1")>
			</cfloop>
			<cfloop query="qGetException_inActive">
				<cfset a = StructInsert(Exception_Active_Value, "#qGetException_inActive.setting_name#", "0")>
			</cfloop>
		</cfif>
		
		<cfreturn Exception_Active_Value>
	</cffunction>

	<cffunction name="getTemplates" output="false"  returntype="query">
		<cfargument name="Generic_Type"  type="string" required="true" default="">
		
		<cfset useLakebaseForqGetTemplates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForqGetTemplates>
	<cftry>
		<cfset qGetTemplates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"deleted" = "eq.0",
				"isdominant" = "eq.1",
				"generic_type" = "eq.#arguments.Generic_Type#",
				"active" = "eq.1",
				"order" = "created_type.asc",
				"select" = "created_type,first_parent_id"
			}), "created_type,first_parent_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetTemplates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetTemplates>
<cfquery name="qGetTemplates" datasource="#application.datasource#">
			SELECT Created_Type, First_Parent_ID
			FROM 	Program_Control_Panel_Options
			WHERE 	Deleted = 0
			AND 	IsDominant = 1 
			AND 	Program_Control_Panel_Options.Generic_Type = '#arguments.Generic_Type#'
			AND 	Active =1
			ORDER BY Created_Type asc
		</cfquery>
</cfif>

		<cfreturn qGetTemplates>
	</cffunction>

	<cffunction name="getSettingsException" output="false"  returntype="query">
		<cfargument name="Generic_Type"  type="string" required="true" default="">
		<cfargument name="Setting_ID" type="numeric" required="false" default="0" />
		<cfquery name="qGetSettingsException" datasource="#application.datasource#">
			SELECT 	Excluded_First_Parent_ID
			FROM 	Settings_Template_Display
			WHERE	Setting_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Setting_ID#" />
			AND 	Excluded_First_Parent_ID IS NOT NULL
			AND Settings_Template_Display.deleted =0
			AND Generic_Type = '#Generic_Type#'
		</cfquery>
		<cfreturn qGetSettingsException />
	</cffunction>

	<cffunction name="getSettingsExceptionTBL" output="false"  returntype="query">
		<cfargument name="Generic_Type"  type="string" required="true" default="">
		<cfargument name="Setting_ID" type="numeric" required="false" default="0" />
		<cfargument name="SettingDisplayValueInTable" type="string" required="false" default="">
		<cfargument name="SettingDisplayValueInTableID" type="string" required="false" default="0">

		<cfquery name="qGetSettingsException" datasource="#application.datasource#">
			SELECT 	Excluded_First_Parent_ID
			FROM 	Settings_Template_Display
			WHERE 	Setting_Display_Value_InTable = '#arguments.SettingDisplayValueInTable#'
			AND   	Setting_Display_Value_InTable_ID = #arguments.SettingDisplayValueInTableID#
			AND 	Excluded_First_Parent_ID IS NOT NULL
			AND 	Settings_Template_Display.deleted =0
			AND 	Generic_Type = '#Generic_Type#'
		</cfquery>
		<cfreturn qGetSettingsException />
	</cffunction>

	<cffunction name="getMgmtSettingsExceptionValInTBL" output="false"  returntype="query">
		<cfargument name="Generic_Type"  type="string" required="true" default="">
		<cfargument name="ID" required="true" default=0 type="numeric" />
		<cfargument name="SettingDisplayValueInTable" type="string" required="true" default="">
		<cfargument name="FormIdColInTBL" type="string" required="true" default="">

		<cfquery name="MgmtSettingsExceptionValInTBL" datasource="#application.datasource#">
			select #arguments.SettingDisplayValueInTable#.#arguments.FormIdColInTBL# as MgmtSettingID, 
			#arguments.SettingDisplayValueInTable#.Setting_Display_Value as InTblVale,
			Settings_Template_Display.Setting_Display_Value as ExceptionVal --ISNULL(Settings_Template_Display.Setting_Display_Value, 1) as Setting_Display_Value
			from #arguments.SettingDisplayValueInTable#
			left join Settings_Template_Display on Program_Qualifications.SettingsManagement_ID = Settings_Template_Display.Setting_Display_Value_InTable_ID
			and Settings_Template_Display.deleted = 0
			and Settings_Template_Display.Setting_Display_Value_InTable = '#arguments.SettingDisplayValueInTable#'
			and Settings_Template_Display.Excluded_First_Parent_ID  = (select First_Parent_ID 
			from Program_Control_Panel_Options
			where ProgramControl_Panel_Options_ID = #ID#)
			and Generic_Type= '#Generic_Type#'
		</cfquery>			
		<cfreturn MgmtSettingsExceptionValInTBL />
	</cffunction>

	<cffunction name="getMgmtSettingsValInTBL" output="false"  returntype="struct">
		<cfargument name="Generic_Type"  type="string" required="true" default="">
		<cfargument name="ID" required="true" default=0 type="numeric" />
		<cfargument name="SettingDisplayValueInTable" type="string" required="true" default="">
		<cfargument name="FormIdColInTBL" type="string" required="true" default="">

		<cfset TemplateMgmtSettingsInTBL = StructNew()>

		<cfquery name="qMgmtSettingsValInTBL" datasource="#application.datasource#">
			select 	#arguments.SettingDisplayValueInTable#.#arguments.FormIdColInTBL# as MgmtSettingID, 
				#arguments.SettingDisplayValueInTable#.Setting_Display_Value as SettingValInTBL,
				Settings_Template_Display.Setting_Display_Value as ExceptionVal 
			from #arguments.SettingDisplayValueInTable#
			left join Settings_Template_Display on Program_Qualifications.SettingsManagement_ID = Settings_Template_Display.Setting_Display_Value_InTable_ID
			and Settings_Template_Display.deleted = 0
			and Settings_Template_Display.Setting_Display_Value_InTable = '#arguments.SettingDisplayValueInTable#'
			and Settings_Template_Display.Excluded_First_Parent_ID  = (select First_Parent_ID 
			from Program_Control_Panel_Options
			where ProgramControl_Panel_Options_ID = #ID#)
			and Generic_Type= '#Generic_Type#'
		</cfquery>
		<cfloop query="qMgmtSettingsValInTBL">
			<cfset Display_Value = qMgmtSettingsValInTBL.SettingValInTBL>
					
			<cfif len(qMgmtSettingsValInTBL.ExceptionVal) GT 0>
				<cfif qMgmtSettingsValInTBL.SettingValInTBL eq 0>
					<cfset Display_Value = 1>
				</cfif>
				<cfif qMgmtSettingsValInTBL.SettingValInTBL eq 1>
					<cfset Display_Value = 0>
				</cfif>
			</cfif>
					
			<cfset a = StructInsert(TemplateMgmtSettingsInTBL, "#qMgmtSettingsValInTBL.MgmtSettingID#", "#Display_Value#")>
		</cfloop>
			
		<cfreturn TemplateMgmtSettingsInTBL />
	</cffunction>

	<cffunction name="getProfileSettings" output="false"  returntype="struct">
		
		<cfset ProfileManagementSettings = StructNew()>
		<cfquery name="qGetProfileManagementSettings" datasource="#application.datasource#">
			select	distinct Setting_Name, ISNULL(Setting_Display_Value, 1) as Setting_Display_Value
			from	Settings_List
			where deleted = 0
			and setting_Type = 'Profile'
		</cfquery>
		
		<cfloop query="qGetProfileManagementSettings">
			<cfset a = StructInsert(ProfileManagementSettings, "#qGetProfileManagementSettings.setting_name#", "#qGetProfileManagementSettings.Setting_Display_Value#")>
		</cfloop>
		
		<cfreturn ProfileManagementSettings>
	</cffunction>

	<cffunction name="getProfileGroupApprovalTypeSettings" output="false"  returntype="query">
		<cfargument name="ThisApprovalType" type="string" required="true" default="0">
		
		<cfquery name="qgetProfileGroupApprovalTypeSettings" datasource="#application.datasource#">
			select	distinct Group_Labels_Approval_Group_Count, ISNULL(Setting_Display_Value, 1) as Setting_Display_Value
			from	Settings_List_Group_Approval_Type
			where 	ApprovalType = '#arguments.ThisApprovalType#'
		</cfquery>		
		
		<cfreturn qgetProfileGroupApprovalTypeSettings>
	</cffunction>

	<cffunction name="getTemplateMgmtSettingsSecPage" output="false"  returntype="struct">
		<cfargument name="Generic_Type"  type="string" required="true" default="">
		<cfargument name="ID" required="false" default=0 type="numeric" />
		
		<cfset templateMgmtSettingsSecPage = StructNew()>
		<cfif arguments.ID EQ 0 >
			<cfquery name="qTemplateMgmtSettingsSecPage" datasource="#application.datasource#">
				select distinct Setting_Name,ISNULL(Settings_Template_Display.Setting_Display_Value, 1) as Setting_Display_Value
				from Settings_List
				left join Settings_Template_Display 
				on Settings_Template_Display.Setting_ID = Settings_List.Setting_ID 
				and Settings_Template_Display.Generic_Type= '#arguments.Generic_Type#'
				and Settings_Template_Display.Excluded_First_Parent_ID IS NULL
				and Settings_Template_Display.deleted = 0
				where Settings_List.TemplatePageSequence = 2
			</cfquery>
			<cfloop query="qTemplateMgmtSettingsSecPage">
				<cfset a = StructInsert(templateMgmtSettingsSecPage, "#Setting_Name#", "#Setting_Display_Value#")>
			</cfloop>
		<cfelse>
			<cfquery name="qGetExceptionSettingID" datasource="#application.datasource#">
				select distinct Setting_ID
				from Settings_Template_Display
				where deleted = 0
				and Excluded_First_Parent_ID  = (select First_Parent_ID 
				from Program_Control_Panel_Options
				where ProgramControl_Panel_Options_ID = #ID#)
				and Generic_Type= '#Generic_Type#'
			</cfquery>
			<cfquery name="qTemplateMgmtSettingsSecPage" datasource="#application.datasource#">
				select distinct Setting_Name,Settings_List.Setting_ID,ISNULL(Settings_Template_Display.Setting_Display_Value, 1) as Setting_Display_Value
				from Settings_List
				left join Settings_Template_Display 
				on Settings_Template_Display.Setting_ID = Settings_List.Setting_ID 
				and Settings_Template_Display.Generic_Type= '#Generic_Type#'
				and Settings_Template_Display.Excluded_First_Parent_ID IS NULL
				and Settings_Template_Display.deleted = 0
				where Settings_List.TemplatePageSequence = 2
			</cfquery>
			<cfif qGetExceptionSettingID.recordcount GT 0>
				<cfloop query="qTemplateMgmtSettingsSecPage">
					<cfset Display_Value = qTemplateMgmtSettingsSecPage.Setting_Display_Value>
					<cfloop query="qGetExceptionSettingID">
						<cfif qTemplateMgmtSettingsSecPage.Setting_ID EQ  qGetExceptionSettingID.Setting_ID>
							<cfif qTemplateMgmtSettingsSecPage.Setting_Display_Value EQ 0>
								<cfset Display_Value = 1>
							<cfelse>
								<cfset Display_Value = 0>
							</cfif>
						</cfif>
					</cfloop>
					<cfset a = StructInsert(templateMgmtSettingsSecPage, "#setting_name#", "#Display_Value#")>
				</cfloop>
			<cfelse>
				<cfloop query="qTemplateMgmtSettingsSecPage">
					<cfset a = StructInsert(templateMgmtSettingsSecPage, "#setting_name#", "#Setting_Display_Value#")>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfreturn templateMgmtSettingsSecPage>
	</cffunction>
</cfcomponent>