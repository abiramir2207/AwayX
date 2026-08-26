<!-----------------------------------------------------------------------------

FILE NAME:		BBUploadDetail.cfc
DESCRIPTION:	BB upload detail fields declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	28-Apr-2011	Created
							
------------------------------------------------------------------------------> 

<cfcomponent output="false" displayname="BBUploadDetail" alias="mvc.Models.Billback.vos.BBUploadDetail">
	 
	<cfproperty name="uploadID" 		 		type="numeric"	hint="" />
	<cfproperty name="shipTo" 					type="string" hint="SAP Distributor Number::Claim_Org_ID" />
	<cfproperty name="dupShipTo" 				type="string" hint="SAP Distributor Number::Dup_Claim_Org_ID" />	
	<cfproperty name="custNumber"				type="string" hint="Customer Distributor Number::DC_Org_ID" />
	<cfproperty name="custName"					type="string" hint="Customer Distributor Name::DC_Org_Desc" />
	<cfproperty name="operatorLegacyId" 		type="string" hint="SAP Promoted Customer::Operator_Org_ID" />
	<cfproperty name="custContractNumber" 		type="string" hint="Customer Promotion Code::Agreement_Num" />
	<cfproperty name="custContractDescription" 	type="string" hint="Customer Promotion Description::Agreement_Name" />
	<cfproperty name="operatorId" 				type="string" hint="DC_AC_Num" />
	<cfproperty name="operatorName" 			type="string" hint="DC_AC_Name" />
	<cfproperty name="operatorAddress1" 		type="string" hint="ST_Address_1" />
	<cfproperty name="operatorAddress2" 		type="string" hint="ST_Address_2" />
	<cfproperty name="operatorCity" 			type="string" hint="ST_City" />
	<cfproperty name="operatorState" 			type="string" hint="ST_State" />
	<cfproperty name="operatorZip" 				type="string" hint="ST_Zip_Code" />
	<cfproperty name="item" 			 		type="string" hint="bsa item::Product_Num" />
	<cfproperty name="custItem" 				type="string" hint="alias item::DC_Product_Num" />
	<cfproperty name="custItemDescription" 		type="string" hint="alias item description::DC_Product_Desc" />
	<cfproperty name="BBProductQuantity" 		type="numeric" hint="CS_Qty" />
	<cfproperty name="caseRate" 				type="string" hint="CS_Claim_Rate" />
	<cfproperty name="BBRate" 			 		type="numeric" hint="extended dollar amount::Award_Amt" />
	<cfproperty name="contractNumber" 			type="string" hint="bsa contract number::Contract_ID" />
	<cfproperty name="contractTitle" 			type="string" hint="bsa contract title" />
	<cfproperty name="bbDetailID"		 		type="numeric" hint="" />
	<cfproperty name="bbHeaderID"		 		type="numeric" hint="" />
	<cfproperty name="errMsg"			 		type="string" hint="" />
	<cfproperty name="errType"			 		type="string" hint="" />
	<cfproperty name="errObj" 					type="mvc.Models.Billback.vos.BBUploadDetailError" 	hint = "" />
	<cfproperty name="uploadtype"		 		type="string" hint="" />
	<cfproperty name="rowID"		 			type="numeric" hint="" />
	<cfproperty name="DiscountType"		 		type="string" hint="Discount_Type" />
	<cfproperty name="bEdited"		 			type="boolean" hint="decide which rows to update on save" />
 
 
	<cfscript>
		//Initialize the CFC with the default properties values.
 
		this.uploadID 				= "";
 		this.shipTo 				= "";
		this.dupShipTo				= "";
		this.custNumber 			= "";
		this.custName 				= "";
		this.operatorLegacyId 		= "";
		this.custContractNumber 	= "";
		this.custContractDescription = "";
		this.operatorId 			= "";
		this.operatorName 			= "";
		this.operatorAddress1 		= "";
		this.operatorAddress2 		= "";
		this.operatorCity 			= "";
		this.operatorState 			= "";
		this.operatorZip 			= "";
		this.item 					= "";
		this.custItem 				= "";
		this.custItemDescription 	= "";
		this.BBProductQuantity 		= "";
		this.caseRate 				= "";
		this.BBRate 				= "";
		this.contractNumber 		= "";
		this.contractTitle 			= "";
		this.bbDetailID 			= "";
		this.bbHeaderID 			= "";
		this.errMsg 				= "";
		this.errType 				= "";
		this.errObj 				= "";
		this.uploadType 			= "";
		this.rowID					= "";	
		this.DiscountType			= "";
		this.bEdited				= 0;
 
 
		//(End) These are of type object. In CF, we can get away with just initializing it like a string 
	</cfscript>

	<cffunction name="init" output="false" returntype="BBUploadDetail">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>