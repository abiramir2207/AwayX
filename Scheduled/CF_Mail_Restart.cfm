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
