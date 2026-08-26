<html>
<head>
<title>Test Deduction Get Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfset url.id = '0DDBCE4C-BDAA-4DE7-AF76-A4021328998E' />
<cfset request.ACCESSSTRUCTURE.USER_ID = '364F9F61-19B9-E720-221EC3CC6983060B' />
<cfset request.ACCESSSTRUCTURE.PROFILES_ID = '35' />
<cfset REQUEST.ACCESSSTRUCTURE.TIMEZONEOFFSET = '240.0' />
<cfset request.AccessStructure.useDayLightSavingsTime = 1 />
<cfset objDeductionManager = CreateObject("component", "mvc.Models.Deduction.DeductionManager") />

<cfset qGetDeductionData =  objDeductionManager.getDeduction('85F6571E-98B9-4F1A-8A80-718CEB61D284') />

<cfdump var="#qGetDeductionData#" />



</body>
</html>
