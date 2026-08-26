<CFSET PAGE_TITLE="Company Billing Information">

<CFPARAM NAME="URL.Company_Main_ID" DEFAULT="">

<CFQUERY NAME="GetCompanyBillingInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM 
			Company_Billing
	WHERE 
			Company_Main_ID = '#URL.Company_Main_ID#'
			AND
			Deleted = 0
</CFQUERY>

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

<!--- Form Variables --->
<CFPARAM NAME="ButtonCaption" DEFAULT="Save Changes">
<CFPARAM NAME="Form.Billing_Address_1" DEFAULT="#GetCompanyBillingInfo.Address_1#">
<CFPARAM NAME="Form.Billing_Address_2" DEFAULT="#GetCompanyBillingInfo.Address_2#">
<CFPARAM NAME="Form.Billing_City" DEFAULT="#GetCompanyBillingInfo.Address_City#">
<CFPARAM NAME="Form.Billing_State" DEFAULT="#GetCompanyBillingInfo.Address_State#">
<CFPARAM NAME="Form.Billing_Zip" DEFAULT="#GetCompanyBillingInfo.Address_Zip#">
<CFPARAM NAME="Form.Billing_Contact_Name_Last" DEFAULT="#GetCompanyBillingInfo.Contact_First_Name#">
<CFPARAM NAME="Form.Billing_Contact_Name_First" DEFAULT="#GetCompanyBillingInfo.Contact_Last_Name#">
<CFPARAM NAME="Form.Billing_Contact_Phone_1" DEFAULT="#mid(GetCompanyBillingInfo.Contact_Phone,2,3)#">
<CFPARAM NAME="Form.Billing_Contact_Phone_2" DEFAULT="#mid(GetCompanyBillingInfo.Contact_Phone,6,3)#">
<CFPARAM NAME="Form.Billing_Contact_Phone_3" DEFAULT="#mid(GetCompanyBillingInfo.Contact_Phone,9,4)#">
<CFPARAM NAME="Form.Billing_Contact_Fax_1" DEFAULT="#mid(GetCompanyBillingInfo.Contact_Fax,2,3)#">
<CFPARAM NAME="Form.Billing_Contact_Fax_2" DEFAULT="#mid(GetCompanyBillingInfo.Contact_Fax,6,3)#">
<CFPARAM NAME="Form.Billing_Contact_Fax_3" DEFAULT="#mid(GetCompanyBillingInfo.Contact_Fax,9,4)#">
<CFPARAM NAME="Form.Billing_Contact_Phone_Ext" DEFAULT="#mid(GetCompanyBillingInfo.Contact_Phone, 18, len(GetCompanyBillingInfo.Contact_Phone))#">
<CFPARAM NAME="Form.Billing_Contact_Email" DEFAULT="#GetCompanyBillingInfo.Contact_Email#">


<CFIF LEN(GETCOMPANYBILLINGINFO.START_DATE)>
	<CFPARAM NAME="Form.Billing_Date" DEFAULT="#dateformat(GetCompanyBillingInfo.Billing_Date, 'mm/dd/yyyy')#">
	<CFPARAM NAME="Form.Billing_Start_Date" DEFAULT="#dateformat(GetCompanyBillingInfo.Start_Date, 'mm/dd/yyyy')#">	
<CFELSE>
	<CFPARAM NAME="Form.Billing_Date" DEFAULT="#dateformat(Now(), 'mm/dd/yyyy')#">
	<CFPARAM NAME="Form.Billing_Start_Date" DEFAULT="#dateformat(Now(), 'mm/dd/yyyy')#">	
</CFIF>

<!--- 
<CFPARAM NAME="Form.Billing_Date" DEFAULT="<CFIF GetCompanyBillingInfo.Recordcount>GetCompanyBillingInfo.Billing_Date<CFELSE>Now()</CFIF>">
 --->
<CFPARAM NAME="Form.Billing_MSA" DEFAULT="#GetCompanyBillingInfo.Monthly_Subscription_Amount#">


<CFPARAM NAME="Form.Document_ID" DEFAULT="BillingInformation">
<CFPARAM NAME="Form.Company_Main_ID" DEFAULT="#URL.Company_Main_ID#">



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
	<DIV CLASS="page_instructions" ALIGN="left">Please Enter the Appropiate Billing Information</DIV>
	<HR ALIGN="left" COLOR="EA7500">
	
			<CFFORM ACTION="UpdateActions.cfm" METHOD="POST" NAME="BillingInfo">
			<DIV ALIGN="center">
			<FIELDSET CLASS="fieldset">
			<LEGEND ALIGN="left" CLASS="legend"><CFOUTPUT>#GetCompanyName.Company_Name#</CFOUTPUT> - Billing Information</LEGEND>
				<INPUT TYPE="hidden" NAME="Document_ID" ID="Document_ID" VALUE="<CFOUTPUT>#Form.Document_ID#</CFOUTPUT>">
				<INPUT TYPE="hidden" NAME="Company_Main_ID" ID="Company_Main_ID" VALUE="<CFOUTPUT>#Form.Company_Main_ID#</CFOUTPUT>">

			<CFIF isdefined("URL.RTS")>
				<INPUT TYPE="hidden" NAME="RTS" ID="RTS" VALUE="1">
			</CFIF>				

				<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="0" CELLPADDING="3" BORDERCOLORDARK="#000000" ALIGN="left">
					<TR>
						<TD ALIGN="right">Address 1</TD>
						<TD><CFINPUT TYPE="Text" NAME="Billing_Address_1" VALUE="#Form.Billing_Address_1#" MESSAGE="Please Enter A Billing Address" REQUIRED="Yes" SIZE="40" ID="Billing_Address_1"><FONT SIZE="-1" COLOR="Red">*</FONT></TD>
					</TR>
					<TR>
						<TD ALIGN="right">Address 2</TD>
						<TD><CFINPUT TYPE="Text" NAME="Billing_Address_2" VALUE="#Form.Billing_Address_2#" REQUIRED="No" SIZE="40" ID="Billing_Address_2"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">City</TD>
						<TD><CFINPUT TYPE="Text" NAME="Billing_City" VALUE="#Form.Billing_City#" MESSAGE="Please Enter A City" REQUIRED="Yes" SIZE="40" ID="Billing_City"><FONT SIZE="-1" COLOR="Red">*</FONT></TD>
					</TR>
					<TR>
						<TD ALIGN="right">State</TD>
						<TD>
							<CFSELECT NAME="Billing_State" QUERY="GetStates" VALUE="State_ID" DISPLAY="State_Name" SELECTED="#Form.Billing_State#" REQUIRED="Yes"></CFSELECT><FONT SIZE="-1" COLOR="Red">*</FONT>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">ZIP</TD>
						<TD><INPUT TYPE="Text" NAME="Billing_ZIP" VALUE="<CFOUTPUT>#Form.Billing_Zip#</CFOUTPUT>" SIZE="4" MAXLENGTH="5" ID="Billing_ZIP" ONKEYUP="javascript:nextBox(this, 'NONE')"><FONT SIZE="-1" COLOR="Red">*</FONT></TD>
					</TR>
					<TR>
						<TD ALIGN="right" VALIGN="middle">Contact Name</TD>
						<TD>
							<TABLE>
								<TR>
									<TD>
										<FONT COLOR="Silver">First Name</FONT><BR>
										<CFINPUT TYPE="Text" NAME="Billing_Contact_Name_First" VALUE="#Form.Billing_Contact_Name_First#" MESSAGE="Please Enter The Billing Contact's First Name" REQUIRED="Yes">
									</TD>
									<TD ALIGN="left">
										<FONT COLOR="Silver">Last Name</FONT><BR>
										<CFINPUT TYPE="Text" NAME="Billing_Contact_Name_Last" VALUE="#Form.Billing_Contact_Name_Last#" MESSAGE="Please Enter The Billing Contact's Last Name" REQUIRED="No">
									</TD>
								</TR>
							</TABLE>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Contact Phone</TD>
						<TD>
							<INPUT TYPE="text" NAME="Billing_Contact_Phone_1" ID="Billing_Contact_Phone_1" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Billing_Contact_Phone_1#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Contact_Phone_2', 3)">-
							<INPUT TYPE="text" NAME="Billing_Contact_Phone_2" ID="Billing_Contact_Phone_2" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Billing_Contact_Phone_2#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Contact_Phone_3', 3)">-
							<INPUT TYPE="text" NAME="Billing_Contact_Phone_3" ID="Billing_Contact_Phone_3" SIZE="3" MAXLENGTH="4" VALUE="<CFOUTPUT>#Form.Billing_Contact_Phone_3#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Contact_Phone_Ext', 4)">Ext.
							<INPUT TYPE="text" NAME="Billing_Contact_Phone_Ext" ID="Billing_Contact_Phone_Ext" SIZE="5" VALUE="<CFOUTPUT>#Form.Billing_Contact_Phone_Ext#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'NONE')">
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Contact Fax</TD>
						<TD>
							<INPUT TYPE="text" NAME="Billing_Contact_Fax_1" ID="Billing_Contact_Fax_1" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Billing_Contact_Fax_1#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Contact_Fax_2', 3)">-
							<INPUT TYPE="text" NAME="Billing_Contact_Fax_2" ID="Billing_Contact_Fax_2" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Billing_Contact_Fax_2#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Billing_Contact_Fax_3', 3)">-
							<INPUT TYPE="text" NAME="Billing_Contact_Fax_3" ID="Billing_Contact_Fax_3" SIZE="3" MAXLENGTH="4" VALUE="<CFOUTPUT>#Form.Billing_Contact_Fax_3#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'NONE')">
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Contact E-mail</TD>
						<TD><INPUT TYPE="text" NAME="Billing_Contact_Email" ID="Billing_Contact_Email" SIZE="40" VALUE="<CFOUTPUT>#Form.Billing_Contact_Email#</CFOUTPUT>"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">Start Date</TD>
						<TD>
							<CF_EASYDATE FORMNAME="BillingInfo" FIELDNAME="Billing_Start_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Form.Billing_Start_Date#">
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Billing Date</TD>
						<TD>
							<CF_EASYDATE FORMNAME="BillingInfo" FIELDNAME="Billing_Date" FORMAT="mm/dd/yyyy" DEFAULT="#Form.Billing_Date#">
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Monthly Subscription Amount</TD>
						<TD><INPUT TYPE="text" NAME="Billing_MSA" VALUE="<CFOUTPUT>#Form.Billing_MSA#</CFOUTPUT>"></TD>
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
