<html>
<head>
<title>Test Billback Deviation Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset objBillbackEditManager = CreateObject("component", "mvc.Models.Billback.BillbackEditManager") />

<cfset stRetGetBillbackData = objBillbackEditManager.runBillbackDeviation(494159, '209EBAA9-65B8-C6FB-03C2048565FD1659') />


</body>
</html>
