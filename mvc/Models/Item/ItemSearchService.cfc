

<cfcomponent name="ItemSearchService" displayname="ItemSearchService" hint="Search Products" extends="mvc.Models.SettingsService">
	<cfset appSettings = application.appSettingsGet />
	<cffunction name="getItems" hint="return all products" access="remote" output="false" returntype="Array">
		<cfargument name="ProgramId" default="0">
		<cfargument name="DiscountTypeId" default="0">
	    <cfargument name="StatusFilterOn" default ="0">
			<cfset var arrRet = ArrayNew(1)>
			<cfset var qGetItems =  queryNew('tmp')>
			<cfset var businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
			<cfset var busSegIdForProgram = 0 />
			<cfset startTime = getTickCount() />
			<!--- <cflog text="start :: #now()# 0000000000000000000000" > --->
			<cfif businessSegManager.isEnabled()>
				<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(arguments.programId) />
			</cfif>
	        <cfif not IsDefined("Get_Profile_Settings")>
		  <cfinclude template="/get_access_profile.cfm">
		</cfif>
			 <!---   <cfif not isdefined("session.qGetItems")> --->
				<CFQUERY NAME="qGetItems" datasource="#application.datasource#">
        				
						IF object_id('tempdb..##tmpProducts') IS NOT NULL
						DROP TABLE ##tmpProducts

						CREATE TABLE ##tmpProducts
						(BSA_Foodservice_Items_Master_ID varchar(37), Product_Type_ID int)

						CREATE CLUSTERED INDEX IX_TmpProducts
    					ON ##tmpProducts (Product_Type_ID, BSA_Foodservice_Items_Master_ID)

						<!--- This temp table is used to find out which products exist in which discount types --->
						INSERT ##tmpProducts
						SELECT BSA_Foodservice_Items_Master_ID, Product_Type_ID
						FROM Contract_Products
						WHERE Contract_Main_Id = #arguments.ProgramId#
						AND	Deleted = 0

						 SELECT    BSAFIM.BSA_FoodService_Items_Master_ID AS itemGuid,
						 			<!--- CASE 
						 			WHEN CP.Contract_Products_ID > 0 THEN
						 			 	1 
						 			ELSE
						 			 	0
						 			END 
						 			0 AS isSelected,--->
						             <!--- <cfif i NEQ 1>'#i#' + </cfif> --->
						           rTrim(lTrim(BSAFIM.Item)) AS baItem, 
						           BSAFIM.Description, 
						           rTrim(lTrim(isNull(B.Brand_Name,''))) AS Brand_Name,
						           rTrim(lTrim(isNull(QB.Q_Brand,''))) AS Q_Brand,
						           rTrim(lTrim(isNull(TCD.Type_Code_Desc,''))) AS Type_Code_Desc,
						           rTrim(lTrim(isNull(TGD.Type_Group_Desc,''))) AS Type_Group_Desc,			 
											CASE 
												WHEN tmpFixed.Product_Type_ID = 1 THEN 
													1
												ELSE 
													0
											END 
									AS Fixed_Price_Included,
									
											CASE 
												WHEN tmpRebate.Product_Type_ID = 2 THEN 
													1
												ELSE 
													0
											END
									AS Rebate_Included,
									
											CASE 
												WHEN tmpLumpSum.Product_Type_ID = 3 THEN 
													1
												ELSE 
													0
											END
									 AS LumpSum_Included,
									 
											CASE 
												WHEN tmpGrowth.Product_Type_ID = 4 THEN 
													1
												ELSE 
													0
											END
									 AS Growth_Included,
									 
											CASE 
												WHEN tmpBidRequest.Product_Type_ID = 10 THEN 
													1
												ELSE 
													0
											END
									 AS BidRequest_Included
                   <!--- <cfif (arguments.StatusFilterOn EQ 1)> --->
                   ,CASE 
										WHEN Active_code = 'A' THEN 'Active'
										ELSE 'In-Active'
										END
									AS Item_Status
                  <!---  </cfif> --->
				
						  FROM	      BSA_FoodService_Items_Master BSAFIM 
						  LEFT JOIN  Brand B ON 
						  		B.Brand_ID = BSAFIM.Brand_ID
						  LEFT JOIN  Q_Brand_Desc QB ON 
						  		QB.Q_Brand_ID = BSAFIM.Q_Brand_ID
						  LEFT JOIN  Type_Code_Desc TCD ON 
						  		TCD.Type_Code_Desc_ID = BSAFIM.Type_Code_Desc_ID
						  LEFT JOIN  Type_Group_Desc TGD ON 
						  		TGD.Type_Group_Desc_ID = BSAFIM.Type_Group_Desc_ID
						  	<!--- is it on a FIXED comp for this contract --->	
						  LEFT JOIN ##tmpProducts tmpFixed ON
						  		tmpFixed.Product_Type_ID = 1 AND
						  		tmpFixed.BSA_FoodService_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_Id
						  		
						  	<!--- is it on a REBATE comp for this contract --->	
						  LEFT JOIN ##tmpProducts tmpRebate ON
						  		tmpRebate.Product_Type_ID = 2  AND
						  		tmpRebate.BSA_FoodService_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_Id
						  		
						  	<!--- is it on a LUMP SUM comp for this contract --->	
						  LEFT JOIN ##tmpProducts tmpLumpSum ON
						  		tmpLumpSum.Product_Type_ID = 3 AND
						  		tmpLumpSum.BSA_FoodService_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_Id
						  		
						  	<!--- is it on a GROWTH comp for this contract --->	
						  LEFT JOIN ##tmpProducts tmpGrowth ON
						  		tmpGrowth.Product_Type_ID = 4 AND
						  		tmpGrowth.BSA_FoodService_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_Id
						  		
						  	<!--- is it on a BID REQUEST comp for this contract --->	
						  LEFT JOIN ##tmpProducts tmpBidRequest ON
						  		tmpBidRequest.Product_Type_ID = 10 AND
						  		tmpBidRequest.BSA_FoodService_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_Id
						  		
						  <!--- LEFT JOIN	Contract_Products CP ON
						  		CP.Contract_Main_Id = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer"> AND
						  		CP.BSA_Foodservice_Items_Master_ID = BSAFIM.BSA_FoodService_Items_Master_ID AND
							  		CP.Product_Type_ID = #arguments.DiscountTypeId# and<!--- <cfqueryparam value="#arguments.DiscountTypeId#" cfsqltype="cf_sql_integer"> AND --->
						  		CP.Deleted = 0 --->
						  WHERE       BSAFIM.DELETED = 0 
						 <cfif (arguments.StatusFilterOn EQ 0)> AND         BSAFIM.ACTIVE_CODE = 'A'</cfif>
						  AND 		  BSAFIM.Item IS NOT NULL <cfif (appSettings.getSearchInactiveProductsInPrograms() EQ 0) OR Get_Profile_Settings.Search_Inactive_Products_Programs EQ 0> AND (BSAFIM.ACTIVE_CODE = 'A') </cfif>
						  <!--- Restrictions are built seperateley and returned via savecontent this.searchSettings()  --->
						  #searchSettings(arguments.ProgramId)#

					IF object_id('tempdb..##tmpProducts') IS NOT NULL
					DROP TABLE ##tmpProducts
				  </CFQUERY>
				 <cfset loopstartTime = getTickCount() />
				<cfloop query="qGetItems">
					<cfscript>
						stData = structNew();
						stData["__type__"] = "mvc.Models.Item.vos.ItemGridData";
						stData["itemGuid"] = qGetItems.itemGuid;
						stData["isSelected"] = "";
						stData["baItem"] = qGetItems.baItem;
						stData["Description"] = qGetItems.Description;
						stData["Brand_Name"] = qGetItems.Brand_Name;
						stData["Q_Brand"] = qGetItems.Q_Brand;
						stData["Type_Code_Desc"] = qGetItems.Type_Code_Desc;
						stData["Type_Group_Desc"] = qGetItems.Type_Group_Desc;
						stData["Fixed_Price_Included"] = qGetItems.Fixed_Price_Included;
						stData["Rebate_Included"] = qGetItems.Rebate_Included;
						stData["LumpSum_Included"] = qGetItems.LumpSum_Included;
						stData["Growth_Included"] = qGetItems.Growth_Included;
						stData["BidRequest_Included"] = qGetItems.BidRequest_Included;
            //if(StatusFilterOn EQ 1)
           // {
              stData["Item_Status"] = qGetItems.Item_Status;
            // }
            ArrayAppend(arrRet, duplicate(stData));
					</cfscript>
				</cfloop>
				 <!--- <cfset endTime = getTickCount() />
				 <cfset loopelapseTime = endTime - loopstartTime>
				 <cfset queryelapseTime = loopstartTime - startTime>
				 <cfset totelapseTime = endTime - startTime>
				 <cflog text="queryTime: #queryelapseTime# :: loopTime: #loopelapseTime# " />
				 <cflog text="TotTime : #totelapseTime#  :: end : #now()#  XXXXXXXXXXXXXXXX" /> --->

			 <cfreturn arrRet />
			
	</cffunction>
	
	<cffunction name="getCompItems" hint="return all products" access="remote" output="false" returntype="Array">
		<cfargument name="ProgramId" default="0">
		<cfargument name="DiscountTypeId" default="0">
    	<cfargument name="StatusFilterOn" default ="0">
    	<cfargument name="bAll" default = "true">
    	<cfargument name="bMP" default = "false">
		<cfargument name="TemplateFiltersID" default = "0">
		<cfargument name="sItemSearch" default = "">
		
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
			//this.dmp(arguments);
			appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings();
		</cfscript>
		<cfif not IsDefined("Get_Profile_Settings")>
		  <cfinclude template="/get_access_profile.cfm">
		</cfif>
		<cfquery name="GetSettings" datasource="#application.datasource#">
			SELECT PCPO.Discount_Rebates_Group_Level,
					exclude_sig_products,
					modifying_program,
					EZButton_On,
					EZ_Contract_Id,
					First_Parent_Id,
					Contract_Main.Template_Filters_Id
			FROM Contract_Main
			INNER JOIN	Program_Control_Panel_Options PCPO ON 
				Contract_Main.ProgramType_ID = PCPO.ProgramControl_Panel_Options_ID
			WHERE Contract_Main_ID = <cfqueryparam value="#arguments.ProgramId#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfif GetSettings.recordcount>
			<cfset FirstParentId = GetSettings.First_Parent_Id />
			<cfset varTemplateFiltersID = GetSettings.Template_Filters_Id />
		<cfelse>
			<cfset varTemplateFiltersID = arguments.TemplateFiltersID />
		</cfif>
		<!---<cfif isnumeric(arguments.TemplateFiltersID) AND arguments.TemplateFiltersID NEQ 0 >
			<cfquery name="GetTemplateId" datasource="#application.datasource#">
				SELECT Template_Id 
				FROM Template_Filters
				WHERE Template_Filters_Id = <cfqueryparam value="#arguments.TemplateFiltersID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset FirstParentId = GetTemplateId.Template_Id />
			<cfset varTemplateFiltersID = arguments.TemplateFiltersID />
		<cfelse>
			<cfset varTemplateFiltersID = GetSettings.Template_Filters_Id />
		</cfif>--->

			<cfif businessSegManager.isEnabled()>
				<cfset busSegIdForProgram = businessSegManager.getSegmentIdByProgram(arguments.programId) />
			</cfif>
			 <!---   <cfif not isdefined("session.qGetItems")> --->
				<CFQUERY NAME="qGetItems" datasource="#application.datasource#">

						 SELECT DISTINCT BSAFIM.BSA_FoodService_Items_Master_ID AS itemGuid,
						           rTrim(lTrim(BSAFIM.Item)) AS baItem, 
						           BSAFIM.Description, 
						           rTrim(lTrim(isNull(B.Brand_Name,''))) AS Brand_Name,
						           rTrim(lTrim(isNull(QB.Q_Brand,''))) AS Q_Brand,
						           rTrim(lTrim(isNull(TCD.Type_Code_Desc,''))) AS Type_Code_Desc,
						           rTrim(lTrim(isNull(TGD.Type_Group_Desc,''))) AS Type_Group_Desc
                   <!--- <cfif (arguments.StatusFilterOn EQ 1)> --->
                   					,CASE 
										WHEN Active_code = 'A' THEN 'Active'
										ELSE 'In-Active'
										END
									AS Item_Status,
                  <!---  </cfif> --->
							0 AS volume,
						<cfif iMPId>
							MPR.rate AS Market_Price,
							MPR.Uom_Id,
							UOM.Abbreviation_Singular,
							UOM.Unit_of_Measure_Desc_Singular,
							CASE 
								WHEN MPR.Uom_Id = 2 THEN CAST(MPR.Rate * BSAFIM.Net_Weight AS DECIMAL(18,4))
								ELSE MPR.Rate
							END AS Market_Price_Rate_CS,
							CASE 
								WHEN MPR.Uom_Id = 1 THEN CAST(MPR.Rate / BSAFIM.Net_Weight AS DECIMAL(18,4))
								ELSE MPR.Rate
							END AS Market_Price_Rate_LB
						<cfelse>
							'' AS Market_Price,
							0  AS Uom_Id,
							'' AS Abbreviation_Singular,
							'' AS Unit_of_Measure_Desc_Singular,
							0 AS Market_Price_Rate_CS,
							0 AS Market_Price_Rate_LB
						</cfif>
						  FROM	      BSA_FoodService_Items_Master BSAFIM 
						  LEFT JOIN  Brand B ON 
						  		B.Brand_ID = BSAFIM.Brand_ID
						  LEFT JOIN  Q_Brand_Desc QB ON 
						  		QB.Q_Brand_ID = BSAFIM.Q_Brand_ID
						  LEFT JOIN  Type_Code_Desc TCD ON 
						  		TCD.Type_Code_Desc_ID = BSAFIM.Type_Code_Desc_ID
						  LEFT JOIN  Type_Group_Desc TGD ON 
						  		TGD.Type_Group_Desc_ID = BSAFIM.Type_Group_Desc_ID
						<cfif iMPId>
							LEFT JOIN Market_Price_List MP ON
								MP.Market_Price_List_Id = #iMPId#
							LEFT JOIN Market_Price_Product_Rates MPR ON
								MP.Market_Price_List_Id = MPR.Market_Price_List_Id AND
								MPR.BSA_Foodservice_Items_Master_Id = BSAFIM.BSA_FoodService_Items_Master_ID
							LEFT JOIN Units_of_Measure UOM ON
								UOM.Unit_Of_Measure_ID = MPR.Uom_Id
						</cfif>
						<cfif NOT bAll>
							#this.searchPGJoin(FirstParentId,varTemplateFiltersID)#
						</cfif>	
						  WHERE       BSAFIM.DELETED = 0
						 <cfif (appSettings.getSearchInactiveProductsInPrograms() EQ 0) OR Get_Profile_Settings.Search_Inactive_Products_Programs EQ 0> AND (BSAFIM.ACTIVE_CODE = 'A') </cfif>
						  AND 		  BSAFIM.Item IS NOT NULL
						  <!--- Restrictions are built seperateley and returned via savecontent this.searchSettings()  --->
						  <cfif NOT bAll>
						  	<cfif NOT arguments.bMp>
						  		#searchSettings(arguments.ProgramId)#
						  	</cfif>
						  	#this.searchPGWhere(FirstParentId,varTemplateFiltersID)#
						  </cfif>
						  <CFif sItemSearch NEQ ''>
						  	  AND(
									BSAFIM.Item like '%#sItemSearch#%' OR 
									BSAFIM.Description like '%#sItemSearch#%' OR
									B.Brand_Name like '%#sItemSearch#%' OR
									QB.Q_Brand like '%#sItemSearch#%' OR
									TCD.Type_Code_Desc like '%#sItemSearch#%' OR
									TGD.Type_Group_Desc like '%#sItemSearch#%'
								 )
						  </CFIF>
						  ORDER BY  baItem, itemGuid
					<!---IF object_id('tempdb..##tmpProducts') IS NOT NULL
					DROP TABLE ##tmpProducts--->
				  </CFQUERY>	  
				<!---<cfif NOT bAll>
				  	<cfdump var="#qGetItems#" output="c:\dump.log" >
				  </cfif>--->
				<cfloop query="qGetItems">
					<cfif bAll>
						<cfscript>
							stUomData = structNew();
							stUomData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
							stUomData["uomId"] = qGetItems.Uom_Id;
							stUomData["description"] = qGetItems.Unit_of_Measure_Desc_Singular;
							stUomData["abbreviation"] = qGetItems.Abbreviation_Singular;
					
							stData = structNew();
							stData["__type__"] = "mvc.Models.Item.vos.Item";
							stData["itemGuid"] = qGetItems.itemGuid;
							stData["isSelected"] = "";
							stData["baItem"] = qGetItems.baItem;
							stData["Description"] = qGetItems.Description;
							stData["Brand_Name"] = qGetItems.Brand_Name;
							stData["Q_Brand"] = qGetItems.Q_Brand;
							stData["Type_Code_Desc"] = qGetItems.Type_Code_Desc;
							stData["Type_Group_Desc"] = qGetItems.Type_Group_Desc;
							stData["Item_Status"] = qGetItems.Item_Status;
							stData["volume"] = qGetItems.volume;
							stData["uomMP"] = stUomData;
	            			ArrayAppend(arrRet, duplicate(stData));
						</cfscript>
					<cfelse>
						<cfscript>
							stUomData = structNew();
							stUomData["__type__"] = "mvc.Models.Program.Component.vos.Uom";
							stUomData["uomId"] = qGetItems.Uom_Id;
							stUomData["description"] = qGetItems.Unit_of_Measure_Desc_Singular;
							stUomData["abbreviation"] = qGetItems.Abbreviation_Singular;
							
							stData = structNew();
							stData["uomMP"] = stUomData;
							stData["itemGuid"] = qGetItems.itemGuid;
							stData["marketPrice"] = qGetItems.Market_Price;
							stData["marketPriceCS"] = qGetItems.Market_Price_Rate_CS;
							stData["marketPriceLB"] = qGetItems.Market_Price_Rate_LB;
							ArrayAppend(arrRet, stData);
						</cfscript>
					</cfif>
				</cfloop>
				<!--- <cfset this.dmp(qGetItems) /> --->
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
		
		
		<!--- <cfdump var="#qGroupsInTemplate#"/> --->
		
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