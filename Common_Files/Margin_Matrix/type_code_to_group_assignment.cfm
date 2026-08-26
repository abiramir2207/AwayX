
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get all of the margin codes																	 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="getMarginGroupTypeCodes" datasource="#application.datasource#">
	SELECT *
	FROM Margin_Group_Type_Codes
	WHERE Margin_Group_ID = '#URL.Group_ID#'
	AND Deleted = 0
</CFQUERY>
<CFSET ExistingTypeCodes = valuelist(getMarginGroupTypeCodes.Type_Code_Desc_ID)>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Get the nargin codes that have been assigned													 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="getOccupiedMarginGroupTypeCodes" datasource="#application.datasource#">
	SELECT *
	FROM Margin_Group_Type_Codes
	WHERE Margin_Group_ID != '#URL.Group_ID#'
	AND Deleted = 0
</CFQUERY>



<CFSET ExcludedTypeCodes = valuelist(getOccupiedMarginGroupTypeCodes.Type_Code_Desc_ID)>

<CFQUERY NAME="getAllTypeCodes" datasource="#application.datasource#">
	SELECT *
	FROM Type_Code_Desc
	WHERE Deleted = 0 <CFIF getOccupiedMarginGroupTypeCodes.Recordcount GT 0>AND Type_Code_Desc_ID NOT IN(#replace(listqualify(ExcludedTypeCodes, "'", ","), '"', "'", "ALL")#)</CFIF>
	Order BY Type_Code_Desc
</CFQUERY>


<CFIF getAllTypeCodes.recordcount GT 0>
	
	<cfset bgcolor = "ffffff">
	<TABLE BORDER="0" ALIGN="center" CELLPADDING="0" CELLSPACING="2">
		<TR>
			<CFSET Mycounter=0>
			<CFOUTPUT QUERY="getAllTypeCodes">
			<cfif listfind(ExistingTypeCodes,getAllTypeCodes.Type_Code_Desc_ID, ",")>
			<TD><cfif listfind(ExistingTypeCodes,getAllTypeCodes.Type_Code_Desc_ID, ",")><IMG SRC="/images/yes_small.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0"><CFELSE><IMG SRC="/images/no_small.gif" WIDTH="12" HEIGHT="12" ALT="" BORDER="0"></cfif></TD>
			<TD NOWRAP>&nbsp;&nbsp;#Type_Code_Desc#</TD>
			<CFSET Mycounter=Mycounter+1>
		<CFIF Mycounter Mod 2>
		<CFELSE>
		</TR><TR>
		</CFIF>
		</CFIF>
	</CFOUTPUT>
	</TABLE>
	
</CFIF>

	
	