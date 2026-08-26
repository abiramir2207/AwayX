<cfcomponent displayname="GroupCombinationManager" hint="Group Combination Manager" extends="components.Base">

	<cffunction name="init" returntype="components.products.group.GroupCombinationManager" output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getGroupCombinationDefinitionHeader" returntype="query" output="false">
		<cfargument name="groupCombinationDefinitionHeaderId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetGroupCombinationDefinitionHeader" datasource="#application.datasource#">
			SELECT	*
			FROM	Group_Combination_Definition_Header
			WHERE	Group_Combination_Definition_Header_ID = <cfqueryparam value="#arguments.groupCombinationDefinitionHeaderId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfreturn qGetGroupCombinationDefinitionHeader />
		
	</cffunction>
	
	<cffunction name="getGroupCombinationDefinitionDetail" returntype="query" output="false">
		<cfargument name="groupCombinationDefinitionHeaderId" type="numeric" required="false" default="0" />
		
		<cfquery name="qGetGroupCombinationDefinitionDetail" datasource="#application.datasource#">
			SELECT	Group_Combination_Definition_Detail.Member_Group_Level_ID, Product_Group_Level.Product_Group_Level_Type
			FROM	Group_Combination_Definition_Detail
			
			INNER JOIN Product_Group_Level
			ON	Product_Group_Level.Product_Group_Level_ID = Group_Combination_Definition_Detail.Member_Group_Level_ID
			
			WHERE	Group_Combination_Definition_Header_ID = <cfqueryparam value="#arguments.groupCombinationDefinitionHeaderId#" cfsqltype="CF_SQL_INTEGER">
		</cfquery>
		
		<cfreturn qGetGroupCombinationDefinitionDetail />
		
	</cffunction>
	
</cfcomponent>