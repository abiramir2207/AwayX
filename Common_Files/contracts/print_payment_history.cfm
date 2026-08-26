<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Print</title>
</head>

<body>
<CFPARAM NAME="URL.PRINT" default="1">
<CFPARAM NAME="form.PRINTONLY" default="0">
<CFPARAM NAME="URL.BBID" 	DEFAULT="">
<CFPARAM NAME="form.Include_File_path" 	DEFAULT="">
<cfparam name="url.contract_number" default="">
<cfparam name="url.ContractID" default="">
<cfparam name="form.paymentId" default="">
<cfparam name="form.distributor_id" default="">
<cfparam name="form.FAX_EMAIL" default="">
<cfparam name="form.issingleselection" default="0">

<cfset url.issingleselection = form.issingleselection>

<cfif url.issingleselection EQ 1>
<cfset url.distributor_id = form.distributoridlist>
<cfset url.paymentId = form.FinalPaymentList>
</cfif>

<cfif form.PRINTONLY eq 1>
<CF_Print_Common 
	Include_File_path="#form.Include_File_path#" 
	Billback_ID=""
	contract_number="">
</cfif>

<cfif form.PRINTONLY eq 0>
<CFIF UCASE(form.FAX_EMAIL) NEQ "FAX">
	<CFSET form.FAX_EMAIL = "EMAIL">
</CFIF>
<CFSET FROM_DETAILS = 1>
<CF_Email_Common_Form 
	Include_File_path="#form.Include_File_path#" 
	Document_Title="" 
	Document_Number_Variable="" 
	Document_Title_Variable="Document_Title"
	Document_Title_File_Prefix="Report_Details_" 
	Redirect_To_File_Path="" 
	RETURN_URL_BBID=""
	Billback_ID=""
	FAX_EMAIL="#form.FAX_EMAIL#"
	contract_number=""
	Provide_Close_Link = "1"
	displayoutput="0">
</cfif>

</body>
</html>
