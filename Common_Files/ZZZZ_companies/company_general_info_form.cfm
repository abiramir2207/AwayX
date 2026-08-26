

<CFPARAM NAME="URL.Company_Main_ID" DEFAULT="">



<CFQUERY NAME="RetrieveCompanyInfo" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT *
	FROM 
			Company_Main
	WHERE 
			Company_Main_ID = '#URL.Company_Main_ID#'
			AND
			Deleted = 0
</CFQUERY>

<CFQUERY NAME="GetNationalAffiliationCodes" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT DISTINCT National_Affiliation_Code, Company_Main_ID
	FROM Company_Main
	WHERE National_Affiliation_Code <> 0
	ORDER BY National_Affiliation_Code ASC
</CFQUERY>

<CFPARAM NAME="Form.National_Affiliation_Code" DEFAULT="#RetrieveCompanyInfo.National_Affiliation_Code#">
<CFPARAM NAME="Form.Company_Main_ID" DEFAULT="#RetrieveCompanyInfo.Company_Main_ID#">
<CFPARAM NAME="Form.Company_Name" DEFAULT="#RetrieveCompanyInfo.Company_Name#">
<CFPARAM NAME="Form.Company_Address_1" DEFAULT="#RetrieveCompanyInfo.Address_1#">
<CFPARAM NAME="Form.Company_Address_2" DEFAULT="#RetrieveCompanyInfo.Address_2#">
<CFPARAM NAME="Form.Company_Address_City" DEFAULT="#RetrieveCompanyInfo.Address_City#">
<CFPARAM NAME="Form.Company_Address_State" DEFAULT="#RetrieveCompanyInfo.Address_State#">
<CFPARAM NAME="Form.Company_Address_ZIP" DEFAULT="#RetrieveCompanyInfo.Address_ZIP#">
	<CFIF RETRIEVECOMPANYINFO.RECORDCOUNT>
		<CFPARAM NAME="Form.Company_Phone_1" DEFAULT="#mid(RetrieveCompanyInfo.Phone,2,3)#">
		<CFPARAM NAME="Form.Company_Phone_2" DEFAULT="#mid(RetrieveCompanyInfo.Phone,6,3)#">
		<CFPARAM NAME="Form.Company_Phone_3" DEFAULT="#mid(RetrieveCompanyInfo.Phone,9,4)#">
		<CFPARAM NAME="Form.Company_Phone_Ext" DEFAULT="#mid(RetrieveCompanyInfo.Phone, 18, len(RetrieveCompanyInfo.Phone))#">
	<CFELSE>
		<CFPARAM NAME="Form.Company_Phone_1" DEFAULT="">
		<CFPARAM NAME="Form.Company_Phone_2" DEFAULT="">
		<CFPARAM NAME="Form.Company_Phone_3" DEFAULT="">
		<CFPARAM NAME="Form.Company_Phone_Ext" DEFAULT="">
	</CFIF>	

	<CFIF RETRIEVECOMPANYINFO.RECORDCOUNT>
			<CFPARAM NAME="Form.Company_Fax_1" DEFAULT="#mid(RetrieveCompanyInfo.FAX,2,3)#">
			<CFPARAM NAME="Form.Company_Fax_2" DEFAULT="#mid(RetrieveCompanyInfo.FAX,6,3)#">
			<CFPARAM NAME="Form.Company_Fax_3" DEFAULT="#mid(RetrieveCompanyInfo.FAX,9,12)#">
	<CFELSE>
			<CFPARAM NAME="Form.Company_Fax_1" DEFAULT="">
			<CFPARAM NAME="Form.Company_Fax_2" DEFAULT="">
			<CFPARAM NAME="Form.Company_Fax_3" DEFAULT="">
	</CFIF>	
<CFPARAM NAME="Form.Company_Website" DEFAULT="#RetrieveCompanyInfo.Website#">
<CFPARAM NAME="Form.Company_Type_ID" DEFAULT="#RetrieveCompanyInfo.Company_Type_ID#">
<CFPARAM NAME="Form.Company_Notes" DEFAULT="#RetrieveCompanyInfo.Notes#">

<CFPARAM NAME="FormButtonCaption" DEFAULT="create company">

<CFPARAM NAME="FormActionPage" DEFAULT="">
<CFPARAM NAME="Form.Document_ID" DEFAULT="CompanyInformation">

<CFIF RETRIEVECOMPANYINFO.RECORDCOUNT>
	<CFSET FORMACTIONPAGE = "UpdateActions.cfm">
	<CFSET FORMBUTTONCAPTION = "Update Information">
	<CFSET PAGE_TITLE="Edit Company Information">
<CFELSE>
	<CFSET FORMACTIONPAGE = "InsertActions.cfm">
	<CFSET PAGE_TITLE="Create New Company">

</CFIF>



<CFQUERY NAME="GetStates" datasource="#application.datasource#" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(24, 0, 0, 0)#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>

<CFQUERY NAME="GetCompanyTypes" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT * FROM Company_Types
</CFQUERY>

<CFQUERY NAME="GetCompanies" datasource="#application.datasource#" DBTYPE="ODBC">
	SELECT * FROM Company_Main WHERE Company_Main_ID <> '#Form.Company_Main_ID#'
</CFQUERY>


 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<SCRIPT SRC="../PhoneNumberValidationCode.js"></SCRIPT> 
<SCRIPT>

	
	function CheckPhoneNumbersForData(){
		if(document.all.Company_Phone_1.value.length+document.all.Company_Phone_2.value.length+document.all.Company_Phone_3.value.length == 10){
			if(document.all.Company_Fax_1.value.length+document.all.Company_Fax_2.value.length+document.all.Company_Fax_3.value.length == 10){
				return true
			}
		}
		else{
			return false
		}
	}
</SCRIPT>
</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<CFINCLUDE TEMPLATE="/includes/header.cfm">
<BLOCKQUOTE>
	<DIV CLASS="page_instructions" ALIGN="left">Please Enter the Appropiate Company Information</DIV>
	<HR ALIGN="left" COLOR="EA7500">


<CFFORM ACTION="#FormActionPage#" METHOD="POST" NAME="NewCompany" ID="NewCompany">
<INPUT TYPE="hidden" NAME="Document_ID" ID="Document_ID" VALUE="<CFOUTPUT>#Form.Document_ID#</CFOUTPUT>">
<INPUT TYPE="hidden" NAME="Company_Main_ID" ID="Company_Main_ID" VALUE="<CFOUTPUT>#Form.Company_Main_ID#</CFOUTPUT>">

<CFIF isdefined("URL.RTS")>
	<INPUT TYPE="hidden" NAME="RTS" ID="RTS" VALUE="1">
</CFIF>
			<DIV ALIGN="center">
			<FIELDSET CLASS="fieldset">
			<LEGEND ALIGN="left" CLASS="legend">General User Information</LEGEND>
				<TABLE BORDER="0" BORDERCOLORLIGHT="#000000" CELLSPACING="0" CELLPADDING="3" BORDERCOLORDARK="#000000" ALIGN="left">
					<TR>
						<TD ALIGN="right">Company Name</TD>
						<TD><CFINPUT TYPE="Text" NAME="Company_Name" VALUE="#Form.Company_Name#" MESSAGE="Please Enter A Company Name" REQUIRED="Yes" SIZE="40"><FONT SIZE="-1" COLOR="Red">*</FONT></TD>
					</TR>
					<TR>
						<TD ALIGN="right">Address 1</TD>
						<TD><CFINPUT TYPE="Text" NAME="Company_Address_1" VALUE="#Form.Company_Address_1#" MESSAGE="Please Enter An Address" REQUIRED="Yes" SIZE="40"><FONT SIZE="-1" COLOR="Red">*</FONT>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Address 2</TD>
						<TD><CFINPUT TYPE="Text" NAME="Company_Address_2" VALUE="#Form.Company_Address_2#" REQUIRED="No" SIZE="40"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">City</TD>
						<TD><CFINPUT TYPE="Text" NAME="Company_Address_City" VALUE="#Form.Company_Address_City#" MESSAGE="Please Enter A City" REQUIRED="Yes" SIZE="40"><FONT SIZE="-1" COLOR="Red">*</FONT></TD>
					</TR>
					<TR>
						<TD ALIGN="right">State</TD>
						<TD>
							<CFSELECT NAME="Company_Address_State" SIZE="1" QUERY="GetStates" VALUE="State_ID" DISPLAY="State_Name" SELECTED="Form.Company_Address_State" REQUIRED="Yes" ID="Company_Address_State"><FONT SIZE="-1" COLOR="Red">*</FONT></CFSELECT><FONT SIZE="-1" COLOR="Red">*</FONT>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">ZIP</TD>
						<TD><INPUT TYPE="Text" NAME="Company_Address_ZIP" VALUE="<CFOUTPUT>#Form.Company_Address_ZIP#</CFOUTPUT>"SIZE="4" MAXLENGTH="5" ONKEYUP="javascript:nextBox(this, 5);"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">Phone</TD>
						<TD>

							<INPUT TYPE="text" NAME="Company_Phone_1" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Company_Phone_1#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Company_Phone_2', 3);">-
							<INPUT TYPE="text" NAME="Company_Phone_2" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Company_Phone_2#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Company_Phone_3', 3);">-
							<INPUT TYPE="text" NAME="Company_Phone_3" SIZE="3" MAXLENGTH="4" VALUE="<CFOUTPUT>#Form.Company_Phone_3#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Company_Phone_Ext', 4);">Ext.
							<INPUT TYPE="text" NAME="Company_Phone_Ext" SIZE="5" VALUE="<CFOUTPUT>#Form.Company_Phone_Ext#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'NONE');">					
					
						</TD>
					</TR>

					<TR>
						<TD ALIGN="right">Fax</TD>
						<TD>
						
							<INPUT TYPE="text" NAME="Company_Fax_1" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Company_Fax_1#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Company_Fax_2', 3);">-
							<INPUT TYPE="text" NAME="Company_Fax_2" SIZE="2" MAXLENGTH="3" VALUE="<CFOUTPUT>#Form.Company_Fax_2#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'Company_Fax_3', 3);">-
							<INPUT TYPE="text" NAME="Company_Fax_3" SIZE="3" MAXLENGTH="4" VALUE="<CFOUTPUT>#Form.Company_Fax_3#</CFOUTPUT>" ONKEYUP="javascript:nextBox(this, 'NONE', 4);">					
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Website</TD>
						<TD>
							<INPUT TYPE="text" NAME="Company_Website" SIZE="50" VALUE="<CFOUTPUT>#RetrieveCompanyInfo.Website#</CFOUTPUT>">
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">Company Type</TD>
						<TD>
							<CFOUTPUT QUERY="GetCompanyTypes">
								<INPUT TYPE="radio" NAME="Company_Type_ID" VALUE="#GetCompanyTypes.Company_Type_ID#"
								<CFIF FORM.COMPANY_TYPE_ID EQ GETCOMPANYTYPES.COMPANY_TYPE_ID>CHECKED<CFELSEIF FORM.COMPANY_TYPE_ID EQ "" AND GETCOMPANYTYPES.COMPANY_TYPE_ID EQ 1>CHECKED</CFIF>
								>#GetCompanyTypes.Company_Type_Desc#
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD ALIGN="right">National Affilliation Code</TD>
						<TD><INPUT TYPE="text" NAME="National_Affiliation_Code" ID="National_Affiliation_Code" SIZE="30" VALUE="<CFOUTPUT>#Form.National_Affiliation_Code#</CFOUTPUT>"></TD>
					</TR>
					<TR>
						<TD ALIGN="right">Mother Company</TD>
						<TD>
							<SELECT NAME="Mother_Company" ID="Mother_Company">
								<OPTION VALUE="0">NONE</OPTION>
									<CFOUTPUT QUERY="GetNationalAffiliationCodes">
										<OPTION VALUE="#GetNationalAffiliationCodes.Company_Main_ID#">#GetNationalAffiliationCodes.National_Affiliation_Code#</OPTION>
									</CFOUTPUT>
							</SELECT>
						</TD>
					</TR>

					<TR>
						<TD ALIGN="right">Notes</TD>
						<TD>
							<CF_SCALABLETEXTAREA 
								NAME="Company_Notes" 
								COLS="30" 
								ROWS="5" 
								INCREMENTLABEL="<IMG SRC=""\images\bigger.gif"" BORDER=""0"" ALT=""Bigger"">" 
								decrementLabel="<IMG SRC=""\IMAGES\SMALLER.GIF"" BORDER=""0"" ALT=""SMALLER"">"
							><CFOUTPUT>#Form.Company_Notes#</CFOUTPUT></CF_SCALABLETEXTAREA>			
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="100%" ALIGN="center"><FONT SIZE="-1" COLOR="Red">* Required Field</FONT></TD>
					</TR>
				</TABLE>
			</fieldset>
			</DIV>
	<BR>
	<DIV ALIGN="center">
	<CF_button
		button_caption	=	"#FormButtonCaption#"
		button_action	=	""
		button_type		=	"submit"
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
