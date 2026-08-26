
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Generates the header/toc that is used in the contract creation help files						 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<TABLE CELLSPACING="3" BORDER="0" WIDTH="100%">
<TR>

<CFIF request.TemplateName EQ 'viewprogram.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD>
<CFELSE>
	<A HREF="viewprogram.cfm" onmouseover="javascript:change('View One Program')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>1</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'formulapricedetails.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD>
<CFELSE>
	<A HREF="formulapricedetails.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; Formula Price Details')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>2</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'programbuttons.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD>
<CFELSE>
	<A HREF="programbuttons.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Program Options')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>3</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'approvenew.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>4</B></FONT></TD>
<CFELSE>
	<A HREF="approvenew.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; Approving a New Program')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>4</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'approverevised.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>5</B></FONT></TD>
<CFELSE>
	<A HREF="approverevised.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Approving a Revised Program')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>5</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'margins.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>6</B></FONT></TD>
<CFELSE>
	<A HREF="margins.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;View Margins')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>6</B></FONT></TD></A>
</CFIF>

<CFIF request.TemplateName EQ 'tradeadjustment.cfm'>
	<TD BGCOLOR="Orange" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>7</B></FONT></TD>
<CFELSE>
	<A HREF="tradeadjustment.cfm" onmouseover="javascript:change('&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; #application.returned_customer_setting.Trade_Label# Adjustment')" onmouseout="javascript:change('')"><TD BGCOLOR="Blue" WIDTH="18" HEIGHT="18" ALIGN="center" STYLE="cursor: pointer;"><FONT COLOR="White" SIZE="2"><B>7</B></FONT></TD></A>
</CFIF>

<td>&nbsp; </td>

</TR>
</TABLE>
