<!------ displayZipCodeList.cfm ----->
<CFOUTPUT>
<cfparam name="FORM.sort_by" 	default="">
<cfparam name="FORM.sort_order" 	default="">

<cfparam name="showDelete" 	default="false">
<cfparam name="inputName" 	default="">
<cfparam name="skeyword" 	default="">

<script language="JavaScript">
	function setSort(sSortBy, sSortOrder)
	{
		var thisForm = document.#formName#;
		thisForm.sort_by.value = sSortBy;
		thisForm.sort_order.value = sSortOrder;
		thisForm.submit();
		return false;
	}
</script>

<cfparam name="pageLength" 	default="10">
<CFPARAM NAME="FORM.startrow" DEFAULT="1">
<CFPARAM NAME="FORM.frompage" DEFAULT="1">
<cf_Number_of_Rows maxrows=#pageLength#>
<cfif StartRow GT SourceQuery.RecordCount>
	<cfset FORM.startrow = 1>
	<cfset FORM.frompage = 1>
	<cf_Number_of_Rows maxrows=#pageLength#>
</cfif>
<CFIF SourceQuery.RecordCount GT 0>
<TABLE CELLPADDING="5" CELLSPACING="0" CLASS="MainTable" WIDTH="90%">
<CAPTION align="right" STYLE="font-weight:bold;font-size:11px;padding:1px;">## of records: #SourceQuery.RecordCount#</CAPTION>
<TR BGCOLOR="##ffce84">
	<CFIF showDelete><TD>
	<img bDelete="true" sMessage="delete all #skeyword# in this page" src="/images/scissor.gif" title="delete all #skeyword# in this page" border="0" onclick="deleteAll()" style="cursor: pointer;">
	</TD></CFIF>
	<CFSET Sort_Header_Name_List = "Postal Code,City,County,State,AreaCode,TimeZone,Market">
	<CFLOOP list="#Sort_Header_Name_List#" delimiters="," index="this_Header">
		<CFSET sortImage="">				
		<CFIF LCase(this_Header) EQ LCase(Form.SORT_BY)>
			<CFIF FORM.SORT_ORDER EQ "DESC">
				<CFSET New_Sort_Order="ASC">
				<CFSET sortImage="up_1.gif">
			<CFELSE>
				<CFSET New_Sort_Order="DESC">
				<CFSET sortImage="down_1.gif">
			</CFIF>
		<CFELSE>
			<CFSET New_Sort_Order="ASC">
		</CFIF>
		<TD ID="Header"><A HREF="##" onClick="javaScript: return setSort('#this_Header#', '#New_Sort_Order#');"><B>#this_Header#</B></A><CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></TD>
	</CFLOOP>
</TR>
<CFSET AlreadySelectedItems = "">
<CFLOOP QUERY="SourceQuery" startrow="#StartRow#" endrow="#Evaluate(StartRow + MaxRows - 1)#">
<TR BGCOLOR="#IIF(currentrow Mod 2, DE('FFFFFF'),DE('CCFFCC'))#">
	<CFIF showDelete>
	<TD STYLE="cursor: pointer;">
	<img bDelete="true" name="IMG_Delete_Scissor" src="/images/scissor.gif" title="delete this #skeyword#" border="0" onclick="deleteRow('#inputName#', '#ZIPCode#', '#skeyword#')" style="cursor: pointer;">
	</TD>
	</CFIF>
	<TD><A HREF="http://tiger.census.gov/cgi-bin/mapgen?lat=37.0000&lon=-96.0000&wid=50&ht=25&iwd=540&iht=380&mlat=#Latitude#&mlon=#Longitude#&on=&off=BACK&msym=smalldot&mlabel=#City#" onclick="NewWindow(this.href,'name','560','405','No', 'No');return false;">#ZIPCode#</A></TD>
	<TD>#City#</TD>
	<TD>#County#</TD>
	<TD>#State#	</TD>
	<TD>#AreaCode#</TD>
	<TD>#TimeZone#</TD>
	<TD>#Market_Name#&nbsp;</TD>
</TR>
</CFLOOP>
</TABLE>
<INPUT NAME="sort_by" TYPE="HIDDEN" VALUE="#FORM.sort_by#">
<INPUT NAME="sort_order" TYPE="HIDDEN" VALUE="#FORM.sort_order#">
<INPUT NAME="startrow" TYPE="HIDDEN" VALUE="#FORM.startrow#">
<INPUT NAME="frompage" TYPE="HIDDEN" VALUE="#FORM.frompage#">
<DIV STYLE="font-size: 12px; color: Red;">
	<CF_Next_Previous_For_Forms
	formname="#formName#"
	query="SourceQuery"
	maxpages="40"
	previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
	next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
	previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
	addparams="">
</DIV>
<CFELSE>
	<BR>
	<FONT SIZE="2"><B>NO POSTAL CODE FOUND</B></FONT>	
</CFIF>
</CFOUTPUT>