<cfcomponent name="MarketPriceManager" displayname="MarketPriceManager" hint="a collevtion of functions used to access Market Price data" extends="mvc.Models.SettingsService" >
	
	<cfscript>
		objMarketPriceRate		= CreateObject("component","mvc.Models.Template.MarketPriceRate");//ok
		objMarketPriceRateDAO	= CreateObject("component","mvc.Models.Template.MarketPriceDAO");
	</cfscript>
	<!--- Based on a program component obj, the MP get component is really concerned with the ProdRate obj.
			** the rest of the component data (claimMech, payee, etc is ignored)
			The Flex MP approval screen uses this for it main Get --->
	<cffunction name="getMarketPriceLists" access="remote" output="false" returntype="Array" hint="function to return Market Price Lists for a Template Filter">
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="argObjType" type="string" default="comp" />
		<cfargument name="status" required="false" default="0" />
		<cfargument name="iMarketPriceListId" type="Numeric" default="0" />
		<cfscript>
			//set local variables
			var nTemplate_Filters_Id	= "";
			var qGetFixedData			= "";
			var qGetRebateData			= "";
			var arrRet 					= ArrayNew(1);
			var mpObjType				= arguments.argObjType;
			
			nTemplate_Filters_Id 	= arguments.Template_Filters_Id;
			//run the query
			qGetMPData 			= objMarketPriceRate.getProductRate(nTemplate_Filters_Id,arguments.status,arguments.iMarketPriceListId);//TODO: NO iMPId in objMarketPriceRate.getProductRate
	
			arrRet = getMPDataStruct(qGetMPData,nTemplate_Filters_Id,1,arrRet,mpObjType);
			//this.dmp(qGetMPData);
		</cfscript>

		<cfreturn arrRet />
		
	</cffunction>
	
	<cffunction name="getMPDataStruct" output="false" returntype="Array">
		<!---GET TYPED MARKET PRICE DATA :: 'Comp' used For Prodrate tool  :: ELSE type = MarketPrice--->
		<cfargument name="componentData" type="query" required="true" />
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="type" type="Numeric" required="true" />
		<cfargument name="returnArray" type="array" required="true" />
		<cfargument name="argObjType" type="string" default="comp" />
		<cfscript>
			//set local variables
			var qComponentData	= "";
			var nTemplateFiltersId	= "";
			var nType			= "";
			var arrProdRate 	= ArrayNew(1);
			var arrRetData		= "";
			var stPayee 		= "";
			var mpObjType		= arguments.argObjType;
			
			//assign local variables
			qComponentData	= arguments.componentData;
			nTemplateFiltersId	= arguments.Template_Filters_Id;
			nType			= arguments.type;
			arrRetData		= arguments.returnArray;
		</cfscript>
		<cfoutput query="qComponentData" group="componentId">	
			<cfscript>
				//build PaidTo Object
				/*stPaidTo = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.PaidTo";
				stData["paidToId"] = "";
				stData["description"] = "";
				stPaidTo = stData;
				//build PaymentCycle Object
				// get the PaymentCycle ID and Description
				//nPaymentCycleID = objPaymentCycleManager.getPaymentCycle(nProgramID, nType, qComponentData.programComponentId);
				//sPaymentCycleDesc = objPaymentCycleManager.getPaymentCycleDescription(nPaymentCycleID);
				stPaymentCycle = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.PaymentCycle";
				stData["paymentCycleId"] = "";
				stData["description"] = "";
				stPaymentCycle = stData;
				//build ClaimMechanic Object
				stClaimMechanic = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.ClaimMechanic";
				stData["claimMechanicId"] = "";
				stData["description"] = "";
				stData["payeeTypeId"] = "";
				stClaimMechanic = stData;
				//build GlAccount Object
				stGlAccount = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.GlAccount";
				stData["glAccountId"] = "";
				stData["description"] = "";
				stGlAccount = stData;*/
				
				//build Payee Object
				stPayee = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.Payee";
				stData["payeeTypeId"] = "";
				stData["name"] = "";
				stData["payeeId"] = "";
				stPayee = stData;
				
				arrProdRate 	= objMarketPriceRate.getProductRateDataStruct(qComponentData, componentId);
				if(mpObjType == 'comp'){
					//build Component Object
					stData = structNew();
					stData["__type__"] = "mvc.Models.Program.Component.vos.Component";
					stData["componentId"] = qComponentData.componentId;
					stData["name"] = qComponentData.name;
					stData["type"] = nType;
					stData["prodRate"] = arrProdRate;
					/*stData["paidTo"] = stPaidTo;
					stData["paymentCycle"] = stPaymentCycle;
					stData["claimMechanic"] = stClaimMechanic;
					stData["glAccount"] = stGlAccount;*/
					stData["payee"] = stPayee;
					stData["uom"] = getMPUomData(nTemplateFiltersId);
					stData["bMarketPriceTemplate"] = "";
					ArrayAppend(arrRetData, duplicate(stData));
				}
				else{
					//build Component Object
					stData = structNew();
					stData["__type__"] = "mvc.Models.Template.MarketPrice";
					stData["Market_Price_List_Id"] = qComponentData.componentId;
					stData["Template_Filters_Id"] = nTemplateFiltersId;
					stData["Start_Date"] = qComponentData.Start_Date;
					stData["End_Date"] = qComponentData.End_Date;
					stData["CreatedUserId"] = qComponentData.Created_User_Id;
					stData["UpdatedUserName"] = qComponentData.UpdatedUserName;
					stData["UpdatedDate"] = qComponentData.UpdatedDate;
					stData["Status"] = qComponentData.Status;
					stData["arrProdRate"] = arrProdRate;
					ArrayAppend(arrRetData, duplicate(stData));
				}
				
			</cfscript>
		</cfoutput>
		
		<cfreturn arrRetData />
		
	</cffunction>

	 <cffunction name="getMPUomData" output="false" returntype="array" hint="function to return uom data">
	 <!--- GET MP UOM RETURNS UOM OBJECT BASED ON TEMPLATE SETTING --->
		<cfargument name="Template_Filters_Id" 	type="Numeric" required="true" />

		<cfscript>
			//set local variables
			var nTemplateFiltersId 	= "";
			var nType			= "";
			var arrUom			= ArrayNew(1);
			var qUOM 			= "" ;
			var qTemplateUOM	= "" ;
			var stData			= "";
			var uom_id_list		= "";
			//assign local variables
			nTemplateFiltersId	= arguments.Template_Filters_Id;
		</cfscript>
		
		<!--- get MP details that will be stored as a component --->
		<cfquery name="qTemplateUOM" datasource="#application.datasource#">
			SELECT	PCPO.RateTypeOption_2, --case (id = 1)
					PCPO.RateTypeOption_1  --lb (id = 2)
			FROM Template_Filters TF
			INNER JOIN Market_Price_List MP ON
				MP.Template_Filters_Id = TF.Template_Filters_Id
			INNER JOIN Program_Control_Panel_Options PCPO ON
				PCPO.First_Parent_ID = TF.Parent_Template_Id
			WHERE TF.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#nTemplateFiltersId#"> AND
				TF.Deleted = 0 AND
				<!---MP.Market_Price_List_Id = <cfqueryparam value="#nTemplateFiltersId#" cfsqltype="cf_sql_integer" /> AND--->
				PCPO.Deleted = 0 AND
				PCPO.IsDominant = 1 
		</cfquery>
		<cfif qTemplateUOM.RateTypeOption_2 EQ 1>
			<CFSET uom_id_list = listappend(uom_id_list,1)>
		</cfif>
		<cfif qTemplateUOM.RateTypeOption_1 EQ 1>
			<CFSET uom_id_list = listappend(uom_id_list,2)>
		</cfif>
		<cfquery name="qUOM" datasource="#application.datasource#">
			SELECT 	Unit_Of_Measure_ID,
				<!--- rtrim(ltrim(Unit_Of_Measure_Desc)) AS Unit_Of_Measure_Desc,			
				 rtrim(ltrim(Abbreviation)) AS Abbreviation,--->

				rtrim(ltrim(Unit_of_Measure_Desc_Singular)) AS Description,	
				rtrim(ltrim(Abbreviation_Singular)) AS Abbreviation
			FROM
					Units_Of_Measure
			WHERE Unit_Of_Measure_ID IN(#uom_id_list#)
		</cfquery>
		<!--- loop over uom results and build an array of structs --->
		<cfloop query="qUOM">
			<cfscript>
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
				stData["uomId"] = qUOM.Unit_Of_Measure_ID;
				stData["description"] = qUOM.Description;
				stData["abbreviation"] = qUOM.Abbreviation;
            	ArrayAppend(arrUom, duplicate(stData));
			</cfscript>
		</cfloop>
		<!--- return the array --->
		<cfreturn arrUom />
	</cffunction>
	
	
	<cffunction name="getMPHeader" access="remote" output="false" returntype="Query" hint="function MP header">	
	<!--- GET MP HEADER INFO :: Used in ProdRates tool --->
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var nTemplateFiltersId		= "";
			var qGetMPHeader			= "";
			//assign local variables
			nTemplateFiltersId 			= arguments.Template_Filters_Id;
		</cfscript>
		
		<cfquery name="qGetMPHeader" datasource="#application.datasource#"> 
				SELECT 1 AS Discount_Fixed_Prices,
						0 AS Discount_Rebates,
						TF.Description AS contract_title,
						PCPO.Created_type AS contract_number,
						0 AS Market_Price,
						PCPO.ProgramControl_Panel_Options_ID
						--MP.Status + ' [' + CAST(MP.Start_Date as varchar (25)) + '] ' AS 
				FROM Template_Filters TF
				--INNER JOIN Market_Price_List MP ON
				--	MP.Template_Filters_Id = TF.Template_Filters_Id
				INNER JOIN Program_Control_Panel_Options PCPO ON
					PCPO.First_Parent_ID = TF.Parent_Template_Id
				WHERE TF.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#nTemplateFiltersId#"> AND
					TF.Deleted = 0 AND
					PCPO.Deleted = 0 AND
					PCPO.IsDominant = 1 		
			</cfquery>

		<cfreturn qGetMPHeader />
	</cffunction>
	
	<cffunction name="getTemplateFilterInfo" access="remote" output="false" returntype="Query" hint="function template filter info">	
	<!--- GET MP HEADER INFO :: Used in ProdRates tool --->
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var nTemplateFiltersId		= "";
			var qgetTemplateFilterInfo			= "";
			//assign local variables
			nTemplateFiltersId 			= arguments.Template_Filters_Id;
		</cfscript>
		
		<cfquery name="qgetTemplateFilterInfo" datasource="#application.datasource#"> 
				SELECT PCPO.*,
						TF.*,
						ISNULL(TRS.Claim_Mechanic_Changed,0) AS Claim_Mechanic_Changed,
						TRS.*
						--MP.Status + ' [' + CAST(MP.Start_Date as varchar (25)) + '] ' AS 
				FROM Template_Filters TF
				--INNER JOIN Market_Price_List MP ON
				--	MP.Template_Filters_Id = TF.Template_Filters_Id
				INNER JOIN Program_Control_Panel_Options PCPO ON
					PCPO.First_Parent_ID = TF.Parent_Template_Id
				LEFT JOIN Template_Revision_Settings TRS ON
					TRS.Template_Id = PCPO.ProgramControl_Panel_Options_ID
				WHERE TF.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#nTemplateFiltersId#"> AND
					TF.Deleted = 0 AND
					PCPO.Deleted = 0		
			</cfquery>

		<cfreturn qgetTemplateFilterInfo />
	</cffunction>
	
	<cffunction name="getFirstParentId" output="false" returntype="Numeric" hint="get Template_Filters_Id">	
	<!--- GET Template_Filters_Id based on Market_Price_List.Market_Price_Id--->
		<cfargument name="TemplateFiltersId" type="Numeric" required="true" />

		<cfscript>
			//set local variables
			var qFirstParentId	= "";
		</cfscript>
		
		<cfquery name="qFirstParentId" datasource="#application.datasource#"> 
				SELECT 	Parent_Template_Id
				FROM	Template_Filters
				WHERE 	Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.TemplateFiltersId#">	 AND
						Deleted = 0 	
			</cfquery>
		<cfreturn qFirstParentId.Parent_Template_Id />
	</cffunction>
			

	<cffunction name="getTemplateFiltersIDBasedOnMP" output="false" returntype="Numeric" hint="get Template_Filters_Id">	
	<!--- GET Template_Filters_Id based on Market_Price_List.Market_Price_Id--->
		<cfargument name="MarketPriceListId" type="Numeric" required="true" />

		<cfscript>
			//set local variables
			var nTemplateFiltersId		= 0;
			var qGetTemplateFiltersID	= "";
		</cfscript>
		
		<cfquery name="qGetTemplateFiltersID" datasource="#application.datasource#"> 
				SELECT MP.Template_Filters_Id
				FROM Market_Price_List MP
				WHERE MP.Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.MarketPriceListId#">		
			</cfquery>
		<cfreturn qGetTemplateFiltersID.Template_Filters_Id />
	</cffunction>

	<cffunction name="getMPLists" access="remote" output="false" returntype="Query" hint="function MP header">
	<!--- GET MP LISTS FOR  A FILTER PACK [DEPRECATED: USE this.getMarketPriceLists() ] --->
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
		
		<cfscript>
			//set local variables
			var nProgramID				= "";
			var qGetMPLists			= "";
			//assign local variables
		</cfscript>
		
		<cfquery name="qGetMPLists" datasource="#application.datasource#"> 
				SELECT 	Market_Price_List_Id,
						Template_Filters_Id,
						Start_Date,
						End_Date,
						Status,
						Created_Date,
						Created_User_Id
				FROM Market_Price_List MP
				WHERE MP.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">
				<cfif Market_Price_List_Id >
					AND MP.Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
				</cfif>
				AND MP.Deleted = 0
		</cfquery>

		<cfreturn qGetMPLists />
		
	</cffunction>
	
	<cffunction name="getProgramActiveMPList" access="remote" output="false" returntype="Numeric" hint="gate active MP List">
	<!--- GET Active MP List for a Program --->
		<cfargument name="Program_Id" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var nProgramID		= "";
			var qGetMPListId	= "";
			var iMPId			= 0;
			//assign local variables
		</cfscript>
		
		<cfquery name="qGetMPListId" datasource="#application.datasource#"> 
			SELECT	TOP 1 MP.Market_Price_List_Id
			FROM Contract_Main CM
			INNER JOIN Program_Control_Panel_Options PCPO ON
					PCPO.ProgramControl_Panel_Options_ID = CM.Programtype_Id
			left JOIN Template_Filters TF ON
				PCPO.First_Parent_ID = TF.parent_template_Id
			left JOIN Market_Price_List MP ON
				MP.Template_Filters_Id = TF.Template_Filters_Id 
			WHERE CM.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Program_Id#"> AND
					MP.Deleted = 0 AND
					MP.status = 'active' AND
					MP.Start_Date <= CM.Contract_End_Date AND
					(MP.End_Date IS NULL OR MP.End_Date >= CM.Contract_Start_Date) AND
					PCPO.Market_Price = 1 /*Make Sure The latest Template has MP ON*/
			ORDER BY MP.Start_Date ASC
		</cfquery>
		<cfif qGetMPListId.recordCount>
			<cfset iMPId = qGetMPListId.Market_Price_List_Id />
		</cfif>
		<cfreturn iMPId />
	</cffunction>
	
	<cffunction name="getTemplateActiveMPList" access="remote" output="false" returntype="Numeric" hint="gate active MP Lis for a template">
	<!--- GET Active MP List for a Program --->
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var iMPId			= 0;
			//assign local variables
		</cfscript>
		
		<cfquery name="qGetMPListId" datasource="#application.datasource#"> 
			SELECT	TOP 1 MP.Market_Price_List_Id
			FROM Template_Filters TF
			INNER JOIN Market_Price_List MP ON
				MP.Template_Filters_Id = TF.Template_Filters_Id
			WHERE TF.Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#"> AND
					MP.Deleted = 0 AND
					MP.status = 'active' AND
					MP.Start_Date <= getdate() AND
					(MP.End_Date IS NULL OR MP.End_Date >= getDate())
			ORDER BY MP.Start_Date ASC
		</cfquery>
		<cfif qGetMPListId.recordCount>
			<cfset iMPId = qGetMPListId.Market_Price_List_Id />
		</cfif>
		<cfreturn iMPId />
	</cffunction>
	
	<cffunction name="getCurrentMPList" access="remote" output="false" returntype="Numeric" hint="gate current MP List">
		<!--- GET Current MP List for a Program --->
		<cfargument name="Program_Id" type="Numeric" required="true" />
		
		<cfscript>
			//set local variables
			var nProgramID		= "";
			var qGetCurrentMPListId	= "";
			var iMPId			= 0;
			//assign local variables
		</cfscript>
		
		<cfquery name="qGetCurrentMPListId" datasource="#application.datasource#"> 
			SELECT	PFC.Market_Price_List_Id
			FROM Contract_Main CM
			INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Id = CM.Contract_Main_Id
			WHERE CM.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Program_Id#">
					And PFC.Deleted = 0
		</cfquery>
		<cfif isNumeric(qGetCurrentMPListId.Market_Price_List_Id)>
			<cfset iMPId = qGetCurrentMPListId.Market_Price_List_Id />
		</cfif>
		<cfreturn iMPId />
	</cffunction>
	
	<cffunction name="isMPOnProgram" output="false" returntype="boolean" hint="check if MP is used on a program">
	<!--- Check if any Programs are associted with this MP List --->
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
		<cfscript>
			//set local variables
			var qIsMpOnProgram	= queryNew('Market_Price_List_Id');
			var bIsMpOnProgram	= 0;
			//assign local variables
		</cfscript>
		
		<cfquery name="qIsMpOnProgram" datasource="#application.datasource#"> 
			SELECT	TOP 1 PFC.Market_Price_List_Id
			FROM Contract_Main CM
			INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Id = CM.Contract_Main_Id
			WHERE PFC.Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
					AND PFC.Deleted = 0
					AND CM.deleted = 0
					--AND CM.Contract_Status_Type_IDX < 7
		</cfquery>
		<cfif isNumeric(qIsMpOnProgram.Market_Price_List_Id)>
			<cfset bIsMpOnProgram = 1 />
		</cfif>
		<!---<cflog text="qIsMpOnProgram: #qIsMpOnProgram.RecordCount#  MP_ID: #arguments.Market_Price_List_Id#  MP From Query: #qIsMpOnProgram.Market_Price_List_Id#">--->
		<cfreturn bIsMpOnProgram />
	</cffunction>

	<cffunction name="saveMPData" output="false" access="remote" returntype="boolean" >
	<!---  SAVE RATE DATA  --->
		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="acComponents" type="Array" required="true" />
		
		<cfscript>
			//set local variables
			var nProgramID				= "";
			var arrData					= ArrayNew(1);
			var arrFixedProdRateData	= ArrayNew(1);
			var arrRebateProdRateData	= ArrayNew(1);
			var indx					= "";
			var indx2					= "";
			var varTemplateFiltersID = this.getTemplateFiltersIDBasedOnMP(arguments.programId);
			var FirstParentId = this.getFirstParentId(varTemplateFiltersID);
			
			//assign local variables
			nProgramID	= arguments.programId;
			arrData		= arguments.acComponents;
		</cfscript>
		<!---TODO:  MPUP AND MPAC LOGIC NEEDS TO GET RUN--->
		<cfloop index="indx" array="#arrData#">
			<cftransaction>
				<!--- Log the current MP data --->
				<cfset this.logMarketPrice(indx.componentId) />
				
				<!--- update the header --->
				<cfquery name="qUpdateMPHeader" datasource="#application.datasource#"> 
					UPDATE Market_Price_List
					SET Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
						Updated_Date = getdate()
					WHERE Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#indx.componentId#">
				</cfquery>
				<!---delete all of the existing rates--->
				<cfquery name="qDelMPRates" datasource="#application.datasource#">
					DELETE FROM Market_Price_Product_Rates
					WHERE  Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#indx.componentId#">
				</cfquery>
				
				
				<!--- set the prod rate array --->
				<cfset arrRebateProdRateData = indx.prodRate />
				<!--- loop over the prod rate array --->
				<cfloop index="indx2" array="#arrRebateProdRateData#">
					<cfif indx2.itemGuid NEQ '' AND isNumeric(indx2.rate) AND indx2.rate GT 0	>	
						<cfquery name="qInsertMPRate" datasource="#application.datasource#">
							INSERT INTO Market_Price_Product_Rates
								(
									Market_Price_List_Id,
									BSA_Foodservice_Items_Master_Id,
									item,
									rate,
									Uom_Id
								)
							VALUES
								(
									<cfqueryparam value="#indx.componentId#" cfsqltype="cf_sql_integer" />,
									<cfqueryparam value="#indx2.itemGuid#" cfsqltype="cf_sql_varchar"  />,
									<cfqueryparam value="#indx2.itemNumber#" cfsqltype="cf_sql_varchar" />,
									<cfqueryparam value="#indx2.rate#" cfsqltype="cf_sql_decimal" scale="4" />,
									<cfqueryparam value="#indx2.uom.uomId#" cfsqltype="cf_sql_integer" />
								)
						</cfquery>
						<!--- HACK [if statement to decide if it is a group]...It is a group.  May need to add the is_item_group flag to prodrate obj --->
						<!--- Populate item level rates -> Captured_From_Group = 1 							--->
						<cfif indx2.itemGuid EQ indx2.itemNumber>
							<cfquery name="qInsertGroupChildrenRates" datasource="#application.datasource#">
								IF OBJECT_ID('tempdb..##MultiProductAttrGroupMembers ') IS NULL	
								CREATE TABLE ##MultiProductAttrGroupMembers (Item VARCHAR(150), 
											UPC VARCHAR(150), 
											Description VARCHAR(255),
											BSA_Foodservice_Items_Master_ID uniqueidentifier)
											
								EXEC Get_Multi_Product_Attr_Group_Members '#indx2.itemGuid#', #FirstParentId#, 0
								 
								--SELECT * FROM ##MultiProductAttrGroupMembers
									
								INSERT INTO Market_Price_Product_Rates
									(
										Market_Price_List_Id,
										BSA_Foodservice_Items_Master_Id,
										item,
										rate,
										Uom_Id,
										Captured_From_Group
									)
								SELECT
										<cfqueryparam value="#indx.componentId#" cfsqltype="cf_sql_integer" />,
										BSA_Foodservice_Items_Master_ID,
										Item,
										<cfqueryparam value="#indx2.rate#" cfsqltype="cf_sql_decimal" scale="4" />,
										<cfqueryparam value="#indx2.uom.uomId#" cfsqltype="cf_sql_integer" />,
										1
								
								FROM ##MultiProductAttrGroupMembers
							</cfquery>
						</cfif>
					</cfif>
				</cfloop>
			</cftransaction>
		</cfloop>
		<cfreturn true />
	</cffunction>
	
	<cffunction name="insertMPHeader" output="false" access="remote" returntype="boolean">
	<!---  SAVE MP HEADER DATA  --->
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="startDate" type="date" required="true" />
		<cfscript>
			//set local variables
			var qInsertMPHeader			= "";
		</cfscript>
		
		<cfquery name="qInsertMPHeader" datasource="#application.datasource#"> 
				INSERT INTO Market_Price_List
					(
						Template_Filters_Id,
						Start_Date,
						--End_Date,
						Status,
						--Created_Date,
						Created_User_Id
					)
				VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">,
						<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.startDate#">,
						'WIP',
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">
					)
				SELECT @@identity as Market_Price_List_Id
		</cfquery>
		
		<cfreturn qInsertMPHeader.Market_Price_List_Id />
	</cffunction>
	
	<cffunction name="updateMPHeader" output="false" access="remote" returntype="boolean">
	<!---  SAVE MP HEADER DATA  --->
		<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="Market_Price_List_Id" type="date" required="true" />
		<cfscript>
			//set local variables
			var qInsertMPHeader		= "";
		</cfscript>

		<cfquery name="qupdateMPHeader" datasource="#application.datasource#"> 
			UPDATE Market_Price_List
				SET Status = 'active',
					Start_Date = '#MPToActivateStartDate#',
					Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
					Updated_Date = getDate()
				WHERE Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">
				AND Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
		</cfquery>
		
		<cfreturn 1 />
	</cffunction>
	
	<cffunction name="activateMP" hint="activate a WIP market price list" returntype="Struct">
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
		<cfargument name="dtActivateNewStartDate" type="String" default="" />
		<cfscript>
			/* returns all Mp's for this template filter */
			var bActivateFlag = 0;
			var sMessage = '';
			var stReturn = structNew();
			var MPtoActivate = '';
			var MPToActivateStartDate = NOW();
			var MPToActivateEndDate = NOW();
			var MPisActive = '';
			var MPisActiveId = 0;
			var MPisActiveStart = dateAdd("d",-1,dateFormat(now(),'mm/dd/yyyy'));
			var arrMarketPrices = this.getMarketPriceLists(arguments.Template_Filters_Id,'mpType');
			/* check number of active lists */
			var iActiveCount = 0;
			CR    = Chr(13);             // Carriage return
    		LF    = Chr(10);             // Line feed
    		CRLF  = CR & LF;
			for (i=1;i LTE ArrayLen(arrMarketPrices);i=i+1) {
				this.doCFLog("ACTIVATE MP ID :" & arrMarketPrices[i].Market_Price_List_Id & ':' & arguments.Market_Price_List_Id & "  STATUS::" & arrMarketPrices[i].Status & ":  END DATE:: " & arrMarketPrices[i].End_Date& ":  arg START DATE:: "  & arguments.dtActivateNewStartDate);
				//For start date UPdates, don't count the one we are updating as active
				if(arrMarketPrices[i].Status == 'active'){
					if(arrMarketPrices[i].End_Date < dateFormat(now(),'mm/dd/yyyy') && arrMarketPrices[i].End_Date != ''){
						this.doCFLog("ACTIVATE MP Expire :" & iActiveCount & ' :: ' & arguments.Template_Filters_Id & ' :: ' & arguments.Market_Price_List_Id);
						this.expireMPList(arrMarketPrices[i].Template_Filters_Id,arrMarketPrices[i].Market_Price_List_Id);
					}
					else{ 
						iActiveCount++;
						if(this.getTemplateActiveMPList(arguments.Template_Filters_Id) == arrMarketPrices[i].Market_Price_List_Id){
							MPisActiveId = arrMarketPrices[i].Market_Price_List_Id;
							MPisActive = arrMarketPrices[i];
							MPisActiveStart = MPisActive.Start_Date;
							this.doCFLog("ACTIVATE MP increment :" & iActiveCount & ' : IS Active ' & MPisActiveStart);
						}
						
					}
					
				}
				//get details for current list we are activating
				if(arrMarketPrices[i].Market_Price_List_Id == arguments.Market_Price_List_Id){
					MPtoActivate = arrMarketPrices[i];
					MPToActivateEndDate = dateFormat(MPtoActivate.End_Date,'mm/dd/yyyy');
					//if the date is passed in then use it.
					if(isDate(arguments.dtActivateNewStartDate)){
						MPToActivateStartDate = dateFormat(arguments.dtActivateNewStartDate,'mm/dd/yyyy');
					}
					else{
						MPToActivateStartDate = dateFormat(MPtoActivate.Start_Date,'mm/dd/yyyy');
					}
				}
			}
			bActivateFlag = (
								(iActiveCount <= 2 || MPtoActivate.Status == 'active') 
								&& MPToActivateStartDate > MPisActiveStart 
								&& MPToActivateStartDate >= dateAdd("d",-1,dateFormat(now(),'mm/dd/yyyy'))
								&& (MPToActivateStartDate <= MPToActivateEndDate || MPToActivateEndDate == '')
							);
			stReturn.bActivateFlag = bActivateFlag;
			this.doCFLog("ACTIVATE MP Flag :" & bActivateFlag & ' : TO Activate' & MPToActivateStartDate & ' MPisActiveStart:' & MPisActiveStart & 'MPisActiveId:' & MPisActiveId & 'iActiveCount' & iActiveCount);
			//set return messages
			if(iActiveCount >= 2 && MPtoActivate.Status != 'active'){sMessage = sMessage & 'There are 2 Price Lists active Already!' & '<br/>';}
			if(MPToActivateStartDate <= MPisActiveStart && iActiveCount > 0){sMessage = sMessage & 'The Price List Start Date Pre Dates the start of an Active list.' & '<br/>';}
			if(MPToActivateStartDate < dateFormat(now(),'mm/dd/yyyy')){sMessage = sMessage & 'The Price List Start Date can not be retroactive.' & '<br/>';}
			if(MPToActivateStartDate > MPToActivateEndDate && MPToActivateEndDate != ''){sMessage = sMessage & 'The Start Date can not be greater than the end date.' & '<br/>';}
			stReturn.sMessage = sMessage;
		</cfscript>
		<cfif bActivateFlag>
			<cfset stReturn.sMessage = sMessage & 'Market Price List: ' & arguments.Market_Price_List_Id />
		<!---TODO:  MPUP AND MPAC LOGIC NEEDS TO GET RUN--->
			<cfquery name="qActivateMPList" datasource="#application.datasource#">
					<cflog text="Active Count: #iActiveCount#" />
					<cfif iActiveCount GT 0 AND MPisActiveId NEQ arguments.Market_Price_List_Id AND MPisActiveId neq 0>
						UPDATE Market_Price_List
						SET End_Date =  DATEADD(d,-1,'#MPToActivateStartDate#'),
							Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
							Updated_Date = getDate()
						WHERE Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#MPisActive.Template_Filters_Id#">
						AND Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#MPisActive.Market_Price_List_Id#">
					</cfif>
					UPDATE Market_Price_List
					SET Status = 'active',
						Start_Date = '#MPToActivateStartDate#',
						Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
						Updated_Date = getDate()
					WHERE Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">
					AND Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
			</cfquery>
		</cfif>
    	<cfreturn stReturn />
    </cffunction>
	
<!---	<cffunction name="activateMP" hint="Update market price list Start Date" returntype="Struct">
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
		<cfargument name="dtUpdateStartDate" type="String" default="" />
		<cfscript>
			/* returns all Mp's for this template filter */
			var bActivateFlag = 0;
			var sMessage = '';
			var stReturn = structNew();
			var MPtoActivate = '';
			var MPisActive = '';
			var MPToActivateStartDate = NOW();
			var MPisActiveStart = dateAdd("m",-1,NOW());
			var arrMarketPrices = this.getMarketPriceLists(arguments.Template_Filters_Id,'mpType');
			/* check number of active lists */
			var iActiveCount = 0;
			CR    = Chr(13);             // Carriage return
    		LF    = Chr(10);             // Line feed
    		CRLF  = CR & LF;
			for (i=1;i LTE ArrayLen(arrMarketPrices);i=i+1) {
				if(arrMarketPrices[i].Status == 'active'){
					iActiveCount++;
					MPisActive = arrMarketPrices[i];
					MPisActiveStart = MPisActive.Start_Date;
				}
				//get details for current list we are activating
				if(arrMarketPrices[i].Market_Price_List_Id == arguments.Market_Price_List_Id){
					MPtoActivate = arrMarketPrices[i];
					//if the date is passed in then use it.
					if(isDate(arguments.dtUpdateStartDate)){
						MPToActivateStartDate = arguments.dtUpdateStartDate;
					}
					else{
						MPToActivateStartDate = MPtoActivate.Start_Date;
					}
				}
			}
			bActivateFlag = (iActiveCount < 2 && MPToActivateStartDate > MPisActiveStart);
			stReturn.bActivateFlag = bActivateFlag;
			if(iActiveCount >= 2){sMessage = sMessage & 'There are 2 Price Lists active Already!' & '<br/>';}
			if(MPToActivateStartDate < MPisActiveStart){sMessage = sMessage & 'The Price List Start Date Pre Dates the start of an Active list!' & '<br/>';}
			stReturn.sMessage = sMessage;
		</cfscript>
		<cfif bActivateFlag>
		<!---TODO:  MPUP AND MPAC LOGIC NEEDS TO GET RUN--->
			<cfquery name="qActivateMPList" datasource="#application.datasource#">
					<cfif iActiveCount EQ 1>
						UPDATE Market_Price_List
						SET End_Date =  DATEADD(d,-1,'#MPToActivateStartDate#'),
							Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
							Updated_Date = getDate()
						WHERE Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#MPisActive.Template_Filters_Id#">
						AND Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#MPisActive.Market_Price_List_Id#">
					</cfif>
					UPDATE Market_Price_List
					SET Status = 'active',
						Start_Date = '#MPToActivateStartDate#',
						Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
						Updated_Date = getDate()
					WHERE Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">
					AND Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
			</cfquery>
		</cfif>
    	<cfreturn stReturn />
    </cffunction>--->
	<cffunction name="deleteMP" hint="delete a WIP market price list" returntype="string">
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
		<cfscript>
			/* returns all Mp's for this template filter */
			var sDeleteMessage = "Market Price List Deleted: " & arguments.Market_Price_List_Id;
			var bDeleteFlag = 0;
			var MPtoDelete = queryNew('Status');
			var bHasPrograms = 0;
			MPtoDelete = this.getMPLists(arguments.Template_Filters_Id,arguments.Market_Price_List_Id);
			bHasPrograms = this.isMPOnProgram(arguments.Market_Price_List_Id);
			//if wip or no associated programs
			bDeleteFlag = (MPtoDelete.Status == 'wip' || bHasPrograms == 0);
			//this.doCFLog("bDeleteFlag: " & bDeleteFlag & "  bHasPrograms:: " & bHasPrograms);
			if(bDeleteFlag){
				//log cuurent data
				this.logMarketPrice(arguments.Market_Price_List_Id);
				//update data in DB
				this.deleteMPData(arguments.Template_Filters_Id,arguments.Market_Price_List_Id);
				
			}
			else if(MPtoDelete.Status == 'active'){
				this.doCFLog("tfid: " & arguments.Template_Filters_Id & "  mpidbHasPrograms:: " & arguments.Market_Price_List_Id);
				//deactivate
				this.deactivateMP(arguments.Template_Filters_Id,arguments.Market_Price_List_Id);
				sDeleteMessage = 'Market Price List De-Activated: ' & arguments.Market_Price_List_Id;
			}
		</cfscript>
		
    	<cfreturn sDeleteMessage />		
    </cffunction>
	
	<cffunction name="deleteMPData" hint="delete Mp list Data in DB" returntype="void">
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
		
			<cfquery name="qDelMPRates" datasource="#application.datasource#">
				DELETE FROM Market_Price_Product_Rates
				WHERE  Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
			</cfquery>
			
			<cfquery name="qDeleteMPList" datasource="#application.datasource#">
					UPDATE Market_Price_List
					SET deleted = 1,
						End_Date = getDate(),
						Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
						Updated_Date = getDate()
					WHERE Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">
					AND Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
			</cfquery>
	
    </cffunction>
	
	<cffunction name="expireMPList" hint="expire mp List" returntype="void">
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
		<cfscript>
			//log cuurent data
			this.logMarketPrice(arguments.Market_Price_List_Id);
		</cfscript>
			<cfquery name="qExpireMPList" datasource="#application.datasource#">
					UPDATE Market_Price_List
					SET Status = 'expired',
						Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
						Updated_Date = getDate()
					WHERE Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">
					AND Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
			</cfquery>
    </cffunction>
	
	<cffunction name="deactivateMP" hint="delete Mp list Data in DB" returntype="void">
    	<cfargument name="Template_Filters_Id" type="Numeric" required="true" />
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
			
			<cfquery name="qDeleteMPList" datasource="#application.datasource#">
					UPDATE Market_Price_List
					SET status = 'Inactive',
						End_Date = getDate(),
						Updated_User_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cookie.User_Id#">,
						Updated_Date = getDate()
					WHERE Template_Filters_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Template_Filters_Id#">
					AND Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
			</cfquery>
	
    </cffunction>
	<cffunction name="logMarketPrice" hint="log header and rate data" returntype="void">
	<!--- LOG MP DATA --->
		<cfargument name="Market_Price_List_Id" type="Numeric" default="0" />
		<cfset var iLogDataStorageDays = 182 />
			<cfquery name="qDeleteRatesLogData" datasource="#application.datasource#">
				DELETE FROM Market_Price_Product_Rates_Log
				WHERE DATEDIFF(DD,Created_Date,GetDate()) > #iLogDataStorageDays#
			</cfquery>
			
			<!---  HEADER DATA IS 1 ROW -> LETS LEAVE IT FOR AUDITING
			<cfquery name="qDeleteListLogData" datasource="#application.datasource#">
				DELETE FROM Market_Price_List_Log
				WHERE DATEDIFF(DD,Created_Date,GetDate()) > #iLogDataStorageDays#
			</cfquery>--->
			
			<cfquery name="qLogMPRates" datasource="#application.datasource#">
				INSERT INTO Market_Price_Product_Rates_Log (
					Market_Price_Product_Rates_Id,
					Market_Price_List_Id,
					BSA_Foodservice_Items_Master_Id,
					item,
					rate,
					Uom_Id
				)
				SELECT 
					Market_Price_Product_Rates_Id,
					Market_Price_List_Id,
					BSA_Foodservice_Items_Master_Id,
					item,
					rate,
					Uom_Id	
				FROM Market_Price_Product_Rates MPR
				WHERE  MPR.Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
			</cfquery>
			
			<cfquery name="qLogMpHeader" datasource="#application.datasource#">
				INSERT INTO Market_Price_List_Log(
					Market_Price_List_Id,
					Template_Filters_Id,
					Start_Date,
					End_Date,
					Status,
					Updated_Date,
					Created_User_Id,
					Updated_User_Id
				)
				SELECT 
					Market_Price_List_Id,
					Template_Filters_Id,
					Start_Date,
					End_Date,
					Status,
					Updated_Date,
					Created_User_Id,
					Updated_User_Id
				FROM Market_Price_List MPL
				WHERE  MPL.Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Market_Price_List_Id#">
			</cfquery>		
    </cffunction>
	
	<cffunction name="autoApproveMarketPriceProgram" hint="auto approve Fixed price items w/MP rates where Fixed price >= MP rate" returntype="VOID" access="remote">
	<!---  ********** Automatically approve any items that are <= the MP Rate ********** --->
    	<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfscript>
			var oReturnObject = StructNew();
			var iMPId = this.getProgramActiveMPList(arguments.ProgramId);
			//var nMaxProgramVariance = this.getMaxProgramMarketPriceVariance(arguments.ProgramId,iMPId);
			oReturnObject.bApproved = "";
			oReturnObject.message = "MP Approval Start";
			//program.components[0].prodRate  session.get_profile_settings.MARKET_PRICE_VARIANCE
		</cfscript>
			<!--- auto approve items (1 means auto) --->
			<cfset objMarketPriceRateDAO.insertMPApprovalVariances(arguments.ProgramId,1) />
			<!--- Now check if any items are left that still need approval --->
			<cfset qGetMPApprovals = objMarketPriceRateDAO.getMPApprovals(arguments.ProgramId) />
			
			<!--- If all items have an approval, then flag the contract as approved --->
			<cfif qGetMPApprovals.recordcount EQ 0 >
				<cfset objMarketPriceRateDAO.setMPProgramApproval(arguments.ProgramId) />
			</cfif>

	</cffunction>
	
	<cffunction name="approveMarketPriceProgram" hint="approve program and store item level rate variances" returnformat="JSON" access="remote">
	<!---  ********** Flag Program as Approved and Log the Approved MP variances so we do not ask for the same approval again  ********** --->
    	<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfscript>
			var oReturnObject = StructNew();
			var iMPId = this.getProgramActiveMPList(arguments.ProgramId);
			var nMaxProgramVariance = this.getMaxProgramMarketPriceVariance(arguments.ProgramId,iMPId);
			oReturnObject.bApproved = "";
			oReturnObject.message = "MP Approval Start";
			//program.components[0].prodRate
		</cfscript>
		<!--- 
			D46215 :: 7.1 Added item with variance and it auto approved
			if user profile setting "Max Market Price Variance %" is 0 and user enter variance in negative program was auto approving
			Modified code to use absolute values.
			--->
		<cfif nMaxProgramVariance LTE Abs(session.get_profile_settings.MARKET_PRICE_VARIANCE)>
		<!--- NEEDED ??? --->
			<cftransaction>
				<!--- flag program as approved --->
				<cfset objMarketPriceRateDAO.setMPProgramApproval(arguments.ProgramId) />
				<!--- insert item level approval --->
				<cfset objMarketPriceRateDAO.insertMPApprovalVariances(arguments.ProgramId) />
				
			</cftransaction>
			<cfscript>
				oReturnObject.bApproved = "true";
				oReturnObject.message = "Market Price rates Approved";
				//program.components[0].prodRate
			</cfscript>
		<cfelse> <!---permissions check failed--->
			<cfscript>
				oReturnObject.bApproved = "";
				oReturnObject.message = "Inadequate user permissions";
				//program.components[0].prodRate
			</cfscript>
		</cfif>
		<cfreturn serializeJSON(oReturnObject) />
	</cffunction>
	 
	<cffunction name="getMaxProgramMarketPriceVariance" hint="get the maximum variance for a program" returntype="Numeric" >
	<!---  ********** GET The Max MP variance for a Program  ********** ---> 
    	<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfargument name="iMPId" type="numeric" required="true"/>
		<cfscript>
			var nReturnNumber = 0;
		</cfscript>
		<!--- get max() from db --->
		<cfset nReturnNumber = objMarketPriceRateDAO.getMaxMPProgramVariances(arguments.ProgramId,arguments.iMPId).MaxVariance />
    	
		<cfreturn nReturnNumber />
    </cffunction>
 
	<cffunction name="MarketPriceUpdateProcess" hint="MPUP" returntype="void" >
	<!--- ************   MPUP   *******************--->
    	<cfargument name="ProgramId" type="numeric" required="true"/>
    	<cfscript>
			var qGetFixedData = queryNew('componentId');
			var arrProdRate = arrayNew(1);
			var indx = "";
			var thisVariance = "";
			var thisVarianceDiff = 0;
			var maxVariance = 0;
			var bMpac = false;
			var objTemplateManager		= CreateObject("component","components.programs.template.TemplateManager");
			var objComponentManager	= CreateObject("component","mvc.Models.Program.Component.ComponentManager");
			var objProdRateManager	= CreateObject("component","mvc.Models.Program.Component.ProductRateManager");
			var currentMPId = this.getCurrentMPList(arguments.ProgramId);
			var activeMPId  = this.getProgramActiveMPList(arguments.ProgramId);
			var prgTemplate = objTemplateManager.getProgramTemplate(arguments.ProgramId);
			// this.doCFLog("CurMPId:: " & currentMPId & "  ActiveMPId:: " & activeMPId);
			//if(currentMPId != activeMPId){
				qGetFixedData 	= objProdRateManager.getProductRate(arguments.ProgramId,1);
			//}
			//template switch can turn off MPUP
			if(prgTemplate.Market_Price_Update_Process eq 0){
				return;
			}
		</cfscript>
		
		<cfoutput query="qGetFixedData" group="componentId">
			<cfscript>
				arrProdRate 	= objProdRateManager.getProductRateDataStruct(qGetFixedData, componentId, 1,1);
				for (i=1;i LTE ArrayLen(arrProdRate);i=i+1) { 
					 //this.doCFLog("MPUP ONE    : " & arrProdRate[i].newRateMP & "  rate:: " & arrProdRate[i].rate & "  CurMPId:: " & currentMPId & "  ActiveMPId:: " & activeMPId);
					//MPUP: if saved MP rate != MP rate from active pricelist (Market Price has changed)

					/*if(arrProdRate[i].rateMP != arrProdRate[i].newRateMP && qGetFixedData.bCustomPrint == 0){*/
					/*LAST VER:: arrProdRate[i].rateMPUom == 1 && arrProdRate[i].rateMPCS != arrProdRate[i].newRateMP) || (arrProdRate[i].rateMPUom == 2 && arrProdRate[i].rateMPLB != arrProdRate[i].newRateMP */
					if(
						(arrProdRate[i].rateMP != arrProdRate[i].newRateMP)
						 && prgTemplate.Custom_Fixed_Price_Options == 0
						 )
						 {
						//if product rate is == to the saved MP rate -> set the Product rate = newMPRate
						//if(arrProdRate[i].rate == arrProdRate[i].rateMP && isnumeric(arrProdRate[i].newRateMP)){
						if
							(
								(
									(arrProdRate[i].uom.uomId == 2 && arrProdRate[i].rateMPLB == arrProdRate[i].rate) || (arrProdRate[i].uom.uomId == 1 && arrProdRate[i].rateMPCS == arrProdRate[i].rate)
								) 
								&& isnumeric(arrProdRate[i].newRateMP)
								&& arrProdRate[i].newRateMP != 0
							){
							//update rate -> set rate = newRateMP
							arrProdRate[i].rate = arrProdRate[i].newRateMP;
							this.updateRateWithNewMpRate(	arguments.ProgramId,
															qGetFixedData.PROGRAMCOMPONENTID,
															arrProdRate[i].newRateMP,//MP Rate
															arrProdRate[i].newRateMP,//Fixed Rate
															arrProdRate[i].contractProductsID);
						}
						//else just update the saved MP Rate -> leave fixed rate as is
						else{
							//if mprate !numeric -> set to 0
							if(!isnumeric(arrProdRate[i].newRateMP)){arrProdRate[i].newRateMP = 0;}
							this.updateRateWithNewMpRate(	arguments.ProgramId,
															qGetFixedData.PROGRAMCOMPONENTID,
															arrProdRate[i].newRateMP,//MP Rate
															arrProdRate[i].rate,//Fixed Rate -> stays same
															arrProdRate[i].contractProductsID);
						}
					}
					thisVariance = 0;
					if(isNumeric(arrProdRate[i].newRateMP) && arrProdRate[i].newRateMP != 0){
						//current variance for this item
						thisVariance = decimalFormat((arrProdRate[i].newRateMP - arrProdRate[i].rate)/arrProdRate[i].newRateMP * 100);
					}
					//Market Price -> use the calculated market Price (Min Price)
					if(prgTemplate.Custom_Fixed_Price_Options == 1 && isNumeric(arrProdRate[i].rateMP) && arrProdRate[i].rateMP != 0){
						thisVariance = decimalFormat((arrProdRate[i].rateMP - arrProdRate[i].rate)/arrProdRate[i].rateMP * 100);
					}
					//MPAC
					//if Current Variance > than Already Approved Variance
					/*this.dmp(arguments.ProgramId);
					this.dmp(arrProdRate[i].itemGuid);
					this.dmp(componentId);
					this.dmp(thisVariance);
					this.dmp(arrProdRate[i].MPApprovalVariance);
					this.dmp('ooooooooooooooooooooooooooooooooooooooooooooooooooooo');*/

					thisVarianceDiff = 0;
					if(isNumeric(arrProdRate[i].MPApprovalVariance)){
						thisVarianceDiff = replace(thisVariance,',','','ALL') - arrProdRate[i].MPApprovalVariance;
					}

					if(abs(thisVarianceDiff) >= .01){
						//Debug 
						//Clear item Approval
						this.clearMarketPriceItemApproval(arguments.ProgramId,arrProdRate[i].itemGuid,componentId);
						
						//set Flag to clear header
						bMpac = true;
						//keep track of max varince for use by CRA
						if(thisVariance > maxVariance){
							maxVariance = thisVariance;
						}
					}
				}//end prodrate loop
				
				//clear MP program approval
				if(bMpac){
					this.clearMarketPriceProgramApproval(arguments.ProgramId,maxVariance);
				}
				if(currentMPId != activeMPId){
					//db update the fixed component mp Id to the active one
					this.updateProgramMPId(arguments.ProgramId,activeMPId);
				}
			</cfscript>	
		</cfoutput>
		<cfscript>
			//any items with a rate <= MP rate do not need approval.
		    this.autoApproveMarketPriceProgram(arguments.ProgramId);
		</cfscript>
		<!--- <cfreturn arrProdRate /> --->
    </cffunction>

	<cffunction name="updateRateWithNewMpRate" hint="set the fixed rate to the MP rate">
	<!---************ DB Update For MPUP  ************ --->
    	<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfargument name="componentId" type="numeric" required="true"/>
		<cfargument name="newRateMP" type="numeric" required="true"/>
		<cfargument name="newFixedRate" type="numeric" required="true"/>
		<cfargument name="contractProductId" type="numeric" required="true"/>
		<!---<cflog text="prg: #arguments.ProgramId#  :comp:  #arguments.componentId#  :rate: #arguments.newRateMP#  :cpid: #arguments.contractProductId#" />--->
		<cfquery name="qUpdateRateWithNewMpRate" datasource="#application.datasource#">
			UPDATE Program_Fixed_Price_Product_Data
			SET Fixed_Price_Value = <cfqueryparam cfsqltype="cf_sql_decimal" scale="2" value="#arguments.newFixedRate#">,
				Market_Price_Rate = <cfqueryparam cfsqltype="cf_sql_decimal" scale="2" value="#arguments.newRateMP#">
			WHERE	Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#">
			AND		Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND 	Program_Fixed_Component_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.componentId#">
			AND		Contract_Products_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contractProductId#">
		</cfquery>
		   		
    </cffunction>
	
	<cffunction name="clearMarketPriceProgramApproval" hint="clear the Market Price approval on the Program">
	<!--- **********  DB UPDATE Clear MP Approval On Program  ********** --->
    	<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfargument name="maxVariance" type="numeric" required="true"/>
    	
		<cfquery name="qUpdateMPProgramApproval" datasource="#application.datasource#">
			UPDATE Contract_Main_Aux_data
			SET Market_Price_Approved = 0,
				Market_Price_Approved_By = '#request.AccessStructure.user_id#',
				Market_Price_Approved_Date = null,
				Market_Price_Approval_Variance = #arguments.maxVariance#
			WHERE  Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#">
		</cfquery>
		
		<cfquery name="qDeleteCapturedFomGroupApprovals" datasource="#application.datasource#">
			DELETE FROM Market_Price_Program_Approvals
			WHERE  Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#">
			AND BSA_Foodservice_Items_Master_ID NOT IN
			(SELECT BSA_Foodservice_Items_Master_ID 
				FROM Contract_Products 
				WHERE Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#"> AND
				Product_Type_ID = 1 AND
				Deleted = 0)
		</cfquery>
    </cffunction>
	
	<cffunction name="clearMarketPriceItemApproval" hint="clear the Market Price approval on the Program">
	<!--- **********  DB UPDATE Clear MP Approval at Item Level  ********** --->
    	<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfargument name="itemGuid" type="string" required="true"/>
		<cfargument name="componentNameId" type="numeric" required="true"/>
 
		<cfquery name="qUpdateMPItemApproval" datasource="#application.datasource#">
			DELETE FROM Market_Price_Program_Approvals
			WHERE  Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#"> AND
					BSA_Foodservice_Items_Master_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemGuid#">
					AND Component_Name_Id = <cfqueryparam cfsqltype="cf_sql_decimal" value="#arguments.componentNameId#">
					
			<!---DELETE FROM Market_Price_Program_Approvals
			WHERE Market_Price_Program_Approvals_Id IN(
			SELECT Market_Price_Program_Approvals_Id
			FROM Market_Price_Program_Approvals MPPA
			INNER JOIN Contract_Products CP ON
				CP.Contract_Main_ID = MPPA.Contract_Main_Id AND
				CP.BSA_Foodservice_Items_Master_ID = MPPA.BSA_Foodservice_Items_Master_ID AND
				CP.Product_Type_ID = 1 
			WHERE  MPPA.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#"> AND 
				(CP.BSA_Foodservice_Items_Master_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemGuid#">
					OR
				 CP.Product_Group_ID =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.itemGuid#">
				)
				 AND 
				Component_Name_Id = <cfqueryparam cfsqltype="cf_sql_decimal" value="#arguments.componentNameId#">
			)--->
		</cfquery>
    </cffunction>
	
	<cffunction name="updateProgramMPId" hint="clear the Market Price approval on the Program">
	<!--- **********  DB UPDATE set MP id for Program_Fixed_Component  ********** --->
    	<cfargument name="ProgramId" type="numeric" required="true"/>
		<cfargument name="MPListId" type="string" required="true"/>
    	
		<cfquery name="qpdateProgramMPId" datasource="#application.datasource#">
			UPDATE Program_Fixed_Component
			SET Market_Price_List_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.MPListId#">
			WHERE  Program_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ProgramId#"> AND
					Deleted = 0
		</cfquery>
    </cffunction>
    
    <cffunction name="doCFLog">
    	<cfargument name="text" type="string" required="true"/>
   		<cflog text="#arguments.text#">
	</cffunction>
    
</cfcomponent>