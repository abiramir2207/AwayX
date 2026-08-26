
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generates the header/toc that is used in the pricing rules help files							 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<TABLE CELLSPACING="3">
<TR>

<CFIF request.TemplateName EQ 'index.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD>
<CFELSE>
	<A HREF="index.cfm" onmouseover="javascript:change('Rule Information')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'page2.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD>
<CFELSE>
	<A HREF="page2.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;  Select Product')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'page3.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD>
<CFELSE>
	<A HREF="page3.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; Commodity Selections')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'page4.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>4</B></FONT></TD>
<CFELSE>
	<A HREF="page4.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; Options and Adjustments')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>4</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'page5.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>5</B></FONT></TD>
<CFELSE>
	<A HREF="page5.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; Review Pricing Rule')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>5</B></FONT></TD></A>
</CFIF>


</TR>
</TABLE>
