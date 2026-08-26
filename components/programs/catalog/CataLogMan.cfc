<cfcomponent displayname="CatalogMan" hint="this is the class for the catalog programs">
	<!--- declare properties --->
	<cfset variables.contractMainID = "" />
	<cfset variables.usersByCreator = "" />
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="CatalogMan" output="false">
		<cfargument name="contractMainID" type="string" required="true" />
		<cfargument name="qUsers" type="query" required="true" />
		<cfset setContractMainID(arguments.contractMainID) />
		<cfset loadUsers(arguments.qUsers) />
		<cfreturn this />
	</cffunction>
	<!--- getter --->
	<cffunction name="getContractMainID" returntype="string" access="public" output="false">
		<cfreturn  variables.contractMainID/>
	</cffunction>
	<cffunction name="getUsersByCreator" returntype="query" access="public" output="false">
		<cfreturn  variables.usersByCreator/>
	</cffunction>
	<!--- setter --->
	<cffunction name="setContractMainID" returntype="void" access="package" output="false">
		<cfargument name="contractMainID" type="string" required="true" />
		<cfset variables.contractMainID = arguments.contractMainID />
	</cffunction>
	<cffunction name="setUsersByCreator" returntype="void" access="package" output="false">
		<cfargument name="qUsers" type="query" required="true" />
		<cfset variables.usersByCreator = arguments.qUsers />
	</cffunction>
	<!--- methods --->
	<cffunction name="loadUsers" access="public" returntype="void" output="false">
		<cfargument name="qUsers" type="query" required="true" />
		<cfquery name="getUserIDByProgram" datasource="#application.datasource#">
			select creator_id
			from contract_main
			where contract_main.contract_main_id like '%#trim(this.getContractMainID())#%' 
			and deleted = 0
		</cfquery>
		<cfquery name="qUsersByCreator" dbtype="query">
			SELECT *
			FROM arguments.qUsers
			where USER_ID in ('#valueList(getUserIDByProgram.creator_id)#')
		</cfquery>
		<cfset setUsersByCreator(qUsersByCreator) />
	</cffunction>
</cfcomponent>