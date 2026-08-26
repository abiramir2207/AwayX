<!------
BB_Detail_Print.cfm
----->
<CFPARAM NAME="URL.BBID" 	DEFAULT="">
<cfset url.show_print_version = 1>
<CF_Print_Common 
	Include_File_path="/Billbacks/Common/Billback_Detail_Content.cfm" 
	Billback_ID="#URL.BBID#">