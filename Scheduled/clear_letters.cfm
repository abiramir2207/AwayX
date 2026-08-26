<cfset maxHours = 0 />

<CFMODULE template="/common_files/contracts/delete_temp_files/Delete_Files.cfm" 
	APP_RELATIVE_PATH="\data_files\created\contracts\letters\output\distributors\" 
	HOURS="#maxHours#" 
	FILTER="*.*"
	RECURSIVE_DELETE="true"
	>
	
<CFMODULE template="/common_files/contracts/delete_temp_files/Delete_Files.cfm" 
	APP_RELATIVE_PATH="\data_files\created\contracts\letters\output\operators\" 
	HOURS="#maxHours#" 
	FILTER="*.*"
	RECURSIVE_DELETE="true"
	>