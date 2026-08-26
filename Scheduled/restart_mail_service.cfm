<!---
Name: 			restart_mail_service.cfm
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	03/13/2012
Created By:    	Tim Ford
Description:	File used to restart the CF mail service
Parameters:		N/A
Usage:			N/A
--->

<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfset sFactory = CreateObject("java","coldfusion.server.ServiceFactory")>
<cfset MailSpoolService = sFactory.mailSpoolService>
<cfset MailSpoolService.stop()>
<cfset MailSpoolService.start()>

</body>
</html>
