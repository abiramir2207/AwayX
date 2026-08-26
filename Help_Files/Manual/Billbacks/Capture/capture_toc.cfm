
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generates the header/toc that is used in the contract creation help files						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<TABLE CELLSPACING="3" BORDER="0" width="100%">
<TR>

<CFIF request.TemplateName EQ 'index.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD>
<CFELSE>
	<A HREF="index.cfm" onmouseover="javascript:change('Main Page')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'page2.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD>
<CFELSE>
	<A HREF="page2.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; Payee')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'page3.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD>
<CFELSE>
<CFOUTPUT>
	<A HREF="page3.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; Programs, Items and #Application.RebateLabel#s')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD></A>
</CFOUTPUT>
</CFIF>
<CFIF request.TemplateName EQ 'page4.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>4</B></FONT></TD>
<CFELSE>
	<A HREF="page4.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; Request Approval')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>4</B></FONT></TD></A>
</CFIF>

<td>&nbsp; </td>
</TR>
</TABLE>
