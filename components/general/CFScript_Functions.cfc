	<cfcomponent displayname="These functions are used in CFScript instead of the tags" hint="CFScript Functions">
	
	<!--- These functions, instead of the tags, are used in CFScript --->
	<cffunction name="flush" returnType="void">
		<cfargument name="interval"  type="numeric" required="false">
			<cfif isDefined("interval")>
				<cfflush interval="#interval#">
			<cfelse>
				<cfflush>
			</cfif>
	</cffunction>

	<cffunction name="abort" output="false" returnType="void">
		<cfargument name="showError" type="string" required="false">
			<cfif isDefined("showError") and len(showError)>
				<cfthrow message="#showError#">
			</cfif>
			<cfabort>
	</cffunction>

	<cffunction name="Deletefile" output="false" returnType="void">
		<cfargument name="file" type="string" required="true">
		<cffile action="delete" file="#file#">	
	</cffunction>

	<cffunction name="fileRename" output="false" returnType="void">
		<cfargument name="source" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cfargument name="propertyName" type="string" required="true">
		<cffile action="Rename" Source="#source#" Destination="#Destination#" Attributes="#propertyName#">	
	</cffunction>

	<cffunction name="DoesfileExist" output="false" returnType="boolean">
		<cfargument name="file_path" type="string" required="true">
		
		<cfset File_Exists = 0>

		<cfif fileexists("#file_path#") eq 1>
			<cfset File_Exists = 1>
		</cfif>
		
		<cfreturn File_Exists>
	</cffunction>


	

	</cfcomponent>