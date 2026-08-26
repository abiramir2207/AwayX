<html>
<head>
<title>Test Billback Upload getDateFilters() Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset objBillbackUpload = CreateObject("component", "mvc.Models.Billback.BillbackUploadManager") />

<cfset objDates =  objBillbackUpload.getDateFilters() />

<cfdump var="#objDates#" />

</body>
</html>