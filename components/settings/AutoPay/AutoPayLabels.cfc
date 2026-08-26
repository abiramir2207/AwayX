<cfcomponent displayname="AutoPayLabels" hint="Controller for auto-pay labels" output="false">

	<!--- GET COLUMN NAMES FOR CURRENTLY SELECTED TABLE --->
	<cffunction name="GetColNames" access="public" returntype="any" output="false" displayname="GetColNames" hint="Gets the column names.">
		<cfargument name="tblType" required="true" default="" type="string">
		<cfquery name="getColNames" datasource="#application.datasource#">
			SELECT TOP 0 *
			FROM #arguments.tblType#
		</cfquery>
		<cfreturn getColNames>
	</cffunction>

	<cffunction name="GetLabels" access="public" returntype="any" output="false" displayname="GetLabels" hint="Gets the Labels if they exist.">
		<cfargument name="tableCode" required="true" default="" type="string">
		<cfquery name="getLabels" datasource="#application.datasource#">
			SELECT *
			FROM BB_Auto_Report_Export_Labels
			WHERE Table_Code = '#arguments.tableCode#'
			ORDER BY Sequence
		</cfquery>
		<cfreturn getLabels>
	</cffunction>

	<cffunction name="modifyLabels" access="public" returntype="any" output="false" displayname="insertLabels" hint="Inserts new label names.">
		<cfif FORM.actionEdit EQ 0>
			<cfquery name="Deleteallpriorrecords" datasource="#application.datasource#">
				DELETE FROM BB_Auto_Report_Export_Labels
				WHERE Table_Code = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.tableCode#">
			</cfquery>
		</cfif>

		<cfloop from="1" to="#FORM.colCount#" index="i">

			<cfif i LT 10>
				<cfset activeSequence = '000' & i>
			<cfelseif i GTE 10 AND i LT 100>
				<cfset activeSequence = '00' & i>
			<cfelseif i GTE 100 AND i LT 1000>
				<cfset activeSequence = '0' & i>
			<cfelseif i GTE 1000 AND i LT 10000>
				<cfset activeSequence = i>
			</cfif>

			<cfset dbColName = evaluate("#'FORM.'&'dbColName_'&'#activeSequence#'#")>
			<cfset defaultColName = evaluate("#'FORM.'&'defaultColName_'&'#activeSequence#'#")>
			<cfset customColName = evaluate("#'FORM.'&'customColName_'&'#activeSequence#'#")>

			<cfparam name="FORM.active_#activeSequence#" default="0">
				<cfif evaluate("FORM.active_#activeSequence#") NEQ 0>
					<cfset active = 1>
				<cfelse>
					<cfset active = 0>
					<cfset inactiveSequence = '99999'>
				</cfif>


			<cfif FORM.actionEdit EQ 1>
				<cfset ID = evaluate("#'FORM.'&'ID_'&'#activeSequence#'#")>
				<cfquery name="insertLabels" datasource="#application.datasource#">
					UPDATE BB_Auto_Report_Export_Labels
					SET Default_Col_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#defaultColName#">
						,Custom_Col_Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#customColName#">
						,Active = <cfqueryparam cfsqltype="cf_sql_bit" value="#active#">
						<cfif evaluate("FORM.active_#activeSequence#") EQ 0>
							,Sequence = <cfqueryparam cfsqltype="cf_sql_varchar" value="#inactiveSequence#">
						</cfif>
					WHERE BB_Auto_Report_Export_Labels_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ID#">
				</cfquery>
			<cfelse>
				<cfquery name="insertLabels" datasource="#application.datasource#">
					INSERT INTO BB_Auto_Report_Export_Labels
					(
						Table_Code,
						DB_Col_Name,
						Default_Col_Name,
						Custom_Col_Name,
						Active,
						Sequence,
						Deleted
					)
					VALUES
					(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.tableCode#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#dbColName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#defaultColName#">,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#customColName#">,
						<cfqueryparam cfsqltype="cf_sql_bit" value="#active#">,
					<cfif evaluate("FORM.active_#activeSequence#") NEQ 0>
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#activeSequence#">,
					<cfelse>
						<cfqueryparam cfsqltype="cf_sql_integer" value="#inactiveSequence#">,
					</cfif>
						<cfqueryparam cfsqltype="cf_sql_bit" value="0">
					)
				</cfquery>
			</cfif>
		</cfloop>

		<cfset message = "Labels successfully updated for '" & FORM.tableName & "'">
		<cfreturn message>
	</cffunction>

</cfcomponent>