<cfif isDefined("form.ID")>

<cfquery name="SetToNotDominant" datasource="#application.datasource#">
UPDATE Program_Control_Panel_Options
SET IsDominant = 0, 
	DeletedBy = '#request.AccessStructure.User_ID#'
WHERE ProgramControl_Panel_Options_ID= #ID#
</cfquery>

<cflocation url="index.cfm">

</cfif>