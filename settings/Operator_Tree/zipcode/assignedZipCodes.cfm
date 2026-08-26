<CFOUTPUT>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Market - Postal codes</title>
</head>

<body>

<!------ assignedZipCodes.cfm ----->

<cfparam name="URL.MID" 	default="">
<cfparam name="FORM.MID" 	default="#URL.MID#">
<CFIF FORM.MID NEQ "" AND IsNumeric(FORM.MID)>

	<cfparam name="FORM.sort_by" 	default="Zip Code">
	<cfparam name="FORM.sort_order" 	default="ASC">
	
	<cfset zipcode = CreateObject("component","components.geography.zipcode") />
	<cfset StSearch = StructNew()>
	<cfset StSearch.marketId = FORM.MID>	
	<cfset Get_ZipCodes = zipcode.getZipCode(StSearch, form.sort_by, form.sort_order)>	
	
	
	<CFSET formName = "frmMarketZipCodeDisplay">
	<CFSET ThisPage = CGI.SCRIPT_NAME>
	<form action="#ThisPage#" method="post" name="#formName#" style="height:100%">
	<input type="Hidden" name="MID" value="#FORM.MID#">
	<CFSET pageLength = 18>
	<CFSET SourceQuery = Get_ZipCodes>
	<CFINCLUDE template="displayZipCodeList.cfm">	
	</form>
</CFIF>

</body>
</html>
</CFOUTPUT>