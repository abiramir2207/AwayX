<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\util\validation.cfc
	Date:      Jan 6, 2012
	Author:    Chris Nguyen
		
	Purposes:  Houses all common validation functions 
	
	Remarks:   
			- Append 'resetUtil' to the URL to reload application.udf object (you need to do this to test your changes in this file).	
			- Calling UDF defined in other .cfc under \components\util\ folder:
			
			  * Syntax:   variables.library.<util_instance>.<udf_name>
			  * Example:  local.urlData = variables.library.string.parseURLData();
			    
--------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent displayname="Validation" output="false" hint="This has user defined functions for validations.">
	
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
	
	<!--- 
	Function will return argument3 if argument1 matches argument2
	Function will return argument1 if argument1 does not match argument2
	Can be used to avoid divide by zero error
	EasyIIf(val, 0, 1) will return val if val is not 0 and will reurn 1 when val is 0.
	This function will not be called with named arguments as this function is inteneted to be an easy function call.
	For the same reason we have defaults for argument2 and argument3 and can be used as below also
	EasyIIf(val)
	 --->
	<cffunction name="EasyIIf" access="public" returntype="string" output="false">
		<cfargument name="argument1" type="string" required="true" />
		<cfargument name="argument2" type="string" required="false" default="0" />
		<cfargument name="argument3" type="string" required="false" default="1" />
		
		<cfscript>
			return iif(arguments.argument1 == arguments.argument2, arguments.argument3, arguments.argument1);
		</cfscript>
	</cffunction>
	
</cfcomponent>