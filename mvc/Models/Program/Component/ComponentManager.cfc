<cfcomponent name="ComponentManager" displayname="ComponentManager"  extends="mvc.Models.SettingsService" output="false">

	<cfscript>
		objTemplateManager		= CreateObject("component","components.programs.template.TemplateManager");
		objPaymentCycleManager 	= CreateObject("component", "components.programs.PaymentCycleManager");
		objProdRateManager		= CreateObject("component","mvc.Models.Program.Component.ProductRateManager");
		objComponentDefManager	= CreateObject("component","mvc.Models.Program.Component.ComponentDefManager");
	</cfscript>

	<cffunction name="getComponent" access="remote" output="false" returntype="Array" hint="function to return all program components">

		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="bItemDesc" type="Boolean" required="false" default="0" />
		<cfargument name="iCompType" type="Numeric" required="false" default="0" />
		<cfargument name="includeGroupMembers" type="Numeric" required="false" default="0" />
		<cfargument name="payeeType" type="string" required="false" default="" />
		<cfargument name="fromBillback" type="numeric" required="false" default="0" />
		<cfargument name="bNewRateMP" type="Boolean" required="false" default="0" />

		<cfscript>
			//set local variables
			var nProgramID				= "";
			var qGetFixedData			= "";
			var qGetRebateData			= "";
			var qGetLumpSumData			= "";
			var arrRet 					= ArrayNew(1);
			var arrRet1 				= ArrayNew(1);
			var arrRet2 				= ArrayNew(1);
			var strPayeeType			= "";
			var nRetToBillback			= 0;

			//assign local variables
			nProgramID 				= arguments.programId;
			strPayeeType			= arguments.payeeType;
			nRetToBillback			= arguments.fromBillback;

			if(arguments.iCompType == 0 || arguments.iCompType == 1){
				qGetFixedData 	= objProdRateManager.getProductRate(nProgramID,1);
				arrRet = getComponentDataStruct(qGetFixedData,nProgramID,1,arrRet,arguments.bItemDesc,0,arguments.bNewRateMP);
				//this.dmp(qGetFixedData);
			}
			if(arguments.iCompType == 0 || arguments.iCompType == 2){
				qGetRebateData 	= objProdRateManager.getProductRate(nProgramID,2,arguments.includeGroupMembers, strPayeeType);
				arrRet = getComponentDataStruct(qGetRebateData,nProgramID,2,arrRet,arguments.bItemDesc);
				//this.dmp(qGetRebateData);
			}
			if(arguments.iCompType == 0 || arguments.iCompType == 3){
				qGetLumpSumData	= objProdRateManager.getProductRate(nProgramID,3, 0, strPayeeType, nRetToBillback);
				arrRet = getComponentDataStruct(qGetLumpSumData,nProgramID,3,arrRet,arguments.bItemDesc, nRetToBillback);
			}
		</cfscript>

		<cfreturn arrRet />

	</cffunction>

	<cffunction name="getComponentDataStruct" output="false" returntype="Array">

		<cfargument name="componentData" type="query" required="true" />
		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="type" type="Numeric" required="true" />
		<cfargument name="returnArray" type="array" required="true" />
		<cfargument name="bItemDesc" type="Boolean" required="false" default="0" />
		<cfargument name="fromBillback" type="numeric" required="false" default="0" />
		<cfargument name="bNewRateMP" type="Boolean" required="false" default="0" />

		<cfscript>
			//set local variables
			var qComponentData	= "";
			var nProgramID		= "";
			var nType			= "";
			var arrProdRate 	= ArrayNew(1);
			var arrRetData		= "";
			var bMarketPriceTemplate = JavaCast("boolean",false );
			var nRetToBillback	= 0;
			var strGroupBy		= "componentId";
			var template = objTemplateManager.getProgramTemplate(arguments.programId);
			var compDefMan = CreateObject("component","mvc.Models.Program.Component.ComponentDefManager");
			//assign local variables
			qComponentData	= arguments.componentData;
			nProgramID		= arguments.programId;
			nType			= arguments.type;
			arrRetData		= arguments.returnArray;
			nRetToBillback	= arguments.fromBillback;
			if(template.Market_Price == 1){
				bMarketPriceTemplate = JavaCast("boolean",true );
			}
			nRetToBillback	= arguments.fromBillback;

			if (nRetToBillback eq 1 and nType eq 3){
				strGroupBy = "programComponentId";
			}
		</cfscript>

		<cfoutput query="qComponentData" group="#strGroupBy#">
		<!--- <cfoutput query="qComponentData" group="componentId"> --->
			<cfif  qComponentData.restrictBB EQ "">
				<cfset qComponentData.restrictBB = false />
			</cfif>
			<cfif  qComponentData.bAutoPay EQ "">
				<cfset qComponentData.bAutoPay = false />
			</cfif>
			<cfscript>
				arrCompDef = compDefMan.getFixRebComponentDef(nProgramID,qComponentData.componentId,nType);
				//this.dmp(arrCompDef);
				//build PaidTo Object
				stPaidTo = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.PaidTo";
				stData["paidToId"] = qComponentData.paidTo;
				stData["description"] = objTemplateManager.getPaymentPaidToTypeDesc(paidToID = qComponentData.paidTo, paidToDesc="");
				stPaidTo = stData;

				//build PaymentCycle Object
				// get the PaymentCycle ID and Description
				nPaymentCycleID = objPaymentCycleManager.getPaymentCycle(nProgramID, nType, qComponentData.programComponentId);
				sPaymentCycleDesc = objPaymentCycleManager.getPaymentCycleDescription(nPaymentCycleID);
				stPaymentCycle = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.PaymentCycle";
				stData["paymentCycleId"] = nPaymentCycleID;
				stData["description"] = sPaymentCycleDesc;
				stPaymentCycle = stData;

				//build ClaimMechanic Object
				stClaimMechanic = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.ClaimMechanic";
				stData["claimMechanicId"] = qComponentData.claimMechanicId;
				stData["description"] = qComponentData.claimMechanicDesc;
				stData["payeeTypeId"] = qComponentData.claimMechPayeeTypeId;
				stData["restrictBB"] = javacast("boolean", qComponentData.restrictBB);
				stData["bAutoPay"] = javacast("boolean", qComponentData.bAutoPay);
				stClaimMechanic = stData;

				//build Payee Object
				stPayee = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.Payee";
				stData["payeeTypeId"] = qComponentData.payeeTypeId;
				stData["name"] = qComponentData.payeeName;
				stData["payeeId"] = qComponentData.payeeId;
				stPayee = stData;

				//build GlAccount Object
				stGlAccount = structNew();
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.GlAccount";
				stData["glAccountId"] = qComponentData.glAccountId;
				stData["description"] = qComponentData.glDescription;
				stGlAccount = stData;

				stCustPrint = structNew();
				stCustPrint["__type__"] = "mvc.Models.Program.Component.vos.CustomPrint";
				stCustPrint["bCustomPrint"] =  JavaCast("boolean",0 ); //qComponentData.bCustomPrint;  this is returned via ItemSearchService getCompItems after Program is loaded
				/*stCustPrint["iColors"] =  qComponentData.iColors;
				stCustPrint["sGraphics"] =  qComponentData.sGraphics;
				stCustPrint["bDigital"] =  qComponentData.bDigital;*/

				arrProdRate 	= objProdRateManager.getProductRateDataStruct(qComponentData, componentId, arguments.bItemDesc, arguments.bNewRateMP, evaluate("#strGroupBy#"), nType, nProgramID);
				//build Component Object
				stData = structNew();
				stData["__type__"] = "mvc.Models.Program.Component.vos.Component";
				stData["componentId"] = qComponentData.componentId;
				stData["name"] = qComponentData.name;
				stData["type"] = nType;
				if(nType == 1){
					stData["fixedType"] = fixedType;
				}
				stData["prodRate"] = arrProdRate;
				stData["paidTo"] = stPaidTo;
				stData["paymentCycle"] = stPaymentCycle;
				stData["claimMechanic"] = stClaimMechanic;
				stData["payee"] = stPayee;
				stData["glAccount"] = stGlAccount;
				stData["uom"] = objComponentDefManager.getComponentUomData(nProgramID, nType);
				stData["bMarketPriceTemplate"] = JavaCast("boolean",bMarketPriceTemplate );
				stData["programId"] = nProgramID;
				stData["programNumber"] = qComponentData.programNumber;
				stData["programTitle"] = qComponentData.programTitle;
				if(Arraylen(arrProdRate) > 0){
					stData["compRate"] = arrProdRate[1].rate;
					stData["compDescription"] = arrProdRate[1].compDescription;
				}
				else{
					stData["compRate"] = 0;
					stData["compDescription"] = '';
				}
				stData["programComponentId"] = qComponentData.programComponentId;
				stData["customPrint"] = stCustPrint;
				if(Arraylen(arrCompDef) > 0){
					stData["componentDef"] = arrCompDef[1];
				}else{
					stData["componentDef"] = structnew();
				}

				ArrayAppend(arrRetData, duplicate(stData));
				//this.doCFLog(stPayee.name);
			</cfscript>

		</cfoutput>

		<cfreturn arrRetData />

	</cffunction>

	<!--- The "Save" function for Ag grid program rates --->
	<cffunction name="saveComponentDataJSON" access="remote" output="false" returnFormat="json">
		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="acComponents" type="array" required="true" />
		<cfargument name="bMarketPrice" type="Boolean" required="false" default="false" />

		<cfset local.reply = {}>

		<cfset saveComponentData(arguments.programId,arguments.acComponents,arguments.bMarketPrice)>

		<cfset local.reply.status = "success">

		<cfreturn serializeJSON(local.reply, "struct")>

	</cffunction>

 	<!---SAVE Component Wrapper sends request To Market Price or stays here--->
	<cffunction name="saveComponentData" access="remote" output="false" returntype="boolean" hint="function to return all components">
		<cfargument name="programId" type="Numeric" required="true" />
		<cfargument name="acComponents" type="Array" required="true" />
		<cfargument name="bMarketPrice" type="Boolean" required="false" default="false" />
		<cfscript>
			//set local variables
			var bRet 				= 0;
			var objMarketPrice	= "";

			if(arguments.bMarketPrice){
				objMarketPrice		= CreateObject("component","mvc.Models.Template.MarketPriceManager");
				bRet = objMarketPrice.saveMPData(arguments.programId,arguments.acComponents);
			}
			else{
				bRet = this.saveComponentDataPrg(arguments.programId,arguments.acComponents);
			}
		</cfscript>
		<cfreturn bRet />
	</cffunction>

	<cffunction name="getTemplateMultiPrdAttrGroups" returntype="boolean">

		<cfreturn application.appSettingsGet.getTemplateMultipleProductAttrGroups()>
	</cffunction>


	<cffunction name="saveComponentDataPrg" output="false" access="remote" returntype="boolean" >
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
			var indx3					= "";
			var nFixedCompID			= "";
			var nFixedContractProdID	= "";
			var stFixedContractProd		= structNew();
			var nRebateCompID			= "";
			var nRebateProdID			= "";
			var nRebateContractProdID	= "";
			var stRebateContractProd	= structNew();
			var nPricingLevel			= 1;
			var payeeId					= '';
			var stVolume				= structNew();
			var	i						= "";
			var nProgramSpan			= 1;
			var nWeeklyCs				= "";
			var nProgramVolume			= "";
			var nDailyVolume			= "";
			var stRebateProdData		= structNew();
			var prgTemplate				= "";
			var bIsGroup				= 0;
			var bIsGroupProgramFlag		= 0;
			var nRateMP					= 0;
			var bRebRateCount			= 0;
			var bFixRateCount			= 0;
			var	qGetRebateVolumeOverrideSelection = "";
			var	qGetFixedVolumeOverrideSelection = "";
			//assign local variables
			nProgramID	= arguments.programId;
			arrData		= arguments.acComponents;
			//template settings
			prgTemplate = objTemplateManager.getProgramTemplate(nProgramID);
			rebateCompProfile = CreateObject("component","components.programs.rebates.RebateComponentProfile");
			fixCompProfile = CreateObject("component","components.programs.Fixed.FixedComponentProfile");

			lfixCompProfile = fixCompProfile.compIdsToFilter(request.accessStructure.PROFILES_ID);
			lRebCompProfile = rebateCompProfile.compIdsToFilter(request.accessStructure.PROFILES_ID);

			objProgramTemplateManager	= CreateObject("component","components.programs.Display_Program.viewprogramtemplateManager");
			if(this.getTemplateMultiPrdAttrGroups() EQ 1){
				qGetDistributors = objProgramTemplateManager.getDistributors(nProgramID, 0, 0, 0);
			}

			getSettings = objProgramTemplateManager.getSettings(nProgramID);
			//this.dmp(arguments);
		</cfscript>
		<cftransaction>
			<!--- get the program span --->
			<cfquery name="qGetProgramSpan" datasource="#application.datasource#">
				SELECT	DATEDIFF(d, Contract_Start_Date, Contract_End_Date) + 1 AS Program_Span,
						Contract_Quantity_UOM_IDX
				FROM 	Contract_Main
				WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
			</cfquery>

			<cfset nProgramSpan = qGetProgramSpan.Program_Span />
			<cfset Contract_Quantity_UOM_IDX = qGetProgramSpan.Contract_Quantity_UOM_IDX />

			<!--- Tim Ford - 01/25/2016: WR 56932 - VOLUME OVERRRIDE LOGIC - CURRENT DESIGN AFFECTS PRODUCTIVITY
			Retain the selected value for Dont_Count_Volume from Program_Fixed_Component
			--->
			<CFQUERY NAME="qGetFixedVolumeOverrideSelection" datasource="#application.datasource#">
				SELECT	DISTINCT Dont_Count_Volume, Program_Fixed_Component_Name_ID
				FROM	Program_Fixed_Component
				WHERE	Deleted = 0
				AND		Program_ID = #nProgramID#
				AND		Dont_Count_Volume = 1
			</CFQUERY>

			<CFQUERY NAME="qGetRebateVolumeOverrideSelection" datasource="#application.datasource#">
				SELECT	DISTINCT Dont_Count_Volume, Program_Rebates_Component_Name_ID
				FROM	Program_Rebates_Component
				WHERE	Deleted = 0
				AND		Program_ID = #nProgramID#
				AND		Dont_Count_Volume = 1
			</CFQUERY>

			<!--- Don't Delete Componenst that this user is restricted from seeing/editing --->
			<cfquery name="deleteFixedComponents" datasource="#application.datasource#">
				DELETE FROM Program_Fixed_Component
				WHERE Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				<cfif ListLen(lfixCompProfile)>
					AND Program_Fixed_Component_Name_ID NOT IN (#lfixCompProfile#)
				</cfif>
			</cfquery>

			<cfquery name="deleteFixedProducts" datasource="#application.datasource#">
				DELETE FROM Program_Fixed_Price_Product_Data
				WHERE Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				<cfif ListLen(lfixCompProfile)>
				AND Program_Fixed_Component_ID NOT IN (SELECT Program_Fixed_Component_ID FROM Program_Fixed_Component
														WHERE Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" /> AND
														Program_Fixed_Component_Name_ID IN (#lfixCompProfile#) AND Deleted = 0)
				</cfif>
			</cfquery>

			<cfquery name="deleteFixedFreightProducts" datasource="#application.datasource#">
				--Program_Fixed_Freight_Rates
				DELETE FROM Program_Fixed_Freight_Rates
				WHERE Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				<cfif ListLen(lfixCompProfile)>
				 AND Component_Name_Id NOT IN  (#lfixCompProfile#)
				</cfif>
			</cfquery>
			<cfif this.getTemplateMultiPrdAttrGroups() EQ 1 >
				<cfquery name="deleteCustomPrintOptions" datasource="#application.datasource#">
					--Program_Fixed_Freight_Rates
					--DELETE FROM
					UPDATE Print_Program_Custom_Options
					SET Deleted = 1
					WHERE Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				</cfquery>
			</cfif>
			<!--- first delete everything from the discount tables for fixed and rebate --->
			<cfquery name="deleteFixedContractProducts" datasource="#application.datasource#" result="xx">
				DELETE FROM	Contract_Products
				WHERE 	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				AND 	Product_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="1" />
				<cfif ListLen(lfixCompProfile)>
				AND	Contract_Products_ID NOT IN (SELECT Contract_Products_ID
													FROM Program_Fixed_Price_Product_Data PFPPD
													INNER JOIN Program_Fixed_Component PFC ON
														PFC.Program_Fixed_Component_ID = PFPPD.Program_Fixed_Component_ID
													WHERE PFC.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
													AND PFC.DELETED = 0
													AND PFC.Program_Fixed_Component_Name_ID IN (#lfixCompProfile#)
												)
				</cfif>
			</cfquery>

			<cfquery name="deleteRebateComponentData" datasource="#application.datasource#">
				DELETE FROM	Program_Rebates_Component_Data
				FROM	Program_Rebates_Component_Data
						INNER JOIN Program_Rebates_Product_Data ON
						Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID
						INNER JOIN Program_Rebates_Component ON
						Program_Rebates_Component.Program_Rebates_Component_ID = Program_Rebates_Component_Data.Program_Rebates_Component_ID
						<cfif ListLen(lRebCompProfile)>
							AND Program_Rebates_Component.Program_Rebates_Component_Name_ID NOT IN (#lRebCompProfile#)-- DONT UPDATE COMPONENTS THIS USER CAN NOT ACCESS
						</cfif>
				WHERE 	Program_Rebates_Product_Data.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				<cfif this.getTemplateMultiPrdAttrGroups() EQ FALSE>
					AND		Program_Rebates_Product_Data.Is_Group = <cfqueryparam cfsqltype="CF_SQL_BIT" value="0">
					AND		Program_Rebates_Component_Data.Is_Group = <cfqueryparam cfsqltype="CF_SQL_BIT" value="0">
				</cfif>
				AND		Program_Rebates_Component.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
			</cfquery>

			<cfquery name="deleteRebateProducts" datasource="#application.datasource#">
				DELETE FROM Program_Rebates_Product_Data
				WHERE	Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				<cfif this.getTemplateMultiPrdAttrGroups() EQ FALSE>
					AND		Is_Group = <cfqueryparam cfsqltype="CF_SQL_BIT" value="0">
				</cfif>
				<cfif ListLen(lRebCompProfile)>
				AND Program_Rebates_Product_Data_ID NOT IN(
						SELECT Program_Rebates_Product_Data_ID
						FROM Program_Rebates_Component_Data PRCD
						INNER JOIN Program_Rebates_Component PRC ON
							PRC.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID
						WHERE
						<cfif this.getTemplateMultiPrdAttrGroups() EQ FALSE>
							PRCD.Is_Group = <cfqueryparam cfsqltype="CF_SQL_BIT" value="0"> AND
						</cfif>
						PRCD.Deleted = 0
						AND PRC.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
						AND PRC.Program_Rebates_Component_Name_ID IN (#lRebCompProfile#)
				)
				</cfif>
			</cfquery>

			<cfquery name="deleteRebateContractProducts" datasource="#application.datasource#">
				DELETE FROM Contract_Products
				WHERE	Contract_Main_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				AND		Product_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="2" />
				<cfif this.getTemplateMultiPrdAttrGroups() EQ FALSE>
					AND		Is_Group = <cfqueryparam cfsqltype="CF_SQL_BIT" value="0">
				</cfif>
				<cfif ListLen(lRebCompProfile)>
				AND Contract_Products_ID NOT IN(
						SELECT Contract_Products_ID
						FROM Program_Rebates_Component_Data PRCD
						INNER JOIN Program_Rebates_Product_Data PRPD ON
							PRPD.Program_Rebates_Product_Data_ID = PRCD.Program_Rebates_Product_Data_ID
						INNER JOIN Program_Rebates_Component PRC ON
							PRC.Program_Rebates_Component_ID = PRCD.Program_Rebates_Component_ID
						WHERE
						<cfif this.getTemplateMultiPrdAttrGroups() EQ FALSE>
							PRCD.Is_Group = <cfqueryparam cfsqltype="CF_SQL_BIT" value="0"> AND
						</cfif>
						PRCD.Deleted = 0
						AND PRC.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
						AND PRC.Program_Rebates_Component_Name_ID IN (#lRebCompProfile#)
					)
				</cfif>
			</cfquery>

			<!--- check if there is a group entry and if there is then we have to do an update on rebate component --->
			<cfquery name="qGetRebateGroupEntires" datasource="#application.datasource#">
				SELECT	Program_Rebates_Component_ID,
						Program_Rebates_Component_Name_ID
				FROM	Program_Rebates_Component
				WHERE	Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
				AND		Deleted = 0
				AND		Program_Rebates_Component_ID IN (SELECT Program_Rebates_Component_ID FROM Program_Rebates_Component_Data WHERE Is_Group = 1)
			</cfquery>

			<cfif qGetRebateGroupEntires.RecordCount>

				<cfquery name="qGetPricingLevel" datasource="#application.datasource#">
					SELECT	DISTINCT TOP 1 Pricing_Level_ID
					FROM	Contract_Products
					WHERE	Contract_Main_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
					AND		Product_Type_ID = 2
					AND		Is_Group = 1
					AND		Deleted = 0
					ORDER BY Pricing_Level_ID DESC
				</cfquery>

				<cfset nPricingLevel = qGetPricingLevel.Pricing_Level_ID + 1 />

			<cfelse>

				<cfquery name="deleteRebateComponents" datasource="#application.datasource#">
					DELETE FROM Program_Rebates_Component
					WHERE	Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
					<cfif ListLen(lRebCompProfile)>
					AND Program_Rebates_Component.Program_Rebates_Component_Name_ID NOT IN (#lRebCompProfile#)
					</cfif>
				</cfquery>

			</cfif>
			<cfset program_fixed_component_name_id_list = StructNew()>	<!--- D30253 : Rebate Grid dropping strategy code from 2200 --->
			<cfloop index="indx" array="#arrData#">
				<cfparam name="vendorSelection" default="0" />
				<cfset glAccountId = 0 />
				<cfset payeeId = '' />
				<cfset payeeTypeId = '' />
				<cfif structKeyExists(indx,'prodRate') && IsArray(indx.prodRate)>
					<!---ALL SET--->
				<cfelse>
						<cfset indx.prodRate = ArrayNew(1) />
				</cfif>

				<!--- Get the glAccountId if it is populated --->

<!---				<cfif structKeyExists(indx,'glAccount') && isStruct(indx.glAccount) && structKeyExists(indx.glAccount,'glAccountId') >
--->
				<cfif structKeyExists(indx,'glAccount') && isDefined("indx.glAccount.glAccountId") >

					<cfset glAccountId = indx.glAccount.glAccountId />
				</cfif>

				<!--- Get the payee id --->
				<cfif structKeyExists(indx,'payee') && structKeyExists(indx.payee,'payeeTypeId') && indx.claimMechanic.payeeTypeId gt 0>
					<cfset payeeTypeId = indx.payee.payeeTypeId />
					<cfif indx.payee.payeeTypeId eq 5>
						<cfquery datasource="#application.datasource#" name="qGetVendorId">
							SELECT Vendor_Master_ID
							FROM Vendor_Master
							WHERE Vendor_ID = <cfqueryparam value="#indx.payee.payeeId#" cfsqltype="cf_sql_varchar"  />
						</cfquery>
						<cfset payeeId = qGetVendorId.Vendor_Master_ID>
					<cfelseif indx.payee.payeeTypeId eq 1>
						<cfquery datasource="#application.datasource#" name="qGetCustomerId">
							SELECT BSA_Foodservice_Customers_ID
							FROM bsa_foodservice_Customers
							WHERE Ship_To = <cfqueryparam value="#indx.payee.payeeId#" cfsqltype="cf_sql_varchar"  />
						</cfquery>
						<cfset payeeId = qGetCustomerId.BSA_Foodservice_Customers_ID>
					<cfelse>
						<cfset payeeId = '' />
					</cfif>
				</cfif>

				<!--- set vendor selection --->
				<cfif indx.claimMechanic.payeeTypeId gt 0>
					<cfif len(trim(payeeId)) gt 0>
						<cfset vendorSelection = 1 />
					<cfelse>
						<cfset vendorSelection = 2 />
					</cfif>
				</cfif>
				<!---<cflog text="Legacypayee::  #indx.payee.payeeId#  :: typeId: #indx.payee.payeeTypeId# :: BaPayeeId: #payeeId# :: #indx.type#"/>--->
				<!--- populate tables for fixed price data --->
				<cfif indx.type eq 1>
					<!--- insert into the Program_Fixed_Component table --->
					<!--- FIX BRANCH TARGET OFFSET ERROR BECUSE FUNCTION [CFTRANSACTION?] IS TOO BIG :: CFC wont compile at runtime if it is all one file?--->
					<cfinclude template="ComponentManagerIncludeFixed.cfm" >
					<!--- FIX BRANCH TARGET OFFSET ERROR BECUSE FUNCTION [CFTRANSACTION?] IS TOO BIG --->

					<!--- set Pricing_Level_Id AND Now cleanup 0 rate Items That are not Exceptions (Pricing_Level_Id = 1)--->
					<cfif this.getTemplateMultiPrdAttrGroups() EQ 1>

						<cfscript>
							var FirstParentId = GetSettings.First_Parent_Id;

							var obj = CreateObject("component","components.products.Group.ProductGroupAttributeManager");
							var qGroupsInTemplate = obj.getProductGroupAttributesGroupTemplate(active = 1, FirstParentID = FirstParentId, TemplateFiltersID = 0);
						</cfscript>
						<cfif isDefined("qGroupsInTemplate")>
							<cfset sJoin = '' />
						 	 <cfset q = qGroupsInTemplate/>
							<cfloop query="qGroupsInTemplate">
								<cfscript>
									if(qGroupsInTemplate.PG_FLAG == 0 && qGroupsInTemplate.ALLOW_IN_GROUP_SEARCH == 1){
										 sJoin = ' #sJoin#
										 			AND GRPIM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD#  =  IM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# AND
										 			IM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# IS NOT NULL ';
									}
								</cfscript>
							</cfloop>
					   </cfif>
					   <!--- Set Pricing_Level_Id = 2 If a Group record exists with a Non zero rate for this item. --->
						<cfquery name="updFixedProductsPricingLevel" datasource="#application.datasource#">
							UPDATE CP
							SET Pricing_Level_Id = 2
							--SELECT *
							FROM Program_Fixed_Price_Product_Data PFPP
							INNER JOIN Contract_Products CP ON
								Contract_Main_ID =	<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
								Product_Type_ID = 	<cfqueryparam value="1" cfsqltype="cf_sql_integer" /> AND
								CP.Is_Group = 0 AND
								CP.Captured_From_Group = 0 AND
								PFPP.Contract_Products_ID = CP.Contract_Products_ID
							INNER JOIN BSA_Foodservice_Items_Master IM ON
								CP.BSA_Foodservice_Items_Master_ID = IM.BSA_Foodservice_Items_Master_ID
							INNER JOIN BSA_Foodservice_Items_Master GRPIM ON
								GRPIM.Is_Item_Group = 1 #sJoin#
							INNER JOIN Contract_Products CPGRP ON
								CPGRP.Contract_Main_ID =	<cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" /> AND
								CPGRP.Product_Type_ID = 	1 AND
								CPGRP.Is_Group = 1 AND
								CPGRP.Captured_From_Group = 0 AND
								CPGRP.BSA_Foodservice_Items_Master_ID = GRPIM.BSA_Foodservice_Items_Master_ID
							INNER JOIN Program_Fixed_Price_Product_Data GRPFPP ON
								GRPFPP.Contract_Products_ID = CPGRP.Contract_Products_ID
								AND GRPFPP.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
							     AND GRPFPP.Program_Fixed_Component_ID = <cfqueryparam value="#nFixedCompID#" cfsqltype="cf_sql_integer" />
								 AND GRPFPP.Fixed_Price_Value != <cfqueryparam value="0.0000" cfsqltype="cf_sql_decimal" />
							WHERE PFPP.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
							     AND PFPP.Program_Fixed_Component_ID = <cfqueryparam value="#nFixedCompID#" cfsqltype="cf_sql_integer" />
								 AND CP.Pricing_Level_Id = 1
						</cfquery>

						<!--- COMMENTED OUT MWS.  We Allow 0 rate items for Cust level rates.  That is the only scenario where 0 rates get inserted.  originally, we had 0 rates for exceptions
							in groups.  The rates grid only supports multi attr groups and that client has tested groups for 8 months with code in place that does not even allow 0 rates to go into
							fixed and contract prod tables.  The cust level rates is for same client.
						CURRENTLY ComponentManagerIncludeFixed.cfm ONLY Inserts 0 rates for Cust level rates and NOT GROUP Exceptions  --->
						<!---:: START :: Now cleanup 0 rate Items :: START :: --->
						<!---
						<cfquery name="delContractProductsNoRate" datasource="#application.datasource#">
							UPDATE CP
							SET DELETED = 1
							<!---WHERE Contract_Products_ID IN(
							SELECT CP.Contract_Products_ID--->
							FROM Program_Fixed_Price_Product_Data PFPP
							INNER JOIN Contract_Products CP ON
								Contract_Main_ID =	#nProgramID# AND
								Product_Type_ID = 	<cfqueryparam value="1" cfsqltype="cf_sql_integer" /> AND
								CP.Captured_From_Group = 0 AND
								PFPP.Contract_Products_ID = CP.Contract_Products_ID
							WHERE PFPP.Program_ID = #nProgramID#
							     AND PFPP.Program_Fixed_Component_ID = <cfqueryparam value="#nFixedCompID#" cfsqltype="cf_sql_integer" />
								 AND PFPP.Fixed_Price_Value = <cfqueryparam value="0.0000" cfsqltype="cf_sql_decimal" />
								 AND CP.Pricing_Level_Id = 1
								 AND CP.Deleted = 0
								 AND PFPP.Deleted = 0
								 -- Do Not Delete CP records where the same item is on another component at a different Peicing_Level Or with A non zero rate
								AND CP.Contract_Products_ID NOT IN(SELECT CP_NOT.Contract_Products_ID FROM Program_Fixed_Price_Product_Data PFPP_Not
								 												INNER JOIN Contract_Products CP_NOT ON
								 													PFPP_Not.Contract_Products_ID = CP_NOT.Contract_Products_ID
								 											WHERE PFPP_Not.Program_ID = #nProgramID#
																			     AND PFPP_Not.Program_Fixed_Component_ID != <cfqueryparam value="#nFixedCompID#" cfsqltype="cf_sql_integer" />
																				AND
																				(
																					(
																						PFPP_Not.Fixed_Price_Value != <cfqueryparam value="0.0000" cfsqltype="cf_sql_decimal" />
																					 )
																					 OR
																					 (CP_NOT.Pricing_Level_Id = 2)
																				  )
																				 AND PFPP_Not.Deleted = 0
																				 AND CP_NOT.Deleted = 0)
						</cfquery>
						<cfquery name="delFixedProductsNoRate" datasource="#application.datasource#">
							UPDATE Program_Fixed_Price_Product_Data
							SET DELETED = 1
							WHERE Program_Fixed_Price_Product_Data_Id IN(
							SELECT Program_Fixed_Price_Product_Data_Id
							FROM Program_Fixed_Price_Product_Data PFPP
							INNER JOIN Contract_Products CP ON
								Contract_Main_ID =	<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
								Product_Type_ID = 	<cfqueryparam value="1" cfsqltype="cf_sql_integer" /> AND
								CP.Captured_From_Group = 0 AND
								PFPP.Contract_Products_ID = CP.Contract_Products_ID
							WHERE PFPP.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
							     AND PFPP.Program_Fixed_Component_ID = <cfqueryparam value="#nFixedCompID#" cfsqltype="cf_sql_integer" />
								 AND PFPP.Fixed_Price_Value = <cfqueryparam value="0.0000" cfsqltype="cf_sql_decimal" />
								 AND CP.Pricing_Level_Id = 1
								 AND CP.Deleted = 1
								 AND PFPP.Deleted = 0
								 )
						</cfquery>  --->
					</cfif>
					<!---:: END :: Now cleanup 0 rate Items :: END :: --->
				<!--- populate tables for rebate data --->
				<cfelse>

					<!--- get the record for the existing entry --->
					<cfquery name="qGetExistingRebateComponentData" datasource="#application.datasource#">
						SELECT	Program_Rebates_Component_ID,
								Program_Rebates_Component_Name_ID,
								Program_ID,
								Component_Paid_To,
								GL_Account_ID,
								Vendor_Master_ID,
								Payee_Type,
								Claim_Mechanics
						FROM	Program_Rebates_Component
						WHERE	Program_Rebates_Component_Name_ID = <cfqueryparam value="#indx.componentId#" cfsqltype="CF_SQL_INTEGER" />
						AND		Program_ID = <cfqueryparam value="#nProgramID#" cfsqltype="CF_SQL_INTEGER" />
						AND		Deleted = 0
					</cfquery>

					<cfif qGetExistingRebateComponentData.RecordCount>


						<cfquery name="qUpdateRebateComponent" datasource="#application.datasource#">
							UPDATE	Program_Rebates_Component
							SET		Component_Paid_To = <cfqueryparam value="#indx.paidTo.paidToId#" cfsqltype="CF_SQL_INTEGER" />,
									GL_Account_ID = <cfqueryparam value="#glAccountId#" cfsqltype="CF_SQL_VARCHAR" />,
									Vendor_Master_ID = <cfqueryparam value="#payeeId#" cfsqltype="cf_sql_varchar" null="#len(payeeId) eq 0#" />
							WHERE	Program_Rebates_Component_ID = <cfqueryparam value="#qGetExistingRebateComponentData.Program_Rebates_Component_ID#" cfsqltype="CF_SQL_INTEGER" />
						</cfquery>

						<!--- set the rebate component id --->
						<cfset nRebateCompID = qGetExistingRebateComponentData.Program_Rebates_Component_ID />

					<cfelse>

						<!--- D30096: Cannot click into Freight page for each DST START--->
						<cfquery name="GetCompInfo" datasource="#application.datasource#" cachedwithin="#createtimespan(0,0,20,0)#">
							SELECT External_ID
							FROM Program_Rebates_Component_Name
							WHERE Program_Rebates_Component_Name_ID = '#indx.componentId#'
						</cfquery>
						<!--- D30096: Cannot click into Freight page for each DST END--->

						<!--- Tim Ford - 01/25/2016: WR 56932 - VOLUME OVERRRIDE LOGIC - CURRENT DESIGN AFFECTS PRODUCTIVITY
						Retain the selected value for Dont_Count_Volume from Program_Fixed_Component
						--->
						<cfset bRebRateCount = 0 />

						<CFQUERY NAME="qGetRebVolOverrideTemp" dbtype="query">
							SELECT	Dont_Count_Volume
							FROM	qGetRebateVolumeOverrideSelection
							WHERE	Program_Rebates_Component_Name_ID = #indx.componentId#
						</CFQUERY>
						<cfif qGetRebVolOverrideTemp.RecordCount>
							<cfset bRebRateCount = qGetRebVolOverrideTemp.Dont_Count_Volume />
						</cfif>

						<!--- insert into the Program_Rebates_Component table --->
						<cfquery name="qInsertRebateComponent" datasource="#application.datasource#">
							INSERT INTO	Program_Rebates_Component
								(
									Program_Rebates_Component_Name_ID,
									Program_ID,
									Component_Paid_To,
									GL_Account_ID,
									Vendor_Master_ID,
									Payee_Type,
									Claim_Mechanics,
									Vendor_Selection,
									Component_External_ID,<!--- D30096: Cannot click into Freight page for each DST--->
									Dont_Count_Volume
								)
							VALUES
								(
									<cfqueryparam value="#indx.componentId#" cfsqltype="CF_SQL_INTEGER" />,
									<cfqueryparam value="#nProgramID#" cfsqltype="CF_SQL_INTEGER" />,
									<cfqueryparam value="#indx.paidTo.paidToId#" cfsqltype="CF_SQL_INTEGER" />,
									<cfqueryparam value="#glAccountId#" cfsqltype="CF_SQL_VARCHAR" />,
									<cfqueryparam value="#payeeId#" cfsqltype="CF_SQL_VARCHAR" null="#len(trim(payeeId)) eq 0#" />,
									<cfqueryparam value="#payeeTypeId#" cfsqltype="CF_SQL_INTEGER" null="#len(trim(payeeTypeId)) eq 0#" />,
									<cfqueryparam value="#indx.claimMechanic.claimMechanicId#" cfsqltype="CF_SQL_INTEGER" />,
									<cfqueryparam value="#vendorSelection#" cfsqltype="cf_sql_integer" />,
									<cfqueryparam value="#GetCompInfo.External_ID#" cfsqltype="CF_SQL_VARCHAR">,<!--- D30096: Cannot click into Freight page for each DST--->
									<cfqueryparam value="#bRebRateCount#" cfsqltype="CF_SQL_BIT">
								)
						</cfquery>

						<!--- set the rebate component id --->
						<cfset nRebateCompID = qInsertRebateComponent.Program_Rebates_Component_ID />

						<!--- save payment cycle data --->
						<cfset objPaymentCycleManager.savePaymentCycle(nProgramID, 2, indx.paymentCycle.paymentCycleId, nRebateCompID) />

					</cfif>

					<!--- set the rebate prod rate array AND isArray(indx.prodRate) --->
					<cfset arrRebateProdRateData = indx.prodRate />
					<!--- loop over the rebate prod rate array --->
					<cfloop index="indx3" array="#arrRebateProdRateData#">
						<cfset bIsGroup = 0 />
						<!---only add items with a rate (0 rate means remove) or if it is an exception (nPricingLevel) AND it is a guid--->
							<!--- Updated for Perf.  MultAttr groups is not employing 0 rate exceptions.  we can go back if we need but only adding Non zero helps performance
								  since we don't have to check and remove invalis 0 rates later  --->
						<cfif indx3.rate GT 0> <!---  (indx3.rate GT 0 OR nPricingLevel GT 1 OR this.getTemplateMultiPrdAttrGroups() EQ 1) AND len(indx3.itemGuid) EQ 36 --->
							<!--- get the Contract_Product_ID from the stRebateContractProd struct if the item has already been inserted into Contract_Products --->
							<cfif structKeyExists(stRebateContractProd,indx3.itemGuid)>
								<cfset nRebateContractProdID = stRebateContractProd["#indx3.itemGuid#"] />
								<cfset nRebateProdID = stRebateProdData["#indx3.itemGuid#"] />
								<cfset bIsGroup = stRebateIsGroup["#indx3.itemGuid#"] />
							<!--- otherwise insert into Contract_Products if the item hasn't already been inserted  --->
							<cfelse>
								<!--- check if record exists.  In case of profile Filtered Components we don't delete contract_Products record --->
								<cfquery name="qAddRebateContractProducts" datasource="#application.datasource#">
									SELECT	ISNULL(CP.Contract_Products_ID,0) AS Contract_Products_ID,
										IM.Is_Item_Group AS isGroup
									FROM BSA_Foodservice_Items_Master IM
									LEFT JOIN Contract_Products CP ON
										CP.BSA_Foodservice_Items_Master_ID = IM.BSA_Foodservice_Items_Master_ID AND
										CP.Contract_Main_ID =	<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
										CP.Product_Type_ID = 	<cfqueryparam value="2" cfsqltype="cf_sql_integer" /> AND
										CP.Deleted = 0
										<cfif this.getTemplateMultiPrdAttrGroups() EQ 0>
										AND CP.Pricing_Level_ID =	<cfqueryparam value="#nPricingLevel#" cfsqltype="cf_sql_integer" />
										</cfif>
									WHERE
									IM.BSA_Foodservice_Items_Master_ID =	<cfqueryparam value="#indx3.itemGuid#" cfsqltype="cf_sql_varchar" /> AND
									IM.Deleted = 0
								</cfquery>
								<cfif qAddRebateContractProducts.isGroup EQ 1>
									<cfset bIsGroup = 1 />
									<cfset bIsGroupProgramFlag = 1 />
								</cfif>
								<cfset stRebateIsGroup["#indx3.itemGuid#"] = bIsGroup />
								<CFIF qAddRebateContractProducts.Contract_Products_ID EQ 0>
									<cfquery name="qAddRebateContractProducts" datasource="#application.datasource#">
										INSERT INTO	Contract_Products
										(
											BSA_Foodservice_Items_Master_ID,
											Contract_Main_ID,
											Product_Type_ID,
											Pricing_Level_ID,
											Is_Group
											<cfif bIsGroup>
												,Product_Group_Id
											</cfif>
										)
										VALUES
										(
											<cfqueryparam value="#indx3.itemGuid#" cfsqltype="cf_sql_varchar" />,
											<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="2" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#nPricingLevel#" cfsqltype="cf_sql_integer" />	,
											<cfqueryparam value="#bIsGroup#" cfsqltype="cf_sql_bit" />
											<cfif bIsGroup>
												,<cfqueryparam value="#indx3.itemGuid#" cfsqltype="cf_sql_varchar" />
											</cfif>
										)
										SELECT Contract_Products_Id = @@IDENTITY
									</cfquery>
								</cfif>
								<!--- set the Contract_Product_Id --->
								<cfset nRebateContractProdID = qAddRebateContractproducts.Contract_Products_ID />
								<cfif !isNumeric(nRebateContractProdID)>
									<cfset nRebateContractProdID = 0 />
								</cfif>
								<!--- now stuff the Contract_Product_ID into the stRebateContractProd struct using the Item Master ID as the struct key --->
								<cfset stRebateContractProd["#indx3.itemGuid#"] = nRebateContractProdID />

								<cfquery name="qAddRebateProdData" datasource="#application.datasource#">
									SELECT Program_Rebates_Product_Data_ID
									FROM Program_Rebates_Product_Data
									WHERE
										Program_ID = <cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
										Contract_Products_ID = <cfqueryparam value="#nRebateContractProdID#" cfsqltype="cf_sql_integer" />
								</cfquery>

								<CFIF qAddRebateProdData.RecordCount EQ 0>
									<!--- insert into the Program_Rebates_Product_Data table --->
									<cfquery name="qAddRebateProdData" datasource="#application.datasource#">
										INSERT INTO	Program_Rebates_Product_Data
										(
											Program_ID,
											Contract_Products_ID,
											Is_Group
										)
										VALUES
										(
											<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#nRebateContractProdID#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#bIsGroup#" cfsqltype="cf_sql_bit" />
										)
									</cfquery>
								</cfif>
								<!--- set the rebate product data id --->
								<cfset nRebateProdID = qAddRebateProdData.Program_Rebates_Product_Data_ID />
								<!--- now stuff the Program_Rebates_Product_Data_ID into the stRebateProdData struct using the Item Master ID as the struct key --->
								<cfset stRebateProdData["#indx3.itemGuid#"] = nRebateProdID />

							</cfif>

							<cfquery name="qCheckRebateCompData" datasource="#application.datasource#">
								SELECT Program_Rebates_Component_Data_ID
								FROM Program_Rebates_Component_Data
								WHERE
									Program_Rebates_Component_ID = <cfqueryparam value="#nRebateCompID#" cfsqltype="cf_sql_integer" /> AND
									Program_Rebates_Product_Data_ID = <cfqueryparam value="#nRebateProdID#" cfsqltype="CF_SQL_BIGINT" /> AND
									Deleted = 0
							</cfquery>

							<!--- D46003 Before inserting check if the record already exist to avoid duplication --->
							<cfif qCheckRebateCompData.RecordCount EQ 0>
								<!--- insert into the Program_Rebates_Component_Data table --->
								<cfquery name="qAddRebateCompData" datasource="#application.datasource#">
									INSERT INTO	Program_Rebates_Component_Data
									(
										Program_Rebates_Component_ID,
										Program_Rebates_Product_Data_ID,
										Rate,
										Unit_Of_Measure_Id,
										Is_Group
									)
									VALUES
									(
										<cfqueryparam value="#nRebateCompID#" cfsqltype="cf_sql_integer" />,
										<cfqueryparam value="#nRebateProdID#" cfsqltype="CF_SQL_BIGINT" />,
										<cfqueryparam value="#indx3.rate#" cfsqltype="cf_sql_varchar" />,
										<cfqueryparam value="#indx3.uom.uomId#" cfsqltype="cf_sql_integer" />,
										<cfqueryparam value="#bIsGroup#" cfsqltype="cf_sql_bit" />
									)
								</cfquery>
							</cfif>

							<cfscript>
								//MAy be needed for UOM HANDLING. Not implementred yet
								stData = structNew();
								stData["uomId"] = indx3.uom.uomId;
								stData["volume"] = indx3.volume;
								//stData["x"] = x;
							</cfscript>

							<!---inset volume into the volume struct --->
							<cfset structInsert(stVolume, indx3.itemGuid, duplicate(stData), true) />
						</cfif>
					</cfloop>

					<!--- D35295 :: Update market pricing to use new group rates grid.
									appSettings.getTemplateMultipleProductAttrGroups() Template Filter
									Setting "Allow In Group Search" Drives Product Groups.
						set Pricing_Level_Id AND Now cleanup 0 rate Items That are not Exceptions (Pricing_Level_Id = 1)--->
					<cfif this.getTemplateMultiPrdAttrGroups() EQ 1>

						<cfscript>
							var FirstParentId = GetSettings.First_Parent_Id;

							var obj = CreateObject("component","components.products.Group.ProductGroupAttributeManager");
							var qGroupsInTemplate = obj.getProductGroupAttributesGroupTemplate(active = 1, FirstParentID = FirstParentId, TemplateFiltersID = 0);
						</cfscript>
						<cfif isDefined("qGroupsInTemplate")>
							<cfset sJoin = '' />
						 	 <cfset q = qGroupsInTemplate/>
							<cfloop query="qGroupsInTemplate">
								<cfscript>
									if(qGroupsInTemplate.PG_FLAG == 0 && qGroupsInTemplate.ALLOW_IN_GROUP_SEARCH == 1){
										 sJoin = ' #sJoin#
										 			AND GRPIM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD#  =  IM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# AND
										 			IM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# IS NOT NULL ';
									}
								</cfscript>
							</cfloop>
					   </cfif>
					   <!--- Set Pricing_Level_Id = 2 If a Group record exists with a Non zero rate for this item. --->
						<cfquery name="updRebateProductsPricingLevel" datasource="#application.datasource#">
							UPDATE CP
							SET Pricing_Level_Id = 2
							--SELECT *
							FROM Program_Rebates_Product_Data PRPD
							INNER JOIN Program_Rebates_Component_Data PRCD ON
								PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
							INNER JOIN Contract_Products CP ON
								Contract_Main_ID = <cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
								Product_Type_ID =  <cfqueryparam value="2" cfsqltype="cf_sql_integer" /> AND
								CP.Is_Group = 0 AND
								CP.Captured_From_Group = 0 AND
								PRPD.Contract_Products_ID = CP.Contract_Products_ID
							INNER JOIN BSA_Foodservice_Items_Master IM ON
								CP.BSA_Foodservice_Items_Master_ID = IM.BSA_Foodservice_Items_Master_ID
							INNER JOIN BSA_Foodservice_Items_Master GRPIM ON
								GRPIM.Is_Item_Group = 1 #sJoin#
							INNER JOIN Contract_Products CPGRP ON
								CPGRP.Contract_Main_ID =	<cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" /> AND
								CPGRP.Product_Type_ID = 	2 AND
								CPGRP.Is_Group = 1 AND
								CPGRP.Captured_From_Group = 0 AND
								CPGRP.BSA_Foodservice_Items_Master_ID = GRPIM.BSA_Foodservice_Items_Master_ID
							INNER JOIN Program_Rebates_Product_Data GRPPRPD ON
								GRPPRPD.Contract_Products_ID = CPGRP.Contract_Products_ID
								AND GRPPRPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
							INNER JOIN Program_Rebates_Component_Data GRPPRCD ON
								GRPPRCD.Program_Rebates_Product_Data_ID = GRPPRPD.Program_Rebates_Product_Data_ID AND
								GRPPRCD.Rate != <cfqueryparam value="0.0000" cfsqltype="cf_sql_decimal" /> AND
								GRPPRCD.Program_Rebates_Component_ID = <cfqueryparam value="#nRebateCompID#" cfsqltype="cf_sql_integer" />
							WHERE PRPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
							     AND PRCD.Program_Rebates_Component_ID = <cfqueryparam value="#nRebateCompID#" cfsqltype="cf_sql_integer" />
								 AND CP.Pricing_Level_Id = 1
						</cfquery>

						<!--- COMMENTED OUT -- we ONLY add NON zero (this was for 0 rate exceptions but MultiAttrGroups is not adding 0 rate exceptions)
							<cfquery name="delRebateContractProductsNoRate" datasource="#application.datasource#">
							UPDATE CP
							SET DELETED = 1
							--WHERE Contract_Products_ID IN(
							--SELECT CP.Contract_Products_ID
							FROM Program_Rebates_Product_Data PRPD
							INNER JOIN Program_Rebates_Component_Data PRCD ON
							PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
							INNER JOIN Contract_Products CP ON
								Contract_Main_ID =	<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
								Product_Type_ID = 	<cfqueryparam value="2" cfsqltype="cf_sql_integer" /> AND
								CP.Captured_From_Group = 0 AND
								PRPD.Contract_Products_ID = CP.Contract_Products_ID
							WHERE PRPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#nProgramID#" />
							     AND PRCD.Program_Rebates_Component_ID = <cfqueryparam value="#nRebateCompID#" cfsqltype="cf_sql_integer" />
								 AND PRCD.Rate = CAST(0 AS decimal(12,4))
								 AND CP.Pricing_Level_Id = 1
								 AND CP.Deleted = 0
								 AND PRPD.Deleted = 0
								 AND PRCD.Deleted = 0
								 -- Do Not Delete CP records where the same item is on another component at a different Peicing_Level Or with A non zero rate
									AND CP.Contract_Products_ID NOT IN(SELECT CP_NOT.Contract_Products_ID FROM Program_Rebates_Product_Data PRPD_Not
									 												INNER JOIN Contract_Products CP_NOT ON
									 													PRPD_Not.Contract_Products_ID = CP_NOT.Contract_Products_ID
									 												INNER JOIN Program_Rebates_Component_Data PRCD_Not ON
																						PRCD_Not.Program_Rebates_Product_Data_ID = PRPD_Not.Program_Rebates_Product_Data_ID
									 											WHERE PRPD_Not.Program_ID = #nProgramID#
																				     AND PRCD_Not.Program_Rebates_Component_ID != <cfqueryparam value="#nRebateCompID#" cfsqltype="cf_sql_integer" />
																					AND
																					(
																						(
																							PRCD_Not.Rate != CAST(0 AS decimal(12,4))
																						 )
																						 OR
																						 (CP_NOT.Pricing_Level_Id = 2)
																					  )
																					 AND PRPD_Not.Deleted = 0
																					 AND PRCD_Not.Deleted = 0
																					 AND CP_NOT.Deleted = 0)
						</cfquery>
						<!---<cfset this.dmp(delRebateContractProductsNoRate) />--->
						<cfquery name="delRebateProductsNoRate" datasource="#application.datasource#">
							UPDATE PRPD
							SET DELETED = 1
							--SELECT *
							FROM Program_Rebates_Product_Data PRPD
							INNER JOIN Program_Rebates_Component_Data PRCD ON
							PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
							INNER JOIN Contract_Products CP ON
								Contract_Main_ID =	<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
								Product_Type_ID = 	<cfqueryparam value="2" cfsqltype="cf_sql_integer" /> AND
								CP.Captured_From_Group = 0 AND
								PRPD.Contract_Products_ID = CP.Contract_Products_ID
							WHERE
								PRCD.Program_Rebates_Component_ID = <cfqueryparam value="#nRebateCompID#" cfsqltype="cf_sql_integer" /> AND
								PRPD.Program_ID = <cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
								CAST(PRCD.Rate as Decimal(12,4))  = 0 AND
								CP.Pricing_Level_Id = 1 AND
								CP.Deleted = 1


							UPDATE PRCD
							SET DELETED = 1
							--SELECT *
							FROM Program_Rebates_Product_Data PRPD
							INNER JOIN Program_Rebates_Component_Data PRCD ON
							PRCD.Program_Rebates_Product_Data_ID = PRPD.Program_Rebates_Product_Data_ID
							INNER JOIN Contract_Products CP ON
								Contract_Main_ID =	<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
								Product_Type_ID = 	<cfqueryparam value="2" cfsqltype="cf_sql_integer" /> AND
								CP.Captured_From_Group = 0 AND
								PRPD.Contract_Products_ID = CP.Contract_Products_ID
							WHERE
								PRCD.Program_Rebates_Component_ID = <cfqueryparam value="#nRebateCompID#" cfsqltype="cf_sql_integer" /> AND
								PRPD.Program_ID = <cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" /> AND
								CAST(PRCD.Rate as Decimal(12,4)) = 0 AND
								CP.Pricing_Level_Id = 1 AND
								CP.Deleted = 1
						</cfquery>
						--->
					</cfif>
					<!--- done --->
				</cfif>
			</cfloop>

			<!--- adjust Program_Rebates_Component_Data table for any missed component/product combinations --->
			<cfquery name="qAdjustCompProd" datasource="#application.datasource#">
				INSERT INTO Program_Rebates_Component_Data
					(Program_Rebates_Component_ID, Program_Rebates_Product_Data_ID, Rate, Unit_Of_Measure_ID, Is_Group)
				SELECT	Program_Rebates_Component.Program_Rebates_Component_ID, Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID, 0 as Rate, 1 as Unit_Of_Measure_ID, Program_Rebates_Product_Data.Is_Group
				FROM	Program_Rebates_Product_Data
						INNER JOIN Program_Rebates_Component ON
						Program_Rebates_Product_Data.Program_ID = Program_Rebates_Component.Program_ID
						LEFT JOIN Program_Rebates_Component_Data  ON
						Program_Rebates_Component_Data.Program_Rebates_Component_ID = Program_Rebates_Component.Program_Rebates_Component_ID AND
						Program_Rebates_Component_Data.Program_Rebates_Product_Data_ID = Program_Rebates_Product_Data.Program_Rebates_Product_Data_ID
				WHERE 	Program_Rebates_Component.Program_ID = <cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />
				AND		Program_Rebates_Component_Data.Program_Rebates_Component_ID IS NULL
				AND		Program_Rebates_Product_Data.Deleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
				AND		Program_Rebates_Component.Deleted = <cfqueryparam value="0" cfsqltype="cf_sql_bit" />
			</cfquery>
			<!---:: END :: Now cleanup 0 rate Items :: END :: --->



	<!--- D30253 : Rebate Grid dropping strategy code from 2200 START--->
	<cfset program_fixed_component_name_id_list = StructKeyList(program_fixed_component_name_id_list)>
	<cfset IsFreightTemplate = CreateObject("component", "components.programs.programManager").GetIsProgramFreightOn(nProgramID)>
	<cfif IsFreightTemplate eq 1>
			<cfset ProgramFreight = CreateObject("component", "components.freight.ProgramFreight") />
    	<cfscript>
			ProgramFreight.Freight(
								Program_ID								= 	#nProgramID#,
								program_fixed_component_name_id_list 	= 	#program_fixed_component_name_id_list#
			);
		</cfscript>
	</cfif>
	<!--- D30253 : Rebate Grid dropping strategy code from 2200 END--->
			<!--- now insert volume --->
				<cfquery name="qRemoveVolume" datasource="#application.datasource#">
					UPDATE	Program_Product_Volume
					SET		Deleted = 1
					WHERE	Program_ID = #nProgramID#
					AND		Deleted = 0
					AND 	BSA_Foodservice_Items_Master_ID NOT IN(SELECT BSA_Foodservice_Items_Master_ID
																	FROM Contract_Products
																	Where Contract_Main_ID = #nProgramID#
																	AND Deleted = 0)
				</cfquery>
				<cfloop list="#StructKeyList(stVolume)#" index="i">
					<cfset thisVol = replace(trim(stVolume["#i#"]["volume"]), ",", "", 'ALL') />
				<!--- if it exists then update otherwise insert --->
				<cfquery name="qCheckVolume" datasource="#application.datasource#">
					SELECT	Program_Product_Volume_ID,
							ISNULL(I.Is_Item_Group,0) AS Is_Item_Group,
							I.Net_Weight
					FROM	BSA_Foodservice_Items_Master I
					LEFT JOIN  Program_Product_Volume V ON
					 	I.BSA_Foodservice_Items_Master_ID = V.BSA_Foodservice_Items_Master_ID
					 	AND		V.Program_ID = #nProgramID#
					 	AND V.deleted = 0
					WHERE	I.BSA_Foodservice_Items_Master_ID = '#i#'
				</cfquery>
				<cfif Contract_Quantity_UOM_IDX EQ 1>
					<cfset nWeeklyCs = (thisVol * 7.00) / nProgramSpan />
				<cfelse>
					<cfset nWeeklyCs = (thisVol / qCheckVolume.Net_Weight * 7.00) / nProgramSpan />
				</cfif>

				<!---<cfset nWeeklyCs = (stVolume["#i#"]["volume"] * 7.00) / nProgramSpan />--->
				<cfset nWeeklyCs = TRIM(nWeeklyCs) />
				<cfif NOT isNumeric(nWeeklyCs)>
					<cfset nWeeklyCs = (1 * 7.00) / nProgramSpan />
				</cfif>

				<cfif qCheckVolume.Program_Product_Volume_ID NEQ ''>
					<cfquery name="qUpdateVolume" datasource="#application.datasource#">
						UPDATE	Program_Product_Volume
						SET		Volume_CS = <cfqueryparam value="#trim(nWeeklyCs)#" cfsqltype="CF_SQL_FLOAT" />,
								Volume_Cap_UOM = #Contract_Quantity_UOM_IDX#
						WHERE	BSA_Foodservice_Items_Master_ID = '#i#'
						AND		Program_ID = #nProgramID#
						AND		Deleted = 0
					</cfquery>
				<cfelse>
					<cfquery name="qInsertVol" datasource="#application.datasource#">
						INSERT INTO	Program_Product_Volume
							(BSA_Foodservice_Items_Master_ID, Program_ID, Volume_CS, Is_Group, Volume_Cap_UOM)
						VALUES
							('#i#', #nProgramID#,  <cfqueryparam value="#nWeeklyCs#" cfsqltype="CF_SQL_FLOAT" />,#qCheckVolume.Is_Item_Group# ,#Contract_Quantity_UOM_IDX#)
					</cfquery>
				</cfif>

			</cfloop>

			<cfquery name="qUpdateVolumeLB" datasource="#application.datasource#">
				UPDATE	Program_Product_Volume
				SET		Volume_LB = Program_Product_Volume.Volume_CS * ISNULL(BSA_Foodservice_Items_Master.Net_Weight,1)
				FROM	Program_Product_Volume
						INNER JOIN BSA_Foodservice_Items_Master ON BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = Program_Product_Volume.BSA_Foodservice_Items_Master_ID
				WHERE	Program_Product_Volume.Program_ID = #nProgramID#
				AND		Program_Product_Volume.Deleted = 0
				<cfif this.getTemplateMultiPrdAttrGroups() EQ FALSE>
					AND		Program_Product_Volume.Is_Group = 0
				</cfif>
			</cfquery>

			<!--- now get the sum of the program volume and update contract_main --->
			<cfquery name="qGetVolumeSum" datasource="#application.datasource#">
				SELECT	CASE
							WHEN Contract_Main.Contract_Quantity_UOM_IDX = 1 THEN SUM(ISNULL(CAST(Program_Product_Volume.Volume_CS AS FLOAT), 0))
							ELSE SUM(ISNULL(CAST(Program_Product_Volume.Volume_LB AS FLOAT), 0))
						END AS Program_Volume
				FROM 	Contract_Main
						INNER JOIN Program_Product_Volume ON
						Program_Product_Volume.Program_ID = Contract_Main.Contract_Main_ID AND
						Program_Product_Volume.Deleted = 0
							AND Program_Product_Volume.Is_Group = 0
				WHERE 	Contract_Main_ID = <cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />
				GROUP BY  Contract_Main.Contract_Quantity_UOM_IDX
			</cfquery>

			<!--- update contract_main --->
			<CFSTOREDPROC PROCEDURE="Update_Contract_Quantity" datasource="#application.datasource#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Contract_Main_ID"		VALUE="#nProgramID#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER "	DBVARNAME="@Verify_Product_Volume"	VALUE="0">
			</CFSTOREDPROC>
	<!---D42322 ::  Programs cannot be submitted for approval
		Added CFELSE to below IF section
		--->
			<cfif bIsGroupProgramFlag AND getSettings.Custom_Fixed_Price_Options EQ 0>
                <cfquery name="bIsGroupProgramFlag" datasource="#application.datasource#">
                  UPDATE      Contract_Main
                  SET         Group_Processed = 1
                  WHERE Deleted = 0
                  AND   Contract_Main_ID = #nProgramID#
                </cfquery>
             <cfelseif getSettings.Custom_Fixed_Price_Options EQ 1>
	             <cfquery name="bIsGroupProgramFlag" datasource="#application.datasource#">
                  UPDATE      Contract_Main
                  SET         Group_Processed = 0
                  WHERE Deleted = 0
                  AND   Contract_Main_ID = #nProgramID#
                </cfquery>
			</cfif>
			<cftransaction action = "commit"/>
		</cftransaction>
  		<!---***  MPUP  ***** MARKET PRICE UPDATE market_price   *****   MPUP   ***--->
		<cfscript>
			if(prgTemplate.Market_Price){//if MP make sure the Market Price Rates are up to date
				objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
				objMarketPriceManager.MarketPriceUpdateProcess(nProgramID);
			}
		</cfscript>
		<!--- Auto Apply Volume getSettings.Custom_Fixed_Price_Options--->
		<!---<cfstoredproc procedure="Get_Program_Product_Volume_Forecast" datasource="#application.datasource#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_INTEGER" dbVarName = "@contract_main_id" null="no" value="#URL.Program_ID#">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@mode" null="no" value="EDIT">
			<cfprocparam type = "In" CFSQLType ="CF_SQL_VARCHAR" dbVarName = "@group_by" null="no" value="">

			<cfprocresult name="getProductVolume" resultset="1">
			<cfprocresult name="getForecastId" resultset="2">
		</cfstoredproc>--->

		<cfreturn true />
	</cffunction>

	<cffunction name="getPeriodCount" access="remote" returnformat="JSON" >
    	<cfargument name="startDate" type="date" required="true"/>
   		<cfargument name="EndDate" type="date" required="true"/>
		<cfargument name="paymenCycleId" required="true"/>
		<cfset var qBBAutoPayPeriodCount = '' />
		<!---<cfset arguments.paymenCycleId = JavaCast("int",arguments.paymenCycleId) />--->

	<!---	<cfset this.doCFLog(arguments) />--->
		<!---<cfquery name="qBBAutoPayPeriodCount" datasource="#application.datasource#">
			exec BB_Auto_Pay_Period_Count '#arguments.startDate#','#arguments.EndDate#',#arguments.paymenCycleId#
		</cfquery>--->
		<CFSTOREDPROC PROCEDURE="BB_Auto_Pay_Period_Count" datasource="#application.datasource#">
				<cfprocresult name = qBBAutoPayPeriodCount>
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_DATE"		DBVARNAME="@Contract_Start_Date" VALUE="#arguments.startDate#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_DATE "	DBVARNAME="@Contract_End_Date"	 VALUE="#arguments.EndDate#">
				<CFPROCPARAM TYPE="In" 	CFSQLTYPE="CF_SQL_INTEGER"	DBVARNAME="@Payment_Cycle_ID"	 VALUE="#arguments.paymenCycleId#">
		</CFSTOREDPROC>
		<cfreturn SerializeJSON(qBBAutoPayPeriodCount.PAYPERIODCOUNT) />
	</cffunction>

	<cffunction name="programWonLossEligible" access="remote" returntype="boolean" >
    	<cfargument name="contractMainId" type="numeric" required="true" default="0"/>

		<cfscript>
			/*  */
			objProgramTemplateManager	= CreateObject("component","components.programs.Display_Program.viewprogramtemplateManager");
			getSettings = objProgramTemplateManager.getSettings(contractMainId);
			if( application.appSettingsGet.getTemplateMultipleProductAttrGroups() == 1 && getSettings.Custom_Fixed_Price_Options == 1){
				if(this.getUnConvertedCount(contractMainId) > 0){
					return  false;
				}

			}
			//if conditions not met fall through to true
			return true;

		</cfscript>
		<cfreturn true />
	</cffunction>

	<cffunction name="getUnConvertedCount" access="package" returntype="Numeric" >
    	<cfargument name="contractMainId" type="numeric" required="true" default="0"/>
		<cfscript>

		</cfscript>
		<cfquery name="qGetData" datasource="#application.datasource#">
			SELECT Q.Q_Brand
			FROM	Program_Fixed_Price_Product_Data FPPD
			INNER JOIN Program_Fixed_Component PFC ON
					PFC.Program_Fixed_Component_ID = FPPD.Program_Fixed_Component_ID
			INNER JOIN Program_Fixed_Component_Name FCN ON
					FCN.Program_Fixed_Component_Name_ID = PFC.Program_Fixed_Component_Name_ID
			INNER JOIN Contract_Products CP ON
					CP.Contract_Products_ID = FPPD.Contract_Products_ID AND
					CP.Contract_Main_ID = FPPD.Program_ID
			INNER JOIN BSA_Foodservice_Items_Master BSAFIM ON
					BSAFIM.BSA_Foodservice_Items_Master_ID = CP.BSA_Foodservice_Items_Master_ID
			INNER JOIN Q_Brand_Desc Q ON
				Q.Q_Brand_ID = BSAFIM.Q_Brand_ID
			WHERE	FPPD.Program_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.contractMainId#">
			AND		FPPD.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		PFC.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Deleted = <cfqueryparam cfsqltype="cf_sql_bit" value="0">
			AND		CP.Product_Type_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
			AND		CP.Captured_From_Group = 0
			AND 	BSAFIM.is_Item_Group = 1
			AND		Q.Q_Brand = 'NONE'
		</cfquery>
		<cfreturn qGetData.RecordCount />
	</cffunction>

	<cffunction name="doCFLog">
    	<cfargument name="x"  required="true"/>
   		<cfdump var="#x#" output="c:\dump.log" >
	</cffunction>
</cfcomponent>