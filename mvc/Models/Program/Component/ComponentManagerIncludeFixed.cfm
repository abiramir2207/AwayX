<!--- Tim Ford - 01/25/2016: WR 56932 - VOLUME OVERRRIDE LOGIC - CURRENT DESIGN AFFECTS PRODUCTIVITY
Retain the selected value for Dont_Count_Volume from Program_Fixed_Component
--->
<cfset bFixRateCount = 0 />

<CFQUERY NAME="qGetFixedVolOverrideTemp" dbtype="query">
	SELECT	Dont_Count_Volume
	FROM	qGetFixedVolumeOverrideSelection
	WHERE	Program_Fixed_Component_Name_ID = #indx.componentId#
</CFQUERY>
<cfif qGetFixedVolOverrideTemp.RecordCount>
	<cfset bFixRateCount = qGetFixedVolOverrideTemp.Dont_Count_Volume />
</cfif>

<cfquery name="qInsertFixedComponent" datasource="#application.datasource#">
	SET NOCOUNT ON
	INSERT INTO Program_Fixed_Component
	(
		Program_Fixed_Component_Name_ID,
		Fixed_Component_Paid_To,
		Program_ID,
		Claim_Mechanics,
		GL_Account_ID,
		Vendor_Master_ID,
		Payee_Type,
		Vendor_Selection,
		Dont_Count_Volume
	)
	VALUES
	(
		<cfqueryparam value="#indx.componentId#" cfsqltype="cf_sql_integer" />,
		<cfqueryparam value="#indx.paidTo.paidToId#" cfsqltype="cf_sql_varchar" />,
		<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />,
		<cfqueryparam value="#indx.claimMechanic.claimMechanicId#" cfsqltype="cf_sql_integer" />,
		<cfqueryparam value="#glAccountId#" cfsqltype="cf_sql_integer" null="#len(glAccountId) eq 0#"/>,
		<cfqueryparam value="#payeeId#" cfsqltype="cf_sql_varchar" null="#len(payeeId) eq 0#" />,
		<cfqueryparam value="#payeeTypeId#" cfsqltype="cf_sql_integer" null="#len(payeeTypeId) eq 0#" />,
		<cfqueryparam value="#vendorSelection#" cfsqltype="cf_sql_integer" />,
		<cfqueryparam value="#bFixRateCount#" cfsqltype="CF_SQL_BIT" />
	)
	SELECT Program_Fixed_Component_ID = @@IDENTITY
	SET NOCOUNT OFF
</cfquery>
<!--- D30253 : Rebate Grid dropping strategy code from 2200 START--->
					<cfset StructInsert(program_fixed_component_name_id_list, "#indx.componentId#", "", "true")>
					<!--- D30253 : Rebate Grid dropping strategy code from 2200 END--->
					<!--- set the fixed component id --->
					<cfset nFixedCompID = qInsertFixedComponent.Program_Fixed_Component_ID />
					<!--- save payment cycle data --->
					<cfset objPaymentCycleManager.savePaymentCycle(nProgramID, 1, indx.paymentCycle.paymentCycleId, nFixedCompID) />
					<!--- set the fixed prod rate array   AND ISArray(indx.prodRate) --->
					<cfset arrFixedProdRateData = indx.prodRate />
					<!--- loop over the fixed prod rate array --->
					<cfloop index="indx2" array="#arrFixedProdRateData#">
						<cfset bHasCustRate = false />
						<cfif (indx2.rate EQ 0 OR indx2.rate EQ '' OR Isnumeric(indx2.rate) EQ false OR val(indx2.rate) eq 0) AND indx.fixedType EQ 3 >
							<cfoutput query="qGetDistributors" >
								<cfset sVar = "rateCust_" & qGetDistributors.Shr_Ship_To />
								<cfif structKeyExists(indx2,sVar) AND Isnumeric(indx2[sVar]) AND indx2[sVar] GT 0>
									<cfset indx2.rate = 0 />
									<cfset bHasCustRate = true />
								</cfif>
							</cfoutput>
						</cfif>

						<cfif indx2.rate NEQ 0 OR bHasCustRate eq true>
							<cfset bIsGroup = 0 />
							<cfset nRateMP = 0 />
							<!---only add items with a rate (0 rate means remove)--->

							<cfset indx2.rate = replace(indx2.rate,',','','ALL')>

							<cfif isNumeric(indx2.rate) AND (indx2.rate GT 0 OR bHasCustRate EQ true) >  <!---  OR this.getTemplateMultiPrdAttrGroups() EQ 1 --->
								<!--- get the Contract_Product_ID from the stFixedContractProd struct if the item has already been inserted into Contract_Products --->

								<cfif structKeyExists(stFixedContractProd,indx2.itemGuid)>
									<cfset nFixedContractProdID = stFixedContractProd["#indx2.itemGuid#"] />
									<cfset bIsGroup = stFixedIsGroup["#indx2.itemGuid#"] />
								<!--- otherwise insert into Contract_Products if the item hasn't already been inserted  --->
								<cfelse>
									<cfquery name="qAddFixedContractproducts" datasource="#application.datasource#" result="qAdd">
										SELECT ISNULL(Contract_Products_ID,0) AS Contract_Products_ID, IM.Is_Item_Group
										FROM BSA_Foodservice_Items_Master IM
										LEFT JOIN Contract_Products CP
										ON CP.BSA_Foodservice_Items_Master_ID = IM.BSA_Foodservice_Items_Master_ID
										AND Contract_Main_ID =	<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />
										AND Product_Type_ID = 	1
										AND CP.Deleted = 0
										WHERE	IM.BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#indx2.itemGuid#" cfsqltype="cf_sql_varchar" />
									</cfquery>
									<cfif qAddFixedContractproducts.Is_Item_Group EQ 1>
										<cfset bIsGroup = 1 />
										<cfset bIsGroupProgramFlag = 1/>
									</cfif>
									<cfif qAddFixedContractproducts.Contract_Products_ID eq 0>
										<cfquery name="qAddFixedContractproducts" datasource="#application.datasource#" result="qAdd">
											SET NOCOUNT ON
											INSERT INTO Contract_Products
												(	BSA_Foodservice_Items_Master_ID,
													Contract_Main_ID,
													Product_Type_ID,
													Is_Group,
													Pricing_Level_ID
													<cfif bIsGroup>
														,Product_Group_Id
													</cfif>
												)
											VALUES
												(
													<cfqueryparam value="#indx2.itemGuid#" cfsqltype="cf_sql_varchar" />,
													<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />,
													<cfqueryparam value="1" cfsqltype="cf_sql_integer" />,
													<cfqueryparam value="#bIsGroup#" cfsqltype="cf_sql_bit" />,
													1
													<cfif bIsGroup>
														,<cfqueryparam value="#indx2.itemGuid#" cfsqltype="cf_sql_varchar" />
													</cfif>
												)
											SELECT Contract_Products_ID = @@IDENTITY
											SET NOCOUNT OFF
										</cfquery>
									</CFIF>
									<!--- set the Contract_Product_Id --->
									<cfset nFixedContractProdID = qAddFixedContractproducts.Contract_Products_ID />
									<!--- now stuff the Contract_Product_ID into the stFixedContractProd struct using the Item Master ID as the struct key --->
									<cfset stFixedContractProd["#indx2.itemGuid#"] = nFixedContractProdID />
									<cfset stFixedIsGroup["#indx2.itemGuid#"] = bIsGroup />

								</cfif>
								<!--- insert into the Program_Fixed_Price_Product_Data table --->
								<cfif IsNumeric(indx2.rateMP) EQ False OR indx2.rateMP LT 0>
										<cfset indx2.rateMP = 0 />
								</cfif>

								<!--- save the Market Price based on the UOM selected for the fixed price --->
								<cfset nRateMP = 0 />
								<cfif isDefined("indx2.rateMPCS") >
									<cfif indx2.uom.uomId eq 2>
										<cfset nRateMP = val(indx2.rateMPLB) />
									<cfelse>
										<cfset nRateMP = val(indx2.rateMPCS) />
									</cfif>
									<cfif IsNumeric(nRateMP) EQ False OR nRateMP LT 0>
											<cfset nRateMP = 0 />
									</cfif>
								</cfif>
								<cfset nRateMPOrig = 0 />
								<cfif indx2.rateMPOrig NEQ '' AND isNumeric(indx2.rateMPOrig) AND val(indx2.rateMPOrig) GT 0 >
										<cfset nRateMPOrig = indx2.rateMPOrig />
								</cfif>

								<!--- FIND THE INTEGER THAT IS JACKED
									UNCOMMENT LINE 659--->
								<cfquery name="qAddFixedProductData" datasource="#application.datasource#">
									INSERT INTO Program_Fixed_Price_Product_Data
										(	Program_ID,
											Contract_Products_ID,
											Fixed_Price_Value,
											Market_Price_Rate,
											Market_Price_Rate_Orig,
											Unit_Of_Measure_ID,
											Program_Fixed_Component_ID,
											Is_Group)
									VALUES
										(
											<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#nFixedContractProdID#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#indx2.rate#" cfsqltype="cf_sql_decimal" scale="4" />,
											<cfqueryparam value="#nRateMP#" cfsqltype="cf_sql_decimal" scale="4" />,
											<cfqueryparam value="#nRateMPOrig#" cfsqltype="cf_sql_decimal" scale="4" />,
											<cfqueryparam value="#indx2.uom.uomId#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#nFixedCompID#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#bIsGroup#" cfsqltype="cf_sql_bit" />
										)
								</cfquery>

								<cfif isDefined("indx2.customPrint.bCustomPrint") AND indx2.customPrint.bCustomPrint
                                        AND isDefined("indx2.customPrint.bDigital")
                                        AND isDefined("indx2.customPrint.sGraphics")
                                        AND isDefined("indx2.customPrint.iColors")>
									<cfquery datasource="#application.datasource#">
										INSERT INTO Print_Program_Custom_Options
										(
											Contract_Main_Id,
											Contract_Products_ID,
											Digital,
											Graphics,
											Colors
										)
										VALUES
										(
											<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#nFixedContractProdID#" cfsqltype="cf_sql_integer" />,
											<cfqueryparam value="#indx2.customPrint.bDigital#" cfsqltype="cf_sql_bit" />,
											<cfqueryparam value="#indx2.customPrint.sGraphics#" cfsqltype="cf_sql_varchar" />,
											<cfqueryparam value="#indx2.customPrint.iColors#" cfsqltype="cf_sql_integer" />
										)
									</cfquery>
								</cfif>

								<cfif this.getTemplateMultiPrdAttrGroups() EQ 1 AND  indx.fixedType EQ 3> <!--- Fixed_Component_Type = 3 is for Customer level rates --->
									<!--- FIX BRANCH TARGET OFFSET ERROR BECUSE FUNCTION IS TOO BIG --->

									<cfinclude template="ComponentManagerInclude.cfm" >
									<!---<cfoutput query="qGetDistributors" >
										<cfset sVar = "indx2.rateCust_" & qGetDistributors.Shr_Ship_To />
										<!---<cfset this.dmp(sVar) />--->

										<cfif isDefined(sVar) AND ISNUMERIC(indx2["rateCust_" & qGetDistributors.Shr_Ship_To]) AND indx2["rateCust_" & qGetDistributors.Shr_Ship_To] GT 0 >
											<!---<cfset this.dmp(indx2["rateCust_" & qGetDistributors.Shr_Ship_To]) />--->
											<!---<cfset this.dmp(indx2["rateCust_" & qGetDistributors.Shr_Ship_To]) />  AND indx2["rateCust_" & qGetDistributors.Shr_Ship_To] GT 0--->
											<!---<cfquery name="qAddFixedFreightData#qGetDistributors.Shr_Ship_To#" datasource="#application.datasource#">
												INSERT INTO Program_Fixed_Freight_Rates
													(	Product_id,
														Customer_id,
														Program_id,
														Component_Name_Id,
														Delivered_Price,
														--Freight_Rate,
														--FOB_Price,
														--Freight_UOM,
														Deleted
														--Paid_To
														)
												VALUES
													(
														<cfqueryparam value="#indx2.itemGuid#" cfsqltype="cf_sql_varchar" />,
														<cfqueryparam value="#qGetDistributors.BSA_Foodservice_Customers_ID#" />,
														<cfqueryparam value="#nProgramID#" cfsqltype="cf_sql_integer" />,
														<cfqueryparam value="##indx.componentId##" cfsqltype="cf_sql_integer" />,
														<cfqueryparam value="#indx2["rateCust_" & qGetDistributors.Shr_Ship_To]#" cfsqltype="cf_sql_decimal" scale="4" />,
														<cfqueryparam value="0" cfsqltype="cf_sql_bit" />
														<!--- ,<cfqueryparam value="#indx2.uom.uomId#" cfsqltype="cf_sql_integer" />,
														<cfqueryparam value="#nFixedCompID#" cfsqltype="cf_sql_integer" />,
														<cfqueryparam value="#bIsGroup#" cfsqltype="cf_sql_bit" />--->
													)
											</cfquery>--->
										</cfif>
									</cfoutput>--->
								</cfif>

								<!---inset volume into the volume struct --->
								<!---<cfset structInsert(stVolume, indx2.itemGuid, indx2.volume, true) />--->
								<cfscript>
									//MAy be needed for UOM HANDLING. Not implementred yet
									stData = structNew();
									stData["uomId"] = indx2.uom.uomId;
									stData["volume"] = indx2.volume;
									//stData["x"] = x;
								</cfscript>

								<!---inset volume into the volume struct --->
								<cfset structInsert(stVolume, indx2.itemGuid, duplicate(stData), true) />
							</cfif>
						</cfif>
					</cfloop>
