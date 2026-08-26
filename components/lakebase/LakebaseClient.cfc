<!---
FILE:      Databricks Lakebase Data API client
FILENAME:  LakebaseClient.cfc
CREATED:   2026-08-03
APP:       AwayX

FUNCTIONALITY:
- Reusable REST client for the Databricks Lakebase Data API (PostgREST-style
  interface over the Lakebase Postgres tables that replaced the "Resers"
  SQL Server datasource).
- Handles Databricks machine-to-machine (M2M) OAuth2 client-credentials auth,
  caching the bearer token in application scope until it expires.
- Provides table CRUD helpers, a stored-procedure (/rpc) caller, and a
  toQuery() converter so existing <cfoutput query="..."> / recordCount call
  sites can consume results with minimal change.

CONFIG (passed to init, normally from AwayX.config -> application.LakebaseConfig):
  enabled       boolean  - master on/off switch
  tokenUrl      string   - Databricks OIDC token endpoint, e.g. https://<workspace-host>/oidc/v1/token
  clientId      string   - service principal client id
  clientSecret  string   - service principal secret (keep OUT of source control)
  apiBaseUrl    string   - Lakebase Data API base, e.g. https://<instance>.database.cloud.databricks.com
  schema        string   - default schema/namespace for table paths (optional)
  scope         string   - OAuth scope (default "all-apis")
  timeout       numeric  - per-request timeout in seconds (default 30)

USAGE:
  <cfset lb = application.oLakebase>
  <cfset qUsers = lb.toQuery( lb.selectRows("_Users", { "User_Code":"eq.jsmith", "select":"User_ID,User_Code,Name_First" }) )>
  <cfset newRow = lb.insertRow("Billback", { "Billback_ID":createUUID(), "BB_Start_Date":now() })>
  <cfset result = lb.callProcedure("generate_contract_number", {})>
--->
<cfcomponent name="LakebaseClient" displayname="Databricks Lakebase Data API client" output="false">

	<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
	<cffunction name="init" access="public" returntype="LakebaseClient" output="false"
		hint="Initialize the client with a configuration structure.">
		<cfargument name="config" type="struct" required="true">

		<cfset var cfg = duplicate(arguments.config)>
		<cfset var name = "">

		<!--- apply defaults for optional keys --->
		<cfif NOT structKeyExists(cfg, "enabled")><cfset cfg.enabled = true></cfif>
		<cfif NOT structKeyExists(cfg, "schema")><cfset cfg.schema = ""></cfif>
		<cfif NOT structKeyExists(cfg, "scope") OR NOT len(trim(cfg.scope))><cfset cfg.scope = "all-apis"></cfif>
		<cfif NOT structKeyExists(cfg, "timeout") OR NOT isNumeric(cfg.timeout)><cfset cfg.timeout = 30></cfif>

		<!--- dual-capable allowlists: which tables/procs are safe to route to Lakebase --->
		<cfset variables.migratedTables = structNew()>
		<cfif structKeyExists(cfg, "MIGRATED_TABLES") AND isArray(cfg.MIGRATED_TABLES)>
			<cfloop array="#cfg.MIGRATED_TABLES#" index="name">
				<cfset variables.migratedTables[lCase(name)] = true>
			</cfloop>
		</cfif>

		<cfset variables.migratedProcs = structNew()>
		<cfif structKeyExists(cfg, "MIGRATED_PROCS") AND isArray(cfg.MIGRATED_PROCS)>
			<cfloop array="#cfg.MIGRATED_PROCS#" index="name">
				<cfset variables.migratedProcs[lCase(name)] = true>
			</cfloop>
		</cfif>

		<!--- normalize base url (strip trailing slash) --->
		<cfif structKeyExists(cfg, "apiBaseUrl")>
			<cfset cfg.apiBaseUrl = reReplace(trim(cfg.apiBaseUrl), "/+$", "")>
		<cfelse>
			<cfset cfg.apiBaseUrl = "">
		</cfif>

		<cfset variables.config = cfg>
		<cfset variables.tokenLockName = "lakebase_token_" & hash(cfg.apiBaseUrl & cfg.tokenUrl)>

		<cfreturn this>
	</cffunction>

	<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
	<cffunction name="isEnabled" access="public" returntype="boolean" output="false"
		hint="Whether the Lakebase integration is switched on and configured.">
		<cfreturn structKeyExists(variables, "config")
			AND variables.config.enabled
			AND len(trim(variables.config.apiBaseUrl)) GT 0
			AND len(trim(variables.config.tokenUrl)) GT 0>
	</cffunction>

	<cffunction name="isTableMigrated" access="public" returntype="boolean" output="false"
		hint="Whether the given table is allowlisted to read/write via Lakebase instead of SQL Server (AwayX.config LAKEBASE.MIGRATED_TABLES).">
		<cfargument name="name" type="string" required="true">
		<cfreturn structKeyExists(variables.migratedTables, lCase(arguments.name))>
	</cffunction>

	<cffunction name="isProcMigrated" access="public" returntype="boolean" output="false"
		hint="Whether the given stored procedure is allowlisted to call via Lakebase /rpc instead of SQL Server (AwayX.config LAKEBASE.MIGRATED_PROCS).">
		<cfargument name="name" type="string" required="true">
		<cfreturn structKeyExists(variables.migratedProcs, lCase(arguments.name))>
	</cffunction>

	<!--- ================================================================= --->
	<!--- AUTHENTICATION                                                     --->
	<!--- ================================================================= --->

	<cffunction name="getAccessToken" access="public" returntype="string" output="false"
		hint="Returns a valid OAuth2 bearer token, fetching/refreshing and caching in application scope.">

		<cfset var cache = "">
		<cfset var nowEpoch = int(getTickCount() / 1000)>

		<!--- fast path: return cached token if still valid (60s safety margin) --->
		<cfif structKeyExists(application, "lakebaseToken")
			AND isStruct(application.lakebaseToken)
			AND structKeyExists(application.lakebaseToken, "access_token")
			AND len(application.lakebaseToken.access_token)
			AND application.lakebaseToken.expiresEpoch GT (nowEpoch + 60)>
			<cfreturn application.lakebaseToken.access_token>
		</cfif>

		<cflock name="#variables.tokenLockName#" type="exclusive" timeout="15">
			<!--- re-check inside lock in case another request refreshed it --->
			<cfset nowEpoch = int(getTickCount() / 1000)>
			<cfif structKeyExists(application, "lakebaseToken")
				AND isStruct(application.lakebaseToken)
				AND structKeyExists(application.lakebaseToken, "access_token")
				AND len(application.lakebaseToken.access_token)
				AND application.lakebaseToken.expiresEpoch GT (nowEpoch + 60)>
				<cfreturn application.lakebaseToken.access_token>
			</cfif>

			<cfset cache = fetchToken()>
			<cfset application.lakebaseToken = cache>
		</cflock>

		<cfreturn cache.access_token>
	</cffunction>

	<cffunction name="fetchToken" access="private" returntype="struct" output="false"
		hint="Calls the Databricks OIDC token endpoint (M2M client-credentials grant).">

		<cfset var httpResp = "">
		<cfset var json = "">
		<cfset var basic = toBase64(variables.config.clientId & ":" & variables.config.clientSecret)>
		<cfset var result = structNew()>
		<cfset var attempt = 0>
		<cfset var maxAttempts = 5>
		<cfset var statusStr = "">

		<!--- Retry on low-level connection failures only, same rationale as sendRequest(). --->
		<cfloop condition="true">
			<cfset attempt++>

			<cfhttp url="#variables.config.tokenUrl#" method="post" result="httpResp"
				timeout="#variables.config.timeout#" charset="utf-8">
				<cfhttpparam type="header"    name="Authorization" value="Basic #basic#">
				<cfhttpparam type="header"    name="Content-Type"  value="application/x-www-form-urlencoded">
				<cfhttpparam type="header"    name="Connection"    value="close">
				<cfhttpparam type="formfield" name="grant_type"    value="client_credentials">
				<cfhttpparam type="formfield" name="scope"         value="#variables.config.scope#">
			</cfhttp>

			<cfset statusStr = isDefined("httpResp.statusCode") ? httpResp.statusCode : "">
			<cfif (left(statusStr, 1) GTE "1" AND left(statusStr, 1) LTE "5") OR attempt GTE maxAttempts>
				<cfbreak>
			</cfif>
			<cfset sleep(1000 * attempt)>
		</cfloop>

		<cfif NOT isDefined("httpResp.statusCode") OR left(httpResp.statusCode, 1) NEQ "2">
			<cfthrow type="Lakebase.AuthError"
				message="Lakebase OAuth token request failed."
				detail="Status: #(isDefined('httpResp.statusCode') ? httpResp.statusCode : 'n/a')# - #(isDefined('httpResp.fileContent') ? left(httpResp.fileContent, 500) : '')#">
		</cfif>

		<cfset json = deserializeJSON(httpResp.fileContent)>

		<cfset result.access_token = json.access_token>
		<!--- expires_in is seconds from now; store absolute epoch --->
		<cfset result.expiresEpoch = int(getTickCount() / 1000)
			+ (structKeyExists(json, "expires_in") ? val(json.expires_in) : 3600)>

		<cfreturn result>
	</cffunction>

	<!--- ================================================================= --->
	<!--- LOW-LEVEL REQUEST                                                  --->
	<!--- ================================================================= --->

	<cffunction name="sendRequest" access="public" returntype="any" output="false"
		hint="Performs an authenticated request against the Lakebase Data API and returns the parsed body.">
		<cfargument name="method"  type="string"  required="true">
		<cfargument name="path"    type="string"  required="true" hint="Path beginning with '/', appended to apiBaseUrl.">
		<cfargument name="body"    type="any"     required="false" default="">
		<cfargument name="headers" type="struct"  required="false" default="#structNew()#">

		<cfset var httpResp = "">
		<cfset var token = getAccessToken()>
		<cfset var fullUrl = variables.config.apiBaseUrl & arguments.path>
		<cfset var hdrKey = "">
		<cfset var attempt = 0>
		<cfset var maxAttempts = 5>
		<cfset var statusStr = "">

		<!--- Retry on low-level connection failures only (e.g. a pooled keep-alive connection
		      the JVM reused after the server already closed it) -- never on a real HTTP error
		      response, which is a legitimate result, not a transport fault. --->
		<cfloop condition="true">
			<cfset attempt++>

			<cfhttp url="#fullUrl#" method="#arguments.method#" result="httpResp"
				timeout="#variables.config.timeout#" charset="utf-8">
				<cfhttpparam type="header" name="Authorization" value="Bearer #token#">
				<cfhttpparam type="header" name="Accept"        value="application/json">
				<cfhttpparam type="header" name="Connection"    value="close">

				<!--- caller-supplied headers (e.g. Prefer: return=representation) --->
				<cfloop collection="#arguments.headers#" item="hdrKey">
					<cfhttpparam type="header" name="#hdrKey#" value="#arguments.headers[hdrKey]#">
				</cfloop>

				<cfif isStruct(arguments.body) OR isArray(arguments.body)>
					<cfhttpparam type="header" name="Content-Type" value="application/json">
					<cfhttpparam type="body" value="#serializeJSON(arguments.body)#">
				<cfelseif isSimpleValue(arguments.body) AND len(arguments.body)>
					<cfhttpparam type="header" name="Content-Type" value="application/json">
					<cfhttpparam type="body" value="#arguments.body#">
				</cfif>
			</cfhttp>

			<cfset statusStr = isDefined("httpResp.statusCode") ? httpResp.statusCode : "">
			<cfif (left(statusStr, 1) GTE "1" AND left(statusStr, 1) LTE "5") OR attempt GTE maxAttempts>
				<cfbreak>
			</cfif>
			<cfset sleep(1000 * attempt)>
		</cfloop>

		<cfreturn handleResponse(httpResp)>
	</cffunction>

	<cffunction name="handleResponse" access="private" returntype="any" output="false"
		hint="Validates HTTP status and deserializes the JSON body (returns empty array on no content).">
		<cfargument name="httpResp" type="any" required="true">

		<cfset var status = isDefined("arguments.httpResp.statusCode") ? arguments.httpResp.statusCode : "0">
		<cfset var content = isDefined("arguments.httpResp.fileContent") ? arguments.httpResp.fileContent : "">

		<cfif left(status, 1) NEQ "2">
			<cfthrow type="Lakebase.ApiError"
				message="Lakebase Data API request failed."
				detail="Status: #status# - #left(toString(content), 800)#">
		</cfif>

		<cfif isSimpleValue(content) AND len(trim(content)) AND isJSON(content)>
			<cfreturn deserializeJSON(content)>
		</cfif>

		<cfreturn arrayNew(1)>
	</cffunction>

	<!--- ================================================================= --->
	<!--- TABLE CRUD (PostgREST-style)                                       --->
	<!--- ================================================================= --->

	<cffunction name="selectRows" access="public" returntype="array" output="false"
		hint="GET rows from a table. params are PostgREST query params, e.g. { 'select':'a,b', 'User_Code':'eq.jsmith', 'order':'Name_Last.asc' }.">
		<cfargument name="table"  type="string" required="true">
		<cfargument name="params" type="struct" required="false" default="#structNew()#">

		<cfset var result = sendRequest(method="get", path=tablePath(arguments.table) & buildQueryString(arguments.params))>
		<cfreturn asArray(result)>
	</cffunction>

	<cffunction name="insertRow" access="public" returntype="any" output="false"
		hint="POST one row (struct) or many rows (array of structs). Returns the inserted representation.">
		<cfargument name="table" type="string" required="true">
		<cfargument name="data"  type="any"    required="true">

		<cfset var hdr = { "Prefer" = "return=representation" }>
		<cfreturn sendRequest(method="post", path=tablePath(arguments.table), body=arguments.data, headers=hdr)>
	</cffunction>

	<cffunction name="updateRows" access="public" returntype="any" output="false"
		hint="PATCH rows matching filter params with the supplied data struct.">
		<cfargument name="table"  type="string" required="true">
		<cfargument name="filter" type="struct" required="true" hint="PostgREST filters, e.g. { 'User_ID':'eq.#id#' }.">
		<cfargument name="data"   type="struct" required="true">

		<cfset var hdr = { "Prefer" = "return=representation" }>
		<cfreturn sendRequest(method="patch", path=tablePath(arguments.table) & buildQueryString(arguments.filter),
			body=arguments.data, headers=hdr)>
	</cffunction>

	<cffunction name="deleteRows" access="public" returntype="any" output="false"
		hint="DELETE rows matching filter params.">
		<cfargument name="table"  type="string" required="true">
		<cfargument name="filter" type="struct" required="true">

		<cfreturn sendRequest(method="delete", path=tablePath(arguments.table) & buildQueryString(arguments.filter))>
	</cffunction>

	<!--- ================================================================= --->
	<!--- STORED PROCEDURES / FUNCTIONS (/rpc)                               --->
	<!--- ================================================================= --->

	<cffunction name="callProcedure" access="public" returntype="any" output="false"
		hint="Invokes a Lakebase stored procedure / function exposed at /rpc/{name} with a struct of named args.">
		<cfargument name="name" type="string" required="true">
		<cfargument name="args" type="struct" required="false" default="#structNew()#">

		<cfset var prefix = len(variables.config.schema) ? "/" & variables.config.schema : "">
		<cfreturn sendRequest(method="post", path=prefix & "/rpc/" & arguments.name, body=arguments.args)>
	</cffunction>

	<!--- ================================================================= --->
	<!--- HELPERS                                                            --->
	<!--- ================================================================= --->

	<cffunction name="toQuery" access="public" returntype="query" output="false"
		hint="Converts a JSON array-of-structs (Data API result) into a native CF query object so legacy call sites keep working.">
		<cfargument name="rows" type="any" required="true">
		<cfargument name="columns" type="string" required="false" default=""
			hint="Comma-separated column list to use when rows is empty, so callers get the same defined columns SQL Server would return for a zero-row result.">

		<cfset var arr = asArray(arguments.rows)>
		<cfset var cols = "">
		<cfset var q = "">
		<cfset var i = 0>
		<cfset var c = "">
		<cfset var colName = "">
		<cfset var row = "">

		<cfif arrayLen(arr) EQ 0>
			<cfif len(trim(arguments.columns))>
				<cfreturn queryNew(arguments.columns)>
			</cfif>
			<cfreturn queryNew("")>
		</cfif>

		<!--- derive columns from the union of keys in the first row --->
		<cfset cols = structKeyArray(arr[1])>
		<cfset q = queryNew(arrayToList(cols))>
		<cfset queryAddRow(q, arrayLen(arr))>

		<cfloop from="1" to="#arrayLen(arr)#" index="i">
			<cfset row = arr[i]>
			<cfloop from="1" to="#arrayLen(cols)#" index="c">
				<cfset colName = cols[c]>
				<cfif structKeyExists(row, colName) AND NOT isNull(row[colName])>
					<cfset querySetCell(q, colName, isSimpleValue(row[colName]) ? row[colName] : serializeJSON(row[colName]), i)>
				</cfif>
			</cfloop>
		</cfloop>

		<cfreturn q>
	</cffunction>

	<cffunction name="tablePath" access="private" returntype="string" output="false"
		hint="Builds the resource path for a table, honoring an optional default schema.">
		<cfargument name="table" type="string" required="true">
		<cfif len(variables.config.schema)>
			<cfreturn "/" & variables.config.schema & "/" & arguments.table>
		</cfif>
		<cfreturn "/" & arguments.table>
	</cffunction>

	<cffunction name="buildQueryString" access="private" returntype="string" output="false"
		hint="Turns a struct of params into a URL query string with encoded values.">
		<cfargument name="params" type="struct" required="true">

		<cfset var parts = arrayNew(1)>
		<cfset var key = "">

		<cfif structIsEmpty(arguments.params)>
			<cfreturn "">
		</cfif>

		<cfloop collection="#arguments.params#" item="key">
			<cfset arrayAppend(parts, lCase(key) & "=" & urlEncodedFormat(arguments.params[key]))>
		</cfloop>

		<cfreturn "?" & arrayToList(parts, "&")>
	</cffunction>

	<cffunction name="asArray" access="private" returntype="array" output="false"
		hint="Normalizes a Data API body into an array of rows.">
		<cfargument name="value" type="any" required="true">

		<cfif isArray(arguments.value)>
			<cfreturn arguments.value>
		<cfelseif isStruct(arguments.value)>
			<cfreturn [ arguments.value ]>
		</cfif>
		<cfreturn arrayNew(1)>
	</cffunction>

</cfcomponent>
