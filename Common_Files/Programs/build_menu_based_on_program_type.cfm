<cfparam name="FORM.Program_Type_ID" default="0">

<cfset FORM.Program_Type_ID = Session.Programs.Properties.CURRENT_PROGRAM_TYPE_ID>

<cfquery name="getOptionToMenuTabMappings" datasource="#application.datasource#">
SELECT     dbo.syscolumns.name, dbo.Program_Control_Panel_Options_MAP_TO_Menu_Tab.Menu_Tab_ID
FROM         dbo.syscolumns INNER JOIN
                      dbo.sysobjects ON dbo.syscolumns.id = dbo.sysobjects.id INNER JOIN
                      dbo.Program_Control_Panel_Options_MAP_TO_Menu_Tab ON 
                      dbo.syscolumns.name = dbo.Program_Control_Panel_Options_MAP_TO_Menu_Tab.Program_Control_Panel_Option_Column_Name
WHERE     (dbo.syscolumns.id IN
                          (SELECT     sysobjects.ID
                            FROM          sysobjects
                            WHERE      NAME = 'Program_Control_Panel_Options'))
</cfquery>

<cfset useLakebaseForgetProgramSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("program_control_panel_options")>
<cfif useLakebaseForgetProgramSettings>
	<cftry>
		<cfset getProgramSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("program_control_panel_options", {
				"programcontrol_panel_options_id" = "eq.#FORM.Program_Type_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetProgramSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetProgramSettings>
<cfquery name="getProgramSettings" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#FORM.Program_Type_ID#'
</cfquery>
</cfif>

<CF_List_Compare List1="#ValueList(getOptionToMenuTabMappings.name)#" List2="#getProgramSettings.ColumnList#" CaseSensitive="NO">


<cfquery name="getDistinctTabs" datasource="#application.datasource#">
	SELECT Distinct Menu_Tab_ID
	FROM Program_Control_Panel_Options_MAP_TO_Menu_Tab
	WHERE Program_Control_Panel_Option_Column_Name IN(#ListQualify(LC_Common, "'")#)
</cfquery>

<cfquery name="getTabsInfo" datasource="#application.datasource#">
	SELECT *
	FROM Menu_Tabs
	WHERE Menu_Tab_ID IN(#ValueList(getDistinctTabs.Menu_Tab_ID)#)
	order by Display_Order desc
</cfquery>



<script>
	parent.clearMenuTabs()
<cfoutput query="getTabsInfo">
	parent.addTabToMenu("#getTabsInfo.Tab_Caption#", "#getTabsInfo.Menu_Tab_ID#");
</cfoutput>
parent.addTabToMenu("Summary", "8");
	parent.initializeMenuTabs()
	parent.oMenuTable.rows(0).cells(0).fireEvent("onclick");
</script>	
