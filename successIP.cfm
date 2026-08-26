<cfset UsersIP = CGI.Remote_Addr>

	<cfquery name="AddIP" datasource="#application.datasource#">
	INSERT INTO LoginIP (IP_Address, User_Code, Status)
	VALUES (<cfqueryparam value="#UsersIP#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="#User_Code#" cfsqltype="CF_SQL_VARCHAR">,
			<cfqueryparam value="1" cfsqltype="CF_SQL_INTEGER">)
	</cfquery>