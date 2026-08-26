<!--- The code on this file was originally on "settings\margin_targets\index.cfm", but is being used on CFINCLUDE, as
this logic needs to be used on "common_files\ExportAll.cfm" for csv file creation.
--->
<cfparam name="costvariableslist" default="">

<cfset useLakebaseForgetTargetStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseForgetTargetStatus>
	<cftry>
		<cfset getTargetStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "program_margin_target_enabled,pm_lastupdated_date,pm_lastupdated_userid"
			}), "program_margin_target_enabled,pm_lastupdated_date,pm_lastupdated_userid"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetTargetStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetTargetStatus>
<cfquery name="getTargetStatus" datasource="#application.datasource#">
	SELECT program_margin_target_enabled, PM_LastUpdated_Date, PM_LastUpdated_UserId
	FROM General_Settings
</cfquery>
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfif appSettings.getlocalcostvariables() eq 1>
<cfset useLakebaseForgetcostvariables = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("cost_sequence")>
<cfif useLakebaseForgetcostvariables>
	<cftry>
		<cfset getcostvariables = application.oLakebase.toQuery(
			application.oLakebase.selectRows("cost_sequence", {
				"deleted" = "eq.0",
				"order" = "cost_sequence_order.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetcostvariables = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetcostvariables>
<cfquery name="getcostvariables" datasource="#application.datasource#">
select * from
cost_sequence
WHERE	Deleted = 0
ORDER BY Cost_Sequence_Order
</cfquery>
</cfif>
<cfif getcostvariables.recordcount GT 0>
<cfset costvariableslist = valuelist(getcostvariables.cost_sequence_order)>
<cfset costvariablesnames = valuelist(getcostvariables.cost_sequence_name)>
</cfif>
</cfif>

<cfset mt.status = getTargetStatus.program_margin_target_enabled>

<cfif mt.status EQ 1>
	<cfset mt.status_text = "On">
	<cfset mt.color = "green">
	<cfset mt.color_checktext = "red">
</cfif>

<cfset approvalGroupType = CreateObject("component", "components.settings.ApprovalGroupManager").getGroupTypeInfo() />
<cfquery name="getAllCodes" datasource="#application.datasource#">
	SELECT 	#approvalGroupType.IDField# AS ID, #approvalGroupType.NameField# AS Name,
	Target_Margin,
	Target_Margin_Operator,
	Target_Case_Rate,
	Target_Case_Rate_UOM,
	ISNULL(Spend_Dollar, 0) as Spend_Dollar
	 <cfif listlen(costvariableslist) GT 0>
	 ,group_local_costs.*
	 </cfif>
	,Target_Margin_ListPrice
	FROM 	#approvalGroupType.tableName#
	 <cfif listlen(costvariableslist) GT 0>
	left join group_local_costs on
	group_local_costs.group_id = #approvalGroupType.tableName#.#approvalGroupType.IDField#
	</cfif>
	WHERE 	Deleted = 0
			<cfif approvalGroupType.prodHierLevel GT 0>
			AND Product_Hierarchy_Level = #approvalGroupType.prodHierLevel#
			</cfif>
	ORDER BY #approvalGroupType.NameField#
</cfquery>
