
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
		<A HREF="index.cfm" onmouseover="javascript:change('Main Page')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'basics.cfm'>
		<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD>
<CFELSE>
		<A HREF="basics.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; Basics')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'rate.cfm'>
		<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD>
<CFELSE>
		<A HREF="rate.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Details')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'discount.cfm'>
		<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>4</B></FONT></TD>
<CFELSE>
		<A HREF="discount.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Summary')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>4</B></FONT></TD></A>
</CFIF>


</tr></table>