<!---
Name: 			BillbackEditSearchManager.cfc
Copyright:		(c) 2005 Blacksmith Applications, Inc.
Created Date:  	05/23/2011
Created By:    	Tim Ford
Description:	I am responsible for assembling and returning data needed for billback edit.
Parameters:		N/A
Usage:			N/A
--->
<cfcomponent name="BillbackEditSearchManager" displayname="BillbackEditSearchManager">

	<!--- initialize the BillbackDAO to use for all functions in BillbackEditSearchManager --->
	<cfscript>
		objBillbackEditSearchDAO 		= CreateObject("component","mvc.Models.Billback.BillbackEditSearchDAO");
	</cfscript>

	<!--- get program data JSON--->
    <cffunction name="getProgramListJSON" output="false" access="remote" returnformat="JSON">
		<cfargument name="userId"			required="true"		type="string" />
		<cfargument name="startDate" 		required="true" 	type="date" />
		<cfargument name="endDate" 			required="true" 	type="date" />
		<cfargument name="payee" 			required="true" 	type="struct" />
		<cfargument name="programNumber"	required="false"	type="string" default="" />
		<cfargument name="distributorId"	required="false"	type="string" default="" />
		<cfargument name="operatorId"		required="false"	type="string" default="" />

		<cfscript>
			var jsonData = '';
			var arrProgramList = getProgramList(
					arguments.userId,
					arguments.startDate,
					arguments.endDate,
					arguments.payee,
					arguments.programNumber,
					arguments.distributorId,
					arguments.operatorId
				);
			arrProgramList = application.util.struct.structSortLowerCase(arrProgramList);
			jsonData = serializeJSON(arrProgramList,"struct");
		</cfscript>

		<cfreturn jsonData/>
	</cffunction>

	<!--- get program data--->
	<cffunction name="getProgramList" output="false" access="remote">

		<cfargument name="userId"			required="true"		type="string" />
		<cfargument name="startDate" 		required="true" 	type="date" />
		<cfargument name="endDate" 			required="true" 	type="date" />
		<cfargument name="payee" 			required="true" 	type="struct" />
		<cfargument name="programNumber"	required="false"	type="string" default="" />
		<cfargument name="distributorId"	required="false"	type="string" default="" />
		<cfargument name="operatorId"		required="false"	type="string" default="" />

		<cfscript>
			//set local variables
			var strUserID		= "";
			var dtStartDate		= "";
			var dtEndDate		= "";
			var stPayee			= structNew();
			var	qGetProgramData	= "";
			var idxRow			= "";
			var stData			= structNew();
			var arrRet			= arrayNew(1);
			var strProgNumber	= "";
			var strDistNumber	= "";
			var strOperNumber	= "";
			var objUserManager	= "";
			var gGetUserData	= "";
			var strProfileId	= "";

			//assign local variables
			strUserID		= arguments.userId;
			dtStartDate		= arguments.startDate;
			dtEndDate		= arguments.endDate;
			stPayee			= arguments.payee;
			strProgNumber	= arguments.programNumber;
			strDistNumber	= arguments.distributorId;
			strOperNumber	= arguments.operatorId;

			objUserManager = CreateObject("component", "components.user.UserManager");
            gGetUserData = objUserManager.getUser(strUserID);
            strProfileId = gGetUserData.Profiles_ID;

			qGetProgramData = objBillbackEditSearchDAO.searchProgramList(strUserID, dtStartDate, dtEndDate, stPayee, strProgNumber, strDistNumber, strOperNumber, strProfileId);

			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetProgramData.RecordCount; idxRow = (idxRow + 1))
			{
				//Populate Program VO;
				stData = structNew();
				// stData["__type__"] = "mvc.Models.Program.Component.vos.Program";
				stData["__type__"] = "mvc.Models.Billback.vos.BBProgram";
				stData["programId"] = qGetProgramData["programId"][idxRow];
				stData["number"] = qGetProgramData["number"][idxRow];
				stData["title"] = qGetProgramData["title"][idxRow];
				stData["startDate"] = qGetProgramData["startDate"][idxRow];
				stData["endDate"] = qGetProgramData["endDate"][idxRow];
				stData["effectiveStartDate"] = qGetProgramData["effectiveStartDate"][idxRow];
				stData["effectiveEndDate"] = qGetProgramData["effectiveEndDate"][idxRow];
				stData["bIsLatestVersion"] = qGetProgramData["bIsLatestVersion"][idxRow];
				ArrayAppend(arrRet, duplicate(stData));
			}

			return arrRet;
		</cfscript>

	</cffunction>

	<!--- get vendor data--->
	<cffunction name="getVendorData" output="false" access="remote">

		<cfargument name="vendorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strVendorId		= "";
			var stRetData		= "";
			var	qGetVendorData	= "";
			var idxRow			= "";

			//assign local variables
			strVendorId		= arguments.vendorId;

			qGetVendorData 	= objBillbackEditSearchDAO.searchVendorData(strVendorId);
			stRetData 		= CreateObject("component","mvc.Models.Entity.vos.Payee").init();

			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetVendorData.RecordCount; idxRow = (idxRow + 1))
			{

				//Populate Vendor VO
				stRetData.payeeTypeId				= 1;
				stRetData.name 						= qGetVendorData["name"][idxRow];
				stRetData.payeeId					= qGetVendorData["payeeId"][idxRow];
				stRetData.address.addressLine1 		= qGetVendorData["addressLine1"][idxRow];
				stRetData.address.addressLine2 		= qGetVendorData["addressLine2"][idxRow];
				stRetData.address.city 				= qGetVendorData["city"][idxRow];
				stRetData.address.state 			= qGetVendorData["state"][idxRow];
				stRetData.address.zipCode 			= qGetVendorData["zipCode"][idxRow];

			}
			return stRetData;
		</cfscript>

	</cffunction>

	<!--- get vendor data--->
	<cffunction name="getVendorDataJSON" output="false" returntype="string" returnformat="JSON" access="remote">

		<cfargument name="vendorId"	required="true"	type="string" />

		<cfscript>
			var jsonData = '';
			var vend = getVendorData(
					arguments.vendorId
				);
			vend = application.util.struct.structSortLowerCase(vend);
			jsonData = serializeJSON(vend,"struct");
		</cfscript>

		<cfreturn jsonData/>

	</cffunction>

	<!--- get payee data--->
	<cffunction name="getPayeeData" output="false" access="remote">

		<cfargument name="payeeId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strPayeeId		= "";
			var stRetData		= structNew();
			var	qGetPayeeData	= "";
			var idxRow			= "";

			//assign local variables
			strPayeeId			= arguments.payeeId;

			qGetPayeeData = objBillbackEditSearchDAO.searchPayeeData(strPayeeId);

			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetPayeeData.RecordCount; idxRow = (idxRow + 1))
			{
				//Populate Address VO
				stData = structNew();
				stData["__type__"]			= "mvc.Models.Entity.vos.Address";
				stData["addressLine1"]		= qGetPayeeData["addressLine1"][idxRow];
				stData["addressLine2"]		= qGetPayeeData["addressLine2"][idxRow];
				stData["city"]				= qGetPayeeData["city"][idxRow];
				stData["state"]				= qGetPayeeData["state"][idxRow];
				stData["zipCode"]			= qGetPayeeData["zipCode"][idxRow];

				//Populate Payee VO
				stRetData["__type__"]		= "mvc.Models.Entity.vos.Payee";
				stRetData["payeeTypeId"]	= 1;
				stRetData["name"]			=  qGetPayeeData["name"][idxRow];
				stRetData["payeeId"]		=  qGetPayeeData["payeeId"][idxRow];
				stRetData["address"]		= stData;

			}
			return stRetData;
		</cfscript>

	</cffunction>

	<cffunction name="getPayeeList" output="false" access="remote">

		<cfargument name="vendorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strVendorId			= "";
			var arrRetData			= arrayNew(1);
			var stPayeeData			= structNew();
			var stData				= structNew();
			var	qGetPayeeListData	= "";
			var idxRow				= "";

			//assign local variables
			strVendorId			= arguments.vendorId;

			qGetPayeeListData = objBillbackEditSearchDAO.searchPayeeList(strVendorId);

			//Loop over query object and build an array of Payee VOs
			for (idxRow = 1; idxRow LTE qGetPayeeListData.RecordCount; idxRow = (idxRow + 1))
			{
				//Populate Address VO
				stData = structNew();
				stData["__type__"] 				= "mvc.Models.Entity.vos.Address";
				stData["addressLine1"]			= qGetPayeeListData["addressLine1"][idxRow];
				stData["addressLine2"] 			= qGetPayeeListData["addressLine2"][idxRow];
				stData["city"] 					= qGetPayeeListData["city"][idxRow];
				stData["state"]					= qGetPayeeListData["state"][idxRow];
				stData["zipCode"] 				= qGetPayeeListData["zipCode"][idxRow];

				//Populate Payee VO
				stPayeeData = structNew();
				stPayeeData["__type__"]			= "mvc.Models.Entity.vos.Payee";
				stPayeeData["payeeTypeId"]		= qGetPayeeListData["payeeTypeId"][idxRow];
				stPayeeData["name"]				=  qGetPayeeListData["name"][idxRow];
				stPayeeData["payeeId"]			=  qGetPayeeListData["payeeId"][idxRow];
				stPayeeData["address"]			= stData;
				stPayeeData["payeeUUId"]		=  qGetPayeeListData["payeeUUId"][idxRow];
				ArrayAppend(arrRetData, duplicate(stPayeeData));

			}
			return arrRetData;
		</cfscript>

    </cffunction>

	<cffunction name="getPayeeListJSON" output="false" returntype="string" returnformat="JSON" access="remote">

		<cfargument name="vendorId"	required="true"	type="string" />

		<cfscript>
			var jsonData = '';
			var arrPayeeList = getPayeeList( arguments.vendorId );
			arrPayeeList = application.util.struct.structSortLowerCase(arrPayeeList);
			jsonData = serializeJSON(arrPayeeList,"struct");
		</cfscript>

		<cfreturn jsonData/>

    </cffunction>

	<!--- get distributor data--->
	<cffunction name="getDistributorData" output="false" access="remote">

		<cfargument name="distributorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strDistributorId	= "";
			var stCustData			= structNew();
			var arrRet				= arrayNew(1);
			var	qGetDistributorData	= "";
			var idxRow				= "";

			//assign local variables
			strDistributorId			= arguments.distributorId;

			qGetDistributorData = objBillbackEditSearchDAO.searchDistributorData(strDistributorId);

			//Loop over query object and build an array of Customer VOs
			for (idxRow = 1; idxRow LTE qGetDistributorData.RecordCount; idxRow = (idxRow + 1))
			{
				//Populate Address VO
				stData = structNew();
				stData["__type__"] 		= "mvc.Models.Entity.vos.Address";
				stData["addressLine1"] 	= qGetDistributorData["addressLine1"][idxRow];
				stData["addressLine2"] 	= qGetDistributorData["addressLine2"][idxRow];
				stData["city"] 			= qGetDistributorData["city"][idxRow];
				stData["state"] 		= qGetDistributorData["state"][idxRow];
				stData["zipCode"] 		= qGetDistributorData["zipCode"][idxRow];

				//Populate Payee VO
				stCustData["__type__"] 		= "mvc.Models.Entity.vos.Customer";
				stCustData["shipTo"] 		=  qGetDistributorData["shipTo"][idxRow];
				stCustData["name"] 			=  qGetDistributorData["name"][idxRow];
				stCustData["customerId"] 	=  qGetDistributorData["customerId"][idxRow];
				stCustData["address"] 		= stData;
				ArrayAppend(arrRet, duplicate(stCustData));

			}
			return arrRet;

		</cfscript>

	</cffunction>

	<!--- get payee data--->
	<cffunction name="getDistributorDataJSON" output="false"  returntype="string" returnformat="JSON" access="remote">

		<cfargument name="distributorId"	required="true"	type="string" />
		<cfscript>
			var jsonData = '';
			var cust = getDistributorData(
					arguments.distributorId
				);
			cust = application.util.struct.structSortLowerCase(cust);
			jsonData = serializeJSON(cust,"struct");
		</cfscript>

		<cfreturn jsonData/>

	</cffunction>

	<!--- get operator data--->
	<cffunction name="getOperatorData" output="false" access="remote">

		<cfargument name="operatorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strOperatorId		= "";
			var stOperatorData		= structNew();
			var arrRet				= arrayNew(1);
			var	qGetOperatorData	= "";
			var idxRow				= "";

			//assign local variables
			strOperatorId			= arguments.operatorId;

			qGetOperatorData = objBillbackEditSearchDAO.searchOperatorData(strOperatorId);

			//Loop over query object and build an array of Operator VOs
			for (idxRow = 1; idxRow LTE qGetOperatorData.RecordCount; idxRow = (idxRow + 1))
			{
				//Populate Address VO
				stData = structNew();
				stData["__type__"] 		= "mvc.Models.Entity.vos.Address";
				stData["addressLine1"] 	= qGetOperatorData["addressLine1"][idxRow];
				stData["addressLine2"] 	= qGetOperatorData["addressLine2"][idxRow];
				stData["city"] 			= qGetOperatorData["city"][idxRow];
				stData["state"] 		= qGetOperatorData["state"][idxRow];
				stData["zipCode"] 		= qGetOperatorData["zipCode"][idxRow];

				//Populate Payee VO
				stOperatorData["__type__"] 	= "mvc.Models.Entity.vos.Operator";
				stOperatorData["ID"] 		=  qGetOperatorData["ID"][idxRow];
				stOperatorData["name"] 		=  qGetOperatorData["name"][idxRow];
				stOperatorData["address"] 	= stData;
				stOperatorData["bsaOperatorId"] 	=  qGetOperatorData["BSA_Operator_ID"][idxRow];
				stOperatorData["legacyId"] 		=  qGetOperatorData["Legacy_ID"][idxRow];
				ArrayAppend(arrRet, duplicate(stOperatorData));

			}
			return arrRet;

		</cfscript>

	</cffunction>

	<!--- get product data --->
	<cffunction name="getProductData" output="false" access="remote">

		<cfargument name="lItemGuids" required="false" default="" />

		<cfscript>
			//set local variables
			var lItemMasterIds		= "";
			var arrRet				= arrayNew(1);
			var stData				= structNew();
			var	qGetProductData		= "";
			var idxRow				= "";

			//assign local variables
			lItemMasterIds = arguments.lItemGuids;

			qGetProductData = objBillbackEditSearchDAO.searchProductData(lItemMasterIds);

			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetProductData.RecordCount; idxRow = (idxRow + 1))
			{

            	stData = structNew();
				//Populate struct
				stData["itemGuid"]			=	qGetProductData["itemGuid"][idxRow];
				stData["itemNumber"] 		=  	qGetProductData["itemNumber"][idxRow];
				stData["description"]		=  	qGetProductData["itemDescription"][idxRow];
				stData["netWeight"] 		=  	qGetProductData["netWeight"][idxRow];
				ArrayAppend(arrRet, duplicate(stData));

			}
			return arrRet;
		</cfscript>

	</cffunction>

	<!--- get product data JSON--->
	<cffunction name="getProductDataJSON" output="false"  returntype="string" returnformat="JSON" access="remote">

		<cfargument name="lItemGuids" required="false" default="" />
		<cfscript>
			var jsonData = '';
			var prod = getProductData(
					arguments.lItemGuids
				);
			prod = application.util.struct.structSortLowerCase(prod);
			jsonData = serializeJSON(prod,"struct");
		</cfscript>

		<cfreturn jsonData/>

	</cffunction>

	<!--- get product list --->
	<cffunction name="getProductList" output="false" access="remote" returntype="array">

		<cfscript>
			//set local variables
			var arrRet				= arrayNew(1);
			var stData				= structNew();
			var	qGetProductData		= "";
			var idxRow				= "";

			qGetProductData = objBillbackEditSearchDAO.searchProductList();

			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetProductData.RecordCount; idxRow = (idxRow + 1))
			{

            	stData = structNew();
				//Populate struct
				stData["itemGuid"]			=	qGetProductData["itemGuid"][idxRow];
				stData["itemNumber"] 		=  	qGetProductData["itemNumber"][idxRow];
				stData["description"]		=  	qGetProductData["itemDescription"][idxRow];
				stData["netWeight"] 		=  	qGetProductData["netWeight"][idxRow];
				ArrayAppend(arrRet, duplicate(stData));

			}
			return arrRet;
        </cfscript>

    </cffunction>


	<!--- get product data JSON--->
	<cffunction name="getProductListJSON" output="false"  returntype="string" returnformat="JSON" access="remote">

		<cfscript>
			var jsonData = '';
			var prodListData = this.getProductList();
			jsonData = application.util.struct.structSortLowerCase(prodListData);
			jsonData = serializeJSON(jsonData,"struct");
		</cfscript>

		<cfreturn jsonData/>

	</cffunction>

	<!--- get distributor list --->
	<cffunction name="getDistributorList" output="false" access="remote" returntype="array">

		<cfscript>
			//set local variables
			var arrRet				= arrayNew(1);
			var stData				= structNew();
			var stCustomerData		= structNew();
			var	qGetDistributorData	= "";
			var idxRow				= "";

			qGetDistributorData = objBillbackEditSearchDAO.searchDistributorList();

			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetDistributorData.RecordCount; idxRow = (idxRow + 1))
			{
				//Populate Address VO
				/*
				stData = structNew();
				stData["__type__"] 		= "mvc.Models.Entity.vos.Address";
				stData["addressLine1"] 	= qGetDistributorData["addressLine1"][idxRow];
				stData["addressLine2"] 	= qGetDistributorData["addressLine2"][idxRow];
				stData["city"] 			= qGetDistributorData["city"][idxRow];
				stData["state"] 		= qGetDistributorData["state"][idxRow];
				stData["zipCode"] 		= qGetDistributorData["zipCode"][idxRow];
				*/

				//Populate Customer VO
				stCustomerData["__type__"] 		= "mvc.Models.Entity.vos.Customer";
				stCustomerData["shipTo"]		= qGetDistributorData["shipTo"][idxRow];
				stCustomerData["name"] 			=  qGetDistributorData["name"][idxRow];
				stCustomerData["customerId"] 	=  qGetDistributorData["customerId"][idxRow];
				stCustomerData["address"] 		= stData;
				ArrayAppend(arrRet, duplicate(stCustomerData));

			}
			return arrRet;
		</cfscript>

	</cffunction>

	<!--- get product data JSON--->
	<cffunction name="getBillToDataJSON" output="false"  returntype="string" returnformat="JSON" access="remote">
		<cfargument name="distributorId"	required="true"	type="string" />
		<cfscript>
			var jsonData = '';
			var aBillto = this.getBillToData(arguments.distributorId);
			jsonData = application.util.struct.structSortLowerCase(aBillto);
			jsonData = serializeJSON(jsonData,"struct");
		</cfscript>

		<cfreturn jsonData/>

	</cffunction>


	<!--- get distributor data--->
	<cffunction name="getBillToData" output="false" access="remote">

		<cfargument name="distributorId"	required="true"	type="string" />

		<cfscript>
			//set local variables
			var strDistributorId	= "";
			var stCustData			= structNew();
			var arrRet				= arrayNew(1);
			var	qGetDistributorData	= "";
			var idxRow				= "";

			//assign local variables
			strDistributorId			= arguments.distributorId;

			qGetDistributorData = objBillbackEditSearchDAO.searchBillToData(strDistributorId);

			//Loop over query object and build an array of Customer VOs
			for (idxRow = 1; idxRow LTE qGetDistributorData.RecordCount; idxRow = (idxRow + 1))
			{
				//Populate Address VO
				stData = structNew();
				stData["__type__"] 		= "mvc.Models.Entity.vos.Address";
				stData["addressLine1"] 	= qGetDistributorData["addressLine1"][idxRow];
				stData["addressLine2"] 	= qGetDistributorData["addressLine2"][idxRow];
				stData["city"] 			= qGetDistributorData["city"][idxRow];
				stData["state"] 		= qGetDistributorData["state"][idxRow];
				stData["zipCode"] 		= qGetDistributorData["zipCode"][idxRow];

				//Populate BillTo VO
				stCustData["__type__"] 		= "mvc.Models.Entity.vos.BillTo";
				stCustData["billTo"] 		=  qGetDistributorData["billTo"][idxRow];
				stCustData["name"] 			=  qGetDistributorData["name"][idxRow];
				stCustData["billToId"] 		=  qGetDistributorData["billToId"][idxRow];
				stCustData["shipTo"] 		=  qGetDistributorData["shipTo"][idxRow];
				stCustData["shipToId"] 		=  qGetDistributorData["shipToId"][idxRow];
				stCustData["address"] 		= stData;
				ArrayAppend(arrRet, duplicate(stCustData));

			}
			return arrRet;

		</cfscript>

	</cffunction>

	<!--- get program product list --->
	<cffunction name="getProgramProductList" output="false" access="remote" returntype="array">

		<cfargument name="billbackIDInt" type="numeric" required="true" default="">

		<cfscript>
			//set local variables
			var nBillbackID		= "";
			var arrRet			= arrayNew(1);
			var stData			= structNew();
			var	qGetProductData	= "";
			var idxRow			= "";

			//assign local variables
			nBillbackID	= arguments.billbackIDInt;
			qGetProductData = objBillbackEditSearchDAO.searchProgramProductData(nBillbackID);

			//Loop over query object and build an array of Program VOs
			for (idxRow = 1; idxRow LTE qGetProductData.RecordCount; idxRow = (idxRow + 1))
			{

            	stData = structNew();
				//Populate struct
				stData["itemGuid"]			=	qGetProductData["itemGuid"][idxRow];
				stData["itemNumber"] 		=  	qGetProductData["itemNumber"][idxRow];
				stData["description"]		=  	qGetProductData["itemDescription"][idxRow];
				stData["netWeight"] 		=  	qGetProductData["netWeight"][idxRow];
				stData["number"]		=  	qGetProductData["number"][idxRow];
				ArrayAppend(arrRet, duplicate(stData));

			}
			return arrRet;
		</cfscript>

	</cffunction>

</cfcomponent>