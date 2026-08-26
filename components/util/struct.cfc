<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\util\struct.cfc
	Date:      Jan 6, 2012
	Author:    Chris Nguyen

	Purposes:  Houses all structure manipulation functions

	Remarks:
			- Append 'resetUtil' to the URL to reload application.udf object (you need to do this to test your changes in this file).
			- Calling UDF defined in other .cfc under \components\util\ folder:

			  * Syntax:   variables.library.<util_instance>.<udf_name>
			  * Example:  local.urlData = variables.library.string.parseURLData();

--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="Struct" output="false" hint="This has user defined functions for structure manipulation.">

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

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="convertToHiddenInput" output="true" returntype="string" hint="Convert elements in a structure into hidden inputs">
		<cfargument name="structure" type="struct" required="true">
		<cfargument name="skip_list" type="string" required="false" default="">

		<cfset local.hidden_input = []>

		<cfsavecontent variable="local.content">
			<cfloop collection="#arguments.structure#" item="local.item">
				<cfif ( listFindNoCase(arguments.skip_list, local.item) eq 0 ) and local.item neq "CFID" and local.item neq "CFTOKEN">

					<!--- skip hidden input that was added previously --->
					<cfif arrayFindNoCase(local.hidden_input, local.item) eq 0>
						<!--- lower case all input names for easy reference in jQuery --->
						<input type="hidden" name="#lcase(local.item)#" value="#arguments.structure[ local.item ]#">

						<!--- save hidden input to prevent duplicates --->
						<cfset arrayAppend(local.hidden_input, local.item)>
					</cfif>

				</cfif>
			</cfloop>
		</cfsavecontent>

		<!--- trim all white spaces --->
		#application.util.string.compress(local.content)#
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="saveToHiddenInput" output="true" returntype="string" hint="Convert elements in a structure into hidden inputs">
		<cfargument name="structure" type="struct" required="true">
		<cfargument name="include_list" type="string" required="true" default="">

		<cfset local.hidden_input = []>
		<cfsavecontent variable="local.content">
			<cfloop list="#arguments.include_list#" index="local.item">
					<!--- remove any leading/trailing white spaces --->
					<cfset local.item = trim(local.item)>

					<!--- skip hidden input that was added previously --->
					<cfif arrayFindNoCase(local.hidden_input, local.item) eq 0>

						<!--- lower case all input names for easy reference in jQuery --->
						<input type="hidden" name="#lcase(local.item)#" value="#(structKeyExists(arguments.structure, local.item) ? arguments.structure[ local.item ] : '')#">

						<!--- save hidden input to prevent duplicates --->
						<cfset arrayAppend(local.hidden_input, local.item)>
					</cfif>
			</cfloop>
		</cfsavecontent>

		<!--- trim all white spaces --->
		#application.util.string.compress(local.content)#
	</cffunction>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cffunction name="queryString" output="true" returntype="string" hint="">
		<cfargument name="structure" type="struct" required="false" default="#url#">
		<cfargument name="skip_list" type="string" required="true" default="">

		<cfset local.result = []>
		<cfloop collection="#arguments.structure#" item="local.item">
			<cfif ( listFindNoCase(arguments.skip_list, local.item) eq 0 ) and local.item neq "CFID" and local.item neq "CFTOKEN">
				<cfset arrayAppend(local.result, local.item & "=" & arguments.structure[ local.item ])>
			</cfif>
		</cfloop>

		<cfreturn arrayToList(local.result, "&")>
	</cffunction>


	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->

	<cfscript>
        // Below function sorts deep level structs & convert keys to lowercase
        function structSortLowerCase( given_struct, need_sorted_keys = 1 ) {
            if ( isNull( given_struct ) ) {
                return javacast( "null", "" );
            }

            if ( isStruct( given_struct ) ) {
                // sort all keys in the given struct
                if ( need_sorted_keys ) {
                    given_struct = structToSorted( given_struct, "text", "asc" );
                }

                // lowecase the keys
                structEach( given_struct, function( key, value ) {
                                                                    given_struct[ "#lcase(key)#" ] = isNull( value )
                                                                                                        ? javacast( "null", "" )
                                                                                                        : value;
                                                                    } );

                // make a recursive call on all values
                return structMap(given_struct, function( key, value ) {
                                                                        return structSortLowerCase( isNull( value )
                                                                                                        ? javacast( "null", "" )
                                                                                                        : value );
                                                                        } );
            }

            if ( isArray( given_struct ) ) {
                // make a recursive call on all values
                return arrayMap( given_struct, function ( value ) {
                                                                    return structSortLowerCase( isNull( value )
                                                                                                    ? javacast( "null", "" )
                                                                                                    : value );
                                                                    } );
            }

            return given_struct;
        }
	</cfscript>

</cfcomponent>