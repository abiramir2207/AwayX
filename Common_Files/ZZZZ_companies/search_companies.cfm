<CFSET PAGE_TITLE=	"Company Search Page">
<CFSET GROUP=		"Administration">

<cfset useLakebaseForGetAllCompanies = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetAllCompanies>
	<cftry>
		<cfset GetAllCompanies = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"order" = "company_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAllCompanies = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAllCompanies>
<CFQUERY NAME="GetAllCompanies" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Company_Main
	Order By Company_Name ASC
</CFQUERY>
</cfif>

<cfset useLakebaseForGetAffiliationCodes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetAffiliationCodes>
	<cftry>
		<cfset GetAffiliationCodes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"national_affiliation_code" = "neq.0",
				"order" = "national_affiliation_code.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAffiliationCodes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAffiliationCodes>
<CFQUERY NAME="GetAffiliationCodes" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Company_Main
	WHERE National_Affiliation_Code != '0'
	ORDER BY National_Affiliation_Code ASC
</CFQUERY>
</cfif>

<cfset useLakebaseForGetAllCompanyTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_types")>
<cfif useLakebaseForGetAllCompanyTypes>
	<cftry>
		<cfset GetAllCompanyTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_types", {
				"order" = "company_type_desc.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAllCompanyTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAllCompanyTypes>
<CFQUERY NAME="GetAllCompanyTypes" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM Company_Types
	ORDER BY Company_Type_Desc ASC
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
		var Mother_Company = "0";
		
		function doSearch() {
			setSearchParams();
			sendParamsToIFRAME();
			//alert(paramString);
			resetSearchParams();
	
			
		}

		function resetSearchParams() {
			paramString = "";
			Company_Main_ID = "0";
			Mother_Company = "0";	
		}

		function setSearchParams() {
			
			Mother_Company = document.all.Mother_Company.value;		
			
			if(document.all.Company_NAC.value != "0") {
				Company_Main_ID = document.all.Company_NAC.value;
			}

			if(document.all.Company_Name.value != "0") {
				Company_Main_ID = document.all.Company_Name.value;
			}
						
			paramString = "Company_Main_ID=" + Company_Main_ID + "&Mother_Company=" + Mother_Company
		}
		
		function sendParamsToIFRAME() {
			document.all.SearchResultsWindow.src = "search_companies_action.cfm?" + paramString
		}

function getAttributesWindow(title, debugObject) {
	/* lists all the attributes associated with debugObject in a separate window */
	msgWindow = window.open('','attributeWindow','');
	msgWindow.document.write('<' + 'SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">\n');
	msgWindow.document.write('function stopError() {return true}\n');
	msgWindow.document.write('window.onerror = stopError;\n');
	msgWindow.document.write('<' + '/SCRIPT>\n');
	msgWindow.document.write('&lt;' + title + '&gt;\n<OL>\n');
	for(var i in debugObject) {
		var valueString = debugObject[i];
		if(typeof(valueString) == 'object') {
			var strValueString = '"' + valueString + '"';
			msgWindow.document.write('\t<LI CLASS="OITEM">' + strValueString + ' <b>[' + i + ']</b><OL TYPE="a">\n');
			if(strValueString!='"null"') {
				// for(var j in debugObject) {
					// valueString2 = debugObject[j];
					// if(typeof(valueString2) == 'string') {
						// var ltRE = new RegExp(String.fromCharCode(60), "g");
						// if(valueString2.match(ltRE)) {valueString2 = valueString2.replace(ltRE, "&lt;");}
						// var gtRE = new RegExp(String.fromCharCode(62), "g");
						// if(valueString2.match(gtRE)) {valueString2 = valueString2.replace(gtRE, "&gt;");}
						// }
					// msgWindow.document.write('\t\t<LI CLASS="OITEM">"' + valueString2 + '" <b>' + i + '.' + j + '</b></LI>\n');
					// }
				}
			msgWindow.document.write('</OL></LI>\n');
			}
		else {
			if(typeof(valueString) == 'string') {
				var ltRE = new RegExp(String.fromCharCode(60), "g");
				if(valueString.match(ltRE)) {valueString = valueString.replace(ltRE, "&lt;");}
				var gtRE = new RegExp(String.fromCharCode(62), "g");
				if(valueString.match(gtRE)) {valueString = valueString.replace(gtRE, "&gt;");}
				}
			msgWindow.document.write('\t<LI CLASS="OITEM">"' + valueString + '" <b>' + i + '</b></LI>\n');
			}
		}
	msgWindow.document.write('</OL>\n');
	}
	
	</SCRIPT>
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
	<DIV ALIGN="center">	
	<FIELDSET CLASS="fieldset" STYLE="width: 550px;">
	<LEGEND ALIGN="left" CLASS="legend">Search Parameters</LEGEND>
		<TABLE>
			<TR>
				<TD NOWRAP>Company Name</TD>
				<TD>
					<SELECT NAME="Company_Name" ID="Company_Name">
						<OPTION VALUE="0">Any Company</OPTION>
						<CFOUTPUT QUERY="GetAllCompanies">
							<OPTION VALUE="#GetAllCompanies.Company_Main_ID#">#GetAllCompanies.Company_Name#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD NOWRAP>Company Affiliation</TD>
				<TD>
					<SELECT NAME="Company_NAC" ID="Company_NAC">
						<OPTION VALUE="0">Any Code</OPTION>
						<CFOUTPUT QUERY="GetAffiliationCodes">
							<OPTION VALUE="#GetAffiliationCodes.Company_Main_ID#">#GetAffiliationCodes.National_Affiliation_Code#</OPTION>
						</CFOUTPUT>
					</SELECT>
				</TD>
			</TR>
			<TR>
				<TD NOWRAP>Daughter Company Of</TD>
				<TD>
					<SELECT NAME="Mother_Company" ID="Mother_Company">
						<OPTION VALUE="0">Any Company</OPTION>
						<CFOUTPUT QUERY="GetAllCompanies">
							<OPTION VALUE="#GetAllCompanies.Company_Main_ID#">#GetAllCompanies.Company_Name#</OPTION>
						</CFOUTPUT>
					</SELECT>
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
	</DIV>

	<DIV ALIGN="center">	
	<FIELDSET CLASS="fieldset" STYLE="width: 550px;">
	<LEGEND ALIGN="left" CLASS="legend">Search Parameters</LEGEND>
		<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
			<TR>
				<TD>
					<TABLE BORDER="1" CELLSPACING="0" CELLPADDING="3" ALIGN="left" BORDERCOLOR="FFFFFF" BGCOLOR="000080" bordercolorlight="#C0C0C0" bordercolordark="#FFFFFF">
						<TR>
							<TD WIDTH="250" STYLE="font-size: 13; font-weight: bold; color: white;">Company Name</TD>
							<TD WIDTH="200" STYLE="font-size: 13; font-weight: bold; color: white;">Affiliation Code</TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
			<TR>
				<TD><IFRAME SRC="search_companies_action.cfm" NAME="SearchResultsWindow" ID="SearchResultsWindow" MARGINWIDTH="0" MARGINHEIGHT="0" ALIGN="middle" FRAMEBORDER="0" STYLE="width: 500px;"></IFRAME></TD>
			</TR>
		</TABLE>
	</fieldset>
	</DIV>
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>

