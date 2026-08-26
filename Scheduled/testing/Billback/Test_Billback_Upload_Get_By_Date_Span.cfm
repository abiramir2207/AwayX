<html>
<head>
<title>Test Billback Upload getBBUploadLogHistory() Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfsetting showdebugoutput="yes" />

<cfset request.ACCESSSTRUCTURE.USER_ID = '364F9F61-19B9-E720-221EC3CC6983060B' />
<cfset request.ACCESSSTRUCTURE.PROFILES_ID = '35' />
<cfset REQUEST.ACCESSSTRUCTURE.TIMEZONEOFFSET = '240.0' />
<cfset request.AccessStructure.useDayLightSavingsTime = 1 />

<cfset objBillbackUpload = CreateObject("component", "mvc.Models.Billback.BillbackUploadManager") />

<cfset objHistory =  objBillbackUpload.getBBUploadLogHistory(dateSpanMonth = 9, dateSpanYear = 2011, monthSpan = 3) />

<cfdump var="#objHistory#" />

</body>
</html>