<!--------------------------------------------------------------------------------------------------------------------------------------------------------
	Component: \components\UtilManager.cfc
	Date:      Dec 24, 2011
	Author:    Chris Nguyen
		
	Remarks:  
	    - application.util object is initialized in Application.cfc (avoid changing it somewhere else)
	    - Append 'resetUtil' to the URL to reload application.udf object (you need to do this when a .cfc under /components/util/ folder is modified)
	
	Usage examples:
	  
		- Calling a UDF defined in string.cfc:
				application.util.string.ActionFormat( action="Edit" )
				
		- Calling a UDF defined in DateTimeUDF.cfc:
				application.util.datetime.DateTimeFormat( date=now(), datemask="short", timemask="short" )
--------------------------------------------------------------------------------------------------------------------------------------------------------->

<cfcomponent displayname="UtilManager" output="no" hint="Houses all the user defined functions.">
     
    <cffunction name="Init" access="public" returntype="UtilManager" output="no" hint="Returns an initialized user defined library instance.">
	    <cfscript>
		    this.array      = CreateObject( "component", "util.array"     ).init( this ); // array manipulation functions
		    this.datetime   = CreateObject( "component", "util.dateTime"  ).init( this ); // date and time manipulation functions
		    this.list       = CreateObject( "component", "util.list"      ).init( this ); // list manipulation functions
		    this.io         = CreateObject( "component", "util.io"        ).init( this ); // input and output related functions
		    this.query      = CreateObject( "component", "util.query"     ).init( this ); // query manipulation functions
		    this.struct     = CreateObject( "component", "util.struct"    ).init( this ); // struct manipulation functions
		    this.string     = CreateObject( "component", "util.string"    ).init( this ); // string manipulation functions
		    this.validation = CreateObject( "component", "util.validation").init( this ); // data validation functions
	     
		    return( this );
	    </cfscript>
    </cffunction>
     
</cfcomponent>