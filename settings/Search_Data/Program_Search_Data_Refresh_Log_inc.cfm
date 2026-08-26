<!---
Program_Search_Data_Refresh_Log_inc.cfm
--->

<CFPARAM NAME="form.startrow" DEFAULT="1">
<CFPARAM NAME="form.frompage" DEFAULT="1">
<cfparam name="form.page_len" default="50">

<cfset endrow =  form.startrow + form.page_len - 1 />

<cfquery name="getProgramSearchDatRefreshLog" datasource="#application.datasource#">
	SELECT	*, DateDiff(ms, Start_Date, End_Date) / 1000.00 as Duration
	FROM	Program_Search_Data_Refresh_Log_Details
	<cfif isDefined("form.search_date") and IsDate(form.search_date)>
	WHERE	DateDiff(d, created_date, '#form.search_date#') = 0
	</cfif>
	ORDER BY Created_Date DESC
 </cfquery>

<cfif getProgramSearchDatRefreshLog.recordCount>
<table cellpadding="2" cellspacing="0" border="0" width="90%" CLASS="Maintable">
	<tr BGCOLOR="FFCE84">
		<td ID="header"><b>Run Date/Time</b></td>
		<td ID="header"><b>Refresh Type</b></td>
		<td ID="header"><b># of programs</b></td>
		<td ID="header"><b>Duration</b></td>
	</tr>
<cfoutput>
<cfloop query="getProgramSearchDatRefreshLog" startrow="#form.startrow#" endrow="#endrow#">
	<CFIF currentrow mod 2>
		<CFSET BG_COLOR = "white">
	<CFELSE>
		<CFSET BG_COLOR = "ccffcc">
	</CFIF>
	<tr bgcolor="#BG_COLOR#">
		<td>#DateFormat(Created_Date, "mm/dd/yyyy")# #TimeFormat(Created_Date, "hh:mm:ss tt")#</td>
		<td><cfif Full_Refresh eq 1>Full<cfelse>Incremental</cfif></td>
		<td>
			<!--- <cfif Full_Refresh eq 0>
				<a 
					href="javascript: NewWindow('Program_Search_Data_Refresh_Log_Programs.cfm?id=#Program_Search_Data_Refresh_Log_Detail_ID#', 'Program_Search_Data_Refresh_Log_Programs', 800, 400, 'yes', 'yes'); "						
					>
			</cfif> --->
			<cfif Full_Refresh eq 0>
				<a 
					href="javascript: getProgramList(#Program_Search_Data_Refresh_Log_Detail_ID#);"						
					>
			</cfif>
							
			#Number_Of_Programs#<cfif Full_Refresh eq 0></a></cfif></td>
		<td>#Duration# secs</td>
	</tr>
</cfloop>

<!--- ****************** PAGING ********************--->
<cfset maxrows =  form.page_len />
<cfset startrow =  form.startrow />
<cfset frompage =  form.frompage />

<br>
<table>
	<tr>
		<td>
		<CF_Next_Previous_For_Forms
			formname="SearchForm"
			query="getProgramSearchDatRefreshLog"
			maxpages="40"
			previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
			next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
			previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
			addparams="">
		</td>
	</tr>
</table>

</cfoutput>
<cfelse>
	<br><br>
	<b>No record found</b>
</cfif>