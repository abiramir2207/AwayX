<cfset useLakebaseForGetCompanyName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetCompanyName>
	<cftry>
		<cfset GetCompanyName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"company_main_id" = "eq.#URL.Company_Main_ID#",
				"select" = "company_name"
			}), "company_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCompanyName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCompanyName>
<CFQUERY NAME="GetCompanyName" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT Company_Name
	FROM Company_Main
	WHERE Company_Main_ID = '#URL.Company_Main_ID#'
</CFQUERY>
</cfif>

<CFSET PAGE_TITLE="Company Summary - #GetCompanyName.Company_Name#">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
		<CF_TAB_GROUP General_Color="FFFFC6" Common_URL_Variables="Company_Main_ID">

			<CF_TAB_ITEM Title="General Information" ToolTip="View Basic Company Information">
				<CFQUERY NAME="GetCompanyGeneralInfo" datasource="#application.datasource#" DBTYPE="ODBC">
					SELECT dbo.Company_Types.Company_Type_Desc AS Company_Type,
					     dbo._states.state_name AS State_Name, 
					    dbo.Company_Main.*, 
					    Company_Main1.Company_Name AS Mother_Company_Name, 
					    Company_Main1.National_Affiliation_Code AS Mother_Company_NAC
					FROM dbo.Company_Main INNER JOIN
					    dbo.Company_Types ON 
					    dbo.Company_Main.Company_Type_ID = dbo.Company_Types.Company_Type_ID
					     INNER JOIN
					    dbo._states ON 
					    dbo.Company_Main.Address_State = dbo._states.state_ID LEFT OUTER
					     JOIN
					    dbo.Company_Main Company_Main1 ON 
					    dbo.Company_Main.Mother_Company = Company_Main1.Company_Main_ID
					WHERE
							Company_Main.Company_Main_ID = '#URL.Company_Main_ID#'
							AND
							Company_Main.Deleted = 0
				</CFQUERY>
				<BR>
				<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="2" CELLPADDING="2" BORDERCOLORDARK="#000000" ALIGN="center">
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Company Name</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Company_Name#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Address 1</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Address_1#</CFOUTPUT></TD>
					</TR>
					<CFIF len(GetCompanyGeneralInfo.Address_2) GT 0>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Address 2</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Address_2#</CFOUTPUT></TD>
					</TR>
					</CFIF>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP></TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Address_City#, #GetCompanyGeneralInfo.State_Name# #GetCompanyGeneralInfo.Address_Zip#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Phone</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Phone#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>FAX</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Fax#</CFOUTPUT></TD>
					</TR>
					<CFIF len(GetCompanyGeneralInfo.Mother_Company_Name) GT 0>
					<TR>
						<TD ALIGN="right" CLASS="labelname">Mother Company</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Mother_Company_Name#</CFOUTPUT></TD>
					</TR>
					</CFIF>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Website</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.website#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Company Type</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Company_Type#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" VALIGN="top" CLASS="labelname" NOWRAP>Notes:</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyGeneralInfo.Notes#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD COLSPAN="2" ALIGN="center">
							<BR><BR>
							[<A HREF="company_general_info_form.cfm?Company_Main_ID=<CFOUTPUT>#URL.Company_Main_ID#</CFOUTPUT>&RTS=1">Edit General Information</A>]
						</TD>
					</TR>
				</TABLE>

			</CF_TAB_ITEM>

			
			<CF_TAB_ITEM Title="Technology Information" ToolTip="View Basic Company Information">
				<CFQUERY NAME="GetCompanyTechInfo" datasource="#application.datasource#" DBTYPE="ODBC">
					SELECT *, Company_Technology.*, 
					    Operating_Systems.Operating_System_Desc, 
					    Database_Platforms.Database_Platform_Desc, 
					    Data_Sampliing_Rates.Data_Sampling_Rate_Desc
					FROM Company_Technology INNER JOIN
					    Operating_Systems ON 
					    Company_Technology.Operating_System = Operating_Systems.Operating_System_ID
					     INNER JOIN
					    Database_Platforms ON 
					    Company_Technology.DB_Platform = Database_Platforms.Database_Platform_ID
					     INNER JOIN
					    Data_Sampliing_Rates ON 
					    Company_Technology.Schedule = Data_Sampliing_Rates.Data_Sampling_Rate_ID
					WHERE
							Company_Main_ID = '#URL.Company_Main_ID#'
							AND
							Company_Technology.Deleted = 0
				</CFQUERY>
				<BR>
				<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="2" CELLPADDING="2" BORDERCOLORDARK="#000000" ALIGN="center">
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>EDI Version</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyTechInfo.EDI_Version#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>EDI Sets</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyTechInfo.EDI_Sets#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Schedule</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyTechInfo.Data_Sampling_Rate_Desc#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Database Platform</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyTechInfo.Database_Platform_Desc#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Operating System</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyTechInfo.Operating_System_Desc#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Operating System Version</TD>
						<TD  CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyTechInfo.Operating_System_Rev#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>E-Mail System</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyTechInfo.Email_System#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Proxy or Firewall</TD>
						<TD CLASS="summary_page_cell" ><CFIF GetCompanyTechInfo.Proxy_Firewall>Yes<CFELSE>NO</CFIF></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD CLASS="summary_page_cell">
							<TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0">
								<TR>
									<TD CLASS="labelname">HTTP Port:</TD>
									<TD WIDTH="30" CLASS="labelname">&nbsp;<CFOUTPUT>#GetCompanyTechInfo.HTTP_Port#</CFOUTPUT></TD>
									<TD  CLASS="labelname">FTP Port:</TD>
									<TD CLASS="labelname">&nbsp;<CFOUTPUT>#GetCompanyTechInfo.FTP_Port#</CFOUTPUT></TD>
								</TR>
								<TR>
									<TD ALIGN="right" CLASS="labelname">SMTP Port:</TD>
									<TD CLASS="labelname">&nbsp;<CFOUTPUT>#GetCompanyTechInfo.SMTP_Port#</CFOUTPUT></TD>
									<TD ALIGN="right" CLASS="labelname">SSL Port:</TD>
									<TD CLASS="labelname">&nbsp;<CFOUTPUT>#GetCompanyTechInfo.SSL_Port#</CFOUTPUT></TD>
								</TR>
							</table>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="center" COLSPAN="2">
							<BR><BR>
							[<A HREF="company_tech_info.cfm?Company_Main_ID=<CFOUTPUT>#URL.Company_Main_ID#</CFOUTPUT>&RTS=1">Edit Technology Information</A>]
						</TD>
					</TR>
				</TABLE>

			</CF_TAB_ITEM>
		
			<CF_TAB_ITEM Title="Billing Information" ToolTip="View Basic Company Information">
				<CFQUERY NAME="GetCompanyBillingInfo" datasource="#application.datasource#" DBTYPE="ODBC">
					SELECT _states.state_name, Company_Billing.*
					FROM _states INNER JOIN
					    Company_Billing ON 
					    _states.state_ID = Company_Billing.Address_State	
					WHERE
							Company_Main_ID = '#URL.Company_Main_ID#'
							AND
							Company_Billing.Deleted = 0
				</CFQUERY>
				<BR>
				<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="2" CELLPADDING="2" BORDERCOLORDARK="#000000" ALIGN="center">
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Address 1</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Address_1#</CFOUTPUT></TD>
					</TR>
					<CFIF len(GetCompanyBillingInfo.Address_2) GT 0>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Address 2</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Address_2#</CFOUTPUT></TD>
					</TR>
					</CFIF>
					<TR>
						<TD ALIGN="right" CLASS="labelname"></TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Address_City#, #GetCompanyBillingInfo.state_name# #GetCompanyBillingInfo.Address_ZIP#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" VALIGN="middle" NOWRAP>Contact Name</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Contact_First_Name# #GetCompanyBillingInfo.Contact_Last_Name#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Contact Phone</TD>
						<TD CLASS="summary_page_cell" ><CFOUTPUT>#GetCompanyBillingInfo.Contact_Phone#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Contact Fax</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Contact_Fax#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Contact E-mail</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Contact_Email#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Start Date</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Start_Date#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Billing Date</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Billing_Date#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Subscription Amount</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Monthly_Subscription_Amount#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD COLSPAN="2" ALIGN="center">
							<BR><BR>
							[<A HREF="company_billing_info.cfm?Company_Main_ID=<CFOUTPUT>#URL.Company_Main_ID#</CFOUTPUT>&RTS=1">Edit Billing Information</A>]
						</TD>
					</TR>
				</TABLE>			
			</CF_TAB_ITEM> 
			
			<CF_TAB_ITEM Title="Bank Information" ToolTip="View Basic Company Information">
				<CFQUERY NAME="GetCompanyBillingInfo" datasource="#application.datasource#" DBTYPE="ODBC">
					SELECT _states.state_name, Company_Billing.*
					FROM _states INNER JOIN
					    Company_Billing ON 
					    _states.state_ID = Company_Billing.Address_State	
					WHERE
							Company_Main_ID = '#URL.Company_Main_ID#'
							AND
							Company_Billing.Deleted = 0
				</CFQUERY>
				<BR>
				<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="2" CELLPADDING="2" BORDERCOLORDARK="#000000" ALIGN="center">
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Bank Name</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Bank_Name#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Bank Account Number</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Bank_Account_Number#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Bank Contact Name</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Bank_Contact_First_Name# #GetCompanyBillingInfo.Bank_Contact_Last_Name#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Bank Contact Phone</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Bank_Contact_Phone#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Bank Contact Fax</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Bank_Contact_Fax#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" CLASS="labelname" NOWRAP>Bank Contact E-mail</TD>
						<TD CLASS="summary_page_cell"><CFOUTPUT>#GetCompanyBillingInfo.Bank_Contact_Email#</CFOUTPUT></TD>
					</TR>
					<TR>
						<TD COLSPAN="2" ALIGN="center">
							<BR><BR>
							[<A HREF="company_bank_info.cfm?Company_Main_ID=<CFOUTPUT>#URL.Company_Main_ID#</CFOUTPUT>&RTS=1">Edit Bank Information</A>]
						</TD>
					</TR>
				</TABLE>
			</CF_TAB_ITEM>
		
		</CF_TAB_GROUP>
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
