<CFPARAM NAME="diThisPage" DEFAULT="#reportPage#">
<LINK Rel = "stylesheet" Type = "text/css" HREF = "/reportWriter/claimReport.css">
<!---- section for components --->
<CFSET cmpHandle = CreateObject("component", "components.reports.claimReport") />
<cfset cmpHandle.setReportTitles(claimReportList) />
<CFSET hWidth=150>
<CFOUTPUT>
	<TABLE border="0" width="550" cellspacing="0" cellpadding="1">
		<TR>
			<cfloop list="#claimReportList#" index="thisReport" delimiters=",">
				<TD ALIGN="center" id="td#Ucase(Left(trim(thisReport), 1))#" WIDTH="#hWidth#" <cfif trim(reportType) EQ trim(thisReport)>CLASS="foreground"<cfelse>CLASS="background" BGCOLOR="B9DCFF" onClick="javascript:window.location='#claimReportPage#?reportType=#thisReport#';this.className='foreground'"</cfif> NOWRAP ><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>#cmpHandle.getClaimReportTitle(trim(thisReport))#</nobr></font></B></TD>		
				<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="2" HEIGHT="2"></TD>
			</cfloop>	
		</TR>
	</TABLE>
	<BR>
</CFOUTPUT>
