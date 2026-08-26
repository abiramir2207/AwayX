<cfcomponent displayname="OperatorList">
	
	<!--- get lists of  saved items.  returns an array of objects o.  one of the objects o.data is an array of items --->
	<cffunction name="getUserOperatorList" output="false" access="remote" returntype="Array">
		<cfargument name="User_ID" required="false">
		<cfset var qRead = "">
		<cfset var qGetData = "">
		<cfset var acData = ArrayNew(1)/>
		<cfset var tmpData = ArrayNew(1)/>
		<cfset var t = "" />
		
		<cfquery name="qRead" datasource="#application.datasource#">
			SELECT    	User_Operator_List_ID, User_ID, List_Name
			FROM		dbo.User_Operator_List
			WHERE	User_ID = <cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar" />
			ORDER BY List_Name
		</cfquery>
		
		<cflog text="query ran: #qRead.recordcount# :: #arguments.User_ID#"> 
		<cfloop query="qRead">
			<!---create a temporary structure to hold this company's information--->
			<cfset t = structnew()>
			<cfset t.User_Operator_List_ID = User_Operator_List_ID>
			<cfset t.User_ID = User_ID>
			<cfset t.List_Name = List_Name>
			<cfset t.Data = ArrayNew(1) />
			<cfquery name="qGetData" datasource="#application.datasource#">
				SELECT	BSA_Operator_ID
				FROM		dbo.User_Operator_List_Data
				WHERE 	User_Operator_List_ID = <cfqueryparam value="#User_Operator_List_ID#" cfsqltype="cf_sql_integer" />
			</cfquery>
			<cfset tmpData = ArrayNew(1)/>

			<cfloop query="qGetData">
				<cfset ArrayAppend(tmpData,qGetData.BSA_Operator_ID) />
			</cfloop>
			<cfset t.Data = tmpData	/>

			<!---append this structure to the array--->
			 <cfset arrayappend(acData, t)>
		</cfloop>
		<cfreturn acData>
	</cffunction>
	
	<!--- save a list of items for future use. --->
	<cffunction name="saveUserOperatorList" output="false" access="remote" returntype="void">
		<cfargument name="User_ID" required="true" type="String">
		<cfargument name="List_Name" required="true" type="String">
		<cfargument name="UserOperatorList" required="true" type="Array" >
		
		<cfset var qCreate = "">
		<cfset var qGetId = "">
		<cfset var listId = "">
		<cfset var i = "">
		
		<cftransaction isolation="read_committed">
			<cfquery name="qCreate" datasource="#application.datasource#">
				 SET NOCOUNT ON
				insert into dbo.User_Operator_list(User_ID, List_Name)
				values (
						<cfqueryparam value="#arguments.User_ID#" cfsqltype="cf_sql_varchar" />,
						<cfqueryparam value="#arguments.List_Name#" cfsqltype="cf_sql_varchar" />
					 )
			      SELECT @@Identity AS newID      
			      SET NOCOUNT OFF 
			</cfquery>
			<cfset listID = qCreate.newID />

			<cfloop array="#UserOperatorList#" index="i">
				<cfquery name="qGetID" datasource="#application.datasource#">
					insert into dbo.User_Operator_list_Data(User_Operator_List_ID, BSA_Operator_ID, Legacy_ID)
					values (
							<cfqueryparam value="#listID#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#i#" cfsqltype="cf_sql_varchar" />,
							<cfqueryparam value="#i#" cfsqltype="cf_sql_varchar" />
						)
				</cfquery>
			</cfloop>
		</cftransaction>

		<!--- <cfscript>
			arguments.bean.setUser_Item_List_ID(qGetID.User_Item_List_ID);
		</cfscript>
		<cfreturn arguments.bean /> --->
	</cffunction>

	<cffunction name="deleteUserOperatorList" output="false" access="remote" returntype="void">
		<cfargument name="ListID" required="true" type="Numeric">
		<cfset var qDeleteUser_Operator_list_Data = "">
		<cfquery name="qDeleteUser_Operator_list_Data" datasource="#application.datasource#">
					DELETE FROM dbo.User_Operator_list
					WHERE User_Operator_list_ID = <cfqueryparam value="#arguments.ListID#" cfsqltype="cf_sql_integer">
					DELETE FROM dbo.User_Operator_List_Data
					WHERE User_Operator_list_ID = <cfqueryparam value="#arguments.ListID#" cfsqltype="cf_sql_integer">
		</cfquery>
	</cffunction>
	
</cfcomponent>