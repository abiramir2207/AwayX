<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>To Do List</title>
	<script language="JavaScript">
	<!--BEGIN Script
		function checkData (){
	        if (document.MyForm.todo_item_text.value == "") {
                alert("You haven't entered any text...")
                document.MyForm.todo_item_text.focus()
                return false}
		}
	// -->
</script>

</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="10" TOPMARGIN="5">

<FORM ACTION="todo_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm" onSubmit="return checkData()">

<A HREF="javascript:self.close();">
<IMG SRC="../images/todo_close_window.gif" WIDTH="18" HEIGHT="18" TITLE="" BORDER="0" ALIGN="absmiddle"> close window 
</A>
&nbsp;&nbsp;&nbsp;
<A HREF="todo_view.cfm">
<IMG SRC="../images/todo_view_item.gif" WIDTH="15" HEIGHT="16" TITLE="" BORDER="0" ALIGN="absmiddle"> view todo list
</A>
<HR>




	<table ALIGN="center" WIDTH="100%" HEIGHT="85%" BORDER="0">
		<TR>
			<TD WIDTH="100%" HEIGHT="90%">
				<B>Enter Item Text:</B><BR>
				<TEXTAREA COLS="51" ROWS="8" NAME="todo_item_text" ID="todo_item_text"></TEXTAREA>
					
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD ROWSPAN="2"><B>Select Priority:</B>&nbsp;&nbsp;&nbsp;&nbsp;</TD>
						<TD ALIGN="center">Low</TD>
						<TD ALIGN="center"></TD>
						<TD ALIGN="center">Med</TD>
						<TD ALIGN="center"></TD>
						<TD ALIGN="center">High</TD>
					</TR>
					<TR>
						<TD ALIGN="center"><INPUT TYPE="radio" NAME="Priority_Level" VALUE="1"></TD>
						<TD ALIGN="center"><INPUT TYPE="radio" NAME="Priority_Level" VALUE="2"></TD>
						<TD ALIGN="center"><INPUT TYPE="radio" NAME="Priority_Level" VALUE="3" CHECKED></TD>
						<TD ALIGN="center"><INPUT TYPE="radio" NAME="Priority_Level" VALUE="4"></TD>
						<TD ALIGN="center"><INPUT TYPE="radio" NAME="Priority_Level" VALUE="5"></TD>
					</TR>
					</TABLE>
				<input type="submit" VALUE="save text">
			</TD>
		</TR>
	</table>

	

</form>

<script>
	document.all.todo_item_text.focus()
</script>

</body>
</html>
