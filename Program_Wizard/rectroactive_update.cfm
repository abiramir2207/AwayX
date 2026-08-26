<!--- retroactiveley update old versions of the template --->
<cfset MainTableFieldsToUpdateLen = ArrayLen(MainTableFieldsToUpdate) />
<!------ If there are fields in this list go an update using the current template values ----->
<cfif MainTableFieldsToUpdateLen GT 0>
	<cfset thisTemplateDiffVersionIdList = templateManager.getThisTemplateAllParentsID(ID) />
		<cfquery name="qUpdateParentTemplate" datasource="#application.datasource#">
			UPDATE	Program_Control_Panel_Options
			SET		Active = Active <!------ This is just so that there is one first entry for set and the comma ----->
			<cfloop index="MainTableFieldIndex" from="1" to="#MainTableFieldsToUpdateLen#">
					, #MainTableFieldsToUpdate[MainTableFieldIndex][1]# = '#MainTableFieldsToUpdate[MainTableFieldIndex][2]#'
			</cfloop>
			WHERE	ProgramControl_Panel_Options_ID in (#thisTemplateDiffVersionIdList#)
			<!--- Dont use queryparam in the above query as thisTemplateDiffVersionIdList is a list --->
		</cfquery>
</cfif>