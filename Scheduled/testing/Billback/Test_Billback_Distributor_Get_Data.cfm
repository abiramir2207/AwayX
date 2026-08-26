<html>
<head>
<title>Test Billback Edit Search getDistributorData Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset objBillbackPayeeSearchManager = CreateObject("component", "mvc.Models.Billback.BillbackEditSearchManager") />

<cfset objDistributor =  objBillbackPayeeSearchManager.getDistributorData(32384800) />

<cfdump var="#objDistributor#" />

</body>
</html>
