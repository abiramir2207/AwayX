<html>
<head>
<title>Test Billback Check Duplicate Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset objBillbackManager = CreateObject("component", "mvc.Models.Billback.BillbackManager") />
<cfset bIsDuplicate =  objBillbackManager.getDuplicateBillbacks(1,'Testing Componet Save','20004400') />
<cfdump var="#bIsDuplicate#" />



</body>
</html>
