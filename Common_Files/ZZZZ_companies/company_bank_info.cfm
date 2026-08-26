<CFSET PAGE_TITLE="Company Bank Information">

<CFPARAM NAME="URL.Company_Main_ID" DEFAULT="">

<cfset useLakebaseForGetCompanyBillingInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_billing")>
<cfif useLakebaseForGetCompanyBillingInfo>
	<cftry>
		<cfset GetCompanyBillingInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_billing", {
				"company_main_id" = "eq.#URL.Company_Main_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCompanyBillingInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCompanyBillingInfo>
<CFQUERY NAME="GetCompanyBillingInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM 
			Company_Billing
	WHERE 
			Company_Main_ID = '#URL.Company_Main_ID#'
			AND
			Deleted = 0
</CFQUERY>
</cfif>

<cfset useLakebaseForGetCompanyName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForGetCompanyName>
	<cftry>
		<cfset GetCompanyName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"company_main_id" = "eq.#URL.Company_Main_ID#",
				"deleted" = "eq.0",
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
	SELECT
			Company_Name
	FROM
			Company_Main
	WHERE
			Company_Main_ID = '#URL.Company_Main_ID#'
			AND
			Deleted = 0
</CFQUERY>
</cfif>

<!--- Form Variables --->
<CFPARAM NAME="Form.Billing_Bank_Name" DEFAULT="#GetCompanyBillingInfo.Bank_Name#">
<CFPARAM NAME="Form.Billing_Bank_Account_Number" DEFAULT="#GetCompanyBillingInfo.Bank_Account_Number#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Name_First" DEFAULT="#GetCompanyBillingInfo.Bank_Contact_First_Name#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Name_Last" DEFAULT="#GetCompanyBillingInfo.Bank_Contact_Last_Name#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Phone_1" DEFAULT="#mid(GetCompanyBillingInfo.Bank_Contact_Phone,2,3)#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Phone_2" DEFAULT="#mid(GetCompanyBillingInfo.Bank_Contact_Phone,6,3)#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Phone_3" DEFAULT="#mid(GetCompanyBillingInfo.Bank_Contact_Phone,9,4)#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Phone_Ext" DEFAULT="#mid(GetCompanyBillingInfo.Bank_Contact_Phone, 18, len(GetCompanyBillingInfo.Bank_Contact_Phone))#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Fax_1" DEFAULT="#mid(GetCompanyBillingInfo.Bank_Contact_Fax,2,3)#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Fax_2" DEFAULT="#mid(GetCompanyBillingInfo.Bank_Contact_Fax,6,3)#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Fax_3" DEFAULT="#mid(GetCompanyBillingInfo.Bank_Contact_Fax,9,4)#">
<CFPARAM NAME="Form.Billing_Bank_Contact_Email" DEFAULT="#GetCompanyBillingInfo.Bank_Contact_Email#">
<CFPARAM NAME="Form.Document_ID" DEFAULT="BankInformation">
<CFPARAM NAME="Form.Company_Main_ID" DEFAULT="#URL.Company_Main_ID#">
<CFPARAM NAME="ButtonCaption" DEFAULT="Save Changes">

<CFQUERY NAME="GetStates" datasource="#application.datasource#" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>


<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	
	<SCRIPT SRC="../PhoneNumberValidationCode.js"></SCRIPT>

</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
	<DIV CLASS="page_instructions" ALIGN="left">Please Enter the Appropiate Bank Information</DIV>
	<HR ALIGN="left" COLOR="EA7500">

	<CFFORM ACTION="UpdateActions.cfm" METHOD="POST" NAME="BankInfo">
		<DIV ALIGN="center">
		<FIELDSET CLASS="fieldset">
		<LEGEND ALIGN="left" CLASS="legend"><CFOUTPUT>#GetCompanyName.Company_Name#</CFOUTPUT> - Bank Information</LEGEND>
			<INPUT TYPE="hidden" NAME="Document_ID" ID="Document_ID" VALUE="<CFOUTPUT>#Form.Document_ID#</CFOUTPUT>">
			<INPUT TYPE="hidden" NAME="Company_Main_ID" ID="Company_Main_ID" VALUE="<CFOUTPUT>#Form.Company_Main_ID#</CFOUTPUT>">
			<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="0" CELLPADDING="3" BORDERCOLORDARK="#000000" ALIGN="left">
				<TR>
					<TD ALIGN="right">Bank Name</TD>
					<TD><CFINPUT TYPE="Text" NAME="Billing_Bank_Name" VALUE="#Form.Billing_Bank_Name#" MESSAGE="Please Enter A Bank Name" REQUIRED="No" SIZE="40" ID="Billing_Bank_Name"></TD>
				</TR>
				<TR>
					<TD ALIGN="right">Bank Account Number</TD>
					<TD><CFINPUT TYPE="Text" NAME="Billing_Bank_Account_Number" VALUE="#Form.Billing_Bank_Account_Number#" MESSAGE="Please Enter A Bank Account Number" REQUIRED="No" SIZE="40" ID="Billing_Bank_Account_Number"></TD>
				</TR>
				<TR>
					<TD ALIGN="right" VALIGN="middle">Bank Contact Name</TD>
					<TD>
						<TABLE>
							<TR>
								<TD>
									<FONT COLOR="Silver">First Name</FONT><BR>
									<INPUT TYPE="Text" NAME="Billing_Bank_Contact_Name_First" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Name_First#</CFOUTPUT>">
								</TD>
								<TD ALIGN="left">
									<FONT COLOR="Silver">Last Name</FONT><BR>
									<INPUT TYPE="Text" NAME="Billing_Bank_Contact_Name_Last" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Name_Last#</CFOUTPUT>">
								</TD>
							</TR>
						</TABLE>
					</TD>
				</TR>
				<TR>
					<TD ALIGN="right">Bank Contact Phone</TD>
					<TD>
						<INPUT TYPE="text" NAME="Billing_Bank_Contact_Phone_1" ID="Billing_Bank_Contact_Phone_1" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Phone_1#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Bank_Contact_Phone_2', 3)">-
						<INPUT TYPE="text" NAME="Billing_Bank_Contact_Phone_2" ID="Billing_Bank_Contact_Phone_2" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Phone_2#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Bank_Contact_Phone_3', 3)">-
						<INPUT TYPE="text" NAME="Billing_Bank_Contact_Phone_3" ID="Billing_Bank_Contact_Phone_3" SIZE="3" MAXLENGTH="4" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Phone_3#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Bank_Contact_Phone_Ext', 4)">Ext.
						<INPUT TYPE="text" NAME="Billing_Bank_Contact_Phone_Ext" ID="Billing_Bank_Contact_Phone_Ext" SIZE="5" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Phone_Ext#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'NONE')">
					</TD>
				</TR>
				<TR>
					<TD ALIGN="right">Bank Contact Fax</TD>
					<TD>
						<INPUT TYPE="text" NAME="Billing_Bank_Contact_Fax_1" ID="Billing_Bank_Contact_Fax_1" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Fax_1#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Bank_Contact_Fax_2', 3)">-
						<INPUT TYPE="text" NAME="Billing_Bank_Contact_Fax_2" ID="Billing_Bank_Contact_Fax_2" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Fax_2#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Bank_Contact_Fax_3', 3)">-
						<INPUT TYPE="text" NAME="Billing_Bank_Contact_Fax_3" ID="Billing_Bank_Contact_Fax_3" SIZE="3" MAXLENGTH="4" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Fax_3#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'NONE')">
					</TD>
				</TR>
				<TR>
					<TD ALIGN="right">Bank Contact E-mail</TD>
					<TD><INPUT TYPE="text" NAME="Billing_Bank_Contact_Email" ID="Billing_Bank_Contact_Email" SIZE="40" VALUE="<CFOUTPUT>#Form.Billing_Bank_Contact_Email#</CFOUTPUT>"></TD>
				</TR>
			</TABLE>
		</fieldset>
		</DIV>
		<BR>
		<DIV ALIGN="center">
			<CF_button
				button_caption	=	"#ButtonCaption#"
				button_type	=	"submit"
				button_width	=	""
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"13"
				font_weight		=	"bold"
			>
		</DIV>
	</CFFORM>
</BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</BODY>
</HTML>
