<CFSET appPath=APPLICATIONPATH>


<!--- clear contract fax temp docs --->
<CFSET Contracts_Temp_Files_Physical_Location = Application.Doc_Path & "\Temp_Files\contracts\contract_documents">

<CFDIRECTORY ACTION="LIST" DIRECTORY="#Contracts_Temp_Files_Physical_Location#" NAME="DirectoryListing" SORT="DateLastModified asc">

<CFIF DirectoryListing.recordcount GT 0>
	<CFOUTPUT QUERY="DirectoryListing">		
		<CFIF DateDiff('h',DirectoryListing.dateLastModified,Now()) GTE 24>			
			<CFSET TheFileLocation = Contracts_Temp_Files_Physical_Location & "\#DirectoryListing.name#">
			<CFFILE ACTION="DELETE" FILE="#TheFileLocation#">
		</CFIF>
	</CFOUTPUT>
</CFIF>

<!--- clear contract xml temp docs --->
<CFSET Contracts_Temp_Files_Physical_Location = Application.Doc_Path & "\Temp_Files\contracts\XML_Programs">

<CFDIRECTORY ACTION="LIST" DIRECTORY="#Contracts_Temp_Files_Physical_Location#" NAME="DirectoryListing" SORT="DateLastModified asc">

<CFIF DirectoryListing.recordcount GT 0>
	<CFOUTPUT QUERY="DirectoryListing">
		<CFIF DateDiff('h',DirectoryListing.dateLastModified,Now()) GTE 24>
			<CFSET TheFileLocation = Contracts_Temp_Files_Physical_Location & "\#DirectoryListing.name#">
			<CFFILE ACTION="DELETE" FILE="#TheFileLocation#">	
		</CFIF>
	</CFOUTPUT>
</CFIF>

