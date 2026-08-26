<cfcomponent displayname="DistributorList">
	<!--- get lists of  saved items.  returns an array of objects o.  one of the objects o.data is an array of items --->
	<cffunction name="getUserDistributorList" output="false" access="remote" returntype="Array">
		<cfargument name="ID" required="false">
		<cfset var qRead = "">
		<cfset var qGetData = "">
		<cfset var acData = ArrayNew(1)/>
		<cfset var tmpData = ArrayNew(1)/>
		<cfset var t = "" />
		<cfquery name="qRead" datasource="#application.datasource#">
			SELECT    	User_Distributor_List_id, 
						User_Id,
						List_Name
			FROM      dbo.User_Distributor_List
			WHERE User_Id = '#arguments.ID#'
			ORDER BY List_Name
		</cfquery>
		 <cflog text="query ran: #qRead.recordcount# :: #arguments.ID#"> 
		<cfloop query="qRead">
				<!---create a temporary structure to hold this company's information--->
            <cfset t = structnew()>
			<cfset t.User_Distributor_List_id = qRead.User_Distributor_List_id>
            <cfset t.User_Id = qRead.User_Id>
            <cfset t.List_Name = qRead.List_Name>
			<cfset t.Data = ArrayNew(1) />
			<cfquery name="qGetData" datasource="#application.datasource#">
				SELECT    Ship_to
				FROM      dbo.User_Distributor_List_Data
				WHERE User_Distributor_List_id = '#User_Distributor_List_id#'
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
	<cffunction name="saveUserDistributorList" output="false" access="remote" returntype="void">
		<cfargument name="UserId" required="true" type="String">
		<cfargument name="lName" required="true" type="String">
		<cfargument type="Array" required="true" name="UserDistributorList">
		
		<cfset var qCreate = "">
		<cfset var qGetId = "">
		<cfset var listId = "">
		<cfset var i = "">
		
		<cftransaction isolation="read_committed">
			<cfquery name="qCreate" datasource="#application.datasource#">
				 SET NOCOUNT ON
				insert into dbo.User_Distributor_list(
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

			<cfloop array="#UserDistributorList#" index="i">
				<cfquery name="qGetID" datasource="#application.datasource#">
					insert into dbo.User_Distributor_list_Data(
								User_Distributor_List_Id, 
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

	<cffunction name="deleteUserDistributorList" output="false" access="remote" returntype="void">
		<cfargument required="true" name="ID" type="Numeric">
		<cfset var qDeleteUser_Distributor_list_Data = "">
		<cfquery name="qDeleteUser_Distributor_list" datasource="#application.datasource#">
					DELETE FROM dbo.User_Distributor_list
					WHERE User_Distributor_list_Id = #ID# <!--- <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer"> --->
		</cfquery>
		<cfquery name="qDeleteUser_Distributor_list_Data" datasource="#application.datasource#">
					DELETE FROM dbo.User_Distributor_list_Data
					WHERE User_Distributor_list_Id = #ID# <!--- <cfqueryparam value="#ID#" cfsqltype="cf_sql_integer"> --->
		</cfquery>
	</cffunction>
	
</cfcomponent>
