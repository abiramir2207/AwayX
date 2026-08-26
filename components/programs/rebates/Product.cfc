<cfcomponent>

	<cffunction name="set" output="true" returntype="struct">

		<cfargument name="contractProdID" type="string" required="true" default="">
		<cfargument name="masterItemID" type="string" required="true" default="">
		<cfargument name="programID" type="string" required="true" default=0>
		<cfargument name="typeID" type="string" required="true" default="">
		<cfargument name="volume" type="string" required="true" default="">
		<cfargument name="item" type="string" required="true" default="">
		<cfargument name="upc" type="string" required="true" default="">
		<cfargument name="description" type="string" required="true" default="">
		<cfargument name="productInventoryUOM" type="string" required="true" default="">
		<cfargument name="EAConversion" type="string" required="true" default="">
		<cfargument name="rebateVal" type="string" required="true" default="">
		<cfargument name="net_weight" type="string" required="true" default="0">
		<cfargument name="productGroupLevel" type="numeric" required="false" default="0">
		<cfargument name="productGroupID" type="string" required="false" default="">
		<cfargument name="pricingLevel" type="string" required="false" default="1">
		<cfargument name="pricingLevelDesc" type="string" required="false" default="">
		<cfargument name="isGroup" type="string" required="false" default="0">
		<cfargument name="productGroupLevelTypeId" type="string" required="false" default="0">
		<cfargument name="qBrand" type="string" required="false" default="">
		<cfargument name="displayGroupType" type="numeric" required="false" default="0" />
		<cfargument name="typeCodeDescId" type="string" required="false" default="" />
		<cfargument name="qProductGroupValuesForItem" type="query" required="false" default="#QueryNew("Product_ID,Group_ID")#" />
		<cfargument name="EZButton_On_Default" type="boolean" required="false" default="0" />
		<cfargument name="Pack_Size" type="string" required="false" default="" />
		<cfargument name="Pack_Size_UOM" type="string" required="false" default="" />
		<!--- <cfargument name="Program_Rebates_Component_Data_ID" type="numeric" required="false" default="0" /> --->
 		<cfargument name="EZ_Contract_ID" type="string" required="false" default="" />
		<cfargument name="BaseSalesLB" type="numeric" required="false" default="0" />
		<cfargument name="BaseSalesCS" type="numeric" required="false" default="0" />
		<cfargument name="Competitor_Name_ID" type="numeric" required="false" default="0" />
		<cfargument name="Competitor_Price" type="numeric" required="false" default="0" />
		<cfargument name="Competitor_Time_Frame" type="string" required="false" default="" />
		<cfargument name="groupNumber" type="string" required="false" default="" />
		<!---62343 8.0 - Blended Rate, CF START --->
		<cfargument name="Blended_Base_Rate" type="string" required="false" default="" />
		<cfargument name="Blended_Disc_Rate" type="string" required="false" default="" />
		<cfargument name="Blended_Calc_Rate" type="string" required="false" default="" />
		<cfargument name="Blended_Adj_Rate" type="string" required="false" default="" />
		<!---62343 8.0 - Blended Rate, CF END --->
		<cfargument name="Sleeves_Per_Case" type="string" required="true" default="">

		<cfparam name="qBrand" default="" />
		<cfparam name="displayGroupName" default="" />

		<cfset productGroupForThisProduct = "" />
		<cfif arguments.qProductGroupValuesForItem.recordCount>
			<cfquery name="qProductGroupForThisProduct" dbtype="query">
				SELECT 	Group_ID
				FROM	arguments.qProductGroupValuesForItem
				WHERE	Product_ID = '#arguments.masterItemID#'
			</cfquery>
			<cfset productGroupForThisProduct = qProductGroupForThisProduct.Group_ID />
		</cfif>

		<cfscript>
			//get netweight and price list
			//thisProduct = createObject("component","components.programs.rebates.Product");
			//fobPrice = this.getPriceList(arguments.masterItemID,arguments.programID);
			fobPrice = 0;
			if(arguments.net_weight EQ 0)
				{
					netWeight = this.getNetWeight(arguments.masterItemID);
				}
			else
				{
					netWeight = arguments.net_weight;
				}
			if(displayGroupType EQ 3)
			{
				displayGroupName = this.getQBrand(arguments.masterItemID);
			}
			else if(displayGroupType EQ 1)
			{
				displayGroupName = this.getTypeCode(arguments.typeCodeDescId);
			}

			tmpStruct = structNew();
			tmpStruct.contractProdID 			= arguments.contractProdID;
			tmpStruct.masterItemID 				= arguments.masterItemID;
			tmpStruct.programID 				= arguments.programID;
			tmpStruct.typeID 					= arguments.typeID;
			tmpStruct.volume 					= arguments.volume;
			tmpStruct.fobPrice 					= fobPrice;
			tmpStruct.netWeight 				= netWeight;
			tmpStruct.item 						= arguments.item;
			tmpStruct.upc 						= arguments.upc;
			tmpStruct.description 				= arguments.description;
			tmpStruct.productInventoryUOM 		= arguments.productInventoryUOM;
			if(tmpStruct.productInventoryUOM 	== 'CS'){
				tmpStruct.productInventoryUOMID = 1;
			}
			else if (tmpStruct.productInventoryUOM == 'LB'){
				tmpStruct.productInventoryUOMID = 2;
			}
			else{
				tmpStruct.productInventoryUOMID = 3;
			}
			tmpStruct.EAConversion = 1;
			if(isNumeric(arguments.EAConversion))
			{
				tmpStruct.EAConversion = arguments.EAConversion;
			}
			tmpStruct.rebateVal 				= arguments.rebateVal;
			tmpStruct.productGroupLevel 		= arguments.productGroupLevel;
			tmpStruct.productGroupID 			= arguments.productGroupID;
			tmpStruct.pricingLevel 				= arguments.pricingLevel;
			tmpStruct.pricingLevelDesc 			= arguments.pricingLevelDesc;
			tmpStruct.isGroup 					= arguments.isGroup;
			tmpStruct.Pack_Size			 		= arguments.Pack_Size;
			tmpStruct.Pack_Size_UOM 			= arguments.Pack_Size_UOM;
			tmpStruct.productGroupLevelTypeId 	= arguments.productGroupLevelTypeId;
			tmpStruct.qBrand 					= "";
			tmpStruct.displayGroupName 			= displayGroupName;
			tmpStruct.productGroupForThisProduct= productGroupForThisProduct;
			tmpStruct.EZButton_On_Default		= arguments.EZButton_On_Default;
  			// Dev Notes: 21553/Anand Rao/19-Mar-10
		  	// HZ - min/max rates for EZ button
      			tmpStruct.EZ_Contract_ID     				= arguments.EZ_Contract_ID;
			tmpStruct.BaseSalesLB     			= arguments.BaseSalesLB;
			tmpStruct.BaseSalesCS    			= arguments.BaseSalesCS;
			tmpStruct.Competitor_Name_ID    	= arguments.Competitor_Name_ID;
			tmpStruct.Competitor_Price    		= arguments.Competitor_Price;
			tmpStruct.Competitor_Time_Frame    	= arguments.Competitor_Time_Frame;
			tmpStruct.groupNumber    			= arguments.groupNumber;
			//tmpStruct.Program_Rebates_Component_Data_ID = arguments.Program_Rebates_Component_Data_ID;
			//62343 8.0 - Blended Rate, CF START
			tmpStruct.Blended_Base_Rate    			= arguments.Blended_Base_Rate;
			tmpStruct.Blended_Disc_Rate    			= arguments.Blended_Disc_Rate;
			tmpStruct.Blended_Calc_Rate    			= arguments.Blended_Calc_Rate;
			tmpStruct.Blended_Adj_Rate    			= arguments.Blended_Adj_Rate;
			//62343 8.0 - Blended Rate, CF END
			tmpStruct.Sleeves_Per_Case 		= arguments.Sleeves_Per_Case;
		</cfscript>
		<cfreturn tmpStruct />

   	</cffunction>

   	<cffunction name="get" output="false" returntype="query">

		<cfargument name="lProductIds" type="string" required="true" default="">

		<cfquery name="qGetProducts" datasource="#application.datasource#">
			SELECT 	*
			FROM 	BSA_Foodservice_Items_Master
			WHERE	BSA_Foodservice_Items_Master_ID in (#replace(listqualify(arguments.lProductIds, "'"), '"', "'")#)
			ORDER BY BSA_Foodservice_Items_Master.Item  ASC
		</cfquery>

		<cfreturn qGetProducts />

   	</cffunction>


	<cffunction name="checkExists" output="false" returntype="boolean">

		<cfargument name="aProdToCheck" type="array" required="true" default="">
		<cfargument name="masterItemID" type="string" required="true" default="">

		<cfscript>
			doesExist = false;

			for (i=1; i lte ArrayLen(arguments.aProdToCheck); i = i+1)
			{
				if (not CompareNoCase(arguments.aProdToCheck[i].masterItemID, arguments.masterItemID)){
					doesExist = true;
				}
			}
		</cfscript>

		<cfreturn doesExist />

		</cffunction>



   	<cffunction name="getPriceList" output="false" returntype="string">

   		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="true" default="">
		<cfargument name="programID" type="string" required="false" default="">

		<!---Call the get_fob_proce stored proc to get the special price--->
		<cfstoredproc procedure="GET_FOB_PRICE_AVERAGE" datasource="#application.datasource#">

			<!--- cfprocparam tags --->
   			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@PROGRAM_ID" value="#arguments.programID#" null="no">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@@PRODUCT_ID" value="#arguments.BSA_Foodservice_Items_Master_ID#" null="no">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@@PRODUCT_TYPE_ID" value="2" null="no">
			<cfprocparam type = "Out" CFSQLType ="CF_SQL_FLOAT" variable="poundPrice" dbVarName = "@@LB_PRICE" null="no">

		</cfstoredproc>

		<cfif poundPrice eq "">
			<cfset poundPrice = 0.000 />
		</cfif>

		<cfreturn poundPrice />

   	</cffunction>

	<cffunction name="getQBrand" output="false" returntype="string">

   		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="true" default="">

		<cfif application.returned_customer_setting.use_product_q_brand EQ 1>
			<!---query to get q brand--->
			<cfquery name="qGetQBrand" datasource="#application.datasource#">
				SELECT 	Distinct(Q_Brand_Desc.Q_Brand)
				FROM 	BSA_Foodservice_Items_Master
						INNER JOIN Line_Of_Business
						ON
						Line_Of_Business.Deleted = 0
						AND Line_Of_Business.Line_Of_Business_ID = BSA_Foodservice_Items_Master.Line_Of_Business_ID
						INNER JOIN Product_Q_Brand_Desc
						ON
						Product_Q_Brand_Desc.Deleted = 0
						AND Product_Q_Brand_Desc.BSA_Foodservice_Items_Master_ID = BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID
						AND Line_Of_Business.Line_Of_Business = Product_Q_Brand_Desc.LOB
						INNER JOIN Q_Brand_Desc
						ON
						Q_Brand_Desc.Deleted = 0
						AND Q_Brand_Desc.Q_Brand_ID = Product_Q_Brand_Desc.Q_Brand_ID
				WHERE 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			</cfquery>
		<cfelse>
			<!---query to get q brand--->
			<cfquery name="qGetQBrand" datasource="#application.datasource#">
				SELECT 	Distinct(Q_Brand_Desc.Q_Brand)
				FROM 	BSA_Foodservice_Items_Master
						INNER JOIN Q_Brand_Desc
						ON
						Q_Brand_Desc.Deleted = 0
						AND Q_Brand_Desc.Q_Brand_ID = BSA_Foodservice_Items_Master.Q_Brand_ID
				WHERE 	BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
			</cfquery>
		</cfif>

		<cfreturn qGetQBrand.Q_Brand />

   	</cffunction>

	<cffunction name="getTypeCode" output="false" returntype="string">

   		<cfargument name="typeCodeDescId" type="string" required="true" />

		<cfset returnValue = "" />

		<cfif arguments.typeCodeDescId NEQ "">

			<!---query to get type code --->
			<cfquery name="qGetTypeCode" datasource="#application.datasource#" cachedwithin="#createTimeSpan(0,0,10,0)#">
				SELECT 	Distinct(Type_Code_Desc)
				FROM 	Type_Code_Desc
				WHERE 	Type_Code_Desc_ID = '#arguments.typeCodeDescId#'
			</cfquery>

			<cfif qGetTypeCode.recordCount>
				<cfset returnValue = qGetTypeCode.Type_Code_Desc />
			</cfif>

		</cfif>

		<cfreturn returnValue />

   	</cffunction>

	<cffunction name="getNetWeight" output="false" returntype="string">

   		<cfargument name="BSA_Foodservice_Items_Master_ID" type="string" required="true" default="">

		<!---query to get net weight--->
		<cfquery name="qGetNetWeight" datasource="#application.datasource#">
			SELECT 	Net_Weight
			FROM 	BSA_Foodservice_Items_Master
			WHERE 	BSA_Foodservice_Items_Master_ID = '#arguments.BSA_Foodservice_Items_Master_ID#'
		</cfquery>

		<cfreturn qGetNetWeight.Net_Weight />

   	</cffunction>

	<cffunction name="dmp" >
		<cfargument name="x" type="any" required="true" default="">
		<cfdump var="#x#" output="c:\dump.log">
	</cffunction>
</cfcomponent>

