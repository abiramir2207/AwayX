
<CFSWITCH EXPRESSION="#Form.Document_ID#">
	
	<CFCASE VALUE="CompanyInformation">
		<CFQUERY NAME="InsertCompanyInfo" datasource="#application.datasource#" DBTYPE="ODBC">
			UPDATE Company_Main
			SET
				Company_type_ID				=	'#Form.Company_Type_ID#',
				Company_Name				=	'#Form.Company_Name#',
				Address_1					=	'#Form.Company_Address_1#',
				Address_2					=	'#Form.Company_Address_2#',
				Address_City				=	'#Form.Company_Address_City#',
				Address_State				=	'#Form.Company_Address_State#',
				Address_Zip					=	'#Form.Company_Address_ZIP#',
				FAX							=	'<CFIF len(Form.Company_FAX_1) EQ 3 AND len(Form.Company_FAX_2) EQ 3 AND len(Form.Company_FAX_3) EQ 4>(#Form.Company_FAX_1#)#Form.Company_FAX_2##Form.Company_FAX_3#</CFIF>',
				Phone						=	'<CFIF len(Form.Company_Phone_1) EQ 3 AND len(Form.Company_Phone_2) EQ 3 AND len(Form.Company_Phone_3) EQ 4>(#Form.Company_Phone_1#)#Form.Company_Phone_2##Form.Company_Phone_3# Ext.#Form.Company_Phone_Ext#</CFIF>',
				Website						=	'#Form.Company_Website#',
				National_Affiliation_Code	=	'#Form.National_Affiliation_Code#',
				Notes						=	'#Form.Company_Notes#',
				Mother_Company				=	'#Form.Mother_Company#'
			WHERE
				Company_Main_ID 			= 	'#Form.Company_Main_ID#'
		</CFQUERY>

		<CFIF isdefined("Form.RTS")>
			<CFLOCATION URL="company_info_summary.cfm?Company_Main_ID=#Form.Company_Main_ID#">
		<CFELSE>			
			<CFLOCATION URL="company_tech_info.cfm?Company_Main_ID=#Form.Company_Main_ID#" ADDTOKEN="No">
		</CFIF>

		
	</CFCASE>
	
	<CFCASE VALUE="TechnologyInformation">
		
		<CFQUERY NAME="UpdateTechnologyInfo" datasource="#application.datasource#" DBTYPE="ODBC">
			UPDATE Company_Technology
			SET
				EDI_Version				= 	'#Form.EDI_Version#',
				EDI_Sets				= 	'#Form.EDI_Sets#',
				Schedule				= 	'#Form.Schedule#',
				DB_Platform				= 	'#Form.DB_Platform#',
				Operating_System		= 	'#Form.Operating_System#',
				Operating_System_Rev	= 	'#Form.OS_Version#',
				Email_System			= 	'#Form.Email_System#',
				Proxy_Firewall			= 	'#Form.Proxy#',
				HTTP_Port				= 	'#Form.HTTP_Port#',
				FTP_Port				= 	'#Form.FTP_Port#',
				SMTP_Port				= 	'#Form.SMTP_Port#',
				SSL_Port				= 	'#Form.SSL_Port#'
			WHERE 
				Company_Main_ID = '#Form.Company_Main_ID#'
		</CFQUERY>

		<CFIF isdefined("Form.RTS")>
			<CFLOCATION URL="company_info_summary.cfm?Company_Main_ID=#Form.Company_Main_ID#">
		<CFELSE>			
			<CFLOCATION URL="company_billing_info.cfm?Company_Main_ID=#Form.Company_Main_ID#" ADDTOKEN="No">
		</CFIF>
		
	</CFCASE>

	<CFCASE VALUE="BillingInformation">

		<CFQUERY NAME="UpdateBillingInfo" datasource="#application.datasource#" DBTYPE="ODBC">
			UPDATE 	Company_Billing
			SET
					Address_1						=	'#Form.Billing_Address_1#',
					Address_2						=	'#Form.Billing_Address_2#',
					Address_City					=	'#Form.Billing_City#',
					Address_State					=	'#Form.Billing_State#',
					Address_Zip						=	'#Form.Billing_ZIP#',
					Contact_First_Name				=	'#Form.Billing_Contact_Name_First#',
					Contact_Last_Name				=	'#Form.Billing_Contact_Name_Last#',
					Contact_Phone					=	'<CFIF len(Form.Billing_Contact_Phone_1) EQ 3 AND len(Form.Billing_Contact_Phone_2) EQ 3 AND len(Form.Billing_Contact_Phone_3) EQ 4>(#Form.Billing_Contact_Phone_1#)#Form.Billing_Contact_Phone_2##Form.Billing_Contact_Phone_3# Ext.#Form.Billing_Contact_Phone_Ext#</CFIF>',
					Contact_FAX						=	'<CFIF len(Form.Billing_Contact_Fax_1) EQ 3 AND len(Form.Billing_Contact_Fax_2) EQ 3 AND len(Form.Billing_Contact_Fax_3) EQ 4>(#Form.Billing_Contact_Fax_1#)#Form.Billing_Contact_Fax_2##Form.Billing_Contact_Fax_3#</CFIF>',
					Contact_Email					=	'#Form.Billing_Contact_Email#',
					Start_Date						=	'#Form.Billing_Start_Date#',
					Billing_Date					=	'#Form.Billing_Date#'
			WHERE 
					Company_Main_ID = '#Form.Company_Main_ID#'
		</CFQUERY>	

		<CFIF isdefined("Form.RTS")>
			<CFLOCATION URL="company_info_summary.cfm?Company_Main_ID=#Form.Company_Main_ID#">
		<CFELSE>			
			<CFLOCATION URL="company_bank_info.cfm?Company_Main_ID=#Form.Company_Main_ID#" ADDTOKEN="No">
		</CFIF>
		
	</CFCASE>
	
	<CFCASE VALUE="BankInformation">

		<CFQUERY NAME="UpdateBankInfo" datasource="#application.datasource#" DBTYPE="ODBC">
			UPDATE 	Company_Billing
			SET
					Bank_Name						=	'#Form.Billing_Bank_Name#',
					Bank_Account_Number				=	'#Form.Billing_Bank_Account_Number#',
					Bank_Contact_First_Name			=	'#Form.Billing_Bank_Contact_Name_First#',
					Bank_Contact_Last_Name			=	'#Form.Billing_Bank_Contact_Name_Last#',
					Bank_Contact_Phone				=	'<CFIF len(Form.Billing_Bank_Contact_Phone_1) EQ 3 AND len(Form.Billing_Bank_Contact_Phone_2) EQ 3 AND len(Form.Billing_Bank_Contact_Phone_3) EQ 4>(#Form.Billing_Bank_Contact_Phone_1#)#Form.Billing_Bank_Contact_Phone_2##Form.Billing_Bank_Contact_Phone_3# Ext.#Form.Billing_Bank_Contact_Phone_Ext#</CFIF>',
					Bank_Contact_FAX				=	'<CFIF len(Form.Billing_Bank_Contact_Fax_1) EQ 3 AND len(Form.Billing_Bank_Contact_Fax_2) EQ 3 AND len(Form.Billing_Bank_Contact_Fax_3) EQ 4>(#Form.Billing_Bank_Contact_Fax_1#)#Form.Billing_Bank_Contact_Fax_2##Form.Billing_Bank_Contact_Fax_3#</CFIF>',
					Bank_Contact_Email				=	'#Form.Billing_Bank_Contact_Email#'
			WHERE 
					Company_Main_ID = '#Form.Company_Main_ID#'
		</CFQUERY>	
		
		<CFLOCATION URL="company_info_summary.cfm?Company_Main_ID=#Form.Company_Main_ID#">
	</CFCASE>

</CFSWITCH>

