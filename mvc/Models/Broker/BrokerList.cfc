<cfcomponent displayname="BrokerList">
	<!--- get lists of  saved items.  returns an array of objects o.  one of the objects o.data is an array of items --->
	<cffunction name="getUserBrokerList" output="false" access="remote" returntype="Array">
		<cfargument name="ID" required="false">
		<cfset var qRead = "">
		<cfset var qGetData = "">
		<cfset var acData = ArrayNew(1)/>
		<cfset var tmpData = ArrayNew(1)/>
		<cfset var t = "" />
		<cfquery name="qRead" datasource="#application.datasource#">
			SELECT    	User_Broker_List_id, 
						User_Id,
						List_Name
			FROM      dbo.User_Broker_List
			WHERE User_Id = '#arguments.ID#'
			ORDER BY List_Name
		</cfquery>
		 <cflog text="query ran: #qRead.recordcount# :: #arguments.ID#"> 
		<cfloop query="qRead">
				<!---create a temporary structure to hold this company's information--->
            <cfset t = structnew()>
			<cfset t.User_Broker_List_id = User_Broker_List_id>
            <cfset t.User_Id = User_Id>
            <cfset t.List_Name = List_Name>
			<cfset t.Data = ArrayNew(1) />
			<cfquery name="qGetData" datasource="#application.datasource#">
				SELECT    Ship_to
				FROM      dbo.User_Broker_List_Data
				WHERE User_Broker_List_id = '#User_Broker_List_id#'
			</cfquery>
			<cfset tmpData = ArrayNew(1)/>
            <cfloop query="qGetData">
				<cfset ArrayAppend(tmpData,qGetData.ship_to) />
			</cfloop>
			<cfset t.Data = tmpData	/>
	            <!---append this structure to the array--->
	         <cfset arrayappend(acData, t)>
		</cfloop>
		<cfreturn acData>
	</cffunction>
	<!--- save a list of items for future use. --->
	<cffunction name="saveUserBrokerList" output="false" access="remote" returntype="void">
		<cfargument name="UserId" required="true" type="String">
		<cfargument name="lName" required="true" type="String">
		<cfargument type="Array" required="true" name="UserBrokerList">
		
		<cfset var qCreate = "">
		<cfset var qGetId = "">
		<cfset var listId = "">
		<cfset var i = "">
		
		<cftransaction isolation="read_committed">
			<cfquery name="qCreate" datasource="#application.datasource#">
				 SET NOCOUNT ON
				insert into dbo.User_Broker_list(
							User_Id, 
							List_Name)
				values (
					<cfqueryparam value="#arguments.UserId#" cfsqltype="CF_SQL_VARCHAR" />,
					<cfqueryparam value="#arguments.lName#" cfsqltype="CF_SQL_VARCHAR" />
					)
				
			      SELECT @@Identity AS newId      
			      SET NOCOUNT OFF 
			</cfquery>
			<cfset listId = qCreate.newId />

			<cfloop array="#UserBrokerList#" index="i">
				<cfquery name="qGetID" datasource="#application.datasource#">
					insert into dbo.User_Broker_list_Data(
								User_Broker_List_Id, 
								Ship_To)
					values (
						<cfqueryparam value="#listId#" cfsqltype="CF_SQL_VARCHAR" />,
						<cfqueryparam value="#i#" cfsqltype="CF_SQL_VARCHAR" />
					)
				</cfquery>
			</cfloop>
		</cftransaction>

		<!--- <cfscript>
			arguments.bean.setUser_Item_List_Id(qGetID.User_Item_List_Id);
		</cfscript>
		<cfreturn arguments.bean /> --->
	</cffunction>

	<cffunction name="deleteUserBrokerList" output="false" access="remote" returntype="void">
		<cfargument required="true" name="ID" type="Numeric">
		<cfset var qDeleteUser_Broker_list_Data = "">
		<cfquery name="qDeleteUser_Broker_list_Data" datasource="#application.datasource#">
					DELETE FROM dbo.User_Broker_list
					WHERE User_Broker_list_Id = <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer">
		</cfquery>
	</cffunction>
	
</cfcomponent>
