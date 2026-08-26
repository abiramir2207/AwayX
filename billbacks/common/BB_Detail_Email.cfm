<!------
BB_Detail_Print.cfm
----->
<CFPARAM NAME="URL.BBID" 	DEFAULT="">

<CFPARAM NAME="URL.FAX_EMAIL" 	DEFAULT="EMAIL">
<cfset url.show_email_version = 1>
<CFIF UCASE(URL.FAX_EMAIL) NEQ "FAX">
	<CFSET URL.FAX_EMAIL = "EMAIL">
</CFIF>
<CFSET FROM_DETAILS = 1>
<CF_Email_Common_Form 
	Include_File_path="/Billbacks/Common/Billback_Detail_Content.cfm" 
	Document_Title="Billback" 
	Document_Number_Variable="Billback_Payable_Number" 
	Document_Title_Variable="Billback_Billback_Title"
	Document_Title_File_Prefix="BB_Details_" 
	Redirect_To_File_Path="/Billbacks/capture/Billback_Summary.cfm" 
	RETURN_URL_BBID="#URL.BBID#"
	Billback_ID="#URL.BBID#"
	FAX_EMAIL="#URL.FAX_EMAIL#">