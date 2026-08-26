<cfset useLakebaseFordeleteitem = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("todolist")>
<cfif useLakebaseFordeleteitem>
	<cftry>
		<cfset application.oLakebase.updateRows("todolist",
			{
				"todolist_id" = "eq.#FORM.itemtodeleteid#"
			},
			{
				"status" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteitem = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteitem>
<CFQUERY NAME="deleteitem" datasource="#application.datasource#">
update todolist
	SET Status = 1
	WHERE todolist_id = '#FORM.itemtodeleteid#'</CFQUERY>
</cfif>
<CFLOCATION URL="todo_view.cfm">
