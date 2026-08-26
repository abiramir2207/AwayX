<cfparam name="Form.ActiveTemplateList" default="">

<!--- "_Template_Name_" is a part of the variable name which is being passed from the "checkbox" on the form page  --->
<cfset searchInputToken = "_Template_Name_">
<cfset LenInputToken = len(searchInputToken)>


<cftransaction>
	<cfquery name="qryDeleteTempTables" datasource="#application.datasource#">
		if object_id('tempdb..##TmpFirstParentID') is not null
		drop table ##TmpFirstParentID	

		if object_id('tempdb..##TemplateList') is not null				
		drop table ##TemplateList		
	</cfquery>
	
	<!--- Get First_parent_ID of the selected templates --->
	<cfquery name="qryGetFirstParentID" datasource="#application.datasource#">
		SELECT Program_Control_Panel_Options.First_parent_ID, ProgramControl_Panel_Options_id AS Current_Template_ID
		INTO ##TmpFirstParentID
		FROM Program_Control_Panel_Options
		<!--- Do not use "cfqueryparam", other wise "##TmpFirstParentID" will not be available in another query --->
		WHERE ProgramControl_Panel_Options_id IN (#Form.ActiveTemplateList#)
	</cfquery>
	
	<!--- Based on the First_parent_ID, get a list of all the revisions of the selected templates.
	Note: This list also includes the selected templates.
	--->
	<cfquery name="qryGetTemplateList" datasource="#application.datasource#">
		SELECT DISTINCT Program_Control_Panel_Options.First_parent_ID, ##TmpFirstParentID.Current_Template_ID, Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
		INTO ##TemplateList
		FROM Program_Control_Panel_Options
		INNER JOIN ##TmpFirstParentID
		ON ##TmpFirstParentID.First_parent_ID = Program_Control_Panel_Options.First_parent_ID
		AND Program_Control_Panel_Options.deleted = 0
	</cfquery>
	
	<!--- 
	Delete the records for the selected user profile and the selected templates (including the template revisions).
	Note: 
	1) We need to delete entries for the revisions of the template as the code needs to retroactively update these entries.
	2) Do not delete record based on just profileID because the inactive templates will not be in the form page and so those
	records will be deleted from the table. User still needs access to programs which are based on inactive templates.
	--->
	<cfquery name="qryGetTemplateList" datasource="#application.datasource#">
		DELETE FROM Profile_Forbidden_Template
		WHERE Profile_ID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#Profile_ID#" list="yes">)
		AND Template_ID IN
		(
		SELECT ProgramControl_Panel_Options_ID
		FROM ##TemplateList
		)
	</cfquery>

	<!--- Loop over the fields and insert into the table entries for all templates in single insert for each selected template --->	
	<cfloop collection = "#Form#" item = "FieldNames">
		<cfset FieldName = FieldNames>
		<cfset startPos = len(listGetAt(FieldName,1,"_")) + 1>
		<cfif mid(FieldName, startPos, LenInputToken) IS searchInputToken>
			<cfset LenFieldName = len(FieldName)>

			<cfset templateID = ListFirst(FieldName, "_")>
			<cfset forbidAccessType = ListLast(FieldName, "_")>
			
			<!--- Loop over the templates --->
			<cfloop list="#Form.ActiveTemplateList#" index="ID">
				
				<!--- If the template in the form is the same as template in the list of selected templates--->
				<cfif templateID eq ID>
					
					<!--- Loop over the list of selected profiles. (There could be one or more) --->
					<cfloop list="#Profile_ID#" index="profileID">
						<cfquery name="ForbiddenList" datasource="#application.datasource#">
							INSERT INTO Profile_Forbidden_Template
							(
								Profile_ID,
								Template_ID,
								Forbid_Access_Type,
								Forbid_Type
							)				
								SELECT 
									<cfqueryparam cfsqltype="cf_sql_integer" value="#profileID#">,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#templateID#">,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#forbidAccessType#">,
									<cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.forbidType#">
						</cfquery>
					</cfloop>
				</cfif>	
				
			</cfloop>			
		</cfif>
	</cfloop>
	
	<!--- RETROACTIVELY INSERT FOR  ALL REVISIONS OF THE TEMPLATES --->

	<!--- Loop over the list of selected profiles. (There could be one or more) --->
	<cfloop list="#Profile_ID#" index="profileID">
		<cfquery name="ForbiddenList" datasource="#application.datasource#">
			INSERT INTO Profile_Forbidden_Template
			(
				Profile_ID,
				Template_ID,
				Forbid_Access_Type,
				Forbid_Type
			)	
			
			SELECT #profileId#, ##TemplateList.ProgramControl_Panel_Options_ID,Profile_Forbidden_Template.Forbid_Access_Type,Profile_Forbidden_Template.Forbid_Type
			FROM Profile_Forbidden_Template
			INNER JOIN ##TemplateList
			ON Profile_Forbidden_Template.Template_ID = ##TemplateList.Current_template_ID				
			WHERE Profile_Forbidden_Template.Profile_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#profileID#">
			AND Profile_Forbidden_Template.deleted = 0
			AND ##TemplateList.Current_template_ID <> ##TemplateList.ProgramControl_Panel_Options_ID <!--- Ignore the parent record (selected templates)  --->
		</cfquery>
	</cfloop>
		
	<cfquery name="UpdateGeneralInformation" datasource="#application.datasource#">
		UPDATE Profiles_Settings
		SET Last_Changed_Date		= getdate(),
		    Last_Changed_User_ID	= '#request.accessStructure.User_ID#'		
	</cfquery>

</cftransaction>

<!---
Do not remove this line - Useful for debugging.
<cflocation url="profile_template.cfm?profileId=#Original_profile_Id#" addtoken="no">
--->

<script language="JavaScript">
self.close();
</script>