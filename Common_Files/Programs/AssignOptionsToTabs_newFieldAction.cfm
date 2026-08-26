<cfquery name="save" datasource="#application.datasource#">
	INSERT INTO Program_Control_Panel_Options_MAP_TO_Menu_Tab
	(Program_Control_Panel_Option_Column_Name,Menu_Tab_ID)
	VALUES
	('#FORM.newField#',0)
</cfquery>
<cflocation url="AssignOptionToTab.cfm">