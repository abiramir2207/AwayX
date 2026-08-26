<cfcomponent hint="positionTree">

	<cffunction name="init" output="false" returntype="components.geography.positionTreeManager">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getLevelExpansion" output="false" returntype="boolean">
		
		<cfargument name="expandLevel" type="numeric" required="true" />
		<cfargument name="currentLevel" type="numeric" required="true" />
		<cfargument name="defaultLevel" type="numeric" required="true" />
		<cfargument name="currLevelID" type="string" required="true" />
		<cfargument name="expandLevelID" type="string" required="true" />
		
		<cfset expandThisSection = 0>
		<cfif arguments.expandLevel GT arguments.currentLevel>
			<cfif arguments.currLevelID EQ arguments.expandLevelID OR arguments.currentLevel LT arguments.defaultLevel>
				<cfset expandThisSection = 1>
			</cfif>
		</cfif>
		
		<cfreturn expandThisSection>
		
	</cffunction>
	
	<cffunction name="getDistributorSection" output="false">
		
		<cfargument name="qDistributor" type="query" required="true" />
		<cfargument name="oXMLDoc" type="any" required="true" />
		<cfargument name="oXML" type="any" required="true" />
		<cfargument name="startIndex" type="numeric" required="false" default="0" />
		
		<CFLOOP query="arguments.qDistributor">
								
			<cfset distIndx = arguments.startIndex + CurrentRow />
			
			<cfset thisPositionDistributorID = BSA_Foodservice_Customers_ID>			
			<CFSET for_Distributor_Name = trim(Name)>
	
			<cfset ArrayAppend(arguments.oXML.XmlChildren, XmlElemNew(arguments.oXMLDoc,"menuItem"))>
			<cfset StructInsert(arguments.oXML.menuItem[distIndx].XmlAttributes, "level", "D") />
			<cfset StructInsert(arguments.oXML.menuItem[distIndx].XmlAttributes, "icon", "level_distributor.gif") />
			<cfset StructInsert(arguments.oXML.menuItem[distIndx].XmlAttributes, "caption", "#reReplace(for_Distributor_Name, "[^\x20-\x7E]", "", "ALL")#") />
			<cfset StructInsert(arguments.oXML.menuItem[distIndx].XmlAttributes, "parensdata", "#trim(Ship_To)# / #Shr_Ship_To#") />
			
		</CFLOOP>
		
	</cffunction>
	
	<cffunction name="getDistributors" output="false" returntype="query">
		
		<cfargument name="marketId" type="numeric" required="true" />
		<cfargument name="brokerId" type="string" required="true" />
		<cfargument name="allowDistributorMultiPosition" type="numeric" required="true" />
		<cfargument name="returnCount" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetDistributors" datasource="#application.datasource#">
			SELECT	<cfif arguments.returnCount NEQ 0> TOP #arguments.returnCount#</cfif>
					BSA_Foodservice_Customers.Name, 
					BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID, 
					BSA_Foodservice_Customers.Ship_To,
					BSA_Foodservice_Customers.Shr_Ship_To
			FROM 	BSA_Foodservice_Customers
					<cfif arguments.allowDistributorMultiPosition>
					INNER JOIN Market_Distributor
					ON Market_Distributor.Deleted = 0
					AND Market_Distributor.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
					AND Market_Distributor.Service_Market_ID = #arguments.marketId#
					</cfif>
			WHERE 	BSA_Foodservice_Customers.Active_Code = 'A'
			AND		BSA_Foodservice_Customers.DELETED = 0
			<cfif NOT arguments.allowDistributorMultiPosition>
			AND		BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID = '#arguments.brokerId#'
			</cfif>
			ORDER BY Name
		</cfquery>
		
		<cfreturn qGetDistributors>
		
	</cffunction>

</cfcomponent>