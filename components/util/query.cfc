<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\util\query.cfc
	Date:      Jan 6, 2012
	Author:    Chris Nguyen

	Purposes:  Houses all query manipulation functions

	Remarks:
			- Append 'resetUtil' to the URL to reload application.udf object (you need to do this to test your changes in this file).
			- Calling UDF defined in other .cfc under \components\util\ folder:

			  * Syntax:   variables.library.<util_instance>.<udf_name>
			  * Example:  local.urlData = variables.library.string.parseURLData();

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="Query" output="false" hint="This has user defined functions for query manipulation.">

	<cffunction name="Init" access="public" returntype="any" output="false">
		<cfargument name="Library" type="any" required="true"/>

		<cfscript>
			// The library variable is a reference to the main UDF library. This is
			// going to be used to reference other parts of the library that are not
			// in this specific component.
			variables.Library = arguments.Library;
			return (this);
		</cfscript>

	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="globalTempTableName" access="public" returntype="string" output="false" hint="Returns a unique global temporary table name with a prefix of ##">
		<!---
		   // tempdb is where global temp tables are stored
		   // :: it is shared between databases in the same server
		   // :: need to prefix the table name with a datasource to avoid collisions
		--->
		<cfif isDefined('request.AccessStructure.User_ID')>
			<cfreturn replace(	'####'
								& application.datasource
								& '_' & request.AccessStructure.User_ID
								& '_' & getTickCount()
								& '_' & randRange(11111, 99999, 'SHA1PRNG'), 	'-', '_', 'all')>
		<cfelse>
			<cfreturn 	'####'
						& application.datasource
						& '_' & getTickCount()
						& '_' & randRange(11111, 99999, 'SHA1PRNG')>
		</cfif>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="clearUserGlobalTempTable" access="public" output="true" hint="Clear out global temporary table(s)">
		<cfargument name="tableName" required="true" type="string" hint='Pass "ALL" to remove all global temp table created by logged in user; otherwise pass a specific table name without the "##" leading characters'>

		<!--- drop a single user global table in current datasource --->
		<cfif arguments.tableName neq 'all'>
			<cfif left(arguments.tableName, 2) eq '####'>
				<cfset local.dropTable = false>

				<!--- drop table only when table name has the same datasource & same logged in user --->
				<cfif isDefined('request.AccessStructure.User_ID')>
					<cfset local.dropTable = arguments.tableName contains (application.datasource & '_' & request.AccessStructure.User_ID & '_')>
				<cfelse>
					<!--- drop table only when table name has the same datasource (e.g. as in scheduled task when user logged in ID is not available) --->
					<cfset local.dropTable = arguments.tableName contains (application.datasource & '_')>
				</cfif>

				<cfif local.dropTable>
					<!--- delete permanently user global temp table --->
					<cfoutput>
					<cfquery name="local.dropTable" datasource="#application.datasource#">
						IF OBJECT_ID('tempdb..#arguments.tableName#') IS NOT NULL
							DROP TABLE #arguments.tableName#
					</cfquery>
					</cfoutput>
				</cfif>
			</cfif>

		<!--- drop ALL user global tables in current datasource --->
		<cfelseif isDefined('request.AccessStructure.User_ID')>
			<!--- set up a global temp table name wildcard matching for current user --->
			<cfset local.gTempTableNameLike = 	'##'
												& application.datasource
												& '_'
												& request.AccessStructure.User_ID
												& '_%'>

			<!--- gather all global temp tables belong to logged in user ---->
			<cfquery name="local.userGlobalTemp" datasource="#application.datasource#">
				SELECT Name FROM tempdb.sys.tables
				 WHERE Name LIKE <cfoutput>'#local.gTempTableNameLike#'</cfoutput>
			</cfquery>

			<!--- delete permanently user global temp tables --->
			<cfoutput query="local.userGlobalTemp">
				<cfquery name="local.dropTable" datasource="#application.datasource#">
					IF OBJECT_ID('tempdb..#####local.userGlobalTemp.Name#') IS NOT NULL
						DROP TABLE #local.userGlobalTemp.Name#
				</cfquery>
			</cfoutput>
		</cfif>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="columnMaxLength" access="public" returntype="string" output="false" hint="Returns maximum length of a string column.">
		<cfargument name="tableNameDotColumnName" required="true" type="string" hint="e.g. Contract_Main.">

		<cfset arguments.tableNameDotColumnName = trim(arguments.tableNameDotColumnName)>

		<cfquery name="local.query" datasource="#application.datasource#">
			SELECT Character_Maximum_Length = ISNULL(Character_Maximum_Length, -1)
				FROM information_schema.COLUMNS
				 WHERE Table_Name = '#listGetAt(arguments.tableNameDotColumnName, 1, ".")#'
				 AND Column_Name = '#listGetAt(arguments.tableNameDotColumnName, 2, ".")#'
		</cfquery>

		<!--- handle invalid columns: return negative value to trigger an error --->
		<cfreturn (local.query.recordCount ? local.query.Character_Maximum_Length : -1)>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="OutputQueryRow" access="public" returntype="void" output="true" hint="Outputs the current row of the passed in query.">
		<cfargument name="Query" type="query" required="true" hint="The query whose row data we are outputting."/>
		<cfargument name="Row" type="numeric" required="false" default="#arguments.Query.CurrentRow#" hint="The row we are going to output (defaults to current row of the passed in query)."/>

		<cfset var local = StructNew()/>

		<!--- Loop over each query column and output both the column name and cell value (in this row only). --->
		<cfloop index="local.ColumnName" list="#arguments.Query.ColumnList#" delimiters=",">
			#local.ColumnName#: #arguments.Query[local.ColumnName][arguments.Row]#<br/>
		</cfloop>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cfscript>
	/**
	 * Accepts a specifically formatted chunk of text, and returns it as a query object.
	 * v2 rewrite by Jamie Jackson
	 *
	 * @param queryData 	 Specifically format chunk of text to convert to a query. (Required)
	 * @return Returns a query object.
	 * @author Bert Dawson (bert@redbanner.com)
	 * @version 2, December 18, 2007
	 */
	function querySim(queryData) output="false" {
		var fieldsDelimiter="|";
		var colnamesDelimiter=",";
		var listOfColumns="";
		var tmpQuery="";
		var numLines="";
		var cellValue="";
		var cellValues="";
		var colName="";
		var lineDelimiter=chr(10) & chr(13);
		var lineNum=0;
		var colPosition=0;

		// the first line is the column list, eg "column1,column2,column3"
		listOfColumns = Trim(ListGetAt(queryData, 1, lineDelimiter));

		// create a temporary Query
		tmpQuery = QueryNew(listOfColumns);

		// the number of lines in the queryData
		numLines = ListLen(queryData, lineDelimiter);

		// loop though the queryData starting at the second line
		for(lineNum=2;  lineNum LTE numLines;  lineNum = lineNum + 1) {
			cellValues = ListGetAt(queryData, lineNum, lineDelimiter);

			if (ListLen(cellValues, fieldsDelimiter) IS ListLen(listOfColumns,",")) {
				QueryAddRow(tmpQuery);
				for (colPosition=1; colPosition LTE ListLen(listOfColumns); colPosition = colPosition + 1){
					cellValue = Trim(ListGetAt(cellValues, colPosition, fieldsDelimiter));
					colName   = Trim(ListGetAt(listOfColumns,colPosition));
					QuerySetCell(tmpQuery, colName, cellValue);
				}
			}
		}

		return( tmpQuery );
	}
	</cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="QueryToCSV" access="public" returntype="string" output="false" hint="I take a query and convert it to a comma separated value string.">
		<cfargument name="Query" type="query" required="true" hint="I am the query being converted to CSV."/>
		<cfargument name="Fields" type="string" required="false" hint="I am the list of query fields to be used when creating the CSV value."/>
		<cfargument name="CreateHeaderRow" type="boolean" required="false" default="true" hint="I flag whether or not to create a row of header values."/>
		<cfargument name="Delimiter" type="string" required="false" default="," hint="I am the field delimiter in the CSV value."/>

		<!--- Define the local scope. --->
		<cfset var LOCAL = {} />

		<!---
			First, we want to set up a column index so that we can
			iterate over the column names faster than if we used a
			standard list loop on the passed-in list.
		--->
		<cfset LOCAL.ColumnNames = [] />

		<cfif isDefined( "arguments.fields" ) >
			<!---
				Loop over column names and index them numerically. We
				are working with an array since I believe its loop times
				are faster than that of a list.
			--->
			<cfloop index="LOCAL.ColumnName" list="#ARGUMENTS.Fields#" delimiters=",">
				<!--- Store the current column name. --->
				<cfset ArrayAppend( LOCAL.ColumnNames, Trim( LOCAL.ColumnName ) ) />
			</cfloop>
		<cfelse>
			<cfset LOCAL.ColumnNames = arguments.query.getMetaData().getColumnLabels() >
		</cfif>

		<!--- Store the column count. --->
		<cfset LOCAL.ColumnCount = ArrayLen( LOCAL.ColumnNames ) />

		<!---
			Now that we have our index in place, let's create
			a string buffer to help us build the CSV value more
			effiently.
		--->
		<cfset LOCAL.Buffer = CreateObject( "java", "java.lang.StringBuffer" ).Init() />

		<!--- Create a short hand for the new line characters. --->
		<cfset LOCAL.NewLine = (Chr( 13 ) & Chr( 10 )) />


		<!--- Check to see if we need to add a header row. --->
		<cfif ARGUMENTS.CreateHeaderRow>

			<!--- Create array to hold row data. --->
			<cfset LOCAL.RowData = [] />

			<!--- Loop over the column names. --->
			<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">

				<!--- Add the field name to the row data. --->
				<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = """#LOCAL.ColumnNames[ LOCAL.ColumnIndex ]#""" />

			</cfloop>

			<!--- Append the row data to the string buffer. --->
			<cfset LOCAL.Buffer.Append( JavaCast( "string", ( ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter	) & LOCAL.NewLine )) ) />

		</cfif>


		<!---
			Now that we have dealt with any header value, let's
			convert the query body to CSV. When doing this, we are
			going to qualify each field value. This is done be
			default since it will be much faster than actually
			checking to see if a field needs to be qualified.
		--->

		<!--- Loop over the query. --->
		<cfloop query="ARGUMENTS.Query">

			<!--- Create array to hold row data. --->
			<cfset LOCAL.RowData = [] />

			<!--- Loop over the columns. --->
			<cfloop index="LOCAL.ColumnIndex" from="1" to="#LOCAL.ColumnCount#" step="1">

				<!--- Add a "=" (equal to sign), so that the number values starting with zeroes, preserve the zeroes. --->
				<cfset local.prefix = (isNumeric(ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ]) ? '=' : '')>

				<!--- Add the field to the row data. --->
				<cfset LOCAL.RowData[ LOCAL.ColumnIndex ] = local.prefix & """#Replace( ARGUMENTS.Query[ LOCAL.ColumnNames[ LOCAL.ColumnIndex ] ][ ARGUMENTS.Query.CurrentRow ], """", """""", "all" )#"""  />

			</cfloop>


			<!--- Append the row data to the string buffer. --->
			<cfset LOCAL.Buffer.Append( JavaCast( "string", ( ArrayToList( LOCAL.RowData, ARGUMENTS.Delimiter ) & LOCAL.NewLine )) ) />

		</cfloop>


		<!--- Return the CSV value. --->
		<cfreturn LOCAL.Buffer.ToString() />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="columnInfo" access="public" output="false" returntype="query" hint="Return column information from database.">
		<cfargument name="table_name" required="true">
		<cfargument name="column_name" required="false">

		<cftry>
			<cfdbinfo datasource="#application.datasource#" name="local.result" type="columns" table="#trim(arguments.table_name)#">

			<cfif structKeyExists(arguments, "column_name")>
				<cfquery dbtype="query" name="local.result">
					SELECT *
					  FROM [local].result
					 WHERE lower(column_name) = '#trim(lcase(arguments.column_name))#'
				</cfquery>
			</cfif>
		<cfcatch type="any">
			<cfset local.result = queryNew("column_name,column_size,type_name,is_nullable,is_primarykey,is_foreignkey,referenced_primarykey,referenced_primary_table,decimal_digits,column_default_value,char_octet_length,ordinal_position,remarks")>
		</cfcatch>
		</cftry>

		<cfreturn local.result>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="rowZeros" access="public" output="false" returntype="query" hint="Return a query with one row and zero value columns.">
		<cfargument name="columns_list" required="true">
		<cfargument name="zero_column_masks" required="false" default="_CS,_LBS,_SUM">

		<cfscript>
			local.qZero        = queryNew( arguments.columns_list );
			local.column_masks = listToArray( arguments.zero_column_masks );
			local.qZero.addRow();

			for ( local.column_name in listToArray( arguments.columns_list ) ) {
				for ( local.column_mask in local.column_masks ) {
					if ( local.column_name contains local.column_mask ) {
						local.qZero.setCell(local.column_name, "0");
						break;
					}
				}
			};

			return local.qZero;
		</cfscript>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cfscript>
		/**
		 * Returns an array of valid columns in query
		 *
		 * @param1 - q :: query to validate
		 * @param2 - cols :: columns to be validated in returned array (optional) default to all columns in query
		 *
		 */
		private function validate_query_columns( q, cols ) output="false" {
			if (not structKeyExists(arguments, "cols")) {
				return listToArray( lcase(q.columnList) );
			}
			else {
				local.columns = [];
				local.columns_param = listToArray( reReplace(lcase(arguments.cols), "\s{2,}|#chr(13)#|#chr(9)#|#chr(32)#|\n|\r", "", "ALL" ) );
				// remove undefined columns
				for (local.column in local.columns_param) {
					// do not validate constants which start with a backslash character
					if (left(local.column, 1) is '\') {
						arrayAppend(local.columns, lcase(local.column));
					}
					else if ( structKeyExists(q, local.column) ) {
						arrayAppend(local.columns, lcase(local.column));
					}
				}
				return local.columns;
			}
		}

		/**
		 * Returns JSON string to feed into Ag-Grid based on a query
		 *
		 * @param1 - q :: query to convert (required)
		 * @param2 - cols :: columns to be included in returned JSON string (optional) default to all columns in query
		 * @param3 - startrow :: default to first row (optional)
		 * @param4 - endrow :: default to last row in the query (optional)
		 *
		 */
		public function toAgGridJSON( q, cols, startrow, endrow ) output="false" {
			local.result   = [];
			local.columns  = structKeyExists(arguments, "cols")
								? validate_query_columns( q, cols )
								: listToArray( lcase(q.columnList) );
			local.startrow = (structKeyExists(arguments, "startrow") and isNumeric(arguments.startrow)
								? max(1, val(arguments.startrow))
								: 1);
			local.endrow   = (structKeyExists(arguments, "endrow") and isNumeric(arguments.endrow)
								? min(max(1, val(arguments.endrow)), q.recordCount)
								: q.recordCount);

			if (local.endrow gte local.startrow) {
				for ( local.current_row=local.startrow; local.current_row <= local.endrow; local.current_row++ ) {
					local.row = {};
					for (local.column in local.columns) {
						local.row[ local.column ] = q[ local.column ][ local.current_row ];
					}
					arrayAppend(local.result, local.row);
				}
			}

			return serializeJSON( local.result );
		}

		/**
		 * Returns JSON string to feed into DataTables based on a query
		 *
		 * @param1 - q :: query to convert (required)
		 * @param2 - cols :: columns to be included in returned JSON string (optional) default to all columns in query
		 * @param3 - startrow :: default to first row (optional)
		 * @param4 - endrow :: default to last row in the query (optional)
		 *
		 */
		public function toDtJSON( q, cols, startrow, endrow ) output="false" {
			local.result   = [];
			local.columns  = structKeyExists(arguments, "cols")
								? validate_query_columns( q, cols )
								: listToArray( lcase(q.columnList) );
			local.startrow = (structKeyExists(arguments, "startrow") and isNumeric(arguments.startrow)
								? max(1, val(arguments.startrow))
								: 1);
			local.endrow   = (structKeyExists(arguments, "endrow") and isNumeric(arguments.endrow)
								? min(max(1, val(arguments.endrow)), q.recordCount)
								: q.recordCount);

			if (local.endrow gte local.startrow) {
				for ( local.current_row=local.startrow; local.current_row <= local.endrow; local.current_row++ ) {
					local.row = [];
					for (local.column in local.columns) {
						// load constants :: start with a backslash character
						arrayAppend( local.row, (left(local.column, 1) is '\')
													// detect for empty string after backslash character
													? ( len(local.column) eq 1 ? '' : right(local.column, len(local.column) - 1) )
													: q[ local.column ][ local.current_row ] );
					}
					arrayAppend(local.result, local.row);
				}
			}

			return serializeJSON( local.result );
		}

		/**
		 * Returns multiple setting values based on a list of setting names
		 */
		public function get_Settings( setting_names, missing_not_allowed ) output="false" {
			if (!structKeyExists(arguments, "missing_not_allowed")) {
				arguments.missing_not_allowed = true;
			}
			local.result = {};

			for (local.setting_name in arguments.setting_names) {
				local.result[ trim(lcase(local.setting_name)) ] = get_Setting( local.setting_name, arguments.missing_not_allowed );
            }

			return local.result;
		}
	</cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cfscript>
    function get_Setting ( required string name, missing_not_allowed = 1 ) output="false" hint="Return interal setting value." {
			// remove leading/trailing spaces
			arguments.name = trim( arguments.name );

			if ( arguments.name eq '' ) {
				throw( type="configuration", message="get_setting() 'name' argument cannot be empty." );
			}

			// All settings are in application scope onApplicationStart()
			if ( isDefined( "application._app_settings." & arguments.name ) ) {
				return application._app_settings[ arguments.name ];
			}
			/*
				THE REST OF THIS SHOULD NEVER GET EXECUTED.  All App vars are in App scope on application Start
					- We could deprecate it
			*/

			// All settings are in request scope onRequestStart()
			if ( isDefined( "request.settings." & arguments.name ) ) {
				return request.settings[ arguments.name ];
			}

			// if setting was previously requested skip the db visit
			if ( isDefined( "request._profile." & arguments.name ) ) {
				return request._profile[ arguments.name ];
			}
            // look up for a modern setting
            local.setting = queryExecute( " SELECT * FROM _Settings WHERE Input_Name = :name ", { name = '#arguments.name#' }, { datasource: application.datasource } );

            if ( local.setting.recordCount ) {
                request._profile[ arguments.name ] = local.setting.value;
                return request._profile[ arguments.name ];
            }

            // look up for classic settings (prior to 2015), save it into a request variable for all references in the same page
            if ( structKeyExists( request, "_profile_classic" ) eq false ) {
                request._profile_classic = queryExecute( " SELECT * FROM _Application_Settings ", {}, { datasource: application.datasource } );
            }

            if ( request._profile_classic.columnList.listFindNoCase( arguments.name ) ) {
                request._profile[ arguments.name ] = request._profile_classic[ arguments.name ][ 1 ];
                return request._profile[ arguments.name ];
            }

			// 'required' setting not found in application scope - trigger event error
			if ( arguments.missing_not_allowed ) {
				throw( type="configuration", message="Internal setting '#arguments.name#' is missing." );
			}

			local.defaults = { planner_indirect_categories: "MSA" };

			// 'optional' setting not found in application scope - return default value or empty string
			return structKeyExists( local.defaults, arguments.name )
						? local.defaults[ arguments.name ]
						: '';
	}
	</cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="generalLabel" output="false" hint="Return custom names saved in general labels (e.g. 'Legacy ID' or 'Operator Type')">
		<cfargument name="list_of_labels" required="no" default="" hint="List of specific general labels to return">

		<cfquery name="local.generalLabel" datasource="#application.datasource#">
			SELECT 	 General_Labels_ID
					,General_Labels_Desc
					,General_Labels_Label = CASE
												WHEN General_Labels_Label IS NULL OR LEN(LTRIM(RTRIM(General_Labels_Label))) = 0 THEN General_Labels_Desc
												ELSE General_Labels_Label
										    END
			FROM 	General_Labels
			WHERE	1 = <cfqueryparam value="1">
					<!--- specific labels are given --->
					<cfif len(trim(arguments.list_of_labels))>
						AND	General_Labels_Desc IN ( <cfqueryparam value="#trim(arguments.list_of_labels)#" list="true"> )
					</cfif>
		</cfquery>

		<cfset local.custom_names = {}>
		<!--- specific labels not given --->
		<cfif trim(arguments.list_of_labels) eq "">
			<cfoutput query="local.generalLabel">
				<cfset local.original_name = local.generalLabel.General_Labels_Desc>
				<cfset local.custom_names[ local.original_name ] = local.generalLabel.General_Labels_Label>
			</cfoutput>
		<cfelse>
			<!--- specific labels are given --->
			<cfloop list="#arguments.list_of_labels#" index="local.original_name">
				<cfquery name="local.qItem" dbtype="query">
					SELECT * FROM [local].generalLabel WHERE UPPER(general_labels_desc) = <cfoutput>'#uCase(trim(local.original_name))#'</cfoutput>
				</cfquery>
				<!---if a custom name is found use it otherwise use the original name --->
				<cfset local.custom_names[ local.original_name ] = local.qItem.recordCount
																		? local.qItem.General_Labels_Label
																		: local.original_name>
			</cfloop>
		</cfif>

		<!--- returns a string when one specific name is requested otherwise returns a structure --->
		<cfreturn listLen(arguments.list_of_labels) eq 1
					? local.custom_names[ trim(arguments.list_of_labels) ]
				  	: local.custom_names>
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
		public function cf_admin() output="false" {
			return { username: "admin",
					 password: decrypt( get_setting("CF_Admin_Password"), get_setting("GenerateSecretKey_AES_128"), "AES", "base64" )
			};
		}
	</cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <!--- This function returns the sql conditions for AG Grid filters (SERVER_SIDE).
	A column's filter model is passed to this function. The model has all the information
	about the column to be filtered o, e.g. Whether it is set as text,number or date on AG Grid etc.
	Note: Do not use cfqueryparam, else it will not work.
	--->
	<cffunction name="getAGGridfilterConditions" access="public" returntype="string">
		<cfargument name="columnFilterModel" type="struct" required="true">

			<cfset var filterValue = "">
			<cfset var filterCriteria = "">
			<cfset var filterType = "">
			<cfset var filterCode = "">

			<!--- Get the filter value --->
			<cfloop collection="#arguments.columnFilterModel#" item="SearchValue">
				<cfif structKeyExists(arguments.columnFilterModel,SearchValue)>
					<cfif SearchValue eq "filter" OR SearchValue eq "dateFrom" OR SearchValue eq "dateTo">
						<cfif SearchValue eq "dateFrom" OR SearchValue eq "dateTo">
							<!--- set date in "mm/dd/yyyy" format --->
							<cfset arguments.columnFilterModel[SearchValue] = DateFormat(arguments.columnFilterModel[SearchValue],"mm/dd/yyyy")>
						</cfif>
						<cfset filterValue = arguments.columnFilterModel[SearchValue]>
					<cfelseif SearchValue eq "type">
							<cfset filterCriteria = arguments.columnFilterModel[SearchValue]>
					<cfelseif SearchValue eq "filterType">
							<cfset filterType = arguments.columnFilterModel[SearchValue]>
					</cfif>
				</cfif>
			</cfloop>

			<cfif filterValue neq "">
				<!--- Filter criteria for "text" datatype on AGGrid --->
				<cfif filterType eq "text">
					<!--- Look for filter criteria anywhere in the search string --->
					<cfif filterCriteria eq "contains">
						<cfset filterCode = "like '%#filterValue#%'">
					<!--- Look for filter criteria from only the beginning of the search string --->
					<cfelseif filterCriteria eq "startsWith">
						<cfset filterCode = "like '#filterValue#%'">
					<!--- Look for filter criteria from only the end of the search string --->
					<cfelseif filterCriteria eq "endsWith">
						<cfset filterCode = "like '%#filterValue#'">
					</cfif>
				<!--- Filter criteria for "date" datatype on AGGrid --->
				<cfelseif filterType eq "date">
					<!--- EQ --->
					<cfif filterCriteria eq "equals">
						<cfset filterCode = filterCode & "= #CreateODBCDate(filterValue)#">
					<!--- GTE --->
					<cfelseif filterCriteria eq "greaterThanOrEqual">
						<cfset filterCode = filterCode & "	>= #CreateODBCDate(filterValue)#">
					<!--- LTE --->
					<cfelseif filterCriteria eq "lessThanOrEqual">
						<cfset filterCode = filterCode & "<= #CreateODBCDate(filterValue)#">
					</cfif>
				<!--- Filter criteria for "number""datatype on AGGrid --->
				<cfelseif filterType eq "number">
					<!--- EQ --->
					<cfif filterCriteria eq "equals">
						<cfset filterCode = filterCode & " = CAST(#filterValue# As FLOAT)">
					<!--- GTE --->
					<cfelseif filterCriteria eq "greaterThanOrEqual">
						<cfset filterCode = filterCode & ">= CAST(#filterValue# As FLOAT)">
					<!--- LTE --->
					<cfelseif filterCriteria eq "lessThanOrEqual">
						<cfset filterCode = filterCode & "<= CAST(#filterValue# As FLOAT)">
					</cfif>
				</cfif>
			</cfif>

		<cfreturn filterCode />
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- This function is called onApplicationStart().  The only other place it is called is loadApplicationAppSettings()
				- components.settings.ApplicationAppSettingsManager.loadApplicationAppSettings()
					- app_settings.cfm calls loadApplicationAppSettings()
					- Upgrade.cfm calls loadApplicationAppSettings()
	--->
    <cffunction name="application_settings" output="false" hint="Retrieve all settings and save in request.settings structure.">
            <cfset application._app_settings = {}>
            <!--- retrieve classic settings --->
            <cfquery name="local.query" datasource="#application.datasource#">
                SELECT * FROM _Application_Settings
            </cfquery>
            <cfloop list="#local.query.columnList#" index="local.column">
                <!--- convert structure key to lower case for easy reading --->
                <cfset application._app_settings[ lcase(local.column) ] = local.query[local.column][1]>
            </cfloop>

            <!--- retrieve modern settings --->
            <cfquery name="local.query" datasource="#application.datasource#">
                SELECT * FROM _Settings
            </cfquery>
            <cfoutput query="local.query">
                <!--- convert structure key to lower case for easy reading --->
                <cfset application._app_settings[ lcase(local.query.input_name) ] = local.query.value>
            </cfoutput>
    </cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="request_settings" output="false" hint="Retrieve all settings and save in request.settings structure.">
    	<!--- Don't go to the DB unless we need to --->
    	<cfif structKeyExists(application, "_app_settings") is true>
    		<cfif structKeyExists(request, "settings") is false>
    			<cfset request.settings = application._app_settings>
    		</cfif>
    	</cfif>
        <cfif structKeyExists(request, "settings") is false>
            <cfset request.settings = {}>
            <!--- retrieve classic settings --->
            <cfquery name="local.query" datasource="#application.datasource#">
                SELECT * FROM _Application_Settings
            </cfquery>
            <cfloop list="#local.query.columnList#" index="local.column">
                <!--- convert structure key to lower case for easy reading --->
                <cfset request.settings[ lcase(local.column) ] = local.query[local.column][1]>
            </cfloop>

            <!--- retrieve modern settings --->
            <cfquery name="local.query" datasource="#application.datasource#">
                SELECT * FROM _Settings
            </cfquery>
            <cfoutput query="local.query">
                <!--- convert structure key to lower case for easy reading --->
                <cfset request.settings[ lcase(local.query.input_name) ] = local.query.value>
            </cfoutput>
        </cfif>
    </cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="createExcelSheet" output="false">
        <cfargument name="query" required="true" type="query">
        <cfargument name="columns" required="false" type="array" hint="array of structures (eg. [{column:'Title'},{column:'LastCreatedDate',header:'Last Created Date'}])">
        <cfargument name="sheet_name" required="false" type="string" default="Sheet 1">

        <cfset local.excel_column_headers = []>
        <cfset local.valid_columns_names  = arguments.query.getColumnNames()>

        <!--- define/populate the optional columns parameter when it does not exist --->
        <cfif !structKeyExists(arguments, "columns")>
            <cfset arguments.columns = []>
            <cfloop array="#local.valid_columns_names#" item="local.column_name">
                <cfset arrayAppend(arguments.columns, { column: local.column_name })>
            </cfloop>
        </cfif>

        <cfset local.qoq_columns = []>
        <!--- exclude invalid columns and build column headers array --->
        <cfloop array="#arguments.columns#" item="local.struct">
            <!--- include only valid columns --->
            <cfif arrayFindNoCase(local.valid_columns_names, local.struct.column)>
                <!--- use given header if it exists otherwise use column name as header --->
                <cfset arrayAppend(local.qoq_columns, local.struct.column
                                                        & " AS "
                                                        & (structKeyExists(local.struct, "header") ? local.struct.header : local.struct.column))>
                <!--- do not change casing on specified header --->
                <cfset local.excel_column_header = (structKeyExists(local.struct, "header")
                                                        ? replace(local.struct.header, "_", " ", "all")
                                                        : application.util.string.capFirstTitle(replace(local.struct.column, "_", " ", "all")))>
                <cfset arrayAppend(local.excel_column_headers, local.excel_column_header)>
            </cfif>
        </cfloop>

        <!--- create a new query of query, include only certain columns --->
        <cfquery name="local.qoq" dbtype="query">
            <!--- valid columns exist --->
            <cfif arrayLen(local.qoq_columns)>
                SELECT
                        #arrayToList(local.qoq_columns)#
                 FROM [arguments].query
            <cfelse>
                <!--- valid columns not found, place nothing in query --->
                SELECT *
                  FROM [arguments].query
                 WHERE 1 = 0
            </cfif>
        </cfquery>

        <cfscript>
            local.excel_sheet = spreadSheetNew(arguments.sheet_name);

            // generate header row with default white font and black background
            if (arrayLen(local.excel_column_headers)) {
                spreadSheetAddRow(local.excel_sheet, arrayToList(local.excel_column_headers));
                spreadSheetFormatRow(local.excel_sheet, {bold=true, fgcolor="black", color="white"}, 1);
            }
            // generate rows based on query of query
            spreadSheetAddRows(local.excel_sheet, local.qoq);

            return local.excel_sheet;
        </cfscript>
    </cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
        // return sql statement from a given query with option to log sql info to sql.log file
        function reveal_sql( query_content, query_label, log_it ) {
            // validate query parameter, bail out if it is invalid
            if ( isDefined("arguments.query_content") eq false
                or isQuery(arguments.query_content) eq false )
                return '';

            // log sql information to sql.log file by default
            if ( isDefined("arguments.log_it") eq false )
                arguments.log_it = true;

            // set up query label
            if ( isDefined("arguments.query_label") )
                arguments.query_label = arguments.query_label;
            else
                arguments.query_label = "";

            // retrieve query meta data
            local.query_metadata = arguments.query_content.getMetadata().getExtendedMetaData();
            // set up returned information
            local.result = { queryLabel: arguments.query_label
                             ,recordCount: numberFormat(local.query_metadata.recordCount, ',')
                             ,execution_time: local.query_metadata.executionTime
                             ,parameters: ( isDefined("local.query_metadata.SQLParameters")
                                        ? ' params=' & serializeJSON(local.query_metadata.SQLParameters)
                                        : '' )
                             ,sql: local.query_metadata.sql
                             ,comments: application.util.string.substringCount( local.query_metadata.sql, " --" )
                            };

            // log information to sql.log file
            if (arguments.log_it) {
                writeLog(text=serializeJSON(local.result), file="sql", application=false);
            }

            return local.result;
        }
    </cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="save_ui_settings" output="false" access="remote">
        <cfargument name="user" required="true">
        <cfargument name="setting_name" required="true">
        <cfargument name="setting_value" required="true">

        <cfoutput>
		<cfquery datasource="#application.datasource#" result="local.query">
			SET NOCOUNT OFF
            UPDATE _UI_Settings
               SET Value = <cfqueryparam value='#arguments.setting_value#'>
                   , Last_Modified = GETDATE()
             WHERE User_ID = <cfqueryparam value='#arguments.user#'>
                    AND Setting = <cfqueryparam value='#arguments.setting_name#' maxlength="50">
        </cfquery>

        <cfif local.query.recordCount eq 0>
            <cfquery datasource="#application.datasource#">
                INSERT INTO _UI_Settings
                            (User_ID, Setting, Value, Last_Modified)
                    VALUES  (   <cfqueryparam value='#arguments.user#'>
                                , <cfqueryparam value='#arguments.setting_name#' maxlength="50">
                                , <cfqueryparam value='#arguments.setting_value#'>
                                , GETDATE())
            </cfquery>
        </cfif>
        </cfoutput>

        <cfreturn "success">
    </cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="get_ui_settings" output="false" access="remote">
        <cfargument name="user" required="true">
        <cfargument name="setting_name" required="true">
        <cfargument name="column_name" required="false" default="value">

        <cfquery datasource="#application.datasource#" name="local.query">
            SELECT Value, Last_Modified
              FROM _UI_Settings
             WHERE User_ID = <cfqueryparam value='#arguments.user#'>
                    AND Setting = <cfqueryparam value='#arguments.setting_name#' maxlength="50">
        </cfquery>

        <cfreturn local.query.recordCount eq 0
                    ? "null"
                    : local.query[ arguments.column_name ][ 1 ]>
    </cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cffunction name="is_session_expired" output="false">
        <cfargument name="user_id" required="true">

        <cfquery name="local.qSession" datasource="#application.datasource#">
            /*** gs.session_expiration_length value = ( selected time-out hours / 24 ) ***/
            SELECT    gs.Session_Expiration_Length * 24 * 60               AS Session_Expiration_In_Minutes
                    , DATEDIFF (n, st.Session_Date_Time_Stamp, GETDATE ()) AS Inactive_Time_Span_In_Minutes
              FROM Session_Tracker st
                    LEFT JOIN General_Settings gs ON 1 = 1
             WHERE session_user_id = <cfqueryparam value='#arguments.user_id#'>
        </cfquery>

        <cfreturn local.qSession.recordCount eq 0
                    ? false
                    : local.qSession.Inactive_Time_Span_In_Minutes gt local.qSession.Session_Expiration_In_Minutes>
    </cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
    function exportToXLSX ( required queries, sheet_names ) output="false" hint="Return an Excel content with multiple sheets based on given queries and optional sheet names" {
        var l = {};

        l.counter = 1;
        l.sheet_names = [];

        for ( l.query in arguments.queries ) {
            l.sheet_name = ( isDefined( "arguments.sheet_names" ) and arguments.sheet_names.len() gte l.counter )
                                    ? arguments.sheet_names[ l.counter ]
                                    : "Sheet " & l.counter;
            // keep track of sheet names
            l.sheet_names.append( l.sheet_name );

            if ( l.counter eq 1 ) {
                // create first sheet with XLSX format
                l.workBook = SpreadsheetNew( l.sheet_name, "yes" );
            }
            else {
                // add additional sheet and make it active
                spreadSheetCreateSheet ( l.workBook, l.sheet_name );
                spreadSheetSetActiveSheet( l.workBook, l.sheet_name );
            }

            // add columns header row
            spreadSheetAddrow( l.workBook, arrayToList( l.query.getMetaData().getColumnLabels() ) );
            // add rows in the query
            spreadSheetAddRows( l.workBook, l.query );
            // this function keeps the leading zeros in the columns - do not remove it
            spreadSheetFormatColumn( l.workBook, { color="black" }, 1);

            l.counter += 1;
        }

        // make 1st sheet as an active sheet
        spreadsheetSetActiveSheet( l.workBook, l.sheet_names[ 1 ] );

        l.tempPath = GetTempDirectory() & CreateUuid() & ".xlsx";
        cfspreadsheet( action="write", filename="#l.tempPath#", name="l.workBook", overwrite=true );

        return spreadSheetRead( l.tempPath );
    }
    </cfscript>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

    <cfscript>
		public function stringEncoded( required string s ) output="false" {
			return replace( arguments.s, "'", "''", "all" );
		}
	</cfscript>

</cfcomponent>