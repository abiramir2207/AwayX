
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generates the header/toc that is used in the Administration :: AwayX Data Integration help files							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<STYLE>
a:hover.prlink
	{
		text-decoration: none;
	}
</STYLE>

<TABLE CELLSPACING="3">
<TR>

<CFIF request.TemplateName EQ 'index.cfm'>
		<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD>
<CFELSE>
		<A HREF="index.cfm" onmouseover="javascript:change('View List')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'add.cfm'>
		<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD>
<CFELSE>
		<A HREF="add.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; Add to List')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'email.cfm'>
		<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD>
<CFELSE>
		<A HREF="email.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Email List')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD></A>
</CFIF>

<TD>

&nbsp; 



</TD>

</tr></table>