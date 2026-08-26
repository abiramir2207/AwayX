<!----------------------------------------------------------------------------------
Name         :	planners_access_rights_action.cfm
Copyright    : 	(c) 2016 Blacksmith Applications, Inc.
Created Date : 	03/01/2016
Created By   : 	Anand Rao
Description  : 	The file contains all Planner profile management logic.
---------------------------------------------------------------------------------->
<cfloop query="getProfiles">
	<cfset LOOPCOUNT = getProfiles.profiles_id>

	<cfparam name="form.Planner_Create_#LOOPCOUNT#" 				default="0">
	<cfparam name="form.Planner_Margin_View_#LOOPCOUNT#" 			default="0">
	<cfparam name="form.Planner_Approval_Rights_#LOOPCOUNT#" 		default="0">
	<cfparam name="form.Marketing_Events_Create_#LOOPCOUNT#" 		default="0">
	<cfparam name="form.Planner_Product_Calendar_#LOOPCOUNT#" 		default="0">
	<cfparam name="form.Planner_Strategic_Guidelines_#LOOPCOUNT#" 	default="0">
	<cfparam name="form.NUC_Targets_Create_#LOOPCOUNT#" 			default="0">
	<cfparam name="form.Planner_Reassign_#LOOPCOUNT#" 				default="0">
	<cfparam name="form.Planner_Catalog_#LOOPCOUNT#" 				default="0">
	<cfparam name="form.Planner_Max_Total_Spend_#LOOPCOUNT#" 		default="0">
	<cfparam name="form.Planner_Target_Max_Overspend_#LOOPCOUNT#" 		default="0">
	<cfparam name="form.Planner_Target_Max_Slotting_Target_Increase_#LOOPCOUNT#" 		default="0">
	<cfparam name="form.Planner_Target_Approval_Dollar_#LOOPCOUNT#" 		default="0">
	
	<!--- AUDITING - CAPTURE ORIGINAL --->
	<cfquery name="variables.qOriginal" datasource="#application.datasource#">
		SELECT Profiles_Desc, PPS.*
		FROM Planner_Profiles_Settings  PPS
		INNER JOIN Profiles p ON PPS.profiles_id  = p.profiles_id 
		WHERE PPS.Profiles_ID = #loopCount# AND PPS.deleted = 0 and p.deleted = 0
	</cfquery>

	<cfquery name="Save_Data" datasource="#application.datasource#">
		DELETE
		FROM		Planner_Profiles_Settings
		WHERE		Profiles_ID = #LOOPCOUNT#;

		INSERT INTO
		Planner_Profiles_Settings
		(
			Profiles_ID,
			Planner_Create,
			Planner_Margin_View,
			Planner_Approval_Rights,
			Marketing_Events_Create,
			Planner_Product_Calendar,
			Planner_Strategic_Guidelines,
			NUC_Targets_Create,
			Planner_Reassign,
			Planner_Catalog,
			Planner_Max_Total_Spend,
			Planner_Target_Max_Overspend,
			Planner_Target_Max_Slotting_Target_Increase,
			Planner_Target_Approval_Dollar

		)
		VALUES
		(
			#LOOPCOUNT#,
			#form[ "Planner_Create_"               & LOOPCOUNT ]#,
			#form[ "Planner_Margin_View_"          & LOOPCOUNT ]#,
			#form[ "Planner_Approval_Rights_"      & LOOPCOUNT ]#,
			#form[ "Marketing_Events_Create_"      & LOOPCOUNT ]#,
			#form[ "Planner_Product_Calendar_"     & LOOPCOUNT ]#,
			#form[ "Planner_Strategic_Guidelines_" & LOOPCOUNT ]#,
			#form[ "NUC_Targets_Create_"           & LOOPCOUNT ]#,
			#form[ "Planner_Reassign_"             & LOOPCOUNT ]#,
			#form[ "Planner_Catalog_"             & LOOPCOUNT ]#,
			'#form[ "Planner_Max_Total_Spend_"      & LOOPCOUNT ]#',
			'#form[ "Planner_Target_Max_Overspend_"      & LOOPCOUNT ]#',
			'#form[ "Planner_Target_Max_Slotting_Target_Increase_"      & LOOPCOUNT ]#',
			'#form[ "Planner_Target_Approval_Dollar_"      & LOOPCOUNT ]#'
		)
	</cfquery>
	<!--- AUDITING - CAPTURE CHANGES --->
	<cfquery name="variables.qUpdated" datasource="#application.datasource#">
		SELECT Profiles_Desc, PPS.*
		FROM Planner_Profiles_Settings  PPS
		INNER JOIN Profiles p ON PPS.profiles_id  = p.profiles_id 
		WHERE PPS.Profiles_ID = #loopCount# AND PPS.deleted = 0 and p.deleted = 0
	</cfquery>
	<cfscript>
		variables.udf = createObject( "component", "components.udf" );
		variables.udf.WriteSettingsAudit( variables.qOriginal, variables.qUpdated, "Planner_Profiles_Settings", loopCount, "#variables.qUpdated.Profiles_Desc#", "Updated_Date,Updated_By,profiles_id,Planner_Profiles_Settings_ID" );
	</cfscript>
</cfloop>