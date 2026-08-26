<!---clear_program_files.cfm--->
<!---file will delete all cached program files--->
<cfparam name="variables.displayOutput" 	default="1" />
<cfparam name="variables.programId" 		default="0" />

<!---set the full path--->
<cfset fileDir = "#Application.Doc_Path#\Temp_Files\Program\" />

<!---TSF: If a program id was passed then just delete the file for that program id, otherwise clean house--->
<cfif variables.programId>
	<cfoutput>
		<cfset variables.fileFilter = "View_Program_#variables.programId#" />
	</cfoutput>
<cfelse>
	<cfset variables.fileFilter = "*" />
</cfif>

<!---loop over the dir and delete all the files--->
<cfdirectory directory="#fileDir#" action="list" name="programFiles" filter="#variables.fileFilter#.htm">

<cfoutput query="programFiles"> 
	
	<cftry>
	
		<cffile action = "delete" file = "#fileDir##name#">
	
	<cfcatch type="any">
		<cfif variables.displayOutput>
			<b><font color="##FF0000">Error deleting file #name#!</font></b>
		</cfif>
	</cfcatch>

	</cftry>
	<cfif variables.displayOutput>
		<b><font color="##00CC00">#name# deleted successfully!</font></h2></b>
	</cfif>
	
	<cfflush>
	
</cfoutput>