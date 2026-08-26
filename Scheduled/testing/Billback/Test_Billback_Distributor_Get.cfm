<html>
<head>
<title>Test Billback Edit Search Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset objBillbackPayeeSearchManager = CreateObject("component", "mvc.Models.Billback.BillbackEditSearchManager") />

<cfset objPayee =  objBillbackPayeeSearchManager.getDistributorList() />

<cfdump var="#objPayee#" />

</body>
</html>
