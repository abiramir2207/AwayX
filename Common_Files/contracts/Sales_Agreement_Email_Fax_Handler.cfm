<!--- encrypt the contract main ID --->
<cf_cryp	type = "en" string = "#URL.Export_Sales_Agreement_ID#" key = "#request.key#">
<CFSET Encoded_Export_Sales_Agreement_ID=cryp.value>

<!--- Date/Time stamp construction to be used int he naming scheme of the file --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">

<!--- Build file name --->
<CFSET filename_email	=	"#CSLGetContractInfo.Export_Sales_Agreement_Number#_#datetimestamp#_#gettickcount()#">

<!--- create usable directories information (Private (Internal) and Public (External)) --->
<CFSET The_File_Location_Private = Application.Doc_Path & "\temp_files\contracts\contract_documents\Export_Programs_View_Private_#filename_email#.htm">
<CFSET The_File_Location_Public = Application.Doc_Path & "\temp_files\contracts\contract_documents\Export_Programs_View_Public_#filename_email#.htm">
<!--- end create usable directories information (Private (Internal) and Public (External)) --->	

<!--- Build complete paths --->
<CFSET completepath_email_Private =The_File_Location_Private>
<CFSET completepath_email_Public =The_File_Location_Public>

<!--- Encrypt the path of the files --->
<cf_cryp	type = "en" string = "#completepath_email_Private#" key = "#request.key#">
<CFSET Encoded_completepath_email_private =cryp.value>
<cf_cryp	type = "en" string = "#completepath_email_Public#" key = "#request.key#">
<CFSET Encoded_completepath_email_public =cryp.value>

<!--- The private (internal) file comprises of public (External) and private (Internal) files --->
<CFSET FinalVarForEmailFax_Private = PublicData & PrivateData>
<!--- The public (External) comprises of only the public (External) file --->
<CFSET FinalVarForEmailFax_Public = PublicData>

<CFSET FinalVarForEmailFax_Private = REReplaceNoCase(FinalVarForEmailFax_Private, "<a[^>]*?>", "", "All")>
<CFSET FinalVarForEmailFax_Private = REReplaceNoCase(FinalVarForEmailFax_Private, "</a>", "", "All")>
<CFSET FinalVarForEmailFax_Private = REReplaceNoCase(FinalVarForEmailFax_Private, "<!--attachmentstart-->.*?<!--attachmentend-->", "", "All")>

<CFSET FinalVarForEmailFax_Public = REReplaceNoCase(FinalVarForEmailFax_Public, "<a[^>]*?>", "", "All")>
<CFSET FinalVarForEmailFax_Public = REReplaceNoCase(FinalVarForEmailFax_Public, "</a>", "", "All")>
<CFSET FinalVarForEmailFax_Public = REReplaceNoCase(FinalVarForEmailFax_Public, "<!--attachmentstart-->.*?<!--attachmentend-->", "", "All")>

<!--- Save the files to the server (Private (Internal) and Public (External)) --->
<cffile action="write" file="#completepath_email_Private#" output="#FinalVarForEmailFax_Private#">
<cffile action="write" file="#completepath_email_Public#" output="#FinalVarForEmailFax_Public#">

