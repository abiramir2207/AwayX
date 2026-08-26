<!------ search_file.cfm ----->

<CFPARAM NAME="FORM.Start_date" DEFAULT="">
<CFPARAM NAME="FORM.End_date" DEFAULT="">
<cfparam name="FORM.startrow" 		default="1">
<CFPARAM NAME="FORM.frompage" 		DEFAULT="1">
<cfparam name="FORM.pageLength" 	default=10>

<cfif form.subcommand EQ "search-result">
	<cfset qSearch = crucibleFileManager.searchReportFiles(request.AccessStructure.user_id, form) />
	
	<!------ get the list of dates ----->
	<cfquery name="qGetDates" dbtype="query">
		SELECT	DISTINCT Crucible_Weekly_Report_ID, Weekly_Report_Date
		FROM	qSearch
		Order By Weekly_Report_Date, Crucible_Weekly_Report_ID
	</cfquery>
	
	<CFSET startrow=FORM.startrow>
	<CFSET frompage=FORM.frompage>
	<cf_Number_of_Rows maxrows="#FORM.pageLength#">
	<cfset endRow = startrow + MaxRows - 1	/>

</cfif>


<script language="JavaScript">

function searchDataFile()
{
	var oForm = document.all.frmCrucibleDataFileSearch;
	oForm.startrow.value = 1;
	oForm.frompage.value = 1;
	oForm.submit();
	return false;
}

</script>

<form name="frmCrucibleDataFileSearch" method="post" action="index.cfm?command=search">

<table cellpadding="2" cellspacing="0">
<tr>
<td>
<table cellpadding="1" cellspacing="0">
<tr>
<td>Date Range: </td>
<td>
<SPAN ID="SP_Start_date">
<CF_EASYDATE FORMNAME="frmCrucibleDataFileSearch" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
</SPAN>
</td>
<td>
<SPAN ID="SP_End_date">
<CF_EASYDATE FORMNAME="frmCrucibleDataFileSearch" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
</SPAN>
</td>
</tr>
</table>
</td>
<td>
<CF_smallLink 
	title = "search data file" 
	url = "##"
	parameters = "onClick=""javascript: return searchDataFile();"""
>
</td>
</tr>
</table>
<cfoutput>
<input type="Hidden" name="subcommand" value="search-result" />
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
</cfoutput>
</form>


<cfif form.subcommand EQ "search-result">	
	<table width="80%" bgcolor="#cccccc" cellpadding="2" cellspacing="1">
	<tr style="font-weight:bold;">
	<td width="40%">Data for the week of </td>
	<td>Download</td>
	</tr>
	<cfloop query="qGetDates" startrow="#StartRow#" endrow="#endRow#">	
	<tr bgcolor="#ffffff" valign="top">
	<td><cfoutput><strong>#DateFormat(Weekly_Report_Date, "mm/dd/yyyy")#</strong>&nbsp;</cfoutput></td>
	<td>
	<cfquery name="qGetFileNames" dbtype="query">
		SELECT	*
		FROM	qSearch
		WHERE	Crucible_Weekly_Report_ID = #Crucible_Weekly_Report_ID#
	</cfquery>
	<cfloop query="qGetFileNames">
	<cfset sDownloadFilePath = "#sAPP_Relative_Path#/#Weekly_Report_Folder#/#Folder_Name#.#sCompressed_File_Extension#" />
	<CF_smallLink 
		title = "download file" 
		url = "/GetDocument.cfm?FilePath=#sDownloadFilePath#"
	><cfif Position_Label NEQ ""> (<cfoutput>#Position_Label#</cfoutput>)</cfif><br>
	</cfloop>
	</td>
	</tr>
	</cfloop>
	<tr>
	<td colspan="100%" bgcolor="#ffffff">
	<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<CF_Next_Previous_For_Forms
		formname="frmCrucibleDataFileSearch"
		query="qGetDates"
		maxpages="30"
		previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
		next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
		previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
		addparams="">
	</DIV>
	</td>
	</tr>
	</table>
	
</cfif>