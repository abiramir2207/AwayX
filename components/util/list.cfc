<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\util\list.cfc
	Date:      Jan 6, 2012
	Author:    Chris Nguyen

	Purposes:  Houses all list manipulation functions

	Remarks:
			- Append 'resetUtil' to the URL to reload application.udf object (you need to do this to test your changes in this file).
			- Calling UDF defined in other .cfc under \components\util\ folder:

			  * Syntax:   variables.library.<util_instance>.<udf_name>
			  * Example:  local.urlData = variables.library.string.parseURLData();

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="List" output="false" hint="This has user defined functions for list manipulation.">

	<cffunction name="Init" access="public" returntype="any" output="false">
		<cfargument name="Library" type="any" required="true" />

		<cfscript>
			// The library variable is a reference to the main UDF library. This is
			// going to be used to reference other parts of the library that are not
			// in this specific component.
			variables.Library = arguments.Library;

			return( this );
		</cfscript>
	</cffunction>


	<cffunction name="removeDupes" access="public" returntype="any" output="false">
		<cfargument name="inList" type="any" required="true" />
		<cfargument name="delim" type="any" required="false" default="," />
		<cfscript>
			var listStruct = {};
			var i = 1;

			for(i=1;i<=listlen(inList, delim);i++)
		    {
		    	listStruct[listgetat(inList,i)] = listgetat(inList,i);
		    }

		    return structkeylist(listStruct);
		</cfscript>
	</cffunction>


	<cffunction name="queryString" access="public" returntype="string" output="false" hint="Returns a query string in this format key1=value1&...&key9=value2 based on a given structure.">
		<cfargument name="struct" required="true"/>
		<cfargument name="excluded_list" required="false" default="" hint="List of variables to be excluded"/>

		<cfset local.array = []>
		<cfloop collection="#arguments.struct#" item="local.entry">
			<cfif listFindNocase(arguments.excluded_list, local.entry) eq 0>
				<cfset arrayAppend(local.array, local.entry & "=" & arguments.struct[ local.entry ])>
			</cfif>
		</cfloop>

		<cfreturn arrayToList( local.array, "&" )>
	</cffunction>


	<cffunction name="jsKeysValues" access="public" returntype="string" output="false" hint='Returns a list of javaScript keys/values in this format key1:"value1",...,key9:"value9" based on a given structure.'>
		<cfargument name="struct" required="true"/>

		<cfset local.array = []>
		<cfloop collection="#arguments.struct#" item="local.entry">
			<cfset arrayAppend(local.array, local.entry & ':"' & arguments.struct[ local.entry ] & '"')>
		</cfloop>

		<cfreturn arrayToList( local.array )>
	</cffunction>
</cfcomponent>