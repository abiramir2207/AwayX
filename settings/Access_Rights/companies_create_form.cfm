<CFSET PageTitle="COMPANIES: ADD COMPANY">
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

<BODY BGCOLOR="WhiteSmoke">
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

<CFPARAM NAME="URL.Company_Main_ID"			DEFAULT="">
<CFPARAM NAME="FORM.COMPANY_NAME" 			DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_1" 				DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_2"				DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_CITY" 			DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_STATE"		 	DEFAULT="">
<CFPARAM NAME="FORM.ADDRESS_ZIP"	 		DEFAULT="">
<CFPARAM NAME="FORM.PHONE_1" 				DEFAULT="">
<CFPARAM NAME="FORM.PHONE_2" 				DEFAULT="">
<CFPARAM NAME="FORM.PHONE_3"				DEFAULT="">
<CFPARAM NAME="FORM.PHONE_EXT"				DEFAULT="">
<CFPARAM NAME="FORM.FAX_1" 					DEFAULT="">
<CFPARAM NAME="FORM.FAX_2" 					DEFAULT="">
<CFPARAM NAME="FORM.FAX_3" 					DEFAULT="">
<CFPARAM NAME="FORM.WEBSITE" 				DEFAULT="">
<CFPARAM NAME="FORM.PRIMARY_CONTACT_EMAIL" 	DEFAULT="">
<CFPARAM NAME="FORM.PRIMARY_CONTACT_NAME" 	DEFAULT="">
<CFPARAM NAME="FORM.UPDATERECORD" 			DEFAULT="0">


<CFIF len(URL.Company_Main_ID) GT 0>
	<cfset useLakebaseForgetCompanyInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForgetCompanyInfo>
	<cftry>
		<cfset getCompanyInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("company_main", {
				"company_main_id" = "eq.#URL.Company_Main_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCompanyInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCompanyInfo>
<CFQUERY NAME="getCompanyInfo" datasource="#application.datasource#">
		SELECT *
		FROM Company_Main
		WHERE Company_Main_ID = '#URL.Company_Main_ID#'
	</CFQUERY>
</cfif>

	<CFIF getCompanyInfo.Recordcount GT 0>
		<CFSET FORM.COMPANY_NAME 				=	"#trim(getCompanyInfo.COMPANY_NAME)#">
		<CFSET FORM.ADDRESS_1 					=	"#trim(getCompanyInfo.ADDRESS_1)#">
		<CFSET FORM.ADDRESS_2 					=	"#trim(getCompanyInfo.ADDRESS_2)#">
		<CFSET FORM.ADDRESS_CITY 				=	"#trim(getCompanyInfo.ADDRESS_CITY)#">
		<CFSET FORM.ADDRESS_STATE 				=	"#trim(getCompanyInfo.ADDRESS_STATE)#">
		<CFSET FORM.ADDRESS_ZIP 				=	"#trim(getCompanyInfo.ADDRESS_ZIP)#">
		<CFSET FORM.PHONE_1 					=	"#trim(getCompanyInfo.PHONE_1)#">
		<CFSET FORM.PHONE_2						=	"#trim(getCompanyInfo.PHONE_2)#">
		<CFSET FORM.PHONE_3 					=	"#trim(getCompanyInfo.PHONE_3)#">
		<CFSET FORM.PHONE_EXT 					=	"#trim(getCompanyInfo.PHONE_EXT)#">
		<CFSET FORM.FAX_1 						=	"#trim(getCompanyInfo.FAX_1)#">
		<CFSET FORM.FAX_2 						=	"#trim(getCompanyInfo.FAX_2)#">
		<CFSET FORM.FAX_3 						=	"#trim(getCompanyInfo.FAX_3)#">
		<CFSET FORM.WEBSITE 					=	"#trim(getCompanyInfo.WEBSITE)#">
		<CFSET FORM.PRIMARY_CONTACT_EMAIL 		=	"#trim(getCompanyInfo.PRIMARY_CONTACT_EMAIL)#">
		<CFSET FORM.PRIMARY_CONTACT_NAME 		=	"#trim(getCompanyInfo.PRIMARY_CONTACT_NAME)#">
		<CFSET FORM.UPDATERECORD				=	"1">
	</CFIF>
</CFIF>


<CFQUERY NAME="getStates" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>

<STYLE TYPE="text/css">
.labelStyle {
	text-align : right;
}
</STYLE>

	<SCRIPT language="JavaScript" src="/Common_Files/scripts/numberValidation.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/requiredFields.js"></SCRIPT>
		<CF_MessageWindow>
	<SCRIPT>
		function verifyData(){
			ErrorCount = 0;

			//Company Name
			if(document.all.Company_Name.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Company Name", document.all.error_CompanyName);
			}
			else {
				clearQueue(document.all.error_CompanyName);
			}

			//Address 1
			if(document.all.Address_1.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter An Address", document.all.error_Address1);
			}
			else {
				clearQueue(document.all.error_Address1);
			}

			//City
			if(document.all.Address_City.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A City", document.all.error_City);
			}
			else {
				clearQueue(document.all.error_City);
			}

			//Zip
			if(document.all.Address_Zip.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Postal Code", document.all.error_Zip);
			}
			else {
				clearQueue(document.all.error_Zip);
			}

			//Phone
			if(document.all.Phone_1.value.length == 0 || document.all.Phone_1.value.length == 0 || document.all.Phone_3.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Valid Phone Number", document.all.error_Phone);
			}
			else {
				clearQueue(document.all.error_Phone);
			}
			
			//Fax
			if(document.all.Address_Zip.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Valid Fax Number", document.all.error_Fax);
			}
			else {
				clearQueue(document.all.error_Fax);
			}

			//Primary Contact Name
			if(document.all.Primary_Contact_Name.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter A Primary Contact", document.all.error_PrimaryContactName);
			}
			else {
				clearQueue(document.all.error_PrimaryContactName);
			}			


			//Primary Contact Email
			if(document.all.Primary_Contact_Email.value.length == 0) {
				ErrorCount++;
				queueMessage("Enter The Priamary Contact's Email Address", document.all.error_PrimaryContactEmail);
			}
			else {
				clearQueue(document.all.error_PrimaryContactEmail);
			}			
						
			if(ErrorCount == 0){
				document.all.MyForm.submit();
			}
			else {
				showMessageWindow()
			}
		}
	</SCRIPT>
	
	<FORM ACTION="companies_create_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
	<CFOUTPUT>
	
	<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0" ALIGN="center">
	<TR>
		<TD>
			<TABLE BORDER="0">
				<TR>
					<TD CLASS="labelStyle"><SPAN ID="error_CompanyName"></SPAN>&nbsp;Company Name</TD>
					<TD ROWSPAN="100%" BGCOLOR="Navy"><IMG SRC="/images/fill.gif" ALT="" WIDTH="1" BORDER="0"></TD>
					<TD><INPUT NAME="Company_Name" VALUE="#FORM.COMPANY_NAME#" TYPE="text" SIZE="40"></TD>
				</TR>
				<TR>
					<TD CLASS="labelStyle"><SPAN ID="error_Address1"></SPAN>&nbsp;Address 1</TD>
					<TD><INPUT NAME="Address_1" VALUE="#FORM.ADDRESS_1#" TYPE="text" SIZE="40"></TD>
				</TR>
				<TR>
					<TD CLASS="labelStyle">Address 2</TD>
					<TD><INPUT NAME="Address_2" VALUE="#FORM.ADDRESS_2#" TYPE="text" SIZE="40"></TD>
				</TR>
				<TR>
					<TD CLASS="labelStyle"><SPAN ID="error_City"></SPAN>&nbsp;<SPAN ID="error_Zip"></SPAN>&nbsp;City/State/Postal</TD>
					<TD><INPUT NAME="Address_City" VALUE="#FORM.ADDRESS_CITY#" TYPE="text"><SELECT NAME="Address_State"><CFLOOP QUERY="getStates"><OPTION VALUE="#getStates.State_ID#" <CFIF getStates.State_ID EQ FORM.ADDRESS_STATE> SELECTED</CFIF>>#getStates.State_Code#</OPTION></CFLOOP></SELECT>, <INPUT NAME="Address_Zip" VALUE="#FORM.ADDRESS_ZIP#" TYPE="text" SIZE="4" MAXLENGTH="10"></TD> <!--- onKeyUp="nextBox(this, 'NONE');" --->
				</TR>
				<TR>
					<TD CLASS="labelStyle"><SPAN ID="error_Phone"></SPAN>&nbsp;Phone</TD>
					<TD><INPUT NAME="Phone_1" VALUE="#FORM.PHONE_1#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Phone_2" VALUE="#FORM.PHONE_2#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Phone_3" VALUE="#FORM.PHONE_3#" TYPE="text" SIZE="2" MAXLENGTH="4" onKeyUp="nextBox(this, 'NONE');">&nbsp;Ext.<INPUT NAME="Phone_Ext" VALUE="#FORM.PHONE_EXT#" TYPE="text" SIZE="2" onKeyUp="nextBox(this, 'NONE');"></TD>
				</TR>
				<TR>
					<TD CLASS="labelStyle"><SPAN ID="error_Fax"></SPAN>&nbsp;Fax</TD>
					<TD><INPUT NAME="Fax_1" VALUE="#FORM.FAX_1#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Fax_2" VALUE="#FORM.FAX_2#" TYPE="text" SIZE="1" MAXLENGTH="3" onKeyUp="nextBox(this, 'NONE');">-<INPUT NAME="Fax_3" VALUE="#FORM.FAX_3#" TYPE="text" SIZE="2" MAXLENGTH="4" onKeyUp="nextBox(this, 'NONE');"></TD>		
				</TR>
				<TR>
					<TD CLASS="labelStyle">Website</TD>
					<TD><INPUT  NAME="Website" VALUE="#FORM.WEBSITE#" TYPE="text" SIZE="40"></TD>
				</TR>
				<TR>
					<TD CLASS="labelStyle"><SPAN ID="error_PrimaryContactName"></SPAN>&nbsp;Primary Contact Name</TD>
					<TD><INPUT NAME="Primary_Contact_Name" VALUE="#FORM.Primary_Contact_Name#" TYPE="text" SIZE="40"></TD>
				</TR>
				<TR>
					<TD CLASS="labelStyle"><SPAN ID="error_PrimaryContactEmail"></SPAN>&nbsp;Primary Contact Email</TD>
					<TD><INPUT NAME="Primary_Contact_Email" VALUE="#FORM.Primary_Contact_Email#" TYPE="text" SIZE="40"></TD>
				</TR>
			</TABLE>
		</TD>
		
		<TD>
			<CF_BUTTON
			BUTTON_NAME		=	""
			BUTTON_CAPTION	=	"save settings"
			BUTTON_ACTION	=	"javascript:verifyData();"
			BUTTON_TYPE		=	"link"
			BUTTON_WIDTH	=	"150"
			BUTTON_COLOR	=	"Navy"
			BUTTON_TIP		=	""
			FONT_COLOR		=	"White"
			FONT_SIZE		=	"12"
			FONT_WEIGHT		=	"bold">		
		</TD>
	</TABLE>
	<INPUT NAME="UPDATERECORD" TYPE="Hidden" VALUE="#FORM.UPDATERECORD#">
	<INPUT NAME="Company_Main_ID" TYPE="Hidden" VALUE="#URL.Company_Main_ID#">
	</CFOUTPUT>
	

	
	</FORM>
	<BR>
	<DIV ALIGN="center">

	</DIV>

</BODY>

