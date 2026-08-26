<CFPARAM NAME="PageTitle" DEFAULT="">
<CFPARAM NAME="PRID" DEFAULT="">

<!--- <CFOUTPUT>#PRID#</CFOUTPUT> --->

<TABLE BORDER="0" CELLPADDING="2" CELLSPACING="0" WIDTH="100%">
<TR>
	<TD ALIGN="left" BGCOLOR="Navy" BACKGROUND="/images/gradient.jpg" WIDTH="715" HEIGHT="25">
	<CFIF PRID NEQ "">
		<SPAN STYLE="color:white; font-size:14px; font-weight: bold;">Edit Pricing Rule: <CFOUTPUT>#ucase(PageTitle)#</CFOUTPUT></SPAN>
	<CFELSE>
		<SPAN STYLE="color:white; font-size:14px; font-weight: bold;">Create Pricing Rule: <CFOUTPUT>#ucase(PageTitle)#</CFOUTPUT></SPAN>
	</CFIF>
	</TD>
</TR>
</TABLE>
<BR>

