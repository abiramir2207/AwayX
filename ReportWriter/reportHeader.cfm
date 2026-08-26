<CFINCLUDE TEMPLATE="/get_access_profile.cfm">


<CFIF NOT IsDefined("reportInclude")>
	<CFINCLUDE TEMPLATE="reportInclude.cfm">
</CFIF>

<CFPARAM NAME="diThisPage" DEFAULT="#reportPage#">
<STYLE TYPE="text/css">
.no_access
	{
		color:gray;
	}
TD.foreground
	{
		border-left :		1px solid Gray;
		border-right :		1px solid Gray;
		border-top :		1px solid Gray;
		color: 				Red;
	}
TD.background
	{
		border-left:		1px solid Gray;
		border-right:		1px solid Gray;
		border-top :		1px solid Gray;
		border-bottom:		1px solid Gray;
		color: 				White;
		cursor:				hand;
	}
TD.Filler
	{
		border-left:		1px solid White;
		border-bottom:		1px solid Gray;
		color: 				White;
	}
A.tablink_back, A:Hover.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_back
	{
		color: 				Black;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
A:visited.tablink_fore
	{
		color: 				Red;
		font-family:		Arial;
		font-size :			11px; 
		font-weight:		bold;
		text-decoration:	none;
	}
</STYLE>

<cfset savedReport=false>

<CFQUERY NAME="q_getSavedReportCount" datasource="#application.datasource#">
SELECT count(Report_Type_ID) as ReportCount
FROM	Report_Type
</CFQUERY>
<CFIF q_getSavedReportCount.recordCount GT 0>
	<CFIF q_getSavedReportCount.ReportCount GT 0>
		<cfset savedReport=true>
	</CFIF>
</CFIF>

<CFSET hWidth=150>
<CFOUTPUT>
<TABLE border="0" width="775" cellspacing="0" cellpadding="1">
	<TR>
		
		<!------------------------------------------------------
		Program Summary
		------------------------------------------------------->
		
		<CFIF diThisPage EQ "programSummary">
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Program Summary</nobr></font></B></TD>
		<CFELSE>
			<A HREF="#reportPage#?reportType=programSummary" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="#reportPage#?reportType=programSummary" CLASS="tablink_back"><nobr>Program Summary</nobr></A></B></TD></A>
		</CFIF>
		<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		
		<!------------------------------------------------------
		Product Summary
		------------------------------------------------------->
		
		<CFIF diThisPage EQ "productSummary">		
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Product Summary</nobr></font></B></TD>
		<CFELSE>
			<A HREF="#reportPage#?reportType=productSummary" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="#reportPage#?reportType=productSummary" CLASS="tablink_back"><nobr>Product Summary</nobr></A></B></TD></A>
		</CFIF>
		<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		
				<!--- New program search --->		
		<CFIF diThisPage EQ "invoiceprogramSummary">
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Invoice Program Summary</nobr></font></B></TD>
		<CFELSE>
			<CFIF (Get_Profile_Settings.Report_Scheduler EQ 1 or Get_Profile_Settings.Reports_Access_Level gt 2) AND application.returned_customer_setting.customer_keyword NEQ "Heinz">
				<A HREF="#reportPage#?reportType=invoiceprogramSummary" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="#reportPage#?reportType=invoiceprogramSummary" CLASS="tablink_back"><nobr>Invoice Program Summary</nobr></A></B></TD></A>
			<cfelse>
				<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="cccccc" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Invoice Program Summary</nobr></font></B></TD>
			</CFIF>
		</CFIF>
		<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		
		<!--- New product search --->		
		<CFIF diThisPage EQ "invoiceproductSummary">
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Invoice Product Summary</nobr></font></B></TD>
		<CFELSE>
			<CFIF (Get_Profile_Settings.Report_Scheduler EQ 1 or Get_Profile_Settings.Reports_Access_Level gt 2) AND application.returned_customer_setting.customer_keyword NEQ "Heinz">
				<A HREF="#reportPage#?reportType=invoiceproductSummary" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="#reportPage#?reportType=invoiceproductSummary" CLASS="tablink_back"><nobr>Invoice Product Summary</nobr></A></B></TD></A>
			<cfelse>
				<TD WIDTH="#hWidth#" class="foreground" BGCOLOR="cccccc" ALIGN="center" NOWRAP ><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Invoice Product Summary</nobr></font></B></TD>
			</CFIF>
		</CFIF>
		<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		 
		 
		<!------------------------------------------------------
		Product / Program Margin
		------------------------------------------------------->
		<CFIF diThisPage EQ "Product_Based_Margin_Analysis">		
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Margin Analysis</nobr></font></B></TD>
		<CFELSE>
			<A HREF="#reportMarginAnalysisPage#" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/yes_small.gif" HSPACE="3"><A HREF="#reportMarginAnalysisPage#" CLASS="tablink_back"><nobr>Margin Analysis</nobr></A></B></TD></A>
		</CFIF>
		<TD CLASS="Filler"><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1"></TD>
		
		<!------------------------------------------------------
		Saved Reports
		------------------------------------------------------->
		
		<CFIF diThisPage EQ reportListPage>
			<TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<cfif savedReport>yes<cfelse>no</cfif>_small.gif" HSPACE="3"><font CLASS="tablink_fore"><nobr>Saved Reports</nobr></font></B></TD>
		<CFELSEIF diThisPage EQ reportDetailsPage>
			<A HREF="#reportListPage#" CLASS="tablink_fore"><TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<cfif savedReport>yes<cfelse>no</cfif>_small.gif" HSPACE="3"><A HREF="#reportListPage#" CLASS="tablink_fore"><nobr>Saved Reports</nobr></A></B></TD></A>
		<CFELSEIF diThisPage EQ MarginReportDetailsPage>
			<A HREF="#reportListPage#" CLASS="tablink_fore"><TD WIDTH="#hWidth#" CLASS="foreground" BGCOLOR="ffffff" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<cfif savedReport>yes<cfelse>no</cfif>_small.gif" HSPACE="3"><A HREF="#reportListPage#" CLASS="tablink_fore"><nobr>Saved Reports</nobr></A></B></TD></A>
		<CFELSE>
			<A HREF="#reportListPage#" CLASS="tablink_back"><TD WIDTH="#hWidth#" CLASS="background" BGCOLOR="B9DCFF" ALIGN="center" NOWRAP><B><IMG src="/images/tabs/<cfif savedReport>yes<cfelse>no</cfif>_small.gif" HSPACE="3"><A HREF="#reportListPage#" CLASS="tablink_back"><nobr>Saved Reports</nobr></A></B></TD></A>
		</CFIF>		
		
		<TD WIDTH="90%" CLASS="Filler">&nbsp;</TD>
	</TR>
</TABLE>

<BR>
</CFOUTPUT>
