<cfcomponent extends="mvc.Models.SettingsService" alias="mvc.Models.Admin.Alias.AliasManagerDAO" hint="Data Access components, that does all the DB calls">

	<cffunction name="init" output="false" returntype="mvc.Models.Admin.Alias.AliasManagerDAO">
		<cfreturn this />
	</cffunction>
	
	<!--- Get settings --->
	<cffunction name="getSettings" access="private" returntype="query">

	    <cfset useLakebaseForqGetSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_settings")>
<cfif useLakebaseForqGetSettings>
	<cftry>
		<cfset qGetSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_settings", {
				"select" = "allow_multiple_operator_xref"
			}), "allow_multiple_operator_xref"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetSettings>
<cfquery name="qGetSettings" datasource="#application.datasource#">
		 SELECT Allow_Multiple_Operator_Xref
		 FROM billback_settings
	    </cfquery>
</cfif>
	  
	   <cfreturn qGetSettings>

	</cffunction>
	
	<!--- Get Source Type Lookup --->
	<cffunction name="getSourceTypeLookup" access="public" returntype="query">

	<cfset var appSettings = application.appSettingsGet />

	    <cfquery name="qGetSourceTypeLookup" datasource="#application.datasource#">
		IF OBJECT_ID('tempdb..##tmpSourceCode') IS NOT NULL
		DROP TABLE ##tmpSourceCode
		
		SELECT DISTINCT Source_Code
		INTO ##tmpSourceCode
		FROM BB_Claim_Item_xref
		WHERE deleted = 0
		
		UNION 
	
		SELECT DISTINCT Source_Code
		FROM BB_Claim_Dist_xref
		WHERE deleted = 0
		
		UNION 
	
		SELECT DISTINCT Source_Code
		FROM BB_Claim_Operator_xref
		WHERE deleted = 0		
		
		UNION 
	
		SELECT DISTINCT Source_Code
		FROM BB_Claim_Program_xref
		WHERE deleted = 0

		<!--- When source_code is "vendor_ID", then we show vendor name as well. --->
		SELECT bbu.Source_Type,bbc.BB_Claim_Source_Xref_ID,bbc.Source_Code,		 
			Isnull(vm.Vendor_Name,'') + 
			CASE WHEN (vm.Vendor_Name IS NULL OR vm.Vendor_Name = '')
					THEN ' '
				ELSE
				' ('
			END
			+ bbc.Source_Code +
			CASE WHEN (vm.Vendor_Name IS NULL OR vm.Vendor_Name = '')
					THEN ' '
				ELSE
				') '
			END		
			+ bbu.Source_Category 
		 As Source_Code_Display, 
		 bbu.Use_Search_Tool,bbu.Source_Type_Desc,bbc.Source_Type_Description

		 FROM BB_Upload_Source_Type_Lookup bbu
		 INNER JOIN BB_claim_Source_Xref bbc
		 ON bbu.Source_Type = bbc.Source_Type
		 LEFT JOIN Vendor_master vm
		 ON  vm.Vendor_ID = bbc.Source_Code
		 WHERE bbu.deleted = 0
		 <!--- Only show those sources which exists in at least one of the alias tables -
		 operator,distributor,item,program
		 --->
		 AND bbc.Source_Code IN
		 (
		 SELECT Source_Code
		 FROM ##tmpSourceCode	 
		 )	 
		 <!--- Use_Search_Tool is 0 --->
		 AND bbu.Use_Search_Tool <> 1
		 AND bbu.active = 1
		 AND bbc.deleted = 0
		 AND bbc.active = 1

		 UNION
		 
		 <!--- Top 1 is required, else there will be multiple vendor records. This is just for a hardcoded value of "PAYEE ALIAS". --->
		 SELECT Top 1 bbu.Source_Type,0 As BB_Claim_Source_Xref_ID,'' As Source_Code,
		 'PAYEE ALIAS' As Source_Code_Display,bbu.Use_Search_Tool,bbu.Source_Type_Desc,
		 '' As Source_Type_Description
		 FROM BB_Upload_Source_Type_Lookup bbu
		 WHERE bbu.deleted = 0
		 AND bbu.active = 1
		 AND bbu.Source_Type = 2

		 UNION

		 <!--- Here we add a hard coded value of "ALL ALIAS". Add '100' as source type. 100 is an arbitrary number, 
		 	which is large enough so that when sorted by source type, this record will be last. This is just for a 
			hardcoded value of "ALL ALIAS".
		 --->
		 SELECT 100 As Source_Type,0 As BB_Claim_Source_Xref_ID,'' As Source_Code,
		 'ALL ALIAS' As Source_Code,
		 0 As Use_Search_Tool,'' As Source_Type_Desc,'' As Source_Type_Description
		--  ORDER BY bbu.Use_Search_Tool DESC,bbu.Source_Type	 
		-- ORDER BY Source_Code_Display 
		 ORDER BY Source_Type_Description, Source_code_Display
	    </cfquery>
	  
	   <cfreturn qGetSourceTypeLookup>

	</cffunction>

	<!--- When searching for Aliases, check to see whether the "Source" exists in the Vendor_Master table. The Source could have been deleted or been inactive,
	      but we do not look for any flags while searching for Aliases belonging to a source.
	--->
	<cffunction name="getSourceDetails" access="public" returntype="query"> 
	  <cfargument name="sourceID" type="string" required="true">

	    <cfquery name="qGetSourceDetails" datasource="#application.datasource#">
		SELECT vm.Vendor_ID,vm.Vendor_Name,vm.City,vm.State
		FROM Vendor_Master vm
		WHERE vm.Vendor_ID = <cfqueryparam value="#arguments.sourceID#" cfsqltype="CF_SQL_VARCHAR">
		<!--- No need to check deleted = 0 OR Active_Code as a vendor could have been deactivated in the Vendor_Master table --->
	    </cfquery>
	  
	   <cfreturn qGetSourceDetails>

	</cffunction>

	<cffunction name="getUploadShipToColumn" access="private" returntype="string"> 

		<cfset var colName = "">

		<cfquery name="qGetUploadShipToColumn" datasource="#application.datasource#">
			SELECT IsNull(Manual_Upload_Ship_To_Column,'Ship_To') As Manual_Upload_Ship_To_Column
			FROM Billback_Upload_Settings
		</cfquery>

		<cfset colName = qGetUploadShipToColumn.Manual_Upload_Ship_To_Column>

		<cfreturn colName>
	</cffunction>

	<!--- The distributor should either be Active in the Customer Master table OR the Alias table should have it. (It is possible that the client supplied us with
	      an Alias for an inactive customer OR over time the customer has become inactive.)
	--->
	<cffunction name="getDistributorDetails" access="public" returntype="query"> 	  
	  <cfargument name="distributorID" type="string" required="true">
	  <!--- Check whether a distributor GUID is being passed to this function. --->
	  <cfargument name="isGUID" type="boolean" required="false" default="false">
	  <!--- Below argument (Check_shipto_OR_Shrshipto) is not being used anymore.
	  Do not remove it, as it is still being called in the code.
	  --->
	  <cfargument name="Check_shipto_OR_Shrshipto" type="boolean" required="false" default="false">

		<cfset var uploadShipToColumn = getUploadShipToColumn()>
	     
	    <cfquery name="qGetDistributorDetails" datasource="#application.datasource#">
		<!--- Active Distributor Only --->	      
		SELECT Name,#uploadShipToColumn# As Ship_To,City,State 
		FROM BSA_Foodservice_Customers
		WHERE deleted = 0
		<cfif arguments.isGUID>
		AND BSA_Foodservice_Customers_ID = <cfqueryparam value="#arguments.distributorID#" cfsqltype="CF_SQL_VARCHAR">
		<cfelse>
		AND #uploadShipToColumn# = <cfqueryparam value="#arguments.distributorID#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
	    </cfquery>
	  
	   <cfreturn qGetDistributorDetails>

	</cffunction>

	<cffunction name="getItemDetails" access="public" returntype="query"> 	  
	  <cfargument name="itemID" type="string" required="true">
	  <!--- Check whether a item GUID is being passed to this function. --->
	  <cfargument name="isGUID" type="boolean" required="false" default="false">
	     
	    <cfquery name="qGetItemDetails" datasource="#application.datasource#">      
		<!--- Active Item Only --->
		SELECT Item,Description
		FROM BSA_Foodservice_Items_Master
		WHERE deleted = 0
		   <cfif arguments.isGUID>
		AND BSA_Foodservice_Items_Master_ID = <cfqueryparam value="#arguments.itemID#" cfsqltype="CF_SQL_VARCHAR">
	       <cfelse>
		AND Item = <cfqueryparam value="#arguments.itemID#" cfsqltype="CF_SQL_VARCHAR">
	       </cfif>
	    </cfquery>
	  
	   <cfreturn qGetItemDetails>

	</cffunction>

	<!--- The program should either exist in the contract_Main table OR the Alias table should have it. --->
	<cffunction name="getProgramDetails" access="public" returntype="query"> 	  
	  <cfargument name="programID" type="string" required="true">
	  <cfargument name="isContractNumber" type="boolean" required="true">
	     
	    <cfquery name="qGetProgramDetails" datasource="#application.datasource#">      
		SELECT cm.Contract_Number,cm.Contract_Title<!---, Contract_Start_Date, Contract_End_Date--->
		FROM Contract_Main cm
		<cfif arguments.isContractNumber eq 1>
		WHERE cm.Contract_Number = <cfqueryparam value="#arguments.programID#" cfsqltype="CF_SQL_VARCHAR">
		AND cm.deleted = 0
		AND cm.Contract_Main_ID =
				(
				 SELECT MAX(Contract_Main_ID)
				 FROM Contract_Main
				 WHERE Contract_Number = cm.Contract_Number
				)
		<cfelse>
		WHERE cm.Contract_Main_ID = <cfqueryparam value="#arguments.programID#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
	    </cfquery>
	  
	   <cfreturn qGetProgramDetails>

	</cffunction>

	<!--- The operator should either be Active in the Operator Master table OR the Alias table should have it. (It is possible that the client supplied us with
	      an Alias for an inactive operator OR over time the operator has become inactive.)
	--->
	<cffunction name="getOperatorDetails" access="public" returntype="query"> 	  
	  <cfargument name="operatorID" type="string" required="true">
	  <cfargument name="isLegacyID" type="boolean" required="true">
	     
	    <cfquery name="qGetOperatorDetails" datasource="#application.datasource#">
		<!--- Active Operator Only --->	      
		SELECT BSA_Operator_ID, 
				Operator_Name,
				legacy_ID,
				Operator_City,
				Operator_State,
		CASE WHEN (legacy_ID IS NULL OR  legacy_ID  = '0') THEN
			0
		ELSE
			1
		END AS isAssigned  
		FROM BSA_Operator
		WHERE deleted = 0
		AND Display_Code = 'A'
	       <cfif arguments.isLegacyID eq 0>
		AND BSA_Operator_ID = <cfqueryparam value="#arguments.operatorID#" cfsqltype="CF_SQL_VARCHAR">
	       <cfelse>
		AND legacy_ID = <cfqueryparam value="#arguments.operatorID#" cfsqltype="CF_SQL_VARCHAR">
	       </cfif>
	    </cfquery>
	  
	   <cfreturn qGetOperatorDetails>

	</cffunction>
		     
	 <!--- The vendor should either be in the vendor Master table OR the Alias table should have it --->
	<cffunction name="getVendorDetails" access="public" returntype="query"> 
	  <cfargument name="vendorID" type="string" required="true">

	    <cfquery name="qGetVendorDetails" datasource="#application.datasource#">
		SELECT Vendor_Name,Vendor_ID,City,State 
		FROM Vendor_Master
		WHERE deleted = 0
		<!---AND Active_code = 'A'--->
		AND Vendor_ID = <cfqueryparam value="#arguments.vendorID#" cfsqltype="CF_SQL_VARCHAR">

		UNION
		
		<!--- Check if the vendor exists in the "SOURCE" table (BB_Claim_Source_XREF) --->
		SELECT DISTINCT vm.Vendor_Name,vm.Vendor_ID,vm.City,vm.State
		FROM Vendor_Master vm
		INNER JOIN BB_Claim_Source_XREF sxref
		ON vm.Vendor_ID = sxref.Source_Code
		WHERE sxref.deleted = 0
		AND vm.Vendor_ID = <cfqueryparam value="#arguments.vendorID#" cfsqltype="CF_SQL_VARCHAR">
		AND sxref.Active = 1
	    </cfquery>
	  
	   <cfreturn qGetVendorDetails>

	</cffunction>

	<!--- Check to see whether the "SOURCE" exists in the Main "SOURCE" lookup table --->
	<cffunction name="getSourceExists" access="public" returntype="query"> 
	  <cfargument name="sourceID" type="string" required="true">

	    <cfquery name="qGetSourceExists" datasource="#application.datasource#">
		SELECT BB_Claim_Source_XREF_ID
		FROM BB_Claim_Source_XREF
		WHERE Source_Code = <cfqueryparam value="#arguments.sourceID#" cfsqltype="CF_SQL_VARCHAR">
		AND Deleted = 0
		AND Active = 1
	    </cfquery>

	   <cfreturn qGetSourceExists>

	</cffunction>

	<!--- Query to get distributor aliases for a source --->
	<cffunction name="getDistributorAliasDetails" access="public" returntype="query">
		<cfargument name="sourceType" type="numeric" required="true">
		<cfargument name="sourceID" type="string" required="false" default="">
		<cfargument name="aliasID" type="string" required="false" default="">
		<cfargument name="arrAliasID" required="false" default="#ArrayNew(1)#">
		<cfargument name="startRow" type="numeric" required="false" default="0">
		<cfargument name="endRow" type="numeric" required="false" default="0">
		<cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
		<cfargument name="sortColumn" type="string" required="false" default="">
		<cfargument name="sortOrder" type="string" required="false" default="">

		<cfset var arrAliasIDList = "">
		<cfset var uploadShipToColumn = getUploadShipToColumn()>
		<cfset var end_row = arguments.endRow - arguments.startRow>

		<!--- When multiple alias Records are passed, make a comma-delimited list of it. --->
		<cfif IsArray(arguments.arrAliasID)>
			<cfif ArrayLen(arguments.arrAliasID) GT 0>
				<cfloop from="1" to="#ArrayLen(arguments.arrAliasID)#" index="i">
					<cfset arrAliasIDList =  ListAppend(arrAliasIDList,arguments.arrAliasID[i].aliasID)>
				</cfloop>
			</cfif>
		</cfif>

	    <cfquery name="qGetDistributorDetails" datasource="#application.datasource#">
		SELECT  *,Rows_Cnt = COUNT(1) OVER()
		FROM (
			SELECT DISTINCT dist_xref.BB_Claim_Dist_XREF_ID As recordID,dist_xref.External_Code as aliasID,dist_xref.External_Description As aliasDesc,
			dist_xref.Region As aliasRegion,dist_xref.Address As aliasAddress,dist_xref.City As aliasCity,dist_xref.State As aliasState,
			dist_xref.ZIP As aliasZIP,dist_xref.Unipro_Num As aliasUniproNum,dist_xref.Loc As aliasLoc, IsNull(dist_xref.Hold_Invoice_Count,0) As holdInvoiceCount,
			IsNull(bsafc.#uploadShipToColumn#,'') As entityID,IsNull(bsafc.Name,'') As entityDesc, '' As entityAddress,
			<!---bsafc.City,bsafc.State,--->
			CASE WHEN bsafc.#uploadShipToColumn# IS NULL THEN
				0
			ELSE
				1
			END AS isAssigned
			,dist_xref.Ignore As Unknown
			<!--- Only for "All Alias" --->
			<cfif sourceType eq 100>
				,CASE 
				<!--- If the source is not "Payee" (vendor), show the actual source --->
				WHEN source_xref.Source_Type != 2 THEN
				source_xref.Source_Code + ' ' + bbu.Source_Category 
				ELSE
				'PAYEE ALIAS'
				END
				As sourceTypeDesc
				,CASE 
				<!--- If the source is "Payee" (vendor), show the payee id --->
				WHEN source_xref.Source_Type = 2 THEN
				source_xref.Source_Code
				ELSE
				''
				END
				As payeeID
			<cfelseif arguments.sourceType EQ 1 AND (arguments.sourceID EQ "USFS" OR arguments.sourceID EQ "SYSCO")>
				,'PAYEE ALIAS' As sourceTypeDesc
				,IsNull(dist_xref.Vendor_ID,'') AS payeeID
			<cfelse>
				,'' As sourceTypeDesc
				,'' As payeeID
			</cfif>
			FROM BB_Claim_Source_XREF source_xref
			INNER JOIN BB_Upload_Source_Type_Lookup bbu
			ON bbu.Source_Type = source_xref.Source_Type
			INNER JOIN BB_Claim_Dist_XREF dist_xref 
			ON source_xref.Source_Code = dist_xref.Source_Code and
				dist_xref.BB_claim_source_xref_id = source_xref.BB_claim_source_xref_id
			LEFT JOIN BSA_Foodservice_Customers bsafc
			ON bsafc.#uploadShipToColumn# = dist_xref.shipTo

			<!--- Every source Type except "All Alias" --->
			<cfif sourceType neq 100>
			  WHERE source_xref.Source_Code = <cfqueryparam value="#arguments.sourceID#" cfsqltype="CF_SQL_VARCHAR">
			
			  <!--- single alias --->
			  <cfif arguments.aliasID neq "">
			  AND dist_xref.External_Code = <cfqueryparam value="#arguments.aliasID#" cfsqltype="CF_SQL_VARCHAR">
			  
			  <!--- multiple aliases --->
			  <cfelseif IsArray(arguments.arrAliasID) AND ArrayLen(arguments.arrAliasID) GT 0>			
			  AND dist_xref.External_Code IN
			  (
				#ListQualify(arrAliasIDList,"'",",","All")#
			  )
			  </cfif>

			</cfif>
			
			<!--- Get "All Alias" --->
			<cfif sourceType eq 100>
			WHERE 
			<CFELSE>
			AND
			</CFIF>
			
			(dist_xref.External_Code IS NOT NULL OR dist_xref.External_Description IS NOT NULL)
			AND
			(LEN(dist_xref.External_Code) != 0 OR LEN(dist_xref.External_Description) != 0)

			AND dist_xref.deleted = 0
			<!--- For every source Type except "All Alias" --->
			<cfif sourceType neq 100>
			AND source_xref.Source_Type = <cfqueryparam value="#arguments.sourceType#" cfsqltype="CF_SQL_NUMERIC">
			</cfif>
			
			<!--- "arguments.filterModel" struct will contain all the columns (struct key) on which the user has requested filter, like ALIASID etc. If the user has not requested
			filter on a column, then that entry (struct key) will not be in the struct. These struct key become a part of "filterModel" because the search filter is a part of the grid.
			Additionally, the user cam search on fields like "ISASSIGNED", "UNKNOWN" etc. These have been manually added to the "filterModel" struct on the front-end.
			--->
			<cfif StructCount(arguments.filterModel) GT 0>
				<cfloop collection="#arguments.filterModel#" item="SearchColumn">
					<cfif SearchColumn eq "ALIASID">AND dist_xref.External_Code</cfif>
					<cfif SearchColumn eq "ALIASDESC">AND dist_xref.External_Description</cfif>
					<cfif SearchColumn eq "ENTITYID">AND bsafc.#uploadShipToColumn#</cfif>
					<cfif SearchColumn eq "ENTITYDESC">AND bsafc.Name</cfif>
					<cfif SearchColumn eq "PAYEEID">AND IsNull(dist_xref.Vendor_ID,'')</cfif>
					<cfif SearchColumn eq "ALIASADDRESS">AND dist_xref.Address</cfif>
					<cfif SearchColumn eq "ALIASREGION">AND dist_xref.Region</cfif>
					<cfif SearchColumn eq "ALIASCITY">AND dist_xref.City</cfif>
					<cfif SearchColumn eq "ALIASSTATE">AND dist_xref.State</cfif>
					<cfif SearchColumn eq "ALIASZIP">AND dist_xref.ZIP</cfif>
					<cfif SearchColumn eq "ALIASUNIPRONUM">AND dist_xref.Unipro_Num</cfif>

					<!--- Do not do below for manually added keys like "ISASSIGNED", "UNKNOWN" etc, else it will throw an error --->
					<cfif SearchColumn neq "ISASSIGNED" AND SearchColumn neq "UNKNOWN">
						<!--- get the filter conditions --->
						<cfset qryConditions = application.util.query.getAGGridfilterConditions(arguments.filterModel[SearchColumn])>
						#PreserveSingleQuotes(qryConditions)#
					</cfif>
				</cfloop>

				<cfif arguments.filterModel.IsAssigned eq 0>
						AND bsafc.#uploadShipToColumn# IS NULL
				</cfif>
				<cfif arguments.filterModel.Unknown eq 1>
						AND dist_xref.Ignore = 1
				<cfelseif arguments.filterModel.Unknown eq 2>
						AND dist_xref.Ignore = 0			
				</cfif>
			</cfif>
			) AS tmp
				
		ORDER BY 
		<cfif arguments.sortColumn eq "">
		AliasID ASC
		<cfelse>
		#arguments.sortColumn# #arguments.sortOrder#
		</cfif>
		
		<!--- arguments.endRow is 0 when we call the query from Flex --->
		<cfif arguments.endRow gt 0>
		OFFSET #arguments.startRow# ROWS
		FETCH NEXT #end_row# ROWS ONLY
		</cfif>
	    </cfquery>

	   <cfreturn qGetDistributorDetails>
	</cffunction>

	<!--- Query to get item aliases for a source --->
	<cffunction name="getItemAliasDetails" access="public" returntype="query"> 
		<cfargument name="sourceType" type="numeric" required="true">
		<cfargument name="sourceID" type="string" required="false" default="">
		<cfargument name="aliasID" type="string" required="false" default="">
		<cfargument name="arrAliasID" type="Array" required="false" default="#ArrayNew(1)#">
		<cfargument name="startRow" type="numeric" required="false" default="0">
		<cfargument name="endRow" type="numeric" required="false" default="0">
		<cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
		<cfargument name="sortColumn" type="string" required="false" default="">
		<cfargument name="sortOrder" type="string" required="false" default="">

		<cfset var arrAliasIDList = "">
		<cfset var end_row = arguments.endRow - arguments.startRow>
	
		<!--- When multiple alias Records are passed, make a comma-delimited list of it. --->
		<cfif IsArray(arguments.arrAliasID)>
			<cfif ArrayLen(arguments.arrAliasID) GT 0>
				<cfloop from="1" to="#ArrayLen(arguments.arrAliasID)#" index="i">
					<cfset arrAliasIDList =  ListAppend(arrAliasIDList,arguments.arrAliasID[i].aliasID)>
				</cfloop>
			</cfif>
		</cfif>

	    <cfquery name="qGetItemDetails" datasource="#application.datasource#">
		SELECT  *,Rows_Cnt = COUNT(1) OVER()
		FROM (
			SELECT DISTINCT item_xref.BB_Claim_item_XREF_ID As recordID,item_xref.External_Code As aliasID,item_xref.External_Description As aliasDesc,
			IsNull(bsaim.Item,'') As entityID,IsNull(bsaim.Description,'') As entityDesc,'' As aliasAddress, '' As entityAddress,item_xref.Unknown,
			IsNull(item_xref.Hold_Invoice_Count,0) As holdInvoiceCount,'' As aliasLoc,'' As aliasUniproNum,'' As aliasZIP, '' As aliasState,'' As aliasCity,'' As aliasRegion,
			CASE WHEN bsaim.Item IS NULL THEN
				0
			ELSE
				1
			END AS isAssigned

			<!--- Only for "All Alias" --->
			<cfif sourceType eq 100>
			,CASE 
			<!--- If the source is not "Payee" (vendor), show the actual source --->
			WHEN source_xref.Source_Type != 2 THEN
			source_xref.Source_Code + ' ' + bbu.Source_Category 
			ELSE
			'PAYEE ALIAS'
			END
			As sourceTypeDesc
			,CASE 
			<!--- If the source is "Payee" (vendor), show the payee id --->
			WHEN source_xref.Source_Type = 2 THEN
			source_xref.Source_Code
			ELSE
			''
			END
			As payeeID
			<cfelse>
			,'' As sourceTypeDesc
			,'' As payeeID
			</cfif>

			FROM BB_Claim_Source_XREF source_xref
			INNER JOIN BB_Upload_Source_Type_Lookup bbu
			ON bbu.Source_Type = source_xref.Source_Type
			INNER JOIN BB_Claim_Item_XREF item_xref 
			ON source_xref.Source_Code = item_xref.Source_Code and
				item_xref.BB_claim_source_xref_id = source_xref.BB_claim_source_xref_id
			LEFT JOIN BSA_Foodservice_Items_Master bsaim
			ON bsaim.item = item_xref.item

			<!--- Every source Type except "All Alias" --->
			<cfif sourceType neq 100>
			  WHERE source_xref.Source_Code = <cfqueryparam value="#arguments.sourceID#" cfsqltype="CF_SQL_VARCHAR">
			  
			  <!--- single alias --->
			  <cfif arguments.aliasID neq "">
			  AND item_xref.External_Code = <cfqueryparam value="#arguments.aliasID#" cfsqltype="CF_SQL_VARCHAR">
			  
			  <!--- multiple aliases --->
			  <cfelseif ArrayLen(arguments.arrAliasID) GT 0>			
			  AND item_xref.External_Code IN
			  (
				#ListQualify(arrAliasIDList,"'",",","All")#
			  )
			  </cfif>

			</cfif>

			<!--- Get "All Alias" --->
			<cfif sourceType eq 100>
			WHERE 
			<CFELSE>
			AND
			</CFIF>

			(item_xref.External_Code IS NOT NULL OR item_xref.External_Description IS NOT NULL)
			AND
			(LEN(item_xref.External_Code) != 0 OR LEN(item_xref.External_Description) != 0)

			AND item_xref.deleted = 0
			<!--- For every source Type except "All Alias" --->
			<cfif sourceType neq 100>
			AND source_xref.Source_Type = <cfqueryparam value="#arguments.sourceType#" cfsqltype="CF_SQL_NUMERIC">
			</cfif>
			<!--- "arguments.filterModel" struct will contain all the columns (struct key) on which the user has requested filter, like ALIASID etc. If the user has not requested
			filter on a column, then that entry (struct key) will not be in the struct. These struct key become a part of "filterModel" because the search filter is a part of the grid.
			Additionally, the user cam search on fields like "ISASSIGNED", "UNKNOWN" etc. These have been manually added to the "filterModel" struct on the front-end.
			--->
			<cfif StructCount(arguments.filterModel) GT 0>
				<cfloop collection="#arguments.filterModel#" item="SearchColumn">
					<cfif SearchColumn eq "ALIASID">AND item_xref.External_Code</cfif>
					<cfif SearchColumn eq "ALIASDESC">AND item_xref.External_Description</cfif>
					<cfif SearchColumn eq "ENTITYID">AND bsaim.Item</cfif>
					<cfif SearchColumn eq "ENTITYDESC">AND bsaim.Description</cfif>
					<!--- Do not do below for manually added keys like "ISASSIGNED", "UNKNOWN" etc, else it will throw an error --->
					<cfif SearchColumn neq "ISASSIGNED" AND SearchColumn neq "UNKNOWN">
						<!--- get the filter conditions --->
						<cfset qryConditions = application.util.query.getAGGridfilterConditions(arguments.filterModel[SearchColumn])>
						#PreserveSingleQuotes(qryConditions)#
					</cfif>
				</cfloop>
			
				<cfif arguments.filterModel.IsAssigned eq 0>
						AND bsaim.Item IS NULL
				</cfif>
				<cfif arguments.filterModel.Unknown eq 1>
						AND item_xref.Unknown = 1
				<cfelseif arguments.filterModel.Unknown eq 2>
						AND item_xref.Unknown = 0			
				</cfif>
			</cfif>
			) AS tmp

		ORDER BY		
		<cfif arguments.sortColumn eq "">
		AliasID ASC
		<cfelse>
		#arguments.sortColumn# #arguments.sortOrder#
		</cfif>

		<!--- arguments.endRow is 0 when we call the query from Flex --->
		<cfif arguments.endRow gt 0>
		OFFSET #arguments.startRow# ROWS
		FETCH NEXT #end_row# ROWS ONLY
		</cfif>
	    </cfquery>

	   <cfreturn qGetItemDetails>

	</cffunction>

	<!--- Query to get program aliases for a source --->
	<cffunction name="getprogramAliasDetails" access="public" returntype="query"> 
		<cfargument name="sourceType" type="numeric" required="true">
		<cfargument name="sourceID" type="string" required="false" default="">
		<cfargument name="aliasID" type="string" required="false" default="">
		<cfargument name="arrAliasID" type="Array" required="false" default="#ArrayNew(1)#">
		<cfargument name="startRow" type="numeric" required="false" default="0">
		<cfargument name="endRow" type="numeric" required="false" default="0">
		<cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
		<cfargument name="sortColumn" type="string" required="false" default="">
		<cfargument name="sortOrder" type="string" required="false" default="">

		<cfset var arrAliasIDList = "">
		<cfset var end_row = arguments.endRow - arguments.startRow>
	
		<!--- When multiple alias Records are passed, make a comma-delimited list of it. --->
		<cfif IsArray(arguments.arrAliasID)>
			<cfif ArrayLen(arguments.arrAliasID) GT 0>
				<cfloop from="1" to="#ArrayLen(arguments.arrAliasID)#" index="i">
					<cfset arrAliasIDList =  ListAppend(arrAliasIDList,arguments.arrAliasID[i].aliasID)>
				</cfloop>
			</cfif>
		</cfif>

	    <cfquery name="qGetProgramDetails" datasource="#application.datasource#">
		 SELECT  *,Rows_Cnt = COUNT(1) OVER()
		 FROM (
			SELECT DISTINCT program_xref.BB_Claim_Program_XREF_ID As recordID,program_xref.External_Code As aliasID,program_xref.External_Description As aliasDesc,
			IsNull(program_xref.Hold_Invoice_Count,0) As holdInvoiceCount, '' As aliasAddress, '' As entityAddress,
			IsNull(cm.Contract_Number,'') AS entityID,IsNull(cm.Contract_Title,'') As entityDesc,
			'' As aliasLoc,'' As aliasUniproNum,'' As aliasZIP, '' As aliasState,'' As aliasCity,'' As aliasRegion,
			CASE WHEN cm.Contract_Number IS NULL THEN
				0
			ELSE
				1
			END AS isAssigned
			,program_xref.Ignore As Unknown
			<!--- Only for "All Alias" --->
			<cfif sourceType eq 100>
			,CASE 
			<!--- If the source is not "Payee" (vendor), show the actual source --->
			WHEN source_xref.Source_Type != 2 THEN
			source_xref.Source_Code + ' ' + bbu.Source_Category 
			ELSE
			'PAYEE ALIAS'
			END
			As sourceTypeDesc
			,CASE 
			<!--- If the source is "Payee" (vendor), show the payee id --->
			WHEN source_xref.Source_Type = 2 THEN
			source_xref.Source_Code
			ELSE
			''
			END
			As payeeID
			<cfelse>
			,'' As sourceTypeDesc
			,'' As payeeID
			</cfif>

			FROM BB_Claim_Source_XREF source_xref
			INNER JOIN BB_Upload_Source_Type_Lookup bbu
			ON bbu.Source_Type = source_xref.Source_Type
			INNER JOIN BB_Claim_Program_XREF program_xref
			ON source_xref.Source_Code = program_xref.Source_Code and
				program_xref.BB_claim_source_xref_id = source_xref.BB_claim_source_xref_id
			LEFT JOIN Contract_Main cm
			ON cm.contract_number = program_xref.contract_number
			AND cm.deleted = 0

			<!--- Every source Type except "All Alias" --->
			<cfif sourceType neq 100>
			  WHERE source_xref.Source_Code = <cfqueryparam value="#arguments.sourceID#" cfsqltype="CF_SQL_VARCHAR">
			  
			  <!--- single alias --->
			  <cfif arguments.aliasID neq "">
			  AND program_xref.External_Code = <cfqueryparam value="#arguments.aliasID#" cfsqltype="CF_SQL_VARCHAR">
			  
			   <!--- multiple aliases --->
			  <cfelseif ArrayLen(arguments.arrAliasID) GT 0>			
			  AND program_xref.External_Code IN
			  (
				#ListQualify(arrAliasIDList,"'",",","All")#
			  )
			  </cfif>

			</cfif>

			<!--- Get "All Alias" --->
			<cfif sourceType eq 100>
			WHERE 
			<CFELSE>
			AND
			</CFIF>

			(program_xref.External_Code IS NOT NULL OR program_xref.External_Description IS NOT NULL)
			AND
			(LEN(program_xref.External_Code) != 0 OR LEN(program_xref.External_Description) != 0)

				AND 
			(	<!--- Here MAX is useful when multiple programs have deleted = 0 --->
				cm.Contract_Main_ID =
				(
				 SELECT MAX(Contract_Main_ID)
				 FROM Contract_Main
				 WHERE Contract_Number = cm.Contract_Number
				 AND deleted = 0
				)
				OR	
				(<!---  There could have been aliases which do not have a program assigned as yet. --->
				 cm.Contract_Number IS NULL	
				)
			)
			AND program_xref.deleted = 0
			<!--- For every source Type except "All Alias" --->
			<cfif sourceType neq 100>
			AND source_xref.Source_Type = <cfqueryparam value="#arguments.sourceType#" cfsqltype="CF_SQL_NUMERIC">
			</cfif>
			<!--- "arguments.filterModel" struct will contain all the columns (struct key) on which the user has requested filter, like ALIASID etc. If the user has not requested
			filter on a column, then that entry (struct key) will not be in the struct. These struct key become a part of "filterModel" because the search filter is a part of the grid.
			Additionally, the user cam search on fields like "ISASSIGNED", "UNKNOWN" etc. These have been manually added to the "filterModel" struct on the front-end.
			--->
			<cfif StructCount(arguments.filterModel) GT 0>
				<cfloop collection="#arguments.filterModel#" item="SearchColumn">
					<cfif SearchColumn eq "ALIASID">AND program_xref.External_Code</cfif>
					<cfif SearchColumn eq "ALIASDESC">AND program_xref.External_Description</cfif>
					<cfif SearchColumn eq "ENTITYID">AND cm.Contract_Number</cfif>
					<cfif SearchColumn eq "ENTITYDESC">AND cm.Contract_Title</cfif>
					<!--- Do not do below for manually added keys like "ISASSIGNED", "UNKNOWN" etc, else it will throw an error --->
					<cfif SearchColumn neq "ISASSIGNED" AND SearchColumn neq "UNKNOWN">
						<!--- get the filter conditions --->
						<cfset qryConditions = application.util.query.getAGGridfilterConditions(arguments.filterModel[SearchColumn])>
						#PreserveSingleQuotes(qryConditions)#
					</cfif>
				</cfloop>
			
				<cfif arguments.filterModel.IsAssigned eq 0>
						AND cm.Contract_Number IS NULL
				</cfif>

				<cfif arguments.filterModel.Unknown eq 1>
						AND program_xref.Ignore = 1
				<cfelseif arguments.filterModel.Unknown eq 2>
						AND program_xref.Ignore = 0			
				</cfif>
			</cfif>
			) AS tmp

		ORDER BY		
		<cfif arguments.sortColumn eq "">
		AliasID ASC
		<cfelse>
		#arguments.sortColumn# #arguments.sortOrder#
		</cfif>

		<!--- arguments.endRow is 0 when we call the query from Flex --->
		<cfif arguments.endRow gt 0>
		OFFSET #arguments.startRow# ROWS
		FETCH NEXT #end_row# ROWS ONLY
		</cfif>
	    </cfquery>
	  
	   <cfreturn qGetProgramDetails>
	</cffunction>
	
	<!--- Query to get operator aliases for a source --->
	<cffunction name="getOperatorAliasDetails" access="public" returntype="query">
		<cfargument name="sourceType" type="numeric" required="true">
		<cfargument name="sourceID" type="string" required="false" default="">
		<cfargument name="aliasID" type="string" required="false" default="">
		<cfargument name="arrAliasID" type="Array" required="false" default="#ArrayNew(1)#">
		<cfargument name="startRow" type="numeric" required="false" default="0">
		<cfargument name="endRow" type="numeric" required="false" default="0">
		<cfargument name="filterModel" type="any" required="false" default=#StructNew()#>
		<cfargument name="sortColumn" type="string" required="false" default="">
		<cfargument name="sortOrder" type="string" required="false" default="">
		<cfargument name="address2" type="numeric" required="false" default="0">

		<cfset var arrAliasIDList = "">
		<cfset var end_row = arguments.endRow - arguments.startRow>
	
		<!--- When multiple alias Records are passed, make a comma-delimited list of it. --->
		<cfif IsArray(arguments.arrAliasID)>
			<cfif ArrayLen(arguments.arrAliasID) GT 0>
				<cfloop from="1" to="#ArrayLen(arguments.arrAliasID)#" index="i">
					<cfset arrAliasIDList =  ListAppend(arrAliasIDList,arguments.arrAliasID[i].aliasID)>
				</cfloop>
			</cfif>
		</cfif>

		<!--- When "Allow_Multiple_Operator_Xref" in the billback settings table is ON, then we can have same aliases for multiple operators.
			  In that case, we want the last inserted record. By using "TOP 1", we can get to that record.
		--->
	    <cfquery name="qGetOperatorDetails" datasource="#application.datasource#">
		 SELECT  *,Rows_Cnt = COUNT(1) OVER()
		 FROM (
			SELECT DISTINCT <cfif arguments.aliasID neq "">TOP 1</cfif> 
				OPR_XREF.BB_Claim_Operator_XREF_ID As recordID,
				OPR_XREF.External_Code As aliasID,
				LTRIM(RTrim(OPR_XREF.External_Description)) AS aliasDesc,
				LTRIM(RTrim(OPR_XREF.Address)) + ' ' + LTRIM(RTrim(ISNULL(OPR_XREF.Address_2, '')))
				<cfif arguments.address2 eq 1>
					+ ' ' + LTRIM(RTrim(OPR_XREF.City)) + ', ' +  LTRIM(RTrim(OPR_XREF.State)) + ' ' + OPR_XREF.Zip
				</cfif>
				 AS aliasAddress,
				LTRIM(RTrim(OPR_XREF.City)) AS City,
				LTRIM(RTrim(OPR_XREF.State)) AS State,
				OPR_XREF.Zip,
				IsNull(OPR_XREF.Hold_Invoice_Count,0) As holdInvoiceCount,
				OPR_XREF.Ignore As Unknown,
				BSAOP.BSA_Operator_ID As bsaId,
				IsNull(BSAOP.legacy_ID,'') As entityID,
				IsNull(LTRIM(RTrim(BSAOP.Operator_Name)),'') AS entityDesc,
				/* These fields (address related) have been added because the client wants to see the data from the loaded file to differentiate between
				between records and that is why the data does not come from the BSA_operators table. This solution is a quick fix.
				*/
				LTRIM(RTrim(BSAOP.Operator_Address)) AS entityAddress,
				LTRIM(RTrim(BSAOP.Operator_City)) AS Operator_City,
				LTRIM(RTrim(BSAOP.Operator_State)) AS Operator_State,
				BSAOP.Operator_Zip,
				'' As aliasLoc,
				'' As aliasUniproNum,
				OPR_XREF.Zip As aliasZIP, 
				'' As aliasState,
				'' As aliasCity,
				'' As aliasRegion,
			CASE WHEN BSAOP.legacy_ID IS NULL THEN
				0
			ELSE
				1
			END AS isAssigned
					
			<!--- Only for "All Alias" --->
			<cfif sourceType eq 100>
			,CASE 
			<!--- If the source is not "Payee" (vendor), show the actual source --->
			WHEN source_xref.Source_Type != 2 THEN
			source_xref.Source_Code + ' ' + bbu.Source_Category 
			ELSE
			'PAYEE ALIAS'
			END
			As sourceTypeDesc
			,CASE 
			<!--- If the source is "Payee" (vendor), show the payee id --->
			WHEN source_xref.Source_Type = 2 THEN
			source_xref.Source_Code
			ELSE
			''
			END
			As payeeID
			<cfelse>
			,source_xref.Source_Code As sourceTypeDesc
			,'' As payeeID
			</cfif>

			FROM BB_Claim_Source_XREF source_xref
			INNER JOIN BB_Upload_Source_Type_Lookup bbu
			ON bbu.Source_Type = source_xref.Source_Type
			INNER JOIN BB_Claim_Operator_XREF OPR_XREF
			ON source_xref.Source_Code = OPR_XREF.Source_Code  and
				OPR_XREF.BB_claim_source_xref_id = source_xref.BB_claim_source_xref_id
			LEFT JOIN BSA_Operator BSAOP
			ON BSAOP.legacy_ID = OPR_XREF.Operator_Number
				AND ISNULL(OPR_XREF.BSA_Operator_ID,BSAOP.BSA_Operator_ID) = BSAOP.BSA_Operator_ID

			<!--- Every source Type except "All Alias" --->
			<cfif sourceType neq 100>
			  WHERE source_xref.Source_Code = <cfqueryparam value="#arguments.sourceID#" cfsqltype="CF_SQL_VARCHAR">
			  
			  <!--- single alias --->
			  <cfif arguments.aliasID neq "">
			  AND OPR_XREF.External_Code = <cfqueryparam value="#arguments.aliasID#" cfsqltype="CF_SQL_VARCHAR">
			  
			  <!--- multiple aliases --->
			  <cfelseif ArrayLen(arguments.arrAliasID) GT 0>	
			  <!--- When "Allow_Multiple_Operator_Xref" in the billback settings table is ON, then we can have same alias for multiple operators.
			  In this case, the number of records returned for might be more than that number of aliases in the comma-delimited string.
			  --->
			  AND OPR_XREF.External_Code IN
			  (
				#ListQualify(arrAliasIDList,"'",",","All")#
			  )
			  </cfif>

			</cfif>

			<!--- Get "All Alias" --->
			<cfif sourceType eq 100>
			WHERE 
			<CFELSE>
			AND
			</CFIF>

			(OPR_XREF.External_Code IS NOT NULL OR OPR_XREF.External_Description IS NOT NULL)	
			AND
			(LEN(OPR_XREF.External_Code) != 0 OR LEN(OPR_XREF.External_Description) != 0)

			AND OPR_XREF.deleted = 0
			--AND External_Code in ('000000148 - CAROLINA BUTTERBALL-DOD NAPA', '000000137 - CAROLINA BUTTERBALL-DOD NAPA')
			<!--- For every source Type except "All Alias" --->
			<cfif sourceType neq 100>
			AND source_xref.Source_Type = <cfqueryparam value="#arguments.sourceType#" cfsqltype="CF_SQL_NUMERIC">
			</cfif>
			<!--- "arguments.filterModel" struct will contain all the columns (struct key) on which the user has requested filter, like ALIASID etc. If the user has not requested
			filter on a column, then that entry (struct key) will not be in the struct. These struct key become a part of "filterModel" because the search filter is a part of the grid.
			Additionally, the user cam search on fields like "ISASSIGNED", "UNKNOWN" etc. These have been manually added to the "filterModel" struct on the front-end.
			--->
			<cfif StructCount(arguments.filterModel) GT 0>
				<cfloop collection="#arguments.filterModel#" item="SearchColumn">
					<cfif SearchColumn eq "ALIASID">AND OPR_XREF.External_Code</cfif>
					<cfif SearchColumn eq "ALIASDESC">AND OPR_XREF.External_Description</cfif>
					<cfif SearchColumn eq "ENTITYID">AND BSAOP.legacy_ID</cfif>
					<cfif SearchColumn eq "ENTITYDESC">AND BSAOP.Operator_Name</cfif>
					<cfif SearchColumn eq "ENTITYADDRESS">AND BSAOP.Operator_Address</cfif>
					<cfif SearchColumn eq "ALIASADDRESS">AND ( OPR_XREF.Address</cfif>
					<!--- Do not do below for manually added keys like "ISASSIGNED", "UNKNOWN" etc, else it will throw an error --->
					<cfif SearchColumn neq "ISASSIGNED" AND SearchColumn neq "UNKNOWN">
						<!--- get the filter conditions --->
						<cfset qryConditions = application.util.query.getAGGridfilterConditions(arguments.filterModel[SearchColumn])>
						<cfset qryConditionState = Replace(application.util.query.getAGGridfilterConditions(arguments.filterModel[SearchColumn]),", ","")/>
						#PreserveSingleQuotes(qryConditions)#
						<cfif SearchColumn eq "ALIASADDRESS"> OR OPR_XREF.Address_2 #PreserveSingleQuotes(qryConditions)# OR OPR_XREF.City #PreserveSingleQuotes(qryConditions)# OR OPR_XREF.State #PreserveSingleQuotes(qryConditions)# OR OPR_XREF.State #PreserveSingleQuotes(qryConditionState)# OR OPR_XREF.Zip #PreserveSingleQuotes(qryConditions)#)</cfif>
					</cfif>
				</cfloop>
			
				<cfif arguments.filterModel.IsAssigned eq 0>
						AND BSAOP.legacy_ID IS NULL
				</cfif>

				<cfif arguments.filterModel.Unknown eq 1>
						AND OPR_XREF.Ignore = 1
				<cfelseif arguments.filterModel.Unknown eq 2>
						AND OPR_XREF.Ignore = 0			
				</cfif>
			</cfif>

			<!--- When "Allow_Multiple_Operator_Xref" in the billback settings table is ON, then we can have same aliases for multiple operators.
				  In that case, we want the last inserted record. By using "ORDER BY OPR_XREF.BB_Claim_Operator_XREF_ID	DESC", we can get to that record.
			--->
			) AS tmp

		<cfif arguments.aliasID neq ""> 
			ORDER BY recordID DESC 
		<cfelse>
			ORDER BY		
			<cfif arguments.sortColumn eq "">
			AliasID ASC
			<cfelse>
			#arguments.sortColumn# #arguments.sortOrder#
			</cfif>		
		</cfif>

		<!--- arguments.endRow is 0 when we call the query from Flex --->
		<cfif arguments.endRow gt 0>
		OFFSET #arguments.startRow# ROWS
		FETCH NEXT #end_row# ROWS ONLY
		</cfif>
	    </cfquery>

	   <cfreturn qGetOperatorDetails>
	</cffunction>
	
	<!--- Query to save a new "SOURCE" and then the "ALIAS" for the new "SOURCE" --->
	<cffunction name="saveSourceAlias" access="public" returntype="void">
	  <cfargument name="entityType" type="numeric" required="true">
	  <cfargument name="aliasDef" required="true">
	  <cfargument name="userID" type="string" required="true">

	    <cfquery name="qSaveSourceAlias" datasource="#application.datasource#">
		DECLARE @BB_Claim_Source_XREF_ID INT
		<!--- This code will not be called for EDI as EDI is already hard-coded in the "BB_Claim_Source_XREF" table.
		      The source_Type for Vendor is "2". 
		--->
		INSERT INTO BB_Claim_Source_XREF(Source_Type,Source_Type_Description,Source_Code,Created_By)
			VALUES('2','VENDOR',<cfqueryparam value="#arguments.aliasDef.sourceID#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR">
			)

		SET @BB_Claim_Source_XREF_ID = SCOPE_IDENTITY()
	        SELECT BB_Claim_Source_XREF_ID = @BB_Claim_Source_XREF_ID
	    </cfquery>
	      
	      <!--- Save "Alias" for the newly added "SOURCE" --->
	      <cfif entityType eq 0>
		<cfset saveDistributorAliasDetails(arguments.aliasDef,qSaveSourceAlias.BB_Claim_Source_XREF_ID,arguments.userID)>
	      <cfelseif entityType eq 1>
		<cfset saveItemAliasDetails(arguments.aliasDef,qSaveSourceAlias.BB_Claim_Source_XREF_ID,arguments.userID)>
	      <cfelseif entityType eq 2>
		<cfset saveProgramAliasDetails(arguments.aliasDef,qSaveSourceAlias.BB_Claim_Source_XREF_ID,arguments.userID)>
	      <cfelseif entityType eq 3>
		<cfset saveOperatorAliasDetails(arguments.aliasDef,qSaveSourceAlias.BB_Claim_Source_XREF_ID,arguments.userID)>
	      </cfif>

	</cffunction>

	<!--- Save the "DISTRIBUTOR ALIASES" for an existing "SOURCE" --->
	<cffunction name="saveDistributorAliasDetails" access="public" returntype="boolean"> 
	  <cfargument name="aliasDef" required="true">
	  <cfargument name="BBClaimSourceXREFID" type="numeric" required="true">
	  <cfargument name="userID" type="string" required="true">

	  <cfset var bGetAliasExists = 0>
	     
	    <!--- Check to see whether the same "Alias" already exists for the source --->
	    <cfset qGetAliasExists = getAliasExists(arguments.aliasDef,0)>
	      
		 <cfquery name="qDistributorAliasExistingID" datasource="#application.datasource#">
		  SELECT Count(*) As ExistingID
		  FROM BB_Claim_Dist_XREF
		  WHERE BB_Claim_Dist_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_NUMERIC">
		 </cfquery>
		
		 <!--- If the "ALIAS" already exists for the source --->
		 <cfif  qGetAliasExists.xref_ID neq "">
			<cfset bGetAliasExists = 1>
		 <cfelse>
			<cfset bGetAliasExists = 0>
		 </cfif>
				   
		   <!--- If it is a newly added "ALIAS" for the source (i.e. this record did not exist in the db and so the user entered a 
		        new Alias and Alias Desc and Dist and Dist Desc. This entry did not exist at all)
		   --->
		   <cfif qDistributorAliasExistingID.ExistingID eq 0 AND qGetAliasExists.xref_ID eq "">
			
			<!--- Insert the new Source/Alias combination --->
			<cfquery name="qSaveDistributorAliasDetails" datasource="#application.datasource#">
			INSERT INTO BB_Claim_Dist_XREF(BB_Claim_Source_XREF_ID,Source_Code,External_Code,External_Description,Shipto,
							Region,Address,City,State,ZIP,Unipro_Num,Loc,Created_By
							<cfif IsDefined("arguments.aliasDef.Unknown")>
							,Ignore
							</cfif>
							)
				VALUES(<cfqueryparam value="#arguments.BBClaimSourceXREFID#" cfsqltype="CF_SQL_NUMERIC">,
					<cfqueryparam value="#arguments.aliasDef.sourceID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.aliasID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#trim(arguments.aliasDef.aliasDesc)#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">,					
					<cfqueryparam value="#trim(arguments.aliasDef.aliasRegion)#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.aliasRegion)#">,
					<cfqueryparam value="#trim(arguments.aliasDef.aliasAddress)#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.aliasAddress)#">,
					<cfqueryparam value="#trim(arguments.aliasDef.aliasCity)#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.aliasCity)#">,
					<cfqueryparam value="#trim(arguments.aliasDef.aliasState)#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.aliasState)#">,
					<cfqueryparam value="#trim(arguments.aliasDef.aliasZIP)#" cfsqltype="CF_SQL_VARCHAR "NULL="#NOT len(arguments.aliasDef.aliasZIP)#">,
					<cfqueryparam value="#trim(arguments.aliasDef.aliasUniproNum)#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.aliasUniproNum)#">,
					<cfqueryparam value="#trim(arguments.aliasDef.aliasLoc)#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.aliasLoc)#">,
					<cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR">
					<cfif IsDefined("arguments.aliasDef.Unknown")>
					,<cfqueryparam value="#arguments.aliasDef.Unknown#" cfsqltype="CF_SQL_BIT">
					</cfif>
					)
			</cfquery>

		    <cfelse>
		     
		     <!--- If this record already exists, then just update it. Do not update record, if the same alias already exists for some other record.	     
			   Note: we could change any part of the record: Alias/Alias Desc/Dist ID (ship to)
			   -- qGetAliasExists.xref_ID EQ "" means no duplcate record found.
			   -- arguments.aliasDef.recordID eq qGetAliasExists.xref_ID means same record.
		     --->
		     <cfif qDistributorAliasExistingID.ExistingID eq 1 AND (qGetAliasExists.xref_ID EQ "" OR (arguments.aliasDef.recordID eq qGetAliasExists.xref_ID))>
			
			<cfset UpdateDistributorAliasDetails(arguments.aliasDef)>
		     </cfif>

		    </cfif>

	   <!--- The only way this will return true is when it is a new record, i.e. a new Alias and Alias Desc and Distributor ID and the same Alias already exists
		  for the vendor.
	   --->
	   <cfreturn bGetAliasExists>

	</cffunction>

	<!--- Save the " ITEM ALIASES" for an existing "SOURCE" --->
	<cffunction name="saveItemAliasDetails" access="public" returntype="boolean"> 
	  <cfargument name="aliasDef" required="true">
	  <cfargument name="BBClaimSourceXREFID" type="numeric" required="true">
	  <cfargument name="userID" type="string" required="true">

	  <cfset var bGetAliasExists = 0>
	     
	    <!--- Check to see whether the same "Alias" already exists for the source --->
	    <cfset qGetAliasExists = getAliasExists(arguments.aliasDef,1)>

		 <cfquery name="qItemAliasExistingID" datasource="#application.datasource#">
		  SELECT Count(*) As ExistingID
		  FROM BB_Claim_Item_XREF
		  WHERE BB_Claim_Item_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_NUMERIC">
		 </cfquery>
		
		 <!--- If the "ALIAS" already exists for the source --->
		 <cfif  qGetAliasExists.xref_ID neq "">
			<cfset bGetAliasExists = 1>
		 <cfelse>
			<cfset bGetAliasExists = 0>
		 </cfif>
		   
		   <!--- If it is a newly added "ALIAS" for the source (i.e. this record did not exist in the db and so the user entered a 
		        new Alias and Alias Desc and Program and Program Desc (Title). This entry did not exist at all)
		   --->
		   <cfif qItemAliasExistingID.ExistingID eq 0 AND qGetAliasExists.xref_ID eq "">
			
			<!--- Insert the new Source/Alias combination --->
			<cfquery name="qSaveItemAliasDetails" datasource="#application.datasource#">
			INSERT INTO BB_Claim_Item_XREF(BB_Claim_Source_XREF_ID,Source_Code,External_Code,External_Description,Item,Created_By
			<!--- This is being used from the "alias upload fixer" and not the regular alias tool --->
			<cfif IsDefined("arguments.aliasDef.Unknown")>
			,Unknown
			</cfif>
			)
				VALUES(<cfqueryparam value="#arguments.BBClaimSourceXREFID#" cfsqltype="CF_SQL_NUMERIC">,
					<cfqueryparam value="#arguments.aliasDef.sourceID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.aliasID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.aliasDesc#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR">
					<!--- This is being used from the "alias upload fixer" and not the regular alias tool --->
					<cfif IsDefined("arguments.aliasDef.Unknown")>
					,<cfqueryparam value="#arguments.aliasDef.Unknown#" cfsqltype="CF_SQL_BIT">
					</cfif>
					)
			</cfquery>

		    <cfelse>
		     
		     <!--- If this record already exists, then just update it. Do not update record, if the same alias already exists for some other record.	     
			   Note: we could change any part of the record: Alias/Alias Desc/Item ID (Item)
			   -- qGetAliasExists.xref_ID EQ "" means no duplcate record found.
			   -- arguments.aliasDef.recordID eq qGetAliasExists.xref_ID means same record.
		     --->
		     <cfif qItemAliasExistingID.ExistingID eq 1  AND (qGetAliasExists.xref_ID EQ "" OR (arguments.aliasDef.recordID eq qGetAliasExists.xref_ID))>			
			<cfset UpdateItemAliasDetails(arguments.aliasDef)>
		     </cfif>

		    </cfif>

	   <!--- The only way this will return true is when it is a new record, i.e. a new Alias and Alias Desc and Item ID and the same Alias already exists
		  for the vendor.
	   --->
	   <cfreturn bGetAliasExists>

	</cffunction>

	<!--- Save the "PROGRAM ALIASES" for an existing "SOURCE" --->
	<cffunction name="saveProgramAliasDetails" access="public" returntype="boolean"> 
	  <cfargument name="aliasDef" required="true">
	  <cfargument name="BBClaimSourceXREFID" type="numeric" required="true">
	  <cfargument name="userID" type="string" required="true">

	  <cfset var bGetAliasExists = 0>
	     
	    <!--- Check to see whether the same "Alias" already exists for the source --->
	    <cfset qGetAliasExists = getAliasExists(arguments.aliasDef,2)>
		
		 <cfquery name="qProgramAliasExistingID" datasource="#application.datasource#">
		  SELECT Count(*) As ExistingID
		  FROM BB_Claim_Program_XREF
		  WHERE BB_Claim_Program_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_NUMERIC">
		 </cfquery>		 
		
		 <!--- If the "ALIAS" already exists for the source --->
		 <cfif  qGetAliasExists.xref_ID neq "">
			<cfset bGetAliasExists = 1>
		 <cfelse>
			<cfset bGetAliasExists = 0>
		 </cfif>

		   <!--- If it is a newly added "ALIAS" for the source (i.e. this record did not exist in the db and so the user entered a 
		        new Alias and Alias Desc and Program and Program Desc (Title). This entry did not exist at all)
		   --->
		   <cfif qProgramAliasExistingID.ExistingID eq 0 AND qGetAliasExists.xref_ID eq "">
			
			<!--- Insert the new Source/Alias combination --->
			<cfquery name="qSaveProgramAliasDetails" datasource="#application.datasource#">
			INSERT INTO BB_Claim_Program_XREF(BB_Claim_Source_XREF_ID,Source_Code,External_Code,External_Description,Contract_Number,Created_By
							<cfif IsDefined("arguments.aliasDef.Unknown")>
							,Ignore
							</cfif>
							)
				VALUES(<cfqueryparam value="#arguments.BBClaimSourceXREFID#" cfsqltype="CF_SQL_NUMERIC">,
					<cfqueryparam value="#arguments.aliasDef.sourceID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.aliasID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.aliasDesc#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR">
					<cfif IsDefined("arguments.aliasDef.Unknown")>
					,<cfqueryparam value="#arguments.aliasDef.Unknown#" cfsqltype="CF_SQL_BIT">
					</cfif>
					)
			</cfquery>

		    <cfelse>
		     
		     <!--- If this record already exists, then just update it. Do not update record, if the same alias already exists for some other record.	     
			   Note: we could change any part of the record: Alias/Alias Desc/Program ID (Contract_Number)
			   -- qGetAliasExists.xref_ID EQ "" means no duplcate record found.
			   -- arguments.aliasDef.recordID eq qGetAliasExists.xref_ID means same record.
		     --->	
		     <cfif qProgramAliasExistingID.ExistingID eq 1 AND (qGetAliasExists.xref_ID EQ "" OR (arguments.aliasDef.recordID eq qGetAliasExists.xref_ID))>
			<cfset UpdateProgramAliasDetails(arguments.aliasDef)>
		     </cfif>

		    </cfif>

	   <cfreturn bGetAliasExists>

	</cffunction>

	<!--- Save the "OPERATOR ALIASES" for an existing "SOURCE" --->
	<cffunction name="saveOperatorAliasDetails" access="public" returntype="boolean"> 
	  <cfargument name="aliasDef" required="true">
	  <cfargument name="BBClaimSourceXREFID" type="numeric" required="true">
	  <cfargument name="userID" type="string" required="true">

	  <cfset var bGetAliasExists = 0>
	     
	    <!--- Check to see whether the same "Alias" already exists for the source --->
	    <cfset qGetAliasExists = getAliasExists(arguments.aliasDef,3)>
	      
		 <cfquery name="qOperatorAliasExistingID" datasource="#application.datasource#">
		  SELECT Count(*) As ExistingID
		  FROM BB_Claim_Operator_XREF
		  WHERE BB_Claim_Operator_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_NUMERIC">
		 </cfquery>
		
		 <!--- If the "ALIAS" already exists for the source --->
		 <cfif  qGetAliasExists.xref_ID neq "">
			<cfset bGetAliasExists = 1>
		 <cfelse>
			<cfset bGetAliasExists = 0>
		 </cfif>
		   
		   <!--- If it is a newly added "ALIAS" for the source (i.e. this record did not exist in the db and so the user entered a 
		        new Alias and Alias Desc and Operator and Operator Desc. This entry did not exist at all)
		   --->
		   <cfif qOperatorAliasExistingID.ExistingID eq 0 AND qGetAliasExists.xref_ID eq "">
			
			<!--- Insert the new Source/Alias combination --->
			<cfquery name="qSaveOperatorAliasDetails" datasource="#application.datasource#">
				INSERT INTO BB_Claim_Operator_XREF(BB_Claim_Source_XREF_ID,
									Source_Code,
									External_Code,
									External_Description,
									Operator_Number,
									Created_By,
									BSA_Operator_ID
									<cfif IsDefined("arguments.aliasDef.Unknown")>
									,Ignore
									</cfif>
									)
				VALUES(<cfqueryparam value="#arguments.BBClaimSourceXREFID#" cfsqltype="CF_SQL_NUMERIC">,
					<cfqueryparam value="#arguments.aliasDef.sourceID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.aliasID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.aliasDesc#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfqueryparam value="#arguments.userID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfif arguments.aliasDef.bsaId NEQ ''>
						<cfqueryparam value="#arguments.aliasDef.bsaId#" cfsqltype="cf_sql_integer" >
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_integer" null="true">
					</cfif>
					<cfif IsDefined("arguments.aliasDef.Unknown")>
					,<cfqueryparam value="#arguments.aliasDef.Unknown#" cfsqltype="CF_SQL_BIT">
					</cfif>
					)
			</cfquery>

		    <cfelse>
		     
		     <!--- If this record already exists, then just update it. Do not update record, if the same alias already exists for some other record.	     
			   Note: we could change any part of the record: Alias/Alias Desc/Operator ID (legacy_ID)
			   -- qGetAliasExists.xref_ID EQ "" means no duplcate record found.
			   -- arguments.aliasDef.recordID eq qGetAliasExists.xref_ID means same record.
		     --->
		     <cfif qOperatorAliasExistingID.ExistingID eq 1 AND (qGetAliasExists.xref_ID EQ "" OR (arguments.aliasDef.recordID eq qGetAliasExists.xref_ID))>	
				<cfset UpdateOperatorAliasDetails(arguments.aliasDef)>
		     </cfif>

		    </cfif>

	   <!--- The only way this will return true is when it is a new record, i.e. a new Alias and Alias Desc and Operator ID and the same Alias already exists
		  for the vendor.
	   --->
	   <cfreturn bGetAliasExists>

	</cffunction>
	
	<!--- Check to see whether the "ALIAS" already exists for the "SOURCE". 
	The rule for a duplicate alias is the following:
	 - In the query, the check is for a duplicate "source code" (Payee ID OR Sysco EDI OR USFS EDI) and External Code (Alias).
	 - An alias record's description OR it's entity can be updated. An Alias ID can only be updated as long as there is no other entry 
	   with the same "Source Code" and  and External Code (Alias).
	--->
	<cffunction name="getAliasExists" access="public" returntype="query">
	  <cfargument name="aliasDef" required="true">
	  <cfargument name="entityType" required="true">

	  <cfset source_Type = arguments.aliasDef.sourceType>
	  <cfset source_ID = arguments.aliasDef.sourceID>
	  
		<!--- WR- 87415 (Start) - From flex Redistributor screen, "SourceType" which is passed is not the real "SourceType". It is actually "SourceCode".
		To avoid making changes in flex, we decided to make below change - Get "source type" from the "BB_Claim_Source_XREF" table
		based on source code and source code description and then use that in the below query.
		Sometimes (From flex Redistributor screen), the sourceTyoe coould be numeric but still not an actual sourceType but a sourceCode. We have to take 
		care of that scenario too.
		For the non-flex redistributor screen, below query is not needed.
		--->

		<cfset ValidSourceType = 1>

		<cfif IsNumeric(arguments.aliasDef.sourceType)>
		 <cfquery name="IsValidSourceType" datasource="#application.datasource#">
			SELECT Source_Type
			FROM BB_Claim_Source_XREF
			<!--- Do not use cfqueryparam. Some values may exceed integer limits --->
			WHERE Source_Type = #arguments.aliasDef.sourceType#
		  </cfquery>
			  <cfif  IsValidSourceType.recordcount eq 0>
				<cfset ValidSourceType = 0>
			  </cfif>
		 </cfif>

	  <cfif IsNumeric(arguments.aliasDef.sourceType) eq 0 OR ValidSourceType eq 0>
		<cfquery name="getSourceType" datasource="#application.datasource#">
			SELECT Source_Type
			FROM BB_Claim_Source_XREF
			WHERE Source_Code = <cfqueryparam value="#arguments.aliasDef.sourceType#" cfsqltype="CF_SQL_VARCHAR">
			AND Source_Type_Description = 'EDI-REDI'<!--- For REDI, the description is always "EDI-REDI" --->
			AND deleted = 0
			AND Active = 1
		</cfquery>
		<cfset source_Type = getSourceType.Source_Type>
		<!---  WR- 87415 (Start) - From flex Redistributor screen, arguments.aliasDef.sourceID ("SourceCode") is mistakingly sent as "SourceType". --->
		<cfset source_ID = arguments.aliasDef.sourceType>
	</cfif>
	<!--- WR- 87415 (End) --->

	    <!--- <cfset var bAliasExists = 0> --->
		
	    <!--- Entity Types: - 
		0 - Distributor
		1 - Item
		2 - Program	 
		3 - Operator
	    --->
	    <cfset qSettings = getSettings()>
		
	    <cfquery name="qgetAliasExists" datasource="#application.datasource#">
		SELECT xref.External_Code
		<cfif entityType eq 0>
		,xref.BB_Claim_DIST_XREF_ID 
		<cfelseif entityType eq 1>
		,xref.BB_Claim_Item_XREF_ID
		<cfelseif entityType eq 2>
		,xref.BB_Claim_Program_XREF_ID
		<cfelseif entityType eq 3>
		,xref.BB_Claim_Operator_XREF_ID		
		</cfif>

		As xref_ID

		FROM
		<!--- Distributor --->
		<cfif entityType eq 0>
		 BB_Claim_DIST_XREF xref
		 <!--- Item --->
		<cfelseif entityType eq 1>
		BB_Claim_Item_XREF xref
		<!--- Program --->
		<cfelseif entityType eq 2>
		BB_Claim_Program_XREF xref
		<!--- Operator --->
		<cfelseif entityType eq 3>
		BB_Claim_Operator_XREF xref	
		</cfif>
		INNER JOIN BB_Claim_Source_XREF sxref
		ON xref.BB_Claim_Source_XREF_ID = sxref.BB_Claim_Source_XREF_ID
		WHERE xref.Source_Code = <cfqueryparam value="#source_ID#" cfsqltype="CF_SQL_VARCHAR">
		AND xref.External_Code = <cfqueryparam value="#arguments.aliasDef.aliasID#" cfsqltype="CF_SQL_VARCHAR">
		AND sxref.Source_Type = <cfqueryparam value="#source_Type#" cfsqltype="CF_SQL_NUMERIC">

		<!--- If the same alias is allowed for multiple operators (qSettings.Allow_Multiple_Operator_Xref = 1) and the entity is operator, 
			  then do not return a record, i.e. since multiple aliases are allowed, it is not considered a duplicate alias.
		--->
		<cfif (isDefined("qSettings.Allow_Multiple_Operator_Xref") AND qSettings.Allow_Multiple_Operator_Xref EQ 1 AND entityType eq 3)>
		AND 1 = 0	
		</cfif>
			
		<!--- Distributor --->
		<cfif entityType eq 0>
		AND xref.BB_Claim_Dist_xref_id <> <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
		 <!--- Item --->
		<cfelseif entityType eq 1>
		AND xref.BB_Claim_Item_XREF_id <> <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
		<!--- Program --->
		<cfelseif entityType eq 2>
		AND xref.BB_Claim_Program_XREF_id <> <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
		<!--- Operator --->
		<cfelseif entityType eq 3>
		AND xref.BB_Claim_Operator_XREF_id <> <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>

		<!--- Distributor --->
		<cfif entityType eq 0>
		 AND xref.shipto IS NOT NULL
		 <!--- Item --->
		<cfelseif entityType eq 1>
		 AND xref.Item IS NOT NULL
		<!--- Program --->
		<cfelseif entityType eq 2>
		 AND xref.Contract_Number IS NOT NULL
		<!--- Operator --->
		<cfelseif entityType eq 3>
		 AND xref.Operator_Number IS NOT NULL	
		</cfif>
		AND xref.Deleted = 0
		AND sxref.deleted = 0
	    </cfquery>

	    <!---<cfset bAliasExists = qgetAliasExists.RecordCount>--->

	   <cfreturn qgetAliasExists>

	</cffunction>
	
	<!--- Update Alias/AliasDesc/Distributor ID/Distributor Desc for the selected record from the Flex Grid --->
	<cffunction name="UpdateDistributorAliasDetails" access="public" returntype="void"> 
	  <cfargument name="aliasDef" required="true">
	   <!--- Later add the updated record in the history table first and then update the record. --->

	   	<!--- Log existing record before update --->
		<cfset saveDistributorAliasDetailsLog(arguments.aliasDef.recordID,'U')>

		    <cfquery name="qUpdateDistributorAliasDetails" datasource="#application.datasource#">
			UPDATE BB_Claim_Dist_XREF
				SET External_Code = <cfqueryparam value="#trim(arguments.aliasDef.aliasID)#" cfsqltype="CF_SQL_VARCHAR">,
				    External_Description = <cfqueryparam value="#trim(arguments.aliasDef.aliasDesc)#" cfsqltype="CF_SQL_VARCHAR">,
				    Shipto = <cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">, 
				    Vendor_ID = <cfqueryparam value="#arguments.aliasDef.payeeID#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.payeeID)#">, 
					<cfif IsDefined("arguments.aliasDef.aliasUniproNum")>
				    Unipro_Num = <cfqueryparam value="#trim(arguments.aliasDef.aliasUniproNum)#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.aliasUniproNum)#">,
					</cfif>
					<cfif IsDefined("arguments.aliasDef.aliasLoc")>
				    Loc = <cfqueryparam value="#trim(arguments.aliasDef.aliasLoc)#" cfsqltype="CF_SQL_VARCHAR" NULL="#NOT len(arguments.aliasDef.aliasLoc)#">,
					</cfif>
				    Updated_Date = getdate(),
				    Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
					<cfif IsDefined("arguments.aliasDef.Unknown")>
					,Ignore = <cfqueryparam value="#arguments.aliasDef.Unknown#" cfsqltype="CF_SQL_BIT">	
					</cfif>
			WHERE BB_Claim_Dist_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
		    </cfquery>

	</cffunction>

	<!--- Update Alias/AliasDesc/Item ID/Item Desc for the selected record from the Flex Grid --->
	<cffunction name="UpdateItemAliasDetails" access="public" returntype="void"> 
	  <cfargument name="aliasDef" required="true">
	<!--- Later add the updated record in the history table first and then update the record. --->
		
		<!--- Log existing record before update --->
		<cfset saveItemAliasDetailsLog(arguments.aliasDef.recordID,'U')>

		    <cfquery name="qUpdateItemAliasDetails" datasource="#application.datasource#">
			UPDATE BB_Claim_Item_XREF
				SET External_Code = <cfqueryparam value="#arguments.aliasDef.aliasID#" cfsqltype="CF_SQL_VARCHAR">,
				    External_Description = <cfqueryparam value="#arguments.aliasDef.aliasDesc#" cfsqltype="CF_SQL_VARCHAR">,
				    Item = <cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">,	
				    Updated_Date = getdate(),
				    Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
				    	<!--- This is being used from the "alias upload fixer" and not the regular alias tool --->
					<cfif IsDefined("arguments.aliasDef.Unknown")>
					,Unknown = <cfqueryparam value="#arguments.aliasDef.Unknown#" cfsqltype="CF_SQL_BIT">	
					</cfif>
			WHERE BB_Claim_Item_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
		    </cfquery>

	</cffunction>

	<!--- Update Alias/AliasDesc/Program ID/Program Title for the selected record from the Flex Grid --->
	<cffunction name="UpdateProgramAliasDetails" access="public" returntype="void"> 
	  <cfargument name="aliasDef" required="true">
	<!--- Later add the updated record in the history table first and then update the record. --->
		
		<!--- Log existing record before update --->
		<cfset saveProgramAliasDetailsLog(arguments.aliasDef.recordID,'U')>

		    <cfquery name="qUpdateProgramAliasDetails" datasource="#application.datasource#">
			UPDATE BB_Claim_Program_XREF
				SET External_Code = <cfqueryparam value="#arguments.aliasDef.aliasID#" cfsqltype="CF_SQL_VARCHAR">,
				    External_Description = <cfqueryparam value="#arguments.aliasDef.aliasDesc#" cfsqltype="CF_SQL_VARCHAR">,
				    Contract_Number = <cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">, 
				    Updated_Date = getdate(),
				    Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
					<cfif IsDefined("arguments.aliasDef.Unknown")>
					,Ignore = <cfqueryparam value="#arguments.aliasDef.Unknown#" cfsqltype="CF_SQL_BIT">	
					</cfif>
			WHERE BB_Claim_Program_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
		    </cfquery>

	</cffunction>

	<!--- Update Alias/AliasDesc/Operator ID/Operator Desc for the selected record from the Flex Grid --->
	<cffunction name="UpdateOperatorAliasDetails" access="public" returntype="void"> 
	  <cfargument name="aliasDef" required="true">
	   <!--- Later add the updated record in the history table first and then update the record. --->
		<cfset var appSettings = application.appSettingsGet />	
	   <CFIF NOT IsDefined("arguments.aliasDef.bsaId")>
			 <cfset arguments.aliasDef.bsaId = '' />
	   </CFIF>
		<!--- If the below query does not return any results then the update statment will not do the update, but the user migth see "saved" message ---->
		<cfif arguments.aliasDef.bsaId EQ '' AND arguments.aliasDef.entityID NEQ ''>
			  <cfquery name="qgetBsaId" datasource="#application.datasource#">
					SELECT o.bsa_operator_Id 
					FROM bsa_operator o
					<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') eq '1'>
						INNER join operator_gpo gpo
						on        gpo.operator_gpo_ID = o.operator_gpo_ID
						and        gpo.deleted =0
						inner join BB_Claim_Operator_XREF oxf
						on        oxf.BB_Claim_Operator_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
						and        oxf.Source_Code = gpo.GPO_Key
					</cfif> 
					where legacy_Id =   <cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">
						and o.deleted = 0
		    </cfquery>
		    <cfset arguments.aliasDef.bsaId = qgetBsaId.bsa_operator_Id />
		</cfif>
		<!--- Log existing record before update --->
		  <cfif ((arguments.aliasDef.bsaId NEQ '' AND arguments.aliasDef.entityID NEQ '') OR (arguments.aliasDef.bsaId EQ '' AND arguments.aliasDef.entityID EQ ''))>  
		<cfset saveOperatorAliasDetailsLog(arguments.aliasDef.recordID,'U')>

		    <cfquery name="qUpdateOperatorAliasDetails" datasource="#application.datasource#">
			UPDATE BB_Claim_Operator_XREF
				SET External_Code = <cfqueryparam value="#arguments.aliasDef.aliasID#" cfsqltype="CF_SQL_VARCHAR">,
				    External_Description = <cfqueryparam value="#arguments.aliasDef.aliasDesc#" cfsqltype="CF_SQL_VARCHAR">,
				    <cfif arguments.aliasDef.entityID NEQ ''>
						Operator_Number = <cfqueryparam value="#arguments.aliasDef.entityID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfelse>
						Operator_Number = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" null="true">,
					</cfif>	
				    Updated_Date = getdate(),
				    Updated_By = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">,
					<cfif arguments.aliasDef.bsaId NEQ ''>
						BSA_Operator_ID = <cfqueryparam value="#arguments.aliasDef.bsaId#" cfsqltype="cf_sql_integer" >
					<cfelse>
						BSA_Operator_ID = <cfqueryparam cfsqltype="cf_sql_integer" null="true">
					</cfif>
					<cfif IsDefined("arguments.aliasDef.Unknown")>
					,Ignore = <cfqueryparam value="#arguments.aliasDef.Unknown#" cfsqltype="CF_SQL_BIT">	
					</cfif>
			WHERE BB_Claim_Operator_XREF_ID = <cfqueryparam value="#arguments.aliasDef.recordID#" cfsqltype="CF_SQL_VARCHAR">
		    </cfquery>
		 </cfif>  
	</cffunction>

	<!--- Add a log for any update or delete from the Alias Distributor Flex Grid --->
	<cffunction name="saveDistributorAliasDetailsLog" access="private" returntype="void"> 
	  <cfargument name="recordID" type="numeric" required="true">
	  <cfargument name="action" type="string" required="true">

		<cfquery name="qSaveDistributorAliasDetailsLog" datasource="#application.datasource#">
		INSERT INTO BB_Claim_Dist_XREF_History(BB_Claim_Source_XREF_ID,BB_Claim_Dist_XREF_ID,Source_Code,External_Code,External_Description,Shipto,
							Region,Address,City,State,ZIP,Unipro_Num,Loc,Action,Action_date,Action_By)

		SELECT BB_Claim_Source_XREF_ID,BB_Claim_Dist_XREF_ID,Source_Code,External_Code,External_Description,Shipto,
		Region,Address,City,State,ZIP,Unipro_Num,Loc,'#arguments.action#',getdate(),'#request.AccessStructure.User_ID#'
		FROM BB_Claim_Dist_XREF
		WHERE BB_Claim_Dist_XREF_ID = '#arguments.recordID#'
		</cfquery>

	</cffunction>

	<!--- Add a log for any update or delete from the Alias Item Flex Grid --->
	<cffunction name="saveItemAliasDetailsLog" access="private" returntype="void"> 
	  <cfargument name="recordID" type="numeric" required="true">
	  <cfargument name="action" type="string" required="true">

		<cfquery name="qSaveItemAliasDetailsLog" datasource="#application.datasource#">
		INSERT INTO BB_Claim_Item_XREF_History(BB_Claim_Source_XREF_ID,BB_Claim_Item_XREF_ID,Source_Code,External_Code,External_Description,Item,Action,Action_date,Action_By)

		SELECT BB_Claim_Source_XREF_ID,BB_Claim_Item_XREF_ID,Source_Code,External_Code,External_Description,Item,'#arguments.action#',getdate(),'#request.AccessStructure.User_ID#'
		FROM BB_Claim_Item_XREF
		WHERE BB_Claim_Item_XREF_ID = '#arguments.recordID#'
		</cfquery>

	</cffunction>

	<!--- Add a log for any update or delete from the Alias Program Flex Grid --->
	<cffunction name="saveProgramAliasDetailsLog" access="private" returntype="void"> 
	  <cfargument name="recordID" type="numeric" required="true">
	  <cfargument name="action" type="string" required="true">

		<cfquery name="qSaveProgramAliasDetailsLog" datasource="#application.datasource#">
		INSERT INTO BB_Claim_Program_XREF_History(BB_Claim_Source_XREF_ID,BB_Claim_Program_XREF_ID,Source_Code,External_Code,External_Description,Contract_Number,Action,Action_date,Action_By)

		SELECT BB_Claim_Source_XREF_ID,BB_Claim_Program_XREF_ID,Source_Code,External_Code,External_Description,Contract_Number,'#arguments.action#',getdate(),'#request.AccessStructure.User_ID#'
		FROM BB_Claim_Program_XREF
		WHERE BB_Claim_Program_XREF_ID = '#arguments.recordID#'
		</cfquery>

	</cffunction>

	<!--- Add a log for any update or delete from the Alias Operator Flex Grid --->
	<cffunction name="saveOperatorAliasDetailsLog" access="private" returntype="void"> 
	  <cfargument name="recordID" type="numeric" required="true">
	  <cfargument name="action" type="string" required="true">

		<cfquery name="qSaveOperatorAliasDetailsLog" datasource="#application.datasource#">
		INSERT INTO BB_Claim_Operator_XREF_History(BB_Claim_Source_XREF_ID,BB_Claim_Operator_XREF_ID,Source_Code,External_Code,External_Description,Operator_Number,Action,Action_date,Action_By)

		SELECT BB_Claim_Source_XREF_ID,BB_Claim_Operator_XREF_ID,Source_Code,External_Code,External_Description,Operator_Number,'#arguments.action#',getdate(),'#request.AccessStructure.User_ID#'
		FROM BB_Claim_Operator_XREF
		WHERE BB_Claim_Operator_XREF_ID = '#arguments.recordID#'
		</cfquery>

	</cffunction>

	<!--- Delete Alias record from the Flex Grid --->
	<cffunction name="deleteAliasRow" access="public" returntype="boolean"> 
	  <cfargument name="rowObjData" required="true">

	  <!--- Later add the deleted record in the history table first and then delete the record. --->
	    
		<cfset var bDeleteAlias = 0>
		 
		  <!--- distributor --->
		  <cfif rowObjData.EntityType eq 0>
		  
		    <!--- Log existing record before delete --->
		    <cfset saveDistributorAliasDetailsLog(arguments.rowObjData.recordID,'D')>

		    <cfquery name="qdeleteAliasRow" datasource="#application.datasource#">
			DELETE FROM BB_Claim_Dist_XREF		
			WHERE BB_Claim_Dist_XREF_ID = <cfqueryparam value="#arguments.rowObjData.recordID#" cfsqltype="CF_SQL_INTEGER">
		    </cfquery>

		  <!--- item --->
		  <cfelseif rowObjData.EntityType eq 1>

		    <!--- Log existing record before delete --->
		    <cfset saveItemAliasDetailsLog(arguments.rowObjData.recordID,'D')>

		    <cfquery name="qdeleteAliasRow" datasource="#application.datasource#">
			DELETE FROM BB_Claim_Item_XREF		
			WHERE BB_Claim_Item_XREF_ID = <cfqueryparam value="#arguments.rowObjData.recordID#" cfsqltype="CF_SQL_INTEGER">
		    </cfquery>
		  
		  <!--- program --->
		  <cfelseif  rowObjData.EntityType eq 2>

		    <!--- Log existing record before delete --->
		    <cfset saveProgramAliasDetailsLog(arguments.rowObjData.recordID,'D')>

		    <cfquery name="qdeleteAliasRow" datasource="#application.datasource#">
			DELETE FROM BB_Claim_Program_XREF		
			WHERE BB_Claim_Program_XREF_ID = <cfqueryparam value="#arguments.rowObjData.recordID#" cfsqltype="CF_SQL_INTEGER">
		    </cfquery>

		  <!--- operator --->
		  <cfelseif  rowObjData.EntityType eq 3>

		    <!--- Log existing record before delete --->
		    <cfset saveOperatorAliasDetailsLog(arguments.rowObjData.recordID,'D')>

		    <cfquery name="qdeleteAliasRow" datasource="#application.datasource#">
			DELETE FROM BB_Claim_Operator_XREF	
			WHERE BB_Claim_Operator_XREF_ID = <cfqueryparam value="#arguments.rowObjData.recordID#" cfsqltype="CF_SQL_INTEGER">
		    </cfquery>

		  </cfif>
		
		<!--- Successful deletion --->
		<cfset bDeleteAlias = 1>
	
	    <cfreturn bDeleteAlias>

	</cffunction>
			
	<!--- Validate if the operator selected have same GPO Kye as the Source --->
	<cffunction name="validateGPOKey" access="public" returntype="struct"> 
		<cfargument name="aliasDef" required="true">
		<cfargument name="BBClaimSourceXREFID" type="numeric" required="true">

		<cfset var returnStruct = StructNew()>
		<cfset returnStruct.valid = 1 />
		<cfset returnStruct.ErrorMessage = "" />
			
		<cfif isDefined("arguments.aliasDef.bsaId") AND arguments.aliasDef.bsaId NEQ ''>
						
			<!--- Get the GPO Key --->
			<cfquery name="qGetGPODetails" datasource="#application.datasource#">
				DECLARE @Source_Code varchar(20),
						@GPO_Key varchar(20)

				SELECT 	@Source_Code = Source_Code
				FROM 	BB_Claim_Source_XREF		
				WHERE 	BB_Claim_Source_XREF_ID = <cfqueryparam value="#arguments.BBClaimSourceXREFID#" cfsqltype="CF_SQL_INTEGER">

				SELECT	@GPO_Key = Operator_GPO.GPO_Key
				FROM	BSA_Operator
				INNER JOIN Operator_GPO ON Operator_GPO.Operator_GPO_ID = BSA_Operator.Operator_GPO_ID
				WHERE	BSA_Operator.BSA_Operator_ID = <cfqueryparam value="#arguments.aliasDef.bsaId#" cfsqltype="cf_sql_integer" >
				
				SELECT @Source_Code as Source_Code, @GPO_Key as GPO_Key
			</cfquery>
				
			<cfif qGetGPODetails.Source_Code NEQ qGetGPODetails.GPO_Key>
				<cfset returnStruct.valid = 0 />
				<cfset returnStruct.ErrorMessage = "Select a record with GPO Key #qGetGPODetails.Source_Code#" />
			</cfif>
			
		</cfif>
				
		<cfreturn returnStruct />

	</cffunction>
</cfcomponent>