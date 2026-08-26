<!------ success_display.cfm ----->
<CFOUTPUT>
<cfparam name="maxRows" 	default="4">
<cfset cntr = 1>
<cfif isDefined("qSource") AND  isDefined("fieldName")>
<TABLE border="0" cellspacing="3" cellpadding="3" WIDTH="100%" BGCOLOR="white">	
	<COLGROUP>
	<COL SPAN="#maxRows#" WIDTH="#Evaluate(100/maxRows)#%"></COL>
	</COLGROUP>
	<TR>
	<CFLOOP query="qSource">
		<TD NOWRAP BGCOLOR="eeeeee">#Evaluate("#fieldName#")#</TD>
		<CFIF cntr mod maxRows><CFELSE></TR><TR></CFIF>
		<CFSET cntr = cntr + 1>
	</CFLOOP>
	<cfloop index="i" from="#Evaluate(cntr mod maxRows)#" to="#maxRows#">
	<TD></TD>
	</CFLOOP>
	</TR>	
</TABLE>	
</cfif>
</CFOUTPUT>