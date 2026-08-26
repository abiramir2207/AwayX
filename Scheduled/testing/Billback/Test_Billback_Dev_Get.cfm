<html>
<head>
<title>Test Billback Get Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfparam name="url.id" default="0" />

<cfset url.id = '0DDBCE4C-BDAA-4DE7-AF76-A4021328998E' />
<cfset request.ACCESSSTRUCTURE.USER_ID = '364F9F61-19B9-E720-221EC3CC6983060B' />
<cfset request.ACCESSSTRUCTURE.PROFILES_ID = '35' />
<cfset REQUEST.ACCESSSTRUCTURE.TIMEZONEOFFSET = '240.0' />
<cfset request.AccessStructure.useDayLightSavingsTime = 1 />
<cfset objBillbackDevManager = CreateObject("component", "mvc.Models.Billback.BillbackDevAppManager") />

<cfset qGetBillbackDevData =  objBillbackDevManager.getBillbackDetails(url.id) />

<cfdump var="#qGetBillbackDevData#" />



</body>
</html>
