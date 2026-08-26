<html>
<head>
<title>Test Billback Get Lock Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />
<cfparam name="url.id" default="0" />
<cfset objBillbackManager = CreateObject("component", "mvc.Models.Billback.BillbackManager") />

<cfset stBillbackLock = objBillbackManager.getLockUnlockBB(url.id) />

<cfdump var="#stBillbackLock#" />

</body>
</html>
