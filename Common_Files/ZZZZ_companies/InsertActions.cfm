	<CFSET IDGENERATOR_GENERATEDIDVARIABLENAME = "Generated.Company_Main_ID">
	<CFSET IDGENERATOR_DESTINATIONTABLE = "Company_Main">		
	<CFSET IDGENERATOR_DESTINATIONFIELD = "Company_Main_ID">		
	<CFINCLUDE TEMPLATE="../keyGenerator.cfm">

<CFSWITCH EXPRESSION="#Form.Document_ID#">
	
	<CFCASE VALUE="CompanyInformation">
		<CFQUERY NAME="InsertCompanyInfo" datasource="#application.datasource#" DBTYPE="ODBC">
			INSERT INTO Company_Main
				(
					Company_Main_ID,
					Company_type_ID,
					Company_Name,
					Address_1,
					Address_2,
					Address_City,
					Address_State,
					Address_Zip,
					FAX,
					Phone,
					Website,
					National_Affiliation_Code,
					Notes
				)
			VALUES
				(
					'#Generated.Company_Main_ID#',
					'#Form.Company_Type_ID#',
					'#Form.Company_Name#',
					'#Form.Company_Address_1#',
					'#Form.Company_Address_2#',
					'#Form.Company_Address_City#',
					'#Form.Company_Address_State#',
					'#Form.Company_Address_ZIP#',
					'<CFIF len(Form.Company_FAX_1) EQ 3 AND len(Form.Company_FAX_2) EQ 3 AND len(Form.Company_FAX_3) EQ 4>(#Form.Company_FAX_1#)#Form.Company_FAX_2##Form.Company_FAX_3#</CFIF>',
					'<CFIF len(Form.Company_Phone_1) EQ 3 AND len(Form.Company_Phone_2) EQ 3 AND len(Form.Company_Phone_3) EQ 4>(#Form.Company_Phone_1#)#Form.Company_Phone_2##Form.Company_Phone_3#</CFIF>',
					'#Form.Company_Website#',
					'<CFIF len(Form.National_Affiliation_Code) NEQ 0>#Form.National_Affiliation_Code#<CFELSE></CFIF>',
					'#Form.Company_Notes#'
				)
		</CFQUERY>
		
		<CFSET IDGENERATOR_GENERATEDIDVARIABLENAME = "Generated.Company_Technology_ID">
		<CFSET IDGENERATOR_DESTINATIONTABLE = "Company_Technology">		
		<CFSET IDGENERATOR_DESTINATIONFIELD = "Company_Technology_ID">		
		<CFINCLUDE TEMPLATE="../keyGenerator.cfm">

		<CFQUERY NAME="CreateTechInfoRecord" datasource="#application.datasource#" DBTYPE="ODBC">
			INSERT INTO Company_Technology
			(Company_Technology_ID, Company_Main_ID, HTTP_Port, FTP_Port, SMTP_Port, SSL_Port)
			VALUES
			('#Generated.Company_Technology_ID#', '#Generated.Company_Main_ID#', '80', '21', '25', '443')
		</CFQUERY>

		<CFSET IDGENERATOR_GENERATEDIDVARIABLENAME = "Generated.Company_Billing_ID">
		<CFSET IDGENERATOR_DESTINATIONTABLE = "Company_Billing">		
		<CFSET IDGENERATOR_DESTINATIONFIELD = "Company_Billing_ID">		
		<CFINCLUDE TEMPLATE="../keyGenerator.cfm">

		
		<cfset useLakebaseForCreateBillingInfoRecord = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_billing")>
<cfif useLakebaseForCreateBillingInfoRecord>
	<cftry>
		<cfset application.oLakebase.insertRow("company_billing", {
			"company_billing_id" = "#Generated.Company_Billing_ID#",
			"company_main_id" = "#Generated.Company_Main_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForCreateBillingInfoRecord = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCreateBillingInfoRecord>
<CFQUERY NAME="CreateBillingInfoRecord" datasource="#application.datasource#" DBTYPE="ODBC">
			INSERT INTO Company_Billing
			(Company_Billing_ID, Company_Main_ID)
			VALUES
			('#Generated.Company_Billing_ID#','#Generated.Company_Main_ID#')
		</CFQUERY>
</cfif>
		
	<CFLOCATION URL="company_tech_info.cfm?Company_Main_ID=#Generated.Company_Main_ID#" ADDTOKEN="No">
	</CFCASE>
</CFSWITCH>
