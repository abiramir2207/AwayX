<!---clear_rebate_files.cfm--->
<!---file will delete all cached rebate files--->
<cfparam name="DeleteSource" default="">

<!--- Deleting from Internal app settings --->
<cfif DeleteSource eq "Appsetting">
	<div align="right"><a href="#" onClick="self.close()" style="font-size:11;font-family:Arial;">close window</a></div>
</cfif>
<!---get the app path--->
<cfparam name="displayClearRebateFilesStatus" 	default="1">
<cfset appPath = request.app_general_functions.Get_Application_Path() />
<cfset Application.Doc_Path = request.app_general_functions.Get_Document_Path() />

<!---set the full path--->
<cfset fileDir = "#Application.Doc_Path#\data_Files\created\contracts\RebateData\" />

<!---loop over the dir and delete all the files--->
<cfdirectory directory="#fileDir#" action="list" name="rebateFiles" filter="*.xml">

<cfoutput query="rebateFiles"> 
	
	<cftry>
	
		<cffile action = "delete" file = "#fileDir##name#">
	
	<cfcatch type="any">
		<cfif displayClearRebateFilesStatus>
		<b><font color="##FF0000">Error deleting file #name#!</font></b>
		</cfif>
	</cfcatch>

	</cftry>
	<cfif displayClearRebateFilesStatus>
	<b><font color="##00CC00">#name# deleted successfully!</font></h2></b>
	</cfif>
	<cfflush>
	
</cfoutput>


