<CFSET PAGE_TITLE=	"User Search Page">
<CFSET GROUP=		"Administration">

<CFQUERY NAME="GetNationalAffiliationCodes" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT Company_Main_ID, National_Affiliation_Code
	FROM Company_Main
	WHERE National_Affiliation_Code <> '0' OR National_Affiliation_Code IS NOT NULL
	ORDER BY National_Affiliation_Code ASC
</CFQUERY>

<cfset useLakebaseForGetAllCompanies = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetAllCompanies>
	<cftry>
		<cfset GetAllCompanies = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"order" = "company_name.asc",
				"select" = "company_main_id,company_name"
			}), "company_main_id,company_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAllCompanies = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAllCompanies>
<CFQUERY NAME="GetAllCompanies" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT Company_Main_ID, Company_Name
	FROM Company_Main
	ORDER BY Company_Name ASC
</CFQUERY>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<SCRIPT>
		var paramString = "";
		var Company_Main_ID = "0";
		var Name_Last = "";
		var Name_Last_Criteria = "";
		
		function doSearch() {
			setSearchParams();
			sendParamsToIFRAME();
			resetSearchParams();
			
		}

		function resetSearchParams() {
			paramString = "";
			Company_Main_ID = 0;
			Name_Last = "";
			Name_Last_Criteria = "";
			
			document.all.Company_Main_ID.selectedIndex = 0
			document.all.Company_NAC.selectedIndex = 0
			document.all.Name_Last_Criteria.selectedIndex = 0
			document.all.Name_Last.value = ""
							
		}
		
				function setSearchParams() {
			
			Name_Last = document.all.Name_Last.value;
			Name_Last_Criteria = document.all.Name_Last_Criteria.value;
			
			if(document.all.Company_NAC.value != 0) {
				Company_Main_ID = document.all.Company_NAC.value;
			}
			if(document.all.Company_Main_ID.value != 0) {
				Company_Main_ID = document.all.Company_Main_ID.value;
			}
						
			paramString = "?Company_Main_ID=" + Company_Main_ID + "&Name_Last=" + Name_Last + "&Name_Last_Criteria=" + Name_Last_Criteria;
		}
		
		function sendParamsToIFRAME() {
			//alert(paramString)
			document.all.SearchResultsWindow.src = "user_search_action.cfm" + paramString;

		}

	</SCRIPT>

</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
	<DIV CLASS="page_instructions" ALIGN="left">Please Enter the Appropiate User Information</DIV>
	<HR ALIGN="left" COLOR="EA7500">

	<DIV ALIGN="center">	
	<FIELDSET CLASS="fieldset" STYLE="width: 550px;">
	<LEGEND ALIGN="left" CLASS="legend">Search Parameters</LEGEND>
		<TABLE>
			<TR>
				<TD>Company Name</TD>
				<TD>
					<SELECT NAME="Company_Main_ID" ID="Company_Main_ID">
						<OPTION VALUE="0">Any Company</OPTION>
						<CFOUTPUT QUERY="GetAllCompanies">
							<OPTION VALUE="#GetAllCompanies.Company_Main_ID#">#GetAllCompanies.Company_Name#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD>Affilitation Code</TD>
				<TD>
					<SELECT NAME="Company_NAC" ID="Company_NAC">
						<OPTION VALUE="0">Any Code</OPTION>
						<CFOUTPUT QUERY="GetNationalAffiliationCodes">	
							<OPTION VALUE="#GetNationalAffiliationCodes.Company_Main_ID#">#GetNationalAffiliationCodes.National_Affiliation_Code#</OPTION>
						</CFOUTPUT>
					</SELECT>					
				</TD>
			</TR>		
			<TR>
				<TD>Last Name</TD>
				<TD>
					<SELECT NAME="Name_Last_Criteria" ID="Name_Last_Criteria">
						<OPTION VALUE="0">Any Name</OPTION>
						<OPTION VALUE="contains">contains</OPTION>
						<OPTION VALUE="begins with">begins with</OPTION>
						<OPTION VALUE="ends with">ends with</OPTION>
						<OPTION VALUE="is">is</OPTION>
					</SELECT>
					<INPUT TYPE="text" NAME="Name_Last" ID="Name_Last">
				</TD>
			</TR>
		</TABLE>
		<BR>
		<DIV ALIGN="center">
			<CF_button
				button_caption	=	"search"
				button_action	=	"doSearch()"
				button_type		=	"button"
				button_width	=	""
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"13"
				font_weight		=	"bold"
			>		
		</DIV>
	<BR>
	</fieldset>
	<DIV ALIGN="center">	
	<FIELDSET CLASS="fieldset" STYLE="width: 550px;">
	<LEGEND ALIGN="left" CLASS="legend">Search Results</LEGEND>
		<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
			<TR>
				<TD>
					<TABLE BORDER="1" CELLSPACING="0" CELLPADDING="3" ALIGN="left" BORDERCOLOR="FFFFFF" BGCOLOR="000080" bordercolorlight="#C0C0C0" bordercolordark="#FFFFFF">
						<TR>
							<TD WIDTH="194" STYLE="font-size: 13; font-weight: bold; color: white;" NOWRAP>Name</TD>
							<TD WIDTH="273" STYLE="font-size: 13; font-weight: bold; color: white;">Company Name</TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
			<TR>
				<TD><IFRAME SRC="user_search_action.cfm" NAME="SearchResultsWindow" ID="SearchResultWindow" WIDTH="500" HEIGHT="300" MARGINWIDTH="0" MARGINHEIGHT="0" ALIGN="middle" FRAMEBORDER="0"></IFRAME></TD>
			</TR>
		</TABLE>
	</fieldset>
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>

</HTML>


