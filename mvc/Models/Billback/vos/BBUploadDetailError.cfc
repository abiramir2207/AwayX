<!-----------------------------------------------------------------------------

FILE NAME:		BBUploadDetail.cfc
DESCRIPTION:	BB upload detail fields declaration
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	28-Apr-2011	Created
							
------------------------------------------------------------------------------> 

<cfcomponent output="false" displayname="BBUploadDetailError" alias="mvc.Models.Billback.vos.BBUploadDetailError">
	 
	<cfproperty name="shipTo" 					type="string" hint="SAP Distributor Number" />
	<cfproperty name="dupShipTo" 				type="string" hint="Dup SAP Distributor Number::Dup_claim_org_id" />
	<cfproperty name="custNumber"				type="string" hint="Customer Distributor Number" />
	<cfproperty name="custName"					type="string" hint="Customer Distributor Name" />
	<cfproperty name="operatorLegacyId" 		type="string" hint="SAP Promoted Customer" />
	<cfproperty name="custContractNumber" 		type="string" hint="Customer Promotion Code" />
	<cfproperty name="custContractDescription" 	type="string" hint="Customer Promotion Description" />
	<cfproperty name="operatorId" 				type="string" hint="" />
	<cfproperty name="operatorName" 			type="string" hint="" />
	<cfproperty name="operatorAddress1" 		type="string" hint="" />
	<cfproperty name="operatorAddress2" 		type="string" hint="" />
	<cfproperty name="operatorCity" 			type="string" hint="" />
	<cfproperty name="operatorState" 			type="string" hint="" />
	<cfproperty name="operatorZip" 				type="string" hint="" />
	<cfproperty name="item" 			 		type="string" hint="bsa item" />
	<cfproperty name="custItem" 				type="string" hint="alias item" />
	<cfproperty name="custItemDescription" 		type="string" hint="alias item description" />
	<cfproperty name="BBProductQuantity" 		type="string" hint="" />
	<cfproperty name="caseRate" 				type="string" hint="" />
	<cfproperty name="BBRate" 			 		type="string" hint="extended dollar amount" />
	<cfproperty name="contractNumber" 			type="string" hint="bsa contract number" />
	<cfproperty name="contractTitle" 			type="string" hint="bsa contract title" />
	<cfproperty name="others"	 		 		type="string" hint="" />	
	<cfproperty name="DiscountType"		 		type="string" hint="Discount_Type" />	
 
 
	<cfscript>
		//Initialize the CFC with the default properties values.
 
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
		this.others 				= "";
		this.DiscountType			= "";
		
		//(End) These are of type object. In CF, we can get away with just initializing it like a string 
	</cfscript>

	<cffunction name="init" output="false" returntype="BBUploadDetailError">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>