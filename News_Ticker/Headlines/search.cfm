<STYLE>
	input
		{
			font-size: 10px;
			font-family: Arial;
		}
</STYLE>


<DIV ALIGN="center">
<FORM ACTION="search_action.cfm" METHOD="post" TARGET="_blank">

<INPUT TYPE="hidden" NAME="google_query" VALUE="http://www.google.com/search?q=">
<INPUT TYPE="hidden" NAME="msn_query" VALUE="http://search.msn.com/results.asp?q=">

<TABLE CELLPADDING="0" CELLSPACING="0">
<TR>
	<TD><IMG SRC="/images/google_tiny.gif" WIDTH="15" HEIGHT="30" ALT="Select Google..." BORDER="0"></TD>
	<TD><INPUT TYPE="radio" NAME="search_engine" VALUE="1" CHECKED></TD>
	<TD><IMG SRC="/images/msn_tiny.gif" WIDTH="25" HEIGHT="25" ALT="Select MSN..." BORDER="0"></TD>
	<TD><INPUT TYPE="radio" NAME="search_engine" VALUE="0"></TD>
</TR>
<TR><TD COLSPAN="100%"><INPUT TYPE="text" NAME="question"><BR>
<INPUT TYPE="submit" VALUE="Search the Web"></TD></TR>
</TABLE>



</FORM>
</DIV>
