<CFIF NOT isDefined("ADI_IncludeFile")>
	<CFINCLUDE template="adiInclude.cfm">
</CFIF>

<CFPARAM NAME="adiThisPage" DEFAULT="#mainPage#">
<STYLE TYPE="text/css">
TD.remaining
	{
		border-bottom :		1px solid #31009C;
	}
TD.foreground
	{
		border-left :		1px solid #31009C;
		border-right :		1px solid #31009C;
		border-top :		1px solid #31009C;
	}
TD.background
	{
		border-left:		1px solid #FFFFFF;
		border-right:		1px solid #FFFFFF;
	}
A.tablink_back
	{
		color: 				#FFFFFF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:VISITED.tablink_back
	{
		color: 				#FFFFFF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:VISITED.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
.tablink_fore
	{
		color: 				#0000FF;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}

</STYLE>


<CFSET hWidth=200>
<CFOUTPUT>
<BR><BR>
<TABLE border="0" cellspacing="2" cellpadding="2" width="100%">
<COLGROUP>
</COLGROUP>
	<TR>
		<CFIF adiThisPage EQ mainPage>
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><font CLASS="tablink_fore">Commodity</font></B></TD>
			<!-----<TD CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore">Commodity</font></B></TD>------->
		<CFELSE>
			<TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><A HREF="#adiThisPage#" CLASS="tablink_back">Commodity</A></B></TD>
			<!-----<TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="#adiThisPage#" CLASS="tablink_back">Commodity</A></B></TD>------->
		</CFIF>
		<TD WIDTH="90%" CLASS="remaining">&nbsp;</TD>
		<!--------
		<CFIF diThisPage EQ "productSummary">		
			<TD CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore">Product Summary</font></B></TD>
		<CFELSE>
			<TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="#reportPage#?reportType=productSummary" CLASS="tablink_back">Product Summary</A></B></TD>
		</CFIF>
		
		<CFIF diThisPage EQ reportListPage>
			<TD CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<cfif savedReport>yes<cfelse>no</cfif>_small.gif" HSPACE="3"><font CLASS="tablink_fore">Saved Reports</font></B></TD>
		<CFELSEIF diThisPage EQ reportDetailsPage>
			<TD CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<cfif savedReport>yes<cfelse>no</cfif>_small.gif" HSPACE="3"><A HREF="#reportListPage#" CLASS="tablink_fore">Saved Reports</A></B></TD>
		<CFELSE>
			<TD CLASS="background" BGCOLOR="31009C" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<cfif savedReport>yes<cfelse>no</cfif>_small.gif" HSPACE="3"><A HREF="#reportListPage#" CLASS="tablink_back">Saved Reports</A></B></TD>
		</CFIF>
		-------------->
	</TR>
</TABLE>

<BR>
</CFOUTPUT>
