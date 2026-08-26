<html>
<head>
<title>Test Billback Copy Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfset request.ACCESSSTRUCTURE.USER_ID = '364F9F61-19B9-E720-221EC3CC6983060B' />
<cfset request.ACCESSSTRUCTURE.PROFILES_ID = '35' />
<cfset REQUEST.ACCESSSTRUCTURE.TIMEZONEOFFSET = '240.0' />
<cfset request.AccessStructure.useDayLightSavingsTime = 1 />

<cfset objBillbackEditManager = CreateObject("component", "mvc.Models.Billback.BillbackEditManager") />
<!--- 494159 --->
<cfset nBillbackId =  objBillbackEditManager.copyBillback(915, request.ACCESSSTRUCTURE.USER_ID) />


<cfdump var="#nBillbackId#" />
<cfabort>

</body>
</html>
