<cfparam name="DeleteSource" default="">

<!--- Deleting from Internal app settings --->
<cfif DeleteSource eq "Appsetting">
	<div align="right"><a href="#" onClick="self.close()" style="font-size:11;font-family:Arial;">close window</a></div>
</cfif>
<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Delete Temp Files
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<cfset maxHours = 12 />
<CFMODULE template="Delete_Files.cfm" 
	APP_RELATIVE_PATH="Temp_Files\" 
	HOURS="#maxHours#" 
	FILTER="*.*|object_save_*"
	RECURSIVE_DELETE="true">

<CFMODULE template="Delete_Files.cfm" 
      APP_RELATIVE_PATH="Data_Files\Created\error_files\" 
      HOURS="4320" <!--- 180 days retention for errors --->
      FILTER="*.*"
      RECURSIVE_DELETE="true">

 <CFMODULE template="Delete_Files.cfm" 
      APP_RELATIVE_PATH="Data_Files\Created\settings\Planners\" 
      HOURS="4320" <!--- 180 days retention for TPO interface JSON --->
      FILTER="*.*"
      RECURSIVE_DELETE="FALSE">
	
<!------<cfmail to = "dkunnath@awayx.com"
      	from = "deleteTempFileCompleted@awayx.com"
      	subject = "Delete Temporary File Completed">
		#Now()#
	  	Delete Temporary File Completed
	</cfmail>----->
	
<!------<cfinvoke component="Temp_Files" method="delete" APP_RELATIVE_PATH="\Billbacks\Check_Book\Bank_Tran\General_Ledger_Account\Email_Files\" FILTER="*.*" HOURS="1">----->