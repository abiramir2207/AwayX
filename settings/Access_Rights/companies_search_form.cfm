<CFSET PageTitle="COMPANIES: LIST COMPANIES">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Help file link here																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET helpfilenumber=32>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR><BR>

<cfset useLakebaseForgetAllCompanies = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForgetAllCompanies>
	<cftry>
		<cfset getAllCompanies = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"deleted" = "eq.0",
				"order" = "company_name.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAllCompanies = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAllCompanies>
<CFQUERY NAME="getAllCompanies" datasource="#application.datasource#">
	SELECT * 
	FROM Company_Main
	WHERE deleted = 0
	ORDER BY Company_name ASC
</CFQUERY>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Company List</title>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<script>
		function verifyDelete(company_name, company_main_id){
			if(confirm("Are You Sure You Want To Delete " + company_name)){
				document.DeleteCompanyForm.Company_Main_ID.value = company_main_id
				document.DeleteCompanyForm.submit();
			}
		}
	</script>
</head>

<body BGCOLOR="Whitesmoke">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Main style used by the data tables															 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>

<TABLE CLASS="Maintable" CELLPADDING="3" CELLSPACING="0">
	<!--- TABLE HEADERS --->
	<TR BGCOLOR="#FFCE84" VALIGN="bottom">
		<TD ID="header"><B>Company Name</B></TD>
		<TD ID="header"><B>Primary Contact</B></TD>
		<TD ID="header"><B>Primary Contact Phone #</B></TD>
		<TD>&nbsp;</TD>
	</TR>
	
	<!--- TABLE DATA QUERY --->
	<CFOUTPUT QUERY="getAllCompanies">
		<CFSET HREFHTML = "<A HREF='companies_create_form.cfm?Company_Main_ID=#getAllCompanies.Company_Main_ID#'>">
		<!--- DATA OUTPUT --->
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD ID="">#HREFHTML##getAllCompanies.Company_Name#</A></TD>
			<TD ID="">#HREFHTML##getAllCompanies.Primary_Contact_Name#</A></TD>
			<TD ID="">#HREFHTML##getAllCompanies.Phone_1#-#getAllCompanies.Phone_2#-#getAllCompanies.Phone_3#<CFIF len(trim(getAllCompanies.Phone_Ext))> Ext. #getAllCompanies.Phone_Ext#</CFIF></A></TD>
			<TD><img SRC="/images/delete.gif" STYLE="cursor: pointer;" ONCLICK="verifyDelete('#getAllCompanies.Company_Name#', '#getAllCompanies.Company_Main_ID#')" TITLE="Click Here To Delete #getAllCompanies.Company_Name#"></TD>
		</TR>	
	</CFOUTPUT>
</TABLE>

<FORM ACTION="companies_delete.cfm" METHOD="post" NAME="DeleteCompanyForm" ID="DeleteCompanyForm">
	<input TYPE="hidden" NAME="Company_Main_ID" VALUE="">
</form>


</body>
</html>
