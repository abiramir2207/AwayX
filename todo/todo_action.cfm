<CFIF trim(todo_item_text) EQ "">
	<CFLOCATION URL="todo_entry.cfm" ADDTOKEN="No">
</CFIF>



<CFQUERY NAME="todo_save" datasource="#application.datasource#">

INSERT INTO todolist
(Users_ID,Listitem_Text, Priority_Level)
VALUES
('#request.AccessStructure.User_ID#', <cfqueryparam value="#FORM.todo_item_text#" cfsqltype="CF_SQL_VARCHAR">, '#FORM.Priority_Level#')</CFQUERY>

<!--- 
<script>
this.close()
</script>
 --->


<CFOUTPUT>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">window.location.href = 'todo_view.cfm?id=#createuuid()#';</SCRIPT>
</CFOUTPUT>