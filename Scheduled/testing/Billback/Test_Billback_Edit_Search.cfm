<html>
<head>
<title>Test Billback Edit Search Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />
<cfset objBillbackManager = CreateObject("component", "mvc.Models.Billback.BillbackManager") />
<cfset objBillbackEditSearchManager = CreateObject("component", "mvc.Models.Billback.BillbackEditSearchManager") />
<!---494146, 494140, 446618 --->
<cfset userId = "364F9F61-19B9-E720-221EC3CC6983060B" />
<cfset request.accessStructure.user_id = userId />
<cfset request.accessStructure.profiles_id = userId />

<cfset arrOfPrograms = objBillbackEditSearchManager.getProgramProductList(2421) />

<cfdump var="#arrOfPrograms#" />

</body>
</html>
