<!------
BB_Detail_Print.cfm
----->
<CFPARAM NAME="URL.BBID" 	DEFAULT="">

<CFPARAM NAME="URL.FAX_EMAIL" 	DEFAULT="EMAIL">
<CFPARAM NAME="URL.Include_File_path" 	DEFAULT="">
<CFPARAM name="url.Contract_Number" default="">

<CFIF UCASE(URL.FAX_EMAIL) NEQ "FAX">
	<CFSET URL.FAX_EMAIL = "EMAIL">
</CFIF>
<CFSET FROM_DETAILS = 1>
<CF_Email_Common_Form 
	Include_File_path="#Application.Doc_Mapping#\#url.Include_File_path#" 
	Document_Title="" 
	Document_Number_Variable="" 
	Document_Title_Variable="Document_Title"
	Document_Title_File_Prefix="Report_Details_" 
	Redirect_To_File_Path="#url.Include_File_path#" 
	RETURN_URL_BBID=""
	Billback_ID=""
	FAX_EMAIL="#URL.FAX_EMAIL#"
	contract_number="#url.Contract_Number#"
	displayoutput="0">