<HTML>
<HEAD>
<TITLE>ToDo List has been emailed...</TITLE>
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</HEAD>

<BODY>

<cfset useLakebaseFortodo_list = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("todolist")>
<cfif useLakebaseFortodo_list>
	<cftry>
		<cfset todo_list = application.oLakebase.toQuery(
			application.oLakebase.selectRows("todolist", {
				"users_id" = "eq.#request.AccessStructure.user_id#",
				"status" = "eq.0",
				"order" = "priority_level.desc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseFortodo_list = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFortodo_list>
<CFQUERY NAME="todo_list" datasource="#application.datasource#">
	SELECT *
	FROM todolist
	WHERE
		USERS_ID = '#request.AccessStructure.user_id#'
		AND
		Status = 0
	Order by
		Priority_Level desc
</CFQUERY>
</cfif>

<!--- <CFMAIL
	to="#Form.email_address#"
	from="#request.AccessStructure.User_Email#"
	subject="Todo List from #request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#" 
	type="html"> --->
<cfoutput>
<CF_EMAILWRAPPER
	to="#Form.email_address#"
	from="#request.AccessStructure.User_Email#"
	subject="Todo List from #request.AccessStructure.Name_First# #request.AccessStructure.Name_Last#" 
	type="html" 
	messagetype="1" 
	generatedby="3" 
	apparea="11" 
	userid="#request.AccessStructure.user_id#">
	<STYLE>
		TD{ font-family: Arial; font-size: 12px;}
	</STYLE>

	<table CELLPADDING="1" CELLSPACING="5" WIDTH="100%">
			<tr VALIGN="top">
				<TD style="border-bottom: solid 1px blue;"><FONT color="Red" size="+1" face="Times New Roman, Times, serif"><B>!</B></FONT></TD>
				<TD style="border-bottom: solid 1px blue;" WIDTH="100%"><B>Task</B></TD>
			</TR>
			<CFLOOP query="todo_list">
			<tr VALIGN="top">
				<TD>#todo_list.Priority_Level#</TD>
				<TD WIDTH="100%">#todo_list.listitem_text#</TD>
			</TR>
			</CFLOOP>
	</table>
<!--- </CFMAIL> --->
</CF_EMAILWRAPPER>
</cfoutput>


<CENTER>
  <BR><BR><BR><BR>
  <B>Returning to list...</B>
</CENTER>


 <script language="JavaScript">
	function seeya()
	{
		window.location.href="todo_view.cfm";
	}
	setTimeout('seeya()',3000); 
</script>




</BODY>
</HTML>
