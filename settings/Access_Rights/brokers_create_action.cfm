
<CFLOOP INDEX="field" LIST="#FORM.Fieldnames#" DELIMITERS=",">
	<CFSET "FORM.#field#" = replace(evaluate("FORM.#field#"), chr(39), "#chr(39)##chr(39)#", "ALL")>
</CFLOOP>

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
<CFPARAM NAME="FORM.Region_Shard" 			DEFAULT="">
<CFPARAM NAME="FORM.REGION_LEGCY_SHARD" 	DEFAULT="">				
<CFPARAM NAME="FORM.WEBSITE" 				DEFAULT="">
<CFPARAM NAME="FORM.PRIMARY_CONTACT_EMAIL" 	DEFAULT="">
<CFPARAM NAME="FORM.PRIMARY_CONTACT_NAME" 	DEFAULT="">
<CFPARAM NAME="FORM.Market_Area_ID"		 	DEFAULT="">
<CFPARAM NAME="FORM.UPDATERECORD" 			DEFAULT="0">

<CFQUERY NAME="getStateCode" datasource="#application.datasource#">
SELECT State_Code
FROM _states
WHERE State_ID = '#FORM.ADDRESS_STATE#'
</CFQUERY>
<CFSET FORM.ADDRESS_STATE = getStateCode.State_Code> 



<CFIF FORM.UPDATERECORD EQ 0>
	<CFSET IDGENERATOR_GENERATEDIDVARIABLENAME = "Generated.Company_Main_ID">
	<CFSET IDGENERATOR_DESTINATIONTABLE = "Company_Main">		
	<CFSET IDGENERATOR_DESTINATIONFIELD = "Company_Main_ID">		
	<CFINCLUDE TEMPLATE="/common_files/keyGenerator.cfm">
	
	<CFQUERY NAME="saveCompany" datasource="#application.datasource#">
		INSERT INTO	BSA_Foodservice_Brokers
			(
				Active_Code,
				Address,
				Address_2,
				City,
				State,
				Zip,
				Broker_Csr,
				E_Mail,
				Broker_Name,
				Line_Of_Business_ID,
				Account_Exec,
				Phone_1,
				Phone_2,
				Phone_3,
				Phone_Ext,
				Fax_1,
				Fax_2,
				Fax_3,
				Service_Region_ID,
				Service_Zone_ID,
				Service_Market_ID,
				BROKER_SHARD
			)
		VALUES
			(
				'A',
				'#FORM.ADDRESS#',
				'#FORM.ADDRESS_2#',
				'#FORM.ADDRESS_CITY#',
				'#FORM.ADDRESS_STATE#',
				'#FORM.ADDRESS_ZIP#',
				'#FORM.BROKER_CSR#',
				'#FORM.BROKER_EMAIL#',
				'#FORM.BROKER_NAME#',
				'#FORM.LINE_OF_BUSINESS_ID#',
				'#FORM.ACCOUNT_EXEC#',
				'#FORM.PHONE_1#',
				'#FORM.PHONE_2#',
				'#FORM.PHONE_3#',
				'#FORM.PHONE_EXT#',
				'#FORM.FAX_1#',
				'#FORM.FAX_2#',
				'#FORM.FAX_3#',
				'#FORM.Region_ID#',
				'#FORM.Zone_ID#',
				'#Form.MARKET_AREA_ID#',
				'#FORM.BROKER_SHARD#'
			)
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="updateCompany" datasource="#application.datasource#">
		UPDATE BSA_Foodservice_Brokers
		SET 
			Broker_Csr	 			=	'#FORM.BROKER_CSR#',
			E_Mail	 				=	'#FORM.BROKER_EMAIL#',
			Phone_1	 				=	'#FORM.PHONE_1#',
			Phone_2	 				=	'#FORM.PHONE_2#',
			Phone_3	 				=	'#FORM.PHONE_3#',
			Phone_Ext	 			=	'#FORM.PHONE_EXT#',
			Fax_1	 				=	'#FORM.FAX_1#',
			Fax_2	 				=	'#FORM.FAX_2#',
			Fax_3	 				=	'#FORM.FAX_3#',
			<cfif FORM.Region_ID neq "">
				Service_Region_ID		=	'#FORM.Region_ID#',
			</cfif>
			<cfif FORM.Zone_ID neq "">
				Service_Zone_ID			=	'#FORM.Zone_ID#',
			</cfif>
			Service_Market_ID		=	'#Form.MARKET_AREA_ID#',
			Updated_Date = getdate() 
		WHERE 
			BSA_Foodservice_Brokers_ID 			=	'#FORM.BROKER_ID#'
	</CFQUERY>
</CFIF>

<!--- <CFQUERY NAME="getLastMAassignedToBroker" datasource="#application.datasource#">
	SELECT *
	FROM Service_Markets
	WHERE 0=1
</CFQUERY>
<CFIF len(FORM.BROKER_ID) GT 0>
<CFQUERY NAME="getLastMAassignedToBroker" datasource="#application.datasource#">
	SELECT *
	FROM Service_Markets
	WHERE BSA_Foodservice_Brokers_ID = '#FORM.BROKER_ID#'
</CFQUERY>
</CFIF>

<CFIF getLastMAassignedToBroker.Recordcount NEQ 0>
	<CFIF getLastMAassignedToBroker.Service_Market_ID NEQ FORM.MARKET_AREA_ID>
		<CFQUERY NAME="saveMAassignment" datasource="#application.datasource#">
			UPDATE Service_Markets
			SET BSA_Foodservice_Brokers_ID = NULL
			WHERE Service_Market_ID = '#getLastMAassignedToBroker.Service_Market_ID#'
		</CFQUERY>
	</CFIF>
</CFIF> --->

<cfif len(FORM.BROKER_ID) EQ 0><CFSET FORM.Broker_ID = saveCompany.BSA_Foodservice_Brokers_ID></cfif>


<CFQUERY NAME="saveMAassignment" datasource="#application.datasource#">
	UPDATE BSA_Foodservice_Brokers
	SET  Service_Market_ID = '#Form.MARKET_AREA_ID#'
	WHERE BSA_Foodservice_Brokers_ID = '#FORM.BROKER_ID#'
</CFQUERY>


<!--- 
<CFQUERY NAME="saveMAassignment" datasource="#application.datasource#">
	UPDATE Service_Markets
	SET BSA_Foodservice_Brokers_ID = '#FORM.BROKER_ID#'
	WHERE Service_Market_ID = '#Form.MARKET_AREA_ID#'
</CFQUERY>
 --->

<CFLOCATION URL="brokers_search_form.cfm">