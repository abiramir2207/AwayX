<html>
<head>
<title>Test Billback Settlement Function</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
<cfset request.ACCESSSTRUCTURE.USER_ID = '364F9F61-19B9-E720-221EC3CC6983060B' />
<cfset request.ACCESSSTRUCTURE.PROFILES_ID = '35' />
<cfset REQUEST.ACCESSSTRUCTURE.TIMEZONEOFFSET = '240.0' />
<cfset request.AccessStructure.useDayLightSavingsTime = 1 />

<cfset objBillbackManager = CreateObject("component", "mvc.Models.Billback.BillbackManager") />
<cfset objBillbackSettlementManager = CreateObject("component", "mvc.Models.Billback.BillbackSettlementManager") />
<!--- 494159 --->
<cfset stGetBillbackData 	=  objBillbackManager.getBillback(2807) />
<cfset stBBHEaderData 		=  stGetBillbackData.bbHeader />
<cfset stArgs 				= structNew() />
<cfset stArgs.action		= "SAVE" />
<cfset stRetSettlementData 	= objBillbackSettlementManager.approveBillbackSettlement(stBBHEaderData, stArgs) />

<cfdump var="#stRetSettlementData#" />
<!---
<cfscript>
	//set local variables
	arrData						= arrayNew(1);
	arrBillbackProgDistProdRate = arrayNew(1);
	stDistributorListData		= structNew();
	stProductRateData			= structNew();
	lDistributorID				= "";
	strBillbackProgramID		= "";
	idxRow						= "";

	//assign local variables
	arrBillbackProgDistProdRate = stGetBillbackData.bbPrgDistItemRate;
	
	for (idxRow = 1; idxRow LTE arrayLen(arrBillbackProgDistProdRate); idxRow = (idxRow + 1))
	{
		stData = structNew();
		stData["Billback_Distributor_List.Distributor_ID"] 		= arrBillbackProgDistProdRate[idxRow]["bbDistributor"].customerId;
		
		stData["Billback_Program.Program_ID"] 					= arrBillbackProgDistProdRate[idxRow]["bbProgram"].programID;
		
		stData["Billback_Product.BB_Product_Quantity"] 			= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].volume;
		stData["Billback_Product.BB_Product_UOM"] 				= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].uom.uomId;
		stData["Billback_Product.Product_ID"]					= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].itemGuid;
		stData["Billback_Product.Distributor_ID"]				= arrBillbackProgDistProdRate[idxRow]["bbDistributor"].customerId;
		
		stData["Billback_Product_Detail.BB_Product_Type_ID"]	= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].discountType;
		stData["Billback_Product_Detail.BB_Rate"]				= arrBillbackProgDistProdRate[idxRow]["bbProdRate"].rate;
		
		//structInsert(stDistributorListData, arrBillbackProgDistProdRate[idxRow]["bbDistributor"].customerId, "", "true");
		//structInsert(stProgramListData, arrBillbackProgDistProdRate[idxRow]["bbProgram"].programID, "", "true");
		//structAppend(stProductRateData, arrBillbackProgDistProdRate[idxRow]);
		ArrayAppend(arrData, duplicate(stData));
	}

</cfscript>

--->

</body>
</html>
