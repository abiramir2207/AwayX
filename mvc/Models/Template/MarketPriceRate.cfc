<cfcomponent name="MarketPriceRate" displayname="MarketPriceRate">

	<cffunction name="getProductRate"output="false" returntype="query" hint="function to return all product rates for a given program product type">
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="status" type="string" required="true" hint="" />
		<cfargument name="iMarketPriceListId" type="Numeric" default="0" />

		<cfscript>
			//set local variables
			//nTemplate_Filters_Id,1,arguments.status,arguments.iMarketPriceListId
			var nTemplate_Filters_Id	= "";
			var qGetRateData			= "";
	
			//assign local variables
			nTemplate_Filters_Id	= arguments.Template_Filters_Id;
		    //get rates
			qGetRateData	= getMPProductRateData(nTemplate_Filters_Id,arguments.status,arguments.iMarketPriceListId);
			
			return qGetRateData;
			
		</cfscript>
		
	</cffunction>
	
	<cffunction name="getMPProductRateData"output="false" returntype="query" hint="function to return fixed price rate product data">
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="status" required="false" default="0" />
		<cfargument name="iMarketPriceListId" type="Numeric" default="0" />
		<cfscript>
			//set local variables
			var nProgramID	= "";
			var qGetData	= "";	
			var qRetData	= "";
	
			//assign local variables
			nTemplate_Filters_Id 			= arguments.Template_Filters_Id;
		</cfscript>
		
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT DISTINCT	MPR.BSA_Foodservice_Items_Master_Id AS itemGuid,
					MPR.Item AS itemNumber,
					UOM.Unit_Of_Measure_ID AS uomId,
					UOM.Unit_Of_Measure_Desc AS description,
					UOM.Abbreviation_Singular AS abbreviation,
					MPR.rate AS rate,
					MP.Market_Price_List_Id AS componentId,
					-- TF.Description AS name,
					MP.Status + ' [' + CONVERT(char(10), Start_Date, 101) + '] ' AS name,
					MP.Start_Date,
					MP.End_Date,
					MP.Status,
					MP.Created_User_Id,
					U.Name_first + ' ' + U.Name_Last AS UpdatedUserName,
					MP.Updated_Date AS UpdatedDate,
					'' AS paidTo,
					'' AS programComponentId,
					'' AS claimMechanicId,
					0 AS claimMechPayeeTypeId,
					0 AS payeeTypeId,
					'' AS payeeName,
					--Program_Fixed_Component.Vendor_Master_ID AS payeeId,
					'' AS payeeId,
					'' AS claimMechanicDesc,
					'' AS glAccountId,
					'' AS glDescription,
					0 AS volume
			FROM Template_Filters TF
			INNER JOIN Market_Price_List MP ON
					MP.Template_Filters_Id = TF.Template_Filters_Id
			LEFT JOIN _Users U ON
				U.User_id = Mp.Updated_User_Id
			LEFT JOIN Market_Price_Product_Rates MPR ON
				MP.Market_Price_List_Id = MPR.Market_Price_List_Id
			LEFT JOIN Units_Of_Measure UOM ON
					UOM.Unit_Of_Measure_ID = MPR.Uom_Id
			WHERE TF.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#nTemplate_Filters_Id#"> AND
				MP.Deleted = 0
				<cfif Status NEQ '0'>
					AND MP.Status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.status#">
				</cfif>
				<cfif arguments.iMarketPriceListId NEQ '0'>
					AND MP.Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iMarketPriceListId#">
				</cfif>
				AND (MP.End_Date IS NULL OR MP.End_Date >= <cfoutput>'#dateFormat(now(),"mm/dd/yyyy")#'</cfoutput>)
				--- GROUP RECORDS ONLY
				AND ISNULL(MPR.Captured_From_Group,0) = 0
			ORDER BY MP.Start_Date ASC
			<!---MP.Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#">--->
		</cfquery>
		<!---<cfdump var="#qGetData#" output="c:\dump.log" >--->
		<cfset qRetData = qGetData />
		
		<cfreturn qRetData />
		
	</cffunction>
	
	<cffunction name="getProductRateDataStruct" output="false" returntype="array">
		
		<cfargument name="productRateData" type="query" required="true">
		<cfargument name="componentId" type="Numeric" required="true">
		
		<cfscript>
			//set local variables
			var qProductRateData	= "";
			var nCompID				= "";
			var arrRetData			= ArrayNew(1);
	
			//assign local variables
			qProductRateData	= arguments.productRateData;
			nCompID				= arguments.componentId;
			
			//Loop over query object and build the prodRate object
			for (idxRow = 1; idxRow LTE qProductRateData.RecordCount; idxRow = (idxRow + 1))
			{
				
				if(qProductRateData["componentId"][idxRow] eq nCompID)
				{
					if(trim(qProductRateData["itemGuid"][idxRow] != '')){
						stUom = structNew();
						stUomData = structNew();
						stUomData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
						stUomData["uomId"] = trim(qProductRateData["uomId"][idxRow]);
						stUomData["description"] = trim(qProductRateData["description"][idxRow]);
						stUomData["abbreviation"] = trim(qProductRateData["abbreviation"][idxRow]);
						stUom = stUomData;
						
						stData = structNew();
						stData["__type__"] = "mvc.Models.Program.Component.vos.ProdRate";
						stData["itemGuid"] = trim(qProductRateData["itemGuid"][idxRow]);
						stData["itemNumber"] = trim(qProductRateData["itemNumber"][idxRow]);
						stData["rate"] = trim(qProductRateData["rate"][idxRow]);
						stData["uom"] = stUom;
						stData["volume"] = trim(qProductRateData["volume"][idxRow]);
		            	ArrayAppend(arrRetData, duplicate(stData));
					}
	            }
			}
			
			return arrRetData;
		</cfscript>
		
	</cffunction>

</cfcomponent>