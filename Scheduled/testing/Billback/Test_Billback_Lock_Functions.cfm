<html>
<head>
<title>Test Billback Lock Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />
<cfparam name="url.id" default="0" />
<cfparam name="url.lu" default="0" />
<cfset objBillbackManager = CreateObject("component", "mvc.Models.Billback.BillbackManager") />

<cfset stBillbackLock = objBillbackManager.lockUnlockBB(url.id, '364F9F61-19B9-E720-221EC3CC6983060B', url.lu) />

<cfdump var="#stBillbackLock#" />

</body>
</html>
