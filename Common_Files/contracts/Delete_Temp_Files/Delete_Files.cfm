<CFINCLUDE TEMPLATE="/get_App_Path.cfm">
<CFSET appPath=APPLICATIONPATH>

<CFTRY>
	<CFSET Attributes.A_APP_RELATIVE_PATH = REReplaceNoCase(Attributes.APP_RELATIVE_PATH, "\\$", "")>
	<CFSET Attributes.A_APP_RELATIVE_PATH = REReplaceNoCase(Attributes.A_APP_RELATIVE_PATH, "^\\", "")>
	<CFSET FOLDER_PATH = Application.Doc_Path & "\" & Attributes.A_APP_RELATIVE_PATH>
	<cfparam name="Attributes.FILTER" 	default="*.*">
	<cfparam name="Attributes.HOURS" 	default=24>
	<CFPARAM NAME="Attributes.DELETE_FOLDER_STRUCTURE" 	DEFAULT="false">
	<CFPARAM NAME="Attributes.RECURSIVE_DELETE" 	DEFAULT="false">
	<cfparam name="Attributes.DIR_DELETE_COUNTER" 	default=0>
	<CFIF Attributes.DELETE_FOLDER_STRUCTURE>
		<CFSET Attributes.RECURSIVE_DELETE = true>
	</CFIF>
	
	<CFIF NOT isNumeric(Attributes.HOURS)>
		<CFSET Error_Message="Invalid Hour specified">
		<CFEXIT>
	</CFIF>
	<CFCATCH>
	<CFOUTPUT>
	#Now()#
	#CFCATCH.Message#
	</CFOUTPUT>
	<!----- just for the time being, this file was edited, 
	so for few days i would like to get an email if something breaks, 
	and if some one wants to take this away, pls consult with deepa --------->
	<cfmail type="HTML" to = "dkunnath@#application.CompanyEmailSuffix#"
      	from = "deleteTempFileError@#application.CompanyEmailSuffix#"
      	subject = "Delete Temporary File Error">		
		#Now()#
	  	#CFCATCH.Message#
	</cfmail>
	<CFEXIT>
	</CFCATCH>
</CFTRY>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<CFTRY>	
	<CFSET CanDeleteFolder = 1>
	<CFSET Attributes.DIR_DELETE_COUNTER = Attributes.DIR_DELETE_COUNTER + 1>
	<CFIF ThisTag.ExecutionMode EQ "START"> 
		<CFDIRECTORY ACTION="LIST" DIRECTORY="#FOLDER_PATH#" NAME="FileListing" SORT="DateLastModified asc" FILTER="#Attributes.FILTER#">
		<CFIF FileListing.recordcount GT 0>
			<CFOUTPUT QUERY="FileListing">
				<CFIF Type EQ "File">
					<CFIF DateDiff('h',FileListing.dateLastModified,Now()) GTE Attributes.HOURS>			
						<CFSET TheFileLocation = FOLDER_PATH & "\#name#">
						<CFIF ATTRIBUTES EQ "" AND TheFileLocation CONTAINS  "common_documents">
							<CFFILE ACTION="DELETE" FILE="#TheFileLocation#">
							<!------Delete file #Type# #TheFileLocation#<BR>----->
						<CFELSE>
							<CFSET CanDeleteFolder = 0>
						</CFIF>					
					</CFIF>
				</CFIF>
			</CFOUTPUT>
			<cfset FileListing = queryNew("Attributes,DateLastModified,Directory,Link,Mode,Name,Size,Type")>
		</CFIF>
	
		<!---------------- Delete the folder structure inside --------->
		<CFIF Attributes.RECURSIVE_DELETE>
			<CFDIRECTORY ACTION="LIST" DIRECTORY="#FOLDER_PATH#" NAME="DirectoryListing">
			<CFIF DirectoryListing.recordcount GT 0>
				<CFOUTPUT QUERY="DirectoryListing">
					<CFIF Type EQ "Dir">
						<cfif len(name) eq 35 and len(Listlast(name,"-")) eq 16 and Len(ListFirst(name,"-")) EQ 8 AND ListLen(name,"-") EQ 4 >  <!--- It's a uuid which is a temp "user_id" dir --->
							<CFSET dirPath = Application.Doc_Path & "\" & "#Attributes.A_APP_RELATIVE_PATH#\#name#">
							<cfset DirectoryDelete(dirPath)>
						<cfelse>
							<CFSET TheFileLocation = Attributes.A_APP_RELATIVE_PATH & "\#name#">
							<CFMODULE template="Delete_Files.cfm" 
								APP_RELATIVE_PATH="#TheFileLocation#" 
								HOURS="#Attributes.HOURS#" 
								FILTER="#Attributes.FILTER#"
								DIR_DELETE_COUNTER="#Attributes.DIR_DELETE_COUNTER#"
								RECURSIVE_DELETE="#Attributes.RECURSIVE_DELETE#"
								DELETE_FOLDER_STRUCTURE="#Attributes.DELETE_FOLDER_STRUCTURE#">
						</cfif>
					</CFIF>
				</CFOUTPUT>
				<cfset DirectoryListing = queryNew("Attributes,DateLastModified,Directory,Link,Mode,Name,Size,Type")>
			</CFIF>
			<!---<CFIF Attributes.DELETE_FOLDER_STRUCTURE AND Attributes.DIR_DELETE_COUNTER GT 1 AND CanDeleteFolder>
				<CFDIRECTORY ACTION="DELETE" DIRECTORY="#FOLDER_PATH#">
			</CFIF> --->		
		</CFIF>
		
	</CFIF>
	
	<CFCATCH>
	<CFOUTPUT>
	#Now()#
	#CFCATCH.Message#
	</CFOUTPUT>
	<!------<cfmail type="HTML" to = "dkunnath@awayx.com"
      	from = "deleteTempFileError@awayx.com"
      	subject = "Delete Temporary File Error">		
		#Now()#
	  	#CFCATCH.Message#
	</cfmail>----->
	</CFCATCH>
</CFTRY>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


