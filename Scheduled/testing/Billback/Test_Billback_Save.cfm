<html>
<head>
<title>Test Billback Save Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfset request.ACCESSSTRUCTURE.USER_ID = '364F9F61-19B9-E720-221EC3CC6983060B' />
<cfset request.ACCESSSTRUCTURE.PROFILES_ID = '35' />
<cfset objBillbackManager = CreateObject("component", "mvc.Models.Billback.BillbackManager") />
<cfset objBillbackEditManager = CreateObject("component", "mvc.Models.Billback.BillbackEditManager") />
<!--- 494159 --->
<cfset stGetBillbackData =  objBillbackManager.getBillback(128) />


<cfset stGetBillbackData.bbHeader.billbackIDInt = "" />

<cfset stRetGetBillbackData = objBillbackEditManager.saveBillback(stGetBillbackData) />

<cfdump var="#stRetGetBillbackData#" />
<cfabort>

</body>
</html>
