

<cfcomponent name="ItemSearchService_Groups" displayname="ItemSearchService_Groups" hint="Search Products" extends="mvc.Models.SettingsService">
	<cfset appSettings = application.appSettingsGet />

	
	<cffunction name="getAllItemsJSON" access="remote" output="false" returnformat="JSON">
		<cfargument name="ProgramId" default="0">
		<cfargument name="StatusFilterOn" default ="1">
		<cfargument name="bAll" default = "true">
		<cfargument name="bMP" default = "false">
		<cfargument name="TemplateFiltersID" default = "0">
		
		<cfscript>
			var jsonData = '';
			jsonData = serializeJSON(
									getCompItems(ProgramId=arguments.ProgramId,StatusFilterOn=arguments.StatusFilterOn,bAll=arguments.bAll
									,bMP=arguments.bMP,TemplateFiltersID=arguments.TemplateFiltersID)
									);
		</cfscript>

		<cfreturn jsonData/>	
	</cffunction>

	<cffunction name="getCustomPrintItemsJSON" access="remote" output="false" returnformat="JSON">
		<cfargument name="ProgramId" default="0">
		<cfargument name="StatusFilterOn" default ="1">
		<cfargument name="bAll" default = "true">
		<cfargument name="bMP" default = "false">
		<cfargument name="TemplateFiltersID" default = "0">
		<cfargument name="customPrint">
		<cfargument name="aItems" type="array" default = "#ArrayNew(1)#">

		<cfscript>
			var jsonData = '';
			arguments.customPrint = DeserializeJSON(arguments.customPrint);
			jsonData = serializeJSON(
									getCompItems(ProgramId=arguments.ProgramId,StatusFilterOn=arguments.StatusFilterOn
									,bAll=arguments.bAll,bMP=arguments.bMP,TemplateFiltersID=arguments.TemplateFiltersID
									,customPrint=arguments.customPrint,aItems=arguments.aItems)
									);
		</cfscript>

		<cfreturn jsonData/>	
	</cffunction>
	
	<cffunction name="getCompItems" hint="return all products" access="remote" output="false" returntype="Array">
		<cfargument name="ProgramId" default="0">
		<cfargument name="DiscountTypeId" default="0">
    	<cfargument name="StatusFilterOn" default ="1">
    	<cfargument name="bAll" default = "true">
    	<cfargument name="bMP" default = "false">
		<cfargument name="TemplateFiltersID" default = "0">
		<cfargument name="customPrint" default = "#CreateObject("component","mvc.Models.Program.Component.vos.CustomPrint")#">
		<cfargument name="aItems" type="array" default = "#ArrayNew(1)#">

		
    	<cfscript>
			var arrRet = ArrayNew(1);
			var qGetItems =  queryNew('tmp');
			var busSegIdForProgram = 0;
			var FirstParentId = 0;
			var varTemplateFiltersID = 0;
			var stUomData = structNew();
			var businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager");
			var objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
			var iMPId = objMarketPriceManager.getProgramActiveMPList(arguments.ProgramId);
			var s = '';
			var sJoin = '';
			var sGroupSQL= '';
			var sGroupJoin= '';
			var sGroupClauseSQL= '';
			var l = '';
			var lGroup = '';
			var bGroups = 1;
			var iProgramSpan = 7;
			var nMultiplier  = iProgramSpan/7;
			// this.dmp(aItems);
			var listCustomItems = '';
			var CUSTOM_PRINT_ATTR = 'Local Print';
			var ezProgramId = 0;
			var priceHeaderListID = 0;
			for (i=1;i LTE ArrayLen(aItems);i=i+1) {
				listCustomItems = listappend(listCustomItems,aItems[i]['itemGuid'],',');
			}
			appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
			arguments.StatusFilterOn = appSettings.getSearchInactiveProductsInPrograms();
		// this.dmp(objMarketPriceManager.getProgramActiveMPList(arguments.ProgramId));
		</cfscript>
		<cfif not IsDefined("Get_Profile_Settings")>
		  <cfinclude template="/get_access_profile.cfm">
		</cfif>
		<cfif bMp>
			<cfquery name="GetSettings" datasource="#application.datasource#">
				SELECT PCPO.*
				FROM Template_Filters TF
				INNER JOIN Program_Control_Panel_Options PCPO ON
					PCPO.First_Parent_ID = TF.Parent_Template_Id
				WHERE TF.Template_Filters_Id = (SELECT MP.Template_Filters_Id
												FROM Market_Price_List MP
												WHERE MP.Market_Price_List_Id = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">)  AND
					TF.Deleted = 0 AND
					PCPO.Deleted = 0	
					AND IsDominant = 1 
			</cfquery>
		<cfelse>
			<cfquery name="GetSettings" datasource="#application.datasource#">
				SELECT PCPO.Discount_Rebates_Group_Level,PCPO.Group_Deal,PCPO.Custom_Fixed_Price_Options,
						exclude_sig_products,modifying_program,EZButton_On,EZ_Contract_Id,First_Parent_Id,
						CM.Template_Filters_Id,DateDiff(dd,CM.Contract_start_date,CM.Contract_End_date)AS contractSpan,
						CMAD.Price_List_ID,
						CMAD.priceBracket_Update,
						PCPO.Margin_Price_List_Header_ID
				FROM Contract_Main CM
				INNER JOIN	Program_Control_Panel_Options PCPO ON 
					CM.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
				INNER JOIN Contract_Main_Aux_Data CMAD
					ON CM.Contract_Main_ID = CMAD.Contract_Main_ID
				WHERE CM.Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cfif>
		
		<cfif appSettings.getPriceListByTemplate() EQ 1 AND iMPId EQ 0 AND GetSettings.recordcount>
			<cfset priceHeaderListID = GetSettings.Margin_Price_List_Header_ID />
		<cfelseif appSettings.getUseFixedPriceType() AND GetSettings.recordcount>
			<cfset priceHeaderListID = GetSettings.Price_List_ID />
		</cfif> 
		
		<cfscript>
			if(GetSettings.recordcount && !bMP){
				iProgramSpan = GetSettings.contractSpan + 1;
				nMultiplier  = iProgramSpan/7;
				FirstParentId = GetSettings.First_Parent_Id;
				varTemplateFiltersID = GetSettings.Template_Filters_Id;
				ezProgramId = GetSettings.EZ_Contract_Id;
				}
			else{
				varTemplateFiltersID = arguments.TemplateFiltersID;
			}
			if(bMP){
				varTemplateFiltersID = objMarketPriceManager.getTemplateFiltersIDBasedOnMP(arguments.ProgramId);
				iMPId = arguments.ProgramId;
				FirstParentId = objMarketPriceManager.getFirstParentId(varTemplateFiltersID);
			}
			var obj = CreateObject("component","components.products.Group.ProductGroupAttributeManager");
			/* Dev Note: 76437 - Exclude "product Hierarchy" - ExcludeGroupLevelType = 2 */
			var qGroupsInTemplate = obj.getProductGroupAttributesGroupTemplate(active = 1, FirstParentID = FirstParentId, TemplateFiltersID = 0, ExcludeGroupLevelType = 2);
		//	this.dmp(qGroupsInTemplate);
		</cfscript>

			<cfif businessSegManager.isEnabled()>
					<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(arguments.programId) />
			</cfif>
			
			<!--- D35295 : Template Filter Setting "Allow In Group Search" Drives Product Groups.  --->
			 <cfif isDefined("qGroupsInTemplate") AND bAll>
			 	 <cfset q = qGroupsInTemplate/>
				  
				<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1 AND (GetSettings.Group_Deal EQ 1 OR bMP EQ 1)>
					<cfset sGroupJoin =  " OR (BSAFIM.Is_Item_Group = 1 
											AND( CP.Contract_Products_ID IS NOT NULL OR BSAFIM.BSA_Foodservice_Items_Master_Id	IN(
													SELECT DISTINCT GRPIM.BSA_Foodservice_Items_Master_ID						 			
													 FROM BSA_Foodservice_Items_Master IM  
												 	INNER JOIN BSA_Foodservice_Items_Master GRPIM ON 1=1  " />
				</cfif>
				
				<cfloop query="q">
					<cfscript>
						//D35295 IF getTemplateMultipleProductAttrGroups() the ALLOW_IN_GROUP_SEARCH determines which attributes are valid in Search Tool as columns and filters.  NO Planning Groups
						if(application.appSettingsGet.getTemplateMultipleProductAttrGroups() == 1 AND (GetSettings.Group_Deal == 1 OR bMP == 1)){
							if(q.PG_FLAG == 0 AND q.ALLOW_IN_GROUP_SEARCH EQ 1){
							 s = " #s# rTrim(lTrim(isNull(#q.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#q.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD#,''))) AS #q.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD#,";
							 sJoin = ' #sJoin# INNER JOIN #q.PRODUCT_GROUP_ATTRIBUTE_TABLE# ON 
							 			#q.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#q.PRODUCT_GROUP_ATTRIBUTE_ID_FIELD# =  BSAFIM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# AND
							 			BSAFIM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# IS NOT NULL ';
							 			
							 	  sGroupJoin = ' #sGroupJoin# 
							 			AND GRPIM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD#  =  IM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# AND
							 			BSAFIM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# IS NOT NULL ';
							 
	
							 l= listappend(l,q.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD);
							 lGroup= listappend(lGroup,q.GROUP_LEVEL_ID);
								 //USED IN GROUP BY CLAUSE
								sGroupClauseSQL = " #sGroupClauseSQL# #q.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#q.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD#,";	 
							}
						}
						// getTemplateMultipleProductAttrGroups() is OFF.  Return all attrs with ALLOW_IN_SEARCH = 1
						else{
							sGroupJoin = '';
							if(q.PG_FLAG == 0 AND q.ALLOW_IN_SEARCH EQ 1){
							 s = " #s# rTrim(lTrim(isNull(#q.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#q.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD#,''))) AS #q.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD#,";
							
							 sJoin = ' #sJoin# INNER JOIN #q.PRODUCT_GROUP_ATTRIBUTE_TABLE# ON 
							 			#q.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#q.PRODUCT_GROUP_ATTRIBUTE_ID_FIELD# =  BSAFIM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# AND
							 			BSAFIM.#q.PRODUCT_GROUP_ATTRIBUTE_MASTER_ID_FIELD# IS NOT NULL ';
							 
							 l= listappend(l,q.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD);
							 lGroup= listappend(lGroup,q.GROUP_LEVEL_ID);
							 //USED IN GROUP BY CLAUSE
						sGroupClauseSQL = " #sGroupClauseSQL# #q.PRODUCT_GROUP_ATTRIBUTE_TABLE#.#q.PRODUCT_GROUP_ATTRIBUTE_NAME_FIELD#,";	 
							}
						}
						
					</cfscript>
				</cfloop>
				
				<!--- Build sql that determines which GROUP records in Item master are valid.  Appsetting getTemplateMultipleProductAttrGroups() IS ON !! --->
				<cfif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1  AND (GetSettings.Group_Deal EQ 1  OR bMP EQ 1) >
					<cfset sGroupJoin = " #sGroupJoin#    WHERE IM.Item Is Not Null AND GRPIM.Is_Item_Group = 1 AND IM.ACTIVE_CODE = 'A'  "/>
					<cfquery name="qGroupLevelNot" datasource="#application.datasource#">
						SELECT PGA.Product_Group_Attribute_Master_ID_Field
						FROM Product_Group_Attribute PGA
						INNER JOIN Product_Group_Level PGL ON 
							PGL.Product_Group_Level_ID = PGA.Product_Group_Level_ID
						WHERE PGA.Product_Group_Level_ID NOT IN (#ListQualify(lGroup,"'",",")#) AND
							PGA.Active = 1 AND
							PGA.Deleted = 0 AND
							PGL.Is_PG = 0
					</cfquery>
					<cfloop query="qGroupLevelNot">
						<cfscript>
								 sGroupSQL = ' #sGroupSQL# AND GRPIM.#qGroupLevelNot.Product_Group_Attribute_Master_ID_Field#  IS NULL ';
						</cfscript>
					</cfloop>
					<cfif GetSettings.Custom_Fixed_Price_Options && GetSettings.Group_Deal>
					<cfset sGroupSQL = " #sGroupSQL# )) OR (BSAFIM.BSA_Foodservice_Items_Master_Id	IN(SELECT BSA_Foodservice_Items_Master_ID
															FROM BSA_Foodservice_Items_Master  where 
															Q_Brand_ID = (SELECT Q_Brand_ID FROM Q_Brand_Desc where Q_Brand = 'NONE') AND 
															Type_Group_desc_Id = (SELECT Type_Group_desc_Id FROM Type_Group_desc where Type_Group_Desc = 'NONE')AND
															Is_Item_Group = 1))) " />
					<cfelse>
					
					<cfset sGroupSQL = ' #sGroupSQL# )) ) ' />
					</cfif>
				</cfif>
				
		   </cfif>
		   <!---END  D35295 : Template Filter Setting "Allow In Group Search" Drives Product Groups.  --->
		   	
		   <cfset arrFields = listToArray(l) />

			 <!---   <cfif not isdefined("session.qGetItems")> --->
				  <CFQUERY NAME="qDeleteTempTables" datasource="#application.datasource#">
				  	  IF OBJECT_ID('tempdb..##TMP_Query_Result') IS NOT NULL
						DROP TABLE ##TMP_Query_Result
					  IF OBJECT_ID('tempdb..##TMP_GM_Price') IS NOT NULL
						DROP TABLE ##TMP_GM_Price
				  </CFQUERY>
				<cfsavecontent variable="sQuery">
					<cfoutput>
						IF OBJECT_ID('tempdb..##TMP_Query_Result') IS NOT NULL
						DROP TABLE ##TMP_Query_Result
						
						 SELECT DISTINCT
						 		BSAFIM.BSA_FoodService_Items_Master_ID AS itemGuid,
						        BSAFIM.Description,
						        ISNULL(BSAFIM.Is_Item_Group,0) as IsGroup,
						 		CASE
						 			WHEN BSAFIM.Is_Item_Group = 1 THEN 'Group'
						 			ELSE BSAFIM.Item
						 			END
						 		AS baItemDisplay,
						 		CASE
						 			WHEN BSAFIM.Is_Item_Group = 1 THEN  
						 					Cast(BSAFIM.BSA_FoodService_Items_Master_ID AS varchar(36))
						 			ELSE  rTrim(lTrim(BSAFIM.Item))
						 			END
						 		 AS baItem,
					        #s#
               					CASE 
									WHEN BSAFIM.Active_code = 'A' OR BSAFIM.Is_Item_Group = 1 THEN 'Active'
									ELSE 'In-Active'
									END
								AS Item_Status,
							ISNULL(CAST(V.Volume_LB AS DECIMAL (9,0)),1) AS Volume,
						<cfif iMPId>
							<cfif GetSettings.Custom_Fixed_Price_Options>
								ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0)) AS Market_Price,
							<cfelse>
								ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate,0)) AS Market_Price,
							 </cfif>
							ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0)) AS Market_Price_Rate_Orig,
							MPR.Uom_Id,
							UOM.Abbreviation_Singular,
							UOM.Unit_of_Measure_Desc_Singular,
							CASE 
								WHEN MPR.Uom_Id = 2 THEN CAST(ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0)) * BSAFIM.Net_Weight AS DECIMAL(18,4))
								ELSE ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0))
							END AS Market_Price_Rate_CS,
							CASE 
								WHEN MPR.Uom_Id = 1 THEN CAST(ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0)) / BSAFIM.Net_Weight AS DECIMAL(18,4))
								ELSE ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0))
							END AS Market_Price_Rate_LB
						<cfelseif (appSettings.getUseFixedPriceType() OR appSettings.getPriceListByTemplate() EQ 1) ><!--- D42975 :: Base_Price from gross_margin --->
							ISNULL(PLD.CS_FOB_Price,0) AS Market_Price,
							ISNULL(PLD.CS_FOB_Price,0) AS Market_Price_Rate_Orig,
							1 AS Uom_Id,
							'CS' AS Abbreviation_Singular,
							'Case' AS Unit_of_Measure_Desc_Singular,
							ISNULL(PLD.CS_FOB_Price,0)  AS Market_Price_Rate_CS,
							ISNULL(cast(PLD.CS_FOB_Price as decimal(16,4)),0)/BSAFIM.Net_Weight AS Market_Price_Rate_LB
						<cfelse>
							<!----- D42975 :: Base_Price from gross_margin
										TODO: seach for todo on this file to find other versions of getting base_Price (list Price or useFixedPrice)  --->
						
						<!--- Price is updated from Gross margin in next query, get default hear --->
						CAST(ISNULL(PLDEF.CS_FOB_Price,0) as decimal(20, 2)) AS Market_Price,
						CAST(ISNULL(PLDEF.CS_FOB_Price,0) as decimal(20, 2)) AS Market_Price_Rate_Orig,
						1 AS Uom_Id,
						'CS' AS Abbreviation_Singular,
						'Case' AS Unit_of_Measure_Desc_Singular,
						CAST(ISNULL(PLDEF.CS_FOB_Price,0) as decimal(20, 2)) AS Market_Price_Rate_CS,
						CAST(ISNULL(PLDEF.CS_FOB_Price,0) as decimal(20, 4)) AS Market_Price_Rate_LB
						
						<!---	0  AS Market_Price,
							0  AS Market_Price_Rate_Orig,
							0  AS Uom_Id,
							'' AS Abbreviation_Singular,
							'' AS Unit_of_Measure_Desc_Singular,
							0  AS Market_Price_Rate_CS,
							0  AS Market_Price_Rate_LB--->
						</cfif>
						<!--- GET CUSTOM PRINT CHARGES 
							If !ball
								Custom_Price Data		
							If !list && !bAll
								Join Contract_products & Item level Print Charge table		
							Else !bAll
								In(list) & arguments.customPrint data
							
							--->
						<cfif NOT bAll AND iMPId>
							<cfif arrayLen(aItems) GT 0 >
								,CAST(ISNULL(PMR.Amount,0) AS DECIMAL(12,2)) AS printMakeReady
								,CAST(ISNULL(PPC.Amount,0) AS DECIMAL(12,2)) AS printPlate
								,CAST(ISNULL(PPP.Amount,0) AS DECIMAL(12,2)) AS printPrePress
								,0	AS printMinPrice
								,#arguments.customPrint.iColors#  AS iColors
								,'#arguments.customPrint.sGraphics#' AS sGraphics
								,<cfif arguments.customPrint.bDigital>
									1
								<cfelse>
									0
								</cfif>
								  AS bDigital
								,CAST(ISNULL(PMR.Amount,0) AS DECIMAL(12,2)) AS printMakeReadyBase
								,CAST(ISNULL(PPC.Amount,0) AS DECIMAL(12,2)) AS printPlateBase
								,CAST(ISNULL(PPP.Amount,0) AS DECIMAL(12,2)) AS printPrePressBase
							<cfelse>
								,CAST(ISNULL(PMR.Amount,0)/( ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2)) AS printMakeReady
								,CAST(ISNULL(PPC.Amount,0) * ISNULL(PPCO.Colors,0)/ (ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2)) AS printPlate
								,CAST(ISNULL(PPP.Amount,0)/( ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2)) AS printPrePress
								,CAST(ISNULL(PMR.Amount,0)/(ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2)) +
									CAST(ISNULL(PPC.Amount,0) * ISNULL(PPCO.Colors,0)/( ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2)) +
									CAST(ISNULL(PPP.Amount,0)/( ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2))+
									CAST(ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0))  AS DECIMAL(12,2))
									AS printMinPrice
								,CAST(ISNULL(PMR.Amount,0)/(ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2)) +
									CAST(ISNULL(PPC.Amount,0) * ISNULL(PPCO.Colors,0)/( ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2)) +
									CAST(ISNULL(PPP.Amount,0)/( ISNULL(V.Volume_LB,1) * #nMultiplier#) AS DECIMAL(12,2))+
									CAST(ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0))  AS DECIMAL(12,2))
									AS printMinPrice_LB
								,CAST(ISNULL(PMR.Amount,0)/(ISNULL(V.Volume_CS,1) * #nMultiplier#) AS DECIMAL(12,2)) +
									CAST(ISNULL(PPC.Amount,0) * ISNULL(PPCO.Colors,0)/( ISNULL(V.Volume_CS,1) * #nMultiplier#) AS DECIMAL(12,2)) +
									CAST(ISNULL(PPP.Amount,0)/( ISNULL(V.Volume_CS,1) * #nMultiplier#) AS DECIMAL(12,2))+
									CAST(ISNULL(MPR.rate,IsNull(FPPD.Market_Price_Rate_Orig,0))  AS DECIMAL(12,2)) * BSAFIM.net_Weight
									AS printMinPrice_CS
								,ISNULL(PPCO.Colors,1)  AS iColors
								,ISNULL(PPCO.Graphics,'A') AS sGraphics
								,ISNULL(PPCO.digital,0)  AS bDigital
								,CAST(ISNULL(PMR.Amount,0) AS DECIMAL(12,2)) AS printMakeReadyBase
								,CAST(ISNULL(PPC.Amount,0) AS DECIMAL(12,2)) AS printPlateBase
								,CAST(ISNULL(PPP.Amount,0) AS DECIMAL(12,2)) AS printPrePressBase
							</cfif>
							
						<cfelse>
							,0  AS PrintMakeReadyCharge
							,0  AS PrintPlateCharge
							,0  AS PrintPrePressCharge
							,0  AS PrintMinPrice
							,0  AS iColors
							,'' AS sGraphics
							,0  AS bDigital
							,0  AS printMakeReadyBase
							,0  AS printPlateBase
							,0  AS printPrePressBase
						</cfif>
							,BSAFIM.Net_Weight
						 <cfif GetSettings.Custom_Fixed_Price_Options eq 1 && GetSettings.Group_Deal eq 1>
						  	  ,CASE
				 			WHEN B2.Brand_Id IS NULL THEN 0
				 		-- Commented Out -- No need to check for 'none'
				 		--	WHEN TGD.Type_Group_Desc_Id IS NULL THEN 0
				 			ELSE 1
				 			END as bCustomPrint

				 		 <cfelse>
							 ,0 as bCustomPrint	
						  </cfif>
						<cfif ezProgramId GT 0>
							,PRCDEZ.rate as rateEz
						<cfelse>
							,0 as rateEz
						</cfif>
						  INTO 		 ##TMP_Query_Result
						  FROM	     BSA_FoodService_Items_Master BSAFIM
						  <!--- LEFT JOIN CP SO WE CAN GET INACTIVE PRODS ALREADY ON PROGRAM [IN WHERE STATEMENT] --->
						 <cfif NOT bAll EQ false AND arguments.customPrint.bCustomPrint EQ true AND arrayLen(aItems) GT 0>
						 	 INNER
						 <cfelse>
						 	 LEFT
						 </cfif>
						   JOIN Contract_Products CP ON
						  			CP.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_Foodservice_Items_Master_ID
								AND CP.Contract_Main_ID = #arguments.programId#
								AND CP.Deleted = 0
								--AND CP.Is_Group = 0
								AND CP.Captured_From_Group = 0
							LEFT JOIN Program_Product_Volume V ON
								V.Program_ID = #arguments.programId# AND
								V.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_Foodservice_Items_Master_ID AND
								V.Deleted = 0
						  <!--- GET CUSTOM PRINT CHARGES -> goes first since inner join helps Perf.--->
							<cfif NOT bAll>
								<cfif arrayLen(aItems) EQ 0 >
									INNER JOIN Print_Program_Custom_Options PPCO ON
										PPCO.Contract_Main_ID = #arguments.programId# AND
										PPCO.Contract_Products_Id = CP.Contract_Products_Id
								</cfif>
								LEFT JOIN Print_Make_Ready PMR ON
									PMR.Prod_Var_B_Id = BSAFIM.Prod_Var_B_Id
									<cfif  arrayLen(aItems) EQ 0>
										AND PMR.color_count = PPCO.Colors
									<cfelse>
										AND PMR.color_count =  #arguments.customPrint.iColors#
									</cfif> 
								LEFT JOIN Print_Plate_Charge PPC ON
									PPC.Prod_Var_B_Id = BSAFIM.Prod_Var_B_Id AND
									PPC.Inv_Type = 'MakeShip'
								LEFT JOIN Print_Pre_Press PPP ON
									PPP.Prod_Var_B_Id = BSAFIM.Prod_Var_B_Id
										<cfif  arrayLen(aItems) EQ 0 > 
										AND
										(
											(PPP.Digital = 1 AND PPCO.Digital = 1)
											OR
											(PPP.Digital = 0 AND PPCO.Digital = 0)
										) AND
										PPP.Complexity = PPCO.Graphics AND
										PPP.Colors = PPCO.Colors
									<cfelse>
										AND
										<cfif arguments.customPrint.bDigital>
											PPP.Digital = 1 AND
										<cfelse>
											PPP.Digital = 0 AND
										</cfif>
										PPP.Complexity = '#arguments.customPrint.sGraphics#' AND
										PPP.Colors = #arguments.customPrint.iColors#
									</cfif>
									
							</cfif>
						  <cfoutput>#sJoin#</cfoutput>	
						  <cfif GetSettings.Custom_Fixed_Price_Options eq 1 && GetSettings.Group_Deal eq 1>
						  	LEFT JOIN Brand B2 ON
								B2.Brand_ID = BSAFIM.Brand_ID AND
								B2.Brand_Name = 'Local Print'
							-- Commented Out -- No need to check for 'none'
							--LEFT JOIN Type_Group_Desc TGD ON
							--		TGD.Type_Group_Desc_ID = BSAFIM.Type_Group_Desc_Id AND
							--		TGD.Type_Group_Desc = 'NONE'
						  </cfif>
						  
						<cfif iMPId>
							LEFT JOIN Market_Price_List MP ON
								MP.Market_Price_List_Id = #iMPId#
							LEFT JOIN Market_Price_Product_Rates MPR ON
								MP.Market_Price_List_Id = MPR.Market_Price_List_Id AND
								MPR.BSA_Foodservice_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_ID
							LEFT JOIN Program_Fixed_Price_Product_Data FPPD ON
								FPPD.Program_ID = #arguments.programId# AND
								CP.Contract_Products_ID = FPPD.Contract_Products_ID
							LEFT JOIN Units_of_Measure UOM ON
								UOM.Unit_Of_Measure_ID = MPR.Uom_Id
						<cfelseif (appSettings.getUseFixedPriceType() OR appSettings.getPriceListByTemplate() EQ 1) ><!--- D42975 :: Base_Price from gross_margin --->
							LEFT JOIN Price_List_Header PLH ON
								PLH.price_list_header_ID = '#priceHeaderListID#' AND
								PLH.deleted = 0
							LEFT JOIN Price_List_Detail PLD ON
								PLD.price_list_header_id = PLH.price_list_header_id AND
								PLD.deleted = 0 AND
								PLD.product_id = BSAFIM.BSA_FoodService_Items_Master_ID
						<cfelse>
						<!--- D42975 :: Base_Price from gross_margin--->
						<!--- Price is updated from Gross margin in next query --->
							LEFT JOIN Price_List_Default PLDEF ON
								PLDEF.Product_Id =  BSAFIM.BSA_FoodService_Items_Master_ID
						</cfif>
						<cfif ezProgramId GT 0>
						LEFT JOIN Contract_Products CPEZ ON
							CPEZ.Contract_Main_ID = #ezProgramId# AND
							CPEZ.product_Type_ID = 2 AND
							CPEZ.Deleted = 0 AND
							CPEZ.Captured_From_Group = 0 AND
							CPEZ.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_Foodservice_Items_Master_ID
						LEFT JOIN Program_Rebates_Product_Data PRPDEZ ON
							PRPDEZ.Contract_Products_ID = CPEZ.Contract_Products_ID AND
							PRPDEZ.Deleted = 0
						LEFT JOIN Program_Rebates_Component_Data PRCDEZ ON
							PRCDEZ.Program_Rebates_Product_Data_ID = PRPDEZ.Program_Rebates_Product_Data_ID
						AND	PRCDEZ.Deleted = 0
						</cfif>
							#this.searchPGJoin(FirstParentId,varTemplateFiltersID)#
						  WHERE       
						  
						  <cfif arguments.customPrint.bCustomPrint AND arrayLen(aItems) GT 0>
						  		BSAFIM.BSA_FoodService_Items_Master_ID IN(#ListQualify(listCustomItems,"'",",","all" )#) AND
						  </cfif>
						  
						  BSAFIM.DELETED = 0--KRAFT AND Cast(PLD.CS_Bracket_1 as Decimal(16,4)) > 0.0
						  <cfif val(busSegIdForProgram) neq 0>
								AND BSAFIM.Business_Segment_Id = #busSegIdForProgram#
						  </cfif>
						 <cfif bAll >
							 AND (
							  <!--- GET Items (Not NULL)   ::  Only return active records unless they are on the Program. --->
							  	(BSAFIM.Item Is Not Null  <cfif (appSettings.getSearchInactiveProductsInPrograms() EQ 0) OR Get_Profile_Settings.Search_Inactive_Products_Programs EQ 0> AND (BSAFIM.ACTIVE_CODE = 'A' OR CP.Contract_Products_ID IS NOT NULL) </cfif>)
							  	<!--- Dynamic sql to handle Multi-Product Attr Groups D35295 --->
							  		#preserveSingleQuotes(sGroupJoin)#
							  		#preserveSingleQuotes(sGroupSQL)#)
							  	<!--- Restrictions are built seperateley and returned via savecontent this.searchSettings()  --->
							   <cfif arguments.bMp AND application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 1 >
							  	--GROUPS ONLY FOR Market Price List
								And BSAFIM.Is_Item_Group = 1
							  <cfelseif application.appSettingsGet.getTemplateMultipleProductAttrGroups() EQ 0>
								 <!--- #searchSettings(arguments.ProgramId)# --->
								 And ISNULL(BSAFIM.Is_Item_Group,0) = 0
							  </cfif>
							  	#this.searchPGWhere(FirstParentId,varTemplateFiltersID)#
						 </cfif>
						 <cfif NOT iMPId AND NOT appSettings.getUseFixedPriceType() AND NOT appSettings.getPriceListByTemplate() EQ 1 >
						 GROUP BY
							BSAFIM.BSA_FoodService_Items_Master_ID,
							BSAFIM.Description,
							BSAFIM.Is_Item_Group,
							BSAFIM.Item,
							BSAFIM.Active_code,
							V.Volume_LB,
							#sGroupClauseSQL#
							BSAFIM.Net_Weight
							<cfif ezProgramId GT 0>	<!--- D45239 --->
								,PRCDEZ.rate
							</cfif>
							,PLDEF.CS_FOB_Price
							
						 </cfif>
						 
						 
						 
						 <cfif iMPId>
							<!--- Price is in the main query --->
						<cfelseif (appSettings.getUseFixedPriceType() OR appSettings.getPriceListByTemplate() EQ 1) ><!--- D42975 :: Base_Price from gross_margin --->
							<!--- Price is in the main query --->
						<cfelse>
							<!--- Get price from Gross margin. Done here to avoid duplication when item is part fo fixed and rebate --->
							IF OBJECT_ID('tempdb..##TMP_GM_Price') IS NOT NULL
							DROP TABLE ##TMP_GM_Price
						
							SELECT	BSAFIM.itemGuid,
									ISNULL(SUM(GrM.CS_FOB_Price * CD.Program_Weight) / ISNULL(NULLIF(SUM(CAST(CD.Program_Weight AS FLOAT)), 0), 100),0) AS Price_CS,
									ISNULL(SUM(GrM.CS_FOB_Price * CD.Program_Weight) / ISNULL(NULLIF(SUM(CAST(CD.Program_Weight AS FLOAT)), 0), 100),0)/isnull(nullif(cast(BSAFIM.Net_Weight as decimal(14,4)),0),1) AS Price_LB
						 	INTO	##TMP_GM_Price
						 	FROM	##TMP_Query_Result BSAFIM
						 	INNER JOIN Contract_Distributors CD ON
								CD.Contract_Main_ID = #arguments.programId# AND
								CD.Deleted = 0
							INNER JOIN Gross_Margin GrM ON
								GrM.Product_id = BSAFIM.itemGuid AND 
								GrM.Customer_Id = CD.BSA_Foodservice_Customers_ID AND
								GrM.CS_FOB_Price <> 0
						--D46276 :: Update margin page and rates grid to not include prices from inactive customers START
						 INNER JOIN BSA_Foodservice_Customers BFC
						 ON BFC.BSA_Foodservice_Customers_ID = CD.BSA_Foodservice_Customers_ID
						 AND BFC.Active_Code = 'A'
						--D46276 :: Update margin page and rates grid to not include prices from inactive customers END
							GROUP BY BSAFIM.itemGuid, BSAFIM.Net_Weight
							
							-- Use ITEM_MARGIN_TARGETS table if no price in Gross_Margin table
							INSERT INTO ##TMP_GM_Price (itemGuid, Price_CS, Price_LB)
							SELECT	BSAFIM.itemGuid, imt.ITEM_FOB_BASE_PRICE_CS, imt.ITEM_FOB_BASE_PRICE_LB
							FROM	##TMP_Query_Result BSAFIM
							INNER JOIN ITEM_MARGIN_TARGETS imt
							ON		imt.Product_Id = BSAFIM.itemGuid
							WHERE	NOT EXISTS (SELECT 1 FROM ##TMP_GM_Price t WHERE t.itemGuid = BSAFIM.itemGuid)
							
							UPDATE	##TMP_Query_Result
							SET		Market_Price = Price_CS,
									Market_Price_Rate_Orig = Price_CS,
									Market_Price_Rate_CS = Price_CS,
									Market_Price_Rate_LB = Price_LB
							FROM	##TMP_Query_Result
							INNER JOIN ##TMP_GM_Price
							ON		##TMP_GM_Price.itemGuid = ##TMP_Query_Result.itemGuid
						</cfif>
						 
						 SELECT	*
						 FROM	##TMP_Query_Result
						 ORDER BY  IsGroup ASC, baItemDisplay, Description, itemGuid
					</cfoutput>
				</cfsavecontent>
	
				<!---<cfdump var="#sQuery#" output="c:\dump.log" >--->
				  <CFQUERY NAME="qGetItems" datasource="#application.datasource#">
				  	  #preserveSingleQuotes(sQuery)#
				  </CFQUERY> 

			<!---<cfif !bAll>
			 	<cfdump var="#qGetItems#" output="c:\dump.log" >
			</cfif>--->
				<cfloop index="i" from="1" to="#qGetItems.recordcount#">
					<cfif bAll>
						<cfscript>
							stUomData = structNew();
							stUomData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
							stUomData["uomId"] = qGetItems["Uom_Id"][i];
							stUomData["description"] = qGetItems["Unit_of_Measure_Desc_Singular"][i];
							stUomData["abbreviation"] = qGetItems["Abbreviation_Singular"][i];
							
							stData = structNew();
							stData["__type__"] = "mvc.Models.Item.vos.Item";
							stData["isSelected"] = "";
							stData["baItem"] = qGetItems["baItem"][i];
							stData["baItemDisplay"] = qGetItems["baItemDisplay"][i];
							stData["itemGuid"] = qGetItems["itemGuid"][i];
							stData["isGroup"] = javacast("boolean",qGetItems["isGroup"][i]);
							if(qGetItems["isGroup"][i] == 0){
								stData["Description"] = qGetItems["Description"][i];
							}
							else{
								stData["Description"] = 'Group';
							}
							
							for (n=1;n LTE ArrayLen(arrFields);n=n+1) {
        						stData["#arrFields[n]#"] = qGetItems["#arrFields[n]#"][i];
							}
							/*
							for(s in arrFields) {
									stData["#s#"] = qGetItems["#s#"][i];
								}
							*/
							stData["Item_Status"] = qGetItems["Item_Status"][i];
							//stData["volume"] = qGetItems["volume"][i];
							stData["uomMP"] = stUomData;
							stData["marketPrice"] = qGetItems["Market_Price"][i];
							stData["rateMPOrig"] = qGetItems["Market_Price_Rate_Orig"][i];
							stData["marketPriceCS"] = qGetItems["Market_Price_Rate_CS"][i];
							stData["marketPriceLB"] = qGetItems["Market_Price_Rate_LB"][i];
							stData["rateEz"] = qGetItems["rateEz"][i];
							
							stCustPrint = structNew();
							stCustPrint["__type__"] 	= "mvc.Models.Program.Component.vos.CustomPrint";
							stCustPrint["bCustomPrint"] =  javacast("boolean",qGetItems["bCustomPrint"][i]);
							
							stData["customPrint"] = duplicate(stCustPrint);
							
	            			ArrayAppend(arrRet, duplicate(stData));
						</cfscript>
					<cfelse>
						<cfscript>
							/* loop over items to calculate print charges */
							if(arrayLen(aItems) GT 0){
								for (ix=1;i LTE ArrayLen(aItems);ix=ix+1) {
									if(aItems[ix]["itemGuid"] == qGetItems["itemGuid"][i]){
										vol = aItems[ix]["volume"];
										local.printMakeReady 	=  qGetItems["printMakeReady"][i] / (vol);// * nMultiplier
										local.printPlate		=  qGetItems["printPlate"][i] * arguments.customPrint.iColors/(vol);//* nMultiplier :: vol comes from UI so multiplier (vol is store as a weekly num in db) is not needed :: 
										local.printPrePress 	=  qGetItems["printPrePress"][i] / (vol);// * nMultiplier
										local.printMinPrice 	=  numberFormat((printMakeReady + printPlate + printPrePress + qGetItems["Market_Price_Rate_Orig"][i]), "9999.9999");
									
										/*
											MAKE SURE VOLUME FROM ITEMS vos (in flex) HAS CORRECT DATA
										 */
										break;
									}
								}
								stCustPrintCharge = structNew();
								stCustPrintCharge["__type__"] = "mvc.Models.Program.Component.vos.CustomPrintCharge";
								stCustPrintCharge["printMakeReady"] =  local.printMakeReady;
								stCustPrintCharge["printPlate"] 	=  local.printPlate;
								stCustPrintCharge["printPrePress"]  =  local.printPrePress;
								stCustPrintCharge["printMinPrice"]  =  local.printMinPrice;
								stCustPrintCharge["printMinPriceLB"]  =  local.printMinPrice;
								stCustPrintCharge["printMinPriceCS"]  =  local.printMinPrice * qGetItems["Net_Weight"][i];
								//BASE Charge
								stCustPrintCharge["printPlateBase"] 	=  qGetItems["printPlateBase"][i];
								stCustPrintCharge["printPrePressBase"]  =  qGetItems["printPrePressBase"][i];
								stCustPrintCharge["printMakeReadyBase"]  =  qGetItems["printMakeReadyBase"][i];
							}
							else{
								stCustPrintCharge = structNew();
								stCustPrintCharge["__type__"] = "mvc.Models.Program.Component.vos.CustomPrintCharge";
								stCustPrintCharge["printMakeReady"] =  qGetItems["printMakeReady"][i];
								stCustPrintCharge["printPlate"] 	=  qGetItems["printPlate"][i];
								stCustPrintCharge["printPrePress"]  =  qGetItems["printPrePress"][i];
								stCustPrintCharge["printMinPrice"]  =  qGetItems["printMinPrice"][i];
								stCustPrintCharge["printMinPriceLB"] =  qGetItems["printMinPrice"][i];
								stCustPrintCharge["printMinPriceCS"]  =  qGetItems["printMinPrice"][i] * qGetItems["Net_Weight"][i];
								//BASE Charge
								stCustPrintCharge["printPlateBase"] 	=  qGetItems["printPlateBase"][i];
								stCustPrintCharge["printPrePressBase"]  =  qGetItems["printPrePressBase"][i];
								stCustPrintCharge["printMakeReadyBase"]  =  qGetItems["printMakeReadyBase"][i];
								
							}
							stUomData = structNew();
							stUomData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
							stUomData["uomId"] = qGetItems["Uom_Id"][i];
							stUomData["description"] = qGetItems["Unit_of_Measure_Desc_Singular"][i];
							stUomData["abbreviation"] = qGetItems["Abbreviation_Singular"][i];
							
							
							
							stCustPrint = structNew();
							stCustPrint["__type__"] 	= "mvc.Models.Program.Component.vos.CustomPrint";
							stCustPrint["iColors"]		=  qGetItems["iColors"][i];
							stCustPrint["sGraphics"]	=  qGetItems["sGraphics"][i];
							stCustPrint["bDigital"] 	=  javacast("boolean",qGetItems["bDigital"][i]);
							stCustPrint["bCustomPrint"] =  javacast("boolean",qGetItems["bCustomPrint"][i]);
							
							stData = structNew();
							stData["uomMP"] = stUomData;
							stData["customPrintCharge"] = duplicate(stCustPrintCharge);
							stData["customPrint"] = duplicate(stCustPrint);
							stData["itemGuid"] = qGetItems["itemGuid"][i];
							stData["marketPrice"] = qGetItems["Market_Price"][i];
							stData["rateMPOrig"] = qGetItems["Market_Price_Rate_Orig"][i];
							stData["marketPriceCS"] = qGetItems["Market_Price_Rate_CS"][i];
							stData["marketPriceLB"] = qGetItems["Market_Price_Rate_LB"][i];
							ArrayAppend(arrRet, duplicate(stData));
						</cfscript>
					</cfif>
				</cfloop>
				<!--- <cfdump var="#arrRet#" output="c:\dump.log" > --->
			 <cfreturn arrRet />
	</cffunction>
	
	<cffunction name="getMiniItemMasterItems" access="remote" returntype="Array">
		<cfargument name="ProgramId" default="0">
		<cfset var Distributor_List = "00000000-0000-0000-0000-000000000000">
		<cfset var qGetCustomers = "" />
		<cfset var qGetItemsFromMiniItemsMaster = "" />
		<cfset var tmpData = ArrayNew(1)/>
		
		<cfquery name="getRebateTypes" datasource="#Application.Datasource#">
					SELECT  C.Contract_Main_ID, 
							PCPO.Discount_Fixed_Prices, 
					        PCPO.Discount_Rebates,
					        PCPO.Discount_Growth, 
					        PCPO.Discount_Lump_Sums,
					        PCPO.Discount_Formula_Pricing,
					        PCPO.Generic_Type
					FROM    dbo.Contract_Main C 
					INNER JOIN dbo.Program_Control_Panel_Options  PCPO ON 
					       C.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID AND 
					       PCPO.Deleted = 0
					WHERE     (C.Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">	) AND C.Deleted=0
		</cfquery>
		<cfif getRebateTypes.Generic_Type IS NOT "Brokerage" >
			<cfquery name="qGetCustomers" datasource="#application.datasource#">
				SELECT	DISTINCT(BSA_Foodservice_Customers_ID)
				FROM	Contract_Distributors
				WHERE	Deleted = 0
				AND		Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">		
			</cfquery>
		<cfelse>
			<cfquery name="qGetCustomers" datasource="#application.datasource#">
				SELECT	DISTINCT(BSA_Foodservice_Customers_ID)
				FROM	Contract_Brokers CB
				INNER JOIN BSA_FoodService_Customers CM on CM.BSA_FoodService_Brokers_ID = CB.BSA_FoodService_Brokers_ID 
				WHERE	CB.Deleted = 0 
				AND		Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">		
			</cfquery>
		</cfif>
		
		<cfif qGetCustomers.recordcount GT 0>
			<cfset Distributor_List = ValueList(qGetCustomers.BSA_Foodservice_Customers_ID) />
		</cfif>
		<cfquery name="qGetItemsFromMiniItemsMaster" datasource="#application.datasource#">
			SELECT DISTINCT ltrim(rtrim(Product_Table.Item)) AS Item		
			FROM	BSA_Mini_Item_Master Product_Table	
			WHERE	
						Product_Table.Customer_ID IN (#ListQualify(Distributor_List, "'")#)
		</cfquery>
		
		<cfset tmpData.AddAll(qGetItemsFromMiniItemsMaster[ "Item" ])  />
		
		<cfreturn tmpData />
	</cffunction>
	
	<cffunction name="searchSettings" returntype="String">
		<cfargument name="ProgramId" default="0">
		
		<cfset var exclude_sig_products = 0 />
		<cfset var GetSettings = "" />
		<cfset var programInfo = "" />
		<cfset var approvalGroupManager = "" />
		<cfset var approvalGroupType = "" />
		<cfset var restrictOnProfileProductGroup = "" />
		<cfset var qRestrictOnModifyingProductGroupList = "" />
		<cfset var restrictOnModifyingProductGroupList = "" />
		<cfset var restrictOnProductGroup = "" />
		<cfset var qRestrictOnProductGroupList = "" />
		<cfset var restrictOnProductGroupList = "" />
		<cfset var restrictOnClassCodeUUIDList = "" />
		<cfset var businessSegManager = "" />
		<cfset var sProdSearchClause = "" />
		<cfset var programManager	 = "" />
		<!--- <cfset var = "" />
		<cfset var = "" />
		<cfset var = "" />
		<cfset var = "" /> --->
		
		<CFIF arguments.ProgramId NEQ 0 AND LEN(trim(arguments.ProgramId)) NEQ 0>
			<cfset programManager = CreateObject("component", "components.programs.ProgramManager").init()>
			<cfset programInfo = programManager.getProgramInfo(arguments.ProgramId)>
		
		<cfquery name="GetSettings" datasource="#application.datasource#">
			SELECT PCPO.Discount_Rebates_Group_Level,
					exclude_sig_products,
					modifying_program,
					EZButton_On,EZ_Contract_Id
			FROM Contract_Main
				INNER JOIN	Program_Control_Panel_Options PCPO
				ON (Contract_Main.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID)
			WHERE Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfset exclude_sig_products = getsettings.exclude_sig_products />
			<cfif programInfo.Restrict_On_Approval_Group EQ 1 OR GetSettings.modifying_program EQ 1>
				<cfset approvalGroupManager = CreateObject("component", "components.settings.ApprovalGroupManager").init()>
				<cfset approvalGroupType = approvalGroupManager.getGroupTypeInfo(productGroupLevelId=appSettings.getTemplateRestrictGroupLevel()) />
			</cfif>
			
			<cfif GetSettings.modifying_program EQ 1>
			<cfset restrictOnProfileProductGroup = 1>
				<cfset qRestrictOnModifyingProductGroupList = approvalGroupManager.GetProfileAllowApprovalGroups(request.AccessStructure.Profiles_ID)>
				<cfset restrictOnModifyingProductGroupList = ValueList(qRestrictOnModifyingProductGroupList.Group_ID)>
			</cfif>
				
			<cfif programInfo.Restrict_On_Approval_Group EQ 1>
				<cfset restrictOnProductGroup = 1>
				<cfset qRestrictOnProductGroupList = approvalGroupManager.getTemplateAllowApprovalGroups(programInfo.ProgramType_ID)>
				<cfset restrictOnProductGroupList = ValueList(qRestrictOnProductGroupList.Group_ID)>
				<cfif appSettings.getTemplateRestrictGroupLevel() eq 10>
					<cfif NOT isDefined("businessSegManager")>
						<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
					</cfif>
					<cfset restrictOnClassCodeUUIDList = restrictOnProductGroupList>
					<cfset restrictOnProductGroupList = businessSegManager.getClassCodeIDList(restrictOnProductGroupList) />
				</cfif>
			</cfif>
		 </CFIF>
		 
		 <cfsavecontent variable="sProdSearchClause">
			 
			 <cfif IsDefined("exclude_sig_products")>
				<cfif exclude_sig_products EQ 1>
					AND BSAFIM.specialty_product = 0
				</cfif>
			 </cfif>
			 <cfparam name="restrictOnProductGroup" 	default="0">
				<cfparam name="restrictOnProductGroupList" 	default="">
				<cfoutput>
					<cfif restrictOnProductGroup EQ "1" AND isDefined("approvalGroupType")>
					AND 
					<cfif Len(restrictOnProductGroupList) EQ 0>1=2
					<cfelseif approvalGroupType.groupLevelType EQ 5>QB.#approvalGroupType.productGroupIDField# IN (#ListQualify(restrictOnProductGroupList, "'", ",")#)
					<cfelse>BSAFIM.#approvalGroupType.MasterIDField# IN (#ListQualify(restrictOnProductGroupList, "'", ",")#)
					</cfif>
				</cfif>
				<!------ Add to product query for restrict on product group for each profile ----->
				<cfparam name="restrictOnProfileProductGroup" 	default="0">
				<cfparam name="restrictOnModifyingProductGroupList" 	default="">	
				<cfif restrictOnProfileProductGroup EQ "1" AND isDefined("approvalGroupType")>
					AND 
					<cfif Len(restrictOnModifyingProductGroupList) EQ 0>0=0
					<cfelseif approvalGroupType.groupLevelType EQ 5>QB.#approvalGroupType.productGroupIDField#  NOT IN (#ListQualify(restrictOnModifyingProductGroupList, "'", ",")#)
					<cfelse>BSAFIM.#approvalGroupType.MasterIDField# NOT IN (#ListQualify(restrictOnModifyingProductGroupList, "'", ",")#)
					</cfif>
				</cfif>
				</cfoutput>
		 </cfsavecontent>
		<!--- <cflog text="item where clause :: #sProdSearchClause#" />--->
		 <cfreturn sProdSearchClause />
	</cffunction>
	
	<cffunction name="searchPGJoin" returntype="String">
		<cfargument name="FirstParentID" default="0">
		<cfargument name="TemplateFiltersID" default = "0">
		<cfscript>
			var sWhereClause = "";
			
			/* INSERT LOGIC TO INCORPORATE ITEM FILTERS (PLANNING GROUPS) */
		</cfscript>
		<cfscript>
			obj = CreateObject("component","components.products.group.ProductGroupAttributeManager");
			qGroupsInTemplate = obj.getProductGroupAttributesGroupTemplate(active = 1, FirstParentID = arguments.FirstParentID, TemplateFiltersID = arguments.TemplateFiltersID);
			Q = '';
		</cfscript>
		
		<cfif isDefined("qGroupsInTemplate")>
			<cfloop query="qGroupsInTemplate">
		  		<!--- We need to filter the search results in 2 situations
				-- Tempalte is filtered on a product group
				-- A drop down value is selected
				 --->
				<!--- do this only for planning groups --->
				<!--- Below logic is to add extra JOINs on planning group tables so that we can filter later in the where clause --->
				<cfset typeId = qGroupsInTemplate.Group_Level_ID />				
				
				<cfif qGroupsInTemplate.PG_Flag>
					<cfif qGroupsInTemplate.Allow_Filter>
						<cfset q = '#q# INNER JOIN PG_Product_Members as PGPM_#typeId#
				            ON		PGPM_#typeId#.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_Foodservice_Items_Master_ID
				            INNER JOIN PG_Product_Category as PGPC_#typeId#
				            ON		PGPC_#typeId#.PG_Product_Category_ID = PGPM_#typeId#.PG_Product_Category_ID' />
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn q/>
	</cffunction>
	
	<cffunction name="searchPGWhere" returntype="String">
		<cfargument name="FirstParentID" default="0">
		<cfargument name="TemplateFiltersID" default = "0">
		<cfscript>
			var sWhereClause = "";
			var obj = CreateObject("component","components.products.Group.ProductGroupAttributeManager");
			var qGroupsInTemplate = obj.getProductGroupAttributesGroupTemplate(active = 1, FirstParentID = arguments.FirstParentID, TemplateFiltersID = arguments.TemplateFiltersID);
			var s = '';
			var i = 0;
		</cfscript>
		
		<cfif isDefined("qGroupsInTemplate")>
			<cfloop query="qGroupsInTemplate">
				<cfscript>
					ProductAttributeDropDownName = "Product_Attribute_#qGroupsInTemplate.Group_Level_ID#";
					typeId = qGroupsInTemplate.Group_Level_ID;
					if(qGroupsInTemplate.Allow_Filter){
						if(i==0){
							s =  'AND ( ';
						}
						//add the filters as a list of AND
						if(i>0){
							s =  '#s# AND ';
						}
						//--- Template is filtered on a product group --->
						if ((qGroupsInTemplate.PG_Flag EQ 0) AND (qGroupsInTemplate.Product_Group_Attribute_Master_ID_Field NEQ "PG_Product_Category_ID")){
						   s =  '#s# CAST(BSAFIM.#qGroupsInTemplate.Product_Group_Attribute_Master_ID_Field# as varchar(50)) 
								IN (SELECT Product_group_ID FROM Product_Group_Template_Selection 
									WHERE Deleted = 0 AND Active = 1 AND 
										PG_Flag = 0 AND
										(Template_Filters_Id = #TemplateFiltersID# OR #TemplateFiltersID# = 0) AND
										Template_ID = #FirstParentID# AND 
										Product_Group_Level_ID = #qGroupsInTemplate.Group_Level_ID#)';
						}
						else{
							//--- Planning groups / Anand Rao/10-Jan-2011 ---
							s = '#s# PGPM_#typeId#.PG_Product_Category_ID IN (SELECT Product_group_ID FROM Product_Group_Template_Selection WHERE Deleted = 0 AND Active = 1 AND PG_Flag = 1 AND 
						 				Template_ID = #FirstParentID# AND 
						 				(Template_Filters_Id = #TemplateFiltersID# OR #TemplateFiltersID# = 0) AND
						 				Product_Group_Level_ID = #qGroupsInTemplate.Group_Level_ID#)';
						}
						i++;
					}
				</cfscript>
			</cfloop>
			<cfif i GT 0>
				<cfset s =  '#s# ) ' />
			</cfif>
		</cfif>
		
		<cfreturn s/>
	</cffunction>
	
	<cffunction name="getCustomCharges" returntype="Struct" access="remote">
		<cfargument name="programId" default="0">
		<cfargument name="list" default = "">
		<cfscript>
			var x = '';
			var objMarketPriceManager	= CreateObject("component","mvc.Models.Template.MarketPriceManager");
			var iMPId = objMarketPriceManager.getProgramActiveMPList(arguments.ProgramId);
			var varTemplateFiltersID = 0;
			var stUomData = structNew();
		</cfscript>
		<cfquery name="GetCustomCharge" datasource="#application.datasource#">
			SELECT DISTINCT
			 	BSAFIM.BSA_FoodService_Items_Master_ID AS itemGuid,
				MPR.rate AS Market_Price,
				MPR.Uom_Id,
				UOM.Abbreviation_Singular,
				UOM.Unit_of_Measure_Desc_Singular
				,CAST(ISNULL(PMR.Amount,0)/ISNULL(Prod_Var_A,0) AS DECIMAL(12,2)) AS printMakeReady
				,CAST(ISNULL(PPC.Amount,0) * #arguments.customPrint.iColors#/ISNULL(Prod_Var_A,0) AS DECIMAL(12,2)) AS printPlate
				,CAST(ISNULL(PPP.Amount,0)/ISNULL(Prod_Var_A,0) AS DECIMAL(12,2)) AS printPrePress
				
				,CAST(ISNULL(PMR.Amount,0)/ISNULL(Prod_Var_A,0) AS DECIMAL(12,2)) +
					CAST(ISNULL(PPC.Amount,0) * #arguments.customPrint.iColors#/ISNULL(Prod_Var_A,0) AS DECIMAL(12,2)) +
					CAST(ISNULL(PPP.Amount,0)/ISNULL(Prod_Var_A,0) AS DECIMAL(12,2))+
					CAST(ISNULL(MPR.rate,0) AS DECIMAL(12,2))
					AS printMinPrice
				,0  AS iColors
				,'' AS sGraphics
				,0  AS bDigital
			
			  FROM	     BSA_FoodService_Items_Master BSAFIM
			  <!--- GET CUSTOM PRINT CHARGES -> goes first since inner join helps Perf.--->
					INNER JOIN Print_Product_Group_Mapping PPGM ON
						PPGM.Prod_Var_B_Id = BSAFIM.Prod_Var_B_Id
					LEFT JOIN Print_Make_Ready PMR ON
						PMR.Product_Group_Id = PPGM.Product_Group_Id AND
						PMR.color_count =  #arguments.customPrint.iColors#
					LEFT JOIN Print_Plate_Charge PPC ON
						PPC.Product_Group_Id = PPGM.Product_Group_Id AND
						PPC.Inv_Type = 'MakeShip'
					LEFT JOIN Print_Pre_Press PPP ON
						PPP.Product_Group_Id = PPGM.Product_Group_Id AND
						<cfif arguments.customPrint.bDigital>
							PPP.Art_Type =  'Digital' AND
						<cfelse>
							PPP.Art_Type !=  'Digital' AND
						</cfif>
						PPP.Complexity = '#arguments.customPrint.sGraphics#' AND
						PPP.Colors = #arguments.customPrint.iColors#
					LEFT JOIN Prod_Var_A PVA ON
						PVA.Prod_Var_A_ID = BSAFIM.Prod_Var_A_ID
			<!---  LEFT JOIN Contract_Products CP ON
			  			CP.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_Foodservice_Items_Master_ID
					AND CP.Contract_Main_ID = #arguments.programId#
					AND CP.Deleted = 0
					AND CP.Captured_From_Group = 0--->
			INNER JOIN
				 Market_Price_List MP ON
					MP.Market_Price_List_Id = #iMPId#
			INNER JOIN Market_Price_Product_Rates MPR ON
					MP.Market_Price_List_Id = MPR.Market_Price_List_Id AND
					MPR.BSA_Foodservice_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_ID
			LEFT JOIN Units_of_Measure UOM ON
					UOM.Unit_Of_Measure_ID = MPR.Uom_Id
			WHERE    BSA_FoodService_Items_Master_ID IN(preserveSingleQuotes(#list#)) 
			--AND    BSAFIM.DELETED = 0
			--AND BSAFIM.Item Is Not Null
			ORDER BY  baItem, itemGuid
		</cfquery>
	</cffunction>
	
	<cffunction name="getSettingsObject" returntype="Struct" access="remote">
		<cfargument name="userId" default="00000000-9999-9999-0000000000000000">
		<cfargument name="programId" default="0">
		<cfset var obj = "" />
		<cfset var stSettings = StructNew()/>
		<cflog text="getSettingsObject">
		<!--- profile and user settings [empty for now] -> we may want to write and all use a common function for profile data--->
		<cfset obj = createobject("component", "mvc.models.SettingsService") />
		<cfset stSettings.user = StructNew()/>
		<cfset stSettings.user = obj.getUserObject(arguments.userId) />
		
		<!--- return application.appSettingsGet as a structure with keys named the same as the appsettings methods--->
		<cfset stSettings.appSettings = StructNew()/>
		<!--- <cfset stSettings.appSettings = obj.getAppSettingsObject() /> --->
		<cfset structinsert(stSettings.appSettings,"Exact_List_Matching_On",appSettings.Exact_List_Matching_On)>
		<!--- appsettings: variables returned are specific to calling swf --->
		<cfset stSettings.appFlex = StructNew()/>
		
		<cfset stsettings.UIAttributes = obj.getUIAttributes()> 
		<cfreturn stSettings>
	</cffunction>

	<cffunction name="getRebateTypes" hint="return what discount types exist on a program template" access="remote" output="false" returntype="Array">
	  <cfargument name="ProgramId" default="0">
		<cfset ArrayDiscountTypes = ArrayNew(1)>
		<cfquery name="qgetRebateTypes" datasource="#Application.Datasource#">
		SELECT  PCPO.Discount_Fixed_Prices, 
			PCPO.Discount_Rebates,
			PCPO.Discount_Growth, 
			PCPO.Discount_Lump_Sums,
			PCPO.Discount_bidrequest 
		FROM    dbo.Contract_Main C 
		INNER JOIN dbo.Program_Control_Panel_Options  PCPO ON 
			  C.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID AND 
			  PCPO.Deleted = 0
		WHERE     (C.Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">	) AND C.Deleted=0
		</cfquery>

		<!--- This Array will return existing discount types available in a  program --->
		<cfset ArrCounter=  1>
		<cfloop query="qgetRebateTypes">
			<cfif qgetRebateTypes.Discount_Fixed_Prices EQ 1> 
				<cfset ArrayDiscountTypes[#ArrCounter#] = "Fixed Price"/>
				<cfset ArrCounter = ArrCounter + 1>
			</cfif>

			<cfif qgetRebateTypes.Discount_Rebates EQ 1> 
				<cfset ArrayDiscountTypes[#ArrCounter#] = "Rebate"/>
				<cfset ArrCounter = ArrCounter + 1>
			</cfif>

			<cfif qgetRebateTypes.Discount_Lump_Sums EQ 1> 
				<cfset ArrayDiscountTypes[#ArrCounter#] = "Lump Sum"/>
				<cfset ArrCounter = ArrCounter + 1>
			</cfif>

			<cfif qgetRebateTypes.Discount_Growth EQ 1> 
				<cfset ArrayDiscountTypes[#ArrCounter#] = "Growth"/>
				<cfset ArrCounter = ArrCounter + 1>
			</cfif>

			<cfif qgetRebateTypes.Discount_bidrequest EQ 1> 
				<cfset ArrayDiscountTypes[#ArrCounter#] = "Bid Request"/>
				<cfset ArrCounter = ArrCounter + 1>
			</cfif>
		</cfloop>

		<cfreturn ArrayDiscountTypes>
	</cffunction>
	
	
	<!--- 	**************************************************************************************************************************
		TODO: USE THIS LOGIC FOR GETTING BASE PRICE
				** 2 if else statements seem to parallel eachother.
		**************************************************************************************************************************
	
<cfif appSettings.getPriceListByTemplate() EQ 1 AND Program_Details.Market_Price EQ 0>
	<cfset qTemplatePrice = CreateObject("component", "components.programs.ProgramManager").getItemCustPriceTemplatePS(
			product_id = productId,
			Contract_Main_ID = CID,
			priceHeaderListID = Program_Details.Margin_Price_List_Header_ID) />
	<cfif qTemplatePrice.recordCount>
		<cfset Program_Template_Price_CS = qTemplatePrice.FOB_CS_Price />
	</cfif> 

<cfelseif appSettings.getUseFixedPriceType()>
	<cfset qBracketPrice = CreateObject("component", "components.programs.bid_request.BidRequestProductManager").getItemCustPriceForFP(
			product_id = productId,
			Contract_Main_ID = CID,
			priceListID = Program_Details.Price_List_ID) />
	<cfif qBracketPrice.recordCount>
		<cfset Program_Bracket_Price_CS = qBracketPrice.FOB_CS_Price />
	</cfif> 
<cfelseif Program_Details.Use_Fixed_Price_As_Base_Sales OR Program_Details.Market_Price>
	<CFQUERY NAME="getProgramFixedPrice" datasource="#application.datasource#">
		SELECT 	AVG(
			<cfif Program_Details.Market_Price>
				CASE
				WHEN Unit_Of_Measure_ID = 1 THEN
						CAST(ISNULL(PFPPD.Market_Price_Rate,0) AS DECIMAL(10,4))
				WHEN Unit_Of_Measure_ID = 2 THEN
						CAST(ISNULL(PFPPD.Market_Price_Rate,0) AS DECIMAL(10,4)) * #Product_Details.Net_Weight#
				ELSE
					0
				END) 
			<cfelse>
				CASE
				WHEN Unit_Of_Measure_ID = 1 THEN
						CAST(ISNULL(PFPPD.Fixed_Price_Value,0) AS DECIMAL(10,4))
				WHEN Unit_Of_Measure_ID = 2 THEN
						CAST(ISNULL(PFPPD.Fixed_Price_Value,0) AS DECIMAL(10,4)) * #Product_Details.Net_Weight#
				ELSE
					0
				END) 
			</cfif>
				as Fixed_Price_Value
		FROM 	Contract_Products CP
		INNER JOIN Program_Fixed_Price_Product_Data PFPPD
		ON		PFPPD.Deleted = 0
		AND		PFPPD.Contract_Products_ID = CP.Contract_Products_ID
		<cfif Program_Details.Market_Price>
			AND 	ISNULL(CAST(PFPPD.Fixed_Price_Value AS FLOAT), 0) != 0.00
		<cfelse>
			AND 	CAST(ISNULL(PFPPD.Fixed_Price_Value,0) AS DECIMAL(10,4)) != 0.00
		</cfif>
		WHERE	CP.Contract_Main_ID = '#CID#'
		AND		CP.Deleted = 0
		AND		CP.Product_Type_ID = 1
		AND		CP.BSA_Foodservice_Items_Master_ID = '#replace(ItemId, "_", "-", "ALL")#'		
	</CFQUERY>
	<cfif getProgramFixedPrice.recordCount>
		<cfset Program_Fixed_Price_CS = getProgramFixedPrice.Fixed_Price_Value />
	</cfif>
</cfif>

<!--- Get Base Price for a Product --->
	<CFQUERY NAME="getBasePrice" datasource="#application.datasource#">
		SELECT CASE #Product_Details.Item_Deliverytype#
			WHEN 2 
				THEN
					ITEM_FOB_BASE_PRICE
			ELSE
					ITEM_DEL_BASE_PRICE
			END
			As CS_Price
		FROM 	Item_Margin_Targets imt
		WHERE 	imt.product_id = '#replace(ItemId, "_", "-", "ALL")#'
		AND 	imt.Deleted = 0
	</CFQUERY>
	
	**********
	**********	
		
		
		
		
	<cfif appSettings.getPriceListByTemplate() EQ 1 AND (Program_Details.Market_Price EQ 0)>
		<cfset Base_Price = Program_Template_Price_CS />
	<cfelseif appSettings.getUseFixedPriceType()>
		<cfset Base_Price = Program_Bracket_Price_CS />
	<cfelseif (Program_Details.Use_Fixed_Price_As_Base_Sales OR Program_Details.Market_Price) AND Program_Fixed_Price_CS GT 0>
		<cfset Base_Price = Program_Fixed_Price_CS />
	<cfelse>
		<!--- Get Base Price for a Customer/Product Combo --->
		<CFQUERY NAME="getBasePriceFromgrossMargin" datasource="#application.datasource#">
			SELECT 
				CASE #Product_Details.Item_Deliverytype#
				WHEN 2 
						-- Bcoz of duplicate records, we are using AVG
					THEN
						AVG(CS_FOB_Price) 
				ELSE
						AVG(CS_DEL_Price)
				END
				As CS_Price
			FROM 	gross_Margin
			WHERE 	Customer_ID = '#Customer_ID#'
			AND 	product_id = '#replace(ItemId, "_", "-", "ALL")#'
			AND 	Deleted =0
		</CFQUERY>
	
		<cfif getBasePriceFromgrossMargin.recordcount eq 0 or getBasePriceFromgrossMargin.CS_Price eq "">
				<!--- Get Base Price for a Product (If record not found in Gross Margin) --->
			<cfset Base_Price = getBasePrice.CS_Price>
		<cfelse>
			<cfset  Base_Price = getBasePriceFromgrossMargin.CS_Price>
		</cfif>

	</cfif> 
	**************************************************************************************************************************
			TODO
	**************************************************************************************************************************--->
	
<!---	<cffunction name="getProductAttrs" returntype="Struct" access="remote">
		<cfargument name="programId" default="0">
		<cfargument name="TemplateFiltersID" default = "0">
		<cfargument name="FirstParentID" default="0">
		<cfscript>
			var x = '';
			
			var ProductGroupAttributeManager = CreateObject("component", "components.products.group.ProductGroupAttributeManager").init();
  			var qGetProdGrpAttrsTemplate = ProductGroupAttributeManager.getProductGroupAttributesGroupTemplate(active=1,FirstParentID=arguments.FirstParentID);
		</cfscript>
		
		<cfquery name="GetSettings" datasource="#application.datasource#">

		</cfquery>
	</cffunction>--->
	
</cfcomponent>
