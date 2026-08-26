<CFSET Encoded_Contract_Main_ID=URL.CID>

<!--- Date/Time stamp construction to be used int he naming scheme of the file --->
<CFSET datetimestamp="#numberformat(month(now()),'00')##numberformat(day(now()),'00')##numberformat(year(now()),'0000')##numberformat(hour(now()),'00')##numberformat(minute(now()),'00')##numberformat(second(now()),'00')#">

<!--- Build file name --->
<CFSET filename_email	=	"#getProgramData.Contract_Number#_#datetimestamp#_#gettickcount()#">

<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_Path & "\temp_files\contracts\contract_documents\Group_Retail_info_#filename_email#.htm">
<!--- end create usable directory information --->	

<!--- Build complete path --->
<CFSET completepath_email=The_File_Location>

<!--- Encrypt the path of the file --->
<cf_cryp	type = "en" string = "#completepath_email#" key = "#request.key#">
<CFSET Encoded_completepath_email=cryp.value>

<CFSET FinalVarForEmailFax = ShowDataforPrintFaxEmail>

<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "<a[^>]*?>", "", "All")>
<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "</a>", "", "All")>
<CFSET FinalVarForEmailFax = REReplaceNoCase(FinalVarForEmailFax, "<!--attachmentstart-->.*?<!--attachmentend-->", "", "All")>

<!--- Save the file to the server --->
<cflock timeout="10" type="exclusive">
	<cffile action="write" file="#completepath_email#" output="#FinalVarForEmailFax#">
</cflock>
