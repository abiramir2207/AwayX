<cfloop index="FormFieldName" list="#Form.FieldNames#">
	
	<cfif left(FormFieldName, 14) EQ "TAB_ASSIGNMENT">
		<cfquery name="SaveAssignent" datasource="#application.datasource#">
		UPDATE Program_Control_Panel_Options_MAP_TO_Menu_Tab
			SET Menu_Tab_ID = #evaluate("#FormFieldName#")#
			WHERE Program_Control_Panel_Option_Column_Name = '#evaluate("Option_Filedname_#listgetat(FormFieldName,3,"_")#")#'
		</cfquery>
	</cfif>
</CFLOOP>
<cflocation url="AssignOptionsToTabs.cfm">