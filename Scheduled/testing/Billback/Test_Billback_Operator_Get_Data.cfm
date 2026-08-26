<html>
<head>
<title>Test Billback Edit Search getOperatorData Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset objBillbackPayeeSearchManager = CreateObject("component", "mvc.Models.Billback.BillbackEditSearchManager") />

<cfset objOperator =  objBillbackPayeeSearchManager.getOperatorData(200003) />

<cfdump var="#objOperator#" />

</body>
</html>
