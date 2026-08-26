<CFPARAM NAME="URL.PRINT" default="1">
<CFPARAM NAME="URL.BBID" 	DEFAULT="">
<CFPARAM NAME="URL.Include_File_path" 	DEFAULT="">
<cfparam name="url.contract_number" default="">
<CF_Print_Common 
	Include_File_path="#url.Include_File_path#" 
	Billback_ID=""
	contract_number="">