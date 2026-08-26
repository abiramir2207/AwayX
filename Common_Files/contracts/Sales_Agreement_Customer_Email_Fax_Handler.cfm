<!--- encrypt the export customer ID --->
<cf_cryp	type = "de" string = "#URL.CID#" key = "#request.key#">
<CFSET Decoded_Export_Customer_ID=cryp.value>

<!--- Date/Time stamp construction to be used in the naming scheme of the file --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">

<cfinclude template="/common_files/contracts/sales_agreement_customer_printer_friendly.cfm">

<cfset useLakebaseForCSLGetCustomerInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("export_customer")>
<cfif useLakebaseForCSLGetCustomerInfo>
	<cftry>
		<cfset CSLGetCustomerInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("export_customer", { "export_customer_id" = "eq.#Decoded_Export_Customer_ID#", "select" = "export_customer_id" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForCSLGetCustomerInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCSLGetCustomerInfo>
	<cfquery name="CSLGetCustomerInfo" datasource="#application.datasource#">
		SELECT Export_Customer_ID
		FROM Export_Customer
		WHERE Export_Customer_ID = '#Decoded_Export_Customer_ID#'
	</cfquery>
</cfif>

<!--- Build file name --->
<CFSET filename_email	=	"#CSLGetCustomerInfo.Export_Customer_ID#_#datetimestamp#_#gettickcount()#">

<!--- create usable directories information --->
<CFSET The_File_Location = Application.Doc_Path & "\temp_files\customer\Customer_View_#filename_email#.htm">
<!--- end create usable directories information --->	

<!--- Build complete paths --->
<CFSET completepath_email =The_File_Location>

<!--- Encrypt the path of the files --->
<cf_cryp	type = "en" string = "#completepath_email#" key = "#request.key#">
<CFSET Encoded_completepath_email =cryp.value>

<CFSET FinalVarForEmailFax = CustomerDocument>

<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "<a[^>]*?>", "", "All")>
<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "</a>", "", "All")>
<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "<!--attachmentstart-->.*?<!--attachmentend-->", "", "All")>

<!--- Save the files to the server --->
<cffile action="write" file="#completepath_email#" output="#FinalVarForEmailFax#">

