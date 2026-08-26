<cfparam name="showWaitMessage" default="0">
<cfparam name="autoredirectflag" default="0">
<cfparam name="autoredirectflag_URL" default="index.cfm">
<cfparam name="form.z" default="0">

<!--- Get the expanded path of the CURRENT template path. --->
<cfset docPath = GetDirectoryFromPath(GetCurrentTemplatePath()) />

<cfif isdefined("cgi.HTTP_REFERER")>
	<cfif len(cgi.HTTP_REFERER) GT 0>
		<cfset previousURL = listtoarray(cgi.HTTP_REFERER, "/")>
		<cfif arraylen(previousURL) EQ 5>
			<cfset previousURL = listtoarray(previousURL[5], "?")>
			<cfif lcase(previousURL[1]) EQ "index.cfm">
				<cfset showWaitMessage = 1>
				<cfset autoredirectflag = 1>
			</cfif>
		</cfif>
	</cfif>
</cfif>

<cfif showWaitMessage EQ 1>
	<BODY BGCOLOR="WhiteSmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
		<div align="center" id="waitLoad" style="font-weight: bold; color: red; font-size: 20px">please be patient while the tree is rebuilt to reflect your changes...</div>
	</BODY>
	<cfflush>
</cfif>
<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<cfset positionTreeManager = CreateObject("component", "components.geography.positionTreeManager").init() />
<!---replaced with XmlFormat(string) --->
<cfscript>
	function xmlEscapeString(oString){
		oString_New = oString;
		oString_New = replace(oString_New,"<","&lt;", "ALL");
		oString_New = replace(oString_New,">","&gt;", "ALL");
		oString_New = replace(oString_New,"&","&amp;", "ALL");
		oString_New = replace(oString_New,"'","&apos;", "ALL");
		oString_New = replace(oString_New,'"',"&quot;", "ALL");
		return oString_New;		
	}
</cfscript>

<CFSET thisPositionZone 	= 0>
<CFSET thisPositionRegion 	= 0>
<CFSET thisPositionMarket 	= 0>

<CFINCLUDE TEMPLATE="/settings/get_position_label.cfm">

<!---get zones that are free--->
<cfset useLakebaseForzone_free = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_binder")>
<cfif useLakebaseForzone_free>
	<cftry>
		<cfset zone_free = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_binder", {
				"deleted" = "eq.0",
				"binder_type" = "eq.4"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForzone_free = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForzone_free>
<cfquery name="zone_free" datasource="#application.datasource#">
	SELECT 	* 
	FROM 	user_binder
	WHERE 	Deleted = 0
	AND		binder_type = 4
</cfquery>
</cfif>

<cfset zone_free_list = lcase(valuelist(zone_free.SERVICE_ID))>

<!---get regions that are free--->
<cfset useLakebaseForregion_free = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_binder")>
<cfif useLakebaseForregion_free>
	<cftry>
		<cfset region_free = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_binder", {
				"deleted" = "eq.0",
				"binder_type" = "eq.5"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForregion_free = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForregion_free>
<cfquery name="region_free" datasource="#application.datasource#">
	SELECT 	* 
	FROM 	user_binder
	WHERE 	Deleted = 0
	AND		binder_type = 5
</cfquery>
</cfif>

<cfset region_free_list = lcase(valuelist(region_free.SERVICE_ID))>

<!---get markets that are free--->
<cfset useLakebaseFormarket_free = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("user_binder")>
<cfif useLakebaseFormarket_free>
	<cftry>
		<cfset market_free = application.oLakebase.toQuery(
			application.oLakebase.selectRows("user_binder", {
				"deleted" = "eq.0",
				"binder_type" = "eq.6"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseFormarket_free = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFormarket_free>
<cfquery name="market_free" datasource="#application.datasource#">
	SELECT 	* 
	FROM 	user_binder
	WHERE 	Deleted = 0
	AND		binder_type = 6
</cfquery>
</cfif>

<cfset market_free_list = lcase(valuelist(market_free.SERVICE_ID))>

<!---get admin--->
<cfset useLakebaseForgetAdmin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForgetAdmin>
	<cftry>
		<cfset getAdmin = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#request.AccessStructure.User_ID#",
				"select" = "is_system_administrator"
			}), "is_system_administrator"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetAdmin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetAdmin>
<CFQUERY NAME="getAdmin" datasource="#application.datasource#">
	SELECT	Is_System_Administrator
	FROM 	_Users
	WHERE 	User_ID = '#request.AccessStructure.User_ID#'
</CFQUERY>
</cfif>

<CFSET isAdmin = getAdmin.Is_System_Administrator>

<!--- get foodservice line of business id--->
<CFQUERY NAME="getFoodserviceLOBID" datasource="#application.datasource#">
	SELECT 	Line_Of_Business_ID
	FROM 	Line_Of_Business
	WHERE 	Line_Of_Business IN (#ListQualify(application.returned_customer_setting.Line_Business_Default, "'", ",")#) AND Deleted = 0
</CFQUERY>
	
<CFSET ListOfLOBIDS = listqualify(valuelist(getFoodserviceLOBID.Line_Of_Business_ID), "'")>

<!---get active zones--->
<CFQUERY NAME="getFoodserviceActiveZones" datasource="#application.datasource#">
	SELECT	DISTINCT Service_Zone_ID, 
			Line_Of_Business_ID
	FROM    BSA_Foodservice_Brokers
	WHERE	(Active_Code = 'A') 
	AND 	(Line_Of_Business_ID IN(#preservesinglequotes(ListOfLOBIDS)#)) 
	AND 	(Deleted = 0)
</CFQUERY>

<CFSET listofservicezones = valuelist(getFoodserviceActiveZones.Service_Zone_ID)>

<!---get zones--->
<CFQUERY NAME="getZones" datasource="#application.datasource#">
	SELECT	*
	FROM 	Service_Zones 
	WHERE 	Deleted = 0
	<cfif isDefined("form.save") and form.z neq 0>
	AND 	Service_Zone_ID = <cfqueryparam value="#form.z#" cfsqltype="CF_SQL_VARCHAR" />
	</cfif>
	<cfif listlen(zone_free_list) gt 0>
		AND Service_Zone_ID NOT IN(#listqualify(zone_free_list, "'")#)
	</cfif>
	--WHERE Service_Zone_ID IN(#listqualify(listofservicezones, "'")#) AND Deleted = 0
	ORDER BY Zone_Name
</CFQUERY>

<!--- <CFSET for_Position_Label = XmlFormat(thisPositionLabelText)> --->
<CFSET for_Position_Label = trim(thisPositionLabelText)>

<!---get the xml DOM from file if we are saving--->
<cfif isDefined("form.save") and form.z neq 0>

	<!---read in the xml from file and set it to our xml object--->
	<cffile action="read" file="#docPath#\explorerFile.xml" variable="xmlDataPacket">
	<cfset xmlDoc = XmlParse(trim(xmlDataPacket)) />
	
	<!---loop through and find the index of the zone we are updating--->
	<cfloop index="indx" from="1" to="#ArrayLen(xmlDoc.menu.XmlChildren)#">

		<cfif xmlDoc.menu.XmlChildren[indx].XmlAttributes.zoneId eq form.z>
			<cfset indxToUpdate = indx />
			<cfbreak />
		</cfif>
	
	</cfloop>

<!---if we aren't saving then rebuild xml object--->
<cfelse>

	<!----set the XML object--->
	<cfset xmlDoc = XmlNew() />
	
	<!---add top level element--->
	<cfset xmlDoc.menu = XmlElemNew(xmlDoc,"menu") />
	
	<!---populate top level attributes--->
	<cfset StructInsert(xmlDoc.menu.XmlAttributes, "caption", "All Zones") />
	<cfset StructInsert(xmlDoc.menu.XmlAttributes, "href", "manage_nodes.cfm?z=0&r=0&m=0") />
	<cfset StructInsert(xmlDoc.menu.XmlAttributes, "label", "#for_Position_Label#") />
	<cfset StructInsert(xmlDoc.menu.XmlAttributes, "icon", "level_all.gif") />

</cfif>



<!---loop through zones and build xml --->
<CFOUTPUT QUERY="getZones">

	<!---if we are saving then set the zone index to the zone index we found in the loop--->
	<cfif isDefined("form.save") and form.z neq 0>
		<cfset zoneIndx = indxToUpdate />
	<cfelse>
		<cfset zoneIndx = getZones.CurrentRow />
	</cfif>
	
	<CFSET GlobalZoneID = getZones.Service_Zone_ID>
	<CFSET thisPositionZone 	= GlobalZoneID>
	<CFSET thisPositionRegion 	= 0>
	<CFSET thisPositionMarket 	= 0>
	<CFINCLUDE TEMPLATE="/settings/get_position_label.cfm">

	<!--- <CFSET for_Zone_Name=XmlFormat(getZones.Zone_Name)> --->
	<CFSET for_Zone_Name=trim(getZones.Zone_Name)>
	<!--- <CFSET for_Position_Label = XmlFormat(thisPositionLabelText)> --->
	<CFSET for_Position_Label = trim(thisPositionLabelText)>

	<!---set this zone element--->
	<cfset zoneElem = xmlDoc.menu />
	
	<cfset zoneElem.XmlChildren[zoneIndx] =  XmlElemNew(xmlDoc,"menuItem")>
	<!--- <cfset ArrayAppend(zoneElem.XmlChildren, XmlElemNew(xmlDoc,"menuItem"))> --->
	<cfset StructInsert(zoneElem.menuItem[zoneIndx].XmlAttributes, "level", "I") />
	<cfset StructInsert(zoneElem.menuItem[zoneIndx].XmlAttributes, "icon", "level_one.gif") />
	<cfset StructInsert(zoneElem.menuItem[zoneIndx].XmlAttributes, "caption", "#trim(for_Zone_Name)#") />
	<cfset StructInsert(zoneElem.menuItem[zoneIndx].XmlAttributes, "href",("javascript:window.open('manage_nodes.cfm?z=#GlobalZoneID#&r=0&m=0', 'MyWindow', 'toolbar = 0, scrollbars= 1');void(0);")) />
	<cfset StructInsert(zoneElem.menuItem[zoneIndx].XmlAttributes, "label", "#for_Position_Label#") />
	<cfset StructInsert(zoneElem.menuItem[zoneIndx].XmlAttributes, "zoneId", "#GlobalZoneID#") />

	<!---get regions--->
	<CFQUERY NAME="getRegions" datasource="#application.datasource#">
		SELECT 	*
		FROM 	service_regions
		WHERE 	Service_Zone_ID = '#getZones.Service_Zone_ID#' AND Deleted = 0
		<cfif listlen(region_free_list) gt 0>AND Service_Region_ID NOT IN(#listqualify(region_free_list, "'")#)</cfif>
		ORDER BY Region_Name
	</CFQUERY>
	
	<!---loop through regions and build xml children of zones--->
	<CFLOOP QUERY="getRegions">
	
		<cfset regionIndx = getRegions.CurrentRow />
		
		<CFSET GlobalRegionID = getRegions.Service_Region_ID>
		<CFSET thisPositionZone 	= GlobalZoneID>
		<CFSET thisPositionRegion 	= GlobalRegionID>
		<CFSET thisPositionMarket 	= 0>
		<CFINCLUDE TEMPLATE="/settings/get_position_label.cfm">

		<!--- <CFSET for_Region_Name=XmlFormat(getRegions.Region_Name)> --->
		<CFSET for_Region_Name=trim(getRegions.Region_Name)>
		<!--- <CFSET for_Position_Label = XmlFormat(thisPositionLabelText)> --->
		<CFSET for_Position_Label = trim(thisPositionLabelText)>
		
		<!---set this region element--->
		<cfset regionElem = xmlDoc.menu.menuItem[zoneIndx] />
		
		<cfset ArrayAppend(regionElem.XmlChildren, XmlElemNew(xmlDoc,"menuItem"))>
		<cfset StructInsert(regionElem.menuItem[regionIndx].XmlAttributes, "level", "II") />
		<cfset StructInsert(regionElem.menuItem[regionIndx].XmlAttributes, "icon", "level_two.gif") />
		<cfset StructInsert(regionElem.menuItem[regionIndx].XmlAttributes, "caption", "#trim(for_Region_Name)#") />
		<cfset StructInsert(regionElem.menuItem[regionIndx].XmlAttributes, "parensdata", "") />
		<cfset StructInsert(regionElem.menuItem[regionIndx].XmlAttributes, "href", ("javascript:window.open('manage_nodes.cfm?z=#GlobalZoneID#&r=#GlobalRegionID#&m=0', 'MyWindow', 'toolbar = 0, scrollbars= 1');void(0);")) />
		<cfset StructInsert(regionElem.menuItem[regionIndx].XmlAttributes, "label", "#for_Position_Label#") />
	
	
		<!---get markets--->
		<CFQUERY NAME="getMarkets" datasource="#application.datasource#">
			SELECT *
			FROM service_markets
			WHERE Service_Region_ID = '#getRegions.Service_Region_ID#' AND Deleted = 0
			<cfif listlen(market_free_list) gt 0>AND Service_Market_ID NOT IN(#listqualify(market_free_list, "'")#)</cfif>
			ORDER BY Market_Name
		</CFQUERY>
		
		<!---loop through markets and build xml children of regions--->
		<CFLOOP QUERY="getMarkets">
		
			<cfset marketIndx = getMarkets.CurrentRow />
			
			<CFSET GlobalMarketID = getMarkets.Service_Market_ID>
			<CFSET thisPositionZone 	= GlobalZoneID>
			<CFSET thisPositionRegion 	= GlobalRegionID>
			<CFSET thisPositionMarket 	= GlobalMarketID>
			<CFINCLUDE TEMPLATE="/settings/get_position_label.cfm">

			<!--- <CFSET for_Market_Name=XmlFormat(getMarkets.Market_Name)> --->
			<CFSET for_Market_Name=trim(getMarkets.Market_Name)>
			<!--- <CFSET for_Position_Label = XmlFormat(thisPositionLabelText)> --->
			<CFSET for_Position_Label = trim(thisPositionLabelText)>
			
			<!---set this market element--->
			<cfset marketElem = xmlDoc.menu.menuItem[zoneIndx].menuItem[regionIndx] />
			
			<cfset ArrayAppend(marketElem.XmlChildren, XmlElemNew(xmlDoc,"menuItem"))>
			<cfset StructInsert(marketElem.menuItem[marketIndx].XmlAttributes, "level", "III") />
			<cfset StructInsert(marketElem.menuItem[marketIndx].XmlAttributes, "icon", "level_three.gif") />
			<cfset StructInsert(marketElem.menuItem[marketIndx].XmlAttributes, "caption", "#trim(for_Market_Name)#") />
			<cfset StructInsert(marketElem.menuItem[marketIndx].XmlAttributes, "parensdata", "") />
			<cfset StructInsert(marketElem.menuItem[marketIndx].XmlAttributes, "href",("javascript:window.open('manage_nodes.cfm?z=#GlobalZoneID#&r=#GlobalRegionID#&m=#GlobalMarketID#', 'MyWindow', 'toolbar = 0, scrollbars= 1');void(0);")) />
			<cfset StructInsert(marketElem.menuItem[marketIndx].XmlAttributes, "label", "#for_Position_Label#") />
			
			<!---set the broker element--->
			<cfset brokerElem = xmlDoc.menu.menuItem[zoneIndx].menuItem[regionIndx].menuItem[marketIndx] />
			<cfset brokerIndx = 0>
				
			<!---get brokers--->
			<cfset useLakebaseForgetBrokers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_brokers")>
<cfif useLakebaseForgetBrokers>
	<cftry>
		<cfset getBrokers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_brokers", {
				"active_code" = "eq.A",
				"deleted" = "eq.0",
				"service_market_id" = "eq.#getMarkets.Service_Market_ID#",
				"order" = "broker_name.asc",
				"select" = "broker_name,bsa_foodservice_brokers_id,broker_shard"
			}), "broker_name,bsa_foodservice_brokers_id,broker_shard"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBrokers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBrokers>
<cfquery name="getBrokers" datasource="#application.datasource#">
				SELECT 	Broker_Name, 
						BSA_Foodservice_Brokers_ID, 
						Broker_Shard
				FROM 	BSA_Foodservice_Brokers
				WHERE 	Active_Code = 'A'
				AND		DELETED = 0
				AND		Service_Market_ID = '#getMarkets.Service_Market_ID#'
				ORDER BY Broker_Name
			</cfquery>
</cfif>
			
			<!---loop through brokers and build xml children to markets--->
			<CFLOOP query="getBrokers">
			
				<cfset brokerIndx = getBrokers.CurrentRow />
				
				<cfset thisPositionBrokerID = getBrokers.BSA_Foodservice_Brokers_ID>
				<!--- <CFSET for_Broker_Name=XmlFormat(getBrokers.Broker_Name)> --->
				<CFSET for_Broker_Name=getBrokers.Broker_Name>

				<!--- <CFSET brokerid_display=XmlFormat(getBrokers.Broker_Shard)> --->
				<CFSET brokerid_display=trim(getBrokers.Broker_Shard)>
				<cfif len(trim(brokerid_display)) EQ 0>
					<cfset brokerid_display = "ID UNAVAILABLE">
				</cfif>
				
				<cfset ArrayAppend(brokerElem.XmlChildren, XmlElemNew(xmlDoc,"menuItem"))>
				<cfset StructInsert(brokerElem.menuItem[brokerIndx].XmlAttributes, "level", "B") />
				<cfset StructInsert(brokerElem.menuItem[brokerIndx].XmlAttributes, "icon", "level_broker.gif") />
				<cfset StructInsert(brokerElem.menuItem[brokerIndx].XmlAttributes, "caption", "#trim(for_Broker_Name)#") />
				<cfset StructInsert(brokerElem.menuItem[brokerIndx].XmlAttributes, "parensdata", "#brokerid_display#") />
				<cfset StructInsert(brokerElem.menuItem[brokerIndx].XmlAttributes, "href", ("javascript:window.open('manage_nodes.cfm?z=#GlobalZoneID#&r=#GlobalRegionID#&m=#GlobalMarketID#&b=#thisPositionBrokerID#', 'MyWindow', 'toolbar = 0, scrollbars= 1');void(0);")) />
				
				<cfif appSettings.getPosition_Tree_Display_Distributor()><!----- D12004: Remove distributors from tree ----->
					<!---get distributors--->
					<cfset getDistributor = positionTreeManager.getDistributors(0, thisPositionBrokerID, appSettings.getDistributorMultiPosition(), 0) />
					
					<!--- start distributor--->
					<!---set the broker element--->
					<cfset distElem = xmlDoc.menu.menuItem[zoneIndx].menuItem[regionIndx].menuItem[marketIndx].menuItem[brokerIndx] />
					
					<!---  set the distributor sectiopn of the tree --->
					<cfset positionTreeManager.getDistributorSection(getDistributor, xmlDoc, distElem)>
					<!---  set the distributor sectiopn of the tree --->
					<!--- end distributor--->
				</cfif>

			</CFLOOP>
			<!--- end broker node --->
			
			<cfif appSettings.getPosition_Tree_Display_Distributor()><!----- D12004: Remove distributors from tree ----->
				<!--- start distributor--->
				<!---get distributors--->
				<cfif appSettings.getDistributorMultiPosition()>
					<cfset getDistributor = positionTreeManager.getDistributors(GlobalMarketID, '', appSettings.getDistributorMultiPosition()) />
					
					<!---  set the distributor section of the tree --->
					<cfset positionTreeManager.getDistributorSection(getDistributor, xmlDoc, brokerElem, brokerIndx)>
					<!---  set the distributor section of the tree --->
				</cfif>
				<!--- end distributor--->
			</cfif>
			
		</CFLOOP>
		<!--- end market node --->
			
	</CFLOOP>
	<!--- end region node --->
	
</CFOUTPUT>
<!--- end zone node --->

<!---convert xml object to a string to write to file--->
<cfset xmlDoc = toString(xmlDoc) />

<cfset xmlDoc = Replace(xmlDoc, "encoding=""UTF-8""", "encoding=""ISO-8859-1""") />

<cffile action="WRITE" file="#docPath#\explorerFile.xml" output="#trim(xmlDoc)#" addnewline="Yes">

<cfif autoredirectflag EQ 1>
	<script>
		window.location.href = "<cfoutput>#autoredirectflag_URL#</cfoutput>";
	</script>
</cfif>