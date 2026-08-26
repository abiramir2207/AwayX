<html>
<head>
<title>Test Billback Edit Search Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset objBillbackPayeeSearchManager = CreateObject("component", "mvc.Models.Billback.BillbackEditSearchManager") />

<cfset objProducts =  objBillbackPayeeSearchManager.getProductData('d40fbfdd-b9eb-443a-b870-0017850786e2,ae461ec9-e667-490f-8da8-006dbd47bce4') />

<cfdump var="#objProducts#" />

</body>
</html>