<STYLE TYPE="text/css">
DIV.BreakHere {
page-break-before: always;
}
</STYLE>

<cfoutput><h3>
host: #lcase(CGI.HTTP_HOST)#&nbsp;&nbsp;&nbsp; datasource: #application.datasource#
</h3></cfoutput>
<BR>

<h1>TREE FROM POSITION TABLE</h1>
<hr>
<br>

<cfquery name="getPositions" datasource="#application.datasource#">
	SELECT Service_Zone_ID, Service_Region_ID, Service_Market_ID, Position_Label
	FROM         dbo.User_Positions
	WHERE     (Deleted = 0)
	ORDER BY Service_Zone_ID, Service_Region_ID, Service_Market_ID, Position_Label
</cfquery>

<!--- get zones in position table --->
<cfquery name="Zones" datasource="#application.datasource#">
	SELECT DISTINCT dbo.Service_Zones.Service_Zone_ID, dbo.Service_Zones.Zone_Name
	FROM         dbo.User_Positions INNER JOIN
	                      dbo.Service_Zones ON dbo.User_Positions.Service_Zone_ID = dbo.Service_Zones.Service_Zone_ID
	WHERE     (dbo.User_Positions.Deleted = 0)
</cfquery>
<!--- get regions in position table --->
<cfquery name="Regions" datasource="#application.datasource#">
SELECT DISTINCT dbo.User_Positions.Service_Region_ID, dbo.Service_Regions.Region_Name
FROM         dbo.User_Positions INNER JOIN
                      dbo.Service_Regions ON dbo.User_Positions.Service_Region_ID = dbo.Service_Regions.Service_Region_ID
WHERE     (dbo.User_Positions.Deleted = 0)
</cfquery>
<!--- get markets in position table --->
<cfquery name="Markets" datasource="#application.datasource#">
SELECT DISTINCT dbo.User_Positions.Service_Market_ID, dbo.Service_Markets.Market_Name
FROM         dbo.User_Positions INNER JOIN
                      dbo.Service_Markets ON dbo.User_Positions.Service_Market_ID = dbo.Service_Markets.Service_Market_ID
WHERE     (dbo.User_Positions.Deleted = 0)
</cfquery>

<cfset NameArray = ArrayNew(1)>
<cfloop index="x" from="1" to="#getPositions.recordcount#">
	<CFSET NameArray[x] = "">
</cfloop>
<CFSET temp = QueryAddColumn(getPositions, "Service_Zone_Name", NameArray)>
<CFSET temp = QueryAddColumn(getPositions, "Service_Region_Name", NameArray)>
<CFSET temp = QueryAddColumn(getPositions, "Service_Market_Name", NameArray)>

<cfset RC = 1>
<cfloop query="getPositions">
	<cfset getPositions_Service_Zone_ID = getPositions.Service_Zone_ID>
	<cfset getPositions_Service_Region_ID = getPositions.Service_Region_ID>
	<cfset getPositions_Service_Market_ID = getPositions.Service_Market_ID>

	<cfloop query="Zones">
		<cfif getPositions_Service_Zone_ID EQ Zones.Service_Zone_ID>
			<cfset QuerySetCell(getPositions, "Service_Zone_Name", Zones.Zone_Name, RC)>
		</cfif>
	</cfloop>
	<cfloop query="Regions">
		<cfif getPositions_Service_Region_ID EQ Regions.Service_Region_ID>
			<cfset QuerySetCell(getPositions, "Service_Region_Name", Regions.Region_Name, RC)>
		</cfif>
	</cfloop>
	<cfloop query="Markets">
		<cfif getPositions_Service_Market_ID EQ Markets.Service_Market_ID>
			<cfset QuerySetCell(getPositions, "Service_Market_Name", Markets.Market_Name, RC)>
		</cfif>
	</cfloop>
<cfset RC = RC+1>
</cfloop>

<cfquery name="getPositions" dbtype="query">
	SELECT * FROM getPositions
	ORDER BY Service_Zone_Name, Service_Region_Name, Service_Market_Name, Position_Label
</cfquery>

<!--- <cfdump var="#getPositions#"> --->

<cfoutput>
<table border="1" cellspacing="2" cellpadding="2">
	<cfset useLakebaseForgetGodLabel = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getpositions")>
<cfif useLakebaseForgetGodLabel>
	<cftry>
		<cfset getGodLabel = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getpositions", {
				"service_zone_id" = "is.null",
				"service_region_id" = "is.null",
				"service_market_id" = "is.null",
				"select" = "position_label"
			}), "position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGodLabel = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGodLabel>
<cfquery name="getGodLabel" dbtype="query">
		SELECT Position_Label
		FROM getPositions
		WHERE
			Service_Zone_ID IS NULL
			AND
			Service_Region_ID IS NULL
			AND
			Service_Market_ID IS NULL
	</cfquery>
</cfif>
	<TR>
		<td><b>#getGodLabel.Position_Label#&nbsp;</b></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</TR>
	
	<cfset useLakebaseForgetZones = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getpositions")>
<cfif useLakebaseForgetZones>
	<cftry>
		<cfset getZones = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getpositions", {
				"service_zone_id" = "not.is.null",
				"service_region_id" = "is.null",
				"service_market_id" = "is.null",
				"order" = "service_zone_name.asc",
				"select" = "service_zone_id,service_zone_name,position_label"
			}), "service_zone_id,service_zone_name,position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetZones = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetZones>
<cfquery name="getZones" dbtype="query">
		SELECT DISTINCT Service_Zone_ID, Service_Zone_Name, Position_Label
		FROM getPositions
		WHERE Service_Zone_ID is not null AND Service_Region_ID IS NULL AND Service_Market_ID IS NULL
		ORDER BY Service_Zone_Name
	</cfquery>
</cfif>

	<cfset ZoneList = ValueList(getZones.Service_Zone_ID)>
	
	<cfloop query="getZones">
		<TR>
			<TD>#getZones.Service_Zone_Name#&nbsp;</TD>
			<TD><b>#getZones.Position_Label#&nbsp;</b></TD>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</TR>

		<cfset useLakebaseForgetRegions = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getpositions")>
<cfif useLakebaseForgetRegions>
	<cftry>
		<cfset getRegions = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getpositions", {
				"service_zone_id" = "eq.#getZones.Service_Zone_ID#",
				"service_region_id" = "not.is.null",
				"service_market_id" = "is.null",
				"order" = "service_region_name.asc",
				"select" = "service_region_id,service_region_name,position_label"
			}), "service_region_id,service_region_name,position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetRegions = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetRegions>
<cfquery name="getRegions" dbtype="query">
			SELECT DISTINCT Service_Region_ID, Service_Region_Name, Position_Label
			FROM getPositions
			WHERE Service_Zone_ID = '#getZones.Service_Zone_ID#' AND Service_Region_ID IS NOT NULL AND Service_Market_ID IS NULL
			ORDER BY Service_Region_Name 
		</cfquery>
</cfif>
		
		<cfloop query="getRegions">
			<TR>
				<td>&nbsp;</td>
				<TD>#getRegions.Service_Region_Name#&nbsp;</TD>
				<TD><b>#getRegions.Position_Label#&nbsp;</b></TD>
				<td>&nbsp;</td>
			</TR>
 			
			<cfset useLakebaseForgetMarkets = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getpositions")>
<cfif useLakebaseForgetMarkets>
	<cftry>
		<cfset getMarkets = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getpositions", {
				"service_region_id" = "eq.#getRegions.Service_Region_ID#",
				"service_zone_id" = "not.is.null",
				"service_market_id" = "not.is.null",
				"order" = "service_market_name.asc",
				"select" = "service_market_id,service_market_name,position_label"
			}), "service_market_id,service_market_name,position_label"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetMarkets = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetMarkets>
<cfquery name="getMarkets" dbtype="query">
				SELECT DISTINCT Service_Market_ID, Service_Market_Name, Position_Label
				FROM getPositions
				WHERE Service_Region_ID = '#getRegions.Service_Region_ID#' AND Service_Zone_ID IS NOT NULL AND Service_Market_ID IS NOT NULL
				ORDER BY Service_Market_Name
			</cfquery>
</cfif>	
			
			<cfloop query="getMarkets">
				<TR>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<TD>#getMarkets.Service_Market_Name#&nbsp;</TD>
					<TD><b>#getMarkets.Position_Label#&nbsp;</b></TD>
				</TR>			
			</cfloop>	
		</cfloop>
		
		
	</cfloop>
</table>


<DIV CLASS="BreakHere">

<cfoutput><h3>
host: #lcase(CGI.HTTP_HOST)#&nbsp;&nbsp;&nbsp; datasource: #application.datasource#
</h3></cfoutput>
<BR>

<h1>TREE FROM DATA FROM RELATED COLUMNS</h1>
<hr>
<br>


<!--- get tree from table lookups --->
<cfset ZoneList = listqualify(ZoneList, "'")>
<cfquery name="Zones" datasource="#application.datasource#">
	SELECT 	Zone_Name, Service_Zone_ID
	FROM 	Service_Zones
	WHERE 	Deleted = 0 
			AND len(Zone_Name) > 0 
			<CFIF Len(ZoneList) GT 0>
			AND Service_Zone_ID IN (#preservesinglequotes(ZoneList)#)
			<CFELSE>
			AND 1 = 2
			</CFIF>
	ORDER BY Zone_Name
</cfquery>

<table border="1" cellspacing="2" cellpadding="2">
<cfloop query="Zones">
	<tr>
		<td>#Zones.Zone_Name#</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
	</tr>

	<cfquery name="Regions" datasource="#application.datasource#">
		SELECT Region_Name, Service_Region_ID
		FROM Service_Regions
		WHERE Deleted = 0 AND Service_Zone_ID = '#Zones.Service_Zone_ID#' AND len(Region_Name) > 0
		ORDER BY Region_Name
	</cfquery>
	
	<cfloop query="Regions">
		<tr>
			<td>&nbsp;</td>
			<td>#Regions.Region_Name#</td>
			<td>&nbsp;</td>
		</tr>

		<cfquery name="Markets" datasource="#application.datasource#">
			SELECT Market_Name, Service_Market_ID
			FROM Service_Markets
			WHERE Deleted = 0 AND Service_Region_ID = '#Regions.Service_Region_ID#' AND len(Market_Name) > 0
			ORDER BY Market_Name
		</cfquery>
		
		<cfloop query="Markets">
			<tr>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>#Markets.Market_Name#</td>
			</tr>
		</cfloop>
	
	</cfloop>
	
</cfloop>
</table>

</cfoutput>
<DIV CLASS="BreakHere">