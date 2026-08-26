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


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>View List</title>
</head>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="10" TOPMARGIN="5">

<CFINCLUDE template="todo_header.cfm">


<table CELLPADDING="5" CELLSPACING="0" CLASS="maintable" WIDTH="100%">
	<CFOUTPUT QUERY="todo_list">
		<tr bgcolor="#IIf(CurrentRow Mod 2, DE('D7FFD1'), DE('FFFFFF'))#">
			<TD VALIGN="top"><input type="checkbox" ONCLICK="deleteItem(this)" VALUE="#todo_list.todolist_id#"></TD>
			<TD VALIGN="top">#Priority_Level#</TD>
			<TD VALIGN="top" WIDTH="100%">#todo_list.listitem_text#</TD>
		</TR>
	</CFOUTPUT>
</table>
<script>
	function deleteItem(itemCheckbox){
		if(confirm("Press OK To Delete Item")){
			document.all.itemtodeleteid.value = itemCheckbox.value;
			MyForm.submit();
		}
		else {
			itemCheckbox.checked = false;
		}
	}
</script>

<cfif todo_list.recordcount EQ 0>
	<BR><BR><BR><div ALIGN="center" STYLE="color: red; font-size: 20px;">No Items</div>
</cfif>

<FORM ACTION="todo_delete.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<INPUT TYPE="hidden" NAME="itemtodeleteid" VALUE="">
</form>

</body>
</html>




