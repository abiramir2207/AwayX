<!------ customerManager.cfc ----->
<cfcomponent hint="Manages Customer" extends="cm.com.Base">


	<cffunction name="init" output="false">
	
		<cfreturn this />
		
	</cffunction>
	
	<cffunction name="getFamilys" output="true">
		
		
		<CFQUERY NAME="getFamilys" DATASOURCE="#application.datasource#">
			SELECT	Family_ID, Family_Name
			FROM	Distributor_Family
			WHERE
					Deleted = 0
			ORDER BY Family_Name
		</CFQUERY>
		
		<cfreturn getFamilys>
		
	</cffunction>
	
	<cffunction name="getBuyingGroups" output="true">
		
		
		<CFQUERY NAME="getBuyingGroups" DATASOURCE="#application.datasource#">
			SELECT	Buying_Group_ID, Buying_Group_Name
			FROM	Distributor_Buying_Groups
			WHERE
					Deleted = 0
			ORDER BY Buying_Group_Name
		</CFQUERY>
		
		<cfreturn getBuyingGroups>
		
	</cffunction>
	
	<cffunction name="getOperatorTypes" output="true">
		
		
		<CFQUERY NAME="getOperatorTypes" DATASOURCE="#application.datasource#">
			SELECT	DISTINCT Operator_Type
			FROM	BSA_Operator
			WHERE
				Deleted = 0
			ORDER BY Operator_Type
		</CFQUERY>
		
		<cfreturn getOperatorTypes>
		
	</cffunction>
	
	<cffunction name="getAllDistributors" output="false">
		<cfargument name="userId" type="string" required="true" />
		
		<CFQUERY NAME="getAllDistributors" DATASOURCE="#application.datasource#">
			SELECT 	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
			FROM	BSA_Foodservice_Customers
				INNER JOIN BSA_Foodservice_Brokers
				ON
				BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
				AND
				BSA_Foodservice_Brokers.Deleted = 0	
				INNER JOIN Service_Markets
				ON
				Service_Markets.Deleted = 0
				AND
				Service_Markets.Service_Market_ID = BSA_Foodservice_Brokers.Service_Market_ID							
				INNER JOIN User_Positions
				ON
				User_Positions.Deleted = 0
				AND
				User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID	
			WHERE 	BSA_Foodservice_Customers.Deleted = 0

		</CFQUERY>
		
		<cfreturn ValueList(getAllDistributors.BSA_Foodservice_Customers_ID)>
	</cffunction>
	
	<cffunction name="getAllOperators" output="false">
		<cfargument name="userId" type="string" required="true" />
		
		<CFQUERY NAME="getAllOperators" DATASOURCE="#application.datasource#">
			SELECT 	DISTINCT
				BSA_Operator.BSA_Operator_ID
			FROM	
				BSA_Operator
				INNER JOIN Market_ZipCode
				ON
				Market_ZipCode.ZipCode = Left(BSA_Operator.Operator_Zip, 5)
				AND
				Market_ZipCode.Deleted = 0	
				INNER JOIN Service_Markets
				ON
				Service_Markets.Deleted = 0
				AND
				Service_Markets.Service_Market_ID = Market_ZipCode.Service_Market_ID
				INNER JOIN User_Positions
				ON
				User_Positions.Deleted = 0
				AND
				(
					(
						User_Positions.Service_Market_ID = Service_Markets.Service_Market_ID
					)
					OR
					(
						BSA_Operator.User_Positions_ID IS NOT NULL
						AND
						User_Positions.User_Positions_ID = BSA_Operator.User_Positions_ID
					)
				)				
			WHERE 	BSA_Operator.Deleted = 0				
		</CFQUERY>
		
		<cfreturn ValueList(getAllOperators.BSA_Operator_ID)>
	</cffunction>
	
	<cffunction name="save" output="true">
	
		<cfargument name="groupType" required="true" type="numeric" />
		<cfargument name="id" required="true" type="any" />
		<cfset returnValue = 0>
		
		<cfset fieldName = "">
		<cfset fieldType = "">
		<cfswitch expression="#arguments.groupType#">
			<cfcase value="1"><!------ Distributor ----->
				<cfset fieldName = "Distributor_ID">
				<cfset fieldType = "2">
			</cfcase>
			<cfcase value="2"><!------ Operator ----->
				<cfset fieldName = "Operator_ID">
				<cfset fieldType = "1">
			</cfcase>
			<cfcase value="3"><!------ Family ----->
				<cfset fieldName = "Family_ID">
				<cfset fieldType = "2">
			</cfcase>
			<cfcase value="4"><!------ Buying Group ----->
				<cfset fieldName = "Buying_Group_ID">
				<cfset fieldType = "2">
			</cfcase>
			<cfcase value="5"><!------ Operator Type ----->
				<cfset fieldName = "Operator_Type">
				<cfset fieldType = "2">
			</cfcase>
		</cfswitch>
		
		<cfif fieldName NEQ "" AND fieldType NEQ "">
			<cfquery name="insertCuctomer" datasource="#application.datasource#">
						
				SET NOCOUNT ON
				
				INSERT INTO CM_Customer
					(CM_Customer_Group_ID, #fieldName#)
				VALUES
					(#arguments.groupType#
					, <cfif fieldType EQ 2>'</cfif>#arguments.id#<cfif fieldType EQ 2>'</cfif>)
				
				SELECT CM_Customer_ID = @@IDENTITY
				
				SET NOCOUNT OFF
				
			</cfquery>
			<cfset returnValue = insertCuctomer.CM_Customer_ID>
		</cfif>
		
		<cfreturn returnValue>
	</cffunction>
	
</cfcomponent>