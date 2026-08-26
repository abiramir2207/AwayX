<!--- RETROACTIVELY UPDATE ALL REVISIONS OF THIS TEMPLATE --->
<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
<cfset allRevsOfTemplate = templateManager.getThisTemplateAllParentsID(FORM.ID) />
<cfset allRevsOfTemplateCount = listLen(allRevsOfTemplate) />

<cfset searchInputToken = "_Profile_Settings_">
<cfset LenInputToken = len(searchInputToken)>

<cfquery name="tmpTable" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##tmp_ProfileValues') IS NOT NULL
	DROP TABLE ##tmp_ProfileValues

	create table ##tmp_ProfileValues(
		Profile_ID int,
		Forbid_Access_Type int,
		Forbid_Type int
)
</cfquery>

<cfloop collection = #Form# item = "FieldNames">
	<cfset FieldName = FieldNames>
	<cfset startPos = len(listGetAt(FieldName,1,"_")) + 1>
	<cfif mid(FieldName, startPos, LenInputToken) IS searchInputToken>
		<cfset ProfileID = ListFirst(FieldName, "_")>
		<cfset forbidAccessType = ListLast(FieldName, "_")>

		<cfquery name="ForbiddenList" datasource="#application.datasource#">
			INSERT INTO ##tmp_ProfileValues(Profile_ID, Forbid_Access_Type, Forbid_Type)
			SELECT
			<cfqueryparam cfsqltype="cf_sql_integer" value="#ProfileID#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#forbidAccessType#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.forbidType#">
		</cfquery>
	</cfif>
</cfloop>


<cfquery name="qGetThisTemplateAllParentsID" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##tmp_TemplateList') IS NOT NULL
	DROP TABLE ##tmp_TemplateList

	SELECT		PCP.Programcontrol_Panel_Options_ID
	INTO ##tmp_TemplateList
	FROM 		Program_Control_Panel_Options PCP_Latest
	INNER JOIN 	Program_Control_Panel_Options PCP ON PCP_Latest.First_Parent_ID = PCP.First_Parent_ID
	WHERE	 	PCP_Latest.Programcontrol_Panel_Options_ID = #FORM.ID#
	AND 		PCP.Deleted = 0
</cfquery>


<cfquery name="FinalTmp" datasource="#application.datasource#">
	IF OBJECT_ID('tempdb..##tmp_FinalTmp') IS NOT NULL
	DROP TABLE ##tmp_FinalTmp

	SELECT  Template.Programcontrol_Panel_Options_ID, Profiles.Profile_ID, Profiles.Forbid_Access_Type, Profiles.Forbid_Type
	INTO ##tmp_FinalTmp
	FROM ##tmp_TemplateList Template
	INNER JOIN ##tmp_ProfileValues Profiles
	ON 1 = 1
</cfquery>

<cfquery name="Updaterecords" datasource="#application.datasource#">
<!---DELETE COMBINATIONS WHICH NO LONGER EXISTS--->
	DELETE FROM Profile_Forbidden_Template
	WHERE Template_ID IN (SELECT Programcontrol_Panel_Options_ID FROM ##tmp_TemplateList)
	AND NOT EXISTS (
		SELECT 1
		FROM ##tmp_FinalTmp FTmp
		WHERE FTmp.Programcontrol_Panel_Options_ID = Profile_Forbidden_Template.Template_ID
		AND FTmp.Profile_ID = Profile_Forbidden_Template.Profile_ID
		AND FTmp.Forbid_Access_Type = Profile_Forbidden_Template.Forbid_Access_Type
	)

<!---UPDATE COMBINATIONS WHICH DO EXISTS--->
UPDATE Profile_Forbidden_Template
SET Forbid_Type = FTmp.Forbid_Type
FROM Profile_Forbidden_Template
INNER JOIN ##tmp_FinalTmp FTmp
ON  FTmp.Programcontrol_Panel_Options_ID = Profile_Forbidden_Template.Template_ID
AND FTmp.Profile_ID = Profile_Forbidden_Template.Profile_ID
AND FTmp.Forbid_Access_Type = Profile_Forbidden_Template.Forbid_Access_Type

<!---INSERT COMBINATIONS WHICH DOES NOT EXIST.--->
	INSERT INTO Profile_Forbidden_Template ( Template_ID, Profile_ID, Forbid_Access_Type, Forbid_Type)
	SELECT Programcontrol_Panel_Options_ID, Profile_ID, Forbid_Access_Type, Forbid_Type
	FROM ##tmp_FinalTmp FTmp
	WHERE  NOT EXISTS (
		SELECT 1
		FROM Profile_Forbidden_Template PFT
		WHERE PFT.Template_ID = FTmp.Programcontrol_Panel_Options_ID
		AND PFT.Profile_ID = FTmp.Profile_ID
		AND PFT.Forbid_Access_Type =  FTmp.Forbid_Access_Type
	)

</cfquery>



<cfset pageName = "profile_settings_matrix">
<cfinclude template="Next_Page.cfm" />