<!---
name:		Mappings.cfc
author:		JOHN BEYNON john@beynon.org.uk
purpose:	Allow creation/deletion and amendment of cf mappings 
programmatically using the factory service object
version: 	1.0
history:	19 February 2004	CREATED
--->
<cfcomponent hint="CFC to list/add/edit/delete CF mappings 
programmatically">

  <cfset factoryobject = CreateObject("java", "coldfusion.server.ServiceFactory")>
<cfset rt_service = factoryobject.runtimeservice>
 <cfset mappings = rt_service.mappings>

	<cffunction name="list" output="false" returntype="struct" hint="Return a 
structure of existing CF mappings">
		<cfscript>
			return mappings;
		</cfscript>
	</cffunction>


	<cffunction name="add" output="false" returntype="boolean" hint="Add a new 
CF mapping">
		<cfargument name="mappingname" required="yes" hint="mapping name to 
create">
		<cfargument name="absolutepath" required="yes" hint="absolute path to cf 
mapping">

		<cfscript>
			var result = false;
			// check that the first character in the mapping name is a /
			if( left(arguments.mappingname, 1) eq "/" ){
				// check that the mapping or absolute is not blank
				if (arguments.mappingname is not "" AND arguments.absolutepath is not 
"")
				{
				mappings["#arguments.mappingname#"] = "#arguments.absolutepath#";
				result = true;
				}
			}
			return result;
		</cfscript>
	</cffunction>


	<cffunction name="edit" output="false" returntype="boolean" hint="Edit an 
existing CF mapping">
  		<cfargument name="mappingname" required="no" hint="mapping name to 
edit">
		<cfargument name="newpath" required="no" hint="new absolute path">

		<cfscript>
			var result = false;
			if (structkeyexists(mappings, arguments.mappingname) AND 
arguments.newpath is not ""){
				structupdate(mappings, arguments.mappingname, arguments.newpath);
				result = true;
			}
			return result;
		</cfscript>
	</cffunction>

	<cffunction name="delete" output="false" returntype="boolean" hint="Delete 
an existing CF mapping">
		<cfargument name="mappingname" required="yes" hint="map name to delete">

		<cfscript>
			var result = false;
			if (structkeyexists(mappings, arguments.mappingname)){
				structdelete(mappings, arguments.mappingname);
				result = true;
			}
			return result;
		</cfscript>
	</cffunction>
</cfcomponent>
