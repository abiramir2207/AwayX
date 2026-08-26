<CFQUERY NAME="deleteitem" datasource="#application.datasource#">
update todolist
	SET Status = 1
	WHERE todolist_id = '#FORM.itemtodeleteid#'</CFQUERY>
<CFLOCATION URL="todo_view.cfm">
