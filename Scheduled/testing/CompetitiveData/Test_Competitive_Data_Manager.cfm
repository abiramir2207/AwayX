<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfset variables.programId = 100396 />

<cfset objCompetitiveDataManager = CreateObject("component", "components.programs.bid_request.CompetitiveDataManager") />

<cfset qGetProgramCompetitiveData = objCompetitiveDataManager.getProgramCompetitiveData(variables.programId) />
<cfset qGetProgramCompetitiveProductData = objCompetitiveDataManager.getProgramCompetitiveProductData(variables.programId) />

<cfdump var="#qGetProgramCompetitiveData#" label="Get Program Competitive Data" />
<cfdump var="#qGetProgramCompetitiveProductData#" label="Get Program Competitive Product Data" />


<cfoutput query="qGetProgramCompetitiveProductData">

	<cfset qGetProgramCompetitiveWonData = objCompetitiveDataManager.getProgramCompetitiveWonData(variables.programId, qGetProgramCompetitiveProductData.BSA_Foodservice_Items_Master_ID) />
	
	<cfdump var="#qGetProgramCompetitiveWonData#" label="Get Program Competitive Won Data" />

</cfoutput>

<cfset objCompetitiveDataSettings = CreateObject("component", "components.programs.bid_request.CompetitiveDataSettings") />

<cfset qGetWonBy		= objCompetitiveDataSettings.getWonBy() />
<cfset qGetCategory 	= objCompetitiveDataSettings.getCategory() />
<cfset qGetPackage 		= objCompetitiveDataSettings.getPackage() />
<cfset qGetSource 		= objCompetitiveDataSettings.getSource() />
<cfset qGetSourceType 	= objCompetitiveDataSettings.getSourceType() />

<cfdump var="#qGetWonBy#" label="Get Won By" />
<cfdump var="#qGetCategory#" label="Get Category" />
<cfdump var="#qGetPackage#" label="Get Package" />
<cfdump var="#qGetSource#" label="Get Source" />
<cfdump var="#qGetSourceType#" label="Get Source Type" />

</body>
</html>
