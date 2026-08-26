<CFPARAM NAME="FORM.COMPANY_MAIN_ID"		DEFAULT="">
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



<CFIF FORM.UPDATERECORD EQ 0>
	<CFSET IDGENERATOR_GENERATEDIDVARIABLENAME = "Generated.Company_Main_ID">
	<CFSET IDGENERATOR_DESTINATIONTABLE = "Company_Main">		
	<CFSET IDGENERATOR_DESTINATIONFIELD = "Company_Main_ID">		
	<CFINCLUDE TEMPLATE="/common_files/keyGenerator.cfm">
	
	<cfset useLakebaseForsaveCompany = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForsaveCompany>
	<cftry>
		<cfset application.oLakebase.insertRow("company_main", {
			"company_main_id" = "#Generated.Company_Main_ID#",
			"company_name" = "#FORM.COMPANY_NAME#",
			"address_1" = "#FORM.ADDRESS_1#",
			"address_2" = "#FORM.ADDRESS_2#",
			"address_city" = "#FORM.ADDRESS_CITY#",
			"address_state" = "#FORM.ADDRESS_STATE#",
			"address_zip" = "#FORM.ADDRESS_ZIP#",
			"phone_1" = "#FORM.PHONE_1#",
			"phone_2" = "#FORM.PHONE_2#",
			"phone_3" = "#FORM.PHONE_3#",
			"phone_ext" = "#FORM.PHONE_EXT#",
			"fax_1" = "#FORM.FAX_1#",
			"fax_2" = "#FORM.FAX_2#",
			"fax_3" = "#FORM.FAX_3#",
			"website" = "#FORM.WEBSITE#",
			"primary_contact_name" = "#FORM.PRIMARY_CONTACT_EMAIL#",
			"primary_contact_email" = "#FORM.PRIMARY_CONTACT_NAME#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForsaveCompany = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForsaveCompany>
<CFQUERY NAME="saveCompany" datasource="#application.datasource#">
		INSERT INTO	Company_Main
		(Company_Main_ID, Company_Name, Address_1, Address_2, Address_City, Address_State, Address_Zip, Phone_1, Phone_2, Phone_3, Phone_Ext, Fax_1, Fax_2, Fax_3, Website, Primary_Contact_Name, Primary_Contact_Email)
		VALUES
		('#Generated.Company_Main_ID#', '#FORM.COMPANY_NAME#','#FORM.ADDRESS_1#','#FORM.ADDRESS_2#','#FORM.ADDRESS_CITY#','#FORM.ADDRESS_STATE#','#FORM.ADDRESS_ZIP#','#FORM.PHONE_1#','#FORM.PHONE_2#','#FORM.PHONE_3#','#FORM.PHONE_EXT#','#FORM.FAX_1#','#FORM.FAX_2#','#FORM.FAX_3#','#FORM.WEBSITE#','#FORM.PRIMARY_CONTACT_EMAIL#','#FORM.PRIMARY_CONTACT_NAME#')
	</CFQUERY>
</cfif>
<CFELSE>
	<cfset useLakebaseForupdateCompany = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("company_main")>
<cfif useLakebaseForupdateCompany>
	<cftry>
		<cfset application.oLakebase.updateRows("company_main",
			{
				"company_main_id" = "eq.#FORM.COMPANY_MAIN_ID#"
			},
			{
				"company_name" = "#FORM.COMPANY_NAME#",
				"address_1" = "#FORM.ADDRESS_1#",
				"address_2" = "#FORM.ADDRESS_2#",
				"address_city" = "#FORM.ADDRESS_CITY#",
				"address_state" = "#FORM.ADDRESS_STATE#",
				"address_zip" = "#FORM.ADDRESS_ZIP#",
				"phone_1" = "#FORM.PHONE_1#",
				"phone_2" = "#FORM.PHONE_2#",
				"phone_3" = "#FORM.PHONE_3#",
				"phone_ext" = "#FORM.PHONE_EXT#",
				"fax_1" = "#FORM.FAX_1#",
				"fax_2" = "#FORM.FAX_2#",
				"fax_3" = "#FORM.FAX_3#",
				"website" = "#FORM.WEBSITE#",
				"primary_contact_email" = "#FORM.PRIMARY_CONTACT_EMAIL#",
				"primary_contact_name" = "#FORM.PRIMARY_CONTACT_NAME#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateCompany = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateCompany>
<CFQUERY NAME="updateCompany" datasource="#application.datasource#">
		UPDATE Company_Main
		SET 
			COMPANY_NAME				=	'#FORM.COMPANY_NAME#',
			ADDRESS_1					=	'#FORM.ADDRESS_1#',
			ADDRESS_2					=	'#FORM.ADDRESS_2#',
			ADDRESS_CITY				=	'#FORM.ADDRESS_CITY#',
			ADDRESS_STATE				=	'#FORM.ADDRESS_STATE#',
			ADDRESS_ZIP					=	'#FORM.ADDRESS_ZIP#',
			PHONE_1						=	'#FORM.PHONE_1#',
			PHONE_2						=	'#FORM.PHONE_2#',
			PHONE_3						=	'#FORM.PHONE_3#',
			PHONE_EXT					=	'#FORM.PHONE_EXT#',
			FAX_1						=	'#FORM.FAX_1#',
			FAX_2						=	'#FORM.FAX_2#',
			FAX_3						=	'#FORM.FAX_3#',
			WEBSITE						=	'#FORM.WEBSITE#',
			PRIMARY_CONTACT_EMAIL		=	'#FORM.PRIMARY_CONTACT_EMAIL#',
			PRIMARY_CONTACT_NAME		=	'#FORM.PRIMARY_CONTACT_NAME#'
		WHERE 
			COMPANY_MAIN_ID 			=	'#FORM.COMPANY_MAIN_ID#'
	</CFQUERY>
</cfif>


</CFIF>




<CFLOCATION URL="companies_create_form.cfm">