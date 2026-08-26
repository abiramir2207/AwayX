<cfcomponent hint="Zip Code" extends="components.Base">
	
	<cffunction name="getZipCode" output="false" returntype="query">
		
		<cfargument name="search" type="struct" required="true" />
		<cfargument name="sortBy" type="string" required="false" default="" />
		<cfargument name="sortOrder" type="string" required="false" default="" />
		
		<cfset this.search = arguments.search>
		
		<!------ sort code ----->
		<cfset sql_Sort_By="ZipCodes.ZIPCode">
		<cfswitch expression="#arguments.sortBy#">
			<cfcase value="City">
				<cfset sql_Sort_By="ZipCodes.City">
			</cfcase>
			<cfcase value="County">
				<cfset sql_Sort_By="ZipCodes.County">
			</cfcase>
			<cfcase value="State">
				<cfset sql_Sort_By="ZipCodes.State">
			</cfcase>
			<cfcase value="AreaCode">
				<cfset sql_Sort_By="ZipCodes.AreaCode">
			</cfcase>
			<cfcase value="TimeZone">
				<cfset sql_Sort_By="ZipCodes.TimeZone">
			</cfcase>
			<cfcase value="Market">
				<cfset sql_Sort_By="Service_Markets.Market_Name">
			</cfcase>
		</cfswitch>
		
		<CFIF arguments.sortOrder EQ "DESC">
			<cfset sql_Sort_By="#sql_Sort_By# DESC">
		<CFELSE>
			<cfset sql_Sort_By="#sql_Sort_By# ASC">
		</CFIF>

		<cfquery name="qGetZipCode" datasource="#application.datasource#">
			Select		ZipCodes.ZIPCode, ZipCodes.City, ZipCodes.County, ZipCodes.State, ZipCodes.AreaCode, ZipCodes.TimeZone, ZipCodes.Latitude, ZipCodes.Longitude,
						Service_Markets.Market_Name
			From		ZipCodes
						LEFT JOIN Market_ZipCode
						ON
						Market_ZipCode.ZipCode = ZipCodes.ZIPCode
						AND
						Market_ZipCode.Deleted = 0
						LEFT JOIN Service_Markets
						ON
						Service_Markets.Deleted = 0
						AND
						Service_Markets.Service_Market_ID = Market_ZipCode.Service_Market_ID						
			Where		
						ZipCodes.CityType	=	'D'
						<cfif Super.variableExist("this.search.idList", "")><!------ not null ----->
							AND	ZipCodes.ZIPCode IN (#ListQualify(this.search.idList, "'", ",")#)
						<cfelse>
							<cfif Super.variableExist("this.search.idList", "1")><!------ null ----->
							AND	1	=	2
							</cfif>							
						</cfif>
						<cfif Super.variableExist("this.search.marketId", "")>
							AND
							Market_ZipCode.Service_Market_ID = #this.search.marketId#
						</cfif>
			Order by	#sql_Sort_By#
		</cfquery>
		
		<cfreturn qGetZipCode />
		
	</cffunction>
	
	<cffunction name="saveMarket">
		
		<cfargument name="marketId" type="numeric" required="true" />
		<cfargument name="idList" type="string" required="false" default="" />
		<cfargument name="userId" type="string" required="false" default="" />
		
		<cfloop list="#arguments.idList#" delimiters="," index="ThisZipCode">
	 	
	 	<cfset useLakebaseFordelete_zip_code_entry = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("market_zipcode")>
<cfif useLakebaseFordelete_zip_code_entry>
	<cftry>
		<cfset application.oLakebase.updateRows("market_zipcode",
			{
				"deleted" = "eq.0",
				"zipcode" = "eq.#ThisZipCode#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordelete_zip_code_entry = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordelete_zip_code_entry>
<cfquery name="delete_zip_code_entry" datasource="#application.datasource#">
			UPDATE	Market_ZipCode
			SET 	Deleted = 1
			WHERE
					Market_ZipCode.Deleted = 0
					AND
					Market_ZipCode.ZipCode = '#ThisZipCode#'
		</cfquery>
</cfif>
		<cfquery name="insert_zip_code_entry" datasource="#application.datasource#">
			INSERT INTO	Market_ZipCode 
					(ZipCode, Service_Market_ID, Assigned_By_User_ID)
			VALUES 	('#ThisZipCode#', #arguments.marketId#, '#arguments.userId#')
		</cfquery>
		
	 </cfloop>
	 
	</cffunction>
	
</cfcomponent>