<HTML>
<HEAD>
<TITLE>Email ToDo List</TITLE>
<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">


<script language="JavaScript">
	<!--BEGIN Script
		function checkData (){
		        if (document.MyForm.email_address.value == "") {
		                alert("You must enter a valid e-mail address...")
		                document.MyForm.email_address.focus()
		                return false}
		}
	// -->
</script>
</HEAD>

<BODY>

<FORM action="todo_email_action.cfm" method="post" name="MyForm" onSubmit="return checkData();">
  <CENTER>
	<BR>
	<B>Email addresses of the recipient(s):</B><BR><BR>
	<TEXTAREA name="email_address" cols="51" rows="8"></TEXTAREA><BR>
	<I><B><FONT color="#FF0000">Use semi-colon ( ; ) to separate<BR>more than one addresses</FONT></B></I><BR>
	<BR>
	<INPUT name="" type="image" src="/images/email_button.gif">
    </CENTER>
</FORM>




</BODY>
</HTML>

