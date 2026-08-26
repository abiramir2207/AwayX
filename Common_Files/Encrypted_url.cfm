<!------Encrypted_url.cfm----->
<CFSET Encrypted_Url = "">
<CFIF IsDefined("Encrypt_Document_Type") AND IsDefined("Encrypt_Document_ID")>
	<CFSET Encrypt_Key = CreateUUID()>
	<CFSET Encrypt_Key = Replace(Encrypt_Key, "-", "", "All")>
	<CF_CRYP type="en" key="#Encrypt_Key#" string="#Encrypt_Document_Type#">
	<CFSET Part_1 = cryp.value>
	<CFSET Part_2 = Encrypt_Key>
	<CF_CRYP type="en" key="#Encrypt_Key#" string="#Encrypt_Document_ID#">
	<CFSET Part_3 = cryp.value>
	
	
	<CFSET PaddingUUID1 = CreateUUID()>
	<CFSET PaddingUUID1 = Replace(PaddingUUID1, "-", "", "All")>
	<CFSET PaddingUUID1 = Left(PaddingUUID1, 5)>
	
	<CFSET PaddingUUID2 = CreateUUID()>
	<CFSET PaddingUUID2 = Replace(PaddingUUID2, "-", "", "All")>
	<CFSET PaddingUUID2 = Left(PaddingUUID2, 5)>
	
	<CFSET Token="#PaddingUUID1##Len(Part_1)#_#Part_1##Part_2##Part_3#_#Len(Part_2)##PaddingUUID2#">
	<CFSET Encrypted_Url = "#application.HTTPVar##CGI.Server_Name#/Common_Access/login.cfm?token=#Token#">	
	
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
	<cfset commonAccessURLPrefix = Trim(appSettings.getCommonAccessURLPrefix()) />
	<cfif commonAccessURLPrefix NEQ "">
		<cfset Encrypted_Url = "#commonAccessURLPrefix##Encrypted_Url#" />
	</cfif>
</CFIF>