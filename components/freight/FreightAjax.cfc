<!---  
       Name:          FreightAjax.cfc    
       Copyright:     Copyright (c) 2007 Blacksmith Applications, Inc.       
       Created Date:  10/23/2007
       Created By:    dkunnath
       Description:   
--->
 <cfcomponent extends="components.ajaxCFC.ajax">

	<cffunction name="callpopulateprogramdistributorfreight" output="no" returntype="numeric">
		<cfargument	name="programID" type="string" required="true" >
		<cfargument	name="ReCalculateAll" type="boolean" required="false" default="0">

		<cfset ProgramFreight = createObject("component","components.freight.ProgramFreight")>

		  <!--- Log an entry for the freight AJAX call made --->
		  <cfset logFreightCall('#arguments.programID#')>

		  <cfset ProgramFreight.PopulateProgramDistributorFreight(arguments.programID,arguments.ReCalculateAll)>
			
			<cfreturn 1>
	</cffunction>
	
	<!--- Log any AJAX Call for freight --->
	<cffunction name="logFreightCall" output="no" returntype="void">
		<cfargument name="ProgramID" required="true" type="string">
		
			<cfquery name="InsertLogFreightAJAX" datasource="#application.datasource#">
				INSERT INTO Log_Freight_AJAX(Program_ID)
				VALUES('#arguments.ProgramID#')
			</cfquery>	
	</cffunction>
	
	<cffunction name="warehouseChanged" output="no" returntype="array">
		<cfargument	name="freightComponentType" type="string" required="true" >
		<cfargument	name="freightDate" type="string" required="true" >
		<cfargument	name="distributorID" type="string" required="true" >
		<cfargument	name="warehouseID" type="string" required="true" >
		<cfargument	name="zipCode" type="string" required="true" >
		<cfargument	name="defaultBracketId" type="string" required="true" >
		
		<cfset var dataArray = ArrayNew(1)>
		<cfset dataArray[1] = arguments.freightComponentType />
		<cfset dataArray[2] = arguments.freightDate />
		<cfset dataArray[3] = Replace(arguments.distributorID, "-", "_", "all") >
		<cfset dataArray[4] = arguments.warehouseID />
		<cfset dataArray[5] = 0 /> <!--- ibf ---->
		<cfset dataArray[6] = 0 /> <!--- bracket ---->
		<cfset dataArray[7] = 0 /> <!--- obf ---->
		
		<cfset dataArray[5] = getIBFRate(warehouseID = arguments.warehouseID, dDate = arguments.freightDate) />
		
		<cfset validZipCode = arguments.zipCode />
		<cfif Val(validZipCode) eq 0>
			<cfset validZipCode = "000">
		</cfif>

		<cfif arguments.freightComponentType eq 1><!--- get del info --->
			<cfset newBracketId = getDefaultBracket(distributorID = arguments.distributorID, warehouseID = arguments.warehouseID) />
			<cfif newBracketId eq 0>
				<cfset newBracketId = arguments.defaultBracketId />
			</cfif>
			<cfset dataArray[6] = newBracketId />
			<cfset dataArray[7] = getOBFRate(
									warehouseID = arguments.warehouseID,
									bracketID = newBracketId,
									zipCode =  validZipCode,
									dDate = arguments.freightDate)
									 />
		</cfif>
		
		<cfreturn dataArray />
		
	</cffunction>
	
	<cffunction name="bracketChanged" output="no" returntype="array">
		<cfargument	name="freightComponentType" type="string" required="true" >
		<cfargument	name="freightDate" type="string" required="true" >
		<cfargument	name="distributorID" type="string" required="true" >
		<cfargument	name="warehouseID" type="string" required="true" >
		<cfargument	name="zipCode" type="string" required="true" >
		<cfargument	name="bracketId" type="string" required="true" >
		
		<cfset var dataArray = ArrayNew(1)>
		<cfset dataArray[1] = arguments.freightComponentType />
		<cfset dataArray[2] = arguments.freightDate />
		<cfset dataArray[3] = Replace(arguments.distributorID, "-", "_", "all") >
		<cfset dataArray[4] = arguments.warehouseID />
		<cfset dataArray[5] = 0 /> <!--- ibf ---->
		<cfset dataArray[6] = arguments.bracketId /> <!--- bracket ---->
		<cfset dataArray[7] = 0 /> <!--- obf ---->
		
		<cfset validZipCode = arguments.zipCode />
		<cfif Val(validZipCode) eq 0>
			<cfset validZipCode = "000">
		</cfif>
		
		<cfif arguments.freightComponentType eq 1><!--- get del info --->
			<cfset dataArray[7] = getOBFRate(
									warehouseID = arguments.warehouseID,
									bracketID = arguments.bracketId,
									zipCode =  validZipCode,
									dDate = arguments.freightDate)
									 />
		</cfif>

		<cfreturn dataArray />
		
	</cffunction>	
	
	<cffunction name="getDefaultBracket" output="no" returntype="numeric">
		<cfargument	name="distributorID" type="string" required="true" >
		<cfargument	name="warehouseID" type="string" required="true" >
		<cfset var bracketId =  0 />
		
		<cfquery name="qGetDistributorWarehouseBracket" datasource="#application.datasource#">
			SELECT	Freight_Bracket_Setting_ID
			FROM	Customer_Warehouse_Bracket
			WHERE	Customer_Warehouse_Bracket.Deleted = 0
			AND		Customer_Warehouse_Bracket.Distributor_ID = <cfqueryparam value="#arguments.distributorID#" cfsqltype="cf_sql_varchar">
			AND		Customer_Warehouse_Bracket.Warehouse_Master_ID = <cfqueryparam value="#arguments.warehouseID#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		<cfif qGetDistributorWarehouseBracket.recordCount>
			<cfset bracketId = qGetDistributorWarehouseBracket.Freight_Bracket_Setting_ID />
		</cfif>

		<cfreturn bracketId / >
	</cffunction>

	<cffunction name="getIBFRate" output="no" returntype="numeric">
		<cfargument	name="warehouseID" type="string" required="true" >
		<cfargument	name="dDate" type="string" required="true" >
		
		<cfset var ibfRate =  0 />
		
		<cfquery name="qGetWarehouseIBFRate" datasource="#application.datasource#">
			SELECT	CONVERT(Decimal(9,2),ISNULL(Inbound_Freight_Rate.IBF_Rate, 0)) as IBF_Rate
			FROM	Inbound_Freight_Rate
			WHERE	Inbound_Freight_Rate.Deleted = 0
			AND		Inbound_Freight_Rate.Warehouse_Master_ID = <cfqueryparam value="#arguments.warehouseID#" cfsqltype="CF_SQL_INTEGER">
			AND		#createodbcdate(arguments.dDate)# between Inbound_Freight_Rate.Start_Date AND Inbound_Freight_Rate.End_Date
		</cfquery>
		<cfif qGetWarehouseIBFRate.recordCount>
			<cfset ibfRate = qGetWarehouseIBFRate.IBF_Rate />
		</cfif>

		<cfreturn ibfRate / >
	</cffunction>
	
	<cffunction name="getOBFRate" output="no" returntype="numeric">
		<cfargument	name="warehouseID" type="string" required="true" >
		<cfargument	name="bracketID" type="string" required="true" >
		<cfargument	name="zipCode" type="string" required="true" >
		<cfargument	name="dDate" type="string" required="true" >
		
		<cfset var obfRate =  0 />
		
		<cfquery name="qGetWarehouseBracketOBFRate" datasource="#application.datasource#">
			SELECT	CONVERT(Decimal(9,2),ISNULL(Outbound_Freight_Rate.OBF_Rate, 0)) as OBF_Rate
			FROM	Outbound_Freight_Rate
			WHERE	Outbound_Freight_Rate.Deleted = 0
			AND		Outbound_Freight_Rate.Warehouse_Master_ID = <cfqueryparam value="#arguments.warehouseID#" cfsqltype="CF_SQL_INTEGER">
			AND		Outbound_Freight_Rate.Freight_Bracket_Setting_ID = <cfqueryparam value="#arguments.bracketID#" cfsqltype="CF_SQL_INTEGER">
			AND		cast('#left(trim(arguments.ZipCode), 3)#' as int) between cast(Outbound_Freight_Rate.Zip_Start as int) AND cast(Outbound_Freight_Rate.Zip_End as int)
			AND		#createodbcdate(arguments.dDate)# between Outbound_Freight_Rate.Start_Date AND Outbound_Freight_Rate.End_Date
		</cfquery>
		<cfif qGetWarehouseBracketOBFRate.recordCount>
			<cfset obfRate = qGetWarehouseBracketOBFRate.OBF_Rate />
		</cfif>

		<cfreturn obfRate / >
	</cffunction>	
	
</cfcomponent>