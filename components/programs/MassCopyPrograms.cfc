<cfcomponent displayname="Mass Copy Programs">

	<cffunction access="public" name="saveMassCopyProgramData" output="false">
	
		<cfargument name="programId" 		required="yes">
		<cfargument name="programTitle"		required="yes">
		<cfargument name="createdBy"		required="yes">
		<cfargument name="distributorList"	required="yes">
		
		<cfset var indetity = "" />
		
		<cfquery name="qAddProgram" datasource="#application.datasource#">
		
			INSERT INTO	Mass_Program_Copy
				(Program_ID, Contract_Title, Created_By)
			VALUES
				(
					<cfqueryparam value="#arguments.programId#" cfsqltype="CF_SQL_INTEGER" />,
					<cfqueryparam value="#arguments.programTitle#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.createdBy#" cfsqltype="CF_SQL_VARCHAR" />
				)
				
			SELECT	@@IDENTITY AS ID
		</cfquery>
		
		<cfset indetity = qAddProgram.ID />
		
		
		<cfloop index="indx" list="#arguments.distributorList#">
		
			<cfquery name="qAddDistributors" datasource="#application.datasource#">
		
			INSERT INTO	Mass_Program_Copy_Distributor
				(Mass_Program_Copy_ID, BSA_Foodservice_Customers_ID)
			VALUES
				(
					<cfqueryparam value="#indetity#" cfsqltype="CF_SQL_INTEGER" />,
					<cfqueryparam value="#trim(indx)#" cfsqltype="CF_SQL_VARCHAR" />
				)
		</cfquery>
		
		</cfloop>
		
		<cfreturn indetity />
		
	</cffunction>
	
</cfcomponent>