<cfheader name="Cache-Control" value="no-store">
<cfheader name="expires" value="-100"> 



<cfparam name="URL.CID" default="">

<CFIF len(trim(URL.CID)) EQ 0>
	<CFSET nextLocationFlag = 2>
<CFELSE>
	<CFSET nextLocationFlag = 1>
</CFIF>

<cfset nextLocationFlag = 1>
<cfswitch expression="#nextLocationFlag#">
	<CFCASE value="1">
		<!--- got contracts --->
			<CFSET nextLocationURL = "/common_files/contracts/contract_Edit_menu.cfm?CID=#URL.CID#">
	</CFCASE>
	<CFCASE value="2">
		<!--- got scorecard --->
		<cfset nextLocationURL = "scorecard/scorecard1.cfm?SECTION_TO_OPEN=ALL">
	</CFCASE>
</cfswitch>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title></title>
	<script>
	//window.location.href = "<cfoutput>#nextLocationURL#</cfoutput>"
	</script>
</head>

<body>
	<cfoutput>#now()#</cfoutput>
</body>
</html>

<BR><cfoutput>#CGI.HTTP_REFERER#</cfoutput>
