<!---
This file may be called from trade planner or from program volume. If called from trade planner, there is no database information. Therefore this page has no program specific database calls.

To access a variable from a program:
1) The query should be located in ProgramVolume.cfc (components/programs/volume/programVolume.cfc)
2) Initialize variable with default value in setDefaults()
3) Create method setting variable (or add variable to existing method)
4) You may now call the variable from VolumeApplicator.cfc
--->


<!---xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
This component will hold a volume packet.
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx---->
<cfcomponent displayname="Build Volume Packet" hint="Build Volume Packet">
	<cfset this.packetId 			= "">
	<cfset this.packetLocation 		= "">
	<cfset this.appRelativeLocation = "\Temp_Files\Volume">
	<cfset this.fileExtension 		= "txt">
	<cfset this.volumePacket 		= StructNew()>
	<cfset this.volumePacket.volumeUOT	= 0 />
	<cfset this.volumePacket.volumeMultiplier	= 0 />
	
	<cfset ProductGroupManager = CreateObject("component", "components.programs.products.ProductGroupManager").init() />
	
	<!----------------- init() -------------------->
   	<cffunction name="init" output="true" hint="init" returntype="string">
		<cfargument name="packetId" type="string" required="true" default="">
		<cfargument name="readWriteMode" type="numeric" required="true" default="">
		<!------ 0=read, 1=write ----->
		
		<cfset this.packetId = Trim(arguments.packetId)>
		
		<!------ Build the physical path ----->
		<cfset this.packetRelativePath	= this.getPacketPath()>
		<cfset this.packetLocation = request.app_general_functions.Get_Document_Path()>
		<cfset this.packetLocation		= this.packetLocation&"\"&this.packetRelativePath>
		<!------ check whether the packetId is valid  ----->
		<cfif compareNoCase(this.packetId, "")>
			<cfif not fileExists(this.packetLocation)>
				<cfset this.packetId = "">
			</cfif>
		</cfif>
		
		<!---- initialise the packet ----->
		<cfif compareNoCase(this.packetId, "")>
			<!------ file exists ----->
			<cfset this.volumePacket = request.app_general_functions.getWddxDataFromFile(this.packetRelativePath)>
			<cfif arguments.readWriteMode EQ 1>
				<!------ clear unnecessary ones ----->
				<cfset this.volumePacket.products				= ArrayNew(1)>
				<cfset this.volumePacket.proudctsNotInForecast	= 0>
				
				<cfset this.volumePacket.forecastInfo 						= StructNew()>
				<cfset this.setForecastInfoDefaults()>
			</cfif>
		<cfelse>
			<!------ file does not exist ----->
			<cfscript>
				setDefaults();
			</cfscript>			
		</cfif>
		
		<cfreturn this.packetId>
	</cffunction>
	
	<!----------------- getVolumePacket() -------------------->
   	<cffunction name="getVolumePacket" output="false" hint="getVolumePacket">
		<cfreturn this.volumePacket>
	</cffunction>
	
	<!----------------- setVolumePacket() -------------------->
   	<cffunction name="setVolumePacket" output="false" hint="setVolumePacket">
	
		<cfargument name="volumePacket" type="struct" required="true" default="">
		
		<cfset this.volumePacket = arguments.volumePacket>
		
	</cffunction>
	
	
	<!----------------- setDefaults() -------------------->
   	<cffunction name="setDefaults" output="false" hint="setDefaults">
		<!---- set the dafaults to properties like, uom, canDoForecast etc. ----->
		<cfset this.volumePacket.forecastId				= 0>
		<cfset this.volumePacket.canDoForecast			= 1>
		<cfset this.volumePacket.canDoForecastString	= "">
		<cfset this.volumePacket.canDoClaimForecast		= 0>
		<cfset this.volumePacket.uom					= 1>
		<cfset this.volumePacket.totalQuantity			= 0>
		<cfset this.volumePacket.avgQuantityApplicator	= 0>
		
		<cfset this.volumePacket.canSaveTotalQuantity	= 0>
		<cfset this.volumePacket.allProductsSelected	= 0>
		<cfset this.volumePacket.allDistributorsSelected= 0>
		
		<cfset this.volumePacket.products				= ArrayNew(1)>
		<cfset this.volumePacket.appAreaStartDate		= Now()>
		<cfset this.volumePacket.appAreaEndDate			= Now()>
		<cfset this.volumePacket.appAreaSpan 			= dateDiff("d", this.volumePacket.appAreaStartDate, this.volumePacket.appAreaEndDate) + 1>
		
		<cfset this.volumePacket.appAreaTitle			= "">
		<cfset this.volumePacket.appAreaReturnToFile	= "">
		
		<cfset this.volumePacket.saveTotalVolume		= 0>
		<cfset this.volumePacket.volumeAction			= "">
		<cfset this.volumePacket.action					= "forecast">
		
		<cfset this.volumePacket.showVolumeCap			= 0>
		<cfset this.volumePacket.VolumeCapRequired			= 0>		
		
		<cfset this.volumePacket.proudctsNotInForecast	= 0>
		
		<cfset this.volumePacket.distributorsNotInAppArea = 0>
		<cfset this.volumePacket.distributorsNotInForecast = 0>
		
		<!---Allow zero volume--->
		<cfset this.volumePacket.ZeroVolume = 0>
		<cfset this.volumePacket.productsWithZeroVolume = 0>
		
		<cfset this.volumePacket.bVolumeAtGroupLevel = 0>
		
		<cfset this.volumePacket.forecastInfo 						= StructNew()>
		<cfset this.setForecastInfoDefaults()>
		
		<cfscript>
			this.setAppAreaId(1, "");
		</cfscript>
	</cffunction>
	
	<!----------------- setForecastInfoDefaults() -------------------->
   	<cffunction name="setForecastInfoDefaults" output="false" hint="setForecastInfoDefaults">
		<cfset this.volumePacket.forecastInfo.priorForecast 		= false>
		<cfset this.volumePacket.forecastInfo.appAreaStartDate 		= "">
		<cfset this.volumePacket.forecastInfo.appAreaEndDate 		= "">
	</cffunction>
	
	<!----------------- addDistributors() -------------------->
   	<cffunction name="addDistributors" output="false" hint="addDistributors">
		<cfargument name="distributorIds" type="string" required="true" default="">
		<!---- add all the distributors ----->
		<cfset 	this.volumePacket.distributors			= ListToArray(arguments.distributorIds, ",")>

		<cfset this.volumePacket.distributorsNotInAppArea = 0>
		<cfset this.volumePacket.distributorsNotInForecast = 0>
			
		<cfif this.volumePacket.forecastId NEQ 0>
			<cfquery name="Distributor_In_Forecast_Not_In_AppArea" datasource="#application.datasource#">
				SELECT	DISTINCT Distributor_ID
				FROM	Forecast_Distributor						
				WHERE				
						Forecast_ID = #this.volumePacket.forecastId#
						AND
						<cfif Len(arguments.distributorIds) GT 0>
						Distributor_ID NOT IN (#ListQualify(arguments.distributorIds, "'", ",")#)
						<cfelse>
						1=1
						</cfif>
						
			</cfquery>
			
			<cfquery name="Distributor_In_Forecast_And_In_AppArea" datasource="#application.datasource#">
				SELECT	DISTINCT Distributor_ID
				FROM	Forecast_Distributor						
				WHERE				
						Forecast_ID = #this.volumePacket.forecastId#
						AND
						<cfif Len(arguments.distributorIds) GT 0>
						Distributor_ID IN (#ListQualify(arguments.distributorIds, "'", ",")#)
						<cfelse>
						1=2
						</cfif>
			</cfquery>
			
			<cfset this.volumePacket.distributorsNotInAppArea = Distributor_In_Forecast_Not_In_AppArea.recordCount>
			<cfset this.volumePacket.distributorsNotInForecast = ListLen(arguments.distributorIds, ",") - Distributor_In_Forecast_And_In_AppArea.recordCount>
		</cfif>
		
		
	</cffunction>
	
	<!----------------- addOperators() -------------------->
   	<cffunction name="addOperators" output="false" hint="addOperators">
		<cfargument name="operatorIds" type="string" required="true" default="">
		<!---- add operators ----->
		<cfset 	this.volumePacket.operators			= ListToArray(arguments.operatorIds, ",")>		
	</cffunction>
	
	<!----------------- addProduct() -------------------->
   	<cffunction name="addProduct" output="false" hint="addProduct">
		<cfargument name="productId" type="string" required="true" default="">
		<cfargument name="productVolume" type="numeric" required="true" default="">
		<cfargument name="productVolumeCap" type="string" required="false" default="">
		<cfargument name="groupingName" type="string" required="false" default="">
		<cfargument name="groupingId" type="string" required="false" default="">
		<cfargument name="isGroup" type="string" required="false" default="">
		<cfargument name="isPartOfGroup" type="string" required="false" default="">
		
		<!---- add all the distributors ----->
		<cfscript>
			ArrayAppend(this.volumePacket.products, 
						buildProductStruct(arguments.productId, arguments.productVolume, arguments.productVolumeCap, arguments.groupingName, arguments.groupingId, arguments.isGroup, arguments.isPartOfGroup)
						);
		</cfscript>		
	</cffunction>
	
	<!----------------- getForecastVolumeInfo() -------------------->
   	<cffunction name="getForecastVolumeInfo" output="false" hint="getForecastVolumeInfo">
		<cfif this.volumePacket.forecastId NEQ 0>
			<cfquery name="qForecastVolumeInfo" datasource="#application.datasource#">
				SELECT	Forecast_Product.Product_ID,
						ISNULL(<cfif this.volumePacket.uom EQ 1>
						Forecast_Volume.Volume_CS
						<cfelse>
						Forecast_Volume.Volume_LB
						</cfif>, 0) as forecastVolume
				FROM	Forecast_Product
						LEFT JOIN Forecast_Volume
						ON
						Forecast_Volume.Product_ID = Forecast_Product.Product_ID
						AND
						Forecast_Volume.Forecast_ID = Forecast_Product.Forecast_ID
				WHERE
						Forecast_Product.Forecast_ID = #this.volumePacket.forecastId#
			</cfquery>
		</cfif>
	</cffunction>
	
	
	<!----------------- buildProductStruct() -------------------->
   	<cffunction name="buildProductStruct" output="true" hint="buildProductStruct">
		<cfargument name="productId" type="string" required="true" default="">
		<cfargument name="productVolume" type="numeric" required="true" default="">
		<cfargument name="productVolumeCap" type="string" required="false" default="">
		<cfargument name="groupingName" type="string" required="false" default="">
		<cfargument name="groupingId" type="string" required="false" default="">
		<cfargument name="isGroup" type="string" required="false" default="">
		<cfargument name="isPartOfGroup" type="string" required="false" default="">
		
		<cfset This_Net_Weight = 1 />
		
		<cfset doQuery = true>
		<cfif this.volumePacket.forecastId EQ 0>			
			<!------ no previous forecast ----->
			<cfif IsDefined("this.MainProductsQuery")>
				<!---- whole product info query already exist ----->
				<!------ get more info ----->
				<cfquery name="getProductInfo" dbtype="query">
					SELECT	Item, UPC, Description, Net_Weight,
							forecastVolume, doneForecast, 
							ProductUOM
					FROM	this.MainProductsQuery
					WHERE
							BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
				</cfquery>
				
				<cfset This_Net_Weight = getProductInfo.Net_Weight />
				
				<cfset doQuery = false>
			</cfif>
		</cfif>
		
		<cfif doQuery>
			<!------ get more info ----->
			<cfquery name="getProductInfo" datasource="#application.datasource#">
				SELECT	Item, UPC, Description, CAST(Net_Weight AS Float) as Net_Weight,
						Inventory_UM ProductUOM
				FROM	BSA_Foodservice_Items_Master						
				WHERE
						BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = '#arguments.productId#'
			</cfquery>
			
			<cfset This_Net_Weight = getProductInfo.Net_Weight />
			
		</cfif>
		
		<cfset qProductGroupLevel = ProductGroupManager.getGroupFromProduct(arguments.productId, 1) />
		<cfif qProductGroupLevel.Product_Group_Level_ID EQ 1>
			<cfset getGroupProductInfo = ProductGroupManager.getProductGroupDetails(qProductGroupLevel.Product_Group_Level_ID, qProductGroupLevel.Product_Group_ID) />
			<cfset getProductInfo.Description = getGroupProductInfo.Description />
			<cfset getProductInfo.Item = getGroupProductInfo.Item />
			<cfset getProductInfo.UPC = getGroupProductInfo.UPC />
		</cfif>
		
		<cfset doneForecast = 0>
		<cfset forecastVolume = 0>
		<cfif isDefined("qForecastVolumeInfo")>
			<cfset useLakebaseForGet_Forecast_Volume = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qforecastvolumeinfo")>
<cfif useLakebaseForGet_Forecast_Volume>
	<cftry>
		<cfset Get_Forecast_Volume = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qforecastvolumeinfo", {
				"product_id" = "eq.#arguments.productId#",
				"select" = "forecastvolume"
			}), "forecastvolume"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Forecast_Volume = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Forecast_Volume>
<CFQUERY NAME="Get_Forecast_Volume" dbtype="query">
				SELECT	forecastVolume
				FROM	qForecastVolumeInfo
				WHERE
						Product_ID = '#arguments.productId#'
			</CFQUERY>
</cfif>
			<cfif Get_Forecast_Volume.RecordCount GT 0>
				<cfset doneForecast = 1>
				<cfset forecastVolume = Get_Forecast_Volume.forecastVolume>
			</cfif>
		</cfif>
		
		<!---- add this product ----->
		<cfset 	prodStruct					= StructNew()>
		<cfset 	prodStruct.productId		= arguments.productId>
		<cfset 	prodStruct.productVolume	= arguments.productVolume>
		<cfset 	prodStruct.productVolumeCap	= arguments.productVolumeCap>
		<cfset 	prodStruct.productGroupLevel= qProductGroupLevel.Product_Group_Level_ID>
		<cfset 	prodStruct.item				= getProductInfo.item>
		<cfset 	prodStruct.upc				= getProductInfo.upc>
		<cfset 	prodStruct.description		= getProductInfo.description>
		<cfset 	prodStruct.netWeight		= This_Net_Weight>
		<cfset 	prodStruct.productUOM		= getProductInfo.ProductUOM>
		<cfset 	prodStruct.groupName		= arguments.groupingName>
		<cfset 	prodStruct.groupId			= arguments.groupingId>
		<cfset 	prodStruct.isGroup			= arguments.isGroup>
		<cfset 	prodStruct.isPartOfGroup	= arguments.isPartOfGroup>
		<cfset 	prodStruct.forecastVolume	= forecastVolume>
		<cfset 	prodStruct.doneForecast		= 1>
		<cfif doneForecast EQ 0>
			<cfset 	prodStruct.doneForecast		= 0>
			<cfset 	this.volumePacket.proudctsNotInForecast	= this.volumePacket.proudctsNotInForecast + 1>
		</cfif>
		<cfset 	prodStruct.claimVolume	= 0>
		<cfreturn prodStruct>
	</cffunction>
	
	<!----------------- forecastGood() -------------------->
	<cffunction name="forecastGood" output="false" hint="forecastGood">
		<cfset forecastGood = true>
		<cfif this.volumePacket.proudctsNotInForecast GT 0>
			<cfset forecastGood = false>
		</cfif>
		<cfif this.volumePacket.distributorsNotInAppArea GT 0>
			<cfset forecastGood = false>
		</cfif>
		<cfif this.volumePacket.distributorsNotInForecast GT 0>
			<cfset forecastGood = false>
		</cfif>
		<cfreturn forecastGood>
   	</cffunction>
	
	<!----------------- getForecastId() -------------------->
   	<cffunction name="saveVolumePacket" output="false" hint="saveVolumePacket">
		<cfif not compareNoCase(this.packetId, "")>
			<cfset this.packetId = request.app_general_functions.replaceHyphen(createUUID())>
			<cfset this.packetRelativePath	= this.getPacketPath()>
		</cfif>
		<cfscript>
			request.app_general_functions.writeWddxDataToFile(this.volumePacket, this.packetRelativePath);
		</cfscript>
		
		<cfreturn this.packetId>
	</cffunction>
	
	<!----------------- getPacketPath() -------------------->
   	<cffunction name="getPacketPath" output="false" hint="getPacketPath">
	
		<cfset this.appRelativeLocation = REReplaceNoCase(this.appRelativeLocation, "\\$", "")>
		<cfset this.appRelativeLocation = REReplaceNoCase(this.appRelativeLocation, "^\\", "")>
		<cfreturn this.appRelativeLocation & "\" & this.packetId & "." & this.fileExtension>
		
	</cffunction>
	
	<!----------------- setForecastId() -------------------->
   	<cffunction name="setForecastId" output="false" hint="setForecastId">
		
		<cfargument name="forecastId" type="numeric" required="true" default="">
		
		<cfset this.volumePacket.forecastId = arguments.forecastId>
		<cfif this.volumePacket.forecastId NEQ 0>
			<cfset this.volumePacket.forecastInfo.priorForecast = true>
			<cfset this.loadForecastBasicInfo()>
			<cfif NOT isDefined("qForecastVolumeInfo")>
				<cfset this.getForecastVolumeInfo()>
			</cfif>
		</cfif>
		
	</cffunction>
	
	<!----------------- loadForecastBasicInfo() -------------------->
   	<cffunction name="loadForecastBasicInfo" output="false" hint="loadForecastBasicInfo">
		<cfset this.volumePacket.forecastInfo.priorForecast 	= false>
		
		<cfset this.volumePacket.forecastInfo.appAreaStartDate 		= "">
		<cfset this.volumePacket.forecastInfo.appAreaEndDate 		= "">
		<cfif this.volumePacket.forecastId NEQ 0>
			<cfquery name="getForecastInfo" datasource="#application.datasource#">
				SELECT	Forecast_From_Date, Forecast_To_Date, Forecast_Update_Date, _Users.Name_First + ' ' + _Users.Name_Last AS Forecast_User,
						App_Area_Start_Date, App_Area_End_Date
				FROM	Forecast
						LEFT JOIN _Users
						ON
						_Users.User_ID = Forecast.Forecast_Update_User_ID
						AND
						_Users.Deleted = 0
				WHERE
						Forecast.Forecast_ID = #this.volumePacket.forecastId#
			</cfquery>
			<cfif getForecastInfo.recordCount GT 0>
				<cfset this.volumePacket.forecastInfo.priorForecast 			= true>
				<cfset this.volumePacket.forecastInfo.forecastFromDate 		= getForecastInfo.Forecast_From_Date>
				<cfset this.volumePacket.forecastInfo.forecastToDate 		= getForecastInfo.Forecast_To_Date>
				<cfset this.volumePacket.forecastInfo.forecastUpdateDate 	= getForecastInfo.Forecast_Update_Date>
				<cfset this.volumePacket.forecastInfo.forecastUpdateUser 	= getForecastInfo.Forecast_User>
				<cfset this.volumePacket.forecastInfo.forecastSpan 			= DateDiff("d", this.volumePacket.forecastInfo.forecastFromDate, this.volumePacket.forecastInfo.forecastToDate) + 1>
				<cfset this.volumePacket.forecastInfo.appAreaStartDate 		= getForecastInfo.App_Area_Start_Date>
				<cfset this.volumePacket.forecastInfo.appAreaEndDate 		= getForecastInfo.App_Area_End_Date>
			</cfif>
		</cfif>
	</cffunction>
	
	<!----------------- getForecastId() -------------------->
   	<cffunction name="getForecastId" output="false" hint="getForecastId">
	
		<cfreturn this.volumePacket.forecastId>
		
	</cffunction>

	
	<!----------------- setAction() -------------------->
   	<cffunction name="setAction" output="false" hint="setAction">
		
		<cfargument name="action" type="string" required="true" default="">
		
		<cfset this.volumePacket.action = arguments.action>
		
	</cffunction>
	
	<!----------------- setVolumeUOT() -------------------->
   	<cffunction name="setVolumeUOT" output="false" hint="setAction">
		
		<cfargument name="volumeUOT" type="numeric" required="true">
		
		<cfset this.volumePacket.volumeUOT	= arguments.volumeUOT />
		
	</cffunction>
	
	<!----------------- setVolumeMultiplier() -------------------->
   	<cffunction name="setVolumeMultiplier" output="false" hint="setAction">
		
		<cfargument name="volumeMultiplier" type="numeric" required="true">
		
		<cfset this.volumePacket.volumeMultiplier	= arguments.volumeMultiplier />
		
	</cffunction>
	
	<!----------------- setAppAreaId() -------------------->
   	<cffunction name="setAppAreaId" output="false" hint="setAppAreaId">
		<cfargument name="appArea" type="numeric" required="true" default="">
		<cfargument name="appAreaId" type="string" required="true" default="">
		
		<cfset this.volumePacket.appArea		= arguments.appArea>
		<cfif this.volumePacket.appArea eq 1>
			<cfset this.volumePacket.appAreaKeyword			= "program">
		<cfelse>
			<cfset this.volumePacket.appAreaKeyword			= "#application.returned_customer_setting.trade_label# planner">
		</cfif>
		<cfset this.volumePacket.appAreaId 		= arguments.appAreaId>
		
	</cffunction>
	
	<!----------------- getAppAreaId() -------------------->
   	<cffunction name="getAppAreaId" output="false" hint="getAppAreaId">
	
		<cfreturn this.volumePacket.appAreaId>
		
	</cffunction>
	
	<!----------------- setCanDoForecast() -------------------->
   	<cffunction name="setCanDoForecast" output="false" hint="setCanDoForecast">
		<cfargument name="canDoForecast" type="numeric" required="true" default="">
		
		<cfset this.volumePacket.canDoForecast		= arguments.canDoForecast>
		
	</cffunction>
	
	<!----------------- setCanDoForecastString() -------------------->
   	<cffunction name="setCanDoForecastString" output="false" hint="setCanDoForecastString">
		<cfargument name="canDoForecastString" type="string" required="true" default="">
		
		<cfset this.volumePacket.canDoForecastString		= arguments.canDoForecastString>
		
	</cffunction>
	
	<!----------------- setCanDoClaimForecast() -------------------->
   	<cffunction name="setCanDoClaimForecast" output="false" hint="setCanDoClaimForecast">
		<cfargument name="canDoClaimForecast" type="numeric" required="true" default="">
		<cfset this.volumePacket.canDoClaimForecast		= arguments.canDoClaimForecast>
	</cffunction>
	
	
	<!----------------- setAppAreaDates() -------------------->
   	<cffunction name="setAppAreaDates" output="false" hint="setAppAreaDates">
		<cfargument name="appAreaStartDate" type="date" required="true" default="">
		<cfargument name="appAreaEndDate" type="date" required="true" default="">
		
		<cfset this.volumePacket.appAreaStartDate		= arguments.appAreaStartDate>
		<cfset this.volumePacket.appAreaEndDate			= arguments.appAreaEndDate>
		<cfset this.volumePacket.appAreaSpan 			= dateDiff("d", this.volumePacket.appAreaStartDate, this.volumePacket.appAreaEndDate) + 1>
		
	</cffunction>
	
	<!----------------- setUom() -------------------->
   	<cffunction name="setUom" output="false" hint="setUom">
		<cfargument name="uom" type="numeric" required="true" default="0">
		
		<cfset this.volumePacket.uom			= arguments.uom>
		
	</cffunction>
	
	<!----------------- setAvgQuantityApplicator() -------------------->
   	<cffunction name="setAvgQuantityApplicator" output="false" hint="setAvgQuantityApplicator">
		<cfargument name="totalQuantity" type="numeric" required="true" default="0">
		<cfargument name="avgQuantityApplicator" type="numeric" required="false" default="0">
		
		<cfset this.volumePacket.totalQuantity			= arguments.totalQuantity>
		<cfset this.volumePacket.avgQuantityApplicator	= arguments.avgQuantityApplicator>
		
	</cffunction>
	
	<!----------------- setAppAreaTitle() -------------------->
   	<cffunction name="setAppAreaTitle" output="false" hint="setAppAreaTitle">
		<cfargument name="appAreaTitle" type="string" required="true" default="">		
		
		<cfset this.volumePacket.appAreaTitle			= arguments.appAreaTitle>		
	</cffunction>
	
	<!----------------- setShowVolumeCap() -------------------->
   	<cffunction name="setShowVolumeCap" output="false" hint="setShowVolumeCap">
		<cfargument name="showVolumeCap" type="numeric" required="true">
		
		<cfset this.volumePacket.showVolumeCap			= arguments.showVolumeCap>		
	</cffunction>
	
	<!----------------- setAppAreaReturnToFile() -------------------->
   	<cffunction name="setAppAreaReturnToFile" output="false" hint="setAppAreaReturnToFile">
		<cfargument name="appAreaReturnToFile" type="string" required="true" default="">		
		
		<cfset this.volumePacket.appAreaReturnToFile	= arguments.appAreaReturnToFile>
	</cffunction>
	
	<!----------------- setSaveTotalQuantity() -------------------->
   	<cffunction name="setSaveTotalQuantity" output="false" hint="setSaveTotalQuantity">
		<cfargument name="canSaveTotalQuantity" type="numeric" required="true" default="">		
		
		<cfset this.volumePacket.canSaveTotalQuantity	= arguments.canSaveTotalQuantity>
		<cfif this.volumePacket.allProductsSelected>
			<cfset this.volumePacket.canDoForecast			= 0>
		</cfif>
	</cffunction>
	
	<!----------------- setAllProductsSelected() -------------------->
   	<cffunction name="setAllProductsSelected" output="false" hint="setSaveTotalQuantity">
		<cfargument name="allProductsSelected" type="numeric" required="true" default="">		
		
		<cfset this.volumePacket.allProductsSelected	= arguments.allProductsSelected>
		<cfif this.volumePacket.allProductsSelected>
			<cfset this.volumePacket.canDoForecast			= 0>
		</cfif>
	</cffunction>
	
	<!----------------- setAllDistributorsSelected() -------------------->
   	<cffunction name="setAllDistributorsSelected" output="false" hint="setSaveTotalQuantity">
		<cfargument name="allDistributorsSelected" type="numeric" required="true" default="">		
		
		<cfset this.volumePacket.allDistributorsSelected	= arguments.allDistributorsSelected>
		<cfif this.volumePacket.allDistributorsSelected>
			<cfset this.volumePacket.canDoForecast			= 0>
		</cfif>
	</cffunction>
	
	<!----------------- setMainProductsQuery() -------------------->
   	<cffunction name="setMainProductsQuery" output="false" hint="setMainProductsQuery">
		<cfargument name="MainProductsQuery" type="query" required="true" default="">
		
		<cfset this.MainProductsQuery	= arguments.MainProductsQuery>
	</cffunction>	
	
		
	<!----------------- getTemplateSetting() -------------------->
   	<cffunction name="setZeroVolume" output="false" hint="Allow zero volume for an item if 1">
	
		<cfargument name="ZeroVolume" type="boolean" required="false" default="0">
	
		<cfset this.volumePacket.ZeroVolume = arguments.ZeroVolume>
		
	</cffunction>
	
	<!----------------- getTemplateSetting() -------------------->
   	<cffunction name="getZeroVolume" output="false" hint="Return Zero volume">
		<cfreturn this.volumePacket.ZeroVolume />
	</cffunction>
	
	<!----------------- setProductsWithZeroVolume() -------------------->
   	<cffunction name="setProductsWithZeroVolume" output="false" hint="Set the number of products with Zero volume">
		<cfargument name="productsWithZeroVolume" type="numeric" required="false" default="0">
		<cfset this.volumePacket.productsWithZeroVolume = arguments.productsWithZeroVolume>
	</cffunction>
	
	<!----------------- getProductsWithZeroVolume() -------------------->
   	<cffunction name="getProductsWithZeroVolume" output="false" hint="Return Number of products with Zero Volume">
		<cfreturn this.volumePacket.productsWithZeroVolume />
	</cffunction>
	
	<cffunction name="setVolumeAtGroupLevel" output="false" hint="Will let the component know if the current session is applying volume at group level">
	
		<cfargument name="bVolumeAtGroupLevel" type="boolean" required="false" default="0">
	
		<cfset this.volumePacket.bVolumeAtGroupLevel = arguments.bVolumeAtGroupLevel>
		
	</cffunction>
	
	<cffunction name="getVolumeAtGroupLevel" output="false">
		<cfreturn this.volumePacket.bVolumeAtGroupLevel />
	</cffunction>
	
</cfcomponent>
