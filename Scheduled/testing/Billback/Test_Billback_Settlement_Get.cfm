<html>
<head>
<title>Test Billback Settlement Get Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfparam name="url.id" default="0" />
<cfset request.ACCESSSTRUCTURE.USER_ID = '364F9F61-19B9-E720-221EC3CC6983060B' />
<cfset request.ACCESSSTRUCTURE.PROFILES_ID = '35' />
<cfset REQUEST.ACCESSSTRUCTURE.TIMEZONEOFFSET = '240.0' />
<cfset request.AccessStructure.useDayLightSavingsTime = 1 />

<cfset objBillbackSettlementManager = CreateObject("component", "mvc.Models.Billback.BillbackSettlementManager") />

<cfif url.id neq 0>
	<cfset stRetSettlementData 	= objBillbackSettlementManager.getBillbackSettlement(url.id) />
	<cfdump var="#stRetSettlementData#" />
</cfif>


</body>
</html>
