<cfquery name="getTabs" datasource="#application.datasource#">
	SELECT *
	FROM Menu_Tabs
</cfquery>

<cfset ListOfTabIds = ValueList(getTabs.Menu_Tab_ID)>
<cfset ListOfTabCaptions = ValueList(getTabs.Tab_Caption)>


<cfquery name="getOptions" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options_MAP_TO_Menu_Tab
	-- ORDER BY Menu_Tab_ID desc
</cfquery>

<form action="AssignOptionsToTabs_action.cfm" method="post" name="theForm" id="theForm">
<table>
	<TR>
		<TD>Option Variable</TD>
		<TD>Current Tab</TD>
		<TD>New Tab</TD>
		<TD>&nbsp;</TD>
	</TR>
	<cfoutput query="getOptions">
	<TR>
		<TD>#getOptions.Program_Control_Panel_Option_Column_Name#</TD>
		<TD>
			<cfif getOptions.Menu_Tab_ID NEQ 0>
				#listgetat(ListOfTabCaptions,listfind(ListOfTabIds, getOptions.Menu_Tab_ID,","))#
			<CFELSE>
			*
			</cfif>
		</TD>
		<TD>
			<CFSET X = getOptions.Menu_Tab_ID>
			<select name="Tab_Assignment_#CurrentRow#" id="Tab_Assignment_#CurrentRow#">
				<CFLOOP query="getTabs">
					<OPTION value="#getTabs.Menu_Tab_ID#"<cfif getTabs.Menu_Tab_ID EQ x> SELECTED</cfif>>#getTabs.Tab_Caption#</OPTION>
				</CFLOOP>
			</SELECT>
			<input type="hidden" name="Option_Filedname_#currentrow#" id="Option_Filedname_#currentrow#" value="#getOptions.Program_Control_Panel_Option_Column_Name#">
		</TD>
		<TD>
			<A onclick="theForm.submit()">SUBMIT</A>
		</TD>
	</TR>
	</cfoutput>
</table>
</form>

<hr>
<form action="AssignOptionsToTabs_newFieldAction.cfm" method="post" name="newFieldForm" id="newFieldForm">
<table>
	<TR>
		<TD>New Field</TD>
		<TD><input type="Text" name="newField"></TD>
		<TD><A onclick="newFieldForm.submit()">SUBMIT</A></TD>
	</TR>
</table>
</form>
