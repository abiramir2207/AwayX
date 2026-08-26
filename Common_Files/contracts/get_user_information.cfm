<cfset UserInformation = StructNew()>
<cfset UserInformation.User_ID = "8F4E2CFD-C6AB-4172-BCFCD050F39EF729">
<cfset UserInformation.User_Position_ID = "">

<cfset UserInformation.Service_Zone_ID_List = "0">
<cfset UserInformation.Service_Region_ID_List = "0">
<cfset UserInformation.Service_Market_ID_List = "0">

<CFSET UserInformation.User_ID = "8F4E2CFD-C6AB-4172-BCFCD050F39EF729">

<cfset useLakebaseForget_Basic_User_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForget_Basic_User_Info>
	<cftry>
		<cfset get_Basic_User_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#UserInformation.User_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_Basic_User_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_Basic_User_Info>
<CFQUERY NAME="get_Basic_User_Info" datasource="#application.datasource#">
	SELECT *
	FROM _Users
	WHERE User_ID = '#UserInformation.User_ID#'
</CFQUERY>
</cfif>
<CFSET UserInformation.Profile_ID = get_Basic_User_Info.Profiles_ID>

<cfset useLakebaseForget_User_Geographic_Restriction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profiles_settings")>
<cfif useLakebaseForget_User_Geographic_Restriction>
	<cftry>
		<cfset get_User_Geographic_Restriction = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profiles_settings", {
				"profiles_id" = "eq.#UserInformation.Profile_ID#",
				"select" = "geographic_access"
			}), "geographic_access"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForget_User_Geographic_Restriction = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForget_User_Geographic_Restriction>
<CFQUERY NAME="get_User_Geographic_Restriction" datasource="#application.datasource#">
	SELECT Geographic_Access
	FROM Profiles_Settings
	WHERE Profiles_ID = '#UserInformation.Profile_ID#'
</CFQUERY>
</cfif>
<CFSET UserInformation.Geographic_Access = get_User_Geographic_Restriction.Geographic_Access>


<CFQUERY NAME="get_User_Position" datasource="#application.datasource#">
SELECT     dbo.User_Position_Holders.User_Position_Holders_ID, dbo.User_Position_Holders.User_Positions_ID, dbo.User_Position_Holders.User_ID, 
                      dbo.User_Positions.Position_Label, dbo.User_Positions.Service_Zone_ID, dbo.User_Positions.Service_Region_ID, 
                      dbo.User_Positions.Service_Market_ID
FROM         dbo.User_Position_Holders INNER JOIN
                      dbo.User_Positions ON dbo.User_Position_Holders.User_Positions_ID = dbo.User_Positions.User_Positions_ID
WHERE     (dbo.User_Position_Holders.deleted = 0) AND (dbo.User_Positions.Deleted = 0) AND (dbo.User_Position_Holders.User_ID = '#UserInformation.User_ID#')
</CFQUERY>

<CFSWITCH EXPRESSION="#UserInformation.Geographic_Access#">
	<!--- National --->
	<CFCASE VALUE="1">
		<CFSET UserInformation.Geographic_Access_Label = "National">
		<CFSET UserInformation.Restricted_Geographic_ID_List = "NO RESTRICTIONS">
	</CFCASE>			

	<!--- Zone --->
	<CFCASE VALUE="2">
		<CFSET UserInformation.Geographic_Access_Label = "Zone">
		<CFSET UserInformation.Restricted_Geographic_ID_List = UserInformation.Service_Zone_ID_List>
	</CFCASE>			

	<!--- Region --->
	<CFCASE VALUE="3">
		<CFSET UserInformation.Geographic_Access_Label = "Region">
		<CFSET UserInformation.Restricted_Geographic_ID_List = UserInformation.Service_Region_ID_List>
	</CFCASE>			

	<!--- Market --->
	<CFCASE VALUE="4">
		<CFSET UserInformation.Geographic_Access_Label = "Market">
		<CFSET UserInformation.Restricted_Geographic_ID_List = UserInformation.Service_Market_ID_List>
	</CFCASE>			
</CFSWITCH>

<CFIF get_User_Position.Recordcount GT 0>
	<cfset UserInformation.User_Position_ID = get_User_Position.User_Positions_ID>
</CFIF>

<CFIF  len(trim(get_User_Position.Service_Zone_ID)) EQ 0>
	<cfset UserInformation.Service_Zone_ID_List 	= "ALL">
	<cfset UserInformation.Service_Region_ID_List 	= "ALL">
	<cfset UserInformation.Service_Market_ID_List 	= "ALL">
<CFELSE>
<!--- Map Out Zones, Regions, and Markets --->


	<CFIF get_User_Position.recordcount GT 0>
		<CFSET UserInformation.Service_Zone_ID_List = ValueList(get_User_Position.Service_Zone_ID)>

		<cfset useLakebaseForGetAllRegions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_regions")>
		<cfif useLakebaseForGetAllRegions>
			<cftry>
				<cfset get_All_Regions = application.oLakebase.toQuery(
					application.oLakebase.selectRows("service_regions", { "select" = "service_region_id", "service_zone_id" = "in.(#UserInformation.Service_Zone_ID_List#)", "deleted" = "eq.0" })
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetAllRegions = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetAllRegions>
		<CFQUERY NAME="get_All_Regions" datasource="#application.datasource#">
			SELECT Service_Region_ID
			FROM Service_Regions
			WHERE Service_Zone_ID IN(#replace(listqualify(UserInformation.Service_Zone_ID_List, "'", ","), '"', "'", "ALL")#) AND Deleted = 0
		</CFQUERY>
		</cfif>
		<cfset UserInformation.Service_Region_ID_List = ValueList(get_All_Regions.Service_Region_ID)>

		<cfset useLakebaseForGetAllMarkets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("service_markets")>
		<cfif useLakebaseForGetAllMarkets>
			<cftry>
				<cfset get_All_Markets = application.oLakebase.toQuery(
					application.oLakebase.selectRows("service_markets", { "select" = "service_market_id,bsa_foodservice_brokers_id", "service_region_id" = "in.(#UserInformation.Service_Region_ID_List#)", "deleted" = "eq.false" })
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForGetAllMarkets = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForGetAllMarkets>
		<CFQUERY NAME="get_All_Markets" datasource="#application.datasource#">
			SELECT Service_Market_ID, BSA_Foodservice_Brokers_ID
			FROM Service_Markets
			WHERE Service_Region_ID IN(#replace(listqualify(UserInformation.Service_Region_ID_List, "'", ","), '"', "'", "ALL")#) AND Deleted = 0
		</CFQUERY>
		</cfif>
		<cfset UserInformation.Service_Market_ID_List = ValueList(get_All_Markets.Service_Market_ID)>
		<cfset UserInformation.Service_Market_Brokers_ID_List = ValueList(get_All_Markets.BSA_Foodservice_Brokers_ID)>
	</CFIF>
</CFIF>






