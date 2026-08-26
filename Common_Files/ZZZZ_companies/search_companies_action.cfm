<CFPARAM NAME="URL.Company_Main_ID" DEFAULT="0">
<CFPARAM NAME="URL.Mother_Company" DEFAULT="0">
<CFPARAM NAME="URL.Company_Type_ID" DEFAULT="0">


<CFQUERY NAME="SearchCompanies" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Company_Main
	WHERE
			0=0
			
			<CFIF URL.Company_Main_ID NEQ 0>
			AND
			Company_Main_ID = '#URL.Company_Main_ID#'
			</CFIF>

			<CFIF URL.Mother_Company NEQ 0>
			AND
			Mother_Company = '#URL.Mother_Company#'
			</CFIF>
			
</CFQUERY>

<CFSET PAGE_TITLE="XXXXXXXXXXXX">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT>
		function companySummary(Company_Main_ID) {
			parent.location.href = "/common_files/companies/company_info_summary.cfm?Company_Main_ID=" + Company_Main_ID
		}
	</SCRIPT>
</HEAD>

<BODY>
</BODY>
</HTML>


<CFIF SearchCompanies.RecordCount EQ 0>
	&nbsp;<DIV ALIGN="left">NO MATCHES FOUND</DIV>
<CFELSE>
	<TABLE BORDERCOLOR="FFFFFF" bordercolorlight="#C0C0C0" bordercolordark="#FFFFFF" BORDER="1" CELLSPACING="0" CELLPADDING="3" STYLE="cursor: hand">
		<CFOUTPUT QUERY="SearchCompanies">
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ccffcc'))#" ONCLICK="companySummary('#SearchCompanies.Company_Main_ID#');" ONMOUSEOVER="this.bgColor = 'cccccc'" ONMOUSEOUT="this.bgColor = '#IIf(CurrentRow Mod 2, DE('ffffff'), DE('ccffcc'))#'">
				<TD WIDTH="250" NOWRAP STYLE="color: Blue;">#SearchCompanies.Company_Name#</TD>
				<TD WIDTH="200" STYLE="color: Blue;"><CFIF len(SearchCompanies.National_Affiliation_Code)>#SearchCompanies.National_Affiliation_Code#<CFELSE>----</CFIF></TD>
			</TR>
		</CFOUTPUT>
	</TABLE>
</CFIF>