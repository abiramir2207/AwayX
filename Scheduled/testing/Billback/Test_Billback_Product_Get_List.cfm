<html>
<head>
<title>Test Billback Edit Search getProductList() Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset objBillbackPayeeSearchManager = CreateObject("component", "mvc.Models.Billback.BillbackEditSearchManager") />

<cfset objProducts =  objBillbackPayeeSearchManager.getProductData() />

<cfdump var="#objProducts#" />

</body>
</html>