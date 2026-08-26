<!DOCTYPE html>
<cfsilent>
	<!--- detect if the user agent is from safari but NOT from chrome ----------------------------- --->
	<cfif FindNoCase('safari', CGI.HTTP_USER_AGENT) gt 0 and FindNoCase('Chrome', CGI.HTTP_USER_AGENT) lt 1>
		<cfset browser = 'Safari'>
		<cflocation url="/dashboards/index.cfm">
	</cfif>
	<cfset request.focusHiLightOff = 0>
	<cfif structKeyExists(URL, "pageToOpen")>
		<cfset src_path = URL.pageToOpen
							& (find("?", URL.pageToOpen) ? "&" : "?")
							& "a=" & createuuid()>
	<cfelse>
		<cfset src_path = "/Manufacturers/home.cfm?a=" & createuuid()>
	</cfif>
</cfsilent>
<cfoutput>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<title>#application.returned_customer_setting.company_name# @ #application.Companyname#</title>
	<link rel="shortcut icon" href="#application.appsettingsget.getFaviconPath()#">
</head>
<frameset rows="50,*">
    <frame name="header_new" src="/includes/header_frame.cfm?a=#createuuid()#" frameborder="0" height="53" scrolling="no" noresize></frame>
    <frame name="mywindowname" src="#src_path#" frameborder="0" scrolling="auto" noresize></frame>
</frameset><noframes></noframes>
</html>
</cfoutput>